# 36 Structures, part 1: shared model, placement, starts, pieces base, terrain adaptation

| Item | Value |
|---|---|
| Covers | The model every structure shares: registries and id assignment (structure types, structure placement types, structure piece types), the element schemas of `worldgen/structure` and `worldgen/structure_set` (settings, spawn overrides, placements), the placement engines (`random_spread`, `concentric_rings`, `dimension_origin`, frequency reduction, exclusion zones, locate offset), structure start creation (generation context, biome check, weighted choice inside a set, stubs and pieces builder), the `StructureStart` record and its NBT, chunk references and the chunk-status handling, `StructureCheck`, the `StructurePiece` base class (coordinate frames, block helpers, box helpers, serialization), `BoundingBox`, `StructurePiecesBuilder`, `PiecesContainer`, the single-piece base (`SinglePieceStructure`, `ScatteredFeaturePiece`), terrain adaptation and the beardifier, structure spawn overrides and the queries that use them, structure tags, and the locate search. |
| Does not cover | Rows of data (the extraction tool copies the `worldgen/structure`, `worldgen/structure_set`, `worldgen/template_pool`, `worldgen/processor_list` elements and the structure NBT files, see 22 and 23 section 2.1): this document gives the schema, the semantics and the engines, never a row. The template system and `TemplateStructurePiece` (36-2), jigsaw assembly and `PoolElementStructurePiece` (36-3), and the per-structure generators and points of interest (36-4 to 36-10). `NoiseSpawnFinder` (the dimension origin of the noise generator). The feature decoration engine (35). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.structure.*` (`Structure`, `StructureStart`, `StructureCheck`, `StructureCheckResult`, `StructureSet`, `StructureType`, `TerrainAdjustment`, `StructureSpawnOverride`, `StructurePiece`, `BoundingBox`, `SinglePieceStructure`, `ScatteredFeaturePiece`, `BuiltinStructures`, `BuiltinStructureSets`, `pieces.*`, `placement.*`), `net.minecraft.world.level.levelgen.Beardifier`, `WorldgenRandom`, `net.minecraft.world.level.chunk.ChunkGenerator`, `ChunkGeneratorStructureState`, `ChunkAccess`, `storage.SerializableChunkData`, `status.ChunkStatusTasks`, `net.minecraft.world.level.StructureManager`, `net.minecraft.world.level.biome.BiomeSource`, `net.minecraft.tags.StructureTags`, `Direction`, `Mth`. No execution. Worked examples in section 12 were computed by hand-written arithmetic from the rules (not by running the artifact). |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engines (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12b, GAP-18, R4, R7, R10). |
| Status | Written by the reader for round RS20, part 1. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. No fact here is taken from recall: where the artifact
differs from what an earlier version of the game did, only the artifact's behaviour is written. References use "10 section 2" for
other documents, "35-1 section 5" likewise, and "36-N section M" for sibling parts of this document (36-1 is this file). Block
coordinates are absolute unless a section says "piece-local". Random-source arithmetic (the Java linear congruential generator and
the `WorldgenRandom` wrapper) is defined in 10 section 2.6, 11 section 4 and 35-1 section 5.2 and is not repeated; the helpers used
here that those documents do not define are in section 4.3.

---

## 1. What a structure is in this version, and what is data

A **structure** is a registry element of `worldgen/structure`: a polymorphic record dispatched on a `type` field over the static
registry `worldgen/structure_type` (section 2.2), carrying the common settings of section 3.1 plus type-specific fields (the
type-specific fields are 36-3 for `jigsaw` and 36-4 to 36-10 for the rest). A **structure set** is an element of
`worldgen/structure_set`: a list of weighted structures that share one **placement** (section 3.3), which decides *which chunks*
may hold a start of the set. A **structure start** (`StructureStart`) is the generated result for one chunk and one structure: an
ordered list of **pieces** (`StructurePiece`) plus a reference counter. Starts live in chunk data (section 7.3); pieces are
placed block by block during the `features` decoration pass of every chunk their bounding box touches (section 8).

| Item | Supplied by | Where specified |
|---|---|---|
| Structure elements (biomes, step, adaptation, spawn overrides, type fields) | data pack (tool copies) | schema: section 3 |
| Structure set elements (structure list, weights, placement values: spacing, separation, salt, rings, ...) | data pack (tool copies) | schema: section 3 |
| Structure NBT templates (`.nbt` files), template pools, processor lists | data pack (tool copies) | schema and engine: 36-2, 36-3 |
| Structure tags (`worldgen`-side tags of `worldgen/structure`) | data pack (tool copies) | names: section 2.6; resolution: 04 and 23 |
| The 16 structure types, the 3 placement types, the 56 piece types and their ids | code | section 2 |
| Placement engines, start creation, chunk references, `StructureCheck`, locate search | code | sections 4 to 11 |
| Piece base class, geometry, block helpers, serialization | code | section 6 |
| Terrain adaptation and the beardifier | code | section 9 |

Rule for implementers: never tabulate, hard-code or compare against a data row. A structure id, a set id, a salt, a spacing or a
weight is read from the loaded registry elements at run time. The code-defined integers in this document (ids of types, enum
values, constants of formulas) are the only numbers an implementation embeds.

---

## 2. Registries and id assignment

### 2.1 The registries this document touches

| Registry key | Kind | Content | Wire |
|---|---|---|---|
| `worldgen/structure` | data (dynamic) | structure elements | no (23 section 2.1 row 6) |
| `worldgen/structure_set` | data (dynamic) | structure set elements | no (23 section 2.1 row 7) |
| `worldgen/structure_type` | code (static) | 16 entries, section 2.2 | no |
| `worldgen/structure_placement` | code (static) | 3 entries, section 2.3 | no |
| `worldgen/structure_piece` | code (static) | 56 entries, section 2.4 | no |
| `worldgen/structure_pool_element`, `worldgen/structure_processor`, `worldgen/template_pool`, `worldgen/processor_list` | static / data | siblings 36-2, 36-3 | no |

The three static registries are filled in code in the order shown; an id is the registration index (inferred: `Registry.register
is called in this order, and ids of a simple registry are sequential; this is the same assumption 35 section 3 makes for features).
None of them is sent to a client in the registry-sync packets (04 section 6; 23 lists them as static registries), so ids matter only
for internal tables and for a test that wants to compare registration order.

### 2.2 `worldgen/structure_type` (16 entries, ids in registration order)

Each entry pairs a registry name with the codec of one `Structure` subclass. Names are `minecraft:<name>`.

| Id | Name | Class | Part |
|---|---|---|---|
| 0 | `buried_treasure` | `BuriedTreasureStructure` | 36-4 to 36-10 |
| 1 | `desert_pyramid` | `DesertPyramidStructure` | same |
| 2 | `end_city` | `EndCityStructure` | same |
| 3 | `fortress` | `NetherFortressStructure` | same |
| 4 | `igloo` | `IglooStructure` | same |
| 5 | `jigsaw` | `JigsawStructure` | 36-3 |
| 6 | `jungle_temple` | `JungleTempleStructure` | 36-4 to 36-10 |
| 7 | `mineshaft` | `MineshaftStructure` | same |
| 8 | `nether_fossil` | `NetherFossilStructure` | same |
| 9 | `ocean_monument` | `OceanMonumentStructure` | same |
| 10 | `ocean_ruin` | `OceanRuinStructure` | same |
| 11 | `ruined_portal` | `RuinedPortalStructure` | same |
| 12 | `shipwreck` | `ShipwreckStructure` | same |
| 13 | `stronghold` | `StrongholdStructure` | same |
| 14 | `swamp_hut` | `SwampHutStructure` | same |
| 15 | `woodland_mansion` | `WoodlandMansionStructure` | same |

(`StructureType` static initializer, one `register(name, codec)` per row.) The `type` field of a structure element names one of
these; the rest of the element is decoded by that type's codec, which always starts with the common settings of section 3.1 flattened
into the same object (the settings are not nested).

### 2.3 `worldgen/structure_placement` (3 entries)

| Id | Name | Class | Section |
|---|---|---|---|
| 0 | `concentric_rings` | `ConcentricRingsStructurePlacement` | 4.6 |
| 1 | `dimension_origin` | `DimensionOriginStructurePlacement` | 4.7 |
| 2 | `random_spread` | `RandomSpreadStructurePlacement` | 4.3 |

(`StructurePlacements.bootstrap`, registration order.) A structure set's `placement` object is dispatched on its `type` field over
this registry.

### 2.4 `worldgen/structure_piece` (56 entries, ids in registration order)

The registry **key** of each piece type is the lower-case form (`Locale.ROOT`) of a short code in the table; the stored NBT `id` of
a piece is the full namespaced key, for example `minecraft:mscorridor` (section 6.7). The loader lower-cases the stored text before
looking it up and applies the renames of section 6.7. "Load form" says what the piece's loader receives: **C** the piece NBT only
(`ContextlessType`), **T** the structure template manager plus the NBT (`StructureTemplateType`), **F** the full serialization context
plus the NBT (a type that registered itself directly).

| Id | Key (code as read, lower-cased on registration) | Load | Field |
|---|---|---|---|
| 0 | `mscorridor` (`MSCorridor`) | C | `MINE_SHAFT_CORRIDOR` |
| 1 | `mscrossing` (`MSCrossing`) | C | `MINE_SHAFT_CROSSING` |
| 2 | `msroom` (`MSRoom`) | C | `MINE_SHAFT_ROOM` |
| 3 | `msstairs` (`MSStairs`) | C | `MINE_SHAFT_STAIRS` |
| 4 | `nebcr` (`NeBCr`) | C | `NETHER_FORTRESS_BRIDGE_CROSSING` |
| 5 | `nebef` (`NeBEF`) | C | `NETHER_FORTRESS_BRIDGE_END_FILLER` |
| 6 | `nebs` (`NeBS`) | C | `NETHER_FORTRESS_BRIDGE_STRAIGHT` |
| 7 | `neccs` (`NeCCS`) | C | `NETHER_FORTRESS_CASTLE_CORRIDOR_STAIRS` |
| 8 | `nectb` (`NeCTB`) | C | `NETHER_FORTRESS_CASTLE_CORRIDOR_T_BALCONY` |
| 9 | `nece` (`NeCE`) | C | `NETHER_FORTRESS_CASTLE_ENTRANCE` |
| 10 | `nescsc` (`NeSCSC`) | C | `NETHER_FORTRESS_CASTLE_SMALL_CORRIDOR_CROSSING` |
| 11 | `nesclt` (`NeSCLT`) | C | `NETHER_FORTRESS_CASTLE_SMALL_CORRIDOR_LEFT_TURN` |
| 12 | `nesc` (`NeSC`) | C | `NETHER_FORTRESS_CASTLE_SMALL_CORRIDOR` |
| 13 | `nescrt` (`NeSCRT`) | C | `NETHER_FORTRESS_CASTLE_SMALL_CORRIDOR_RIGHT_TURN` |
| 14 | `necsr` (`NeCSR`) | C | `NETHER_FORTRESS_CASTLE_STALK_ROOM` |
| 15 | `nemt` (`NeMT`) | C | `NETHER_FORTRESS_MONSTER_THRONE` |
| 16 | `nerc` (`NeRC`) | C | `NETHER_FORTRESS_ROOM_CROSSING` |
| 17 | `nesr` (`NeSR`) | C | `NETHER_FORTRESS_STAIRS_ROOM` |
| 18 | `nestart` (`NeStart`) | C | `NETHER_FORTRESS_START` |
| 19 | `shcc` (`SHCC`) | C | `STRONGHOLD_CHEST_CORRIDOR` |
| 20 | `shfc` (`SHFC`) | C | `STRONGHOLD_FILLER_CORRIDOR` |
| 21 | `sh5c` (`SH5C`) | C | `STRONGHOLD_FIVE_CROSSING` |
| 22 | `shlt` (`SHLT`) | C | `STRONGHOLD_LEFT_TURN` |
| 23 | `shli` (`SHLi`) | C | `STRONGHOLD_LIBRARY` |
| 24 | `shpr` (`SHPR`) | C | `STRONGHOLD_PORTAL_ROOM` |
| 25 | `shph` (`SHPH`) | C | `STRONGHOLD_PRISON_HALL` |
| 26 | `shrt` (`SHRT`) | C | `STRONGHOLD_RIGHT_TURN` |
| 27 | `shrc` (`SHRC`) | C | `STRONGHOLD_ROOM_CROSSING` |
| 28 | `shsd` (`SHSD`) | C | `STRONGHOLD_STAIRS_DOWN` |
| 29 | `shstart` (`SHStart`) | C | `STRONGHOLD_START` |
| 30 | `shs` (`SHS`) | C | `STRONGHOLD_STRAIGHT` |
| 31 | `shssd` (`SHSSD`) | C | `STRONGHOLD_STRAIGHT_STAIRS_DOWN` |
| 32 | `tejp` (`TeJP`) | C | `JUNGLE_PYRAMID_PIECE` |
| 33 | `orp` (`ORP`) | T | `OCEAN_RUIN` |
| 34 | `iglu` (`Iglu`) | T | `IGLOO` |
| 35 | `rupo` (`RUPO`) | F | `RUINED_PORTAL` |
| 36 | `tesh` (`TeSH`) | C | `SWAMPLAND_HUT` |
| 37 | `tedp` (`TeDP`) | C | `DESERT_PYRAMID_PIECE` |
| 38 | `omb` (`OMB`) | C | `OCEAN_MONUMENT_BUILDING` |
| 39 | `omcr` (`OMCR`) | C | `OCEAN_MONUMENT_CORE_ROOM` |
| 40 | `omdxr` (`OMDXR`) | C | `OCEAN_MONUMENT_DOUBLE_X_ROOM` |
| 41 | `omdxyr` (`OMDXYR`) | C | `OCEAN_MONUMENT_DOUBLE_XY_ROOM` |
| 42 | `omdyr` (`OMDYR`) | C | `OCEAN_MONUMENT_DOUBLE_Y_ROOM` |
| 43 | `omdyzr` (`OMDYZR`) | C | `OCEAN_MONUMENT_DOUBLE_YZ_ROOM` |
| 44 | `omdzr` (`OMDZR`) | C | `OCEAN_MONUMENT_DOUBLE_Z_ROOM` |
| 45 | `omentry` (`OMEntry`) | C | `OCEAN_MONUMENT_ENTRY_ROOM` |
| 46 | `ompenthouse` (`OMPenthouse`) | C | `OCEAN_MONUMENT_PENTHOUSE` |
| 47 | `omsimple` (`OMSimple`) | C | `OCEAN_MONUMENT_SIMPLE_ROOM` |
| 48 | `omsimplet` (`OMSimpleT`) | C | `OCEAN_MONUMENT_SIMPLE_TOP_ROOM` |
| 49 | `omwr` (`OMWR`) | C | `OCEAN_MONUMENT_WING_ROOM` |
| 50 | `ecp` (`ECP`) | T | `END_CITY_PIECE` |
| 51 | `wmp` (`WMP`) | T | `WOODLAND_MANSION_PIECE` |
| 52 | `btp` (`BTP`) | C | `BURIED_TREASURE_PIECE` |
| 53 | `shipwreck` (`Shipwreck`) | T | `SHIPWRECK_PIECE` |
| 54 | `nefos` (`NeFos`) | T | `NETHER_FOSSIL` |
| 55 | `jigsaw` (`jigsaw`) | F | `JIGSAW` |

