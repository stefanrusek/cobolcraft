# 56. Superflat world (the flat chunk generator, its settings, presets and create-world screens)

| Item | Value |
|---|---|
| Covers | The flat generator of 26.3 end to end: the settings schema and defaults and where a world stores them (§2), the nine presets and the tag that lists them (§3), how a chunk is generated and which stages are skipped, the heightmap and spawn queries, structures and mob spawning (§4), the "is flat" flag, sea level and the client effects (§5), the create-world screens with every message key and English text (§6), worked examples (§7) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.FlatLevelSource`, `...levelgen.flat.*`, `ChunkGenerator`, `ChunkGeneratorStructureState`, `chunk.status.ChunkStatusTasks`, `biome.FixedBiomeSource`, `WorldDimensions`, `PrimaryLevelData`, `WorldGenerationContext`, `ServerLevel`, `ServerPlayer`, `PlayerSpawnFinder`, `MinecraftServer.setInitialSpawn`, `CommonPlayerSpawnInfo`, `ClientLevel$ClientLevelData`, `FogRenderer`, `SkyRenderer`, `DedicatedServerProperties$WorldDimensionData` and the create-world and flat-editor screens, and of the data files and `assets/minecraft/lang/en_us.json` in the jar. No execution. Counts were taken with `unzip -Z1 <jar> \| grep -v '/$' \| grep <prefix> \| wc -l`. Values marked "(computed)" come from arithmetic or from a scratch script over the jar's data files (not from the artifact's code); they are test vectors, unverified against a running artifact. |
| Extends | 07 section 10.4.5, 12 section 3.3 and 3.4d, 33 section 6, 35-1 sections 4 and 8.3, 35-5 section 11, 36-1 section 4.1, 44-2 |
| Closes | 35-5 Open question 6 (fill layers and flat worlds). Also answers 07 Open question 31 (defaults of `lakes` and `features`, element form of `layers`: §2.1, §2.2); 07 itself was not edited in this round |

Values are marked "(inferred)" when deduced and "(recalled, not verified)" when taken from memory; both are listed in the Open
questions. Nothing in this document is taken from recall unless it carries that mark. References use the form "NN section M".
Coordinates are block coordinates, `y` is the vertical axis, and the overworld dimension type has `min_y` -64, `height` 384
(top block 319), read in `data/minecraft/dimension_type/overworld.json`. "Layer index" `i` means the layer at `y = minY + i`.

---

## 1. Overview and where the pieces are

| Piece | Class (where read) | Role |
|---|---|---|
| Settings | `FlatLevelGeneratorSettings` | layers, biome, structure overrides, the two flags; the codec of §2 |
| Layer | `FlatLayerInfo` | one `{block, height}` entry |
| Generator | `FlatLevelSource` (extends `ChunkGenerator`) | codec id `minecraft:flat`, one member `settings`; a `FixedBiomeSource` of the settings' biome |
| Preset registry | `FlatLevelGeneratorPreset`, `FlatLevelGeneratorPresets` | `{display, settings}` elements; registry key `flat_level_generator_preset` (a data pack registry) |
| Preset tag | `FlatLevelGeneratorPresetTags.VISIBLE` | which presets the preset screen shows |
| World presets | `data/minecraft/worldgen/world_preset/flat.json`, `flat_all_dimensions.json` | what the "Superflat" world type installs |
| Flat flag | `WorldDimensions.specialWorldProperty`, `PrimaryLevelData.isFlatWorld`, `ServerLevel.isFlat` | the "is flat" boolean of the spawn info (§5) |
| Screens | `CreateFlatWorldScreen`, `PresetFlatWorldScreen`, `PresetEditor`, `CreateWorldScreen$WorldTab`, `WorldCreationUiState` | §6 |

The flat generator is a complete `ChunkGenerator` of its own. It shares the generation pyramid, the decoration driver, the
structure placement engines and the heightmaps with the noise generator (35-1 section 4, 36-1 section 4), and replaces
everything that the noise generator does in its terrain stage (§4.2).

---

## 2. The settings

### 2.1 Schema (`FlatLevelGeneratorSettings.CODEC`)

The same codec is used for a data pack JSON file (as `settings` of a flat preset, or of a `generator` of type `minecraft:flat` in
a world preset or dimension file) and for the saved world (§2.5). `lakes` and `features` are "always present" optional members
(written even when equal to their default).

| Member | Kind | Required | Default | Notes |
|---|---|---|---|---|
| `layers` | list of layer (§2.2), **bottom first** | **required** (no default) | none | may be empty (valid; §2.4); the sum of all heights must be at most `DimensionType.Y_SIZE` = 4064 (`(1 << 12) - 32`, 00 section on packed positions, 04 "height" range 16 to 4064); a larger sum is a decode error, message `Sum of layer heights is > 4064` |
| `biome` | biome id string | optional (lenient) | `minecraft:plains` | written always; when the string does not name a registered biome the member is treated as absent and the game logs `Unknown biome, defaulting to plains` and uses plains |
| `lakes` | boolean | optional | **false** | enables the two lava lakes (§4.5) |
| `features` | boolean | optional | **false** | enables the biome's decoration features (§4.5) |
| `structure_overrides` | structure-set reference or list (§2.3) | optional (lenient) | absent = **all structure sets** (§4.7) | an explicit empty list means no structures |

The settings object is "stable" (`Codec.stable`), i.e. it does not make a data pack experimental.

### 2.2 The layer element (`FlatLayerInfo.CODEC`)

| Member | Kind | Required | Allowed values |
|---|---|---|---|
| `height` | int | required | 0 to 4064 inclusive (`Codec.intRange(0, Y_SIZE)`) |
| `block` | block id string | required | a registered block (looked up through the block registry's holder-by-name codec; an unknown name is expected to be a decode error, inferred, Open question 6). The layer uses the block's **default state** (`Block.defaultBlockState`): no block state properties can be given |

Order in the jar's JSON files: `block` then `height` (the data generator sorts keys); the codec's own group order is `height`
then `block`. Neither matters when reading.

### 2.3 `structure_overrides`

A structure-set holder set (`RegistryCodecs.holderSet` of the registry `worldgen/structure_set`). The jar's nine preset files show
the three forms the data generator wrote: a one-element set as a **bare string** (`"minecraft:villages"`), a longer set as a list of
strings, and an empty set as `[]`. A tag reference `#namespace:name` is the third reading form of the codec (inferred from the
codec's name; not exercised by any file of the jar, Open question 4). Meaning: the generator only places structure sets named
here, further filtered by the biome test of §4.7. The member being **absent** is a different state from `[]`: absent allows
every structure set of the registry.

The 21 structure sets of the jar (`worldgen/structure_set/`, counted from the archive): `abandoned_camp`, `ancient_cities`,
`buried_treasures`, `desert_pyramids`, `end_cities`, `igloos`, `jungle_temples`, `mineshafts`, `nether_complexes`,
`nether_fossils`, `ocean_monuments`, `ocean_ruins`, `pillager_outposts`, `ruined_portals`, `shipwrecks`, `strongholds`,
`swamp_huts`, `trail_ruins`, `trial_chambers`, `villages`, `woodland_mansions`.

### 2.4 Derived state (built by `updateLayers` and `adjustGenerationSettings`)

- **Expanded layer list** `layers`: each layer's default block state repeated `height` times, in list order. Index 0 is the lowest
  block. Its length is the **total height** (sum of heights).
- **`voidGen`**: true when every state of the expanded list is air (also true for an empty list; inferred from the empty
  `allMatch`). Used only for the decoration gate of §4.5.
