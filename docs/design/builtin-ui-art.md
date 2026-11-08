# Built-in UI art, fallback UI texts, world type selection and missing-data screens

Status: design, round RS29 (closes GAP-34 of [README.md](README.md) Part 5 for the art, the font, the fallback texts of the new screens and the text-colour rules; the options screen texts are not supplied and stay open, Open question 13). Written from documents only: no artifact was
opened and no repository code was read. Every pixel value in this document comes from a recipe that was run once to
produce the check values of section 9; if a rule and a check value ever disagree, the document is wrong and is corrected
first (as in standin-content section 1.5).

Citations use the form "14 section 6" for docs/protocol documents ("12 section 5.6a"), "standin section 1.4.1" for
[standin-content.md](standin-content.md), "faithful section 6.4" for
[faithful-pack-mapping.md](faithful-pack-mapping.md) and "README Part 4, C11" for [README.md](README.md). Open
questions are numbered at the end (section 12). Each judgement call is marked **Decision UI-n** with its reason; the
decisions are indexed in section 11.

## 0. What this document does

The cobolcraft world type must run with no vanilla pack and no generated pack (README Part 4, C10 and C11). The user
interface (HUD, inventory, bench, recipe book, menus, options) uses the standard layouts of documents 12 and 13 in both
world types. So the built-in pack (08 section 10) has to draw all of that with original art. This document specifies:

1. every GUI sprite and whole-image GUI texture the built-in pack ships, each with an exact recipe, size, scaling and
   check value (sections 2 to 5, 9);
2. the text colours and the fallback UI texts that the new screens need (section 6);
3. the **world type selection** control on the Create New World screen and the world list (section 7);
4. the **missing-data message**: the screen, the title-screen banner, the states and the texts shown when the standard
   world type cannot be offered (section 8).

README Part 4, C11 also names "options" and "a fallback font and language set". The art for the options screen widgets
(sliders, checkboxes, buttons, section 4.5) and the font are supplied here. The **texts of the options screen** (13
section 7) are not: they are out of scope of this document and GAP-34 stays open for them (Open question 13). Until a
later round supplies those keys in the built-in `lang/en_us.json`, the lookup rule of 08 section 10.8 shows an unknown key as
the key itself, so the options screen of the cobolcraft world type would show raw key names.

What is reused and not repeated here:

| Existing item | Where | How it is used |
|---|---|---|
| Colours, `H`, noise, rectangle, line, triangle, alpha rule | standin section 1.4.1 | All recipes below use this vocabulary; section 2 only adds to it. |
| Break-stage recipe (10 overlays) | faithful section 8.1 | Reused unchanged (section 4.9); the second set (`destroy_oit_stage_*`) is added (Decision UI-9). |
| `hud/crosshair` and `widget/scroller_background` recipes | faithful section 6.4 | Reused unchanged (sections 4.1, 4.5). |
| `container/slot_highlight_front` and `_back` recipes | faithful section 6.4 | **Replaced** (Decision UI-8): 12 section 5.6 gives their size as 24 x 24, which the earlier design did not have. |
| Bitmap font (95 glyphs, advances, missing glyph) | standin section 18, 08 section 10.9 and 10.10 | Unchanged. The four font definition files and the font name `minecraft:default` are those of 08 section 10.10 (this document follows 08, not faithful section 6.3, which is superseded, section 5.4). Section 4.12 only fixes the 128 x 128 image and its check value. |
| Missing-texture stripes | standin section 1.4.2, README decision 12 | Unchanged, engine-generated. |
| Placeholder `goto_pad` ring look | standin section 1.4.2 | Reused for the pack icon (section 4.8). |
| English UI texts of the existing screens | 08 section 10.8.6 | Unchanged; section 6 adds only keys that are new. |

## 1. Scope: which sprites, and which are left out

The sprite id groups of 14 section 6.1 are the starting list. The cobolcraft client draws the screens of 08 section
10.8.6 (title, server list, connecting, inventory, bench, chat, pause, packs, world list, create world, delete
confirmation, open to others) plus the HUD of 12 section 5, the recipe book of 13 section 3.9 and the crack overlay of
12 section 4. A group is supplied if one of those draws it.

| Group of 14 section 6.1 | Decision | Sprites supplied |
|---|---|---|
| Hotbar | supplied | all 6 ids (section 4.1) |
| Crosshair | supplied | all 4 ids (section 4.1) |
| Health and food | supplied except the mount hearts | all heart variants including `hardcore_*`, `absorbing_*`, `poisoned_*`, `withered_*`, `frozen_*`; food, hunger food, armour, air (sections 4.2, 4.3). `hud/heart/vehicle_*` is omitted (table below) |
| Experience bar | supplied (12 section 5.4) | 2 ids (section 4.1) |
| Status effects | supplied | `hud/effect_background`, `hud/effect_background_ambient`; `mob_effect/<name>` generated per effect name (section 4.10) |
| Container slots | supplied | `container/slot`, both highlights, five empty-slot icons (section 4.4) |
| Buttons and fields | supplied except locked and unlocked buttons | 15 ids (section 4.5) |
| Tooltips and popups | supplied | 3 ids, plus `toast/recipe` (section 4.6) |
| Recipe book | supplied except `furnace_*` | 21 ids (section 4.7) |
| Boss bars | **omitted** | none |
| Other screens (`pause_menu/*`, `player_list/*`, `icon/*`, `notification/*`, other `toast/*`, `spectator/*`, `advancements/*`, `social_interactions/*`, `server_list/*`, `world_list/*`) | **omitted** | none |
| Whole-image sheets | supplied for the screens that exist | inventory, crafting table, recipe book (section 4.11) |
| Menu tiles and separators | supplied | 8 images (section 4.8) |
| Title logo images (`title/*`) | **omitted** | none |

Every omitted id, with its reason and what is drawn instead (the fallback is always the missing-texture stripes of
standin section 1.4.2, 14 section 3.1):

| Omitted ids | Where they would be drawn | Reason | Fallback |
|---|---|---|---|
| `hud/heart/vehicle_*` (the mount heart variants; 14 section 6.1) | the mount health row while riding a mount that has health (12 section 5.4; the food row is hidden then) | the cobolcraft content as written has no mount (README Part 2.6 S64, S67, as far as this document knows; not verified, Open question 6) | stripes in the mount health row |
| `hud/jump_bar_*` (12 section 5.4) | the experience-bar slot while riding a jumping mount | same | stripes in that slot |
| `hud/locator_bar_*` (12 section 5.4) | the experience-bar slot when the locator is active | the cobolcraft content has no locator | stripes in that slot |
| the locked and unlocked button sprites (14 section 6.1 "Buttons and fields") | the difficulty lock on the options screen | the cobolcraft screens have no lock button (08 section 10.8.6) | stripes on that button |
| `boss_bar/*` | boss bars | no bosses | stripes |
| `furnace_*` of the recipe book | the furnace recipe book | no furnace screen | stripes |
| Other screens (`pause_menu/*`, `player_list/*`, `icon/*`, `notification/*`, other `toast/*`, `spectator/*`, `advancements/*`, `social_interactions/*`, `server_list/*`, `world_list/*`) | screens the cobolcraft client does not draw | its screens draw lists and buttons with text and the widgets of section 4.5 | stripes |
| `title/*` (the logo images) | the title screen | the title screen shows the text of `cobolcraft.screen.title.name` | stripes |

**Decision UI-6 (omitted families).** The omitted ids are not drawn by any screen or HUD part of the cobolcraft world
type, as far as the documents show. Reason: an unused sprite is dead weight in every future change of the style, and each
recipe is a promise that must be kept. The reason column for mounts, jump and locator bars rests on the content list
(README S64, S67) and not on a document that excludes them; `summon` can create entities (Open question 6), so a rideable
one cannot be excluded by this document alone. A client that starts drawing one of the omitted ids must add its recipe
here first (Open question 6 lists the commands, such as `bossbar`, that could reach one).

Counts: the `gui` atlas gets 102 built-in sprites. Outside the `gui` atlas the pack ships 8 menu images, 1 pack icon, 20
crack overlays, 3 sheets and the font image: 135 PNG files in all (section 3, table of paths), plus 15 JSON files of this
document (the nine-slice `.mcmeta` files; `atlases/gui.json` is already defined by 08 section 10.2) and the 4 font definition files of 08 section 10.10 (section 5.1).

## 2. Drawing vocabulary added to standin section 1.4.1

Everything of standin section 1.4.1 applies unchanged (pixel (x, y) with y down, `#RRGGBB`, alpha rule, later step
overwrites, `R`, `L`, `T`, `H`, Noise). The same rules govern images of any size; "the texture" means the image being
drawn. The additions:

- **Alpha table.** The alpha byte of p % is round(p x 255 / 100) with halves up. The values used here: 20 % = 51,
  25 % = 64, 40 % = 102, 60 % = 153, 80 % = 204, 94 % = 240. (standin section 1.4.1 lists 60 %, 66 %, 80 %, 92 %.)
- **Ring** `Ring(x0, y0, x1, y1, t, C)`: every pixel of `R(x0, y0, x1, y1)` with x < x0 + t, x > x1 - t, y < y0 + t or
  y > y1 - t is colour `C`. (The 1-px border of standin section 1.4.1 is `Ring` over the whole image with t = 1.)
- **Frame** `Frame(W, H, TL, BR, F, t)`, a W x H image: fill `F`; then the top `t` rows and the left `t` columns in `TL`;
  then the bottom `t` rows and the right `t` columns in `BR`. Where the bands meet (top-right and bottom-left corners)
  `BR` wins. It is a flat inset or outset without an outline. Worked example, `Frame(8, 6, D, L, F, 1)` (D = `#5E5740`,
  L = `#F4EFDD`, F = `#A39A7A`):

  ```
  DDDDDDDL
  DFFFFFFL
  DFFFFFFL
  DFFFFFFL
  DFFFFFFL
  LLLLLLLL
  ```

- **Bevel** `Bevel(W, H, O, HI, LO, F, b, r)`, a W x H image. Steps in order: (1) `R` over the whole image in `O`
  (the outline); (2) `R(1, 1, W-2, H-2)` in `F`; (3) for k = 1 .. b: the row k from column 1 to W-2 and the column k from row 1
  to H-2 in `HI`; (4) for k = 1 .. b: the row H-1-k from column 1 to W-2 and the column W-1-k from row 1 to H-2 in `LO`
  (so `LO` wins at the top-right and bottom-left); (5) if r = 1 the four corner pixels (0, 0), (W-1, 0), (0, H-1) and
  (W-1, H-1) become transparent. With b = 0 the image is an outline and a flat fill. Worked example,
  `Bevel(10, 8, O, HI, LO, F, 1, 1)` (`.` is transparent):

  ```
  .OOOOOOOO.
  OHHHHHHHLO
  OHFFFFFFLO
  OHFFFFFFLO
  OHFFFFFFLO
  OHFFFFFFLO
  OLLLLLLLLO
  .OOOOOOOO.
  ```

- **Art** `Art(rows, key)`: a list of strings, one per row, top row first, one character per pixel, left to right.
  `.` is transparent; every other character is the colour the key gives. All strings of one art have the same length.
- **Paste** `Paste(image, x, y)`: copy every non-transparent pixel of `image` onto the target with its top-left pixel at
  (x, y). Transparent pixels of `image` leave the target as it is.
- **Tint ramp.** `lighten(c)` adds 48 to each channel and clamps at 255.

### 2.1 Palette

**Decision UI-3 (look).** The built-in UI is "parchment and ledger": warm parchment panels for containers (chosen here
in the family of the `cardstack` colours of standin section 1.4.2 `#EDE6CF` and `#B9AE8C`, but not those values: the PAR, SLOT,
TAB and RSL colours and HI `#7FA9C9`, VIOLET HI `#A58BE0` are new choices of this document), ledger-blue buttons (the
`ledger_tile` blues `#3E6C8F` and `#24425A` are reused) and a violet accent (the `goto_pad` violets `#3B2F5C`, `#6A4FB3`,
`#C9B8FF` are reused). Reason: the blues and violets already exist in the cobolcraft content and the parchment is near the
`cardstack` hue, so the UI looks like part of the same game; it also differs on purpose from the vanilla grey UI, so
nobody mistakes the fallback for the pack.

| Token | Colour | Use |
|---|---|---|
| `INK` | `#1A1A1A` | outlines, shadows (also the dark of the missing texture) |
| `PAR` | O `#2A2A2A`, HI `#F4EFDD`, LO `#8C8366`, F `#D8D0B4` | parchment panel |
| `SLOT` | D `#5E5740`, L `#F4EFDD`, F `#A39A7A` | slot (inset) |
| `BTN` | O `#1A1A1A`, HI `#7FA9C9`, LO `#24425A`, F `#3E6C8F` | button, normal |
| `BTNH` | O `#FFFFFF`, HI `#A3C6E0`, LO `#2F5876`, F `#4F82A8` | button, hovered or focused |
| `BTND` | O `#1A1A1A`, HI `#555B62`, LO `#2A2D31`, F `#3A3F45` | button, disabled |
| `FIELD` | O `#6B6B75`, F `#14141A` | text field |
| `TRACK` | O `#1A1A1A`, HI `#0B0B10`, LO `#4A4A56`, F `#14141A` | slider track, checkbox box |
| `HOTBAR` | O `#1A1A1A`, HI `#45454F`, LO `#1F1F25`, F `#2B2B33`; slot well TL `#14141A`, BR `#55556A`, F `#1F1F25` | hotbar and attack indicator panels |
| `TAB` | O `#1A1A1A`, HI `#C9C2A5`, LO `#6F674D`, F `#A39A7A` | unselected recipe-book tab |
| `RSL`, `RSU` | RSL: O `#1A1A1A`, HI `#5E5740`, LO `#F4EFDD`, F `#A39A7A`. RSU: O `#1A1A1A`, HI `#6A3B36`, LO `#C98A82`, F `#A0645C` | recipe slot craftable, uncraftable |
| `GREEN` | O `#1A1A1A`, HI `#7FC066`, LO `#2F5E22`, F `#4F8F3A` | filter on |
| `VIOLET` | O `#1A1A1A`, HI `#A58BE0`, LO `#3B2F5C`, F `#6A4FB3` | ambient effect background |

**Decision UI-4 (flat art).** Panels, buttons and slots are flat colours with one-pixel bevels and no noise; only the two large
menu tiles use Noise (section 4.8). Reason: small sprites must stay legible when a user pack replaces only some of them, and
noise at 18 x 18 pixels reads as dirt; the exact recipes stay short enough to be checked by hand.

For a token with O, HI, LO and F the shorthand `Bevel(W, H, TOKEN, b, r)` means `Bevel(W, H, O, HI, LO, F, b, r)`.

## 3. Placement in the built-in pack

**Decision UI-1 (namespace and paths).** The GUI art is shipped in the `minecraft:` namespace at the paths and ids the
client asks for (14 section 6.1, 6.2), not under `cobolcraft:`. Reason: the client's requests for GUI sprites are
engine vocabulary (08 section 1.3 and the README rule R1); a user pack such as Faithful 32x and the generated vanilla pack
replace a file by shipping the same path (faithful section 9.1, README Part 4, C7), and a different namespace would stop
them from doing so. The built-in pack is at the bottom of the stack, so every file below is replaced as soon as a pack
above it has the same path. This is how faithful section 6.4 already listed the GUI set.

