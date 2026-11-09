# 22 Extraction tool and pack loaders

| Item | Value |
|---|---|
| Covers | The COBOL extraction tool that turns the user's vanilla 26.3 client jar into a generated vanilla **resource pack**, a generated vanilla **data pack** and three disabled feature data packs: what the jar contains (layout and format facts only), what is extracted and where, the exact `pack.mcmeta` of each pack, the version and SHA-256 check and what a mismatch does, regeneration, verification, the tool's inputs, outputs, algorithm steps, exit codes and messages; and the loaders: how the server and the client find, validate and order the generated packs and the user's packs (Faithful), what each world type needs, and the behaviour without the jar or without the generated packs |
| Does not cover | Rows of the data (assets, recipes, loot tables, tags, registry JSON, worldgen JSON, structure NBT): the tool copies them and the documents do not list them. The engines that interpret the data (registry loading and codecs, tag resolution, loot, recipes, worldgen, models): documents 04, 08, 10 to 21 and the later research documents. Sounds (section 10) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, 41,483,720 bytes (already recorded in [README.md](README.md); version 26.3, protocol 777, world data version 5023) |
| Second artifact (layout facts only) | `Faithful 32x - 26.3.zip`, SHA-256 `596035002e8c369ca673b5b922cd532a38a2aaabe80f317f5ac4d5c7680c7bf2` (already recorded in README.md). Read only for its zip structure and for which asset kinds it ships, to specify the user-pack loader in section 8 |
| Method | Static reading, with no execution: the zip central directory, local headers and end record of both archives were read as bytes; `unzip -Z1` and `unzip -Z` listings (files counted with `grep -v '/$'`, never from an `unzip -l` total); `version.json`, `pack.mcmeta` files, a few JSON data files and every PNG header were read as data; `javap -c -p -constants` on the pack-source classes to see how the game itself describes its built-in packs |
| Status | Written by the reader for round RS1 (GAP-32 of [../design/README.md](../design/README.md)), operator decisions "Vanilla assets and data", "Own world type" and "Resource pack" in `tickets/CC-0001-client-polish.md` |

Class names in backticks say where a fact was read. They are not the design. Section references use the form "08 §3.1".
Statements about CobolCraft's own choices (names of folders, exit codes, message texts) are **design** and are marked
"(design)"; everything else in sections 2 and 3 was read from the artifacts in this round. "(inferred)" marks a deduction
and "(recalled, not verified)" marks something not read; both are listed in the Open questions.

Other documents: 04 §2 (known packs and omitted entry data), 08 (pack format, stack order, built-in cobolcraft pack),
13 §7 and §8 (`options.txt`, the pack screen), 14 (textures, atlases, fonts). Documents that interpret what this tool
produces or that share its numbering: 46 (how the numeric id of a static registry entry is assigned, which is not read from the
extracted data), 24 (the block registry in eight parts: block ids and block state ids come from the registry model, not from
`blockstates/` files), 33 (world simulation), 41 (item entity physics) and 44 (residual mob questions). The registry-loading
document now exists as 23 (it cites section 8 of this document for the stack). Planned and not yet existing: the world-types document (RS2), cited by name until it exists. Cross-references to sections of this document are written
"section N.N" in prose and "N.N" in parentheses inside tables; other documents are cited "NN §x".

---

## 1. Purpose and the data/code split

The standard world type is Minecraft 26.3 content (08 §1.6). Its **data** (models, block states, item definitions,
atlases, language, textures, fonts, particle and equipment definitions; recipes, loot tables, tags, registry entries,
worldgen JSON, structure NBT, advancements, villager trades) is shipped inside the user's own client jar. CobolCraft
never commits, bundles or lists it. A separate COBOL program, the **extraction tool**, runs on the user's machine,
reads the jar, and writes two directories that are valid packs in the format of 08. The game then loads those packs
like any other pack.

What the tool does **not** produce: anything that is code in the jar (class files). The block and item registries
and their numbering (the block registry is document 24; the numeric ids of the static registries are document 46: none of them is read from the
extracted files), entity types, shapes, the light engine, fluids, redstone, block entities, menus, feature and
structure algorithms and the data interpreters are specified by the clean-room documents, not extracted.

Principle II is respected as follows: the tool is written from this document; its author never reads the jar. The tool
reads the jar at run time, as the user's own program on the user's own machine.

---

## 2. What the jar contains (facts read)

### 2.1 Archive container

| Fact | Value |
|---|---|
| Size | 41,483,720 bytes |
| End of central directory record | Signature `PK 05 06` at offset size − 22 (the record is 22 bytes: the archive has no comment). Disk number 0, central-directory disk 0, entries on this disk 34,227, total entries 34,227, central directory size 3,557,113 bytes, central directory offset 37,926,585. No zip64 record and no zip64 marker value (no field is 0xFFFF or 0xFFFFFFFF) |
| Entries | 34,227 central records: **1,349 directory entries** (names end in `/`) and **32,878 files** |
| Compression | Every one of the 34,227 entries uses method **8 (deflate)**, "normal" deflate, general-purpose flags `0x0808` (bit 3: sizes and CRC follow the data in a data descriptor; bit 11: names are UTF-8). Not encrypted. No extra field (length 0) and no file comment on any entry. "Version needed" 2.0 |
| Local headers | Signature `PK 03 04`; in every local header the CRC and both sizes are **0** (bit 3), so the sizes and the CRC must come from the **central directory**. The data starts at: local header offset + 30 + the name length and extra length **read from the local header itself**. A 16-byte data descriptor (signature `PK 07 08`, CRC, compressed size, uncompressed size) follows the data |
| Empty files | A zero-length file is still deflated: compressed size 2 bytes (`03 00`), uncompressed size 0, CRC 0. Example: `assets/.mcassetsroot` |
| Entry order | Not sorted by name. The first central record is `META-INF/MANIFEST.MF`; `version.json` is central record index 27,459 (zero-based; record 27,460 of 34,227), about 80% in, with its central record at offset 40,829,200. After the first record come `MOJANGCS.SF`, `MOJANGCS.RSA`, the `META-INF/` directory entry and `META-INF/LICENSE`. The last record is `assets/minecraft/waypoint_style/default.json`. The tool's linear walk to `version.json` (C3) therefore reads about 80% of the directory first |
| Dates | 3 entries (the signature files `META-INF/MANIFEST.MF`, `.SF`, `.RSA`) carry the build time 2026-09-15 11:22; all other entries carry 1980-02-01 00:00 (DOS time zero) |
| Signing | `META-INF/MOJANGCS.SF` and `MOJANGCS.RSA` hold a jar signature. The tool does **not** verify it; the whole-file SHA-256 (4) is the integrity check. `META-INF/MANIFEST.MF` has `Manifest-Version: 1.0`, `Main-Class: net.minecraft.client.Main` and, per entry, a `Name:` line with a SHA-384 digest, so it lists assets by name. The tool ignores the manifest |
| Directory entries by prefix | `data/` 565, `net/` 530, `assets/` 209, `com/` 44, `META-INF/` 1: 1,349 in all (the figure above; a test can check the split) |

Under `assets/` and `data/` there is no duplicate name (also not when compared in lower case) and, for every file under
`assets/` and `data/`, only the characters `a-z 0-9 _ - . /`, no empty segment and no `.` or `..` segment. The longest
path under `assets/` or `data/` is 139 characters (a nested feature-pack file) and the deepest has 10 segments (98 paths; 6 more have 9 segments, of which 5 are in the `trade_rebalance` feature pack and 1 is `data/minecraft/worldgen/template_pool/bastion/units/stages/rot/stage_1.json`).
These are exactly the identifier rules of 08 §1.3 and §1.4.

### 2.2 Top level of the archive

| Prefix | Files | Used by the tool |
|---|---|---|
| `assets/` | 11,604 (11,603 under `assets/minecraft/` plus the empty marker `assets/.mcassetsroot`) | Yes: becomes the resource pack |
| `data/` | 9,884 (9,883 under `data/minecraft/` plus the empty marker `data/.mcassetsroot`) | Yes: becomes the data pack and the feature packs |
| `net/` | 10,737 (class files) | No (code) |
| `com/` | 646 (class files) | No (code) |
| `META-INF/` | 4: `MANIFEST.MF`, `MOJANGCS.SF`, `MOJANGCS.RSA`, `LICENSE` | No |
| `version.json` | 1 | Read, not copied: version and pack formats (2.3; 6.1 maps it to none) |
| `pack.png` | 1: a 128 x 128 8-bit RGB PNG, 11,851 bytes | Yes: copied as the icon of both generated packs |
| `flightrecorder-config.jfc` | 1 | No |

Only the namespace `minecraft` exists under both `assets/` and `data/`. **There is no `pack.mcmeta` at the root** and no
`pack.mcmeta` under `assets/`; the game builds the metadata of its built-in packs in memory (2.4). The two marker
files `.mcassetsroot` are zero bytes; the game uses them to find the archive root and they have no meaning in a pack.
The tool skips them.

### 2.3 `version.json`

A JSON object, 422 bytes, UTF-8, 4-space indent. Read as data (its CRC-32 is `68d6e8ca`):

| Key | Value in this jar | Required by the game's reader (`DetectedVersion`) |
|---|---|---|
| `id` | `"26.3"` | yes |
| `name` | `"26.3"` | yes |
| `world_version` | 5023 | yes |
| `series_id` | `"main"` | no (default `main`) |
| `protocol_version` | 777 | yes |
| `pack_version.resource_major` | 97 | yes |
| `pack_version.resource_minor` | 1 | yes |
| `pack_version.data_major` | 121 | yes |
| `pack_version.data_minor` | 0 | yes |
| `build_time` | `"2026-09-15T11:20:48+00:00"` | yes |
| `java_component`, `java_version` | `"java-runtime-epsilon"`, 25 | not read by `DetectedVersion` |
| `stable` | true | yes |
| `use_editor` | false | not read by `DetectedVersion` |

So the resource pack version is **97.1** and the data pack version is **121.0**, as 08 §2.1 already records.

