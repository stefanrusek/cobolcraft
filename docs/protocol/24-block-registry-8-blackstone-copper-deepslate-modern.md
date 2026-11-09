# Block registry, part 8: cracked nether bricks to firefly bush (Blocks fields 770 to 910) and the whole-registry check

| Item | Value |
|---|---|
| Covers | Rows for the last 141 fields of the `Blocks` static initialiser, `CHISELED_NETHER_BRICKS` (field 770, block id 1031) through `FIREFLY_BUSH` (field 910, block id 1285): cracked nether bricks and quartz bricks, candles and candle cakes, amethyst, tuff, sulfur and cinnabar families, calcite, tinted glass, powder snow, the sculk family, the weathering copper families (copper block, cut, chiseled, stairs, slabs, doors, trapdoors, grates, bulbs, chests, golem statues, lightning rods), dripstone, cave vines, spore blossom, azalea, moss, dripleafs, hanging roots, rooted dirt, mud, the deepslate families, raw metal blocks, potted azaleas, froglights, frogspawn, reinforced deepslate, decorated pot, crafter, trial spawner, vault, heavy core, pale moss, eyeblossoms and the firefly bush. It also gives the classes of these rows (properties with value order, default state, shapes, survival and placement rules), and closes with the whole-registry check: 911 fields, 1286 registered blocks, 35723 block states, and the seam values and per-field table that let parts 1 to 8 be compared with no gap and no overlap. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas) and of the client resource files `assets/minecraft/blockstates/*.json` (used only to cross-check property names, values and variant counts) and, for 7.5, the data files `data/minecraft/tags/block/*.json` and the file names under `data/minecraft/loot_table/blocks/` that the jar carries, with no execution. The following classes were also read in full: `BlockBehaviour$Properties`, `BlockBehaviour`, `BlockBehaviour$BlockStateBase`, `WallBlock`, `WallBlock$1`, `SpeleothemBlock$1`, `TrapDoorBlock`, `MossyCarpetBlock`, `MossyCarpetBlock$1`, `PotentSulfurBlock`, `OctahedralGroup`, `SymmetricGroup3`, `Blocks$1`, `TrialSpawnerState` and `VaultState`. Classes read are named in backticks where a fact is given. Values not read are marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions. |
| Status | Round RS4, part 8 of 8 (design map Part 5 GAP-1, and the columns of GAP-29 and GAP-30) |
| Shared rules | Column definitions, the `Properties` builder, derived per-state values, the shape model, enumerations (`MapColor`, `NoteBlockInstrument`, `SoundType`, `PushReaction`), tint classes, placement columns, blocks and items, and block tags are defined in part 1 of this document family (file `24-block-registry-1-model-and-foundation.md`, cited "24-block-registry-1 §N"; the other parts are cited the same way by the leading part of their file name). This part does not repeat them. |
| Siblings | Parts 1 to 7 cover `Blocks` fields 0 to 769 in field order: [24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md), [24-block-registry-2-leaves-flora-signs.md](24-block-registry-2-leaves-flora-signs.md), [24-block-registry-3-signs-doors-redstone.md](24-block-registry-3-signs-doors-redstone.md), [24-block-registry-4-stems-glass-skulls.md](24-block-registry-4-stems-glass-skulls.md), [24-block-registry-5-quartz-concrete-gates.md](24-block-registry-5-quartz-concrete-gates.md), [24-block-registry-6-gates-end-concrete-potted.md](24-block-registry-6-gates-end-concrete-potted.md), [24-block-registry-7-stairs-slabs-walls-workstations.md](24-block-registry-7-stairs-slabs-walls-workstations.md). Cite them as "24-block-registry-N §M". The seam between part 7 and this part was checked against part 7 (see 11.2). |

Class, method and field names in backticks say where a fact was read. They are not the design. "04 §5" means section 5 of
[04-registry-sync.md](04-registry-sync.md); "13 §2" means section 2 of
[13-client-gameplay-and-controls.md](13-client-gameplay-and-controls.md). The design map is `docs/design/README.md`.

Data versus code (design map R7). Ids, properties, state numbering, shapes, behaviours and tint rules are code and are
specified here for every row. Block models, block states JSON, loot tables, recipes and tag files are data that the
extraction tool copies out of the jar; they are not tabulated. Tag names that code reads are listed where a rule needs
them.

## Contents

1. Scope and seams
2. Registration mechanics used in this range
3. Property definitions used in this range
4. Block classes of this range
5. Shape reference
6. Light, map colour and other state-dependent functions
7. The rows: fields 770 to 910
8. Tint and placement summary (GAP-29 and GAP-30 columns)
9. Worked examples
10. Validation
11. Whole-registry check
12. Open questions
Appendix A. All 911 fields: ids and first state ids

---

## 1. Scope and seams

### 1.1 What this part covers

| Quantity | Value |
|---|---|
| Fields of `Blocks` | 141 (fields 770 to 910) |
| Registered blocks | 255 (ids 1031 to 1285): 127 fields register one block, 12 weathering copper fields register 8 blocks each (96), 2 dyed-candle fields register 16 each (32) |
| Block states | 9273 (state ids 26450 to 35722) |
| First field | 770 `CHISELED_NETHER_BRICKS`, id 1031, first state id 26450 |
| Last field | 910 `FIREFLY_BUSH`, id 1285, state id 35722 (the highest state id of the registry) |
| Seam with part 7 | field 769 `POLISHED_BLACKSTONE_WALL`, id 1030, first state id 26126, 324 states, last state id 26449 |

The row order is registry order. For a field that registers several blocks (section 2) the ids are consecutive in the
position of the field, so id of the next field = id of this field + number of blocks registered.

### 1.2 Families registered before this range

Some families that a reader may expect here are registered earlier in the initialiser and belong to parts 1 to 7. Field
indices read from the class: `MANGROVE_PROPAGULE` 34, `MANGROVE_ROOTS` 61, `BAMBOO_BLOCK` 63,
`BUSH` 128, `CREAKING_HEART` 183, `CACTUS_FLOWER` 269, `PACKED_MUD` 305, `MUD_BRICKS` 306, `COPPER_BARS` 317,
`COPPER_CHAIN` 319, `RESIN_BLOCK` 336, `RESIN_BRICKS` 337, `GLOW_LICHEN` 328, `POLISHED_BLACKSTONE_BRICKS` 758,
`CHISELED_POLISHED_BLACKSTONE` 760, `GILDED_BLACKSTONE` 764, `POLISHED_BLACKSTONE_WALL` 769 (see section 11.3 for the
fields that are in this part). Pale moss, eyeblossoms and the firefly bush are here (fields 903 to 910). The sulfur family
(fields 797 to 810, with the potent sulfur block at 798 and the sulfur spike at 849) and the cinnabar family (811 to 823)
are in this range; whether each is new in 26.3 is not established (no earlier artifact was read). Wildflowers (857) and
leaf litter (858) are also in this range.
The only `pearlescent` block in this range is the pearlescent froglight, and no separate "tinted" set exists besides
tinted glass.

### 1.3 Conventions

- Column meaning, units, and enumerations: 24-block-registry-1 §7 and §8. Hardness and blast resistance are floats; `f`
  suffixes are dropped. A hardness written `2` in the artifact (an int constant) is the float 2.0.
- `copy-legacy:X` and `copy-full:X` in the flags column say that the builder started from `Properties.ofLegacyCopy(X)`
  or `ofFullCopy(X)` (24-block-registry-1 §4.3) and then applied the other calls of the chain; the columns already show the
  resulting values. The difference between the two copies is in the predicates, jump factor, fall reduction, loot table
  and description (24-block-registry-1 §4.3); none of these is a column of the row table, and a copy never carries `noLootTable`.
- `viewBlocking:nearPlaneIntersectsOutline` marks slabs, stairs and the copper slab and stair rows: the builder
  replaces the view-blocking predicate by a test that is true when any box of the state's occlusion shape, moved to
  the block position, intersects the camera near plane (`Blocks.NEAR_PLANE_INTERSECTS_OUTLINE`, a
  `StateArgumentPredicate`). It is a rendering predicate (camera inside a block).
- The flags column shows the builder's resulting flags, implied ones included, not only the calls of the chain. `Properties.noCollision()` clears both
  `hasCollision` and `canOcclude`, so every row that shows `noCollision` also shows `noOcclusion` although its chain does not call `noOcclusion()`
  (cave vines, cave vines plant, spore blossom, sculk vein, pink petals, wildflowers, leaf litter, big dripleaf stem, small dripleaf, hanging roots,
  frogspawn, pale hanging moss, both eyeblossoms, firefly bush). `Properties.instabreak()` is `strength(0)`, that is hardness 0 and blast resistance 0, and
  `strength(h)` is `strength(h, h)`.
- "Default id" is the state id of the default state (24-block-registry-1 §3). "First state id" and "states" for a field that
  registers several blocks are those of the first block; section 7.3 lists the others.
- The associated item: the item key is the same as the block key unless the row says otherwise
  (`cave_vines` has item `glow_berries`); a block registered with `BlockIds` instead of `BlockItemIds` has no item
  (candle cakes, `cave_vines_plant`, `big_dripleaf_stem`, the potted blocks). 24-block-registry-1 §11.

### 1.4 `Properties` defaults that the rows rely on

A row with no call for a value takes the initial value assigned by the private constructor of `BlockBehaviour$Properties`. Table columns for
sound, push reaction and instrument therefore show these defaults when the chain has no `sound`, `pushReaction` or `instrument` call.

| Value | Initial value | Rows that show it |
|---|---|---|
| sound type | `SoundType.STONE` | every row without a `sound` call (decorated pot, the potted blocks, crafter, raw metal blocks, trial spawner, vault, heavy core, quartz bricks and others) |
| push reaction | `PUSH_PULL` | every row without a `pushReaction` call |
| note block instrument | `HARP` | every row without an `instrument` call |
| map colour | `MapColor.NONE` | every row without a `mapColor` call |
| has collision, can occlude | true, true | rows without `noCollision` or `noOcclusion` |
| light emission | 0 for every state | rows without `lightLevel` |
| friction, speed factor, jump factor | 0.6, 1.0, 1.0 | all 255 blocks of this range (see 7.4) |
| hardness (destroy time), blast resistance (explosion resistance) | 0.0, 0.0 | every row with no `strength` or `instabreak` call (pink petals, wildflowers, leaf litter, pale hanging moss, the potted blocks and others show 0.0 / 0.0 in 7.1); the private constructor assigns neither, so both keep the Java numeric default 0.0 (inferred from the absent assignment, as for `bounceRestitution`) |
| spawn terrain particles | true | |
| loot table key, description id | `blocks/<path>` in the loot table registry, `block.<namespace>.<path>` | see 7.5 |

`bounceRestitution` and `fallDistanceReduction` are not assigned by the constructor (inferred: Java numeric default 0.0, Open question 22).

---

## 2. Registration mechanics used in this range

### 2.1 Helpers that build the properties of a derived block

All are private static methods of `Blocks`. The block registered by a helper is a `SlabBlock`, `StairBlock` or
`WallBlock`; the properties come from the source block named in the call.

| Helper | Properties | Constructed block |
|---|---|---|
| `registerSlab(id, source)` | `ofLegacyCopy(source)` then the near-plane view-blocking test. Overloads add `destroyTime(h)` or `strength(h, r)` (not used by the rows here) | `new SlabBlock(props)` |
| `registerStair(id, source)` | `ofFullCopy(source)` then the near-plane view-blocking test | `new StairBlock(source.defaultBlockState(), props)` |
| `registerLegacyStair(id, source)` | `ofLegacyCopy(source)` then the near-plane view-blocking test; registered under the block key of the id | `new StairBlock(source.defaultBlockState(), props)` |
| `registerWall(id, source)` | `ofLegacyCopy(source)` then `forceSolidOn()` | `new WallBlock(props)` |

In this range `registerLegacyStair` is used by the tuff families and by the deepslate families; `registerStair`
(full copy) by the sulfur and cinnabar families. A stair, slab or wall therefore has the hardness, blast resistance,
tool flag, map colour, sound and instrument of its source block (the rows show them).

### 2.2 `ColorCollection` (dyed candles)

`DYED_CANDLE` (field 774) and `DYED_CANDLE_CAKE` (field 776) call `ColorCollection.registerBlocks`, which registers 16
blocks in the dye order white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue,
brown, green, red, black (24-block-registry-1 §2.3). Keys are `{dye}_candle` and `{dye}_candle_cake`. The properties function of the
candles is `candleProperties(dye map colour)`; that of the cakes is `ofLegacyCopy(CANDLE_CAKE)`, so they all share
the cake's values. The candle cake factory is `new CandleCakeBlock(DYED_CANDLE.pick(dye), props)`. Table in 7.2.

### 2.3 `WeatheringCopperCollection` (twelve fields)

