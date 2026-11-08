# Block registry, part 5: heads to fence gates (Blocks fields 420 to 524)

| Item | Value |
|---|---|
| Covers | The block registry rows for `Blocks` fields 420 (`WITHER_SKELETON_WALL_SKULL`) to 524 (`PALE_OAK_FENCE_GATE`): wall and floor skulls and heads, anvils, trapped chest, weighted pressure plates, comparator, daylight detector (with its inverted mode), redstone block, nether quartz ore, hopper, the quartz family, activator rail, dropper, the dyed terracotta, stained glass pane, carpet, banner and wall banner collections, wood and prismarine and sandstone stairs and slabs, slime block, barrier, light block, iron trapdoor, hay block, packed ice, coal block, tall plants, the smooth blocks, and the first seven fence gates. For each row: id, key, class, properties and value order, state count, first and default state id, break and blast values, light, map colour, sound, push reaction, instrument and flags. For each class: the shapes (collision, outline, occlusion, support) in pixel boxes, the default state, the placement state, `canSurvive`, replaceable rules and the per-block interaction rules that belong to the registry. The tint class and placement columns of GAP-29 and GAP-30 for these blocks. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas), with no execution. Block ids, state counts and offsets were computed by the rule of 04 §5.2 from a table of all `Blocks` fields 0 to 524 that the reader built from the same bytecode (cross-check in section 11). The tag files under `data/minecraft/tags/block/` were read as data for the mineable and needs-tool columns (section 7.14b). Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions. Fixer pass: the constants, formulas and class facts of sections 4, 6.1, 7.2, 7.4 to 7.6, 7.9, 7.10, 7.11, 7.13, 7.14a, 7.14b were re-read against the same bytecode and are cited by class and method. |
| File name | The name `24-block-registry-5-quartz-concrete-gates` is historic and inexact: fields 420 to 524 contain no concrete blocks (the concrete collections are in a later part) and the range starts at heads, not quartz. The file keeps its name because sibling documents and the index cite it and this round may edit only this file; the covered range is the one in the Covers row. Rename it together with the siblings and `README.md` in a later index pass (Open question 18). |
| Status | Round RS4, part 5 of 8 (design map Part 5 GAP-1, and the columns of GAP-29 and GAP-30) |
| Siblings | Part 1 ([24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md)) defines the shared model and every column: this document cites it as "24 part 1 §N" and does not repeat it. Parts 2 to 4 cover fields 105 to 419, parts 6 to 8 fields 525 to 910. |

Class, method and field names in backticks say where a fact was read; they are not the design. "04 §5" is
[04-registry-sync.md](04-registry-sync.md) section 5. The design map is `docs/design/README.md`.

Data versus code (design map R7). Everything below is code: registry rows, state definitions, shapes, placement
and interaction rules. Block models, block state JSON, loot tables, recipes and tag files are data that the extraction
tool copies; this document names the tags that code reads and does not list tag members.

Shared rules cited, not repeated: the id rule and collections (24 part 1 §2), the state id rule (24 part 1 §3, 04
§5.2), the `Properties` builder, its defaults and the legacy copy (24 part 1 §4), derived per-state values and
`isSolid` (24 part 1 §5), the shape model and the sturdy tests (24 part 1 §6), the column definitions (24 part 1 §7),
the enumerations `MapColor`, `PushReaction`, `NoteBlockInstrument`, `SoundType` (24 part 1 §8), the tint sources
(24 part 1 §9), the replaceable, `canSurvive` and placement columns (24 part 1 §10).

## Contents

1. Id and state bases for this part
2. Property definitions used by these rows
3. The rows: fields 420 to 524
4. Notes to the rows
5. The four colour collections (dyed terracotta, stained glass pane, carpet, banner and wall banner), with per-colour tables
6. Shape helpers and pixel-box geometry (6.1 the XZ offset type)
7. Classes: shapes, defaults, placement, `canSurvive`, interaction (7.1 skulls to 7.18 fence gates; 7.14a light and occlusion; 7.14b friction, loot table and tool tags)
8. Placement columns (GAP-30) per class
9. Tint class (GAP-29) for this range
10. Worked examples
11. Validation
12. Open questions

## 1. Id and state bases for this part

Field 420 (`WITHER_SKELETON_WALL_SKULL`) is the first row. By the id rule (24 part 1 §2) and the state rule (04 §5.2):

| Quantity | Value | How it was obtained |
|---|---|---|
| Registry id of the first row | **509** | 420 fields precede it. Collections register several blocks in the position of one field: 16 each for the five `ColorCollection` fields `BED`, `WOOL`, `WOOL_STAIRS`, `WOOL_SLAB`, `STAINED_GLASS` and 8 each (four weathering states and four waxed states) for the two `WeatheringCopperCollection` fields `COPPER_BARS` and `COPPER_CHAIN` that lie before field 420. 420 + 5 x 15 + 2 x 7 = 509. |
| First state id of the first row | **12754** | The whole-registry table of part 8 (24 part 8, Appendix A) gives 12754 for `wither_skeleton_wall_skull` (id 509). An earlier draft of this document used 12698 from its own running sum over parts 2 to 4; that sum was 56 too low (part 4 counted `command_block` with 8 states, but the artifact's `CommandBlock` has `facing` (6) and `conditional` (2), 12 states, which is 4 of the 56; the other 52 came from the draft's own sum over fields 105 to 419). Block ids and per-block state counts of all 105 rows agree with part 8; only the absolute first-state ids moved, by exactly +56. The same table gives 575 before block 105, as part 1 states (24 part 1 §3). |
| Blocks in this part | 180 | Fields 420 to 524: 105 fields, of which `DYED_TERRACOTTA`, `STAINED_GLASS_PANE`, `CARPET`, `BANNER` and `WALL_BANNER` are collections of 16 (105 + 5 x 15 = 180). Ids 509 to 688. |
| States in this part | 2801 | State ids 12754 to 15554. The next field (`MANGROVE_FENCE_GATE`) starts at id 689 and state id 15555 (part 8 agrees: `pale_oak_fence_gate` first state 15523, `mangrove_fence_gate` 15555). |

The base 12754 is the authority of part 8's whole-registry table. Part 4's relative offsets are 4 too low from `beacon` on because of its `command_block` count (it needs 12 states, see above); the offsets in section 3 of this document, the per-block default indexes (hopper 0, quartz_stairs 11, fence gate 7, banner 8, light 31, and the rest) and every state count are unaffected. Every id and state id below is the base plus an offset.

## 2. Property definitions used by these rows

Value lists in the order in which the state numbering uses them (24 part 1 §3 item 3). Properties of a block are
sorted by name for the state index (04 §5.2), whatever the order of declaration.

| Property (name) | Field | Values in order | Count |
|---|---|---|---|
| `facing` (4 directions) | `HorizontalDirectionalBlock.FACING` = `BlockStateProperties.HORIZONTAL_FACING`, created with the predicate `Direction.Plane.HORIZONTAL` over the enum constants in **ordinal order** | north, south, west, east | 4 |
| `facing` (6 directions) | `DirectionalBlock.FACING` = `BlockStateProperties.FACING`, created with an explicit list | north, east, south, west, up, down | 6 |
| `facing` (hopper) | `BlockStateProperties.FACING_HOPPER`, created with a predicate "not `UP`" over the enum constants in ordinal order | down, north, south, west, east | 5 |
| `powered`, `waterlogged`, `enabled`, `inverted`, `triggered`, `open`, `in_wall`, `north`, `east`, `south`, `west` | `BooleanProperty` | true, false | 2 |
| `half` (stairs, trapdoors) | `BlockStateProperties.HALF` | top, bottom | 2 |
| `half` (double plants) | `BlockStateProperties.DOUBLE_BLOCK_HALF` | upper, lower | 2 |
| `shape` (stairs) | `BlockStateProperties.STAIRS_SHAPE` | straight, inner_left, inner_right, outer_left, outer_right | 5 |
| `shape` (powered rails) | `BlockStateProperties.RAIL_SHAPE_STRAIGHT`, created with a predicate that rejects the four corner shapes (`NORTH_EAST`, `NORTH_WEST`, `SOUTH_EAST`, `SOUTH_WEST`) over the `RailShape` constants in ordinal order | north_south, east_west, ascending_east, ascending_west, ascending_north, ascending_south | 6 |
| `type` (slabs) | `BlockStateProperties.SLAB_TYPE` | top, bottom, double | 3 |
| `type` (chests) | `BlockStateProperties.CHEST_TYPE` | single, left, right | 3 |
| `mode` (comparator) | `BlockStateProperties.MODE_COMPARATOR` | compare, subtract | 2 |
| `axis` | `BlockStateProperties.AXIS` (all three axes) | x, y, z | 3 |
| `rotation` | `BlockStateProperties.ROTATION_16`: an integer from 0 to `RotationSegment.getMaxSegmentIndex()`, which is 15 (a 4-bit segmented angle) | 0, 1, ... , 15 | 16 |
| `power` | `BlockStateProperties.POWER` | 0 to 15 | 16 |
| `level` (light block) | `BlockStateProperties.LEVEL` | 0 to 15 | 16 |

Serialised names of the enums (`getSerializedName`): `DoubleBlockHalf` returns `upper` and `lower` (read from the
constants), `Half` `top` and `bottom`, the `SlabType`, `StairsShape`, `ChestType`, `ComparatorMode` and `RailShape`
constants their lower-case names. Direction names are lower case.

`Direction` constants in ordinal order: down, up, north, south, west, east. Their `get2DDataValue` (read from the
constructor arguments) is: south 0, west 1, north 2, east 3 (down and up -1). `getClockWise` maps north to east to south
to west to north (used below as "clockwise seen from above"; the rotation of shapes by `BLOCK_ROT_Y_90` maps north to
east, consistent with this).

## 3. The rows: fields 420 to 524

