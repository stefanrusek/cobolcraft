# Block shapes: collision and outline rules of the standard world type (consolidated)

| Item | Value |
|---|---|
| Covers | The per-block-state collision shape and outline (targeting) shape of every block class of the standard world type, written as rules by family and property so that an implementer can build a lookup table; the player-collision expectations that follow from them |
| Sources | Documents consolidated, no artifact read in this round: `24-block-registry-1` (section 4.4 offsets, section 5.2 derived values, section 6 shape model, section 14 classes), `24-block-registry-2` (sections 2.6, 2.7, 6, 7.8, 7.11, 8), `24-block-registry-3` (section 5, 7), `24-block-registry-4` (sections 2.4, 5.2, 6), `24-block-registry-5` (sections 6, 7), `24-block-registry-6` (sections 4, 6), `24-block-registry-7` (sections 4 to 14), `24-block-registry-8` (sections 4, 5), `29a-fluids` (section 1.2 and 1.3), `29b-falling-growth-fire-2/3/4/7` (shape lines), `30-redstone-1/3/4/5/6` (shape lines), `31-block-entities-1` (section 13.4 and 13.5), `13-client-gameplay-and-controls` (section 1), `18-mob-framework` (section 3.3), `42-particles-1` (section 4.4 resolver), `29-block-updates-and-placement` (placement context). `12-client-rendering` states no block shape; `31-block-entities-2 to 8` and `30-redstone-2, 7, 8` add no further box |
| Method | Consolidation of existing documents. Nothing here was read from the game jar, the resource pack or any code. Where documents disagree or are silent the gap is an entry of the Open questions, not a guess. Formulas marked "derived" were computed here from the rotation rules of section 2.4 applied to boxes the documents state |
| Scope | Shape only. Occlusion, block-support and visual shapes, light, and sturdiness are named only where they differ from the collision or outline shape in a way the documents state |

## 1. Conventions

### 1.1 Units and boxes

- Pixel units: each axis runs 0 to 16 across the block cell (24-1 6.2). A box is written (x1,y1,z1,x2,y2,z2) with x1<x2, y1<y2, z1<z2. x grows east, y grows up, z grows south; north is small z.
- A shape is a list of boxes whose union is the shape. Boxes of one shape may overlap. An empty shape is the empty list. Boxes may leave the cell (a value below 0 or above 16, for example the long piston arm to z 20, the fence collision to y 24, the pitcher crop to y -1).
- Helper boxes used in the tables (24-1 6.2, 24-4 2.4): `column(s,y1,y2)` = (8-s/2, y1, 8-s/2, 8+s/2, y2, 8+s/2); `column(sx,sz,y1,y2)` = (8-sx/2, y1, 8-sz/2, 8+sx/2, y2, 8+sz/2); `cube(s)` = a box of side s centred on (8,8,8). Tables give the resulting numbers, so these are only for reading the source documents.
- Generic collision rule (24-1 5.2): the collision shape of a state is its outline shape when the block has collision, else the empty shape; a class may override it. The outline is the targeting shape in this document (see Open questions 6 and 7 for what the documents leave unsaid about targeting).

### 1.2 Collision shape versus outline shape

- Every state has two shapes: the collision shape (entity movement) and the outline shape (`getShape`, targeting and, for non-collision blocks, the only shape). Tables below give both; "same" in the outline column means equal to the collision column.
- The `noCollision` flag (column 16 of the registry rows, which also clears the can-occlude flag) makes the collision shape empty and leaves the outline unchanged. Examples: torches, buttons, levers, plates, signs, rails, redstone wire, plants. A block with the flag still has an outline and can be targeted.
- The flag is not the last word: a class may override its collision shape. The documents show these overrides of a `noCollision` row: `scaffolding` (24-7 11.4: own collision, rule R-C19), `wall_hanging_sign` (24-3 5.2: the plank only, rule R-C8), `pitcher_crop` (24-6 6.7: lower-half boxes, rule R-F13; Open question 5). The flag `noOcclusion` alone keeps the collision shape (ladder, lanterns, campfires, glass-like blocks).
- A shape can also differ between collision and outline without the flag. Rules that do this are marked in the "collision" column: fences, fence gates and walls (collision 24 high), snow layers (one layer lower), cactus (15 high), sculk shrieker (outline full cube, collision half), mud and soul sand (collision 14 high), honey (collision shrunk), composter (collision is the empty bin), big dripleaf (collision is the leaf only), bamboo stalk (thin collision), lectern, and so on.
- Open or closed state can empty a collision shape: an open fence gate has no collision (24-5 7.18). A full dripleaf (tilt full) has none (24-8 5.2). An open trapdoor or door keeps a collision shape, a thin panel (rules R-B6, R-B7).

### 1.3 Fluids

- `water` and `lava` (`LiquidBlock`) have an empty outline (24-1 section 14, 29a 1.2). Their collision is the empty shape except in the cases of rule R-A3 (source lava a Strider can stand on; the "always collide with fluid" context). `bubble_column`, `void_air`, `cave_air` and `air` are empty in both shapes.
- The fluid itself has a shape: for a fluid state of amount `n` (1 to 8; source 8 counts as height 8/9) the own height is n/9 of a block; the height is 1.0 when the cell above holds the same fluid; the shape is the box (0,0,0,16,16*height,16) (29a 1.3). That box is the fluid shape, not the block shape; the documents do not say whether the targeting step uses it (Open question 6).
- `waterlogged` never changes a block shape in any rule below (fences, walls, panes, stairs, slabs, trapdoors and the others say so; the states differ only in the fluid reported). A double slab and a block that is not `SimpleWaterlogged` cannot be waterlogged.

### 1.4 The XZ and XYZ model offset

- Blocks flagged `offset:XZ` or `offset:XYZ` (column 16) are moved by an offset that depends only on the block position (24-1 4.4, 24-2 2.7, 24-5 6.1). With `getSeed(x,0,z)`: take h = (x*3129871 as a 32-bit product widened to 64 bits) XOR (z*116129781 in 64 bits) XOR y, where y is 0; then seed = (h*h*42317861 + h*11) >> 16 with 64-bit wrap-around and an arithmetic shift. Both types use y = 0.
- dx = clamp(((seed AND 15)/15 - 0.5)*0.5, -m, m); dz = clamp((((seed >> 8) AND 15)/15 - 0.5)*0.5, -m, m); m = maximum horizontal offset, default 0.25 block. For `XYZ` only: dy = (((seed >> 4) AND 15)/15 - 1.0) * v, with v = maximum vertical offset, default 0.2 (so dy lies between -0.2 and 0). The division by 15 is done in 32-bit float and then widened (24-2 2.7); the clamp bounds are the float 0.25 widened. Offsets are in blocks (multiply by 16 for pixels).
- Exceptions to the limits: pointed dripstone and sulfur spike use m = 0.125 (24-8 4.4); small dripleaf is `XYZ` with v = 0.1 (24-8 4.4). No other override of m or v is stated (24-5 6.1 states that no class overrides m).
- Blocks with `offset:XZ`: the fifteen flowers (and `wither_rose`), `tall_seagrass`, `sunflower`, `lilac`, `rose_bush`, `peony`, `tall_grass`, `large_fern`, `pitcher_plant`, `bamboo_sapling`, `bamboo`, `warped_roots`, `crimson_roots`, `nether_sprouts`, `hanging_roots`, `open_eyeblossom`, `closed_eyeblossom`, `mangrove_propagule`, `pointed_dripstone`, `sulfur_spike`. Blocks with `offset:XYZ`: `short_grass`, `fern`, `short_dry_grass`, `tall_dry_grass`, `small_dripleaf` (24-2 5, 24-5 3, 24-6 7.2, 24-7 17, 24-8 7.1, 29b-4).
- Where the offset is applied: 24-5 6.1 says it applies to the outline and the collision shape, the model and the selection box; 24-6 (bamboo, bamboo sapling, pitcher plant) and 24-8 (dripstone, roots, dripleaf, eyeblossom) give shapes "moved by the offset"; 24-2 2.7 says only the flowers apply it inside `getShape` and leaves the others untraced. Rule used in this document: the offset moves the outline and any collision of every offset block (Open question 1 records the conflict). Both halves of a tall plant get the same offset because the seed ignores y.
- A block with collision and an offset type is marked `dynamicShape` (24-1 4.4): `bamboo`, `pointed_dripstone`, `sulfur_spike`.

### 1.5 What a shape depends on

- Almost every shape is a function of the block state's properties only. Connection booleans (fence, wall, pane, bars, tripwire, vine, redstone wire, chorus plant) are stored in the state; the neighbours are consulted only when the state is computed (placement and shape update), never when the shape is read.
- Shapes that read something beyond the properties:
  - position: every offset block (section 1.4);
  - the block entity: `shulker_box` and `moving_piston` (rules R-E16, R-E23);
  - the querying entity or the placer (the "collision context"): `scaffolding` (holds scaffolding item; entity above; descending), `light` (holds the light item), `powder_snow` (fall distance, boots, above), `water`/`lava` (rules R-A3), `moving_piston` (piston no-clip direction);
  - the cell above: none directly; `wall` reads it when the state is computed (tall or low arms), the shape reads only the state.
- Collision-context helpers as far as the documents define them: the placement context carries `descending` = the player's descending flag, `isHoldingItem` = main-hand item, `entityBottom` = the player's current y (the lowest double when there is no player), placement flag true, no entity, `alwaysCollideWithFluid` false (29 9.6). The context built for a particle (42-1 4.4) has no entity, `isDescending` false, `canStandOnFluid` false and `isAbove(shape, pos)` true when the context y exceeds (cell y + shape max y - 9.999999747378752E-6). The same helper for entities is not defined (Open question 7).

### 1.6 Properties, directions and cardinal facts used by the rules

- Directions: north = -z, east = +x, south = +z, west = -x, up = +y, down = -y. Clockwise and counter-clockwise are seen from above: clockwise(north) = east, clockwise(east) = south, clockwise(south) = west, clockwise(west) = north; counter-clockwise is the reverse.
- Property value lists and defaults are in the registry parts; this document names only the properties that a shape consults.

### 1.7 Out of scope for the lookup

Block-support, occlusion and visual shapes differ from the outline for some blocks (fence arms 2 wide for occlusion, `leaves` empty support, iron bars empty visual shape, soul sand and mud full support shape, chorus flower support `(1,0,1,15,15,15)`). They are not needed for movement or targeting and are in the registry parts.

## 2. Rotation and mirroring formulas

