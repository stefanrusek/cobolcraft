# Faithful 32x pack mapping and the cobolcraft skin (design)

This is a CobolCraft design document. It has three jobs: (1) it records the facts about the operator's resource pack
`Faithful 32x - 26.3.zip` (section 2); (2) it fixes the **pack order** and how Faithful layers on the generated
vanilla pack and the built-in pack (section 9); (3) it defines the **optional Faithful skin** of the cobolcraft
world type, a built-in pack that points the invented `cobolcraft:` blocks and items at Faithful's `minecraft:`
textures (sections 3 to 5, 8.2).

The **standard** world type needs no mapping table. Its blocks, items, models and textures are the vanilla ones, in
the resource pack that the extraction tool generates from the user's jar ([../protocol/22-extraction-tool.md](../protocol/22-extraction-tool.md),
cited as "22 §n"), and Faithful applies to them directly by path (08 §1.6). The **cobolcraft** world type keeps its
own art under `cobolcraft:` ids in the built-in pack; without the skin Faithful has no effect on that content. The
behaviour of the shipped client that this document relies on is in
[../protocol/14-texture-only-packs.md](../protocol/14-texture-only-packs.md) (cited as "14 §n"); the pack format and
the pack stack are [../protocol/08-resource-packs.md](../protocol/08-resource-packs.md) (cited as "08 §n"); the
content of the cobolcraft world type is [standin-content.md](standin-content.md) (cited as "SC §n"); the
decisions are in [README.md](README.md) (cited as "design README", with C7 the pack stack and decision 10 the skin).

| Item | Value |
|---|---|
| Operator decisions | Ticket CC-0001: the client must load and use this pack; `minecraft:` wherever a vanilla equivalent exists (so a pack applies by path); `cobolcraft:` where CobolCraft extends or diverges; the invented `cobolcraft:` content stays as a selectable world type. Design README decision 10: the Faithful skin is optional, off by default, covers blocks and items only, leaves `turf` out and keeps the entity strips (adopted default; the operator may overrule). |
| Scope of sections | Sections 2, 6, 7, 8.1, 9 and 10 apply to both world types. Sections 3, 4, 5 and 8.2 are **skin only** (cobolcraft world type, skin enabled). |
| Pack inspected | `Faithful 32x - 26.3.zip`, SHA-256 `596035002e8c369ca673b5b922cd532a38a2aaabe80f317f5ac4d5c7680c7bf2`, read as data with `unzip -l`, `unzip -p` and a PNG header reader (width and height only). Resource pack range 84 to 97. |
| Client artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in `docs/protocol/README.md`), static reading only. |
| Status of rows | A row marked "(inferred)" is a judgement call about which vanilla texture is the closest equivalent of an invented entry. It is a design choice, not a fact read from an artifact. |

No texture of the pack or of the jar is copied into the repository. The built-in pack keeps its own procedural
art (SC §1.4, §2, §3, §14.5, §18).

---

## 1. The namespace rule

### 1.1 Rule

The client resolves every asset by namespace and path. Both namespaces are enumerated (08 §1.3, 14 §2.2), and
resolution is **per asset**. The rule per world type (08 §1.6):

| World type | Texture ids | Faithful applies |
|---|---|---|
| Standard | `minecraft:` for everything. The generated pack and Faithful share the vanilla paths, so no rule and no table is needed. | Directly, by path. |
| Cobolcraft, no skin | `cobolcraft:` for the invented blocks, items, entities and weather kinds (08 §10.3). `minecraft:` only for the shared client parts (GUI, font, break stages, sky; sections 6 and 8.1). | Only on the shared `minecraft:` parts. |
| Cobolcraft, skin enabled | For an entry with a vanilla equivalent, the skin's models name a `minecraft:` texture; an entry with none keeps its `cobolcraft:` texture. | On every entry the skin points at `minecraft:`. |

"Vanilla equivalent" is decided per entry in sections 3 to 5, as a skin choice. A user pack replaces any file of a
lower pack by shipping the same path (08 §3.2), whichever namespace it is in. A pack author who wants to restyle a
`cobolcraft:` texture ships `assets/cobolcraft/...`.

### 1.2 What does not change

The skin moves **texture ids** only. The following stay as they are in 08 §10 and SC, because the registry keys and
wire ids of blocks, items and entities are untouched (the keys stay `cobolcraft:`, design README Own world type):

- Registry keys such as `cobolcraft:greystone`, and therefore the files named after them:
  `assets/cobolcraft/blockstates/greystone.json`, `assets/cobolcraft/models/block/greystone.json`,
  `assets/cobolcraft/models/item/greystone.json`, `assets/cobolcraft/items/greystone.json`, and the language keys
  (`block.cobolcraft.greystone`, 08 §10.8). The skin pack overrides the **model** files only; the block state,
  item definition and language files are the built-in pack's.
- Gameplay values, collision boxes, hardness and the recipes of SC.
- The recipe **names** used as noise seeds (SC §1.4.1: for example `greystone`, `loam`, `turf_top`) and all check
  values of SC §1.5. Without the skin the built-in art is written to `cobolcraft:` paths and every check value is
  valid, `turf` included (the skin leaves turf out, section 8.2).

### 1.3 Edits to 08 and SC

An earlier revision of this document listed edits that would have moved the cobolcraft content to `minecraft:`
paths. They are **not applied** and the list is removed. The edits that are applied (the world types, the namespace
rule, the pack stack, the built-in pack of the cobolcraft world type) are in design README Part 3.1; the SC edits
are its S rows.

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
| Colormaps (`colormap/grass`, `foliage`, `dry_foliage`) | **none** | Standard world type: the generated pack supplies them (22 §6) and Faithful's grey templates are tinted from them. The per-biome temperature, downfall, water, grass, foliage and dry foliage colours of the 67 shipped biomes, with the colormap lookups already computed, are in 43 §5.1; the block and item tint source assignments are in 43 §2 and §7. Cobolcraft world type: not read (the skin leaves turf out, section 8.2). |
| Palettes (`palettes/trim/*`, `trim_base`) | none | Needed only for trims; the generated pack supplies them; the cobolcraft world type has no armour. |
| Sun | `environment/celestial/sun.png`, 64 x 64 | Provided. |
| Moon | 8 phase files, 64 x 64 each, `environment/celestial/moon/` | Provided (all eight phase names of 14 §8.1). |
| Rain and snow | `environment/rain.png`, `snow.png`, 128 x 512 | Provided. |
| Clouds | none (`environment/clouds.png` absent) | Standard world type: the generated pack supplies the image. Cobolcraft world type: the built-in pack (section 6.1). |
| End sky and flash | `end_sky.png` 256 x 256; `celestial/end_flash.png` 128 x 128 | Provided; used by the standard End, not by the cobolcraft world type. |
| Entity layer textures | overlays, outer layers, armour, wool and eyes (2.1), and the 85 equipment files (which include the harnesses) | Provided; used by the standard world type, not by the cobolcraft world type. Eye files (`_eyes`) are drawn bright by the vanilla client. |
| Vignette, crosshair | vignette: none; crosshair `hud/crosshair`: none | Standard world type: the generated pack. Cobolcraft world type: built-in (sections 6.4 and 7). |