| Kind | Path under `assets/minecraft/` | Sprite id |
|---|---|---|
| GUI sprite (all groups of sections 4.1 to 4.7) | `textures/gui/sprites/<id>.png` | `minecraft:<id>` in the `gui` atlas |
| Effect icon (section 4.10) | `textures/mob_effect/<name>.png`, virtual files made when the pack is opened | `minecraft:mob_effect/<name>` in the `gui` atlas |
| Crack overlay (section 4.9) | `textures/block/destroy_stage_<N>.png`, `destroy_oit_stage_<N>.png` | `minecraft:block/destroy_stage_<N>` in the `blocks` atlas |
| Menu tiles (section 4.8) | `textures/gui/<name>.png` | whole image |
| Pack icon (section 4.8) | `textures/misc/unknown_pack.png` | whole image |
| Sheets (section 4.11) | `textures/gui/container/inventory.png`, `textures/gui/container/crafting_table.png`, `textures/gui/recipe_book.png` | whole image |
| Font image (section 4.12) | `textures/font/ascii.png` | whole image (08 section 10.10) |
| Font definitions (section 4.12) | `font/default.json`, `font/include/space.json`, `font/include/default.json`, `font/include/unifont.json` | font `minecraft:default` (08 section 10.10); 4 files already counted by 08 section 10.9, not new here |
| Atlas definition | `atlases/gui.json` | already defined by 08 section 10.2 (and counted in 08 section 10.9); not new here |
| Nine-slice metadata | `textures/gui/sprites/<id>.png.mcmeta` | 15 files, listed below |

`atlases/gui.json` (the definition of 14 section 3.1, as already given in 08 section 10.2; 08 section 7.3 gives the format):

```json
{"sources":[{"type":"directory","source":"gui/sprites","prefix":""},
            {"type":"directory","source":"mob_effect","prefix":"mob_effect/"}]}
```

**Decision UI-2 (sizes and scaling).** A sprite with no `.mcmeta` is drawn at its own pixel size, 1 GUI pixel per sprite
pixel (12 section 5.1). Where 12 or 13 gives the size of a sprite (hotbar 182 x 22, selection 24 x 23, off-hand 29 x 24,
crosshair 15 x 15, hearts and food 9 x 9, experience bar 182 x 5, slot highlights 24 x 24, buttons 200 x 20, tooltip
100 x 100 with border 9, recipe-book arrows 12 x 17, filter button 26 x 16, recipe-book button 20 x 18), the size below
is that size. Where no document gives it, the size below is chosen here and listed in Open question 1, and the client
draws the sprite at the size it has. Reason: with plain 1:1 drawing the size of an unread sprite is free, so choosing
it costs nothing; a user pack at 32 x 32 resolution scales by the same fraction (14 section 6.3).

The nine-slice `.mcmeta` of a sprite, with W, H and B from the table of section 5.3, is exactly

```json
{"gui":{"scaling":{"type":"nine_slice","width":W,"height":H,"border":B}}}
```

with `stretch_inner` left at its default (false: the inner parts tile, 14 section 6.3). Every nine-slice recipe below has a
uniform interior, so tiling and stretching look the same. A border value is at least the outline plus the bevel (1 + b),
so the corner parts contain every pixel that is not uniform along an edge.

**Decision UI-21 (borders are chosen, and differ from 12 for the buttons).** The border values of the table of section 5.3
are choices of this document, not read values, with one exception: tooltip border 9 (12 section 5.8, read). 12 section 5.9 reports
border 3 for `widget/button` and `widget/button_highlighted` and border 1 for `widget/button_disabled`; this document uses
border 2 for all three, and 1 for the text field (no value is documented for the text field, the sliders, the handles or
the scrollers). Reason: with the built-in art (outline 1 plus bevel 1), a border below 2 would copy the highlight edge but not
the shadow edge at a width under 200 (the Create button is 120 x 20, a default button 150 x 20, 12 section 5.9), because the
untiled right and bottom parts would then start inside the bevel; border 2 is the smallest that keeps both edges, and border
3 would draw the same image for this art. The consequence for a pack that replaces only `widget/button.png`: a file's
`.mcmeta` companion comes from the **same pack as the file** (08 section 3.2 and 7.4; 22 E6 says the same for Faithful), so a
pack that ships the PNG alone does **not** inherit the built-in `.mcmeta`: the sprite then has no nine-slice and is stretched
over the whole button. A nine-slice replacement must ship its own `.mcmeta` (Faithful does) and then uses its own border, for
example the 3 of 12 section 5.9. The border 2 of this document applies only to the built-in files. Open question 19 lists the
difference.

## 4. Recipes

Every recipe produces exactly one RGBA image. Steps run in the order written. Check values are in section 9.

### 4.1 HUD: hotbar, selection, off-hand, crosshair, indicators, experience bar, effect backgrounds

Positions of these sprites on screen are in 12 section 5.2 to 5.4; the item cell of a slot lies inside the slot well
as shown below.

| Sprite id | Size | Recipe |
|---|---|---|
| `hud/hotbar` | 182 x 22 | `Bevel(182, 22, HOTBAR, 1, 1)`; then for i = 0 .. 8 `Paste(Frame(18, 18, TL, BR, F, 1), 2 + 20 i, 2)` with the slot well colours of `HOTBAR`. The item cell of slot i (16 x 16, 12 section 5.2) is at (3 + 20 i, 3) in the sprite, so each well has a 1-px margin around it. |
| `hud/hotbar_selection` | 24 x 23 | `Ring(0, 0, 23, 22, 2, #FFFFFF)`; then the four corner pixels transparent. The inside stays transparent so the slot shows. |
| `hud/hotbar_offhand_left` | 29 x 24 | `Bevel(29, 24, HOTBAR, 1, 1)`; then `Paste(Frame(18, 18, ...well...), 2, 3)`. The item cell is at (3, 4) (12 section 5.2: x = hotbar x - 26, y = H - 19 against the sprite at hotbar x - 29, H - 23). |
| `hud/hotbar_offhand_right` | 29 x 24 | The same panel, with the well pasted at (9, 3); the item cell is at (10, 4). |
| `hud/hotbar_attack_indicator_background` | 18 x 18 | `Bevel(18, 18, HOTBAR, 1, 1)`. |
| `hud/hotbar_attack_indicator_progress` | 18 x 18 | `R(2, 2, 15, 15)` in `#E6E1CF`; then `R(2, 2, 15, 2)` in `#FFFFFF`. |
| `hud/crosshair` | 15 x 15 | `L(0, 7, 14, 7, 1)` and `L(7, 0, 7, 14, 1)` in `#FFFFFF` (faithful section 6.4, unchanged). |
| `hud/crosshair_attack_indicator_background` | 16 x 16 | `R(0, 6, 15, 9)` in `#1A1A1A` at alpha 60 % (153). |
| `hud/crosshair_attack_indicator_progress` | 16 x 16 | `R(1, 7, 14, 8)` in `#FFFFFF`. |
| `hud/crosshair_attack_indicator_full` | 16 x 16 | `R(0, 6, 15, 9)` in `#FFFFFF`; then `R(1, 7, 14, 8)` in `#F4EFDD`. |
| `hud/experience_bar_background` | 182 x 5 | `R(0, 0, 181, 4)` in `#1A1A1A`; then `R(1, 1, 180, 3)` in `#3A3A44`. |
| `hud/experience_bar_progress` | 182 x 5 | `R(0, 0, 181, 4)` in `#5FBF2A`; then `R(0, 0, 181, 0)` in `#A8E86A`; then `R(0, 4, 181, 4)` in `#3E8A1C`. (The client clips it to the left w pixels, 12 section 5.4.) |
| `hud/effect_background` | 24 x 24 | `Bevel(24, 24, BTN, 1, 1)`. |
| `hud/effect_background_ambient` | 24 x 24 | `Bevel(24, 24, VIOLET, 1, 1)`. |

The selection frame is white on purpose: it must read on the dark hotbar and over any held item colour.
The three crosshair-indicator sprites are all 16 x 16 so that the 16 x 16 indicator of 12 section 5.3 is drawn 1:1;
they contain only the bar (rows 6 to 9). Whether the client clips `_progress` horizontally or vertically is not
documented (Open question 3); the bar is uniform, so a horizontal clip shows the intended fill and a vertical clip shows
a partial bar, which is acceptable until the question is closed.

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `hud/hotbar` | 182 x 22 | stretch (none) | 4000 | `64110cb3efc93bb6eb77e45aa52eddb5766e8122e7cc95ad45e2b50537b1e1d2` |
| `hud/hotbar_selection` | 24 x 23 | stretch (none) | 168 | `8abc421bcaff2c932d4c42c3d8a40d49fcceca4a1a3bb4419436e65673e0faeb` |
| `hud/hotbar_offhand_left` | 29 x 24 | stretch (none) | 692 | `a7319c34104c65238eab08b471296c7b0dff429a190330d168cf2dc99ac36204` |
| `hud/hotbar_offhand_right` | 29 x 24 | stretch (none) | 692 | `918272e56e3ca3b724ba7f222b8a06df194cef9db9da8e518e706aeb1f9ed795` |
| `hud/hotbar_attack_indicator_background` | 18 x 18 | stretch (none) | 320 | `db2097bb2f164bb93a44f2924eb6b2c8420e8ca6ea5682b66cf6e95017524017` |
| `hud/hotbar_attack_indicator_progress` | 18 x 18 | stretch (none) | 196 | `21fbfd3dc901651b21d51c6b5c2d4a26defaa3aac38d6f1ee4191e51711aeda6` |
| `hud/crosshair` | 15 x 15 | stretch (none) | 29 | `a1ec4d40b5660adb19e545f8987c33b662fe52789e17d2a6a842a3d47b82fbb7` |
| `hud/crosshair_attack_indicator_background` | 16 x 16 | stretch (none) | 64 | `a5ea657140803dcb756e94f5aba359d0265fa2c74e1b1f0a1921a497dad7d6c8` |
| `hud/crosshair_attack_indicator_progress` | 16 x 16 | stretch (none) | 28 | `17ed9592a6c3914e374e1fcd08e6aa340016e96370f3703e2a0e8c2885def304` |
| `hud/crosshair_attack_indicator_full` | 16 x 16 | stretch (none) | 64 | `9c61bde962402c47f99b10aaa24b533aea144e9dae7d0ad68034b2f644dd8875` |
| `hud/experience_bar_background` | 182 x 5 | stretch (none) | 910 | `ef3e1717bc40ff58bf50123a442fd24186a1dbda21b13132d3b5127f45544706` |
| `hud/experience_bar_progress` | 182 x 5 | stretch (none) | 910 | `7b1586f640762c9a9960640a44e5cb0652caeeeb9c0948385b8a01aa2f064a60` |
| `hud/effect_background` | 24 x 24 | stretch (none) | 572 | `04415823c650786d74c0a1c50bbec948b7954166c1314b07d1652afdec2982e7` |
| `hud/effect_background_ambient` | 24 x 24 | stretch (none) | 572 | `b5f52cb2f1da4d6243a8b8fc587a2f71e0cb712234bd12257a1b14fc99d218ae` |

Manifest of this group: see section 9.2.

### 4.2 Hearts

All heart sprites are 9 x 9 and drawn from one silhouette. `Art(HEART, key)` with

```
.KK...KK.
KrRK.KRRK
KrRRKRRRK
KRRRRRRDK
.KRRRRDK.
..KRRDK..
...KDK...
....K....
.........
```

The key letters: `K` outline, `r` highlight, `R` body, `D` shade. In a **container** sprite, every `r`, `R` and `D` pixel
is the container interior colour `c`. In a **half** sprite, every `r`, `R` and `D` pixel in a column of 5 or more
(x >= 5) is `c`. In a **blinking** sprite the colours of the second table are used. The sprite id is
`hud/heart/<prefix><part><suffix>` with part `full`, `half` or `container`, prefix `` (normal), `hardcore_`, `absorbing_`,
`poisoned_`, `withered_` or `frozen_` (container only: `` and `hardcore_`), and suffix `` or `_blinking`.

Colours when not blinking (outline `K` is `#1A1A1A` everywhere):

| Kind | `R` | `r` | `D` | `c` (interior of container and of the empty half) |
|---|---|---|---|---|
| normal | `#D8362F` | `#FF8A80` | `#9E1F1F` | `#3C2323` |
| hardcore | `#A02A8F` | `#E08AD6` | `#6A1B60` | `#2E2236` |
| absorbing | `#E6B422` | `#FFE680` | `#A8801A` | `#3C2323` |
| poisoned | `#6B8E23` | `#B5D55A` | `#4A6516` | `#3C2323` |
| withered | `#3A3A3A` | `#7A7A7A` | `#1F1F1F` | `#3C2323` |
| frozen | `#6FC3E8` | `#D2F0FF` | `#3F8FB5` | `#3C2323` |

Colours when blinking (`K` is `#FFFFFF`; the damage flash, 12 section 5.4):

| Kind | `R` | `r` | `D` | `c` |
|---|---|---|---|---|
| normal | `#FF6A62` | `#FFD0CC` | `#D8362F` | `#5A3A3A` |
| hardcore | `#D05ABF` | `#FFBAFF` | `#9A4B90` | `#4A3A55` |
| absorbing | `#FFE452` | `#FFFFB0` | `#D8B04A` | `#5A3A3A` |
| poisoned | `#9BBE53` | `#E5FF8A` | `#7A9546` | `#5A3A3A` |
| withered | `#6A6A6A` | `#AAAAAA` | `#4F4F4F` | `#5A3A3A` |
| frozen | `#9FF3FF` | `#FFFFFF` | `#6FBFE5` | `#5A3A3A` |

(Except for normal, the blinking `R`, `r` and `D` are `lighten` of the non-blinking colours.) The 28 ids are the 4
containers (`container`, `container_blinking`, `container_hardcore`, `container_hardcore_blinking`) and, for each of the
six kinds, `full`, `half`, `full_blinking` and `half_blinking` with the kind's prefix.