- **Non-solid layers are nulled.** When the generation settings are built (the first call of the generator's settings getter,
  which `ChunkGenerator.validate` forces together with the per-step feature table; the call before the first chunk is inferred,
  Open question 7), every expanded entry whose state does **not** satisfy the `MOTION_BLOCKING` heightmap test (35-1 section 4.2:
  the block is not in the tag `blocks_motion_in_heightmap` and has no fluid) is replaced by **null** in the expanded list, and a
  `fill_layer` feature for that index is registered instead (§4.4). Air, a snow layer, flowers and any other non-motion-blocking
  block are such layers. Water and lava stay in the list (their fluid state counts). The null entries are visible to every later
  user of the list (§4.3, §4.6).
- The settings keep their two booleans after a copy: `withBiomeAndLayers(layers, structureOverrides, biome)` makes a new settings
  object with the same lava-lake list and the same two flags, the given layers, overrides and biome. The editor screens use it
  (§6.4).

### 2.5 Where a world stores it

Not in `level.dat`. In 26.3 the generator settings are part of the world-wide saved data file
`<world>/data/minecraft/world_gen_settings.dat` (07 section 10.4.5, `WorldGenSettings.CODEC`): gzip NBT, root `data` compound with
`seed`, `generate_structures`, `bonus_chest` and `dimensions`. The overworld entry of `dimensions` holds `type` (dimension type id) and
`generator`, where the generator compound holds `type` = `minecraft:flat` and one member `settings` with the schema of §2.1
(`FlatLevelSource.CODEC` is a record codec with the single field `settings`; the flattening of the dispatched generator compound is
as in 07 section 10.4.5, inferred there). NBT forms: a boolean is a Byte (07), `height` an Int, `block`, `biome` and the
structure-set names Strings, `layers` a List of Compound.

Example (default settings of §2.6 as a saved overworld stem):

```
dimensions: { "minecraft:overworld": {
  type: "minecraft:overworld",
  generator: { type: "minecraft:flat",
    settings: { layers: [ {height: 1, block: "minecraft:bedrock"},
                          {height: 2, block: "minecraft:dirt"},
                          {height: 1, block: "minecraft:grass_block"} ],
                biome: "minecraft:plains", lakes: 0b, features: 0b,
                structure_overrides: ["minecraft:strongholds", "minecraft:villages"] } } } }
```

(Whether a one-element override list is written as a bare string or as a list in NBT is not read; the JSON data files show the
bare string, Open question 4. A reader must accept both.)

The flat flag of §5 is **not stored**: it is derived at load time from the overworld generator (§5.1). The seed
(`seed` in the same file) does not influence flat terrain; it only seeds decoration, structure placement and the mob and biome
random sources.

### 2.6 The defaults, exactly

Three different "defaults" exist; they are not the same object:

| Where | Layers (bottom first) | Biome | Lakes | Features | `structure_overrides` |
|---|---|---|---|---|---|
| Codec defaults for absent members (§2.1) | none (required) | plains | false | false | absent (all sets) |
| `FlatLevelGeneratorSettings.getDefault` (used by the Customize button when the world is not flat, and by the text parser when the text is unusable, §6.4) | `bedrock` 1, `dirt` 2, `grass_block` 1 | plains | false | false | `strongholds`, `villages` (in this order) |
| World preset `flat` (what the Superflat world type installs; `worldgen/world_preset/flat.json`) | `bedrock` 1, `dirt` 2, `grass_block` 1 | plains | false | false | `strongholds`, `villages` |

The second and third rows are equal. **There is no preset in the registry that equals them**: `classic_flat` (§3.2) has the same
layers but only `villages`. So "the default superflat world" of the create-world screen is the world preset `flat`, not a
registry preset.

### 2.7 The two flat world presets

`data/minecraft/worldgen/world_preset/` has 7 files (counted from the archive). Two use the flat generator:

| World preset | In tag `normal` (shown in the World Type button) | Overworld | Nether and End |
|---|---|---|---|
| `flat` | yes (second entry, §6.1) | `type` `minecraft:overworld`, generator `minecraft:flat` with the §2.6 settings | `minecraft:noise` generators with the normal settings (End: `the_end` biome source and settings `minecraft:end`; Nether: `multi_noise` preset `nether`, settings `nether`) |
| `flat_all_dimensions` | **no** (in neither `normal` nor `extended`; reachable only from a data pack or a developer path) | flat; biome `desert`, `features` false, `lakes` false; layers `bedrock` 1, `sandstone` 67; no `structure_overrides` | flat with biome `basalt_deltas`, layers `bedrock` 1, `basalt` 3 (type `the_nether`); and flat with biome `the_end`, layers `bedrock` 1, `end_stone` 3 (type `the_end`) |

The other five files are `normal`, `large_biomes`, `amplified`, `single_biome_surface` and `debug_all_block_states`. The tag
`normal` lists `normal`, `flat`, `large_biomes`, `amplified`, `single_biome_surface` (this order); the tag `extended` is
`#minecraft:normal` plus `debug_all_block_states`.

A flat generator in a **dedicated server**: the property `level-type` names a world preset (the id; `default` and `largebiomes` are
legacy aliases for `normal` and `large_biomes`, others are looked up in the world preset registry; an unknown value logs
`Failed to parse level-type {}, defaulting to {}` and uses `normal`). When the chosen preset is `flat`, the property
`generator-settings` (a JSON object) is parsed with the §2.1 codec; on success the overworld generator is replaced by a flat
generator with those settings, on failure (for example no `layers`) the error is logged and the preset's own settings stay.

---

## 3. The preset registry and the visible tag

### 3.1 Registry and tag

- Registry `flat_level_generator_preset`, element = `{display: item id, settings: §2.1 settings}` (`FlatLevelGeneratorPreset.DIRECT_CODEC`;
  `display` is the item shown as the preset's icon). **9 files** in `data/minecraft/worldgen/flat_level_generator_preset/`
  (counted from the archive).
- Tag `data/minecraft/tags/worldgen/flat_level_generator_preset/visible.json`: 1 file, 9 entries, in this order:
  `classic_flat`, `tunnelers_dream`, `water_world`, `overworld`, `snowy_kingdom`, `bottomless_pit`, `desert`, `redstone_ready`,
  `the_void`. The preset screen lists exactly the members of this tag (§6.3), in the tag's order (inferred: the list is built by
  iterating the tag, Open question 3).
- `FlatLevelGeneratorPresets` also declares a resource key `test_world` (and the nine above) but registers no element for it and
  the jar has no data file for it (Open question 2).
- A preset whose layers contain a block that is not enabled by the world's feature flags is silently left out of the screen
  (logged as `Discarding flat world preset {} since it contains experimental blocks {}`). No preset of the jar contains such a
  block.

### 3.2 The nine presets (read from the data files)

All booleans false unless noted. Layers are bottom first, as stored.

| Preset id | Icon item | Biome | Layers (block x height) | Total | `features` | `lakes` | `structure_overrides` |
|---|---|---|---|---|---|---|---|
| `classic_flat` | `grass_block` | `plains` | bedrock 1, dirt 2, grass_block 1 | 4 | false | false | `villages` |
| `tunnelers_dream` | `stone` | `windswept_hills` | bedrock 1, stone 230, dirt 5, grass_block 1 | 237 | **true** | false | `mineshafts`, `strongholds` |
| `water_world` | `water_bucket` | `deep_ocean` | bedrock 1, deepslate 64, stone 5, dirt 5, gravel 5, water 90 | 170 | false | false | `ocean_ruins`, `shipwrecks`, `ocean_monuments` |
| `overworld` | `short_grass` | `plains` | bedrock 1, stone 59, dirt 3, grass_block 1 | 64 | **true** | **true** | `villages`, `mineshafts`, `pillager_outposts`, `ruined_portals`, `strongholds` |
| `snowy_kingdom` | `snow` | `snowy_plains` | bedrock 1, stone 59, dirt 3, grass_block 1, snow 1 | 65 | false | false | `villages`, `igloos` |
| `bottomless_pit` | `feather` | `plains` | cobblestone 2, dirt 3, grass_block 1 | 6 | false | false | `villages` |
| `desert` | `sand` | `desert` | bedrock 1, stone 3, sandstone 52, sand 8 | 64 | **true** | false | `villages`, `desert_pyramids`, `mineshafts`, `strongholds` |
| `redstone_ready` | `redstone` | `desert` | bedrock 1, stone 3, sandstone 116 | 120 | false | false | `[]` (none) |
| `the_void` | `barrier` | `the_void` | air 1 | 1 | **true** | false | `[]` (none) |

