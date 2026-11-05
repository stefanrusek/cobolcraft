# 08 Resource packs

This document specifies the resource pack *format* that the 26.3 client reads (resource pack version
**97.1**), and how server-pushed packs flow on the wire. Our game reads the same format so that
creators can use existing tooling. Our packs target our own `cobolcraft:` namespace. Nothing here
describes or depends on vanilla asset content. We do not extract, bundle or list vanilla textures,
models or sounds.

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
bare `block/greystone` means `minecraft:block/greystone`.

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

Typical resulting order, bottom to top: the built-in default pack (required, fixed `BOTTOM`), then
user-selected packs in the user's order, then server-pushed packs (required, fixed `TOP`, section 9.6).

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
| `x`, `y`, `z` | Numbers (degrees) | alternative to `axis`/`angle` | Euler form. Each defaults to 0 once the form is chosen. Composed with JOML `rotationZYX` (inferred: the call order is z, y, x). |
| `rescale` | Boolean | no (false) | Scales the rotated element per axis so that it keeps spanning its original extent (inferred from `CuboidRotation.computeRescale`). |

If neither `axis`+`angle` nor any of `x`/`y`/`z` is present, the error is "Missing rotation value, expected
either 'axis' and 'angle' or 'x', 'y' and 'z'".

### 5.5 Face

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `texture` | String | **yes** | — | Usually `#slot`. |
| `uv` | Array of 4 numbers `[minU, minV, maxU, maxV]` | no | derived from the element bounds (inferred) | In sixteenths of the sprite. Exactly 4 values. |
| `cullface` | Direction name | no | none | The face is skipped when the neighbour in that direction hides it. |
| `rotation` | Integer: 0, 90, 180, 270 | no | 0 | Rotates the UV mapping. Same Quadrant rule: the value modulo 360 must be 0, 90, 180 or 270. |
| `tintindex` | Integer | no | −1 | −1 means no tint. Other values select a tint source (item tints are in 6.4. Block tints are fixed in client code). |

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
(`ItemTintSources`). The stand-in pack needs none.

---

## 7. Textures

### 7.1 Files

