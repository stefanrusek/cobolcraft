# Block registry, part 1: shared model and the foundation blocks (Blocks fields 0 to 104)

| Item | Value |
|---|---|
| Covers | The shared model that every part of the block registry cites: how block ids and block state ids are assigned, the `BlockBehaviour.Properties` builder and its defaults, the per-state values derived from it, the voxel shape model, the schema of every per-block column, the tint-class and placement-rule columns, the block and item relationship, and the block tag model with the tags that code reads by name. Rows for `Blocks` fields 0 to 104, `AIR` (id 0) through `ORANGE_POPLAR_LEAVES` (id 104): air, the stone family, dirt and grass, cobblestone, planks, saplings, bedrock, water, lava, sand, gravel, ores, logs, wood, stripped variants, leaves up to `ORANGE_POPLAR_LEAVES`. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas), with no execution. The classes read are named in backticks where a fact is given. Values not read are marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions. |
| Status | Round RS4, part 1 of 8 (design map Part 5 GAP-1, and the columns of GAP-29 and GAP-30) |
| Siblings | Parts 2 to 8 cover the remaining `Blocks` fields in field order (fields 105 onward) and cite this document for every column definition: [24-block-registry-2-leaves-flora-signs.md](24-block-registry-2-leaves-flora-signs.md), [24-block-registry-3-signs-doors-redstone.md](24-block-registry-3-signs-doors-redstone.md), [24-block-registry-4-stems-glass-skulls.md](24-block-registry-4-stems-glass-skulls.md), [24-block-registry-5-quartz-concrete-gates.md](24-block-registry-5-quartz-concrete-gates.md), [24-block-registry-6-gates-end-concrete-potted.md](24-block-registry-6-gates-end-concrete-potted.md), [24-block-registry-7-stairs-slabs-walls-workstations.md](24-block-registry-7-stairs-slabs-walls-workstations.md), [24-block-registry-8-blackstone-copper-deepslate-modern.md](24-block-registry-8-blackstone-copper-deepslate-modern.md). Cite them as "24 part N". Document 46 (static registry ids) cites "other (24)" for the block registry. |

Class, method and field names in backticks say where a fact was read. They are not the design. "04 §5" means section 5 of
[04-registry-sync.md](04-registry-sync.md); "13 §2" means section 2 of
[13-client-gameplay-and-controls.md](13-client-gameplay-and-controls.md), and so on. The design map is
`docs/design/README.md`.

Data versus code (design map R7). The block registry is code: ids, properties, state numbering, shapes, behaviours,
tint rules. This document specifies all of that for its rows. It does not tabulate data that the extraction tool
copies out of the jar (block models and block states JSON, loot tables, recipes, tag files); it specifies the
schema and the engines that read them. The block tag file contents are data; the tag names that code reads are code
and are listed in section 12.

## Contents

1. Scope, conventions, the sibling index
2. The block id rule
3. The block state id rule
4. The `Properties` builder
5. Values derived per state
6. The shape model
7. Column definitions
8. Enumerations used by the columns
9. Tint classes (GAP-29 columns)
10. Placement columns (GAP-30 columns)
11. Blocks and items
12. Block tags
13. Property definitions used by the rows of this part
14. Block classes of the rows of this part
15. The rows: fields 0 to 104
16. Worked examples
17. Validation
18. Open questions

---

## 1. Scope, conventions, the sibling index

- Row order is registry order: row N is the block whose numeric id is N (valid for all rows of this part, section 2).
- A "field" means a `public static final` field of `net.minecraft.world.level.block.Blocks`. There are 911 of them
  (counted from the class, fields numbered from 0). Field index and registry id coincide only for the fields before
  the first collection field, that is fields 0 to 118. Field 119 is `BED`, the first collection: it starts at id 119
  and registers 16 blocks (ids 119 to 134), so from field 120 on the id is the field index plus the extra
  registrations of every collection before it (section 2.3 has the table of all 33 collection fields with their
  first ids).
- Numbers are as written in the artifact. `f` suffixes are dropped in tables; a hardness shown as `2.0` is the float
  2.0.
- Where a column value is a name from an enumeration, section 8 lists the enumeration.
- Part 1 rows list the behaviour class of each block (section 14) and where a class carries behaviour that other
  documents specify (fluids, falling blocks, tree growth), this document says only what the registry needs and cites
  the document that owns the behaviour: random ticks 33 §2.4; block updates, placement and breaking 29 (§2 to §3, §9, §10); falling blocks 29b-1 §3; crops,
  stems, saplings 29b-1 §7 and 29b-2; spreading blocks, leaves, snow and ice 29b-3 (§3, §5); fungi, moss and copper
  29b-5; light (consumes the emission, dampening and occlusion of section 5.2) 32 §2; tint behaviour 43 (owner of the
  tint sources, the biome blend radius and the cache; section 9 here only indexes them and defers to 43 wherever the two
  could differ). Fluids (design map RS10), pistons (RS12) and block entities 31 have no numbered document for the fluid
  and piston rules yet and keep their design-map codes.
- Related existing documents: 04 §5 (id rules), 06 §5 (chunk palettes), 13 §2 (break time), 17 Appendix A
  (`mineable/*`), 17 §3.3a (flammability), 43 (tint sources), 11 §8 (ore blocks), 46 §14.3 (sound event table).

Sibling index (parts are by `Blocks` field order; the exact field boundaries are in each part's own header):

| Part | Fields | File |
|---|---|---|
| 1 (this document) | 0 to 104 | model, foundation blocks (this file) |
| 2 | from 105 | [24-block-registry-2-leaves-flora-signs.md](24-block-registry-2-leaves-flora-signs.md) |
| 3 | after part 2 | [24-block-registry-3-signs-doors-redstone.md](24-block-registry-3-signs-doors-redstone.md) |
| 4 | after part 3 | [24-block-registry-4-stems-glass-skulls.md](24-block-registry-4-stems-glass-skulls.md) |
| 5 | after part 4 | [24-block-registry-5-quartz-concrete-gates.md](24-block-registry-5-quartz-concrete-gates.md) |
| 6 | after part 5 | [24-block-registry-6-gates-end-concrete-potted.md](24-block-registry-6-gates-end-concrete-potted.md) |
| 7 | after part 6 | [24-block-registry-7-stairs-slabs-walls-workstations.md](24-block-registry-7-stairs-slabs-walls-workstations.md) |
| 8 | up to field 910 | [24-block-registry-8-blackstone-copper-deepslate-modern.md](24-block-registry-8-blackstone-copper-deepslate-modern.md) |

Parts 2 to 8 together cover fields 105 to 910 and cite sections 2 to 12 here.

## 2. The block id rule

### 2.1 Registration

1. `net.minecraft.core.registries.BuiltInRegistries.BLOCK` is a defaulted registry (default key `air`, see 46).
2. `Blocks.<clinit>` calls one private static `register` helper per block. The helper takes either a `BlockItemId` or
   a `ResourceKey<Block>`, a factory function from `Properties` to a `Block`, and a `Properties`. It stores the key in
   the properties (`Properties.setId`), constructs the block with the factory and registers it in `BLOCK` under the key.
   The overload without a factory constructs a plain `Block`.
3. The numeric id of a block is the registration index: the number of blocks registered before it, starting at 0
   (`MappedRegistry.register`, 04 §5.1).

### 2.2 Order

- The order of registration is the order of the `putstatic` instructions in `Blocks.<clinit>`. That sequence was
  compared with the order of the field declarations of the class: the two sequences are identical for all 911 fields
  (read from the class file).
- Field declaration order is therefore the registration order. There is no separate ordering table.
- Keys:
  - For a block with an item, the key comes from `references.BlockItemIds.<FIELD>`. A `BlockItemId` is a record of a
    block key and an item key (`BlockItemId.block()`, `BlockItemId.item()`), built from one path string in the default
    namespace `minecraft`.
  - For a block without an item the key comes from `references.BlockIds.<FIELD>`. In this part: `WATER` and `LAVA`.
  - For all 105 rows of this part the key is the lower-case field name. (The exceptions between field name and key
    elsewhere, for example `REDSTONE_DUST` whose block key is `redstone_wire`, belong to later parts.)

### 2.3 Collections

The collection fields expand into several registrations. The expansion is done by the collection's own
`registerBlocks` method (or, for four of the colour fields, by a `zipMap` over the 16 colours with a stair or slab
registration helper), which is called from `Blocks.<clinit>` in the position of the field.

| Collection | Registrations per field | Expansion rule |
|---|---|---|
| `ColorCollection<T>` (`net.minecraft.world.level.block.ColorCollection`) | 16 | A record of 16 values in the dye order below. `registerBlocks(id, factory, ..)` calls `zipMap` over the 16 dye colours, so the 16 blocks are registered in this order, consecutively, in the position of the field. The block key of each colour is the colour name joined to the base name by an underscore, colour first: `prefixWithColor` is a string concatenation whose recipe constant is `\u0001_\u0001` (read from the constant pool of the `makeConcatWithConstants` call), the colour being the first operand. |
| `WeatheringCopperCollection` | 8 | Two `ByState` records of four values each (`unaffected`, `exposed`, `weathered`, `oxidized`): the weathering record first, then the waxed record (`registerBlocks` applies the weathering function before the waxed function, and `ByState.map` evaluates the four values in that order). The key prefixes are, in order: (empty), `exposed_`, `weathered_`, `oxidized_` for the weathering record and `waxed_`, `waxed_exposed_`, `waxed_weathered_`, `waxed_oxidized_` for the waxed record (`PREFIXES`, read). How each prefix is joined to the base name of a block is specified in the part that covers the field (the base names of some collections differ from the field name). |

Dye order of `ColorCollection` (`VALUES`): white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray,
cyan, purple, blue, brown, green, red, black. (Read from the record component order and from the static initialiser.)

Collection fields of `Blocks` (all 33, read from the field types; field numbers start at 0). "First id" is the registry
id of the first block of the field, computed as field number plus the extra registrations of the collection fields
before it (each earlier collection adds its count minus 1); the computation assumes that every other field registers
exactly one block and that the four `zipMap` colour fields register 16 blocks each (both read from the `registerBlocks`
and `zipMap` call counts in `Blocks.<clinit>`: 14 `ColorCollection.registerBlocks` calls plus 4 `zipMap` fields give the
18 colour fields, and 15 `WeatheringCopperCollection.registerBlocks` calls give the 15 weathering fields). The ids were not
checked against a data-generator dump.

| Field no. | Field | Kind | Blocks | Ids (first to last) |
|---|---|---|---|---|
| 119 | `BED` | colour | 16 | 119 to 134 |
| 136 | `WOOL` | colour | 16 | 151 to 166 |
| 137 | `WOOL_STAIRS` | colour (zipMap) | 16 | 167 to 182 |
| 138 | `WOOL_SLAB` | colour (zipMap) | 16 | 183 to 198 |
| 289 | `STAINED_GLASS` | colour | 16 | 349 to 364 |
| 317 | `COPPER_BARS` | weathering | 8 | 392 to 399 |
| 319 | `COPPER_CHAIN` | weathering | 8 | 401 to 408 |
| 448 | `DYED_TERRACOTTA` | colour | 16 | 537 to 552 |
| 449 | `STAINED_GLASS_PANE` | colour | 16 | 553 to 568 |
| 473 | `CARPET` | colour | 16 | 592 to 607 |
| 483 | `BANNER` | colour | 16 | 617 to 632 |
| 484 | `WALL_BANNER` | colour | 16 | 633 to 648 |
| 572 | `DYED_SHULKER_BOX` | colour | 16 | 736 to 751 |
| 573 | `GLAZED_TERRACOTTA` | colour | 16 | 752 to 767 |
| 574 | `CONCRETE` | colour | 16 | 768 to 783 |
| 575 | `CONCRETE_STAIRS` | colour (zipMap) | 16 | 784 to 799 |
| 576 | `CONCRETE_SLAB` | colour (zipMap) | 16 | 800 to 815 |
| 577 | `CONCRETE_POWDER` | colour | 16 | 816 to 831 |
| 687 | `COPPER_LANTERN` | weathering | 8 | 941 to 948 |
| 774 | `DYED_CANDLE` | colour | 16 | 1035 to 1050 |
| 776 | `DYED_CANDLE_CAKE` | colour | 16 | 1052 to 1067 |
| 833 | `COPPER_BLOCK` | weathering | 8 | 1124 to 1131 |
| 836 | `CUT_COPPER` | weathering | 8 | 1134 to 1141 |
| 837 | `CHISELED_COPPER` | weathering | 8 | 1142 to 1149 |
| 838 | `CUT_COPPER_STAIRS` | weathering | 8 | 1150 to 1157 |
| 839 | `CUT_COPPER_SLAB` | weathering | 8 | 1158 to 1165 |
| 840 | `COPPER_DOOR` | weathering | 8 | 1166 to 1173 |
| 841 | `COPPER_TRAPDOOR` | weathering | 8 | 1174 to 1181 |
| 842 | `COPPER_GRATE` | weathering | 8 | 1182 to 1189 |
| 843 | `COPPER_BULB` | weathering | 8 | 1190 to 1197 |
| 844 | `COPPER_CHEST` | weathering | 8 | 1198 to 1205 |
| 845 | `COPPER_GOLEM_STATUE` | weathering | 8 | 1206 to 1213 |
| 846 | `LIGHTNING_ROD` | weathering | 8 | 1214 to 1221 |

Under the same assumption the total block count is 911 + 18 * 15 + 15 * 7 = 1286 (ids 0 to 1285).

Special cases:

- `VOID_AIR` (field 630) and `CAVE_AIR` (field 631) are ordinary registrations in field order, with keys from
  `BlockIds`, the same properties as `AIR` (replaceable, no collision, no loot table, air) and the same factory
  (`AirBlock`). They have no item. They are not at the start of the registry: only `AIR` is id 0. Field 632 is
  `BUBBLE_COLUMN`. By the table above their ids are 884 (`VOID_AIR`), 885 (`CAVE_AIR`) and 886 (`BUBBLE_COLUMN`).
- Field 120 is the plain block `STRAW_BED` (id 135) and field 121 is `POWERED_RAIL` (id 136), directly after the 16 beds.
- There is no field named `LEGACY...` in `Blocks`. `Properties.ofLegacyCopy` is a builder method (section 4.3), not a
  registry placement rule.
- Field 20 `PALE_OAK_WOOD` is declared (and registered) before field 21 `PALE_OAK_PLANKS`. The order of the wood types in
  the planks run is: oak, spruce, birch, jungle, acacia, cherry, dark oak, pale oak wood, pale oak planks, mangrove,
  poplar, bamboo planks, bamboo mosaic. Do not assume alphabetical or per-family order.

Worked example, ids: `AIR` 0, `STONE` 1, `GRASS_BLOCK` 8, `DIRT` 9, `OAK_PLANKS` 13, `PALE_OAK_WOOD` 20,
`OAK_SAPLING` 26, `BEDROCK` 36, `WATER` 37, `LAVA` 38, `OAK_LOG` 51, `OAK_LEAVES` 94, `ORANGE_POPLAR_LEAVES` 104
(section 15).

## 3. The block state id rule

The numbering is specified in 04 §5.2; this section restates what a block table needs and adds facts read in this
round.

1. After all blocks are registered, a lambda in `Blocks.<clinit>` walks `BuiltInRegistries.BLOCK` in registry order.
   For each block it walks `getStateDefinition().getPossibleStates()` in list order and, for every state, calls
   `Block.BLOCK_STATE_REGISTRY.add(state)` and then `state.initCache()`. The ids are contiguous from 0; a block owns a
   consecutive range.
2. The state list of a block is the Cartesian product of its properties' value lists (04 §5.2): properties sorted by
   name (natural `String` order, `StateDefinition.propertiesByName` is an `ImmutableSortedMap`), the first property
   varying slowest, the last fastest. The order in which the block declares its properties is irrelevant.
3. Value order: Boolean `true`, `false`; integer `min` up to `max`; enum in the order given at creation (all constants
   in declaration order for `EnumProperty.create(name, class)`).
4. First state id of a block = sum of the state counts of all blocks with a lower id. In this part: state counts and
   first ids are in the rows (section 15). Id 105, the first block of part 2, has first state id 575.
5. The default state is set by the block constructor through `registerDefaultState`, starting from
   `StateDefinition.any()` (the first state) and then calling `setValue` for each property (read in the classes of
   section 14). The default is therefore not always the first state. The row column "default id" is the state id of
   the default state.
6. Block state ids on the wire and in chunk palettes: 04 §5.3, 06 §5.

Index formula for a block with properties P0..Pk-1 in sorted-name order: see 04 §5.2.

## 4. The `Properties` builder

`net.minecraft.world.level.block.state.BlockBehaviour$Properties` is a mutable builder; every setter returns the
builder. `BlockBehaviour`'s constructor copies a subset into `final` fields of the block (`hasCollision`,
`explosionResistance`, `isRandomlyTicking`, `soundType`, `friction`, `speedFactor`, `jumpFactor`, `bounceRestitution`,
`fallDistanceReduction`, `dynamicShape`, `requiredFeatures`, the loot table key and the description id) and keeps the
builder itself in `properties`; each `BlockState` copies the rest at construction (section 5).