A field that calls `WeatheringCopperCollection.registerBlocks(ids, register, waxedFactory, weatheringFactory, properties)`
registers 8 blocks. The argument order of the call is waxed factory first, weathering factory second (the order of
the method's parameters); the registration order is read from the method body:

1. The four weathering blocks, in weathering order unaffected, exposed, weathered, oxidized. Each is built by the
   weathering factory (two arguments: the weather state and the properties; a few factories ignore the state).
2. Then the four waxed blocks in the same order, built by the waxed factory.

Both runs call the same properties function with the weather state of the position, so a waxed block has the same
builder values as the unwaxed block of the same state. Keys: the id collection is built by prefixing the state prefixes
`""`, `exposed_`, `weathered_`, `oxidized_` (weathering run) and `waxed_`, `waxed_exposed_`, `waxed_weathered_`,
`waxed_oxidized_` (waxed run) to the base name (`WeatheringCopperCollection.PREFIXES` and `prefixWithState`; the prefix is
the first operand). For `COPPER_BLOCK` the base names are special: `copper_block` for the unaffected state and `copper`
for the other three (`COPPER_BLOCK_SPECIAL_NAMES`), so the keys are `copper_block`, `exposed_copper`,
`weathered_copper`, `oxidized_copper`, `waxed_copper_block`, `waxed_exposed_copper`, `waxed_weathered_copper`,
`waxed_oxidized_copper`. For every other family the base name is the family name (`cut_copper`, `copper_door`, ...).
The item key of each block equals its block key.

The classes: the weathering factory builds the "Weathering..." class (it implements the oxidation step, 29b part 5 section 4) and
the waxed factory builds the plain class (table 7.3). A `WeatheringCopper*` class adds no property to its plain
superclass: the state list is the same.

### 2.4 Collection fields of this range

| Field | Name | Blocks | Ids |
|---|---|---|---|
| 774 | `DYED_CANDLE` | 16 | 1035 to 1050 |
| 776 | `DYED_CANDLE_CAKE` | 16 | 1052 to 1067 |
| 833 | `COPPER_BLOCK` | 8 | 1124 to 1131 |
| 836 | `CUT_COPPER` | 8 | 1134 to 1141 |
| 837 | `CHISELED_COPPER` | 8 | 1142 to 1149 |
| 838 | `CUT_COPPER_STAIRS` | 8 | 1150 to 1157 |
| 839 | `CUT_COPPER_SLAB` | 8 | 1158 to 1165 |
| 840 | `COPPER_DOOR` | 8 | 1166 to 1173 |
| 841 | `COPPER_TRAPDOOR` | 8 | 1174 to 1181 |
| 842 | `COPPER_GRATE` | 8 | 1182 to 1189 |
| 843 | `COPPER_BULB` | 8 | 1190 to 1197 |
| 844 | `COPPER_CHEST` | 8 | 1198 to 1205 |
| 845 | `COPPER_GOLEM_STATUE` | 8 | 1206 to 1213 |
| 846 | `LIGHTNING_ROD` | 8 | 1214 to 1221 |

Fields 834 (`COPPER_ORE`) and 835 (`DEEPSLATE_COPPER_ORE`) are single blocks between the copper block and cut copper
fields.

---

## 3. Property definitions used in this range

Properties come from `BlockStateProperties` (or the block class). The state list orders properties by name (24-block-registry-1 §3 and
04 §5.2); the value lists below give each property's own order, which is the order of the index in that formula.

| Property name | Type | Values in order | Used by |
|---|---|---|---|
| `candles` | int 1 to 4 | 1, 2, 3, 4 | candles |
| `lit` | bool | true, false | candles, candle cakes, copper bulbs |
| `waterlogged` | bool | true, false | most blocks with a non-cube shape (see section 4) |
| `facing` (`FACING`) | enum Direction | north, east, south, west, up, down (an explicit order, not ordinal order) | amethyst clusters, lightning rods |
| `facing` (`HORIZONTAL_FACING`) | enum Direction, horizontal only | north, south, west, east (Direction constants in declaration order DOWN, UP, NORTH, SOUTH, WEST, EAST with the vertical ones filtered out) | stairs, doors, trapdoors, chests, statues, pots, dripleaf, vault, calibrated sensor, pink petals, leaf litter |
| `type` (slab) | enum | top, bottom, double | slabs |
| `half` (stairs, trapdoors) | enum | top, bottom | stairs, trapdoors |
| `half` (doors, small dripleaf) | enum | upper, lower | doors, small dripleaf |
| `shape` | enum | straight, inner_left, inner_right, outer_left, outer_right | stairs |
| `hinge` | enum | left, right | doors |
| `open`, `powered` | bool | true, false | doors, trapdoors; `powered` also bulbs, rods |
| `up` (walls) | bool | true, false | walls |
| `north`, `east`, `south`, `west` (walls and pale moss carpet) | enum | none, low, tall | walls, pale moss carpet |
| `bottom` | bool | true, false | pale moss carpet |
| `down`, `east`, `north`, `south`, `up`, `west` (face flags) | bool | true, false | sculk vein |
| `sculk_sensor_phase` | enum | inactive, active, cooldown | sculk sensors |
| `power` | int 0 to 15 | 0 to 15 | sculk sensors |
| `bloom` | bool | true, false | sculk catalyst |
| `shrieking`, `can_summon` | bool | true, false | sculk shrieker |
| `vertical_direction` | enum | up, down | pointed dripstone, sulfur spike |
| `thickness` | enum | tip_merge, tip, frustum, middle, base | pointed dripstone, sulfur spike |
| `age` | int 0 to 25 | 0 to 25 | cave vines |
| `berries` | bool | true, false | cave vines, cave vines plant |
| `flower_amount` | int 1 to 4 | 1, 2, 3, 4 | pink petals, wildflowers |
| `segment_amount` | int 1 to 4 | 1, 2, 3, 4 | leaf litter |
| `tilt` | enum | none, unstable, partial, full | big dripleaf |
| `tip` | bool | true, false | pale hanging moss |
| `axis` | enum | x, y, z | deepslate, infested deepslate, froglights |
| `cracked` | bool | true, false | decorated pot |
| `orientation` | enum `FrontAndTop` (12) | down_east, down_north, down_south, down_west, up_east, up_north, up_south, up_west, west_up, east_up, north_up, south_up | crafter |
| `triggered`, `crafting` | bool | true, false | crafter |
| `trial_spawner_state` | enum | inactive, waiting_for_players, active, waiting_for_reward_ejection, ejecting_reward, cooldown | trial spawner |
| `vault_state` | enum | inactive, active, unlocking, ejecting | vault |
| `ominous` | bool | true, false | trial spawner, vault |
| `potent_sulfur_state` | enum | dry, wet, dormant, erupting, continuous | potent sulfur |
| `copper_golem_pose` | enum | standing, sitting, running, star | copper golem statue |
| `type` (chest) | enum | single, left, right | copper chests |

The two `half` and the two `facing` properties have the same name but different value lists; the list in use is the one of the
block's own class (section 4). A property absent from a block does not enter its state list.

---

## 4. Block classes of this range

Properties are listed in the sorted-name order used by the state formula. "Default" gives the default state as read from the
constructor (`registerDefaultState`); a property not named takes the value in the first position of its list only when the
constructor says so, so every default here is spelled out. "Survive" is `canSurvive`; "Place" is `getStateForPlacement`.
Water: a class that implements `SimpleWaterloggedBlock` reports the water source fluid state when `waterlogged` is true and
schedules a water tick on a neighbour update; unless stated otherwise the placement sets `waterlogged` when the fluid at the
position is water. Box coordinates in the shape column are pixels (0 to 16) in the shape's own orientation; section 5 gives
the orientation rule. Behaviour that is not about the registry (random ticks, growth, spreading, vibrations, block entities,
use actions) is only named and cross-referenced: block updates and placement are in 29, falling, growth, spreading, bone meal and oxidation in 29b, block entities in 31, light in 32, worldgen features in 35, loot and predicates in 26. Redstone and fluids have no document yet (Open question 24, written "OQ 24 redstone" below).

### 4.1 Plain and nearly plain blocks

| Class | Properties and default | Shape and other overrides | Survive | Place |
|---|---|---|---|---|
| `Block` | none; one state | full cube | true | default state |
| `AmethystBlock`, `BuddingAmethystBlock` | none | full cube; budding amethyst has `randomTicks` (growth: 29b) | true | default |
| `TintedGlassBlock` (extends `TransparentBlock`) | none | full cube; visual shape empty; shade brightness 1.0; `propagatesSkylightDown` false (the parent says true); `getLightDampening` 15 | true | default |
| `WaterloggedTransparentBlock` (copper grate, waxed grate) | `waterlogged`; default false | full cube; visual shape empty; shade brightness 1.0; skylight passes; placement waterlogged when the fluid is water | true | default plus waterlogged |
| `DropExperienceBlock(xp)` (copper ores: `ConstantInt(0)`; `SculkBlock`: `ConstantInt(1)`) | none | full cube | true | default |
| `SculkBlock` | none | full cube; implements `SculkBehaviour` (spread: 31 part 8 section 7.3, `SculkSpreader`) | true | default |
| `PowderSnowBlock` | none | outline: full cube; `dynamicShape`; collision depends on the entity (see 5.3); `skipRendering` true next to powder snow; `getVisualShape` empty; pathfindable true for every computation type | true | default |
| `RootedDirtBlock` | none | full cube (bone meal behaviour: 29b part 1) | true | default |
| `MudBlock` | none | outline full cube; collision `column(16,0,14)`; block support shape and visual shape full cube; shade brightness 0.2; not pathfindable | true | default |
| `BonemealableFeaturePlacerBlock(feature)` (moss block: `CaveFeatures.MOSS_PATCH_BONEMEAL`; pale moss block: `VegetationFeatures.PALE_MOSS_PATCH_BONEMEAL`) | none | full cube; bone meal places the named configured feature (worldgen data: bone meal placement in 29b part 5 section 3.3, feature model in 35) | true | default |
| `RotatedPillarBlock` (deepslate, froglights) | `axis`; default `y` | full cube | true | `axis` of the clicked face (24-block-registry-1 §10.3) |
| `InfestedRotatedPillarBlock(host, props)` (`INFESTED_DEEPSLATE`, host `DEEPSLATE`; constructor rule below the table) | `axis`; default `y` | full cube | true | `axis` of the clicked face; the silverfish release on break is Open question 26 |
| `FrogspawnBlock` | none | outline `column(16,0,1.5)` | block below: see 4.3 | default; hatch delay 3600 to 12000 ticks (rule below the table in 4.4) |
| `FlowerPotBlock(content)` (four potted blocks) | none | `column(6,0,6)`; not pathfindable; the two potted eyeblossoms are randomly ticking (class rule) | true | default |
| `HeavyCoreBlock` | `waterlogged`; default false | `column(8,0,8)`; not pathfindable | true | default plus waterlogged |
| `CrafterBlock` | `crafting`, `orientation`, `triggered`; default `crafting` false, `orientation` north_up, `triggered` false | full cube; has a block entity (31 part 2 section 7); analog output from the block entity | true | front = the opposite of the placer's nearest looking direction; top = the opposite of the placer's horizontal direction when the front is down, the placer's horizontal direction when the front is up, and up in the four horizontal cases (`FrontAndTop.fromFrontAndTop(front, top)`); `triggered` true when a neighbour signal reaches the position |
| `TrialSpawnerBlock` | `ominous`, `trial_spawner_state`; default false, `inactive` | full cube; block entity (31 part 7 section 4) | true | default |
| `VaultBlock` | `facing` (horizontal), `ominous`, `vault_state`; default north, false, `inactive` | full cube; block entity (31 part 7 section 5) | true | `facing` = the opposite of the placer's horizontal direction |
| `PotentSulfurBlock` | `potent_sulfur_state`; default `dry` | full cube; block entity (31 part 8); the ticker depends on the state | true | the state is recomputed at placement and on every shape update by `validBlockState(level, pos)`, read in this order: (1) the fluid above is not a water source: `dry`; (2) otherwise the block below is in block tag `causes_continuous_geyser_eruptions` and its fluid state is empty or a source: `continuous`; (3) otherwise the block below is in tag `causes_periodic_geyser_eruptions` with the same fluid condition: when the current state is neither `erupting` nor `dormant` the block entity's countdown is reset, then the result is `erupting` if the current state is `erupting`, else `dormant`; (4) otherwise `wet`. The fluid condition "empty or a source" is true for a solid block (empty fluid state). Ticker set per state: 31 part 8 |

`InfestedBlock` constructor rule (parent of `InfestedRotatedPillarBlock`): the constructor replaces the properties it is given: destroy time = the host block's `defaultDestroyTime()` divided by 2, and explosion resistance = 0.75, whatever the builder chain set. The registry row of `infested_deepslate` has no `strength` call, so with host `DEEPSLATE` (hardness 3.0) its values are hardness 1.5 and blast resistance 0.75. Other infested blocks follow the same rule, but this is the only one in fields 770 to 910. The constructor also registers the host-to-infested pair in a static map (used by the silverfish behaviour, Open question 26).

### 4.2 Candles, cakes, amethyst, sculk

| Class | Properties and default | Shape | Survive | Place and other |
|---|---|---|---|---|
| `CandleBlock` (`CANDLE`, `DYED_CANDLE`) | `candles`, `lit`, `waterlogged`; default 1, false, false | by `candles` 1 to 4: box(7,0,7,9,6,9); box(5,0,6,11,6,9); box(5,0,6,10,6,11); box(5,0,5,11,6,10) | `Block.canSupportCenter(level, pos.below(), UP)` | if the block at the position is this block, `candles` cycles 1 to 2 to 3 to 4 to 1 (`BlockState.cycle`); otherwise the default state with `waterlogged` from the fluid. Replaceable by the same candle item when the placer is not using secondary use and `candles` is below 4. Can be lit only when not waterlogged and not lit. Extinguished by an empty hand when `lit` (use action: 29 section 9). Light: 3 times `candles` when lit |
| `CandleCakeBlock(candle)` (`CANDLE_CAKE`, `DYED_CANDLE_CAKE`) | `lit`; default false | box(1,0,1,15,8,15) united with box(7,8,7,9,14,9) (`column(14,0,8)` and `column(2,8,14)`) | the block below `isSolid()` | not placed by an item; analog comparator output 14 (`CakeBlock.FULL_CAKE_SIGNAL`, which is (7 - 0 bites) times 2); not pathfindable; light 3 when lit |
| `AmethystClusterBlock(height, width)` | `facing` (explicit order), `waterlogged`; default `up`, false | for facing north, box centred on x and y with side `width` and z from `16 - height` to 16 (`boxZ(width, 16 - height, 16)`), rotated to the other five facings (section 5.1). Arguments: cluster (7, 10), large bud (5, 10), medium bud (4, 10), small bud (3, 8) | the block opposite to `facing` (at `pos - facing`) must have its face toward `facing` sturdy (`isFaceSturdy`, full) | `facing` = the clicked face; `waterlogged` from the fluid. After a neighbour update from the opposite side, when `canSurvive` fails the state becomes air |
| `SculkSensorBlock` | `power` 0 to 15, `sculk_sensor_phase`, `waterlogged`; default power 0, `inactive`, false | outline and collision `column(16,0,8)` (the lower half); `useShapeForLightOcclusion` true; not pathfindable | true | waterlogged from the fluid. Redstone: signal source; direct signal only toward `up`; analog output = last vibration frequency when active, else 0 (OQ 24 redstone; block entity 31 part 8 section 4) |
| `CalibratedSculkSensorBlock` | as the sensor plus `facing` (horizontal); default = sensor default and north | as the sensor | true | as the sensor, plus `facing` = the placer's horizontal direction (not opposite). Its own signal is returned for every direction argument except the one equal to `facing`, for which it returns 0 |
| `SculkCatalystBlock` | `bloom`; default false | full cube; block entity (xp range `ConstantInt(5)`) | true | default |
| `SculkShriekerBlock` | `can_summon`, `shrieking`, `waterlogged`; default false, false, false | outline: full cube (no `getShape` override); collision and occlusion `column(16,0,8)`; `useShapeForLightOcclusion` true | true | waterlogged from the fluid; block entity (31 part 8 section 6) |
| `SculkVeinBlock` (extends `MultifaceSpreadeableBlock`, `MultifaceBlock`) | `down`, `east`, `north`, `south`, `up`, `waterlogged`, `west` (seven booleans); default all false (the last state of the 128) | union of one thin sheet per true face; the sheet of a face is box(0,0,0,16,16,1) at the north face rotated to the face (section 5.1); the shape is the full cube when no face is set | true when at least one face flag is set and, for every set face, the neighbour on that face satisfies `canAttachTo` (its block support shape or its collision shape has the opposite face full) | `getStateForPlacement` picks the first of the nearest looking directions for which a valid state exists (face flag set and, when the position already holds this block, the face not set and attachable); replaceable by the same item when any face is free. Every face is supported by the base class (`isFaceSupported` true). Spreading: 31 part 8 section 7.3 |

### 4.3 Slabs, stairs, walls, doors, trapdoors, chests, statues, rods, grates, bulbs

| Class | Properties and default | Shape (see 5.2) | Place and other |
|---|---|---|---|
| `SlabBlock` | `type`, `waterlogged`; default bottom, false | bottom: `column(16,0,8)`; top: `column(16,8,16)`; double: full cube. `useShapeForLightOcclusion` true unless double | if the position holds this slab, `type` double and not waterlogged; else bottom with waterlogged from the fluid, then top when the clicked face is not up/down and the click height above the block base exceeds 0.5, or the clicked face is down. Replaceable by the same item per the clicked face and click height (full rule in the class; the double-slab upgrade case is the common one). `placeLiquid` and `canPlaceLiquid` are refused for double |
| `StairBlock(base, props)` | `facing`, `half`, `shape`, `waterlogged`; default north, bottom, straight, false | 5.2 | `facing` = the placer's horizontal direction; `half` = top when the clicked face is down, or the click is on a side and above 0.5, else bottom; `shape` from the neighbours (rule below); `useShapeForLightOcclusion` true; not pathfindable |
| `WallBlock` | `east`, `north`, `south`, `up`, `waterlogged`, `west`; default up true, sides none, waterlogged false | 5.2 | a side is connected when the neighbour in that direction is in tag `walls`, or is an aligned fence gate, or has a sturdy face toward the wall (`connectsTo`); a connected side is `tall` or `low`, and an unconnected side is `none` (rule `makeWallState` below); `up` is decided by `shouldRaisePost` (rule below). `propagatesSkylightDown` = not waterlogged; not pathfindable |
| `DoorBlock(type, props)` | `facing`, `half`, `hinge`, `open`, `powered`; default north, lower, left, false, false | 5.2 | the constructor sets the sound type of the block from the block set type (copper: `SoundType.COPPER`). Survive: the lower half needs a sturdy top face below; the upper half needs the lower half of the same block below. Placed only when the position above is replaceable and below the height limit; `powered` and `open` are both set when a signal reaches the position or the position above; `facing` = the placer's horizontal direction; hinge from `getHinge` (neighbours); `half` lower |
| `TrapDoorBlock(type, props)` | `facing`, `half`, `open`, `powered`, `waterlogged`; default north, bottom, false, false, false | 5.2 | sound type from the block set type. Placement has two branches, selected as follows (read from `getStateForPlacement`): the **placer branch** is taken when `replacingClickedOnBlock()` is false or the clicked face is not horizontal (it is up or down): `facing` = the opposite of the placer's horizontal direction, `half` = bottom when the clicked face is up, else top. The **side branch** is taken when `replacingClickedOnBlock()` is true and the clicked face is horizontal: `facing` = the clicked face, `half` = top when the click height above the block base exceeds 0.5, else bottom. After either branch: when a neighbour signal reaches the position, `open` and `powered` are both true; `waterlogged` when the fluid at the position is water. Pathfindable when open for land and air, and for water when waterlogged |
| `CopperBulbBlock` | `lit`, `powered`; default false, false | full cube | comparator output 15 when lit; light by weathering when lit (section 6) |
| `ChestBlock` (`CopperChestBlock`, `WeatheringCopperChestBlock`) | `facing`, `type`, `waterlogged`; default north, single, false | single: `column(14,0,14)`; left and right: box(1,0,0,15,14,15) rotated so that the long side points to the partner (key `getConnectedDirection`: the facing rotated clockwise for `left`, counter-clockwise for `right`) | placement picks the partner with the neighbour rule of the class (`candidatePartnerFacing`) unless the placer is sneaking, and then the copper chest takes the least oxidized state of the connected chests. Block entity, container, comparator output from the container (31 part 1). Not pathfindable |
| `DecoratedPotBlock` | `cracked`, `facing`, `waterlogged`; default false, north, false | `column(14,0,16)` = box(1,0,1,15,16,15) | `facing` = the placer's horizontal direction, `cracked` false, waterlogged from the fluid; comparator output from the block entity (31 part 3 section 5); not pathfindable |
| `CopperGolemStatueBlock(weatherState, props)` | `copper_golem_pose`, `facing`, `waterlogged`; default standing, north, false | `column(10,0,14)` | `facing` = the opposite of the placer's horizontal direction; comparator output = ordinal of the pose plus 1 (1 to 4); block entity (31 part 8 section 8; oxidation and statue hooks 29b part 5 section 6.3) |
| `LightningRodBlock` (extends `RodBlock`) | `facing` (explicit order), `powered`, `waterlogged`; default up, false, false | 5.2 (by the axis of `facing`) | `facing` = the clicked face; direct signal 15 toward `facing` while powered; signal source; not pathfindable |

Stair shape rule (`getStairsShape`): look at the neighbour in front (`pos` moved by `facing`). When it is a stair with the same
`half` and a facing on the other axis, and `canTakeShape(pos, opposite of that neighbour's facing)` holds, the shape is
`outer_left` when that neighbour's facing equals this stair's facing rotated counter-clockwise, else `outer_right`. Otherwise
look at the neighbour behind (`pos` moved by the opposite of `facing`): when it is a stair with the same `half` and a facing on
the other axis, and `canTakeShape(pos, that neighbour's facing)` holds, the shape is `inner_left` when its facing equals this
facing rotated counter-clockwise, else `inner_right`. Otherwise `straight`. `canTakeShape(pos, dir)` looks at the block at
`pos` moved by `dir` and is true when that block is not a stair, or has another facing than this stair, or another half.

Wall rules (`WallBlock.updateShape`, `makeWallState`, `shouldRaisePost`, `isCovered`). Inputs: the wall state, the
block above it, and for each of the four directions a flag "connected" (from `connectsTo`, from the neighbour on that side).

1. `aboveShape` = the face of the above block's collision shape that points down (`getCollisionShape(...).getFaceShape(DOWN)`).
2. For each direction: when not connected, the side is `none`. When connected, the side is `tall` if the side test box lies
   entirely inside `aboveShape`, else `low`. The side test box for north is box(7,0,0,9,16,9) (`boxZ(2, 16, 0, 9)`: x 7 to 9, y 0 to 16, z 0 to 9),
   rotated to the other three directions with `rotateHorizontal`. "Inside" (`isCovered(a, b)`) means that no part of `b` lies
   outside `a`. A wall with no solid block above therefore has `low` sides; a block above whose down face covers the side
   box makes the side `tall`. (The treatment of the down face shape as a footprint in x and z is inferred, Open question 20.)
3. `up` = `shouldRaisePost(wall state with the new sides, above state, aboveShape)`, evaluated in this order:
   1. true when the above block is a wall whose `up` is true;
   2. true when the wall has no connected side at all, or when exactly one of north and south is connected, or exactly one of
      east and west is connected (so an end, a corner, a T-junction or a lone post is raised; a straight run through, or a
      cross, is not raised by this test);
   3. false when north and south are both `tall`, or east and west are both `tall`;
   4. otherwise true when the above block is in block tag `wall_post_override`, or when the post test shape
      `column(2,0,16)` (x and z 7 to 9, y 0 to 16) lies entirely inside `aboveShape`; else false.

Worked examples (wall rules). (a) A wall with no neighbours and air above: no connected side, step 3.2 gives `up` true. (b) A wall
connected north and south, `low` sides, air above (the empty shape covers nothing): 3.1 no, 3.2 no (north and south are both
connected, east and west both not), 3.3 no, 3.4: not a post-override block and the post test shape is not inside the empty shape, so `up` is false.
(c) The same wall with a full-cube block above: the side test boxes and the post test shape are inside the full down face, so both
sides are `tall`, and 3.3 gives `up` false.

### 4.4 Dripstone, vines, plants

| Class | Properties and default | Shape | Survive | Place and other |
|---|---|---|---|---|
| `SpeleothemBlock(base, props)` (`PointedDripstoneBlock`, `SulfurSpikeBlock`) | `thickness`, `vertical_direction`, `waterlogged`; default tip, up, false | by thickness (5.2), then moved by the block offset (type XZ, maximum horizontal offset 0.125 = (16 - 12) / 2 / 16, read from the base shape; maximum vertical offset the builder default). The two classes have the same shape, properties and defaults | `isValidSpeleothemPlacement` for the tip direction (rule not read here, Open question 9) | `vertical_direction` from the nearest looking vertical direction, thickness from the neighbours, waterlogged from the fluid. Implements `Fallable` (falling: 29b part 1). Not pathfindable |
| `CaveVinesBlock` (head) | `age` 0 to 25, `berries`; default 0, false | `column(14,0,16)` | the block above (growth direction down, opposite is `up`) must be attachable and have a sturdy down face, or be the head or body of cave vines | randomly ticking while `age` is below 25; placement age is random 0 to 24 (`nextInt(25)`); growth: 29b |
| `CaveVinesPlantBlock` (body) | `berries`; default false | `column(14,0,16)` | as the head | not replaceable by the head's own item (the class returns false for it; otherwise the default rule); light 14 when berries |
| `SporeBlossomBlock` | none | `column(12,13,16)` | the block above has a center-supporting down face (`canSupportCenter(above, DOWN)`) and the position is not in water (`isWaterAt`) | default |
| `AzaleaBlock` (azalea and flowering azalea) | none | `column(16,8,16)` united with `column(4,0,8)` | the block below is in tag `supports_azalea`; not pathfindable | default |
| `CarpetBlock` (moss carpet) | none | `column(16,0,1)` | the block below is not air | default |
| `MossyCarpetBlock` (pale moss carpet) | `bottom`, `east`, `north`, `south`, `west`; default `bottom` true, sides none | `makeShapes`: the base slab (`bottom`: y 0 to 1 full width) united with, for each side: `low` = box(0,0,0,16,10,1) rotated to the side, `tall` = box(0,0,0,16,16,1) rotated to the side (mapping read from the `makeShapes` lambda: `low` is the height-10 sheet, `tall` the full-height sheet); the full cube when the union is empty. Collision: when `bottom` is true the shape of the default state (the base slab alone), else empty. `propagatesSkylightDown` true | when `bottom` the block below is not air; otherwise the block below must be a pale moss carpet with `bottom` set | `getUpdatedState(state, level, pos, forceLow)` recomputes the four sides (rule below the table) |
| `FlowerBedBlock(props, height 3)` (pink petals, wildflowers) | `facing`, `flower_amount`; default north, 1 | 5.2 (segmented, height 3) | the block below is in tag `supports_vegetation` | `flower_amount` + 1 (capped at 4) when the block at the position is this block, else facing = the opposite of the placer's horizontal direction; replaceable by the same item when not using secondary use and amount below 4 |
| `LeafLitterBlock` | `facing`, `segment_amount`; default north, 1 | 5.2 (segmented, height 1) | the block below has a sturdy up face | as flower beds with `segment_amount`; also has the builder `replaceable` flag |
| `BigDripleafBlock` | `facing`, `tilt`, `waterlogged`; default north, none, false | 5.2 | the block below is a big dripleaf, a big dripleaf stem, or in tag `supports_big_dripleaf` | facing = opposite of the placer's horizontal direction unless a big dripleaf (or stem) is below (then copied); waterlogged when the fluid is a water source. Tilt timing and tick delays: 29b |
| `BigDripleafStemBlock` | `facing`, `waterlogged`; default north, false | 5.2 | the block below is a stem or in `supports_big_dripleaf`, and the block above is a stem or a big dripleaf | stem facing copied from the leaf above in the update rules (29 section 3.2) |
| `SmallDripleafBlock` (extends `DoublePlantBlock`) | `facing`, `half`, `waterlogged`; default north, lower, false | `column(12,0,13)`, moved by the offset (type XYZ, maximum vertical offset 0.1) | upper half: the lower half of this block below; lower half: the block below is in tag `supports_small_dripleaf`, or the position above is a water source and the vegetation rule holds | `facing` = opposite of the placer's horizontal direction; needs the position above replaceable and below the height limit; waterlogged from the fluid (lower half) |
| `HangingRootsBlock` | `waterlogged`; default false | `column(12,10,16)`, offset type XZ | the block above has a sturdy down face | default plus waterlogged; the builder has `replaceable` |
| `HangingMossBlock` (pale hanging moss) | `tip`; default true | tip: `column(14,2,16)`; base: `column(14,0,16)`; skylight passes | `canStayAtPosition`: the block above can be attached to from below (multiface rule) or is this block | default |
| `EyeblossomBlock(type, props)` (open, closed) | none | `column(6,0,10)` moved by the offset (XZ), via `FlowerBlock` | the block below is in tag `supports_vegetation` | default; the open and closed block exchange by environment ticks (29b); the suspicious stew effect is data of the type |
| `FireflyBushBlock` | none | default shape (full cube) with `noCollision` | the block below is in tag `supports_vegetation` | default; light 2 |

Pale moss carpet sides (`MossyCarpetBlock.getUpdatedState(state, level, pos, forceLow)`). Let `base` be
`forceLow` OR the state's `bottom`. For each horizontal direction `d`, with `canSupportAtFace(d)` = `MultifaceBlock.canAttachTo(level, pos, d)`
(always false for up, which is not iterated here):

1. The candidate value is `none` when `canSupportAtFace(d)` is false. When it is true, the candidate is `low` if `base` is true, else the current value of that side.
2. When the candidate is `low`: look at the block above. If it is a pale moss carpet whose side `d` is not `none` and whose `bottom` is false, the candidate becomes `tall`.
   Then, if this state's `bottom` is false: look at the block below; if it is a pale moss carpet whose side `d` is `none`, the candidate becomes `none`.
3. The candidate is stored as the side `d`. Candidates that are `none` or `tall` at step 1 (current value kept) skip step 2.

Worked example: a carpet with `bottom` true over a solid block, with a solid block to the north and nothing else: north = `low` (step 1, `base` true); the block above is air, so no `tall`; `bottom` is true, so the below check is skipped; south, east, west = `none`.

`VegetationBlock` (parent of azalea, flower bed, leaf litter, eyeblossom, firefly bush): survive is `mayPlaceOn(below)` with
tag `supports_vegetation` unless overridden; `propagatesSkylightDown` is "the fluid at the position is empty"; pathfinding
through the block is allowed for air computations when it has no collision.

Frogspawn survive (`FrogspawnBlock.mayPlaceOn`): the fluid at the position below passes when it is in fluid tag
`supports_frogspawn` or the block below is in block tag `supports_frogspawn`, and the fluid above must be empty
(grouping read: (fluid below in tag OR block below in tag) AND the fluid at the frogspawn position is empty; Open question 6). Hatch timing: the static fields `minHatchTickDelay` and `maxHatchTickDelay` are set to 3600 and 12000 in the static initialiser (the class also has constants `DEFAULT_MIN_HATCH_TICK_DELAY` 3600, `DEFAULT_MAX_HATCH_TICK_DELAY` 12000, `MIN_TADPOLES_SPAWN` 2 and `MAX_TADPOLES_SPAWN` 5); `onPlace` schedules a tick after a uniform random delay between the two (`nextInt(min, max)`). The hatch behaviour itself is deferred (29b).

---

## 5. Shape reference

### 5.1 Orientation rule

A shape built for the north direction is turned to the other directions by `Shapes.rotateHorizontal`, `rotateAll`,
`rotateHorizontalAxis` or `rotateAllAxis`. The rotations are about the block centre. Mapping of the direction key to the
rotation of the base (north) shape:

| Key | Rotation of the base shape | Effect on a pixel box |
|---|---|---|
| north | none | as written |
| east | `BLOCK_ROT_Y_90` | point (x, z) goes to (16 - z, x), y unchanged |
| south | `BLOCK_ROT_Y_180` | (x, z) goes to (16 - x, 16 - z) |
| west | `BLOCK_ROT_Y_270` | (x, z) goes to (z, 16 - x) |
| up | `BLOCK_ROT_X_270` | the north direction (minus z) is carried onto up (plus y), and up onto south: (y, z) goes to (16 - z, y). A shape at the south side (z 9 to 16) becomes a shape at the bottom (y 0 to 7). Read from the group: see the table after this one |
| down | `BLOCK_ROT_X_90` | the north direction is carried onto down, and down onto south: (y, z) goes to (z, 16 - y). A shape at the south side becomes a shape at the top. Read from the group: see the table after this one |
| axis x | `BLOCK_ROT_Y_90` of the axis z base | |
| axis y | `BLOCK_ROT_X_90` of the axis z base | |

The signs are read from `com.mojang.math.OctahedralGroup`. Its static initialiser assigns `BLOCK_ROT_Y_90` = `ROT_90_Y_NEG`, `BLOCK_ROT_Y_180` = `ROT_180_FACE_XZ`, `BLOCK_ROT_Y_270` = `ROT_90_Y_POS`,
`BLOCK_ROT_X_90` = `ROT_90_X_NEG`, `BLOCK_ROT_X_270` = `ROT_90_X_POS`. Each constant is a permutation of the axes plus three invert flags (x, y, z). The direction map `rotate(Direction)` takes the
axis of the direction, applies the inverse permutation to it, and flips the axis direction when the resulting axis is inverted. The constants used here:

| Constant | Permutation | Inverted axes | Direction map (result) | Same as the table above |
|---|---|---|---|---|
| `ROT_90_Y_NEG` (`BLOCK_ROT_Y_90`) | swap x and z | x | north to east, east to south, south to west, west to north | key east: point (x, z) to (16 - z, x) |
| `ROT_180_FACE_XZ` (`BLOCK_ROT_Y_180`) | none | x and z | north to south, east to west | key south: (x, z) to (16 - x, 16 - z) |
| `ROT_90_Y_POS` (`BLOCK_ROT_Y_270`) | swap x and z | z | north to west, west to south, south to east, east to north | key west: (x, z) to (z, 16 - x) |
| `ROT_90_X_POS` (`BLOCK_ROT_X_270`) | swap y and z | y | north to up, up to south, south to down, down to north | key up: (y, z) to (16 - z, y) |
| `ROT_90_X_NEG` (`BLOCK_ROT_X_90`) | swap y and z | z | north to down, down to south, south to up, up to north | key down: (y, z) to (z, 16 - y) |

The pixel formulas follow from the direction maps by linearity about the block centre (8, 8, 8); the box transform inside `Shapes.rotate` delegates to the same group (`DiscreteVoxelShape.rotate(group)`), and its arithmetic was not read (Open question 19). `rotateHorizontal` builds the four horizontal keys (compose with the given
group first, then the rotation), `rotateAll` adds up and down, `rotateHorizontalAxis` has the axes z and x, `rotateAllAxis` the axes
z, x and y. `INVERT_Y` flips y (used for the top stairs).

Box helpers (24-block-registry-1 §6.2, completed here from the bytecode): `Block.boxZ(sx, sy, z0, z1)` is the box from x = 8 - sx/2
to 8 + sx/2, y = 8 - sy/2 to 8 + sy/2, z = z0 to z1; `boxZ(s, z0, z1)` means `boxZ(s, s, z0, z1)`;
`boxZ(sx, y0, y1, z0, z1)` (five arguments) is the box x = 8 - sx/2 to 8 + sx/2, y = y0 to y1, z = z0 to z1.
`Block.column(sx, sz, y0, y1)` is x = 8 - sx/2 to 8 + sx/2, z = 8 - sz/2 to 8 + sz/2, y = y0 to y1.
`Block.cube(sx, sy, sz)` is a box centred on all three axes.

### 5.2 Shape constants by class

| Class | Shapes (pixel units; orientation: north unless stated) |
|---|---|
| `SlabBlock` | bottom: box(0,0,0,16,8,16); top: box(0,8,0,16,16,16); double: the full cube |
| `StairBlock` | `OUTER` = box(0,0,0,16,8,16) united with box(0,8,0,8,16,8). `STRAIGHT` = `OUTER` united with `OUTER` rotated by `BLOCK_ROT_Y_90`. `INNER` = `STRAIGHT` united with `STRAIGHT` rotated by `BLOCK_ROT_Y_90`. Bottom shapes: the horizontal rotations of each; top shapes: the same with `INVERT_Y` applied first. Selection: straight uses the facing key; outer_left, inner_right use the facing key; inner_left uses the facing rotated counter-clockwise; outer_right uses the facing rotated clockwise (the switch map of `StairBlock$1` numbers STRAIGHT 1, OUTER_LEFT 2, INNER_RIGHT 3, INNER_LEFT 4, OUTER_RIGHT 5, read) |
| `WallBlock` outline | post `column(8,0,16)` (x and z 4 to 12, y 0 to 16), included only when `up` is true; each side other than `none` adds an arm toward its direction: `low` = box(5,0,0,11,14,11), `tall` = box(5,0,0,11,16,11) (north arm, rotated to the side). Read from `makeShapes(16, 14)` and the `WallBlock$1` switch map (NONE 1, LOW 2, TALL 3): `low` uses the arm of height 14 (the second argument), `tall` the arm of height 16 (the first argument, the same as the post); `none` adds nothing |
| `WallBlock` collision | the same with height 24 for post and arms (post `column(8,0,24)`, arms box(5,0,0,11,24,11)) |
| `DoorBlock` | one slab box(0,0,13,16,16,16) rotated by the horizontal key. Closed: key = `facing`. Open: key = `facing` rotated counter-clockwise when `hinge` is right, clockwise when `hinge` is left |
| `TrapDoorBlock` | one slab box(0,0,13,16,16,16) with the `rotateAll` keys: closed bottom half uses key up (the slab y 0 to 3), closed top half uses key down (y 13 to 16), open uses the `facing` key (slab on that side as the base for north: z 13 to 16) |
| `ChestBlock` | single: `column(14,0,14)` = box(1,0,1,15,14,15); left or right: box(1,0,0,15,14,15) under `rotateHorizontal`, selected by the connected direction |
| `CopperGolemStatueBlock` | `column(10,0,14)` = box(3,0,3,13,14,13) |
| `LightningRodBlock` | `cube(4,4,16)`: for the z axis box(6,6,0,10,10,16); for the x axis box(0,6,6,16,10,10); for the y axis box(6,0,6,10,16,10); selected by the axis of `facing` |
| `AmethystClusterBlock` | for facing north: box(x0,x0,16 - h,x1,x1,16) in the order (x, y, z) with x0 = 8 - w/2 and x1 = 8 + w/2: cluster h 7 w 10 (3 to 13, z 9 to 16), large bud h 5 w 10 (z 11 to 16), medium bud h 4 w 10 (z 12 to 16), small bud h 3 w 8 (4 to 12, z 13 to 16); `rotateAll` for the other facings |
| `CandleBlock`, `CandleCakeBlock` | see 4.2 |
| `SculkSensorBlock`, `SculkShriekerBlock` collision | box(0,0,0,16,8,16) |
| `SculkVeinBlock` | per true face a sheet box(0,0,0,16,16,1) rotated to the face (`rotateAll`); union; full cube when no face is set |
| `PointedDripstoneBlock`, `SulfurSpikeBlock` | tip_merge `column(6,0,16)`; tip with `vertical_direction` up `column(6,0,11)`; tip with `vertical_direction` down `column(6,5,16)`; frustum `column(8,0,16)`; middle `column(10,0,16)`; base `column(12,0,16)`; each moved by the block offset (XZ). Read from `SpeleothemBlock$1` (TIP_MERGE 1, TIP 2, FRUSTUM 3, MIDDLE 4, BASE 5) and the `getShape` switch: case 1 selects the tip_merge shape, case 2 the tip shape (down when `vertical_direction` is down, else up), case 3 frustum, case 4 middle, case 5 base. `isCollisionShapeFullBlock` is false and `isPathfindable` false |
| `CaveVinesBlock`, `CaveVinesPlantBlock` | `column(14,0,16)` |
| `SporeBlossomBlock` | `column(12,13,16)` |
| `AzaleaBlock` | `column(16,8,16)` united with `column(4,0,8)` |
| `CarpetBlock` | `column(16,0,1)` |
| `MossyCarpetBlock` | base: box(0,0,0,16,1,16) (the y 0 to 1 sheet; it is the full-face sheet `boxZ(16, 0, 1)` taken at key down); `low` side: box(0,0,0,16,10,1) rotated (`rotateHorizontal`); `tall` side: box(0,0,0,16,16,1) rotated (`rotateAll` sheet at the side key). Mapping read from the `makeShapes` lambda and `MossyCarpetBlock$1` (NONE 1, LOW 2, TALL 3): LOW uses the height-10 map, TALL the full-height map |
| `FlowerBedBlock` (height 3) and `LeafLitterBlock` (height 1) | one quarter box(0,0,0,8,h,8) (h = 3 and 1) rotated by the horizontal key; the state shape is the single box that encloses the union of the first `n` quarters, where `n` is the amount and quarter i uses the facing rotated counter-clockwise i times (i from 0): so 1 quarter for amount 1, two adjacent quarters for 2, and so on, all enclosed in one box |
| `FrogspawnBlock` | `column(16,0,1.5)` = box(0,0,0,16,1.5,16) |
| `BigDripleafBlock` | leaf by `tilt`: none and unstable `column(16,11,15)`; partial `column(16,11,13)`; full: empty. Stem `column(6,0,13)` moved by (0, 0, 0.25 block = 4 px) and then `rotateHorizontal`. Outline = leaf shape united with the stem of the facing; collision = leaf shape only |
| `BigDripleafStemBlock` | `column(6,0,16)` moved by 4 px in z, `rotateHorizontal` |
| `SmallDripleafBlock` | `column(12,0,13)` (x and z 2 to 14, y 0 to 13) moved by the offset |
| `HangingRootsBlock` | `column(12,10,16)` moved by the offset |
| `HangingMossBlock` | tip `column(14,2,16)`; base `column(14,0,16)` |
| `FlowerBlock` (eyeblossoms) | `column(6,0,10)` moved by the offset |
| `FlowerPotBlock` | `column(6,0,6)` = box(5,0,5,11,6,11) |
| `HeavyCoreBlock` | `column(8,0,8)` = box(4,0,4,12,8,12) |
| `DecoratedPotBlock` | `column(14,0,16)` = box(1,0,1,15,16,15) |
| `MudBlock` collision | `column(16,0,14)` |
| `PowderSnowBlock` | falling-entity collision box (0,0,0,1,0.8999999761581421,1) in block units |

### 5.3 Powder snow collision

`PowderSnowBlock.getCollisionShape` is evaluated with the collision context. Read as three cases: (a) when the context is
not a placement context and the context belongs to an entity: if the entity's fall distance is greater than 2.5 the shape is
the box of 5.2 (height 0.9 block); (b) otherwise, when the entity may walk on powder snow (`canEntityWalkOnPowderSnow`, rule below) and the entity is above the block (`isAbove(full block, pos, false)`) and not descending, the shape is the
default collision shape (the full cube for a block with collision); (c) in every other case, including the placement context,
the collision shape is empty. The outline shape is the full cube (the class has `dynamicShape`).

`canEntityWalkOnPowderSnow(entity)`, read in full: true when the entity type is in entity type tag `powder_snow_walkable_mobs`
(data file `data/minecraft/tags/entity_type/powder_snow_walkable_mobs.json`: `rabbit`, `endermite`, `silverfish`, `fox`); otherwise,
when the entity is a `LivingEntity`, true exactly when the item in its feet equipment slot is `leather_boots`; otherwise false.

Constants read in `PowderSnowBlock`: falling-into threshold `NUM_BLOCKS_TO_FALL_INTO_BLOCK` 2.5 (fall distance, case (a));
`MINIMUM_FALL_DISTANCE_FOR_SOUND` 4.0 and `MINIMUM_FALL_DISTANCE_FOR_BIG_SOUND` 7.0 (fall distances for the landing sounds in `fallOn`, which
only acts on a living entity; the sound ids were not read here); `IN_BLOCK_HORIZONTAL_SPEED_MULTIPLIER` 0.9 and
`IN_BLOCK_VERTICAL_SPEED_MULTIPLIER` 1.5 (float constants; the vector actually passed is (0.8999999761581421, 1.5, 0.8999999761581421)).

`entityInside` (entity inside the block's cell): (1) when the entity is not a `LivingEntity`, or its in-block state is this block, it calls
`makeStuckInBlock(state, (0.9, 1.5, 0.9))`, the movement multiplier vector that is the powder snow slowdown (the multiplier semantics are in
entity movement code, not read here; Open question 22); (2) on a server level it then spawns `snowflake` particles through the level particle
packet (randomization type ALTERNATIVE; the count and spread values were not recorded here); (3) it applies the inside-effect types `FREEZE` and
`EXTINGUISH` through the effect applier, `EXTINGUISH` also being registered to run before the freeze effect (`runBefore`) on the server path. What each effect type does
is outside this part (see 33 and 29b by section title; not read here).

---

## 6. Light, map colour and other state-dependent functions

| Block or family | Light (0 to 15) | Notes |
|---|---|---|
| `candle`, dyed candles | 3 times `candles` when `lit`, else 0 (`CandleBlock.LIGHT_EMISSION`) | 3, 6, 9, 12 |
| candle cakes | 3 when `lit`, else 0 (`litBlockEmission(3)`) | |
| `amethyst_cluster`, `large_amethyst_bud`, `medium_amethyst_bud`, `small_amethyst_bud` | 5, 4, 2, 1 constant | |
| `sculk_sensor`, `calibrated_sculk_sensor` | 1 constant | emissive rendering when the phase is `active` |
| `sculk_catalyst` | 6 constant | |
| `cave_vines`, `cave_vines_plant` | 14 when `berries`, else 0 (`CaveVines.emission(14)`) | |
| `ochre_froglight`, `verdant_froglight`, `pearlescent_froglight` | 15 | |
| `copper_bulb` (all eight) | when `lit`: 15 (unaffected), 12 (exposed), 8 (weathered), 4 (oxidized, and its waxed twins by their state); else 0 | read: the properties function of the copper bulb in `Blocks` switches on the weather state (`Blocks$1`: UNAFFECTED 1, EXPOSED 2, WEATHERED 3, OXIDIZED 4) to the constants 15, 12, 8, 4 and passes it to `litBlockEmission`, which gives that number when `lit` is true and 0 otherwise |
| `trial_spawner` | by `trial_spawner_state`: inactive 0, waiting_for_players 4, active 8, waiting_for_reward_ejection 8, ejecting_reward 8, cooldown 0 | read: `TrialSpawnerState.lightLevel()` returns the integer argument of each enum constant (the fourth constructor argument: 0, 4, 8, 8, 8, 0 in the declaration order inactive, waiting_for_players, active, waiting_for_reward_ejection, ejecting_reward, cooldown); the block's `lightLevel` function in `Blocks` calls it |
| `vault` | by `vault_state`: inactive 6 (`HALF_LIT`), active 12, unlocking 12, ejecting 12 (`LIT`) | read: `VaultState.lightLevel()` returns the `value` of the constant's `VaultState$LightLevel`: `HALF_LIT` 6, `LIT` 12; INACTIVE is built with `HALF_LIT`, ACTIVE, UNLOCKING and EJECTING with `LIT`; the block's `lightLevel` function in `Blocks` calls it |
| `firefly_bush` | 2 constant | |
| all other blocks | 0 | |

Map colours that are not a constant in the row: dyed candles use the dye's map colour: white SNOW, orange COLOR_ORANGE,
magenta COLOR_MAGENTA, light_blue COLOR_LIGHT_BLUE, yellow COLOR_YELLOW, lime COLOR_LIGHT_GREEN, pink COLOR_PINK, gray
COLOR_GRAY, light_gray COLOR_LIGHT_GRAY, cyan COLOR_CYAN, purple COLOR_PURPLE, blue COLOR_BLUE, brown COLOR_BROWN, green
COLOR_GREEN, red COLOR_RED, black COLOR_BLACK (`DyeColor.getMapColor`, the first of the dye's two map colours; the second is
the terracotta colour). The undyed candle is SAND. The weathering copper families use, by weathering state (unaffected,
exposed, weathered, oxidized): COLOR_ORANGE, TERRACOTTA_LIGHT_GRAY, WARPED_STEM, WARPED_NYLIUM (read: the switch map `Blocks$1` numbers UNAFFECTED 1, EXPOSED 2, WEATHERED 3, OXIDIZED 4, and the map-colour function's table switch gives COLOR_ORANGE, TERRACOTTA_LIGHT_GRAY, WARPED_STEM, WARPED_NYLIUM for 1 to 4); the waxed twin has the same
colour. `pale_moss_carpet` and `pale_hanging_moss` copy the default map colour of `pale_moss_block` (COLOR_LIGHT_GRAY);
`open_eyeblossom` copies the default colour of `creaking_heart` (COLOR_ORANGE); `closed_eyeblossom` copies that of
`pale_oak_leaves` (METAL).

The copper block's instrument by weathering state: TRUMPET, TRUMPET_EXPOSED, TRUMPET_WEATHERED, TRUMPET_OXIDIZED (the instrument switch uses the same map, cases 1 to 4 in that order); the
families that copy the copper block fully (cut copper, chiseled copper, cut copper stairs and slabs) inherit those values.

---

## 7. The rows: fields 770 to 910

### 7.1 Main table

Columns as in 24-block-registry-1 §7, with the field index first, the id (a range for collection fields) and the associated item last.
For a collection field the values shown are those of the first block (unaffected, unwaxed, or white); section 7.2 and 7.3
list what varies. Light: section 6. Friction, speed and jump factors, occlusion and collision shapes, light dampening, loot table key and tool tags are rules and are given in 7.4 and 7.5, not as columns. Flags: section 1.3 and 24-block-registry-1 §7 (`validSpawn:never` and `redstoneConductor:never` and
`suffocating:never` are constant false predicates; `redstoneConductor:always`, `validSpawn:always` and `suffocating:always`
are constant true predicates, read as `Blocks.always`).

| field | id | key | class | properties | states | first state id | default id | hardness | blast res. | tool req. | light | map colour | sound | push | instrument | flags | item |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 770 | 1031 | chiseled_nether_bricks | Block | - | 1 | 26450 | 26450 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | - | item: same key |
| 771 | 1032 | cracked_nether_bricks | Block | - | 1 | 26451 | 26451 | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | - | item: same key |
| 772 | 1033 | quartz_bricks | Block | - | 1 | 26452 | 26452 | 0.8 | 0.8 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | copy-legacy:quartz_block | item: same key |
| 773 | 1034 | candle | CandleBlock | candles[1..4] lit[bool] waterlogged[bool] | 16 | 26453 | 26456 | 0.1 | 0.1 | no | 3 x candles when lit, else 0 | SAND | CANDLE | POPPED | HARP | noOcclusion | item: same key |
| 774 | 1035-1050 | {dye}_candle | CandleBlock | candles[1..4] lit[bool] waterlogged[bool] | 16 | 26469 | 26472 | 0.1 | 0.1 | no | 3 x candles when lit, else 0 | by dye | CANDLE | POPPED | HARP | noOcclusion | item: same key |
| 775 | 1051 | candle_cake | CandleCakeBlock | lit[bool] | 2 | 26725 | 26726 | 0.5 | 0.5 | no | 3 when lit, else 0 | NONE | WOOL | POPPED | HARP | forceSolidOn copy-legacy:cake | item: none |
| 776 | 1052-1067 | {dye}_candle_cake | CandleCakeBlock | lit[bool] | 2 | 26727 | 26728 | 0.5 | 0.5 | no | 3 when lit, else 0 | by dye | WOOL | POPPED | HARP | forceSolidOn copy-legacy:candle_cake | item: none |
| 777 | 1068 | amethyst_block | AmethystBlock | - | 1 | 26759 | 26759 | 1.5 | 1.5 | yes | 0 | COLOR_PURPLE | AMETHYST | PUSH_PULL | HARP | - | item: same key |
| 778 | 1069 | budding_amethyst | BuddingAmethystBlock | - | 1 | 26760 | 26760 | 1.5 | 1.5 | yes | 0 | COLOR_PURPLE | AMETHYST | POPPED | HARP | randomTicks | item: same key |
| 779 | 1070 | amethyst_cluster | AmethystClusterBlock | facing[north/east/south/west/up/down] waterlogged[bool] | 12 | 26761 | 26770 | 1.5 | 1.5 | no | 5 | COLOR_PURPLE | AMETHYST_CLUSTER | POPPED | HARP | forceSolidOn noOcclusion | item: same key |
| 780 | 1071 | large_amethyst_bud | AmethystClusterBlock | facing[north/east/south/west/up/down] waterlogged[bool] | 12 | 26773 | 26782 | 1.5 | 1.5 | no | 4 | COLOR_PURPLE | MEDIUM_AMETHYST_BUD | POPPED | HARP | forceSolidOn noOcclusion copy-legacy:amethyst_cluster | item: same key |
| 781 | 1072 | medium_amethyst_bud | AmethystClusterBlock | facing[north/east/south/west/up/down] waterlogged[bool] | 12 | 26785 | 26794 | 1.5 | 1.5 | no | 2 | COLOR_PURPLE | LARGE_AMETHYST_BUD | POPPED | HARP | forceSolidOn noOcclusion copy-legacy:amethyst_cluster | item: same key |
| 782 | 1073 | small_amethyst_bud | AmethystClusterBlock | facing[north/east/south/west/up/down] waterlogged[bool] | 12 | 26797 | 26806 | 1.5 | 1.5 | no | 1 | COLOR_PURPLE | SMALL_AMETHYST_BUD | POPPED | HARP | forceSolidOn noOcclusion copy-legacy:amethyst_cluster | item: same key |
| 783 | 1074 | tuff | Block | - | 1 | 26809 | 26809 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF | PUSH_PULL | BASEDRUM | - | item: same key |
| 784 | 1075 | tuff_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 26810 | 26813 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF | PUSH_PULL | BASEDRUM | copy-legacy:tuff viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 785 | 1076 | tuff_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 26816 | 26827 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF | PUSH_PULL | BASEDRUM | copy-legacy:tuff viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 786 | 1077 | tuff_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 26896 | 26899 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF | PUSH_PULL | BASEDRUM | copy-legacy:tuff forceSolidOn | item: same key |
| 787 | 1078 | polished_tuff | Block | - | 1 | 27220 | 27220 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | POLISHED_TUFF | PUSH_PULL | BASEDRUM | copy-legacy:tuff | item: same key |
| 788 | 1079 | polished_tuff_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 27221 | 27224 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | POLISHED_TUFF | PUSH_PULL | BASEDRUM | copy-legacy:polished_tuff viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 789 | 1080 | polished_tuff_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 27227 | 27238 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | POLISHED_TUFF | PUSH_PULL | BASEDRUM | copy-legacy:polished_tuff viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 790 | 1081 | polished_tuff_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 27307 | 27310 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | POLISHED_TUFF | PUSH_PULL | BASEDRUM | copy-legacy:polished_tuff forceSolidOn | item: same key |
| 791 | 1082 | chiseled_tuff | Block | - | 1 | 27631 | 27631 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF | PUSH_PULL | BASEDRUM | copy-legacy:tuff | item: same key |
| 792 | 1083 | tuff_bricks | Block | - | 1 | 27632 | 27632 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:tuff | item: same key |
| 793 | 1084 | tuff_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 27633 | 27636 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:tuff_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 794 | 1085 | tuff_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 27639 | 27650 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:tuff_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 795 | 1086 | tuff_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 27719 | 27722 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:tuff_bricks forceSolidOn | item: same key |
| 796 | 1087 | chiseled_tuff_bricks | Block | - | 1 | 28043 | 28043 | 1.5 | 6.0 | yes | 0 | TERRACOTTA_GRAY | TUFF_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:tuff_bricks | item: same key |
| 797 | 1088 | sulfur | Block | - | 1 | 28044 | 28044 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | - | item: same key |
| 798 | 1089 | potent_sulfur | PotentSulfurBlock | potent_sulfur_state[dry/wet/dormant/erupting/continuous] | 5 | 28045 | 28045 | 1.5 | 6.0 | yes | 0 | GOLD | POTENT_SULFUR | PUSH_PULL | BASEDRUM | copy-full:sulfur | item: same key |
| 799 | 1090 | sulfur_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 28050 | 28053 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 800 | 1091 | sulfur_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 28056 | 28067 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-full:sulfur viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 801 | 1092 | sulfur_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 28136 | 28139 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur forceSolidOn | item: same key |
| 802 | 1093 | polished_sulfur | Block | - | 1 | 28460 | 28460 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur | item: same key |
| 803 | 1094 | polished_sulfur_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 28461 | 28464 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:polished_sulfur viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 804 | 1095 | polished_sulfur_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 28467 | 28478 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-full:polished_sulfur viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 805 | 1096 | polished_sulfur_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 28547 | 28550 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:polished_sulfur forceSolidOn | item: same key |
| 806 | 1097 | sulfur_bricks | Block | - | 1 | 28871 | 28871 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur | item: same key |
| 807 | 1098 | sulfur_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 28872 | 28875 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 808 | 1099 | sulfur_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 28878 | 28889 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-full:sulfur_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 809 | 1100 | sulfur_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 28958 | 28961 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur_bricks forceSolidOn | item: same key |
| 810 | 1101 | chiseled_sulfur | Block | - | 1 | 29282 | 29282 | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | SULFUR | PUSH_PULL | BASEDRUM | copy-legacy:sulfur | item: same key |
| 811 | 1102 | cinnabar | Block | - | 1 | 29283 | 29283 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | - | item: same key |
| 812 | 1103 | cinnabar_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 29284 | 29287 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 813 | 1104 | cinnabar_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 29290 | 29301 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-full:cinnabar viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 814 | 1105 | cinnabar_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 29370 | 29373 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar forceSolidOn | item: same key |
| 815 | 1106 | polished_cinnabar | Block | - | 1 | 29694 | 29694 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar | item: same key |
| 816 | 1107 | polished_cinnabar_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 29695 | 29698 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:polished_cinnabar viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 817 | 1108 | polished_cinnabar_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 29701 | 29712 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-full:polished_cinnabar viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 818 | 1109 | polished_cinnabar_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 29781 | 29784 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:polished_cinnabar forceSolidOn | item: same key |
| 819 | 1110 | cinnabar_bricks | Block | - | 1 | 30105 | 30105 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar | item: same key |
| 820 | 1111 | cinnabar_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 30106 | 30109 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 821 | 1112 | cinnabar_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 30112 | 30123 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-full:cinnabar_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 822 | 1113 | cinnabar_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 30192 | 30195 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar_bricks forceSolidOn | item: same key |
| 823 | 1114 | chiseled_cinnabar | Block | - | 1 | 30516 | 30516 | 1.5 | 6.0 | yes | 0 | COLOR_RED | CINNABAR | PUSH_PULL | BASEDRUM | copy-legacy:cinnabar | item: same key |
| 824 | 1115 | calcite | Block | - | 1 | 30517 | 30517 | 0.75 | 0.75 | yes | 0 | TERRACOTTA_WHITE | CALCITE | PUSH_PULL | BASEDRUM | - | item: same key |
| 825 | 1116 | tinted_glass | TintedGlassBlock | - | 1 | 30518 | 30518 | 0.3 | 0.3 | no | 0 | COLOR_GRAY | GLASS | PUSH_PULL | HAT | noOcclusion copy-legacy:glass validSpawn:never redstoneConductor:never suffocating:never | item: same key |
| 826 | 1117 | powder_snow | PowderSnowBlock | - | 1 | 30519 | 30519 | 0.25 | 0.25 | no | 0 | SNOW | POWDER_SNOW | PUSH_PULL | HARP | dynamicShape noOcclusion redstoneConductor:never | item: powder_snow_bucket |
| 827 | 1118 | sculk_sensor | SculkSensorBlock | power[0..15] sculk_sensor_phase[inactive/active/cooldown] waterlogged[bool] | 96 | 30520 | 30521 | 1.5 | 1.5 | no | 1 | COLOR_CYAN | SCULK_SENSOR | PUSH_PULL | HARP | emissive(active phase) | item: same key |
| 828 | 1119 | calibrated_sculk_sensor | CalibratedSculkSensorBlock | facing[north/south/west/east] power[0..15] sculk_sensor_phase[inactive/active/cooldown] waterlogged[bool] | 384 | 30616 | 30617 | 1.5 | 1.5 | no | 1 | COLOR_CYAN | SCULK_SENSOR | PUSH_PULL | HARP | emissive(active phase) copy-legacy:sculk_sensor | item: same key |
| 829 | 1120 | sculk | SculkBlock | - | 1 | 31000 | 31000 | 0.2 | 0.2 | no | 0 | COLOR_BLACK | SCULK | PUSH_PULL | HARP | - | item: same key |
| 830 | 1121 | sculk_vein | SculkVeinBlock | down[bool] east[bool] north[bool] south[bool] up[bool] waterlogged[bool] west[bool] | 128 | 31001 | 31128 | 0.2 | 0.2 | no | 0 | COLOR_BLACK | SCULK_VEIN | POPPED | HARP | forceSolidOn noCollision noOcclusion | item: same key |
| 831 | 1122 | sculk_catalyst | SculkCatalystBlock | bloom[bool] | 2 | 31129 | 31130 | 3.0 | 3.0 | no | 6 | COLOR_BLACK | SCULK_CATALYST | PUSH_PULL | HARP | - | item: same key |
| 832 | 1123 | sculk_shrieker | SculkShriekerBlock | can_summon[bool] shrieking[bool] waterlogged[bool] | 8 | 31131 | 31138 | 3.0 | 3.0 | no | 0 | COLOR_BLACK | SCULK_SHRIEKER | PUSH_PULL | HARP | - | item: same key |
| 833 | 1124-1131 | copper_block (+7, section 7.3) | WeatheringCopperFullBlock / waxed Block | - | 1 | 31139 | 31139 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | TRUMPET | - | item: same key |
| 834 | 1132 | copper_ore | DropExperienceBlock | - | 1 | 31147 | 31147 | 3.0 | 3.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | copy-legacy:iron_ore | item: same key |
| 835 | 1133 | deepslate_copper_ore | DropExperienceBlock | - | 1 | 31148 | 31148 | 4.5 | 3.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:copper_ore | item: same key |
| 836 | 1134-1141 | cut_copper (+7, section 7.3) | WeatheringCopperFullBlock / waxed Block | - | 1 | 31149 | 31149 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | TRUMPET | copy-full:copper_block | item: same key |
| 837 | 1142-1149 | chiseled_copper (+7, section 7.3) | WeatheringCopperFullBlock / waxed Block | - | 1 | 31157 | 31157 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | TRUMPET | copy-full:copper_block | item: same key |
| 838 | 1150-1157 | cut_copper_stairs (+7, section 7.3) | WeatheringCopperStairBlock / waxed StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 31165 | 31176 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | TRUMPET | copy-full:cut_copper viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 839 | 1158-1165 | cut_copper_slab (+7, section 7.3) | WeatheringCopperSlabBlock / waxed SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 31805 | 31808 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | TRUMPET | copy-full:cut_copper viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 840 | 1166-1173 | copper_door (+7, section 7.3) | WeatheringCopperDoorBlock / waxed DoorBlock | facing[north/south/west/east] half[upper/lower] hinge[left/right] open[bool] powered[bool] | 64 | 31853 | 31864 | 3.0 | 6.0 | no | 0 | COLOR_ORANGE | COPPER (BlockSetType.COPPER) | POPPED | HARP | noOcclusion | item: same key |
| 841 | 1174-1181 | copper_trapdoor (+7, section 7.3) | WeatheringCopperTrapDoorBlock / waxed TrapDoorBlock | facing[north/south/west/east] half[top/bottom] open[bool] powered[bool] waterlogged[bool] | 64 | 32365 | 32380 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER (BlockSetType.COPPER) | PUSH_PULL | HARP | noOcclusion validSpawn:never | item: same key |
| 842 | 1182-1189 | copper_grate (+7, section 7.3) | WeatheringCopperGrateBlock / waxed WaterloggedTransparentBlock | waterlogged[bool] | 2 | 32877 | 32878 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER_GRATE | PUSH_PULL | HARP | noOcclusion validSpawn:never redstoneConductor:never suffocating:never | item: same key |
| 843 | 1190-1197 | copper_bulb (+7, section 7.3) | WeatheringCopperBulbBlock / waxed CopperBulbBlock | lit[bool] powered[bool] | 4 | 32893 | 32896 | 3.0 | 6.0 | yes | when lit: 15,12,8,4 by weathering; else 0 | COLOR_ORANGE | COPPER_BULB | PUSH_PULL | HARP | redstoneConductor:never | item: same key |
| 844 | 1198-1205 | copper_chest (+7, section 7.3) | WeatheringCopperChestBlock / waxed CopperChestBlock | facing[north/south/west/east] type[single/left/right] waterlogged[bool] | 24 | 32925 | 32926 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | HARP | - | item: same key |
| 845 | 1206-1213 | copper_golem_statue (+7, section 7.3) | WeatheringCopperGolemStatueBlock / waxed CopperGolemStatueBlock | copper_golem_pose[standing/sitting/running/star] facing[north/south/west/east] waterlogged[bool] | 32 | 33117 | 33118 | 3.0 | 6.0 | no | 0 | COLOR_ORANGE | COPPER_GOLEM_STATUE | POPPED | HARP | noOcclusion | item: same key |
| 846 | 1214-1221 | lightning_rod (+7, section 7.3) | WeatheringLightningRodBlock / waxed LightningRodBlock | facing[north/east/south/west/up/down] powered[bool] waterlogged[bool] | 24 | 33373 | 33392 | 3.0 | 6.0 | yes | 0 | COLOR_ORANGE | COPPER | PUSH_PULL | HARP | forceSolidOn noOcclusion | item: same key |
| 847 | 1222 | dripstone_block | Block | - | 1 | 33565 | 33565 | 1.5 | 1.0 | yes | 0 | TERRACOTTA_BROWN | DRIPSTONE_BLOCK | PUSH_PULL | BASEDRUM | - | item: same key |
| 848 | 1223 | pointed_dripstone | PointedDripstoneBlock | thickness[tip_merge/tip/frustum/middle/base] vertical_direction[up/down] waterlogged[bool] | 20 | 33566 | 33571 | 1.5 | 3.0 | no | 0 | TERRACOTTA_BROWN | POINTED_DRIPSTONE | POPPED | BASEDRUM | forceSolidOn noOcclusion randomTicks dynamicShape offset:XZ redstoneConductor:never | item: same key |
| 849 | 1224 | sulfur_spike | SulfurSpikeBlock | thickness[tip_merge/tip/frustum/middle/base] vertical_direction[up/down] waterlogged[bool] | 20 | 33586 | 33591 | 1.5 | 3.0 | no | 0 | COLOR_YELLOW | SULFUR_SPIKE | POPPED | BASEDRUM | forceSolidOn noOcclusion randomTicks dynamicShape offset:XZ redstoneConductor:never | item: same key |
| 850 | 1225 | cave_vines | CaveVinesBlock | age[0..25] berries[bool] | 52 | 33606 | 33607 | 0.0 | 0.0 | no | 14 when berries, else 0 | PLANT | CAVE_VINES | POPPED | HARP | randomTicks noCollision noOcclusion | item: glow_berries |
| 851 | 1226 | cave_vines_plant | CaveVinesPlantBlock | berries[bool] | 2 | 33658 | 33659 | 0.0 | 0.0 | no | 14 when berries, else 0 | PLANT | CAVE_VINES | POPPED | HARP | noCollision noOcclusion | item: none |
| 852 | 1227 | spore_blossom | SporeBlossomBlock | - | 1 | 33660 | 33660 | 0.0 | 0.0 | no | 0 | PLANT | SPORE_BLOSSOM | POPPED | HARP | noCollision noOcclusion | item: same key |
| 853 | 1228 | azalea | AzaleaBlock | - | 1 | 33661 | 33661 | 0.0 | 0.0 | no | 0 | PLANT | AZALEA | POPPED | HARP | forceSolidOff noOcclusion | item: same key |
| 854 | 1229 | flowering_azalea | AzaleaBlock | - | 1 | 33662 | 33662 | 0.0 | 0.0 | no | 0 | PLANT | FLOWERING_AZALEA | POPPED | HARP | forceSolidOff noOcclusion | item: same key |
| 855 | 1230 | moss_carpet | CarpetBlock | - | 1 | 33663 | 33663 | 0.1 | 0.1 | no | 0 | COLOR_GREEN | MOSS_CARPET | POPPED | HARP | - | item: same key |
| 856 | 1231 | pink_petals | FlowerBedBlock | facing[north/south/west/east] flower_amount[1..4] | 16 | 33664 | 33664 | 0.0 | 0.0 | no | 0 | PLANT | PINK_PETALS | POPPED | HARP | noCollision noOcclusion | item: same key |
| 857 | 1232 | wildflowers | FlowerBedBlock | facing[north/south/west/east] flower_amount[1..4] | 16 | 33680 | 33680 | 0.0 | 0.0 | no | 0 | PLANT | PINK_PETALS | POPPED | HARP | noCollision noOcclusion | item: same key |
| 858 | 1233 | leaf_litter | LeafLitterBlock | facing[north/south/west/east] segment_amount[1..4] | 16 | 33696 | 33696 | 0.0 | 0.0 | no | 0 | COLOR_BROWN | LEAF_LITTER | POPPED | HARP | replaceable noCollision noOcclusion | item: same key |
| 859 | 1234 | moss_block | BonemealableFeaturePlacerBlock | - | 1 | 33712 | 33712 | 0.1 | 0.1 | no | 0 | COLOR_GREEN | MOSS | POPPED | HARP | - | item: same key |
| 860 | 1235 | big_dripleaf | BigDripleafBlock | facing[north/south/west/east] tilt[none/unstable/partial/full] waterlogged[bool] | 32 | 33713 | 33714 | 0.1 | 0.1 | no | 0 | PLANT | BIG_DRIPLEAF | POPPED | HARP | forceSolidOff | item: same key |
| 861 | 1236 | big_dripleaf_stem | BigDripleafStemBlock | facing[north/south/west/east] waterlogged[bool] | 8 | 33745 | 33746 | 0.1 | 0.1 | no | 0 | PLANT | BIG_DRIPLEAF | POPPED | HARP | noCollision noOcclusion | item: none |
| 862 | 1237 | small_dripleaf | SmallDripleafBlock | facing[north/south/west/east] half[upper/lower] waterlogged[bool] | 16 | 33753 | 33756 | 0.0 | 0.0 | no | 0 | PLANT | SMALL_DRIPLEAF | POPPED | HARP | noCollision noOcclusion offset:XYZ | item: same key |
| 863 | 1238 | hanging_roots | HangingRootsBlock | waterlogged[bool] | 2 | 33769 | 33770 | 0.0 | 0.0 | no | 0 | DIRT | HANGING_ROOTS | POPPED | HARP | replaceable noCollision noOcclusion offset:XZ ignitedByLava | item: same key |
| 864 | 1239 | rooted_dirt | RootedDirtBlock | - | 1 | 33771 | 33771 | 0.5 | 0.5 | no | 0 | DIRT | ROOTED_DIRT | PUSH_PULL | HARP | - | item: same key |
| 865 | 1240 | mud | MudBlock | - | 1 | 33772 | 33772 | 0.5 | 0.5 | no | 0 | TERRACOTTA_CYAN | MUD | PUSH_PULL | HARP | copy-legacy:dirt validSpawn:always redstoneConductor:always suffocating:always | item: same key |
| 866 | 1241 | deepslate | RotatedPillarBlock | axis[x/y/z] | 3 | 33773 | 33774 | 3.0 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | - | item: same key |
| 867 | 1242 | cobbled_deepslate | Block | - | 1 | 33776 | 33776 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:deepslate | item: same key |
| 868 | 1243 | cobbled_deepslate_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 33777 | 33788 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 869 | 1244 | cobbled_deepslate_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 33857 | 33860 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 870 | 1245 | cobbled_deepslate_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 33863 | 33866 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate forceSolidOn | item: same key |
| 871 | 1246 | polished_deepslate | Block | - | 1 | 34187 | 34187 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | POLISHED_DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate | item: same key |
| 872 | 1247 | polished_deepslate_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 34188 | 34199 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | POLISHED_DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:polished_deepslate viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 873 | 1248 | polished_deepslate_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 34268 | 34271 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | POLISHED_DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:polished_deepslate viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 874 | 1249 | polished_deepslate_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 34274 | 34277 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | POLISHED_DEEPSLATE | PUSH_PULL | BASEDRUM | copy-legacy:polished_deepslate forceSolidOn | item: same key |
| 875 | 1250 | deepslate_tiles | Block | - | 1 | 34598 | 34598 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_TILES | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate | item: same key |
| 876 | 1251 | deepslate_tile_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 34599 | 34610 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_TILES | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_tiles viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 877 | 1252 | deepslate_tile_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 34679 | 34682 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_TILES | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_tiles viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 878 | 1253 | deepslate_tile_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 34685 | 34688 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_TILES | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_tiles forceSolidOn | item: same key |
| 879 | 1254 | deepslate_bricks | Block | - | 1 | 35009 | 35009 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate | item: same key |
| 880 | 1255 | deepslate_brick_stairs | StairBlock | facing[north/south/west/east] half[top/bottom] shape[straight/inner_left/inner_right/outer_left/outer_right] waterlogged[bool] | 80 | 35010 | 35021 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 881 | 1256 | deepslate_brick_slab | SlabBlock | type[top/bottom/double] waterlogged[bool] | 6 | 35090 | 35093 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_bricks viewBlocking:nearPlaneIntersectsOutline | item: same key |
| 882 | 1257 | deepslate_brick_wall | WallBlock | east[none/low/tall] north[none/low/tall] south[none/low/tall] up[bool] waterlogged[bool] west[none/low/tall] | 324 | 35096 | 35099 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_bricks forceSolidOn | item: same key |
| 883 | 1258 | chiseled_deepslate | Block | - | 1 | 35420 | 35420 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:cobbled_deepslate | item: same key |
| 884 | 1259 | cracked_deepslate_bricks | Block | - | 1 | 35421 | 35421 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_BRICKS | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_bricks | item: same key |
| 885 | 1260 | cracked_deepslate_tiles | Block | - | 1 | 35422 | 35422 | 3.5 | 6.0 | yes | 0 | DEEPSLATE | DEEPSLATE_TILES | PUSH_PULL | BASEDRUM | copy-legacy:deepslate_tiles | item: same key |
| 886 | 1261 | infested_deepslate | InfestedRotatedPillarBlock | axis[x/y/z] | 3 | 35423 | 35424 | 1.5 | 0.75 | no | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | HARP | - | item: same key. Hardness and blast resistance come from the `InfestedBlock` constructor (4.1), not from a builder `strength` call |
| 887 | 1262 | smooth_basalt | Block | - | 1 | 35426 | 35426 | 1.25 | 4.2 | yes | 0 | COLOR_BLACK | BASALT | PUSH_PULL | BASEDRUM | copy-legacy:basalt | item: same key |
| 888 | 1263 | raw_iron_block | Block | - | 1 | 35427 | 35427 | 5.0 | 6.0 | yes | 0 | RAW_IRON | STONE | PUSH_PULL | BASEDRUM | - | item: same key |
| 889 | 1264 | raw_copper_block | Block | - | 1 | 35428 | 35428 | 5.0 | 6.0 | yes | 0 | COLOR_ORANGE | STONE | PUSH_PULL | BASEDRUM | - | item: same key |
| 890 | 1265 | raw_gold_block | Block | - | 1 | 35429 | 35429 | 5.0 | 6.0 | yes | 0 | GOLD | STONE | PUSH_PULL | BASEDRUM | - | item: same key |
| 891 | 1266 | potted_azalea_bush | FlowerPotBlock | - | 1 | 35430 | 35430 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion | item: none |
| 892 | 1267 | potted_flowering_azalea_bush | FlowerPotBlock | - | 1 | 35431 | 35431 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion | item: none |
| 893 | 1268 | ochre_froglight | RotatedPillarBlock | axis[x/y/z] | 3 | 35432 | 35433 | 0.3 | 0.3 | no | 15 | SAND | FROGLIGHT | PUSH_PULL | HARP | - | item: same key |
| 894 | 1269 | verdant_froglight | RotatedPillarBlock | axis[x/y/z] | 3 | 35435 | 35436 | 0.3 | 0.3 | no | 15 | GLOW_LICHEN | FROGLIGHT | PUSH_PULL | HARP | - | item: same key |
| 895 | 1270 | pearlescent_froglight | RotatedPillarBlock | axis[x/y/z] | 3 | 35438 | 35439 | 0.3 | 0.3 | no | 15 | COLOR_PINK | FROGLIGHT | PUSH_PULL | HARP | - | item: same key |
| 896 | 1271 | frogspawn | FrogspawnBlock | - | 1 | 35441 | 35441 | 0.0 | 0.0 | no | 0 | WATER | FROGSPAWN | POPPED | HARP | noOcclusion noCollision | item: same key |
| 897 | 1272 | reinforced_deepslate | Block | - | 1 | 35442 | 35442 | 55.0 | 1200.0 | no | 0 | DEEPSLATE | DEEPSLATE | IMMOVEABLE | BASEDRUM | - | item: same key |
| 898 | 1273 | decorated_pot | DecoratedPotBlock | cracked[bool] facing[north/south/west/east] waterlogged[bool] | 16 | 35443 | 35452 | 0.0 | 0.0 | no | 0 | TERRACOTTA_RED | STONE | POPPED | HARP | noOcclusion | item: same key |
| 899 | 1274 | crafter | CrafterBlock | crafting[bool] orientation[down_east/down_north/down_south/down_west/up_east/up_north/up_south/up_west/west_up/east_up/north_up/south_up] triggered[bool] | 48 | 35459 | 35504 | 1.5 | 3.5 | no | 0 | STONE | STONE | PUSH_PULL | HARP | - | item: same key |
| 900 | 1275 | trial_spawner | TrialSpawnerBlock | ominous[bool] trial_spawner_state[inactive/waiting_for_players/active/waiting_for_reward_ejection/ejecting_reward/cooldown] | 12 | 35507 | 35513 | 50.0 | 50.0 | no | by state: 0,4,8,8,8,0 | STONE | TRIAL_SPAWNER | PUSH_PULL | BASEDRUM | noOcclusion | item: same key |
| 901 | 1276 | vault | VaultBlock | facing[north/south/west/east] ominous[bool] vault_state[inactive/active/unlocking/ejecting] | 32 | 35519 | 35523 | 50.0 | 50.0 | no | by state: 6,12,12,12 | STONE | VAULT | PUSH_PULL | BASEDRUM | noOcclusion | item: same key |
| 902 | 1277 | heavy_core | HeavyCoreBlock | waterlogged[bool] | 2 | 35551 | 35552 | 10.0 | 1200.0 | no | 0 | METAL | HEAVY_CORE | PUSH_PULL | SNARE | - | item: same key |
| 903 | 1278 | pale_moss_block | BonemealableFeaturePlacerBlock | - | 1 | 35553 | 35553 | 0.1 | 0.1 | no | 0 | COLOR_LIGHT_GRAY | MOSS | POPPED | HARP | ignitedByLava | item: same key |
| 904 | 1279 | pale_moss_carpet | MossyCarpetBlock | bottom[bool] east[none/low/tall] north[none/low/tall] south[none/low/tall] west[none/low/tall] | 162 | 35554 | 35554 | 0.1 | 0.1 | no | 0 | COLOR_LIGHT_GRAY | MOSS_CARPET | POPPED | HARP | ignitedByLava noOcclusion | item: same key |
| 905 | 1280 | pale_hanging_moss | HangingMossBlock | tip[bool] | 2 | 35716 | 35716 | 0.0 | 0.0 | no | 0 | COLOR_LIGHT_GRAY | MOSS_CARPET | POPPED | HARP | ignitedByLava noCollision noOcclusion | item: same key |
| 906 | 1281 | open_eyeblossom | EyeblossomBlock | - | 1 | 35718 | 35718 | 0.0 | 0.0 | no | 0 | COLOR_ORANGE | GRASS | POPPED | HARP | noCollision noOcclusion offset:XZ randomTicks | item: same key |
| 907 | 1282 | closed_eyeblossom | EyeblossomBlock | - | 1 | 35719 | 35719 | 0.0 | 0.0 | no | 0 | METAL | GRASS | POPPED | HARP | noCollision noOcclusion offset:XZ randomTicks | item: same key |
| 908 | 1283 | potted_open_eyeblossom | FlowerPotBlock | - | 1 | 35720 | 35720 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion randomTicks | item: none |
| 909 | 1284 | potted_closed_eyeblossom | FlowerPotBlock | - | 1 | 35721 | 35721 | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion randomTicks | item: none |
| 910 | 1285 | firefly_bush | FireflyBushBlock | - | 1 | 35722 | 35722 | 0.0 | 0.0 | no | 2 | PLANT | SWEET_BERRY_BUSH | POPPED | HARP | ignitedByLava noCollision noOcclusion | item: same key |

Notes on individual fields:

- Fields 840 and 841 (copper door and trapdoor): the builder chain has no `sound` call; the class constructor installs the sound
  type of `BlockSetType.COPPER`, which is `SoundType.COPPER`. The door's builder chain also has no `requiresCorrectToolForDrops`
  (the trapdoor has it): what the artifact does, recorded as read. The loot table `data/minecraft/loot_table/blocks/copper_door.json` has one entry with only a `match_block` condition (block `copper_door`, state `half=lower`) and `survives_explosion` on the pool, with no tool or enchantment condition: the lower half drops the door item with any tool or by hand (Open question 10, closed). The `copper_golem_statue` loot table likewise has no tool condition; it copies `custom_name` from the block entity and the `copper_golem_pose` state property.
- Field 825 (`tinted_glass`): `ofLegacyCopy(GLASS)` then map colour COLOR_GRAY and the four overrides in the flags. Its
  instrument is the glass instrument HAT. The class also overrides skylight and light dampening (4.1).
- Field 826 (`powder_snow`): `dynamicShape`, so no shape cache is built; the class overrides the collision shape (5.3).
- Field 848 and 849 (pointed dripstone, sulfur spike): `offset:XZ` with `dynamicShape`; the builder lists `noOcclusion` twice.
- Field 865 (`mud`): `ofLegacyCopy(DIRT)` then map colour TERRACOTTA_CYAN, the three constant-true predicates, and sound MUD.
- Field 897 (`reinforced_deepslate`): hardness 55, blast resistance 1200, `IMMOVEABLE`, tool not required in the builder.
- Field 898 (`decorated_pot`): `strength(0, 0)` with int constants, hardness and resistance 0; `noOcclusion`, `POPPED`.
- Field 902 (`heavy_core`): `pushReaction(PUSH_PULL)` is set explicitly; `explosionResistance(1200)` follows `strength(10)`, which
  sets 10 first, so the blast resistance is 1200.
- Fields 891, 892, 908 and 909 (potted azaleas and eyeblossoms): `flowerPotProperties()` is instabreak, `noOcclusion`, `POPPED`;
  no map colour call, so the colour is NONE. The two eyeblossom pots add `randomTicks`.
- Fields 906 and 907: `offset:XZ` and `randomTicks`.
- Field 850 (`cave_vines`): the block key is `cave_vines` and the item key is `glow_berries` (the id used in the
  initialiser is `BlockItemIds.GLOW_BERRY_CROP`).
- Fields 780 to 782: the sounds of the large and medium buds are as read: the large bud uses `MEDIUM_AMETHYST_BUD`, the medium bud
  uses `LARGE_AMETHYST_BUD` (the artifact swaps them).

### 7.2 Candles and candle cakes by dye

Dyed candle (field 774) and dyed candle cake (field 776), white first. For every dye the state counts and defaults are
those of the first rows (candle: 16 states, default offset 3; cake: 2 states, default offset 1). Map colour of the
candle: the dye's colour; the cake has colour NONE.

| dye | candle id | candle first state | cake id | cake first state | candle map colour |
|---|---|---|---|---|---|
| white | 1035 | 26469 | 1052 | 26727 | SNOW |
| orange | 1036 | 26485 | 1053 | 26729 | COLOR_ORANGE |
| magenta | 1037 | 26501 | 1054 | 26731 | COLOR_MAGENTA |
| light_blue | 1038 | 26517 | 1055 | 26733 | COLOR_LIGHT_BLUE |
| yellow | 1039 | 26533 | 1056 | 26735 | COLOR_YELLOW |
| lime | 1040 | 26549 | 1057 | 26737 | COLOR_LIGHT_GREEN |
| pink | 1041 | 26565 | 1058 | 26739 | COLOR_PINK |
| gray | 1042 | 26581 | 1059 | 26741 | COLOR_GRAY |
| light_gray | 1043 | 26597 | 1060 | 26743 | COLOR_LIGHT_GRAY |
| cyan | 1044 | 26613 | 1061 | 26745 | COLOR_CYAN |
| purple | 1045 | 26629 | 1062 | 26747 | COLOR_PURPLE |
| blue | 1046 | 26645 | 1063 | 26749 | COLOR_BLUE |
| brown | 1047 | 26661 | 1064 | 26751 | COLOR_BROWN |
| green | 1048 | 26677 | 1065 | 26753 | COLOR_GREEN |
| red | 1049 | 26693 | 1066 | 26755 | COLOR_RED |
| black | 1050 | 26709 | 1067 | 26757 | COLOR_BLACK |

### 7.3 Weathering copper families

For each family the registration order is: the four weathering blocks, then the four waxed ones (section 2.3). All eight
blocks of a family have the same property list and state count. Key patterns: weathering `<prefix><base>`; waxed
`waxed_<prefix><base>`. Per-block ids and first state ids are in the second table.

| field | ids | keys of the four weathering blocks | weathering class | waxed class | states per block | first state id of the first block | default offset in the block |
|---|---|---|---|---|---|---|---|
| 833 | 1124-1131 | copper_block, exposed_copper, weathered_copper, oxidized_copper | WeatheringCopperFullBlock | Block | 1 | 31139 | 0 |
| 836 | 1134-1141 | cut_copper, exposed_cut_copper, weathered_cut_copper, oxidized_cut_copper | WeatheringCopperFullBlock | Block | 1 | 31149 | 0 |
| 837 | 1142-1149 | chiseled_copper, exposed_chiseled_copper, weathered_chiseled_copper, oxidized_chiseled_copper | WeatheringCopperFullBlock | Block | 1 | 31157 | 0 |
| 838 | 1150-1157 | cut_copper_stairs, exposed_cut_copper_stairs, weathered_cut_copper_stairs, oxidized_cut_copper_stairs | WeatheringCopperStairBlock | StairBlock | 80 | 31165 | 11 |
| 839 | 1158-1165 | cut_copper_slab, exposed_cut_copper_slab, weathered_cut_copper_slab, oxidized_cut_copper_slab | WeatheringCopperSlabBlock | SlabBlock | 6 | 31805 | 3 |
| 840 | 1166-1173 | copper_door, exposed_copper_door, weathered_copper_door, oxidized_copper_door | WeatheringCopperDoorBlock | DoorBlock | 64 | 31853 | 11 |
| 841 | 1174-1181 | copper_trapdoor, exposed_copper_trapdoor, weathered_copper_trapdoor, oxidized_copper_trapdoor | WeatheringCopperTrapDoorBlock | TrapDoorBlock | 64 | 32365 | 15 |
| 842 | 1182-1189 | copper_grate, exposed_copper_grate, weathered_copper_grate, oxidized_copper_grate | WeatheringCopperGrateBlock | WaterloggedTransparentBlock | 2 | 32877 | 1 |
| 843 | 1190-1197 | copper_bulb, exposed_copper_bulb, weathered_copper_bulb, oxidized_copper_bulb | WeatheringCopperBulbBlock | CopperBulbBlock | 4 | 32893 | 3 |
| 844 | 1198-1205 | copper_chest, exposed_copper_chest, weathered_copper_chest, oxidized_copper_chest | WeatheringCopperChestBlock | CopperChestBlock | 24 | 32925 | 1 |
| 845 | 1206-1213 | copper_golem_statue, exposed_copper_golem_statue, weathered_copper_golem_statue, oxidized_copper_golem_statue | WeatheringCopperGolemStatueBlock | CopperGolemStatueBlock | 32 | 33117 | 1 |
| 846 | 1214-1221 | lightning_rod, exposed_lightning_rod, weathered_lightning_rod, oxidized_lightning_rod | WeatheringLightningRodBlock | LightningRodBlock | 24 | 33373 | 19 |

Values that vary with the weathering state: the map colour (section 6) in every family; the copper block's instrument
(section 6) and its copies; the copper bulb's light (section 6). Everything else in the row (hardness 3.0 and blast
resistance 6.0 for all twelve families; tool required as in the main table; sound as in the main table) is the same for the
four states and for the waxed twins.

Per-block ids and first state ids (`id:first state id`), in registration order:

| field | blocks |
|---|---|
| 833 | 1124:31139, 1125:31140, 1126:31141, 1127:31142, 1128:31143, 1129:31144, 1130:31145, 1131:31146 |
| 836 | 1134:31149, 1135:31150, 1136:31151, 1137:31152, 1138:31153, 1139:31154, 1140:31155, 1141:31156 |
| 837 | 1142:31157, 1143:31158, 1144:31159, 1145:31160, 1146:31161, 1147:31162, 1148:31163, 1149:31164 |
| 838 | 1150:31165, 1151:31245, 1152:31325, 1153:31405, 1154:31485, 1155:31565, 1156:31645, 1157:31725 |
| 839 | 1158:31805, 1159:31811, 1160:31817, 1161:31823, 1162:31829, 1163:31835, 1164:31841, 1165:31847 |
| 840 | 1166:31853, 1167:31917, 1168:31981, 1169:32045, 1170:32109, 1171:32173, 1172:32237, 1173:32301 |
| 841 | 1174:32365, 1175:32429, 1176:32493, 1177:32557, 1178:32621, 1179:32685, 1180:32749, 1181:32813 |
| 842 | 1182:32877, 1183:32879, 1184:32881, 1185:32883, 1186:32885, 1187:32887, 1188:32889, 1189:32891 |
| 843 | 1190:32893, 1191:32897, 1192:32901, 1193:32905, 1194:32909, 1195:32913, 1196:32917, 1197:32921 |
| 844 | 1198:32925, 1199:32949, 1200:32973, 1201:32997, 1202:33021, 1203:33045, 1204:33069, 1205:33093 |
| 845 | 1206:33117, 1207:33149, 1208:33181, 1209:33213, 1210:33245, 1211:33277, 1212:33309, 1213:33341 |
| 846 | 1214:33373, 1215:33397, 1216:33421, 1217:33445, 1218:33469, 1219:33493, 1220:33517, 1221:33541 |

Properties of the copper families (the main table shows the first block): copper block, cut copper, chiseled copper: none;
cut copper stairs: stair properties; cut copper slab: slab properties; door: door properties; trapdoor: trapdoor properties;
grate: `waterlogged`; bulb: `lit`, `powered`; chest: `facing`, `type`, `waterlogged`; golem statue: `copper_golem_pose`,
`facing`, `waterlogged`; lightning rod: `facing`, `powered`, `waterlogged`.

### 7.4 Friction, speed factor, jump factor, occlusion shape, collision shape and light dampening

Rules, read from `BlockBehaviour`, `BlockBehaviour$BlockStateBase.initCache` and the class overrides (each class chain was scanned for overrides of
`getOcclusionShape`, `getCollisionShape`, `getShape`, `getBlockSupportShape`, `propagatesSkylightDown`, `useShapeForLightOcclusion` and `getLightDampening`):

1. Friction, speed factor, jump factor: 0.6, 1.0, 1.0 for all 255 blocks of this range; read these as three constant columns that apply to every row of 7.1 to 7.3 (all rows: friction 0.6, speed factor 1.0, jump factor 1.0). No builder chain of this range, and no source block of a copy (cobbled deepslate, tuff,
   sulfur, cinnabar, deepslate variants, amethyst cluster, quartz block, iron ore, glass, dirt, basalt, copper ore, cake, candle cake, sculk sensor, copper block, cut copper),
   calls `friction`, `speedFactor` or `jumpFactor`; the only such calls in `Blocks` are for ice, soul sand, slime, honey, packed ice, frosted ice, blue ice and none in the id range of
   this part. Mud and powder snow have no such call either, so their entity slowdown is not in these properties. Powder snow's slowdown is in `PowderSnowBlock.entityInside`: `makeStuckInBlock` with the movement multiplier (0.9, 1.5, 0.9) (5.3). Mud's slowdown, if any, was not found in the `MudBlock` class members read here (Open question 22).
2. Outline (`getShape`): the full cube unless the class says otherwise (sections 4 and 5.2). Collision (`getCollisionShape`): the outline when `hasCollision`, else empty; classes that
   override it: `WallBlock` (height 24), `MudBlock` (`column(16,0,14)`), `PowderSnowBlock` (5.3), `SculkShriekerBlock` (half-height box), `BigDripleafBlock` (leaf only) and
   `MossyCarpetBlock` (base slab when `bottom`, else empty). Rows with `noCollision` have an empty collision shape. Block support shape: the collision shape, except `MudBlock` (full cube).
3. Occlusion shape: empty when `canOcclude` is false (flag `noOcclusion`, explicit or implied by `noCollision`); otherwise `getOcclusionShape(state)`, which is by default the outline evaluated at the
   origin; the only override in this range is `SculkShriekerBlock` (the half-height box). `solidRender` is true when the occlusion shape is the full cube.
4. Light dampening (`getLightDampening`; the engine that consumes it is 32 section 7): 15 when `solidRender`; otherwise 0 when `propagatesSkylightDown` and 1 when not. The only override in this range is `TintedGlassBlock` (15, and
   `propagatesSkylightDown` false). The default `propagatesSkylightDown` is true when the outline is not the full cube and the state's fluid is empty; the overrides are
   `TransparentBlock` (true; parent of the copper grate classes), `TintedGlassBlock` (false), `VegetationBlock` (the fluid is empty), `WallBlock` (not waterlogged),
   `MossyCarpetBlock` (true) and `HangingMossBlock` (true).

Result by family:

| Family | Occlusion shape | Light dampening |
|---|---|---|
| Plain full-cube classes without `noOcclusion` (`Block`, `DropExperienceBlock`, `RotatedPillarBlock`, `InfestedRotatedPillarBlock`, `AmethystBlock`, `BuddingAmethystBlock`, `SculkBlock`, `SculkCatalystBlock`, `RootedDirtBlock`, `BonemealableFeaturePlacerBlock`, `CopperBulbBlock`, `CrafterBlock`, `PotentSulfurBlock`, `MudBlock`, the weathering copper full blocks) and the double slab | full cube | 15 |
| `TintedGlassBlock` (`tinted_glass`) | empty | 15 (class override) |
| Full-cube outline with `noOcclusion` and a default `propagatesSkylightDown`: `PowderSnowBlock`, `TrialSpawnerBlock`, `VaultBlock`, `SculkVeinBlock` with no face set | empty | 1 |
| `SculkShriekerBlock` | half-height box (override) | 1 (outline is a full cube, so the default test is false) |
| Copper grate and waxed copper grate (`WaterloggedTransparentBlock`) | empty | 0 (`TransparentBlock` returns true) |
| `MossyCarpetBlock`, `HangingMossBlock`, `CarpetBlock` | outline for the carpet; empty for the two with `noOcclusion` | 0 |
| Vegetation classes without a `waterlogged` property (`AzaleaBlock`, `FlowerBedBlock`, `LeafLitterBlock`, `EyeblossomBlock`, `FireflyBushBlock`) and other non-waterloggable non-full blocks (`FlowerPotBlock`, `FrogspawnBlock`, `SporeBlossomBlock`, `CaveVinesBlock`, `CaveVinesPlantBlock`, `CandleCakeBlock`, `DoorBlock`) | outline when `canOcclude` (candle cake, flower pot, carpet), else empty | 0 |
| Non-full outline with a `waterlogged` property (bottom and top slab, stairs, sculk sensors, candles, amethyst clusters and buds, trapdoors, copper chests, copper golem statues, lightning rods, decorated pot, heavy core, pointed dripstone, sulfur spike, big and small dripleaf, big dripleaf stem, hanging roots, sculk vein with a face set) | outline when `canOcclude`, else empty | 0 when not waterlogged, 1 when waterlogged |
| `WallBlock` | outline (the wall's own shape, post and arms) | 0 when not waterlogged, 1 when waterlogged (the class override is "not waterlogged") |

Worked examples. A bottom `tuff_slab`, not waterlogged: outline box(0,0,0,16,8,16), occlusion the same, not a full cube, fluid empty, so dampening 0; the same slab waterlogged: 1; the double slab: 15.
A `tinted_glass`: dampening 15 although its occlusion shape is empty. A `trial_spawner`: full outline, empty occlusion, `propagatesSkylightDown` false, dampening 1. A `candle` with `lit` true and `waterlogged` true: outline box(7,0,7,9,6,9) (one candle), empty occlusion, fluid water, dampening 1.

5. Burnable: the registry rows have no burnable column. Two separate facts exist.
   - Fire odds (ignite, burn) come from `FireBlock.bootStrap`, tabulated in 17 section 3.3a and re-read for the blocks of this range. Blocks absent from that list are not flammable: in particular `moss_block`, `moss_carpet`, the sculk family, candles, copper, the dripstone and the stone families.

| (Ignite, burn) | Blocks of this range |
|---|---|
| (5, 100) | `pale_moss_block`, `pale_moss_carpet`, `pale_hanging_moss` |
| (15, 60) | `cave_vines`, `cave_vines_plant` |
| (30, 60) | `azalea`, `flowering_azalea`, `hanging_roots` |
| (60, 100) | `pink_petals`, `wildflowers`, `leaf_litter`, `spore_blossom`, `big_dripleaf`, `big_dripleaf_stem`, `small_dripleaf`, `firefly_bush` |

   `big_dripleaf_stem` is read as its own entry in `bootStrap` (60, 100), after `big_dripleaf` and before `small_dripleaf`; 17 section 3.3a names only "big and small dripleaf".
   - `ignitedByLava` is a separate builder flag of the flags column (blocks that lava can ignite). In this range it is set on `hanging_roots`, `pale_moss_block`, `pale_moss_carpet`, `pale_hanging_moss` and `firefly_bush` only. Fire odds and `ignitedByLava` are independent: for example `azalea` has fire odds but no lava flag.

### 7.5 Loot table key and correct-tool tags

- Loot table key: `minecraft:blocks/<path of the block key>` for all 255 blocks of this range (the `Properties` default; 24-block-registry-1 §4.1 and §15.1). No row of this range calls `noLootTable()` or `overrideLootTable()`, and a copy builder does not carry the source's key. The jar carries a file `data/minecraft/loot_table/blocks/<path>.json` for each of the 255 keys (checked by file name; contents are data for the extraction tool, not tabulated here).
- Tool tags (data files `data/minecraft/tags/block/mineable/*.json` and `needs_*_tool.json`, references to other tags followed; contents are data, 24-block-registry-1 §12.2 for what the tags mean). For each block key of this range, the tag membership read from the jar is:

| Tag | Members in this range |
|---|---|
| `mineable/pickaxe` | all blocks of the range except the ones listed in the next rows and the following non-members: dyed and plain candles and candle cakes, `tinted_glass`, `powder_snow`, `cave_vines`, `cave_vines_plant`, `spore_blossom`, `azalea`, `flowering_azalea`, `pink_petals`, `wildflowers`, `leaf_litter`, `small_dripleaf`, `hanging_roots`, the two potted azaleas, the three froglights, `frogspawn`, `reinforced_deepslate`, `decorated_pot`, `trial_spawner`, `vault`, `pale_hanging_moss`, both eyeblossoms, both potted eyeblossoms, `firefly_bush` (these are in none of the four `mineable` tags) |
| `mineable/axe` | `big_dripleaf`, `big_dripleaf_stem` |
| `mineable/shovel` | `rooted_dirt`, `mud` |
| `mineable/hoe` | `sculk_sensor`, `calibrated_sculk_sensor`, `sculk`, `sculk_vein`, `sculk_catalyst`, `sculk_shrieker`, `moss_carpet`, `moss_block`, `pale_moss_block`, `pale_moss_carpet` |
| `needs_stone_tool` | the eight blocks of each weathering family `copper_block`, `cut_copper`, `chiseled_copper`, `cut_copper_stairs`, `cut_copper_slab`, `copper_trapdoor`, `copper_grate`, `copper_bulb`, `copper_chest` and `lightning_rod` (80 blocks, waxed ones included); `copper_ore`, `deepslate_copper_ore`, `raw_iron_block`, `raw_copper_block`, `crafter`. Not members: `copper_door` and `copper_golem_statue` (the door row has no `requiresCorrectToolForDrops`, Open question 10) |
| `needs_iron_tool` | `raw_gold_block` |
| `needs_diamond_tool` | none in this range |

The sulfur and cinnabar families, the tuff, deepslate, nether brick, quartz brick, amethyst, calcite, dripstone and the other stone-like rows are in `mineable/pickaxe` and in no `needs_*` tag unless listed above.

---

## 8. Tint and placement summary (GAP-29 and GAP-30 columns)

### 8.1 Tint (24-block-registry-1 §9; sources and colour lookup in 43 section 2.1)

`BlockColors.createDefault` (43 section 2.1) refers to three blocks of this range: `pink_petals` and `wildflowers` (two tint sources: a blank
first layer and the grass source at index 1, see 24-block-registry-1 §9.3) and `leaf_litter` (the dry foliage source,
`BiomeColors.getAverageDryFoliageColor`). Every other block of this part has no tint class: the lists are empty. In
particular the moss, azalea, dripleaf, cave vine, hanging root, eyeblossom, firefly bush and pale moss blocks are untinted.

### 8.2 Replaceable (24-block-registry-1 §10.1)

The builder flag `replaceable` is set for `leaf_litter` and `hanging_roots` in this range. Placement replacement also follows
the class rules in section 4: candles, flower beds and leaf litter (same item, amount below the cap), slabs (same item, per
face and click height), sculk vein (same item while a face is free), growing plant bodies. `canBeReplaced(Fluid)` follows
24-block-registry-1 §5.2.

### 8.3 Survival (`canSurvive`)

Section 4 lists the rule per class. Blocks with a rule: candles, candle cakes, amethyst clusters, sculk vein, doors, cave
vines and plant, spore blossom, azalea, carpets, pink petals and wildflowers, leaf litter, dripleafs, hanging roots,
hanging moss, frogspawn, speleothems, eyeblossoms, firefly bush, mossy carpet. Every other row uses the default
(`true`).

### 8.4 Block tags that code reads in this range

Block tags read by the classes of this range (tag contents are data, extraction tool, 22 section 6; tool tags: 24-block-registry-1 §12.2):

| Tag | Read by |
|---|---|
| `supports_vegetation`, `supports_azalea`, `supports_big_dripleaf`, `supports_small_dripleaf` | the survival rules of section 4.4 (eyeblossoms, azalea, dripleafs and other vegetation) |
| `supports_frogspawn` (block tag and fluid tag) | `FrogspawnBlock` |
| `wall_post_override`, `walls` | `WallBlock` |
| `candles` | `CandleBlock` |
| `candle_cakes` | `CandleCakeBlock` |
| `copper_chests` | `CopperChestBlock` |
| `copper_golem_statues` | `CopperGolemStatueBlock` |
| `causes_continuous_geyser_eruptions`, `causes_periodic_geyser_eruptions` | `PotentSulfurBlock` (4.1) |
| `sculk_growth_inhibitors` | `SculkBlock` |
| `vibration_resonators` | `SculkSensorBlock` |
| `sculk_replaceable` | `SculkVeinBlock`, `SculkSpreader` |
| `sculk_replaceable_world_gen` | `SculkSpreader` |
| `speleothems` | `SpeleothemBlock` |
| `pale_oak_logs` | `HangingMossBlock` |

Fluid tags read: `water` (`SlabBlock`, `CopperGolemStatueBlock`), `lava` (`PointedDripstoneBlock`) and `supports_frogspawn` (`FrogspawnBlock`). `SulfurSpikeBlock` itself references no tag; the shared logic is in `SpeleothemBlock`. The tag set was collected from the constant pool references (`BlockTags`, `FluidTags`) of the listed classes; tags read only by helper classes they call are not included.

### 8.5 Block entities in this range

`BaseEntityBlock` subclasses (block entity types and behaviour: 31): sculk sensor, calibrated sculk sensor, sculk
shrieker, sculk catalyst, copper chests (both weathering and waxed), copper golem statues, decorated pot, crafter, trial
spawner, vault, potent sulfur. Candles, bulbs, rods and the rest have no block entity.

---

## 9. Worked examples

1. Ids: `chiseled_nether_bricks` field 770 is id 1031; `candle` field 773 is id 1034; `dyed_candle` field 774 starts at 1035 so
   `white_candle` is 1035 and `black_candle` is 1050; `candle_cake` (field 775) is 1051 and `white_candle_cake` (field 776) is 1052.
   `copper_block` (field 833) is 1124 and `waxed_oxidized_copper` is 1131. `firefly_bush` is 1285.
2. State id of `white_candle[candles=3, lit=false, waterlogged=false]`: properties by name are `candles`, `lit`, `waterlogged`;
   indices 2, 1, 1; index within the block = ((2 x 2) + 1) x 2 + 1 = 11; the block's first state id is 26469; the state id is 26480.
3. State id of `cut_copper_stairs[facing=east, half=top, shape=outer_left, waterlogged=true]`: names sorted `facing`, `half`,
   `shape`, `waterlogged`; indices 3 (north, south, west, east), 0 (top first), 3 (straight, inner_left, inner_right, outer_left),
   0 (true first); index = ((3 x 2 + 0) x 5 + 3) x 2 + 0 = 66; first state id 31165; state id 31231. The default state of the
   block (facing north, half bottom, straight, waterlogged false) has index 11, id 31176.
4. `pointed_dripstone` (id 1223, first state 33566, 20 states): names `thickness`, `vertical_direction`, `waterlogged`; default
   thickness tip (index 1), vertical_direction up (0), waterlogged false (1): index (1 x 2 + 0) x 2 + 1 = 5; default id 33571.
5. `sculk_vein` (id 1121, first state 31001): seven booleans, `true` first, so the all-false default is the last state, index
   127, id 31128. `pale_moss_carpet` (id 1279): default (`bottom` true, sides none) is index 0, the first state, id 35554, of 162
   states (2 x 3 x 3 x 3 x 3).
6. Open copper door: `copper_door` facing north, hinge left, open: the key is the facing rotated clockwise, east; the base slab
   box(0,0,13,16,16,16) goes to box(0,0,0,3,16,16) (x 0 to 3 across the whole depth), so the open door lies along the west edge.
   With hinge right the key is west: box(13,0,0,16,16,16), the east edge.
7. Candle shape: `candles` = 2: box(5,0,6,11,6,9). Light of a lit candle with 3 candles: 9.
8. Whole-block counts for the check of section 11: this part adds 255 blocks and 9273 states; 26450 + 9273 = 35723.

---

## 10. Validation

Checks run for this document (all against the 26.3 client jar):

| # | Check | Result |
|---|---|---|
| V1 | Registration order of `Blocks.<clinit>` against the declared fields | the 911 `public static final` block fields, in declaration order, are exactly the 911 block registrations in `putstatic` order (compared name by name), so field index and registration order agree (24-block-registry-1 §2.2) |
| V2 | Collection expansion: 14 collection fields in this range (2 colour, 12 weathering), 255 registrations from field 770 to 910 | ids 1031 to 1285 are consecutive and the count of blocks registered by the whole class is 1286 (section 11) |
| V3 | Property sets against the client's block state files (`assets/minecraft/blockstates/<key>.json`): every variant key and every multipart condition names only properties and values that the class definition of the block has | 255 of 255 blocks of this part have a state file; for all 255 the file's property names are a subset of the computed property names (105 of them have no property in the file: plain or full-cube blocks and blocks whose state is not rendered by property) |
| V4 | Variant counts: for each state file that uses `variants` only, the number of variant keys equals the product of the value counts of the properties named in the keys | 132 such files in this part, 132 agree; over the whole registry 626 of 626 agree |
| V5 | Seam with the parts before: first state id of every field below 105 recomputed from the class data | the 105 rows of part 1 (fields 0 to 104) were recomputed independently and agree on state count and first state id for every row; field 105 starts at state 575 |
| V6 | Totals | highest state id 35722, so 35723 states; registrations 1286; fields 911 |
| V7 | Properties not visible in state files (for example `waterlogged`, `powered`, `lit`, `power`) | taken from `createBlockStateDefinition` of the class and its superclasses; V3 cannot see them. A missing property would change the totals, so the defaults and counts of the rows with such properties were read from the constructor (section 4) |
| V8 | Defaults | each default state was read from `registerDefaultState` calls in the constructors (section 4). A subclass that starts from `defaultBlockState()` of its parent (calibrated sensor, weathering classes) adds to the parent default |

---

## 11. Whole-registry check

### 11.1 Totals

| Quantity | Value | How it was obtained |
|---|---|---|
| Fields of `Blocks` that are blocks | 911 | `public static final` block fields; the three predicate fields at the head of the class (`NOT_CLOSED_SHULKER`, `NOT_EXTENDED_PISTON`, `NEAR_PLANE_INTERSECTS_OUTLINE`) are not blocks |
| Registered blocks | 1286 | 911 fields, of which 33 are collection fields: 14 `ColorCollection.registerBlocks` fields and 4 `ColorCollection.zipMap` fields (16 blocks each) and 15 `WeatheringCopperCollection.registerBlocks` fields (8 blocks each); 878 single-block fields plus 18 x 16 plus 15 x 8 = 878 + 288 + 120 = 1286 |
| Block states | 35723 | the sum of the state counts of all 1286 blocks; highest state id 35722 |
| Last block | `firefly_bush`, id 1285, state id 35722 | |
| Client state files | 1288 | `assets/minecraft/blockstates`: 1286 for blocks plus `item_frame` and `glow_item_frame`, which are not blocks |

(The four `zipMap` fields are fields 137 `WOOL_STAIRS`, 138 `WOOL_SLAB`, 575 `CONCRETE_STAIRS` and 576 `CONCRETE_SLAB`; each registers
16 stairs or slabs built with `registerStair` or `registerSlab` from the matching coloured block. Three of the 15 weathering
fields are outside this part: copper bars, copper chain and copper lantern. Of the 14 colour `registerBlocks` fields, 2 are in
this part.)

### 11.2 Seams and the union of parts 1 to 8

Parts cover fields in order with no overlap or gap exactly when the first field and first state id of each part equals
the last field + 1 and the end state id + 1 of the part before. Known seams:

| Seam | Value |
|---|---|
| Part 1 starts | field 0 `air`, id 0, state 0 |
| Part 1 ends / part 2 starts | field 104 `orange_poplar_leaves` (id 104, first state 547, 28 states), field 105 `yellow_poplar_leaves` (id 105, first state 575) |
| Part 7 ends / part 8 starts | field 769 `polished_blackstone_wall` (id 1030, first state 26126, 324 states, last 26449), field 770 `chiseled_nether_bricks` (id 1031, first state 26450) |
| Part 8 ends | field 910 `firefly_bush` (id 1285, state 35722) |
| Part 7 seam check | checked against [24-block-registry-7-stairs-slabs-walls-workstations.md](24-block-registry-7-stairs-slabs-walls-workstations.md): its last field 769 is id 1030, first state 26126, 324 states, last state 26449; part 8 starts at 26450, which matches |
| Appendix A, mechanical check | all 911 rows: field indices 0 to 910 contiguous; cumulative block count and state count give each row's id and first state id with no gap and no overlap, ending at 1286 blocks and 35723 states; names agree with the static field order of `Blocks`. Also counted: 14 `ColorCollection.registerBlocks` calls, 4 `zipMap` calls, 15 `WeatheringCopperCollection.registerBlocks` calls, 1288 blockstate files, and loot table files for all 255 keys of this range |
| Boundaries between parts 1 to 6 | the appendix is consistent across them (row above); the per-part tables of parts 1 to 6 were not re-checked against the appendix in this part |

The verification rule for the whole registry: (a) every field index 0 to 910 appears in exactly one part's table; (b) for each
part the first row's id and first state id equal the preceding part's last row id + number of blocks it registers and first state
id + states; (c) the last row of part 8 is `firefly_bush` id 1285 and its state id 35722; (d) the sum of the "states" column
over all rows of all parts (counting each block of a collection field) is 35723; (e) the number of registered blocks is 1286.

### 11.3 Fields of this part, by family

| Fields | Family |
|---|---|
| 770 to 772 | chiseled and cracked nether bricks, quartz bricks |
| 773 to 776 | candles and candle cakes (plain and dyed) |
| 777 to 782 | amethyst block, budding amethyst, cluster and three buds |
| 783 to 796 | tuff, polished tuff, tuff bricks, chiseled variants, slabs, stairs, walls |
| 797 to 823 | sulfur family (sulfur, potent sulfur, polished, bricks, chiseled) and cinnabar family |
| 824 to 826 | calcite, tinted glass, powder snow |
| 827 to 832 | sculk sensor, calibrated sensor, sculk, vein, catalyst, shrieker |
| 833 to 846 | `copper_block` (833), copper ore, deepslate copper ore, and eleven further weathering copper families (836 to 846); twelve weathering fields in all |
| 847 to 849 | dripstone block, pointed dripstone, sulfur spike |
| 850 to 865 | cave vines and plant, spore blossom, azaleas, moss carpet, pink petals, wildflowers, leaf litter, moss block, dripleafs, hanging roots, rooted dirt, mud |
| 866 to 890 | deepslate, cobbled, polished, tiles, bricks, chiseled, cracked, infested deepslate, smooth basalt, raw iron, copper and gold blocks |
| 891 to 896 | potted azaleas, froglights, frogspawn |
| 897 to 902 | reinforced deepslate, decorated pot, crafter, trial spawner, vault, heavy core |
| 903 to 910 | pale moss block and carpet, pale hanging moss, eyeblossoms and their pots, firefly bush |

---

## 12. Open questions

1. Map colour ids and colours, the `NoteBlockInstrument` constants beyond the first 19, and the `SoundType` table are cited from 24-block-registry-1 §8; this part names the constants it uses and did not re-read their values.
2. The behaviour of each class that is not a registry fact (random ticks, growth, spreading, oxidation steps, vibrations, trial spawner and vault logic, copper chest hinge sounds (`getHingeSound`), potent sulfur tickers) was not read; its topics are covered by 29, 29b, 31 and 35, except redstone and fluids (Open question 24).
3. `PotentSulfurBlock`: the placement and update state rule `validBlockState` is closed (4.1). Still unread here: the exact set of tickers per state (`getTicker` was only seen to choose among client and server tickers by state); the block entity logic is in 31 part 8.
4. Closed: `canEntityWalkOnPowderSnow` was read (5.3): tag `powder_snow_walkable_mobs` or leather boots in the feet slot of a living entity. The case (a) test is the collision context being an entity context (with a fall distance above 2.5); the `FallingBlockEntity` test seen in the same method was not traced further.
5. Closed: `MossyCarpetBlock.getUpdatedState` and the `low` and `tall` shape mapping were read (4.4 rule below the table; 5.2). Not read: `createTopperWithSideChance`, `placeAt` and `setPlacedBy` (worldgen and placement helpers of the same class).
6. Closed: `FrogspawnBlock.mayPlaceOn(level, below)` is read as (fluid at `below` in fluid tag `supports_frogspawn` OR block at `below` in block tag `supports_frogspawn`) AND fluid at `below.above()` (the block position itself) is the empty fluid; `canSurvive` calls it with the position below.
7. Closed: `WallBlock$1` (NONE 1, LOW 2, TALL 3) and the `makeShapes` lambda show that `low` uses the height-14 arm and `tall` the height-16 arm (5.2).
8. Closed (signs): the `BLOCK_ROT_*` constants were traced to `OctahedralGroup` constants and their direction maps (5.1). The remaining gap is Open question 19.
9. Closed: `SpeleothemBlock$1` (TIP_MERGE 1, TIP 2, FRUSTUM 3, MIDDLE 4, BASE 5) and the `getShape` switch were read (5.2). Still not read here: `isValidSpeleothemPlacement`, the thickness calculation and the growth rules; searched 29b parts 1, 3 and 5 by section title only.
10. Closed: `COPPER_DOOR` has no `requiresCorrectToolForDrops` while `COPPER_TRAPDOOR` and the other copper families have it; its loot table has no tool condition (7.1 note on field 840), so the lower half drops with any tool or by hand.
11. Closed: `Blocks$1` numbers UNAFFECTED 1, EXPOSED 2, WEATHERED 3, OXIDIZED 4; the map-colour switch gives COLOR_ORANGE, TERRACOTTA_LIGHT_GRAY, WARPED_STEM, WARPED_NYLIUM and the instrument switch TRUMPET, TRUMPET_EXPOSED, TRUMPET_WEATHERED, TRUMPET_OXIDIZED for 1 to 4 (section 6).
12. Closed for Appendix A: the rule of 11.2 was run over all 911 appendix rows with no gap or overlap (11.2). Still open: the per-part tables of parts 1 to 6 were not checked against the appendix here.
13. In the whole-registry validation the enum property `mode` of `test_block` (a block outside this part, block id 997) is resolved by name only as four values (`accept`, `fail`, `log`, `start` in the client state file, in an unknown order): its state count (4) is used in the totals, its value order is not given here.
14. The `emissiveRendering` predicate (sculk sensors: phase active) is a rendering rule of the client; how the renderer uses it belongs to document 12.
15. The suspicious-stew effects of the eyeblossom types and the contents of the `supports_*` tags are data and are not specified here.
16. `SlabBlock.canBeReplaced` (replacement by click position) and `StairBlock`, `DoorBlock` placement and neighbour-update rules are summarised from their structure in 4.3 (the wall and trapdoor rules were read in full); implementers should treat the sequences of 29 (block updates and placement) as authoritative.
17. Closed: the branch condition of `TrapDoorBlock.getStateForPlacement` was read (4.3).
18. Closed: `WallBlock.shouldRaisePost`, `makeWallState` and `isCovered` were read (4.3 wall rules). The `connectsTo` helper and the neighbour update order in `updateShape` were summarised, not transcribed.
19. The point arithmetic of `Shapes.rotate` (and `DiscreteVoxelShape.rotate(group)`) was not read; 5.1 derives the pixel formulas from the direction maps of `OctahedralGroup.rotate(Direction)` and assumes boxes are transformed by the same group. Searched: `Shapes.rotate` delegates to `DiscreteVoxelShape.rotate(OctahedralGroup)`.
20. `WallBlock`: `aboveShape` is the down face shape (`getFaceShape(DOWN)`) of the above block's collision shape; reading it as a footprint in x and z for the coverage tests (4.3 wall rule step 2 and 3.4) is inferred, since `VoxelShape.getFaceShape` and `Shapes.joinIsNotEmpty` were not read.
21. The tool-tag and loot-table results of 7.5 come from the data files embedded in the client jar; that they equal the data the server loads is inferred (the extraction tool, 22 §6, copies these files). Tag files were read with references to other tags followed.
22. `bounceRestitution` and `fallDistanceReduction` are not assigned by the `Properties` constructor, so their values 0 are inferred; mud and powder snow set no friction, speed or jump factor in the properties, and powder snow's slowdown is read in `PowderSnowBlock.entityInside` (multiplier (0.9, 1.5, 0.9), 5.3). Mud's slowdown, if any, was not found in the `MudBlock` members read; the meaning of `makeStuckInBlock` (entity movement code) was not read here.
23. The dampening and occlusion results of 7.4 are derived by rule from the read `BlockBehaviour` methods and from a scan of the override sets of every class of this range (including the generic parents `AbstractChestBlock`, `BaseEntityBlock`, `GrowingPlantBlock`, `MultifaceBlock`, `RodBlock`, `FlowerBlock` and the `Weathering*` classes, which override none of the shape or dampening methods); they were not checked state by state.

24. Behaviour topics with no document yet: redstone (signal output of sculk sensors, bulbs, rods, doors and trapdoors) and fluids (waterlogging ticks, `canBeReplaced(Fluid)`). Searched: 22, 29, 29b, 31, 32, 33, 35 and 41 by section title only. Block updates and placement are covered by 29, falling, growth, spreading and oxidation by 29b, block entities by 31, worldgen features by 35, light by 32, loot and predicates by 26; 22 section 6 covers the data files (tags, loot tables) as files, not their meaning.
25. Closed. Flammability odds are in 17 section 3.3a and are tabulated for this range in 7.4 item 5. Open sub-point: `FireBlock.bootStrap` was read for the blocks of this range only; the rows for blocks of other ranges are in 17.
26. `InfestedBlock` release rule (silverfish on break) and the static host-to-infested state maps were only seen as fields and the spawn call (`EntityTypes.SILVERFISH`, spawn reason triggered, position block centre in x and z); the break and drop rules are deferred; 29 section 10 covers the player break path and 26 the loot side, but neither names the infested release (searched by section title only).

---

## Appendix A. All 911 fields: ids and first state ids

Field index, name, id (a range for a collection field), first state id of the first block, total states of the field, number of
blocks registered by the field. Use it for the whole-registry check of section 11. The name column holds the lowercased Java field names. The registered block keys differ for these fields: 774 `dyed_candle` registers the 16 keys `<dye>_candle`, 776 `dyed_candle_cake` the 16 keys `<dye>_candle_cake`, 891 `potted_azalea` is the key `potted_azalea_bush` and 892 `potted_flowering_azalea` is the key `potted_flowering_azalea_bush` (as in 7.1); other collection fields behave likewise.

| field | field name (lowercased Java static field; not always the block key, see note) | id | first state id | states | blocks |
|---|---|---|---|---|---|
| 0 | air | 0 | 0 | 1 | 1 |
| 1 | stone | 1 | 1 | 1 | 1 |
| 2 | granite | 2 | 2 | 1 | 1 |
| 3 | polished_granite | 3 | 3 | 1 | 1 |
| 4 | diorite | 4 | 4 | 1 | 1 |
| 5 | polished_diorite | 5 | 5 | 1 | 1 |
| 6 | andesite | 6 | 6 | 1 | 1 |
| 7 | polished_andesite | 7 | 7 | 1 | 1 |
| 8 | grass_block | 8 | 8 | 2 | 1 |
| 9 | dirt | 9 | 10 | 1 | 1 |
| 10 | coarse_dirt | 10 | 11 | 1 | 1 |
| 11 | podzol | 11 | 12 | 2 | 1 |
| 12 | cobblestone | 12 | 14 | 1 | 1 |
| 13 | oak_planks | 13 | 15 | 1 | 1 |
| 14 | spruce_planks | 14 | 16 | 1 | 1 |
| 15 | birch_planks | 15 | 17 | 1 | 1 |
| 16 | jungle_planks | 16 | 18 | 1 | 1 |
| 17 | acacia_planks | 17 | 19 | 1 | 1 |
| 18 | cherry_planks | 18 | 20 | 1 | 1 |
| 19 | dark_oak_planks | 19 | 21 | 1 | 1 |
| 20 | pale_oak_wood | 20 | 22 | 3 | 1 |
| 21 | pale_oak_planks | 21 | 25 | 1 | 1 |
| 22 | mangrove_planks | 22 | 26 | 1 | 1 |
| 23 | poplar_planks | 23 | 27 | 1 | 1 |
| 24 | bamboo_planks | 24 | 28 | 1 | 1 |
| 25 | bamboo_mosaic | 25 | 29 | 1 | 1 |
| 26 | oak_sapling | 26 | 30 | 2 | 1 |
| 27 | spruce_sapling | 27 | 32 | 2 | 1 |
| 28 | birch_sapling | 28 | 34 | 2 | 1 |
| 29 | jungle_sapling | 29 | 36 | 2 | 1 |
| 30 | acacia_sapling | 30 | 38 | 2 | 1 |
| 31 | cherry_sapling | 31 | 40 | 2 | 1 |
| 32 | dark_oak_sapling | 32 | 42 | 2 | 1 |
| 33 | pale_oak_sapling | 33 | 44 | 2 | 1 |
| 34 | mangrove_propagule | 34 | 46 | 40 | 1 |
| 35 | poplar_sapling | 35 | 86 | 2 | 1 |
| 36 | bedrock | 36 | 88 | 1 | 1 |
| 37 | water | 37 | 89 | 16 | 1 |
| 38 | lava | 38 | 105 | 16 | 1 |
| 39 | sand | 39 | 121 | 1 | 1 |
| 40 | suspicious_sand | 40 | 122 | 4 | 1 |
| 41 | red_sand | 41 | 126 | 1 | 1 |
| 42 | gravel | 42 | 127 | 1 | 1 |
| 43 | suspicious_gravel | 43 | 128 | 4 | 1 |
| 44 | gold_ore | 44 | 132 | 1 | 1 |
| 45 | deepslate_gold_ore | 45 | 133 | 1 | 1 |
| 46 | iron_ore | 46 | 134 | 1 | 1 |
| 47 | deepslate_iron_ore | 47 | 135 | 1 | 1 |
| 48 | coal_ore | 48 | 136 | 1 | 1 |
| 49 | deepslate_coal_ore | 49 | 137 | 1 | 1 |
| 50 | nether_gold_ore | 50 | 138 | 1 | 1 |
| 51 | oak_log | 51 | 139 | 3 | 1 |
| 52 | spruce_log | 52 | 142 | 3 | 1 |
| 53 | birch_log | 53 | 145 | 3 | 1 |
| 54 | jungle_log | 54 | 148 | 3 | 1 |
| 55 | acacia_log | 55 | 151 | 3 | 1 |
| 56 | cherry_log | 56 | 154 | 3 | 1 |
| 57 | dark_oak_log | 57 | 157 | 3 | 1 |
| 58 | pale_oak_log | 58 | 160 | 3 | 1 |
| 59 | mangrove_log | 59 | 163 | 3 | 1 |
| 60 | poplar_log | 60 | 166 | 3 | 1 |
| 61 | mangrove_roots | 61 | 169 | 2 | 1 |
| 62 | muddy_mangrove_roots | 62 | 171 | 3 | 1 |
| 63 | bamboo_block | 63 | 174 | 3 | 1 |
| 64 | stripped_spruce_log | 64 | 177 | 3 | 1 |
| 65 | stripped_birch_log | 65 | 180 | 3 | 1 |
| 66 | stripped_jungle_log | 66 | 183 | 3 | 1 |
| 67 | stripped_acacia_log | 67 | 186 | 3 | 1 |
| 68 | stripped_cherry_log | 68 | 189 | 3 | 1 |
| 69 | stripped_dark_oak_log | 69 | 192 | 3 | 1 |
| 70 | stripped_pale_oak_log | 70 | 195 | 3 | 1 |
| 71 | stripped_oak_log | 71 | 198 | 3 | 1 |
| 72 | stripped_mangrove_log | 72 | 201 | 3 | 1 |
| 73 | stripped_poplar_log | 73 | 204 | 3 | 1 |
| 74 | stripped_bamboo_block | 74 | 207 | 3 | 1 |
| 75 | oak_wood | 75 | 210 | 3 | 1 |
| 76 | spruce_wood | 76 | 213 | 3 | 1 |
| 77 | birch_wood | 77 | 216 | 3 | 1 |
| 78 | jungle_wood | 78 | 219 | 3 | 1 |
| 79 | acacia_wood | 79 | 222 | 3 | 1 |
| 80 | cherry_wood | 80 | 225 | 3 | 1 |
| 81 | dark_oak_wood | 81 | 228 | 3 | 1 |
| 82 | mangrove_wood | 82 | 231 | 3 | 1 |
| 83 | poplar_wood | 83 | 234 | 3 | 1 |
| 84 | stripped_oak_wood | 84 | 237 | 3 | 1 |
| 85 | stripped_spruce_wood | 85 | 240 | 3 | 1 |
| 86 | stripped_birch_wood | 86 | 243 | 3 | 1 |
| 87 | stripped_jungle_wood | 87 | 246 | 3 | 1 |
| 88 | stripped_acacia_wood | 88 | 249 | 3 | 1 |
| 89 | stripped_cherry_wood | 89 | 252 | 3 | 1 |
| 90 | stripped_dark_oak_wood | 90 | 255 | 3 | 1 |
| 91 | stripped_pale_oak_wood | 91 | 258 | 3 | 1 |
| 92 | stripped_mangrove_wood | 92 | 261 | 3 | 1 |
| 93 | stripped_poplar_wood | 93 | 264 | 3 | 1 |
| 94 | oak_leaves | 94 | 267 | 28 | 1 |
| 95 | spruce_leaves | 95 | 295 | 28 | 1 |
| 96 | birch_leaves | 96 | 323 | 28 | 1 |
| 97 | jungle_leaves | 97 | 351 | 28 | 1 |
| 98 | acacia_leaves | 98 | 379 | 28 | 1 |
| 99 | cherry_leaves | 99 | 407 | 28 | 1 |
| 100 | dark_oak_leaves | 100 | 435 | 28 | 1 |
| 101 | pale_oak_leaves | 101 | 463 | 28 | 1 |
| 102 | mangrove_leaves | 102 | 491 | 28 | 1 |
| 103 | red_poplar_leaves | 103 | 519 | 28 | 1 |
| 104 | orange_poplar_leaves | 104 | 547 | 28 | 1 |
| 105 | yellow_poplar_leaves | 105 | 575 | 28 | 1 |
| 106 | azalea_leaves | 106 | 603 | 28 | 1 |
| 107 | flowering_azalea_leaves | 107 | 631 | 28 | 1 |
| 108 | sponge | 108 | 659 | 1 | 1 |
| 109 | wet_sponge | 109 | 660 | 1 | 1 |
| 110 | glass | 110 | 661 | 1 | 1 |
| 111 | lapis_ore | 111 | 662 | 1 | 1 |
| 112 | deepslate_lapis_ore | 112 | 663 | 1 | 1 |
| 113 | lapis_block | 113 | 664 | 1 | 1 |
| 114 | dispenser | 114 | 665 | 12 | 1 |
| 115 | sandstone | 115 | 677 | 1 | 1 |
| 116 | chiseled_sandstone | 116 | 678 | 1 | 1 |
| 117 | cut_sandstone | 117 | 679 | 1 | 1 |
| 118 | note_block | 118 | 680 | 1350 | 1 |
| 119 | bed | 119-134 | 2030 | 256 | 16 |
| 120 | straw_bed | 135 | 2286 | 16 | 1 |
| 121 | powered_rail | 136 | 2302 | 24 | 1 |
| 122 | detector_rail | 137 | 2326 | 24 | 1 |
| 123 | sticky_piston | 138 | 2350 | 12 | 1 |
| 124 | cobweb | 139 | 2362 | 1 | 1 |
| 125 | short_grass | 140 | 2363 | 1 | 1 |
| 126 | fern | 141 | 2364 | 1 | 1 |
| 127 | dead_bush | 142 | 2365 | 1 | 1 |
| 128 | bush | 143 | 2366 | 1 | 1 |
| 129 | red_shrub | 144 | 2367 | 1 | 1 |
| 130 | short_dry_grass | 145 | 2368 | 1 | 1 |
| 131 | tall_dry_grass | 146 | 2369 | 1 | 1 |
| 132 | seagrass | 147 | 2370 | 1 | 1 |
| 133 | tall_seagrass | 148 | 2371 | 2 | 1 |
| 134 | piston | 149 | 2373 | 12 | 1 |
| 135 | piston_head | 150 | 2385 | 24 | 1 |
| 136 | wool | 151-166 | 2409 | 16 | 16 |
| 137 | wool_stairs | 167-182 | 2425 | 1280 | 16 |
| 138 | wool_slab | 183-198 | 3705 | 96 | 16 |
| 139 | moving_piston | 199 | 3801 | 12 | 1 |
| 140 | dandelion | 200 | 3813 | 1 | 1 |
| 141 | golden_dandelion | 201 | 3814 | 1 | 1 |
| 142 | torchflower | 202 | 3815 | 1 | 1 |
| 143 | poppy | 203 | 3816 | 1 | 1 |
| 144 | blue_orchid | 204 | 3817 | 1 | 1 |
| 145 | allium | 205 | 3818 | 1 | 1 |
| 146 | azure_bluet | 206 | 3819 | 1 | 1 |
| 147 | red_tulip | 207 | 3820 | 1 | 1 |
| 148 | orange_tulip | 208 | 3821 | 1 | 1 |
| 149 | white_tulip | 209 | 3822 | 1 | 1 |
| 150 | pink_tulip | 210 | 3823 | 1 | 1 |
| 151 | oxeye_daisy | 211 | 3824 | 1 | 1 |
| 152 | cornflower | 212 | 3825 | 1 | 1 |
| 153 | wither_rose | 213 | 3826 | 1 | 1 |
| 154 | lily_of_the_valley | 214 | 3827 | 1 | 1 |
| 155 | brown_mushroom | 215 | 3828 | 1 | 1 |
| 156 | red_mushroom | 216 | 3829 | 1 | 1 |
| 157 | gold_block | 217 | 3830 | 1 | 1 |
| 158 | iron_block | 218 | 3831 | 1 | 1 |
| 159 | bricks | 219 | 3832 | 1 | 1 |
| 160 | tnt | 220 | 3833 | 2 | 1 |
| 161 | bookshelf | 221 | 3835 | 1 | 1 |
| 162 | chiseled_bookshelf | 222 | 3836 | 256 | 1 |
| 163 | acacia_shelf | 223 | 4092 | 64 | 1 |
| 164 | bamboo_shelf | 224 | 4156 | 64 | 1 |
| 165 | birch_shelf | 225 | 4220 | 64 | 1 |
| 166 | cherry_shelf | 226 | 4284 | 64 | 1 |
| 167 | crimson_shelf | 227 | 4348 | 64 | 1 |
| 168 | dark_oak_shelf | 228 | 4412 | 64 | 1 |
| 169 | jungle_shelf | 229 | 4476 | 64 | 1 |
| 170 | mangrove_shelf | 230 | 4540 | 64 | 1 |
| 171 | oak_shelf | 231 | 4604 | 64 | 1 |
| 172 | pale_oak_shelf | 232 | 4668 | 64 | 1 |
| 173 | poplar_shelf | 233 | 4732 | 64 | 1 |
| 174 | spruce_shelf | 234 | 4796 | 64 | 1 |
| 175 | warped_shelf | 235 | 4860 | 64 | 1 |
| 176 | mossy_cobblestone | 236 | 4924 | 1 | 1 |
| 177 | obsidian | 237 | 4925 | 1 | 1 |
| 178 | torch | 238 | 4926 | 1 | 1 |
| 179 | wall_torch | 239 | 4927 | 4 | 1 |
| 180 | fire | 240 | 4931 | 512 | 1 |
| 181 | soul_fire | 241 | 5443 | 1 | 1 |
| 182 | spawner | 242 | 5444 | 1 | 1 |
| 183 | creaking_heart | 243 | 5445 | 18 | 1 |
| 184 | oak_stairs | 244 | 5463 | 80 | 1 |
| 185 | chest | 245 | 5543 | 24 | 1 |
| 186 | redstone_wire | 246 | 5567 | 1296 | 1 |
| 187 | diamond_ore | 247 | 6863 | 1 | 1 |
| 188 | deepslate_diamond_ore | 248 | 6864 | 1 | 1 |
| 189 | diamond_block | 249 | 6865 | 1 | 1 |
| 190 | crafting_table | 250 | 6866 | 1 | 1 |
| 191 | wheat | 251 | 6867 | 8 | 1 |
| 192 | farmland | 252 | 6875 | 8 | 1 |
| 193 | furnace | 253 | 6883 | 8 | 1 |
| 194 | oak_sign | 254 | 6891 | 32 | 1 |
| 195 | spruce_sign | 255 | 6923 | 32 | 1 |
| 196 | birch_sign | 256 | 6955 | 32 | 1 |
| 197 | acacia_sign | 257 | 6987 | 32 | 1 |
| 198 | cherry_sign | 258 | 7019 | 32 | 1 |
| 199 | jungle_sign | 259 | 7051 | 32 | 1 |
| 200 | dark_oak_sign | 260 | 7083 | 32 | 1 |
| 201 | pale_oak_sign | 261 | 7115 | 32 | 1 |
| 202 | mangrove_sign | 262 | 7147 | 32 | 1 |
| 203 | poplar_sign | 263 | 7179 | 32 | 1 |
| 204 | bamboo_sign | 264 | 7211 | 32 | 1 |
| 205 | oak_door | 265 | 7243 | 64 | 1 |
| 206 | ladder | 266 | 7307 | 8 | 1 |
| 207 | rail | 267 | 7315 | 20 | 1 |
| 208 | cobblestone_stairs | 268 | 7335 | 80 | 1 |
| 209 | oak_wall_sign | 269 | 7415 | 8 | 1 |
| 210 | spruce_wall_sign | 270 | 7423 | 8 | 1 |
| 211 | birch_wall_sign | 271 | 7431 | 8 | 1 |
| 212 | acacia_wall_sign | 272 | 7439 | 8 | 1 |
| 213 | cherry_wall_sign | 273 | 7447 | 8 | 1 |
| 214 | jungle_wall_sign | 274 | 7455 | 8 | 1 |
| 215 | dark_oak_wall_sign | 275 | 7463 | 8 | 1 |
| 216 | pale_oak_wall_sign | 276 | 7471 | 8 | 1 |
| 217 | mangrove_wall_sign | 277 | 7479 | 8 | 1 |
| 218 | poplar_wall_sign | 278 | 7487 | 8 | 1 |
| 219 | bamboo_wall_sign | 279 | 7495 | 8 | 1 |
| 220 | oak_hanging_sign | 280 | 7503 | 64 | 1 |
| 221 | spruce_hanging_sign | 281 | 7567 | 64 | 1 |
| 222 | birch_hanging_sign | 282 | 7631 | 64 | 1 |
| 223 | acacia_hanging_sign | 283 | 7695 | 64 | 1 |
| 224 | cherry_hanging_sign | 284 | 7759 | 64 | 1 |
| 225 | jungle_hanging_sign | 285 | 7823 | 64 | 1 |
| 226 | dark_oak_hanging_sign | 286 | 7887 | 64 | 1 |
| 227 | pale_oak_hanging_sign | 287 | 7951 | 64 | 1 |
| 228 | crimson_hanging_sign | 288 | 8015 | 64 | 1 |
| 229 | warped_hanging_sign | 289 | 8079 | 64 | 1 |
| 230 | mangrove_hanging_sign | 290 | 8143 | 64 | 1 |
| 231 | poplar_hanging_sign | 291 | 8207 | 64 | 1 |
| 232 | bamboo_hanging_sign | 292 | 8271 | 64 | 1 |
| 233 | oak_wall_hanging_sign | 293 | 8335 | 8 | 1 |
| 234 | spruce_wall_hanging_sign | 294 | 8343 | 8 | 1 |
| 235 | birch_wall_hanging_sign | 295 | 8351 | 8 | 1 |
| 236 | acacia_wall_hanging_sign | 296 | 8359 | 8 | 1 |
| 237 | cherry_wall_hanging_sign | 297 | 8367 | 8 | 1 |
| 238 | jungle_wall_hanging_sign | 298 | 8375 | 8 | 1 |
| 239 | dark_oak_wall_hanging_sign | 299 | 8383 | 8 | 1 |
| 240 | pale_oak_wall_hanging_sign | 300 | 8391 | 8 | 1 |
| 241 | mangrove_wall_hanging_sign | 301 | 8399 | 8 | 1 |
| 242 | poplar_wall_hanging_sign | 302 | 8407 | 8 | 1 |
| 243 | crimson_wall_hanging_sign | 303 | 8415 | 8 | 1 |
| 244 | warped_wall_hanging_sign | 304 | 8423 | 8 | 1 |
| 245 | bamboo_wall_hanging_sign | 305 | 8431 | 8 | 1 |
| 246 | lever | 306 | 8439 | 24 | 1 |
| 247 | stone_pressure_plate | 307 | 8463 | 2 | 1 |
| 248 | iron_door | 308 | 8465 | 64 | 1 |
| 249 | oak_pressure_plate | 309 | 8529 | 2 | 1 |
| 250 | spruce_pressure_plate | 310 | 8531 | 2 | 1 |
| 251 | birch_pressure_plate | 311 | 8533 | 2 | 1 |
| 252 | jungle_pressure_plate | 312 | 8535 | 2 | 1 |
| 253 | acacia_pressure_plate | 313 | 8537 | 2 | 1 |
| 254 | cherry_pressure_plate | 314 | 8539 | 2 | 1 |
| 255 | dark_oak_pressure_plate | 315 | 8541 | 2 | 1 |
| 256 | pale_oak_pressure_plate | 316 | 8543 | 2 | 1 |
| 257 | mangrove_pressure_plate | 317 | 8545 | 2 | 1 |
| 258 | poplar_pressure_plate | 318 | 8547 | 2 | 1 |
| 259 | bamboo_pressure_plate | 319 | 8549 | 2 | 1 |
| 260 | redstone_ore | 320 | 8551 | 2 | 1 |
| 261 | deepslate_redstone_ore | 321 | 8553 | 2 | 1 |
| 262 | redstone_torch | 322 | 8555 | 2 | 1 |
| 263 | redstone_wall_torch | 323 | 8557 | 8 | 1 |
| 264 | stone_button | 324 | 8565 | 24 | 1 |
| 265 | snow | 325 | 8589 | 8 | 1 |
| 266 | ice | 326 | 8597 | 1 | 1 |
| 267 | snow_block | 327 | 8598 | 1 | 1 |
| 268 | cactus | 328 | 8599 | 16 | 1 |
| 269 | cactus_flower | 329 | 8615 | 1 | 1 |
| 270 | clay | 330 | 8616 | 1 | 1 |
| 271 | sugar_cane | 331 | 8617 | 16 | 1 |
| 272 | jukebox | 332 | 8633 | 2 | 1 |
| 273 | oak_fence | 333 | 8635 | 32 | 1 |
| 274 | netherrack | 334 | 8667 | 1 | 1 |
| 275 | soul_sand | 335 | 8668 | 1 | 1 |
| 276 | soul_soil | 336 | 8669 | 1 | 1 |
| 277 | basalt | 337 | 8670 | 3 | 1 |
| 278 | polished_basalt | 338 | 8673 | 3 | 1 |
| 279 | soul_torch | 339 | 8676 | 1 | 1 |
| 280 | soul_wall_torch | 340 | 8677 | 4 | 1 |
| 281 | copper_torch | 341 | 8681 | 1 | 1 |
| 282 | copper_wall_torch | 342 | 8682 | 4 | 1 |
| 283 | glowstone | 343 | 8686 | 1 | 1 |
| 284 | nether_portal | 344 | 8687 | 2 | 1 |
| 285 | carved_pumpkin | 345 | 8689 | 4 | 1 |
| 286 | jack_o_lantern | 346 | 8693 | 4 | 1 |
| 287 | cake | 347 | 8697 | 7 | 1 |
| 288 | repeater | 348 | 8704 | 64 | 1 |
| 289 | stained_glass | 349-364 | 8768 | 16 | 16 |
| 290 | oak_trapdoor | 365 | 8784 | 64 | 1 |
| 291 | spruce_trapdoor | 366 | 8848 | 64 | 1 |
| 292 | birch_trapdoor | 367 | 8912 | 64 | 1 |
| 293 | jungle_trapdoor | 368 | 8976 | 64 | 1 |
| 294 | acacia_trapdoor | 369 | 9040 | 64 | 1 |
| 295 | cherry_trapdoor | 370 | 9104 | 64 | 1 |
| 296 | dark_oak_trapdoor | 371 | 9168 | 64 | 1 |
| 297 | pale_oak_trapdoor | 372 | 9232 | 64 | 1 |
| 298 | mangrove_trapdoor | 373 | 9296 | 64 | 1 |
| 299 | poplar_trapdoor | 374 | 9360 | 64 | 1 |
| 300 | bamboo_trapdoor | 375 | 9424 | 64 | 1 |
| 301 | stone_bricks | 376 | 9488 | 1 | 1 |
| 302 | mossy_stone_bricks | 377 | 9489 | 1 | 1 |
| 303 | cracked_stone_bricks | 378 | 9490 | 1 | 1 |
| 304 | chiseled_stone_bricks | 379 | 9491 | 1 | 1 |
| 305 | packed_mud | 380 | 9492 | 1 | 1 |
| 306 | mud_bricks | 381 | 9493 | 1 | 1 |
| 307 | infested_stone | 382 | 9494 | 1 | 1 |
| 308 | infested_cobblestone | 383 | 9495 | 1 | 1 |
| 309 | infested_stone_bricks | 384 | 9496 | 1 | 1 |
| 310 | infested_mossy_stone_bricks | 385 | 9497 | 1 | 1 |
| 311 | infested_cracked_stone_bricks | 386 | 9498 | 1 | 1 |
| 312 | infested_chiseled_stone_bricks | 387 | 9499 | 1 | 1 |
| 313 | brown_mushroom_block | 388 | 9500 | 64 | 1 |
| 314 | red_mushroom_block | 389 | 9564 | 64 | 1 |
| 315 | mushroom_stem | 390 | 9628 | 64 | 1 |
| 316 | iron_bars | 391 | 9692 | 32 | 1 |
| 317 | copper_bars | 392-399 | 9724 | 256 | 8 |
| 318 | iron_chain | 400 | 9980 | 6 | 1 |
| 319 | copper_chain | 401-408 | 9986 | 48 | 8 |
| 320 | glass_pane | 409 | 10034 | 32 | 1 |
| 321 | pumpkin | 410 | 10066 | 1 | 1 |
| 322 | melon | 411 | 10067 | 1 | 1 |
| 323 | attached_pumpkin_stem | 412 | 10068 | 4 | 1 |
| 324 | attached_melon_stem | 413 | 10072 | 4 | 1 |
| 325 | pumpkin_stem | 414 | 10076 | 8 | 1 |
| 326 | melon_stem | 415 | 10084 | 8 | 1 |
| 327 | vine | 416 | 10092 | 32 | 1 |
| 328 | glow_lichen | 417 | 10124 | 128 | 1 |
| 329 | resin_clump | 418 | 10252 | 128 | 1 |
| 330 | oak_fence_gate | 419 | 10380 | 32 | 1 |
| 331 | brick_stairs | 420 | 10412 | 80 | 1 |
| 332 | stone_brick_stairs | 421 | 10492 | 80 | 1 |
| 333 | mud_brick_stairs | 422 | 10572 | 80 | 1 |
| 334 | mycelium | 423 | 10652 | 2 | 1 |
| 335 | lily_pad | 424 | 10654 | 1 | 1 |
| 336 | resin_block | 425 | 10655 | 1 | 1 |
| 337 | resin_bricks | 426 | 10656 | 1 | 1 |
| 338 | resin_brick_stairs | 427 | 10657 | 80 | 1 |
| 339 | resin_brick_slab | 428 | 10737 | 6 | 1 |
| 340 | resin_brick_wall | 429 | 10743 | 324 | 1 |
| 341 | chiseled_resin_bricks | 430 | 11067 | 1 | 1 |
| 342 | nether_bricks | 431 | 11068 | 1 | 1 |
| 343 | nether_brick_fence | 432 | 11069 | 32 | 1 |
| 344 | nether_brick_stairs | 433 | 11101 | 80 | 1 |
| 345 | nether_wart | 434 | 11181 | 4 | 1 |
| 346 | enchanting_table | 435 | 11185 | 1 | 1 |
| 347 | brewing_stand | 436 | 11186 | 8 | 1 |
| 348 | cauldron | 437 | 11194 | 1 | 1 |
| 349 | water_cauldron | 438 | 11195 | 3 | 1 |
| 350 | lava_cauldron | 439 | 11198 | 1 | 1 |
| 351 | powder_snow_cauldron | 440 | 11199 | 3 | 1 |
| 352 | end_portal | 441 | 11202 | 1 | 1 |
| 353 | end_portal_frame | 442 | 11203 | 8 | 1 |
| 354 | end_stone | 443 | 11211 | 1 | 1 |
| 355 | dragon_egg | 444 | 11212 | 1 | 1 |
| 356 | redstone_lamp | 445 | 11213 | 2 | 1 |
| 357 | cocoa | 446 | 11215 | 12 | 1 |
| 358 | shelf_mushroom | 447 | 11227 | 8 | 1 |
| 359 | sandstone_stairs | 448 | 11235 | 80 | 1 |
| 360 | emerald_ore | 449 | 11315 | 1 | 1 |
| 361 | deepslate_emerald_ore | 450 | 11316 | 1 | 1 |
| 362 | ender_chest | 451 | 11317 | 8 | 1 |
| 363 | tripwire_hook | 452 | 11325 | 16 | 1 |
| 364 | tripwire | 453 | 11341 | 128 | 1 |
| 365 | emerald_block | 454 | 11469 | 1 | 1 |
| 366 | spruce_stairs | 455 | 11470 | 80 | 1 |
| 367 | birch_stairs | 456 | 11550 | 80 | 1 |
| 368 | jungle_stairs | 457 | 11630 | 80 | 1 |
| 369 | command_block | 458 | 11710 | 12 | 1 |
| 370 | beacon | 459 | 11722 | 1 | 1 |
| 371 | cobblestone_wall | 460 | 11723 | 324 | 1 |
| 372 | mossy_cobblestone_wall | 461 | 12047 | 324 | 1 |
| 373 | flower_pot | 462 | 12371 | 1 | 1 |
| 374 | potted_torchflower | 463 | 12372 | 1 | 1 |
| 375 | potted_oak_sapling | 464 | 12373 | 1 | 1 |
| 376 | potted_spruce_sapling | 465 | 12374 | 1 | 1 |
| 377 | potted_birch_sapling | 466 | 12375 | 1 | 1 |
| 378 | potted_jungle_sapling | 467 | 12376 | 1 | 1 |
| 379 | potted_acacia_sapling | 468 | 12377 | 1 | 1 |
| 380 | potted_cherry_sapling | 469 | 12378 | 1 | 1 |
| 381 | potted_dark_oak_sapling | 470 | 12379 | 1 | 1 |
| 382 | potted_pale_oak_sapling | 471 | 12380 | 1 | 1 |
| 383 | potted_poplar_sapling | 472 | 12381 | 1 | 1 |
| 384 | potted_mangrove_propagule | 473 | 12382 | 1 | 1 |
| 385 | potted_fern | 474 | 12383 | 1 | 1 |
| 386 | potted_dandelion | 475 | 12384 | 1 | 1 |
| 387 | potted_golden_dandelion | 476 | 12385 | 1 | 1 |
| 388 | potted_poppy | 477 | 12386 | 1 | 1 |
| 389 | potted_blue_orchid | 478 | 12387 | 1 | 1 |
| 390 | potted_allium | 479 | 12388 | 1 | 1 |
| 391 | potted_azure_bluet | 480 | 12389 | 1 | 1 |
| 392 | potted_red_tulip | 481 | 12390 | 1 | 1 |
| 393 | potted_orange_tulip | 482 | 12391 | 1 | 1 |
| 394 | potted_white_tulip | 483 | 12392 | 1 | 1 |
| 395 | potted_pink_tulip | 484 | 12393 | 1 | 1 |
| 396 | potted_oxeye_daisy | 485 | 12394 | 1 | 1 |
| 397 | potted_cornflower | 486 | 12395 | 1 | 1 |
| 398 | potted_lily_of_the_valley | 487 | 12396 | 1 | 1 |
| 399 | potted_wither_rose | 488 | 12397 | 1 | 1 |
| 400 | potted_red_mushroom | 489 | 12398 | 1 | 1 |
| 401 | potted_brown_mushroom | 490 | 12399 | 1 | 1 |
| 402 | potted_dead_bush | 491 | 12400 | 1 | 1 |
| 403 | potted_cactus | 492 | 12401 | 1 | 1 |
| 404 | carrots | 493 | 12402 | 8 | 1 |
| 405 | potatoes | 494 | 12410 | 8 | 1 |
| 406 | oak_button | 495 | 12418 | 24 | 1 |
| 407 | spruce_button | 496 | 12442 | 24 | 1 |
| 408 | birch_button | 497 | 12466 | 24 | 1 |
| 409 | jungle_button | 498 | 12490 | 24 | 1 |
| 410 | acacia_button | 499 | 12514 | 24 | 1 |
| 411 | cherry_button | 500 | 12538 | 24 | 1 |
| 412 | dark_oak_button | 501 | 12562 | 24 | 1 |
| 413 | pale_oak_button | 502 | 12586 | 24 | 1 |
| 414 | mangrove_button | 503 | 12610 | 24 | 1 |
| 415 | poplar_button | 504 | 12634 | 24 | 1 |
| 416 | bamboo_button | 505 | 12658 | 24 | 1 |
| 417 | skeleton_skull | 506 | 12682 | 32 | 1 |
| 418 | skeleton_wall_skull | 507 | 12714 | 8 | 1 |
| 419 | wither_skeleton_skull | 508 | 12722 | 32 | 1 |
| 420 | wither_skeleton_wall_skull | 509 | 12754 | 8 | 1 |
| 421 | zombie_head | 510 | 12762 | 32 | 1 |
| 422 | zombie_wall_head | 511 | 12794 | 8 | 1 |
| 423 | player_head | 512 | 12802 | 32 | 1 |
| 424 | player_wall_head | 513 | 12834 | 8 | 1 |
| 425 | creeper_head | 514 | 12842 | 32 | 1 |
| 426 | creeper_wall_head | 515 | 12874 | 8 | 1 |
| 427 | dragon_head | 516 | 12882 | 32 | 1 |
| 428 | dragon_wall_head | 517 | 12914 | 8 | 1 |
| 429 | piglin_head | 518 | 12922 | 32 | 1 |
| 430 | piglin_wall_head | 519 | 12954 | 8 | 1 |
| 431 | anvil | 520 | 12962 | 4 | 1 |
| 432 | chipped_anvil | 521 | 12966 | 4 | 1 |
| 433 | damaged_anvil | 522 | 12970 | 4 | 1 |
| 434 | trapped_chest | 523 | 12974 | 24 | 1 |
| 435 | light_weighted_pressure_plate | 524 | 12998 | 16 | 1 |
| 436 | heavy_weighted_pressure_plate | 525 | 13014 | 16 | 1 |
| 437 | comparator | 526 | 13030 | 16 | 1 |
| 438 | daylight_detector | 527 | 13046 | 32 | 1 |
| 439 | redstone_block | 528 | 13078 | 1 | 1 |
| 440 | nether_quartz_ore | 529 | 13079 | 1 | 1 |
| 441 | hopper | 530 | 13080 | 10 | 1 |
| 442 | quartz_block | 531 | 13090 | 1 | 1 |
| 443 | chiseled_quartz_block | 532 | 13091 | 1 | 1 |
| 444 | quartz_pillar | 533 | 13092 | 3 | 1 |
| 445 | quartz_stairs | 534 | 13095 | 80 | 1 |
| 446 | activator_rail | 535 | 13175 | 24 | 1 |
| 447 | dropper | 536 | 13199 | 12 | 1 |
| 448 | dyed_terracotta | 537-552 | 13211 | 16 | 16 |
| 449 | stained_glass_pane | 553-568 | 13227 | 512 | 16 |
| 450 | acacia_stairs | 569 | 13739 | 80 | 1 |
| 451 | cherry_stairs | 570 | 13819 | 80 | 1 |
| 452 | dark_oak_stairs | 571 | 13899 | 80 | 1 |
| 453 | pale_oak_stairs | 572 | 13979 | 80 | 1 |
| 454 | mangrove_stairs | 573 | 14059 | 80 | 1 |
| 455 | poplar_stairs | 574 | 14139 | 80 | 1 |
| 456 | bamboo_stairs | 575 | 14219 | 80 | 1 |
| 457 | bamboo_mosaic_stairs | 576 | 14299 | 80 | 1 |
| 458 | slime_block | 577 | 14379 | 1 | 1 |
| 459 | barrier | 578 | 14380 | 2 | 1 |
| 460 | light | 579 | 14382 | 32 | 1 |
| 461 | iron_trapdoor | 580 | 14414 | 64 | 1 |
| 462 | prismarine | 581 | 14478 | 1 | 1 |
| 463 | prismarine_bricks | 582 | 14479 | 1 | 1 |
| 464 | dark_prismarine | 583 | 14480 | 1 | 1 |
| 465 | prismarine_stairs | 584 | 14481 | 80 | 1 |
| 466 | prismarine_brick_stairs | 585 | 14561 | 80 | 1 |
| 467 | dark_prismarine_stairs | 586 | 14641 | 80 | 1 |
| 468 | prismarine_slab | 587 | 14721 | 6 | 1 |
| 469 | prismarine_brick_slab | 588 | 14727 | 6 | 1 |
| 470 | dark_prismarine_slab | 589 | 14733 | 6 | 1 |
| 471 | sea_lantern | 590 | 14739 | 1 | 1 |
| 472 | hay_block | 591 | 14740 | 3 | 1 |
| 473 | carpet | 592-607 | 14743 | 16 | 16 |
| 474 | terracotta | 608 | 14759 | 1 | 1 |
| 475 | coal_block | 609 | 14760 | 1 | 1 |
| 476 | packed_ice | 610 | 14761 | 1 | 1 |
| 477 | sunflower | 611 | 14762 | 2 | 1 |
| 478 | lilac | 612 | 14764 | 2 | 1 |
| 479 | rose_bush | 613 | 14766 | 2 | 1 |
| 480 | peony | 614 | 14768 | 2 | 1 |
| 481 | tall_grass | 615 | 14770 | 2 | 1 |
| 482 | large_fern | 616 | 14772 | 2 | 1 |
| 483 | banner | 617-632 | 14774 | 256 | 16 |
| 484 | wall_banner | 633-648 | 15030 | 64 | 16 |
| 485 | red_sandstone | 649 | 15094 | 1 | 1 |
| 486 | chiseled_red_sandstone | 650 | 15095 | 1 | 1 |
| 487 | cut_red_sandstone | 651 | 15096 | 1 | 1 |
| 488 | red_sandstone_stairs | 652 | 15097 | 80 | 1 |
| 489 | oak_slab | 653 | 15177 | 6 | 1 |
| 490 | spruce_slab | 654 | 15183 | 6 | 1 |
| 491 | birch_slab | 655 | 15189 | 6 | 1 |
| 492 | jungle_slab | 656 | 15195 | 6 | 1 |
| 493 | acacia_slab | 657 | 15201 | 6 | 1 |
| 494 | cherry_slab | 658 | 15207 | 6 | 1 |
| 495 | dark_oak_slab | 659 | 15213 | 6 | 1 |
| 496 | pale_oak_slab | 660 | 15219 | 6 | 1 |
| 497 | mangrove_slab | 661 | 15225 | 6 | 1 |
| 498 | poplar_slab | 662 | 15231 | 6 | 1 |
| 499 | bamboo_slab | 663 | 15237 | 6 | 1 |
| 500 | bamboo_mosaic_slab | 664 | 15243 | 6 | 1 |
| 501 | stone_slab | 665 | 15249 | 6 | 1 |
| 502 | sandstone_slab | 666 | 15255 | 6 | 1 |
| 503 | cut_sandstone_slab | 667 | 15261 | 6 | 1 |
| 504 | petrified_oak_slab | 668 | 15267 | 6 | 1 |
| 505 | cobblestone_slab | 669 | 15273 | 6 | 1 |
| 506 | brick_slab | 670 | 15279 | 6 | 1 |
| 507 | stone_brick_slab | 671 | 15285 | 6 | 1 |
| 508 | mud_brick_slab | 672 | 15291 | 6 | 1 |
| 509 | nether_brick_slab | 673 | 15297 | 6 | 1 |
| 510 | quartz_slab | 674 | 15303 | 6 | 1 |
| 511 | red_sandstone_slab | 675 | 15309 | 6 | 1 |
| 512 | cut_red_sandstone_slab | 676 | 15315 | 6 | 1 |
| 513 | smooth_stone | 677 | 15321 | 1 | 1 |
| 514 | smooth_stone_slab | 678 | 15322 | 6 | 1 |
| 515 | smooth_sandstone | 679 | 15328 | 1 | 1 |
| 516 | smooth_quartz | 680 | 15329 | 1 | 1 |
| 517 | smooth_red_sandstone | 681 | 15330 | 1 | 1 |
| 518 | spruce_fence_gate | 682 | 15331 | 32 | 1 |
| 519 | birch_fence_gate | 683 | 15363 | 32 | 1 |
| 520 | jungle_fence_gate | 684 | 15395 | 32 | 1 |
| 521 | acacia_fence_gate | 685 | 15427 | 32 | 1 |
| 522 | cherry_fence_gate | 686 | 15459 | 32 | 1 |
| 523 | dark_oak_fence_gate | 687 | 15491 | 32 | 1 |
| 524 | pale_oak_fence_gate | 688 | 15523 | 32 | 1 |
| 525 | mangrove_fence_gate | 689 | 15555 | 32 | 1 |
| 526 | poplar_fence_gate | 690 | 15587 | 32 | 1 |
| 527 | bamboo_fence_gate | 691 | 15619 | 32 | 1 |
| 528 | spruce_fence | 692 | 15651 | 32 | 1 |
| 529 | birch_fence | 693 | 15683 | 32 | 1 |
| 530 | jungle_fence | 694 | 15715 | 32 | 1 |
| 531 | acacia_fence | 695 | 15747 | 32 | 1 |
| 532 | cherry_fence | 696 | 15779 | 32 | 1 |
| 533 | dark_oak_fence | 697 | 15811 | 32 | 1 |
| 534 | pale_oak_fence | 698 | 15843 | 32 | 1 |
| 535 | mangrove_fence | 699 | 15875 | 32 | 1 |
| 536 | poplar_fence | 700 | 15907 | 32 | 1 |
| 537 | bamboo_fence | 701 | 15939 | 32 | 1 |
| 538 | spruce_door | 702 | 15971 | 64 | 1 |
| 539 | birch_door | 703 | 16035 | 64 | 1 |
| 540 | jungle_door | 704 | 16099 | 64 | 1 |
| 541 | acacia_door | 705 | 16163 | 64 | 1 |
| 542 | cherry_door | 706 | 16227 | 64 | 1 |
| 543 | dark_oak_door | 707 | 16291 | 64 | 1 |
| 544 | pale_oak_door | 708 | 16355 | 64 | 1 |
| 545 | mangrove_door | 709 | 16419 | 64 | 1 |
| 546 | poplar_door | 710 | 16483 | 64 | 1 |
| 547 | bamboo_door | 711 | 16547 | 64 | 1 |
| 548 | end_rod | 712 | 16611 | 6 | 1 |
| 549 | chorus_plant | 713 | 16617 | 64 | 1 |
| 550 | chorus_flower | 714 | 16681 | 6 | 1 |
| 551 | purpur_block | 715 | 16687 | 1 | 1 |
| 552 | purpur_slab | 716 | 16688 | 6 | 1 |
| 553 | purpur_pillar | 717 | 16694 | 3 | 1 |
| 554 | purpur_stairs | 718 | 16697 | 80 | 1 |
| 555 | end_stone_bricks | 719 | 16777 | 1 | 1 |
| 556 | torchflower_crop | 720 | 16778 | 2 | 1 |
| 557 | pitcher_crop | 721 | 16780 | 10 | 1 |
| 558 | pitcher_plant | 722 | 16790 | 2 | 1 |
| 559 | beetroots | 723 | 16792 | 4 | 1 |
| 560 | dirt_path | 724 | 16796 | 1 | 1 |
| 561 | end_gateway | 725 | 16797 | 1 | 1 |
| 562 | repeating_command_block | 726 | 16798 | 12 | 1 |
| 563 | chain_command_block | 727 | 16810 | 12 | 1 |
| 564 | frosted_ice | 728 | 16822 | 4 | 1 |
| 565 | magma_block | 729 | 16826 | 1 | 1 |
| 566 | nether_wart_block | 730 | 16827 | 1 | 1 |
| 567 | red_nether_bricks | 731 | 16828 | 1 | 1 |
| 568 | bone_block | 732 | 16829 | 3 | 1 |
| 569 | structure_void | 733 | 16832 | 1 | 1 |
| 570 | observer | 734 | 16833 | 12 | 1 |
| 571 | shulker_box | 735 | 16845 | 6 | 1 |
| 572 | dyed_shulker_box | 736-751 | 16851 | 96 | 16 |
| 573 | glazed_terracotta | 752-767 | 16947 | 64 | 16 |
| 574 | concrete | 768-783 | 17011 | 16 | 16 |
| 575 | concrete_stairs | 784-799 | 17027 | 1280 | 16 |
| 576 | concrete_slab | 800-815 | 18307 | 96 | 16 |
| 577 | concrete_powder | 816-831 | 18403 | 16 | 16 |
| 578 | kelp | 832 | 18419 | 26 | 1 |
| 579 | kelp_plant | 833 | 18445 | 1 | 1 |
| 580 | dried_kelp_block | 834 | 18446 | 1 | 1 |
| 581 | turtle_egg | 835 | 18447 | 12 | 1 |
| 582 | sniffer_egg | 836 | 18459 | 3 | 1 |
| 583 | dried_ghast | 837 | 18462 | 32 | 1 |
| 584 | dead_tube_coral_block | 838 | 18494 | 1 | 1 |
| 585 | dead_brain_coral_block | 839 | 18495 | 1 | 1 |
| 586 | dead_bubble_coral_block | 840 | 18496 | 1 | 1 |
| 587 | dead_fire_coral_block | 841 | 18497 | 1 | 1 |
| 588 | dead_horn_coral_block | 842 | 18498 | 1 | 1 |
| 589 | tube_coral_block | 843 | 18499 | 1 | 1 |
| 590 | brain_coral_block | 844 | 18500 | 1 | 1 |
| 591 | bubble_coral_block | 845 | 18501 | 1 | 1 |
| 592 | fire_coral_block | 846 | 18502 | 1 | 1 |
| 593 | horn_coral_block | 847 | 18503 | 1 | 1 |
| 594 | dead_tube_coral | 848 | 18504 | 2 | 1 |
| 595 | dead_brain_coral | 849 | 18506 | 2 | 1 |
| 596 | dead_bubble_coral | 850 | 18508 | 2 | 1 |
| 597 | dead_fire_coral | 851 | 18510 | 2 | 1 |
| 598 | dead_horn_coral | 852 | 18512 | 2 | 1 |
| 599 | tube_coral | 853 | 18514 | 2 | 1 |
| 600 | brain_coral | 854 | 18516 | 2 | 1 |
| 601 | bubble_coral | 855 | 18518 | 2 | 1 |
| 602 | fire_coral | 856 | 18520 | 2 | 1 |
| 603 | horn_coral | 857 | 18522 | 2 | 1 |
| 604 | dead_tube_coral_fan | 858 | 18524 | 2 | 1 |
| 605 | dead_brain_coral_fan | 859 | 18526 | 2 | 1 |
| 606 | dead_bubble_coral_fan | 860 | 18528 | 2 | 1 |
| 607 | dead_fire_coral_fan | 861 | 18530 | 2 | 1 |
| 608 | dead_horn_coral_fan | 862 | 18532 | 2 | 1 |
| 609 | tube_coral_fan | 863 | 18534 | 2 | 1 |
| 610 | brain_coral_fan | 864 | 18536 | 2 | 1 |
| 611 | bubble_coral_fan | 865 | 18538 | 2 | 1 |
| 612 | fire_coral_fan | 866 | 18540 | 2 | 1 |
| 613 | horn_coral_fan | 867 | 18542 | 2 | 1 |
| 614 | dead_tube_coral_wall_fan | 868 | 18544 | 8 | 1 |
| 615 | dead_brain_coral_wall_fan | 869 | 18552 | 8 | 1 |
| 616 | dead_bubble_coral_wall_fan | 870 | 18560 | 8 | 1 |
| 617 | dead_fire_coral_wall_fan | 871 | 18568 | 8 | 1 |
| 618 | dead_horn_coral_wall_fan | 872 | 18576 | 8 | 1 |
| 619 | tube_coral_wall_fan | 873 | 18584 | 8 | 1 |
| 620 | brain_coral_wall_fan | 874 | 18592 | 8 | 1 |
| 621 | bubble_coral_wall_fan | 875 | 18600 | 8 | 1 |
| 622 | fire_coral_wall_fan | 876 | 18608 | 8 | 1 |
| 623 | horn_coral_wall_fan | 877 | 18616 | 8 | 1 |
| 624 | sea_pickle | 878 | 18624 | 8 | 1 |
| 625 | blue_ice | 879 | 18632 | 1 | 1 |
| 626 | conduit | 880 | 18633 | 2 | 1 |
| 627 | bamboo_sapling | 881 | 18635 | 1 | 1 |
| 628 | bamboo | 882 | 18636 | 12 | 1 |
| 629 | potted_bamboo | 883 | 18648 | 1 | 1 |
| 630 | void_air | 884 | 18649 | 1 | 1 |
| 631 | cave_air | 885 | 18650 | 1 | 1 |
| 632 | bubble_column | 886 | 18651 | 2 | 1 |
| 633 | polished_granite_stairs | 887 | 18653 | 80 | 1 |
| 634 | smooth_red_sandstone_stairs | 888 | 18733 | 80 | 1 |
| 635 | mossy_stone_brick_stairs | 889 | 18813 | 80 | 1 |
| 636 | polished_diorite_stairs | 890 | 18893 | 80 | 1 |
| 637 | mossy_cobblestone_stairs | 891 | 18973 | 80 | 1 |
| 638 | end_stone_brick_stairs | 892 | 19053 | 80 | 1 |
| 639 | stone_stairs | 893 | 19133 | 80 | 1 |
| 640 | smooth_sandstone_stairs | 894 | 19213 | 80 | 1 |
| 641 | smooth_quartz_stairs | 895 | 19293 | 80 | 1 |
| 642 | granite_stairs | 896 | 19373 | 80 | 1 |
| 643 | andesite_stairs | 897 | 19453 | 80 | 1 |
| 644 | red_nether_brick_stairs | 898 | 19533 | 80 | 1 |
| 645 | polished_andesite_stairs | 899 | 19613 | 80 | 1 |
| 646 | diorite_stairs | 900 | 19693 | 80 | 1 |
| 647 | polished_granite_slab | 901 | 19773 | 6 | 1 |
| 648 | smooth_red_sandstone_slab | 902 | 19779 | 6 | 1 |
| 649 | mossy_stone_brick_slab | 903 | 19785 | 6 | 1 |
| 650 | polished_diorite_slab | 904 | 19791 | 6 | 1 |
| 651 | mossy_cobblestone_slab | 905 | 19797 | 6 | 1 |
| 652 | end_stone_brick_slab | 906 | 19803 | 6 | 1 |
| 653 | smooth_sandstone_slab | 907 | 19809 | 6 | 1 |
| 654 | smooth_quartz_slab | 908 | 19815 | 6 | 1 |
| 655 | granite_slab | 909 | 19821 | 6 | 1 |
| 656 | andesite_slab | 910 | 19827 | 6 | 1 |
| 657 | red_nether_brick_slab | 911 | 19833 | 6 | 1 |
| 658 | polished_andesite_slab | 912 | 19839 | 6 | 1 |
| 659 | diorite_slab | 913 | 19845 | 6 | 1 |
| 660 | brick_wall | 914 | 19851 | 324 | 1 |
| 661 | prismarine_wall | 915 | 20175 | 324 | 1 |
| 662 | red_sandstone_wall | 916 | 20499 | 324 | 1 |
| 663 | mossy_stone_brick_wall | 917 | 20823 | 324 | 1 |
| 664 | granite_wall | 918 | 21147 | 324 | 1 |
| 665 | stone_brick_wall | 919 | 21471 | 324 | 1 |
| 666 | mud_brick_wall | 920 | 21795 | 324 | 1 |
| 667 | nether_brick_wall | 921 | 22119 | 324 | 1 |
| 668 | andesite_wall | 922 | 22443 | 324 | 1 |
| 669 | red_nether_brick_wall | 923 | 22767 | 324 | 1 |
| 670 | sandstone_wall | 924 | 23091 | 324 | 1 |
| 671 | end_stone_brick_wall | 925 | 23415 | 324 | 1 |
| 672 | diorite_wall | 926 | 23739 | 324 | 1 |
| 673 | scaffolding | 927 | 24063 | 32 | 1 |
| 674 | loom | 928 | 24095 | 4 | 1 |
| 675 | barrel | 929 | 24099 | 12 | 1 |
| 676 | smoker | 930 | 24111 | 8 | 1 |
| 677 | blast_furnace | 931 | 24119 | 8 | 1 |
| 678 | cartography_table | 932 | 24127 | 1 | 1 |
| 679 | fletching_table | 933 | 24128 | 1 | 1 |
| 680 | grindstone | 934 | 24129 | 12 | 1 |
| 681 | lectern | 935 | 24141 | 16 | 1 |
| 682 | smithing_table | 936 | 24157 | 1 | 1 |
| 683 | stonecutter | 937 | 24158 | 4 | 1 |
| 684 | bell | 938 | 24162 | 32 | 1 |
| 685 | lantern | 939 | 24194 | 4 | 1 |
| 686 | soul_lantern | 940 | 24198 | 4 | 1 |
| 687 | copper_lantern | 941-948 | 24202 | 32 | 8 |
| 688 | campfire | 949 | 24234 | 32 | 1 |
| 689 | soul_campfire | 950 | 24266 | 32 | 1 |
| 690 | sweet_berry_bush | 951 | 24298 | 4 | 1 |
| 691 | warped_stem | 952 | 24302 | 3 | 1 |
| 692 | stripped_warped_stem | 953 | 24305 | 3 | 1 |
| 693 | warped_hyphae | 954 | 24308 | 3 | 1 |
| 694 | stripped_warped_hyphae | 955 | 24311 | 3 | 1 |
| 695 | warped_nylium | 956 | 24314 | 1 | 1 |
| 696 | warped_fungus | 957 | 24315 | 1 | 1 |
| 697 | warped_wart_block | 958 | 24316 | 1 | 1 |
| 698 | warped_roots | 959 | 24317 | 1 | 1 |
| 699 | nether_sprouts | 960 | 24318 | 1 | 1 |
| 700 | crimson_stem | 961 | 24319 | 3 | 1 |
| 701 | stripped_crimson_stem | 962 | 24322 | 3 | 1 |
| 702 | crimson_hyphae | 963 | 24325 | 3 | 1 |
| 703 | stripped_crimson_hyphae | 964 | 24328 | 3 | 1 |
| 704 | crimson_nylium | 965 | 24331 | 1 | 1 |
| 705 | crimson_fungus | 966 | 24332 | 1 | 1 |
| 706 | shroomlight | 967 | 24333 | 1 | 1 |
| 707 | weeping_vines | 968 | 24334 | 26 | 1 |
| 708 | weeping_vines_plant | 969 | 24360 | 1 | 1 |
| 709 | twisting_vines | 970 | 24361 | 26 | 1 |
| 710 | twisting_vines_plant | 971 | 24387 | 1 | 1 |
| 711 | crimson_roots | 972 | 24388 | 1 | 1 |
| 712 | crimson_planks | 973 | 24389 | 1 | 1 |
| 713 | warped_planks | 974 | 24390 | 1 | 1 |
| 714 | crimson_slab | 975 | 24391 | 6 | 1 |
| 715 | warped_slab | 976 | 24397 | 6 | 1 |
| 716 | crimson_pressure_plate | 977 | 24403 | 2 | 1 |
| 717 | warped_pressure_plate | 978 | 24405 | 2 | 1 |
| 718 | crimson_fence | 979 | 24407 | 32 | 1 |
| 719 | warped_fence | 980 | 24439 | 32 | 1 |
| 720 | crimson_trapdoor | 981 | 24471 | 64 | 1 |
| 721 | warped_trapdoor | 982 | 24535 | 64 | 1 |
| 722 | crimson_fence_gate | 983 | 24599 | 32 | 1 |
| 723 | warped_fence_gate | 984 | 24631 | 32 | 1 |
| 724 | crimson_stairs | 985 | 24663 | 80 | 1 |
| 725 | warped_stairs | 986 | 24743 | 80 | 1 |
| 726 | crimson_button | 987 | 24823 | 24 | 1 |
| 727 | warped_button | 988 | 24847 | 24 | 1 |
| 728 | crimson_door | 989 | 24871 | 64 | 1 |
| 729 | warped_door | 990 | 24935 | 64 | 1 |
| 730 | crimson_sign | 991 | 24999 | 32 | 1 |
| 731 | warped_sign | 992 | 25031 | 32 | 1 |
| 732 | crimson_wall_sign | 993 | 25063 | 8 | 1 |
| 733 | warped_wall_sign | 994 | 25071 | 8 | 1 |
| 734 | structure_block | 995 | 25079 | 4 | 1 |
| 735 | jigsaw | 996 | 25083 | 12 | 1 |
| 736 | test_block | 997 | 25095 | 4 | 1 |
| 737 | test_instance_block | 998 | 25099 | 1 | 1 |
| 738 | composter | 999 | 25100 | 9 | 1 |
| 739 | target | 1000 | 25109 | 16 | 1 |
| 740 | bee_nest | 1001 | 25125 | 24 | 1 |
| 741 | beehive | 1002 | 25149 | 24 | 1 |
| 742 | honey_block | 1003 | 25173 | 1 | 1 |
| 743 | honeycomb_block | 1004 | 25174 | 1 | 1 |
| 744 | netherite_block | 1005 | 25175 | 1 | 1 |
| 745 | ancient_debris | 1006 | 25176 | 1 | 1 |
| 746 | crying_obsidian | 1007 | 25177 | 1 | 1 |
| 747 | respawn_anchor | 1008 | 25178 | 5 | 1 |
| 748 | potted_crimson_fungus | 1009 | 25183 | 1 | 1 |
| 749 | potted_warped_fungus | 1010 | 25184 | 1 | 1 |
| 750 | potted_crimson_roots | 1011 | 25185 | 1 | 1 |
| 751 | potted_warped_roots | 1012 | 25186 | 1 | 1 |
| 752 | lodestone | 1013 | 25187 | 1 | 1 |
| 753 | blackstone | 1014 | 25188 | 1 | 1 |
| 754 | blackstone_stairs | 1015 | 25189 | 80 | 1 |
| 755 | blackstone_wall | 1016 | 25269 | 324 | 1 |
| 756 | blackstone_slab | 1017 | 25593 | 6 | 1 |
| 757 | polished_blackstone | 1018 | 25599 | 1 | 1 |
| 758 | polished_blackstone_bricks | 1019 | 25600 | 1 | 1 |
| 759 | cracked_polished_blackstone_bricks | 1020 | 25601 | 1 | 1 |
| 760 | chiseled_polished_blackstone | 1021 | 25602 | 1 | 1 |
| 761 | polished_blackstone_brick_slab | 1022 | 25603 | 6 | 1 |
| 762 | polished_blackstone_brick_stairs | 1023 | 25609 | 80 | 1 |
| 763 | polished_blackstone_brick_wall | 1024 | 25689 | 324 | 1 |
| 764 | gilded_blackstone | 1025 | 26013 | 1 | 1 |
| 765 | polished_blackstone_stairs | 1026 | 26014 | 80 | 1 |
| 766 | polished_blackstone_slab | 1027 | 26094 | 6 | 1 |
| 767 | polished_blackstone_pressure_plate | 1028 | 26100 | 2 | 1 |
| 768 | polished_blackstone_button | 1029 | 26102 | 24 | 1 |
| 769 | polished_blackstone_wall | 1030 | 26126 | 324 | 1 |
| 770 | chiseled_nether_bricks | 1031 | 26450 | 1 | 1 |
| 771 | cracked_nether_bricks | 1032 | 26451 | 1 | 1 |
| 772 | quartz_bricks | 1033 | 26452 | 1 | 1 |
| 773 | candle | 1034 | 26453 | 16 | 1 |
| 774 | dyed_candle | 1035-1050 | 26469 | 256 | 16 |
| 775 | candle_cake | 1051 | 26725 | 2 | 1 |
| 776 | dyed_candle_cake | 1052-1067 | 26727 | 32 | 16 |
| 777 | amethyst_block | 1068 | 26759 | 1 | 1 |
| 778 | budding_amethyst | 1069 | 26760 | 1 | 1 |
| 779 | amethyst_cluster | 1070 | 26761 | 12 | 1 |
| 780 | large_amethyst_bud | 1071 | 26773 | 12 | 1 |
| 781 | medium_amethyst_bud | 1072 | 26785 | 12 | 1 |
| 782 | small_amethyst_bud | 1073 | 26797 | 12 | 1 |
| 783 | tuff | 1074 | 26809 | 1 | 1 |
| 784 | tuff_slab | 1075 | 26810 | 6 | 1 |
| 785 | tuff_stairs | 1076 | 26816 | 80 | 1 |
| 786 | tuff_wall | 1077 | 26896 | 324 | 1 |
| 787 | polished_tuff | 1078 | 27220 | 1 | 1 |
| 788 | polished_tuff_slab | 1079 | 27221 | 6 | 1 |
| 789 | polished_tuff_stairs | 1080 | 27227 | 80 | 1 |
| 790 | polished_tuff_wall | 1081 | 27307 | 324 | 1 |
| 791 | chiseled_tuff | 1082 | 27631 | 1 | 1 |
| 792 | tuff_bricks | 1083 | 27632 | 1 | 1 |
| 793 | tuff_brick_slab | 1084 | 27633 | 6 | 1 |
| 794 | tuff_brick_stairs | 1085 | 27639 | 80 | 1 |
| 795 | tuff_brick_wall | 1086 | 27719 | 324 | 1 |
| 796 | chiseled_tuff_bricks | 1087 | 28043 | 1 | 1 |
| 797 | sulfur | 1088 | 28044 | 1 | 1 |
| 798 | potent_sulfur | 1089 | 28045 | 5 | 1 |
| 799 | sulfur_slab | 1090 | 28050 | 6 | 1 |
| 800 | sulfur_stairs | 1091 | 28056 | 80 | 1 |
| 801 | sulfur_wall | 1092 | 28136 | 324 | 1 |
| 802 | polished_sulfur | 1093 | 28460 | 1 | 1 |
| 803 | polished_sulfur_slab | 1094 | 28461 | 6 | 1 |
| 804 | polished_sulfur_stairs | 1095 | 28467 | 80 | 1 |
| 805 | polished_sulfur_wall | 1096 | 28547 | 324 | 1 |
| 806 | sulfur_bricks | 1097 | 28871 | 1 | 1 |
| 807 | sulfur_brick_slab | 1098 | 28872 | 6 | 1 |
| 808 | sulfur_brick_stairs | 1099 | 28878 | 80 | 1 |
| 809 | sulfur_brick_wall | 1100 | 28958 | 324 | 1 |
| 810 | chiseled_sulfur | 1101 | 29282 | 1 | 1 |
| 811 | cinnabar | 1102 | 29283 | 1 | 1 |
| 812 | cinnabar_slab | 1103 | 29284 | 6 | 1 |
| 813 | cinnabar_stairs | 1104 | 29290 | 80 | 1 |
| 814 | cinnabar_wall | 1105 | 29370 | 324 | 1 |
| 815 | polished_cinnabar | 1106 | 29694 | 1 | 1 |
| 816 | polished_cinnabar_slab | 1107 | 29695 | 6 | 1 |
| 817 | polished_cinnabar_stairs | 1108 | 29701 | 80 | 1 |
| 818 | polished_cinnabar_wall | 1109 | 29781 | 324 | 1 |
| 819 | cinnabar_bricks | 1110 | 30105 | 1 | 1 |
| 820 | cinnabar_brick_slab | 1111 | 30106 | 6 | 1 |
| 821 | cinnabar_brick_stairs | 1112 | 30112 | 80 | 1 |
| 822 | cinnabar_brick_wall | 1113 | 30192 | 324 | 1 |
| 823 | chiseled_cinnabar | 1114 | 30516 | 1 | 1 |
| 824 | calcite | 1115 | 30517 | 1 | 1 |
| 825 | tinted_glass | 1116 | 30518 | 1 | 1 |
| 826 | powder_snow | 1117 | 30519 | 1 | 1 |
| 827 | sculk_sensor | 1118 | 30520 | 96 | 1 |
| 828 | calibrated_sculk_sensor | 1119 | 30616 | 384 | 1 |
| 829 | sculk | 1120 | 31000 | 1 | 1 |
| 830 | sculk_vein | 1121 | 31001 | 128 | 1 |
| 831 | sculk_catalyst | 1122 | 31129 | 2 | 1 |
| 832 | sculk_shrieker | 1123 | 31131 | 8 | 1 |
| 833 | copper_block | 1124-1131 | 31139 | 8 | 8 |
| 834 | copper_ore | 1132 | 31147 | 1 | 1 |
| 835 | deepslate_copper_ore | 1133 | 31148 | 1 | 1 |
| 836 | cut_copper | 1134-1141 | 31149 | 8 | 8 |
| 837 | chiseled_copper | 1142-1149 | 31157 | 8 | 8 |
| 838 | cut_copper_stairs | 1150-1157 | 31165 | 640 | 8 |
| 839 | cut_copper_slab | 1158-1165 | 31805 | 48 | 8 |
| 840 | copper_door | 1166-1173 | 31853 | 512 | 8 |
| 841 | copper_trapdoor | 1174-1181 | 32365 | 512 | 8 |
| 842 | copper_grate | 1182-1189 | 32877 | 16 | 8 |
| 843 | copper_bulb | 1190-1197 | 32893 | 32 | 8 |
| 844 | copper_chest | 1198-1205 | 32925 | 192 | 8 |
| 845 | copper_golem_statue | 1206-1213 | 33117 | 256 | 8 |
| 846 | lightning_rod | 1214-1221 | 33373 | 192 | 8 |
| 847 | dripstone_block | 1222 | 33565 | 1 | 1 |
| 848 | pointed_dripstone | 1223 | 33566 | 20 | 1 |
| 849 | sulfur_spike | 1224 | 33586 | 20 | 1 |
| 850 | cave_vines | 1225 | 33606 | 52 | 1 |
| 851 | cave_vines_plant | 1226 | 33658 | 2 | 1 |
| 852 | spore_blossom | 1227 | 33660 | 1 | 1 |
| 853 | azalea | 1228 | 33661 | 1 | 1 |
| 854 | flowering_azalea | 1229 | 33662 | 1 | 1 |
| 855 | moss_carpet | 1230 | 33663 | 1 | 1 |
| 856 | pink_petals | 1231 | 33664 | 16 | 1 |
| 857 | wildflowers | 1232 | 33680 | 16 | 1 |
| 858 | leaf_litter | 1233 | 33696 | 16 | 1 |
| 859 | moss_block | 1234 | 33712 | 1 | 1 |
| 860 | big_dripleaf | 1235 | 33713 | 32 | 1 |
| 861 | big_dripleaf_stem | 1236 | 33745 | 8 | 1 |
| 862 | small_dripleaf | 1237 | 33753 | 16 | 1 |
| 863 | hanging_roots | 1238 | 33769 | 2 | 1 |
| 864 | rooted_dirt | 1239 | 33771 | 1 | 1 |
| 865 | mud | 1240 | 33772 | 1 | 1 |
| 866 | deepslate | 1241 | 33773 | 3 | 1 |
| 867 | cobbled_deepslate | 1242 | 33776 | 1 | 1 |
| 868 | cobbled_deepslate_stairs | 1243 | 33777 | 80 | 1 |
| 869 | cobbled_deepslate_slab | 1244 | 33857 | 6 | 1 |
| 870 | cobbled_deepslate_wall | 1245 | 33863 | 324 | 1 |
| 871 | polished_deepslate | 1246 | 34187 | 1 | 1 |
| 872 | polished_deepslate_stairs | 1247 | 34188 | 80 | 1 |
| 873 | polished_deepslate_slab | 1248 | 34268 | 6 | 1 |
| 874 | polished_deepslate_wall | 1249 | 34274 | 324 | 1 |
| 875 | deepslate_tiles | 1250 | 34598 | 1 | 1 |
| 876 | deepslate_tile_stairs | 1251 | 34599 | 80 | 1 |
| 877 | deepslate_tile_slab | 1252 | 34679 | 6 | 1 |
| 878 | deepslate_tile_wall | 1253 | 34685 | 324 | 1 |
| 879 | deepslate_bricks | 1254 | 35009 | 1 | 1 |
| 880 | deepslate_brick_stairs | 1255 | 35010 | 80 | 1 |
| 881 | deepslate_brick_slab | 1256 | 35090 | 6 | 1 |
| 882 | deepslate_brick_wall | 1257 | 35096 | 324 | 1 |
| 883 | chiseled_deepslate | 1258 | 35420 | 1 | 1 |
| 884 | cracked_deepslate_bricks | 1259 | 35421 | 1 | 1 |
| 885 | cracked_deepslate_tiles | 1260 | 35422 | 1 | 1 |
| 886 | infested_deepslate | 1261 | 35423 | 3 | 1 |
| 887 | smooth_basalt | 1262 | 35426 | 1 | 1 |
| 888 | raw_iron_block | 1263 | 35427 | 1 | 1 |
| 889 | raw_copper_block | 1264 | 35428 | 1 | 1 |
| 890 | raw_gold_block | 1265 | 35429 | 1 | 1 |
| 891 | potted_azalea | 1266 | 35430 | 1 | 1 |
| 892 | potted_flowering_azalea | 1267 | 35431 | 1 | 1 |
| 893 | ochre_froglight | 1268 | 35432 | 3 | 1 |
| 894 | verdant_froglight | 1269 | 35435 | 3 | 1 |
| 895 | pearlescent_froglight | 1270 | 35438 | 3 | 1 |
| 896 | frogspawn | 1271 | 35441 | 1 | 1 |
| 897 | reinforced_deepslate | 1272 | 35442 | 1 | 1 |
| 898 | decorated_pot | 1273 | 35443 | 16 | 1 |
| 899 | crafter | 1274 | 35459 | 48 | 1 |
| 900 | trial_spawner | 1275 | 35507 | 12 | 1 |
| 901 | vault | 1276 | 35519 | 32 | 1 |
| 902 | heavy_core | 1277 | 35551 | 2 | 1 |
| 903 | pale_moss_block | 1278 | 35553 | 1 | 1 |
| 904 | pale_moss_carpet | 1279 | 35554 | 162 | 1 |
| 905 | pale_hanging_moss | 1280 | 35716 | 2 | 1 |
| 906 | open_eyeblossom | 1281 | 35718 | 1 | 1 |
| 907 | closed_eyeblossom | 1282 | 35719 | 1 | 1 |
| 908 | potted_open_eyeblossom | 1283 | 35720 | 1 | 1 |
| 909 | potted_closed_eyeblossom | 1284 | 35721 | 1 | 1 |
| 910 | firefly_bush | 1285 | 35722 | 1 | 1 |
