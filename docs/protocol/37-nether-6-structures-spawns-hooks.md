# 37 The Nether, part 6: structures, spawns and hooks

| Item | Value |
|---|---|
| Covers | The Nether side of structure generation and of natural spawning, as hooks: the structure sets and structure definitions that reach the Nether (`nether_complexes`: fortress and bastion remnant; `nether_fossils`; the Nether member of `ruined_portals`), the schema fields those definitions use and their defaults, the fortress piece family (classes, weights, limits, extents, ids, loot), the bastion pool graph (four variants), the Nether ruined portal setup, the biome and structure tags, the per-biome spawn lists and spawn costs of the five Nether biomes, the Nether-specific spawn predicates, and the numbers RS23 (portals) needs from the Nether. |
| Does not cover | The structure engines themselves. They are specified in the structures round (GAP-12b): placement, start creation, `createStructures` and the piece builder in 36-1 (sections 4.3, 5.2, 5.3, 6.4, 6.6); the template system and processors in 36-2; the jigsaw expander in 36-3; the ruined portal engine (stub, `findSuitableY`, processors, `postProcess`, `spreadNetherrack`, drip columns, the blackstone swap) in 36-4 section 8; the fortress growth procedure, child rules, boxes and block fills in 36-8 sections 2 to 7; the bastion's use of the jigsaw engine and its pool closures in 36-8 sections 13 to 16; and 35-6 section 10. This document repeats only what a Nether hook needs (the numbers, the stub positions, the tables) and cites those sections for the rest. The portal algorithm (RS23). Noise, biomes, carvers, surface rules and features (parts 2 to 5 of this document). The spawn engine (18 section 6, 44-2 section 8). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the JSON data and structure NBT inside the jar, with no execution. A value is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)"; every such mark is listed in the Open questions. |
| Round | RS21 (GAP-13a of [../design/README.md](../design/README.md)), scope "Part 6" |
| Operator decisions | Standard Minecraft content is the target; a COBOL tool extracts the data pack and resource pack from the user's jar, so data rows (structure JSON, template pools, processor lists, structure NBT, loot tables, tags, biome JSON) are not tabulated here beyond the few small tables the engines depend on. This document specifies the schema, the semantics and the code-defined content (the fortress piece family, the spawn predicates, the numbers). Ticket CC-0001, Decisions "World scope" and "Vanilla assets and data". |

Class names in backticks say where a fact was read; they are not the design. "37-n section m" is part n of the Nether
document (`37-nether-1-model-and-dimension-rules.md`, `37-nether-2-noise-settings-and-density.md`,
`37-nether-3-biome-source-and-climate.md`, `37-nether-4-surface-rules-and-carvers.md`,
`37-nether-5-features-and-decoration.md`). "18 section n" is [18-mob-framework.md](18-mob-framework.md), "44-2 section n" is
[44-residual-mob-questions-2-spawning-structures.md](44-residual-mob-questions-2-spawning-structures.md), "44-6 section n"
is [44-residual-mob-questions-6-nether.md](44-residual-mob-questions-6-nether.md), "21 section n" is
[21-mobs-aquatic-nether-end-bosses-and-entities.md](21-mobs-aquatic-nether-end-bosses-and-entities.md), "10 section n" is
[10-world-generation-terrain.md](10-world-generation-terrain.md). "11 section n" is
[11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md). The structures round (GAP-12b) is cited by document:
"36-1 section n" is [36-structures-1-model-placement-starts.md](36-structures-1-model-placement-starts.md), "36-2" is
`36-structures-2-templates-and-processors.md`, "36-3" is `36-structures-3-jigsaw-assembly.md`, "36-4 section n" is
[36-structures-4-scattered-and-small.md](36-structures-4-scattered-and-small.md) (the ruined portal is its section 8, the nether fossil its section 9),
and "36-8 section n" is [36-structures-8-nether-and-end.md](36-structures-8-nether-and-end.md) (fortress sections 2 to 7, bastion sections 13 to 16).
Where an earlier draft of this document left a question to the structures round, the answer is cited in section 13.

## Contents

1. What is in the Nether's structure and spawn data, and where the engines live
2. Structure sets: placement numbers and entry selection
3. Structure definitions: fields, defaults and the four Nether instances
4. The fortress piece family (index)
5. The bastion remnant: four variants as pool graphs (index)
6. The Nether ruined portal
7. The nether fossil (summary and cross-reference)
8. Tags
9. Natural spawning in the Nether
10. Interface to portals (RS23): numbers only
11. Worked examples
12. Validation
13. Open questions

## 1. What is in the Nether's structure and spawn data, and where the engines live

| Question | Answer | Where |
|---|---|---|
| Which structures can generate in the Nether | Four definitions: `fortress`, `bastion_remnant`, `ruined_portal_nether`, `nether_fossil`. The first two share one structure set (`nether_complexes`), the third is one entry of the seven-entry set `ruined_portals`, the fourth has its own set (`nether_fossils`). | sections 2, 3 |
| Data versus code | Placement numbers, biome tags, steps, spawn overrides, template pools, processor lists, loot tables and structure NBT are **data** (extracted by the tool). The fortress piece family (14 piece classes), the ruined portal setup and placement code, the nether fossil point search, the jigsaw expander and the spawn predicates are **code**. | sections 4 to 7, 9 |
| Is there a Nether-specific structure engine | Yes, three: `NetherFortressStructure` with `NetherFortressPieces` (own piece grammar, not a jigsaw), `NetherFossilStructure`, and the shared `RuinedPortalStructure` with its `in_nether` placement. The bastion remnant uses the generic `JigsawStructure`. `BastionPieces` and its sibling classes in `net.minecraft.data.worldgen` (`BastionHousingUnitsPools`, `BastionHoglinStablePools`, `BastionTreasureRoomPools`, `BastionBridgePools`, `BastionSharedPools`) are the data generators that wrote the pool JSON; the runtime reads only the JSON. Engines: fortress 36-8 sections 2 to 7, ruined portal 36-4 section 8, nether fossil 36-4 section 9, jigsaw 36-3 and 36-8 sections 13 to 16. | sections 3, 5 |
| Spawn data | The five Nether biomes carry `natural_mob_spawns` (an environment attribute with the modifier `overlay`) as in 44-2 section 7.3; nothing in the dimension type sets it. The fortress adds a `monster` override. | section 9 |
| Mob generation at chunk creation | Enabled (`disable_mob_generation` false in `noise_settings/nether`); only the `creature` list matters (strider) and the probability is the attribute default 0.1. | section 9.6 |

## 2. Structure sets: placement numbers and entry selection

The three sets read (`data/minecraft/worldgen/structure_set/*.json`):

| Set | Placement | spacing | separation | salt | Entries (weight) |
|---|---|---|---|---|---|
| `nether_complexes` | `random_spread` | 27 | 4 | 30084232 | `fortress` 2, `bastion_remnant` 3 (file order) |
| `nether_fossils` | `random_spread` | 2 | 1 | 14357921 | `nether_fossil` 1 |
| `ruined_portals` | `random_spread` | 40 | 15 | 34222645 | seven entries, weight 1 each: `ruined_portal`, `ruined_portal_desert`, `ruined_portal_jungle`, `ruined_portal_swamp`, `ruined_portal_mountain`, `ruined_portal_ocean`, `ruined_portal_nether` |

Defaults of the placement (`StructurePlacement`, `RandomSpreadStructurePlacement` codecs, read): `spread_type` defaults to
`linear`; `locate_offset` defaults to (0, 0, 0); no `frequency` or `exclusion_zone` appears in any of the three files, so
those keep their defaults (the frequency check passes always; the exclusion zone is absent). The codec validation requires
`spacing > separation` and both at most 4096 (message "Spacing has to be larger than separation").