### 2.4 Fonts

The pack supplies five font images (14 §10.4) and no definition. Only `font/ascii.png` (256 x 256: 16 x 16 cells of 16 x 16 pixels)
is bound by the built-in font of the cobolcraft world type (section 6.3); the standard font definition of the generated pack binds the others.

---

## 3. Blocks

**Skin only.** This table applies to the cobolcraft world type with the skin enabled (design README decision 10).
Without the skin every block uses its built-in texture `cobolcraft:block/<name>` (08 §10.3, SC recipes). The standard
world type uses none of this section.

Texture ids the skin's block models name for every block of the cobolcraft world type (SC §1.1) and the pack file
each resolves to. The "Pack file" column is the path inside the pack (every file is 32 x 32 and present). "Built-in
art" is the recipe (SC §1.4.2) of the `cobolcraft:` texture that is used where the skin does not point at a
`minecraft:` texture. The skin needs the target texture from the generated pack or from Faithful (9.7).

| Stand-in block (face) | Skin target side | Sprite id | Pack file | In pack | Built-in art recipe (SC §1.4.2) |
|---|---|---|---|---|---|
| `baseplate` (all faces) | `minecraft:` (inferred: the unbreakable bottom layer is bedrock-like) | `minecraft:block/bedrock` | `assets/minecraft/textures/block/bedrock.png` | yes | `baseplate` |
| `greystone` (all) | `minecraft:` | `minecraft:block/stone` | `.../block/stone.png` | yes | `greystone` |
| `loam` (all) | `minecraft:` | `minecraft:block/dirt` | `.../block/dirt.png` | yes | `loam` |
| `turf`, top | `cobolcraft:` (left out of the skin: no tint, section 8.2) | `cobolcraft:block/turf_top` | none, use built-in | no | `turf_top` |
| `turf`, sides and bottom | `cobolcraft:` (left out of the skin) | `cobolcraft:block/turf_side`; bottom as built-in (`loam`) | none, use built-in | no | `turf_side`, `loam` |
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
| `crafting_bench`, top | `minecraft:` (the bench is the crafting block role, WT-22; the closest equivalent is the crafting table (inferred)) | `minecraft:block/crafting_table_top` | `.../block/crafting_table_top.png` | yes | `crafting_bench_top` (CORE-33) |
| `crafting_bench`, sides | `minecraft:` (equivalent chosen as for top (inferred)) | `minecraft:block/crafting_table_side` | `.../block/crafting_table_side.png` | yes | `crafting_bench_side` (CORE-33) |
| `crafting_bench`, bottom | `cobolcraft:` (as the built-in model: the bench is made of `ledger_tile`) | `cobolcraft:block/ledger_tile` | none, use built-in | no | `ledger_tile` |
| `void` | not drawn | none | none | n/a | none |

Note: the bench's bottom face is a fifth use of `cobolcraft:` art by the skin (after `turf`, the three `cardstack` ids and the `ledger_tile` and `goto_pad` blocks): it names `cobolcraft:block/ledger_tile`, and no new sprite id.