### 2.4 How the game describes its own built-in packs

The built-in packs have no file in the jar. The client's `ClientPackSource` and the server's `ServerPacksSource` build their
metadata from the running version, as follows (this is what the generated `pack.mcmeta` files mirror, section 6.2):

| Fact | Client built-in pack (`vanilla`, resources) | Server built-in pack (`vanilla`, data) |
|---|---|---|
| Pack id and title key | `vanilla`, `resourcePack.vanilla.name` (English text "Default") | `vanilla`, `dataPack.vanilla.name` (English text "Default") |
| Description key and English text | `resourcePack.vanilla.description`: "The default look and feel of Minecraft" | `dataPack.vanilla.description`: "The default data for Minecraft" |
| Declared format range | from the running version's pack version: `[major.minor, major.2147483647]` (`PackFormat.minorRange`), that is 97.1 to 97.* | the same rule with the data version: 121.0 to 121.* |
| Selection config (required, default position, fixed) | required (true), BOTTOM, fixed (false) (read from `ClientPackSource`, field `VANILLA_SELECTION_CONFIG`) | not required, BOTTOM, not fixed (read from `ServerPacksSource`, field `VANILLA_SELECTION_CONFIG`) |
| Second selection config, for the other built-in packs of the same source | not required, TOP, not fixed: used by the other built-in client packs (`programmer_art`, `high_contrast`, which exist in code only) | not required, TOP, not fixed (`FEATURE_SELECTION_CONFIG`): applied by `createBuiltinPack` to built-in packs whose source is `PackSource.FEATURE`; the feature packs would sit at the top of the stack if enabled (8.3 level 2). The `ServerPacksSource` field `PACKS_DIR` (type `Identifier`, built as `minecraft:datapacks`) is a different thing: it is passed to the built-in-pack source as the in-jar directory of the built-in packs, which is the jar folder `data/minecraft/datapacks/` of 2.7 (read). The client twin `PACKS_DIR` is `minecraft:resourcepacks`, consistent with the jar having no such folder. The world folder name is read from elsewhere (8.3 level 3) |
| Namespaces exposed | `minecraft` and `realms` (no `realms` content is in the jar) | `minecraft` |

The jar also carries three built-in **feature data packs** as ordinary files under `data/minecraft/datapacks/`
(2.7). Other built-in client packs exist in code (`programmer_art`, `high_contrast`); their files are not in the jar
(no `programmer_art` or `high_contrast` directory exists under `assets/`, and the jar has no `resourcepacks/` folder).