**Candidate chunk of a region** (`RandomSpreadStructurePlacement.getPotentialStructureChunk`, read; the same rule is 36-1 section 4.3, with
`setLargeFeatureWithSalt` defined there and `setLargeFeatureSeed` in 11 section 4, over the legacy generator of 10 section 2.6), for a chunk (cx, cz):
1. `regionX = floorDiv(cx, spacing)`, `regionZ = floorDiv(cz, spacing)` (floor division: negative chunks go to negative regions).
2. A `WorldgenRandom` over `LegacyRandomSource` is seeded with `setLargeFeatureWithSalt(levelSeed, regionX, regionZ, salt)`.
3. `offX = evaluate(random, spacing - separation)` then `offZ = evaluate(random, spacing - separation)` (x first, z second).
   `evaluate` for `linear` is `nextInt(bound)`; for `triangular` it is `(nextInt(bound) + nextInt(bound)) / 2` (both
   `nextInt` calls on the same random).
4. The candidate chunk is `(regionX * spacing + offX, regionZ * spacing + offZ)`; chunk (cx, cz) is a "structure chunk" when it equals the candidate.

Consequences in the Nether: `nether_complexes` has an offset range of `27 - 4 = 23` (candidate chunk `27 * region + 0..22` on each axis, one
attempt per 27 x 27 chunk region); `nether_fossils` has `2 - 1 = 1`, so `nextInt(1)` is always 0 and the candidate is always the
chunk `(2 * regionX, 2 * regionZ)`: one attempt per 2 x 2 chunks, further limited by the soul sand valley tag (section 8);
`ruined_portals` has range 25, one attempt per 40 x 40 chunk region.

**Choosing among several entries** (`ChunkGenerator.createStructures` lambda and `tryGenerateStructure`, read; the full procedure is 36-1
section 5.2). For each structure set of the chunk, in order, two tests come before any choice:
1. If any structure of the set already has a valid start in this chunk, the whole set is skipped.
2. `placement.isStructureChunk(state, chunkX, chunkZ)` must be true (36-1 section 4.2). It is the candidate-chunk rule above together with the
   frequency reducer and the exclusion zone; the three Nether sets name neither, so they keep their defaults and only the candidate-chunk rule matters.

Then a set with a single entry tries that entry directly. With several entries:
3. Copy the entry list; seed a fresh `WorldgenRandom(LegacyRandomSource)` with `setLargeFeatureSeed(levelSeed, chunkX, chunkZ)`; `total` is the sum of the
   weights of the list (it is computed once and decreased by the weight of an entry that is removed, which is the same as re-summing).
4. Loop while the list is non-empty: `roll = nextInt(total)`; walk the list in order, subtracting each weight from `roll`, and stop at the first entry for
   which the running value falls below zero.
5. Call `tryGenerateStructure` for that entry. It passes the references count of an existing start of that structure in the chunk (0 when there is none),
   builds the structure's generation context, asks the structure for a valid generation point (which includes the biome check of section 3.0 against the
   structure's `biomes` set), and stores the start if it is valid (36-1 section 5.3).
6. On success stop; on failure remove the entry from the list, subtract its weight from `total` and repeat from step 4 with the remaining weights.

So in the Nether a fortress or bastion is attempted at most once per candidate chunk each, and a failed first pick (for example a
bastion pick in basalt deltas, section 8) falls through to the other entry with a new `nextInt`.

## 3. Structure definitions: fields, defaults and the four Nether instances

Common settings of every structure (`Structure.StructureSettings`, `settingsCodec`): `biomes` (a biome tag or list: the biomes the
start may occupy), `spawn_overrides` (map from mob category to `{bounding_box: piece|full, spawns: [...]}`, may be empty),
`step` (a generation step name: `underground_decoration` and `surface_structures` appear here), and `terrain_adaptation`
(default `none`; `beard_thin` is used by the nether fossil). `type` selects the codec.

| Structure | `type` | `biomes` | `step` | `terrain_adaptation` | `spawn_overrides` |
|---|---|---|---|---|---|
| `fortress` | `fortress` | tag `has_structure/nether_fortress` | `underground_decoration` | absent (default `none`) | `monster`, `piece`, five entries (section 9.4) |
| `bastion_remnant` | `jigsaw` | tag `has_structure/bastion_remnant` | `surface_structures` | absent (default `none`) | `{}` |
| `ruined_portal_nether` | `ruined_portal` | tag `has_structure/ruined_portal_nether` | `surface_structures` | absent (default `none`) | `{}` |
| `nether_fossil` | `nether_fossil` | tag `has_structure/nether_fossil` | `underground_decoration` | `beard_thin` | `{}` |

The step determines when the structure's pieces are written to the world relative to features (the order of the steps is 37-5 section 3 for
the Nether's feature indices and 36-1 sections 5 and 8 for structure starts and placement; 10 section 7 is the biome source and does not
cover structure steps).

### 3.0 The biome check of a start

`Structure.findValidGenerationPoint` (read) calls the structure's `findGenerationPoint`, then keeps the stub only if `GenerationContext.isValidBiome(stub)`
holds (36-1 section 5.3). That test reads the noise biome through the context's biome resolver at the stub's own position, converted with
`QuartPos.fromBlock` on x, y and z (the Nether source is three-dimensional, 37-3, so y matters), and tests it against the structure's `biomes` set.
The stub positions of the four Nether structures (read):

