# 23 Registry loading, codecs and tag resolution

| Item | Value |
|---|---|
| Covers | How data-pack files become game state: the four registry layers and the load sequence of a server (static, world, dimensions, reloadable), what loading one registry from a pack does (file discovery, which pack wins, registration order and therefore numeric ids, strict JSON, error collection, tags, freezing, validators), how the same registries are loaded on the client from Registry Data, how references (`Id ref`, `Id-or-inline`, `HolderSet`) resolve and when an unresolved reference becomes an error, the tag file format and its resolution (`values`, `#` references, `?`-optional entries, `replace`, pack stacking, dependency order, cycles), tag loading for static registries and for synchronized registries, the value providers (int, float, height with vertical anchors, block state providers, weighted lists), the 15 environment-attribute value types, the 51 environment attributes with their defaults, ranges and flags, the attribute modifiers and the `EnvironmentAttributeMap` codec, resource-id rules, a validation section, and (9.5) the validation messages and ranges of the dimension type and of the other synchronized registries |
| Does not cover | Rows of data (the extraction tool copies them, see 22). Wire packets (04 §1 to §4). Entry schemas already tabulated in 04 §6 (not repeated; this document adds what 04 left unexpanded or marks where 04 §6 is confirmed or corrected). Enchantment effect components (RS8). Per-feature, per-structure and density-function semantics of the other world registries (documents 10, 11 and the later worldgen rounds). Loot, recipe and advancement engines (RS6, RS7) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and constant pools (`javap -v`), with no execution. The serialization library (`com.mojang.serialization`, DataFixerUpper: `Codec`, `JsonOps`, `Dynamic`, `DataResult`) is **not** in the client jar (0 entries under that package), so its own behaviour is not read; where a rule below depends on it, the rule is cited as "library behaviour" and is marked "(recalled, not verified)" or "(inferred)" |
| Status | Written by the reader for round RS3 (GAP-6, GAP-7, GAP-7a of [../design/README.md](../design/README.md)); fixer pass applied (weighted-list errors and selector, tag-file failure outcomes, Update Tags text, block-state providers, colour codecs, `BedRule`, `Music`, `Mth.lerpInt`, dimension-type messages). Operator decisions "Vanilla assets and data" and "Own world type" in `tickets/CC-0001-client-polish.md` |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and
"(recalled, not verified)" marks something not read; both are listed in the Open questions. Section references use "04 §6"
for other documents and "section 6.2" for this one.

Related documents. 04 (wire, ids, schemas), 22 (the tool that produces the data packs and the pack stack order), 24 and
46 (the numbering of static registries, which is **not** loaded from data), 10 and 11 (noise, `WorldgenRandom`,
`LegacyRandomSource`), 19 §1 (variant selection from `spawn_conditions`), 33 (how attributes are sampled at run time),
17 §4.12 and §6.2 (damage types and enchantments as data rows).

---

## 1. Resource ids

An `Identifier` (`net.minecraft.resources.Identifier`) is a namespace and a path, written `namespace:path`.

| Rule | Value (read from `Identifier`) |
|---|---|
| Default namespace | `minecraft`, used when the text has no `:` |
| Splitting | at the **first** `:` (`indexOf`). A `:` at index 0 gives the default namespace `minecraft` with the rest as path (read in `bySeparator` and `tryBySeparator`: the index-0 branch calls the default-namespace constructor) |
| Namespace characters | `a` to `z`, `0` to `9`, `_`, `-`, `.`. The namespace `..` is rejected |
| Path characters | `a` to `z`, `0` to `9`, `_`, `-`, `.`, `/`. No upper case, no `:` |
| Parsing failure | `parse` throws an `IdentifierException`; `Identifier.read` (used by the codec forms and by `TAG_OR_ELEMENT_ID`) wraps it into a data error; both are errors for the element being decoded |
| Exact messages (constants of `Identifier`, `\u0001` = a placeholder filled by string concatenation) | "Non [a-z0-9_.-] character in namespace of identifier: <namespace>:<path>" (namespace fails `isValidNamespace`), "Non [a-z0-9/._-] character in path of location: <namespace>:<path>" (path fails `isValidPath`), "Not a valid resource location: <text> <exception message>" (the data error built by `Identifier.read` when `parse` throws; the exception message is one of the first two texts, so a data error reads e.g. "Not a valid resource location: A:b Non [a-z0-9_.-] character in namespace of identifier: A:b"). The first two texts are thrown by `assertValidNamespace` and `assertValidPath` as an `IdentifierException`, which passes its message through `StringEscapeUtils.escapeJava` before storing it, so non-ASCII or quote characters in the offending id appear escaped in the message |
| `realms` namespace | `Identifier` defines the constant `REALMS_NAMESPACE` = `realms`. Within `Identifier` itself the constant is only declared: no namespace or path check compares against it (`isValidNamespace` tests only the `..` rule and the character set). Whether any other class special-cases `realms` was not searched (Open question 22) |
| Path resolution guard | `resolveAgainst(root)` resolves `<root>/<namespace>/<path>`, normalises both, and throws `IllegalStateException` "Identifier \"<id>\" tried to access path \"<path>\" from root \"<root>\"" when the normalised result is not inside the root. This is a file-system helper used for pack extraction and data generation, not a load-time id rule (what calls it was not traced) |
| Equality and hash | by namespace and path (hash = 31 * hash(namespace) + hash(path)) |
| **Ordering** | `compareTo` compares the **path first** (`String.compareTo`, UTF-16 code units), and only when the paths are equal compares the namespace. This ordering decides numeric ids in pack-loaded registries (section 3.4) |

Two derived forms. A `ResourceKey` is a registry id plus an element id. The registry id of a dynamic registry is
`minecraft:` plus the registry path (`minecraft:worldgen/biome`, `minecraft:dimension_type`).

File naming (read from `FileToIdConverter` and `Registries`):

| Kind | Directory prefix (relative to `data/<namespace>/`) | Extension | Mapping |
|---|---|---|---|
| Registry element | the registry **path** (`worldgen/biome`, `damage_type`, `trial_spawner`, `dimension`, ...) | `.json` | `data/<ns>/<registry path>/<element path>.json` is the element `<ns>:<element path>` |
| Tag | `tags/` + the registry path | `.json` | `data/<ns>/tags/<registry path>/<tag path>.json` is the tag `<ns>:<tag path>` |
| Registry whose path differs from its key name | the path is what the registry was created with: the trial spawner configuration registry has path `trial_spawner` (field `TRIAL_SPAWNER_CONFIG`), the level stem registry has path `dimension` (field `LEVEL_STEM`) | | |

The element path may contain `/` (nested folders): `data/minecraft/worldgen/biome/a/b.json` is `minecraft:a/b` in
registry `minecraft:worldgen/biome`.

Directory rules, read from `Registries`: `registryDirPath(key)` is the **path part** of the registry key's identifier
only (the namespace of the registry key is ignored), `elementsDirPath` returns it unchanged, and `tagsDirPath` is the text
`tags/` followed by it. A registry path that itself contains `/` therefore gives nested directories on both sides:
elements of `worldgen/biome` live under `data/<ns>/worldgen/biome/` and its tags under `data/<ns>/tags/worldgen/biome/`.
There is no per-registry exception list; the two directories used by the loaders are always derived by these two rules.
`Registries` also defines a third helper, `componentsDirPath(key)`, which gives the text `components/` followed by the registry
path. Searching every class of the jar for the method name finds it only in `Registries` itself and in
`net.minecraft.data.PackOutput` (data generation), so it is not a runtime load path and no loader in this document uses it.

Tag-or-element id grammar, read from `ExtraCodecs.TAG_OR_ELEMENT_ID` (the codec behind tag-file strings, the `id` of an
object entry and the `#` form of holder-set fields): a String whose first character is `#` has that single `#` removed and
the rest parsed with `Identifier.read` and marked as a tag; any other String is parsed with `Identifier.read` and marked as
an element. `#` is in neither the namespace nor the path alphabet above, so `##a:b`, `a:#b` and `#` alone fail with the
identifier error for the text after the first `#`; no other `#` handling exists. The display form of an id (used in
logs) is `#` + id for a tag.

## 2. Registry layers and the server load sequence

The server keeps its registries in a `LayeredRegistryAccess` over `RegistryLayer`, in this order: `STATIC`, `WORLD`,
`DIMENSIONS`, `RELOADABLE`. `STATIC` holds the built-in registries (blocks, items, entity types, sound events, the
`int_provider_type` registry, `environment_attribute`, ... 22 and 46). The other three layers are filled from data.

`WorldLoader.load` runs this sequence (read from `WorldLoader` lambdas):

1. Build the resource manager from the selected data packs (22 §8 for the stack).
2. Read the tags of every **static** registry (`TagLoader.loadTagsForExistingRegistries`). Each registry's pending tags
   are kept aside, not applied. Build "updated lookups": the static registries as they will look once their tags apply.
3. Load the **WORLD** layer: all 51 `RegistryDataLoader.WORLD_REGISTRIES` together (section 3), with the updated static
   lookups as parents. Then freeze and validate each (section 3.6).
4. Load the **DIMENSIONS** layer: the one registry `DIMENSION_REGISTRIES` (`dimension`, element codec `LevelStem.CODEC`),
   with the static and world registries as parents. The world-data supplier then produces the final dimension registry
   (world settings, presets, and the player's world options decide which stems exist).
5. Load the **RELOADABLE** layer (`ReloadableServerRegistries.reload`, `RELOADABLE_REGISTRIES`, 8 registries), with the
   static (updated) + world + dimension registries as parents. After loading, the loot registries are validated
   (a problem list; "Found loot table validation problems" is fatal only for fatal problems, other problems are logged
   as warnings "Found loot table element validation problem in {}: {}").
6. Build the recipe manager, command tree, advancement manager and function library from the combined lookups, then
   apply the postponed static tags and rebuild the default item components (`updateComponentsAndStaticRegistryTags`).

Consequences for an implementation:

- **Registry order inside a layer does not matter for correctness.** Within one `load` call, every registry's elements
  are decoded concurrently against *lazy* holder lookups (section 5.2), so an element may name an element or a tag of
  another registry of the same layer that has not been decoded yet. Errors surface at freeze time.
- **Layer order matters.** A WORLD element may name static registries and WORLD registries; it may **not** name a
  DIMENSIONS or RELOADABLE element (those registries do not exist yet). RELOADABLE elements may name anything.
- The static tags are applied last, but static registries' tags are *read* before the WORLD layer, so a WORLD element
  that names a static tag (`#minecraft:...`) sees the tag content.

### 2.1 The WORLD registries (51, in `WORLD_REGISTRIES` order)

The order below is the list order; it is the order of `RegistryAccess` iteration for the layer, nothing else. "Sync" =
also in `SYNCHRONIZED_REGISTRIES` (04 §3, sent with the Network codec shown there). "Non-empty" = validator
`RegistryValidator.nonEmpty` (the loaded registry must contain at least one entry, else the error in section 3.6).

| # | Registry path | Sync | Validator | Schema |
|---|---|---|---|---|
| 0 | `dimension_type` | yes | none | 04 §6; bounds in section 7.3.3; constructor messages in 9.5 |
| 1 | `worldgen/biome` | yes | none | 04 §6 and section 8 (attributes) |
| 2 | `chat_type` | yes | none | 04 §6 |
| 3 | `worldgen/carver` | no | none | 11 |
| 4 | `worldgen/feature` | no | none | RS19 |
| 5 | `worldgen/placed_feature` | no | none | RS19 |
| 6 | `worldgen/structure` | no | none | RS20 |
| 7 | `worldgen/structure_set` | no | none | RS20 |
| 8 | `worldgen/processor_list` | no | none | RS20 |
| 9 | `worldgen/template_pool` | no | none | RS20 |
| 10 | `worldgen/noise_settings` | no | none | 10 |
| 11 | `worldgen/noise` | no | none | 10 |
| 12 | `worldgen/density_function` | no | none | 10 |
| 13 | `worldgen/material_rule` | no | none | 10 |
| 14 | `worldgen/material_condition` | no | none | 10 |
| 15 | `worldgen/world_preset` | no | none | RS2 |
| 16 | `worldgen/flat_level_generator_preset` | no | none | RS2 |
| 17 | `trim_pattern` | yes | none | 04 §6 |
| 18 | `trim_material` | yes | none | 04 §6 |
| 19 | `trial_spawner` | no | none | RS13 |
| 20 | `wolf_variant` | yes | non-empty | 04 §6, section 9.1 |
| 21 | `wolf_sound_variant` | yes | non-empty | 04 §6 |
| 22 | `pig_variant` | yes | non-empty | 04 §6, section 9.1 |
| 23 | `pig_sound_variant` | yes | non-empty | 04 §6 |
| 24 | `frog_variant` | yes | non-empty | 04 §6, section 9.1 |
| 25 | `cat_variant` | yes | non-empty | 04 §6, section 9.1 |
| 26 | `cat_sound_variant` | yes | non-empty | 04 §6 |
| 27 | `cow_variant` | yes | non-empty | 04 §6, section 9.1 |
| 28 | `cow_sound_variant` | yes | non-empty | 04 §6 |
| 29 | `sulfur_cube_archetype` | yes | none | 04 §6 |
| 30 | `chicken_variant` | yes | non-empty | 04 §6, section 9.1 |
| 31 | `chicken_sound_variant` | yes | non-empty | 04 §6 |
| 32 | `zombie_nautilus_variant` | yes | non-empty | 04 §6, section 9.1 |
| 33 | `painting_variant` | yes | non-empty | 04 §6 |
| 34 | `damage_type` | yes | none | 04 §6; rows 17 §4.12 |
| 35 | `worldgen/multi_noise_biome_source_parameter_list` | no | none | 10 |
| 36 | `banner_pattern` | yes | none | 04 §6 |
| 37 | `enchantment` | yes | none | 04 §6; effects RS8 |
| 38 | `enchantment_provider` | no | none | RS8 |
| 39 | `jukebox_song` | yes | none | 04 §6 |
| 40 | `instrument` | yes | none | 04 §6 |
| 41 | `test_environment` | yes | none | 04 §6 (no behaviour) |
| 42 | `test_instance` | yes | none | 04 §6 (no behaviour) |
| 43 | `dialog` | yes | none | 04 §6 (no behaviour) |
| 44 | `world_clock` | yes | none | 04 §6 |
| 45 | `timeline` | yes | **timeline marker uniqueness** (section 9.2) | 04 §6 and section 9.2 |
| 46 | `villager_trade` | no | none | 19 (RS12) |
| 47 | `trade_set` | no | none | 19 (RS12) |
| 48 | `decorated_pot_pattern` | yes | none | 04 §6 |
| 49 | `block_transformer` | yes | none | 04 §6 |
| 50 | `worldgen/block_state_provider` | yes | none | 04 §6 and section 7.4 |

Counts check: 51 rows; the 32 rows marked "yes" are the 32 of `SYNCHRONIZED_REGISTRIES` (04 §3 table, same members). The
13 "non-empty" rows are the same 13 as in 04 §3.2 item 4. The element codec used for **loading** is the registry's
`DIRECT_CODEC` (full definition), except three rows that name a plain `CODEC` (`decorated_pot_pattern`, `villager_trade`,
`trade_set`). The codec used for **sending** is the one named in 04 §3. It differs from the loading codec for exactly 13
registries, the ones 04 §3 lists with a `NETWORK_CODEC`: biome, dimension type, timeline, the wolf, pig, frog, cat, cow,
chicken and zombie-nautilus variants, and the wolf, pig and cat sound variants (the cow and chicken sound variants and all
other synchronized registries use one codec both ways); see section 9.1.

### 2.2 DIMENSIONS and RELOADABLE

| Layer | Registry paths (list order) | Element codecs (read) |
|---|---|---|
| DIMENSIONS (1) | `dimension` | `LevelStem.CODEC` |
| RELOADABLE (8) | `loot_table`, `predicate`, `context_float_provider`, `context_int_provider`, `item_modifier`, `slot_source`, `advancement`, `recipe` | `LootTable.DIRECT_CODEC`, `LootItemCondition.DIRECT_CODEC`, `ContextFloatProviders.DIRECT_CODEC`, `ContextIntProviders.DIRECT_CODEC`, `LootItemFunctions.TYPED_CODEC`, `SlotSources.TYPED_CODEC`, `Advancement.CODEC`, `Recipe.DIRECT_CODEC` |

All of them go through the same loader (section 3) and the same tag mechanism (section 6): for example the `recipe`
registry's elements are `data/<ns>/recipe/<path>.json`. Reloadable registries are never synchronized by Registry Data
(04 §3); recipes and advancements reach the client by their own play packets (13 §3, RS7).

## 3. Loading one registry from the data packs

Class: `ResourceManagerRegistryLoadTask` (extends `RegistryLoadTask`). One task per registry. The steps:

### 3.1 Steps

1. **Discover.** List every file whose path starts with the registry path and ends with `.json`, over all namespaces
   (`FileToIdConverter.listMatchingResources`). For a given file id only the **top-most pack** that provides it counts:
   a higher-priority pack replaces the lower file of the same id completely. There is **no merging** of element files.
2. **Decode, in parallel.** Each file is parsed with the strict JSON reader and decoded with the registry's element
   codec through a `RegistryOps` over the JSON ops (section 5). A file that fails produces an exception recorded against
   that element's key; the other files continue.
3. **Register, in sorted order.** The successfully decoded elements are registered in the order of their element
   `Identifier` under the ordering of section 1 (path first, then namespace). Failed elements are recorded as errors and
   not registered. The registry gives each registered element the next numeric id (0, 1, 2, ...). **This is where the
   numeric ids of every data-pack registry come from** (section 3.4).
4. **Tags.** The registry's tag files are read and resolved (section 6) against the registry's own elements, then bound
   to the registry.
5. **Freeze** (section 3.6): references and tags that were created by name but never defined become errors.
6. **Validate** with the registry's `RegistryValidator`.
7. The layer's task list reports all errors together (section 3.5).

### 3.2 Strict JSON

Files are read through `StrictJsonParser.parse`: the Gson reader in `STRICT` strictness; after the value, the reader must
be at the end of the document, otherwise the error is "Did not consume the entire document." A malformed document, a
number format error or an I/O error is reported as a syntax error of that file. Comments, trailing commas and unquoted
names are not accepted (strictness effect of Gson; library behaviour, recalled not verified). Duplicate object keys:
not read (Open question 9).

### 3.3 Registration info

Each element is registered with a `RegistrationInfo` (an optional `KnownPack` and a lifecycle):

- For a file read from a pack, the known pack is the pack's own known-pack identity if it has one (the built-in vanilla
  packs), and the lifecycle is *stable* when the pack has a known-pack identity and *experimental* otherwise
  (`REGISTRATION_INFO_CACHE`).