The code that registers the presets (`FlatLevelGeneratorPresets$Bootstrap`) was read and agrees with these files for the layers,
biomes and icon items. The sums and the following are (computed): top solid block `y` (= `-64 + total - 1`) is -61, 172, 105, -1,
0 (the snow layer; the grass is at -1), -59, -1, 55, and none (all air). The water world's top block is water at `y = 105`.
The "Bottomless Pit" preset is a normal (non-bottomless) 6-layer world: it has no bedrock, so the floor can be dug through;
nothing in the generator makes it special.

The English names are in §6.5 (`flat_world_preset.minecraft.<id>`), also the unknown-preset text `???`.

### 3.3 Which structure sets can really generate (computed)

A structure set takes part only if at least one of its structures lists the generator's biome in its `biomes` set (§4.7). Computed
from the 21 structure sets, the 52 structure files (`worldgen/structure/`) and the biome tags of the jar (scratch script;
set membership only):

| Biome | Structure sets that survive the biome test (structure that matched) |
|---|---|
| `plains` | `mineshafts` (mineshaft), `pillager_outposts`, `ruined_portals` (ruined_portal), `strongholds`, `trial_chambers`, `villages` (village_plains) |
| `desert` | `desert_pyramids`, `mineshafts`, `pillager_outposts`, `ruined_portals` (ruined_portal_desert), `strongholds`, `trial_chambers`, `villages` (village_desert) |
| `snowy_plains` | `igloos`, `mineshafts`, `pillager_outposts`, `ruined_portals` (ruined_portal), `strongholds`, `trial_chambers`, `villages` (village_snowy) |
| `windswept_hills` | `mineshafts`, `ruined_portals` (ruined_portal_mountain), `strongholds`, `trial_chambers` |
| `deep_ocean` | `mineshafts`, `ocean_monuments`, `ocean_ruins` (ocean_ruin_cold), `ruined_portals` (ruined_portal_ocean), `shipwrecks`, `strongholds`, `trial_chambers` |
| `the_void` | none |

Intersected with each preset's `structure_overrides`: every set named by a preset of §3.2 survives for that preset's biome (the
overrides were chosen to fit), except that `the_void` and `redstone_ready` name none. With an **absent** `structure_overrides` the
survivors are exactly the row of the biome (for plains: six sets).

---

## 4. How the generator fills a chunk

### 4.1 Generator limits

`FlatLevelSource` overrides the three limit methods with constants (read):

| Method | Value | Normal use |
|---|---|---|
| `getMinY()` | **0** | `WorldGenerationContext.getMinGenY()` = `max(level.minY, generator.getMinY())` |
| `getGenDepth()` | **384** | `WorldGenerationContext.getGenDepth()` = `min(level.height, generator.getGenDepth())` |
| `getSeaLevel()` | **-63** | `ServerLevel.getSeaLevel()` returns it (read), and so do `WorldGenRegion.getSeaLevel`, the spawn info (§5.2), `Level.getPrecipitationAt` and the `WorldGenerationContext` sea level |

Consequences (35-1 section 8.3 gives the anchor rules `above_bottom n = minGenY + n`, `below_top n = minGenY + depth - 1 - n`,
`relative_to_sea_level n = seaLevel + n`):

- In a flat world in the overworld dimension type (`min_y` -64, `height` 384) `minGenY` is **0**, not -64, and the generation
  depth is 384: `above_bottom 0` resolves to `y = 0`, `below_top 0` to `y = 383` (above the world top 319), `relative_to_sea_level 0`
  to `y = -63`. Any height range or provider that uses such an anchor therefore resolves relative to y = 0, 383 or -63, not
  relative to the level's real bottom or to the top of the ground (which of the biome features use which anchors was not read,
  Open question 11).
- Sea level -63 is independent of the layers: the Water World preset has water up to `y = 105` and sea level is still -63.
- `Level.getPrecipitationAt` passes `getSeaLevel()` to `Biome.getPrecipitationAt(pos, seaLevel)` (read). With the temperature rule of
  33 section 4.5 (height reduction starts above `sea + 17`) the reduction starts above `y = -46` in a flat world, so for the same
  biome snow and ice appear much lower than in the standard world (computed example in §7.6).

### 4.2 Stage by stage

`ChunkPyramid.GENERATION_PYRAMID` is shared (10 section 11.1, 35-1 section 4.1). What the flat generator does:

| Stage (`ChunkStatus`) | Flat behaviour |
|---|---|
| `empty` | as usual |
| `structure_starts` | `ChunkGenerator.createStructures` with the flat structure state (§4.7) |
| `structure_references` | as usual |
| `biomes` | `createBiomes` fills the chunk's biome palettes from the `FixedBiomeSource`: **every biome cell of every chunk is the settings' biome** (`getNoiseBiome(x, y, z)` returns the one holder for all inputs; `possibleBiomes` is that one biome). The climate sampler is not consulted |
| `terrain` | `FlatLevelSource.buildTerrain`: only the layer fill of §4.3. **No noise, no density functions, no aquifers, no surface rules, no carvers, no ore veins** run: in 26.3 those live in `NoiseBasedChunkGenerator.buildTerrain`, which the flat generator does not use (the base `ChunkGenerator` has no carver or surface hook, read: the stage calls only `buildTerrain`) |
| `features` | `ChunkGenerator.applyBiomeDecoration` (the same driver, with the flat generation settings of §4.5). It always runs; `features` false only empties the biome's part of the list |
| `initialize_light`, `light` | as usual |
| `spawn` | `ChunkGenerator.spawnOriginalMobs`, which `FlatLevelSource` overrides with an **empty** method: no animals or other mobs are created during chunk generation |
| `full` | as usual |

So a freshly generated flat chunk holds only the layer blocks, the structure pieces of the chunk's structures, and whatever the
decoration step puts there.

### 4.3 The terrain fill (`buildTerrain`)

Inputs: the chunk (min y `chunk.getMinY()`, height `chunk.getHeight()`), the expanded layer list `L` of §2.4 (with its null
entries).

1. For `i = 0` up to `min(chunk height, L.size) - 1`: let `s = L[i]`; if `s` is null skip; `y = chunk.minY + i`; for every column of the
   chunk (x 0..15 outer, z 0..15 inner) write `s` at `(x, y, z)` in the chunk (`ChunkAccess.setBlockState`), and call
   `Heightmap.update(x, y, z, s)` on the **`OCEAN_FLOOR_WG`** and **`WORLD_SURFACE_WG`** heightmaps (created unprimed here).
2. Return the chunk.

Rules and edge cases:

- Layer 0 is at the chunk's minimum y (the level's `min_y`, -64 in the overworld), regardless of `getMinY()` = 0 of §4.1. Nothing is
  written below layer 0 (the dimension has no floor: all cells below the first layer do not exist, there is no void gap) and
  nothing above the last layer (air, the chunk's initial content).
- A total height above the dimension height is **cut**: only the lowest 384 layers are written in the overworld. The settings
  codec still allows 4064 (§2.1).
- `terrain` only writes the two worldgen heightmaps. The four final heightmaps are built by the usual priming (35-1 section 4.2,
  "Heightmaps maintained on a chunk once it has passed `terrain`"), from the blocks present.
- Block writes use the plain chunk setter: no neighbour updates, no light update, no block entity creation.

### 4.4 Non-solid layers: `fill_layer` (closes 35-5 Open question 6)

For each expanded-list index `i` that was nulled (§2.4) the generator adds, to the generation settings' step
`TOP_LAYER_MODIFICATION` (step 10), one inline placed feature with **no placement modifiers**: `FillLayerFeature(i, state)`
(the feature of 35-5 section 11, `fill_layer`: for all 256 columns of the decorated chunk, if the block at
`(x, minY + i, z)` is air, write `state` with flag 2). So the answer to the 35-5 question is: flat worlds use that feature, and
only for layers whose state is not motion-blocking (snow layers, flowers, air, carpets, and so on). They are appended **after**
the biome's own features of step 10 (for the presets: after `freeze_top_layer` or `void_start_platform`), in increasing layer index
order (the order inside the step is inferred: the per-step list is built biome features first, then the fill features, and the
feature sorter keeps a single biome's order, Open question 15).

Because the fill runs in the `features` stage, `OCEAN_FLOOR_WG`/`WORLD_SURFACE_WG` and the first `terrain` fill do not see these
blocks, and `FlatLevelSource.getBaseHeight` skips them (§4.6); the final heightmaps see them (35-1 section 4.2 update rule).
An air layer is also nulled and gets a fill feature that changes nothing.

### 4.5 The generation settings of the biome: what `features` and `lakes` do

`FlatLevelSource` passes `FlatLevelGeneratorSettings.adjustGenerationSettings` (memoized per biome) as the generator's
`generationSettingsGetter`. For the settings' own biome `B` (for any other biome the unchanged settings of that biome are
returned; no other biome occurs with the fixed source) it builds a new generation-settings object with **no carvers**, whose
step lists are:

1. If `lakes` is true: step `LAKES` (1) first receives `lake_lava_underground`, then `lake_lava_surface` (placed features
   `MiscOverworldPlacements.LAKE_LAVA_UNDERGROUND` and `LAKE_LAVA_SURFACE`, looked up in the registry).
2. Let `gate = features && (not voidGen || B is minecraft:the_void)`. If `gate`, copy the biome's own lists step by step (same
   order inside each step) for **every step except**: `UNDERGROUND_STRUCTURES` (3) and `SURFACE_STRUCTURES` (4) (never copied), and
   `LAKES` (1) when `lakes` is true (replaced by step 1 above). When `gate` is false none of the biome's features is copied.
3. For every nulled layer, the fill feature of §4.4.

Observations:

- `features` false and `lakes` true gives only the two lava lakes plus the fill features; `features` true and `lakes` false keeps the
  biome's own lake step (which for the overworld biomes of the presets is the same two lava lakes, read in `plains`, `desert`,
  `windswept_hills`).
- Steps 3 and 4 hold the biome's *non-structure* features in those steps (for example `monster_room`, `monster_room_deep`, and for
  `desert` also `fossil_upper`, `fossil_lower` and `desert_well`; read). They are dropped in flat worlds, but **structures** are
  still placed at their own step by the driver (§4.7), because the driver walks the structure list of each step independently of
  the biome features.
- With a void-like stack (all air) and a biome other than `the_void`, `features` has no effect on the biome part; `the_void` is
  the one biome allowed to run its features over an all-air stack (this is how `void_start_platform` runs, 35-7 section 10).
- Decoration seeds are per `(chunk, step, feature index)` (11 section 6.1) and the index is the position in the **flat generator's
  own** per-step list, so a flat world with `features` does not place trees, ores or flowers where the standard world of the same
  seed and biome would.
- Biome feature counts per step for the biomes of the presets (read from the biome files; 11 steps, index 0 to 10):
  `plains` [0, 2, 1, 2, 0, 0, 29, 0, 2, 11, 1], `desert` [0, 2, 1, 4, 1, 0, 29, 0, 2, 10, 1], `windswept_hills`
  [0, 2, 1, 2, 0, 0, 30, 1, 2, 10, 1], `the_void` [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1] (the single feature of step 10 is
  `void_start_platform`). The names are in the biome files; the ores of step 6 and the vegetation of step 9 are specified in
  35-1 to 35-7.
- With `features` true the biome's ores and other height-ranged features resolve their `VerticalAnchor`s with the §4.1 numbers
  (minGenY 0, depth 384, sea level -63). For example the `desert` preset has only 3 stone blocks (y -63 to -61), so any ore whose
  placement needs stone at other heights simply finds none; this is a consequence of the read anchor rule and the layer stacks,
  not a separate rule, and the individual ore ranges were not evaluated (Open question 11).

### 4.6 Height queries

All are on `FlatLevelSource`, using the expanded list `L` (with nulls) and a `LevelHeightAccessor` `h` (the level):

| Query | Result |
|---|---|
| `getBaseHeight(x, z, type, h, randomState)` | `i = min(L.size - 1, h.getMaxY())`; scan `i` down to 0: skip null entries; the first entry whose state satisfies `type`'s heightmap test (`Heightmap$Types.isOpaque`, 35-1 section 4.2) gives `h.getMinY() + i + 1`; if none, `h.getMinY()`. The result does not depend on `x`, `z`. (Quirk, read: the start index is capped by `getMaxY()` (319 for the overworld), not by the number of slots 384, so layers above index 319 are ignored by this query; with total height <= 320 there is no effect) |
| `getFirstFreeHeight` | the same value (`ChunkGenerator` calls `getBaseHeight`) |
| `getFirstOccupiedHeight` | `getBaseHeight - 1` |
| `getBaseColumn(x, z, h, randomState)` | a `NoiseColumn` starting at `h.getMinY()` with the first `h.getHeight()` entries of `L`, null replaced by air. Used for structure placement |
| `getSpawnHeight(h)` | `h.getMinY() + min(h.getHeight(), L.size)` (the first free `y` above a full stack from the bottom, counting nulls and air layers) |
| `addDebugScreenInfo` | adds nothing |

Because null layers are skipped, a top layer of snow makes `getBaseHeight(..., OCEAN_FLOOR_WG)` and `WORLD_SURFACE_WG` return the
height under the snow (the heightmaps of the chunk, built from real blocks later, will include it).

### 4.7 Structures

- `FlatLevelSource.createState` builds the structure state with the flat variant (36-1 section 4.1): the candidate sets are the sets
  named by `structure_overrides` when present, else **every** set of the registry; then only the sets that pass the biome test
  of §3.3 are kept. `concentricRingsSeed` is **0** (a normal generator uses the world seed), so the stronghold ring positions
  (36-1 section 4.6) are the same in every flat world regardless of the seed; `levelSeed` is still the world seed (read:
  `createForFlat` passes it as before, only the ring seed differs). The dimension origin (`dimension_origin` placement, spawn) is chunk (0, 0).
