# Built-in UI art, fallback UI texts, world type selection and missing-data screens

Status: design, round RS29 (closes GAP-34 of [README.md](README.md) Part 5 for the art, the font, the fallback texts of the new screens and the text-colour rules; the options screen texts are supplied in section 6.2 by round OPT, which closes Open question 13). Written from documents only: no artifact was
opened and no repository code was read. Every pixel value in this document comes from a recipe, and every check value of
section 9 was produced by running that recipe with a script written from this document's own rules (the groups of sections
4.1 to 4.9, 4.11 and 4.12 when they were written; the 40 effect icons of section 4.10 in the fix pass of the same round, which
also reproduced the three values given earlier). If a rule and a check value ever disagree, the document is wrong and is
corrected first (as in standin-content section 1.5).

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
section 7) are supplied by section 6.2 (round OPT; Open question 13 is closed). **GAP-34 and README C11 also stay open for the standard language keys** that the
cobolcraft world type needs and that no generated pack supplies there: the bench title, the experience level number, chat,
command feedback and death messages (Open question 23). Until a
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

**Decision UI-21 (borders are chosen; the buttons follow 12 except the disabled one).** The border values of the table of section 5.3
are choices of this document, not read values, with one exception: tooltip border 9 (12 section 5.8, read). 12 section 5.9 reports
border 3 for `widget/button` and `widget/button_highlighted` and border 1 for `widget/button_disabled`; this document uses
border 3 for the first two (the read value) and 2 for the disabled button, and 1 for the text field (no value is documented for the text field, the sliders, the handles or
the scrollers). Reason for the disabled button only: with the built-in art (outline 1 plus bevel 1), a border of 1 would copy the highlight edge but not
the shadow edge at a width under 200 (the Create button is 120 x 20, a default button 150 x 20, 12 section 5.9), because the
untiled right and bottom parts would then start inside the bevel; border 2 is the smallest that keeps both edges. The normal and highlighted buttons keep the read 3, which draws
the same image for this art. The consequence for a pack that replaces only `widget/button.png`: a file's
`.mcmeta` companion comes from the **same pack as the file** (08 section 3.2 and 7.4; 22 E6 says the same for Faithful), so a
pack that ships the PNG alone does **not** inherit the built-in `.mcmeta`: the sprite then has no nine-slice and is stretched
over the whole button. A nine-slice replacement must ship its own `.mcmeta` (Faithful does) and then uses its own border, for
example the 3 of 12 section 5.9. The borders of this document apply only to the built-in files. Open question 19 lists the
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

**Decision UI-27 (where the empty-slot icons are drawn, and `container/slot`).** All values here are chosen: 12 sections 5.6 and
5.6a do not mention the icons. (a) An icon is drawn only while its slot holds no item, at the slot's item cell, i.e. its
top-left pixel at the slot position of 12 section 5.6a (the 16 x 16 icon covers the 16 x 16 cell; the 24 x 24 highlights at
slot - 4 are drawn around it, so the icon is under the highlight). (b) It is drawn over the slot well that the sheet carries (section 4.11) and under
any item, at full opacity, with no tint. (c) The mapping is: menu slots 5, 6, 7, 8 of the inventory menu (12 section 5.6a:
head, chest, legs, feet, at (8, 8), (8, 26), (8, 44), (8, 62)) draw `helmet`, `chestplate`, `leggings`, `boots` in that order;
menu slot 45, the off-hand at (77, 62), draws `shield`. No other slot, and no slot of the bench menu, has an icon. (d) The
sheets of section 4.11 already carry the slot wells, so no built-in screen draws `container/slot` (18 x 18); it is supplied
because 14 section 6.1 lists it and a pack that replaces the sheets may rely on it (a screen without a sheet would draw it at
(slot.x - 1, slot.y - 1); inferred, not used by any built-in screen). Reason: with the 16 x 16 cell origin, the icon and an item
occupy exactly the same pixels. Open question 5 covers the unread vanilla placement.

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
| `widget/button` | 200 x 20 | nine_slice border 3 | `Bevel(200, 20, BTN, 1, 1)` |
| `widget/button_highlighted` | 200 x 20 | nine_slice border 3 | `Bevel(200, 20, BTNH, 1, 1)` |
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
| `widget/button` | 200 x 20 | nine_slice 200x20, border 3 | 3996 | `f8dc9cafe0138e6a494f074d5ef924e0867541b8849232063dc1f051a84ecc50` |
| `widget/button_highlighted` | 200 x 20 | nine_slice 200x20, border 3 | 3996 | `f81a5a3524017f2939f9abdea23e02caebff15570a9d1e5294a56307acbffb0f` |
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
and carries no field art. **In the cobolcraft world type** the client draws, over the panel at the rectangles of 13 section 3.9
(except the two labels, whose rectangles are chosen here):

(In the standard world type the vanilla `recipe_book.png` of the generated pack may already hold the search-field art, or the
vanilla search box may draw its own sprite; no document says which, so this decision does not apply there and the client
draws the fields as 13 section 3.9 documents. Open question 4.)

| Part | Rectangle on the panel | Background | Text |
|---|---|---|---|
| Search box | (25, 13), 81 x 14 | `widget/text_field` (nine-slice, border 1, `#14141A` face, `#6B6B75` outline; `_highlighted` while focused) stretched to 81 x 14 | typed text `#FFFFFF` with shadow; hint `cobolcraft.screen.common.search_hint` in `#A0A0A0`; both on the dark field |
| Filter button | (110, 12), 26 x 16 | the sprite `recipe_book/filter_*` itself (section 4.7 table), which is the whole button | none (tooltip only) |
| Page label (position **chosen**; 13 section 3.9 gives the arrows at (38, 137) and (93, 137), 12 x 17 each, and that a "page/total" label exists, but no label position) | the rectangle between the arrows: x = 50 to 92 (43 wide), y = 141 (the arrows' vertical middle for 9-high text: 137 + (17 - 9) div 2); the text is centred in it: x = 50 + (43 - textWidth) div 2 | none (the PAR face) | `cobolcraft.screen.recipe_book.page` in `#404040`, no shadow |
| Toast text (text and position **chosen**; 13 gives neither) | left-aligned at (toastX + 8, toastY + 11) (9-high text centred in the 32-high sprite: 11 = (32 - 9) div 2 rounded down) | the sprite | `cobolcraft.screen.recipe_book.toast` ("New Recipe") in `#404040`, no shadow |

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
must state the virtual-file rule: until then 08 section 10.2 and this section disagree; Open question 7). All 40 icons have check
values (the table at the end of this section) and the group has a manifest (section 9.2, key `mob_effect/<name>`). The 18 x 18 size and the placement of the icon inside the
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

**Check values of all 40 effect icons** (18 x 18, stretch (none); all 324 pixels except the 4 corner pixels are non-transparent, 320 in all; the white count depends on the letter). The first three repeat the worked examples.

| Key | Base | Letter | SHA-256 of RGBA |
|---|---|---|---|
| `mob_effect/speed` | `#7EC35C` | S | `552ad8826f4fae713e5c29559a162ff98f7602013df4074a0c6c18b22b3f82bb` |
| `mob_effect/slowness` | `#D6B05E` | S | `2005e3a85da9f3b8cc2533c80c4a64d78f8a495369e990bb9d2882fbfb5895f0` |
| `mob_effect/haste` | `#8091DF` | H | `d6bb5cc9e4e25e49ab8944cd9b57f8c3204804c813857f66c732b1104cdebeb7` |
| `mob_effect/mining_fatigue` | `#A882D0` | M | `6d4d5130ddd4a7b88e32b6a88d9775113b1b48fb938072391f536df1029149e0` |
| `mob_effect/strength` | `#51CB79` | S | `e21758b698ab2cd8b4ef61f2ec8ef08feca00f8645222f3ad1c97e397b73d68e` |
| `mob_effect/instant_health` | `#A27C61` | I | `0c454d28618d6cbb8924d2cb074c70bfda895fba0fb473f2842e35ec935df31d` |
| `mob_effect/instant_damage` | `#964452` | I | `1fbfcd8022789807f0723f737caa8c3e3657a87b20e9369c5502e0c7cdcd867d` |
| `mob_effect/jump_boost` | `#AE4795` | J | `2c93b357ac06bcb17829ecfd0a378eb7480285c07434b26a18d7200d7d17462e` |
| `mob_effect/nausea` | `#7384D2` | N | `82712dc9f708f8f886da4ac0249af28d6a207b28a045e81e8670fa8f3a0ebf5a` |
| `mob_effect/regeneration` | `#5F79BE` | R | `5ab05e2a1c535c4268f425c0db67e32b13c0cae13b05085ff46ff5517fb46d0f` |
| `mob_effect/resistance` | `#815B40` | R | `c022830081ebfcd30bac4c366448e331d6996f55c08e2299134f07fcd02ccf7f` |
| `mob_effect/fire_resistance` | `#D7BC96` | F | `7c3495652c2bede28dc94211750d7eda8d2396de16fd072f47365b979cafc2b5` |
| `mob_effect/water_breathing` | `#C4A942` | W | `2c0ba29052916e71325c8f5bdb63a51a00e4280b74fe28e6e57d419b53dc2d77` |
| `mob_effect/invisibility` | `#D37852` | I | `b9a0ac186e70cf13ed7cdd705152ff2644b328f903bd05d636437f2c0e22e4d7` |
| `mob_effect/blindness` | `#77BC96` | B | `05a0f1121ced2cbdb011b183ad89656829ca43081666e3691607972c40e18f96` |
| `mob_effect/night_vision` | `#977C56` | N | `101255423fa4e69f890c65872a02dfe5a0e6cbd1e262582eda906b1c72a8b40e` |
| `mob_effect/hunger` | `#437C61` | H | `44f0acc890d7c579ee1fe06e3dca68de8a93abca8428e91fc3a5ab418135b0c3` |
| `mob_effect/weakness` | `#C0DA48` | W | `a81bf6805ffd962a63490081e962b55144a522784e27ebda5ca76b0ce56f01c2` |
| `mob_effect/poison` | `#90AA4F` | P | `84cc1926ae4ce98a2bb9fcc99a5fb28c9f1eb44679952b047f9276ea733ad139` |
| `mob_effect/wither` | `#91ABB9` | W | `383c8266747045d6a6d7df88fca9829c4ece9d06dc861b0892151eaeb7b1b873` |
| `mob_effect/health_boost` | `#CBD987` | H | `e9aaef0593fdb689ea4c64eff66048a225875f0a9ff3badb4e1b0cba6101be41` |
| `mob_effect/absorption` | `#63DD82` | A | `87c22ab4009fb0c08eba2edcfe2410b9efd0b9ee5293ebbc2d4e79b2d1cb5cc9` |
| `mob_effect/saturation` | `#DF599E` | S | `67fc29b60ead1d562ebae911d736b6575a3a4ce715413fbc7b187bc68e5afd68` |
| `mob_effect/glowing` | `#40519F` | G | `3c3844c165dfcc61165dfc7aac771cf0593cec877451070339155349b9c1a618` |
| `mob_effect/levitation` | `#934152` | L | `62a7a471c9bb3eb138824b8a59b51e3071f419444d652a74432c2a9a1db63acc` |
| `mob_effect/luck` | `#5C6A7B` | L | `262612046e7fc1710e337a4df858a35735776da7bf055370ce364c7949eba485` |
| `mob_effect/unluck` | `#B383D1` | U | `78dc0ebc3cda951268b25a306031f5f2ecccedf23536e3190b5c9d1b540a6853` |
| `mob_effect/slow_falling` | `#B15FD9` | S | `98aa747a84857e06d42e2f76e06eee5c39ed39dc4c4217c4b7b888641c58bb31` |
| `mob_effect/conduit_power` | `#CF68B6` | C | `e25947c17434204834697cb64d294859288fdd2812151ddaf66d7f7ec6002f37` |
| `mob_effect/dolphins_grace` | `#87D546` | D | `c2173bc9e76d1adae84533422923f54bdad7a2e0ba6bfb46de1735cd823a0b22` |
| `mob_effect/bad_omen` | `#4BD069` | B | `1062b82eabf6c85307d7a8cdfd9405fbd159a81195646eaace9c1e1fb032b739` |
| `mob_effect/hero_of_the_village` | `#5061AF` | H | `99c76968a8e6472609250f765dff6f07fc27600c1a972f80792a7905ddfd9fdc` |
| `mob_effect/darkness` | `#62DC8A` | D | `63ded7be1fab583c3807ae1666f3a8ada3f27f85c3cb4474fc100a67cb5a5ca8` |
| `mob_effect/trial_omen` | `#7DCBDC` | T | `b19b202fbfb368a99a936e60b3f0862d85f05aa966cf320e15816548f9731cbc` |
| `mob_effect/raid_omen` | `#5F44BE` | R | `84e7ca9fd5d6ba84a46402345943878084283c9398bcbf09b987b39cfc974f72` |
| `mob_effect/wind_charged` | `#5D6B7C` | W | `8c7acdc94c302c029ef5c9f4a07b4fcb41fecb6a9e55e1ae408c3a9366578f53` |
| `mob_effect/weaving` | `#DE4F5C` | W | `df891f1cda8137f8401e26adf0c9c552b6c8a1d0955cbc14ec4049780601dc65` |
| `mob_effect/oozing` | `#785DD7` | O | `aab4d42c82f18b7e27ac1a862d54950120cf4c97ae19ccedb1f00f7f789a38ae` |
| `mob_effect/infested` | `#D28091` | I | `4f6cbbda9d3124ecc2efb639ca966b2ece448603403621107e0aa9b2b1cf1051` |
| `mob_effect/breath_of_the_nautilus` | `#DDB765` | B | `9eb3ff72f17e1ec34e80d89808afdc4218da5d099465436b82880c65a74b6856` |