- Elements received over the network use an empty known pack and the *experimental* lifecycle.
- `ReloadableServerRegistries` uses the same default (no known pack, experimental) for elements it creates itself.

The known pack is what makes Registry Data omit an entry's data (04 §2 step 4): an entry registered from a pack whose
known pack is in the set shared with the client is sent without Data.

### 3.4 Numeric ids and entry order, with a worked example

The id of an entry in a pack-loaded registry is its index in the sorted order of step 3. The ordering is by **path
first**. Therefore:

| Elements found (any packs) | Registered order | Ids |
|---|---|---|
| `minecraft:plains`, `minecraft:badlands`, `mymod:beach`, `minecraft:a/b` | `minecraft:a/b`, `minecraft:badlands`, `mymod:beach`, `minecraft:plains` | 0, 1, 2, 3 |
| `zeta:apple`, `minecraft:apple`, `alpha:apple` | `alpha:apple`, `minecraft:apple`, `zeta:apple` (equal paths: namespace order) | 0, 1, 2 |

(`/` sorts before letters: `a/b` < `badlands` because `a` < `b` at the first character, and `a/b` < `a1` because `/` (0x2F)
< `1` (0x31).) Registry Data entries are sent in id order (04 §2 step 4, §4), so the client's ids equal the server's.
A game that wants vanilla ids for a vanilla registry must therefore load vanilla elements into the registry and get the
same sorted order: any extra element (a user pack's) changes the ids of every element sorted after it. The server
and the CobolCraft client agree on ids because the client registers in the order it **receives** (04 §4) and the server
sends in its own id order; a vanilla client behaves the same way (it also registers in received order, section 4).

### 3.5 Error collection

All tasks of one `load` call run; every element error and every freeze/validate error is collected in a map keyed by the
resource key. After all tasks finish, **if the map is non-empty the whole load fails** (`logErrors`): the full details
are written to the log (header "Registry loading errors:", then per registry "> Errors in registry <r>:" and per element
">> Errors in element <id>:" followed by the exception text) and a crash report with the message "Failed to load registries
due to errors" is raised (report category "Registry Loading", sections "Loading info" and "Errors" with a brief summary:
the failing entries sorted by registry id, then by element id). The client wraps its own load in a report titled
"Network Registry Load" (04 §3.2). A game need not copy the report format; it must refuse to continue with a partially
loaded layer.

Order of error classes within a load: (1) element decode and "missing resource" errors, (2) freeze errors,
(3) validator errors. The freeze step runs for every task first; if any freeze reported an error, the load fails
before the validators run (read from `lambda$load$2`: freeze all, fail if errors, then validate all, fail if errors).

### 3.6 Freeze and validate

`RegistryLoadTask.freezeRegistry` calls `MappedRegistry.freeze`:

| Check | Error text (read from the constant pool) |
|---|---|
| Registry already frozen | "Registry is already frozen" |
| Values that were referenced by key (a lazy holder was created) but never registered | "Unbound values in registry <registry>: <sorted list of keys>" |
| Intrusive holders not registered (static registries only) | "Some intrusive holders were not registered: ..." |
| Tags present before freezing | "Tags already present before freezing" |
| Tags that were referenced (by an element, section 5.2) but never bound | "Unbound tags in registry <registry>: <sorted list of tag keys>" |

After freezing, each element's holder is bound to its value and the registry's id order is final. Adding a key twice
in one registry fails at registration with "Adding duplicate key '<key>' to registry"; adding the same value object
twice fails with "Adding duplicate value '<value>' to registry". With one file per element id, a pack-loaded registry
cannot hit the first message; a Registry Data packet that repeats an id can (04 §3.2 item 2).

`RegistryValidator.nonEmpty`: if the frozen registry has size 0 the error is "Registry must be non-empty: <registry id>",
recorded under the registry key itself. `RegistryValidator.none` never reports. The timeline validator is in 9.2.

Bind-time tag checks (`MappedRegistry`, class constants). When tags are bound or refreshed in a registry, each member of a
tag goes through one check (`validateAndUnwrapTagElement`), and both failures are an `IllegalStateException`:

| Check, in order | Text |
|---|---|
| the member holder cannot be serialized in this registry (it is owned by another registry) | "Can't create named set <tag> containing value <holder> from outside registry <registry>" |
| the member is not a **reference** holder (it is a direct holder, an inline value without an id) | "Found direct holder <holder> value in tag <tag>" |

The second text is a tag-binding check of `MappedRegistry`; it is not part of `TagNetworkSerialization` (6.6). The use site
read is the refresh of the holders' tag lists after binding (`refreshTagsInHolders`, which walks every bound tag and every
member). A third constant of the class, "Invalid method used for tag loading", was not traced to a call (Open question 18).

## 4. Loading from the network (client)

`RegistryDataLoader.load(Map<registry key, NetworkedRegistryData>, knownDataSource, ...)` builds one
`NetworkRegistryLoadTask` per registry of `SYNCHRONIZED_REGISTRIES`, in list order. `NetworkedRegistryData` pairs the
received `PackedRegistryEntry` list with the tag payload for that registry.

Per registry (read from `NetworkRegistryLoadTask`):

1. If the client received no Registry Data **and** no tags for the registry, the task does nothing: the registry stays
   empty (04 §3.2 item 5).
