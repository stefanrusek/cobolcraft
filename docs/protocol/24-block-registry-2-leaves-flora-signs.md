# 24 — Block registry, part 2: leaves, flora, signs (ordinals 105 to 209)

| Item | Value |
|---|---|
| Covers | The code-defined content of the block registry for registration ordinals 105 to 209 of the `Blocks` initializer, from `yellow_poplar_leaves` to `oak_wall_sign`: for every block its key, registry id, block class and constructor arguments, state properties (names, value order, defaults, state count and state-id offset), settings (hardness, resistance, tool requirement, instrument, sound type, map colour, light, flags), collision / outline / occlusion shapes, and the placement-state, survival and replaceability rules that are part of the block class. The shared rules of part 1 are cited as "24 part 1" (`24-block-registry-1-model-and-foundation.md`) and not repeated; the few base-class defaults this part needs are restated in section 2 so that it can be read alone. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for bootstrap-method arguments) with no execution. Classes read: `Blocks` (static initializer and helper methods), `BlockBehaviour$Properties`, `BlockBehaviour$BlockStateBase`, `Block`, `StateDefinition`, `BlockStateProperties`, `Shapes`, `ColorCollection`, `DyeColor`, `WoodType`, `BlockSetType`, `BlockItemIds`, `BlockIds`, `OctahedralGroup`, `Mth` and the block classes named in section 3. |

Class and field names in backticks say where a fact was read; they are not the design. "04 §5.2" means section 5.2 of
`04-registry-sync.md`; "13 §2.1" means section 2.1 of document 13, and so on. Data rows (models, block-state JSON, loot
tables, recipes, tags, language) are not tabulated: where a rule depends on a tag, the tag is named and the document that
extracts tags is 22 (extraction tool). Behaviour that belongs to the update engines (random ticks, redstone, pistons,
fire spread, growth, block entities) is named with the document that is to specify it and is not repeated here, except
for the constants that define the registry entry itself.

## Contents

