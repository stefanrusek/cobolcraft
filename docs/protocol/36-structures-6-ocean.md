# 36 Structures, part 6: ocean ruins, shipwrecks and the ocean monument

| Item | Value |
|---|---|
| Covers | The three ocean structure families: the **ocean ruin** (`ocean_ruin_cold`, `ocean_ruin_warm`: structure schema, start generation, the template choice for small, big, cold and warm ruins, the cluster algorithm, integrity (rot), the suspicious sand and gravel rule, the height-adaptation of a piece, the `chest` and `drowned` data markers, piece serialization), the **shipwreck** (`shipwreck`, `shipwreck_beached`: schema, the two template lists, the height rules for ocean and beached wrecks, the palette choice, the three loot markers, serialization) and the **ocean monument** (`monument`: biome test, the single building piece and its 58 x 23 x 58 box, the room grid and the room-connection graph with its random pruning, the seven room fitters, all twelve piece classes (the building and eleven room, wing and penthouse classes) with their complete block geometry, the gold core, the sponge rooms, the entrance, wings and roof, the water clearing, the elder guardians, the spawn override, the regeneration of the pieces after a chunk load). Block-by-block geometry of every piece the monument is made of is given as operation tables (sections 5.8 and 5.9). Worked examples (computed) and a validation section close the document. |
| Does not cover | Rows of data: the extraction tool copies `worldgen/structure`, `worldgen/structure_set`, the biome tags `has_structure/*`, the structure tags, the loot tables (`chests/underwater_ruin_small`, `chests/underwater_ruin_big`, `chests/shipwreck_map`, `chests/shipwreck_supply`, `chests/shipwreck_treasure`, `archaeology/ocean_ruin_warm`, `archaeology/ocean_ruin_cold`) and the structure NBT files `structure/underwater_ruin/*` (48 files) and `structure/shipwreck/*` (20 files); see 22 and 23. This document gives their schema, their use and the engines. The ocean monument has **no** NBT files: it is entirely code and is specified here in full. The shared structure machinery is the sibling parts: the model, placement, starts, the `StructurePiece` base, `BoundingBox`, block-writing helpers and spawn overrides are 36-1 (cited as "36-1 section N"); the template system (`StructureTemplate`, `TemplateStructurePiece`, processors, `placeInWorld`) is 36-2; this document restates only the parts of them that its three families depend on, and where it does the restatement was read again in this round. Loot-table evaluation is 26, the brushable block entity (suspicious sand and gravel) is 31 part 4, the elder guardian, guardian and drowned mobs are 44 part 2 section 10.8 and the mob documents. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.structure.structures.OceanRuinStructure`, `OceanRuinStructure$Type`, `OceanRuinPieces` (and `$OceanRuinPiece`), `ShipwreckStructure`, `ShipwreckPieces` (and `$ShipwreckPiece`), `OceanMonumentStructure`, `OceanMonumentPieces` and all its 23 nested classes (the switch-map class `$1`, `MonumentBuilding`, `OceanMonumentPiece`, `RoomDefinition`, `MonumentRoomFitter`, the seven `Fit*` classes and the eleven room, wing and penthouse classes), of `structure.TemplateStructurePiece`, `Structure`, `templatesystem.StructureTemplate`, `StructurePlaceSettings`, `BlockRotProcessor`, `BlockIgnoreProcessor`, `CappedProcessor`, `RuleProcessor`, `ProcessorRule`, `rule.blockentity.AppendLoot`, of `net.minecraft.util.Util`, `Mth`, `RandomSource`, `levelgen.LegacyRandomSource` (positional factory), `Direction` and `Direction$Plane`, `Rotation`, `biome.BiomeResolver`, `world.RandomizableContainer`, `storage.loot.BuiltInLootTables`, and of the data files named above under `data/minecraft/` (structure JSON, structure sets, tags) and the NBT of the 68 template files (sizes, palettes, data markers; read with a scratch NBT reader, no execution of the artifact). No execution of the artifact. Counts were taken with `unzip -Z1 <jar> | grep -v '/$' | grep <prefix> | wc -l`. Values marked "(computed)" were produced by throwaway scratch implementations of this document's own rules (a Java-LCG, `getSeed`, the monument room graph and the ruin cluster); they are test vectors, unverified against the artifact, and are listed in Open question 12. |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engines and the code-defined geometry (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12b, GAP-18, R4, R7, R10). |
| Status | Written by the reader for round RS20, part 6. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. No fact in this document is taken from recall.
References use "10 section 2" for other documents, "36-1 section 5" for sibling part 1 of this series and "section 5" for this one.
Coordinates are block coordinates; `y` is the vertical axis; the overworld has `minY = -64`, height 384 and sea level 63 (10 section 5).
"Chunk write box" is the `BoundingBox` argument that every `postProcess` receives (36-1 section 8); "the placement random" is the
`random` argument of `postProcess`, one stream shared by all pieces of one structure in one chunk pass (36-1 section 8).

---

## 1. The three families at a glance

| Structure element (id) | `type` | Generator class | Key fields (schema) | Pieces |
|---|---|---|---|---|
| `ocean_ruin_cold`, `ocean_ruin_warm` | `ocean_ruin` | `OceanRuinStructure` | `biome_temp` (`warm` or `cold`), `large_probability` (float 0..1), `cluster_probability` (float 0..1) beside the common settings of 36-1 section 3.1 | `orp` (`OceanRuinPiece`, a template piece, 36-1 section 2.4 row 33) |
| `shipwreck`, `shipwreck_beached` | `shipwreck` | `ShipwreckStructure` | `is_beached` (boolean) beside the common settings | `shipwreck` (`ShipwreckPiece`, a template piece, row 53) |
| `monument` | `ocean_monument` | `OceanMonumentStructure` | none beside the common settings | `omb` (the single piece placed in the start) and eleven more types created inside it (section 5.5) |

The common settings (`biomes`, `spawn_overrides`, `step`, `terrain_adaptation`, 36-1 section 3.1) of all five structures in the jar:
`step` is `surface_structures` for all; `terrain_adaptation` is absent from all five files and therefore `none` (no beardifier, 36-1
section 9); `spawn_overrides` is `{}` for the ruins and shipwrecks, and for the monument it has three keys (section 5.10). The values
of the data, as read, are given only where the engine's behaviour is tied to them:

| Structure set (data) | Placement | Members (weight 1 each) |
|---|---|---|
| `ocean_ruins` | `random_spread`, spacing 20, separation 8, salt 14357621, spread type linear (default) | `ocean_ruin_cold`, `ocean_ruin_warm` |
| `shipwrecks` | `random_spread`, spacing 24, separation 4, salt 165745295, linear | `shipwreck`, `shipwreck_beached` |
| `ocean_monuments` | `random_spread`, spacing 32, separation 5, salt 10387313, **triangular** | `monument` |

| Structure | Biomes (tag in the data pack) | Biome content (data, for orientation) |
|---|---|---|
| `ocean_ruin_cold` | `has_structure/ocean_ruin_cold` | `frozen_ocean`, `cold_ocean`, `ocean`, `deep_frozen_ocean`, `deep_cold_ocean`, `deep_ocean` |
| `ocean_ruin_warm` | `has_structure/ocean_ruin_warm` | `lukewarm_ocean`, `warm_ocean`, `deep_lukewarm_ocean` |
| `shipwreck` | `has_structure/shipwreck` | the tag `is_ocean` |
| `shipwreck_beached` | `has_structure/shipwreck_beached` | the tag `is_beach` |
| `monument` | `has_structure/ocean_monument` | the tag `is_deep_ocean`; the additional surrounding test of section 5.1 uses `required_ocean_monument_surrounding` = tags `is_ocean` and `is_river` |

Both `ocean_ruin_*` structures and the tag `dolphin_located` (`#ocean_ruin` and `#shipwreck`) are cited by 44 part 7. The tag `ocean_ruin`
holds the two ruin structures; the tag `shipwreck` holds the two shipwrecks; `on_ocean_monument_maps` holds `monument` and
`on_ocean_ruin_warm_maps` holds `ocean_ruin_warm` (explorer maps, 25 part 5).

---

## 2. Shared definitions used by the three generators

### 2.1 Random sources and draw primitives

All three generators use the **Java linear congruential generator** (`LegacyRandomSource`, 10 section 2.6) through the start's `WorldgenRandom`,
and the template engine uses it for per-block and per-position streams. The primitives:

| Name | Definition |
|---|---|
| `LCG(seed)` | 10 section 2.6: `state = (seed xor 0x5DEECE66D) and (2^48 - 1)`; `next(bits)` advances `state = (state * 0x5DEECE66D + 11) and (2^48 - 1)` and returns `(int)(state >>> (48 - bits))`; `nextInt(bound)` is `(bound * next(31)) >> 31` for a power of two and the rejection loop on `next(31) % bound` otherwise; `nextFloat()` is `next(24) * 5.9604645E-8`; `nextBoolean()` is `next(1) != 0`; `nextLong()` is `(next(32) << 32) + next(32)` (signed 32-bit parts); `nextInt()` is `next(32)`. |
| `getSeed(x, y, z)` | `Mth.getSeed`, 10 section 2.4 (`getSeed(1, 2, 3) = -33674130277896`). `getSeed(pos)` is the same on a block position. |
| Start random | `WorldgenRandom(LCG(0))` then `setLargeFeatureSeed(worldSeed, chunkX, chunkZ)` (11 section 4; 36-1 section 5.1). The first draw of a start is the first draw after that call. |
| `Mth.nextInt(r, lo, hi)` | `lo` if `lo >= hi`, else `r.nextInt(hi - lo + 1) + lo` (both ends inclusive). |
| `Util.getRandom(array, r)` | `array[r.nextInt(array.length)]` (one `nextInt` draw). |
| `Rotation.getRandom(r)` | `Util.getRandom` over `[NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90]` (the enum's declaration order; serialized names `none`, `clockwise_90`, `180`, `counterclockwise_90`; the legacy NBT codec uses the constant names `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90`). |
| `Direction.Plane.HORIZONTAL.getRandomDirection(r)` | `Util.getRandom` over `[NORTH, EAST, SOUTH, WEST]` (one `nextInt(4)`). |
| `Util.shuffle(list, r)` | for `i` from `size` down to 2: `j = r.nextInt(i)`; swap the elements at `i - 1` and `j`. (Nothing is drawn for a list of size 0 or 1.) The same loop is used by `Util.toShuffledList(IntStream, r)` on an array of the integers in order. |
| Positional factory (`LegacyPositionalRandomFactory`) | built by `RandomSource.createThreadLocalInstance(seed).forkPositional()`: the stream `LCG(seed)` (identical to `LegacyRandomSource`) draws one `nextLong()` = `F`; `at(pos)` is `LCG(getSeed(pos) xor F)`. |
| Per-position stream of the template engine | `StructurePlaceSettings.getRandom(pos)` is `LCG(getSeed(pos))` when the settings carry no fixed random (none of the settings in this document do). `RuleProcessor` makes the same stream from the block's world position. |
| `Direction` 3-D data values | `DOWN` 0, `UP` 1, `NORTH` 2, `SOUTH` 3, `WEST` 4, `EAST` 5 (declaration order; also the order of `Direction.values()`); steps: `DOWN (0,-1,0)`, `UP (0,1,0)`, `NORTH (0,0,-1)`, `SOUTH (0,0,1)`, `WEST (-1,0,0)`, `EAST (1,0,0)`; opposite pairs `DOWN/UP`, `NORTH/SOUTH`, `WEST/EAST`. |

### 2.2 Rotating a position, and the box of a template piece

`StructureTemplate.transform(pos, mirror, rotation, pivot)` with `Mirror.NONE` (all pieces of this document use `NONE`) maps `(x, y, z)` with
pivot `(px, pz)` as follows (`y` is unchanged):

| Rotation | New `x` | New `z` |
|---|---|---|
| `NONE` | `x` | `z` |
| `CLOCKWISE_90` | `px + pz - z` | `pz - px + x` |
| `CLOCKWISE_180` | `2 px - x` | `2 pz - z` |
| `COUNTERCLOCKWISE_90` | `px - pz + z` | `px + pz - x` |

(The branch for each rotation was identified through the switch table of `StructureTemplate$1`: `COUNTERCLOCKWISE_90` is case 1,
`CLOCKWISE_90` case 2, `CLOCKWISE_180` case 3.) With pivot `(0, 0)`: `CLOCKWISE_90` gives `(-z, x)`, `COUNTERCLOCKWISE_90` gives `(z, -x)`,
`CLOCKWISE_180` gives `(-x, -z)`.

The **box of a template piece** (`StructureTemplate.getBoundingBox(settings, pos)`): with template size `s`, `c0 = transform((0,0,0))`,
`c1 = transform((s.x - 1, s.y - 1, s.z - 1))` (rotation, pivot and mirror of the settings), the box is the per-axis min and max of `c0` and `c1`, moved by
`pos`. The ruin pieces use pivot `(0, 0, 0)` (the default of `StructurePlaceSettings`); shipwreck pieces use pivot `(4, 0, 15)`.

### 2.3 What a template piece does when it is placed (summary of 36-2, as far as it was read here)

`TemplateStructurePiece` stores `templateName` (the identifier string), `templatePosition` (a block position, the template's minimum
corner before rotation), the template and the `StructurePlaceSettings` (rotation, mirror, pivot, processors). Its orientation is fixed to
`NORTH` (so its mirror and rotation fields from 36-1 section 6.4 are `NONE`; the template rotation lives in the settings). Its box is
`template.getBoundingBox(settings, templatePosition)`, computed at construction and again at the start of each `postProcess`.
Its NBT adds `TPX`, `TPY`, `TPZ` (ints) and `Template` (string) to the base keys of 36-1 section 6.7.

`TemplateStructurePiece.postProcess(level, sm, generator, random, chunkBox, chunkPos, pivot)`:

1. `settings.boundingBox = chunkBox`; recompute the piece box from `templatePosition`.
2. `template.placeInWorld(level, templatePosition, templatePosition, settings, random, 2)` (block flags 2). When it returns true:
3. every block of the template (the raw palette blocks, rotated by the settings) that is a **structure block** in `DATA` mode and whose world
   position lies inside the chunk box is passed, in template block order, to `handleDataMarker(metadata, pos, level, random, chunkBox)`;
   the metadata is the structure block's `metadata` string (default empty). Because the list is taken from the raw template,
   a data marker is handled even if a processor would have dropped its block.
4. every **jigsaw** block of the template inside the chunk box is replaced (`setBlockAndUpdate`) by its `final_state` (default `minecraft:air`).
   (None of the 68 templates here contains a jigsaw; the rule is stated for completeness.)

`placeInWorld` (36-2) in the parts these families depend on:

* **Palette**: a template file with several palettes (the shipwreck templates have 8, the ruins 1) uses the palette at index
  `LCG(getSeed(templatePosition)).nextInt(palettes)` (`StructurePlaceSettings.getRandomPalette(palettes, pos)`).
  The same palette is used for the marker list of step 3.
* **Processing**: for each palette block (in palette order), the world position is `transform(blockPos) + templatePosition`. Unless some
  processor of the settings reports `evaluatesEntirePieceState` (the `capped` processor does), blocks outside the chunk box are skipped
  before processing. Each surviving block runs through the processors in list order (`processBlock`); a processor returning "none"
  removes the block. The original and the processed lists stay index-aligned (a block removed by any processor is removed from both).
  Then each processor's `finalizeProcessing(level, templatePosition, pivot, originalList, processedList, settings)` runs in list order and may
  replace entries of the processed list. Finally only blocks inside the chunk box are written.
* **Writing**: a block with NBT first has a barrier written at its position (flags 820), then the block with flags 2; if the new block entity is a
  randomizable container (a chest), its `LootTableSeed` NBT is **set to `random.nextLong()`** (one draw from the placement random per such block,
  in processed-block order) before the entity loads the NBT. The draw is guarded by the debug constant `SharedConstants.DEBUG_STRUCTURE_EDIT_MODE` and is skipped when it is true; this document assumes it is false (normal operation), and the draw counts of section 4.3 and the worked examples rely on that. Waterlogging is applied (`LiquidSettings.APPLY_WATERLOGGING` is the default): where the
  world already has a water source at a position and the placed block can hold water, it becomes waterlogged (36-2).
* A template with no palette or no blocks places nothing.

### 2.4 The processors that these structures use

| Processor | Behaviour as read |
|---|---|
| `rot` (`BlockRotProcessor`, field `integrity`, optional `rottable_blocks`) | Per block: `r = LCG(getSeed(blockWorldPosition))`; if `rottable_blocks` is present and the block is not in it, keep the block; otherwise keep it iff `r.nextFloat() <= integrity`, else remove it. (The ruins and no other piece here set `rottable_blocks`, so every block is subject.) The first float of the per-block stream is the only draw. |
| `block_ignore` with `STRUCTURE_AND_AIR` | remove (do not place) blocks whose block is `air` or `structure_block`. (The other presets in the jar ignore only one of the two; only this one is used here.) Consequence: the template's air does not carve the water or terrain, and the structure-block data markers are never placed. |
| `rule` (`RuleProcessor`, list of `ProcessorRule`) | Per block: `r = LCG(getSeed(blockWorldPosition))`; for each rule in order: if `inputPredicate.test(state, pos, r)` and `locationPredicate.testAgainstWorldState(level, pos, r)` and `positionPredicate.test(origPos, pos, pivot, r)` all hold, return a block at the same position with the rule's `output_state` and NBT = `blockEntityModifier.apply(r, nbt)`; if no rule matches, return the block unchanged. The rule used here has `inputPredicate` = `block_match` of one block (sand or gravel), `locationPredicate` = always true, `positionPredicate` = always true (the default), `output_state` = suspicious sand or suspicious gravel (default state) and modifier `append_loot`. |
| `append_loot` (`AppendLoot`, field `loot_table`) | returns a **copy** of the NBT (a new empty compound when the block had none) with `LootTable` = the table's resource key and `LootTableSeed` = `r.nextLong()` (the first `nextLong()` of the per-block stream of the rule, for the block's world position). |
| `capped` (`CappedProcessor`, fields `delegate`, `limit`) | `evaluatesEntirePieceState` = true. `processBlock` is the identity. Its `finalizeProcessing`: if `limit.maxInclusive() == 0` or the processed list is empty, or the two list sizes differ, return the processed list unchanged. Otherwise: `r = positional factory of seed (world seed)` `.at(templatePosition)` (section 2.1; the argument is the template position the piece is being placed at, with its current `y`); `n = min(limit.sample(r), processedList.size())` (a constant limit draws nothing); if `n < 1` return unchanged; build the index list `0 .. size-1`, shuffle it with `r` (section 2.1); walk the shuffled indices while fewer than `n` blocks have been changed: run the delegate's `processBlock` on the pair (original block `i`, processed block `i`); if the result is not none and differs from the processed block, store it as processed block `i` and count one change. The pass therefore replaces the **first `n` matching blocks in the shuffled order**, over the whole piece (not only the part inside the chunk box). |