2. For each received entry, in **received order**: if it has Data, decode the NBT tag with the registry's element codec
   (`NetworkRegistryLoadTask` uses a `RegistryOps` over `NbtOps`; the `Network` codec of 04 §3). If it has no Data,
   load `data/<ns>/<registry path>/<path>.json` from the **known data source** (the client's copy of the confirmed packs)
   with a `RegistryOps` over JSON, using the **same element codec** (so for biome, the Network codec: fields that the
   Network codec leaves out are ignored in the pack file as well).
3. Register all successfully decoded elements **in received order** (no sorting). Ids are the received indices.
4. Resolve the registry's tags from the Update Tags payload (section 6.6) and bind them.
5. Freeze and validate exactly as in 3.5 and 3.6. The 13 non-empty validators apply to the client too.

Failure texts (read; all three are String constants of `net.minecraft.resources.RegistryLoadTask$PendingRegistration`, whose record components are `key`, `value`, `registrationInfo`): "Failed to parse value %s for key %s from server" (a Data entry that does not decode) and
"Failed to find resource %s for element %s" (a Data-less entry whose pack file is missing); a pack file that exists but
does not decode reports "Failed to parse %s from pack %s".

An implementation that serves its own entries and never sends Data-less entries (04 §2 guidance) only needs the Data path.

## 5. References, holders and the registry ops

Decoding and encoding of element fields that name other elements is done by three codecs. All three require a
`RegistryOps` (a `DynamicOps` wrapper that carries `RegistryInfoLookup`: registry key -> holder getter). Decoding the
same field with a plain ops fails with the errors below.

### 5.1 The three forms

| Form (class) | Accepts | Does | Errors (read) |
|---|---|---|---|
| **Id ref** (`RegistryFixedCodec`, API `RegistryCodecs.holder(key)`) | an Identifier String | looks the key up in the getter of that registry and returns its holder. Never an inline object | "Can't access registry <registry>" when the ops has no getter for the registry; "Failed to get element <id> from registry <registry>" when the getter returns nothing (see 5.2: a lazy getter never returns nothing). When the ops is not a registry ops at all, `RegistryOps` reports "Not a registry ops". Encoding a **direct** holder through an Id ref fails with "Elements from registry <registry> can't be serialized to a value" |
| **Id-or-inline** (`RegistryFileCodec`, `RegistryCodecs.holder(key, codec)`; the third argument `allowInline` is true for this overload) | first tries to read an Identifier String; if that fails and inline is allowed, decodes the value with the element codec and wraps it in a **direct holder** (no id) | as Id ref for the String branch; inline otherwise | "Inline definitions not allowed here" when `allowInline` is false (the `holder(key, codec, false)` overload); "Registry does not exist: <registry>" when the ops has no getter; "Failed to get element <id> from registry <registry>" |
| **HolderSet** (`HolderSetCodec`, `RegistryCodecs.holderSet(...)`) | a `#`-prefixed String (a tag), or elements (see below) | tag form: looks the tag key up in the registry getter and returns a **named** set; element form: a **direct** set of holders | "Registries are not available in this context" (ops that is not a registry ops); "Registry <registry> is not available in this context" (no getter for the registry); "Missing tag: '<tag>' in '<registry>'" when the getter returns no set for the tag; a String without `#` fails the tag-id parser (`net.minecraft.tags.TagKey`, constant "Not a tag id"; it is not a constant of `HolderSetCodec`) and is then tried as an element |

Complete constant lists (read from the class constant pools; `HolderSetCodec`, `RegistryFixedCodec` and `RegistryFileCodec` are in package `net.minecraft.core.registries.codec`; `RegistryOps` is in `net.minecraft.resources`). `HolderSetCodec` has exactly four: "Registries are not available in
this context", "Registry %s is not available in this context", "HolderSet %s is not valid in current registry set" and
"Missing tag: '%s' in '%s'". `RegistryFixedCodec` has "Can't access registry <registry>", "Failed to get element <id> from
registry <registry>", "Elements from registry <registry> can't be serialized to a value" and "Element <holder> is not valid in
current registry set". `RegistryOps` has "Not a registry ops", "Can't find value: <id>" and "Unknown registry: <registry>"
(the last two belong to its element and getter retrieval helpers; which branch produces which was not traced).

HolderSet element form. The flag `homogenousList` of `holderSet(..., boolean)` decides:

- `false` (**the default** of `holderSet(key)` and `holderSet(key, codec)`): the value is either **one** element (a bare
  Identifier String, or an inline object if the element codec allows inline) or a **list** of elements (the compact list
  codec: a single element is accepted where a list is expected).
- `true`: only a list of elements.

The tag form is a String with a leading `#` followed by an Identifier (`"#minecraft:logs"`). A String without `#` is an
element id. The leading `#` is mandatory for tags in HolderSet fields; tag **files** (section 6) use `#` inside
`values` strings too.

Encoding: a named HolderSet encodes as the `#id` string provided its owner can serialize in the ops' registry
(otherwise "HolderSet <set> is not valid in current registry set"); anything else encodes as the list of its holders. A
holder owned by another registry set is rejected with "Element <holder> is not valid in current registry set".

### 5.2 Lazy lookups, and why unbound references become freeze errors

During a layer load the ops' getter for each registry **in that layer** is a `ConcurrentHolderGetter` over the
registry's *registration lookup* (`MappedRegistry.createRegistrationLookup`). That lookup **never fails**: asking for a key
that has not been registered yet returns a new **unbound** holder reference, remembered by key; asking for a tag that
has not been bound yet returns a new **unbound** named set. Later registration binds the reference to the value and
tag binding binds the set. Registries of lower layers (the static layer and earlier layers) are read through their
normal frozen lookups: an unknown element there is a failed lookup ("Failed to get element ..."), and an unknown tag
yields no set ("Failed to get tag ...").

Therefore, for a registry in the layer being loaded:

- a reference to an element that no file defines is **not** an error while decoding; it is reported at freeze as
  "Unbound values in registry ..." (listing every such key, sorted);
- a `#tag` reference to a tag that no tag file defines is reported at freeze as "Unbound tags in registry ..."
  (04 Open question 4 resolved for the pack-load path: the lookup creates the tag lazily and the freeze rejects it).
  The same holds on the client for synchronized registries: a tag named by an element but absent from Update Tags is
  an error at the end of configuration (the client binds only the tags it received).

Both are fatal for the load (section 3.5). A server author must therefore make sure that every tag named by a
synchronized element is also present in the Update Tags payload, even when the tag is empty (an empty tag file
`{"values": []}` defines an empty tag; so does a tag file that parses as JSON but fails to decode, section 6.3 step A,
whereas a tag file with a JSON syntax error defines nothing).

## 6. Tags

### 6.1 Tag file grammar

A tag file is a JSON object (`TagFile.CODEC`):

| Field | Type | Req/Opt (default) | Notes |
|---|---|---|---|
| `values` | list of TagEntry | **Req** | order is significant (section 6.4) |
| `replace` | boolean | Opt (`false`) | when true, the entries collected so far from lower-priority packs for this tag are discarded before this file's entries are added |

A **TagEntry** (`TagEntry.CODEC`) is either:

| Form | JSON | Meaning |
|---|---|---|
| String | `"minecraft:oak_log"` | element reference, **required** |
| String | `"#minecraft:logs"` | tag reference, **required** |
| Object | `{"id": "<string as above>", "required": <bool>}` | `id` is an element or `#tag` string; `required` is optional with default `true` |

When `required` is false the entry is **optional**. Encoding rule (for round trips): a required entry is written as the
bare String, an optional entry as the Object. A bare String is parsed as the id form (`TAG_OR_ELEMENT_ID`: with or
without a leading `#`); an object's `id` is parsed the same way.

Additional rules read from `TagEntry`:

- An element id is an `Identifier` (section 1); `#` is stripped only as a tag marker, so a path cannot start with `#`.
- Display form of an entry (used in error messages): `#` for a tag, the id, and a trailing `?` when optional.
- `required` does not change *what* is matched, only whether a missing target is an error (6.3).

Constructed test vector (the names are invented for this document; they are not read from the artifact and say nothing about the contents of any vanilla tag such as `minecraft:logs` or `birch_logs`):

```
{ "replace": false,
  "values": [ "minecraft:oak_log", "#minecraft:birch_logs",
              { "id": "othermod:cherry_log", "required": false },
              { "id": "#othermod:more_logs",  "required": false } ] }
```

### 6.2 Where tags come from and how packs stack

For registry `R` with path `P`, the loader asks for every file `tags/P/**/*.json` as a **stack** per tag id
(`listMatchingResourceStacks`): all packs that provide the file, **ordered from the lowest-priority pack to the
highest-priority pack** (the pack list is the order the packs were pushed; single-resource lookup walks the list from the
end, so the last pack is the winner. Read: `MultiPackResourceManager` / `FallbackResourceManager`). The tag id is
`<namespace>:<path under tags/P/>` (file extension removed).

### 6.3 Resolution of a tag (the algorithm)

Step A. **Collect.** For each tag id, start with an empty list of entries. For each pack file of the stack, in stack
order (low to high priority):

1. Per file, `TagLoader.load` does these things **in this order**, inside one guarded block (any exception ends the
   file's processing, is logged as the error "Couldn't read tag list <tag> from <file> in data pack <pack>", and the
   next file is tried; the other packs' files of the same tag still apply; this is the one place where a bad data file
   is not fatal):
   a. open the file (an I/O failure ends the file here);
   b. parse it with the strict JSON reader (a syntax error ends the file here);
   c. **create the tag's entry list** for this tag id if none exists yet (an empty list, shared by all files of the tag);
   d. decode `TagFile` from the JSON (a decode failure, for example a missing `values`, ends the file here).
   Outcomes. A file that fails at (a) or (b) leaves **no trace**: if it was the only file of the tag, the tag id never
   enters the map and the tag is undefined. A file that fails at (d) has already created the list, so if it was the
   only file of the tag, the tag **exists with no entries**: it is built as an empty tag, bound, listed in Update Tags
   with zero members, and a `#tag` reference to it resolves (to nothing) instead of becoming an "Unbound tags" freeze
   error (section 5.2). A failed file never applies its `replace` flag and adds no entries.
2. If `replace` is true, clear the list collected so far.
3. Append the file's entries, in file order, each remembering its source pack id.

Step B. **Order by dependencies.** Build a graph: tag `A` depends on every **required** tag reference of any of its
entries (an edge that must be satisfied), and on every **optional** tag reference (an edge that only orders). Visit
tags so that referenced tags are built before the tags that reference them (`DependencySorter`). `DependencySorter.orderByDependencies` runs in two
passes over one multimap of edges: first it adds **every required** edge of every entry, then **every optional** edge. Each edge
goes through add-if-not-cyclic: the edge from `A` to `B` is dropped only when `B` can already reach `A` through the edges
recorded so far (the test follows recorded edges transitively; a direct reverse edge counts). Because all required edges are
recorded before any optional one, required edges win: in a cycle that mixes required and optional edges, an optional edge is the
one dropped. Among edges of the same kind the first one tried wins, and the order of trying follows the contents map, a plain
`HashMap`. After the edges are fixed, the visit is a depth-first walk over the key set of that same map (a visited set; each
tag's recorded dependencies are visited before the tag itself). An edge that would close a cycle is not recorded (so one tag of
a cycle is built before its dependency is available). The visiting order
of independent tags is the iteration order of a hash map: **not specified**; it does not change any result except in
cycles (6.5).

Step C. **Build each tag.** Maintain an ordered set `S` (insertion order, no duplicates) for the tag. For each entry in
collected order, apply `TagEntry.build`:

| Entry | Lookup | Result |
|---|---|---|
| element reference | `elementLookup(id, required)` | found: add the element to `S` (a duplicate element is ignored, first occurrence keeps its position). **Not found: if required, the entry fails; if optional, it is skipped silently** |
| tag reference | the tags already built in this load, by tag id | found: add that tag's elements, in that tag's order, to `S` (dedupe by first occurrence). **Not found: required fails, optional is skipped** |

If any required entry failed, the **whole tag is not built**: it is absent from the result and the log has "Couldn't
load tag <tag> as it is missing following references: <list of the failed entries with their source pack>". Otherwise
the tag's content is `S` in order (an immutable list). Consequently, a missing optional reference never causes an
error, a missing required reference makes the tag **missing**, and a tag that depends on a missing tag also fails
(it is itself missing from the built map), transitively.

`elementLookup` depends on the registry being loaded:

| Registry kind | Lookup used | Effect of "required" |
|---|---|---|
| a registry loaded in this layer (section 3, step 4) | `required = true`: the registration lookup (lazy, never fails, creates an unbound holder); `required = false`: only elements already registered | a *required* element that no file defines is **found** (unbound holder) and then fails at freeze ("Unbound values"); an *optional* one that is missing is skipped silently. So for these registries the tag-build "missing required element" case is reported by the freeze, not by the tag log |
| a static registry (built-in), tag read in step 2 of section 2 | lookup in the frozen registry by id, regardless of `required` | missing + required: the tag fails to build (logged); missing + optional: skipped |

Step D. **Bind.** The result map (tag id -> list of holders) is wrapped into tag keys and bound to the registry
(`bindTags`). For a registry loaded in this layer this happens before the freeze; for a static registry the result is
kept as pending tags and applied at the end of step 6 of section 2 (`Registry.prepareTagReload` then `apply`). Bind-time
member checks (including "Found direct holder <holder> value in tag <tag>") are in 3.6. A bound
tag replaces any earlier binding of that tag.

### 6.4 Order inside a tag

Order is the order of first occurrence while processing the entries in file order, with nested tag contents inserted at
the position of the `#tag` entry, and across stacked files in pack priority order (low to high) after any `replace`.
This order is what Update Tags sends (section 6.6). Clients and server code that iterate a tag (random choice from a
tag, `getRandomElementOf`) see this order.

### 6.5 Cycles and self-references

A tag that references itself, or a cycle of required references, cannot be satisfied: the edge that would close the
cycle is dropped from the build order, so one of the tags is built when the other is not yet available; a required
reference to an unavailable tag fails that tag, and every tag that requires the failed one fails with it. Which tag of
the cycle fails first depends on hash iteration order (Open question 4); **at least one tag of every cycle that has
only required edges is missing**. An optional edge in a cycle is skipped without failing the referencing tag. In a cycle that mixes both kinds the optional edge is
the one dropped from the ordering (6.3 step B: required edges are recorded first).

### 6.6 Network form (Update Tags) and its resolution on the client

Server (`TagNetworkSerialization.serializeTagsToNetwork` and `serializeToNetwork`): for every registry in
`networkSafeRegistries` (the static layer plus the synchronized world-layer registries, 04 §3.3), take the registry's bound
tags (`Registry.getTags`, which includes tags with no members); for each tag write the **numeric id of each element**
(`Registry.getId`) in the tag's order. Every member must be a **reference** holder: a holder of any other kind raises an
`IllegalStateException` whose text is "Can't serialize unregistered value <holder>" (this is the only String constant of
`TagNetworkSerialization`). The text "Found direct holder <holder> value in tag <tag>" does exist in the artifact, but in
`MappedRegistry`, as a tag-binding check (3.6); it is not a serialization message. Registries whose payload is empty are left out: a filter keeps a registry only when
`NetworkPayload.isEmpty()` is false, and `isEmpty` tests that the payload's tag map has no entries (so a registry whose
tags all exist with zero members is still sent, with those empty tags). There is no nesting, no `replace`, no optional
flag on the wire.

Client (`deserializeTagsFromNetwork`): for each tag, map each id through `Registry.get(int)` (which returns an Optional)
and flatten the Optionals, so ids that do not resolve are **silently dropped** (no error, no log); the tag keeps the
resolved holders in order. The load result for the registry carries exactly the tags of the payload, which are bound as the
registry's tag set (a later payload for the same registry replaces an earlier one: `TagLoader.loadTagsFromNetwork` calls
`NetworkPayload.resolve`, and the replacement itself happens in the registry bind step, whose body was not read; Open
question 5).

### 6.7 Worked examples (test vectors)

Registry `block` (static). Files, lowest priority pack first:

| Pack | File | Content |
|---|---|---|
| base | `data/minecraft/tags/block/logs.json` | `{"values": ["minecraft:oak_log", "#minecraft:birch_logs", "minecraft:acacia_log"]}` |
| base | `data/minecraft/tags/block/birch_logs.json` | `{"values": ["minecraft:birch_log", "minecraft:birch_wood"]}` |
| user | `data/minecraft/tags/block/logs.json` | `{"values": ["minecraft:oak_log", {"id": "x:cherry_log", "required": false}, "minecraft:dark_oak_log"]}` |

1. No `replace` anywhere. Collected entries for `minecraft:logs`: `oak_log`, `#birch_logs`, `acacia_log` (base), then
   `oak_log`, `x:cherry_log?`, `dark_oak_log` (user). Build order: `birch_logs` first. Result of `logs`, in order:
   `oak_log`, `birch_log`, `birch_wood`, `acacia_log`, `dark_oak_log` (the second `oak_log` is a duplicate and dropped;
   `x:cherry_log` does not exist, is optional, so it is skipped). Update Tags payload: the ids of those five blocks in
   that order.
2. If the user file had `"replace": true`: the base entries are discarded and the result is `oak_log`, `dark_oak_log`.
   `birch_logs` is still built (as its own tag) but is no longer referenced by `logs`.
3. If the user file used `"x:cherry_log"` as a plain String (required): the tag `logs` is **not built**; the log
   contains "Couldn't load tag minecraft:logs as it is missing following references: x:cherry_log (from user)" (exact
   source-pack text as logged); the tag is absent, `#minecraft:logs` in any consumer resolves to nothing, and every
   tag that required `#minecraft:logs` is missing too.
4. If `base/logs.json` contained `"#minecraft:logs"` (self reference): the tag is missing (6.5).

## 7. Value providers

Providers appear as fields of many registry elements (dimension type, features, structures, enchantment values, ...).
They are code: the codec shapes and the sampling formulas below are complete. `r.nextInt(n)` is the `RandomSource`
call with bound `n` (uniform in `[0, n)`); the bit-level generators are in 10 §3.

Notation: `rb(a, b)` = `a + r.nextInt(b - a + 1)` (`Mth.randomBetweenInclusive`, read), and
`ni(a, b)` = `a` if `a >= b`, otherwise `a + r.nextInt(b - a + 1)` (`Mth.nextInt`, read).
Draws happen in the order the formula is evaluated, innermost first.

### 7.1 IntProvider

Codec (`IntProviders.CODEC`): an **Int** is shorthand for `constant`; an **object** is dispatched on `type` over the
static `int_provider_type` registry (the id is a registry id: `minecraft:uniform` or `uniform`), with the type's fields
beside `type`. Encoding writes a bare Int for a `constant`. Two bounded variants exist: `NON_NEGATIVE_CODEC` (minimum
>= 0) and `POSITIVE_CODEC` (>= 1), and the parameterised `codec(min, max)`; each rejects a provider whose `minInclusive()`
is below the lower bound or whose `maxInclusive()` is above the upper bound with "Value provider too low: <v> [<min>-<max>]"
or "Value provider too high: <v> [<min>-<max>]". The range of a provider is the interval of values it can produce
(`minInclusive`, `maxInclusive`).