Shapes are authored for one orientation and turned about the cell centre (8,8,8). All formulas are on pixel boxes (24-1 6.7, 24-2 2.6, 24-4 2.4, 24-7 4, 24-8 5.1).

### 2.1 Horizontal turns (yaw), key = a horizontal direction

A box (x1,z1,x2,z2) with unchanged y authored for key north becomes:

| Key | Point map | New box (x1,z1,x2,z2) |
|---|---|---|
| north | (x,z) -> (x,z) | (x1, z1, x2, z2) |
| east | (x,z) -> (16-z, x) | (16-z2, x1, 16-z1, x2) |
| south | (x,z) -> (16-x, 16-z) | (16-x2, 16-z2, 16-x1, 16-z1) |
| west | (x,z) -> (z, 16-x) | (z1, 16-x2, z2, 16-x1) |

East is a quarter turn clockwise seen from above. A feature on the north side goes to the east side. Example: the box (0,0,0,8,8,8)-sized north-west corner (0,0,8,8 in x1,z1,x2,z2) becomes (8,0,16,8), the north-east corner. Three steps equal the west key.

### 2.2 Six-direction keys (`rotateAll`)

| Key | Rule on the box (x1,y1,z1,x2,y2,z2) authored for north |
|---|---|
| north, east, south, west | section 2.1 |
| up | y becomes 16-z and z becomes y: new y range (16-z2, 16-z1), new z range (y1, y2), x unchanged |
| down | y becomes z and z becomes 16-y: new y range (z1, z2), new z range (16-y2, 16-y1), x unchanged |

Check: the trapdoor panel (0,0,13,16,16,16) under key down is (0,13,0,16,16,16), under key up (0,0,0,16,3,16).

### 2.3 Axis keys

- `rotateHorizontalAxis` (fence gate, anvil, bell frame): key z = the box as authored, key x = the east turn of section 2.1. A shape keyed by the axis of `facing`: facing north or south uses z, east or west uses x.
- `rotateAllAxis` (chain, end rod, lightning rod): z as authored, x = east turn, y = the down turn of section 2.2 (the box authored along z, running 0 to 16 in z, then lies along y).

### 2.4 Attach faces (`rotateAttachFace`, lever, button, grindstone)

Authored for face = wall and key north. For `face` wall: yaw by the facing (section 2.1). For `floor`: first (x,y,z) -> (x, 16-z, y) (box: y range (16-z2, 16-z1), z range (y1, y2)), then yaw by the facing. For `ceiling`: first (x,y,z) -> (16-x, z, y) (box: x range (16-x2, 16-x1), y range (z1, z2), z range (y1, y2)), then yaw by the facing. The ceiling transform is the X quarter turn (x,y,z) -> (x,z,16-y) followed by the half turn about y; the documents resolved the order from the group table (24-4 open question 2, closed).

### 2.5 Vertical mirror

`half = top` stairs: first y -> 16-y (box y range (16-y2, 16-y1)), then the yaw of section 2.1.

### 2.6 Rotate and mirror of the state itself

Rotating or mirroring a state changes its properties (the facing, the side booleans), not its shapes; a shape lookup uses the state it is given. The mapping of properties is in the registry parts (24-4 6.2, 24-7 8.5).

## 3. Rule table by block class

Rule ids (R-...) are referenced by the index in section 4. Boxes are in pixels. "Key" means the direction used in the rotation formulas of section 2. Outline "same" means equal to collision. Where the collision column says "none" the collision shape is empty.

### 3.1 Generic and fluids

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-A1 | `Block` (all stone, dirt, planks, ores, bricks, concrete, terracotta, wool, copper blocks, `bedrock` ...), `RotatedPillarBlock`, `InfestedBlock` and pillar variant, `DropExperienceBlock`, glass (`TransparentBlock`), stained glass, `TintedGlassBlock`, `WaterloggedTransparentBlock`, `IceBlock`, `FrostedIceBlock`, `HalfTransparentBlock`, `SlimeBlock`, `LeavesBlock` and all leaf subclasses, `MangroveRootsBlock`, `SpawnerBlock`, `HugeMushroomBlock`, `BeaconBlock`, `ObserverBlock`, `DispenserBlock`, `DropperBlock`, `FurnaceBlock`, `CommandBlock`, `CrafterBlock`, `TrialSpawnerBlock`, `VaultBlock`, `CopperBulbBlock`, `StructureBlock`, `JigsawBlock`, `TestBlock`, `TestInstanceBlock`, `LoomBlock`, `BarrelBlock`, `SmokerBlock`, `BlastFurnaceBlock`, `CartographyTableBlock`, `SmithingTableBlock`, `CraftingTableBlock`, and the other plain-shape classes listed in section 4 | none (`axis`, `facing`, `lit` and the like do not change the shape) | always | (0,0,0,16,16,16) | same | The default `Block.getShape` (24-1 6.7). `LeavesBlock` has an empty block-support shape and empty occlusion, not an empty collision. `noOcclusion` does not change collision |
| R-A2 | `cobweb`; `kelp_plant`; `end_gateway`; `firefly_bush` | none | always | none (`noCollision`) | (0,0,0,16,16,16) | The outline is the full cube (`WebBlock`, kelp plant, gateway) with no collision (24-2 section 6, 24-6 6.9, 6.14, 24-8 4.4) |
| R-A3 | `air`, `void_air`, `cave_air`, `bubble_column`, `water`, `lava` (`LiquidBlock`) | `level` (liquid) | air and bubble column: always. Liquid: collision rules below | none, except liquid cases | none (empty) | `LiquidBlock` collision, in this order (24-1 sec. 14, 29a 1.2): (1) the full cube when the context says "always collide with fluid"; (2) empty when `level` is not 0; (3) when `level` is 0 and the context is a living entity that is above the shape and may stand on the fluid: that entity's liquid shape. The Strider alone may stand on lava (a `column(16,0,8)` = (0,0,0,16,8,16), only source lava); otherwise empty. All the other entity classes: unknown (24-1 open question 11) |
| R-A4 | `barrier` | none | always | (0,0,0,16,16,16) | same | Invisible block with full collision (24-5 7.15) |
| R-A5 | `light` | `level`, `waterlogged` | the querying context holds the light item: shape is the full cube; else empty | none | full cube when the context holds the light item, else empty | Collision is evaluated without a holding context, so it is always empty (24-5 7.15) |
| R-A6 | `structure_void` | none | always | none | (5,5,5,11,11,11) | `noCollision`, replaceable |

### 3.2 Slabs, stairs, walls, fences, gates, doors, trapdoors, panes

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-B1 | `SlabBlock` (all slabs including `WeatheringCopperSlabBlock`) | `type` | bottom | (0,0,0,16,8,16) | same | A player standing on a bottom slab has feet at 0.5 |
| | | | top | (0,8,0,16,16,16) | same | |
| | | | double | (0,0,0,16,16,16) | same | `waterlogged` ignored |
| R-B2 | `StairBlock` (all stairs, `WeatheringCopperStairBlock`) | `facing`, `half`, `shape` | piece and key chosen below | the shape | same | Pieces authored for half = bottom, key north: SLAB (0,0,0,16,8,16). OUTER = SLAB + (0,8,0,8,16,8). STRAIGHT = SLAB + (0,8,0,16,16,8). INNER = SLAB + (0,8,0,16,16,8) + (8,8,0,16,16,16). Piece by `shape`: straight uses STRAIGHT; inner_left and inner_right use INNER; outer_left and outer_right use OUTER. Key by `shape`: `facing` for straight, outer_left and inner_right; counter-clockwise(`facing`) for inner_left; clockwise(`facing`) for outer_right. Yaw the piece by the key (section 2.1). `half` = top: mirror the piece vertically (section 2.5) before the yaw. `waterlogged` ignored. The `shape` property itself is computed from the neighbours when the state is placed or updated: 24-2 7.8 |
| R-B3 | `WallBlock` | `up`, `north`, `east`, `south`, `west` (each none, low, tall) | union of parts | Same parts with height 24 | Post `up` = true: (4,0,4,12,16,12). North arm: low = (5,0,0,11,14,11); tall = (5,0,0,11,16,11); none adds nothing. East, south, west arms: yaw the north arm (section 2.1): east low (5,0,5,16,14,11); south (5,0,5,11,14,16); west (0,0,5,11,14,11); tall likewise with y to 16 | Collision: post (4,0,4,12,24,12) when `up`, every low or tall arm becomes y 0 to 24. `waterlogged` ignored. A wall is a barrier 1.5 high for movement |
| R-B4 | `FenceBlock` (all wooden and nether fences) | `north`, `east`, `south`, `west` (booleans) | union of parts | Post (6,0,6,10,24,10); each true side adds an arm to y 24 | Post (6,0,6,10,16,10); north arm (6,0,0,10,16,8) when `north`; east (8,0,6,16,16,10); south (6,0,8,10,16,16); west (0,0,6,8,16,10) | Arm of side d is the north arm yawed to d. Collision arms: (6,0,0,10,24,8) and its yaws. `waterlogged` ignored. Connection states: 24-4 5.2 |
| R-B5 | `FenceGateBlock` | `facing` (axis only), `in_wall`, `open` | outline and collision | open: none. Closed: axis z (facing north or south) (0,0,6,16,24,10); axis x (6,0,0,10,24,16) | Axis z: (0,0,6,16,16,10); axis x (6,0,0,10,16,16). `in_wall`: y top 13: (0,0,6,16,13,10) and (6,0,0,10,13,16) | The outline ignores `open`; collision is 24 high when closed (24-5 7.18, 24-6 6.1) |
| R-B6 | `DoorBlock` (all doors) | `facing`, `open`, `hinge` | key chosen below | Panel box authored for key north: (0,0,13,16,16,16); yaw by the key | same | Key: `facing` when closed; when open, counter-clockwise(`facing`) if `hinge` = right, clockwise(`facing`) if `hinge` = left. Both halves (upper and lower) use the same shape (each 16 high). The panel is 3 pixels thick against the cell edge opposite the key: key north z 13..16; east x 0..3; south z 0..3; west x 13..16 |
| R-B7 | `TrapDoorBlock` (all trapdoors) | `facing`, `half`, `open` | key chosen below | Panel authored for key north (0,0,13,16,16,16); `rotateAll` | same | Key: `facing` when open; when closed, down for `half` = top and up for `half` = bottom. Results: closed bottom (0,0,0,16,3,16); closed top (0,13,0,16,16,16); open facing north (0,0,13,16,16,16), east (0,0,0,3,16,16), south (0,0,0,16,16,3), west (13,0,0,16,16,16). The panel sits against the edge opposite the key |
| R-B8 | `IronBarsBlock` (`iron_bars`, copper bars, `StainedGlassPaneBlock`, `glass_pane`, `WeatheringCopperBarsBlock`) | `north`, `east`, `south`, `west` | union | Post (7,0,7,9,16,9) plus arms | same | North arm (7,0,0,9,16,8); east (8,0,7,16,16,9); south (7,0,8,9,16,16); west (0,0,7,8,16,9). Arm of side d when side d is true. `waterlogged` ignored. The visual shape is empty (rendering only) |
| R-B9 | `ChainBlock`, `WeatheringCopperChainBlock` | `axis` | by axis | (6.5,6.5,0,9.5,9.5,16) for axis z; (0,6.5,6.5,16,9.5,9.5) for axis x; (6.5,0,6.5,9.5,16,9.5) for axis y | same | `rotateAllAxis(cube(3,3,16))` (24-4 6.4) |
| R-B10 | `EndRodBlock` | `facing` (axis only) | by axis of `facing` | z axis (6,6,0,10,10,16); x axis (0,6,6,16,10,10); y axis (6,0,6,10,16,10) | same | `rotateAllAxis(cube(4,4,16))` (24-6 6.4) |
| R-B11 | `LightningRodBlock`, `WeatheringLightningRodBlock` | `facing` (axis only) | as R-B10 | as R-B10 | same | `cube(4,4,16)` keyed by axis (24-8 5.2) |