(`StructurePieceType` static initializer, one registration per row, in this order; the helper that registers a piece lower-cases the
code with `Locale.ROOT` and registers it under the default namespace. Table rows 0 to 55 were produced by extracting the string,
the registering helper and the target field of each registration in order; the "Load" column is the helper used: `setPieceId` is C,
`setTemplatePieceId` is T, `setFullContextPieceId` is F.)

### 2.5 Enums that structures use (ids in declaration order)

| Enum | Values, in order | Serialized names |
|---|---|---|
| `TerrainAdjustment` | 0 `NONE`, 1 `BURY`, 2 `BEARD_THIN`, 3 `BEARD_BOX`, 4 `ENCAPSULATE` | `none`, `bury`, `beard_thin`, `beard_box`, `encapsulate` |
| `StructureSpawnOverride$BoundingBoxType` | 0 `PIECE`, 1 `STRUCTURE` | `piece`, `full` |
| `RandomSpreadType` | 0 `LINEAR`, 1 `TRIANGULAR` | serialized names `linear` and `triangular` (read in the enum's static initializer) |
| `AbstractSpreadingStructurePlacement$FrequencyReductionMethod` | 0 `DEFAULT`, 1 `LEGACY_TYPE_1`, 2 `LEGACY_TYPE_2`, 3 `LEGACY_TYPE_3` | `default`, `legacy_type_1`, `legacy_type_2`, `legacy_type_3` |
| `StructureCheckResult` | 0 `START_PRESENT`, 1 `START_NOT_PRESENT`, 2 `CHUNK_LOAD_NEEDED` | none (internal) |
| `GenerationStep$Decoration` (the `step` field) | 0 `RAW_GENERATION`, 1 `LAKES`, 2 `LOCAL_MODIFICATIONS`, 3 `UNDERGROUND_STRUCTURES`, 4 `SURFACE_STRUCTURES`, 5 `STRONGHOLDS`, 6 `UNDERGROUND_ORES`, 7 `UNDERGROUND_DECORATION`, 8 `FLUID_SPRINGS`, 9 `VEGETAL_DECORATION`, 10 `TOP_LAYER_MODIFICATION` | `raw_generation`, `lakes`, `local_modifications`, `underground_structures`, `surface_structures`, `strongholds`, `underground_ores`, `underground_decoration`, `fluid_springs`, `vegetal_decoration`, `top_layer_modification` |

### 2.6 Naming-only lists

**`BuiltinStructures`** holds the resource keys of structure elements (`worldgen/structure`, namespace `minecraft`). 52 names, in
declaration order (the list was compared against the 52 `worldgen/structure` data files by sorted name; the order among the camp keys was not checked against the declaration): `pillager_outpost`, `mineshaft`, `mineshaft_mesa`, `mansion`, `jungle_pyramid`, `desert_pyramid`, `igloo`,
`shipwreck`, `shipwreck_beached`, `swamp_hut`, `stronghold`, `monument`, `ocean_ruin_cold`, `ocean_ruin_warm`, `fortress`,
`nether_fossil`, `end_city`, `buried_treasure`, `bastion_remnant`, `village_plains`, `village_desert`, `village_savanna`,
`village_snowy`, `village_taiga`, `ruined_portal`, `ruined_portal_desert`, `ruined_portal_jungle`, `ruined_portal_swamp`,
`ruined_portal_mountain`, `ruined_portal_ocean`, `ruined_portal_nether`, `ancient_city`, `trail_ruins`, `trial_chambers`, and eighteen `abandoned_camp_*` keys (names not repeated here; the data pack's file list is the reference). (Abandoned camps are not a structure type of
their own in section 2.2: `data/minecraft/worldgen/structure/abandoned_camp_forest.json` has type `minecraft:jigsaw`, and so do all 18 `abandoned_camp_*` files (type line read in each); the jigsaw fields, `start_pool`, `use_expansion_hack` and the `beard_thin` adaptation of that file belong to 36-3 section 8 and 36-9 and are not repeated here.)

**`BuiltinStructureSets`** holds the resource keys of structure sets. 21 names: `villages`, `desert_pyramids`, `igloos`,
`jungle_temples`, `swamp_huts`, `pillager_outposts`, `ocean_monuments`, `woodland_mansions`, `buried_treasures`, `mineshafts`,
`ruined_portals`, `shipwrecks`, `ocean_ruins`, `nether_complexes`, `nether_fossils`, `end_cities`, `ancient_cities`, `strongholds`,
`trail_ruins`, `trial_chambers`, `abandoned_camp`.

These two lists are naming only: they say which keys code refers to, not what the elements contain. A data pack may add other
structures and sets; no engine requires the lists to be complete.

**`StructureTags`** (`worldgen`-side tag keys of `worldgen/structure`, tag file names in `data/minecraft/tags/worldgen/structure/`):
`eye_of_ender_located`, `dolphin_located`, `on_woodland_mansion_maps`, `on_ocean_monument_maps`, `on_savanna_village_maps`,
`on_desert_village_maps`, `on_plains_village_maps`, `on_taiga_village_maps`, `on_snowy_village_maps`, `on_jungle_pyramid_maps`,
`on_swamp_hut_maps`, `on_treasure_maps`, `on_buried_trial_chambers_maps`, `on_ancient_city_maps`, `on_mineshaft_maps`,
`on_desert_pyramid_maps`, `on_ocean_ruin_warm_maps`, `cats_spawn_in`, `cats_spawn_as_black`, `village`, `mineshaft`, `shipwreck`,
`ruined_portal`, `ocean_ruin`, `abandoned_camp`, `on_abandoned_camp_bamboo_jungle_maps`, `on_abandoned_camp_cherry_grove_maps`,
`on_abandoned_camp_birch_forest_maps`, `on_abandoned_camp_dappled_forest_maps`, `on_abandoned_camp_flower_forest_maps`,
`on_abandoned_camp_pale_garden_maps`, `on_abandoned_camp_swamp_maps`, `on_abandoned_camp_windswept_forest_maps` (33 keys). The
membership is data. Which engine consults which tag: `*_maps` tags select the structure an explorer map or the locate machinery
searches for (item and command documents, 16 section 7.7); `cats_spawn_in` and `cats_spawn_as_black` are read by the cat spawning
rules (18, 19); `village` and the other single-family tags are read by village, raid and other engine code that asks "is this position
inside a structure of this family" through `getStructureWithPieceAt` (section 7.5); `eye_of_ender_located` and `dolphin_located`
are the search targets of the two items. (The consumer attributions after the tag names (cat spawning, villages, maps, eye of ender, dolphin) were not traced to any call site in this
round: they are (inferred) from the tag names, are textbook-style, and stay in Open question 4.)

---

## 3. Element schemas

JSON field names are exactly the codec field names. "H-or-I" and "HolderSet" are the forms of 23 section 5.1.

### 3.1 Common structure settings (`Structure$StructureSettings`)

Flattened into every structure element beside `type`.

| Field | Type | Default | Meaning |
|---|---|---|---|
| `biomes` | HolderSet of `worldgen/biome` | required | The biomes in which the structure may generate (section 5.1 uses the set twice: as a coarse filter and as the valid-biome predicate). |
| `spawn_overrides` | map from mob category to spawn override | required (may be an empty object) | Section 10. Keys are the mob category names of 18. |
| `step` | `GenerationStep$Decoration` name | required | The decoration step at which the pieces are placed (section 8). (Read: `Structure$StructureSettings` has a static `DEFAULT` built with an empty spawn-override map, step `surface_structures` and adaptation `none`; the one-argument constructor taking only biomes copies the other three from `DEFAULT`. The codec still requires `step` and `spawn_overrides`; the shipped `abandoned_camp_forest` element states `surface_structures` explicitly.) |
| `terrain_adaptation` | `TerrainAdjustment` name | `none` (the codec's optional default is taken from `DEFAULT`, read) | Section 9. |

### 3.2 Structure set (`StructureSet`)

| Field | Type | Meaning |
|---|---|---|
| `structures` | list of selection entries | non-empty in every shipped use (emptiness is not validated by the codec: the generation loop of section 5.2 simply ends at once); the order is the order of the weighted choice |
| `placement` | placement object | section 3.3 |

A selection entry is `{ "structure": H-or-I of structure, "weight": positive int }` (`weight` is a positive integer; the codec
rejects 0 and negatives). A constructor exists that wraps one structure with weight 1.

### 3.3 Placements

All three placement types implement `isStructureChunk(state, chunkX, chunkZ)` (section 4.2). The two spreading ones share these
fields (`AbstractSpreadingStructurePlacement`):

| Field | Type | Default | Meaning |
|---|---|---|---|
| `locate_offset` | `[x, y, z]` ints, each with absolute value at most 16 | `[0, 0, 0]` | added to the chunk's minimum-corner block position at y = 0 to give the locate target (section 4.8) |
| `frequency_reduction_method` | name | `default` | section 4.4 |
| `frequency` | float in [0, 1] | `1.0` | probability scale of the reducer |
| `salt` | non-negative int | required | extra seed term |
| `exclusion_zone` | `{ "other_set": H-or-I of structure set, "chunk_count": int 1..16 }` | absent | section 4.5 |

`random_spread` adds `spacing` (int 0..4096, required), `separation` (int 0..4096, required) and `spread_type` (default `linear`). The
codec also validates `spacing > separation` (the check passes when `spacing <= separation` is false; a violating element is rejected
with an error message). `concentric_rings` adds `distance` (int 0..1023), `spread` (int 0..1023), `count` (int 1..4095) and
`preferred_biomes` (HolderSet of `worldgen/biome`), all required. `dimension_origin` has no fields beyond `type`.

---

## 4. Placement engines

### 4.1 The per-world state (`ChunkGeneratorStructureState`)

One per dimension generator, created by `ChunkGenerator.createState(structureSetLookup, randomState, seed)` (normal generators) or by
the flat-world variant. It holds:

| Field | Value |
|---|---|
| `levelSeed` | the world seed (the dimension's seed as given to the generator) |
| `concentricRingsSeed` | normal generators: the world seed; flat generators: **0** |
| `origin` | the "dimension origin" chunk: `ChunkGenerator.getOrigin(randomState)`. The base implementation returns chunk (0, 0). The noise generator returns, when its noise settings' `spawn_target` list is non-empty, the chunk containing `NoiseSpawnFinder.findSpawnPosition(spawn_target, samplers)` evaluated with a cached sampler context (the spawn search is outside this round), otherwise chunk (0, 0). |
| `possibleStructureSets` | every element of `worldgen/structure_set`, kept only if at least one structure of the set has at least one biome (of its `biomes` set) that is in the generator's biome source's possible-biome set. Order: registry listing order. |
| `placementsForStructure` | built lazily on first query (`ensureStructuresGenerated`): for every kept set and every structure entry whose `biomes` intersect the possible biomes, the set's placement is appended to the structure's placement list (a structure listed in two sets gets two placements). |
| `ringPositions` | built lazily with the above: for every kept set whose placement is `concentric_rings` and which has at least one qualifying structure, the ring chunk list of section 4.6 |

Two queries used later: `hasStructureChunkInRange(set, cx, cz, r)` is true when any chunk (x, z) with `|x - cx| <= r` and
`|z - cz| <= r` (x outer loop from `cx - r`, z inner loop from `cz - r`) satisfies the set's placement `isStructureChunk` (this
is the exclusion-zone test); `getPlacementsForStructure(structure)` returns the list above, empty when the structure is in no kept
set.

### 4.2 `isStructureChunk` (what "this chunk may hold a start of the set" means)

For the two spreading placements the result is the **conjunction**, evaluated in this order and short-circuiting:

1. `isPlacementChunk(state, cx, cz)` (type-specific: sections 4.3, 4.6);
2. `applyAdditionalChunkRestrictions(cx, cz, levelSeed)`: true when `frequency >= 1.0`; otherwise the frequency reducer (section 4.4)
   must return true for `(levelSeed, salt, cx, cz, frequency)`;
3. `applyInteractionsWithOtherStructures(state, cx, cz)`: true when there is no exclusion zone, or when
   `state.hasStructureChunkInRange(other_set, cx, cz, chunk_count)` is false.

`dimension_origin` is simply "the chunk is the state's origin chunk" (no restrictions). `StructureCheck` (section 7.6) uses step 2
alone (`applyAdditionalChunkRestrictions`) as a cheap pre-test.

### 4.3 `random_spread`

Seeding helper (read in `WorldgenRandom`), used by every legacy-seeded structure computation here:

| Helper | Definition |
|---|---|
| `setLargeFeatureWithSalt(seed, rx, rz, salt)` | `setSeed( rx * 341873128712 + rz * 132897987541 + seed + salt )` with 64-bit wrap-around arithmetic (`rx`, `rz` are 32-bit ints widened to 64 bits before the multiplication) |
| `setLargeFeatureSeed(seed, cx, cz)` | defined in 11 section 4: `setSeed(seed)`, `a = nextLong()`, `b = nextLong()`, `setSeed((cx*a) xor (cz*b) xor seed)` |

Every `WorldgenRandom` of this section wraps `LegacyRandomSource(0)`, so `setSeed` is the Java LCG scramble (10 section 2.6) and every
`nextInt`, `nextFloat`, `nextDouble`, `nextLong` is the legacy definition.

**Potential structure chunk of a spacing cell.** For a chunk (cx, cz), the grid cell is `(rx, rz) = (floorDiv(cx, spacing), floorDiv(cz,
spacing))` (floor division, so negative chunks go to negative cells). With `W` a fresh legacy `WorldgenRandom`:

1. `W.setLargeFeatureWithSalt(levelSeed, rx, rz, salt)`.
2. `limit = spacing - separation`.
3. `dx = evaluate(W, limit)`, then `dz = evaluate(W, limit)`, in that order. `evaluate` is: `linear`: `W.nextInt(limit)`; `triangular`:
   `(W.nextInt(limit) + W.nextInt(limit)) / 2` (integer division; two draws, the first added is drawn first).
4. The potential chunk is `(rx * spacing + dx, rz * spacing + dz)`.

`isPlacementChunk(state, cx, cz)` is true exactly when the potential chunk of the cell containing (cx, cz) equals (cx, cz). So a
set holds at most one start per `spacing x spacing` chunk cell, at offset `0 .. spacing - separation - 1` from the cell's minimum
corner (the whole `separation` is a guaranteed gap at the high edge of the cell; neighbouring starts are therefore at least
`separation` chunks apart in each axis only when linear). If `limit` is 0 `nextInt(0)` would throw; the codec's `spacing >
separation` check prevents that.

### 4.4 Frequency reduction (`frequency_reduction_method`)

`frequency < 1`: the chunk passes only if the selected reducer returns true. Each reducer builds a fresh legacy `WorldgenRandom`
(`LegacyRandomSource(0)`) and draws once; "chunk" below means (cx, cz) of the candidate chunk. The mapping of constants to
reducers is read from the enum's static initializer: invokedynamic #0 to #3 map to `probabilityReducer` (`default`), `legacyPillagerOutpostReducer` (`legacy_type_1`), `legacyArbitrarySaltProbabilityReducer` (`legacy_type_2`) and `legacyProbabilityReducerWithDouble` (`legacy_type_3`).

| Method | Seeding | Draw and test |
|---|---|---|
| `default` | `setLargeFeatureWithSalt(levelSeed, cx, cz, salt)` | `nextFloat() < frequency` |
| `legacy_type_1` (pillager-outpost style) | none of the helpers: `rx = cx >> 4`, `rz = cz >> 4` (arithmetic shift); `setSeed( ((rx xor (rz << 4)) as 64-bit) xor levelSeed )`; then one `nextInt()` is **discarded** | `nextInt(trunc(1.0 / frequency)) == 0`, where `trunc` is the float-to-int conversion (toward zero) of the single-precision quotient `1.0f / frequency` |
| `legacy_type_2` (arbitrary-salt style) | `setLargeFeatureWithSalt(levelSeed, cx, cz, 10387320)` (the fixed salt 10387320 replaces the placement's salt) | `nextFloat() < frequency` |
| `legacy_type_3` | `setLargeFeatureSeed(levelSeed, cx, cz)` | `nextDouble() < (double) frequency` |

For `default` and `legacy_type_2` the float comparison is single precision (`nextFloat` returns a float).

### 4.5 Exclusion zone

`exclusion_zone.other_set` names another structure set (resolved from the registry, or an inline set). The candidate chunk is rejected
when `hasStructureChunkInRange(other_set, cx, cz, chunk_count)` is true (section 4.1: a square of side `2 * chunk_count + 1` chunks
centred on the candidate, tested against the other set's own `isStructureChunk`, including the other set's own frequency and exclusion
rules, which recurse). Exclusion is therefore one-directional unless both sets name each other (and mutual exclusion would recurse
without end; no shipped data does this, inferred).

### 4.6 `concentric_rings`

`isPlacementChunk(state, cx, cz)`: the placement's ring list was computed by the state (below); true when (cx, cz) is in the list;
false when the list is absent. The list is a function of `concentricRingsSeed`, the placement's `distance`, `spread`, `count`,
`preferred_biomes`, the biome source and the random state. It is computed once per placement per world.

Let `R` be `LegacyRandomSource` seeded by `setSeed(concentricRingsSeed)` (the source is created with a unique random seed and
immediately reseeded, so the result is deterministic). `count = 0` gives an empty list. Otherwise, with `distance = D`, `spread = S`
(the first ring's number of positions), `count = N`:

1. `angle = R.nextDouble() * pi * 2` (pi is `3.141592653589793`).
2. State: `posInRing = 0`, `ring = 0`. For `i = 0 .. N-1`:
   1. `radius = ((4 * D + D * ring * 6) as int) + (R.nextDouble() - 0.5) * (D * 2.5)` (the int part is exact; the product is double).
   2. `rx = round(cos(angle) * radius)`, `rz = round(sin(angle) * radius)`, where `round` is Java `Math.round` on a double (floor of
      `value + 0.5`), `cos` and `sin` are `Math.cos`, `Math.sin` (double).
   3. `F = R.fork()`: a new `LegacyRandomSource` seeded with `R.nextLong()` (two `next(32)` draws from `R`).
   4. The ring chunk for this position is the result of the **biome search** of section 4.6.1 with the ring coordinates `(rx, rz)`,
      the placement's `preferred_biomes` and the random source `F`; if the search finds nothing the ring chunk is `(rx, rz)` itself.
      (The searches run on a worker pool in the artifact; the list order is the order of `i`, so the result does not depend on
      scheduling.)
   5. `angle += 2 * pi / S`; `posInRing += 1`.
   6. If `posInRing == S`: `ring += 1`; `posInRing = 0`; `S = S + (2 * S) / (ring + 1)` (integer division, with the **new** `ring`);
      `S = min(S, N - i)` (with the current `i`, before increment); then `angle += R.nextDouble() * pi * 2`.

The outputs are `N` chunk coordinates in order. Because the search draws only from `F`, the stream of `R` is exactly: one draw for the
start angle, per position one `nextDouble` and one `nextLong`, per completed ring one more `nextDouble`.

#### 4.6.1 The biome search used by rings (`BiomeSource.findBiomeHorizontal`, step 1, scan-all mode)

Debug branch: when `SharedConstants.DEBUG_ONLY_GENERATE_HALF_THE_WORLD` or `debugGenerateSquareTerrainWithoutNoise` is set, the outer z loop
starts at 0 instead of -r (a debug-only path, out of scope). Read: `SharedConstants` does not hard-code the two flags; its static initializer sets both from `debugFlag(name)` with the names `ONLY_GENERATE_HALF_THE_WORLD` and `GENERATE_SQUARE_TERRAIN_WITHOUT_NOISE`, so they are switch-controlled debug flags, off unless an operator sets them (the property mechanism behind `debugFlag` is inferred; `debugFlag` itself was not read; Open question 12).

Call: `findBiomeHorizontal(blockX = rx * 16 + 8, y = 0, blockZ = rz * 16 + 8, radius = 112, predicate = "preferred_biomes
contains biome", random = F, sampler)`, which the artifact implements with step = 1 and "closest-first" = false. In quart (4-block
cell) units: `cx = blockX >> 2`, `cz = blockZ >> 2`, `cy = y >> 2 = 0`, `r = 112 >> 2 = 28`. The biome of a cell is the multi-noise
biome at quart coordinates (qx, cy, qz) from a caching resolver of the climate sampler (10 section 7). The scan visits **every** cell
of the square `|dx| <= 28`, `|dz| <= 28`, with `dz` as the outer loop (from -28 up) and `dx` the inner loop, for the radius value
`r = 28` only (the loop over radii runs a single value in this mode). Each cell whose biome satisfies the predicate takes part in
**reservoir sampling** with `F`: let `k` be the number of qualifying cells seen before this one (0 for the first). If `k = 0`, or
`F.nextInt(k + 1) == 0`, this cell becomes the candidate (block position `(qx * 4, y, qz * 4)`); every qualifying cell increments `k`
whether or not it was chosen. The result is the final candidate (or none); its chunk is `(candidateBlockX >> 4, candidateBlockZ >> 4)`.
The first qualifying cell draws nothing from `F`; each later qualifying cell draws exactly one `nextInt`.

### 4.7 `dimension_origin`

`isStructureChunk` is true for exactly one chunk per dimension: `state.origin` (section 4.1). Locate offset is zero (the interface
default).

### 4.8 Locate position

`getLocatePos(chunkPos)` is `(chunkPos.minBlockX, 0, chunkPos.minBlockZ) + locateOffset`. The offset is `locate_offset` for the two
spreading placements and zero for `dimension_origin`. (The y of the result is the offset's y; `locate` commands show it as the
reported position, see 16 section 7.7. The concentric rings locate path in section 11 uses a different fixed point.)

---

## 5. Creating starts

### 5.1 The generation context (`Structure$GenerationContext`)

An immutable bundle given to a structure's generator: registry access, chunk generator, biome source, climate sampler, biome resolver
(`biomeSource.createResolver(climateSampler)`), random state, structure template manager, a `WorldgenRandom` (`random`), the world
`seed`, the chunk position, the level height accessor (min y, max y), and a `validBiome` predicate. `random` is built as
`LegacyRandomSource(0)` wrapped in `WorldgenRandom` and seeded with `setLargeFeatureSeed(seed, chunkX, chunkZ)` (11 section 4);
**every structure of a chunk therefore starts from the same random state**; a generator consumes it in its own order. `validBiome` is
`structure.biomes.contains(biome)`.

Queries on the context:

| Query | Definition |
|---|---|
| `isValidBiome(stub)` | `validBiome( biomeResolver.getNoiseBiome( stub.position.x >> 2, stub.position.y >> 2, stub.position.z >> 2 ) )` |
| `couldStructureExistInColumn(x, z, yLow, yHigh)` (block coordinates) | convert all to quart units (`>> 2`); build a resolver for the 1 x (qHigh - qLow + 1) x 1 column at (qx, qLow, qz); true when `validBiome` holds for any quart cell in the column from `qLow` to `qHigh` inclusive (the loop runs `qy` from `qLow` up) |
| `couldValidBiomeExistInTerrainColumn(x, z)` | `couldStructureExistInColumn(x, z, minY - 1, maxY)` with the height accessor's min y and max y (max y inclusive) |
| `couldValidBiomeExistOnTopOfChunkCenter()` | `couldValidBiomeExistInTerrainColumn(chunk middle block x, chunk middle block z)`; the middle block is `chunkMin + 8` per axis |

The `y` of the first query is a **quart** column scan, so the coarse check can be true although the exact stub position's biome fails
`isValidBiome` (the stub check is the authoritative one, section 5.3).

### 5.2 `createStructures` for one chunk (stage `STRUCTURE_STARTS`)

`ChunkGenerator.createStructures` does nothing when the debug flag that disables structures is set. Otherwise it builds a climate
sampler from the random state with caches enabled and, for **each structure set in `possibleStructureSets` (in order)**, runs:

1. If any structure of the set already has a **valid** start in this chunk (read through the chunk's start map), stop for this set.
2. If `placement.isStructureChunk(state, chunkX, chunkZ)` is false, stop for this set.
3. If the set has exactly one entry: try to generate that entry (step 5) and stop.
4. Otherwise copy the entry list; make a legacy `WorldgenRandom` and `setLargeFeatureSeed(levelSeed, chunkX, chunkZ)` (a second,
   separate random from the context's `random`; it is used only for choosing); let `total` be the sum of the remaining weights.
5. While the list is non-empty: `r = nextInt(total)`; walk the list in order subtracting each entry's weight from `r` until `r`
   becomes negative (that entry is chosen; index `j`). Try to generate the chosen entry. If it produced a valid start, stop for this
   set. Otherwise remove the entry from the list, subtract its weight from `total`, and repeat.

"Try to generate an entry": `refs = ` the references count of an existing start of that structure in this chunk (0 if none); call
`Structure.generate` (section 5.3) with the chunk generator's biome source, random state, template manager, world seed, chunk
position, `refs`, the level height accessor and `structure.biomes.contains`; if the returned start is valid, store it in the chunk
(`setStartForStructure`, which marks the chunk unsaved) and report success. Nothing is stored for a failed attempt.

So at most one structure per set generates per chunk; different sets are independent, and several sets may each generate a start in
the same chunk.

`ChunkStatusTasks`: the stage `STRUCTURE_STARTS` runs `createStructures` only when the world option "generate structures" is on, and
in every case then notifies the level that the chunk's structure starts are available; a chunk loaded from disk at this stage skips
generation and only notifies (`loadStructureStarts`).

### 5.3 `Structure.generate` and the generation stub

1. Build the context of section 5.1.
2. `findValidGenerationPoint(ctx)`: call the structure's own `findGenerationPoint(ctx)` (36-3 to 36-10); keep the result only if
   `ctx.isValidBiome(stub)` (the stub's **position** is tested, before any piece exists).
3. If a stub remains: obtain its pieces builder (the stub holds either a consumer that fills a fresh `StructurePiecesBuilder`, or a
   ready builder; the consumer runs now, here, **after** the biome check) and create
   `StructureStart(structure, chunkPos, references, builder.build())`; if that start is valid (at least one piece) return it.
4. Otherwise return the shared invalid start (`INVALID_START`: no pieces, chunk (0, 0), references 0, no structure).

A generation stub is `{ position: BlockPos, generator }`.

### 5.4 Helpers that generators call (all on `Structure`)

Heights use `ChunkGenerator.getFirstOccupiedHeight(x, z, heightmapType, heightAccessor, randomState)`, which is
`getBaseHeight(x, z, type, ...) - 1`. For a noise generator `getBaseHeight` is the column query of 37-2 section 6.5 (no surface rules,
no carvers, no structures: terrain density only), returning the y after the highest block that satisfies the heightmap's predicate
(`minY` when none).

| Helper | Definition |
|---|---|
| `onTopOfChunkCenter(ctx, heightmap, consumer)` | empty if `couldValidBiomeExistOnTopOfChunkCenter()` is false; else the next |
| `onTopOfChunkCenterWithoutBiomeCheck(ctx, heightmap, consumer)` | `x = chunk middle x`, `z = chunk middle z`, `y = getFirstOccupiedHeight(x, z, heightmap)`; stub at `(x, y, z)` with `consumer` |
| `getCornerHeights(ctx, x, sizeX, z, sizeZ)` | four heights with heightmap `WORLD_SURFACE_WG`, in this order: `(x, z)`, `(x, z + sizeZ)`, `(x + sizeX, z)`, `(x + sizeX, z + sizeZ)` |
| `getMeanFirstOccupiedHeight(ctx, x, sizeX, z, sizeZ)` | the integer (truncating) mean of the four corner heights: `sum / 4` |
| `getLowestY(ctx, x, z, sizeX, sizeZ)` | the minimum of the four corner heights above, with corners `(x, z)`, `(x, z + sizeZ)`, `(x + sizeX, z)`, `(x + sizeX, z + sizeZ)` |
| `getLowestY(ctx, sizeX, sizeZ)` | the same with `(x, z)` = the chunk's minimum block corner |
| `getLowestYIn5by5Box(ctx, x, z, rotation)` | a block position `(x, lowest, z)` with `lowest = getLowestY(ctx, x, z, sx, sz)`, where `(sx, sz)` = `(5, 5)` for rotation `NONE`, `(-5, 5)` for `CLOCKWISE_90`, `(-5, -5)` for `CLOCKWISE_180`, `(5, -5)` for `COUNTERCLOCKWISE_90` (negative sizes mean the box extends toward lower coordinates) |
| `adjustBoundingBox(box)` | the box itself when `terrain_adaptation` is `none`; otherwise the box inflated by 12 in every direction (`inflatedBy(12)`) |
| `afterPlace(...)` | default no-op; a few structures override it (36-4 to 36-10); called after the pieces of a start have been placed in a chunk (section 8) |

(The argument order of `getLowestY(ctx, x, z, sizeX, sizeZ)` was read from the call into `getCornerHeights`, whose own parameters
are `(x, sizeX, z, sizeZ)`.)

### 5.5 `SinglePieceStructure` and `ScatteredFeaturePiece`

`SinglePieceStructure` is the base of the structures that consist of one piece made by a constructor taking `(random, blockX,
blockZ)`; it stores that constructor and the piece's width and depth. Its `findGenerationPoint`:

1. empty if `couldValidBiomeExistOnTopOfChunkCenter()` is false;
2. empty if `getLowestY(ctx, width, depth) < generator.getSeaLevel()` (the chunk's minimum corner plus the piece footprint, section 5.4);
3. otherwise `onTopOfChunkCenterWithoutBiomeCheck(ctx, WORLD_SURFACE_WG, builder -> builder.addPiece(constructor(ctx.random,
   chunkMinBlockX, chunkMinBlockZ)))`.

`ScatteredFeaturePiece` is the base of the single-block-footprint pieces (temples, huts, igloo-like pieces that build by code). Fields:
`width`, `height`, `depth` (final) and `heightPosition` (initially -1, meaning "not yet fixed"). Constructor: the bounding box is
`makeBoundingBox(x, y, z, orientation, width, height, depth)` (section 6.3) and `setOrientation(orientation)` is applied.
NBT keys added by the class: `Width`, `Height`, `Depth`, `HPos` (all ints, missing reads as 0).

Two ground-fitting helpers, called from `postProcess` of subclasses (the level is the generation level, the box is the chunk write
box):

* `updateAverageGroundHeight(level, chunkBox, offset)`: returns true at once when `heightPosition >= 0`. Otherwise it visits every
  column `(x, z)` of the piece's own box (z from `minZ`, x from `minX`); a column counts only if the block position `(x, 64, z)` is
  inside `chunkBox`, and then adds the y of `level.getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, (x, 64, z))` (35-1 section 4.2) to a
  sum and 1 to a count. No counted column: returns false (nothing changes). Otherwise `heightPosition = sum / count` (integer
  division) and the piece's box is moved vertically by `heightPosition - box.minY + offset`; returns true. (The first chunk that
  places any part of the piece fixes `heightPosition`, from only that chunk's columns; later chunks reuse it.)
* `updateHeightPositionToLowestGroundHeight(level, offset)`: returns true when `heightPosition >= 0`. Otherwise the minimum, over
  **every** column of the piece's box, of `level.getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, (x, 0, z)).y`, starting from `level.maxY + 1`;
  no column is impossible for a non-empty box; then `heightPosition = minimum` and the box is moved vertically by `heightPosition -
  box.minY + offset`; returns true.

### 5.6 `StructureStart`

Fields: `structure`, `pieceContainer` (the ordered pieces), `chunkPos` (the chunk that holds the start, i.e. where it was generated),
`references` (int), and a cached bounding box. Behaviour:

* `isValid()`: the container has at least one piece.
* `getBoundingBox()`: computed once as `structure.adjustBoundingBox(union of all piece boxes)` (section 5.4: inflated by 12 when the
  structure adapts terrain). The union is the smallest box containing every piece box.
* `canBeReferenced()`: `references < getMaxReferences()` where the maximum is **1** (the class is final and does not vary it).
* `addReference()`: `references += 1`.
* `placeInChunk(level, structureManager, generator, random, chunkBox, chunkPos)`: section 8.
* `createTag(context, chunkPos)` and `loadStaticStart(context, tag, seed)`: section 7.3.

---

## 6. Pieces

### 6.1 `StructurePiece` fields

| Field | Meaning |
|---|---|
| `type` | the `StructurePieceType` (section 2.4) |
| `boundingBox` | the piece's `BoundingBox` (mutable) |
| `genDepth` | generation depth (an int; used by recursive generators as the recursion depth, jigsaw as the depth) |
| `orientation` | a horizontal `Direction` or null |
| `rotation`, `mirror` | derived from `orientation` by `setOrientation` (section 6.4); `NONE` when the orientation is null |

### 6.2 Abstract operations

A piece implements `postProcess(level, structureManager, generator, random, chunkBox, chunkPos, pivot)` (place blocks into the
part of the world inside `chunkBox`), `addAdditionalSaveData(context, tag)`, and may override `addChildren(parent, builder, random)`
(default: nothing; recursive generators add the next pieces here), `canBeReplaced(level, x, y, z, box)` (default: true) and
`getLocatorPosition()` (default: the box centre). Provided: `getBoundingBox()`, `getGenDepth()`, `setGenDepth`, `move(dx, dy, dz)`
(moves the box), `isCloseToChunk(chunkPos, margin)`: the box intersects (x, z only) the square from `(chunkMinX - margin, chunkMinZ -
margin)` to `(chunkMinX + 15 + margin, chunkMinZ + 15 + margin)` (inclusive).

### 6.3 `BoundingBox`

Six ints `minX, minY, minZ, maxX, maxY, maxZ`, **both ends inclusive**. The constructor given `(x0, y0, z0, x1, y1, z1)` stores them
as given if `x1 >= x0`, `y1 >= y0` and `z1 >= z0`; otherwise (a malformed box; the artifact also logs it) it stores the per-axis min
and max. NBT and codec form: an int array of six values in the order `[minX, minY, minZ, maxX, maxY, maxZ]` (a fixed size of 6 is
enforced).

| Operation | Definition |
|---|---|
| `intersects(box)` / `intersects(x0, y0, z0, x1, y1, z1)` | true iff on each axis `this.max >= other.min` and `this.min <= other.max` (touching boxes intersect; the 4-argument form `(x0, z0, x1, z1)` tests x and z only) |
| `isInside(x, y, z)` | `min <= v <= max` on every axis |
| `getXSpan` / `getYSpan` / `getZSpan` | `max - min + 1` |
| `getCenter()` | per axis `min + (max - min + 1) / 2` (integer division) |
| `inflatedBy(n)` / `inflatedBy(x, y, z)` | a new box with `min - n` and `max + n` per axis |
| `move(dx, dy, dz)` / `moved(...)` | shift all six values (the first mutates, the second returns a copy) |
| `encapsulate(box)` / `encapsulate(pos)` / `encapsulatingBoxes(iterable)` | the smallest box containing both; the iterable form returns empty for an empty iterable |
| `intersectingChunks()` | the chunk positions from `(minX >> 4, minZ >> 4)` to `(maxX >> 4, maxZ >> 4)` inclusive |
| `fromCorners(a, b)` | per-axis min and max of two positions |
| `infinite()` | min = `-2147483648`, max = `2147483647` on all axes |
| `orientBox(x, y, z, offX, offY, offZ, width, height, depth, direction)` | below |

**`orientBox`** places a `width` (x of the piece-local frame) by `height` by `depth` (z of the local frame) box at an anchor
`(x, y, z)` plus a local offset, rotated by the direction. In every case `minY = y + offY` and `maxY = y + height - 1 + offY`.

| Direction | `minX` | `maxX` | `minZ` | `maxZ` |
|---|---|---|---|---|
| `SOUTH` (and any other direction, including up and down) | `x + offX` | `x + width - 1 + offX` | `z + offZ` | `z + depth - 1 + offZ` |
| `NORTH` | `x + offX` | `x + width - 1 + offX` | `z - depth + 1 + offZ` | `z + offZ` |
| `WEST` | `x - depth + 1 + offZ` | `x + offZ` | `z + offX` | `z + width - 1 + offX` |
| `EAST` | `x + offZ` | `x + depth - 1 + offZ` | `z + offX` | `z + width - 1 + offX` |

(Read from the four branches of `orientBox`; the branch for each direction was matched through the switch table of `BoundingBox$1`,
whose constants are `SOUTH`, `NORTH`, `WEST`, `EAST` in this order, 1 to 4. Note that the order differs from the table of
`StructurePiece$1` in section 6.4.)

`StructurePiece.makeBoundingBox(x, y, z, direction, width, height, depth)`: if the direction's axis is Z (north or south): the box
`(x, y, z)` to `(x + width - 1, y + height - 1, z + depth - 1)`; otherwise (axis X, or any other): `(x, y, z)` to `(x + depth - 1,
y + height - 1, z + width - 1)`. `getRandomHorizontalDirection(random)` picks uniformly from the four horizontal directions in the
order `NORTH, EAST, SOUTH, WEST` using the `Util.getRandom` list draw (one `nextInt(4)`; its exact form is 35-1 section 5.2's
`nextInt(bound)` over a size-4 array; `Util.getRandom` on a list or array is exactly one `nextInt(size)` followed by an indexed get, read).

### 6.4 Orientation, rotation, mirror and the piece-local frame

`setOrientation(d)` sets `orientation = d` and derives, by direction:

| Orientation | `mirror` | `rotation` |
|---|---|---|
| none (null) | `NONE` | `NONE` |
| `NORTH` | `NONE` | `NONE` |
| `SOUTH` | `LEFT_RIGHT` | `NONE` |
| `WEST` | `LEFT_RIGHT` | `CLOCKWISE_90` |
| `EAST` | `NONE` | `CLOCKWISE_90` |
| anything else | `NONE` | `NONE` |

The three world-coordinate converters turn a piece-local `(x, y, z)` (local x along the piece's width, local z along its depth, local
y up from the piece's lowest layer) into world coordinates, using the box and the orientation:

| Orientation | `worldX(x, z)` | `worldZ(x, z)` |
|---|---|---|
| null | `x` | `z` |
| `NORTH` | `minX + x` | `maxZ - z` |
| `SOUTH` | `minX + x` | `minZ + z` |
| `WEST` | `maxX - z` | `minZ + x` |
| `EAST` | `minX + z` | `minZ + x` |

`worldY(y)` is `y` when the orientation is null (the local y is already absolute) and `minY + y` otherwise. (Read from the two
switch tables of `getWorldX` and `getWorldZ`, whose index order is `NORTH`=1, `SOUTH`=2, `WEST`=3, `EAST`=4.) `getWorldPos(x, y, z)`
combines the three.

### 6.5 Block-writing helpers (what generators call)

Every helper below takes a **chunk write box** (`BoundingBox`); a block whose world position is outside it is skipped (the whole
piece is rebuilt by every chunk it touches, each time writing only its own chunk's part, section 8). All local coordinates are
piece-local.

| Helper | Behaviour |
|---|---|
| `placeBlock(level, state, x, y, z, box)` | world position `p = getWorldPos`; skip if `p` is outside `box` or if `canBeReplaced(level, x, y, z, box)` is false; apply `mirror` to the state if the piece's mirror is not `NONE`, then `rotation` if not `NONE` (mirror first, then rotate); `level.setBlock(p, state, 2)`; if the position now has a non-empty fluid state, schedule a fluid tick for it with delay 0; if the placed block is one of the **shape-check blocks** (below), mark `p` for post-processing in its chunk (35-1 section 4.3). |
| `getBlock(level, x, y, z, box)` | the block at the world position, or air when outside `box` |
| `isInterior(level, x, y, z, box)` | world position of `(x, y + 1, z)`: false if outside `box`; else true iff that y is below `level.getHeight(OCEAN_FLOOR_WG, worldX, worldZ)` |
| `generateAirBox(level, box, x0, y0, z0, x1, y1, z1)` | `placeBlock(air)` for every cell; loop order **y outermost, then x, then z** (all `generate*` helpers use this order, which matters only for the order of side effects) |
| `generateBox(level, box, x0,y0,z0,x1,y1,z1, edgeState, fillState, skipAir)` | for every cell: if `skipAir` and the existing block (via `getBlock`) is air, skip; the cell is an **edge cell** when `y` equals `y0` or `y1`, or `x` equals `x0` or `x1`, or `z` equals `z0` or `z1`; place `edgeState` for edge cells, `fillState` otherwise |
| `generateBox(level, box, x0,..z1, skipAir, random, selector)` | same cells and edge test, no fixed states: call `selector.next(random, x, y, z, isEdge)`, then place `selector.getNext()` (a `BlockSelector` subclass keeps its choice in a protected field, initial air) |
| `generateBox(level, box, localBox, edgeState, fillState, skipAir)` and the selector form | the same with the corners taken from a local `BoundingBox` |
| `generateMaybeBox(level, box, random, chance, x0,y0,z0,x1,y1,z1, edgeState, fillState, skipAir, requireInterior)` | for every cell, **first draw `random.nextFloat()` (always, even for cells that end up skipped)**; skip the cell if the draw is greater than `chance`; then skip if `skipAir` and the cell is air; then skip if `requireInterior` and `isInterior` is false; then place `edgeState` or `fillState` by the same edge test |
| `maybeGenerateBlock(level, box, random, chance, x, y, z, state)` | draw `random.nextFloat()`; place the block iff the draw `< chance` |
| `generateUpperHalfSphere(level, box, x0,y0,z0,x1,y1,z1, state, skipAir)` | `sx = x1-x0+1`, `sy = y1-y0+1`, `sz = z1-z0+1` (floats); centre `cx = x0 + sx/2`, `cz = z0 + sz/2`; for `y` from `y0` to `y1`: `ny = (y - y0) / sy`; for `x`: `nx = (x - cx) / (sx * 0.5)`; for `z`: `nz = (z - cz) / (sz * 0.5)`; skip if `skipAir` and air; place `state` iff `nx*nx + ny*ny + nz*nz <= 1.05` (all single precision) |
| `fillColumnDown(level, state, x, y, z, box)` | from the world position of `(x, y, z)` (skip entirely if outside `box`): while the block at the position is **replaceable by structures** and its y is greater than `level.minY + 1`: `setBlock(pos, state, 2)` and step down one block |
| `isReplaceableByStructures(state)` | air, or a liquid, or glow lichen, or seagrass, or tall seagrass |
| `createChest(level, box, random, x, y, z, lootTable)` | world position; calls the position form with no forced state |
| `createChest(level, box, random, pos, lootTable, state)` | false if `pos` is outside `box` or already holds a chest; if `state` is null use `reorient` of a default chest; `setBlock(pos, state, 2)`; if a chest block entity is present, set its loot table to `lootTable` with seed `random.nextLong()`; true |
| `createDispenser(level, box, random, x, y, z, facing, lootTable)` | false if the position is outside `box` or already a dispenser; else `placeBlock` a dispenser with the given `FACING`, set its block entity's loot table with seed `random.nextLong()`, true |
| `reorient(level, pos, chestState)` | below |

**Shape-check blocks** (12): nether brick fence, torch, wall torch, and the fences of oak, spruce, dark oak, pale oak, acacia, birch
and jungle, ladder, iron bars. (The cherry, mangrove and bamboo fences and the nether-brick-like blocks other than the fence are not in
the set.)

**`reorient`** orients a chest state by its surroundings. Scan the four horizontal neighbours of `pos` in the order `NORTH, EAST,
SOUTH, WEST`: if any neighbour is a chest, return the state unchanged. Otherwise a neighbour that "renders solid" (`isSolidRender`) is
a candidate: the first one becomes the candidate direction, a second solid neighbour clears the candidate and ends the scan
(`found` = none). If a unique candidate exists, return the state with `FACING` set to the **opposite** of the candidate. Otherwise
start with `d` = the state's current `FACING`, `p = pos + d`; while `p` renders solid, change `d` in this fixed sequence, retesting after
each: first `d = opposite(d)`, then `d = clockwise(d)`, then `d = opposite(d)` (each step only if the position at the current `d`
is solid); return the state with `FACING = d`. (At most the three changes are made, then the result is used whether or not the final
position is solid.)

### 6.6 `StructurePiecesBuilder` and `PiecesContainer`

`StructurePiecesBuilder` is an ordered list of pieces. `addPiece(piece)` appends. `findCollisionPiece(box)` returns the first piece (in
list order) whose box intersects `box`, else null. `offsetPiecesVertically(dy)` moves every piece by `(0, dy, 0)`. `getBoundingBox()` is
the union of all piece boxes (it is an error to ask for it with no pieces). `isEmpty()`, `clear()`, and `build()` (an immutable copy
as a `PiecesContainer`).

Two vertical placement helpers used by underground and ocean generators:

* `moveBelowSeaLevel(seaLevel, minY, random, offset)`: `cap = seaLevel - offset`; `top = ySpan + minY + 1` where `ySpan` is the builder
  box's height; if `top < cap` then `top = top + random.nextInt(cap - top)`; `dy = top - box.maxY`; apply `offsetPiecesVertically(dy)`;
  return `dy`.
* `moveInsideHeights(random, minY, maxY)`: `room = maxY - minY + 1 - ySpan`; `newMin = (room > 1) ? minY + random.nextInt(room) : minY`;
  shift all pieces by `newMin - box.minY`.

`PiecesContainer` (a record around an immutable list): `isEmpty()`, `isInsidePiece(pos)` (any piece box contains `pos`),
`calculateBoundingBox()` (the union of the boxes; it is an error with no pieces), `pieces()`, and the save and load of section 6.7.

### 6.7 Serialization of pieces

Piece tag (`StructurePiece.createTag`), a compound:

| Key | Type | Value |
|---|---|---|
| `id` | string | the namespaced registry key of the piece type, e.g. `minecraft:mscorridor` |
| `BB` | int array (6) | the box, section 6.3 |
| `O` | int | `-1` for a null orientation, else the direction's 2D data value: `SOUTH` 0, `WEST` 1, `NORTH` 2, `EAST` 3 (read from the `Direction` constants' third constructor argument; decoding is `values[abs(v mod 4)]`) |
| `GD` | int | `genDepth` |
| ... | | type-specific keys added by `addAdditionalSaveData` (36-2 to 36-10; `ScatteredFeaturePiece` adds `Width`, `Height`, `Depth`, `HPos`) |

Reading the base fields (`StructurePiece(type, tag)`): `GD` defaults to 0, `BB` must be present (a missing or invalid box is a load
failure for that piece), `O` defaults to 0 (south), `-1` means null; then `setOrientation`.

`PiecesContainer.save` writes a list of piece tags in order. `PiecesContainer.load(list, context)`: for each entry, read `id`
(default empty), lower-case it, parse it as an identifier, apply the **rename table** (below), look it up in the piece registry; an
unknown id logs an error and **skips** the piece; otherwise the type's loader reads the piece (any exception while loading logs the id
and skips the piece); the result is the list of the loaded pieces (a start whose pieces all fail to load is then invalid). Rename
table (old id to current, all in the default namespace): `nvi`, `pcp`, `bastionremnant` and `runtime` each load as `minecraft:jigsaw`.

The `StructurePieceSerializationContext` bundle carries the resource manager, registry access and the structure template manager
(the loader form F receives all; T receives the template manager; C receives none).

---

## 7. Chunk integration

### 7.1 Where starts and references live

Every chunk (`ChunkAccess`) has two maps: **starts** (`Structure -> StructureStart`, the starts generated **in this chunk**, i.e. whose
`chunkPos` equals this chunk) and **references** (`Structure -> set of packed chunk positions`, the chunks **whose starts' boxes reach
into this chunk** for that structure). A packed chunk position is `(x & 0xFFFFFFFF) | ((z & 0xFFFFFFFF) << 32)` (read in `ChunkPos.pack`: both ints masked with `4294967295`, the z half shifted left by 32 and or-ed in). Setting a start, or adding a reference, marks the chunk unsaved.

### 7.2 Stage handling

The generation pyramid's relevant stages (the order and neighbour needs are in 10 section 11.1; this section adds what they do):

| Stage | Needs | Action for structures |
|---|---|---|
| `STRUCTURE_STARTS` | none | `createStructures` (section 5.2) for the chunk, if generating (not when the chunk was loaded from storage); then "starts available" notification |
| `STRUCTURE_REFERENCES` | `STRUCTURE_STARTS` of the chunks within radius 8 | `createReferences` (section 7.4), in a region view of the neighbourhood |
| `BIOMES`, `TERRAIN` | `STRUCTURE_STARTS` within radius 8 | `TERRAIN` builds the beardifier from the starts around the chunk (section 9) |
| `FEATURES` | `STRUCTURE_STARTS` within 8 | `applyBiomeDecoration`: structures per step, then features (section 8) |

### 7.3 Chunk NBT

The chunk compound's `structures` entry (07 section 7, "On-disk chunk NBT", row `structures`) is `{ "starts": {...}, "References": {...} }`:

* `starts`: a compound keyed by the structure's registry id string (e.g. `minecraft:village_plains`), each value being the start's tag
  (`StructureStart.createTag`): `id` (string: the structure id, or the literal `INVALID` for an invalid start, in which case the
  compound contains only `id`), `ChunkX` (int), `ChunkZ` (int), `references` (int), `Children` (list of piece tags, section 6.7).
* `References`: a compound keyed by the structure id, each value a **long array** of packed chunk positions; entries with an empty set
  are not written.

Loading: `starts` entries whose key does not parse or does not name a registered structure are logged and dropped; an entry whose
id is `INVALID` loads as the shared invalid start; a start that fails to load (exception) is dropped; for an `ocean_monument` the
piece list is regenerated after load (36 sibling). `ChunkX`, `ChunkZ`, `references` default to 0 and `Children` to an empty list.
References: keys that do not name a registered structure are logged and dropped; within each long array, any packed position whose
chunk is at Chebyshev distance **greater than 8** from the chunk being loaded is logged and dropped.

(An older location of the same data, `Level.Structures.Starts`, and a root-level `structures.starts`, are read only by
`StructureCheck`'s lightweight scan, section 7.6.)

### 7.4 `createReferences`

Run for chunk C = (cx, cz) in stage `STRUCTURE_REFERENCES` with a view of the surrounding region:

For `x` from `cx - 8` to `cx + 8` (outer) and `z` from `cz - 8` to `cz + 8` (inner), let `S` be the chunk at (x, z); for each start of
`S` (any structure; the iteration order of the map is not defined): if the start is valid and its **bounding box** (the adjusted one of
section 5.6) intersects the horizontal square of C (`minBlockX .. minBlockX + 15` by `minBlockZ .. minBlockZ + 15`, x and z only),
add the reference (packed position of S) to C's reference set for that structure. The radius 8 is why a start that is larger than 8
chunks in some direction cannot be fully referenced; no structure is that large.

So the references of a chunk answer "which starts could have blocks here", and `StructureManager` (section 7.5) reads them.

### 7.5 `StructureManager` queries

| Query | Definition |
|---|---|
| `startsForStructure(cx, cz, predicate)` / `(cx, cz, structure)` | read C = chunk (cx, cz) **at least up to `STRUCTURE_REFERENCES`**; for each structure in its references that satisfies the predicate (or the one structure), look up each referenced chunk **at least up to `STRUCTURE_STARTS`**, take that structure's start there, keep it if valid. Returns an immutable list (referenced chunks in set order) |
| `getStartForStructure(structure, chunkAccess)` / `setStartForStructure` / `addReferenceForStructure` | direct access to the chunk's maps |
| `shouldGenerateStructures()` | the world option "generate structures" |
| `getStructureAt(pos, structure)` and `getStructureAt(pos, HolderSet)` (two overloads) | the first start from `startsForStructure(chunk of pos, ...)` whose **bounding box** (adjusted) contains `pos`; else the invalid start |
| `getStructureWithPieceAt(pos, tag / set / predicate)` and `getStructureWithPieceAt(x, y, z, structure)` (four overloads in total) | the first start from `startsForStructure` (filtered by the tag, set or predicate) for which `structureHasPieceAt(pos, start)`; else the invalid start |
| `structureHasPieceAt(pos, start)` | any piece's own box contains `pos` |
| `getAllStructuresAt(pos)` | the references map of the chunk of `pos` (structure to set of packed start chunks), read up to `STRUCTURE_REFERENCES`; **no box test** |
| `checkStructurePresence(chunkPos, structure, placement, skipReferenced)` | `StructureCheck.checkStart` (section 7.6) |
| `addReference(start)` | `start.addReference()` and `StructureCheck.incrementReference(start.chunkPos, start.structure)` |
| `forWorldGenRegion(region)` | the same manager reading chunks through a generation region (used by `createReferences` and decoration) |

Because `getAllStructuresAt` returns every structure that merely **references** the chunk, callers that need containment of a block
must apply their own box test (section 10 does).

### 7.6 `StructureCheck`

A per-dimension cache that answers "does chunk (x, z) hold a start of structure S" **without loading the chunk**, used by the locate
search (section 11). State: `loadedChunks` (packed chunk to a map `Structure -> references int`, filled by reading chunk data or by
generation events), `featureChecks` (per structure, packed chunk to boolean: the memoised result of "could this structure be created
here"), `chunksWithoutStartsInStorage` (a set that is **cleared whenever it reaches 131072 entries**, then the current chunk is added).
Constants: the stored marker for "no start" is `-1`.

`checkStart(chunkPos, structure, placement, skipReferenced)`:

1. If `loadedChunks` knows the chunk, answer from it (step 6).
2. Else, if the chunk is not in `chunksWithoutStartsInStorage`: try to read the chunk's start data from storage with a partial NBT scan
   of the three possible locations (`DataVersion`, `Level.Structures.Starts`, `structures.starts`), run the partial data fixer on it
   (any failure returns `CHUNK_LOAD_NEEDED`), build the structure-to-references map from the `starts` entries whose `id` is not
   `INVALID` (a `references` int, default 0; unknown structure keys skipped; an empty `starts` compound gives the shared empty
   map), store it in `loadedChunks` (removing the chunk from the "without starts" set and dropping the chunk's memoised
   `featureChecks`), and answer from it. If nothing was found in storage for this chunk, add it to the "without starts" set
   (after the size reset) and continue.
3. If `placement.applyAdditionalChunkRestrictions(x, z, seed)` is false, return `START_NOT_PRESENT`.
4. Look up (or compute and memoise) `canCreateStructure(chunkPos, structure)`: build a generation context with the structure's biomes
   as the valid-biome predicate and ask `findValidGenerationPoint`; true iff a stub results (this runs the structure's real
   generator up to the stub, without building pieces).
5. If it cannot be created return `START_NOT_PRESENT`; else `CHUNK_LOAD_NEEDED` (the caller must load the chunk to know).
6. Answer from a references map: the structure's value is `-1` or absent: `START_NOT_PRESENT`; present: if `skipReferenced` is true and the
   value is not 0, `START_NOT_PRESENT`; otherwise `START_PRESENT`.

`onStructureLoad(chunkPos, starts)` records the valid starts' `references` values into `loadedChunks` when a chunk is loaded or
generated; `incrementReference(chunkPos, structure)` increments the stored count (creating the map if needed) and removes the chunk
from the "without starts" set.

---

## 8. Placing pieces: the structure part of decoration

`ChunkGenerator.applyBiomeDecoration(level, chunk, structureManager)` (35-1 section 6 gives the feature half): with chunk (cx, cz) and
`origin = (16 cx, 16 cz)` block corner, the **decoration seed** `d = setDecorationSeed(worldSeed, 16 cx, 16 cz)` (11 section 4,
on a Xoroshiro-wrapped `WorldgenRandom`, 35-1 section 5.1). Debug-only early exit (read): the method returns at once, before any structure or feature step, for a chunk where `SharedConstants.debugVoidTerrain(chunkPos)` is true (a function of the two debug flags of section 4.6.1; off in normal operation). For each decoration step index `s` from 0 up (the loop runs
`max(feature-step count, number of GenerationStep values)` steps), when `structureManager.shouldGenerateStructures()`:

1. Take the structures whose `step` ordinal equals `s`, in **registry listing order** of `worldgen/structure` (grouped by step ordinal;
   a step with no structures contributes nothing).
2. For the k-th of them (k from 0 within this step): `setFeatureSeed(d, k, s)` (`setSeed(d + k + 10000 * s)`), then for every start of that
   structure returned by `startsForStructure(cx, cz, structure)` (section 7.5; the starts that reference this chunk), call
   `start.placeInChunk(level, structureManager, generator, random, writableArea, chunkPos)`.
3. The feature placements of step `s` follow (35).

`writableArea` is the box `(chunkMinX, level.minY + 1, chunkMinZ)` to `(chunkMinX + 15, level.maxY, chunkMinZ + 15)` of the
chunk's generation height accessor: the lowest layer of the level is never written by structures. The seed is set once per structure
(not per start), so several starts of the same structure referencing this chunk consume one random stream in turn.

`StructureStart.placeInChunk` (section 5.6):

1. If the start has no pieces, return.
2. Let `box0` be the first piece's box and `centre` its `getCenter()`; the **pivot** is `(centre.x, box0.minY, centre.z)` (the first piece, not
   the union).
3. For each piece in list order whose box intersects the writable area (full 3-D intersection with the area box): call
   `piece.postProcess(level, structureManager, generator, random, writableArea, chunkPos, pivot)`. The writable area passed on is the
   chunk's box, so the piece clips its own writes to this chunk (section 6.5).
4. Then `structure.afterPlace(level, structureManager, generator, random, writableArea, chunkPos, pieces)` once per chunk (default none).

Because every piece box that touches the chunk is placed with the same `random` in list order, and each chunk is decorated
independently, a piece's generation code must be a pure function of its own fields, the world state inside the clipped box, and
the shared `random` draws it makes in a fixed order; generators in 36-4 to 36-10 draw from `random` only as the artifact does.

---

## 9. Terrain adaptation and the beardifier

### 9.1 Meaning of the five modes

`terrain_adaptation` tells the terrain stage (`TERRAIN`, 10 section 4 and 11.1) how the pieces of a structure shape the terrain
around them, by adding a **density contribution** (the `beardifier` node of the final density function, 10 section 4.1: its value
is added after the cave and noodle combination). A positive contribution adds solid, a negative one removes terrain.

| Mode | Effect |
|---|---|
| `none` | no contribution; the structure's bounding box is not inflated (section 5.4) |
| `bury` | terrain is added in a rounded shell around the pieces so they sit inside the ground |
| `beard_thin` | terrain is added below the piece's lowest layer and removed above it, as a smooth skirt, only **the bottom** of the piece matters |
| `beard_box` | like `beard_thin` but the vertical distance is measured to the **whole box** (a piece with a roof also removes terrain above the roof, and adds nothing inside) |
| `encapsulate` | a rounded shell is added around the entire box (the structure is wrapped in terrain) |

### 9.2 Collecting the contributors for a chunk (`Beardifier.forStructuresInChunk`)

For chunk P = (px, pz) with minimum block corner `(bx, bz)`:

1. `starts = startsForStructure(px, pz, predicate: structure.terrain_adaptation != none)` (section 7.5). If empty, the beardifier is
   the shared empty one (value 0 everywhere).
2. For each start (adaptation `a` = its structure's mode) and each piece of it, in order; consider the piece only if it
   `isCloseToChunk(P, 12)` (its box within 12 blocks of the chunk in x and z):
   * if the piece is a **jigsaw piece** (`PoolElementStructurePiece`, 36-3) with element projection `RIGID`: add a **rigid** record
     `{ box = piece box, adjustment = a, groundLevelDelta = piece.getGroundLevelDelta() }` and extend the affected box by the piece
     box. Then, for **every** jigsaw piece (rigid or not), for each of its junctions (source x, source ground y, source z): if
     `bx - 12 < srcX < bx + 15 + 12` and `bz - 12 < srcZ < bz + 15 + 12` (both strict), add the junction to the junction list and extend
     the affected box with the single-block box at `(srcX, srcGroundY, srcZ)`;
   * any other piece: add a rigid record `{ piece box, a, 0 }` and extend the affected box.
3. If no rigid or junction record was added, the beardifier is the empty one; otherwise its **affected box** is the union of everything
   added, `inflatedBy(24)`, and the record lists are immutable copies.

The "close to chunk" margin 12 and the affected-box inflation 24 are the kernel radius (12) and its diameter (24) below.

### 9.3 The value at a block (`sampleValue(x, y, z)`)

Zero if the affected box does not contain `(x, y, z)`. Otherwise the float sum of the contributions of every rigid record then every
junction (a float accumulator starting at 0.0, added in list order, single precision):

**Rigid record** with box `B`, mode `a`, delta `g`:

| Quantity | Definition |
|---|---|
| `dx` | `max(0, B.minX - x, x - B.maxX)` (distance outside the box along x, 0 inside) |
| `dz` | `max(0, B.minZ - z, z - B.maxZ)` |
| `bottom` | `B.minY + g` |
| `yb` | `y - bottom` (signed; negative below the bottom) |
| `dy` | for `none`: 0; for `bury` and `beard_thin`: `yb`; for `beard_box`: `max(0, bottom - y, y - B.maxY)`; for `encapsulate`: `max(0, B.minY - y, y - B.maxY)` |

| Mode | Contribution |
|---|---|
| `none` | 0 |
| `bury` | `bury(dx, dy / 2, dz)` (`dx`, `dy / 2.0`, `dz` as floats) |
| `beard_thin` | `0.8 * beard(dx, dy, dz, yb)` |
| `beard_box` | `0.8 * beard(dx, dy, dz, yb)` |
| `encapsulate` | `0.8 * bury(dx / 2, dy / 2, dz / 2)` (all as floats) |

**Junction** `(srcX, srcGroundY, srcZ)`: `jx = x - srcX`, `jy = y - srcGroundY`, `jz = z - srcZ`; contribution `0.4 * beard(jx, jy, jz, jy)`.

**`bury(a, b, c)`** (floats): `L = a*a + b*b + c*c` (single precision); `0` if `L >= 36`; else `1 - sqrt(L) / 6` (the square root is the
double-precision root rounded to float).

**`beard(dx, dy, dz, yb)`** (ints): `ix = dx + 12`, `iy = dy + 12`, `iz = dz + 12`; if any of them is outside `0 .. 23`, the
result is 0. Otherwise `yf = yb + 0.5` (float), `L = dx*dx + yf*yf + dz*dz` (float), `v = (-yf * fastInvSqrt(L / 2)) / 2` (float;
`fastInvSqrt` is the double-precision approximate inverse square root defined below, converted to float), and the result is
`v * KERNEL[iz * 576 + ix * 24 + iy]`.

**`fastInvSqrt(x)`** (double): `h = 0.5 * x`; reinterpret `x` as a 64-bit integer `i`; `i = 6910469410427058090 - (i >> 1)` (arithmetic
shift); reinterpret back as a double `y`; return `y * (1.5 - h * y * y)` (one Newton step).

**The kernel** is a 24 x 24 x 24 float table (13824 entries) built once: for `i`, `j`, `k` from 0 to 23 (i outermost, k innermost),
`KERNEL[i*576 + j*24 + k] = (float) exp(-(a*a + (b + 0.5)*(b + 0.5) + c*c) / 16)` where `a = j - 12`, `b = k - 12`, `c = i - 12`, and
`exp` is `Math.pow(e, -d/16)` with `e = 2.718281828459045` (double). So the table's x index is the middle one, y is the fastest, z
the slowest. `beard` multiplies the kernel at the *distance* indices, so its y-extent is 24 cells (12 below and 11 above the bottom
for `dy`).

(Reading note: in `beard_thin` and `bury` the vertical offset `dy` equals the signed `yb`, so the terrain **under** the bottom layer
produces a positive contribution and the terrain **above** it a negative one; `beard_box` and `encapsulate` use a non-negative `dy`,
so the vertical profile is symmetric around the box.)

### 9.4 How the terrain stage evaluates it

The artifact evaluates the beardifier with a volume sampler: for an interpolation volume (a grid of `sizeX x sizeY x sizeZ` sample
points at block positions `minBlock + index * step`, the cell sizes of the interpolated density are parameters `cell_size_xz` and `cell_size_y` of 10 section 4.1; the data does not give them: `noise_settings/overworld.json` has a `noise` block with only `min_y` (-64) and `height` (384), the nether file 0 and 128, and neither has `size_horizontal` or `size_vertical`; the figure of 4 x 8 x 4 blocks per cell is (recalled, not verified), Open question 10), `sampleVolume` first fills the
output buffer with 0.0; then, if the affected box intersects the volume, it computes the index range of grid points whose block
position lies inside the affected box (`floorDiv` of the offsets by the steps, clamped to the volume) and writes
`sampleValue`-equivalent values at exactly those grid points, looping `z` outermost, then `x`, then `y` innermost (loop order read in the bytecode; the `DensityVolume` record holds `size`, `minBlock` and `stepBlock` per axis). The observable result is
identical to evaluating section 9.3 at every grid point that the terrain interpolation reads; points outside the affected box read 0.
The interpolation of the rest of the density function is unchanged (10 section 4).

The beardifier's context key name is `beardifier`; its value range is unbounded (`Interval.INFINITE`).

---

## 10. Spawn overrides

`StructureSpawnOverride` is `{ "bounding_box": "piece" | "full", "spawns": WeightedList of SpawnerData }` (the spawner data codec is 18
section 6.6: entity type, weight in the list, min and max group size). The map in a structure's settings is keyed by mob category.

Query `ChunkGenerator.getMobsAt(level, structureManager, category, pos)`, used by the natural spawner (18, 21):

1. Take `structureManager.getAllStructuresAt(pos)` (section 7.5: every structure whose start **references** the chunk of `pos`; iteration
   order of that map is not defined, see Open question 5).
2. For each structure in that map: look up `spawn_overrides[category]`; skip when absent. Otherwise test **each referencing start** (via
   `fillStartsForStructure`, which loads the start from its chunk and keeps only valid ones): for `bounding_box = piece`, the start
   qualifies when some piece's own box contains `pos` (`structureHasPieceAt`); for `full`, when the start's `getBoundingBox()` contains `pos` (the
   **adjusted** box of section 5.6: inflated by 12 for a terrain-adapting structure). The first structure with any qualifying start
   wins: return its `spawns` list.
3. If no structure wins, return the normal list: `level.environmentAttributes().getValue(NATURAL_MOB_SPAWNS, pos)` of the biome at `pos`
   (a `MobSpawnSettings`), restricted to `category` (`getMobsToSpawn(category)`; 18 section 6.6).

Spawn overrides replace, not add to, the biome's list for that category at positions they cover.

---

## 11. Locate (`ChunkGenerator.findNearestMapStructure`)

Inputs: the level, a set of structure holders, an origin block position, `searchRadius` (in cells, see below), and
`skipReferenced`. Returns the nearest start's locate position and the holder, or none. This is the engine under `locate structure`
(16 section 7.7), the explorer-map items and the eye of ender.

1. Return none when the debug feature-disable flag is set or when the world option "generate structures" is off.
2. Group the (structure, placement) pairs of the set (from `getPlacementsForStructure`, section 4.1) by placement object: map
   `placement -> set of structure holders`. If the map is empty, return none.
3. For every `concentric_rings` placement: `getNearestGeneratedStructure(set, level, placement)`: iterate the placement's ring chunk
   list; for each ring chunk compute the squared distance from the origin to the block `(ringChunk.x * 16 + 8, 32, ringChunk.z * 16 + 8)`
   (centre of the chunk at y = 32); only the first candidate, or a candidate strictly closer than the best so far, is examined by
   `getStructureGeneratingAt` (below); a hit becomes the best. The best hit over all rings placements is kept, with its squared
   distance (from the origin to the **locate position**, not to the ring chunk centre).
4. Collect every `random_spread` placement. Then for `r = 0, 1, 2, ..., searchRadius` (inclusive), run **ring `r`** over all collected
   placements: with `(ox, oz)` the origin's chunk, for `ix` from `-r` to `r` (outer) and `iz` from `-r` to `r` (inner), consider only cells on the
   border of the square (`|ix| = r` or `|iz| = r`); for each such cell the candidate chunk is `getPotentialStructureChunk(seed,
   ox + spacing * ix, oz + spacing * iz)` (section 4.3; so the cell grid is offset from the origin's cell in whole spacings), and the **first**
   candidate (in loop order) for which `getStructureGeneratingAt` succeeds is that placement's answer for this ring (the search over
   the placement's cells stops at that first hit; later cells of the same ring are not compared). Each answer's squared distance
   from the origin to its locate position is compared with the best so far (strictly less replaces it). If any placement produced an
   answer in ring `r`, return the best found overall and stop; otherwise continue with `r + 1`.
5. After the last ring, return the best (the rings-placement result from step 3, or none).

`getStructureGeneratingAt(set, level, structureManager, skipReferenced, placement, chunkPos)`: for each structure of the set in order:
`result = structureManager.checkStructurePresence(chunkPos, structure, placement, skipReferenced)`; `START_NOT_PRESENT` goes to the next
structure; if `skipReferenced` is false and the result is `START_PRESENT`, return `(placement.getLocatePos(chunkPos), holder)` without loading
the chunk; otherwise load the chunk at stage `STRUCTURE_STARTS`, read the structure's start there, and if it is valid and
(`skipReferenced` is false or `tryAddReference(start)` succeeds, i.e. `start.canBeReferenced()` and then `addReference`), return
`(placement.getLocatePos(start.chunkPos), holder)`. None found: null.

The `skipReferenced` option is true for map items that mark a structure as "found" once so that two maps do not point at the same
one (a start can be referenced by one map: `canBeReferenced` allows one reference).

---

## 12. Worked examples

All numbers in this section were computed by hand arithmetic from the rules above (a short script was used to avoid slips); they are
test vectors for an implementation, **not** values read from the artifact. Example parameter values (spacing, separation, salt,
distance, counts, weights) are invented inputs, not data-pack values.

### 12.1 Random spread

`spacing = 32`, `separation = 8` (so `limit = 24`), `salt = 12345`, `levelSeed = 0`. The cell of chunk `(cx, cz)` is `(floorDiv(cx, 32),
floorDiv(cz, 32))`; the cell's seed is `rx * 341873128712 + rz * 132897987541 + 0 + 12345`.

| Chunk | Cell | `linear` potential chunk | `triangular` potential chunk |
|---|---|---|---|
| (0, 0) | (0, 0) | (19, 16) | (17, 10) |
| (5, 7) | (0, 0) | (19, 16) (same cell, same answer) | (17, 10) |
| (-1, -1) | (-1, -1) | (-18, -26) | (-22, -26) |
| (40, -33) | (1, -2) | (33, -44) | (42, -53) |

So chunk (0, 0) is not a structure chunk (the potential chunk of its cell is (19, 16)); chunk (19, 16) is. With `levelSeed = 77` and
linear spreading, cell (0, 0) gives (17, 3).

### 12.2 Per-chunk seed and weighted choice

`setLargeFeatureSeed(0, 0, 0)` then `nextInt(100)` = 60 (both products are 0 so the seed is the plain seed 0 scramble). For a set
with weights `[2, 1, 1]` (total 4): chunk (0, 0), seed 0: `nextInt(4)` = 2; subtract 2 gives 0 (not negative), the index advances;
subtract 1 gives -1: the entry at index **1** is chosen. If it fails, it is removed and the total becomes 3. Chunk (3, -2),
seed 42: `nextInt(4)` = 0; subtract 2 gives -2: index **0** is chosen.

### 12.3 Concentric rings (positions before the biome snap)

`distance = 32`, `spread = 3`, `count = 12`, seed 0. The `nextDouble` stream of the ring list's generator gives the following raw
ring chunks `(rx, rz)` (ring number, ring size at that ring, radius):

| i | Ring | Size | Radius | `(rx, rz)` |
|---|---|---|---|---|
| 0 | 0 | 3 | 107.243 | (-13, -106) |
| 1 | 0 | 3 | 132.035 | (121, 52) |
| 2 | 0 | 3 | 114.657 | (-92, 69) |
| 3 | 1 | 6 | 350.335 | (-75, -342) |
| 4 | 1 | 6 | 301.996 | (223, -203) |
| 5 | 1 | 6 | 291.728 | (278, 89) |
| 6 | 1 | 6 | 323.739 | (69, 316) |
| 7 | 1 | 6 | 288.359 | (-213, 194) |
| 8 | 1 | 6 | 312.864 | (-298, -95) |
| 9 | 2 | 4 | 510.979 | (-138, -492) |
| 10 | 2 | 4 | 530.652 | (511, -143) |
| 11 | 2 | 4 | 539.111 | (145, 519) |

(Ring 0 completes at i = 2: `S = 3 + 6/2 = 6`, clamp `min(6, 12 - 2)` = 6. Ring 1 completes at i = 8: `S = 6 + 12/3 = 10`, clamp
`min(10, 12 - 8)` = 4, so ring 2 has 4 positions.) Ring size sequence with no clamp: 3, 6, 10, 15, 21, 28. For
seed 12345 the first positions are (-105, 124), (-39, -107), (114, 21).

### 12.4 Piece geometry

`orientBox(10, 64, 20, offX = -1, offY = -4, offZ = 0, width = 5, height = 6, depth = 7, direction)`:

| Direction | Result box `(minX, minY, minZ) - (maxX, maxY, maxZ)` |
|---|---|
| `SOUTH` | (9, 60, 20) - (13, 65, 26) |
| `NORTH` | (9, 60, 14) - (13, 65, 20) |
| `WEST` | (4, 60, 19) - (10, 65, 23) |
| `EAST` | (10, 60, 19) - (16, 65, 23) |

`makeBoundingBox(100, 64, 200, NORTH, width 10, height 5, depth 15)` is (100, 64, 200) - (109, 68, 214); the same call with `EAST` is
(100, 64, 200) - (114, 68, 209). For the first box with orientation `NORTH`, local (3, 2, 4): world x = 100 + 3 = 103, world z =
`maxZ - z` = 214 - 4 = 210, world y = 64 + 2 = 66. With `WEST` and a box (100, 64, 200) - (114, 68, 209) the local (3, 2, 4) maps to world x =
`maxX - z` = 114 - 4 = 110, world z = `minZ + x` = 200 + 3 = 203.

`BoundingBox` center of (100, 64, 200) - (109, 68, 214): x = 100 + 10/2 = 105, y = 64 + 5/2 = 66, z = 200 + 15/2 = 207.

### 12.5 Beardifier values

All single precision where stated; box `B` below stands for a piece with `groundLevelDelta = 0`.

| Case | Inputs | Result |
|---|---|---|
| kernel centre | `KERNEL(a=0, b=0, c=0)` | 0.984496 (`exp(-0.25/16)`) |
| kernel | `KERNEL(a=3, b=-2, c=1)` | 0.465043 |
| `beard` right at the bottom edge | `beard(0, 0, 0, yb = 0)` | -0.695970 |
| `beard` two blocks outside in x | `beard(2, 0, 0, yb = 0)` | -0.131402 |
| `beard` below the bottom | `beard(0, -4, 3, yb = -4)` | +0.142014 |
| `beard` above the bottom | `beard(0, 5, 0, yb = 5)` | -0.106574 |
| `beard` out of the kernel | `beard(12, 0, 0, 0)` | 0 (index 24 is outside 0..23) |
| `bury` | `bury(0, 0, 0)`, `bury(3, 2, 0)`, `bury(6, 0, 0)` | 1.0, 0.399075, 0.0 |
| `beard_thin` | at `(dx, dz) = (0, 0)`, 5 above the bottom | `0.8 * -0.106574` = -0.085259 |
| junction | `jx = 1, jy = -3, jz = 2` | `0.4 * beard(1, -3, 2, -3)` = `0.4 * 0.260653` = 0.104261 |

### 12.6 References and the stage radius

A start generated in chunk (10, 10) whose adjusted box spans x 130 to 190 and z 150 to 170 references the chunks with x from 8 to 11 and
z from 9 to 10 (the chunk columns `x >> 4` of 130 and 190 are 8 and 11; `z >> 4` of 150 and 170 are 9 and 10). The reference is added
when a chunk (cx, cz) with `|cx - 10| <= 8` and `|cz - 10| <= 8` runs `createReferences`; chunks farther than 8 never learn of it.

---

## 13. Validation: checkable facts

An implementation is consistent with this document when all of the following hold.

1. The static registries have 16, 3 and 56 entries with the ids and names of sections 2.2 to 2.4; the piece registry key of the
   mineshaft corridor is `minecraft:mscorridor` and a stored piece id `minecraft:MSCorridor` also loads (lower-casing on read).
2. A stored piece with id `minecraft:nvi`, `pcp`, `bastionremnant` or `runtime` loads as the jigsaw piece type.
3. A piece tag has the keys `id`, `BB` (int array of 6: min x, min y, min z, max x, max y, max z), `O` (-1, or 0 south / 1 west / 2 north /
   3 east) and `GD`; a start tag has `id`, `ChunkX`, `ChunkZ`, `references`, `Children`; an invalid start is `{id: "INVALID"}`.
4. Random spread: the example table of section 12.1 (any rewrite of the helper that changes the order of the two draws or the integer
   division for triangular changes the `(17, 10)` result of cell (0, 0)).
5. Frequency reduction `legacy_type_1` discards one `nextInt()` before the test and uses the truncated `1 / frequency`.
6. `getPotentialStructureChunk` is a pure function of `(levelSeed, spacing, separation, spread type, salt, cell)`; both results for
   negative cells use floor division (chunk (-1, -1) is in cell (-1, -1)).
7. A set with several entries generates at most one entry per chunk; with weights `[2, 1, 1]` at chunk (0, 0) seed 0 the first choice is the
   second entry.
8. A failed generation attempt leaves no start in the chunk (no invalid start is stored); a set with a valid start in the chunk is never
   tried again.
9. The structure's stub position is tested for biome before the pieces are generated, with quart coordinates `(x >> 2, y >> 2, z >> 2)`.
10. `StructureStart.getBoundingBox` of a start with terrain adaptation is the union of its pieces inflated by 12; `bounding_box: full`
    spawn overrides use that box, `piece` uses the pieces' own boxes.
11. `getStructureWithPieceAt` returns a start only when a **piece** box contains the position; `getStructureAt` uses the start's box.
12. Decoration places a structure's starts with `setFeatureSeed(decorationSeed, k, s)` where `k` is the structure's index within its step
    in registry order and `s` the step ordinal; the writable area excludes the lowest layer of the level.
13. `orientBox` and `makeBoundingBox` match the tables of section 12.4; `worldX`/`worldZ` match section 6.4.
14. Beardifier: section 12.5; the value is exactly 0 outside the affected box; the beardifier of a chunk with no adapting start is 0.
15. Concentric rings: for count 0 the list is empty; the ring size recurrence is `S + (2S)/(ring+1)` clamped by the remaining count; the
    search draws are only from the forked sources.
16. References beyond Chebyshev distance 8 are discarded on load; one reference at most per start (`canBeReferenced` is `references < 1`).

---

## Open questions

1. **Dimension origin of the noise generator.** `NoiseSpawnFinder.findSpawnPosition` (the spawn search over the noise settings'
   `spawn_target` parameter boxes) was not read, so the one chunk of a `dimension_origin` placement is only known as "the chunk
   containing the found spawn position, or (0, 0) without spawn targets". Needs a round on the spawn finder (shared with the world spawn
   point).
2. **Biome resolver details in the ring search.** The ring-position biome snap (section 4.6.1) samples the multi-noise source at
   quart coordinates with y = 0 through a caching resolver; the exact climate evaluation (10 section 7) was cited, not re-read for this
   path. The search radius 112 and the reservoir rule were read.
3. **Names and tags of data-defined structure fields** (type-specific fields of `jigsaw`, the structure NBT, pool and processor
   schemas) are in the siblings 36-2 to 36-10 and are not verified here.
4. **Tag consumers.** Which engine reads each of the 33 structure tags (section 2.6): the attribution after the list is inferred
   from the tag names, not traced to call sites.
5. **Order of structures in `getAllStructuresAt`.** The reference map of a chunk is a hash map keyed by structure objects, so when
   two structures with a spawn override for the same category overlap one chunk, which wins is not determined by the data order
   (inferred from the map type; the chunk's map class was not read to the end). Implementations should pick registry order and
   record it.
6. **Numerical exactness.** Ring positions use `Math.cos`/`Math.sin` and `Math.round`; a platform whose sine and cosine differ from
    the JVM's in the last place can differ at exact half-way rounding cases. The beardifier uses `Math.pow` and `Math.sqrt` (double) and
    float arithmetic; the kernel table values were not compared against a run.
7. **Examples unverified.** Every number in section 12 comes from hand arithmetic (with a small script) from the rules, not from running
    the artifact; they should be re-checked once a reference run exists.
8. **`Heightmap` semantics for ground fitting.** `ScatteredFeaturePiece` uses `level.getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, pos).y`; whether that
    y is the first free block above the surface or the surface block itself is defined in 35-1 section 4.2 (cited, not re-read).
9. **`StructureCheck` partial data-fixer path.** The scan accepts three layouts (`Level.Structures.Starts`, `structures.starts`
    plus `DataVersion`) and runs a partial data fixer before reading; the fixer itself (only relevant for old worlds) is out of scope.
10. **Interpolation cell size in the beardifier volume.** Section 9.4 relies on the cell sizes of the noise interpolation (4 blocks in x and z, 8 in y); the figure was not read in `Beardifier.sampleVolume` or the noise chunk in this round (searched 10 section 4.1, which gives only the `cell_size_xz` and `cell_size_y` parameters). Further read in this pass: the overworld and nether `noise_settings` files carry no cell-size fields (only `min_y` and `height`), so 10 section 4.1's `cell_size_xz` and `cell_size_y` cannot be tied to data here; they must be reconciled in 10 (the owner of the noise settings) or by reading the noise-chunk class. Marked (recalled, not verified).
11. **(Closed.)** The default `step` is read (section 3.1); nothing remains open.
12. **Debug flags: switch mechanism.** `SharedConstants` sets both flags from `debugFlag(name)` (read); how `debugFlag` obtains its value (inferred: a system property or similar operator switch) was not read. The debug path itself is out of scope.
13. **Scope not owned by 36-1.** `PostPlacementProcessor` is an interface with one `afterPlace` method and a `NONE` constant that does nothing; no other class under `levelgen/structure` refers to it (read), so it is unused. The real hook is `Structure.afterPlace(level, structureManager, generator, random, box, chunkPos, PiecesContainer)`, a no-op in the base class (section 8 calls it). Templates and processors are in 36-2; jigsaw assembly in 36-3; scattered and small structures in 36-4; mineshaft and stronghold in 36-5; ocean in 36-6; woodland mansion in 36-7; nether and end in 36-8; villages, outposts and their points of interest (`PoiTypes`, workstation registration at generation) in 36-9 section 10 (section 9 there covers chests and markers); ancient city, trial chambers, trail ruins, loot and the spawn checklist in 36-10 (titles of the siblings read; loot placement not re-checked against 26). Chunk-level `structureReferences` is declared `Map<Structure, LongSet>` but the concrete map class was not read (see 5).