| `type` | Fields (all Req unless noted) | Validation on decode | Sample (`r` = random source) | Range |
|---|---|---|---|---|
| `constant` | `value` (Int) | none | `value` (no draw) | `[value, value]` |
| `uniform` | `min_inclusive`, `max_inclusive` (Int) | `max >= min`, else "Max must be at least min, min_inclusive: a, max_inclusive: b" | `rb(min, max)` (one draw) | `[min, max]` |
| `biased_to_bottom` | `min_inclusive`, `max_inclusive` | `max >= min`, else "Max must be at least min, min_inclusive: a, max_inclusive: b" (read in `BiasedToBottomInt`) | `min + r.nextInt( r.nextInt(max - min + 1) + 1 )` (inner draw first) | `[min, max]` |
| `very_biased_to_bottom` | `min_inclusive`, `max_inclusive` | `max >= min`, else the same message (read in `VeryBiasedToBottomInt`) | with `a = r.nextInt(max - min + 1)`, `b = r.nextInt(a + 1)`, result `min + r.nextInt(b + 1)` (three draws, in that order) | `[min, max]` |
| `clamped` | `source` (IntProvider), `min_inclusive`, `max_inclusive` | `max >= min`, else "Max must be at least min, min_inclusive: a, max_inclusive: b" (read) | `clamp(source.sample(r), min, max)` | `[max(min, source.min), min(max, source.max)]` |
| `weighted_list` | `distribution`: non-empty weighted list of IntProvider (7.5; field `distribution`, codec `WeightedList.nonEmptyCodec`) | total weight must be above 0: an empty list and a list whose weights are all 0 both fail with "Weighted list must contain at least one entry with non-zero weight" (7.5) | pick an entry by weight (one draw `r.nextInt(totalWeight)`, then the selector of 7.5), then `entry.sample(r)` | `minInclusive` is the smallest `minInclusive` of the entries and `maxInclusive` the largest `maxInclusive`, both computed once at construction (`WeightedListInt`: running `Math.min` / `Math.max` starting from `2147483647` and `-2147483648`) |
| `clamped_normal` | `mean` (Float), `deviation` (Float), `min_inclusive`, `max_inclusive` (Int) | `max >= min`, else "Max must be larger than min: [a, b]" (read; this is a different text from the `clamped` row, whose failure text is "Max must be at least min, min_inclusive: a, max_inclusive: b") | `(int) clamp( mean + (float) r.nextGaussian() * deviation, (float)min, (float)max )` (truncating cast, one Gaussian draw) | `[min, max]` |
| `trapezoid` | `min`, `max`, `plateau` (Int) | `max >= min` ("Max must be larger than min: [a, b]") and `plateau <= max - min` ("Plateau can at most be the full span: [a, b]") | see below | `[min, max]` |

`trapezoid` sample (read):

1. If `plateau == 0` and `max == -min`: `r.nextInt(max + 1) - r.nextInt(max + 1)` (two draws; the first term is drawn
   first).
2. Else let `range = max - min`. If `plateau == range`: `rb(min, max)`.
3. Else `slope = (range - plateau) / 2` (integer division) and `side = range - slope`; the result is
   `min + rb(0, side) + rb(0, slope)` (draws: first `r.nextInt(side + 1)`, then `r.nextInt(slope + 1)`).

Worked examples (sample draws given as the results of `nextInt`):

| Provider | Draws | Result |
|---|---|---|
| `uniform min 3 max 7` | `nextInt(5) = 2` | 5 |
| `biased_to_bottom min 2 max 12` | `nextInt(11) = 8`, then `nextInt(9) = 5` | `2 + 5 = 7` |
| `very_biased_to_bottom min 0 max 10` | `nextInt(11) = 9`, `nextInt(10) = 4`, `nextInt(5) = 3` | 3 |
| `trapezoid min -4 max 4 plateau 2` (not symmetric-triangle case since `plateau != 0`): `range = 8`, `slope = 3`, `side = 5` | `nextInt(6) = 4`, `nextInt(4) = 2` | `-4 + 4 + 2 = 2` |
| `trapezoid min -4 max 4 plateau 0` (symmetric, `plateau == 0`, `max == -min`) | `nextInt(5) = 4`, `nextInt(5) = 1` | `4 - 1 = 3` |
| `clamped_normal mean 1.0 dev 2.0 min 0 max 4`, `nextGaussian = 1.7` | one draw | `clamp(1.0 + 1.7*2.0 = 4.4, 0, 4) = 4.0` -> 4 |

### 7.2 FloatProvider

Codec (`FloatProviders.CODEC`): a **Float** is shorthand for `constant`; an object dispatches on `type` over the static
`float_provider_type` registry. Bounded wrappers `codec(min, max)` and `codec(min)` reject providers with
"Value provider too low: v [lo-hi]" / "Value provider too high: v [lo-hi]".

| `type` | Fields (all Req) | Validation | Sample |
|---|---|---|---|
| `constant` | `value` (Float) | none | `value` |
| `uniform` | `min_inclusive`, `max_exclusive` (Float) | `max > min` strictly ("Max must be larger than min, min: a, max: b") | `min + r.nextFloat() * (max - min)` (`Mth.randomBetween`, one draw) |
| `clamped_normal` | `mean`, `deviation`, `min`, `max` (Float) | `max >= min` ("Max must be larger than min: [a, b]") | `clamp(mean + (float) r.nextGaussian() * deviation, min, max)` |
| `trapezoid` | `min`, `max`, `plateau` (Float) | `max >= min` and `plateau <= max - min` (same messages as the int form) | `range = max - min; slope = (range - plateau) / 2; side = range - slope`; result `min + r.nextFloat() * side + r.nextFloat() * slope` (draw order: the `side` term first) |

Note (read): the code-side factory of the uniform float provider also throws an IllegalArgumentException with the text "Max must exceed min" when `max <= min`. That is a code-construction guard, not a data decode error; the only codec (data) message for the uniform float provider is the "Max must be larger than min, min: a, max: b" text in the table.

A fifth class `MultipliedFloats` (a `SampledFloat` product) and `SampledFloat` exist as run-time helpers; they are not
JSON types (no `type` id registered in `FloatProviders.bootstrap`: the registered types are exactly the four above).

### 7.3 HeightProvider and vertical anchors

#### 7.3.1 VerticalAnchor

Codec (`VerticalAnchor.CODEC`): an object with **exactly one** of these keys (the four alternatives are combined with
exclusive-or: zero keys or two keys is an error), each an Int in `[DimensionType.MIN_Y, DimensionType.MAX_Y]`
(`[-2032, 2031]`, section 7.3.3):

| Key | Meaning (resolved against a `WorldGenerationContext`) |
|---|---|
| `absolute` | `y = value` |
| `above_bottom` | `y = minGenY + value` |
| `below_top` | `y = (minGenY + genDepth - 1) - value` |
| `relative_to_sea_level` | `y = seaLevel + value` |

`VerticalAnchor.BOTTOM` is `above_bottom 0`; `TOP` is `below_top 0`; `seaLevel()` is `relative_to_sea_level 0`.
`WorldGenerationContext` supplies `getMinGenY`, `getGenDepth` (the generation height) and `seaLevel` of the chunk
generator or level (10 §5 for the overworld values).

#### 7.3.2 HeightProvider

Codec (`HeightProvider.CODEC`): a **VerticalAnchor object** is shorthand for `constant`; otherwise an object dispatches
on `type` over the static `height_provider_type` registry. `inner` below is an Int in `[1, 2147483647]`.

| `type` | Fields | Sample (`lo`/`hi` are the resolved anchors) |
|---|---|---|
| `constant` | `value` (VerticalAnchor) | resolved `value` (no draw) |
| `uniform` | `min_inclusive`, `max_inclusive` (VerticalAnchor) | if `lo > hi`: log "Empty height range: <provider>" once per distinct `(lo, hi)` pair and return `lo`; else `rb(lo, hi)` |
| `biased_to_bottom` | `min_inclusive`, `max_inclusive`, `inner` (Opt, default 1) | if `hi - lo - inner + 1 <= 0`: log "Empty height range: ..." and return `lo`; else `lo + r.nextInt( r.nextInt(hi - lo - inner + 1) + inner )` (inner draw first) |
| `very_biased_to_bottom` | same fields | same empty-range rule; else `a = ni(lo + inner, hi)`; `b = ni(lo, a - 1)`; result `ni(lo, b - 1 + inner)` (three draws in that order) |
| `trapezoid` | `min_inclusive`, `max_inclusive`, `plateau` (Int, Opt default 0) | if `lo > hi`: log "Empty height range: ..." and return `lo`. `range = hi - lo`; if `plateau >= range`: `rb(lo, hi)`; else `slope = (range - plateau) / 2`, `side = range - slope`, result `lo + rb(0, side) + rb(0, slope)` |
| `weighted_list` | `distribution`: non-empty weighted list of HeightProvider | pick by weight, then sample the entry |

Worked example. `biased_to_bottom` with `min_inclusive` `{"absolute": 0}`, `max_inclusive` `{"absolute": 10}`, `inner`
default 1: `hi - lo - inner + 1 = 10`; with `nextInt(10) = 7` then `nextInt(7 + 1) = 3`: result `0 + 3 = 3`. Same fields with
`very_biased_to_bottom`: `a = ni(1, 10) = 1 + nextInt(10)`, say 8 (`nextInt(10) = 7`); `b = ni(0, 7) = nextInt(8)`, say
3; result `ni(0, 3 - 1 + 1) = ni(0, 3) = nextInt(4)`, say 2: result 2.

#### 7.3.3 Dimension height bounds (resolves 04 Open question 6)

Read from the static initialisers: `BlockPos.PACKED_HORIZONTAL_LENGTH = 1 + log2(smallestEncompassingPowerOfTwo(30000000))
= 1 + log2(33554432) = 26`; `PACKED_Y_LENGTH = 64 - 2 * 26 = 12`; `DimensionType.BITS_FOR_Y = 12`;
`Y_SIZE = (1 << 12) - 32 = 4064`; `MAX_Y = (Y_SIZE >> 1) - 1 = 2031`; `MIN_Y = MAX_Y - Y_SIZE + 1 = -2032`;
`WAY_ABOVE_MAX_Y = MAX_Y << 4`, `WAY_BELOW_MIN_Y = MIN_Y << 4`; `MIN_HEIGHT = 16`. These are the bounds used in the
dimension-type table of 04 §6 and by `VerticalAnchor`.

### 7.4 BlockStateProvider

Codec (`BlockStateProvider.DIRECT_CODEC`): exactly one of

1. a **block state object** (`BlockState.FULL_CODEC`: `{"id": ..., "properties": {...}}`, 04 §6), meaning a `simple`
   provider with that state; or
2. a **typed provider** (`TYPED_CODEC`): an object dispatched on `type` over the static `worldgen/block_state_provider_type`
   registry.

`BlockStateProvider.CODEC` (used wherever a feature config says "block state provider") is **Id-or-inline** over the
registry `worldgen/block_state_provider` (section 5.1): a String names an element of that registry, an object is the
direct form above. `getState(level, random, pos)` returns the state to place; `getOptionalState` is the nullable variant
used by placement code that can skip.

The 10 provider types (registry ids as written in the artifact, `minecraft:` namespace):

| `type` | Fields | State selection |
|---|---|---|
| `simple` | `state` (BlockState) | always `state` (no draw) |
| `weighted` | `entries`: non-empty weighted list of BlockState (7.5; field codec `WeightedList.nonEmptyCodec`, so a decode of an empty or all-zero list fails with the 7.5 message; the constructor of `WeightedStateProvider` additionally throws an exception with the text "Weighted list must have at least one entry" when it is built with an empty list in code, which a decoded provider never reaches) | weighted pick (one `nextInt(totalWeight)`) |
| `random_block` | `blocks`: a **HolderSet over the static `block` registry** (`RegistryCodecs.holderSet(block)` with the default non-homogeneous form of 5.1: one block id, a `#tag`, or a list of block ids; **not** a list of block states) | `HolderSet.getRandomElement(r)`: when the set is empty nothing is drawn and the result is the **block state already in the level at the position**; otherwise one draw `r.nextInt(size)` (`Util.getRandomSafe` on the set's list, tag order of 6.4 for a tag) picks a block and the result is that block's **default state**. The `optional` variant returns nothing for an empty set |
| `rotated` | `state` (BlockStateProvider, Id-or-inline, Req), `direction` (Direction name `down` `up` `north` `south` `west` `east`, **Opt**, absent by default) | 1. the direction is the given one, or, when absent, `Direction.getRandom(r)` = one draw `r.nextInt(6)` into the enum order `down, up, north, south, west, east` (`Util.getRandom(array, r)`); this draw happens **before** the inner provider is asked. 2. the inner provider's state is computed (its own draws). 3. the property `axis` is set to the direction's axis (`trySetValue`: ignored when the block has no such property). 4. the property `facing` is set to the direction (also ignored when absent). 5. when the direction's axis is horizontal, the property `horizontal_facing` is set to the direction (ignored when absent). The result is the final state |
| `copy_properties` | `source` (BlockStateProvider, Id-or-inline, Req); **no other field** | `source.getState(...)` is computed (its own draws), then every property that the **block currently at the position** defines is copied onto that state with `trySetValue` (a property the source block lacks is ignored; the copied value is the one of the level state): `BlockState.withPropertiesOf(levelState)` over `levelState.getBlock().getStateDefinition().getProperties()`. The result keeps the source's block |
| `randomized_int` | `source` (BlockStateProvider, Id-or-inline, Req), `property` (String, Req), `values` (IntProvider, Req) | 1. `source.getState(...)`. 2. The integer property is looked up by **name** among the state's properties (first one that is an `IntegerProperty` with that name, cached after the first success; when the cached property is not on the new state, looked up again). 3. When no integer property of that name exists the source state is returned **unchanged** (no sample drawn). 4. Otherwise `state.setValue(property, values.sample(r))` (one sample, drawn after the source's draws). A sampled value outside the property's range makes `setValue` throw at run time; the codec does not check it (the exception text "Property value out of range: <name>: <value>" belongs to the code-side constructor that takes a ready property and tests `values` min/max against the property's possible values) |
| `rule_based` | `fallback` (BlockStateProvider, Id-or-inline, **Opt**), `rules`: list of `{if_true: BlockPredicate, then: BlockStateProvider}` (`rules` Req) | the first rule whose predicate holds at the position gives the state (`then`); no match uses `fallback`; with no fallback no state: the `optional` form returns nothing |
| `noise` | `seed` (Long, Req), `noise` (`NormalNoise.DIRECT_CODEC` parameters, Req), `scale` (`ExtraCodecs.POSITIVE_FLOAT`, Req), `states` (`ExtraCodecs.nonEmptyList(list of BlockState.CODEC)`, Req) | noise value `v` (float) = the noise at `(x*scale, y*scale, z*scale)` (7.4.1); index `floor( clamp((1 + v) / 2, 0, 0.9999) * size )` (float arithmetic, truncating cast) into `states`. No random draw at all |
| `dual_noise` | `variety` (`InclusiveRange<Int>` with `min_inclusive` and `max_inclusive`, bounds `[1, 64]`, Req), `slow_noise` (NormalNoise parameters, Req), `slow_scale` (`POSITIVE_FLOAT`, Req), plus the four `noise` fields (`seed`, `noise`, `scale`, `states`) | **no random draw.** Let `slow(P)` be the slow noise sampled at position `P` with coordinates `float(x) * slow_scale` (float product, then widened), likewise for y and z. 1. `s = slow(pos)`. 2. window size `n = (int) clampedMap(s, -1.0, 1.0, variety.min, variety.max + 1)`, where `clampedMap` is `Mth.clampedMap(v, inLo, inHi, outLo, outHi)` = `outLo + t*(outHi - outLo)` with `t = clamp((v - inLo)/(inHi - inLo), 0, 1)` (`Mth.inverseLerp` then `Mth.clampedLerp`; the cast truncates, so `n` reaches `variety.max + 1` only at `s >= 1`). 3. Build a list of `n` states: entry `i` (`i` from 0) is `states[idx]` where `idx` is the `noise`-provider index formula above applied to `slow(pos + (i * 54545, 0, i * 34234))` (offsets as ints added to the block position). 4. The result is the entry of that list chosen by the same index formula applied to the **main** noise value at `pos` with `scale` (the value `getNoiseValue(pos, scale)`). The slow noise is created from its own `WorldgenRandom(LegacyRandomSource(seed))` with the **same `seed`** as the main noise |
| `noise_threshold` | the four fields `seed`, `noise`, `scale` (as `noise`, but **no** `states`), `threshold` (Float in `[-1, 1]`, Req), `high_chance` (Float in `[0, 1]`, Req), `default_state` (BlockState.CODEC, Req), `low_states` (non-empty list of BlockState.CODEC, Req), `high_states` (non-empty list, Req) | `v` = the noise at `(x*scale, y*scale, z*scale)`, compared as a double. 1. If `v < threshold` (strictly): one draw `r.nextInt(size(low_states))`, result `low_states[that]`. 2. Otherwise draw `r.nextFloat()`; if it is `< high_chance` (strictly) draw `r.nextInt(size(high_states))` and the result is `high_states[that]`; 3. otherwise the result is `default_state` (only the `nextFloat` was drawn) |

