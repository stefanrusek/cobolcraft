# 14 Texture-only resource packs

This document specifies how the 26.3 client resolves **textures**: which files it asks for, how the
atlases collect them, how texture size differences, animation, GUI scaling, colormaps and fonts are
handled, and what a pack that ships only PNG files (and `.mcmeta` files) must therefore provide. It adds to
[08-resource-packs.md](08-resource-packs.md) (pack container, stacking, atlas definition format) and does not
repeat it. The pack stack order, how a pack such as Faithful layers on the generated and built-in packs, and the optional skin
that points the cobolcraft world type's content at it are a design matter and live in
[../design/faithful-pack-mapping.md](../design/faithful-pack-mapping.md).

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (resource pack version 97.1). This is the artifact already recorded in [README.md](README.md). |
| Second input (data) | The operator's resource pack `Faithful 32x - 26.3.zip`, SHA-256 `596035002e8c369ca673b5b922cd532a38a2aaabe80f317f5ac4d5c7680c7bf2`. It is third-party data. It was read with `unzip -l` and `unzip -p` and a PNG header reader (width and height only). Nothing in it was executed. The pack facts are in §14 and in the design document. |
| Method | Static reading of the shipped bytecode (`javap`), with no execution; resource listings of the jar (`unzip -l`) for directory structure and counts only. The jar's own images are not reproduced or listed here. |

Class names are cited in backticks to say where a fact was read. They are not the design.

Because this document describes what the **client asks for**, it names path families and sprite ids of
the `minecraft:` namespace. They are engine vocabulary (08 intro): a pack has to use them. The document
describes families, rules and counts, not a catalogue of the jar's images.

---

## 1. What "texture-only" means

A pack that has no `blockstates/`, `models/`, `items/`, `atlases/`, `lang/`, `font/*.json`, `particles/*.json`,
`equipment/*.json` or `post_effect/` files is **texture-only**. For the client, every such data file is a
resource like any other and is resolved by the stack (08 3.2). A texture-only pack therefore relies on the
packs below it for all data files. The consequences:

| Kind of file | Where it comes from when the pack lacks it | Section |
|---|---|---|
| Block states, models, item definitions | Lower packs: the built-in pack. They name the sprite ids that the pack's PNG files then fill. | 3.4 |
| Atlas definitions (`atlases/*.json`) | **Merged** across all packs (08 7.3): a pack with none adds no sources. The built-in definitions' `directory` sources scan every namespace, so the pack's PNG files are picked up with no definition of its own. | 3 |
| Language files | Lower packs. | |
| Font definitions (`font/<id>.json`) | Lower packs. The pack's font PNG files are used only if a provider of a definition names them. | 10 |
| Particle definitions (`particles/<id>.json`) | Lower packs. The pack's particle PNG files are used when a definition names their sprite ids. | 7 |
| Colormaps, palettes | PNG files under `textures/colormap/` and `textures/palettes/`. A texture-only pack may omit them, and then the lower pack's copy is used. | 9, 7.4 |

A **texture** of a texture-only pack is used in exactly one way: some data file (model, item definition, particle
definition, equipment definition, font definition, atlas definition) or some client code names its id, and the
file `assets/<ns>/textures/<path>.png` is looked up in the stack from the top.

---

## 2. Identifiers and lookup

### 2.1 Id to file

| Kind of id | Rule | Example (shape only) |
|---|---|---|
| **Sprite id** (a texture slot in a model, a particle texture, a GUI sprite) | The sprite `ns:p` belongs to an atlas. Its file is `assets/ns/textures/<atlas source directory>/<rest>.png`, where `p` = `<atlas prefix><rest>`. See 3.2. | block sprite `minecraft:block/x` has file `assets/minecraft/textures/block/x.png` |
| **Whole-image texture id** (entity textures, environment, colormap, font images, container sheets, misc) | Code names `ns:textures/<path>.png` (or `ns:<path>` and adds `textures/` in front and `.png` at the end). The image is loaded as it is, with its own dimensions, not packed in an atlas. | `textures/entity/<family>/<name>.png`, `textures/environment/rain.png` |
| **Font bitmap file** | The provider's `file` is an id relative to `textures/` including `.png` (`BitmapProvider$Definition`: prefix `textures/`). | `file` = `minecraft:font/ascii.png` |
| **Equipment layer** | `equipment/<id>.json` names layer types and texture ids. The file is `textures/entity/equipment/<layer type>/<texture id path>.png` (inferred from the 85 files of that family and the class `EquipmentLayerRenderer`; not traced end to end). | |

An id without a namespace is `minecraft:`. Everything the client **hard-wires** is in `minecraft:`: the
atlas definition ids, the fixed texture paths of 8, the colormaps and the vanilla font definition ids. Data
files of a pack may name any namespace.

### 2.2 Namespaces are enumerated

For an atlas `directory` source (3.3) and for every directory listing, the client queries **all namespaces
of all packs** (08 1.3: the union over packs of the directory names under `assets/`). A namespace with an
invalid name is ignored in whole. So a pack may carry `minecraft:` assets next to `cobolcraft:`, `forge:`
and so on, and all of them are enumerated:

- A `directory` source over `block` adds `ns:block/<rest>` for the `block` textures of every namespace.
- A file that is fixed by name (a colormap, `environment/rain.png`) is looked up only in the namespace that
  the client code names, always `minecraft`.
- A namespace that nothing names, and whose files are outside every scanned directory, is loaded
  into no atlas and costs nothing. A file inside a scanned directory of an unrelated namespace (for
  example `forge:item/mask/x` under the item directory) is added to the atlas as an extra sprite that no
  model uses.

### 2.3 Lookup order

All lookups follow 08 3.2: the top pack that has the file wins. Two details for textures:

1. A PNG file **and its companion `.mcmeta`** are two separate lookups (12). The PNG comes from the highest
   pack that has it. The `.mcmeta` is searched from the top pack down to, and including, the pack that
   supplied the PNG, and the first pack with a `.mcmeta` for that path wins. A pack *below* the PNG's pack is
   never consulted. If none above or at that pack has one, the sprite has no metadata (stretch scaling,
   no animation). The class is `FallbackResourceManager` (`createStackMetadataFinder`). This refines 08 7.4,
   which says "from the same pack".
2. A missing file is not an error for atlas sprites that are only named by data (the missing texture
   sprite is used, with a log line "Missing sprite"), and an unreadable image is replaced by the missing
   texture (08 7.1).

---

## 3. Atlases

### 3.1 The twelve atlases

