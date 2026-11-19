# Block shapes: collision and outline rules of the standard world type (consolidated)

| Item | Value |
|---|---|
| Covers | The per-block-state collision shape and outline (targeting) shape of every block class of the standard world type, written as rules by family and property so that an implementer can build a lookup table; the player-collision expectations that follow from them |
| Sources | First round: documents consolidated, no artifact read (R4 then read the jar, see the Method row): `24-block-registry-1` (section 4.4 offsets, section 5.2 derived values, section 6 shape model, section 14 classes), `24-block-registry-2` (sections 2.6, 2.7, 6, 7.8, 7.11, 8), `24-block-registry-3` (section 5, 7), `24-block-registry-4` (sections 2.4, 5.2, 6), `24-block-registry-5` (sections 6, 7), `24-block-registry-6` (sections 4, 6), `24-block-registry-7` (sections 4 to 14), `24-block-registry-8` (sections 4, 5), `29a-fluids` (section 1.2 and 1.3), `29b-falling-growth-fire-2/3/4/7` (shape lines), `30-redstone-1/3/4/5/6` (shape lines), `31-block-entities-1` (section 13.4 and 13.5), `13-client-gameplay-and-controls` (section 1), `18-mob-framework` (section 3.3), `42-particles-1` (section 4.4 resolver), `29-block-updates-and-placement` (placement context). `12-client-rendering` states no block shape; `31-block-entities-2 to 8` and `30-redstone-2, 7, 8` add no further box |
| Method | Consolidation of existing documents (the first round), then a jar-reading round "R4" (clean-room reader). Round R4: static reading of the shipped bytecode (`javap`, no execution) of `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`), classes `BlockBehaviour`, its `BlockStateBase` (initCache and the shape queries), `Block` (`box`, `boxZ`, `column`, `cube`, `boxes`), `Shapes` (`rotate*`, the `BLOCK_CENTER` origin, `or`, `join`), `ClipContext` (and `$Block`, `$Fluid`), `BlockGetter.clip`, `Entity` (`pick`, `collide`, the step-up helpers), `Player.maybeBackOffFromEdge`, `EntityCollisionContext` (and `$Empty`), `PositionCollisionContext`, `MinecartCollisionContext`, `LiquidBlock`, `LivingEntity`, `Strider`, the block classes named in section 3.8, `ShulkerBoxBlockEntity`, `Shulker`, `PistonMovingBlockEntity`, `LevelExtractor.extractBlockOutline`, `LevelRenderer`, `Blocks` (property chains) and `BlockStateProperties`. Sections and rows marked "R4" were read in that round; unmarked rules are the consolidation of the first round and, where the R4 sections say so, were re-checked against the jar. Where documents disagree or are silent the gap is an entry of the Open questions, not a guess. Formulas marked "derived" were computed here from the rotation rules of section 2.4 applied to boxes the documents state |
| Scope | Shape only, plus (R4) the light and occlusion data of the blocks that were open (section 3.8) and the rules that derive occlusion, support and visual shapes from the outline (section 1.8.1), the collision contexts (1.8.2), the targeting algorithm (1.8.3) and the collision step with step-up (6.1). Sturdiness is named only where it differs from the collision or outline shape in a way the documents state |

## 1. Conventions

### 1.1 Units and boxes

- Pixel units: each axis runs 0 to 16 across the block cell (24-1 6.2). A box is written (x1,y1,z1,x2,y2,z2) with x1<x2, y1<y2, z1<z2. x grows east, y grows up, z grows south; north is small z.
- A shape is a list of boxes whose union is the shape. Boxes of one shape may overlap. An empty shape is the empty list. Boxes may leave the cell (a value below 0 or above 16, for example the long piston arm to z 20, the fence collision to y 24, the pitcher crop to y -1).
- Helper boxes used in the tables (24-1 6.2, 24-4 2.4): `column(s,y1,y2)` = (8-s/2, y1, 8-s/2, 8+s/2, y2, 8+s/2); `column(sx,sz,y1,y2)` = (8-sx/2, y1, 8-sz/2, 8+sx/2, y2, 8+sz/2); `cube(s)` = a box of side s centred on (8,8,8). Tables give the resulting numbers, so these are only for reading the source documents.
- Generic collision rule (24-1 5.2): the collision shape of a state is its outline shape when the block has collision, else the empty shape; a class may override it. The outline is the targeting shape in this document; the targeting algorithm is section 1.8.3 (R4).

### 1.2 Collision shape versus outline shape

- Every state has two shapes: the collision shape (entity movement) and the outline shape (`getShape`, targeting and, for non-collision blocks, the only shape). Tables below give both; "same" in the outline column means equal to the collision column.
- The `noCollision` flag (column 16 of the registry rows, which also clears the can-occlude flag) makes the collision shape empty and leaves the outline unchanged. Examples: torches, buttons, levers, plates, signs, rails, redstone wire, plants. A block with the flag still has an outline and can be targeted.
- The flag is not the last word: a class may override its collision shape. R4 (read in `BlockBehaviour`): the default collision shape of a state is its outline shape when the block's `hasCollision` flag is set and the empty shape when it is not (`noCollision()` clears `hasCollision`); a class that overrides `getCollisionShape` never consults the flag. The classes that declare their own collision shape (complete list read from the jar: every class of the block package and `piston`) are `BambooStalkBlock`, `BellBlock`, `BigDripleafBlock`, `CactusBlock`, `ComposterBlock`, `CrossCollisionBlock` (fences and panes), `FenceGateBlock`, `GrindstoneBlock`, `HoneyBlock`, `LecternBlock`, `LiquidBlock`, `MossyCarpetBlock`, `MudBlock`, `PitcherCropBlock`, `PowderSnowBlock`, `ScaffoldingBlock`, `SculkShriekerBlock`, `SkullBlock`, `SnowLayerBlock`, `SoulSandBlock`, `WallBlock`, `WallHangingSignBlock` and `MovingPistonBlock` (through its block entity). Examples of an override of a `noCollision` row: `scaffolding` (rule R-C20), `wall_hanging_sign` (rule R-C9), `pitcher_crop` (rule R-F13: the lower half really is solid, the boxes of R-F13 are returned for every state of the lower half; the answer to former Open question 5). The flag `noOcclusion` alone keeps the collision shape (ladder, lanterns, campfires, glass-like blocks).
- A shape can also differ between collision and outline without the flag. Rules that do this are marked in the "collision" column: fences, fence gates and walls (collision 24 high), snow layers (one layer lower), cactus (15 high), sculk shrieker (outline full cube, collision half), mud and soul sand (collision 14 high), honey (collision shrunk), composter (collision is the empty bin), big dripleaf (collision is the leaf only), bamboo stalk (thin collision), lectern, and so on.
- Open or closed state can empty a collision shape: an open fence gate has no collision (24-5 7.18). A full dripleaf (tilt full) has none (24-8 5.2). An open trapdoor or door keeps a collision shape, a thin panel (rules R-B6, R-B7).

### 1.3 Fluids

- `water` and `lava` (`LiquidBlock`) have an empty outline (24-1 section 14, 29a 1.2). Their collision is the empty shape except in the cases of rule R-A3 (source lava a Strider can stand on; the "always collide with fluid" context). `bubble_column`, `void_air`, `cave_air` and `air` are empty in both shapes.
- The fluid itself has a shape: for a fluid state of amount `n` (1 to 8; source 8 counts as height 8/9) the own height is n/9 of a block; the height is 1.0 when the cell above holds the same fluid; the shape is the box (0,0,0,16,16*height,16) (29a 1.3). That box is the fluid shape, not the block shape. R4: the targeting step does use it when the pick asks for fluids (section 1.8.3).
- `waterlogged` never changes a block shape in any rule below (fences, walls, panes, stairs, slabs, trapdoors and the others say so; the states differ only in the fluid reported). A double slab and a block that is not `SimpleWaterlogged` cannot be waterlogged.

### 1.4 The XZ and XYZ model offset

