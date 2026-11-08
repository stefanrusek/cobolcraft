# Block registry, part 7: stairs, slabs, walls, workstations and the Nether wood set (Blocks fields 630 to 769)

| Item | Value |
|---|---|
| Covers | The rows of `Blocks` fields 630 to 769 (`VOID_AIR` through `POLISHED_BLACKSTONE_WALL`), which register 147 blocks (registry ids 884 to 1030, block state ids 18649 to 26449): the two technical air blocks and the bubble column; the stair, slab and wall families of the stone-like blocks (granite, diorite, andesite, their polished and mossy variants, smooth sandstone and quartz, end stone brick, red nether brick, brick, prismarine, red sandstone, stone brick, mud brick, nether brick, sandstone, blackstone and its polished variants); scaffolding; the workstations (loom, barrel, smoker, blast furnace, cartography table, fletching table, grindstone, lectern, smithing table, stonecutter); bell, lanterns and the copper lantern collection, campfires, sweet berry bush; the Nether wood set (warped and crimson stems, hyphae, nylium, fungi, roots, sprouts, wart block, planks, slabs, pressure plates, fences, trapdoors, fence gates, stairs, buttons, doors, signs) and the vines, shroomlight; the game-master blocks (structure block, jigsaw, test block, test instance block); composter, target, bee nest and beehive, honey block, honeycomb block, netherite block, ancient debris, crying obsidian, respawn anchor, the four potted Nether plants, lodestone and the blackstone group up to `POLISHED_BLACKSTONE_WALL`. For each block: id, key, class, state properties with value order, state counts, first and default state id, hardness, blast resistance, tool flag, light, map colour, sound, push reaction, instrument and builder flags (the columns of 24 part 1 section 7), plus for every class of the range the state properties and defaults, the complete shapes (stairs, slabs, walls, fences, gates, trapdoors, doors, buttons, plates, signs, scaffolding, bell, lantern, lectern, grindstone, composter and the rest), the placement state, the survival (`canSurvive`) rule, the neighbour update rule where it changes the state, and the block's use-on-block behaviour at the registry level. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas), with no execution. Every value in the rows and every shape box was read in this round from `net.minecraft.world.level.block.Blocks` and from the block classes named in backticks. State counts and first state ids were computed by summing the property value counts of every block registered before the range (all 911 `Blocks` fields, with the collections expanded) and checked against the totals in section 12. Statements not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions. |
| Status | Round RS4, part 7 of 8 (design map Part 5 GAP-1, and the columns of GAP-29 and GAP-30) |
| Siblings | Part 1 is [24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md): it defines the id rule, the state id rule, the `Properties` builder, the derived per-state values, the voxel shape model and the column schema, and this part cites it ("24 part 1 section N") instead of repeating it. Parts 2 to 6 and 8 cover the other field ranges and are cited as "24 part N". Several classes of this range (stairs, slabs, walls, fences, doors, trapdoors, buttons, signs, pressure plates, lanterns) also occur in other ranges with other materials; the rules below hold for every instance and the sibling parts may cite them. |

Class, method and field names in backticks say where a fact was read. They are not the design. "04 §5" means section 5 of
[04-registry-sync.md](04-registry-sync.md); "13 §2" means section 2 of
[13-client-gameplay-and-controls.md](13-client-gameplay-and-controls.md), and so on. The design map is
`docs/design/README.md`. Data versus code (design map R7): this document tabulates only code. Block models and block state
JSON, loot tables, recipes and tag files are data that the extraction tool copies; the tag **names** and data-component names
that code reads are listed where a rule uses them.

## Contents

1. Scope, ids and the collection expansion
2. Registration helpers in `Blocks`
3. Properties used in this range
4. Orientation conventions for rotated shapes
5. Air, bubble column
6. Stairs
7. Slabs
8. Walls
9. Fences, fence gates, trapdoors, doors, buttons, pressure plates, signs
10. Workstations and containers
11. Lighting blocks, scaffolding, bell, sweet berry bush
12. Nether plants, nylium, vines, stems
13. Game-master blocks
14. Composter, target, beehives, honey, crying obsidian, respawn anchor, flower pots
15. Block set types used by the range
16. Tint (GAP-29) and placement (GAP-30) summary
17. The rows: fields 630 to 769
18. Worked examples
19. Validation
20. Open questions

---

## 1. Scope, ids and the collection expansion

### 1.1 Field numbers and ids

- "Field N" counts the block fields of `Blocks` from `AIR` = 0, as part 1 does. Three predicate fields (`NOT_CLOSED_SHULKER`, `NOT_EXTENDED_PISTON`, `NEAR_PLANE_INTERSECTS_OUTLINE`) precede `AIR` in the static initialiser and are not blocks; the initialiser's 915 stores minus those three minus the final `SolidDebugger` call give the 911 block fields. In this count `VOID_AIR` is field 630 and `POLISHED_BLACKSTONE_WALL` is field 769 (140 fields).
- Registry id = number of blocks registered before it (04 §5.1). Before this range there are 630 fields; 16 of them are colour collections (16 blocks each, 15 extra) and 2 are weathering collections (8 blocks each, 7 extra; section 1.2), so `VOID_AIR` has id 630 + 16 x 15 + 2 x 7 = **884**. Inside the range only `COPPER_LANTERN` expands (seven extra blocks), so the 140 fields register **147** blocks, ids **884 to 1030**.
- State ids: `VOID_AIR` first state id **18649**; the last block of the range, `POLISHED_BLACKSTONE_WALL` (324 states), occupies 26126 to 26449; the next block (`CHISELED_NETHER_BRICKS`, part 8) starts at **26450**. The range holds 7801 states.
- Keys. The key is `minecraft:<path>`. For fields registered with a `BlockItemId` the block key and the item key come from the string pair in `BlockItemIds`; they equal the lower-case field name for every row of this range except one: the field `SWEET_BERRY_BUSH` is registered through the id `SWEET_BERRY_CROP`, whose block key is `sweet_berry_bush` and whose **item** key is `sweet_berries`. Eleven blocks of the range are registered through `BlockIds` and have no item: `void_air`, `cave_air`, `bubble_column`, `weeping_vines_plant`, `twisting_vines_plant`, `crimson_wall_sign`, `warped_wall_sign`, `potted_crimson_fungus`, `potted_warped_fungus`, `potted_crimson_roots`, `potted_warped_roots`.

### 1.2 The weathering collection (answers 24 part 1 Open question 1)

`WeatheringCopperCollection.registerBlocks(ids, register, waxedFactory, weatheringFactory, propertiesFn)` registers **eight** blocks per call, in this order, consecutively, at the position of the field:

| Order | State | Key prefix | Factory |
|---|---|---|---|
| 1 | unaffected | (empty) | weathering factory with the state `UNAFFECTED` |
| 2 | exposed | `exposed_` | weathering factory, `EXPOSED` |
| 3 | weathered | `weathered_` | weathering factory, `WEATHERED` |
| 4 | oxidized | `oxidized_` | weathering factory, `OXIDIZED` |
| 5 | waxed unaffected | `waxed_` | waxed factory |
| 6 | waxed exposed | `waxed_exposed_` | waxed factory |
| 7 | waxed weathered | `waxed_weathered_` | waxed factory |
| 8 | waxed oxidized | `waxed_oxidized_` | waxed factory |

The key of each is the prefix concatenated before the base name (`PREFIXES` zipped with the base name by a concatenation lambda whose first operand is the prefix; read: `WeatheringCopperCollection.<clinit>`, `prefixWithState`). The `Properties` come from one function of the weather state (for the copper lantern it ignores the state, so all eight have the same properties). In this range `COPPER_LANTERN` (field 687) is the only instance: ids 941 to 948, four states each (rows 941 to 948). The earlier instances (`COPPER_BARS` field 317 and `COPPER_CHAIN` field 319) registered eight blocks each too; that is the "2 x 7" in the id arithmetic above. The same count holds for the later instances (`COPPER_BLOCK` and the others), so ids after this range follow the same way (part 8 states the same boundary: field 769 is id 1030, field 770 is id 1031).

## 2. Registration helpers in `Blocks`

All helpers end in `Blocks.register(key, factory, properties)`, which stores the key in the properties and registers the constructed block (24 part 1 section 2.1). The helpers used in this range:

| Helper | Block class and constructor | `Properties` |
|---|---|---|
| `registerLegacyStair(id, source)` | `StairBlock(source.defaultBlockState(), properties)` | `ofLegacyCopy(source)` then `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)` |
| `registerStair(id, source)` (no use in this range; 6 blocks elsewhere) | same | `ofFullCopy(source)` then the same view-blocking predicate |
| `registerSlab(id, source)` | `SlabBlock(properties)` | `ofLegacyCopy(source)` then `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)` |
| `registerSlab(id, source, h)` | same | the above, then `destroyTime(h)`. In this range two slabs use it, both with h = 2.0 (read: `fconst_2` then the 3-argument overload): `blackstone_slab` (source `blackstone`, hardness 2.0) and `polished_blackstone_brick_slab` (source `polished_blackstone_bricks`, whose own hardness is 1.5, so the row shows 2.0). Several slabs registered earlier in the initialiser (stone, stone brick, quartz, red sandstone, cut red sandstone, purpur) also use the 3-argument form with 2.0 and are rows of other parts |
| `registerSlab(id, source, h, r)` | same | the above, then `strength(h, r)` (a 4-argument overload exists; not used by a row of this range) |
| `registerWall(id, source)` | `WallBlock(properties)` | `ofLegacyCopy(source)` then `forceSolidOn()` (no view-blocking override) |
| `netherStemProperties(color)` | (properties only) | `of().mapColor(color).instrument(BASS).strength(2).sound(STEM)` (the colour lambda ignores the state) |
| `buttonProperties()` | (properties only) | `of().noCollision().strength(0.5).pushReaction(POPPED)` |
| `flowerPotProperties()` | (properties only) | `of().instabreak().noOcclusion().pushReaction(POPPED)` |
| `wallVariant(sign, copyDescription)` | (properties only) | `of().overrideLootTable(<the standing sign's loot table>)`, plus `overrideDescription(<the standing sign's description id>)` when the flag is true (it is for both wall signs here); the row then adds colour, instrument, `forceSolidOn`, `noCollision`, `strength(1)` |
| `litBlockEmission(n)` | (light function) | light n when the state's `lit` is true, else 0 |

`NEAR_PLANE_INTERSECTS_OUTLINE` is a four-argument predicate (state, level, position, box): it is true when any box of the state's **occlusion shape** (`getOcclusionShape(...).toAabbs()`), moved to the position, intersects the box (the camera's near plane box). It replaces the default view-blocking rule (24 part 1 section 4.1: the suffocating predicate) for stairs and slabs, so these partial blocks block the view exactly where their occlusion shape is.

`ofLegacyCopy` copies hardness, resistance, collision, random ticks, light, map colour, sound, friction, speed factor, bounce, dynamic shape, occlusion, air, ignited by lava, liquid, force-solid flags, push reaction, tool flag, offset, terrain particles, features, emissive rendering, instrument and replaceable (24 part 1 section 4.3). It does not copy the predicates, the jump factor or the loot table key, so every stair, slab and wall has the loot table `blocks/<its own key>`. In the rows the flag column shows the copy as `legacyCopy:<source>`; the values in the other columns are already the copied values.

## 3. Properties used in this range

Property names, value lists and value order, read from `BlockStateProperties` and the enums (24 part 1 section 3 gives the state id formula: properties sorted by name, first slowest, last fastest, values in the listed order).

| Property name | Type and values in order | Used by |
|---|---|---|
| `facing` (horizontal) | north, south, west, east | stairs, loom, smoker, blast furnace, lectern, stonecutter, bell, campfires, trapdoors, fence gates, doors, wall signs, beehives, grindstone, buttons |
| `facing` (six) | north, east, south, west, up, down | barrel |
| `half` (stairs, trapdoor) | top, bottom | stairs, trapdoors |
| `half` (door) | upper, lower | doors |
| `shape` | straight, inner_left, inner_right, outer_left, outer_right | stairs |
| `type` | top, bottom, double | slabs |
| `up`, `lit`, `open`, `powered`, `hanging`, `bottom`, `drag`, `signal_fire`, `in_wall`, `has_book`, `waterlogged` | boolean: true, false | per class |
| `north`, `east`, `south`, `west` (wall) | none, low, tall | walls |
| `north`, `east`, `south`, `west` (fence) | boolean true, false | fences |
| `face` | floor, wall, ceiling | grindstone, buttons |
| `attachment` | floor, ceiling, single_wall, double_wall | bell |
| `hinge` | left, right | doors |
| `rotation` | 0 to 15 | standing signs |
| `axis` | x, y, z | stems, hyphae |
| `age` (berry) | 0 to 3 | sweet berry bush |
| `age` (vines) | 0 to 25 (26 values) | weeping and twisting vines (heads) |
| `distance` | 0 to 7 (8 values) | scaffolding |
| `bottom` | true, false | scaffolding |
| `drag` | true, false | bubble column |
| `level` | 0 to 8 | composter |
| `power` | 0 to 15 | target |
| `honey_level` | 0 to 5 | beehives |
| `charges` | 0 to 4 | respawn anchor |
| `has_book` | true, false | lectern |
| `signal_fire` | true, false | campfires |
| `in_wall` | true, false | fence gates |
| `mode` (structure) | save, load, corner, data | structure block |
| `mode` (test) | start, log, fail, accept | test block |
| `orientation` | down_east, down_north, down_south, down_west, up_east, up_north, up_south, up_west, west_up, east_up, north_up, south_up | jigsaw |
| `waterlogged` | true, false | stairs, slabs, walls, fences, lanterns, campfires, signs, trapdoors, scaffolding |

The `FrontAndTop` constants are written front-top (`DOWN_EAST` is front DOWN, top EAST); the serialized name is the lower-case constant name. The `StructureMode` and `TestBlockMode` serialized names are as listed (`TestBlockMode` also carries ids 0 to 3 in the same order).