**Conflict with document 08 (open cross-document defect).** The values above are read again in the fixing round: the client vanilla config is required (true), BOTTOM, fixed (false); the client built-in config and the server feature config are not required, TOP, not fixed; the server vanilla config is not required, BOTTOM, not fixed. 08 §3.1 (the paragraph "Typical resulting order") and 08 §10 (the sentence "required and fixed at BOTTOM, inferred") still state the client vanilla pack as fixed. This document cannot edit 08. **Request to the owner of 08:** replace both statements by "required, BOTTOM, not fixed" and replace the §10 inference by the read value (the move tests are in 8.1). Until 08 is corrected, a reader of 08 alone gets the wrong value; this is recorded as Open question 15. Section 8.1 below fixes both bottom packs on purpose (a CobolCraft choice, not the jar's behaviour).

### 2.5 `assets/minecraft/` layout

Counts are files, counted with `grep -v '/$'` on the entry list. The kinds and the documents that interpret them:

| Directory | Files | Kind | Interpreted by |
|---|---|---|---|
| `atlases/` | 12 | JSON atlas definitions (`blocks`, `items`, `gui`, `particles`, `paintings`, `celestials`, `chests`, `banner_patterns`, `shield_patterns`, `decorated_pot`, `shulker_boxes`, `map_decorations`) | 08 §7.3 |
| `blockstates/` | 1,288 | JSON block state files | 08 §4 |
| `models/block/`, `models/item/` | 2,883 and 1,309 (total 4,192) | JSON models | 08 §5 |
| `items/` | 1,658 | JSON item model definitions. The dispatch key is `type`, for example `"type": "minecraft:model"` (answers 08 Open question 3) | 08 §6 |
| `equipment/` | 45 | JSON equipment (armor and harness layer) definitions | 08 §8, 14 |
| `particles/` | 115 | JSON particle definitions | 08 §8 |
| `font/` | 7 | JSON font definitions: `default`, `alt`, `illageralt`, `uniform`, and `include/default`, `include/space`, `include/unifont` (the last has an empty provider list; the unifont data is not in the jar, 14 §10) | 14 §10 |
| `lang/` | 2 | `en_us.json` (8,559 keys, 546,577 bytes, the largest file under `assets/` and `data/`) and `deprecated.json` (two arrays, `removed` with 425 entries and `renamed` with 148). **No other language file is in the jar** | 08 §8, §10.8 |
| `textures/` | 4,182 | 3,964 PNG and 218 `.mcmeta` (each `.mcmeta` sits next to a PNG of the same name; none is orphaned) | 08 §7, 14 |
| `post_effect/` | 5 | JSON post-processing chains | not used by CobolCraft's renderer (inferred) |
| `shaders/` | 89: `core/` 63, `include/` 17, `post/` 9 | GLSL text (`.vsh` 30, `.fsh` 42, `.glsl` 17) | not used by CobolCraft's renderer (inferred) |
| `texts/` | 4 | `credits.json`, and the text files `end.txt`, `postcredits.txt`, `splashes.txt` (UTF-8, LF) | 13 (poem and credits screens, if built) |
| `waypoint_style/` | 2 | JSON | not used (inferred) |
| `gpu_warnlist.json`, `regional_compliancies.json` | 1 each | JSON | not used (inferred) |

Texture subdirectories (files, PNG plus `.mcmeta`): `block` 1,405; `entity` 759; `gui` 616; `item` 831; `particle` 301;
`trims` 76; `painting` 52; `map` 42; `mob_effect` 40; `misc` 20; `palettes` 17; `environment` 14; `font` 5 (`accented`, `ascii`, `ascii_sga`, `asciillager`, `nonlatin_european`); `colormap` 3;
`effect` 1. The `mcmeta` counts per subdirectory are `block` 105, `gui` 53, `trims` 36, `entity` 16, `misc` 7,
`particle` 1 (total 218).

**Directory structure facts for a validator** (read from the entry list):

| Fact | Value |
|---|---|
| Subfolders of `models/` | only `block/` and `item/` (4,192 files), no other |
| Files directly at the `assets/minecraft/` level | `gpu_warnlist.json` and `regional_compliancies.json`; every other file is in a subdirectory |
| Nesting under `textures/` | not flat: lookups must recurse. `gui/` has the subfolders `advancements` 6, `container` 26, `hanging_signs` 13, `presets` 1, `realms` 12, `signs` 13, `sprites` 522 (of which 53 are `.mcmeta`, all of the `gui` mcmeta count above) and `title` 12 (605 in subfolders plus 11 files of its own: 616). `entity/` has no file of its own: 576 files are one folder down (6 segments, counting `assets` as the first, for example `entity/<mob>/<name>.png`) and 183 are two folders down (7 segments, for example `entity/villager/profession/<name>.png`, `entity/villager/type/<name>.png`, `entity/equipment/<kind>/<name>.png`, `entity/zombie_villager/...`, `entity/conduit/...`). `gui/` has 11 files at 5 segments, 68 at 6, 351 at 7 and 186 at 8 |
| Nesting under `font/` | `font/include/` holds three files (`default.json`, `space.json`, `unifont.json`); this is depth 5 |
| Maximum depth under `assets/` | `gui/sprites/...` files reach 8 segments; the 10-segment maximum of 2.1 belongs to a nested feature-pack file (2.7) |

The assets total 6,195,583 bytes uncompressed (11,604 files).

### 2.6 `data/minecraft/` layout

The first path segment under `data/minecraft/` says what a file is. Counts are files. "Sync" marks the 32 registries of
04 §3 (all 32 have a directory here; the directory is the registry path of 04 §2 step "resource path
`data/<ns>/<registry path>/<entry>.json`").

| Directory | Files | Kind and role |
|---|---|---|
| `worldgen/biome` | 67 | JSON, Sync |
| `worldgen/block_state_provider` | 8 | JSON, Sync |
| `chat_type` | 7 | JSON, Sync |
| `trim_pattern`, `trim_material` | 18, 11 | JSON, Sync |
| `wolf_variant`, `wolf_sound_variant` | 9, 7 | JSON, Sync |
| `pig_variant`, `pig_sound_variant` | 3, 3 | JSON, Sync |
| `frog_variant` | 3 | JSON, Sync |
| `cat_variant`, `cat_sound_variant` | 11, 2 | JSON, Sync |
| `cow_variant`, `cow_sound_variant` | 3, 2 | JSON, Sync |
| `chicken_variant`, `chicken_sound_variant` | 3, 2 | JSON, Sync |
| `zombie_nautilus_variant` | 2 | JSON, Sync |
| `painting_variant` | 51 | JSON, Sync |
| `sulfur_cube_archetype` | 12 | JSON, Sync |
| `dimension_type` | 4 | JSON, Sync |
| `damage_type` | 51 | JSON, Sync |
| `banner_pattern` | 43 | JSON, Sync |
| `enchantment` | 43 | JSON, Sync |
| `jukebox_song` | 22 | JSON, Sync |
| `instrument` | 8 | JSON, Sync |
| `test_environment`, `test_instance` | 1, 1 | JSON, Sync |
| `dialog` | 3 | JSON, Sync |
| `world_clock` | 2 | JSON, Sync |
| `timeline` | 4 | JSON, Sync |
| `decorated_pot_pattern` | 23 | JSON, Sync |
| `block_transformer` | 3 | JSON, Sync |
| `worldgen/` other registries | 1,144 in all under `worldgen/`, of which 75 are the two Sync ones above; the rest: `feature` 240, `placed_feature` 273, `template_pool` 245, `density_function` 55, `noise` 64, `noise_settings` 7, `carver` 4, `structure` 52, `structure_set` 21, `processor_list` 40, `material_condition` 8, `material_rule` 42, `world_preset` 7, `flat_level_generator_preset` 9, `multi_noise_biome_source_parameter_list` 2 | JSON, server-side registries (loaded by the registry loader, not synchronized) |
| `tags/` | 883 | JSON tag files, `tags/<registry path>/<tag path>.json`. Subdirectories (files): `block` 300, `item` 236, `worldgen` 123, `entity_type` 49, `damage_type` 36, `enchantment` 22, `villager_trade` 73, `banner_pattern` 11, `fluid` 10, `game_event` 5, `potion` 5, `dialog` 2, `instrument` 3, `painting_variant` 1, `point_of_interest_type` 3, `timeline` 4 |
| `loot_table/` | 1,447 | JSON. Subdirectories: `blocks` 1,201, `entities` 109, `chests` 58, `gameplay` 26, `shearing` 22, `archaeology` 6, `charged_creeper` 6, `spawners` 5, and 14 files in `barrels`, `brush`, `carve`, `dispensers`, `equipment`, `harvest`, `pots`, `till` |
| `recipe/` | 2,042 | JSON |
| `advancement/` | 1,866 | JSON (includes the recipe-unlock advancements) |
| `structure/` | 1,511 | **NBT**, `.nbt` (2.8). Subdirectories by structure family (`village` 483, `abandoned_camp` 297, `trial_chambers` 191, `bastion` 167, `trail_ruins` 84, `woodland_mansion` 73, `ancient_city` 58, `underwater_ruin` 48, and smaller ones, plus `empty.nbt` at the top) |
| `villager_trade/`, `trade_set/` | 391, 68 | JSON |
| `enchantment_provider/` | 7 | JSON |
| `trial_spawner/` | 28 | JSON |
| `context_float_provider/`, `context_int_provider/` | 4, 26 | JSON |
| `predicate/` | 3 | JSON |
| `datapacks/` | 106 | Three nested feature packs (2.7) |

By extension, `data/` holds 8,369 `.json`, 1,511 `.nbt`, 3 `.mcmeta` and 1 `.mcassetsroot` (the total below). The 3 `.mcmeta` are the `pack.mcmeta` files of the feature packs (2.7) and no other `.mcmeta` exists under `data/`; every `.json` is under one of the directories of the table above or under the feature packs.

All of `data/` is 9,884 files and 9,822,164 bytes uncompressed. The directory names are the singular forms above
(`recipe`, `loot_table`, `advancement`, `structure`, `tags/block`), taken from this jar. Older documentation of the
game may use plural names; this jar's names win.

Registries and data folders the jar does **not** contain are the ones the game defines in code (for example the static
registries of 04 §5). There is no `data/minecraft/dimension` folder: the dimensions come from the `world_preset` files and
code (RS2 and RS3 specify this).

### 2.7 The nested feature packs

`data/minecraft/datapacks/` holds three complete data packs, laid out as ordinary packs below their folder:

| Folder | Files | Contents |
|---|---|---|
| `minecart_improvements/` | 1 | `pack.mcmeta` only |
| `redstone_experiments/` | 1 | `pack.mcmeta` only |
| `trade_rebalance/` | 104 | `pack.mcmeta` and 103 files under `data/minecraft/` (loot tables, tags, villager trades) |

Depth (segments of the jar path, `data` counted as the first): the three `pack.mcmeta` files are at depth 5 (`data/minecraft/datapacks/<name>/pack.mcmeta`); the 103 data files of `trade_rebalance` are 5 files at depth 9 and 98 files at depth 10 (within the feature pack; jar-wide the depth-9 count is 6, 2.1), the deepest paths in the jar under `assets/` and `data/`. The jar-wide count of 10 segments in 2.1 is this depth.

Each `pack.mcmeta` has the keys `features` (with `enabled`: one flag, `minecraft:minecart_improvements`,
`minecraft:redstone_experiments` or `minecraft:trade_rebalance`) and `pack` (`description` as a translate component
`dataPack.<name>.description`, `min_format` 121, `max_format` 121), two-space indent, keys in alphabetical order. They show the
form the game itself reads for a data pack. The texts are "Improved movement for Minecarts", "Experimental Redstone changes"
and "Updated trades for Villagers"; their titles are "Minecart Improvements", "Redstone Experiments" and "Villager Trade
Rebalance" (`en_us.json`). The game enables them only by feature flag (08 §2.6).

### 2.8 File kinds and encodings

| Kind | Facts |
|---|---|
| JSON (`.json`, `.mcmeta`) | 15,919 files under `assets/` and `data/` (7,329 + 8,369 `.json`, 218 + 3 `.mcmeta`). All parse as JSON, all are UTF-8, none has a byte-order mark, none contains a carriage return. Two contain non-ASCII bytes (`texts/credits.json`, `lang/en_us.json`). 692 end with a newline and 15,227 do not. Most use a 2-space indent; some (`version.json`, the font files) use 4 |
| PNG | 3,964 under `assets/` (plus `pack.png`). None is interlaced; none has 16-bit samples. Bit depth and colour type counts: 1-bit gray 6, 1-bit palette 15, 2-bit gray 5, 2-bit palette 116, 4-bit gray 1, 4-bit palette 737, 8-bit gray 176, 8-bit RGB 132, 8-bit palette 1,828, 8-bit gray with alpha 401, 8-bit RGBA 547. Palette images: 2,696 (all have a `PLTE` chunk). A `tRNS` chunk is present in 2,102 files (1,966 palette, 128 gray, 8 RGB). The only chunk types are `IHDR`, `PLTE`, `tRNS`, `IDAT`, `IEND`. Largest side 1,024, reached by **three** files: `textures/block/water_flow.png` (32 x 1,024), `textures/gui/title/minceraft.png` (1,024 x 256) and `textures/gui/title/minecraft.png` (1,024 x 256); files with a side of 512 or more are rare (19, those three included) |
| NBT | 1,511 `.nbt` files, all under `data/minecraft/structure/`. Every file starts with the gzip magic `1F 8B` (gzip-compressed NBT) and the first decompressed byte is 10 (a compound), so they are in the file format of 07 §1 (not the network format of 00) |
| Text | 3 `.txt` under `assets/minecraft/texts/` (UTF-8, LF), 89 shader files, 17 `.glsl` |
| Marker | 2 empty `.mcassetsroot` |

The tool copies every file **byte for byte**. It never parses, reformats or re-encodes a JSON, PNG or NBT file.

### 2.9 What the jar does not contain

| Absent | Consequence |
|---|---|
| **Any sound**: no `.ogg`, no `sounds.json`, no `assets/minecraft/sounds*` path (the check is on `assets/` only: the only matches of "sound" or "music" there are 70 `music_disc*` item textures and models, plus `gui/sprites/icon/music_notes.png` and its `.mcmeta`; under `data/` 23 file names contain "sound", for example the three `tags/block/triggers_ambient_*_block_sounds.json` files, so a validator must not flag them) | There is nothing to extract and nothing for the tool to leave out. The game's sound files and sound index are not in the client jar (inferred: they are separate downloads of the launcher, recalled, not verified). Sounds stay out of scope (design README decision 17) |
| Any language other than `en_us` | The generated pack is English only (14 and 08 §8 already assume `en_us`) |
| The unifont glyph data | Characters not covered by the bitmap sheets have no glyph (14 §10) |
| `pack.mcmeta`, at any level | The tool writes it (6.2) |
| Any `pack.png` other than the root one | The root `pack.png` is reused for both packs |

---

## 3. The second artifact: Faithful (user-pack facts)

`Faithful 32x - 26.3.zip` is the kind of user pack the loaders must accept (08 §1.1). Facts relevant here:

| Fact | Value |
|---|---|
| Container | 13,116,019 bytes; end record at size − 22; 5,300 entries; central directory 668,927 bytes at offset 12,447,070; no zip64 marker |
| Methods | **Mixed**: 3,075 entries deflated (8) and 2,225 stored (0, which includes the directory entries). General-purpose flags are 0 on every entry (no data descriptor, no UTF-8 flag) |
| Extra fields | Every entry has a non-empty extra field in its central record, so the data offset must come from the local header's own name and extra lengths, never from the central record |
| Root | `pack.mcmeta`, `pack.png`, `LICENSE.txt` (an upper-case name in a non-asset position: allowed, only `assets/` and `data/` paths are checked) |
| `pack.mcmeta` | `pack.description` is a plain string; `pack.min_format` 84; `pack.max_format` 97 (integers: 84.0 to 97.*, which contains 97.1; a major above 64 needs no `pack_format`, 08 §2.3) |
| Namespaces | `assets/minecraft` (5,035 files), and `fabric` (1 file), `forge`, `modmenu` and `neoforge` (9 files each). They are valid namespaces (08 §1.3) that nothing in CobolCraft references |
| Kinds under `assets/minecraft/` | `textures` 4,137 files, `optifine` 897 files (ignored), `models` 1 (`models/item/redstone_torch.json`). **No** `blockstates`, `atlases`, `lang`, `items`, `font`, `equipment` or `particles` |
| Overlap with the jar | Of the 3,964 jar PNGs under `assets/minecraft/`, 3,901 also exist in Faithful (same path) and 63 do not; Faithful adds 889 PNG paths that the jar does not have |

So, stacked on the generated resource pack, Faithful replaces 3,901 textures by path and one model, and every
other asset kind (block states, atlases, item definitions, language, fonts) comes from the generated pack through the merge
rules of 08 §3.2.

---

## 4. Accepted jars and the checks

### 4.1 The accepted-jar table

The tool and the game carry a table of accepted jars, defined by this document and by the README's "Source artifact" row.
(design) A new row is added only by a clean-room round for that jar. Today the table has one row:

| Version id | Size (bytes) | SHA-256 | `world_version` | `protocol_version` | Resource format | Data format |
|---|---|---|---|---|---|---|
| `26.3` | 41,483,720 | `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` | 5023 | 777 | 97.1 | 121.0 |

(design) Only a jar whose SHA-256 is in the table is accepted. There is no switch to accept an unknown jar (Open
question 1). The reason is that the engines of documents 04 and 10 to 21 were specified from this exact artifact; a
different build can differ in data format and registry numbering without any sign in its file names.

### 4.2 The check, in order

The check is a linear sequence of five steps (C1 to C5). It runs after the end record has been parsed (7.3 steps 1 and 2),
because C3 needs the central directory. C1 and C2 are 7.3 step 3; C3 to C5 are 7.3 step 4.

| Step | Action | Result |
|---|---|---|
| C1 | **Size.** Read the file size and compare it with the size of every table row | `size-known` if it equals a row's size, otherwise `size-unknown`. This result does not stop anything; it is combined in C4 |
| C2 | **SHA-256.** Read the whole file in blocks and compute SHA-256 (FIPS 180-4). The 41 MB file is read once for this and again for the extraction. The digest is shown in lower-case hex | `digest-known` if it equals a row's digest, otherwise `digest-unknown`. Always computed, whatever C1 said, because the messages need it |
| C3 | **Read `version.json`, whatever the outcome of C1 and C2.** Walk the central directory until the record named exactly `version.json` and read that one entry (record parsing and entry reading as in 7.3 step 7, substeps 1, 6 and 7; nothing is extracted to disk). Parse the keys of 2.3 | the `id` string, or `unknown` when the entry is missing, damaged or has no valid `id` |
| C4 | **Decide.** Identified jar: C1 is `size-known` and C2 is `digest-known` for the same row. Then go to C5. Otherwise fail, writing nothing and leaving an existing generated directory untouched, with the code of the table below | see the table below |
| C5 | **Cross-check after a match.** `id`, `world_version`, `protocol_version` and the four pack-version numbers of C3 must equal the identified row (they do for 26.3). A difference, a missing entry or an invalid file is a table error | CCX-045 |

Failure code of C4:

| C1 size | C2 digest | `id` of C3 is in the table | Code | Meaning |
|---|---|---|---|---|
| known | known | (not reached: the jar is identified) | none | go to C5 |
| unknown | unknown | yes | CCX-031 | the jar says it is a supported version but it is another build or damaged (size wrong, id known) |
| known | unknown | yes | CCX-031 | the size is right but the digest is wrong (digest wrong, id known) |
| unknown or known | unknown | no (any other id, or `unknown`) | CCX-030 | the jar is not a supported version (id unknown) |
| unknown | known | any | CCX-031 | cannot happen for a real file (a digest is only equal if the size is); treated as a damaged table (design) |

CCX-045 is raised only from C5 or from the totals check of 7.3 step 8, never from C4.

---

## 5. Where things live (design)

### 5.1 Directories

| Name | Meaning | Default |
|---|---|---|
| Game directory | The directory of `options.txt` for the client (13 §7). For the server it is the server's working directory (the directory of its configuration file) | as today |
| Generated directory | The root of everything the tool writes | `<game directory>/generated` |
| Jar path | Where the user keeps the jar. The tool never copies or moves it | none; searched as in 7.1 |

The generated directory may be overridden on the tool's command line, on the client's command line and in the server
configuration (names are chosen by the CLI and configuration documents; FR-009 owns the server key; this document calls it
"generated directory"). When the client and a server run on one machine they may share one generated directory.

The generated directory is **not** the pack folder `resourcepacks/` (13 §8): packs in `resourcepacks/` are the user's, are
listed as `file/<name>`, can be disabled and reordered. The generated pack must stay below them and cannot be disabled
(section 8.1). The folder `generated/` (and any other directory the user picks) must be ignored by git; this document
cannot edit `.gitignore` (Open question 8). The operator's existing `tmp/` folder is already ignored (`/tmp/` in `.gitignore`), so
`--game-dir tmp/game` is a safe development choice.

### 5.2 Tree written by the tool

```
<generated>/
  .cobolcraft-generated           marker file (section 7.5, empty)
  manifest.txt                    6.4
  index.txt                       6.5
  vanilla-resources/              the resource pack, id "vanilla"
    pack.mcmeta                   6.2
    pack.png                      the jar's pack.png
    assets/minecraft/...          the jar's assets/minecraft/..., 11,603 files
  vanilla-data/                   the data pack, id "vanilla"
    pack.mcmeta                   6.2
    pack.png                      the jar's pack.png
    data/minecraft/...            the jar's data/minecraft/... except datapacks/, 9,777 files
  featurepacks/
    minecart_improvements/        pack.mcmeta (the jar's file, verbatim)
    redstone_experiments/         pack.mcmeta (the jar's file, verbatim)
    trade_rebalance/              pack.mcmeta + data/minecraft/... (103 files)
```

Folder names are fixed (design). The two pack folders are directory packs in the sense of 08 §1.1 (a directory with a
`pack.mcmeta`), so they need no archive writer.

---

## 6. What is extracted

### 6.1 Selection and path mapping

For each file entry of the jar (directory entries are ignored; directories are created when a file needs them):

| Jar path | Output path under `<generated>/` | Notes |
|---|---|---|
| `assets/.mcassetsroot`, `data/.mcassetsroot` | none | skipped |
| `assets/<rest>` | `vanilla-resources/assets/<rest>` | verbatim |
| `data/minecraft/datapacks/<name>/pack.mcmeta` | `featurepacks/<name>/pack.mcmeta` | verbatim |
| `data/minecraft/datapacks/<name>/data/<rest>` | `featurepacks/<name>/data/<rest>` | verbatim |
| `data/minecraft/datapacks/<anything else>` | none | none exists in 26.3; if a file appears, the tool fails with CCX-043 rather than guess |
| `data/<rest>` (any other) | `vanilla-data/data/<rest>` | verbatim |
| `pack.png` | `vanilla-resources/pack.png` **and** `vanilla-data/pack.png` | verbatim, written twice |
| `version.json` | none | read for the checks only. The manifest records its numbers |
| everything else (`net/`, `com/`, `META-INF/`, `flightrecorder-config.jfc`) | none | not extracted: code and signatures |
| `pack.mcmeta` of the two generated packs | `vanilla-resources/pack.mcmeta`, `vanilla-data/pack.mcmeta` | **written by the tool**, 6.2 |

Counts after a successful run on the accepted 26.3 jar (the validation numbers of section 12):

| Output | Files | Directories (excluding the root of the pack) |
|---|---|---|
| `vanilla-resources/` | 11,605 (11,603 jar files, `pack.mcmeta`, `pack.png`) | 209 (all below `assets/`) |
| `vanilla-data/` | 9,779 (9,777 jar files, `pack.mcmeta`, `pack.png`) | 539 (all below `data/`) |
| `featurepacks/` | 106 (103 data files, 3 `pack.mcmeta`) | 22 (all in `trade_rebalance/data/`) |
| Payload total | **21,490** | 770 |
| plus tool files | `manifest.txt`, `index.txt`, the marker | |

Directory counts include every ancestor below the pack's own root (`assets`, `assets/minecraft`, and so on).
The payload is 16,041,701 bytes (about 16 MB), computed from the jar's central records: 6,195,583 bytes from `assets/` (the empty
marker adds nothing), 9,713,315 bytes from `data/` outside `datapacks/`, 108,849 bytes in the feature packs (their three
`pack.mcmeta` files included), two copies of `pack.png` (11,851 bytes each) and the two generated `pack.mcmeta` files (129 and 123 bytes). The index
adds about 1.8 MB (inferred from the path lengths).

(Why the data pack is not cut down: the data of the jar is the complete generated output of the game, and a vanilla client
validates against it (design README R8, C14). Trimming rows would silently diverge.)

### 6.2 `pack.mcmeta` of the generated packs

Both files are written by the tool as UTF-8, LF line ends, two-space indent, one trailing newline, keys in the order shown.
The numbers come from the identified table row (which equals `version.json`): the resource pack uses `resource_major` and
`resource_minor`, the data pack uses `data_major` and `data_minor`. The rule for the format keys is the one the game applies to
its own built-in packs (2.4): the range is from the version's own `major.minor` up to the end of its major. In the notation of 08
§2.1, `min_format` is the two-element array `[major, minor]` and `max_format` is the integer `major`. This is the only place where the tool writes an array where the files read use plain integers: the jar's three feature packs have `min_format` and `max_format` as integers (121 and 121) and Faithful uses integers (84 and 97). A test must not compare the generated `pack.mcmeta` with the form of those files.

`vanilla-resources/pack.mcmeta`, exact text (129 bytes, CRC-32 `c6f2b630`, computed from this text):

```
{
  "pack": {
    "description": "The default look and feel of Minecraft",
    "min_format": [97, 1],
    "max_format": 97
  }
}
```

`vanilla-data/pack.mcmeta`, exact text (123 bytes, CRC-32 `14f8038e`, computed from this text):

```
{
  "pack": {
    "description": "The default data for Minecraft",
    "min_format": [121, 0],
    "max_format": 121
  }
}
```

Notes: (1) `description` is a plain string, a valid text component (08 §2.2), chosen over a translate component so the
pack screen shows the text even if no language file is loaded. The two strings are the English texts of the game's own keys
(2.4). (2) `[121, 0]` and the plain integer `121` mean the same (08 §2.1); the array form is used for both packs so the tool has one
rule. (3) There is no `pack_format` or `supported_formats` (a major above 64 must not carry them, 08 §2.3), no `overlays`, no
`filter` and no `features` section. A generated pack therefore needs no feature flag. (4) The numbers in the text above are the
values for 26.3; the tool derives them, it does not hard-code the digits (the table row is the source).

The three feature packs keep the jar's own `pack.mcmeta` files byte for byte.

### 6.3 Regeneration rules

| Situation | What the tool does |
|---|---|
| Generated directory absent | Build it |
| Present, valid manifest, `jar-sha256` equal to the identified jar's, `format` equal to the tool's manifest format, and no `--force` | Do nothing. CCX-100 "up to date" and exit 0. (A quick check of the sentinel files, 8.2 steps 3 to 5, is also done; if one fails, rebuild) |
| Present, manifest missing, unparseable or from another manifest `format` | Rebuild |
| Present, manifest `jar-sha256` differs from the identified jar's | Rebuild (the user installed a newer accepted jar) |
| `--force` | Rebuild |
| `--verify` | Never rebuilds; checks the tree against `index.txt` (7.6) |

A rebuild always starts from nothing: the tool never merges into an existing generated directory, because a stale file
from an older build would otherwise survive. The old directory is removed only after the new one is complete (7.5). The tool
never reads or writes `resourcepacks/`, the world folders or `options.txt`. The game never runs the tool by itself; a menu
or launcher may start it and read its exit code (section 9).

### 6.4 `manifest.txt` (design)

UTF-8, LF, one `key=value` line per fact, keys in this order, no blank lines, written last of the content files. Example for
the accepted jar (the tool version string is the program's own):

```
format=1
tool=cobolcraft-extract 1
jar-version=26.3
jar-sha256=4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d
jar-size=41483720
world-version=5023
protocol-version=777
resource-format=97.1
data-format=121.0
files-resource=11605
files-data=9779
files-feature=106
files-total=21490
```

`format` is the manifest layout number (1). The game checks `format`, `jar-sha256`, `resource-format` and `data-format` (8.2).
A line that is missing or repeated makes the manifest invalid. Unknown extra keys after these are ignored (inferred, so a later
tool can append keys and an older game still starts).

### 6.5 `index.txt` (design)

One line per payload file in extraction order (the central directory order of the jar, which is not alphabetical), with the
fields separated by one space: CRC-32 as 8 lower-case hex digits, size in decimal bytes, and the path relative to the generated
directory. It does not list `manifest.txt`, `index.txt` or the marker. Both copies of `pack.png` and both generated
`pack.mcmeta` files are listed (the CRC-32 is computed on the bytes written). For `vanilla-resources/pack.mcmeta` for example:
`c6f2b630 129 vanilla-resources/pack.mcmeta`. The file has 21,490 lines for 26.3. It exists only for `--verify`; the game
does not read it.

---

## 7. The tool (design)

### 7.1 Inputs

| Input | Form | Rule |
|---|---|---|
| Jar | `--jar <path>` | If absent, the tool tries, in order, `<game directory>/minecraft-26.3-client.jar` and `<game directory>/client.jar` and, in the working directory, `minecraft-26.3-client.jar`. First regular file wins. None: CCX-010 |
| Game directory | `--game-dir <path>` | Default: the working directory |
| Generated directory | `--generated-dir <path>` | Default: `<game directory>/generated` |
| `--force` | flag | Section 6.3 |
| `--verify` | flag | Check only (7.6). Does not need the jar: it skips the whole of 7.3 (step 1, finding the jar, included) |
| `--dry-run` | flag | Do steps 1 to 5 of 7.3, then the walk of step 7 with substeps 1 to 4 (mapping and counting) and, to validate the entries, optionally 5 to 7. It creates no directory, writes no file (not the marker, not either `pack.mcmeta`, no index line, no `.partial` removal) and skips steps 6 and 8 to 10. It prints the counts of 6.1 (payload files per kind and the skipped count, which exist only after the walk). If the plan of step 5 is "do nothing" it prints CCX-100 and stops without a walk, unless `--force` is also given |
| `--quiet` | flag | Print only errors and the final line |

Unknown options or a missing value: CCX-001 and exit 1. The tool needs no network and reads no environment variable.

### 7.2 Platform services the tool needs

The tool is COBOL; these services must exist in the project's runtime (the shim or equivalent). This document does not say how
they are provided.

| Service | Requirement |
|---|---|
| File read at an offset | Read N bytes at a byte offset of a 41 MB file (all offsets fit in 31 bits, Open question 11) |
| Raw inflate | Decompress an RFC 1951 deflate stream (no zlib or gzip header) held in memory; the output size is known in advance from the central record. Must handle the 2-byte stream of an empty file |
| Stored entries | Methods 0 and 8 only, both needed by the user-pack loader (3), 8.4); the tool for the jar needs method 8 only |
| SHA-256 | Incremental over blocks, final digest as 32 bytes |
| CRC-32 | The zip CRC-32 (reflected, polynomial 0xEDB88320, initial and final xor 0xFFFFFFFF). Check value: the 9 bytes `123456789` give `cbf43926` (the standard check value) |
| Directory create, rename, recursive remove | `mkdir -p` semantics; rename of a directory within one volume; removal of a directory tree (or listing plus unlink plus rmdir) |
| Write a file | Create or truncate, write in blocks, close with an error status |

Working storage: the largest entry under `assets/` and `data/`, and so the largest that is extracted, is 546,577 bytes (`lang/en_us.json`), so a 1 MiB (1,048,576 bytes)
buffer suffices. An entry whose uncompressed size exceeds the buffer is CCX-041. The central directory (3.4 MB) is read
in blocks and processed record by record; no table of all entries is needed.

### 7.3 Algorithm, step by step

1. **Find the jar** (7.1). Read its size. If it is below 22 bytes: CCX-020.
2. **End record.** Read the last 22 bytes. If they do not start with `PK 05 06`, read back at most 65,535 + 22 bytes and search
   for the last `PK 05 06` (a comment is allowed by the format; the jar has none). Not found: CCX-020. Reject, with CCX-021, a
   record whose disk numbers are not 0, whose two entry counts differ, or that has any of its fields equal to 0xFFFF
   or 0xFFFFFFFF (zip64). Reject (CCX-020) a central directory that does not end exactly at the end record (offset +
   size ≠ end record offset).
3. **Size and digest** (section 4.2, C1 and C2). This reads the file once for the digest. It never stops by itself: the outcome is
   decided in step 4 after `version.json` has been read.
4. **`version.json`, then the decision.** Walk the central directory (record parsing as in step 7, substep 1) until the record
   named exactly `version.json`; extract it into the buffer (entry reading as in step 7, substeps 6 and 7); parse the JSON for the keys
   of 2.3 (a minimal reader is enough: the file is flat except `pack_version`). This is done for every jar, identified or not
   (4.2 C3). Then apply 4.2 C4: a jar that is not identified fails with CCX-030 or CCX-031 as the table of 4.2 says, with
   nothing written; an identified jar goes on to 4.2 C5 (compare with the table row; CCX-045 on a difference, a missing entry or an
   invalid file).
5. **Plan.** Decide the action from section 6.3. If "do nothing": print CCX-100 and exit 0. Otherwise, if the action is a build, run
   the **target check** of 7.5 now (before any work is done): if `<generated>` exists, is not empty and has no `.cobolcraft-generated`
   marker, stop with CCX-051 without having written anything. (`--dry-run` also runs this check and reports CCX-051.)
6. **Prepare.** Remove a leftover `<generated>.partial` directory (only if it contains the marker, 7.5). Create it with the
   marker file `.cobolcraft-generated`. Write `vanilla-resources/pack.mcmeta` and `vanilla-data/pack.mcmeta` (6.2) and record their
   index lines.
7. **Walk the central directory** from its first record to the last. For each record:
   1. Check the record signature `PK 01 02`. Read the flags, method, CRC-32, compressed size, uncompressed size, name length,
      extra length, comment length and the local header offset. Advance by 46 + the three lengths.
   2. Skip directory entries (name ends in `/`).
   3. Map the name with the table of 6.1. If it maps to nothing, count it as skipped and continue. (The count of skipped
      entries on 26.3 is 11,391: 11,388 code and signature files (`net/` 10,737, `com/` 646, `META-INF/` 4, the `.jfc` file) plus
      `version.json` and the two markers. It is printed in the final line and is not checked.)
   4. Validate every segment of the output path against 08 §1.4 (lower case, `a-z 0-9 _ - .`, no empty, `.` or `..`
      segment; the namespace segment against 08 §1.3). Fail with CCX-043 on a violation. Reject a name with a byte above 127
      (CCX-043). A path that has already been written in this run: CCX-044.
   5. If bit 0 of the flags is set (encrypted), or the method is not 8: CCX-021.
   6. Read the 30-byte local header at the recorded offset. Check `PK 03 04`. Take its own name length and extra length. Compare
      the local name with the central name byte for byte (CCX-042 on a difference). The data starts at offset + 30 + name length
      + extra length.
   7. Read the compressed bytes (the central compressed size) and inflate them into the buffer. The inflated length must equal the
      central uncompressed size and the CRC-32 of the inflated bytes must equal the central CRC-32. Failures: CCX-041, CCX-040.
      A zero-length file inflates to nothing.
   8. Create missing parent directories under `<generated>.partial`, write the file, count it, append its index line. A write error:
      CCX-050.
   9. For `pack.png`, write the same bytes a second time to the other pack and index it too.
8. **Totals.** Compare the counts with the table row of 6.1 (21,490 payload files for 26.3). A different count means a table error:
   CCX-045. (For a jar added to the table later, the row carries its own counts.)
9. **Write `index.txt`, then `manifest.txt`** (6.4, 6.5).
10. **Swap** (7.5). Print the final line.

Progress output: one line per 1,000 files written (to standard output), unless `--quiet`.

### 7.3.1 Zip record layouts (read from the jar's bytes)

All integers are little-endian. Offsets are from the start of the record. Values in the last column were read from the jar's end record, first central record and its local header.

| Record | Size | Field offsets |
|---|---|---|
| End record `PK 05 06` | 22 + comment | +4 disk number (2), +6 disk of central directory (2), +8 entries on this disk (2), +10 total entries (2; 34,227), +12 central directory size (4; 3,557,113), +16 central directory offset (4; 37,926,585), +20 comment length (2; 0) |
| Central record `PK 01 02` | 46 + name + extra + comment | +4 version made by (2), +6 version needed (2; 20), +8 flags (2; 0x0808), +10 method (2; 8), +12 time (2), +14 date (2), +16 CRC-32 (4), +20 compressed size (4), +24 uncompressed size (4), +28 name length (2), +30 extra length (2), +32 comment length (2), +34 disk start (2), +36 internal attributes (2), +38 external attributes (4), +42 local header offset (4); the name starts at +46 |
| Local header `PK 03 04` | 30 + name + extra | +4 version (2), +6 flags (2), +8 method (2), +10 time (2), +12 date (2), +14 CRC-32 (4; 0 in the jar), +18 compressed size (4; 0 in the jar), +22 uncompressed size (4; 0 in the jar), +26 name length (2), +28 extra length (2); the name starts at +30 and the data at +30 + name length + extra length |

The central directory begins at the end record's offset and ends exactly at the end record (3,557,113 + 37,926,585 = 41,483,698, plus 22 = 41,483,720, the jar size). The manifest `Name:` list covers the entries the jar signature covers (2.1: it lists assets by name with a SHA-384 digest); the tool ignores it.

### 7.4 Exit codes and messages

Messages are English plain text on standard error (errors) or standard output (progress). Placeholders in angle brackets.
Every error line starts with its code. Nothing is written on a failure before step 6, including CCX-051 raised by the target check of step 5; on a later failure the `.partial`
directory is removed and the previous generated directory (if any) is untouched.

| Code | Exit | Text |
|---|---|---|
| CCX-001 | 1 | `CCX-001 usage: cobolcraft-extract [--jar <file>] [--game-dir <dir>] [--generated-dir <dir>] [--force] [--verify] [--dry-run] [--quiet]` |
| CCX-010 | 2 | `CCX-010 Cannot find the Minecraft client jar. Looked for: <list>. Pass --jar <file>.` |
| CCX-011 | 2 | `CCX-011 Cannot read <path>: <system message>.` |
| CCX-020 | 4 | `CCX-020 <path> is not a zip file this tool can read: <detail>.` (details: `too short`, `no end record`, `central directory does not match the end record`, `bad central record at entry <n>`) |
| CCX-021 | 4 | `CCX-021 <path> uses a zip feature this tool does not support: <feature>.` (`zip64`, `several disks`, `encrypted entry <name>`, `compression method <n> in entry <name>`) |
| CCX-030 | 3 | `CCX-030 This jar is not supported (Minecraft <id>, SHA-256 <hex>, <size> bytes). CobolCraft supports Minecraft <supported ids>. Nothing was written.` (`<id>` is `unknown` when `version.json` is missing) |
| CCX-031 | 3 | `CCX-031 This jar says it is Minecraft <id> but it is not the build CobolCraft was written for (SHA-256 <hex>, expected <hex>; size <size>, expected <size>). The file may be damaged or from another build. Nothing was written.` |
| CCX-040 | 4 | `CCX-040 Entry <name> is damaged: CRC-32 <hex>, expected <hex>.` |
| CCX-041 | 4 | `CCX-041 Entry <name> cannot be unpacked: <detail>.` (`bad deflate data`, `size <n> instead of <m>`, `larger than the 1048576-byte buffer`) |
| CCX-042 | 4 | `CCX-042 Entry <name> does not match its local header.` |
| CCX-043 | 4 | `CCX-043 Entry name <name> cannot become a pack path.` |
| CCX-044 | 4 | `CCX-044 Two entries map to <output path>.` |
| CCX-045 | 4 | `CCX-045 version.json or the file counts do not match the table for this jar: <detail>.` |
| CCX-050 | 5 | `CCX-050 Cannot write <path>: <system message>.` |
| CCX-051 | 5 | `CCX-051 Refusing to replace <dir>: it was not made by this tool (no .cobolcraft-generated marker).` |
| CCX-060 | 6 | `CCX-060 Verification failed: <n> problems. First: <detail>.` (`missing <path>`, `size <a> instead of <b> in <path>`, `CRC-32 <a> instead of <b> in <path>`, `extra file <path>`, `manifest invalid: <detail>`) |
| CCX-100 | 0 | `CCX-100 Generated packs are up to date (Minecraft <id>, SHA-256 <hex>). Nothing to do. Use --force to rebuild.` |
| CCX-101 | 0 | final line after a build: `CCX-101 Wrote <r> resource files, <d> data files and <f> feature-pack files (<n> bytes) to <dir>. Skipped <s> jar entries (code, signatures, markers).` |
| CCX-102 | 0 | `CCX-102 Verified <n> files in <dir>.` |

Exit code 0 is success (including "up to date" and a successful verify). The codes 2 to 6 are stable so a launcher can map them to
screens.

### 7.5 Atomic replacement and the safety rule

0. **Target check at the plan step** (7.3 step 5): if `<generated>` exists, check that it is empty or contains the marker
   `.cobolcraft-generated`; otherwise stop with CCX-051 before anything is written, so the user does not wait for a 16 MB build
   to learn that the directory is not allowed.
1. Build in `<generated>.partial` (same parent, same volume).
2. **Target check again at the swap**, after the manifest is written: the same test. It is still needed because the directory may
   have changed during the build (a race, for example the user created files in it or replaced it). Failing it stops with CCX-051 and removes
   the partial directory. Together, 0 and 2 mean the tool can never delete a directory the user pointed it at by mistake.
3. Remove `<generated>`.
4. Rename `<generated>.partial` to `<generated>`.

An interruption between 3 and 4 leaves no `<generated>`, which every loader treats as "not generated" (8.2). An interruption
before 3 leaves the old directory intact and a `.partial` that the next run removes (7.3 step 6). `manifest.txt` is the last
file written inside the partial directory, so a directory without it is incomplete.

### 7.6 `--verify`

Does not need the jar. Steps: read `manifest.txt` (CCX-060 if missing or invalid); read `index.txt`; for each line check that the
file exists, has the size and, by reading it, the CRC-32 (this reads 16 MB); then walk the tree and count files other than the
three tool files: the count must equal `files-total` and every file must have been listed (extra file: CCX-060). Also check
that the two `pack.mcmeta` texts are what 6.2 gives for the manifest's `resource-format` and `data-format`. Print CCX-102 on
success.

---

## 8. Loaders (design)

### 8.1 Generated resource pack in the client's pack repository

The client's pack repository (08 §3.1, 13 §8) gets two built-in required packs below all user packs:

| Pack id | Title | Source label | Origin | Selection (required, default position, fixed) |
|---|---|---|---|---|
| `cobolcraft` | "CobolCraft" | built-in | the built-in pack of the cobolcraft world type (08 §10) | required, BOTTOM, **fixed** |
| `vanilla` | "Default" (the vanilla English title) | built-in | the directory `<generated>/vanilla-resources`, when it passes the check of 8.2 | required, BOTTOM, **fixed** |

Fixed position is a CobolCraft choice. The jar's own client pack is required and BOTTOM but not fixed (2.4; 08 §3.1 and §10 say fixed and need the correction named there). In the jar's pack screen model the move-up and move-down tests of an entry look only at the fixed flag of the neighbouring pack in the selected list; the required flag matters only for toggling selection (an entry is deselectable only if selected and not required). So a required, non-fixed pack such as the jar's own vanilla pack can be moved in vanilla. That is why CobolCraft fixes both bottom packs: without it the player could move a user pack below `vanilla` or `cobolcraft` and break the stack order of the design README (C7). (Read: the two tests consult the neighbour only, not the entry's own flag; where fixed entries get their move buttons is not read here.) With 08 §3.1's rule (required packs are
added in pack id order, each BOTTOM insertion goes above the packs already fixed at the bottom), `cobolcraft` is added first and `vanilla` ends above it.