**`BlockState.CODEC` versus `FULL_CODEC`.** The `simple` provider's `state` field and the `states`, `default_state`,
`low_states` and `high_states` fields use `BlockState.CODEC`, which accepts either a **bare block id String** (decoded to
that block's default state) or the object form of `FULL_CODEC` (`{"id": ..., "properties": {...}}`, `properties`
optional and read leniently). Encoding writes the bare id when the state is the block's default state. (Read in the
static initialiser of `BlockState`.) The bare `BlockStateProvider.DIRECT_CODEC` of the first alternative above uses
`FULL_CODEC` (an object, never a bare String: the String form is the registry-name form of `BlockStateProvider.CODEC`).

Registration order of the ten provider types in `BlockStateProviderTypes` (the registry order, hence the ids of 46):
`copy_properties`, `dual_noise`, `noise`, `noise_threshold`, `random_block`, `randomized_int`, `rotated`, `rule_based`,
`simple`, `weighted`. Note that the first column of the table above lists the types in a different order.

#### 7.4.1 Noise-based providers

The shared base class `NoiseBasedStateProvider` has the fields `seed` (Long), `noise` (`NormalNoise.DIRECT_CODEC`) and
`scale` (`ExtraCodecs.POSITIVE_FLOAT`; the codec rejects zero and negative values). **At construction** it calls
`NormalNoise.create(RandomSource)` on the decoded parameters with a fresh `WorldgenRandom(LegacyRandomSource(seed))`
(read: constructor), which yields a `Noise` object kept for the provider's life. Its value at a position is
`Noise.get(double x, double y, double z)` returning a **float**, called with `(double) blockX * (double) scale` and the same
for y and z (the float `scale` is widened to double first; for `dual_noise` the slow noise instead multiplies in float:
7.4). The noise algorithm (`NormalNoise`, `PerlinNoise`) and the `LegacyRandomSource` / `WorldgenRandom` generators are in
10 §3 and 11 §4. `noise` itself is the `NormalNoise` parameter codec (fields of `NormalNoise$Parameters`, the same shape as
a `worldgen/noise` element: `firstOctave` and `amplitudes`; see 10). Because the generator is built from the seed at
construction, two providers with the same `seed` and parameters give identical values, and the sample draws nothing from
the caller's random source.

### 7.5 WeightedList

Classes: `WeightedList`, `Weighted`, `WeightedRandom`, and the two selectors `WeightedList$Flat` and `WeightedList$Compact`.

**Codec.** A JSON **list** of objects `{"data": <E>, "weight": <non-negative Int>}` (`Weighted.codec`: `data` Req,
`weight` Req with `ExtraCodecs.NON_NEGATIVE_INT`; an overload taking a `MapCodec` for the data also exists in `Weighted` and
its entry shape was not read, and it is not used by any codec of this document; a stream codec for the network form also exists). Two list codecs exist: the plain
`codec(...)` (an empty list is accepted) and `nonEmptyCodec(...)`, which every use in this document takes (the `distribution`
of int and height `weighted_list`, the `entries` of the `weighted` block state provider). `nonEmptyCodec` has **one**
validation message, "Weighted list must contain at least one entry with non-zero weight". It fires when
`WeightedList.isEmpty()` is true, and `isEmpty` is true exactly when the list's **total weight is 0**, which covers both the
empty list `[]` and a list whose every weight is 0. The text "Weighted list has no elements" is **not a decode error**: it
is the `IllegalStateException` text of `getRandomOrThrow` (a sampling call on an empty list) and cannot be reached from
decoded data because decode already refused the list.

**Construction** (`WeightedList` constructor): the entries are copied; the total weight is the sum of the weights computed
in 64 bits (`WeightedRandom.getTotalWeight`), and a sum above 2147483647 throws `IllegalArgumentException` "Sum of weights
must be <= 2147483647" (an element error when it happens during decode). `Weighted` itself throws "Weight should be >= 0" for a
negative weight and, for a weight of exactly 0, logs the warning "Found 0 weight, make sure this is intentional!" (once
per such entry at its construction; a warning, not an error). The selector is then chosen by the total weight:

| Total weight | Selector | Behaviour |
|---|---|---|
| 0 | none (null) | `isEmpty` true; `getRandom` returns nothing and draws nothing; `getRandomOrThrow` throws |
| 1 to 63 (`FLAT_THRESHOLD` = 64, the flat form is used when the total is **below** 64) | `Flat` | a table with one slot per unit of weight, filled in list order (entry 1 fills slots `[0, w1)`, entry 2 the next `w2` slots, ...); the draw indexes the table directly |
| 64 or more | `Compact` | walks the entries in list order, subtracting each entry's weight from the drawn value, and returns the first entry for which the running value becomes **negative** |

Both selectors give the same entry for the same draw: the entry `k` whose cumulative range `[w1 + ... + w(k-1), w1 + ... + wk)`
contains the draw. (Entries with weight 0 never match. `Compact` throws an `IllegalStateException` "<v> exceeded total
weight" if the walk ends without a match; unreachable for a draw below the total.)

**Sampling.** `getRandom` and `getRandomOrThrow` draw **once** `r.nextInt(totalWeight)` and pass the value to the selector;
the chosen entry's own sample (an int provider's `sample`, a height provider's sample) then follows, so a weighted
provider consumes the selection draw first and the entry's draws after it.

Worked examples. Entries `[ {data A, weight 2}, {data B, weight 0}, {data C, weight 3} ]`: total 5 (Flat table
`A A C C C`). Draw 0 or 1 gives A, draw 2, 3 or 4 gives C, B is never chosen. A list of 40 entries of weight 2 (total 80,
Compact): for draw 79, after 39 subtractions the running value is 79 - 78 = 1 (not negative), the 40th gives 1 - 2 = -1, so entry 40 is returned.
`weighted_list` int provider over `[uniform 1..2 weight 1, constant 10 weight 1]`: range `[1, 10]` (minimum of the minima, maximum of the
maxima).

## 8. Environment attributes

An **environment attribute** is a typed, named quantity (fog colour, sky colour, whether bees stay in the hive, the
spawn table ...) that biomes, dimension types and timelines can set, and that game code reads per position and time.
Attributes are code-defined: the `environment_attribute` static registry has the 51 entries of section 8.3; the 15
**attribute types** are the static registry `attribute_type`. Run-time sampling (layers, interpolation, time tracks) is
document 33; this section specifies the **definitions and the data codecs**.

### 8.1 Attribute definition fields

Each `EnvironmentAttribute` has: `type` (an `AttributeType`), `defaultValue` (required, "Missing default value" if absent),
`valueRange` (default: any value allowed), and four flags (defaults in brackets):

| Flag | Default | Meaning (read from the builder and uses) |
|---|---|---|
| `syncable` | false | the attribute is kept in the network form of `EnvironmentAttributeMap` and of timeline tracks; non-syncable entries are **dropped in both directions** of the network codecs |
| `positional` | **true** | the attribute may vary by position; `notPositional` sets false. A non-positional attribute is rejected in a **biome** `attributes` map (`CODEC_ONLY_POSITIONAL`), but allowed in a dimension type's `attributes` |
| `spatiallyInterpolated` | false | the sampled value is interpolated across biome boundaries (33) |
| `fullResolutionBiomes` | false | the attribute is looked up with full-resolution biome data instead of the blurred biome grid (33) |

`valueCodec` of an attribute is the type's value codec **validated by the range**. A range is one of: *any*; or a float
interval `[min, max]` (inclusive both ends). Predefined: `UNIT_FLOAT` = `[0, 1]`; `UNIT_FLOAT_EPSILON` = `[0, 0.9999999]`;
`NON_NEGATIVE_FLOAT` = `[0, +Infinity]`. Validation error text (a constant of the nested class `AttributeRange$2`, not of `AttributeRange`, which has no String constants): "<value> is not in range [<min>; <max>]". `sanitize(value)` clamps a float into the interval (used
when a sampled or combined value leaves the range), and is the identity for *any*.

### 8.2 The 15 attribute types

| Type id | Value codec (data form) | Default interpolation | Modifier library (op ids; section 8.4) |
|---|---|---|---|
| `boolean` | boolean | step; thresholds 1 (keyframe), 0 (state change), 0.5 (spatial), 0 (partial tick), see the "Step" paragraph below this table | `and`, `nand`, `or`, `nor`, `xor`, `xnor` (+ `override`) |
| `tri_state` | `true`, `false`, `default` (also accepts a boolean) | step | `override` only |
| `float` | Float | linear (`Mth.lerp`) | `alpha_blend`, `add`, `subtract`, `multiply`, `minimum`, `maximum` |
| `angle_degrees` | Float | keyframe, state-change and spatial blending: linear; **partial-tick** blending: the shortest-arc function with a 90-degree limit (8.5) | same as `float` |
| `rgb_color` | colour (8.6) as a 3-float vector | per-component linear | `alpha_blend`, `add`, `subtract`, `multiply`, `blend_to_gray` |
| `argb_color` | colour (8.6) as a 4-float vector | per-component linear | `alpha_blend`, `add`, `subtract`, `multiply`, `blend_to_gray` |
| `integer` | Int | `Mth.lerpInt(t, a, b)` = `a + floor(t * (float)(b - a))` (8.5) | `add`, `subtract`, `multiply`, `minimum`, `maximum` |
| `moon_phase` | String: `full_moon`, `waning_gibbous`, `third_quarter`, `waning_crescent`, `new_moon`, `waxing_crescent`, `first_quarter`, `waxing_gibbous` | step | `override` only |
| `activity` | Identifier of an entry of the static `activity` registry | step | `override` only |
| `bed_rule` | object (8.7) | step | `override` only |
| `particle` | a particle options value (`ParticleTypes.CODEC`: an Identifier or an object with `type` plus options) | step | `override` only |
| `ambient_particles` | list of `{particle, probability}` (8.7) | cross-fade (8.5) | `append` |
| `background_music` | object (8.7) | step | `override` only |
| `ambient_sounds` | object (8.7) | step | `override` only |
| `mob_spawn_settings` | the `MobSpawnSettings` codec of a biome's spawner table (18 App A) | step | `overlay` |

An `AttributeType` carries four interpolation functions (keyframe, state change, spatial, partial tick). Interpolated types
built with one function use it for all four; the five-argument form (`float`, `angle_degrees`, `integer`) takes a second
function for the **partial-tick** slot only. `float`, `angle_degrees` and `integer` also define `toFloat` conversions
(`integer` also `toInt`) used when a value is read as a number; the other types have none. `AttributeType` carries the failure
texts of those conversions: "<value> cannot be represented as a float" and "<value> cannot be represented as an integer".

"Step" types (`ofNotInterpolated`) have four interpolation functions that all select between the two endpoint values by a
threshold on the progress `t in [0, 1]`: key-frame blending switches at `t >= 1`, state-change blending switches at
`t >= 0`, spatial blending switches at `t >= 0.5`, and partial-tick blending switches at `t >= 0`. (`ofStep(th)` returns
the second value when `t >= th`, else the first; read in `LerpFunction.ofStep` and `AttributeType.ofNotInterpolated`.) The
`override` operation is available in every type's library. The `checkAllowedModifier` rule: a modifier object that is neither
`override` nor an element of the type's library is rejected ("Modifier <modifier> is not valid for <type>").

### 8.3 The 51 attributes

Registry ids are `minecraft:<name>`. "Range" is the value range of 8.1. Colour defaults are shown as 24-bit RGB; 4-float
colours as `AARRGGBB`. Flags: S = syncable, N = not positional, I = spatially interpolated, F = full-resolution biomes. A row with an empty flags column is positional, not synced, not interpolated and not full-resolution.

| Name | Type | Default | Range | Flags |
|---|---|---|---|---|
| `visual/fog_color` | rgb_color | `000000` | any | S I |
| `visual/fog_start_distance` | float | 0.0 | any | S I |
| `visual/fog_end_distance` | float | 1024.0 | non-negative | S I |
| `visual/sky_fog_end_distance` | float | 512.0 | non-negative | S I |
| `visual/cloud_fog_end_distance` | float | 2048.0 | non-negative | S I |
| `visual/water_fog_color` | rgb_color | `050533` | any | S I |
| `visual/water_fog_start_distance` | float | -8.0 | any | S I |
| `visual/water_fog_end_distance` | float | 96.0 | non-negative | S I |
| `visual/sky_color` | rgb_color | `000000` | any | S I |
| `visual/sunrise_sunset_color` | argb_color | `00000000` | any | S I |
| `visual/cloud_color` | argb_color | `00000000` | any | S I |
| `visual/cloud_height` | float | 192.33 | any | S I |
| `visual/sun_angle` | angle_degrees | 0.0 | any | S I |
| `visual/moon_angle` | angle_degrees | 0.0 | any | S I |
| `visual/star_angle` | angle_degrees | 0.0 | any | S I |
| `visual/moon_phase` | moon_phase | `full_moon` | n/a | S |
| `visual/star_brightness` | float | 0.0 | unit | S I |
| `visual/block_light_tint` | rgb_color | `FFD88C` | any | S I |
| `visual/sky_light_color` | rgb_color | `FFFFFF` | any | S I |
| `visual/sky_light_factor` | float | 1.0 | unit | S I |
| `visual/night_vision_color` | rgb_color | `999999` | any | S I |
| `visual/ambient_light_color` | rgb_color | `000000` | any | S I |
| `visual/default_dripstone_particle` | particle | the dripping dripstone water particle | n/a | S |
| `visual/ambient_particles` | ambient_particles | empty list | n/a | S |
| `audio/background_music` | background_music | empty (`BackgroundMusic.EMPTY`) | n/a | S |
| `audio/music_volume` | float | 1.0 | unit | S |
| `audio/ambient_sounds` | ambient_sounds | empty (`AmbientSounds.EMPTY`) | n/a | S |
| `audio/firefly_bush_sounds` | boolean | false | n/a | S |
| `gameplay/sky_light_level` | float | 15.0 | `[0, 15]` | N S |
| `gameplay/can_start_raid` | boolean | true | n/a | |
| `gameplay/water_evaporates` | boolean | false | n/a | S |
| `gameplay/bed_rule` | bed_rule | `can_sleep_when_dark` (8.7) | n/a | |
| `gameplay/straw_bed_rule` | bed_rule | `destroy_on_leave` (8.7) | n/a | |
| `gameplay/respawn_anchor_works` | boolean | false | n/a | |
| `gameplay/nether_portal_spawns_piglin` | boolean | false | n/a | |
| `gameplay/fast_lava` | boolean | false | n/a | N S |
| `gameplay/increased_fire_burnout` | boolean | false | n/a | |
| `gameplay/eyeblossom_open` | tri_state | `default` | n/a | |
| `gameplay/turtle_egg_hatch_chance` | float | 0.002 | unit | |
| `gameplay/piglins_zombify` | boolean | true | n/a | S |
| `gameplay/snow_golem_melts` | boolean | false | n/a | |
| `gameplay/creaking_active` | boolean | false | n/a | S |
| `gameplay/surface_slime_spawn_chance` | float | 0.0 | unit | |
| `gameplay/cat_waking_up_gift_chance` | float | 0.0 | unit | |
| `gameplay/bees_stay_in_hive` | boolean | false | n/a | |
| `gameplay/monsters_burn` | boolean | false | n/a | |
| `gameplay/can_pillager_patrol_spawn` | boolean | true | n/a | |
| `gameplay/natural_mob_spawns` | mob_spawn_settings | the empty spawn settings | n/a | F |
| `gameplay/creature_world_gen_spawn_probability` | float | 0.1 | `[0, 0.9999999]` | |
| `gameplay/villager_activity` | activity | `idle` | n/a | |
| `gameplay/baby_villager_activity` | activity | `idle` | n/a | |

Registry order (the `environment_attribute` registration order, which is the numeric id in 46) is the row order above. Verified from the static initialiser of `EnvironmentAttributes` in this round: the 51 name constants, in the order of the class's registration code, equal the 51 rows above in the same order (compared name by name); the claim about 46 itself was not re-read from 46.
The syncable set (the attributes that survive the network `attributes` map and timeline tracks) is exactly the rows with
flag S: **33** attributes (all 24 `visual/*` rows, all 4 `audio/*` rows, and 5 `gameplay/*` rows: `sky_light_level`,
`water_evaporates`, `fast_lava`, `piglins_zombify`, `creaking_active`). This answers 04 Open question 7 (which attributes
are syncable). The row count is 24 + 4 + 23 = 51. The non-positional attributes (flag N, rejected inside a biome map) are
`gameplay/sky_light_level` and `gameplay/fast_lava`.

Colour default arithmetic (read from `ARGB.vector3fFromRGB24`, `vector4fFromARGB32`): the integer defaults in the bytecode
are `0` (black), `-16448205` (= `0xFF050533`, so RGB `050533`), `-10100` (= `0xFFFFD88C`, low 24 bits `FFD88C`), `-1`
(white), `-6710887` (= `0xFF999999`, RGB `999999`) and `-16777216` (= `0xFF000000`, RGB `000000`); only the low 24 bits
are used for RGB defaults, and each channel is `byte / 255`. The ARGB defaults are `0` = fully transparent black.

### 8.4 Modifiers

An attribute value in data is either the plain value (shorthand for the `override` modifier with that value) or an object
`{"modifier": <op id>, "argument": <per-op value>}`. The decoder tries the object form first, then the plain value
(`Codec.either(dispatch, valueCodec)`); the plain value is checked against the attribute's **range**; an `override`
object's argument is the attribute value codec (also range-checked); the arguments of other ops use the codec in the table
and are not range-checked. `modifier` is an id from the **type's library** (8.2); an id not in the library (and not
`override`) is rejected.

