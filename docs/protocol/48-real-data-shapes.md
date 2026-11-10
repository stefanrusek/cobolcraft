# 48 Real data shapes: sizes, accepted value forms and member census of the shipped data files

| Item | Value |
|---|---|
| Covers | The data files of `data/minecraft/` as they are, for the readers of those files (the content loaders): (1) file counts, identifier lengths, key lengths over 64 bytes and JSON node counts per registry directory, to size fixed-width fields and the document node cap; (2) the value forms that every union-valued member accepts (block state, block state provider, int, float and height providers, loot and context number providers, pool element `location`, ore `size`, tree placer members, noise settings `default_block`, surface rule `result_state`, references); (3) a member census (required and optional members with value kinds) for every `type` of the feature, placement modifier, tree placer, foliage placer, trunk placer, structure, structure placement, structure processor, pool element, surface rule, density function, carver, block state provider and provider families, plus loot, recipe and context-provider types; (4) where documents 10, 23, 26, 35, 36, 37 and 44 agree or disagree with the data. |
| Does not cover | What the data means (documents 10, 11, 23, 26, 35 to 39). Shapes of `advancement`, `dialog`, `timeline`, `enchantment` effects, `trial_spawner`, entity variants and `biome` beyond the file-level members of section 2.7 and the size figures of section 1. The NBT structure templates (document 36). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of data files (and scripted counting). The JSON files were read as data with a script (`python3 -I`, standard `json` module); no code of the artifact was executed. Counts were taken over the unpacked copy `build/extract-real/generated/vanilla-data/data`, which was first compared byte for byte with the jar entries (section 1.1), and over the jar archive listing (files only, directory entries excluded). |
| Operator decisions | Standard Minecraft content is the target (ticket CC-0001, "Vanilla assets and data"); the loaders of the content layer read these files, and documents 10, 11, 23, 26, 35 to 39 and 44 say what the values mean. |
| Status | Written by the reader for a corrective round after the content loaders rejected the real data. |

"(inferred)" marks a rule deduced from the data rather than read; the inferences are listed in the Open questions. Every table
cell in sections 1 to 4 is a count or a form produced by a script over the files; nothing in this document was taken from
recall. Where an earlier document is consistent with the data this document says so in section 5 and does not repeat the rule.

**How to read the kind labels.** A "kind" is the JSON kind of one value, as the file stores it.

| Label | Meaning |
|---|---|
| `int` | a number token without `.` and without exponent (14,795 such tokens in the pack) |
| `num` | a number token with a `.` (6,426 tokens, none without a dot; some carry an exponent, section 2.6) |
| `bool` | `true` or `false` |
| `id` | a string shaped like `namespace:path` (all 8,266 files use the namespace `minecraft`). Block ids, registry references and enumerated names that carry a namespace are all `id`; which one a string is depends on the slot (section 2.4) |
| `tag` | a string that starts with `#` (a tag reference, `#minecraft:...`) |
| `str` | any other string; when a member has at most 8 distinct such values they are listed in braces, for example `str{down/up}` |
| `obj` | an object with none of the discriminator members below |
| `o{type}`, `o{ptype}`, `o{etype}`, `o{proc}` | an object with a `type`, `predicate_type`, `element_type`, `processor_type` member |
| `o{id}` | an object with an `id` member (a block state object `{id, properties?}`, or an item stack object `{id, count?, components?}`) |
| `arr[k1 or k2]` | an array whose elements are of the kinds listed (`arr[]` is an empty array) |
| `a or b` | a union: both kinds occur for that member (in the tables of sections 2.7 and 3 to 4 the word `or` joins the kinds) |

---

## 1. Sizes

### 1.1 What was counted

The jar holds 9,884 entries under `data/`: 8,369 `.json`, 1,511 `.nbt`, 3 `.mcmeta` and 1 `.mcassetsroot`. Every entry of `data/` that
exists in the unpacked copy (9,777 of them) is byte-identical to its jar entry. The 107 jar entries that are not in the copy are
the three disabled feature packs under `data/minecraft/datapacks/` (103 `.json` and 3 `pack.mcmeta`; the 107th is `data/.mcassetsroot`; section 1.6). So
the copy holds **8,266 JSON files** (the 8,369 minus the 103 feature-pack files) and 1,511 NBT files (the structure templates, 0 JSON
files under `structure/`). Only the namespace `minecraft` occurs. All JSON files: UTF-8 without byte-order mark, only ASCII
characters, LF line ends, no final newline, two-space indentation of members (8,253 of the 8,266; the other 13 are 8 scalar-rooted files (`0.0`, `1.0`, `1.0`, `2.0`, `20`, `1`, `2`, `1`), 2 files that are `{}`, and 3 array-rooted `block_transformer` files whose elements are indented),
no backslash escape in any string.

Definitions used below. The **path** of an element is its file path under the registry directory without `.json`
(for example `cartographer/3/emerald_and_compass_buried_trial_chambers_map`). The **id with namespace** is `minecraft:` plus the path, 10
bytes longer than the path. The loaders' error "key over 64 bytes" matches the id with namespace (both villager trades named in the
loader report have 65 and 70 bytes with the prefix and 55 and 60 without). **Nodes** count every object, array and scalar once (the
member names are not nodes), so `{"a": 1}` has 2 nodes. **Depth** counts container nesting, the root object being 1. Lengths are bytes
(all ASCII, so bytes equal characters).

### 1.2 Per registry directory

Directory names are the singular forms of 22 §2; `worldgen/<x>` and `tags/<x>` are rows of their own. `tags` rows are the
`tags/<registry>` directories.

| registry directory (under data/minecraft/) | files | max path (bytes) | max id with namespace (bytes) | files whose path is over 64 | files whose id with namespace is over 64 | max nodes | p99 nodes | max file size (bytes) | max nesting depth |
|---|---|---|---|---|---|---|---|---|---|
| advancement | 1866 | 102 | 112 | 341 | 464 | 631 | 89 | 22577 | 12 |
| banner_pattern | 43 | 22 | 32 | 0 | 0 | 3 | 3 | 122 | 1 |
| block_transformer | 3 | 6 | 16 | 0 | 0 | 1488 | 1488 | 60159 | 9 |
| cat_sound_variant | 2 | 7 | 17 | 0 | 0 | 21 | 21 | 1086 | 2 |
| cat_variant | 11 | 17 | 27 | 0 | 0 | 15 | 15 | 459 | 5 |
| chat_type | 7 | 25 | 35 | 0 | 0 | 14 | 14 | 332 | 3 |
| chicken_sound_variant | 2 | 7 | 17 | 0 | 0 | 11 | 11 | 511 | 2 |
| chicken_variant | 3 | 9 | 19 | 0 | 0 | 10 | 10 | 331 | 4 |
| context_float_provider | 4 | 31 | 41 | 0 | 0 | 5 | 5 | 199 | 1 |
| context_int_provider | 26 | 41 | 51 | 0 | 0 | 19 | 19 | 454 | 5 |
| cow_sound_variant | 2 | 7 | 17 | 0 | 0 | 5 | 5 | 214 | 1 |
| cow_variant | 3 | 9 | 19 | 0 | 0 | 10 | 10 | 315 | 4 |
| damage_type | 51 | 21 | 31 | 0 | 0 | 5 | 5 | 137 | 1 |
| decorated_pot_pattern | 23 | 10 | 20 | 0 | 0 | 2 | 2 | 56 | 1 |
| dialog | 3 | 14 | 24 | 0 | 0 | 13 | 13 | 348 | 3 |
| dimension_type | 4 | 15 | 25 | 0 | 0 | 51 | 51 | 1786 | 4 |
| enchantment | 43 | 21 | 31 | 0 | 0 | 172 | 172 | 7372 | 16 |
| enchantment_provider | 7 | 27 | 37 | 0 | 0 | 5 | 5 | 144 | 1 |
| frog_variant | 3 | 9 | 19 | 0 | 0 | 8 | 8 | 234 | 4 |
| instrument | 8 | 16 | 26 | 0 | 0 | 6 | 6 | 177 | 2 |
| jukebox_song | 22 | 17 | 27 | 0 | 0 | 6 | 6 | 201 | 2 |
| loot_table | 1447 | 49 | 59 | 0 | 0 | 404 | 191 | 15389 | 16 |
| painting_variant | 51 | 15 | 25 | 0 | 0 | 10 | 10 | 276 | 2 |
| pig_sound_variant | 3 | 7 | 17 | 0 | 0 | 13 | 13 | 576 | 2 |
| pig_variant | 3 | 9 | 19 | 0 | 0 | 10 | 10 | 315 | 4 |
| predicate | 3 | 19 | 29 | 0 | 0 | 9 | 9 | 251 | 6 |
| recipe | 2042 | 78 | 88 | 32 | 157 | 24 | 24 | 785 | 5 |
| sulfur_cube_archetype | 12 | 15 | 25 | 0 | 0 | 41 | 41 | 1439 | 3 |
| tags/banner_pattern | 11 | 29 | 39 | 0 | 0 | 34 | 34 | 1022 | 2 |
| tags/block | 300 | 51 | 61 | 0 | 0 | 451 | 79 | 15972 | 2 |
| tags/damage_type | 36 | 32 | 42 | 0 | 0 | 32 | 32 | 839 | 2 |
| tags/dialog | 2 | 22 | 32 | 0 | 0 | 2 | 2 | 18 | 2 |
| tags/enchantment | 22 | 33 | 43 | 0 | 0 | 45 | 45 | 1222 | 2 |
| tags/entity_type | 49 | 34 | 44 | 0 | 0 | 27 | 27 | 619 | 2 |
| tags/fluid | 10 | 30 | 40 | 0 | 0 | 4 | 4 | 74 | 2 |
| tags/game_event | 5 | 26 | 36 | 0 | 0 | 59 | 59 | 1670 | 2 |
| tags/instrument | 3 | 20 | 30 | 0 | 0 | 6 | 6 | 152 | 2 |
| tags/item | 236 | 37 | 47 | 0 | 0 | 96 | 57 | 3045 | 2 |
| tags/painting_variant | 1 | 9 | 19 | 0 | 0 | 49 | 49 | 1187 | 2 |
| tags/point_of_interest_type | 3 | 19 | 29 | 0 | 0 | 15 | 15 | 364 | 2 |
| tags/potion | 5 | 30 | 40 | 0 | 0 | 43 | 43 | 1284 | 2 |
| tags/timeline | 4 | 12 | 22 | 0 | 0 | 6 | 6 | 119 | 2 |
| tags/villager_trade | 73 | 25 | 35 | 0 | 0 | 80 | 80 | 4263 | 2 |
| tags/worldgen | 123 | 58 | 68 | 0 | 3 | 58 | 57 | 1698 | 2 |
| test_environment | 1 | 7 | 17 | 0 | 0 | 3 | 3 | 53 | 2 |
| test_instance | 1 | 11 | 21 | 0 | 0 | 8 | 8 | 204 | 1 |
| timeline | 4 | 17 | 27 | 0 | 0 | 352 | 352 | 9260 | 5 |
| trade_set | 68 | 25 | 35 | 0 | 0 | 4 | 4 | 139 | 1 |
| trial_spawner | 28 | 49 | 59 | 0 | 0 | 25 | 25 | 662 | 5 |
| trim_material | 11 | 9 | 19 | 0 | 0 | 5 | 5 | 147 | 2 |
| trim_pattern | 18 | 9 | 19 | 0 | 0 | 5 | 5 | 133 | 2 |
| villager_trade | 391 | 60 | 70 | 0 | 2 | 34 | 33 | 1002 | 7 |
| wolf_sound_variant | 7 | 7 | 17 | 0 | 0 | 17 | 17 | 822 | 2 |
| wolf_variant | 9 | 8 | 18 | 0 | 0 | 15 | 15 | 568 | 4 |
| world_clock | 2 | 9 | 19 | 0 | 0 | 1 | 1 | 2 | 1 |
| worldgen/biome | 67 | 24 | 34 | 0 | 0 | 182 | 182 | 5879 | 8 |
| worldgen/block_state_provider | 8 | 20 | 30 | 0 | 0 | 23 | 23 | 525 | 6 |
| worldgen/carver | 4 | 22 | 32 | 0 | 0 | 35 | 35 | 944 | 3 |
| worldgen/density_function | 55 | 48 | 58 | 0 | 0 | 1132 | 1132 | 53538 | 17 |
| worldgen/feature | 240 | 31 | 41 | 0 | 0 | 518 | 257 | 20332 | 17 |
| worldgen/flat_level_generator_preset | 9 | 15 | 25 | 0 | 0 | 29 | 29 | 740 | 4 |
| worldgen/material_condition | 8 | 21 | 31 | 0 | 0 | 6 | 6 | 141 | 1 |
| worldgen/material_rule | 42 | 54 | 64 | 0 | 0 | 369 | 369 | 16946 | 15 |
| worldgen/multi_noise_biome_source_parameter_list | 2 | 9 | 19 | 0 | 0 | 2 | 2 | 37 | 1 |
| worldgen/noise | 64 | 31 | 41 | 0 | 0 | 14 | 14 | 213 | 2 |
| worldgen/noise_settings | 7 | 16 | 26 | 0 | 0 | 128 | 128 | 4206 | 11 |
| worldgen/placed_feature | 273 | 35 | 45 | 0 | 0 | 90 | 88 | 2745 | 9 |
| worldgen/processor_list | 40 | 38 | 48 | 0 | 0 | 164 | 164 | 6881 | 8 |
| worldgen/structure | 52 | 38 | 48 | 0 | 0 | 108 | 108 | 3960 | 7 |
| worldgen/structure_set | 21 | 17 | 27 | 0 | 0 | 61 | 61 | 1794 | 3 |
| worldgen/template_pool | 245 | 50 | 60 | 0 | 0 | 395 | 395 | 14971 | 8 |
| worldgen/world_preset | 7 | 22 | 32 | 0 | 0 | 47 | 47 | 1513 | 7 |
| zombie_nautilus_variant | 2 | 9 | 19 | 0 | 0 | 9 | 9 | 280 | 4 |
| **all** | 8266 | | | | | | | | |
| `structure` (NBT templates, not JSON) | 1511 | 78 | 88 | 42 | 139 | n/a | n/a | 80375 | n/a |

The `structure` row is the one registry directory that holds `.nbt` files (document 36); its path is relative to `structure/` and the id with namespace is
`minecraft:` plus that path. `data/minecraft/datapacks/` (jar only) is described in section 1.6. Every other directory under `data/minecraft/` is a row above.

Readings of the table.

- **Total.** 8,266 JSON files; the largest by nodes is `block_transformer/axe` (1,488 nodes, 60,159 bytes, an array root); the largest
  among the registries the content loaders read is `worldgen/density_function/overworld/offset` (and its `overworld_amplified` and
  `overworld_large_biomes` twins: 1,132 nodes, 53,538 bytes). Over all 8,266 files the 99th percentile is 182 nodes and the 99.9th
  percentile 518 nodes. The deepest nesting is 17 (density functions and features).
- **Path lengths.** The longest path is 102 bytes (`advancement`), then 78 (`recipe`), 60 (`villager_trade`), 58 (`tags/worldgen`), 54
  (`worldgen/material_rule`), 51 (`tags/block`), 50 (`worldgen/template_pool`), 49 (`trial_spawner` and `loot_table`). Every other directory is at
  most 48.