Resulting stack, bottom to top, for the client:

| Level | Pack | Present when |
|---|---|---|
| 1 | `cobolcraft` (built-in) | always |
| 2 | `vanilla` (generated resource pack) | the generated pack check is `ok` |
| 3 | user packs in the order of `resourcePacks` in `options.txt` | enabled by the player; folder `<game directory>/resourcepacks/` (13 §8) |
| 4 | server-pushed packs | the server sent them (08 §9.6) |

Faithful lives at level 3. It is **never enabled automatically**: it appears in the Available list as `file/Faithful 32x - 26.3.zip`
and the player enables it, as the ticket's story says (CC-0001 Resource pack). `options.txt` keeps the stored ids lowest
first, for example `resourcePacks:["vanilla","file/Faithful 32x - 26.3.zip"]` (13 §7.1); the required packs are re-added on every
load (08 §3.1, 13 §8 "Loading at startup"), so their presence in that list is not needed.

The generated pack is a directory pack: the client reads files by path from the directory, as for any folder pack (08 §1.1). It
shows the icon `pack.png` and the description of 6.2. It is compatible with the running version, because 97.1 is inside the
declared range (97.1 to 97.*).

Reloading: the client re-reads the generated pack whenever it reloads resources (13 §8). It does not watch the generated
directory. After the tool has rebuilt it, the player restarts or presses the reload key.

