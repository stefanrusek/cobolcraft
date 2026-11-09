# 08 Resource packs

This document specifies the resource pack *format* that the 26.3 client reads (resource pack version
**97.1**), and how server-pushed packs flow on the wire. Our game reads the same format so that
creators can use existing tooling. The game has two world types (1.6). The built-in pack, which belongs to
the cobolcraft world type, targets our own `cobolcraft:` namespace (section 10). The resource pack of the
standard world type is not written by hand. A tool generates it at run time from the user's own client jar
and it uses the `minecraft:` namespace. User packs written for the standard client, such as Faithful, use
`minecraft:` too. Nothing is committed, bundled or listed in these documents: no vanilla textures, models or
sounds appear here. The tool reads the jar on the user's machine and writes into the user's game directory
only.

A few identifiers in the `minecraft:` namespace are **engine vocabulary**: names that the client code
hard-wires, such as the atlas definition ids, the built-in item-model generator and the dispatch type
ids. They are marked **[engine name]** and appear here only because a pack has to use them.

Sources (bytecode): `net.minecraft.server.packs.*` (`PackType`, `PackResources`, `PathPackResources`,
`FilePackResources`, `OverlayedPackResources`, `OverlayMetadataSection`, `FeatureFlagsMetadataSection`,
`DownloadQueue`, `DownloadCacheCleaner`), `net.minecraft.server.packs.metadata.pack.*` (`PackMetadataSection`,
`PackFormat`, `PackFormat$IntermediaryFormat`), `net.minecraft.server.packs.repository.*` (`Pack`,
`Pack$Position`, `PackRepository`, `PackCompatibility`, `FolderRepositorySource`, `PackDetector`),
`net.minecraft.server.packs.resources.*` (`FallbackResourceManager`, `MultiPackResourceManager`,
`ResourceFilterSection`), `net.minecraft.util.IdentifierPattern`, `net.minecraft.util.FileUtil`,
`net.minecraft.resources.Identifier`, `net.minecraft.client.renderer.block.dispatch.*` (block state
files), `net.minecraft.client.resources.model.cuboid.*` (model files), `net.minecraft.client.resources.model.sprite.*`,
`net.minecraft.client.resources.model.*` (`ModelManager`, `BlockStateModelLoader`, `ClientItemInfoLoader`,
`ModelDiscovery`, `ResolvedModel`, `SimpleModelWrapper`), `net.minecraft.client.renderer.item.*` (item
model definitions), `net.minecraft.client.renderer.texture.*` and `...texture.atlas.*` (atlases, sprites),
`net.minecraft.client.resources.metadata.*` (texture `.mcmeta` sections), `net.minecraft.client.resources.server.*`
(`DownloadedPackSource`, `ServerPackManager`), `net.minecraft.client.multiplayer.ClientCommonPacketListenerImpl`,
`net.minecraft.util.HttpUtil`, and `version.json` in the client artifact.

The `com.mojang.math` classes (`Quadrant`, `Transformation`) were extracted and read in a second pass. The
serialization library (`com.mojang.serialization`, DFU) is a separate library and is not in the jar.

---

## 1. Pack container

### 1.1 Zip or folder

A pack is either a **directory** or a **zip archive**. In the user's pack folder, an entry counts as a
pack if it is a directory that contains `pack.mcmeta`, or a regular file whose name ends in `.zip`
(`PackDetector`). Other entries are skipped with a log line. Server-pushed packs are always zip files
(section 9).

Inside a zip, paths use `/` as the separator. The resource for identifier `ns:path` of a client pack is
the entry `assets/ns/path` (`FilePackResources.getPathFromLocation`: the format is type directory, then
namespace, then path).

### 1.2 Root layout

| Path (relative to pack root) | Required | Purpose |
|---|---|---|
| `pack.mcmeta` | **yes** | Pack metadata (section 2). Without it the pack is rejected ("Missing metadata in pack"). |
| `pack.png` | no | Icon in the pack selection screen. Read as an image; if it is unreadable the screen falls back to a placeholder icon. No size check was found. |
| `assets/<namespace>/...` | no | Client resources (the `CLIENT_RESOURCES` pack type uses the directory name `assets`). |
| `data/<namespace>/...` | no | Server data (the `SERVER_DATA` pack type, directory `data`). Ignored when the pack is used as a resource pack. |
| `<overlay directory>/assets/...` | no | Overlay content (section 1.5). |

### 1.3 Namespace rules

A namespace is the name of a directory directly under `assets/`. When a pack lists its namespaces, every
directory name is checked with `Identifier.isValidNamespace`. A name with any character outside the set
below is logged ("Non [a-z0-9_.-] character in namespace … ignoring") and **the whole namespace is
ignored**. A non-directory entry where a namespace directory is expected is also rejected.

| Part | Allowed characters |
|---|---|
| Namespace | `a`–`z`, `0`–`9`, `_`, `-`, `.` |
| Path | `a`–`z`, `0`–`9`, `_`, `-`, `.`, `/` |

Identifier text is `namespace:path`. When the namespace and colon are left out, the namespace is
`minecraft`. **Every reference inside a `cobolcraft` pack must therefore spell out `cobolcraft:`.** A
bare `block/greystone` means `minecraft:block/greystone`. A reference inside the generated vanilla pack or
inside Faithful uses bare or `minecraft:` ids (1.6).

### 1.4 Path rules

Resource paths are split on `/`, and each segment is checked (`FileUtil.decomposePath`,
`FileUtil.isValidPathSegment`):

| Rule | Result if broken |
|---|---|
| No empty segment (no leading `/`, trailing `/` or `//`) | Path rejected ("Invalid path in pack … ignoring"). |
| No segment equal to `.` or `..` | Rejected. |
| Each segment uses only `a`–`z`, `0`–`9`, `-`, `.`, `_` | Rejected. |
| Upper-case letters | Not allowed anywhere. File names in a pack must be lower case. |

Directory listings (used for atlas `directory` sources, the model and item-definition scans, and so on)
skip files whose names fail these checks. A file named `.ds_store` is ignored in folder packs.

### 1.5 Overlays

An overlay is an extra directory at the pack root, laid out like the root itself (`<dir>/assets/<ns>/…`).
It is switched on only when its declared format range includes the running version (97.1). Overlays are
declared in `pack.mcmeta` (section 2.4).

Lookup order inside one pack (`OverlayedPackResources`): the **active overlays in reverse declaration
order** come first (the last-declared overlay wins), and the pack root comes last. So a file in an active
overlay replaces the same file at the root, and a later overlay replaces an earlier one. The set of
namespaces is the union over the root and all active overlays. `pack.mcmeta` and `pack.png` are always
read from the root.

Overlay directory names must match the regular expression `[-_a-zA-Z0-9.]+`. Any other name is a parse
error for the `overlays` section ("is not accepted directory name").

### 1.6 Namespaces and world types

The game has two **world types**. The **standard** world type is Minecraft 26.3 content, built from the
vanilla resource pack and data pack that the extraction tool generates from the user's jar, plus the engines
that the documents 10 to 21 specify. The **cobolcraft** world type is the invented `cobolcraft:` content of
[../design/standin-content.md](../design/standin-content.md), which runs with no jar and no generated pack.

**Namespace rule.**

| World type | Namespace use |
|---|---|
| Standard | `minecraft:` for everything: registry keys, texture and model paths, language keys, tags, dimension keys. Packs written for it, such as Faithful, apply directly by path. |
| Cobolcraft | `cobolcraft:` for its own content. `minecraft:` for protocol vocabulary (the **[engine name]** ids of this document and the registry slot names of 04) and for the standard entries that the shared gameplay rules need. |

`cobolcraft:` is the place where CobolCraft extends or diverges from Minecraft. Anything with a vanilla
equivalent uses `minecraft:`.

**Shared rules.** Gameplay rules are the standard rules of the documents 10 to 21 in both world types:
health, hunger, damage, the hurt window, day length, movement, commands, the crafting grids, ground items and
the like. Where the standard behaviour and the stand-in content differ on a rule, the standard rule applies in
both world types. The world type selects the content set (blocks, items, mobs, recipes, biomes, dimensions and
textures) and nothing else.

The pack order for both world types is in 3.1 and section 10.

---

## 2. `pack.mcmeta`

`pack.mcmeta` is a JSON object. Each top-level key is a **metadata section**. Each section is decoded only
when the client asks for it, so unknown top-level keys are ignored (inferred: no code was found that
rejects extra keys).

| Section key | Required | Content |
|---|---|---|
| `pack` | **yes** | Description and supported format range (2.1–2.3). |
| `overlays` | no | Overlay declarations (2.4). |
| `filter` | no | Resources this pack hides in lower packs (section 3.3). |
| `language` | no | Extra languages this pack provides (2.5). |
| `features` | no | Feature flags the pack needs (2.6). Mainly for data packs. |

### 2.1 Version numbers

A **pack format** is a pair `major.minor` of non-negative integers (`PackFormat`). Formats compare by major,
then minor. The 26.3 client's own resource version is **97.1**, and its data version is 121.0 (from
`version.json`: `resource_major` 97, `resource_minor` 1).

In JSON, a single format value (used by `min_format` and `max_format`) is written in one of two ways:

| Form | Meaning for `min_format` | Meaning for `max_format` |
|---|---|---|
| Integer `N` | `N.0` | `N.*` (any minor; internally minor = 2147483647) |
| Array `[N]` | `N.0` | `N.*` |
| Array `[N, M]` | `N.M` | `N.M` |

The array holds 1 to 256 non-negative integers. Only the first two are used.

### 2.2 The `pack` section

| Field | Type | Required | Notes |
|---|---|---|---|
| `description` | Text component (JSON text: a string, an object or an array) | **yes** | Shown in the pack list. |
| `min_format` | Format (2.1) | see 2.3 | Lowest supported format. |
| `max_format` | Format (2.1) | see 2.3 | Highest supported format. |
| `pack_format` | Integer | see 2.3 | Legacy single major version. |
| `supported_formats` | Integer range | see 2.3 | Legacy range of majors. Written as an integer, a two-element array `[min, max]`, or an object `{min_inclusive, max_inclusive}` (inferred from the use of `ExtraCodecs.intervalCodec`). |

### 2.3 Format validation (client resource packs)

For resource packs, the "last pre-minor version" is **64** (`PackFormat.lastPreMinorVersion`: 64 for
client resources, 81 for server data). Versions newer than 64 understand `min_format`/`max_format`. Older
versions only read `pack_format`/`supported_formats`. Validation (`PackFormat$IntermediaryFormat.validate`)
works as follows:

| Case | Rule |
|---|---|
| Only one of `min_format`/`max_format` present | Error: "missing field, must declare both min_format and max_format". |
| Both present | New-style validation, rows below. |
| Neither present, `supported_formats` present | Legacy: its maximum must be ≤ 64, or the error is "declares support for version newer than 64, but is missing mandatory fields min_format and max_format". The result is the range `[min.0, max.0]`. |
| Only `pack_format` present | It must be ≤ 64 (same error otherwise). The result is that single version. |
| None of the four | Error: "could not be parsed, missing format version information". |

New-style rows (both `min_format` and `max_format` present):

| Rule | Detail |
|---|---|
| `min_format` ≤ `max_format` | Else error "min_format (…) is greater than max_format (…)". |
| `min_format` major > 64 | `supported_formats` must be absent (inferred from the message "key … is deprecated starting from pack format …. Remove … from your pack.mcmeta"). If `pack_format` is present it must lie within the declared majors (inferred). |
| `min_format` major ≤ 64 | The range also covers legacy clients, so `pack_format` is required. If `supported_formats` is present it must agree with `min_format`/`max_format` ("version declaration mismatch …"). A multi-version range may not start below 15 ("Multi-version packs cannot support minimum version of less than 15"). |

If parsing with these rules fails, the client tries a **fallback** reading that takes only `description`
and marks the pack's range as unknown (`PackMetadataSection.FALLBACK_TYPE`, a single format of major
2147483647). Such a pack is listed with compatibility "unknown".

**Compatibility** (`PackCompatibility.forVersion`), compared with the running version 97.1:

| Result | Condition |
|---|---|
| `unknown` | Range came from the fallback. |
| `too old` | `max` < 97.1. |
| `too new` | `min` > 97.1. |
| `compatible` | Otherwise. |

An incompatible pack can still be enabled locally after a confirmation prompt (the language keys
`pack.incompatible.confirm.*`).

**For our packs:** declare `min_format` 97 and `max_format` 97 (that is, 97.0 through 97.*), and nothing
else. This passes all rules above.

### 2.4 The `overlays` section

| Field | Type | Required | Notes |
|---|---|---|---|
| `entries` | Array of OverlayEntry | **yes** | In declaration order. |

OverlayEntry:

| Field | Type | Required | Notes |
|---|---|---|---|
| `directory` | String | **yes** | Matches `[-_a-zA-Z0-9.]+`. |
| `min_format`, `max_format` | Format | conditional | As in 2.3. |
| `formats` | Integer range | conditional | Legacy range. It plays the role that `supported_formats` plays in 2.3. |