- **Sizing (inferred).** A field that holds an id with namespace needs 112 bytes for the keys of all directories (`advancement`), 88 for
  every directory except `advancement`, and 88 bytes for the identifier-valued strings inside the worldgen files (section 1.4; 88 in `advancement`
  files as well). A node cap of 2,048
  admits every file of the pack with a margin of 38 percent over the largest (1,488); 1,132 is the largest figure among worldgen
  registries. A container nesting limit of 24 admits every file (maximum 17). The largest JSON file is `block_transformer/axe` (60,159 bytes) and the largest density function file is 53,538 bytes, so a
  64 KiB (65,536 bytes) file buffer fits every JSON file with a margin of under 10 percent; use at least 128 KiB (inferred). The largest NBT
  template is 80,375 bytes, which a 64 KiB buffer does not hold.

### 1.3 Keys over 64 bytes

| Directory | Files with id with namespace over 64 bytes | of which path alone over 64 | Longest id with namespace | Examples |
|---|---|---|---|---|
| `recipe` | 157 | 32 | 88 | `brewing/lingering_potion_awkward_glistering_melon_slice` (55 + 10), `chiseled_polished_blackstone_from_blackstone_stonecutting` (67 + 10), `waxed_weathered_cut_copper_stairs_from_waxed_weathered_cut_copper_stonecutting` (78 + 10) |
| `villager_trade` | 2 | 0 | 70 | `cartographer/3/emerald_and_compass_buried_trial_chambers_map` (60 + 10), `cartographer/5/emerald_and_compass_woodland_mansion_map` (55 + 10) |
| `advancement` | 464 | 341 | 112 | `recipes/building_blocks/waxed_weathered_cut_copper_stairs_from_waxed_weathered_cut_copper_stonecutting` (102 + 10) |
| `tags/worldgen` | 3 | 0 | 68 | (the other `tags/*` directories are at most 61 with the namespace) |
| all other directories | 0 | 0 | at most 64 | `worldgen/material_rule` 64, `villager_trade` 70 (listed above), `loot_table` 59 |

Total over all directories: 626 files have an id with namespace over 64 bytes (464 `advancement`, 157 `recipe`, 3 `tags/worldgen`, 2
`villager_trade`; 159 in the two directories of the loader report). Only `advancement` (341) and `recipe` (32) have files whose path alone is over 64
bytes.

The same limit is exceeded by identifier-valued strings **inside** files, not only by keys: see section 1.4 (`template_pool`
`location`, 241 values over 64 bytes, up to 88).

### 1.4 Largest values inside files

Per registry (the file named in parentheses is the first of the files that reach the maximum; ties exist): the longest array, the object with most members, and the longest identifier-shaped string value (a string matching
`#?namespace:path`), and the longest string of any kind. Lengths in bytes; an identifier-shaped value includes `minecraft:` and, for
a tag reference, the `#`.

| registry | max array length | max members of one object | longest identifier-shaped string value (bytes) | longest any string (bytes) |
|---|---|---|---|---|
| advancement | 60 ( wax_off ) | 56 | 88 | 88 |
| banner_pattern | 0 (  ) | 2 | 32 | 45 |
| block_transformer | 52 ( axe ) | 6 | 45 | 45 |
| cat_sound_variant | 0 (  ) | 9 | 40 | 40 |
| cat_variant | 2 ( all_black ) | 3 | 47 | 47 |
| chat_type | 3 ( team_msg_command_incoming ) | 3 | 0 | 33 |
| chicken_sound_variant | 0 (  ) | 4 | 38 | 38 |
| chicken_variant | 1 ( cold ) | 4 | 47 | 47 |
| context_float_provider | 0 (  ) | 4 | 41 | 41 |
| context_int_provider | 2 ( low ) | 4 | 51 | 51 |
| cow_sound_variant | 0 (  ) | 4 | 34 | 34 |
| cow_variant | 1 ( cold ) | 4 | 43 | 43 |
| damage_type | 0 (  ) | 4 | 0 | 32 |
| decorated_pot_pattern | 0 (  ) | 1 | 36 | 36 |
| dialog | 0 (  ) | 7 | 33 | 33 |
| dimension_type | 0 (  ) | 16 | 33 | 33 |
| enchantment | 4 ( frost_walker ) | 11 | 42 | 43 |
| enchantment_provider | 0 (  ) | 4 | 33 | 33 |
| frog_variant | 1 ( cold ) | 2 | 36 | 36 |
| instrument | 0 (  ) | 4 | 32 | 37 |
| jukebox_song | 0 (  ) | 4 | 38 | 40 |
| loot_table | 31 ( trail_ruins_common ) | 5 | 59 | 59 |
| painting_variant | 0 (  ) | 5 | 25 | 41 |
| pig_sound_variant | 0 (  ) | 5 | 33 | 33 |
| pig_variant | 1 ( cold ) | 4 | 43 | 43 |
| predicate | 2 ( fast_cooking ) | 2 | 23 | 23 |
| recipe | 16 ( iron_nugget_from_blasting ) | 7 | 48 | 48 |
| sulfur_cube_archetype | 5 ( bouncy ) | 6 | 60 | 60 |
| tags | 449 ( mineable/pickaxe ) | 1 | 70 | 70 |
| test_environment | 0 (  ) | 2 | 16 | 16 |
| test_instance | 0 (  ) | 7 | 21 | 21 |
| timeline | 32 ( day ) | 18 | 19 | 19 |
| trade_set | 0 (  ) | 3 | 45 | 45 |
| trial_spawner | 2 ( breeze/ominous ) | 6 | 52 | 52 |
| trim_material | 0 (  ) | 2 | 24 | 33 |
| trim_pattern | 0 (  ) | 3 | 19 | 32 |
| villager_trade | 6 ( 4/emerald_suspicious_stew ) | 8 | 40 | 40 |
| wolf_sound_variant | 0 (  ) | 7 | 36 | 36 |
| wolf_variant | 1 ( ashen ) | 3 | 46 | 46 |
| world_clock | 0 (  ) | 0 | 0 | 0 |
| worldgen/biome | 30 ( badlands ) | 8 | 45 | 45 |
| worldgen/block_state_provider | 11 ( flower_flower_forest ) | 9 | 41 | 41 |
| worldgen/carver | 0 (  ) | 10 | 31 | 31 |
| worldgen/density_function | 11 ( overworld/factor ) | 6 | 58 | 58 |
| worldgen/feature | 59 ( crimson_fungus ) | 16 | 44 | 44 |
| worldgen/flat_level_generator_preset | 6 ( water_world ) | 5 | 27 | 27 |
| worldgen/material_condition | 0 (  ) | 5 | 21 | 21 |
| worldgen/material_rule | 12 ( overworld/biome_surface ) | 8 | 64 | 64 |
| worldgen/multi_noise_biome_source_parameter_list | 0 (  ) | 1 | 19 | 19 |
| worldgen/noise | 9 ( cave_cheese ) | 4 | 0 | 0 |
| worldgen/noise_settings | 9 ( amplified ) | 11 | 58 | 58 |
| worldgen/placed_feature | 11 ( twisting_vines ) | 5 | 43 | 43 |
| worldgen/processor_list | 17 ( zombie_plains ) | 5 | 44 | 44 |
| worldgen/structure | 5 ( fortress ) | 13 | 63 | 63 |
| worldgen/structure_set | 18 ( abandoned_camp ) | 7 | 48 | 48 |
| worldgen/template_pool | 49 ( abandoned_camp/camp/bamboo_jungle ) | 4 | 88 | 88 |
| worldgen/world_preset | 3 ( flat ) | 5 | 23 | 23 |
| zombie_nautilus_variant | 1 ( temperate ) | 3 | 47 | 47 |

Facts that sizing needs.

- `worldgen/template_pool` `location` values are structure template names: **2,196 values, 1,286 distinct, 139 distinct (241 uses) over
  64 bytes, the longest 88 bytes** (`minecraft:` plus up to 78 bytes of path). The 241 uses equal the loader's 241 `location must be
  an identifier` errors (inferred: the loader's identifier width is 64 bytes). Each value names a structure template file
  `data/minecraft/structure/<path>.nbt`: the 1,511 NBT files have ids with namespace up to 88 bytes. 1,285 of the 1,286 distinct
  values name an existing NBT file; **`minecraft:ancient_city/walls/intact_horizontal_wall_stairs_5` names none** (a dangling reference, Open question 3).
- The longest identifier-shaped string value in `tags` files is 70 bytes (a plain id or a `#` reference); the longest string in an `advancement` file
  is 88.
- Objects with an `id` and a `properties` object (599 outside advancements and tags) have at most 6 properties, property names up to 19 bytes,
  property values up to 8 bytes, every property value a string (1,283 of 1,283).
- A `tags` file has one member, `values`, an array of up to 449 strings (`tags/block/mineable/pickaxe`); every element is a string
  (6,231 of 6,231; no object entries and no `replace` member); an element is a plain id or a `#` tag.
- The longest array of a `template_pool` file has 49 elements, of a `loot_table` file 31, of a `worldgen/feature` file 59, of a `density_function`
  file 11 (the 54 object files together hold 1,290 spline point objects).

### 1.5 JSON number and layout facts for a parser

- 14,795 integer tokens, longest 9 digits (`165745296`), all within a signed 32-bit range; 571 are negative.
- 6,426 decimal tokens. The longest is 22 characters. 18 digits after the dot at most. Tokens with an exponent: `1.7976931348623157E308`
  (27 uses, always `max_threshold` of a `noise_threshold` surface condition; the value equals the largest finite double, inferred from the digits), `2.9802322E-8` (12, `value`),
  `5.9604645E-8` (6, `value`), `1.0E-4` (6, `probability`), `9.999999747378752E-6` (2, `min`). The exponent letter is upper case `E`.