`AtlasManager` registers the atlases below. Each has a definition id (a file `atlases/<name>.json`, merged
across packs) and a texture location (`textures/atlas/<name>.png`, a runtime texture, not a pack file).

| Atlas (definition id) | Sources in the shipped definition (type, source directory, id prefix) | Sprite ids it yields | Used by |
|---|---|---|---|
| `blocks` | `directory` `block` prefix `block/`; `directory` `entity/conduit` prefix `entity/conduit/`; `single` the bell body (`entity/bell/bell_body`); `single` the enchanting-table book (`entity/enchantment/enchanting_table_book`) | `ns:block/<rest>` etc. | All block models; item models may also use it (08 5.3); the break-stage overlays (4.3); the four single-sprite block-entity pieces named in the sources. |
| `items` | `directory` `item` prefix `item/`; one `paletted_permutations` source (see 7.4) for the four armour-trim item overlays | `ns:item/<rest>` | Item models. |
| `gui` | `directory` `gui/sprites` prefix empty; `directory` `mob_effect` prefix `mob_effect/` | `ns:<rest>` where the file is `textures/gui/sprites/<rest>.png`, and `ns:mob_effect/<rest>` for `textures/mob_effect/<rest>.png` | Every GUI sprite (6), the status effect icons. |
| `celestials` | `directory` `environment/celestial` prefix empty | `sun`, `end_flash`, `moon/<phase>` (8.1) | The sky renderer. |
| `particles` | `directory` `particle` prefix empty | `ns:<name>` | Particles (7.1). |
| `map_decorations` | `directory` `map/decorations` prefix empty | `ns:<name>` | Map icons (7.3). |
| `paintings` | `directory` `painting` prefix empty | `ns:<name>` | Paintings (7.2). |
| `chests` | `directory` `entity/chest` prefix `entity/chest/` | `ns:entity/chest/<name>` | Chest block entities. |
| `banner_patterns` | `directory` `entity/banner` prefix `entity/banner/` | | Banners. |
| `shield_patterns` | `directory` `entity/shield` prefix `entity/shield/` | | Shields. |
| `shulker_boxes` | `directory` `entity/shulker` prefix `entity/shulker/` | | Shulker boxes. |
| `decorated_pot` | `directory` `entity/decorated_pot` prefix `entity/decorated_pot/` | | Decorated pots. |

Read from the twelve `assets/minecraft/atlases/*.json` files of the jar. The atlas set is fixed in code
(`AtlasManager.KNOWN_ATLASES`); a pack cannot add one. A sprite id that appears in two atlases produces a
"Duplicate sprite" warning (08 7.2).

Two atlas sprite ids exist that are not file-derived: the **missing texture** sprite (code-generated, 16 x 16
magenta (`#F800F8`) and black pattern in the shipped client, `MissingTextureAtlasSprite`), which every atlas contains and
which stands in for any sprite that fails to load.

### 3.2 Sprite id and file rule

For a `directory` source with `source` S and `prefix` X, and a file `assets/ns/textures/S/R.png` (R may
contain `/`), the sprite id is `ns:X` + `R`. The `.png` suffix is mandatory (`DirectoryLister` filters on
it). All namespaces are scanned (2.2).

Worked examples (shapes): with the `blocks` definition, `assets/minecraft/textures/block/a/b.png` becomes
`minecraft:block/a/b`; `assets/cobolcraft/textures/block/c.png` becomes `cobolcraft:block/c`. With the `gui`
definition, `assets/minecraft/textures/gui/sprites/hud/x.png` becomes `minecraft:hud/x` and
`assets/minecraft/textures/mob_effect/y.png` becomes `minecraft:mob_effect/y`.

### 3.3 Atlas source types

The five types of 08 7.3 are the whole set (`SpriteSources`: `single`, `directory`, `filter`, `unstitch`,
`paletted_permutations`). In the shipped definitions only `directory`, `single` and
`paletted_permutations` occur. Additional notes:

- Sources run in order into one map from sprite id to image. A later add with the same id replaces the earlier.
- Because definitions are merged bottom-up (08 7.3), the shipped `blocks` and `items` definitions in the
  built-in pack are enough to scan a user pack's files. A texture-only user pack ships none.
- `filter` is the only way to remove an earlier sprite.

### 3.4 What the built-in pack must still supply

For a texture-only user pack to work, the pack below it must define: the models, block states and item
definitions that name the sprite ids; the atlas definitions of 3.1 for the atlases our client uses; the
language file; font definitions; particle definitions (if particles are drawn); and the colormaps (9).

### 3.5 Sprites of different sizes in one atlas

All sprites of one atlas may have different sizes. The client does **not** rescale any sprite
(`SpriteLoader`, `Stitcher`):

1. Each sprite keeps its own pixel size (for an animated sprite, the size of one frame, see 11).
2. The mip level count of the whole atlas is limited by the smallest power-of-two divisor over all sprites:
   for every sprite, take the lowest set bit of its width and of its height; the smaller of those over all
   sprites, as log2, is the upper bound of the atlas mip level. For 16 x 16 and 32 x 32 sprites together it
   is 4 (from 16). A sprite whose width or height has a small power-of-two factor (for example 20) lowers
   it, with the warning "limits mip level". The requested level is `min(requested, bound)`.
3. The stitcher registers each sprite with its width and height plus a padding on each side, rounded up to a
   multiple of 2^(mip level), sorts by size and packs it into rectangles. The atlas grows to the next
   power of two in x and y until all sprites fit, within the GPU's maximum texture size. A sprite that
   cannot be placed is a fatal stitch error ("Stitching", listing all sprites). The padding amount is
   (1 << M) << clamp(A - 1, 0, 4) per side, with M the atlas mip level and A the anisotropy bit (0 unless
   anisotropic filtering is on); 16 pixels at the defaults. That formula is from 12 §2.2 and agrees with the
   clamp-and-shift in the `Stitcher` constructor.
4. Each sprite's UV rectangle is its placement as a fraction of the atlas size. A model face with UV
   [u0, v0, u1, v1] in model texels (0 to 16) maps it onto the sprite's own rectangle as a fraction, so a
   32 x 32 sprite fills a face exactly like a 16 x 16 one. **A sprite of any size is drawn on the same
   geometry**; only its resolution changes.
5. Mixing sizes is therefore safe. A 16 x 16 built-in sprite and a 32 x 32 user sprite for different ids can
   share one atlas, and a user sprite replaces a built-in sprite of another size with no UV change.
6. Sprites need not be square. A static sprite may have any width and height. An animated sprite must be
   a vertical strip (or grid) of equal frames (11).