| Structure | Stub position (x, y, z) | Read in |
|---|---|---|
| `fortress` | (chunk min x, 64, chunk min z); y is `MAGIC_START_Y`, before the later 48 to 70 shift | `NetherFortressStructure.findGenerationPoint` |
| `bastion_remnant` | (x of the centre of the start piece's box, 33, z of the centre), centre = `(maxX + minX) / 2` and `(maxZ + minZ) / 2` in integer division; y = the sampled start height 33 because no projection is set | `JigsawPlacement.addPieces` (the stub is built there, not in `JigsawStructure`, which passes `(chunk min x, 33, chunk min z)` to `addPieces` as the start origin) |
| `ruined_portal_nether` | (chunk min x, the final y of `findSuitableY`, chunk min z); the box centre is used only to sample the surface height | `RuinedPortalStructure.findGenerationPoint` (`ChunkPos.getWorldPosition` is `(min x, 0, min z)`) |
| `nether_fossil` | (the drawn x, the found y, the drawn z) | 36-4 section 9 and 37-5 section 6 |

Consequence: the fortress and the bastion of the same candidate chunk are checked at different heights (64 and 33) and at different columns, so
they can see different biomes (section 11, example 3).

### 3.1 `fortress`

No parameters beyond the common settings. The generation point is fixed by `NetherFortressStructure.findGenerationPoint`
(read): the stub position is `(chunk min x, 64, chunk min z)` (y is the constant `MAGIC_START_Y` = 64); the pieces are built by
`generatePieces`: a `StartPiece` is created at `(chunk.getBlockX(2), chunk.getBlockZ(2))` (the block 2 inside the chunk's
minimum corner on each axis), the start piece expands its children, then, while the pending-children list is non-empty, a random pending piece
(`nextInt(size)` of the list) is removed and expanded in turn; finally `moveInsideHeights(random, 48, 70)` places the whole
structure vertically inside the interval 48 to 70. The shift rule (read in `StructurePiecesBuilder.moveInsideHeights`, and 36-1 section 6.6):
let `ySpan` be the height of the union box of all pieces and `room = 70 - 48 + 1 - ySpan = 23 - ySpan`; the new minimum y is `48 + nextInt(room)`
when `room > 1`, otherwise 48 (no draw); every piece is moved vertically by `newMinY - box.minY`. The random is the generation context's random,
the same stream that chose the pending-piece indices, and this draw is the last use of it. The biome check uses the tag `#is_nether` (all five Nether
biomes), section 8, at the stub of section 3.0. The piece grammar is in section 4; the growth procedure is 36-8 sections 2 to 4.

### 3.2 `bastion_remnant` (a `jigsaw` structure)

Fields of `JigsawStructure.CODEC` (read) and the values this structure gives them:

| Field | Meaning and default | Value here |
|---|---|---|
| `start_pool` | pool the expansion starts from | `minecraft:bastion/starts` |
| `start_jigsaw_name` | optional name of the start connector | absent |
| `size` | maximum expansion depth, integer 0 to 20 | 6 |
| `start_height` | a height provider sampled with the structure random and the world-generation context | `{absolute: 33}` (constant y = 33) |
| `use_expansion_hack` | boolean, required | false |
| `project_start_to_heightmap` | optional heightmap type; when absent the start y is the sampled `start_height` | absent (no projection: every bastion starts at y = 33) |
| `max_distance_from_center` | either an integer (both axes) or `{horizontal 1..128, vertical 1..Y_SIZE (default Y_SIZE)}` | the integer 80 (horizontal 80, vertical = `Y_SIZE` = 4064, read: `DimensionType` static initialiser, see below) |
| `pool_aliases` | list of alias bindings, default empty | absent (empty): this structure uses no aliases |
| `dimension_padding` | default `ZERO` | absent (zero) |
| `liquid_settings` | `apply_waterlogging` (default) or `ignore_waterlogging` | absent (`apply_waterlogging`) |

The codec rejects a structure whose horizontal reach exceeds 128 ("Horizontal structure size including terrain adaptation must not
exceed 128", `MAX_TOTAL_STRUCTURE_RANGE`).

`Y_SIZE` (read in the `DimensionType` static initialiser): `BITS_FOR_Y` is `BlockPos.PACKED_Y_LENGTH`, which is `64 - 2 * PACKED_HORIZONTAL_LENGTH`;
`PACKED_HORIZONTAL_LENGTH` is `1 + log2(smallestEncompassingPowerOfTwo(30000000))` = 1 + 25 = 26 (the constant 30000000 and the formula are read; the
logarithm of 33554432 is computed), so `PACKED_Y_LENGTH` = 12. Then `Y_SIZE = (1 << 12) - 32 = 4064`, `MAX_Y = (Y_SIZE >> 1) - 1 = 2031` and
`MIN_Y = MAX_Y - Y_SIZE + 1 = -2032` (the same `MAX_Y` 2031 as 37-1; `MAX_Y + 1` is 2032).

The start origin handed to the expander is `(chunk min x, sampled y, chunk min z)` (read from `JigsawStructure.findGenerationPoint`); the expander is
`JigsawPlacement.addPieces` (36-3; the bastion's parameters and closures are 36-8 sections 13 and 14). The generation stub it returns, which is the
position the biome check uses, is the centre of the start piece's box in x and z with y = 33 (section 3.0).

### 3.3 `ruined_portal_nether`

Fields of `RuinedPortalStructure` (read): `setups`, a non-empty list of `Setup` objects with the fields
`placement` (`on_land_surface`, `partly_buried`, `on_ocean_floor`, `in_mountain`, `underground`, `in_nether`), `air_pocket_probability`,
`mossiness`, `overgrown`, `vines`, `can_be_cold`, `replace_with_blackstone` and `weight`. The Nether structure has exactly one setup:

| Field | Value |
|---|---|
| `placement` | `in_nether` |
| `air_pocket_probability` | 0.0 |
| `mossiness` | 0.0 |
| `overgrown`, `vines`, `can_be_cold` | false, false, false |
| `replace_with_blackstone` | true |
| `weight` | 1.0 |

(For contrast, the standard overworld structure `ruined_portal` has two setups of weight 0.5 each: `underground` with air pocket
1.0 and `on_land_surface` with air pocket 0.0, both with mossiness 0.2 and `can_be_cold` true, and `replace_with_blackstone` false.)
Generation is in section 6.

### 3.4 `nether_fossil`

Field `height` (a height provider): `uniform` from `{absolute: 32}` to `{below_top: 2}`. `below_top` resolves as
`minGenY + genDepth - 1 - offset`, where `WorldGenerationContext` takes `minGenY = max(level min y, generator min y)` and
`genDepth = min(level height, generator gen depth)`; for the Nether that is `0 + 128 - 1 - 2 = 125`, so the fossil's starting y is
drawn from 32 to 125. The point search and pieces are in 37-5 section 6 (read there and confirmed here); section 7 summarises it.

## 4. The fortress piece family (index)

The fortress is not a jigsaw structure: `NetherFortressPieces` defines its own piece classes, a weighted choice and a growth
procedure. Full generation is **36-8 sections 2 to 7**: the weighted selection loop with its depth limit 30 and the `BridgeEndFiller` fallback
(section 3.4), the `allowInRow` rule (section 3.4: an entry equal to the structure's last created piece is skipped unless it allows repetition,
and the last-piece record is shared by both tables), the per-piece child-opening rules (sections 4.1 and 4.3), the start piece box (section 4.2) and the
block fills (section 5). This section indexes what is code-defined and fixed: the classes, their registered ids, extents, weights and limits, and loot.

Constants (read): `MAX_DEPTH` = 30 (pieces stop expanding beyond depth 30), `LOWEST_Y_POSITION` = 10, `MAGIC_START_Y` = 64.

**Two weight tables.** `BRIDGE_PIECE_WEIGHTS` (the open bridge level) and `CASTLE_PIECE_WEIGHTS` (the enclosed castle level). Each entry is
`PieceWeight(pieceClass, weight, maxPlaceCount[, allowInRow])`: `maxPlaceCount` 0 means unlimited (`doPlace` and `isValid` are true
when `maxPlaceCount == 0` or `placeCount < maxPlaceCount`); `allowInRow` (default false) says whether the same class may follow
itself directly (its use in the growth procedure is 36-8 section 3.4). The placement counters are per structure.

| Table | Piece class | Weight | Max count | Allow in row |
|---|---|---|---|---|
| bridge | `BridgeStraight` | 30 | unlimited | yes |
| bridge | `BridgeCrossing` | 10 | 4 | no |
| bridge | `RoomCrossing` | 10 | 4 | no |
| bridge | `StairsRoom` | 10 | 3 | no |
| bridge | `MonsterThrone` | 5 | 2 | no |
| bridge | `CastleEntrance` | 5 | 1 | no |
| castle | `CastleSmallCorridorPiece` | 25 | unlimited | yes |
| castle | `CastleSmallCorridorCrossingPiece` | 15 | 5 | no |
| castle | `CastleSmallCorridorRightTurnPiece` | 5 | 10 | no |
| castle | `CastleSmallCorridorLeftTurnPiece` | 5 | 10 | no |
| castle | `CastleCorridorStairsPiece` | 10 | 3 | yes |
| castle | `CastleCorridorTBalconyPiece` | 7 | 2 | no |
| castle | `CastleStalkRoom` | 5 | 2 | no |

Other classes: `StartPiece` extends `BridgeCrossing` (no weight; one per structure, saved id `NeStart`), `BridgeEndFiller`
(closes an open bridge end; no weight).

**Registered ids and extents.** Each piece type is registered under a short string; the registration helper of `StructurePieceType`
lower-cases the text with `Locale.ROOT` (read), so the registered keys are the strings below in lower case (`nebcr`, `nebef`, `nebs`, `neccs`, `nectb`,
`nece`, `nescsc`, `nestart` and so on; the full table with namespaces is 36-1 section 2.4). Extents are the
`orientBox(x, y, z, offX, offY, offZ, width, height, depth, direction)` arguments of each `createPiece`: the three offsets move the box
relative to the connection point, then size x, y (height), z (depth) in the piece's local frame (the argument order and the
per-direction box arithmetic are 36-1 section 6.3 and 36-8 section 4.2, where a worked example confirms it):

| Class | Id (as registered) | Offset (x, y, z) | Size (w, h, d) | Loot or special |
|---|---|---|---|---|
| `StartPiece` | `NeStart` | as `BridgeCrossing` | 19 x 10 x 19 | none |
| `BridgeCrossing` | `NeBCr` | (-8, -3, 0) | 19 x 10 x 19 | none |
| `BridgeStraight` | `NeBS` | (-1, -3, 0) | 5 x 10 x 19 | none |
| `BridgeEndFiller` | `NeBEF` | (-1, -3, 0) | 5 x 10 x 8 | none |
| `RoomCrossing` | `NeRC` | (-2, 0, 0) | 7 x 9 x 7 | none |
| `StairsRoom` | `NeSR` | (-2, 0, 0) | 7 x 11 x 7 | none |
| `MonsterThrone` | `NeMT` | (-2, 0, 0) | 7 x 8 x 9 | blaze spawner, once (44-2 section 10.2) |
| `CastleEntrance` | `NeCE` | (-5, -3, 0) | 13 x 14 x 13 | none |
| `CastleStalkRoom` | `NeCSR` | (-5, -3, 0) | 13 x 14 x 13 | none (the nether wart room) |
| `CastleSmallCorridorPiece` | `NeSC` | (-1, 0, 0) | 5 x 7 x 5 | none |
| `CastleSmallCorridorCrossingPiece` | `NeSCSC` | (-1, 0, 0) | 5 x 7 x 5 | none |
| `CastleSmallCorridorLeftTurnPiece` | `NeSCLT` | (-1, 0, 0) | 5 x 7 x 5 | chest, `chests/nether_bridge`, local (3, 2, 3) |
| `CastleSmallCorridorRightTurnPiece` | `NeSCRT` | (-1, 0, 0) | 5 x 7 x 5 | chest, `chests/nether_bridge`, local (1, 2, 3) |
| `CastleCorridorStairsPiece` | `NeCCS` | (-1, -7, 0) | 5 x 14 x 10 | none |
| `CastleCorridorTBalconyPiece` | `NeCTB` | (-3, 0, 0) | 9 x 7 x 9 | none |

**Chests.** Only the two turn pieces place a chest: the constructor sets the flag `isNeedingChest` to `nextInt(3) == 0` (one in three), stored
in the piece NBT as the boolean `Chest`; during post-processing, if the flag is set and the chest's world position lies inside the
chunk box being written, the flag is cleared and one chest with the loot table `minecraft:chests/nether_bridge` is placed at the local
position in the table (the loot table is data; the rolling engine is 26 and 18 section 7.6). No other fortress piece
references a loot table (each class was searched for `createChest` and the loot key: only the two turn classes).

**Spawning inside a fortress.** Natural spawns use the `monster` override of section 9.4 and the hard-coded fortress rule of 44-2
section 8.1 (bricks floor, whole bounding box); the throne room's spawner is 44-2 section 10.2.

**Saved piece NBT** is the piece-framework format of 07 and 36-1 section 6.7; the fortress pieces add `Chest` (turn pieces) and, as 36-8 section 4.3 records,
`Seed` (end filler) and `Mob` (throne).

## 5. The bastion remnant: four variants as pool graphs (index)

`bastion_remnant` expands from the pool `minecraft:bastion/starts` (fallback `minecraft:empty`), which has four elements, each a
`single_pool_element` of weight 1 with the processor list `minecraft:bastion_generic_degradation` and projection `rigid`. Choosing a start
piece is therefore a uniform draw among four, which selects one of four **variants**; each variant's pieces connect only to the pools of
its own family plus the shared pools. The pool closure of each variant was computed by following every `jigsaw` block
entity's `pool` value in the templates and every pool's elements (counts below are of the closure, counting the start template):

| Variant (by the start template and the data class that generated its pools) | Start template | Pools in the closure | Templates in the closure | Pools of its own family |
|---|---|---|---|---|
| Housing units (`BastionHousingUnitsPools`) | `bastion/units/air_base` | 18 | 38 | `units/center_pieces`, `units/edge_wall_units`, `units/edges`, `units/fillers/stage_0`, `units/large_ramparts`, `units/pathways`, `units/rampart_plates`, `units/ramparts`, `units/stages/stage_0..3`, `units/stages/rot/stage_1`, `units/wall_units`, `units/walls/wall_bases` |
| Hoglin stable (`BastionHoglinStablePools`) | `bastion/hoglin_stable/air_base` | 17 | 62 | `hoglin_stable/connectors`, `large_stables/inner`, `large_stables/outer`, `mirrored_starting_pieces`, `posts`, `rampart_plates`, `ramparts`, `small_stables/inner`, `small_stables/outer`, `stairs`, `starting_pieces`, `wall_bases`, `walls` |
| Treasure room (`BastionTreasureRoomPools`) | `bastion/treasure/big_air_full` | 22 | 66 | `treasure/bases`, `bases/centers`, `brains`, `connectors`, `corners/bottom`, `corners/edges`, `corners/middle`, `corners/top`, `entrances`, `extensions/houses`, `extensions/large_pool`, `extensions/small_pool`, `ramparts`, `roofs`, `stairs`, `walls`, `walls/bottom`, `walls/mid`, `walls/outer`, `walls/top` |
| Bridge (`BastionBridgePools`) | `bastion/bridge/starting_pieces/entrance_base` | 10 | 19 | `bridge/bridge_pieces`, `connectors`, `legs`, `rampart_plates`, `ramparts`, `starting_pieces`, `walls` |

All pool names are under `minecraft:bastion/`. The shared pools (`BastionSharedPools`) are reached by following every jigsaw block's `pool` value from each
variant's start template (computed again in this pass over the jar; the pool counts of the table include them):

| Shared pool | Reached by |
|---|---|
| `blocks/gold` | housing units, hoglin stable |
| `mobs/piglin` | all four variants |
| `mobs/piglin_melee` | all four variants |
| `mobs/hoglin` | hoglin stable and bridge only (not housing units, not treasure room) |

The mob pools are the preplaced piglins and hoglins of 44-2 section 10.5 (weights and which structure references them).

Totals read from the archive (counted with `unzip -Z1 | grep -v '/$'`): 60 template-pool files under `worldgen/template_pool/bastion/`
(counting `starts`), 167 structure NBT files under `structure/bastion/`, and 11 processor lists whose names relate to the bastion
(`bastion_generic_degradation`, `bottom_rampart`, `bridge`, `empty`, `entrance_replacement`, `high_rampart`, `housing`, `rampart_degradation`,
`side_wall_degradation`, `stable_degradation`, `treasure_rooms`; the jar has 40 processor-list files in all). Four bastion chest loot tables exist: `chests/bastion_bridge`,
`chests/bastion_hoglin_stable`, `chests/bastion_other`, `chests/bastion_treasure` (data; the chests are template block entities with a
`LootTable` key, not placed by code).

**Processors** (data; the engine is 36-2): the degradation lists are `rule` processors made of `random_block_match`
rules with `always_true` location tests. Example read (`bastion_generic_degradation`): polished blackstone bricks become cracked polished
blackstone bricks with probability 0.3; blackstone becomes air with 0.0001; gold block becomes cracked polished blackstone bricks with 0.3;
gilded blackstone becomes blackstone with 0.5; blackstone becomes gilded blackstone with 0.01. The other lists vary the numbers
(for example `rampart_degradation` uses 0.4 for bricks).

**Depth and range.** With `size` 6 the expansion has at most 6 levels below the start; with `max_distance_from_center` 80 no piece
may extend beyond 80 blocks horizontally from the start (the exact box test is in 36-3, applied to the bastion in 36-8 section 13).

## 6. The Nether ruined portal

`RuinedPortalStructure.findGenerationPoint` (read). Inputs: the structure's single setup (section 3.3), the generation context's
random (`WorldgenRandom`), the chunk position. For the Nether setup the random is used in this order:

1. Setup choice: with one setup no random is used.
2. Air pocket: `sample(random, air_pocket_probability)` is false at probability 0.0 and true at 1.0 without a draw, and otherwise
   `nextFloat() < p`; with 0.0 here it is **false and consumes no random**.
3. Template: `nextFloat() < 0.05` selects one of the three giant portals (`ruined_portal/giant_portal_1..3`, index `nextInt(3)`);
   otherwise one of the ten normal portals (`ruined_portal/portal_1..10`, index `nextInt(10)`). The templates are structure NBT (13 files).
4. Rotation: one random of the four `Rotation` values (`nextInt(4)` over the enum order); mirror: `nextFloat() < 0.5` gives `NONE`,
   else `FRONT_BACK`. The pivot is `(sizeX / 2, 0, sizeZ / 2)` (integer division).
5. Position: the template's box at the chunk's world corner `(chunk min x, 0, chunk min z)` (`ChunkPos.getWorldPosition`) is computed with the
   rotation, pivot and mirror; its centre gives the column (cx, cz). The base height under that column (`getBaseHeight`) uses the heightmap chosen by
   `RuinedPortalPiece.getHeightMapType` (`OCEAN_FLOOR_WG` for `on_ocean_floor`, `WORLD_SURFACE_WG` for every other placement); the surface y is that
   height minus 1 (read: the call is followed by the constant 1 and a subtraction). In the `in_nether` placement the surface y is passed on but not used.
6. Vertical placement `in_nether` (`findSuitableY`): with the air-pocket flag true the candidate y is `randomBetweenInclusive(32, 100)`;
   with the flag false (this setup) `nextFloat() < 0.5` gives `randomBetweenInclusive(27, 29)` and otherwise
   `randomBetweenInclusive(29, 100)`. Then the y is lowered: starting at the candidate and while `y > minY + 15` (15 in
   the Nether), the generator's base columns (`getBaseColumn`) at the four corners of the placed box (min x or max x, with min z or
   max z) are tested at height y; the loop stops at the first y where three of the four columns hold a
   block that passes the placement heightmap's opacity test (`Heightmap$Types.isOpaque`: for `WORLD_SURFACE_WG` the predicate is "block is not air",
   for `OCEAN_FLOOR_WG` it is the motion-blocking material predicate; the heightmap here is `OCEAN_FLOOR_WG` only for `on_ocean_floor`, so the Nether
   uses "not air"). The loop does not run below `minY + 15`, so the returned y lies between 15 and the candidate (at most 100) in the Nether; it is
   exactly 15 when no y above it had three passing columns. The result is the y of the piece.