- Blocks flagged `offset:XZ` or `offset:XYZ` (column 16) are moved by an offset that depends only on the block position (24-1 4.4, 24-2 2.7, 24-5 6.1). With `getSeed(x,0,z)`: take h = (x*3129871 as a 32-bit product widened to 64 bits) XOR (z*116129781 in 64 bits) XOR y, where y is 0; then seed = (h*h*42317861 + h*11) >> 16 with 64-bit wrap-around and an arithmetic shift. Both types use y = 0.
- dx = clamp(((seed AND 15)/15 - 0.5)*0.5, -m, m); dz = clamp((((seed >> 8) AND 15)/15 - 0.5)*0.5, -m, m); m = maximum horizontal offset, default 0.25 block. For `XYZ` only: dy = (((seed >> 4) AND 15)/15 - 1.0) * v, with v = maximum vertical offset, default 0.2 (so dy lies between -0.2 and 0). The division by 15 is done in 32-bit float and then widened (24-2 2.7); the clamp bounds are the float 0.25 widened. Offsets are in blocks (multiply by 16 for pixels).
- Exceptions to the limits: pointed dripstone and sulfur spike use m = 0.125 (24-8 4.4); small dripleaf is `XYZ` with v = 0.1 (24-8 4.4). No other override of m or v is stated (24-5 6.1 states that no class overrides m).
- Blocks with `offset:XZ`: the fifteen flowers (and `wither_rose`), `tall_seagrass`, `sunflower`, `lilac`, `rose_bush`, `peony`, `tall_grass`, `large_fern`, `pitcher_plant`, `bamboo_sapling`, `bamboo`, `warped_roots`, `crimson_roots`, `nether_sprouts`, `hanging_roots`, `open_eyeblossom`, `closed_eyeblossom`, `mangrove_propagule`, `pointed_dripstone`, `sulfur_spike`. Blocks with `offset:XYZ`: `short_grass`, `fern`, `short_dry_grass`, `tall_dry_grass`, `small_dripleaf` (24-2 5, 24-5 3, 24-6 7.2, 24-7 17, 24-8 7.1, 29b-4).
- Where the offset is applied (corrected in R4; the first round assumed that every offset block moves its shapes, which the jar contradicts). The offset function is evaluated by `BlockState.getOffset(pos)`, and the jar has exactly these callers in the game logic: the `getShape` of `FlowerBlock` (so also `WitherRoseBlock` and `EyeblossomBlock`, which inherit it), the `getShape` and the `getCollisionShape` of `BambooStalkBlock`, the `getShape` of `BambooSaplingBlock`, the `getShape` of `SpeleothemBlock` (`pointed_dripstone`, `sulfur_spike`) and the `getShape` of `MangrovePropaguleBlock`: each returns its authored box moved by the offset vector. All of these blocks are `offset:XZ` (section 1.4 list), so the moved amount is in x and z only. The client classes `ModelBlockRenderer` and `SectionRenderDispatcher` also reference `getOffset` (inferred: they shift the drawn **model** of every offset block; their code was not read), and `LevelRenderer` applies it to the block-break crack overlay (read: it translates the pose by the offset before drawing the crack model); the other classes of the jar that contain the name (`Bee$BeePollinateGoal`, `ServerboundSetStructureBlockPacket`, `ServerGamePacketListenerImpl`, `DataCommands`, `RegionFile`, the `Blender` output buffer, `LanServerDetection`, `MenuTooltipPositioner`, `SectionRenderDispatcher`) were not traced and are inferred to be unrelated or rendering-only. The list of classes that contain the name was taken from the whole jar (string search of every class file). Consequence, the rule of this document: **only the five families above have shifted outline and collision shapes; every other offset block (`short_grass`, `fern`, `short_dry_grass`, `tall_dry_grass`, `tall_grass`, `large_fern`, the four tall flowers, `pitcher_plant`, `tall_seagrass`, `small_dripleaf`, `warped_roots`, `crimson_roots`, `nether_sprouts`, `hanging_roots`) keeps its authored box unshifted for collision, targeting and the outline, although its model is drawn shifted.** The outline the client draws is the unshifted `getShape` box, so for those blocks it is not centred on the drawn model. Both halves of a tall plant get the same offset (for rendering) because the seed ignores y (former Open questions 1 and 3: answered; the seed of the offset is `Mth.getSeed(x, 0, z)` for both halves, 29b-4's lower-half-y seed concerns model variants only).
- Limits (R4, read): the defaults of `Block.getMaxHorizontalOffset` and `getMaxVerticalOffset` are the floats 0.25 and 0.2; the only overrides are `SpeleothemBlock` (horizontal limit from its constant `MAX_HORIZONTAL_OFFSET`, 0.125 as 24-8 states) and `SmallDripleafBlock` (vertical limit 0.1). So `short_grass`, `fern`, `short_dry_grass` and `tall_dry_grass` use the default vertical limit 0.2 (former Open question 1, second part).
- A block with collision and an offset type is marked `dynamicShape` (24-1 4.4): `bamboo`, `pointed_dripstone`, `sulfur_spike`.

### 1.5 What a shape depends on

- Almost every shape is a function of the block state's properties only. Connection booleans (fence, wall, pane, bars, tripwire, vine, redstone wire, chorus plant) are stored in the state; the neighbours are consulted only when the state is computed (placement and shape update), never when the shape is read.
- Shapes that read something beyond the properties:
  - position: every offset block (section 1.4);
  - the block entity: `shulker_box` and `moving_piston` (rules R-E16, R-E27; section 3.8);
  - the querying entity or the placer (the "collision context"): `scaffolding` (holds scaffolding item; entity above; descending), `light` (holds the light item), `powder_snow` (fall distance, boots, above), `water`/`lava` (rules R-A3), `moving_piston` (piston no-clip direction);
  - the cell above: none directly; `wall` reads it when the state is computed (tall or low arms), the shape reads only the state.
- Collision-context helpers as far as the documents define them: the placement context carries `descending` = the player's descending flag, `isHoldingItem` = main-hand item, `entityBottom` = the player's current y (the lowest double when there is no player), placement flag true, no entity, `alwaysCollideWithFluid` false (29 9.6). The context built for a particle (42-1 4.4) has no entity, `isDescending` false, `canStandOnFluid` false and `isAbove(shape, pos)` true when the context y exceeds (cell y + shape max y - 9.999999747378752E-6). The helper for entities and the other contexts are defined in section 1.8.2 (R4; former Open question 7).

### 1.6 Properties, directions and cardinal facts used by the rules

- Directions: north = -z, east = +x, south = +z, west = -x, up = +y, down = -y. Clockwise and counter-clockwise are seen from above: clockwise(north) = east, clockwise(east) = south, clockwise(south) = west, clockwise(west) = north; counter-clockwise is the reverse.
- Property value lists and defaults are in the registry parts; this document names only the properties that a shape consults.

### 1.7 Out of scope for the lookup

Block-support, occlusion and visual shapes differ from the outline for some blocks (fence arms 2 wide for occlusion, `leaves` empty support, iron bars empty visual shape, soul sand and mud full support shape, chorus flower support `(1,0,1,15,15,15)`). They are not needed for movement or targeting and are in the registry parts. R4 adds the rules that derive them (section 1.8.1) and the data for the blocks that were open (section 3.8).

### 1.8 Shape queries, collision contexts and targeting (R4)

Read in the source artifact named in the header (`BlockBehaviour`, `BlockStateBase`, `EntityCollisionContext`, `ClipContext`, `BlockGetter`, `Entity`).

#### 1.8.1 The shape queries, their defaults and the light data derived from them

A block class answers up to eight shape queries. Defaults (`BlockBehaviour`) and the complete list of classes that override each one (read from every class of the block package and `piston`):

| Query | Default | Overridden by |
|---|---|---|
| `getShape(state, level, pos, context)` (outline) | the full cube | the classes of section 3 |
| `getCollisionShape(state, level, pos, context)` | `getShape` when the block's `hasCollision` is set, else empty | see section 1.2 |
| `getOcclusionShape(state)` | `getShape` evaluated with an empty block getter, position (0,0,0) and the empty context (1.8.2) | `FenceBlock`, `FenceGateBlock`, `LecternBlock`, `SculkShriekerBlock` |
| `getBlockSupportShape(state, level, pos)` | `getCollisionShape` with the empty context | `CeilingHangingSignBlock`, `ChorusFlowerBlock`, `FenceGateBlock`, `LeavesBlock`, `MudBlock`, `ShulkerBoxBlock`, `SnowLayerBlock`, `SoulSandBlock`, `WallHangingSignBlock` |
| `getVisualShape(state, level, pos, context)` | `getCollisionShape` with the given context | `FenceBlock`, `IronBarsBlock`, `MudBlock`, `PowderSnowBlock`, `SnowLayerBlock`, `SoulSandBlock`, `TransparentBlock` |
| `getInteractionShape(state, level, pos)` | the empty shape | `AbstractCauldronBlock` (all cauldrons), `ComposterBlock`, `HopperBlock`, `ScaffoldingBlock` |
| `getEntityInsideCollisionShape(state, level, pos, entity)` | the full cube | `EndPortalBlock`, `LavaCauldronBlock`, `LayeredCauldronBlock`, `PowderSnowBlock`, `TripWireBlock` |
| `useShapeForLightOcclusion(state)` | false | `DaylightDetectorBlock`, `EnchantingTableBlock`, `EndPortalFrameBlock`, `FarmlandBlock`, `LecternBlock`, `PathBlock`, `SculkSensorBlock`, `SculkShriekerBlock`, `ShelfBlock`, `SlabBlock` (not `double`), `SnowLayerBlock`, `StairBlock`, `StonecutterBlock`, `PistonHeadBlock` (true), `PistonBaseBlock` (`extended`) |

Every class not named in a row uses the default of that row. R4 checked, class by class, the classes whose documents gave only a "default shape" statement (former Open question 13: the grass, sand, ore, copper, command, spawner, container, furnace, workstation, ice, sculk, amethyst and similar full blocks): none declares any of these queries, except `LeavesBlock` (support shape only) and `TransparentBlock` (visual shape only), so for every other block class not named in section 3 the outline, collision (when `hasCollision`), occlusion and support shape is the full cube. The only classes with their own shape methods that section 3 did not already name were `BaseFireBlock` (rule R-D22, re-read and equal) and the piston classes (R-E25 to R-E27).

The per-state light and culling data is computed once for every state when the block registry is built (`initCache`), also for a `dynamicShape` block (only the collision-shape cache, `isSolid` and the large-shape flag are skipped for it):

1. `canOcclude` is the block flag (cleared by `noOcclusion()`).
2. `occlusionShape` = the empty shape when `canOcclude` is false, else `getOcclusionShape(state)` (default: the outline evaluated with the empty context and an empty world, so a context-dependent outline gives the shape of its context-free branch: for `scaffolding` the unstable shape when `bottom` is true, else the stable shape; for a shulker box the full cube, which `noOcclusion` then discards).
3. `solidRender` = the occlusion shape is exactly the full cube.
4. `occlusionShapesByFace[d]` = six empty shapes when the occlusion shape is empty; six full squares when `solidRender`; else `getFaceShape(d)` of the occlusion shape (rule below).
5. `propagatesSkylightDown` = the block's rule (default: the state's outline evaluated as in item 2 is not the full cube **and** the state's fluid is empty; overrides in 32 section 7).
6. `lightDampening` = the block's rule (default: 15 when `solidRender`, else 0 when `propagatesSkylightDown`, else 1; overrides: `LeavesBlock`, `TintedGlassBlock`).

`getFaceShape(d)` of a shape (a shape in this document is a union of boxes): empty for the empty shape, the full square for the full cube; otherwise take the **cross-section of the shape at the plane 1e-7 inside the cell on side d** (the plane y = 1e-7 for down, y = 1 - 1e-7 for up, and likewise for the other axes) and project it on the face; a shape that fills its whole range 0 to 1 along the axis of d is its own face. The result is empty when no box reaches that plane. The light engine uses these faces only for states with `useShapeForLightOcclusion` true (32 section 2.1); a state with the flag false takes part in light with its dampening alone. Worked example: the lectern (occlusion shape `(0,0,0,16,2,16)` plus `(4,2,4,12,14,12)`): the down face is the full square, the up face is empty (the shape ends at y = 14), each of the four side faces is the rectangle 16 wide and 2 high (the foot plate; the column starts 4 inside).

#### 1.8.2 Collision contexts (former Open questions 7 and 15)

The `context` argument of the queries is one of these (read, `CollisionContext`, `EntityCollisionContext`, `$Empty`, `PositionCollisionContext`, `MinecartCollisionContext`):

| Context | Built by | descending | held item | `isAbove(shape, pos, flag)` | `alwaysCollideWithFluid` | `canStandOnFluid(fluidAbove, ownFluid)` |
|---|---|---|---|---|---|---|
| entity context | `CollisionContext.of(entity)` (flag false) and `of(entity, flag)` (the flag becomes `alwaysCollideWithFluid`); the placement variant of 29 9.6 sets `placement` true | `entity.isDescending()` | the main-hand stack when the entity is a living entity, else empty | `entityBottom > cellY + shape.maxY - 9.999999747378752E-6`, where `entityBottom` is `entity.getY()` read when the context was built (the feet, not the box); the boolean argument is ignored | the flag | true when the entity is a `LivingEntity`, its `canStandOnFluid(ownFluid)` is true and the two fluid types are not the same fluid |
| empty context | `CollisionContext.empty()` | false | empty | returns **the boolean argument** (the entity-bottom is -Double.MAX_VALUE and is not used) | false (`emptyWithFluidCollisions()`: true) | false (no entity) |
| position context | `CollisionContext.positionContext(y)` (the particle engine, 42-1 4.4) | false | empty | `y > cellY + shape.maxY - 9.999999747378752E-6` | false | false |
| minecart context | `CollisionContext.of(entity)` when the entity is a minecart with the "experimental movement" setting on | as the entity context | as the entity context | as the entity context | false | as the entity context |

The minecart context only changes the collision shape: when the minecart's cell (or the rail below it) holds a rail, the cell below that rail returns the empty shape, and when that rail is a slope, one horizontal neighbour of the rail cell returns the empty shape too (the switch on the slope shape maps its four cases to the neighbours east, west, north and south in that order; which slope shape belongs to which case was not traced, inferred to be the ascending side; Open question 17).

Entity classes: `LivingEntity.canStandOnFluid` returns false and `LivingEntity.getLiquidCollisionShape` returns the empty shape; the only override of either in the jar is `Strider` (stands on a fluid in the tag `lava`; liquid collision shape `(0,0,0,16,8,16)`). So every entity class other than `Strider` has an empty liquid collision shape and cannot stand on a fluid; the shapes of `water` and `lava` blocks are as rule R-A3. `isDescending` is the entity's own method; for the picking context of 1.8.3 and for scaffolding it is the sneak state (the method was not traced further, see Open question 17).

#### 1.8.3 Targeting (picking) and the drawn outline (former Open questions 4 and 6)

1. The client picks with `Entity.pick(range, partialTick, withFluid)`: the segment runs from the eye position (at `partialTick`) along the view vector for `range` blocks, and the clip context is (`OUTLINE`, fluid mode `ANY` when `withFluid` else `NONE`, the entity). `range` is the caller's (the player's block interaction range, not read here).
2. `BlockGetter.clip` walks the cells of the segment in order and for each cell computes a block hit and a fluid hit; the first cell with a hit ends the walk (inferred: the walk returns the first non-null cell result; the cell traversal helper `traverseBlocks` was not read).
3. Block hit: the block shape is `getShape(context)` for `OUTLINE` (`getCollisionShape(context)` for `COLLIDER`, `getVisualShape(context)` for `VISUAL`; `FALLDAMAGE_RESETTING` is the full cube for a state in the tag `fall_damage_resetting`, a full cube for end gateway and end portal when the context's entity is a player, a full cube for a nether portal when the context's level is a server level whose game rule `players_nether_portal_default_delay` is 0 and the entity is a player, and the empty shape otherwise). The ray is clipped against the shape's boxes (moved to the cell). If the ray hits the shape, the **interaction shape** (1.8.1) is clipped too; when it is hit strictly nearer to the ray's origin (squared distance), the result keeps the outline hit (its position) and takes the interaction hit's **face** (direction). If the outline is not hit, the interaction shape is never consulted (so it can only change which face is reported, never create a target). With the interaction shapes of 3.8: looking into a cauldron from above the reported face comes from the inside box; the composter and scaffolding full-cube interaction shapes make every face of the block reachable even when the outline has holes (the composter's bin) and the hopper's cavity and stub refine the face.
4. Fluid hit: the fluid state's shape (the box of 1.3, `FluidState.getShape`) when the fluid mode accepts the fluid state: `NONE` accepts none, `SOURCE_ONLY` accepts source states only (inferred from the predicate order), `ANY` accepts every non-empty fluid state, `WATER` accepts states in the tag `water`; otherwise the empty shape. The cell's result is the block hit or the fluid hit, whichever is nearer to the origin (squared distance), **the block hit when the distances are equal**. A pick with `withFluid` false (the usual attack and use pick) never reports a fluid; a bucket-style pick does.
5. The block outline the client draws is, for the targeted cell when its state is not air and the position is inside the world border: `getShape(level, pos, CollisionContext.of(cameraEntity))` (the camera entity's context, so a scaffolding outline is the full cube while the camera entity holds a scaffolding item); the other three shapes (collision, occlusion, interaction) are drawn only when the debug-shapes switch of the shared constants is on. Offset blocks draw the unshifted `getShape` box except the five families of section 1.4.

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
| R-A3 | `air`, `void_air`, `cave_air`, `bubble_column`, `water`, `lava` (`LiquidBlock`) | `level` (liquid) | air and bubble column: always. Liquid: collision rules below | none, except liquid cases | none (empty) | `LiquidBlock` collision, in this order (24-1 sec. 14, 29a 1.2): (1) the full cube when the context says "always collide with fluid"; (2) empty when `level` is not 0; (3) when `level` is 0 and the context is a living entity that is above the shape and may stand on the fluid: that entity's liquid shape. The Strider alone may stand on lava (a `column(16,0,8)` = (0,0,0,16,8,16), only source lava); otherwise empty. R4 (read, `LiquidBlock.getCollisionShape`): step (3) is exactly: the context is an entity context whose entity is a `LivingEntity`; the entity's liquid collision shape `S` (`LivingEntity`: empty; `Strider`: (0,0,0,16,8,16); no other class overrides it) is kept only when `isAbove(S, pos)` (1.8.2: the entity's feet y is above cell y + S.maxY - 9.999999747378752E-6) **and** `canStandOnFluid(fluid in the cell above, this block's fluid)` holds (the entity's own `canStandOnFluid(this fluid)`, true only for a Strider on lava, **and** the fluid above is not the same fluid type); else empty. So every other entity class collides with no fluid block (former Open questions 7 and 15 and 24-1 open question 11: answered). A non-entity context (empty, position) always gives the empty shape in step (3) |
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
| R-C19 | `BellBlock` | `attachment`, `facing` | by attachment | Bell body B = (5,6,5,11,13,11) + (4,4,4,12,6,12). Ceiling: B + (7,13,7,9,16,9). Floor: frame only, facing axis z (0,0,4,16,16,12), axis x (4,0,0,12,16,16). Double wall: B + (7,13,0,9,15,16) for axis z, (0,13,7,16,15,9) for axis x. Single wall: B + (7,13,0,9,15,13) yawed to key `facing` | same | Outline and collision equal (`getCollisionShape` and `getShape` both return the same lookup). R4 re-read: B, the four attachment shapes and the axis keys are exactly as written; the floor shape really is the frame only (a 16 wide, 16 high, 8 deep box, no bell body) for every `facing` of an axis, the `attachment` order is `floor`, `ceiling`, `single_wall`, `double_wall`, and `floor` and `double_wall` look the shape up by the **axis** of `facing` while `single_wall` looks it up by the direction (former Open question 10: answered). Light data: section 3.8.4 |
| R-C20 | `ScaffoldingBlock` | `bottom`, `distance`; context | see notes | Placing: none. Entity above the full block and not descending: stable shape. Otherwise, with `distance` not 0, `bottom` true and the entity above the block one below: (0,0,0,16,2,16). Else none | Context holds scaffolding item: full cube. Else `bottom`: unstable; else stable | Stable = (0,14,0,16,16,16) + corner posts (0,0,0,2,16,2), (14,0,0,16,16,2), (14,0,14,16,16,16), (0,0,14,2,16,16). Unstable = stable + (0,0,0,16,2,16) + bottom edge beams (0,0,0,16,2,2), (14,0,0,16,2,16), (0,0,14,16,2,16), (0,0,0,2,2,16). The interaction shape is the full cube. The row flag is `noCollision` (24-7 11.4). R4 re-read: all boxes, the context test order and the "entity above" tests are exactly as stated; "the entity above the full block" is `isAbove(full cube, pos)` of 1.8.2 and "the entity above the block one below" is `isAbove(the full cube moved down one cell, pos)`, i.e. the feet are higher than cell y - 1e-5 (cell y plus the moved shape's top 0, minus 9.999999747378752E-6); with the empty context (no entity, which is what `BlockState.getCollisionShape(level, pos)` without a context uses) the "above" tests return true and `isDescending` is false, so the collision shape is the stable shape for every state. The block is also `dynamicShape` (no shape cache), `isValidSpawn` false and not a redstone conductor. Light data: section 3.8.5 |
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
| R-E5 | `LecternBlock` | `facing` | collision versus outline | (0,0,0,16,2,16) + (4,2,4,12,14,12) | collision + desk boxes authored north (0,10,1,16,14,5.333333), (0,12,5.333333,16,16,9.666667), (0,14,9.666667,16,18,14), yawed to key `facing` | The third desk box reaches y 18, above the cell. R4 re-read: the numbers are exact as written (the desk boxes are `boxZ(16,10,14,1,5.333333)`, `boxZ(16,12,16,5.333333,9.666667)`, `boxZ(16,14,18,9.666667,14)` where 5.333333 and 9.666667 are the six-decimal constants themselves, not exact thirds; the union with the collision shape `column(16,0,2)` + `column(8,2,14)`, then `rotateHorizontal`: the key is `facing`, authored for north). The y 18 is real, not an error (former Open question 11: answered). `getOcclusionShape` is the collision shape (symmetric, not keyed) and `useShapeForLightOcclusion` is true (section 3.8.6) |
| R-E6 | `HopperBlock` | `facing` (down, north, south, west, east) | body plus spout | Body (0,10,0,16,16,16) + (4,4,4,12,10,12) minus the cavity (2,11,2,14,16,14), plus the spout of `facing`: north (6,4,0,10,8,8); east (8,4,6,16,8,10); south (6,4,8,10,8,16); west (0,4,6,8,8,10); down (6,0,6,10,6,10). R4: section 3.8.1 gives the body as six boxes and confirms every number, the down spout included | same (`getShape` = collision); the separate **interaction shape** (cavity plus a stub) only refines the face of a hit, it is not the targeting shape (section 1.8.3; former Open question 4: answered) | R4: the down spout is read (it is the north spout turned about the point (8,6,8) and clipped to the cell), no longer derived (24-5 open question 6: answered). `enabled` ignored |
| R-E7 | `AnvilBlock` (anvil, chipped, damaged) | `facing` (axis only) | by axis | Axis z (facing north or south): (2,0,2,14,4,14) + (4,4,3,12,5,13) + (6,5,4,10,10,12) + (3,10,0,13,16,16). Axis x (facing east or west): (2,0,2,14,4,14) + (3,4,4,13,5,12) + (4,5,6,12,10,10) + (0,10,3,16,16,13) | same | |
| R-E8 | `CauldronBlock`, `LavaCauldronBlock`, `LayeredCauldronBlock` (water, powder snow) | none for the shape (`level` ignored) | always | Full cube minus (0,0,4,16,3,12), (4,0,0,12,3,16), (2,0,2,14,3,14) and the inside (2,4,2,14,16,14) | same | Leaves four corner legs in y 0 to 3 and 2-wide walls above y 4; the floor spans y 3 to 4. Entity-inside shape adds the content box up to y 6+3*level (water, powder snow) or 15 (lava); not a collision. R4: confirmed for all four blocks and every `level` (the shape ignores `level`); the decomposition into boxes, the per-variant entity-inside shapes, the interaction shape and the light data are in section 3.8.2 |
| R-E9 | `BrewingStandBlock` | none | always | (7,2,7,9,14,9) + (1,0,1,15,2,15) | same | |
| R-E10 | `ComposterBlock` | `level` (0 to 8) | collision versus outline | Collision: the level-0 bin | Outline: the full cube minus the box (2, f, 2, 14, 16, 14) where f = floor top: level 0: 2; 1: 3; 2: 5; 3: 7; 4: 9; 5: 11; 6: 13; 7 and 8: 15 | Collision uses the level-0 shape (f = 2) at every level. The interaction shape is the full cube. R4: confirmed exactly (floor f = clamp(1 + 2 * level, 2, 16) for level 0 to 7, level 8 reuses the level-7 shape; `level` runs 0 to 8); decomposition and light data in section 3.8.3 |
| R-E11 | `GrindstoneBlock` | `face`, `facing` | by face | Wall, key north (support to the south): legs (2,6,7,4,10,16), (2,5,3,4,11,9), (12,6,7,14,10,16), (12,5,3,14,11,9), wheel (4,2,0,12,14,12). Floor, north: (2,0,6,4,9,10), (2,7,5,4,13,11), (12,0,6,14,9,10), (12,7,5,14,13,11), wheel (4,4,2,12,16,14). Ceiling, north: (2,7,6,4,16,10), (2,3,5,4,9,11), (12,7,6,14,16,10), (12,3,5,14,9,11), wheel (4,0,2,12,12,14). Other facings: yaw | same | Derived by the attach-face transforms of section 2.4 (24-7 10.1). R4: the wall/north boxes are read exactly as written (legs and their `INVERT_X` mirror, wheel `boxZ(8,2,14,0,12)`), `getShape` = `getCollisionShape` = the lookup by (`face`, `facing`), and the floor and ceiling transforms are the group elements named in section 2.4 (floor `BLOCK_ROT_X_270`, ceiling `BLOCK_ROT_Y_180` composed with `BLOCK_ROT_X_90`); section 3.8.7 lists all twelve shapes |
| R-E12 | `StonecutterBlock` | none | always | (0,0,0,16,9,16) | same | |
| R-E13 | `EndPortalFrameBlock` | `eye` | by `eye` | `eye` false: (0,0,0,16,13,16). `eye` true: that + (4,13,4,12,16,12) | same | |
| R-E14 | `DragonEggBlock` | none | always | (1,0,1,15,16,15) | same | |
| R-E15 | `ConduitBlock` | none | always | (5,5,5,11,11,11) | same | `cube(6)` |
| R-E16 | `ShulkerBoxBlock` | `facing`, block entity lid progress | by progress | Closed: full cube. Otherwise the unit cube extended by 0.5*progress block along `facing` (progress 0 to 1) | same | Without a block entity: full cube. Not a function of the state alone (24-6 6.12, 31-1 13.5). R4 (former Open question 12: answered): the shape is the box of section 3.8.8, a function of `facing` and the block entity's lid `progress`; the outline equals the collision shape because the block declares no `getCollisionShape` and has `hasCollision`; the support shape, the light data and the agreement with 31-1 13 and 52 section 4 are in 3.8.8 |
| R-E17 | `DecoratedPotBlock` | none | always | (1,0,1,15,16,15) | same | |
| R-E18 | `HeavyCoreBlock` | none | always | (4,0,4,12,8,12) | same | |
| R-E19 | `CopperGolemStatueBlock`, `WeatheringCopperGolemStatueBlock` | none | always | (3,0,3,13,14,13) | same | |
| R-E20 | `FlowerPotBlock` (`flower_pot`, all `potted_*`) | none | always | (5,0,5,11,6,11) | same | |
| R-E21 | `ShelfBlock` (all shelves) | `facing` | key = `facing` | Union authored north: (0,0,13,16,16,16), (0,12,11,16,16,13), (0,0,11,16,4,13); yaw | same | |
| R-E22 | `CakeBlock` | `bites` (0 to 6) | by bites | (1+2*bites, 0, 1, 15, 8, 15) | same | |
| R-E23 | `SculkSensorBlock`, `CalibratedSculkSensorBlock` | none | always | (0,0,0,16,8,16) | same | |
| R-E24 | `SculkShriekerBlock` | none | always | (0,0,0,16,8,16) | (0,0,0,16,16,16) | |
| R-E25 | `PistonBaseBlock` (`piston`, `sticky_piston`) | `extended`, `facing` | by `extended` | Not extended: full cube. Extended: authored north (0,0,4,16,16,16); `rotateAll`: south (0,0,0,16,16,12); west (4,0,0,16,16,16); east (0,0,0,12,16,16); down (0,4,0,16,16,16); up (0,0,0,16,12,16) | same | The extended body is 12 thick, flush with the back. R4 re-read: `boxZ(16,4,16)` then `rotateAll`, the key is `facing`, collision = outline; `useShapeForLightOcclusion` = `extended` (section 3.8.10) |
| R-E26 | `PistonHeadBlock` | `facing`, `short` | union of platform and arm | Platform authored north (0,0,0,16,16,4); arm (6,6,4,10,10,20) when `short` false or (6,6,4,10,10,16) when `short` true; `rotateAll`. South: platform (0,0,12,16,16,16), arm (6,6,-4,10,10,12) / (6,6,0,10,10,12). West: platform (0,0,0,4,16,16), arm (4,6,6,20,10,10) / (4,6,6,16,10,10). East: platform (12,0,0,16,16,16), arm (-4,6,6,12,10,10) / (0,6,6,12,10,10). Down: platform (0,0,0,16,4,16), arm (6,4,6,10,20,10) / (6,4,6,10,16,10). Up: platform (0,12,0,16,16,16), arm (6,-4,6,10,12,10) / (6,0,6,10,12,10) | same | The long arm extends 4 outside the cell on the back side. Documented in 30-3 9.2. R4 re-read: platform `boxZ(16,0,4)`, short arm `boxZ(4,4,16)`, long arm `boxZ(4,4,20)`, `rotateAll`, key `facing`; the shape ignores `type` (normal or sticky); `useShapeForLightOcclusion` is true (section 3.8.10) |
| R-E27 | `MovingPistonBlock` | block entity | see notes | Empty with no block entity. Else: `base` union the carried state's collision shape shifted by the movement offset, exactly as 30-3 section 7.5; restated with the numbers in section 3.8.9 (R4: read and found equal to 30-3 7.5) | none (empty, read: `getShape` returns the empty shape for every state) | Dynamic (`dynamicShape`, no shape cache); not a function of the state |

### 3.6 Plants and growing blocks

| Id | Class or keys | Properties consulted | Condition | Collision | Outline | Notes |
|---|---|---|---|---|---|---|
| R-F1 | `SaplingBlock` (all saplings) | none | always | none | (2,0,2,14,12,14) | |
| R-F2 | `MangrovePropaguleBlock` | `age` (0 to 4), `hanging` | by hanging | none | Column 2 by 2 (7 to 9 in x and z) from y = M to 16 where M = 13, 10, 7, 3, 0 for age 0 to 4 when `hanging`; M = 0 when not `hanging`; moved by the XZ offset | |
| R-F3 | `FlowerBlock` (the 14 flowers), `WitherRoseBlock` | none | always | none | (5,0,5,11,10,11) moved by the XZ offset | |
| R-F4 | `EyeblossomBlock` | none | always | none | (5,0,5,11,10,11) moved by the XZ offset | |
| R-F5 | `TallGrassBlock` (`short_grass`, `fern`) | none | always | none | (2,0,2,14,13,14), **not** moved (R4 correction: the model is drawn with the XYZ offset, the shape is not; section 1.4) | 24-2 section 6; the shape per 29b-4 is `column(12,0,13)`; R4: `getShape` returns the constant box |
| R-F6 | `DryVegetationBlock` (`dead_bush`) | none | always | none | (2,0,2,14,13,14) | |
| R-F7 | `BushBlock` (`bush`, `red_shrub`) | none | always | none | (0,0,0,16,13,16) | |
| R-F8 | `ShortDryGrassBlock` | none | always | none | (2,0,2,14,10,14), not moved (R4 correction, section 1.4) | |
| R-F9 | `TallDryGrassBlock` | none | always | none | (1,0,1,15,16,15), not moved (R4 correction, section 1.4) | |
| R-F10 | `SeagrassBlock` | none | always | none | (2,0,2,14,12,14) | |
| R-F11 | `TallSeagrassBlock` | `half` (shape the same for both) | always | none | (2,0,2,14,16,14), not moved (R4 correction, section 1.4) | |
| R-F12 | `TallFlowerBlock` (sunflower, lilac, rose bush, peony), `DoublePlantBlock` (`tall_grass`, `large_fern`, `pitcher_plant`) | none (`half` ignored) | always | none | (0,0,0,16,16,16), not moved (R4 correction, section 1.4) | No shape override (24-5 7.17, 24-6 6.7). R4 (former Open question 2: answered): `DoublePlantBlock` and `TallFlowerBlock` declare no `getShape`, so the full cube is real, for both halves and every tall plant, `pitcher_plant` included; no tighter shape exists in the jar |
| R-F13 | `PitcherCropBlock` | `age` (0 to 4), `half` | by half | Lower half only: age 0 (5,-1,5,11,3,11); ages 1 to 4 (3,-1,3,13,5,13). Upper half none. | Let a = 4 + 0 for age 0 else 6 + T[age] with T = (0, 9, 11, 22, 26) giving a = 4, 15, 17, 28, 32; width w = 6 for age 0 else 10 (box x and z from 8-w/2 to 8+w/2). Lower half: x and z from 8-w/2 to 8+w/2, y from -1 to min(16, a-1) (tops 3, 14, 16, 16, 16); upper half: same x and z, y from 0 to max(0, a-1-16) (tops 0, 0, 0, 11, 15) | The row flag is `noCollision`; the lower-half collision above is stated by 24-6 6.7 and 29b-2 (former Open question 5: answered by R4, `PitcherCropBlock.getCollisionShape` returns the lower-half box for every state of the lower half, the age-0 bulb box when `age` is 0, and the empty shape for the upper half; the outline formula above was re-read exactly, the upper half being `column(w, 0, max(0, a-1-16))`). Ages 0 to 2 never have an upper half |
| R-F14 | `CropBlock` (`wheat`) | `age` (0 to 7) | by age | none | (0,0,0,16,2+2*age,16) | Heights 2, 4, 6, 8, 10, 12, 14, 16 |
| R-F15 | `CarrotBlock`, `PotatoBlock` | `age` (0 to 7) | by age | none | (0,0,0,16,2+age,16) | Heights 2 to 9 |
| R-F16 | `BeetrootBlock` | `age` (0 to 3) | by age | none | (0,0,0,16,2+2*age,16) | Heights 2, 4, 6, 8 |
| R-F17 | `TorchflowerCropBlock` | `age` (0 to 1) | by age | none | (5,0,5,11,6+4*age,11) | |
| R-F18 | `StemBlock` (`pumpkin_stem`, `melon_stem`) | `age` (0 to 7) | by age | none | (7,0,7,9,2+2*age,9) | |
| R-F19 | `AttachedStemBlock` | `facing` | key = `facing` | none | Authored north (6,0,0,10,10,10); east (6,0,6,16,10,10); south (6,0,6,10,10,16); west (0,0,6,10,10,10) | `rotateHorizontal(boxZ(4,0,10,0,10))`; the east, south and west boxes are derived with section 2.1. R4 re-read: `boxZ(4,0,10,0,10)` then `rotateHorizontal`, looked up by `facing`, so the derived boxes are exact (former Open question 16: answered) |
| R-F20 | `NetherWartBlock` | `age` (0 to 3) | by age | none | (0,0,0,16,5+3*age,16) | Heights 5, 8, 11, 14 |
| R-F21 | `MushroomBlock` (`brown_mushroom`, `red_mushroom`) | none | always | none | (5,0,5,11,6,11) | |
| R-F22 | `CocoaBlock` | `age` (0 to 2), `facing` | key = `facing` | by age (authored north) | Authored north: age 0 (6,7,1,10,12,5); age 1 (5,5,1,11,12,7); age 2 (4,3,1,12,12,9); yaw by `facing` | Formula in 24-4 6.23; the boxes are those computed in the document |
| R-F23 | `ShelfMushroomBlock` | `age` (0, 1), `facing` | key = `facing` | same (the row carries `noOcclusion` only; the block bounces entities) | Union authored north: age 0 cap (3,9,9,13,11,16) + stem (5,8,12,11,9,16); age 1 cap (1,8,6,15,11,16) + stem (4,6,10,12,8,16); yaw | |
| R-F24 | `KelpBlock` | none | always | none | (0,0,0,16,9,16) | `kelp_plant` is R-A2 |
| R-F25 | `SweetBerryBushBlock` | `age` (0 to 3) | by age | none | age 0 (3,0,3,13,8,13); ages 1 and 2 (1,0,1,15,16,15); age 3 (0,0,0,16,16,16) | |
| R-F26 | `NetherFungusBlock` | none | always | none | (4,0,4,12,9,12) | |
| R-F27 | `NetherRootsBlock` | none | always | none | (2,0,2,14,13,14), not moved (R4 correction, section 1.4) | |
| R-F28 | `NetherSproutsBlock` | none | always | none | (2,0,2,14,3,14), not moved (R4 correction, section 1.4) | |
| R-F29 | `WeepingVinesBlock` (head), `WeepingVinesPlantBlock`, `TwistingVinesBlock`, `TwistingVinesPlantBlock` | none | by block | none | weeping head (4,9,4,12,16,12); weeping plant (1,0,1,15,16,15); twisting head (4,0,4,12,15,12); twisting plant (4,0,4,12,16,12) | |
| R-F30 | `CaveVinesBlock`, `CaveVinesPlantBlock` | none | always | none | (1,0,1,15,16,15) | |
| R-F31 | `SporeBlossomBlock` | none | always | none | (2,13,2,14,16,14) | |
| R-F32 | `AzaleaBlock` (`azalea`, `flowering_azalea`) | none | always | (0,8,0,16,16,16) + (6,0,6,10,8,10) | same | The row does not carry `noCollision` |
| R-F33 | `HangingRootsBlock` | none | always | none | (2,10,2,14,16,14), not moved (R4 correction, section 1.4) | |
| R-F34 | `HangingMossBlock` | `tip` | by tip | none | tip (1,2,1,15,16,15); base (1,0,1,15,16,15) | |
| R-F35 | `SmallDripleafBlock` | none (`half`, `facing` ignored) | always | none | (2,0,2,14,13,14), not moved (R4 correction, section 1.4; the model's vertical offset limit is 0.1) | |
| R-F36 | `BigDripleafBlock` | `tilt`, `facing` | by tilt | Leaf: none or unstable (0,11,0,16,15,16); partial (0,11,0,16,13,16); full none | Leaf shape + stem. Stem: the box (5,0,9,11,13,15) authored north, yawed to key `facing` | Stem = `column(6,0,13)` moved 4 pixels in z |
| R-F37 | `BigDripleafStemBlock` | `facing` | key = `facing` | none | (5,0,9,11,16,15) authored north, yawed | |
| R-F38 | `FlowerBedBlock` (pink petals, wildflowers), `LeafLitterBlock` | `facing`, amount (`flower_amount` or `segment_amount`) | n quarters | none | One box that encloses the union of the first n quarter pads; quarter i (i from 0) is (0,0,0,8,h,8) yawed by `facing` turned counter-clockwise i times; h = 3 for flower beds, 1 for leaf litter | Derived result for `facing` north: n = 1 (0,0,0,8,h,8); n = 2 (0,0,0,8,h,16); n = 3 or 4 (0,0,0,16,h,16). R4 (former Open question 9: answered): the shape is built by `SegmentableBlock.getShapeCalculator` (the union of n quarter pads, then one enclosing box, as stated) with the quarter `box(0,0,0,8,H,8)`; `H` is `getShapeHeight()`: the `FlowerBedBlock` constructor argument, which is 3 for both `pink_petals` and `wildflowers`, and the interface default 1.0 for `leaf_litter`; so 24-8 is right and 29b-4's "3 for both" is wrong for leaf litter |
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
| R-G3 | `RespawnAnchorBlock`, `CryingObsidianBlock`, `TargetBlock`, `BeehiveBlock`, `JukeboxBlock`, `NoteBlock`, `TntBlock`, `SpongeBlock`, `WetSpongeBlock`, `ChiseledBookShelfBlock`, `CreakingHeartBlock`, `MagmaBlock`, `NetherrackBlock`, `GrassBlock`, `SnowyBlock`, `MyceliumBlock`, `NyliumBlock`, `SandBlock`, `ColoredFallingBlock`, `BrushableBlock`, `ConcretePowderBlock`, `GlazedTerracottaBlock`, `PoweredBlock`, `HayBlock`, `CarvedPumpkinBlock`, `PumpkinBlock`, `RedStoneOreBlock`, `RedstoneLampBlock`, `WeatheringCopperFullBlock`, `WeatheringCopperGrateBlock`, `WeatheringCopperBulbBlock`, `CopperBulbBlock`, `StructureBlock`, `FrostedIceBlock`, `LeavesBlock` family | none | always | full cube | same | Documents state a full cube or "default shape" for these classes (24-2 section 6, 24-3 5.2, 24-5 7.9, 24-8 4.1); a few are only covered by the general default; R4 confirmed the default for every one of them from the jar (section 1.8.1; former Open question 13: answered) |
| R-G4 | `WeatheringCopperDoorBlock`, `WeatheringCopperTrapDoorBlock`, `WeatheringCopperStairBlock`, `WeatheringCopperSlabBlock`, `WeatheringCopperBarsBlock`, `WeatheringCopperChainBlock`, `WeatheringLightningRodBlock`, `WeatheringLanternBlock`, `WeatheringCopperChestBlock`, `WeatheringCopperGolemStatueBlock` | as the base class | as the base class | as R-B6, R-B7, R-B2, R-B1, R-B8, R-B9, R-B11, R-C17, R-E1, R-E19 | same | The weathering stage never changes a shape |

### 3.8 R4: the blocks that were open, read from the jar

Source: the classes named in each subsection (the artifact of the header). Notation as in section 1: pixel boxes (x1,y1,z1,x2,y2,z2), unions, y up, z south. "Light data" is the tuple of 1.8.1: `canOcclude` (no `noOcclusion()` in the block's property chain, read from `Blocks`), `useShapeForLightOcclusion`, occlusion shape, `propagatesSkylightDown`, `lightDampening`.

#### 3.8.1 Hopper (`HopperBlock`)

- Constants: cavity `Cv` = `column(12,11,16)` = (2,11,2,14,16,14); bowl `column(16,10,16)` = (0,10,0,16,16,16); funnel `column(8,4,10)` = (4,4,4,12,10,12).
- Body = (bowl union funnel) minus `Cv`. As boxes: (0,10,0,16,11,16); (0,11,0,2,16,16); (14,11,0,16,16,16); (2,11,0,14,16,2); (2,11,14,14,16,16); (4,4,4,12,10,12).
- Spout `boxZ(4,4,8,0,8)` = (6,4,0,10,8,8) for the north key, turned about the point (8,6,8) (not the cell centre) with the six-direction rule of 2.2, then **intersected with the full cube** (the part outside the cell is cut): north (6,4,0,10,8,8); east (8,4,6,16,8,10); south (6,4,8,10,8,16); west (0,4,6,8,8,10); down: the turned box is (6,-2,6,10,6,10) and the cut gives (6,0,6,10,6,10). `facing` takes five values (`up` is not allowed).
- Outline = collision = body union spout(`facing`), for both values of `enabled` (the shape table is built per `enabled` but the two entries are equal).
- Interaction shape (`getInteractionShape`): `Cv` union a stub; the stub is `boxZ(4,8,10,0,4)` = (6,8,0,10,10,4) for north, turned about the cell centre by the horizontal key `facing`: east (12,8,6,16,10,10); south (6,8,12,10,10,16); west (0,8,6,4,10,10); for `facing` = down the interaction shape is `Cv` alone. It is used only as in 1.8.3 item 3.
- Light data: `noOcclusion` is set, so `canOcclude` false, occlusion shape empty, `useShapeForLightOcclusion` false, `propagatesSkylightDown` true, `lightDampening` 0.

#### 3.8.2 Cauldrons (`AbstractCauldronBlock`, `CauldronBlock`, `LavaCauldronBlock`, `LayeredCauldronBlock`)

Four blocks: `cauldron` (empty), `water_cauldron` (`LayeredCauldronBlock`, rain), `powder_snow_cauldron` (`LayeredCauldronBlock`, snow) and `lava_cauldron`. `level` of the layered cauldrons runs 1 to 3.

- Outline = collision (every block, every `level`) = the full cube minus `A` = (0,0,4,16,3,12), `B` = (4,0,0,12,3,16), `C` = (2,0,2,14,3,14) and `I` = (2,4,2,14,16,14). As boxes: the corner legs, each an L of two boxes: (0,0,0,4,3,2), (0,0,2,2,3,4), (12,0,0,16,3,2), (14,0,2,16,3,4), (0,0,14,4,3,16), (0,0,12,2,3,14), (12,0,14,16,3,16), (14,0,12,16,3,14); the floor (0,3,0,16,4,16); the rim walls (0,4,0,16,16,2), (0,4,14,16,16,16), (0,4,2,2,16,14), (14,4,2,16,16,14). (So the legs are L-shaped, the 2 by 2 inner corner of each is open; 51's earlier "four corner legs" is this.)
- Interaction shape (all four): `I` = (2,4,2,14,16,14).
- Entity-inside collision shape (`getEntityInsideCollisionShape`; not a collision, used to test whether an entity stands in the content): `cauldron`: the default full cube (the class declares none); `water_cauldron` and `powder_snow_cauldron`: the outline union (2,4,2,14,Y,14) with Y = 6 + 3 * `level`: level 1 gives 9, level 2 gives 12, level 3 gives 15; `lava_cauldron`: the outline union (2,4,2,14,15,14). Content height as a fraction of a block (`getContentHeight`): layered (6 + 3 * `level`) / 16, lava 0.9375 (15/16).
- Block properties (`Blocks`): `cauldron` has `requiresCorrectToolForDrops`, strength 2.0 and `noOcclusion`; the three others are `ofLegacyCopy` of it (so `noOcclusion` too); `lava_cauldron` adds a light level function that returns 15 (read in the lambda; the emission is 15 for every state).
- Light data: `canOcclude` false, occlusion shape empty, `useShapeForLightOcclusion` false, `propagatesSkylightDown` true, `lightDampening` 0 (all four blocks; `lava_cauldron` also emits 15).

#### 3.8.3 Composter (`ComposterBlock`)

- `level` runs 0 to 8. Floor top `f` by `level` (the hole is `column(12, f, 16)` = (2,f,2,14,16,14), `f` = clamp(1 + 2 * `level`, 2, 16)): level 0: 2; 1: 3; 2: 5; 3: 7; 4: 9; 5: 11; 6: 13; 7: 15; level 8 uses the level-7 shape (f = 15).
- Outline = the full cube minus the hole, as boxes: the floor (0,0,0,16,f,16) and the rim walls (0,f,0,16,16,2), (0,f,14,16,16,16), (0,f,2,2,16,14), (14,f,2,16,16,14). Collision = the level-0 outline for every `level` (f = 2). Interaction shape = the full cube.
- Light data: `canOcclude` true (no `noOcclusion`), `useShapeForLightOcclusion` false, occlusion shape = the outline of the state (not the full cube), `propagatesSkylightDown` true, `lightDampening` 0 for every `level`.

#### 3.8.4 Bell (`BellBlock`)

Attachments (enum order `floor`, `ceiling`, `single_wall`, `double_wall`). Bell body `B` = (5,6,5,11,13,11) union (4,4,4,12,6,12). Outline = collision.

| `attachment` | Lookup key | Shape |
|---|---|---|
| `floor` | axis of `facing` | the frame alone, `cube(16,16,8)`: axis z (`facing` north or south) (0,0,4,16,16,12); axis x (`facing` east or west) (4,0,0,12,16,16) |
| `ceiling` | none | `B` union (7,13,7,9,16,9) |
| `single_wall` | `facing` | `B` union the arm: north (7,13,0,9,15,13); east (3,13,7,16,15,9); south (7,13,3,9,15,16); west (0,13,7,13,15,9) |
| `double_wall` | axis of `facing` | `B` union the bar: axis z (7,13,0,9,15,16); axis x (0,13,7,16,15,9) |

Light data: `forceSolidOn`, no `noOcclusion`: `canOcclude` true, `useShapeForLightOcclusion` false (so the engine ignores the shape), occlusion shape = the outline (not full), `propagatesSkylightDown` true, `lightDampening` 0.

#### 3.8.5 Scaffolding (`ScaffoldingBlock`)

Properties `distance` 0 to 7, `bottom`, `waterlogged`. Block chain: `noCollision`, `dynamicShape`, `isValidSpawn` never, `isRedstoneConductor` never, push reaction popped. Boxes: `Stable` = (0,14,0,16,16,16) plus the posts (0,0,0,2,16,2), (14,0,0,16,16,2), (14,0,14,16,16,16), (0,0,14,2,16,16); `Plate` = (0,0,0,16,2,16); `Unstable` = `Stable` union `Plate` union the four edge beams (0,0,0,16,2,2), (14,0,0,16,2,16), (0,0,14,16,2,16), (0,0,0,2,2,16) (the beams lie inside `Plate`; the union equals `Stable` union `Plate`).

- Outline (`getShape`): the full cube when the context holds a scaffolding item (`isHoldingItem` of the block's item, 1.8.2), else `Unstable` when `bottom` is true, else `Stable`.
- Collision (`getCollisionShape`), first match: (1) the context is a placement context: empty; (2) the context says it is above the full cube (`isAbove(full cube, pos)`) and is not descending: `Stable`; (3) otherwise, when `distance` is not 0 and `bottom` is true and the context is above the full cube moved one cell down (feet above the cell's own y minus 9.999999747378752E-6): `Plate`; (4) otherwise empty. With the empty context (no entity) test (2) is true (its boolean argument is returned) and descending is false, so `Stable`.
- Interaction shape: the full cube.
- Light data: `canOcclude` true, `useShapeForLightOcclusion` false, occlusion shape `Unstable` when `bottom` else `Stable` (evaluated with the empty context), `propagatesSkylightDown` true unless `waterlogged` (then false), `lightDampening` 0 (1 when waterlogged).

#### 3.8.6 Lectern (`LecternBlock`)

Shapes as rule R-E5. Collision = occlusion shape = `Coll` = (0,0,0,16,2,16) union (4,2,4,12,14,12), for every state. Outline = `Coll` union the three desk boxes, keyed by `facing`. Light data: `canOcclude` true, `useShapeForLightOcclusion` **true**, occlusion shape `Coll`, `propagatesSkylightDown` true, `lightDampening` 0. Face shapes of `Coll` (derived with the 1.8.1 rule): down the full square; up empty; north, south, east, west each the 16 by 2 rectangle along the foot plate (x 0 to 16 and y 0 to 2 for north and south, z 0 to 16 and y 0 to 2 for east and west).

#### 3.8.7 Grindstone (`GrindstoneBlock`)

Authored for `face` = wall, `facing` = north: legs (2,6,7,4,10,16) and (2,5,3,4,11,9), their mirror in x (12,6,7,14,10,16) and (12,5,3,14,11,9), wheel (4,2,0,12,14,12). The tip is by `face` (2.4: wall none; floor (x,y,z) to (x,16-z,y); ceiling (x,y,z) to (16-x,z,y)), then the yaw of 2.1 by `facing` (the yaw is applied after the tip; the wheel must stay an upright disc for every `facing`, which only that order gives: inferred from the shapes, the composition order of the group elements was not independently re-derived). Outline = collision. All twelve shapes (legs a, b, mirrored legs c, d, wheel w):

| `face` | `facing` | Legs and wheel |
|---|---|---|
| wall | north | (2,6,7,4,10,16) (2,5,3,4,11,9) (12,6,7,14,10,16) (12,5,3,14,11,9); w (4,2,0,12,14,12) |
| wall | east | (0,6,2,9,10,4) (7,5,2,13,11,4) (0,6,12,9,10,14) (7,5,12,13,11,14); w (4,2,4,16,14,12) |
| wall | south | (12,6,0,14,10,9) (12,5,7,14,11,13) (2,6,0,4,10,9) (2,5,7,4,11,13); w (4,2,4,12,14,16) |
| wall | west | (7,6,12,16,10,14) (3,5,12,9,11,14) (7,6,2,16,10,4) (3,5,2,9,11,4); w (0,2,4,12,14,12) |
| floor | north | (2,0,6,4,9,10) (2,7,5,4,13,11) (12,0,6,14,9,10) (12,7,5,14,13,11); w (4,4,2,12,16,14) |
| floor | east | (6,0,2,10,9,4) (5,7,2,11,13,4) (6,0,12,10,9,14) (5,7,12,11,13,14); w (2,4,4,14,16,12) |
| floor | south | (12,0,6,14,9,10) (12,7,5,14,13,11) (2,0,6,4,9,10) (2,7,5,4,13,11); w (4,4,2,12,16,14) |
| floor | west | (6,0,12,10,9,14) (5,7,12,11,13,14) (6,0,2,10,9,4) (5,7,2,11,13,4); w (2,4,4,14,16,12) |
| ceiling | north | (12,7,6,14,16,10) (12,3,5,14,9,11) (2,7,6,4,16,10) (2,3,5,4,9,11); w (4,0,2,12,12,14) |
| ceiling | east | (6,7,12,10,16,14) (5,3,12,11,9,14) (6,7,2,10,16,4) (5,3,2,11,9,4); w (2,0,4,14,12,12) |
| ceiling | south | (2,7,6,4,16,10) (2,3,5,4,9,11) (12,7,6,14,16,10) (12,3,5,14,9,11); w (4,0,2,12,12,14) |
| ceiling | west | (6,7,2,10,16,4) (5,3,2,11,9,4) (6,7,12,10,16,14) (5,3,12,11,9,14); w (2,0,4,14,12,12) |

(The numbers of the floor and ceiling rows and of the east, south and west rows are computed here from the authored boxes with the formulas above (derived). As unions the floor and ceiling rows depend only on the axis of `facing` (north and south give the same union, east and west the same), not on the composition order of the group elements; the only inferred part is which axis the wheel takes (north and south: thick along x, east and west: thick along z); the north rows of floor and ceiling and the wall-north row agree with the former R-E11 text.) Light data: block chain `requiresCorrectToolForDrops`, strength, push reaction immovable (no `noOcclusion`): `canOcclude` true, `useShapeForLightOcclusion` false, occlusion shape = the outline of the state, `propagatesSkylightDown` true, `lightDampening` 0.

#### 3.8.8 Shulker box (`ShulkerBoxBlock`, `ShulkerBoxBlockEntity`, `Shulker`) (former Open question 12)

- State and block entity: the block has `facing` (six values; the box opens toward it). The block entity holds `progress` and `progressOld` (floats, 0 to 1), an animation status (0 `closed`, 1 `opening`, 2 `opened`, 3 `closing`) and an `openCount`. Rules, evaluated once per tick on client and server: `progressOld` takes the previous `progress`; `closed` keeps `progress` 0; `opened` keeps it 1; `opening` adds 0.1 and, once it reaches at least 1, clamps to 1 and switches to `opened`; `closing` subtracts 0.1 and, once it reaches at most 0, clamps to 0 and switches to `closed`. Neighbour updates run on the tick that leaves `progress` 0 (`progressOld` exactly 0 while opening), on the tick that reaches 1 or 0, and on the tick that leaves 1 (`progressOld` exactly 1 while closing). Only `opening` pushes entities (below). Block event 1 with count n sets `openCount` = n; n = 0 sets `closing`, n = 1 sets `opening`, any other n leaves the status. `getProgress(t)` = lerp(t, `progressOld`, `progress`) in floats; `isClosed` = status `closed`. A full open or close takes 10 ticks: float sums reach 1.0000001 on opening tick 10 (clamped to 1) and -7.45e-08 on closing tick 10 (clamped to 0), values as in the 31-1 section 14 example.
- Outline = collision (`getShape` has no separate collision, `hasCollision` is set): with a block entity of this type, the box `Shulker.getProgressAabb(1.0, facing, e, (0.5,0,0.5))` with `e` = `0.5f * getProgress(1.0f)` = half the current-tick progress (no interpolation: `lerp(1.0, old, new)` is the current `progress` up to float rounding); without one, the full cube. Meaning of the helper (`s` = 1, `d` = the step of `facing`): start from the box (-0.5, 0, -0.5) to (0.5, 1, 0.5), grow it along `facing` by `e` (a positive step moves the max side, a negative step the min side), then move it by (0.5, 0, 0.5). In pixels, with `q` = 8 * `progress` (so `q` runs 0 to 8 while the lid opens), the shape by `facing`: up (0,0,0,16,16+q,16); down (0,-q,0,16,16,16); north (0,0,-q,16,16,16); south (0,0,0,16,16,16+q); east (0,0,0,16+q,16,16); west (-q,0,0,16,16,16). `progress` 0 (closed) gives exactly the full cube; `progress` 1 (open) extends the box by 8 pixels (half a block) beyond the cell on the lid side. Examples: facing up, `progress` 0.5: (0,0,0,16,20,16); facing west, `progress` 1: (-8,0,0,16,16,16).
- Support shape (`getBlockSupportShape`): the full cube when there is no block entity or the status is closed; else the thin plate on the side **opposite** `facing`: key = opposite(`facing`) of `boxZ(16,0,1)` turned by the six-direction rule: key north (0,0,0,16,16,1); east (15,0,0,16,16,16); south (0,0,15,16,16,16); west (0,0,0,1,16,16); up (0,15,0,16,16,16); down (0,0,0,16,1,16). So an open box facing up supports only through its bottom 1 pixel. (This is the table 31-1 section 13.5 said was not read.)
- Entity push and the "can open" test use the swept slab `getProgressDeltaAabb(1.0, facing, a, b, bottom centre of the block)`: the same start box grown along `facing` by max(a, b) blocks, then shrunk back from the cell side by 1 + min(a, b) blocks, then moved to the cell: it is the slab beyond the cell's face on the lid side between the distances min(a, b) and max(a, b) from that face (facing up: x and z over the whole cell, y from 16 * (1 + min) to 16 * (1 + max) pixels). Pushing (opening ticks only): the entities whose push reaction is not "ignore entity" inside the slab for (a, b) = (`progressOld`, `progress`) **as stored (not halved)** are moved with `MoverType.SHULKER_BOX` by (slab size along each axis + 0.01) times the step of `facing`; so each opening tick pushes by about 0.11 block while the box and the lid rise by only 0.05 (the factor 0.5 exists only in the outline and collision box: read as it is, reproduce it as it is). `canOpen` for a closed box uses the slab for (0.0, 0.5): (facing up) x and z over the cell, y 16 to 24 pixels, deflated by 1e-6, and requires no collision in it (31-1 section 13.4).
- Agreement with 31-1 section 13 and 52 section 4: the status machine and the 0.1 per tick step are 31-1 13.2 and 13.3; the renderer of 52 4.4 uses the interpolated `progress` p (lerp at the frame's partial tick) for the lid rise 8 * p model pixels (that is half a block times p, the same extension as the box's 0.5 * `progress`) and for the lid turn p * 270 degrees; the box does not depend on the turn. The box uses the current tick's progress, the renderer the interpolated one, so between ticks the drawn lid is up to 0.1 progress behind or ahead of the box.
- Light data: block chain `forceSolidOn`, `dynamicShape`, `noOcclusion`, `isSuffocating` = closed, push reaction popped: `canOcclude` false (occlusion shape empty), `useShapeForLightOcclusion` false, `propagatesSkylightDown` **false** (override), `lightDampening` 1.

#### 3.8.9 Moving piston (`MovingPistonBlock`, `PistonMovingBlockEntity`)

Outline: the empty shape for every state (so a moving piston can never be targeted). Collision: the block entity's `getCollisionShape(level, pos)`, or the empty shape when there is no block entity. That function was read and is equal to 30-3 section 7.5 (the four steps there are exact: `base`; the `NOCLIP` test; the head of `short` = `extending` is not equal to `1 - progress < 0.25`; the shift by `step(direction) * extendedProgress`, with `extendedProgress` = `progress - 1` when extending and `1 - progress` when not, in floats). Example (extending source piston, facing up, `progress` 0.5): `base` is empty; the head is short (true is not equal to false); the shift is -0.5 block = -8 pixels along y; the collision is the short head (platform (0,12,0,16,16,16), arm (6,0,6,10,12,10)) moved down 8 pixels: (0,4,0,16,8,16) and (6,-8,6,10,4,10). Light data: `forceSolidOn`, `dynamicShape`, `noOcclusion`: `canOcclude` false, occlusion shape empty, `useShapeForLightOcclusion` false, `propagatesSkylightDown` true (the outline is empty, not the full cube), `lightDampening` 0.

#### 3.8.10 Piston base and head light data (`PistonBaseBlock`, `PistonHeadBlock`)

Block chain of the bases (`pistonProperties`): strength 1.5, an `isRedstoneConductor` predicate (a lambda, not traced here), `isSuffocating` = not extended, push reaction immovable; the head: strength, no loot table, push reaction immovable; neither has `noOcclusion`, so `canOcclude` is true for both.

| State | Occlusion shape | `useShapeForLightOcclusion` | `lightDampening` | Face shapes (derived with the 1.8.1 rule), facing north |
|---|---|---|---|---|
| base, `extended` false | the full cube | false | 15 | six full squares |
| base, `extended` true | (0,0,4,16,16,16) | true | 0 | south (the back) full; north (the front) empty; up, down, east, west each a 16 by 12 rectangle flush with the back (for up and down: x 0 to 16, z 4 to 16; for east and west: y 0 to 16, z 4 to 16) |
| head, any `short`, `type` | platform (0,0,0,16,16,4) union the arm | true | 0 | north (the platform side) full; south the 4 by 4 square x 6 to 10, y 6 to 10 (both arm lengths reach the south plane); up, down, east, west each a 16 by 4 rectangle flush with the north side (z 0 to 4) |

For other `facing` values the faces turn with the shape (the facing side, the back side and the four others follow the rows above). `propagatesSkylightDown` is true for the three non-full rows (no fluid) and false for the first (full cube), which is what the 15 follows from.

#### 3.8.11 Summary of the light data of the R4 blocks

| Block | `canOcclude` | `useShapeForLightOcclusion` | Occlusion shape | `propagatesSkylightDown` | `lightDampening` |
|---|---|---|---|---|---|
| `cauldron`, `water_cauldron`, `powder_snow_cauldron`, `lava_cauldron` | false | false | empty | true | 0 (`lava_cauldron` emits 15) |
| `hopper` | false | false | empty | true | 0 |
| `bell` | true | false | the outline | true | 0 |
| `scaffolding` | true | false | `Stable` or `Unstable` (by `bottom`) | not `waterlogged` | 0, or 1 when `waterlogged` |
| `composter` | true | false | the outline by `level` | true | 0 |
| `grindstone` | true | false | the outline | true | 0 |
| `lectern` | true | true | `Coll` (3.8.6) | true | 0 |
| `piston`, `sticky_piston` | true | `extended` | full cube / (0,0,4,16,16,16) keyed | `extended` | 15 / 0 |
| `piston_head` | true | true | platform plus arm | true | 0 |
| `moving_piston` | false | false | empty | true | 0 |
| `shulker_box` and the 16 dyed boxes | false | false | empty | false | 1 |

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
17. `tall_grass` at block position (0, y, 0): outline (0,0,0,16,16,16), **not** moved (R4 correction: the offset only shifts the drawn model; the seed 0 offset would be dx = dz = -0.25, 4 pixels toward the north-west, in the model), collision none. `poppy` at the same position: outline (5,0,5,11,10,11) moved by (-4,0,-4) pixels = (1,0,1,7,10,7), collision none (a `FlowerBlock` shifts its shape).
18. `piston`, `extended=true`, `facing=up`: collision and outline (0,0,0,16,12,16). `piston_head`, `facing=up`, `short=false`: platform (0,12,0,16,16,16) plus arm (6,-4,6,10,12,10).
19. `redstone_wire`, `north=side`, `east=up`, others none: dot (3,0,3,13,1,13) plus north arm (3,0,0,13,1,8) plus the east arm turned from the north arm: (8,0,3,16,1,13), plus the east up strip (15,0,3,16,16,13); collision none.
20. `cake`, `bites=2`: (5,0,1,15,8,15) for collision and outline.
21. (R4) `water_cauldron`, `level=2`: collision and outline = the cauldron shape of 3.8.2 (floor (0,3,0,16,4,16), rim walls from y 4); entity-inside shape = that shape plus (2,4,2,14,12,14); content height 12/16 = 0.75; interaction shape (2,4,2,14,16,14). `lava_cauldron`: entity-inside plus (2,4,2,14,15,14), emission 15.
22. (R4) `composter`, `level=5`: outline = the full cube minus (2,11,2,14,16,14), i.e. floor (0,0,0,16,11,16) plus rim walls (0,11,0,16,16,2), (0,11,14,16,16,16), (0,11,2,2,16,14), (14,11,2,16,16,14); collision = the level-0 shape (floor to y 2, walls above); interaction shape = the full cube.
23. (R4) `hopper`, `facing=down`: collision and outline = the six body boxes of 3.8.1 plus (6,0,6,10,6,10); interaction shape (2,11,2,14,16,14) only. `facing=east`: spout (8,4,6,16,8,10); interaction shape (2,11,2,14,16,14) plus (12,8,6,16,10,10).
24. (R4) `shulker_box`, `facing=up`, opening, tick 3 (`progress` 0.3, `q` = 2.4): collision and outline (0,0,0,16,18.4,16); at `progress` 1 (open): (0,0,0,16,24,16); closed: the full cube. `facing=west`, `progress` 0.5: (-4,0,0,16,16,16). Open and `facing=up`: support shape (0,0,0,16,1,16).
25. (R4) `scaffolding`, `distance=0`, `bottom=false`: a walking player above it collides with the stable shape (top slab at y 14 to 16, four posts); the same player sneaking collides with nothing and sinks through (the plate rule needs `distance` not 0). With `distance=3`, `bottom=true`: a sneaking player whose feet are above the cell's own y collides with the plate (0,0,0,16,2,16). A player holding scaffolding sees and targets the full cube.
26. (R4) `bell`, `attachment=floor`, `facing=north` or `south`: (0,0,4,16,16,12) (frame only); `attachment=ceiling`: body (5,6,5,11,13,11) plus (4,4,4,12,6,12) plus (7,13,7,9,16,9); `attachment=single_wall`, `facing=east`: body plus (3,13,7,16,15,9).
27. (R4) `grindstone`, `face=floor`, `facing=east`: legs (6,0,2,10,9,4), (5,7,2,11,13,4), (6,0,12,10,9,14), (5,7,12,11,13,14), wheel (2,4,4,14,16,12).
28. (R4) `moving_piston` (extending source, `facing=up`, `progress` 0.5): outline empty; collision (0,4,0,16,8,16) plus (6,-8,6,10,4,10).
29. (R4) Step-up: the worked example at the end of 6.1 (a bottom slab ahead, `m` = (0.2, 0, 0): the result is (0.2, 0.5, 0)).

Player-collision expectations (the player box is 0.6 wide and 1.8 tall, 21 all-entities table):
- Standing on a bottom slab puts the feet at cell y + 0.5 (example 2). Standing on farmland puts them at 0.9375 (example 10). A path block is the same height.
- An open door is passable on the side of the cell that its panel does not occupy (example 6).
- A ladder is a 3-pixel panel with collision (example 7); the climbing behaviour is in 13 section 1.3. Its outline is the same panel.
- Torches, buttons, levers, plates, signs, banners, rails, redstone wire, flowers and grasses have no collision; they can be walked through and still can be targeted by the outline.
- Fences, walls and closed fence gates are 24 pixels (1.5 blocks) high for collision.

## 6. Entity movement, step-up and collision resolution (as far as the documents state them)

- Step height: 0.6 (`step_height` attribute default; 13 section 1.2). 13 section 1.3 step 3 only says "the move is performed (`Entity.move`, collision resolution, step up to 0.6)". 18 section 3.3 adds: `Entity.move` moves along each axis in the order y, then the larger of x and z (compared by absolute delta), with collision against block shapes and the world border, honouring the step height; it sets `onGround` (the vertical move was blocked while moving down), `horizontalCollision` and `verticalCollision`; "sneaking-off-edge protection applies to players only". 18 section 3.2 says: a collision blocked horizontally but passable if the entity rises by at most the step height is resolved by stepping up.
- The collide algorithm itself is written in 42-particles-1 section 4.4 (`Particle.move` resolver; the same `Entity.collideBoundingBox` shape pipeline without entities and without step-up): query box = the entity box expanded toward the delta; colliders = block collision shapes of the cells from floor(min - 1e-7) - 1 to floor(max + 1e-7) + 1 on each axis, corner cells skipped, margin cells only for large shapes (type 1) or a moving piston (type 2); a full-cube shape counts only if the query box intersects the cell, other shapes are moved to the cell and kept when non-empty and intersecting the query box. Axes are resolved one at a time in the order y, then x and z by the rule above (z first when |dx| < |dz|), skipping an axis whose delta is exactly 0, against the accumulated offset of the earlier axes. Each shape clips the running delta (`Shapes.collide`, `VoxelShape.collide`): a running |delta| below 1e-7 gives 0; the tolerance on the other two axes is 1e-7. `EPSILON` = 1.0E-7 and `BIG_EPSILON` = 1.0E-6 (24-1 6.2). Collision flags: x and z flags when requested and collided differ under a tolerant comparison, vertical flag when they differ exactly (41 3.3).
- The step-up algorithm is section 6.1 (R4). The sneaking-edge protection is 53 section 5 (R4 re-read `Player.maybeBackOffFromEdge`, `isAboveGround` and `canFallAtLeast` and found the preconditions, the 0.05 step and the probe box of 53 5.1 and 5.2 as stated there); the box sizes of the poses are 53. What is still not stated is in Open question 8.

### 6.1 The collision step with step-up (`Entity.collide`, R4) (former Open question 8, first part)

Inputs: the movement vector `m` = (mx, my, mz) that reached the collision step (after the edge protection of 53 section 5 and the piston limit of 30-3 8.3, when they apply), the entity's box `B`, `H` = `maxUpStep()` (a float: the `step_height` attribute, 0.6 for a player; 53 section 5.1 says when it is raised), the `onGround` flag, the level. `collideBoundingBox` is the shape pipeline of section 6, second bullet; `collideWithShapes(v, box, colliders)` resolves the axes of `v` one at a time in the axis order below, skipping an axis whose component is exactly 0, each time clipping the component with `Shapes.collide(axis, box moved by the already resolved components, colliders, component)`. **Axis order** (`Direction.axisStepOrder(v)`): Y first, then Z then X when |vx| < |vz|, else X then Z.

1. `E` = the collidable entities (`Level.getEntityCollisions`) in `B` expanded toward `m` and expanded upward by `H`.
2. `r` = `m` when `m` has length 0, else `collideBoundingBox(entity, m, B, level, E)`; its colliders are `E`, the world border's collision shape when the entity is close to the border (inside it but near enough), and the block collision shapes (`Level.getBlockCollisions`) found in `B` expanded toward `m`.
3. Blocked flags (exact double comparison): `xC` = mx differs from rx, `yC` = my differs from ry, `zC` = mz differs from rz; `down` = `yC` and my < 0.
4. A step is tried only when `H` > 0, and (`down` or `onGround`), and (`xC` or `zC`). Otherwise the result is `r`.
5. Step search space: `B0` = `B` lowered by -ry when `down` (moved by (0, ry, 0)), else `B`. Colliders `C` = `E` plus the border shape plus the block collision shapes inside `S`, where `S` = `B0` grown by mx in x, mz in z and `H` upward, and, when not `down`, also 9.999999747378752E-6 downward.
6. Candidate heights: for every shape in `C`, take the Y coordinates of its boxes (the planes where they start or end, world coordinates) in ascending order; `h` = the float of (coordinate - `B0`.minY). Keep `h` when `h` >= 0, `h` is not equal to the float of `ry`, and `h` <= `H`; the scan of a shape stops at its first coordinate with `h` > `H`. The kept values, without duplicates, are tried in ascending order.
7. For a candidate `h`, `v` = `collideWithShapes((mx, h, mz), B0, C)`. The candidate wins when the horizontal squared length of `v` is strictly greater than that of `r`; the result is then `v` with its y reduced by (`B`.minY - `B0`.minY) (when `down`: `v`.y + ry). The first winning candidate ends the search.
8. When no candidate wins the result is `r`.

The first candidate that gains horizontal travel is taken, so the step is the lowest sufficient ledge top (or bottom edge) within `H`, not always `H`. Worked example (player, `H` = 0.6, standing at y = 0, `onGround`, box x from 0.35 to 0.95; a bottom slab (collision (0,0,0,16,8,16), top 0.5) in the cell x 1 to 2, y 0 to 1; `m` = (0.2, 0, 0)): `r` = (0.05, 0, 0) (blocked by the slab at x = 1), `xC` true, step tried; the colliders' Y coordinates relative to `B0`.minY are -1 and 0 (the floor block, skipped: below 0 and equal to `dyr` = 0) and 0 and 0.5 (the slab: 0 skipped, 0.5 kept); candidate set {0.5}; `v` = (0.2, 0.5, 0) (up 0.5 is free, then x is free over the slab); 0.04 is greater than 0.0025, so the move is (0.2, 0.5, 0): the player is on the slab in the same tick. With a full block of height 1 in the same place the only candidate is 1.0 > `H`, none is kept, and the result is `r`.
- Still not read: the rest of `Entity.move` (how `onGround`, `horizontalCollision` and the other flags are set from `r`; 18 section 3.3 and 41 section 3.3 give them), `Level.getEntityCollisions` and `Level.getBlockCollisions` internals (the cell enumeration is 42-1 4.4), `Shapes.collide` internals (42-1).

## 7. Open questions

Each entry names the class or block key and what is missing. The orchestrator handles them separately. Numbers 1 to 16 are kept so that references stay valid: an entry marked "answered" was resolved by the jar-reading round R4 and points to the section that states the rule; the others are still open.

1. Offset application: answered (R4), section 1.4: only `FlowerBlock` (flowers, wither rose, eyeblossoms), `BambooStalkBlock`, `BambooSaplingBlock`, `SpeleothemBlock` and `MangrovePropaguleBlock` shift their shapes; every other offset block shifts only its model. The vertical limit of `short_grass`, `fern`, `short_dry_grass` and `tall_dry_grass` is the default 0.2.
2. Tall flowers and double plants: answered (R4), rule R-F12: the full cube is real.
3. Offset seed of a tall plant: answered (R4), section 1.4: `getSeed(x, 0, z)`, y fixed at 0, so both halves are the same.
4. Hopper targeting shape: answered (R4), sections 1.8.3 and 3.8.1: the outline is the targeting shape; the interaction shape only refines the reported face.
5. Collision overriding the `noCollision` flag: answered (R4), section 1.2 (complete list of overriding classes) and rule R-F13 (the pitcher crop's lower half is solid).
6. Targeting algorithm: answered (R4), section 1.8.3.
7. Collision context helpers: answered (R4), section 1.8.2. The meaning of `isDescending` for an entity that is not a player is open (17).
8. Step-up: answered (R4), section 6.1. Sneaking-edge protection and the poses' box sizes: 53. **Still open**: the rest of `Entity.move` as listed at the end of section 6.1 (flags and the order of the callers), the grid search inside `Shapes.collide` (42-1 open question 12).
9. Flower bed and leaf litter height: answered (R4), rule R-F38: 3 and 1.
10. Bell floor shape: answered (R4), rule R-C19 and section 3.8.4.
11. Lectern desk boxes: answered (R4), rule R-E5 and section 3.8.6.
12. Shulker box lid progress: answered (R4), section 3.8.8 (box as a function of `facing` and `progress`, the animation, the support shape, the agreement with 31-1 and 52).
13. Classes with only a default shape: answered (R4), section 1.8.1: all declare nothing, the defaults hold.
14. Moving piston shape: answered (R4), section 3.8.9 (equal to 30-3 7.5; outline empty).
15. `LiquidBlock` collision for other entity classes: answered (R4), rule R-A3 and section 1.8.2: empty for every class other than `Strider`.
16. Attached stem boxes: answered (R4), rule R-F19.
17. `isDescending()` for entities other than players (the method of `Entity` was not traced; for the player it is the sneak state) and the mapping of each `RailShape` slope to the neighbour cell that `MinecartCollisionContext` ignores (only the switch's four neighbours, east, west, north, south, were read, not which slope maps to which case).
18. Targeting internals not read: `BlockGetter.traverseBlocks` (the cell order and the "first non-null result ends the walk" rule are inferred), `VoxelShape.clip` (ray against boxes, entry face), the `SOURCE_ONLY` fluid predicate (inferred to accept source states only), `FluidState.getShape` (29a 1.3 has the box), and the `withFluid` argument and `range` that the player's pick passes to `Entity.pick`.
19. Grindstone, and every attach-face block, floor and ceiling rows: the group elements (`BLOCK_ROT_X_270` for the floor, `BLOCK_ROT_Y_180` composed with `BLOCK_ROT_X_90` for the ceiling, yaw by `Y_90`, `Y_180`, `Y_270`) were read; the composition order and the rotation sense of each element were not re-derived from the group table in R4 (the floor and ceiling rows of the grindstone do not depend on the order as unions: they depend only on the axis of `facing`; what the order decides is the axis assignment, inferred from the upright wheel) (section 2.4 relied on the earlier resolution; the hopper's down spout and the bell, which use a single element, agree with 2.1 and 2.2).
20. The client classes `ModelBlockRenderer` and `SectionRenderDispatcher` were found to reference `getOffset` but were not read (the statement that they shift the drawn model is inferred); `LevelRenderer`'s use for the crack overlay was read.
21. Shulker box: the float rounding of `lerp(1.0, progressOld, progress)` against `progress` (the extension is `0.5f * getProgress(1.0f)`; equal to the current progress up to a float ulp), and whether the unrelated `Shulker` mob uses the same helpers for its own shape (not read).

## Implementation status (client, core, content)

Recorded by the implementing lane (not a statement about the artifact). The shape tables are built from the rules of sections 3 and 4 by class and property (`content/src/block-shapes.cob`, rows in `content/copy/CTBSDATA.cpy`). Covered: slabs, stairs, doors, trapdoors, fences, fence gates, walls, panes and bars, chains, end and lightning rods, ladders, vines and lichen (outline), torches, buttons, levers, pressure plates, signs, banners, carpets, snow layers, farmland, path, soul sand, mud, honey, cactus, rails, lanterns, candles, anvils, chests, beds (mattress only), end portal frames, crops, saplings and the small plants (outline without the XZ offset), portals, fire (outline cube). Everything else keeps the default: no collision when the row flags say noCollision or air, else the full cube; the outline is the full cube except for air and liquids. Not yet covered (still default): the rows of the open questions above plus cauldrons, hoppers, bells, scaffolding, pistons, composters, grindstones, lecterns' desk (outline), skull variants and joined chests. The player box is the operator box (0.7 wide), so a ladder cell is entered from the side away from its panel and the 3 pixel panel stops a body that walks into it, which is what starts the climb (13 section 1.3).