### 3.3 Attached small blocks

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-C1 | `TorchBlock` (`torch`, `soul_torch`, `copper_torch`), `RedstoneTorchBlock` | none (redstone: `lit`, shape unchanged) | always | none | (6,0,6,10,10,10) | |
| R-C2 | `WallTorchBlock` (`wall_torch`, `soul_wall_torch`, `copper_wall_torch`), `RedstoneWallTorchBlock` | `facing` | key = `facing` | none | Authored for north (5.5,3,11,10.5,13,16). East (0,3,5.5,5,13,10.5); south (5.5,3,0,10.5,13,5); west (11,3,5.5,16,13,10.5) | Section 2.1 on the north box gives these |
| R-C3 | `LeverBlock` | `face`, `facing` (`powered` ignored) | by face | none | Wall, key = `facing`, authored north (5,4,10,11,12,16): east (0,4,5,6,12,11); south (5,4,0,11,12,6); west (10,4,5,16,12,11). Floor: facing north or south (5,0,4,11,6,12); east or west (4,0,5,12,6,11). Ceiling: facing north or south (5,10,4,11,16,12); east or west (4,10,5,12,16,11) | 24-3 5.2, 30-5 2.6 |
| R-C4 | `ButtonBlock` (all buttons) | `face`, `facing`, `powered` | thickness by `powered` | none | Wall: north unpressed (5,6,14,11,10,16), pressed (5,6,15,11,10,16); east (0,6,5,2,10,11) / (0,6,5,1,10,11); south (5,6,0,11,10,2) / (5,6,0,11,10,1); west (14,6,5,16,10,11) / (15,6,5,16,10,11). Floor: facing north or south unpressed (5,0,6,11,2,10), pressed (5,0,6,11,1,10); east or west (6,0,5,10,2,11) / (6,0,5,10,1,11). Ceiling: north or south (5,14,6,11,16,10) / (5,15,6,11,16,10); east or west (6,14,5,10,16,11) / (6,15,5,10,16,11) | 24-4 6.32. Plate 6 by 4, 2 thick released and 1 thick pressed. A button has no collision |
| R-C5 | `PressurePlateBlock` (all), `WeightedPressurePlateBlock` | `powered` (weighted: `power`) | released or pressed | none | Released (signal 0): (1,0,1,15,1,15). Pressed: (1,0,1,15,0.5,15) | Pressed = `powered` true, or `power` above 0. Detection box (not a shape) (1,0,1,15,4,15) |
| R-C6 | `StandingSignBlock` | none (`rotation` ignored) | always | none | (4,0,4,12,16,12) | |
| R-C7 | `WallSignBlock` | `facing` | key = `facing` | none | Authored north (0,4.5,14,16,12.5,16). East (0,4.5,0,2,12.5,16); south (0,4.5,0,16,12.5,2); west (14,4.5,0,16,12.5,16) | |
| R-C8 | `CeilingHangingSignBlock` | `rotation` (0 to 15) | by rotation | none | rotation 0 or 8: (1,0,7,15,10,9); rotation 4 or 12: (7,0,1,9,10,15); every other rotation: (3,0,3,13,16,13) | 24-3 5.2. `attached` does not change it |
| R-C9 | `WallHangingSignBlock` | `facing` (axis only) | by axis of `facing` | Plank only: axis z (0,14,6,16,16,10); axis x (6,14,0,10,16,16) | Plank plus board: axis z plank + (1,0,7,15,10,9); axis x plank + (7,0,1,9,10,15) | The `noCollision` row flag is overridden by a plank collision (24-3 5.2). Collision exists despite the flag |
| R-C10 | `BannerBlock` | none | always | none | (4,0,4,12,16,12) | |
| R-C11 | `WallBannerBlock` | `facing` | key = `facing` | none | North (0,0,14,16,12.5,16); east (0,0,0,2,12.5,16); south (0,0,0,16,12.5,2); west (14,0,0,16,12.5,16) | |
| R-C12 | `SkullBlock`, `PlayerHeadBlock`, `WitherSkullBlock` (standing heads) | `rotation` ignored | by head type | Zombie, creeper, wither skeleton, skeleton, player: (4,0,4,12,8,12). Piglin: (3,0,3,13,8,13). Dragon: (4,0,4,12,8,12) | same, except dragon outline (4,0,4,12,8.5,12) | `AbstractSkullBlock`; the piglin and dragon heads exist in the registry as `SkullBlock` types (24-5 7.1) |
| R-C13 | `WallSkullBlock`, `PlayerWallHeadBlock`, `WitherWallSkullBlock`, `PiglinWallSkullBlock` | `facing` | key = `facing`, by type | Ordinary types: north (4,4,8,12,12,16); east (0,4,4,8,12,12); south (4,4,0,12,12,8); west (8,4,4,16,12,12). Piglin: north (3,4,8,13,12,16); east (0,4,3,8,12,13); south (3,4,0,13,12,8); west (8,4,3,16,12,13) | same (the dragon wall head uses the ordinary wall shape) | 24-5 7.1 |
| R-C14 | `TripWireHookBlock` | `facing` | key = `facing` | none | Authored north (5,0,10,11,10,16): east (0,0,5,6,10,11); south (5,0,0,11,10,6); west (10,0,5,16,10,11) | 24-4 6.26 |
| R-C15 | `LadderBlock` | `facing` | key = `facing` | Panel authored north (0,0,13,16,16,16); east (0,0,0,3,16,16); south (0,0,0,16,16,3); west (13,0,0,16,16,16) | same | A ladder has collision (a 3-pixel panel), `noOcclusion` only |
| R-C16 | `VineBlock`, `MultifaceBlock` (`glow_lichen`, `resin_clump`), `SculkVeinBlock` | `up`, `north`, `east`, `south`, `west`, `down` (booleans, no `down` for vine) | union of sheets | none (`vine`, `glow_lichen`, `resin_clump` and `sculk_vein` are all `noCollision`) | Union over the true faces of a sheet one pixel thick: north (0,0,0,16,16,1); east (15,0,0,16,16,16); south (0,0,15,16,16,16); west (0,0,0,1,16,16); up (0,15,0,16,16,16); down (0,0,0,16,1,16). With no face set the shape is the full cube | `rotateAll(boxZ(16,0,1))`. The down sheet follows from the `down` entry of section 2.2 (derived) |
| R-C17 | `LanternBlock`, `WeatheringLanternBlock` | `hanging` | by `hanging` | Standing: (6,7,6,10,9,10) + (5,0,5,11,7,11). Hanging: (6,8,6,10,10,10) + (5,1,5,11,8,11) | same | One pixel higher when hanging |
| R-C18 | `CampfireBlock` (campfire, soul campfire) | none (`lit`, `facing` ignored) | always | (0,0,0,16,7,16) | same | |
| R-C19 | `BellBlock` | `attachment`, `facing` | by attachment | Bell body B = (5,6,5,11,13,11) + (4,4,4,12,6,12). Ceiling: B + (7,13,7,9,16,9). Floor: frame only, facing axis z (0,0,4,16,16,12), axis x (4,0,0,12,16,16). Double wall: B + (7,13,0,9,15,16) for axis z, (0,13,7,16,15,9) for axis x. Single wall: B + (7,13,0,9,15,13) yawed to key `facing` | same | Outline and collision equal; the floor shape as read lacks the body (Open question 10) |
| R-C20 | `ScaffoldingBlock` | `bottom`, `distance`; context | see notes | Placing: none. Entity above the full block and not descending: stable shape. Otherwise, with `distance` not 0, `bottom` true and the entity above the block one below: (0,0,0,16,2,16). Else none | Context holds scaffolding item: full cube. Else `bottom`: unstable; else stable | Stable = (0,14,0,16,16,16) + corner posts (0,0,0,2,16,2), (14,0,0,16,16,2), (14,0,14,16,16,16), (0,0,14,2,16,16). Unstable = stable + (0,0,0,16,2,16) + bottom edge beams (0,0,0,16,2,2), (14,0,0,16,2,16), (0,0,14,16,2,16), (0,0,0,2,2,16). The interaction shape is the full cube. The row flag is `noCollision` (24-7 11.4) |
| R-C21 | `CandleBlock` | `candles` (1 to 4) | by count | same (the row carries `noOcclusion` only) | 1: (7,0,7,9,6,9); 2: (5,0,6,11,6,9); 3: (5,0,6,10,6,11); 4: (5,0,5,11,6,10) | `lit`, `waterlogged` ignored |
| R-C22 | `CandleCakeBlock` | none | always | same | (1,0,1,15,8,15) + (7,8,7,9,14,9) | |
| R-C23 | `AmethystClusterBlock` (cluster, large bud, medium bud, small bud) | `facing` | `rotateAll`, key = `facing` | the shape | Authored north, height h width w: box (8-w/2, 8-w/2, 16-h, 8+w/2, 8+w/2, 16). Cluster h 7 w 10 (3,3,9,13,13,16); large bud h 5 w 10 (3,3,11,13,13,16); medium bud h 4 w 10 (3,3,12,13,13,16); small bud h 3 w 8 (4,4,13,12,12,16). Other keys: section 2.2 | `facing` up puts the cluster on the floor (up key: y 0 to 7 for the cluster) |