Operation ids (`AttributeModifier$OperationId`, in order): `override`, `alpha_blend`, `add`, `subtract`, `multiply`,
`blend_to_gray`, `minimum`, `maximum`, `and`, `nand`, `or`, `nor`, `xor`, `xnor`, `append`, `overlay` (16).

| Op | Subject types | Argument codec | Result (`s` = the value so far, `a` = the argument) |
|---|---|---|---|
| `override` | all | the attribute value codec | `a` |
| `add` (float, integer) | float, angle_degrees, integer | Float / Int | `s + a` |
| `subtract` | same | same | `s - a` |
| `multiply` | same | same | `s * a` |
| `minimum` | same | same | `min(s, a)` |
| `maximum` | same | same | `max(s, a)` |
| `alpha_blend` (float) | float, angle_degrees | Float, or object `{value: Float, alpha: Float in [0,1], default 1}` | `s + alpha * (value - s)` (`Mth.lerp(alpha, s, value)`); keyframe blending interpolates `value` and `alpha` independently |
| `and`, `nand`, `or`, `nor`, `xor`, `xnor` | boolean | boolean | the standard logic function of `s` and `a` (the six, in enum order AND, NAND, OR, NOR, XOR, XNOR; plain truth tables, read as a switch over the six) |
| `add` (colour) | rgb_color, argb_color | RGB colour (`STRING_RGB_VEC3_COLOR`) | per channel `min(s + a, 1)`; for argb the alpha is unchanged |
| `subtract` (colour) | same | RGB colour | per channel `max(s - a, 0)`; alpha unchanged |
| `multiply` (rgb) | rgb_color | RGB colour | per channel `s * a` (identity when either is all ones) |
| `multiply` (argb) | argb_color | ARGB colour | per channel including alpha `s * a` |
| `alpha_blend` (rgb) | rgb_color | ARGB colour (`a.w` is the blend alpha) | if `a.w == 0` then `s`; else linear mix `s + a.w * (a.rgb - s)` |
| `alpha_blend` (argb) | argb_color | ARGB colour | with `sa` = alpha of `s` and `aa` = alpha of `a`: `aa == 1` gives `a`; `aa == 0` gives `s`; else the output alpha is `aa + sa * (1 - aa)` and each channel is `(aa * a_c + sa * (1 - aa) * s_c) / outAlpha` (read from `alphaBlend` and `alphaBlendChannel`) |
| `blend_to_gray` | rgb_color, argb_color | object `{brightness: Float in [0,1], factor: Float in [0,1]}` (both Req) | `g = 0.3*r + 0.59*gc + 0.11*b` (luma weights **0.3, 0.59, 0.11**, read in `ARGB.greyscale`); the grey colour `(g, g, g)` is scaled by `brightness` (each channel clamped to `[0,1]`), then the result is `lerp(factor, s, grey*brightness)` per channel (alpha unchanged for argb) |
| `append` | ambient_particles | list of AmbientParticle | if `a` is empty: `s`; else if `s` is empty: `a`; else `s` followed by `a` |
| `overlay` | mob_spawn_settings | spawn-settings object | the argument's spawn data is overlaid on the subject (details: 18 App A, not read here, Open question 10) |

Application order: an attribute map entry holds **one** modifier and its argument. When several sources contribute to one
attribute (dimension type map, biome map, timeline tracks, weather, other layers) they are applied as layers in the
order given in 33; this document specifies only the single entry.

### 8.5 Keyframe and state interpolation functions

| Function | Behaviour |
|---|---|
| float | `Mth.lerp(t, a, b) = a + t * (b - a)` (read) |
| integer | `Mth.lerpInt(t, a, b)` = `a + floor(t * (float)(b - a))`: the difference is converted to float, multiplied by the float `t`, floored (`Mth.floor`, toward negative infinity) and added to `a` as an int (read) |
| colour (3- and 4-float) | `ARGB.srgbLerp` over the vector, which is a **linear** component-wise lerp (read: it calls the vector `lerp`) |
| degrees (`ofDegrees(limit)`, limit 90, the partial-tick function of `angle_degrees`) | let `d = wrapDegrees(b - a)` (wrap into `[-180, 180)`, read: remainder 360, then -360 if `>= 180`, then +360 if `< -180`); if `|d| < limit`: `a + t * d` (shortest arc); otherwise the result is **`b` for every `t`** |
| step(th) | `b` if `t >= th`, else `a` |
| list cross-fade (`ambient_particles`) | `t == 0` gives `a`, `t == 1` gives `b`; otherwise the list of every element of `a` with its probability scaled by `(1 - t)` followed by every element of `b` scaled by `t` |

### 8.6 Colour value forms

Attribute colour values and colour arguments accept three data forms (`ExtraCodecs`), all converted to float vectors. The
hex string is tried first, then the alternative (`Codec.withAlternative`).

| Codec (`ExtraCodecs` field) | Used for | String form | Alternative forms (read) |
|---|---|---|---|
| `STRING_RGB_VEC3_COLOR` | `rgb_color` values and `add`/`subtract`/`multiply` arguments | `"#RRGGBB"`: `#` plus exactly 6 hex digits; the value gets alpha 255 added (`ARGB.opaque`) and is turned into a 3-vector (`vector3fFromRGB24`: red, green, blue, each byte / 255) | `RGB_COLOR_VEC3_CODEC`: a **list of 3 floats** `[r, g, b]` (components 0 to 1, vector order x, y, z = red, green, blue), or a plain **Int**, of which only the low 24 bits are used (`vector3fFromRGB24`) |
| `STRING_ARGB_VEC4_COLOR` | `argb_color` values and arguments, and the `alpha_blend`/`blend_to_gray` colour arguments | `"#AARRGGBB"`: `#` plus exactly 8 hex digits, turned into a 4-vector (`vector4fFromARGB32`: red, green, blue, alpha, each byte / 255; vector order x, y, z, w = red, green, blue, alpha) | `ARGB_COLOR_VEC4_CODEC`: a **list of 4 floats** `[r, g, b, a]`, or a plain **Int** read as ARGB32 (alpha in the top byte) |
| `STRING_RGB_COLOR` and `STRING_ARGB_COLOR` | int-valued colour fields elsewhere (not attributes) | `#` plus 6 digits (the value gets alpha 255 added) / 8 digits | `RGB_COLOR_CODEC`: an Int, or a list of 3 floats packed with alpha 1.0 (`ARGB.colorFromFloat(1, r, g, b)`); `ARGB_COLOR_CODEC`: an Int or a list of 4 floats |