**Decision UI-5 (all heart variants).** Every variant of 12 section 5.4 is supplied, including hardcore, absorption,
poison, wither and freeze, and the hardcore blinking container (which 12 does not name but the blink rule implies).
Reason: the shared rules (README R2) give the cobolcraft world type the standard `effect` command and the standard
damage and effect mechanics, so a player can be poisoned or frozen; a stripe heart would be a visible fault in the most
looked-at part of the HUD. The heart art is shared, so the variants cost one table.

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `hud/heart/container` | 9 x 9 | stretch (none) | 46 | `f7a944c23e5dc40f511f057af3d26ca9986dac7ad8f083a33fadf15cade71fc7` |
| `hud/heart/container_blinking` | 9 x 9 | stretch (none) | 46 | `18864ac1aaa5bef38b5b4c5a54aa66122f45c864e6ef66b57dbac46acafa958c` |
| `hud/heart/container_hardcore` | 9 x 9 | stretch (none) | 46 | `27f8a0c5b45d8f0bd2ccfefce469bc817509cd06966a50721e1e0dd2ced82b4b` |
| `hud/heart/container_hardcore_blinking` | 9 x 9 | stretch (none) | 46 | `f262d202f39efcf96595ec63cb600d3e0991a961d3d913f2b8cf57ffcaa8e4ee` |
| `hud/heart/full` | 9 x 9 | stretch (none) | 46 | `b5340236ff73e532c4ad8ec210c9c7cb90ddeed1309d8e87e7ed99dff6ad894a` |
| `hud/heart/full_blinking` | 9 x 9 | stretch (none) | 46 | `540b3517e84a1fb8031e90bb78bd373b1ba1e1274fdb5c30ac0e86d412f14f64` |
| `hud/heart/half` | 9 x 9 | stretch (none) | 46 | `670fb92a149561f0d0776fcac6052fea77b6be950e7323c9ba8f76e7b007611b` |
| `hud/heart/half_blinking` | 9 x 9 | stretch (none) | 46 | `36483d1912a992e47f0842cd5b273f05bba95b7b8b0b31c90406fa7d3b057f12` |
| `hud/heart/hardcore_full` | 9 x 9 | stretch (none) | 46 | `e2788f24e550e00c76dc32c59e4c842fd030c858fe7e236c7e7fdffab3f79ed5` |
| `hud/heart/hardcore_full_blinking` | 9 x 9 | stretch (none) | 46 | `1439a164de552285459674891096f14d87311d0bc6eb84143c328522a43329cd` |
| `hud/heart/hardcore_half` | 9 x 9 | stretch (none) | 46 | `63d3084a6c5fbe6afa82154ed4f70e7f479b050cf4e2b1440de855607652be0c` |
| `hud/heart/hardcore_half_blinking` | 9 x 9 | stretch (none) | 46 | `380df826d5364e8f05ecb17fc5bdf9bdb8aadcddadc5e0890777a0a300e7cef4` |
| `hud/heart/absorbing_full` | 9 x 9 | stretch (none) | 46 | `a7271f7880e514bbac758dd58a04867c4d1def1dccd18070852ad64445f48aab` |
| `hud/heart/absorbing_full_blinking` | 9 x 9 | stretch (none) | 46 | `7eb1b7edc34045afb68d235bac7581e1eeb0f7bf94f4fa1229cd7bf99347e360` |
| `hud/heart/absorbing_half` | 9 x 9 | stretch (none) | 46 | `f0468de9af6c9883357bbff2f1b6e76e56e49eba5d7958e64593c4f43d9af427` |
| `hud/heart/absorbing_half_blinking` | 9 x 9 | stretch (none) | 46 | `19dbdb57875a0b386eb8b2da159a87544544a16e5220041a9e8a56e31575fcaa` |
| `hud/heart/poisoned_full` | 9 x 9 | stretch (none) | 46 | `e8b41053ddea84f3e605a7d9e54432ebe85085bea1674eccd2e837762b194c52` |
| `hud/heart/poisoned_full_blinking` | 9 x 9 | stretch (none) | 46 | `f138d325a646d165a89fedaaf869251ea80aa31e5229dac6f2d1e463ea0f7ce6` |
| `hud/heart/poisoned_half` | 9 x 9 | stretch (none) | 46 | `d3bf0ed1f19c4a59127b802ff0847143c94874f8fdb284be83a9d3aeea4fc985` |
| `hud/heart/poisoned_half_blinking` | 9 x 9 | stretch (none) | 46 | `c963e4bfef882244ea41acc49ffd08453281dc2856cd1e3e67339809a3bded93` |
| `hud/heart/withered_full` | 9 x 9 | stretch (none) | 46 | `16efb73dcdd02390efdd1a77ed0e92dd52194ccd0679965115e38ac2fbd422db` |
| `hud/heart/withered_full_blinking` | 9 x 9 | stretch (none) | 46 | `59dea035e68738dac25cfc5177181234c6fa95971e1b43f732f68924c2b1f632` |
| `hud/heart/withered_half` | 9 x 9 | stretch (none) | 46 | `3ab39128c2250eb2c4ce4b6c6f7ef6205e0e2616ee70da46ab68c78604bde80e` |
| `hud/heart/withered_half_blinking` | 9 x 9 | stretch (none) | 46 | `e351d72509c898da2a378466d7228b508827cdb53dd6401dfaeafc589ef1d748` |
| `hud/heart/frozen_full` | 9 x 9 | stretch (none) | 46 | `ad96450cffe55597fb120f436efe7df0b2533326aa6845ce107daeb740fced78` |
| `hud/heart/frozen_full_blinking` | 9 x 9 | stretch (none) | 46 | `0f6486085159f1cf67e1ad94fd77f4bf94b06d8f9693e11c00798adf9a65400e` |
| `hud/heart/frozen_half` | 9 x 9 | stretch (none) | 46 | `af4e35519a1def6fb15769114eb9333ac7c10e53d5f0b774dcb42d52d3633d2c` |
| `hud/heart/frozen_half_blinking` | 9 x 9 | stretch (none) | 46 | `a6533ec7e4e96949d754f67b1fddfe41a4c5884265f892f7cfddd21536b4d784` |

### 4.3 Food, armour and air

All are 9 x 9.

**Food** (`hud/food_empty`, `hud/food_half`, `hud/food_full`, each also with the suffix `_hunger`). `Art(FOOD, key)`:

```
....KKK..
...KFFFK.
..KFhFFK.
..KFFFFK.
...KFFK..
..KKKK...
.KbbK....
KbbK.....
.KK......
```

`K` is `#1A1A1A`. Full: `F` `#C0703A`, `h` `#E8A56A`, `b` `#EDE6CF`. Hunger: `F` `#7C8A3A`, `h` `#B0BE6A`,
`b` `#C9C9A8`. The **empty** sprite draws every `F` and `h` pixel in the empty colour (`#2E2622`, hunger `#2A2E22`) and
every `b` pixel in `#4A4540` (hunger `#4A4A40`). The **half** sprite draws columns x <= 4 as full and columns x >= 5
as empty.

**Armour** (`hud/armor_empty`, `hud/armor_half`, `hud/armor_full`). `Art(ARMOR, key)`:

```
.KKK.KKK.
KAAAKAAAK
KAhAAAAAK
KAAAAAAAK
.KAAAAAK.
.KAAAADK.
.KAAADDK.
.KKKKKKK.
.........
```

`K` is `#1A1A1A`; full: `A` `#C7CED6`, `h` `#F2F5F8`, `D` `#8E98A3`. Empty: every `A`, `h` and `D` pixel `#2D3036`.
Half: columns x <= 4 full, x >= 5 empty.

**Air** (`hud/air`, `hud/air_empty`, `hud/air_bursting`). `Art(AIR, key)`:

```
..KKKKK..
.KbbbbbK.
KbhhbbbbK
KbhbbbbbK
KbbbbbbbK
KbbbbbbbK
KbbbbbbbK
.KbbbbbK.
..KKKKK..
```

`hud/air`: `K` `#1A1A1A`, `b` `#7FB8E8`, `h` `#E6F6FF`. `hud/air_empty`: only the `K` pixels, in `#3A5A78`; everything else
transparent. `hud/air_bursting`, `Art` with `h` = `#E6F6FF`:

```
h...h...h
.h..h..h.
..h.h.h..
...hhh...
hhhh.hhhh
...hhh...
..h.h.h..
.h..h..h.
h...h...h
```

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `hud/food_empty` | 9 x 9 | stretch (none) | 38 | `e73ef2306ba1c6374ab4549afef46f6f04f5f93c503f41d2b581a3762ade26d0` |
| `hud/food_empty_hunger` | 9 x 9 | stretch (none) | 38 | `cc37c090c47e7d3dcc1fa2b0f5dd5c2b9ab13e369faea9f18838d6d5c99b19ea` |
| `hud/food_half` | 9 x 9 | stretch (none) | 38 | `5f68167c15a6ba479d2ea4159ce90d33f1ab24db904fabb663d710883c5b2662` |
| `hud/food_half_hunger` | 9 x 9 | stretch (none) | 38 | `8140e083c473f650d5de713fe3b3ed5666553567a0fb5db303e297371b2ac984` |
| `hud/food_full` | 9 x 9 | stretch (none) | 38 | `774fcfdbe6236295c9948f43d5cd557f18456d56eff07907c912fb6e3c0cc547` |
| `hud/food_full_hunger` | 9 x 9 | stretch (none) | 38 | `1c92b57f05f68c9adcdecc29caa7c73e85f20d317d9b23dc7a33e760281f9a23` |

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `hud/armor_empty` | 9 x 9 | stretch (none) | 61 | `63af4813df6ea9c8939819788e9662bca6061104cd7f52064820bdf8c048c32a` |
| `hud/armor_half` | 9 x 9 | stretch (none) | 61 | `1cbf1c7e43c4fc7f47497e7b307de7fc606a4393e359987adbf845fd21b251fc` |
| `hud/armor_full` | 9 x 9 | stretch (none) | 61 | `58061abd6410306f4d38960a3b8005dcfdc10475d6ad6ac6ec6dbd98b873ae4c` |
| `hud/air` | 9 x 9 | stretch (none) | 69 | `5dce864407bc03a3b63d6ef0fcad97ab5b667e47d2277cb6710072a5699ea2fc` |
| `hud/air_empty` | 9 x 9 | stretch (none) | 24 | `37de0c219e8b176f3213395113bc7aaa0623844054aedd63c54b7759e35dd2db` |
| `hud/air_bursting` | 9 x 9 | stretch (none) | 32 | `0db83aadda939caca8ca6672475ca29ce08da79f045a1aede8cd8ea9536e14a9` |

### 4.4 Container slots and empty-slot icons

| Sprite id | Size | Recipe |
|---|---|---|
| `container/slot` | 18 x 18 | `Frame(18, 18, #5E5740, #F4EFDD, #A39A7A, 1)` (the `SLOT` token). |
| `container/slot_highlight_back` | 24 x 24 | `Ring(2, 2, 21, 21, 2, C)` with `C` = `#FFFFFF` at alpha 25 % (64). |
| `container/slot_highlight_front` | 24 x 24 | `R(4, 4, 19, 19)` in `#FFFFFF` at alpha 40 % (102). |
| `container/slot/helmet`, `chestplate`, `leggings`, `boots`, `shield` | 16 x 16 | `Art(rows, key)` with every `S` = `#6F674D`; rows below. |

**Decision UI-8 (slot highlight size).** The highlight sprites are 24 x 24 and are drawn at (slot.x - 4, slot.y - 4)
(12 section 5.6), so the 16 x 16 item cell sits in the middle with 4 pixels around. The back sprite is a soft 2-pixel
glow ring around the cell, the front sprite is a translucent white square over the cell. This replaces the earlier
inferred recipes of faithful section 6.4 (16 x 16 front, 1 x 1 transparent back), which assumed a stretched sprite; the
read size is better evidence. Reason: the geometry is documented, so the art must fit it.

Empty-slot icon rows (16 columns; `S` ink, `.` transparent). The ids `helmet`, `chestplate`, `leggings`, `boots` mark the
four armour slots of 12 section 5.6a, and `shield` marks the off-hand slot.

```
helmet                chestplate            leggings              boots                 shield
................      ................      ................      ................      ................
................      ..SSSS....SSSS..      ................      ................      ..SSSSSSSSSSSS..
....SSSSSSSS....      .SSSSSS..SSSSSS.      ...SSSSSSSSSS...      ................      ..SSSSSSSSSSSS..
...SSSSSSSSSS...      .SSSSSSSSSSSSSS.      ...SSSSSSSSSS...      ..SSSS....SSSS..      ..SSSSSSSSSSSS..
..SSSSSSSSSSSS..      .SSSSSSSSSSSSSS.      ...SSSSSSSSSS...      ..SSSS....SSSS..      ..SSSSSSSSSSSS..
..SSSSSSSSSSSS..      ..SSSSSSSSSSSS..      ...SSSSSSSSSS...      ..SSSS....SSSS..      ..SSSSSSSSSSSS..
..SSSSSSSSSSSS..      ...SSSSSSSSSS...      ...SSSS..SSSS...      ..SSSS....SSSS..      ..SSSSSSSSSSSS..
..SSSSSSSSSSSS..      ...SSSSSSSSSS...      ...SSSS..SSSS...      ..SSSSSS..SSSSSS      ..SSSSSSSSSSSS..
..SSS......SSS..      ...SSSSSSSSSS...      ...SSSS..SSSS...      ..SSSSSS..SSSSSS      ...SSSSSSSSSS...
..SSS......SSS..      ...SSSSSSSSSS...      ...SSSS..SSSS...      ..SSSSSS..SSSSSS      ...SSSSSSSSSS...
..SSS......SSS..      ...SSSSSSSSSS...      ...SSSS..SSSS...      ................      ....SSSSSSSS....
................      ...SSSSSSSSSS...      ...SSSS..SSSS...      ................      .....SSSSSS.....
................      ...SSSSSSSSSS...      ...SSSS..SSSS...      ................      ......SSSS......
................      ................      ................      ................      .......SS.......
................      ................      ................      ................      ................
................      ................      ................      ................      ................
```

(Rows 0 to 15 of each, top to bottom. The `boots` columns are 16 wide: the two boot toes run to the right edge.)

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `container/slot` | 18 x 18 | stretch (none) | 324 | `aa2330f2575dc5927b4afcbe6d4037ba56d2295bfe25a6fc899ec7be4d7c4b56` |
| `container/slot_highlight_back` | 24 x 24 | stretch (none) | 144 | `df6fc76d963e7533752d70d69df7f3d49ebac153e667d2cfd69026a95875bac3` |
| `container/slot_highlight_front` | 24 x 24 | stretch (none) | 256 | `fffa00222f3989d2badf908b071194f92584793c9a6096844af1161b63ded42b` |
| `container/slot/helmet` | 16 x 16 | stretch (none) | 84 | `c78ac9f4d4c05b78d9d26d093f8141c46677ff2aa24e3b60706ab2cec743efa1` |
| `container/slot/chestplate` | 16 x 16 | stretch (none) | 130 | `b1c3e7580021557908e418f7d0c02bec39af530abbd86bed6c639952f7267738` |
| `container/slot/leggings` | 16 x 16 | stretch (none) | 96 | `ebafb69c15446da66521701b4372e585bae2d44b4fcfc4a7933232687bba49f1` |
| `container/slot/boots` | 16 x 16 | stretch (none) | 68 | `e4ce50973b584a03dee10e24db284036d0b088ca81c036841dbcf7e4e679e023` |
| `container/slot/shield` | 16 x 16 | stretch (none) | 124 | `d56f1dfa74a4cfd2807dcf983be6989f89d9d10f0cab33b3ee5c46f5fdb22cc6` |

### 4.5 Buttons, fields, sliders, checkboxes and scrollers

| Sprite id | Size | Scaling | Recipe |
|---|---|---|---|
| `widget/button` | 200 x 20 | nine_slice border 2 | `Bevel(200, 20, BTN, 1, 1)` |
| `widget/button_highlighted` | 200 x 20 | nine_slice border 2 | `Bevel(200, 20, BTNH, 1, 1)` |
| `widget/button_disabled` | 200 x 20 | nine_slice border 2 | `Bevel(200, 20, BTND, 1, 1)` |
| `widget/text_field` | 200 x 20 | nine_slice border 1 | `Bevel(200, 20, O = #6B6B75, HI = #14141A, LO = #14141A, F = #14141A, 0, 0)`: a 1-px outline and a flat dark fill |
| `widget/text_field_highlighted` | 200 x 20 | nine_slice border 1 | the same with `O` = `#FFFFFF` |
| `widget/slider` | 200 x 20 | nine_slice border 2 | `Bevel(200, 20, TRACK, 1, 1)` |
| `widget/slider_highlighted` | 200 x 20 | nine_slice border 2 | the same with `O` = `#FFFFFF` |
| `widget/slider_handle` | 8 x 20 | nine_slice border 2 | `Bevel(8, 20, BTN, 1, 1)` |
| `widget/slider_handle_highlighted` | 8 x 20 | nine_slice border 2 | `Bevel(8, 20, BTNH, 1, 1)` |
| `widget/checkbox` | 17 x 17 | stretch | `Bevel(17, 17, TRACK, 1, 0)` |
| `widget/checkbox_highlighted` | 17 x 17 | stretch | the same with `O` = `#FFFFFF` |
| `widget/checkbox_selected` | 17 x 17 | stretch | `widget/checkbox`; then `L(3, 7, 6, 10, 2)` and `L(6, 10, 12, 4, 2)` in `#7CD33A` (a check mark) |
| `widget/checkbox_selected_highlighted` | 17 x 17 | stretch | `widget/checkbox_highlighted` with the same two lines |
| `widget/scroller` | 6 x 32 | nine_slice border 2 | `Bevel(6, 32, BTN, 1, 0)` |
| `widget/scroller_background` | 6 x 32 | nine_slice border 1 | every pixel `#000000` at alpha 40 % (102) (faithful section 6.4, unchanged) |