### 3.4 Low and flat blocks

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-D1 | `WoolCarpetBlock`, `CarpetBlock` (`moss_carpet`) | none | always | (0,0,0,16,1,16) | same | |
| R-D2 | `MossyCarpetBlock` (`pale_moss_carpet`) | `bottom`, `north`, `east`, `south`, `west` (none, low, tall) | union | `bottom` true: (0,0,0,16,1,16). `bottom` false: none | Base (0,0,0,16,1,16) when `bottom`; per side: low = (0,0,0,16,10,1) yawed to that side; tall = (0,0,0,16,16,1) yawed; none adds nothing. The full cube when the union is empty | 24-8 4.4, 5.2 |
| R-D3 | `SnowLayerBlock` | `layers` (1 to 8) | by layers | (0,0,0,16, 2*(layers-1), 16): layer 1 is empty, layer 2 2 high, layer 8 14 high | (0,0,0,16, 2*layers, 16) | 24-3 5.2, 29b-3 |
| R-D4 | `FarmlandBlock` | none (`moisture` ignored) | always | (0,0,0,16,15,16) | same | 15/16 high |
| R-D5 | `PathBlock` (`dirt_path`) | none | always | (0,0,0,16,15,16) | same | |
| R-D6 | `SoulSandBlock` | none | always | (0,0,0,16,14,16) | (0,0,0,16,16,16) | The docs state support and visual shapes full; the outline is the default full cube (24-3 5.2) |
| R-D7 | `MudBlock` | none | always | (0,0,0,16,14,16) | (0,0,0,16,16,16) | |
| R-D8 | `HoneyBlock` | none | always | (1,0,1,15,15,15) | (0,0,0,16,16,16) | |
| R-D9 | `CactusBlock` | none | always | (1,0,1,15,15,15) | (1,0,1,15,16,15) | |
| R-D10 | `CactusFlowerBlock` | none | always | none | (1,0,1,15,12,15) | |
| R-D11 | `SugarCaneBlock` | none | always | none | (2,0,2,14,16,14) | |
| R-D12 | `LilyPadBlock` | none | always | same (the row carries `noOcclusion` only) | (1,0,1,15,1.5,15) | |
| R-D13 | `FrogspawnBlock` | none | always | none | (0,0,0,16,1.5,16) | |
| R-D14 | `RepeaterBlock`, `ComparatorBlock` | none (`facing`, `delay`, `locked`, `powered`, `mode` ignored) | always | (0,0,0,16,2,16) | same | They have collision (24-3 5.2, 24-5 7.5) |
| R-D15 | `DaylightDetectorBlock` | none | always | (0,0,0,16,6,16) | same | |
| R-D16 | `RailBlock`, `PoweredRailBlock`, `DetectorRailBlock` | `shape` | slope or flat | none | ascending_north, ascending_east, ascending_south, ascending_west: (0,0,0,16,8,16). Every other shape (the two straight shapes, the four curves): (0,0,0,16,2,16) | Powered and detector rails use six straight shapes plus the ascending shapes |
| R-D17 | `RedstoneWireBlock` | `north`, `east`, `south`, `west` (none, side, up) | union | none | Dot (3,0,3,13,1,13) always, plus per direction: `side`: side arm; `up`: side arm and up strip. North side arm (3,0,0,13,1,8); north up strip (3,0,0,13,16,1). Other directions: yaw of section 2.1 | `power` does not change it |
| R-D18 | `TripWireBlock` | `attached` | by `attached` | none | attached: (0,1,0,16,2.5,16); else (0,0,0,16,8,16) | The documents also use this box as the entity-inside shape |
| R-D19 | `NetherPortalBlock` | `axis` | by axis | none | axis z (6,0,0,10,16,16); axis x (0,0,6,16,16,10) | |
| R-D20 | `EndPortalBlock` | none | always | none | (0,6,0,16,12,16) | Entity-inside shape equal |
| R-D21 | `PowderSnowBlock` | context | see notes | Entity with fall distance above 2.5: (0,0,0,16,14.4,16) (0.8999999761581421 blocks high). Else an entity that may walk on it (rabbit, endermite, silverfish, fox, or leather boots) that is above the cell and not descending: full cube. Else none. A placement context: none | (0,0,0,16,16,16) | 24-8 5.3 |
| R-D22 | `FireBlock`, `SoulFireBlock` | `north`, `east`, `south`, `west`, `up` (fire) | by flags | none | `soul_fire`: always the flat sheet (0,0,0,16,1,16). `fire` with no flag true: the flat sheet. `fire` with flags: union over true flags of north (0,0,0,16,16,1), east (15,0,0,16,16,16), south (0,0,15,16,16,16), west (0,0,0,1,16,16), up (0,15,0,16,16,16); no flat sheet then | `age` ignored |

### 3.5 Containers, furniture and workstations

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-E1 | `ChestBlock`, `TrappedChestBlock`, `CopperChestBlock`, `WeatheringCopperChestBlock` | `type`, `facing` | single or joined | single (1,0,1,15,14,15). Joined: authored north (1,0,0,15,14,15), keyed by the connected direction: clockwise(`facing`) for type left, counter-clockwise(`facing`) for type right. North (1,0,0,15,14,15); east (1,0,1,16,14,15); south (1,0,1,15,14,16); west (0,0,1,15,14,15) | same | |
| R-E2 | `EnderChestBlock` | none | always | (1,0,1,15,14,15) | same | `column(14,0,14)` |
| R-E3 | `BedBlock` (all colours), `StrawBedBlock` | `facing`, `part` | key chosen below | Bed: mattress (0,3,0,16,9,16) + leg A (0,0,0,3,3,3) + leg B (13,0,0,16,3,3), authored north. Straw bed: foot half (0,0,0,16,4,16); head half the same + pillow (0,0,0,16,5,8), authored north | same | Key = the direction opposite to the connected direction, where the connected direction points from this half to the other: key = opposite(`facing`) for the foot half and `facing` for the head half. The legs are at the end away from the other half |
| R-E4 | `EnchantingTableBlock` | none | always | (0,0,0,16,12,16) | same | |
| R-E5 | `LecternBlock` | `facing` | collision versus outline | (0,0,0,16,2,16) + (4,2,4,12,14,12) | collision + desk boxes authored north (0,10,1,16,14,5.333333), (0,12,5.333333,16,16,9.666667), (0,14,9.666667,16,18,14), yawed to key `facing` | The third desk box reaches y 18, above the cell (Open question 11) |
| R-E6 | `HopperBlock` | `facing` (down, north, south, west, east) | body plus spout | Body (0,10,0,16,16,16) + (4,4,4,12,10,12) minus the cavity (2,11,2,14,16,14), plus the spout of `facing`: north (6,4,0,10,8,8); east (8,4,6,16,8,10); south (6,4,8,10,8,16); west (0,4,6,8,8,10); down (6,0,6,10,6,10) | same (see Open question 4: the doc 30-4 calls a separate cavity shape the outline and picking shape) | The down spout is derived, not read (24-5 open question 6). `enabled` ignored |
| R-E7 | `AnvilBlock` (anvil, chipped, damaged) | `facing` (axis only) | by axis | Axis z (facing north or south): (2,0,2,14,4,14) + (4,4,3,12,5,13) + (6,5,4,10,10,12) + (3,10,0,13,16,16). Axis x (facing east or west): (2,0,2,14,4,14) + (3,4,4,13,5,12) + (4,5,6,12,10,10) + (0,10,3,16,16,13) | same | |
| R-E8 | `CauldronBlock`, `LavaCauldronBlock`, `LayeredCauldronBlock` (water, powder snow) | none for the shape (`level` ignored) | always | Full cube minus (0,0,4,16,3,12), (4,0,0,12,3,16), (2,0,2,14,3,14) and the inside (2,4,2,14,16,14) | same | Leaves four corner legs in y 0 to 3 and 2-wide walls above y 4; the floor spans y 3 to 4. Entity-inside shape adds the content box up to y 6+3*level (water, powder snow) or 15 (lava); not a collision |
| R-E9 | `BrewingStandBlock` | none | always | (7,2,7,9,14,9) + (1,0,1,15,2,15) | same | |
| R-E10 | `ComposterBlock` | `level` (0 to 8) | collision versus outline | Collision: the level-0 bin | Outline: the full cube minus the box (2, f, 2, 14, 16, 14) where f = floor top: level 0: 2; 1: 3; 2: 5; 3: 7; 4: 9; 5: 11; 6: 13; 7 and 8: 15 | Collision uses the level-0 shape (f = 2) at every level. The interaction shape is the full cube |
| R-E11 | `GrindstoneBlock` | `face`, `facing` | by face | Wall, key north (support to the south): legs (2,6,7,4,10,16), (2,5,3,4,11,9), (12,6,7,14,10,16), (12,5,3,14,11,9), wheel (4,2,0,12,14,12). Floor, north: (2,0,6,4,9,10), (2,7,5,4,13,11), (12,0,6,14,9,10), (12,7,5,14,13,11), wheel (4,4,2,12,16,14). Ceiling, north: (2,7,6,4,16,10), (2,3,5,4,9,11), (12,7,6,14,16,10), (12,3,5,14,9,11), wheel (4,0,2,12,12,14). Other facings: yaw | same | Derived by the attach-face transforms of section 2.4 (24-7 10.1) |
| R-E12 | `StonecutterBlock` | none | always | (0,0,0,16,9,16) | same | |
| R-E13 | `EndPortalFrameBlock` | `eye` | by `eye` | `eye` false: (0,0,0,16,13,16). `eye` true: that + (4,13,4,12,16,12) | same | |
| R-E14 | `DragonEggBlock` | none | always | (1,0,1,15,16,15) | same | |
| R-E15 | `ConduitBlock` | none | always | (5,5,5,11,11,11) | same | `cube(6)` |
| R-E16 | `ShulkerBoxBlock` | `facing`, block entity lid progress | by progress | Closed: full cube. Otherwise the unit cube extended by 0.5*progress block along `facing` (progress 0 to 1) | same | Without a block entity: full cube. Not a function of the state alone (24-6 6.12, 31-1 13.5). Open question 12 |
| R-E17 | `DecoratedPotBlock` | none | always | (1,0,1,15,16,15) | same | |
| R-E18 | `HeavyCoreBlock` | none | always | (4,0,4,12,8,12) | same | |
| R-E19 | `CopperGolemStatueBlock`, `WeatheringCopperGolemStatueBlock` | none | always | (3,0,3,13,14,13) | same | |
| R-E20 | `FlowerPotBlock` (`flower_pot`, all `potted_*`) | none | always | (5,0,5,11,6,11) | same | |
| R-E21 | `ShelfBlock` (all shelves) | `facing` | key = `facing` | Union authored north: (0,0,13,16,16,16), (0,12,11,16,16,13), (0,0,11,16,4,13); yaw | same | |
| R-E22 | `CakeBlock` | `bites` (0 to 6) | by bites | (1+2*bites, 0, 1, 15, 8, 15) | same | |
| R-E23 | `SculkSensorBlock`, `CalibratedSculkSensorBlock` | none | always | (0,0,0,16,8,16) | same | |
| R-E24 | `SculkShriekerBlock` | none | always | (0,0,0,16,8,16) | (0,0,0,16,16,16) | |
| R-E25 | `PistonBaseBlock` (`piston`, `sticky_piston`) | `extended`, `facing` | by `extended` | Not extended: full cube. Extended: authored north (0,0,4,16,16,16); `rotateAll`: south (0,0,0,16,16,12); west (4,0,0,16,16,16); east (0,0,0,12,16,16); down (0,4,0,16,16,16); up (0,0,0,16,12,16) | same | The extended body is 12 thick, flush with the back |
| R-E26 | `PistonHeadBlock` | `facing`, `short` | union of platform and arm | Platform authored north (0,0,0,16,16,4); arm (6,6,4,10,10,20) when `short` false or (6,6,4,10,10,16) when `short` true; `rotateAll`. South: platform (0,0,12,16,16,16), arm (6,6,-4,10,10,12) / (6,6,0,10,10,12). West: platform (0,0,0,4,16,16), arm (4,6,6,20,10,10) / (4,6,6,16,10,10). East: platform (12,0,0,16,16,16), arm (-4,6,6,12,10,10) / (0,6,6,12,10,10). Down: platform (0,0,0,16,4,16), arm (6,4,6,10,20,10) / (6,4,6,10,16,10). Up: platform (0,12,0,16,16,16), arm (6,-4,6,10,12,10) / (6,0,6,10,12,10) | same | The long arm extends 4 outside the cell on the back side. Documented in 30-3 9.2 |
| R-E27 | `MovingPistonBlock` | block entity | see notes | Empty with no block entity. Else: base union carried shape, per 24-2 5.8 and 30-3 7.5 | none (empty) | Dynamic; not a function of the state |

