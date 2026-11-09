# 36 Structures, part 2: structure templates (structure NBT), placement settings, and structure processors

| Item | Value |
|---|---|
| Covers | The structure template: its in-memory model and the structure NBT file schema (palettes, blocks, entities, size), how templates are found and loaded (`StructureTemplateManager` and the sources under `templatesystem.loader`), the coordinate transform (mirror, rotation, pivot, bounding box, zero position), `StructurePlaceSettings`, the placement algorithm `StructureTemplate.placeInWorld` (block order, block entities, loot seeds, liquid handling, shape updates, entities), `TemplateStructurePiece` (data markers and jigsaw markers), and every structure processor: the processor interface, lists and registries, `rule` with its rule tests, position tests and block entity modifiers, and the ten other processor types (`block_ignore`, `block_rot`, `protected_blocks`, `capped`, `gravity`, `jigsaw_replacement`, `lava_submerged_block`, `blackstone_replace`, `block_age`, `nop`). |
| Does not cover | Rows of data: the 1511 structure NBT files and the 40 processor-list elements are copied by the extraction tool (22, 23 section 2.1); this document gives their schema and the engine that interprets them. Jigsaw assembly (pool elements, `JigsawPlacement`, connection search) is 36-3; per-structure piece classes are later parts of 36. The structure block and jigsaw block entities (their keys, screens, packets) are 31-6 section 6 and section 8. Structure starts, structure sets, placement, the `StructurePiece` base and `BoundingBox` are 36-1. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.structure.templatesystem.*` (including `loader.*` and `rule.blockentity.*`), `...structure.TemplateStructurePiece`, `net.minecraft.world.level.block.entity.StructureBlockEntity` and `JigsawBlockEntity`, `net.minecraft.world.level.block.Rotation` and `Mirror`, `net.minecraft.util.Mth`, `net.minecraft.util.Util` (`toShuffledList`), `RandomSource`, `SingleThreadedRandomSource`, `LegacyRandomSource$LegacyPositionalRandomFactory`, `net.minecraft.world.phys.shapes.DiscreteVoxelShape`, `net.minecraft.core.AxisCycle`, `net.minecraft.nbt.NbtUtils`, `net.minecraft.core.registries.Registries`; static reading of the jar's data (`version.json`, every `data/minecraft/structure/**.nbt` file decompressed and scanned with a script, and every `data/minecraft/worldgen/processor_list/*.json`). No execution of the artifact. The worked examples in section 10 were computed by hand and by a small script that implements the formulas of this document; they were not run against the artifact. |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12b, R4, R7, R10). |
| Status | Written by the reader for round RS20, part 2. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. Facts are read from the artifact; where
recall suggested a value, the value was read before it was written. References use "10 section 2.6" for other documents, "36-1
section 6" for the sibling parts of this document, and "section 4" for this one. Coordinates are block coordinates; "template-local"
means the coordinates stored in the structure file (the template's own origin is its (0,0,0) block); "absolute" means world
coordinates.

---

## 0. Reader's map

| Topic | Section |
|---|---|
| What the template is, file schema, in-memory model, block order | 1 |
| Finding and loading templates, saving, the manager cache | 2 |
| Coordinate transform, bounding box, zero position, size | 3 |
| Placement settings | 4 |
| Placing a template into the world | 5 |
| `TemplateStructurePiece`, data markers, jigsaw replacement | 6 |
| Processor framework (interface, list, registries, codecs, pipeline) | 7 |
| The rule processor, rule tests, position tests, block entity modifiers | 8 |
| The other processors | 9 |
| What the shipped data uses | 10 |
| Worked examples | 11 |
| Validation | 12 |
| Open questions | 13 |

Names of random generators: "legacy source" means `LegacyRandomSource`, the `java.util.Random` linear congruential generator of 10
section 2.6 (`nextFloat`, `nextInt(bound)`, `nextLong` as defined there); `Mth.getSeed(x, y, z)` is defined in 10 section 2.4 and
section 2.6. Update-flag numbers (816, 820, 16 ...) are the bits of 29 section 1.

---

## 1. The structure template

### 1.1 In-memory model (`StructureTemplate`)

| Field | Meaning |
|---|---|
| `palettes` | list of palettes; each palette is one complete alternative version of the block list (section 1.3) |
| `entityInfoList` | list of entity records (section 1.4); shared by all palettes |
| `size` | `Vec3i`, the template's extent in blocks on x, y, z; default `(0,0,0)` |
| `author` | String, default `""` (not stored in the NBT file; set only by the structure block) |

A block record (`StructureBlockInfo`) is `(pos, state, nbt)`: a template-local position, a block state and an optional block entity
tag (`nbt` may be absent). A palette (`StructureTemplate$Palette`) holds the ordered list of block records plus two caches: blocks
filtered by one block type (`blocks(block)`), and the jigsaw records (`jigsaws()`, built once from the records whose block is
`minecraft:jigsaw`, each parsed by section 1.5). Records are immutable; processors build new ones.

### 1.2 The structure NBT file

Files are gzip-compressed NBT (`NbtIo.readCompressed` with an unlimited size accounter; the read for `.snbt` text files, used only by
development sources, parses SNBT text instead). The root compound has these keys (all read from `StructureTemplate.save/load`; every
shipped file was also checked, section 10.1):

| Key | Tag | Rule |
|---|---|---|
| `DataVersion` | Int | written by `save` (current data version); on load, a missing value counts as 500 and the file is run through the data fixer for type `STRUCTURE` up to the current version before parsing. All 1511 shipped files carry 5023, which is the `world_version` of this jar (`version.json`), so no upgrade ever applies to them. |
| `size` | List of 3 Int | x, y, z; on load each missing element reads as 0 (`getIntOr(i, 0)`) |
| `palette` | List of Compound | single-palette form: the block-state list (section 1.3); read when `palettes` is absent |
| `palettes` | List of (List of Compound) | multi-palette form; when present it is used and `palette` is ignored; each inner list is one palette's state list |
| `blocks` | List of Compound | block records (below); shared by all palettes: the record's `state` is an index into the state list of each palette |
| `entities` | List of Compound | entity records (section 1.4) |

A **block-state entry** is a Compound with `id` (String, a block identifier) and, optionally, `properties` (Compound of property name
to String value). Reading (`NbtUtils.readBlockState`): an `id` that is missing, malformed or not a registered block gives the default
state of `minecraft:air`; otherwise the block's default state, then each entry of `properties` is applied by name and value text;
a property name or value that does not parse is skipped (the default value stays). Writing (`writeBlockState`) emits `id` and then
the state's properties through `writeStateProperties` (not re-read here). The keys are `id` and `properties`: these are the keys the
shipped files use (section 10.1), and a file written with other key names would read every palette entry as air.

A **block record** (element of `blocks`) is a Compound: `pos` (List of 3 Int, template-local x, y, z, missing elements read 0), `state`
(Int, index into the palette's state list; an index with no mapping reads as the default state `minecraft:air`; missing reads 0), and
optional `nbt` (Compound, the block entity data, written by `BlockEntity.saveWithId`, so it contains the block entity type id).

`SimplePalette` (the state list while loading or saving) is an id mapper from state to index: `addMapping(state, index)` at load;
at save `idFor(state)` assigns indices 0, 1, 2 ... in order of first use and returns the existing index on repeats.

**Save** (`save(tag)`, used only by the structure block): an empty palette list gives empty `blocks` and `palette` lists. Otherwise,
for each palette in order, the blocks are written in that palette's order; the first palette's records define the `blocks` list
(`pos`, `state` index in the first palette's numbering, `nbt` if present); the other palettes only contribute their own state lists.
One palette: key `palette` holds its states. More than one: key `palettes` holds the list of lists. `entities` follows (section 1.4),
then `size`, then `DataVersion`. (The assumption behind multi-palette files is that every palette has the same blocks at the same
positions with different states; the loader does not check it, section 1.3.)

### 1.3 Palettes and block order

`load(tag)` clears palettes and entities, reads `size`, then reads `blocks` and `palettes` (when `palettes` is present: one palette
per inner list in order; otherwise one palette from `palette`). For each palette (`loadPalette(states, blocks)`): build the state
list; for each block record in file order build `(pos, states[state], nbt)` and put it in one of three groups:

| Group | Condition (tested in this order) |
|---|---|
| with block entity data | the record has `nbt` |
| full cubes | no `nbt`, the block does not have a dynamic shape, and the state's collision shape against an empty world at (0,0,0) is a full block |
| others | everything else |

Each group is sorted by `y` ascending, then `x` ascending, then `z` ascending (the three key extractors are, in order,
`lambda$buildInfoList$0` = y, `$1` = x, `$2` = z, checked in the bootstrap table). The palette's final list is the concatenation
**full cubes, then others, then records with block entity data**. This is the **placement order** of section 5. A template whose
palettes have different numbers of records is not rejected; each palette is simply processed as its own list, so a tool that builds
multi-palette files must keep the groups consistent only if it wants identical shapes between palettes.

`getRandomPalette(palettes, pos)` (`StructurePlaceSettings`, section 4) picks which palette a placement uses; with one palette it
always picks it. An empty list of palettes is an error when asked for a palette, so every caller first checks emptiness.

### 1.4 Entity records

An entity record (`StructureEntityInfo`) is `(pos, blockPos, nbt)`: `pos` a template-local `Vec3` (doubles), `blockPos` a
template-local `BlockPos`, `nbt` the entity's NBT compound (which contains its `id`).

File form (list `entities`, each a Compound): `pos` (List of 3 Double, missing elements read 0.0), `blockPos` (List of 3 Int,
missing read 0), `nbt` (Compound; an entity record with no `nbt` is **dropped** on load: the consumer only runs when the tag is
present). Save writes `pos`, `blockPos`, then `nbt` when present.

`fillFromWorld` (structure block save, 31-6 section 6.3) builds records: every entity in the box (`AABB.encapsulatingFullBlocks`
of the two corner positions) that is not a player is saved with the entity's own save routine (`Entity.save`; the entity `id` IS included: a shipped record, `village/desert/camel_spawn.nbt`, holds `nbt` with a string `id` = `minecraft:camel`, read from the data) and copied; `pos` is the entity position minus the box minimum corner;
`blockPos` is, for a painting, the painting's block position minus the minimum corner, otherwise `BlockPos.containing(pos)`
where `pos` is the already-relative vector.

### 1.5 Jigsaw records (`JigsawBlockInfo`)

`JigsawBlockInfo.parse(blockInfo)` requires the record's `nbt` (a missing tag is an error) and reads these keys, all with a
default when missing or invalid:

| Field | Key | Default |
|---|---|---|
| `jointType` | `joint` (String `rollable` or `aligned`, case as shown) | `aligned` when the block's front direction (`JigsawBlock.getFrontFacing(state)`) is horizontal, otherwise `rollable` |
| `name` | `name` (identifier) | `minecraft:empty` |
| `pool` | `pool` (resource key of a template pool) | the key `minecraft:empty` |
| `target` | `target` (identifier) | `minecraft:empty` |
| `placementPriority` | `placement_priority` (Int) | 0 |
| `selectionPriority` | `selection_priority` (Int) | 0 |

The record also carries the block's `pos` and `state`. `withInfo(pos, state)` returns a copy with the position and state replaced
(used when the record is transformed into world orientation, section 3.5). The jigsaw block entity (31-6 section 8) writes the same
keys plus `final_state` (String block-state text, default `minecraft:air`); `final_state` is not part of `JigsawBlockInfo`; it is read
when the marker is replaced (section 6.3 and processor `jigsaw_replacement`, section 9.6).

---

## 2. Finding, loading, saving: `StructureTemplateManager` and the sources

### 2.1 Identifiers and paths

A template id is an identifier `namespace:path`. The file for an id is found with a "file to id converter" with prefix `structure` and
extension `.nbt` (binary) or `.snbt` (text): id `minecraft:igloo/top` maps to the resource `minecraft:structure/igloo/top.nbt`, that is
`data/minecraft/structure/igloo/top.nbt` in a data pack (the four converters are `WORLD_STRUCTURE_LISTER` (`.nbt`),
`WORLD_TEXT_STRUCTURE_LISTER` (`.snbt`), `RESOURCE_STRUCTURE_LISTER` (`.nbt`), `RESOURCE_TEXT_STRUCTURE_LISTER` (`.snbt`), all prefix
`structure`). The conversion from file to id removes the prefix and the extension, and lists only files with the right extension.

### 2.2 Sources (`TemplateSource` and subclasses)

A source answers `load(id)` (an optional template) and `list()` (the ids it can supply). The base class holds a data fixer and the
block holder lookup, and implements the shared reading: open the stream (a missing file is a normal "not found", every other failure
is passed to the source's error handler and gives "not found"), read either gzip NBT or SNBT, take `DataVersion` (default 500), run
the data fixer for `STRUCTURE` to the current version, then `StructureTemplate.load(blockLookup, tag)`.

| Source | Reads from | Notes |
|---|---|---|
| `DirectoryTemplateSource` | a directory on disk: `<dir>/<namespace>/structure/<path>.nbt` (or `.snbt` when constructed with the text flag); when the directory does not exist, nothing is found and `list()` is empty | `list()` enumerates every namespace folder under the directory and keeps files with the right extension. Errors are logged as "Couldn't load structure from {dir}:{id}". |
| `ResourceManagerTemplateSource` | the resource manager (the loaded data packs): `open(idToFile(id))` | `list()` is all resources matching the converter. Replaced on reload (`setResourceManager`). Errors logged as "Couldn't load structure {id}". |

`TemplatePathFactory(dir[, packType])` builds a file path for an id: `<dir>[/<pack type directory>]/<namespace>/<file path of the id>`; the
id path is decomposed into segments (`FileUtil.decomposePath`) and every segment must be a valid path segment (not `.` or `..`,
and matching the strict path segment character check); otherwise the call throws an identifier error. It is used for saving.

### 2.3 The manager (`StructureTemplateManager`)

Construction takes the resource manager, the level storage access, the data fixer and the block holder lookup. It creates:

1. the resource-manager source (converter `.nbt`);
2. `worldTemplates`: a path factory over `<level directory>/generated` (the `GENERATED_DIR` level resource, the string `generated`);
3. optionally a `testTemplates` path factory (built only when `StructureUtils.testStructuresTargetDir` is configured; a separate item,
   not a source, and not used by the game);
4. the **source list**, in this order: (a) a `DirectoryTemplateSource` over `<level>/generated` with converter `.nbt` and text flag
   false; (b) at most ONE test-only directory source, built only when `StructureUtils.testStructuresSourceDir` is configured (converter
   `.snbt`, text flag true; not used in normal play); (c) the resource-manager source.

Operations:

| Operation | Behaviour |
|---|---|
| `get(id)` | `structureRepository` is a concurrent map from id to an optional template; `computeIfAbsent(id, tryLoad)`. The result, including "absent", is cached. |
| `tryLoad(id)` | go through the source list in order; the first source that returns a template wins; an exception inside a source is swallowed and the next source is tried; when none supplies it, the result is absent. So a template saved in the world's `generated` folder overrides a data pack template of the same id. |
| `getOrCreate(id)` | `get(id)`; when absent, create an empty template, store it in the map as present, and return it (this is how a structure block creates a new template to fill). |
| `listTemplates()` | the distinct union of every source's `list()`. |
| `onResourceManagerReload` | point the resource source at the new manager and clear the whole map. |
| `remove(id)` | drop the map entry (the structure block's unload). |
| `save(id)` | no entry or an absent entry gives false. Otherwise the path is `worldTemplates` path for the id with the `.nbt` converter (or `.snbt` when the debug constant `DEBUG_SAVE_STRUCTURES_AS_SNBT` is set, normally false) and the static `save(path, template, asText)`; any exception logs "Failed to save structure file {} to {}" and returns false. |
| static `save(path, template, asText)` | a path without a parent returns false; create the parent directories; `template.save(new CompoundTag())`; write gzip NBT (or SNBT text); return true. |

A game server therefore needs: the data-pack lookup of `structure/<path>.nbt`, a per-id cache, and (for structure blocks) the
`generated` folder. Template pieces (section 6) call `getOrCreate`, which never fails: a piece whose template file does not exist
gets an **empty** template (no palettes) and places nothing (section 5.1, step 1).

---

## 3. Coordinate transform

All of this is in `StructureTemplate` (static `transform` methods, `getZeroPositionWithTransform`, `getBoundingBox`, `getSize`).
Enumerations: `Rotation` constants (declaration order) `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90`; `Mirror` constants
`NONE`, `LEFT_RIGHT`, `FRONT_BACK`.

### 3.1 Block positions: `transform(pos, mirror, rotation, pivot)`

Let `(x, y, z) = pos` and `(px, pz) = (pivot.x, pivot.z)` (the pivot's y is ignored).

1. **Mirror first**, about the template's own origin (not about the pivot): `LEFT_RIGHT` replaces `z` by `-z`; `FRONT_BACK` replaces
   `x` by `-x`; `NONE` changes nothing.
2. **Rotate second**, about the pivot, on the mirrored `(x, z)`; `y` is unchanged:

| Rotation | new x | new z |
|---|---|---|
| `NONE` | `x` | `z` |
| `CLOCKWISE_90` | `px + pz - z` | `pz - px + x` |
| `CLOCKWISE_180` | `2*px - x` | `2*pz - z` |
| `COUNTERCLOCKWISE_90` | `px - pz + z` | `px + pz - x` |

(read: the switch map in `StructureTemplate$1` assigns case 1 to `COUNTERCLOCKWISE_90`, 2 to `CLOCKWISE_90`, 3 to `CLOCKWISE_180`.)
With the pivot at the origin these are `(x, z) -> (-z, x)` for clockwise 90, `(-x, -z)` for 180, `(z, -x)` for counterclockwise 90. When
`NONE` rotation and `NONE` mirror are both given, the position is returned unchanged. For a shipped piece the pivot is the zero
block `(0,0,0)` unless the piece sets `rotationPivot` (section 4); a jigsaw pool element sets a pivot per its own rules (36-3).

### 3.2 Entity positions: `transform(vec3, mirror, rotation, pivot)`

Same order, on doubles, treating the block-centre convention: mirror: `LEFT_RIGHT` `z -> 1 - z`; `FRONT_BACK` `x -> 1 - x`. Rotation:

| Rotation | new x | new z |
|---|---|---|
| `CLOCKWISE_90` | `(px + pz + 1) - z` | `(pz - px) + x` |
| `CLOCKWISE_180` | `(2*px + 1) - x` | `(2*pz + 1) - z` |
| `COUNTERCLOCKWISE_90` | `(px - pz) + z` | `(px + pz + 1) - x` |

`y` is unchanged. So the entity at the middle of block `(1,0,0)` keeps its relation to that block under the block transform
(example 11.1).

### 3.3 Size and bounding box

* `getSize(rotation)`: for `CLOCKWISE_90` and `COUNTERCLOCKWISE_90` the result is `(size.z, size.y, size.x)`; otherwise `size`.
* `getBoundingBox(origin, rotation, pivot, mirror)` = `BoundingBox.fromCorners(transform((0,0,0)), transform(size - (1,1,1)))` then moved
  by `origin`, where `transform` is section 3.1 with the given mirror, rotation and pivot. The convenience form takes a
  `StructurePlaceSettings` and uses its rotation, pivot and mirror. (`BoundingBox.fromCorners` takes the per-axis min and max: 36-1
  section 6.3.)
* `getZeroPositionWithTransform(pos, mirror, rotation, sizeX, sizeZ)`: the position at which the template's local origin must be
  placed so that the transformed template's **minimum corner** is at `pos` (pivot at the origin). With `sx = sizeX - 1`,
  `sz = sizeZ - 1`, `dx = sx` if the mirror is `FRONT_BACK` else 0, `dz = sz` if the mirror is `LEFT_RIGHT` else 0, the result is `pos`
  plus:

| Rotation | offset (x, y, z) |
|---|---|
| `NONE` | `(dx, 0, dz)` |
| `CLOCKWISE_90` | `(sz - dz, 0, dx)` |
| `CLOCKWISE_180` | `(sx - dx, 0, sz - dz)` |
| `COUNTERCLOCKWISE_90` | `(dz, 0, sx - dx)` |

  The instance form uses the template's own `size.x`, `size.z`.

### 3.4 Relative positions between two placements

`calculateRelativePosition(settings, pos)` = `transform(pos, settings.mirror, settings.rotation, settings.rotationPivot)` (a
template-local position to a position relative to the placement origin). `calculateConnectedPosition(settingsA, posA, settingsB, posB)`
= `relative(settingsA, posA) - relative(settingsB, posB)` (the offset that makes two jigsaw connectors coincide; 36-3).

### 3.5 Filtered views

* `filterBlocks(origin, settings, block[, relative = true])`: the records of the **palette chosen for these settings and this origin**
  (section 4.3) whose block is `block`. Each result record has its position `calculateRelativePosition + origin` (when `relative`
  is true; with false the template-local position is kept), and its state **rotated by the settings' rotation (`BlockState.rotate`)
  but NOT mirrored**; records whose absolute position is outside the settings' bounding box (when the settings have one) are dropped.
  `nbt` is passed through unchanged.
* `getJigsaws(origin, rotation)`: with a fresh `StructurePlaceSettings` that has only the rotation set (mirror none, pivot zero), take
  the palette chosen for those settings at `origin`, and for each jigsaw record return `withInfo(origin + relative(rotation), state.rotate(rotation))`.
  An empty palette list gives an empty list.

---

## 4. Placement settings (`StructurePlaceSettings`)

### 4.1 Fields and defaults

| Field | Default | Meaning |
|---|---|---|
| `mirror` | `Mirror.NONE` | applied before rotation (section 3.1) |
| `rotation` | `Rotation.NONE` | |
| `rotationPivot` | `BlockPos.ZERO` | pivot of the rotation (template-local coordinates); only x and z matter |
| `ignoreEntities` | false | when true, the template's entities are not placed (section 5.6) |
| `boundingBox` | none (null) | when set, only blocks and entities whose absolute position is inside it are placed |
| `liquidSettings` | `APPLY_WATERLOGGING` | `LiquidSettings` constants `IGNORE_WATERLOGGING` (serialized `ignore_waterlogging`), `APPLY_WATERLOGGING` (serialized `apply_waterlogging`); `shouldApplyWaterlogging()` is true only for the second |
| `random` | none (null) | an optional fixed random source |
| `palette` | 0 | stored but **never read**: palette choice is random (section 4.3) |
| `processors` | empty list | ordered list of `StructureProcessor` (section 7) |
| `knownShape` | false | when true, shape updates are skipped after placement (section 5.5) |
| `finalizeEntities` | false | when true, mobs created from the template get `finalizeSpawn` (section 5.6) |

`copy()` copies every field (the processor list is copied element by element, the processors themselves are shared). Setters return
the settings object for chaining; `clearProcessors`, `addProcessor` and `popProcessor` (remove the first equal element) manage the list.

### 4.2 The random source of the settings: `getRandom(pos)`

1. If the settings hold a `random`, return that same object (shared state: every call continues the one stream).
2. Otherwise, if `pos` is null, return a legacy source seeded with the `Util` millisecond clock (`Util.getMillis()`; not shown to be wall-clock epoch time; not reproducible).
3. Otherwise return a **new** legacy source seeded with `Mth.getSeed(pos)`: the draws depend only on the position, and a second call
   for the same position restarts the same sequence.

(31-6 section 6.4 states the same rule from the structure block's side.)

### 4.3 Palette choice: `getRandomPalette(palettes, pos)`

An empty palette list throws ("No palettes"). Otherwise `palettes[ getRandom(pos).nextInt(palettes.size()) ]`. This is evaluated by
`placeInWorld` with `pos` = the placement origin, and again by `filterBlocks`/`getJigsaws` with their origin argument. With the
position-seeded case the index is fixed by the origin: for 4 palettes at origin `(10, 64, 10)` the seed is `Mth.getSeed(10,64,10)`
and the index is 1 (example 11.5). With a shared `random` in the settings each call consumes a draw, so the palette seen by
`filterBlocks` after `placeInWorld` can differ from the one used for placement (the structure-block integrity path is the only
shipped case that sets `random`, and its templates have one palette, section 10.1).

---

## 5. Placing a template: `placeInWorld(level, origin, anchor, settings, random, flags)`

Inputs: a server level accessor; `origin` (the absolute position of the template's local (0,0,0), after the caller has applied any
zero-position shift); `anchor`, a second position that is passed unchanged to the processors as "the pivot position" (for a
`TemplateStructurePiece` it is the `BlockPos` argument of `postProcess`, 36-1 section 8; the structure block passes `origin` twice);
the settings; a random source (used only for loot seeds, section 5.3); an update-flag word (29 section 1). Output: boolean, true when the
placement ran. Steps, in order:

### 5.1 Early exits

1. No palettes: return false.
2. `palette = settings.getRandomPalette(palettes, origin)`; `blocks = palette.blocks()` (the ordered list of section 1.3).
3. When `blocks` is empty: return false when `ignoreEntities` is true or the entity list is empty.
4. Whether or not `blocks` is empty: return false when any component of the template size is below 1. (The non-empty branch jumps to
   this same size test; a template with blocks but a size component below 1 therefore places nothing.) Otherwise continue (an
   entity-only template with a valid size is placed).

### 5.2 Process the block list

`processed = processBlockInfos(level, origin, anchor, settings, blocks)` (section 7.4). The result is the list of block records in
**absolute** positions, after every processor and after `finalizeProcessing`, in the order produced (the order of `blocks` minus
removed records, possibly reordered by a processor's finalizer).

### 5.3 Place the blocks

Let `box = settings.boundingBox` (may be null). Initialise: `placedPositions` (list of position and `nbt` pairs), `fluidPending`
and `fluidDone` (two position lists, used only when waterlogging applies), and a running min/max corner of placed positions. For
each processed record `r`, in order:

1. If `box` is non-null and `r.pos` is outside it, skip the record.
2. If waterlogging applies, `oldFluid = level.getFluidState(r.pos)` (read **before** the write); otherwise `oldFluid` is null.
3. `state = r.state.mirror(settings.mirror).rotate(settings.rotation)` (mirror first, then rotate: the processed state is
   transformed here, so processors see and produce **untransformed template states**, section 7.4).
4. If `r.nbt` is present: first write `minecraft:barrier` at the position with flags **820** (816 + 4: skip all side effects, no
   client redraw), which discards whatever block entity data stood there without drops.
5. Write `state` at the position with the caller's `flags`. If the write returns false, go to the next record (nothing else below
   happens for this record).
6. Grow the min/max corner with the position and append `(pos, r.nbt)` to `placedPositions`.
7. If `r.nbt` is present: take the block entity now at the position; if it exists, then (a) unless the debug constant
   `DEBUG_STRUCTURE_EDIT_MODE` is set (normally false) and when the block entity is a `RandomizableContainer`, overwrite the tag's
   `LootTableSeed` with `random.nextLong()` (this consumes one draw from the `random` argument per such block, in placement order, even
   when the container has no loot table); (b) load the tag into the block entity (`loadWithComponents`).
8. If `oldFluid` is non-null (waterlogging applies): if the state placed has a **source** fluid (`state.getFluidState().isSource()`),
   append the position to `fluidDone`; otherwise, if the state's block is a `LiquidBlockContainer`, call its `placeLiquid(level, pos,
   state, oldFluid)` and then, if `oldFluid` is **not** a source, append the position to `fluidPending`.

### 5.4 Waterlogging pass

Only when waterlogging applies and `fluidPending` is non-empty. Repeat while the previous round changed something (the first round
always runs):

1. `changed = false`. For each position `p` in `fluidPending` (iterating the list; removals happen during the iteration):
   a. `f = level.getFluidState(p)`.
   b. For `d` in the order UP, NORTH, EAST, SOUTH, WEST, while `f` is not a source: `nf = level.getFluidState(p.relative(d))`; when
      `nf` is a source and `p.relative(d)` is not in `fluidDone`, set `f = nf`.
   c. If `f` is a source: take the block state at `p`; when its block is a `LiquidBlockContainer`, call `placeLiquid(level, p, thatState, f)`,
      set `changed = true`, and remove `p` from `fluidPending`.

(Effect: a flowing fluid cell that the template replaced with a waterloggable block becomes waterlogged only when a source fluid is
adjacent from above or the four sides; this repeats so that waterlogging can spread through a chain of such blocks. `placeLiquid` is
the fluid-container operation of 29a; for the waterloggable blocks it acts only on a not-yet-waterlogged state and the water source type, sets waterlogged=true with `setBlockAndUpdate` and schedules a fluid tick for the fluid's tick delay; lava never waterlogs.)

### 5.5 Shape updates

When at least one block was placed (min corner not above max corner):

1. If `settings.knownShape` is false: build a bit grid of the size of the placed corner box (`max - min + 1` per axis) with one set bit
   per entry of `placedPositions` (position minus min corner), then run `updateShapeAtEdge(level, flags, grid, min)` (section 5.5.1).
2. For each entry `(pos, nbt)` of `placedPositions` in order:
   a. If `knownShape` is false: `state = level.getBlockState(pos)`; `newState = Block.updateFromNeighbourShapes(state, level, pos)`
      (the all-neighbour shape update of 29 section 3); if it differs from `state`, write `newState` with flags `(flags AND NOT 1) OR 16`
      (neighbour-update bit cleared, known-shape bit set); then `level.updateNeighborsAt(pos, newState.block)` (this happens whether
      or not the state changed, but only in the `knownShape = false` branch).
   b. If `nbt` is not null: take the block entity at `pos` and, if it exists, call `setChanged()`.

#### 5.5.1 `updateShapeAtEdge(level, flags, grid, minX, minY, minZ)`

`grid.forAllFaces(consumer)` visits every **exposed face** of the set cells: for each set cell and each of the six directions in which
the neighbouring cell inside the grid is clear or lies outside the grid, the consumer is called once with `(direction, x, y, z)` where
`(x, y, z)` is the set cell and `direction` points to the clear neighbour. For one face the consumer does:

1. `pos = min + (x, y, z)`; `neighbour = pos + direction`.
2. `s = level.getBlockState(pos)`, `n = level.getBlockState(neighbour)`.
3. `s2 = s.updateShape(level, level-as-tick-access, pos, direction, neighbour, n, level.getRandom())` (29 section 3.2); if `s2 != s`, write `s2`
   at `pos` with flags `flags AND NOT 1`.
4. `n2 = n.updateShape(level, ..., neighbour, direction.getOpposite(), pos, s2, level.getRandom())` (the state `s2` is passed, the possibly
   updated one is NOT re-read: `s2` is used as the "neighbour state" argument); if `n2 != n`, write `n2` at `neighbour` with flags
   `flags AND NOT 1`.

The visiting order of `forAllFaces` (`DiscreteVoxelShape`) is three passes with the cycle NONE, FORWARD, BACKWARD (`AxisCycle`). In
each pass the grid is scanned in lines along one axis; positions along the line run from 0 to the line length inclusive, where
position `k` is "set" only when `k` is inside the grid and the cell is set (so the position just past the end is clear). At a position
where the previous cell was clear and the current is set, the consumer is called with the NEGATIVE direction of the line axis and the
current cell; where the previous was set and the current is clear, the consumer is called with the POSITIVE direction and the
previous cell. The lines of pass 1 run along z (outer loops: x ascending, then y ascending); pass 2 along y (outer loops: z, then x);
pass 3 along x (outer loops: y, then z). Read from `DiscreteVoxelShape.forAllFaces`: it runs `forAllAxisFaces` with NONE, FORWARD, BACKWARD; each pass takes
`inv = cycle.inverse()`, the line axis is `inv.cycle(Z)`, the outer loop `i` runs over the size of `inv.cycle(X)` and the inner loop `j` over the size of `inv.cycle(Y)`;
`AxisCycle` FORWARD adds one to the axis ordinal modulo 3 and BACKWARD is its inverse.

### 5.6 Entities

When `settings.ignoreEntities` is false, after the block work (including when no block was placed), for each entity record in list order:

1. `blockPos = transform(info.blockPos, mirror, rotation, pivot) + origin` (section 3.1 with the settings' own pivot). When `box` is
   non-null and `blockPos` is outside it, skip the record.
2. Copy the record's `nbt`. `vec = transform(info.pos, mirror, rotation, pivot) + (origin.x, origin.y, origin.z)` (section 3.2).
3. Overwrite `Pos` with `vec` (List of 3 Double); remove `UUID` (so a fresh UUID is assigned); when the tag contains `block_pos`,
   store `blockPos` (from step 1) under `block_pos` with the block-position codec (an int array).
4. Create the entity from the tag with spawn reason `STRUCTURE` (`EntityType.create(input, level, request)`); a creation exception is
   swallowed and gives no entity (the record is skipped). Entity NBT loading is 45.
5. For the created entity: `yaw = entity.rotate(rotation)`; `yaw = yaw + (entity.mirror(mirror) - entity.getYRot())`; place it at `vec`
   with that yaw and its own pitch; set body and head yaw to `yaw`.
6. When `settings.finalizeEntities` is true and the entity is a `Mob`: call `finalizeSpawn(level, difficulty at BlockPos.containing(vec),
   STRUCTURE, no group data)`.
7. Add the entity with its passengers (`addFreshEntityWithPassengers`).

(`Entity.rotate(Rotation)` and `Entity.mirror(Mirror)` return the new yaw value; entities that override them (hanging entities,
`blockPos`-anchored ones) are in 44 and 45, Open question 5.)

Finally `placeInWorld` returns **true**.

---

## 6. `TemplateStructurePiece`

The abstract base of every structure piece that places a template (subclass of `StructurePiece`, 36-1 section 6). It has the fields
`templateName` (String), `template` (the `StructureTemplate`), `placeSettings` (a `StructurePlaceSettings`) and `templatePosition`
(`BlockPos`, the placement origin).

### 6.1 Construction and serialization

* New piece (type, generation depth, manager, template id, name string, settings, position): `template = manager.getOrCreate(id)`;
  the piece's bounding box is `template.getBoundingBox(settings, position)`; orientation is set to `NORTH`; the fields are stored.
* Loaded piece (type, tag, manager, settings function): reads `Template` (String, default `""`), `TPX`, `TPY`, `TPZ` (Int, default 0)
  into `templatePosition`; `template = manager.getOrCreate(makeTemplateLocation())` where the location is `Identifier.parse(templateName)`
  (a subclass may override it); `placeSettings = settingsFunction.apply(that identifier)`; the bounding box is recomputed as
  `template.getBoundingBox(placeSettings, templatePosition)`.
* Save (`addAdditionalSaveData`) writes `TPX`, `TPY`, `TPZ` (Int) and `Template` (String). The remaining keys (`id`, `GD`, `BB`, `O`) are the
  `StructurePiece` base's (36-1 section 6.7). The mirror, rotation and pivot are NOT saved here: a subclass writes its own `Rot` or similar and
  rebuilds the settings in its settings function.
* `move(dx, dy, dz)` shifts the base box and adds the offset to `templatePosition`. `getRotation()` returns `placeSettings.getRotation()`.

### 6.2 `postProcess(level, structureManager, generator, random, chunkBox, chunkPos, anchor)`

1. `placeSettings.setBoundingBox(chunkBox)`: the settings are restricted to the chunk-window box handed in (so only the part of the
   piece inside the chunk being decorated is written, 36-1 section 8).
2. `boundingBox = template.getBoundingBox(placeSettings, templatePosition)` is recomputed.
3. `template.placeInWorld(level, templatePosition, anchor, placeSettings, random, 2)` (flags 2: send to clients only). If it returns false,
   stop.
4. **Data markers.** `blocks = template.filterBlocks(templatePosition, placeSettings, structure_block)` (section 3.5: transformed positions,
   rotated states, only those inside the chunk box). For each record that has `nbt`: the tag's `mode` is read with the legacy mode codec
   (31-6 section 6.1.1; a missing or invalid mode is an error that propagates); when the mode is `DATA`, call
   `handleDataMarker(metadata, pos, level, random, chunkBox)` with `metadata` = the tag's `metadata` String (default `""`) and the absolute
   `pos`. `handleDataMarker` is abstract: each structure's piece class defines what each metadata string means (per-structure parts of 36;
   typical uses are placing a chest with a loot table, a spawner or an entity at the marker). Other modes (`SAVE`, `LOAD`, `CORNER`) are
   ignored: those structure blocks stay in the world as placed blocks unless a processor removed them (see `block_ignore`, section 9.1).
5. **Jigsaw markers.** `blocks = template.filterBlocks(templatePosition, placeSettings, jigsaw)`; for each record with `nbt`: read
   `final_state` (String, default `minecraft:air`) and parse it as a block state (the command-style block-state text parser, 15 section 9.1,
   called with `allowNbt` = true, so the text may carry a block-entity NBT part after the properties; `BlockStateParser.parseForBlock(lookup, string, allowNbt)` keeps a field `allowNbt` and consults it on reaching a `{`); on a syntax error log
   "Error while parsing blockstate {} in jigsaw block @ {}" and use the default state of `minecraft:air`; then `level.setBlockAndUpdate(pos,
   state)` (default flags, 29 section 2). The jigsaw block's own state is not rotated into the final state: `final_state` text is written
   as is. (Pieces assembled by `JigsawPlacement` normally already had their jigsaws replaced by the processor of section 9.6 during
   `placeInWorld`; this step covers template pieces whose processors did not include it and the debug case.)

---

## 7. Structure processors: framework

### 7.1 The processor interface (`StructureProcessor`)

| Method | Default | Meaning |
|---|---|---|
| `processBlock(level, origin, anchor, localPos, current, settings)` | returns `current` | transform one block record. `origin` and `anchor` are the two positions of `placeInWorld`; `localPos` is the **template-local position of the record before any processing**; `current` is the record in absolute position as left by the earlier processors (its state is untransformed). Returning null removes the block from the placement. |
| `finalizeProcessing(level, origin, anchor, originals, processed, settings)` | returns `processed` | a whole-list step run after every block has been processed; `originals` (template records of the blocks that survived) and `processed` have equal length and matching order |
| `evaluatesEntirePieceState()` | false | when any processor in the list returns true, blocks outside the settings' bounding box are still sent through the processors (section 7.4) |
| `codec()` | | the `MapCodec` for the JSON form |

### 7.2 Registries, lists and JSON

| Registry key | Kind | Content (registration order) |
|---|---|---|
| `worldgen/structure_processor` | code (static) | `blackstone_replace`, `block_age`, `block_ignore`, `block_rot`, `capped`, `gravity`, `jigsaw_replacement`, `lava_submerged_block`, `nop`, `protected_blocks`, `rule` (11 entries; ids are registration indices, inferred) |
| `rule_test` | code (static) | `all_of`, `always_true`, `any_of`, `block_match`, `blockstate_match`, `not`, `tag_match`, `height_match`, `random_block_match`, `random_blockstate_match` (10) |
| `pos_rule_test` | code (static) | `always_true`, `linear_pos`, `axis_aligned_linear_pos` (3) |
| `rule_block_entity_modifier` | code (static) | `clear`, `passthrough`, `append_static`, `append_loot` (4) |
| `worldgen/processor_list` | data (dynamic) | the 40 shipped processor lists (23 section 2.1 row 8) |

None is sent to clients (04 section 6, 23). Registry ids matter only for internal tables.

JSON forms:

* A single processor: an object with `processor_type` (identifier of a `worldgen/structure_processor` entry) plus that type's fields
  beside it (dispatch codec, the type's `MapCodec`).
* A processor list element (`StructureProcessorList`, a record of an ordered `List<StructureProcessor>`): **either** an object
  `{"processors": [ ... ]}` **or** a bare array of processors (`DIRECT_CODEC` = the object form with the bare array as the
  alternative). A reference to a list from other data (a pool element's `processors` field, 36-3) is the holder form: the identifier of
  a `worldgen/processor_list` element or an inline list (23 section 5.1).
* `rule_test`: an object with `predicate_type` (identifier) plus fields. `pos_rule_test`: object with `predicate_type` plus fields.
  `rule_block_entity_modifier`: object with `type` plus fields.

### 7.3 `empty` and the pass-through list

The data pack's list `minecraft:empty` has no processors. A settings object with an empty list does nothing in section 7.4 (every
record is kept, `finalizeProcessing` calls are skipped).

### 7.4 The pipeline: `StructureTemplate.processBlockInfos(level, origin, anchor, settings, blocks)`

1. `onlyInsideBox = true`; if any processor in `settings.processors` has `evaluatesEntirePieceState() == true`, set `onlyInsideBox = false`.
2. For each template record `t` of `blocks` in order:
   a. `absPos = calculateRelativePosition(settings, t.pos) + origin` (section 3.4).
   b. If `onlyInsideBox` and the settings have a bounding box and `absPos` is outside it, skip the record entirely (it enters neither list).
   c. `cur = (absPos, t.state, copy of t.nbt)`: the state is the **template state, not mirrored or rotated yet**; the tag is a deep copy so
      processors may mutate it.
   d. For each processor in list order, while `cur` is not null: `cur = processor.processBlock(level, origin, anchor, t.pos, cur, settings)`.
   e. If `cur` is not null: append `cur` to `processed` and `t` to `originals`.
3. For each processor in list order: `processed = processor.finalizeProcessing(level, origin, anchor, originals, processed, settings)`
   (`level` here is the server level accessor; `processed` is replaced by the return value, so a finalizer can reorder, replace or
   drop records provided it keeps the contract of its own type).
4. Return `processed`.

`placeInWorld` (section 5.3) then applies the box test again, the state transform, and the writes. So processors that read the state
(`block_match`, `blockstate_match` ...) compare against the **unrotated, unmirrored** template state, while the world state used by
`location_predicate` is read at the absolute position. A rule's `output_state` is itself rotated and mirrored when written (a stair
output keeps the template's facing before the transform).

---

## 8. The rule processor (`rule`)

JSON: `{"processor_type": "minecraft:rule", "rules": [ProcessorRule, ...]}`.

### 8.1 `RuleProcessor.processBlock`

1. `rng = legacy source seeded with Mth.getSeed(current.pos)` (the **absolute** position; one fresh source per block, not the settings'
   random).
2. For each rule in list order: if `rule.test(level, current.state, localPos, current.pos, anchor, rng)` is true, return a new record
   `(current.pos, rule.outputState, rule.outputTag(rng, current.nbt))` and stop (the first matching rule wins; later rules are not
   evaluated and draw nothing).
3. No rule matched: return `current` unchanged.

Note the same `rng` is passed to every rule test in turn, so draws made by the tests of non-matching rules shift the draws seen by
later rules (section 11.4).

### 8.2 `ProcessorRule`

| JSON field | Type | Default | Meaning |
|---|---|---|---|
| `input_predicate` | `rule_test` | required | tested against the **template state** at the absolute position (`test(state, absPos, rng)`) |
| `location_predicate` | `rule_test` | required | tested against the **world's current state** at the absolute position (`testAgainstWorldState(level, absPos, rng)`, section 8.3) |
| `position_predicate` | `pos_rule_test` | `always_true` (lenient: an invalid value falls back to the default) | `test(localPos, absPos, anchor, rng)` |
| `output_state` | block state (the standard block-state codec: `Name`, optional `Properties`) | required | the state written |
| `block_entity_modifier` | `rule_block_entity_modifier` | `passthrough` (lenient) | how the block entity tag changes |

The rule matches when all three predicates are true, evaluated in the order input, location, position, with short-circuit: when the input
predicate fails, no later predicate draws from `rng`. The output tag is `modifier.apply(rng, current.nbt)` (`current.nbt` may be null).

### 8.3 Rule tests (`RuleTest`)

`test(state, pos, rng)` is abstract. `testAgainstWorldState(level, pos, rng)` defaults to `test(level.getBlockState(pos), pos, rng)`.
Only `always_true` overrides it (returning true **without** reading the world).

| `predicate_type` | Fields | `test(state, pos, rng)` |
|---|---|---|
| `always_true` | none | true |
| `block_match` | `block` (a block id) | `state.is(block)` |
| `blockstate_match` | `block_state` (a block state) | the state equals the given state exactly (every property value; a property missing from the JSON takes its default) |
| `tag_match` | `tag` (a block tag id; whether a leading `#` is accepted was not checked) | `state.is(tag)` |
| `random_block_match` | `block`, `probability` (float) | `state.is(block)` and then `rng.nextFloat() < probability` (the draw is made **only when the block matches**) |
| `random_blockstate_match` | `block_state`, `probability` | state equals and then `rng.nextFloat() < probability` (draw only on a match) |
| `height_match` | `min_inclusive`, `max_inclusive` (Int) | `min_inclusive <= pos.y <= max_inclusive` (absolute y; the state is ignored) |
| `all_of` | `rules` (list of rule tests) | every rule's `test(state, pos, rng)` is true, in order, stopping at the first false (an empty list is true) |
| `any_of` | `rules` | some rule is true, stopping at the first true (an empty list is false) |
| `not` | `rule` | the negation of the rule's `test` |

Composite tests pass `state`, `pos` and `rng` down unchanged. Under `location_predicate`, the composite's `testAgainstWorldState` is
the default, so the world state is read once at `pos` and given to every child (`always_true` inside an `all_of` therefore reads the
world anyway). `probability` is compared with a strict "less than" (read: `fcmpg` followed by `ifge`).

### 8.4 Position tests (`PosRuleTest`)

`test(localPos, absPos, anchor, rng)`:

| `predicate_type` | Fields (defaults) | Behaviour |
|---|---|---|
| `always_true` | none | true |
| `linear_pos` | `min_chance` (float, 0), `max_chance` (float, 0), `min_dist` (Int, 0), `max_dist` (Int, 0) | `d = absPos.distManhattan(anchor)` (sum of the absolute coordinate differences); see section 8.4.1 |
| `axis_aligned_linear_pos` | the four above and `axis` (`x`, `y` or `z`; optional, default `y`, read from the codec; the one shipped use, `high_rampart`, gives no `axis`, no `min_chance` and no `min_dist`, so it runs with the defaults axis y, 0, 0) | `d` = the absolute difference of `absPos` and `anchor` along the axis only; see section 8.4.1 |

#### 8.4.1 The linear chance

Both types construct only when `min_dist < max_dist` (otherwise the constructor throws an invalid-range error; in a data pack this
fails the element). Let `t = (d - min_dist) / (max_dist - min_dist)` (floating point, `Mth.inverseLerp`, not clamped), `t' = clamp(t, 0, 1)`
and `chance = min_chance + t' * (max_chance - min_chance)` (`Mth.clampedLerp` then `lerp`). The draw `u = rng.nextFloat()` is
**always** made (one draw per evaluation) and the test passes when `u <= chance` (**less than or equal**, unlike `probability` above:
read `fcmpg; ifgt` returning false). For the axis-aligned type `d` is `|dx|` for axis x, `|dy|` for y, `|dz|` for z (the implementation
sums the three products with the positive direction's step vector, so only the chosen axis contributes), then converted to an integer
by truncation. The local position is not used by either type.

### 8.5 Block entity modifiers (`RuleBlockEntityModifier.apply(rng, tag)`)

| `type` | Fields | Result |
|---|---|---|
| `passthrough` | none | `tag` unchanged (may be null) |
| `clear` | none | a new empty compound (discards the template's tag; the block is still given a block entity tag, which is empty) |
| `append_static` | `data` (compound) | when `tag` is null, a copy of `data`; otherwise `tag.merge(data)` (keys of `data` overwrite or merge into `tag`; nested compounds merge recursively) |
| `append_loot` | `loot_table` (resource key of a loot table) | copy of `tag` (or a new empty compound), then `LootTable` := the key (as an identifier string) and `LootTableSeed` := `rng.nextLong()` (one draw) |

---

## 9. The other processors

For every processor the "when" column is a data-driven JSON use or a use from code (a piece class or a pool element); the shipped
processor lists use only `rule`, `block_rot`, `protected_blocks` and `capped` (section 10.2), the others are used from code (pieces
and pool elements: 36-3 and later parts), and their code-side use sites are not repeated here.

### 9.1 `block_ignore`

JSON: `{"blocks": [block state, ...]}`: each entry is read with the block-state codec and **only its block is kept** (properties are ignored).
`processBlock`: returns null when the record's block is in the list, otherwise `current`. Code constants: `STRUCTURE_BLOCK` (list of
`structure_block`), `AIR` (list of `air`), `STRUCTURE_AND_AIR` (`air` and `structure_block`).

### 9.2 `block_rot`

JSON: `rottable_blocks` (optional holder set of blocks, a block id list, a `#tag` or inline list: 23 section 5.1) and `integrity` (float in the range 0 to 1,
required). `processBlock`: `rng = settings.getRandom(current.pos)` (section 4.2: the settings' shared random when set, else a position-seeded
source). When `rottable_blocks` is present and the record's state is **not** in it, return `current` (no draw). Otherwise draw
`u = rng.nextFloat()`; if `u > integrity` return null (the block is not placed), else `current`. So a block survives with
probability `integrity`, and `u <= integrity` keeps it (`integrity = 1` keeps every block unless `u` could exceed 1, which it cannot).
The constructor with a holder set stores it as present; the structure block's integrity path (31-6 section 6.4) constructs it with no set.

### 9.3 `protected_blocks`

JSON: `value` (holder set of blocks, in the data usually a `#` tag). `processBlock`: read the **world** state at the record's absolute
position; if that state is in the set, return null (do not overwrite protected blocks), otherwise `current`.

### 9.4 `capped`

JSON: `delegate` (a single processor object) and `limit` (an `IntProvider`, positive: 23 section 7.1).
It does nothing in `processBlock` (the default pass-through) and `evaluatesEntirePieceState()` is **true**. Its `finalizeProcessing` does:

1. If `limit.maxInclusive()` is 0 or `processed` is empty: return `processed`.
2. If `originals.size() != processed.size()`: log an error message and return `processed` (the delegate would be misaligned).
3. `rng = positional factory at origin`: `seedRng = SingleThreadedRandomSource(level.getSeed())`; this is the same linear congruential
   algorithm as the legacy source with the seeding of 10 section 2.6; `factory = seedRng.forkPositional()` (a legacy positional factory
   whose seed is `seedRng.nextLong()`); `rng = factory.at(origin)` (`Mth.getSeed(origin) XOR factory seed`, a new legacy source:
   10 section 2.6).
4. `cap = min(limit.sample(rng), processed.size())`. If `cap < 1`: return `processed`.
5. `order` = the indices `0 .. n-1` shuffled with `rng`: for `i` from `n` down to 2: `j = rng.nextInt(i)`; swap `order[i-1]` and `order[j]`
   (`Util.toShuffledList(IntStream.range(0, n), rng)`).
6. `applied = 0`. Walk `order` while `applied < cap`: for index `i`, `result = delegate.processBlock(level, origin, anchor, originals[i].pos,
   processed[i], settings)` (the first position argument is the **original record's template-local position**; note `anchor` is the
   third position); if `result` is non-null and not equal (record equality: position, state, tag) to `processed[i]`, then
   `applied += 1` and `processed[i] = result`. A null result or an unchanged result is ignored (it does not remove the block and does not
   count).
7. Return `processed`.

So `capped` applies the delegate to a random subset of blocks, at most `limit` of the ones the delegate actually changes. The delegate's
own `finalizeProcessing` is never called.

### 9.5 `gravity`

JSON: `heightmap` (heightmap type name, default `WORLD_SURFACE_WG`) and `offset` (Int, default 0). The heightmap names are the serialized
names `WORLD_SURFACE_WG`, `WORLD_SURFACE`, `OCEAN_FLOOR_WG`, `OCEAN_FLOOR`, `MOTION_BLOCKING`, `MOTION_BLOCKING_NO_LEAVES` (upper case, read from
the enum constructor strings; 06 section 3.1). `processBlock`: when the level argument is a `ServerLevel` (a real world rather than a
world-generation region), `WORLD_SURFACE_WG` is replaced by `WORLD_SURFACE` and `OCEAN_FLOOR_WG` by `OCEAN_FLOOR`; other types are used
as given (and any heightmap is used as given when the level is not a server level). Then
`h = level.getHeight(heightmap, current.x, current.z) + offset` and the result position is
`(current.x, h + localPos.y, current.z)`: **the template-local y of the record** is added to the heightmap height, so each block keeps its
vertical offset above the local terrain surface; the state and tag are unchanged. (`getHeight` is the heightmap value of 06 section 3.1 and 10, the
y of the first non-matching cell above the highest matching block.)

### 9.6 `jigsaw_replacement`

No fields (a unit codec). `processBlock`: 

1. If the record's block is not `jigsaw` (or the debug constant `DEBUG_KEEP_JIGSAW_BLOCKS_DURING_STRUCTURE_GEN` is on, normally off), return `current`.
2. If the record has no `nbt`: log "Jigsaw block at {} is missing nbt, will not replace" (the `{}` argument is the **piece origin**, the second position parameter, not the block's own position) and return `current`.
3. Read `final_state` (String, default `minecraft:air`) and parse it with the block-state text parser against the world's block lookup, with `allowNbt` = true (as in section 6.2 step 5). On a
   syntax error log "Failed to parse jigsaw replacement state '{}' at {}: {}" (with the **piece origin** as the position argument) and return **null**.
4. If the parsed state is `structure_void`, return null (nothing is placed).
5. Otherwise return `(current.pos, parsedState, no nbt)`.

The parsed state is rotated and mirrored by `placeInWorld` like any state (so a `final_state` with a facing keeps its relation to the
piece), unlike the text path of section 6.2 step 5.

### 9.7 `lava_submerged_block`

No fields. `processBlock`: read the world state at the record's position; when it is `lava` (the lava block, any level) and the template
state's collision-shape check `Block.isShapeFullBlock(state.getShape(level, pos))` is **false**, return `(pos, lava default state, current.nbt)`
(source lava replaces a non-full block that would otherwise leave a gap under lava); in every other case `current`. (The shape is
evaluated for the template's state at the world position.) Used from code (nether structures, ruined portals): per-structure parts.

### 9.8 `blackstone_replace`

No fields (a singleton). A fixed map from block to block, read from the constructor (23 entries; keys are matched on the **block**,
not the state):

| From | To |
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

(Counting each "from" block separately the table has 23 entries; 23 `put` calls were counted in the constructor.) `processBlock`: look up the record's block; if absent return `current`. Otherwise start from the target
block's **default state** and copy only these properties **if the source state has them**: stairs `facing` and `half`, slab `type`. No
other property is copied: `waterlogged`, stair `shape`, wall connections and `iron_bars` connections take the target's defaults. The
record's position and tag are kept.

### 9.9 `block_age`

JSON: `mossiness` (float, required). `processBlock`: `rng = settings.getRandom(current.pos)` (section 4.2); `state = current.state`;
`newState` starts null. By the first matching block class:

| State is | Replacement function |
|---|---|
| `stone_bricks`, `stone` or `chiseled_stone_bricks` | `fullStone` (below) |
| in block tag `stairs` | `stairs` |
| in block tag `slabs` | `slab` |
| in block tag `walls` | `wall` |
| `obsidian` | `obsidian` |
| anything else | no change |

When `newState` is null the record is returned unchanged; otherwise `(current.pos, newState, current.nbt)`. The functions:

* `fullStone(rng)`: draw `u = rng.nextFloat()`; if `u >= 0.5` return none. Then **build both candidate lists, consuming draws in this order**:
  non-mossy list = [`cracked_stone_bricks` default state, `stone_brick_stairs` with a random facing and half]; mossy list =
  [`mossy_stone_bricks` default state, `mossy_stone_brick_stairs` with a random facing and half]. A "random facing and half" state draws
  one draw for the facing (the artifact calls `Direction$Plane.getRandomDirection`; the horizontal order north, east, south, west is read; that it is exactly one `nextInt(4)` is inferred from the worked example) and then one draw for the half (the artifact calls `Util.getRandom(Half.values(), rng)`; `Half` order TOP then BOTTOM is read; one `nextInt(2)` is inferred). So four draws build the two lists (non-mossy stairs first). Then
  `pick(rng, nonMossy, mossy)`.
* `pick(rng, nonMossy, mossy)`: draw `u = rng.nextFloat()`; when `u < mossiness` choose from `mossy`, else from `nonMossy`; the choice is
  `list[rng.nextInt(2)]` (one `nextInt(2)` draw; both lists have length 2).
* `stairs(state, rng)`: draw `u = rng.nextFloat()`; if `u >= 0.5` none. Mossy list = [`mossy_stone_brick_stairs` with **the same properties as the
  input state** (`withPropertiesOf`), `mossy_stone_brick_slab` default state]; non-mossy list = the constant `NON_MOSSY_REPLACEMENTS` =
  [`stone_slab` default, `stone_brick_slab` default]. Then `pick(rng, NON_MOSSY_REPLACEMENTS, mossy)`.
* `slab(state, rng)`: draw `u`; when `u < mossiness` the result is `mossy_stone_brick_slab` with the input's properties; else none.
* `wall(state, rng)`: draw `u`; when `u < mossiness` the result is `mossy_stone_brick_wall` with the input's properties; else none.
* `obsidian(rng)`: draw `u`; when `u < 0.15` the result is `crying_obsidian` default state; else none.

Constants: the full-stone gate 0.5 and the stairs gate 0.5 (`PROBABILITY_OF_REPLACING_FULL_BLOCK`, `PROBABILITY_OF_REPLACING_STAIRS`), the
obsidian gate 0.15 (`PROBABILITY_OF_REPLACING_OBSIDIAN`). `withPropertiesOf(state)` copies every property of the input state that the target block also
has (`Block.withPropertiesOf` walks the target block's property list and copies each property the source state has, read). Section 9.7's full-block test (`Block.isShapeFullBlock`) is a lookup in a cache of full-block shapes (read).

### 9.10 `nop`

No fields. Returns `current` (the default behaviour). Used as a placeholder.

---

## 10. What the shipped data uses

### 10.1 Structure NBT files

Counted from the archive with `unzip -Z1 | grep -v '/$'`: `data/minecraft/structure/**` has **1511** files, all ending `.nbt`. A script
decompressed all of them: every one has `DataVersion` **5023** (equal to `world_version` 5023 in `version.json`), so the data fixer never runs
for the shipped files; **20** of them use the multi-palette form (`palettes`), the other 1491 use `palette`. Palette entries use the
keys `id` and `properties`; block records use `pos`, `state` and `nbt`. Jigsaw records in these files carry the keys of section 1.5
and `final_state`. (The scan of a sample file, `igloo/top.nbt`, showed the root keys `size`, `entities`, `blocks`, `palette`,
`DataVersion`; its block entity tags include furnace and jigsaw data.)

### 10.2 Processor lists

`data/minecraft/worldgen/processor_list/` has **40** elements. The `processor_type` values used across them, counted by occurrence in the
JSON text: `rule` 39, `protected_blocks` 7, `block_rot` 6, `capped` 4. Rule-test types used: `always_true` 155 (154 as `location_predicate`, 1 as `input_predicate`), `random_block_match` 123,
`block_match` 33 (23 as `input_predicate`, 10 as `location_predicate`), `tag_match` 9, `blockstate_match` 8; position test types used: `axis_aligned_linear_pos` 1 (`linear_pos` is not used in the data);
block entity modifier `append_loot` 4 (`passthrough` is the default everywhere else). Types registered but not used in the shipped lists
(`gravity`, `block_age`, `blackstone_replace`, `jigsaw_replacement`, `lava_submerged_block`, `block_ignore`, `nop`, and the rule
tests `all_of`, `any_of`, `not`, `height_match`, `random_blockstate_match`) are referenced from code, or are only available to data
packs; the engine must implement all of them because the registries are public to data packs.

---

## 11. Worked examples

These were computed from the formulas above (by hand and with a script of those formulas); they were not run against the artifact.

### 11.1 Transform of a block and of an entity

Pivot `(0,0,0)`, mirror `NONE`, rotation `CLOCKWISE_90`, template-local block `(3, 5, 1)`: `(x, z) -> (-z, x)` gives `(-1, 5, 3)`. With
`COUNTERCLOCKWISE_90`: `(z, -x)` gives `(1, 5, -3)`. With `CLOCKWISE_180`: `(-3, 5, -1)`. With pivot `(2, 0, 2)` and clockwise 90:
`x' = 2 + 2 - 1 = 3`, `z' = 2 - 2 + 3 = 3`, so `(3, 5, 3)` (check: offset from the pivot `(1, -1)` turns into `(1, 1)`).
Entity at `(1.5, 0, 0.5)` (the middle of block `(1,0,0)`), pivot origin, clockwise 90: `x' = 0 + 0 + 1 - 0.5 = 0.5`, `z' = 0 - 0 + 1.5 = 1.5`,
i.e. the middle of block `(0, 0, 1)`, which is where the block transform sends block `(1, 0, 0)`.
Mirror `LEFT_RIGHT` then clockwise 90 for block `(3, 5, 1)`: mirror gives `(3, 5, -1)`, then `(x, z) -> (-z, x)` gives `(1, 5, 3)`.

### 11.2 Bounding box and zero position

Template size `(5, 4, 3)`, rotation `CLOCKWISE_90`, mirror `NONE`, pivot origin, origin `(100, 64, 200)`: corner `(0,0,0)` maps to `(0,0,0)`;
corner `(4, 3, 2)` maps to `(-2, 3, 4)`; the box before the move is `(-2,0,0)` to `(0,3,4)`; after the move
`(98, 64, 200)` to `(100, 67, 204)`: width 3 and depth 5 (x and z swapped). `getZeroPositionWithTransform((100,64,200), NONE, CLOCKWISE_90, 5, 3)`:
`sx = 4`, `sz = 2`, offset `(sz - dz, 0, dx) = (2, 0, 0)`, so the origin is placed at `(102, 64, 200)` and then the minimum corner of the
transformed box is `(100, 64, 200)`.

### 11.3 Block order in a palette

A template has four records: `(1,0,0)` stone (full cube), `(0,0,0)` stone, `(0,1,0)` torch (not a full cube), `(0,0,1)` chest with `nbt`.
Groups: full cubes `(1,0,0)`, `(0,0,0)`; others `(0,1,0)`; with `nbt` `(0,0,1)`. Sorting inside the full-cube group by y, then x, then z gives `(0,0,0)`
then `(1,0,0)`. Final order: `(0,0,0)`, `(1,0,0)`, `(0,1,0)`, `(0,0,1)` (the chest's loot seed is drawn last).

### 11.4 Rule processor draws

A rule list `[R1, R2]` where R1 has `input_predicate` `random_block_match(stone, 0.5)`, location `always_true`, output `cobblestone`; R2 has input
`random_block_match(stone, 0.5)`, output `mossy_cobblestone`. For a stone block at absolute `(1, 2, 3)`: `Mth.getSeed(1,2,3) = -33674130277896`
and the legacy source's first three `nextFloat` values are `0.795369`, `0.88627`, `0.667475`. R1 draws `0.795369`, not less than 0.5, fails. R2 draws
`0.88627`, fails. The block stays stone. For a stone block at `(-5, 64, 17)`: seed `-133562294076312`, draws `0.069996`: R1 matches
(first rule wins) and the block becomes cobblestone; R2 is not evaluated. For a block that is not stone, no draw happens in either rule.

### 11.5 Palette choice

Four palettes, no `random` in the settings, origin `(10, 64, 10)`: `Mth.getSeed(10,64,10)` seeds a legacy source and `nextInt(4)` is 1,
so palette 1 is used; with two palettes `nextInt(2)` is 0 at the same origin. The same origin always gives the same choice.

### 11.6 Linear position test

`linear_pos` with `min_chance 0`, `max_chance 1`, `min_dist 0`, `max_dist 8`, anchor `(0, 64, 0)`, block at `(3, 64, -1)`: `d = 3 + 0 + 1 = 4`;
`t = 0.5`; `chance = 0.5`; the test passes when the draw `u <= 0.5`. At `d = 12`, `t = 1.5` clamps to 1, `chance = 1`, the test always passes (a draw is still
consumed). At `d = 0`, `chance = 0`: the test passes only when `u == 0.0` exactly (probability 2^-24).

### 11.7 Blackstone replacement

Input `stone_brick_stairs[facing=east, half=top, shape=outer_left, waterlogged=true]` becomes the default state of
`polished_blackstone_brick_stairs` with `facing=east` and `half=top`; `shape` is `straight` and `waterlogged` is `false` (defaults). Input
`stone_brick_wall[up=true, north=low, ...]` becomes the default `polished_blackstone_brick_wall` (no property copied). Input
`smooth_stone_slab[type=double]` becomes `polished_blackstone_slab[type=double]`.

### 11.8 Block age draws

`block_age` with `mossiness = 0.3` on `stone_bricks` at `(-5, 64, 17)` with no shared random (position-seeded): the draws of that source are
`nextFloat 0.069996` (below 0.5: proceed), `nextInt(4) = 2` (south), `nextInt(2) = 0` (top), `nextInt(4) = 2` (south), `nextInt(2) = 0` (top),
`nextFloat 0.544531` (not below 0.3: choose the non-mossy list), `nextInt(2) = 0` (index 0): the result is `cracked_stone_bricks`. At
`(1, 2, 3)` the first draw `0.795369` is not below 0.5, so the block is unchanged.

### 11.9 `capped` shuffle

Level seed 12345, origin `(10, 64, 10)`, five processed blocks, `limit` a uniform provider over 1 to 3 (drawn as `1 + rng.nextInt(3)`, the
uniform form of 23 section 7.1, assumed here). Seed source: the legacy-algorithm source from 12345; its `nextLong()` = `6674089274190705457` is the
factory seed; `rng` = a legacy source seeded with `Mth.getSeed(10,64,10) XOR 6674089274190705457`. First draw: `nextInt(3)` gives 0, so the limit
is 1. Then the shuffle of the indices `[0,1,2,3,4]` (for `i = 5` down to 2: `j = rng.nextInt(i)`, swap `order[i-1]` and `order[j]`) gives
`[2, 1, 4, 0, 3]`. The delegate is tried on block 2 first, then 1, 4, ... and the walk stops as soon as one block has actually changed (limit 1).

### 11.10 Liquid handling

A template of one `oak_stairs[waterlogged=false]` is placed where the world has a flowing water cell (level 3) that has a source water cell directly above it. Waterlogging
applies: `oldFluid` = flowing water; the new state has no fluid; the block is a liquid container, `placeLiquid(..., flowing water)` runs (a no-op: `SimpleWaterloggedBlock.placeLiquid` acts only when the state is not yet waterlogged and the fluid is the water type `Fluids.WATER` and, on the server side, sets waterlogged=true with `setBlockAndUpdate` and schedules a fluid tick of the fluid's tick delay; `Fluids.WATER` matches the source type only, so flowing water does nothing here, and lava never waterlogs) and since the fluid is not a source the position goes to `fluidPending`. In the pass: `f` = flowing; UP neighbour
is a source water cell not in `fluidDone`, so `f` becomes that source; the block is a liquid container, so the stairs become waterlogged with water
source; removed from the pending list; another round runs (changed) and finds the list empty.

---

## 12. Validation

An implementation is correct against this document when:

1. **Transform.** `transform` equals the tables of section 3.1 and 3.2 for all 4 rotations x 3 mirrors on a sample of block and entity positions with a non-zero
   pivot, and examples 11.1 and 11.2 reproduce.
2. **Bounding box.** The box of a placed template always has the rotated size of section 3.3, and every block written by an unrestricted
   placement lies inside it.
3. **Order.** A random template's palette list equals the groups of section 1.3 and 11.3 (full cubes, others, block entities; each by y, x, z).
4. **Round trip.** `load` of a file followed by `save` and `load` gives the same palette, block records and entity records (states by
   index; indices assigned by first use in `save`).
5. **Processors.** For each processor type, examples 11.4 to 11.9 reproduce; `rule` with `random_block_match` draws only on a block match; `linear_pos` consumes one draw
   per evaluation and uses `<=`; `capped` never changes more than `limit` blocks.
6. **State transform timing.** A rule with `output_state` `oak_stairs[facing=north]` placed under rotation `CLOCKWISE_90` yields `facing=east` in the world,
   while `block_match` on a template stair compares against its unrotated file state.
7. **Block entities.** Placing a chest record with a `LootTable` and a seed in `nbt` replaces the seed with a draw from the `random` argument and loads
   the rest; two placements with the same seeded `random` and order give the same seeds.
8. **Liquids.** Example 11.10; with `IGNORE_WATERLOGGING` no fluid state is read and no pass runs.
9. **Entities.** An entity record is dropped when its transformed block position lies outside the settings box; the UUID is not reused.
10. **Template manager.** A template in `<world>/generated/<ns>/structure/<path>.nbt` overrides the data-pack file of the same id; a missing id yields an absent
    entry (cached) from `get` and an empty template from `getOrCreate`.
11. **Early exits.** `placeInWorld` returns false and writes nothing for: no palettes; empty block list with `ignoreEntities` true or no entities; any size component below 1 even when the block list is non-empty (section 5.1).
12. **Data pack coverage.** All 1511 shipped structure files load; all 40 processor lists parse with `DIRECT_CODEC` (both the object and the bare-array forms).

---

## 13. Open questions

1. (Closed: the `forAllFaces` pass order was read, section 5.5.1; number kept so references stay stable.)
2. The data-fixer upgrade for older structure files (`DataFixTypes.STRUCTURE`, base version 500) was not read; all shipped files are already at 5023, so it matters
   only for user-supplied or world-generated files.
3. `BlockState.rotate` and `BlockState.mirror` are per-block rules (24-x, block registry parts); this document uses them without restating them. Properties such as
   a jigsaw's `orientation` rotate by their own rule (31-6 section 8, 24).
4. `LiquidBlockContainer.placeLiquid` and the fluid cells' source tests are the fluid engine's (29a); only their use in sections 5.3 and 5.4 is specified here.
5. `Entity.rotate`, `Entity.mirror`, hanging-entity overrides and `EntityType.create` from NBT are entity-model topics (44, 45); sections 5.6 uses them as black boxes.
6. (Closed: `allowNbt` read, sections 6.2 and 9.6; number kept.)
7. (Closed: `Block.withPropertiesOf` and `Block.isShapeFullBlock` read, sections 9.9 and 9.7; number kept.)
8. (Closed: the entity `id` is present in the saved `nbt`, read from a shipped record, section 1.4; number kept.)
9. The jigsaw-assembly use of `getJigsaws`, `calculateConnectedPosition` and the per-pool-element settings (pivot, bounding box, processors) is 36-3.
10. Where each shipped processor list is referenced (which pool element or piece class uses `gravity`, `block_age`, `blackstone_replace`, `lava_submerged_block`,
    `jigsaw_replacement`, `block_ignore`) belongs to 36-3 and the per-structure parts.
11. `IntProvider.maxInclusive()` and `sample` (used by `capped`) are specified in 23 section 7.1; the exact value range of the `POSITIVE_CODEC` constraint was not
    re-read here.
12. Example 11.9 assumes the uniform provider draws `min + nextInt(max - min + 1)`; this is the form 23 section 7.1 gives, not re-read here.
13. The block-collection part of `fillFromWorld` (which positions are collected, the structure-void ignore list, how size and the block lists are filled) is specified in 31-6 section 6.3 only as the call (ignore list = `structure_void`, include-entities = not `ignoreEntities`); the inside of the collection loop was not re-read here. The `StructureProcessorList` direct codec (object versus bare array) is only stated in section 12; the shipped lists all use the object form (`processors` key, seen in `ancient_city_start_degradation`); the bare-array form was not exercised by data (a sample of the 41 listing entries was not exhaustively checked).