### 8.2 The generated-pack check ("valid generated packs")

Run by the client at start-up and when it reloads, and by the server at start-up and before it creates or loads a standard world. It does not
read the jar and does not hash anything. Inputs: the generated directory and the compiled-in accepted-jar table (4.1). Steps:

1. If `<generated>` is not a directory: result `absent`.
2. Read `<generated>/manifest.txt` (a few hundred bytes). Missing: `absent` if the tool's marker is also missing, otherwise
   `incomplete`. Invalid (a key missing, repeated, out of order, or a value that does not parse): `damaged`.
3. `format` must be 1; `jar-sha256` must equal the SHA-256 of an accepted-jar row and `jar-version`, `jar-size`, `world-version`,
   `protocol-version`, `resource-format` and `data-format` must equal that row's. Otherwise `stale`.
4. The resource sentinels exist: `vanilla-resources/pack.mcmeta`, `vanilla-resources/assets/minecraft/lang/en_us.json`,
   `vanilla-resources/assets/minecraft/atlases/blocks.json`, `vanilla-resources/assets/minecraft/textures/misc/unknown_pack.png`.
5. The data sentinels exist: `vanilla-data/pack.mcmeta`, `vanilla-data/data/minecraft/worldgen/biome/plains.json` (the fallback
   biome of 04 §3.2), `vanilla-data/data/minecraft/dimension_type/overworld.json`,
   `vanilla-data/data/minecraft/damage_type/generic.json`, `vanilla-data/data/minecraft/recipe/stick.json`. Any sentinel missing: `damaged`.