### 3.6 Plants and growing blocks

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-F1 | `SaplingBlock` (all saplings) | none | always | none | (2,0,2,14,12,14) | |
| R-F2 | `MangrovePropaguleBlock` | `age` (0 to 4), `hanging` | by hanging | none | Column 2 by 2 (7 to 9 in x and z) from y = M to 16 where M = 13, 10, 7, 3, 0 for age 0 to 4 when `hanging`; M = 0 when not `hanging`; moved by the XZ offset | |
| R-F3 | `FlowerBlock` (the 14 flowers), `WitherRoseBlock` | none | always | none | (5,0,5,11,10,11) moved by the XZ offset | |
| R-F4 | `EyeblossomBlock` | none | always | none | (5,0,5,11,10,11) moved by the XZ offset | |
| R-F5 | `TallGrassBlock` (`short_grass`, `fern`) | none | always | none | (2,0,2,14,13,14) moved by the XYZ offset | 24-2 section 6; the shape per 29b-4 is `column(12,0,13)` |
| R-F6 | `DryVegetationBlock` (`dead_bush`) | none | always | none | (2,0,2,14,13,14) | |
| R-F7 | `BushBlock` (`bush`, `red_shrub`) | none | always | none | (0,0,0,16,13,16) | |
| R-F8 | `ShortDryGrassBlock` | none | always | none | (2,0,2,14,10,14) moved by the XYZ offset | |
| R-F9 | `TallDryGrassBlock` | none | always | none | (1,0,1,15,16,15) moved by the XYZ offset | |
| R-F10 | `SeagrassBlock` | none | always | none | (2,0,2,14,12,14) | |
| R-F11 | `TallSeagrassBlock` | `half` (shape the same for both) | always | none | (2,0,2,14,16,14) moved by the XZ offset | |
| R-F12 | `TallFlowerBlock` (sunflower, lilac, rose bush, peony), `DoublePlantBlock` (`tall_grass`, `large_fern`, `pitcher_plant`) | none (`half` ignored) | always | none | (0,0,0,16,16,16) moved by the XZ offset | No shape override (24-5 7.17, 24-6 6.7). Open question 2 |
| R-F13 | `PitcherCropBlock` | `age` (0 to 4), `half` | by half | Lower half only: age 0 (5,-1,5,11,3,11); ages 1 to 4 (3,-1,3,13,5,13). Upper half none. | Let a = 4 + 0 for age 0 else 6 + T[age] with T = (0, 9, 11, 22, 26) giving a = 4, 15, 17, 28, 32; width w = 6 for age 0 else 10 (box x and z from 8-w/2 to 8+w/2). Lower half: x and z from 8-w/2 to 8+w/2, y from -1 to min(16, a-1) (tops 3, 14, 16, 16, 16); upper half: same x and z, y from 0 to max(0, a-1-16) (tops 0, 0, 0, 11, 15) | The row flag is `noCollision`; the lower-half collision above is stated by 24-6 6.7 and 29b-2 (Open question 5). Ages 0 to 2 never have an upper half |
| R-F14 | `CropBlock` (`wheat`) | `age` (0 to 7) | by age | none | (0,0,0,16,2+2*age,16) | Heights 2, 4, 6, 8, 10, 12, 14, 16 |
| R-F15 | `CarrotBlock`, `PotatoBlock` | `age` (0 to 7) | by age | none | (0,0,0,16,2+age,16) | Heights 2 to 9 |
| R-F16 | `BeetrootBlock` | `age` (0 to 3) | by age | none | (0,0,0,16,2+2*age,16) | Heights 2, 4, 6, 8 |
| R-F17 | `TorchflowerCropBlock` | `age` (0 to 1) | by age | none | (5,0,5,11,6+4*age,11) | |
| R-F18 | `StemBlock` (`pumpkin_stem`, `melon_stem`) | `age` (0 to 7) | by age | none | (7,0,7,9,2+2*age,9) | |
| R-F19 | `AttachedStemBlock` | `facing` | key = `facing` | none | Authored north (6,0,0,10,10,10); east (6,0,6,16,10,10); south (6,0,6,10,10,16); west (0,0,6,10,10,10) | `rotateHorizontal(boxZ(4,0,10,0,10))`; the east, south and west boxes are derived with section 2.1 (Open question 16) |
| R-F20 | `NetherWartBlock` | `age` (0 to 3) | by age | none | (0,0,0,16,5+3*age,16) | Heights 5, 8, 11, 14 |
| R-F21 | `MushroomBlock` (`brown_mushroom`, `red_mushroom`) | none | always | none | (5,0,5,11,6,11) | |
| R-F22 | `CocoaBlock` | `age` (0 to 2), `facing` | key = `facing` | by age (authored north) | Authored north: age 0 (6,7,1,10,12,5); age 1 (5,5,1,11,12,7); age 2 (4,3,1,12,12,9); yaw by `facing` | Formula in 24-4 6.23; the boxes are those computed in the document |
| R-F23 | `ShelfMushroomBlock` | `age` (0, 1), `facing` | key = `facing` | same (the row carries `noOcclusion` only; the block bounces entities) | Union authored north: age 0 cap (3,9,9,13,11,16) + stem (5,8,12,11,9,16); age 1 cap (1,8,6,15,11,16) + stem (4,6,10,12,8,16); yaw | |
| R-F24 | `KelpBlock` | none | always | none | (0,0,0,16,9,16) | `kelp_plant` is R-A2 |
| R-F25 | `SweetBerryBushBlock` | `age` (0 to 3) | by age | none | age 0 (3,0,3,13,8,13); ages 1 and 2 (1,0,1,15,16,15); age 3 (0,0,0,16,16,16) | |
| R-F26 | `NetherFungusBlock` | none | always | none | (4,0,4,12,9,12) | |
| R-F27 | `NetherRootsBlock` | none | always | none | (2,0,2,14,13,14) moved by the XZ offset | |
| R-F28 | `NetherSproutsBlock` | none | always | none | (2,0,2,14,3,14) moved by the XZ offset | |
| R-F29 | `WeepingVinesBlock` (head), `WeepingVinesPlantBlock`, `TwistingVinesBlock`, `TwistingVinesPlantBlock` | none | by block | none | weeping head (4,9,4,12,16,12); weeping plant (1,0,1,15,16,15); twisting head (4,0,4,12,15,12); twisting plant (4,0,4,12,16,12) | |
| R-F30 | `CaveVinesBlock`, `CaveVinesPlantBlock` | none | always | none | (1,0,1,15,16,15) | |
| R-F31 | `SporeBlossomBlock` | none | always | none | (2,13,2,14,16,14) | |
| R-F32 | `AzaleaBlock` (`azalea`, `flowering_azalea`) | none | always | (0,8,0,16,16,16) + (6,0,6,10,8,10) | same | The row does not carry `noCollision` |
| R-F33 | `HangingRootsBlock` | none | always | none | (2,10,2,14,16,14) moved by the XZ offset | |
| R-F34 | `HangingMossBlock` | `tip` | by tip | none | tip (1,2,1,15,16,15); base (1,0,1,15,16,15) | |
| R-F35 | `SmallDripleafBlock` | none (`half`, `facing` ignored) | always | none | (2,0,2,14,13,14) moved by the XYZ offset (vertical limit 0.1) | |
| R-F36 | `BigDripleafBlock` | `tilt`, `facing` | by tilt | Leaf: none or unstable (0,11,0,16,15,16); partial (0,11,0,16,13,16); full none | Leaf shape + stem. Stem: the box (5,0,9,11,13,15) authored north, yawed to key `facing` | Stem = `column(6,0,13)` moved 4 pixels in z |
| R-F37 | `BigDripleafStemBlock` | `facing` | key = `facing` | none | (5,0,9,11,16,15) authored north, yawed | |
| R-F38 | `FlowerBedBlock` (pink petals, wildflowers), `LeafLitterBlock` | `facing`, amount (`flower_amount` or `segment_amount`) | n quarters | none | One box that encloses the union of the first n quarter pads; quarter i (i from 0) is (0,0,0,8,h,8) yawed by `facing` turned counter-clockwise i times; h = 3 for flower beds, 1 for leaf litter | Derived result for `facing` north: n = 1 (0,0,0,8,h,8); n = 2 (0,0,0,8,h,16); n = 3 or 4 (0,0,0,16,h,16) |
| R-F39 | `PointedDripstoneBlock`, `SulfurSpikeBlock` | `thickness`, `vertical_direction` | by thickness | Same as the outline (24-8 5.2) | tip_merge (5,0,5,11,16,11); tip with `vertical_direction` up (5,0,5,11,11,11); tip with down (5,5,5,11,16,11); frustum (4,0,4,12,16,12); middle (3,0,3,13,16,13); base (2,0,2,14,16,14); moved by the XZ offset (limit 0.125) | The flag row lists `forceSolidOn`, `noOcclusion`, `dynamicShape` |
| R-F40 | `ChorusPlantBlock` | `north`, `east`, `south`, `west`, `up`, `down` | union | same | Node (3,3,3,13,13,13) plus, for each true direction, an arm 10 by 10: north (3,3,0,13,13,8); south (3,3,8,13,13,16); west (0,3,3,8,13,13); east (8,3,3,16,13,13); up (3,8,3,13,16,13); down (3,0,3,13,8,13) | `PipeBlock.makeShapes(10)` (24-6 6.5) |
| R-F41 | `ChorusFlowerBlock` | none | always | (0,0,0,16,16,16) | same | Support shape (1,0,1,15,15,15) is not the outline |
| R-F42 | `BambooSaplingBlock` | none | always | none | (4,0,4,12,12,12) moved by the XZ offset | |
| R-F43 | `BambooStalkBlock` | `leaves` | by leaves | (6.5,0,6.5,9.5,16,9.5) moved by the XZ offset | `leaves` = large: (3,0,3,13,16,13); else (5,0,5,11,16,11); moved by the XZ offset | Collision is thin at every `leaves` |
| R-F44 | `SeaPickleBlock` | `pickles` (1 to 4) | by pickles | same (collision exists) | 1: (6,0,6,10,6,10); 2: (3,0,3,13,6,13); 3: (2,0,2,14,6,14); 4: (2,0,2,14,7,14) | |
| R-F45 | `TurtleEggBlock` | `eggs` (1 to 4) | by eggs | same | 1: (3,0,3,12,7,12); 2 to 4: (1,0,1,15,7,15) | |
| R-F46 | `SnifferEggBlock` | none | always | same | (1,0,2,15,16,14) | |
| R-F47 | `DriedGhastBlock` | none | always | same | (3,0,3,13,10,13) | |
| R-F48 | `BaseCoralPlantBlock`, `CoralPlantBlock` | none | always | none | (2,0,2,14,15,14) | |
| R-F49 | `BaseCoralFanBlock`, `CoralFanBlock` | none | always | none | (2,0,2,14,4,14) | |
| R-F50 | `BaseCoralWallFanBlock`, `CoralWallFanBlock` | `facing` | key = `facing` | none | Authored north (0,4,5,16,12,16); yaw | |
| R-F51 | `CoralBlock` (live and dead coral blocks) | none | always | full cube | same | Part of R-A1 |
| R-F52 | `SpeleothemBlock` | see R-F39 | | | | The shared base class |