- Structure starts are created and referenced by the normal stages. Each start generates its pieces inside the chunk's
  decoration at the structure's own step; the structure code reads `getBaseHeight` and `getBaseColumn` of §4.6 and the sea level of
  §4.1. A structure that needs terrain above a minimum (for example the desert pyramid's "no start when the lowest corner is below
  sea level", 36-4) always passes in a flat world: the ground is above -63 (for the stacks of §3.2).
- The world option "Generate Structures" (`generate_structures` of `world_gen_settings.dat`) still gates all structure
  generation (the decoration driver checks `StructureManager.shouldGenerateStructures` before every structure step); the create-world
  switch is disabled in hardcore and debug worlds (inferred from the screen's conditions, Open question 12).
- Which structures exist for each preset: §3.3. The standard Superflat world (§2.6) therefore generates **villages and
  strongholds** only.

### 4.8 Spawn point

World spawn (33 section 6.2, with the flat-specific numbers):

1. Provisional spawn: `origin` is chunk (0, 0). `y = getSpawnHeight(level)` = `minY + min(384, total height)`; if that `y` is below `minY` (cannot
   happen for a non-negative total) the `WORLD_SURFACE` height is used. Provisional spawn = `(8, y, 8)` of chunk (0, 0). For the default
   stack: `-64 + 4 = -60`.
2. Spiral search over the 11 x 11 chunks around (0, 0), first chunk with a non-null column (columns x outer z inner from the
   chunk minimum): `getLevelRespawnPos(x, z)` uses (overworld, no ceiling) the `MOTION_BLOCKING` height as `topY`; rejects a column
   whose `WORLD_SURFACE` height is <= `topY` and above its `OCEAN_FLOOR` height (a water-covered column); then scans `y` from
   `topY + 1` down to the level's `minY`, rejecting on any fluid and returning `(x, y + 1, z)` at the first block with a full upper
   collision face.
3. The first hit becomes the world spawn (yaw, pitch 0); if none is found the provisional spawn stays.

Flat specifics:

- A normal ground stack is found at column (0, 0) of chunk (0, 0): the world spawn is `(0, topY, 0)` with `topY` = the first free y
  above the surface (default stack: `(0, -60, 0)`; 33 section 6.4 then places the joining player at a random free column within
  `respawn_radius` of it).
- A stack whose top is water (Water World) has every column rejected (surface above floor): the provisional spawn
  `(8, 106, 8)` (the top of the stack) stays and the player's search (33 section 6.4, step 5, `fixupSpawnHeight`) ends at the
  surface, standing on the water block's top (computed example in §7.4).
- An all-air stack finds no column in the first generation pass (the stack has nothing to stand on) except where a feature put a
  block there: with the `the_void` preset the start platform (35-7 section 10) lies in chunk (0, 0) and gives a spawn on it (computed
  example in §7.5).

### 4.9 Mobs

- **Spawn tables** are the biome's `minecraft:gameplay/natural_mob_spawns` attribute of the settings' biome, as in the standard world
  (`ChunkGenerator.getMobsAt` is not overridden: structure spawn overrides at the position first, then the attribute at the
  position; 44-2). A structure that exists in the flat world has its overrides (swamp hut witches, monument guardians, and so on).
- **No creatures at chunk generation**: `spawnOriginalMobs` is empty in the flat generator (§4.2), so the biome attribute
  `minecraft:gameplay/creature_world_gen_spawn_probability` (read: `snowy_plains` has 0.07) is never used in a flat world. Whether and
  how animals then appear through ongoing natural spawning is not traced here (see 18 and 44-2).
- The `the_void` biome has the empty list in every category (read), so no natural spawning at all happens in the Void preset.
- Nothing else in the mob or spawner code reads the flat flag: the only classes that mention it are in §5.1 (searched over all
  classes of the jar for `isFlat`).

---

## 5. The "is flat" flag, sea level and client effects

### 5.1 What sets the flag

`WorldDimensions.specialWorldProperty` looks at the **overworld** level stem only: debug generator gives `DEBUG`, flat generator
gives `FLAT`, anything else `NONE`. `PrimaryLevelData.isFlatWorld()` is `specialWorldProperty == FLAT`; `ServerLevel.isFlat()` asks the
server's world data. It is therefore one value for the whole world (the same in the Nether and the End), true exactly when the
overworld uses `minecraft:flat`, including `flat_all_dimensions`. It is derived each time the world is loaded; nothing stores it
(§2.5).

Consumers (the complete list, from a search of all classes of the jar for `isFlat`): `ServerPlayer.createCommonSpawnInfo`
(the wire flag), `ClientPacketListener` (two places: handling the Login and the Respawn packets, which build the client level
data with it) and `ClientLevel$ClientLevelData` (the two effects of §5.3). No server gameplay code reads it.

### 5.2 The wire field

`CommonPlayerSpawnInfo` carries `Is flat` (a Boolean) in the Login and Respawn packets (05b, "Is flat"; the field order is in
05b). The server fills it from `ServerLevel.isFlat()` (§5.1) and the same record carries the **sea level** (VarInt) from
`ServerLevel.getSeaLevel()`, which for a flat world is **-63** (§4.1); a negative VarInt is five bytes (00). The Respawn packet carries
the flag of the destination level, which is the same value in every dimension of the world.

### 5.3 Client effects

The client level data answers two questions with the flag (`ClientLevelData`):

| Question | Flat | Not flat | Reader |
|---|---|---|---|
| `getHorizonHeight(h)` | `h.getMinY()` (-64 for the overworld type) as a double | 63.0 | `SkyRenderer.shouldRenderDarkDisc`: the dark disc ("void horizon", 12 section 3.4d) is drawn when `eyeY - horizonHeight < 0` and the player is not under water |
| `voidDarknessOnsetRange()` | 1.0 | 32.0 | `FogRenderer`: `v = clamp((onset + minY - cameraY) / onset, 0, 1)` (12 section 3.3 item 2, formula confirmed here: `minY` is `ClientLevel.getMinY`, `cameraY` the camera position's y); the fog colour is multiplied by `(1 - v)^2` unless the camera is in lava or powder snow, and an environment can modify `v` first |

Nothing else differs: the cloud renderer, the sky and the fog distances do not read the flag (the two classes above are the only
readers of those two methods). Cloud height and fog distances come from the dimension type's attributes (12 section 3.1, 3.6).
Examples (computed, onset and horizon as read):

- Superflat default, player standing on the grass at `y = -60`, eye `y` about -58.4: `eyeY - (-64) = 5.6 > 0` so **no dark disc**;
  `v = clamp((1 - 64 + 58.4) / 1) = 0`: no darkening. In a normal overworld the dark disc test is `eyeY - 63 < 0`, true under the
  surface; here it is true only below `y = -64`.
- In a flat world the void darkness starts only when the camera is below `y = -63` (`v` at -63.5 is 0.5, at -64 or lower 1): a player
  in the bedrock layer sees almost full darkness, and a player who digs out of the bottom sees the world go black within one block.
  In a non-flat overworld `v` starts at `y = -32` and reaches 1 at -64.

### 5.4 Dimension limits, border, height

The flat generator does not choose a dimension type: the world preset names it (`flat`: `minecraft:overworld`, §2.7). So an
ordinary flat world has `min_y` -64, `height` 384, `logical_height` 384, `has_ceiling` false, `has_skylight` true (read in
`dimension_type/overworld.json`); the world border, time, weather, sleeping and game rules are exactly the standard ones (33, 07).
The only vertical oddities are the generator limits of §4.1 (minGenY 0, sea level -63) and that the layers start at the dimension's
`min_y` (§4.3).

---

## 6. The create-world UI

Sizes in this section are the integer constants read in the constructors; they are given where a client implementation needs them.
`CommonComponents` texts: Done = "Done", Cancel = "Cancel" (`gui.done`, `gui.cancel`; the standard texts of 50/other screens).

### 6.1 World tab: the world type button and Customize

The tab "World" (`createWorld.tab.world.title`) of the create-world screen (the other tabs are "Game" and "More") contains, in a
two-column grid (column spacing 10, row spacing 8):

1. A cycle button 150 x 20, label `selectWorld.mapType` ("World Type"), values = the world types of the list below. Its list is
   `getNormalPresetList()` (members of the world preset tag `normal`, in tag order); while the alternate key of the cycle button is
   held (`CycleButton.DEFAULT_ALT_LIST_SELECTOR`) it cycles through `getAltPresetList()` (the `extended` tag). The text of a value
   is the translation of `generator.<namespace>.<path>` of the world preset id; a world whose settings match no preset is shown as
   `generator.custom` ("Custom"). The button is enabled only when the current type has a preset holder (a custom world cannot be
   cycled; inferred from `lambda$new$1`). Value order and texts:

   | # | World preset id | Key | English |
   |---|---|---|---|
   | 1 | `normal` | `generator.minecraft.normal` | Default |
   | 2 | `flat` | `generator.minecraft.flat` | Superflat |
   | 3 | `large_biomes` | `generator.minecraft.large_biomes` | Large Biomes |
   | 4 | `amplified` | `generator.minecraft.amplified` | AMPLIFIED |
   | 5 | `single_biome_surface` | `generator.minecraft.single_biome_surface` | Single Biome |
   | 6 (alt list only) | `debug_all_block_states` | `generator.minecraft.debug_all_block_states` | Debug Mode |

   (The first line "World Type" and the value are shown by the button as label and value; the exact joining format is the
   standard cycle-button one, not re-read.) Choosing a type calls `setWorldType`, which stores the entry and, when it has a preset holder, calls `updateDimensions` with an updater. The updater ignores its input and returns the preset's `createWorldDimensions()`, a full replacement of the world's **dimensions**, as read. For `flat` the result is the §2.6 overworld with the standard Nether and End (§2.7).
2. The **Customize** button (`selectWorld.customizeType` = "Customize"), beside it. Enabled when the world is not a debug world
   **and** a preset editor exists for the selected world type: editors exist for `flat` (the flat editor of §6.2) and
   `single_biome_surface` only. Clicking opens the editor screen for the current world creation context.
3. Seed edit box (308 x 20, label `selectWorld.enterSeed` = "Seed for the world generator", empty-hint `selectWorld.seedInfo`), then the switches "Generate Structures" (`selectWorld.mapFeatures` "Generate Structures", info
   `selectWorld.mapFeatures.info` "Villages, Shipwrecks, etc.") and "Bonus Chest" (`selectWorld.bonusItems`). The bonus chest switch is
   inactive in hardcore and debug worlds; the structure switch inactive in debug worlds (assigned from the two read conditions;
   which is which is inferred).

For the Customize button on the flat type the editor starts from the **current overworld generator's settings** if that generator is
the flat generator, else from `getDefault` (§2.6).

The initial world creation options (`InitialWorldCreationOptions`) can carry a flat preset key; if one is given the screen selects
the flat world type with that preset's settings at start (used by internal entry points; none of the jar's nine presets is wired to
the plain "Create New World" path; Open question 2).

### 6.2 The flat editor screen (`CreateFlatWorldScreen`)

Title `createWorld.customize.flat.title` = "Superflat Customization". Layout: header 33 high, footer 64 high; the body is a list
(`DetailsList`, an object selection list, row height 24, list top 43 below the screen top, height `screenHeight - 103`).

- **Header row** (first row of the list, height `int(9 * 1.5)` = 13, not selectable): two underlined texts, `createWorld.customize.flat.tile` =
  "Layer Material" at the left edge and `createWorld.customize.flat.height` = "Height" right-aligned at the right edge.
- **One row per layer, listed top layer first** (the settings' layer list reversed). A row shows the layer's slot (an 18 x 18
  `container/slot` sprite at the content origin + (1, 1)) with the item of the layer's block drawn at +(2, 2) of it (the block's
  item; for a block without an item, water shows a **water bucket** and lava a **lava bucket**; anything else shows an empty slot),
  then the item's name at content x + 18 + 5, vertically centred, and the height text right-aligned. The height text is a
  translation with the layer height as its argument: the **first** row (top layer) uses `createWorld.customize.flat.layer.top`
  ("Top - %s"), the **last** row (bottom layer) `createWorld.customize.flat.layer.bottom` ("Bottom - %s"), every row between
  `createWorld.customize.flat.layer` ("%s"); with a single layer the row is "Top - n". Clicking a row selects it (the narration is
  "<item> Height <n>").
- **Footer buttons**, four, in two rows of two (first row Remove Layer and Presets, second row Done and Cancel; inferred from the
  layout nesting): `createWorld.customize.flat.removeLayer` = "Remove Layer" (enabled only while a layer row is selected; removes the
  selected layer from the settings' layer list, then selects the row at the same position or the last one, or none when no layer is
  left, and rebuilds the expanded list); `createWorld.customize.presets` = "Presets" (opens §6.3); `gui.done` "Done"; `gui.cancel`
  "Cancel".
- **Done** hands the settings to the world creation (`FlatWorldConfigurator`): the new world dimensions are the **current ones with
  only the overworld generator replaced by a new flat generator** with these settings (`replaceOverworldGenerator`; the Nether and the End
  are untouched), then the screen closes to the create-world screen. **Cancel** just closes it. The editor works on the settings
  object it was given (no copy is made in the constructor), so a layer removed before Cancel stays removed in that object (inferred,
  Open question 8). The type stays "Superflat" after Done: read, `WorldCreationUiState.updateDimensions` only applies the updater to the context's selected dimensions and calls `onChanged`; it does not assign the world type (only `setWorldType` and the preset-list refresh do).

**There is no way to add a layer in this screen, no biome selector, no structure toggles, no lakes or features switches and no
height editor** (the screen's widgets are exactly the list and the four buttons; searched in all five classes and in the language file
for `addLayer`, `biome`, `structure`). Layers, biome and everything else come from presets or from the preset text of §6.3. The flags
`lakes`, `features` and the `structure_overrides` can only be changed by choosing a preset (their values come with it, §6.4) or by
a data pack, the server property or a saved file (§2).

### 6.3 The preset screen (`PresetFlatWorldScreen`)

Title `createWorld.customize.presets.title` = "Select a Preset". Opened from the editor; returns to the editor on Cancel or on Use Preset.

- A text box (x 50, y 40, width `screenWidth - 100`, height 20, max length 1230) holding the **preset text** of §6.4; initial value
  is the text of the editor's current settings. Above it, at (51, 30) in grey (colour `-6250336`, i.e. `0xFFA0A0A0`), the text
  `createWorld.customize.presets.share` = "Want to share your preset with someone? Use the box below!".
- Above the list, at (51, 68) in the same grey, `createWorld.customize.presets.list` = "Alternatively, here are some we made earlier!".
- The list: members of the tag `visible` in tag order (§3.1), each row = the preset's `display` item in an 18 x 18 slot (item at +2, +2) and
  the preset name at content x + 18 + 5, y + 6; the name is the translation of `flat_world_preset.<namespace>.<path>` of the preset key
  (§6.5), or `flat_world_preset.unknown` ("???") for an unnamed one. List top 80, height `screenHeight - 117`, row height 24.
  Clicking a row (or pressing the select key on it) **selects** it: the working settings become the preset's settings and the text box
  is set to their preset text (cursor to the start); nothing is applied yet.
- Buttons at the bottom (y = `screenHeight - 28`, 150 x 20): "Use Preset" (`createWorld.customize.presets.select`) at
  x = `width / 2 - 155`, and Cancel at `width / 2 + 5`. "Use Preset" is enabled when a row is selected **or** the text box holds
  more than one character.
- **Use Preset**: parse the text box with §6.4 (using the working settings as the base for the flags and overrides), hand the result to
  the editor (`setConfig`: the editor's list rebuilds and its remove button revalidates) and return to the editor. The world is
  not changed until the editor's Done.

### 6.4 The preset text (share string) and its parser

Written by `save(settings)`: the layers in list order (bottom first) joined by `,`, each as `N*<block id>` or, when the height is 1, just
`<block id>` (the block's registered name with namespace); then `;`; then the biome id. Example for the §2.6 default:
`minecraft:bedrock,2*minecraft:dirt,minecraft:grass_block;minecraft:plains`.

Read by `fromString` (the working settings supply the flags and overrides; `getDefault` of §2.6 is the fallback):

1. Split the text at `;`. The first part is the layer list; **only one further part is read**, the biome (any more are ignored).
2. Split the first part at `,` (a plain string split on the comma). For each piece, in order, with `consumed` = the sum of the heights
   of the pieces already accepted, each counted **as clamped by the piece parser** (below):
   - A piece is `N*name` (split at the **first** `*`; two parts: `N` is parsed as an integer and clamped to at least 0; a non-number
     makes the whole text unusable) or `name` (height 1). A third `*` stays in `name` and then fails the block lookup.
   - `name` is parsed as an identifier and looked up in the block registry; an unknown block makes the whole text unusable
     (logged `Error while parsing flat world string => Unknown block, {}`); a missing namespace is read as `minecraft` (inferred
     from the identifier parser, Open question 5).
   - The piece parser itself clamps the height to `min(consumed + N, 4064) - consumed` (a piece may therefore come out with height
     0 or less than `N`); `consumed` then grows by that clamped height. The list builder then computes the room `4064 - consumed`
     (taken before the piece is added); when it is not positive the piece is dropped, otherwise the layer is added with its height
     limited to the room (`heightLimited`, a second clamp that is a no-op after the first). Net effect: no accepted layer pushes
     the total above 4064.
3. When the layer list is empty (including an unusable text, or an empty box) the result is `getDefault` of §2.6. Otherwise the biome is
   the second part parsed as an identifier and looked up in the biome registry; if it fails or is missing the biome is
   `minecraft:plains` (a failed lookup logs `Invalid biome: {}`).
4. The result is the working settings' `withBiomeAndLayers(layers, working.structureOverrides, biome)`: so `lakes`, `features` and the
   structure overrides are those of the **working settings** (the editor's current settings, or the preset just selected), not
   something the text can express.

Examples (computed from the rules): `3*minecraft:stone,minecraft:grass_block;minecraft:desert` gives stone 3, grass_block 1, biome
`desert`; `4000*stone,100*dirt` gives stone 4000 and dirt **64** (limited to the remaining room of 4064); `5000*stone` gives stone
4064; `0*minecraft:stone` gives one layer of height 0; `minecraft:stone,minecraft:nope` is unusable and yields the default.

### 6.5 Message keys and English texts (read from `en_us.json`)

| Key | English |
|---|---|
| `createWorld.customize.flat.title` | Superflat Customization |
| `createWorld.customize.flat.tile` | Layer Material |
| `createWorld.customize.flat.height` | Height |
| `createWorld.customize.flat.layer` | `%s` |
| `createWorld.customize.flat.layer.top` | Top - `%s` |
| `createWorld.customize.flat.layer.bottom` | Bottom - `%s` |
| `createWorld.customize.flat.removeLayer` | Remove Layer |
| `createWorld.customize.presets` | Presets |
| `createWorld.customize.presets.title` | Select a Preset |
| `createWorld.customize.presets.share` | Want to share your preset with someone? Use the box below! |
| `createWorld.customize.presets.list` | Alternatively, here are some we made earlier! |
| `createWorld.customize.presets.select` | Use Preset |
| `flat_world_preset.minecraft.classic_flat` | Classic Flat |
| `flat_world_preset.minecraft.tunnelers_dream` | Tunnelers' Dream (the apostrophe is the plain ASCII one) |
| `flat_world_preset.minecraft.water_world` | Water World |
| `flat_world_preset.minecraft.overworld` | Overworld |
| `flat_world_preset.minecraft.snowy_kingdom` | Snowy Kingdom |
| `flat_world_preset.minecraft.bottomless_pit` | Bottomless Pit |
| `flat_world_preset.minecraft.desert` | Desert |
| `flat_world_preset.minecraft.redstone_ready` | Redstone Ready |
| `flat_world_preset.minecraft.the_void` | The Void |
| `flat_world_preset.unknown` | ??? |
| `generator.minecraft.flat` | Superflat |
| `generator.minecraft.flat_all_dimensions` | Flat All Dimensions |
| `generator.minecraft.normal` | Default |
| `generator.minecraft.large_biomes` | Large Biomes |
| `generator.minecraft.amplified` | AMPLIFIED |
| `generator.minecraft.amplified.info` | Notice: Just for fun! Requires a beefy computer. (shown on the World tab as the tooltip of the World Type button while the AMPLIFIED type is selected, read; not shown for Superflat) |
| `generator.minecraft.single_biome_surface` | Single Biome |
| `generator.minecraft.debug_all_block_states` | Debug Mode |
| `generator.custom` | Custom |
| `generator.customized` | Old Customized |
| `generator.single_biome_caves` / `generator.single_biome_floating_islands` | Caves / Floating Islands (not world types in the list) |
| `selectWorld.mapType` | World Type |
| `selectWorld.mapType.normal` | Normal (present in `en_us.json`; **no class of the jar references it**, searched over all classes, so the artifact does not use it; the Default type uses `generator.minecraft.normal`) |
| `selectWorld.enterSeed` | Seed for the world generator (label of the seed box) |
| `createWorld.tab.world.title` / `createWorld.tab.game.title` / `createWorld.tab.more.title` | World / Game / More |
| `selectWorld.customizeType` | Customize |
| `selectWorld.mapFeatures` / `.info` | Generate Structures / Villages, Shipwrecks, etc. |
| `selectWorld.bonusItems` | Bonus Chest |
| `selectWorld.seedInfo` | Leave blank for a random seed |

(Also read: the `createWorld.customize.buffet.*` keys belong to the Single Biome editor, not to the flat editor.)

### 6.6 What a minimal implementation needs, and what the full editor adds

- **Minimal (preset choice):** a world type value "Superflat" whose settings are §2.6; the nine presets of §3.2 selectable by name and icon
  in the order of §3.1; the settings stored as §2.5; the flag and sea level of §5; the generator of §4. The Customize path can be
  reduced to the preset list plus the preset text box of §6.3 (which also gives arbitrary layer stacks).
- **Full editor:** the layer list (reversed, with the Top/Bottom texts and item icons), Remove Layer, the preset screen with the text box and
  parser of §6.4, Done replacing only the overworld generator, Cancel. In 26.3 the artifact has nothing more (§6.2); a CobolCraft
  extension (layer adder, biome and structure toggles) would be an addition, not vanilla behaviour.

---

## 7. Worked examples

Layer indices are relative to the level's `min_y` -64. "air" above the top block up to y = 319. Heightmap value = top block y + 1
(35-1 section 4.2). All values (computed) from the rules above.

### 7.1 Default superflat (§2.6): bedrock 1, dirt 2, grass_block 1

| y | Block |
|---|---|
| 319 .. -60 | air |
| -61 | grass_block |
| -62, -63 | dirt |
| -64 | bedrock |

Total 4. `getSpawnHeight` = -64 + min(384, 4) = **-60**; `getBaseHeight` for `OCEAN_FLOOR_WG`, `WORLD_SURFACE_WG`, `MOTION_BLOCKING`: **-60**
(index 3, `-64 + 3 + 1`); `getFirstOccupiedHeight` -61. Biome plains in all 4 x 4 x 4 cells. World spawn: provisional `(8, -60, 8)`; the search accepts
column (0, 0) of chunk (0, 0): `topY` -60, surface -60 = floor -60 (not water-covered), scan from y -59: -59 and -60 are air, -61
is grass with a full top face: spawn `(0, -60, 0)`. Structures: strongholds and villages (§3.3). Biome features: none (`features`
false). Preset text: `minecraft:bedrock,2*minecraft:dirt,minecraft:grass_block;minecraft:plains`.

### 7.2 Classic Tunnelers' Dream: bedrock 1, stone 230, dirt 5, grass_block 1 (biome `windswept_hills`, features true)

| y | Block |
|---|---|
| 319 .. 173 | air |
| 172 | grass_block |
| 171 .. 167 | dirt |
| 166 .. -63 | stone (230 blocks) |
| -64 | bedrock |

Total 237; `getSpawnHeight` = `-64 + 237` = **173**; base height 173; world spawn column (0, 0) at `(0, 173, 0)`, player lands on the grass.
Decoration: step 6 ores and the rest of the `windswept_hills` list of §4.5 except steps 3 and 4 (so no monster rooms); mineshafts and
strongholds only (§3.3, no villages, no outposts). No caves, no ravines (no carvers). Anchors resolve with §4.1 (minGenY 0, sea level -63).

### 7.3 Redstone Ready and Overworld (layer arithmetic)

`redstone_ready`: bedrock -64, stone -63..-61, sandstone -60..55 (116 blocks), top block 55, total 120, spawn height 56, no structures, desert biome,
no features. `overworld`: bedrock -64, stone -63..-5 (59), dirt -4..-2, grass_block -1, total 64, spawn height 0, with features and lakes
(both flags) and the five structure sets of §3.2.

### 7.4 Water World: bedrock 1, deepslate 64, stone 5, dirt 5, gravel 5, water 90 (biome `deep_ocean`)

| y | Block |
|---|---|
| 319 .. 106 | air |
| 105 .. 16 | water (90 blocks) |
| 15 .. 11 | gravel |
| 10 .. 6 | dirt |
| 5 .. 1 | stone |
| 0 .. -63 | deepslate (64 blocks) |
| -64 | bedrock |

Total 170, water counts as motion-blocking (fluid) so it is written by the terrain fill (§2.4). Heightmaps: `OCEAN_FLOOR_WG` and `OCEAN_FLOOR`
**16**; `WORLD_SURFACE_WG` and `MOTION_BLOCKING` **106**. `getSpawnHeight` = **106**. Sea level stays -63. Spawn: every
column fails (`WORLD_SURFACE` 106 <= `topY` 106 and above `OCEAN_FLOOR` 16), so the world spawn stays the provisional `(8, 106, 8)`; the
joining player's search finds no dry column and `fixupSpawnHeight` leaves the box at y 106 (the box at 105 is water), so the player is placed at
`(8.5 + ..., 106, ...)` standing on the water surface (the horizontal part of that last step follows 33 section 6.4, unchanged).
Structures: ocean ruins, shipwrecks, monuments (§3.3); no features, no lakes.

### 7.5 The Void: air 1 (biome `the_void`, features true)

Terrain: the air layer is not motion-blocking, so its entry is nulled (a no-op fill feature is registered) and the terrain fill writes
nothing; heightmaps equal the minimum y -64. `voidGen` is true but the biome is `the_void`, so `gate` is true (§4.5) and the biome's single
feature, `void_start_platform`, runs in step 10 (35-7 section 10: the 33 x 33 platform of stone, a cobblestone block at
`(8, y, 8)`, `y = -61` for `origin.y` -64). Spawn height -64 + min(384, 1) = **-63**. With the platform in the generated chunk (0, 0) the spawn
search accepts column (0, 0) (platform stone at y -61, `topY` -60): world spawn `(0, -60, 0)` (the platform's feature writes update the final
heightmaps; this chain is inferred, Open question 9). No structures, no mobs (empty spawn lists), no lakes.

### 7.6 Sea level -63 and snow (computed)

Windswept hills `T0 = 0.2`. For `y > sea + 17 = -46` the temperature is `T0 - (N * 8 + y - (-46)) * 0.05 / 40` (33 section 4.5), with
`N = 0` for the example. At `y = 172` (Tunnelers' Dream surface) windswept hills gives `0.2 - 218 * 0.00125 = -0.0725`, below the 0.15
threshold: **snow** falls and `freeze_top_layer` places snow and ice there; the same biome in the standard world at `y = 172` is
`0.2 - (172 - 80) * 0.00125 = 0.085`, also snow. The difference shows at low altitude: at `y = -10` the flat world gives
`0.2 - 36 * 0.00125 = 0.155` (rain, just above 0.15), at `y = -5` `0.2 - 41 * 0.00125 = 0.149` (snow).

---

## Open questions

1. **Legacy flat string.** `LevelFlatGeneratorInfoFix` and `StructureSettingsFlattenFix` (data fixers for the pre-1.16 flat text
   `3;minecraft:bedrock,2*minecraft:dirt,...;1;village`) exist in the jar and were not read; this document covers only the current
   form (§2) and the editor's share text (§6.4).
2. **`test_world` and the initial-options preset.** `FlatLevelGeneratorPresets` declares a `test_world` key with no element in the
   jar and `InitialWorldCreationOptions` carries an optional flat preset key; which entry point sets it, and what `test_world` would
   contain, was not traced (it presumably belongs to the game-test world, 55).
3. **List order.** That the preset screen lists in the tag file's order is inferred (it iterates `Registry.getTagOrEmpty(visible)`; the
   tag's element order was not read).
4. **`structure_overrides` forms.** Reading a `#tag` and writing a one-element set (bare string vs list) in NBT are inferred from the
   codec helper names and from the JSON data files; the helper's code was not read.
5. **Identifier default namespace.** That a block or biome name without namespace in the preset text resolves to `minecraft` is inferred
   from the use of `Identifier.parse` / `tryParse` (the rule itself was not re-read here).
6. **Unknown block ids.** The layer codec uses the block registry's holder-by-name codec; whether an unknown block id fails the decode or
   resolves to the registry default (`air`) was not traced (`DefaultedMappedRegistry.getValue` falls back to the default but the
   holder lookup path was not shown to use it).
7. **When the nulls appear.** The nulling of non-solid layers happens in `adjustGenerationSettings`; that it has run before the first
   `buildTerrain` (so the terrain fill already skips them) rests on `ChunkGenerator.validate` forcing the per-step feature table; the call
   of `validate` was not located. If it ran later, a snow layer would first be written by the terrain fill and again by the fill feature,
   with the same result except that the worldgen heightmaps would include the layer.
8. **Editor aliasing.** That the flat editor mutates the settings object it was given and does not undo on Cancel is read from the missing copy;
   whether the settings object is shared with the pending world's generator was not traced.
9. **Void preset spawn.** The spawn at `(0, -60, 0)` is a composition of read rules (platform in chunk (0, 0) before the spawn search, final
   heightmaps updated by feature writes); not otherwise confirmed.
10. **Other consumers of sea level -63.** The effects listed (§4.1, §5.2, temperature) are the ones traced; the other readers of `getSeaLevel`
    (40 classes mention it) were not each checked, for example turtle spawning (19) and the phantom rules (20).
11. **Feature index, counts and anchors.** The exact per-step feature index lists of the flat generator for each preset's biome (needed to
    reproduce the decoration seeds of 11 section 6.1) were not enumerated; only the step counts (§4.5) were read. Which biome features
    use `above_bottom`, `below_top` or `relative_to_sea_level` anchors (§4.1) and how that moves them in a flat world was not evaluated.
12. **Create-world switch conditions.** Which of the two read conditions (not debug; not hardcore and not debug) belongs to "Generate
    Structures" and which to "Bonus Chest" is inferred from their order of construction.
13. **Cycle button text format.** The joining of label and value in the World Type button ("World Type: Superflat") is the standard
    cycle-button form and was not re-read.
14. **Stability flag.** That a flat overworld (fixed biome source) is not flagged experimental when creating a world rests on
    `WorldDimensions.isStableOverworld` accepting any biome source that is not a multi-noise source; the lifecycle's effect on the
    creation screens was not traced.
15. **Order of fill features.** That the fill features follow the biome's step-10 features and keep their index order after the feature
    sorter is inferred from the builder order and the sorter's per-biome edge rule (not re-read).
16. **Structure generation in flat worlds.** The stronghold ring computation with seed 0 and the individual structure generators' use of
    `getBaseHeight` / `getBaseColumn` for flat terrain were not re-traced here; they follow 36-1 section 4.6 and the structure parts.
17. **Pixel layout.** Only the integer constants read from the screen constructors are given (§6.2, §6.3); the rest of the layout (fonts, row
    backgrounds, scroll bars) is the standard list widget of the game and is not specified here.
18. **Computed tables.** The structure-set survivors of §3.3 and all numbers marked "(computed)" in §3.2 and §7 were produced by a scratch script
    over the extracted JSON and by arithmetic, not by the artifact; the script was a throwaway and is not kept.