---

## 3. Ocean ruins (`OceanRuinStructure`, `OceanRuinPieces`)

### 3.1 Template lists (`OceanRuinPieces`)

All template identifiers are in the default namespace, under `structure/underwater_ruin/` (files `<name>.nbt`). The arrays, in index order:

| Array | Length | Members in index order |
|---|---|---|
| `WARM_RUINS` (small, warm) | 8 | `warm_1` .. `warm_8` |
| `RUINS_BRICK` (small, cold, intact) | 8 | `brick_1` .. `brick_8` |
| `RUINS_CRACKED` (small, cold, cracked) | 8 | `cracked_1` .. `cracked_8` |
| `RUINS_MOSSY` (small, cold, mossy) | 8 | `mossy_1` .. `mossy_8` |
| `BIG_WARM_RUINS` | 4 | `big_warm_4`, `big_warm_5`, `big_warm_6`, `big_warm_7` |
| `BIG_RUINS_BRICK` | 4 | `big_brick_1`, `big_brick_2`, `big_brick_3`, `big_brick_8` |
| `BIG_RUINS_CRACKED` | 4 | `big_cracked_1`, `big_cracked_2`, `big_cracked_3`, `big_cracked_8` |
| `BIG_RUINS_MOSSY` | 4 | `big_mossy_1`, `big_mossy_2`, `big_mossy_3`, `big_mossy_8` |

Template sizes (read from the NBT `size` list `[x, y, z]`): every small template is `[6, 7, 7]` (294 block entries); every big template is
`[16, 16, 16]` (4096 entries). All 48 files exist in the jar (`warm_*` 8, `brick_*` 8, `cracked_*` 8, `mossy_*` 8, `big_brick_*` 4,
`big_cracked_*` 4, `big_mossy_*` 4, `big_warm_*` 4). Each file has one palette. The 48 files contain **47 `chest` markers and 51 `drowned`
markers** in total (structure blocks in `DATA` mode; the `metadata` strings are exactly `chest` and `drowned`).

Two constants of the class: the **archaeology processors**, built by one helper `archyRuleProcessor(inputBlock, outputBlock, lootTable)` =
`capped(delegate = rule[ input block_match(inputBlock) -> output_state outputBlock, modifier append_loot(lootTable) ], limit = constant 5)`:

| Name | input block | output block | loot table |
|---|---|---|---|
| `WARM_SUSPICIOUS_BLOCK_PROCESSOR` | `sand` | `suspicious_sand` | `archaeology/ocean_ruin_warm` |
| `COLD_SUSPICIOUS_BLOCK_PROCESSOR` | `gravel` | `suspicious_gravel` | `archaeology/ocean_ruin_cold` |

### 3.2 The structure start (`findGenerationPoint`, `generatePieces`)

1. `onTopOfChunkCenter(context, OCEAN_FLOOR_WG, consumer)` (36-1 section 5.4): if no valid biome can exist at the chunk centre the start is absent;
   otherwise the stub position is `(chunkMidX, firstOccupiedHeight(OCEAN_FLOOR_WG), chunkMidZ)` (used for the biome test and for locating, 36-1 section 5.3) and
   `consumer` is the piece generator below.
2. Piece generator (the start random `r`, section 2.1):
   1. `pos = (chunkMinX, 90, chunkMinZ)` (the fixed `y = 90` is a placeholder; the real `y` is computed when the piece is placed, section 3.5).
   2. `rotation = Rotation.getRandom(r)` (one `nextInt(4)`).
   3. `addPieces(pos, rotation, builder, r, structure)` (section 3.3).

### 3.3 `addPieces`

Let `lp = large_probability`, `cp = cluster_probability` of the structure element (data: 0.3 and 0.9 for both ruin structures).

1. `isLarge = (r.nextFloat() <= lp)` (note **less-than-or-equal**).
2. `integrity = 0.9` if `isLarge`, else `0.8`.
3. `addPiece(pos, rotation, isLarge, integrity)` (section 3.4).
4. If `isLarge`: draw `r.nextFloat()`; if it is `<= cp`, run the **cluster** (section 3.6). (The draw is made only for large ruins.)

### 3.4 `addPiece(pos, rotation, large, integrity)` (template choice)

The piece constructor is `OceanRuinPiece(templateId, pos, rotation, integrity, biomeTemp, large)` (section 3.5).

* **Warm structure**: one piece. Template = `BIG_WARM_RUINS[r.nextInt(4)]` when `large`, else `WARM_RUINS[r.nextInt(8)]`; the piece gets `integrity` as passed.
* **Cold structure**: three pieces, all at the same `pos` and `rotation`, created and added in this order. First one index `i = r.nextInt(L)` is drawn,
  where `L = 4` when `large` (the big arrays) and `L = 8` otherwise; then:

| Order | Template | Integrity |
|---|---|---|
| 1 | `BIG_RUINS_BRICK[i]` or `RUINS_BRICK[i]` | the `integrity` argument (0.9 large, 0.8 small) |
| 2 | `BIG_RUINS_CRACKED[i]` or `RUINS_CRACKED[i]` | `0.7` |
| 3 | `BIG_RUINS_MOSSY[i]` or `RUINS_MOSSY[i]` | `0.5` |

The three templates have the same footprint; the later pieces are placed over the earlier ones, and each piece removes (rots away) the blocks whose
own per-block float exceeds its integrity (section 2.4), so what remains of the intact template is overlaid by the cracked and mossy variants'
blocks where those survive their lower integrity. All three pieces are `isLarge = large`.

### 3.5 The piece (`OceanRuinPiece`)