### 3.7 Other classes

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-G1 | `PowderSnowBlock` | | see R-D21 | | | |
| R-G2 | `PotentSulfurBlock`, `SculkBlock`, `SculkCatalystBlock`, `RootedDirtBlock`, `BuddingAmethystBlock`, `AmethystBlock`, `BonemealableFeaturePlacerBlock` | none | always | full cube | same | Full cubes stated in 24-8 4.1 |
| R-G3 | `RespawnAnchorBlock`, `CryingObsidianBlock`, `TargetBlock`, `BeehiveBlock`, `JukeboxBlock`, `NoteBlock`, `TntBlock`, `SpongeBlock`, `WetSpongeBlock`, `ChiseledBookShelfBlock`, `CreakingHeartBlock`, `MagmaBlock`, `NetherrackBlock`, `GrassBlock`, `SnowyBlock`, `MyceliumBlock`, `NyliumBlock`, `SandBlock`, `ColoredFallingBlock`, `BrushableBlock`, `ConcretePowderBlock`, `GlazedTerracottaBlock`, `PoweredBlock`, `HayBlock`, `CarvedPumpkinBlock`, `PumpkinBlock`, `RedStoneOreBlock`, `RedstoneLampBlock`, `WeatheringCopperFullBlock`, `WeatheringCopperGrateBlock`, `WeatheringCopperBulbBlock`, `CopperBulbBlock`, `StructureBlock`, `FrostedIceBlock`, `LeavesBlock` family | none | always | full cube | same | Documents state a full cube or "default shape" for these classes (24-2 section 6, 24-3 5.2, 24-5 7.9, 24-8 4.1); a few are only covered by the general default (Open question 13) |
| R-G4 | `WeatheringCopperDoorBlock`, `WeatheringCopperTrapDoorBlock`, `WeatheringCopperStairBlock`, `WeatheringCopperSlabBlock`, `WeatheringCopperBarsBlock`, `WeatheringCopperChainBlock`, `WeatheringLightningRodBlock`, `WeatheringLanternBlock`, `WeatheringCopperChestBlock`, `WeatheringCopperGolemStatueBlock` | as the base class | as the base class | as R-B6, R-B7, R-B2, R-B1, R-B8, R-B9, R-B11, R-C17, R-E1, R-E19 | same | The weathering stage never changes a shape |

## 4. Index of every class of documents 24-1 to 24-8

The "Rule" column names the row of section 3 that covers the class. Classes covered only by the default full cube are marked "full cube default". Base classes that no registry row uses as the constructed class are marked "base".