- No `-0`, no `-0.0`, no number token that starts with `+`, no integer part with a leading zero, no integer token beyond 32-bit range.
- Keys of an object appear in **alphabetical order, with `type` first when the object has one** (inferred rule: it holds for all
  objects of every directory except `advancement`; every one of the 14,739 objects that have a `type` and another member has `type` first). A parser must
  still accept any order (inferred: the game's reader does not depend on the order).

### 1.6 The three disabled feature packs (jar only)

The jar also holds `data/minecraft/datapacks/{minecart_improvements,redstone_experiments,trade_rebalance}/`. The first two hold only a
`pack.mcmeta`. `trade_rebalance` holds 103 JSON files: 81 `villager_trade` (longest path 63 bytes, 7 over 64 with the namespace, at most 40
nodes), 17 `tags` (at most 29 nodes) and 5 `loot_table` (at most 279 nodes, 9,265 bytes). 16 of the 103 ids also exist in the base pack
(5 loot tables, 10 tags, 1 villager trade). Each `pack.mcmeta` has a `features.enabled` list with one id and `pack.min_format` and
`max_format` of 121. The extraction output `build/extract-real/generated/featurepacks/` holds the three packs as separate directories.

---

## 2. Accepted value forms

### 2.1 The shapes named by the loader errors

Every row says what the files hold, not what the loader accepted. Examples are short inline excerpts of the data.

| Shape (loader message) | Forms that occur | Where | Example |
|---|---|---|---|
| noise settings `default_block` (and `default_fluid`) | a plain block id string; never an object, never `Name`/`Properties` | 7 of 7 `noise_settings` files | `"default_block": "minecraft:stone"` |
| surface rule `result_state` | a plain block id string; never an object, no properties (91 of 91 `block` rules) | `worldgen/material_rule`, rule type `block` | `{"type": "minecraft:block", "result_state": "minecraft:bedrock"}` |
| surface rule `rules` | **there is no `rules` member.** The `sequence` rule's member is named `sequence`: an array whose elements are objects or strings (a string names another `material_rule` file) | `worldgen/material_rule` | `{"type": "minecraft:sequence", "sequence": ["minecraft:bedrock_floor", {"type": "minecraft:condition", ...}]}` |
| surface rule `condition` | members `if_true` (a string naming a `material_condition` file, or an inline condition object) and `then_run` (a string naming a `material_rule` file, or an inline rule object) | | `{"type": "minecraft:condition", "if_true": {"type": "minecraft:above_preliminary_surface"}, "then_run": "minecraft:overworld/surface"}` |
| ore `config.size` | **there is no `config` member anywhere in the 8,266 files.** `size` is a top-level member of the `ore` feature (and `scattered_ore`), always a plain integer (32 of 32) | 30 `ore`, 2 `scattered_ore` | `{"type": "minecraft:ore", "discard_chance_on_air_exposure": 0.0, "size": 17, "targets": [...]}` |
| ore `targets[]` | objects `{state, target}`: `state` a plain block id string, `target` a rule test object (`predicate_type`) | 49 targets | `{"state": "minecraft:coal_ore", "target": {"predicate_type": "minecraft:tag_match", "tag": "minecraft:stone_ore_replaceables"}}` (a target may nest `any_of`/`all_of`/`not`/`height_match`) |
| block state (`block_state`: the value must be an object) | **a plain block id string, or an object `{id, properties?}`** (`properties` optional, an object of string values). The keys are `id` and `properties`, not `Name`/`Properties`. Which of the two a slot uses is in section 2.2 | everywhere a block state is a value | `"state": "minecraft:basalt"` and `{"id": "minecraft:dirt"}` and `{"id": "minecraft:cherry_leaves", "properties": {"distance": "7", "persistent": "false", "waterlogged": "false"}}` |
| block state provider (`block_state_provider`: the member `type` is missing) | **three forms:** a string that names a `worldgen/block_state_provider` file (8 names), an object `{id, properties?}` (a state, the "simple" provider; 0 files use a `type` of `simple`), or a typed object (`type`: `weighted`, `randomized_int`, `noise`, `noise_threshold`, `dual_noise`, `rule_based`, `rotated`, `random_block`). Never a plain block id string in a provider slot | section 2.2 | `"below_trunk_provider": "minecraft:soil_beneath_tree"`; `"trunk_provider": {"id": "minecraft:cherry_log", "properties": {"axis": "y"}}`; `{"type": "minecraft:weighted", "entries": [{"data": "minecraft:cave_vines_plant", "weight": 4}]}` |
| int provider (`int_provider`: the member `type` is missing) | a **bare integer** (no `constant` type exists in the 8,266 files), or a typed object with `type` one of `uniform`, `biased_to_bottom`, `very_biased_to_bottom`, `clamped`, `clamped_normal`, `trapezoid`, `weighted_list`; or (cherry trunk placer only) an **untyped** `{max_inclusive, min_inclusive}` object that has no `type` (2 instances) | section 2.3 | `"count": 30`; `{"type": "minecraft:uniform", "max_inclusive": 4, "min_inclusive": 1}`; `"branch_start_offset_from_top": {"max_inclusive": -3, "min_inclusive": -4}` |
| float provider | a **bare number** (decimal token), or a typed object: `uniform` (`min_inclusive`, `max_exclusive`), `trapezoid` (`min`, `max`, `plateau`, decimal), `clamped_normal` (`mean`, `deviation`, `min`, `max`), no `constant` type | carver, feature, loot | `"floor_level": -0.7`; `{"type": "minecraft:uniform", "max_exclusive": -0.4, "min_inclusive": -1.0}` |
| height provider | a typed object whose bounds are vertical anchors: `uniform` (77), `trapezoid` (13), `very_biased_to_bottom` (2, extra member `inner`); or, for the structure `start_height`, a bare anchor object | `height_range` placement, carver `y`, structure `start_height` | `{"type": "minecraft:uniform", "max_inclusive": {"below_top": 0}, "min_inclusive": {"absolute": 136}}`; `"start_height": {"absolute": 0}` |
| vertical anchor | an object with exactly one member, `absolute`, `above_bottom`, `below_top` or `relative_to_sea_level`, an integer value | | `{"above_bottom": 5}` |
| tree member `height` (`member height must be an integer`) | foliage placers: an **integer** for `blob`, `bush`, `cherry`, `fancy`, `jungle`; an **int provider object** for `pine` and `poplar`. `mega_pine` has `crown_height` (provider), `spruce` has `trunk_height` (provider), `random_spread` has `foliage_height` (integer). `radius`: integer except `poplar`, `spruce` (provider objects); `offset`: integer except `spruce` (provider) | 45 foliage placers | `{"type": "minecraft:poplar_foliage_placer", "height": {"type": "minecraft:uniform", "max_inclusive": 6, "min_inclusive": 5}, "offset": 0, "radius": {"type": "minecraft:weighted_list", "distribution": [...]}, "side_hole_chance": 0.15}` |
| template pool element `location` (must be an identifier) | always a string, an id with namespace naming a structure template (`structure/<path>.nbt`); 2,196 of 2,196 values, up to **88 bytes**; 241 values exceed 64 | `single_pool_element`, `legacy_single_pool_element` | `"location": "minecraft:abandoned_camp/camp/default/campsite_default_chest_1"` |
| template pool element `processors` | a string naming a `processor_list` file (757), or an object `{processors: [...]}` (an inline list, 1,439; every one of them is the empty `{"processors": []}`) | | `"processors": "minecraft:ancient_city_start_degradation"`; `"processors": {"processors": []}` |
| loot `rolls`, `count`, `levels` (`loot_int`: the value must be an object) | a **bare integer** (`rolls`: 1,515 integers and 80 `uniform`; `count`: 395 integers, 614 `uniform`, 18 `binomial`; `levels`: 7 integers, 27 `uniform`) or a typed object `uniform` (`min`, `max`), for `count` also `binomial` (`n`, `p`). Bounds are integers for int uses and decimals for float uses (`enchanted_count_increase.count`, `set_damage.damage`: `uniform` with decimal `min`/`max`) | `loot_table` | `"rolls": 1`; `{"type": "minecraft:uniform", "max": 4, "min": 2}`; `{"type": "minecraft:binomial", "n": 3, "p": 0.53333336}` |
| context int/float provider root (`loot_int`: the value must be an object) | the **whole file** may be a bare number: `context_int_provider` 4 of 26 files are an integer (for example `20`), `context_float_provider` 3 of 4 are a decimal (for example `1.0`); the rest are typed objects (`conditional`, `div`, `number_dispatcher`, `weighted_list`) | `context_int_provider`, `context_float_provider` | `20`; `1.0`; `{"type": "minecraft:conditional", "condition": "minecraft:block/fast_cooking", "on_false": "...", "on_true": "..."}` |
| density function operand | a number, a string naming a `density_function` file, or a typed object; the root of one file (`zero`) is the number `0.0` | `worldgen/density_function`, `noise_settings` | `{"type": "minecraft:add", "left": -0.50375, "right": "minecraft:overworld/offset"}` |

### 2.2 Block state and block state provider slots

A **block state slot** accepts a plain block id string or a state object `{id, properties?}`. A **block state provider slot** accepts
a string that names one of the 8 `worldgen/block_state_provider` files, a state object `{id, properties?}`, or a typed provider. (35-2 §4.1
states both rules; the data agrees: no provider slot holds a plain block id that is not one of the 8 names.) The table shows, for each member
that has an object form somewhere, how many values of each form occur, so that a slot can be classified by the data alone. A member that has
plain strings and no provider names is a state slot (`state`, `data`, `output_state`, `block`); a member with provider names or typed objects
is a provider slot (`to_place`, `provider`, `below_trunk_provider`, `block_provider`, `source`, ...).

Ambiguity to know: `minecraft:mangrove_propagule` is both a block id (the `would_survive` `state` of two placed features) and one of the 8 provider names (the
`block_provider` and `provider` of two features). The slot decides: in a state slot the string is a block, in a provider slot it is a provider name.

The 8 provider files and the type of each: `cave_vines_body` (`weighted`), `cave_vines_head` (`randomized_int`), `flower_flower_forest` (`noise`), `flower_meadow`
(`dual_noise`), `flower_plain` (`noise_threshold`), `mangrove_propagule` (`randomized_int`), `podzol_beneath_tree` and `soil_beneath_tree` (`rule_based`).

| registry | member | plain string | one of the 8 provider names | object with id and properties | object with id only | typed provider object |
|---|---|---|---|---|---|---|
| block_state_provider | data | 2 | 0 | 2 | 0 | 0 |
| block_state_provider | source | 0 | 0 | 1 | 0 | 1 |
| block_state_provider | then | 0 | 0 | 1 | 1 | 0 |
| feature | above_root_provider | 0 | 0 | 0 | 2 | 0 |
| feature | alternate_inner_layer_provider | 0 | 0 | 0 | 1 | 0 |
| feature | barrier | 0 | 0 | 0 | 2 | 0 |
| feature | below_trunk_provider | 0 | 44 | 0 | 1 | 0 |
| feature | block | 10 | 0 | 9 | 2 | 1 |
| feature | block_provider | 0 | 2 | 0 | 1 | 5 |
| feature | block_state_provider | 0 | 0 | 0 | 0 | 20 |
| feature | cap_provider | 0 | 0 | 2 | 0 | 0 |
| feature | data | 75 | 0 | 304 | 13 | 0 |
| feature | fallback | 0 | 0 | 0 | 2 | 0 |
| feature | filling_provider | 0 | 0 | 0 | 1 | 0 |
| feature | fluid | 0 | 0 | 2 | 0 | 0 |
| feature | foliage_provider | 0 | 0 | 44 | 0 | 1 |
| feature | ground_state | 0 | 0 | 0 | 7 | 0 |
| feature | hanging_root_state_provider | 0 | 0 | 1 | 1 | 0 |
| feature | inner_layer_provider | 0 | 0 | 0 | 1 | 0 |
| feature | middle_layer_provider | 0 | 0 | 0 | 1 | 0 |
| feature | muddy_roots_provider | 0 | 0 | 2 | 0 | 0 |
| feature | outer_layer_provider | 0 | 0 | 0 | 1 | 0 |
| feature | provider | 0 | 6 | 10 | 5 | 4 |
| feature | root_provider | 0 | 0 | 2 | 0 | 0 |
| feature | root_state_provider | 0 | 0 | 0 | 2 | 0 |
| feature | source | 0 | 0 | 5 | 0 | 0 |
| feature | state | 55 | 0 | 7 | 0 | 4 |
| feature | state_provider | 0 | 0 | 1 | 4 | 5 |
| feature | stem_provider | 0 | 0 | 2 | 0 | 0 |
| feature | then | 0 | 0 | 2 | 1 | 0 |
| feature | to_place | 0 | 3 | 20 | 32 | 20 |
| feature | trunk_provider | 0 | 0 | 51 | 0 | 0 |
| placed_feature | state | 61 | 2 | 0 | 0 | 0 |
| processor_list | block_state | 0 | 0 | 8 | 0 | 0 |
| processor_list | output_state | 152 | 0 | 12 | 0 | 0 |

A state object has the members `id` (required) and `properties` (optional): every object counted in the table above has no other member. `properties` is an
object whose values are strings, 1 to 6 members. A `rule_based` provider rule is `{if_true, then}` where `then` is a state object (`{"id": "minecraft:dirt"}`, no
properties).

### 2.3 Number providers

The int, float and height providers are slots, not separate registries in the data. Their forms:

| Form | Members | Used for |
|---|---|---|
| bare integer | the integer itself | int slots (no `constant` type exists) |
| bare number | the decimal itself | float slots (carver `floor_level`, `horizontal_radius_multiplier`, ...) |
| `uniform` int | `min_inclusive`, `max_inclusive` (integers) | int slots |
| `uniform` float | `min_inclusive`, `max_exclusive` (decimals) | float slots (17 instances) |
| `uniform` height | `min_inclusive`, `max_inclusive` (vertical anchors) | `height_range.height`, carver `y`, `structure.height`, `start_height` |
| `trapezoid` int | `min`, `max`, `plateau` (integers) | placement offsets `x`, `y`, `z` (270) |
| `trapezoid` float | `min`, `max`, `plateau` (decimals) | carver `thickness` |
| `trapezoid` height | `min_inclusive`, `max_inclusive` (anchors); no `plateau` | `height_range.height` (13) |
| `clamped_normal` int | `mean`, `deviation` (decimals), `min_inclusive`, `max_inclusive` (integers) | placement offsets (6) |
| `clamped_normal` float | `mean`, `deviation`, `min`, `max` (decimals) | `speleothem_cluster.wetness` (1) |
| `clamped` int | `source` (an int provider object), `min_inclusive`, `max_inclusive` (integers) | `count`, `column_radius` (3) |
| `biased_to_bottom`, `very_biased_to_bottom` int | `min_inclusive`, `max_inclusive` (integers) | `count`, `height`, carver `count` (3 and 3) |
| `very_biased_to_bottom` height | `min_inclusive`, `max_inclusive` (anchors), `inner` (integer) | `height_range.height` (2) |
| `weighted_list` | `distribution`: array of `{data, weight}`; `data` is an integer (31 lists) or an int provider object (9 lists, mixed with integers); `weight` an integer | int slots |
| untyped uniform | `{min_inclusive, max_inclusive}` with no `type` | cherry trunk placer `branch_start_offset_from_top` |
| loot `uniform` | `min`, `max` (integers or decimals) | `rolls`, `count`, `levels`, `damage`, `duration`, `amplifier` |
| loot `binomial` | `n` (integer), `p` (decimal) | `count` (18 loot uses, 7 trade uses) |
| `linear` | `base`, `per_level_above_first` (decimals) | enchantment `value`, `amount`, `duration` (43 uses in `enchantment` files; 11 loot and trade uses are in section 4.5) |

Vertical anchors: an object with exactly one integer member, `absolute`, `above_bottom`, `below_top` or `relative_to_sea_level`. Counts over all non-tag,
non-advancement files: `absolute` 142, `above_bottom` 69, `below_top` 33, `relative_to_sea_level` 4 (the four are the `max_inclusive` bound of the
`height_range` predicate of the two basalt column features). A height-provider slot that is a bare anchor object (no `type`) occurs for the structure member
`start_height` (27 of 28 jigsaw structures: `{"absolute": n}`); a typed `uniform` height occurs once.

Which members are provider slots, and which forms occur at each, per member (counts of values in the registries of the second column only; the bare forms are
counted for the members that have an object form somewhere; other uses of the same member name in unrelated shapes are given as "also". The same member
name also holds bare integers in registries that are not listed, for example `count` of an item stack in `recipe` (727) and `villager_trade` (303) and of a
biome spawner (605), and `height` of a painting or of a flat preset layer; those are not counted here):

| member | registries | bare integer | bare number | object forms (type[value kind]: count) |
|---|---|---|---|---|
| amplifier | loot_table | 0 | 0 | uniform[int]: 3 |
| bend_length | feature | 0 | 0 | uniform[int]: 1 |
| branch_amount | feature | 0 | 0 | uniform[int]: 6 |
| branch_count | feature | 0 | 0 | weighted_list[int]: 2 |
| branch_end_offset_from_top | feature | 0 | 0 | uniform[int]: 2 |
| branch_horizontal_length | feature | 0 | 0 | uniform[int]: 2 |
| branch_start_offset_from_top | feature | 0 | 0 | untyped {min_inclusive,max_inclusive}: 2 |
| column_radius | feature | 0 | 0 | clamped[int]: 1 |
| column_reach | feature | 2 | 0 | uniform[int]: 2 |
| count | carver, feature, loot_table, placed_feature, structure | 583 | 0 | biased_to_bottom[int]: 1, binomial[-]: 18, clamped[int]: 2, uniform[int]: 554, uniform[num]: 80, very_biased_to_bottom[int]: 3, weighted_list[int]: 22 |
| crown_height | feature | 0 | 0 | uniform[int]: 2 |
| damage | loot_table | 0 | 0 | uniform[num]: 28 |
| data | feature, placed_feature | 83 | 0 | uniform[int]: 15; also non-provider uses: string 75 in `feature` (block state slots), array and string 3 and 7 in `structure`, string 2 in `block_state_provider` |
| density | feature | 0 | 0 | uniform[num]: 2 |
| depth | feature | 6 | 0 | uniform[int]: 1 |
| distance_factor | carver | 0 | 0 | uniform[num]: 1 |
| duration | loot_table, villager_trade | 6 | 0 | uniform[int]: 14 |
| extra_branch_length | feature | 0 | 0 | uniform[int]: 2 |
| extra_branch_steps | feature | 0 | 0 | uniform[int]: 2 |
| floor_level | carver | 0 | 1 | uniform[num]: 2 |
| height | feature, placed_feature, structure | 56 | 0 | biased_to_bottom[int]: 2, trapezoid[height]: 13, uniform[height]: 72, uniform[int]: 14, very_biased_to_bottom[height]: 2, weighted_list[int, nested providers]: 9, weighted_list[int]: 1 |
| height_scale | feature | 0 | 0 | uniform[num]: 1 |
| horizontal_radius_factor | carver | 0 | 0 | uniform[num]: 1 |
| horizontal_radius_multiplier | carver | 0 | 1 | uniform[num]: 2 |
| levels | loot_table, villager_trade | 7 | 0 | uniform[int]: 44 |
| log_length | feature | 0 | 0 | uniform[int]: 6 |
| monster_spawn_light_level | dimension_type | 2 | 0 | uniform[int]: 2 |
| offset | feature | 44 | 0 | uniform[int]: 1; also non-provider uses: array 35 in `feature`, 52 in `placed_feature` (block predicate `offset`) |
| outer_wall_distance | feature | 0 | 0 | uniform[int]: 1 |
| radius | feature | 48 | 0 | uniform[int]: 10, weighted_list[int]: 6 |
| rim_size | feature | 0 | 0 | uniform[int]: 1 |
| rolls | loot_table | 1515 | 0 | uniform[int]: 80 |
| room_vertical_radius_multiplier | carver | 0 | 1 | uniform[num]: 2 |
| size | feature, structure | 61 | 0 | uniform[int]: 1 |
| source | feature, placed_feature | 0 | 0 | uniform[int]: 3; also non-provider uses: string 71 in `loot_table` (`copy_components`) |
| speleothem_block_layer_thickness | feature | 0 | 0 | uniform[int]: 2 |
| stalactite_bluntness | feature | 0 | 0 | uniform[num]: 1 |
| stalagmite_bluntness | feature | 0 | 0 | uniform[num]: 1 |
| start_height | structure | 0 | 0 | uniform[height]: 1 |
| thickness | carver | 0 | 0 | trapezoid[num]: 4 |
| trunk_height | feature | 0 | 0 | uniform[int]: 1 |
| trunk_offset_y | feature | 0 | 0 | uniform[int]: 2 |
| values | block_state_provider, feature | 0 | 0 | uniform[int]: 7 |
| vertical_radius_multiplier | carver | 0 | 1 | uniform[num]: 2 |
| vertical_rotation | carver | 0 | 0 | uniform[num]: 1 |
| wetness | feature | 0 | 1 | clamped_normal[num]: 1 |
| wind_speed | feature | 0 | 0 | uniform[num]: 1 |
| x | feature, placed_feature | 54 | 0 | clamped_normal[int]: 2, trapezoid[int]: 89, uniform[int]: 3 |
| xz_offset | feature | 0 | 0 | trapezoid[int]: 2 |
| xz_radius | feature | 0 | 0 | uniform[int]: 7 |
| xz_size | feature | 0 | 0 | uniform[int]: 5 |
| y | carver, feature, placed_feature | 48 | 0 | clamped_normal[int]: 2, trapezoid[int]: 89, uniform[height]: 4, uniform[int]: 9 |
| y_offset | feature | 0 | 0 | trapezoid[int]: 1, uniform[int]: 1 |
| y_size | feature | 0 | 0 | uniform[int]: 5 |
| z | feature, placed_feature | 54 | 0 | clamped_normal[int]: 2, trapezoid[int]: 89, uniform[int]: 3 |

### 2.4 References: a string names an entry of another registry

Wherever a registry entry is a value, the value is a string `minecraft:<path>` (a reference) or an inline object of the same shape. Resolved
against the files, the reference slots are:

| Member (registry file) | String names an entry of | Inline object also allowed? (inferred from data) |
|---|---|---|
| `noise_settings.material_rule` | `worldgen/material_rule` | no inline in the data (7 of 7 strings) |
| `noise_settings.noise_router.*` | `worldgen/density_function`; a number is also allowed (4 of 7 `continents`, `depth`, `ridges`, ...) | yes (`final_density` 4, `temperature` 1, `vegetation` 1) |
| `noise_settings.aquifers.surface_level` and `debug_functions[].function` | `worldgen/density_function` | `function`: yes |
| `material_rule` `sequence[]`, `then_run` | `worldgen/material_rule` | yes (`then_run`: 40 strings, 123 objects; `sequence` arrays mix strings and objects) |
| `material_rule` `if_true` | `worldgen/material_condition` | yes (34 strings, 129 objects) |
| `density_function` operands (`input`, `left`, `right`, `first`, `second`, `when_*`, `shift_x`, `shift_z`, spline `coordinate`) | `worldgen/density_function` | yes; also numbers |
| `density_function` `noise`, `material_rule` `noise` | `worldgen/noise` | no inline |
| `placed_feature.feature` | `worldgen/feature` (a string in 273 of 273 files, each name exists there) | no in `placed_feature` files; in `worldgen/feature` files the member `feature` is a string (89), a typed feature object (91) or a placed feature object (15) |
| `random_selector.default`, `features[].feature`, `weighted` `data`, `feature_true`/`feature_false`, `vegetation_feature`, `coral` bodies | `worldgen/placed_feature` (a string), or an inline placed feature `{feature, placement}`, or an inline typed feature | yes |
| `template_pool.elements[].element.feature` | `worldgen/placed_feature` | |
| `template_pool.fallback` | `worldgen/template_pool` (`minecraft:empty` is a file) | no |
| `template_pool` element `processors` | `worldgen/processor_list` | yes (`{processors: [...]}`) |
| `structure.start_pool`, `structure_set.structures[].structure` | `worldgen/template_pool`, `worldgen/structure` | no |
| `structure.biomes` | a `#` tag of `tags/worldgen/biome` (always a tag string, 52 of 52) | no |
| feature `blocks`, `replaceable`, `valid_blocks`, `can_replace` ... (block sets) | a plain id, a `#` tag, or an array of ids (never a mixed array) | |
| `loot_table` entry `value` (type `loot_table`) | `loot_table` (a string, 54) | yes (an inline table object, 3) |
| `loot_table` `condition`, `terms[]`, `term` | `predicate` (a string, 137+76+1) | yes (objects) |
| `context_*_provider` `condition`, `on_true`, `on_false` | `predicate`, `context_*_provider` | no |
| `trade_set.trades`, structure/biome members | a `#` tag of `tags/villager_trade` (strings starting with `#`) | no |

### 2.5 Other union-valued members

| Member (where) | Forms that occur | Example |
|---|---|---|
| block sets: `blocks` (`matching_blocks`, feature members), `fluids`, `valid_blocks`, `accepted_neighbors` | a bare id; a `#` tag; an array of ids. None of the 49 arrays in these members (in `worldgen/feature`, `worldgen/placed_feature` and `predicate` files; 3 more in `advancement` files) contains a `#` tag (`tags` files do, previous row) | `"blocks": "minecraft:sand"`; `"blocks": ["minecraft:netherrack", "minecraft:basalt"]` |
| `tags/*` `values[]` | a plain id or a `#` tag (strings only; both may occur in one array) | `{"values": ["#minecraft:animals_spawnable_on", "#minecraft:badlands_terracotta", "minecraft:red_sand"]}` (`tags/block/armadillo_spawnable_on`) |
| recipe `ingredient`, `ingredients[]`, `key.*` values | a bare item id; a `#` item tag; an array of ids (a choice) | `"ingredient": "minecraft:stone"`; `"ingredient": ["minecraft:copper_pickaxe", "minecraft:copper_shovel"]` |
| recipe `result`, `output`, villager `gives`, `wants`, `additional_wants` | an item stack object `{id, count?, components?}`: `count` an integer (727 of 1,744 recipe results carry it), `components` an object (17) | `{"id": "minecraft:acacia_button"}`; `{"count": 12, "id": "minecraft:emerald"}` |
| `processor` rule `output_state` | a plain block id (152) or a state object (12) | `"output_state": "minecraft:mossy_cobblestone"` |
| structure `max_distance_from_center` | an integer (28 of 28 in the data; the document 36-3 also allows an object) | `"max_distance_from_center": 80` |
| `offset` | foliage placers: an integer or an int provider; block predicates: an array of 3 integers; placement `offset` has `x`, `y`, `z` members, each an integer or a provider | `"offset": [0, 1, 0]` |
| loot `condition` of an entry | a string (a `predicate` file) or a typed object | `"condition": "minecraft:tool/can_silk_touch"` |
| structure `spawn_overrides.<group>.spawns[]` | objects `{count, type, weight}`; `type` is an entity id (not a discriminator), `count` an integer or `uniform` provider | |
| `random_selector.default` | a string (a placed feature), or an inline placed feature | `"default": {"feature": "minecraft:oak_bees_005", "placement": []}` |
| `noise_settings.noise_router.temperature` | an id, a number or a typed density function | |
| `noise_settings.spawn_target[]` | objects keyed by **density function ids** (`minecraft:overworld/continents`, ...), each value an array of two decimals `[min, max]` | `{"minecraft:overworld/continents": [-0.11, 1.0], ...}` |

### 2.6 Number tokens and members that mix `int` and `num`

A slot written with a decimal point holds a float and a slot written without holds an integer, with these exceptions (inferred rule: a
float field never holds an integer token and an integer field never holds a decimal, except where this table lists a mixture):

| Member (kind of object) | Mixture | Reading |
|---|---|---|
| `uniform.min` / `.max` in `loot_table` | 658 integer pairs, 108 decimal pairs | integer pair: an int provider; decimal pair: a float provider |
| `uniform.min_inclusive` in `worldgen/feature` | 110 integer, 6 decimal | decimal ones are float providers (`max_exclusive` instead of `max_inclusive`) |
| `weight` in untyped objects of `worldgen/structure` | 10 integer, 9 decimal | decimal: `ruined_portal` `setups[].weight` (`0.5`, `1.0`); integer: pool alias `groups[]` and `targets[]` weights |
| `base`, `min` in `enchantment` | integer and decimal | `soul_speed` and `lunge` effect values |

### 2.7 File roots and top-level members per registry

The root of a file is an object in all registries except: `block_transformer` (an array of objects), 4 `context_int_provider` files
(an integer), 3 `context_float_provider` files (a decimal) and `worldgen/density_function/zero` (the number `0.0`). The table lists the
members that occur in every file (required in practice) and in some (optional, with the count of files); `type`-rooted registries
list the union of members over all types, so see sections 3 and 4 for per-type members.

| registry | root kinds | n objects | required top-level members | optional top-level members |
|---|---|---|---|---|
| banner_pattern | obj 43 | 43 | asset_id:id, translation_key:str | - |
| block_transformer | arr[obj] 3 | 0 | - | - |
| cat_sound_variant | obj 2 | 2 | adult_sounds:obj, baby_sounds:obj | - |
| cat_variant | obj 11 | 11 | asset_id:id, baby_asset_id:id, spawn_conditions:arr[obj] | - |
| chat_type | obj 7 | 7 | chat:obj, narration:obj | - |
| chicken_sound_variant | obj 2 | 2 | adult_sounds:obj, baby_sounds:obj | - |
| chicken_variant | obj 3 | 3 | asset_id:id, baby_asset_id:id, spawn_conditions:arr[obj] | model:str{cold} (1) |
| context_float_provider | num 3, o{type} 1 | 1 | condition:id, on_false:id, on_true:id | - |
| context_int_provider | int 4, o{type} 22 | 22 | - | cases:arr[obj] (4), default:o{type} (4), left:int (18), right:o{type} (18) |
| cow_sound_variant | obj 2 | 2 | ambient_sound:id, death_sound:id, hurt_sound:id, step_sound:id | - |
| cow_variant | obj 3 | 3 | asset_id:id, baby_asset_id:id, spawn_conditions:arr[obj] | model:str{cold/warm} (2) |
| damage_type | obj 51 | 51 | exhaustion:num, message_id:str, scaling:str{always/when_caused_by_living_non_player} | death_message_type:str{fall_variants/intentional_game_design} (3), effects:str{burning/drowning/freezing/poking/thorns} (12) |
| decorated_pot_pattern | obj 23 | 23 | asset_id:id | - |
| dialog | o{type} 3 | 3 | button_width:int, columns:int, exit_action:obj, external_title:obj, title:obj | dialogs:tag (2) |
| dimension_type | obj 4 | 4 | ambient_light:num, attributes:obj, coordinate_scale:num, has_ceiling:bool, has_ender_dragon_fight:bool, has_skylight:bool, height:int, infiniburn:tag, logical_height:int, min_y:int, monster_spawn_block_light_limit:int, monster_spawn_light_level:int or o{type}, timelines:tag | cardinal_light:str{nether} (1), default_clock:id (3), has_fixed_time:bool (2), skybox:str{end/none} (2) |
| enchantment | obj 43 | 43 | anvil_cost:int, description:obj, max_cost:obj, max_level:int, min_cost:obj, slots:arr[str], supported_items:tag, weight:int | effects:obj (42), exclusive_set:tag (18), primary_items:tag (5) |
| enchantment_provider | o{type} 7 | 7 | - | enchantment:id (6), enchantments:tag (1), level:int (6), max_cost_span:int (1), min_cost:int (1) |
| frog_variant | obj 3 | 3 | asset_id:id, spawn_conditions:arr[obj] | - |
| instrument | obj 8 | 8 | description:obj, range:num, sound_event:id, use_duration:num | - |
| jukebox_song | obj 22 | 22 | comparator_output:int, description:obj, length_in_seconds:num, sound_event:id | - |
| loot_table | o{type} 1447 | 1447 | random_sequence:id | modifier:o{type} (9), pools:arr[obj] (1403) |
| painting_variant | obj 51 | 51 | asset_id:id, height:int, title:obj, width:int | author:obj (46) |
| pig_sound_variant | obj 3 | 3 | adult_sounds:obj, baby_sounds:obj | - |
| pig_variant | obj 3 | 3 | asset_id:id, baby_asset_id:id, spawn_conditions:arr[obj] | model:str{cold} (1) |
| predicate | o{type} 3 | 3 | - | blocks:arr[id] (1), predicate:obj (2) |
| recipe | o{type} 2042 | 2042 | - | add_material_count_to_result:bool (1), addition:tag (30), back:tag (1), banner:id or tag (17), base:id or tag (30), category:str{blocks/building/equipment/food/redstone} (800), cookingtime:int (116), dye:tag (8), experience:num (116), front:tag (1), fuel:id (2), group:str (808), ingredient:arr[id] or id or tag (467), ingredients:arr[arr[id] or id] or arr[id or tag] or arr[id] or arr[tag] (375), input:obj or tag (312), key:obj (827), left:tag (1), map:tag (1), material:id or tag (36), material_count:obj (1), output:o{id} (279), pattern:arr[str or tag] or arr[str] or arr[tag] or id (845), reagent:obj (279), result:obj or o{id} (1744), right:tag (1), shapes:obj (1), shell:id (1), show_notification:bool (1), source:id (2), star:id (1), target:id (8), template:id (30), trail:id (1), twinkle:id (1) |
| sulfur_cube_archetype | obj 12 | 12 | attribute_modifiers:arr[o{id}], items:tag, knockback_modifiers:obj, sound_settings:obj | buoyant:bool (5), contact_damage:obj (1), explosion:obj (1) |
| tags | obj 883 | 883 | values:arr[] or arr[id or tag] or arr[id] or arr[tag] | - |
| test_environment | o{type} 1 | 1 | definitions:arr[] | - |
| test_instance | o{type} 1 | 1 | environment:id, function:id, max_ticks:int, required:bool, setup_ticks:int, structure:id | - |
| timeline | obj 4 | 4 | clock:id, tracks:obj | period_ticks:int (3), time_markers:obj (1) |
| trade_set | obj 68 | 68 | amount:int, random_sequence:id, trades:tag | - |
| trial_spawner | obj 28 | 28 | simultaneous_mobs_added_per_player:num, spawn_potentials:arr[obj], ticks_between_spawn:int | loot_tables_to_eject:arr[obj] (14), simultaneous_mobs:num (25), total_mobs:num (6), total_mobs_added_per_player:num (2) |
| trim_material | obj 11 | 11 | description:obj, palette_id:id | - |
| trim_pattern | obj 18 | 18 | asset_id:id, decal:bool, description:obj | - |
| villager_trade | obj 391 | 391 | gives:o{id}, reputation_discount:num, wants:o{id} | additional_wants:o{id} (18), double_trade_price_enchantments:tag (4), given_item_modifier:arr[o{type}] or o{type} (41), max_uses:int (374), merchant_predicate:o{type} (27), xp:int (266) |
| wolf_sound_variant | obj 7 | 7 | adult_sounds:obj, baby_sounds:obj | - |
| wolf_variant | obj 9 | 9 | assets:obj, baby_assets:obj, spawn_conditions:arr[obj] | - |
| world_clock | obj 2 | 2 | - | - |
| worldgen/biome | obj 67 | 67 | attributes:obj, carvers:arr[] or arr[id] or id, downfall:num, effects:obj, features:arr[] or arr[arr[] or arr[id]] or arr[arr[id]], has_precipitation:bool, temperature:num | temperature_modifier:str{frozen} (2) |
| worldgen/block_state_provider | o{type} 8 | 8 | - | default_state:id (1), entries:arr[obj] (1), high_chance:num (1), high_states:arr[id] (1), low_states:arr[id] (1), noise:obj (3), property:str{age} (2), rules:arr[obj] (2), scale:num (3), seed:int (3), slow_noise:obj (1), slow_scale:num (1), source:o{id} or o{type} (2), states:arr[id] (2), threshold:num (1), values:o{type} (2), variety:arr[int] (1) |
| worldgen/carver | o{type} 4 | 4 | probability:num, y:o{type} | count:o{type} (3), floor_level:num or o{type} (3), horizontal_radius_multiplier:num or o{type} (3), room_vertical_radius_multiplier:num or o{type} (3), shape:obj (1), start_vertical_radius_multiplier:num (1), thickness:o{type} (3), vertical_radius_multiplier:num or o{type} (3), vertical_rotation:o{type} (1), weird_thickness_bias:bool (2) |
| worldgen/density_function | o{type} 54, num 1 | 54 | - | axis:str{y} (1), cell_height:int (3), cell_size_xz:int (3), cell_size_y:int (3), density:o{type} (3), from_coordinate:int (1), from_value:num (1), input:id or o{type} (33), left:id or num or o{type} (10), lower_bound:int (3), max:num (1), max_exclusive:num (3), min:num (1), min_inclusive:num (3), noise:id (4), right:id or num or o{type} (10), shift_x:id (4), shift_z:id (4), smear_scale_multiplier:num (3), to_coordinate:int (1), to_value:num (1), upper_bound:o{type} (3), when_in_range:num or o{type} (3), when_out_of_range:num or o{type} (3), xz_factor:num (3), xz_scale:num (7), y_factor:num (3), y_scale:num (7) |
| worldgen/feature | o{type} 240 | 240 | - | accepted_neighbors:id (1), active:bool (1), allowed_placement:o{type} (6), allowed_tree_position:o{type} (2), allowed_vertical_water_for_tree:int (2), attempts:int (1), barrier:o{id} (1), base_block:id (2), below_trunk_provider:id or o{id} (45), block:id or o{id} (3), blocks:obj (1), can_be_placed_on:arr[id] (2), can_place_feature:o{type} (1), can_place_on:o{type} (4), can_place_on_ceiling:bool (2), can_place_on_floor:bool (1), can_place_on_wall:bool (2), can_replace:o{type} (2), can_replace_with_air_or_fluid:o{type} (1), can_replace_with_barrier:o{type} (1), cap_provider:o{id} (2), chance_of_speleothem_at_max_distance_from_center:num (2), chance_of_spreading:num (1), column_radius:o{type} (1), contents:id (1), crack:obj (1), decor_state:id (4), decorators:arr[] or arr[o{type}] (45), default:id or obj (21), density:o{type} (2), depth:int or o{type} (7), direction:str{down/up} (6), discard_chance_on_air_exposure:num (32), exact:bool (2), exit:arr[int] (1), extra_bottom_block_chance:num (7), extra_edge_column_chance:num (7), feature:obj (2), feature_false:obj (2), feature_true:obj (2), features:arr[obj] (47), floor_search_range:int (1), floor_to_ceiling_search_range:int (2), fluid:o{id} (1), foliage_placer:o{type} (45), foliage_provider:o{id} or o{type} (45), foliage_radius:int (1), fossil_processors:id (2), fossil_structures:arr[id] (2), ground_state:o{id} (7), half_height:int (5), hanging_root_placement_attempts:int (2), hanging_root_radius:int (2), hanging_root_state_provider:o{id} (2), hanging_roots_vertical_span:int (2), hat_state:id (4), height:o{type} (2), height_deviation:int (2), height_scale:o{type} (1), hole_count:int (1), ignore_vines:bool (45), invalid_blocks_threshold:int (1), layers:arr[obj] or obj (7), level_test_distance:int (2), log_decorators:arr[o{type}] (6), log_length:o{type} (6), max_column_radius_to_cave_height_ratio:num (1), max_distance_from_center_affecting_height_bias:int (2), max_distance_from_edge_affecting_chance_of_speleothem:int (2), max_empty_corners_allowed:int (2), max_level_deviation:int (2), max_stalagmite_stalactite_height_diff:int (2), min_bluntness_for_wind:num (1), min_radius_for_wind:int (1), minimum_size:o{type} (45), outer_wall_distance:o{type} (1), overlay_processors:id (2), overlay_structures:arr[id] (2), placement_probability_per_valid_position:num (1), placement_radius_around_floor:int (1), planted:bool (2), pointed_block:id (2), prioritize_tip:bool (6), probability:num (2), radius:o{type} (9), replaceable:tag (7), replaceable_blocks:o{type} or tag (7), required_vertical_space_for_tree:int (2), requires_block_below:bool (2), rim:id (1), rim_size:o{type} (1), rock_count:int (1), root_column_max_height:int (2), root_placement_attempts:int (2), root_placer:o{type} (2), root_radius:int (2), root_replaceable:tag (2), root_state_provider:o{id} (2), schedule_tick:bool (2), search_range:int (2), size:int or o{type} (33), speleothem_block_layer_thickness:o{type} (2), spikes:arr[] (1), stalactite_bluntness:o{type} (1), stalagmite_bluntness:o{type} (1), state:id or o{id} (12), state_provider:o{id} or o{type} (10), stem_provider:o{id} (2), stem_state:id (4), stump_decorators:arr[] or arr[o{type}] (6), surface:str{ceiling/floor} (7), target:id or o{type} (7), targets:arr[obj] (32), to_place:id or o{id} or o{type} (37), trunk_placer:o{type} (45), trunk_provider:o{id} (51), use_alternate_layer0_chance:num (1), valid_base_block:id (4), valid_blocks:arr[id] or id (6), vegetation_chance:num (7), vegetation_feature:obj (7), vertical_range:int (7), wetness:num or o{type} (2), wind_speed:o{type} (1), xz_offset:o{type} (1), xz_radius:o{type} (7), y_offset:o{type} (1) |
| worldgen/flat_level_generator_preset | obj 9 | 9 | display:id, settings:obj | - |
| worldgen/material_condition | o{type} 8 | 8 | offset:int | add_stone_depth:bool (2), add_surface_depth:bool (6), secondary_depth_range:int (6), surface_depth_multiplier:int (2), surface_type:str{ceiling/floor} (6) |
| worldgen/material_rule | o{type} 42 | 42 | - | density:id (2), filler_block:id (2), filler_gap:id (2), if_true:id or o{type} (8), ore_block:id (2), raw_ore_block:id (2), raw_ore_chance:num (2), result_state:id (6), richness:id (2), sequence:arr[id or o{type}] or arr[id] or arr[o{type}] (26), then_run:o{type} (8) |
| worldgen/multi_noise_biome_source_parameter_list | obj 2 | 2 | preset:id | - |
| worldgen/noise | obj 64 | 64 | base_amplitude:num, base_octave:int | amplitude_modifiers:arr[num] (20), octave_count:int (33) |
| worldgen/noise_settings | obj 7 | 7 | debug_functions:arr[obj], default_block:id, default_fluid:id, disable_mob_generation:bool, legacy_random_source:bool, material_rule:id, noise:obj, noise_router:obj, sea_level:int, spawn_target:arr[] or arr[obj] | aquifers:obj (3) |
| worldgen/placed_feature | obj 273 | 273 | feature:id, placement:arr[] or arr[o{type}] | - |
| worldgen/processor_list | obj 40 | 40 | processors:arr[] or arr[o{proc}] | - |
| worldgen/structure | o{type} 52 | 52 | biomes:tag, spawn_overrides:obj, step:str{surface_structures/underground_decoration/underground_structures} | biome_temp:str{cold/warm} (2), cluster_probability:num (2), dimension_padding:int (1), height:o{type} (1), is_beached:bool (2), large_probability:num (2), liquid_settings:str{ignore_waterlogging} (1), max_distance_from_center:int (28), mineshaft_type:str{mesa/normal} (2), pool_aliases:arr[o{type}] (1), project_start_to_heightmap:str{WORLD_SURFACE_WG} (25), setups:arr[obj] (7), size:int (28), start_height:obj or o{type} (28), start_jigsaw_name:id (1), start_pool:id (28), terrain_adaptation:str{beard_box/beard_thin/bury/encapsulate} (29), use_expansion_hack:bool (28) |
| worldgen/structure_set | obj 21 | 21 | placement:o{type}, structures:arr[obj] | - |
| worldgen/template_pool | obj 245 | 245 | elements:arr[] or arr[obj], fallback:id | - |
| worldgen/world_preset | obj 7 | 7 | dimensions:obj | - |
| zombie_nautilus_variant | obj 2 | 2 | asset_id:id, spawn_conditions:arr[obj] | model:str{warm} (1) |

### 2.8 Unnamed sub-objects

Objects that have no discriminator member, keyed by the member that holds them (registry / member name). Members are required if they appear in every
instance. These replace guessed shapes for ore targets, weighted entries, layers, spline points, noise parameters, pool elements and similar.
The table covers the worldgen registries that the content loaders read, `loot_table` pools, `villager_trade` item stacks and `block_transformer`; the
unnamed sub-objects of `biome`, `enchantment`, `timeline`, `trial_spawner`, `dimension_type`, `recipe` and `predicate` files are not tabulated (Open question 7).
The rows are ordered alphabetically by registry, then by member, except that the last twelve rows are out of order (added later).

| registry / member holding the object | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| block_state_provider / data | 2 | id:id, properties:obj | - |
| block_state_provider / entries | 4 | data:id or o{id}, weight:int | - |
| block_state_provider / noise | 3 | base_amplitude:num, base_octave:int | - |
| block_state_provider / properties | 4 | - | age:str{0} (2), berries:str{true} (2), hanging:str{true} (1), snowy:str{false} (1), stage:str{0} (1), waterlogged:str{false} (1) |
| block_state_provider / rules | 2 | if_true:o{type}, then:o{id} | - |
| block_state_provider / slow_noise | 1 | base_amplitude:num, base_octave:int | - |
| block_state_provider / source | 1 | id:id, properties:obj | - |
| block_state_provider / then | 2 | id:id | properties:obj (1) |
| carver / max_inclusive | 4 | - | absolute:int (3), below_top:int (1) |
| carver / min_inclusive | 4 | - | above_bottom:int (2), absolute:int (2) |
| carver / shape | 1 | distance_factor:o{type}, horizontal_radius_factor:o{type}, thickness:o{type}, vertical_radius_center_factor:num, vertical_radius_default_factor:num, width_smoothness:int, y_scale:num | - |
| density_function / points | 1290 | derivative:num, location:num, value:num or obj | - |
| density_function / spline | 9 | coordinate:id, points:arr[obj] | - |
| density_function / value | 345 | coordinate:id, points:arr[obj] | - |
| feature / above_root_placement | 2 | above_root_placement_chance:num, above_root_provider:o{id} | - |
| feature / above_root_provider | 2 | id:id | - |
| feature / alternate_inner_layer_provider | 1 | id:id | - |
| feature / barrier | 2 | id:id | - |
| feature / below_trunk_provider | 1 | id:id | - |
| feature / block | 11 | id:id | properties:obj (9) |
| feature / block_provider | 1 | id:id | - |
| feature / blocks | 1 | alternate_inner_layer_provider:o{id}, cannot_replace:tag, filling_provider:o{id}, inner_layer_provider:o{id}, inner_placements:arr[id], invalid_blocks:tag, middle_layer_provider:o{id}, outer_layer_provider:o{id} | - |
| feature / branch_start_offset_from_top | 2 | max_inclusive:int, min_inclusive:int | - |
| feature / cap_feature | 1 | feature:o{type}, placement:arr[] | - |
| feature / cap_provider | 2 | id:id, properties:obj | - |
| feature / crack | 1 | generate_crack_chance:num | - |
| feature / data | 338 | - | feature:id or o{type} (21), id:id (317), placement:arr[] or arr[o{type}] (21), properties:obj (304) |
| feature / default | 2 | feature:id, placement:arr[] or arr[o{type}] | - |
| feature / distribution | 54 | data:int or o{type}, weight:int | - |
| feature / entries | 374 | data:id or o{id}, weight:int | - |
| feature / fallback | 2 | id:id | - |
| feature / feature | 15 | feature:id, placement:arr[] or arr[o{type}] | - |
| feature / feature_false | 2 | feature:id, placement:arr[] | - |
| feature / feature_true | 2 | feature:id, placement:arr[] | - |
| feature / features | 159 | - | chance:num (53), data:id or obj (26), feature:id or obj or o{type} (133), placement:arr[] or arr[o{type}] (80), weight:int (26) |
| feature / filling_provider | 1 | id:id | - |
| feature / fluid | 2 | id:id, properties:obj | - |
| feature / foliage_provider | 44 | id:id, properties:obj | - |
| feature / ground_state | 7 | id:id | - |
| feature / hanging_root_state_provider | 2 | id:id | properties:obj (1) |
| feature / inner_layer_provider | 1 | id:id | - |
| feature / layers | 24 | - | height:int or o{type} (23), provider:id or o{id} or o{type} (23) |
| feature / mangrove_root_placement | 2 | can_grow_through:tag, max_root_length:int, max_root_width:int, muddy_roots_in:arr[id], muddy_roots_provider:o{id}, random_skew_chance:num | - |
| feature / max_inclusive | 4 | relative_to_sea_level:int | - |
| feature / middle_layer_provider | 1 | id:id | - |
| feature / min_inclusive | 4 | above_bottom:int | - |
| feature / muddy_roots_provider | 2 | id:id, properties:obj | - |
| feature / outer_layer_provider | 1 | id:id | - |
| feature / processors | 2 | processors:arr[o{proc}] | - |
| feature / provider | 15 | id:id | properties:obj (10) |
| feature / root_provider | 2 | id:id, properties:obj | - |
| feature / root_state_provider | 2 | id:id | - |
| feature / rules | 5 | - | block_entity_modifier:o{type} (2), if_true:o{type} (3), input_predicate:o{ptype} (2), location_predicate:o{ptype} (2), output_state:id (2), then:o{id} (3) |
| feature / source | 5 | id:id, properties:obj | - |
| feature / state | 7 | id:id, properties:obj | - |
| feature / state_provider | 5 | id:id | properties:obj (1) |
| feature / stem_provider | 2 | id:id, properties:obj | - |
| feature / targets | 49 | state:id, target:o{ptype} | - |
| feature / templates | 13 | data:o{id}, weight:int | - |
| feature / then | 3 | id:id | properties:obj (2) |
| feature / to_place | 52 | id:id | properties:obj (20) |
| feature / trunk_provider | 51 | id:id, properties:obj | - |
| feature / vegetation_feature | 7 | feature:id, placement:arr[] | - |
| material_rule / anchor | 23 | - | absolute:int (22), below_top:int (1) |
| material_rule / false_at_and_above | 3 | - | above_bottom:int (1), absolute:int (1), below_top:int (1) |
| material_rule / true_at_and_below | 3 | - | above_bottom:int (1), absolute:int (1), below_top:int (1) |
| noise_settings / aquifers | 3 | barrier:o{type}, exclusion:o{type}, fluid_level_floodedness:o{type}, fluid_level_spread:o{type}, lava:o{type}, surface_level:id | - |
| noise_settings / debug_functions | 34 | function:id or o{type}, label:str | - |
| noise_settings / noise | 7 | height:int, min_y:int | - |
| noise_settings / noise_router | 7 | chunk_surface_level:id or num, continents:id or num, depth:id or num, erosion:id or num, final_density:id or o{type}, ridges:id or num, temperature:id or num or o{type}, vegetation:id or num or o{type} | - |
| noise_settings / spawn_target | 6 | minecraft:overworld/ridges:arr[num] | minecraft:overworld/continents:arr[num] (4), minecraft:overworld/erosion:arr[num] (4), minecraft:overworld/temperature:arr[num] (4), minecraft:overworld/vegetation:arr[num] (4), minecraft:overworld_large_biomes/continents:arr[num] (2), minecraft:overworld_large_biomes/erosion:arr[num] (2), minecraft:overworld_large_biomes/temperature:arr[num] (2), minecraft:overworld_large_biomes/vegetation:arr[num] (2) |
| placed_feature / distribution | 44 | data:int, weight:int | - |
| placed_feature / max_inclusive | 86 | - | above_bottom:int (4), absolute:int (54), below_top:int (28) |
| placed_feature / min_inclusive | 86 | - | above_bottom:int (57), absolute:int (29) |
| processor_list / block_state | 8 | id:id, properties:obj | - |
| processor_list / output_state | 12 | id:id, properties:obj | - |
| processor_list / properties | 20 | - | east:str{false/true} (16), facing:str{north} (1), lit:str{false/true} (4), north:str{false/true} (16), powered:str{false} (3), signal_fire:str{false} (1), south:str{false/true} (16), waterlogged:str{false} (17), west:str{false/true} (16) |
| processor_list / rules | 164 | input_predicate:o{ptype}, location_predicate:o{ptype}, output_state:id or o{id} | block_entity_modifier:o{type} (4), position_predicate:o{ptype} (1) |
| structure / ambient | 2 | bounding_box:str{full/piece}, spawns:arr[] | - |
| structure / axolotls | 3 | bounding_box:str{full/piece}, spawns:arr[] | - |
| structure / creature | 3 | bounding_box:str{full/piece}, spawns:arr[] or arr[o{type}] | - |
| structure / groups | 3 | data:arr[o{type}], weight:int | - |
| structure / max_inclusive | 2 | - | absolute:int (1), below_top:int (1) |
| structure / min_inclusive | 2 | absolute:int | - |
| structure / misc | 2 | bounding_box:str{full/piece}, spawns:arr[] | - |
| structure / monster | 6 | bounding_box:str{full/piece}, spawns:arr[] or arr[o{type}] | - |
| structure / setups | 9 | air_pocket_probability:num, can_be_cold:bool, mossiness:num, overgrown:bool, placement:str{in_mountain/in_nether/on_land_surface/on_ocean_floor/partly_buried/underground}, replace_with_blackstone:bool, vines:bool, weight:num | - |
| structure / spawn_overrides | 52 | - | ambient:obj (2), axolotls:obj (3), creature:obj (3), misc:obj (2), monster:obj (6), underground_water_creature:obj (3), water_ambient:obj (2), water_creature:obj (2) |
| structure / start_height | 27 | absolute:int | - |
| structure / targets | 7 | data:id, weight:int | - |
| structure / underground_water_creature | 3 | bounding_box:str{full/piece}, spawns:arr[] | - |
| structure / water_ambient | 2 | bounding_box:str{full/piece}, spawns:arr[] | - |
| structure / water_creature | 2 | bounding_box:str{full/piece}, spawns:arr[] | - |
| structure_set / exclusion_zone | 1 | chunk_count:int, other_set:id | - |
| structure_set / structures | 52 | structure:id, weight:int | - |
| template_pool / elements | 2281 | element:o{etype}, weight:int | - |
| template_pool / processors | 1439 | processors:arr[] | - |
| block_transformer / rules | 134 | if_true:o{type}, then:o{id} or o{type} | - |
| block_transformer / source | 130 | id:id | properties:obj or o{type} (109) |
| block_transformer / then | 4 | id:id | properties:obj (1) |
| flat_level_generator_preset / layers | 33 | block:id, height:int | - |
| flat_level_generator_preset / settings | 9 | biome:id, features:bool, lakes:bool, layers:arr[obj], structure_overrides:arr[] or arr[id] or id | - |
| loot_table / pools | 1595 | entries:arr[o{type}], rolls:int or o{type} | condition:id or o{type} (1035), modifier:arr[o{type}] or o{type} (10) |
| villager_trade / additional_wants | 18 | id:id | count:int (1) |
| villager_trade / gives | 391 | id:id | count:int (83) |
| villager_trade / wants | 391 | id:id | components:obj (1), count:int (219) |
| world_preset / dimensions | 7 | minecraft:overworld:o{type}, minecraft:the_end:o{type}, minecraft:the_nether:o{type} | - |
| world_preset / layers | 9 | block:id, height:int | - |
| world_preset / settings | 4 | biome:id, features:bool, lakes:bool, layers:arr[obj] | structure_overrides:arr[id] (1) |

---

## 3. Member census of the worldgen type families

For each type the instances of that type were collected over all files (nested instances included), and the members were counted. A
member that occurs in **every** instance is listed as required in practice; a member present in only some instances is optional in
practice, with the number of instances that have it in parentheses. "n" is the number of instances (not files). The discriminator
member itself (`type`, `predicate_type`, `element_type`, `processor_type`) is omitted. The kinds are those of the legend above. Members that are
`id` hold block ids, registry references or other ids depending on the slot (sections 2.2 and 2.4).

The family of an object is decided by the member that holds it, not by the type name alone (`not`, `all_of`, `any_of`, `noise`, `noise_threshold`,
`biome`, `count`, `offset`, `weighted`, `block` appear in several families with different members). `minecraft:`-prefixes are dropped from the type names.

### 3.1 Feature types

The `type` of a `worldgen/feature` file (47 types at file level) and of features nested inside other features (member `feature`, `features[].feature`, `default`, `data`, `cap_feature`, `vegetation_feature`, `coral_*` bodies). Nested uses add these types to the file-level 47: `coral_claw`, `coral_tree`, `no_op`, `projected_random_patchy_square`, `sculk_patch`, `single_block_pillar`, `speleothem`, `stepped_column_cluster`, `template`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| bamboo | 2 | probability:num | - |
| block_blob | 1 | can_place_on:o{type}, state:id | - |
| block_column | 12 | allowed_placement:o{type}, direction:str{down/up}, layers:arr[obj], prioritize_tip:bool | - |
| block_pile | 5 | state_provider:o{id} or o{type} | - |
| blue_ice | 1 | - | - |
| bonus_chest | 1 | - | - |
| chorus_plant | 1 | - | - |
| coral_claw | 5 | feature:obj | - |
| coral_tree | 5 | feature:obj | - |
| delta_feature | 1 | contents:id, rim:id, rim_size:o{type}, size:o{type} | - |
| disk | 5 | half_height:int, radius:o{type}, state_provider:o{id} or o{type}, target:o{type} | - |
| end_gateway | 2 | exact:bool | exit:arr[int] (1) |
| end_island | 1 | - | - |
| end_platform | 1 | - | - |
| end_podium | 2 | - | active:bool (1) |
| end_spike | 1 | spikes:arr[] | - |
| fallen_tree | 6 | log_decorators:arr[o{type}], log_length:o{type}, stump_decorators:arr[] or arr[o{type}], trunk_provider:o{id} | - |
| fossil | 2 | fossil_processors:id, fossil_structures:arr[id], max_empty_corners_allowed:int, overlay_processors:id, overlay_structures:arr[id] | - |
| freeze_top_layer | 1 | - | - |
| geode | 1 | blocks:obj, crack:obj, invalid_blocks_threshold:int, layers:obj, outer_wall_distance:o{type}, use_alternate_layer0_chance:num | - |
| huge_brown_mushroom | 1 | can_place_on:o{type}, cap_provider:o{id}, foliage_radius:int, stem_provider:o{id} | - |
| huge_fungus | 4 | decor_state:id, hat_state:id, replaceable_blocks:o{type}, stem_state:id, valid_base_block:id | planted:bool (2) |
| huge_red_mushroom | 1 | can_place_on:o{type}, cap_provider:o{id}, stem_provider:o{id} | - |
| iceberg | 2 | state:id | - |
| lake | 2 | barrier:o{id}, can_place_feature:o{type}, can_replace_with_air_or_fluid:o{type}, can_replace_with_barrier:o{type}, fluid:o{id} | - |
| large_dripstone | 1 | column_radius:o{type}, height_scale:o{type}, max_column_radius_to_cave_height_ratio:num, min_bluntness_for_wind:num, min_radius_for_wind:int, replaceable_blocks:tag, stalactite_bluntness:o{type}, stalagmite_bluntness:o{type}, wind_speed:o{type} | - |
| monster_room | 1 | - | - |
| multiface_growth | 2 | block:id, can_be_placed_on:arr[id], can_place_on_ceiling:bool, can_place_on_wall:bool, search_range:int | can_place_on_floor:bool (1), chance_of_spreading:num (1) |
| netherrack_replace_blobs | 2 | radius:o{type}, state:id, target:id | - |
| no_op | 2 | - | - |
| ore | 30 | discard_chance_on_air_exposure:num, size:int, targets:arr[obj] | - |
| overlay | 14 | features:arr[obj] or obj | - |
| projected_random_patchy_square | 1 | block:o{type}, max_projection_height:int, project_through:o{type}, size:int | - |
| random_boolean_selector | 2 | feature_false:obj, feature_true:obj | - |
| random_neighbor_spread | 2 | accepted_neighbors:arr[id] or id, attempts:int, block:o{id}, can_replace:o{type}, xz_offset:o{type}, y_offset:o{type} | - |
| random_selector | 21 | default:id or obj, features:arr[obj] | - |
| root_system | 2 | allowed_tree_position:o{type}, allowed_vertical_water_for_tree:int, feature:obj, hanging_root_placement_attempts:int, hanging_root_radius:int, hanging_root_state_provider:o{id}, hanging_roots_vertical_span:int, level_test_distance:int, max_level_deviation:int, required_vertical_space_for_tree:int, root_column_max_height:int, root_placement_attempts:int, root_radius:int, root_replaceable:tag, root_state_provider:o{id} | - |
| scattered_ore | 2 | discard_chance_on_air_exposure:num, size:int, targets:arr[obj] | - |
| sculk_patch | 2 | amount_per_charge:int, charge_count:int, growth_rounds:int, spread_attempts:int, spread_rounds:int | - |
| sequence | 7 | features:arr[obj] | - |
| simple_block | 75 | to_place:id or o{id} or o{type} | schedule_tick:bool (2) |
| simple_random_selector | 5 | features:arr[obj] | - |
| single_block_pillar | 5 | block:o{id}, can_replace:o{type}, direction:str{down} | cap_feature:obj (1), chance_to_continue:num (4) |
| speleothem | 4 | base_block:id, pointed_block:id, replaceable_blocks:tag | - |
| speleothem_cluster | 2 | base_block:id, chance_of_speleothem_at_max_distance_from_center:num, density:o{type}, floor_to_ceiling_search_range:int, height:o{type}, height_deviation:int, max_distance_from_center_affecting_height_bias:int, max_distance_from_edge_affecting_chance_of_speleothem:int, max_stalagmite_stalactite_height_diff:int, pointed_block:id, radius:o{type}, replaceable_blocks:tag, speleothem_block_layer_thickness:o{type}, wetness:num or o{type} | - |
| spike | 1 | can_place_on:o{type}, can_replace:o{type}, state:id | - |
| spring_feature | 6 | state:o{id}, valid_blocks:arr[id] or id | hole_count:int (1), requires_block_below:bool (2), rock_count:int (1) |
| stepped_column_cluster | 4 | block:o{id}, can_replace:o{type}, cannot_place_on:tag, cluster_reach:int, column_count:int, column_reach:int or o{type}, continue_through:o{type}, height:o{type} | - |
| template | 7 | templates:arr[obj] | processors:obj (2) |
| tree | 45 | below_trunk_provider:id or o{id}, decorators:arr[] or arr[o{type}], foliage_placer:o{type}, foliage_provider:o{id} or o{type}, ignore_vines:bool, minimum_size:o{type}, trunk_placer:o{type}, trunk_provider:o{id} | root_placer:o{type} (2) |
| underwater_magma | 1 | floor_search_range:int, placement_probability_per_valid_position:num, placement_radius_around_floor:int | - |
| vegetation_patch | 6 | depth:int or o{type}, extra_bottom_block_chance:num, extra_edge_column_chance:num, ground_state:o{id}, replaceable:tag, surface:str{ceiling/floor}, vegetation_chance:num, vegetation_feature:obj, vertical_range:int, xz_radius:o{type} | - |
| vines | 1 | - | - |
| void_start_platform | 1 | - | - |
| waterlogged_vegetation_patch | 1 | depth:int, extra_bottom_block_chance:num, extra_edge_column_chance:num, ground_state:o{id}, replaceable:tag, surface:str{floor}, vegetation_chance:num, vegetation_feature:obj, vertical_range:int, xz_radius:o{type} | - |
| weighted_random_selector | 10 | features:arr[obj] | - |

### 3.2 Placement modifier types

Elements of `placement` (all 273 `placed_feature` files, and inline placed features inside `worldgen/feature` files) and of `placements` inside `randomly_selected`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| biome | 211 | - | - |
| block_predicate_filter | 198 | predicate:o{type} | - |
| count | 216 | count:int or o{type} | - |
| count_on_every_layer | 8 | count:int | - |
| cuboid | 5 | include_edges:bool, include_interior:bool, xz_size:o{type}, y_size:o{type} | - |
| environment_scan | 22 | direction_of_search:str{down/up}, max_steps:int, target_condition:o{type} | allowed_search_condition:o{type} (11) |
| fixed_placement | 1 | positions:arr[arr[int]] | - |
| height_range | 86 | height:o{type} | - |
| heightmap | 111 | heightmap:str{MOTION_BLOCKING/MOTION_BLOCKING_NO_LEAVES/OCEAN_FLOOR/OCEAN_FLOOR_WG/WORLD_SURFACE_WG} | - |
| in_square | 198 | - | - |
| noise_based_count | 4 | noise_factor:num, noise_to_count_ratio:int | noise_offset:num (1) |
| noise_threshold_count | 6 | above_noise:int, below_noise:int, noise_level:num | - |
| offset | 148 | x:int or o{type}, y:int or o{type}, z:int or o{type} | - |
| random_chance | 11 | chance:num | - |
| randomly_selected | 2 | placements:arr[o{type}] | - |
| rarity_filter | 59 | chance:int | - |
| surface_relative_threshold_filter | 3 | heightmap:str{OCEAN_FLOOR_WG}, max_inclusive:int | - |
| surface_water_depth_filter | 26 | max_water_depth:int | - |

### 3.3 Trunk placer types

The member `trunk_placer` of a `tree` feature.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| bending_trunk_placer | 1 | base_height:int, bend_length:o{type}, height_rand_a:int, height_rand_b:int, min_height_for_leaves:int | - |
| cherry_trunk_placer | 2 | base_height:int, branch_count:o{type}, branch_end_offset_from_top:o{type}, branch_horizontal_length:o{type}, branch_start_offset_from_top:obj, height_rand_a:int, height_rand_b:int | - |
| dark_oak_trunk_placer | 5 | base_height:int, height_rand_a:int, height_rand_b:int | - |
| fancy_trunk_placer | 6 | base_height:int, height_rand_a:int, height_rand_b:int | - |
| forking_trunk_placer | 1 | base_height:int, height_rand_a:int, height_rand_b:int | - |
| giant_trunk_placer | 2 | base_height:int, height_rand_a:int, height_rand_b:int | - |
| mega_jungle_trunk_placer | 1 | base_height:int, height_rand_a:int, height_rand_b:int | - |
| poplar_trunk_placer | 6 | base_height:int, branch_amount:o{type}, height_rand_a:int, height_rand_b:int, trunk_height_above_branches:int | - |
| straight_trunk_placer | 19 | base_height:int, height_rand_a:int, height_rand_b:int | - |
| upwards_branching_trunk_placer | 2 | base_height:int, can_grow_through:tag, extra_branch_length:o{type}, extra_branch_steps:o{type}, height_rand_a:int, height_rand_b:int, place_branch_per_log_probability:num | - |

### 3.4 Foliage placer types

The member `foliage_placer` of a `tree` feature.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| acacia_foliage_placer | 1 | offset:int, radius:int | - |
| blob_foliage_placer | 16 | height:int, offset:int, radius:int | - |
| bush_foliage_placer | 1 | height:int, offset:int, radius:int | - |
| cherry_foliage_placer | 2 | corner_hole_chance:num, hanging_leaves_chance:num, hanging_leaves_extension_chance:num, height:int, offset:int, radius:int, wide_bottom_layer_hole_chance:num | - |
| dark_oak_foliage_placer | 5 | offset:int, radius:int | - |
| fancy_foliage_placer | 6 | height:int, offset:int, radius:int | - |
| jungle_foliage_placer | 1 | height:int, offset:int, radius:int | - |
| mega_pine_foliage_placer | 2 | crown_height:o{type}, offset:int, radius:int | - |
| pine_foliage_placer | 1 | height:o{type}, offset:int, radius:int | - |
| poplar_foliage_placer | 6 | height:o{type}, offset:int, radius:o{type}, side_hole_chance:num | - |
| random_spread_foliage_placer | 3 | foliage_height:int, leaf_placement_attempts:int, offset:int, radius:int | - |
| spruce_foliage_placer | 1 | offset:o{type}, radius:o{type}, trunk_height:o{type} | - |

### 3.5 Root placer types

The member `root_placer` of a `tree` feature (2 instances).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| mangrove_root_placer | 2 | above_root_placement:obj, mangrove_root_placement:obj, root_provider:o{id}, trunk_offset_y:o{type} | - |

### 3.6 Tree decorator types

Elements of `decorators` (trees), `log_decorators` and `stump_decorators` (`fallen_tree`).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| alter_ground | 2 | provider:id | - |
| attached_to_leaves | 2 | block_provider:id, directions:arr[str], exclusion_radius_xz:int, exclusion_radius_y:int, probability:num, required_empty_blocks:int | - |
| attached_to_logs | 6 | block_provider:o{id} or o{type}, directions:arr[str], probability:num | - |
| beehive | 16 | probability:num | - |
| cocoa | 1 | probability:num | - |
| creaking_heart | 1 | probability:num | - |
| leave_vine | 5 | probability:num | - |
| pale_moss | 2 | ground_probability:num, leaves_probability:num, trunk_probability:num | - |
| place_on_ground | 20 | block_state_provider:o{type}, height:int, tries:int | radius:int (10) |
| shelf_mushroom | 7 | probability:num | - |
| trunk_vine | 4 | - | - |

### 3.7 Tree feature size types

The member `minimum_size` of a `tree` feature.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| three_layers_feature_size | 5 | upper_size:int | - |
| two_layers_feature_size | 40 | - | limit:int (11), lower_size:int (3), min_clipped_height:int (6), upper_size:int (23) |

### 3.8 Block entity modifier types

The member `block_entity_modifier` of a processor rule or of a feature rule.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| append_loot | 6 | loot_table:id | - |

### 3.9 Block state provider types

Typed objects in a block-state-provider slot (section 2.2), in `worldgen/block_state_provider` and `worldgen/feature` files.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| dual_noise | 1 | noise:obj, scale:num, seed:int, slow_noise:obj, slow_scale:num, states:arr[id], variety:arr[int] | - |
| noise | 1 | noise:obj, scale:num, seed:int, states:arr[id] | - |
| noise_threshold | 1 | default_state:id, high_chance:num, high_states:arr[id], low_states:arr[id], noise:obj, scale:num, seed:int, threshold:num | - |
| random_block | 5 | blocks:tag | - |
| randomized_int | 7 | property:str{age/pickles}, source:o{id} or o{type}, values:o{type} | - |
| rotated | 5 | state:o{id} or o{type} | direction:str{east/north/south/west} (4) |
| rule_based | 5 | rules:arr[obj] | fallback:o{id} (2) |
| weighted | 44 | entries:arr[obj] | - |

### 3.10 Block predicate types

Typed objects in a block-predicate slot (`predicate`, `predicates`, `can_place_on`, `can_replace`, `allowed_placement`, `target_condition`, `would_survive` owners, ...) in `worldgen/feature` and `worldgen/placed_feature` files and, for the `rule_based` provider `if_true`, in `worldgen/block_state_provider` files (2 `matching_block_tag` and 1 `not` of the counts below).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| all_of | 56 | predicates:arr[o{type}] | - |
| any_of | 35 | predicates:arr[o{type}] | - |
| has_sturdy_face | 6 | direction:str{down/up} | offset:arr[int] (5) |
| height_range | 4 | max_inclusive:obj, min_inclusive:obj | - |
| inside_world_bounds | 1 | offset:arr[int] | - |
| matching_block_tag | 162 | tag:id | offset:arr[int] (8) |
| matching_blocks | 110 | blocks:arr[id] or id | offset:arr[int] (46) |
| matching_fluids | 31 | fluids:arr[id] or id | offset:arr[int] (26) |
| not | 19 | predicate:o{type} | - |
| replaceable | 2 | - | - |
| solid | 21 | - | offset:arr[int] (1) |
| true | 1 | - | - |
| volume_match | 1 | match:o{type}, max:arr[int], min:arr[int] | - |
| would_survive | 63 | state:id | - |

### 3.11 Number provider types

Typed objects in an int, float or height provider slot of the worldgen registries (`worldgen/feature`, `placed_feature`, `carver`, `structure`, and the `values` of `worldgen/block_state_provider`, 2 `uniform[int]`). Each type is split by the JSON kind of its bounds, shown in brackets: `[int]` integer bounds (an int provider), `[num]` decimal bounds (a float provider), `[height]` vertical-anchor object bounds (a height provider). Loot, trade, dimension and enchantment number providers are in section 4.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| biased_to_bottom[int] | 3 | max_inclusive:int, min_inclusive:int | - |
| clamped[int] | 3 | max_inclusive:int, min_inclusive:int, source:o{type} | - |
| clamped_normal[int] | 6 | deviation:num, max_inclusive:int, mean:num, min_inclusive:int | - |
| clamped_normal[num] | 1 | deviation:num, max:num, mean:num, min:num | - |
| trapezoid[height] | 13 | max_inclusive:obj, min_inclusive:obj | - |
| trapezoid[int] | 270 | max:int, min:int, plateau:int | - |
| trapezoid[num] | 4 | max:num, min:num, plateau:num | - |
| uniform[height] | 77 | max_inclusive:obj, min_inclusive:obj | - |
| uniform[int] | 137 | max_inclusive:int, min_inclusive:int | - |
| uniform[num] | 17 | max_exclusive:num, min_inclusive:num | - |
| very_biased_to_bottom[height] | 2 | inner:int, max_inclusive:obj, min_inclusive:obj | - |
| very_biased_to_bottom[int] | 3 | max_inclusive:int, min_inclusive:int | - |
| weighted_list[int, nested providers] | 9 | distribution:arr[obj] | - |
| weighted_list[int] | 31 | distribution:arr[obj] | - |

### 3.12 Structure types

The `type` of a `worldgen/structure` file (16 types, 52 files).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| buried_treasure | 1 | biomes:tag, spawn_overrides:obj, step:str{underground_structures} | - |
| desert_pyramid | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |
| end_city | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |
| fortress | 1 | biomes:tag, spawn_overrides:obj, step:str{underground_decoration} | - |
| igloo | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |
| jigsaw | 28 | biomes:tag, max_distance_from_center:int, size:int, spawn_overrides:obj, start_height:obj or o{type}, start_pool:id, step:str{surface_structures/underground_decoration/underground_structures}, use_expansion_hack:bool | dimension_padding:int (1), liquid_settings:str{ignore_waterlogging} (1), pool_aliases:arr[o{type}] (1), project_start_to_heightmap:str{WORLD_SURFACE_WG} (25), start_jigsaw_name:id (1), terrain_adaptation:str{beard_box/beard_thin/bury/encapsulate} (27) |
| jungle_temple | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |
| mineshaft | 2 | biomes:tag, mineshaft_type:str{mesa/normal}, spawn_overrides:obj, step:str{underground_structures} | - |
| nether_fossil | 1 | biomes:tag, height:o{type}, spawn_overrides:obj, step:str{underground_decoration}, terrain_adaptation:str{beard_thin} | - |
| ocean_monument | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |
| ocean_ruin | 2 | biome_temp:str{cold/warm}, biomes:tag, cluster_probability:num, large_probability:num, spawn_overrides:obj, step:str{surface_structures} | - |
| ruined_portal | 7 | biomes:tag, setups:arr[obj], spawn_overrides:obj, step:str{surface_structures} | - |
| shipwreck | 2 | biomes:tag, is_beached:bool, spawn_overrides:obj, step:str{surface_structures} | - |
| stronghold | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures}, terrain_adaptation:str{bury} | - |
| swamp_hut | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |
| woodland_mansion | 1 | biomes:tag, spawn_overrides:obj, step:str{surface_structures} | - |