### 4.11 Sheets: inventory, crafting table and recipe book

The three sheets are 256 x 256 RGBA images read as whole images with the logical size 256 x 256 (14 section 6.2). Outside the screen's image area they stay transparent.
**Decision UI-10.** The built-in sheets are drawn at the logical size (no 2x), and the recipe book panel is at (0, 0) of its sheet. Reason: the built-in pack
needs no more resolution than the logical one, and a user pack at 512 x 512 works unchanged (14 section 6.2). The origin of
the recipe-book panel inside the vanilla sheet was read in round GUI as (1, 1) (section 4.13.4). The origin (rbX, rbY) is therefore a
**parameter of the client** (the point of the sheet where the client reads the 147 x 166 panel), not a constant of the recipe:
the recipe below pastes the panel at (rbX, rbY), with rbX = rbY = 0 for the built-in sheet and its check values; the client's read rule is in 4.13.8. The check values of the
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
| `recipe_book` (origin (0, 0); the vanilla sheet's is (1, 1), section 4.13.4, interim rule in 4.13.8) | 256 x 256 | stretch (none) | 24398 | `b5debe5d431df026cb369fa0d80d9696ccdfbe5cc71f5a21aa379662dbf7f841` |

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

### 4.13 Values read from the shipped client (US6 round, "GUI reader")

Source: the artifact already recorded in docs/protocol/README.md, `minecraft-26.3-client.jar` (version 26.3, SHA-256
`4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`); static reading (`javap`, `unzip`, PNG header and pixel
reads), with no execution. Everything below was read in this round. It replaces the "chosen" and "not read" values named in each
subsection; where it differs from a recipe of sections 4.1 to 4.9 the difference is listed in 4.13.8 and the recipe is not
changed by this round (no check value of section 9 changes). Class names are cited as references only. "Vanilla sprite" means the
file in the artifact; the built-in art stays original (Decision UI-3).

#### 4.13.1 Sprite sizes (vanilla PNG sizes; under `textures/gui/sprites/` except the `mob_effect` icons, which are under `textures/mob_effect/`)

| Sprite id | Vanilla size | Built-in size (this document) | Note |
|---|---|---|---|
| `hud/hotbar` | 182 x 22 | 182 x 22 | same |
| `hud/hotbar_selection` | 24 x 23 | 24 x 23 | same |
| `hud/hotbar_offhand_left`, `_right` | 29 x 24 | 29 x 24 | same |
| `hud/hotbar_attack_indicator_background`, `_progress` | 18 x 18 | 18 x 18 | read, closes the size part of Open question 1 |
| `hud/crosshair` | 15 x 15 | 15 x 15 | same |
| `hud/crosshair_attack_indicator_background`, `_progress` | **16 x 4** | 16 x 16 (chosen) | differs (4.13.8) |
| `hud/crosshair_attack_indicator_full` | 16 x 16 | 16 x 16 | same |
| `hud/effect_background`, `_ambient` | 24 x 24 | 24 x 24 | read, closes Open question 1 for them |
| `container/inventory/effect_background`, `_ambient` | 32 x 32, nine-slice border 4 | not supplied | the inventory-screen effect list; not in section 1 |
| `hud/experience_bar_background`, `_progress` | 182 x 5 | 182 x 5 | same |
| hearts (all variants), food, armour, air | 9 x 9 | 9 x 9 | same |
| `mob_effect/<name>` (under `textures/mob_effect/`, not `gui/sprites/`; atlas source of 08 section 10.2) | 18 x 18 (checked on `speed`; 40 files in the archive) | 18 x 18 | same; the 40 names are in section 4.10 |
| `container/slot` | 18 x 18 | see 4.4 | same |
| `container/slot_highlight_back`, `_front` | 24 x 24, nine-slice 24 x 24 border 4 | 24 x 24 | same size; vanilla has a nine-slice file, the built-in sprite has none (drawn 1:1) |
| `container/slot/<name>` (empty-slot icons) | 16 x 16 | see 4.4 | read |
| `widget/button`, `_highlighted`, `_disabled` | 200 x 20 | 200 x 20 | same |
| `widget/text_field`, `_highlighted` | 200 x 20 | 200 x 20 | same |
| `widget/slider`, `_highlighted` | 200 x 20 | 200 x 20 | same |
| `widget/slider_handle`, `_highlighted` | 8 x 20 | 8 x 20 | same |
| `widget/checkbox` (4 sprites) | **20 x 20** | 17 x 17 | drawn at 17 x 17 by the client (4.13.3), so the built-in 17 x 17 is consistent |
| `widget/scroller`, `widget/scroller_background` | 6 x 32 | 6 x 32 | same |
| `tooltip/background`, `tooltip/frame` | 100 x 100 | 100 x 100 | same |
| `popup/background` | **236 x 34**, nine-slice border 6 | 32 x 32, border 4 | no cobolcraft screen draws it (section 1); a free choice, not changed |
| `toast/recipe` | 160 x 32, no `.mcmeta` (stretch) | 160 x 32 | same |
| `recipe_book/button`, `_highlighted` | 20 x 18 | 20 x 18 | same |
| `recipe_book/tab`, `_selected` | **35 x 27** | 32 x 27 | the client draws the tab at 35 x 27 (4.13.4) |
| `recipe_book/slot_craftable`, `_many_craftable`, `_uncraftable`, `_many_uncraftable` | 25 x 25 | 25 x 25 | same |
| `recipe_book/page_forward`, `_backward` (and `_highlighted`) | 12 x 17 | 12 x 17 | same |
| `recipe_book/filter_*` (and `furnace_filter_*`) | 26 x 16 | 26 x 16 | same |
| `recipe_book/overlay_recipe` | 32 x 32, nine-slice border 4 | 32 x 32, border 4 | same |
| `recipe_book/crafting_overlay*` | **24 x 24** | 25 x 25 | differs; the overlay button's drawn size was not read (Open question 32) |

The artifact has 522 files under `textures/gui/sprites/` (`unzip -Z1 | grep -v '/$'`), 53 of them `.mcmeta`. Whole-image textures
`textures/gui/container/inventory.png`, `crafting_table.png`, `generic_54.png` and `textures/gui/recipe_book.png` are all 256 x 256.

#### 4.13.2 Nine-slice metadata (vanilla `.mcmeta`, every one of type `nine_slice`; 47 of the 53 files; the other 6 are animations)

The vanilla values for the widgets this document supplies (the built-in values stay those of section 5.3 and Decision UI-21;
a pack above the built-in pack brings its own):

| Sprite id | Width x height | Border | Note |
|---|---|---|---|
| `widget/button`, `_highlighted` | 200 x 20 | 3 | as 12 section 5.9 |
| `widget/button_disabled` | 200 x 20 | 1 | as 12 section 5.9 |
| `widget/text_field`, `_highlighted` | 200 x 20 | 1 | read (closes Open question 19 for the field) |
| `widget/slider`, `_highlighted` | 200 x 20 | 1 | built-in uses 2 |
| `widget/slider_handle`, `_highlighted` | 8 x 20 | left 2, top 2, right 2, **bottom 3** | per-side object; built-in uses 2 uniform |
| `widget/scroller`, `widget/scroller_background` | 6 x 32 | 1 | built-in `scroller` uses 2 |
| `tooltip/background` | 100 x 100 | 9 | as 12 section 5.8 |
| `tooltip/frame` | 100 x 100 | **10**, `stretch_inner` **true** | built-in uses 9 and no `stretch_inner` |
| `popup/background` | 236 x 34 | 6 | |
| `recipe_book/overlay_recipe` | 32 x 32 | 4 | |
| `container/slot_highlight_back`, `_front` | 24 x 24 | 4 | |
| `container/inventory/effect_background`, `_ambient` | 32 x 32 | 4 | |
| `widget/tab`, `_selected`, `_highlighted`, `_selected_highlighted` | 130 x 24 | left 2, top 2, right 2, bottom 0 | the tab bar of the options and world screens; not supplied here |
| `toast/tutorial`, `toast/now_playing` | 160 x 32 | 3 and 4 | other toasts; not supplied |
| `toast/system` | 160 x 64 | left 17, top 30, right 4, bottom 4 | not supplied |
| `hud/locator_bar_background` | 12 x 5 | left 5, right 5, top 1, bottom 1 | not supplied |

Consequences for the client: the nine-slice reader must accept both the single-integer and the four-side object forms of `border`
and the Boolean `stretch_inner` (08 section 7.3 already lists them; this round confirms all three occur in the artifact). The
vanilla checkbox and recipe-book sprites other than `overlay_recipe` carry no `.mcmeta` (stretch).

#### 4.13.3 Widget geometry and colours (closes the widget part of Open questions 14 and 19)

| Widget | Read value |
|---|---|
| Button | default size 150 x 20; the constants of the builder are 120 (small), 150 (default), 200 (big), height 20, spacing 8. The sprite is drawn at the widget rectangle (nine-slice scaled); the label is a scrolling string over the rectangle with a 2-pixel margin each side, centred. Pressed, disabled and hovered or focused choose `button_disabled`, `button_highlighted`, `button`; the highlighted sprite shows for hover or keyboard focus. |
| Text field (`EditBox`) | default size 150 x 20; the sprite is drawn at the widget rectangle (`text_field`, `_highlighted` while focused). Text colours: enabled `#E0E0E0` (constant `DEFAULT_TEXT_COLOR`), disabled `#707070`, hint `#808080`. The recipe-book search box sets its text colour to white (`#FFFFFF`) and is 81 x 14 at (25, 13) of the panel with a maximum length of 50 characters (4.13.4). |
| Slider | default height 20; handle 8 wide (half 4); the track is `slider` or `slider_highlighted`, the handle is `slider_handle` or `_highlighted`, drawn at the widget's own height; text margin 2. |
| Checkbox | box size = the font's line height + 8 = 17 for the 9-pixel font (the vanilla sprite is 20 x 20 and is drawn scaled to 17 x 17); spacing between box and label 4 (read constants `BOX_PADDING` 8, `SPACING` 4). The four sprites are `checkbox`, `_highlighted`, `_selected`, `_selected_highlighted`. |
| Scroll bar | width 6, minimum knob height 32 (the knob sprite is `scroller`, the track `scroller_background`). |
| Container labels | colour `#404040`, no shadow (read: integer -12566464); the slot hover overlay colour is white at 50 % (`0x80FFFFFF`, ARGB integer -2130706433). Inventory title at label x 97, crafting-table title at label x 29 (read). |
| Named colour constants (`CommonColors`) | WHITE `#FFFFFF`, BLACK `#000000`, GRAY `#808080`, DARK_GRAY `#404040`, LIGHT_GRAY `#A0A0A0`, LIGHTER_GRAY `#BABABA`, RED `#FF0000`, SOFT_RED `#DF5050`, GREEN `#00FF00`, BLUE `#0000FF`, YELLOW `#FFFF00`, SOFT_YELLOW `#FFFF55`, DARK_PURPLE `#500050`, HIGH_CONTRAST_DIAMOND `#57FFE1`, COSMOS_PINK `#FFCCCC`, TEXT_GRAY `#E0E0E0` (all with alpha `FF`; read as signed 32-bit constants and converted) |

The colour a disabled button label is drawn in was not found: the label is drawn through the widget's text collector, whose
parameters carry only a pose, an opacity (the widget's alpha) and a scissor, and the label's colour comes from the component's
style (white when none is given). Where the greying of a disabled label happens was not traced (Open question 33); the
choice of Decision UI-12 (`#A0A0A0`, which equals `LIGHT_GRAY`) stays. `#A0A0A0` and `#404040` are both vanilla named constants,
which supports the chosen secondary and label colours; `#FFC857` (warning) has no counterpart and remains a choice.

#### 4.13.4 Recipe book: panel, tabs, grid, toast (closes Open questions 2, 4 and 30 for the standard layout)

Panel (class `RecipeBookComponent`):

| Item | Read value |
|---|---|
| Panel size | 147 x 166, blitted from `recipe_book.png` with the source origin **(1, 1)** (not (0, 0)) of the 256 x 256 texture |
| Panel origin | x = (screen width - 147) div 2 - xOffset; y = (screen height - 166) div 2. xOffset is 86, or 0 when the screen is "too narrow" |
| Too narrow | GUI width < 379 (class `AbstractRecipeBookScreen`) |
| Screen image left edge while the book is open and not too narrow | 177 + (GUI width - image width - 200) div 2; otherwise (GUI width - image width) div 2. Image size of inventory and crafting table: 176 x 166, blitted from (0, 0) of a 256 x 256 sheet (closes the region part of Open question 2) |
| Book button | 20 x 18; inventory at (left + 104, GUI height div 2 - 22); crafting table at (left + 5, GUI height div 2 - 49) |
| Search box | (panel + 25, panel + 13), 81 x 14, hint `gui.recipebook.search_hint` ("Search..."), text white |
| Filter button | (panel + 110, panel + 12), 26 x 16 |
| Tabs | each 35 x 27; x = panel x - 30, y = panel y + 3 + 27 x n (n counts the visible tabs in order, the Search tab always visible); the selected tab is drawn 2 pixels further left (x - 2) |
| Tab icon | one item at (tabX + 9, tabY + 5) (+ x offset -2 when selected); a tab with two icons draws the first at tabX + 3 and the second at tabX + 14 (same y) |
| Result grid | 5 columns, 20 results per page; cell (i) at (panel + 11 + 25 x (i mod 5), panel + 31 + 25 x (i div 5)); cells are 25 x 25 |
| Page arrows | forward at (panel + 93, panel + 137), backward at (panel + 38, panel + 137), each 12 x 17; tooltips `gui.recipebook.next_page`, `gui.recipebook.previous_page` |
| Page label | shown only when there is more than one page; text `gui.recipebook.page` ("%s/%s", current page from 1, total); centred on x = panel + 73, top y = panel + 141; colour white (integer -1) |

Texts read from the vanilla language file: `gui.recipebook.search_hint` = "Search...", `gui.recipebook.page` = "%s/%s",
`gui.recipebook.next_page` = "Next Page", `gui.recipebook.previous_page` = "Previous Page", `itemGroup.search` = "Search Items".

Toast (class `RecipeToast`): sprite `toast/recipe` drawn at the toast's origin over its full size (160 x 32); title `recipe.toast.title`
("New Recipe(s) Unlocked!") at (30, 7) in colour `#500050` (DARK_PURPLE) with no shadow; description `recipe.toast.description` ("Check your
recipe book") at (30, 18) in black `#000000`, no shadow; the category item at (3, 3) scaled to 0.6 and the unlocked item at (8, 8);
display time 5000 ms (the item changes over time when several recipes arrive).

For the cobolcraft world type (Decisions UI-22, UI-23): use the read geometry above where it is not a design choice. Specifically
(**Decision UI-28**): the tab rectangle is 35 x 27 and the built-in 32 x 27 sprite is stretched over it; the tab letter of Decision UI-22 is
centred in 35 pixels, x = tabX + (35 - a) div 2, y = tabY + 9 (unchanged), minus 2 on x when selected, as the item would be; the
page label is centred on panel x + 73 at y + 141 (replacing the chosen 50 to 92 box of Decision UI-23; the arrows' mid-point 71.5
is not where the vanilla label is); the toast title is at (toastX + 30, toastY + 7) and the description at (toastX + 30, toastY + 18) with
the new colours; texts "New Recipe(s) Unlocked!" and "Check your recipe book" replace `cobolcraft.screen.recipe_book.toast`
("New Recipe", chosen) for the standard keys, and the cobolcraft keys keep whatever English the built-in `lang` gives (state the same
wording there). The label colour on the real panel is white because the real `recipe_book.png` panel is dark; on the built-in
parchment panel the dark-text rule of section 6 still applies (the vanilla panel's face colours were not sampled). Reason: the
positions are read values and the contrast rule is why the colour stays the built-in one.

#### 4.13.5 Tooltip layout and frame

Read from `TooltipRenderUtil`: the tooltip box is the text block grown by 3 pixels of padding on every side (constants
`PADDING_LEFT/RIGHT/TOP/BOTTOM` 3) and then by the sprite margin 9 on every side; so both sprites are drawn at (textX - 12, textY - 12)
with size (textWidth + 24, textHeight + 24). The mouse offset is 12 (`MOUSE_OFFSET`). Both sprites are drawn with the same rectangle,
background first, frame over it. Two sprite ids per tooltip (the defaults `tooltip/background`, `tooltip/frame`) can be replaced by a
per-item style id; the replacement path is the same name with the item's namespace and path.

Vanilla `tooltip/background`: the opaque area is pixels 8 to 91 on both axes (84 x 84), every pixel `#100010` at alpha 240 (94 %),
with the four corner pixels (8, 8), (91, 8), (8, 91), (91, 91) transparent (7052 opaque pixels). Vanilla `tooltip/frame`: a
one-pixel ring at pixels 9 to 90 (320 opaque pixels, corners (9, 9) and the other three transparent, so each side runs from 10 to 89),
alpha 80 (31 %), a vertical gradient from `#5000FF` at the top edge to `#28007F` at the bottom edge (the side columns go through the
intermediate values), and everything inside the ring transparent. The border is 10 with `stretch_inner`, so the ring stays one
pixel wide and straight when the middle is stretched. Frame position: the ring lies at sprite pixel 9, which is 3 pixels outside the
text, i.e. exactly at the padding edge (rectangle edge 12 minus 9). **Decision UI-13 is confirmed in effect, not in number**: the
built-in frame at pixels 7 and 8 (outer edge 5 from the text, inner edge 3) is 1 to 2 pixels further out than the vanilla ring; this is
accepted, because a pack above the built-in pack brings its own frame and `.mcmeta`. Closes Open question 16.

#### 4.13.6 Window size and GUI scale (closes Open question 29's window part)

| Rule | Read value |
|---|---|
| Minimum window size | 320 x 240 window units, set as the window manager's minimum (`SDL_SetWindowMinimumSize`) and also as the floor of the requested start size |
| GUI scale option | 0 means Auto; 1 up to a maximum that is the Auto result for the current window; the option is clamped into [0, that maximum] when set; displayed as "Auto" (`options.guiScale.auto`) for 0 and as the decimal number otherwise; the caption key is `options.guiScale` ("GUI Scale") |
| Scale applied | start with 1; while the scale is not the requested value (the requested value 0 never matches) and the scale is below both framebuffer sizes and (framebuffer width div (scale + 1)) >= 320 and (framebuffer height div (scale + 1)) >= 240: add 1. If the "force unicode font" option is on and the result is odd, add 1. This is evaluated on every window resize with the stored option value, so a manual scale larger than fits is lowered to the fitting one without changing the stored option |
| GUI size | width = ceil(framebuffer width / scale), height = ceil(framebuffer height / scale) |

Worked examples (framebuffer size, requested scale, force-unicode flag, result; computed by following the rule above):
1920 x 1080 Auto: 4, GUI 480 x 270 (1080 div 5 = 216 < 240 stops at 4); 854 x 480 Auto: 2, GUI 427 x 240; 640 x 480 Auto: 2, GUI 320 x 240;
960 x 540 Auto: 2, GUI 480 x 270; 1280 x 720 Auto: 3, GUI 427 x 240 (ceil(1280/3) = 427) and with force-unicode on 4, GUI 320 x 180;
320 x 240 Auto: 1, GUI 320 x 240, and with force-unicode on 2, GUI 160 x 120; 1920 x 1080 manual 3: 3, GUI 640 x 360 (with
force-unicode on: 4); 1920 x 1080 manual 9: 4 (lowered to fit). Force-unicode is the option that makes the font
draw the Unicode providers; the cobolcraft client has no such option, so the flag is off and the odd-to-even step never applies
(inferred from the content list; the standard world type never needs it for the built-in font).

Consequence for layouts: with the flag off the smallest GUI an Auto or a manual scale gives, on a framebuffer of at least 320 x 240
pixels, has width >= 320 and height >= 240 (every step to a larger scale is refused below that), so the layouts of section 7.2 may
assume 320 x 240 as the minimum GUI size. A window smaller than 320 x 240 can only occur where the window manager ignores the minimum-size
hint; it then runs at scale 1 and the GUI is smaller (inferred: no other clamp was found). Open question 29 keeps that case.

#### 4.13.7 Contrast values

Recomputed in this round (WCAG relative luminance, sRGB, ratio (L1 + 0.05) / (L2 + 0.05)); they replace the unchecked values of section 6
where they differ:

| Pair | Ratio |
|---|---|
| `#A0A0A0` on `#1E1E26` (menu tile) / `#101016` / `#3A3F45` (disabled button) | 6.33 / 7.25 / 4.06 |
| `#FFC857` on `#1E1E26` / `#101016` / `#3A3F45` | 10.76 / 12.32 / 6.91 |
| `#FFFFFF` on `#3A3F45` | 10.62 |
| `#404040` on `#D8D0B4` / `#A39A7A` | 6.72 / 3.68 |
| `#1A1A1A` on `#A39A7A` | 6.18 |
| `#FFFFFF` on `#D8D0B4` / `#A39A7A` | 1.54 / 2.81 |

These agree with the figures of section 6 (6.3 to 7.2, 4.1, 10.8, 12.3, 6.9, 10.6, 6.7, 3.7, 6.2, 1.54, 2.8); the values were computed
by script from the section 2.1 colours, not read from the artifact. Pairs below 4.5: `#404040` on the tab face `#A39A7A`
(3.68; why tab letters use `#1A1A1A`), `#A0A0A0` on the disabled button face (4.06, above the large-text threshold of 3), and the two white-on-parchment pairs (1.54, 2.81), which are never drawn (section 6). The
shadow colour `#3F3F3F` stays an assumption: the shadow rule was not re-read in this round (Open question 31).

#### 4.13.8 Differences between this document's recipes and the read values

Recipes and check values are unchanged by this round. The client must follow the rule in the right column; an implementer who
wants the built-in art to match the vanilla sizes must change the recipe and recompute section 9 in the same edit.

| Sprite | Built-in | Read | Rule for the client |
|---|---|---|---|
| `hud/crosshair_attack_indicator_background`, `_progress` | 16 x 16 | 16 x 4 | **Interim choice (Open questions 3 and 32):** for the built-in 16 x 16 sprites draw the source sub-rectangle rows 6 to 9 (the 16 x 4 band that holds the bar, section 4.1: background `R(0, 6, 15, 9)`, progress rows 7 and 8 inside it) 1:1 at a 16 x 4 destination (never squash the 16 rows to 4); a vanilla-style sprite that is already 16 x 4 is stretched to the destination, which is the same size. Horizontally centred on the crosshair centre (x = GUI width div 2 - 8) at y = GUI height div 2 - 7 + 16 (inferred position, not read); `_progress` is clipped from the left to 16 x cooldown fraction pixels wide, not scaled (the clipping direction is inferred, Open question 3). A recipe change to 16 x 4 would retire this rule. |
| `recipe_book/tab`, `_selected` | 32 x 27 | 35 x 27 | draw at 35 x 27 (4.13.4) |
| `recipe_book/crafting_overlay*` | 25 x 25 | 24 x 24 | **Interim choice (Open question 32):** draw at 25 x 25 (the built-in size, 1:1) in the 25-pixel cell of the overlay; the vanilla 24 x 24 draw size is not adopted because the overlay layout was not read |
| `recipe_book` sheet panel origin | (0, 0) (4.11, Decision UI-10) | (1, 1) in the vanilla sheet | **Rule:** the client blits the 147 x 166 panel from a source origin that depends on where `textures/gui/recipe_book.png` resolves: (1, 1) when a pack above the built-in pack supplies it (vanilla and user layouts), (0, 0) when the built-in file is used. The destination origin is unchanged (4.13.4). The origin is in logical sheet units and is multiplied by the sheet's resolution factor for a higher-resolution sheet (inferred for user layouts such as a 512 x 512 sheet: 1 logical unit = 2 pixels). The client learns which file resolved from the pack-stack lookup result (the pack that supplied the file, 08 section 3). Moving the built-in panel to (1, 1) is **optional**; the rule above stands until it is done, and then the origin collapses to (1, 1) and the `recipe_book` check value and the Sheets manifest of section 9.2 are recomputed (rbX = rbY = 1). Not done in this round. |
| `widget/slider`, `_highlighted` | border 2 | border 1 | none (built-in only) |
| `widget/slider_handle*` | border 2 | 2, 2, 2, 3 | none |
| `widget/scroller` | border 2 | border 1 | none |
| `tooltip/frame` | border 9, frame at 7 and 8 | border 10, `stretch_inner`, ring at 9 | none (4.13.5) |

New Open questions 32 and 33 are in section 12.



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
| `widget/button`, `widget/button_highlighted` | 200 | 20 | 3 |
| `widget/button_disabled` | 200 | 20 | 2 |
| `widget/text_field`, `widget/text_field_highlighted` | 200 | 20 | 1 |
| `widget/slider`, `widget/slider_highlighted` | 200 | 20 | 2 |
| `widget/slider_handle`, `widget/slider_handle_highlighted` | 8 | 20 | 2 |
| `widget/scroller` | 6 | 32 | 2 |
| `widget/scroller_background` | 6 | 32 | 1 |
| `tooltip/background`, `tooltip/frame` | 100 | 100 | 9 |
| `popup/background`, `recipe_book/overlay_recipe` | 32 | 32 | 4 |

Rule for the writer of each: a user pack that replaces one of these PNG files must ship its own `.mcmeta` too (Decision UI-21), otherwise
the sprite is stretched. The border B must leave a non-empty centre in both directions (08 section 7.4): the smallest case is
`widget/scroller`, 6 wide with B = 2, whose centre is 2 pixels wide (the 8-pixel handle with B = 2 has a centre of 4, and
`widget/scroller_background`, 6 wide with B = 1, also has 4); 2 is non-empty, so the rule holds for every row of the table. The border values other than the tooltip's are chosen (Decision UI-21); the two enabled buttons use the read 3 of 12 section 5.9,
and the disabled button uses 2 where 12 reads 1.

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
| 08 section 10.8.6 | `cobolcraft.hud.health` ("Health %s/%s"), `cobolcraft.hud.food` and `cobolcraft.hud.crosshair` ("+"): a text health and food line and a text crosshair | retired: the HUD draws hearts, food and the crosshair as sprites (sections 4.1 to 4.3); the three keys draw nothing (Open question 25) |
| 08 section 10.8.6 | the `cobolcraft.screen.crafting.*` keys of feature 001's crafting screen | retired with that screen (README R6: crafting is the inventory 2x2 grid and the bench 3x3 grid, whose sheets are in section 4.11) |

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
| `cobolcraft.ui.missing_data.fix_force` | none | Command: cobolcraft-extract --jar <file> --force, then restart the game. |
| `cobolcraft.ui.missing_data.banner` | none | Game data missing. Click for details. |
| `cobolcraft.screen.create_world.seed` | none | Seed (optional) |
| `cobolcraft.screen.create_world.seed_hint` | none | Leave empty for a random seed |
| `cobolcraft.world_type.auto_fallback` (world-types.md 3.5) | result word | world-type=auto: Minecraft content is not usable (%s), created a cobolcraft world |
| `cobolcraft.world_type.unknown.short` | world type value | Unknown world type '%s' |
| `cobolcraft.world_type.unknown` (world-types.md 3.5; console) | world type value | This world was made by a newer version of the game (world type '%s'). |
| `cobolcraft.world_type.missing` (world-types.md 3.5) | none | This world has no world type and cannot be opened. |
| `cobolcraft.world_type.no_level` (world-types.md 3.5) | none | This folder holds world data but no level.dat. |
| `cobolcraft.world_type.no_seed` (world-types.md 3.5) | none | This world has no seed and cannot be opened. |
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

The `world_type.*` keys other than `standard`, `cobolcraft` and their descriptions are the keys world-types.md 3.5 asks this
document to place in the built-in pack; the texts are those of world-types.md 3.5 and 2.1 (`%s` replaces `<result>` or
`<value>`). The `config_ignored` and `config_invalid` texts of that table are console lines of the server only and are not
language keys of the client. world-types.md says `standard.unavailable` is used by the Create screen and the world list;
this document does not draw it there (the screens use the `short` keys), and the claim should be dropped from world-types.md
(Open question 25).

The search hint, filter, page, tab and pack-folder texts are the English words of 13 section 3.9 and 13 section 8 as those
documents word them (checked against 13 section 3.9 for the search hint, the filter tooltips and "Right Click for More", and against 13 section 8 for "Open Pack Folder", "(Place pack files here)" and "Drag and drop files into this window to add packs"; the five tab names are in 13 section 3.9; the page label format `%s/%s` and the toast text are chosen); they are listed here only because the sprites of sections 4.5 to 4.7 are
drawn for them. The exception is the **toast text** `cobolcraft.screen.recipe_book.toast` ("New Recipe"), which 13 does not
give: it is chosen here (Decision UI-23), as is the position of the page label (13 gives the arrows and the existence of the label only). The existing `cobolcraft.screen.*` keys of 08 section
10.8.6 are unchanged and are reused (for example `cobolcraft.screen.common.back`, `cobolcraft.screen.create_world.create`).
The options screen texts are supplied in section 6.2 (Open question 13 is closed).

### 6.2 Options screen texts (round OPT)

Source: the vanilla client jar `minecraft-26.3-client.jar` (the artifact already recorded in docs/protocol/README.md; SHA-256
`4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`), file `assets/minecraft/lang/en_us.json` (8559 keys), read statically in a clean-room
round together with the option and screen classes. The Faithful 32x pack has no `lang` directory, so it changes none of these texts. **Every value in the tables
below is read, none is chosen.** The behaviour behind them (option names, defaults, ranges, persisted keys, stored forms, label formats, screen order) is in
13 section 7.2 and sections 7.4 to 7.6, which this section is the text companion of. This closes Open question 13 and the options-screen part of GAP-34.

**Decision UI-29 (keys of the options screens).** The options screens use the **standard key names** exactly as the artifact has them (`options.*`,
`controls.*`, `key.*`, `soundCategory.*`, `narrator.*`), not `cobolcraft.` keys. Reason: these are the keys a generated pack's language file also defines
with the same values (so the generated file can replace the built-in text by the lookup rule of 08 section 10.8 with no visible change), the key tables of
13 are written in them, and mapping about 430 keys to a second namespace would add a table with no gain; the collision concern of Decision UI-14 (a client-only key being
overridden by accident) does not arise because the standard values are the same. The built-in `lang/en_us.json` (08 section 10.8.6) therefore carries every row of the tables of this section
plus the `key.keyboard.*` and `key.mouse.*` rows of 13 section 7.5. Texts use Java-style placeholders: `%s` in order, `%1$s` positional, and `%%` for a literal percent
sign (for example `Language translations may not be 100%% accurate.` is shown with one `%`). A literal `\n` in a value is a line break. The only non-ASCII value in the keys of this section is in 13 section 7.5 (`Keypad ±`, the plus-minus sign); Decision UI-11 (ASCII built-in texts) means the
built-in file draws it as `+-` unless the font has the glyph (a choice, Open question 35).

Rows are grouped by screen. The captions are formatted by the rules of 13 section 7.4 (`%s: %s`, percent, pixels, ON/OFF, special values). Enum values and
tooltips are shown with the option; keys that appear in two groups are listed once.

**Generic value formats and common words**

| Key | Text |
|---|---|
| `options.generic_value` | %s: %s |
| `options.percent_value` | %s: %s%% |
| `options.pixel_value` | %s: %spx |
| `options.value` | %s |
| `options.on` | ON |
| `options.off` | OFF |
| `options.on.composed` | %s: ON |
| `options.off.composed` | %s: OFF |
| `options.multiplier` | %sx |
| `options.framerate` | %s fps |
| `options.blocks` | %s Blocks |
| `options.chunks` | %s Chunks |
| `options.hidden` | Hidden |
| `options.visible` | Shown |
| `gui.done` | Done |
| `gui.back` | Back |
| `gui.cancel` | Cancel |
| `gui.yes` | Yes |
| `gui.no` | No |
| `gui.none` | None |
| `gui.up` | Up |
| `gui.down` | Down |
| `options.needsRestart` | Requires a game restart to take effect. |
| `options.restartRequired` | Some of your changes require a game restart to be applied. |

**Options screen (OptionsScreen)**

| Key | Text |
|---|---|
| `options.title` | Options |
| `options.fov` | FOV |
| `options.fov.min` | Normal |
| `options.fov.max` | Quake Pro |
| `options.skinCustomisation` | Skin Customization... |
| `options.sounds` | Music & Sounds... |
| `options.video` | Video Settings... |
| `options.controls` | Controls... |
| `options.language` | Language... |
| `options.chat` | Chat Settings... |
| `options.resourcepack` | Resource Packs... |
| `options.accessibility` | Accessibility Settings... |
| `resourcePack.title` | Select Resource Packs |
| `menu.options` | Options... |

**Video Settings screen**

| Key | Text |
|---|---|
| `options.videoTitle` | Video Settings |
| `options.video.display.header` | Display |
| `options.video.interface.header` | Interface |
| `options.video.preferences.header` | Preferences |
| `options.video.quality.header` | Quality & Performance |
| `options.graphics` | Graphics |
| `options.graphics.preset` | Preset |
| `options.graphics.preset.tooltip` | Sets "Quality & Performance" settings to reasonable defaults corresponding to the desired quality. |
| `options.graphics.fast` | Fast |
| `options.graphics.fast.tooltip` | Fast graphics reduces the amount of visible rain and snow.\nTransparency effects are disabled for various blocks such as leaves. |
| `options.graphics.fancy` | Fancy |
| `options.graphics.fancy.tooltip` | Fancy graphics balances performance and quality for the majority of machines.\nWeather, clouds, and particles may not appear behind translucent blocks or water. |
| `options.graphics.fabulous` | Fabulous! |
| `options.graphics.fabulous.tooltip` | %s graphics uses screen shaders for drawing weather, clouds, and particles behind translucent blocks and water.\nThis may severely impact performance for portable devices and 4K displays. |
| `options.graphics.custom` | Custom |
| `options.graphicsApi` | Graphics API |
| `options.graphicsApi.default` | Default |
| `options.graphicsApi.opengl` | Prefer OpenGL |
| `options.graphicsApi.restart` | You must restart your game to change the graphics API. |
| `options.graphicsApi.tooltip` | Which graphics API to use for rendering. Leave as Default unless you have a specific need to change this! |
| `options.graphicsApi.tooltip.vulkan` | Experimental. Might reduce performance or cause instability on some systems. |
| `options.graphicsApi.vulkan` | Prefer Vulkan (Experimental) |
| `options.framerateLimit` | Max Framerate |
| `options.framerateLimit.max` | Unlimited |
| `options.vsync` | VSync |
| `options.inactivityFpsLimit` | Reduce fps when |
| `options.inactivityFpsLimit.afk` | AFK |
| `options.inactivityFpsLimit.afk.tooltip` | Limits framerate to 30 when the game is not getting any player input for more than a minute. Further limits it to 10 after 9 more minutes. |
| `options.inactivityFpsLimit.minimized` | Minimized |
| `options.inactivityFpsLimit.minimized.tooltip` | Limits framerate only when the game window is minimized. |
| `options.debugGuiScale.tooltip` | Overrides the debug overlay with a different GUI scale than the rest of the game |
| `options.debugGuiScale.unchanged` | Unchanged |
| `options.guiScale` | GUI Scale |
| `options.guiScale.auto` | Auto |
| `options.exclusiveFullscreen` | Exclusive Fullscreen |
| `options.exclusiveFullscreen.off.tooltip` | All input methods are expected to work in this fullscreen mode, but adaptive sync (Nvidia G-Sync, AMD FreeSync) will not work. |
| `options.exclusiveFullscreen.on.tooltip` | This fullscreen mode might prevent some input methods from working, but adaptive sync (Nvidia G-Sync, AMD FreeSync) should work. |
| `options.exclusiveFullscreen.warningTooltip` | This option might prevent some input methods from working. |
| `options.fullscreen` | Fullscreen |
| `options.fullscreen.current` | Current |
| `options.fullscreen.entry` | %sx%s@%s (%sbit) |
| `options.fullscreen.exclusive.mode` | Exclusive Fullscreen Mode |
| `options.fullscreen.exclusive.mode.tooltip` | This setting only takes effect when Exclusive Fullscreen is enabled. |
| `options.fullscreen.resolution` | Fullscreen Resolution |
| `options.fullscreen.unavailable` | Setting unavailable |
| `options.macFullscreenMenuVisibility` | Menu/Dock Visibility |
| `options.macFullscreenMenuVisibility.tooltip` | Whether the macOS Menu bar and Dock can be revealed by moving the mouse to the edge of the screen while in non-exclusive fullscreen. |
| `options.gamma` | Brightness |
| `options.gamma.default` | Default |
| `options.gamma.max` | Bright |
| `options.gamma.min` | Moody |
| `options.ao` | Smooth Lighting |
| `options.ao.max` | Maximum |
| `options.ao.min` | Minimum |
| `options.ao.off` | OFF |
| `options.biomeBlendRadius` | Biome Blend |
| `options.biomeBlendRadius.1` | OFF (Fastest) |
| `options.biomeBlendRadius.3` | 3x3 (Fast) |
| `options.biomeBlendRadius.5` | 5x5 (Normal) |
| `options.biomeBlendRadius.7` | 7x7 (High) |
| `options.biomeBlendRadius.9` | 9x9 (Very High) |
| `options.biomeBlendRadius.11` | 11x11 (Extreme) |
| `options.biomeBlendRadius.13` | 13x13 (Showoff) |
| `options.biomeBlendRadius.15` | 15x15 (Maximum) |
| `options.prioritizeChunkUpdates` | Chunk Builder |
| `options.prioritizeChunkUpdates.byPlayer` | Semi Blocking |
| `options.prioritizeChunkUpdates.byPlayer.tooltip` | Some actions within a chunk will recompile the chunk immediately. This includes block placing and destroying. |
| `options.prioritizeChunkUpdates.nearby` | Fully Blocking |
| `options.prioritizeChunkUpdates.nearby.tooltip` | Nearby chunks are always compiled immediately. This may impact game performance when blocks are placed or destroyed. |
| `options.prioritizeChunkUpdates.none` | Threaded |
| `options.prioritizeChunkUpdates.none.tooltip` | Nearby chunks are compiled in parallel threads. This may result in brief visual holes when blocks are destroyed. |
| `options.renderDistance` | Render Distance |
| `options.simulationDistance` | Simulation Distance |
| `options.renderClouds` | Clouds |
| `options.clouds.fast` | Fast |
| `options.clouds.fancy` | Fancy |
| `options.renderCloudsDistance` | Cloud Distance |
| `options.attack.crosshair` | Crosshair |
| `options.attack.hotbar` | Hotbar |
| `options.attackIndicator` | Attack Indicator |
| `options.autosaveIndicator` | Autosave Indicator |
| `options.chunkFade` | Chunk Fade Time |
| `options.chunkFade.none` | Chunk Fade: None |
| `options.chunkFade.seconds` | Chunk Fade: %s second(s) |
| `options.chunkFade.tooltip` | How long in seconds chunks should fade in when they're first rendered, if at all. |
| `options.cutoutLeaves` | See-Through Leaves |
| `options.cutoutLeaves.tooltip` | Allows you to see through gaps in leaves. Disabling improves performance. |
| `options.entityDistanceScaling` | Entity Distance |
| `options.entityShadows` | Entity Shadows |
| `options.improvedTransparency` | Improved Transparency |
| `options.improvedTransparency.oit.tooltip` | An experimental approach that uses an order-independent transparency algorithm to avoid graphical issues normally present when looking through multiple layers of translucent objects.\nThis will impact performance. |
| `options.improvedTransparency.tooltip` | An experimental approach that uses screen shaders for drawing weather, clouds, and particles behind translucent blocks and water.\nThis will impact GPU performance. |
| `options.maxAnisotropy` | Anisotropic Filtering |
| `options.maxAnisotropy.tooltip` | Each level significantly improves how smooth textures look, but impacts performance and significantly impacts video memory usage. Requires Texture Filtering to be set to Anisotropic. |
| `options.mipmapLevels` | Mipmap Levels |
| `options.particles` | Particles |
| `options.particles.all` | All |
| `options.particles.decreased` | Decreased |
| `options.particles.minimal` | Minimal |
| `options.textureFiltering` | Texture Filtering |
| `options.textureFiltering.anisotropic` | Anisotropic |
| `options.textureFiltering.anisotropic.tooltip` | A hardware-based filtering method, but impacts performance and significantly impacts video memory usage. May not be supported on all hardware. |
| `options.textureFiltering.none` | None |
| `options.textureFiltering.none.tooltip` | Textures are displayed without any filtering. Blocks may look blurry when viewed at an angle. |
| `options.textureFiltering.rgss` | RGSS |
| `options.textureFiltering.rgss.tooltip` | (Rotated Grid Super Sampling)\nA shader-based filtering method that improves texture quality with a moderate performance impact. |
| `options.vignette` | Show Vignette |
| `options.vignette.tooltip` | This is a subtle texture over the game screen used for reducing brightness towards the edges of the screen and warning about the world border. |
| `options.weatherRadius` | Weather Effect Radius |
| `options.weatherRadius.tooltip` | Radius of the area where rain and snow effects are visible. Very low performance impact. |
| `options.accessibility.menu_background_blurriness` | Menu Background Blur |
| `options.accessibility.menu_background_blurriness.tooltip` | Changes the blurriness of menu backgrounds. |

**Unsupported-graphics warning screen (Fabulous preset)**

| Key | Text |
|---|---|
| `options.graphics.warning.accept` | Continue Without Support |
| `options.graphics.warning.cancel` | Take Me Back |
| `options.graphics.warning.message` | Your graphics device is detected as unsupported for the %s graphics option.\n\nYou may ignore this and continue, however support will not be provided for your device if you choose to use %s graphics. |
| `options.graphics.warning.renderer` | Renderer detected: [%s] |
| `options.graphics.warning.title` | Graphics Device Unsupported |
| `options.graphics.warning.vendor` | Vendor detected: [%s] |
| `options.graphics.warning.version` | OpenGL Version detected: [%s] |

**Controls screen, Mouse Settings, Key Binds**

| Key | Text |
|---|---|
| `controls.keybinds` | Key Binds... |
| `controls.keybinds.duplicateKeybinds` | This key is also used for:\n%s |
| `controls.keybinds.title` | Key Binds |
| `controls.reset` | Reset |
| `controls.resetAll` | Reset Keys |
| `controls.title` | Controls |
| `options.allowCursorChanges` | Allow Cursor Changes |
| `options.allowCursorChanges.tooltip` | Allows the mouse cursor to change shape when over certain UI elements. |
| `options.autoJump` | Auto-Jump |
| `options.ctrlClickEmulatesRightClick` | Right Click Emulation |
| `options.ctrlClickEmulatesRightClick.tooltip` | When enabled, Control + left-click is treated as a right-click. Only applies on macOS. |
| `options.discrete_mouse_scroll` | Discrete Scrolling |
| `options.invertMouse` | Invert Mouse |
| `options.invertMouseX` | Invert Mouse X |
| `options.invertMouseY` | Invert Mouse Y |
| `options.key.hold` | Hold |
| `options.key.toggle` | Toggle |
| `options.mouse_settings` | Mouse Settings... |
| `options.mouse_settings.title` | Mouse Settings |
| `options.mouseWheelSensitivity` | Scroll Sensitivity |
| `options.operatorItemsTab` | Operator Items Tab |
| `options.quitShortcuts` | Quit Shortcuts |
| `options.quitShortcuts.tooltip` | Whether keyboard shortcuts can close the game. When off, Alt + F4 on Windows and Linux, and Cmd + Q on macOS, will no longer quit the game. |
| `options.rotateWithMinecart` | Rotate with Minecarts |
| `options.rotateWithMinecart.tooltip` | Whether the player's view should rotate with a turning Minecart. Only available in worlds with the 'Minecart Improvements' experimental setting turned on. |
| `options.sensitivity` | Sensitivity |
| `options.sensitivity.max` | HYPERSPEED!!! |
| `options.sensitivity.min` | *yawn* |
| `options.sprintWindow` | Sprint Window |
| `options.sprintWindow.tooltip` | Time window in ticks where double-tapping the forward key activates sprint. |
| `key.sneak` | Sneak |
| `key.sprint` | Sprint |
| `key.attack` | Attack/Destroy |
| `key.use` | Use Item/Place Block |
| `key.categories.creative` | Creative Mode |
| `key.categories.gameplay` | Gameplay |
| `key.categories.inventory` | Inventory |
| `key.categories.misc` | Miscellaneous |
| `key.categories.movement` | Movement |
| `key.categories.multiplayer` | Multiplayer |
| `key.categories.spectator` | Spectator |
| `key.categories.ui` | Game Interface |
| `key.category.minecraft.creative` | Creative Mode |
| `key.category.minecraft.debug` | Debug |
| `key.category.minecraft.gameplay` | Gameplay |
| `key.category.minecraft.inventory` | Inventory |
| `key.category.minecraft.misc` | Miscellaneous |
| `key.category.minecraft.movement` | Movement |
| `key.category.minecraft.multiplayer` | Multiplayer |
| `key.category.minecraft.spectator` | Spectator |
| `narrator.controls.bound` | %s is bound to %s |
| `narrator.controls.reset` | Reset %s button |
| `narrator.controls.unbound` | %s is not bound |

**Key binding names (all bindable actions)**

| Key | Text |
|---|---|
| `key.advancements` | Advancements |
| `key.back` | Walk Backward |
| `key.chat` | Open Chat |
| `key.command` | Open Command |
| `key.debug.clearChat` | Clear Chat |
| `key.debug.copyLocation` | Copy Location |
| `key.debug.copyRecreateCommand` | Copy Data |
| `key.debug.crash` | Debug Crash |
| `key.debug.debugOptions` | Debug Options |
| `key.debug.dumpDynamicTextures` | Dump Dynamic Textures |
| `key.debug.dumpVersion` | Dump Version Info |
| `key.debug.focusPause` | Toggle Lost Focus Pause |
| `key.debug.fpsCharts` | Fps Charts |
| `key.debug.improvedTransparency` | Toggle Improved Transparency |
| `key.debug.lightmapTexture` | Lightmap Texture |
| `key.debug.modifier` | Debug Modifier Key |
| `key.debug.networkCharts` | Network Charts |
| `key.debug.overlay` | Toggle Overlay |
| `key.debug.profiling` | Start/Stop Profiling |
| `key.debug.profilingChart` | Profiling Chart |
| `key.debug.reloadChunk` | Reload Chunks |
| `key.debug.reloadResourcePacks` | Reload Resource Packs |
| `key.debug.showAdvancedTooltips` | Show Advanced Tooltips |
| `key.debug.showChunkBorders` | Show Chunk Boundaries |
| `key.debug.showHitboxes` | Show Hitboxes |
| `key.debug.spectate` | Cycle Spectator |
| `key.debug.switchGameMode` | Game Mode Switcher |
| `key.drop` | Drop Selected Item |
| `key.forward` | Walk Forward |
| `key.friends` | Friends Screen |
| `key.fullscreen` | Toggle Fullscreen |
| `key.hotbar.1` | Hotbar Slot 1 |
| `key.hotbar.2` | Hotbar Slot 2 |
| `key.hotbar.3` | Hotbar Slot 3 |
| `key.hotbar.4` | Hotbar Slot 4 |
| `key.hotbar.5` | Hotbar Slot 5 |
| `key.hotbar.6` | Hotbar Slot 6 |
| `key.hotbar.7` | Hotbar Slot 7 |
| `key.hotbar.8` | Hotbar Slot 8 |
| `key.hotbar.9` | Hotbar Slot 9 |
| `key.inventory` | Open/Close Inventory |
| `key.jump` | Jump |
| `key.left` | Strafe Left |
| `key.loadToolbarActivator` | Load Hotbar Activator |
| `key.pickItem` | Pick Block |
| `key.playerlist` | List Players |
| `key.quickActions` | Quick Actions |
| `key.right` | Strafe Right |
| `key.saveToolbarActivator` | Save Hotbar Activator |
| `key.screenshot` | Take Screenshot |
| `key.smoothCamera` | Toggle Cinematic Camera |
| `key.socialInteractions` | Social Interactions Screen |
| `key.spectatorHotbar` | Select On Hotbar |
| `key.spectatorOutlines` | Highlight Players |
| `key.swapOffhand` | Swap Item With Off Hand |
| `key.toggleGui` | Toggle GUI |
| `key.togglePerspective` | Toggle Perspective |
| `key.toggleSpectatorShaderEffects` | Toggle Spectator Shader Effects |

**Music & Sounds screen**

| Key | Text |
|---|---|
| `options.sounds.title` | Music & Sound Options |
| `soundCategory.ambient` | Ambient/Environment |
| `soundCategory.block` | Blocks |
| `soundCategory.hostile` | Hostile Mobs |
| `soundCategory.master` | Master Volume |
| `soundCategory.music` | Music |
| `soundCategory.neutral` | Friendly Mobs |
| `soundCategory.player` | Players |
| `soundCategory.record` | Jukebox/Note Blocks |
| `soundCategory.ui` | UI |
| `soundCategory.voice` | Narrator/Voice |
| `soundCategory.weather` | Weather |
| `options.audioDevice` | Device |
| `options.audioDevice.default` | System Default |
| `options.directionalAudio` | Directional Audio |
| `options.directionalAudio.off.tooltip` | Classic Stereo sound. |
| `options.directionalAudio.on.tooltip` | Uses HRTF-based directional audio to improve the simulation of 3D sound. Requires HRTF-compatible audio hardware, and is best experienced with headphones. |
| `options.music_frequency` | Music Frequency |
| `options.music_frequency.constant` | Constant |
| `options.music_frequency.default` | Default |
| `options.music_frequency.frequent` | Frequent |
| `options.music_frequency.tooltip` | Changes how frequently music plays while in a game world. |
| `options.musicToast` | Music Toast |
| `options.musicToast.never` | Never |
| `options.musicToast.never.tooltip` | No music toast is shown. |
| `options.musicToast.pauseMenu` | Pause Menu |
| `options.musicToast.pauseMenu.tooltip` | A music toast is constantly displayed in the in-game pause menu while a song is playing. |
| `options.musicToast.pauseMenuAndToast` | Pause Menu and Toast |
| `options.musicToast.pauseMenuAndToast.tooltip` | Displays a toast when a song starts playing. The same toast is constantly displayed in the in-game pause menu while a song is playing. |
| `options.showSubtitles` | Closed Captions |
| `options.showSubtitles.tooltip` | Enables captions for sounds played in the game. |

**Accessibility Settings screen**

| Key | Text |
|---|---|
| `options.accessibility.high_contrast` | High Contrast |
| `options.accessibility.high_contrast_block_outline` | High Contrast Block Outlines |
| `options.accessibility.high_contrast_block_outline.tooltip` | Enhances the block outline contrast of the targeted block. |
| `options.accessibility.high_contrast.error.tooltip` | High Contrast resource pack is not available. |
| `options.accessibility.high_contrast.tooltip` | Enhances the contrast of UI elements. |
| `options.accessibility.link` | Accessibility Guide |
| `options.accessibility.narrator_hotkey` | Narrator Hotkey |
| `options.accessibility.narrator_hotkey.mac.tooltip` | Allows the Narrator to be toggled on and off with 'Cmd + B'. |
| `options.accessibility.narrator_hotkey.tooltip` | Allows the Narrator to be toggled on and off with 'Ctrl + B'. |
| `options.accessibility.panorama_speed` | Panorama Scroll Speed |
| `options.accessibility.text_background` | Text Background |
| `options.accessibility.text_background_opacity` | Text Background Opacity |
| `options.accessibility.text_background.chat` | Chat |
| `options.accessibility.text_background.everywhere` | Everywhere |
| `options.accessibility.title` | Accessibility Settings |
| `options.accessibility.tooltip` | Accessibility Settings |
| `options.damageTiltStrength` | Damage Tilt |
| `options.damageTiltStrength.tooltip` | The amount of camera shake caused by being hurt. |
| `options.darkMojangStudiosBackgroundColor` | Monochrome Logo |
| `options.darkMojangStudiosBackgroundColor.tooltip` | Changes the Mojang Studios loading screen background color to black. |
| `options.darknessEffectScale` | Darkness Pulsing |
| `options.darknessEffectScale.tooltip` | Controls how much the Darkness effect pulses when a Warden or Sculk Shrieker gives it to you. |
| `options.fovEffectScale` | FOV Effects |
| `options.fovEffectScale.tooltip` | Controls how much the field of view can change with gameplay effects. |
| `options.glintSpeed` | Glint Speed |
| `options.glintSpeed.tooltip` | Controls how fast the visual glint shimmers across enchanted items. |
| `options.glintStrength` | Glint Strength |
| `options.glintStrength.tooltip` | Controls how transparent the visual glint is on enchanted items. |
| `options.hideLightningFlashes` | Hide Sky Flashes |
| `options.hideLightningFlashes.tooltip` | Prevents Lightning Bolts or other environmental effects from making the sky flash. The sources of flashes themselves will still be visible. |
| `options.hideSplashTexts` | Hide Splash Texts |
| `options.hideSplashTexts.tooltip` | Hides the yellow splash text in the main menu. |
| `options.narrator` | Narrator |
| `options.narrator.all` | Narrates All |
| `options.narrator.chat` | Narrates Chat |
| `options.narrator.notavailable` | Not Available |
| `options.narrator.off` | OFF |
| `options.narrator.system` | Narrates System |
| `options.screenEffectScale` | Distortion Effects |
| `options.screenEffectScale.tooltip` | Strength of Nausea and Nether Portal screen distortion effects.\nAt lower values, the Nausea effect is replaced with a green overlay. |
| `options.viewBobbing` | View Bobbing |
| `narrator.button.accessibility` | Accessibility |

**Chat Settings screen**

| Key | Text |
|---|---|
| `options.chat.color` | Colors |
| `options.chat.delay` | Chat Delay: %s second(s) |
| `options.chat.delay_none` | Chat Delay: None |
| `options.chat.drafts` | Save Unsent Chats |
| `options.chat.drafts.tooltip` | Unsent messages will be saved and can be sent the next time chat is opened. |
| `options.chat.height.focused` | Focused Height |
| `options.chat.height.unfocused` | Unfocused Height |
| `options.chat.line_spacing` | Line Spacing |
| `options.chat.links` | Web Links |
| `options.chat.links.prompt` | Prompt on Links |
| `options.chat.opacity` | Chat Text Opacity |
| `options.chat.scale` | Chat Text Size |
| `options.chat.title` | Chat Settings |
| `options.chat.visibility` | Chat |
| `options.chat.visibility.full` | Shown |
| `options.chat.visibility.hidden` | Hidden |
| `options.chat.visibility.system` | Commands Only |
| `options.chat.width` | Width |
| `options.autoSuggestCommands` | Command Suggestions |
| `options.hideMatchedNames` | Hide Matched Names |
| `options.hideMatchedNames.tooltip` | 3rd-party Servers may send chat messages in non-standard formats.\nWith this option on, hidden players will be matched based on chat sender names. |
| `options.reducedDebugInfo` | Reduced Debug Info |
| `options.onlyShowSecureChat` | Only Show Secure Chat |
| `options.onlyShowSecureChat.tooltip` | Only display messages from other players that can be verified to have been sent by that player, and have not been modified. |
| `options.notifications.display_time` | Notification Time |
| `options.notifications.display_time.tooltip` | Affects the length of time that all notifications stay visible on the screen. |

**Skin Customization screen**

| Key | Text |
|---|---|
| `options.mainHand` | Main Hand |
| `options.mainHand.left` | Left |
| `options.mainHand.right` | Right |
| `options.modelPart.cape` | Cape |
| `options.modelPart.hat` | Hat |
| `options.modelPart.jacket` | Jacket |
| `options.modelPart.left_pants_leg` | Left Pant Leg |
| `options.modelPart.left_sleeve` | Left Sleeve |
| `options.modelPart.right_pants_leg` | Right Pant Leg |
| `options.modelPart.right_sleeve` | Right Sleeve |
| `options.skinCustomisation.title` | Skin Customization |

**Language screen**

| Key | Text |
|---|---|
| `options.language.empty_or_missing_translation` | Translation file for %s was empty or missing. Restart your game and launcher, then try again. |
| `options.language.load_translations_failed` | Loading translations failed |
| `options.language.narration` | Change Language |
| `options.language.title` | Language |
| `options.language.tooltip` | Change Language |
| `options.languageAccuracyWarning` | (Language translations may not be 100%% accurate) |
| `options.languageWarning` | Language translations may not be 100%% accurate. |
| `narrator.button.language` | Language |
| `gui.language.search` | Search... |

**Entries that exist on the real screens but need no behaviour in CobolCraft (not built)**

| Key | Text |
|---|---|
| `options.allowFriendRequests` | Allow Requests |
| `options.allowFriendRequests.tooltip` | Allow other players to send you friend requests |
| `options.allowServerListing` | Allow Server Listings |
| `options.allowServerListing.tooltip` | Servers may list online players as part of their public status.\nWith this option off, your name will not show up in such lists. |
| `options.credits_and_attribution` | Credits & Attribution... |
| `options.font` | Font Settings... |
| `options.font.title` | Font Settings |
| `options.forceUnicodeFont` | Force Unicode Font |
| `options.friendsList` | Friends List |
| `options.friendsList.confirm.message` | Use your Friends List to send and receive friend requests.\n\nManage online safety settings with your %s. |
| `options.friendsList.confirm.message.link` | Microsoft account |
| `options.friendsList.confirm.title` | Friends List |
| `options.friendsList.confirm.turnOff` | Turn OFF |
| `options.friendsList.confirm.turnOn` | Turn ON |
| `options.inGameNotification` | In-Game Notification |
| `options.inGameNotification.tooltip` | Show Friend notifications in-game |
| `options.japaneseGlyphVariants` | Japanese Glyph Variants |
| `options.japaneseGlyphVariants.tooltip` | Uses Japanese variants of CJK characters in the default font. |
| `options.multiplayer.title` | Open to LAN |
| `options.online` | Online... |
| `options.online.friends.header` | Friends List |
| `options.online.realms.header` | Realms |
| `options.online.servers.header` | Servers |
| `options.online.title` | Online Options |
| `options.online.xboxSettings` | Xbox Settings... |
| `options.rawMouseInput` | Raw Input |
| `options.realmsNotifications` | Realms News & Invites |
| `options.realmsNotifications.button` | News & Invites |
| `options.realmsNotifications.tooltip` | Fetches Realms news and invites in the title screen and displays their respective icon on the Realms button. |
| `options.sharePresence` | Visibility |
| `options.sharePresence.all` | Full |
| `options.sharePresence.all.tooltip` | Friends can see what you're playing. |
| `options.sharePresence.limited` | Limited |
| `options.sharePresence.limited.tooltip` | Friends can see when you're online, but not what you're playing. |
| `options.sharePresence.none` | Hidden |
| `options.sharePresence.none.tooltip` | Friends will always see you as offline. |
| `options.telemetry` | Telemetry Data... |
| `options.telemetry.button` | Data Collection |
| `options.telemetry.button.tooltip` | "%s" includes only the required data.\n"%s" includes optional, as well as the required data. |
| `options.telemetry.disabled` | Telemetry is disabled. |
| `options.telemetry.state.all` | All |
| `options.telemetry.state.minimal` | Minimal |
| `options.telemetry.state.none` | None |
| `options.touchscreen` | Touchscreen Mode |
| `options.worldOptions.button` | World Options... |
| `options.worldOptions.title` | World Options |

Not supplied here, with the reason: `key.keyboard.*` and `key.mouse.*` (13 section 7.5 has them with their codes); the resource-pack screen texts (`pack.*`,
`resourcePack.*`, 13 section 8); the difficulty and world-option texts (`options.difficulty*`, `options.worldOptions.*`), which belong to the in-world options of a
world's owner and not to the Options screens of the title or pause menu in this client; `options.showNowPlayingToast*` (a legacy key that no option uses).

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
Activating it (click, Enter or Space when focused) selects the next type in the order `standard`, `cobolcraft`, and wraps (the
auto and explicit states are Decision UI-25 below). Both types are always in the cycle, even when `standard` is unavailable. (README Part 4, C10 says that without a valid jar the game
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

**Decision UI-25 (auto and explicit state of the type button).** The button has two states, as world-types.md 3.2 defines
them, and the state lives only in the screen. In the **auto** state (the screen's initial state) the button shows the type the
default rule yields from the check result when the screen opened: `standard` if it is available, else `cobolcraft` (README
decision 2: "default `standard` when the generated packs are present, otherwise `cobolcraft`"). The first activation makes the
choice **explicit**: it selects the type after the one shown (wrapping), and the state stays explicit afterwards, even when the
player cycles back to the type it started on. The description block always follows the type shown.

Pressing Create re-runs the check (world-types.md 3.2) and the result at that moment decides:

| State | Result at Create | Outcome |
|---|---|---|
| auto | `ok` | a `standard` world (even if the screen showed `cobolcraft`) |
| auto | not `ok` | a `cobolcraft` world, with the visible fallback notice (below); no missing-data screen (T2a) |
| explicit `standard` | not `ok` | no world; the missing-data screen with the extra button (T2, Decision UI-16) |
| explicit `standard` | `ok` | a `standard` world |
| explicit `cobolcraft` | any | a `cobolcraft` world |

(This is world-types.md 3.2 and its examples E6 and E6a: opened with `ok`, button untouched, check `damaged` at Create gives a
cobolcraft world and the notice.) **Fallback notice:** the key `cobolcraft.world_type.auto_fallback`, with the result word
(`absent`, `incomplete`, `stale` or `damaged`) as its argument, in `#FFC857`. It is drawn as the second line of the new world's
row in the world list (section 7.3) and as a one-line text at the top of the world list screen (y = 8, centred, wrapped by the
greedy rule of section 8.3 to `wrapW`) when the player returns to it after Create; it is kept in memory only.

Below the cycle button is a **description block**: left-aligned text, wrapped to 200 pixels at the greedy rule of section 8.3 with a
line pitch of 11, at most 3 lines (further lines are not drawn). When the selected type is available it is the type's
description key (`#A0A0A0`). When it is unavailable it is the `short` key of the current reason
(`cobolcraft.ui.missing_data.short.<reason>`, reason one of `absent`, `incomplete`, `stale`, `damaged`, `#FFC857`).

**Decision UI-16 (Create and Play stay enabled).** The Create button is never disabled by the type. If the player presses it
with an explicit `standard` choice while the check is not `ok` (an auto choice falls back instead, Decision UI-25), no world is made and the missing-data screen of section 8.3 opens, with the extra
button `Use CobolCraft World Type`. Reason: a disabled button answers "why" with silence; a pressed button can open the full
explanation, and it is the same screen for every trigger.

**Decision UI-24 (Create screen layout and seed row).** Every position in the table below is a choice of this document, since no
document gives them (Open question 17): the title at y = 20, the name label at y = 40, the name field at y = 50, the game mode
button at y = 78, the type button at y = 102, the description block at y = 128 with its cap of 3 lines, 11-pixel pitch and
200-pixel wrap width, the seed label at y = 164 and field at y = 174, and the Create and Cancel buttons (120 x 20 at guiH - 28,
cx - 122 and cx + 2). The seed row is the optional seed text field of world-types.md WT-19; its label and its empty-field
hint `cobolcraft.screen.create_world.seed_hint` ("Leave empty for a random seed", `#A0A0A0`, drawn in the empty field) are chosen
(Open question 26). The seed field is shown for both types, because the seed is stored for both (world-types.md WT-5). The
description block has its 31 pixels (y = 128 to 159) reserved even when it is shorter, so the seed row does not move. Reason:
the rows must not overlap at the smallest automatic GUI (240 high: the field ends at y = 193, Create starts at 212), and an
exact table is needed to test a layout. The 3-line cap cuts anything longer; only the two worked examples below were wrapped by hand.

Layout, in GUI pixels (12 section 5.1), with cx = guiW div 2. The earlier rows exist already (08 section 10.8.6 keys); their
positions are fixed by Decision UI-24. Values for the smallest automatic GUI, 320 x 240:

| Element | x | y | Width x height | At 320 x 240 |
|---|---|---|---|---|
| Title `cobolcraft.screen.create_world.title`, centred, white | (guiW - textWidth) div 2 | 20 | text x 9 | "Create New World" is 90 wide: x = 115 |
| Label `cobolcraft.screen.create_world.name`, `#A0A0A0` | cx - 100 | 40 | text x 9 | x = 60 |
| Name field (`widget/text_field`) | cx - 100 | 50 | 200 x 20 | (60, 50) |
| Game mode cycle button (existing) | cx - 100 | 78 | 200 x 20 | (60, 78) |
| **World type cycle button** | cx - 100 | 102 | 200 x 20 | (60, 102) |
| **Description block** | cx - 100 | 128 | 200 wide, up to 3 x 11 - 2 = 31 | (60, 128) to y = 159 |
| **Seed label** `cobolcraft.screen.create_world.seed` ("Seed (optional)"), `#A0A0A0` | cx - 100 | 164 | text x 9 | (60, 164) |
| **Seed field** (`widget/text_field`, optional; world-types.md WT-19) | cx - 100 | 174 | 200 x 20 | (60, 174) to y = 193 |
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

**Decision UI-26 (worlds that cannot be opened at all).** world-types.md 2.1 defines four more cases in which a world is not
opened. The row's second line, in `#FFC857`, and the Play button, which is **disabled** (sprite `widget/button_disabled`,
label `#A0A0A0`, no activation; unlike the unavailable-standard case above, because no screen can explain or fix these),
are:

| Case (world-types.md 2.1) | Second line | Key and text |
|---|---|---|
| `WorldType` is an unknown string `<value>` | `cobolcraft.world_type.unknown.short` | Unknown world type '%s' (the value, drawn with the missing glyph for a character outside codes 32 to 126) |
| `WorldType` absent, with `dimensions/minecraft/` | `cobolcraft.world_type.missing` | This world has no world type and cannot be opened. |
| a folder with `dimensions/` and no `level.dat` | `cobolcraft.world_type.no_level` | This folder holds world data but no level.dat. |
| a standard world with no `Seed` | `cobolcraft.world_type.no_seed` | This world has no seed and cannot be opened. |

The long keys `cobolcraft.world_type.unknown` and `.config_*` are server console texts (world-types.md 3.5) and are not drawn
by this document's screens. Nothing in such a world is altered. The "newer version" text of `unknown` is not shown on the
row; it is the console text. A second line wider than the row is cut at the row's edge (Open question 24). A world whose
`WorldType` is valid and available has no warning line.

**Fallback notice.** A world created through an auto fallback (Decision UI-25) shows the notice as its second line in place of
the type line, until the player first opens that world or leaves the game; nothing is stored.

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
| T1 | The title screen is shown while the state is not `ok` | the banner with the reason (section 8.4) |
| T2 | Create is pressed with an **explicit** `standard` choice (the button was pressed at least once, section 7.2) and the check at that moment is not `ok` | the missing-data screen with the extra button |
| T2a | Create is pressed in the **auto** state of the type button and the check at that moment is not `ok` | no screen: a cobolcraft world is created and the fallback notice of Decision UI-25 is shown (world-types.md 3.2) |
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
| 4 | what to do: the exact command line | `cobolcraft.ui.missing_data.fix` for `absent`, `incomplete` and `stale`; `cobolcraft.ui.missing_data.fix_force` for `damaged` (the command line of 22 section 9.2, with `--force` for `damaged` as the text of paragraph 1 says) | `#FFFFFF` |

Paragraph 1 is 22's fixed text and names the action; paragraph 4 gives the command line to type, and for `damaged` it carries
the same `--force` as paragraph 1, so the screen never gives two different instructions for one state. The `damaged` command
line wraps to 2 lines like the others (inferred from the widths; not hand-checked).

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

When the state is not `ok`, the title screen draws a two-line banner (T1), so that the reason is on the title screen itself (22
section 8.6 says the banner "says why"; it is the only surface for a standard server joined without packs and for an existing
cobolcraft world with a not-`ok` check). A `popup/background` panel (nine-slice, border 4) of width textWidth + 16 and height 30
at x = (guiW - width) div 2, y = 8, where textWidth is the larger of the widths of the two lines. Line 1 is the text
`cobolcraft.ui.missing_data.banner` in `#FFC857` at (x + 8, y + 5); line 2 is `cobolcraft.ui.missing_data.short.<reason>`
(section 8.1 reason) in `#FFC857` at (x + 8, y + 16). At 320 x 240 with reason `absent`, line 1 is 198 wide and line 2
("Needs Minecraft content from your jar.") 209 wide, so the panel is 225 x 30 at (47, 8), line 1 is at (55, 13) and line 2 at
(55, 24). When the pointer is over the panel, or it has keyboard focus, `Ring(x, y, x + width - 1, y + 29, 1, #FFFFFF)` is
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
| Effect icons (4.10) | 40 (keys: `mob_effect/<name>`, names in id order in 4.10) | `24644e02a9e418b8516e40e3abcb12b5067192bb0820e318c889df5c8fa8aac2` |
| Sheets (4.11) | 3 (ids: `container/inventory`, `container/crafting_table`, `recipe_book`) | `7b89b76c45319c214fa63a2ed24b3780cc2fdb3237867707ee0a976d46df9f8e` |

The 40 generated effect icons (4.10) are one group of this table: the key of a member is `mob_effect/<name>` (for example
`mob_effect/speed`), and the lines are sorted by key in byte order, not in id order (`mob_effect/absorption` is first, `mob_effect/weakness` before `mob_effect/weaving`, `mob_effect/wind_charged` before `mob_effect/wither`).

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
2. Hash every file as in section 9 (the 40 virtual effect icons of section 4.10 included) and compare with sections 4.1 to 4.12,
   then the manifests of 9.2.
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
| UI-10 | Built-in sheets are at logical size; the built-in recipe book panel is at (0, 0) (built-in sheet only; the client's source origin follows 4.13.8) | 4.11, 4.13.8 |
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
| UI-21 | Nine-slice borders are chosen; buttons use the read 3, the disabled button 2 against the read 1 of 12 section 5.9 | 3, 5.3 |
| UI-22 | Recipe-book tab icons are letters in the cobolcraft world type | 4.7 |
| UI-23 | Recipe-book search field uses `widget/text_field` (cobolcraft world type only); dark text without shadow on parchment; page label and toast text rectangles are chosen | 4.7, 6 |
| UI-24 | The Create New World layout (row positions, pitch, 3-line cap, 200-pixel wrap, button positions) and the seed row are chosen | 7.2 |
| UI-25 | The type button has an auto and an explicit state; an auto choice that fails at Create falls back to cobolcraft with a visible notice | 7.2 |
| UI-26 | A world with an unknown or missing type, no level.dat or no seed shows a warning line and a disabled Play | 7.3 |
| UI-27 | Placement and use of the empty-slot icons and of `container/slot` | 4.4 |
| UI-29 | The options screens use the standard key names (`options.*`, `controls.*`, `key.*`, `soundCategory.*`) with the values read from the artifact | 6.2 |
| UI-28 | Recipe-book tab rectangle 35 x 27 with the built-in sprite stretched, tab letter centred in 35, page label centred on panel x + 73, toast text positions and colours read from the client | 4.13.4 |

## 12. Open questions

Each is for the planner or the next clean-room round; none blocks an implementation of this document, because every one
has a stated working choice.

1. **Sprite sizes not read.** The sizes of `hud/hotbar_attack_indicator_background` and `_progress` (18 x 18), the three
   crosshair indicator sprites (16 x 16), `hud/effect_background` and `_ambient` (24 x 24), the recipe-book tab (32 x 27),
   the recipe slots and overlay buttons (25 x 25), `popup/background` (32 x 32), `recipe_book/overlay_recipe` (32 x 32) and
   `toast/recipe` (160 x 32) are choices. A round that reads the sprite sizes or the draw calls of 14 section 6.1's classes should confirm or
   replace them. A pack's own sizes already work (14 section 6.3). **Mostly closed by section 4.13.1**: read sizes are the same except the crosshair attack-indicator bar (16 x 4, not 16 x 16), the tab (35 x 27), the crafting overlay (24 x 24) and `popup/background` (236 x 34); client rules in 4.13.8.
2. **Sheet regions.** 14 section 6.2 and 12 section 5.6 give the region of the inventory and crafting-table sheets, (0, 0, 176, 166).
   The region of `recipe_book.png` that the 147 x 166 panel uses is not given (13 section 3.9 says only that the texture is 256 x 256). If
   the real sheet has the panel at another origin, the client must use that origin and the built-in sheet of section 4.11 must
   move the panel to it. **Closed by section 4.13.4**: the panel is blitted from (1, 1) of the 256 x 256 sheet, size 147 x 166; the inventory and crafting-table sheets are (0, 0, 176, 166). Moving the built-in panel to (1, 1) is optional: the interim rule of 4.13.8 stands (origin (1, 1) for a sheet from a pack above the built-in pack, (0, 0) for the built-in sheet); doing it means recomputing the section 9 check value (not done in this round).
3. **Attack indicator drawing.** Whether the `_progress` sprites are clipped horizontally or vertically by the cooldown,
   and whether the hotbar indicator is 18 x 18 (12 section 5.2 says only "not detailed here"). **Partly closed**: the hotbar indicator sprites are 18 x 18 (section 4.13.1); the clipping direction is still unread (interim choice in 4.13.8).
4. **Recipe-book tab and toast details.** Original tab icons (new sprite ids with recipes) are not drawn; Decision UI-22 uses
   letters in the cobolcraft world type, and the real icon offsets in the standard type are still unread. Also the tab sprite width, the id
   of the toast sprite (`toast/recipe` is a working name from 14 section 6.1's `toast/*`) and the toast's texts. The page-label and toast-text rectangles and the toast text are chosen (Decision UI-23); no document
   gives them.
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
13. **Closed: options screen texts.** Supplied by section 6.2 (texts, read from the artifact's `en_us.json`) and 13 sections 7.2 and 7.4 to 7.6 (names,
    defaults, ranges, persisted keys, stored forms, label formats, screen order, key codes and key labels). Remaining details are Open questions 35 to 37 (34 is closed).
14. **Disabled and hovered label colours.** 12 section 5.9 says the disabled colour was not traced; `#A0A0A0` is a choice.
15. **Generated font definitions.** Closed by 08 section 10.10: both world types use `minecraft:default`, the generated pack's
    files replace the built-in four by path, and no `cobolcraft:default` exists (section 4.12).
16. **Tooltip frame offset.** The real frame offset inside the 9-pixel border (Decision UI-13) is not verifiable from the documents; a
    read of the real `tooltip/frame` metrics would. **Closed by section 4.13.5** (vanilla ring at pixel 9, border 10, `stretch_inner`).
17. **Existing screen layouts.** The positions of the title, name label, name field and game mode button on the Create New
    World screen, and of the world list rows, are not in a document; section 7.2 fixes them. If another document (spec
    data model section 13) has them, that one wins and the rows of the type control follow the game mode row.
18. **Banner focus and keyboard.** The tab order of the banner and the Create screen's extra button, and whether Enter on the
    banner activates it (the text of section 8.3 says Enter activates the first button of that screen only).
19. **Button borders.** 12 section 5.9 reports border 3 (disabled 1); the built-in art uses 3 (disabled 2, Decision UI-21). A read of the
    real `.mcmeta` values for the other widgets (text field, sliders, handles, scrollers) would confirm or replace the rest. **Closed by section 4.13.2** (values listed there; the built-in values stay as chosen).
20. **Selectable or disabled standard choice (needs a ruling; this fix pass could not settle it).** 22 section 9.2 disables the standard choice on the world-creation screen; this
    document keeps it selectable and explains on Create (Decision UI-15, UI-16). README Part 4, C10 ("the game offers only the
    cobolcraft world type" without a valid jar) and README decision 2 ("a missing or wrong jar disables the standard type") say
    offered-only or disabled as well, so the conflict is three-sided: README and 22 say not offered or disabled, this document says
    offered and selectable. No world is created in any reading, so the outcome matches C10; only the wording "offers only" does not.
    The owner of 22, the README or the operator decides; until then the screens of section 7.2 are implemented as written and
    are the first thing to change if the ruling goes the other way (cycle skips `standard`, `standard.unavailable` shown under
    the button, which would also give that key its user). Searched: README Part 4 C10, README decision 2, 22 section 9.2,
    world-types.md 3.5; none carries a ruling. (Open question 9 is a separate question: jar against generated directory.)
21. **Closed: manifest of the 40 effect icons.** The hashes of all 40 icons and the group manifest are in sections 4.10 and 9.2.
    Nothing remains open except the placement (Open question 22).
22. **Status-effect HUD layout.** 12 section 5 has no layout for the status-effect icons (position, spacing, the use of the
    24 x 24 background, the 18 x 18 icon offset, the blink at the end of a duration). Searched: 12 section 5 and 14 section 7.5.
    The 18 x 18 icon centred in the 24 x 24 background is a working choice only.
23. **Standard language keys the cobolcraft world type still lacks (GAP-34 and README Part 4, C11, fallback language set).**
    cobolcraft-standard-core.md Open question 11 makes this document and the built-in `lang/en_us.json` the home of
    `container.crafting` (the bench title), `block.cobolcraft.crafting_bench` and `item.cobolcraft.crafting_bench`,
    `enchantment.minecraft.efficiency`, the `chat.type.*` keys, `commands.message.display.incoming` and `.outgoing`,
    `death.attack.*` and `death.attack.hail`; the experience level text of 12 section 5.4 uses the standard key
    `gui.experience.level`, and 08 section 10.8 retired the stand-in death and command keys in favour of the standard ones.
    With no generated pack the cobolcraft world type has no language file for any of these, so by the lookup rule of 08
    section 10.8 each is shown as the key itself. **This document supplies none of these texts** (it supplies the level
    colour, section 6, and the bench sheet, section 4.11, but not the words), so GAP-34 and README C11 stay open for the
    bench title, the experience level number, chat messages, command feedback and death messages, (the options screen texts are
    supplied in section 6.2). Searched: sections 6 and 6.1 of this document, and the key tables of 08 section 10.8.6; none
    holds them. The next round must write the English texts (and mark which are read from the vanilla language file and
    which are chosen).
24. **Rows and widths of the world list and the notice.** The row width of the world list and the room for the second line
    are not given by any document (Open question 17), so a long second line (the texts of `no_level`, `no_seed` and
    `missing`, Decision UI-26) is cut at the row's right edge, without an ellipsis; a round that reads the list layout should
    replace that rule. Where the fallback notice of Decision UI-25 sits on "the next screen" is likewise chosen (the line at
    the top of the world list; the screen after Create is the world list).
25. **Edits other documents owe this document (the contradictions stay until those edits are made; this task may edit only this file).** (a) world-types.md section 3.5 says that `cobolcraft.world_type.standard.unavailable`
    is used by the Create screen and the world list; this document draws the `short` keys there instead (section 6.1), so
    world-types.md should drop that claim, or this document must change. (b) 22 section 8.6 says the title banner "says why":
    the banner of section 8.4 now shows the `short` reason on its second line, so the sentence holds; 22 section 9.2 should
    cite section 8.4 for the layout. (c) 08 section 10.8.6 still lists `cobolcraft.hud.health`, `.food`, `.crosshair` and the
    `cobolcraft.screen.crafting.*` keys; the table of section 5.4 says they are retired. (d) world-types.md says no keys are placed in this document yet; section 6.1
    places them, so that sentence must be updated. (e) 08 section 10.2 (closing sentence), 10.9 (count), 10 (no virtual
    `mob_effect` file rule) must be edited as section 5.4 lists; until then the repository holds conflicting definitions.
26. **Seed field texts.** The label and hint of the seed field (Decision UI-24) are chosen; whether the standard Create screen
    has the same words is unread.
27. **Hardcore and effect combinations of the hearts.** 12 section 5.4 says hardcore worlds use `hardcore_*` hearts and that
    poison, wither and freeze use `poisoned_*`, `withered_*`, `frozen_*`, but not which one is drawn when both apply, nor whether
    `absorbing_*` has hardcore forms. Section 4.2 supplies no `hardcore_poisoned_*`, `hardcore_withered_*`, `hardcore_frozen_*`
    or `hardcore_absorbing_*` ids; if the client asks for such an id it draws the missing-texture stripes. Working choice: the
    client draws the effect sprite (`poisoned_*` and so on) over the hardcore container, since the effect sprites are the
    ones 12 names for the filled part. Searched: 12 section 5.4, 14 section 6.1. `container_hardcore_blinking` is inferred.
28. **Misc whole-image textures and the 14 section 6.2 sheets not supplied.** 14 section 7.6 lists placeholder icons for an unknown
    server or pack under `textures/misc`. Only `misc/unknown_pack` is supplied. The unknown-server icon (the server list entry
    with no favicon, 08 section 10.8.6), and the other `misc/` textures (vignette, underwater, pumpkin, spyglass, shadow, glint)
    and sheets (`generic_54` and the like) are not supplied and not otherwise addressed: nothing in the cobolcraft screens as
    listed in section 1 draws them (not verified against client code). Until a round decides, such a request draws the stripes;
    the server list should draw no icon rather than request one.
29. **Minimum window size and text widths.** Section 7.2 assumes the smallest automatic GUI is 320 x 240; 12 section 5.1 derives the
    GUI size from the framebuffer, so a window below 320 x 240 at GUI scale 1 overflows the rows. **Window part closed by section 4.13.6** (minimum window 320 x 240; the GUI is never smaller while the framebuffer is at least that size); the text-width part stays open. The text widths in the worked
    examples of sections 7.2 and 8.3 (90, 95, 111, 121, 209 and so on) were computed from standin section 18 advances and not
    re-verified by a second reader; section 10 step 5 depends on them.
30. **Recipe-book panel origin and tab overlap.** The origin (rbX, rbY) of the panel in `recipe_book.png` is a parameter that holds
    only at (0, 0) (Open question 2, Decision UI-10); the Sheets manifest changes if it moves, and in the standard world type the
    client must use the real sheet's origin, which no document gives. Also, 13 section 3.9 places a tab at x = panel - offset - 30,
    so a 32-wide tab overlaps the panel by 2 pixels; the tab sprite is drawn over the panel edge there. **Closed by section 4.13.4**: tabs are 35 wide at panel x - 30 (the selected one 2 further left); the origin (1, 1) is read.
31. **Contrast values and shadow colour.** The contrast ratios of section 6 and the shadow `#3F3F3F` are chosen or assumed as
    stated; the ratios were not recomputed in the fix pass. **Ratios recomputed in section 4.13.7**; the shadow colour is still unread.
32. **Recipe overlay button size and indicator placement.** The vanilla `recipe_book/crafting_overlay*` sprites are 24 x 24 while the recipe
    slots are 25 x 25; the size at which the "more recipes" overlay (`OverlayRecipeComponent`) draws its buttons, and its layout, were not
    read in this round. Likewise the position of the 16 x 4 attack-indicator bar under the crosshair was not read.
33. **Disabled button label colour and text shadow.** The button classes draw the label through a collector that carries only pose,
    opacity and scissor; where a disabled label becomes grey (if it does) and the shadow rule (offset, colour) were not traced
    (section 4.13.3). Decision UI-12 stays a choice.
34. **Closed: preset values.** Read in the second pass of round OPT: the full per-preset table, what `Custom` leaves alone and the device conditions are in 13 section 7.6.
35. **Plus-minus glyph.** The label of the keypad key code 215 is `Keypad ±` (13 section 7.5), the only non-ASCII value among the options
    texts; whether the built-in font (section 4.12) carries the glyph is a choice (`+-` is the fallback).
36. **Legacy `options.dat`.** The artifact has no reader or writer of an `options.dat`; round OPT found only `options.txt` (13 section 7.1). The format of
    a legacy `options.dat` (US16) is not documented here and must come from another source (the operator's description or a document, not the artifact).
37. **Untraced screen details.** (a) Closed: the two-column offset is read (150-wide widgets, second column 160 to the right, 13 section 7.6); (b) the interval during which a click right after binding a key is ignored; (c) the mouse-button label formatter for
    buttons 4 to 8 (taken as `Button N`) and the layout-dependent label of printable keys (the client asks the windowing library; the table gives the US-layout
    upper-case letter); (d) the in-world difficulty control next to the FOV slider; (e) the list of languages and their display names for the Language
    screen (the jar's `lang` folder holds `en_us.json` and `deprecated.json` only); (f) the platform-dependent Windows/Meta/Command/Option key texts.