| Class | Rule |
|---|---|
| `AbstractCauldronBlock`, `CauldronBlock`, `LavaCauldronBlock`, `LayeredCauldronBlock` | R-E8 |
| `AbstractChestBlock`, `ChestBlock`, `CopperChestBlock`, `TrappedChestBlock`, `WeatheringCopperChestBlock` | R-E1 |
| `AbstractFurnaceBlock`, `BlastFurnaceBlock`, `FurnaceBlock`, `SmokerBlock` | R-A1 |
| `AbstractSkullBlock`, `SkullBlock`, `PlayerHeadBlock`, `WitherSkullBlock` | R-C12 |
| `WallSkullBlock`, `PlayerWallHeadBlock`, `PiglinWallSkullBlock`, `WitherWallSkullBlock` | R-C13 |
| `AirBlock`, `BubbleColumnBlock`, `LiquidBlock` | R-A3 |
| `AmethystBlock`, `BuddingAmethystBlock` | R-G2 |
| `AmethystClusterBlock` | R-C23 |
| `AnvilBlock` | R-E7 |
| `AttachedStemBlock` | R-F19 |
| `AzaleaBlock` | R-F32 |
| `BambooSaplingBlock` | R-F42 |
| `BambooStalkBlock` | R-F43 |
| `BannerBlock` | R-C10 |
| `WallBannerBlock` | R-C11 |
| `BarrelBlock` | R-A1 |
| `BarrierBlock` | R-A4 |
| `BaseCoralFanBlock`, `CoralFanBlock` | R-F49 |
| `BaseCoralPlantBlock`, `CoralPlantBlock`, `BaseCoralPlantTypeBlock` (base) | R-F48 |
| `BaseCoralWallFanBlock`, `CoralWallFanBlock` | R-F50 |
| `CoralBlock` | R-F51 |
| `BaseEntityBlock` (base), `BaseCommandBlock` (base), `BeaconBeamBlock` (interface), `GameMasterBlock` (interface), `SimpleWaterloggedBlock` (interface), `ChangeOverTimeBlock` (interface) | no shape of their own |
| `BasePressurePlateBlock` (base), `PressurePlateBlock`, `WeightedPressurePlateBlock` | R-C5 |
| `BaseRailBlock` (base), `RailBlock`, `PoweredRailBlock`, `DetectorRailBlock` | R-D16 |
| `BaseTorchBlock` (base), `TorchBlock`, `RedstoneTorchBlock` | R-C1 |
| `WallTorchBlock`, `RedstoneWallTorchBlock` | R-C2 |
| `BeaconBlock`, `BeehiveBlock` | R-A1 (R-G3) |
| `BedBlock`, `StrawBedBlock` | R-E3 |
| `BeetrootBlock` | R-F16 |
| `BellBlock` | R-C19 |
| `BigDripleafBlock` | R-F36 |
| `BigDripleafStemBlock` | R-F37 |
| `Block` | R-A1 |
| `BonemealableFeaturePlacerBlock` | R-G2 |
| `BrewingStandBlock` | R-E9 |
| `BrushableBlock`, `ColoredFallingBlock`, `SandBlock`, `FallingBlock` (base), `ConcretePowderBlock`, `GlazedTerracottaBlock` | full cube default (R-G3) |
| `BushBlock` | R-F7 |
| `ButtonBlock` | R-C4 |
| `CactusBlock` | R-D9 |
| `CactusFlowerBlock` | R-D10 |
| `CakeBlock` | R-E22 |
| `CalibratedSculkSensorBlock`, `SculkSensorBlock` | R-E23 |
| `CampfireBlock` | R-C18 |
| `CandleBlock` | R-C21 |
| `CandleCakeBlock` | R-C22 |
| `CarpetBlock`, `WoolCarpetBlock` | R-D1 |
| `CarrotBlock`, `PotatoBlock` | R-F15 |
| `CartographyTableBlock`, `SmithingTableBlock`, `CraftingTableBlock`, `LoomBlock` | R-A1 |
| `CarvedPumpkinBlock`, `PumpkinBlock`, `HayBlock`, `JukeboxBlock`, `NoteBlock`, `TntBlock`, `SpongeBlock`, `WetSpongeBlock`, `ChiseledBookShelfBlock`, `CreakingHeartBlock`, `MagmaBlock`, `NetherrackBlock`, `TargetBlock`, `PoweredBlock`, `RedStoneOreBlock`, `RedstoneLampBlock`, `CryingObsidianBlock`, `RespawnAnchorBlock`, `GrassBlock`, `SnowyBlock`, `SpreadingSnowyBlock` (base), `MyceliumBlock`, `NyliumBlock` | R-A1 / R-G3 |
| `CaveVinesBlock`, `CaveVinesPlantBlock`, `CaveVines` (helper) | R-F30 |
| `CeilingHangingSignBlock` | R-C8 |
| `ChainBlock`, `WeatheringCopperChainBlock` | R-B9 |
| `ChorusFlowerBlock` | R-F41 |
| `ChorusPlantBlock`, `PipeBlock` (base) | R-F40 |
| `CocoaBlock` | R-F22 |
| `CommandBlock`, `CrafterBlock`, `DispenserBlock`, `DropperBlock`, `TrialSpawnerBlock`, `VaultBlock`, `SpawnerBlock`, `StructureBlock`, `JigsawBlock`, `TestBlock`, `TestInstanceBlock` | R-A1 |
| `ComparatorBlock`, `RepeaterBlock`, `DiodeBlock` (base) | R-D14 |
| `ComposterBlock` | R-E10 |
| `ConduitBlock` | R-E15 |
| `CopperBulbBlock`, `WeatheringCopperBulbBlock`, `WeatheringCopperFullBlock`, `WeatheringCopperGrateBlock`, `WaterloggedTransparentBlock`, `TintedGlassBlock`, `StainedGlassBlock`, `TransparentBlock`, `HalfTransparentBlock`, `SlimeBlock`, `IceBlock`, `FrostedIceBlock` | R-A1 |
| `CopperGolemStatueBlock`, `WeatheringCopperGolemStatueBlock` | R-E19 |
| `CropBlock` | R-F14 |
| `DaylightDetectorBlock` | R-D15 |
| `DecoratedPotBlock` | R-E17 |
| `DoorBlock`, `WeatheringCopperDoorBlock` | R-B6 |
| `DoublePlantBlock`, `TallFlowerBlock` | R-F12 |
| `DragonEggBlock` | R-E14 |
| `DriedGhastBlock` | R-F47 |
| `DropExperienceBlock`, `InfestedBlock`, `InfestedRotatedPillarBlock`, `RotatedPillarBlock`, `RootedDirtBlock`, `SculkBlock`, `SculkCatalystBlock`, `PotentSulfurBlock`, `MangroveRootsBlock`, `HugeMushroomBlock` | R-A1 / R-G2 |
| `DryVegetationBlock` | R-F6 |
| `EnchantingTableBlock` | R-E4 |
| `EndGatewayBlock`, `FireflyBushBlock` | R-A2 |
| `EndPortalBlock` | R-D20 |
| `EndPortalFrameBlock` | R-E13 |
| `EndRodBlock` | R-B10 |
| `EnderChestBlock` | R-E2 |
| `EyeblossomBlock` | R-F4 |
| `FarmlandBlock` | R-D4 |
| `FenceBlock`, `CrossCollisionBlock` (base) | R-B4 |
| `FenceGateBlock` | R-B5 |
| `FireBlock`, `SoulFireBlock` | R-D22 |
| `FlowerBedBlock`, `LeafLitterBlock` | R-F38 |
| `FlowerBlock`, `WitherRoseBlock` | R-F3 |
| `FlowerPotBlock` | R-E20 |
| `FrogspawnBlock` | R-D13 |
| `GlowLichenBlock`, `MultifaceBlock`, `MultifaceSpreadeableBlock` (base), `SculkVeinBlock`, `VineBlock` | R-C16 |
| `GrindstoneBlock` | R-E11 |
| `GrowingPlantBlock`, `GrowingPlantHeadBlock`, `GrowingPlantBodyBlock` (bases), `KelpBlock` | R-F24 |
| `KelpPlantBlock`, `WebBlock` | R-A2 |
| `HangingMossBlock` | R-F34 |
| `HangingRootsBlock` | R-F33 |
| `HeavyCoreBlock` | R-E18 |
| `HoneyBlock` | R-D8 |
| `HopperBlock` | R-E6 |
| `IronBarsBlock`, `StainedGlassPaneBlock`, `WeatheringCopperBarsBlock` | R-B8 |
| `LadderBlock` | R-C15 |
| `LanternBlock`, `WeatheringLanternBlock` | R-C17 |
| `LecternBlock` | R-E5 |
| `LeavesBlock`, `MangroveLeavesBlock`, `TintedParticleLeavesBlock`, `UntintedParticleLeavesBlock`, `FallingParticlesLeavesBlock` | R-A1 |
| `LeverBlock` | R-C3 |
| `LightBlock` | R-A5 |
| `LightningRodBlock`, `RodBlock` (base), `WeatheringLightningRodBlock` | R-B11 |
| `LilyPadBlock` | R-D12 |
| `MangrovePropaguleBlock` | R-F2 |
| `MossyCarpetBlock` | R-D2 |
| `MovingPistonBlock` | R-E27 |
| `MudBlock` | R-D7 |
| `MushroomBlock` | R-F21 |
| `NetherFungusBlock` | R-F26 |
| `NetherPortalBlock` | R-D19 |
| `NetherRootsBlock` | R-F27 |
| `NetherSproutsBlock` | R-F28 |
| `NetherWartBlock` | R-F20 |
| `ObserverBlock` | R-A1 |
| `PathBlock` | R-D5 |
| `PistonBaseBlock` | R-E25 |
| `PistonHeadBlock` | R-E26 |
| `PitcherCropBlock` | R-F13 |
| `PointedDripstoneBlock`, `SulfurSpikeBlock`, `SpeleothemBlock` (base) | R-F39 |
| `PowderSnowBlock` | R-D21 |
| `SaplingBlock` | R-F1 |
| `ScaffoldingBlock` | R-C20 |
| `SculkShriekerBlock` | R-E24 |
| `SeaPickleBlock` | R-F44 |
| `SeagrassBlock` | R-F10 |
| `ShelfBlock` | R-E21 |
| `ShelfMushroomBlock` | R-F23 |
| `ShortDryGrassBlock` | R-F8 |
| `ShulkerBoxBlock` | R-E16 |
| `SlabBlock`, `WeatheringCopperSlabBlock` | R-B1 |
| `SmallDripleafBlock` | R-F35 |
| `SnifferEggBlock` | R-F46 |
| `SnowLayerBlock` | R-D3 |
| `SoulSandBlock` | R-D6 |
| `StairBlock`, `WeatheringCopperStairBlock` | R-B2 |
| `StandingSignBlock`, `SignBlock` (base) | R-C6 |
| `WallSignBlock` | R-C7 |
| `StemBlock` | R-F18 |
| `StonecutterBlock` | R-E12 |
| `StructureVoidBlock` | R-A6 |
| `SugarCaneBlock` | R-D11 |
| `SweetBerryBushBlock` | R-F25 |
| `TallDryGrassBlock` | R-F9 |
| `TallGrassBlock` | R-F5 |
| `TallSeagrassBlock` | R-F11 |
| `TorchflowerCropBlock` | R-F17 |
| `TrapDoorBlock`, `WeatheringCopperTrapDoorBlock` | R-B7 |
| `TripWireBlock` | R-D18 |
| `TripWireHookBlock` | R-C14 |
| `TurtleEggBlock` | R-F45 |
| `TwistingVinesBlock`, `TwistingVinesPlantBlock`, `WeepingVinesBlock`, `WeepingVinesPlantBlock`, `NetherVines` (helper) | R-F29 |
| `SporeBlossomBlock` | R-F31 |
| `VegetationBlock` (base of the plant classes) | per class |
| `WallBlock` | R-B3 |
| `WallHangingSignBlock` | R-C9 |
| `HorizontalDirectionalBlock`, `DirectionalBlock`, `FaceAttachedHorizontalDirectionalBlock` (bases) | per class |

## 5. Worked examples

Each example gives the inputs (block key and properties) and the expected shapes in pixels. "None" is the empty shape. All are derived from the rules of section 3 with the formulas of section 2.

1. `stone`: collision (0,0,0,16,16,16), outline the same.
2. `oak_slab` with `type=bottom`: collision and outline (0,0,0,16,8,16). A player stands with feet at y = cell y + 0.5. `type=top`: (0,8,0,16,16,16). `type=double`: full cube.
3. `oak_stairs`, `facing=east`, `half=bottom`, `shape=straight`: piece STRAIGHT, key east. SLAB (0,0,0,16,8,16) plus the north half (0,8,0,16,16,8) turned east (x range 16-8..16-0 = 8..16, z range 0..16): (8,8,0,16,16,16). Collision and outline equal.
4. `oak_stairs`, `facing=north`, `half=bottom`, `shape=outer_right`: piece OUTER, key clockwise(north) = east. The north-west quarter (0,8,0,8,16,8) turned east is (8,8,0,16,16,8), the north-east quarter; plus the slab.
5. `oak_stairs`, `facing=south`, `half=top`, `shape=inner_left`: piece INNER mirrored, key counter-clockwise(south) = east. Mirrored INNER north: slab (0,8,0,16,16,16) plus (0,0,0,16,8,8) plus (8,0,0,16,8,16). Turned east: (0,0,0,16,8,8) becomes (8,0,0,16,8,16); (8,0,0,16,8,16) becomes (0,0,8,16,8,16). Result: the top slab plus the lower-layer east half and south half.
6. `oak_door`, `facing=north`, `half=lower`, `hinge=left`, `open=false`: key north, collision and outline (0,0,13,16,16,16). Same state with `open=true`: key clockwise(north) = east, shape (0,0,0,3,16,16), so a player can pass through the rest of the cell on the east side of the open panel; with `hinge=right` and `open=true`: key counter-clockwise(north) = west, shape (13,0,0,16,16,16). In both open cases the door leaves the cell passable except for a 3-pixel strip along one edge.
7. `ladder`, `facing=east`: outline (0,0,0,3,16,16); collision the same (a thin 3-pixel panel; the documents give the ladder collision, it is not `noCollision`).
8. `torch`: outline (6,0,6,10,10,10), collision none. `wall_torch`, `facing=east`: outline (0,3,5.5,5,13,10.5), collision none.
9. `stone_button`, `face=wall`, `facing=north`, `powered=false`: outline (5,6,14,11,10,16), collision none. With `powered=true`: (5,6,15,11,10,16).
10. `farmland`: collision and outline (0,0,0,16,15,16): a player stands with feet at 15/16 of the cell height (0.9375).
11. `oak_fence`, `north=true`, other sides false: outline post (6,0,6,10,16,10) plus arm (6,0,0,10,16,8); collision post (6,0,6,10,24,10) plus arm (6,0,0,10,24,8) (24 high; 24-6 example 8 infers that an entity cannot step or jump onto it, an inference the documents do not compute; see section 6).
12. `cobblestone_wall`, `up=true`, `north=low`, `east=tall`, others none: outline post (4,0,4,12,16,12), north arm (5,0,0,11,14,11), east arm (5,0,5,16,16,11); collision post (4,0,4,12,24,12), north arm (5,0,0,11,24,11), east arm (5,0,5,16,24,11).
13. `oak_trapdoor`, `half=top`, `open=false`: (0,13,0,16,16,16). With `half=bottom`, `open=false`: (0,0,0,16,3,16). With `facing=south`, `open=true`: (0,0,0,16,16,3).
14. `oak_fence_gate`, `facing=north`, `in_wall=true`, `open=false`: outline (0,0,6,16,13,10), collision (0,0,6,16,24,10). With `open=true`: collision none, outline unchanged.
15. `snow`, `layers=3`: outline (0,0,0,16,6,16), collision (0,0,0,16,4,16). With `layers=1`: outline (0,0,0,16,2,16), collision none.
16. `chest`, `facing=north`, `type=left`: connected direction clockwise(north) = east, shape (1,0,1,16,14,15) for collision and outline.
17. `tall_grass` at block position (0, y, 0): outline (0,0,0,16,16,16) moved by (-0.25, 0, -0.25) blocks (seed 0 gives dx = dz = -0.25, that is 4 pixels toward the north-west), collision none.
18. `piston`, `extended=true`, `facing=up`: collision and outline (0,0,0,16,12,16). `piston_head`, `facing=up`, `short=false`: platform (0,12,0,16,16,16) plus arm (6,-4,6,10,12,10).
19. `redstone_wire`, `north=side`, `east=up`, others none: dot (3,0,3,13,1,13) plus north arm (3,0,0,13,1,8) plus the east arm turned from the north arm: (8,0,3,16,1,13), plus the east up strip (15,0,3,16,16,13); collision none.
20. `cake`, `bites=2`: (5,0,1,15,8,15) for collision and outline.