### 4.1 Defaults (set by the private constructor, `Properties.of()` returns a new builder with these)

| Field | Default |
|---|---|
| map colour function | constant `MapColor.NONE` (id 0) |
| hasCollision | true |
| soundType | `SoundType.STONE` |
| lightEmission function | constant 0 |
| friction | 0.6 |
| speedFactor | 1.0 |
| jumpFactor | 1.0 |
| drops (loot table key) | a function of the block key: `<namespace>:blocks/<path>` in the `loot_table` registry (the path gets the prefix `blocks/`) |
| descriptionId | `block.<namespace>.<path>` (`Util.makeDescriptionId("block", key)`) |
| canOcclude | true |
| pushReaction | `PUSH_PULL` |
| spawnTerrainParticles | true |
| instrument | `HARP` |
| isValidSpawn | true when the state's top face is sturdy (`isFaceSturdy` UP, support type FULL) and the state's light emission is below 14 |
| isRedstoneConductor | `BlockState.isCollisionShapeFullBlock` |
| isSuffocating | true when the state is in tag `causes_suffocation` and its collision shape is a full block |
| isViewBlocking | the state's `isSuffocating` (the box argument is ignored) |
| postProcess | none (a function that returns no position) |
| emissiveRendering | false |
| requiredFeatures | the vanilla feature set |
| left at the Java default | destroyTime 0.0, explosionResistance 0.0, bounceRestitution 0.0, fallDistanceReduction 0.0, requiresCorrectToolForDrops false, isRandomlyTicking false, isAir false, ignitedByLava false, liquid false, forceSolidOff false, forceSolidOn false, replaceable false, dynamicShape false, offsetFunction none |

### 4.2 Setters

| Setter | Effect |
|---|---|
| `mapColor(MapColor)` / `mapColor(DyeColor)` / `mapColor(Function<BlockState, MapColor>)` | sets the map colour function. A `DyeColor` uses that colour's map colour. A function gives a state-dependent colour. |
| `noCollision()` | hasCollision false **and** canOcclude false |
| `noOcclusion()` | canOcclude false only (the collision shape is kept) |
| `friction(f)`, `speedFactor(f)`, `jumpFactor(f)`, `bounceRestitution(f)`, `fallDistanceReduction(f)` | set the named field |
| `sound(SoundType)` | soundType |
| `lightLevel(ToIntFunction<BlockState>)` | light emission per state (not clamped in the setter) |
| `strength(h, r)` | `destroyTime(h)` and `explosionResistance(r)` |
| `strength(v)` | `strength(v, v)` |
| `instabreak()` | `strength(0)` (hardness 0 and resistance 0) |
| `destroyTime(h)` | sets hardness. A negative value is stored as is (bedrock uses -1.0). |
| `explosionResistance(r)` | stores `max(0, r)` |
| `requiresCorrectToolForDrops()` | flag |
| `randomTicks()` | isRandomlyTicking true (the block receives random ticks) |
| `dynamicShape()` | marks that the shape depends on the position or neighbours, so no per-state shape cache is built |
| `noLootTable()` | the loot table key is "none" (an empty `Optional`) |
| `overrideLootTable(Optional<key>)` | fixed loot table key |
| `overrideDescription(String)` | fixed description id |
| `ignitedByLava()` | flag read by the fire rules |
| `liquid()` | flag |
| `forceSolidOn()` / `forceSolidOff()` | override of the derived `isSolid` (section 5.2) |
| `pushReaction(PushReaction)` | piston behaviour |
| `air()` | isAir true |
| `isValidSpawn(pred)`, `isRedstoneConductor(pred)`, `isSuffocating(pred)`, `isViewBlocking(pred)` | replace the default predicate |
| `postProcess(fn)` | position that gets a post-processing pass after chunk load (`getPostProcessPos`) |
| `emissiveRendering(pred)` | render the state at full brightness |
| `noTerrainParticles()` | spawnTerrainParticles false |
| `requiredFeatures(flags...)` | sets the feature set (used by blocks that belong to a data-pack feature flag) |
| `instrument(NoteBlockInstrument)` | instrument that a note block above this block plays |
| `replaceable()` | the replaceable flag (section 10.1) |
| `offsetType(OffsetType)` | `NONE` clears the offset function; `XZ` and `XYZ` install the offset functions of section 4.4 |
| `setId(ResourceKey<Block>)` | the key; required before `effectiveDrops` and `effectiveDescriptionId` are read, otherwise the builder fails with "Block id not set" |

### 4.3 Copying builders

| Method | Fields copied from the source block's builder |
|---|---|
| `ofLegacyCopy(block)` | destroyTime, explosionResistance, hasCollision, isRandomlyTicking, lightEmission, mapColor, soundType, friction, speedFactor, bounceRestitution, dynamicShape, canOcclude, isAir, ignitedByLava, liquid, forceSolidOff, forceSolidOn, pushReaction, requiresCorrectToolForDrops, offsetFunction, spawnTerrainParticles, requiredFeatures, emissiveRendering, instrument, replaceable. **Not copied:** jumpFactor, fallDistanceReduction, the predicates isValidSpawn, isRedstoneConductor, isSuffocating, isViewBlocking, postProcess, the loot table key and the description id (these take the defaults, so the copy gets a loot table named after its own key). |
| `ofFullCopy(block)` | everything of `ofLegacyCopy`, plus jumpFactor, isRedstoneConductor, isValidSpawn, postProcess, isSuffocating, isViewBlocking, drops, descriptionId |

In this part `ofLegacyCopy` is used by the deepslate ores, which copy the ore (including "requires correct tool" and
the instrument) and then override map colour, strength and sound (section 15).

### 4.4 Offset functions

The offset of a block with an offset type is a function of the block position (`BlockState.getOffset`):

Seed: `Mth.getSeed(x, y, z)`. Let `a = (x * 3129871)` as a 32-bit integer product widened to 64 bits, `b = z * 116129781L`
in 64 bits, `s0 = a XOR b XOR y`. Then `s1 = s0 * s0 * 42317861L + s0 * 11L` (64-bit wrap-around) and the result is `s1`
shifted right arithmetically by 16.

For both types the seed is taken with y = 0. With `h` = the block's maximum horizontal offset (default 0.25,
`getMaxHorizontalOffset`) and `v` = maximum vertical offset (default 0.2, `getMaxVerticalOffset`):

| Type | dx | dy | dz |
|---|---|---|---|
| `XZ` | clamp(((seed AND 15) / 15 - 0.5) * 0.5, -h, h) | 0 | clamp((((seed >> 8) AND 15) / 15 - 0.5) * 0.5, -h, h) |
| `XYZ` | as `XZ` | (((seed >> 4) AND 15) / 15 - 1.0) * v | as `XZ` |

(The first `AND 15` and the divisions are done in float, then widened to double; the clamp is on doubles.)
A block with a collision shape and an offset type must be marked `dynamicShape()`, otherwise the shape cache build
fails with an error naming the block (read in `BlockStateBase$Cache`).

## 5. Values derived per state

`BlockBehaviour$BlockStateBase` (the base of `BlockState`) computes these when the state is constructed and in
`initCache()` (section 3, step 1).

### 5.1 Copied at construction

lightEmission (the light function applied to the state), useShapeForLightOcclusion (a `Block` method, default false),
isAir, ignitedByLava, liquid, pushReaction, mapColor (the function applied to the state), destroySpeed (= hardness),
requiresCorrectToolForDrops, canOcclude, the four predicates, postProcess, emissiveRendering, offsetFunction,
spawnTerrainParticles, instrument, replaceable.

### 5.2 Computed in `initCache`