1. [Scope and conventions](#1-scope-and-conventions)
2. [Shared definitions this part relies on](#2-shared-definitions-this-part-relies-on)
3. [Registry rows](#3-registry-rows)
4. [State layout, defaults and index formulas](#4-state-layout-defaults-and-index-formulas)
5. [Block settings](#5-block-settings)
6. [Shapes](#6-shapes)
7. [Placement state, survival, replaceability and other class rules](#7-placement-state-survival-replaceability-and-other-class-rules)
8. [Worked examples](#8-worked-examples)
9. [Validation](#9-validation)
10. [Open questions](#10-open-questions)

---

## 1. Scope and conventions

### 1.1 What "ordinal 105 to 209" means

The `Blocks` static initializer registers blocks in a long sequence of statements. The first three statements create
three predicates (not blocks); every later statement ends with a `register` call. In this document the **ordinal** of a
block is the number of its statement among the block statements, counting from 0 (`air` is ordinal 0). Ordinals 105 to 209
are the 105 statements from `yellow_poplar_leaves` (105) to `oak_wall_sign` (209).

The range contains shelves, TNT, bookshelves, gold, iron and brick blocks, mossy cobblestone, obsidian, creaking
heart, `oak_stairs`, an oak door, a ladder, a rail and `cobblestone_stairs`, and it contains no hanging sign (those come
after ordinal 209 and belong to 24 part 3). The range is every ordinal from 105 to 209, in registration order.

### 1.2 Ordinal, block id and state id

- **Block id** (the protocol id of the `block` registry, 04 §5.1) is the registration index. A statement registers one
  block, except the four colour-collection statements of this range, which register 16 blocks each
  (`ColorCollection.registerBlocks` and `ColorCollection.zipMap`; section 2.8). Colours are registered in the order
  white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black.
- Every statement before ordinal 119 registers exactly one block (read by scanning the first 119 statements: none calls a
  collection helper), so **block id = ordinal for ordinals 0 to 118**. From ordinal 119 the ids shift: `bed` (119)
  occupies ids 119 to 134, so `straw_bed` (120) is id 135; `wool` (136) occupies 151 to 166, `wool_stairs` (137) 167 to
  182, `wool_slab` (138) 183 to 198, `moving_piston` (139) is id 199, and `oak_wall_sign` (209) is id 269.
  The range covers 105 ordinals and 165 block ids (105 to 269).
- **State id** is `Block.BLOCK_STATE_REGISTRY` (04 §5.2): blocks in id order, each block's states in the order of
  `StateDefinition` (properties sorted by name, first name varies slowest). This part gives, for every block, its state
  count and its **state offset**: the number of states of all blocks of this range that precede it. The absolute first
  state id of a block is `B105 + offset`, where `B105` is the total number of states of the blocks with ids 0 to 104,
  which 24 part 1 gives: **B105 = 575** (24 part 1 section 15 row 104: first state id 547 plus 28 states, so 547 + 28 = 575; the nine leaf blocks of ids 96 to 104 have 28 states each and `birch_leaves`, id 96, starts at 323, so 323 + 9 x 28 = 575; 24 part 1 section 16 item 4 gives the same first state id for id 105). Every absolute state id of this part is `575 + offset`; 24 part 3 chains from it (`ladder` 7307 = 575 + 6732, `oak_wall_sign` 7415 = 575 + 6840). The range holds **6 848 states** in total (offsets 0 to 6 847).

### 1.3 Units and notation

- Shapes are written as boxes `[x0,y0,z0 - x1,y1,z1]` in sixteenths of a block (0 to 16 spans one block). The artifact
  builds them from sixteenths and divides by 16; fractional values such as 5.5 are exact.
- Direction value order, as the constants of `Direction` are declared: down, up, north, south, west, east. Coordinates:
  east is +x, south is +z, up is +y. `clockwise(d)` and `counter-clockwise(d)` are as seen from above:
  clockwise(north) = east, clockwise(east) = south, clockwise(south) = west, clockwise(west) = north.
- "Facing-authored shape": a shape written for facing north and turned for the other facings (section 2.6).
- Property value lists are given in value order (the order that sets the state index). Booleans are listed `true`
  first, then `false`, as 04 §5.2 states, so the index of `false` is 1.
- "Tag" means a block or item tag of the vanilla data pack; the code only tests membership.

---

## 2. Shared definitions this part relies on

These are restated from the artifact because the rows in sections 3 to 7 use them. Where 24 part 1 states the same
rule it is authoritative, and a difference between the two is a defect to be reported (Open question 1).

### 2.1 Defaults of `BlockBehaviour$Properties`

A block's settings start from these values (`BlockBehaviour$Properties.of`) and each builder call in section 2.2 changes
one of them.

| Setting | Default |
|---|---|
| map colour | `NONE` (a function of the state) |
| collision | yes |
| sound type | `STONE` |
| light emission | 0 for every state |
| friction | 0.6 |
| speed factor / jump factor | 1.0 / 1.0 |
| hardness (destroy time), explosion resistance | 0 / 0 |
| can occlude | yes |
| push reaction | `PUSH_PULL` |
| terrain particles | yes |
| instrument | `HARP` |
| random ticks | no |
| replaceable | no |
| force solid on / off | no / no |
| ignited by lava | no |
| dynamic shape | no |
| offset | none |
| loot table | `blocks/<key>` (data) |
| valid spawn | the top face is sturdy and the state's light emission is below 14 (any entity type) |
| redstone conductor | the collision shape is a full block |
| suffocating | the state is in tag `causes_suffocation` and the collision shape is a full block |
| view blocking | same as suffocating |
| post process | none |

### 2.2 Builder calls used in this range

| Call | Effect |
|---|---|
| `mapColor(c)` | map colour is the constant `c`, a `DyeColor`'s colour, or a function of the state |
| `strength(a, b)` / `strength(a)` | hardness a, resistance b; the one-argument form sets both to a. Resistance is clamped to at least 0 (`explosionResistance` applies `max(0, b)`) |
| `instabreak()` | `strength(0)` |
| `noCollision()` | collision off **and** can occlude off |
| `noOcclusion()` | can occlude off |
| `requiresCorrectToolForDrops()` | the block drops only when mined with a correct tool (13 §2.1 and 17 give the tool rules) |
| `randomTicks()` | the state set is random-ticked (a class may override per state: leaves, crops) |
| `replaceable()` | a block placement may replace this block (section 7.1) |
| `forceSolidOn()` / `forceSolidOff()` | "legacy solid" is forced true / false (section 2.3) |
| `ignitedByLava()` | lava may ignite the block |
| `pushReaction(r)` | piston behaviour: `PUSH_PULL`, `POPPED` (breaks and drops when pushed), `IMMOVEABLE` |
| `offsetType(t)` | per-position model offset, `XZ` or `XYZ` (section 2.7) |
| `noLootTable()` | the block has no loot table |
| `dynamicShape()` | the shape can change without a state change (read from a block entity) |
| `lightLevel(f)` | light emission is `f(state)` |
| `sound(s)` | sound type |
| `instrument(i)` | note-block instrument played when this block is below a note block |
| `isValidSpawn`, `isRedstoneConductor`, `isSuffocating`, `isViewBlocking`, `postProcess` | replace the predicate of the same name; `never` is a predicate that is false for every input, `always` true |
| `bounceRestitution(x)`, `fallDistanceReduction(x)` | bed bounce factor and fall-distance multiplier reduction |
| `ofLegacyCopy(b)` | a copy of b's settings: hardness, resistance, collision, random ticks, light, map colour, sound, friction, speed factor, bounce, dynamic shape, can occlude, air, ignited by lava, liquid, force solid on/off, push reaction, tool requirement, offset, terrain particles, required features (feature-flag set), emissive-rendering predicate, instrument, replaceable (read from `BlockBehaviour$Properties.ofLegacyCopy`: 25 distinct fields). It does **not** copy jump factor, the five predicates (spawn, conductor, suffocating, view blocking, post process), loot table, description or fall-distance reduction |
| `ofFullCopy(b)` | `ofLegacyCopy(b)` plus jump factor, the five predicates, loot table and description. Neither copy form carries `fallDistanceReduction`, so a copy never inherits it (read) |

`NEAR_PLANE_INTERSECTS_OUTLINE` (view-blocking predicate of every stair and slab here) is true when at least one box of the
state's occlusion shape, moved to the block position, intersects the box passed in. `NOT_EXTENDED_PISTON` is true when the
state's `extended` property is false. `ocelotOrParrot` is true when the entity type is `ocelot` or `parrot`.

Helpers of `Blocks` used here:

| Helper | Expansion |
|---|---|
| `leavesProperties(sound)` | map colour `PLANT`, hardness and resistance 0.2, random ticks, the given sound type, no occlusion, valid spawn = `ocelotOrParrot`, suffocating = `never`, ignited by lava, push reaction `POPPED`, redstone conductor = `never` |
| `pistonProperties()` | map colour `STONE`, hardness and resistance 1.5, redstone conductor = `never`, suffocating = `NOT_EXTENDED_PISTON`, push reaction `IMMOVEABLE` |
| `litBlockEmission(n)` | light emission is n when the state's `lit` is true, else 0 |
| `wallVariant(base, sameDescription)` | fresh `of()` settings, with the loot table of `base` and, when the flag is true, the description (language key) of `base` |
| `registerStair(id, base)` | `StairBlock` built on `base`'s default state, settings `ofFullCopy(base)` plus view blocking = `NEAR_PLANE_INTERSECTS_OUTLINE` |
| `registerLegacyStair(id, base)` | same, with `ofLegacyCopy(base)` |
| `registerSlab(id, base)` | `SlabBlock`, settings `ofLegacyCopy(base)` plus view blocking = `NEAR_PLANE_INTERSECTS_OUTLINE` |

### 2.3 Base-class defaults (`BlockBehaviour`, `Block`, `BlockStateBase`)

| Query | Default |
|---|---|
| outline shape (`getShape`) | full block |
| collision shape | the outline shape when collision is on, else empty |
| occlusion shape | the outline shape (and empty when can-occlude is off) |
| block-support shape | the collision shape |
| interaction shape | empty |
| visual shape | the collision shape |
| render shape | `MODEL` |
| use shape for light occlusion | false |
| light dampening | 15 when the occlusion shape is a full block; else 0 if skylight propagates down (including the class overrides in the next row), else 1 |
| propagates skylight down | the outline shape is not a full block and the fluid state is empty. **Overridden by classes (read):** `TransparentBlock` returns true for every state (so `glass` has dampening 0 although its outline is a full block); `VegetationBlock` returns true when the fluid state is empty (flowers, `short_grass`, `fern`, `bush`, `red_shrub`, `dead_bush`, `short_dry_grass`, `tall_dry_grass`, the mushrooms, `seagrass` and `wheat` inherit it; `tall_seagrass` extends `DoublePlantBlock`, not checked); `BambooStalkBlock` returns true, and `WallBlock` and `CrossCollisionBlock` return true unless waterlogged (neither is in this range). **The list is not complete:** the classes of the `world.level.block` package that declare `propagatesSkylightDown` or `getLightDampening` in this jar (read from the method tables) are `BambooStalkBlock`, `BarrierBlock`, `CrossCollisionBlock`, `GlowLichenBlock`, `HangingMossBlock`, `LeavesBlock`, `LightBlock`, `LiquidBlock`, `MossyCarpetBlock`, `PipeBlock`, `ShulkerBoxBlock`, `TintedGlassBlock`, `TransparentBlock`, `VegetationBlock`, `VineBlock` and `WallBlock`; none of the ones not named above is a block of this range, so the per-block results of section 5.3 are unaffected. `WebBlock`, `IceBlock`, `NyliumBlock` and `SpreadingSnowyBlock` declare neither method (read) |
| shade brightness | 0.2 when the collision shape is a full block, else 1.0 |
| can survive | true |
| fluid state | empty |
| can be replaced by a fluid | the replaceable flag, or the state is not legacy solid |
| destroy progress per tick | speed / hardness / (30 if the player has a correct tool for drops, else 100); 0 when hardness is -1 (13 §2.1) |
| maximum horizontal / vertical offset | 0.25 / 0.2 (no block of this range overrides them) |
| pathfindable | not tabulated for this range (Open question 11), except `farmland`, whose `isPathfindable` returns false for every computation type (read) |

**Legacy solid** (used by `canSurvive` of farmland and signs; `BlockStateBase.calculateSolid`, branch results read from the
`SolidDebugger$Reason` constants): evaluated in this order, the first matching step decides.

1. `forceSolidOn` set on the block: **true**.
2. `forceSolidOff` set: **false**.
3. The per-state cache is missing: false (not reachable once the registry is built).
4. The collision shape is empty: **false**.
5. Let `size = (xsize + ysize + zsize) / 3` for the bounding box of the collision shape (`AABB.getSize`, read: the plain mean of the three edge lengths, in blocks). When `size >= 0.7291666666666666` (35/48): **true**.
6. Otherwise, when the box height `ysize >= 1.0`: **true**.
7. Otherwise: **false**.

Worked checks: a bottom slab (box 1 x 0.5 x 1) has size 0.8333 and is solid; farmland (1 x 0.9375 x 1) has size 0.9792 and
is solid; a flower (collision empty) is not solid; a ladder is not solid because of `forceSolidOff`; a sign is solid
because of `forceSolidOn`. The sum threshold is 2.1875 blocks.

**Friction, speed factor and jump factor.** No block of ordinals 105 to 209 overrides them: the only `friction`,
`speedFactor` and `jumpFactor` calls in the `Blocks` initializer belong to `ice`, `soul_sand`, `slime_block`, `packed_ice`,
`frosted_ice`, `blue_ice` and `honey_block`, all registered after ordinal 209 (the byte offsets of those calls follow
the `oak_wall_sign` registration; read). Every block of this range therefore has friction 0.6, speed factor 1.0 and jump
factor 1.0, including the blocks built by `ofLegacyCopy` / `ofFullCopy` from wool, planks, cobblestone, lapis ore and
diamond ore (their sources do not override either).

### 2.4 Properties used in this range

Each row is a `BlockStateProperties` constant: the serialized property name, and its value list in value order.

| Constant | Name | Values in order |
|---|---|---|
| `DISTANCE` | `distance` | 1, 2, 3, 4, 5, 6, 7 |
| `PERSISTENT`, `WATERLOGGED`, `TRIGGERED`, `POWERED`, `OCCUPIED`, `EXTENDED`, `SHORT`, `UNSTABLE`, `LIT`, `OPEN`, `NATURAL`, `SLOT_n_OCCUPIED` | `persistent`, `waterlogged`, `triggered`, `powered`, `occupied`, `extended`, `short`, `unstable`, `lit`, `open`, `natural`, `slot_0_occupied` to `slot_5_occupied` | true, false |
| `FACING` (6 values) | `facing` | north, east, south, west, up, down (an explicit list, not ordinal order) |
| `HORIZONTAL_FACING` (4 values) | `facing` | north, south, west, east (the horizontal directions in `Direction` declaration order; rule of 04 §5.2 for the filtered form) |
| `NOTEBLOCK_INSTRUMENT` | `instrument` | the 27 values of `NoteBlockInstrument` in declaration order: harp, basedrum, snare, hat, bass, flute, bell, guitar, chime, xylophone, iron_xylophone, cow_bell, didgeridoo, bit, banjo, pling, trumpet, trumpet_exposed, trumpet_oxidized, trumpet_weathered, zombie, skeleton, creeper, dragon, wither_skeleton, piglin, custom_head |
| `NOTE` | `note` | 0 to 24 |
| `BED_PART` | `part` | head, foot |
| `RAIL_SHAPE` | `shape` | north_south, east_west, ascending_east, ascending_west, ascending_north, ascending_south, south_east, south_west, north_west, north_east |
| `RAIL_SHAPE_STRAIGHT` | `shape` | the `RAIL_SHAPE` values minus the four corner shapes: north_south, east_west, ascending_east, ascending_west, ascending_north, ascending_south |
| `PISTON_TYPE` | `type` | normal (constant `DEFAULT`), sticky |
| `SLAB_TYPE` | `type` | top, bottom, double |
| `CHEST_TYPE` | `type` | single, left, right |
| `HALF` | `half` | top, bottom |
| `DOUBLE_BLOCK_HALF` | `half` | upper, lower |
| `STAIRS_SHAPE` | `shape` | straight, inner_left, inner_right, outer_left, outer_right |
| `DOOR_HINGE` | `hinge` | left, right |
| `AGE_15` (fire) | `age` | 0 to 15 |
| `AGE_7` (crops) | `age` | 0 to 7 |
| `MOISTURE` | `moisture` | 0 to 7 |
| `POWER` | `power` | 0 to 15 |
| `ROTATION_16` | `rotation` | 0 to 15 (the maximum segment index of a 4-bit angle, `RotationSegment`) |
| `NORTH`, `EAST`, `SOUTH`, `WEST`, `UP` (fire) | `north`, `east`, `south`, `west`, `up` | true, false |
| `NORTH_REDSTONE`, `EAST_REDSTONE`, `SOUTH_REDSTONE`, `WEST_REDSTONE` | `north`, `east`, `south`, `west` | up, side, none |
| `SIDE_CHAIN_PART` | `side_chain` | unconnected, right, center, left |
| `AXIS` | `axis` | x, y, z |
| `CREAKING_HEART_STATE` | `creaking_heart_state` | uprooted, dormant, awake |

### 2.5 Default state

`Block`'s constructor starts from `StateDefinition.any()`, which is the **first** state of the list (the first value of
every property: `true` for booleans, the first listed value for the others), and a block class overrides it with
`registerDefaultState`. Every class of this range sets every property that it declares, except `facing` of the beds
(first value, north) and the single `half` of `DoublePlantBlock` (set to lower). Section 4 gives the final default per
class.

### 2.6 Shape helpers and rotation

Helpers of `Block` (arguments in sixteenths, results in sixteenths here):

| Helper | Meaning |
|---|---|
| `box(x0,y0,z0,x1,y1,z1)` | the box; each argument is divided by 16; the call fails when a minimum exceeds a maximum |
| `column(s, y0, y1)` | `[8-s/2, y0, 8-s/2 - 8+s/2, y1, 8+s/2]`: a square column centred on the block axis |
| `column(sx, sz, y0, y1)` | `[8-sx/2, y0, 8-sz/2 - 8+sx/2, y1, 8+sz/2]` |
| `boxZ(s, z0, z1)` | `[8-s/2, 8-s/2, z0 - 8+s/2, 8+s/2, z1]`: a square cross-section centred on the z axis, running from z0 to z1 |
| `boxZ(sx, sy, z0, z1)` | `[8-sx/2, 8-sy/2, z0 - 8+sx/2, 8+sy/2, z1]` |
| `boxZ(sx, y0, y1, z0, z1)` | `[8-sx/2, y0, z0 - 8+sx/2, y1, z1]` |
| `Shapes.or` | union of boxes |
| `Shapes.rotateHorizontal(shape)` | a map from the four horizontal directions to the shape turned about the block centre: north = the shape as written, east = turned by `BLOCK_ROT_Y_90`, south by 180 degrees, west by 270 degrees. A second argument `INVERT_Y` also mirrors the shape vertically (y becomes 16 - y) |
| `Shapes.rotateAll(shape)` | the six directions: the four horizontal ones as above, up = turned by `BLOCK_ROT_X_270`, down by `BLOCK_ROT_X_90` |

Turning a shape (read from `Shapes.rotate`, `OctahedralGroup` and `SymmetricGroup3`): the rotation takes the group's axis
permutation and per-axis inversion flags; the new coordinate list of axis A is the old list of the axis `permutation(A)`,
reflected about the block centre (c -> 1 - c) when the group inverts A. `BLOCK_ROT_Y_90` is the group `ROT_90_Y_NEG`:
permutation (x -> z, y -> y, z -> x), inversion of x only. So a point at block-relative (x, z) goes to (1 - z, x): a
feature on the north side (small z) ends up on the east side, as the table assignment "east = Y_90" requires. `BLOCK_ROT_X_270` is
`ROT_90_X_POS`: permutation (x, z -> y, y -> z), inversion of y only, so (y, z) goes to (1 - z, y): a feature at the north
face (z near 0) ends at the top face (y near 1). `BLOCK_ROT_X_90` is `ROT_90_X_NEG` (inversion of z; down). `BLOCK_ROT_Y_180` is
`ROT_180_FACE_XZ`, `BLOCK_ROT_Y_270` is `ROT_90_Y_POS`. In `rotateHorizontal` / `rotateAll` the table entry for east is
`BLOCK_ROT_Y_90` composed with the optional extra group, south `Y_180`, west `Y_270`, and for `rotateAll` up uses `X_270` and down `X_90`.
All of this was read.

`Shapes.rotateHorizontal` and `rotateAll` return maps; the block classes look up the map with a property value
(`facing`, or a computed direction), so each facing-authored shape below is given for facing north only.

### 2.7 Model offset (`offsetType`)

A state of a block with offset type `XZ` or `XYZ` is drawn (and, for `FlowerBlock`, its outline moved) by an offset that
depends only on the block position, using the position hash `Mth.getSeed(x, 0, z)`. The hash of `(x, y, z)` is:

1. `h = (x * 3129871)` (as a 32-bit integer product, then widened to 64 bits) `xor` `(z * 116129781)` (64-bit) `xor` `y`;
2. result = `(h * h * 42317861 + h * 11) >> 16` (64-bit arithmetic, arithmetic shift).

With `seed = getSeed(x, 0, z)` and `maxH = 0.25`, `maxV = 0.2`:

- `dx = clamp(((seed & 15) / 15 - 0.5) * 0.5, -maxH, maxH)`;
- `dz = clamp((((seed >> 8) & 15) / 15 - 0.5) * 0.5, -maxH, maxH)`;

Precision (read, `BlockBehaviour$Properties` offset callbacks): the masked value is converted to a 32-bit float and **divided by the float constant 15.0 in float32 arithmetic**; only then is the quotient widened to double, and the `- 0.5` and `* 0.5` steps use double constants. The clamp bounds are the float `maxH` (0.25) and `-maxH` widened to double. For `dy` the same float32 division by 15.0 is done, the result widened to double, `1.0` subtracted (double), and the product taken with the float `maxV` (0.2f, whose double widening is 0.20000000298...) widened to double. A bit-exact implementation must therefore round the quotient to float32 before the double steps. The worked numbers of section 8 agree to the digits shown.

- `XZ`: offset (dx, 0, dz);
- `XYZ`: offset (dx, dy, dz) with `dy = (((seed >> 4) & 15) / 15 - 1.0) * maxV` (float32 division as below) (so `dy` is between -0.2 and 0).

Only `FlowerBlock` (the fifteen flowers of this range) applies the offset inside `getShape` (its outline box is moved by
it). The other offset blocks (`short_grass`, `fern`, `short_dry_grass`, `tall_dry_grass`, `tall_seagrass`) do not move
their `getShape` result in the block class; where the offset is applied for them is not read (Open question 6).

### 2.8 Colour collections

`ColorCollection` is a record of 16 values in the order white, orange, magenta, light_blue, yellow, lime, pink, gray,
light_gray, cyan, purple, blue, brown, green, red, black. `registerBlocks` registers the blocks of one collection in that
order; `zipMap` combines two collections position by position, in that order. The block key is `<colour>_<base>`
(`ColorCollection.prefixWithColor` joins the colour name, an underscore and the base key). The map colour of each colour
(`DyeColor.getMapColor`):

| Colour | Map colour |
|---|---|
| white | `SNOW` |
| orange | `COLOR_ORANGE` |
| magenta | `COLOR_MAGENTA` |
| light_blue | `COLOR_LIGHT_BLUE` |
| yellow | `COLOR_YELLOW` |
| lime | `COLOR_LIGHT_GREEN` |
| pink | `COLOR_PINK` |
| gray | `COLOR_GRAY` |
| light_gray | `COLOR_LIGHT_GRAY` |
| cyan | `COLOR_CYAN` |
| purple | `COLOR_PURPLE` |
| blue | `COLOR_BLUE` |
| brown | `COLOR_BROWN` |
| green | `COLOR_GREEN` |
| red | `COLOR_RED` |
| black | `COLOR_BLACK` |

---

## 3. Registry rows

Columns: **Ord** the registration ordinal; **Block id** the registry id (section 1.2); **Key** the registry key
(`minecraft:` namespace); **Class** the block class with the constructor arguments the initializer passes; **States**
the number of block states; **State offset** the number of states of this range that precede the block (add `B105`).
For the four collections the offset of colour *c* (0 for white to 15 for black) is the first number plus *c* times the
states per block. The classes' inherited behaviour is in sections 4 to 7.

| Ord | Block id | Key | Class (constructor arguments) | States | State offset |
|---|---|---|---|---|---|
| 105 | 105 | `yellow_poplar_leaves` | UntintedParticleLeavesBlock (chance 0.01; particle `yellow_poplar_leaves`; ambient sound player with `poplar_leaves_ambient` gated by tag `required_for_poplar_leaf_ambience`) | 28 | 0 |
| 106 | 106 | `azalea_leaves` | UntintedParticleLeavesBlock (chance 0.01; particle `tinted_leaves` with colour option 0xFF70922D; no ambient sound) | 28 | 28 |
| 107 | 107 | `flowering_azalea_leaves` | UntintedParticleLeavesBlock (chance 0.01; particle `tinted_leaves` with colour option 0xFF70922D; no ambient sound) | 28 | 56 |
| 108 | 108 | `sponge` | SpongeBlock | 1 | 84 |
| 109 | 109 | `wet_sponge` | WetSpongeBlock | 1 | 85 |
| 110 | 110 | `glass` | TransparentBlock | 1 | 86 |
| 111 | 111 | `lapis_ore` | DropExperienceBlock (xp 2..5) | 1 | 87 |
| 112 | 112 | `deepslate_lapis_ore` | DropExperienceBlock (xp 2..5) | 1 | 88 |
| 113 | 113 | `lapis_block` | Block | 1 | 89 |
| 114 | 114 | `dispenser` | DispenserBlock | 12 | 90 |
| 115 | 115 | `sandstone` | Block | 1 | 102 |
| 116 | 116 | `chiseled_sandstone` | Block | 1 | 103 |
| 117 | 117 | `cut_sandstone` | Block | 1 | 104 |
| 118 | 118 | `note_block` | NoteBlock | 1350 | 105 |
| 119 | 119 to 134 | `<colour>_bed` | BedBlock (per colour) | 16 each | 1455 + 16 x colour |
| 120 | 135 | `straw_bed` | StrawBedBlock | 16 | 1711 |
| 121 | 136 | `powered_rail` | PoweredRailBlock | 24 | 1727 |
| 122 | 137 | `detector_rail` | DetectorRailBlock | 24 | 1751 |
| 123 | 138 | `sticky_piston` | PistonBaseBlock (sticky = true) | 12 | 1775 |
| 124 | 139 | `cobweb` | WebBlock | 1 | 1787 |
| 125 | 140 | `short_grass` | TallGrassBlock | 1 | 1788 |
| 126 | 141 | `fern` | TallGrassBlock | 1 | 1789 |
| 127 | 142 | `dead_bush` | DryVegetationBlock | 1 | 1790 |
| 128 | 143 | `bush` | BushBlock (height 13) | 1 | 1791 |
| 129 | 144 | `red_shrub` | BushBlock (height 13) | 1 | 1792 |
| 130 | 145 | `short_dry_grass` | ShortDryGrassBlock | 1 | 1793 |
| 131 | 146 | `tall_dry_grass` | TallDryGrassBlock | 1 | 1794 |
| 132 | 147 | `seagrass` | SeagrassBlock | 1 | 1795 |
| 133 | 148 | `tall_seagrass` | TallSeagrassBlock | 2 | 1796 |
| 134 | 149 | `piston` | PistonBaseBlock (sticky = false) | 12 | 1798 |
| 135 | 150 | `piston_head` | PistonHeadBlock | 24 | 1810 |
| 136 | 151 to 166 | `<colour>_wool` | Block | 1 each | 1834 + 1 x colour |
| 137 | 167 to 182 | `<colour>_wool_stairs` | StairBlock (base state = default state of the base block) | 80 each | 1850 + 80 x colour |
| 138 | 183 to 198 | `<colour>_wool_slab` | SlabBlock | 6 each | 3130 + 6 x colour |
| 139 | 199 | `moving_piston` | MovingPistonBlock | 12 | 3226 |
| 140 | 200 | `dandelion` | FlowerBlock (effect saturation, 0.35 s) | 1 | 3238 |
| 141 | 201 | `golden_dandelion` | FlowerBlock (effect saturation, 0.35 s) | 1 | 3239 |
| 142 | 202 | `torchflower` | FlowerBlock (effect night_vision, 5 s) | 1 | 3240 |
| 143 | 203 | `poppy` | FlowerBlock (effect night_vision, 5 s) | 1 | 3241 |
| 144 | 204 | `blue_orchid` | FlowerBlock (effect saturation, 0.35 s) | 1 | 3242 |
| 145 | 205 | `allium` | FlowerBlock (effect fire_resistance, 3 s) | 1 | 3243 |
| 146 | 206 | `azure_bluet` | FlowerBlock (effect blindness, 11 s) | 1 | 3244 |
| 147 | 207 | `red_tulip` | FlowerBlock (effect weakness, 7 s) | 1 | 3245 |
| 148 | 208 | `orange_tulip` | FlowerBlock (effect weakness, 7 s) | 1 | 3246 |
| 149 | 209 | `white_tulip` | FlowerBlock (effect weakness, 7 s) | 1 | 3247 |
| 150 | 210 | `pink_tulip` | FlowerBlock (effect weakness, 7 s) | 1 | 3248 |
| 151 | 211 | `oxeye_daisy` | FlowerBlock (effect regeneration, 7 s) | 1 | 3249 |
| 152 | 212 | `cornflower` | FlowerBlock (effect jump_boost, 5 s) | 1 | 3250 |
| 153 | 213 | `wither_rose` | WitherRoseBlock (effect wither, 7 s) | 1 | 3251 |
| 154 | 214 | `lily_of_the_valley` | FlowerBlock (effect poison, 11 s) | 1 | 3252 |
| 155 | 215 | `brown_mushroom` | MushroomBlock (feature `huge_brown_mushroom`) | 1 | 3253 |
| 156 | 216 | `red_mushroom` | MushroomBlock (feature `huge_red_mushroom`) | 1 | 3254 |
| 157 | 217 | `gold_block` | Block | 1 | 3255 |
| 158 | 218 | `iron_block` | Block | 1 | 3256 |
| 159 | 219 | `bricks` | Block | 1 | 3257 |
| 160 | 220 | `tnt` | TntBlock | 2 | 3258 |
| 161 | 221 | `bookshelf` | Block | 1 | 3260 |
| 162 | 222 | `chiseled_bookshelf` | ChiseledBookShelfBlock | 256 | 3261 |
| 163 | 223 | `acacia_shelf` | ShelfBlock | 64 | 3517 |
| 164 | 224 | `bamboo_shelf` | ShelfBlock | 64 | 3581 |
| 165 | 225 | `birch_shelf` | ShelfBlock | 64 | 3645 |
| 166 | 226 | `cherry_shelf` | ShelfBlock | 64 | 3709 |
| 167 | 227 | `crimson_shelf` | ShelfBlock | 64 | 3773 |
| 168 | 228 | `dark_oak_shelf` | ShelfBlock | 64 | 3837 |
| 169 | 229 | `jungle_shelf` | ShelfBlock | 64 | 3901 |
| 170 | 230 | `mangrove_shelf` | ShelfBlock | 64 | 3965 |
| 171 | 231 | `oak_shelf` | ShelfBlock | 64 | 4029 |
| 172 | 232 | `pale_oak_shelf` | ShelfBlock | 64 | 4093 |
| 173 | 233 | `poplar_shelf` | ShelfBlock | 64 | 4157 |
| 174 | 234 | `spruce_shelf` | ShelfBlock | 64 | 4221 |
| 175 | 235 | `warped_shelf` | ShelfBlock | 64 | 4285 |
| 176 | 236 | `mossy_cobblestone` | Block | 1 | 4349 |
| 177 | 237 | `obsidian` | Block | 1 | 4350 |
| 178 | 238 | `torch` | TorchBlock (particle `flame`) | 1 | 4351 |
| 179 | 239 | `wall_torch` | WallTorchBlock (particle `flame`) | 4 | 4352 |
| 180 | 240 | `fire` | FireBlock | 512 | 4356 |
| 181 | 241 | `soul_fire` | SoulFireBlock | 1 | 4868 |
| 182 | 242 | `spawner` | SpawnerBlock | 1 | 4869 |
| 183 | 243 | `creaking_heart` | CreakingHeartBlock | 18 | 4870 |
| 184 | 244 | `oak_stairs` | StairBlock (base state = default state of the base block) | 80 | 4888 |
| 185 | 245 | `chest` | ChestBlock (open/close sounds `chest_open`/`chest_close`) | 24 | 4968 |
| 186 | 246 | `redstone_wire` | RedstoneWireBlock | 1296 | 4992 |
| 187 | 247 | `diamond_ore` | DropExperienceBlock (xp 3..7) | 1 | 6288 |
| 188 | 248 | `deepslate_diamond_ore` | DropExperienceBlock (xp 3..7) | 1 | 6289 |
| 189 | 249 | `diamond_block` | Block | 1 | 6290 |
| 190 | 250 | `crafting_table` | CraftingTableBlock | 1 | 6291 |
| 191 | 251 | `wheat` | CropBlock | 8 | 6292 |
| 192 | 252 | `farmland` | FarmlandBlock (base block `dirt`) | 8 | 6300 |
| 193 | 253 | `furnace` | FurnaceBlock | 8 | 6308 |
| 194 | 254 | `oak_sign` | StandingSignBlock (wood type `oak`) | 32 | 6316 |
| 195 | 255 | `spruce_sign` | StandingSignBlock (wood type `spruce`) | 32 | 6348 |
| 196 | 256 | `birch_sign` | StandingSignBlock (wood type `birch`) | 32 | 6380 |
| 197 | 257 | `acacia_sign` | StandingSignBlock (wood type `acacia`) | 32 | 6412 |
| 198 | 258 | `cherry_sign` | StandingSignBlock (wood type `cherry`) | 32 | 6444 |
| 199 | 259 | `jungle_sign` | StandingSignBlock (wood type `jungle`) | 32 | 6476 |
| 200 | 260 | `dark_oak_sign` | StandingSignBlock (wood type `dark_oak`) | 32 | 6508 |
| 201 | 261 | `pale_oak_sign` | StandingSignBlock (wood type `pale_oak`) | 32 | 6540 |
| 202 | 262 | `mangrove_sign` | StandingSignBlock (wood type `mangrove`) | 32 | 6572 |
| 203 | 263 | `poplar_sign` | StandingSignBlock (wood type `poplar`) | 32 | 6604 |
| 204 | 264 | `bamboo_sign` | StandingSignBlock (wood type `bamboo`) | 32 | 6636 |
| 205 | 265 | `oak_door` | DoorBlock (block set type `oak`) | 64 | 6668 |
| 206 | 266 | `ladder` | LadderBlock | 8 | 6732 |
| 207 | 267 | `rail` | RailBlock | 20 | 6740 |
| 208 | 268 | `cobblestone_stairs` | StairBlock (base state = default state of the base block) | 80 | 6760 |
| 209 | 269 | `oak_wall_sign` | WallSignBlock (wood type `oak`) | 8 | 6840 |

The sixteen colours of the four collections are, in id order: `white`, `orange`, `magenta`, `light_blue`, `yellow`, `lime`,
`pink`, `gray`, `light_gray`, `cyan`, `purple`, `blue`, `brown`, `green`, `red`, `black`. So `white_bed` is id 119,
`black_bed` id 134, `white_wool` 151, `black_wool` 166, `white_wool_stairs` 167, `black_wool_stairs` 182,
`white_wool_slab` 183 and `black_wool_slab` 198. Per-colour constructor arguments: `BedBlock(colour, settings)`;
the wool block is a plain `Block`; `wool_stairs` is `registerStair(id, <colour>_wool)`; `wool_slab` is
`registerSlab(id, <colour>_wool)`.

The fifteen flowers (ordinals 140 to 154) are `FlowerBlock` with a stew effect (effect, seconds): the effect list is the
suspicious-stew effect; the class is given in the Class column. `wither_rose` is `WitherRoseBlock`, a `FlowerBlock` subclass.

---

## 4. State layout, defaults and index formulas

State order follows 04 §5.2: properties sorted by name, first name slowest. The **index** of a state inside its block is
`Σ vᵢ · Πⱼ>ᵢ cⱼ` over the sorted properties; `true` has index 0 and `false` index 1. Absolute state id =
`B105 + state offset (section 3) + index`. The default index is given in the last column.

| Block (classes) | Properties in sorted order, with value counts | States | Index formula | Default state | Default index |
|---|---|---|---|---|---|
| `yellow_poplar_leaves`, `azalea_leaves`, `flowering_azalea_leaves` (`LeavesBlock`) | distance (7), persistent (2), waterlogged (2) | 28 | `(distance-1)*4 + p*2 + w` | distance 7, persistent false, waterlogged false | 27 |
| `dispenser` | facing (6, `FACING`), triggered (2) | 12 | `f*2 + t` | facing north, triggered false | 1 |
| `note_block` | instrument (27), note (25), powered (2) | 1 350 | `i*50 + note*2 + pw` | instrument harp, note 0, powered false | 1 |
| every `<colour>_bed` (`BedBlock`), `straw_bed` | facing (4), occupied (2), part (2) | 16 | `f*4 + occ*2 + part` (part head 0, foot 1) | facing north, occupied false, part foot | 3 |
| `powered_rail`, `detector_rail` | powered (2), shape (6 straight), waterlogged (2) | 24 | `pw*12 + shape*2 + w` | powered false, shape north_south, waterlogged false | 13 |
| `rail` | shape (10), waterlogged (2) | 20 | `shape*2 + w` | shape north_south, waterlogged false | 1 |
| `piston`, `sticky_piston` | extended (2), facing (6) | 12 | `ex*6 + f` | extended false, facing north | 6 |
| `piston_head` | facing (6), short (2), type (2) | 24 | `f*4 + sh*2 + type` | facing north, short false, type normal | 2 |
| `moving_piston` | facing (6), type (2) | 12 | `f*2 + type` | facing north, type normal | 0 |
| `tall_seagrass` | half (2) | 2 | `half` (upper 0, lower 1) | half lower | 1 |
| every `<colour>_wool_slab` (`SlabBlock`) | type (3), waterlogged (2) | 6 | `type*2 + w` | type bottom, waterlogged false | 3 |
| `oak_stairs`, `cobblestone_stairs`, every `<colour>_wool_stairs` (`StairBlock`) | facing (4), half (2), shape (5), waterlogged (2) | 80 | `f*20 + half*10 + shape*2 + w` (half top 0, bottom 1) | facing north, half bottom, shape straight, waterlogged false | 11 |
| `tnt` | unstable (2) | 2 | `unstable` | unstable false | 1 |
| `chiseled_bookshelf` | facing (4), slot_0_occupied ... slot_5_occupied (2 each) | 256 | `f*64 + Σ s_k * 2^(5-k)` | facing north, all slots false | 63 |
| the thirteen `*_shelf` blocks (`ShelfBlock`) | facing (4), powered (2), side_chain (4), waterlogged (2) | 64 | `f*16 + pw*8 + sc*2 + w` | facing north, powered false, side_chain unconnected, waterlogged false | 9 |
| `wall_torch` | facing (4) | 4 | `f` | facing north | 0 |
| `fire` | age (16), east (2), north (2), south (2), up (2), west (2) | 512 | `age*32 + e*16 + n*8 + s*4 + u*2 + w` | age 0, all sides false | 31 |
| `creaking_heart` | axis (3), creaking_heart_state (3), natural (2) | 18 | `a*6 + state*2 + nat` | axis y, state uprooted, natural false | 7 |
| `chest` | facing (4), type (3), waterlogged (2) | 24 | `f*6 + type*2 + w` | facing north, type single, waterlogged false | 1 |
| `redstone_wire` | east (3), north (3), power (16), south (3), west (3) | 1 296 | `e*432 + n*144 + power*9 + s*3 + w` (up 0, side 1, none 2) | all sides none, power 0 | 1 160 |
| `wheat` | age (8) | 8 | `age` | age 0 | 0 |
| `farmland` | moisture (8) | 8 | `moisture` | moisture 0 | 0 |
| `furnace` | facing (4), lit (2) | 8 | `f*2 + lit` | facing north, lit false | 1 |
| the eleven `*_sign` (standing) | rotation (16), waterlogged (2) | 32 | `rot*2 + w` | rotation 8, waterlogged false | 17 |
| `oak_door` | facing (4), half (2), hinge (2), open (2), powered (2) | 64 | `f*16 + half*8 + hinge*4 + open*2 + pw` (half upper 0, lower 1) | facing north, half lower, hinge left, open false, powered false | 11 |
| `ladder`, `oak_wall_sign` | facing (4), waterlogged (2) | 8 | `f*2 + w` | facing north, waterlogged false | 1 |
| `soul_fire` | none | 1 | | | 0 |
| every other block of the range (`sponge`, `wet_sponge`, `glass`, ores and blocks, sandstones, wool blocks, plants, flowers, mushrooms, torch, spawner, ...) | none | 1 | | | 0 |

Notes:
- `f` is the index of `facing` in its value list: for the four-value `facing` north 0, south 1, west 2, east 3; for the
  six-value `FACING` (dispenser, pistons, piston head, moving piston) north 0, east 1, south 2, west 3, up 4, down 5.
- `soul_fire` has no property although `fire` has six: `SoulFireBlock` adds none.
- The powered rails and the detector rail share one layout; the `shape` of those two is the six-value straight list, so
  `ascending_*` are indices 2 to 5 and no corner shape exists for them.

---

## 5. Block settings

Every block in the range follows. Columns: **H / R** hardness and explosion resistance (resistance after the clamp of
section 2.2); **Tool** "req" when `requiresCorrectToolForDrops` is set; **Instrument** (default `HARP` when blank);
**Sound** (default `STONE` when blank); **Map colour**; **Light**; **Other settings**. Where two ordinals share a row,
every value is the same.

| Ord(s) and key(s) | H / R | Tool | Instrument | Sound | Map colour | Light | Other settings |
|---|---|---|---|---|---|---|---|
| 105 `yellow_poplar_leaves` | 0.2 / 0.2 | | | `POPLAR_LEAVES` | `COLOR_YELLOW` | | `leavesProperties` (random ticks, no occlusion, valid spawn only ocelot or parrot, suffocating never, redstone conductor never, ignited by lava, `POPPED`) |
| 106 `azalea_leaves`, 107 `flowering_azalea_leaves` | 0.2 / 0.2 | | | `AZALEA_LEAVES` | `PLANT` | | `leavesProperties` |
| 108 `sponge` | 0.6 / 0.6 | | | `SPONGE` | `COLOR_YELLOW` | | |
| 109 `wet_sponge` | 0.6 / 0.6 | | | `WET_SPONGE` | `COLOR_YELLOW` | | |
| 110 `glass` | 0.3 / 0.3 | | `HAT` | `GLASS` | `NONE` | | no occlusion; valid spawn, redstone conductor and suffocating all `never` |
| 111 `lapis_ore` | 3.0 / 3.0 | req | `BASEDRUM` | | `STONE` | | |
| 112 `deepslate_lapis_ore` | 4.5 / 3.0 | req | `BASEDRUM` | `DEEPSLATE` | `DEEPSLATE` | | `ofLegacyCopy(lapis_ore)` with map colour, strength and sound replaced; the tool requirement and instrument are inherited |
| 113 `lapis_block` | 3.0 / 3.0 | req | | | `LAPIS` | | |
| 114 `dispenser` | 3.5 / 3.5 | req | `BASEDRUM` | | `STONE` | | |
| 115 `sandstone`, 116 `chiseled_sandstone`, 117 `cut_sandstone` | 0.8 / 0.8 | req | `BASEDRUM` | | `SAND` | | |
| 118 `note_block` | 0.8 / 0.8 | | `BASS` | `WOOD` | `WOOD` | | ignited by lava |
| 119 each `<colour>_bed` | 0.2 / 0.2 | | | `WOOD` | head half: `WOOL`; foot half: the colour's map colour (section 2.8) | | no occlusion, ignited by lava, `POPPED`, bounce restitution 0.75, fall-distance reduction 0.5 |
| 120 `straw_bed` | 0.2 / 0.2 | | | `STRAW_BED` | `COLOR_YELLOW` | | no occlusion, ignited by lava, `POPPED` |
| 121 `powered_rail`, 122 `detector_rail`, 207 `rail` | 0.7 / 0.7 | | | `METAL` | `NONE` | | no collision |
| 123 `sticky_piston`, 134 `piston` | 1.5 / 1.5 | | | | `STONE` | | `pistonProperties` |
| 124 `cobweb` | 4.0 / 4.0 | req | | `COBWEB` | `WOOL` | | force solid on, no collision, `POPPED` |
| 125 `short_grass`, 126 `fern` | 0 / 0 | | | `GRASS` | `PLANT` | | replaceable, no collision, instabreak, offset `XYZ`, ignited by lava, `POPPED` |
| 127 `dead_bush` | 0 / 0 | | | `GRASS` | `WOOD` | | replaceable, no collision, instabreak, ignited by lava, `POPPED` |
| 128 `bush` | 0 / 0 | | | `GRASS` | `PLANT` | | replaceable, no collision, instabreak, ignited by lava, `POPPED` |
| 129 `red_shrub` | 0 / 0 | | | `RED_SHRUB` | `CRIMSON_NYLIUM` | | as `bush` |
| 130 `short_dry_grass`, 131 `tall_dry_grass` | 0 / 0 | | | `GRASS` | `COLOR_YELLOW` | | replaceable, no collision, instabreak, ignited by lava, offset `XYZ`, `POPPED` |
| 132 `seagrass` | 0 / 0 | | | `WET_GRASS` | `WATER` | | replaceable, no collision, instabreak, `POPPED` |
| 133 `tall_seagrass` | 0 / 0 | | | `WET_GRASS` | `WATER` | | as `seagrass` plus offset `XZ` |
| 135 `piston_head` | 1.5 / 1.5 | | | | `STONE` | | no loot table, `IMMOVEABLE` |
| 136 each `<colour>_wool` | 0.8 / 0.8 | | `GUITAR` | `WOOL` | the colour's map colour | | ignited by lava |
| 137 each `<colour>_wool_stairs` | as the wool block of the colour | | | | | | `ofFullCopy(<colour>_wool)`, view blocking `NEAR_PLANE_INTERSECTS_OUTLINE` |
| 138 each `<colour>_wool_slab` | as the wool block of the colour | | | | | | `ofLegacyCopy(<colour>_wool)`, view blocking `NEAR_PLANE_INTERSECTS_OUTLINE` |
| 139 `moving_piston` | -1.0 / 0 | | | | `STONE` | | force solid on, dynamic shape, no loot table, no occlusion, valid spawn / redstone conductor / suffocating `never`, `IMMOVEABLE` |
| 140 to 154 the fifteen flowers | 0 / 0 | | | `GRASS` | `PLANT` | | no collision, instabreak, offset `XZ`, `POPPED` |
| 155 `brown_mushroom` | 0 / 0 | | | `GRASS` | `COLOR_BROWN` | 1 | no collision, random ticks, instabreak, post process = self position, `POPPED` |
| 156 `red_mushroom` | 0 / 0 | | | `GRASS` | `COLOR_RED` | | as `brown_mushroom` without light |
| 157 `gold_block` | 3.0 / 6.0 | req | `BELL` | `METAL` | `GOLD` | | |
| 158 `iron_block` | 5.0 / 6.0 | req | `IRON_XYLOPHONE` | `IRON` | `METAL` | | |
| 159 `bricks` | 2.0 / 6.0 | req | `BASEDRUM` | | `COLOR_RED` | | |
| 160 `tnt` | 0 / 0 | | | `GRASS` | `FIRE` | | instabreak, ignited by lava, redstone conductor `never` |
| 161 `bookshelf` | 1.5 / 1.5 | | `BASS` | `WOOD` | `WOOD` | | ignited by lava |
| 162 `chiseled_bookshelf` | 1.5 / 1.5 | | `BASS` | `CHISELED_BOOKSHELF` | `WOOD` | | ignited by lava |
| 163 `acacia_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `COLOR_ORANGE` | | ignited by lava |
| 164 `bamboo_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `COLOR_YELLOW` | | ignited by lava |
| 165 `birch_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `SAND` | | ignited by lava |
| 166 `cherry_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `TERRACOTTA_WHITE` | | ignited by lava |
| 167 `crimson_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `CRIMSON_STEM` | | ignited by lava |
| 168 `dark_oak_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `COLOR_BROWN` | | ignited by lava |
| 169 `jungle_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `DIRT` | | ignited by lava |
| 170 `mangrove_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `COLOR_RED` | | ignited by lava |
| 171 `oak_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `WOOD` | | ignited by lava |
| 172 `pale_oak_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `QUARTZ` | | ignited by lava |
| 173 `poplar_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `COLOR_LIGHT_GRAY` | | ignited by lava |
| 174 `spruce_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `PODZOL` | | ignited by lava |
| 175 `warped_shelf` | 2.0 / 3.0 | | `BASS` | `SHELF` | `WARPED_STEM` | | ignited by lava |
| 176 `mossy_cobblestone` | 2.0 / 6.0 | req | `BASEDRUM` | | `STONE` | | |
| 177 `obsidian` | 50.0 / 1200.0 | req | `BASEDRUM` | | `COLOR_BLACK` | | `IMMOVEABLE` |
| 178 `torch` | 0 / 0 | | | `WOOD` | `NONE` | 14 | no collision, instabreak, `POPPED` |
| 179 `wall_torch` | 0 / 0 | | | `WOOD` | `NONE` | 14 | `wallVariant(torch, true)` (loot table and description of `torch`), no collision, instabreak, `POPPED` |
| 180 `fire` | 0 / 0 | | | `WOOL` | `FIRE` | 15 | replaceable, no collision, instabreak, `POPPED` |
| 181 `soul_fire` | 0 / 0 | | | `WOOL` | `COLOR_LIGHT_BLUE` | 10 | replaceable, no collision, instabreak, `POPPED` |
| 182 `spawner` | 5.0 / 5.0 | req | `BASEDRUM` | `SPAWNER` | `STONE` | | no occlusion |
| 183 `creaking_heart` | 10.0 / 10.0 | | `BASEDRUM` | `CREAKING_HEART` | `COLOR_ORANGE` | | |
| 184 `oak_stairs` | as `oak_planks`: 2.0 / 3.0 | | `BASS` | `WOOD` | `WOOD` | | `ofLegacyCopy(oak_planks)` (ignited by lava), view blocking `NEAR_PLANE_INTERSECTS_OUTLINE` |
| 185 `chest` | 2.5 / 2.5 | | `BASS` | `WOOD` | `WOOD` | | ignited by lava |
| 186 `redstone_wire` | 0 / 0 | | | | `NONE` | | no collision, instabreak, `POPPED` |
| 187 `diamond_ore` | 3.0 / 3.0 | req | `BASEDRUM` | | `STONE` | | |
| 188 `deepslate_diamond_ore` | 4.5 / 3.0 | req | `BASEDRUM` | `DEEPSLATE` | `DEEPSLATE` | | `ofLegacyCopy(diamond_ore)` with map colour, strength and sound replaced |
| 189 `diamond_block` | 5.0 / 6.0 | req | | `METAL` | `DIAMOND` | | |
| 190 `crafting_table` | 2.5 / 2.5 | | `BASS` | `WOOD` | `WOOD` | | ignited by lava |
| 191 `wheat` | 0 / 0 | | | `CROP` | age 6 or more: `COLOR_YELLOW`; age below 6: `PLANT` | | no collision, random ticks, instabreak, `POPPED` |
| 192 `farmland` | 0.6 / 0.6 | | | `GRAVEL` | `DIRT` | | random ticks, suffocating = `always` |
| 193 `furnace` | 3.5 / 3.5 | req | `BASEDRUM` | | `STONE` | 13 when `lit` | |
| 194 `oak_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` (wood type `oak`) | `WOOD` | | force solid on, no collision, ignited by lava |
| 195 `spruce_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `PODZOL` | | as `oak_sign` |
| 196 `birch_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `SAND` | | as `oak_sign` |
| 197 `acacia_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `COLOR_ORANGE` | | as `oak_sign` |
| 198 `cherry_sign` | 1.0 / 1.0 | | `BASS` | `CHERRY_WOOD` | `TERRACOTTA_WHITE` | | as `oak_sign` |
| 199 `jungle_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `DIRT` | | as `oak_sign` |
| 200 `dark_oak_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `COLOR_BROWN` | | as `oak_sign` |
| 201 `pale_oak_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `QUARTZ` | | as `oak_sign` |
| 202 `mangrove_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `COLOR_RED` | | as `oak_sign` |
| 203 `poplar_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` | `COLOR_LIGHT_GRAY` | | as `oak_sign` |
| 204 `bamboo_sign` | 1.0 / 1.0 | | `BASS` | `BAMBOO_WOOD` | `COLOR_YELLOW` | | as `oak_sign` |
| 205 `oak_door` | 3.0 / 3.0 | | `BASS` | `WOOD` (block set type `oak`) | `WOOD` | | no occlusion, ignited by lava, `POPPED` |
| 206 `ladder` | 0.4 / 0.4 | | | `LADDER` | `NONE` | | force solid off, no occlusion, `POPPED` |
| 208 `cobblestone_stairs` | as `cobblestone`: 2.0 / 6.0 | req | `BASEDRUM` | | `STONE` | | `ofLegacyCopy(cobblestone)`, view blocking `NEAR_PLANE_INTERSECTS_OUTLINE` |
| 209 `oak_wall_sign` | 1.0 / 1.0 | | `BASS` | `WOOD` (wood type `oak`) | `WOOD` | | `wallVariant(oak_sign, true)`; force solid on, no collision, ignited by lava |

Notes:
- The sound type of every sign is set by its constructor from the wood type, overriding the builder: wood types
  `cherry` use `CHERRY_WOOD`, `bamboo` uses `BAMBOO_WOOD`, the others in this range use `WOOD` (`WoodType` constructor
  defaults; the wood type also carries the hanging-sign sound, fence-gate sounds and block set type, which part 3 and
  later parts need). `oak_door`'s sound is the sound type of block set type `oak` (`WOOD`); the oak set type allows
  opening by hand, by wind-charge burst and button activation by arrows.
- The map colour of a sign, shelf or door written "the default map colour of block X" in the artifact is the map colour
  of X's default state. For a log, whose map colour depends on `axis`, the default axis is y and the colour is the
  first of its two colour arguments. The values in the table are those resolved: `spruce_log` top `PODZOL`,
  `jungle_log` top `DIRT`, `dark_oak_log` `COLOR_BROWN`, `mangrove_log` top `COLOR_RED`, `cherry_planks`
  `TERRACOTTA_WHITE`, `pale_oak_planks` `QUARTZ`, `poplar_planks` `COLOR_LIGHT_GRAY`, `bamboo_planks` `COLOR_YELLOW`,
  `acacia_planks` `COLOR_ORANGE`, `birch_planks` `SAND`, `oak_planks` `WOOD` (all read from the registrations of those
  blocks, ordinals 13 to 59, which part 1 specifies).
- The numeric map colour table (`MapColor`) and the sound-type table (`SoundType`: volume, pitch, event names) are not in
  this part: they are 24 part 1 sections 8.1 and 8.4, and the names used here were cross-checked against them (section 5.5).
- `moving_piston` hardness -1.0 means unbreakable (13 §2.1: the break-progress formula returns 0 for hardness -1);
  its resistance is 0 because of the clamp.
- Light emission: only torch (14), wall torch (14), fire (15), soul fire (10), brown mushroom (1) and a lit furnace (13)
  emit light in this range; every other state emits 0.
- Random-ticked states: leaves with `distance` 7 and `persistent` false (class override), brown and red mushroom,
  wheat while not at maximum age (class override), farmland. The `randomTicks` flag on the leaves, mushrooms,
  wheat and farmland settings is the registry-level flag; the class overrides decide the state-level answer.
- Flammability (which blocks burn and how fast) is not a `Properties` setting: `FireBlock.bootStrap` fills it in. The
  entries for this range are tabulated in section 5.7; the separate `ignitedByLava` flag in the settings table above is
  a different mechanism (lava spread) and is not the same set. The tint class per block is section 5.6.

### 5.1 Associated item and loot table

Blocks are registered either by a `BlockItemId` pair (block key, item key) or, for blocks without an item, by a bare
`BlockIds` key (24 part 1 section 11). In this range:

| Case | Blocks |
|---|---|
| Item key differs from block key | `redstone_wire` -> item `redstone` (`BlockItemIds.REDSTONE_DUST`); `wheat` -> item `wheat_seeds` (`BlockItemIds.WHEAT_CROP`) |
| No item (registered by `BlockIds` only; read from the 104 statements after `yellow_poplar_leaves`) | `tall_seagrass`, `piston_head`, `moving_piston`, `wall_torch`, `fire`, `soul_fire`, `oak_wall_sign` |
| Item key = block key | every other block of the range; the four collections give `<colour>_bed`, `<colour>_wool`, `<colour>_wool_stairs`, `<colour>_wool_slab` |

The other two-key pairs of `BlockItemIds` (`tripwire` -> `string`, `powder_snow` -> `powder_snow_bucket`, `cocoa`, `carrots`, `potatoes`, ...) are outside
this range (the `cocoa`, `carrots` and `potatoes` item keys are not repeated here; they belong to the parts that register those blocks). Loot table key: `blocks/<block key>` for every block except: `piston_head` and `moving_piston` (`noLootTable`; the
data pack has no table for them); `wall_torch` (table of `torch`) and `oak_wall_sign` (table of `oak_sign`) through `wallVariant`.
`fire` and `soul_fire` have a table in the data pack whose body is empty apart from a random-sequence name.

### 5.2 Push reaction

Default `PUSH_PULL`. Per block, from the settings above: `POPPED` for the three leaves, every bed and `straw_bed`, `cobweb`,
`short_grass`, `fern`, `dead_bush`, `bush`, `red_shrub`, `short_dry_grass`, `tall_dry_grass`, `seagrass`, `tall_seagrass`,
the fifteen flowers, both mushrooms, `torch`, `wall_torch`, `fire`, `soul_fire`, `redstone_wire`, `wheat`, `oak_door`,
`ladder`; `IMMOVEABLE` for `piston`, `sticky_piston`, `piston_head`, `moving_piston` and `obsidian`; `PUSH_PULL` for everything else
(rails, signs, shelves, chest, furnace, farmland, TNT, spawner, creaking heart and all full blocks).

### 5.3 Light dampening and occlusion shape

Rule (section 2.3): dampening 15 when the occlusion shape is a full block; else 0 when skylight propagates down (outline not
a full block and fluid empty), else 1. Results for this range:

| Blocks | Occlusion shape | Light dampening |
|---|---|---|
| full cubes of section 6 (`sponge` ... `furnace`, wool, ores, bricks, `tnt`, `bookshelf`, `obsidian`, ...) | full block | 15 |
| three leaves | empty (no occlusion) | 1 (class override: `LeavesBlock.getLightDampening` returns the constant 1, read) |
| `glass` | empty | 0 (`TransparentBlock` overrides propagates-skylight-down to true, section 2.3) |
| `spawner` | empty (no occlusion) | 1 (outline is full, so skylight does not propagate) |
| bed halves, `straw_bed`, `oak_door`, `ladder`, `moving_piston` | empty (no occlusion) | 0, or 1 when the fluid state is not empty (waterlogged ladder) |
| `cobweb` | empty (`noCollision` clears can-occlude) | 1 (outline is a full cube, `WebBlock` declares no `getShape` or `propagatesSkylightDown` override, so skylight does not propagate down by the rule of section 2.3; occlusion is empty, so not 15) |
| all other no-collision blocks (plants, flowers, mushrooms, torches, fire, rails, redstone wire, wheat, signs) | empty (`noCollision` clears can-occlude) | 0 (`seagrass`, `tall_seagrass`: 1 because the fluid state is water; waterlogged signs and rails: 1) |
| slabs: bottom/top | the half-block box | 0 (1 when waterlogged); double: full block, 15 |
| stairs | the stair shape of section 6 | 0 (1 when waterlogged) |
| `farmland`, `chest`, shelves, extended piston, `piston_head` | the outline of section 6 | 0 (1 when waterlogged or fluid present) |
| unextended `piston`, `sticky_piston` | full block | 15 |

Basis of the values. **Read:** the three leaves (constant 1 in `LeavesBlock.getLightDampening`), the default rule of section 2.3 and its inputs, the settings that feed it (can-occlude off for `noOcclusion` / `noCollision`) and the propagates-skylight-down overrides of section 2.3 (`TransparentBlock`, `VegetationBlock`). **Inferred:** every other row, derived by applying the rule to the shapes of section 6 and to the `waterlogged` property; among the block classes `getLightDampening` is declared only in `LeavesBlock` (constant 1) and `TintedGlassBlock`, besides the bases `BlockBehaviour` and `BlockStateBase` (read from the method tables; `IceBlock`, `FrostedIceBlock`, `NyliumBlock` and `SpreadingSnowyBlock` declare no such method; an earlier text of this document listed them, which was recall of another version and was wrong for this jar), so no class of this range other than the leaves overrides it; but no per-state value was evaluated. For every block with a `waterlogged` property (rails, slabs, stairs, chest, ladder, signs, shelves, leaves) the waterlogged states have a non-empty fluid state, so skylight does not propagate down and the dampening of a state whose occlusion shape is not a full block is 1 instead of 0 (inferred from the rule; the table rows say "1 when waterlogged"). The "valid spawn" default (top face sturdy and emission below 14) of section 2.1 was read.

### 5.4 Tags per block, and correct-tool tags

Computed from the data-pack tag files of the artifact (`data/minecraft/tags/block/*.json`, with `#` includes resolved) for each
block key of this range. Legend. **Grp**: `S` = the block is in all seven tags `blocks_dolphin_jump`,
`blocks_lava_fire_spread`, `blocks_motion`, `blocks_motion_in_heightmap`, `causes_suffocation`, `entities_can_teleport_to`,
`ice_melts_when_destroyed_above`; `N` = in `blocks_motion_no_leaves` and `blocks_motion_in_heightmap_no_leaves`; `F` = in
`blocks_fluid_flow`; `-` none. **Mineable**: the `mineable/*` tag (tool type). **Needs**: the `needs_*_tool` tag. **Incorrect for**: the
`incorrect_for_<tier>_tool` tags that contain the block. Colour collections are one row. `requiresCorrectToolForDrops` is
in the settings table (section 5); a block with the flag and no `needs_*` tag (for example `dispenser`, `furnace`) needs a
tool of the lowest tier. The tag set is data and can differ in another data pack; the table is what this artifact ships.

| Block(s) | Grp | Mineable | Needs | Incorrect for | Other tags |
|---|---|---|---|---|---|
| `yellow_poplar_leaves`, `azalea_leaves` | SF | hoe | - | - | `completes_find_tree_tutorial`, `lava_pool_stone_cannot_replace`, `leaves`, `parrots_spawnable_on`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `shears_extreme_breaking_speed`, `sword_efficient` |
| `flowering_azalea_leaves` | SF | hoe | - | - | `bee_attractive`, `completes_find_tree_tutorial`, `flowers`, `lava_pool_stone_cannot_replace`, `leaves`, `parrots_spawnable_on`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `shears_extreme_breaking_speed`, `sword_efficient` |
| `sponge`, `wet_sponge` | SNF | hoe | - | - | - |
| `glass` | SNF | - | - | - | `impermeable` |
| `lapis_ore`, `deepslate_lapis_ore` | SNF | pickaxe | needs_stone_tool | gold, wooden | `lapis_ores`, `ores` |
| `lapis_block` | SNF | pickaxe | needs_stone_tool | gold, wooden | - |
| `dispenser` | SNF | pickaxe | - | - | - |
| `sandstone` | SNF | pickaxe | - | - | `sculk_replaceable`, `sculk_replaceable_world_gen` |
| `chiseled_sandstone`, `cut_sandstone` | SNF | pickaxe | - | - | - |
| `note_block` | SNF | axe | - | - | - |
| `<colour>_bed` | SNF | - | - | - | `beds`, `cats_can_lie_on`, `cats_can_sit_on`, `speeds_up_zombie_villager_curing`, `villager_babies_can_jump_on_bed`, `villagers_can_sleep_on_bed` |
| `straw_bed` | SNF | hoe | - | - | `washed_away_by_fluids` |
| `powered_rail`, `detector_rail` | - | pickaxe | - | - | `prevent_mob_spawning_inside`, `rails`, `washed_away_by_fluids` |
| `sticky_piston` | SNF | pickaxe | - | - | - |
| `cobweb` | - | - | - | - | `fall_damage_resetting`, `washed_away_by_fluids` |
| `short_grass`, `fern` | - | - | - | - | `edible_for_sheep`, `enchantment_power_transmitter`, `replaceable`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `washed_away_by_fluids` |
| `dead_bush`, `bush` | - | - | - | - | `enchantment_power_transmitter`, `replaceable`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `washed_away_by_fluids` |
| `red_shrub` | - | - | - | - | `enchantment_power_transmitter`, `replaceable`, `replaceable_by_mushrooms`, `washed_away_by_fluids` |
| `short_dry_grass`, `tall_dry_grass` | - | - | - | - | `edible_for_sheep`, `enchantment_power_transmitter`, `replaceable`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `washed_away_by_fluids` |
| `seagrass` | - | - | - | - | `enchantment_power_transmitter`, `replaceable`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `underwater_bonemeals`, `washed_away_by_fluids` |
| `tall_seagrass` | - | - | - | - | `enchantment_power_transmitter`, `replaceable`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `washed_away_by_fluids` |
| `piston`, `piston_head` | SNF | pickaxe | - | - | - |
| `<colour>_wool` | SNF | - | - | - | `dampens_vibrations`, `occludes_vibration_signals`, `shears_major_breaking_speed`, `wool` |
| `<colour>_wool_stairs` | SNF | - | - | - | `dampens_vibrations`, `shears_major_breaking_speed`, `stairs`, `wool_stairs` |
| `<colour>_wool_slab` | SNF | - | - | - | `dampens_vibrations`, `shears_major_breaking_speed`, `slabs`, `wool_slabs` |
| `moving_piston` | SNF | - | - | - | `dragon_immune`, `maintains_farmland`, `wither_immune` |
| `dandelion` | - | - | - | - | `bee_attractive`, `enderman_holdable`, `flowers`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `small_flowers`, `washed_away_by_fluids` |
| `golden_dandelion` | - | - | - | - | `enderman_holdable`, `flowers`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `small_flowers`, `washed_away_by_fluids` |
| `torchflower` | - | - | - | - | `bee_attractive`, `enderman_holdable`, `flowers`, `maintains_farmland`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `small_flowers`, `washed_away_by_fluids` |
| `poppy`, `blue_orchid`, `allium`, `azure_bluet`, `red_tulip`, `orange_tulip`, `white_tulip`, `pink_tulip`, `oxeye_daisy`, `cornflower` | - | - | - | - | `bee_attractive`, `enderman_holdable`, `flowers`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `small_flowers`, `washed_away_by_fluids` |
| `wither_rose` | - | - | - | - | `bee_attractive`, `cat_does_not_teleport_to`, `dangerous_for_teleportation`, `enderman_does_not_teleport_to`, `enderman_holdable`, `flowers`, `happy_ghast_avoids`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `small_flowers`, `washed_away_by_fluids`, `wither_immune_to`, `wither_skeleton_immune_to` |
| `lily_of_the_valley` | - | - | - | - | `bee_attractive`, `enderman_holdable`, `flowers`, `replaceable_by_mushrooms`, `replaceable_by_trees`, `small_flowers`, `washed_away_by_fluids` |
| `brown_mushroom`, `red_mushroom` | - | - | - | - | `enderman_holdable`, `replaceable_by_mushrooms`, `washed_away_by_fluids` |
| `gold_block` | SNF | pickaxe | needs_iron_tool | copper, gold, stone, wooden | `beacon_base_blocks`, `guarded_by_piglins` |
| `iron_block` | SNF | pickaxe | needs_stone_tool | gold, wooden | `beacon_base_blocks` |
| `bricks` | SNF | pickaxe | - | - | - |
| `tnt` | SNF | - | - | - | `enderman_holdable` |
| `bookshelf` | SNF | axe | - | - | `enchantment_power_provider` |
| `chiseled_bookshelf` | SNF | axe | - | - | - |
| `acacia_shelf`, `bamboo_shelf`, `birch_shelf`, `cherry_shelf`, `crimson_shelf`, `dark_oak_shelf`, `jungle_shelf`, `mangrove_shelf`, `oak_shelf`, `pale_oak_shelf`, `poplar_shelf`, `spruce_shelf`, `warped_shelf` | SNF | axe | - | - | `wooden_shelves` |
| `mossy_cobblestone` | SNF | pickaxe | - | - | - |
| `obsidian` | SNF | pickaxe | needs_diamond_tool | copper, gold, iron, stone, wooden | `dragon_immune`, `nether_portal_frame` |
| `torch` | - | - | - | - | `wall_post_override`, `washed_away_by_fluids` |
| `wall_torch` | - | - | - | - | `washed_away_by_fluids` |
| `fire` | - | - | - | - | `cat_does_not_teleport_to`, `dangerous_for_teleportation`, `dragon_transparent`, `enchantment_power_transmitter`, `enderman_does_not_teleport_to`, `fire`, `happy_ghast_avoids`, `replaceable`, `washed_away_by_fluids` |
| `soul_fire` | - | - | - | - | `cat_does_not_teleport_to`, `dangerous_for_teleportation`, `dragon_transparent`, `enchantment_power_transmitter`, `enderman_does_not_teleport_to`, `fire`, `piglin_repellents`, `replaceable`, `washed_away_by_fluids` |
| `spawner` | SNF | pickaxe | - | - | `cannot_place_basalt_pillar_on`, `features_cannot_replace`, `lava_pool_stone_cannot_replace` |
| `creaking_heart` | SNF | axe | - | - | - |
| `oak_stairs` | SNF | axe | - | - | `stairs`, `wooden_stairs` |
| `chest` | SNF | axe | - | - | `cannot_place_basalt_pillar_on`, `cats_can_sit_on`, `features_cannot_replace`, `guarded_by_piglins`, `lava_pool_stone_cannot_replace` |
| `redstone_wire` | - | - | - | - | `washed_away_by_fluids` |
| `diamond_ore`, `deepslate_diamond_ore` | SNF | pickaxe | needs_iron_tool | copper, gold, stone, wooden | `diamond_ores`, `ores` |
| `diamond_block` | SNF | pickaxe | needs_iron_tool | copper, gold, stone, wooden | `beacon_base_blocks` |
| `crafting_table` | SNF | axe | - | - | - |
| `wheat` | - | - | - | - | `bee_growables`, `crops`, `maintains_farmland`, `washed_away_by_fluids` |
| `farmland` | SNF | shovel | - | - | `grows_crops`, `support_override_cactus_flower`, `supports_azalea`, `supports_big_dripleaf`, `supports_crimson_fungus`, `supports_crimson_roots`, `supports_crops`, `supports_dry_vegetation`, `supports_mangrove_propagule`, `supports_melon_stem`, `supports_melon_stem_fruit`, `supports_nether_sprouts`, `supports_pumpkin_stem`, `supports_pumpkin_stem_fruit`, `supports_stem_crops`, `supports_stem_fruit`, `supports_vegetation`, `supports_warped_fungus`, `supports_warped_roots`, `supports_wither_rose` |
| `furnace` | SNF | pickaxe | - | - | `cats_can_sit_on` |
| `oak_sign`, `spruce_sign`, `birch_sign`, `acacia_sign`, `cherry_sign`, `jungle_sign`, `dark_oak_sign`, `pale_oak_sign`, `mangrove_sign`, `poplar_sign`, `bamboo_sign` | F | axe | - | - | `all_signs`, `signs`, `standing_signs`, `wall_post_override` |
| `oak_door` | SNF | axe | - | - | `doors`, `mob_interactable_doors`, `wooden_doors` |
| `ladder` | - | axe | - | - | `climbable`, `fall_damage_resetting` |
| `rail` | - | pickaxe | - | - | `prevent_mob_spawning_inside`, `rails`, `washed_away_by_fluids` |
| `cobblestone_stairs` | SNF | pickaxe | - | - | `stairs` |
| `oak_wall_sign` | F | axe | - | - | `all_signs`, `signs`, `wall_post_override`, `wall_signs` |

### 5.5 Map colour and sound type values

The names are in the table of section 5. The numeric map-colour table (id, base colour, brightness shades) and the
`SoundType` table (volume, pitch, five sound events) are in 24 part 1 sections 8.1 and 8.4. The cross-check was done in
a cross-check: all 27 map-colour names and all 24 sound-type names used in section 5 exist there (Open questions 2 and 3,
closed). Two names worth noting because they are not in the "standard" list: `CROP` (wheat) and `RED_SHRUB` are in the
exception table of 24 part 1 section 8.4, and the colour `NONE` is id 0 of section 8.1.

### 5.6 Tint class per block

Which tint source colours a block's model is decided by the client class `BlockColors.createDefault` (a registry of tint
source lists per block; 24 part 1 section 9.3 is the full table and the rule "every block that is not in it has no tint").
It is data of the client, not of the block classes. For the blocks of ordinals 105 to 209 the read result (the block
fields referenced by `createDefault` were listed from the class and compared with this range) is:

| Tint class | Blocks of this range | Source (24 part 1 section 9.3) |
|---|---|---|
| grass | `short_grass`, `fern`, `bush` | `grass()` (defined in 24 part 1 section 9.1) |
| redstone | `redstone_wire` | `redstone()` (power-indexed ramp, section 7.9) |
| none | everything else, in particular the three leaves of this range (`yellow_poplar_leaves`, `azalea_leaves`, `flowering_azalea_leaves` are not registered there; their falling-leaf particle colour is a class constant, section 7.9), `red_shrub`, `short_dry_grass`, `tall_dry_grass`, `dead_bush`, `seagrass`, `tall_seagrass`, `wheat`, the flowers, the mushrooms, the wool family, farmland | no entry |

No block of this range has a foliage or water tint registered under its own key.


### 5.7 Burnable (flammability) entries of this range

`FireBlock.bootStrap` registers, for each listed block, two integers through `setFlammable(block, a, b)`: `a` is stored in
the table named `igniteOdds` and `b` in the table named `burnOdds`. A block that is not registered has 0 in both. `canBurn` is
true when the block's ignite number is above 0; and both lookups return 0 for any state whose `waterlogged` property is true.
(What the two numbers do in fire spread and burn-out is not specified in a separate fire part of 29b (none exists); the fire constants that are documented are in 17 sections 3.3 and 3.3a and in 29b part 1, and the fire random-tick and spread engine is otherwise unspecified, see Open question 4; the numbers are constants here, read from the
bytecode of the initialiser and of the four colour-collection callbacks.) The entries that fall in ordinals 105 to 209:

| (ignite, burn) | Blocks of this range |
|---|---|
| (30, 60) | `yellow_poplar_leaves`, `azalea_leaves`, `flowering_azalea_leaves`, `straw_bed`, all sixteen `<colour>_wool`, all sixteen `<colour>_wool_stairs`, all sixteen `<colour>_wool_slab` (the three collections are registered by a per-colour callback, each with 30 and 60) |
| (30, 20) | `bookshelf`, the eleven registered shelves: `acacia_shelf`, `bamboo_shelf`, `birch_shelf`, `cherry_shelf`, `dark_oak_shelf`, `jungle_shelf`, `mangrove_shelf`, `oak_shelf`, `pale_oak_shelf`, `poplar_shelf`, `spruce_shelf` (read in `FireBlock.bootStrap`) |
| (15, 100) | `tnt` |
| (60, 100) | `short_grass`, `fern`, `dead_bush`, `bush`, `red_shrub`, `short_dry_grass`, `tall_dry_grass`, and the flowers `dandelion`, `golden_dandelion`, `torchflower`, `poppy`, `blue_orchid`, `allium`, `azure_bluet`, `red_tulip`, `orange_tulip`, `white_tulip`, `pink_tulip`, `oxeye_daisy`, `cornflower`, `wither_rose`, `lily_of_the_valley` |
| (5, 20) | `oak_stairs` |
| not registered (0, 0) | every other block of the range, including `crimson_shelf` and `warped_shelf` (not registered in `FireBlock.bootStrap`; both are still `ignitedByLava`), all `<colour>_bed`, `note_block`, `chiseled_bookshelf`, `chest`, `crafting_table`, the signs, `oak_door`, `ladder`, `creaking_heart`, `redstone_wire`, `seagrass`, `tall_seagrass`, both mushrooms, `wheat`, `farmland`, `cobweb`, `fire`, `soul_fire`, `cobblestone_stairs` and every full-block stone, ore or metal block |

Notes. A block can be `ignitedByLava` (section 5 settings) without being registered here (for example `note_block`,
`chest`, `crafting_table`, the beds, the signs and `oak_door`), and the reverse. Blocks outside this range that share the
table (planks, logs, slabs, fences, fence gates, other stairs, carpets, vines and so on) belong to the parts that register
them. The registered number pairs seen in the whole initialiser are (5, 20), (5, 5), (30, 60), (30, 20), (15, 100),
(60, 100), (60, 20), (15, 20), (5, 100), (60, 60) and (15, 60).

---

## 6. Shapes

Shapes use the notation of section 1.3. "Collision" is the collision shape; where nothing is said the collision shape
follows section 2.3 (empty for blocks with no collision, otherwise the outline). Occlusion follows section 2.3 (empty
for blocks with can-occlude off).

| Block(s) | Outline shape | Collision | Notes |
|---|---|---|---|
| full cubes: `sponge`, `wet_sponge`, `lapis_ore`, `deepslate_lapis_ore`, `lapis_block`, `dispenser`, the three sandstones, `note_block`, all `<colour>_wool`, `gold_block`, `iron_block`, `bricks`, `tnt`, `bookshelf`, `chiseled_bookshelf`, `mossy_cobblestone`, `obsidian`, `creaking_heart`, `diamond_ore`, `deepslate_diamond_ore`, `diamond_block`, `crafting_table`, `furnace` | `[0,0,0 - 16,16,16]` | same | |
| `glass` | full cube | same | visual shape empty; shade brightness 1.0; skylight propagates down; adjacent faces of the same block are not rendered (`TransparentBlock`, `HalfTransparentBlock`) |
| `yellow_poplar_leaves`, `azalea_leaves`, `flowering_azalea_leaves` | full cube | full cube | block-support shape empty; light dampening 1; not an occluder (no occlusion) |
| `spawner` | full cube | full cube | not an occluder |
| `cobweb` | full cube | empty | |
| `short_grass`, `fern`, `dead_bush` | `[2,0,2 - 14,13,14]` | empty | |
| `bush`, `red_shrub` | `[0,0,0 - 16,13,16]` | empty | `BushBlock` height 13 |
| `short_dry_grass` | `[2,0,2 - 14,10,14]` | empty | |
| `tall_dry_grass` | `[1,0,1 - 15,16,15]` | empty | |
| `seagrass` | `[2,0,2 - 14,12,14]` | empty | |
| `tall_seagrass` | `[2,0,2 - 14,16,14]` (both halves) | empty | |
| the fifteen flowers | `[5,0,5 - 11,10,11]` moved by the offset of section 2.7 | empty | |
| `brown_mushroom`, `red_mushroom` | `[5,0,5 - 11,6,11]` | empty | |
| `torch` | `[6,0,6 - 10,10,10]` | empty | |
| `wall_torch` | facing-authored `[5.5,3,11 - 10.5,13,16]` (`boxZ(5,3,13,11,16)`), table indexed by `facing` | empty | east: `[0,3,5.5 - 5,13,10.5]`; south: `[5.5,3,0 - 10.5,13,5]`; west: `[11,3,5.5 - 16,13,10.5]` |
| `fire`, `soul_fire` | flat sheet `[0,0,0 - 16,1,16]` (soul fire always; fire when no side flag is set) | empty | `fire` with at least one of `north`, `east`, `south`, `west`, `up` true: the union over the true flags of one sheet each: north `[0,0,0 - 16,16,1]`, east `[15,0,0 - 16,16,16]`, south `[0,0,15 - 16,16,16]`, west `[0,0,0 - 1,16,16]`, up `[0,15,0 - 16,16,16]`; the flat sheet is not included then. `fire` ignores `age` for shape. (read: `FireBlock.makeShapes` builds one `boxZ(16, 0, 1)` piece, the north sheet, and runs it through `Shapes.rotateAll`; east, south and west are the Y turns of section 2.6 and up is the `X_270` turn; a state's shape is the union over its true flags, and the flat sheet when that union is empty) |
| `powered_rail`, `detector_rail`, `rail` | flat: `[0,0,0 - 16,2,16]`; for shapes ascending_east/west/north/south: `[0,0,0 - 16,8,16]` | empty | one table for all three rails (`BaseRailBlock`) |
| `piston`, `sticky_piston` | not extended: full cube. Extended: facing-authored `[0,0,4 - 16,16,16]`; the six-direction table (`rotateAll`) indexed by `facing` | same | `useShapeForLightOcclusion` is true when extended |
| `piston_head` | facing-authored platform `[0,0,0 - 16,16,4]` plus an arm `[6,6,4 - 10,10,20]` (short false) or `[6,6,4 - 10,10,16]` (short true); six-direction table indexed by `facing` | same | the arm of the long head ends 4 units past the block boundary on the side of the piston body (z 16 to 20) |
| `moving_piston` | empty (`getShape` returns the empty shape) | dynamic: see the rule after this table | render shape `INVISIBLE`; not breakable |
| `slab` family: `<colour>_wool_slab` | bottom `[0,0,0 - 16,8,16]`; top `[0,8,0 - 16,16,16]`; double: full cube | same | `useShapeForLightOcclusion` true unless double |
| stairs: `oak_stairs`, `cobblestone_stairs`, `<colour>_wool_stairs` | see below | same | `useShapeForLightOcclusion` true |
| `chest` | type single: `[1,0,1 - 15,14,15]`. type left or right: facing-authored `[1,0,0 - 15,14,15]` looked up with the connected direction | same | connected direction = clockwise(facing) for type left, counter-clockwise(facing) for type right |
| `redstone_wire` | by state, see below | empty | |
| `wheat` | `[0,0,0 - 16, 2+2*age ,16]` for age 0 to 7: heights 2, 4, 6, 8, 10, 12, 14, 16 | empty | |
| `farmland` | `[0,0,0 - 16,15,16]` | same | `useShapeForLightOcclusion` true |
| standing signs (11 blocks) | `[4,0,4 - 12,16,12]` | empty | |
| `oak_wall_sign` | facing-authored `[0,4.5,14 - 16,12.5,16]`, table indexed by `facing` | empty | |
| `oak_door` | facing-authored `[0,0,13 - 16,16,16]`, direction chosen as below | same | |
| `ladder` | facing-authored `[0,0,13 - 16,16,16]`, table indexed by `facing` | same | |
| `<colour>_bed` | see below | same | |
| `straw_bed` | see below | same | |
| `<x>_shelf` (13 blocks) | facing-authored union of `[0,0,13 - 16,16,16]`, `[0,12,11 - 16,16,13]` and `[0,0,11 - 16,4,13]`, table indexed by `facing` | same | `useShapeForLightOcclusion` true |

**`moving_piston` collision rule** (read: `MovingPistonBlock.getCollisionShape`, `PistonMovingBlockEntity.getCollisionShape`, `getExtendedProgress`, `getMovementDirection`). The block's outline (`getShape`) is always empty. Its collision shape is the empty shape when the position has no moving-piston block entity; otherwise it is computed from the block entity, whose fields are `movedState` (the block being carried), `direction` (the push direction), `extending`, `isSourcePiston` and `progress` (float, 0 to 1):

1. `extendedProgress = progress - 1` when `extending`, else `1 - progress` (float32).
2. `movementDirection = direction` when `extending`, else the opposite of `direction`.
3. Base shape: when `extending` is false **and** `isSourcePiston` is true **and** `movedState` is a piston base, the collision shape of that piston with `extended` set to true at the position; otherwise empty.
4. Early return: when a per-thread "no-clip" direction (set by the entity-movement code while it moves an entity carried by the piston) equals `movementDirection` and `progress < 1`, the base shape of step 3 alone is the result.
5. The carried state: when `isSourcePiston`, a `piston_head` state with `facing = direction` and `short = (extending XOR (1 - progress < 0.25))`; otherwise `movedState`.
6. Offset per axis: the direction's step component (float) times `extendedProgress`, widened to double.
7. Result: the union of the base shape and the carried state's collision shape moved by that offset.

The no-clip thread-local and the entity push code that sets it, and the rules that create and advance the block entity (`progress` step per tick, finishing), are not specified (Open question 21).

**Stairs.** Authoring (facing north, bottom half): the lower slab `[0,0,0 - 16,8,16]` plus an upper part that depends on
the shape.
- outer (a corner): the upper part is the quarter `[0,8,0 - 8,16,8]` (north-west);
- straight: the upper part is the north half `[0,8,0 - 16,16,8]` (the outer quarter plus the same quarter turned by
  `Y_90`, which is `[8,8,0 - 16,16,8]`);
- inner: the upper part is the north half plus the east half: `[0,8,0 - 16,16,8]` and `[8,8,0 - 16,16,16]` (the straight
  shape plus the straight shape turned by `Y_90`).
For `half = top` the same shapes mirrored vertically (y becomes 16 - y). Each of the six shapes (bottom and top times
outer, straight, inner) is turned for the four facings by the `rotateHorizontal` rule. Selection: take the bottom or top
set by `half`; shape `straight` uses the straight shape, `inner_left` and `inner_right` the inner shape, `outer_left`
and `outer_right` the outer shape; the direction used to index the turned table is `facing` for straight, outer_left
and inner_right, counter-clockwise(facing) for inner_left, and clockwise(facing) for outer_right. (The artifact's
`switch` over `StairsShape` uses a compiler-generated index with the order straight, outer_left, inner_right, inner_left,
outer_right; the mapping above was resolved through that table.)

Worked check: `outer_left` facing north is the quarter at north-west; `outer_right` facing north uses the east table
entry of the outer shape: the quarter `[8,8,0 - 16,16,8]`, north-east.

**Redstone wire.** Pieces (in sixteenths, authored for north): dot `[3,0,3 - 13,1,13]`; side `[3,0,0 - 13,1,8]`;
up `[3,0,0 - 13,16,1]`. The shape of a state is the dot plus, for each of the four directions: nothing when that
direction's value is `none`; the side piece turned to that direction when it is `side`; the side piece and the up piece,
both turned to that direction, when it is `up`. The dot is always included (the artifact's base argument; the loop
union starts from it, inferred from the lambda's parameter list). The value of `power` does not change the shape.

**Beds.** Pieces: leg A `[0,0,0 - 3,3,3]`, leg B = leg A turned by `Y_90` = `[13,0,0 - 16,3,3]`, mattress
`[0,3,0 - 16,9,16]`. Bed shape (facing-authored, key north) = mattress plus both legs. The table is indexed by the
direction opposite to the **connected direction**, where the connected direction is the direction from this half to the
other half: `facing` for the foot half, the opposite of `facing` for the head half. So the key is the opposite of
`facing` for the foot and `facing` for the head, and the legs are at the end away from the other half.
`straw_bed`: base `[0,0,0 - 16,4,16]` (a 16-wide column from y 0 to 4); pillow `[0,0,0 - 16,5,8]`. The foot half uses
the base alone, the head half the base plus the pillow; both are turned like the bed and indexed by the same key.

**Door.** The shape key is `facing` when the door is closed. When open, the key is counter-clockwise(facing) if
`hinge` is right, clockwise(facing) if `hinge` is left. The same shape is used for both halves.

### 5.8 Blocks that carry the ignited-by-lava flag

One list of the blocks of this range with the flag (the settings table of section 5 carries it per row; read from the builder calls). Direct `ignitedByLava()`: the three leaves (through `leavesProperties`), `note_block`, every `<colour>_bed`, `straw_bed`, `short_grass`, `fern`, `dead_bush`, `bush`, `red_shrub`, `short_dry_grass`, `tall_dry_grass`, `tnt`, `bookshelf`, `chiseled_bookshelf`, all thirteen shelves (`acacia_shelf` to `warped_shelf`, including `crimson_shelf` and `warped_shelf`), `chest`, `crafting_table`, `oak_sign` and the other standing signs, `oak_wall_sign`, `oak_door`, every `<colour>_wool`, and `oak_stairs` (copied from `oak_planks` by `ofLegacyCopy`, which copies the flag). `<colour>_wool_slab` copies the flag from its wool through `ofLegacyCopy`; `<colour>_wool_stairs` uses `ofFullCopy`, whose copied field set was not read (the flag is therefore (inferred) true for both). Not flagged: `cobweb`, the flowers, the mushrooms, `seagrass`, `tall_seagrass`, `wheat`, `farmland`, `ladder`, `creaking_heart`, `torch`, `fire`, `soul_fire`, `spawner`, `redstone_wire`, the pistons and `cobblestone_stairs`. The set differs from the burnable table of 5.7 (for example `crimson_shelf`, the beds, `note_block` and `chest` are flagged but not burnable, and the flowers are burnable but not flagged).

---

## 7. Placement state, survival, replaceability and other class rules

These are the per-class rules that decide which state a placement gets, whether a state may stay in the
world, and whether another block may replace it. The engines that call them (neighbour updates, scheduled ticks) are
specified in 29 sections 3 to 5, 29b and 31; the constants of the rules are here.

### 7.1 Replaceable blocks

`replaceable()` is set on: `short_grass`, `fern`, `dead_bush`, `bush`, `red_shrub`, `short_dry_grass`,
`tall_dry_grass`, `seagrass`, `tall_seagrass`, `fire`, `soul_fire` (and on `air` in part 1). A block placement may
replace a state whose `canBeReplaced` is true. Slabs override this: see 7.3. The flowers, torches, mushrooms, rails,
redstone wire and crops are **not** replaceable.

### 7.2 Rules by class

| Class | Placement state | Survival (`canSurvive`) and neighbour reactions |
|---|---|---|
| Leaves (`LeavesBlock`) | `persistent` true; `waterlogged` true when the fluid at the position is water; `distance` as computed in 7.4 | no `canSurvive`; a random tick removes the block (dropping its resources) when `persistent` is false and `distance` is 7; a scheduled tick recomputes `distance`; a neighbour shape update re-schedules a tick (delay 1) when `neighbour distance + 1` differs from this block's `distance`; waterlogged leaves schedule a water tick (7.5) |
| `sponge`, `wet_sponge` | default state | `sponge` tries to absorb water when placed or when a neighbour changes (7.6); `wet_sponge` turns into `sponge` when placed in an environment whose attribute `water_evaporates` is true (level event 2009, sound `wet_sponge_dries`) |
| `dispenser` | `facing` = opposite of the player's nearest looking direction (six-way); `triggered` false | none |
| `note_block` | instrument chosen by 7.10 (note block); note 0; powered false | an update from above or below recomputes the instrument; a neighbour signal change sets `powered` |
| Beds | `facing` = the player's horizontal direction; refused (no state) unless the block at `pos + facing` is replaceable and inside the world border | if the other half is gone (the block at the connected position is not the same block, or its `part` is not the opposite part) the block becomes air; the occupied flag is copied between halves |
| Rails | `waterlogged` from the fluid; `shape` = east_west when the player's horizontal direction is east or west, else north_south | a rail needs a block below that supports a rigid block (top face sturdy, rigid); `shape` is recomputed by neighbour updates (rail connection by `RailState`: not specified in this document; see 24 part 3 Open question 5 and 29 for the neighbour-update entry points); removed when the rail or the slope's raised neighbour loses support |
| Pistons | `facing` = opposite of the nearest looking direction; `extended` false | extension and pushing: the piston engine (`PistonStructureResolver`, `PistonMovingBlockEntity`) is not specified in any existing document (Open question 5); only the shapes (section 6), the block-event queue (33 step 9, 29 section on block events) and the move-by-piston update flag (29) exist |
| `piston_head` | state set by the piston | survives when the block on its back side (opposite of `facing`) is the matching piston (`piston` for type normal, `sticky_piston` for sticky) with `extended` true and the same `facing`, or is a `moving_piston` with the same `facing`; otherwise it becomes air; when removed it also destroys a fitting base |
| Plants (`VegetationBlock` subclasses) | default state | survives when the block below satisfies the class's rule (table 7.3); otherwise becomes air on the next shape update; skylight propagates down when the fluid state is empty |
| `tall_seagrass`, other double plants | `half` lower at the clicked position; refused when the position is at the top of the world or the block above is not replaceable; `tall_seagrass` additionally needs full water above | the upper half survives only while the block below is the same block with `half` lower; the lower half follows the plant rule, and for `tall_seagrass` also needs the fluid at its position to be full water; the upper half's shape update removes it when the lower half is gone, and the lower half removes itself when its own support is lost |
| `seagrass` | refused unless the fluid at the position is water and full | survives on a block whose top face is sturdy (full) and that is not in tag `cannot_support_seagrass`; its fluid state is always water source |
| `wheat` | default state | survives when the block below is in tag `supports_crops` and the raw brightness at the position (sky darkening 0) is at least 8; random tick growth needs raw brightness at least 9 (growth rules: 29b part 2 section 3) |
| Mushrooms | default state | survives when the block below is in tag `overrides_mushroom_light_requirement`, or the raw brightness at the position is below 13 and the block below is a solid-render block (its occlusion shape is a full block); a random tick spreads with chance 1 in 25 (spreading: 29b part 5) |
| Flowers | default state | block below in tag `supports_vegetation`; `wither_rose`: tag `supports_wither_rose` |
| `dead_bush`, `short_dry_grass`, `tall_dry_grass` | default state | block below in tag `supports_dry_vegetation` |
| `short_grass`, `fern`, `bush`, `red_shrub` | default state | block below in tag `supports_vegetation` |
| `torch` | default | the top face of the block below must support the centre (`canSupportCenter`: the centre support type; for a block in tag `unstable_bottom_center` only when looking at it from below, which does not apply to the top face) |
| `wall_torch` | tries the player's nearest looking directions in order, skipping vertical ones, and takes the first for which the torch survives, with `facing` = opposite of that direction; refused when none works | the block at `pos + opposite(facing)` must have a sturdy full face toward the torch; otherwise air |
| `fire` | `fire` unless the block below can host soul fire (tag `soul_fire_base_blocks`), then `soul_fire`; for `fire`: if the block below can burn or has a sturdy top face the default state (all flags false); otherwise the four side flags and `up` set from whether the neighbour burns | survives when the block below has a sturdy top face or any of the six neighbours can burn; `can burn` = the neighbour's ignite chance in the flammability table is above 0 (table in 5.7). `soul_fire` survives when the block below is in tag `soul_fire_base_blocks` |
| `spawner`, `creaking_heart`, `furnace`, `crafting_table`, `dispenser`, `chest`, `chiseled_bookshelf`, shelves | see own rows | no support rule |
| `creaking_heart` | `axis` = the axis of the clicked face; `creaking_heart_state` then recomputed from the surroundings; `natural` false (rules read: 7.12) | a shape update schedules a block tick after 1 game tick; the tick recomputes the state (7.12) |
| `chest` | `facing`, `type` and `waterlogged` as in 7.7 (read) | shape update rules in 7.7 step 5 (read) |
| `redstone_wire` | connection state computed from the neighbours, starting from the cross state (all four sides `side`) and keeping the previous `power` | survives when the block below has a sturdy top face or is a hopper; otherwise dropped as an item; a wire with no connection and a dot shape is rewritten as a cross when the player uses it (and the reverse), subject to the player's build permission |
| `farmland` | default state; when it could not survive at the position the placement gives `dirt`'s default state instead | survives when the block above is not legacy-solid, or is in tag `maintains_farmland`; when it cannot survive a scheduled tick turns it into `dirt`; random tick: when water is near (a fluid in tag `water` in the box from offset (-4, 0, -4) to (4, 1, 4) around the farmland position, read in `FarmlandBlock.isNearWater`; moisture and trampling: 29b part 2 section 9, where the trampling test is a bounding-box volume above 0.512) or rain falls on the block above, `moisture` becomes 7 if it was below 7; otherwise `moisture` decreases by 1 when above 0; otherwise (moisture 0) it turns into `dirt` unless the block above is in tag `maintains_farmland` |
| `furnace` | `facing` = opposite of the player's horizontal direction; `lit` false | none |
| Standing signs | `rotation` = `round((yaw + 180) x 16 / 360) & 15` (read: `StandingSignBlock.getStateForPlacement` calls `RotationSegment.convertToSegment` on the placement rotation plus 180.0f; that is a 4-bit `SegmentedAnglePrecision`: multiply by the float 16/360, `Math.round` (half rounds up), then AND with 15; float arithmetic); `waterlogged` from the fluid | survives when the block below is legacy-solid; becomes air when that is lost |
| `oak_wall_sign` | tries the nearest looking horizontal directions, `facing` = the opposite; `waterlogged` from the fluid | the block at `pos + opposite(facing)` must be legacy-solid |
| `oak_door` | refused when the position is at the top of the world or the block above is not replaceable; `facing` = the player's horizontal direction; `hinge` chosen by the rule of 7.11 (read); `powered` and `open` = whether the position or the position above has a neighbour signal; `half` lower | the lower half survives when the top face of the block below is sturdy; the upper half survives when the block below is this same door block; when one half is lost the other becomes air |
| `ladder` | refused when the placement does not replace the clicked block and the block behind the clicked face (`clickedPos + opposite(clickedFace)`) is a ladder whose `facing` equals the clicked face; otherwise the first of the player's nearest looking directions that is horizontal and for which the ladder survives, `facing` = the opposite of that direction; refused when none | the block on the back side (`pos + opposite(facing)`) must have a sturdy full face toward the ladder |
| Slabs, stairs | see 7.3 and 7.8 (read) | water tick when waterlogged (7.5) |
| Shelves | `facing` = opposite of the player's horizontal direction; `powered` = whether a neighbour signal exists; `waterlogged` from the fluid | none |
| `tnt` | default state | ignites when a neighbour signal exists on placement or on a neighbour change |

### 7.3 Slab placement and replacement (read: `SlabBlock.getStateForPlacement` and `canBeReplaced`, instruction by instruction)

Placement of a `wool_slab` at a position that already holds the same slab block gives `type` double with `waterlogged`
false. Otherwise the new state is `type` bottom, `waterlogged` from the fluid, and `type` top when the clicked face is
down, or when the clicked face is not up and the vertical fraction of the click position inside the block exceeds 0.5.
Stairs use the same top/bottom decision for `half` (read in `StairBlock.getStateForPlacement`; the stair's `facing` is the player's horizontal direction itself, not its opposite). A slab state can be replaced by placing an item of the same slab
block when its `type` is not double; when the placement replaces the clicked block, a bottom slab accepts the item when
the click is on its top face, or on a side face in the upper half of the block; a top slab symmetrically on its bottom
face or on a side face in the lower half; when the placement does not replace the clicked block (the slab is placed at the neighbouring position) the item is accepted whenever the item matches and the type is not double. A double slab is never replaced. Strictness: "exceeds 0.5" is a strict comparison on the click height inside the block (a click at exactly 0.5 counts as the lower half); "the item matches" is that the stack in hand is the item of this slab block.

### 7.4 Leaf distance

For a leaf block at position p the distance is 7 reduced by neighbours: for each of the six neighbours n, the neighbour's
contribution is 0 when n is in tag `prevents_nearby_leaf_decay` (logs), else n's own `distance` property when n has
one (so another leaf block contributes its `distance`, any leaf of this range or part 1), else 7; the candidate distance
is contribution + 1; the result is the minimum of 7 and every candidate. The exact scan order does not change the
result. On placement `persistent` is true, so a placed leaf never decays until the player breaks it.

### 7.5 Waterlogging

Blocks with a `waterlogged` property (leaves, rails, stairs, slabs, chests, ladders, signs, shelves, wall and standing
signs) report the water source fluid state when it is true, and, in their shape update, schedule a water tick when it is
true (`Fluids.WATER` with the fluid's tick delay). The fluid engine is in 33 (world simulation) and the neighbour-update plumbing in 29 section 3.

### 7.6 Sponge

`sponge`, when placed (and not replacing a `sponge`) or when notified by a neighbour, runs a breadth-first search from its
position over the six face neighbours: at most 6 steps from the sponge and at most 65 visited positions. A position is
visited (and the search continues through it) when it is the sponge itself, or when it holds water (fluid in tag
`water`) and one of these holds: the block can be picked up as a liquid container block (bucket-pickup; the pickup is
performed and the result is not empty); or the block is a liquid block (it is set to air); or the block is `kelp`,
`kelp_plant`, `seagrass` or `tall_seagrass` (its resources are dropped, with its block entity, and it is set to air). A
position that holds water but none of these, or holds no water, is skipped. When the search visits more than one position
the sponge becomes `wet_sponge` (set with update flag 2) and plays `sponge_absorb` (volume 1.0, pitch 1.0, `blocks`
category, no source entity). The 6 and 65 and the four block names are read; the visit rule is summarised from the lambda
structure (inferred: the exact order in which the three alternatives are tried was not re-read, so a block that satisfies
two of them is treated as satisfying the first listed).

### 7.7 Chest partner (read in full)

Read from `ChestBlock.getStateForPlacement`, `getChestType`, `candidatePartnerFacing`, `chestCanConnectTo`, `getConnectedDirection` and `updateShape`.
`chestCanConnectTo(state)` is true when the state is a state of the same block (the chest block itself, not a trapped chest).
`getConnectedDirection(state)`: clockwise(`facing`) when `type` is `left`, otherwise counter-clockwise(`facing`) (this covers
`right`, and `single`, whose value is never used for a join).

**Placement.**

1. Start with `type` single, `facing` = opposite of the player's horizontal direction, `waterlogged` = the fluid at the
   clicked position is water.
2. When the player is sneaking (`isSecondaryUseActive`) **and** the clicked face is horizontal: let `partner` =
   `candidatePartnerFacing(clickedPos, opposite(clicked face))`. When `partner` exists **and** its axis differs from the
   axis of the clicked face, the chest takes **that partner's facing** as its own `facing` (replacing the value of step 1),
   and `type` = `right` when counter-clockwise(that facing) equals the opposite of the clicked face, else `left`.
3. When `type` is still `single` **and** the player is not sneaking: `type` = `getChestType(clickedPos, facing)`:
   - if `candidatePartnerFacing(pos, clockwise(facing))` equals `facing`, the type is `left`;
   - otherwise, if `candidatePartnerFacing(pos, counter-clockwise(facing))` equals `facing`, the type is `right`;
   - otherwise `single`.
   A sneaking player whose step 2 did not apply gets `single` (step 3 is skipped when sneaking).
4. `candidatePartnerFacing(pos, direction)`: look at the state at `pos + direction`; when it is a connectable chest whose
   `type` is `single`, the result is that state's `facing`, otherwise nothing.
5. **Shape update** (`updateShape`, called with the direction of the changed neighbour): first, when `waterlogged`, a water
   tick is scheduled. Then:
   - when the neighbour state is a chest of the same block **and** the direction is horizontal: if this chest is `single`,
     the neighbour's `type` is not `single`, the two `facing` values are equal, and the neighbour's connected direction
     equals the opposite of the update direction, then this chest's `type` becomes the opposite of the neighbour's `type`
     (`left` <-> `right`); if any of those conditions fails nothing changes;
   - otherwise (the neighbour is not a chest of this block, or the direction is vertical): when this chest's connected
     direction equals the update direction, `type` becomes `single`. Note this tests only that the neighbour **is no longer a
     chest of this block**, not that its facing or type still match.

Observable constants: a double chest's two halves have the same `facing` and opposite types; `left` is the half whose
partner lies on the clockwise side of `facing`, `right` the half whose partner lies on the counter-clockwise side (the
connected direction of section 6). Worked example in section 8, example 13.

### 7.8 Stair connection shape (read: `StairBlock.getStairsShape` and `canTakeShape`)

For a stair at p with `facing` f and `half` h, `shape` is chosen as follows (the order matters):

1. Let n1 be the state at `p + f` (the front). If n1 is a stair of the same `half` whose `facing` is on a different axis
   than f, and `canTakeShape(p, opposite(n1.facing))` holds, then the shape is `outer_left` when n1's `facing` is
   counter-clockwise(f), and `outer_right` otherwise.
2. Otherwise let n2 be the state at `p + opposite(f)` (the back). If n2 is a stair of the same `half` whose `facing` is
   on a different axis than f, and `canTakeShape(p, n2.facing)` holds, then the shape is `inner_left` when n2's `facing`
   is counter-clockwise(f), and `inner_right` otherwise.
3. Otherwise `straight`.

`canTakeShape(p, d)` is true unless the state at `p + d` is a stair with the same `facing` and the same `half` as the stair
at p. The shape is recomputed in the shape update when the changed neighbour is horizontal. The `half` of a placed stair:
top when the clicked face is down, or when the clicked face is not up and the vertical fraction of the click position
exceeds 0.5; otherwise bottom. (The rule was read from `StairBlock.getStairsShape` and `canTakeShape`; "is a stair" means the block class is `StairBlock` (not a tag). The use of `opposite(n1.facing)` in step 1 against `n2.facing` in step 2 is as the artifact shows. At placement, `facing` = the player's horizontal direction, `half` as above, `waterlogged` from the fluid, and `shape` = the result of this rule at the placed position.)


### 7.10 Note block instrument (read)

`NoteBlock.setInstrument(level, pos, state)`:

1. Let `above` = the `instrument` setting (builder `instrument(...)`, default `HARP`) of the block state at `pos + up`.
2. When `above` *works above a note block* (its `NoteBlockInstrument$Type` is not `BASE_BLOCK`, that is the six mob heads zombie,
   skeleton, creeper, dragon, wither_skeleton, piglin of type `MOB_HEAD` and `custom_head` of type `CUSTOM`), the note block's
   `instrument` is `above`.
3. Otherwise let `below` = the `instrument` setting of the block at `pos + down`; when `below` works above a note block (a mob
   head below), the result is `harp`; else it is `below`.

Used at placement, and in the shape update when the changed neighbour is above or below (vertical axis). A neighbour signal change
sets `powered` to whether the position has a neighbour signal, plays the note on the false-to-true change, and stores the state.
`isTunable` is true for `BASE_BLOCK` instruments; `hasCustomSound` is true for `custom_head`. The instrument setting of each block is the Instrument column of section 5.

### 7.11 Door hinge (read: `DoorBlock.getHinge`)

Inputs: the placement position `p`, the player's horizontal direction `d`, and the click position inside the block (x and
z fractions `cx`, `cz`, 0 to 1). Let `L` = `p + counter-clockwise(d)` and `R` = `p + clockwise(d)`; `LU` and `RU` are the
positions one block above `L` and `R`.

1. Score `s` = (-1 if the collision shape of the block at `L` is a full block) + (-1 if the same holds at `LU`) + (+1 if
   the block at `R` has a full-block collision shape) + (+1 if the same holds at `RU`). So `s` ranges from -2 to 2 and
   is negative when more solid blocks are on the left.
2. `leftDoor` = the block at `L` is a door block and its `half` is lower; `rightDoor` = the same for `R`.
3. `hinge` = **right** when (`leftDoor` and not `rightDoor`) or `s > 0`.
4. Otherwise `hinge` = **left** when (`rightDoor` and not `leftDoor`) or `s < 0`.
5. Otherwise (a tie: `s = 0` and no door difference) the click decides, using the step of `d` (`stepX`, `stepZ`, each
   -1, 0 or 1): `hinge` = **right** when any of these holds: `stepX < 0` and `cz < 0.5`; `stepX > 0` and `cz > 0.5`; `stepZ < 0`
   and `cx > 0.5`; `stepZ > 0` and `cx < 0.5`. Otherwise **left**. (Strict comparisons: a click exactly at 0.5 gives left.)

"Door block" is the block class `DoorBlock` (every wood and metal door), not a tag. Only the hinge is chosen here; `open` and
`powered` are set from the neighbour-signal test at placement (7.2). Worked example: section 8, example 12.

### 7.12 Creaking heart (read: `CreakingHeartBlock`, `CreakingHeartBlockEntity.serverTick` and `updateCreakingState`)

States: `axis` (x, y, z; default y), `creaking_heart_state` (`uprooted`, `dormant`, `awake`; default `uprooted`), `natural`
(default false; that world generation places hearts with `natural` true is (recalled, not verified) and belongs to the feature/worldgen documents).

1. **Required logs.** `hasRequiredLogs(state, pos)` is true when, for **both** directions of the heart's `axis`, the
   neighbouring block is in tag `pale_oak_logs` **and** its own `axis` property equals the heart's `axis`.
2. **Placement.** `axis` = the axis of the clicked face; then the state is passed through the update of step 3.
3. **Block update (`updateState`).** The state changes only when `hasRequiredLogs` is true **and** the current state is
   `uprooted`: it becomes `awake` when the environment attribute `creaking_active` at the position is true, else `dormant`.
   In every other case the state is unchanged (the block class never sets `uprooted` itself).
4. **Triggers.** A shape update (any neighbour change) schedules a block tick for this block after 1 game tick; that tick
   runs step 3 and writes the new state with update.
5. **Block entity tick (server).** A countdown runs each tick; when it elapses it is reset to 20 plus a random number from
   0 to 4 (20 when no level is attached), so the periodic check happens about every 22 to 26 ticks (inferred from the
   counter test: the check runs on the tick after the counter has gone below 0). The check
   (`updateCreakingState`): when `hasRequiredLogs` is **false** and the heart has no protector creaking recorded, the state
   becomes `uprooted`; otherwise it becomes `awake` when `creaking_active` at the position is true, else `dormant`. A changed
   state is written. This is the only place that returns a heart to `uprooted` or switches `awake` and `dormant` back and
   forth.
6. **Protector creaking** (summarised from the instruction listing; mob rules belong to 44 part 4): when the state is
   `awake` and no protector is recorded, monsters are spawnable and difficulty is not peaceful, and a player is within 32
   blocks, a protector creaking is spawned. An existing protector is removed when (`creaking_active` is false and the
   creaking does not require persistence), or the distance to it exceeds 34, or a player is stuck in it.
7. **`natural`.** In the two classes read, only `tryAwardExperience` reads it, called when a player destroys the block: when the player does not
   prevent block drops, is not a spectator, `natural` is true and the level is a server level, experience is dropped,
   a random integer from 20 to 24 inclusive (`nextIntBetweenInclusive(20, 24)`). The destruction also asks the block entity to
   remove its protector with a player-attack damage source.
6a. **Protector spawn and resin constants** (read: static constants and `spawnProtector`, `getCreakingProtector`, `creakingHurt`). Spawn: 5 attempts per spawn (`ATTEMPTS_PER_SPAWN`), searching within horizontal range 16 and vertical range 8 of the heart (`SPAWN_RANGE_XZ`, `SPAWN_RANGE_Y`), entity spawn reason `SPAWNER`, placement strategy `ON_TOP_OF_COLLIDER_NO_LEAVES` (the creaking stands on top of a collider that is not a leaf block); after a successful spawn the server broadcasts entity event 60 for the creaking. Roaming radius constant 32 (`CREAKING_ROAMING_RADIUS`). When the heart's state is `awake` at the time of a hurt of the protector, resin is spread 2 or 3 times (`nextIntBetweenInclusive(2, 3)`), each spread a breadth-first traversal from the heart with maximum depth 2 and at most 64 positions (`MAX_DEPTH`, `MAX_COUNT`); the block placed by a spread and the per-position acceptance test (`spreadResin` lambdas) were not read in detail (Open question 9). Grace: while the block entity has existed for fewer than 30 ticks (`TICKS_GRACE_PERIOD`) an unresolved stored protector UUID is kept; at 30 ticks or more it is cleared (`clearCreakingInfo`). Emitter: after a hurt the particle emitter counter is set to 100 ticks (`HURT_CALL_TOTAL_TICKS`; also constants 10 hurt calls at interval 10 and particle ticks 50) and the emitter targets the centre of the creaking's bounding box; the emitter colours are the integers 16545810 and 6250335 (open and closed eye colours are (inferred) from the names of the states only).
8. **Analog output** (read: `CreakingHeartBlockEntity.computeAnalogOutputSignal`). The output is 0 when the block entity has no creaking information or no protector creaking is recorded. Otherwise let `d` be the distance to the protector, `r = clamp(d, 0, 32) / 32` (double division) and the output is `15 - floor(r x 15)`, so 15 at distance 0 and 0 at distance 32 or more. Other constants of the class (read): the removal distance of a protector is 34 and the player distance for spawning one is 32 (item 6); the destroy experience of item 7 is `nextIntBetweenInclusive(20, 24)`; the countdown reset of item 5 is 20 plus `nextInt(5)`.

### 7.9 Tint and colour inputs

Which block uses which tint source (foliage, grass, water, redstone) is decided by the colour handlers (`BlockColors`),
not by the block classes, and is specified in 43 (tint sources); this part names only what the block classes themselves define.
The leaves classes carry a falling-leaf particle with chance 0.01 per animate tick (constructor constant, read; behaviour in 42 part 4 section 8): the poplar leaves use the particle type of their own name together with the ambient `poplar_leaves_ambient` sound, gated by tag `required_for_poplar_leaf_ambience`; the two
azalea leaves, with no ambient sound, use the particle type `tinted_leaves` with the fixed colour option 0xFF70922D (ARGB, read as the signed
integer -9399763). `orange_poplar_leaves` and `red_poplar_leaves` (ids 103 and 104) are not in this range. For `redstone_wire` the artifact defines a colour per power value (`RedstoneWireBlock` static table, read), used for the
dust particles and, by the model's tint index (data), for the block: with `f = power / 15` in 32-bit floating point,
red = `f * 0.6` plus 0.4 when `f > 0` and plus 0.3 when `f = 0`; green = `clamp(f * f * 0.7 - 0.5, 0, 1)`; blue =
`clamp(f * f * 0.6 - 0.7, 0, 1)`; alpha 1. Each channel is converted as `floor(channel * 255)` (`ARGB.colorFromFloat`, read) and
packed as alpha, red, green, blue (8 bits each). Resulting 0xAARRGGBB values, power 0 to 15 (evaluated with float32
steps):

| Power | Colour | Power | Colour |
|---|---|---|---|
| 0 | `FF4C0000` | 8 | `FFB70000` |
| 1 | `FF700000` | 9 | `FFC10000` |
| 2 | `FF7A0000` | 10 | `FFCC0000` |
| 3 | `FF840000` | 11 | `FFD60000` |
| 4 | `FF8E0000` | 12 | `FFE00000` |
| 5 | `FF990000` | 13 | `FFEA0600` |
| 6 | `FFA30000` | 14 | `FFF41B00` |
| 7 | `FFAD0000` | 15 | `FFFF3200` |

Which block uses which tint source is tabulated in 24 part 1 section 9.3 and restated for this range in section 5.6; the table above is the only block-class
definition of a per-state colour in this range.

---

## 8. Worked examples

1. **Ids.** `yellow_poplar_leaves` is ordinal 105 and id 105. `orange_bed` is id 120 (`bed` ordinal 119, colour index 1),
   `black_bed` is id 134, `straw_bed` id 135, `powered_rail` 136, `white_wool` 151, `black_wool` 166,
   `white_wool_stairs` 167, `black_wool_slab` 198, `moving_piston` 199, `fire` 240, `redstone_wire` 246,
   `oak_wall_sign` 269 (ordinal 209).
2. **Default state of `azalea_leaves`.** State offset 28; default index 27 (distance 7: 6 * 4 = 24, persistent false:
   1 * 2 = 2, waterlogged false: 1). State id = `B105 + 28 + 27 = B105 + 55`.
3. **A note block state.** Instrument `trumpet` (index 16), note 12, powered true: index
   `16 * 50 + 12 * 2 + 0 = 824`; state id = `B105 + 105 + 824 = B105 + 929`.
4. **A stair state.** `oak_stairs` (state offset 4 888), facing east (index 3), half top (0), shape outer_left (3),
   waterlogged true (0): index `3 * 20 + 0 * 10 + 3 * 2 + 0 = 66`; state id `B105 + 4 888 + 66 = B105 + 4 954`.
5. **A redstone wire state.** east `side` (1), north `up` (0), power 15, south `none` (2), west `none` (2):
   index `1 * 432 + 0 * 144 + 15 * 9 + 2 * 3 + 2 = 575`; state id `B105 + 4 992 + 575 = B105 + 5 567`.
6. **Wall torch outline.** Facing north: `[5.5,3,11 - 10.5,13,16]`. Facing east the point map (x, z) to (1 - z, x) gives
   x from `1 - 16/16 = 0` to `1 - 11/16 = 5/16` and z from 5.5/16 to 10.5/16, that is `[0,3,5.5 - 5,13,10.5]`: the torch
   leans out from the west wall of the block, which is the wall it is attached to when facing east.
7. **Bed shape.** A `head` half with facing north: the connected direction is south, the table key is north, so the legs are
   `[0,0,0 - 3,3,3]` and `[13,0,0 - 16,3,3]` (north corners) and the mattress is `[0,3,0 - 16,9,16]`: the pillow end is at
   the north end. The `foot` half of the same bed (facing north) has connected direction north, key south: legs at
   `[0,0,13 - 3,3,16]` and `[13,0,13 - 16,3,16]`.
8. **Flower offset.** A flower at (3, 64, 5): `seed = Mth.getSeed(3, 0, 5)` = -87208048172454 (using the formula of section
   2.7); `seed & 15` = 10, `(seed >> 8) & 15` = 2; `dx = ((10 / 15) - 0.5) * 0.5 = 0.08333`, `dz = ((2 / 15) - 0.5) * 0.5 =
   -0.18333`; both inside the clamp of 0.25. The outline `[5,0,5 - 11,10,11]` (in blocks 0.3125 to 0.6875 in x and z) becomes
   x from 0.3958 to 0.7708 and z from 0.1292 to 0.5042. At (0, 0): seed 0, so `dx = dz = -0.25` (the clamp is just reached).
   For offset type `XYZ` at (0, 0) `dy = -0.2`.
9. **Wheat heights.** Age 0: `[0,0,0 - 16,2,16]`; age 3: height 8; age 7: height 16 (a full block outline, still with no
   collision).
10. **Leaf distance.** A placed leaf (`persistent` true) beside a log: the neighbour in tag `prevents_nearby_leaf_decay`
    contributes 0, the candidate is 1, so the leaf's `distance` is 1. Two blocks away along a chain of non-persistent
    leaves the distances read 2, 3 and so on up to 7; a non-persistent leaf with `distance` 7 is random-ticked and decays.
11. **Door shape.** A closed oak door facing north: outline `[0,0,13 - 16,16,16]` (the south side of the block). Turning
    that box by `Y_90` (x, z) to (1 - z, x) gives the table entries: key east `[0,0,0 - 3,16,16]`, key south
    `[0,0,0 - 16,16,3]`, key west `[13,0,0 - 16,16,16]`. The same door, open with hinge right, uses key
    counter-clockwise(north) = west, so its outline is `[13,0,0 - 16,16,16]`; open with hinge left it uses key
    clockwise(north) = east, `[0,0,0 - 3,16,16]`.
12. **Door hinge.** A player facing north (`d` = north; counter-clockwise(north) = west, clockwise = east) places a door in open
    ground: no full blocks at `L`, `LU`, `R`, `RU`, no doors, so `s` = 0 and the click decides: `stepZ` = -1, so a click at
    `cx` = 0.8 gives hinge right, a click at `cx` = 0.5 or 0.2 gives hinge left. With a full block at `L` only, `s` = -1 and
    the hinge is left whatever the click; with full blocks at `R` and `RU`, `s` = 2 and the hinge is right. With the lower half of
    a door at `L` and no door at `R`, the hinge is right whatever `s` is (rule 3 comes before the score test of rule 4).
13. **Chest pairing.** A single chest A at (0, 0, 0) with `facing` south. A player facing north (not sneaking) places a chest B
    at (1, 0, 0): `facing` = south; `getChestType` with direction south tests clockwise(south) = west first: the state at
    (0, 0, 0) is a single chest of facing south, so B's `type` is `left`. The shape update sent to A (changed neighbour on the
    east) finds A single, B not single, equal facings, and B's connected direction clockwise(south) = west equal to
    opposite(east): A's `type` becomes `right`. A's connected direction is now counter-clockwise(south) = east, which points at B.

---

## 9. Validation

### 9.1 Checks performed while writing

| Check | Result |
|---|---|
| The number of block statements from ordinal 105 to 209 | 105 statements; 4 of them register 16 blocks each (`bed`, `wool`, `wool_stairs`, `wool_slab`), so 165 block ids (105 to 269) |
| No collection statement before ordinal 119 | the first 119 statements each end in one `register` call; ordinal = id up to 118 |
| Order of colours in a collection | read from the record's field order and from `zipMap` (white first, black last); `DyeColor` constants in the same order |
| Key of a collection member | `<colour>_<base>`; the join string of `prefixWithColor` was found in the class constant pool |
| State counts | each count recomputed as the product of value counts of the properties of section 4; sum over the range 6 848 (84 leaves + 1 371 sponges to cut sandstone and note block + 272 beds + 60 rails and sticky piston + 47 plants through piston head + 1 404 wool family and moving piston + 279 flowers to chiseled bookshelf + 832 shelves + 1 939 mossy cobblestone to chest and redstone wire + 560 ores, crops, furnace, signs, door, ladder, rail, stairs, wall sign) |
| Property order | sorted by name (04 §5.2); `distance`, `persistent`, `waterlogged` for leaves; `east`, `north`, `power`, `south`, `west` for redstone wire; `age`, `east`, `north`, `south`, `up`, `west` for fire; `facing`, `half`, `hinge`, `open`, `powered` for doors |
| Compiler switch index tables | the stair-shape and slab-type `switch` statements use compiler-generated indices that are not ordinals; both generated tables were read (stairs: straight, outer_left, inner_right, inner_left, outer_right; slabs: top, bottom, double; chest: single, left, right) |
| Constructor arguments | each `Blocks` lambda that wraps a constructor was read (the flowers' effects, the leaves' particles, the experience ranges 2 to 5 and 3 to 7, the mushrooms' features, the sign wood types) |
| Hardness / resistance of copies | `ofLegacyCopy` and `ofFullCopy` field lists read from `BlockBehaviour$Properties`; the oak planks and cobblestone records read for the stair copies |

### 9.2 Checkpoints an implementation can test

An implementation that builds this registry (or the extraction tool's cross-check against the jar reports of 04 §5.1) must
produce these values. The state ids are given relative to `B105` (part 1):

| Block | Id | States | State offset |
|---|---|---|---|
| `yellow_poplar_leaves` | 105 | 28 | 0 |
| `note_block` | 118 | 1 350 | 105 |
| `white_bed` | 119 | 16 | 1 455 |
| `black_bed` | 134 | 16 | 1 695 |
| `straw_bed` | 135 | 16 | 1 711 |
| `powered_rail` | 136 | 24 | 1 727 |
| `piston` | 149 | 12 | 1 798 |
| `piston_head` | 150 | 24 | 1 810 |
| `white_wool` | 151 | 1 | 1 834 |
| `white_wool_stairs` | 167 | 80 | 1 850 |
| `white_wool_slab` | 183 | 6 | 3 130 |
| `moving_piston` | 199 | 12 | 3 226 |
| `chiseled_bookshelf` | 222 | 256 | 3 261 |
| `acacia_shelf` | 223 | 64 | 3 517 |
| `fire` | 240 | 512 | 4 356 |
| `chest` | 245 | 24 | 4 968 |
| `redstone_wire` | 246 | 1 296 | 4 992 |
| `oak_sign` | 254 | 32 | 6 316 |
| `oak_door` | 265 | 64 | 6 668 |
| `oak_wall_sign` | 269 | 8 | 6 840 |

The last block ends at offset 6 848 (the next block of part 3 starts there). Offsets of every block are in section 3.

### 9.3 Not verified

Nothing was executed. Where a fact was recomposed from compact instruction listings rather than read line by line, the text
says so ("inferred", "summarised", "recalled, not verified") at the rule itself and the item is in section 10. Rules read
instruction by instruction and marked "(read)": door hinge (7.11), chest placement and shape update
(7.7), creaking heart (7.12 except the protector spawn, summarised), slab placement and replacement (7.3), stair shape and
placement (7.8), flammability numbers (5.7), tint list (5.6). Also read: standing-sign rotation (7.2), the up-facing fire sheet (section 6), the farmland moisture scan box (7.2), the creaking heart analog output (7.12), the propagates-skylight-down overrides (2.3) and the eleven registered shelves (5.7). Still inferred: light dampening per block other than leaves
(5.3) and the sponge visit rule (7.6).

---

## 10. Open questions

1. **Restated defaults.** Where 24 part 1 restates the base-class defaults of section 2 or the property value lists of section 2.4 and differs from this part, one of the two is wrong; no difference was found when `B105 = 575` was checked (section 1.2).
2. **Map colours.** Closed. Every one of the 27 map-colour names used in section 5 (and the colour-collection names of section 2.8) was checked against the name column of 24 part 1 section 8.1 (ids 0 to 61); none is missing. The colour values are in that table, not here.
3. **Sound types.** Closed. Every one of the 24 sound-type names used in section 5 (`AZALEA_LEAVES`, `BAMBOO_WOOD`, `CHERRY_WOOD`, `CHISELED_BOOKSHELF`, `COBWEB`, `CREAKING_HEART`, `CROP`, `DEEPSLATE`, `GLASS`, `GRASS`, `GRAVEL`, `IRON`, `LADDER`, `METAL`, `POPLAR_LEAVES`, `RED_SHRUB`, `SHELF`, `SPAWNER`, `SPONGE`, `STRAW_BED`, `WET_GRASS`, `WET_SPONGE`, `WOOD`, `WOOL`, plus the default `STONE`) appears in 24 part 1 section 8.4: `CROP` and `RED_SHRUB` in its exception table, the others in its list of standard constants. The volume, pitch and events are in that table.
4. **Fire.** The ignite and burn numbers of this range are now tabulated in section 5.7 (read from `FireBlock.bootStrap`). Not specified here, and not specified in any existing document (there is no separate fire part of 29b; 17 sections 3.3 and 3.3a and 29b part 1 carry only some fire constants): the meaning of the two numbers in fire's random tick and spread, the `increased_fire_burnout` attribute and the age rules (tick delay 30 plus a random number below 10 is read as a constant only).
5. **Engines named but not specified here.** (Closed in part as to citations: no document 30 exists, and 12 is client rendering, so none of these is cited to them any more.) Dispenser behaviours (`DispenseItemBehavior`), piston movement
   (`PistonStructureResolver`, `PistonMovingBlockEntity`), rail connection (`RailState`), redstone signal evaluation
   (`DefaultRedstoneWireEvaluator`), note block sounds, crop growth speed (29b part 2), bed sleeping, sign editing and the block entities of dispensers, chests, furnaces, spawners, shelves,
   chiseled bookshelves, signs and creaking hearts. The piston and rail engines are unspecified (searched 29, 31-block-entities-2 and 33: only update flags and the block-event queue are described); the others belong to 29, 29b and 31 where those documents cover them. Leaf particle chance and ambient sounds are in section 7.9 (constructor constants, read) and 42 part 4; the farmland moisture scan box is in 7.2.
6. **Where the model offset is applied.** Only `FlowerBlock` moves its outline by the offset inside `getShape`. For
   `short_grass`, `fern`, `short_dry_grass`, `tall_dry_grass` and `tall_seagrass` the state carries an offset function but the
   block class does not use it; the consumer is outside the block classes (rendering, targeting). Not traced.
7. **Note block sounds.** The instrument choice is read (7.10). The sound events of each instrument, tunable pitch (`getPitchFromNote`) and the custom-head sound lookup were not read here.
8. **Chest partner search.** Closed: `getStateForPlacement`, `getChestType`, `candidatePartnerFacing`, `chestCanConnectTo` and `updateShape` were read in full; the rules are in 7.7. Corrected against the first version of this document: in the sneaking branch the placed chest takes the partner's `facing`, and `type` is `right` when counter-clockwise of that facing equals the opposite of the clicked face. Not read: the double-chest container combiner (`DoubleBlockCombiner`), which belongs with the block-entity document.
9. **Creaking heart state transitions.** Mostly closed: 7.12 gives the block-class transitions, the block entity's periodic recomputation (including the return to `uprooted`), the use of `natural` and the analog output formula, all read. The spawn constants, the resin-spread counts and the grace and emitter durations are now recorded in 7.12 item 6a. Not read in detail: the block placed by a resin spread and its acceptance test, the `SpawnUtil` placement search itself, and the particle details (left to 44 part 4 and 31 part 8). Searched: `CreakingHeartBlock`, `CreakingHeartBlockEntity.serverTick`, `updateCreakingState` and `computeAnalogOutputSignal`.
10. **Door hinge choice.** Closed: `DoorBlock.getHinge` was read in full; the rule is in 7.11 with a worked example (section 8, example 12).
11. **Pathfinding flags.** `isPathfindable` overrides are not tabulated (only `farmland`, false, is recorded in section 2.3); not read for the other blocks of this range. They belong with the pathfinding document (mob navigation).
12. **Legacy solid.** Closed: section 2.3 (branches and `AABB.getSize` read).
13. **Rotation convention.** Closed: section 2.6 (`Shapes.rotate`, `OctahedralGroup` and `SymmetricGroup3` read).
14. **Redstone colour ramp.** Closed: section 7.9 (table initialiser read).
15. **Hanging signs, `crimson_*` and `warped_*` signs, wall signs other than oak.** Not in this range; part 3.
16. **Block set type and wood type tables.** Only `oak` (set type) and the eleven standing-sign wood types (sound only) are
    read here; the full tables (trapdoor, pressure plate, button and fence gate sounds, hanging-sign sounds) belong to the
    parts that register those blocks.
17. **Render shapes of block-entity blocks.** `chest`, `bed`, `sign`, `shelf` and similar blocks do not override
    `getRenderShape` in the block class (default `MODEL`); how the client draws their block entity is for document 12.
18. **Slab and stair placement text.** Closed: `SlabBlock.getStateForPlacement`, `SlabBlock.canBeReplaced`, `StairBlock.getStateForPlacement`, `getStairsShape` and `canTakeShape` were read instruction by instruction, and the comparison constant 0.5 is exact (strictly greater than). Rules in 7.3 and 7.8 are marked "(read)". Not read: `updateShape` of slabs and stairs beyond the water tick and the shape recomputation, and `isPathfindable`.
19. **Tag data.** Section 5.4 is computed from the data files of this jar only; a data pack that replaces tags changes it.
20. **Flower, plant and shelf class rules.** `isPathfindable`, the `FlowerBlock` suspicious-stew timing and the shelf powered-chain rule (`side_chain`) are not specified here.
21. **Moving piston engine.** The collision rule of `moving_piston` is in section 6 (read). Not read or specified: the creation and per-tick advance of `PistonMovingBlockEntity` (`progress` step, finishing, the entity push and the no-clip direction thread-local), and `PistonStructureResolver` (push limit and blocks that move). Searched: 29, 31-block-entities-2 and 33 mention only update flag 64 and the block-event queue.