Player-collision expectations (the player box is 0.6 wide and 1.8 tall, 21 all-entities table):
- Standing on a bottom slab puts the feet at cell y + 0.5 (example 2). Standing on farmland puts them at 0.9375 (example 10). A path block is the same height.
- An open door is passable on the side of the cell that its panel does not occupy (example 6).
- A ladder is a 3-pixel panel with collision (example 7); the climbing behaviour is in 13 section 1.3. Its outline is the same panel.
- Torches, buttons, levers, plates, signs, banners, rails, redstone wire, flowers and grasses have no collision; they can be walked through and still can be targeted by the outline.
- Fences, walls and closed fence gates are 24 pixels (1.5 blocks) high for collision.

## 6. Entity movement, step-up and collision resolution (as far as the documents state them)

- Step height: 0.6 (`step_height` attribute default; 13 section 1.2). 13 section 1.3 step 3 only says "the move is performed (`Entity.move`, collision resolution, step up to 0.6)". 18 section 3.3 adds: `Entity.move` moves along each axis in the order y, then the larger of x and z (compared by absolute delta), with collision against block shapes and the world border, honouring the step height; it sets `onGround` (the vertical move was blocked while moving down), `horizontalCollision` and `verticalCollision`; "sneaking-off-edge protection applies to players only". 18 section 3.2 says: a collision blocked horizontally but passable if the entity rises by at most the step height is resolved by stepping up.
- The collide algorithm itself is written in 42-particles-1 section 4.4 (`Particle.move` resolver; the same `Entity.collideBoundingBox` shape pipeline without entities and without step-up): query box = the entity box expanded toward the delta; colliders = block collision shapes of the cells from floor(min - 1e-7) - 1 to floor(max + 1e-7) + 1 on each axis, corner cells skipped, margin cells only for large shapes (type 1) or a moving piston (type 2); a full-cube shape counts only if the query box intersects the cell, other shapes are moved to the cell and kept when non-empty and intersecting the query box. Axes are resolved one at a time in the order y, then x and z by the rule above (z first when |dx| < |dz|), skipping an axis whose delta is exactly 0, against the accumulated offset of the earlier axes. Each shape clips the running delta (`Shapes.collide`, `VoxelShape.collide`): a running |delta| below 1e-7 gives 0; the tolerance on the other two axes is 1e-7. `EPSILON` = 1.0E-7 and `BIG_EPSILON` = 1.0E-6 (24-1 6.2). Collision flags: x and z flags when requested and collided differ under a tolerant comparison, vertical flag when they differ exactly (41 3.3).
- Not stated by any document read: the step-up algorithm (when the step is tried, the order of the three trial moves, the on-ground precondition, how the result is chosen), the sneaking-edge protection algorithm, the box sizes of the other player poses; Open question 8.

## 7. Open questions

Each entry names the class or block key and what is missing. The orchestrator handles them separately.

1. Offset application. Classes `TallGrassBlock` (`short_grass`, `fern`), `ShortDryGrassBlock`, `TallDryGrassBlock`, `SmallDripleafBlock` (XYZ) and `TallSeagrassBlock`, `BambooSaplingBlock`, `NetherRootsBlock`, `NetherSproutsBlock`, `HangingRootsBlock`, `EyeblossomBlock`, `PointedDripstoneBlock`, `SulfurSpikeBlock`, `MangrovePropaguleBlock`: 24-2 2.7 and its open question 6 say only the flowers apply the offset inside `getShape` and that where the others apply it is untraced; 24-5 6.1, 24-6 and 24-8 say the offset moves the outline and collision. Missing: confirmation that the offset moves the collision and outline of every offset block, and the consumer that applies it for blocks whose class does not (rendering or targeting). Also missing: whether `short_grass`/`fern` `XYZ` use the default vertical limit 0.2 (not stated; only small dripleaf's 0.1 and the dripstone horizontal 0.125 are).
2. `TallFlowerBlock` (`sunflower`, `lilac`, `rose_bush`, `peony`) and `DoublePlantBlock` (`tall_grass`, `large_fern`, `pitcher_plant`): the documents state only that no class overrides `getShape`, so the outline is the full cube moved by the offset (24-5 7.17, 24-6 6.7). A full-cube outline for a plant is unusual; confirm that no tighter shape exists (24-2 section 6 gives `tall_seagrass` a column but the tall flowers none).
3. Offset seed for a tall plant is `getSeed(x,0,z)` for both halves (24-5 7.17); 29b-4 9.1 gives a different seed (lower half y) for model variant choice only. Confirm which applies to the outline.
4. `HopperBlock`: 24-5 7.8 says the collision and outline are body plus spout and the interaction shape (cavity, with a horizontal stub) is separate; 30-4 5.2 calls the interaction shape "the interaction (outline and picking) shape". Missing: which shape is used for targeting.
5. `PitcherCropBlock`: the row flag is `noCollision` but 24-6 6.7 and 29b-2 state lower-half collision boxes; likewise `WallHangingSignBlock` (plank collision despite the flag) and `ScaffoldingBlock`. Missing: a statement of the general rule for classes that override `getCollisionShape` over the `noCollision` flag, and whether the pitcher crop is really solid for entities.
6. Targeting algorithm: no document states how the client chooses the targeted block (ray against which shape, outline versus interaction versus visual shape, whether fluid shapes are targetable, the outline drawing, the reach). Applies to every class with an interaction shape (`CauldronBlock` family: inside box; `ComposterBlock`, `ScaffoldingBlock`: full block; `HopperBlock`: cavity) and to `LiquidBlock`.
7. `CollisionContext` helpers: `isAbove(shape, pos, flag)` for an entity (what the entity bottom is, the meaning of the boolean argument), `isDescending`, `canStandOnFluid` for classes other than `Strider` and `LivingEntity`, and which entity classes override `getLiquidCollisionShape` (24-1 open question 11). Needed for `ScaffoldingBlock`, `PowderSnowBlock`, `LiquidBlock`. Also the `isHoldingItem` source for a non-placement entity context (`LightBlock`, `ScaffoldingBlock`).
8. Step-up algorithm, sneaking-edge protection, player hitbox sizes of non-standing poses, and the full `Entity.move` sequence for entities: not in 13 beyond "step up to 0.6"; 18 section 3.3 gives only the axis order and flags; the grid search inside `VoxelShape.collide` is untraced (42-1 open question 12).
9. `FlowerBedBlock` and `LeafLitterBlock`: 29b-4 says the shape height is 3 pixels "for both" while 24-8 gives height 3 for flower beds and height 1 for leaf litter; this document uses 24-8. Confirm.
10. `BellBlock`: 24-7 11.5 says the floor attachment shape is the frame only "(the bell body is not part of this shape as read)". Confirm the floor shape and that collision equals outline for every attachment.
11. `LecternBlock`: the third desk box (0,14,9.666667,16,18,14) has y max 18, above the cell; confirm the numbers and the key (facing) of the yaw (24-7 10.2).
12. `ShulkerBoxBlock`: the lid `progress` (0 to 1) and `facing` values for each lid state and the animation steps belong to the block entity (31-1 13.5) and the shulker entity helpers, which are not specified in the documents read; `progress` per lid status is not tabulated.
13. Classes marked "full cube default" whose documents state no shape and no override (so the default `Block.getShape` is assumed): `GrassBlock`, `SnowyBlock`, `MyceliumBlock`, `NyliumBlock`, `SandBlock`, `ColoredFallingBlock`, `BrushableBlock`, `ConcretePowderBlock`, `GlazedTerracottaBlock`, `SlimeBlock` and `HalfTransparentBlock`, `TargetBlock`, `BeehiveBlock`, `RedstoneLampBlock`, `RedStoneOreBlock`, `RespawnAnchorBlock`, `CryingObsidianBlock`, `WeatheringCopperFullBlock`, `WeatheringCopperGrateBlock`, `CopperBulbBlock`, `CommandBlock`, `ObserverBlock`, `CoralBlock`. 24-6 section 4 and 24-7 section 10 state the default rule ("default shape unless stated") but do not confirm each class.
14. `MovingPistonBlock`: the carried state's shape is computed from the block entity fields (24-2 5.8, 30-3 7.5); the thread-local no-clip direction and the entity-push code that sets it are in 30-3 8.3 (not consolidated here). A table lookup cannot hold this shape.
15. `LiquidBlock` collision for entity classes other than players and Strider: only `LivingEntity` (empty) and `Strider` (half-height column) are known.
16. `AttachedStemBlock` east and west boxes: the document states `rotateHorizontal(boxZ(4,0,10,0,10))` and the north box (6,0,0,10,10,10); the east, south and west boxes in R-F19 are derived with section 2.1 (not stated in the document).