### 3.13 Structure placement types

The member `placement` of a `worldgen/structure_set` file (21 files).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| concentric_rings | 1 | count:int, distance:int, preferred_biomes:tag, salt:int, spread:int | - |
| random_spread | 20 | salt:int, separation:int, spacing:int | exclusion_zone:obj (1), frequency:num (3), frequency_reduction_method:str{legacy_type_1/legacy_type_2/legacy_type_3} (3), locate_offset:arr[int] (1), spread_type:str{triangular} (3) |

### 3.14 Pool alias types

Elements of the structure member `pool_aliases` and of their nested `groups[].data`, `targets[]`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| direct | 6 | alias:id, target:id | - |
| random | 2 | alias:id, targets:arr[obj] | - |
| random_group | 1 | groups:arr[obj] | - |

### 3.15 Pool element types

The `element_type` of `template_pool[].elements[].element` and of nested `list_pool_element.elements[]`. The discriminator here is `element_type`, not `type`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| empty_pool_element | 31 | - | - |
| feature_pool_element | 57 | feature:id, projection:str{rigid} | - |
| legacy_single_pool_element | 1665 | location:id, processors:id or obj, projection:str{rigid/terrain_matching} | - |
| list_pool_element | 3 | elements:arr[o{etype}], projection:str{rigid} | - |
| single_pool_element | 531 | location:id, processors:id or obj, projection:str{rigid} | - |