Defaults (read from the constructors' `registerDefaultState` calls, including superclass constructors; a property that no constructor sets takes the **first** value of its list, because the default starts at `StateDefinition.any()`):

| Class | Default state |
|---|---|
| `AirBlock` | no properties |
| `BubbleColumnBlock` | `drag=true` |
| `StairBlock` | `facing=north, half=bottom, shape=straight, waterlogged=false` |
| `SlabBlock` | `type=bottom, waterlogged=false` |
| `WallBlock` | `up=true, north=east=south=west=none, waterlogged=false` |
| `ScaffoldingBlock` | `distance=7, waterlogged=false, bottom=false` |
| `LoomBlock`, `StonecutterBlock` | `facing=north` |
| `BarrelBlock` | `facing=north, open=false` |
| `SmokerBlock`, `BlastFurnaceBlock` (via `AbstractFurnaceBlock`) | `facing=north, lit=false` |
| `GrindstoneBlock` | `facing=north, face=wall` |
| `LecternBlock` | `facing=north, powered=false, has_book=false` |
| `BellBlock` | `facing=north, attachment=floor, powered=false` |
| `LanternBlock` | `hanging=false, waterlogged=false` |
| `CampfireBlock` | `lit=true, signal_fire=false, waterlogged=false, facing=north` |
| `SweetBerryBushBlock` | `age=0` |
| `RotatedPillarBlock` | `axis=y` |
| `WeepingVinesBlock`, `TwistingVinesBlock` (via `GrowingPlantHeadBlock`) | `age=0` |
| `PressurePlateBlock` | `powered=false` |
| `FenceBlock` | all four sides false, `waterlogged=false` |
| `TrapDoorBlock` | `facing=north, open=false, half=bottom, powered=false, waterlogged=false` |
| `FenceGateBlock` | `facing=north` (first value), `open=false, powered=false, in_wall=false` |
| `ButtonBlock` | `facing=north, powered=false, face=wall` |
| `DoorBlock` | `facing=north, open=false, hinge=left, powered=false, half=lower` |
| `StandingSignBlock` | `rotation=8, waterlogged=false` |
| `WallSignBlock` | `facing=north, waterlogged=false` |
| `StructureBlock` | `mode=load` |
| `JigsawBlock` | `orientation=north_up` |
| `TestBlock` | `mode=start` (first value; no constructor default was found) |
| `ComposterBlock` | `level=0` |
| `TargetBlock` | `power=0` |
| `BeehiveBlock` | `honey_level=0, facing=north` |
| `RespawnAnchorBlock` | `charges=0` |

## 4. Orientation conventions for rotated shapes

Many shapes below are built once for the direction NORTH and rotated. The artifact does it through `Shapes.rotateHorizontal`, `rotateHorizontalAxis`, `rotateAll` and `rotateAttachFace` with the symmetry-group constants `BLOCK_ROT_Y_90` and friends. This document states the rotation as geometry on the 16-pixel block (x grows east, z grows south, y grows up):

- **Yaw by one clockwise step** (viewed from above; north to east; `BLOCK_ROT_Y_90`): a point (x, z) goes to (16 - z, x). A box (x1, z1, x2, z2) goes to (16 - z2, x1, 16 - z1, x2). So the north-west corner box (0, 0, 8, 8) becomes the north-east corner box (8, 0, 16, 8). Two steps: (16 - x, 16 - z). Three steps: (z, 16 - x).
- `rotateHorizontal(shape)` returns a map: NORTH = the shape unchanged, EAST = one step, SOUTH = two steps, WEST = three steps. `rotateHorizontal(shape, group)` first applies the group, then the yaw.
- `rotateHorizontalAxis(shape)` returns a map keyed by axis: Z = the shape unchanged, X = one yaw step (so a box thin in z becomes a box thin in x).
- `rotateAll(shape)` returns six directions; NORTH is the unchanged shape; for the trapdoor and the vertical keys, section 9.3 states the result directly.
- `rotateAttachFace(shape)` returns, for `face` = wall, floor, ceiling and each horizontal facing, the base shape pitched and then yawed: WALL is the base shape yawed by the facing; FLOOR pitches the base shape so that its z = 16 side (the attachment side of the base) goes to the bottom, i.e. (y, z) goes to (16 - z, y), then yaws; CEILING pitches so that the z = 16 side goes to the top and then turns 180 degrees about the vertical axis, i.e. (y, z) goes to (z, 16 - y) followed by (x, z) going to (16 - x, 16 - z), then yaws.
- `INVERT_Y` (used for upside-down stairs) is the mirror y goes to 16 - y; it commutes with yaw.

The group constants were decoded in this round from `OctahedralGroup` and `SymmetricGroup3` (read: the constructor arguments of each constant, `SymmetricGroup3` permutations p0, p1, p2, and `Shapes.rotate(shape, group, centre)`). A group is an axis permutation plus three invert flags. `Shapes.rotate` builds the new shape so that the new X, Y and Z coordinate lists are the old lists of axes p0, p1 and p2, each flipped about the block centre (c goes to 16 - c) when the group inverts that new axis. The constants used:

| Constant | Alias read | Permutation (p0, p1, p2) | Inverted axes | Effect on a pixel point (x, y, z) |
|---|---|---|---|---|
| `BLOCK_ROT_Y_90` | `ROT_90_Y_NEG` | (2, 1, 0) | X | (16 - z, y, x) |
| `BLOCK_ROT_Y_180` | `ROT_180_FACE_XZ` | (0, 1, 2) | X and Z | (16 - x, y, 16 - z) |
| `BLOCK_ROT_X_90` | `ROT_90_X_NEG` | (0, 2, 1) | Z | (x, z, 16 - y) |
| `BLOCK_ROT_X_270` | `ROT_90_X_POS` | (0, 2, 1) | Y | (x, 16 - z, y) |

`compose` is a table lookup built from the same data; `a.compose(b)` means "apply `b` first, then `a`" (read from the table builder: the flag of axis k is the XOR of `a` inverting k and `b` inverting the axis that `a`'s permutation sends k to). The yaw map therefore applies the caller's group first and then the yaw (`BLOCK_ROT_Y_90.compose(group)` for EAST, `BLOCK_ROT_Y_180.compose(group)` for SOUTH, `BLOCK_ROT_Y_270.compose(group)` for WEST). `rotateAttachFace` uses: WALL = the yaw map of the base shape; FLOOR = the yaw map of `BLOCK_ROT_X_270` applied to the base shape (identity composed with it); CEILING = the yaw map of `BLOCK_ROT_Y_180.compose(BLOCK_ROT_X_90)`, which is pitch first, then the half turn, and as one transform is (x, y, z) goes to (16 - x, z, y). The earlier statement of the first-round reader (that the quarter turn is clockwise from above, taking the north-west corner box to the north-east corner box) and the floor and ceiling pitches are thereby confirmed by the group data, no longer inferred. The `Direction` effect of `BLOCK_ROT_Y_90` (read from `rotate(Vector3i)`: swap x and z, then negate x) is NORTH to EAST.


## 5. Air, bubble column

### 5.1 `AirBlock` (`void_air`, `cave_air`)

Properties of the builder as for `AIR` (24 part 1 rows): replaceable, no collision, no loot table, `air()`. No state properties, one state each (ids 18649 and 18650). Shape: the empty shape; render shape `INVISIBLE`. No item. They are placed by world generation and by commands only; nothing in the class distinguishes them from `AIR` except the key (the gameplay meaning of "void air" and "cave air" is by identity checks elsewhere, e.g. in tags `air`; not read here).

### 5.2 `BubbleColumnBlock` (`bubble_column`)

- Properties: `drag` (boolean, default true). Builder: map colour `WATER`, replaceable, no collision, no loot table, push reaction `POPPED`, `liquid()`, sound `EMPTY`. No item.
- Shape: empty (`getShape`); render shape `INVISIBLE`. The block reports the **water source fluid state** (`Fluids.WATER.getSource(false)`), so it is a water cell.
- `canSurvive`: the block below is a bubble column, or is in block tag `enables_bubble_column_push_up`, or is in `enables_bubble_column_drag_down`.
- Column states (`getColumnState(self, above, below)`): 1. if the state below is a bubble column, the result is the state below unchanged. 2. else if the state below is in `enables_bubble_column_push_up`, the result is the bubble column with `drag=false`. 3. else if in `enables_bubble_column_drag_down`, `drag=true`. 4. else if the state is a bubble column, plain water (`WATER` default state); otherwise the original state is kept.
- `canOccupy(self, state)`: the state is already a bubble column, or its fluid is in fluid tag `bubble_column_can_occupy`, the block is a `LiquidBlock`, the fluid is a source and its amount is at least 8.
- `updateColumn(level, pos, belowState)`: when the position can be occupied, set the column state there (flags 2), then walk upward: for each next cell that can be occupied, set the same column state (flags 2); stop at the first cell that cannot be occupied or when a set fails.
- Scheduling: `updateShape` always schedules a water tick (delay `FlowingFluid.getTickDelay`). It also schedules a block tick after **5** ticks (`CHECK_PERIOD`) when any of these holds: the state cannot survive; the changed neighbour is DOWN; the changed neighbour is UP, is not a bubble column and can be occupied. In the other cases the generic `Block.updateShape` result is returned. The block tick re-runs `updateColumn` with the state below.
- Entities: `entityInside` calls `onInsideBubbleColumn(drag)` on the entity; when the cell above has an empty collision shape and no fluid (a surface cell) it calls `onAboveBubbleColumn(drag, pos)` instead (the entity motion is in the entity physics documents).
- Bucket pickup (`pickupBlock`): replaces the block by air with flags 11 and returns a water bucket item.
- Client: `animateTick` spawns, when `drag` is true, one `CURRENT_DOWN` particle at (x + 0.5, y + 0.8, z + 0.5) with zero velocity; when `drag` is false it spawns `BUBBLE_COLUMN_UP` particles (two per tick, at the column centre and at a random point inside the cell). In both branches, with probability 1/200 per tick it plays the whirlpool ambient sound (drag) or the upwards ambient sound, with volume 0.2 + 0.2 x `nextFloat()` and pitch 0.9 + 0.15 x `nextFloat()`. Particles belong to RS24.
- Tint: `waterParticles()` (24 part 1 section 9.3).

## 6. Stairs (`StairBlock`)

### 6.1 State and registration

Properties (sorted order): `facing` (north, south, west, east), `half` (top, bottom), `shape` (straight, inner_left, inner_right, outer_left, outer_right), `waterlogged`; 4 x 2 x 5 x 2 = 80 states. Default: facing north, half bottom, shape straight, waterlogged false (index 11 inside the block). The constructor stores the base block and its default state (`baseState`). The class reports `useShapeForLightOcclusion` true, `isPathfindable` false for every computation type and the **base block's explosion resistance**. 19 blocks of the range use it, all registered with `registerLegacyStair`: for every one the numeric columns equal the source block's (rows in section 17).

### 6.2 Shapes (pixel units)

| Name | Boxes (x1, y1, z1, x2, y2, z2), bottom half, facing north |
|---|---|
| base slab | (0, 0, 0, 16, 8, 16) = `column(16, 0, 8)` |
| OUTER | base slab and the top north-west corner (0, 8, 0, 8, 16, 8) |
| STRAIGHT | OUTER and its one-step yaw: base slab and the top north half (0, 8, 0, 16, 16, 8) |
| INNER | STRAIGHT and its one-step yaw: base slab, top north half and top east half (8, 8, 0, 16, 16, 16) |

Per state the shape is `TABLE[half][type][key]` where `type` is OUTER for the shapes outer_left and outer_right, STRAIGHT for straight and INNER for inner_left and inner_right, and the key direction is:

| `shape` property | key direction |
|---|---|
| straight, outer_left, inner_right | the state's `facing` |
| inner_left | `facing` turned one step counter-clockwise (`getCounterClockWise`) |
| outer_right | `facing` turned one step clockwise (`getClockWise`) |

`TABLE[bottom]` = `rotateHorizontal(shape)` (the shape for the key yawed from north). `TABLE[top]` = `rotateHorizontal(shape, INVERT_Y)`: first mirror y to 16 - y (the slab goes to y 8..16, the corner blocks to y 0..8), then yaw. The collision shape and the outline are the same shape. Check that the names fit the geometry: facing north, outer_left uses key north = the north-west high corner (the left side when looking north is west); inner_right uses key north = north half and east half high (the extra step on the right); inner_left uses key west: the base INNER yawed three steps (north half goes west, east half goes north): west half and north half high.

### 6.3 Placement

`getStateForPlacement`: `facing` = the placing player's horizontal direction (`getHorizontalDirection`, not its opposite); `half` = top when the clicked face is DOWN, or when the clicked face is not UP and the click point's y within the block is above 0.5; else bottom; `waterlogged` = whether the fluid at the position is water; then `shape` is computed with the rule of 6.4 for the new state.

### 6.4 Shape property (`getStairsShape`)

Given a stair state S at position P with facing F and half H:

1. Let A be the state at P + F (the cell the stair faces, "front"). If A is a stair, has half H, and the axis of A's facing differs from the axis of F, and `canTakeShape(S, P, opposite of A's facing)` holds, then the result is OUTER_LEFT if A's facing equals F turned counter-clockwise, else OUTER_RIGHT.
2. Otherwise let B be the state at P + opposite(F) ("back"). If B is a stair with half H, the axis of B's facing differs from the axis of F, and `canTakeShape(S, P, B's facing)` holds, then the result is INNER_LEFT if B's facing equals F turned counter-clockwise, else INNER_RIGHT.
3. Otherwise STRAIGHT.

`canTakeShape(S, P, D)`: let C be the state at P + D; the answer is **true** unless C is a stair with the same facing and the same half as S. (So a corner does not form against a stair that already continues the same line.)

### 6.5 Neighbour updates, rotate, mirror, fluid

- `updateShape`: when waterlogged, schedule a water tick; when the changed neighbour direction is horizontal, recompute `shape` by 6.4; otherwise leave the state (then the generic `Block.updateShape`).
- `rotate(rotation)` rotates `facing` by the rotation.
- `mirror`: LEFT_RIGHT with a facing on the Z axis, and FRONT_BACK with a facing on the X axis, turn the stair by 180 degrees (`rotate CLOCKWISE_180`) and swap left and right in the shape (inner_left to inner_right, inner_right to inner_left, outer_left to outer_right, outer_right to outer_left); `straight` keeps shape with only the 180 degree turn; other mirror/facing combinations use the generic rule (read from the nested switch; the pairing of the four non-straight shapes is as stated).
- Fluid: waterlogged gives the water source (`getSource(false)`); the class implements `SimpleWaterloggedBlock` (RS10 owns placing and picking up water).
- `canSurvive`: default (true). Replaceable: no (`canBeReplaced` default). Light: dampening by the generic rule on the shape (never a full block).

## 7. Slabs (`SlabBlock`)

### 7.1 State and shapes

Properties: `type` (top, bottom, double), `waterlogged`; 6 states; default `type=bottom, waterlogged=false` (index 3 inside the block). 18 blocks in this range, registered with `registerSlab`; two of them carry the destroy time override 2.0 (`blackstone_slab` and `polished_blackstone_brick_slab`; flag `destroyTime:2.0` in rows 1017 and 1022). The other 16 keep the copied hardness. `useShapeForLightOcclusion` is true unless the type is `double`.

| `type` | Shape and collision (pixel) |
|---|---|
| top | `column(16, 8, 16)` = (0, 8, 0, 16, 16, 16) |
| bottom | `column(16, 0, 8)` = (0, 0, 0, 16, 8, 16) |
| double | the full block |

### 7.2 Placement

1. If the state already at the clicked position is the same slab block, the result is that state with `type=double` and `waterlogged=false`.
2. Otherwise the result is the default state with `waterlogged` from the fluid at the position, and `type=top` when the clicked face is DOWN, or when the clicked face is not UP and the click y within the block is above 0.5; else `type=bottom`.

### 7.3 Replace rule (`canBeReplaced(state, context)`)

1. If the slab is `double`, or the item in hand is not the slab's own item: not replaceable (false).
2. If the placement replaces the clicked-on block (`replacingClickedOnBlock`): let `upper` be (click y within the block > 0.5) and `F` the clicked face. For `type=bottom` the answer is true when F is UP, or when `upper` and F is horizontal. For `type=top` the answer is true when F is DOWN, or when not `upper` and F is horizontal. Otherwise false.
3. If the placement does not replace the clicked-on block (the position is adjacent): true.

### 7.4 Fluids

`getFluidState` returns water when waterlogged. `placeLiquid` and `canPlaceLiquid` work only when `type` is not `double` (a double slab cannot be waterlogged). Pathfinding (`isPathfindable`, read in `SlabBlock`): the LAND and AIR computations are false; the WATER computation is true exactly when the cell's fluid is in fluid tag `water` (that is, when waterlogged). The default of `Block` (`BlockBehaviour.isPathfindable`, read, used by every class of this range that does not override it): LAND and AIR are true when the state's collision shape, evaluated against the empty block getter at the origin, is **not** a full block; WATER is true when the cell's fluid is in fluid tag `water`; any other computation type is false.

## 8. Walls (`WallBlock`)

### 8.1 State

Properties (sorted order): `east`, `north`, `south` (each none, low, tall), `up` (true, false), `waterlogged`, `west`; 3 x 3 x 3 x 2 x 2 x 3 = 324 states. Default: `up=true`, every side `none`, `waterlogged=false` (index 3 inside the block). 16 blocks in this range, registered with `registerWall` (properties copied from the source, `forceSolidOn`). `isPathfindable` is false; `propagatesSkylightDown` is true exactly when not waterlogged; fluid is water when waterlogged.

### 8.2 Shapes

The class builds two shape tables from `makeShapes(heightPost, heightLow)`: shapes with (16, 14) and collision shapes with (24, 24). For one table with post height `HP` and low-arm height `HL`:

| Part | Box (pixel) |
|---|---|
| post | `column(8, 0, HP)` = (4, 0, 4, 12, HP, 12) |
| low arm, north | `boxZ(6, 0, HL, 0, 11)` = (5, 0, 0, 11, HL, 11); the east, south and west arms are the yawed copies (`rotateHorizontal`) |
| tall arm, north | `boxZ(6, 0, HP, 0, 11)` = (5, 0, 0, 11, HP, 11), yawed copies as above |

The shape of a state is the union of: the post when `up` is true (empty otherwise), and for each of north, east, south, west: nothing for `none`, the low arm for `low`, the tall arm for `tall`. The table is built per combination of all properties except `waterlogged` (`getShapeForEachState(fn, WATERLOGGED)`). Outline shape: (16, 14); collision shape: (24, 24), so the arms and the post are 24 pixels high for movement. The yawed arms (x and z extents): east arm x 5..16, z 5..11; south arm x 5..11, z 5..16; west arm x 0..11, z 5..11.

Two test shapes decide "tall" and the post: `TEST_SHAPE_POST` = `column(2, 0, 16)` = (7, 0, 7, 9, 16, 9), and `TEST_SHAPES_WALL` = `rotateHorizontal(boxZ(2, 16, 0, 9))`, i.e. north (7, 0, 0, 9, 16, 9) and its yaws. A shape "covers" a test shape when the test shape minus the shape is empty.

### 8.3 Connection rule (`connectsTo(neighbourState, sturdy, directionFromNeighbourToWall)`)

True when any of:

1. the neighbour is in block tag `walls`;
2. the neighbour is not an *exception block* and `sturdy` is true; the exception blocks (`Block.isExceptionForConnection`) are: any leaves block, `BARRIER`, `CARVED_PUMPKIN`, `JACK_O_LANTERN`, `MELON`, `PUMPKIN`, and any block in tag `shulker_boxes`;
3. the neighbour's block is an `IronBarsBlock` (panes and bars);
4. the neighbour is a `FenceGateBlock` whose `facing` axis, turned a quarter, is the direction's axis (`FenceGateBlock.connectsToDirection(state, direction)`: the gate's facing turned clockwise has the same axis as the direction).

`sturdy` for the neighbour on side D is `neighbour.isFaceSturdy(level, neighbourPos, opposite(D))` (the face of the neighbour towards the wall; support type FULL).

### 8.4 Computing the state

`updateShape(level, state, pos, aboveState, n, e, s, w)` (the four booleans are the connections):

1. Let `F` = the down-face shape of the **above** state's collision shape (`aboveState.getCollisionShape(level, pos).getFaceShape(DOWN)`).
2. Set each side with `makeWallState(connected, F, testWall[direction])`: `none` when not connected; `tall` when connected and `F` covers the test shape for that direction; else `low`.
3. Set `up` with `shouldRaisePost(stateWithSides, aboveState, F)`.

`shouldRaisePost(S, above, F)`:

1. If `above` is a wall block with `up=true`, the post is raised (true).
2. Let `nNone`, `sNone`, `eNone`, `wNone` be "side is none" for S. If all four are none, or `nNone != sNone`, or `wNone != eNone`: true (a corner, end or t-junction needs a post).
3. If (north and south are both `tall`) or (east and west are both `tall`): false.
4. Otherwise true when `above` is in tag `wall_post_override`, or when `F` covers `TEST_SHAPE_POST`; else false.

Placement (`getStateForPlacement`): read the five neighbours (N, E, S, W and above); each side connection is `connectsTo(neighbour, neighbour.isFaceSturdy(neighbourPos, towards the wall), towards the wall)`; `waterlogged` from the fluid; then `updateShape` of 8.4 on the default state with these booleans.

`updateShape` (neighbour change): schedule a water tick when waterlogged; direction DOWN: only the generic update; direction UP: `topUpdate` = re-run 8.4 with the current sides (connected when not `none`) and the new above state; horizontal direction D: `sideUpdate` = recompute the connection of side D from the neighbour that changed (same `connectsTo` rule) and keep the other three sides' connection as "side is not none", with the above state read at P + UP, then 8.4.

`rotate` and `mirror` permute the four sides with the facing rotation. (The exact mapping is tabulated in section 8.5.)

### 8.5 Rotate and mirror

Read from `WallBlock.rotate` and `WallBlock.mirror` (the switch maps `WallBlock$1` give the constant for each case). Only the four side properties move; `up` and `waterlogged` are unchanged. "new X = old Y" means the new value of side X is the old value of side Y.

| Rotation | new north | new east | new south | new west |
|---|---|---|---|---|
| none | old north | old east | old south | old west |
| clockwise 90 | old west | old north | old east | old south |
| clockwise 180 | old south | old west | old north | old east |
| counter-clockwise 90 | old east | old south | old west | old north |

| Mirror | Effect |
|---|---|
| left-right | new north = old south and new south = old north (east and west unchanged) |
| front-back | new east = old west and new west = old east (north and south unchanged) |
| none | unchanged |

## 9. Fences, fence gates, trapdoors, doors, buttons, pressure plates, signs

### 9.1 Fence (`FenceBlock`, `CrossCollisionBlock`)

- Properties: `east`, `north`, `south`, `west` (boolean), `waterlogged`; 32 states; default all false. `isPathfindable` false.
- `CrossCollisionBlock(a, b, c, d, e)` is constructed by `FenceBlock` as (4.0, 16.0, 4.0, 16.0, 24.0). It builds two shape tables with `makeShapes(post width, post height, arm width, arm min y, arm max y)`: **shapes** use (a, b, c, 0, d) = (4, 16, 4, 0, 16) and **collision** shapes use (a, e, c, 0, e) = (4, 24, 4, 0, 24). Post: `column(w, 0, h)` = (6, 0, 6, 10, h, 10). Arm (north): `boxZ(c, miny, maxy, 0, 8)` = (6, 0, 0, 10, maxy, 8), other arms yawed. State shape = post and the arms of the true sides. So the outline is a 4-wide post and 4-wide arms, 16 high; collision is 24 high.
- Connection (`connectsTo(state, sturdy, direction)`): true when the neighbour is a fence of the same kind (it is in block tag `fences`, and "in `wooden_fences`" is equal for the neighbour and for this fence's default state), or a fence gate whose axis fits (as walls, 8.3 rule 4), or the neighbour is not an exception block (8.3 rule 2 list) and its face towards the fence is sturdy (the combination was read exactly: sturdy and not an exception, or `isSameFence`, or a gate for which `FenceGateBlock.connectsToDirection` is true).
- Use on block (`useWithoutItem`): on the server it calls `LeadItem.bindPlayerMobs(player, level, pos)` and returns its result (the leash-to-fence rule, see the mob documents); on the client it returns PASS.
- Placement: each of the four sides from `connectsTo` on the neighbour with its sturdy face; `waterlogged` from the fluid. `updateShape`: schedule water tick; for a horizontal direction recompute that side only.

### 9.2 Fence gate (`FenceGateBlock`)

- Properties: `facing`, `in_wall`, `open`, `powered`; facing 4 x open 2 x powered 2 x in_wall 2 = 32 states; default `facing=north, open=false, powered=false, in_wall=false`. Constructor argument: a `WoodType` (here `CRIMSON`, `WARPED`; supplies sounds). Builder (rows): `forceSolidOn`, strength (2, 3).
- Shapes (pixel): outline `SHAPES` = `rotateHorizontalAxis(cube(16, 16, 4))` = (0, 0, 6, 16, 16, 10) for facing north or south, yawed for east and west; `in_wall` outline = the same minus the region `column(16, 13, 16)` (y 13..16 removed: (0, 0, 6, 16, 13, 10)). Collision: open is the empty shape; closed is `column(16, 4, 0, 24)` = (0, 0, 6, 16, 24, 10) (axis-keyed the same way). Support shape (`getBlockSupportShape`): open empty; closed `column(16, 4, 5, 24)` = (0, 5, 6, 16, 24, 10). Occlusion shape: two posts (0, 5, 7, 2, 16, 9) and (14, 5, 7, 16, 16, 9), `in_wall` moved down 3 pixels (y 2..13). The shape maps are keyed by the facing's axis (Z: unchanged; X: one yaw step).
- Placement: `facing` = the placing player's horizontal direction; `in_wall` true when a wall (block tag `walls`) is at either side along the gate's line (for a facing on the Z axis: west or east neighbour; for X: north or south); `open` and `powered` true when the position receives a neighbour signal (`hasNeighborSignal`). `updateShape`: when the changed neighbour is on the gate's line (the direction's axis equals the axis of the clockwise-turned facing) `in_wall` is recomputed from walls at the changed side and the opposite side.
- Redstone: `neighborChanged` sets `powered` and `open` to the signal when `powered` changes (flags 2) and plays the sound; use opens or closes it: when closing, `open=false` (flags 10); when opening, the gate's `facing` becomes the player's direction if that direction is the opposite of the gate's facing, then `open=true`.
- `connectsToDirection(state, d)`: the axis of the gate's facing turned clockwise equals the axis of `d`. `isPathfindable`: walk and air computations use `open`; water computation false (read from the switch).

- Use (`useWithoutItem`, read; no set-type check, a gate always opens by hand): when `open` is true the state is set with `open=false` (flags 10). When closed: if the player's horizontal direction equals the opposite of the gate's `facing`, `facing` is first set to the player's direction; then `open=true` (flags 10). Then, with the new `open` value, the sound is the wood type's `fenceGateOpen` or `fenceGateClose` event (section 15) at volume 1.0 and pitch `nextFloat() x 0.1 + 0.9`, played at the position (source `BLOCKS`), and the game event `BLOCK_OPEN` or `BLOCK_CLOSE` is emitted with the player as the cause. The use always succeeds.

### 9.3 Trapdoor (`TrapDoorBlock`)

- Properties: `facing`, `half` (top, bottom), `open`, `powered`, `waterlogged`; 64 states; default `facing=north, open=false, half=bottom, powered=false, waterlogged=false`. Constructor argument: a `BlockSetType` (sounds and rules, section 15).
- Shapes: `SHAPES` = `rotateAll(boxZ(16, 13, 16))`: the base is the panel (0, 0, 13, 16, 16, 16), a 3-pixel slab at the south edge, stored under the key NORTH. Each key direction D gives the 3-pixel panel against the face **opposite** D (NORTH: panel z 13..16; SOUTH: z 0..3; EAST: x 0..3; WEST: x 13..16; UP: y 0..3; DOWN: y 13..16). The state shape (outline and collision are the same, the class has no separate collision override) is `SHAPES[key]` where key = `facing` when open, else DOWN when `half=top`, else UP.
- Placement: `waterlogged` from the fluid; if the placement does not replace the clicked block or the clicked face is vertical: `facing` = the placing player's horizontal direction opposite, `half` = bottom when the clicked face is UP else top; otherwise (clicked on a horizontal face of a block): `facing` = the clicked face, `half` = top when the click y within the block is above 0.5 else bottom. If the position has a neighbour signal: `open=true`, `powered=true`.
- Redstone: `neighborChanged` (server side): when the signal differs from `powered`: if `open` differs from the signal, set `open` and play the open or close sound; then set `powered`; when waterlogged schedule a water tick. `isPathfindable`: land computation = `open`; water = `waterlogged`; air = `open`.

- Use (`useWithoutItem`, read): when the set type's `canOpenByHand` is false the result is PASS (no change). Otherwise `toggle`: `open` is cycled (flags 2); when waterlogged a water tick is scheduled with the water fluid's tick delay; then the sound is the set type's trapdoor open or close sound at volume 1.0 and pitch `nextFloat() x 0.1 + 0.9` and the game event `BLOCK_OPEN` or `BLOCK_CLOSE`; the result is SUCCESS. Explosion hit (`onExplosionHit`): when the explosion can trigger blocks, the set type allows opening by wind charge and the trapdoor is not `powered`, it toggles with no player; the parent rule then runs.

### 9.4 Door (`DoorBlock`)

- Properties (sorted): `facing`, `half` (upper, lower), `hinge` (left, right), `open`, `powered`; 4 x 2 x 2 x 2 x 2 = 64 states; default `facing=north, open=false, hinge=left, powered=false, half=lower`. Constructor argument: a `BlockSetType`.
- Shape: `SHAPES` = `rotateHorizontal(boxZ(16, 13, 16))` (panel (0, 0, 13, 16, 16, 16) under key NORTH; as for trapdoors a key D puts the panel against the face opposite D). The key of a state: `facing` when closed; when open, `facing` turned counter-clockwise if `hinge=right`, else clockwise. Both halves use the same shape (full block height each).
- Placement (lower position P): only when P.y is below the world's maximum y and the block above can be replaced (`canBeReplaced(context)`); then the state has `facing` = the player's horizontal direction, `hinge` from the rule below, `powered` and `open` = whether P or P.above has a neighbour signal, `half=lower`. `setPlacedBy` places the upper half (same state with `half=upper`) at P + UP.
- Hinge choice (`getHinge`): let L = the cell to the counter-clockwise side of the facing at P, R = the clockwise side; L' and R' the same one cell up. `score` = (-1 if L is a full collision block) + (-1 if L' is) + (+1 if R is) + (+1 if R' is). `leftDoor` = the state at L is a door block in its lower half, `rightDoor` likewise for R. If (`leftDoor` and not `rightDoor`) or `score` > 0: `hinge=right`. Else if (`rightDoor` and not `leftDoor`) or `score` < 0: `hinge=left`. Otherwise the click position decides: with (dx, dz) the facing's steps and (cx, cz) the click position inside the cell, `right` when (dx < 0 and cz < 0.5) or (dx > 0 and cz > 0.5) or (dz < 0 and cx > 0.5) or (dz > 0 and cx < 0.5); else `left`. (read: L is `getCounterClockWise` of the player's horizontal direction and R is `getClockWise`, each also taken one cell up; the L tests add -1 and the R tests add +1.)
- `canSurvive`: for the lower half the block below has its UP face sturdy (FULL); for the upper half the state below must be the same door block (`BlockState.is(this)`).
- `updateShape`: a change to the vertical neighbour (direction on the Y axis) keeps the other half consistent: if the neighbour is a door block with the other half, the state copies the neighbour's open, hinge, facing, powered with the own half preserved; otherwise the door is removed (air); a lower half whose DOWN neighbour changed and cannot survive becomes air.
- Redstone: `neighborChanged` computes `signal` = the position or the other half's position has a neighbour signal; when the neighbour block is not this door and the signal differs from `powered`: when `open` differs from the signal play the sound and emit game events (`BLOCK_OPEN` or `BLOCK_CLOSE`), then set `powered` and `open` to the signal (flags 2). `isPathfindable`: land and air use `open`; water false.