Columns follow 24 part 1 §7, with two changes for this part: a leading "field" column (the index into `Blocks`, since
five rows are collections) and the "id" column shows a range for a collection. "states" is the count per block;
"properties" gives the count of each property in sorted-name order. "first state id" and "default id" are absolute,
using the bases of section 1; for a collection row they give the range and the formula for colour k (0 white to 15 black),
with the per-colour table in section 5. Hardness and blast resistance are floats written without the `f`. Where the
sound in the builder chain is overridden by the constructor of the class, the column shows the effective sound and
"(ctor)": `BasePressurePlateBlock` (its constructor, so both weighted plates) and `TrapDoorBlock` apply `BlockSetType.soundType`, and `FenceGateBlock` applies
`WoodType.soundType` (cherry: `CHERRY_WOOD`; all others of this part: `WOOD`, the default of the two-argument `WoodType`
constructor). Flag spelling follows 24 part 1 §7; `overrideLoot+name:X` is the `wallVariant` helper (the wall block uses
the loot table and the description id of block X); `viewBlocking:nearPlane` is the `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)`
predicate that `registerStair` and `registerSlab` set; `legacyCopy(X)` means `ofLegacyCopy(X)` (24 part 1 §4.3), whose copied
fields are listed there. Associated item: same key as the block, for every row except the wall variants (wall skull, wall
head, wall banner), which are registered through `BlockIds` and have no item of their own (the item is the floor variant's).

| field | id | key | class | states | properties | first state id | default id | hardness | blast res. | tool req. | light | map colour | sound | push | instrument | flags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 420 | 509 | wither_skeleton_wall_skull | WitherWallSkullBlock | 8 | facing[4] powered[2] | 12754 | 12755 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | HARP | overrideLoot+name:wither_skeleton_skull |
| 421 | 510 | zombie_head | SkullBlock | 32 | powered[2] rotation[16] | 12762 | 12778 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | ZOMBIE | noOcclusion |
| 422 | 511 | zombie_wall_head | WallSkullBlock | 8 | facing[4] powered[2] | 12794 | 12795 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | HARP | overrideLoot+name:zombie_head |
| 423 | 512 | player_head | PlayerHeadBlock | 32 | powered[2] rotation[16] | 12802 | 12818 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | CUSTOM_HEAD | noOcclusion |
| 424 | 513 | player_wall_head | PlayerWallHeadBlock | 8 | facing[4] powered[2] | 12834 | 12835 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | HARP | overrideLoot+name:player_head |
| 425 | 514 | creeper_head | SkullBlock | 32 | powered[2] rotation[16] | 12842 | 12858 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | CREEPER | noOcclusion |
| 426 | 515 | creeper_wall_head | WallSkullBlock | 8 | facing[4] powered[2] | 12874 | 12875 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | HARP | overrideLoot+name:creeper_head |
| 427 | 516 | dragon_head | SkullBlock | 32 | powered[2] rotation[16] | 12882 | 12898 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | DRAGON | noOcclusion |
| 428 | 517 | dragon_wall_head | WallSkullBlock | 8 | facing[4] powered[2] | 12914 | 12915 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | HARP | overrideLoot+name:dragon_head |
| 429 | 518 | piglin_head | SkullBlock | 32 | powered[2] rotation[16] | 12922 | 12938 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | PIGLIN | noOcclusion |
| 430 | 519 | piglin_wall_head | PiglinWallSkullBlock | 8 | facing[4] powered[2] | 12954 | 12955 | 1.0 | 1.0 | no | 0 | NONE | STONE | POPPED | HARP | overrideLoot+name:piglin_head |
| 431 | 520 | anvil | AnvilBlock | 4 | facing[4] | 12962 | 12962 | 5.0 | 1200.0 | yes | 0 | METAL | ANVIL | IMMOVEABLE | HARP | - |
| 432 | 521 | chipped_anvil | AnvilBlock | 4 | facing[4] | 12966 | 12966 | 5.0 | 1200.0 | yes | 0 | METAL | ANVIL | IMMOVEABLE | HARP | - |
| 433 | 522 | damaged_anvil | AnvilBlock | 4 | facing[4] | 12970 | 12970 | 5.0 | 1200.0 | yes | 0 | METAL | ANVIL | IMMOVEABLE | HARP | - |
| 434 | 523 | trapped_chest | TrappedChestBlock | 24 | facing[4] type[3] waterlogged[2] | 12974 | 12975 | 2.5 | 2.5 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 435 | 524 | light_weighted_pressure_plate | WeightedPressurePlateBlock | 16 | power[16] | 12998 | 12998 | 0.5 | 0.5 | no | 0 | GOLD | METAL (ctor) | POPPED | HARP | forceSolidOn noCollision |
| 436 | 525 | heavy_weighted_pressure_plate | WeightedPressurePlateBlock | 16 | power[16] | 13014 | 13014 | 0.5 | 0.5 | no | 0 | METAL | IRON (ctor) | POPPED | HARP | forceSolidOn noCollision |
| 437 | 526 | comparator | ComparatorBlock | 16 | facing[4] mode[2] powered[2] | 13030 | 13031 | 0 | 0 | no | 0 | NONE | STONE | POPPED | HARP | - |
| 438 | 527 | daylight_detector | DaylightDetectorBlock | 32 | inverted[2] power[16] | 13046 | 13062 | 0.2 | 0.2 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 439 | 528 | redstone_block | PoweredBlock | 1 | - | 13078 | 13078 | 5.0 | 6.0 | yes | 0 | FIRE | METAL | PUSH_PULL | HARP | redstoneConductor:never |
| 440 | 529 | nether_quartz_ore | DropExperienceBlock | 1 | - | 13079 | 13079 | 3.0 | 3.0 | yes | 0 | NETHER | NETHER_ORE | PUSH_PULL | BASEDRUM | - |
| 441 | 530 | hopper | HopperBlock | 10 | enabled[2] facing[5] | 13080 | 13080 | 3.0 | 4.8 | yes | 0 | STONE | METAL | PUSH_PULL | HARP | noOcclusion |
| 442 | 531 | quartz_block | Block | 1 | - | 13090 | 13090 | 0.8 | 0.8 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | - |
| 443 | 532 | chiseled_quartz_block | Block | 1 | - | 13091 | 13091 | 0.8 | 0.8 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | - |
| 444 | 533 | quartz_pillar | RotatedPillarBlock | 3 | axis[3] | 13092 | 13093 | 0.8 | 0.8 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | - |
| 445 | 534 | quartz_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 13095 | 13106 | 0.8 | 0.8 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy(quartz_block) viewBlocking:nearPlane |
| 446 | 535 | activator_rail | PoweredRailBlock | 24 | powered[2] shape[6] waterlogged[2] | 13175 | 13188 | 0.7 | 0.7 | no | 0 | NONE | METAL | PUSH_PULL | HARP | noCollision |
| 447 | 536 | dropper | DropperBlock | 12 | facing[6] triggered[2] | 13199 | 13200 | 3.5 | 3.5 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 448 | 537 to 552 | dyed_terracotta | Block | 1 | - | 13211 to 13226 | 13211 + k*1 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 |
| 449 | 553 to 568 | stained_glass_pane | StainedGlassPaneBlock | 32 | east[2] north[2] south[2] waterlogged[2] west[2] | 13227 to 13738 | 13258 + k*32 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 |
| 450 | 569 | acacia_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 13739 | 13750 | 2.0 | 3.0 | no | 0 | COLOR_ORANGE | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(acacia_planks) viewBlocking:nearPlane |
| 451 | 570 | cherry_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 13819 | 13830 | 2.0 | 3.0 | no | 0 | TERRACOTTA_WHITE | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(cherry_planks) viewBlocking:nearPlane |
| 452 | 571 | dark_oak_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 13899 | 13910 | 2.0 | 3.0 | no | 0 | COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(dark_oak_planks) viewBlocking:nearPlane |
| 453 | 572 | pale_oak_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 13979 | 13990 | 2.0 | 3.0 | no | 0 | QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(pale_oak_planks) viewBlocking:nearPlane |
| 454 | 573 | mangrove_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14059 | 14070 | 2.0 | 3.0 | no | 0 | COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(mangrove_planks) viewBlocking:nearPlane |
| 455 | 574 | poplar_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14139 | 14150 | 2.0 | 3.0 | no | 0 | COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(poplar_planks) viewBlocking:nearPlane |
| 456 | 575 | bamboo_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14219 | 14230 | 2.0 | 3.0 | no | 0 | COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(bamboo_planks) viewBlocking:nearPlane |
| 457 | 576 | bamboo_mosaic_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14299 | 14310 | 2.0 | 3.0 | no | 0 | COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(bamboo_mosaic) viewBlocking:nearPlane |
| 458 | 577 | slime_block | SlimeBlock | 1 | - | 14379 | 14379 | 0 | 0 | no | 0 | GRASS | SLIME_BLOCK | PUSH_PULL | HARP | bounce:1.0 noOcclusion |
| 459 | 578 | barrier | BarrierBlock | 2 | waterlogged[2] | 14380 | 14381 | -1.0 | 3600000.8 | no | 0 | waterlogged?WATER:NONE | STONE | IMMOVEABLE | HARP | noLootTable noOcclusion validSpawn:never noTerrainParticles |
| 460 | 579 | light | LightBlock | 32 | level[16] waterlogged[2] | 14382 | 14413 | -1.0 | 3600000.8 | no | level property | waterlogged?WATER:NONE | STONE | PUSH_PULL | HARP | replaceable noLootTable noOcclusion |
| 461 | 580 | iron_trapdoor | TrapDoorBlock | 64 | facing[4] half[2] open[2] powered[2] waterlogged[2] | 14414 | 14429 | 5.0 | 5.0 | yes | 0 | METAL | IRON (ctor) | PUSH_PULL | HARP | noOcclusion validSpawn:never |
| 462 | 581 | prismarine | Block | 1 | - | 14478 | 14478 | 1.5 | 6.0 | yes | 0 | COLOR_CYAN | STONE | PUSH_PULL | BASEDRUM | - |
| 463 | 582 | prismarine_bricks | Block | 1 | - | 14479 | 14479 | 1.5 | 6.0 | yes | 0 | DIAMOND | STONE | PUSH_PULL | BASEDRUM | - |
| 464 | 583 | dark_prismarine | Block | 1 | - | 14480 | 14480 | 1.5 | 6.0 | yes | 0 | DIAMOND | STONE | PUSH_PULL | BASEDRUM | - |
| 465 | 584 | prismarine_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14481 | 14492 | 1.5 | 6.0 | yes | 0 | COLOR_CYAN | STONE | PUSH_PULL | BASEDRUM | legacyCopy(prismarine) viewBlocking:nearPlane |
| 466 | 585 | prismarine_brick_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14561 | 14572 | 1.5 | 6.0 | yes | 0 | DIAMOND | STONE | PUSH_PULL | BASEDRUM | legacyCopy(prismarine_bricks) viewBlocking:nearPlane |
| 467 | 586 | dark_prismarine_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 14641 | 14652 | 1.5 | 6.0 | yes | 0 | DIAMOND | STONE | PUSH_PULL | BASEDRUM | legacyCopy(dark_prismarine) viewBlocking:nearPlane |
| 468 | 587 | prismarine_slab | SlabBlock | 6 | type[3] waterlogged[2] | 14721 | 14724 | 1.5 | 6.0 | yes | 0 | COLOR_CYAN | STONE | PUSH_PULL | BASEDRUM | legacyCopy(prismarine) viewBlocking:nearPlane |
| 469 | 588 | prismarine_brick_slab | SlabBlock | 6 | type[3] waterlogged[2] | 14727 | 14730 | 1.5 | 6.0 | yes | 0 | DIAMOND | STONE | PUSH_PULL | BASEDRUM | legacyCopy(prismarine_bricks) viewBlocking:nearPlane |
| 470 | 589 | dark_prismarine_slab | SlabBlock | 6 | type[3] waterlogged[2] | 14733 | 14736 | 1.5 | 6.0 | yes | 0 | DIAMOND | STONE | PUSH_PULL | BASEDRUM | legacyCopy(dark_prismarine) viewBlocking:nearPlane |
| 471 | 590 | sea_lantern | Block | 1 | - | 14739 | 14739 | 0.3 | 0.3 | no | 15 | QUARTZ | GLASS | PUSH_PULL | HAT | redstoneConductor:never |
| 472 | 591 | hay_block | HayBlock | 3 | axis[3] | 14740 | 14741 | 0.5 | 0.5 | no | 0 | COLOR_YELLOW | GRASS | PUSH_PULL | BANJO | - |
| 473 | 592 to 607 | carpet | WoolCarpetBlock | 1 | - | 14743 to 14758 | 14743 + k*1 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 |
| 474 | 608 | terracotta | Block | 1 | - | 14759 | 14759 | 1.25 | 4.2 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | - |
| 475 | 609 | coal_block | Block | 1 | - | 14760 | 14760 | 5.0 | 6.0 | yes | 0 | COLOR_BLACK | STONE | PUSH_PULL | BASEDRUM | - |
| 476 | 610 | packed_ice | Block | 1 | - | 14761 | 14761 | 0.5 | 0.5 | no | 0 | ICE | GLASS | PUSH_PULL | CHIME | - |
| 477 | 611 | sunflower | TallFlowerBlock | 2 | half[2] | 14762 | 14763 | 0 | 0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision offset:XZ ignitedByLava |
| 478 | 612 | lilac | TallFlowerBlock | 2 | half[2] | 14764 | 14765 | 0 | 0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision offset:XZ ignitedByLava |
| 479 | 613 | rose_bush | TallFlowerBlock | 2 | half[2] | 14766 | 14767 | 0 | 0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision offset:XZ ignitedByLava |
| 480 | 614 | peony | TallFlowerBlock | 2 | half[2] | 14768 | 14769 | 0 | 0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision offset:XZ ignitedByLava |
| 481 | 615 | tall_grass | DoublePlantBlock | 2 | half[2] | 14770 | 14771 | 0 | 0 | no | 0 | PLANT | GRASS | POPPED | HARP | replaceable noCollision offset:XZ ignitedByLava |
| 482 | 616 | large_fern | DoublePlantBlock | 2 | half[2] | 14772 | 14773 | 0 | 0 | no | 0 | PLANT | GRASS | POPPED | HARP | replaceable noCollision offset:XZ ignitedByLava |
| 483 | 617 to 632 | banner | BannerBlock | 16 | rotation[16] | 14774 to 15029 | 14782 + k*16 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 |
| 484 | 633 to 648 | wall_banner | WallBannerBlock | 4 | facing[4] | 15030 to 15093 | 15030 + k*4 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 | see 5 |
| 485 | 649 | red_sandstone | Block | 1 | - | 15094 | 15094 | 0.8 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | - |
| 486 | 650 | chiseled_red_sandstone | Block | 1 | - | 15095 | 15095 | 0.8 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | - |
| 487 | 651 | cut_red_sandstone | Block | 1 | - | 15096 | 15096 | 0.8 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | - |
| 488 | 652 | red_sandstone_stairs | StairBlock | 80 | facing[4] half[2] shape[5] waterlogged[2] | 15097 | 15108 | 0.8 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(red_sandstone) viewBlocking:nearPlane |
| 489 | 653 | oak_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15177 | 15180 | 2.0 | 3.0 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(oak_planks) viewBlocking:nearPlane |
| 490 | 654 | spruce_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15183 | 15186 | 2.0 | 3.0 | no | 0 | PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(spruce_planks) viewBlocking:nearPlane |
| 491 | 655 | birch_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15189 | 15192 | 2.0 | 3.0 | no | 0 | SAND | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(birch_planks) viewBlocking:nearPlane |
| 492 | 656 | jungle_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15195 | 15198 | 2.0 | 3.0 | no | 0 | DIRT | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(jungle_planks) viewBlocking:nearPlane |
| 493 | 657 | acacia_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15201 | 15204 | 2.0 | 3.0 | no | 0 | COLOR_ORANGE | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(acacia_planks) viewBlocking:nearPlane |
| 494 | 658 | cherry_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15207 | 15210 | 2.0 | 3.0 | no | 0 | TERRACOTTA_WHITE | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(cherry_planks) viewBlocking:nearPlane |
| 495 | 659 | dark_oak_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15213 | 15216 | 2.0 | 3.0 | no | 0 | COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(dark_oak_planks) viewBlocking:nearPlane |
| 496 | 660 | pale_oak_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15219 | 15222 | 2.0 | 3.0 | no | 0 | QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(pale_oak_planks) viewBlocking:nearPlane |
| 497 | 661 | mangrove_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15225 | 15228 | 2.0 | 3.0 | no | 0 | COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(mangrove_planks) viewBlocking:nearPlane |
| 498 | 662 | poplar_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15231 | 15234 | 2.0 | 3.0 | no | 0 | COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(poplar_planks) viewBlocking:nearPlane |
| 499 | 663 | bamboo_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15237 | 15240 | 2.0 | 3.0 | no | 0 | COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(bamboo_planks) viewBlocking:nearPlane |
| 500 | 664 | bamboo_mosaic_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15243 | 15246 | 2.0 | 3.0 | no | 0 | COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava legacyCopy(bamboo_mosaic) viewBlocking:nearPlane |
| 501 | 665 | stone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15249 | 15252 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(stone) viewBlocking:nearPlane |
| 502 | 666 | sandstone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15255 | 15258 | 2.0 | 6.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy(sandstone) viewBlocking:nearPlane |
| 503 | 667 | cut_sandstone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15261 | 15264 | 2.0 | 6.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | legacyCopy(cut_sandstone) viewBlocking:nearPlane |
| 504 | 668 | petrified_oak_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15267 | 15270 | 2.0 | 6.0 | yes | 0 | WOOD | STONE | PUSH_PULL | BASEDRUM | - |
| 505 | 669 | cobblestone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15273 | 15276 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(cobblestone) viewBlocking:nearPlane |
| 506 | 670 | brick_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15279 | 15282 | 2.0 | 6.0 | yes | 0 | COLOR_RED | STONE | PUSH_PULL | BASEDRUM | legacyCopy(bricks) viewBlocking:nearPlane |
| 507 | 671 | stone_brick_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15285 | 15288 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(stone_bricks) viewBlocking:nearPlane |
| 508 | 672 | mud_brick_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15291 | 15294 | 1.5 | 3.0 | yes | 0 | TERRACOTTA_LIGHT_GRAY | MUD_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy(mud_bricks) viewBlocking:nearPlane |
| 509 | 673 | nether_brick_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15297 | 15300 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | legacyCopy(nether_bricks) viewBlocking:nearPlane |
| 510 | 674 | quartz_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15303 | 15306 | 2.0 | 0.8 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | legacyCopy(quartz_block) viewBlocking:nearPlane |
| 511 | 675 | red_sandstone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15309 | 15312 | 2.0 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(red_sandstone) viewBlocking:nearPlane |
| 512 | 676 | cut_red_sandstone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15315 | 15318 | 2.0 | 0.8 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(cut_red_sandstone) viewBlocking:nearPlane |
| 513 | 677 | smooth_stone | Block | 1 | - | 15321 | 15321 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 514 | 678 | smooth_stone_slab | SlabBlock | 6 | type[3] waterlogged[2] | 15322 | 15325 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | legacyCopy(smooth_stone) viewBlocking:nearPlane |
| 515 | 679 | smooth_sandstone | Block | 1 | - | 15328 | 15328 | 2.0 | 6.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | - |
| 516 | 680 | smooth_quartz | Block | 1 | - | 15329 | 15329 | 2.0 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | - |
| 517 | 681 | smooth_red_sandstone | Block | 1 | - | 15330 | 15330 | 2.0 | 6.0 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | - |
| 518 | 682 | spruce_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15331 | 15338 | 2.0 | 3.0 | no | 0 | PODZOL | WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |
| 519 | 683 | birch_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15363 | 15370 | 2.0 | 3.0 | no | 0 | SAND | WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |
| 520 | 684 | jungle_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15395 | 15402 | 2.0 | 3.0 | no | 0 | DIRT | WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |
| 521 | 685 | acacia_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15427 | 15434 | 2.0 | 3.0 | no | 0 | COLOR_ORANGE | WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |
| 522 | 686 | cherry_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15459 | 15466 | 2.0 | 3.0 | no | 0 | TERRACOTTA_WHITE | CHERRY_WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |
| 523 | 687 | dark_oak_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15491 | 15498 | 2.0 | 3.0 | no | 0 | COLOR_BROWN | WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |
| 524 | 688 | pale_oak_fence_gate | FenceGateBlock | 32 | facing[4] in_wall[2] open[2] powered[2] | 15523 | 15530 | 2.0 | 3.0 | no | 0 | QUARTZ | WOOD (ctor) | PUSH_PULL | BASS | forceSolidOn ignitedByLava |

## 4. Notes to the rows

1. **Daylight detector.** There is one block, `daylight_detector`, with property `inverted`. The "inverted daylight
   detector" is the state `inverted=true`, not a separate block (field 438 is the only daylight detector field, and its class declares the property `inverted`).
2. **Pale oak, poplar and the other woods.** The wood families here include pale oak, poplar, bamboo, mangrove and cherry. The rows keep the field order of the artifact: acacia, cherry, dark
   oak, pale oak, mangrove, poplar, bamboo, bamboo mosaic for the stairs (fields 450 to 457), and oak, spruce, birch,
   jungle, acacia, cherry, dark oak, pale oak, mangrove, poplar, bamboo, bamboo mosaic for the slabs (fields 489 to 500).
   Fence gates in this part are spruce, birch, jungle, acacia, cherry, dark oak, pale oak (fields 518 to 524); the oak
   gate and the mangrove, poplar and bamboo gates are in earlier or later parts.
3. **Slab and stair copies.** A stair or slab is built with `Properties.ofLegacyCopy(base)` (24 part 1 §4.3), so it
   takes hardness, blast resistance, tool flag, map colour, sound, instrument, light, flags, push reaction, friction,
   speed factor and bounce restitution from the base block, and it does **not** copy jump factor, the spawn and
   conductor predicates, the suffocating and view-blocking predicates, or the loot table. The helpers then set
   `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)`. This list applies to `registerLegacyStair` and the slab helpers only. `registerStair` is a different helper: it starts from `ofFullCopy(base)`, which copies more than the legacy copy. All 13 stairs of this part (quartz, the eight woods, three prismarine, red sandstone) use `registerLegacyStair` (read from the call sites in the `Blocks` static initialiser); the eight `registerStair` users are the concrete and wool stair collections and the six sulfur and cinnabar stairs, all outside this part. `registerSlab(id, base, d)` also sets the hardness to d, and
   `registerSlab(id, base, h, r)` sets hardness h and blast resistance r. Hence `quartz_slab` has hardness 2.0 and blast
   resistance 0.8 (the base's value), `red_sandstone_slab` and `cut_red_sandstone_slab` also 2.0 and 0.8, `stone_slab`
   2.0 and 6.0 (hardness replaced; the base `stone` is 1.5 and 6.0), `stone_brick_slab` 2.0 and 6.0 (hardness replaced; the
   base `stone_bricks` is 1.5 and 6.0) and `mud_brick_slab` 1.5 and 3.0 (the base `mud_bricks` values). The `petrified_oak_slab` has its own
   builder chain (hardness 2.0, blast resistance 6.0, needs the correct tool, map colour `WOOD`, instrument `BASEDRUM`,
   sound `STONE`) and no legacy copy. `smooth_stone_slab`, `smooth_sandstone` and `smooth_quartz` follow the rows.
4. **Fence gate map colour.** `Block.defaultMapColor(planks)` returns the planks block's default-state map colour and the
   chain passes it to `mapColor`; the map colour of each gate is that of its planks (spruce `PODZOL`, birch `SAND`,
   jungle `DIRT`, acacia `COLOR_ORANGE`, cherry `TERRACOTTA_WHITE`, dark oak `COLOR_BROWN`, pale oak `QUARTZ`).
5. **Barrier and light block.** Both call `waterloggedMapColor(NONE)` then `mapColor`: the map colour is `WATER` when the
   state is waterlogged and `NONE` otherwise (`Blocks.lambda$waterloggedMapColor$0`: returns `MapColor.WATER` for
   waterlogged true, else the given colour). Hardness -1 and blast resistance 3600000.8 make both unbreakable.
   The light block's `lightLevel` is the function `LightBlock.LIGHT_EMISSION`: the state's `level` property.
6. **Redstone conductor.** `redstone_block` and `sea_lantern` set `isRedstoneConductor` to the constant false
   predicate (`Blocks.never`). (`redstone_block` is a signal source of power 15 regardless: section 7.)
7. **Sea lantern light.** `lightLevel` is a constant function returning 15 (`Blocks.lambda$static$257` returns 15).
8. **Friction and bounce.** `slime_block` has friction 0.8 and `bounceRestitution(1.0)`; `packed_ice` has friction 0.98.
   Friction 0.8 (slime) and 0.98 (packed ice) were read at the `friction` calls of the `Blocks` initialiser. Other rows keep the defaults 0.6 friction (24 part 1 §4.1). The bounce restitution is read by entity code
   (`Entity.getBlockBounciness`: the block's `getBounceRestitution`, multiplied by 0.8 when the
   entity is not a `LivingEntity`; the 0.8 constant was read there); the
   motion rule that uses it belongs to the entity movement documents (Open question 4).
9. **Heads.** The five floor head rows (`zombie`, `player`, `creeper`, `dragon`, `piglin`) set `noOcclusion` and
   an instrument (`ZOMBIE`, `CUSTOM_HEAD`, `CREEPER`, `DRAGON`, `PIGLIN`). The wither skeleton floor skull is field 419,
   the last row of the preceding part. Wall variants use `Properties.of()` through `wallVariant`: they have default instrument `HARP`, collision, and
   `canOcclude` true, and they take loot table and description from the floor variant. The wither skeleton wall skull
   uses class `WitherWallSkullBlock`; the others `WallSkullBlock`, `PlayerWallHeadBlock` (player) and `PiglinWallSkullBlock`
   (piglin).
10. **Tall flowers and tall grass.** Offset type `XZ` (section 6.1), `noCollision`, `ignitedByLava`, push `POPPED`, sound
    `GRASS`, instant break. `tall_grass` and `large_fern` are also `replaceable`. Classes: `TallFlowerBlock` (sunflower,
    lilac, rose bush, peony) and `DoublePlantBlock` (tall grass, large fern).

## 5. The four colour collections

Each of these fields registers 16 blocks in the dye order white, orange, magenta, light_blue, yellow, lime, pink, gray,
light_gray, cyan, purple, blue, brown, green, red, black (24 part 1 §2.3). The key is the colour joined to the base name
by an underscore, colour first (`ColorCollection.prefixWithColor`, recipe `<colour>_<name>`). The colour is the
`DyeColor` passed to the block's constructor and to the properties function. Properties:

| Collection | Class (constructor receives the dye) | Builder chain per colour | Per-state values |
|---|---|---|---|
| `DYED_TERRACOTTA` (`<colour>_terracotta`) | `Block` (plain; the dye is used only by the properties) | `of()`; map colour = the dye's terracotta colour (`DyeColor.getTerracottaColor`); instrument `BASEDRUM`; requires the correct tool; hardness 1.25; blast resistance 4.2 | sound `STONE`, push `PUSH_PULL`, light 0 |
| `STAINED_GLASS_PANE` (`<colour>_stained_glass_pane`) | `StainedGlassPaneBlock` (also `BeaconBeamBlock`; stores the dye) | `of()`; instrument `HAT`; hardness 0.3; sound `GLASS`; `noOcclusion`; **no** map colour call, so `NONE` | blast resistance 0.3 (`strength(0.3)` sets both), push `PUSH_PULL` |
| `CARPET` (`<colour>_carpet`) | `WoolCarpetBlock` (stores the dye) | `of()`; map colour = the dye's map colour (`DyeColor.getMapColor`); hardness 0.1 (blast 0.1); sound `WOOL`; `ignitedByLava` | push `PUSH_PULL`, instrument `HARP` |
| `BANNER` (`<colour>_banner`) | `BannerBlock` | `of()`; map colour `WOOD`; `forceSolidOn`; instrument `BASS`; `noCollision`; hardness 1.0 (blast 1.0); sound `WOOD`; `ignitedByLava` | push `PUSH_PULL` |
| `WALL_BANNER` (`<colour>_wall_banner`, key from `BlockIds`) | `WallBannerBlock` | `wallVariant(banner of the same colour, true)` (loot table and description id of the standing banner), then the same chain as the banner | push `PUSH_PULL` |

The dye table that supplies the map colours (read from the `DyeColor` constants; the first colour is `getMapColor`, the
second `getTerracottaColor`): white `SNOW`, `TERRACOTTA_WHITE`; orange `COLOR_ORANGE`, `TERRACOTTA_ORANGE`; magenta
`COLOR_MAGENTA`, `TERRACOTTA_MAGENTA`; light_blue `COLOR_LIGHT_BLUE`, `TERRACOTTA_LIGHT_BLUE`; yellow `COLOR_YELLOW`,
`TERRACOTTA_YELLOW`; lime `COLOR_LIGHT_GREEN`, `TERRACOTTA_LIGHT_GREEN`; pink `COLOR_PINK`, `TERRACOTTA_PINK`; gray
`COLOR_GRAY`, `TERRACOTTA_GRAY`; light_gray `COLOR_LIGHT_GRAY`, `TERRACOTTA_LIGHT_GRAY`; cyan `COLOR_CYAN`,
`TERRACOTTA_CYAN`; purple `COLOR_PURPLE`, `TERRACOTTA_PURPLE`; blue `COLOR_BLUE`, `TERRACOTTA_BLUE`; brown `COLOR_BROWN`,
`TERRACOTTA_BROWN`; green `COLOR_GREEN`, `TERRACOTTA_GREEN`; red `COLOR_RED`, `TERRACOTTA_RED`; black `COLOR_BLACK`,
`TERRACOTTA_BLACK`. (The dye's other attributes, text colour, firework colour and texture diffuse colour, belong to the
item and dye documents.)

Per-colour ids (id, first state id, default id are absolute with the bases of section 1):

**dyed_terracotta**

| k | key | id | first state id | default id | map colour |
|---|---|---|---|---|---|
| 0 | white_terracotta | 537 | 13211 | 13211 | TERRACOTTA_WHITE |
| 1 | orange_terracotta | 538 | 13212 | 13212 | TERRACOTTA_ORANGE |
| 2 | magenta_terracotta | 539 | 13213 | 13213 | TERRACOTTA_MAGENTA |
| 3 | light_blue_terracotta | 540 | 13214 | 13214 | TERRACOTTA_LIGHT_BLUE |
| 4 | yellow_terracotta | 541 | 13215 | 13215 | TERRACOTTA_YELLOW |
| 5 | lime_terracotta | 542 | 13216 | 13216 | TERRACOTTA_LIGHT_GREEN |
| 6 | pink_terracotta | 543 | 13217 | 13217 | TERRACOTTA_PINK |
| 7 | gray_terracotta | 544 | 13218 | 13218 | TERRACOTTA_GRAY |
| 8 | light_gray_terracotta | 545 | 13219 | 13219 | TERRACOTTA_LIGHT_GRAY |
| 9 | cyan_terracotta | 546 | 13220 | 13220 | TERRACOTTA_CYAN |
| 10 | purple_terracotta | 547 | 13221 | 13221 | TERRACOTTA_PURPLE |
| 11 | blue_terracotta | 548 | 13222 | 13222 | TERRACOTTA_BLUE |
| 12 | brown_terracotta | 549 | 13223 | 13223 | TERRACOTTA_BROWN |
| 13 | green_terracotta | 550 | 13224 | 13224 | TERRACOTTA_GREEN |
| 14 | red_terracotta | 551 | 13225 | 13225 | TERRACOTTA_RED |
| 15 | black_terracotta | 552 | 13226 | 13226 | TERRACOTTA_BLACK |

**stained_glass_pane**

| k | key | id | first state id | default id | map colour |
|---|---|---|---|---|---|
| 0 | white_stained_glass_pane | 553 | 13227 | 13258 | NONE (no mapColor call) |
| 1 | orange_stained_glass_pane | 554 | 13259 | 13290 | NONE (no mapColor call) |
| 2 | magenta_stained_glass_pane | 555 | 13291 | 13322 | NONE (no mapColor call) |
| 3 | light_blue_stained_glass_pane | 556 | 13323 | 13354 | NONE (no mapColor call) |
| 4 | yellow_stained_glass_pane | 557 | 13355 | 13386 | NONE (no mapColor call) |
| 5 | lime_stained_glass_pane | 558 | 13387 | 13418 | NONE (no mapColor call) |
| 6 | pink_stained_glass_pane | 559 | 13419 | 13450 | NONE (no mapColor call) |
| 7 | gray_stained_glass_pane | 560 | 13451 | 13482 | NONE (no mapColor call) |
| 8 | light_gray_stained_glass_pane | 561 | 13483 | 13514 | NONE (no mapColor call) |
| 9 | cyan_stained_glass_pane | 562 | 13515 | 13546 | NONE (no mapColor call) |
| 10 | purple_stained_glass_pane | 563 | 13547 | 13578 | NONE (no mapColor call) |
| 11 | blue_stained_glass_pane | 564 | 13579 | 13610 | NONE (no mapColor call) |
| 12 | brown_stained_glass_pane | 565 | 13611 | 13642 | NONE (no mapColor call) |
| 13 | green_stained_glass_pane | 566 | 13643 | 13674 | NONE (no mapColor call) |
| 14 | red_stained_glass_pane | 567 | 13675 | 13706 | NONE (no mapColor call) |
| 15 | black_stained_glass_pane | 568 | 13707 | 13738 | NONE (no mapColor call) |

**carpet**

| k | key | id | first state id | default id | map colour |
|---|---|---|---|---|---|
| 0 | white_carpet | 592 | 14743 | 14743 | SNOW |
| 1 | orange_carpet | 593 | 14744 | 14744 | COLOR_ORANGE |
| 2 | magenta_carpet | 594 | 14745 | 14745 | COLOR_MAGENTA |
| 3 | light_blue_carpet | 595 | 14746 | 14746 | COLOR_LIGHT_BLUE |
| 4 | yellow_carpet | 596 | 14747 | 14747 | COLOR_YELLOW |
| 5 | lime_carpet | 597 | 14748 | 14748 | COLOR_LIGHT_GREEN |
| 6 | pink_carpet | 598 | 14749 | 14749 | COLOR_PINK |
| 7 | gray_carpet | 599 | 14750 | 14750 | COLOR_GRAY |
| 8 | light_gray_carpet | 600 | 14751 | 14751 | COLOR_LIGHT_GRAY |
| 9 | cyan_carpet | 601 | 14752 | 14752 | COLOR_CYAN |
| 10 | purple_carpet | 602 | 14753 | 14753 | COLOR_PURPLE |
| 11 | blue_carpet | 603 | 14754 | 14754 | COLOR_BLUE |
| 12 | brown_carpet | 604 | 14755 | 14755 | COLOR_BROWN |
| 13 | green_carpet | 605 | 14756 | 14756 | COLOR_GREEN |
| 14 | red_carpet | 606 | 14757 | 14757 | COLOR_RED |
| 15 | black_carpet | 607 | 14758 | 14758 | COLOR_BLACK |

**banner**

| k | key | id | first state id | default id | map colour |
|---|---|---|---|---|---|
| 0 | white_banner | 617 | 14774 | 14782 | WOOD |
| 1 | orange_banner | 618 | 14790 | 14798 | WOOD |
| 2 | magenta_banner | 619 | 14806 | 14814 | WOOD |
| 3 | light_blue_banner | 620 | 14822 | 14830 | WOOD |
| 4 | yellow_banner | 621 | 14838 | 14846 | WOOD |
| 5 | lime_banner | 622 | 14854 | 14862 | WOOD |
| 6 | pink_banner | 623 | 14870 | 14878 | WOOD |
| 7 | gray_banner | 624 | 14886 | 14894 | WOOD |
| 8 | light_gray_banner | 625 | 14902 | 14910 | WOOD |
| 9 | cyan_banner | 626 | 14918 | 14926 | WOOD |
| 10 | purple_banner | 627 | 14934 | 14942 | WOOD |
| 11 | blue_banner | 628 | 14950 | 14958 | WOOD |
| 12 | brown_banner | 629 | 14966 | 14974 | WOOD |
| 13 | green_banner | 630 | 14982 | 14990 | WOOD |
| 14 | red_banner | 631 | 14998 | 15006 | WOOD |
| 15 | black_banner | 632 | 15014 | 15022 | WOOD |

**wall_banner**

| k | key | id | first state id | default id | map colour |
|---|---|---|---|---|---|
| 0 | white_wall_banner | 633 | 15030 | 15030 | WOOD |
| 1 | orange_wall_banner | 634 | 15034 | 15034 | WOOD |
| 2 | magenta_wall_banner | 635 | 15038 | 15038 | WOOD |
| 3 | light_blue_wall_banner | 636 | 15042 | 15042 | WOOD |
| 4 | yellow_wall_banner | 637 | 15046 | 15046 | WOOD |
| 5 | lime_wall_banner | 638 | 15050 | 15050 | WOOD |
| 6 | pink_wall_banner | 639 | 15054 | 15054 | WOOD |
| 7 | gray_wall_banner | 640 | 15058 | 15058 | WOOD |
| 8 | light_gray_wall_banner | 641 | 15062 | 15062 | WOOD |
| 9 | cyan_wall_banner | 642 | 15066 | 15066 | WOOD |
| 10 | purple_wall_banner | 643 | 15070 | 15070 | WOOD |
| 11 | blue_wall_banner | 644 | 15074 | 15074 | WOOD |
| 12 | brown_wall_banner | 645 | 15078 | 15078 | WOOD |
| 13 | green_wall_banner | 646 | 15082 | 15082 | WOOD |
| 14 | red_wall_banner | 647 | 15086 | 15086 | WOOD |
| 15 | black_wall_banner | 648 | 15090 | 15090 | WOOD |

Wall banners: the wall banner's `facing` is a `HorizontalDirectionalBlock.FACING` (north, south, west, east), default
north. Banner `rotation` default is 8 (the banner faces north in the model convention of the rotation segment).

## 6. Shape helpers and pixel-box geometry

All shapes below are written as pixel boxes `(x0,y0,z0)-(x1,y1,z1)` on the 16-pixel block (24 part 1 §6). Helpers read
from `Block`:

| Helper | Meaning (read from the bytecode) |
|---|---|
| `box(x0,y0,z0,x1,y1,z1)` | the six numbers divided by 16 (`Shapes.box`) |
| `column(s, y0, y1)` | `box(8-s/2, y0, 8-s/2, 8+s/2, y1, 8+s/2)`; `column(sx, sz, y0, y1)` has separate X and Z sizes |
| `cube(sx, sy, sz)` | `column(sx, sz, 8-sy/2, 8+sy/2)`; `cube(s)` = `cube(s,s,s)` |
| `boxZ(sx, z0, z1)` | `boxZ(sx, sx, z0, z1)` |
| `boxZ(sx, sy, z0, z1)` | `box(8-sx/2, 8-sy/2, z0, 8+sx/2, 8+sy/2, z1)` |
| `boxZ(sx, y0, y1, z0, z1)` | `box(8-sx/2, y0, z0, 8+sx/2, y1, z1)` |

Rotation of shape maps (`Shapes.rotateHorizontal`, `rotateHorizontalAxis`, `rotateAll`): the given shape is the
**north** entry (identity). The east entry is the shape rotated by `BLOCK_ROT_Y_90`, south by `BLOCK_ROT_Y_180`, west by
`BLOCK_ROT_Y_270`, about the block centre (8, 8, 8) unless a centre is given. `rotateHorizontalAxis(s)` maps axis Z to `s`
and axis X to `s` rotated 90 degrees. `rotateAll` adds `up` (`BLOCK_ROT_X_270`) and `down` (`BLOCK_ROT_X_90`). In pixels, the
rotation by 90 degrees (north to east, clockwise seen from above) maps the box (x0,z0)-(x1,z1) to (16-z1, 16-z0 in X)
and (x0..x1 in Z): the new X range is `16 - z1` to `16 - z0` and the new Z range is `x0` to `x1`; the Y range is unchanged.
Rotating by 180 degrees gives X `16-x1..16-x0` and Z `16-z1..16-z0`; by 270 degrees the new X range is `z0..z1` and the new
Z range is `16-x1..16-x0`. `Shapes.join(a, b, ONLY_FIRST)` is a minus b, `AND` is intersection, `Shapes.or` union.
`getShapeForEachState` collapses properties that the shape ignores.

### 6.1 Offset type XZ (tall flowers, tall grass, large fern)

`offsetType(XZ)` installs the offset function of the second lambda of `Properties.offsetType` (ordinal 1). For a block
position (x, y, z): let `seed = Mth.getSeed(x, 0, z)`, where `Mth.getSeed(x,y,z)` is: `l = (x * 3129871 as an int product,
widened to long) XOR (z * 116129781L) XOR y`; `l = l * l * 42317861L + l * 11L`; the result is `l >> 16` (arithmetic shift). All four constants and the shift were re-read in `Mth.getSeed(int,int,int)`. Then the horizontal offset limit `m` is `Block.getMaxHorizontalOffset()` (0.25: the `BlockBehaviour.getMaxHorizontalOffset` default, read; no class in the `net.minecraft.world.level.block` package overrides it, checked by searching the class files for the method name). The offset is
`dx = clamp(((seed & 15) / 15 - 0.5) * 0.5, -m, m)`, `dy = 0`, `dz = clamp((((seed >> 8) & 15) / 15 - 0.5) * 0.5, -m, m)`.
The offset applies to the outline and collision shape, to the model and to the selection box; it does not move the block.
Both offset lambdas of `Properties.offsetType` seed with `Mth.getSeed(x, 0, z)` (read). (Type `XYZ` is the other lambda: `dy = ((seed >> 4 & 15) / 15 - 1) * getMaxVerticalOffset()`, vertical limit `BlockBehaviour.getMaxVerticalOffset` 0.2, read; not used here.)

## 7. Classes: shapes, defaults, placement, `canSurvive`, interaction

Section 7 lists, per class, what the registry specifies. Redstone signal propagation, scheduled ticks, falling-block
entities and block entities are other documents (design map RS9 `29-block-updates-and-placement`, RS11, RS12
`30-redstone`, RS13 `31-block-entities`); where a rule below needs them it states the registry-visible part and names
the owner.

### 7.1 Skulls and heads

Classes: `AbstractSkullBlock` (property `powered`, default false; block entity `SkullBlockEntity`; not pathfindable),
`SkullBlock` (adds `rotation`, default 0), `WallSkullBlock` (adds `facing`, default north), `PlayerHeadBlock`,
`PlayerWallHeadBlock`, `PiglinWallSkullBlock`, `WitherWallSkullBlock` (`setPlacedBy` calls the wither build check,
`WitherSkullBlock.checkSpawn`, a structure rule outside this document). The skull "type" passed to the constructor
(`SkullBlock$Types`: wither skeleton, zombie, player, creeper, dragon, piglin) selects the shape and the block entity data.

| Aspect | Rule |
|---|---|
| Shapes (floor) | collision `box(4,0,4)-(12,8,12)` for every type except piglin; piglin `box(3,0,3)-(13,8,13)`. The outline (`getShape`) is the collision shape, except for the **dragon** head, whose outline is `box(4,0,4)-(12,8.5,12)`. |
| Shapes (wall), facing north | `box(4,4,8)-(12,12,16)`; east `(0,4,4)-(8,12,12)`; south `(4,4,0)-(12,12,8)`; west `(8,4,4)-(16,12,12)`. The piglin wall head, facing north: `box(3,4,8)-(13,12,16)`; east `(0,4,3)-(8,12,13)`; south `(3,4,0)-(13,12,8)`; west `(8,4,3)-(16,12,13)`. The dragon wall head uses the ordinary wall shape. |
| Placement, floor | `powered` = the position receives a neighbour signal (`Level.hasNeighborSignal`); `rotation` = `RotationSegment.convertToSegment(placer yaw)`: the angle `round(yaw * 16 / 360)` taken modulo 16. Segment 0 faces south, 4 west, 8 north, 12 east (`fromDirection` is the 2D data value shifted left by 2, matching the table of section 2). The reverse function `RotationSegment.convertToDirection` uses a different table: constants `NORTH_0` = 0, `EAST_90` = 4, `SOUTH_180` = 8, `WEST_270` = 12, so 0 gives north, 4 east, 8 south, 12 west, and any other segment gives no direction. The two tables are opposite, so a banner rotation of 8 does not "face north" by `convertToDirection` (it maps to south). |
| Placement, wall | start from the floor-skull placement (`powered` from the neighbour signal); then scan `BlockPlaceContext.getNearestLookingDirections()` in the order given: skip non-horizontal directions; for a horizontal direction d set `facing = d.opposite`, and accept (return that state) when the block state at `pos.relative(d)` does **not** pass `BlockState.canBeReplaced(BlockPlaceContext)` (`WallSkullBlock.getStateForPlacement` calls `canBeReplaced(BlockPlaceContext)` on the block at `pos.relative(d)`, read). The first accepted direction is used; if none is accepted the placement fails (null). `getNearestLookingDirections()` is `Direction.orderedByNearest(player)` (the direction nearest to the look vector first); the context's flag `replaceClicked` (set when the clicked block is replaced by the placement) decides the rest: when it is **set**, the order is returned unchanged; when it is **not set**, the opposite of the clicked face is moved to the front of that order (the entries before it shift one place back). Read in `BlockPlaceContext.getNearestLookingDirections`; an earlier draft stated the two cases the other way round. |
| `rotate` / `mirror` | floor: `rotation` through `Rotation.rotate(rotation, 16)` and `Mirror.mirror(rotation, 16)`; wall: `facing` rotated or mirrored |
| `neighborChanged` | on the server, `powered` is set to `hasNeighborSignal` when it differs (flag 2) |
| Signal and block entity | `SkullBlockEntity` (RS13); the ticker runs on the client only, and only for dragon and piglin heads (dragon and piglin floor and wall: animation) |
| `canSurvive` | default true (no support requirement; a head can float) |
| Properties | `pushReaction POPPED`, hardness 1.0 (24 part 1 §4) |

### 7.2 Anvil (`AnvilBlock`, a `FallingBlock`)

| Aspect | Rule |
|---|---|
| Properties | `facing` (4), default north |
| Placement | `facing` = the clockwise direction of the placer's horizontal facing (`getHorizontalDirection().getClockWise()`) |
| Shape | built for axis Z then rotated: union of `box(2,0,2)-(14,4,14)`, `box(4,4,3)-(12,5,13)`, `box(6,5,4)-(10,10,12)`, `box(3,10,0)-(13,16,16)`; the entry for the axis X is the same union rotated 90 degrees: `(2,0,2)-(14,4,14)`, `(3,4,4)-(13,5,12)`, `(4,5,6)-(12,10,10)`, `(0,10,3)-(16,16,13)`. The lookup key is `facing.getAxis()`: facing north or south uses the Z shape. |
| Use | `useWithoutItem` on the server opens the anvil menu (title key `container.repair`), awards the stat "interact with anvil"; client: success. The menu is `AnvilMenu`. |
| Falling | as a `FallingBlock` (24 part 1 §14 owner RS11): `onPlace` and `updateShape` schedule a tick after 2 game ticks (`FallingBlock` delay constant 2, read); the tick starts a falling block entity when the block below is free (`FallingBlock.isFree`: air, the block tag `fire`, or a state that is replaceable; read) and the block's y is not below the level's minimum y (`getMinY()`; it falls at y >= minY); the anvil's `falling` hook calls `setHurtsEntities(2.0, 40)` (`AnvilBlock.falling`: float 2.0, int 40, read): damage per fallen block 2.0, maximum 40; landing (`AnvilBlock.onLand`) plays level event 1031 and breaking after the fall (`onBrokenAfterFall`) level event 1029 (both constants read) (both unless silent); the fall damage source is `anvil`. `damage(state)`: anvil becomes chipped anvil, chipped becomes damaged anvil, keeping `facing`; damaged anvil returns null (destroyed). `getDustColor` is the block's map colour value. |
| Pushing | `IMMOVEABLE` |
| Pathfinding | `isPathfindable` false |

### 7.3 Chest family: trapped chest (`TrappedChestBlock extends ChestBlock`)

| Aspect | Rule |
|---|---|
| Properties | `facing` (4), `type` (single, left, right), `waterlogged`; default facing north, single, not waterlogged |
| Shape | single: `box(1,0,1)-(15,14,15)`. Joined halves (`type` left or right): the shape extends toward the partner, keyed by `ChestBlock.getConnectedDirection(state)` (clockwise of `facing` for LEFT, counter-clockwise for RIGHT): toward north `(1,0,0)-(15,14,15)`, east `(1,0,1)-(16,14,15)`, south `(1,0,1)-(15,14,16)`, west `(0,0,1)-(15,14,15)` |
| Placement | `facing` = opposite of the placer's horizontal direction; `waterlogged` from the fluid at the position; `type` starts single. The click branch runs only when secondary use is active and the clicked face is horizontal: let `partner = candidatePartnerFacing(level, pos, clickedFace.opposite)`. When the partner exists and its axis differs from the axis of the **clicked face**, the placed chest's `facing` is replaced by the partner's `facing`, and the type is RIGHT when `partner.getCounterClockWise()` equals `clickedFace.opposite`, else LEFT. (Default `facing` before this branch: the opposite of the placer's horizontal direction.) When the type is still single and secondary use is not active, `getChestType(level, pos, facing)` is used: if `candidatePartnerFacing(level, pos, facing.getClockWise())` equals `facing` the type is LEFT; else if the same test with `facing.getCounterClockWise()` equals `facing` the type is RIGHT; else SINGLE. `candidatePartnerFacing(level, pos, dir)` is the `facing` of the block at `pos.relative(dir)` when it passes `chestCanConnectTo` (it is a chest of the same block) and its `type` is single, else none |
| `updateShape` | when the changed neighbour is a connectable chest on a horizontal side and this chest is single or the neighbours pair up (same facing, partner direction opposite), `type` is set to the neighbour's opposite type; when this chest is joined and the neighbour in the connected direction changed to not be a chest, `type` becomes single |
| Signals | signal source: output power = number of viewers of the chest (`getOpenCount`) clamped to 0 to 15; direct signal only upward (`Direction.UP`); comparator output = container fullness (`getRedstoneSignalFromContainer`); block entity `TrappedChestBlockEntity` (RS13). Open and close sounds are the ordinary chest sounds; the stat is `trigger_trapped_chest`. |
| `canSurvive` | default true |

The placement text above was read in full from `getStateForPlacement`; `getChestType` is called only when the type is still SINGLE and secondary use is not active.

### 7.4 Weighted pressure plates (`WeightedPressurePlateBlock extends BasePressurePlateBlock`)

| Aspect | Rule |
|---|---|
| Rows | `light_weighted_pressure_plate`: max weight 15, block set type `GOLD`. `heavy_weighted_pressure_plate`: max weight 150, `IRON` |
| Properties | `power` 0 to 15, default 0 |
| Shape | not pressed (signal 0): `column(14,0,1)` = `box(1,0,1)-(15,1,15)`; pressed: `column(14,0,0.5)` = `box(1,0,1)-(15,0.5,15)`; both `noCollision` so the collision shape is empty. Entity detection box: `column(14,0,4)` converted to an AABB (`box(1,0,1)-(15,4,15)`), moved to the plate's position |
| `canSurvive` | the block below can support a rigid block on its upper face (`canSupportRigidBlock`), or it can support the centre of its upper face (`canSupportCenter(UP)`); `updateShape` toward `down` returns air when this fails |
| Signal strength | count the entities in the detection box that are not spectators and do not ignore block triggers (`isIgnoringBlockTriggers` false), `n`; `s = min(n, maxWeight)`; the plate's power is `ceil(min(s, maxWeight) / maxWeight * 15)` when `s > 0`, else 0 |
| Pressed delay | `getPressedTime` is 10 ticks for the weighted plates (the base default is 20) |
| Signal | signal source; own signal = `power`; direct signal upward = `power` (`getDirectSignal(UP)`); `checkPressed` updates the state, plays the click on or off sounds from the set type and neighbour updates the block and the block below |
| Sound | applied by the constructor of `BasePressurePlateBlock` (the base class, not `WeightedPressurePlateBlock`), which passes `BlockSetType.soundType` of the type to `Properties.sound`: gold `METAL`, iron `IRON`. Click sounds `METAL_PRESSURE_PLATE_CLICK_ON/OFF` for both |
| Push reaction | `POPPED`; `forceSolidOn` |

### 7.5 Comparator (`ComparatorBlock extends DiodeBlock`)

| Aspect | Rule |
|---|---|
| Properties | `facing` (4), `mode` (compare, subtract), `powered`; default facing north, mode compare, powered false |
| Shape | `column(16,0,2)` = `box(0,0,0)-(16,2,16)` (the `DiodeBlock.SHAPE`); the comparator is not `noCollision`, so the collision shape is this slab |
| Placement | `facing` = opposite of the placer's horizontal direction |
| `canSurvive` | the block below has a rigid-support upper face (`isFaceSturdy(UP, RIGID)`); `updateShape` toward `down` returns air when the support fails |
| Use | with building allowed: toggles `mode` and plays `COMPARATOR_CLICK` (sound source blocks) at volume 0.3 and, judged on the mode **after** the toggle, pitch 0.55 for subtract and 0.5 for compare (constants read in `ComparatorBlock.useWithoutItem`); then refreshes the output |
| Redstone | delay 2 ticks (`getDelay` returns 2, read); the input signal, the side signals, the output signal stored in the block entity (`ComparatorBlockEntity`) and the tick priority rules are RS12 (30-redstone) and RS13. Registry-visible parts: `hasAnalogOutputSignal` is not used; the input signal reads a container or analog block behind it, or a conductive block behind it with an item frame holding an item (`ItemFrame.getAnalogOutput`) |

### 7.6 Daylight detector (`DaylightDetectorBlock`, with `inverted`)

| Aspect | Rule |
|---|---|
| Properties | `inverted` and `power` (0 to 15); default `power` 0, `inverted` false |
| Shape | `column(16,0,6)` = `box(0,0,0)-(16,6,16)`; `useShapeForLightOcclusion` true |
| Signal | signal source; own signal = `power` |
| Use | with building allowed, on the server: cycles `inverted`, writes it with flag 2, plays a block change game event, and recomputes the power immediately. A player who cannot build gets the default behaviour (block entity use) |
| Ticker | `getTicker` returns a ticker only when the level is on the server and the dimension has sky light; the ticker is the private static `DaylightDetectorBlock.tickEntity` (the class `DaylightDetectorBlockEntity` has only a constructor), which, when `gameTime % 20 == 0`, calls `updateSignalStrength` |
| Power formula | let `s` = `Level.getEffectiveSkyBrightness(pos)` (0 to 15). If `inverted`: `s = 15 - s`. Otherwise, when `s > 0`: let `a` be the sun angle in radians from the environment attribute `SUN_ANGLE` (the attribute value, in degrees, times 0.017453292); the target angle is 0 when `a < pi` and `2*pi` otherwise; `a = a + (target - a) * 0.2`; `s = round(s * cos(a))`. In both cases `s` is clamped to 0 to 15. The state is rewritten (with `setBlockAndUpdate`) only when it changes. (The whole method `DaylightDetectorBlock.updateSignalStrength` was re-read: constants 0.017453292, pi, 2 pi, 0.2, the order of operations, `Math.round` and the clamp 0 to 15. Only the unit of the attribute, degrees, is (inferred) from the conversion constant: Open question 7.) |

### 7.7 Redstone block (`PoweredBlock`), nether quartz ore (`DropExperienceBlock`)

`PoweredBlock`: signal source, own signal 15, in every direction; `isRedstoneConductor` is false (note 6 of section 4).
`DropExperienceBlock` with the experience range `UniformInt.of(2, 5)` (constructor argument): after the block is broken
with drops enabled, `tryDropExperience` drops an experience amount uniformly from 2 to 5 inclusive (the experience-drop
engine is the loot and experience documents).

### 7.8 Hopper (`HopperBlock`)

| Aspect | Rule |
|---|---|
| Properties | `enabled` (true, false), `facing` (down, north, south, west, east); default `facing` down, `enabled` true |
| Placement | `facing` = the opposite of the clicked face when that face is horizontal; for a vertical clicked face `facing` is down. `enabled` is true (the neighbour update of `onPlace` then sets it from the power state) |
| Power | `onPlace` (when not replacing another hopper) and `neighborChanged` set `enabled = not hasNeighborSignal` with flag 2 |
| Shape (collision and outline) | `body` = union(`column(16,10,16)` = `box(0,10,0)-(16,16,16)`, `column(8,4,10)` = `box(4,4,4)-(12,10,12)`) minus `cavity` = `column(12,11,16)` = `box(2,11,2)-(14,16,14)`. The spout for facing d is `boxZ(4,4,8,0,8)` = `box(6,4,0)-(10,8,8)` (north), rotated about the centre (8, 6, 8) by `rotateAll` and intersected with the unit block. Shape(state) = body union spout(facing). Spout entries: north `(6,4,0)-(10,8,8)`, east `(8,4,6)-(16,8,10)`, south `(6,4,8)-(10,8,16)`, west `(0,4,6)-(8,8,10)`, down `(6,0,6)-(10,6,10)` (the down entry is the rotated box clipped by the block bound; derived by hand from the rotation: Open question 8). The shape table is built with `getShapeForEachState` over `enabled`, so it does not depend on `enabled` |
| Interaction shape (`getInteractionShape`, used for hopper-item suction and menus) | `cavity` for facing down; for a horizontal facing, `cavity` union `boxZ(4,8,10,0,4)` = `box(6,8,0)-(10,10,4)` rotated horizontally: north `(6,8,0)-(10,10,4)`, east `(12,8,6)-(16,10,10)`, south `(6,8,12)-(10,10,16)`, west `(0,8,6)-(4,10,10)` |
| Use | on the server, a hopper block entity opens its menu and awards the stat "inspect hopper" |
| Block entity | `HopperBlockEntity` and ticker on the server only (RS13: transfer cooldown and item pulling); `entityInside` forwards to the block entity; `affectNeighborsAfterRemoval` drops the contents; analog output = container fullness; `hasAnalogOutputSignal` true |
| Other | `rotate` and `mirror` on `facing`; not pathfindable |

### 7.9 Quartz family, smooth blocks, prismarine, red sandstone, coal block, terracotta, hay, packed ice

All are full cubes with the default state, except:

| Block | Class and rule |
|---|---|
| `quartz_pillar` | `RotatedPillarBlock`: `axis` default y; placement `axis` = axis of the clicked face; `rotate` swaps x and z for 90 and 270 degree rotations (y unchanged) |
| `hay_block` | `HayBlock extends RotatedPillarBlock`: same axis rules; `fallOn` calls `Entity.causeFallDamage(distance, 0.2, fall source)` directly (`HayBlock.fallOn`, float 0.2 read): the fall distance is passed unchanged and the **damage multiplier is 0.2** (the `Block` default is described below) |
| `slime_block` | `SlimeBlock extends HalfTransparentBlock`: `fallOn`: when the entity is not suppressing the bounce (`isSuppressingBounce`, the sneaking state), fall damage is applied with a multiplier 0 (no damage; `SlimeBlock.fallOn`, read); when it is suppressing, the method returns without calling anything. `stepOn`: when `|vy| < 0.1` and the entity is not stepping carefully, the entity's horizontal velocity is multiplied by `0.4 + |vy| * 0.2` (`SlimeBlock.stepOn`, constants 0.1, 0.4, 0.2 read) (and vertical velocity by 1). Bounce restitution 1.0 (note 8). Friction 0.8 |
| `Block.fallOn` default (all other rows) | calls `Entity.causeFallDamage(distance x (1 - fallDistanceReduction), 1.0, fall source)` (read: the distance is multiplied by one minus the reduction; the multiplier argument is 1.0); no row of this part sets `fallDistanceReduction` |
| `quartz_block`, `chiseled_quartz_block`, `smooth_quartz`, `terracotta`, `coal_block`, `packed_ice`, `prismarine`, `prismarine_bricks`, `dark_prismarine`, `sea_lantern`, red sandstone blocks, `smooth_*` | class `Block`: no state, full cube, default placement. `sea_lantern` emits light 15, instrument `HAT`, sound `GLASS`; `packed_ice` has instrument `CHIME`, sound `GLASS`, friction 0.98 |

### 7.10 Stairs (`StairBlock`)

Every stair row of this part (fields 445, 450 to 457, 465 to 467, 488) is a `StairBlock` made by `registerLegacyStair` (the legacy copy of note 3 of section 4); `registerStair` (full copy) is not used for any row here. The constructor takes the base block's default state (the base is stored; `getExplosionResistance`
returns the base's).

| Aspect | Rule |
|---|---|
| Properties | `facing`, `half`, `shape`, `waterlogged` (sorted order); default facing north, half bottom, shape straight, waterlogged false (default index 11 of 80) |
| Shape pieces (bottom, facing north) | `OUTER` = `box(0,0,0)-(16,8,16)` union `box(0,8,0)-(8,16,8)` (the slab plus the north-west top quarter). `STRAIGHT` = OUTER union OUTER rotated 90 degrees (the slab plus the north half). `INNER` = STRAIGHT union STRAIGHT rotated 90 degrees (the slab plus the north half plus the east half: three top quarters, north-west, north-east, south-east). The tables of the 4 facings are `rotateHorizontal` of each piece. The top-half tables are the pieces mirrored with `OctahedralGroup.INVERT_Y` (flipped upside down about the block centre) and then rotated horizontally |
| Shape lookup | pick the table by `half` and `shape`: `straight` uses STRAIGHT, `inner_left` and `inner_right` use INNER, `outer_left` and `outer_right` use OUTER. The key direction is `facing`, except for `inner_left` (counter-clockwise of `facing`) and `outer_right` (clockwise of `facing`): `straight`, `outer_left` and `inner_right` use `facing` itself. (The `StairBlock$1` switch map assigns 1 straight, 2 outer_left, 3 inner_right, 4 inner_left, 5 outer_right; read.) Worked check for facing north: OUTER_LEFT = NW quarter; OUTER_RIGHT = rotate clockwise = NE quarter; INNER_RIGHT = NW, NE, SE; INNER_LEFT = rotate counter-clockwise = SW, NW, NE |
| `useShapeForLightOcclusion` | true |
| Placement | `facing` = placer's horizontal direction; `half` = top when the clicked face is down, bottom when up, otherwise top when the click point's fractional y above the block's y exceeds 0.5 (strictly greater), else bottom; `waterlogged` = fluid at the position is water; `shape` = `getStairsShape` below |
| `getStairsShape(state, level, pos)` | let f = `facing`. (1) Take the block at `pos.relative(f)`. If it is a stair of the same `half` whose facing axis differs from f's axis, and `canTakeShape(state, level, pos, thatFacing.opposite)`, then the result is `outer_left` when thatFacing equals f's counter-clockwise direction, else `outer_right`. (2) Otherwise take the block at `pos.relative(f.opposite)`. If it is a stair of the same `half` with a different axis and `canTakeShape(state, level, pos, thatFacing)`, the result is `inner_left` when thatFacing equals f's counter-clockwise direction, else `inner_right`. (3) Otherwise `straight`. `canTakeShape(state, level, pos, dir)` is false exactly when the block at `pos.relative(dir)` is a stair with the same `facing` and the same `half` as `state`; true otherwise. `isStairs` tests the block class. |
| `updateShape` | schedules a water tick when waterlogged; when the changed neighbour direction is horizontal the `shape` is recomputed with `getStairsShape`; otherwise the default |
| `rotate` / `mirror` | `rotate` rotates `facing`. `mirror` (read in `StairBlock.mirror`, with the `Mirror` and `StairsShape` switch maps): mirror `LEFT_RIGHT` acts only when `facing` is on axis Z (north, south); mirror `FRONT_BACK` only when `facing` is on axis X (east, west). In both acting cases the state is first rotated 180 degrees (so `facing` flips) and then the shape is replaced as in the table below; in every other case `Block.mirror` runs (the plain mirror by `Mirror.getRotation(facing)`: 180 degrees when the mirror's axis matches, else none; `Mirror.getRotation` read, the `Block.mirror` body itself is (inferred) to apply that rotation). |
| Pathfinding | not pathfindable |

Stair `mirror` shape table (after the 180 degree rotation of `facing`):

| shape before | `LEFT_RIGHT` with facing on axis Z | `FRONT_BACK` with facing on axis X |
|---|---|---|
| straight | straight | straight |
| outer_left | outer_right | outer_right |
| outer_right | outer_left | outer_left |
| inner_left | inner_right | inner_left (unchanged) |
| inner_right | inner_left | inner_right (unchanged) |

The two columns differ for the inner shapes only. All ten entries were read from the bytecode of `StairBlock.mirror`.

### 7.11 Slabs (`SlabBlock`)

| Aspect | Rule |
|---|---|
| Properties | `type` (top, bottom, double), `waterlogged`; default type bottom, not waterlogged (default index 3 of 6) |
| Shapes | bottom `column(16,0,8)` = `box(0,0,0)-(16,8,16)`; top `column(16,8,16)` = `box(0,8,0)-(16,16,16)`; double: the full block |
| `useShapeForLightOcclusion` | true unless `type` is double |
| Placement | if the block at the position is already this slab: `type` double, `waterlogged` false. Otherwise `type` bottom with `waterlogged` from the fluid; then `type` top when the clicked face is down, stays bottom when it is up, otherwise top when the click point's fractional y exceeds 0.5 |
| `canBeReplaced(context)` (turning a slab into a double) | false unless the held item is this slab's item and `type` is not double; if the context is replacing the clicked block (`replacingClickedOnBlock`): for a bottom slab, true when the clicked face is up or when the click is in the upper half of the block and the face is horizontal; for a top slab, true when the face is down or when the click is in the lower half and the face is horizontal (`upper` = click y minus block y > 0.5); when it is not replacing the clicked block, a single return of true. (All returns of `SlabBlock.canBeReplaced` were re-read: the item test with the double test first, then the two face-and-half cases, and the single `true` when the placement is not replacing the clicked block; none is inferred.) |
| Fluid | `placeLiquid` and `canPlaceLiquid` are refused when `type` is double; otherwise the `SimpleWaterloggedBlock` rules; the water source state when waterlogged |
| Pathfinding | `isPathfindable`: land false; water true when the fluid state is in the fluid tag `water`; air false (`PathComputationType` constants LAND, WATER, AIR, switch map and the three results read) |

### 7.12 Activator rail (`PoweredRailBlock extends BaseRailBlock`; `isStraight` true)

| Aspect | Rule |
|---|---|
| Properties | `powered`, `shape` (six straight shapes), `waterlogged`; default shape north_south, not powered, not waterlogged (default index 13 of 24: sorted order `powered` (stride 12), `shape` (stride 2), `waterlogged` (stride 1): `powered` false is index 1, `shape` north_south index 0, `waterlogged` false index 1, so 12 + 0 + 1 = 13) |
| Shape | flat `column(16,0,2)` = `box(0,0,0)-(16,2,16)`; sloped (the shape property `isSlope`: the four ascending shapes) `column(16,0,8)` = `box(0,0,0)-(16,8,16)`. `noCollision`: collision empty |
| Placement | shape = `east_west` when the placer's horizontal direction is east or west, else `north_south`; `waterlogged` from the fluid |
| `canSurvive` | the block below can support a rigid block on its upper face (`canSupportRigidBlock`); the neighbour check removes the rail when an ascending side loses its support (the support position for ascending_east is east, west, north, south respectively) |
| Neighbour and power | `onPlace`, `neighborChanged`, power propagation up to 8 rails along the line (depth limit 8 in `findPoweredRailSignal`) and the rail connection state machine (`RailState`) are RS12 and RS9 |
| `rotate` / `mirror` | per `RailShape` tables |

### 7.13 Dropper (`DropperBlock extends DispenserBlock`)

| Aspect | Rule |
|---|---|
| Properties | `facing` (6 directions), `triggered`; default facing north, triggered false (default index 1 of 12: sorted order `facing` (stride 2), `triggered` (stride 1); north is index 0, `triggered` false is index 1) |
| Shape | full cube |
| Placement | `facing` = opposite of the nearest looking direction (`getNearestLookingDirection().getOpposite()`) |
| Redstone | `neighborChanged`: powered when the block or the block above receives a signal; on a rising edge with `triggered` false, schedules a tick in 4 game ticks (constant 4 read in `DispenserBlock.neighborChanged`, inherited by the dropper) and sets `triggered` true; on a falling edge sets it false; the tick calls `dispenseFrom` |
| `dispenseFrom` (dropper) | the block entity `DropperBlockEntity` must exist; a random non-empty slot is chosen (`getRandomSlot`); none: level event 1001 (empty click). With the container at `pos.relative(facing)` (`HopperBlockEntity.getContainerAt`) absent: the default dispense behaviour drops the stack. With a container: one item (`copyWithCount(1)`) is inserted from the opposite side (`HopperBlockEntity.addItem`, side = facing's opposite); on full insertion the source stack shrinks by 1, otherwise it is restored |
| Other | menu opens on use ("inspect dropper" stat); analog output = container fullness; `rotate`/`mirror` on `facing` |

### 7.14 Stained glass pane (`StainedGlassPaneBlock extends IronBarsBlock`)

| Aspect | Rule |
|---|---|
| Properties | `east`, `north`, `south`, `waterlogged`, `west` (sorted); all false by default (default index 31 of 32) |
| Shapes | post `column(2,0,16)` = `box(7,0,7)-(9,16,9)`; arm for north `boxZ(2,0,16,0,8)` = `box(7,0,0)-(9,16,8)`, east `(8,0,7)-(16,16,9)`, south `(7,0,8)-(9,16,16)`, west `(0,0,7)-(8,16,9)`. Shape = post union the arms of the sides whose property is true. Collision and outline shapes are the same (the constructor passes the same numbers 2, 16, 2, 16, 16 for both). The visual shape is empty (`getVisualShape`) |
| Placement | each side property = `attachsTo(neighbour state, isFaceSturdy(neighbour, level, neighbourPos, opposite face))` for the neighbour in that direction (north uses the block at `pos.north()` and its south face, east uses `pos.east()` and its west face, and so on); `waterlogged` from the fluid |
| `attachsTo(state, sturdy)` | true when (`not Block.isExceptionForConnection(state)` and the face is sturdy), or the neighbour block is an `IronBarsBlock`, or the neighbour is in the block tag `walls`. `isExceptionForConnection` is true for leaves, barrier, carved pumpkin, jack o'lantern, melon, pumpkin and the tag `shulker_boxes` (the first test is `instanceof LeavesBlock`, read as the leaves class) |
| `updateShape` | when the direction is horizontal the matching side property is recomputed from the changed neighbour with the same rule; waterlogging schedules a water tick |
| `rotate` / `mirror` | the four side properties are permuted with the facing rotation (180: north with south, east with west; clockwise 90: north takes west's value, east takes north's, south east's, west south's); mirror swaps the pairs |
| Other | `propagatesSkylightDown` is true when not waterlogged; not pathfindable; `skipRendering` hides inner faces against other panes or bars with connected sides; implements `BeaconBeamBlock` (the dye colour tints beacon beams) |

Block and item tags read by classes of this part (by name; members are data): `walls` (`FenceGateBlock`, `IronBarsBlock`), `bars` (`IronBarsBlock`), `rails` (`BaseRailBlock`), `supports_vegetation` (`VegetationBlock`), `fire` (`FallingBlock.isFree`), `shulker_boxes` (`isExceptionForConnection`); item tag `sulfur_cube_swallowable` (`DispenserBlock`; the dropper section does not describe it, and its use is Open question 16). Mineable and needs-tool tag names per row are part 1's.

### 7.14a Light opacity, occlusion shape and skylight

Rules read from `BlockBehaviour$BlockStateBase.initCache`, `BlockBehaviour.getLightDampening`, `getOcclusionShape` and `propagatesSkylightDown`:

1. The occlusion shape of a state is its outline shape evaluated with an empty block getter at the origin, when the block can occlude (`canOcclude`, default true; `noOcclusion` and `noCollision` both clear it), and the empty shape otherwise. Only `FenceGateBlock` overrides the occlusion shape (section 7.18).
2. `solidRender` is true when the occlusion shape is a full block.
3. Light dampening per state: 15 when `solidRender`; otherwise 0 when `propagatesSkylightDown`; otherwise 1.
4. Default `propagatesSkylightDown`: the outline shape is not a full block and the fluid state is empty. `BarrierBlock` and `LightBlock` override it to "the fluid state is empty" (read), so a full-cube collision does not matter for them.
5. `useShapeForLightOcclusion` is true for stairs, slabs that are not double, and the daylight detector (read: the three overrides); false elsewhere.

Resulting dampening for this part (derived by rules 1 to 4 from the shapes of section 7):

| Rows | Dampening |
|---|---|
| Full cubes that can occlude: quartz block, chiseled quartz, quartz pillar, smooth quartz, redstone block, nether quartz ore, dropper, terracotta and the 16 dyed terracotta, three prismarine blocks, coal block, packed ice, hay block, three red sandstone blocks, smooth stone, smooth sandstone, smooth red sandstone, sea lantern; any slab state with `type=double` | 15 |
| `slime_block` (full cube but `noOcclusion`, so `solidRender` false; shape full, so no skylight propagation) | 1 |
| `barrier`, `light` | 0 when not waterlogged, 1 when waterlogged |
| Stairs, non-double slabs, stained glass panes, trapped chest, iron trapdoor (waterlogged ones); also hopper (no `waterlogged` property) | 0 when the fluid state is empty, 1 when waterlogged (hopper always 0) |
| Heads and wall heads, anvils, weighted plates, comparator, daylight detector, activator rail, carpets, banners, wall banners, tall plants, fence gates (none has `waterlogged`) | 0 |

`DoublePlantBlock extends VegetationBlock` and `TallFlowerBlock extends DoublePlantBlock` (read). `propagatesSkylightDown` on panes follows rule 4 (no override), so it is true when not waterlogged; earlier text that listed it as a class property is the result of that rule.

The per-face occlusion shape column is the projection of the occlusion shape onto each face (`getFaceShape`); full cubes use the shared full-face table and empty shapes the shared empty table (read in `initCache`).

### 7.14b Friction, speed, jump, loot table, tool tags

| Column | Rule for fields 420 to 524 |
|---|---|
| Friction | 0.6 default; `slime_block` 0.8; `packed_ice` 0.98. Stairs and slabs copy the base's friction (all defaults here) |
| Speed factor, jump factor | 1.0 and 1.0 for every row: the `speedFactor` and `jumpFactor` calls of the `Blocks` initialiser belong to soul sand and honey block, outside this part |
| Loot table key | Properties default: the resource key `loot_table` with the block's identifier prefixed by `blocks/` (namespace kept), i.e. `minecraft:blocks/<key>`; read in `Properties` (`lambda$new$2`). Exceptions: `barrier` and `light` (`noLootTable`, empty); the wall skull, wall head and wall banner rows (`overrideLoot` to the floor or standing block's table). Description id: `block.<namespace>.<path>`, or the overridden block's for wall variants |
| Tool tags (block tags read as data: `mineable/pickaxe`, `mineable/axe`, `mineable/shovel`, `mineable/hoe`, `needs_stone_tool`, `needs_iron_tool`, `needs_diamond_tool`, with nested tag references resolved) | `mineable/pickaxe` (64 blocks): anvils, both weighted plates, redstone block, nether quartz ore, hopper, quartz block, chiseled quartz, quartz pillar, quartz stairs, activator rail, dropper, the 16 dyed terracotta, iron trapdoor, the three prismarine blocks with their stairs and slabs, terracotta, coal block, packed ice, three red sandstone blocks and the red sandstone stairs, and all stone-type slabs (stone, sandstone, cut sandstone, petrified oak, cobblestone, brick, stone brick, mud brick, nether brick, quartz, red sandstone, cut red sandstone, smooth stone) plus smooth stone, smooth sandstone, smooth quartz, smooth red sandstone. `mineable/axe` (61): trapped chest, daylight detector, the eight wood stairs here, the 12 wood and bamboo slabs, the 16 banners, the 16 wall banners, the seven fence gates. `mineable/hoe` (1): hay block. `mineable/shovel`: none. Not in any mineable tag (54): all 11 heads, comparator, the 16 panes, slime block, barrier, light, sea lantern, the 16 carpets, the six tall plants. None of the 180 blocks is in a `needs_*_tool` tag. The "tool req." column is the separate code flag `requiresCorrectToolForDrops` of the row table; a row can have the flag without being in a needs tag (the flag then requires any tool in the mineable tag that applies) |

### 7.15 Barrier and light block

| Block | Rule |
|---|---|
| `barrier` (`BarrierBlock`) | Property `waterlogged` (default false). Shape: full cube (collision and outline default). `getRenderShape` is `INVISIBLE`; `getShadeBrightness` 1.0; `propagatesSkylightDown` when the fluid state is empty. `pickupBlock` and `canPlaceLiquid` are refused for players not in creative mode (a creative player may take the water). Placement: waterlogged from the fluid. `isValidSpawn` never |
| `light` (`LightBlock`) | Properties `level` (0 to 15, default 15), `waterlogged`. Light emission = `level`. Shape: the full cube when the entity holds the light item (`CollisionContext.isHoldingItem(LIGHT)`), else the empty shape; the block has no collision (`getShape` returns an empty shape for the collision query because the context holds nothing; the collision shape is evaluated without a context and is empty). Invisible render. Use: when the player may use game master blocks, on the server, cycles `level` (wrapping) and returns server success; otherwise consume. The clone item carries the level in `BLOCK_STATE` item data. Replaceable flag set. Not droppable (`noLootTable`) |

### 7.16 Iron trapdoor (`TrapDoorBlock`, set type `IRON`)

| Aspect | Rule |
|---|---|
| Properties | `facing` (4), `half`, `open`, `powered`, `waterlogged` (sorted order: facing, half, open, powered, waterlogged); default north, bottom, closed, unpowered, dry (default index 15 of 64: strides 16, 8, 4, 2, 1 give 0 + 8 + 4 + 2 + 1) |
| Shape | the north entry of the table is `boxZ(16,13,16)` = `box(0,0,13)-(16,16,16)`, rotated by `rotateAll`: north `(0,0,13)-(16,16,16)`, east `(0,0,0)-(3,16,16)`, south `(0,0,0)-(16,16,3)`, west `(13,0,0)-(16,16,16)`, down `(0,13,0)-(16,16,16)`, up `(0,0,0)-(16,3,16)`. Lookup: when `open`, key = `facing`; when closed, key = `down` for `half` top and `up` for `half` bottom |
| Placement | when the clicked face is horizontal and the placement is not replacing the clicked block: `facing` = the clicked face, `half` = top when the click's fractional y exceeds 0.5, else bottom. Otherwise: `facing` = opposite of the placer's horizontal direction, `half` = bottom when the clicked face is up, else top. When the position receives a neighbour signal, `open` and `powered` are set true. `waterlogged` from the fluid |
| Use | the iron set type cannot be opened by hand (`canOpenByHand` false, read): use passes. Redstone: `neighborChanged` sets `powered`, and `open` to match the signal, plays the open or close sound (`IRON_TRAPDOOR_OPEN/CLOSE`) and a game event |
| Explosion | wind charge toggling is by the set type (`canOpenByWindCharge`; false for iron) |
| Pathfinding | land: when open; water: when waterlogged; air: when open (read) |
| Properties | `noOcclusion`, `validSpawn:never`, tool required, hardness 5.0 |

### 7.17 Carpet (`WoolCarpetBlock extends CarpetBlock`), tall plants, banners

| Block | Rule |
|---|---|
| carpet | shape `column(16,0,1)` = `box(0,0,0)-(16,1,16)`; `canSurvive` = the block below is not air (`isEmptyBlock` false); `updateShape` returns air when it fails |
| `TallFlowerBlock` (sunflower, lilac, rose bush, peony) and `DoublePlantBlock` (tall grass, large fern) | Property `half` (upper, lower), default lower. No shape override (the outline is the full cube shifted by the XZ offset; collision empty because `noCollision`). `canSurvive`: lower half: the block below is in the block tag `supports_vegetation`; upper half: the block below is the same block with `half` lower. `updateShape`: for the vertical direction: the lower half is removed (state air) when the upper half's support changed and the neighbour above is not this block with `half` upper...; the exact test: when the updated direction is on the Y axis and the half is not consistent with the neighbour (for the lower half looking up, for the upper half looking down) and the neighbour is not this same block with the other half, the block becomes air; the lower half also becomes air when looking down and `canSurvive` fails. Placement: allowed only when the position above is below the world maximum Y and replaceable; the item places the lower half, and `setPlacedBy` places the upper half at `pos.above()` with the upper half state and the waterlogging copied. Offset seed: the XZ offset (section 6.1) always uses `Mth.getSeed(x, 0, z)`, so y is ignored and both halves get the same offset. `DoublePlantBlock.getSeed(state, pos)` is a separate override (x, the y of the lower half, z; the upper half uses `pos.below()`) and is the block-state seed for choosing model variants, not the offset seed. Breaking: in creative or when the tool prevents drops, the lower half is removed without drops and with the break level event (2001); the broken block is replaced by water when the lower half is in water, else air (flag 35) |
| `TallFlowerBlock` extras | bone meal always works as a target and always succeeds; it spawns one item of the block at the position (`popResource`) |
| `BannerBlock` | `rotation` default 8. Shape `column(8,0,16)` = `box(4,0,4)-(12,16,12)`. `canSurvive`: the block below is solid (`isSolid`, 24 part 1 §5.2). `updateShape` toward down returns air when `canSurvive` fails. Placement: `rotation` = `convertToSegment(placer yaw + 180)`. `rotate`/`mirror` through `Rotation.rotate(rotation, 16)`; block entity `BannerBlockEntity` with the dye; `isPossibleToRespawnInThis` true; the clone item is the banner item of the block entity |
| `WallBannerBlock` | `facing`, default north. Shape of facing north `boxZ(16,0,12.5,14,16)` = `box(0,0,14)-(16,12.5,16)`; east `(0,0,0)-(2,12.5,16)`; south `(0,0,0)-(16,12.5,2)`; west `(14,0,0)-(16,12.5,16)`. `canSurvive`: the block at `pos.relative(facing.opposite)` is solid. Placement: over `getNearestLookingDirections()` take the first horizontal direction `d` such that the state with `facing = d.opposite` survives (`canSurvive`), else none |

### 7.18 Fence gates (`FenceGateBlock`, wood type from the constructor)

| Aspect | Rule |
|---|---|
| Properties | `facing` (4), `in_wall`, `open`, `powered` (sorted); default facing north (the first value, never set by the constructor), `in_wall` false, `open` false, `powered` false (default index 7 of 32: strides 8, 4, 2, 1 give 0 + 4 + 2 + 1) |
| Shapes (pixels) | outline, facing axis Z (facing north or south): `cube(16,16,4)` = `box(0,0,6)-(16,16,10)`; axis X: `box(6,0,0)-(10,16,16)`. When `in_wall` is true: the outline minus the top 3 pixels (`join` with `column(16,13,16)`, ONLY_FIRST), that is `box(0,0,6)-(16,13,10)` and `box(6,0,0)-(10,13,16)`. Collision (closed): `column(16,4,0,24)` = `box(0,0,6)-(16,24,10)` for axis Z and `box(6,0,0)-(10,24,16)` for axis X; empty when open. Block support shape: `column(16,4,5,24)` = `box(0,5,6)-(16,24,10)` (axis Z) and `box(6,5,0)-(10,24,16)` (axis X) when closed, empty when open. Occlusion shape: for axis Z the union `box(0,5,7)-(2,16,9)` and `box(14,5,7)-(16,16,9)`; for axis X `box(7,5,0)-(9,16,2)` and `box(7,5,14)-(9,16,16)`; when `in_wall` it is moved down 3 pixels (`box(0,2,7)-(2,13,9)` and so on) |
| Placement | `powered` and `open` both = `hasNeighborSignal` at the position; `facing` = the placer's horizontal direction; `in_wall` = true when the horizontal axis of the facing is Z and the block to the west or the east is in the tag `walls`, or the axis is X and the block to the north or the south is in `walls` |
| `updateShape` | when the changed neighbour's direction axis equals the axis of the clockwise direction of `facing` (the sides of the gate), `in_wall` is recomputed: true when this side's neighbour or the opposite side's is a wall (`isWall` of the changed neighbour state `||` the block on the opposite side). Otherwise the default |
| Use | closing: `open` false (flags 10). Opening: when the player's direction equals the opposite of `facing` the gate's `facing` is set to the player's direction; `open` true (flags 10). Plays the type's open or close sound at volume 1.0 and pitch `random * 0.1 + 0.9`, then the game event block open or close. Sound events: cherry `CHERRY_WOOD_FENCE_GATE_OPEN/CLOSE`, the others `FENCE_GATE_OPEN/CLOSE` |
| Redstone | `neighborChanged` on the server: when `hasNeighborSignal` differs from `powered`, set `powered` and `open` to it (flags 2) and play the sound and game event when `open` changed |
| Explosion | an explosion that can trigger blocks and a gate that is not powered toggles `open` and plays the sound |
| Pathfinding | land and air: when open; water: false (read) |
| Other | `connectsToDirection(state, direction)` is true when the gate's facing axis is perpendicular to the direction's axis (used by fences and walls to connect); the gate has `forceSolidOn`; flags `ignitedByLava` |

## 8. Placement columns (GAP-30) per class

Summary of 24 part 1 §10 for the classes of this part: replaceable flag, `canSurvive`, placement state.

| Class (rows) | Replaceable | `canSurvive` | Placement state |
|---|---|---|---|
| `Block`, `PoweredBlock`, `DropExperienceBlock`, `SlimeBlock`, `HayBlock`... | no (flag unset; only `light`, `tall_grass`, `large_fern` have it) | default true | default state (`hay_block` and `quartz_pillar`: axis of the clicked face) |
| `light` (flag set) | yes | default true | default state (level 15) |
| `tall_grass`, `large_fern` (flag set) | yes | section 7.17 | lower half; the upper half added by `setPlacedBy` |
| Skulls and heads | no | default true | section 7.1 |
| Wall banners, banners | no | solid support | section 7.17 |
| Weighted plates, comparator, activator rail, carpet | no | support below | section 7.4, 7.5, 7.12, 7.17 |
| Stairs, slabs | no (a slab is replaceable by the same item through `canBeReplaced(context)`) | default true | sections 7.10, 7.11 |
| Hopper, dropper, anvil, chest | no | default true | sections 7.8, 7.13, 7.2, 7.3 |
| Trapdoor, fence gate, pane | no | default true | sections 7.16, 7.18, 7.14 |
| Barrier | no | default true | waterlogged from the fluid |

The default replaceable behaviour `canBeReplaced(context)` (flag set and the held item is not this block's item) is in
24 part 1 §5.2; the slab overrides it as described in section 7.11.

## 9. Tint class (GAP-29) for this range

Of the 105 fields only `TALL_GRASS` (field 481) and `LARGE_FERN` (field 482) are registered in
`BlockColors.createDefault`, both with `BlockTintSources.doubleTallGrass()` (a single source, index 0). Its in-hand
colour is the default grass colour (`GrassColor.getDefaultColor()`), its in-world colour is the average grass colour
(`BiomeColors.getAverageGrassColor`) at the position, moved one block down when the block's `half` is `upper`, so that both
halves share one colour; it depends on the property `half`. The colour of a block is then applied to tinted faces of the
model by tint index 0. Sunflower, lilac, rose bush and peony are not registered (untinted). No other block of this range
is tinted: the tint column is "none" for every other row of section 3 and every per-colour row of section 5 (the stained glass pane dye colour tints beacon beams through `BeaconBeamBlock`, which is not a block tint source). See 24 part 1 §9.1 and §9.3.

## 10. Worked examples

1. **Ids.** `anvil` is field 431: id = 509 + 11 = 520; `quartz_stairs` field 445 id 534; `sea_lantern` field 471 id 590;
   `white_carpet` id 592, `black_carpet` id 607; `banner` colours 617 to 632, `wall_banner` colours 633 to 648;
   `pale_oak_fence_gate` id 688.
2. **State ids.** `hopper` (field 441): offset 326 in this part, so first state id 12754 + 326 = 13080, 10 states. The
   properties sorted are `enabled` (true first) and `facing` (down, north, south, west, east). The state `enabled=true,
   facing=down` is index 0 x 5 + 0 = 0: this is the default state, id 13080. `enabled=false, facing=east` is index 1 x 5 + 4 = 9,
   id 13089. `quartz_stairs` (80 states, first 13095): sorted properties `facing` (4), `half` (2), `shape` (5), `waterlogged` (2), with strides
   20, 10, 2 and 1. The default `facing=north, half=bottom, shape=straight, waterlogged=false` is
   0 x 20 + 1 x 10 + 0 x 2 + 1 x 1 = 11 (`half` values are top then bottom, so bottom is index 1; `straight` is index 0;
   `waterlogged` false is index 1). Default id 13095 + 11 = 13106.
3. **Fence gate states.** `spruce_fence_gate`, offset 2577: first state id 12754 + 2577 = 15331. Sorted properties:
   `facing` (4, stride 8), `in_wall` (stride 4), `open` (stride 2), `powered` (stride 1). Default `facing=north, in_wall=false,
   open=false, powered=false`: 0 x 8 + 1 x 4 + 1 x 2 + 1 x 1 = 7, id 15338.
4. **Stair shape.** A stair at the origin facing north (bottom half) with a stair to its north facing east, same half: the
   front neighbour is a stair, same half, its facing axis (X) differs from the stair's (Z); `canTakeShape(state, level, pos,
   neighbour.facing.opposite = west)`: the block to the west is not a stair with the same facing, so it is true; the neighbour's
   facing east is not the counter-clockwise direction of north (west), so the result is `outer_right`: shape = OUTER rotated
   clockwise = slab plus the north-east top quarter `box(8,8,0)-(16,16,8)`.
5. **Slab placement.** Clicking the side of a block at a click height of 0.7 above the cell bottom with a slab: the face is
   horizontal and the fractional y is 0.7 > 0.5, so `type=top`; the box is `(0,8,0)-(16,16,16)`. Clicking the upper face
   of a bottom slab of the same kind: `canBeReplaced` is true (face up), the placement state becomes `type=double`.
6. **Daylight detector.** `s = 15`, not inverted, sun angle (degrees converted to radians) 1.0 radian (less than pi): the
   target is 0, `a = 1.0 + (0 - 1.0) x 0.2 = 0.8`, `s = round(15 x cos(0.8)) = round(15 x 0.6967) = round(10.45) = 10`. Inverted
   with the same sky brightness 15: `s = 15 - 15 = 0`, power 0.
7. **Weighted plate.** Heavy plate (150), 3 entities: `s = 3`, power `ceil(3 / 150 x 15) = ceil(0.3) = 1`. Light plate (15), 3
   entities: `ceil(3 / 15 x 15) = 3`. Light plate with 20 entities: `s = min(20, 15) = 15`, power 15.
8. **Wall head.** A zombie wall head facing north occupies `(4,4,8)-(12,12,16)`; facing east `(0,4,4)-(8,12,12)`. Check by the
   rotation formula: north box X 4..12, Z 8..16 rotated 90 degrees gives X `16-16..16-8 = 0..8`, Z `4..12` ✓.
9. **Offset.** Tall grass at x=0, z=0: `seed = Mth.getSeed(0,0,0)`: `l = 0 XOR 0 XOR 0 = 0`, `l*l*42317861 + l*11 = 0`, seed 0.
   `dx = clamp((0/15 - 0.5) x 0.5, -0.25, 0.25) = -0.25`, `dz = -0.25`: the plant is shifted 4 pixels toward north-west.

## 11. Validation

| Check | Result |
|---|---|
| Field count | 105 fields (420 to 524 inclusive) |
| Registered blocks | 180 = 105 + 5 collections x 15; ids 509 to 688 |
| State total | 2801, the sum over the 180 blocks of the per-block state count. By class (blocks x states, collections counted per block): `WitherWallSkullBlock` 8; `SkullBlock` 4 x 32 = 128 (zombie, creeper, dragon, piglin); `PlayerHeadBlock` 32; `WallSkullBlock` 3 x 8 = 24; `PlayerWallHeadBlock` 8; `PiglinWallSkullBlock` 8; `AnvilBlock` 3 x 4 = 12; `TrappedChestBlock` 24; `WeightedPressurePlateBlock` 2 x 16 = 32; `ComparatorBlock` 16; `DaylightDetectorBlock` 32; `PoweredBlock` 1; `DropExperienceBlock` 1; `HopperBlock` 10; plain `Block` 32 (quartz block, chiseled quartz, 16 terracotta, 3 prismarine, sea lantern, terracotta, coal block, packed ice, 3 red sandstone, 4 smooth blocks); `RotatedPillarBlock` 3; `StairBlock` 13 x 80 = 1040; `PoweredRailBlock` 24; `DropperBlock` 12; `StainedGlassPaneBlock` 16 x 32 = 512; `SlimeBlock` 1; `BarrierBlock` 2; `LightBlock` 32; `TrapDoorBlock` 64; `SlabBlock` 28 x 6 = 168; `HayBlock` 3; `WoolCarpetBlock` 16; `TallFlowerBlock` 4 x 2 = 8; `DoublePlantBlock` 2 x 2 = 4; `BannerBlock` 16 x 16 = 256; `WallBannerBlock` 16 x 4 = 64; `FenceGateBlock` 7 x 32 = 224. The class totals add to 2801 (checked by program) |
| Last block | `pale_oak_fence_gate`: id 688, first state 15523, 32 states, last state id 15554; `mangrove_fence_gate` follows at id 689, state 15555 (matches part 8) |
| Cross-check of the method | the same program, run over fields 0 to 104, gives 575 for the state sum, the value part 1 states for block 105 (24 part 1 §3); it gives 509 registry ids before field 420 by the collection rule of 24 part 1 §2.3 |
| Consistency checks per row | the "properties" counts multiply to "states" for every row (checked by program); default ids lie within the range; no row's default is outside its block's range |
| Collection expansions | five 16-block runs: terracotta 537 to 552, panes 553 to 568, carpet 592 to 607, banner 617 to 632, wall banner 633 to 648 |
| Shape reading | the helper definitions of section 6 were read from `Block.column`, `Block.cube`, `Block.boxZ` and `Shapes.rotate*`; every pixel box of section 7 was recomputed from the arguments of the `static {}` initialisers by those helpers |
| Test suggestions | state-id of every block by the formula 04 §5.2; shape of stairs for all 5 shapes x 4 facings x 2 halves against the piece table of 7.10; fence gate placement next to a wall; slab merge; wall banner `canSurvive`; carpet over air; daylight detector power for each of s = 0 to 15 with and without `inverted`; trapdoor shape for every open, half and facing combination |

## 12. Open questions

1. (Closed.) The absolute state base is 12754, from part 8's whole-registry table; ids and counts agree with part 8 for all 105 rows. Part 4 needs its `command_block` count corrected to 12 states (the artifact's class has `facing` and `conditional`); that is outside this document.
2. The `WeatheringCopperCollection` count (8 blocks per field: four weathering and four waxed states) was read from the collection record; the order of the eight within the field is for the part that covers field 317 and 319.
3. The sound of the wood types without an explicit sound (spruce, birch, jungle, acacia, dark oak, pale oak) is the default of the two-argument `WoodType` constructor (`SoundType.WOOD`, read). The sound **events** of the gate (open and close) for those types are `FENCE_GATE_OPEN` and `FENCE_GATE_CLOSE` (read in the same constructor); the sound event ids belong to the sound registry (46).
4. The entity-level rule for bounce restitution (how the velocity is reversed and scaled in `Entity` movement) was only partly traced: the block value and the 0.8 factor for non-living entities were read in `getBlockBounciness`; the motion rule belongs to the entity movement and item entity physics documents (41 for ground items).
5. (Closed.) `getNearestLookingDirections` and the wall skull test position were read (section 7.1): `Direction.orderedByNearest`, then the `replaceClicked` flag decides whether the opposite of the clicked face is moved to the front; the wall skull tests `canBeReplaced(context)` at `pos.relative(d)`. The wall banner scan was not re-read in this pass; its text in 7.17 stands as an earlier reading.
6. (Closed.) The chest placement of 7.3 was re-read in full in `ChestBlock.getStateForPlacement`, `getChestType` and `candidatePartnerFacing`, including the RIGHT-versus-LEFT choice of the click branch (RIGHT when the partner's counter-clockwise direction equals the opposite of the clicked face).
7. The daylight detector's sun angle: the attribute `SUN_ANGLE` value is multiplied by 0.017453292; the unit of the attribute (degrees) is (inferred) from the conversion constant. The environment attribute documents (33) should state the unit. Everything else in the formula was read.
8. The hopper "down" spout entry is derived by hand from the rotation of the north spout about (8, 6, 8) by 90 degrees about the X axis and clipping to the block; it was not evaluated by the artifact.
9. (Closed.) The slab `canBeReplaced(context)` was re-read; every return is read, none is inferred.
10. `isPathfindable` was read for slab, stairs, anvil, hopper, skulls (all constant false except the slab's water case), fence gate, trapdoor, chest (false), `VegetationBlock` (air: true when the block has no collision, otherwise the default) and the `BlockBehaviour` default (land and air: the collision shape is not a full block; water: fluid in tag `water`). Not individually read: whether the plate, rail, diode, banner, pane and carpet classes inherit the default (a search of the class files found no override in them, so they do); pathfinding itself is the mob navigation document (18).
11. (Closed.) The stair `mirror` tables were read (section 7.10). The remaining (inferred) piece is the body of `Block.mirror`.
12. The sound events and particle effects of the weighted plates, the comparator and the dropper (event ids 1001, 1029, 1031) are named, not tabulated: level events belong to the packet documents (05a, `LevelEvent`). The values 1029 and 1031 were read in `AnvilBlock`.
13. (Closed.) `isExceptionForConnection` starts with `instanceof LeavesBlock`, confirmed.
14. The default `fallOn` multiplication `d * (1 - fallDistanceReduction)` was read from the instruction order; no row of this part sets `fallDistanceReduction`.
15. Mob head and skull block entities (`SkullBlockEntity`: profile resolution, note block sound, animation state), banner patterns, hopper transfer, comparator output, dropper `DispenseItemBehavior` registry: RS13 and RS12.
16. `DispenserBlock` reads the item tag `sulfur_cube_swallowable`; what it does in the dispense path was not traced (dispenser behaviour belongs to RS12/RS13).
17. (Closed in part.) Light dampening, occlusion shape, `useShapeForLightOcclusion`, friction, speed and jump factors, loot table key and mineable tags are now given by rules and tables in 7.14a and 7.14b. Remaining: the outline and occlusion shapes of classes whose shapes are in other documents are not expanded per state; the `needs_*_tool` result (none in this range) was computed from the tag files by resolving nested tags and should be re-checked if tag files are re-extracted.
18. File name: `24-block-registry-5-quartz-concrete-gates.md` does not match the range (no concrete blocks). Renaming needs edits to the sibling documents and `README.md`, which this pass may not touch.
19. Not covered by the fixer pass and needing a further reviewer: the state-id arithmetic of the colour collections and the 2801 total (section 11), the tall-plant `updateShape` rules of 7.17, and the wall banner placement scan. The daylight power branch layout was re-read in this pass.