Hex string rules (`ExtraCodecs.hexColor(digits)`), all errors being data errors of the field: the text must start with `#`
("Hex color must begin with #"); the number of characters after `#` must equal `digits` ("Hex color is wrong size, expected
<digits> digits but got <n>"); the digits are parsed as an unsigned number that must lie in `[0, 16^digits - 1]` (an
unparsable digit string gives "Invalid color value: <text>" and a value outside the range gives "Color value out of range:
<text>"; both read in `ExtraCodecs`, the argument being the input text (inferred: the message builders take one String)). Hex digits of either case are
accepted (inferred: the parser is `HexFormat.fromHexDigitsToLong`, not read further). Encoding a 3-vector writes the
channels as `floor(component * 255)` (`ARGB.as8BitChannel`) and the string as `#` plus 6 digits (lower case, from the default `HexFormat`: recalled, not verified); encoding a 4-vector writes 8 digits in ARGB order. Converting a float vector to an Int uses the same
`floor(component * 255)` and, for an RGB list, alpha 255.

Constructed test vectors (the values are invented for this document, not read from the artifact). `"#c0d8ff"` gives `(192/255, 216/255, 255/255)`; the Int `-16448205` (`0xFF050533`) for an
`rgb_color` gives `(5/255, 5/255, 51/255)` (the alpha byte is ignored); `[0.5, 0.25, 1.0]` is accepted as is, without
rounding to bytes, for a vector codec, but an Int-valued codec would store `(127, 63, 255)`. `"#80FF0000"` for an
`argb_color` gives `(1.0, 0.0, 0.0, 128/255)`.

### 8.7 Other attribute value shapes

| Name | Fields | Notes |
|---|---|---|
| BedRule | `can_sleep`: `always` / `when_dark` / `never` (Req); `can_set_spawn`: same enum (Req); `destroy_on_use` (boolean, Opt, default `false`); `destroy_on_leave` (boolean, Opt, default `false`); `error_message` (TextComponent, Opt, absent by default) | Three constants are defined (field order of the constructor: `can_sleep`, `can_set_spawn`, `destroy_on_use`, `destroy_on_leave`, `error_message`). `CAN_SLEEP_WHEN_DARK` = `when_dark`, **`always`**, false, false, translatable `block.minecraft.bed.no_sleep` (the default of `gameplay/bed_rule`). `DESTROY_ON_LEAVE` = `when_dark`, `never`, false, **true**, translatable `block.minecraft.bed.no_sleep` (the default of `gameplay/straw_bed_rule`). `DESTROY_ON_USE` = `never`, `never`, **true**, false, no error message (not the default of an attribute). The two enum tests in `BedRule$Rule` are `always` true, `never` false, `when_dark` evaluated against the level (body not read; 33) |
| AmbientParticle | `particle` (particle options, Req); `probability` (Float in `[0, 1]` inclusive, Req: `Codec.floatRange(0, 1)` in `AmbientParticle`) | per-tick spawn probability |
| AmbientSounds | `loop` (SoundEvent, Opt); `mood` (AmbientMoodSettings, Opt); `additions` (compact list of AmbientAdditionsSettings, Opt, default empty) | |
| AmbientMoodSettings | `sound` (SoundEvent), `tick_delay` (Int), `block_search_extent` (Int), `offset` (Double); all Req | |
| AmbientAdditionsSettings | `sound` (SoundEvent), `tick_chance` (Double); both Req | |
| BackgroundMusic | `default`, `creative`, `underwater` (each a `Music` object, each Opt) | `Music` (`Music.CODEC`): `sound` (SoundEvent, Id-or-inline, Req), `min_delay` (non-negative Int, Req), `max_delay` (non-negative Int, Req), `replace_current_music` (boolean, Opt, default `false`). No check that `max_delay >= min_delay` was found in the class |

### 8.8 EnvironmentAttributeMap

`EnvironmentAttributeMap.CODEC` is a JSON/NBT **object** whose keys are attribute ids (an Identifier of the
`environment_attribute` registry: `minecraft:visual/fog_color` or `visual/fog_color`) and whose value codec is chosen **by the
key** (the attribute's entry codec of 8.4: a plain value or `{modifier, argument}`) (`Codec.dispatchedMap`). Variants:

| Codec | Used by | Rule |
|---|---|---|
| `CODEC` | `dimension_type` (`attributes` field, DIRECT) and timelines | any attribute |
| `CODEC_ONLY_POSITIONAL` | `worldgen/biome` (DIRECT) | rejects the map when it contains an attribute with `positional = false`; the error text is "The following attributes cannot be positional: <list>", listing the non-positional attributes found (the message wording is the artifact's; the rule is that a non-positional attribute is rejected) |
| `NETWORK_CODEC` | the network codecs of `dimension_type` and `worldgen/biome` | `CODEC` composed with `filterSyncable`: entries whose attribute is not syncable are removed when encoding **and** when decoding |

Therefore a server that serializes a biome with the network codec drops every non-syncable attribute from the packet
(the vanilla client does not need them: `gameplay/natural_mob_spawns` is not synced, so spawn data stays on the server),
and a biome file (DIRECT codec) that sets `gameplay/sky_light_level` or `gameplay/fast_lava` fails to load.

Constructed test vector (the colours and the file are invented, not read from the artifact). In a biome file:

```
"attributes": {
  "minecraft:visual/fog_color": "#c0d8ff",
  "minecraft:visual/water_fog_color": { "modifier": "multiply", "argument": "#80a0ff" },
  "minecraft:gameplay/bees_stay_in_hive": true
}
```

decodes to: `fog_color` override with colour `(0xc0, 0xd8, 0xff)/255`; `water_fog_color` multiply by `(0x80, 0xa0, 0xff)/255`
(each channel of the subject times the argument); `bees_stay_in_hive` override true. Sent with the network codec the third
entry is dropped (not syncable); the first two are kept. In a biome file, `"minecraft:gameplay/fast_lava": true` fails:
the attribute is not positional.

## 9. Notes on the synchronized registries (additions to 04 §6)

04 §6 tabulates the schemas of all 32 synchronized registries. This section records what the reading for RS3 added,
confirmed or resolved.

### 9.1 Network codec versus loading codec of the variants and the biome

- The `*_variant` registries are **loaded** from the data pack with their `DIRECT_CODEC`, which has all the fields of the
  network codec **plus** `spawn_conditions` (`SpawnPrioritySelectors.CODEC`, required): a list of `{condition?, priority}`
  entries, with the condition types `structure` (`structures`: a HolderSet over `worldgen/structure`), `moon_brightness`
  (`range`: a double interval) and `biome` (`biomes`: a HolderSet over `worldgen/biome`). Selection of a variant for a new
  mob uses them (19 §1). They are not sent (04 §6), so a client never sees them.
- `Biome.DIRECT_CODEC` has the same climate and `effects` fields as the network codec plus the generation settings
  (carvers, features, spawn costs) which the network codec leaves out; its `attributes` field uses
  `CODEC_ONLY_POSITIONAL` (8.8). `DimensionType.DIRECT_CODEC` uses `EnvironmentAttributeMap.CODEC`; its network twin uses the
  syncable-only form.
- `Timeline.NETWORK_CODEC` is the direct codec with non-syncable tracks removed (04 §6); the direct codec's validation
  (section 9.2a: marker ticks in `[0, period)`, keyframe ticks in `[0, period]`, tracks' own checks) applies on both sides.

### 9.2 Timeline registry-level validation (resolves 04 Open question 8)

The timeline registry is the only one in `WORLD_REGISTRIES` with a custom registry validator (`Timeline.validateRegistry`);
the `SYNCHRONIZED_REGISTRIES` entry for `timeline` has no validator, so the check runs on a **server** load and not on the
client's network load. The check: for every timeline, take its `clock` (a `world_clock` holder) and the set of **time
marker names** it defines; across **all** timelines, a marker name may be defined at most once **per clock**. A second
definition is not a data error of the registry: `Timeline.validateRegistry` walks the registry elements in registry iteration
order (id order), keeps a multimap clock -> marker names, and when adding a marker to a clock's set finds it already present
it puts an `IllegalStateException` into the shared error map (resource key -> exception) under the **key of the offending
(second) timeline's element**, with the message "<marker key> was defined multiple times in <registered name>" (text
`"%s was defined multiple times in %s"`, the registered name coming from `Holder.getRegisteredName` of the holder being
visited). A third definition gives a further exception under the third timeline's key. The message
"Timeline has no track for <...>" exists in the same class but belongs to run-time look-ups of a track, not to loading.

`clock` in a timeline is an **Id ref** into `world_clock` (no inline form, no tag). `period_ticks` is a positive Int.
Time-marker keys are `ClockTimeMarker.KEY_CODEC` identifiers.

### 9.2a Timeline codec checks (read from `Timeline`, `AttributeTrack`, `KeyframeTrack`, `Keyframe`)

Timeline record fields (`Timeline.CODEC`, field order): `clock` (Id ref into `world_clock`, Req), `period_ticks` (`POSITIVE_INT`, Opt, absent by default), `tracks` (map attribute id to track, Opt, default empty; the track codec is chosen by the attribute, section 8.4), `time_markers` (map of `ClockTimeMarker` key to `{ticks, show_in_commands}`, Opt, default empty; `TimeMarkerInfo` fields `ticks` Int, `show_in_commands` boolean). The whole-timeline check `validateInternal` runs **after** the record decodes and only when `period_ticks` is present (with no period it returns the timeline unchanged, so markers and keyframes are then unbounded):

| # | Check | Message (constants of the named class) |
|---|---|---|
| 1 | For each time marker, in the map's iteration order: `0 <= ticks < period_ticks`; the first failure ends validation | "Time Marker <marker key> must be in range [0; <period_ticks>)" (`Timeline`; the closing bracket is a parenthesis: upper bound exclusive) |
| 2 | For each track, `KeyframeTrack.validatePeriod`: every keyframe has `0 <= ticks <= period_ticks` (upper bound **inclusive**); results of the tracks are combined with `apply2stable` | "Keyframe at tick <ticks> must be in range [0; <period_ticks>]" (`KeyframeTrack`) |

Track codec (`AttributeTrack` plus `KeyframeTrack.mapCodec`): `modifier` (Opt; the modifier operation, `override` when absent is **recalled, not verified**: the default was not traced), then the argument track fields `keyframes` (list of `{ticks: Int, value}`, Req) and `ease` (`EasingType`, Opt, default `linear`). `KeyframeTrack.validateKeyframes` checks, in this order: the list is not empty ("Keyframes must not be empty"); the keyframes are in non-decreasing order of `ticks` ("Keyframes must be ordered by ticks field"); no more than two keyframes share one tick ("More than 2 keyframes on same tick: <keyframe>"; exactly how runs of equal ticks are counted was inferred from a loop over the sorted list, so treat it as "three or more at the same tick fails"). A run-time sampler of an empty track reports "Track has no keyframes" (not a load error). Non-syncable tracks are removed from the network form (`filterSyncableTracks`, 9.1). The set of easing type ids, the semantics of two keyframes on one tick, and the `ClockTimeMarker` and `WorldClock` codecs were not read here (Open question 23).

### 9.3 Numeric field leniency (resolves 04 Open question 9)

For NBT input, `NbtOps.getNumberValue` accepts **any numeric tag type** (Byte, Short, Int, Long, Float, Double) and
converts it; a non-numeric tag gives the error "Not a number". `getBooleanValue` takes the number and returns `true` when
it is not zero; booleans are written as Byte 0/1. `getStringValue` accepts only String tags ("Not a string"). For JSON
input the equivalent behaviour is the library's (`JsonOps`, not in the artifact): numbers accepted as numbers;
booleans from JSON booleans; the number-as-boolean leniency was **not** verified for JSON (Open question 3).

### 9.4 Client look-ups of fixed keys

04 §3.2 item 6 lists the keys the client requires. Reading RS3 added no new required keys (the `RegistryOps` path never
requires specific keys), but the freeze rule of 3.6 makes every element or tag **named by** an element a requirement: for
example a `dimension_type` that names a `timelines` tag or a `default_clock` that is not in `world_clock` is a load
error even if no player ever visits the dimension.

### 9.5 Validation messages, ranges and defaults (confirmation pass over the registry codecs)

04 §6 tabulates the fields, defaults and ranges of every synchronized registry. RS3 re-read the codec classes for
**validation rules** (range codecs, `validate`, constructor checks, error strings). Result: 04 §6's ranges and defaults are
confirmed for the registries below, and the exact texts and the order of checks are added here.

**DimensionType** (`DimensionType` record constructor, read; applies to the direct and the network codec, which share the
record). Codec ranges first (data errors of the field): `coordinate_scale` Double in `[9.999999747378752E-6, 3.0E7]` (the
lower bound is the float nearest `1.0E-5` widened to double, which lies slightly **below** `1.0E-5`, so a scale of exactly
`1.0E-5` is accepted; the bound is the constant read in the class); `min_y` Int in `[-2032, 2031]`; `height` Int in `[16, 4064]`; `logical_height` Int in
`[0, 4064]`. Optional fields and defaults (read): `has_fixed_time` false, `skybox` `overworld`, `cardinal_light` `default`,
`attributes` the empty map, `timelines` the empty holder set, `default_clock` absent; `has_skylight`, `has_ceiling`,
`has_ender_dragon_fight`, `infiniburn`, `ambient_light` and the monster settings fields are Req.

Then the record constructor runs these checks **in this order** and throws an `IllegalStateException` on the first failure
(an exception, not a data error: for a pack file it is recorded against the element like any decode exception, section 3.1
step 2; whether the library wraps it into a data error first was not read):

| # | Condition that fails | Message |
|---|---|---|
| 1 | `height < 16` | "height has to be at least 16" |
| 2 | `min_y + height > 2032` (that is `MAX_Y + 1`) | "min_y + height cannot be higher than: 2032" |
| 3 | `logical_height > height` | "logical_height cannot be higher than height" |
| 4 | `height % 16 != 0` | "height has to be multiple of 16" |
| 5 | `min_y % 16 != 0` | "min_y has to be a multiple of 16" |

Note (read): the number in the check 2 message is not a fixed string. The constructor passes `MAX_Y + 1` as a runtime argument into the message template ("min_y + height cannot be higher than: " followed by the number), so "2032" is the formatted value with the vanilla constants; it changes if the constants change.

Examples: `min_y -64`, `height 384`, `logical_height 384` passes all five. `min_y 0`, `height 383`, `logical_height 383`
passes 1 to 3 and fails check 4. `min_y 1600`, `height 512` fails check 2 (2112 > 2032) before anything else is tested. The
numbers 16 and 2032 are the constants of section 7.3.3.

**Other registries.** The classes below were scanned for range codecs, `validate`/`flatXmap`, `checkState`, explicit
exceptions and error strings. No custom validation beyond the range codecs already listed in 04 §6 was found, and none of
them registers a registry-level validator (section 2.1):

| Registry (class) | Ranges and constraints read | Defaults read |
|---|---|---|
| `damage_type` (`DamageType`) | enums only (`scaling`, `effects`, `death_message_type`); no range on `exhaustion` | `effects` and `death_message_type` have defaults as in 04 §6 |
| `jukebox_song` (`JukeboxSong`) | `length_in_seconds` positive float (`POSITIVE_FLOAT`), `comparator_output` Int in `[0, 15]` | none |
| `instrument` (`Instrument`) | `use_duration` non-negative float, `range` positive float, `durability_damage` non-negative Int | `durability_damage` 0 |
| `painting_variant` (`PaintingVariant`) | `width` and `height` Int in `[1, 16]` | `title`, `author` absent |
| `trim_pattern` (`TrimPattern`) | none | `decal` false |
| `trim_material` (`TrimMaterial`), `banner_pattern` (`BannerPattern`), `decorated_pot_pattern` (`DecoratedPotPattern`) | none | none |
| `chat_type` (`ChatType`, `ChatTypeDecoration`) | none beyond field shapes (`translation_key`, `parameters`, `style`) | `style` default as in 04 §6 |
| `sulfur_cube_archetype` (`SulfurCubeArchetype`), `block_transformer` (`BlockTransformer`), `test_environment`, `test_instance` (`GameTestInstance`, `TestEnvironmentDefinition`) | only `NON_NEGATIVE_INT` / `POSITIVE_INT` field codecs inside nested records (explosion data, clock time, transformer data); no custom messages | as 04 §6 |
| `world_clock` (`WorldClock`) | no field, no check | n/a |

**Dialog** (`dialog` registry, `Dialog` and the `net.minecraft.server.dialog` classes; no gameplay behaviour in CobolCraft, 04
§6). Validation read: `width` fields use an Int range `[1, 1024]` (`Dialog.WIDTH_CODEC`); several record fields use
`POSITIVE_INT`; a multi-action dialog has a **non-empty** list field (inferred to be its `actions`; the field name next to the `nonEmptyList` call was not read). Checks with texts: (a) `CommonDialogData`: a
dialog with `pause` true whose `after_action` does not unpause fails with "Dialogs that pause the game must use
after_action values that unpause it after user action!" (`DialogAction.willUnpause` is false for the action; which of the three
actions `close`, `none`, `wait_for_response` unpause was not read); (b) `TextInput`: `initial` longer than `max_length` fails
with "Default text length exceeds allowed size"; (c) `NumberRangeInput$RangeInfo`: an `initial` outside the closed interval
between `start` and `end` (compared after taking the min and max of the two) fails with "Initial value <v> is outside of
range [<lo>, <hi>]"; (d) `SingleOptionInput`: more than one entry marked initial fails with "Multiple initial values" and
the `entries` list must be non-empty; (e) `ParsedTemplate` (a string with variable markers): a string that does not parse as a
template fails with "Failed to parse template <text>: <reason>", and a string codec in the same class rejects a name that
`StringTemplate.isValidVariableName` refuses with "<name> is not a valid input name" (applied to input names; the field it is
attached to was not read).

## 10. Validation section

All checks below were read from the artifact. "Fatal" = the layer load fails (section 3.5) or, for tag files, the tag
is missing (6.3).

| # | Check | Condition | Result |
|---|---|---|---|
| V1 | Identifier syntax | namespace in `[a-z0-9_.-]`, not `..`; path in `[a-z0-9_./-]`; split at the first `:` | element or field error with the messages of section 1 ("Non [a-z0-9_.-] character in namespace of identifier: ...", "Non [a-z0-9/._-] character in path of location: ...", wrapped as "Not a valid resource location: ...") |
| V2 | JSON syntax | strict JSON, whole document consumed | element error ("Did not consume the entire document.") |
| V3 | Element decode | the registry element codec accepts the value (every Req field present, ranges, enums) | element error "Failed to parse <id> from pack <pack>" (pack load), "Failed to parse value ... for key ... from server" (network) |
| V4 | Missing pack file (network, Data-less entry) | file not found in the known data source | "Failed to find resource <file> for element <id>" |
| V5 | Duplicate registry key | same key registered twice | "Adding duplicate key '<key>' to registry" |
| V6 | Unbound element reference | a key named by some element was never registered | freeze: "Unbound values in registry <r>: <keys>" |
| V7 | Unbound tag reference | a `#tag` named by some element was never bound | freeze: "Unbound tags in registry <r>: <tags>" |
| V8 | Non-empty registries | the 13 listed in 2.1 have at least one element | "Registry must be non-empty: <r>" |
| V9 | Timeline markers | unique per clock across the registry | exception recorded under the second timeline's element key: "<marker> was defined multiple times in <timeline>" (9.2) |
| V10 | Int/float provider bounds | per section 7.1 and 7.2 | "Max must be at least min, min_inclusive: a, max_inclusive: b" (`uniform`, `biased_to_bottom`, `very_biased_to_bottom` and `clamped` int providers), "Max must be larger than min: [a, b]", "Plateau can at most be the full span: [a, b]", "Value provider too low/high: ..." |
| V11 | Weighted list | weights >= 0 and total weight above 0 (an empty list and an all-zero list are the same failure); sum of weights at most 2147483647 | decode error "Weighted list must contain at least one entry with non-zero weight" for an empty or all-zero list; "Sum of weights must be <= 2147483647" on overflow (7.5). "Weighted list has no elements" is a sampling-time exception, not a decode error |
| V12 | Vertical anchor | exactly one key, value in `[-2032, 2031]` | decode error |
| V13 | Environment attribute value | within the attribute range; for the biome map, only positional attributes; modifier allowed for the type | decode errors of 8.1, 8.4, 8.8 |
| V14 | Colour string | starts with `#`, exact digit count | "Hex color must begin with #", "Hex color is wrong size, expected <n> digits but got <m>", "Invalid color value: <text>" or "Color value out of range: <text>" |
| V15 | Tag file read | opens, parses as strict JSON, `values` present and every entry decodes | file skipped and logged. A syntax or I/O failure leaves the tag undefined (if it was its only file); a decode failure leaves the tag defined as an empty tag (6.3 step A) |
| V16 | Tag references | required entries resolve | tag missing, logged; other tags unaffected |
| V17 | Dimension type bounds | `min_y` in `[-2032, 2031]`, `height` in `[16, 4064]`, `logical_height` in `[0, 4064]` (codec ranges), then the five record-constructor checks of 9.5 in their order (height at least 16, `min_y + height` at most 2032, `logical_height` at most `height`, `height` a multiple of 16, `min_y` a multiple of 16) | element error with the messages of 9.5 |
| V18 | Loot validation (reloadable layer) | the loot registries validate | problems logged; fatal ones fail the load |

Test cases for implementers (each states the input, the expected result):

1. A `minecraft:uniform` int provider with `min_inclusive` 5 and `max_inclusive` 4 fails to decode.
2. A `trapezoid` float provider `min 0 max 1 plateau 2` fails with "Plateau can at most be the full span".
3. A `weighted_list` int provider with `"distribution": []` fails with "Weighted list must contain at least one entry with
   non-zero weight"; `"distribution": [{"data": 3, "weight": 0}]` fails with the **same** message (the warning "Found 0
   weight, make sure this is intentional!" is also logged for the second); `"distribution": [{"data": 3, "weight": 1}]`
   decodes and always samples 3 with exactly one `nextInt(1)` draw consumed (7.5).
4. A biome file with `"attributes": {"minecraft:gameplay/fast_lava": true}` fails to load.
5. Two timelines on the same clock each defining the time marker `minecraft:noon` produce one **element** error (an exception, not a data error), recorded against the resource key of the second timeline in
   id order, with message "minecraft:noon was defined multiple times in <second timeline's registered name>" (marker key
   written as in 9.2).
6. A tag file with `{"values": ["minecraft:missing_block"]}` for the `block` registry (static): the tag is missing and
   the log names `minecraft:missing_block`; with `{"id": "minecraft:missing_block", "required": false}` the tag loads
   empty.
7. A `damage_type` element naming nothing else loads; a `wolf_variant` registry with no files fails with
   "Registry must be non-empty: minecraft:wolf_variant".
8. `{"modifier": "xor", "argument": true}` on a `float` attribute fails (xor is in the boolean library only).

## 11. Resolutions of 04 open questions

| 04 Open question | Resolution |
|---|---|
| 4 (unbound tag references) | 5.2: lazily created, rejected at freeze, on both pack and network paths |
| 6 (dimension Y bounds) | 7.3.3: 26 horizontal bits, 12 vertical bits, `[-2032, 2031]` |
| 7 (unexpanded sub-schemas) | int and float providers: 7.1 and 7.2; environment attribute value codecs and the syncable set: 8; block-state-provider types: 7.4 (all ten read in the fixer pass); weighted lists: 7.5; enchantment effect components: RS8; text component style, dialog action URI checks, game rule value types: not read in this round |
| 8 (timeline whole-registry validation) | 9.2 |
| 9 (numeric leniency) | 9.3 (NBT verified, JSON not) |
| 10 (client re-ordering) | 4 and 3.4: registration preserves list order on the client; this round found no later re-sorting in `NetworkRegistryLoadTask`, `RegistryLoadTask`, `freeze` (the freeze only binds values, orders error lists, and builds the component lookup) |

## Open questions

1. **Order of stacked packs outside tags.** The statement that the pack list is lowest priority first (so a later pack
   overrides) is read from `FallbackResourceManager.getResource` (iterates from the last pushed pack) and from the tag stack
   order; how `PackRepository` orders the selected packs before building the manager (and how the vanilla server places the
   world's `datapacks` folder relative to the built-in packs) was not read in this round. See 22 §8.
2. **Registry element files with a different file extension or in a non-`data` root.** Only `.json` under
   `data/<ns>/<registry path>/` was read. Other pack types (the resource-pack `assets` side) are 08 and 14.
3. **JSON leniency.** Whether JSON integers are accepted for boolean fields, whether a JSON number is accepted where an Int
   is expected when it has a fractional part, and whether a duplicate object key is an error, depend on the serialization
   library (`JsonOps`, `MapLike`), which is not in the artifact. (Recalled, not verified.)
4. **Cycle outcome.** Which tag of a required-reference cycle is the one reported missing depends on `HashMap` iteration
   order of tag ids; the dependency-sorter reading (cycle edge dropped, referencing tag then fails) is read, the resulting
   deterministic outcome per cycle is not defined.
5. **Static tag application edge cases.** `Registry.prepareTagReload`, `apply` and the bind step behind
   `TagLoader.loadTagsFromNetwork` (how a pending or received tag set replaces the existing set, what happens to tags that
   existed before and have no new file or payload entry) were not read; this document assumes the whole tag set of a static
   registry is replaced by the pending set (04 §3.3 states "replace that registry's tag set"). Searched: `TagLoader`,
   `TagNetworkSerialization` and their nested classes only.
6. **Resolved in the fixer pass (was: WeightedList selector and `WeightedListInt` ranges).** Read in 7.5 and 7.1. Residual:
   the `Weighted.codec(MapCodec)` overload's entry shape was not read (no codec in this document uses it).
7. **Block state providers, residual.** All ten types are now specified in 7.4 (fields, defaults, draw orders, comparison
   directions, the dual-noise window rule and its constants). Not read: the body of `HolderSet$Named.getRandomElement` (the
   `ListBacked` implementation was read and a tag is assumed to use it), `NormalNoise.create` and `Noise.get` themselves
   (10 §3 and 11 §4 own them), and the `BlockPredicate` types used by `rule_based` (RS19).
8. **Resolved in the fixer pass (was: `Mth.lerpInt` and `ofInteger`).** `LerpFunction.ofInteger` is a method handle to
   `Mth.lerpInt`, whose body is read in 8.5: `a + floor(t * (float)(b - a))`.
9. **Duplicate and unknown JSON fields.** Whether the record codecs reject unknown fields was not read (the usual behaviour,
   unknown map keys ignored, is **recalled, not verified**).
10. **`overlay` modifier on `mob_spawn_settings`.** The merge rule and the `MobSpawnSettings` codec fields are in 18 App A or
    RS13; they were not re-read.
11. **Colour codecs, residual.** The forms are now read (8.6). Not recorded: the exact texts of the data errors for a float
    list of the wrong length (the `VECTOR3F` and `VECTOR4F` list codecs), (the texts for an unparsable hex digit string and for a hex
    value outside its range are now read: 8.6), and
    whether an upper-case digit string is accepted (the parser is `HexFormat`, library code, recalled not verified).
12. **`BedRule` and `Music`, residual.** Fields, defaults and the three `BedRule` constants are read (8.7). Not read: the
    level-dependent test behind `BedRule$Rule.when_dark` (33 owns run-time use), and whether any check relates `max_delay` to
    `min_delay` in `Music` (none found in the class).
13. **Registry data of the non-synchronized WORLD registries** (carver, feature, structure, noise settings, trial spawner,
    villager trade, trade set, enchantment provider, multi-noise parameter list, world preset, flat level preset) is
    specified by the documents named in the table of 2.1, several of which do not exist yet.
14. **Loot validation (V18).** Which loot problems are fatal was not read (`ProblemReporter$Collector.hasFatalProblems`);
    RS6 owns it.
15. **Client crash handling.** As in 04 Open question 3, whether the client disconnects with a message or terminates after the
    registry-load crash report was not read.
16. **Library behaviour of constructor exceptions.** The `DimensionType` constructor checks (9.5) throw
    `IllegalStateException`; whether `RecordCodecBuilder` turns that into a data error or lets it propagate to the loader's
    per-element exception handler was not read (the library is not in the artifact). Either way the element fails.
17. **Validation scan coverage.** The scan of 9.5 covered the classes it names. The `*_variant` and `*_sound_variant`
    registries, `enchantment` and its effect components (RS8), the track checks of `timeline` other than the marker checks
    of 9.2, and the nested records of `test_environment` and `test_instance` were not searched for error strings beyond what
    04 §6 already tabulates.
18. **Resolved (was: where the error text "Found direct holder ... value in tag ..." came from).** It is a String constant of
    `net.minecraft.core.MappedRegistry` (with "Can't create named set ... from outside registry" and "Invalid method used for tag
    loading"), used by the bind-time member check of 3.6; `TagNetworkSerialization` only has "Can't serialize unregistered
    value". Residual: the caller chain was read only down to `refreshTagsInHolders`, and where "Invalid method used for tag
    loading" is thrown was not traced. No tag file or Update Tags payload can produce a direct holder (both resolve to
    reference holders), so the check is believed to guard code-built tags only (inferred).
19. **`Direction` enum order.** The draw of `rotated` indexes `Direction.VALUES`, assigned from `Direction.values()`; the
    declaration order `down, up, north, south, west, east` was read from the static initialiser's constant order (the
    sorted-by-id arrays also present in the class are other fields), and `Util.getRandom(array, r)` is one `nextInt(length)`.
20. **Lowercase-hex encoding claim (8.6).** The statement that the hex text form is lowercase depends on `HexFormat`, which is JDK
    code and not in the artifact; it is **recalled, not verified**.
21. **Sections not exhaustively re-verified.** A later review checked the provider and DimensionType messages (7.1, 7.2, 9.5)
    against the class constants but did not exhaustively re-verify 7.4 (block state provider semantics), the dialog validation
    texts in 9.5. The network-load message texts of section 4 and the HolderSet and id-reference codec strings of 5.1 were later
    matched against the constant pools (`RegistryLoadTask$PendingRegistration`; `HolderSetCodec`, `RegistryFixedCodec`) and are
    verified. A later reviewer should spot-check the rest.
22. **`realms` namespace and the path-resolution guard.** `Identifier.REALMS_NAMESPACE` (`realms`) is declared but not used by
    any `Identifier` method. Searched: the constant pool and bytecode of `Identifier` only; no other class was searched for a
    special case of that namespace, and the callers of `Identifier.resolveAgainst` (the "tried to access path" guard) were not
    traced.
23. **Timeline and track details not read.** The default of the track `modifier` field, the `EasingType` ids, the behaviour of two
    keyframes on one tick, the `ClockTimeMarker`, `WorldClock` and `Timelines` (built-in timeline data) contents, and the
    field-level validation of `biome` (beyond 04 §6, 8.8 and 9.1) and of the `spawn_conditions` priority selector (the priority
    value range and ordering rule) were not read in this round. Searched: string constants of `Timeline`, `Timeline$TimeMarkerInfo`,
    `AttributeTrack`, `KeyframeTrack`, `Keyframe`.