- Use (`useWithoutItem`, read): when the set type's `canOpenByHand` is false the result is PASS. Otherwise the clicked state's `open` is cycled and set (flags 10; the other half follows through `updateShape`, section above), the sound is the set type's door open or close sound at volume 1.0 and pitch `nextFloat() x 0.1 + 0.9`, and `BLOCK_OPEN` or `BLOCK_CLOSE` is emitted with the player; the result is SUCCESS. `setOpen(entity, level, state, pos, open)` (used by other callers) does the same when the state is this door and `open` differs: set `open` (flags 10), sound, game event.
- `rotate` replaces `facing` by the rotated direction; `mirror` with NONE returns the state unchanged; otherwise the state is rotated by the rotation that the mirror assigns to the current facing (`Mirror.getRotation(facing)`) and then the `hinge` is cycled (left to right or back).

### 9.5 Button (`ButtonBlock`)

- Properties (sorted): `face`, `facing`, `powered`; 3 x 4 x 2 = 24 states; default `facing=north, powered=false, face=wall`. Constructor arguments: a `BlockSetType` and `ticksToStayPressed`: crimson and warped 30; the stone button of the polished blackstone button 20 (set type `STONE`). Builder (`buttonProperties`): no collision, strength 0.5, push reaction `POPPED`.
- Attachment, `canSurvive`, placement and the neighbour update are those of `FaceAttachedHorizontalDirectionalBlock` (section 11.1).
- Shape: with the base box `B` = `boxZ(6, 4, 8, 16)` = (5, 6, 8, 11, 10, 16) rotated by `rotateAttachFace`, and the two cubes C14 = `cube(14)` = (1, 1, 1, 15, 15, 15) and C12 = `cube(12)` = (2, 2, 2, 14, 14, 14) (same rotation, they are symmetric): the shape of a state = (the rotated B) minus (C14 when `powered`, C12 when not). So the button is a 6 by 4 pixel plate, **2 pixels thick** (14..16 from the wall side) when released and **1 pixel** thick when powered. Wall, facing north (support at south): released (5, 6, 14, 11, 10, 16), powered (5, 6, 15, 11, 10, 16). Floor, any facing: released (5, 0, 6, 11, 2, 10) before yaw; ceiling: released (5, 14, 6, 11, 16, 10).
- Use: `press` sets `powered=true` (`setBlockAndUpdate`), updates neighbours, schedules a tick after `ticksToStayPressed`, plays the press sound and emits `BLOCK_ACTIVATE`. The scheduled tick calls `checkPressed`. When the set type allows arrows (`canButtonBeActivatedByArrows`: crimson and warped yes, stone and polished blackstone no) `entityInside` also checks for an `AbstractArrow` in the button's bounds and presses/releases accordingly.
- Signal: `isSignalSource` true; the direct signal is 15 towards the connected direction when powered (`getDirectSignal(direction)` is 15 when the button is powered and `direction` equals `getConnectedDirection(state)`, else 0).

### 9.6 Pressure plate (`PressurePlateBlock` on `BasePressurePlateBlock`)

- Properties: `powered`; 2 states; default false. Constructor argument: a `BlockSetType`. Builder: `forceSolidOn`, no collision, strength 0.5, push reaction `POPPED`.
- Shapes (pixel): released `column(14, 0, 1)` = (1, 0, 1, 15, 1, 15); pressed `column(14, 0, 0.5)` = (1, 0, 1, 15, 0.5, 15). No collision. Detection box (`TOUCH_AABB`): the first box of `column(14, 0, 4)` = (1, 0, 1, 15, 4, 15) in pixels, moved to the position.
- Signal strength: 15 when at least one entity of the sensitive class is inside the box, else 0 (the plate has only the two outputs). Sensitive class: set type sensitivity `EVERYTHING` = any `Entity`; `MOBS` = `LivingEntity`.
- Timing: `getPressedTime` = 20 ticks; `entityInside` (server side) calls `checkPressed` when the signal is currently 0; the scheduled tick re-checks while powered. `checkPressed` compares the old and the new signal: when they differ the plate sets the state (flags 2), updates neighbours and marks the block dirty; a falling edge plays the set type's plate click-off sound and emits `BLOCK_DEACTIVATE`, a rising edge the click-on sound and `BLOCK_ACTIVATE`; whenever the new signal is positive a tick is scheduled after 20.
- `canSurvive`: the block below is a rigid support (`Block.canSupportRigidBlock`) or supports the centre of its top face (`canSupportCenter(below, UP)`). `updateShape`: when the DOWN neighbour changes and the plate can no longer survive, it becomes air.

### 9.7 Signs (`StandingSignBlock`, `WallSignBlock`, base `SignBlock`)