Button labels are drawn by the client (12 section 5.9): white with shadow when enabled; **Decision UI-12** fixes the
disabled label colour (not traced: 12 section 5.9's own Open question 5, and Open question 14 here) as `#A0A0A0` (section 6). The corner pixels of
`Bevel` with r = 1 are transparent, so buttons show a one-pixel rounding.

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `widget/button` | 200 x 20 | nine_slice 200x20, border 2 | 3996 | `f8dc9cafe0138e6a494f074d5ef924e0867541b8849232063dc1f051a84ecc50` |
| `widget/button_highlighted` | 200 x 20 | nine_slice 200x20, border 2 | 3996 | `f81a5a3524017f2939f9abdea23e02caebff15570a9d1e5294a56307acbffb0f` |
| `widget/button_disabled` | 200 x 20 | nine_slice 200x20, border 2 | 3996 | `4e6dec8a1dc4abacffa04eddcdedc2265ec344f3e0adccb5d71f1f36169d0fe7` |
| `widget/text_field` | 200 x 20 | nine_slice 200x20, border 1 | 4000 | `8223446042379b35a4b6a4cc4847f73931a5169d702f1a8f9b91af21c8f0bf07` |
| `widget/text_field_highlighted` | 200 x 20 | nine_slice 200x20, border 1 | 4000 | `4dad001685564f09e1f73d494289177b741032bf2b4e1ab016c0c5b477ce697d` |
| `widget/slider` | 200 x 20 | nine_slice 200x20, border 2 | 3996 | `cffc6c7ae95cfd261b252ac54072a1c57b85281f0257cecebf5bcdb5b45d9e83` |
| `widget/slider_highlighted` | 200 x 20 | nine_slice 200x20, border 2 | 3996 | `3b4266fbe7b0a9f5f044be39f966cf739754d34f02a6b521b7e3d096afad5abb` |
| `widget/slider_handle` | 8 x 20 | nine_slice 8x20, border 2 | 156 | `2a5eeaad9db6967c6112e6552e116059c25405fb11df24e901b1ee45246baf1d` |
| `widget/slider_handle_highlighted` | 8 x 20 | nine_slice 8x20, border 2 | 156 | `35111826c4fd51683f5894b2e95d604640e6d64fd5e88f34580b67821cff07a7` |
| `widget/checkbox` | 17 x 17 | stretch (none) | 289 | `5c07382c3b159eac66f2751b8dbbe761005fea8e65c1ca7bd2979eca66d64969` |
| `widget/checkbox_highlighted` | 17 x 17 | stretch (none) | 289 | `5a93056e90773fceed1fc9008827c9bba66927646372356b6e07b06b8b04d7be` |
| `widget/checkbox_selected` | 17 x 17 | stretch (none) | 289 | `e2e9b0f6de7d041010c840a2ae382e626664fbb45552132cf731eb784c4151fb` |
| `widget/checkbox_selected_highlighted` | 17 x 17 | stretch (none) | 289 | `283faac3c127dc65f91b497c7c9a0d2120119a3075ddee0c09c10d459b36601d` |
| `widget/scroller` | 6 x 32 | nine_slice 6x32, border 2 | 192 | `f7c19f17113c5562b47c2f100b8bcd9db8e69e95d1b5b321ab84c5a668b3276d` |
| `widget/scroller_background` | 6 x 32 | nine_slice 6x32, border 1 | 192 | `42a5eae89a97b4cb6428dd99869a025acac80728c4d6aa2ce63a890be69e9a6a` |

### 4.6 Tooltips, popups and toasts

| Sprite id | Size | Scaling | Recipe |
|---|---|---|---|
| `tooltip/background` | 100 x 100 | nine_slice border 9 | `R(7, 7, 92, 92)` in `#16121F` at alpha 94 % (240); then the four corner pixels (7, 7), (92, 7), (7, 92), (92, 92) transparent. |
| `tooltip/frame` | 100 x 100 | nine_slice border 9 | `Ring(7, 7, 92, 92, 1, #6A4FB3)`; then `Ring(8, 8, 91, 91, 1, #3B2F5C)`; then the same four corner pixels transparent. |
| `popup/background` | 32 x 32 | nine_slice border 4 | `Bevel(32, 32, HOTBAR, 1, 1)` (dark, so that white and amber text read on it, section 6) |
| `toast/recipe` | 160 x 32 | stretch | `Bevel(160, 32, PAR, 1, 1)` |

How the tooltip sprites fit 12 section 5.8: the destination rectangle starts 12 pixels left of and above the text
(3 pixels of padding plus the 9-pixel border) and the border of 9 covers the corners. Pixel 7 and 8 of the border are
the frame, so the outer frame edge is 5 pixels from the text on every side (a 2-pixel frame plus 3 pixels of padding
to the inner edge at pixel 9), and pixels 0 to 6 are transparent. **Decision UI-13 (tooltip frame offset).** The frame
sits at pixels 7 and 8 so that the padding between text and the inner frame edge is exactly the 3 pixels 12 section 5.8
gives. Reason: 12 does not say where inside the 9-pixel border the frame lies, and this is the only choice that makes the
documented padding true (Open question 16).

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `tooltip/background` | 100 x 100 | nine_slice 100x100, border 9 | 7392 | `2104e52138d387ffbe00c1a8266b46bbb4fb596ad0ec4d08021ba45617037969` |
| `tooltip/frame` | 100 x 100 | nine_slice 100x100, border 9 | 668 | `586358f783e5966d2db18086123d0126672e1c46fc366d370e9c16de97f43b53` |
| `popup/background` | 32 x 32 | nine_slice 32x32, border 4 | 1020 | `e5fb3daca6d18a1d7cb64ae59dc7825913def1b031f38a0b9f7344ee9fd8b558` |
| `toast/recipe` | 160 x 32 | stretch (none) | 5116 | `c0c488cf2b7bb74dddc6ad5f32eba2798c881a83885883768ffbbbddaf19c7f8` |

### 4.7 Recipe book

Sizes: tab 32 x 27 (27 is the documented pitch, 13 section 3.9; the width is chosen, Open question 1); recipe slot and
overlay button 25 x 25 (the grid cell of 13 section 3.9); arrows 12 x 17 and filter button 26 x 16 (documented); book
button 20 x 18 (documented).

| Sprite id | Size | Scaling | Recipe |
|---|---|---|---|
| `recipe_book/button` | 20 x 18 | stretch | `Bevel(20, 18, BTN, 1, 1)`; then `R(5, 4, 14, 13)` in `#F4EFDD`; then `R(9, 4, 10, 13)` in `#3B2F5C` (an open book with a spine). |
| `recipe_book/button_highlighted` | 20 x 18 | stretch | the same with `BTNH`. |
| `recipe_book/tab` | 32 x 27 | stretch | `Bevel(32, 27, TAB, 1, 1)` |
| `recipe_book/tab_selected` | 32 x 27 | stretch | `Bevel(32, 27, PAR, 1, 1)` |
| `recipe_book/slot_craftable` | 25 x 25 | stretch | `Bevel(25, 25, RSL, 1, 1)` |
| `recipe_book/slot_many_craftable` | 25 x 25 | stretch | `slot_craftable`; then `T((18, 23), (23, 23), (23, 18))` in `#F4EFDD` (a stack corner) |
| `recipe_book/slot_uncraftable` | 25 x 25 | stretch | `Bevel(25, 25, RSU, 1, 1)` |
| `recipe_book/slot_many_uncraftable` | 25 x 25 | stretch | `slot_uncraftable`; then the same triangle |
| `recipe_book/page_forward` | 12 x 17 | stretch | `T((4, 4), (4, 14), (10, 9))` in `#1A1A1A` (shadow); then `T((3, 3), (3, 13), (9, 8))` in `#F4EFDD` |
| `recipe_book/page_forward_highlighted` | 12 x 17 | stretch | the same with the arrow in `#FFFFFF` |
| `recipe_book/page_backward` | 12 x 17 | stretch | `T((9, 4), (9, 14), (3, 9))` in `#1A1A1A`; then `T((8, 3), (8, 13), (2, 8))` in `#F4EFDD` |
| `recipe_book/page_backward_highlighted` | 12 x 17 | stretch | the same with the arrow in `#FFFFFF` |
| `recipe_book/filter_enabled` | 26 x 16 | stretch | `Bevel(26, 16, GREEN, 1, 1)`; then `T((8, 4), (17, 4), (12, 11))` in `#F4EFDD` (a funnel) |
| `recipe_book/filter_enabled_highlighted` | 26 x 16 | stretch | the same with `O` = `#FFFFFF` |
| `recipe_book/filter_disabled` | 26 x 16 | stretch | `Bevel(26, 16, BTN, 1, 1)`; then the same funnel |
| `recipe_book/filter_disabled_highlighted` | 26 x 16 | stretch | the same with `O` = `#FFFFFF` |
| `recipe_book/overlay_recipe` | 32 x 32 | nine_slice border 4 | `Bevel(32, 32, PAR, 1, 1)` |
| `recipe_book/crafting_overlay` | 25 x 25 | stretch | `Bevel(25, 25, BTN, 1, 1)` |
| `recipe_book/crafting_overlay_highlighted` | 25 x 25 | stretch | `Bevel(25, 25, BTNH, 1, 1)` |
| `recipe_book/crafting_overlay_disabled` | 25 x 25 | stretch | `Bevel(25, 25, BTND, 1, 1)` |
| `recipe_book/crafting_overlay_disabled_highlighted` | 25 x 25 | stretch | `Bevel(25, 25, BTND, 1, 1)` with `O` = `#FFFFFF` |

**Decision UI-23 (who draws the recipe-book panel's fields and labels).** The `recipe_book` sheet is only the flat PAR bevel
and carries no field art. In both world types the client draws, over the panel at the rectangles of 13 section 3.9:

| Part | Rectangle on the panel | Background | Text |
|---|---|---|---|
| Search box | (25, 13), 81 x 14 | `widget/text_field` (nine-slice, border 1, `#14141A` face, `#6B6B75` outline; `_highlighted` while focused) stretched to 81 x 14 | typed text `#FFFFFF` with shadow; hint `cobolcraft.screen.common.search_hint` in `#A0A0A0`; both on the dark field |
| Filter button | (110, 12), 26 x 16 | the sprite `recipe_book/filter_*` itself (section 4.7 table), which is the whole button | none (tooltip only) |
| Page label | right of the arrows, as 13 section 3.9 places it | none (the PAR face) | `cobolcraft.screen.recipe_book.page` in `#404040`, no shadow |
| Toast text | inside `toast/recipe` (PAR face) | the sprite | `cobolcraft.screen.recipe_book.toast` in `#404040`, no shadow; its position is not given by any document (Open question 4) |

13 section 3.9 gives the search text as white; that holds because the text sits on the dark field. A page label that 13 would
draw in white would be unreadable on `#D8D0B4` (contrast 1.54), so the built-in art overrides it with the parchment rule of section 6.

Uncraftable slots are red-tinted, which matches the "red slot background" of 13 section 3.9; craftable ones use the
slot parchment. The `furnace_*` recipe-book sprites are omitted (Decision UI-6).

**Decision UI-22 (tab icons are letters in the cobolcraft world type).** 13 section 3.9 gives the tab icons as items: Search a
magnifier, Equipment an iron axe and a golden sword, Building Blocks bricks, Misc a lava bucket and an apple, Redstone
redstone. The cobolcraft world type has none of those items or models, and the built-in pack ships no vanilla item models, so
drawing them would draw stripes. In the cobolcraft world type the client therefore draws, instead of the item icons, the first
character of the tab's name (the value of `cobolcraft.screen.recipe_book.tab.<name>`: S, E, B, M, R) in `#1A1A1A` with no shadow (text rule for parchment surfaces, section 6):
the glyph's advance-box is centred, x = tabX + (32 - a) div 2 with a the advance of that letter (standin section 18), and the
text's top y = tabY + 9, where (tabX, tabY) is the top-left of the tab sprite. Unselected and selected tabs use the same
position. In the standard world type the client draws the items of 13 section 3.9 as documented (the generated pack has
their models). The tab tooltip text is the full name. No new sprite id is needed. Reason: it is the only rule that needs no
new item, model or sprite and is readable in a 32 x 27 tab; original icons would need five new sprites with
recipes and check values (Open question 4).

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `recipe_book/button` | 20 x 18 | stretch (none) | 356 | `702bbcbdaaf1cb4b3387120c7d679e5130851d96cb0c72893d740a98c5e4da52` |
| `recipe_book/button_highlighted` | 20 x 18 | stretch (none) | 356 | `76603b17cbf88ee35d0f7dbd44a86f48bc01262a36156803e95de5ef254b9b0e` |
| `recipe_book/tab` | 32 x 27 | stretch (none) | 860 | `b8033d0d45dc3cd5276fc581ae228fb86c5bad1cbda6451819e659fff81590f6` |
| `recipe_book/tab_selected` | 32 x 27 | stretch (none) | 860 | `8ae9c3f6663d918193cdef5bca862337266adde76493cde0357b7cc6981d4f3d` |
| `recipe_book/slot_craftable` | 25 x 25 | stretch (none) | 621 | `4b04282f10e8631c1cf6165d85bf787e248d585176f7ada93c2dc31dffccf255` |
| `recipe_book/slot_many_craftable` | 25 x 25 | stretch (none) | 621 | `03f12f9371182d2433be936f78e86e69351deee22a3f98b0b3d82d3deeb35b7c` |
| `recipe_book/slot_uncraftable` | 25 x 25 | stretch (none) | 621 | `97cd35a8e88a2146dcddc77032d9f85d0dd0719264b21995fabbf6aee61d21d9` |
| `recipe_book/slot_many_uncraftable` | 25 x 25 | stretch (none) | 621 | `80ea22bd233945a4acba13163da33bea91c320e7afcd1740fd2be4f69a129d76` |
| `recipe_book/page_forward` | 12 x 17 | stretch (none) | 49 | `6d069890d83faba59d26f49ce313a56592361cc1c52e3ad449bfbe4524801966` |
| `recipe_book/page_forward_highlighted` | 12 x 17 | stretch (none) | 49 | `3d9cd52730af460e1163e502df57b750932b64d54888b8c4a2b9e48922ab1962` |
| `recipe_book/page_backward` | 12 x 17 | stretch (none) | 49 | `973f1beaa1bc4f1757cdf71cb8e8a22c87edd3ae5bb1deca78698f09af89fe08` |
| `recipe_book/page_backward_highlighted` | 12 x 17 | stretch (none) | 49 | `54549d256faa5244016db3efa95f3b6f67ab6945b24ec4a07a6560ed50c6bc53` |
| `recipe_book/filter_enabled` | 26 x 16 | stretch (none) | 412 | `70e06fcd551b32e5ed92fdcea4e39bba1def2b0ae32b027f8c2231f14db7a468` |
| `recipe_book/filter_enabled_highlighted` | 26 x 16 | stretch (none) | 412 | `07bddd66e12519e9c4325b6c75eb949f66aac75eeb1d1ed46adf21746f72a71d` |
| `recipe_book/filter_disabled` | 26 x 16 | stretch (none) | 412 | `5dd3bee2980e46e49cf58a6017c8c5e34e7b90e3ce62d26e5be55e1ba86b98ef` |
| `recipe_book/filter_disabled_highlighted` | 26 x 16 | stretch (none) | 412 | `6a5271bd5180dc99f67a7ac0a9113e6f1a8db7b2432ef82e1a5b6feb058d9bd0` |
| `recipe_book/overlay_recipe` | 32 x 32 | nine_slice 32x32, border 4 | 1020 | `081f10e6eabbd931331c12774b870baf32f5d3f4fe7b730d9412cfc6f24ca2aa` |
| `recipe_book/crafting_overlay` | 25 x 25 | stretch (none) | 621 | `da18a82324940982ffb65a63ccf83e71fc4731a9f845c8c7be1b9f0c92b6edf2` |
| `recipe_book/crafting_overlay_highlighted` | 25 x 25 | stretch (none) | 621 | `f02d34d063e2f8ca9088ad8d2b1c00844404065826bc54287d352114762f233b` |
| `recipe_book/crafting_overlay_disabled` | 25 x 25 | stretch (none) | 621 | `a5eba51e6f20dfb71814a73b80754b288202b8387483b4ea0a0fb846fbe36c83` |
| `recipe_book/crafting_overlay_disabled_highlighted` | 25 x 25 | stretch (none) | 621 | `88ce1de95ae2efe356e7dbefdb4aa6da3ff7979173721af3dd7739da29cbd01c` |

### 4.8 Menu tiles, separators and the pack icon

| Image file (under `textures/gui/` unless stated) | Size | Recipe |
|---|---|---|
| `menu_background.png` | 32 x 32 | Noise `menu_background`: fill `#1E1E26`; 12 % `#262630`, 6 % `#16161C` |
| `menu_list_background.png` | 32 x 32 | Noise `menu_list_background`: fill `#101016`; 10 % `#17171E`, 5 % `#0B0B10` |
| `header_separator.png` | 32 x 2 | row 0 `#0B0B10`; row 1 `#4A4A56` |
| `footer_separator.png` | 32 x 2 | row 0 `#4A4A56`; row 1 `#0B0B10` |
| `inworld_menu_background.png` | 32 x 32 | the `menu_background` image with every alpha set to 80 % (204) |
| `inworld_menu_list_background.png` | 32 x 32 | the `menu_list_background` image with every alpha set to 60 % (153) |
| `inworld_header_separator.png` | 32 x 2 | the `header_separator` image with every alpha set to 60 % (153) |
| `inworld_footer_separator.png` | 32 x 2 | the `footer_separator` image with every alpha set to 60 % (153) |
| `textures/misc/unknown_pack.png` | 64 x 64 | with q = min(x, y, 63 - x, 63 - y) div 4: q = 0 `#3B2F5C`; q in {1, 3, 5} `#1F1B2E`; q in {2, 4} `#6A4FB3`; q >= 6 `#C9B8FF` (the `goto_pad` rings at four times the size) |

The Noise names are the file stems (standin section 1.4.1: the ASCII bytes of the name). The tiles are tiled by the client
(14 section 6.2): the 32 x 32 tiles in both directions, the 32 x 2 separators horizontally. `tab_header_background.png`
is not supplied (no screen has a tab header). The pack icon is what the pack screen shows for a pack with no
`pack.png` (13 section 8).

| Image key (section 9.2) | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `menu_background` | 32 x 32 | stretch (none) | 1024 | `84b91f09e970a5c28dbb6e00f117bc9d6a64e8f46c8a5fc28c0507473de90487` |
| `menu_list_background` | 32 x 32 | stretch (none) | 1024 | `4f9573c24c89ebd2e8968f6c5eceaa4df47c6a271bd3ee34ce06a7e5d2c804b8` |
| `header_separator` | 32 x 2 | stretch (none) | 64 | `bad63f244c002fd5ccfceda7c656229a30d91570a6fd2bd88b70920778e3172b` |
| `footer_separator` | 32 x 2 | stretch (none) | 64 | `4757aefc3f828f6179a703f652c647f20e9049c4bdf180328fa737fd450e57d5` |
| `inworld_menu_background` | 32 x 32 | stretch (none) | 1024 | `d3ad195d171c8e563d35d0196542e2d78178c8913c7a4314da75b00f014bc115` |
| `inworld_menu_list_background` | 32 x 32 | stretch (none) | 1024 | `6b385efbe09ff7d3e1cd7e485ec5b358ea04a143a962da5a36d8b33f8b45e855` |
| `inworld_header_separator` | 32 x 2 | stretch (none) | 64 | `333eb815b5bd005f6573336f9534d50fd9d03842f947c4100986cc21a11ae770` |
| `inworld_footer_separator` | 32 x 2 | stretch (none) | 64 | `a6c2ad8f335ba429c6a4705f6d1deedd3752ef2453818a11ae2da27fa0068ec1` |

| Image key (section 9.2) | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `misc/unknown_pack` | 64 x 64 | stretch (none) | 4096 | `9bab87ca5b712514c24c73ca590d8881d44fa1144e68a749a16c8c0b8c671452` |

### 4.9 Crack overlay

Reused unchanged from faithful section 8.1: the ten 16 x 16 images `block/destroy_stage_0` to `destroy_stage_9`. In stage N
every pixel is transparent except those with n < 8 + 9 N, where n = H(100, 101, 115, 116, 114, 111, 121, x, y) mod 100
(the ASCII bytes of `destroy`, then x and y); such a pixel is `#404040` at alpha 255. The crumbling blend of 12 section
4.3 doubles source times destination, so `#404040` darkens the block to half and transparent pixels are discarded. The
pattern only grows with N. The numbers of dark pixels for stages 0 to 9 are 20, 42, 64, 87, 110, 135, 160, 187, 211 and
231 (these match faithful section 8.1 and were recomputed here).

**Decision UI-9 (second set).** `block/destroy_oit_stage_0` to `destroy_oit_stage_9` are supplied and are pixel-identical
to the first set (the same bytes). Reason: 14 section 4.3 says which set the client uses is untraced (Open question 3 of
14), and the two sets share their stage numbering; an identical copy is correct whichever one is chosen.

| Sprite id | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `block/destroy_stage_0` | 16 x 16 | stretch (none) | 20 | `452807c102577cfb3ae149fefbf4f29d7d9587c4b31e0271dcd24d6180d174a9` |
| `block/destroy_stage_1` | 16 x 16 | stretch (none) | 42 | `38c4d770215885152432128154c7dd2458660a9c16b97564d71c174bcf541989` |
| `block/destroy_stage_2` | 16 x 16 | stretch (none) | 64 | `6d72c59d697b2b0ebc8173a3263f723f3dc169de59e1402239be74b58cad29d0` |
| `block/destroy_stage_3` | 16 x 16 | stretch (none) | 87 | `b3898682d35ed25077dfba76b8d32e30c00d8b8c180f9f2c66b34392a22912e4` |
| `block/destroy_stage_4` | 16 x 16 | stretch (none) | 110 | `e283eb112477965aede4f010fe7e665e3fb3a2d094a0624ad86896626db9df1c` |
| `block/destroy_stage_5` | 16 x 16 | stretch (none) | 135 | `04d99c24fc9b160014d0564ea2e61afc39cfb81913f81b59aea31c204d024294` |
| `block/destroy_stage_6` | 16 x 16 | stretch (none) | 160 | `1d64f33ff34a5f5bbbf5e2dcaa6bf172ddd0b98deb057a586b805950f50e801b` |
| `block/destroy_stage_7` | 16 x 16 | stretch (none) | 187 | `89e1096872ecaedf6ade2371e6bd2e9866318024f9bb1dedb4e7aab80d659590` |
| `block/destroy_stage_8` | 16 x 16 | stretch (none) | 211 | `145a729d6bbf69f9a08048068296f37c59ef8cab19fb49cbe3673dd3e5547e81` |
| `block/destroy_stage_9` | 16 x 16 | stretch (none) | 231 | `304cc5508fcbc594295777a531c5fca2172a6bab070b3a304eb376285310174c` |
| `block/destroy_oit_stage_0` | 16 x 16 | stretch (none) | 20 | `452807c102577cfb3ae149fefbf4f29d7d9587c4b31e0271dcd24d6180d174a9` |
| `block/destroy_oit_stage_1` | 16 x 16 | stretch (none) | 42 | `38c4d770215885152432128154c7dd2458660a9c16b97564d71c174bcf541989` |
| `block/destroy_oit_stage_2` | 16 x 16 | stretch (none) | 64 | `6d72c59d697b2b0ebc8173a3263f723f3dc169de59e1402239be74b58cad29d0` |
| `block/destroy_oit_stage_3` | 16 x 16 | stretch (none) | 87 | `b3898682d35ed25077dfba76b8d32e30c00d8b8c180f9f2c66b34392a22912e4` |
| `block/destroy_oit_stage_4` | 16 x 16 | stretch (none) | 110 | `e283eb112477965aede4f010fe7e665e3fb3a2d094a0624ad86896626db9df1c` |
| `block/destroy_oit_stage_5` | 16 x 16 | stretch (none) | 135 | `04d99c24fc9b160014d0564ea2e61afc39cfb81913f81b59aea31c204d024294` |
| `block/destroy_oit_stage_6` | 16 x 16 | stretch (none) | 160 | `1d64f33ff34a5f5bbbf5e2dcaa6bf172ddd0b98deb057a586b805950f50e801b` |
| `block/destroy_oit_stage_7` | 16 x 16 | stretch (none) | 187 | `89e1096872ecaedf6ade2371e6bd2e9866318024f9bb1dedb4e7aab80d659590` |
| `block/destroy_oit_stage_8` | 16 x 16 | stretch (none) | 211 | `145a729d6bbf69f9a08048068296f37c59ef8cab19fb49cbe3673dd3e5547e81` |
| `block/destroy_oit_stage_9` | 16 x 16 | stretch (none) | 231 | `304cc5508fcbc594295777a531c5fca2172a6bab070b3a304eb376285310174c` |

### 4.10 Status effect icons (generated by name)

The standard `effect` command and the standard mob effects (17, 16 section 5.10) apply in the cobolcraft world type, so an
effect can be on the player. **Decision UI-7.** The icon `mob_effect/<name>` is not a stored file but is generated from its
name, at the size 18 x 18, by the rule below. Reason: a generated icon gives each effect a distinct, stable colour and letter
with one rule, and needs no original art per effect.

**Enumeration and atlas hook (part of Decision UI-7).** The `gui` atlas source is a `directory` source (section 3, 08 section
7.3), which finds files by listing, and 08 section 10 has no mechanism that serves a generated image, so this document adds
one rule to the built-in pack: when the built-in pack is opened (at start-up and on every resource reload) it lists, as
virtual files `assets/minecraft/textures/mob_effect/<name>.png`, one image per name of a **fixed list**, the key paths of the
40 `mob_effect` entries of 46 section 4.1 (as of this round: `speed` first; 46 section 4.1 holds the table and this list is a copy of it, in id order 0 to 39). The image bytes are produced by the rule below, so a reload makes the same bytes. The 40 names, in id order, are: `speed`, `slowness`, `haste`, `mining_fatigue`, `strength`, `instant_health`,
`instant_damage`, `jump_boost`, `nausea`, `regeneration`, `resistance`, `fire_resistance`, `water_breathing`, `invisibility`,
`blindness`, `night_vision`, `hunger`, `weakness`, `poison`, `wither`, `health_boost`, `absorption`, `saturation`, `glowing`,
`levitation`, `luck`, `unluck`, `slow_falling`, `conduit_power`, `dolphins_grace`, `bad_omen`, `hero_of_the_village`,
`darkness`, `trial_omen`, `raid_omen`, `wind_charged`, `weaving`, `oozing`, `infested`, `breath_of_the_nautilus`. The list is fixed and does not
depend on the registry the client receives in configuration (04), because the atlas is stitched at resource load, before the
registry is known. An effect whose key path is not in the list (a name that a later version of 46 adds, or an effect from a
server's own registry) has no icon in the built-in pack: its sprite request draws the missing-texture stripes, and no icon is
made on demand. When the generated vanilla pack is present (the standard world type), its files of the same paths replace
the virtual ones by the path rule (08 section 3.2). Whoever edits 46 section 4.1 must also edit the list here (08 section 10
must state the virtual-file rule: until then 08 section 10.2 and this section disagree; Open question 7). Only three icons have check
values (the worked examples below) and there is no group manifest over the 40, unlike the other groups of section 9.2: the
manifest was not computed in this round (Open question 21). The 18 x 18 size and the placement of the icon inside the
24 x 24 `effect_background` are choices; 12 section 5 has no status-effect HUD layout at all, so the HUD placement itself is
unread (Open question 22).

For an effect whose key path (the text after `minecraft:` or any namespace colon, for example `night_vision`) has the ASCII
bytes b1 .. bk:

1. base colour (r, g, b) with r = 64 + (H(b1, ..., bk, 1) mod 160), g = 64 + (H(b1, ..., bk, 2) mod 160),
   b = 64 + (H(b1, ..., bk, 3) mod 160);
2. HI = each channel of the base plus 64, clamped at 255; LO = each channel of the base `div` 2;
3. the image is `Bevel(18, 18, O = #1A1A1A, HI, LO, F = base, 1, 1)`;
4. the glyph of the upper-case first letter of the path (the built-in font, section 4.12; if the first character is not an
   ASCII letter, the glyph of `?`) is drawn in `#FFFFFF` with the glyph cell's top-left pixel at (5, 5): row j and column k of
   the glyph rows are set when bit `0x80 >> k` of row byte j is set, and the pixel (5 + k, 5 + j) is `#FFFFFF`.

Worked examples (the base colours are results of step 1; the counts are in the same order as the table below):

| Key path | Base | HI | LO | Letter | Transparent | `#1A1A1A` | HI | LO | Base | `#FFFFFF` | SHA-256 of RGBA |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `speed` | `#7EC35C` | `#BEFF9C` | `#3F612E` | S | 4 | 64 | 29 | 31 | 181 | 15 | `552ad8826f4fae713e5c29559a162ff98f7602013df4074a0c6c18b22b3f82bb` |
| `poison` | `#90AA4F` | `#D0EA8F` | `#485527` | P | 4 | 64 | 29 | 31 | 181 | 15 | `84cc1926ae4ce98a2bb9fcc99a5fb28c9f1eb44679952b047f9276ea733ad139` |
| `night_vision` | `#977C56` | `#D7BC96` | `#4B3E2B` | N | 4 | 64 | 29 | 31 | 179 | 17 | `101255423fa4e69f890c65872a02dfe5a0e6cbd1e262582eda906b1c72a8b40e` |

(The counts are those of the final image: the glyph overwrites bevel and face pixels, so the white count is the glyph's ink, 15 and 17 pixels.)

### 4.11 Sheets: inventory, crafting table and recipe book

The three sheets are 256 x 256 RGBA images read as whole images with the logical size 256 x 256 (14 section 6.2). Outside the screen's image area they stay transparent.
**Decision UI-10.** The built-in sheets are drawn at the logical size (no 2x), and the recipe book panel is at (0, 0) of its sheet. Reason: the built-in pack
needs no more resolution than the logical one, and a user pack at 512 x 512 works unchanged (14 section 6.2). The origin of
the recipe-book panel inside the vanilla sheet is not documented (Open question 2). The origin (rbX, rbY) is therefore a
**parameter of the client** (the point of the sheet where the client reads the 147 x 166 panel), not a constant of the recipe:
the recipe below pastes the panel at (rbX, rbY), whose value is (0, 0) until Open question 2 is closed. The check values of the
`recipe_book` sheet and the Sheets group manifest of section 9.2 hold for (0, 0) only; if the origin changes they change with it
and must be recomputed.

**`container/inventory`** (image area 176 x 166 at (0, 0); slot positions of 12 section 5.6a and 13 section 3.5). Steps in order:

1. `Paste(Bevel(176, 166, PAR, 2, 1), 0, 0)`. (The outer 3 pixels are the outline and two bevel bands.)
2. For every slot position (x, y) of the 36 main and hotbar slots (x = 8 + 18 col, y = 84 + 18 row, row 0 to 2; and x = 8 + 18 i,
   y = 142), the 4 armour slots (8, 8 + 18 i), the 4 crafting-grid slots (98 + 18 col, 18 + 18 row) and the off-hand slot
   (77, 62), in that order: `Paste(Frame(18, 18, #5E5740, #F4EFDD, #A39A7A, 1), x - 1, y - 1)`.
3. The result slot at (154, 28): `Paste(Frame(22, 22, #5E5740, #F4EFDD, #A39A7A, 2), 151, 25)`.
4. The player preview well (12 section 5.6a: the rectangle from (26, 8) to (75, 78) inclusive):
   `Paste(Frame(50, 71, #14141A, #55556A, #2B2B33, 1), 26, 8)`.
5. The arrow: `R(135, 35, 141, 37)` and `T((142, 32), (142, 40), (147, 36))`, both in `#6F674D`.

**`container/crafting_table`** (image area 176 x 166; slots of 12 section 5.6b):

1. `Paste(Bevel(176, 166, PAR, 2, 1), 0, 0)`.
2. Slot frames, 18 x 18 as above at (x - 1, y - 1), for the 27 main and 9 hotbar slots (as above) and the 9 grid slots
   (30 + 18 col, 17 + 18 row), in that order.
3. The result slot at (124, 35): `Paste(Frame(22, 22, #5E5740, #F4EFDD, #A39A7A, 2), 121, 32)`.
4. The arrow: `R(90, 42, 107, 44)` and `T((106, 38), (106, 48), (114, 43))`, both in `#6F674D`.

**`recipe_book`** (the panel of 13 section 3.9, 147 x 166): `Paste(Bevel(147, 166, PAR, 2, 1), rbX, rbY)`, with (rbX, rbY) = (0, 0)
for the check values (Decision UI-10).

The client draws the title, the inventory label and every item over the sheet (12 section 5.6), so none of them is part of the
art. The 1-pixel margin of an item cell inside its 18 x 18 slot well follows 12 section 5.6.

| Image key (section 9.2) | Size | Scaling | Non-transparent pixels | SHA-256 of RGBA |
|---|---|---|---|---|
| `container/inventory` | 256 x 256 | stretch (none) | 29212 | `5f2c1695278c2442740905e00fcc2d694b53a63e97df56cedf9098c22e5bdd7e` |
| `container/crafting_table` | 256 x 256 | stretch (none) | 29212 | `01e90ebb452e902775db939381a925ed45b2eae701972f2afd1de88b7e6fa60a` |
| `recipe_book` (origin (0, 0); depends on the unread origin, Open question 2) | 256 x 256 | stretch (none) | 24398 | `b5debe5d431df026cb369fa0d80d9696ccdfbe5cc71f5a21aa379662dbf7f841` |

### 4.12 Font image

The font is not redesigned. The glyph data, advance rule (rightmost ink column plus 2, space 4) and the missing glyph
(`F8 88 88 88 88 88 F8 00`, advance 6, engine generated) are standin section 18 and 08 section 10.10. This section only
restates the image so it has a check value.

**Definition files (follows 08 section 10.10; conflicts with faithful section 6.3).** Both world types use the font
`minecraft:default` (08 section 10.10), and the renderer ignores any `font` a text names. The built-in pack carries the 4
definition files of 08 section 10.10: `assets/minecraft/font/default.json`, `assets/minecraft/font/include/space.json`,
`assets/minecraft/font/include/default.json` and `assets/minecraft/font/include/unifont.json` (an empty provider list).
Their content is the one of 08 section 10.10 and 14 section 10.1; `include/default` holds only the `bitmap` provider shown
below, because the built-in pack supplies no image for the other providers. The generated vanilla pack carries the full
set at the same paths and so replaces these four files by the path rule. faithful section 6.3 (and 9.3), which puts the
provider in `assets/cobolcraft/font/default.json` under a `cobolcraft:` font name, is superseded (section 5.4). The earlier
statement that a second provider list for `cobolcraft:default` might be needed is void.

`assets/minecraft/textures/font/ascii.png` is 128 x 128 RGBA, 16 x 16 cells of 8 x 8 (14 section 10.2 layout, scale 1). The
glyph of code c (32 to 126) fills the cell whose top-left pixel is ((c mod 16) x 8, (c div 16) x 8): row byte r of the glyph
(standin section 18 table) sets pixel column k when bit `0x80 >> k` is set, in `#FFFFFF` (alpha 255); all other pixels, and the whole of rows 0, 1 and
8 to 15 and the cell of code 127, are transparent. It has 1128 ink pixels and 15256 transparent pixels. The earlier 128 x 48
layout of standin section 18 (cell ((c - 32) mod 16, (c - 32) div 16)) has the same ink; its check value is in section 9.

`assets/minecraft/font/include/default.json` (08 section 10.10) holds one `bitmap` provider (`providers[0]`) with `file` `minecraft:font/ascii.png`,
`height` 8, `ascent` 7 and `chars` of 16 strings of 16 characters: rows 0, 1 and 8 to 15 are 16 times `\u0000`; row 2 to row 7 are
the characters 0x20 to 0x7E in code order, with the last cell of row 7 (code 0x7F) `\u0000`:

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

**Decision UI-11 (ASCII only).** The built-in font draws codes 32 to 126; every other character draws as the
missing glyph (08 section 10.10). In the standard world type this means that accented or other letters in player
names, chat or item names show as boxes when no pack above the built-in pack supplies a font image that covers them.
Reason: 14 section 10 shows that the standard `accented` and `nonlatin_european` images hold more than 2000 glyphs; inventing that
many original glyphs is outside GAP-34, and the standard world type always has the generated resource pack above this
one (README Part 4, C10), which carries them: its `minecraft:default` definitions replace the four built-in files by path
(08 section 10.10), so the accented and non-Latin providers apply (this closes the old Open question 15).



## 5. Coverage and metadata

### 5.1 Counts

| Group | Files | Section |
|---|---|---|
| `gui` atlas sprites: hotbar, crosshair, experience, effect backgrounds | 14 | 4.1 |
| `gui` atlas sprites: hearts | 28 | 4.2 |
| `gui` atlas sprites: food | 6 | 4.3 |
| `gui` atlas sprites: armour and air | 6 | 4.3 |
| `gui` atlas sprites: container slots and icons | 8 | 4.4 |
| `gui` atlas sprites: widgets | 15 | 4.5 |
| `gui` atlas sprites: tooltips, popup, toast | 4 | 4.6 |
| `gui` atlas sprites: recipe book | 21 | 4.7 |
| Menu tiles and separators | 8 | 4.8 |
| Pack icon | 1 | 4.8 |
| Crack overlays (two sets of 10) | 20 | 4.9 |
| Sheets | 3 | 4.11 |
| Font image | 1 | 4.12 |
| **PNG files in all** | **135** | |
| Not stored files: effect icons, 40 virtual files made at pack open | 40 | 4.10 |
| Added metadata: 15 nine-slice `.mcmeta` files (`atlases/gui.json` is already in 08 section 10.2 and its count) | 15 | 3, 5.3 |
| Font definition files (08 section 10.10, already in 08's count) | 4 | 4.12 |

08 section 10.9 counts 98 files, or 101 with the three optional ones, and that count already includes the font image (1 of
its 27 PNG) and the 4 font definitions; it does not count the GUI sprites. So this document adds 134 PNG files (135 less the
font image that 08 has) plus 15 JSON files (the `.mcmeta` files; 08 section 10.9 counts the three atlas definitions, 10.2, among its 98): 98 + 134 + 15 = 247 files, or 250 with the optional ones, not counting the 40
virtual effect icons. README P08-13 asks for the recount; the new total is for the writer of 08 to confirm once the tool
document and the world-type document land.

### 5.2 Reconciliation with faithful section 6.4

faithful section 6.4 listed 58 ids (3 sheets, 55 sprites) that the client uses, 4 of which Faithful 32x lacks. All 58
are supplied here. The changes:

| Id | Earlier design | Now |
|---|---|---|
| `hud/crosshair` | 15 x 15, two white lines | unchanged (section 4.1) |
| `container/slot_highlight_front` | 16 x 16, white 40 % | 24 x 24, white 40 % over the middle 16 x 16 (Decision UI-8) |
| `container/slot_highlight_back` | 1 x 1, transparent | 24 x 24 glow ring (Decision UI-8) |
| `widget/scroller_background` | 6 x 32, nine-slice border 1, black 40 % | unchanged (section 4.5) |
| `container/crafting_table` | "bind after that is read; until then use `cobolcraft:gui/container/bench`" | the layout is read (12 section 5.6b, 13 section 3.5), so the built-in `minecraft:gui/container/crafting_table` sheet is drawn here (section 4.11); no `cobolcraft:gui/container/bench` is needed |

Added to the 58: the sprites of the HUD (attack indicators, experience bar, effect backgrounds, air, armour), all heart
variants, hunger food, five empty-slot icons, `popup/background`, `toast/recipe`, the menu tiles and separators, the pack
icon, the second crack set, the generated effect icons and the font image restatement.

### 5.3 Nine-slice metadata

Fifteen sprites carry a `.mcmeta` file of the form of section 3. W and H are the sprite size, B the border.

| Sprite id | W | H | B |
|---|---|---|---|
| `widget/button`, `widget/button_highlighted`, `widget/button_disabled` | 200 | 20 | 2 |
| `widget/text_field`, `widget/text_field_highlighted` | 200 | 20 | 1 |
| `widget/slider`, `widget/slider_highlighted` | 200 | 20 | 2 |
| `widget/slider_handle`, `widget/slider_handle_highlighted` | 8 | 20 | 2 |
| `widget/scroller` | 6 | 32 | 2 |
| `widget/scroller_background` | 6 | 32 | 1 |
| `tooltip/background`, `tooltip/frame` | 100 | 100 | 9 |
| `popup/background`, `recipe_book/overlay_recipe` | 32 | 32 | 4 |

Rule for the writer of each: a user pack that replaces one of these PNG files must ship its own `.mcmeta` too (Decision UI-21), otherwise
the sprite is stretched. The border B must leave a non-empty centre in both directions (08 section 7.4): the smallest case is the
8-pixel-wide handle with B = 2, a centre of 4 pixels. The border values are chosen (Decision UI-21), and the three buttons
differ from 12 section 5.9 (border 3, and 1 for disabled).

### 5.4 Sections of other documents that this document supersedes

Until the other documents are edited (README T18, T19, P08-9, P08-10, P08-13), the repository holds two recipes for the same
sprite ids. This document wins for these, and the owner of each must edit them:

| Document and section | What it says now | What replaces it |
|---|---|---|
| faithful 6.4 | slot highlights 16 x 16 front and 1 x 1 back | 24 x 24 both (Decision UI-8, section 4.4) |
| faithful 6.4 | crafting-table sheet falls back to `cobolcraft:gui/container/bench` | the built-in `minecraft:gui/container/crafting_table` sheet (section 4.11) |
| faithful 6.3 and 9.3 | font definition `cobolcraft:` at `assets/cobolcraft/font/default.json` | the 4 `minecraft:default` definition files of 08 section 10.10 (section 4.12) |
| faithful 9.4 | "about 96 more" sprites | 102 `gui` sprites (section 1) |
| 08 section 10.9 | the count leaves out the GUI art | section 5.1 (98 + 134 + 15 = 247) |
| 08 section 10.2 (closing sentence) | "built-in GUI sprites ... not yet specified, so the table of 10.3 lists none" | this document specifies them (sections 4 and 5.1); 08 already defines `atlases/gui.json` (10.2), which is unchanged |
| 08 section 10 | no virtual effect icons | the virtual `mob_effect` files (section 4.10; Open question 7) |

## 6. Text colours and fallback UI texts

**Decision UI-12 (text colours).** The client draws text in the colours below. The first two come from 12 (read); the others
are chosen here because the screens need them.

| Role | Colour and treatment | Source |
|---|---|---|
| Labels on parchment containers | `#404040`, no shadow | 12 section 5.6 |
| Normal text: titles, button labels, tooltips, chat | `#FFFFFF`, with shadow (`#3F3F3F`, an assumption: truncation, see below) | 12 section 5.8, 5.9, 5.10 |
| Secondary text: world folder, type line, path | `#A0A0A0`, with shadow | chosen |
| Disabled button label | `#A0A0A0`, with shadow | chosen (12 section 5.9 Open question 5; Open question 14) |
| Warning text: unavailable world type, banner | `#FFC857`, with shadow | chosen |
| Experience level number | `#80FF20` over a black outline | 12 section 5.4 |
| Text on parchment (page label, toast text) | `#404040`, no shadow (as the labels above) | chosen (Decision UI-23) |
| Recipe-book tab letters | `#1A1A1A`, no shadow (on `#A39A7A` and `#D8D0B4`) | chosen (Decision UI-22) |
| Search text and hint | `#FFFFFF` with shadow; hint `#A0A0A0`; drawn on the dark `widget/text_field` | 13 section 3.9, Decision UI-23 |

Reason for the chosen ones: they are drawn only on dark surfaces (the menu tiles `#1E1E26` and `#101016`, `popup/background`
`#2B2B33`, the disabled button face `#3A3F45`), where the contrast ratios (WCAG relative luminance) are `#A0A0A0` 6.3 to 7.2 on
the tiles and 4.1 on the disabled button, `#FFC857` 10.8 and 12.3 on the tiles and 6.9 on the disabled button face, and `#FFFFFF`
at least 10.6 on every one of them; and a single warning colour makes "something is wrong with this choice" recognisable at a
glance. The shadow colour follows 12 section 5.10's rule (each of r, g, b multiplied by 0.25). The rounding is not documented
and 255 x 0.25 = 63.75: truncation gives `#3F3F3F`, rounding to nearest gives `#404040`. The value `#3F3F3F` is an assumption
(truncation) and the rounding is the client's; no check value depends on it. Parchment surfaces (`PAR`, `TAB`, `SLOT`, and the `toast/recipe` face) carry only dark text with no shadow: the `#404040` labels of 12 section 5.6
(contrast about 6.7 on `#D8D0B4`, 3.7 on `#A39A7A`), and `#1A1A1A` where the face is the darker `#A39A7A` (tab letters, contrast about 6.2).
White on `#D8D0B4` would be 1.54 and on `#A39A7A` about 2.8 (computed), which is why white text is never drawn on parchment
(the search text sits on the dark text field instead, Decision UI-23).

### 6.1 Fallback texts for the new screens

**Decision UI-14 (keys).** The client's own screens use keys under `cobolcraft.` (08 section 10.8.6: "These keys belong to the
client alone"), so that the standard keys of the generated language file never collide with them. The new keys of this
document are added to the built-in `lang/en_us.json` of 08 section 10.8.6 in the same way. Reason: the standard key names
for these labels were not read (GAP-27), and a key the client alone uses cannot be overridden by accident. All texts are
ASCII (Decision UI-11). `%s` is replaced by the argument in order.

| Key | Arguments | Value |
|---|---|---|
| `cobolcraft.world_type.standard` | none | Standard |
| `cobolcraft.world_type.cobolcraft` | none | CobolCraft |
| `cobolcraft.world_type.standard.description` | none | Minecraft 26.3 content, generated from your game jar. |
| `cobolcraft.world_type.cobolcraft.description` | none | CobolCraft's own content. Needs no jar. |
| `cobolcraft.screen.create_world.type` | type name | World type: %s |
| `cobolcraft.screen.world_list.type` | type name | Type: %s |
| `cobolcraft.ui.missing_data.title` | none | Game Data Missing |
| `cobolcraft.packs.absent` (22 section 9.2, not new here) | none | Minecraft content is not set up. Run the extraction tool with your Minecraft 26.3 client jar to play standard worlds. |
| `cobolcraft.packs.incomplete` (22 section 9.2) | none | The Minecraft content is incomplete. Run the extraction tool again. |
| `cobolcraft.packs.stale` (22 section 9.2) | none | The Minecraft content was made for another version. Run the extraction tool again. |
| `cobolcraft.packs.damaged` (22 section 9.2) | none | The Minecraft content is damaged. Run the extraction tool with --force. |
| `cobolcraft.world_type.standard.unavailable` (22 section 9.2) | none | Standard worlds need the Minecraft content. See the title screen message. |
| `cobolcraft.ui.missing_data.short.absent` | none | Needs Minecraft content from your jar. |
| `cobolcraft.ui.missing_data.short.incomplete` | none | Minecraft content is incomplete. |
| `cobolcraft.ui.missing_data.short.stale` | none | Minecraft content is for another version. |
| `cobolcraft.ui.missing_data.short.damaged` | none | Minecraft content is damaged. |
| `cobolcraft.ui.missing_data.path` | path | Looked in: %s |
| `cobolcraft.ui.missing_data.what_works` | none | The CobolCraft world type needs no extra data and still works. |
| `cobolcraft.ui.missing_data.fix` | none | Command: cobolcraft-extract --jar <file>, then restart the game. |
| `cobolcraft.ui.missing_data.banner` | none | Game data missing. Click for details. |
| `cobolcraft.ui.missing_data.use_cobolcraft` | none | Use CobolCraft World Type |
| `cobolcraft.screen.common.search_hint` | none | Search... |
| `cobolcraft.screen.recipe_book.filter_on` | none | Showing Craftable |
| `cobolcraft.screen.recipe_book.filter_off` | none | Showing All |
| `cobolcraft.screen.recipe_book.more` | none | Right Click for More |
| `cobolcraft.screen.recipe_book.page` | page, total | %s/%s |
| `cobolcraft.screen.recipe_book.tab.search` | none | Search |
| `cobolcraft.screen.recipe_book.tab.equipment` | none | Equipment |
| `cobolcraft.screen.recipe_book.tab.building` | none | Building Blocks |
| `cobolcraft.screen.recipe_book.tab.misc` | none | Misc |
| `cobolcraft.screen.recipe_book.tab.redstone` | none | Redstone |
| `cobolcraft.screen.recipe_book.toast` | none | New Recipe |
| `cobolcraft.screen.packs.open_folder` | none | Open Pack Folder |
| `cobolcraft.screen.packs.open_folder_tooltip` | none | (Place pack files here) |
| `cobolcraft.screen.packs.drop_hint` | none | Drag and drop files into this window to add packs |

The five reason texts and `standard.unavailable` are the keys and texts of 22 section 9.2 (the two documents are reconciled to
use the same keys; 22 owns them and this table repeats them for the reader). The `short`, `path`, `fix` and `title` keys are
new here; `fix` carries the tool's command line `cobolcraft-extract --jar <file>` of 22 section 9.2. `standard.unavailable` is
not drawn by any screen of this document: it is 22's text for a disabled standard choice and for opening a standard world by
other means (section 8.1 says where this document differs); the screens here show the reason text or the `short` text instead.

The recipe-book, search and pack-folder texts are the English words of 13 section 3.9 and 13 section 8; they are listed
here only because the sprites of sections 4.5 to 4.7 are drawn for them. The existing `cobolcraft.screen.*` keys of 08 section
10.8.6 are unchanged and are reused (for example `cobolcraft.screen.common.back`, `cobolcraft.screen.create_world.create`).
The options screen texts are not supplied (Open question 13); GAP-34 is not closed for them (section 0).

## 7. World type selection

### 7.1 Model

There are two world types, `standard` and `cobolcraft` (README Part 1 and Part 4, C1). Their names on screen are the keys
`cobolcraft.world_type.standard` and `.cobolcraft`. The type of a world is stored with the world (README decision 2,
`WorldType` in `level.dat`); the exact key and values belong to the world-type document (GAP-33) and are used here as working
names (Open question 8). The `standard` type is **available** when the result of the generated-pack check of 22 section 8.2 is
`ok` (section 8.1); the `cobolcraft` type is always available.

### 7.2 Create New World screen

**Decision UI-15 (the type control).** The Create New World screen gets one more row: a **cycle button** (a normal button
of 200 x 20, sprites `widget/button*`) that shows `cobolcraft.screen.create_world.type` with the name of the selected type.
Activating it (click, Enter or Space when focused) selects the next type in the order `standard`, `cobolcraft`, and wraps. Both
types are always in the cycle, even when `standard` is unavailable. (README Part 4, C10 says that without a valid jar the game
"offers only the cobolcraft world type", and README decision 2 says a missing or wrong jar "disables the standard type": the
"offers only" and "disables" wordings differ from this rule; the outcome, that no standard world is created, is the same,
because Create opens the missing-data screen. Open question 20.) Reason: if the unavailable type were hidden, the player
would never learn that it exists or why it is missing, and README Part 4, C10 requires that "the game says why"; if it were a
disabled button, the player could not select it to see the reason. Showing it, selectable, with the reason beside it, does
both with no extra widget.

**Conflict with 22 section 9.2 (stated, not settled).** 22 section 9.2 says that the standard choice on the world-creation
screen is disabled while the packs are not valid (its `cobolcraft.world_type.standard.unavailable` row). This document keeps
the choice selectable and explains on Create (Decision UI-16). The two cannot both hold; this document follows its own rule
(selectable) because a disabled choice would explain nothing, and the operator or the owner of 22 settles it (Open question
20). If 22's rule wins, the cycle skips `standard` and the description block shows `standard.unavailable` under the button.

Initial selection: `standard` if it is available, else `cobolcraft` (README decision 2: "default `standard` when the generated
packs are present, otherwise `cobolcraft`").

Below the cycle button is a **description block**: left-aligned text, wrapped to 200 pixels at the greedy rule of section 8.3 with a
line pitch of 11, at most 3 lines (further lines are not drawn). When the selected type is available it is the type's
description key (`#A0A0A0`). When it is unavailable it is the `short` key of the current reason
(`cobolcraft.ui.missing_data.short.<reason>`, reason one of `absent`, `incomplete`, `stale`, `damaged`, `#FFC857`).

**Decision UI-16 (Create and Play stay enabled).** The Create button is never disabled by the type. If the player presses it
while the selected type is unavailable, no world is made and the missing-data screen of section 8.3 opens, with the extra
button `Use CobolCraft World Type`. Reason: a disabled button answers "why" with silence; a pressed button can open the full
explanation, and it is the same screen for every trigger.

Layout, in GUI pixels (12 section 5.1), with cx = guiW div 2. The earlier rows exist already (08 section 10.8.6 keys); their
positions are fixed here because no document gives them (Open question 17). Values for the smallest automatic GUI, 320 x 240:

| Element | x | y | Width x height | At 320 x 240 |
|---|---|---|---|---|
| Title `cobolcraft.screen.create_world.title`, centred, white | (guiW - textWidth) div 2 | 20 | text x 9 | "Create New World" is 90 wide: x = 115 |
| Label `cobolcraft.screen.create_world.name`, `#A0A0A0` | cx - 100 | 40 | text x 9 | x = 60 |
| Name field (`widget/text_field`) | cx - 100 | 50 | 200 x 20 | (60, 50) |
| Game mode cycle button (existing) | cx - 100 | 78 | 200 x 20 | (60, 78) |
| **World type cycle button** | cx - 100 | 102 | 200 x 20 | (60, 102) |
| **Description block** | cx - 100 | 128 | 200 wide, up to 3 x 11 - 2 = 31 | (60, 128) to y = 159 |
| Create button | cx - 122 | guiH - 28 | 120 x 20 | (38, 212) |
| Cancel button | cx + 2 | guiH - 28 | 120 x 20 | (162, 212) |

Worked example at 320 x 240, `standard` unavailable with reason `absent`: the button reads "World type: Standard" (111 wide,
centred in the button: text x = 60 + (200 - 111) div 2 = 104). The description block wraps
"Needs Minecraft content from your jar." (209 wide) into the two lines "Needs Minecraft content from your" (184 wide)
and "jar." (21 wide), at (60, 128) and (60, 139), both `#FFC857`. After one activation the button reads "World type:
CobolCraft" (121 wide), and the block shows "CobolCraft's own content. Needs no jar." (212 wide) in `#A0A0A0`, wrapped as "CobolCraft's own content. Needs no" (187 wide) and "jar." (21 wide). The widths use the advances of standin section 18 (the width of a line is the sum of
the advances of its characters, spaces advance 4).

### 7.3 World list

**Decision UI-17 (type on the list).** In the world list (08 section 10.8.6 `cobolcraft.screen.world_list.entry`), each row gets a second text line, drawn
11 pixels below the first line and aligned with it: `cobolcraft.screen.world_list.type` with the world's type name in `#A0A0A0`
when the type is available, or the `short` key of the reason (section 8.1) in `#FFC857` when it is not. The Play button is not
disabled for such a world: pressing it opens the missing-data screen (without the extra button, because a world's type
cannot be changed). Reason: the same as Decision UI-16, and the row itself tells the player which worlds are affected before
they press anything. A world of an unavailable type is never opened and is never altered.

## 8. The missing-data message

### 8.1 States

The state is the result of the generated-pack check of 22 section 8.2, computed at start-up, at every resource reload and
whenever the screens of this section are opened. That check does **not read the jar and hashes nothing**: its inputs are the
generated directory (22 section 5.1) and the compiled-in accepted-jar table (22 section 4.1), and its result is `ok` or one
of the four reason words below (22 section 8.2 step order: the first failing step decides). The earlier states of this
document (`no_jar`, `wrong_jar`, `no_packs`) are void: the jar is needed only to (re)generate, not at run time (22 section
8.2 and 8.6).

| State (22 reason) | Meaning (22 section 8.2) | Text key | `Looked in` shows |
|---|---|---|---|
| `absent` | the generated directory does not exist, or `manifest.txt` and the tool's marker are both missing | `cobolcraft.packs.absent` | the generated directory (22 section 5.1) |
| `incomplete` | `manifest.txt` is missing but the tool's marker exists | `cobolcraft.packs.incomplete` | the generated directory |
| `stale` | the manifest does not equal a row of the accepted-jar table | `cobolcraft.packs.stale` | the generated directory |
| `damaged` | the manifest is invalid, or a sentinel file is missing | `cobolcraft.packs.damaged` (its text says to use `--force`) | the generated directory |
| `ok` | the check passes | none | not shown |

**Decision UI-18 (one result, no precedence).** The state is the single result of 22 section 8.2, so this document has no
precedence rule of its own. Reason: the check already orders its steps. The cobolcraft world type does not depend on the
state.

**Which side this document follows (README C10 and decision 2 against 22).** README Part 4, C10 and decision 2 say that a
missing or wrong jar disables the standard type, even when packs were generated earlier; 22 section 8.2, 8.6 and its Open
question 2 say that a valid generated directory is enough and the jar is not needed at run time. This document **follows 22**:
no state depends on the presence of a jar, and `no_jar` and `wrong_jar` do not exist. The conflict between README and 22
is the operator's to settle (Open question 9); if README wins, the states `no_jar` and `wrong_jar` return in front of the
four reasons.

### 8.2 Where the message appears

| # | Trigger | Surface |
|---|---|---|
| T1 | The title screen is shown while the state is not `ok` | the banner (section 8.4) |
| T2 | Create is pressed with an unavailable type selected | the missing-data screen with the extra button |
| T3 | Play is pressed on a world of an unavailable type | the missing-data screen with only Back |
| T4 | The banner is clicked or activated | the missing-data screen with only Back |

Joining a server of the standard world type without the generated packs, and starting a dedicated server for it, follow
22 section 8.6 and 9.2 and need no screen of this document: the client still joins (stripes where a standard asset is missing,
with the banner of section 8.4 on the title screen), and a dedicated server configured for a standard world prints the text of
the reason key (22 section 9.2, English, the console has no pack) followed by the command line `cobolcraft-extract --jar <file>`,
and exits with a non-zero status (22 section 8.6).

### 8.3 The missing-data screen

The screen is drawn over the previous screen's background (the menu tile, or the dark gradient of 12 section 5.6 in a world).

Contents, in this order, each a paragraph:

| # | Paragraph | Key | Colour |
|---|---|---|---|
| 1 | the reason text | `cobolcraft.packs.<reason>` (section 8.1) | `#FFC857` |
| 2 | where it looked | `cobolcraft.ui.missing_data.path` with the generated directory, capped (rule below) | `#A0A0A0` |
| 3 | what still works | `cobolcraft.ui.missing_data.what_works` | `#FFFFFF` |
| 4 | what to do | `cobolcraft.ui.missing_data.fix` (the command line of 22 section 9.2) | `#FFFFFF` |

**Decision UI-19 (design of the screen).** A single centred panel with a title, four paragraphs and one or two 200 x 20
buttons below it. Reason: it follows the shape of the existing notice screens (pack confirmation, delete confirmation, 08
section 10.8.6) and needs no widget that is not already in section 4.5 and 4.6.

Rules:

- `wrapW` = min(guiW - 40, 320). `panelW` = wrapW + 24; `panelX` = cx - panelW div 2; `panelY` = 24. The panel is drawn with
  `popup/background` (nine-slice 32 x 32, border 4) over the rectangle (panelX, panelY, panelW, panelH).
- The title `cobolcraft.ui.missing_data.title` is white, centred at x = (guiW - textWidth) div 2, top y = panelY + 10.
- The paragraphs start at x = panelX + 12. The first paragraph's top is y = panelY + 30. A paragraph is wrapped to `wrapW` by
  the **greedy rule**: take words (separated by single spaces); add a word to the current line while the line's width
  (sum of advances, standin section 18, spaces 4) stays at most `wrapW`, otherwise start a new line; a word wider than
  `wrapW` is broken at the last character that fits. Lines are 11 pixels apart. A paragraph of n lines occupies 11 n - 2 pixels
  (the last line's text is 9 high). The next paragraph's top is 6 pixels below the last line's bottom.
- **Path cap.** Paragraph 2 is at most 2 lines. If "Looked in: " plus the path wraps to more than 2 lines by the greedy rule, the
  path is cut from its end, one character at a time, until "Looked in: " plus the cut path plus `...` fits in 2 lines, and the
  paragraph shows the cut path followed by `...`. A path character outside codes 32 to 126 draws as the missing glyph (a box,
  advance 6, Decision UI-11) and is counted so; the screen does not try to transliterate it. With the cap, every paragraph
  has a bounded length: at 320 x 240 the worst case (reason `absent`, a path of 2 lines, the extra button) puts the bottom of
  Back at y = 231, inside guiH = 240 (checked for all four reasons; the worked example gives the one-line-path numbers).
- `panelH` = (bottom of the last line) - panelY + 12.
- The buttons are 200 x 20 at x = cx - 100. The first is at y = panelY + panelH + 12; if the extra button is present
  it is first (`cobolcraft.ui.missing_data.use_cobolcraft`), and Back (`cobolcraft.screen.common.back`) is 24 pixels below it,
  otherwise Back is first.
- Escape and Back return to the previous screen. `Use CobolCraft World Type` sets the Create screen's type to `cobolcraft`,
  returns to the Create screen and creates nothing. Enter activates the first button.

Worked example, 320 x 240, reason `absent`, path `/home/player/cobolcraft/generated` (an example), opened from Create (T2): wrapW = 280,
panelW = 304, panelX = 8, panelY = 24. Title "Game Data Missing" is 95 wide: x = 112, top y = 34. Paragraph tops and lines:

| Paragraph | Top y | Lines (width) |
|---|---|---|
| 1 | 54 | "Minecraft content is not set up. Run the extraction" (276); "tool with your Minecraft 26.3 client jar to play" (257, at y = 65); "standard worlds." (90, at y = 76) |
| 2 | 91 | "Looked in: /home/player/cobolcraft/generated" (251) |
| 3 | 106 | "The CobolCraft world type needs no extra data and" (271); "still works." (63, at y = 117) |
| 4 | 132 | "Command: cobolcraft-extract --jar <file>, then" (253); "restart the game." (93, at y = 143) |

The last line's bottom is 143 + 9 = 152, so panelH = 152 - 24 + 12 = 140 and the panel spans y = 24 to 164. The extra button
is at (60, 176) and Back at (60, 200). For `incomplete`, `stale` and `damaged` with a one-line path the panel is 129 high (their
first paragraph is 2 lines); a 2-line path adds 11 to each panel.

### 8.4 The title-screen banner

When the state is not `ok`, the title screen draws one line (T1): a `popup/background` panel (nine-slice, border 4) of width
textWidth + 16 and height 20 at x = (guiW - width) div 2, y = 8, and the text `cobolcraft.ui.missing_data.banner` in
`#FFC857` at (x + 8, y + 5). At 320 x 240 the text is 198 wide, so the panel is 214 x 20 at (53, 8) and the text is at
(61, 13). When the pointer is over the panel, or it has keyboard focus, `Ring(x, y, x + width - 1, y + 19, 1, #FFFFFF)` is
drawn over its edge. Clicking or activating it opens the screen of section 8.3 (T4).

**Decision UI-20 (no dismissal).** The banner is shown every time the title screen is shown while the state is not `ok`; there is
no "do not show again" option and nothing is stored. Reason: a stored dismissal is state that can go stale (the player installs
the jar and forgets), the line costs one row of the screen, and the options file of 13 section 7 stays free of a setting
that nobody asked for. The banner position is chosen without a title layout to check against (Open question 10).

## 9. Check values

Sections 4.1 to 4.11 contain, for every file, the size, the number of non-transparent pixels (alpha greater than 0) and
the SHA-256 of the raw RGBA bytes (rows top to bottom, pixels left to right, bytes R, G, B, A), as in standin section 1.5.

### 9.1 How to use them

An implementation generates each image from its recipe, hashes the bytes in that order and compares. A mismatch means the
recipe was read differently; the manifest of 9.2 locates which group.

### 9.2 Group manifests

The **key** of a member is exactly the string in the first column of its table, and it is also what the manifest line starts
with. For atlas sprites it is the sprite id (`widget/button`, `block/destroy_stage_3`). For whole images it is the path
below `textures/` without `.png` and without a leading `gui/` (so `menu_background` is the file `textures/gui/menu_background.png`,
`container/inventory` is `textures/gui/container/inventory.png`, `recipe_book` is `textures/gui/recipe_book.png`), except
`misc/unknown_pack`, which is below `textures/` itself (`textures/misc/unknown_pack.png`). No manifest key starts with `gui/` or `textures/`.
In byte order `block/destroy_oit_stage_N` sorts before `block/destroy_stage_N`.

A group manifest is the SHA-256 of the UTF-8 text made of one line per member, sorted by key (byte order of the key string
as written in the first column of the member tables of sections 4.1 to 4.11, without `minecraft:`), each line the id, a tab, the member's SHA-256 in lower case hex and a
line feed.

| Group (section) | Members | Manifest SHA-256 |
|---|---|---|
| HUD (4.1) | 14 | `ce26ed48529a64bf06241bff792f19732350670b44a8ab0c7784c6e8eed712b1` |
| Hearts (4.2) | 28 | `487e8cf24e4461b37e39e61d076f644319a530d9f4fbdfbc32a364d49cf12f64` |
| Food (4.3) | 6 | `72ce66c5d345dd11cbe48c59dfec388be4df8ad1a50be3c36e4542d9fd7870bd` |
| Armour and air (4.3) | 6 | `6852f9222fccccd78581ff41b1289b7a2d3fdc4ef8e73aee1780f422245180ef` |
| Container (4.4) | 8 | `7d5c894f9e5751c463537713fdbd6e4710b14fae424f9cbcca08ddc40707df54` |
| Widgets (4.5) | 15 | `8707adef0357ef30f19db413db2902a559151b3ae7aeb4a3091b7e3ceda4d3ed` |
| Tooltips, popup, toast (4.6) | 4 | `746ac9cc8f44a1d45c439dd30415192ea071934940acad51390852c279c37792` |
| Recipe book (4.7) | 21 | `1d21c9bfd69932ff47e68c4644df4c147678dce18cbe3c7a5b14c1c3719f0fb1` |
| Menu tiles (4.8) | 8 (ids: `menu_background`, ...) | `54ce53f995bdb0efac069adf2573094da62cf4ea59892d5f94554598ff9f86c4` |
| Pack icon (4.8) | 1 (`misc/unknown_pack`) | `64429336d33116504793186b0dbb5ec7dbadaeed2bf67011a53cb25f550014b3` |
| Crack overlay (4.9) | 20 (ids: `block/destroy_stage_N`, `block/destroy_oit_stage_N`) | `f263d943bb93b125fb27470d4e82bc4ede98e6d031b30f484838ac92488d2427` |
| Sheets (4.11) | 3 (ids: `container/inventory`, `container/crafting_table`, `recipe_book`) | `7b89b76c45319c214fa63a2ed24b3780cc2fdb3237867707ee0a976d46df9f8e` |

### 9.3 Font image and spot checks

| Item | Value |
|---|---|
| `font/ascii.png` 128 x 128 (section 4.12) | 1128 `#FFFFFF`, 15256 transparent; SHA-256 `b754d7f30c6e5e8c996f1155b1dd31004099eca7497623d20941aea9b1ee0556` |
| the older 128 x 48 layout of standin section 18 | 1128 `#FFFFFF`, 5016 transparent; SHA-256 `d8fb610fda8183ee66a2570270e8045b87271c0ba94467570c99a1d9a6efb037` |
| Advances | space 4, `A` 6, `W` 6, `i` 5, `!` 4 (standin section 18) |

Spot checks (pixel colours; `transparent` is RGBA 0, 0, 0, 0):

| Image | Pixel (x, y) and colour |
|---|---|
| `menu_background` | n = H(bytes of `menu_background`, x, y) mod 100: (0, 0) n = 9 gives `#262630`; (31, 31) n = 71 gives `#1E1E26`; (5, 7) n = 87 gives `#1E1E26` |
| `menu_list_background` | (0, 0) `#0B0B10`; (31, 31) `#101016` |
| `widget/button` | (0, 0) transparent; (1, 1) `#7FA9C9`; (198, 1) `#24425A`; (2, 2) `#3E6C8F`; (100, 10) `#3E6C8F`; (100, 18) `#24425A` |
| `hud/hotbar` | (0, 0) transparent; (1, 1) `#45454F`; (2, 2) `#14141A`; (3, 3) `#1F1F25`; (20, 20) `#1F1F25` |
| `misc/unknown_pack` | (0, 0) `#3B2F5C`; (4, 4) `#1F1B2E`; (8, 8) `#6A4FB3`; (24, 24) `#C9B8FF`; (32, 32) `#C9B8FF` |
| `container/inventory` | (0, 0) transparent; (2, 2) `#F4EFDD`; (7, 83) `#5E5740`; (8, 84) `#A39A7A`; (150, 24) `#D8D0B4`; (151, 25) `#5E5740`; (140, 36) `#6F674D` |
| `container/crafting_table` | (100, 43) `#6F674D`; (122, 33) `#5E5740`; (135, 36) `#A39A7A` |
| crack stage N | n at (0, 0) = 51, at (15, 15) = 55, at (7, 7) = 3 (faithful section 8.1) |

## 10. Checking an implementation

1. Generate all 135 PNG files and the 15 `.mcmeta` files and count them: 102 sprites in `gui/sprites/`, 20 under `block/`, 8 menu
   images, the pack icon, 3 sheets and the font image; check that the pack lists the 4 font definition files of 08 section 10.10
   and 40 virtual `mob_effect/<name>.png` files (section 4.10).
2. Hash every file as in section 9 and compare with sections 4.1 to 4.12, then the manifests of 9.2.
3. Check that no sprite of the table of section 1 marked "supplied" is requested by the client and found missing: start the
   client in the cobolcraft world type with no other pack, open the inventory, the bench, the recipe book, Create New World,
   the pack screen, and look for the missing-texture stripes (standin section 1.4.2). None may appear in any of them.
4. Replace the built-in pack's `widget/button` with a 32x pack file of the same path **and its own `.mcmeta`** (nine-slice,
   for example border 3) and check that every button changes and nothing else does (SC-005 style test; 14 section 6.3 says a
   nine-slice sprite may be at any resolution as long as the aspect ratio holds). Then remove the `.mcmeta` from that pack and
   check that the sprite is stretched over each button (no inherited built-in nine-slice; 08 section 3.2, Decision UI-21).
5. Create the worked examples of sections 7.2 and 8.3 (320 x 240) and check every coordinate in them.

## 11. Decisions

| Id | Decision | Section |
|---|---|---|
| UI-1 | Built-in GUI art is in the `minecraft:` namespace at the client's own paths | 3 |
| UI-2 | Sprites are drawn 1:1 at their own size; unread sizes are chosen here | 3 |
| UI-3 | The look is "parchment and ledger": blues and violets reused, parchment chosen near `cardstack` | 2.1 |
| UI-4 | Beveled flat art with no noise, except the two menu tiles | 2.1 |
| UI-5 | Every heart variant of 12 section 5.4 is supplied | 4.2 |
| UI-6 | Boss bars, mount hearts, furnace recipe book, locator and jump bars, lock buttons, title logo and the other screen groups are omitted (every id listed, with fallback) | 1 |
| UI-7 | Effect icons are generated from the effect's name, for a fixed list of 40 names, as virtual files of the built-in pack | 4.10 |
| UI-8 | Slot highlights are 24 x 24 | 4.4 |
| UI-9 | The second crack set is a copy of the first | 4.9 |
| UI-10 | Built-in sheets are at logical size; the recipe book panel is at (0, 0) | 4.11 |
| UI-11 | The built-in font is ASCII only; the definitions are the 4 `minecraft:default` files of 08 section 10.10 | 4.12 |
| UI-12 | Text colours | 6 |
| UI-13 | The tooltip frame sits at pixels 7 and 8 of the border | 4.6 |
| UI-14 | New texts use `cobolcraft.` keys | 6.1 |
| UI-15 | World type is a cycle button on the Create screen, both types always listed | 7.2 |
| UI-16 | Create and Play are never disabled by the type; they open the missing-data screen | 7.2 |
| UI-17 | The world list shows the type on a second line | 7.3 |
| UI-18 | The state is the single result of 22 section 8.2 (`absent`, `incomplete`, `stale`, `damaged`); no jar state; follows 22 against README C10 | 8.1 |
| UI-19 | One centred panel for the missing-data screen, path capped at 2 lines | 8.3 |
| UI-20 | The title banner has no dismissal and stores nothing | 8.4 |
| UI-21 | Nine-slice borders are chosen; buttons use 2 against 3 and 1 of 12 section 5.9 | 3, 5.3 |
| UI-22 | Recipe-book tab icons are letters in the cobolcraft world type | 4.7 |
| UI-23 | Recipe-book search field uses `widget/text_field`; dark text without shadow on parchment | 4.7, 6 |

## 12. Open questions

Each is for the planner or the next clean-room round; none blocks an implementation of this document, because every one
has a stated working choice.

1. **Sprite sizes not read.** The sizes of `hud/hotbar_attack_indicator_background` and `_progress` (18 x 18), the three
   crosshair indicator sprites (16 x 16), `hud/effect_background` and `_ambient` (24 x 24), the recipe-book tab (32 x 27),
   the recipe slots and overlay buttons (25 x 25), `popup/background` (32 x 32), `recipe_book/overlay_recipe` (32 x 32) and
   `toast/recipe` (160 x 32) are choices. A round that reads the sprite sizes or the draw calls of 14 section 6.1's classes should confirm or
   replace them. A pack's own sizes already work (14 section 6.3).
2. **Sheet regions.** 14 section 6.2 and 12 section 5.6 give the region of the inventory and crafting-table sheets, (0, 0, 176, 166).
   The region of `recipe_book.png` that the 147 x 166 panel uses is not given (13 section 3.9 says only that the texture is 256 x 256). If
   the real sheet has the panel at another origin, the client must use that origin and the built-in sheet of section 4.11 must
   move the panel to it.
3. **Attack indicator drawing.** Whether the `_progress` sprites are clipped horizontally or vertically by the cooldown,
   and whether the hotbar indicator is 18 x 18 (12 section 5.2 says only "not detailed here").
4. **Recipe-book tab and toast details.** Original tab icons (new sprite ids with recipes) are not drawn; Decision UI-22 uses
   letters in the cobolcraft world type, and the real icon offsets in the standard type are still unread. Also the tab sprite width, the id
   of the toast sprite (`toast/recipe` is a working name from 14 section 6.1's `toast/*`) and the toast's texts.
5. **Other sprite ids.** 14 section 6.1 says its list is "the list our client needs, not every sprite of the jar". Ids that the
   cobolcraft client's classes ask for and that are not in the list would show as stripes; a read of the sprite string
   constants of the screens in section 1's "supplied" rows would settle it.
6. **Omitted families reachable by commands.** `bossbar` (16 section 4 catalogue) can create a boss bar; the locator bar
   and jump bar share the experience-bar slot (12 section 5.4); `summon` can create rideable entities. In the cobolcraft world type
   these draw stripes until a recipe is added here. Decide whether to supply them.
7. **Effect icon names and the virtual-file rule.** Whether the client asks the `gui` atlas for `mob_effect/<name>` with the effect's registry
   path and at what size (18 x 18 is assumed; 14 section 7.5 says only "square"). 08 section 10 has no virtual-file
   mechanism; searched: 08 section 10 and 14 section 3; section 4.10 adds the rule and 08 must state it.
8. **World-type document names.** The `level.dat` key, the stored values, the setting `world-type` and the server's
   behaviour (README Part 7, decision 2, GAP-33) are used here as `standard` and `cobolcraft`; the world-types document
   should confirm or rename them, and confirm that the state `ok` is the only thing that makes `standard` available.
9. **README C10 and decision 2 against 22.** README says a missing or wrong jar disables the standard type; 22 section 8.2 and 8.6
   and its Open question 2 say a valid generated directory is enough. Section 8.1 follows 22. The operator settles it. The
   old question about asset tool facts is closed: states, keys, texts and the command line now come from 22 sections 8.2 and 9.2.
10. **Title screen layout.** The banner of section 8.4 is at the top. If the title screen has text or buttons there, move it.
11. **Standard server without data.** Closed by 22 section 8.6: the client joins anyway and the title banner explains.
    Still open: whether a pre-login notice is wanted.
12. **Dedicated server.** Closed by 22 sections 8.6 and 9.2: it prints the reason text and `cobolcraft-extract --jar <file>`
    and exits non-zero.
13. **Options screen texts.** The labels and value formats of the options of 13 section 7 (view distance, sensitivity, field of view, GUI
    scale, "Auto") are not in 08 section 10.8.6.
14. **Disabled and hovered label colours.** 12 section 5.9 says the disabled colour was not traced; `#A0A0A0` is a choice.
15. **Generated font definitions.** Closed by 08 section 10.10: both world types use `minecraft:default`, the generated pack's
    files replace the built-in four by path, and no `cobolcraft:default` exists (section 4.12).
16. **Tooltip frame offset.** The real frame offset inside the 9-pixel border (Decision UI-13) is not verifiable from the documents; a
    read of the real `tooltip/frame` metrics would.
17. **Existing screen layouts.** The positions of the title, name label, name field and game mode button on the Create New
    World screen, and of the world list rows, are not in a document; section 7.2 fixes them. If another document (spec
    data model section 13) has them, that one wins and the rows of the type control follow the game mode row.
18. **Banner focus and keyboard.** The tab order of the banner and the Create screen's extra button, and whether Enter on the
    banner activates it (the text of section 8.3 says Enter activates the first button of that screen only).
19. **Button borders.** 12 section 5.9 reports border 3 (disabled 1); the built-in art uses 2 (Decision UI-21). A read of the
    real `.mcmeta` values for the other widgets (text field, sliders, handles, scrollers) would confirm or replace the rest.
20. **Selectable or disabled standard choice.** 22 section 9.2 disables the standard choice on the world-creation screen; this
    document keeps it selectable and explains on Create (Decision UI-15, UI-16). README Part 4, C10 ("the game offers only the
    cobolcraft world type" without a valid jar) and README decision 2 ("a missing or wrong jar disables the standard type") say
    offered-only or disabled as well, so the conflict is three-sided: README and 22 say not offered or disabled, this document says
    offered and selectable. No world is created in any reading, so the outcome matches C10; only the wording "offers only" does not.
    The owner of 22, the README or the operator decides. (Open question 9 is a separate question: jar against generated directory.)
21. **Manifest of the 40 effect icons.** Section 4.10 lists the 40 names and gives three check values; a group manifest over all
    40 (as in section 9.2, key `mob_effect/<name>`) was not computed in this round, because no tool run was part of it. Whoever
    runs the recipes should add it.
22. **Status-effect HUD layout.** 12 section 5 has no layout for the status-effect icons (position, spacing, the use of the
    24 x 24 background, the 18 x 18 icon offset, the blink at the end of a duration). Searched: 12 section 5 and 14 section 7.5.
    The 18 x 18 icon centred in the 24 x 24 background is a working choice only.