---

## 4. Block and item textures

### 4.1 Block textures

Block faces name sprites in the `blocks` atlas through the `textures` map of a model (08 5.3). The family
is `textures/block/<name>.png` and the sprite id is `ns:block/<name>`. Subdirectories are allowed.

Colour tinting is **not** in the PNG: a face with a `tintindex` is multiplied by a colour that the client
computes (9, 4.4). The PNG of a tinted block is a grey-scale template.

Mip strategy and filtering for a sprite come from its `texture` section (08 7.4). Transparent-edge sprites
(glass, leaves) use `mipmap_strategy`.

### 4.2 Item textures

Item models of type `builtin/generated` name one to five `layerN` sprites (08 5.7). The family is
`textures/item/<name>.png`; sprite id `ns:item/<name>`; subdirectories allowed. A layer may also name a
`block/` sprite (08 10.7).

### 4.3 Block break overlay

The progress of breaking a block is drawn with ten overlay sprites in the `blocks` atlas: ids
`minecraft:block/destroy_stage_0` to `destroy_stage_9` (`ModelBakery`, `DESTROY_STAGE_COUNT` = 10). A second
set of ten, `minecraft:block/destroy_oit_stage_0` to `destroy_oit_stage_9`, exists for the
order-independent-transparency render path. Which set is chosen is untraced (Open question 3). The
sprites are mostly transparent, with a crack pattern, 8-bit grey with alpha. The destroy stage index is 0 to 9.
The overlay is drawn with the crumbling blend (12 §4.3): the result is 2 x source x destination colour,
so a mid-grey (0.5) pixel leaves the block unchanged, darker pixels darken it, and fragments whose texture alpha times vertex alpha is below 0.1 are discarded (12 §4.3). The texture is projected once per block face, so its resolution is free.

### 4.4 Tinting

Block and item tint colours are computed by the client (colormaps, biome colours, item tint sources of
08 6.4). Water colour is not a colormap: it comes from the biome's data (the biome effects of 04 and the
worldgen data), not from a texture.

---

## 5. Entity textures

### 5.1 Path rule

Entity textures are **whole-image** textures (not atlas sprites) at `textures/entity/...`. The shipped
client names 285 distinct entity texture paths in code (found as string constants), arranged in
families by directory. The pack inventory (§14) shows the same directory families. The rules:

| Rule | Detail |
|---|---|
| One file per look | Variants (colour, age, biome) are separate files in the family's directory. A baby has its own file. |
| Layers | A model layer that is drawn over the base has its own file next to it. Observed suffix families: `_overlay`, `_outer_layer`, `_armor` (the five files are the creeper and wither charge layers and three wolf armour crackiness levels), `_wool` and `_wool_undercoat`, `_eyes` (glowing eyes, drawn bright). Armour, saddles and harnesses are not suffix files: they are under `entity/equipment/<layer type>/` (2.1), where `_saddle` and `_body` appear only in directory names. |
| Players | Default skins are `entity/player/wide/<name>.png` and `entity/player/slim/<name>.png`, nine names each (the `wide` and `slim` arm widths). A skin sent by a server replaces them. |
| Block entities | Chests, banners, shields, shulker boxes and pots use an atlas (3.1) rather than whole images. |
| Not an atlas | Entity files are loaded directly. They are not in `blocks`, except the four named sources of 3.1. |

### 5.2 Texture size and UV

An entity model is defined in **model texels**: each part's boxes name a texture offset (u, v) and a size,
and the layer definition declares the texture's width and height in those texels (`LayerDefinition.create`
takes the two integers). The client divides texel coordinates by that declared size to get UV fractions
(`ModelPart$Cube`, `ModelPart$Polygon`). Therefore:

- A pack texture of **any whole-number multiple** of the declared size (the 32x pack: exactly 2 x in both
  directions) is sampled at the same fractions and lines up. The client never reads the image's own size.
- A texture with a **different aspect ratio** is distorted. A texture at a smaller scale is blurred.
- The file's actual size need not match for the client to run.

### 5.3 Box UV layout (the standard unwrap)

For a box of size w x h x d placed at texture offset (u, v), the six faces occupy these rectangles
(inferred from the standard model layout; verified against the constants of three models below, not by
transcribing the `Cube` constructor):

| Face | Top-left (x, y) | Size |
|---|---|---|
| top (+y) | (u + d, v) | w x d |
| bottom (-y) | (u + d + w, v) | w x d |
| side on the left of the front rectangle | (u, v + d) | d x h |
| front | (u + d, v + d) | w x h |
| side on the right of the front rectangle | (u + d + w, v + d) | d x h |
| back | (u + 2d + w, v + d) | w x h |

The strip is `2d + 2w` wide and `d + h` tall. The orientation of each face (which edge is up) follows the usual
convention; an implementation that needs pixel-exact orientation must compare against a reference render
(Open question 4).

### 5.4 Model constants of the three standard models (player, cow, slime)

Read from the model classes. Units are model texels; boxes are given as origin (x, y, z) and size (w, h, d); texture offsets (u, v).

| Model (class) | Texture size | Part | Texture offset | Box origin | Box size |
|---|---|---|---|---|---|
| Player / humanoid (`HumanoidModel`, `PlayerModel`) | 64 x 64 | head | (0, 0) | (-4, -8, -4) | 8 x 8 x 8 |
| | | hat (overlay) | (32, 0) | (-4, -8, -4), grow 0.5 | 8 x 8 x 8 |
| | | body | (16, 16) | (-4, 0, -2) | 8 x 12 x 4 |
| | | right arm | (40, 16) | (-3, -2, -2) wide, (-2, -2, -2) slim | 4 x 12 x 4 wide, 3 x 12 x 4 slim |
| | | left arm | (32, 48) (the layout of the lower half) | (-1, -2, -2) | 4 or 3 x 12 x 4 |
| | | right leg | (0, 16) | (-2, 0, -2) | 4 x 12 x 4 |
| | | left leg | (16, 48) | (-2, 0, -2) | 4 x 12 x 4 |
| | | jacket, sleeves, pants (second skin layer, grow 0.25) | body (16, 32); right sleeve (40, 32); left sleeve (48, 48); right pants (0, 32); left pants (0, 48) | as the base part | as the base part |
| Cow (`CowModel`, `createBaseCowModel`) | 64 x 64 | head | (0, 0) | (-4, -4, -6) | 8 x 8 x 6 |
| | | snout | (1, 33) | (-3, 1, -7) | 6 x 3 x 1 |
| | | horns | (22, 0) | right (-5, -5, -5), left (4, -5, -5) | 1 x 3 x 1 |
| | | body (rotated 90 degrees about x) | (18, 4) | (-6, -10, -7) | 12 x 18 x 10 |
| | | udder | (52, 0) | (-2, 2, -8) | 4 x 6 x 1 |
| | | four legs | (0, 16) | (-2, 0, -2) | 4 x 12 x 4 |
| Slime (`SlimeModel`) | 64 x 32 | outer shell | (0, 0) | (-4, 16, -4) | 8 x 8 x 8 |
| | | inner body | (0, 16) | (-3, 17, -3) | 6 x 6 x 6 |
| | | eyes | (32, 0) and (32, 4) | (-3.25, 18, -3.5) and (1.25, 18, -3.5) | 2 x 2 x 2 |
| | | mouth | (32, 8) | (0, 21, -3.5) | 1 x 1 x 1 |