- Standing sign: properties `rotation` (0 to 15), `waterlogged`; 32 states; default `rotation=8, waterlogged=false`. Constructor argument: a `WoodType`. Shape (both kinds' base `SignBlock`): `column(8, 0, 16)` = (4, 0, 4, 12, 16, 12) for the standing sign. `canSurvive`: the block below `isSolid`. Placement: `rotation` = `RotationSegment.convertToSegment(playerYaw + 180)` = round((yaw + 180) x 16 / 360) and 15 (`SegmentedAnglePrecision` with 4 bits: `Math.round(x * (16 / 360))` then `& 15`); `waterlogged` from the fluid. `updateShape`: the DOWN neighbour changes and the sign cannot survive: air. `rotate`: `Rotation.rotate(rotation, 16)`; `mirror`: `Mirror.mirror(rotation, 16)`.
- Wall sign: properties `facing`, `waterlogged`; 8 states; default `facing=north, waterlogged=false`. Shape `rotateHorizontal(boxZ(16, 4.5, 12.5, 14, 16))`: the panel (0, 4.5, 14, 16, 12.5, 16) under key NORTH (against the south face), yawed for the other facings. `canSurvive`: the block at P + opposite(facing) `isSolid`. Placement: for each of `getNearestLookingDirections` that is horizontal, `facing` = its opposite; the first state that can survive wins (with `waterlogged` from the fluid); none: not placeable. `updateShape`: the neighbour at the supporting side changes and the sign cannot survive: air. Properties through `wallVariant`: the wall sign shares loot table and description with the standing sign.
- Both: block entity `SignBlockEntity` (RS13); `isPossibleToRespawnInThis` true; sign items apply text (`SignApplicator`), waxing and editing (RS13).
- Sound (read): the `StandingSignBlock` and `WallSignBlock` constructors call `sound` with the `WoodType`'s `soundType`, which is `NETHER_WOOD` for `CRIMSON` and `WARPED`. The `WoodType` also carries `NETHER_WOOD_HANGING_SIGN` as the hanging-sign sound type (hanging signs are outside this range). The same applies to the other families: `DoorBlock`, `TrapDoorBlock`, `ButtonBlock` and `BasePressurePlateBlock` call `sound` with the `BlockSetType`'s `soundType`, and `FenceGateBlock` with the `WoodType`'s `soundType`. The rows of section 17 show the result.

- Sign use (`SignBlock`, read; shared by standing and wall signs). Block entity missing: PASS. **Item use** (`useItemOn`): an item that is a `SignApplicator` (dye, glow ink, ink sac and the like) can act when the player may build (`mayBuild`). On the client the result is SUCCESS when the applicator can act or the sign is waxed, otherwise CONSUME. On the server: when the applicator cannot act, the sign is waxed, or another player is editing it, the result is TRY_WITH_EMPTY_HAND; otherwise the text face the player is facing (`getSlotPlayerIsFacing`) is tested with `canApplyToSign`; on success `tryApplyToSign` runs, click commands are executed if present, the stat `ITEM_USED` of the item is awarded, `BLOCK_CHANGE` is emitted, one item is consumed and the result is SUCCESS; otherwise TRY_WITH_EMPTY_HAND. **Empty-hand use** (`useWithoutItem`, server only): the face the player is facing is chosen; click commands run first; if the sign is waxed the "interaction failed" sound of the block entity is played (source `BLOCKS`) and the result is SUCCESS_SERVER; if commands ran the result is SUCCESS_SERVER; else, when no other player is editing, the player may build and that face has editable text (`hasEditableText(textFilteringEnabled)`), the editor is opened (`openTextEdit`) and the result is SUCCESS_SERVER; otherwise the result is PASS (the final branch was read as returning PASS; its return line was not individually decoded).

## 10. Workstations and containers

All have `isPathfindable` default and the full-cube shape unless stated.

| Block | Class | State and placement | Use and notes (read) |
|---|---|---|---|
| `loom` | `LoomBlock` (parent `HorizontalDirectionalBlock`) | `facing` = opposite of the placing player's horizontal direction | right-click (server) opens the `LoomMenu` (`ContainerLevelAccess` for the position) with title key `container.loom`, awards stat `INTERACT_WITH_LOOM`; always returns success |
| `barrel` | `BarrelBlock` | `facing` = opposite of the placing player's nearest looking direction (all six); `open` false | block entity `BarrelBlockEntity`; use opens it (server side) with stat `OPEN_BARREL` and angers nearby piglins (`PiglinAi.angerNearbyPiglins(.., true)`); scheduled tick calls `recheckOpen`; comparator output = `AbstractContainerMenu.getRedstoneSignalFromBlockEntity` |
| `smoker` | `SmokerBlock` (`AbstractFurnaceBlock`) | `facing` = opposite of the placing player's horizontal direction; `lit` false | block entity `SmokerBlockEntity`; use opens the container (stat `INTERACT_WITH_SMOKER`); light 13 when lit; comparator = container signal; after removal `Containers.updateNeighboursAfterDestroy` runs (content dropping is RS13); client: when lit, 10 percent of animate ticks play `SMOKER_SMOKE` and spawn smoke at y + 1.1 |
| `blast_furnace` | `BlastFurnaceBlock` (`AbstractFurnaceBlock`) | as the smoker | `BlastFurnaceBlockEntity`, stat `INTERACT_WITH_BLAST_FURNACE`; light 13 when lit; client: 10 percent play `BLASTFURNACE_FIRE_CRACKLE`, flame particles near the front face |
| `cartography_table` | `CartographyTableBlock` | none | opens `CartographyTableMenu`, title `container.cartography_table`, stat `INTERACT_WITH_CARTOGRAPHY_TABLE` |
| `fletching_table` | plain `Block` | none | no use behaviour in the class (the block has a village job role in the POI data) |
| `smithing_table` | `SmithingTableBlock` (extends `CraftingTableBlock`) | none | opens `SmithingMenu`, title `container.upgrade`, stat `INTERACT_WITH_SMITHING_TABLE` |
| `stonecutter` | `StonecutterBlock` | `facing` = opposite of the player's horizontal direction | shape `column(16, 0, 9)` = (0, 0, 0, 16, 9, 16); `useShapeForLightOcclusion` true; `isPathfindable` false; opens `StonecutterMenu`, title `container.stonecutter`, stat `INTERACT_WITH_STONECUTTER` |
| `grindstone` | `GrindstoneBlock` (`FaceAttachedHorizontalDirectionalBlock`) | section 11.1 attachment | opens `GrindstoneMenu`, title `container.grindstone_title`; `canSurvive` is overridden to **true** (it needs no support); shape below |
| `lectern` | `LecternBlock` | `facing` = opposite of the player's horizontal direction; `has_book` true only when a player who can use game-master blocks places an item whose entity data contains `Book` | shapes below; redstone below |

The menu classes (`LoomMenu`, `CartographyTableMenu`, `SmithingMenu`, `GrindstoneMenu`, `StonecutterMenu`) and the block entities belong to the menu and block entity documents (design map RS13, RS16).

### 10.1 Grindstone shape

Base (wall, facing north; the legs reach the south face): legs `A` = (2, 6, 7, 4, 10, 16) and (2, 5, 3, 4, 11, 9); the mirrored legs `INVERT_X(A)` = (12, 6, 7, 14, 10, 16) and (12, 5, 3, 14, 11, 9); wheel `boxZ(8, 2, 14, 0, 12)` = (4, 2, 0, 12, 14, 12). The state shape is `rotateAttachFace(union)[face][facing]`. Results for facing north (computed with the decoded group transforms of section 4: floor (x, y, z) to (x, 16 - z, y), ceiling (x, y, z) to (16 - x, z, y); a box therefore maps floor (x1, y1, z1, x2, y2, z2) to (x1, 16 - z2, y1, x2, 16 - z1, y2) and ceiling to (16 - x2, z1, y1, 16 - x1, z2, y2)): **floor**: legs (2, 0, 6, 4, 9, 10), (2, 7, 5, 4, 13, 11) and the mirrored pair at x 12..14, wheel (4, 4, 2, 12, 16, 14); **ceiling**: legs (2, 7, 6, 4, 16, 10), (2, 3, 5, 4, 9, 11) (note: the second leg is lower) and the mirrored pair, wheel (4, 0, 2, 12, 12, 14); **wall** (south support): the base boxes unchanged. Other facings yaw clockwise by the steps from north.

### 10.2 Lectern shapes and signals

Collision shape (`SHAPE_COLLISION`): `column(16, 0, 2)` (0, 0, 0, 16, 2, 16) and `column(8, 2, 14)` (4, 2, 4, 12, 14, 12). Outline (`SHAPES`, by facing): the collision shape plus three desk boxes built with `boxZ` for north: (0, 10, 1, 16, 14, 5.333333), (0, 12, 5.333333, 16, 16, 9.666667) and (0, 14, 9.666667, 16, 18, 14), yawed for other facings. Occlusion shape = the collision shape. `isSignalSource` true; `getDirectSignal` is 15 towards UP when `powered` (else 0); comparator output is the block entity's redstone signal when `has_book` (else 0); the book is placed by `tryPlaceBook` when the item is in item tag `lectern_books`; the scheduled tick unpowers (`changePowered(false)`); opening the screen requires a book, otherwise the use returns `CONSUME`.

Read in this round (`LecternBlock`): `useItemOn`: with `has_book` true the result is TRY_WITH_EMPTY_HAND; with an item in tag `lectern_books`, `tryPlaceBook` runs and the result is SUCCESS when it placed the book, else PASS; with an empty hand stack in the main hand: PASS; otherwise TRY_WITH_EMPTY_HAND. `tryPlaceBook` succeeds only when `has_book` is false: on the server it takes one item from the stack, stores it in the block entity, calls `resetBookState(has_book=true)` (sets `powered=false` and `has_book` with `setBlockAndUpdate`, emits `BLOCK_CHANGE`, updates the block below) and plays `BOOK_PUT` (volume 1, pitch 1). `useWithoutItem`: with a book the server opens the lectern menu (stat `INTERACT_WITH_LECTERN`) and the result is SUCCESS, without a book CONSUME. **Pulse** (`signalPageChange`, called when a page is turned): `powered=true` (`setBlockAndUpdate`, then the block below is updated), a tick is scheduled after **2** ticks and level event **1043** (data 0) is sent; the tick calls `changePowered(false)`. `getDirectSignal` is 15 towards UP while `powered`.

## 11. Lighting blocks, scaffolding, bell, sweet berry bush

### 11.1 `FaceAttachedHorizontalDirectionalBlock` (grindstone, buttons)

- Property `face` (floor, wall, ceiling) plus `facing`.
- Connected direction (`getConnectedDirection`): CEILING gives DOWN, FLOOR gives UP, WALL gives `facing`. The support block is at P + opposite(connected direction): the block below for FLOOR, above for CEILING, behind (opposite of facing) for WALL.
- `canAttach(level, pos, dir)`: the block at pos + dir has its face towards the position (`opposite(dir)`) sturdy (FULL support). `canSurvive` = `canAttach(level, pos, opposite(connected))`.
- Placement: iterate `getNearestLookingDirections` (the six directions ordered by how close they are to the player's look direction); for each: vertical axis: `face` = CEILING when the direction is UP, else FLOOR, `facing` = the player's horizontal direction; horizontal axis: `face` = WALL, `facing` = the direction's opposite. The first state that `canSurvive` at the clicked position is the result; none: not placeable.
- `updateShape`: when the changed neighbour is the supporting side (direction = opposite of the connected direction) and the state can no longer survive: air; otherwise the horizontal-directional base rule.

### 11.2 Lantern (`LanternBlock`, `WeatheringLanternBlock`)

- Properties: `hanging`, `waterlogged`; 4 states; default both false. Builder: `forceSolidOn`, strength 3.5, sound `LANTERN`, `noOcclusion`, push reaction `POPPED`, map colour `METAL`; light 15 (lantern and copper lanterns) or 10 (soul lantern). The copper lantern collection registers 8 blocks (section 1.2): the four weathering ones use `WeatheringLanternBlock` (random ticks while a next weathering state exists: `isRandomlyTicking` = `WeatheringCopper.getNext(block)` present; `randomTick` calls `changeOverTime`; the weathering rules are in the copper block rows of part 8); the four waxed ones use `LanternBlock`.
- Shapes (pixel): standing = `column(4, 7, 9)` = (6, 7, 6, 10, 9, 10) and `column(6, 0, 7)` = (5, 0, 5, 11, 7, 11); hanging = the same moved up 1/16 block (one pixel) in y: (6, 8, 6, 10, 10, 10) and (5, 1, 5, 11, 8, 11).
- Placement: `waterlogged` from the fluid; iterate `getNearestLookingDirections`; the first direction on the Y axis gives `hanging` = (direction is UP); the state is accepted when it can survive; non-vertical directions are skipped; none: not placeable. `canSurvive`: with c = UP when hanging else DOWN, the block at pos + c supports the centre of its face towards the lantern (`canSupportCenter(level, pos + c, opposite(c))`). `isPathfindable` false. Fluid: water when waterlogged.

### 11.3 Campfire (`CampfireBlock`, soul campfire)

- Properties (sorted): `facing`, `lit`, `signal_fire`, `waterlogged`; 32 states; default `lit=true, signal_fire=false, waterlogged=false, facing=north`. Constructor arguments: `spawnParticles` and `fireDamage`: campfire (true, 1), soul campfire (false, 2). Light when lit: 15 (campfire), 10 (soul campfire). Builder: sound `WOOD`, strength 2, `noOcclusion`, `ignitedByLava`.
- Shape: `column(16, 0, 7)` = (0, 0, 0, 16, 7, 16) (outline and collision). `isPathfindable` false. A second constant `SHAPE_VIRTUAL_POST` = `column(4, 0, 16)` is used by the smoke-signal rule below.
- Placement: `waterlogged` from the fluid; `signal_fire` = the block below is a hay bale (`isSmokeSource`); `lit` = not waterlogged; `facing` = the placing player's horizontal direction.
- Water: `placeLiquid` into a campfire that is not waterlogged and gets water: if lit, play `GENERIC_EXTINGUISH_FIRE` (server) and douse; set `waterlogged=true` (and `lit=false`). A fire arrow (`onProjectileHit`, burning projectile that may interact) lights an unlit, non-waterlogged campfire (flags 11).
- Douse by item (`useItemOn`, read): the cooking placement above is tried first (an item that passes `CAMPFIRE_INPUT` is placed, or the use is CONSUME). Otherwise, when the held item is in item tag `douses_campfires` **and** the campfire is `lit`: on the server level event **1009** (data 0) is sent at the position; `douse(player, level, pos, state)` runs; the state is set with `lit=false` (`setBlockAndUpdate`); the held item is damaged by 1 (`hurtAndBreak`, the hand's slot); the result is SUCCESS. Otherwise the result is TRY_WITH_EMPTY_HAND. `douse` itself: on the client it spawns 20 particle calls (`makeParticles` with the `signal_fire` value and the extinguish flag true); on both sides it emits `BLOCK_CHANGE` for the acting entity at the position. The water case above also calls `douse` (with no entity) after playing `GENERIC_EXTINGUISH_FIRE` (volume 1, pitch 1, server only).
- Damage: `entityInside` hurts a `LivingEntity` standing in a lit campfire with the campfire damage source for `fireDamage` points.
- Cooking: block entity `CampfireBlockEntity` (RS13); right-click with an item that passes the recipe property set `CAMPFIRE_INPUT` places it (stat `INTERACT_WITH_CAMPFIRE`); the ticker (server) cooks with `RecipeType.CAMPFIRE_COOKING` while lit, otherwise decays cooking progress. Particles (`CAMPFIRE_COSY_SMOKE`, `CAMPFIRE_SIGNAL_SMOKE`) belong to RS24.

### 11.4 Scaffolding (`ScaffoldingBlock`)

- Properties (sorted): `bottom`, `distance` (0 to 7), `waterlogged`; 2 x 8 x 2 = 32 states; default `distance=7, waterlogged=false, bottom=false`. Builder: no collision (the class supplies its own collision), `dynamicShape`, push reaction `POPPED`, never valid for spawn, never a redstone conductor, sound `SCAFFOLDING`, map colour `SAND`.
- Shapes (pixel): `SHAPE_STABLE` = `column(16, 14, 16)` = (0, 14, 0, 16, 16, 16) (the top plate) and the four corner posts `rotateHorizontal(box(0, 0, 0, 2, 16, 2))` = (0,0,0,2,16,2), (14,0,0,16,16,2), (14,0,14,16,16,16), (0,0,14,2,16,16). `SHAPE_UNSTABLE_BOTTOM` = `column(16, 0, 2)` = (0, 0, 0, 16, 2, 16). `SHAPE_UNSTABLE` = STABLE plus UNSTABLE_BOTTOM plus the four bottom edge beams `rotateHorizontal(boxZ(16, 0, 2, 0, 2))` = (0, 0, 0, 16, 2, 2) yawed to all four sides. `SHAPE_BELOW_BLOCK` = the full block moved one block down.
- Outline (`getShape`): when the collision context holds the scaffolding item: the full block; else `SHAPE_UNSTABLE` when `bottom` is true, else `SHAPE_STABLE`. Interaction shape: the full block. Collision (`getCollisionShape`): the empty shape while placing; the stable shape when the entity is above the full block and not descending (`isAbove(block, pos, true)` and not `isDescending`); otherwise `SHAPE_UNSTABLE_BOTTOM` when `distance` is not 0 and `bottom` is true and the entity is above `SHAPE_BELOW_BLOCK`; else empty.
- Distance (`getDistance(level, pos)`): start with 7; look at the block below: if it is scaffolding use its `distance`, else if its UP face is sturdy the result is 0 (return at once); then for each horizontal neighbour that is scaffolding, take `min(result, neighbour.distance + 1)`, stopping early when the result is 1. `isBottom(level, pos, distance)` = `distance > 0` and the block below is not scaffolding.
- `canSurvive`: `getDistance < 7`. Placement: `distance` and `bottom` computed from `getDistance` and `isBottom`; `waterlogged` from the fluid. `canBeReplaced`: true when the item in hand is scaffolding (so a scaffolding can be placed onto scaffolding).
- Ticking: `onPlace` (server) and a horizontal or vertical `updateShape` schedule a tick after **1** tick (`TICK_DELAY`); `updateShape` also schedules a water tick when waterlogged. The tick recomputes `distance` and `bottom`; if the new distance is 7: when the old state's distance was already 7 the block turns into a falling block entity (`FallingBlockEntity.fall`), else it is destroyed with drops; if the new state differs the block is set with updates. (the pairing of old and new in the distance-7 test was read from local-variable order and is inferred; Open question 9)

### 11.5 Bell (`BellBlock`)

- Properties (sorted): `attachment` (floor, ceiling, single_wall, double_wall), `facing`, `powered`; 4 x 4 x 2 = 32 states; default `facing=north, attachment=floor, powered=false`. Builder: `forceSolidOn`, strength 5, sound `ANVIL`, push reaction `POPPED`, map colour `GOLD`. Block entity (ring animation, RS13). `isPathfindable` false.
- Shapes (pixel): `BELL_SHAPE` = `column(6, 6, 13)` (5, 6, 5, 11, 13, 11) and `column(8, 4, 6)` (4, 4, 4, 12, 6, 12). Ceiling: BELL plus `column(2, 13, 16)` (7, 13, 7, 9, 16, 9). Floor: the frame only, `cube(16, 16, 8)` = (0, 0, 4, 16, 16, 12) for facing on the Z axis and the one-yaw copy (4, 0, 0, 12, 16, 16) for the X axis (the bell body is not part of this shape as read). Double wall: BELL plus `column(2, 16, 13, 15)` = (7, 13, 0, 9, 15, 16) for the Z axis, one-yaw copy for X (keyed by the facing's axis). Single wall: BELL plus `boxZ(2, 13, 15, 0, 13)` = (7, 13, 0, 9, 15, 13), yawed per facing (key = facing). The same shape serves outline and collision.
- Support: the connected direction (the direction pointing away from the support) is UP for floor, DOWN for ceiling, and the facing's opposite for the wall types (so the support of a single wall bell is on the facing side, where its bar reaches). `canSurvive`: for CEILING the block above supports the centre of its DOWN face (`canSupportCenter(pos.above, DOWN)`); otherwise `canAttach(level, pos, opposite(connected))`.
- Placement: clicked face on the Y axis: `attachment` = CEILING when the face is DOWN else FLOOR, `facing` = the player's horizontal direction; if that cannot survive, try the next. Clicked face horizontal: `facing` = the clicked face's opposite; `attachment` = DOUBLE_WALL when the blocks on both sides along the clicked axis have a sturdy face towards the bell (west and east for the X axis, north and south for the Z axis), else SINGLE_WALL; if that cannot survive, fall back to FLOOR when the block below has a sturdy UP face else CEILING; if still not survivable: not placeable.
- `updateShape`: when the support side changes and the bell cannot survive and is not `DOUBLE_WALL`, it becomes air; for a wall bell whose facing axis equals the changed direction's axis: a DOUBLE_WALL whose support is no longer sturdy turns into SINGLE_WALL with the facing opposite, and a SINGLE_WALL whose opposite side is now sturdy turns into DOUBLE_WALL.
- Redstone: `neighborChanged` rings the bell (`attemptToRing(level, pos, null)`) when the position starts receiving a signal and updates `powered` (flags 3 as `setBlockAndUpdate`); a projectile hit rings it (`onProjectileHit` calls `onHit` with the proper-hit test on; the player owner of the projectile, if any, is passed); `useWithoutItem` also calls `onHit` with the test on, returning SUCCESS when the bell rang and PASS otherwise, and a ring by a player awards stat `BELL_RING`.

**Proper hit** (`isProperHit(state, hitFace, hitY)`, read), where `hitY` is the hit location's y minus the block's y (0 to 1): the hit is not proper (no ring) when the hit face is on the Y axis, or when `hitY` is greater than **0.8123999834060669** (the float 0.8124 widened to double). Otherwise it depends on `attachment`:

| `attachment` | Proper when |
|---|---|
| floor | the axis of the bell's `facing` equals the axis of the hit face |
| ceiling | always |
| single_wall | the axis of `facing` differs from the axis of the hit face |
| double_wall | the axis of `facing` differs from the axis of the hit face |

Example: a floor bell with `facing=north` hit on its north or south face at local height 0.5 rings; hit on its east face it does not; hit on its top face it never rings. The sound and the 'bell resonates' detection belong to RS13.

### 11.6 Sweet berry bush (`SweetBerryBushBlock`)

- Property `age` (0 to 3); default 0. Builder: map colour `PLANT`, random ticks, no collision, sound `SWEET_BERRY_BUSH`, push reaction `POPPED`. The item key is `sweet_berries` (section 1.1).
- Shape (outline; no collision): age 0 `column(10, 0, 8)` (3, 0, 3, 13, 8, 13); age 3 the full block; ages 1 and 2 `column(14, 0, 16)` (1, 0, 1, 15, 16, 15).
- `isRandomlyTicking` only while `age < 3`. Random tick: when `age < 3`, with probability 1/5 (`nextInt(5) == 0`) and the raw brightness at pos.above (with sky darkness 0) at least 9, `age` increases by 1 (flags 2) and a block change game event is emitted.
- `entityInside`: for a `LivingEntity` that is not a fox or bee, the entity is slowed (`makeStuckInBlock` with the vector whose components are the doubles 0.800000011920929 (the float 0.8 widened), 0.75 and 0.800000011920929). On the server, when `age > 0`, the entity is hurt with the damage source `sweetBerryBush` and amount 1.0 when the movement test passes. The movement vector is the entity's known movement when the entity is client-authoritative, otherwise its old position minus its current position. The test passes when that vector's horizontal squared length is greater than 0 and (|x| is at least 0.003 or |z| is at least 0.003); the constant is the float 0.003 widened to double, 0.003000000026077032 (read). Harvest by use, bone meal and the loot table are in the behaviour documents (RS11) and data.


## 12. Nether plants, nylium, vines, stems

### 12.1 Stems and hyphae (`RotatedPillarBlock`)

`warped_stem`, `stripped_warped_stem`, `crimson_stem`, `stripped_crimson_stem` use `netherStemProperties(colour)` (section 2): hardness and resistance 2, instrument `BASS`, sound `STEM`; the four hyphae blocks are built directly with the same numbers and the hyphae colour. Unlike the overworld logs (24 part 1 rows) none of these has `ignitedByLava`, and none requires a tool. Property `axis` (x, y, z), default y; placement: `axis` = the axis of the clicked face (24 part 1 section 10.3).

### 12.2 Nylium (`NyliumBlock`)

- No state properties. Builder: tool required, strength 0.4, sound `NYLIUM`, random ticks, instrument `BASEDRUM`.
- Random tick: if the block above does not let light through (`canBeNylium`: let A = the state above; the light dampening into the cell, `LightEngine.getLightDampeningInto(state, A, UP, A.getLightDampening())`, must be below 15), the nylium becomes `NETHERRACK` (`setBlockAndUpdate`). Otherwise nothing.
- Bone meal: a valid target when the block above is air and the position above is inside the build height; every use succeeds (`isBonemealSuccess` is always true); the effect places the configured feature `NetherFeatures.NYLIUM_BONEMEAL` above the block through the chunk generator (the feature itself is data and RS19).

### 12.3 Fungi (`NetherFungusBlock`)

- Constructor arguments (from the lambdas): (planted feature key, required nylium block, support tag): warped (`TreeFeatures.WARPED_FUNGUS_PLANTED`, `WARPED_NYLIUM`, tag `supports_warped_fungus`), crimson (`CRIMSON_FUNGUS_PLANTED`, `CRIMSON_NYLIUM`, `supports_crimson_fungus`). Parent `VegetationBlock`; no state properties. Builder: instabreak, no collision, sound `FUNGUS`, push reaction `POPPED`.
- Shape `column(8, 0, 9)` = (4, 0, 4, 12, 9, 12). `canSurvive` = the generic vegetation rule: the block below passes `mayPlaceOn`, which for the fungi is "the state is in the support tag". `updateShape`: when the block cannot survive the fungus becomes air.
- Bone meal: valid target when the block below is the required nylium and the position above is inside the build height; success when `nextFloat() < 0.4` (`BONEMEAL_SUCCESS_PROBABILITY` = 0.4); the effect places the configured feature at the position through the chunk generator (the feature definition is data; RS19).

### 12.4 Roots and sprouts (`NetherRootsBlock`, `NetherSproutsBlock`)

Parent `VegetationBlock`, no state properties; builders: replaceable, no collision, instabreak, offset type XZ (24 part 1 section 4.4), push reaction `POPPED`; roots sound `ROOTS`, sprouts sound `NETHER_SPROUTS`. Shapes: roots `column(12, 0, 13)` = (2, 0, 2, 14, 13, 14); sprouts `column(12, 0, 3)` = (2, 0, 2, 14, 3, 14) (both shifted by the XZ offset). Support: roots `mayPlaceOn` = the block below is in tag `supports_warped_roots` (warped) or `supports_crimson_roots` (crimson); sprouts: tag `supports_nether_sprouts`. The four potted variants (section 14.5) hold the roots and fungi.

### 12.5 Vines (`WeepingVinesBlock`, `TwistingVinesBlock` and their `*PlantBlock` bodies)

The head blocks derive from `GrowingPlantHeadBlock(properties, growthDirection, shape, scheduleFluidTicks, growPerTickProbability)` with the constructor values: weeping vines (DOWN, shape, false, 0.1), twisting vines (UP, shape, false, 0.1); the bodies derive from `GrowingPlantBodyBlock(properties, growthDirection, shape, scheduleFluidTicks)` with (DOWN or UP, shape, false).

| Block | Class | Properties | Shape (pixel) |
|---|---|---|---|
| `weeping_vines` | head | `age` 0..25 | `column(8, 9, 16)` = (4, 9, 4, 12, 16, 12) |
| `weeping_vines_plant` | body | none | `column(14, 0, 16)` = (1, 0, 1, 15, 16, 15) |
| `twisting_vines` | head | `age` 0..25 | `column(8, 0, 15)` = (4, 0, 4, 12, 15, 12) |
| `twisting_vines_plant` | body | none | `column(8, 0, 16)` = (4, 0, 4, 12, 16, 12) |

Builders: no collision, instabreak, sound `WEEPING_VINES` (both kinds), push reaction `POPPED`; the heads have random ticks. Map colours: weeping `NETHER`, twisting `COLOR_CYAN`. The plant bodies are registered through `BlockIds` (no item).

Rules read from the shared classes:

1. **Head random ticking**: only while `age < 25` (`isRandomlyTicking`). A random tick with `age < 25`: with probability `growPerTickProbability` (`nextDouble() < 0.1`), when the cell at pos + growthDirection can be grown into, the head is placed there (the head state with `age` increased by one, `BlockState.cycle(age)`).
2. `canGrowInto(state)` for both nether vines: the state is air (`NetherVines.isValidGrowthState`).
3. **Placement**: if the cell at pos + growthDirection holds the head or the body of the same family, the placed block is the **body**; otherwise the **head** with `age` = `nextInt(25)` (0 to 24).
4. **Survival** (`canSurvive`, shared by head and body): let S be the state at pos + opposite(growthDirection) (above for weeping, below for twisting). Both must hold: S passes `canAttachTo(S)` (always true for these classes) and (S is the head or body of the same family, or S has its face towards the plant, `growthDirection`, sturdy with support type FULL). The scheduled tick (`tick`) destroys the block with drops when it can no longer survive.
5. **Neighbour updates** (head): when the changed neighbour is on the opposite-of-growth side and the head cannot survive, a tick is scheduled after 1 tick; when the neighbour in the growth direction becomes the head or the body of the same family the head is converted into the body (`updateBodyAfterConvertedFromHead`). The **body's update** (`GrowingPlantBodyBlock.updateShape`, read): (a) when the changed neighbour is on the opposite-of-growth side and the body cannot survive, a tick is scheduled after 1 tick; (b) when the changed neighbour is in the growth direction and is neither this body block nor the head block of the family, the body is replaced by the head state of `getStateForPlacement(random)` (a head with a random `age`, step 3; `updateHeadAfterConvertedFromBody` returns that head state unchanged); (c) otherwise, when the class's `scheduleFluidTicks` flag is set (false for both vine bodies), a water tick is scheduled; then the default update. `updateBodyAfterConvertedFromHead(headState, bodyState)` (head to body, used in the head's rule) returns the new body state unchanged, i.e. the default body state.
6. **Bone meal**: valid when the cell at pos + growthDirection can be grown into and is inside the build height. The effect: let `n` = `getBlocksToGrowWhenBonemealed`; let `a` = min(age + 1, 25); for up to `n` cells in the growth direction, as long as the next cell can be grown into and is inside the build height, set a head with `age = a` there (then `a = min(a + 1, 25)`). `n` for the nether vines (`NetherVines.getBlocksToGrowWhenBonemealed(random)`): start with a threshold of 1.0 and a count of 0; repeat: if `nextDouble()` is below the threshold, multiply the threshold by 0.826 and add one to the count, otherwise stop; the result is the count.

### 12.6 Other plain blocks of the group

`warped_wart_block` (strength 1, sound `WART_BLOCK`), `shroomlight` (strength 1, sound `SHROOMLIGHT`, light 15), `crimson_planks` and `warped_planks` (strength (2, 3), sound `NETHER_WOOD`, instrument `BASS`), `fletching_table`, `honeycomb_block` (strength 0.6, sound `CORAL_BLOCK`), `netherite_block` (tool required, strength (50, 1200), sound `NETHERITE_BLOCK`), `ancient_debris` (tool required, strength (30, 1200), sound `ANCIENT_DEBRIS`), `lodestone` (tool required, strength 3.5, sound `LODESTONE`, push reaction `IMMOVEABLE`), `blackstone` and its polished, brick, cracked, chiseled and gilded forms (plain `Block`, values in the rows) are the plain `Block` class: full cube, no state, no behaviour. (`lodestone` has no class behaviour in this version's `Blocks`; compass use is an item rule, RS5.) Crimson and warped slabs use the slab rules of section 7 with the planks as the source.

## 13. Game-master blocks

All four are non-breakable in survival (hardness -1, blast resistance 3600000, no loot table) and implement `GameMasterBlock`; their use screens and placement are for players that pass `canUseGameMasterBlocks` (the permission test is the entity document's, not read here).

| Block | Class | Properties | Rules read |
|---|---|---|---|
| `structure_block` | `StructureBlock` (block entity `StructureBlockEntity`) | `mode` (save, load, corner, data), default load | use calls `usedBy(player)` (opens the editor; success on true else pass); `setPlacedBy` calls `createdBy(entity)` on the block entity; `neighborChanged` (server): when the position's signal differs from the entity's `isPowered`, rising edge sets powered and calls `trigger(level, entity)`, falling edge clears powered |
| `jigsaw` | `JigsawBlock` (block entity `JigsawBlockEntity`) | `orientation` (`FrontAndTop`, 12 values), default `north_up` | placement: front = the clicked face; top = UP when the clicked face is horizontal, else the opposite of the player's horizontal direction (when the clicked face is vertical); `rotate` and `mirror` apply the group rotation to the `FrontAndTop` value; use opens the jigsaw editor (requires game-master) |
| `test_block` | `TestBlock` (`TestBlockEntity`) | `mode` (start, log, fail, accept) | placement mode from the item's block-state component when present; use opens the test block screen (client side path when the player passes the permission) ; `neighborChanged` (server) acts only in mode `start`: rising edge sets powered and triggers, falling edge clears powered; the scheduled tick resets the entity |
| `test_instance_block` | `TestInstanceBlock` (`TestInstanceBlockEntity`) | none | use opens the instance screen for a permitted player |

The builders: `structure_block` and `jigsaw` map colour `COLOR_LIGHT_GRAY`, tool required, strength (-1, 3600000), no loot table; `test_block` same without the tool flag; `test_instance_block` no colour, `noOcclusion`, same strength, no loot table. All are full cubes except the test instance block (its shape is the default `Block` shape too; `noOcclusion` affects only occlusion). The block entity types and their data are RS13.

## 14. Composter, target, beehives, honey, crying obsidian, respawn anchor, flower pots

### 14.1 Composter (`ComposterBlock`)

- Property `level` (0 to 8), default 0; comparator output = `level`. Builder: strength 0.6, sound `WOOD`, `ignitedByLava`, instrument `BASS`, colour `WOOD`. `isPathfindable` false.
- Shapes (pixel): `SHAPES[i]` for i = 0..7 = the full block minus `column(12, clamp(2i + 1, 2, 16), 16)`: a bin with 2-pixel walls whose floor rises with the level (floor top y: i=0: 2; 1: 3; 2: 5; 3: 7; 4: 9; 5: 11; 6: 13; 7: 15); `SHAPES[8]` = `SHAPES[7]`. Outline = `SHAPES[level]`; collision = `SHAPES[0]`; interaction shape = the full block.
- Use with an item: when `level < 8` and the item has the data component `COMPOSTABLE`: if `level < 7` (server): `layers` = the component's `layers` int provider resolved in a loot context (parameters: the block state, the cell centre as origin, and optionally the interacting entity; parameter set `BLOCK_INTERACT`; default 0 when resolution fails); if `layers > 0` the level becomes `clamp(level + layers, 0, 7)` (block change game event) and, when the new level is 7, a tick is scheduled after 20; in all cases (also when no layer was added) the world event 1500 is sent with data 1 when the state changed and 0 otherwise, the item-used stat is awarded and **one item is consumed**; the use returns success. At level 7 the item is not consumed (success is still returned).
- Tick: when `level == 7` the level cycles to 8 (a ready sound is played). `onPlace` schedules the same tick (after 20) when the placed state is level 7.
- Use without an item: `level == 8` empties (see below), otherwise pass. Emptying (`extractProduce`): on the server drops one bone meal item entity at the cell's lower corner + (0.5, 1.01, 0.5) with a random horizontal offset of up to 0.7 and the default pick-up delay; then the level becomes 0 (block change game event) and the empty sound plays.
- Hoppers and droppers see a container: level 8 gives an output container holding one bone meal; level below 7 gives an input container that accepts one compostable item from above (`Direction.UP`) at a time; level 7 gives an empty container. The compostable chances are data on the item (the `COMPOSTABLE` component, RS5).

### 14.2 Target (`TargetBlock`)

- Property `power` (0 to 15; the `OUTPUT_POWER` property uses the name `power`), default 0. Builder: strength 0.5, sound `GRASS`, colour `QUARTZ`. `isSignalSource` true; the output equals `power`.
- A projectile hit (`onProjectileHit`): computes the strength `s` from the hit: take the hit location's fractional part on each axis, its distance from 0.5 (`|frac(c) - 0.5|`), and let `d` = the larger of the two distances on the axes **other than** the hit face's axis (face on Y: x and z; face on Z: x and y; face on X: y and z); `s` = `max(1, ceil(15 x clamp((0.5 - d) / 0.5, 0, 1)))`. The block is powered with `s` for **20 ticks** when the projectile is an arrow, otherwise **8 ticks** (set `power`, then schedule the reset tick; the set is skipped when a tick is already scheduled for the block). When the owner is a server player the stat `TARGET_HIT` is awarded and the `TARGET_BLOCK_HIT` trigger fires with the hit location and `s`.
- The scheduled tick sets `power` back to 0 when it is not already 0. `onPlace` (server, when the new state is not the replaced target): a placed target with `power > 0` and no scheduled tick is reset to 0 with flags 18.

### 14.3 Bee nest and beehive (`BeehiveBlock`)

Properties (sorted): `facing`, `honey_level` (0 to 5); 24 states; default `honey_level=0, facing=north`. Placement: `facing` = the opposite of the placing player's horizontal direction. Comparator output = `honey_level`. Block entity `BeehiveBlockEntity` (bees inside; RS13 and the bee rules). Use with an item (`useItemOn`, read) at `honey_level >= 5`: **shears** (server only): `dropHoneycomb` (loot table `harvest_beehive` as a block-interaction table), the `BEEHIVE_SHEAR` sound at the player's position (volume 1, pitch 1), 1 durability damage to the shears, game event `SHEAR`; **glass bottle** (the bytecode path is not gated on the server in the part read): one bottle is taken, `BOTTLE_FILL` is played (volume 1, pitch 1), a honey bottle replaces the stack when it empties, else it is added to the inventory, or dropped (not forced, predicted) when the inventory is full; game event `FLUID_PICKUP`; the server awards stat `ITEM_USED` for the item. After a successful harvest: if the position is a smoky position (`CampfireBlock.isSmokeyPos`) only the honey level is reset to 0 (`setBlockAndUpdate`); otherwise, when the hive contains bees `angerNearbyBees` runs first, then `releaseBeesAndResetHoneyLevel` (resets the level to 0 and releases all bees with the EMERGENCY status, naming the player); the result is SUCCESS. Any other case falls to the parent rule.

`angerNearbyBees`: the box is the block grown by (8, 6, 8); if it holds at least one bee and at least one player, every bee in it that has no target gets a random player of that box as its target.

`playerDestroy` (server, after the normal destruction): when the block entity is a hive and the tool does **not** carry an enchantment in tag `prevents_bee_spawns_when_mining`: all bees are released (EMERGENCY, naming the player), `Containers.updateNeighboursAfterDestroy` runs and `angerNearbyBees` runs; in every case the advancement trigger `BEE_NEST_DESTROYED` fires with the bee count. `onExplosionHit` runs the parent rule and `angerNearbyBees`.

`playerWillDestroy` (server, read): when the player **prevents block drops** (`preventsBlockDrops`, creative mode) and the game rule `BLOCK_DROPS` is true and the block entity is a hive that is not empty or whose `honey_level` is above 0, an item stack of this block is created, the block entity's components are applied and `BLOCK_STATE` is set to `honey_level` = the current level, and the stack is spawned as an item entity at the block position with the default pickup delay; then the parent rule runs. (This is the creative-mode path that keeps the hive content; survival drops come from the loot table.)

Client drip particles (`animateTick`): at `honey_level >= 5`, the attempt loop bound is `nextInt(1) + 1`, which is always 1: when the cell has no fluid and `nextFloat() >= 0.3`, and the collision shape's top reaches y = 1 and the state is not in block tag `impermeable`, honey particles are spawned (position rules RS24). The bee nest and the beehive differ only in the rows (hardness 0.3 and 0.6, colour yellow and wood).

### 14.4 Honey block (`HoneyBlock`, `HalfTransparentBlock`)

Builder: colour `COLOR_ORANGE`, **speed factor 0.4, jump factor 0.5**, `noOcclusion`, sound `HONEY_BLOCK`, hardness 0 (instant). Shape: the outline is the full cube; the **collision** shape is `column(14, 0, 15)` = (1, 0, 1, 15, 15, 15). Landing on it (`fallOn`): plays the slide sound, broadcasts entity event 54, and applies fall damage scaled by **0.2** (the damage multiplier argument); when damage was dealt it plays the block's fall sound at volume x 0.5 and pitch x 0.75. Sliding (`entityInside`): an entity slides down the side when it is not on the ground, its y is at most the cell's y + 0.9375 - 1e-7, its previous vertical speed is below -0.08, and it is more than 0.4375 + (entity width / 2) + 1e-7 away from the cell centre on x or z (the slide motion and the particle effects are entity physics, RS24 and the entity documents). Constants of the class (read): `SLIDE_STARTS_WHEN_VERTICAL_SPEED_IS_AT_LEAST` 0.13, `MIN_FALL_SPEED_TO_BE_CONSIDERED_SLIDING` 0.08, `THROTTLE_SLIDE_SPEED_TO` 0.05, `SLIDE_ADVANCEMENT_CHECK_INTERVAL` 20 ticks. `getOldDeltaY(d)` and `getNewDeltaY(d)` convert between the current and the previous vertical speed with the constants 0.98 (the float, as 0.9800000190734863) and 0.08. In `entityInside`, when the old delta y is below -0.13 the new delta y is set with the value -0.05 (the slide is throttled to -0.05 per tick). On the server, with probability 1 in 5 (`nextInt(5) == 0`), it broadcasts entity event 53 (slide particles); entity event 54 is the fall case. On the client the slide particles number 5 and the jump particles 10.

### 14.5 Crying obsidian, respawn anchor, flower pots

- `crying_obsidian` (`CryingObsidianBlock`): tool required, strength (50, 1200), light 10, push reaction `IMMOVEABLE`, instrument `BASEDRUM`; the class only adds client drip particles (not decoded; RS24).
- `respawn_anchor` (`RespawnAnchorBlock`): property `charges` (0 to 4), default 0; tool required, strength (50, 1200), push reaction `IMMOVEABLE`, instrument `BASEDRUM`. **Light** = `floor(charges / 4 x 15)` = 0, 3, 7, 11, 15. Comparator output = the same scaled value with maximum 15. Charge: right-click with `GLOWSTONE` when `charges < 4` raises `charges` by one (block change game event, charge sound, one item consumed); when the main hand holds fuel that cannot be used (already 4 charges) and the off-hand holds fuel that can, the main-hand use passes so that the off-hand may act; other cases fall through to the empty-hand use. Use without fuel: `charges == 0` passes; otherwise, when the dimension's environment attribute `RESPAWN_ANCHOR_WORKS` is true, a server player gets its respawn position set to the anchor (a respawn configuration for this dimension with angle 0, not forced) unless it is already that position, and the use succeeds; when the attribute is false the anchor **explodes**: it is removed, then an explosion with power 5.0, fire true, interaction BLOCK and the "bad respawn point" damage source is made at the cell centre; the explosion calculator (`RespawnAnchorBlock$1`, read) treats the cell as under water when one of the four horizontal neighbours holds water that would flow into the cell or the cell above holds a fluid in fluid tag `water`; its only override is the block explosion resistance: for the anchor's own position, and only when that under-water flag is set, the resistance is the resistance of the `water` block (100.0, read from its builder `strength(100.0)`), otherwise the default calculator is used. The `isWaterThatWouldFlow` test: the cell's fluid is in tag `water` and (it is a source, or its amount is at least 2 and the fluid in the cell below is not in tag `water`). The eight respawn search offsets (the four horizontal neighbours then four diagonal ones: (0,0,-1), (-1,0,0), (0,0,1), (1,0,0), (-1,0,-1), (1,0,-1), (-1,0,1), (1,0,1)) are `RESPAWN_HORIZONTAL_OFFSETS`; the respawn position search itself is RS16 (not read).
- `potted_crimson_fungus`, `potted_warped_fungus`, `potted_crimson_roots`, `potted_warped_roots` (`FlowerPotBlock(content)`): no state, builder `flowerPotProperties` (instabreak, `noOcclusion`, push reaction `POPPED`). Shape `column(6, 0, 6)` = (5, 0, 5, 11, 6, 11). Right-click with a block item whose block is registered as a plantable content (the map `POTTED_BY_CONTENT`) replaces the empty pot by the potted block (stat `POT_FLOWER`, one item consumed); right-click on a pot with an empty hand gives the content item to the player and restores the plain `FLOWER_POT`. `updateShape`: when the DOWN neighbour changes and the pot cannot survive it becomes air. (Tint: none, except that the potted fern is in the tint table of 24 part 1.)

## 15. Block set types used by the range

`BlockSetType(name, canOpenByHand, canOpenByWindCharge, canButtonBeActivatedByArrows, pressurePlateSensitivity, soundType, doorClose, doorOpen, trapdoorClose, trapdoorOpen, pressurePlateClickOff, pressurePlateClickOn, buttonClickOff, buttonClickOn)`. The four used here:

| Set type | by hand | wind charge | arrows press buttons | plate sensitivity | sound type | door close/open | trapdoor close/open | plate off/on | button off/on |
|---|---|---|---|---|---|---|---|---|---|
| `stone` | yes | yes | no | `MOBS` | `STONE` | `IRON_DOOR_CLOSE`/`IRON_DOOR_OPEN` | `IRON_TRAPDOOR_CLOSE`/`OPEN` | `STONE_PRESSURE_PLATE_CLICK_OFF`/`ON` | `STONE_BUTTON_CLICK_OFF`/`ON` |
| `polished_blackstone` | yes | yes | no | `MOBS` | `STONE` | as stone | as stone | as stone | as stone |
| `crimson` | yes | yes | yes | `EVERYTHING` | `NETHER_WOOD` | `NETHER_WOOD_DOOR_CLOSE`/`OPEN` | `NETHER_WOOD_TRAPDOOR_CLOSE`/`OPEN` | `NETHER_WOOD_PRESSURE_PLATE_CLICK_OFF`/`ON` | `NETHER_WOOD_BUTTON_CLICK_OFF`/`ON` |
| `warped` | yes | yes | yes | `EVERYTHING` | `NETHER_WOOD` | as crimson | as crimson | as crimson | as crimson |

(The three boolean columns are in the order of the record fields `canOpenByHand`, `canOpenByWindCharge`, `canButtonBeActivatedByArrows`; the constructor takes them in that order as read.) The polished blackstone pressure plate uses `polished_blackstone` and its button `stone` (20 ticks). Wood types: `WoodType.CRIMSON` and `WoodType.WARPED` each pair their block set type with block sound type `NETHER_WOOD`, hanging-sign sound type `NETHER_WOOD_HANGING_SIGN`, fence gate close event `NETHER_WOOD_FENCE_GATE_CLOSE` and open event `NETHER_WOOD_FENCE_GATE_OPEN` (read; the fence gate uses these two events when it opens and closes, section 9.2). Sound event keys map through the sound event table of 46.

### 15.1 Coverage statement for columns not tabulated per block

- Friction, speed and jump factors: the only override in this range is the honey block (speed 0.4, jump 0.5, section 14.4); every other block of the range has the defaults, so the flag column is complete for them.
- Tags: block tags are data files (RS5), but their membership for the 147 blocks of this range was evaluated in this round from the jar's tag files (`data/minecraft/tags/block/`, nested tag references expanded). Correct-tool membership:

| Tag | Members in this range |
|---|---|
| `mineable/pickaxe` (79) | all stairs, slabs and walls of stone-like blocks (granite, polished granite, diorite, polished diorite, andesite, polished andesite, mossy cobblestone, mossy stone brick, stone, stone brick (wall), end stone brick, smooth sandstone, smooth red sandstone, smooth quartz, red nether brick, brick, prismarine, red sandstone, mud brick, nether brick, sandstone, blackstone and polished blackstone families), `smoker`, `blast_furnace`, `grindstone`, `stonecutter`, `bell`, `lantern`, `soul_lantern` and all eight copper lanterns, both nylium, `netherite_block`, `ancient_debris`, `crying_obsidian`, `respawn_anchor`, `lodestone`, `blackstone`, `polished_blackstone`, `polished_blackstone_bricks`, `cracked_polished_blackstone_bricks`, `chiseled_polished_blackstone`, `gilded_blackstone`, `polished_blackstone_pressure_plate`, `polished_blackstone_button` |
| `mineable/axe` (41) | `loom`, `barrel`, `cartography_table`, `fletching_table`, `lectern`, `smithing_table`, `campfire`, `soul_campfire`, `composter`, `bee_nest`, `beehive`, the crimson and warped stems, stripped stems, hyphae, stripped hyphae, planks, slabs, pressure plates, fences, trapdoors, fence gates, stairs, buttons, doors, signs and wall signs |
| `mineable/hoe` (3) | `warped_wart_block`, `shroomlight`, `target` |
| `mineable/shovel` | none of the range |
| `needs_diamond_tool` (4) | `netherite_block`, `ancient_debris`, `crying_obsidian`, `respawn_anchor` |
| `needs_stone_tool`, `needs_iron_tool` | none of the range |

The `tool required` column of the rows is the builder flag (`requiresCorrectToolForDrops`) and is independent of these tags; a block in a `mineable/*` tag is mined faster by that tool class, and the `needs_*` tags choose the minimum tool tier (13 §2). Other family tags (membership read): `walls` = the 16 walls; `fences` and `wooden_fences` = the two nether fences; `slabs` = 18 slabs (16 stone-like and the two wooden); `stairs` = 19 (17 stone-like, plus the two wooden); `doors`, `trapdoors`, `fence_gates` = the two nether woods each; `buttons` = three (crimson, warped, polished blackstone); `pressure_plates` = three; `all_signs` = the four nether signs; `campfires` = the two campfires; `beehives` = bee nest and beehive; `climbable` = scaffolding and the four vine blocks; `wall_post_override` = the two nether pressure plates, the four nether signs and the polished blackstone pressure plate; `replaceable` = `void_air`, `cave_air`, `bubble_column`, the two roots and `nether_sprouts`; `air` = `void_air`, `cave_air`; `impermeable`, `enables_bubble_column_push_up`, `enables_bubble_column_drag_down` have no member in this range.
- Burnable and ignited by lava: `ignitedByLava` is a builder flag and appears in the rows' flag column where set (campfires among them); the fuel and flammability numbers (fire spread and burn odds) are the fire table of 24 part 1 and are not per-row builder values.
- Light opacity and occlusion: the generic rule of 24 part 1 section 5.2 applies per row. Overrides read in this round over all classes of the range and their superclasses: `getLightDampening` is **not overridden** by any of them. `propagatesSkylightDown` is overridden by `WallBlock` and `CrossCollisionBlock` (fences): true exactly when not waterlogged; and by `TransparentBlock` (always true; no block of this range extends it). `useShapeForLightOcclusion` is true for stairs, slabs that are not double, `StonecutterBlock` and `LecternBlock`. `getOcclusionShape` overrides: `FenceBlock` (and `FenceGateBlock`, section 9.2) and `LecternBlock` (the collision shape, section 10.2); `FenceBlock.getVisualShape` returns its outline shape. `HalfTransparentBlock.skipRendering` (the honey block's base): true when the neighbour state is the same block. The lantern, bell, campfire, scaffolding and the other partial blocks use only the generic rule.
- Burnable: not part of the block builder; it belongs to the fire table of 24 part 1.

## 16. Tint (GAP-29) and placement (GAP-30) summary

Tint: `bubble_column` uses `waterParticles()`; **no other block of the range has a tint source** (the registration list of `BlockColors.createDefault` was read in full for this range: its block references are `ACACIA_LEAVES`, `ATTACHED_MELON_STEM`, `ATTACHED_PUMPKIN_STEM`, `BIRCH_LEAVES`, `BUBBLE_COLUMN`, `BUSH`, `DARK_OAK_LEAVES`, `FERN`, `GRASS_BLOCK`, `JUNGLE_LEAVES`, `LARGE_FERN`, `LEAF_LITTER`, `LILY_PAD`, `MANGROVE_LEAVES`, `MELON_STEM`, `OAK_LEAVES`, `PINK_PETALS`, `POTTED_FERN`, `PUMPKIN_STEM`, `REDSTONE_WIRE`, `SHORT_GRASS`, `SPRUCE_LEAVES`, `SUGAR_CANE`, `TALL_GRASS`, `VINE`, `WATER`, `WATER_CAULDRON`, `WILDFLOWERS`; of these only `BUBBLE_COLUMN` lies in 630 to 769).

Replaceable flag (builder): `void_air`, `cave_air`, `bubble_column`, `warped_roots`, `crimson_roots`, `nether_sprouts`; the class-level replace rules are the slab rule (7.3) and scaffolding (item is scaffolding). Every other block uses the default (`canBeReplaced(context)` false).

Per class, the survival, placement and update rules (details in the sections named):

| Class | `canSurvive` | Placement state | Section |
|---|---|---|---|
| `AirBlock`, `Block`, `RotatedPillarBlock`, `CryingObsidianBlock`, `HoneyBlock`, lodestone | default true | default state (pillar: axis of clicked face) | 5, 12 |
| `BubbleColumnBlock` | below is a column or in the push-up or drag-down tag | not placed by items | 5.2 |
| `StairBlock` | default | facing, half, waterlogged, shape | 6 |
| `SlabBlock` | default | merge to double or top/bottom | 7 |
| `WallBlock` | default | connections from neighbours | 8 |
| `FenceBlock`, `FenceGateBlock` | default | connections; gate facing, in_wall, powered | 9 |
| `TrapDoorBlock`, `DoorBlock` | trapdoor default; door per 9.4 | per 9.3, 9.4 | 9 |
| `ButtonBlock`, `GrindstoneBlock` | attached (button), true (grindstone) | attach face rules | 9.5, 10, 11.1 |
| `PressurePlateBlock` | rigid support below or centre support | default | 9.6 |
| `StandingSignBlock`, `WallSignBlock` | below solid / behind solid | rotation or nearest wall | 9.7 |
| `LanternBlock` | support centre above or below | hanging from the look direction | 11.2 |
| `CampfireBlock` | default | lit, waterlogged, signal fire, facing | 11.3 |
| `ScaffoldingBlock` | distance below 7 | distance, bottom, waterlogged | 11.4 |
| `BellBlock` | per attachment | attachment by clicked face | 11.5 |
| `SweetBerryBushBlock` | default | default | 11.6 |
| `NetherFungusBlock`, `NetherRootsBlock`, `NetherSproutsBlock` | support tag below | default | 12 |
| `NyliumBlock` | default | default | 12.2 |
| vine heads and bodies | attach rule 12.5 step 4 | body or head with random age | 12.5 |
| `LoomBlock`, `StonecutterBlock`, furnaces, lectern, beehives | default | facing from the player | 10, 14.3 |
| `BarrelBlock` | default | facing from the look direction | 10 |
| `FlowerPotBlock` | default | default | 14.5 |


## 17. The rows: fields 630 to 769

Columns as in 24 part 1 section 7: id, key (all `minecraft:`), class (with constructor arguments other than `Properties`), properties in sorted-name order with value order, number of states, first state id, default state id, hardness, blast resistance, tool required, light, map colour, sound type, push reaction, instrument, builder flags (the flags that differ from the defaults, spelled as in the builder; `legacyCopy:<source>` marks `ofLegacyCopy`, `viewBlocking:nearPlaneIntersectsOutline` the predicate of section 2, `wallVariant:<sign>` the helper of section 2, `validSpawn:never` and `redstoneConductor:never` the constant-false predicates; `speedFactor` and `jumpFactor` are listed only when set). Values after `legacyCopy` are the values copied from the source; the numbers were evaluated from the builder chains (and, for the copies, from the source block's chain). The property order is the sorted order; the "properties" column shows the first and last value for numeric ranges. The loot table of every block is `blocks/<key>` except where the flags say `noLootTable` or `wallVariant`. The item of every block is the item of the same key, except `sweet_berry_bush` (item `sweet_berries`) and the eleven blocks without item (section 1.1). Rows 941 to 948 are the eight blocks of the single field `COPPER_LANTERN`; the other fields register one block each. Light column: a plain number is a constant function; `lit ? n : 0` is `litBlockEmission(n)`.

| id | key | class | properties | states | first state | default state | hardness | resistance | tool | light | map colour | sound | push | instrument | flags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 884 | void_air | AirBlock | - | 1 | 18649 | 18649 | 0.0 | 0.0 | no | 0 | NONE | STONE | PUSH_PULL | HARP | replaceable noCollision noLootTable air |
| 885 | cave_air | AirBlock | - | 1 | 18650 | 18650 | 0.0 | 0.0 | no | 0 | NONE | STONE | PUSH_PULL | HARP | replaceable noCollision noLootTable air |
| 886 | bubble_column | BubbleColumnBlock | drag[true/false] | 2 | 18651 | 18651 | 0.0 | 0.0 | no | 0 | WATER | EMPTY | POPPED | HARP | replaceable noCollision noLootTable liquid |
| 887 | polished_granite_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 18653 | 18664 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_granite viewBlocking:nearPlaneIntersectsOutline |
| 888 | smooth_red_sandstone_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 18733 | 18744 | 2.0 | 6.0 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:smooth_red_sandstone viewBlocking:nearPlaneIntersectsOutline |
| 889 | mossy_stone_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 18813 | 18824 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:mossy_stone_bricks viewBlocking:nearPlaneIntersectsOutline |
| 890 | polished_diorite_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 18893 | 18904 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_diorite viewBlocking:nearPlaneIntersectsOutline |
| 891 | mossy_cobblestone_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 18973 | 18984 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:mossy_cobblestone viewBlocking:nearPlaneIntersectsOutline |
| 892 | end_stone_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19053 | 19064 | 3.0 | 9.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy:end_stone_bricks viewBlocking:nearPlaneIntersectsOutline |
| 893 | stone_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19133 | 19144 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:stone viewBlocking:nearPlaneIntersectsOutline |
| 894 | smooth_sandstone_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19213 | 19224 | 2.0 | 6.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy:smooth_sandstone viewBlocking:nearPlaneIntersectsOutline |
| 895 | smooth_quartz_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19293 | 19304 | 2.0 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:smooth_quartz viewBlocking:nearPlaneIntersectsOutline |
| 896 | granite_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19373 | 19384 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | legacyCopy:granite viewBlocking:nearPlaneIntersectsOutline |
| 897 | andesite_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19453 | 19464 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:andesite viewBlocking:nearPlaneIntersectsOutline |
| 898 | red_nether_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19533 | 19544 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy:red_nether_bricks viewBlocking:nearPlaneIntersectsOutline |
| 899 | polished_andesite_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19613 | 19624 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_andesite viewBlocking:nearPlaneIntersectsOutline |
| 900 | diorite_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 19693 | 19704 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:diorite viewBlocking:nearPlaneIntersectsOutline |
| 901 | polished_granite_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19773 | 19776 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_granite viewBlocking:nearPlaneIntersectsOutline |
| 902 | smooth_red_sandstone_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19779 | 19782 | 2.0 | 6.0 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:smooth_red_sandstone viewBlocking:nearPlaneIntersectsOutline |
| 903 | mossy_stone_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19785 | 19788 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:mossy_stone_bricks viewBlocking:nearPlaneIntersectsOutline |
| 904 | polished_diorite_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19791 | 19794 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_diorite viewBlocking:nearPlaneIntersectsOutline |
| 905 | mossy_cobblestone_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19797 | 19800 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:mossy_cobblestone viewBlocking:nearPlaneIntersectsOutline |
| 906 | end_stone_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19803 | 19806 | 3.0 | 9.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy:end_stone_bricks viewBlocking:nearPlaneIntersectsOutline |
| 907 | smooth_sandstone_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19809 | 19812 | 2.0 | 6.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy:smooth_sandstone viewBlocking:nearPlaneIntersectsOutline |
| 908 | smooth_quartz_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19815 | 19818 | 2.0 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:smooth_quartz viewBlocking:nearPlaneIntersectsOutline |
| 909 | granite_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19821 | 19824 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | legacyCopy:granite viewBlocking:nearPlaneIntersectsOutline |
| 910 | andesite_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19827 | 19830 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:andesite viewBlocking:nearPlaneIntersectsOutline |
| 911 | red_nether_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19833 | 19836 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy:red_nether_bricks viewBlocking:nearPlaneIntersectsOutline |
| 912 | polished_andesite_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19839 | 19842 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_andesite viewBlocking:nearPlaneIntersectsOutline |
| 913 | diorite_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 19845 | 19848 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:diorite viewBlocking:nearPlaneIntersectsOutline |
| 914 | brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 19851 | 19854 | 2.0 | 6.0 | yes | 0 | COLOR_RED | STONE | PUSH_PULL | BASEDRUM | legacyCopy:bricks forceSolidOn |
| 915 | prismarine_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 20175 | 20178 | 1.5 | 6.0 | yes | 0 | COLOR_CYAN | STONE | PUSH_PULL | BASEDRUM | legacyCopy:prismarine forceSolidOn |
| 916 | red_sandstone_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 20499 | 20502 | 0.8 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:red_sandstone forceSolidOn |
| 917 | mossy_stone_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 20823 | 20826 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:mossy_stone_bricks forceSolidOn |
| 918 | granite_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 21147 | 21150 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | legacyCopy:granite forceSolidOn |
| 919 | stone_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 21471 | 21474 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:stone_bricks forceSolidOn |
| 920 | mud_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 21795 | 21798 | 1.5 | 3.0 | yes | 0 | TERRACOTTA_LIGHT_GRAY | MUD_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy:mud_bricks forceSolidOn |
| 921 | nether_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 22119 | 22122 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy:nether_bricks forceSolidOn |
| 922 | andesite_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 22443 | 22446 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy:andesite forceSolidOn |
| 923 | red_nether_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 22767 | 22770 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy:red_nether_bricks forceSolidOn |
| 924 | sandstone_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 23091 | 23094 | 0.8 | 0.8 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy:sandstone forceSolidOn |
| 925 | end_stone_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 23415 | 23418 | 3.0 | 9.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy:end_stone_bricks forceSolidOn |
| 926 | diorite_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 23739 | 23742 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy:diorite forceSolidOn |
| 927 | scaffolding | ScaffoldingBlock | bottom[true/false] distance[0..7] waterlogged[true/false] | 32 | 24063 | 24094 | 0.0 | 0.0 | no | 0 | SAND | SCAFFOLDING | POPPED | HARP | noCollision dynamicShape validSpawn:never redstoneConductor:never |
| 928 | loom | LoomBlock | facing[north/south/west/east] | 4 | 24095 | 24095 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 929 | barrel | BarrelBlock | facing[north/east/south/west/up/down] open[true/false] | 12 | 24099 | 24100 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 930 | smoker | SmokerBlock | facing[north/south/west/east] lit[true/false] | 8 | 24111 | 24112 | 3.5 | 3.5 | yes | lit ? 13 : 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 931 | blast_furnace | BlastFurnaceBlock | facing[north/south/west/east] lit[true/false] | 8 | 24119 | 24120 | 3.5 | 3.5 | yes | lit ? 13 : 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 932 | cartography_table | CartographyTableBlock | - | 1 | 24127 | 24127 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 933 | fletching_table | Block | - | 1 | 24128 | 24128 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 934 | grindstone | GrindstoneBlock | face[floor/wall/ceiling] facing[north/south/west/east] | 12 | 24129 | 24133 | 2.0 | 6.0 | yes | 0 | METAL | STONE | IMMOVEABLE | HARP | - |
| 935 | lectern | LecternBlock | facing[north/south/west/east] has_book[true/false] powered[true/false] | 16 | 24141 | 24144 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 936 | smithing_table | SmithingTableBlock | - | 1 | 24157 | 24157 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 937 | stonecutter | StonecutterBlock | facing[north/south/west/east] | 4 | 24158 | 24158 | 3.5 | 3.5 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 938 | bell | BellBlock | attachment[floor/ceiling/single_wall/double_wall] facing[north/south/west/east] powered[true/false] | 32 | 24162 | 24163 | 5.0 | 5.0 | no | 0 | GOLD | ANVIL | POPPED | HARP | forceSolidOn |
| 939 | lantern | LanternBlock | hanging[true/false] waterlogged[true/false] | 4 | 24194 | 24197 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 940 | soul_lantern | LanternBlock | hanging[true/false] waterlogged[true/false] | 4 | 24198 | 24201 | 3.5 | 3.5 | no | 10 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 941 | copper_lantern | WeatheringLanternBlock (UNAFFECTED) | hanging[true/false] waterlogged[true/false] | 4 | 24202 | 24205 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 942 | exposed_copper_lantern | WeatheringLanternBlock (EXPOSED) | hanging[true/false] waterlogged[true/false] | 4 | 24206 | 24209 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 943 | weathered_copper_lantern | WeatheringLanternBlock (WEATHERED) | hanging[true/false] waterlogged[true/false] | 4 | 24210 | 24213 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 944 | oxidized_copper_lantern | WeatheringLanternBlock (OXIDIZED) | hanging[true/false] waterlogged[true/false] | 4 | 24214 | 24217 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 945 | waxed_copper_lantern | LanternBlock | hanging[true/false] waterlogged[true/false] | 4 | 24218 | 24221 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 946 | waxed_exposed_copper_lantern | LanternBlock | hanging[true/false] waterlogged[true/false] | 4 | 24222 | 24225 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 947 | waxed_weathered_copper_lantern | LanternBlock | hanging[true/false] waterlogged[true/false] | 4 | 24226 | 24229 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 948 | waxed_oxidized_copper_lantern | LanternBlock | hanging[true/false] waterlogged[true/false] | 4 | 24230 | 24233 | 3.5 | 3.5 | no | 15 | METAL | LANTERN | POPPED | HARP | forceSolidOn noOcclusion |
| 949 | campfire | CampfireBlock (spawnParticles true, fireDamage 1) | facing[north/south/west/east] lit[true/false] signal_fire[true/false] waterlogged[true/false] | 32 | 24234 | 24237 | 2.0 | 2.0 | no | lit ? 15 : 0 | PODZOL | WOOD | PUSH_PULL | BASS | noOcclusion ignitedByLava |
| 950 | soul_campfire | CampfireBlock (spawnParticles false, fireDamage 2) | facing[north/south/west/east] lit[true/false] signal_fire[true/false] waterlogged[true/false] | 32 | 24266 | 24269 | 2.0 | 2.0 | no | lit ? 10 : 0 | PODZOL | WOOD | PUSH_PULL | BASS | noOcclusion ignitedByLava |
| 951 | sweet_berry_bush | SweetBerryBushBlock | age[0..3] | 4 | 24298 | 24298 | 0.0 | 0.0 | no | 0 | PLANT | SWEET_BERRY_BUSH | POPPED | HARP | randomTicks noCollision |
| 952 | warped_stem | RotatedPillarBlock | axis[x/y/z] | 3 | 24302 | 24303 | 2.0 | 2.0 | no | 0 | WARPED_STEM | STEM | PUSH_PULL | BASS | - |
| 953 | stripped_warped_stem | RotatedPillarBlock | axis[x/y/z] | 3 | 24305 | 24306 | 2.0 | 2.0 | no | 0 | WARPED_STEM | STEM | PUSH_PULL | BASS | - |
| 954 | warped_hyphae | RotatedPillarBlock | axis[x/y/z] | 3 | 24308 | 24309 | 2.0 | 2.0 | no | 0 | WARPED_HYPHAE | STEM | PUSH_PULL | BASS | - |
| 955 | stripped_warped_hyphae | RotatedPillarBlock | axis[x/y/z] | 3 | 24311 | 24312 | 2.0 | 2.0 | no | 0 | WARPED_HYPHAE | STEM | PUSH_PULL | BASS | - |
| 956 | warped_nylium | NyliumBlock | - | 1 | 24314 | 24314 | 0.4 | 0.4 | yes | 0 | WARPED_NYLIUM | NYLIUM | PUSH_PULL | BASEDRUM | randomTicks |
| 957 | warped_fungus | NetherFungusBlock (TreeFeatures.WARPED_FUNGUS_PLANTED WARPED_NYLIUM tag SUPPORTS_WARPED_FUNGUS) | - | 1 | 24315 | 24315 | 0.0 | 0.0 | no | 0 | COLOR_CYAN | FUNGUS | POPPED | HARP | noCollision |
| 958 | warped_wart_block | Block | - | 1 | 24316 | 24316 | 1.0 | 1.0 | no | 0 | WARPED_WART_BLOCK | WART_BLOCK | PUSH_PULL | HARP | - |
| 959 | warped_roots | NetherRootsBlock (tag SUPPORTS_WARPED_ROOTS) | - | 1 | 24317 | 24317 | 0.0 | 0.0 | no | 0 | COLOR_CYAN | ROOTS | POPPED | HARP | replaceable noCollision offset:XZ |
| 960 | nether_sprouts | NetherSproutsBlock | - | 1 | 24318 | 24318 | 0.0 | 0.0 | no | 0 | COLOR_CYAN | NETHER_SPROUTS | POPPED | HARP | replaceable noCollision offset:XZ |
| 961 | crimson_stem | RotatedPillarBlock | axis[x/y/z] | 3 | 24319 | 24320 | 2.0 | 2.0 | no | 0 | CRIMSON_STEM | STEM | PUSH_PULL | BASS | - |
| 962 | stripped_crimson_stem | RotatedPillarBlock | axis[x/y/z] | 3 | 24322 | 24323 | 2.0 | 2.0 | no | 0 | CRIMSON_STEM | STEM | PUSH_PULL | BASS | - |
| 963 | crimson_hyphae | RotatedPillarBlock | axis[x/y/z] | 3 | 24325 | 24326 | 2.0 | 2.0 | no | 0 | CRIMSON_HYPHAE | STEM | PUSH_PULL | BASS | - |
| 964 | stripped_crimson_hyphae | RotatedPillarBlock | axis[x/y/z] | 3 | 24328 | 24329 | 2.0 | 2.0 | no | 0 | CRIMSON_HYPHAE | STEM | PUSH_PULL | BASS | - |
| 965 | crimson_nylium | NyliumBlock | - | 1 | 24331 | 24331 | 0.4 | 0.4 | yes | 0 | CRIMSON_NYLIUM | NYLIUM | PUSH_PULL | BASEDRUM | randomTicks |
| 966 | crimson_fungus | NetherFungusBlock (TreeFeatures.CRIMSON_FUNGUS_PLANTED CRIMSON_NYLIUM tag SUPPORTS_CRIMSON_FUNGUS) | - | 1 | 24332 | 24332 | 0.0 | 0.0 | no | 0 | NETHER | FUNGUS | POPPED | HARP | noCollision |
| 967 | shroomlight | Block | - | 1 | 24333 | 24333 | 1.0 | 1.0 | no | 15 | COLOR_RED | SHROOMLIGHT | PUSH_PULL | HARP | - |
| 968 | weeping_vines | WeepingVinesBlock | age[0..25] | 26 | 24334 | 24334 | 0.0 | 0.0 | no | 0 | NETHER | WEEPING_VINES | POPPED | HARP | randomTicks noCollision |
| 969 | weeping_vines_plant | WeepingVinesPlantBlock | - | 1 | 24360 | 24360 | 0.0 | 0.0 | no | 0 | NETHER | WEEPING_VINES | POPPED | HARP | noCollision |
| 970 | twisting_vines | TwistingVinesBlock | age[0..25] | 26 | 24361 | 24361 | 0.0 | 0.0 | no | 0 | COLOR_CYAN | WEEPING_VINES | POPPED | HARP | randomTicks noCollision |
| 971 | twisting_vines_plant | TwistingVinesPlantBlock | - | 1 | 24387 | 24387 | 0.0 | 0.0 | no | 0 | COLOR_CYAN | WEEPING_VINES | POPPED | HARP | noCollision |
| 972 | crimson_roots | NetherRootsBlock (tag SUPPORTS_CRIMSON_ROOTS) | - | 1 | 24388 | 24388 | 0.0 | 0.0 | no | 0 | NETHER | ROOTS | POPPED | HARP | replaceable noCollision offset:XZ |
| 973 | crimson_planks | Block | - | 1 | 24389 | 24389 | 2.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | - |
| 974 | warped_planks | Block | - | 1 | 24390 | 24390 | 2.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | - |
| 975 | crimson_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 24391 | 24394 | 2.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | legacyCopy:crimson_planks viewBlocking:nearPlaneIntersectsOutline |
| 976 | warped_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 24397 | 24400 | 2.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | legacyCopy:warped_planks viewBlocking:nearPlaneIntersectsOutline |
| 977 | crimson_pressure_plate | PressurePlateBlock (BlockSetType.CRIMSON) | powered[true/false] | 2 | 24403 | 24404 | 0.5 | 0.5 | no | 0 | CRIMSON_STEM | NETHER_WOOD | POPPED | BASS | forceSolidOn noCollision |
| 978 | warped_pressure_plate | PressurePlateBlock (BlockSetType.WARPED) | powered[true/false] | 2 | 24405 | 24406 | 0.5 | 0.5 | no | 0 | WARPED_STEM | NETHER_WOOD | POPPED | BASS | forceSolidOn noCollision |
| 979 | crimson_fence | FenceBlock | east[true/false] north[true/false] south[true/false] waterlogged[true/false] west[true/false] | 32 | 24407 | 24438 | 2.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | - |
| 980 | warped_fence | FenceBlock | east[true/false] north[true/false] south[true/false] waterlogged[true/false] west[true/false] | 32 | 24439 | 24470 | 2.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | - |
| 981 | crimson_trapdoor | TrapDoorBlock (BlockSetType.CRIMSON) | facing[north/south/west/east] half[top/bottom] open[true/false] powered[true/false] waterlogged[true/false] | 64 | 24471 | 24486 | 3.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | noOcclusion validSpawn:never |
| 982 | warped_trapdoor | TrapDoorBlock (BlockSetType.WARPED) | facing[north/south/west/east] half[top/bottom] open[true/false] powered[true/false] waterlogged[true/false] | 64 | 24535 | 24550 | 3.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | noOcclusion validSpawn:never |
| 983 | crimson_fence_gate | FenceGateBlock (WoodType.CRIMSON) | facing[north/south/west/east] in_wall[true/false] open[true/false] powered[true/false] | 32 | 24599 | 24606 | 2.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | forceSolidOn |
| 984 | warped_fence_gate | FenceGateBlock (WoodType.WARPED) | facing[north/south/west/east] in_wall[true/false] open[true/false] powered[true/false] | 32 | 24631 | 24638 | 2.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | forceSolidOn |
| 985 | crimson_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 24663 | 24674 | 2.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | legacyCopy:crimson_planks viewBlocking:nearPlaneIntersectsOutline |
| 986 | warped_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 24743 | 24754 | 2.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | legacyCopy:warped_planks viewBlocking:nearPlaneIntersectsOutline |
| 987 | crimson_button | ButtonBlock (BlockSetType.CRIMSON 30) | face[floor/wall/ceiling] facing[north/south/west/east] powered[true/false] | 24 | 24823 | 24832 | 0.5 | 0.5 | no | 0 | NONE | NETHER_WOOD | POPPED | HARP | noCollision |
| 988 | warped_button | ButtonBlock (BlockSetType.WARPED 30) | face[floor/wall/ceiling] facing[north/south/west/east] powered[true/false] | 24 | 24847 | 24856 | 0.5 | 0.5 | no | 0 | NONE | NETHER_WOOD | POPPED | HARP | noCollision |
| 989 | crimson_door | DoorBlock (BlockSetType.CRIMSON) | facing[north/south/west/east] half[upper/lower] hinge[left/right] open[true/false] powered[true/false] | 64 | 24871 | 24882 | 3.0 | 3.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | POPPED | BASS | noOcclusion |
| 990 | warped_door | DoorBlock (BlockSetType.WARPED) | facing[north/south/west/east] half[upper/lower] hinge[left/right] open[true/false] powered[true/false] | 64 | 24935 | 24946 | 3.0 | 3.0 | no | 0 | WARPED_STEM | NETHER_WOOD | POPPED | BASS | noOcclusion |
| 991 | crimson_sign | StandingSignBlock (WoodType.CRIMSON) | rotation[0..15] waterlogged[true/false] | 32 | 24999 | 25016 | 1.0 | 1.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | forceSolidOn noCollision |
| 992 | warped_sign | StandingSignBlock (WoodType.WARPED) | rotation[0..15] waterlogged[true/false] | 32 | 25031 | 25048 | 1.0 | 1.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | forceSolidOn noCollision |
| 993 | crimson_wall_sign | WallSignBlock (WoodType.CRIMSON) | facing[north/south/west/east] waterlogged[true/false] | 8 | 25063 | 25064 | 1.0 | 1.0 | no | 0 | CRIMSON_STEM | NETHER_WOOD | PUSH_PULL | BASS | wallVariant:crimson_sign+description forceSolidOn noCollision |
| 994 | warped_wall_sign | WallSignBlock (WoodType.WARPED) | facing[north/south/west/east] waterlogged[true/false] | 8 | 25071 | 25072 | 1.0 | 1.0 | no | 0 | WARPED_STEM | NETHER_WOOD | PUSH_PULL | BASS | wallVariant:warped_sign+description forceSolidOn noCollision |
| 995 | structure_block | StructureBlock | mode[save/load/corner/data] | 4 | 25079 | 25080 | -1.0 | 3600000.0 | yes | 0 | COLOR_LIGHT_GRAY | STONE | PUSH_PULL | HARP | noLootTable |
| 996 | jigsaw | JigsawBlock | orientation[down_east/down_north/down_south/down_west/up_east/up_north/up_south/up_west/west_up/east_up/north_up/south_up] | 12 | 25083 | 25093 | -1.0 | 3600000.0 | yes | 0 | COLOR_LIGHT_GRAY | STONE | PUSH_PULL | HARP | noLootTable |
| 997 | test_block | TestBlock | mode[start/log/fail/accept] | 4 | 25095 | 25095 | -1.0 | 3600000.0 | no | 0 | COLOR_LIGHT_GRAY | STONE | PUSH_PULL | HARP | noLootTable |
| 998 | test_instance_block | TestInstanceBlock | - | 1 | 25099 | 25099 | -1.0 | 3600000.0 | no | 0 | NONE | STONE | PUSH_PULL | HARP | noOcclusion noLootTable |
| 999 | composter | ComposterBlock | level[0..8] | 9 | 25100 | 25100 | 0.6 | 0.6 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 1000 | target | TargetBlock | power[0..15] | 16 | 25109 | 25109 | 0.5 | 0.5 | no | 0 | QUARTZ | GRASS | PUSH_PULL | HARP | - |
| 1001 | bee_nest | BeehiveBlock | facing[north/south/west/east] honey_level[0..5] | 24 | 25125 | 25125 | 0.3 | 0.3 | no | 0 | COLOR_YELLOW | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 1002 | beehive | BeehiveBlock | facing[north/south/west/east] honey_level[0..5] | 24 | 25149 | 25149 | 0.6 | 0.6 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 1003 | honey_block | HoneyBlock | - | 1 | 25173 | 25173 | 0.0 | 0.0 | no | 0 | COLOR_ORANGE | HONEY_BLOCK | PUSH_PULL | HARP | noOcclusion speedFactor:0.4 jumpFactor:0.5 |
| 1004 | honeycomb_block | Block | - | 1 | 25174 | 25174 | 0.6 | 0.6 | no | 0 | COLOR_ORANGE | CORAL_BLOCK | PUSH_PULL | HARP | - |
| 1005 | netherite_block | Block | - | 1 | 25175 | 25175 | 50.0 | 1200.0 | yes | 0 | COLOR_BLACK | NETHERITE_BLOCK | PUSH_PULL | HARP | - |
| 1006 | ancient_debris | Block | - | 1 | 25176 | 25176 | 30.0 | 1200.0 | yes | 0 | COLOR_BLACK | ANCIENT_DEBRIS | PUSH_PULL | HARP | - |
| 1007 | crying_obsidian | CryingObsidianBlock | - | 1 | 25177 | 25177 | 50.0 | 1200.0 | yes | 10 | COLOR_BLACK | STONE | IMMOVEABLE | BASEDRUM | - |
| 1008 | respawn_anchor | RespawnAnchorBlock | charges[0..4] | 5 | 25178 | 25178 | 50.0 | 1200.0 | yes | 0/3/7/11/15 by charges | COLOR_BLACK | STONE | IMMOVEABLE | BASEDRUM | - |
| 1009 | potted_crimson_fungus | FlowerPotBlock (CRIMSON_FUNGUS) | - | 1 | 25183 | 25183 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion |
| 1010 | potted_warped_fungus | FlowerPotBlock (WARPED_FUNGUS) | - | 1 | 25184 | 25184 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion |
| 1011 | potted_crimson_roots | FlowerPotBlock (CRIMSON_ROOTS) | - | 1 | 25185 | 25185 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion |
| 1012 | potted_warped_roots | FlowerPotBlock (WARPED_ROOTS) | - | 1 | 25186 | 25186 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion |
| 1013 | lodestone | Block | - | 1 | 25187 | 25187 | 3.5 | 3.5 | yes | 0 | METAL | LODESTONE | IMMOVEABLE | HARP | - |
| 1014 | blackstone | Block | - | 1 | 25188 | 25188 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | - |
| 1015 | blackstone_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 25189 | 25200 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:blackstone viewBlocking:nearPlaneIntersectsOutline |
| 1016 | blackstone_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 25269 | 25272 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:blackstone forceSolidOn |
| 1017 | blackstone_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 25593 | 25596 | 2.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:blackstone destroyTime:2.0 viewBlocking:nearPlaneIntersectsOutline |
| 1018 | polished_blackstone | Block | - | 1 | 25599 | 25599 | 2.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:blackstone |
| 1019 | polished_blackstone_bricks | Block | - | 1 | 25600 | 25600 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone |
| 1020 | cracked_polished_blackstone_bricks | Block | - | 1 | 25601 | 25601 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone_bricks |
| 1021 | chiseled_polished_blackstone | Block | - | 1 | 25602 | 25602 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone |
| 1022 | polished_blackstone_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 25603 | 25606 | 2.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone_bricks destroyTime:2.0 viewBlocking:nearPlaneIntersectsOutline |
| 1023 | polished_blackstone_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 25609 | 25620 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone_bricks viewBlocking:nearPlaneIntersectsOutline |
| 1024 | polished_blackstone_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 25689 | 25692 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone_bricks forceSolidOn |
| 1025 | gilded_blackstone | Block | - | 1 | 26013 | 26013 | 1.5 | 6.0 | yes | 0 | COLOR_BLACK | GILDED_BLACKSTONE | PUSH_PULL | BASEDRUM | legacyCopy:blackstone |
| 1026 | polished_blackstone_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[true/false] | 80 | 26014 | 26025 | 2.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone viewBlocking:nearPlaneIntersectsOutline |
| 1027 | polished_blackstone_slab | SlabBlock | type[top/bottom/double] waterlogged[true/false] | 6 | 26094 | 26097 | 2.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone viewBlocking:nearPlaneIntersectsOutline |
| 1028 | polished_blackstone_pressure_plate | PressurePlateBlock (BlockSetType.POLISHED_BLACKSTONE) | powered[true/false] | 2 | 26100 | 26101 | 0.5 | 0.5 | no | 0 | COLOR_BLACK | STONE | POPPED | BASEDRUM | forceSolidOn noCollision |
| 1029 | polished_blackstone_button | ButtonBlock (BlockSetType.STONE 20) | face[floor/wall/ceiling] facing[north/south/west/east] powered[true/false] | 24 | 26102 | 26111 | 0.5 | 0.5 | no | 0 | NONE | STONE | POPPED | HARP | noCollision |
| 1030 | polished_blackstone_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[true/false] waterlogged[true/false] west[none/low/tall] | 324 | 26126 | 26129 | 2.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | legacyCopy:polished_blackstone forceSolidOn |

## 18. Worked examples

1. **Stair state id.** `polished_granite_stairs` (id 887): 80 states from 18653. Sorted properties: `facing` (north 0, south 1, west 2, east 3), `half` (top 0, bottom 1), `shape` (straight 0, inner_left 1, inner_right 2, outer_left 3, outer_right 4), `waterlogged` (true 0, false 1). Index = ((facing x 2 + half) x 5 + shape) x 2 + waterlogged. The default (north, bottom, straight, false): ((0 x 2 + 1) x 5 + 0) x 2 + 1 = 11, id 18664 (the row). The state `facing=east, half=top, shape=inner_left, waterlogged=true`: ((3 x 2 + 0) x 5 + 1) x 2 + 0 = 62, id 18715.
2. **Slab ids.** `polished_granite_slab` (id 901): 6 states from 19773; index = type x 2 + waterlogged with type top 0, bottom 1, double 2. Default (bottom, false) = 3, id 19776; `type=double, waterlogged=true` = 4, id 19777. The next block starts at 19779.
3. **Wall state id.** `polished_blackstone_wall` (id 1030) first state 26126, sorted `east`, `north`, `south`, `up`, `waterlogged`, `west`: index = ((((east x 3 + north) x 3 + south) x 2 + up) x 2 + waterlogged) x 3 + west, with none 0, low 1, tall 2, true 0, false 1. Default: ((((0 x 3 + 0) x 3 + 0) x 2 + 0) x 2 + 1) x 3 + 0 = 3, id 26129. The state `east=tall, north=low, south=none, up=true, waterlogged=false, west=none`: (((2 x 3 + 1) x 3 + 0) x 2 + 0) = 42, then x 2 + 1 = 85, then x 3 + 0 = 255, id 26381. The last state of the block is 26449; the next block starts at 26450.
4. **Stair corner.** A stair A at P facing north (bottom half) with a stair B at P + north (the cell A faces) facing west, same half, no other stairs around: the facing axes differ (north on Z, west on X); `canTakeShape(A, P, opposite of B's facing = east)` reads the block at P + east, which is air, so true; B's facing (west) is A's facing turned counter-clockwise, so A becomes `shape=outer_left`. Its shape is `TABLE[bottom][OUTER][key = north]`: the slab (0, 0, 0, 16, 8, 16) plus the top corner (0, 8, 0, 8, 16, 8). If instead B (facing west) stood at P + south (behind A) the result would be `inner_left` with key = north turned counter-clockwise = west: the slab plus the top west half (0, 8, 0, 8, 16, 16) and the top north half (0, 8, 0, 16, 16, 8).
5. **Wall post and tall sides.** A wall with `north=low` and `south=low` (east and west none) and nothing above (the above cell's DOWN face shape is empty): not all sides are none, north and south are equally none (both connected), west and east equally none, so step 2 of `shouldRaisePost` does not force a post; no tall pair; the empty face does not cover the 2-pixel post test shape, so `up=false`: a bare straight wall. With a full block above: the full face covers the arm test shapes, so both arms become `tall` (a tall arm is 16 pixels high instead of 14), and the tall pair rule says no post, so `up=false` again. With a wall above that has `up=true`: step 1 makes `up=true`.
6. **Wall connection.** The wall's east neighbour is `stone` (sturdy face towards the wall, not an exception block): rule 2 gives a connection; with a `pumpkin` east the exception list blocks rule 2 and the side stays `none` (unless a fence gate or bars). A fence gate to the east whose facing is north or south (axis Z, clockwise-turned axis X equals the east direction's axis) connects.
7. **Button shape.** `crimson_button` facing north on the wall (support at the south): released (5, 6, 14, 11, 10, 16), powered (5, 6, 15, 11, 10, 16); on the floor facing north released (5, 0, 6, 11, 2, 10); on the ceiling (5, 14, 6, 11, 16, 10). It stays pressed 30 ticks (crimson), 20 for `polished_blackstone_button`.
8. **Target strength.** A projectile hits the UP face at the fractional position (0.5, y, 0.9): the distances from the centre are 0.0 (x) and 0.4 (z); the larger is 0.4; strength = max(1, ceil(15 x clamp((0.5 - 0.4) / 0.5, 0, 1))) = ceil(15 x 0.2) = 3 (floating-point evaluation: 0.5 - 0.4 is 0.09999999999999998, divided by 0.5 it is 0.19999999999999996, so the product is 2.999999999999999 and the ceiling is 3). Dead centre gives 15; a hit at distance 0.5 or more gives 1. An arrow holds the output for 20 ticks, other projectiles for 8.
9. **Sign rotation.** A player with yaw 0 degrees placing a standing sign: `round((0 + 180) x 16 / 360)` = 8, `& 15` = 8 (the default). Yaw 90: `round(270 x 16 / 360)` = 12. Yaw -180: `round(0)` = 0.
10. **Respawn anchor light.** charges 0, 1, 2, 3, 4 give floor(c / 4 x 15) = 0, 3, 7, 11, 15; the comparator signal is the same list.
11. **Composter.** Level 0: collision `SHAPES[0]` = block minus `column(12, 2, 16)`: a bin with a 2-pixel floor. Level 3: outline floor top at clamp(2 x 3 + 1, 2, 16) = 7 pixels. Level 8 uses `SHAPES[7]` (floor top 15). An item with `layers = 1` at level 6 makes level 7 and schedules a tick after 20; the tick makes level 8; right-click drops one bone meal and resets to 0.
12. **Nether vine bone meal.** The count `n` has P(n >= 1) = 1 (the first draw is below 1.0) and P(n >= k + 1) = 0.826^k for k >= 1; a bone meal use places up to `n` new head blocks downward (weeping) or upward (twisting), each with `age` one larger than the previous (capped at 25).
13. **Scaffolding distance.** A scaffolding standing on solid ground (its UP-sturdy block below): distance 0, `bottom=false` (`isBottom` needs distance > 0 and a non-scaffolding block below). A scaffolding placed on a scaffolding of distance 0 and one cell to the side: distance 1 (min over horizontal scaffolding neighbours of their distance + 1, early exit at 1), `bottom=true` when the block below is not scaffolding. At distance 7 `canSurvive` fails.
14. **Copper lantern ids.** `waxed_oxidized_copper_lantern` is the eighth block of the field: id 941 + 7 = 948, states 24230 to 24233 (4 states each from 24202); `waxed_copper_lantern` is the fifth: id 945. Hanging standing lantern states: sorted `hanging`, `waterlogged`; default (false, false) = index 3.
15. **Trapdoor shape.** A bottom-half closed trapdoor: key UP, the panel (0, 0, 0, 16, 3, 16) (against the face opposite UP); a top-half closed one: key DOWN, (0, 13, 0, 16, 16, 16); open, facing north: key NORTH, the panel (0, 0, 13, 16, 16, 16) against the south face. Doors with `facing=north`, closed: the panel (0, 0, 13, 16, 16, 16); open with `hinge=left`: key = facing turned clockwise = east, the panel (0, 0, 0, 3, 16, 16); open with `hinge=right`: key west, the panel (13, 0, 0, 16, 16, 16).

## 19. Validation

1. **Counts.** 140 fields register 147 blocks; the id range 884 to 1030 is contiguous; the sum of the states column is 7801; 18649 + 7801 = 26450, the first state id of `CHISELED_NETHER_BRICKS` (part 8). Each row's first state equals the previous row's first state plus its state count (the table was generated that way and the sum was checked).
2. **Property rule.** For every row the number of states equals the product of the property value counts of its class (checked for all 47 classes in the range: stairs 80, slabs 6, walls 324, fences 32, trapdoors 64, fence gates 32, doors 64, buttons 24, standing signs 32, wall signs 8, scaffolding 32, bell 32, campfires 32, lanterns 4, lectern 16, grindstone 12, barrel 12, furnaces 8, loom and stonecutter 4, beehives 24, composter 9, target 16, respawn anchor 5, vines heads 26, jigsaw 12, structure block 4, test block 4, sweet berry bush 4, bubble column 2, stems and hyphae 3) and the default id lies inside the block's range.
3. **Id arithmetic.** The id of `VOID_AIR` (884) was computed independently from the field order: 630 earlier fields, 16 colour collections of 16 blocks (15 extra each), 2 weathering collections of 8 blocks (7 extra each): 630 + 240 + 14 = 884. The end of the range, field 769 = id 1030 = 769 + 254 + 7.
4. **State counts of earlier blocks.** The first state id 18649 depends on the state counts of all 630 + expanded earlier blocks. Their classes were resolved from the factory lambdas and `createBlockStateDefinition` (with superclass properties), the same method that gives part 1's 575 states for fields 0 to 104 (this computation gives 575 for the first state of field 105, the figure of 24 part 1 section 15). Six classes had to be read by hand because their property lists are built by loops or helper lists (`ChiseledBookShelfBlock` 4 x 2^6 = 256, `MultifaceBlock` family 2^6 x 2 = 128 for glow lichen, resin clump and sculk vein, `CaveVinesBlock` 26 x 2 = 52, `CaveVinesPlantBlock` 2). A reference client's block state registry dump (`blocks.json` of the data generator) can check this part: such a dump should list the first state id of `minecraft:void_air` as 18649 and of `minecraft:polished_blackstone_wall` as 26126.
5. **Cross-checks with other documents.** The break times follow 13 §2 and 17 App A: for example `stonecutter` (hardness 3.5, tool required) with an iron pickaxe is 6 / 3.5 / 30 per tick, about 0.057, 18 ticks. The unbreakable game-master blocks use hardness -1 (13 §2.6). The state id formula is 04 §5.2 (examples 1 to 3 above).
6. **Reading checks done in this round.** The stair shape table was verified for self-consistency with the property names: the corner names, the `getStairsShape` neighbour test and the shape selection give the same left and right sense (section 6.2, last paragraph); the trapdoor key-to-panel mapping agrees with the closed bottom and top shapes (UP key is a bottom panel); the pathfinding switches of door, trapdoor and gate were matched to the `PathComputationType` constants read from the switch-map classes; the `BlockSetType` rows were read from the static initialiser; the copper lantern collection was checked with the 7-extra arithmetic and against part 8, which states the same boundary (field 769 is id 1030, first state 26126, last state 26449, and field 770 starts at state 26450), and against part 6, whose last block `potted_bamboo` is id 883 so that `void_air` is 884.

Not validated: any behaviour listed as owned by another document (fluids RS10, growth RS11, redstone RS12, block entities RS13, particles RS24, entity physics); the per-state light dampening of each class (only the generic rule of 24 part 1 section 5.2 applies; `useShapeForLightOcclusion` is true for stairs, non-double slabs and the stonecutter); the client-side particle and sound details, the door and trapdoor explosion (wind charge) path of doors, and the final return branch of the sign empty-hand use.

## 20. Open questions

1. **(closed)** The rotation conventions were decoded from the `OctahedralGroup` and `SymmetricGroup3` data (section 4); the grindstone floor and ceiling boxes (10.1) follow from them.
2. **Bubble column argument order.** In `getColumnState(block, a, b)` and `updateColumn`, which of the two states is "the state below" was inferred from the use sites (section 5.2).
3. **(closed)** The door hinge side pairing was read (section 9.4).
4. **(closed)** The fence connection rule was read exactly (section 9.1).
5. **(closed)** The body update rule and the head-to-body conversion were read (section 12.5 step 5).
6. **(closed)** `BlockBehaviour.isPathfindable` and the slab override were read (section 7.4).
7. **(closed)** `WallBlock.rotate` and `mirror` were read (section 8.5).
8. **(closed)** The door neighbour pairing was read (section 9.4).
9. **Scaffolding tick.** The pairing of the old and new state in the distance-7 branch (falling block versus destroy) was read from local variable order and is inferred.
10. **(closed)** The sweet berry bush damage path was read (section 11.6).
11. **Client details.** The particle and sound logic of the crying obsidian, the composter, the furnaces' flames and the bubble column was summarised, not tabulated (RS24).
12. **Door, trapdoor, gate and sign use.** Read in this round (sections 9.2, 9.3, 9.4, 9.7): the toggle, sounds, game events and the sign item and empty-hand paths. Still not read: the `BlockSetType` wind-charge path of doors (`DoorBlock.onExplosionHit`), the sign block entity's editing messages (RS13) and the return value of the last branch of the sign's empty-hand use (assumed PASS, inferred).
13. **(closed except data)** The beehive shear and bottle paths, `playerDestroy`, `playerWillDestroy` and bee anger were read (section 14.3). Not read: the `harvest_beehive` loot table contents (data), `BeehiveBlockEntity.emptyAllLivingFromHive` and the bee behaviour (RS13 and the bee rules).
14. **(closed)** Lectern `tryPlaceBook`, `openScreen` and the 2-tick pulse were read (section 10.2).
15. **Respawn.** The `RespawnAnchorBlock$1` calculator was read (section 14.5). The respawn position search itself (offsets listed) is RS16 and was not read.
16. **Composter data.** The `COMPOSTABLE` component (chance and layers fields) and the per-item values are data on the items (RS5); the layers int provider's resolution context was listed, not its provider types.
17. **Weathering rules.** The random tick chance and the neighbour influence of `WeatheringCopper.changeOverTime` for the copper lanterns belong to the copper rows (part 8).
18. **Game-master permission.** `Player.canUseGameMasterBlocks` and the `GameMasterBlock` marker's effect on placement and the operator-only screens.
19. **(closed)** Sound columns were read: the constructors set the sound from the `BlockSetType` or `WoodType` (sections 9.7 and 15); crimson and warped doors, trapdoors, gates, buttons, plates and signs are `NETHER_WOOD`, the polished blackstone plate and button `STONE`.
20. **(closed)** Light dampening and skylight propagation overrides were searched over every class of the range and its superclasses (section 15.1): only the wall and fence waterlogged rule and the shape-for-occlusion flags exist.
21. **Tags.** Tag contents are data; their membership for the range was evaluated (section 15.1). Tag names read by the classes of this range: block tags `enables_bubble_column_push_up`, `enables_bubble_column_drag_down`, `walls`, `fences`, `wooden_fences`, `wall_post_override`, `supports_warped_fungus`, `supports_crimson_fungus`, `supports_warped_roots`, `supports_crimson_roots`, `supports_nether_sprouts`, `supports_vegetation`, `campfires`, and `impermeable` (`BeehiveBlock` drip particles: a hive whose state is in it spawns none); item tags `lectern_books` (lectern accepts the book) and `douses_campfires` (item use extinguishes a lit campfire, section 11.3); enchantment tag `prevents_bee_spawns_when_mining` (a tool with such an enchantment does not release the bees when a hive is mined, section 14.3); fluid tags `bubble_column_can_occupy` and `water` (slab pathfinding in water, section 7.4; the default block pathfinding rule; the respawn anchor's water tests and explosion resistance, section 14.5); and `shulker_boxes` (wall connection exceptions). Whether `supports_vegetation` applies to the nether plants through the base class was read for `VegetationBlock` only.
22. **No recalled content.** No value in this document was taken from memory of other versions or the wiki; where the artifact differed from what a reader may expect (for example the 4-pixel fence arms and the 14-pixel weeping vine body) the artifact value was written.