| Value | Rule |
|---|---|
| fluidState | `Block.getFluidState(state)`; default is the empty fluid's default state. The default is overridden for waterlogged blocks: `LeavesBlock`, `MangroveRootsBlock` and `MangrovePropaguleBlock` each override `getFluidState` so that `waterlogged` true gives the water fluid's source state (not flowing) and `waterlogged` false gives the default (empty). `LiquidBlock` overrides it too, by level (section 14) |
| isRandomlyTicking | `Block.isRandomlyTicking(state)`; default is the builder flag |
| shape cache | built only when the block is not `dynamicShape` (otherwise the cache is absent and the queries below compute on demand) |
| collisionShape | `Block.getCollisionShape(state, empty getter, origin, empty context)`: by default the state's shape when `hasCollision`, else the empty shape |
| largeCollisionShape | true when, for any axis, the collision shape's min is below 0 or its max is above 1 (a shape that sticks out of the block cell) |
| faceSturdy[direction][supportType] | for each of 6 directions and 3 support types, `SupportType.isSupporting(...)` (section 6.6) |
| isCollisionShapeFullBlock | whether the collision shape equals the full cube (section 6.5) |
| legacySolid (`isSolid`) | see the next table |
| occlusionShape | the empty shape when `canOcclude` is false, else `Block.getOcclusionShape(state)` (default: the state's shape evaluated with an empty getter at the origin) |
| solidRender | the occlusion shape is a full block |
| occlusionShapesByFace | the empty occlusion shape gives six empty faces; a full-block occlusion gives six full faces; else the face shape of the occlusion shape per direction (`VoxelShape.getFaceShape`) |
| propagatesSkylightDown | `Block.propagatesSkylightDown(state)`; default: the shape is not a full block **and** the state's fluid is empty |
| lightDampening | `Block.getLightDampening(state)`; default: 15 when `solidRender`, else 0 when `propagatesSkylightDown`, else 1 |

`isSolid` (legacySolid), first matching row wins:

| Condition | Result |
|---|---|
| builder `forceSolidOn` | true |
| builder `forceSolidOff` | false |
| no shape cache (dynamic shape) | false |
| collision shape empty | false |
| average of the three edge lengths of the collision shape's bounding box >= 0.7291666666666666 (35/48) | true |
| the bounding box's Y extent >= 1.0 | true |
| otherwise | false |

(`AABB.getSize` is the sum of the three extents divided by 3.0, read. The values of the reasons were read from the
`SolidDebugger$Reason` constants: `FORCE_SOLID_ON` true, `LARGE_ENOUGH_COLLISION_SHAPE` true,
`HIGH_ENOUGH_COLLISION_SHAPE` true, `FORCE_SOLID_OFF` false, `NULL_CACHE` false, `EMPTY_COLLISION_SHAPE` false and
`FALLTHROUGH` false; the last one is the "otherwise" row.)

Other derived queries:

| Query | Rule |
|---|---|
| `isLightPermeable` | `not solidRender` **or** `lightDampening == 0` |
| `isViewBlocking(box)` | the stored predicate (default: `isSuffocating`) |
| `getShadeBrightness` (ambient occlusion) | default: 0.2 when the collision shape is a full block, else 1.0 |
| `canBeReplaced()` | the builder's replaceable flag |
| `canBeReplaced(BlockPlaceContext)` | default: the flag is set **and** (the item in hand is empty **or** the held item is not this block's item); blocks may override |
| `canBeReplaced(Fluid)` | default: the flag is set **or** the state is not `isSolid` |
| `canSurvive(level, pos)` | default true (blocks override, section 10.2) |
| `getDestroyProgress(player, ...)` | the rule lives in `BlockBehaviour.getDestroyProgress(state, player, level, pos)`; `BlockStateBase.getDestroyProgress` only delegates to it. A destroy speed of exactly -1.0 gives 0; otherwise `player.getDestroySpeed(state) / destroySpeed / d` where d is 30 when `player.hasCorrectToolForDrops(state)` and 100 otherwise (the "break progress per tick"; see 13 §2.1) |
| `isFaceSturdy(level, pos, face)` | `isFaceSturdy(.., SupportType.FULL)`; reads the cache when present, else computes |
| render shape | default `RenderShape.MODEL`; `AirBlock` and `LiquidBlock` override `getRenderShape` and return `RenderShape.INVISIBLE` (read; section 14) |

## 6. The shape model

### 6.1 VoxelShape

A `VoxelShape` (`net.minecraft.world.phys.shapes`) is a set of cells on a rectangular grid plus the coordinates of the
grid lines per axis.

- A `DiscreteVoxelShape` (`BitSetDiscreteVoxelShape`) is a 3D bit grid of size `xSize * ySize * zSize`.
- The coordinate list of each axis has `size + 1` entries from 0.0 to 1.0 (a `CubePointRange` gives equal steps, an
  `OffsetDoubleList` shifts coordinates; an `ArrayVoxelShape` stores explicit lists).
- `CubeVoxelShape` is the equal-step case: `1 / size` steps.
- `SliceShape` is a one-layer slice of a shape (used for face shapes), `SubShape` a sub-box.
- Merging two shapes (`Shapes.or`, `join`) builds merged coordinate lists with an `IndexMerger`
  (`DiscreteCubeMerger`, `IdenticalMerger`, `NonOverlappingMerger`, `IndirectMerger` are the four merge strategies
  chosen by `Shapes.createIndexMerger`) and combines the cell bits with a `BooleanOp`.

`BooleanOp` constants used by the rows' consumers: `ONLY_FIRST`, `ONLY_SECOND`, `NOT_SAME`, `OR`, and others.

### 6.2 Constants and constructors (`net.minecraft.world.phys.shapes.Shapes`)

| Name | Meaning |
|---|---|
| `EPSILON` | 1.0E-7 |
| `BIG_EPSILON` | 1.0E-6 |
| `Shapes.empty()` | the empty shape: a 0x0x0 grid with one coordinate (0.0) per axis; a single shared instance |
| `Shapes.block()` | the full cube 0..1 on all axes, one shared instance (compared by identity in the occlusion code) |
| `Shapes.INFINITY` | the box from minus infinity to plus infinity on all axes |
| `Shapes.box(x1,y1,z1,x2,y2,z2)` | the box in block units 0..1; fails with "The min values need to be smaller or equals to the max values" when a min exceeds its max |
| `Shapes.create(...)` | the same shape; see 6.3 |
| `Shapes.or(a, b, ...)`, `Shapes.join(a, b, op)`, `Shapes.joinIsNotEmpty(a, b, op)` | union and boolean combinations |

`Block.box(x1,y1,z1,x2,y2,z2)` takes **pixel** units (0 to 16) and divides each argument by 16 before calling
`Shapes.box`. Other helpers of `Block` (pixel units):

| Helper | Box produced |
|---|---|
| `column(sizeXZ, minY, maxY)` | centred on x = z = 8: from `8 - sizeXZ/2` to `8 + sizeXZ/2` on x and z, from `minY` to `maxY` on y |
| `column(sizeX, sizeZ, minY, maxY)` | as above with separate x and z sizes |
| `cube(size)` / `cube(sx, sy, sz)` | a box centred in all three axes: `column(sx, sz, 8 - sy/2, 8 + sy/2)` |
| `boxes(max, fn)` | an array of `max + 1` shapes `fn(0) .. fn(max)` |
| `boxZ(...)` | the same boxes with the roles of the axes rotated so that the long side lies along z |

### 6.3 `Shapes.create`: grid resolution

`Shapes.create(x1,y1,z1,x2,y2,z2)`:

1. When any extent (`x2 - x1`, `y2 - y1`, `z2 - z1`) is below `EPSILON` (1.0E-7), the result is `Shapes.empty()`.
2. For each axis, `findBits(min, max)` tries bit counts b = 0, 1, 2, 3 (grid of `2^b` cells per axis). The first b for
   which both `min * 2^b` and `max * 2^b` are within `1.0E-7 * 2^b` of an integer wins. When the values lie outside
   `[-1.0E-7, 1.0000001]` or no b up to 3 fits, the result is -1.
3. When any axis has -1, the shape is a one-cell grid (the full-block bit grid) with explicit coordinate lists
   `{min, max}` per axis (an `ArrayVoxelShape`).
4. Otherwise the shape is a `CubeVoxelShape` with `2^bx x 2^by x 2^bz` cells in which the cells inside the box are set.

Consequence: boxes whose pixel edges are multiples of 2 pixels (eighths of a block) use a coarse grid; all other
boxes use the one-cell explicit-coordinate form.

### 6.4 Shape queries

| Query | Meaning |
|---|---|
| `isEmpty()` | no set cell |
| `bounds()` | the bounding `AABB` of the set cells |
| `min(axis)`, `max(axis)` | the lowest and highest coordinate of set cells on that axis |
| `getFaceShape(direction)` | the shape's cross-section at the face: empty for an empty shape, `Shapes.block()` for the block, otherwise a per-direction cached slice computed by `calculateFace` (a shape that is "cube-like along" the axis uses a slice, else the one-layer boundary) |
| `isCubeLikeAlong(axis)` | whether the shape fills the whole length along the axis in every occupied column |
| `Shapes.collide(axis, box, shapes, distance)` | the allowed movement of a box along an axis against shapes (the physics step, see 13) |
| `Shapes.blockOccludes(a, b, direction)`, `mergedFaceOccludes`, `faceShapeOccludes` | whether face shape a hides face shape b |
| `Shapes.rotate(shape, OctahedralGroup[, origin])`, `rotateHorizontal`, `rotateAll`, `rotateHorizontalAxis`, `rotateAllAxis`, `rotateAttachFace` | build the per-direction or per-axis shape maps of rotated copies of a base shape (used by block classes with facing properties) |

### 6.5 Full block and sturdy tests (`Block`)

- `Block.isShapeFullBlock(shape)`: true when `Shapes.joinIsNotEmpty(Shapes.block(), shape, NOT_SAME)` is **false**, that
  is, when the shape has no cell different from the full cube. The result is cached per shape (a cache of at most 512
  entries).
- `Block.isFaceFull(shape, direction)` = `isShapeFullBlock(shape.getFaceShape(direction))`.
- `Block.canSupportRigidBlock(level, pos)`: the state at the position has its UP face sturdy with support type RIGID.
- `Block.canSupportCenter(level, pos, direction)`: false when `direction` is DOWN and the state is in tag
  `unstable_bottom_center`; otherwise the state's face in that direction is sturdy with support type CENTER.
- `Block.shouldRenderFace(state, neighbour, direction)` (cull test): see 12 (rendering); it compares the face occlusion
  shapes with an `ONLY_FIRST` join and a 256-entry cache.

### 6.6 Support types (`SupportType`)

Three constants, in this order: `FULL`, `CENTER`, `RIGID`. Each defines `isSupporting(state, level, pos, direction)`
on the state's **block support shape** (`getBlockSupportShape`, default `getCollisionShape`; leaves override it to the
empty shape):

| Type | Supported when |
|---|---|
| `FULL` | the support shape's face in that direction is a full face (`Block.isFaceFull`) |
| `CENTER` | (`SupportType$2.isSupporting`, read: the result is true exactly when the join is empty, the same polarity as `RIGID`) the face shape covers the centre test column, `Block.column(2, 0, 10)` (a 2x2 pixel column in the middle of the face): the join `ONLY_SECOND` of face and test column is empty |
| `RIGID` | the face shape covers everything of the full cube except a 12-pixel-wide centred square hole: the test shape is `Shapes.block()` minus `Block.column(12, 0, 16)` (`ONLY_FIRST` join), and the join `ONLY_SECOND` of face and test shape is empty (the face covers the whole rim) |

### 6.7 Shape families (composition rules)

The shape of a block state is returned by `Block.getShape` of the class. Shapes are composed from boxes with
`Shapes.or`; families keep one precomputed shape per state or per property combination
(`Block.getShapeForEachState(fn)` builds a map from every state to a shape, collapsing properties the shape ignores).

| Family | Composition (all dimensions are pixel units, from the 16-pixel block) | Properties consulted |
|---|---|---|
| Full cube | `Shapes.block()` (the `Block` default) | none |
| Empty | `Shapes.empty()` (air, liquids' outline) | none |
| Slab, stair, fence, wall, pane, door, trapdoor, bed, rail and the others | specified with their blocks in the parts that cover them | per family |

For the blocks of this part the shapes are (read from the classes, section 14): full cube for all stone, dirt, planks,
ore, log, wood and bedrock blocks; the leaf blocks have the full cube as shape, an empty block-support shape and an
empty occlusion because `noOcclusion()` is set; saplings use a 12x12 pixel column from y 0 to 12 (the first argument of
`Block.column(12.0, 0.0, 12.0)`); air and liquids have the empty shape; the mangrove propagule uses a family of shapes
that depends on age and on hanging (section 6.8).

### 6.8 Mangrove propagule shapes

`MangrovePropaguleBlock.SHAPE_MIN_Y` is the array {13, 10, 7, 3, 0}. `SHAPE_PER_AGE` is `Block.boxes(4, i -> column(2, SHAPE_MIN_Y[i], 16))`:
five shapes, each a 2 by 2 pixel column centred in the cell from y = `SHAPE_MIN_Y[i]` to y = 16 pixels.

| Index | Pixel box (x, y, z; 2x2 column centred at 8) |
|---|---|
| 0 | 7..9, 13..16, 7..9 |
| 1 | 7..9, 10..16, 7..9 |
| 2 | 7..9, 7..16, 7..9 |
| 3 | 7..9, 3..16, 7..9 |
| 4 | 7..9, 0..16, 7..9 |

`getShape` picks index = `age` when `hanging` is true and index 4 (the full-height column) when `hanging` is false, then
moves the chosen shape by `BlockState.getOffset(pos)` (the XZ offset of section 4.4). The class does not override
`getMaxHorizontalOffset`, so the default 0.25 applies. The block has `noCollision`, so the collision shape is empty and
the `dynamicShape` rule of section 4.4 does not bite.

## 7. Column definitions

Every block table in this document family has these columns, in this order. A value is either read from the block's
builder chain (section 4), derived (sections 3 and 5), or the class (section 14).

| # | Column | Type | Definition |
|---|---|---|---|
| 1 | id | int | registry id (section 2) |
| 2 | key | identifier path | namespace `minecraft`; section 2.2 |
| 3 | class | class name | the block class constructed by the factory, with constructor arguments other than `Properties` (section 14) |
| 4 | properties | list | block state properties in sorted-name order with value order (section 13); `-` for none |
| 5 | states | int | product of the value counts |
| 6 | first state id | int | section 3, step 4 |
| 7 | default id | int | state id of the default state (section 3, step 5) |
| 8 | hardness | float | `destroyTime`. -1 means unbreakable. 0 means instant. Used in the break formula of 13 §2.1 |
| 9 | blast resistance | float | `explosionResistance` (after the `max(0, r)` rule) |
| 10 | tool required | yes/no | `requiresCorrectToolForDrops`. "yes" means drops need the correct tool and, with the tool tags of section 12.2, a sufficient tier (the break formula uses 100 instead of 30 for an incorrect tool, section 5.2) |
| 11 | light | int 0 to 15 | `lightLevel`; a plain number for a constant function |
| 12 | map colour | `MapColor` | section 8.1. `axis=y:A, else:B` means a function of the `axis` property |
| 13 | sound type | `SoundType` | section 8.4 |
| 14 | push reaction | `PushReaction` | section 8.2 |
| 15 | instrument | `NoteBlockInstrument` | section 8.3. Default `HARP` |
| 16 | flags | list | the builder flags that differ from the defaults, spelled as in the builder: `replaceable`, `noCollision`, `noOcclusion`, `randomTicks`, `ignitedByLava`, `liquid`, `air`, `noLootTable`, `offset:XZ`, `validSpawn:never`, `validSpawn:ocelotOrParrot`, `suffocating:never`, `redstoneConductor:never`, `legacyCopy:<source>` |

Columns requested by the design map that are not columns of the row table because they are rules, not per-row values (section 15.1 tabulates their values per row group for this part):

| Column of the design map | Where it is specified |
|---|---|
| friction, speed factor, jump factor | section 4.1 defaults (0.6, 1.0, 1.0); no block of this part overrides them (the builder chains of the rows contain no `friction`, `speedFactor` or `jumpFactor` call, read) |
| replaceable | flag in "flags" plus section 10.1 |
| burnable | there is no burnable flag in the builder (it has only `ignitedByLava`): the (ignite odds, burn odds) pair of each block is registered by `FireBlock.bootStrap` and specified in 17 §3.3a. Section 15.2 gives the pair per row of this part |
| ignited by lava | flag `ignitedByLava` |
| occlusion, collision and outline shape | section 5.2 (derived) and section 6.7 (per family); for every block of this part section 6.7 names the shapes |
| light opacity | `lightDampening` of section 5.2: 15 for full opaque cubes, 0 when skylight propagates, else 1; leaves override to 1 (`LeavesBlock.getLightDampening`) |
| tint class | section 9 |
| loot table key rule | `blocks/<path>` (section 4.1) unless the flags column says `noLootTable` |
| associated item | section 11 |
| correct-tool tags | tag membership is data (design map R7: the extraction tool, 22, copies the tag files out of the jar and the loader reads them), not a column of the row table. For this part the membership was read from the shipped tag files (`data/minecraft/tags/block/*.json` in the artifact, `#` entries expanded) and is tabulated per row group in section 15.2, so that the rows can be checked; the complete `mineable/*` lists are also in 17 Appendix A (which agrees). The tag names and their uses are section 12.2 |

## 8. Enumerations used by the columns

### 8.1 `MapColor` (`net.minecraft.world.level.material.MapColor`)

Ids 0 to 61, `MATERIAL_COLORS` has 64 slots (an id outside 0 to 63 fails with "Map colour ID must be between 0 and 63
(inclusive)"). The colour is `0xRRGGBB`. `calculateARGBColor(brightness)` returns 0 for `NONE`; for every other colour it
sets the alpha byte to 255 (`ARGB.opaque`) and scales each of red, green and blue by `modifier / 255`
(integer division, each channel clamped to 0..255, alpha kept; `ARGB.scaleRGB`). The modifiers of
`MapColor$Brightness` (ordinal = id), read from the constants: 0 `LOW` 180, 1 `NORMAL` 220, 2 `HIGH` 255,
3 `LOWEST` 135. The map rendering rules that choose a brightness are not part of this document.

| id | name | colour |
|---|---|---|
| 0 | NONE | 0 |
| 1 | GRASS | 0x7FB238 |
| 2 | SAND | 0xF7E9A3 |
| 3 | WOOL | 0xC7C7C7 |
| 4 | FIRE | 0xFF0000 |
| 5 | ICE | 0xA0A0FF |
| 6 | METAL | 0xA7A7A7 |
| 7 | PLANT | 0x007C00 |
| 8 | SNOW | 0xFFFFFF |
| 9 | CLAY | 0xA4A8B8 |
| 10 | DIRT | 0x976D4D |
| 11 | STONE | 0x707070 |
| 12 | WATER | 0x4040FF |
| 13 | WOOD | 0x8F7748 |
| 14 | QUARTZ | 0xFFFCF5 |
| 15 | COLOR_ORANGE | 0xD87F33 |
| 16 | COLOR_MAGENTA | 0xB24CD8 |
| 17 | COLOR_LIGHT_BLUE | 0x6699D8 |
| 18 | COLOR_YELLOW | 0xE5E533 |
| 19 | COLOR_LIGHT_GREEN | 0x7FCC19 |
| 20 | COLOR_PINK | 0xF27FA5 |
| 21 | COLOR_GRAY | 0x4C4C4C |
| 22 | COLOR_LIGHT_GRAY | 0x999999 |
| 23 | COLOR_CYAN | 0x4C7F99 |
| 24 | COLOR_PURPLE | 0x7F3FB2 |
| 25 | COLOR_BLUE | 0x334CB2 |
| 26 | COLOR_BROWN | 0x664C33 |
| 27 | COLOR_GREEN | 0x667F33 |
| 28 | COLOR_RED | 0x993333 |
| 29 | COLOR_BLACK | 0x191919 |
| 30 | GOLD | 0xFAEE4D |
| 31 | DIAMOND | 0x5CDBD5 |
| 32 | LAPIS | 0x4A80FF |
| 33 | EMERALD | 0x00D93A |
| 34 | PODZOL | 0x815631 |
| 35 | NETHER | 0x700200 |
| 36 | TERRACOTTA_WHITE | 0xD1B1A1 |
| 37 | TERRACOTTA_ORANGE | 0x9F5224 |
| 38 | TERRACOTTA_MAGENTA | 0x95576C |
| 39 | TERRACOTTA_LIGHT_BLUE | 0x706C8A |
| 40 | TERRACOTTA_YELLOW | 0xBA8524 |
| 41 | TERRACOTTA_LIGHT_GREEN | 0x677535 |
| 42 | TERRACOTTA_PINK | 0xA04D4E |
| 43 | TERRACOTTA_GRAY | 0x392923 |
| 44 | TERRACOTTA_LIGHT_GRAY | 0x876B62 |
| 45 | TERRACOTTA_CYAN | 0x575C5C |
| 46 | TERRACOTTA_PURPLE | 0x7A4958 |
| 47 | TERRACOTTA_BLUE | 0x4C3E5C |
| 48 | TERRACOTTA_BROWN | 0x4C3223 |
| 49 | TERRACOTTA_GREEN | 0x4C522A |
| 50 | TERRACOTTA_RED | 0x8E3C2E |
| 51 | TERRACOTTA_BLACK | 0x251610 |
| 52 | CRIMSON_NYLIUM | 0xBD3031 |
| 53 | CRIMSON_STEM | 0x943F61 |
| 54 | CRIMSON_HYPHAE | 0x5C191D |
| 55 | WARPED_NYLIUM | 0x167E86 |
| 56 | WARPED_STEM | 0x3A8E8C |
| 57 | WARPED_HYPHAE | 0x562C3E |
| 58 | WARPED_WART_BLOCK | 0x14B485 |
| 59 | DEEPSLATE | 0x646464 |
| 60 | RAW_IRON | 0xD8AF93 |
| 61 | GLOW_LICHEN | 0x7FA796 |


### 8.2 `PushReaction`

Constants, in declaration order: `PUSH_PULL`, `PUSH`, `POPPED`, `IMMOVEABLE`, `IGNORE_ENTITY`
(spelled as in the artifact; "IMMOVEABLE" is the artifact's spelling). Default `PUSH_PULL`. The movement rules belong
to the piston document (design map RS12). Rows of this part use only `PUSH_PULL` and `POPPED`.

### 8.3 `NoteBlockInstrument`

27 constants (the constructor loop count is 27). The first constants in order, with ordinal: 0 `HARP`, 1 `BASEDRUM`,
2 `SNARE`, 3 `HAT`, 4 `BASS`, 5 `FLUTE`, 6 `BELL`, 7 `GUITAR`, 8 `CHIME`, 9 `XYLOPHONE`, 10 `IRON_XYLOPHONE`,
11 `COW_BELL`, 12 `DIDGERIDOO`, 13 `BIT`, 14 `BANJO`, 15 `PLING`, 16 `TRUMPET`, 17 `TRUMPET_EXPOSED`,
18 `TRUMPET_OXIDIZED`, 19 `TRUMPET_WEATHERED`, 20 `ZOMBIE`, 21 `SKELETON`, 22 `CREEPER`, 23 `DRAGON`,
24 `WITHER_SKELETON`, 25 `PIGLIN`, 26 `CUSTOM_HEAD` (names and order read from the static initialiser). Each has a type (`BASE_BLOCK` for instruments chosen by the block below the note block, `CUSTOM` for the
head-based ones) and a sound event; those details belong to the note block row (a later part).
The instrument of a block is the value in the column, default `HARP`. Rows of this part use `HARP`, `BASEDRUM`,
`SNARE` and `BASS`.

### 8.4 `SoundType`

`net.minecraft.world.level.block.SoundType` is a record of volume, pitch and five `SoundEvents` (break, step, place,
hit, fall). Default of the builder: `STONE`. The constructor takes `(volume, pitch, break, step, place, hit, fall)`.

There are 131 constants. 110 are "standard": volume 1.0, pitch 1.0 and the five events are the `SoundEvents` fields named
`<NAME>_BREAK`, `<NAME>_STEP`, `<NAME>_PLACE`, `<NAME>_HIT`, `<NAME>_FALL`, with the exceptions:

| Constant | Exception |
|---|---|
| `METAL` | pitch 1.5 (volume 1.0) |
| `ANVIL` | volume 0.3 (pitch 1.0) |

The 21 constants whose volume, pitch or events differ from the pattern (events listed in the order break, step,
place, hit, fall; the `SoundEvents` field names, which are also the registered sound event paths' constant names;
the mapping of field to sound event key is the sound event table at 46 §14.3):

| Constant | Volume and pitch if not 1.0 | Events |
|---|---|---|
| EMPTY | - | EMPTY, EMPTY, EMPTY, EMPTY, EMPTY |
| LILY_PAD | - | BIG_DRIPLEAF_BREAK, BIG_DRIPLEAF_STEP, LILY_PAD_PLACE, BIG_DRIPLEAF_HIT, BIG_DRIPLEAF_FALL |
| BAMBOO_SAPLING | - | BAMBOO_SAPLING_BREAK, BAMBOO_STEP, BAMBOO_SAPLING_PLACE, BAMBOO_SAPLING_HIT, BAMBOO_FALL |
| SWEET_BERRY_BUSH | - | SWEET_BERRY_BUSH_BREAK, GRASS_STEP, SWEET_BERRY_BUSH_PLACE, GRASS_HIT, GRASS_FALL |
| CROP | - | CROP_BREAK, GRASS_STEP, CROP_PLANTED, GRASS_HIT, GRASS_FALL |
| HARD_CROP | - | WOOD_BREAK, WOOD_STEP, CROP_PLANTED, WOOD_HIT, WOOD_FALL |
| NETHER_WART | - | NETHER_WART_BREAK, STONE_STEP, NETHER_WART_PLANTED, STONE_HIT, STONE_FALL |
| TWISTING_VINES | vol 1.0 pitch 0.5 | WEEPING_VINES_BREAK, WEEPING_VINES_STEP, WEEPING_VINES_PLACE, WEEPING_VINES_HIT, WEEPING_VINES_FALL |
| AMETHYST | - | AMETHYST_BLOCK_BREAK, AMETHYST_BLOCK_STEP, AMETHYST_BLOCK_PLACE, AMETHYST_BLOCK_HIT, AMETHYST_BLOCK_FALL |
| SMALL_AMETHYST_BUD | - | SMALL_AMETHYST_BUD_BREAK, AMETHYST_CLUSTER_STEP, SMALL_AMETHYST_BUD_PLACE, AMETHYST_CLUSTER_HIT, AMETHYST_CLUSTER_FALL |
| MEDIUM_AMETHYST_BUD | - | MEDIUM_AMETHYST_BUD_BREAK, AMETHYST_CLUSTER_STEP, MEDIUM_AMETHYST_BUD_PLACE, AMETHYST_CLUSTER_HIT, AMETHYST_CLUSTER_FALL |
| LARGE_AMETHYST_BUD | - | LARGE_AMETHYST_BUD_BREAK, AMETHYST_CLUSTER_STEP, LARGE_AMETHYST_BUD_PLACE, AMETHYST_CLUSTER_HIT, AMETHYST_CLUSTER_FALL |
| CACTUS_FLOWER | - | CACTUS_FLOWER_BREAK, EMPTY, CACTUS_FLOWER_PLACE, EMPTY, EMPTY |
| SCULK | - | SCULK_BLOCK_BREAK, SCULK_BLOCK_STEP, SCULK_BLOCK_PLACE, SCULK_BLOCK_HIT, SCULK_BLOCK_FALL |
| GLOW_LICHEN | - | GRASS_BREAK, VINE_STEP, GRASS_PLACE, GRASS_HIT, GRASS_FALL |
| FROGSPAWN | - | FROGSPAWN_BREAK, FROGSPAWNSTEP, FROGSPAWN_PLACE, FROGSPAWN_HIT, FROGSPAWN_FALL |
| DECORATED_POT_CRACKED | - | DECORATED_POT_SHATTER, DECORATED_POT_STEP, DECORATED_POT_PLACE, DECORATED_POT_HIT, DECORATED_POT_FALL |
| RESIN | - | RESIN_BREAK, RESIN_STEP, RESIN_PLACE, EMPTY, RESIN_FALL |
| DRIED_GHAST | - | DRIED_GHAST_BREAK, DRIED_GHAST_STEP, EMPTY, EMPTY, DRIED_GHAST_FALL |
| SHELF_MUSHROOM | - | SHELF_MUSHROOM_BREAK, SHELF_MUSHROOM_STEP, SHELF_MUSHROOM_PLACE, EMPTY, SHELF_MUSHROOM_FALL |
| RED_SHRUB | - | RED_SHRUB_BREAK, EMPTY, RED_SHRUB_PLACE, EMPTY, EMPTY |


The 110 standard constants follow the pattern above; the class declares them in the order `WOOD`, `GRAVEL`, `GRASS`, `STONE`, `METAL`, `GLASS`, `WOOL`, `SAND`, `SNOW` and so on (the first nine, read from the declaration order). The rows of this part use only these standard constants (plus `EMPTY` from the table above): `WOOD`, `GRAVEL`, `GRASS`, `STONE`, `SAND`, `NETHER_GOLD_ORE`, `DEEPSLATE`, `MANGROVE_ROOTS`, `MUDDY_MANGROVE_ROOTS`, `BAMBOO_WOOD`, `CHERRY_WOOD`, `CHERRY_SAPLING`, `CHERRY_LEAVES`, `SUSPICIOUS_SAND`, `SUSPICIOUS_GRAVEL` and `POPLAR_LEAVES`. The other 94 standard names are given by the part that first uses them; each is a `SoundType` constant whose five events are the `<NAME>_BREAK`, `_STEP`, `_PLACE`, `_HIT` and `_FALL` fields of `SoundEvents`, so no per-constant row is needed here (the full count, 131 = 110 standard + 21 in the table above, was read).

## 9. Tint classes (GAP-29 columns)

The tint class of a block is client data: which tint source (if any) colours which tint index of the block's model.
It is code in `net.minecraft.client.color.block.BlockColors.createDefault`, which registers a list of tint sources per
block in an identity map. A block that is not in the map has an empty list (no tint). The model JSON (data) says which
faces use which tint index; index i of a face selects the i-th source of the block's list (`getTintSource(state, i)`).
A tint source (`BlockTintSource`) has three colours: `color(state)` for items and the in-hand view,
`colorInWorld(state, level, pos)` for the placed block, and a terrain-particle colour.

### 9.1 Sources (`BlockTintSources`)

The interface defaults (read in `BlockTintSource`): `colorInWorld` returns `color`, and `colorAsTerrainParticle`
returns `colorInWorld`. A source that overrides neither therefore has all three colours equal. 43 §2 owns this table
(with the redstone and stem formulas, 43 §2.2 and §2.3); the rows below agree with it.

| Source | In-hand colour | In-world colour | Terrain particle colour |
|---|---|---|---|
| `constant(c)` | c | c | c (default) |
| `constant(inHand, inWorld)` | inHand | inWorld | inWorld (default) |
| `grass()` | `GrassColor.getDefaultColor()` | `BiomeColors.getAverageGrassColor(level, pos)` | as in world (default) |
| `grassBlock()` | `GrassColor.getDefaultColor()` | `BiomeColors.getAverageGrassColor(level, pos)` | constant -1 (opaque white, 0xFFFFFFFF), so the particle is untinted |
| `doubleTallGrass()` | `GrassColor.getDefaultColor()` | grass colour at the lower half: the position is moved one down when the `half` property is `upper` | as in world (default) |
| `sugarCane()` | -1 (0xFFFFFFFF) | `BiomeColors.getAverageGrassColor(level, pos)` | as in world (default) |
| `foliage()` | -12012264 (0xFF48B518) | `BiomeColors.getAverageFoliageColor(level, pos)` | as in world (default) |
| `dryFoliage()` | -10732494 (0xFF5C3C32) | `BiomeColors.getAverageDryFoliageColor(level, pos)` | as in world (default) |
| `water()` (`BlockTintSources$8`) | -1 (0xFFFFFFFF) | `BiomeColors.getAverageWaterColor(level, pos)` | as in world (default) |
| `waterParticles()` (`BlockTintSources$9`) | -1 (0xFFFFFFFF) | -1 (not overridden; falls back to `color`) | `BiomeColors.getAverageWaterColor(level, pos)` |
| `redstone()` | by `power`, 43 §2.2 | same | same |
| `stem()` | by `age`, 43 §2.3 | same | same |

The dry foliage in-hand value and the grass-family values agree with 43 §2. Consequence: a water or bubble column block
is drawn in the world with no tint (0xFFFFFFFF); only its terrain particles take the biome water colour (the water
fluid's own tint is 43's subject).

`GrassColor.getDefaultColor()` calls `GrassColor.get(0.5, 1.0)` (temperature 0.5, downfall 1.0, both read from the
bytecode). `GrassColor.get(temperature, downfall)` samples the colormap texture (65536 pixels, 256 by
256) through `ColorMapColorUtil`; a missing pixel array gives -65281 (0xFFFF00FF, magenta). The grass, foliage and dry
foliage colormaps are loaded by `GrassColorReloadListener`, `FoliageColorReloadListener` and
`DryFoliageColorReloadListener` from the `minecraft:textures/colormap/*` pack textures (08 §6.4; data).

### 9.2 Biome colour resolvers (`BiomeColors`)

Four `ColorResolver`s: grass, foliage, dry foliage and water. Each maps a biome and a pair of x, z coordinates to an
ARGB or RGB int: the water resolver returns `Biome.getWaterColor()`, the foliage resolver `Biome.getFoliageColor()`, the
dry foliage resolver `Biome.getDryFoliageColor()`; the grass resolver is the biome's grass colour (temperature and
downfall colormap lookup plus the grass colour modifier). `getAverageXColor(level, pos)` calls
`BlockAndTintGetter.getBlockTint(pos, resolver)`, which blends the biome colours of the surrounding columns; the blend
radius and the cache (`BlockTintCache`) are specified in 43 §4 (not repeated here).

### 9.3 Block to source table (all of `createDefault`, so that sibling parts can cite it)

| Blocks | Sources (list; index 0 first) |
|---|---|
| `GRASS_BLOCK` | `grassBlock()` |
| `SHORT_GRASS`, `FERN`, `POTTED_FERN`, `BUSH` | `grass()` |
| `PINK_PETALS`, `WILDFLOWERS` | two sources: a blank layer (index 0, untinted) then `grass()` (index 1) |
| `TALL_GRASS`, `LARGE_FERN` | `doubleTallGrass()` |
| `SPRUCE_LEAVES` | `constant(-10380959)` = 0xFF619961 |
| `BIRCH_LEAVES` | `constant(-8345771)` = 0xFF80A755 |
| `OAK_LEAVES`, `JUNGLE_LEAVES`, `ACACIA_LEAVES`, `DARK_OAK_LEAVES`, `MANGROVE_LEAVES`, `VINE` | `foliage()` |
| `LEAF_LITTER` | `dryFoliage()` |
| `WATER_CAULDRON` | `water()` |
| `WATER`, `BUBBLE_COLUMN` | `waterParticles()` (untinted in the world, biome water colour for terrain particles) |
| `REDSTONE_WIRE` | `redstone()` |
| `SUGAR_CANE` | `sugarCane()` |
| `ATTACHED_MELON_STEM`, `ATTACHED_PUMPKIN_STEM` | `constant(-2046180)` = 0xFFE0C71C |
| `MELON_STEM`, `PUMPKIN_STEM` | `stem()` |
| `LILY_PAD` | `constant(-9321636, -14647248)`: in hand 0xFF71C35C, in the world 0xFF208030 (`LILY_PAD_DEFAULT`, `LILY_PAD_IN_WORLD`) |

Every other block has no tint. In particular `CHERRY_LEAVES`, `PALE_OAK_LEAVES`, `AZALEA_LEAVES`,
`FLOWERING_AZALEA_LEAVES` and the poplar leaves are not registered, so they are untinted. The "tint class" column of a
row is "none" unless the block is in this table.

## 10. Placement columns (GAP-30 columns)

### 10.1 Replaceable

The `replaceable` builder flag (section 4.2) is the column. It means a block may be overwritten by placing another
block (`BlockState.canBeReplaced()`); the placement context test is in section 5.2. The flag also appears as the block
tag `replaceable` (section 12.1); both are separate: the tag is data, the flag is code. Rows of this part with the
flag: `air`, `water`, `lava`. The default-state replaced test for fluids is `canBeReplaced(Fluid)` (flag, or not
`isSolid`).

### 10.2 `canSurvive`

`BlockBehaviour.canSurvive(state, level, pos)` defaults to true. A class overrides it to keep a block in place; the
block is then removed or turned into air by `updateShape` when it fails (the update machinery is 29 §3). Classes in this
part:

| Class | canSurvive rule |
|---|---|
| `Block`, `AirBlock`, `RotatedPillarBlock`, `DropExperienceBlock`, falling blocks, liquids, leaves, `MangroveRootsBlock`, grass family | default (true) |
| `SaplingBlock` (via `VegetationBlock`) | the state below (`pos.below()`) is in block tag `supports_vegetation` (`mayPlaceOn`); `updateShape` returns air when it fails |
| `MangrovePropaguleBlock` | for the standing form: the state below is in `supports_mangrove_propagule` (`mayPlaceOn`); for the hanging form (property `hanging` true): the state at `pos.above()` is in tag `supports_hanging_mangrove_propagule` (read in `canSurvive`: the position is `BlockPos.above`) |
| `SpreadingSnowyBlock` (grass block, and other spreading blocks) | `canStayAlive` and `canPropagate` are used by random ticks, not by `canSurvive` (the rules are in 29b-3 §3) |

### 10.3 Placement state

`Block.getStateForPlacement(BlockPlaceContext)` returns the state placed by an item. Default: the default state.

| Class | Placement state |
|---|---|
| `Block`, `DropExperienceBlock`, falling blocks, `AirBlock`, `BrushableBlock`, `SaplingBlock` | the default state |
| `RotatedPillarBlock` | the default state with `axis` = the axis of the clicked face (`Direction.getAxis`) |
| `SnowyBlock` family (grass block, podzol, mycelium) | the default state with `snowy` true when the block above is in tag `snow` (`isSnowySetting`); `updateShape` for the UP neighbour recomputes `snowy` the same way |
| `LeavesBlock` | `persistent` true (a placed leaf block never decays), `waterlogged` true when the fluid at the clicked position is water, then `distance` from the neighbour distances (`updateDistance`, which scans the six neighbours; `distance` 7 means "far from a log") |
| `MangroveRootsBlock` | waterlogged from the fluid at the position |
| `MangrovePropaguleBlock` | the sapling placement state, then `waterlogged` true when the fluid at the clicked position is water, and `age` 4 (the placed propagule is fully grown); `hanging` keeps its default false. The hanging form is only created by tree growth (`createNewHangingPropagule(age)`: default state with `hanging` true and the given age, default 0) |
| `LiquidBlock` | not placed by items (no item) |

## 11. Blocks and items

- The registry link is the `BlockItemId` record (section 2.2): block key and item key, one path string in
  `minecraft`. In `Items`, the `registerBlock(BlockItemId, Block, ...)` helpers register a `BlockItem` under the
  **item key** of the id, with item properties that call `useBlockDescriptionPrefix()` (the item's description id uses
  the block prefix `block.minecraft.<path>`) and the block's `requiredFeatures`. `Block.asItem()` caches
  `Item.byBlock(block)`; `Item.byBlock` and `Block.byItem` use the map `Item.BY_BLOCK`, falling back to `Items.AIR`
  for a block without an item (such as water and lava).
- For every row of this part, item key = block key (the strings in `BlockItemIds` are identical to the lower-case
  field names). `WATER` and `LAVA` use `BlockIds`: no item.
- Items whose item key differs from the block key (seeds, buckets) are in later parts and in the item registry
  document (RS5).
- The associated-item column of a row is therefore "same key" or "none".

## 12. Block tags

### 12.1 Model

- A block tag is a `TagKey<Block>` in the `block` registry's tag set. `BlockState.is(tagKey)` tests whether the state's
  block is in the tag; `is(tagKey, predicate)` adds a test of the state.
- The contents of tags are data (data pack `data/minecraft/tags/block/*.json`), loaded by the tag loader (design map
  RS3) and synchronized to clients (04 §1, 04 §5.3). A tag may include other tags (`#minecraft:logs`) and optional
  entries; resolving is the tag loader's job.
- The names that code reads are constants of `net.minecraft.tags.BlockTags`: 284 fields (counted). The key of a tag is
  `minecraft:<path>`; the path of 218 fields is a string constant in `BlockTags`; the other 66 are built as
  `BlockItemTags.<FIELD>.block()` from `net.minecraft.tags.BlockItemTags`, a class of 83 `BlockItemTagId` constants
  (a `BlockItemTagId` is a record of a block tag key and an item tag key, built from one or two path strings in the
  default namespace; the first string is the block path, the second the item path; with one string both are equal).
  The paths of all 66 are string constants of `BlockItemTags`. Three fields carry a path different from the field
  name: `SIGNS` is `standing_signs`, `HANGING_SIGNS` is `ceiling_hanging_signs` and `BEE_FOOD` is `bee_attractive`
  (the item-side paths are `signs`, `hanging_signs` and `bee_food`).
- Gameplay code reads tags by name: it never tests blocks by identity where a tag exists. A COBOL implementation
  therefore needs the tag set loaded from the data pack before any rule below runs.

### 12.2 Tags that decide breaking, tools and drops

The tag names are read from `BlockTags`. Each row below states the call sites that reference the tag, found by searching every class of the jar for the field name and reading the referencing methods (the data generator class `VanillaBlockTagsProvider` is the only other referrer of every tag; it is not behaviour). The contents quoted are the shipped tag files. A tag with no behaviour referrer is said to be data only.

| Tag | Used for |
|---|---|
| `mineable/pickaxe`, `mineable/axe`, `mineable/shovel`, `mineable/hoe` | "the tool type that mines this block quickly": the tool's mining rule (a component with a block set per speed; 17 Appendix A) matches the block against the tag. A block that is in none of them is mined at hand speed by every tool |
| `needs_stone_tool`, `needs_iron_tool`, `needs_diamond_tool` | only referenced by the `incorrect_for_*` tag files (below); a block in a `needs_*` tag is a block that the lower tiers cannot correctly mine (17 and 13 §2 own the consuming rule; membership of the rows of this part is section 15.2) |
| `incorrect_for_wooden_tool`, `incorrect_for_gold_tool`, `incorrect_for_stone_tool`, `incorrect_for_copper_tool`, `incorrect_for_iron_tool`, `incorrect_for_diamond_tool`, `incorrect_for_netherite_tool` | `ToolMaterial` stores one such tag per material; `applyToolProperties` builds the tool component's rule list from two rules in this order: (1) `deniesDrops` for the blocks of the material's `incorrect_for_*` tag, (2) `minesAndDrops` for the `mineable/*` tag of the tool type with the material's speed (the component constructor then receives default speed 1.0, damage per block 1 and the boolean true). Material speeds read: wood 2.0, stone 4.0, copper 5.0, iron 6.0, diamond 8.0, gold 12.0, netherite 9.0. Tag contents (data): wooden and gold = `#needs_stone_tool` + `#needs_iron_tool` + `#needs_diamond_tool`; stone and copper = `#needs_iron_tool` + `#needs_diamond_tool`; iron = `#needs_diamond_tool`; diamond and netherite are empty. So a block of `needs_stone_tool` is denied only to wooden and gold tools, `needs_iron_tool` to wooden, gold, stone and copper, `needs_diamond_tool` to wooden, gold, stone, copper and iron |
| `sword_efficient`, `sword_instantly_mines` | the sword's tool component (`ToolMaterial`, three rules in this order): (1) cobweb alone, `minesAndDrops` at speed 15.0; (2) the blocks of `sword_instantly_mines` get `overrideSpeed` 3.4028235E38 (the largest float); (3) the blocks of `sword_efficient` get `overrideSpeed` 1.5. Component defaults: speed 1.0, damage per block 2, boolean false. Contents: `sword_instantly_mines` = bamboo, bamboo sapling; `sword_efficient` = `#leaves`, vine, glow lichen, pumpkin, carved pumpkin, jack o'lantern, melon, cocoa, big dripleaf, big dripleaf stem, chorus plant, chorus flower |
| `shears_extreme_breaking_speed`, `shears_major_breaking_speed`, `shears_minor_breaking_speed` | the shears' tool component (`ShearsItem`, four rules in this order): (1) cobweb alone, `minesAndDrops` 15.0; (2) extreme tag `overrideSpeed` 15.0; (3) major tag 5.0; (4) minor tag 2.0. Component defaults: speed 1.0, damage per block 1, boolean true. Contents: extreme = `#leaves`; major = `#wool`, `#wool_slabs`, `#wool_stairs`; minor = glow lichen, vine |
| `turns_into_dirt_path`, `turns_into_farmland` | `BlockTransformers` (the shovel and hoe use rules): a block of `turns_into_dirt_path` whose block above (direction up) is in the `air` tag becomes `dirt_path` (sound `SHOVEL_FLATTEN`); a block of `turns_into_farmland` with air above becomes `farmland`; the hoe table also has coarse dirt (air above) to dirt and rooted dirt to dirt (sound `HOE_TILL`). The side effects of each transformer beyond the sound were not read. Contents: dirt path = grass block, dirt, podzol, coarse dirt, mycelium, rooted dirt; farmland = grass block, dirt path, dirt |
| `replaceable` | data only: no class other than the data generator references `BlockTags.REPLACEABLE`. The placement engine reads the builder flag (section 10.1; 29 §9, "canBeReplaced"); the `ReplaceablePredicate` block predicate of world generation also reads the flag (`BlockState.canBeReplaced`), not the tag. The tag file lists air, water, lava, short grass, fern, dead bush, bush, red shrub, short and tall dry grass, seagrass, tall seagrass, fire, soul fire, snow, vine, glow lichen, resin clump and further entries (the file continues; it mirrors the flag) |
| `climbable` | `LivingEntity` (the "is on a climbable" test): when the entity is fall flying and the state in its block is in `can_glide_through`, the answer is false; otherwise a state in `climbable` records the position as the last climbable position and the answer is true; a trapdoor test follows (not read further). Movement effect: 13 §1.3. `Entity` and `DismountHelper` also reference the tag (not read). Contents: ladder, vine, scaffolding, weeping vines and plant, twisting vines and plant, cave vines and plant |
| `fall_damage_resetting`, `suppresses_bounce`, `cushion_uses_collision_shape` | `fall_damage_resetting`: read in the `ClipContext.Block.FALLDAMAGE_RESETTING` shape getter, blocks of the tag are full for everyone (33 §8.2, the `players_nether_portal_default_delay` row). `suppresses_bounce`: in `Entity`, in the code that picks the bounce value on landing: the bounce is 0 when the downward speed is not greater than the effective gravity, when the entity is suppressing bounce, or when the landed-on state is in the tag; otherwise the larger of the running value and the block's bounciness (`getBlockBounciness`). Contents: honey block only. `cushion_uses_collision_shape`: `CushionItem` use-on proceeds past a first test only when the clicked state is in the tag, then reads the player's eye position and the click location (rest not read). Contents: `#cauldrons`, hopper, composter |
| `causes_suffocation`, `blocks_motion`, `blocks_motion_no_leaves`, `blocks_motion_in_heightmap`, `blocks_motion_in_heightmap_no_leaves` | `causes_suffocation`: the default `isSuffocating` of `Properties` is true when the state is in the tag and its collision shape is a full block (section 4.1). `blocks_motion_in_heightmap` and `blocks_motion_in_heightmap_no_leaves`: the `Heightmap.Types` predicates of `MOTION_BLOCKING` and `MOTION_BLOCKING_NO_LEAVES`: a state counts when it is in the respective tag or its fluid state is not empty. `OCEAN_FLOOR` and `OCEAN_FLOOR_WG` use the heightmap field `MATERIAL_MOTION_BLOCKING`, `WORLD_SURFACE` and `WORLD_SURFACE_WG` use `NOT_AIR` (neither field's body was read; Open question 16). Usage kinds read: `WORLD_SURFACE_WG` worldgen, `WORLD_SURFACE` client, `OCEAN_FLOOR_WG` worldgen, `OCEAN_FLOOR` live world. `blocks_motion` and `blocks_motion_no_leaves` have no behaviour referrer: they are data only and exist as inclusions (`causes_suffocation` = `#blocks_motion`; `blocks_motion_in_heightmap` = `#blocks_motion`; `blocks_motion_in_heightmap_no_leaves` = `#blocks_motion_no_leaves`; `blocks_motion` = `#blocks_motion_no_leaves` + `#leaves`). Heightmap updates: 29 §2.1 step 4; 33 §2.4 reads `MOTION_BLOCKING` |
| `leaves`, `logs`, `planks`, `saplings`, `sand`, `dirt`, `ores`, `base_stone_overworld`, `snow`, `fire`, `air` | grouping tags read by name in world rules. All eleven names were checked against section 12.3: `leaves`, `logs`, `planks`, `saplings`, `sand`, `dirt` and `ores` are `BlockItemTags` entries (the block path of each is its name; no tag `ore` exists), `base_stone_overworld`, `snow`, `fire` and `air` are `BlockTags` string constants. Uses read: `snow` decides the `snowy` property (section 10.3, 29b-3 §3.1); `logs` is the `prevents_nearby_leaf_decay` set of the leaf distance rule (29b-3 §5.2); `air` is the block-above test of the dirt path and farmland transformers (above); `fire` is referenced by the shears item construction (the use was not read); the use of every other name was not traced here (Open question 16) |
| `supports_vegetation`, `supports_mangrove_propagule`, `supports_hanging_mangrove_propagule`, and the other `supports_*` tags | `canSurvive` of plant blocks (section 10.2) |
| `prevents_nearby_leaf_decay` | leaf distance (read in `LeavesBlock.getOptionalDistanceAt`); random ticks 33 §2.4 |
| `required_for_poplar_leaf_ambience` | poplar leaves ambient sound (an argument of the poplar leaves' ambient sound player) |
| `unstable_bottom_center` | `Block.canSupportCenter` (section 6.5) |

The semantics of the tool tags, with the break formula, are 13 §2 and 17 Appendix A. In this part, a row's "tool required"
and the tags `mineable/*` together answer "which tool mines it": the tag names the tool type, the flag says whether
drops are lost without a correct tool and tier. Section 15.2 gives the membership per row.

### 12.3 All `BlockTags` names

Read from a string constant in `BlockTags` (218):
`mob_interactable_doors`, `pressure_plates`, `stone_pressure_plates`, `overworld_natural_logs`, `banners`, `piglin_repellents`, `badlands_terracotta`, `flower_pots`, `enderman_holdable`, `ice`, `valid_spawn`, `impermeable`, `underwater_bonemeals`, `coral_blocks`, `wall_corals`, `coral_plants`, `corals`, `wall_signs`, `signs`, `wall_hanging_signs`, `all_hanging_signs`, `all_signs`, `dragon_immune`, `dragon_transparent`, `wither_immune`, `wither_summon_base_blocks`, `beehives`, `crops`, `bee_growables`, `portals`, `fire`, `nylium`, `beacon_base_blocks`, `soul_speed_blocks`, `wall_post_override`, `climbable`, `fall_damage_resetting`, `hoglin_repellents`, `strider_warm_blocks`, `campfires`, `guarded_by_piglins`, `prevent_mob_spawning_inside`, `unstable_bottom_center`, `edible_for_sheep`, `can_glide_through`, `causes_periodic_geyser_eruptions`, `causes_continuous_geyser_eruptions`, `nether_portal_frame`, `conduit_effect_block`, `infiniburn_overworld`, `infiniburn_nether`, `infiniburn_end`, `substrate_overworld`, `base_stone_overworld`, `stone_ore_replaceables`, `height_specific_ore_replaceables`, `deepslate_ore_replaceables`, `base_stone_nether`, `beneath_tree_podzol_replaceable`, `beneath_bamboo_podzol_replaceable`, `cannot_replace_below_tree_trunk`, `cannot_place_basalt_pillar_on`, `uncarvable`, `candle_cakes`, `cauldrons`, `crystal_sound_blocks`, `inside_step_sound_blocks`, `combination_step_sound_blocks`, `camel_sand_step_sound_blocks`, `happy_ghast_avoids`, `occludes_vibration_signals`, `cushion_uses_collision_shape`, `dripstone_replaceable_blocks`, `sulfur_spike_replaceable_blocks`, `cave_vines`, `moss_replaceable`, `lush_ground_replaceable`, `azalea_root_replaceable`, `ice_spike_replaceable`, `forest_rock_can_place_on`, `huge_brown_mushroom_can_place_on`, `huge_red_mushroom_can_place_on`, `snow`, `mineable/axe`, `mineable/hoe`, `mineable/pickaxe`, `mineable/shovel`, `sword_efficient`, `sword_instantly_mines`, `shears_extreme_breaking_speed`, `shears_major_breaking_speed`, `shears_minor_breaking_speed`, `turns_into_dirt_path`, `turns_into_farmland`, `needs_diamond_tool`, `needs_iron_tool`, `needs_stone_tool`, `incorrect_for_netherite_tool`, `incorrect_for_diamond_tool`, `incorrect_for_iron_tool`, `incorrect_for_copper_tool`, `incorrect_for_stone_tool`, `incorrect_for_gold_tool`, `incorrect_for_wooden_tool`, `features_cannot_replace`, `lava_pool_stone_cannot_replace`, `geode_invalid_blocks`, `frog_prefer_jump_to`, `sculk_growth_inhibitors`, `sculk_replaceable`, `sculk_replaceable_world_gen`, `ancient_city_replaceable`, `vibration_resonators`, `animals_spawnable_on`, `armadillo_spawnable_on`, `axolotls_spawnable_on`, `goats_spawnable_on`, `mooshrooms_spawnable_on`, `parrots_spawnable_on`, `polar_bears_spawnable_on_alternate`, `rabbits_spawnable_on`, `foxes_spawnable_on`, `wolves_spawnable_on`, `frogs_spawnable_on`, `bats_spawnable_on`, `camels_spawnable_on`, `azalea_grows_on`, `convertible_to_mud`, `mangrove_logs_can_grow_through`, `mangrove_roots_can_grow_through`, `snaps_goat_horn`, `replaceable_by_trees`, `replaceable_by_mushrooms`, `enables_bubble_column_drag_down`, `enables_bubble_column_push_up`, `cats_can_sit_on`, `cats_can_lie_on`, `speeds_up_zombie_villager_curing`, `villagers_can_sleep_on_bed`, `villager_babies_can_jump_on_bed`, `supports_vegetation`, `supports_dry_vegetation`, `supports_crops`, `supports_stem_crops`, `supports_stem_fruit`, `supports_pumpkin_stem`, `supports_melon_stem`, `supports_pumpkin_stem_fruit`, `supports_melon_stem_fruit`, `supports_sugar_cane`, `supports_sugar_cane_adjacently`, `supports_bamboo`, `supports_small_dripleaf`, `supports_big_dripleaf`, `supports_cactus`, `supports_chorus_plant`, `supports_chorus_flower`, `supports_nether_sprouts`, `supports_azalea`, `supports_warped_fungus`, `supports_crimson_fungus`, `supports_mangrove_propagule`, `supports_hanging_mangrove_propagule`, `supports_nether_wart`, `supports_crimson_roots`, `supports_warped_roots`, `supports_wither_rose`, `supports_cocoa`, `supports_lily_pad`, `supports_frogspawn`, `prevents_nearby_leaf_decay`, `support_override_cactus_flower`, `support_override_snow_layer`, `cannot_support_snow_layer`, `cannot_support_seagrass`, `cannot_support_kelp`, `overrides_mushroom_light_requirement`, `grows_crops`, `invalid_spawn_inside`, `sniffer_diggable_block`, `sniffer_egg_hatch_boost`, `trail_ruins_replaceable`, `replaceable`, `enchantment_power_provider`, `enchantment_power_transmitter`, `maintains_farmland`, `blocks_wind_charge_explosions`, `does_not_block_hoppers`, `suppresses_bounce`, `triggers_ambient_desert_sand_block_sounds`, `triggers_ambient_desert_dry_vegetation_block_sounds`, `triggers_ambient_dried_ghast_block_sounds`, `required_for_poplar_leaf_ambience`, `speleothems`, `dangerous_for_teleportation`, `cat_does_not_teleport_to`, `enderman_does_not_teleport_to`, `shulker_does_not_teleport_to`, `consumable_does_not_teleport_to`, `fox_immune_to`, `polar_bear_immune_to`, `snow_golem_immune_to`, `stray_immune_to`, `wither_immune_to`, `wither_skeleton_immune_to`, `default_immune_to`, `blocks_motion`, `blocks_motion_no_leaves`, `entities_can_teleport_to`, `blocks_dolphin_jump`, `ice_melts_when_destroyed_above`, `causes_suffocation`, `blocks_motion_in_heightmap`, `blocks_motion_in_heightmap_no_leaves`, `blocks_lava_fire_spread`, `blocks_fluid_flow`, `washed_away_by_fluids`, `air`

Read from `BlockItemTags` through `BlockItemTagId.block()` (66; the block path, which for the three fields named above differs from the field name):
`wool`, `planks`, `stone_bricks`, `wooden_buttons`, `stone_buttons`, `buttons`, `wool_carpets`, `wooden_doors`, `wooden_stairs`, `wooden_slabs`, `wooden_fences`, `fence_gates`, `wooden_pressure_plates`, `wooden_shelves`, `doors`, `saplings`, `bamboo_blocks`, `pale_oak_logs`, `jungle_logs`, `wart_blocks`, `logs`, `sand`, `slabs`, `walls`, `stairs`, `anvil`, `rails`, `leaves`, `wooden_trapdoors`, `trapdoors`, `small_flowers`, `flowers`, `beds`, `fences`, `soul_fire_base_blocks`, `candles`, `dampens_vibrations`, `gold_ores`, `iron_ores`, `copper_ores`, `ores`, `dirt`, `mud`, `moss_blocks`, `grass_blocks`, `terracotta`, `glazed_terracotta`, `concrete`, `concrete_slabs`, `concrete_stairs`, `concrete_powders`, `completes_find_tree_tutorial`, `shulker_boxes`, `copper_chests`, `lightning_rods`, `copper`, `chains`, `copper_golem_statues`, `lanterns`, `bars`, `skulls`, `wool_slabs`, `wool_stairs`, `ceiling_hanging_signs`, `standing_signs`, `bee_attractive`

Seventeen other `BlockItemTags` constants have no `BlockTags` field (item-side tags only): `logs_that_burn`, `smelts_to_glass`,
`coal_ores`, `diamond_ores`, `emerald_ores`, `lapis_ores`, `redstone_ores`, `oak_logs`, `spruce_logs`, `birch_logs`,
`dark_oak_logs`, `acacia_logs`, `cherry_logs`, `mangrove_logs`, `poplar_logs`, `crimson_stems`, `warped_stems`.

## 13. Property definitions used by the rows of this part

`net.minecraft.world.level.block.state.properties.BlockStateProperties`:

| Field | Name | Type | Values in order | Used by |
|---|---|---|---|---|
| `SNOWY` | `snowy` | boolean | true, false | grass block, podzol |
| `AXIS` | `axis` | enum `Direction.Axis` | x, y, z (constants `X`, `Y`, `Z` with names `x`, `y`, `z`, in that order, read in `Direction$Axis`) | logs, wood, bamboo block, muddy mangrove roots |
| `STAGE` | `stage` | integer 0 to 1 | 0, 1 | saplings, propagule |
| `AGE_4` | `age` | integer 0 to 4 | 0, 1, 2, 3, 4 | propagule |
| `HANGING` | `hanging` | boolean | true, false | propagule |
| `WATERLOGGED` | `waterlogged` | boolean | true, false | propagule, mangrove roots, leaves |
| `LEVEL` | `level` | integer 0 to 15 | 0 .. 15 | liquids |
| `DUSTED` | `dusted` | integer 0 to 3 | 0 .. 3 | suspicious sand and gravel |
| `DISTANCE` | `distance` | integer 1 to 7 | 1 .. 7 | leaves |
| `PERSISTENT` | `persistent` | boolean | true, false | leaves |

Default values (read from the constructors' `setValue` calls): `snowy` false, `axis` y, `stage` 0, `age` 0, `hanging`
false, `waterlogged` false, `level` 0, `dusted` 0, `distance` 7, `persistent` false. (The `dusted` default 0 was read in the `BrushableBlock` constructor.)

## 14. Block classes of the rows of this part

Constructor arguments are shown as read. Behaviour that belongs to other documents is named and cited.

| Class | Constructor arguments | Properties | Behaviour owned here / elsewhere |
|---|---|---|---|
| `AirBlock` | none | none | shape empty; `getRenderShape` returns `RenderShape.INVISIBLE` (read). |
| `Block` | none | none | full cube; defaults of section 5. |
| `DropExperienceBlock` | xp `IntProvider`: `ConstantInt(0)` (gold, iron, coal... see rows) or `UniformInt(0,1)`, `UniformInt(0,2)` | none | `spawnAfterBreak` drops the experience (the xp amount is read from the provider when the block is broken with drops; the loot table gives items; see 17). |
| `GrassBlock` (extends `SpreadingSnowyBlock` extends `SnowyBlock`) | none (the spread targets are fixed in the class) | `snowy` | random ticks 33 §2.4, spread and death rules 29b-3 §3; bone meal (`placeBonemealEffect`; 29b-3 §3.3). |
| `SnowyBlock` (podzol) | none | `snowy` | as above without the spreading. |
| `RotatedPillarBlock` | none | `axis` | `rotate` for 90 degree rotations; placement section 10.3. |
| `SaplingBlock` | `TreeGrower` | `stage` | shape 12x12 column 0..12 px; random ticks 33 §2.4, growth 29b-1 §7; bone meal success chance 0.45 (read as a double constant in `isBonemealSuccess`). |
| `MangrovePropaguleBlock` | `TreeGrower.MANGROVE` | `age`, `hanging`, `stage`, `waterlogged` | shapes by age and hanging (section 6.8); `getFluidState` gives the water source when waterlogged (section 5.2); `updateShape` schedules a water tick when waterlogged; random tick: a standing propagule (`hanging` false) calls `advanceTree` with probability 1 in 7 (`nextInt(7)` equal to 0); a hanging one that is not fully grown (`age` below 4) cycles `age` to the next value (update flag 2) (further growth rules 29b-3 §5). |
| `LiquidBlock` | `FlowingFluid` (`Fluids.WATER`, `Fluids.LAVA`) | `level` | `getFluidState` maps the level to the fluid (RS10); `getRenderShape` returns `RenderShape.INVISIBLE` (read); collision shape, in order: (1) the full cube when the collision context's `alwaysCollideWithFluid` is true; (2) else the empty shape when the state's `level` is not 0; (3) else the shape `getLiquidCollisionShape()` of the colliding living entity, only when `ifMobIsColliding` yields a living entity (the context is an entity collision context whose entity is a `LivingEntity`) and that context's `isAbove(shape, pos, true)` is true and `canStandOnFluid(fluid of the block above, this state's fluid)` is true; otherwise empty. `LivingEntity.getLiquidCollisionShape` is the empty shape (read), and `Strider` overrides it with `Block.column(16, 0, 8)`, a full-width column 8 pixels high (read; other overrides were not exhaustively searched, Open question 11). The shape in step 3 comes from the colliding entity's `getLiquidCollisionShape`, not from the block. `getShape` is the empty shape; `propagatesSkylightDown` is false. Shape is `dynamicShape`-free: the shape cache is built. Other overrides of the class, all read as signatures and the facts below (the fluid tick algorithm they call is deferred to the fluid document of design map RS10, which does not exist yet): `isPathfindable` is true unless the fluid is in the `lava` fluid tag; `skipRendering` compares the neighbour state's fluid type with this fluid (`isSame`); `getDrops` is the empty list; `isRandomlyTicking` and `randomTick` delegate to the state's fluid state; `onPlace` and `neighborChanged` schedule a fluid tick after `FlowingFluid.getTickDelay` when `shouldSpreadLiquid` is true, then, when `shouldBubbleColumnOccupy` is true, call `tryScheduleBubbleBlockColumn` for the block below; `updateShape` schedules a fluid tick (same delay) when this or the neighbour fluid state is a source, and when the direction is down and `shouldBubbleColumnOccupy` is true it also calls `tryScheduleBubbleBlockColumn`; `tick` calls `BubbleColumnBlock.updateColumn` with `Blocks.BUBBLE_COLUMN` when `shouldBubbleColumnOccupy` is true (constant `BUBBLE_COLUMN_CHECK_DELAY` = 20); `pickupBlock` (bucket) replaces the block with air (flag value 11) and returns the fluid's bucket item only when `level` is 0, else the empty stack; `getPickupSound` returns the fluid's pickup sound. Deferred to RS10 (bodies of `shouldSpreadLiquid`, `fizz` for the lava and water interaction, `tryScheduleBubbleBlockColumn`, `shouldBubbleColumnOccupy`, `BubbleColumnBlock.updateColumn`, `FlowingFluid.getTickDelay`): Open question 19. |
| `SandBlock` | `ColorRGBA` dust colour | none | falling (29b-1 §3). Colours: sand 14406560 (0xDBD3A0), red sand 11098145 (0xA95821). |
| `ColoredFallingBlock` (gravel) | `ColorRGBA` -8356741 (0xFF807C7B) | none | falling (29b-1 §3). |
| `BrushableBlock` | turns-into block, brush sound, brush complete sound | `dusted` | has a block entity (`newBlockEntity`; 31-4); falls like sand. Sand: turns into `SAND`, sounds `BRUSH_SAND` for both. Gravel: `GRAVEL`, `BRUSH_GRAVEL`. |
| `MangroveRootsBlock` | none | `waterlogged` | `skipRendering` returns true when the neighbour state is `MANGROVE_ROOTS` and the face direction is on the Y axis (up or down), else false (no super call); `getFluidState` gives the water source when waterlogged (section 5.2); waterlogging (RS10). No override of shape, occlusion shape, light dampening or skylight propagation: the shape is the full cube, `noOcclusion` makes the occlusion shape empty (`solidRender` false), `propagatesSkylightDown` is false (the shape is a full block), so `lightDampening` is 1 (section 5.2), with `waterlogged` true or false. `suffocating:never`, so it does not suffocate. |
| `LeavesBlock` | an ambient sound player (here `noAmbientSound`) | `distance`, `persistent`, `waterlogged` | `getLightDampening` returns 1; support shape empty; `getFluidState` gives the water source when waterlogged (section 5.2); `skipRendering` returns true when the static cutout option (`setCutoutLeaves`) is off and the neighbour state's block is a `LeavesBlock`, else it defers to the `Block` default; decay (random ticks 33 §2.4; `decaying`, `distance` 7 and not persistent; rules 29b-3 §5); `setCutoutLeaves` is a static render option. |
| `TintedParticleLeavesBlock` (extends `FallingParticlesLeavesBlock`) | falling-leaf particle chance (float) | as leaves | spawns a tinted falling-leaf particle (29b-3 §5.6). |
| `UntintedParticleLeavesBlock` | chance, `ParticleOptions`, optional ambient sound event and tag | as leaves | untinted particle (29b-3 §5.6). |
| `MangroveLeavesBlock` | chance 0.01 | as leaves | tinted particle and `getParticlePos` (29b-3 §5.6). |

## 15. The rows: fields 0 to 104

Columns as in section 7. Flags `validSpawn:ocelotOrParrot` is the predicate `Blocks.ocelotOrParrot` (true exactly when
the entity type is the ocelot or the parrot); `validSpawn:never` is the constant false predicate;
`suffocating:never` and `redstoneConductor:never` are the constant false predicates. Tint class: section 9.3. Associated
item: same key (none for `water` and `lava`). Loot table: `blocks/<key>` unless `noLootTable` (`air`, `bedrock`,
`water`, `lava`). The map colour of the log family: `axis=y:A, else:B` takes A for `axis` y and B for x and z (the first
colour is used when the state's axis is y, read in `lambda$logProperties$0`).

| id | key | class | properties | states | first state id | default id | hardness | blast res. | tool req. | light | map colour | sound | push | instrument | flags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | air | AirBlock | - | 1 | 0 | 0 | 0.0 | 0.0 | no | 0 | NONE | STONE | PUSH_PULL | HARP | replaceable noCollision noLootTable air |
| 1 | stone | Block | - | 1 | 1 | 1 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 2 | granite | Block | - | 1 | 2 | 2 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | - |
| 3 | polished_granite | Block | - | 1 | 3 | 3 | 1.5 | 6.0 | yes | 0 | DIRT | STONE | PUSH_PULL | BASEDRUM | - |
| 4 | diorite | Block | - | 1 | 4 | 4 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | - |
| 5 | polished_diorite | Block | - | 1 | 5 | 5 | 1.5 | 6.0 | yes | 0 | QUARTZ | STONE | PUSH_PULL | BASEDRUM | - |
| 6 | andesite | Block | - | 1 | 6 | 6 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 7 | polished_andesite | Block | - | 1 | 7 | 7 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 8 | grass_block | GrassBlock | snowy[true/false] | 2 | 8 | 9 | 0.6 | 0.6 | no | 0 | GRASS | GRASS | PUSH_PULL | HARP | randomTicks |
| 9 | dirt | Block | - | 1 | 10 | 10 | 0.5 | 0.5 | no | 0 | DIRT | GRAVEL | PUSH_PULL | HARP | - |
| 10 | coarse_dirt | Block | - | 1 | 11 | 11 | 0.5 | 0.5 | no | 0 | DIRT | GRAVEL | PUSH_PULL | HARP | - |
| 11 | podzol | SnowyBlock | snowy[true/false] | 2 | 12 | 13 | 0.5 | 0.5 | no | 0 | PODZOL | GRAVEL | PUSH_PULL | HARP | - |
| 12 | cobblestone | Block | - | 1 | 14 | 14 | 2.0 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 13 | oak_planks | Block | - | 1 | 15 | 15 | 2.0 | 3.0 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 14 | spruce_planks | Block | - | 1 | 16 | 16 | 2.0 | 3.0 | no | 0 | PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 15 | birch_planks | Block | - | 1 | 17 | 17 | 2.0 | 3.0 | no | 0 | SAND | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 16 | jungle_planks | Block | - | 1 | 18 | 18 | 2.0 | 3.0 | no | 0 | DIRT | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 17 | acacia_planks | Block | - | 1 | 19 | 19 | 2.0 | 3.0 | no | 0 | COLOR_ORANGE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 18 | cherry_planks | Block | - | 1 | 20 | 20 | 2.0 | 3.0 | no | 0 | TERRACOTTA_WHITE | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 19 | dark_oak_planks | Block | - | 1 | 21 | 21 | 2.0 | 3.0 | no | 0 | COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 20 | pale_oak_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 22 | 23 | 2.0 | 2.0 | no | 0 | STONE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 21 | pale_oak_planks | Block | - | 1 | 25 | 25 | 2.0 | 3.0 | no | 0 | QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 22 | mangrove_planks | Block | - | 1 | 26 | 26 | 2.0 | 3.0 | no | 0 | COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 23 | poplar_planks | Block | - | 1 | 27 | 27 | 2.0 | 3.0 | no | 0 | COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 24 | bamboo_planks | Block | - | 1 | 28 | 28 | 2.0 | 3.0 | no | 0 | COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 25 | bamboo_mosaic | Block | - | 1 | 29 | 29 | 2.0 | 3.0 | no | 0 | COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 26 | oak_sapling | SaplingBlock TreeGrower.OAK | stage[0..1] | 2 | 30 | 30 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks |
| 27 | spruce_sapling | SaplingBlock TreeGrower.SPRUCE | stage[0..1] | 2 | 32 | 32 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks |
| 28 | birch_sapling | SaplingBlock TreeGrower.BIRCH | stage[0..1] | 2 | 34 | 34 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks |
| 29 | jungle_sapling | SaplingBlock TreeGrower.JUNGLE | stage[0..1] | 2 | 36 | 36 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks |
| 30 | acacia_sapling | SaplingBlock TreeGrower.ACACIA | stage[0..1] | 2 | 38 | 38 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks |
| 31 | cherry_sapling | SaplingBlock TreeGrower.CHERRY | stage[0..1] | 2 | 40 | 40 | 0.0 | 0.0 | no | 0 | COLOR_PINK | CHERRY_SAPLING | POPPED | HARP | noCollision randomTicks |
| 32 | dark_oak_sapling | SaplingBlock TreeGrower.DARK_OAK | stage[0..1] | 2 | 42 | 42 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks |
| 33 | pale_oak_sapling | SaplingBlock TreeGrower.PALE_OAK | stage[0..1] | 2 | 44 | 44 | 0.0 | 0.0 | no | 0 | METAL | GRASS | POPPED | HARP | noCollision randomTicks |
| 34 | mangrove_propagule | MangrovePropaguleBlock TreeGrower.MANGROVE | age[0..4] hanging[true/false] stage[0..1] waterlogged[true/false] | 40 | 46 | 51 | 0.0 | 0.0 | no | 0 | PLANT | GRASS | POPPED | HARP | noCollision randomTicks offset:XZ |
| 35 | poplar_sapling | SaplingBlock TreeGrower.POPLAR | stage[0..1] | 2 | 86 | 86 | 0.0 | 0.0 | no | 0 | METAL | GRASS | POPPED | HARP | noCollision randomTicks |
| 36 | bedrock | Block | - | 1 | 88 | 88 | -1.0 | 3600000.0 | no | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | noLootTable validSpawn:never |
| 37 | water | LiquidBlock Fluids.WATER | level[0..15] | 16 | 89 | 89 | 100.0 | 100.0 | no | 0 | WATER | EMPTY | POPPED | HARP | replaceable noCollision noLootTable liquid |
| 38 | lava | LiquidBlock Fluids.LAVA | level[0..15] | 16 | 105 | 105 | 100.0 | 100.0 | no | 15 | FIRE | EMPTY | POPPED | HARP | replaceable noCollision randomTicks noLootTable liquid |
| 39 | sand | SandBlock new ColorRGBA 14406560 | - | 1 | 121 | 121 | 0.5 | 0.5 | no | 0 | SAND | SAND | PUSH_PULL | SNARE | - |
| 40 | suspicious_sand | BrushableBlock SAND SoundEvents.BRUSH_SAND SoundEvents.BRUSH_SAND | dusted[0..3] | 4 | 122 | 122 | 0.25 | 0.25 | no | 0 | SAND | SUSPICIOUS_SAND | POPPED | SNARE | - |
| 41 | red_sand | SandBlock new ColorRGBA 11098145 | - | 1 | 126 | 126 | 0.5 | 0.5 | no | 0 | COLOR_ORANGE | SAND | PUSH_PULL | SNARE | - |
| 42 | gravel | ColoredFallingBlock new ColorRGBA -8356741 | - | 1 | 127 | 127 | 0.6 | 0.6 | no | 0 | STONE | GRAVEL | PUSH_PULL | SNARE | - |
| 43 | suspicious_gravel | BrushableBlock GRAVEL SoundEvents.BRUSH_GRAVEL SoundEvents.BRUSH_GRAVEL | dusted[0..3] | 4 | 128 | 128 | 0.25 | 0.25 | no | 0 | STONE | SUSPICIOUS_GRAVEL | POPPED | SNARE | - |
| 44 | gold_ore | DropExperienceBlock 0 ConstantInt.of | - | 1 | 132 | 132 | 3.0 | 3.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 45 | deepslate_gold_ore | DropExperienceBlock 0 ConstantInt.of | - | 1 | 133 | 133 | 4.5 | 3.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | legacyCopy:gold_ore |
| 46 | iron_ore | DropExperienceBlock 0 ConstantInt.of | - | 1 | 134 | 134 | 3.0 | 3.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 47 | deepslate_iron_ore | DropExperienceBlock 0 ConstantInt.of | - | 1 | 135 | 135 | 4.5 | 3.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | legacyCopy:iron_ore |
| 48 | coal_ore | DropExperienceBlock 0 2 UniformInt.of | - | 1 | 136 | 136 | 3.0 | 3.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 49 | deepslate_coal_ore | DropExperienceBlock 0 2 UniformInt.of | - | 1 | 137 | 137 | 4.5 | 3.0 | yes | 0 | DEEPSLATE | DEEPSLATE | PUSH_PULL | BASEDRUM | legacyCopy:coal_ore |
| 50 | nether_gold_ore | DropExperienceBlock 0 1 UniformInt.of | - | 1 | 138 | 138 | 3.0 | 3.0 | yes | 0 | NETHER | NETHER_GOLD_ORE | PUSH_PULL | BASEDRUM | - |
| 51 | oak_log | RotatedPillarBlock | axis[x/y/z] | 3 | 139 | 140 | 2.0 | 2.0 | no | 0 | axis=y:WOOD, else:PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 52 | spruce_log | RotatedPillarBlock | axis[x/y/z] | 3 | 142 | 143 | 2.0 | 2.0 | no | 0 | axis=y:PODZOL, else:COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 53 | birch_log | RotatedPillarBlock | axis[x/y/z] | 3 | 145 | 146 | 2.0 | 2.0 | no | 0 | axis=y:SAND, else:QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 54 | jungle_log | RotatedPillarBlock | axis[x/y/z] | 3 | 148 | 149 | 2.0 | 2.0 | no | 0 | axis=y:DIRT, else:PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 55 | acacia_log | RotatedPillarBlock | axis[x/y/z] | 3 | 151 | 152 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_ORANGE, else:STONE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 56 | cherry_log | RotatedPillarBlock | axis[x/y/z] | 3 | 154 | 155 | 2.0 | 2.0 | no | 0 | axis=y:TERRACOTTA_WHITE, else:TERRACOTTA_GRAY | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 57 | dark_oak_log | RotatedPillarBlock | axis[x/y/z] | 3 | 157 | 158 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_BROWN, else:COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 58 | pale_oak_log | RotatedPillarBlock | axis[x/y/z] | 3 | 160 | 161 | 2.0 | 2.0 | no | 0 | axis=y:QUARTZ, else:STONE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 59 | mangrove_log | RotatedPillarBlock | axis[x/y/z] | 3 | 163 | 164 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_RED, else:PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 60 | poplar_log | RotatedPillarBlock | axis[x/y/z] | 3 | 166 | 167 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_LIGHT_GRAY, else:PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 61 | mangrove_roots | MangroveRootsBlock | waterlogged[true/false] | 2 | 169 | 170 | 0.7 | 0.7 | no | 0 | PODZOL | MANGROVE_ROOTS | PUSH_PULL | BASS | noOcclusion suffocating:never ignitedByLava (the builder chain calls `noOcclusion` twice, before and after `isSuffocating`; the flag is idempotent) |
| 62 | muddy_mangrove_roots | RotatedPillarBlock | axis[x/y/z] | 3 | 171 | 172 | 0.7 | 0.7 | no | 0 | PODZOL | MUDDY_MANGROVE_ROOTS | PUSH_PULL | HARP | - |
| 63 | bamboo_block | RotatedPillarBlock | axis[x/y/z] | 3 | 174 | 175 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_YELLOW, else:PLANT | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 64 | stripped_spruce_log | RotatedPillarBlock | axis[x/y/z] | 3 | 177 | 178 | 2.0 | 2.0 | no | 0 | axis=y:PODZOL, else:PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 65 | stripped_birch_log | RotatedPillarBlock | axis[x/y/z] | 3 | 180 | 181 | 2.0 | 2.0 | no | 0 | axis=y:SAND, else:SAND | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 66 | stripped_jungle_log | RotatedPillarBlock | axis[x/y/z] | 3 | 183 | 184 | 2.0 | 2.0 | no | 0 | axis=y:DIRT, else:DIRT | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 67 | stripped_acacia_log | RotatedPillarBlock | axis[x/y/z] | 3 | 186 | 187 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_ORANGE, else:COLOR_ORANGE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 68 | stripped_cherry_log | RotatedPillarBlock | axis[x/y/z] | 3 | 189 | 190 | 2.0 | 2.0 | no | 0 | axis=y:TERRACOTTA_WHITE, else:TERRACOTTA_PINK | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 69 | stripped_dark_oak_log | RotatedPillarBlock | axis[x/y/z] | 3 | 192 | 193 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_BROWN, else:COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 70 | stripped_pale_oak_log | RotatedPillarBlock | axis[x/y/z] | 3 | 195 | 196 | 2.0 | 2.0 | no | 0 | axis=y:QUARTZ, else:QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 71 | stripped_oak_log | RotatedPillarBlock | axis[x/y/z] | 3 | 198 | 199 | 2.0 | 2.0 | no | 0 | axis=y:WOOD, else:WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 72 | stripped_mangrove_log | RotatedPillarBlock | axis[x/y/z] | 3 | 201 | 202 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_RED, else:COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 73 | stripped_poplar_log | RotatedPillarBlock | axis[x/y/z] | 3 | 204 | 205 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_LIGHT_GRAY, else:COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 74 | stripped_bamboo_block | RotatedPillarBlock | axis[x/y/z] | 3 | 207 | 208 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_YELLOW, else:COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 75 | oak_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 210 | 211 | 2.0 | 2.0 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 76 | spruce_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 213 | 214 | 2.0 | 2.0 | no | 0 | PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 77 | birch_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 216 | 217 | 2.0 | 2.0 | no | 0 | SAND | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 78 | jungle_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 219 | 220 | 2.0 | 2.0 | no | 0 | DIRT | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 79 | acacia_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 222 | 223 | 2.0 | 2.0 | no | 0 | COLOR_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 80 | cherry_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 225 | 226 | 2.0 | 2.0 | no | 0 | TERRACOTTA_GRAY | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 81 | dark_oak_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 228 | 229 | 2.0 | 2.0 | no | 0 | COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 82 | mangrove_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 231 | 232 | 2.0 | 2.0 | no | 0 | COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 83 | poplar_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 234 | 235 | 2.0 | 2.0 | no | 0 | PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 84 | stripped_oak_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 237 | 238 | 2.0 | 2.0 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 85 | stripped_spruce_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 240 | 241 | 2.0 | 2.0 | no | 0 | PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 86 | stripped_birch_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 243 | 244 | 2.0 | 2.0 | no | 0 | SAND | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 87 | stripped_jungle_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 246 | 247 | 2.0 | 2.0 | no | 0 | DIRT | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 88 | stripped_acacia_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 249 | 250 | 2.0 | 2.0 | no | 0 | COLOR_ORANGE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 89 | stripped_cherry_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 252 | 253 | 2.0 | 2.0 | no | 0 | TERRACOTTA_PINK | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 90 | stripped_dark_oak_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 255 | 256 | 2.0 | 2.0 | no | 0 | COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 91 | stripped_pale_oak_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 258 | 259 | 2.0 | 2.0 | no | 0 | QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 92 | stripped_mangrove_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 261 | 262 | 2.0 | 2.0 | no | 0 | axis=y:COLOR_RED, else:COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 93 | stripped_poplar_wood | RotatedPillarBlock | axis[x/y/z] | 3 | 264 | 265 | 2.0 | 2.0 | no | 0 | COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 94 | oak_leaves | TintedParticleLeavesBlock 0.01f | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 267 | 294 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 95 | spruce_leaves | LeavesBlock AmbientLeavesBlockSoundPlayer.noAmbientSound | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 295 | 322 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 96 | birch_leaves | TintedParticleLeavesBlock 0.01f | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 323 | 350 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 97 | jungle_leaves | TintedParticleLeavesBlock 0.01f | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 351 | 378 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 98 | acacia_leaves | TintedParticleLeavesBlock 0.01f | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 379 | 406 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 99 | cherry_leaves | UntintedParticleLeavesBlock 0.1f ParticleTypes.CHERRY_LEAVES AmbientLeavesBlockSoundPlayer.noAmbientSound | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 407 | 434 | 0.2 | 0.2 | no | 0 | COLOR_PINK | CHERRY_LEAVES | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 100 | dark_oak_leaves | TintedParticleLeavesBlock 0.01f | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 435 | 462 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 101 | pale_oak_leaves | UntintedParticleLeavesBlock 0.02f ParticleTypes.PALE_OAK_LEAVES AmbientLeavesBlockSoundPlayer.noAmbientSound | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 463 | 490 | 0.2 | 0.2 | no | 0 | METAL | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 102 | mangrove_leaves | MangroveLeavesBlock 0.01f | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 491 | 518 | 0.2 | 0.2 | no | 0 | PLANT | GRASS | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 103 | red_poplar_leaves | UntintedParticleLeavesBlock 0.01f ParticleTypes.RED_POPLAR_LEAVES SoundEvents.POPLAR_LEAVES_AMBIENT BlockTags.REQUIRED_FOR_POPLAR_LEAF_AMBIENCE AmbientLeavesBlockSoundPlayer.of | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 519 | 546 | 0.2 | 0.2 | no | 0 | COLOR_RED | POPLAR_LEAVES | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |
| 104 | orange_poplar_leaves | UntintedParticleLeavesBlock 0.01f ParticleTypes.ORANGE_POPLAR_LEAVES SoundEvents.POPLAR_LEAVES_AMBIENT BlockTags.REQUIRED_FOR_POPLAR_LEAF_AMBIENCE AmbientLeavesBlockSoundPlayer.of | distance[1..7] persistent[true/false] waterlogged[true/false] | 28 | 547 | 574 | 0.2 | 0.2 | no | 0 | COLOR_ORANGE | POPLAR_LEAVES | POPPED | HARP | randomTicks noOcclusion validSpawn:ocelotOrParrot suffocating:never ignitedByLava redstoneConductor:never |


Row counts by class (for checking): `RotatedPillarBlock` 43, `Block` 23, `SaplingBlock` 9, `DropExperienceBlock` 7,
`TintedParticleLeavesBlock` 5, `UntintedParticleLeavesBlock` 4, `LiquidBlock` 2, `SandBlock` 2, `BrushableBlock` 2, and one each
of `AirBlock`, `GrassBlock`, `SnowyBlock`, `MangrovePropaguleBlock`, `ColoredFallingBlock`, `MangroveRootsBlock`,
`LeavesBlock` (spruce) and `MangroveLeavesBlock`. Total 105 rows and 575 states.

### 15.1 Derived values per row (columns that are rules, tabulated for this part)

The following per-row values are not columns of the table above because each follows from a rule; they are listed here
so that an implementer does not have to derive them. "Shape" is the outline shape from `getShape`; "collision" is the
collision shape; "occlusion" is the occlusion shape (section 5.2); "dampening" is `lightDampening`. Defaults for every
row of this part: friction 0.6, speed factor 1.0, jump factor 1.0 (section 4.1; none of the 105 rows overrides them, so those three columns are constant here); the explicit burn pair (ignite, burn) is (5, 20) for planks, bamboo mosaic and mangrove roots, (5, 5) for logs and wood and (30, 60) for leaves (table 15.2; read from 17 §3.3a, not re-read from the jar in this round); loot table `blocks/<key>` except the four
`noLootTable` rows; associated item same key except `water` and `lava`.

| Rows (ids) | Shape | Collision | Occlusion | Dampening | Tint source (9.3) | Ignited by lava | Fluid state |
|---|---|---|---|---|---|---|---|
| 0 `air` | empty | empty | empty | 0 | none | no | empty |
| 1 to 7, 9, 10, 12 (stone family, dirt, coarse dirt, cobblestone) | full cube | full cube | full cube | 15 | none | no | empty |
| 8 `grass_block` | full cube | full cube | full cube | 15 | `grassBlock()` | no | empty |
| 11 `podzol` | full cube | full cube | full cube | 15 | none | no | empty |
| 13 to 25 (planks, mosaic) | full cube | full cube | full cube | 15 | none | yes | empty |
| 20, 51 to 60, 63 to 93 (wood, logs, stripped, bamboo block) | full cube | full cube | full cube | 15 | none | yes | empty |
| 26 to 33, 35 (saplings) | 12x12 pixel column, y 0 to 12 | empty | empty (`noCollision` also clears `canOcclude`) | 0 (the shape is not a full block and the fluid is empty, so skylight propagates) | none | no | empty |
| 34 `mangrove_propagule` | 2x2 column by age and hanging (6.8), moved by the XZ offset | empty | empty (`noCollision`) | 0 when not waterlogged; with `waterlogged` true the fluid is not empty, so skylight does not propagate by the default rule and the dampening is 1 (derived from section 5.2) | none | no | water source when `waterlogged` |
| 36 `bedrock`, 39 to 50 (sand, gravel, suspicious blocks, ores) | full cube | full cube | full cube | 15 | none | no | empty |
| 37 `water`, 38 `lava` | empty | empty (the collision shape of liquids is context dependent, section 14) | empty | 1 (`propagatesSkylightDown` is false by the `LiquidBlock` override and the occlusion is empty, so the default rule gives 1; same class for both) | 37: `waterParticles()` (in world 0xFFFFFFFF, terrain particle colour the biome water colour); 38: none | no | the liquid, by level |
| 61 `mangrove_roots` | full cube | full cube | empty (`noOcclusion`) | 1 | none | yes | water source when `waterlogged` |
| 62 `muddy_mangrove_roots` | full cube | full cube | full cube | 15 | none | no | empty |
| 94 `oak_leaves`, 97 `jungle_leaves`, 98 `acacia_leaves`, 100 `dark_oak_leaves`, 102 `mangrove_leaves` | full cube (block support shape empty) | full cube | empty (`noOcclusion`) | 1 (class override) | `foliage()` | yes | water source when `waterlogged` |
| 95 `spruce_leaves` | as above | full cube | empty | 1 | `constant(0xFF619961)` | yes | water source when `waterlogged` |
| 96 `birch_leaves` | as above | full cube | empty | 1 | `constant(0xFF80A755)` | yes | water source when `waterlogged` |
| 99, 101, 103, 104 (cherry, pale oak, red poplar, orange poplar leaves) | as above | full cube | empty | 1 | none | yes | water source when `waterlogged` |

Rows with a non-default tint source: 8 (grass block), 37 (water, particle colour only), 94, 97, 98, 100, 102 (foliage colour), 95 and 96 (constant
colours). Rows that are not a full cube in shape or collision: 0, 26 to 35, 37, 38. Rows whose occlusion is not a full
cube although the shape is: 61 and 94 to 104.

### 15.2 Burn odds and tool tags per row (read; cross-references 17 §3.3a and 17 Appendix A)

Burn and ignite odds are the pair registered by `FireBlock.bootStrap` (17 §3.3a: "(ignite, burn)"); a row not listed is not flammable (ignite odds 0). The fire rules that consume the pair are in 17 §3.3a and 29b-3. Tool tags are the contents of the shipped tag files with `#` entries expanded (data; the extraction tool, 22, supplies them at run time, this table only lets the rows be checked). Rows not named in a tag column are in no tag of that column.

| Rows (ids) | (ignite, burn) | `mineable/*` | `needs_*` | `incorrect_for_*` | Other tags read |
|---|---|---|---|---|---|
| 0 `air`, 26 to 35 (saplings), 36 `bedrock`, 37 `water`, 38 `lava` | not flammable | none | none | none | none |
| 1 to 7, 12 (stone family, cobblestone) | not flammable | pickaxe | none | none (the tool-required flag alone: any pickaxe, any tier) | none |
| 8 `grass_block`, 9 `dirt` | not flammable | shovel | none | none | `turns_into_dirt_path`, `turns_into_farmland` |
| 10 `coarse_dirt`, 11 `podzol` | not flammable | shovel | none | none | `turns_into_dirt_path` |
| 39 to 43 (sand, suspicious sand, red sand, gravel, suspicious gravel) | not flammable | shovel | none | none | none |
| 44, 45 (gold ore, deepslate gold ore) | not flammable | pickaxe | `needs_iron_tool` | wooden, gold, stone, copper | none |
| 46, 47 (iron ore, deepslate iron ore) | not flammable | pickaxe | `needs_stone_tool` | wooden, gold | none |
| 48, 49, 50 (coal ore, deepslate coal ore, nether gold ore) | not flammable | pickaxe | none | none | none |
| 13 to 19, 21 to 25 (planks, bamboo mosaic) | (5, 20) | axe | none | none | none |
| 20, 51 to 60, 63 to 93 (wood, logs, stripped logs and wood, bamboo block, stripped bamboo block) | (5, 5) | axe | none | none | none |
| 61 `mangrove_roots` | (5, 20) | axe | none | none | none |
| 62 `muddy_mangrove_roots` | not flammable | shovel | none | none | none |
| 94 to 104 (all leaves) | (30, 60) | hoe | none | none | `sword_efficient`, `shears_extreme_breaking_speed` |

Checks: `needs_diamond_tool`, `incorrect_for_iron_tool`, `incorrect_for_diamond_tool`, `incorrect_for_netherite_tool`, `sword_instantly_mines`, `shears_major_breaking_speed` and `shears_minor_breaking_speed` contain none of rows 0 to 104. `mineable/axe` has 55 rows here, `mineable/pickaxe` 15, `mineable/shovel` 10, `mineable/hoe` 11 (these counts are of this range only). The pickaxe, axe, shovel and hoe rows agree with 17 Appendix A. `ignitedByLava` (section 15 flags) is a separate property from the fire odds: the planks, wood and logs, mangrove roots and leaves carry it.

Block order by family inside the range (ids): 0 air; 1 to 7 stone, granite, polished granite, diorite, polished
diorite, andesite, polished andesite; 8 to 11 grass block, dirt, coarse dirt, podzol; 12 cobblestone; 13 to 25
planks and mosaic (section 2.3 gives the order); 26 to 35 saplings (the mangrove propagule at 34, the poplar sapling
at 35); 36 bedrock; 37 water; 38 lava; 39 to 43 sand, suspicious sand, red sand, gravel, suspicious gravel; 44 to
50 gold ore, deepslate gold ore, iron ore, deepslate iron ore, coal ore, deepslate coal ore, nether gold ore; 51 to
60 logs (oak, spruce, birch, jungle, acacia, cherry, dark oak, pale oak, mangrove, poplar); 61 and 62 mangrove roots and
muddy mangrove roots; 63 bamboo block; 64 to 74 stripped logs (spruce, birch, jungle, acacia, cherry, dark oak, pale
oak, oak, mangrove, poplar, then stripped bamboo block); 75 to 93 wood and stripped wood; 94 to 104 leaves.

## 16. Worked examples

1. **State ids of a log.** `oak_log` has one property, `axis` (x, y, z), 3 states, first state id 139. Ids:
   `axis=x` 139, `axis=y` 140, `axis=z` 141. The default is `axis=y`, id 140.
2. **State ids of leaves.** `oak_leaves`: properties sorted by name `distance` (1..7), `persistent` (true, false),
   `waterlogged` (true, false); 7 * 2 * 2 = 28 states; first state id 267. Index of a state =
   `(distance - 1) * 4 + p * 2 + w`, where p is 0 for `persistent=true` and 1 for false, and w likewise for
   `waterlogged`. The default (`distance=7`, both false) has index 6*4 + 1*2 + 1 = 27, so id 294. State
   `distance=1, persistent=true, waterlogged=true` is id 267. The next block (`spruce_leaves`) starts at 295.
3. **State ids of the propagule.** `mangrove_propagule`: sorted properties `age` (0..4), `hanging` (true, false), `stage`
   (0, 1), `waterlogged` (true, false): 5 * 2 * 2 * 2 = 40 states, first id 46. Default (`age=0`, `hanging=false`,
   `stage=0`, `waterlogged=false`): index ((0 * 2 + 1) * 2 + 0) * 2 + 1 = 5, id 51. The block after it, `poplar_sapling`, starts at 86.
4. **Boundaries.** `water` first state id 89 (16 states, 89..104), `lava` 105..120, `sand` 121. The first block of
   part 2 (id 105) has first state id 575.
5. **Break time (uses the table).** Per tick progress = (tool speed / hardness) / d, with d = 30 for a correct tool
   (or a block that needs no tool) and 100 otherwise (section 5.2; 13 §2.1). `stone` (hardness 1.5, tool required) by
   hand: speed 1.0, d = 100: 1.0 / 1.5 / 100 = 0.006667 per tick, 150 ticks. With an iron pickaxe (speed 6.0 is the
   tier's speed from 17, d = 30): 6 / 1.5 / 30 = 0.1333, 8 ticks. `dirt` (hardness 0.5, no tool requirement) by hand: 1 / 0.5 / 30 =
   0.0667, 15 ticks. `bedrock` (-1): progress 0, never breaks in survival.
6. **Light and opacity.** `stone` (full opaque cube): lightDampening 15. `oak_leaves`: `noOcclusion`, occlusion shape
   empty, dampening 1 (class override). `water`: shape empty, `propagatesSkylightDown` false (class override), dampening 1,
   light emission 0. `lava`: emission 15. `air`: empty shape, propagates skylight, dampening 0. `oak_sapling`: empty
   collision, shape not a full block, no fluid, propagates skylight, dampening 0.
7. **Offset.** `mangrove_propagule` has offset type XZ. At x = 0, z = 0 the seed is 0, so both horizontal fractions are
   (0 / 15 - 0.5) * 0.5 = -0.25, which is within the default clamp of 0.25 (the propagule does not override
   `getMaxHorizontalOffset`, section 6.8), giving an offset of (-0.25, 0, -0.25).
8. **Tint.** `grass_block` in the world: `BiomeColors.getAverageGrassColor`; in hand: `GrassColor.getDefaultColor()`;
   as a terrain particle: 0xFFFFFFFF. `spruce_leaves`: constant 0xFF619961 in both places. `oak_leaves`: foliage
   colour; in hand 0xFF48B518. `cherry_leaves`: none.
9. **Legacy copy.** `deepslate_gold_ore` takes everything from `gold_ore` (hardness 3.0, resistance 3.0, tool required,
   instrument `BASEDRUM`, map colour `STONE`) and then sets map colour `DEEPSLATE`, strength (4.5, 3.0) and sound
   `DEEPSLATE`. Result: 4.5 / 3.0, tool required, instrument `BASEDRUM`.

## 17. Validation

How to check an implementation against this document:

1. Count: 105 rows (ids 0 to 104), 575 states in total; the state ranges are contiguous with no gap (each row's first
   state id equals the previous row's first state id plus its state count). Section 15 satisfies this by construction
   (the table was generated from the builder chains and class property lists and the sum was checked: 575).
2. Registry order: the registration order equals the declaration order of the fields of `Blocks` (compared for all
   911 fields in this round).
3. Property rule: the state count of every block equals the product of its property value counts, and the default id
   lies in [first, first + states - 1].
4. Cross-checks with other documents: 04 §5.2 formula (examples 1 to 3 above); the break times of example 5 agree with
   13 §9 (stone by hand 150 ticks, with an iron pickaxe 8, dirt by hand 15); the ore blocks of 11 §8 are rows 44 to 50
   here (hardness and resistance as listed, deepslate variants 4.5 / 3.0).
5. A reference client can validate ids through its block state registry dump (`registries.json` and `blocks.json` of the
   data generator, 04 §5.1). The ids in section 15 are the values such a dump would give for these 105 blocks.
6. Reading checks that were done in this round: the default lambdas of `Properties` (section 4.1) were resolved
   through the bootstrap method table (the redstone-conductor default is a method reference to
   `isCollisionShapeFullBlock`; the suffocating default is a separate lambda; the view-blocking default delegates to
   the suffocating predicate); `ofLegacyCopy` and `ofFullCopy` were compared field by field; the tint registrations
   were read in full.

Not validated: any behaviour listed as owned by another document (growth, falling, fluids, decay); the tag contents beyond the rows of this part (data, 22).

## 18. Open questions

1. Collection ids (section 2.3): the first ids of the collection fields and the total of 1286 blocks are computed from
   the field list and the registration call counts, assuming every non-collection field registers exactly one block and
   every colour field 16 and weathering field 8 blocks. They were searched for in `Blocks.<clinit>` (call counts) and in
   `ColorCollection`, `WeatheringCopperCollection` and `ByState`, but not compared with a registry dump. How the
   weathering prefixes are joined to the base names (the key of each of the 8 blocks of a weathering field) is not read
   here; the parts that cover those fields give the keys.
2. Resolved: the `ColorCollection.prefixWithColor` recipe is `\u0001_\u0001`, the colour first (section 2.3). No open point.
3. Resolved: the 66 `BlockTags` names built from `BlockItemTags` were read there (section 12.1, 12.3). No open point.
4. Resolved: the propagule shapes and offsets are in section 6.8. No open point.
5. Resolved: burn and spread odds are in 17 §3.3a and tabulated per row in section 15.2. No open point.
6. The map rendering rules that choose a `MapColor$Brightness` for a map pixel (the modifiers themselves are read,
   section 8.1).
7. Resolved: `NoteBlockInstrument` constants 19 to 26 are named in section 8.3. Their types and sound events were not
   read (they belong to the note block row, a later part).
8. Resolved: `GrassColor.getDefaultColor()` is `get(0.5, 1.0)`. Not read: the numeric content of the colormap textures (data).
9. Resolved: the biome blend radius and the tint cache are in 43 §4. No open point.
10. Resolved: `LeavesBlock.createBlockStateDefinition` adds exactly `distance`, `persistent` and `waterlogged` (read), and `FallingParticlesLeavesBlock` has no override of it, so the leaves have three properties.
11. Open: which entity classes other than `LivingEntity` (empty) and `Strider` (column 16, 0, 8) override `getLiquidCollisionShape`; a scan of the entity classes was started but not completed, and the bodies of `CollisionContext.isAbove` and `canStandOnFluid` were not read.
12. `CENTER` and `FULL` support types were read; the exact branch of `VoxelShape.getFaceShape` for non-cube-like shapes
    (`calculateFace`) was not decoded: section 6.4 describes only the entry rules.
13. Resolved in part: the construction of the tool rule lists from `incorrect_for_*` and `mineable/*` is read (section 12.2). Open: the body of `Tool` that evaluates a rule list for a block (which rule wins when several match, how `deniesDrops` interacts with `minesAndDrops`); 13 §2 and 17 own it, and `Tool$Rule` was not read here.
14. `SoundEvents` field to registry key mapping for the 131 sound types: 46 §14.3 owns the sound event table; not
    cross-checked here.
15. The class of `Block$ShapePairKey`-based face culling (`shouldRenderFace`) was only skimmed (cache size 256, compare
    with `ONLY_FIRST`): a full read belongs to the rendering document.
16. Uses of tags in section 12.2 that remain untraced: the grouping tags other than `snow`, `logs`, `leaves` and `air` (referrers of `planks`, `saplings`, `sand`, `dirt`, `ores`, `base_stone_overworld`, `fire` and the second referrers of `climbable`, `Entity` and `DismountHelper`, were not read); the bodies of the heightmap fields `MATERIAL_MOTION_BLOCKING` and `NOT_AIR`; the bodies after the first test in `CushionItem` use-on. Searched: every class of the jar for the field names of the tags in section 12.2 (all other referrers are read, see the table).
17. Resolved: the `isSolid` fallthrough value is false, read from `SolidDebugger$Reason.FALLTHROUGH` (section 5.2). No open point.
18. Resolved for rows 0 to 104: burn odds (section 15.2, 17 §3.3a) and tool tag membership (section 15.2, read from the shipped tag files, agreeing with 17 Appendix A). Tag membership of the rows of other parts remains with the extraction tool (22) and the parts that cover them.
19. Fluid behaviour of `LiquidBlock` deferred to RS10 (design map GAP-9; no numbered document exists yet): `shouldSpreadLiquid`, `fizz` (lava and water interaction), `tryScheduleBubbleBlockColumn`, `shouldBubbleColumnOccupy`, `BubbleColumnBlock.updateColumn`, `FlowingFluid.getTickDelay` and the fluid tick itself. Only the call structure of these overrides is stated in section 14.