7. The stub position is `(chunk min x, y, chunk min z)`, and it is also the piece's template position (36-4 section 8.2 step 9). It is **not** the box
   centre: the centre is used only in step 5 (read: the stub is built from the chunk's world position and the y of step 6). The piece is created with the
   vertical placement, the properties (`airPocket`, `mossiness`, `overgrown`, `vines`, `replaceWithBlackstone` and `cold`: false for `can_be_cold` false)
   and the template. An earlier draft of this document gave the box centre for the stub; the artifact disagrees and the stub above stands.

**Processors of the piece** (`RuinedPortalPiece.makeSettings`, read; the engines are 36-2 and 36-4 section 8.4). In order:
1. block ignore: structure blocks only when the air pocket is on, otherwise structure blocks and air;
2. a rule processor with the rules, in order: gold block becomes air with probability 0.3; lava is replaced (the vertical placement
   `on_ocean_floor` gives lava to magma block always; a cold portal gives lava to netherrack always; otherwise lava becomes magma
   block with probability 0.2, which is the Nether case); and, because the portal is not cold, netherrack becomes magma block with probability 0.07;
3. `BlockAgeProcessor(mossiness)` with 0.0 here (so no aging in the Nether);
4. `ProtectedBlockProcessor` with the block tag `features_cannot_replace`;
5. `LavaSubmergedBlockProcessor`;
6. when `replace_with_blackstone` is true (the Nether case) one more processor is added: `BlackstoneReplaceProcessor`, tabulated in section 6.1.

**Post-processing** (`postProcess`, read in outline): after the template is placed, `spreadNetherrack` and
`addNetherrackDripColumnsBelowPortal` run for every ruined portal, and vines or leaves only when `vines` or `overgrown` is set (never in the Nether).
Netherrack placement chooses magma block with probability 0.07 when the portal is not cold. The spread uses a table of 14
probabilities indexed by distance: indexes 0 to 6 are 1.0, 7 and 8 are 0.9, 9 is 0.8, 10 is 0.7, 11 is 0.6, 12 is 0.4 and 13 is 0.2.
A drip column extends netherrack downward with a 0.5 chance per step. The distance rule, the use of the box and of the surface heightmap by
these helpers, the drip-column geometry and the replace test are specified in full in **36-4 sections 8.4 to 8.7** (the spread loop over a 29 x 29
column window with the distance table above, the nine-cell drip column and the `in_nether` exception to the lava test); this document does not
repeat them.

### 6.1 The blackstone replacement table

`BlackstoneReplaceProcessor` (read; its table is code, a map of 23 entries built when the processor is created). For a template block, the block
type is looked up; if it is not in the table the block is unchanged. Otherwise the new block's default state is used, then the properties are copied
from the old state when the old state has them: `FACING` and `HALF` (the stair properties) and `TYPE` (the slab property). Other properties,
including waterlogging, are not copied; the block entity data is kept.

| Old block | New block |
|---|---|
| `cobblestone`, `mossy_cobblestone` | `blackstone` |
| `stone` | `polished_blackstone` |
| `stone_bricks`, `mossy_stone_bricks` | `polished_blackstone_bricks` |
| `cobblestone_stairs`, `mossy_cobblestone_stairs` | `blackstone_stairs` |
| `stone_stairs` | `polished_blackstone_stairs` |
| `stone_brick_stairs`, `mossy_stone_brick_stairs` | `polished_blackstone_brick_stairs` |
| `cobblestone_slab`, `mossy_cobblestone_slab` | `blackstone_slab` |
| `smooth_stone_slab`, `stone_slab` | `polished_blackstone_slab` |
| `stone_brick_slab`, `mossy_stone_brick_slab` | `polished_blackstone_brick_slab` |
| `stone_brick_wall`, `mossy_stone_brick_wall` | `polished_blackstone_brick_wall` |
| `cobblestone_wall`, `mossy_cobblestone_wall` | `blackstone_wall` |
| `chiseled_stone_bricks` | `chiseled_polished_blackstone` |
| `cracked_stone_bricks` | `cracked_polished_blackstone_bricks` |
| `iron_bars` | `iron_chain` |

Row count: 2 + 1 + 2 + 2 + 1 + 2 + 2 + 2 + 2 + 2 + 2 + 1 + 1 + 1 = 23 keys. The class names of the constants are `IRON_CHAIN` and the block ids above are the
lower-case forms of the constant names (the id strings themselves are in the block registry, 24).

**Nether-specific facts**: the `ruined_portals` set is shared with the overworld, so in the Nether only `ruined_portal_nether`
can pass the biome check (the other six tags name overworld biomes) and the weighted selection of section 2 reaches it after the
failures of the other picks.

## 7. The nether fossil (summary and cross-reference)

Fully specified in 37-5 section 6, which this reading confirms entry by entry. Summary for the structure hooks: attempt per chunk
`(2 rx, 2 rz)` (section 2); `x = minX + nextInt(16)`, then `z = minZ + nextInt(16)`; y from the height provider (32 to 125); the
point is found by scanning the base column downward from y while y is above the sea level of 32 for an air cell over a soul sand
block or over a sturdy-topped block; no structure if the final y is not above 32; then rotation `nextInt(4)` and the template
`nether_fossils/fossil_N` (N = 1..14, `nextInt(14)`); the placed piece uses the ignore processor `STRUCTURE_AND_AIR` and mirror `NONE`;
after placement a dried ghast is placed with probability 0.5 (37-5 section 6). Terrain adaptation `beard_thin` applies. Only the soul
sand valley is in the tag.

## 8. Tags

All read from `data/minecraft/tags/worldgen/**`:

| Tag | Values | Used by |
|---|---|---|
| `worldgen/biome/is_nether` | `nether_wastes`, `soul_sand_valley`, `crimson_forest`, `warped_forest`, `basalt_deltas` (in that file order) | referenced by the two tags below |
| `worldgen/biome/has_structure/nether_fortress` | `#is_nether` | `fortress.biomes` |
| `worldgen/biome/has_structure/bastion_remnant` | `crimson_forest`, `nether_wastes`, `soul_sand_valley`, `warped_forest` | `bastion_remnant.biomes` |
| `worldgen/biome/has_structure/nether_fossil` | `soul_sand_valley` | `nether_fossil.biomes` |
| `worldgen/biome/has_structure/ruined_portal_nether` | `#is_nether` | `ruined_portal_nether.biomes` |
| `worldgen/structure/ruined_portal` | the seven ruined portal structures (including `ruined_portal_nether`) | queries that treat all ruined portals as one kind |

Per biome: nether wastes: fortress, bastion remnant, ruined portal (fossil: no). Soul sand valley: all four. Crimson forest and warped
forest: fortress, bastion remnant, ruined portal. Basalt deltas: fortress and ruined portal only (no bastion: its biome is not in the tag).
There are no structure tags that name the fortress or bastion (all tag files in the jar were searched for the names: only the
`ruined_portal` structure tag matches). The advancement `nether/find_fortress` matches the structure `fortress` by location; the other
Nether advancements are outside this scope.

## 9. Natural spawning in the Nether

### 9.1 The attribute and the dimension

Each Nether biome's `attributes` object carries `gameplay/natural_mob_spawns`: `{modifier: "overlay", argument: {spawns_by_category,
spawn_costs}}`; the overlay semantics and the lookup order (fortress rule, then structure overrides, then the biome list) are in 44-2
sections 7.3 and 8.1, the pack draw in 18 section 6.5, spawn costs in 18 section 6.7. The dimension type `the_nether` sets
`monster_spawn_light_level` 7 and `monster_spawn_block_light_limit` 15, and the attribute `gameplay/piglins_zombify` false
(so piglins and hoglins do not turn into zombified versions in the Nether; 44-6 section 7). None of the five biomes defines
any category other than `creature` and `monster`; none defines `creature_world_gen_spawn_probability` (only five overworld biomes
do: snowy plains, ice spikes, badlands, eroded badlands, wooded badlands), so the attribute default 0.1 applies.

### 9.2 Per-biome lists (read from `worldgen/biome/*.json`)

`count` is the pack-size provider of the entry (a constant or `uniform` min..max inclusive); `weight` is the draw weight inside its category list of the biome.

| Biome | Category | Entity | Weight | Count |
|---|---|---|---|---|
| nether_wastes | creature | strider | 60 | 1 to 2 |
| nether_wastes | monster | ghast | 50 | 4 |
| nether_wastes | monster | zombified_piglin | 100 | 4 |
| nether_wastes | monster | magma_cube | 2 | 4 |
| nether_wastes | monster | enderman | 1 | 4 |
| nether_wastes | monster | piglin | 15 | 4 |
| crimson_forest | creature | strider | 60 | 1 to 2 |
| crimson_forest | monster | zombified_piglin | 1 | 2 to 4 |
| crimson_forest | monster | hoglin | 9 | 3 to 4 |
| crimson_forest | monster | piglin | 5 | 3 to 4 |
| warped_forest | creature | strider | 60 | 1 to 2 |
| warped_forest | monster | enderman | 1 | 4 |
| soul_sand_valley | creature | strider | 60 | 1 to 2 |
| soul_sand_valley | monster | skeleton | 20 | 5 |
| soul_sand_valley | monster | ghast | 50 | 4 |
| soul_sand_valley | monster | enderman | 1 | 4 |
| basalt_deltas | creature | strider | 60 | 1 to 2 |
| basalt_deltas | monster | ghast | 40 | 1 |
| basalt_deltas | monster | magma_cube | 100 | 2 to 5 |

Category totals (for draw probabilities): nether wastes monster 168 (50 + 100 + 2 + 1 + 15); crimson forest 15; warped forest 1;
soul sand valley 71; basalt deltas 140. Every `creature` list is the single strider entry (total 60, so probability 1).
Wither skeletons, blazes and the fortress zombified piglins and magma cubes have **no** biome entry: they come only from the
fortress override (9.4). No `ambient`, `water_*` or `underground_water_creature` list is defined in any Nether biome.

### 9.3 Spawn costs (`spawn_costs`)

Only two biomes define costs (a map from entity type to `{charge, energy_budget}`); the other three have `{}`:

| Biome | Entity | `charge` | `energy_budget` |
|---|---|---|---|
| warped_forest | enderman | 1.0 | 0.12 |
| soul_sand_valley | enderman | 0.7 | 0.15 |
| soul_sand_valley | ghast | 0.7 | 0.15 |
| soul_sand_valley | skeleton | 0.7 | 0.15 |
| soul_sand_valley | strider | 0.7 | 0.15 |

The semantics (a point charge per counted mob at its position; a new spawn is limited by the potential at the position and the budget) are
18 section 6.7; the cost used at spawn time is read from the attribute at the mob's block position (the `NaturalSpawner.createState`
lambda reads `NATURAL_MOB_SPAWNS` at the position and adds the entity type's cost), the same data as the table.

### 9.4 The fortress override

`fortress.json` `spawn_overrides.monster`: `bounding_box` `piece`, `spawns`:

| Entity | Weight | Count |
|---|---|---|
| blaze | 10 | 2 to 3 (uniform) |
| zombified_piglin | 5 | 4 |
| wither_skeleton | 8 | 5 |
| skeleton | 2 | 5 |
| magma_cube | 3 | 4 |

Total weight 28. The list **replaces** the biome's monster list on any block of a fortress piece's box (44-2 sections 8.1 and 8.2); in
addition the hard-coded list with the same five entries applies when the cell below the position is nether bricks and the position is
anywhere in the fortress's whole box (44-2 section 8.4). Creature spawns (striders) are unaffected by the override. The structure
data and the hard-coded list were compared in 44-2 and have identical entries.

### 9.5 Spawn predicates of the Nether mobs (`SpawnPlacements`, read)

Every Nether monster uses the placement type `ON_GROUND` and the heightmap `MOTION_BLOCKING_NO_LEAVES`; the strider uses `IN_LAVA` and
the same heightmap. The predicates (all return booleans; `checkMobSpawnRules` is the generic test of 44-2 section 12):

| Entity | Predicate | Rule |
|---|---|---|
| ghast | `Ghast.checkGhastSpawnRules` | difficulty is not peaceful, **and** `nextInt(20) == 0`, **and** `checkMobSpawnRules` |
| zombified_piglin | `ZombifiedPiglin.checkZombifiedPiglinSpawnRules` | difficulty is not peaceful and the block below is not `nether_wart_block` (no light test) |
| piglin | `Piglin.checkPiglinSpawnRules` | the block below is not `nether_wart_block` (no difficulty test, no light test) |
| hoglin | `Hoglin.checkHoglinSpawnRules` | the block below is not `nether_wart_block` |
| magma_cube | `MagmaCube.checkMagmaCubeSpawnRules` | difficulty is not peaceful (no light test) |
| strider | `Strider.checkStriderSpawnRules` | starting at the candidate position, move up one block at a time while the fluid at the cell is lava (the first move happens before the first test); the rule is true when the first cell that is not lava is **air** |
| enderman, skeleton, wither_skeleton | `Monster.checkMonsterSpawnRules` | unless the spawn reason ignores light: `isDarkEnoughToSpawn`; then `checkMobSpawnRules` |
| blaze (and zoglin) | `Monster.checkAnyLightMonsterSpawnRules` | `checkMobSpawnRules` only (any light) |

`Monster.isDarkEnoughToSpawn` (read) in the Nether: (1) the sky brightness at the cell is compared with `nextInt(32)`: the sky light of
the Nether is 0 (no sky), so `sky > nextInt(32)` is never true and this test passes; (2) the block-light test applies only when the
dimension's `monster_spawn_block_light_limit` is below 15: the Nether's limit is 15, so **the block-light test is skipped**; (3) the final
test is that the cell's raw brightness (`getMaxLocalRawBrightness`, which uses the value 10 as the sky darkening only when the level is
thundering, never in the Nether) is at most a sample of `monster_spawn_light_level` (the constant 7): a position of light level 8 or
more does not spawn skeletons, wither skeletons or endermen, while ghasts, zombified piglins, piglins, hoglins, magma cubes and blazes
ignore light.

### 9.6 Chunk-generation spawns in the Nether

`NoiseBasedChunkGenerator.spawnOriginalMobs` (read) runs unless the settings' `disable_mob_generation` is true: the flag is **false** in
`noise_settings/nether` (and in every overworld-style settings file; **true** only in `end`), and the biome is sampled at the chunk's
minimum corner at the world's top y.

**Seeding and position** (read in `spawnOriginalMobs`): the region's centre chunk gives the corner position `(chunk min x, 0, chunk min z)`, which is
moved to `y = WorldGenRegion.getMaxY()` (the level's maximum y; for the Nether, minimum y 0 and height 256 give 255, from 37-1). A fresh
`WorldgenRandom` over a `LegacyRandomSource` is created with a unique seed (`RandomSupport.generateUniqueSeed`, not derived from the world seed), then
`setDecorationSeed(region seed, chunk min x, chunk min z)` is called on it (the definition is in 10 section 2.6 and 11; its returned value is discarded).
`NaturalSpawner.spawnMobsForChunkGeneration` (18 section 6.10) then runs with this random and the corner position. The call re-seeds the generator
from the region seed and the corner, so (inferred, from `setDecorationSeed` being a seeding call on a legacy generator) the unique seed has no effect on
the draws that follow and the pass is a function of the world seed and the chunk; this was not checked against the seeding definition in this round
(Open question 16).

`spawnMobsForChunkGeneration` runs with the `creature` list: a
strider entry with probability 0.1 per check. For a dimension with a ceiling the candidate position is found by `getTopNonCollidingPos` (read, the
column's x and z come from `nextInt(16)` draws inside the chunk): starting at the heightmap top for the entity's heightmap type, the position first moves
down **while the cell is not air** (it moves once before the first test, so it ends on the first air cell below the roof), then moves down **while the
cell is air** down to the level's minimum y, and the cell it stops on is the solid floor cell. That cell goes through the placement type's
`adjustSpawnPosition`; the strider's `IN_LAVA` placement type adjusts the position (18 section 6.9). The game rule `spawn_mobs` gates it. This agrees with
the corrected reading of 37-1 section 6.5 (that section's sentence has the two loops in the opposite order and is to be corrected there).

## 10. Interface to portals (RS23): numbers only

Only numbers read for the Nether side; the portal algorithm is RS23:

| Item | Value | Source |
|---|---|---|
| `coordinate_scale` | Nether 8.0, Overworld 1.0 | dimension type JSON; `getTeleportationScale(from, to) = from.scale / to.scale` (a double division) |
| Destination dimension | the destination is the Nether when the current level is **not** the Nether, and the Overworld when it is; so a portal used in the End targets the Nether (the portal round, RS23, owns the rest) | `NetherPortalBlock.getPortalDestination` (compares the level key with `Level.NETHER`) |
| Scale of the coordinates | the entity's own x and z (not a portal block position) are multiplied by the teleportation scale (overworld to Nether 1/8, Nether to overworld 8); y is unscaled; `WorldBorder.clampToBounds(double, double, double)` clamps them to the destination border and returns an integer **block position**, which is the origin of the portal search | `NetherPortalBlock.getPortalDestination` |
| Portal point search radius | 16 blocks when the destination is the Nether; 128 when the destination is the overworld (squares around the scaled position) | `PortalForcer.findClosestPortalPosition` (its flag is "destination is the Nether") |
| Portal creation search | a spiral of radius 16 around the scaled position | `PortalForcer.createPortal` |
| Top y for a created portal | `min(maxY, minY + logical_height - 1)`: in the Nether `min(255, 0 + 128 - 1) = 127`; in the overworld `min(319, -64 + 384 - 1) = 319` | `PortalForcer.createPortal` |
| Fallback portal y range | lower bound `max(minY + 1, 70)` (70 in the Nether), upper bound `top - 9` (118 in the Nether, 310 in the overworld); if the upper bound is below the lower bound no portal is created; the fallback y is the entity's y clamped to that range | `PortalForcer.createPortal` |
| Build height ceiling | Not 128: the use-item-on handling in `ServerGamePacketListenerImpl` compares the block y with `ServerLevel.getMaxY()` and `getMinY()` and sends `build.tooHigh` or `build.tooLow`; `logical_height` 128 limits only portal creation and the chorus-fruit teleport | agrees with 37-1 section 6.6 |
| Terrain extent | noise `min_y` 0, `height` 128: terrain and the bedrock roof fill y 0 to 127; the 128 cells above are not filled by the noise generator | 37-2, 37-4 |
| Bedrock roof as the player boundary | no code in the entity or player classes searched ties the player to y 127 (Open question 7); the roof is the generated bedrock layer only | not found |
| Sea level | 32 (lava ocean) | `noise_settings/nether` |
| Spawn target | empty list: no world spawn is searched inside the Nether | `noise_settings/nether` |

## 11. Worked examples

1. **Region and candidate chunk.** Chunk (-1, 30), `nether_complexes`: `regionX = floorDiv(-1, 27) = -1`, `regionZ = floorDiv(30, 27) = 1`. The random is seeded
   with `(seed, -1, 1, 30084232)`, then `offX = nextInt(23)` and `offZ = nextInt(23)` are drawn; the candidate chunk is
   `(-27 + offX, 27 + offZ)`, which spans chunks -27..-5 in x and 27..49 in z. Chunk x = -1 would need `offX` = 26, which is outside 0..22, so chunk (-1, 30) is never a structure chunk of this set.
2. **Nether fossil candidate.** Chunk (7, 10): region (3, 5); the offset is `nextInt(1) = 0`, so the candidate is chunk (6, 10) and chunk (7, 10) is not a structure chunk.
3. **Entry selection.** Suppose the biome seen at the **fortress** stub (chunk min x, 64, chunk min z) and at the **bastion** stub (box centre x, 33, box centre z) is basalt deltas in both places (fortress allowed, bastion not; the two stubs are different positions, section 3.0, so this is an assumption, not a consequence): total weight 5, `nextInt(5)` of 0 or 1 (probability 0.4) picks the fortress; 2, 3 or 4 (0.6) picks the bastion, which fails the biome check,
   leaving only the fortress and a second draw `nextInt(2)` (total 2, a list of one), which picks the fortress. Under that assumption the fortress is generated in every case. In a real basalt deltas region the bastion stub at y = 33 and the fortress stub at y = 64 can lie in different biomes (the Nether source is three-dimensional), so the conclusion holds only where the fortress stub itself is in a Nether biome, which is every Nether biome (tag `#is_nether`); the bastion then simply fails or succeeds on its own stub.
   If both stubs lie in a crimson forest both are valid: the first pick is the fortress with probability 0.4 and the bastion with 0.6, and only a failed start falls through.
4. **Ruined portal y distribution.** Nether setup, air pocket false: the candidate y is uniform 27..29 with probability 0.5 (each y: 0.5/3), otherwise uniform 29..100 (72 values, each 0.5/72). So `P(y = 29) = 1/6 + 1/144`, `P(y = 100) = 1/144`; the final y is then lowered until three of the four corner columns hold a solid block at that height (never below 15).
5. **Fortress start.** Chunk (4, -3): the stub is `(64, 64, -48)` (chunk min x = 64, y = 64, min z = -48); the start piece is created at x = 66 and z = -46 (block 2 of the chunk on each axis), then the whole structure is moved so its box fits y 48 to 70 (section 3.1): with a union box 30 high, `room = 23 - 30 < 1`, so the new minimum y is 48 and no random is drawn; with a union box 10 high, `room = 13` and the new minimum y is `48 + nextInt(13)`, 48 to 60.
6. **Spawn draw.** Nether wastes, category monster: P(ghast) = 50/168 = 29.8 %, P(zombified piglin) = 100/168 = 59.5 %, P(piglin) = 15/168 = 8.9 %, P(magma cube) = 2/168 = 1.2 %, P(enderman) = 1/168 = 0.6 %. A ghast pick passes `checkGhastSpawnRules` with probability 1/20 per attempt on a non-peaceful difficulty (then the generic test).
   Warped forest: every monster pick is an enderman (total weight 1).
7. **Fortress list.** On a nether bricks floor in a fortress: blaze 10/28 = 35.7 %, wither skeleton 8/28 = 28.6 %, zombified piglin 5/28 = 17.9 %, magma cube 3/28 = 10.7 %, skeleton 2/28 = 7.1 %.
8. **Light.** A skeleton candidate in the soul sand valley at a cell with raw brightness 7: passes the light test (7 <= 7); at 8: fails. A ghast candidate at brightness 15: unaffected by light.
9. **Strider.** A candidate in a lava cell with two lava cells above it and air above those: the position moves up twice, the next cell is air: the rule is true. Lava directly under a solid cell: the first cell above is solid, not air: false.
10. **Coordinates.** A player at overworld (100.0, 70.0, -40.0) enters a portal: the scaled position is (12.5, 70.0, -5.0), and `clampToBounds` returns the block `(12, 70, -5)` (inside the border), which is the search origin passed on (radius 16, destination Nether); from Nether (12, 64, -5) back: the block `(96, 64, -40)` before the portal search (radius 128).
11. **Portal ceiling.** `createPortal` in the Nether: top 127; fallback y range [70, 118].

## 12. Validation

| # | Check | How to verify against the artifact | Expected |
|---|---|---|---|
| V1 | structure JSON count | `unzip -Z1 jar \| grep -v '/$' \| grep -c 'data/minecraft/worldgen/structure/'` | 52 |
| V2 | the three sets | read `structure_set/nether_complexes.json`, `nether_fossils.json`, `ruined_portals.json` | the numbers of section 2 |
| V3 | fortress override total | sum of the five weights | 28 |
| V4 | bastion template count | files under `data/minecraft/structure/bastion/` | 167 |
| V5 | bastion pool files | files under `data/minecraft/worldgen/template_pool/bastion/` | 60 |
| V6 | ruined portal templates | files under `data/minecraft/structure/ruined_portal/` | 13 (10 normal, 3 giant) |
| V7 | nether fossil templates | files under `data/minecraft/structure/nether_fossils/` | 14 |
| V8 | fortress weights | `NetherFortressPieces` static initialiser | the table of section 4 (6 bridge entries, 7 castle entries) |
| V9 | piece ids | `StructurePieceType` constants | the 15 `Ne*` ids of section 4 (14 piece classes plus `NeStart`), plus `ORP`, `NeFos` and `jigsaw` |
| V10 | biome tags | the `tags/worldgen/biome/has_structure/*` files named in section 8 | as listed |
| V11 | Nether biome spawn lists | `worldgen/biome/*.json` attribute `gameplay/natural_mob_spawns` | sections 9.2 and 9.3 |
| V12 | dimension scalars | `dimension_type/the_nether.json` | `coordinate_scale` 8.0, `logical_height` 128, `monster_spawn_light_level` 7, `monster_spawn_block_light_limit` 15, `piglins_zombify` false |
| V13 | noise settings flags | `noise_settings/nether.json` | `disable_mob_generation` false, `sea_level` 32, `noise` `{min_y 0, height 128}`, `spawn_target` `[]` |
| V14 | chunk-gen probability default | `EnvironmentAttributes.CREATURE_WORLD_GEN_SPAWN_PROBABILITY` default | 0.1 |
| V15 | portal radii | `PortalForcer.findClosestPortalPosition` | 16 (destination Nether) and 128 |
| V16 | build limit uses max y | `ServerGamePacketListenerImpl` use-item-on handling | compares with `getMaxY()` and `getMinY()`, not the logical height |

Test sketches for an implementation: a unit test of the candidate chunk with a fixed seed against the legacy generator of 10 section 2.6, the seeding helper `setLargeFeatureWithSalt` of 36-1 section 4.3 and `setLargeFeatureSeed` of 11 section 4;
table tests of the spawn predicates (ghast 1/20, zombified piglin on a wart block false, strider rule with lava columns); a test that
every Nether biome's monster weights sum to the totals of 9.2; a test of `isDarkEnoughToSpawn` with `monster_spawn_block_light_limit` 15
(block light ignored) and brightness 7 and 8.

## 13. Open questions

Questions of the earlier draft that were answered are listed first with their answer, so the numbering of references stays traceable.

1. Resolved. `Y_SIZE` is read, not inferred: 4064 (section 3.2). `MAX_Y` is 2031, `MIN_Y` is -2032. Only the logarithm of 33554432 (25) that feeds `PACKED_HORIZONTAL_LENGTH` is computed, not read.
2. Resolved. The fortress piece keys are the lower-case forms (`nebcr`, `nebef`, ...), full table in 36-1 section 2.4. The stored NBT id carries the `minecraft:` namespace (36-1 sections 2.4 and 6.7).
3. Resolved. The `orientBox` argument order and the per-direction arithmetic are 36-1 section 6.3, with a worked example in 36-8 section 7.1.
4. Resolved. The selection loop (weights, 5 attempts, depth limit 30, `BridgeEndFiller` fallback) is 36-8 section 3.4.
5. Resolved. The spread loop, drip columns and replace test are 36-4 sections 8.5 and 8.6.
6. Resolved. The piece's template position is the stub `(chunk min x, y, chunk min z)` (36-4 section 8.2 step 9; section 6 step 7). Note that this document's earlier draft (box centre) was wrong.
7. No player-boundary rule at the bedrock roof was found: the entity, player and level classes that mention the Nether key are portal, piglin, hoglin, wither, TNT and POI code. Whether anything damages or blocks a player above y 127 was not found; the build limit is `getMaxY` (255 inferred from `min_y + height - 1`).
8. Resolved. `moveInsideHeights` is read (section 3.1).
9. Resolved. `allowInRow` false skips an entry that equals the structure's last created piece (a single structure-wide record shared by both tables), 36-8 sections 3.4 and 3.5.
10. Resolved. The biome check reads the biome at the stub position in quart coordinates (section 3.0); the four stubs are tabulated there.
11. The bastion variant names ("housing units", "hoglin stable", "treasure room", "bridge") come from the data-generator class names and the template folder names; they are descriptive only.
12. The processors of the 11 bastion lists were read in one example (`bastion_generic_degradation`) and partly for `rampart_degradation`; all are data (36-2 for the engine, 36-8 sections 13 to 16 for the bastion). The ruined portal's blackstone swap table is now read (section 6.1).
13. The mob category of each Nether entity type is taken from the biome JSON (monster, creature); the `MobCategory` assignments in `EntityTypes` were not re-read here (21 section 2 holds the entity table).
14. The dried ghast placement in fossils (probability 0.5) is taken from 37-5 and confirmed by the constant 0.5f in `placeDriedGhast`; which box (template box or chunk box) bounds the position is as stated in 37-5 and was not independently re-derived.
15. Resolved. `Heightmap$Types` was read: `WORLD_SURFACE_WG` uses the predicate "not air", `OCEAN_FLOOR_WG` the motion-blocking material predicate; "surface y = base height - 1" is read (section 6 steps 5 and 6).
16. `spawnOriginalMobs` seeds a fresh legacy `WorldgenRandom` with a unique seed and then calls `setDecorationSeed` on it; that the second call makes the first seed irrelevant is inferred from its being a seeding call and was not checked against the definition (section 9.6).
17. The conversion of the clamped double position of `clampToBounds` to a block position (the example of section 11 assumes a floor, so 12.5 gives 12) was not read; only the return type `BlockPos` was.
18. The fortress, bastion and ruined portal engines are owned by 36-8 and 36-4 and are not repeated here; if one of them changes, the stub table of section 3.0 and section 6 must be checked against it. The stubs were read in this document's own pass: the ruined portal stub is the chunk corner at the final y (not the box centre), and the bastion stub is the centre of the start piece's box at y 33 (not the chunk corner); 36-4 section 8.2 and 36-8 section 13 agree.
19. `docs/protocol/README.md` has no entry for the 36-structures or 37-nether documents; the Documents table and scope sentence are for the orchestrator to update (this run may not edit the README).
20. 37-1 section 6.5 describes the order of the two loops of `NaturalSpawner.getTopNonCollidingPos` in the opposite order of the artifact (section 9.6 here is the read order); 37-1 needs a correction.
