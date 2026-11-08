# 35 Worldgen features, part 1: shared model, generic features and placement modifiers

| Item | Value |
|---|---|
| Covers | The model every world-generation feature shares: what a feature and a placed feature are in this version, the place contract and its boolean result, the write rules and flags of the world-generation level, the 3 x 3 chunk write window, random-source conventions and per-feature seeding (by reference to 11), the debug-only feature counter, the type registries that features use (names and ids in registration order), the schema conventions of the data pack's feature and placed-feature elements; the generic and combinator features (`no_op`, `random_selector`, `simple_random_selector`, `random_boolean_selector`, `weighted_random_selector`, `sequence`, and the helper record `WeightedPlacedFeature`); `PlacedFeature.place` and `PlacementContext` (the evaluation of the modifier list, with draw order); and every placement modifier (18 types). |
| Does not cover | Rows of data (the extraction tool copies the `worldgen/feature`, `worldgen/placed_feature` and `worldgen/block_state_provider` elements, see 22 and 23 section 2.1). The other 52 feature types, the tree placers, tree decorators, block predicates and state providers beyond their names: those are the sibling parts of this document (35 part 2 predicates and providers, part 3 tree placers, part 4 decorators and vegetation, part 5 water and surface, part 6 underground, part 7 nether, end and miscellaneous). The ore feature (11 section 7). Structures (RS20). Numeric providers: 23 section 7 already specifies `IntProvider`, `FloatProvider`, `HeightProvider`, `WeightedList` and `BlockStateProvider` completely, so this document only cross-references them and adds how they are drawn from the world-generation random source. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.feature.*`, `...placement.*`, `...heightproviders.*`, `...blockpredicates.*`, `...feature.stateproviders.*`, `...trunkplacers`, `...foliageplacers`, `...rootplacers`, `...treedecorators`, `...featuresize`, of `net.minecraft.server.level.WorldGenRegion`, `net.minecraft.world.level.chunk.ChunkGenerator`, `ProtoChunk`, `LevelChunk`, `chunk.status.ChunkPyramid` and `ChunkStep`, `levelgen.Heightmap`, `WorldgenRandom`, `BitRandomSource`, and of the data-generated JSON under `data/minecraft/worldgen/` in the jar. No execution. Counts were taken with `unzip -Z1 <jar> | grep -v '/$' | grep <prefix> | wc -l`. Values marked "(computed)" were produced by a scratch implementation of this document's own rules, not by the artifact. |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12a, R4, R7, R10). |
| Status | Written by the reader for round RS19, part 1. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. No fact in this document is taken from recall:
where the artifact differs from what an earlier version of the game did, only the artifact's behaviour is written. References
use "10 section 2" for other documents and "section 5" for this one. Coordinates are block coordinates; `y` is the vertical
axis; the overworld has `minY = -64`, height 384 (top block 319), sea level 63 (10 section 5).

---

## 1. What this version's feature model is

Three structural facts, all read from the artifact, shape everything below.

1. **There is no "configured feature" layer.** The registry `worldgen/feature` (23 section 2.1, row 4) holds `Feature` values
   directly. A `Feature` is an interface (`net.minecraft.world.level.levelgen.feature.Feature`); each feature type is a record
   whose fields are its configuration. The element JSON is therefore one object: `{"type": "minecraft:<feature_type>", <the
   record's fields beside type>}` (dispatch over the static registry `worldgen/feature_type`, section 3). There is no `config`
   wrapper. The class `ConfiguredFeature` and the registry `worldgen/configured_feature` do not exist in the jar (0 classes of that
   name; 23's list of the 51 world registries has no such row).
2. **A placed feature is a feature plus a modifier list.** `PlacedFeature` is a record `{feature, placement}`; `feature` names an
   element of `worldgen/feature` (or an inline feature object) and `placement` is a list of placement modifiers (possibly empty).
   Placed features are registry elements of `worldgen/placed_feature` and are what a biome's `features` lists name (11 section 6.2).
3. **Placement is evaluated by `FeaturePlacer`**, an explicit-stack evaluator (section 8), not by a recursive call.
   Its observable order is depth first (section 8.2). One placement modifier, `cuboid`, lives in the `feature` package and not in
   `placement`.

Element shapes (all fields read from the codecs; `H-or-I` is the Id-or-inline holder form of 23 section 5.1, `HolderSet` the
holder-set form there):

| Element | JSON | Notes |
|---|---|---|
| Feature | `{"type": id, ...fields}` | `Feature.DIRECT_CODEC`: dispatch on `type` over `worldgen/feature_type`; fields inline |
| Placed feature | `{"feature": H-or-I(Feature), "placement": [modifier, ...]}` | both fields required; `placement` may be `[]`. `PlacedFeature.DIRECT_CODEC` |
| Placement modifier | `{"type": id, ...fields}` | dispatch over `worldgen/placement_modifier_type`; fields inline |
| Reference to a feature | a String id of a `worldgen/feature` element, or an inline Feature object | `Feature.CODEC` (23 section 5.1 Id-or-inline) |
| Reference to a placed feature | a String id of a `worldgen/placed_feature` element, or an inline placed feature | `PlacedFeature.CODEC` (Id-or-inline) |
| List of placed features | one placed feature, a `#tag`, or a list | `PlacedFeature.LIST_CODEC` (HolderSet, non-homogeneous: 23 section 5.1) |
| List of lists (biome `features`) | a list of lists; each inner value must itself be a list of elements (no `#tag`, no single bare element: the homogeneous flag) | `PlacedFeature.LIST_OF_LISTS_CODEC` (`holderSet` with the homogeneous flag true) |

Inline forms occur in the data: for example `trees_plains` (a `random_selector`) has a `default` that is an inline placed feature
`{"feature": "minecraft:oak_bees_005", "placement": []}` and a feature entry that is a bare placed-feature id.

### 1.1 Schema conventions of the config records

Conventions read from the codecs of this part and observed in the data files; the sibling parts apply them to the other feature types.

| Convention | Rule |
|---|---|
| Files and ids | `data/<ns>/worldgen/feature/<path>.json` is the feature `<ns>:<path>`; the path may contain `/` (the six `coral/...` files are `minecraft:coral/brain_block` and so on); the same for `worldgen/placed_feature` (23 sections 1 and 3 for discovery, pack order and error reporting) |
| Required field | decoded with a plain field codec; a missing field is a decode error naming the field |
| Optional field | decoded with a default; the data-generated files **omit** optional fields that equal the default (for example `noise_offset` is absent from the kelp placement, `allowed_search_condition` from scans that allow everything) |
| Dispatch | an object with a `type` String (an id of the registry named in section 3; the namespace follows the id rules of 23 section 1) and the type's fields beside it, for features, placement modifiers, block predicates, providers and placers. Exception seen in the data: the ore `targets` rules (11 section 7.3) dispatch on a key named `predicate_type` over the structure-template rule tests (`RuleTest` classes in `levelgen.structure.templatesystem`: `tag_match`, `block_match`, `height_match`, `all_of`, `any_of`, `not`), which are **not** the block predicates of `block_predicate_type`; they belong to the ore feature, not to this document |
| Integer providers | an integer is the constant provider; objects dispatch on `type` (23 section 7.1); bounded variants reject out of range providers at decode (section 10) |
| Float in a fixed range | `Codec.floatRange(0, 1)` for chances; `ExtraCodecs.POSITIVE_INT` for the `rarity_filter` chance |
| Non-empty lists | `ExtraCodecs.nonEmptyList` (`randomly_selected.placements`), `ExtraCodecs.nonEmptyHolderSet` (`simple_random_selector`, `sequence`) |
| Positions | a `BlockPos` is a JSON array of three ints `[x, y, z]` (`fixed_placement.positions`, and the `offset` field of block predicates, 35 part 2) |
| Directions | the lowercase names `down`, `up`, `north`, `south`, `west`, `east`; `direction_of_search` accepts only `up` and `down` |
| Heightmap | the uppercase names of section 4.2 |
| Block state | an object `{"id": "<block>", "properties": {"<name>": "<value as string>", ...}}` (23 section 7.4 for the bare-String form and the leniency of `properties`) |
| References | Ids are Strings; tags are `#`-prefixed Strings in holder-set fields (23 section 5.1) |
| Order of keys | the generated files write `type` first and the other keys in alphabetical order; key order has no meaning |

Counts in the jar (read with `unzip -Z1`, directory entries excluded): `data/minecraft/worldgen/feature/` 240 files (234 at top
level and 6 in the `coral/` folder, all of type `overlay`), `placed_feature/` 273 files, `block_state_provider/` 8 files,
`biome/` 67 files. Of the 58 registered feature types, 11 have no top-level feature file (`coral_claw`, `coral_tree`,
`fill_layer`, `no_op`, `projected_random_patchy_square`, `replace_single_block`, `sculk_patch`, `single_block_pillar`,
`speleothem`, `stepped_column_cluster`, `template`); several of them occur inline inside other features (for example `no_op`
twice, `coral_claw` and `coral_tree` five times each among the four folders read: feature, placed_feature, biome,
block_state_provider).

---

## 2. The place contract and the boolean result

### 2.1 Signature

Every feature implements one method: `place(level, generator, random, pos)` with `level` a `WorldGenLevel` (section 4),
`generator` the `ChunkGenerator` of the dimension, `random` a `RandomSource` (section 5) and `pos` a block position. It returns a
boolean. There is no separate "context" object in this version: everything a feature needs is the four arguments plus its own
record fields.

Meaning of the result: **true when the feature changed the world or otherwise counts as having succeeded, false when it
declined.** The exact condition is each feature's own and is given by the part that specifies it. The result is consumed in
exactly three places:

| Consumer | Use of the boolean |
|---|---|
| `Sequence` feature (section 9.6) | stops at the first element that returns false and returns false; true when all returned true |
| `PlacedFeature.place` (section 8) | with an empty modifier list it returns the feature's own result; with modifiers it returns the OR over all positions that reached the feature (false when none did) |
| `/place feature` (command, section 2.3) | false makes the command fail with `commands.place.feature.failed` |

The decoration driver (section 6) ignores the result. The selector features return the nested result unchanged. The engine does not
enforce that a feature which returns false has written nothing: a feature may write and then return false.

### 2.2 Helper methods every feature may use (interface defaults)

| Method | Behaviour (read) |
|---|---|
| `setBlock(writer, pos, state)` | `writer.setBlockAndUpdate(pos, state)`, i.e. `setBlock(pos, state, 3)` (flags 1 and 2, 29 section 1) |
| `safeSetBlock(level, pos, state, filter)` | if `filter.test(level.getBlockState(pos))` is true, `level.setBlock(pos, state, 2)` (flag 2 only); the return value of `setBlock` is dropped |
| `markAboveForPostProcessing(level, pos)` | repeat twice: move up one block; if the block there is air (`isAir`, which includes cave and void air) stop; otherwise `level.getChunk(pos).markPosForPostProcessing(pos)` |
| `getSubFeatures()` | the stream of nested placed features' features (empty by default); used by `PlacedFeature.getFeatures()` to flatten a nested tree. Not part of placement |

`level.setBlock(pos, state, flags)` of the `LevelWriter` default adds the budget 512 (`UPDATE_LIMIT`) and calls the
four-argument form; the generation level ignores the budget (section 4.2).

### 2.3 Other callers of `place`

| Caller | Random source | Level |
|---|---|---|
| Chunk decoration (`ChunkGenerator.applyBiomeDecoration`) | the per-chunk `WorldgenRandom` of section 5, reseeded per placed feature | the `WorldGenRegion` of the chunk (section 4) |
| Nested placed features (selectors, `sequence`, section 9) | the same `random` object | the same level |
| `/place feature <feature> [pos]` (`PlaceCommand.placeFeature`) | `ServerLevel.getRandom()` (the live level's random) | the `ServerLevel` itself, which also implements `WorldGenLevel` (flags then behave as in 29); requires the 3 x 3 chunks around the position to be loaded. It calls `Feature.place` directly (a feature, **not** a placed feature: no modifiers run), with `pos` as given |

Note for 16: the command catalog names the argument kind `configured_feature`; in this jar the argument is a holder of a
`Feature` (registry `worldgen/feature`), see Open question 9.

### 2.4 `FeatureCountTracker` (debug only)

`FeatureCountTracker` counts, per level, how often each (feature, top-level placed feature) pair was placed and how many chunks
were decorated, and can log the table (`logCounts`: per feature a count and the count divided by the chunk total). It is called
only when `SharedConstants.DEBUG_FEATURE_COUNT` is true: from `FeaturePlacer.place` (with an empty modifier list, **before** the single
`Feature.place` call; with modifiers, **after** each `Feature.place`, once per emitted position; in both cases gated only on the flag, not
on the boolean result) and from `applyBiomeDecoration` after a chunk. The flag is a boolean read at class
load with `debugFlag("FEATURE_COUNT")` (a debug property; its source was not traced, Open question 10). **It has no effect on
generation, and an implementation may omit it.** Exceptions inside the tracker are caught and logged ("Failed to increment feature
count", "Failed to increment chunk count").

---

## 3. Type registries used by features

All twelve are static registries created with `registerSimple` (no default entry), filled by one bootstrap each, so an
entry's id is the number of entries registered before it (46 section 2.1). **None of these ids appears on the wire** (they are
not synchronized and no packet names them: 04 section 3 lists the synchronized registries); names are what data and saves use. The
ids are given so an implementation that keeps a numeric table matches the artifact (R8). The registry path is the text after
`minecraft:` in the registry name.

| Registry path | Entries | Element | Bootstrap class | Specified in |
|---|---|---|---|---|
| `worldgen/feature_type` | 58 | `MapCodec` of a Feature record | `FeatureTypes` | this document (section 3.1) and parts 2 to 7 |
| `worldgen/placement_modifier_type` | 18 | `MapCodec` of a modifier | `PlacementModifierTypes` | this document (sections 7 to 8) |
| `block_predicate_type` | 16 | `MapCodec` of a predicate | `BlockPredicateType` | 35 part 2 |
| `worldgen/block_state_provider_type` | 10 | `MapCodec` of a provider | `BlockStateProviderTypes` | 23 section 7.4 |
| `int_provider_type` | 8 | `MapCodec` | `IntProviders` | 23 section 7.1 |
| `float_provider_type` | 4 | `MapCodec` | `FloatProviders` | 23 section 7.2 |
| `height_provider_type` | 6 | `MapCodec` | `HeightProviderType` | 23 section 7.3 |
| `worldgen/trunk_placer_type` | 10 | `MapCodec` | `TrunkPlacerType` | 35 part 3 |
| `worldgen/foliage_placer_type` | 12 | `MapCodec` | `FoliagePlacerType` | 35 part 3 |
| `worldgen/root_placer_type` | 1 | `MapCodec` | `RootPlacerType` | 35 part 3 |
| `worldgen/tree_decorator_type` | 11 | `MapCodec` | `TreeDecoratorType` | 35 part 3 or 4 (the part that specifies tree decoration) |
| `worldgen/feature_size_type` | 2 | `MapCodec` | `FeatureSizeType` | 35 part 3 |

Counts of 23's data registries for the same area: `worldgen/feature` (elements 240 in the jar), `worldgen/placed_feature` (273),
`worldgen/block_state_provider` (8); they are loaded from data (23 sections 2.1 and 3), not registered by code.

### 3.1 `worldgen/feature_type` (58 entries, ids in registration order)

The class column is the class whose static `CODEC` was registered under the name (a name and its class do not always agree
word for word: `delta_feature` is `DeltaFeature`, `spring_feature` is `SpringFeature`, `freeze_top_layer` is
`SnowAndFreezeFeature`, `netherrack_replace_blobs` is `ReplaceBlobsFeature`, `replace_single_block` is `ReplaceBlockFeature`,
`overlay` is `OverlayFeature`).

| id | name | class | id | name | class |
|---|---|---|---|---|---|
| 0 | `bamboo` | `BambooFeature` | 29 | `netherrack_replace_blobs` | `ReplaceBlobsFeature` |
| 1 | `block_blob` | `BlockBlobFeature` | 30 | `no_op` | `NoOpFeature` (9.1) |
| 2 | `block_column` | `BlockColumnFeature` | 31 | `ore` | `OreFeature` (11 section 7) |
| 3 | `block_pile` | `BlockPileFeature` | 32 | `overlay` | `OverlayFeature` |
| 4 | `blue_ice` | `BlueIceFeature` | 33 | `projected_random_patchy_square` | `ProjectedRandomPatchySquare` |
| 5 | `bonus_chest` | `BonusChestFeature` | 34 | `random_boolean_selector` | `RandomBooleanSelectorFeature` (9.4) |
| 6 | `chorus_plant` | `ChorusPlantFeature` | 35 | `random_neighbor_spread` | `RandomNeighborSpreadFeature` |
| 7 | `coral_claw` | `CoralClawFeature` | 36 | `random_selector` | `RandomSelectorFeature` (9.2) |
| 8 | `coral_tree` | `CoralTreeFeature` | 37 | `replace_single_block` | `ReplaceBlockFeature` |
| 9 | `delta_feature` | `DeltaFeature` | 38 | `root_system` | `RootSystemFeature` |
| 10 | `disk` | `DiskFeature` | 39 | `scattered_ore` | `ScatteredOreFeature` |
| 11 | `end_gateway` | `EndGatewayFeature` | 40 | `sculk_patch` | `SculkPatchFeature` |
| 12 | `end_island` | `EndIslandFeature` | 41 | `sequence` | `SequenceFeature` (9.6) |
| 13 | `end_platform` | `EndPlatformFeature` | 42 | `simple_block` | `SimpleBlockFeature` |
| 14 | `end_podium` | `EndPodiumFeature` | 43 | `simple_random_selector` | `SimpleRandomSelectorFeature` (9.3) |
| 15 | `end_spike` | `EndSpikeFeature` | 44 | `single_block_pillar` | `SingleBlockPillarFeature` |
| 16 | `fallen_tree` | `FallenTreeFeature` | 45 | `speleothem` | `SpeleothemFeature` |
| 17 | `fill_layer` | `FillLayerFeature` | 46 | `speleothem_cluster` | `SpeleothemClusterFeature` |
| 18 | `fossil` | `FossilFeature` | 47 | `spike` | `SpikeFeature` |
| 19 | `freeze_top_layer` | `SnowAndFreezeFeature` | 48 | `spring_feature` | `SpringFeature` |
| 20 | `geode` | `GeodeFeature` | 49 | `stepped_column_cluster` | `SteppedColumnClusterFeature` |
| 21 | `huge_brown_mushroom` | `HugeBrownMushroomFeature` | 50 | `template` | `TemplateFeature` |
| 22 | `huge_fungus` | `HugeFungusFeature` | 51 | `tree` | `TreeFeature` |
| 23 | `huge_red_mushroom` | `HugeRedMushroomFeature` | 52 | `underwater_magma` | `UnderwaterMagmaFeature` |
| 24 | `iceberg` | `IcebergFeature` | 53 | `vegetation_patch` | `VegetationPatchFeature` |
| 25 | `lake` | `LakeFeature` | 54 | `vines` | `VinesFeature` |
| 26 | `large_dripstone` | `LargeDripstoneFeature` | 55 | `void_start_platform` | `VoidStartPlatformFeature` |
| 27 | `monster_room` | `MonsterRoomFeature` | 56 | `waterlogged_vegetation_patch` | `WaterloggedVegetationPatchFeature` |
| 28 | `multiface_growth` | `MultifaceGrowthFeature` | 57 | `weighted_random_selector` | `WeightedRandomSelectorFeature` (9.5) |

The table reads left to right, top to bottom within each column group: ids 0 to 28 on the left, 29 to 57 on the right.
Other helper classes in the `feature` package that are **not** feature types: `AbstractHugeMushroomFeature`, `AbstractOreFeature`,
`BlockReplacement`, `CuboidPlacement` (a placement modifier, section 7.14), `FeatureCountTracker`, `FeatureTypes`,
`SpeleothemUtils`, and the record `WeightedPlacedFeature` (section 9.7).

### 3.2 `worldgen/placement_modifier_type` (18 entries)

| id | name | class (package `placement` unless noted) | kind | section |
|---|---|---|---|---|
| 0 | `block_predicate_filter` | `BlockPredicateFilter` | filter | 7.4 |
| 1 | `rarity_filter` | `RarityFilter` | filter | 7.5 |
| 2 | `random_chance` | `RandomChancePlacement` | filter | 7.6 |
| 3 | `surface_relative_threshold_filter` | `SurfaceRelativeThresholdFilter` | filter | 7.7 |
| 4 | `surface_water_depth_filter` | `SurfaceWaterDepthFilter` | filter | 7.8 |
| 5 | `biome` | `BiomeFilter` | filter | 7.3 |
| 6 | `count` | `CountPlacement` | repeating | 7.1 |
| 7 | `noise_based_count` | `NoiseBasedCountPlacement` | repeating | 7.9 |
| 8 | `noise_threshold_count` | `NoiseThresholdCountPlacement` | repeating | 7.10 |
| 9 | `count_on_every_layer` | `CountOnEveryLayerPlacement` | other | 7.11 |
| 10 | `cuboid` | `feature.CuboidPlacement` | other | 7.14 |
| 11 | `environment_scan` | `EnvironmentScanPlacement` | other | 7.12 |
| 12 | `heightmap` | `HeightmapPlacement` | other | 7.13 |
| 13 | `height_range` | `HeightRangePlacement` | other | 7.15 |
| 14 | `in_square` | `InSquarePlacement` | other | 7.2 |
| 15 | `offset` | `OffsetPlacement` | other | 7.16 |
| 16 | `randomly_selected` | `RandomlySelectedPlacement` | other | 7.17 |
| 17 | `fixed_placement` | `FixedPlacement` | other | 7.18 |

Kinds (interfaces): a **filter** (`PlacementFilter`) implements `shouldPlace(context, random, pos)` and its `modify` emits the
input position unchanged when that is true and nothing otherwise; a **repeating** modifier (`RepeatingPlacement`) implements
`count(random, pos)` and its `modify` emits the input position that many times; **other** modifiers implement `modify`
directly. Every modifier receives `(context, random, pos, emit)` and calls `emit(position)` zero or more times. The
base `PlacementModifier` interface adds only `codec()`.

Usage in the jar's data (scope: the four folders feature, placed_feature, biome, block_state_provider): the `placement` lists of
the 273 placed features contain `biome` 211, `count` 201, `in_square` 198, `block_predicate_filter` 155, `heightmap` 111,
`offset` 93, `height_range` 86, `rarity_filter` 55, `surface_water_depth_filter` 26, `environment_scan` 12,
`count_on_every_layer` 8, `noise_threshold_count` 6, `noise_based_count` 4, `surface_relative_threshold_filter` 3,
`fixed_placement` 1. `random_chance` (11), `cuboid` (5) and `randomly_selected` (2) occur only inside inline placement lists
of features, as counted over every object of those folders. List lengths: 0 modifiers 6 files, 1: 53, 2: 8, 3: 9, 4: 71, 5: 34,
6: 36, 7: 47, 8: 8, 11: 1.

### 3.3 Other type registries, names in registration order

Name lists only; behaviour is in the part named. Class names are given where the registered name differs from the class name
in a way a reader could trip over (read: the class whose `CODEC` was registered).

| Registry | Names (id 0, 1, 2, ...) |
|---|---|
| `block_predicate_type` (16) | `matching_blocks`, `matching_block_tag`, `matching_fluids`, `matching_biomes`, `has_sturdy_face`, `solid`, `replaceable`, `would_survive`, `inside_world_bounds`, `any_of`, `all_of`, `not`, `true`, `unobstructed`, `height_range`, `volume_match` |
| `worldgen/block_state_provider_type` (10, from 23 section 7.4) | `copy_properties`, `dual_noise`, `noise`, `noise_threshold`, `random_block`, `randomized_int`, `rotated`, `rule_based`, `simple`, `weighted` |
| `int_provider_type` (8) | `constant`, `uniform`, `biased_to_bottom`, `very_biased_to_bottom`, `clamped`, `weighted_list`, `clamped_normal`, `trapezoid` |
| `float_provider_type` (4) | `constant`, `uniform`, `clamped_normal`, `trapezoid` |
| `height_provider_type` (6) | `constant`, `uniform`, `biased_to_bottom`, `very_biased_to_bottom`, `trapezoid`, `weighted_list` |
| `worldgen/trunk_placer_type` (10) | `straight_trunk_placer`, `forking_trunk_placer`, `giant_trunk_placer`, `mega_jungle_trunk_placer`, `dark_oak_trunk_placer`, `fancy_trunk_placer`, `bending_trunk_placer`, `upwards_branching_trunk_placer`, `cherry_trunk_placer`, `poplar_trunk_placer` |
| `worldgen/foliage_placer_type` (12) | `blob_foliage_placer`, `spruce_foliage_placer`, `pine_foliage_placer`, `acacia_foliage_placer`, `bush_foliage_placer`, `fancy_foliage_placer`, `jungle_foliage_placer` (class `MegaJungleFoliagePlacer`), `mega_pine_foliage_placer`, `dark_oak_foliage_placer`, `random_spread_foliage_placer`, `cherry_foliage_placer`, `poplar_foliage_placer` |
| `worldgen/root_placer_type` (1) | `mangrove_root_placer` |
| `worldgen/tree_decorator_type` (11) | `trunk_vine`, `leave_vine`, `pale_moss`, `creaking_heart`, `cocoa`, `shelf_mushroom`, `beehive`, `alter_ground`, `attached_to_leaves`, `place_on_ground`, `attached_to_logs` |
| `worldgen/feature_size_type` (2) | `two_layers_feature_size`, `three_layers_feature_size` |

Class names behind the block predicate names: `MatchingBlocksPredicate`, `MatchingBlockTagPredicate`, `MatchingFluidsPredicate`,
`MatchingBiomesPredicate`, `HasSturdyFacePredicate`, `SolidPredicate`, `ReplaceablePredicate`, `WouldSurvivePredicate`,
`InsideWorldBoundsPredicate`, `AnyOfPredicate`, `AllOfPredicate`, `NotPredicate`, `TrueBlockPredicate`, `UnobstructedPredicate`,
`HeightRangePredicate`, `VolumeMatchPredicate` (the combining ones share `CombiningPredicate`; `StateTestingPredicate` is a
base class and is not registered). Trunk class names are the name with `Placer` capitalised (`StraightTrunkPlacer`, ...,
`PoplarTrunkPlacer`); decorator classes are `TrunkVineDecorator`, `LeaveVineDecorator`, `PaleMossDecorator`,
`CreakingHeartDecorator`, `CocoaDecorator`, `ShelfMushroomDecorator`, `BeehiveDecorator`, `AlterGroundDecorator`,
`AttachedToLeavesDecorator`, `PlaceOnGroundDecorator`, `AttachedToLogsDecorator`.

---

## 4. The world-generation level

During chunk decoration `level` is a `WorldGenRegion` (`net.minecraft.server.level.WorldGenRegion`, a `WorldGenLevel`). The
interface adds three methods to `ServerLevelAccessor`: `getSeed()`, `ensureCanWrite(pos)` (default: true) and
`setCurrentlyGenerating(supplier)` (a debug label). The region is built for one **center chunk** and one **chunk step**; its
numbers for the features step are read in section 4.1.

### 4.1 Chunk steps, the write window and reading outside it

The generation pyramid is, in order: `empty`, `structure_starts`, `structure_references`, `biomes`, `terrain`, `features`,
`initialize_light`, `light`, `spawn`, `full` (`ChunkPyramid.GENERATION_PYRAMID`; the status names are the strings registered in
`ChunkStatus`). The step `features` is built with (all read):

| Property | Value |
|---|---|
| Requirement 1 | `structure_starts` complete in every chunk within Chebyshev distance 8 of the center |
| Requirement 2 | `terrain` complete in every chunk within distance 1 (the 3 x 3 block of chunks) |
| `blockStateWriteRadius` | 1 |
| Heightmaps maintained on a chunk once it has passed `terrain` | the four **final** ones: `OCEAN_FLOOR`, `WORLD_SURFACE`, `MOTION_BLOCKING`, `MOTION_BLOCKING_NO_LEAVES`. The chunk statuses up to `biomes` maintain the two **worldgen** ones (`OCEAN_FLOOR_WG`, `WORLD_SURFACE_WG`); `terrain` and every later status list the four final ones (`ChunkStatus.register` calls) |
| Direct dependency status by distance | distance 0 and 1: `terrain`; distances 2 to 8: `structure_starts` (accumulated through `ChunkStep.Builder.addRequirement`, which keeps the later status at the smaller radius) |

Rules of `WorldGenRegion`:

1. **Write window.** `isWithinWriteZone(chunkX, chunkZ)` is true when both `|centerX - chunkX|` and `|centerZ - chunkZ|` are at
   most `writeRadius` (the step's `blockStateWriteRadius`, **1** for features: a 3 x 3 window of chunks, written as 3 x 3 in
   the rule of 11 section 6.5). `ensureCanWrite(pos)` is false for a position outside the window: it logs an error
   (`Util.logAndPauseIfInIde`, a development hook) and returns false. When the center chunk is being upgraded from an old format
   (`isUpgrading`), `ensureCanWrite` instead returns whether `y` is inside the upgraded height accessor's build height; that
   case does not arise for generation of a new chunk.
2. **setBlock(pos, state, flags, budget).** (1) If `ensureCanWrite(pos)` is false return false. (2) Take the chunk containing
   `pos` (`getChunk(x >> 4, z >> 4)`, section 4.4) and call its `setBlockState(pos, state, flags)`; a `ProtoChunk` **ignores the
   flags** and the budget. (3) If the chunk returned an old state, notify the point-of-interest system
   (`ServerLevel.updatePOIOnBlockStateChange(pos, old, new)`). (4) Block entities: if the new state has a block entity: when
   the chunk's persisted status is of chunk type `LEVELCHUNK` (not the case during features) create the entity with the block's
   `newBlockEntity` and attach it (or remove an existing one when the block gives none); otherwise store a **stub**: a compound
   `{x, y, z, id: "DUMMY"}` in the chunk's block-entity NBT (it is turned into a real entity at chunk promotion, section 4.3).
   Else, if the old state had a block entity, remove it. (5) If bit 16 (`UPDATE_KNOWN_SHAPE`) of `flags` is clear, ask the new
   state for its post-process position (`BlockState.getPostProcessPos`, the block's `postProcess` property, 24) and, when
   non-null, mark that position for post-processing in its chunk (section 4.3). (6) Return true.
3. **Out-of-range y.** `ProtoChunk.setBlockState` returns `void_air`'s default state without writing when `y` is outside the
   build height, and `setBlock` still returns true (the write is silently discarded). `ProtoChunk.getBlockState` returns
   `void_air` and `getFluidState` returns the empty fluid for such `y`. A write of air into a section that holds only air is a
   no-op (the chunk returns the state it was given). `isOutsideBuildHeight(y)` is `y < minY` or `y > minY + height - 1`.
4. **Reading.** `getBlockState(pos)`, `getFluidState(pos)`, `getHeight(type, x, z)` and `getBlockEntity(pos)` read the chunk
   containing the position. A read outside the write window only logs a warning (`warnIfReadOutsideWriteZone`, a development
   hook) and proceeds. `getChunk(x, z, status, ...)` throws `IllegalStateException("Requested chunk unavailable during world
   generation")` when the chunk is farther than the step's dependency radius (here 8) or the requested status is later than the
   step's dependency status at that distance; `hasChunk(x, z)` is true for distances below the dependency count (9).
   Reads at distances 2 to 8 therefore succeed but see chunks that have only passed `structure_starts` (no terrain written: the
   blocks read are air; inferred, Open question 3). A feature whose footprint can extend more than 16 blocks beyond its origin
   column risks reads past the window; vanilla's features stay within the window in practice (11 section 6.5).
5. **Entities.** `addFreshEntity(entity)` adds the entity to the chunk of its block coordinates (`chunk.addEntity`) and returns
   true, without a window check.
6. **Destroying.** `destroyBlock(pos, drop, entity, budget)` returns false for air; otherwise it sets air with flags 3
   (no drop is produced during generation). `removeBlock(pos, moved)` sets air with `setBlockAndUpdate` (flags 3); unlike the live
   level it does not substitute the fluid's block.
7. **Level properties.** `getSeed()` is the level's world seed; `getSeaLevel()`, `getMinY()` (-64) and `getHeight()` (384) are the
   dimension's (10 section 5); `getBiome(pos)` is `BiomeManager.getBiome(pos)`, the fuzzy-zoomed biome of 10 section 7.7
   (the manager is built from the obfuscated seed); `getUncachedNoiseBiome` goes through the server level's uncached biome resolver;
   `getRandom()` is a separate source: the named positional factory `minecraft:worldgen_region_random` (10 section 2.5 item 5)
   evaluated `.at(16 * cx, 0, 16 * cz)` for the center chunk (`P` of 10 section 2.5; `ChunkPos.getWorldPosition` has `y = 0`). It is the random of
   `level.getRandom()`, which is **not** the random passed to `place` (section 5); which features call it is a matter of their
   own part.
8. **Flags used in this document.** The flag constants are `Block.UPDATE_*` (29 section 1): 1 neighbours, 2 clients, 4 invisible,
   8 immediate, 16 known shape, 32 suppress drops, 64 piston, 128, 256 skip block-entity side effects, 512 skip on-place;
   `UPDATE_NONE` 260, `UPDATE_ALL` 3, `UPDATE_ALL_IMMEDIATE` 11, `UPDATE_SKIP_ALL_SIDEEFFECTS` 816. In the generation level the only
   flag the level itself reads is **16** (step 2.5). Neighbour and shape updates, light and client broadcasts of 29 do not
   run on a `ProtoChunk`; features that need their effect rely on post-processing (4.3) or on later ticks.

### 4.2 Heights: `getHeight(type, x, z)`

`WorldGenRegion.getHeight(type, x, z)` returns `chunk.getHeight(type, x and 15, z and 15) + 1`, where `ChunkAccess.getHeight`
is the heightmap's stored first-free y minus one. The result is therefore the **first free y above the highest block that
satisfies the heightmap's test** (the heightmap's "first available" value), and it equals `minY` for a column with no
qualifying block. `PlacementContext.getHeight` and every height-using modifier go through this call. A heightmap that is absent
from the chunk is built on first use (`Heightmap.primeHeightmaps`: for each column scan down from the highest section's top edge;
skip blocks that are exactly `Blocks.AIR`; the first block that satisfies a heightmap's test fixes that heightmap's value to
`y + 1`; stop when all requested heightmaps are fixed).

The heightmap types and their tests (`Heightmap$Types`; the stored ordinal, the serialized name used by JSON and the usage):

| Ordinal | Name (JSON string) | Usage | Test on a block state (`Heightmap` lambdas; tags are data, 22) |
|---|---|---|---|
| 0 | `WORLD_SURFACE_WG` | worldgen | the state is not air (`isAir` false: cave air and void air count as air) |
| 1 | `WORLD_SURFACE` | client | the same test |
| 2 | `OCEAN_FLOOR_WG` | worldgen | the state is in the block tag `minecraft:blocks_motion_in_heightmap` (no fluid clause) |
| 3 | `OCEAN_FLOOR` | live world | the same test |
| 4 | `MOTION_BLOCKING` | client | in tag `blocks_motion_in_heightmap`, **or** its fluid state is non-empty |
| 5 | `MOTION_BLOCKING_NO_LEAVES` | client | in tag `blocks_motion_in_heightmap_no_leaves`, **or** its fluid state is non-empty |

The tag rows in the jar: `blocks_motion_in_heightmap` is `#minecraft:blocks_motion`, `blocks_motion_in_heightmap_no_leaves`
is `#minecraft:blocks_motion_no_leaves`, and `blocks_motion` is `#minecraft:blocks_motion_no_leaves` plus `#minecraft:leaves`.
So leaves count for `OCEAN_FLOOR` and `MOTION_BLOCKING` but not for the no-leaves map, and fluids count for `MOTION_BLOCKING*` but
not for `OCEAN_FLOOR*`. This resolves 11 Open question 5 (the predicate of `OCEAN_FLOOR_WG`). The wire ordinals match 06 section 3.1.

Update rule when a block at `(x, y, z)` changes to `state` (`Heightmap.update`, called by `ProtoChunk.setBlockState` for every
heightmap of the chunk's `heightmapsAfter` set that already exists; absent ones are primed in one pass): let `first` be the
stored first-free y of the column. (1) If `y <= first - 2` ignore. (2) If `state` passes the test: when `y >= first` set `first = y + 1`,
otherwise ignore. (3) If it fails the test and `first - 1 == y` (the top qualifying block was removed): scan down from `y - 1`
to `minY` for the first block that passes the test and set `first` to its `y + 1`, or to `minY` when none. (4) Otherwise ignore.
Consequence: the two worldgen maps are **not** updated by feature writes during `features` (their status set stops at
`biomes`); the final maps are updated by every write (inferred from `ProtoChunk.setBlockState` iterating only the persisted
status's set, Open question 4).

### 4.3 Post-processing

Positions marked in section 4.1 step 5 (and by `markAboveForPostProcessing`) are stored per section as packed offsets in the
chunk's post-processing lists (`ProtoChunk.markPosForPostProcessing` ignores positions outside the build height). When the
chunk is promoted to a live chunk (`LevelChunk.postProcessGeneration(serverLevel)`), for every stored position in section order:
(1) if the fluid state is non-empty, tick the fluid (`FluidState.tick`); (2) if the block is a `LiquidBlock`, run its scheduled
tick (`BlockState.tick`) with the level's random; otherwise compute `Block.updateFromNeighbourShapes(state, level, pos)` and, when
it differs from the current state, set it with flags **276** (= 256 + 16 + 4: skip block-entity side effects, known shape,
invisible); (3) then clear the list. After that every pending block-entity stub is realized (`getBlockEntity` for each pending
position) and the chunk's upgrade data runs. Blocks that give a post-process position in this jar (`Blocks` static
initialiser): `brown_mushroom` and `red_mushroom` (the block's own position) and `soul_sand` and `magma_block` (the position above
the block). Chunk promotion itself is 33's.

### 4.4 Which chunk object a read or write uses

`getChunk(x, z)` returns the region's cached chunk for that coordinate (a `ProtoChunk` for chunks being generated, or a full
chunk for one already generated), looked up in a static 2D cache sized by the step's dependency radius. All writes of a feature
that crosses chunk borders therefore land in the neighbours' chunk objects directly, and are visible to later decoration of the
neighbour. There is no copy and no deferral.

---

## 5. Random sources, draw conventions and per-feature seeding

### 5.1 The source a feature receives

The `random` argument of `place` during decoration is the `WorldgenRandom` of 11 section 6.1: a `WorldgenRandom` wrapping a
**Xoroshiro** source, created once per decorated chunk (`new WorldgenRandom(new XoroshiroRandomSource(uniqueSeed))`, whose initial
seed is replaced immediately), seeded per placed feature as in 11 sections 4 and 6.1:

1. `decorationSeed = setDecorationSeed(worldSeed, 16 * cx, 16 * cz)` once per chunk (the block coordinates of the chunk's
   minimum corner; `cx`, `cz` chunk coordinates). Read again here: `setSeed(worldSeed)`; `a = nextLong() OR 1`;
   `b = nextLong() OR 1`; `r = (bx * a + bz * b) XOR worldSeed` in 64-bit arithmetic; `setSeed(r)`; the result is `r`.
2. For each placed feature `F` that runs, with `index` its position in the step's ordered feature list (11 section 6.2) and
   `step` the decoration step 0 to 10: `setSeed(decorationSeed + index + 10000 * step)` (64-bit sum), then
   `placeWithBiomeCheck(F, random, origin)` with `origin = (16 * cx, minY, 16 * cz)` (`SectionPos.of(chunk, minSectionY).origin`).
3. **Structures take the same stream at the same step first:** inside each step, the structures of the step run before its
   features, and for the *n*th structure of the step (counting from 0 in the step, **including structures with no start in
   this chunk**) the source is reseeded with `decorationSeed + n + 10000 * step`. That a structure and a feature of the same
   step can therefore share a seed when `n == index` is a property of the artifact (RS20 details structures).

Because the source is reseeded for every placed feature, the pseudo-random draws of one placed feature depend only on
`(worldSeed, cx, cz, step, index)` and the world contents it reads (11 section 6.1), never on how many other features ran.

### 5.2 How the wrapped source draws (what every `nextInt` below means)

`WorldgenRandom` extends `LegacyRandomSource`, and its `next(bits)` has two branches (read in `WorldgenRandom.next`): if the wrapped
source is itself a `LegacyRandomSource` it delegates to that source's `next(bits)`; otherwise it takes the Xoroshiro branch described next.
The first branch is not used for decoration (the wrapped source there is Xoroshiro, 5.1). `nextGaussian` comes from `LegacyRandomSource` (5.3).

A Xoroshiro-wrapped `WorldgenRandom` does **not** use Xoroshiro's own derived operations (10 section 2.3). It is a
`BitRandomSource` whose `next(bits)` is `(int)(wrapped.nextLong() >>> (64 - bits))` (one native `nextLong` per call, take the top
`bits` bits, truncate to a 32-bit signed int; read in `WorldgenRandom.next`). Every operation below is built on it (read in
`BitRandomSource`, not overridden by `WorldgenRandom`), with `next` costing one native draw:

| Operation | Definition | Native draws |
|---|---|---|
| `nextInt()` | `next(32)` | 1 |
| `nextInt(bound)`, `bound > 0` (else `IllegalArgumentException "Bound must be positive"`) | if `bound` is a power of two: `(int)((bound * (long) next(31)) >> 31)` (one draw, always consumed, even for `bound = 1`). Otherwise: `bits = next(31)`; `v = bits mod bound`; if `bits - v + (bound - 1)` overflows int to a negative number, draw again; result `v` | 1 (power of two), or 1 + retries |
| `nextInt(lo, hi)` | `lo + nextInt(hi - lo)`; `hi <= lo` throws `"bound - origin is non positive"` | as `nextInt` |
| `nextIntBetweenInclusive(lo, hi)` | `lo + nextInt(hi - lo + 1)` | as `nextInt` |
| `nextLong()` | `h = next(32)`, `l = next(32)`, result `((long) h << 32) + (long) l` (the low word is **sign-extended**, so it can borrow from the high word) | 2 |
| `nextBoolean()` | `next(1) != 0` (the top bit of the native output) | 1 |
| `nextFloat()` | `(float) next(24) * 5.9604645E-8f` (single-precision multiply) | 1 |
| `nextDouble()` | `a = next(26)`, `b = next(27)`, `(double)(((long) a << 27) + (long) b) * 1.1102230246251565E-16` | 2 |
| `nextGaussian()` | Marsaglia polar method on this generator's `nextDouble` (section 5.3) | 2 per attempt |
| `triangle(center, spread)` | `center + spread * (nextDouble() - nextDouble())` | 4 |
| `fork()` / `forkPositional()` | delegated to the **wrapped** Xoroshiro: two **native** `nextLong` draws build a new, **unwrapped** `XoroshiroRandomSource` (or factory) (10 section 2.3); the fork then draws natively (Lemire `nextInt`), not as this table | 2 native |
| `setSeed(s)` | `wrapped.setSeed(s)`: 10 section 2.2 seeding (no-op while the wrapped source is not yet set, i.e. during construction) | 0 |

This supplements 11 section 4, which gives `nextInt(n)`, `nextFloat`, `nextDouble` and `nextLong` for this wrapper; the entries
`nextBoolean` (the top bit, not Xoroshiro's low bit), `nextInt()` (the top 32 bits, not the low 32), `nextGaussian`, `triangle`
and `fork` are added here. The class also counts calls to `next` in a field (`getCount`), which has no behavioural effect.

Rules of thumb that follow, used by the modifier descriptions:

- `nextInt(16)` (the chunk-offset draw of `in_square` and `count_on_every_layer`) consumes **one** native draw and returns bits
  63 down to 60 of it: `next(31)` is the native value shifted right by 33, multiplied by 16 and shifted right by 31.
- `nextInt(n)` of a size-1 list still consumes one draw (`Util.getRandom` and `HolderSet` selection call `nextInt(size)`).
- Draw order is the evaluation order of the expression: for `a - b` with two draws, `a` is drawn first (matches 23 section 7).

### 5.3 `nextGaussian` of the wrapper

`WorldgenRandom` does not override it; `LegacyRandomSource.nextGaussian` delegates to a `MarsagliaPolarGaussian` object that was
constructed over the **wrapper itself** (`this`), so it draws with the table above. State: a flag "have a spare value" and the
spare. Algorithm: (1) if the flag is set, clear it and return the spare. (2) Repeat: `v1 = 2 * nextDouble() - 1`,
`v2 = 2 * nextDouble() - 1`, `s = v1 * v1 + v2 * v2`; accept when `s < 1` and `s != 0`. (3) `m = sqrt(-2 * ln(s) / s)`; store
`v2 * m` as the spare, set the flag, return `v1 * m`. The flag is **not** cleared by `setSeed` on a `WorldgenRandom` (its
`setSeed` override only forwards to the wrapped source; the base class's reset call is not made), so a spare left by one placed
feature survives the reseed for the next (read: `WorldgenRandom.setSeed` has no call to the base). Used by the
`clamped_normal` int and float providers (23 section 7).

---

## 6. The decoration driver (what calls placed features)

Only the facts about features are listed; the step list, the sorting and the biome candidates are 11 section 6.

1. `applyBiomeDecoration(level, chunk, structureManager)` returns at once when the debug flag "void terrain" is set. It computes
   `decorationSeed` (section 5.1), the list `featuresPerStep` (11 section 6.2), and the **candidate biome set**: every biome in
   the section palettes of the 3 x 3 chunks around the center (`ChunkPos.rangeClosed(center, 1)`), intersected with the biome
   source's `possibleBiomes`.
2. A single `FeaturePlacer` is created for the chunk and reused for every placed feature (its three lists are empty between
   features).
3. For `step` from 0 to `max(11, featuresPerStep.size) - 1`: (a) when the structure manager says structures are generated, run the
   step's structures (seed rule of section 5.1 item 3); (b) when `step < featuresPerStep.size`: collect the set of feature
   indices of the step over every candidate biome's generation settings (`BiomeGenerationSettings.features()`; a biome with
   fewer step lists than `step` contributes nothing; the index is the feature's `indexMapping` in the step's sorted list),
   sort the indices ascending, and for each index: reseed (section 5.1 item 2) and call `FeaturePlacer.placeWithBiomeCheck`.
4. Any exception thrown by a feature is wrapped in a crash report titled "Feature placement" (with the feature's registry name or
   its string form) and rethrown; there is no per-feature recovery. A failure of the whole run is reported as "Biome
   decoration" with the chunk's center coordinates.
5. At the end the level's "currently generating" label is cleared and, in debug mode, the chunk counter increments (2.4).

---

## 7. Placement modifiers

Notation: `pos` is the input position, `emit(p)` passes a position to the next modifier, `r` is the `random` (section 5.2),
`ctx` the `PlacementContext` (section 8.3), `level = ctx.getLevel()`. A *draw* is the call that consumes randomness. Field
types: "IntProvider(a,b)" means the 23 section 7.1 codec bounded to `[a, b]` (a provider whose range is outside the bounds fails
to decode with the 23 messages); `H-or-I`, `BlockPredicate` and the like as in section 1. Each modifier says which of its fields are
required and the default of each optional one.

Summary of draws per modifier (an empty cell is "no draw"):

| Modifier | Draws in order |
|---|---|
| `biome`, `block_predicate_filter`, `surface_relative_threshold_filter`, `surface_water_depth_filter`, `heightmap`, `fixed_placement`, `environment_scan` | none (the block predicates they call receive only the level and the position, no random source) |
| `count` | the provider's draws (constant: none) |
| `noise_based_count`, `noise_threshold_count` | none |
| `rarity_filter`, `random_chance` | one `nextFloat` |
| `in_square` | `nextInt(16)` for x, then `nextInt(16)` for z |
| `height_range` | the height provider's draws (23 section 7.3.2) |
| `offset` | the x provider, then the y provider, then the z provider |
| `randomly_selected` | one `nextInt(n)`, then the chosen modifier's draws |
| `count_on_every_layer` | per layer: the count provider (re-sampled at **every** loop test), and per iteration `nextInt(16)` x, `nextInt(16)` z |
| `cuboid` | `y_size`, then `xz_size`, then `xz_size` |

### 7.1 `count` (repeating)

JSON `{"type": "minecraft:count", "count": IntProvider(0, 4096)}`, field required. `count(r, pos)` is one sample of the provider;
the modifier emits `pos` that many times (a count of 0 emits nothing). A bare integer is a constant provider (no draw).

### 7.2 `in_square`

JSON `{"type": "minecraft:in_square"}` (no fields; one shared instance). Draws `dx = nextInt(16)` then `dz = nextInt(16)` (that
order) and emits `(pos.x + dx, pos.y, pos.z + dz)`. Used after `count` to spread repeats over the chunk.

### 7.3 `biome` (filter)

JSON `{"type": "minecraft:biome"}`. `shouldPlace`: let `top = ctx.topFeature()` (an Optional that **must** be present: when absent
the filter throws `IllegalStateException("Tried to biome check an unregistered feature, or a feature that should not restrict
the biome")`); `biome = level.getBiome(pos)` (fuzzy zoom, section 4.1 item 7); `settings = generator.getBiomeGenerationSettings(biome)`;
pass iff `settings.hasFeature(top)`. `hasFeature` is membership of `top` in the **set of all placed features of all steps** of
that biome's generation settings (a memoized set; equality is the record's: same feature holder and same modifier list,
inferred, Open question 7). Consequences:

- The topFeature is present only when the placed feature is run through `placeWithBiomeCheck` (the decoration driver): nested
  placed features (selectors, `sequence`) and `/place feature` have no top feature, so a `biome` modifier inside one would throw. The data
  puts `biome` only in top-level placed features.
- The check is at the **position the modifier sees**, not at the origin: when it comes after `in_square` and `heightmap` the
  biome at the final `(x, y, z)` decides; in the data it also sits early in some lists (for example right after
  `count_on_every_layer`), where the position is still the layer position.
- A feature whose placed feature appears in one biome's list can still be tried while decorating a chunk where that biome is only
  present at a distance (11 section 6.2 candidate rule); the filter removes the positions in other biomes.

### 7.4 `block_predicate_filter`

JSON `{"type": "minecraft:block_predicate_filter", "predicate": BlockPredicate}`, required. Pass iff `predicate.test(level, pos)`.
Block predicates (35 part 2) evaluate relative to `pos` and may carry their own `offset`.

### 7.5 `rarity_filter`

JSON `{"type": "minecraft:rarity_filter", "chance": n}` with `n` a positive int (`ExtraCodecs.POSITIVE_INT`, required). Draws
`nextFloat()`; passes iff it is **strictly less than** `1.0f / (float) n` (single-precision division). `n = 1` always passes (the
draw is still consumed); `n = 4` passes below 0.25f; `n = 32` below 0.03125f.

### 7.6 `random_chance`

JSON `{"type": "minecraft:random_chance", "chance": f}` with `f` a float in `[0, 1]` (required). Draws `nextFloat()`; passes iff it
is strictly less than `f`. (No placed feature of the jar uses it at the top level; 11 inline placement lists do.)

### 7.7 `surface_relative_threshold_filter`

JSON `{"type": "minecraft:surface_relative_threshold_filter", "heightmap": Heightmap, "min_inclusive": int, "max_inclusive": int}`:
`heightmap` required (section 4.2 names); the two bounds optional, defaulting to the int minimum (-2147483648) and the int
maximum (2147483647). With `h = level.getHeight(heightmap, pos.x, pos.z)` (section 4.2) in 64-bit arithmetic, pass iff
`h + min <= pos.y <= h + max`. No draw. Example (computed): `glow_lichen` uses `OCEAN_FLOOR_WG` with `max_inclusive -13` and no
minimum: with `h = 70` positions pass for every `y <= 57`.

### 7.8 `surface_water_depth_filter`

JSON `{"type": "minecraft:surface_water_depth_filter", "max_water_depth": int}` (required, no range check). With
`floor = level.getHeight(OCEAN_FLOOR, x, z)` and `surface = level.getHeight(WORLD_SURFACE, x, z)` of `pos`'s column, pass iff
`surface - floor <= max_water_depth`. `max_water_depth 0` therefore means that the world surface and the ocean floor are the same height: nothing that counts for
`WORLD_SURFACE` (any non-air block) but not for `OCEAN_FLOOR` (section 4.2: for example water) lies above the floor.

### 7.9 `noise_based_count` (repeating)

JSON `{"type": "minecraft:noise_based_count", "noise_to_count_ratio": int, "noise_factor": double, "noise_offset": double}`;
the first two required, the offset optional (default 0.0). `count(r, pos)` = `(int) ceil( (n + noise_offset) * noise_to_count_ratio )`
with `n = BIOME_INFO_NOISE.get(pos.x / noise_factor, pos.z / noise_factor)` (the 2D simplex noise of seed 2345, 10 section 3.5 for the algorithm and
the melt-test paragraph of 10 section 10.8 for the seed; a **float** result widened to double before the addition; positions are converted to
double and divided by the double factor). No draw. The cast truncates; `ceil` of a value at or below -1 gives zero or a negative
count (no repeat). Worked values (computed from the formula) with ratio 160 and offset 0.3: noise 0.0 gives 48, noise 0.25
gives 88, noise -0.5 gives -32 (no repeats), and noise `0.1f` (which is 0.10000000149011612 as a double) gives 65, not 64: the
float-to-double widening matters.

### 7.10 `noise_threshold_count` (repeating)

JSON `{"type": "minecraft:noise_threshold_count", "noise_level": double, "below_noise": int, "above_noise": int}`, all required.
`count(r, pos)` = `below_noise` when `BIOME_INFO_NOISE.get(pos.x / 200.0, pos.z / 200.0) < noise_level` (float widened to double,
strict comparison, so equal or NaN goes to `above_noise`), else `above_noise`. The scale 200.0 is a constant of the class. No draw.
Data example: the plains flower placed feature has `noise_level -0.8`, `below_noise 15`, `above_noise 4`.

### 7.11 `count_on_every_layer`

JSON `{"type": "minecraft:count_on_every_layer", "count": IntProvider(0, 256)}`, required. It finds, for random columns of the
chunk, the floor positions of every cave layer. Behaviour:

1. `layer = 0`.
2. Set `found = false`. For `i = 0, 1, ...` while `i < count.sample(r)` (the provider is **sampled again at every loop test**, including the
   final failing test; for a constant provider there is no draw): draw `x = pos.x + nextInt(16)` then `z = pos.z + nextInt(16)`;
   `h = level.getHeight(MOTION_BLOCKING, x, z)`; `y = floorOfLayer(x, h, z, layer)`; if `y` is not "none" emit `(x, y, z)`
   and set `found = true`.
3. `layer = layer + 1`; if `found` repeat from step 2, otherwise stop.

`floorOfLayer(x, startY, z, target)`: let `above = state(x, startY, z)` and `n = 0`; for `yy` from `startY` down to `minY + 1`: let
`below = state(x, yy - 1, z)`; if `below` is not "empty" and `above` is "empty" and `below` is not bedrock, then if `n == target` return
`yy`, else `n = n + 1`; then `above = below`. If the loop ends return "none". "Empty" means air (`isAir`), water or lava (the block
is water or lava). A floor that is bedrock is never counted. Worked example (computed): a column with air at `y >= 90`, solid blocks
from 89 to 86, air from 85 to 80 and solid stone from 79 down to the bottom: layer 0 gives `y = 90` (the state at 90 is air, the one below is
solid), layer 1 gives 80 (the cave floor), layer 2 gives none unless another cave exists. Each layer chooses new random columns, so the
layers of one run are generally in different columns.

### 7.12 `environment_scan`

JSON `{"type": "minecraft:environment_scan", "direction_of_search": "up" or "down", "target_condition": BlockPredicate,
"allowed_search_condition": BlockPredicate (optional, default always true), "max_steps": int in [1, 32]}`. The direction codec is the
vertical-only direction codec (`Direction.VERTICAL_CODEC`; any other name fails with "Expected a vertical direction"). Behaviour
for input `pos`:

1. If `allowed.test(level, pos)` is false: emit nothing and stop.
2. For `i = 0` while `i < max_steps`: if `target.test(level, pos)` emit `pos` and stop. Move `pos` one block in the direction. If the
   new `y` is outside the build height stop with **no** emission. If `allowed.test(level, pos)` is false leave the loop; else
   `i = i + 1`.
3. After the loop (steps exhausted or a disallowed block reached) emit `pos` if `target.test(level, pos)`.

So the target is tested at the start, at every allowed position reached, and once more at the first disallowed position or after the
last step. At most `max_steps` moves are made. Worked example (cave vines: direction up, allowed = air, target = has a sturdy face
downward, `max_steps 12`): input `y = 10` with air at 10 to 14 and stone at 15: tests at 10, 11, 12, 13, 14 fail, the move to 15 reaches a block
that is not air, the loop ends and the final test at 15 succeeds: emit `y = 15` (the data's next modifier `offset (0, -1, 0)` then
gives 14, the air block under the ceiling). With `max_steps 2` and a long air column from 10: tests at 10 and 11 fail, the loop ends
at `y = 12` after two moves, the final test at 12 fails: nothing is emitted. If the input position is itself in stone (not allowed): nothing.

### 7.13 `heightmap`

JSON `{"type": "minecraft:heightmap", "heightmap": Heightmap}` (required; names of section 4.2). With `h = level.getHeight(type, pos.x,
pos.z)` (section 4.2), emit `(pos.x, h, pos.z)` iff `h > level.getMinY()` (strictly; a column with no qualifying block gives
`minY` and is dropped). `y` is the first free block above the surface for that map. No draw. Example (computed from 4.2): grass at
`y = 69` with air above and `MOTION_BLOCKING`: `h = 70`.

### 7.14 `cuboid`

JSON `{"type": "minecraft:cuboid", "xz_size": IntProvider(1, 16), "y_size": IntProvider(1, 16), "include_edges": bool (default true),
"include_interior": bool (default true)}`; the two sizes are required. Behaviour: draw `dy = y_size.sample(r)`, then `dx =
xz_size.sample(r)`, then `dz = xz_size.sample(r)` (that order). Visit `x` from 0 to `dx`, within it `y` from 0 to `dy`, within it `z`
from 0 to `dz` (all inclusive, so the box has `(dx+1)(dy+1)(dz+1)` cells, offsets are added to `pos`; emission order is
x-major, then y, then z). A cell is **extreme** on an axis when its coordinate is 0 or equals the axis size (the sampled size is at least 1
because the codec bounds the providers to `[1, 16]`). For each cell: (a) if `include_edges` is false and the cell is extreme on at
least **two** axes, skip it; (b) if `include_interior` is false and the cell is extreme on **no** axis, skip it; otherwise emit
`pos + (x, y, z)`. Worked examples (computed): `dx = dy = dz = 2` (a 3 x 3 x 3 box):
all defaults emit 27 cells; `include_interior false` emits 26 (only the centre `(1, 1, 1)` is skipped); `include_edges false` emits 7 (the
8 corners and the 12 edge cells are skipped; the 6 face centres and the centre remain). With `dx = dy = dz = 1` every cell is a
corner, so `include_edges false` emits nothing.

### 7.15 `height_range`

JSON `{"type": "minecraft:height_range", "height": HeightProvider}` (required; 23 section 7.3.2, including the "shorthand" form of
a bare vertical anchor object). Emits `pos` with `y = height.sample(r, ctx)` (the context resolves `above_bottom`, `below_top` and
`relative_to_sea_level` anchors, section 8.3). The x and z are unchanged. Draws exactly those of the provider.

### 7.16 `offset`

JSON `{"type": "minecraft:offset", "x": IntProvider(-16, 16), "y": IntProvider(-16, 16), "z": IntProvider(-16, 16)}`, all three
required (in this version an `offset` without all three fields does not decode). Samples `x`, then `y`, then `z` (that order) and
emits `pos` translated by the three values. Worked example (computed, wrapped generator seeded with 1000, no draws before): the
plains flower modifier of the data uses trapezoid providers `x: -6..6`, `y: -2..2`, `z: -6..6` (plateau 0): each is `nextInt(m + 1)
- nextInt(m + 1)` (23 section 7.1 case `plateau == 0 and max == -min`, with `m` 6, 2, 6): the draws give offsets `(-1, 2, -4)`.

### 7.17 `randomly_selected`

JSON `{"type": "minecraft:randomly_selected", "placements": [modifier, ...]}` with a non-empty list (required). Draws `nextInt(n)` for
the list size `n` (`Util.getRandom`, one draw even for `n = 1`) and runs the chosen modifier's `modify` with the same input and the same
`emit` (so it may emit several positions or none, and its own draws follow immediately). The list is a set of alternatives for one slot of the
outer modifier list; the modifiers after the `randomly_selected` entry in the outer list then run on whatever was emitted.

### 7.18 `fixed_placement`

JSON `{"type": "minecraft:fixed_placement", "positions": [[x, y, z], ...]}`, required (each position is a 3-int array: the
`BlockPos` codec, a fixed-size int stream). The input position fixes a chunk (`pos.x >> 4`, `pos.z >> 4`); the modifier emits, in list
order, every listed absolute position that lies in **that same chunk**. In decoration the input is the chunk's origin, so
a listed position is emitted only while its own chunk is being decorated. Data example: `end_platform` has the single position
`[100, 49, 0]`, in chunk `(6, 0)`. No draw.

### 7.19 `RepeatingPlacement` base and the shared interface

`RepeatingPlacement.modify(ctx, r, pos, emit)`: `n = count(r, pos)` (draws, if any, happen once, before any emission) and then `n`
calls of `emit(pos)`. The three repeating types are `count`, `noise_based_count`, `noise_threshold_count`. `PlacementFilter.modify`:
if `shouldPlace` then `emit(pos)`. The unit modifiers `biome` and `in_square` have a single shared instance and codec of no fields.

### 7.20 `CaveSurface` (an enum used by features, not a modifier)

`CaveSurface` is an enum with two values used as a config field by features that grow on a cave floor or ceiling; it is defined here
because it lives in the `placement` package: `CEILING` (direction `up`, y step `+1`, serialized name `ceiling`) and `FLOOR` (direction `down`,
y step `-1`, name `floor`). Its codec is the enum's serialized name (`StringRepresentable`). The fields `direction` and `y` of each value
are used by the features that scan toward that surface (35 parts 4 to 6).

---

## 8. `PlacedFeature.place`, `FeaturePlacer` and `PlacementContext`

### 8.1 Entry points

`PlacedFeature.place(level, generator, random, pos)` creates a new `FeaturePlacer(level, generator)` and calls its `place(this, random, pos)`
(without a biome check). `FeaturePlacer.placeWithBiomeCheck(feature, random, pos)` is the same with the feature recorded as the
context's top feature (used by the decoration driver only). Both return the boolean result of section 2.1. Nested placed features always
use the first form on a fresh placer, so they carry **no** top feature.

### 8.2 The evaluation (numbered behaviour)

Inputs: `F` (feature, `modifiers` list of length `M`), `random`, `pos`, `context = PlacementContext(level, generator, topFeature)`.

1. If `M == 0`: place the feature at `pos` once and return its result (the debug counter, if enabled, is notified before).
2. Otherwise `result = false`; the evaluator has a **stack** of (position, modifier index) pairs, holding `(pos, 0)`, and an
   emission buffer `modified`.
3. While the stack is not empty: pop the **last-pushed** pair `(p, m)`. Call `modifiers[m].modify(context, random, p, emit)` where
   `emit` appends to `modified`.
4. If `m + 1 < M`: push every position of `modified` with index `m + 1`, iterating `modified` **from its last element to its first**, so
   that the first emitted position is on top of the stack and is processed first.
5. If `m + 1 == M` (the last modifier): for each position of `modified`, **in emission order**, call `F.place(level, generator,
   random, position)` and OR the result into `result`.
6. After step 4 or step 5 clear `modified` (it is empty at the start of every `modify` call), and go back to step 3. When the stack is empty
   return `result`.

Observable order (equal to depth-first recursion): all draws of the first modifier; then the whole subtree of its first emitted
position (every later modifier's draws, then the feature's draws) before the second emitted position starts. One difference
from a recursive description: all emissions of one `modify` call are collected before any downstream work, so a modifier that
draws and emits several positions (for example `cuboid`, or a count of 3) finishes **all its own draws first**; and when the
**last** modifier emits several positions, the feature is placed for them only after the modifier has finished. Because a
modifier never inspects the world after emitting, this is indistinguishable from recursion except for the position of the
last modifier's own draws.

Trace (computed): modifiers `[count 3, in_square, height_range uniform 0..64, biome]`, feature draws nothing. The stack holds
`(o, 0)`. Pop: `count` emits `o` three times; push three entries with index 1. Pop the first: `in_square` draws `dx`, `dz`, emits
`p1`; push `(p1, 2)`; pop it: `height_range` draws `y1`, emits `p1'`; push `(p1', 3)`; pop it: `biome` (last) emits `p1'` or nothing;
`F.place` runs for it; the buffer clears. The next entry of index 1 then starts: `dx`, `dz`, `y2`. The draw sequence is
`dx1 dz1 y1 [F1] dx2 dz2 y2 [F2] dx3 dz3 y3 [F3]`.

### 8.3 `PlacementContext`

`PlacementContext extends WorldGenerationContext` and holds `level`, `generator` and `topFeature` (an Optional placed feature).

| Member | Value |
|---|---|
| `getHeight(type, x, z)` | `level.getHeight(type, x, z)` (section 4.2) |
| `getBlockState(pos)` | `level.getBlockState(pos)` |
| `getMinY()` | `level.getMinY()` |
| `getLevel()`, `generator()`, `topFeature()` | the fields |
| inherited minimum generation y | `max(level.minY, generator.minY)`; overworld -64 |
| inherited generation depth | `min(level.height, generator.genDepth)`; overworld 384 |
| inherited sea level | `generator.getSeaLevel()`; overworld 63 |

The inherited numbers resolve `VerticalAnchor`s (23 section 7.3.1: `above_bottom n` is `minY + n`, `below_top n` is `minY + depth - 1 - n`, `relative_to_sea_level n`
is `seaLevel + n`) for the `height_range` modifier and for height providers elsewhere. For the noise generator the three come from the
`noise_settings` of the dimension (10 section 5).

---

## 9. Generic and combinator features

All six feature types take placed features (`PlacedFeature.CODEC` Id-or-inline unless noted) and forward `(level, generator, random, pos)` to
`PlacedFeature.place` on the **same** random and position, so each nested placed feature runs its own modifier list from `pos`.

### 9.1 `no_op`

JSON `{"type": "minecraft:no_op"}` (no fields). `place` returns **true** and does nothing, with no draw.

### 9.2 `random_selector`

JSON `{"type": "minecraft:random_selector", "features": [WeightedPlacedFeature, ...], "default": PlacedFeature}`, both required (the list may be
empty). Walk `features` in list order: draw `nextFloat()`; if it is **strictly less** than the entry's `chance`, place that entry's placed feature
and return its result (no later entry is drawn for); otherwise continue. If no entry was chosen place `default` and return its result. Each
entry costs one draw, so a list of `k` entries consumes between 1 and `k` draws before the chosen placed feature's own draws. The probability of
entry `j` is `chance_j` times the product of `(1 - chance_i)` over earlier entries (chances are floats; the comparison is in single
precision). Data example (`trees_plains`): entries chance 0.33333334 (fancy oak with bees), then 0.0125 (fallen oak), default the plain oak with
bees: P(fancy) about 0.3333, P(fallen) about 0.6667 x 0.0125 = 0.00833, P(default) about 0.658. Computed draws for a generator seeded with
1000: the first three `nextFloat` are 0.61734074, 0.64006275, 0.74027783, so the first call falls through both entries to the default and
consumes two draws.

### 9.3 `simple_random_selector`

JSON `{"type": "minecraft:simple_random_selector", "features": HolderSet(PlacedFeature)}` (a single element, a `#tag` or a list; **non-empty**:
`ExtraCodecs.nonEmptyHolderSet`). Draw `i = nextInt(size)` over the set's size (the list order of a direct set, the tag order of 23 section 6.4 for a tag; one
draw even when the size is 1) and place element `i`; return its result.

### 9.4 `random_boolean_selector`

JSON `{"type": "minecraft:random_boolean_selector", "feature_true": PlacedFeature, "feature_false": PlacedFeature}`, both required. Draw
`nextBoolean()` (the top bit of one native draw, section 5.2) and place `feature_true` when it is true, `feature_false` otherwise; return its result.
Computed: a generator seeded with 1000 gives the booleans true, true, true, false, true, false for its first six calls.

### 9.5 `weighted_random_selector`

JSON `{"type": "minecraft:weighted_random_selector", "features": WeightedList(PlacedFeature)}` (23 section 7.5: a list of `{"data": placed feature, "weight":
non-negative int}`, using the plain codec, so an empty list **decodes**). `WeightedList.getRandom(random)`: an empty list (total weight 0) returns
nothing and draws nothing, and the feature returns **false**; otherwise one draw `nextInt(totalWeight)` and the selector of 23 section 7.5 picks
the entry (flat table below total weight 64, running subtraction from 64 up); place it and return its result. Data example (`seagrass_mid`): weights 60 and 40
(total 100, so the compact selector): the draw `nextInt(100)` below 60 selects the first entry (a `tall_seagrass` lower half, with its own
filter), otherwise the second. Computed for seed 1000: the first two draws of `nextInt(100)` are 67 and 34.

### 9.6 `sequence`

JSON `{"type": "minecraft:sequence", "features": HolderSet(PlacedFeature)}` (non-empty). Creates one `FeaturePlacer` and, for each element in set order, places
it at `pos`; **stops with false at the first element that returns false**, and returns true after the last element. Elements run on the same random
in sequence, so the draws of element 2 follow those of element 1. Elements that returned true before a later failure have already written their
blocks. Data example (`sculk_patch_deep_dark`): element 1 is the sculk patch (empty modifier list, so its own result decides);
element 2 is a catalyst block behind `random_chance 0.5` and a sturdy-face filter, so it returns false half the time (the first draw of the
list fails the chance) and the sequence returns false, which no consumer in decoration reads.

### 9.7 `WeightedPlacedFeature`

A record, not a feature: `{"feature": PlacedFeature (Id-or-inline), "chance": float in [0, 1]}`, both required (`Codec.floatRange(0, 1)`), with
`place` forwarding to the placed feature. It is the element type of `random_selector.features`.

---

## 10. Numeric providers as the placement code draws them

The provider specifications are 23 section 7 and are not repeated. What this document adds is where each is bounded and what "draw" means for the
wrapped source:

| Used by | Provider | Bounds enforced at decode |
|---|---|---|
| `count` | `IntProvider` | `[0, 4096]` |
| `count_on_every_layer` | `IntProvider` | `[0, 256]` |
| `offset` (x, y, z) | `IntProvider` each | `[-16, 16]` |
| `cuboid` (`xz_size`, `y_size`) | `IntProvider` each | `[1, 16]` |
| `height_range` | `HeightProvider` | none beyond the anchor range of 23 section 7.3.1 |
| `weighted_random_selector` | `WeightedList` of placed features | total weight at most 2147483647 (23 section 7.5) |

Every `r.nextInt(n)` of 23 section 7 is the wrapped `nextInt(n)` of section 5.2 in decoration. 11 section 4 already restates the uniform, trapezoid and
very-biased forms for ores; they agree with 23 (for example a height `trapezoid` of 11 with `plateau 0` is `lo + nextInt(slope + 1) +
nextInt(slopeWidth + 1)`, two draws). The `clamped_normal` providers call `nextGaussian` (section 5.3). `WeightedList` selection draws one
`nextInt(totalWeight)` (read in `WeightedList.getRandom`) and none for an empty list.

---

## 11. Worked examples (computed from the rules above)

All values in this section come from a scratch implementation of sections 5.1 and 5.2 (checked against the Xoroshiro test vectors of 10
section 2.7: seed 0 first `nextLong` 3038984756725240190); they are not read from the artifact. They are test vectors for implementers, not artifact values: the artifact check covers only the
rules they rest on (the `decorationSeed` formula, the `next` shifts, the power-of-two `nextInt` path and the `nextBoolean` top bit), and the
seed-1000 draws in 7.16 and 11.3 and the positions in 11.2 could not be re-derived without that scratch implementation.

### 11.1 Decoration seeds

| World seed | Chunk | `decorationSeed` |
|---|---|---|
| 0 | (0, 0) | 0 (both products are 0, so `r = 0 XOR 0`) |
| 12345 | (3, -2) | -5778620028567011383 |
| 0 | (-1, 5) | 8481739403297134432 |

Feature seeds: chunk (0, 0), world seed 0, step 9, index 3: `90003`; step 6, index 11: `60011` (the 11 section 10.4 relation).

### 11.2 Positions for `[count 3, in_square, height_range uniform absolute 0..64, biome]`

The feature draws nothing (a generator seeded for the feature, then draws `nextInt(16)`, `nextInt(16)`, `nextInt(65)` per repeat, section 8.2):

| World seed, chunk | Step, index | Seed given to the feature | Positions `(x, y, z)` in draw order |
|---|---|---|---|
| 0, (0, 0) | 9, 3 | 90003 | (15, 43, 11), (15, 54, 10), (11, 40, 14) |
| 0, (0, 0) | 6, 11 | 60011 | (10, 60, 15), (15, 34, 11), (4, 6, 1) |
| 12345, (3, -2) | 9, 3 | -5778620028566921380 | (48, 39, -25), (61, 17, -24), (61, 46, -19) |
| 0, (-1, 5) | 9, 3 | 8481739403297224435 | (-11, 26, 90), (-16, 34, 93), (-1, 50, 87) |

The block coordinates are the chunk's origin (`16 * cx`, `16 * cz`) plus the offsets, so the chunk (3, -2) yields x in 48 to 63 and z in -32
to -17.

### 11.3 Single draws (generator seeded with 1000 via `setSeed`)

| Operation | Result |
|---|---|
| first three `nextFloat()` | 0.61734074, 0.64006275, 0.74027783 (so a `rarity_filter 4`, threshold 0.25, rejects the first position) |
| first six `nextBoolean()` | true, true, true, false, true, false |
| first six `nextInt(16)` | 9, 10, 11, 7, 11, 5 |
| first six `nextInt(3)` | 1, 0, 2, 0, 1, 1 |
| first three `nextInt()` | -1643508961, -1545918627, -1115498129 |
| `nextLong()` first call (two draws) | -7058817239723858083 (the native Xoroshiro `nextLong` for the same seed would be -7058817236172336398: the two differ) |
| `nextInt(100)` twice | 67, 34 |
| first `nextGaussian()` | 0.6943196185721859 (the spare 1.4217534803646787 is returned by the next call) |

---

## 12. Validation: checkable facts

1. The registry sizes are 58 (feature types), 18 (placement modifiers), 16 (block predicates), 10 (state providers), 8 (int providers), 4 (float
   providers), 6 (height providers), 10 (trunk placers), 12 (foliage placers), 1 (root placer), 11 (tree decorators), 2 (feature sizes); the first
   and last feature types are `bamboo` (0) and `weighted_random_selector` (57); the first and last modifier types are `block_predicate_filter` (0)
   and `fixed_placement` (17); `jungle_foliage_placer` is the megajungle class.
2. There is no `configured_feature` registry or class; a placed feature is `{feature, placement}`; features are flat records dispatched on `type`.
3. The features step: neighbours `terrain` at distance 1, `structure_starts` at distance 8, write radius 1; dependency count 9.
4. `WorldGenRegion.getHeight` is the stored first-free y (`+1` of the chunk's `getHeight`); an empty column gives `minY`.
5. Heightmap ordinals 0 to 5 are `WORLD_SURFACE_WG`, `WORLD_SURFACE`, `OCEAN_FLOOR_WG`, `OCEAN_FLOOR`, `MOTION_BLOCKING`, `MOTION_BLOCKING_NO_LEAVES`.
6. Seeding: `setSeed(decorationSeed + index + 10000 * step)` per placed feature; `decorationSeed` from `a = nextLong() OR 1`, `b = nextLong() OR 1`,
   `(bx * a + bz * b) XOR seed`; `nextLong()` of the wrapper is two `next(32)` draws with a sign-extended low word.
7. `nextBoolean` is `next(1) != 0` (the top bit); `nextInt(power of two)` consumes exactly one draw.
8. `rarity_filter n` passes iff `nextFloat() < 1.0f / n`; `random_chance f` iff `nextFloat() < f`; `in_square` draws x then z.
9. `count_on_every_layer` re-samples its count provider at every loop test; `floorOfLayer` excludes a floor whose lower neighbour is bedrock.
10. `environment_scan` makes at most `max_steps` moves, tests the target at the first disallowed position, and emits nothing when the scan leaves the world.
11. `cuboid` draws `y_size`, then `xz_size` twice, and iterates x, y, z inclusive; a 3 x 3 x 3 box with `include_edges false` keeps 7 cells.
12. `random_selector` draws one float per entry until one succeeds; `simple_random_selector` draws one `nextInt(size)` even for size 1; `sequence` stops at the first false.
13. `FeaturePlacer` returns the OR of the results; with an empty list it returns the feature's own result; all emissions of a `modify` call precede downstream work.
14. `biome` throws without a top feature; the data puts it only in top-level placed features.
15. Data counts: 240 feature files, 273 placed feature files; 11 feature types without a top-level file; placement type usage as in section 3.2.

---

## Open questions

1. **Division of the 58 feature types.** This document specifies six (`no_op`, the four selectors, `sequence`) and refers `ore` to 11 section 7. The other 51 are
   named in section 3.1 and belong to the sibling parts; which part claims each name is for those parts to state. A name no part claims is a gap.
2. **Features run outside decoration.** `/place feature` and (in vanilla's other callers, not traced here) bone meal call `place` with the live level's random and a
   `ServerLevel`; the random there is a different generator class (`ServerLevel.getRandom`), whose draw definitions were not read in this round, and the live level applies the
   flags of 29. Behaviour differs from decoration only through these two things (inferred).
3. **Reads beyond the write window.** That reads at distances 2 to 8 return unfinished chunks (air) was inferred from the dependency table (only `structure_starts` is
   guaranteed there); the chunks' actual content at that moment was not traced.
4. **Worldgen heightmaps during `features`.** That `OCEAN_FLOOR_WG` and `WORLD_SURFACE_WG` stay frozen after terrain is inferred from the `heightmapsAfter` sets of `terrain`
   and later statuses and from `ProtoChunk.setBlockState`; who last writes them was not traced (10 section 8 and 10 Open question 6 are the owners).
5. **Which features call `level.getRandom()` or `random.fork()`.** Both change the draw definitions (section 4.1 item 7, section 5.2). They are recorded by the part that specifies
   each feature.
6. **Floating-point functions in `nextGaussian`.** The polar method calls `Math.log` and `Math.sqrt`; whether the intrinsic and the strict forms can differ in the last bit
   was not examined. It affects only the `clamped_normal` providers.
7. **`PlacedFeature` equality in `biome`.** That `hasFeature` compares by record equality (feature holder and modifier list) rather than by identity was inferred from the set
   being of `PlacedFeature` values. Two differently named placed features with identical content would then be indistinguishable in the check.
8. **The 2D simplex noise.** `BIOME_INFO_NOISE` is the seed-2345 simplex noise of 10 section 3.5 and 10 section 10.8; this round did not re-read its permutation construction and gives no
   numeric noise example. The worked values of 7.9 use assumed noise values.
9. **16 versus this jar.** 16 section 7.5 names the argument of `/place feature` a "configured_feature"; in this jar the argument is a holder of a `Feature` of the registry
   `worldgen/feature` and the command places it without modifiers. 16 should be corrected by its owner.
10. **`DEBUG_FEATURE_COUNT`.** The flag is initialised with `debugFlag("FEATURE_COUNT")`; the source of that flag (system property or environment) was not traced.
11. **Other post-processing marks.** Section 4.3 lists the blocks that mark themselves and `markAboveForPostProcessing`; whether other call sites in the jar (carvers, aquifer
    fluids, structure pieces) mark positions was not scanned jar-wide. Chunk promotion order is 33's.
12. **Biome step lists longer than 11.** The decoration loop runs to `max(11, featuresPerStep.size)`; no data has a longer list, and the case was not exercised.
13. **`ceil` and float widening.** The noise counts (7.9) depend on float-to-double widening and `Math.ceil`; the examples are computed, and no test in the artifact was read.
14. **Feature index table.** As in 11 Open question 2, the absolute `featureIndex` values are not tabulated (they follow from the sort of 11 section 6.2 over the biome order of 10 section 7.4).