(In the slime model the outer and inner shells are two layer definitions; the outer one is drawn translucent.)

---

## 6. GUI textures

The client draws the GUI two ways. Both are independent of the pixel size of the image.

### 6.1 GUI sprites (the `gui` atlas)

Sprite ids are the path under `textures/gui/sprites/`. The ids the client asks for, by group (from the string
constants of the `Hud`, `AbstractContainerScreen`, widget and recipe-book classes; this is the list our
client needs, not every sprite of the jar):

| Group | Sprite ids (relative to `gui/sprites/`) |
|---|---|
| Hotbar | `hud/hotbar`, `hud/hotbar_selection`, `hud/hotbar_offhand_left`, `hud/hotbar_offhand_right`, `hud/hotbar_attack_indicator_background`, `hud/hotbar_attack_indicator_progress` |
| Crosshair | `hud/crosshair`, `hud/crosshair_attack_indicator_background`, `hud/crosshair_attack_indicator_progress`, `hud/crosshair_attack_indicator_full` |
| Health and food | `hud/heart/container`, `hud/heart/full`, `hud/heart/half`, and each with the `_blinking` suffix (flash on damage); `hud/heart/vehicle_*`; `hud/food_empty`, `hud/food_half`, `hud/food_full` and the `_hunger` variants of each; `hud/armor_empty`, `hud/armor_half`, `hud/armor_full`; `hud/air`, `hud/air_empty`, `hud/air_bursting` |
| Status effects | `hud/effect_background`, `hud/effect_background_ambient`, and `mob_effect/<name>` (the `mob_effect` atlas source) |
| Container slots | `container/slot` (slot background), `container/slot_highlight_back`, `container/slot_highlight_front`; empty-slot icons `container/slot/<kind>` (for example helmet) |
| Buttons and fields | `widget/button`, `widget/button_highlighted`, `widget/button_disabled`; `widget/text_field`, `widget/text_field_highlighted`; `widget/slider`, `widget/slider_highlighted`, `widget/slider_handle`, `widget/slider_handle_highlighted`; `widget/checkbox`, `widget/checkbox_highlighted`, `widget/checkbox_selected`, `widget/checkbox_selected_highlighted`; `widget/scroller`, `widget/scroller_background`; `widget/locked_button*`, `widget/unlocked_button*` |
| Tooltips and popups | `tooltip/background`, `tooltip/frame`, `popup/background` |
| Recipe book | `recipe_book/button`, `recipe_book/button_highlighted`, `recipe_book/tab`, `recipe_book/tab_selected`, `recipe_book/slot_craftable`, `recipe_book/slot_many_craftable`, `recipe_book/slot_uncraftable`, `recipe_book/slot_many_uncraftable`, `recipe_book/page_backward`, `recipe_book/page_forward` (each also `_highlighted`), `recipe_book/filter_enabled`, `recipe_book/filter_disabled` (each also `_highlighted`), `recipe_book/overlay_recipe`, `recipe_book/crafting_overlay` (with `_highlighted`, `_disabled`, `_disabled_highlighted`), `recipe_book/furnace_*` |
| Boss bars | `boss_bar/<colour>_background` and `<colour>_progress`, and `notched_<n>_*` |
| Other screens | `pause_menu/*`, `player_list/*`, `icon/*`, `notification/*`, `toast/*`, `spectator/*`, `advancements/*`, `social_interactions/*`, `server_list/*`, `world_list/*` and so on |

Sprites are stretched, tiled or nine-sliced as their `.mcmeta` says (6.3).

### 6.2 Whole-image GUI textures

These are loaded as whole images and blitted from a rectangle:

| File (`textures/gui/...`) | Used by |
|---|---|
| `container/inventory.png` | The player inventory screen (`AbstractContainerScreen`, `InventoryScreen`). |
| `container/crafting_table.png` | The 3 x 3 crafting screen. |
| `container/generic_54.png`, `dispenser`, `hopper`, `furnace`, `blast_furnace`, `smoker`, `anvil`, `beacon`, `brewing_stand`, `cartography_table`, `crafter`, `enchanting_table`, `grindstone`, `horse`, `loom`, `nautilus`, `shulker_box`, `smithing`, `stonecutter`, `villager`, `gamemode_switcher`, `creative_inventory/tab_*` | The corresponding screens. |
| `recipe_book.png` | The recipe book (the book's sheet). |
| `book.png` | The written book screen. |
| `menu_background.png`, `menu_list_background.png`, `inworld_menu_background.png`, `inworld_menu_list_background.png`, `header_separator.png`, `footer_separator.png`, `inworld_header_separator.png`, `inworld_footer_separator.png`, `tab_header_background.png` | Menu screens (tiled). |
| `title/minecraft.png`, `title/edition.png`, `title/mojangstudios.png`, `title/background/panorama*`, `title/realms.png` | The title screen and loading overlay. |
| `advancements/window.png`, `signs/*`, `hanging_signs/*` | Those screens. |

The client blits a rectangle of such an image with the **logical sheet size** passed by the caller (256 x 256
for most screens; 512 x 256 for the villager screen). The texture coordinates are rectangle position divided
by that logical size (`GuiGraphicsExtractor.blit` with texture width and height arguments). **A sheet at twice the
logical size works unchanged**, provided it keeps the aspect ratio and the layout. The shipped sheets
are 256 x 256; the pack's are 512 x 512 (§14).

Standard container geometry (read from `AbstractContainerScreen` and `InventoryMenu`): the screen's image area
is **176 x 166** logical pixels, drawn at the top-left of the sheet; the sheet is addressed as 256 x 256.

| Element on the inventory screen | Position in the 176 x 166 image area | Notes |
|---|---|---|
| 2 x 2 crafting grid | first slot at (98, 18), 18 pixel pitch in both directions | `InventoryMenu` |
| Crafting result slot | (154, 28) | |
| Armour slots (4) | (8, 8 + 18 x i), i = 0 to 3 | |
| Off-hand slot | (77, 62) | |
| Main inventory (27) | origin (8, 84), 9 columns, 18 pixel pitch | |
| Hotbar (9) | origin (8, 142) (84 + 58) | |

Slot pitch 18 and item size 16 are logical pixels. The 3 x 3 crafting table adds a 3 x 3 grid and its result;
those numbers were not read (Open question 5).

### 6.3 Scaling of a sprite (`gui` section)

Every sprite has a scaling mode from its `.mcmeta` `gui.scaling` (08 7.4): `stretch` (the default, with no
`.mcmeta`), `tile`, or `nine_slice`. Findings:

- The `width`/`height` of `tile` and `nine_slice` are **logical** sizes in GUI pixels. They are not the
  image's pixel size. The border values are in the same logical units.
- When the sprite is blitted into a destination rectangle, the client converts each part to texture
  coordinates by dividing the part's logical position by the logical `width`/`height`
  (`blitSprite` with sprite width and height arguments: u = x / width). The image may therefore have any
  resolution, as long as its aspect ratio equals logical width : logical height.
- Nine-slice: the four borders are limited to half the destination width or height. When the destination
  size equals the logical size the sprite is drawn in one piece. The inner parts are tiled along each axis
  unless `stretch_inner` is true (then they are stretched).
- A sprite with no scaling section is stretched over the whole destination. Its pixel size is irrelevant.
- A pack that supplies its own `.mcmeta` for a sprite can set a different logical size (the pack's own
  files do for several tooltip and effect sprites). The client uses whatever `.mcmeta` the stack (2.3) yields.
- If the sprite is **animated** (an `animation` section), the frame, not the whole image, is the sprite
  (11).

Shipped inventory of `.mcmeta` sections in the jar's textures (counted from the jar): 218 files: 63 `animation`,
60 `texture`, 47 `gui` (all `nine_slice`, none `tile`), 36 `palette`, 14 `villager`.

### 6.4 The `texture` section on GUI sprites

`blur`, `clamp`, `mipmap_strategy` (08 7.4) apply to atlas sprites and whole-image textures alike.

---

## 7. Particles, effects, paintings, maps, trims and misc

### 7.1 Particles

A particle type has a data file `particles/<id>.json` with a `textures` array of sprite ids (the examples
read: a one-sprite array, a 16-frame array, a 4-frame array). The sprite id `ns:<name>` has the file
`textures/particle/<name>.png` (3.1, `particles` atlas). The list is the animation: the client picks a sprite
by age or at random depending on the particle's code. The definitions themselves are in the jar's own
`assets` (115 files), so a texture-only pack relies on them.

### 7.2 Paintings

Sprites of the `paintings` atlas: file `textures/painting/<name>.png`, sprite id `ns:<name>`. The painting
variant data (`painting_variant` in 04) names the asset id. Sizes are multiples of 16 per block.

### 7.3 Map decorations

Sprites of the `map_decorations` atlas: file `textures/map/decorations/<name>.png`, sprite id `ns:<name>`.
Two whole-image map textures are named by code: `textures/map/map_background.png` and
`textures/map/map_background_checkerboard.png`.

### 7.4 Armour trims and palettes

Trim overlays for **items** are generated at load time by the `items` atlas's `paletted_permutations`
source (08 7.3): the four base textures `trims/items/{helmet,chestplate,leggings,boots}_trim` are recoloured with 16
palette images `trim/<material>` (and `_darker` variants), the key palette being `trim_base`. The palette
files are under `textures/palettes/` (`trim/*.png`, `trim_base.png`).
Trim textures for **worn** armour are under `textures/trims/entity/<layer type>/<pattern>.png`; each such file
has a `.mcmeta` with a `palette` section (field `base_palette`) naming the key palette (36 such `.mcmeta`
files in the jar). The 16-material recolouring uses the same palette images.

A texture-only pack that ships the trim PNGs but no `textures/palettes/` relies on the lower pack's palettes.

### 7.5 Status effect icons

`textures/mob_effect/<name>.png`, sprite id `ns:mob_effect/<name>` in the `gui` atlas (3.1). One file per
effect, square.

### 7.6 Misc

Whole-image textures under `textures/misc/` named by code: the enchantment glint for items and for armour,
the vignette, the nausea overlay, the powder-snow outline, the spyglass scope, the underwater overlay, the
pumpkin blur, the world border force field, the entity shadow, the credits vignette, and the placeholder
icons for an unknown server or pack.

---

## 8. Environment textures

### 8.1 Celestial bodies

The sky renderer (`SkyRenderer`) draws sun, moon and the End flash as quads from the `celestials` atlas.

| Sprite id | File | Drawn as |
|---|---|---|
| `sun` | `textures/environment/celestial/sun.png` | A square quad of edge **60** world units (a unit quad with corners (±1, 0, ±1) scaled by 30, so 30 is the half-size) at height **100** above the camera, rotating with the time of day. |
| `moon/full_moon`, `moon/waning_gibbous`, `moon/third_quarter`, `moon/waning_crescent`, `moon/new_moon`, `moon/waxing_crescent`, `moon/first_quarter`, `moon/waxing_gibbous` | `textures/environment/celestial/moon/<phase>.png` | A square quad of edge **40** (the same unit quad scaled by 20) at height **100**. One sprite per phase. |
| `end_flash` | `textures/environment/celestial/end_flash.png` | End sky flash: edge **120** (unit quad scaled by 60) at height 100. |

The phase index runs 0 to 7 in exactly the order of the table row for the moon (`MoonPhase`: full moon,
waning gibbous, third quarter, waning crescent, new moon, waxing crescent, first quarter, waxing gibbous).
Each sprite is a **whole** square (not a 4 x 2 sheet, as in older versions). Sprite size is free (the
client takes UV from the sprite rectangle): the jar's sun and moon images are 32 x 32 (12 §3.4c) and the
pack's are 64 x 64, exactly 2 x. The quad's world size does not depend on the image size. The sun and moon
quads are built from a unit quad in `buildCelestialQuad`/`buildSunQuad`/`buildEndFlashQuad` and scaled in
`applyCelestialBodyTransform`; 12 §3.4c has the blend and colour.

### 8.2 Rain and snow

`textures/environment/rain.png` and `snow.png` are whole-image textures (`WeatherEffectRenderer`) drawn on
vertical quads around the camera. They are tall strips of falling streaks that repeat vertically; the
precise UV mapping (the fraction of the image used per quad and the scroll speed) was not traced (Open
question 6). The sampling is by fractions of the image, so any whole-number scale works.

### 8.3 Clouds

`textures/environment/clouds.png` is read **pixel by pixel on the CPU** (`CloudRenderer`: `NativeImage.read`, then
the pixels are read with `getPixel`), not sampled as a texture. Each pixel is one cloud **cell** of
**12 blocks** edge: a pixel is empty when its alpha is **below 10** (read in `isCellEmpty`: the pixel's alpha compared with 10) and solid
otherwise; the cloud colour is not taken from the pixel but from the `visual/cloud_color` environment attribute (overworld base `#ccffffff`, multiplied by the day track and weather layers; 12 §3.6). Cells are 12 x 4 x 12 blocks. The
constants `BLOCKS_PER_SECOND` = 0.6 and `TICKS_PER_CELL` = 400 describe the same drift: one 12-block
cell per 400 ticks is 0.03 blocks per tick, which is 0.6 blocks per second. 12 §3.6 has the full cloud rules. The image wraps.
A pack image of twice the size has twice as many cells in each direction, which changes the cloud layout
and the repeat distance, unlike every other texture. The jar's clouds image is 256 x 256 (checked from the
file header only).

### 8.4 End sky

`textures/environment/end_sky.png` is the End sky box and the end portal's background (`SkyRenderer`,
`AbstractEndPortalRenderer`).