6. Otherwise `ok`.

The two results the callers need are `ok` or "not ok" with the reason word (`absent`, `incomplete`, `stale`, `damaged`) for the
message of 9.2. The full integrity check is the tool's `--verify`; the game does not run it (it would read 16 MB).

### 8.3 Server: data packs

For a **standard** world the server builds a data pack stack, bottom to top:

| Level | Pack | Notes |
|---|---|---|
| 1 | `vanilla` = `<generated>/vanilla-data` | required for standard worlds; the check of 8.2 must be `ok` |
| 2 | feature packs from `<generated>/featurepacks/<name>` | **not loaded in this version**: each needs its feature flag (08 §2.6); none is enabled by default, and no setting enables one (Open question 5). If one were enabled, the feature-pack config of 2.4 (not required, TOP, not fixed, applied to built-in packs by their source `FEATURE`, not by the folder name) would put it at the top, so it would sit above `vanilla` (inferred; the effect on a stack was not traced); its place relative to user data packs is not read (inferred: user packs are added later and go above) |
| 3 | user data packs from `<world folder>/datapacks/` | optional; a directory with `pack.mcmeta` or a `.zip`, id `file/<name>`; same detection and format rules as 08 §1.1 to §2.3 against the data format 121.0 (the folder name is read: `LevelResource.DATAPACK_DIR` has the id `datapacks`, and the server's pack-repository factory that takes the level storage access builds the repository from the level path of that resource; the detection and format rules are inferred from the 13 §8 resource rules; the world folder document 07 §9 does not list the folder yet) |

The pack-level override rule is the one of 08 §3.2 applied to the data tree: files replace by path from the top pack down, and merged
kinds (tags) concatenate bottom to top (the tag document will define the tag merge). How the data is read once found (the
registry loader, codecs, tag resolution) is 23 §2 and §3.

For a **cobolcraft** world the data pack stack is empty at level 1: the cobolcraft world type's hand-authored core (design
README C3) is part of the game and is not read from a directory. The generated data pack is **not** read for a cobolcraft world, even when it exists.