### 3.16 Structure processor types

Elements of `worldgen/processor_list` `processors` and `capped.delegate`, and `processors` of the `fossil`/`template` features. The discriminator is `processor_type`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| block_rot | 6 | integrity:num | rottable_blocks:tag (2) |
| capped | 4 | delegate:o{proc}, limit:int | - |
| protected_blocks | 7 | value:tag | - |
| rule | 41 | rules:arr[obj] | - |

### 3.17 Rule test types

Members `input_predicate`, `location_predicate` of a processor rule, `target` of ore targets, and nested `rules[]`/`rule`. The discriminator is `predicate_type`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| all_of | 68 | rules:arr[o{ptype}] | - |
| always_true | 157 | - | - |
| any_of | 34 | rules:arr[o{ptype}] | - |
| block_match | 41 | block:id | - |
| blockstate_match | 8 | block_state:o{id} | - |
| height_match | 34 | max_inclusive:int, min_inclusive:int | - |
| not | 34 | rule:o{ptype} | - |
| random_block_match | 123 | block:id, probability:num | - |
| tag_match | 120 | tag:id | - |

### 3.18 Position test types

The member `position_predicate` of a processor rule (1 instance). The discriminator is `predicate_type`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| axis_aligned_linear_pos | 1 | max_chance:num, max_dist:int | - |