The rules in 2.3 apply to each entry. An entry with none of `min_format`, `max_format` or `formats` is
skipped with the warning "Unknown or broken overlay entry". If the lowest declared minimum across all
entries is at or below 64, every entry must carry `formats` ("missing required field formats, must be
present in all overlays …"). An entry is active when its range contains 97.1.

### 2.5 The `language` section

A JSON object that maps a **language code** (a string of 1 to 16 characters) to a LanguageInfo:

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | Non-empty string | **yes** | Display name. |
| `region` | Non-empty string | **yes** | Display region. |
| `bidirectional` | Boolean | no (false) | Right-to-left text. |

The built-in language `en_us` always exists.

### 2.6 The `features` section

| Field | Type | Required | Notes |
|---|---|---|---|
| `enabled` | Array of Identifier | **yes** | Feature flags this pack requests. |

Not needed for our packs.

---

## 3. Stacking

### 3.1 Pack order

The client keeps an ordered list of selected packs. **The list runs from lowest to highest priority: a
pack later in the list overrides an earlier one.** Each pack has a selection config (required, default
position, fixed position) (`PackSelectionConfig`, `Pack$Position`).

Inserting a pack (`Pack$Position.insert`):

| Position | Behaviour |
|---|---|
| `TOP` | Inserted at the top, but below any existing packs that are themselves fixed at `TOP`. |
| `BOTTOM` | Inserted at the bottom, but above any existing packs that are themselves fixed at `BOTTOM`. |

On every rebuild, required packs missing from the selection are added at their default position
(`PackRepository.rebuildSelected`). Available packs are discovered into a map sorted by pack id, so
required packs are added in pack-id order.

Typical resulting order, bottom to top: the built-in default pack (required, fixed `BOTTOM`), then, for
a client that has generated a pack from the vanilla client files, that generated vanilla pack (the
four-layer stack and its placement are in section 10), then user-selected packs in the user's order, then server-pushed packs (required, fixed `TOP`, section 9.6).

### 3.2 Overriding

For a single-file lookup (`FallbackResourceManager.getResource`), packs are searched **from the top
down**. The first pack that contains the file supplies it. A file's `.mcmeta` companion is taken from the
**same** pack as the file (`createStackMetadataFinder`), so a pack that overrides a texture without
shipping a `.mcmeta` does not inherit the lower pack's animation.

Some asset kinds are **merged across packs** rather than replaced whole. They read the full stack of
copies from bottom to top:

| Asset kind | How packs combine |
|---|---|
| Block state files (4) | Every pack's copy is applied bottom to top. For each block state, a higher pack's assignment replaces the lower one. States the higher file does not cover keep the lower pack's model (`BlockStateModelLoader.loadBlockStateDefinitionStack`). |
| Atlas definitions (7.3) | All copies are concatenated, bottom pack first. Their sources run in that order (`SpriteSourceList.load`). |
| Language files (8) | All copies are loaded bottom to top into one map, so higher packs override individual keys (inferred from `ClientLanguage.loadFrom` iterating the resource stack). |
| Models, item definitions, textures, and most other files | Whole-file replacement: only the topmost copy is used. |

### 3.3 The `filter` section

| Field | Type | Required | Notes |
|---|---|---|---|
| `block` | Array of IdentifierPattern | **yes** | Patterns of resources to hide. |

IdentifierPattern:

| Field | Type | Required | Notes |
|---|---|---|---|
| `namespace` | Regular expression (string) | no | If absent, matches every namespace. |
| `path` | Regular expression (string) | no | If absent, matches every path. |

Matching uses Java `Pattern.asPredicate`, which is a **find** (substring) match, not a whole-string match.
Anchor with `^…$` for an exact match. A resource is filtered by a pattern when both its namespace and its
path match.

Semantics: a pack's filter hides matching resources **in all packs below it**. The pack's own files are
not affected. During a top-down lookup, once the search reaches a pack whose filter matches the resource
without having found it, the search stops and the resource counts as absent ("Resource {} not found, but
was filtered by pack {}"). For merged stacks (3.2), a filter removes the matching entries contributed by
packs below the filtering pack (`applyPackFiltersToExistingResources`). A `.mcmeta` companion is filtered
together with its file.

---

## 4. Block state files

Path: `assets/<ns>/blockstates/<block path>.json`. One file per block. The file for block `ns:name` is
`blockstates/name.json` in namespace `ns` (`BlockStateModelLoader`, directory `blockstates`).

### 4.1 Top level

| Field | Type | Required | Notes |
|---|---|---|---|
| `variants` | Object mapping VariantKey to ModelChoice | one of the two | Must be non-empty. |
| `multipart` | Array of MultipartCase | one of the two | Must be non-empty. |

If neither is present, the error is "Neither 'variants' nor 'multipart' found". Both may be present. Then
`variants` is applied first, and `multipart` only fills in states that no variant matched (`putIfAbsent`).

### 4.2 Variant keys

A VariantKey is a comma-separated list of `property=value` pairs (split on `,`, then on the first `=`)
(`VariantSelector`).

| Rule | Detail |
|---|---|
| Property names | Must be properties of the block, or the error is "Unknown blockstate property". |
| Values | Must be valid values of that property, or the error is "Unknown value … for blockstate property". |
| Properties not mentioned | Act as wildcards. A key that names fewer properties matches every state that agrees on the named ones. |
| Empty key `""` | Matches every state of the block (inferred: an empty list of constraints). |
| Order of pairs | Not significant. |
| Two keys matching one state | Error "Overlapping definition on state" (the whole file fails). |

States that match no key are left without a model by this file (they fall back to a lower pack or to
the missing model).

### 4.3 ModelChoice

A ModelChoice is **either one Variant object or a non-empty array of WeightedVariant objects**
(`BlockStateModel$Unbaked`).

Variant:

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `model` | Identifier | **yes** | — | A model id (section 5). |
| `x` | Quadrant | no | 0 | Rotation of the whole model about X, in degrees. |
| `y` | Quadrant | no | 0 | Rotation about Y. |
| `z` | Quadrant | no | 0 | Rotation about Z. **New in this format version.** |
| `uvlock` | Boolean | no | false | Keeps texture orientation fixed in world space while the model rotates. |

A Quadrant is a quarter-turn angle. `Quadrant.parseJson` takes the integer modulo 360 (always non-negative), so
−90 and 450 are accepted and mean 270 and 90. The result must be 0, 90, 180 or 270; anything else is a parse error. The three rotations are combined into one of the 24 cube orientations
(`Quadrant.fromXYZAngles`, then `BlockModelRotation`).

WeightedVariant is a Variant plus:

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `weight` | Positive integer | no | 1 | Relative probability. |

When the array has several entries, one of them is chosen at random per block with probability
weight / total weight (`WeightedList.getRandomOrThrow`). The random source is seeded per block position by
the renderer (inferred). A one-element array behaves like a single Variant.

### 4.4 Multipart

MultipartCase:

| Field | Type | Required | Notes |
|---|---|---|---|
| `when` | Condition | no | If absent, the case always applies. |
| `apply` | ModelChoice | **yes** | Same as 4.3. |

For each state, **every** case whose condition holds contributes its model. The block's model is the union
of all contributing parts. When several weighted lists apply, each list makes its own random pick
(`MultiPartModel`).

A Condition is one of two kinds (`multipart.Condition`):

| Kind | Shape | Meaning |
|---|---|---|
| Combined | An object with **exactly one** key, `AND` or `OR`, whose value is an array of Conditions | `AND`: all sub-conditions hold. `OR`: at least one holds. Any other map size is an error ("expected exactly one element"). Conditions nest. |
| Key-value | A non-empty object mapping property name to TermList | All listed properties must match. |

A TermList is a string, or an integer or boolean that is read as its string form. It is split on `|` into
terms. A term `v` matches when the property equals `v`. A term `!v` matches when the property does **not**
equal `v`. The property matches if **any** term matches (`KeyValueCondition$Terms`). An empty term or an
empty value is an error. An unknown property or value is an error naming the block. A condition that is
always true or always false is accepted with a warning.

---

## 5. Model files

Path: `assets/<ns>/models/<path>.json`. Model id `ns:path` maps to that file (`ModelManager`, directory
`models`). By convention block models live under `block/` and item models under `item/`, but the client
does not require this.

### 5.1 Top level

| Field | Type | Required | Default if absent everywhere in the chain | Notes |
|---|---|---|---|---|
| `parent` | Identifier string | no | none | An empty string means no parent. |
| `textures` | Object mapping slot name to TextureValue | no | empty | Merged along the chain (5.3). |
| `elements` | Array of Element | no | no geometry | Taken from the nearest model in the chain that has `elements`. **Not merged.** |
| `ambientocclusion` | Boolean | no | true | |
| `display` | Object mapping DisplayContext to Transform | no | identity | Per context, the nearest model that defines that context wins. |
| `gui_light` | `"front"` or `"side"` | no | `side` | How the item is lit in GUI slots. Any other value is an error. |

Other keys are ignored (inferred).

### 5.2 Parent resolution

Starting from the model itself and walking up through `parent`, each property in the table above is taken
from the **first** model in the chain that defines it (`ResolvedModel.findTop*`). Textures are the
exception (5.3).

| Situation | Effect |
|---|---|
| Parent id names no file | "Missing block model". The missing model is used in its place. |
| Cycle in the parent chain | "Model … ignored due to cyclic dependency". The model is unusable. |
| `minecraft:builtin/generated` **[engine name]** as parent | A built-in generator with no file. It extrudes item layer textures (5.7). |
| `minecraft:builtin/missing` **[engine name]** | The built-in missing model. |

### 5.3 Textures and `#` references

A TextureValue is one of:

| Form | Meaning |
|---|---|
| String starting with `#` | A reference to another slot, by name (without the `#`). |
| Other string | A sprite id in an atlas. The default namespace is `minecraft`. The sprite id `ns:block/foo` is the texture file `assets/ns/textures/block/foo.png` (7.3). |
| Object `{ "sprite": Identifier, "force_translucent": Boolean }` | A sprite id. With `force_translucent` (default false), faces using it are always drawn in the translucent layer (`Material`). |

Resolution (`TextureSlots$Resolver`): slot maps from the root of the chain down to the model itself are
layered so that **child entries replace parent entries with the same slot name**. References are then
followed until they reach a sprite. A reference that never reaches one is logged ("Unresolved texture
references") and the face renders with the missing texture. The slot `particle` supplies the
block-breaking particle sprite.

A block model may use sprites from the **block atlas only**. Otherwise the model is rejected ("Rejecting
block model …, since it contains sprites from outside of supported atlas"). An item model must use one
atlas only, and that atlas must be the block atlas or the item atlas (`CuboidItemModelWrapper`).

The render layer for a face (opaque, cutout or translucent) is not declared in the model. It comes from the
pixels of the sprite area the face actually uses (fully opaque, contains alpha 0 only, or contains partial
alpha), unless `force_translucent` is set (`BakedQuad$MaterialInfo`, `SpriteContents.computeTransparency`).

### 5.4 Element

Coordinates are in sixteenths of a block. 0–16 spans one block.

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `from` | Array of 3 numbers | **yes** | — | Minimum corner. Each component must lie in −16 … 32 ("specifier exceeds the allowed boundaries"). |
| `to` | Array of 3 numbers | **yes** | — | Maximum corner, same bounds. |
| `faces` | Object mapping Direction to Face | **yes** | — | 1 to 6 entries. Direction names are `down`, `up`, `north`, `south`, `west`, `east`. An unknown name is an error. |
| `rotation` | ElementRotation | no | none | |
| `shade_direction_override` | Direction name | no | none | Faces are shaded as if they faced this direction (inferred from the name). The older `shade` boolean is **not read** in this version. |
| `light_emission` | Integer 0–15 | no | 0 | Must be an integer in range, else error. Raises the face's minimum brightness when drawn (inferred). Does not emit world light. |

ElementRotation (`CuboidModelElement$Deserializer.getRotation`):

| Field | Type | Required | Notes |
|---|---|---|---|
| `origin` | Array of 3 numbers | **yes** | Pivot point in sixteenths. |
| `axis` | `"x"`, `"y"` or `"z"` | with `angle` | Single-axis form. |
| `angle` | Number (degrees) | with `axis` | **No range check in this version.** Any angle is accepted. |
| `x`, `y`, `z` | Numbers (degrees) | alternative to `axis`/`angle` | Euler form. Each defaults to 0 once the form is chosen. Composed with JOML `rotationZYX` (inferred: the call order is z, y, x). CobolCraft's rule is in 5.4.1. |
| `rescale` | Boolean | no (false) | Scales the rotated element per axis so that it keeps spanning its original extent (inferred from `CuboidRotation.computeRescale`). CobolCraft's rule is in 5.4.1. |

If neither `axis`+`angle` nor any of `x`/`y`/`z` is present, the error is "Missing rotation value, expected
either 'axis' and 'angle' or 'x', 'y' and 'z'".

#### 5.4.1 CobolCraft's element rotation rule

This is the rule CobolCraft's renderer implements (it answers Open question 4). It is our own definition. It
was not checked against a rendered reference of the 26.3 client.

- **Model axes.** +x is east, +y is up, +z is south (so north is −z). The axes form a right-handed system.
- **Handedness.** A positive angle a about an axis turns counter-clockwise as seen from the positive end of
  that axis looking toward the origin (the right-hand rule). For a point (x, y, z) relative to the pivot:
  - about X: y′ = y·cos a − z·sin a, z′ = y·sin a + z·cos a;
  - about Y: x′ = x·cos a + z·sin a, z′ = −x·sin a + z·cos a;
  - about Z: x′ = x·cos a − y·sin a, y′ = x·sin a + y·cos a.

  For example, `axis` = `y`, `angle` = 90 turns a point on the east side (+x) to the north side (−z).
- **Pivot.** Every vertex is first made relative to `origin`, rotated, and then moved back by `origin`.
- **Single-axis form.** One rotation by `angle` about `axis`.
- **Euler form, composition order.** The vertex is rotated about X by `x` first, then about Y by `y`, then
  about Z by `z`. As a matrix for column vectors this is R = R_z(z) · R_y(y) · R_x(x), which is what JOML
  `rotationZYX(z, y, x)` builds. Each of the three rotations is about the fixed model axes, not the
  rotated ones.
- **Rescale.** In the single-axis form with `rescale` true, after rotating, the two coordinates
  perpendicular to `axis` (relative to the pivot) are multiplied by 1 / max(|cos a|, |sin a|). A 45° turn is
  therefore scaled by √2, and 0° or 90° turns are not scaled. In the Euler form, CobolCraft ignores
  `rescale`.
- **Order with other transforms.** The element rotation applies in model space. The block state Variant
  rotation (4.3) applies to the result afterwards. A face keeps its declared direction name for `cullface`
  and for shading. Both are then turned by the Variant rotation only, never by the element rotation.
- **Variant rotation (4.3), for comparison.** CobolCraft turns the whole model about the block centre
  (8, 8, 8): by `x` first, then `y`, then `z`. Each quarter turn is **clockwise** as seen from the
  positive end of its axis, so `y` = 90 turns north to east, and `x` = 90 turns up to north. 10.6 relies on
  this rule.

The built-in pack (section 10) uses no element rotation. The rule matters only for packs that do.

### 5.5 Face

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `texture` | String | **yes** | — | Usually `#slot`. |
| `uv` | Array of 4 numbers `[u1, v1, u2, v2]` | no | derived from the element bounds (5.5.1) | In sixteenths of the sprite. Exactly 4 values. |
| `cullface` | Direction name | no | none | The face is skipped when the neighbour in that direction hides it. |
| `rotation` | Integer: 0, 90, 180, 270 | no | 0 | Rotates the UV mapping. Same Quadrant rule: the value modulo 360 must be 0, 90, 180 or 270. |
| `tintindex` | Integer | no | −1 | −1 means no tint. Other values select a tint source (item tints are in 6.4. Block tints are fixed in client code). |

#### 5.5.1 CobolCraft's face UV rule

This is the rule CobolCraft's renderer implements (it answers Open question 6). It uses the axes of 5.4.1.

**Default `uv`.** With `from` = (fx, fy, fz) and `to` = (tx, ty, tz) in sixteenths, a face without `uv` gets:

| Face | u1 | v1 | u2 | v2 |
|---|---|---|---|---|
| `down` | fx | 16 − tz | tx | 16 − fz |
| `up` | fx | fz | tx | tz |
| `north` | 16 − tx | 16 − ty | 16 − fx | 16 − fy |
| `south` | fx | 16 − ty | tx | 16 − fy |
| `west` | fz | 16 − ty | tz | 16 − fy |
| `east` | 16 − tz | 16 − ty | 16 − fz | 16 − fy |

Each face thus shows the part of the sprite that lines up with the face's place in the block. A full cube
(0, 0, 0)–(16, 16, 16) gets [0, 0, 16, 16] on every face. Values outside 0–16, from bounds beyond the block,
are used as they are. The sprite does not repeat, so such faces sample outside it. Avoid them.

**Corner assignment.** Look at the face from outside its element. For the four side faces, "top" is +y.
For `up`, the top edge is north (−z) and the right edge is east. For `down`, the top edge is south (+z) and
the right edge is east. With `rotation` 0, the corners get these UVs:

| Corner | top-left | top-right | bottom-right | bottom-left |
|---|---|---|---|---|
| UV | (u1, v1) | (u2, v1) | (u2, v2) | (u1, v2) |

The values are used as given, so u1 > u2 or v1 > v2 mirrors the image. The UV (u, v) is the sprite texel
position (u / 16 × sprite width, v / 16 × sprite height).

**Face `rotation`.** A face `rotation` of r turns the image clockwise on the face by r degrees. Each
quarter turn moves every corner's UV to the next corner clockwise. With 90, for example, top-right gets
(u1, v1), bottom-right gets (u2, v1), bottom-left gets (u2, v2) and top-left gets (u1, v2).

**`uvlock`.** With `uvlock` true on a Variant (4.3), CobolCraft computes each face's UVs as if the Variant
rotation were 0. It uses the default-`uv` formula above on the element's rotated bounds, keyed by the
face's final world direction. An explicit `uv` is not changed. The built-in pack never sets `uvlock`.

### 5.6 Display transforms

DisplayContext keys (`ItemDisplayContext` serialized names, **[engine name]** vocabulary):
`thirdperson_righthand`, `thirdperson_lefthand`, `firstperson_righthand`, `firstperson_lefthand`, `head`,
`gui`, `ground`, `fixed`, `on_shelf`. A missing left-hand transform copies the right-hand one.

Transform:

| Field | Type | Default | Notes |
|---|---|---|---|
| `rotation` | Array of 3 numbers | 0, 0, 0 | Degrees. |
| `translation` | Array of 3 numbers | 0, 0, 0 | Sixteenths. Each component is clamped to −80 … 80. |
| `scale` | Array of 3 numbers | 1, 1, 1 | Each component clamped to −4 … 4. |

A Transform array must have exactly 3 elements.

### 5.7 The built-in generated model

A model whose chain reaches `minecraft:builtin/generated` **[engine name]** gets its geometry from the
generator (`ItemModelGenerator`), not from `elements`:

- Texture slots `layer0` to `layer4` are read in order, stopping at the first missing slot. Each layer
  becomes a flat front and back quad, 1/16 block thick (from z 7.5 to 8.5), plus edge quads wherever an
  opaque pixel borders a transparent one.
- Layer *n* uses tint index *n* (inferred).
- `particle` defaults to `#layer0`.
- `gui_light` defaults to `front`.

---

## 6. Item model definitions

Path: `assets/<ns>/items/<item path>.json`. One file per item. The id matches the item's registry key
(`ClientItemInfoLoader`, directory `items`). The client renders an item through this file, not through
`models/item/…` directly. Only the topmost pack's copy is used.

### 6.1 Top level

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `model` | ItemModel | **yes** | — | The root of the dispatch tree. |
| `hand_animation_on_swap` | Boolean | no | true | Plays the re-equip animation when the stack changes. |
| `oversized_in_gui` | Boolean | no | false | Lets the GUI rendering extend beyond the slot. |
| `swap_animation_scale` | Float | no | 1.0 | Speed of the swap animation. |

### 6.2 ItemModel

An ItemModel is an object with a `type` field holding an Identifier (default namespace `minecraft`). The
remaining fields depend on the type (`ItemModels`: an id-dispatched codec. The key name `type` is inferred
from the dispatch codec's default). All type ids are **[engine name]**.

| Type | Fields (required unless marked) | Meaning |
|---|---|---|
| `minecraft:model` | `model` Identifier (a model id, section 5); `transformation` (optional); `tints` (optional array of TintSource, default empty) | Renders a static model. |
| `minecraft:composite` | `models` array of ItemModel; `transformation` (optional) | Renders all listed models together. An empty list renders nothing. |
| `minecraft:condition` | `property` (a condition property id) plus that property's own fields; `on_true` ItemModel; `on_false` ItemModel; `transformation` (optional) | Two-way branch on a boolean property of the stack or context. |
| `minecraft:select` | `property` (a select property id) plus its fields; `cases` non-empty array of `{ when, model }`; `fallback` ItemModel (optional); `transformation` (optional) | Multi-way branch. `when` is a single value or a non-empty list of values. Duplicate values across cases are an error. |
| `minecraft:range_dispatch` | `property` (a numeric property id) plus its fields; `scale` Float (optional, default 1); `entries` array of `{ threshold Float, model ItemModel }`; `fallback` ItemModel (optional); `transformation` (optional) | Picks the entry with the highest threshold ≤ property × scale. Entries are sorted by threshold when loaded. |
| `minecraft:special` | `base` Identifier (a model id used for particles and transforms); `model` (a special renderer, its own `type`-dispatched object); `transformation` (optional) | Code-drawn renderers. Not needed for our packs. |
| `minecraft:empty` | none | Renders nothing. |
| `minecraft:bundle/selected_item` | none | Renders the item selected inside a bundle-like container. |

`transformation` is decoded by `Transformation.EXTENDED_CODEC`. It accepts either an object with the keys
`translation`, `left_rotation`, `scale` and `right_rotation`, which are composed as translation × left rotation ×
scale × right rotation, or alternatively a raw 4×4 matrix (`ExtraCodecs.MATRIX4F`, 16 floats). The accepted
encodings of each rotation value (quaternion array or axis-angle object) live in `ExtraCodecs` and were not
expanded here.

### 6.3 Property ids (names only)

These are **[engine name]** dispatch keys. Each reads client-side state. Their extra fields are out of
scope here.

| Used by | Property ids |
|---|---|
| `condition` | `custom_model_data`, `using_item`, `broken`, `damaged`, `fishing_rod/cast`, `has_component`, `bundle/has_selected_item`, `selected`, `carried`, `extended_view`, `keybind_down`, `view_entity`, `component` |
| `select` | `custom_model_data`, `main_hand`, `charge_type`, `trim_material`, `block_state`, `display_context`, `local_time`, `context_entity_type`, `context_dimension`, `component` |
| `range_dispatch` | `custom_model_data`, `bundle/fullness`, `damage`, `cooldown`, `time`, `compass`, `crossbow/pull`, `use_cycle`, `use_duration`, `count` |

### 6.4 Tint sources

`tints[i]` supplies the colour for faces with `tintindex` *i*. TintSource is `type`-dispatched. The type ids
are `constant` (field `value`), `dye`, `grass`, `firework`, `potion`, `team` and `custom_model_data`
(`ItemTintSources`). The built-in pack needs none.

---

## 7. Textures

### 7.1 Files

Textures are PNG files under `assets/<ns>/textures/`. The client decodes them into RGBA images
(`NativeImage.read`). An unreadable image is replaced with the missing texture ("Using missing texture,
unable to load"). Dimensions need not be powers of two. However, the smallest power of two that divides a
sprite's width and height limits the mipmap levels of the whole atlas ("limits mip level from … to …"),
so 16 × 16 or other power-of-two sizes are recommended. The maximum atlas size is the GPU limit.
Which PNG kinds occur in the client jar and in the Faithful pack (colour types, depths, Adam7, 16-bit, several `IDAT`
chunks, ancillary chunks), what a decoder must support, what the Java-side reader rejects and what an unreadable file
does are in 22 §2.8.1.

### 7.2 Atlases

Sprites used by models are packed into **atlases**. The set of atlases is fixed by the client
(`AtlasManager`): there are twelve, each with a definition id. The standard client uses all twelve. Their
shipped sources and sprite ids are in 14 §3.1.

| Atlas | Definition file **[engine name]** | Used by |
|---|---|---|
| Block atlas | `assets/minecraft/atlases/blocks.json` | All block models. Item models may also use it. Break-stage overlays and a few block-entity pieces. |
| Item atlas | `assets/minecraft/atlases/items.json` | Item models. |
| GUI atlas | `assets/minecraft/atlases/gui.json` | Every GUI sprite and the status effect icons. |
| Celestials | `assets/minecraft/atlases/celestials.json` | Sun, moon phases and the End flash. |
| Particles | `assets/minecraft/atlases/particles.json` | Particles. |
| Map decorations | `assets/minecraft/atlases/map_decorations.json` | Map icons. |
| Paintings | `assets/minecraft/atlases/paintings.json` | Paintings. |
| Chests | `assets/minecraft/atlases/chests.json` | Chest block entities. |
| Banner patterns | `assets/minecraft/atlases/banner_patterns.json` | Banners. |
| Shield patterns | `assets/minecraft/atlases/shield_patterns.json` | Shields. |
| Shulker boxes | `assets/minecraft/atlases/shulker_boxes.json` | Shulker boxes. |
| Decorated pot | `assets/minecraft/atlases/decorated_pot.json` | Decorated pots. |

The generated vanilla pack carries the definitions of all twelve. The built-in pack carries the definitions
of the atlases that the sprites of the cobolcraft world type need (10.2). Definitions merge across packs
(7.3), so both can be present.

A sprite id that appears in two atlases produces a warning ("Duplicate sprite … This will be rejected in
a future version").

### 7.3 Atlas definition files

Path: `assets/<ns>/atlases/<atlas>.json` (`SpriteSourceList`, directory `atlases`). **Definitions are
merged across all packs** (3.2): every pack's copy is parsed, and their source lists are concatenated
from the bottom pack upwards. A pack therefore *adds* sprites by shipping a definition with only its own
sources. The generated vanilla pack holds the shipped sources of each atlas (14 §3.1). The built-in pack
holds only the sources for its own `cobolcraft:` sprites (10.2).

Top level:

| Field | Type | Required | Notes |
|---|---|---|---|
| `sources` | Array of SpriteSource | **yes** | Run in order. Each source adds sprites to, or removes sprites from, a working map from sprite id to image. A later add with the same id replaces the earlier one. |

SpriteSource is `type`-dispatched (`SpriteSources`). Type ids are **[engine name]**. The default namespace is
`minecraft`.

| Type | Fields | Effect |
|---|---|---|
| `directory` | `source` String (required); `prefix` String (required) | Lists every `textures/<source>/…/*.png` **in every namespace**. Each file `ns:textures/<source>/<rest>.png` becomes sprite `ns:<prefix><rest>`. |
| `single` | `resource` Identifier (required); `sprite` Identifier (optional, defaults to `resource`) | Adds one sprite from `textures/<resource>.png`. A missing file is logged ("Missing sprite"). |
| `filter` | `pattern` IdentifierPattern (3.3) (required) | Removes every sprite added so far whose id matches. |
| `unstitch` | `resource` Identifier (required); `regions` non-empty array of Region; `divisor_x` Double (optional, default 1); `divisor_y` Double (optional, default 1) | Cuts named sprites out of one larger image. Region: `sprite` Identifier, `x`, `y`, `width`, `height` (Doubles, in units of image size ÷ divisor). |
| `paletted_permutations` | `textures` array of Identifier; `palette_key` Identifier; `permutations` object mapping suffix to palette-image Identifier; `separator` String (optional, default `_`) | Recolours each listed texture once per permutation. The new sprite id is the texture id + separator + suffix. Palettes are images under `textures/palettes/` (inferred from `Palette.ID_CONVERTER`, directory `textures/palettes`). |

### 7.4 Texture `.mcmeta`

A texture `foo.png` may have a companion `foo.png.mcmeta` (same directory, from the same pack). It is a
JSON object of sections.

**`animation`** (`AnimationMetadataSection`):

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `frametime` | Positive integer | no | 1 | Default ticks per frame. |
| `frames` | Array of Frame | no | every frame in order | |
| `width` | Positive integer | no | see below | Frame width in pixels. |
| `height` | Positive integer | no | see below | Frame height. |
| `interpolate` | Boolean | no | false | Blends between frames. |

Frame size: if both `width` and `height` are given, they are used. If only one is given, the other is the
full image dimension. If neither is given, frames are square with side min(image width, image height). The
image width and height must be exact multiples of the frame size, or the texture becomes the missing
texture ("is not multiple of frame size"). Frames are numbered left to right, then top to bottom
(inferred).

A Frame is either a non-negative integer (a frame index) or an object `{ index: non-negative int (required),
time: positive int (optional, defaults to frametime) }`. An invalid index or duration is logged per frame,
and unused frames are reported.

**`texture`** (`TextureMetadataSection`):

| Field | Type | Default | Notes |
|---|---|---|---|
| `blur` | Boolean | false | Linear filtering. |
| `clamp` | Boolean | false | Clamp instead of repeat. |
| `mipmap_strategy` | `auto`, `mean`, `cutout`, `strict_cutout`, `dark_cutout` | `auto` | How mip levels are built. |
| `alpha_cutoff_bias` | Float | 0 | Adjusts the alpha threshold for cutout mipmaps. |

**`gui`** (`GuiMetadataSection`, for GUI sprites):

| Field | Type | Default | Notes |
|---|---|---|---|
| `scaling` | GuiSpriteScaling | `stretch` | `type`-dispatched: `stretch` (no fields); `tile` (`width`, `height` positive ints, required); `nine_slice` (`width`, `height` positive ints; `border` = either one positive int for all sides, or `{left, top, right, bottom}` non-negative ints; `stretch_inner` Boolean default false). A nine-slice border must leave a non-empty centre in both directions. |

Two further texture sections exist for code-defined uses: `villager` (field `hat`) and `palette` (field
`base_palette`). They are not needed for our packs.

---

## 8. Other asset kinds

All paths are under `assets/<ns>/`. The last column says whether CobolCraft's client reads the kind. The
built-in pack (section 10) ships every kind marked **read**, except the colormaps, which the generated
vanilla pack carries (Faithful has none).

| Path | Purpose | CobolCraft client |
|---|---|---|
| `blockstates/<block>.json` | State → model mapping (4). | **read** (10.6) |
| `models/**/<name>.json` | Geometry and texture slots (5). | **read** (10.4, 10.5, 10.7) |
| `items/<item>.json` | Item model definition (6). | **read** (10.7) |
| `textures/**/<name>.png` (+ `.png.mcmeta`) | Images (7). | **read** (10.3) |
| `atlases/<atlas>.json` | Sprite sources per atlas (7.3). The ids are fixed by the client. | **read** (the twelve atlases, 7.2; the built-in pack defines blocks, items and gui, 10.2) |
| `lang/<code>.json` | A JSON object mapping translation key to string. Values may use `%s` and `%1$s` placeholders; numeric `%d`/`%f` placeholders are rewritten to `%s` on load. Keys for registry content follow `<kind>.<namespace>.<path with / replaced by .>`, for example `block.cobolcraft.greystone` (`Util.makeDescriptionId`). | **read** (`en_us`, 10.8) |
| `font/<id>.json` | Font provider definitions. CobolCraft reads the `bitmap` provider type (10.10). | **read** (`minecraft:default`, 10.10) |
| `sounds.json` | Sound event → sound file list. | not read (sounds are out of scope) |
| `sounds/**/<name>.ogg` | Ogg audio files. | not read (sounds are out of scope) |
| `particles/<id>.json` | Particle sprite lists. | not read |
| `equipment/<id>.json` | Worn-equipment layer textures. | not read |
| `shaders/**` (`.json`, `.vsh`, `.fsh`, `include/*.glsl`) | GLSL programs. | not applicable (our Vulkan client) |
| `post_effect/<id>.json` | Post-processing chains (named by the Post Effects packet, 03). | not read |
| `waypoint_style/<id>.json` | Locator-bar waypoint styles. | not read |
| `textures/colormap/*.png` | Biome colour lookup images: `grass.png`, `foliage.png`, `dry_foliage.png`, each 256 × 256 (14 §9). | **read** (14 §9) |
| `textures/palettes/*.png` | Palettes for `paletted_permutations` (7.3). | not read directly (only as input to an atlas source, 7.3) |
| `texts/*` | Plain-text resources such as the title-screen splash list. | not read |

---

## 9. Server-pushed packs

The wire packets are in 03-configuration.md: Resource Pack Push (config 0x09 / play 0x52), Resource Pack Pop
(config 0x08 / play 0x51) and serverbound Resource Pack Response (config 0x06 / play 0x32). This section
describes what the client does with them.

### 9.1 On Resource Pack Push

| Step | Client behaviour |
|---|---|
| 1. URL check | The URL string must parse as a URL with protocol exactly `http` or `https`. Otherwise the client immediately replies **5 invalid URL** and stops. |
| 2. Hash | If the hash string matches `^[a-fA-F0-9]{40}$`, it is lowercased and used as the expected SHA-1. **Any other value, including empty, means "no expected hash"**: the download is not verified and no error is raised. |
| 3. Prompt decision | The per-server setting is *prompt*, *enabled* or *disabled* (an unknown server counts as *prompt*). The client shows a confirmation screen if the setting is *prompt*, or if the pack is **required** and the setting is *disabled*. Otherwise it proceeds without asking: *enabled* allows, and *disabled* (pack not required) declines. |
| 4. Prompt screen | The text depends on `required`. If a Prompt component was sent, it is appended to the standard text (key `multiplayer.texturePrompt.serverPrompt`). **Accept** stores *enabled* for the server and allows server packs. **Decline** stores *disabled* and rejects server packs. If the pack was required, the client also **disconnects itself** with `multiplayer.requiredTexturePrompt.disconnect`. (Vanilla client behaviour. CobolCraft's client does not do this; see 9.8.) Several pushes that arrive while the screen is open are merged into one screen. |
| 5. Queueing | If server packs are currently declined, the client replies **1 declined** at once. Otherwise the pack is queued. A queued pack with the **same UUID** is replaced (the old one is dropped silently). If packs are allowed, the client replies **3 accepted**. Packs that wait for the prompt get **3 accepted** once it is accepted, or **1 declined** once it is declined. |
| 6. Download | Accepted packs that are not yet downloaded are fetched in one batch (9.3). Each successful pack gets **4 downloaded**. If any pack in the batch fails, that pack gets **2 failed download**, and every other pack in the batch that is not already active is dropped with **7 discarded**. |
| 7. Activation | When all wanted packs are downloaded, the client reloads its resources with the server packs on top (9.6). On success, each newly active pack gets **0 successfully loaded**. If the reload fails, the client retries once without the new packs. The affected packs get **6 failed reload**. |

### 9.2 Response sequence summary

| Outcome | Actions sent, in order |
|---|---|
| Normal success | 3 accepted, 4 downloaded, 0 successfully loaded |
| Already cached with matching hash | 3 accepted, 4 downloaded, 0 successfully loaded (the "download" is a cache hit) |
| Bad URL | 5 invalid URL |
| User or settings decline | 1 declined (a prompt decline on a required pack is followed by the client disconnecting) |
| HTTP error, size limit, hash mismatch | 3 accepted, 2 failed download |
| Another pack in the same batch failed | 3 accepted, (4 downloaded possible), 7 discarded |
| Pack content broken | 3 accepted, 4 downloaded, 6 failed reload |
| Popped or replaced by the server | No further response for that pack (inferred: those removal reasons carry no reply in `ServerPackManager$RemovalReason`) |

Terminal actions are 0, 1, 2, 5, 6 and 7. A vanilla server's configuration task waits for the first
terminal action (03).

### 9.3 Download rules

| Item | Value |
|---|---|
| Hash algorithm | SHA-1 over the raw file bytes (`Hashing.sha1`). |
| Size limit | **262,144,000 bytes (250 MiB).** Checked against the declared length and again while streaming. A larger file fails ("Filesize is bigger than maximum allowed"). |
| Request headers | `X-Minecraft-Username`, `X-Minecraft-UUID`, `X-Minecraft-Version`, `X-Minecraft-Version-ID`, `X-Minecraft-Pack-Format`, `User-Agent` = `Minecraft Java/<version>` (`DownloadedPackSource$4`). |
| Hash mismatch | Fails ("Hash of downloaded file (…) did not match requested (…)"). The temporary file is deleted. |
| Container | The file is opened as a **zip** pack (`FilePackResources`). It must contain a valid `pack.mcmeta`. |

### 9.4 Cache

| Item | Value |
|---|---|
| Root | `<game directory>/downloads/` |
| Per-pack directory | `downloads/<pack UUID>/` |
| File name | The lowercase hex SHA-1 of the content. |
| Reuse | With an expected hash, an existing file at `<uuid>/<hash>` whose content hashes to the same value is used without any network request ("Returning cached file since actual hash matches requested"). Its modification time is refreshed. |
| No expected hash | Always downloads to a temporary file. The file is then stored under its computed hash. |
| Housekeeping | A JSON event log `downloads/log.json`. On start-up the cache directory is vacuumed to at most 20 entries (`DownloadCacheCleaner.vacuumCacheDir(…, 20)`). The oldest entries go first (inferred from the time-based entry records). |

So a server that keeps the same pack UUID and sends the correct hash lets returning clients skip the
download.

### 9.5 Resource Pack Pop

Pop with a UUID removes that pack. Pop with no UUID removes all server packs. Removed packs drop out at
the next resource reload. On disconnect, all server packs are removed and the prompt state resets.

### 9.6 Stacking of pushed packs

Each active server pack becomes a pack with id `server/<8 hex digits>/<uuid>`. It is **required**, has
default position **`TOP`**, and its position is **fixed** (`DownloadedPackSource.DOWNLOADED_PACK_SELECTION`).
Server packs therefore always sit above every locally selected pack, and the user cannot reorder them.

Among server packs, the **most recently pushed pack has the highest priority** (inferred: the load list is
reversed before ids are numbered, the ids sort in that order, and each fixed-`TOP` insertion lands below
the fixed-`TOP` packs already placed). If any server pack has invalid metadata, all server packs are
ignored for that reload ("Invalid pack metadata in {}, ignoring all").

### 9.7 What our server needs to do

1. Host the pack zip over HTTP or HTTPS.
2. Compute its SHA-1 and send it as 40 hex characters.
3. Use a stable UUID per pack so that clients can reuse their cache.
4. In configuration, send Push and wait for a terminal response.
5. Treat "1 declined" on a required pack as a reason to disconnect, as the vanilla server does.

### 9.8 CobolCraft's own behaviour on a declined required pack

The table in 9.1 describes the vanilla client, which disconnects itself after the Decline button
(`multiplayer.requiredTexturePrompt.disconnect`). CobolCraft's own client and server do not follow that
path:

| Side | Behaviour |
|---|---|
| CobolCraft client | Declining a required pack, whether on the prompt or through a saved *disabled* policy, sends **1 declined** and nothing else. The client does **not** disconnect itself. It keeps the connection open and waits for the server. |
| CobolCraft server | When it receives **1 declined** for a pack it offered as required, it sends Disconnect with the `translate` component `cobolcraft.disconnect.pack_required` (standin-content §17, text in 10.8.4) and closes the connection. During configuration this is the configuration Disconnect; if it happens in play, the play Disconnect. |
| CobolCraft client, afterwards | It handles that Disconnect like any other. It returns to the server list and shows the message rendered through the lang (10.8). |

So the reason the player sees always comes from the server's §17 key, never from a client-side text.

---

## 10. Built-in default pack of the cobolcraft world type

CobolCraft's built-in pack, named `cobolcraft`, is the pack of the cobolcraft world type (1.6). It carries the procedural textures of
[../design/standin-content.md](../design/standin-content.md) (§1.4, §2, §3.2, §12.6 and §14.5), the bitmap font
of its §18, and the English texts of its names and messages (FR-003). The texture generator writes PNG files
at the paths below, or serves them from memory through a pack source. The renderer reads only pack data.
Every texture must match its stand-in recipe pixel for pixel. standin-content §1.5 lists check values (SC-004).
A user or server pack replaces any file by shipping the same path (3.2). The built-in pack sits at the bottom
of the stack, required and fixed at `BOTTOM` (inferred to mirror the client's own built-in pack).

The stack, from bottom to top, in both world types: (1) this built-in pack; (2) the generated vanilla
resource pack, when the tool has produced it; (3) the user's packs in the user's order, including Faithful;
(4) server-pushed packs (9.6). A `minecraft:` texture of Faithful replaces the generated pack's texture by
the same path. It has no effect on `cobolcraft:` content, which only a pack that ships `cobolcraft:` paths
can replace.

The missing texture (orange and black stripes, standin-content §1.4.2) stays engine-generated. It is not a
pack file. It stands in for any block, item, entity or environment texture that no pack supplies, at that
texture's stand-in size. The client's own missing sprite is also code-generated
(`MissingTextureAtlasSprite`). The missing glyph of the font (10.10) is engine-generated too.

### 10.1 Root

`pack.mcmeta`:

| Key path | Value |
|---|---|
| `pack.description` | String "CobolCraft built-in default pack" |
| `pack.min_format` | 97 |
| `pack.max_format` | 97 |

`pack.png`: optional. For example, the ledger_tile texture scaled up.

### 10.2 Atlas definitions

These three files are **[engine name]** paths. A pack adds its sprites to the fixed atlases this way.

| File | `sources` |
|---|---|
| `assets/minecraft/atlases/blocks.json` | One entry: `type` = `directory`, `source` = `block`, `prefix` = `block/` |
| `assets/minecraft/atlases/items.json` | One entry: `type` = `directory`, `source` = `item`, `prefix` = `item/` |
| `assets/minecraft/atlases/gui.json` | Two entries as in 14 §3.1: `type` = `directory`, `source` = `gui/sprites`, `prefix` = empty; `type` = `directory`, `source` = `mob_effect`, `prefix` = `mob_effect/` |

Because `directory` scans every namespace, these entries pick up `assets/cobolcraft/textures/block/*.png`
as sprites `cobolcraft:block/<name>`, and `textures/item/*.png` as `cobolcraft:item/<name>`. The `gui` entries
pick up `textures/gui/sprites/<name>.png` as sprite `<namespace>:<name>`. The built-in GUI sprites that the
shared UI needs in the cobolcraft world type are not yet specified (GAP-34), so the table of 10.3 lists none.

Entity textures (`textures/entity/`), environment textures (`textures/environment/`) and the font image
(`textures/font/`) are **not** atlas sprites. No atlas source lists those directories, and no model refers
to them. The client loads each one as a whole image by its path (10.10, 10.11).

### 10.3 Textures

All files are RGBA PNG under `assets/cobolcraft/textures/`, except the font image, which is
`assets/minecraft/textures/font/ascii.png`. The recipes are in standin-content. No `.mcmeta`
is needed. The "Drawn on" column lists everything a file affects. A pack that replaces one file therefore
changes exactly those things and nothing else (SC-005, US18-3). An *item icon* is the item's picture in
inventory slots, in the hotbar and on a ground item (10.11).

| File | Size | Sprite id | Recipe (standin-content) | Drawn on |
|---|---|---|---|---|
| `block/baseplate.png` | 16 × 16 | `cobolcraft:block/baseplate` | §1.4.2 baseplate | baseplate block (all faces); baseplate item icon |
| `block/greystone.png` | 16 × 16 | `cobolcraft:block/greystone` | §1.4.2 greystone | greystone block; greystone item icon |
| `block/loam.png` | 16 × 16 | `cobolcraft:block/loam` | §1.4.2 loam | loam block; turf bottom face; loam item icon |
| `block/turf_top.png` | 16 × 16 | `cobolcraft:block/turf_top` | §1.4.2 turf, top | turf top face; turf item icon |
| `block/turf_side.png` | 16 × 16 | `cobolcraft:block/turf_side` | §1.4.2 turf, sides | turf side faces |
| `block/grit.png` | 16 × 16 | `cobolcraft:block/grit` | §1.4.2 grit | grit block; grit item icon |
| `block/cardstack_end.png` | 16 × 16 | `cobolcraft:block/cardstack_end` | §1.4.2 cardstack, ends | cardstack end faces (all six states); cardstack item icon |
| `block/cardstack_side.png` | 16 × 16 | `cobolcraft:block/cardstack_side` | §1.4.2 cardstack, sides, punched = false | cardstack side faces, `punched=false` |
| `block/cardstack_side_punched.png` | 16 × 16 | `cobolcraft:block/cardstack_side_punched` | §1.4.2 cardstack, sides, punched = true | cardstack side faces, `punched=true` |
| `block/lucite.png` | 16 × 16 | `cobolcraft:block/lucite` | §1.4.2 lucite. Its partial alpha puts its faces in the translucent layer automatically (5.3). | lucite block; lucite item icon |
| `block/glowtube_lit.png` | 16 × 16 | `cobolcraft:block/glowtube_lit` | §1.4.2 glowtube, lit | glowtube `lit=true`; glowtube item icon |
| `block/glowtube_unlit.png` | 16 × 16 | `cobolcraft:block/glowtube_unlit` | §1.4.2 glowtube, unlit | glowtube `lit=false` |
| `block/ledger_tile.png` | 16 × 16 | `cobolcraft:block/ledger_tile` | §1.4.2 ledger_tile | ledger_tile block; ledger_tile item icon |
| `block/goto_pad.png` | 16 × 16 | `cobolcraft:block/goto_pad` | §1.4.2 goto_pad | goto_pad block (the travel block, all faces); goto_pad item icon |
| `block/slag.png` | 16 × 16 | `cobolcraft:block/slag` | §1.4.2 slag | slag block; slag item icon |
| `block/crafting_bench_top.png` | 16 × 16 | `cobolcraft:block/crafting_bench_top` | cobolcraft-standard-core.md CORE-33 | crafting bench top face; crafting bench item icon |
| `block/crafting_bench_side.png` | 16 × 16 | `cobolcraft:block/crafting_bench_side` | cobolcraft-standard-core.md CORE-33 | crafting bench side faces (its bottom face is `block/ledger_tile.png`) |
| `item/pry_bar.png` | 16 × 16 | `cobolcraft:item/pry_bar` | §2 pry_bar | pry_bar item icon |
| `item/trowel.png` | 16 × 16 | `cobolcraft:item/trowel` | §2 trowel | trowel item icon |
| `item/grazer_flank.png` | 16 × 16 | `cobolcraft:item/grazer_flank` | §2 grazer_flank | grazer_flank item icon (food) |
| `item/seared_flank.png` | 16 × 16 | `cobolcraft:item/seared_flank` | §2 seared_flank | seared_flank item icon (food) |
| `item/sod_cake.png` | 16 × 16 | `cobolcraft:item/sod_cake` | §2 sod_cake | sod_cake item icon (food) |
| `item/dump_shard.png` | 16 × 16 | `cobolcraft:item/dump_shard` | §2 dump_shard | dump_shard item icon (recipe material) |
| `entity/operator.png` | 66 × 28 | — (whole image) | §3.1, §3.2 | every player's figure |
| `entity/sodgrazer.png` | 80 × 23 | — (whole image) | §3.1, §12.6 | every sodgrazer |
| `entity/abend.png` | 72 × 12 | — (whole image) | §3.1, §12.6 | every abend |
| `environment/drizzle.png` | 16 × 16 | — (whole image) | §14.5 drizzle | drizzle precipitation quads |
| `environment/hailstorm.png` | 16 × 16 | — (whole image) | §14.5 hailstorm | hailstorm precipitation quads |
| `assets/minecraft/textures/font/ascii.png` (not under `cobolcraft`) | 128 × 128 | — (whole image) | §18, placed by the standard layout (10.10) | every character of client text (10.10) |

The `ground item` entity (`cobolcraft:loose_item`) has no texture of its own: it shows its item's icon. The
`clear` weather kind has no environment texture and draws nothing.

A pack may supply a texture at another size. Block and item sprites follow 7.1. Entity and environment
textures are mapped by fractions of their stand-in size (10.11). A replacement with the same aspect ratio
at any whole-number scale therefore lines up.

The cardstack side texture is drawn with its card-edge lines horizontal. In the upright model (axis = y),
the stack's long direction is vertical, so the lines cross it as standin-content describes.

### 10.4 Template models

We ship no vanilla parent models, so the pack defines its own small set of templates. The names are ours.
All live under `assets/cobolcraft/models/block/`.

**`template_box`** (a full cube, every face its own slot):

| Key path | Value |
|---|---|
| `textures.particle` | `#north` |
| `elements[0].from` | 0, 0, 0 |
| `elements[0].to` | 16, 16, 16 |
| `elements[0].faces.<dir>` for each of down, up, north, south, west, east | `texture` = `#<dir>`, `cullface` = `<dir>` (no `uv`: derived from the bounds, 5.5.1, giving [0, 0, 16, 16]) |

The other templates set `parent` = `cobolcraft:block/template_box` and differ only in their `textures` map:

| Template | `textures` entries |
|---|---|
| `template_uniform` | `particle` = `#all`; down, up, north, south, west and east each = `#all` |
| `template_layered` | `particle` = `#side`; `up` = `#top`; `down` = `#bottom`; north, south, west and east each = `#side` |
| `template_pillar` | `particle` = `#side`; `up` and `down` = `#end`; north, south, west and east each = `#side` |

`ambientocclusion` and `gui_light` are left at their defaults (true, side).

### 10.5 Block models

Under `assets/cobolcraft/models/block/`. Each has a `parent` and a `textures` map only.

| Model id | `parent` | `textures` |
|---|---|---|
| `cobolcraft:block/baseplate` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/baseplate` |
| `cobolcraft:block/greystone` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/greystone` |
| `cobolcraft:block/loam` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/loam` |
| `cobolcraft:block/turf` | `cobolcraft:block/template_layered` | `top` = `cobolcraft:block/turf_top`; `side` = `cobolcraft:block/turf_side`; `bottom` = `cobolcraft:block/loam` |
| `cobolcraft:block/grit` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/grit` |
| `cobolcraft:block/cardstack` | `cobolcraft:block/template_pillar` | `end` = `cobolcraft:block/cardstack_end`; `side` = `cobolcraft:block/cardstack_side` |
| `cobolcraft:block/cardstack_punched` | `cobolcraft:block/template_pillar` | `end` = `cobolcraft:block/cardstack_end`; `side` = `cobolcraft:block/cardstack_side_punched` |
| `cobolcraft:block/lucite` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/lucite` |
| `cobolcraft:block/glowtube_lit` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/glowtube_lit` |
| `cobolcraft:block/glowtube_unlit` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/glowtube_unlit` |
| `cobolcraft:block/ledger_tile` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/ledger_tile` |
| `cobolcraft:block/goto_pad` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/goto_pad` |
| `cobolcraft:block/slag` | `cobolcraft:block/template_uniform` | `all` = `cobolcraft:block/slag` |
| `cobolcraft:block/void` (optional) | none | none. No `elements`, so it has no geometry. |

Optional: `glowtube_lit` and `goto_pad` may instead copy the `template_box` element with `light_emission`
15, so that their faces draw at full brightness. World light still comes from the block's light level
(standin-content §1.1: 15 for a lit glowtube, 6 for a goto_pad), not from the model.

Lucite culling between two lucite blocks (standin-content §1.1) is renderer policy for same-block
neighbours. `cullface` only marks which neighbour may hide a face.

### 10.6 Block state files

Under `assets/cobolcraft/blockstates/`. Each uses `variants`.

| File | Variant key → Variant |
|---|---|
| `baseplate.json`, `greystone.json`, `loam.json`, `turf.json`, `grit.json`, `lucite.json`, `ledger_tile.json`, `goto_pad.json`, `slag.json` | `""` → `model` = `cobolcraft:block/<same name>` |
| `glowtube.json` | `lit=true` → `cobolcraft:block/glowtube_lit`; `lit=false` → `cobolcraft:block/glowtube_unlit` |
| `cardstack.json` | six keys, below |
| `void.json` (optional) | `""` → `cobolcraft:block/void`. Our client never draws void, so the file can be omitted. |

`cardstack.json` (the template puts the ends on up/down, matching axis = y):

| Key | `model` | `x` | `y` |
|---|---|---|---|
| `axis=y,punched=false` | `cobolcraft:block/cardstack` | 0 | 0 |
| `axis=y,punched=true` | `cobolcraft:block/cardstack_punched` | 0 | 0 |
| `axis=z,punched=false` | `cobolcraft:block/cardstack` | 90 | 0 |
| `axis=z,punched=true` | `cobolcraft:block/cardstack_punched` | 90 | 0 |
| `axis=x,punched=false` | `cobolcraft:block/cardstack` | 90 | 90 |
| `axis=x,punched=true` | `cobolcraft:block/cardstack_punched` | 90 | 90 |

`uvlock` stays false, so the card-edge lines turn with the stack. With the Variant rotation rule of 5.4.1,
`x` = 90 turns the ends from up/down to north/south (axis = z). `x` = 90 then `y` = 90 turns them to
east/west (axis = x). These six keys cover the six cardstack states (state ids 6 to 11 of standin-content
§1.2) exactly once, so there is no overlap error. Together, the eleven files give each of the **18** block
states of standin-content §1.2 exactly one model, except state 0 (void), which is never drawn.

### 10.7 Item models and item definitions

standin-content §2 asks for **flat 16 × 16 icons** for every item. Block items use a block texture. Each
gets a generated item model under `assets/cobolcraft/models/item/`, with `parent` =
`minecraft:builtin/generated` **[engine name]** and a single `layer0`. Block items take `layer0` from the
block atlas, which item models are allowed to use (5.3). Each model's layer uses one atlas only.

| Item | Item model id | `layer0` |
|---|---|---|
| baseplate | `cobolcraft:item/baseplate` | `cobolcraft:block/baseplate` |
| greystone | `cobolcraft:item/greystone` | `cobolcraft:block/greystone` |
| loam | `cobolcraft:item/loam` | `cobolcraft:block/loam` |
| turf | `cobolcraft:item/turf` | `cobolcraft:block/turf_top` |
| grit | `cobolcraft:item/grit` | `cobolcraft:block/grit` |
| cardstack | `cobolcraft:item/cardstack` | `cobolcraft:block/cardstack_end` |
| lucite | `cobolcraft:item/lucite` | `cobolcraft:block/lucite` |
| glowtube | `cobolcraft:item/glowtube` | `cobolcraft:block/glowtube_lit` |
| ledger_tile | `cobolcraft:item/ledger_tile` | `cobolcraft:block/ledger_tile` |
| pry_bar | `cobolcraft:item/pry_bar` | `cobolcraft:item/pry_bar` |
| trowel | `cobolcraft:item/trowel` | `cobolcraft:item/trowel` |
| grazer_flank | `cobolcraft:item/grazer_flank` | `cobolcraft:item/grazer_flank` |
| seared_flank | `cobolcraft:item/seared_flank` | `cobolcraft:item/seared_flank` |
| sod_cake | `cobolcraft:item/sod_cake` | `cobolcraft:item/sod_cake` |
| dump_shard | `cobolcraft:item/dump_shard` | `cobolcraft:item/dump_shard` |
| goto_pad | `cobolcraft:item/goto_pad` | `cobolcraft:block/goto_pad` |
| slag | `cobolcraft:item/slag` | `cobolcraft:block/slag` |

No `display` entries are needed for our client, which applies its own hand and GUI placement. A later pack
can add them (5.6).

Item definitions under `assets/cobolcraft/items/`:

| File | `model.type` | `model.model` |
|---|---|---|
| `<item>.json` for each of the 17 items above (item ids 1 to 17 of standin-content §2) | `minecraft:model` | the item model id from the table above |
| `nothing.json` (optional) | `minecraft:empty` | none |

The other top-level fields keep their defaults (6.1).

CobolCraft's client draws every item icon (slots, hotbar and ground item, 10.11) as the `layer0` sprite of
the model that the item's definition names. It reads only the `minecraft:model` type for this. If the
definition has another type, or its model chain does not reach `minecraft:builtin/generated` with a
`layer0`, the icon is the missing texture.

### 10.8 Language

`assets/cobolcraft/lang/en_us.json` is one JSON object that maps each translation key below to its text. The
client loads `lang/en_us.json` from every namespace of every pack and merges them, bottom pack first (3.2).
A higher pack therefore replaces single texts, and the namespace directory of a lang file does not limit
which keys it may hold.

Rules that CobolCraft's client and server console apply:

- **Lookup.** A key that no pack defines is shown as the key itself.
- **Arguments.** The texts use only plain `%s` placeholders, in argument order: the first `%s` takes the
  first argument of the `translate` component, and so on. The "Arguments" columns give that order. They
  copy standin-content §17, which also says how each argument is written. A replacement pack may
  reorder the arguments with `%1$s`, `%2$s`, … (section 8).
- **Character set.** Every text is printable ASCII (codes 32 to 126), the range of the built-in font (10.10).
  Any other character draws as the missing glyph.
- **Who reads it.** Server-sent messages are `translate` components (contracts/wire-profile.md §1 message
  rule; standin-content §17), apart from the protocol-defined disconnect reasons of 10.8.4. Only player
  chat is literal text. The client renders those messages through
  this table. The server console prints them through the same texts (operator-surface §3). Client screen
  and HUD texts (10.8.6) are looked up by the client itself.

**Where the texts come from.** There are three sources, and the merge order above (bottom pack first, a higher pack replaces a
key) decides which one a player sees:

| Source | Holds | Pack level (11.2) |
|---|---|---|
| This built-in file | The `cobolcraft.*` keys, the `block.cobolcraft.*`, `item.cobolcraft.*`, `entity.cobolcraft.*`, `weather.cobolcraft.*` and `dimension.cobolcraft.*` names of 10.8.1, and a **fallback set** of standard keys | 1 |
| The generated `vanilla` pack (22 §6.1: `assets/minecraft/lang/en_us.json`, verbatim) | Every standard key with its standard text: command feedback, death messages, disconnect reasons, advancement and UI texts | 2 |
| User packs such as Faithful | Whatever they ship; Faithful is textures only (14) and has no `lang` file | 3 |

Consequences. (1) In the standard world type the generated pack's text wins over any fallback entry of the same key, so a fallback
text is never seen while the generated pack is valid. (2) In the cobolcraft world type, with no generated pack, the standard keys the shared rules need
(death messages, command feedback, UI texts) are shown from the fallback set, in the standard wording (README P08-12). That wording is
read from the standard `en_us` (15 §5 for the framework keys, 16 for each command's keys with their English text, 16 §13 for the game rule titles).
(3) A CobolCraft text never takes a standard key (world-types §6.2, Decision WT-15), because the generated `en_us` would replace it:
that is why the CobolCraft keys use the `cobolcraft.` prefix. (4) The lookup rule above (a key no pack defines is shown as the key) applies
last.

Sections 10.8.2 (death messages) and 10.8.3 (command messages) no longer exist. The stand-in keys they
listed are retired: death messages and command messages use the standard keys in both world types (15 §5, 16
and the standard `en_us`). The numbers are not reused, so that citations of 10.8.4 to 10.8.6 stay valid.

#### 10.8.1 Names

CobolCraft names an item that places a block by its block's key, and every other item by its `item.*` key.
Mob names use the `entity.*` form of section 8. Weather kinds and dimensions are not registry content in
the client, so CobolCraft gives them keys of its own in the same `<kind>.<namespace>.<path>` form.

| Key | Value |
|---|---|
| `block.cobolcraft.baseplate` | Baseplate |
| `block.cobolcraft.greystone` | Greystone |
| `block.cobolcraft.loam` | Loam |
| `block.cobolcraft.turf` | Turf |
| `block.cobolcraft.grit` | Grit |
| `block.cobolcraft.cardstack` | Cardstack |
| `block.cobolcraft.lucite` | Lucite |
| `block.cobolcraft.glowtube` | Glowtube |
| `block.cobolcraft.ledger_tile` | Ledger Tile |
| `block.cobolcraft.goto_pad` | GOTO Pad |
| `block.cobolcraft.slag` | Slag |
| `item.cobolcraft.pry_bar` | Pry Bar |
| `item.cobolcraft.trowel` | Trowel |
| `item.cobolcraft.grazer_flank` | Grazer Flank |
| `item.cobolcraft.seared_flank` | Seared Flank |
| `item.cobolcraft.sod_cake` | Sod Cake |
| `item.cobolcraft.dump_shard` | Dump Shard |
| `entity.cobolcraft.operator` | Operator |
| `entity.cobolcraft.sodgrazer` | Sodgrazer |
| `entity.cobolcraft.abend` | Abend |
| `weather.cobolcraft.clear` | Clear |
| `weather.cobolcraft.drizzle` | Drizzle |
| `weather.cobolcraft.hailstorm` | Hailstorm |
| `dimension.cobolcraft.main` | Main |
| `dimension.cobolcraft.subroutine` | Subroutine |
| `cobolcraft.gamemode.survival` | Survival |
| `cobolcraft.gamemode.creative` | Creative |

#### 10.8.4 Disconnect and refusal reasons (standin-content §17)

Only three disconnect keys are CobolCraft's own, because the standard has no equivalent: `host_closed` (a
client-hosted world), `pack_required` (09 §9.8) and `name_is_host`. The other CobolCraft reasons of the earlier
design (barred, not on the guest list, replaced, shutdown, ejected, ejected without a reason) are retired. They use
the shared standard keys in both world types (for example `multiplayer.disconnect.not_whitelisted`; 16 §11.22,
and GAP-27 for standard keys that no document lists yet).

| Key | Arguments | Value |
|---|---|---|
| `cobolcraft.disconnect.name_is_host` | name | The name %s belongs to the host of this world |
| `cobolcraft.disconnect.host_closed` | — | The host closed the world |
| `cobolcraft.disconnect.pack_required` | — | This server requires its resource pack |

The protocol documents fix the keys of some disconnects, and CobolCraft's server sends those keys as they
are (FR-001 makes the protocol's disconnect behaviours required; 09 §2 and its Open question 2). These are
**[engine name]** keys. Their texts are the **standard wording** of the standard `en_us`, not wording of our own.
In the standard world type the generated pack supplies them and its texts replace any built-in text with the
same key (pack order, 22 Open question 3). In the cobolcraft world type this file is the fallback and carries the
standard wording. The Value column below therefore gives no text. The standard text is in no document yet
(GAP-27) and a clean-room round must supply it before the fallback file is written. A pack can change these
texts like any other key:

| Key | Arguments | Sent when | Value |
|---|---|---|---|
| `multiplayer.disconnect.incompatible` | the server's version name | Login with protocol version ≠ 777, client version ≥ 754 (02) | standard text (GAP-27) |
| `multiplayer.disconnect.outdated_client` | the server's version name | Login with protocol version < 754 (02) | standard text (GAP-27) |
| `multiplayer.disconnect.transfers_disabled` | — | Handshake with intent 3, transfer (02) | standard text (GAP-27) |
| `multiplayer.disconnect.slow_login` | — | Login not finished within 600 ticks (01 §7.5, 02) | standard text (GAP-27) |
| `multiplayer.disconnect.unexpected_query_response` | — | An answer to a query or cookie request the server never made (02) | standard text (GAP-27) |
| `multiplayer.disconnect.invalid_player_movement` | — | A position or rotation that is not a finite number in range (05c) | standard text (GAP-27) |
| `disconnect.timeout` | — | A missing or wrong Keep Alive reply (01 §7.5) | standard text (GAP-27) |

The other disconnect keys of 01 and 02 are never sent by CobolCraft's server. `disconnect.ignoring_status_request`
and `multiplayer.status.request_handled` end a status exchange, which has no Disconnect packet.
`multiplayer.disconnect.unverified_username` and `multiplayer.disconnect.authservers_down` belong to online
mode, which CobolCraft never uses.

#### 10.8.5 Chat type (standin-content §4.4)

| Key | Arguments | Value |
|---|---|---|
| `cobolcraft.chat.say` | sender, content | <%s> %s |
| `cobolcraft.chat.say.narrate` | sender, content | %s says %s |

#### 10.8.6 Client screens and HUD (data-model §13)

These keys belong to the client alone. The server never sends them. **Lookup rule.** Where the standard `en_us`
has a key for a UI text (title screen, pause menu, options, resource pack screens, connecting and similar), the
client uses the standard key in both world types, and its text comes from the generated pack or the standard
`en_us`. The `cobolcraft.screen.*` and `cobolcraft.hud.*` entries below are the **fallback set** of the built-in
pack. The client looks up the standard key first and uses the entry below only when no loaded pack defines that
key. An entry with no standard counterpart (for example the pack prompt, open to others and the crafting list
texts) stays a CobolCraft key. Which entries have a standard counterpart is settled with the standard key
survey (GAP-27). The screen names follow the screen model of data-model §13. Keys under `cobolcraft.screen.common` are shared by several screens.

| Key | Arguments | Value |
|---|---|---|
| `cobolcraft.screen.common.done` | — | Done |
| `cobolcraft.screen.common.cancel` | — | Cancel |
| `cobolcraft.screen.common.back` | — | Back |
| `cobolcraft.screen.common.yes` | — | Yes |
| `cobolcraft.screen.common.no` | — | No |
| `cobolcraft.screen.title.name` | — | CobolCraft |
| `cobolcraft.screen.title.single_player` | — | Single-player |
| `cobolcraft.screen.title.multiplayer` | — | Multiplayer |
| `cobolcraft.screen.title.packs` | — | Resource Packs |
| `cobolcraft.screen.title.quit` | — | Quit Game |
| `cobolcraft.screen.server_list.title` | — | Servers |
| `cobolcraft.screen.server_list.join` | — | Join |
| `cobolcraft.screen.server_list.add` | — | Add Server |
| `cobolcraft.screen.server_list.edit` | — | Edit |
| `cobolcraft.screen.server_list.remove` | — | Remove |
| `cobolcraft.screen.server_list.empty` | — | No servers yet |
| `cobolcraft.screen.server_list.pinging` | — | Asking the server... |
| `cobolcraft.screen.server_list.online` | players online, maximum players | %s of %s online |
| `cobolcraft.screen.server_list.unreachable` | — | No answer from the server |
| `cobolcraft.screen.server_list.incompatible` | the server's version name | Incompatible version: %s |
| `cobolcraft.screen.server_list.disconnected` | the last disconnect message | Disconnected: %s |
| `cobolcraft.screen.edit_server.title_add` | — | Add Server |
| `cobolcraft.screen.edit_server.title_edit` | — | Edit Server |
| `cobolcraft.screen.edit_server.name` | — | Server name |
| `cobolcraft.screen.edit_server.address` | — | Address |
| `cobolcraft.screen.edit_server.pack_policy` | policy word (one of the next three) | Server packs: %s |
| `cobolcraft.screen.pack_policy.prompt` | — | Ask each time |
| `cobolcraft.screen.pack_policy.enabled` | — | Always accept |
| `cobolcraft.screen.pack_policy.disabled` | — | Never accept |
| `cobolcraft.screen.connecting.title` | address | Connecting to %s |
| `cobolcraft.screen.connecting.joining` | — | Joining the world |
| `cobolcraft.screen.connecting.failed` | address | Could not connect to %s |
| `cobolcraft.screen.connecting.lost` | — | The connection was lost |
| `cobolcraft.screen.connecting.timed_out` | — | The server stopped answering |
| `cobolcraft.screen.inventory.title` | — | Inventory |
| `cobolcraft.screen.crafting.title` | — | Crafting |
| `cobolcraft.screen.crafting.craftable` | — | Ready to craft |
| `cobolcraft.screen.crafting.not_craftable` | — | Missing ingredients |
| `cobolcraft.screen.crafting.ingredient` | count, item name | %s x %s |
| `cobolcraft.screen.crafting.result` | count, item name | Makes %s x %s |
| `cobolcraft.screen.crafting.craft` | — | Craft |
| `cobolcraft.screen.chat.hint` | — | Type a message, or / for a command |
| `cobolcraft.screen.pause.title` | — | Game Menu |
| `cobolcraft.screen.pause.paused` | — | Paused |
| `cobolcraft.screen.pause.resume` | — | Back to the World |
| `cobolcraft.screen.pause.open_to_others` | — | Open to Others |
| `cobolcraft.screen.pause.disconnect` | — | Disconnect |
| `cobolcraft.screen.pause.quit_world` | — | Save and Leave the World |
| `cobolcraft.screen.packs.title` | — | Resource Packs |
| `cobolcraft.screen.packs.available` | — | Available |
| `cobolcraft.screen.packs.selected` | — | Selected |
| `cobolcraft.screen.packs.enable` | — | Enable |
| `cobolcraft.screen.packs.disable` | — | Disable |
| `cobolcraft.screen.packs.move_up` | — | Move Up |
| `cobolcraft.screen.packs.move_down` | — | Move Down |
| `cobolcraft.screen.packs.builtin` | — | Built-in pack |
| `cobolcraft.screen.packs.compatible` | — | Compatible |
| `cobolcraft.screen.packs.too_old` | — | Made for an older version |
| `cobolcraft.screen.packs.too_new` | — | Made for a newer version |
| `cobolcraft.screen.packs.unknown` | — | Version unknown |
| `cobolcraft.screen.packs.error` | pack name, problem (one of the next four) | %s cannot be used: %s |
| `cobolcraft.screen.packs.problem.unreadable` | — | the pack cannot be read |
| `cobolcraft.screen.packs.problem.no_metadata` | — | pack.mcmeta is missing |
| `cobolcraft.screen.packs.problem.bad_metadata` | — | pack.mcmeta has no usable pack section |
| `cobolcraft.screen.packs.problem.bad_file` | path of the file | %s cannot be read |
| `cobolcraft.screen.pack_confirm.title` | — | Enable This Pack? |
| `cobolcraft.screen.pack_confirm.too_old` | pack name | %s was made for an older version and may look wrong |
| `cobolcraft.screen.pack_confirm.too_new` | pack name | %s was made for a newer version and may look wrong |
| `cobolcraft.screen.pack_confirm.unknown` | pack name | The version of %s is unknown and it may look wrong |
| `cobolcraft.screen.pack_confirm.enable` | — | Enable Anyway |
| `cobolcraft.screen.pack_prompt.title` | — | Server Resource Pack |
| `cobolcraft.screen.pack_prompt.optional` | — | This server offers a resource pack |
| `cobolcraft.screen.pack_prompt.required` | — | This server requires a resource pack; declining disconnects you |
| `cobolcraft.screen.pack_prompt.message` | the server's prompt text | The server says: %s |
| `cobolcraft.screen.pack_prompt.accept` | — | Accept |
| `cobolcraft.screen.pack_prompt.decline` | — | Decline |
| `cobolcraft.screen.pack_prompt.remembered` | — | Your answer is kept for this server |
| `cobolcraft.screen.pack_prompt.downloading` | — | Fetching the server pack... |
| `cobolcraft.screen.world_list.title` | — | Single-player Worlds |
| `cobolcraft.screen.world_list.entry` | level name, folder name | %s (%s) |
| `cobolcraft.screen.world_list.play` | — | Play |
| `cobolcraft.screen.world_list.create` | — | Create New World |
| `cobolcraft.screen.world_list.delete` | — | Delete |
| `cobolcraft.screen.world_list.empty` | — | No worlds yet |
| `cobolcraft.screen.create_world.title` | — | Create New World |
| `cobolcraft.screen.create_world.name` | — | World name |
| `cobolcraft.screen.create_world.default_name` | — | New World |
| `cobolcraft.screen.create_world.mode` | game mode name | Game mode: %s |
| `cobolcraft.screen.create_world.create` | — | Create |
| `cobolcraft.screen.confirm_delete.title` | — | Delete This World? |
| `cobolcraft.screen.confirm_delete.text` | level name | %s will be deleted for good |
| `cobolcraft.screen.confirm_delete.delete` | — | Delete |
| `cobolcraft.screen.open_to_others.title` | — | Open to Others |
| `cobolcraft.screen.open_to_others.mode` | game mode name | Guest game mode: %s |
| `cobolcraft.screen.open_to_others.operators` | `Yes` or `No` text | Guests may use operator commands: %s |
| `cobolcraft.screen.open_to_others.start` | — | Open the World |
| `cobolcraft.screen.open_to_others.address` | address and port | Others can join at %s |
| `cobolcraft.hud.health` | current health, maximum health | Health %s/%s |
| `cobolcraft.hud.food` | current food, maximum food | Food %s/%s |
| `cobolcraft.hud.crosshair` | — | + |

A "game mode name" argument is the text of `cobolcraft.gamemode.survival` or `cobolcraft.gamemode.creative`
(10.8.1). A "`Yes` or `No` text" argument is the text of `cobolcraft.screen.common.yes` or `.no`. The death
screen uses the standard keys (10.8.2 was removed). Three HUD parts of data-model §13 carry no fixed text. The hotbar shows item
icons and each stack count as decimal digits. The chat lines show the received messages. The target
highlight is an outline. The world screen has no labels apart from the HUD.

### 10.9 File count

| Kind | Files |
|---|---|
| `pack.mcmeta` | 1 |
| Atlas definitions (10.2) | 3 |
| PNG textures (10.3) | 29: 17 block (the 15 of the table, and the 2 bench textures `crafting_bench_top` and `crafting_bench_side` of cobolcraft-standard-core.md CORE-33), 6 item, 3 entity, 2 environment, 1 font |
| Template models (10.4) | 4 |
| Block models (10.5) | 13 (14 with void) |
| Item models (10.7) | 17 |
| Block state files (10.6) | 11 (12 with void) |
| Item definitions (10.7) | 17 (18 with nothing) |
| Font definitions (10.10) | 4 |
| Language files (10.8) | 1 |

That is 98 files, or 101 with the three optional ones. The built-in GUI sprites (GAP-34) are not counted.

### 10.10 Font

Both world types use the standard font definitions of 14 §10.1: the font `minecraft:default`, a list of
providers that includes `include/space` and `include/default`. The built-in pack carries a fallback copy of
them, and the generated vanilla pack carries the full set. Every character of client text (screens, HUD, chat
and item names) is drawn with `minecraft:default`. The renderer ignores any `font` a text component names. The
fallback glyphs are built from standin-content §18.

**Definition files in the built-in pack.** The files of 14 §10.1 for `default`: `assets/minecraft/font/default.json`,
`assets/minecraft/font/include/space.json`, `assets/minecraft/font/include/default.json` and
`assets/minecraft/font/include/unifont.json` (an empty provider list, as in the shipped jar). Their content is
the one in 14 §10.1, with one difference: `include/default` holds only provider (c), the `bitmap` of
`minecraft:font/ascii.png`, because the built-in pack supplies no image for providers (a) and (b). The
generated pack's definitions hold all three.

`include/default` provider (c) in the built-in pack:

| Key path | Value |
|---|---|
| `providers[0].type` | `bitmap` **[engine name]** |
| `providers[0].file` | `minecraft:font/ascii.png` (an id relative to `textures/`, including `.png`, so the file is `assets/minecraft/textures/font/ascii.png`) |
| `providers[0].height` | 8 |
| `providers[0].ascent` | 7 |
| `providers[0].chars` | the sixteen strings below (the standard layout of 14 §10.2, ASCII only) |

`chars` lists the image row by row. Each string covers one row of 16 cells, and every string has the same
length. The character `\u0000` marks an unused cell. In JSON:

```json
["\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 " !\"#$%&'()*+,-./",
 "0123456789:;<=>?",
 "@ABCDEFGHIJKLMNO",
 "PQRSTUVWXYZ[\\]^_",
 "`abcdefghijklmno",
 "pqrstuvwxyz{|}~\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000",
 "\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000"]
```

The field meanings are those of 14 §10.1 and §10.3. `file` names the image. The cell size is the image width
divided by the row length, by the image height divided by the number of rows. `height` is the drawn glyph
height in pixels. `ascent` is the number of pixels above the baseline, and it may not exceed `height`.

**`assets/minecraft/textures/font/ascii.png`** is 128 × 128 RGBA, a 16 × 16 grid of 8 × 8 cells. The glyph for
code c (32 to 126) fills the cell whose top-left pixel is ((c mod 16) × 8, (c div 16) × 8), so the printable
range sits in rows 2 to 7 as in 14 §10.2. Within the cell, row r is the glyph's row byte r, and column k is bit
0x80 >> k: a set bit is `#FFFFFF` at alpha 255, and a clear bit is transparent. Every other cell, including the
one for code 127 at (120, 56), stays transparent. With ascent 7, cell rows 0 to 6 sit above the baseline and
row 7 holds descenders, as standin-content §18 says. (standin-content §18 still describes a 128 × 48 image
with the first glyph row at the top. The placement above replaces that layout. The glyph data and advances are
unchanged.)

**CobolCraft's text rules** apply to the built-in font and to any pack's replacement. At scale 1 they agree with 14 §10.3:

- A glyph's advance is the column of its rightmost non-transparent pixel plus 2, counted in cell pixels. A
  cell with no ink, such as the space, advances 4. These rules give the advances listed in
  standin-content §18. With a replacement image whose cells are larger than 8 × 8, advances and pixels
  scale by `height` / cell height.
- Text is coloured by multiplying the ink by the text colour.
- A character that is not in `chars`, or that falls in a `\u0000` cell, draws as the **missing glyph**.
  This glyph is engine-generated, not a pack file: the box `F8 88 88 88 88 88 F8 00` (standin-content §18),
  advance 6. If no pack supplies a usable `minecraft:default`, every character draws as the missing glyph.

### 10.11 Entities and weather

CobolCraft draws entities and precipitation from the boxes and rules of standin-content, using textures
from packs. The **geometry is fixed in the client**: a pack cannot change the boxes. A pack changes only
the textures, which are the files of 10.3 under `entity/` and `environment/`. Replacing
`textures/entity/abend.png`, for example, changes every abend and nothing else (SC-005).

**Entity boxes.** Each entity type is drawn as boxes in its model space (standin-content §3.1: units of
1/16 block, +y up, +z the look direction, +x the entity's left). The model is turned about +y by −yaw
(right-handed) and moved to the entity position. This model space is not the block model space of 5.4.1.

| Entity type | Part | Boxes (from → to) | w × h × d |
|---|---|---|---|
| `cobolcraft:operator` | `box` | (−5.5, 0, −5.5) → (5.5, 28, 5.5) | 11 × 28 × 11 |
| `cobolcraft:sodgrazer` | `body` | (−7, 3, −6) → (7, 12, 6) | 14 × 9 × 12 |
| | `head` | (−4, 6, 6) → (4, 14, 11) | 8 × 8 × 5 |
| | `leg` | (2, 0, 2) → (5, 3, 5); (−5, 0, 2) → (−2, 3, 5); (2, 0, −5) → (5, 3, −2); (−5, 0, −5) → (−2, 3, −2) | 3 × 3 × 3 |
| `cobolcraft:abend` | `body` | (−6, 0, −6) → (6, 12, 6) | 12 × 12 × 12 |

The sources are standin-content §3.2 and §12.6. A `cobolcraft:loose_item` has no boxes (see Ground items
below).

**Texture layout per box face.** Each part has one strip of the texture (standin-content §3.1 strip layout).
Every box of a part uses the same face rectangles. Each rectangle below is given as its top-left texel
(x, y) and its size in texels:

| Texture | Part (strip rows) | front (+z) | back (−z) | left (+x) | right (−x) | top (+y) | bottom (−y) |
|---|---|---|---|---|---|---|---|
| `operator` 66 × 28 | `box` (y 0–27) | (0, 0) 11 × 28 | (11, 0) 11 × 28 | (22, 0) 11 × 28 | (33, 0) 11 × 28 | (44, 0) 11 × 11 | (55, 0) 11 × 11 |
| `sodgrazer` 80 × 23 | `body` (y 0–11) | (0, 0) 14 × 9 | (14, 0) 14 × 9 | (28, 0) 12 × 9 | (40, 0) 12 × 9 | (52, 0) 14 × 12 | (66, 0) 14 × 12 |
| | `head` (y 12–19) | (0, 12) 8 × 8 | (8, 12) 8 × 8 | (16, 12) 5 × 8 | (21, 12) 5 × 8 | (26, 12) 8 × 5 | (34, 12) 8 × 5 |
| | `leg` (y 20–22) | (0, 20) 3 × 3 | (3, 20) 3 × 3 | (6, 20) 3 × 3 | (9, 20) 3 × 3 | (12, 20) 3 × 3 | (15, 20) 3 × 3 |
| `abend` 72 × 12 | `body` (y 0–11) | (0, 0) 12 × 12 | (12, 0) 12 × 12 | (24, 0) 12 × 12 | (36, 0) 12 × 12 | (48, 0) 12 × 12 | (60, 0) 12 × 12 |

A rectangle covers texel edges x to x + width and y to y + height. Its corners map onto the face's corners
by standin-content §3.1 "Texel orientation": row 0 is the top edge, and column 0 is the −x edge of the
front, and so on. A texture coordinate is the texel edge divided by the stand-in texture size in the table,
for example u = x / 80 for `sodgrazer`. A replacement image of any size is therefore sampled at the same
fractions. Texels outside every rectangle are never sampled. Entity faces use the same render-layer rule
as block faces (5.3): fully transparent texels are not drawn.

**Ground items.** A `cobolcraft:loose_item` is drawn as its item's icon on a square 0.3 × 0.3 block
billboard (standin-content §3.3). The bottom edge is at the entity's y, it is centred horizontally on the
entity position, and it is turned about the vertical axis to face the camera. The icon is the `layer0`
sprite of the item model named by the item's definition (10.7), the same picture the GUI shows. The quad
spans the whole sprite, with the sprite's top row at the top. An item definition that does not lead to a
generated model with a `layer0` is drawn with the missing texture.

**Weather.** In drizzle and hailstorm, the client builds the crossed vertical quads of standin-content
§14.5 around the camera. It draws them with the environment texture of the current kind:
`textures/environment/drizzle.png` or `textures/environment/hailstorm.png`. On each quad, u runs from 0 at
one end to 1 at the other. v is the block y modulo 1, plus the downward scroll of §14.5, and the texture
repeats vertically (the client samples it with repeat wrapping). The quads are alpha-blended, unlit, and
drawn after opaque geometry. Clear weather, and every dimension without weather (standin-content §14.2),
draws no quads. The sky colour and daylight changes of §14.5 are client constants, not pack files.

---


## 11. Generated resource pack and pack order

The resource pack of the standard world type is not authored in these documents. The extraction tool (22) builds it on the user's machine from
the user's own client jar, and the client loads it as a built-in required pack. This section only places it in the stack; the rows, the paths and
the checks are in 22.

### 11.1 The generated pack

| Item | Where it is specified |
|---|---|
| Location: `<generated>/vanilla-resources/`, a directory pack (1.1) with pack id `vanilla`, title "Default" | 22 §5.1, §5.2, §8.1 |
| Content: the jar's `assets/` verbatim (models, block states, item definitions, atlases, textures, colormaps, fonts, language, sounds as files) plus `pack.png` | 22 §6.1 |
| `pack.mcmeta`: written by the tool, description and format range 97.1 to 97.*, in the array form of 2.1 | 22 §6.2 |
| When it is present: the generated-pack check result `ok`; otherwise `absent`, `incomplete`, `stale` or `damaged` with a message | 22 §8.2, §9.2 |
| Regeneration, atomic replacement, `--verify` | 22 §6.3, §7.5, §7.6 |
| Reload: the client re-reads the pack on every resource reload; it does not watch the directory | 22 §8.1 |
| What it cannot hold: anything the jar does not contain (22 §2.9), and any content that is code (README R7) | 22 §10 |

Because the pack is a copy of the jar's own assets, everything in 2 to 9 applies to it as written (formats, atlases 7, colormaps 8, `.mcmeta`
rules). It uses bare or `minecraft:` ids (1.3). The block tint index is data in its models; the tint source and colour of each block is code
(Open question 10, 14 §9).

### 11.2 Pack order

The client's pack repository holds two built-in required packs below all user packs (22 §8.1). Both are fixed at the bottom: the player can neither
disable nor move them, so no user pack can end up below them (README C7).

| Level (bottom first) | Pack | Present when | Replaced by |
|---|---|---|---|
| 1 | `cobolcraft` built-in (10) | always | any higher pack on the same path |
| 2 | `vanilla` generated (11.1) | the generated-pack check is `ok` | levels 3 and 4 |
| 3 | User packs, in the order of `resourcePacks` in `options.txt`, from `<game directory>/resourcepacks/` (3.1, 13 §8). Faithful is here, never enabled by itself | enabled by the player | level 4 |
| 4 | Server-pushed packs (9.6) | the server sent them | nothing |

Rules.

1. A path is resolved top-down: the first pack from the top that holds it supplies it (3.2). Texture, model and language entries follow the same rule per
   path and per key.
2. **Level 2 wins over level 1** on a path that both hold. The two packs share very few paths: the built-in pack supplies `cobolcraft:` paths, the generated
   pack `minecraft:` paths. The shared ones are engine vocabulary (22 §9.1) and the language (10.8: standard keys in both files, the generated text wins).
3. Faithful and other `minecraft:` packs apply by path over the generated pack; they never touch a `cobolcraft:` path (world-types §6.4, 22 §9).
4. The same stack applies in both world types when the generated pack is valid; the isolation is by namespace (world-types Decision WT-15, 7.3).
5. A standard world type needs level 2. If it is not `ok`, the standard world type is disabled with the message of 22 §9.2, and the stack is level 1, 3, 4. A
   cobolcraft world runs on level 1 alone (22 §9.1).
6. Which texture is used for a block, item or entity of the standard world type when nothing in the stack holds it: the engine-generated missing texture (10, last paragraph).

### 11.3 Open points

The language fallback texts for standard keys (10.8.4, 10.8.6) and the zip-reader and format details are in Open questions 12 and 13.

## Open questions

1. ~~**Quadrant values.**~~ Resolved: the value modulo 360 must be 0, 90, 180 or 270 (`Quadrant.parseJson`).
2. ~~**Item `transformation` field.**~~ Resolved: a decomposed object or a 16-float matrix. Only the rotation sub-encodings in `ExtraCodecs` remain unexpanded.
3. **Item model dispatch key name.** The `type` key is inferred from the default of the DFU dispatch codec,
   which is not in the class tree.
4. ~~**Element Euler rotation order.**~~ Answered with CobolCraft's own rule (5.4.1). The element rotation is
   right-handed. The Euler form applies x, then y, then z (R = R_z · R_y · R_x, as JOML `rotationZYX`
   builds it). Rescale is defined for the single-axis form only. Whether the 26.3 client draws exactly the
   same result was not checked against a rendered reference. That matters only for packs that rotate
   elements, and the built-in pack does not.
5. **`shade_direction_override` and `light_emission` render effects.** Both are parsed and validated as
   described. Their exact visual effect is renderer policy and was not traced.
6. ~~**Default face UVs.**~~ Answered with CobolCraft's own formula (5.5.1). It gives the default `uv` per face
   direction from `from` and `to`, the corner assignment, and the face `rotation` rule. `FaceBakery` was
   not transcribed. The formula aligns each face with its place in the block, and the built-in pack's full
   cubes get [0, 0, 16, 16] under it.
7. **`pack_format` with a new-style range.** The precise check that applies when `min_format` major > 64
   and `pack_format` is also present was read only in outline (2.3).
8. **Required server packs and incompatible formats.** It is not confirmed whether a server pack whose range
   excludes 97.1 is loaded anyway (inferred yes: required packs bypass the compatibility prompt) or fails
   activation.
9. **Cache vacuum policy.** The criterion that `DownloadCacheCleaner` uses to choose victims (modification
   time versus log order) was not traced in detail.
10. ~~**Block tint indexes.**~~ Now a requirement. The tint index of a face (`tintindex`, 5.5) is data: the
    generated models carry it. Which tint source and colour each block uses (grass, foliage, dry foliage,
    water, constant) is code, keyed to the block, and the colour comes from the biome and the colormaps
    (14 §9). The client must implement that mapping for the standard world type (GAP-29). The rules are not
    yet written down.
11. ~~**Protocol-defined disconnect reasons.**~~ Answered: the server keeps the keys that 01, 02 and 05c
    fix (`multiplayer.disconnect.incompatible`, `…outdated_client`, `…transfers_disabled`, `…slow_login`,
    `…unexpected_query_response`, `…invalid_player_movement` and `disconnect.timeout`), and 10.8.4 gives
    each one its standard `en_us` text (generated pack in the standard world type, this file as fallback in the
    cobolcraft world type), so the client never shows a bare key for them. A pack can change these texts. The texts themselves are still missing (question 12).
12. **Standard texts of the fallback language set (GAP-27).** 10.8.4 gives no text for the seven protocol-defined disconnect reasons, and 10.8.6 does not
    say which `cobolcraft.screen.*` entries have a standard key. Until a clean-room round supplies them (README GAP-27) the cobolcraft world type shows
    the bare key for a disconnect reason when the generated pack is absent. The command and framework keys are covered by 15 §5 and 16.
13. **Index of standard `en_us` keys.** 11.1 relies on the generated `en_us` for every standard text; the engine reads keys that no document lists. The
    list of keys the engine looks up is open until the standard key survey (README GAP-27) is done.