### 8.4 Reading packs: the zip reader (client and server)

The client reads user packs in zip form (Faithful) and the server may read zipped data packs, so the game needs a zip reader that
the tool's reader of 7.3 is a subset of. Requirements, from the two archives read:

| Requirement | Reason |
|---|---|
| Find the end record by backward search | the jar has no comment, a user zip may |
| Central directory as the source of sizes, CRC and offset | the jar uses data descriptors (zero sizes in local headers) |
| Data start from the local header's own name and extra lengths | every Faithful entry has an extra field |
| Methods 0 (stored) and 8 (deflate) | Faithful mixes both; the jar uses 8 only |
| Flags: ignore bit 3 (descriptor) and bit 11 (names UTF-8 or unflagged ASCII) | both archives |
| Names: `/` separators; a name ending in `/` is a directory; entries are matched byte for byte, case sensitive | 08 §1.1, §1.4 |
| Reject zip64, several disks and encrypted entries with a clear pack error | none of the two archives needs them (a user pack that does is rejected with the pack marked unreadable) |

Random access is by central-directory name lookup: build a hash or sorted index of the names once per pack and open an entry
by seeking, instead of scanning. (The index of a 5,300-entry pack is small.)

### 8.5 Multiplayer and the single-player host

In multiplayer the client needs the **resource pack only**. It receives every registry entry and every tag over the network (04 §2:
the client's list of known packs is empty, so the server sends each entry with its data, 04 §2 "Guidance for an original server"),
so the client does not read the data pack. (This answers the "to be confirmed in RS1" note of the design README C8: confirmed
from 04 §2; the client never needs `vanilla-data`.) The server (or the single-player host, which is a server in the same process)
needs the data pack for a standard world.

Therefore: a dedicated server with a standard world needs a valid generated directory, and so needs the jar once. A client that only
joins servers needs the generated resource pack for the standard look; without it the client still joins (8.6, 9.2).

### 8.6 Behaviour matrix

| Situation | Client | Server and single-player host |
|---|---|---|
| Valid generated packs, jar not present | works fully. The jar is needed only to (re)generate | works fully. Standard and cobolcraft worlds both available |
| Generated packs `absent`, `incomplete`, `stale` or `damaged` | the cobolcraft built-in pack alone is used; `minecraft:` content with no asset is drawn with the engine's missing model and missing texture (08 §10, orange and black stripes). A banner on the title screen says why (9.2). Joining a server still works | standard worlds cannot be created or opened; cobolcraft worlds run on the built-in pack and the hand-authored core. A dedicated server configured for a standard world refuses to start with the message of 9.2 and a non-zero exit |
| Jar present but wrong version or SHA | nothing is generated (the tool refused, CCX-030 or CCX-031); same as `absent` | same as `absent` |
| Jar removed after a successful generation | no change | no change |
| A newer accepted jar installed later | the packs are `stale` only if the table no longer lists the old row (never, since rows are only added); the tool rebuilds when run with the new jar (6.3). The old packs keep working until then | same |

(The design README C10 and decision 2 say that "a missing or wrong jar disables the standard type". This document refines it: what matters
at run time is a valid generated directory, not the jar. See Open question 2.)

---

## 9. The cobolcraft world type, with and without the packs

### 9.1 What must run with no jar and no generated directory

The cobolcraft world type (08 §10, `../design/standin-content.md`, design README C3 and C11) must start, create a world, play and save with an empty
generated directory and with no `resourcepacks/` content. This is tested by section 12 test T8. That means the built-in `cobolcraft` pack
provides every texture, font glyph and `en_us` text the cobolcraft world needs, including the UI (design README C11, GAP-34). When the generated
pack is present too (level 2 of 8.1), the stack is the one of 8.1 for the cobolcraft world as well. The two namespaces do not collide (`cobolcraft:` against
`minecraft:`) except for the engine-vocabulary files of `minecraft:` that both packs may supply (language keys, 08 §3.2 merges; see Open question 3).

### 9.2 Messages the game shows (design)

These texts live in the **built-in pack's** `en_us` (not the generated pack's, which may not exist). Key names are proposals (inferred):

| Key | Text | Used when |
|---|---|---|
| `cobolcraft.packs.absent` | "Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds." | result `absent` |
| `cobolcraft.packs.incomplete` | "The Minecraft content is incomplete. Run the extraction tool again." | `incomplete` |
| `cobolcraft.packs.stale` | "The Minecraft content was made for another version. Run the extraction tool again." | `stale` |
| `cobolcraft.packs.damaged` | "The Minecraft content is damaged. Run the extraction tool with --force." | `damaged` |
| `cobolcraft.world_type.standard.unavailable` | "Standard worlds need the Minecraft content. See the title screen message." | the world-creation screen's standard choice disabled; opening a standard world |

A dedicated server prints the same texts (English, the console has no pack) followed by the tool's command line (`cobolcraft-extract --jar <file>`).

---

## 10. What is deliberately not extracted

| Item | Reason |
|---|---|
| Sounds | Decision 17 of the design README (spec 001 Assumptions): out of scope. The jar has none anyway (2.9). The sound event registry is static and is not data |
| Class files, `META-INF`, the signature, `flightrecorder-config.jfc` | Code and packaging. Principle II keeps code out of everyone's hands except the running user's own game |
| `.mcassetsroot` markers | No meaning in a pack |
| Shaders | They are extracted verbatim (`vanilla-resources/assets/minecraft/shaders/`) so that a user pack that overrides one still lines up with the vanilla layout, but CobolCraft's renderer does not read them (inferred; 12 describes its own rendering). Dropping the 89 files would cost no behaviour (Open question 6) |
| Other languages, unifont data, the sound index | Not in the jar |
| The jar itself | Never copied, moved or modified |

---

## 11. Worked examples

**E1: reading `version.json` from the jar bytes.** The end record is at offset 41,483,698 (size 41,483,720 − 22) and says: 34,227
entries, central directory 3,557,113 bytes at 37,926,585 (37,926,585 + 3,557,113 = 41,483,698, the end record offset: consistent).
The central record of `version.json` is at offset 40,829,200 and says: flags `0x0808`, method 8, CRC-32 `68d6e8ca`, compressed size 212,
uncompressed size 422, local header at offset 36,581,098. The local header at 36,581,098 starts with `50 4B 03 04`, has name length 12 and
extra length 0 and zero sizes; the data starts at 36,581,098 + 30 + 12 + 0 = 36,581,140 and runs 212 bytes; the 4 bytes that follow are
`50 4B 07 08` (the data descriptor). Inflating gives 422 bytes whose CRC-32 is `68d6e8ca`.

**E2: an empty file.** `assets/.mcassetsroot`: method 8, compressed size 2, uncompressed size 0, CRC-32 `00000000`, local
header at 14,392,402, name length 20, data at 14,392,452 (bytes `03 00`). The tool counts it as skipped (6.1) and does not write it.

**E3: mapping.** `assets/minecraft/blockstates/stone.json` (central record at 40,930,766; compressed 101, uncompressed 324,
CRC-32 `591efe86`) is written to `<generated>/vanilla-resources/assets/minecraft/blockstates/stone.json`.
`data/minecraft/datapacks/trade_rebalance/data/minecraft/tags/villager_trade/armorer/level_1.json` becomes
`<generated>/featurepacks/trade_rebalance/data/minecraft/tags/villager_trade/armorer/level_1.json`.
`data/minecraft/recipe/stick.json` becomes `<generated>/vanilla-data/data/minecraft/recipe/stick.json`. `pack.png` (central
record at 38,344,111; compressed 11,856, uncompressed 11,851, CRC-32 `dff0c869`) is written to both packs.
`net/minecraft/world/entity/raid/Raid$RaidStatus.class` is skipped.

**E4: mismatch.** A jar with SHA-256 `0000...` and 41,483,720 bytes whose `version.json` says `"id": "26.3"` fails with CCX-031. A jar
whose `version.json` says `"id": "26.4"` fails with CCX-030, prints `Minecraft 26.4` and `Minecraft 26.3` and writes nothing, and a
previous `generated/` stays as it was.

