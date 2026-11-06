# Faithful 32x pack mapping (design)

This is a CobolCraft design document. It decides how the client loads and uses the operator's resource pack
`Faithful 32x - 26.3.zip` and how our stand-in content binds to the pack's texture files. The behaviour of the
shipped client that it relies on is in [../protocol/14-texture-only-packs.md](../protocol/14-texture-only-packs.md)
(cited as "14 §n"); the pack format is [../protocol/08-resource-packs.md](../protocol/08-resource-packs.md) (cited
as "08 §n"); the stand-in content is [standin-content.md](standin-content.md) (cited as "SC §n").

| Item | Value |
|---|---|
| Operator decisions | Ticket CC-0001: the client must load and use this pack. Then: (1) the `minecraft:` namespace is used wherever a vanilla equivalent exists, so a pack applies by path; (2) `cobolcraft:` is kept for content where CobolCraft extends or diverges from Minecraft. |
| Pack inspected | `Faithful 32x - 26.3.zip`, SHA-256 `596035002e8c369ca673b5b922cd532a38a2aaabe80f317f5ac4d5c7680c7bf2`, read as data with `unzip -l`, `unzip -p` and a PNG header reader (width and height only). Resource pack range 84 to 97. |
| Client artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in `docs/protocol/README.md`), static reading only. |
| Status of rows | A row marked "(inferred)" is a judgement call about which vanilla texture is the closest equivalent of a stand-in. It is a design choice, not a fact read from an artifact. |

No texture of the pack or of the jar is copied into the repository. The built-in pack keeps its own procedural
art (SC §1.4, §2, §3, §14.5, §18).

---

## 1. The namespace rule

### 1.1 Rule

The client resolves every asset by namespace and path. Both namespaces are enumerated (08 §1.3, 14 §2.2), and
resolution is **per asset**:

| If the stand-in entry... | its texture ids are in | Reason |
|---|---|---|
| has a vanilla equivalent (a texture of the same role exists in the pack's `minecraft:` set) | `minecraft:` | A user pack such as Faithful then applies with no id mapping, and any other 26.3-format pack does too. |
| has no vanilla equivalent, or CobolCraft diverges (our own block, item, mob, screen or string) | `cobolcraft:` | Nothing in a vanilla-targeted pack could supply it; a pack author who wants to restyle it ships `assets/cobolcraft/...`. |

"Vanilla equivalent" is decided per stand-in entry in sections 3 to 7. The built-in pack
(`cobolcraft`, 08 §10) supplies **both** namespaces: it ships its procedural art for a vanilla-equivalent entry
at the `minecraft:` path (at the bottom of the stack), and its own art for the others under `cobolcraft:`. A user
pack replaces any built-in file by shipping the same path (08 §3.2), whichever namespace it is in.

### 1.2 What does not change

The rule moves **texture ids** only. The following stay as they are in 08 §10 and SC, because the registry
keys and wire ids of blocks, items and entities are untouched (see the open question in section 11):

- Registry keys such as `cobolcraft:greystone`, and therefore the files named after them:
  `assets/cobolcraft/blockstates/greystone.json`, `assets/cobolcraft/models/block/greystone.json`,
  `assets/cobolcraft/models/item/greystone.json`, `assets/cobolcraft/items/greystone.json`, and the language keys
  (`block.cobolcraft.greystone`, 08 §10.8).
- Gameplay values, collision boxes, hardness and the recipes of SC.
- The recipe **names** used as noise seeds (SC §1.4.1: for example `greystone`, `loam`, `turf_top`). Only the
  file the finished image is written to changes. All check values of SC §1.5 stay valid, except those called out in
  section 8.2 (turf) and section 5 (entities).

### 1.3 Statements of 08 and SC that this changes

These documents are **not edited** by this design. A later SDD round updates them (Principle II); this list is
what must change.

| Document and place | Current statement | Change |
|---|---|---|
| 08, introduction (paragraph 1) | "Our packs target our own `cobolcraft:` namespace. Nothing here describes or depends on vanilla asset content." | Our packs target `cobolcraft:` for our own content and `minecraft:` for content that has a vanilla equivalent. The rest stands: we do not extract, bundle or list vanilla assets, and the built-in `minecraft:` files are our own procedural art. |
| 08 §1.3, last paragraph | "Every reference inside a `cobolcraft` pack must therefore spell out `cobolcraft:`." | Add: a reference to a vanilla-equivalent sprite spells `minecraft:` (or leaves the namespace out, which means the same). |
| 08 §8, rows `textures/colormap/*.png` and `textures/**` | colormap "not read" | The client reads `minecraft:colormap/grass` for the turf tint (section 8.2). The row becomes **read**. |
| 08 §10, opening paragraph | "CobolCraft's built-in pack, named `cobolcraft`, carries the procedural textures" | The built-in pack has two namespace directories, `assets/minecraft/` and `assets/cobolcraft/` (this document, §9). |
| 08 §10.2 | the blocks and items atlas definitions pick up `cobolcraft:` sprites | The same `directory` sources pick up `minecraft:block/...` and `minecraft:item/...` too (14 §2.2); no entry changes. A `gui` atlas definition is added (section 7). |
| 08 §10.3 (table, "Sprite id" and file columns, and the paragraph after it) | every texture is at `assets/cobolcraft/textures/...` with a `cobolcraft:` sprite id | The file and sprite id of each row become the id of sections 3 to 6. The size column and the "Drawn on" column are unchanged for blocks and items. The entity, environment and font rows change as in sections 5, 6.2 and 6.3. |
| 08 §10.5 (block model `textures` values) and §10.7 (item `layer0` values) | `cobolcraft:block/<name>` sprites | The `textures` and `layer0` values name the sprite ids of sections 3 and 4. Model ids and file locations are unchanged. The `turf` model needs a second element (section 8.2). |
| 08 §10.9 (file count) | 27 PNG files: 15 block, 6 item, 3 entity, 2 environment, 1 font | Recounted in section 9.4. |
| 08 §10.10 (font) | `cobolcraft:font/ascii.png`, 128 x 48, six rows | The file is `minecraft:font/ascii.png`, 128 x 128, sixteen rows, ASCII in rows 2 to 7 (section 6.3). |
| 08 §10.11 (entities and weather) | entity textures `cobolcraft:`-path strips, fixed boxes | Only if the operator approves the geometry change of section 5; the weather textures become the `minecraft:` environment files (section 6.2). |
| SC §1.4.1, "Noise" definition | "the texture name `name` (the file stem of 08 §10.3)" | The name is the **recipe name** (kept), no longer necessarily the file stem. |
| SC §1.4.2 (recipe table, "Texture (file stem)" column) | file stems `greystone`, `loam`, ... | Add the target path column of section 3. Add the `grass_block_side_overlay` split and the grey turf art (section 8.2) and the ten break-stage recipes (section 8.1). |
| SC §2 (item icon recipes) | "texture file stem = the item's key path" | The recipe name stays; the target path is section 4's. |
| SC §3.1, §3.2, §12.6 | entity textures at `textures/entity/<key path>.png`, the strip layout | Unchanged unless the section 5 geometry change is approved. |
| SC §14.1, §14.5 | environment textures `textures/environment/drizzle.png`, `hailstorm.png` | Become `minecraft:environment/rain.png` and `snow.png` (section 6.2). |
| SC §18 | `ascii.png` 128 x 48, cell of code c at (((c - 32) mod 16) x 8, ((c - 32) div 16) x 8) | 128 x 128, cell of code c at ((c mod 16) x 8, (c div 16) x 8). The glyphs, advances and the missing glyph are unchanged. |

---

## 2. What the pack provides

All counts are of files in `Faithful 32x - 26.3.zip` (5300 archive entries; 5066 files). A "sheet" is a
whole-image GUI texture.

### 2.1 Inventory by category

| Pack directory (under `assets/minecraft/`) | PNG | `.mcmeta` | Typical size | Notes |
|---|---|---|---|---|
| `textures/block/` | 1297 | 105 | 32 x 32 (1197 files); 64 x 64 (45); animation strips such as 32 x 128, 32 x 96, 32 x 1024 | 2 x the vanilla size. Includes `destroy_stage_0` to `_9` and `destroy_oit_stage_0` to `_9`. Grass, foliage and water-tinted textures are grey-scale templates. |
| `textures/item/` | 832 | 0 | 32 x 32 (825); 64 x 64 (7) | One extra, `item/custom/redstone_torch.png`, used by the pack's one model. |
| `textures/entity/` | 763 | 14 | 128 x 128 (386); 128 x 64 (120); 64 x 64 (105); 256 x 256 (56); 256 x 128 (39); 32 x 32 (36) | 85 under `entity/equipment/`, 18 player skins (`entity/player/wide/` and `slim/`, 9 each, 128 x 128), 124 `_baby` variants, plus layer files outside `equipment/`: 2 `_overlay`, 2 `_outer_layer`, 5 `_armor`, 3 `_wool`, 7 `_eyes` (14 §5.1). The 16 `_harness` files are inside `equipment/happy_ghast_body/` and already part of the 85. The suffix and layer counts overlap and are not a partition of the 763: for example the 124 `_baby` files include 2 inside `equipment/`, and `sheep_wool_baby` and `drowned_outer_layer_baby` are also counted under wool and outer layer. |
| `textures/gui/` | 543 | 49 | 465 PNG under `gui/sprites/` (2 x the logical size); 78 PNG outside it (sheets 512 x 512 and 1024 x 512, signs, panorama, realms) | `.mcmeta`: 43 `gui` (all `nine_slice`) and 6 `animation`; see 2.2. |
| `textures/particle/` | 297 | 1 | 16 x 16 (106), 32 x 32 (82), 64 x 64 (53), 10 x 10 (38), 6 x 6 (12) | 2 x the vanilla size. |
| `textures/trims/` | 40 | 36 | 128 x 64 (36), 32 x 32 (4) | 36 armour trim files under `trims/entity/humanoid` and `humanoid_leggings` (18 patterns x 2 layers, each with a `palette` `.mcmeta`), 4 item overlays `trims/items/*_trim`. |
| `textures/painting/` | 52 | 0 | 64 x 64, 32 x 32, 96 x 96, 128 x 128, 128 x 64, 64 x 32 | |
| `textures/map/` | 42 | 0 | 16 x 16 (40); `map_background` 128 x 128 and `map_background_checkerboard` 256 x 256 | 40 under `map/decorations/` |
| `textures/mob_effect/` | 40 | 0 | 36 x 36 (all) | |
| `textures/environment/` | 13 | 0 | `rain`, `snow` 128 x 512; `end_sky` 256 x 256; `celestial/sun` and 8 moon phases 64 x 64; `celestial/end_flash` 128 x 128 | See 2.3. |
| `textures/misc/` | 7 | 1 | `enchanted_item_glint` 256 x 256 (+ `.mcmeta`), `forcefield` 32 x 32, `powder_snow_outline` 512 x 512, `pumpkinblur` 256 x 256, `spyglass_scope` 512 x 512, `underwater` 32 x 32, `unknown_pack` 128 x 128 | No vignette, shadow, nausea or credits files. |
| `textures/font/` | 5 | 0 | `ascii` 256 x 256, `ascii_sga` 256 x 256, `asciillager` 256 x 80, `nonlatin_european` 256 x 1072, `accented` 288 x 1800 | 2 x the vanilla size; see 2.4. |
| Total under `textures/` | **3931** | **206** | | |
| `optifine/ctm/` | 858 | 38 `.properties` | | Connected-texture rules; not read by the vanilla client (14 §13). Plus `optifine/textures/icons.png`. |
| `models/item/` | 1 JSON | | | `redstone_torch.json`: `parent` `minecraft:item/generated`, `layer0` `minecraft:item/custom/redstone_torch`. |
| Other namespaces | `forge` 9, `neoforge` 9, `modmenu` 9, `fabric` 1 | | | Mod-loader and menu-mod assets. Harmless extras (14 §2.2). |
| Root | `pack.mcmeta`, `pack.png`, `LICENSE.txt` | | | `pack.mcmeta`: `min_format` 84, `max_format` 97, description "The go-to 32x resource pack." |

The pack has **no** block states, **no** atlas definitions, **no** language files, **no** font or particle
definitions, **no** `colormap/` and **no** `palettes/`.

### 2.2 GUI: sheets and sprites

Sheets (whole images, 14 §6.2). All are exactly twice the vanilla size:

| Sheet (under `textures/gui/`) | Size in the pack | Logical size used by the client |
|---|---|---|
| `container/inventory.png`, `crafting_table.png`, `furnace.png`, `blast_furnace.png`, `smoker.png`, `generic_54.png`, `dispenser.png`, `hopper.png`, `anvil.png`, `beacon.png`, `brewing_stand.png`, `cartography_table.png`, `crafter.png`, `enchanting_table.png`, `grindstone.png`, `horse.png`, `loom.png`, `nautilus.png`, `shulker_box.png`, `smithing.png`, `stonecutter.png` (21 files) | 512 x 512 | 256 x 256 |
| `container/villager.png` | 1024 x 512 | 512 x 256 |
| `container/gamemode_switcher.png` | 256 x 256 | 128 x 128 |
| `container/creative_inventory/tab_inventory.png`, `tab_item_search.png`, `tab_items.png` | 512 x 512 | 256 x 256 |
| `recipe_book.png`, `book.png`, `demo_background.png` | 512 x 512 | 256 x 256 |
| `header_separator.png`, `footer_separator.png`, `inworld_header_separator.png`, `inworld_footer_separator.png` | 64 x 4 | 32 x 2 (tiled) |
| `signs/` (13), `hanging_signs/` (13), `advancements/` (6), `realms/` (6), `title/` (7: six panorama faces and `mojangstudios.png`) | various | |

Sprites (the `gui` atlas, 14 §6.1): 465 PNG files under `gui/sprites/` in 24 groups, with these PNG counts:
`container` 126, `hud` 84, `widget` 35, `advancements` 33, `recipe_book` 29, `icon` 23, `boss_bar` 22, `server_list` 18,
`friends` 17, `toast` 12, `statistics` 9, `world_list` 8, `transferable_list` 8, `social_interactions` 8,
`notification` 6, `spectator` 5, `realm_status` 4, `pending_invite` 4, `player_list` 3, `pause_menu` 3, `dialog` 3,
`tooltip` 2, `gamemode_switcher` 2, `popup` 1.
Pack-made sprite sizes are 2 x the logical size; for example `hud/hotbar` 364 x 44, `hud/heart/full` 18 x 18,
`container/slot` 36 x 36, `widget/button` 400 x 40, `tooltip/background` 100 x 100.

`.mcmeta` for sprites: 43 `nine_slice` files (no `tile`) and 6 `animation` files. Logical sizes are stated in them
(for example `widget/button`: width 200, height 20, border left 20, top 4, right 20, bottom 4), so a 32x sprite draws at the
same size as a 16x one (14 §6.3). Sprites without a `.mcmeta` are stretched.

### 2.3 Colormaps, environment, entity layers

| Kind | In the pack | Consequence |
|---|---|---|
| Colormaps (`colormap/grass`, `foliage`, `dry_foliage`) | **none** | The built-in pack must supply `minecraft:colormap/grass` (section 8.2). |
| Palettes (`palettes/trim/*`, `trim_base`) | none | Needed only for trims; the stand-in has no armour. |
| Sun | `environment/celestial/sun.png`, 64 x 64 | Provided. |
| Moon | 8 phase files, 64 x 64 each, `environment/celestial/moon/` | Provided (all eight phase names of 14 §8.1). |
| Rain and snow | `environment/rain.png`, `snow.png`, 128 x 512 | Provided. |
| Clouds | none (`environment/clouds.png` absent) | Built-in, if the client draws clouds. |
| End sky and flash | `end_sky.png` 256 x 256; `celestial/end_flash.png` 128 x 128 | Provided; not used by the stand-in. |
| Entity layer textures | overlays, outer layers, armour, wool and eyes (2.1), and the 85 equipment files (which include the harnesses) | Provided; not used by the stand-in. Eye files (`_eyes`) are drawn bright by the vanilla client. |
| Moon phases, vignette, crosshair | vignette: none; crosshair `hud/crosshair`: none | Built-in (section 7). |

### 2.4 Fonts

The pack supplies five font images (14 §10.4) and no definition. Only `font/ascii.png` (256 x 256: cells of 16 x 16,
16 x 16 cells) is bound by our client (section 6.3).

---

## 3. Blocks

Texture ids for every stand-in block (SC §1.1) and the pack file each resolves to. The "Pack file" column is the
path inside the pack (every file is 32 x 32 and present). "Built-in art" is the file the built-in pack writes at the
same path from the SC recipe named in the last column.

| Stand-in block (face) | Namespace side | Sprite id | Pack file | In pack | Built-in art recipe (SC §1.4.2) |
|---|---|---|---|---|---|
| `baseplate` (all faces) | `minecraft:` (inferred: the unbreakable bottom layer is bedrock-like) | `minecraft:block/bedrock` | `assets/minecraft/textures/block/bedrock.png` | yes | `baseplate` |
| `greystone` (all) | `minecraft:` | `minecraft:block/stone` | `.../block/stone.png` | yes | `greystone` |
| `loam` (all) and the bottom of `turf` | `minecraft:` | `minecraft:block/dirt` | `.../block/dirt.png` | yes | `loam` |
| `turf`, top | `minecraft:` | `minecraft:block/grass_block_top`, tint 0 (section 8.2) | `.../block/grass_block_top.png` | yes | `turf_top`, grey form |
| `turf`, sides | `minecraft:` | `minecraft:block/grass_block_side` plus overlay `minecraft:block/grass_block_side_overlay`, tint 0 | `.../block/grass_block_side.png`, `.../block/grass_block_side_overlay.png` | yes | `turf_side`, split in two |
| `grit` (all) | `minecraft:` (inferred: pale low-ground surface) | `minecraft:block/sand` | `.../block/sand.png` | yes | `grit` |
| `cardstack`, ends | `cobolcraft:` (no equivalent: a bound stack of punch cards) | `cobolcraft:block/cardstack_end` | none, use built-in | no | `cardstack_end` |
| `cardstack`, sides, `punched=false` | `cobolcraft:` | `cobolcraft:block/cardstack_side` | none, use built-in | no | `cardstack_side` |
| `cardstack`, sides, `punched=true` | `cobolcraft:` | `cobolcraft:block/cardstack_side_punched` | none, use built-in | no | `cardstack_side_punched` |
| `lucite` (all) | `minecraft:` | `minecraft:block/glass` | `.../block/glass.png` (has a `texture` `.mcmeta`, `mipmap_strategy` `mean`) | yes | `lucite` |
| `glowtube`, `lit=true` | `minecraft:` (a lamp that toggles) | `minecraft:block/redstone_lamp_on` | `.../block/redstone_lamp_on.png` | yes | `glowtube_lit` |
| `glowtube`, `lit=false` | `minecraft:` | `minecraft:block/redstone_lamp` | `.../block/redstone_lamp.png` | yes | `glowtube_unlit` |
| `ledger_tile` (all) | `cobolcraft:` (no equivalent: a plain blue grid tile) | `cobolcraft:block/ledger_tile` | none, use built-in | no | `ledger_tile` |
| `goto_pad` (all) | `cobolcraft:` (no equivalent: the travel block) | `cobolcraft:block/goto_pad` | none, use built-in | no | `goto_pad` |
| `slag` (all) | `minecraft:` (inferred: the surface fill of the extra dimension, closest to a nether-style stone) | `minecraft:block/netherrack` | `.../block/netherrack.png` | yes | `slag` |
| `void` | not drawn | none | none | n/a | none |

Counts: 8 stand-in blocks (baseplate, greystone, loam, turf, grit, lucite, glowtube, slag) are on the `minecraft:` side,
using 11 sprite ids (bedrock, stone, dirt, grass top, grass side, grass side overlay, sand, glass, lamp on, lamp,
netherrack); the pack has all 11. 3 stand-in blocks (cardstack, ledger_tile, goto_pad) are on the `cobolcraft:` side,
using 5 sprite ids; the pack has none of them, by design.

### 3.1 Break-stage overlays

The survival break indicator (CC-0001) draws the ten sprites `minecraft:block/destroy_stage_0` to
`destroy_stage_9` (14 §4.3). The pack has these ten, and ten `destroy_oit_stage_*` that are unused by us.

---

## 4. Items

The item icon is the `layer0` sprite of the generated item model (08 §10.7). A block item keeps the block sprite as
its `layer0`, so a block item picks up the pack's block texture through section 3.

| Stand-in item | Namespace side | `layer0` sprite id | Pack file | In pack | Note |
|---|---|---|---|---|---|
| `baseplate`, `greystone`, `loam`, `turf`, `grit`, `cardstack`, `lucite`, `glowtube`, `ledger_tile`, `goto_pad`, `slag` (block items) | as their block | the block sprite of section 3: `turf` uses `minecraft:block/grass_block_top` with tint 0; `cardstack` its end face; `glowtube` the lit face | as in section 3 | as in section 3 | Same file as the block. |
| `pry_bar` (hard-class tool) | `minecraft:` (inferred) | `minecraft:item/iron_pickaxe` | `assets/minecraft/textures/item/iron_pickaxe.png` | yes | Pickaxe for hard blocks. |
| `trowel` (soft-class tool) | `minecraft:` (inferred) | `minecraft:item/iron_shovel` | `.../item/iron_shovel.png` | yes | Shovel for soft blocks. |
| `grazer_flank` (food 3) | `minecraft:` | `minecraft:item/beef` | `.../item/beef.png` | yes | Raw meat. |
| `seared_flank` (food 8) | `minecraft:` | `minecraft:item/cooked_beef` | `.../item/cooked_beef.png` | yes | Cooked meat. |
| `sod_cake` (food 2) | `minecraft:` (inferred) | `minecraft:item/cake` | `.../item/cake.png` | yes | |
| `dump_shard` (crafting material, purple) | `minecraft:` (inferred) | `minecraft:item/amethyst_shard` | `.../item/amethyst_shard.png` | yes | |
| `nothing` | not drawn | none | none | n/a | |

All 6 `minecraft:` item textures are present in the pack, all 32 x 32.

A ground item (`cobolcraft:loose_item`) has no texture of its own (08 §10.11). A crafting bench item and block
(CC-0001) are not in SC yet; if added, the closest vanilla equivalent is `block/crafting_table_top`, `..._side`
and `..._front` (all present), to be decided with that content.

---

## 5. Mobs and the player figure

### 5.1 Chosen equivalents

| Stand-in entity | Equivalent (inferred) | Texture id | Pack file | Size in pack | In pack |
|---|---|---|---|---|---|
| `cobolcraft:operator` (player figure) | The default player skin, wide arms | `minecraft:entity/player/wide/steve` | `assets/minecraft/textures/entity/player/wide/steve.png` | 128 x 128 | yes |
| `cobolcraft:sodgrazer` (passive grazer) | The temperate cow | `minecraft:entity/cow/cow_temperate` | `.../entity/cow/cow_temperate.png` | 128 x 128 | yes |
| `cobolcraft:abend` (hostile cube) | The slime (a cube mob) | `minecraft:entity/slime/slime` | `.../entity/slime/slime.png` | 128 x 64 | yes |
| `cobolcraft:loose_item` | none: it shows its item icon | none | none | | n/a |

### 5.2 What using these textures requires

The vanilla textures are laid out for the vanilla models, not for our boxes (08 §10.11 uses its own strip layout,
SC §3.1). Whole-image entity textures are sampled by **fractions of the model's declared texture size** (14 §5.2).
A pack's texture therefore lines up only if the client's model uses the vanilla layout. Binding a pack texture to
our boxes as they are would garble it. So the namespace rule for entities has a precondition: **the client adopts
the vanilla box layout (14 §5.4) for these three models**. This is design change G, and it is **not decided here**:
it needs the operator's approval (open question 1).

If approved:

| Entity | Model the client builds (14 §5.4) | Texture declared size | Notes |
|---|---|---|---|
| operator | Humanoid: head 8 x 8 x 8, body 8 x 12 x 4, two arms, two legs, plus the hat and second skin layers | 64 x 64 | The pack file is 128 x 128 = 2 x. A 64 x 64 skin from a server also works (a mismatch of scale is free). Slim arms use the `slim` file (3-wide arms). |
| sodgrazer | Cow: head, snout, body (rotated), four legs; horns and udder optional | 64 x 64 | The pack file is 2 x. |
| abend | Slime: outer shell 8 x 8 x 8 drawn translucent, inner body 6 x 6 x 6, two eyes, mouth | 64 x 32 | The pack file is 128 x 64 = 2 x. |

Collision boxes and every gameplay value (SC §3, §12) are unchanged. The model is scaled uniformly so that its
height matches the entity's collision height (inferred); this is a visual choice only.
The built-in pack then ships, at these `minecraft:` paths, original procedural textures in the vanilla layouts
(new recipes for SC §3, in the same style: flat colours and noise, using the operator's colours `#3A5A9A`, `#5E7A3C`
and `#2E2A4F`). Their size is the declared size (64 x 64, 64 x 64, 64 x 32); it is the declared size, not the pack's
2 x, that the SC recipe fixes.

**Until the change is approved**, the stand-in keeps the current boxes and the `cobolcraft:entity/operator`,
`entity/sodgrazer` and `entity/abend` strips of 08 §10.3, and a user pack cannot restyle them except by shipping those
`cobolcraft:` paths. The three rows of 5.1 then read "none, use built-in".

---

## 6. Environment, GUI and font

### 6.1 Sky

| Stand-in | Equivalent | Texture id | Pack file | In pack |
|---|---|---|---|---|
| Sun (SC has no sun disc; the sky is a colour, SC §4.8) | Vanilla sun, if the client draws one (inferred) | `minecraft:sun` (`celestials` atlas) | `assets/minecraft/textures/environment/celestial/sun.png` (64 x 64, i.e. 2 x the jar's 32 x 32) | yes |
| Moon (SC has none) | The eight vanilla phases, in the order of 14 §8.1 (inferred) | `minecraft:moon/full_moon`, `waning_gibbous`, `third_quarter`, `waning_crescent`, `new_moon`, `waxing_crescent`, `first_quarter`, `waxing_gibbous` | `.../environment/celestial/moon/<phase>.png` (64 x 64 each, 2 x the jar's 32 x 32) | yes, all 8 |
| Clouds (SC has none) | Vanilla clouds, if drawn | `minecraft:environment/clouds` | none | no: built-in (the image is read by pixel; keep it 256 x 256, one pixel = 12 blocks, 14 §8.3) |

These rows only bind if a later SC revision adds a sun and moon. The built-in pack then ships a procedural disc
for each. They are listed here so the pack's files are accounted for.

### 6.2 Weather

SC §14.1 weather kinds map onto the pack's precipitation images (14 §8.2):

| Weather kind | Texture id | Pack file | Size | In pack |
|---|---|---|---|---|
| `cobolcraft:drizzle` | `minecraft:environment/rain` | `assets/minecraft/textures/environment/rain.png` | 128 x 512 | yes |
| `cobolcraft:hailstorm` | `minecraft:environment/snow` (inferred: pellets) | `.../environment/snow.png` | 128 x 512 | yes |
| `cobolcraft:clear` | none | none | | n/a |

Both pack files are 1 : 4 tall streak images. SC §14.5 says the texture repeats every one block vertically. For a
square image that is unchanged. The rule becomes: **the texture repeats every `height / width` blocks vertically**
(so 1 block for the built-in 16 x 16 images, 4 blocks for a 128 x 512 image), with `u` from 0 to 1 across the quad as
before and the scroll applied in the same units (inferred; the shipped client's own UV mapping was not traced, 14
open question 6). The built-in pack ships its 16 x 16 `drizzle` and `hailstorm` art at the paths
`minecraft:environment/rain` and `minecraft:environment/snow`.

### 6.3 Font

The text font (SC §18, 08 §10.10) is bound to the pack's `font/ascii.png`:

| Item | Value |
|---|---|
| Font definition | `assets/cobolcraft/font/default.json` stays. One `bitmap` provider: `file` `minecraft:font/ascii.png`, `height` 8, `ascent` 7, `chars` = sixteen strings of 16 characters, rows 0, 1 and 8 to 15 all `\u0000`, rows 2 to 7 the ASCII characters 0x20 to 0x7E in code order (row 7 ends with a `\u0000` after `~`). |
| Pack file | `assets/minecraft/textures/font/ascii.png`, 256 x 256: sixteen cells of 16 x 16 per row, so scale 0.5 (14 §10.3). In the pack. |
| Built-in art | The SC §18 glyphs written into a **128 x 128** image: the glyph for code c in the 8 x 8 cell at ((c mod 16) x 8, (c div 16) x 8). Rows 0, 1 and 8 to 15 are transparent. |
| Advances | The rule of 14 §10.3 applied to the cell as given (advance = trunc(0.5 + width x scale) + 1). For the built-in image (scale 1) it equals the SC §18 table. For the pack's image the advances follow its own ink; they match the built-in ones only when every glyph is an exact 2 x enlargement. A glyph can differ by 1 pixel. (inferred) |
| Cells not listed in `chars` | Never drawn. Rows 9 to 15 of the pack file (Latin-1 and box-drawing glyphs) stay unused. |
| Other pack fonts | `accented`, `nonlatin_european`, `ascii_sga`, `asciillager`: unused. |

### 6.4 GUI sprites and sheets

Our screens and HUD (CC-0001; SC has no sprite art) bind by role to the vanilla sprite ids of 14 §6.1. They are all in
the `gui` atlas, so a sprite id is the path under `gui/sprites/`. The pack's coverage of the set our client uses:

| Role | Sprite ids | Pack |
|---|---|---|
| Hotbar, selection, off-hand slots | `minecraft:hud/hotbar`, `hud/hotbar_selection`, `hud/hotbar_offhand_left`, `hud/hotbar_offhand_right` | all 4 |
| Health | `hud/heart/container`, `full`, `half`, and `container_blinking`, `full_blinking`, `half_blinking` | all 6 |
| Food | `hud/food_empty`, `food_half`, `food_full` | all 3 |
| Crosshair | `hud/crosshair` | **missing** |
| Slot | `container/slot`, `container/slot_highlight_back`, `container/slot_highlight_front` | `slot` yes; both highlights **missing** |
| Buttons and fields | `widget/button`, `button_disabled`, `button_highlighted`, `text_field`, `text_field_highlighted`, `slider`, `slider_highlighted`, `slider_handle`, `slider_handle_highlighted`, `checkbox`, `checkbox_highlighted`, `checkbox_selected`, `checkbox_selected_highlighted`, `scroller` | all 14 |
| Scroll bar track | `widget/scroller_background` | **missing** |
| Tooltips | `tooltip/background`, `tooltip/frame` | both |
| Recipe book | `recipe_book/button`, `button_highlighted`, `tab`, `tab_selected`, `slot_craftable`, `slot_many_craftable`, `slot_uncraftable`, `slot_many_uncraftable`, `page_backward`, `page_backward_highlighted`, `page_forward`, `page_forward_highlighted`, `filter_enabled`, `filter_enabled_highlighted`, `filter_disabled`, `filter_disabled_highlighted`, `overlay_recipe`, `crafting_overlay`, `crafting_overlay_highlighted`, `crafting_overlay_disabled`, `crafting_overlay_disabled_highlighted` | all 21 |
| Inventory screen | sheet `minecraft:gui/container/inventory` (whole image, logical 256 x 256, image area 176 x 166, slot positions 14 §6.2) | yes (512 x 512) |
| Crafting bench screen | sheet `minecraft:gui/container/crafting_table` | yes (512 x 512), but its slot layout is not yet documented (14 open question 5): bind after that is read; until then use a built-in `cobolcraft:gui/container/bench` |
| Recipe book sheet | `minecraft:gui/recipe_book` | yes (512 x 512) |

The GUI set has 58 ids: 3 sheets (inventory, crafting table, recipe book) and 55 sprites (14 hud, 3 container, 15 widget,
2 tooltip, 21 recipe book). The pack has 54 of them (3 sheets and 51 sprites). **4 sprites are missing**: `hud/crosshair`,
`container/slot_highlight_back`, `container/slot_highlight_front`, `widget/scroller_background`.

The built-in pack must ship an original, simple version of every id in the table, because with no user pack the client
must still draw. The recipes (flat colours, SC §1.4.1 vocabulary) are a later SC addition. For the four ids the pack
lacks, this design fixes them now (inferred), since a pack-only run would otherwise show the stripes:

| Sprite id | Size | Scaling | Recipe |
|---|---|---|---|
| `minecraft:hud/crosshair` | 15 x 15 | stretch (none) | `L(0, 7, 14, 7, 1)` and `L(7, 0, 7, 14, 1)` in `#FFFFFF` |
| `minecraft:container/slot_highlight_front` | 16 x 16 | stretch | every pixel `#FFFFFF` at alpha 40 % (102) |
| `minecraft:container/slot_highlight_back` | 1 x 1 | stretch | transparent |
| `minecraft:widget/scroller_background` | 6 x 32 | `nine_slice` width 6, height 32, border 1 | every pixel `#000000` at alpha 40 % (102) |

(`L` is the line of SC §1.4.1, with the 15 x 15 coordinate range.)

---

## 7. Colormap, particles, trims and other categories

Our client has no use for a category the stand-in does not draw. The mapping:

| Category | Stand-in use | Binding |
|---|---|---|
| `colormap/grass` | The turf tint (section 8.2) | The built-in pack supplies `minecraft:colormap/grass` (not in the pack). |
| `colormap/foliage`, `dry_foliage` | None (no leaves) | not read. |
| `particle` | None in SC; CC-0001 mentions none | none: no `particles/*.json` ships, so no particle textures are read. |
| `trims`, `palettes`, `entity/equipment` | None (no armour) | none. |
| `mob_effect` | None (no status effects) | none. |
| `painting`, `map` | None | none. |
| `misc` | The glint, vignette, shadow, nausea and so on are not drawn | none. A later vignette or shadow is built-in (the pack has neither). |
| `gui/title`, `gui/realms`, `gui/signs`, `advancements` | The title screen uses text (08 §10.8.6) | none. |

---

## 8. Tinting and the break overlay

### 8.1 Break stage recipes (new in SC §1.4.2, built-in art)

The built-in pack ships ten 16 x 16 overlays at `minecraft:block/destroy_stage_0` to `destroy_stage_9`. Stage N (0 to 9):
every pixel is transparent except those with n < 8 + 9N, where n = H(100, 101, 115, 116, 114, 111, 121, x, y) mod 100
(the ASCII bytes of `destroy`, then x and y; SC §1.4.1). Such a pixel is `#404040` at alpha 255: the crumbling blend (12 §4.3) multiplies the block colour by 2 x 0.25 = 0.5 there, and the
transparent pixels are discarded. The pattern therefore only grows with N.

Check values: n at (0, 0) = 51, at (15, 15) = 55, at (7, 7) = 3. The number of dark pixels of stages 0 to 9 is
20, 42, 64, 87, 110, 135, 160, 187, 211, 231.

### 8.2 Grass tint (turf)

The pack's grass block textures are grey-scale templates (the vanilla client tints them from a colormap, 14 §4.1 and §9),
and the pack has no colormap. The design:

| Item | Value |
|---|---|
| Tint index | The `turf` top face, the overlay of the side faces, and the `turf` item icon use `tintindex` 0. The tint source is the grass colormap with a fixed temperature 0.8 and downfall 0.4 for all biomes. Per-biome variation is deferred (open question 4). The turf block model has a second element for the overlay: the same box, side faces only, texture `minecraft:block/grass_block_side_overlay`, `tintindex` 0. Resolving 08's open question 10 for this block. |
| Lookup | Per 14 §9: d' = 0.4 x 0.8 = 0.32; x = 50; y = 173; array index 173 x 256 + 50 = 44338. |
| Built-in colormap | `minecraft:colormap/grass`: 256 x 256, every pixel `#73D054`. The lookup then always returns `#73D054`. |
| Built-in art, top | `minecraft:block/grass_block_top`: Noise `turf_top` with fill `#AFAFAF`, 20 % `#989898`, 10 % `#CCCCCC`. Multiplied by `#73D054`: fill gives (79, 143, 58) = `#4F8F3A` (exact); the 20 % pick gives (69, 124, 50) against SC `#447D32` = (68, 125, 50) (each channel off by at most 1); the 10 % pick gives (92, 166, 67) against SC `#5CA044` = (92, 160, 68), so its **green is 6 too high**. A single tint cannot match all three picks, because their green-to-red ratios differ (1.81, 1.84, 1.74). |
| Built-in art, side | `minecraft:block/grass_block_side`: the `loam` texture. `minecraft:block/grass_block_side_overlay`: pixel (x, y) is the grey `turf_top` pixel when y <= 3, or y = 4 and x is even; every other pixel is transparent. |
| Effect on SC §1.5 check values | The values of `turf_top` and `turf_side` describe the **tinted result**, not the PNG. It matches SC for the fill and the 20 % pick within 1 per channel, and for the 10 % pick within 1 in red and blue but 6 in green. This relaxes "pixel for pixel" (SC-004) for these two textures; operator approval is open question 2. |
| With the pack | The pack's grey `grass_block_top` and overlay multiplied by `#73D054` give a green. The look differs from vanilla, since vanilla's tint is per biome. |

---

## 9. Fallback, coverage, unused files

### 9.1 Fallback chain

For every asset id the client asks for, resolution goes down the pack stack (08 §3.1) and stops at the first hit:

1. **User packs**, top of the user's list first (08 §3.1), including server-pushed packs above them (08 §9.6).
2. **The built-in `cobolcraft` pack** (bottom, required, 08 §10).
3. **Missing-texture stripes** (SC §1.4.2, engine-generated): a block, item, GUI-sprite or particle sprite that nothing supplies;
   or, for whole-image textures (entity, environment), the stripes at the stand-in's size. The missing font glyph (SC §18)
   stands in for a character with no glyph.

A hit in a user pack at a path never makes the client try the built-in file for the **same** id. A `.mcmeta` is searched as
14 §2.3 (1) says: from the top pack down to, and including, the pack that supplied the PNG. So a user PNG with no
`.mcmeta` is used with stretch scaling and no animation even if the built-in pack has a `.mcmeta` for that path.

An asset the **built-in** pack also lacks (for example a stand-in id a later revision adds before its recipe exists)
is shown as stripes and logged once with the id.

**Texture-size differences need no handling in the chain** (14 §3.5, §5.2, §6.3): a 32 x 32 user sprite and a 16 x 16
built-in sprite share an atlas; an entity or environment image is sampled by fractions; a GUI sheet or sprite is addressed
in logical units. The exceptions: a colormap must be 256 x 256 (14 §9) and a clouds image's size changes the layout
(14 §8.3). A user colormap of another size is a defect of that pack: the client ignores it, with a log line, and uses the
built-in one (inferred rule).

### 9.2 Namespaces are enumerated

The client builds the namespace set as the union over all packs of the directory names under `assets/` (08 §1.3,
14 §2.2). With the built-in pack and Faithful loaded, that set is `cobolcraft` and `minecraft` from the built-in
pack, and `minecraft`, `forge`, `neoforge`, `modmenu` and `fabric` from Faithful: **six** namespaces. Rules:

1. A texture the client looks up **by id** is looked up only in the id's own namespace (14 §2.2).
2. An atlas `directory` source scans every namespace, so the sprites `forge:item/mask/bucket_fluid` and similar
   (4 forge and 4 neoforge item PNG files) join the item atlas as extra sprites.
   They are unused, and harmless. A client MAY skip a namespace that no stand-in asset names, to save memory (inferred).
3. A namespace with an invalid name is ignored in whole (08 §1.3); none of the five fails the check.
4. The pack's `minecraft:` files are read as an additional namespace next to `cobolcraft:`. No file of
   `minecraft:` is ever read from the jar; the built-in pack supplies the `minecraft:` data files the stand-in needs (9.3).

### 9.3 What the built-in pack must still supply

The pack has no data files. The built-in pack therefore supplies, in the namespaces shown:

| Kind | Where | Contents |
|---|---|---|
| Block states, block models, item models, item definitions | `cobolcraft:` (their keys are `cobolcraft:`, 1.2) | As 08 §10.4 to §10.7, with texture ids of sections 3 and 4. The `turf` model has the overlay element. |
| Atlas definitions | `minecraft:` ([engine name] paths) | `blocks`, `items` as 08 §10.2, plus `gui` (`directory` `gui/sprites`, prefix empty). A `celestials` definition if the sky is drawn. |
| Language | `cobolcraft:` | `lang/en_us.json` as 08 §10.8 |
| Font definition | `cobolcraft:` | `font/default.json` (6.3) |
| Procedural textures | `minecraft:` | the 11 block ids of section 3, 6 item ids of section 4, 10 break stages, 1 colormap, 2 environment, 1 font image, and the GUI set of section 6.4 |
| Procedural textures | `cobolcraft:` | `cardstack_end`, `cardstack_side`, `cardstack_side_punched`, `ledger_tile`, `goto_pad`; the three entity strips while the geometry change is not approved |
| Particle, trim, equipment, palette, post-effect files | none | not used by the stand-in |

### 9.4 Built-in file count

| Kind | Files |
|---|---|
| `pack.mcmeta` | 1 |
| Atlas definitions | 3 (`blocks`, `items`, `gui`) |
| Block PNG | 11 (`minecraft:`) + 5 (`cobolcraft:`) = 16 |
| Break stages | 10 |
| Item PNG | 6 |
| Entity PNG | 3 (strips; `cobolcraft:`; become 3 vanilla-layout files if section 5 is approved) |
| Environment PNG | 2 |
| Font PNG, font definition | 1 + 1 |
| Colormap | 1 |
| GUI PNG and sprites (6.4) | at least the four new sprites; the rest to be specified (about 96 more) |
| Template models, block models, item models, block states, item definitions, language | as 08 §10.9, plus one overlay model template |

### 9.5 Pack coverage report

For the stand-in content as bound above. "Needs" counts the files the client asks for from a user pack.

| Category | Needs | In Faithful | Lacks (built-in or stripes) |
|---|---|---|---|
| Block sprites (section 3) | 11 | 11 | none |
| Break stages (3.1) | 10 | 10 | none |
| Item sprites (section 4) | 6 | 6 | none |
| Entity textures (section 5; only if approved) | 3 | 3 | none |
| Environment: rain, snow (6.2) | 2 | 2 | none |
| Environment: sun and 8 moons (6.1; if drawn) | 9 | 9 | none |
| Environment: clouds (if drawn) | 1 | 0 | `environment/clouds` |
| Font image | 1 | 1 | none |
| Colormap | 1 | 0 | `colormap/grass` |
| GUI sprites and sheets (6.4) | 58 | 54 | `hud/crosshair`, `container/slot_highlight_back`, `container/slot_highlight_front`, `widget/scroller_background` |
| Stand-in entries with no vanilla equivalent | 5 block textures | | `cobolcraft:` built-in art (section 3): `cardstack` x 3, `ledger_tile`, `goto_pad` |

The files our client asks for from the pack: 11 block + 10 break stages + 6 item + 3 entity + 11 environment (2 weather,
9 sky) + 1 font + 54 GUI = **96** (the whole used set is 100 ids, of which the pack lacks the 4 GUI sprites). Of the
pack's 3931 PNG files, 96 are used (the 3 entity files only if section 5 is approved, and the 9 sky files only if a sky is
drawn). The other **3835** are unused.

### 9.6 Pack files the stand-in does not use

By category (PNG files under `assets/minecraft/textures/`):

| Category | In pack | Used (sections 3 to 6) | Unused |
|---|---|---|---|
| `block` | 1297 | 21 (11 + 10 stages) | 1276 (including the 10 `destroy_oit_stage_*`) |
| `item` | 832 | 6 | 826 (including `item/custom/redstone_torch`) |
| `entity` | 763 | 3 | 760 (every other mob, the 17 other player skins, the 85 equipment files, all layer files) |
| `gui` | 543 | 54 | 489 |
| `environment` | 13 | 11 | 2 (`end_sky`, `celestial/end_flash`) |
| `font` | 5 | 1 | 4 (`accented`, `nonlatin_european`, `ascii_sga`, `asciillager`) |
| `particle` | 297 | 0 | 297 |
| `trims` | 40 | 0 | 40 |
| `painting` | 52 | 0 | 52 |
| `map` | 42 | 0 | 42 |
| `mob_effect` | 40 | 0 | 40 |
| `misc` | 7 | 0 | 7 |
| **Total** | **3931** | **96** | **3835** |

The GUI used count is 54 present files: 3 sheets and 51 sprites. The crafting-table sheet is bound only after 14 open
question 5. The unused list is the complement of the used list in sections 3 to 6; a client's coverage command reproduces it.

Other unused content: `optifine/` (897 files); `models/item/redstone_torch.json`; the `forge`, `neoforge`, `modmenu` and
`fabric` namespaces (28 files); `pack.png`, `LICENSE.txt`; the one `.mcmeta` under `textures/` with no counterpart in the
jar (`misc/enchanted_item_glint.png.mcmeta`).

The pack's 30 PNG files with no counterpart in the 26.3 jar are all unused: `entity/rabbit/white_splotched`,
12 `entity/signs/<wood>` and 12 `entity/signs/hanging/<wood>` files (the jar has sign textures only under
`gui/signs/` and `gui/hanging_signs/`, so these look like an older sign location kept by the pack (inferred)), `gui/demo_background`, `gui/sprites/hud/locator_bar_player`, `item/custom/redstone_torch`,
`item/light` and `misc/enchanted_item_glint`.

---

## 10. Validation

Checkable facts for this document (a reviewer reproduces them with `unzip -l`, a PNG header reader and the
formulas of SC §1.4.1).

| # | Fact | Expected |
|---|---|---|
| D1 | SHA-256 of the pack | as in the header |
| D2 | Files in the pack, PNG under `assets/minecraft/textures/` | 3931; `.mcmeta` 206 |
| D3 | The 11 `minecraft:` block files of section 3 exist and are 32 x 32 | `bedrock`, `stone`, `dirt`, `grass_block_top`, `grass_block_side`, `grass_block_side_overlay`, `sand`, `glass`, `redstone_lamp`, `redstone_lamp_on`, `netherrack` |
| D4 | The 6 item files of section 4 exist and are 32 x 32 | `iron_pickaxe`, `iron_shovel`, `beef`, `cooked_beef`, `cake`, `amethyst_shard` |
| D5 | Entity files | `player/wide/steve` 128 x 128; `cow/cow_temperate` 128 x 128; `slime/slime` 128 x 64 |
| D6 | Environment files | `rain`, `snow` 128 x 512; `celestial/sun` and 8 moons 64 x 64 |
| D7 | `font/ascii.png` size | 256 x 256 |
| D8 | GUI: `hud/hotbar` 364 x 44; `widget/button` 400 x 40 with `nine_slice` 200 x 20, border 20, 4, 20, 4; `container/slot` 36 x 36; `container/inventory` 512 x 512 | |
| D9 | Pack GUI sprites missing from the 58-id GUI set | exactly `hud/crosshair`, `container/slot_highlight_back`, `container/slot_highlight_front`, `widget/scroller_background` |
| D10 | Pack has no `textures/colormap/`, no `textures/palettes/`, no `atlases/`, `blockstates/`, `lang/` | true |
| D11 | Grass lookup at temperature 0.8, downfall 0.4 | index 44338 (x = 50, y = 173) |
| D12 | Break stage dark-pixel counts, stages 0 to 9 | 20, 42, 64, 87, 110, 135, 160, 187, 211, 231 |
| D13 | Namespaces in the pack | `minecraft`, `forge`, `neoforge`, `modmenu`, `fabric` (5); with the built-in pack, 6 |
| D14 | Grey turf top picks times the built-in tint `#73D054` (each channel = grey x tint channel / 255, rounded half up) | `#AFAFAF` gives (79, 143, 58) = SC `#4F8F3A`; `#989898` gives (69, 124, 50) vs SC `#447D32` (68, 125, 50), off by 1 in red and green; `#CCCCCC` gives (92, 166, 67) vs SC `#5CA044` (92, 160, 68), green off by 6 |
| D15 | Built-in file count (9.4) | 16 block PNG, 10 break stages, 6 item, 3 entity, 2 environment, 1 font, 1 colormap |

---

## 11. Open questions

1. **Entity geometry (section 5.2).** Adopting the vanilla box layout for the player, grazer and cube mob lets a
   pack restyle them but changes how they look, and it changes SC §3, §12.6 and 08 §10.11. The operator must approve it,
   or the three stay `cobolcraft:` strips.
2. **SC-004 for turf (8.2).** The turf textures become grey templates tinted by a built-in colormap, so their
   check values apply to the tinted result: within 1 per channel for the fill and the 20 % pick, but the 10 % pick's
   green is 6 too high (a single tint cannot fit all three). Needs the operator's agreement to that tolerance, or turf
   stays `cobolcraft:` with no tint.
3. **Registry and wire-id implication.** This document moves only texture ids. Whether the block, item and entity keys
   themselves also move to `minecraft:` for entries with a vanilla equivalent (for example `cobolcraft:greystone` to
   `minecraft:stone`) is **not decided**. It would change the registry sync (04), the world files (07 §9), the
   language keys and every block-state and model file name of 08 §10, and it would tie the registry to the vanilla
   numbering. The texture binding of sections 3 to 5 works either way.
4. **Per-biome grass tint.** A fixed temperature and downfall is used for every biome (8.2). Whether the stand-in
   biomes (SC §4.3) should vary it is open.
5. **Equivalent choices marked "(inferred)"**: bedrock for baseplate, sand for grit, netherrack for slag, iron pickaxe
   and shovel for the tools, cake for the sod cake, amethyst shard for the dump shard, steve, cow and slime for the
   three entities, snow for the hailstorm.
6. **Built-in GUI art.** About 96 sprites need original built-in recipes (6.4). Not specified here beyond the four ids
   the pack lacks.
7. **Crafting bench screen.** Bind `crafting_table.png` after its layout is read (14 open question 5).
8. **Break-stage set.** Which of `destroy_stage_N` and `destroy_oit_stage_N` the client uses (14 open question 3); this
   design uses `destroy_stage_N` and asks the built-in and user packs for both only if the renderer needs it.
9. **Rain and snow period.** The repeat distance rule of 6.2 was chosen to keep 16 x 16 images as they are; it is a
   design choice, not a read value.
10. **Clouds and sky.** SC has no sun, moon or clouds. 6.1 only accounts for the pack's files.