### 3.19 Surface rule types

Typed objects in `worldgen/material_rule` files in a rule slot (file root, `sequence[]`, `then_run`). The surface rules are in `worldgen/material_rule`; the directory `surface_rule` does not exist.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| bandlands | 2 | - | - |
| block | 91 | result_state:id | - |
| condition | 163 | if_true:id or o{type}, then_run:id or o{type} | - |
| ore_vein | 2 | density:id, filler_block:id, filler_gap:id, ore_block:id, raw_ore_block:id, raw_ore_chance:num, richness:id | - |
| sequence | 49 | sequence:arr[id or o{type}] or arr[id] or arr[o{type}] | - |

### 3.20 Surface condition types

Typed objects in `worldgen/material_rule` condition slots (`if_true`, `invert`) and the root of `worldgen/material_condition` files.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| above_preliminary_surface | 1 | - | - |
| biome | 48 | biome_is:arr[id] or id | - |
| hole | 6 | - | - |
| noise_threshold | 43 | max_threshold:num, min_threshold:num, noise:id | is_3d:bool (3) |
| not | 14 | invert:o{type} | - |
| steep | 5 | - | - |
| stone_depth | 6 | add_surface_depth:bool, offset:int, secondary_depth_range:int, surface_type:str{ceiling/floor} | - |
| vertical_gradient | 3 | false_at_and_above:obj, random_name:id, true_at_and_below:obj | - |
| water | 2 | add_stone_depth:bool, offset:int, surface_depth_multiplier:int | - |
| y_above | 23 | add_stone_depth:bool, anchor:obj, surface_depth_multiplier:int | - |