---

## 9. Colormaps

Three colour lookup images exist: `textures/colormap/grass.png`, `foliage.png`, `dry_foliage.png`
(`GrassColorReloadListener`, `FoliageColorReloadListener`, `DryFoliageColorReloadListener`, ids in the
`minecraft` namespace). They are read as raw ARGB pixel arrays (`NativeImage.makePixelArray`), without
resampling. The lookup (`ColorMapColorUtil.get`) takes the biome's temperature t and downfall d, both
clamped to 0 to 1 by the caller (`Biome`):

| Step | Formula |
|---|---|
| 1 | d' = d x t |
| 2 | x = truncate((1 - t) x 255) |
| 3 | y = truncate((1 - d') x 255) |
| 4 | index = y x 256 + x (that is, `(y << 8) | x`) |
| 5 | If index is not below the array length, the result is the default colour. Otherwise the result is the pixel at that array index. |

The image must therefore be **256 x 256** for the lookup to be meaningful: the row stride is the fixed 256
and the default array holds 65536 entries. A larger image (such as 512 x 512) is read row-major with the
same 256 stride and gives the wrong pixels. The pixel at (x, y) of a correct image is the colour for the
temperature and downfall that give that x and y. Only the triangle y >= x (d' <= t) is ever looked up.

Default colours when the index is out of range (constants in the three classes, ARGB): grass `FFFF00FF`
(a deliberately wrong magenta), foliage `FF48B518`, dry foliage `FF5C3C32`. The four fixed foliage tints
are constants in code, not image lookups: evergreen `FF619961`, birch `FF80A755`, default `FF48B518`,
mangrove `FF92C648`.

`Biome` also applies per-biome overrides (`foliageColorOverride`, `dryFoliageColorOverride`, a grass colour
modifier) from the biome's data before it falls back to the colormap.

**Water** and sky colours are not images; the biome data carries them.

A texture-only pack either ships its own 256 x 256 colormaps or relies on the lower pack's.

---

## 10. Fonts

### 10.1 Definition files

A font is `font/<id>.json` with a `providers` array. The client's provider types (`GlyphProviderType`):

| `type` | Fields | Meaning |
|---|---|---|
| `bitmap` | `file` (id relative to `textures/`, including `.png`), `chars` (array of equal-length strings, one per cell row), `height` (default 8), `ascent` | A grid image; `chars` gives the code point of each cell, `\u0000` for none. |
| `space` | `advances`: map from a character string to an advance | Characters that advance without drawing. |
| `unihex` | (the unihex zip, with size overrides) | The 16 x 16 and 8 x 16 unifont glyph source. |
| `ttf` | file, size, oversample, shift, skip | A TrueType file. |
| `reference` | `id` of another font definition; optional `filter` | Include another definition's providers. |

The vanilla fonts of the jar (`font/*.json`, 4 top-level definitions and 3 `include/` parts):

| Id | Providers |
|---|---|
| `default` | `reference` `include/space`; `reference` `include/default` with filter `uniform` false; `reference` `include/unifont` |
| `uniform` | `include/space`, `include/unifont` |
| `alt` | `include/space`; a `bitmap` with `font/ascii_sga.png`, ascent 7 (the enchanting-table script) |
| `illageralt` | `include/space`; a `bitmap` with `font/asciillager.png`, ascent 7 (illager script) |
| `include/space` | one `space` provider: advance 4 for U+0020 (the space), 0 for U+200C |
| `include/default` | three `bitmap` providers: (a) `font/nonlatin_european.png`, ascent 7, 67 rows x 16, 1058 glyphs (Greek, Cyrillic, Hebrew, symbols, punctuation); (b) `font/accented.png`, height 12, ascent 10, 75 rows x 16, 1189 glyphs (Latin accented letters and others); (c) `font/ascii.png`, ascent 7, 16 rows x 16, 166 glyphs (10.2) |
| `include/unifont` | an empty provider list in the shipped jar (the unifont data is not in the jar) |

Providers earlier in the list win for a code point.

### 10.2 The ascii layout

`font/ascii.png` is a 16 x 16 grid; row r, column c holds the glyph for the code point listed (`--` is no glyph).
Row 0, 1, 8 and 14 hold none except as shown.

| Row | Code points (hex) |
|---|---|
| 0, 1 | none |
| 2 | 20 to 2F |
| 3 | 30 to 3F |
| 4 | 40 to 4F |
| 5 | 50 to 5F |
| 6 | 60 to 6F |
| 7 | 70 to 7E (column 15 empty) |
| 8 | none |
| 9 | columns 12, 15: A3, 192 (the others empty) |
| 10 | columns 6, 7, 10, 14, 15: AA, BA, AC, AB, BB |
| 11 | 2591 2592 2593 2502 2524 2561 2562 2556 2555 2563 2551 2557 255D 255C 255B 2510 |
| 12 | 2514 2534 252C 251C 2500 253C 255E 255F 255A 2554 2569 2566 2560 2550 256C 2567 |
| 13 | 2568 2564 2565 2559 2558 2552 2553 256B 256A 2518 250C 2588 2584 258C 2590 2580 |
| 14 | columns 13, 14: 2205, 2208 |
| 15 | 2261 B1 2265 2264 2320 2321 F7 2248 B0 2219 (empty) 221A 207F B2 25A0 (empty) |

The ASCII printable range 20 to 7E is rows 2 to 7. Rows 0, 1 and 8 are empty.

### 10.3 Cell size, scale and advance

For a `bitmap` provider with `R` rows of `C` columns (every `chars` string has the same length C), image
size W x H:

| Quantity | Rule |
|---|---|
| Cell size | cw = W / C and ch = H / R (integer division). |
| Scale | s = `height` / ch. (`height` defaults to 8.) |
| Glyph width in cell pixels | The column of the rightmost pixel whose alpha (or luminance for a grey image) is not 0, plus 1. An empty cell has width 0. |
| Advance | trunc(0.5 + width x s) + 1 (in drawn pixels). |
| Drawn glyph | The cell is drawn with height `height` and width cw x s; `ascent` is the number of drawn pixels above the baseline. |
| Duplicates | A code point listed twice is logged ("declared multiple times") and the later one wins. |

So the same provider with a cell of 8 x 8 and a cell of 16 x 16 (with `height` 8 and `ascent` 7) gives identical
text layout: the scale is 1 and 0.5 and the widths and advances come out the same, **for glyphs that are exact
2x enlargements**. Text drawn from a 2x image is simply sharper.

In CobolCraft's own font rule (08 10.10, advance = rightmost column + 2) the formula above is the same with
`height` 8 and an 8 x 8 cell (trunc(0.5 + w) + 1 = w + 1, with w = column + 1).

### 10.4 Which font image a pack's file serves

| Pack file (`textures/font/`) | Consumed by |
|---|---|
| `ascii.png` | provider (c) of `include/default`; the pack's grid must keep 16 x 16 cells so `chars` of 10.2 still map. |
| `accented.png` | provider (b); cells are 1/16 of the width and 1/75 of the height. |
| `nonlatin_european.png` | provider (a); 16 columns x 67 rows. |
| `ascii_sga.png` | the `alt` font. 16 x 16 cells. |
| `asciillager.png` | the `illageralt` font. 16 columns x 5 rows. |

A texture-only pack has no `font/*.json` and no unihex data; it changes how the glyphs look and nothing else.

---

## 11. Animated textures

A `foo.png.mcmeta` with an `animation` section (field table in 08 7.4) turns `foo.png` into an animated
sprite (`SpriteContents$AnimatedTexture`, `AnimationMetadataSection`). Additional rules:

1. **Frame size.** If neither `width` nor `height` is given, the frame is a square with the side
   min(image width, image height) (so a tall strip of squares needs no fields). If both are given, they are the
   frame size in pixels. With only one given, the other defaults to the image's own dimension. The image
   width and height must be multiples of the frame size, or the sprite becomes the missing texture.
2. **Frame order.** Frames are numbered left to right, then top to bottom (inferred).
3. **Timing.** `frametime` is the default number of **ticks** a frame lasts (default 1; positive). A
   frame object `{index, time}` overrides it. Without `frames`, every frame is shown in index order.
4. **Interpolate.** When true, the colour shown between frame changes blends linearly from the current
   frame to the next, by the fraction of the frame time elapsed. When false, frames switch abruptly.
5. **Atlas size.** The sprite size used by the stitcher and the UV is the **frame** size. The atlas holds
   only the visible frame; the animation is uploaded into the atlas region each frame.
6. **Size changes are free.** Doubling the image doubles the frame size and nothing in `.mcmeta` needs to
   change if `width` and `height` are omitted. If they are given, they are in the image's own pixels
   and must be doubled too. For two entity textures (the conduit wind files) the jar gives only `height` 32 (the frame width then
   defaults to the 64 px image), while the 32x pack states both `width` 128 and `height` 64 and an explicit
   `frames` list: both stated, at twice the effective frame size.
7. For GUI sprites, `animation` works the same: `height`/`width` are pixel values of the supplied image.

In the pack (§14) 63 of its 206 texture `.mcmeta` files carry an `animation` section.

---

## 12. Companion `.mcmeta` files

| Section | Applies to | Notes |
|---|---|---|
| `animation` | atlas sprites and whole-image textures | 11 |
| `texture` | atlas sprites and whole images | `blur`, `clamp`, `mipmap_strategy`, `alpha_cutoff_bias` (08 7.4) |
| `gui` | GUI sprites | 6.3 |
| `villager` | villager and zombie villager profession and type overlays | `hat`: how the head covering is drawn |
| `palette` | trim textures | `base_palette` (7.4) |

The `.mcmeta` lookup rule is 2.3 (1). The pack's `.mcmeta` files override the jar's on a per-file basis. The
shipped client has 218 and the pack 206 under `textures/` (§14).

---

## 13. OptiFine files

The `assets/minecraft/optifine/` directory of a pack holds connected-texture (CTM) rules and a few
other OptiFine-format files: `.properties` rule files (`matchBlocks`, `faces`, `method`, `tiles` and so on) and
the tile PNG files they refer to. **The vanilla client does not read any of it.** Checked in the jar:

- No class file contains the text `optifine`, `mcpatcher` or a `ctm` directory name (a case-insensitive
  scan of every class file; the only hits for `ctm` were letters inside longer unrelated words).
- The jar itself ships no such directory.
- No resource listing in the client enumerates `optifine/`. Atlas `directory` sources list only `block`,
  `item`, `entity/*`, `gui/sprites`, `mob_effect`, `environment/celestial`, `particle`, `map/decorations` and
  `painting`. Because those are listed **per source directory**, tile PNG files under
  `optifine/ctm/...` are in none of them.

So the files are inert: they cost disk space only. Our client may ignore them (it need not implement
connected textures).

The `models/item/*.json` files of a pack are read as models: the pack's one model file (`item/redstone_torch.json`,
parent `minecraft:item/generated`, `layer0` = `minecraft:item/custom/redstone_torch`) is a valid generated item model whose
sprite lies in the `item` directory, so the `items` atlas picks the PNG up even though no
shipped item definition names the model.

---

## 14. The operator's pack (Faithful 32x for 26.3), as data

Everything below was counted from `unzip -l` and PNG headers.

| Item | Value |
|---|---|
| Archive | 5300 entries, of which 5066 files (the rest are directories). |
| `pack.mcmeta` | `pack.description` "The go-to 32x resource pack.", `pack.min_format` 84, `pack.max_format` 97. Version 97.1 is inside the range, so the pack is compatible (08 2.3). No `overlays`, `language` or `features` section. |
| Root files | `pack.mcmeta`, `pack.png`, `LICENSE.txt` |
| Namespaces under `assets/` | `minecraft` (5035 files), `forge` (9), `neoforge` (9), `modmenu` (9), `fabric` (1). All names are valid (2.2). |
| Data files | none: no `blockstates/`, `atlases/`, `lang/`, `items/`, `font/*.json`, `particles/`, `sounds`, `equipment/`; one model, `models/item/redstone_torch.json` |
| PNG files under `assets/minecraft/textures/` | **3931** |
| Of these, same path in the 26.3 jar | 3901 (30 extras not in the jar, 63 jar textures the pack does not have) |
| Scale | Every shared texture is exactly 2 x the jar's width and height, except 15 GUI images (9 at 1 x, 6 at a different multiple), 2 `misc` images at 1 x and 1 particle sheet (2 x wide, 1.875 x tall) |
| `.mcmeta` under `textures/` | 206 (105 block, 49 gui, 36 trims, 14 entity, 1 particle, 1 misc); 4 more under `forge` and `neoforge`; 1 `pack.mcmeta` |
| OptiFine | `assets/minecraft/optifine/`: 897 files (858 PNG and 38 `.properties` under `ctm/`, plus `textures/icons.png`); not read by the vanilla client (13) |

Category counts (PNG files) and typical sizes are in the design document (section 2). The pack has **no**
`textures/colormap/` and **no** `textures/palettes/`; no `environment/clouds.png`; no `misc/vignette.png`, `shadow.png`
or `nausea.png`; no `gui/sprites/hud/crosshair.png`; its `gui/title/` has only the six panorama faces and `mojangstudios.png`
(no logo files, no `panorama_overlay.png`).

---

## Validation

Checkable facts. A reader or reviewer can reproduce each with `unzip -l`, a PNG header reader and `javap`.

| # | Fact | Value |
|---|---|---|
| V1 | SHA-256 of the jar and the pack | as in the header |
| V2 | PNG files in the pack under `assets/minecraft/textures/` by directory | block 1297, item 832, entity 763, gui 543, particle 297, trims 40, painting 52, map 42, mob_effect 40, environment 13, misc 7, font 5; total 3931 |
| V3 | `.mcmeta` files in the pack under `assets/minecraft/textures/` | 206 |
| V4 | Atlas definition files in the jar | 12 (`banner_patterns`, `blocks`, `celestials`, `chests`, `decorated_pot`, `gui`, `items`, `map_decorations`, `paintings`, `particles`, `shield_patterns`, `shulker_boxes`) |
| V5 | `blocks` definition has 4 sources (2 `directory`, 2 `single`); `items` has 2 (`directory`, `paletted_permutations` with 16 permutations); `gui` has 2 `directory` sources (`gui/sprites` prefix empty, `mob_effect` prefix `mob_effect/`) | |
| V6 | Colormap lookup of temperature 0.8, downfall 0.4 | x = 50, y = 173, index 44338 (173 x 256 + 50). The calls use floats widened to doubles: (1 - 0.8000000119) x 255 = 50.99999 truncates to 50. |
| V7 | Colormap lookup of temperature 1.0, downfall 1.0 | x = 0, y = 0, index 0 |
| V8 | Colormap lookup of temperature 0.0, downfall anything | d' = 0, x = 255, y = 255, index 65535 |
| V9 | Mip bound for sprites of 16 x 16 and 32 x 32 | lowest set bit 16 gives log2 = 4 |
| V10 | Mip bound when one sprite is 20 x 20 | lowest set bit 4 gives 2 |
| V11 | Bitmap font advance, cell 16 x 16, `height` 8, glyph ink reaching column index 9 (width 10) | s = 0.5; advance = trunc(0.5 + 10 x 0.5) + 1 = 6 |
| V12 | Bitmap font advance, cell 8 x 8, `height` 8, ink reaching column index 4 (width 5) | trunc(0.5 + 5) + 1 = 6 |
| V13 | Pack texture sizes | `block/` sprites 32 x 32 except 45 at 64 x 64 and a few strips (for example 32 x 128, 32 x 96, 32 x 1024); `item/` 825 at 32 x 32 and 7 at 64 x 64; `gui/container/inventory.png` 512 x 512; `gui/container/villager.png` 1024 x 512; `gui/sprites/hud/hotbar.png` 364 x 44; `gui/sprites/widget/button.png` 400 x 40 with `nine_slice` width 200, height 20; `environment/rain.png` and `snow.png` 128 x 512; `environment/celestial/sun.png` and each moon 64 x 64; `font/ascii.png` 256 x 256; `font/accented.png` 288 x 1800; `font/nonlatin_european.png` 256 x 1072; `entity/slime/slime.png` 128 x 64; `entity/player/wide/steve.png` 128 x 128 |
| V14 | The distinct entity texture path strings found in code | 285 |
| V15 | Sun quad edge 60, moon 40, end flash 120, all at height 100 (scales 30, 20, 60 on a unit quad); cell size of clouds 12 blocks; cloud cell empty when alpha < 10 | read as constants and `isCellEmpty` |
| V16 | `.mcmeta` sections in the jar's textures | animation 63, texture 60, gui 47 (all nine_slice), palette 36, villager 14 |

---

## Open questions

1. ~~**Padding amount in the stitcher.**~~ Resolved with 12 §2.2 (3.5, item 3).
2. **Entity texture path list by family.** The 285 path strings were counted and grouped by directory, not
   catalogued; names built by concatenation at run time (variants) are not in the count.
3. **Which break-overlay set is drawn.** `destroy_stage_N` or `destroy_oit_stage_N` (4.3): the choice was not
   traced. A pack should supply both.
4. **Face orientation in the box unwrap.** 5.3 gives rectangles, not the orientation of each face.
5. **3 x 3 crafting screen geometry.** Slot origins of the crafting table and the result slot were not read.
6. **Rain and snow UV mapping and fall speed.** Only the textures and their whole-image sampling are known.
7. **Item tint source choice for grass-like block items.** The tint source types exist (08 6.4); which source
   the shipped item definitions use for the grass block icon was not read.
8. ~~**Cloud cell semantics.**~~ Resolved: empty when alpha < 10 (8.3).
9. **Whether `texture` `mipmap_strategy` values other than `auto` change the colour** of a face beyond mip
   levels (the glass texture of the pack uses `mean`).