Counts: 8 blocks (baseplate, greystone, loam, grit, lucite, glowtube, slag, crafting_bench) are pointed at `minecraft:` by the skin,
using 10 sprite ids (bedrock, stone, dirt, sand, glass, lamp on, lamp, netherrack, crafting table top, crafting table side); the pack has all 10 (the crafting table's front texture is not used: the bench has one side texture). 4 blocks
(turf, cardstack, ledger_tile, goto_pad) stay `cobolcraft:`, using 7 sprite ids (`turf_top`, `turf_side`, the three
`cardstack` ids, `ledger_tile`, `goto_pad`); the pack has none of them, by design.

### 3.1 Break-stage overlays

Not skin only: the break indicator is shared client rendering (12 §4) and binds by `minecraft:` in both world types.
The standard world type gets the sprites from the generated pack; the built-in pack supplies them for the cobolcraft
world type (section 8.1). The break indicator draws the ten sprites `minecraft:block/destroy_stage_0` to
`destroy_stage_9` (14 §4.3). The pack has these ten, and ten `destroy_oit_stage_*` that are unused by us.

---

## 4. Items

**Skin only** (the standard world type uses the vanilla item definitions of the generated pack).

The item icon is the `layer0` sprite of the generated item model (08 §10.7). A block item keeps the block sprite as
its `layer0`, so a block item picks up the pack's block texture through section 3.

| Stand-in item | Namespace side | `layer0` sprite id | Pack file | In pack | Note |
|---|---|---|---|---|---|
| `baseplate`, `greystone`, `loam`, `turf`, `grit`, `cardstack`, `lucite`, `glowtube`, `ledger_tile`, `goto_pad`, `slag` (block items) | as their block | the block sprite of section 3: `turf` its built-in `cobolcraft:block/turf_top` (no tint); `cardstack` its end face; `glowtube` the lit face | as in section 3 | as in section 3 | Same file as the block. |
| `pry_bar` (hard-class tool) | `minecraft:` (inferred) | `minecraft:item/iron_pickaxe` | `assets/minecraft/textures/item/iron_pickaxe.png` | yes | Pickaxe for hard blocks. |
| `trowel` (soft-class tool) | `minecraft:` (inferred) | `minecraft:item/iron_shovel` | `.../item/iron_shovel.png` | yes | Shovel for soft blocks. |
| `grazer_flank` (food 3) | `minecraft:` | `minecraft:item/beef` | `.../item/beef.png` | yes | Raw meat. |
| `seared_flank` (food 8) | `minecraft:` | `minecraft:item/cooked_beef` | `.../item/cooked_beef.png` | yes | Cooked meat. |
| `sod_cake` (food 2) | `minecraft:` (inferred) | `minecraft:item/cake` | `.../item/cake.png` | yes | |
| `dump_shard` (crafting material, purple) | `minecraft:` (inferred) | `minecraft:item/amethyst_shard` | `.../item/amethyst_shard.png` | yes | |
| `nothing` | not drawn | none | none | n/a | |
| `crafting_bench` (block item, FR-027, WT-12) | `minecraft:` (equivalent as the block top (inferred)) | `minecraft:block/crafting_table_top` | `.../block/crafting_table_top.png` | yes | The `layer0` of `cobolcraft:item/crafting_bench` is the block's top sprite, as for `turf` (CORE-33); without the skin it is `cobolcraft:block/crafting_bench_top`. |

All 6 `minecraft:` item textures (and the bench's block sprite, section 3) are present in the pack, all 32 x 32.

A ground item (`cobolcraft:loose_item`) has no texture of its own (08 §10.11). The crafting bench block and item are
now in the content (cobolcraft-standard-core.md §5.1, §5.2) and their built-in art is recorded in CORE-33 of §5.10 there
(textures `crafting_bench_top`, `crafting_bench_side`, and the `ledger_tile` bottom).

**Coverage (FR-012, US5-2).** Every cobolcraft block (13 keys: `void` is not drawn, the other 12 are in the table of
section 3), every cobolcraft item (19 keys: `nothing` is not drawn, the other 18 are in the table above) and every
cobolcraft mob (`operator`, `sodgrazer`, `abend`, and `loose_item`, which shows its item icon) has a texture path in this
document (blocks section 3, items this section, mobs section 5.1). **No cobolcraft block, item or mob is unmapped.** A
future cobolcraft entry with no row here shows the missing-texture look (standin §1.4.2, 'missing texture') and is
never given an invented texture.

---

## 5. Mobs and the player figure

**Skin only, and not adopted by default.** The skin covers blocks and items; the three entities keep their
`cobolcraft:entity/operator`, `entity/sodgrazer` and `entity/abend` strips (08 §10.3) and the fixed boxes of SC §3
(design README decision 10). This section is the mapping a skin would use **if** the operator extends it to entities;
until then it is reference only, and Faithful has no effect on the three entities. The standard world type's mobs
use the generated pack's models and Faithful's textures by path.

### 5.1 Chosen equivalents (if the skin includes entities)

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
our boxes as they are would garble it. So the rule for entities has a precondition: **the skin's entity models adopt
the vanilla box layout (14 §5.4) for these three models**. The adopted default is that they do not (Open question 1),
so the skin leaves entities out.

If the operator approves the extension:

| Entity | Model the client builds (14 §5.4) | Texture declared size | Notes |
|---|---|---|---|
| operator | Humanoid: head 8 x 8 x 8, body 8 x 12 x 4, two arms, two legs, plus the hat and second skin layers | 64 x 64 | The pack file is 128 x 128 = 2 x. A 64 x 64 skin from a server also works (a mismatch of scale is free). Slim arms use the `slim` file (3-wide arms). |
| sodgrazer | Cow: head, snout, body (rotated), four legs; horns and udder optional | 64 x 64 | The pack file is 2 x. |
| abend | Slime: outer shell 8 x 8 x 8 drawn translucent, inner body 6 x 6 x 6, two eyes, mouth | 64 x 32 | The pack file is 128 x 64 = 2 x. |

Collision boxes and every gameplay value (SC §3, §12) are unchanged. The model is scaled uniformly so that its
height matches the entity's collision height (inferred); this is a visual choice only.
The skin pack would then ship, for the cobolcraft entity models, original procedural textures in the vanilla layouts
(new recipes for SC §3, in the same style: flat colours and noise, using the operator's colours `#3A5A9A`, `#5E7A3C`
and `#2E2A4F`). Their size is the declared size (64 x 64, 64 x 64, 64 x 32); it is the declared size, not the pack's
2 x, that the SC recipe fixes.

**Without the extension (the default)**, the cobolcraft world type keeps the current boxes and the
`cobolcraft:entity/operator`, `entity/sodgrazer` and `entity/abend` strips of 08 §10.3, and a user pack cannot restyle
them except by shipping those `cobolcraft:` paths. The three rows of 5.1 then read "none, use built-in".

---

## 6. Environment, GUI and font

Shared client UI and sky bind by `minecraft:` in **both** world types (design README C5, C7). In the standard world
type the generated pack supplies every id of this section and Faithful replaces it by path. In the cobolcraft world
type the built-in pack must supply them too, because that world type runs with no jar (22 §9.1); the generated pack
and Faithful then replace the built-in files by path. Section 6.2 differs: its skin binding is skin only.

### 6.1 Sky

| Stand-in | Equivalent | Texture id | Pack file | In pack |
|---|---|---|---|---|
| Sun (the standard sky model replaces the colour sky of SC §4.8, 12 §3) | Vanilla sun | `minecraft:sun` (`celestials` atlas) | `assets/minecraft/textures/environment/celestial/sun.png` (64 x 64, i.e. 2 x the jar's 32 x 32) | yes |
| Moon | The eight vanilla phases, in the order of 14 §8.1 | `minecraft:moon/full_moon`, `waning_gibbous`, `third_quarter`, `waning_crescent`, `new_moon`, `waxing_crescent`, `first_quarter`, `waxing_gibbous` | `.../environment/celestial/moon/<phase>.png` (64 x 64 each, 2 x the jar's 32 x 32) | yes, all 8 |
| Clouds | Vanilla clouds (12 §3.6) | `minecraft:environment/clouds` | none | no: generated pack (standard) or built-in (cobolcraft; the image is read by pixel, 256 x 256, one pixel = 12 blocks, 14 §8.3) |

Sky, sun, moon and clouds are shared (design README C5; 12 §3). The built-in pack therefore needs a procedural sun,
eight moon phases and a clouds image for the cobolcraft world type; their recipes are not yet specified (Open
question 12).

### 6.2 Weather

The standard world type draws precipitation with `minecraft:environment/rain` and `snow` (14 §8.2); the generated
pack supplies them and Faithful replaces them by path. **Skin only:** in the cobolcraft world type the kinds
`drizzle` and `hailstorm` are skins of rain and thunder (design README decision 5), and without the skin they use the
built-in art `cobolcraft:environment/drizzle` and `hailstorm` (08 §10.3). With the skin, SC §14.1 weather kinds map
onto the pack's precipitation images:

| Weather kind | Texture id | Pack file | Size | In pack |
|---|---|---|---|---|
| `cobolcraft:drizzle` | `minecraft:environment/rain` | `assets/minecraft/textures/environment/rain.png` | 128 x 512 | yes |
| `cobolcraft:hailstorm` | `minecraft:environment/snow` (inferred: pellets) | `.../environment/snow.png` | 128 x 512 | yes |
| `cobolcraft:clear` | none | none | | n/a |

Both pack files are 1 : 4 tall streak images. SC §14.5 says the texture repeats every one block vertically. For a
square image that is unchanged. The rule becomes: **the texture repeats every `height / width` blocks vertically**
(so 1 block for the built-in 16 x 16 images, 4 blocks for a 128 x 512 image), with `u` from 0 to 1 across the quad as
before and the scroll applied in the same units (inferred; the shipped client's own UV mapping was not traced, 14
open question 6). The built-in pack keeps its 16 x 16 `drizzle` and `hailstorm` art at their `cobolcraft:` paths, so the repeat rule
applies per image. How the renderer picks a texture per kind, since the standard renderer picks rain or snow by
biome, is Open question 13.

### 6.3 Font

Shared. The standard world type uses the generated pack's font definition, and Faithful's font images replace the
vanilla ones by path. The cobolcraft world type's font (SC §18, 08 §10.10) is bound to `minecraft:font/ascii.png`,
which the generated pack and Faithful replace by path:

| Item | Value |
|---|---|
| Font definition | `assets/cobolcraft/font/default.json` stays. One `bitmap` provider: `file` `minecraft:font/ascii.png`, `height` 8, `ascent` 7, `chars` = sixteen strings of 16 characters, rows 0, 1 and 8 to 15 all `\u0000`, rows 2 to 7 the ASCII characters 0x20 to 0x7E in code order (row 7 ends with a `\u0000` after `~`). |
| Pack file | `assets/minecraft/textures/font/ascii.png`, 256 x 256: sixteen cells of 16 x 16 per row, so scale 0.5 (14 §10.3). In the pack. |
| Built-in art | The SC §18 glyphs written into a **128 x 128** image: the glyph for code c in the 8 x 8 cell at ((c mod 16) x 8, (c div 16) x 8). Rows 0, 1 and 8 to 15 are transparent. |
| Advances | The rule of 14 §10.3 applied to the cell as given (advance = trunc(0.5 + width x scale) + 1). For the built-in image (scale 1) it equals the SC §18 table. For the pack's image the advances follow its own ink; they match the built-in ones only when every glyph is an exact 2 x enlargement. A glyph can differ by 1 pixel. (inferred) |
| Cells not listed in `chars` | Never drawn. Rows 9 to 15 of the pack file (Latin-1 and box-drawing glyphs) stay unused. |
| Other pack fonts | `accented`, `nonlatin_european`, `ascii_sga`, `asciillager`: unused. |

### 6.4 GUI sprites and sheets

Shared. Our screens and HUD bind by role to the vanilla sprite ids of 14 §6.1; the standard world type reads them
from the generated pack. The set below is the minimum of the HUD, inventory, crafting and options screens; it
extends to the screens of design README GAP-19 as they are implemented (Open question 14). They are all in
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
| Crafting bench screen | sheet `minecraft:gui/container/crafting_table` (logical 256 x 256, slot layout 12 §5.6b) | yes (512 x 512) |
| Recipe book sheet | `minecraft:gui/recipe_book` | yes (512 x 512) |

The GUI set has 58 ids: 3 sheets (inventory, crafting table, recipe book) and 55 sprites (14 hud, 3 container, 15 widget,
2 tooltip, 21 recipe book). The pack has 54 of them (3 sheets and 51 sprites). **4 sprites are missing**: `hud/crosshair`,
`container/slot_highlight_back`, `container/slot_highlight_front`, `widget/scroller_background`.

The built-in pack must ship an original, simple version of every id in the table, because the cobolcraft world type with
no generated pack and no user pack must still draw (22 §9.1, design README C11, GAP-34). In the standard world type the
generated pack covers the four ids that Faithful lacks. The recipes (flat colours, SC §1.4.1 vocabulary) are a later SC addition. For the four ids the pack
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

For the cobolcraft world type, the client has no use for a category its content does not draw. The standard world type
uses every category the generated pack carries, and Faithful applies by path. The cobolcraft mapping:

| Category | Stand-in use | Binding |
|---|---|---|
| `colormap/grass` | None: the skin leaves turf out (section 8.2) | not read. Biome tinting for the cobolcraft type, if wanted, is GAP-34. |
| `colormap/foliage`, `dry_foliage` | None (no leaves) | not read. |
| `particle` | None in SC | none unless the built-in pack ships particle definitions (GAP-34); the built-in pack then also carries their textures. |
| `trims`, `palettes`, `entity/equipment` | None (no armour) | none. |
| `mob_effect` | None (no status effects) | none. |
| `painting`, `map` | None | none. |
| `misc` | The glint, vignette, shadow, nausea and so on are not drawn | none. A later vignette or shadow is built-in (the pack has neither). |
| `gui/title`, `gui/realms`, `gui/signs`, `advancements` | The title screen uses text (08 §10.8.6) | none. |

---

## 8. Tinting and the break overlay

### 8.1 Break stage recipes (new in SC §1.4.2, built-in art)

Shared (3.1). The standard world type uses the generated pack's stages. The built-in pack ships ten 16 x 16 overlays at `minecraft:block/destroy_stage_0` to `destroy_stage_9`. Stage N (0 to 9):
every pixel is transparent except those with n < 8 + 9N, where n = H(100, 101, 115, 116, 114, 111, 121, x, y) mod 100
(the ASCII bytes of `destroy`, then x and y; SC §1.4.1). Such a pixel is `#404040` at alpha 255: the crumbling blend (12 §4.3) multiplies the block colour by 2 x 0.25 = 0.5 there, and the
transparent pixels are discarded. The pattern therefore only grows with N.

Check values: n at (0, 0) = 51, at (15, 15) = 55, at (7, 7) = 3. The number of dark pixels of stages 0 to 9 is
20, 42, 64, 87, 110, 135, 160, 187, 211, 231.

### 8.2 Grass tint (turf)

**Skin only, and not adopted by default.** The skin leaves `turf` out (design README decision 10), so no colormap, no
tint and no overlay model is needed, and the relaxation of SC-004 below is not taken: the built-in `turf_top` and
`turf_side` keep their SC check values. The section is kept as the design a skin would use if turf were added later
(Open question 2). The standard world type uses the generated pack's colormaps and the vanilla biome tint (14 §9).

The pack's grass block textures are grey-scale templates (the vanilla client tints them from a colormap, 14 §4.1 and §9),
and the pack has no colormap. The design:

| Item | Value |
|---|---|
| Tint index | The `turf` top face, the overlay of the side faces, and the `turf` item icon use `tintindex` 0. The tint source is the grass colormap with a fixed temperature 0.8 and downfall 0.4 for all biomes. Per-biome variation is deferred (Open question 4). The turf block model has a second element for the overlay: the same box, side faces only, texture `minecraft:block/grass_block_side_overlay`, `tintindex` 0. Resolving 08's open question 10 for this block, if turf joins the skin. |
| Lookup | Per 14 §9: d' = 0.4 x 0.8 = 0.32; x = 50; y = 173; array index 173 x 256 + 50 = 44338. |
| Built-in colormap | `minecraft:colormap/grass`: 256 x 256, every pixel `#73D054`. The lookup then always returns `#73D054`. |
| Built-in art, top | `minecraft:block/grass_block_top`: Noise `turf_top` with fill `#AFAFAF`, 20 % `#989898`, 10 % `#CCCCCC`. Multiplied by `#73D054`: fill gives (79, 143, 58) = `#4F8F3A` (exact); the 20 % pick gives (69, 124, 50) against SC `#447D32` = (68, 125, 50) (each channel off by at most 1); the 10 % pick gives (92, 166, 67) against SC `#5CA044` = (92, 160, 68), so its **green is 6 too high**. A single tint cannot match all three picks, because their green-to-red ratios differ (1.81, 1.84, 1.74). |
| Built-in art, side | `minecraft:block/grass_block_side`: the `loam` texture. `minecraft:block/grass_block_side_overlay`: pixel (x, y) is the grey `turf_top` pixel when y <= 3, or y = 4 and x is even; every other pixel is transparent. |
| Effect on SC §1.5 check values | The values of `turf_top` and `turf_side` describe the **tinted result**, not the PNG. It matches SC for the fill and the 20 % pick within 1 per channel, and for the 10 % pick within 1 in red and blue but 6 in green. This relaxes "pixel for pixel" (SC-004) for these two textures; operator approval would be Open question 2. |
| With the pack | The pack's grey `grass_block_top` and overlay multiplied by `#73D054` give a green. The look differs from vanilla, since vanilla's tint is per biome. |

---

## 9. Fallback, coverage, unused files

### 9.1 Fallback chain

The pack stack is design README C7 and 22 §8.1; the skin pack is added at level 2 (9.7). For every asset
id the client asks for, resolution goes down the stack (08 §3.1) and stops at the first hit. Bottom to top:

| Level | Pack | Present when |
|---|---|---|
| 1 | Built-in `cobolcraft` pack | always (required, fixed) |
| 2 | Faithful skin pack (built-in, optional, id `cobolcraft_faithful_skin`, 9.7) | the cobolcraft world type and the player enabled it; default off |
| 3 | Generated `vanilla` pack | the generated-pack check is `ok` (22 §8.2) |
| 4 | User packs in the user's order, including Faithful | enabled by the player, never automatically |
| 5 | Server-pushed packs (08 §9.6) | the server sent them |

Lookup goes from the top. If nothing supplies the id, the **missing-texture stripes** (SC §1.4.2, engine-generated)
stand in: for a block, item, GUI-sprite or particle sprite, or, for whole-image textures (entity, environment), the
stripes at the entity's or image's size. The missing font glyph (SC §18) stands in for a character with no glyph.

A hit in a higher pack at a path never makes the client try a lower file for the **same** id. A `.mcmeta` is
searched as 14 §2.3 (1) says: from the top pack down to, and including, the pack that supplied the PNG. So a user
PNG with no `.mcmeta` is used with stretch scaling and no animation even if a lower pack has a `.mcmeta` for that path.

An asset that **no** pack supplies (for example an id a later revision adds before its recipe exists) is shown as
stripes and logged once with the id. This is also what the skin shows for a `minecraft:` target when neither the
generated pack nor a user pack has it (9.7).

**Texture-size differences need no handling in the chain** (14 §3.5, §5.2, §6.3): a 32 x 32 user sprite and a 16 x 16
built-in sprite share an atlas; an entity or environment image is sampled by fractions; a GUI sheet or sprite is addressed
in logical units. The exceptions: a colormap must be 256 x 256 (14 §9) and a clouds image's size changes the layout
(14 §8.3). A user colormap of another size is a defect of that pack: the client ignores it, with a log line, and uses the
next lower one (inferred rule).

### 9.2 Namespaces are enumerated

The client builds the namespace set as the union over all packs of the directory names under `assets/` (08 §1.3,
14 §2.2). With the built-in pack, the generated pack and Faithful loaded, that set is `cobolcraft` and `minecraft` from the
built-in pack (and the skin pack), `minecraft` from the generated pack, and `minecraft`, `forge`, `neoforge`,
`modmenu` and `fabric` from Faithful: **six** namespaces. Rules:

1. A texture the client looks up **by id** is looked up only in the id's own namespace (14 §2.2).
2. An atlas `directory` source scans every namespace, so the sprites `forge:item/mask/bucket_fluid` and similar
   (4 forge and 4 neoforge item PNG files) join the item atlas as extra sprites.
   They are unused, and harmless. A client MAY skip a namespace that no stand-in asset names, to save memory (inferred).
3. A namespace with an invalid name is ignored in whole (08 §1.3); none of the five fails the check.
4. The `minecraft:` files of the generated pack and of Faithful are read as a namespace next to `cobolcraft:`. No file
   is read from the jar at run time; the generated pack carries the jar's files (22), and the built-in pack supplies the
   `minecraft:` files the cobolcraft world type needs when there is no generated pack (9.3).

### 9.3 What the built-in pack and the skin pack supply

Faithful has no data files, and the generated pack has none for `cobolcraft:`. For the cobolcraft world type the
built-in pack supplies:

| Kind | Where | Contents |
|---|---|---|
| Block states, block models, item models, item definitions | `cobolcraft:` | As 08 §10.4 to §10.7, with the `cobolcraft:` texture ids of 08 §10.3. |
| Atlas definitions | `minecraft:` ([engine name] paths) | `blocks`, `items` as 08 §10.2, plus `gui` (`directory` `gui/sprites`, prefix empty) and `celestials` for the sky. |
| Language | `cobolcraft:` | `lang/en_us.json` as 08 §10.8 |
| Font definition | `cobolcraft:` | `font/default.json` (6.3) |
| Procedural textures | `cobolcraft:` | the 15 block images of 08 §10.3 and the 2 bench images (`crafting_bench_top`, `crafting_bench_side`, section 3), 6 item images, 3 entity strips and 2 weather images of 08 §10.3 |
| Procedural textures | `minecraft:` | 10 break stages, 1 font image, the GUI set of 6.4, the sun, eight moon phases and clouds (6.1, recipes open) |

The **skin pack** (optional, off by default) supplies only block and item **model** files under `cobolcraft:` that
override the built-in ones with the `minecraft:` texture ids of sections 3 and 4, and, if the weather skin is on,
the weather binding of 6.2. It ships no texture. The `turf` models are not overridden. Its pack id, title and the
toggle are in 9.7.

### 9.4 Built-in file count

| Kind | Files |
|---|---|
| `pack.mcmeta` | 1 |
| Atlas definitions | 4 (`blocks`, `items`, `gui`, `celestials`) |
| Block PNG (`cobolcraft:`) | 17 (the 15 of 08 §10.3 plus `crafting_bench_top` and `crafting_bench_side`) |
| Break stages (`minecraft:`) | 10 |
| Item PNG | 6 |
| Entity PNG (strips) | 3 |
| Environment PNG (weather) | 2 |
| Font PNG, font definition | 1 + 1 |
| GUI PNG and sprites (6.4) | at least the four sprites of 6.4; the rest to be specified (about 96 more, GAP-34) |
| Sun, moon, clouds | 10 images; recipes to be specified |
| Template models, block models, item models, block states, item definitions, language | as 08 §10.9 |

The skin pack adds no PNG file and no more than one `pack.mcmeta` and the model overrides (8 block and 11 item models
at most).

### 9.5 Pack coverage report

For the standard world type a coverage report is a tool output (design README GAP-32), not a document. The table
below is for the skin of the cobolcraft world type (blocks and items) and the shared parts, against Faithful. "Needs"
counts the files the client asks for from a user pack.

| Category | Needs | In Faithful | Lacks (generated pack, built-in or stripes) |
|---|---|---|---|
| Block sprites (section 3, skin) | 8 | 8 | none |
| Break stages (3.1) | 10 | 10 | none |
| Item sprites (section 4, skin) | 6 | 6 | none |
| Entity textures (section 5; only if the skin is extended) | 0 (3) | 0 (3) | none |
| Environment: rain, snow (6.2, skin) | 2 | 2 | none |
| Environment: sun and 8 moons (6.1) | 9 | 9 | none |
| Environment: clouds | 1 | 0 | `environment/clouds` |
| Font image | 1 | 1 | none |
| GUI sprites and sheets (6.4) | 58 | 54 | `hud/crosshair`, `container/slot_highlight_back`, `container/slot_highlight_front`, `widget/scroller_background` |
| Entries with no vanilla equivalent | 7 block textures | | `cobolcraft:` built-in art (section 3): `turf` x 2, `cardstack` x 3, `ledger_tile`, `goto_pad` |

The files our client asks for from the pack: 10 block + 10 break stages + 6 item + 0 entity + 11 environment (2 weather,
9 sky) + 1 font + 54 GUI = **92** (the whole used set is 97 ids, of which the pack lacks the 4 GUI sprites and the clouds image). Of the pack's 3931 PNG files, 92 are used (the 2 weather files only with
the weather skin). The other **3839** are unused. The standard world type uses far more of the pack, and its coverage
is the tool's report.

### 9.6 Pack files the cobolcraft world type does not use

By category (PNG files under `assets/minecraft/textures/`), for the skin of sections 3 and 4 and the shared parts:

| Category | In pack | Used (sections 3, 4, 6, 8.1) | Unused |
|---|---|---|---|
| `block` | 1297 | 20 (10 + 10 stages) | 1277 (including the 10 `destroy_oit_stage_*`) |
| `item` | 832 | 6 | 826 (including `item/custom/redstone_torch`) |
| `entity` | 763 | 0 | 763 (every mob, the 18 player skins, the 85 equipment files, all layer files) |
| `gui` | 543 | 54 | 489 |
| `environment` | 13 | 11 | 2 (`end_sky`, `celestial/end_flash`) |
| `font` | 5 | 1 | 4 (`accented`, `nonlatin_european`, `ascii_sga`, `asciillager`) |
| `particle` | 297 | 0 | 297 |
| `trims` | 40 | 0 | 40 |
| `painting` | 52 | 0 | 52 |
| `map` | 42 | 0 | 42 |
| `mob_effect` | 40 | 0 | 40 |
| `misc` | 7 | 0 | 7 |
| **Total** | **3931** | **92** | **3839** |

The GUI used count is 54 present files: 3 sheets and 51 sprites. The unused list is the complement of the used list;
a client's coverage command reproduces it. The standard world type uses most of these files.

Other unused content: `optifine/` (897 files); `models/item/redstone_torch.json`; the `forge`, `neoforge`, `modmenu` and
`fabric` namespaces (28 files); `pack.png`, `LICENSE.txt`; the one `.mcmeta` under `textures/` with no counterpart in the
jar (`misc/enchanted_item_glint.png.mcmeta`).

The pack's 30 PNG files with no counterpart in the 26.3 jar are all unused: `entity/rabbit/white_splotched`,
12 `entity/signs/<wood>` and 12 `entity/signs/hanging/<wood>` files (the jar has sign textures only under
`gui/signs/` and `gui/hanging_signs/`, so these look like an older sign location kept by the pack (inferred)), `gui/demo_background`, `gui/sprites/hud/locator_bar_player`, `item/custom/redstone_torch`,
`item/light` and `misc/enchanted_item_glint`.

### 9.7 The skin pack: id, title, level and toggle (closes Open question 11)

Read from the 26.3 client jar (SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, the artifact of 13 §8) by static reading, and from
`pack.mcmeta` of `Faithful 32x - 26.3.zip`. The artifact has no notion of a world type, so the world-type rules below are
CobolCraft design; the identification, ordering and listing rules are read.

**What the artifact does (read).**

| Fact | Value | Where |
|---|---|---|
| Id of a pack bundled in the jar (`resourcepacks` directory of the pack source) | the entry's file name with a trailing `.zip` removed; no prefix | `BuiltInPackSource.pathToId` |
| Id of a folder pack | `file/<entry name>` (13 §8) | `FolderRepositorySource` |
| Fixed built-in ids | `vanilla` (the base pack), `programmer_art`, `high_contrast` | `ClientPackSource` |
| Title of a bundled pack | literal id, unless the id is `programmer_art` or `high_contrast`, which have language keys (`resourcePack.programmer_art.name` "Programmer Art", `resourcePack.high_contrast.name` "High Contrast"); the base pack is "Default" (`resourcePack.vanilla.name`), description "The default look and feel of Minecraft" | `ClientPackSource.getPackTitle` |
| Source label of built-in packs | "built-in" (`pack.source.builtin`); the list shows `title (built-in)` via `pack.nameAndSource` "%s (%s)" in grey | `PackSource` |
| Selection config (required, default position, fixed) of the base pack | required = true, BOTTOM, fixed = false | `ClientPackSource.VANILLA_SELECTION_CONFIG` |
| Selection config of every other bundled pack | required = false, TOP, fixed = false | `ClientPackSource.BUILT_IN_SELECTION_CONFIG` |
| Description of a pack | the `description` text of its `pack.mcmeta`; for a built-in pack with no file, a fixed in-code value | `Pack.readPackMetadata` |
| Compatibility | the `pack.mcmeta` format range is checked against the client's resource format, 26.3 = major 97 minor 1 (`version.json`); the Faithful range `min_format` 84, `max_format` 97 therefore includes it | `PackCompatibility.forVersion` |
| Available set | a map sorted by id string (so the Available list is in id order) | `PackRepository.discoverAvailable` |
| Selected list | lowest priority first; `setSelected` keeps the stored order and then inserts every **required** pack that is missing at its default position | `PackRepository.rebuildSelected` |
| Default position rule (`Pack$Position.insert`) | BOTTOM: insert at the lowest index after any packs that are both fixed and default-BOTTOM; TOP: insert at the highest index before any packs that are both fixed and default-TOP | `Pack$Position.insert` |
| Moving | up/down swaps with the neighbour unless the neighbour is fixed (`canMoveUp`, `canMoveDown`); the arrows and the click overlay are hidden only for a pack that is both fixed and required | `PackSelectionModel$EntryBase`, `TransferableSelectionList$PackEntry.showHoverOverlay` |
| Icon | the pack's `pack.png`, else `textures/misc/unknown_pack.png` (13 §8) | |
| `pack.mcmeta` of Faithful | one `pack` object: `description` "The go-to 32x resource pack.", `min_format` 84, `max_format` 97; files at the zip root: `LICENSE.txt`, `pack.mcmeta`, `pack.png`, `assets/` | the zip |

**Adopted values for CobolCraft (design, an operator may overrule).**

| Item | Value |
|---|---|
| Pack id | `cobolcraft_faithful_skin` (no prefix, lower case, like the artifact's built-in ids; it cannot collide with `file/...`) |
| Title | "Faithful Skin" (a literal, as for a bundled pack with no language key); the list shows `Faithful Skin (built-in)` |
| Description (one line) | "Uses Faithful 32x textures for CobolCraft blocks and items. Needs the generated vanilla pack or a Faithful pack." |
| Icon | none shipped; the list shows `textures/misc/unknown_pack.png`. In the jar this file exists only in the vanilla assets; a CobolCraft client gets it from the generated pack, from Faithful (which has a 128 x 128 `unknown_pack`, 2.1) if selected, or else from the built-in pack, which does not yet supply it (Open question 15). |
| Title, description and icon of the base pack `cobolcraft` | not read (the artifact has no such pack); adopted: title "CobolCraft", description "The built-in CobolCraft look", icon as the skin's (design, inferred) |
| Selection config | required = false, default position BOTTOM, fixed = false |
| Base pack `cobolcraft` | required = true, default position BOTTOM, **fixed = true**, so that BOTTOM inserts of other packs land above it |
| Generated `vanilla` pack | required = true when present, BOTTOM, fixed = false, as the artifact's base pack |
| Default state | not selected |
| Level when enabled | level 2: the BOTTOM rule puts it directly above `cobolcraft`, so below a generated `vanilla` pack and below every user pack and server pack (9.1). The player may move it with the arrows like any non-fixed pack; the rule then follows the stored order. |
| Stored form | the id is one of the `resourcePacks` entries (lowest priority first, 13 §8); example with the skin on and a generated pack: `resourcePacks:["cobolcraft","cobolcraft_faithful_skin","vanilla"]`; skin off: `resourcePacks:["cobolcraft","vanilla"]` |
| Pack format | built-in pack, always compatible; its range is the client's current resource format |

Worked example (enabling the skin, nothing else selected but the required packs): Selected, lowest first, is
`[cobolcraft, vanilla]` (cobolcraft is fixed at index 0, so `vanilla` sits at 1). The BOTTOM rule skips the fixed pack at
index 0 and inserts at index 1, giving `[cobolcraft, cobolcraft_faithful_skin, vanilla]`. With the Faithful zip already enabled on
top, `[cobolcraft, vanilla, file/Faithful 32x - 26.3.zip]` becomes `[cobolcraft, cobolcraft_faithful_skin, vanilla, file/Faithful 32x - 26.3.zip]`.

**Where the toggle is.** The skin is an entry of the ordinary resource pack screen (13 §8), not a separate option: it appears
in Available (click or arrow moves it to Selected) when off and in Selected when on, with the standard up/down arrows.
Design rules (inferred from the artifact's mechanics, not read as such). The jar bundles no optional pack instance (the ids `programmer_art` and `high_contrast` appear only as constants), so the TOP default of bundled packs is read from code with no instance to check it against; the skin's BOTTOM is a deliberate deviation from it. The skin can never go below the fixed `cobolcraft` pack (the arrows stop at a fixed neighbour), whereas a generated `vanilla` pack, not being fixed, can be swapped past it.
1. The repository always knows the skin pack (it is always in the available set), so its id is never dropped from
   `resourcePacks` by the "doesn't seem to exist anymore" rule. Mechanism for rule 2: in the hidden mode the screen's
   Available and Selected lists exclude the skin id; the commit rebuilds the selection from the shown lists, so if the skin
   was selected when the screen opened, the commit re-inserts it at the index it had in the stored order (and a hidden
   unselected skin stays unselected). The stored choice is therefore unchanged.
2. The screen lists the skin only while the world being created or opened is of the cobolcraft type (the screen
   opened from the world-creation dialog, or from the options of a cobolcraft world). From the title screen's options with
   no world, and in a standard-type world, the skin entry is hidden and the choice already stored is kept unchanged.
3. The skin has an effect only in a cobolcraft-type world; in a standard-type world the pack stack ignores it.
4. The search box and the other behaviours of 13 §8 apply to it unchanged.

**A skin target nobody supplies.** Unchanged from 9.1: the missing-texture stripes stand in, and the id is logged once.
The pack's own description (above) tells the player what it needs. The alternative (hide the skin while the generated pack
is absent and no Faithful pack is selected) is not adopted.

---

## 10. Validation

Checkable facts for this document (a reviewer reproduces them with `unzip -l`, a PNG header reader and the
formulas of SC §1.4.1). D1 to D13 are facts about the pack and hold for both world types. D14 is reference only.

| # | Fact | Expected |
|---|---|---|
| D1 | SHA-256 of the pack | as in the header |
| D2 | Files in the pack, PNG under `assets/minecraft/textures/` | 3931; `.mcmeta` 206 |
| D3 | The 11 `minecraft:` block files exist and are 32 x 32; the skin uses 8 (the other 3 are the turf files of 8.2, not in the skin) | `bedrock`, `stone`, `dirt`, `grass_block_top`, `grass_block_side`, `grass_block_side_overlay`, `sand`, `glass`, `redstone_lamp`, `redstone_lamp_on`, `netherrack` |
| D4 | The 6 item files of section 4 exist and are 32 x 32 | `iron_pickaxe`, `iron_shovel`, `beef`, `cooked_beef`, `cake`, `amethyst_shard` |
| D5 | Entity files (section 5, reference only by default) | `player/wide/steve` 128 x 128; `cow/cow_temperate` 128 x 128; `slime/slime` 128 x 64 |
| D6 | Environment files | `rain`, `snow` 128 x 512; `celestial/sun` and 8 moons 64 x 64 |
| D7 | `font/ascii.png` size | 256 x 256 |
| D8 | GUI: `hud/hotbar` 364 x 44; `widget/button` 400 x 40 with `nine_slice` 200 x 20, border 20, 4, 20, 4; `container/slot` 36 x 36; `container/inventory` 512 x 512 | |
| D9 | Pack GUI sprites missing from the 58-id GUI set | exactly `hud/crosshair`, `container/slot_highlight_back`, `container/slot_highlight_front`, `widget/scroller_background` |
| D10 | Pack has no `textures/colormap/`, no `textures/palettes/`, no `atlases/`, `blockstates/`, `lang/` | true |
| D11 | Grass lookup at temperature 0.8, downfall 0.4 (8.2, reference only) | index 44338 (x = 50, y = 173) |
| D12 | Break stage dark-pixel counts, stages 0 to 9 | 20, 42, 64, 87, 110, 135, 160, 187, 211, 231 |
| D13 | Namespaces in the pack | `minecraft`, `forge`, `neoforge`, `modmenu`, `fabric` (5); with the built-in pack, 6 |
| D14 | (8.2, reference only) Grey turf top picks times the built-in tint `#73D054` (each channel = grey x tint channel / 255, rounded half up) | `#AFAFAF` gives (79, 143, 58) = SC `#4F8F3A`; `#989898` gives (69, 124, 50) vs SC `#447D32` (68, 125, 50), off by 1 in red and green; `#CCCCCC` gives (92, 166, 67) vs SC `#5CA044` (92, 160, 68), green off by 6 |
| D15 | Built-in file count (9.4) | 17 block PNG, 10 break stages, 6 item, 3 entity, 2 environment, 1 font, 4 atlas definitions; no colormap |

---

## 11. Open questions

Status of the ten earlier questions, then the gaps found while relabelling. A question marked "adopted default" is
the design README's default (decision 10); the operator may overrule it.

1. **Entity geometry (section 5.2).** Closed, adopted default: the skin covers blocks and items; the three entities
   keep their strips. Section 5 stays as reference if the operator extends the skin.
2. **SC-004 for turf (8.2).** Lapsed, adopted default: the skin leaves turf out, so no tolerance is needed and the
   SC check values stand.
3. **Registry and wire-id implication.** Decided: the cobolcraft keys stay `cobolcraft:`; the standard world type
   uses `minecraft:` keys (design README, Own world type).
4. **Per-biome grass tint.** Lapsed with question 2 for the cobolcraft world type; the standard world type uses the
   colormap rule (14 §9, 43 §3 and §5.1).
5. **Equivalent choices marked "(inferred)"**: bedrock for baseplate, sand for grit, netherrack for slag, iron pickaxe
   and shovel for the tools, cake for the sod cake, amethyst shard for the dump shard, snow for the hailstorm
   (and, only if entities join the skin, steve, cow and slime). Skin choices only; kept as written, the operator may
   change them.
6. **Built-in GUI art.** Open and larger than before: about 96 sprites need original built-in recipes (6.4), because
   the cobolcraft world type must draw its UI with no vanilla pack (design README GAP-34). Only the four ids Faithful
   lacks are specified here.
7. **Crafting bench screen.** Resolved: the sheet is bound by 6.4, layout 12 §5.6b.
8. **Break-stage set.** Open (14 open question 3, 12 §4.1): `destroy_stage_N` or `destroy_oit_stage_N`. This design
   uses `destroy_stage_N`; a pack should supply both.
9. **Rain and snow period.** Open (14 open question 6): the repeat distance of 6.2 is a design choice, not a read
   value, and applies only to the skin.
10. **Clouds and sky.** Resolved: shared and specified (12 §3, CC-0007). Recipes for the built-in art: question 12.

New gaps:

11. **Skin pack placement and toggle.** Closed, adopted default, specified in 9.7 (id `cobolcraft_faithful_skin`, title "Faithful Skin", level 2, off by default, an entry of the resource pack screen shown only for a cobolcraft-type world). Original question: the stack of 22 §8.1 and design README C7 has two required built-in packs and
    no optional third. Adopted default: the skin is an optional built-in pack at level 2 (above `cobolcraft`, below
    `vanilla`), off by default, shown only in the cobolcraft world type. Needs: its pack id and title, how the pack
    screen of 13 §8 lists it, and what a skin whose `minecraft:` targets nobody supplies shows (stripes today;
    alternative: the skin is selectable only when the generated pack is present).
12. **Built-in sky art.** Recipes for the procedural sun, eight moon phases and clouds image of the cobolcraft world
    type are not specified (6.1).
13. **Weather skin mechanism.** The standard renderer picks rain or snow by biome (14 §8.2); how the cobolcraft
    kinds `drizzle` and `hailstorm` select a texture, built-in or skin, is not specified (6.2).
14. **GUI id list.** The list of 6.4 stops at the HUD, inventory, crafting and options screens; the ids of the GAP-19
    menus (furnace, chest and so on) and their Faithful coverage are not enumerated.
15. **Built-in `unknown_pack` icon.** The built-in pack does not supply `minecraft:textures/misc/unknown_pack.png`; with no generated pack and no Faithful pack the skin and `cobolcraft` entries would show stripes as icons. Needs a recipe or an accepted stripe icon.