### 3.21 Density function types

Typed objects in `worldgen/density_function` files and inline in `worldgen/noise_settings` files (`noise_router`, `aquifers`, `debug_functions[].function`).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| abs | 18 | input:id or o{type} | - |
| add | 80 | left:id or num or o{type}, right:id or num or o{type} | - |
| beardifier | 11 | - | - |
| blend_alpha | 9 | - | - |
| blend_density | 11 | input:o{type} | - |
| blend_offset | 3 | - | - |
| cache | 32 | input:o{type} | - |
| clamp | 18 | input:o{type}, max:num, min:num | - |
| cube | 2 | input:o{type} | - |
| distance_to_point | 1 | metric:str{euclidean}, point:arr[int] | - |
| div | 3 | left:num, right:id | - |
| end_outer_islands | 1 | - | - |
| find_top_surface | 3 | cell_height:int, density:o{type}, lower_bound:int, upper_bound:o{type} | - |
| gradient | 37 | axis:str{y}, from_coordinate:int, from_value:num, to_coordinate:int, to_value:num | - |
| half_negative | 3 | input:o{type} | - |
| interpolated | 21 | cell_size_xz:int, cell_size_y:int, input:id or o{type} | - |
| interval_select | 3 | functions:arr[o{type}], input:o{type}, thresholds:arr[num] | - |
| lerp | 37 | alpha:o{type}, first:num or o{type}, second:id or o{type} | - |
| max | 11 | left:o{type}, right:num or o{type} | - |
| min | 18 | left:id or o{type}, right:id or o{type} | - |
| mul | 71 | left:id or o{type}, right:id or num or o{type} | - |
| negate | 1 | input:id | - |
| noise | 67 | noise:id, xz_scale:num, y_scale:num | shift_x:id (9), shift_z:id (9) |
| old_blended_noise | 3 | smear_scale_multiplier:num, xz_factor:num, xz_scale:num, y_factor:num, y_scale:num | - |
| quarter_negative | 6 | input:o{type} | - |
| range_choice | 21 | input:id or o{type}, max_exclusive:num, min_inclusive:num, when_in_range:num or o{type}, when_out_of_range:id or num or o{type} | - |
| shift_a | 1 | noise:id | - |
| shift_b | 1 | noise:id | - |
| slice | 1 | axis:str{y}, coordinate:int, input:o{type} | - |
| spline | 9 | spline:obj | - |
| square | 3 | input:o{type} | - |
| squeeze | 11 | input:o{type} | - |
| sub | 19 | left:id or num or o{type}, right:id or num or o{type} | - |

### 3.22 Carver types