| Field | Meaning |
|---|---|
| `biomeType` | `WARM` or `COLD` (ordinal 0, 1; the structure's `biome_temp`) |
| `integrity` | float, the `BlockRotProcessor` integrity |
| `isLarge` | boolean |

**Settings**: rotation as given, `Mirror.NONE`, pivot `(0,0,0)`, processors in this order: (1) `rot(integrity)`, (2) `block_ignore STRUCTURE_AND_AIR`,
(3) the archaeology processor: **cold** uses `COLD_SUSPICIOUS_BLOCK_PROCESSOR`, **warm** uses `WARM_SUSPICIOUS_BLOCK_PROCESSOR`.

**Serialization** (a template piece, 36-1 section 6.7 and section 2.3 above): the base keys, `TPX`, `TPY`, `TPZ`, `Template` and the type-specific keys
`Rot` (the rotation by its legacy constant name), `Integrity` (float, default 0), `BiomeType` (the enum by its legacy constant name `WARM` or `COLD`; read: `Rotation.LEGACY_CODEC` and `OceanRuinStructure$Type.LEGACY_CODEC` are built with `ExtraCodecs.legacyEnum`, whose encoder is `Enum.toString`, which neither enum overrides, and whose decoder is `valueOf`, so the stored strings are `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90` and `WARM`, `COLD`; the lower-case `getSerializedName` values (`warm`, `cold`; `none`, `clockwise_90`, `180`, `counterclockwise_90`) belong to the data-pack codec, not to the piece NBT), `IsLarge` (boolean, default false). `Rot` and `BiomeType` are required: a missing value is a load error for the piece.
The piece-type id is `orp`.

**`postProcess`** (placement of one chunk's part; the height adaptation runs on every call, from the heightmap at that time):

1. `h = level.getHeight(OCEAN_FLOOR_WG, templatePosition.x, templatePosition.z)` (the heightmap value: the first free `y` above the highest block that counts for
   `OCEAN_FLOOR_WG`, 35-1 section 4); set `templatePosition.y = h`.
2. `corner = transform((size.x - 1, 0, size.z - 1), NONE, rotation, (0,0,0)) + templatePosition` (section 2.2; `size` is the template size).
3. `templatePosition.y = adaptedHeight(templatePosition, corner)` (below).
4. Run `TemplateStructurePiece.postProcess` (section 2.3).

`adaptedHeight(p, corner)` (`OceanRuinPiece.getHeight`): let `top = p.y`, `base = p.y - 1`, `lowest = 512`, `count = 0`.
For every `(x, z)` of the rectangle spanned by `p` and `corner` (all columns between the two x values and the two z values, inclusive; one layer, because `corner.y = p.y`):

1. `y = base`; while the block at `(x, y, z)` is air, **or** has a water fluid state, **or** is in the block tag `ice`, **and** `y > level.minY + 1`: `y = y - 1`.
2. `lowest = min(lowest, y)`.
3. If `y < base - 2`: `count = count + 1`.

After all columns: `dx = |p.x - corner.x|`. If `base - lowest > 2` **and** `count > dx - 2`, the result is `lowest + 1`; otherwise the result is `top` (`p.y`).
In words: the ruin sits on the heightmap value of its anchor column, unless the sea floor under it is mostly (more than `dx - 2` columns) more than 2 blocks lower
than that anchor's floor and at least one column is more than 2 lower, in which case it is lowered to one above the lowest floor found. `dx` is the
x extent of the rotated footprint minus 1 (5 for a small template with rotation `NONE` or `CLOCKWISE_180`, 6 for the quarter turns; 15 for a big one).

**`handleDataMarker(metadata, pos, level, random, box)`** (called by section 2.3 step 3 for each marker inside the chunk box):

| `metadata` | Effect |
|---|---|
| `chest` | write `minecraft:chest` (default state: facing north, type single) at `pos` with `waterlogged` = whether the fluid state at `pos` is water (block flags 2); if the block entity there is a chest, set its loot table to `chests/underwater_ruin_big` when the piece's `isLarge`, else `chests/underwater_ruin_small`, with seed `random.nextLong()`. No chest orientation logic runs (the chest always faces north, whatever the rotation). |
| `drowned` | create a `drowned` (spawn reason `STRUCTURE`); if created: `setPersistenceRequired()`, place it at `pos` with yaw 0, pitch 0 (`snapTo(BlockPos, 0, 0)`, the block centre), `finalizeSpawn(level, difficulty at pos, STRUCTURE, no group data)`, add it with passengers; then write **air** at `pos` if `pos.y > level.getSeaLevel()`, else **water** (flags 2). |
| anything else | nothing |

(The marker blocks are not placed by the template, because `block_ignore STRUCTURE_AND_AIR` removes them; so the position still holds whatever was there, normally water.)
The mob details (equipment, baby and passenger rules of `finalizeSpawn`) are the drowned entry of the mob documents (44 part 2 section 10.9 records the same marker behaviour).

### 3.6 The cluster (`addClusterRuins`)

Inputs: the start random `r`, the main ruin's `rotation` and anchor `pos = (X, 90, Z)`. (The cluster applies only to a large ruin; cluster members are always small.)

1. `a = (X, 90, Z)`; `b = a + transform((15, 0, 15), NONE, rotation, (0,0,0))` (section 2.2).
2. `mainBox = fromCorners(a, b)` (a box with `y = 90` only).
3. `base = (min(a.x, b.x), 90, min(a.z, b.z))`: the lowest corner of the main ruin's footprint.
4. Build the list of **eight candidate anchors** `base + offsets` in this order. Every `nextInt(lo, hi)` below is `Mth.nextInt(r, lo, hi)` (inclusive); within one candidate the `x` offset is drawn before the `z` offset; `y` offset 0.

| # | `x` offset | `z` offset |
|---|---|---|
| 1 | `-16 + nextInt(1, 8)` | `16 + nextInt(1, 7)` |
| 2 | `-16 + nextInt(1, 8)` | `0 + nextInt(1, 7)` |
| 3 | `-16 + nextInt(1, 8)` | `-16 + nextInt(4, 8)` |
| 4 | `nextInt(1, 7)` | `16 + nextInt(1, 7)` |
| 5 | `nextInt(1, 7)` | `-16 + nextInt(4, 6)` |
| 6 | `16 + nextInt(1, 7)` | `16 + nextInt(3, 8)` |
| 7 | `16 + nextInt(1, 7)` | `0 + nextInt(1, 7)` |
| 8 | `16 + nextInt(1, 7)` | `-16 + nextInt(4, 8)` |

   All sixteen draws are made, in this order, before step 5.
5. `n = nextInt(4, 8)`.
6. Repeat `n` times: if the candidate list is empty, do nothing in this repetition. Otherwise:
   1. `k = r.nextInt(list.size())`; remove and take candidate `k` (later candidates shift down).
   2. `rot = Rotation.getRandom(r)`.
   3. `c = candidate + transform((5, 0, 6), NONE, rot, (0,0,0))`; `box = fromCorners(candidate, c)`.
   4. If `box` intersects `mainBox` (the full 3-D test of 36-1 section 6.3, which here is a footprint test because both have `y = 90`), skip this repetition (nothing else is drawn).
   5. Otherwise `addPiece(candidate, rot, large = false, integrity = 0.8)` (section 3.4, drawing its template index as there).

Cluster members are not checked against each other or against the terrain; their boxes can overlap each other. The anchors are at most 23 blocks from `base` along x or z
(so a cluster fits in the 3 x 3 chunk write window around the start chunk together with the main ruin; the clipping to the chunk write box of each pass does the rest).

### 3.7 Suspicious sand and gravel

Because the archaeology processor is `capped(limit 5)`, in every placement of a piece at most 5 blocks of the template that are sand (warm) or gravel (cold) after the earlier processors
(`rot` and `block_ignore`) become suspicious sand or gravel. Which blocks: section 2.4, `capped`: the shuffled order of the piece's surviving block list from
the stream `LCG(getSeed(templatePosition) xor F)`, where `F` is the first `nextLong()` of `LCG(worldSeed)`. Each converted block carries `LootTable` = `archaeology/ocean_ruin_warm`
(warm) or `archaeology/ocean_ruin_cold` (cold) and `LootTableSeed` = the first `nextLong()` of `LCG(getSeed(blockWorldPosition))`. Note that `templatePosition` is the **adapted** position
(section 3.5 step 3), the pass runs for every chunk part but the cap is on the whole piece, so each chunk part converts the same blocks (those inside its chunk box are written).
The counts are data (counted in the NBT): small warm templates contain 34 to 56 sand blocks, small cold templates 25 to 43 gravel blocks, big warm templates 202 to 222 sand, big cold templates 192 to 239 gravel (the other of the two blocks occurs in small numbers, e.g. 0 to 24 gravel in big warm templates, and is not converted); the processor converts at most 5 of the matching blocks of one piece either way. Brushing and the loot of the resulting block entity are 31 part 4 and 26.

---

## 4. Shipwrecks (`ShipwreckStructure`, `ShipwreckPieces`)

### 4.1 Template lists (`ShipwreckPieces`)

Identifiers are `shipwreck/<name>` in the default namespace. The two lists, in index order (the `degraded` variants are the rotted ones; the pairs are
`<name>` and `<name>_degraded`):

| Index | `STRUCTURE_LOCATION_OCEAN` (20) | `STRUCTURE_LOCATION_BEACHED` (11) |
|---|---|---|
| 0 | `with_mast` | `with_mast` |
| 1 | `upsidedown_full` | `sideways_full` |
| 2 | `upsidedown_fronthalf` | `sideways_fronthalf` |
| 3 | `upsidedown_backhalf` | `sideways_backhalf` |
| 4 | `sideways_full` | `rightsideup_full` |
| 5 | `sideways_fronthalf` | `rightsideup_fronthalf` |
| 6 | `sideways_backhalf` | `rightsideup_backhalf` |
| 7 | `rightsideup_full` | `with_mast_degraded` |
| 8 | `rightsideup_fronthalf` | `rightsideup_full_degraded` |
| 9 | `rightsideup_backhalf` | `rightsideup_fronthalf_degraded` |
| 10 | `with_mast_degraded` | `rightsideup_backhalf_degraded` |
| 11 | `upsidedown_full_degraded` | |
| 12 | `upsidedown_fronthalf_degraded` | |
| 13 | `upsidedown_backhalf_degraded` | |
| 14 | `sideways_full_degraded` | |
| 15 | `sideways_fronthalf_degraded` | |
| 16 | `sideways_backhalf_degraded` | |
| 17 | `rightsideup_full_degraded` | |
| 18 | `rightsideup_fronthalf_degraded` | |
| 19 | `rightsideup_backhalf_degraded` | |

So an ocean wreck chooses uniformly among 20 entries (with the undamaged mast ship and the right-side-up variants listed once undamaged in
the first ten and once degraded in the last ten, and the upside-down and sideways variants likewise), and a beached wreck among 11 (no
upside-down variants). The 20 template files exist in the jar. Their sizes (NBT `size`, `[x, y, z]`; a degraded variant has the same size as its intact twin): `with_mast`: `[9, 21, 28]`; `rightsideup_full`, `sideways_full`, `upsidedown_full`: `[9, 9, 28]`; `rightsideup_fronthalf` `[9, 9, 24]`, `sideways_fronthalf` `[9, 9, 24]`, `upsidedown_fronthalf` `[9, 9, 22]`; `rightsideup_backhalf` `[9, 9, 16]`, `sideways_backhalf` `[9, 9, 17]`, `upsidedown_backhalf` `[9, 9, 16]`. Every file has **8 palettes**; across the palettes the wood types differ (oak, spruce, jungle, dark oak, birch
planks, logs and stairs in different combinations, e.g. palette 0 of `with_mast`: oak and spruce, palette 7: birch and oak).
The 20 files contain **14 `supply_chest`, 16 `map_chest` and 14 `treasure_chest` markers** (a structure block in `DATA` mode sitting directly **above** a chest block that is part of the template).

Constants: `PIVOT = (4, 0, 15)`; `NUMBER_OF_BLOCKS_ALLOWED_IN_WORLD_GEN_REGION = 32` (named in the class; used in `isTooBigToFitInWorldGenRegion`, section 4.3).
`MARKERS_TO_LOOT`: `map_chest` -> `chests/shipwreck_map`, `treasure_chest` -> `chests/shipwreck_treasure`, `supply_chest` -> `chests/shipwreck_supply`.

### 4.2 The structure start

1. `heightmap = WORLD_SURFACE_WG` if `is_beached` else `OCEAN_FLOOR_WG`; `onTopOfChunkCenter(context, heightmap, consumer)` (36-1 section 5.4).
2. Piece generator (start random `r`): `rotation = Rotation.getRandom(r)`; `pos = (chunkMinX, 90, chunkMinZ)`; `piece = addRandomPiece(pos, rotation, builder, r, isBeached)`:
   template = `Util.getRandom(isBeached ? BEACHED : OCEAN, r)` (one `nextInt(11)` or `nextInt(20)`), piece added to the builder.
3. If `piece.isTooBigToFitInWorldGenRegion()`, adjust the height **immediately** (this branch is dead for the shipped templates, section 4.3): `box = piece.box`; for a beached wreck
   `y = piece.calculateBeachedPosition(getLowestY(context, box.minX, box.xSpan, box.minZ, box.zSpan), r)`, for an ocean wreck `y = getMeanFirstOccupiedHeight(context, box.minX, box.xSpan, box.minZ, box.zSpan)`;
   then `piece.adjustPositionHeight(y)`. (The argument order passed to `getLowestY` is `(minX, xSpan, minZ, zSpan)` while 36-1 section 5.4 gives its parameter order as `(x, z, sizeX, sizeZ)`; the call therefore
   samples corners at `(minX, xSpan)`, `(minX, xSpan + zSpan)`, `(minX + minZ, xSpan)` and `(minX + minZ, xSpan + zSpan)`; this is how the artifact is written, Open question 5.)

### 4.3 The piece (`ShipwreckPiece`)

Fields: `isBeached` and `heightAdjusted` (booleans). **Settings**: the rotation as given, `Mirror.NONE`, pivot `(4, 0, 15)`, one processor: `block_ignore STRUCTURE_AND_AIR`
(so there is no rot and no archaeology). **Serialization**: base keys, `TPX`, `TPY`, `TPZ`, `Template`, plus `isBeached` (boolean, default false), `Rot` (legacy constant name, required) and `height_adjusted`
(boolean, default false). Piece-type id `shipwreck`.

`isTooBigToFitInWorldGenRegion()` = `template.size.x > 32` **or** `template.size.y > 32` (the z size is not tested). With the sizes of section 4.1 (maximum x 9, y 21) it is **false for all
20 templates**; it can only be true for a replaced template.

**`postProcess`**:

1. If `heightAdjusted` or `isTooBigToFitInWorldGenRegion()`: run `TemplateStructurePiece.postProcess` (section 2.3) and stop.
2. Otherwise compute and apply the height once (this happens in the first chunk pass that reaches the piece; afterwards `heightAdjusted` is true and the saved
   `templatePosition.y` is used):
   * `heightmap` = `WORLD_SURFACE_WG` if beached, else `OCEAN_FLOOR_WG`; `size` = the template size; `area = size.x * size.z`.
   * `minY = level.maxY + 1`, `sum = 0`.
   * If `area == 0`: `sum = level.getHeight(heightmap, templatePosition.x, templatePosition.z)`.
   * Else `corner = templatePosition + (size.x - 1, 0, size.z - 1)` (**not rotated**: the rectangle is the unrotated footprint from the template position, whatever the rotation), and for every column `(x, z)` of the rectangle spanned by `templatePosition` and `corner`:
     `h = level.getHeight(heightmap, x, z)`; `sum = sum + h`; `minY = min(minY, h)`. Then `sum = sum / area` (integer division, truncating).
   * `y = calculateBeachedPosition(minY, random)` when beached, else `y = sum` (the mean height).
   * `adjustPositionHeight(y)`: `heightAdjusted = true` and `templatePosition = (x, y, z)`.
3. Run `TemplateStructurePiece.postProcess`.

`calculateBeachedPosition(lowest, random) = lowest - size.y / 2 - random.nextInt(3)` (`size.y / 2` is integer division; the draw is from the **placement random** passed to
`postProcess`; in the dead branch of section 4.2 it is the start random).
Numerical examples: a beached `with_mast` (`size.y = 21`) at minimum surface height 64 gives `64 - 10 - d` with `d` in 0..2, i.e. 54, 53 or 52; a beached `rightsideup_full` (`size.y = 9`) gives
`64 - 4 - d`, i.e. 60, 59 or 58. An ocean wreck sits with its template origin at the mean floor height of the unrotated 9 x 28 (or smaller) rectangle.

**`handleDataMarker(metadata, pos, level, random, box)`**: look the metadata up in `MARKERS_TO_LOOT`; if it is a key, call
`RandomizableContainer.setBlockEntityLootTable(level, random, pos.below(), key)`: read the block entity at `pos.below()` and, if it is a randomizable container, set its loot table to `key` with seed `random.nextLong()`
(the draw happens only when such a block entity exists). Other metadata does nothing.

**Draws per chest.** The template's chest blocks carry NBT (`{Items: [], id: chest}`), so during the block writing of section 2.3 each chest inside the chunk box consumes **one `nextLong()`** of the placement random for
its `LootTableSeed` (in processed-block order), and then its marker consumes another one in the marker pass; the second value is the seed that remains in the block entity together with the table.
(The facing of each chest is the template's, rotated with the piece; the loot-table name is the only thing the marker adds.)

### 4.4 Rotted, beached and ocean wrecks

* **Rotted** (degraded) wrecks are not produced by a processor: they are the `_degraded` template files, chosen from the lists above.
* **Beached** wrecks use the `shipwreck_beached` structure in `is_beach` biomes, a start heightmap of `WORLD_SURFACE_WG`, the 11-entry list and the `calculateBeachedPosition` rule: they sink into the sand
  by half their height plus 0 to 2.
* **Ocean** wrecks use the `shipwreck` structure in ocean biomes, the 20-entry list (upside-down and sideways hulls included) and the mean-floor-height rule.

---

## 5. The ocean monument (`OceanMonumentStructure`, `OceanMonumentPieces`)

The monument is the only structure here with no template file. The start contains **one** piece, the `MonumentBuilding` (type id `omb`), whose box is
58 x 23 x 58; when it is created it also creates, **inside itself**, a list of **child pieces** (rooms, wings and a penthouse) that are never put in the start's
piece list, are not serialized, and are rebuilt by running the same code again (section 5.11). The building places itself and then calls its children.

Block legend for all tables of section 5: **B** = `prismarine_bricks` (`BASE_LIGHT`; also `DOT_DECO_DATA`), **P** = `prismarine` (`BASE_GRAY`),
**D** = `dark_prismarine` (`BASE_BLACK`), **L** = `sea_lantern` (`LAMP_BLOCK`), **G** = `gold_block`, **S** = `wet_sponge`, **water** = a water-clearing operation (section 5.6).
`FILL_BLOCK` = the default state of `water` (a source block).

### 5.1 The start (`findGenerationPoint`)

1. `x = chunkMinX + 9`, `z = chunkMinZ + 9` (`ChunkPos.getBlockX(9)`, `getBlockZ(9)`).
2. `biomes = biomeResolver.getBiomesWithin(x, seaLevel, z, 29)` (`BiomeResolver.getBiomesWithin(x, y, z, radius)`): in **quart** coordinates, from `qx = (x - 29) >> 2` to `(x + 29) >> 2`, `qy`
   from `(seaLevel - 29) >> 2` to `(seaLevel + 29) >> 2`, `qz` from `(z - 29) >> 2` to `(z + 29) >> 2` (all inclusive), the set of the biomes returned by `getNoiseBiome(qx, qy, qz)` at each cell (for
   sea level 63 that is `qy` 8 to 23; for a chunk at `chunkMinX = 0` it is `qx` from `-5` to `9`, 15 values). `seaLevel` is the chunk generator's sea level.
3. If **any** biome of the set is not in the biome tag `required_ocean_monument_surrounding` (data: `is_ocean` or `is_river`), the start is absent.
4. Otherwise `onTopOfChunkCenter(context, OCEAN_FLOOR_WG, consumer)` (36-1 section 5.4: the coarse biome test of the chunk centre, then the stub at the chunk centre; the stub's `y` is used only for the biome
   check and for locating).
5. Piece generator: `top = createTopPiece(chunkPos, r)`:
   `x0 = chunkMinX - 29`, `z0 = chunkMinZ - 29`, `dir = Direction.Plane.HORIZONTAL.getRandomDirection(r)` (one `nextInt(4)`, section 2.1),
   `MonumentBuilding(r, x0, z0, dir)`; the builder gets that one piece.

The building box is **independent of the terrain**: `StructurePiece.makeBoundingBox(x0, 39, z0, dir, 58, 23, 58)` = `(x0, 39, z0)` to `(x0 + 57, 61, z0 + 57)` for every direction (width and depth are both 58), i.e. x and z from
`chunkMinX - 29` to `chunkMinX + 28`, and `y` from 39 to 61 inclusive. (The class constants `WIDTH 58`, `HEIGHT 22`, `DEPTH 58`, `TOP_POSITION 61`, `BIOME_RANGE_CHECK 29`: the box height is 23, not the constant 22.)
The box is therefore centred on the start chunk's minimum corner offset; the monument's lowest layer is at `y = 39` and its top at `y = 61`, a fixed band below sea level 63.

### 5.2 Grid, indices and the room cell

The rooms lie on a grid of **5 (x) by 5 (z) by 3 (y)** cells, one cell being **8 x 4 x 8** blocks (`GRIDROOM_WIDTH 8`, `GRIDROOM_HEIGHT 4`, `GRIDROOM_DEPTH 8`; `GRID_SIZE 75`).
Room index: `index(x, y, z) = y * 25 + z * 5 + x` (so `x = index % 5`, `z = (index / 5) % 5`, `y = index / 25`). Only some cells hold a room:

| Layer | Cells with a room | Count |
|---|---|---|
| `y = 0` | `x` 0..4, `z` 0..3 | 20 |
| `y = 1` | `x` 0..4, `z` 0..3 | 20 |
| `y = 2` | `x` 1..3, `z` 0..1 | 6 |

That is **46 grid rooms**. Three further "special" definitions are created outside the grid: the **penthouse** with index 1003, the **left wing** 1001 and the **right wing** 1002
(`PENTHOUSE_INDEX`, `LEFTWING_INDEX`, `RIGHTWING_INDEX`); a room with `index >= 75` is "special" (`isSpecial`). Named cells: `GRIDROOM_SOURCE_INDEX = index(2,0,0)` = 2
(the entry room), `GRIDROOM_TOP_CONNECT_INDEX = index(2,2,0)` = 52 (connects up to the penthouse), `GRIDROOM_LEFTWING_CONNECT_INDEX = index(0,1,0)` = 5 and
`GRIDROOM_RIGHTWING_CONNECT_INDEX = index(4,1,0)` = 9 (each connects "south" to its wing).

### 5.3 The room graph (`RoomDefinition`, `generateRoomGraph`)

A `RoomDefinition` has: `index`, `connections[6]` (neighbouring definitions by 3-D data value, none by default), `hasOpening[6]` (booleans, false by default), `claimed`, `isSource`, `scanIndex`.

* `setConnection(dir, other)`: `connections[dir] = other` and `other.connections[opposite(dir)] = this`.
* `updateOpenings()`: `hasOpening[d] = (connections[d] exists)` for `d` 0..5.
* `findSource(scan)`: true if `isSource`; else set `scanIndex = scan` and return true iff some `d` in 0..5 has a connection whose `hasOpening[d]` is true, whose `scanIndex != scan`, and
  whose own `findSource(scan)` is true (depth first, in order of `d`); otherwise false.
* `countOpenings()`: the number of true `hasOpening` entries.

`generateRoomGraph(r)` (called by the building constructor, with the start random):

1. Create the 46 definitions of section 5.2 (no random draw). `sourceRoom` = the definition of index 2.
2. **Connections**: for `x` 0..4 (outer), `z` 0..4, `y` 0..2 (inner), skipping missing cells: for each `Direction` in `Direction.values()` order (`DOWN, UP, NORTH, SOUTH, WEST, EAST`), take the
   neighbour cell `(x + stepX, y + stepY, z + stepZ)`; skip it if outside the 5 x 3 x 5 range or without a room. If the neighbour's `z` equals this room's `z` (a step along x or y) call
   `setConnection(direction, neighbour)`; **otherwise (a step along z) call `setConnection(opposite(direction), neighbour)`**. So the connection slots for the z axis are *mirrored*: the slot
   `NORTH` of a room leads to the room at `z + 1` and the slot `SOUTH` to the room at `z - 1`. (This is the artifact's code; all later rules use the slots, so the layout in the world follows it, section 5.5.)
   The grid has 36 links along x, 26 along y and 33 along z: **95** links.
3. Specials: create definitions 1003 (penthouse), 1001 (left wing), 1002 (right wing). `setConnection(UP, penthouse)` on the room of index 52; `setConnection(SOUTH, leftWing)` on index 5;
   `setConnection(SOUTH, rightWing)` on index 9. The three specials are marked `claimed`. The source room gets `isSource = true`. (98 links in all.)
4. **Core room**: `x = r.nextInt(4)`, `coreRoom` = the definition at `(x, 0, 2)`. It is marked `claimed`, and so are the seven cells that complete a 2 x 2 x 2 block with it:
   `connections[EAST]`, `connections[NORTH]` (the cell at `z + 1`), `connections[EAST].connections[NORTH]`, `connections[UP]`, `connections[EAST].connections[UP]`, `connections[NORTH].connections[UP]` and
   `connections[EAST].connections[NORTH].connections[UP]`. (So the core occupies `x`, `x + 1`, `z` 2..3, `y` 0..1.)
5. List the 46 grid definitions in index order (the order of the array), call `updateOpenings()` on each, and also on the penthouse definition (not on the two wing definitions). Then `Util.shuffle(list, r)` (section 2.1).
6. **Pruning**: `scan = 1`. For each definition `R` of the shuffled list, in order: `removed = 0`, `tries = 0`; while `removed < 2` and `tries < 5`:
   1. `tries += 1`; `d = r.nextInt(6)` (**always drawn**, also when it turns out to be useless).
   2. If `R.hasOpening[d]`: let `o` = the 3-D value of the opposite of direction `d`; set `R.hasOpening[d] = false` and `R.connections[d].hasOpening[o] = false`;
      then `a = R.findSource(scan); scan += 1`; if `a` then `b = R.connections[d].findSource(scan); scan += 1`; if both are true, `removed += 1` (the opening stays closed);
      otherwise set both `hasOpening` flags back to true. (`b` is not evaluated when `a` is false, and `scan` is incremented only for evaluated calls.)
7. Append the penthouse, left wing and right wing definitions (in that order) to the list and return it.

Invariant: every opening that is closed leaves both of its rooms still reachable from the source through open connections (it is closed only if both ends still reach the source), so the open-door graph remains
connected. Connections to the wing definitions are never closed (their `hasOpening` flags are false from the start, so the search from a grid room through that link fails and the flags are restored).

### 5.4 Room fitting and piece creation (`MonumentBuilding` constructor)

Given the start random `r`, orientation `dir`, anchor `(x0, z0)` (section 5.1):

1. `box = makeBoundingBox(x0, 39, z0, dir, 58, 23, 58)`; `setOrientation(dir)`; `childPieces = []`.
2. `rooms = generateRoomGraph(r)` (draws of section 5.3). `sourceRoom.claimed = true`.
3. `childPieces.add(EntryRoom(dir, sourceRoom))`, then `childPieces.add(CoreRoom(dir, coreRoom))`.
4. The **fitters**, tried in this order: `FitDoubleXYRoom`, `FitDoubleYZRoom`, `FitDoubleZRoom`, `FitDoubleXRoom`, `FitDoubleYRoom`, `FitSimpleTopRoom`, `FitSimpleRoom`.
5. For each definition in `rooms` (the shuffled list followed by the three specials): skip it if `claimed` or special; otherwise the first fitter whose `fits(def)` is true creates the piece and
   claims its cells; the piece is appended to `childPieces`; no other fitter is tried.

| Fitter | `fits(def)` is true iff (slots as in section 5.3; "free" = not `claimed`) | On creation: claims | Piece (cells x, y, z) |
|---|---|---|---|
| `FitDoubleXY` | `def.open[EAST]` and `def.conn[EAST]` free and `def.open[UP]` and `def.conn[UP]` free and, with `e = def.conn[EAST]`, `e.open[UP]` and `e.conn[UP]` free | `def`, `def.conn[EAST]`, `def.conn[UP]`, `def.conn[EAST].conn[UP]` | `OceanMonumentDoubleXYRoom` (2, 2, 1) |
| `FitDoubleYZ` | the same with `NORTH` (the cell at `z + 1`) in place of `EAST` | `def`, `conn[NORTH]`, `conn[UP]`, `conn[NORTH].conn[UP]` | `OceanMonumentDoubleYZRoom` (1, 2, 2) |
| `FitDoubleZ` | `def.open[NORTH]` and `def.conn[NORTH]` free | `def`, `def.conn[NORTH]` | `OceanMonumentDoubleZRoom` (1, 1, 2) |
| `FitDoubleX` | `def.open[EAST]` and `def.conn[EAST]` free | `def`, `def.conn[EAST]` | `OceanMonumentDoubleXRoom` (2, 1, 1) |
| `FitDoubleY` | `def.open[UP]` and `def.conn[UP]` free | `def`, `def.conn[UP]` | `OceanMonumentDoubleYRoom` (1, 2, 1) |
| `FitSimpleTop` | none of `open[WEST]`, `open[EAST]`, `open[NORTH]`, `open[SOUTH]`, `open[UP]` is true (the `DOWN` flag is not tested) | `def` | `OceanMonumentSimpleTopRoom` (1, 1, 1) |
| `FitSimple` | always | `def` | `OceanMonumentSimpleRoom` (1, 1, 1); the constructor draws `mainDesign = r.nextInt(3)` |

   (`FitDoubleZ.create` contains a branch that would pick `conn[SOUTH]` when `conn[NORTH]` is already claimed; `fits` rules that out, so the branch never runs, inferred.)
   `DoubleXY` and `DoubleYZ` need the claim of the upper cells too, which is why they are tried first.
6. The child boxes are made relative to an origin, then **all moved** by the world position of building-local `(9, 0, 22)`: `v = getWorldPos(9, 0, 22)`
   (36-1 section 6.4: for the building box and orientation, `(worldX(9, 22), minY, worldZ(9, 22))`, with `minY = 39`); every child's box is translated by `v` (`move(Vec3i)`). The wings and the penthouse are
   made from world corners afterwards (step 7) and are not moved.
7. Create the three remaining children from **world corner positions** of the building (`getWorldPos` of building-local points, boxes via `fromCorners`):
   * left wing box = corners local `(1, 1, 1)` and `(23, 8, 21)`; right wing box = local `(34, 1, 1)` and `(56, 8, 21)`; penthouse box = local `(22, 13, 22)` and `(35, 17, 35)`;
   * `s = r.nextInt()` (a full 32-bit draw); `OceanMonumentWingRoom(dir, leftBox, s)`, then `OceanMonumentWingRoom(dir, rightBox, s + 1)` (the post-increment: the left wing receives `s`, the right `s + 1`);
     each wing's `mainDesign = seed & 1`, so **one wing has design 0 and the other design 1 whatever `s`** (left `s & 1`, right `(s + 1) & 1`);
   * `OceanMonumentPenthouse(dir, penthouseBox)`.

Child order in `childPieces`: entry, core, the fitted rooms (in `rooms` order), left wing, right wing, penthouse. The draws made by the constructor, in order: one `nextInt(4)` (the direction, made before the constructor),
the 46-room graph draws of section 5.3, one `nextInt(3)` per `FitSimple` room (interleaved with the fitting in `rooms` order), and finally the single `nextInt()` for the wings.

### 5.5 Child pieces: boxes and orientation

Every child sets its orientation to the building's `dir` (so the local-frame table of 36-1 section 6.4 applies to each child's own box). Types and ids (36-1 section 2.4 rows 38 to 49):

| Class | Piece id | Cells (w, h, d) or box | `mainDesign` |
|---|---|---|---|
| `MonumentBuilding` | `omb` | the 58 x 23 x 58 box of section 5.1 | none |
| `OceanMonumentEntryRoom` | `omentry` | (1, 1, 1) | none |
| `OceanMonumentCoreRoom` | `omcr` | (2, 2, 2) | none |
| `OceanMonumentSimpleRoom` | `omsimple` | (1, 1, 1) | `r.nextInt(3)` |
| `OceanMonumentSimpleTopRoom` | `omsimplet` | (1, 1, 1) | none |
| `OceanMonumentDoubleXRoom` | `omdxr` | (2, 1, 1) | none |
| `OceanMonumentDoubleYRoom` | `omdyr` | (1, 2, 1) | none |
| `OceanMonumentDoubleZRoom` | `omdzr` | (1, 1, 2) | none |
| `OceanMonumentDoubleXYRoom` | `omdxyr` | (2, 2, 1) | none |
| `OceanMonumentDoubleYZRoom` | `omdyzr` | (1, 2, 2) | none |
| `OceanMonumentWingRoom` | `omwr` | the wing box (23 x 8 x 21 for `dir` along z, as `fromCorners` makes it) | `seed & 1` |
| `OceanMonumentPenthouse` | `ompenthouse` | the penthouse box (14 x 5 x 14) | none |

A room piece for definition `def` and size `(w, h, d)` cells (`OceanMonumentPiece.makeBoundingBox`, with `gx = index % 5`, `gz = (index / 5) % 5`, `gy = index / 25`):
first `box = StructurePiece.makeBoundingBox(0, 0, 0, dir, 8 w, 4 h, 8 d)` (36-1 section 6.3: for `NORTH` and `SOUTH` it is `(0,0,0)` to `(8w-1, 4h-1, 8d-1)`; for `EAST` and `WEST` it is
`(0,0,0)` to `(8d-1, 4h-1, 8w-1)`), then it is moved by:

| `dir` | move `(dx, dy, dz)` |
|---|---|
| `NORTH` | `(gx * 8, gy * 4, -(gz + d) * 8 + 1)` |
| `SOUTH` | `(gx * 8, gy * 4, gz * 8)` |
| `WEST` | `(-(gz + d) * 8 + 1, gy * 4, gx * 8)` |
| `EAST` | `(gz * 8, gy * 4, gx * 8)` |

and afterwards by `v` of section 5.4 step 6. The effect is that the grid axes `x` and `z` map onto the building's own local `x` and `z` (the grid origin at building-local `(9, 0, 22)`), whatever the direction;
inside each piece, the piece-local `(x, y, z)` of the geometry tables follow the same mapping with the piece's own box, so a room is drawn identically in its own frame for all four directions.
The entry room (grid `(2, 0, 0)`) is at building-local `z` 22..29, next to the entrance wall at local `z = 21`.

### 5.6 Common helpers of `OceanMonumentPiece`

All use the helpers of 36-1 section 6.5 (`placeBlock`, `generateBox` with the edge/fill states equal, `getBlock`). Block states are the default states of the named blocks.

| Helper | Behaviour |
|---|---|
| `generateBox(x0,y0,z0,x1,y1,z1, B)` (the tables' `BOX`) | `generateBox` with `skipAir = false` and one block for edge and fill (every one of the 386 calls in these classes has `skipAir` false). Order y, then x, then z. |
| `PUT` | `placeBlock(state, x, y, z, chunkBox)` |
| `generateWaterBox(x0,y0,z0,x1,y1,z1)` (`WATER` in the tables) | for every cell, order y, x, z: read the block (air when outside the chunk write box). If its block is `ice`, `packed_ice`, `blue_ice` or `water` (the set `FILL_KEEP`): leave it. Otherwise: if `worldY(y) >= level.getSeaLevel()` and the block state is not exactly `FILL_BLOCK` write **air**; else write **water** (`FILL_BLOCK`). (Since `water` is in `FILL_KEEP`, the "not exactly `FILL_BLOCK`" test is always true when it is reached, so the rule is: not kept, above or at sea level -> air; below sea level -> water.) This is how the monument clears the terrain and floods itself. |
| `generateBoxOnFillOnly(x0,y0,z0,x1,y1,z1, B)` (`FILL` in the tables) | for every cell, order y, x, z: write the block only if the existing block state **is exactly `FILL_BLOCK`** (a water source block, level 0); used for the ceilings, so an upper room's floor is written only where water is, never over solid terrain or another piece's blocks. |
| `generateDefaultFloor(x, z, hasOpening)` | at piece-local `y = 0`, `x` and `z` being the cell's local offset (0 or 8 on the axis a double room extends along). If `hasOpening` (the corresponding `hasOpening[DOWN]` of the cell's definition) is true, eight boxes in this order: `P` `(x+0, 0, z+0)-(x+2, 0, z+7)`; `P` `(x+5, 0, z+0)-(x+7, 0, z+7)`; `P` `(x+3, 0, z+0)-(x+4, 0, z+2)`; `P` `(x+3, 0, z+5)-(x+4, 0, z+7)`; `B` `(x+3, 0, z+2)-(x+4, 0, z+2)`; `B` `(x+3, 0, z+5)-(x+4, 0, z+5)`; `B` `(x+2, 0, z+3)-(x+2, 0, z+4)`; `B` `(x+5, 0, z+3)-(x+5, 0, z+4)`: an 8 x 8 floor with a 2 x 2 hole at `x+3..4`, `z+3..4` (the shaft down to the room below) edged with bricks. If false: one `P` box `(x+0, 0, z+0)-(x+7, 0, z+7)`. |
| `chunkIntersects(chunkBox, x0, z0, x1, z1)` | the two local corners are converted to world `(x, z)`; true iff the chunk box intersects the rectangle between them in x and z (36-1 section 6.3 form with 4 arguments). Only the building uses it. |
| `spawnElder(box, x, y, z)` | section 5.10. |


### 5.7 `MonumentBuilding.postProcess` (called once per chunk pass whose write box the start's piece box intersects)

Local coordinates are the building's own (box 58 x 23 x 58, its orientation `dir`).

1. `top = max(seaLevel, 64) - box.minY` (for sea level 63: `64 - 39 = 25`); `generateWaterBox(0, 0, 0, 58, top, 58)`. (This clears the whole footprint, one cell beyond the box on the
   high-x and high-z side, up to world `y = 64`.)
2. `generateWing(false, 0)`, then `generateWing(true, 33)` (section 5.9.1).
3. `generateEntranceArchs` (5.9.2), `generateEntranceWall` (5.9.3), `generateRoofPiece` (5.9.4), `generateLowerWall` (5.9.5), `generateMiddleWall` (5.9.6), `generateUpperWall` (5.9.7), in this order.
4. **Foundation columns**: for `gx` from 0 to 6: `gz` starts at 0; while `gz < 7`: if `gz == 0` and `gx == 3` set `gz = 6`; for `a` 0..3 (outer), `b` 0..3 (inner):
   `placeBlock(B, 9 gx + a, 0, 9 gz + b)` then `fillColumnDown(B, 9 gx + a, -1, 9 gz + b)` (column of bricks from `y = -1` downward while the cell is replaceable by structures, 36-1 section 6.5);
   then `gz += 1` if `gx` is 0 or 6, else `gz += 6`. The result: 23 pillars of 4 x 4 blocks with their minimum corner at local `(9 gx, 9 gz)`: all seven `gz` for `gx` 0 and 6, `gz` 0 and 6 for `gx` 1, 2, 4, 5, and only `gz` 6 for `gx` 3 (the gap in front of the entrance).
5. **Terrain-clearing steps**: for `i` 0..4: four `generateWaterBox` calls: `(-1 - i, 2 i, -1 - i)-(-1 - i, 23, 58 + i)`; `(58 + i, 2 i, -1 - i)-(58 + i, 23, 58 + i)`; `(0 - i, 2 i, -1 - i)-(57 + i, 23, -1 - i)`; `(0 - i, 2 i, 58 + i)-(57 + i, 23, 58 + i)`
   (a stepped ring of 5 layers around the box that clears the terrain from `y = 2 i` up to local 23, so the monument sits in a pit with stepped sides).
6. **Children**: for each child piece in `childPieces` order whose box intersects the chunk write box (full 3-D test): `child.postProcess(level, sm, generator, random, chunkBox, chunkPos, pivot)` with the same arguments.

Because steps 1 to 5 and the children run in every chunk pass that touches the monument (up to 5 x 5 chunks for the 58-block box), each pass writes only its chunk's part (36-1 section 6.5), and the order of the
sub-operations and the draws of section 5.8 are per pass.


### 5.8 Geometry of the room, wing and penthouse pieces

Conventions for the tables of this section. Coordinates are **piece-local** `(x, y, z)` (36-1 section 6.4: local `y` counts up from the piece box's `minY`; negative `y` is below the box).
The `args` of `BOX`, `WATER` and `FILL` are `x0, y0, z0, x1, y1, z1` (both ends inclusive); `PUT` has `x, y, z`. Rows are executed **top to bottom**; the `when` column gives the condition (blank = always).
"`gridY>0`" means `roomDefinition.index / 25 > 0` (the room is not on the bottom layer). "open S" (and N, E, W) means the `hasOpening` flag of that direction slot (section 5.3; recall that `NORTH` = `z + 1`)
of the named cell, "no UP link" that the named cell has **no** `connections[UP]`. For a **double room** the cells are named: `A` = the piece's own definition, `B` = its second definition
(`connections[EAST]` for X rooms, `connections[NORTH]` for Z rooms); for the XY and YZ rooms `C` = the cell above `A` and `D` = the cell above `B` (`A.connections[UP]`, `B.connections[UP]`).
A piece draws all four walls of a cell only through these rows; the doorways between rooms are produced by `WATER` rows (the doorway is flooded), the walls elsewhere are solid prismarine.
No row in section 5.8 draws a random number except where the text says so.

#### 5.8.1 `OceanMonumentEntryRoom` (cells 1, 1, 1; no floor, no ceiling)


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 0, 3, 0, 2, 3, 7 | B |  |
| 2 | BOX | 5, 3, 0, 7, 3, 7 | B |  |
| 3 | BOX | 0, 2, 0, 1, 2, 7 | B |  |
| 4 | BOX | 6, 2, 0, 7, 2, 7 | B |  |
| 5 | BOX | 0, 1, 0, 0, 1, 7 | B |  |
| 6 | BOX | 7, 1, 0, 7, 1, 7 | B |  |
| 7 | BOX | 0, 1, 7, 7, 3, 7 | B |  |
| 8 | BOX | 1, 1, 0, 2, 3, 0 | B |  |
| 9 | BOX | 5, 1, 0, 6, 3, 0 | B |  |
| 10 | WATER | 3, 1, 7, 4, 2, 7 | water | open N |
| 11 | WATER | 0, 1, 3, 1, 2, 4 | water | open W |
| 12 | WATER | 6, 1, 3, 7, 2, 4 | water | open E |

#### 5.8.2 `OceanMonumentSimpleRoom` (cells 1, 1, 1; `mainDesign` 0, 1 or 2)

Steps, in order:

1. If `gridY>0`: `generateDefaultFloor(0, 0, open[DOWN])` (section 5.6).
2. If the room has no UP link: the `FILL` row 2 of the table (ceiling).
3. `pillar` flag (**random draws here**): `pillar = (mainDesign != 0) and placementRandom.nextBoolean() and (not open[DOWN]) and (not open[UP]) and (countOpenings() > 1)`, evaluated left to right with
   short-circuiting (the `nextBoolean()` draw happens only when `mainDesign != 0`).
4. The rows of the table whose `when` starts with the room's design (`design 0`, `design 1`, `design 2`), in table order, with the sub-conditions shown.
5. If `pillar`: the three `pillar flag` rows at the end.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 4, 1, 6, 4, 6 | P | no UP link |
| 2 | BOX | 0, 1, 0, 2, 1, 2 | B | design 0 |
| 3 | BOX | 0, 3, 0, 2, 3, 2 | B | design 0 |
| 4 | BOX | 0, 2, 0, 0, 2, 2 | P | design 0 |
| 5 | BOX | 1, 2, 0, 2, 2, 0 | P | design 0 |
| 6 | PUT | 1, 2, 1 | L | design 0 |
| 7 | BOX | 5, 1, 0, 7, 1, 2 | B | design 0 |
| 8 | BOX | 5, 3, 0, 7, 3, 2 | B | design 0 |
| 9 | BOX | 7, 2, 0, 7, 2, 2 | P | design 0 |
| 10 | BOX | 5, 2, 0, 6, 2, 0 | P | design 0 |
| 11 | PUT | 6, 2, 1 | L | design 0 |
| 12 | BOX | 0, 1, 5, 2, 1, 7 | B | design 0 |
| 13 | BOX | 0, 3, 5, 2, 3, 7 | B | design 0 |
| 14 | BOX | 0, 2, 5, 0, 2, 7 | P | design 0 |
| 15 | BOX | 1, 2, 7, 2, 2, 7 | P | design 0 |
| 16 | PUT | 1, 2, 6 | L | design 0 |
| 17 | BOX | 5, 1, 5, 7, 1, 7 | B | design 0 |
| 18 | BOX | 5, 3, 5, 7, 3, 7 | B | design 0 |
| 19 | BOX | 7, 2, 5, 7, 2, 7 | P | design 0 |
| 20 | BOX | 5, 2, 7, 6, 2, 7 | P | design 0 |
| 21 | PUT | 6, 2, 6 | L | design 0 |
| 22 | BOX | 3, 3, 0, 4, 3, 0 | B | design 0, open S |
| 23 | BOX | 3, 3, 0, 4, 3, 1 | B | design 0, not open S |
| 24 | BOX | 3, 2, 0, 4, 2, 0 | P | design 0, not open S |
| 25 | BOX | 3, 1, 0, 4, 1, 1 | B | design 0, not open S |
| 26 | BOX | 3, 3, 7, 4, 3, 7 | B | design 0, open N |
| 27 | BOX | 3, 3, 6, 4, 3, 7 | B | design 0, not open N |
| 28 | BOX | 3, 2, 7, 4, 2, 7 | P | design 0, not open N |
| 29 | BOX | 3, 1, 6, 4, 1, 7 | B | design 0, not open N |
| 30 | BOX | 0, 3, 3, 0, 3, 4 | B | design 0, open W |
| 31 | BOX | 0, 3, 3, 1, 3, 4 | B | design 0, not open W |
| 32 | BOX | 0, 2, 3, 0, 2, 4 | P | design 0, not open W |
| 33 | BOX | 0, 1, 3, 1, 1, 4 | B | design 0, not open W |
| 34 | BOX | 7, 3, 3, 7, 3, 4 | B | design 0, open E |
| 35 | BOX | 6, 3, 3, 7, 3, 4 | B | design 0, not open E |
| 36 | BOX | 7, 2, 3, 7, 2, 4 | P | design 0, not open E |
| 37 | BOX | 6, 1, 3, 7, 1, 4 | B | design 0, not open E |
| 38 | BOX | 2, 1, 2, 2, 3, 2 | B | design 1 |
| 39 | BOX | 2, 1, 5, 2, 3, 5 | B | design 1 |
| 40 | BOX | 5, 1, 5, 5, 3, 5 | B | design 1 |
| 41 | BOX | 5, 1, 2, 5, 3, 2 | B | design 1 |
| 42 | PUT | 2, 2, 2 | L | design 1 |
| 43 | PUT | 2, 2, 5 | L | design 1 |
| 44 | PUT | 5, 2, 5 | L | design 1 |
| 45 | PUT | 5, 2, 2 | L | design 1 |
| 46 | BOX | 0, 1, 0, 1, 3, 0 | B | design 1 |
| 47 | BOX | 0, 1, 1, 0, 3, 1 | B | design 1 |
| 48 | BOX | 0, 1, 7, 1, 3, 7 | B | design 1 |
| 49 | BOX | 0, 1, 6, 0, 3, 6 | B | design 1 |
| 50 | BOX | 6, 1, 7, 7, 3, 7 | B | design 1 |
| 51 | BOX | 7, 1, 6, 7, 3, 6 | B | design 1 |
| 52 | BOX | 6, 1, 0, 7, 3, 0 | B | design 1 |
| 53 | BOX | 7, 1, 1, 7, 3, 1 | B | design 1 |
| 54 | PUT | 1, 2, 0 | P | design 1 |
| 55 | PUT | 0, 2, 1 | P | design 1 |
| 56 | PUT | 1, 2, 7 | P | design 1 |
| 57 | PUT | 0, 2, 6 | P | design 1 |
| 58 | PUT | 6, 2, 7 | P | design 1 |
| 59 | PUT | 7, 2, 6 | P | design 1 |
| 60 | PUT | 6, 2, 0 | P | design 1 |
| 61 | PUT | 7, 2, 1 | P | design 1 |
| 62 | BOX | 1, 3, 0, 6, 3, 0 | B | design 1, not open S |
| 63 | BOX | 1, 2, 0, 6, 2, 0 | P | design 1, not open S |
| 64 | BOX | 1, 1, 0, 6, 1, 0 | B | design 1, not open S |
| 65 | BOX | 1, 3, 7, 6, 3, 7 | B | design 1, not open N |
| 66 | BOX | 1, 2, 7, 6, 2, 7 | P | design 1, not open N |
| 67 | BOX | 1, 1, 7, 6, 1, 7 | B | design 1, not open N |
| 68 | BOX | 0, 3, 1, 0, 3, 6 | B | design 1, not open W |
| 69 | BOX | 0, 2, 1, 0, 2, 6 | P | design 1, not open W |
| 70 | BOX | 0, 1, 1, 0, 1, 6 | B | design 1, not open W |
| 71 | BOX | 7, 3, 1, 7, 3, 6 | B | design 1, not open E |
| 72 | BOX | 7, 2, 1, 7, 2, 6 | P | design 1, not open E |
| 73 | BOX | 7, 1, 1, 7, 1, 6 | B | design 1, not open E |
| 74 | BOX | 0, 1, 0, 0, 1, 7 | B | design 2 |
| 75 | BOX | 7, 1, 0, 7, 1, 7 | B | design 2 |
| 76 | BOX | 1, 1, 0, 6, 1, 0 | B | design 2 |
| 77 | BOX | 1, 1, 7, 6, 1, 7 | B | design 2 |
| 78 | BOX | 0, 2, 0, 0, 2, 7 | D | design 2 |
| 79 | BOX | 7, 2, 0, 7, 2, 7 | D | design 2 |
| 80 | BOX | 1, 2, 0, 6, 2, 0 | D | design 2 |
| 81 | BOX | 1, 2, 7, 6, 2, 7 | D | design 2 |
| 82 | BOX | 0, 3, 0, 0, 3, 7 | B | design 2 |
| 83 | BOX | 7, 3, 0, 7, 3, 7 | B | design 2 |
| 84 | BOX | 1, 3, 0, 6, 3, 0 | B | design 2 |
| 85 | BOX | 1, 3, 7, 6, 3, 7 | B | design 2 |
| 86 | BOX | 0, 1, 3, 0, 2, 4 | D | design 2 |
| 87 | BOX | 7, 1, 3, 7, 2, 4 | D | design 2 |
| 88 | BOX | 3, 1, 0, 4, 2, 0 | D | design 2 |
| 89 | BOX | 3, 1, 7, 4, 2, 7 | D | design 2 |
| 90 | WATER | 3, 1, 0, 4, 2, 0 | water | design 2, open S |
| 91 | WATER | 3, 1, 7, 4, 2, 7 | water | design 2, open N |
| 92 | WATER | 0, 1, 3, 0, 2, 4 | water | design 2, open W |
| 93 | WATER | 7, 1, 3, 7, 2, 4 | water | design 2, open E |
| 94 | BOX | 3, 1, 3, 4, 1, 4 | B | pillar flag |
| 95 | BOX | 3, 2, 3, 4, 2, 4 | P | pillar flag |
| 96 | BOX | 3, 3, 3, 4, 3, 4 | B | pillar flag |

Row 1 of the table above is the ceiling `FILL` and is **step 2**; the table is in execution order from row 1 (step 1, the floor, is not in the table).

#### 5.8.3 `OceanMonumentSimpleTopRoom` (cells 1, 1, 1; the "sponge room")

Steps in order: (1) if `gridY>0`: `generateDefaultFloor(0, 0, open[DOWN])`; (2) if no UP link: the `FILL` row; (3) the **sponge pass** (below); (4) the table rows.

**Sponge pass** (draws from the placement random): for `x` from 1 to 6 (outer) and `z` from 1 to 6 (inner): draw `r.nextInt(3)`; if it is `0`, skip the column (so a column is present with probability 2/3);
otherwise draw `r.nextInt(4)`; `y0 = 2 + (that draw == 0 ? 0 : 1)` (so `y0 = 2` with probability 1/4 and `3` with 3/4); write `S` (`wet_sponge`) in the box `(x, y0, z)-(x, 3, z)` (one block at `y = 3`, or two blocks at `y = 2` and `3`).
Exactly one or two draws are made per column (36 or fewer columns). The walls are written **after** the sponge pass, but they do not cover the interior `x, z` 1..6.
A sponge room has at most its `DOWN` opening (section 5.4: the fitter requires `open[W]`, `open[E]`, `open[N]`, `open[S]`, `open[UP]` false), so the `open S` row of the table is never executed for a fitted room (inferred).


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 4, 1, 6, 4, 6 | P | no UP link |
| 2 | BOX | 0, 1, 0, 0, 1, 7 | B |  |
| 3 | BOX | 7, 1, 0, 7, 1, 7 | B |  |
| 4 | BOX | 1, 1, 0, 6, 1, 0 | B |  |
| 5 | BOX | 1, 1, 7, 6, 1, 7 | B |  |
| 6 | BOX | 0, 2, 0, 0, 2, 7 | D |  |
| 7 | BOX | 7, 2, 0, 7, 2, 7 | D |  |
| 8 | BOX | 1, 2, 0, 6, 2, 0 | D |  |
| 9 | BOX | 1, 2, 7, 6, 2, 7 | D |  |
| 10 | BOX | 0, 3, 0, 0, 3, 7 | B |  |
| 11 | BOX | 7, 3, 0, 7, 3, 7 | B |  |
| 12 | BOX | 1, 3, 0, 6, 3, 0 | B |  |
| 13 | BOX | 1, 3, 7, 6, 3, 7 | B |  |
| 14 | BOX | 0, 1, 3, 0, 2, 4 | D |  |
| 15 | BOX | 7, 1, 3, 7, 2, 4 | D |  |
| 16 | BOX | 3, 1, 0, 4, 2, 0 | D |  |
| 17 | BOX | 3, 1, 7, 4, 2, 7 | D |  |
| 18 | WATER | 3, 1, 0, 4, 2, 0 | water | open S |

#### 5.8.4 `OceanMonumentDoubleXRoom` (cells 2, 1, 1; `A` at local `x` 0..7, `B` at 8..15)

Steps: (1) if `gridY>0`: `generateDefaultFloor(8, 0, B.open[DOWN])` then `generateDefaultFloor(0, 0, A.open[DOWN])`; (2) the table rows.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 4, 1, 7, 4, 6 | P | A has no UP link |
| 2 | FILL | 8, 4, 1, 14, 4, 6 | P | B has no UP link |
| 3 | BOX | 0, 3, 0, 0, 3, 7 | B |  |
| 4 | BOX | 15, 3, 0, 15, 3, 7 | B |  |
| 5 | BOX | 1, 3, 0, 15, 3, 0 | B |  |
| 6 | BOX | 1, 3, 7, 14, 3, 7 | B |  |
| 7 | BOX | 0, 2, 0, 0, 2, 7 | P |  |
| 8 | BOX | 15, 2, 0, 15, 2, 7 | P |  |
| 9 | BOX | 1, 2, 0, 15, 2, 0 | P |  |
| 10 | BOX | 1, 2, 7, 14, 2, 7 | P |  |
| 11 | BOX | 0, 1, 0, 0, 1, 7 | B |  |
| 12 | BOX | 15, 1, 0, 15, 1, 7 | B |  |
| 13 | BOX | 1, 1, 0, 15, 1, 0 | B |  |
| 14 | BOX | 1, 1, 7, 14, 1, 7 | B |  |
| 15 | BOX | 5, 1, 0, 10, 1, 4 | B |  |
| 16 | BOX | 6, 2, 0, 9, 2, 3 | P |  |
| 17 | BOX | 5, 3, 0, 10, 3, 4 | B |  |
| 18 | PUT | 6, 2, 3 | L |  |
| 19 | PUT | 9, 2, 3 | L |  |
| 20 | WATER | 3, 1, 0, 4, 2, 0 | water | A open S |
| 21 | WATER | 3, 1, 7, 4, 2, 7 | water | A open N |
| 22 | WATER | 0, 1, 3, 0, 2, 4 | water | A open W |
| 23 | WATER | 11, 1, 0, 12, 2, 0 | water | B open S |
| 24 | WATER | 11, 1, 7, 12, 2, 7 | water | B open N |
| 25 | WATER | 15, 1, 3, 15, 2, 4 | water | B open E |

#### 5.8.5 `OceanMonumentDoubleZRoom` (cells 1, 1, 2; `A` at local `z` 0..7, `B` at 8..15)

Steps: (1) if `gridY>0`: `generateDefaultFloor(0, 8, B.open[DOWN])` then `generateDefaultFloor(0, 0, A.open[DOWN])`; (2) the table rows.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 4, 1, 6, 4, 7 | P | A has no UP link |
| 2 | FILL | 1, 4, 8, 6, 4, 14 | P | B has no UP link |
| 3 | BOX | 0, 3, 0, 0, 3, 15 | B |  |
| 4 | BOX | 7, 3, 0, 7, 3, 15 | B |  |
| 5 | BOX | 1, 3, 0, 7, 3, 0 | B |  |
| 6 | BOX | 1, 3, 15, 6, 3, 15 | B |  |
| 7 | BOX | 0, 2, 0, 0, 2, 15 | P |  |
| 8 | BOX | 7, 2, 0, 7, 2, 15 | P |  |
| 9 | BOX | 1, 2, 0, 7, 2, 0 | P |  |
| 10 | BOX | 1, 2, 15, 6, 2, 15 | P |  |
| 11 | BOX | 0, 1, 0, 0, 1, 15 | B |  |
| 12 | BOX | 7, 1, 0, 7, 1, 15 | B |  |
| 13 | BOX | 1, 1, 0, 7, 1, 0 | B |  |
| 14 | BOX | 1, 1, 15, 6, 1, 15 | B |  |
| 15 | BOX | 1, 1, 1, 1, 1, 2 | B |  |
| 16 | BOX | 6, 1, 1, 6, 1, 2 | B |  |
| 17 | BOX | 1, 3, 1, 1, 3, 2 | B |  |
| 18 | BOX | 6, 3, 1, 6, 3, 2 | B |  |
| 19 | BOX | 1, 1, 13, 1, 1, 14 | B |  |
| 20 | BOX | 6, 1, 13, 6, 1, 14 | B |  |
| 21 | BOX | 1, 3, 13, 1, 3, 14 | B |  |
| 22 | BOX | 6, 3, 13, 6, 3, 14 | B |  |
| 23 | BOX | 2, 1, 6, 2, 3, 6 | B |  |
| 24 | BOX | 5, 1, 6, 5, 3, 6 | B |  |
| 25 | BOX | 2, 1, 9, 2, 3, 9 | B |  |
| 26 | BOX | 5, 1, 9, 5, 3, 9 | B |  |
| 27 | BOX | 3, 2, 6, 4, 2, 6 | B |  |
| 28 | BOX | 3, 2, 9, 4, 2, 9 | B |  |
| 29 | BOX | 2, 2, 7, 2, 2, 8 | B |  |
| 30 | BOX | 5, 2, 7, 5, 2, 8 | B |  |
| 31 | PUT | 2, 2, 5 | L |  |
| 32 | PUT | 5, 2, 5 | L |  |
| 33 | PUT | 2, 2, 10 | L |  |
| 34 | PUT | 5, 2, 10 | L |  |
| 35 | PUT | 2, 3, 5 | B |  |
| 36 | PUT | 5, 3, 5 | B |  |
| 37 | PUT | 2, 3, 10 | B |  |
| 38 | PUT | 5, 3, 10 | B |  |
| 39 | WATER | 3, 1, 0, 4, 2, 0 | water | A open S |
| 40 | WATER | 7, 1, 3, 7, 2, 4 | water | A open E |
| 41 | WATER | 0, 1, 3, 0, 2, 4 | water | A open W |
| 42 | WATER | 3, 1, 15, 4, 2, 15 | water | B open N |
| 43 | WATER | 0, 1, 11, 0, 2, 12 | water | B open W |
| 44 | WATER | 7, 1, 11, 7, 2, 12 | water | B open E |

#### 5.8.6 `OceanMonumentDoubleYRoom` (cells 1, 2, 1; `A` at local `y` 0..3, upper cell `U = A.connections[UP]` at `y` 4..7)

Steps: (1) if `gridY>0`: `generateDefaultFloor(0, 0, A.open[DOWN])`; (2) if `U` has no UP link: the first row below; (3) the remaining fixed rows; (4) the **wall pass**.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 8, 1, 6, 8, 6 | P | upper cell has no UP link |
| 2 | BOX | 0, 4, 0, 0, 4, 7 | B |  |
| 3 | BOX | 7, 4, 0, 7, 4, 7 | B |  |
| 4 | BOX | 1, 4, 0, 6, 4, 0 | B |  |
| 5 | BOX | 1, 4, 7, 6, 4, 7 | B |  |
| 6 | BOX | 2, 4, 1, 2, 4, 2 | B |  |
| 7 | BOX | 1, 4, 2, 1, 4, 2 | B |  |
| 8 | BOX | 5, 4, 1, 5, 4, 2 | B |  |
| 9 | BOX | 6, 4, 2, 6, 4, 2 | B |  |
| 10 | BOX | 2, 4, 5, 2, 4, 6 | B |  |
| 11 | BOX | 1, 4, 5, 1, 4, 5 | B |  |
| 12 | BOX | 5, 4, 5, 5, 4, 6 | B |  |
| 13 | BOX | 6, 4, 5, 6, 4, 5 | B |  |

**Wall pass**: for the cell `L` = `A` with `y0 = 1`, then for `L = U` with `y0 = 5` (in that order), the four walls in the order south (`z = 0`, uses `L.open[S]`), north (`z = 7`, `L.open[N]`), west (`x = 0`, `L.open[W]`), east (`x = 7`, `L.open[E]`):

| Wall | If the cell has an opening there | Otherwise |
|---|---|---|
| south, `z = 0` | `B` boxes `(2, y0, 0)-(2, y0+2, 0)`, `(5, y0, 0)-(5, y0+2, 0)`, `(3, y0+2, 0)-(4, y0+2, 0)` | `B` box `(0, y0, 0)-(7, y0+2, 0)`, then `P` box `(0, y0+1, 0)-(7, y0+1, 0)` |
| north, `z = 7` | the same three boxes at `z = 7` | the same two boxes at `z = 7` |
| west, `x = 0` | `B` boxes `(0, y0, 2)-(0, y0+2, 2)`, `(0, y0, 5)-(0, y0+2, 5)`, `(0, y0+2, 3)-(0, y0+2, 4)` | `B` box `(0, y0, 0)-(0, y0+2, 7)`, then `P` box `(0, y0+1, 0)-(0, y0+1, 7)` |
| east, `x = 7` | the same three boxes at `x = 7` | the same two boxes at `x = 7` |

(An opening is a 2-wide, 2-high doorway at the wall's middle, framed by the pillars at 2 and 5 and a lintel at `y0+2`; the doorway cells themselves are left as they are, i.e. flooded by the building's water clearing, section 5.7 step 1.)

#### 5.8.7 `OceanMonumentDoubleXYRoom` (cells 2, 2, 1; `A`, `B` at `y` 0..3; `C`, `D` above)

Steps: (1) if `gridY>0`: floors `generateDefaultFloor(8, 0, B.open[DOWN])` then `generateDefaultFloor(0, 0, A.open[DOWN])`; (2) the two `FILL` rows (conditions in the table); (3) the **column pass**; (4) the rest of the table.

**Column pass**: for `y` from 1 to 7: colour `P` when `y` is 2 or 6, else `B`; four boxes of that colour: `(0, y, 0)-(0, y, 7)`; `(15, y, 0)-(15, y, 7)`; `(1, y, 0)-(15, y, 0)`; `(1, y, 7)-(14, y, 7)`.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 8, 1, 7, 8, 6 | P | C has no UP link |
| 2 | FILL | 8, 8, 1, 14, 8, 6 | P | D has no UP link |
| 3 | BOX | 2, 1, 3, 2, 7, 4 | B |  |
| 4 | BOX | 3, 1, 2, 4, 7, 2 | B |  |
| 5 | BOX | 3, 1, 5, 4, 7, 5 | B |  |
| 6 | BOX | 13, 1, 3, 13, 7, 4 | B |  |
| 7 | BOX | 11, 1, 2, 12, 7, 2 | B |  |
| 8 | BOX | 11, 1, 5, 12, 7, 5 | B |  |
| 9 | BOX | 5, 1, 3, 5, 3, 4 | B |  |
| 10 | BOX | 10, 1, 3, 10, 3, 4 | B |  |
| 11 | BOX | 5, 7, 2, 10, 7, 5 | B |  |
| 12 | BOX | 5, 5, 2, 5, 7, 2 | B |  |
| 13 | BOX | 10, 5, 2, 10, 7, 2 | B |  |
| 14 | BOX | 5, 5, 5, 5, 7, 5 | B |  |
| 15 | BOX | 10, 5, 5, 10, 7, 5 | B |  |
| 16 | PUT | 6, 6, 2 | B |  |
| 17 | PUT | 9, 6, 2 | B |  |
| 18 | PUT | 6, 6, 5 | B |  |
| 19 | PUT | 9, 6, 5 | B |  |
| 20 | BOX | 5, 4, 3, 6, 4, 4 | B |  |
| 21 | BOX | 9, 4, 3, 10, 4, 4 | B |  |
| 22 | PUT | 5, 4, 2 | L |  |
| 23 | PUT | 5, 4, 5 | L |  |
| 24 | PUT | 10, 4, 2 | L |  |
| 25 | PUT | 10, 4, 5 | L |  |
| 26 | WATER | 3, 1, 0, 4, 2, 0 | water | A open S |
| 27 | WATER | 3, 1, 7, 4, 2, 7 | water | A open N |
| 28 | WATER | 0, 1, 3, 0, 2, 4 | water | A open W |
| 29 | WATER | 11, 1, 0, 12, 2, 0 | water | B open S |
| 30 | WATER | 11, 1, 7, 12, 2, 7 | water | B open N |
| 31 | WATER | 15, 1, 3, 15, 2, 4 | water | B open E |
| 32 | WATER | 3, 5, 0, 4, 6, 0 | water | C open S |
| 33 | WATER | 3, 5, 7, 4, 6, 7 | water | C open N |
| 34 | WATER | 0, 5, 3, 0, 6, 4 | water | C open W |
| 35 | WATER | 11, 5, 0, 12, 6, 0 | water | D open S |
| 36 | WATER | 11, 5, 7, 12, 6, 7 | water | D open N |
| 37 | WATER | 15, 5, 3, 15, 6, 4 | water | D open E |

#### 5.8.8 `OceanMonumentDoubleYZRoom` (cells 1, 2, 2; `A`, `B` at `y` 0..3 with `B` at local `z` 8..15; `C`, `D` above)

Steps: (1) if `gridY>0`: `generateDefaultFloor(0, 8, B.open[DOWN])` then `generateDefaultFloor(0, 0, A.open[DOWN])`; (2) the two `FILL` rows; (3) **wall pass 1**: for `y` from 1 to 7, colour `P` when `y` is 2 or 6 else `B`:
boxes `(0, y, 0)-(0, y, 15)`; `(7, y, 0)-(7, y, 15)`; `(1, y, 0)-(6, y, 0)`; `(1, y, 15)-(6, y, 15)`; (4) **wall pass 2**: for `y` from 1 to 7, colour `L` (sea lantern) when `y` is 2 or 6 else `D`: box `(3, y, 7)-(4, y, 8)`;
(5) the rest of the table (the three-row groups under `C open E`, `C open W`, `D open W`, `D open E` are executed together with the water row that precedes them).


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 8, 1, 6, 8, 7 | P | C has no UP link |
| 2 | FILL | 1, 8, 8, 6, 8, 14 | P | D has no UP link |
| 3 | WATER | 3, 1, 0, 4, 2, 0 | water | A open S |
| 4 | WATER | 7, 1, 3, 7, 2, 4 | water | A open E |
| 5 | WATER | 0, 1, 3, 0, 2, 4 | water | A open W |
| 6 | WATER | 3, 1, 15, 4, 2, 15 | water | B open N |
| 7 | WATER | 0, 1, 11, 0, 2, 12 | water | B open W |
| 8 | WATER | 7, 1, 11, 7, 2, 12 | water | B open E |
| 9 | WATER | 3, 5, 0, 4, 6, 0 | water | C open S |
| 10 | WATER | 7, 5, 3, 7, 6, 4 | water | C open E |
| 11 | BOX | 5, 4, 2, 6, 4, 5 | B | C open E |
| 12 | BOX | 6, 1, 2, 6, 3, 2 | B | C open E |
| 13 | BOX | 6, 1, 5, 6, 3, 5 | B | C open E |
| 14 | WATER | 0, 5, 3, 0, 6, 4 | water | C open W |
| 15 | BOX | 1, 4, 2, 2, 4, 5 | B | C open W |
| 16 | BOX | 1, 1, 2, 1, 3, 2 | B | C open W |
| 17 | BOX | 1, 1, 5, 1, 3, 5 | B | C open W |
| 18 | WATER | 3, 5, 15, 4, 6, 15 | water | D open N |
| 19 | WATER | 0, 5, 11, 0, 6, 12 | water | D open W |
| 20 | BOX | 1, 4, 10, 2, 4, 13 | B | D open W |
| 21 | BOX | 1, 1, 10, 1, 3, 10 | B | D open W |
| 22 | BOX | 1, 1, 13, 1, 3, 13 | B | D open W |
| 23 | WATER | 7, 5, 11, 7, 6, 12 | water | D open E |
| 24 | BOX | 5, 4, 10, 6, 4, 13 | B | D open E |
| 25 | BOX | 6, 1, 10, 6, 3, 10 | B | D open E |
| 26 | BOX | 6, 1, 13, 6, 3, 13 | B | D open E |

#### 5.8.9 `OceanMonumentCoreRoom` (cells 2, 2, 2; the gold core)

Steps in order: (1) the `FILL` row 1 of the table (ceiling, always); (2) the rim: `B` boxes `(0, 7, 0)-(0, 7, 15)`, `(15, 7, 0)-(15, 7, 15)`, `(1, 7, 0)-(15, 7, 0)`, `(1, 7, 15)-(14, 7, 15)`;
(3) **wall pass**: for `y` from 1 to 6, colour `P` when `y` is 2 or 6 else `B`: for `x` in `{0, 15}`: boxes `(x, y, 0)-(x, y, 1)`, `(x, y, 6)-(x, y, 9)`, `(x, y, 14)-(x, y, 15)`; then boxes `(1, y, 0)-(1, y, 0)`,
`(6, y, 0)-(9, y, 0)`, `(14, y, 0)-(14, y, 0)`, `(1, y, 15)-(14, y, 15)`; (4) rows 2 (`D` block `(6,3,6)-(9,6,9)`) and 3 (`G`: the 2 x 2 x 2 gold block cube `(7,4,7)-(8,5,8)`, **8 gold blocks**);
(5) the **lantern pass**: for `y` in `{3, 6}` and `x` in `{6, 9}`: `PUT L (x, y, 6)` and `PUT L (x, y, 9)` (they overwrite corners of the dark prismarine cube); (6) rows 4 to 31 (bricks).
The core has no doorways and no floor of its own (it is on the bottom layer: `gridY = 0`).


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | FILL | 1, 8, 0, 14, 8, 14 | P |  |
| 2 | BOX | 6, 3, 6, 9, 6, 9 | D |  |
| 3 | BOX | 7, 4, 7, 8, 5, 8 | G |  |
| 4 | BOX | 5, 1, 6, 5, 2, 6 | B |  |
| 5 | BOX | 5, 1, 9, 5, 2, 9 | B |  |
| 6 | BOX | 10, 1, 6, 10, 2, 6 | B |  |
| 7 | BOX | 10, 1, 9, 10, 2, 9 | B |  |
| 8 | BOX | 6, 1, 5, 6, 2, 5 | B |  |
| 9 | BOX | 9, 1, 5, 9, 2, 5 | B |  |
| 10 | BOX | 6, 1, 10, 6, 2, 10 | B |  |
| 11 | BOX | 9, 1, 10, 9, 2, 10 | B |  |
| 12 | BOX | 5, 2, 5, 5, 6, 5 | B |  |
| 13 | BOX | 5, 2, 10, 5, 6, 10 | B |  |
| 14 | BOX | 10, 2, 5, 10, 6, 5 | B |  |
| 15 | BOX | 10, 2, 10, 10, 6, 10 | B |  |
| 16 | BOX | 5, 7, 1, 5, 7, 6 | B |  |
| 17 | BOX | 10, 7, 1, 10, 7, 6 | B |  |
| 18 | BOX | 5, 7, 9, 5, 7, 14 | B |  |
| 19 | BOX | 10, 7, 9, 10, 7, 14 | B |  |
| 20 | BOX | 1, 7, 5, 6, 7, 5 | B |  |
| 21 | BOX | 1, 7, 10, 6, 7, 10 | B |  |
| 22 | BOX | 9, 7, 5, 14, 7, 5 | B |  |
| 23 | BOX | 9, 7, 10, 14, 7, 10 | B |  |
| 24 | BOX | 2, 1, 2, 2, 1, 3 | B |  |
| 25 | BOX | 3, 1, 2, 3, 1, 2 | B |  |
| 26 | BOX | 13, 1, 2, 13, 1, 3 | B |  |
| 27 | BOX | 12, 1, 2, 12, 1, 2 | B |  |
| 28 | BOX | 2, 1, 12, 2, 1, 13 | B |  |
| 29 | BOX | 3, 1, 13, 3, 1, 13 | B |  |
| 30 | BOX | 13, 1, 12, 13, 1, 13 | B |  |
| 31 | BOX | 12, 1, 13, 12, 1, 13 | B |  |

#### 5.8.10 `OceanMonumentWingRoom` (the two wings; box 23 x 8 x 21; design 0 or 1)

Draws no random number. The local frame is that of the wing's own box (orientation `dir`). **Design 0** (`mainDesign == 0`), in this order: (1) for `i` from 0 to 3: `B` box `(10 - i, 3 - i, 20 - i)-(12 + i, 3 - i, 20)`;
(2) table rows 1 to 13; (3) for `z` in `18, 15, 12, 9`: `PUT L (6, 3, z)` and `PUT L (16, 3, z)`; (4) table rows 14 to 35; (5) row 36, `ELDER (11, 2, 16)`.
**Design 1**, in this order: rows 37 to 39; for `x` in `{9, 13}`: `PUT B (x, 6, 20)`, `PUT L (x, 5, 20)`, `PUT B (x, 4, 20)`; row 40; for `x` in `{10, 12}`: `B` boxes `(x, 0, 10)-(x, 6, 10)` and `(x, 0, 12)-(x, 6, 12)`,
then `PUT L (x, 0, 10)`, `PUT L (x, 0, 12)`, `PUT L (x, 4, 10)`, `PUT L (x, 4, 12)`; for `x` in `{8, 14}`: `B` boxes `(x, 0, 7)-(x, 2, 7)` and `(x, 0, 14)-(x, 2, 14)`; rows 41 and 42; row 43, `ELDER (11, 5, 13)`.
(`ELDER` = `spawnElder`, section 5.10.)


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 7, 0, 6, 15, 0, 16 | B | design 0 |
| 2 | BOX | 6, 0, 6, 6, 3, 20 | B | design 0 |
| 3 | BOX | 16, 0, 6, 16, 3, 20 | B | design 0 |
| 4 | BOX | 7, 1, 7, 7, 1, 20 | B | design 0 |
| 5 | BOX | 15, 1, 7, 15, 1, 20 | B | design 0 |
| 6 | BOX | 7, 1, 6, 9, 3, 6 | B | design 0 |
| 7 | BOX | 13, 1, 6, 15, 3, 6 | B | design 0 |
| 8 | BOX | 8, 1, 7, 9, 1, 7 | B | design 0 |
| 9 | BOX | 13, 1, 7, 14, 1, 7 | B | design 0 |
| 10 | BOX | 9, 0, 5, 13, 0, 5 | B | design 0 |
| 11 | BOX | 10, 0, 7, 12, 0, 7 | D | design 0 |
| 12 | BOX | 8, 0, 10, 8, 0, 12 | D | design 0 |
| 13 | BOX | 14, 0, 10, 14, 0, 12 | D | design 0 |
| 14 | PUT | 10, 0, 10 | L | design 0 |
| 15 | PUT | 12, 0, 10 | L | design 0 |
| 16 | PUT | 10, 0, 12 | L | design 0 |
| 17 | PUT | 12, 0, 12 | L | design 0 |
| 18 | PUT | 8, 3, 6 | L | design 0 |
| 19 | PUT | 14, 3, 6 | L | design 0 |
| 20 | PUT | 4, 2, 4 | B | design 0 |
| 21 | PUT | 4, 1, 4 | L | design 0 |
| 22 | PUT | 4, 0, 4 | B | design 0 |
| 23 | PUT | 18, 2, 4 | B | design 0 |
| 24 | PUT | 18, 1, 4 | L | design 0 |
| 25 | PUT | 18, 0, 4 | B | design 0 |
| 26 | PUT | 4, 2, 18 | B | design 0 |
| 27 | PUT | 4, 1, 18 | L | design 0 |
| 28 | PUT | 4, 0, 18 | B | design 0 |
| 29 | PUT | 18, 2, 18 | B | design 0 |
| 30 | PUT | 18, 1, 18 | L | design 0 |
| 31 | PUT | 18, 0, 18 | B | design 0 |
| 32 | PUT | 9, 7, 20 | B | design 0 |
| 33 | PUT | 13, 7, 20 | B | design 0 |
| 34 | BOX | 6, 0, 21, 7, 4, 21 | B | design 0 |
| 35 | BOX | 15, 0, 21, 16, 4, 21 | B | design 0 |
| 36 | ELDER | 11, 2, 16 |  | design 0 |
| 37 | BOX | 9, 3, 18, 13, 3, 20 | B | design 1 |
| 38 | BOX | 9, 0, 18, 9, 2, 18 | B | design 1 |
| 39 | BOX | 13, 0, 18, 13, 2, 18 | B | design 1 |
| 40 | BOX | 7, 3, 7, 15, 3, 14 | B | design 1 |
| 41 | BOX | 8, 3, 8, 8, 3, 13 | D | design 1 |
| 42 | BOX | 14, 3, 8, 14, 3, 13 | D | design 1 |
| 43 | ELDER | 11, 5, 13 |  | design 1 |

#### 5.8.11 `OceanMonumentPenthouse` (box 14 x 5 x 14, the roof room)

No random draws. Steps: rows 1 to 9; then the **lantern pass**: for `v` in `2, 5, 8, 11`: `PUT L (0, 0, v)`, `PUT L (13, 0, v)`, `PUT L (v, 0, 0)`; rows 10 to 19; then the **pillar pass**: for `x` in `{3, 10}` and `z` in `2, 5, 8`:
`B` box `(x, 0, z)-(x, 2, z)`; rows 20 to 24 (row 24 is `ELDER (6, 1, 6)`).


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 2, -1, 2, 11, -1, 11 | B |  |
| 2 | BOX | 0, -1, 0, 1, -1, 11 | P |  |
| 3 | BOX | 12, -1, 0, 13, -1, 11 | P |  |
| 4 | BOX | 2, -1, 0, 11, -1, 1 | P |  |
| 5 | BOX | 2, -1, 12, 11, -1, 13 | P |  |
| 6 | BOX | 0, 0, 0, 0, 0, 13 | B |  |
| 7 | BOX | 13, 0, 0, 13, 0, 13 | B |  |
| 8 | BOX | 1, 0, 0, 12, 0, 0 | B |  |
| 9 | BOX | 1, 0, 13, 12, 0, 13 | B |  |
| 10 | BOX | 2, 0, 3, 4, 0, 9 | B |  |
| 11 | BOX | 9, 0, 3, 11, 0, 9 | B |  |
| 12 | BOX | 4, 0, 9, 9, 0, 11 | B |  |
| 13 | PUT | 5, 0, 8 | B |  |
| 14 | PUT | 8, 0, 8 | B |  |
| 15 | PUT | 10, 0, 10 | B |  |
| 16 | PUT | 3, 0, 10 | B |  |
| 17 | BOX | 3, 0, 3, 3, 0, 7 | D |  |
| 18 | BOX | 10, 0, 3, 10, 0, 7 | D |  |
| 19 | BOX | 6, 0, 10, 7, 0, 10 | D |  |
| 20 | BOX | 5, 0, 10, 5, 2, 10 | B |  |
| 21 | BOX | 8, 0, 10, 8, 2, 10 | B |  |
| 22 | BOX | 6, -1, 7, 7, -1, 8 | D |  |
| 23 | WATER | 6, -1, 3, 7, -1, 4 | water |  |
| 24 | ELDER | 6, 1, 6 |  |  |

### 5.9 Geometry of the building's own parts

All coordinates are **building-local** (box 58 x 23 x 58, orientation `dir`). Every sub-generator first tests `chunkIntersects` (section 5.6) against the chunk write box with the rectangle given and does nothing when false.
A `BOX`, `PUT`, `WATER` row has the meaning of section 5.8's conventions. Loops are given in the text between the tables, with the row numbers they follow.

#### 5.9.1 `generateWing(isRight, X)` (guard: `chunkIntersects(X, 0, X + 23, 20)`; called as `(false, 0)` and `(true, 33)`)

Order: rows 1 and 2; **loop A** (`i` 0..3): six `B` boxes `(X+i, i+1, i)-(X+i, i+1, 20)`; `(X+i+7, i+5, i+7)-(X+i+7, i+5, 20)`; `(X+17-i, i+5, i+7)-(X+17-i, i+5, 20)`; `(X+24-i, i+1, i)-(X+24-i, i+1, 20)`;
`(X+i+1, i+1, i)-(X+23-i, i+1, i)`; `(X+i+8, i+5, i+7)-(X+16-i, i+5, i+7)`; rows 3 to 9; **dot pass** (all `PUT B`): let `a = X + (isRight ? 19 : 5)` and `b = X + (isRight ? 5 : 19)`;
for `z` = 20, 17, 14, 11, 8, 5: `(a, 5, z)`; for `z` = 19, 16, 13, 10, 7: `(b, 5, z)`; for `i` 0..3: `(X + 17 - 3 i, 5, 5)` when not right, `(X + 24 - (17 - 3 i), 5, 5)` = `(X + 7 + 3 i, 5, 5)` when right; then `(b, 5, 5)`; rows 10 and 11.
(The loop of 4 steps places the dots along `z = 5` at `X+17, X+14, X+11, X+8` for the left wing and `X+7, X+10, X+13, X+16` for the right wing.)


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | X+0, 0, 0, X+24, 0, 20 | P |  |
| 2 | WATER | X+0, 1, 0, X+24, 10, 20 | water |  |
| 3 | BOX | X+4, 4, 4, X+6, 4, 20 | P |  |
| 4 | BOX | X+7, 4, 4, X+17, 4, 6 | P |  |
| 5 | BOX | X+18, 4, 4, X+20, 4, 20 | P |  |
| 6 | BOX | X+11, 8, 11, X+13, 8, 20 | P |  |
| 7 | PUT | X+12, 9, 12 | B |  |
| 8 | PUT | X+12, 9, 15 | B |  |
| 9 | PUT | X+12, 9, 18 | B |  |
| 10 | BOX | X+11, 1, 12, X+13, 7, 12 | P |  |
| 11 | BOX | X+12, 1, 11, X+12, 7, 13 | P |  |

#### 5.9.2 `generateEntranceArchs` (guard `chunkIntersects(22, 5, 35, 17)`)

Row 1: `WATER (25, 0, 0)-(32, 8, 20)`. Then for `i` 0..3, with `z = 5 + 4 i`, in this order: `B` boxes `(24, 2, z)-(24, 4, z)`, `(22, 4, z)-(23, 4, z)`; `PUT B (25, 5, z)`, `PUT B (26, 6, z)`, `PUT L (26, 5, z)`;
`B` boxes `(33, 2, z)-(33, 4, z)`, `(34, 4, z)-(35, 4, z)`; `PUT B (32, 5, z)`, `PUT B (31, 6, z)`, `PUT L (31, 5, z)`; `P` box `(27, 6, z)-(30, 6, z)`.

#### 5.9.3 `generateEntranceWall` (guard `chunkIntersects(15, 20, 42, 21)`)

Order: rows 1 to 20 of the table below; **loops 1 and 2** (all `PUT D` at `z = 21`): for `i` 0..6: `(28 - i, 6 + i)` and `(29 + i, 6 + i)`; for `i` 0..3: `(28 - i, 9 + i)` and `(29 + i, 9 + i)` (each pair is `x, y`); rows 21 and 22 (`D` at `(28, 12, 21)`, `(29, 12, 21)`);
**loop 3** (all `PUT D`, `z = 21`): for `i` 0..2: `(22 - 2 i, 8)`, `(22 - 2 i, 9)`, `(35 + 2 i, 8)`, `(35 + 2 i, 9)` (`x, y`); rows 23 to 35 (the flooding of the entrance doorway and the stepped gable).


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 15, 0, 21, 42, 0, 21 | P |  |
| 2 | WATER | 26, 1, 21, 31, 3, 21 | water |  |
| 3 | BOX | 21, 12, 21, 36, 12, 21 | P |  |
| 4 | BOX | 17, 11, 21, 40, 11, 21 | P |  |
| 5 | BOX | 16, 10, 21, 41, 10, 21 | P |  |
| 6 | BOX | 15, 7, 21, 42, 9, 21 | P |  |
| 7 | BOX | 16, 6, 21, 41, 6, 21 | P |  |
| 8 | BOX | 17, 5, 21, 40, 5, 21 | P |  |
| 9 | BOX | 21, 4, 21, 36, 4, 21 | P |  |
| 10 | BOX | 22, 3, 21, 26, 3, 21 | P |  |
| 11 | BOX | 31, 3, 21, 35, 3, 21 | P |  |
| 12 | BOX | 23, 2, 21, 25, 2, 21 | P |  |
| 13 | BOX | 32, 2, 21, 34, 2, 21 | P |  |
| 14 | BOX | 28, 4, 20, 29, 4, 21 | B |  |
| 15 | PUT | 27, 3, 21 | B |  |
| 16 | PUT | 30, 3, 21 | B |  |
| 17 | PUT | 26, 2, 21 | B |  |
| 18 | PUT | 31, 2, 21 | B |  |
| 19 | PUT | 25, 1, 21 | B |  |
| 20 | PUT | 32, 1, 21 | B |  |
| 21 | PUT | 28, 12, 21 | D |  |
| 22 | PUT | 29, 12, 21 | D |  |
| 23 | WATER | 15, 13, 21, 42, 15, 21 | water |  |
| 24 | WATER | 15, 1, 21, 15, 6, 21 | water |  |
| 25 | WATER | 16, 1, 21, 16, 5, 21 | water |  |
| 26 | WATER | 17, 1, 21, 20, 4, 21 | water |  |
| 27 | WATER | 21, 1, 21, 21, 3, 21 | water |  |
| 28 | WATER | 22, 1, 21, 22, 2, 21 | water |  |
| 29 | WATER | 23, 1, 21, 24, 1, 21 | water |  |
| 30 | WATER | 42, 1, 21, 42, 6, 21 | water |  |
| 31 | WATER | 41, 1, 21, 41, 5, 21 | water |  |
| 32 | WATER | 37, 1, 21, 40, 4, 21 | water |  |
| 33 | WATER | 36, 1, 21, 36, 3, 21 | water |  |
| 34 | WATER | 33, 1, 21, 34, 1, 21 | water |  |
| 35 | WATER | 35, 1, 21, 35, 2, 21 | water |  |

#### 5.9.4 `generateRoofPiece` (guard `chunkIntersects(21, 21, 36, 36)`)

Rows 1 and 2; then for `i` 0..3 four `B` boxes: `(21+i, 13+i, 21+i)-(36-i, 13+i, 21+i)`; `(21+i, 13+i, 36-i)-(36-i, 13+i, 36-i)`; `(21+i, 13+i, 22+i)-(21+i, 13+i, 35-i)`; `(36-i, 13+i, 22+i)-(36-i, 13+i, 35-i)`; then rows 3 to 23.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 21, 0, 22, 36, 0, 36 | P |  |
| 2 | WATER | 21, 1, 22, 36, 23, 36 | water |  |
| 3 | BOX | 25, 16, 25, 32, 16, 32 | P |  |
| 4 | BOX | 25, 17, 25, 25, 19, 25 | B |  |
| 5 | BOX | 32, 17, 25, 32, 19, 25 | B |  |
| 6 | BOX | 25, 17, 32, 25, 19, 32 | B |  |
| 7 | BOX | 32, 17, 32, 32, 19, 32 | B |  |
| 8 | PUT | 26, 20, 26 | B |  |
| 9 | PUT | 27, 21, 27 | B |  |
| 10 | PUT | 27, 20, 27 | L |  |
| 11 | PUT | 26, 20, 31 | B |  |
| 12 | PUT | 27, 21, 30 | B |  |
| 13 | PUT | 27, 20, 30 | L |  |
| 14 | PUT | 31, 20, 31 | B |  |
| 15 | PUT | 30, 21, 30 | B |  |
| 16 | PUT | 30, 20, 30 | L |  |
| 17 | PUT | 31, 20, 26 | B |  |
| 18 | PUT | 30, 21, 27 | B |  |
| 19 | PUT | 30, 20, 27 | L |  |
| 20 | BOX | 28, 21, 27, 29, 21, 27 | P |  |
| 21 | BOX | 27, 21, 28, 27, 21, 29 | P |  |
| 22 | BOX | 28, 21, 30, 29, 21, 30 | P |  |
| 23 | BOX | 30, 21, 28, 30, 21, 29 | P |  |

#### 5.9.5 `generateLowerWall` (three sections, each with its own guard)

* **Section 1** (guard `chunkIntersects(0, 21, 6, 58)`): rows 1 to 3 (`P`, `WATER`, `P`); then for `i` 0..3: `B` box `(i, i+1, 21)-(i, i+1, 57-i)`; then for `z` from 23 while `z < 53` step 3 (23, 26, ..., 50): `PUT B (5, 5, z)`; row 4 (`PUT B (5, 5, 52)`);
  the `i` loop is run **a second time** (identical boxes, idempotent); rows 5 and 6.
* **Section 2** (guard `chunkIntersects(51, 21, 58, 58)`): rows 7 to 9; for `i` 0..3: `B` box `(57-i, i+1, 21)-(57-i, i+1, 57-i)`; for `z` 23 to 50 step 3: `PUT B (52, 5, z)`; rows 10 to 12.
* **Section 3** (guard `chunkIntersects(0, 51, 57, 57)`): rows 13 and 14; for `i` 0..3: `B` box `(i+1, i+1, 57-i)-(56-i, i+1, 57-i)`.

(Row numbers refer to the table below.)


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 0, 0, 21, 6, 0, 57 | P |  |
| 2 | WATER | 0, 1, 21, 6, 7, 57 | water |  |
| 3 | BOX | 4, 4, 21, 6, 4, 53 | P |  |
| 4 | PUT | 5, 5, 52 | B |  |
| 5 | BOX | 4, 1, 52, 6, 3, 52 | P |  |
| 6 | BOX | 5, 1, 51, 5, 3, 53 | P |  |
| 7 | BOX | 51, 0, 21, 57, 0, 57 | P |  |
| 8 | WATER | 51, 1, 21, 57, 7, 57 | water |  |
| 9 | BOX | 51, 4, 21, 53, 4, 53 | P |  |
| 10 | PUT | 52, 5, 52 | B |  |
| 11 | BOX | 51, 1, 52, 53, 3, 52 | P |  |
| 12 | BOX | 52, 1, 51, 52, 3, 53 | P |  |
| 13 | BOX | 7, 0, 51, 50, 0, 57 | P |  |
| 14 | WATER | 7, 1, 51, 50, 10, 57 | water |  |

#### 5.9.6 `generateMiddleWall` (three sections)

* **Section 1** (guard `chunkIntersects(7, 21, 13, 50)`): rows 1 to 3; for `i` 0..3: `B` box `(7+i, 5+i, 21)-(7+i, 5+i, 54)`; for `z` from 21 to 45 step 3: `PUT B (12, 9, z)`.
* **Section 2** (guard `chunkIntersects(44, 21, 50, 54)`): rows 4 to 6; for `i` 0..3: `B` box `(50-i, 5+i, 21)-(50-i, 5+i, 54)`; for `z` 21 to 45 step 3: `PUT B (45, 9, z)`.
* **Section 3** (guard `chunkIntersects(8, 44, 49, 54)`): rows 7 and 8; for `x` from 12 to 45 step 3 (12, 15, ..., 45): `PUT B (x, 9, 45)` and `PUT B (x, 9, 52)`; and when `x` is one of `12, 18, 24, 33, 39, 45` also `PUT B` at
  `(x, 9, 47)`, `(x, 9, 50)`, `(x, 10, 45)`, `(x, 10, 46)`, `(x, 10, 51)`, `(x, 10, 52)`, `(x, 11, 47)`, `(x, 11, 50)`, `(x, 12, 48)`, `(x, 12, 49)` (in this order); then for `i` 0..2: `P` box `(8+i, 5+i, 54)-(49-i, 5+i, 54)`; rows 9 and 10.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 7, 0, 21, 13, 0, 50 | P |  |
| 2 | WATER | 7, 1, 21, 13, 10, 50 | water |  |
| 3 | BOX | 11, 8, 21, 13, 8, 53 | P |  |
| 4 | BOX | 44, 0, 21, 50, 0, 50 | P |  |
| 5 | WATER | 44, 1, 21, 50, 10, 50 | water |  |
| 6 | BOX | 44, 8, 21, 46, 8, 53 | P |  |
| 7 | BOX | 14, 0, 44, 43, 0, 50 | P |  |
| 8 | WATER | 14, 1, 44, 43, 10, 50 | water |  |
| 9 | BOX | 11, 8, 54, 46, 8, 54 | B |  |
| 10 | BOX | 14, 8, 44, 43, 8, 53 | P |  |

#### 5.9.7 `generateUpperWall` (three sections)

* **Section 1** (guard `chunkIntersects(14, 21, 20, 43)`): rows 1 to 4; for `i` 0..3: `B` box `(14+i, 9+i, 21)-(14+i, 9+i, 43-i)`; for `z` from 23 to 39 step 3: `PUT B (19, 13, z)`.
* **Section 2** (guard `chunkIntersects(37, 21, 43, 43)`): rows 5 to 8; for `i` 0..3: `B` box `(43-i, 9+i, 21)-(43-i, 9+i, 43-i)`; for `z` 23 to 39 step 3: `PUT B (38, 13, z)`.
* **Section 3** (guard `chunkIntersects(15, 37, 42, 43)`): rows 9 to 11; for `i` 0..3: `B` box `(15+i, 9+i, 43-i)-(42-i, 9+i, 43-i)`; for `x` from 21 to 36 step 3: `PUT B (x, 13, 38)`.


| # | op | arguments | blk | when |
|---|---|---|---|---|
| 1 | BOX | 14, 0, 21, 20, 0, 43 | P |  |
| 2 | WATER | 14, 1, 22, 20, 14, 43 | water |  |
| 3 | BOX | 18, 12, 22, 20, 12, 39 | P |  |
| 4 | BOX | 18, 12, 21, 20, 12, 21 | B |  |
| 5 | BOX | 37, 0, 21, 43, 0, 43 | P |  |
| 6 | WATER | 37, 1, 22, 43, 14, 43 | water |  |
| 7 | BOX | 37, 12, 22, 39, 12, 39 | P |  |
| 8 | BOX | 37, 12, 21, 39, 12, 21 | B |  |
| 9 | BOX | 21, 0, 37, 36, 0, 43 | P |  |
| 10 | WATER | 21, 1, 37, 36, 14, 43 | water |  |
| 11 | BOX | 21, 12, 37, 36, 12, 39 | P |  |
### 5.10 Spawning in and around the monument

**Elder guardians** (`OceanMonumentPiece.spawnElder(chunkBox, x, y, z)`): `p = getWorldPos(x, y, z)` of the calling piece; if `chunkBox` contains `p` (inclusive): create an `elder_guardian` (reason `STRUCTURE`);
if created: `heal(maxHealth)`, `snapTo(p.x + 0.5, p.y, p.z + 0.5, yaw 0, pitch 0)`, `finalizeSpawn(level, difficulty at its block, STRUCTURE, no group data)`, add it with passengers. There is no persistence call and no
"already spawned" flag: the call is made on every pass whose chunk box contains the position, which is exactly one pass (the position is one block). Callers: the penthouse at `(6, 1, 6)`; a design-0 wing at `(11, 2, 16)`;
a design-1 wing at `(11, 5, 13)`. Because the two wings always have opposite designs (section 5.4 step 7) a monument has **exactly 3 elder guardians**: one in each wing and one in the penthouse (44 part 2 section 10.8 records the same from the spawn side).

**Guardians and other natural spawns**: the structure element has `spawn_overrides` (data, read): `monster` with `bounding_box = full` and the single entry `guardian`, weight 1, group size uniform 2 to 4;
`axolotls` and `underground_water_creature`, both `full`, with empty lists. The mechanism is 36-1 section 10 (query `getMobsAt`): any position inside the **start's overall box** (the union of the start's piece boxes,
here exactly the one building box `(x0, 39, z0)-(x0 + 57, 61, z0 + 57)`, not inflated because `terrain_adaptation` is `none`) uses these lists instead of the biome's for those three categories: `monster` spawns
yield only guardians (in groups of 2 to 4), and no axolotls and no underground water creatures spawn there. The other categories (`water_creature`, `water_ambient`, `creature`, `ambient`, `misc`) are unchanged. The spawn
rule for guardians themselves (water, light gate) is in the guardian entries of the mob documents (20 and 21; 44 part 2 section 8.3 lists the override).

### 5.11 Serialization and regeneration

Only `omb` is in the start's piece list. Its NBT is the base of 36-1 section 6.7 (`id` `omb`, `BB` the 58 x 23 x 58 box, `O` the orientation, `GD` 0); `OceanMonumentPiece.addAdditionalSaveData` adds nothing, and loading a
`MonumentBuilding` from NBT creates an **empty** `childPieces` list. The children are never saved (their generation depth is 1 and their `mainDesign` values are not stored).

`OceanMonumentStructure.regeneratePiecesAfterLoad(chunkPos, worldSeed, container)` (called when a start of an `ocean_monument` is loaded, 36-1 section 7.3): if the container is empty it returns it unchanged. Otherwise:
`r = WorldgenRandom(LCG(unique seed))` then `setLargeFeatureSeed(worldSeed, chunkPos.x, chunkPos.z)`; `p0 = pieces[0]`; `x0 = p0.box.minX`, `z0 = p0.box.minZ`; `d = HORIZONTAL.getRandomDirection(r)` (**one `nextInt(4)` is always drawn**);
`dir = p0.orientation` if not null, else `d`; build `MonumentBuilding(r, x0, z0, dir)` (the whole child list of section 5.4 is generated again, with the same draws as at generation, because the random state after the direction
draw is the same) and return a container holding just that building. So a loaded monument places identically to a freshly generated one. (The chunk position passed is the start's own chunk, read: `StructureStart.loadStaticStart` reads the int tags `ChunkX` and `ChunkZ` of the start's NBT, builds a `ChunkPos` from them and passes it, with the world seed and the loaded pieces, to `regeneratePiecesAfterLoad` when the loaded structure is an `OceanMonumentStructure`.)

### 5.12 Terrain and water

`terrain_adaptation` is `none`: the monument does not use the beardifier. It clears its own space by the water boxes of section 5.7 steps 1 and 5 (non-water, non-ice blocks inside become water below sea level
and air at or above it), and builds its floor of prismarine layers at local `y = 0` with the 23 foundation pillars of 5.7 step 4 reaching down through water and replaceable blocks. Ice,
packed ice, blue ice and water are never removed by the clearing. The start requires deep ocean at the centre (`has_structure/ocean_monument` = `is_deep_ocean`) and ocean or river within 29 blocks of the point at
`chunkMin + 9` (section 5.1).

---

## 6. Worked examples

All examples marked "(computed)" were produced by a scratch implementation of the rules of this document (Java LCG, `getSeed`, the room graph, the cluster and the template lists) and are test vectors, not artifact
output (Open question 12). The sanity values of the scratch LCG agree with 10 section 2.7 and 11 section 4 (`getSeed(1, 2, 3) = -33674130277896`; `setLargeFeatureSeed(0, 1, 0)` then `next(32)` = 1118589937).

### 6.1 Monument geometry in the world (chunk (0, 0), for each direction; computed from the 36-1 section 6.4 mapping)

Building box for start chunk `(0, 0)`: `(-29, 39, -29)` to `(28, 61, 28)` for every direction. World position `v` of building-local `(9, 0, 22)` and the three boxes made from world corners
(`fromCorners` of `getWorldPos`):

| `dir` | grid origin `v` | left wing | right wing | penthouse |
|---|---|---|---|---|
| `NORTH` | `(-20, 39, 6)` | `(-28, 40, 7)`-`(-6, 47, 27)` | `(5, 40, 7)`-`(27, 47, 27)` | `(-7, 52, -7)`-`(6, 56, 6)` |
| `EAST` | `(-7, 39, -20)` | `(-28, 40, -28)`-`(-8, 47, -6)` | `(-28, 40, 5)`-`(-8, 47, 27)` | `(-7, 52, -7)`-`(6, 56, 6)` |
| `SOUTH` | `(-20, 39, -7)` | `(-28, 40, -28)`-`(-6, 47, -8)` | `(5, 40, -28)`-`(27, 47, -8)` | `(-7, 52, -7)`-`(6, 56, 6)` |
| `WEST` | `(6, 39, -20)` | `(7, 40, -28)`-`(27, 47, -6)` | `(7, 40, 5)`-`(27, 47, 27)` | `(-7, 52, -7)`-`(6, 56, 6)` |

(The wing boxes are 23 x 8 x 21 when the direction is along z and 21 x 8 x 23 along x.) Rooms, `dir = SOUTH`, with `v = (-20, 39, -7)`:
the entry room (index 2: `gx = 2`, `gy = 0`, `gz = 0`, cells 1,1,1): `makeBoundingBox(0,0,0,SOUTH, 8, 4, 8)` = `(0,0,0)-(7,3,7)`, moved by `(16, 0, 0)` and `v`: `(-4, 39, -7)` to `(3, 42, 0)`.
The core with `x = 3` (index 13: `gx = 3`, `gz = 2`; cells 2,2,2 so `(0,0,0)-(15,7,15)`) moved by `(24, 0, 16)` and `v`: `(4, 39, 9)` to `(19, 46, 24)`.
A double X room at index 10 (`gx = 0`, `gz = 2`): `(0,0,0)-(15,3,7)` moved by `(0, 0, 16)` and `v`: `(-20, 39, 9)` to `(-5, 42, 16)`.
Elder guardians for `SOUTH`: penthouse local `(6, 1, 6)` -> world `(-1, 53, -1)` (box minimum `(-7, 52, -7)`: `x = -7 + 6`, `z = -7 + 6`, `y = 52 + 1`); in the left wing (box minimum `(-28, 40, -28)`): design 0 local `(11, 2, 16)` -> `(-17, 42, -12)`,
design 1 local `(11, 5, 13)` -> `(-17, 45, -15)`.

### 6.2 A complete monument start (computed): world seed 0, start chunk (0, 0)

`LCG(0)` with `setLargeFeatureSeed(0, 0, 0)`: the direction draw gives `SOUTH`. The room graph's core `x` is 3, so the core is index 13. The child list in order (type, definition index):
`entry 2`, `core 13`, `DoubleX 10`, `DoubleX 32`, `DoubleZ 0`, `Simple 17` (`mainDesign` 0), `DoubleX 7`, `SimpleTop 41`, `DoubleZ 29`, `Simple 9` (1), `DoubleX 51`, `Simple 53` (2), `SimpleTop 26`, `Simple 37` (2),
`Simple 40` (2), `Simple 6` (1), `Simple 12` (0), `Simple 1` (2), `Simple 3` (2), `DoubleZ 25`, `Simple 35` (2), `DoubleX 15`, `DoubleZ 31`, `DoubleX 27`, `DoubleX 57`, `Simple 42` (2), `Simple 56` (1), `Simple 4` (1);
then the wing seed `s = 116690193` (odd): the left wing has `mainDesign` 1 and the right wing 0; then the penthouse. Totals: 13 simple, 7 DoubleX, 4 DoubleZ, 2 SimpleTop, 1 entry, 1 core = 28 rooms
covering 1 + 8 + 14 + 8 + 13 + 2 = 46 cells, so the 46 grid cells are exactly partitioned (no `DoubleY`, `DoubleXY` or `DoubleYZ` appears for this seed); with the two wings and the penthouse that is 31 children.
(In general the cells of the room pieces always partition the 46 grid cells.)

### 6.3 Ocean ruin vectors (computed unless stated)

* World seed 0, chunk `(0, 0)`, warm: `pos = (0, 90, 0)`, rotation `CLOCKWISE_180`, `nextFloat() <= 0.3` false (small), integrity 0.8, template `warm_2`; no cluster draw.
  Cold: the same rotation and size, then `i = 1`: pieces `brick_2` (0.8), `cracked_2` (0.7), `mossy_2` (0.5), all at `(0, 90, 0)` with `CLOCKWISE_180`.
* World seed 0, chunk `(4, 1)`, warm: `pos = (64, 90, 16)`, rotation `NONE`, large (integrity 0.9), template `big_warm_5`; the cluster draw passes (`<= 0.9`): `mainBox = (64, 90, 16)-(79, 90, 31)`,
  `n = 8`; the chosen members (anchor, rotation, template) in order: `(69, 90, 4) CLOCKWISE_90 warm_8`; `(56, 90, 7) CLOCKWISE_180 warm_7`; `(85, 90, 7) CLOCKWISE_90 warm_3`; `(51, 90, 19) CLOCKWISE_90 warm_8`; `(70, 90, 39) CLOCKWISE_90 warm_5`;
  `(85, 90, 38) CLOCKWISE_90 warm_7`; `(84, 90, 23) NONE warm_1`; `(56, 90, 36) COUNTERCLOCKWISE_90 warm_7` (none of the eight is skipped for intersecting the main ruin).
* The cluster candidate ranges relative to `base` (inclusive, from the table of section 3.6; derived, not computed): #1 `x` -15..-8, `z` 17..23; #2 `x` -15..-8, `z` 1..7; #3 `x` -15..-8, `z` -12..-8; #4 `x` 1..7, `z` 17..23;
  #5 `x` 1..7, `z` -12..-10; #6 `x` 17..23, `z` 19..24; #7 `x` 17..23, `z` 1..7; #8 `x` 17..23, `z` -12..-8.
* Rotation of the small footprint corner `(5, 0, 6)`: `NONE` -> `(5, 6)`; `CLOCKWISE_90` -> `(-6, 5)`; `CLOCKWISE_180` -> `(-5, -6)`; `COUNTERCLOCKWISE_90` -> `(6, -5)`. Of the main footprint `(15, 0, 15)`: `(15, 15)`, `(-15, 15)`, `(-15, -15)`, `(15, -15)` (derived from section 2.2).
* `adaptedHeight` (derived by hand): small ruin, rotation `NONE`, anchor `p = (10, 50, 20)` (so `base = 49`), `corner = (15, 50, 26)`, 6 x 7 = 42 columns, `dx = 5`. If 20 columns end at `y = 45` and the rest at 49: `lowest = 45`, `base - lowest = 4 > 2`,
  `count = 20 > dx - 2 = 3` -> the result is `46`. If only 3 columns are that low: `count = 3 > 3` is false -> the result stays `50`. If the lowest floor is 48 (`base - lowest = 1`) the result stays `50` however many columns are low.
* Per-block rot: block world position `(70, 50, 20)`: `getSeed = 28171223183139`, first `nextFloat()` of `LCG(that)` = 0.792293: kept at integrity 0.8 and 0.9, removed at 0.7 and 0.5. `(0, 0, 0)`: seed 0, float 0.730968 (kept at 0.8, removed at 0.7).
  `(1, 2, 3)`: 0.795369; `(-5, 40, 17)`: 0.607119 (kept at 0.7, removed at 0.5).
* Suspicious blocks: a block at world `(70, 50, 20)` that becomes suspicious gets `LootTableSeed = -3831520032679271255` (the first `nextLong()` of `LCG(getSeed(70, 50, 20))`). For the capped shuffle: world seed 12345, template position
  `(64, 50, 16)`: `F = 6674089274190705457` (first `nextLong()` of `LCG(12345)`), the stream `LCG(getSeed(64, 50, 16) xor F)`, and the shuffle of the index list `0..7` gives `[0, 4, 2, 1, 5, 6, 3, 7]`.

### 6.4 Shipwreck vectors

* (computed) World seed 0, chunk `(0, 0)`: ocean: rotation `CLOCKWISE_180`, `nextInt(20)` selects index 8 = `rightsideup_fronthalf`; beached (the other structure at the same chunk): rotation `CLOCKWISE_180`, `nextInt(11)` selects index 6 = `rightsideup_backhalf`.
  World seed 0, chunk `(7, -3)`, ocean: `CLOCKWISE_90`, `upsidedown_full`.
* (computed) Palette choice `LCG(getSeed(templatePosition)).nextInt(8)`: position `(0, 40, 0)` -> 3; `(0, 41, 0)` -> 0; `(0, 62, 0)` -> 2; `(100, 45, -30)` -> 5; `(-17, 52, 33)` -> 3.
* (derived) Bounding box of a `with_mast` piece (size `[9, 21, 28]`) at `templatePosition (0, 90, 0)`, rotation `CLOCKWISE_90`, pivot `(4, 0, 15)`: `transform((0,0,0))` = `(px + pz - 0, pz - px + 0)` = `(19, 11)`; `transform((8, 20, 27))` = `(4 + 15 - 27, 15 - 4 + 8)` = `(-8, 19)`;
  box `x` -8..19, `z` 11..19, `y` 90..110. The rectangle used for the **height** is the unrotated `(0..8, 0..27)` from the template position (section 4.3), not this box.
* Beached heights: lowest surface 64 and `with_mast` (`size.y = 21`): `64 - 10 - d`, `d` = the next `nextInt(3)` of the placement random.

### 6.5 Data marker effects

A ruin `chest` marker at `(x, y, z)` in water: block `chest` (facing north, single), `waterlogged = true`, then loot table `chests/underwater_ruin_small` (small ruin) with seed = the next `nextLong()` of the placement random.
A `drowned` marker at `y = 62` with sea level 63: one drowned persists there and the marker cell becomes water; at `y = 64` the marker cell becomes air.

---

## 7. Validation: checkable facts

| # | Fact | Where |
|---|---|---|
| 1 | The jar has 48 files under `structure/underwater_ruin/` (warm 8, brick 8, cracked 8, mossy 8, big_brick 4, big_cracked 4, big_mossy 4, big_warm 4), of size `[6, 7, 7]` (small) or `[16, 16, 16]` (big) | 3.1 |
| 2 | Those 48 files hold 47 `chest` and 51 `drowned` markers; the 20 shipwreck files hold 14 `supply_chest`, 16 `map_chest`, 14 `treasure_chest` | 3.1, 4.1 |
| 3 | Every shipwreck template has 8 palettes; none has `size.x` or `size.y` above 32, so `isTooBigToFitInWorldGenRegion` is false for all | 4.1, 4.3 |
| 4 | Ruin: `nextFloat() <= large_probability` (inclusive); integrity 0.9 large / 0.8 small; cold stacks three pieces with integrities as passed, 0.7, 0.5; the same index for all three | 3.3, 3.4 |
| 5 | Cluster: 8 candidates, all 16 draws made first; `n` in 4..8; one `nextInt(size)` and one rotation draw per repetition; the main footprint is excluded by box intersection only | 3.6 |
| 6 | Suspicious blocks: at most 5 per piece, `capped` with `evaluatesEntirePieceState`, positional random from the world seed and the adapted template position | 2.4, 3.7 |
| 7 | Shipwreck: pivot `(4, 0, 15)`, ocean y = integer mean of `OCEAN_FLOOR_WG` over the unrotated rectangle, beached y = `min - size.y / 2 - nextInt(3)` of `WORLD_SURFACE_WG` heights | 4.3 |
| 8 | Monument box: 58 x 23 x 58 at `(chunkMin - 29, 39, chunkMin - 29)`, `y` 39..61, same for all four directions | 5.1 |
| 9 | Monument grid: 46 grid rooms (20 + 20 + 6), 95 grid links plus 3 special links, the z slots mirrored; core at `(nextInt(4), 0, 2)` claiming 8 cells | 5.2, 5.3 |
| 10 | Pruning draws `nextInt(6)` up to 5 times per room (until two openings are closed), whether or not the draw hits an open slot; the open-door graph stays connected to the source | 5.3 |
| 11 | Fitter order XY, YZ, Z, X, Y, SimpleTop, Simple; the cells of the room pieces partition the 46 cells | 5.4 |
| 12 | Each monument has 3 elder guardians (penthouse, design 0 wing, design 1 wing), 8 gold blocks, and sponge rooms only from `SimpleTop` pieces | 5.8, 5.10 |
| 13 | The monument piece list has exactly one piece (`omb`); loading regenerates the children with one always-drawn direction `nextInt(4)` | 5.11 |
| 14 | `OceanMonumentPieces` has 23 nested classes in the jar (the switch-map class, 11 room, wing and penthouse classes, the base class, the building, the definition, the fitter interface and the seven fitters) | method line |
| 15 | Piece ids: `orp`, `shipwreck`, `omb`, `omcr`, `omdxr`, `omdxyr`, `omdyr`, `omdyzr`, `omdzr`, `omentry`, `ompenthouse`, `omsimple`, `omsimplet`, `omwr` | 36-1 section 2.4 |
| 16 | In the jar, the structure JSON of all five structures has `step` `surface_structures`, no `terrain_adaptation`, and the sets have the spacing, separation and salt values of section 1 | 1 |

---

## Open questions

1. **Heightmap evolution inside one region.** `OceanRuinPiece.postProcess` and `ShipwreckPiece.postProcess` read `level.getHeight(OCEAN_FLOOR_WG | WORLD_SURFACE_WG, ...)` on the world-generation region at each call.
   Whether the blocks written by earlier pieces (other ruins of a cluster, earlier chunk passes) change those heightmaps before a later piece reads them was not traced here (the update rule is 35-1 section 4); the ruin recomputes
   its height on every call, the shipwreck only once (the `height_adjusted` flag).
2. **Template engine details.** Section 2.3's description of `placeInWorld` (the barrier write, the `LootTableSeed` draw for randomizable containers, waterlogging, palette choice) was read from the decompiled method but belongs to 36-2;
   the exact interleaving of the loot-seed draws of several chests and the marker pass is as described, but the waterlogging pass and entity placement were not traced.
3. (Closed.) The `Rot` and `BiomeType` spellings were read from `ExtraCodecs.legacyEnum` (section 3.5).
4. **Dead branches inferred.** `FitDoubleZ.create` (a branch that picks `conn[SOUTH]`) and the `open S` row of `SimpleTop` are inferred dead from the `fits` conditions (sections 5.4 and 5.8.3).
5. **Shipwreck `getLowestY` argument order.** The call passes `(minX, xSpan, minZ, zSpan)` to a method documented in 36-1 as taking `(x, z, sizeX, sizeZ)`; this document records the artifact's call literally. The branch runs only for a template whose `size.x` or `size.y`
   exceeds 32, which no shipped template does, so the sampled corners cannot be validated with the stock data.
6. (Closed.) The chunk passed to `regeneratePiecesAfterLoad` is read from `ChunkX`/`ChunkZ` in `StructureStart.loadStaticStart` (section 5.11).
7. **Mob details.** `finalizeSpawn` of the drowned (equipment, baby chance, passengers) and of the elder guardian, and the guardian's natural spawn rule, are in the mob documents, not here.
8. **Biome sampling for the monument.** `getBiomesWithin` is read; the climate sampler behind `getNoiseBiome` (10, 37) was not re-read.
9. **Loot tables and the brushable block entity** (data rows, 26 and 31 part 4) were not read for this document beyond their names and paths.
10. **Chest orientation in ruins.** The `chest` marker writes the default chest state with no orientation logic (read); rotated ruins therefore have north-facing chests. No other facing rule was found in the class.
11. **Template block order in `placeInWorld`** (palette order, which orders the `LootTableSeed` draws and indexes the shuffle of the `capped` processor) is 36-2's and was only partly read.
12. **Computed vectors.** Every value marked "(computed)" (sections 6.2 to 6.4: the room-graph run, the cluster run, the shipwreck choices, the palette indices, the capped shuffle, the rot floats) comes from throwaway scratch code written from this document's own rules, not from the artifact;
    it was cross-checked only against the `getSeed` and `setLargeFeatureSeed` vectors of 10 and 11 and against the known first output of `LCG(0).nextFloat()`. The scratch code is not kept. An independent reviewer re-derived the main vectors (the ruin and shipwreck vectors and the 28-room monument list) with separate scratch code from the artifact's rules and they agree; the "(derived)" `adaptedHeight` example is hand arithmetic and was confirmed correct. These remain test vectors, not artifact output.
13. **Placement ordering side effects.** Fluid ticks and `placeBlock` side effects of the monument's writes (36-1 section 6.5) are as in 36-1; whether flowing water re-fills the cleared pit before all chunk passes finish is a generation-order question owned by 33.
14. **Machine comparison of the room tables (RS20 fixer pass).** For the eight classes of sections 5.8.1 to 5.8.8, every `BOX`, `WATER` and `FILL` row of the tables was compared with the constant arguments of the six-integer box calls in the class's `postProcess` (multiset of operation and coordinates, `javap -c` output, blocks and `when` conditions not compared).
    Result: the call counts and coordinates agree exactly (12, 80, 18, 23, 36, 13 rows for the first six classes, no row missing or extra). Two further classes, `DoubleXYRoom` and `DoubleYZRoom`, make 1 and 2 extra box calls whose coordinates are computed from loop variables, not constants (the column pass and wall pass 1 of sections 5.8.7 and 5.8.8); those loops were read by hand, not machine-compared.
    Not compared by machine: the block (`B`, `P`, `D`, `S`, `L`) of each row, the `when` conditions, sections 5.8.9 to 5.9.7 (core, wings, penthouse and the building's own walls: different table form), and the draw order inside the loops.
15. **Review coverage.** A first review covered sections 1 to 5.8.8 and reported no mismatch; the parts after it (5.8.9 to the end) were not independently reviewed at that time. The omitted-method check found `spawnElder`, `generateDefaultFloor`, `generateBoxOnFillOnly` (section 5.6) and the save and load path (section 5.11) already documented.