Textures are PNG files under `assets/<ns>/textures/`. The client decodes them into RGBA images
(`NativeImage.read`). An unreadable image is replaced with the missing texture ("Using missing texture,
unable to load"). Dimensions need not be powers of two. However, the smallest power of two that divides a
sprite's width and height limits the mipmap levels of the whole atlas ("limits mip level from … to …"),
so 16 × 16 or other power-of-two sizes are recommended. The maximum atlas size is the GPU limit.

### 7.2 Atlases

Sprites used by models are packed into **atlases**. The set of atlases is fixed by the client
(`AtlasManager`): there are twelve, each with a definition id. The two a block game needs are:

| Atlas | Definition file **[engine name]** | Used by |
|---|---|---|
| Block atlas | `assets/minecraft/atlases/blocks.json` | All block models. Item models may also use it. |
| Item atlas | `assets/minecraft/atlases/items.json` | Item models. |

A sprite id that appears in two atlases produces a warning ("Duplicate sprite … This will be rejected in
a future version").

### 7.3 Atlas definition files

Path: `assets/<ns>/atlases/<atlas>.json` (`SpriteSourceList`, directory `atlases`). **Definitions are
merged across all packs** (3.2): every pack's copy is parsed, and their source lists are concatenated
from the bottom pack upwards. A pack therefore *adds* sprites by shipping a definition with only its own
sources.

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

All paths are under `assets/<ns>/`. "Minimal" marks what the first milestone of our client needs.

| Path | Purpose | Minimal |
|---|---|---|
| `blockstates/<block>.json` | State → model mapping (4). | **yes** |
| `models/**/<name>.json` | Geometry and texture slots (5). | **yes** |
| `items/<item>.json` | Item model definition (6). | **yes** |
| `textures/**/<name>.png` (+ `.png.mcmeta`) | Images (7). | **yes** |
| `atlases/<atlas>.json` | Sprite sources per atlas (7.3). The ids are fixed by the client. | **yes** (block and item atlases) |
| `lang/<code>.json` | A JSON object mapping translation key to string. Values may use `%s` and `%1$s` placeholders; numeric `%d`/`%f` placeholders are rewritten to `%s` on load. Keys for registry content follow `<kind>.<namespace>.<path with / replaced by .>`, for example `block.cobolcraft.greystone` (`Util.makeDescriptionId`). | **yes** (`en_us`) |
| `sounds.json` | Sound event → sound file list. | later |
| `sounds/**/<name>.ogg` | Ogg audio files. | later |
| `font/<id>.json` | Font provider definitions. | later (needed for text) |
| `particles/<id>.json` | Particle sprite lists. | later |
| `equipment/<id>.json` | Worn-equipment layer textures. | later |
| `shaders/**` (`.json`, `.vsh`, `.fsh`, `include/*.glsl`) | GLSL programs. | not applicable (our Vulkan client) |
| `post_effect/<id>.json` | Post-processing chains (named by the Post Effects packet, 03). | later |
| `waypoint_style/<id>.json` | Locator-bar waypoint styles. | later |
| `textures/colormap/*.png` | Biome colour lookup images. | later |
| `textures/palettes/*.png` | Palettes for `paletted_permutations` (7.3). | later |
| `texts/*` | Plain-text resources such as the title-screen splash list. | later |

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
| 4. Prompt screen | The text depends on `required`. If a Prompt component was sent, it is appended to the standard text (key `multiplayer.texturePrompt.serverPrompt`). **Accept** stores *enabled* for the server and allows server packs. **Decline** stores *disabled* and rejects server packs. If the pack was required, the client also **disconnects itself** with `multiplayer.requiredTexturePrompt.disconnect`. Several pushes that arrive while the screen is open are merged into one screen. |
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

---

## 10. Stand-in default pack

The procedural textures in [../design/standin-content.md](../design/standin-content.md) §1.4 and §2 can be
expressed as a built-in pack named `cobolcraft`. The texture generator then writes PNG files (or serves
them from memory through a pack source) at the paths below, and the renderer reads only pack data. A user
or server pack replaces any file by shipping the same path (3.2). The built-in pack sits at the bottom of
the stack, required and fixed at `BOTTOM` (inferred to mirror the client's own built-in pack).

The missing texture (orange and black stripes) stays engine-generated. It is not a pack file. The client's
own missing sprite is also code-generated (`MissingTextureAtlasSprite`).

### 10.1 Root

`pack.mcmeta`:

| Key path | Value |
|---|---|
| `pack.description` | String "CobolCraft stand-in default pack" |
| `pack.min_format` | 97 |
| `pack.max_format` | 97 |

`pack.png`: optional. For example, the ledger_tile texture scaled up.

### 10.2 Atlas definitions

These two files are **[engine name]** paths. A pack adds its sprites to the fixed atlases this way.

| File | `sources` |
|---|---|
| `assets/minecraft/atlases/blocks.json` | One entry: `type` = `directory`, `source` = `block`, `prefix` = `block/` |
| `assets/minecraft/atlases/items.json` | One entry: `type` = `directory`, `source` = `item`, `prefix` = `item/` |

Because `directory` scans every namespace, these entries pick up `assets/cobolcraft/textures/block/*.png`
as sprites `cobolcraft:block/<name>`, and `textures/item/*.png` as `cobolcraft:item/<name>`.

### 10.3 Textures

All are 16 × 16 RGBA PNG. The recipes are those of standin-content §1.4 and §2. No `.mcmeta` is needed.

| File (under `assets/cobolcraft/textures/`) | Sprite id | Recipe (standin-content) |
|---|---|---|
| `block/baseplate.png` | `cobolcraft:block/baseplate` | baseplate, all |
| `block/greystone.png` | `cobolcraft:block/greystone` | greystone, all |
| `block/loam.png` | `cobolcraft:block/loam` | loam, all (also used as the turf bottom) |
| `block/turf_top.png` | `cobolcraft:block/turf_top` | turf, top |
| `block/turf_side.png` | `cobolcraft:block/turf_side` | turf, sides |
| `block/grit.png` | `cobolcraft:block/grit` | grit, all |
| `block/cardstack_end.png` | `cobolcraft:block/cardstack_end` | cardstack, ends |
| `block/cardstack_side.png` | `cobolcraft:block/cardstack_side` | cardstack, sides, punched = false |
| `block/cardstack_side_punched.png` | `cobolcraft:block/cardstack_side_punched` | cardstack, sides, punched = true |
| `block/lucite.png` | `cobolcraft:block/lucite` | lucite, all. Its partial alpha puts its faces in the translucent layer automatically (5.3). |
| `block/glowtube_lit.png` | `cobolcraft:block/glowtube_lit` | glowtube, lit |
| `block/glowtube_unlit.png` | `cobolcraft:block/glowtube_unlit` | glowtube, unlit |
| `block/ledger_tile.png` | `cobolcraft:block/ledger_tile` | ledger_tile, all |
| `item/pry_bar.png` | `cobolcraft:item/pry_bar` | pry_bar icon |
| `item/trowel.png` | `cobolcraft:item/trowel` | trowel icon |

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
| `elements[0].faces.<dir>` for each of down, up, north, south, west, east | `texture` = `#<dir>`, `cullface` = `<dir>` (no `uv`: derived from the bounds) |

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
| `cobolcraft:block/void` (optional) | none | none. No `elements`, so it has no geometry. |

Optional: `glowtube_lit` may instead copy the `template_box` element with `light_emission` 15, so that its
faces draw at full brightness. World light still comes from the block's light level (standin-content §1.1),
not from the model.

Lucite culling between two lucite blocks (standin-content §1.1) is renderer policy for same-block
neighbours. `cullface` only marks which neighbour may hide a face.

### 10.6 Block state files

Under `assets/cobolcraft/blockstates/`. Each uses `variants`.

| File | Variant key → Variant |
|---|---|
| `baseplate.json`, `greystone.json`, `loam.json`, `turf.json`, `grit.json`, `lucite.json`, `ledger_tile.json` | `""` → `model` = `cobolcraft:block/<same name>` |
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

`uvlock` stays false, so the card-edge lines turn with the stack. These keys cover the 16 states in
standin-content §1.2 exactly once, so there is no overlap error.

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

No `display` entries are needed for our client, which applies its own hand and GUI placement. A later pack
can add them (5.6).

Item definitions under `assets/cobolcraft/items/`:

| File | `model.type` | `model.model` |
|---|---|---|
| `<item>.json` for each of the 11 items above | `minecraft:model` | the item model id from the table above |
| `nothing.json` (optional) | `minecraft:empty` | none |

The other top-level fields keep their defaults (6.1).

### 10.8 Language

`assets/cobolcraft/lang/en_us.json` maps translation keys to names. The key form is
`<kind>.<namespace>.<path>` (section 8):

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
| `item.cobolcraft.pry_bar` | Pry Bar |
| `item.cobolcraft.trowel` | Trowel |

Whether a block item is named by its block key or by an `item.*` key is item-registry behaviour, outside
this document. Shipping both forms costs nothing (inferred safe choice).

### 10.9 File count

1 `pack.mcmeta`, 2 atlas definitions, 15 PNGs, 4 template models, 11 block models (12 with void), 11 item
models, 9 block state files (10 with void), 11 item definitions (12 with nothing), and 1 language file.

---

## Open questions

1. ~~**Quadrant values.**~~ Resolved: the value modulo 360 must be 0, 90, 180 or 270 (`Quadrant.parseJson`).
2. ~~**Item `transformation` field.**~~ Resolved: a decomposed object or a 16-float matrix. Only the rotation sub-encodings in `ExtraCodecs` remain unexpanded.
3. **Item model dispatch key name.** The `type` key is inferred from the default of the DFU dispatch codec,
   which is not in the class tree.
4. **Element Euler rotation order.** The `x`/`y`/`z` element rotation is built with JOML `rotationZYX`. The
   exact composition order and handedness should be checked against a rendered reference before our
   renderer relies on it.
5. **`shade_direction_override` and `light_emission` render effects.** Both are parsed and validated as
   described. Their exact visual effect is renderer policy and was not traced.
6. **Default face UVs.** When `uv` is absent, UVs are computed from the element bounds and face direction.
   The exact formula is in `FaceBakery` and was not transcribed.
7. **`pack_format` with a new-style range.** The precise check that applies when `min_format` major > 64
   and `pack_format` is also present was read only in outline (2.3).
8. **Required server packs and incompatible formats.** It is not confirmed whether a server pack whose range
   excludes 97.1 is loaded anyway (inferred yes: required packs bypass the compatibility prompt) or fails
   activation.
9. **Cache vacuum policy.** The criterion that `DownloadCacheCleaner` uses to choose victims (modification
   time versus log order) was not traced in detail.
10. **Block tint indexes.** Which tint index produces which colour for blocks is fixed in client code and
    keyed to vanilla blocks. Our client needs its own policy if tinted faces are wanted.