The `type` of a `worldgen/carver` file (4 files).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| canyon | 1 | probability:num, shape:obj, vertical_rotation:o{type}, y:o{type} | - |
| cave | 3 | count:o{type}, floor_level:num or o{type}, horizontal_radius_multiplier:num or o{type}, probability:num, room_vertical_radius_multiplier:num or o{type}, thickness:o{type}, vertical_radius_multiplier:num or o{type}, y:o{type} | start_vertical_radius_multiplier:num (1), weird_thickness_bias:bool (2) |

### 3.23 World preset types

Typed objects in `worldgen/world_preset` files (`dimensions.*`, `generator`, `biome_source`); the types of several slots are merged here.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| debug | 1 | - | - |
| fixed | 1 | biome:id | - |
| flat | 4 | settings:obj | - |
| multi_noise | 9 | preset:id | - |
| noise | 16 | biome_source:o{type}, settings:id | - |
| overworld | 7 | generator:o{type} | - |
| the_end | 13 | - | generator:o{type} (7) |
| the_nether | 7 | generator:o{type} | - |


---

## 4. Member census of the loot, recipe and context-provider types

Same method as section 3, over `loot_table`, `recipe`, `villager_trade`, `predicate`, `context_int_provider`, `context_float_provider` and
`trade_set` files. Enchantment effect types, advancement criteria, dialog and timeline types are not censused here.

### 4.1 Loot table root

The root `type` of a `loot_table` file.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| archaeology | 6 | pools:arr[obj], random_sequence:id | - |
| barter | 1 | pools:arr[obj], random_sequence:id | - |
| block | 1201 | random_sequence:id | modifier:o{type} (9), pools:arr[obj] (1187) |
| block_interact | 5 | pools:arr[obj], random_sequence:id | - |
| chest | 68 | pools:arr[obj], random_sequence:id | - |
| entity | 115 | random_sequence:id | pools:arr[obj] (85) |
| entity_interact | 1 | pools:arr[obj], random_sequence:id | - |
| equipment | 3 | pools:arr[obj], random_sequence:id | - |
| fishing | 4 | pools:arr[obj], random_sequence:id | - |
| gift | 21 | pools:arr[obj], random_sequence:id | - |
| shearing | 22 | pools:arr[obj], random_sequence:id | - |

### 4.2 Loot entry

Elements of a pool's `entries` and of `alternatives.children`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| alternatives | 87 | children:arr[o{type}] | condition:o{type} (3) |
| dynamic | 1 | condition:o{type}, name:id | - |
| empty | 39 | - | weight:int (35) |
| item | 2562 | name:id | condition:id or o{type} (223), modifier:arr[o{type}] or o{type} (1077), weight:int (601) |
| loot_table | 57 | value:id or obj | condition:o{type} (40), modifier:o{type} (2), quality:int (3), weight:int (9) |
| tag | 1 | expand:bool, items:tag | - |

### 4.3 Item function

Elements of an entry `modifier`, of the root `modifier`, of villager `given_item_modifier` and of `filtered.on_fail`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| apply_bonus | 32 | enchantment:id, formula:id | condition:o{type} (1), parameters:obj (15) |
| copy_components | 71 | include:arr[id], source:str{block_entity} | - |
| copy_state | 10 | block:id, properties:arr[str] | - |
| discard | 56 | - | - |
| enchant_randomly | 56 | options:arr[id] or id or tag | include_additional_cost_component:bool (4), only_compatible:bool (4) |
| enchant_with_levels | 51 | levels:int or o{type}, options:tag | include_additional_cost_component:bool (17) |
| enchanted_count_increase | 80 | count:o{type}, enchantment:id | limit:int (3) |
| exploration_map | 28 | destination:tag | decoration:id (26), search_radius:int (10), skip_existing_chunks:bool (3), zoom:int (3) |
| explosion_decay | 190 | - | - |
| filtered | 56 | item_filter:obj, on_fail:o{type} | - |
| furnace_smelt | 19 | condition:o{type} | - |
| limit_count | 6 | limit:obj | - |
| set_components | 6 | components:obj | - |
| set_count | 947 | count:int or o{type} | add:bool (21), condition:o{type} (204) |
| set_damage | 28 | damage:o{type} | - |
| set_enchantments | 11 | enchantments:obj | - |
| set_instrument | 1 | options:tag | - |
| set_name | 8 | name:obj, target:str{item_name} | - |
| set_ominous_bottle_amplifier | 3 | amplifier:o{type} | - |
| set_potion | 53 | id:id | - |
| set_random_dyes | 7 | number_of_dyes:o{type} | - |
| set_random_potion | 1 | options:tag | - |
| set_stew_effect | 4 | effects:arr[o{type}] | - |

### 4.4 Condition

Elements of `conditions`, and the values of `condition`, `term`, `terms`, `requirements`, `merchant_predicate` (a string in these slots names a `predicate` file, section 2.4).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| all_of | 42 | terms:arr[o{type}] | - |
| any_of | 57 | terms:arr[id] or arr[o{type}] | - |
| damage_source_properties | 8 | predicate:obj | - |
| entity_properties | 117 | entity:str{attacker/direct_attacker/this}, predicate:obj | - |
| inverted | 26 | term:id or o{type} | - |
| killed_by_player | 24 | - | - |
| location_check | 14 | predicate:obj | offsetY:int (4) |
| match_block | 300 | blocks:arr[id] or id | state:obj or o{type} (299) |
| match_tool | 3 | predicate:obj | - |
| random_chance | 19 | chance:num | - |
| random_chance_with_enchanted_bonus | 11 | enchanted_chance:o{type}, enchantment:id, unenchanted_chance:num | - |
| survives_explosion | 914 | - | - |
| table_bonus | 35 | chances:arr[num], enchantment:id | - |

### 4.5 Loot number provider

Typed number providers of loot tables, villager trades and the `set_random_dyes` function. These use `min`/`max` (not `min_inclusive`/`max_inclusive`).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| add | 7 | inputs:arr[int or o{type}] | - |
| binomial | 25 | n:int, p:num | - |
| linear | 11 | base:num, per_level_above_first:num | - |
| uniform | 783 | max:int or num, min:int or num | - |

### 4.6 Context provider

Typed objects in `context_int_provider` and `context_float_provider` files.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| conditional | 19 | condition:id, on_false:id, on_true:id | - |
| div | 18 | left:int, right:o{type} | - |
| number_dispatcher | 4 | cases:arr[obj], default:o{type} | - |
| weighted_list | 4 | distribution:arr[obj] | - |

### 4.7 Recipe

The root `type` of a `recipe` file (2,042 files).

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| blasting | 25 | cookingtime:int, experience:num, ingredient:arr[id] or id, result:o{id} | category:str{blocks} (2), group:str{coal/copper_ingot/diamond/emerald/gold_ingot/iron_ingot/lapis_lazuli/redstone} (20) |
| brewing | 279 | input:obj, output:o{id}, reagent:obj | - |
| campfire_cooking | 9 | category:str{food}, cookingtime:int, experience:num, ingredient:id, result:o{id} | - |
| crafting_decorated_pot | 1 | back:tag, front:tag, left:tag, result:o{id}, right:tag | - |
| crafting_dye | 6 | dye:tag, group:str{dyed_armor}, result:o{id}, target:id | - |
| crafting_imbue | 1 | material:id, result:o{id}, source:id | - |
| crafting_shaped | 827 | key:obj, pattern:arr[str or tag] or arr[str] or arr[tag], result:o{id} | category:str{building/equipment/redstone} (534), group:str (413), show_notification:bool (1) |
| crafting_shapeless | 375 | ingredients:arr[arr[id] or id] or arr[id or tag] or arr[id] or arr[tag], result:o{id} | category:str{building/equipment/redstone} (187), group:str (316) |
| crafting_special_bannerduplicate | 16 | banner:id, result:o{id} | - |
| crafting_special_bookcloning | 1 | material:tag, result:o{id}, source:id | - |
| crafting_special_firework_rocket | 1 | fuel:id, result:o{id}, shell:id, star:id | - |
| crafting_special_firework_star | 1 | dye:tag, fuel:id, result:o{id}, shapes:obj, trail:id, twinkle:id | - |
| crafting_special_firework_star_fade | 1 | dye:tag, result:o{id}, target:id | - |
| crafting_special_mapextending | 1 | map:tag, material:id, result:obj | - |
| crafting_special_repairitem | 1 | - | - |
| crafting_special_shielddecoration | 1 | banner:tag, result:o{id}, target:id | - |
| crafting_transmute | 33 | group:str{bundle_dye/map_cloning/shulker_box_dye}, input:tag, material:id, result:obj or o{id} | add_material_count_to_result:bool (1), category:str{equipment} (16), material_count:obj (1) |
| smelting | 73 | cookingtime:int, experience:num, ingredient:arr[id] or id or tag, result:o{id} | category:str{blocks/food} (43), group:str{coal/copper_ingot/diamond/emerald/gold_ingot/iron_ingot/lapis_lazuli/redstone} (20) |
| smithing_transform | 12 | addition:tag, base:id, result:o{id}, template:id | - |
| smithing_trim | 18 | addition:tag, base:tag, pattern:id, template:id | - |
| smoking | 9 | category:str{food}, cookingtime:int, experience:num, ingredient:id, result:o{id} | - |
| stonecutting | 351 | ingredient:id, result:o{id} | - |

### 4.8 Stew effect entry

Elements of `set_stew_effect.effects`.

| type | n | required members (in every instance) | optional members (instances having it) |
|---|---|---|---|
| blindness | 4 | duration:int or o{type} | - |
| jump_boost | 3 | duration:int or o{type} | - |
| night_vision | 4 | duration:int or o{type} | - |
| poison | 3 | duration:int or o{type} | - |
| saturation | 3 | duration:int or o{type} | - |
| weakness | 3 | duration:int or o{type} | - |


### 4.9 Other registries: file-level members

See section 2.7 (`trade_set`, `villager_trade`, `predicate`, `enchantment`, `damage_type` and the others). `damage_type` files have the members
`exhaustion` (decimal), `message_id`, `scaling` (`always` or `when_caused_by_living_non_player`) and optionally `effects` (12 of 51:
`burning`, `drowning`, `freezing`, `poking`, `thorns`) and `death_message_type` (3). `trade_set` files have `amount`, `random_sequence` and `trades`
(a `#` tag of `villager_trade`). `predicate` has 3 files (`block/fast_cooking`, `tool/can_shear`, `tool/can_silk_touch`) whose roots are typed conditions.

---

## 5. Agreement with documents 10, 23, 26, 35, 36, 37 and 44

The data files were compared with the statements of these documents that concern the shape of the files. **No statement was found that the data
contradicts.** Every item below was read from the files in this round.

| Document and section | Statement | Result |
|---|---|---|
| 35-1 §1 | no `configured feature` layer, no `config` wrapper, features are flat records dispatched on `type` | agrees: 0 `config` members in the 8,266 files; `size` of an `ore` is top-level |
| 35-2 §4.1 | `BlockStateProvider.CODEC` slots are Id-or-inline: a string names one of the 8 `block_state_provider` files; the plain object is a state; `BlockState.CODEC` slots accept a bare id or an object | agrees (section 2.2); the loader's assumption that a block state is always an object with `Name`/`Properties` is wrong, and so is the assumption that every provider carries a `type` |
| 23 §7.1 to §7.3 | an int provider accepts a bare integer (constant); float and height providers likewise | agrees (no `constant` type in the data) |
| 35-3 §4.9 and §5.2 | cherry `branch_start_offset_from_top` is a uniform without a `type`; poplar, pine, spruce, mega pine have provider fields | agrees (sections 2.1, 3.3 and 3.4) |
| 35-4 §1.3 | 240 features, 47 file-level types, 37 `simple_block`, 45 `tree`, 273 placed features | agrees (re-counted) |
| 35-2 §9.2 | counts of files per directory and predicate types in use | agrees for the file counts (240, 273, 8, 40, 245, 52); the processor and rule test kinds in the data are 4 and 9 |
| 36-3 §3.3 | pool elements `single`, `legacy_single`, `list`, `feature`, `empty`; `processors` is a reference or an inline `{processors}`; `location` an identifier | agrees; `location` values reach 88 bytes (section 1.4) |
| 36-3 §3.1 | `max_distance_from_center` an integer or an object | the data uses the integer form only (28 of 28) |
| 37-2 §2.1 | 7 noise settings files; `noise` is `{min_y, height}`; `default_block`, `default_fluid` | agrees (7 files; `noise` has only `height` and `min_y`) |
| 10 §10.4 to §10.5 | surface condition member lists; rule types `sequence`, `condition`, `block`, `bandlands`, `ore_vein` | agrees; **gaps**: the table of §10.5 names the members of `condition` (`if_true`, `then_run`) and `block` (`result_state`) but not the member of `sequence` (also called `sequence`), and does not say that the `sequence`, `if_true` and `then_run` slots accept a string naming another `material_rule` or `material_condition` file; `result_state` is a plain block id in all 91 rules, so "with properties where listed" is never exercised |
| 10 §5, 37-2 §2.1 | `spawn_target` is a list of parameter boxes | agrees on the content; the JSON shape (objects keyed by density function ids, each an array `[min, max]`) is not written in either document (section 2.5) |
| 26 §9 | a number provider accepts a bare number, an object or a string id | agrees: bare integers are by far the common form for `rolls`/`count` (section 2.1) |
| 19 §22.4 (villager trades; 44-3 repeats them) | trade members `gives`, `wants`, `additional_wants`, `max_uses`, `xp`, `reputation_discount`, `merchant_predicate`, `given_item_modifier`, `double_trade_price_enchantments` | agrees with the file-level census (section 2.7) |

The failures reported by the content loaders (members read as `config.size`, `Name`/`Properties`, `rules`, a mandatory `type` on a provider, an object-only
`loot_int`, an identifier width of 64 bytes) all follow from assumptions in the loaders that the data does not hold; none follows from an error in the documents,
though document 10 §10.5 omits the member name of the `sequence` rule and the string form of the three slots, and document 37-4 names none of the three members (listed as gaps above).

---

## 6. Open questions

1. **Block id versus provider name.** The string `minecraft:mangrove_propagule` is both a block and a provider name. The data does not mark which a string is; the slot
   decides (section 2.2, and 35-2 §4.1). The classification of members into state slots and provider slots in section 2.2 is read from the forms that occur, not
   from a schema.
2. **Identifier width.** The loader's 64-byte width and the 626 keys and 241 pool `location` values above it come from the loaders, not from the artifact. Whether the
   game limits the length of an identifier or a resource path was not read in this round.
3. **Dangling reference.** `minecraft:ancient_city/walls/intact_horizontal_wall_stairs_5` is named by a pool element but no structure NBT of that name exists in the jar.
   How the game handles a missing template was not read here (document 36-3 §3.3 says it is "the template engine's concern").
4. **Member order.** Section 1.5's rule (alphabetical, `type` first) is inferred from the files; the game's reader is not known to depend on it (inferred).
5. **Float versus integer tokens.** Section 2.6's rule that a float slot never holds an integer token holds in these files; whether the game accepts both was not read here.
6. **Counts for the nested features.** Section 3.1 counts instances including nested inline features; the nine nested-only feature types were not checked for
   whether they are accepted at file level.
7. **Shapes not censused.** `advancement`, `dialog`, `timeline`, `dimension_type` attributes, `enchantment` effects, `trial_spawner`, `biome` members below the file level, the
   unnamed sub-objects of those registries and of `recipe` and `predicate` (section 2.8), and the three feature packs were not censused for shape.
8. **Count of mixed `weighted_list`.** Nine int `weighted_list` providers mix integers and provider objects in their `distribution[].data` (section 2.3); the census
   labels them "int, nested providers".