**E5: first run, then second run.** First run: `cobolcraft-extract --jar tmp/minecraft-26.3-client.jar --game-dir tmp/game`
prints progress lines at 1,000-file steps and ends with `CCX-101 Wrote 11605 resource files, 9779 data files and 106 feature-pack
files (...) to tmp/game/generated. Skipped 11391 jar entries (code, signatures, markers).` (the byte total is the sum of the payload
bytes). Second run: the same command prints the digest lines and `CCX-100 ... up to date ...` and exit 0, without changing a file.

**E6: layering with Faithful.** Stack bottom to top: `cobolcraft`, `vanilla`, `file/Faithful 32x - 26.3.zip`. A request for
`minecraft:textures/block/stone.png` (asset path `assets/minecraft/textures/block/stone.png`) is searched from the top (08 §3.2): Faithful holds it,
so it is used, and its `.mcmeta` companion comes from Faithful too (it has none, so no animation). A request for the block state
`minecraft:blockstates/stone.json` is merged across packs (08 §3.2): only `vanilla` has one, so the vanilla file is used. The atlas
`atlases/blocks.json` exists only in `vanilla` and the built-in pack's own atlas files are concatenated below it. `lang/en_us.json`:
Faithful has none; the built-in pack's keys are loaded first, then the generated pack's keys replace those with the same name
(Open question 3).

**E7: validity check outcomes.** (a) No `generated/` directory: `absent`. (b) `generated/` with a marker but no `manifest.txt`
(the tool was interrupted before the swap and the partial was somehow renamed by hand): `incomplete`. (c) `manifest.txt` with
`jar-sha256=` of another value or a `resource-format=96.0`: `stale`. (d) manifest fine, but `vanilla-data/data/minecraft/worldgen/biome/plains.json`
was deleted: `damaged`.

---

## 12. Validation

Checks an implementation of the tool and loaders must pass, with the expected numbers for the accepted 26.3 jar.

| # | Check | Expected |
|---|---|---|
| T1 | Zip structure of the jar read by the tool | 34,227 central records, 1,349 directories, 32,878 files, all method 8, all flags `0x0808` |
| T2 | SHA-256 of the jar | `4508d006...9a2d` (full value in 4.1); the SHA-256 routine itself returns `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad` for the three bytes `abc` (standard FIPS 180-4 vector, not read from the jar) |
| T3 | CRC-32 routine | `cbf43926` for `123456789`; `68d6e8ca` for the 422 bytes of `version.json` |
| T4 | `version.json` fields | 2.3: `id` 26.3, `world_version` 5023, `protocol_version` 777, resource 97.1, data 121.0 |
| T5 | Output counts | 11,605 resource files, 9,779 data files, 106 feature files, 21,490 payload files; 209, 539 and 22 directories (6.1) |
| T6 | Byte-for-byte copy | for every payload file the CRC-32 and size on disk equal the jar's central values (except the two generated `pack.mcmeta`, whose values are 129 bytes `c6f2b630` and 123 bytes `14f8038e`); `--verify` passes |
| T7 | Content kinds | all 15,919 JSON files still parse; 1,511 `.nbt` files still start with `1F 8B`; 3,964 PNG files still start with the PNG signature; 218 `.mcmeta` texture files each still sit beside a PNG |
| T8 | World without anything | with no `generated/`, no jar and an empty `resourcepacks/`, the cobolcraft world type starts and a standard world is refused with `cobolcraft.packs.absent` |
| T9 | Rejects | each of CCX-001, 010, 011, 020, 021, 030, 031, 040, 041, 042, 043, 044, 045, 050, 051, 060 has a test with the text of 7.4 and the exit code of its row; a truncated jar gives CCX-020; one flipped byte inside an entry gives CCX-040 (CRC) or CCX-041 (deflate); one flipped byte elsewhere gives CCX-031 |
| T10 | Idempotence | a second run changes nothing (CCX-100); `--force` rebuilds and the index is identical (same bytes, same order) |
| T11 | Interrupted run | a run killed before the swap leaves the previous `generated/` unchanged; the next run removes the `.partial` and succeeds |
| T12 | Safety | `--generated-dir` pointing at a non-empty directory without the marker is never deleted (CCX-051) |
| T13 | Pack metadata | the two generated `pack.mcmeta` files are accepted by the pack reader of 08 §2: format ranges 97.1 to 97.* and 121.0 to 121.*; the pack screen lists no `vanilla` entry in Available (it is required) |
| T14 | Stack order | with Faithful enabled the order bottom to top is `cobolcraft`, `vanilla`, `file/Faithful 32x - 26.3.zip`; the example lookups of E6 resolve as stated |
| T15 | Zip reader on Faithful | opens `Faithful 32x - 26.3.zip` (5,300 entries, methods 0 and 8, extra fields) and reads `pack.mcmeta` and `assets/minecraft/textures/block/stone.png` with the CRC-32 of the central record |
| T16 | Client without the jar | with valid generated packs and the jar deleted, the client and a standard-world server start (8.6) |

---

## Open questions

1. **Accepting an unknown jar.** No switch exists to accept a jar outside the table (4.1), as the design README decision 11 says. A
   hidden `--accept-unverified` could help the operator try 26.3.x, at the price of undefined data and registry differences. Decision
   for the operator.
2. **Jar needed at run time?** The design README C10 and decision 2 say a missing jar disables the standard type. This document
   says only the generated directory matters at run time (8.6). Operator to confirm. Also: should the title screen offer to start the
   tool, and where does the game find the tool's executable? Not decided here.
3. **Stack order and language keys.** The built-in `cobolcraft` pack is below the generated `vanilla` pack (C7). Language files merge bottom to top, so the
   generated pack's keys replace the built-in `en_us` texts with the same key (for example the original disconnect texts of 08 §10.8.4), whenever the generated pack is present. Is
   that wanted? The alternative is a different key set for the cobolcraft world's own messages. Also whether any other `minecraft:` path (atlas
   definitions, fonts) is supplied by both packs and needs a rule beyond 08 §3.2.
4. **Move tests of fixed entries (narrowed).** Answered in 8.1: in the jar, required does not prevent a move, only the neighbour's fixed flag does. Still open: whether the pack screen (13 §8) draws move buttons for a fixed entry at all, since the model's tests read the neighbour only. Searched: the move tests of the selection model's entry base class; the screen widget classes were not read.
5. **Feature packs.** The three packs are extracted and never enabled. Enabling them needs the feature-flag engine (08 §2.6, `features.enabled` flags
   such as `minecraft:trade_rebalance`) and the data changes they make (for example the villager-trade tags). No story asks for them. Kept disabled.
6. **Shaders and other unused assets.** `shaders/`, `post_effect/`, `waypoint_style/`, `gpu_warnlist.json`, `regional_compliancies.json` and `texts/` are copied but
   whether the renderer or the screens read them is inferred from document 12 and 13. If an implementation never uses them they could be dropped from the tool, at the cost of the
   validation counts changing.
7. **PNG decoder coverage.** 2.8 lists the PNG features present (bit depths 1, 2, 4 and 8; gray, RGB, palette, gray with alpha, RGBA; `tRNS` on palette, gray and RGB). Whether 08 and 14
   already require a decoder for all of these was not re-read in this round.
8. **`.gitignore`.** The generated directory and any user-chosen directory must be ignored by git. The default `<game directory>/generated` is not covered by the current
   `/tmp/` rule unless the game directory is under `tmp/`. The operator or the planner must add the rule; this document does not edit that file.
9. **Documents that do not exist yet.** The world-types document (RS2) is cited by role only. Documents 23 (registry loading), 24, 46, 33, 41 and 44 exist and are cross-referenced; 8.3 now defers to 23 §2 and §3. How 23 numbers the synchronized registries on the wire was not re-read in this round.
10. **Sound files and index.** 2.9 says the sound files are not in the client jar. That the launcher downloads them separately is recalled, not verified. Not needed by this round (sounds are out of scope).
11. **Large offsets.** The jar is 41,483,720 bytes, so every offset fits in 31 bits. User packs (Faithful: 13,116,019 bytes) too. A pack above 2 GiB would need 64-bit offsets and zip64, which both are
    rejected (8.4). Whether the file service of 7.2 needs a wider offset is left to the implementer.
12. **Data-pack merge for user packs.** The folder name `datapacks` under the world folder is read (8.3 level 3, `LevelResource`), but no story requires user data packs and the world folder document (07 §9, task T15) does not list the folder. It can be dropped or specified there. The merge itself follows 08 §3.2.
13. **Skipped-entry count.** The figure 11,391 of 7.3 step 7 (and of E5) is derived from the counts of 2.2 (10,737 + 646 + 4 + 1 plus `version.json` and the two markers), not from a separate run of the tool.
14. **Resolved from the jar for 08.** 08 Open question 3 (the dispatch key of an item model) is answered in 2.5: the key is `type`. 08 Open questions 5, 7, 8 and 9 were not in the scope of this round (they need
    bytecode of the renderer, `PackFormat` and the download classes) and stay open.
15. **Document 08 still says the client vanilla pack is fixed.** 2.4 gives the read value (required, BOTTOM, not fixed). 08 §3.1 ("Typical resulting
    order"; line 277 reads "built-in default pack (required, fixed BOTTOM)") and 08 §10 (line 905, "required and fixed at BOTTOM, inferred") are unchanged and wrong (re-confirmed against the jar: `VANILLA_SELECTION_CONFIG` is required true, BOTTOM, fixed false). The owner of 08 must correct them; this document cannot.
16. **Feature-pack config and `PACKS_DIR` (closed).** Read: `ServerPacksSource.PACKS_DIR` is `minecraft:datapacks`, the in-jar built-in pack root (2.4); the world folder comes from `LevelResource.DATAPACK_DIR` (8.3). Still not traced: which pack-repository code applies the feature config to a pack stack when a feature is enabled (8.3 level 2 stays inferred).
