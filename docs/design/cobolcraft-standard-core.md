# The cobolcraft world type's standard core

| Item | Value |
|---|---|
| Covers | The small hand-authored data set that the cobolcraft world type carries when no vanilla data pack exists, so that the shared engines (documents 12, 13, 15 to 18, 33) run on it (conditional for the world clock and timelines: the `day` rows are exact only for the tracks that 12 section 3.2 lists, so an engine that reads another track of the standard `day` timeline finds none, Open question 6; the other conditions are in the Readiness table of section 0): the synchronized registries it needs with their rows written out (world clock, timelines, dimension types, biomes, chat types, damage types, one enchantment), the tags its shared rules read, and the cobolcraft blocks, items, tools, foods, mobs, loot, recipes and starting kit expressed in the standard data schemas |
| Does not cover | The generated vanilla data (the standard world type, `docs/protocol/22-extraction-tool.md`); the rules of the engines themselves; textures and language texts (`08` section 10, `builtin-ui-art.md`); the cobolcraft generator (`standin-content.md` section 5.2, 15.2) |
| Closes | GAP-35 and README Part 4 consequence C3 (`docs/design/README.md`); settles README Part 7 decisions 3 (the crafting bench), 4 (break times as properties and tags) and 18 (the core is hand-authored) |
| Method | Documents only. Every number below is taken from a document named next to it, with these exceptions, each marked where it occurs: invented values that are Decisions (CORE-n), values marked "(recalled, not verified)" or "(inferred)", and the `day` timeline, whose rows are exact only for the tracks that 12 section 3.2 lists (Open question 6). The block table's map colour, sound, push reaction, instrument and spawn or suffocation flag columns are Decision CORE-28, not derived values. A value that is a design choice is a **Decision CORE-n** with its reason. A value that no document gives and that is written from outside the documents is marked "(recalled, not verified)" or "(inferred)" and is listed in the Open questions. Loot facts also rest on 26 sections 2, 9.1, 11.1 and 11.4 (table layout, bare-number `rolls`, the block-drop and mob-death rules) |
| Citations | "17 section 4.12" is `docs/protocol/17-tools-weapons-and-combat.md` section 4.12; "standin section 4.7" is `docs/design/standin-content.md`; "README Part 7" is `docs/design/README.md`; "WT-22" is a Decision of `docs/design/world-types.md` |

Read first: `docs/design/README.md` Part 0 (rules R1 to R10), Part 4 (C3, C5, C6), Part 7 (decisions 3 to 7, 14, 18);
`docs/design/world-types.md` sections 4 to 7 and 10; `docs/protocol/04-registry-sync.md` sections 3 and 6;
`docs/protocol/23-registry-loading.md` sections 3, 6, 8.

---

## 0. Reader's map

The cobolcraft world type is the invented `cobolcraft:` content of `standin-content.md`, kept as content, run by the same
engines as the standard world type (README R2, C5, C6). Those engines look things up by standard names: a damage type
`minecraft:fall`, a chat type `minecraft:say_command`, a clock `minecraft:overworld`, a tag `minecraft:mineable/pickaxe`.
A world with no vanilla pack therefore needs those entries. This document writes them.

| Section | Content |
|---|---|
| 1 | How the core is represented, numbered and namespaced (Decisions CORE-1 to CORE-3) |
| 2 | The registry inventory: what is sent, how many entries, where the rows are |
| 3 | The rows of every synchronized registry the core holds |
| 4 | The tags, with the exact member lists and the Update Tags payload |
| 5 | The cobolcraft content in the standard schemas: blocks, items, tools, foods, mobs, loot, recipes, the starting kit, the crafting bench |
| 6 | Which shared engine reads which core entry |
| 7 | Worked examples (computed) |
| 8 | Validation: checkable facts |
| 9 | What other documents must change because of this one |
| | Open questions |

**Readiness.** Not every row below is implementation-ready. The rows in this table carry a value that was recalled, inferred
or invented and not read from a document, and they gate the vanilla-client decode of Registry Data (tier B) or this server's
own codec. They are not to be implemented as final until the clean-room read named in the right column has been done; before
that they are placeholders that may be built and tested only against this document, never against a vanilla client.

| Rows | Why not ready | Needed before it is final |
|---|---|---|
| `damage_type` key of the void type (3.6, CORE-12) | two documents read it as `out_of_world`, three give `fell_out_of_world`, no round has settled it | clean-room read of the key (Open question 1) |
| `damage_type` `message_id` of all 51 standard types (3.6, CORE-10) | invented; one read counter-example exists (`outsideBorder`) | clean-room read of the 51 values (Open question 2) |
| `chat_type` rows 0, 2, 3, 6, 7 (3.5): `chat.type.text`, narration of `msg` and `teammsg`, keys `team_msg_command_incoming` and `_outgoing` | recalled or inferred | clean-room read (Open question 3) |
| `enchantment` `efficiency` (3.7): the `effects` shape and the description key | inferred or recalled | clean-room read (Open questions 4, 11) |
| Food consume `animation` `eat` and `consume_seconds` 1.6 (5.4) | assumed | clean-room read (Open question 8) |
| `day` timeline (3.2) | exact only for the tracks 12 section 3.2 lists | clean-room read of `day.json` (Open question 6) |
| `monster_spawn_light_level` 0 (3.3) | a behavioural departure from the standard for vanilla spawn checks | operator decision (Open question 21) |

**Index of Decisions** (the text is in section order; this list is in number order): CORE-1, 2, 3 section 1; CORE-4 section 3.6;
CORE-5 section 3.1; CORE-6 section 3.2; CORE-7, 8 section 3.3; CORE-9 section 3.4; CORE-10, 11, 12 section 3.6; CORE-13 section
3.5; CORE-14 section 3.7; CORE-15 section 9; CORE-16 section 4; CORE-17, 18 section 5.1; CORE-19, 20 section 5.3; CORE-21 section
5.4; CORE-22 section 5.6; CORE-23 section 5.7; CORE-24 section 5.8; CORE-25 section 5.9; CORE-26 section 5.5; CORE-27 section
5.1 (break-time model); CORE-28 section 5.1 (cosmetic columns); CORE-29 section 5.5 (speed attribute).

Conventions. JSON is used to write rows because the standard schemas are JSON in a data pack and NBT on the wire
(04 section 6: booleans are Byte 0 or 1, colours are `"#RRGGBB"` strings). Identifiers with no colon are in `minecraft:`.
A tick is 1/20 s. "Hand" means the empty hand, tool speed 1.0.

---

## 1. Representation, numbering, namespaces

**Decision CORE-1 (the core is pack-shaped data held inside the program).** Every row of this document is a document in
the layout of a data pack (`data/<namespace>/<registry path>/<name>.json`, tags in
`data/<namespace>/tags/<registry path>/<name>.json`, 23 section 1), embedded in the program and decoded by the same codecs
and the same tag resolver as a pack (23 sections 3 and 6). No file is read from a directory for a cobolcraft world (22
section 8.3: the data pack stack is empty at level 1 and the generated data pack is not read). Reason: WT-14 and world-types
section 7.2 require one loader interface for both world types, so the engines read the cobolcraft rows exactly as they read
a pack's, and only the source differs.

**Decision CORE-2 (id order).** The numeric id of an entry is its position in Registry Data (04 section 4), and the server is
free to choose it. Two rules apply:

- `worldgen/biome` and `dimension_type` keep their stand-in order (biomes `minecraft:plains` 0, `cobolcraft:upland` 1,
  `cobolcraft:ash_flats` 2; dimension types `cobolcraft:surface` 0, `cobolcraft:sunless` 1), because 09 section 3.1, the
  wire fixtures and the chunk generator (standin section 5.2, 15.2) already use those numbers.
- Every other registry of the core takes the order of 23 section 3.4 (path first, then namespace, comparing
  UTF-16 code units, so `/` and `_` sort before letters). Reason: this is the order a pack-backed loader would produce, so
  an implementation that builds the core through the pack loader and one that writes tables get the same ids.

**Decision CORE-3 (namespaces).** Entries that name standard vocabulary keep their `minecraft:` key (README R1, C3;
world-types section 6.2): chat types, damage types, the world clock, timelines, the enchantment, tags. Content that
CobolCraft owns is `cobolcraft:`: the damage type `cobolcraft:hail`, the biomes `cobolcraft:upland` and
`cobolcraft:ash_flats`, the two dimension types, loot tables, recipes. A tag keeps its `minecraft:` key and lists
`cobolcraft:` values (WT-11). `minecraft:plains` stays as the compat biome (README S02, 04 section 3.2 item 6).

---

## 2. Registry inventory

The 32 synchronized registries in the order of 04 section 3. "Sent" is whether a Registry Data packet goes out (an empty
registry gets none, 04 section 3.2 item 5). The vanilla client's non-empty validators (04 section 3.2 item 4) concern the 13
variant registries only.

| # | Registry | Sent | Entries | Rows |
|---|---|---|---|---|
| 0 | `worldgen/biome` | yes | 3 | section 3.4 |
| 1 | `chat_type` | yes | 8 | section 3.5 |
| 2 | `trim_pattern` | no | 0 | none (no armor, no smithing in the content) |
| 3 | `trim_material` | no | 0 | none |
| 4 to 16 | `wolf_variant`, `wolf_sound_variant`, `pig_variant`, `pig_sound_variant`, `frog_variant`, `cat_variant`, `cat_sound_variant`, `cow_sound_variant`, `cow_variant`, `chicken_sound_variant`, `chicken_variant`, `zombie_nautilus_variant`, `painting_variant` | yes (13 packets) | 1 each: `cobolcraft:placeholder` | unchanged, standin section 4.5 |
| 17 | `sulfur_cube_archetype` | no | 0 | none |
| 18 | `dimension_type` | yes | 2 | section 3.3 |
| 19 | `damage_type` | yes | 52 | section 3.6 |
| 20 | `banner_pattern` | no | 0 | none |
| 21 | `enchantment` | yes | 1 | section 3.7 |
| 22 to 26 | `jukebox_song`, `instrument`, `test_environment`, `test_instance`, `dialog` | no | 0 | none |
| 27 | `world_clock` | yes | 1 | section 3.1 |
| 28 | `timeline` | yes | 2 | section 3.2 |
| 29 | `decorated_pot_pattern` | no | 0 | none |
| 30 | `block_transformer` | no | 0 | none (Decision CORE-15) |
| 31 | `worldgen/block_state_provider` | no | 0 | none |

Totals: **20 Registry Data packets and 82 entries** (3 biomes, 8 chat types, 13 variants, 2 dimension types, 52 damage
types, 1 enchantment, 1 world clock, 2 timelines). The stand-in sent 18 packets and 52 entries (standin section 4.2). 12
registries stay empty and send nothing.

Update Tags (04 section 1) is no longer empty: it carries tags for the static registries `block` and `item` and for the
synchronized registry `damage_type`, section 4.4.

The non-synchronized registries a cobolcraft world also loads (loot tables and recipes, the RELOADABLE layer of 23 section
2.2) are in section 5. No worldgen registry is loaded: the cobolcraft generator is code (standin section 5.2, 15.2).

---

## 3. The rows

### 3.1 `world_clock` (04 section 6)

| Id | Key | Data |
|---|---|---|
| 0 | `minecraft:overworld` | empty Compound |

**Decision CORE-5 (one clock, the standard key).** The stand-in clock `cobolcraft:daylight` and its 30000-tick day are
retired. The day is 24000 ticks and the clock is `minecraft:overworld` in both world types (README S38, C5; 12 section 3.2c).
Reason: shared rule. `minecraft:the_end` is not carried: no cobolcraft dimension uses it (33 section 3.1 says 26.3 ships
the two clocks; the second has no consumer here). One clock is shared by both dimensions; the `sunless` type names none
(section 3.3).

### 3.2 `timeline` (04 section 6, 12 section 3.2, 33 section 3.4)

Two entries, ids by CORE-2: `minecraft:day` 0, `minecraft:moon` 1.

**Decision CORE-6 (only the timelines and tracks that have a consumer here).** The vanilla set is `day`, `moon`,
`early_game` and `villager_schedule` (33 section 3.4). `early_game` feeds only `can_pillager_patrol_spawn` and
`villager_schedule` only the villager brain (19 section 22); neither feature exists in the cobolcraft content, so neither
timeline is carried. `day` carries every track that 12 section 3.2 lists plus the time markers of 16 section 4.5, and omits the
gameplay tracks whose consumers are absent (`monsters_burn`, `bees_stay_in_hive`, `cat_waking_up_gift_chance`,
`eyeblossom_open`, bed rules: no cobolcraft block or mob reads them; with the attribute default `false` or absent nothing
burns and nothing sleeps). `moon` carries the `moon_phase` track only (33 section 3.7), not the slime chance track (no
slimes). Reason: a track nobody reads is invented data. Dependency: the claim that the shared engines run on this `day` timeline holds only
for the tracks that 12 section 3.2 lists; Open question 6 asks for the check that `day` has no other rendering track. The `moon` timeline is carried so that the moon sprite shows its phase (12 section 3.4c) and local difficulty reads a
real phase (33 section 3.7).

**`data/minecraft/timeline/day.json`** (values: 12 section 3.2 and 3.2b, markers: 16 section 4.5, 33 section 3.3; the same-tick
pairs of the three angle tracks are the file order 12 section 3.2 gives):

```json
{
  "clock": "minecraft:overworld",
  "period_ticks": 24000,
  "time_markers": {
    "minecraft:day":      { "ticks": 1000,  "show_in_commands": true },
    "minecraft:noon":     { "ticks": 6000,  "show_in_commands": true },
    "minecraft:night":    { "ticks": 13000, "show_in_commands": true },
    "minecraft:midnight": { "ticks": 18000, "show_in_commands": true },
    "minecraft:wake_up_from_sleep": 0
  },
  "tracks": {
    "minecraft:visual/sky_color": { "modifier": "multiply", "keyframes": [
      {"ticks":133,"value":"#ffffff"},{"ticks":11867,"value":"#ffffff"},
      {"ticks":13670,"value":"#000000"},{"ticks":22330,"value":"#000000"} ] },
    "minecraft:visual/fog_color": { "modifier": "multiply", "keyframes": [
      {"ticks":133,"value":"#ffffff"},{"ticks":11867,"value":"#ffffff"},
      {"ticks":13670,"value":"#0f0f16"},{"ticks":22330,"value":"#0f0f16"} ] },
    "minecraft:visual/cloud_color": { "modifier": "multiply", "keyframes": [
      {"ticks":133,"value":"#ffffffff"},{"ticks":11867,"value":"#ffffffff"},
      {"ticks":13670,"value":"#ff191926"},{"ticks":22330,"value":"#ff191926"} ] },
    "minecraft:visual/sky_light_color": { "modifier": "multiply", "keyframes": [
      {"ticks":730,"value":"#ffffff"},{"ticks":11270,"value":"#ffffff"},
      {"ticks":13140,"value":"#7a7aff"},{"ticks":22860,"value":"#7a7aff"} ] },
    "minecraft:visual/sky_light_factor": { "modifier": "multiply", "keyframes": [
      {"ticks":730,"value":1.0},{"ticks":11270,"value":1.0},
      {"ticks":13140,"value":0.24},{"ticks":22860,"value":0.24} ] },
    "minecraft:visual/star_brightness": { "modifier": "maximum", "keyframes": [
      {"ticks":92,"value":0.037},{"ticks":627,"value":0.0},{"ticks":11373,"value":0.0},
      {"ticks":11732,"value":0.016},{"ticks":11959,"value":0.044},{"ticks":12399,"value":0.143},
      {"ticks":12729,"value":0.258},{"ticks":13228,"value":0.5},{"ticks":22772,"value":0.5},
      {"ticks":23032,"value":0.364},{"ticks":23356,"value":0.225},{"ticks":23758,"value":0.101} ] },
    "minecraft:visual/sun_angle": { "ease": { "cubic_bezier": [0.362, 0.241, 0.638, 0.759] }, "keyframes": [
      {"ticks":6000,"value":360.0},{"ticks":6000,"value":0.0} ] },
    "minecraft:visual/moon_angle": { "ease": { "cubic_bezier": [0.362, 0.241, 0.638, 0.759] }, "keyframes": [
      {"ticks":6000,"value":540.0},{"ticks":6000,"value":180.0} ] },
    "minecraft:visual/star_angle": { "ease": { "cubic_bezier": [0.362, 0.241, 0.638, 0.759] }, "keyframes": [
      {"ticks":6000,"value":360.0},{"ticks":6000,"value":0.0} ] },
    "minecraft:visual/sunrise_sunset_color": { "keyframes": [
      {"ticks":71,"value":"#5fefa333"},{"ticks":310,"value":"#29f5ba33"},{"ticks":565,"value":"#06fbd433"},
      {"ticks":730,"value":"#00ffe533"},{"ticks":11270,"value":"#00ffe533"},{"ticks":11397,"value":"#04fcd833"},
      {"ticks":11522,"value":"#0ff9cb33"},{"ticks":11690,"value":"#29f5ba33"},{"ticks":11929,"value":"#5fefa333"},
      {"ticks":12243,"value":"#b1e78733"},{"ticks":12358,"value":"#cce47e33"},{"ticks":12512,"value":"#e9e07233"},
      {"ticks":12613,"value":"#f6dd6b33"},{"ticks":12732,"value":"#feda6333"},{"ticks":12841,"value":"#fed75c33"},
      {"ticks":13035,"value":"#ecd25133"},{"ticks":13252,"value":"#c1cc4733"},{"ticks":13775,"value":"#36be3733"},
      {"ticks":13888,"value":"#1fbb3533"},{"ticks":14039,"value":"#09b73333"},{"ticks":14192,"value":"#00b33333"},
      {"ticks":21807,"value":"#00b23333"},{"ticks":21961,"value":"#09b73333"},{"ticks":22112,"value":"#1fbb3533"},
      {"ticks":22225,"value":"#36be3733"},{"ticks":22748,"value":"#c1cc4733"},{"ticks":22965,"value":"#ecd25133"},
      {"ticks":23159,"value":"#fed75c33"},{"ticks":23272,"value":"#feda6333"},{"ticks":23488,"value":"#e9e07233"},
      {"ticks":23642,"value":"#cce47e33"},{"ticks":23757,"value":"#b1e78733"} ] },
    "minecraft:gameplay/sky_light_level": { "modifier": "multiply", "keyframes": [
      {"ticks":133,"value":1.0},{"ticks":11867,"value":1.0},
      {"ticks":13670,"value":0.26666668},{"ticks":22330,"value":0.26666668} ] }
  }
}
```

Notes on the file. The modifier and the colour form follow 23 sections 8.2 to 8.6 (`multiply` on a colour takes the same
colour string; an ARGB track takes `"#AARRGGBB"`). The modifier `override` is the default and is left out. `sky_light_level`
is not positional but is syncable, so it is allowed in a timeline and is sent (23 section 8.3). The marker names are unique per
clock (23 section 9.2): `day`, `noon`, `night`, `midnight`, `wake_up_from_sleep`. `roll_village_siege` (16 section 4.5) is not
carried (no village, 44 section 1.7). Keyframe ticks are inside `[0, period]` and at most two share a tick (04 section 6).

**`data/minecraft/timeline/moon.json`** (33 section 3.7: period 192000, one keyframe every 24000 ticks, the value held until
the next keyframe because the type is an enum, 33 section 3.4 table):

```json
{
  "clock": "minecraft:overworld",
  "period_ticks": 192000,
  "tracks": {
    "minecraft:visual/moon_phase": { "keyframes": [
      {"ticks":0,"value":"full_moon"},       {"ticks":24000,"value":"waning_gibbous"},
      {"ticks":48000,"value":"third_quarter"},{"ticks":72000,"value":"waning_crescent"},
      {"ticks":96000,"value":"new_moon"},    {"ticks":120000,"value":"waxing_crescent"},
      {"ticks":144000,"value":"first_quarter"},{"ticks":168000,"value":"waxing_gibbous"} ] }
  }
}
```

### 3.3 `dimension_type` (04 section 6, standin section 4.6, 12 section 3.1)

Two entries, ids `cobolcraft:surface` 0 and `cobolcraft:sunless` 1 (CORE-2). The geometry rows are the stand-in's; the sky,
time and attribute rows follow the shared rules (README S36). Where this table differs from standin section 4.6, the right
column says why.

| Field | `cobolcraft:surface` (0) | `cobolcraft:sunless` (1) | Source or reason |
|---|---|---|---|
| `has_fixed_time` | absent (false) | true | standin section 4.6 |
| `has_skylight` | true | false | standin section 4.6 |
| `has_ceiling` | false | false | standin section 4.6 |
| `has_ender_dragon_fight` | false | false | required field, no meaning here |
| `coordinate_scale` | 1.0 | 1.0 | travel keeps x and z (standin section 15.5) |
| `min_y` | 0 | 0 | standin section 4.6 |
| `height` | 256 | 128 | standin section 4.6 |
| `logical_height` | 256 | 128 | standin section 4.6 |
| `infiniburn` | `[]` | `[]` | an empty list names no tag, so no tag file is required (23 section 9.4); no block burns forever |
| `ambient_light` | 0.0 | 0.0 | standin section 4.6; the renderer reads `ambient_light_color` instead (12 section 3.1) |
| `monster_spawn_light_level` | 0 (constant) | 0 (constant) | 0 (constant): the stand-in spawn cycle is the only spawner and no biome carries `natural_mob_spawns` (Decision CORE-26). The field also governs every vanilla-engine spawn check (the spawner block, `/summon` spawn checks), not only natural spawning; with 0 such a check passes at any light level, a departure from the standard (Open question 21) |
| `monster_spawn_block_light_limit` | 0 | 0 | same |
| `skybox` | absent (`overworld`) | `none` | standin section 4.6 |
| `cardinal_light` | absent (`default`) | absent (`default`) | standin section 4.6 |
| `attributes` | see below | see below | 12 section 3.1; standin section 15.3 |
| `timelines` | `["minecraft:day","minecraft:moon"]` | absent | Decision CORE-7 |
| `default_clock` | `"minecraft:overworld"` | absent | section 3.1; a fixed-time dimension has no clock (standin section 4.6) |

**`cobolcraft:surface` attributes** (the overworld map of 12 section 3.1, unchanged):

```json
"attributes": {
  "minecraft:visual/ambient_light_color": "#0a0a0a",
  "minecraft:visual/cloud_color": "#ccffffff",
  "minecraft:visual/cloud_height": 192.33,
  "minecraft:visual/fog_color": "#c0d8ff",
  "minecraft:visual/sky_color": "#78a7ff"
}
```

**`cobolcraft:sunless` attributes:**

```json
"attributes": {
  "minecraft:visual/sky_color": "#100c12",
  "minecraft:visual/fog_color": "#100c12",
  "minecraft:visual/ambient_light_color": "#1a1a1a",
  "minecraft:visual/sky_light_factor": 0.0
}
```

**Decision CORE-7 (the surface timelines are an explicit list).** `timelines` holds the two ids instead of the vanilla tag
`in_overworld` (33 section 3.4: `universal`, `day`, `moon`, `early_game`). Reason: the tag also pulls `early_game` and the
universal group, which are not carried (CORE-6); a list needs no tag file and cannot leave an unbound tag (23 section 3.6).

**Decision CORE-8 (the sunless sky in standard attributes).** The stand-in draws a fixed sky colour `#100C12`, no sun or
moon, no weather (standin section 15.3). In the standard attribute system this is `skybox` `none` (draws nothing, 12 section
3.4), `sky_color` and `fog_color` both `#100c12` (the horizon fog fades to the sky colour, 12 section 3.3, so they must
match or a seam shows), and `sky_light_factor` 0.0 (the Nether's value for a dimension with no sky light, 12 section 3.1).
`ambient_light_color` `#1a1a1a` is the byte closest to the stand-in's brightness floor of 0.1 (standin section 4.6: 26 / 255
= 0.102); the overworld's `#0a0a0a` would be darker than the floor the stand-in promised. A dimension with no skylight
cannot have weather (33 section 4.1: `canHaveWeather` needs sky light), so no weather layer applies, as the stand-in required
(standin section 14.2).

Derived geometry (06 sections 1, 3.1, 7), unchanged from standin section 4.6: `surface` has 16 block sections, 18 light
sections, heightmap entries of `ceillog2(257) = 9` bits (7 per Long, 37 Longs); `sunless` has 8 block sections, 10 light
sections, `ceillog2(129) = 8` bits (8 per Long, 32 Longs).

### 3.4 `worldgen/biome` (04 section 6, standin section 4.3)

Three entries, ids by CORE-2 (the stand-in order).

```json
// id 0: data/minecraft/worldgen/biome/plains.json   (the cobolcraft "lowland")
{ "has_precipitation": true,  "temperature": 0.6, "downfall": 0.4,
  "effects": { "water_color": "#3A6EA5", "grass_color": "#4F8F3A", "foliage_color": "#4F8F3A" } }
// id 1: data/cobolcraft/worldgen/biome/upland.json
{ "has_precipitation": true,  "temperature": 0.3, "downfall": 0.2,
  "effects": { "water_color": "#2F5C8C", "grass_color": "#6B9A55", "foliage_color": "#6B9A55" } }
// id 2: data/cobolcraft/worldgen/biome/ash_flats.json
{ "has_precipitation": false, "temperature": 1.4, "downfall": 0.0,
  "effects": { "water_color": "#3A2F2A", "grass_color": "#5A4A40", "foliage_color": "#5A4A40" } }
```

`temperature_modifier`, `dry_foliage_color`, `grass_color_modifier` and `attributes` are absent (defaults).

**Decision CORE-9 (the lowland keeps the stand-in numbers).** `minecraft:plains` is the lowland of `cobolcraft:main` and
keeps temperature 0.6 and downfall 0.4, not the standard plains 0.8 and 0.4 (10 section 7.8). Reason: README S33 says keep; the
value matters only through the rain or snow test `temperature >= 0.15` (33 section 4.5), which 0.6, 0.3 and 1.4 all pass.
The temperature is lowered with height, so the answer depends on `y` (formula of 33 section 4.5, sea level 48 of standin
section 5.1, noise term 0). Upland (temperature 0.3) turns to snow above about `y` 185, which a player can reach (the surface
dimension is 256 high, `y` up to 255); the standard plains value 0.8 would not. Lowland (0.6) never snows: it would need `y`
above 425, since 0.6 - (y - 65) x 0.00125 < 0.15 gives y > 425, and the build limit is 255. `ash_flats` has no precipitation.
The upland snow line near 185 is a behavioural difference from the stand-in (which had no snow) and is accepted here. The colours are the
built-in pack's art. No biome carries
`gameplay/natural_mob_spawns`, so the standard natural spawning engine (18 section 6) spawns nothing here and the stand-in
spawn cycle (standin section 12.4) is the only spawner (CORE-26).

### 3.5 `chat_type` (04 section 6, 16 section 8)

Eight entries, ids by CORE-2: the sort puts `cobolcraft:say` (path `say`) before `minecraft:say_command` (path
`say_command`).

| Id | Key | `chat` translation_key, parameters, style | `narration` translation_key, parameters | Source |
|---|---|---|---|---|
| 0 | `minecraft:chat` | `chat.type.text`, [sender, content], no style | `chat.type.text.narrate`, [sender, content] | player chat (README decision 7); the key `chat.type.text` is (recalled, not verified), Open question 3 |
| 1 | `minecraft:emote_command` | `chat.type.emote`, [sender, content] | `chat.type.emote`, [sender, content] | 16 section 8.1 ("narration the same key") |
| 2 | `minecraft:msg_command_incoming` | `commands.message.display.incoming`, [sender, content], style `{"color":"gray","italic":true}` | `chat.type.text.narrate`, [sender, content] | 16 section 8.3 (narration parameters inferred) |
| 3 | `minecraft:msg_command_outgoing` | `commands.message.display.outgoing`, [target, content], style `{"color":"gray","italic":true}` | `chat.type.text.narrate`, [sender, content] | 16 section 8.3 (narration parameters inferred) |
| 4 | `cobolcraft:say` | `cobolcraft.chat.say`, [sender, content] | `cobolcraft.chat.say.narrate`, [sender, content] | standin section 4.4, retained |
| 5 | `minecraft:say_command` | `chat.type.announcement`, [sender, content] | `chat.type.text.narrate`, [sender, content] | 16 section 8.1 |
| 6 | `minecraft:team_msg_command_incoming` | `chat.type.team.text`, [target, sender, content] | `chat.type.text.narrate`, [sender, content] | 16 section 8.4 (the registry key is (recalled, not verified)) |
| 7 | `minecraft:team_msg_command_outgoing` | `chat.type.team.sent`, [target, sender, content] | `chat.type.text.narrate`, [sender, content] | 16 section 8.4 (the registry key is (recalled, not verified)) |

For the team rows, `target` is the team name component (16 section 8.4: "%s <%s> %s": team name, sender, content).

**Decision CORE-13 (the standard chat types, plus the stand-in one).** Player chat and the commands `say`, `me`, `msg`,
`teammsg` use the standard types in both world types (README decision 7; 16 section 8). `cobolcraft:say` stays because
README S34 says to keep it; no shared engine sends it, so it costs one row and breaks nothing. Reason: S34, and removing it
would change 09 section 3.1 for no gain.

### 3.6 `damage_type` (04 section 6, 17 section 4.12)

52 entries: the 51 standard types and `cobolcraft:hail`. Ids by CORE-2 (sorted by path). The columns are the schema of
04 section 6: `message_id`, `scaling`, `exhaustion`, `effects`, `death_message_type`. Exhaustion, scaling, `effects` and
`death_message_type` are the values of 17 section 4.12 (groups A to E and the separate attribute list). Legend for the group
column: A no exhaustion; B always scaling, no exhaustion; C always scaling, exhaustion 0.1; D burning types; E other 0.1
types (17 section 4.12). `scaling` is written `always` or `living` (= `when_caused_by_living_non_player`).

| Id | Key | Group | message_id | scaling | exhaustion | effects | death_message_type |
|---|---|---|---|---|---|---|---|
| 0 | `minecraft:arrow` | E | `arrow` | living | 0.1 | hurt (default) | default |
| 1 | `minecraft:bad_respawn_point` | C | `bad_respawn_point` | always | 0.1 | hurt (default) | intentional_game_design |
| 2 | `minecraft:cactus` | E | `cactus` | living | 0.1 | hurt (default) | default |
| 3 | `minecraft:campfire` | D | `campfire` | living | 0.1 | burning | default |
| 4 | `minecraft:cramming` | A | `cramming` | living | 0.0 | hurt (default) | default |
| 5 | `minecraft:dragon_breath` | A | `dragon_breath` | living | 0.0 | hurt (default) | default |
| 6 | `minecraft:drown` | A | `drown` | living | 0.0 | drowning | default |
| 7 | `minecraft:dry_out` | E | `dry_out` | living | 0.1 | hurt (default) | default |
| 8 | `minecraft:ender_pearl` | A | `ender_pearl` | living | 0.0 | hurt (default) | fall_variants |
| 9 | `minecraft:explosion` | C | `explosion` | always | 0.1 | hurt (default) | default |
| 10 | `minecraft:fall` | A | `fall` | living | 0.0 | hurt (default) | fall_variants |
| 11 | `minecraft:falling_anvil` | E | `falling_anvil` | living | 0.1 | hurt (default) | default |
| 12 | `minecraft:falling_block` | E | `falling_block` | living | 0.1 | hurt (default) | default |
| 13 | `minecraft:falling_stalactite` | E | `falling_stalactite` | living | 0.1 | hurt (default) | default |
| 14 | `minecraft:fireball` | D | `fireball` | living | 0.1 | burning | default |
| 15 | `minecraft:fireworks` | E | `fireworks` | living | 0.1 | hurt (default) | default |
| 16 | `minecraft:fly_into_wall` | A | `fly_into_wall` | living | 0.0 | hurt (default) | default |
| 17 | `minecraft:freeze` | A | `freeze` | living | 0.0 | freezing | default |
| 18 | `minecraft:generic` | A | `generic` | living | 0.0 | hurt (default) | default |
| 19 | `minecraft:generic_kill` | A | `generic_kill` | living | 0.0 | hurt (default) | default |
| 20 | `cobolcraft:hail` | E (cobolcraft) | `hail` | living | 0.1 | hurt (default) | default |
| 21 | `minecraft:hot_floor` | D | `hot_floor` | living | 0.1 | burning | default |
| 22 | `minecraft:in_fire` | D | `in_fire` | living | 0.1 | burning | default |
| 23 | `minecraft:in_wall` | A | `in_wall` | living | 0.0 | hurt (default) | default |
| 24 | `minecraft:indirect_magic` | A | `indirect_magic` | living | 0.0 | hurt (default) | default |
| 25 | `minecraft:lava` | D | `lava` | living | 0.1 | burning | default |
| 26 | `minecraft:lightning_bolt` | E | `lightning_bolt` | living | 0.1 | hurt (default) | default |
| 27 | `minecraft:mace_smash` | E | `mace_smash` | living | 0.1 | hurt (default) | default |
| 28 | `minecraft:magic` | A | `magic` | living | 0.0 | hurt (default) | default |
| 29 | `minecraft:mob_attack` | E | `mob_attack` | living | 0.1 | hurt (default) | default |
| 30 | `minecraft:mob_attack_no_aggro` | E | `mob_attack_no_aggro` | living | 0.1 | hurt (default) | default |
| 31 | `minecraft:mob_projectile` | E | `mob_projectile` | living | 0.1 | hurt (default) | default |
| 32 | `minecraft:on_fire` | A | `on_fire` | living | 0.0 | burning | default |
| 33 | `minecraft:out_of_world` | A | `out_of_world` | living | 0.0 | hurt (default) | default |
| 34 | `minecraft:outside_border` | A | `outsideBorder` (read, 33 section 7.5) | living | 0.0 | hurt (default) | default |
| 35 | `minecraft:player_attack` | E | `player_attack` | living | 0.1 | hurt (default) | default |
| 36 | `minecraft:player_explosion` | C | `player_explosion` | always | 0.1 | hurt (default) | default |
| 37 | `minecraft:sonic_boom` | B | `sonic_boom` | always | 0.0 | hurt (default) | default |
| 38 | `minecraft:spear` | E | `spear` | living | 0.1 | hurt (default) | default |
| 39 | `minecraft:spit` | E | `spit` | living | 0.1 | hurt (default) | default |
| 40 | `minecraft:stalagmite` | A | `stalagmite` | living | 0.0 | hurt (default) | default |
| 41 | `minecraft:starve` | A | `starve` | living | 0.0 | hurt (default) | default |
| 42 | `minecraft:sting` | E | `sting` | living | 0.1 | hurt (default) | default |
| 43 | `minecraft:sulfur_cube_hot` | D | `sulfur_cube_hot` | living | 0.1 | burning | default |
| 44 | `minecraft:sweet_berry_bush` | E | `sweet_berry_bush` | living | 0.1 | poking | default |
| 45 | `minecraft:thorns` | E | `thorns` | living | 0.1 | thorns | default |
| 46 | `minecraft:thrown` | E | `thrown` | living | 0.1 | hurt (default) | default |
| 47 | `minecraft:trident` | E | `trident` | living | 0.1 | hurt (default) | default |
| 48 | `minecraft:unattributed_fireball` | D | `unattributed_fireball` | living | 0.1 | burning | default |
| 49 | `minecraft:wind_charge` | E | `wind_charge` | living | 0.1 | hurt (default) | default |
| 50 | `minecraft:wither` | A | `wither` | living | 0.0 | hurt (default) | default |
| 51 | `minecraft:wither_skull` | E | `wither_skull` | living | 0.1 | hurt (default) | default |

**Decision CORE-10 (`message_id` is the key path, except where a document reads otherwise; provisional).** 04 section 6 makes
`message_id` a required String. The core sets `message_id` to the path of the key, so a death message key is
`death.attack.<path>` (and `death.attack.<path>.player` for an attack by a player), with one exception that is read: 33
section 7.5 gives the death message of `outside_border` as `death.attack.outsideBorder`, so its `message_id` is `outsideBorder`
(camel case), which is not the key path. That one datum shows the real values are not uniformly the key path, so the other 50
values below are invented by this decision, and some are probably wrong in the same way (candidates: `fly_into_wall`, `in_fire`,
`dragon_breath` and other multi-word paths; this is a suspicion, not a read fact). The values affect no rule but are not harmless on
the wire: a vanilla client builds the death message key from `message_id`, so a wrong value gives a wrong translation key.
**Precondition:** the 51 standard `message_id` values must be read from the jar by a clean-room round before the
`damage_type` rows are final or sent to a vanilla client (Open question 2). Until then the 50 invented values are placeholders.

**Decision CORE-12 (the void type key is unresolved; the table carries `out_of_world` provisionally).** The documents disagree,
and the evidence does not favour either side by count. For `out_of_world`: 17 section 4.12 (the type name and the tag lists,
which it says are "as listed in the jar"), and 41 line 329 (which says the contents `bypasses_invulnerability` =
`out_of_world`, `generic_kill` were "read from `data/minecraft/tags/damage_type/`"), so two documents report the data key and
the tag membership. For `fell_out_of_world`: 04 section 3.2 item 6, 18 section 3 and standin section 4.7 (which says "checked
against the jar" and that an earlier draft's `out_of_world` was corrected). Those three describe the `DamageSources` code, so they
may have transcribed the name of a code constant instead of the data key; that is a hypothesis, not a read fact, and it is not
used here. No document says which reading is the data file name. This document brings no new evidence and does not decide, and it
does not lean to either key. The row is kept as `out_of_world` only because the ids, tag lists and examples below were computed
with it, and **the document is not accepted, and validation item 3 of section 8 is not satisfied, until a clean-room round reads
the key from the jar** (Open question 1) or the operator records a decision. If the key is `fell_out_of_world`, apply this exact change: the row becomes id 14 (the sort puts the path
`fell_out_of_world` after `falling_stalactite` 13 and before `fireball`); the old ids 14 to 32 (`fireball` to `on_fire`) each
rise by one; id 33 is vacated; ids 34 to 51 are unchanged; every id list of sections 4.3, 4.4 and 7 that mentions an id from
14 to 33 changes the same way. The alternative is to carry both keys (53 damage types, 83 entries, `damage_type` ids shifted,
both keys in `bypasses_armor`, `bypasses_invulnerability`, `bypasses_resistance`, `bypasses_shield` and `no_knockback`); it
is not chosen because a second key with no consumer is invented data. A wrong
key fails the vanilla client's configuration check (tier B) and breaks the void rule.

**Decision CORE-11 (`cobolcraft:hail`, modelled on the cactus).** README decision 5 keeps `cobolcraft:hail` as the damage
source of the hailstorm skin (standin section 14.6: 1 damage every 80 ticks to an exposed entity). It is group E, like
`cactus` (an environmental source with no attacker), with exhaustion 0.1 and `scaling` `when_caused_by_living_non_player`.
It is a member of `no_knockback` and `bypasses_shield` (section 4.3), as `cactus` is: it has no cause position and no
direction. It is in no other tag, so armor applies. Reason: a type must be in the tags that its nature implies, and the
only standard type with the same nature is `cactus`. The retired stand-in types are `cobolcraft:generic`, `impact`,
`below_world` (README S37: only where a cobolcraft rule uses them; none does: the void rule uses `out_of_world`, and the
baseplate stops any fall below the world), `mob_attack`, `player_attack` and `starvation` (replaced by `minecraft:mob_attack`,
`player_attack` and `starve`) (Decision CORE-4).

**Decision CORE-4 (the 25 compat keys carry the standard values).** The vanilla client's `DamageSources` looks up 25 keys at
once and 24 more lazily (04 section 3.2 item 6). All 49 are among the 51 standard rows above, now with the standard values
instead of the stand-in's placeholder `never` and exhaustion 0.0 (README S37). No row uses `scaling` `never`: 17 section 4.12
says no standard type does.

### 3.7 `enchantment` (04 section 6, 17 section 6)

**Decision CORE-14 (one enchantment).** The core carries `minecraft:efficiency` only. Reason, by consumer (17 section 6.3):

| Enchantment | Consumer in the cobolcraft content | Carried |
|---|---|---|
| `efficiency` | the break formula (13 section 2.1) on the two cobolcraft tools | yes |
| `silk_touch`, `fortune` | block loot conditions and functions (17 section 3.16, 11 section 9.2); every cobolcraft block drops itself, so neither changes any result | no |
| `looting` | `enchanted_count_increase` in mob loot (17 section 4.10); the stand-in yields are fixed counts | no |
| `unbreaking`, `mending` | durability (17 section 5); the cobolcraft tools have none (CORE-19) | no |
| `sharpness`, `knockback` and the weapon set | no cobolcraft weapon beyond the two tools, which are mining tools with an attack value | no |
| armor, bow, trident, mace, fishing sets | no such item | no |

An enchantment that is not in the registry cannot be given by `/enchant`, so the question "does this enchantment do
anything here" never arises. README S39 and C3 say "minimal entries"; one is the minimal consumer-backed set. Adding a
row later needs only a file and, if it has a consumer, the item tag it supports.

Row (ids by CORE-2: `minecraft:efficiency` is id 0). The fields are the table of 17 section 6.2; the `effects` value is the
fact of 13 section 2.1 and 17 section 6.3 ("attribute `mining_efficiency` +(L x L + 1)", `levels_squared`, added 1.0,
operation `add_value`), written in the shape of the `attribute_modifiers` schema of 04 section 6 (the shape is inferred,
Open question 4). The `effects` value is the one field of the one enchantment that no rule reads and that is only inferred, and
13 section 2.1 depends on its meaning: a wrong shape is not a wrong rule but a failure of the vanilla client's Registry Data
decode (tier B) and of this server's own decoder:

```json
// data/minecraft/enchantment/efficiency.json
{
  "description": { "translate": "enchantment.minecraft.efficiency" },
  "supported_items": "#minecraft:enchantable/mining",
  "weight": 10,
  "max_level": 5,
  "min_cost": { "base": 1,  "per_level_above_first": 10 },
  "max_cost": { "base": 51, "per_level_above_first": 10 },
  "anvil_cost": 1,
  "slots": ["mainhand"],
  "effects": {
    "minecraft:attributes": [
      { "attribute": "minecraft:mining_efficiency",
        "id": "minecraft:enchantment.efficiency",
        "operation": "add_value",
        "amount": { "type": "minecraft:levels_squared", "added": 1.0 } }
    ]
  }
}
```

`primary_items` is absent (defaults to the supported set) and there is no `exclusive_set` (17 section 6.2). The item tag it
names is in section 4.2. The description key `enchantment.minecraft.efficiency` is (recalled, not verified); the built-in
language file must carry it (Open question 11). The effect component key `attributes` is read (46 section 13.1, id 24).

### 3.8 What stays as it was

The 13 variant registries keep their one entry `cobolcraft:placeholder` (standin section 4.5), because the vanilla client's
non-empty validators need them (04 section 3.2 item 4). The 12 registries of section 2 marked "none" send nothing. README R8 says the cobolcraft world type is not playable by a
vanilla client; the vanilla-client checks reasoned about here (the validators of 04 section 3.2, Open question 17) are
configuration-phase validation only: they decide whether a vanilla client gets through the configuration phase (tier B, C1), not
whether it can play.

---

## 4. Tags

**Decision CORE-16 (which tags the core defines).** A tag file exists in the core when (a) a core entry or a cobolcraft item
or block names it, (b) a shared rule reads it for content that the cobolcraft type has, and (c) the document that gives
the rule states the meaning of the tag (not "inferred"). One more group is added with its meaning marked (inferred)
because dropping it would silently change a rule (section 4.1, second table). Tags with no member in the cobolcraft content
are not defined (an absent tag reads as empty, 23 section 5.2; only a tag that a synchronized entry names must exist, 23
section 3.6, and the core's entries name one, the item tag of section 4.2). Reason: a tag nobody reads is invented data, and one that
is missing is silent where a rule needs a member.

### 4.1 Block tags (registry `minecraft:block`)

Firm (24 section 12.2 states the use):

| Tag | Members | Use |
|---|---|---|
| `minecraft:mineable/pickaxe` | `cobolcraft:greystone`, `cobolcraft:cardstack`, `cobolcraft:ledger_tile`, `cobolcraft:slag`, `cobolcraft:crafting_bench` | the `pry_bar` rule block set (section 5.3); the "hard class" of standin section 2 |
| `minecraft:mineable/shovel` | `cobolcraft:loam`, `cobolcraft:turf`, `cobolcraft:grit` | the `trowel` rule block set; the "soft class" |

Departure from README C3 and decision 4 (the shared mining rules read `mineable/*` and the tier tags; decision 4 says "standard
properties (hardness, mineable tag, tier)"): the `mineable/*` tags are carried, the tier tags are not (CORE-17, Open question 13).

Not defined: `mineable/axe`, `mineable/hoe` (no cobolcraft tool names them), `needs_stone_tool`, `needs_iron_tool`,
`needs_diamond_tool` and the seven `incorrect_for_*_tool` tags (no cobolcraft block requires a correct tool, CORE-17, and no
cobolcraft tool has a deny-drops rule).

Proposed (24 section 12.2 marks the use "(inferred)": the consumers were not read, Open question 5):

| Tag | Members | Why it is proposed |
|---|---|---|
| `minecraft:replaceable` | `cobolcraft:void` | placement may overwrite only `void` (standin section 1.3) |
| `minecraft:air` | `cobolcraft:void` | the grouping tag read by name in world rules (24 section 12.2) |
| `minecraft:causes_suffocation` | `cobolcraft:baseplate`, `greystone`, `loam`, `turf`, `grit`, `cardstack`, `glowtube`, `ledger_tile`, `goto_pad`, `slag`, `crafting_bench` (all `cobolcraft:`) | the default `isSuffocating` predicate is "in this tag and a full collision cube" (24 section 4.1); every full cube suffocates except `lucite`, whose row carries `suffocating:never` (section 5.1) |
| `minecraft:blocks_motion`, `blocks_motion_no_leaves`, `blocks_motion_in_heightmap`, `blocks_motion_in_heightmap_no_leaves` | the 11 blocks of `causes_suffocation` plus `cobolcraft:lucite`, that is the 12 blocks other than `void` | suffocation and the motion-blocking heightmaps; the stand-in heightmaps count every non-void block (standin section 5.2); there are no leaves, so the four lists are equal |

### 4.2 Item tags (registry `minecraft:item`)

| Tag | Members | Use |
|---|---|---|
| `minecraft:enchantable/mining` | `cobolcraft:pry_bar`, `cobolcraft:trowel` | `supported_items` of `efficiency` (17 section 6.2, 6.1) |

### 4.3 Damage type tags (registry `minecraft:damage_type`)

The 20 tags of 17 section 4.12, with the same members, plus `cobolcraft:hail` in `no_knockback` and `bypasses_shield`
(CORE-11). All 20 are carried because every one is read by the damage pipeline of 17 sections 4.4 and 4.5, and the type set
is complete. `bypasses_cooldown` is empty and is sent empty (17 section 4.12).

| Tag (`minecraft:damage_type`) | Members | Ids (the Update Tags entries, in this order) |
|---|---|---|
| `always_hurts_ender_dragons` | fireworks, explosion, player_explosion, bad_respawn_point | 15, 9, 36, 1 |
| `bypasses_armor` | on_fire, in_wall, cramming, drown, fly_into_wall, generic, wither, dragon_breath, starve, fall, ender_pearl, freeze, stalagmite, magic, indirect_magic, out_of_world, generic_kill, sonic_boom, outside_border | 32, 23, 4, 6, 16, 18, 50, 5, 41, 10, 8, 17, 40, 28, 24, 33, 19, 37, 34 |
| `bypasses_cooldown` | (empty) | (none) |
| `bypasses_effects` | starve | 41 |
| `bypasses_enchantments` | sonic_boom | 37 |
| `bypasses_invulnerability` | out_of_world, generic_kill | 33, 19 |
| `bypasses_resistance` | out_of_world, generic_kill | 33, 19 |
| `bypasses_shield` | on_fire, in_wall, cramming, drown, fly_into_wall, generic, wither, dragon_breath, starve, fall, ender_pearl, freeze, stalagmite, magic, indirect_magic, out_of_world, generic_kill, sonic_boom, outside_border, cactus, campfire, dry_out, falling_anvil, falling_stalactite, hot_floor, sulfur_cube_hot, in_fire, lava, lightning_bolt, sweet_berry_bush, hail | 32, 23, 4, 6, 16, 18, 50, 5, 41, 10, 8, 17, 40, 28, 24, 33, 19, 37, 34, 2, 3, 7, 11, 13, 21, 43, 22, 25, 26, 44, 20 |
| `damages_helmet` | falling_anvil, falling_block, falling_stalactite | 11, 12, 13 |
| `is_drowning` | drown | 6 |
| `is_explosion` | fireworks, explosion, player_explosion, bad_respawn_point | 15, 9, 36, 1 |
| `is_fall` | fall, ender_pearl, stalagmite | 10, 8, 40 |
| `is_fire` | in_fire, campfire, on_fire, lava, hot_floor, sulfur_cube_hot, unattributed_fireball, fireball | 22, 3, 32, 25, 21, 43, 48, 14 |
| `is_freezing` | freeze | 17 |
| `is_lightning` | lightning_bolt | 26 |
| `is_player_attack` | player_attack, spear, mace_smash | 35, 38, 27 |
| `is_projectile` | arrow, trident, mob_projectile, unattributed_fireball, fireball, wither_skull, thrown, wind_charge | 0, 47, 31, 48, 14, 51, 46, 49 |
| `no_anger` | mob_attack_no_aggro | 30 |
| `no_impact` | drown | 6 |
| `no_knockback` | explosion, player_explosion, bad_respawn_point, in_fire, lightning_bolt, on_fire, lava, hot_floor, sulfur_cube_hot, in_wall, cramming, drown, starve, cactus, fall, ender_pearl, fly_into_wall, out_of_world, generic, magic, wither, dragon_breath, dry_out, sweet_berry_bush, freeze, stalagmite, outside_border, generic_kill, campfire, spear, hail | 9, 36, 1, 22, 26, 32, 25, 21, 43, 23, 4, 6, 41, 2, 10, 8, 16, 33, 18, 28, 50, 5, 7, 44, 17, 40, 34, 19, 3, 38, 20 |

The tag files write `bypasses_shield` as `"#minecraft:bypasses_armor"` followed by the 12 other keys; the table shows the
flattened result, which is what Update Tags sends (04 section 1, 23 section 6.4).

### 4.4 The Update Tags payload

Registries in this order: `minecraft:block`, `minecraft:item`, `minecraft:damage_type`. Ids of static registries are the
cobolcraft numbering of standin sections 1.1 (block ids), 1.2 (state ids) and 2 (item ids) with the bench appended (section 5.1, 5.2); ids of `damage_type` are
section 3.6.

| Registry | Tag | Entries (numeric ids) |
|---|---|---|
| `minecraft:block` | `minecraft:mineable/pickaxe` | 2, 6, 9, 11, 12 |
| `minecraft:block` | `minecraft:mineable/shovel` | 3, 4, 5 |
| `minecraft:block` | `minecraft:replaceable` | 0 |
| `minecraft:block` | `minecraft:air` | 0 |
| `minecraft:block` | `minecraft:causes_suffocation` | 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12 |
| `minecraft:block` | `minecraft:blocks_motion` and the three `blocks_motion_*` tags | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 (each tag) |
| `minecraft:item` | `minecraft:enchantable/mining` | 10, 11 |
| `minecraft:damage_type` | the 20 tags of section 4.3 | the id column of section 4.3 |

(The block ids are the block ids of section 5.1. A block tag lists block ids, not state ids; `cardstack` is block 6 and
`glowtube` block 8 whatever their state.)

---

## 5. The cobolcraft content in the standard schemas

README Part 7 decisions 3 and 4: the content is unchanged except for the crafting bench; break times become standard
properties and tags; the two tools become tool components.

### 5.1 Blocks

Thirteen blocks (the stand-in twelve and `cobolcraft:crafting_bench`), 19 block states. The bench is **appended**
(WT-12): block id 12, state id 18; ids 0 to 11 and states 0 to 17 are unchanged (standin section 1.2). `ceillog2(19)` is
5, so the global block palette stays 5 bits wide (06 section 5.3).

The row table uses the columns of 24 section 7. Class names: `Block` is the plain full cube; `TransparentBlock` culls faces
between blocks of the same kind (24 section 6 and the glass row); `CraftingTableBlock` opens the 3x3 menu
(13 section 3.5). The cobolcraft use rules of standin section 1.3 (the `cardstack` axis from the clicked face, the
`glowtube` toggle, the `goto_pad` travel) are behaviour on top of the class. The map colour, sound type, push
reaction and instrument columns, and the flags `validSpawn:never` (baseplate, lucite), `suffocating:never` and
`redstoneConductor:never` (lucite), are not derived from any document.

**Decision CORE-28 (cosmetic columns).** No document gives these values for the stand-in blocks. They are chosen as the nearest
standard analogue (the names exist in 24) so that each row is complete: they are cosmetic here (no map item, no sounds, no note
block, no redstone exist in the content) and may be changed freely. The flags follow the standard analogue (`bedrock` and `glass`).
Reason: a complete row needs a value, and none read by a rule is lost.

| id | key | class | properties | states | first state id | default id | hardness | blast res. | tool req. | light | map colour | sound | push | instrument | flags |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | `cobolcraft:void` | AirBlock | - | 1 | 0 | 0 | 0.0 | 0.0 | no | 0 | NONE | STONE | PUSH_PULL | HARP | replaceable noCollision noLootTable air |
| 1 | `cobolcraft:baseplate` | Block | - | 1 | 1 | 1 | -1.0 | 3600000.0 | no | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | noLootTable validSpawn:never |
| 2 | `cobolcraft:greystone` | Block | - | 1 | 2 | 2 | 1.5 | 6.0 | no | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 3 | `cobolcraft:loam` | Block | - | 1 | 3 | 3 | 0.5 | 0.5 | no | 0 | DIRT | GRAVEL | PUSH_PULL | HARP | - |
| 4 | `cobolcraft:turf` | Block | - | 1 | 4 | 4 | 0.6 | 0.6 | no | 0 | GRASS | GRASS | PUSH_PULL | HARP | - |
| 5 | `cobolcraft:grit` | Block | - | 1 | 5 | 5 | 0.5 | 0.5 | no | 0 | SAND | SAND | PUSH_PULL | SNARE | - |
| 6 | `cobolcraft:cardstack` | Block (axis from the face) | `axis[x/y/z]` `punched[true/false]` | 6 | 6 | 9 | 0.7 | 0.7 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | - |
| 7 | `cobolcraft:lucite` | TransparentBlock | - | 1 | 12 | 12 | 0.3 | 0.3 | no | 0 | NONE | GLASS | PUSH_PULL | HAT | noOcclusion validSpawn:never suffocating:never redstoneConductor:never |
| 8 | `cobolcraft:glowtube` | Block (toggled by use) | `lit[true/false]` | 2 | 13 | 13 | 0.2 | 0.2 | no | 15 when `lit`, else 0 | COLOR_YELLOW | GLASS | PUSH_PULL | HAT | - |
| 9 | `cobolcraft:ledger_tile` | Block | - | 1 | 15 | 15 | 0.8 | 0.8 | no | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |
| 10 | `cobolcraft:goto_pad` | Block (travel by use) | - | 1 | 16 | 16 | 1.3 | 1.3 | no | 6 | METAL | METAL | PUSH_PULL | HARP | - |
| 11 | `cobolcraft:slag` | Block | - | 1 | 17 | 17 | 0.4 | 0.4 | no | 0 | NETHER | NETHERRACK | PUSH_PULL | BASEDRUM | - |
| 12 | `cobolcraft:crafting_bench` | CraftingTableBlock | - | 1 | 18 | 18 | 0.8 | 0.8 | no | 0 | WOOD | WOOD | PUSH_PULL | BASS | - |

Where the numbers come from:

- `void`, `baseplate`: the rows of `air` and `bedrock` (24 section 15). `baseplate` is unbreakable (hardness -1.0, 13 section
  2.6); a survival player cannot break it and the creative instant break of 13 section 2.5 is the stand-in's "creative may
  place it" rule.
- `greystone` 1.5 / 6.0 (like `stone`), `loam` 0.5 / 0.5 (`dirt`), `turf` 0.6 / 0.6 (`grass_block`), `grit` 0.5 / 0.5 (`sand`),
  `lucite` 0.3 / 0.3 (`glass`), `slag` 0.4 / 0.4 (`netherrack`): the nearest standard block of README S10 and decision 4
  (24 section 15; 24 part 2 for `glass`, part 3 for `netherrack`).
- `cardstack`, `glowtube`, `ledger_tile`, `goto_pad`, `crafting_bench`: no standard block, so derived from the stand-in hand
  break time t (seconds) by the one rule below (README decision 4: "for the others, from the stand-in times"). The bench has
  no stand-in time; it takes the time of `ledger_tile`, the block it is crafted from.
- Blast resistance of the non-stone blocks equals hardness (the one-argument `strength(v)`, 24 section 4.2); `greystone` has
  the `stone` value 6.0.

**Decision CORE-18 (hardness derivation and tool speed).** For a block with no standard analogue, hardness H is the stand-in
hand time t (seconds) times 20 ticks divided by 30, rounded to one decimal place (H = round(t x 2 / 3, 1)): with no tool
requirement, hand speed 1.0 and divisor 30 (13 section 2.1), a break takes about 30 H ticks, which is t x 20 ticks. Results:
`cardstack` t 1.0 gives 0.7, `glowtube` 0.3 gives 0.2, `ledger_tile` 1.2 gives 0.8, `goto_pad` 2.0 gives 1.3. The two tools
get mining speed **4.0** on their block tag (section 5.3), the speed of a stone tool (17 section 2.1). Reason: the stand-in
tool divided the time by 4 for its class; a tool speed of 4.0 divides it by 4 in the standard formula, and it keeps
`mining_efficiency` working (the attribute is added only when the tool speed is above 1, 13 section 2.1 step 2).

**Decision CORE-17 (no cobolcraft block requires a correct tool).** Every row has "tool req." no, although `stone` and
`netherrack` have it. Reason: the stand-in rule is that any break in survival yields the block's item (standin section
1.3), and the content must stay soft-lock free: if `greystone` needed a pickaxe-like tool and the player lost the `pry_bar`,
no greystone could be won from the terrain and the `pry_bar` recipe (3 `greystone` and 1 `cardstack`) could not be met with
what is left. With the flag off the divisor is always 30 (13 section 2.1 step 8) and the drop never depends on the tool,
so a tool changes only speed. Operator may overrule (Open question 13); doing so adds the tier tags of section 4.1 "Not
defined".

**Decision CORE-27 (break-time model: accumulating single precision).** 13 section 2.1 states the break time as
ceil(1 / progress per tick), and 13 section 2.2 describes the client's accumulation of single-precision progress each tick. The
two disagree by one tick for two blocks: `greystone` by hand is 46 by the closed formula and 45 by accumulation; `slag` by hand
is 12 by the closed formula and 13 by accumulation. This document uses the accumulation model of 13 section 2.2, because it is
what both the client's progress bar and the server's mining check run and the tables and examples below use it. This is a
decision, not a fact of 13; 13 section 2.1 should state that its closed formula is exact only when the progress is not
a float32 boundary case (section 9).

Resulting break times (survival, standing on the ground, no effects), by the accumulating client model of 13 section 2.2 in
single precision. **Exact operation order** (the one an implementation and its tests must use): the speed and H are float32
(H is the decimal value of the table rounded to float32); the per-tick progress `d` is computed once per break as
`(speed / H) / 30` in float32, with the divisor 30 as float32; then each tick does `destroyProgress = destroyProgress + d` in
float32, starting at 0, and the break time is the number of additions until `destroyProgress >= 1.0`. The alternative order
`speed / (H x 30)` was also computed and gives the same tick count for every cell of the table below, so the table does not depend
on that choice. The exact-integer boundary cases of 1/(30 H) (`turf` 18, `cardstack` 21, `ledger_tile` and `crafting_bench` 24, `lucite`
9, `goto_pad` 39, `loam` and `grit` 15, and with the tool `ledger_tile` 6) were each computed in this order and equal the closed
formula; only `slag` by hand (13, closed formula 12) is not boundary-safe. A float32 or float64 change of order elsewhere (for
example summing in double) can move a boundary case by one tick, so section 8 item 12 lists them as tests. The results agree with 13
section 9: `dirt` by hand 15 ticks, `stone` with an iron pickaxe 8 ticks:

| Block | H | By hand (ticks, seconds) | With the matching tool, speed 4.0 | Stand-in by hand | Tool |
|---|---|---|---|---|---|
| `greystone` | 1.5 | 45 (2.25) | 12 (0.60) | 1.5 s | `pry_bar` |
| `loam` | 0.5 | 15 (0.75) | 4 (0.20) | 0.6 s | `trowel` |
| `turf` | 0.6 | 18 (0.90) | 5 (0.25) | 0.7 s | `trowel` |
| `grit` | 0.5 | 15 (0.75) | 4 (0.20) | 0.5 s | `trowel` |
| `cardstack` | 0.7 | 21 (1.05) | 6 (0.30) | 1.0 s | `pry_bar` |
| `ledger_tile` | 0.8 | 24 (1.20) | 6 (0.30) | 1.2 s | `pry_bar` |
| `slag` | 0.4 | 13 (0.65) | 3 (0.15) | 1.2 s | `pry_bar` |
| `crafting_bench` | 0.8 | 24 (1.20) | 6 (0.30) | none | `pry_bar` |
| `lucite` | 0.3 | 9 (0.45) | 9 (no tool class) | 0.4 s | none |
| `glowtube` | 0.2 | 6 (0.30) | 6 (no tool class) | 0.3 s | none |
| `goto_pad` | 1.3 | 39 (1.95) | 39 (no tool class) | 2.0 s | none |

Decision 4 of README Part 7 changes times visibly: `greystone` by hand is 2.25 s against 1.5 s (a `stone` value), `slag` is
0.65 s against 1.2 s (a `netherrack` value), `loam` is 0.75 s against 0.6 s (3 ticks), `turf` 0.90 s against 0.7 s (4 ticks)
and `grit` 0.75 s against 0.5 s (5 ticks, the largest of the three). Only `cardstack`, `ledger_tile`, `lucite`, `glowtube` and
`goto_pad` are within one tick of the stand-in. Open question 14 records the operator's choice.

The loot of every block is in section 5.6.

### 5.2 Items

Nineteen items; the bench item is appended as item id 18 (WT-12), ids 0 to 17 unchanged (standin section 2). The stand-in
uses no data components (standin section 2); under the standard schema the rows below are the prototype components
(17 section 1.1) of each item. A block item carries none beyond what is listed. The table lists only components that
differ from the standard prototype defaults (stack size 64, no other component).

| Item id | Key | Places | Components |
|---|---|---|---|
| 0 | `cobolcraft:nothing` | - | none; the air-equivalent item, never in a non-empty stack |
| 1 | `cobolcraft:baseplate` | baseplate (state 1) | none; creative only (no recipe, no loot table gives it) |
| 2 | `cobolcraft:greystone` | greystone (2) | none |
| 3 | `cobolcraft:loam` | loam (3) | none |
| 4 | `cobolcraft:turf` | turf (4) | none |
| 5 | `cobolcraft:grit` | grit (5) | none |
| 6 | `cobolcraft:cardstack` | cardstack (axis from face, punched false) | none |
| 7 | `cobolcraft:lucite` | lucite (12) | none |
| 8 | `cobolcraft:glowtube` | glowtube (13) | none |
| 9 | `cobolcraft:ledger_tile` | ledger_tile (15) | none |
| 10 | `cobolcraft:pry_bar` | - | section 5.3 |
| 11 | `cobolcraft:trowel` | - | section 5.3 |
| 12 | `cobolcraft:grazer_flank` | - | `max_stack_size` 32; `food`, `consumable` (section 5.4, nutrition 3) |
| 13 | `cobolcraft:seared_flank` | - | `max_stack_size` 32; `food`, `consumable` (nutrition 8) |
| 14 | `cobolcraft:sod_cake` | - | `max_stack_size` 16; `food`, `consumable` (nutrition 2) |
| 15 | `cobolcraft:dump_shard` | - | none; a crafting material |
| 16 | `cobolcraft:goto_pad` | goto_pad (16) | `max_stack_size` 16 |
| 17 | `cobolcraft:slag` | slag (17) | none |
| 18 | `cobolcraft:crafting_bench` | crafting_bench (18) | none |

Stacks are encoded as 00 section 12.1 in both world types; a cobolcraft stack with no patch is a valid empty patch (README
S22). The patch of a tool stack never carries `damage` (CORE-19).

### 5.3 The two tools as components

**Decision CORE-19 (no durability, no enchantability).** The tools have no `max_damage`, no `damage`, no `repairable` and
no `enchantable`. Reason: README S21 keeps "no durability" and the stand-in has none; `isDamageableItem` is false without
`max_damage` (17 section 1.3), so `damage_per_block` and `item_damage_per_attack` below are never applied (17 section 5.1:
`hurtAndBreak` returns at once). `enchantable` is read only by the enchanting table (17 section 1.3), which does not exist
here, and `/enchant` does not read it.

The `tool` component has the shape of 17 section 1.2 (id 28) and 1.3: the rules are scanned in order; a rule has a block
set, an optional speed and an optional `correct_for_drops`.

```json
// cobolcraft:pry_bar  (item id 10)
{
  "max_stack_size": 1,
  "tool": {
    "rules": [ { "blocks": "#minecraft:mineable/pickaxe", "speed": 4.0, "correct_for_drops": true } ],
    "default_mining_speed": 1.0,
    "damage_per_block": 1,
    "can_destroy_blocks_in_creative": true
  },
  "attribute_modifiers": [
    { "attribute": "minecraft:attack_damage", "id": "minecraft:base_attack_damage",
      "amount": 3.0,  "operation": "add_value", "slot": "mainhand" },
    { "attribute": "minecraft:attack_speed",  "id": "minecraft:base_attack_speed",
      "amount": -2.8, "operation": "add_value", "slot": "mainhand" }
  ],
  "weapon": { "item_damage_per_attack": 2, "disable_blocking_for_seconds": 0.0 }
}
// cobolcraft:trowel  (item id 11): the same with "#minecraft:mineable/shovel",
// attack_damage amount 1.0 and attack_speed amount -3.0
```

| Value | `pry_bar` | `trowel` | Source |
|---|---|---|---|
| Mining speed on its tag | 4.0 | 4.0 | CORE-18 |
| Block set | `#minecraft:mineable/pickaxe` | `#minecraft:mineable/shovel` | section 4.1; stand-in "hard" and "soft" classes |
| Attack damage with the item in hand | 1 + 3.0 = **4** | 1 + 1.0 = **2** | README S56: keep the stand-in numbers 4 and 2 (base 1.0 plus modifier, 17 section 1.3, 1.5) |
| Attack speed | 4 - 2.8 = 1.2 (cooldown 16.67 ticks) | 4 - 3.0 = 1.0 (cooldown 20 ticks) | Decision CORE-20 |

**Decision CORE-20 (attack speed copies the nearest standard tool kind).** The stand-in gives the player no attack
cooldown (the standard cooldown, 17 section 4.1, replaces it in both world types, README S56) and so no attack speed for
the two tools. `pry_bar` takes the pickaxe value (modifier -2.8) and `trowel` the shovel value (modifier -3.0) of 17
section 2.3. Reason: they are the pickaxe-like and shovel-like components of README decision 4, and a value is needed;
these are the standard values of the kinds they imitate. Operator may overrule (Open question 18).

The `weapon` component is what the standard tool builders attach (`item_damage_per_attack` 2, disable seconds 0 for non-axes,
17 section 1.4); with no durability it only marks the item as one that can attack.

### 5.4 Foods

```json
// cobolcraft:grazer_flank (nutrition 3), cobolcraft:seared_flank (nutrition 8), cobolcraft:sod_cake (nutrition 2)
"food": { "nutrition": N, "saturation": 0.0, "can_always_eat": false },
"consumable": { "consume_seconds": 1.6, "animation": "eat",
                "sound": { "sound_id": "cobolcraft:silent" },
                "has_consume_particles": true, "on_consume_effects": [] }
```

**Decision CORE-21 (food saturation 0.0, eating time 1.6 s).** Nutrition 3, 8 and 2 are the stand-in food values (README
S63). Saturation 0.0 is the stand-in's ("saturation is always sent as 0.0", README S60) because no document tabulates
per-food saturation (17 Open question 14). `consume_seconds` 1.6 is the default drink time of 17 section 3.8, and the default
for food is assumed equal (Open question 8); the stand-in's 30 ticks is retired (README S63). The sound is the inline form
with the stand-in's silent id (standin section 4.5: an inline compound, never a bare string, because the id is not in the
static `sound_event` registry); sounds are out of scope (README decision 17). The animation name `eat` is (recalled, not
verified). The eating rule itself (a player eats only while food is below 20 unless `can_always_eat`, the completion
effects) is 17 section 4.9. The `consumable` row is not implementation-ready: `eat` and 1.6 are assumed, and a wrong animation name
fails the item component decode (Readiness table of section 0, Open question 8).

### 5.5 Mobs

The four entity types and their ids are unchanged (standin section 3; README S24): `cobolcraft:operator` 0,
`cobolcraft:loose_item` 1, `cobolcraft:sodgrazer` 2, `cobolcraft:abend` 3. `operator` and `loose_item` are the player
and item entity **roles** (WT-22), so they follow the player and item entity rules without a cobolcraft value: the standard
player attribute set (17 section 1.5), the standard player box 0.6 x 1.8 for gameplay (README S24) and the standard item
entity metadata layout (21 appendix A).

The two mobs are expressed through the attributes the shared engines read (18 section 3 attribute table, 17 section 4):

| Attribute or property | `sodgrazer` | `abend` | Stand-in value it reproduces |
|---|---|---|---|
| `max_health` | 8.0 | 12.0 | standin section 12.1 |
| `movement_speed` | 0.1 | 0.12 | the larger of the stand-in speeds (flee 0.1, pursue 0.12) |
| `attack_damage` | (not set, the sodgrazer never attacks) | 3.0 | standin section 12.1; README S54 |
| `follow_range` | (not set) | 20.0 | the give-up range 20.0 (the target is dropped beyond it); the notice range 12.0 stays an AI constant |
| `step_height` | 1.0 | 1.0 | the step-up of one block (standin section 12.2) |
| collision box, eye height | 0.9 x 0.9, 0.7 | 0.75 x 0.75, 0.5 | standin section 3 |
| Default of every other attribute | standard (18 section 3) | standard | |

**Decision CORE-29 (the mob speed is attribute times factor, chosen backwards from the stand-in).** The speed factors 0.5
and 1/3 were derived from the stand-in speeds, not found in any document, and the `step_height` 1.0 row is a design choice
(the stand-in used no such attribute). That attribute times factor equals blocks per tick under the stand-in physics
(gravity 0.05, drag 0.96, which differ from the standard 18 section 3 and 13 section 1.2 drag 0.98) is asserted here, not
shown or tested. The reason for the choice is that `/effect` Speed and `/attribute` change `movement_speed`. A mob that
ignored the attribute in its own physics would ignore them; this is not tested. `follow_range` is unset for `sodgrazer`, so
the standard default of 16 applies (never read, as it never targets). It is consistent with README S64 ("stand-in AI and
physics remain the mob's own").

The stand-in AI speed in blocks per tick equals `movement_speed` times a speed factor, the meaning of a goal's
`speedModifier` (18 section 3.1: speed = attribute x modifier): sodgrazer wander 0.05 = 0.1 x 0.5, flee 0.1 = 0.1 x 1.0;
abend wander 0.04 = 0.12 x (1/3), pursue 0.12 = 0.12 x 1.0. Reason: `/effect` and `/attribute` (16 sections 5.10, 5.12) change
`movement_speed`, and a mob whose own AI ignored the attribute would ignore Speed and Slowness. Stand-in constants that
have no attribute stay constants of the mob's own AI and physics (README S64): wander period 80, flee duration 40, notice
range 12.0, attack reach 1.75, attack cooldown 30, gravity step 0.05 with drag 0.96 (the standard drag is 0.98, 13 section
1.2, and the stand-in's own physics is kept).

**Decision CORE-26 (the stand-in spawn cycle is the only spawner; no experience; no despawning).** Natural spawning of
sodgrazers and abends is the stand-in cycle of standin section 12.4 (README S64); the standard spawning engine (18 section 6)
finds no `gameplay/natural_mob_spawns` in any cobolcraft biome (section 3.4) and so spawns nothing, and the dimension
type's two spawn light fields are 0 (section 3.3). Both types are never removed for distance (the stand-in has no
despawning, standin section 12.4). Both have experience reward 0 (the stand-in has no experience; a value would be
invented content). Reason: one spawner, content unchanged. Open question 9 asks whether the operator wants the standard
animal and monster rewards.

Both types are in no entity type tag (the 21 section 3.6 tags list standard types only). Reason: no tag consumer of the
two types was found in 18 to 21; the damage pipeline reads damage type tags (section 4.3), not entity tags, for them.

Death messages: the generic mob message `death.attack.mob_attack` key for `minecraft:mob_attack` (README decision 5, with
Decision CORE-10).

Loot: section 5.6.

### 5.6 Loot

Block loot tables are `cobolcraft:blocks/<path>` (24 section 4.1: the default key is `<namespace>:blocks/<path>`), mob
loot tables `cobolcraft:entities/<path>` (18 section 7.6). The stand-in yields are kept (README S15, S64): each block drops
its own item, one of it; the sodgrazer drops 2 `grazer_flank`, the abend 1 `dump_shard`. The yield of a block is
independent of its state: every `cardstack` state drops item 6 and both `glowtube` states drop item 8 (standin section 1.3).

**Decision CORE-22 (plain tables).** The tables use only the grammar of 18 section 7.6 that the yields need: one pool, one
roll, one `minecraft:item` entry, and `set_count` where the count is 2. They carry no `explosion_decay`, no silk-touch
alternative, no Fortune function and no looting function, and no condition (a mob drops its yield whatever killed it:
standin section 12.5). Reason: the cobolcraft content has no explosion source, no block whose drop differs from itself and
no enchantment that changes counts (Decision CORE-14), so each of those entries would be dead data. The entry key for
functions is `modifier` and for conditions `condition` (18 section 7.6; 21 section 3.7). `baseplate` and `void` have no loot table
(`noLootTable`, section 5.1), and a creative break yields nothing (13 section 2.5).

```json
// data/cobolcraft/loot_table/blocks/greystone.json  (the same shape for loam, turf, grit, cardstack, lucite,
// glowtube, ledger_tile, goto_pad, slag and crafting_bench, with the item key equal to the block key)
{ "type": "minecraft:block",
  "random_sequence": "cobolcraft:blocks/greystone",
  "pools": [ { "rolls": 1, "entries": [ { "type": "minecraft:item", "name": "cobolcraft:greystone" } ] } ] }

// data/cobolcraft/loot_table/entities/sodgrazer.json
{ "type": "minecraft:entity",
  "random_sequence": "cobolcraft:entities/sodgrazer",
  "pools": [ { "rolls": 1, "entries": [ { "type": "minecraft:item", "name": "cobolcraft:grazer_flank",
      "modifier": [ { "function": "minecraft:set_count", "count": 2 } ] } ] } ] }

// data/cobolcraft/loot_table/entities/abend.json
{ "type": "minecraft:entity",
  "random_sequence": "cobolcraft:entities/abend",
  "pools": [ { "rolls": 1, "entries": [ { "type": "minecraft:item", "name": "cobolcraft:dump_shard" } ] } ] }
```

| Table key | Drops | Stand-in source |
|---|---|---|
| `cobolcraft:blocks/greystone` | 1 `greystone` (item 2) | standin section 1.3 |
| `cobolcraft:blocks/loam`, `turf`, `grit` | 1 of the same item (items 3, 4, 5) | same |
| `cobolcraft:blocks/cardstack` | 1 `cardstack` (item 6) from all 6 states | same |
| `cobolcraft:blocks/lucite` | 1 `lucite` (item 7) | same |
| `cobolcraft:blocks/glowtube` | 1 `glowtube` (item 8) from both states | same |
| `cobolcraft:blocks/ledger_tile` | 1 `ledger_tile` (item 9) | same |
| `cobolcraft:blocks/goto_pad` | 1 `goto_pad` (item 16) | same |
| `cobolcraft:blocks/slag` | 1 `slag` (item 17) | same |
| `cobolcraft:blocks/crafting_bench` | 1 `crafting_bench` (item 18) | appended (WT-12) |
| `cobolcraft:entities/sodgrazer` | 2 `grazer_flank` | standin section 12.1 |
| `cobolcraft:entities/abend` | 1 `dump_shard` | standin section 12.1 |

The dropped stacks are item entities with the standard rules (README S15: pickup delay 10, lifetime 6000, merge; 18
section 6.11; the delay-6 and position rules of standin section 1.3 are retired).

### 5.7 Recipes

Recipes are data files `data/cobolcraft/recipe/<name>.json` in the format of 13 section 3.1: type `crafting_shapeless` (fields
`ingredients`, `result`, `category`; an ingredient is an item id; `result` is `{id, count}`) and, for the bench, type
`crafting_shaped` (fields `pattern`, `key`, `result`, `category`). Matching is 13 section 3.2 and 3.3.

**Decision CORE-23 (the recipes in the standard format, the bench shaped).** The nine stand-in recipes stay shapeless
(README S65). The bench recipe is shaped, 2 x 2 of `ledger_tile`, the pattern of the vanilla crafting table (13 section 3.1
example). Reason: the bench must be craftable in the inventory grid, so it has at most four ingredients; four
`ledger_tile` is the plain building block (`ledger_tile`) the stand-in already gives 64 of and makes from `greystone`
(recipe 0); and a shaped recipe is the only way the shaped matcher (13 section 3.2) is used by the cobolcraft content.
Each repeated ingredient is written once per unit (`"ingredients": [g, g, g, g]`).

| Display id | Recipe key | Type | Ingredients | Result | Category | Smallest grid |
|---|---|---|---|---|---|---|
| 0 | `cobolcraft:ledger_tile` | shapeless | 4 `greystone` | 2 `ledger_tile` | `building` | 2 x 2 |
| 1 | `cobolcraft:lucite` | shapeless | 4 `grit` | 2 `lucite` | `building` | 2 x 2 |
| 2 | `cobolcraft:pry_bar` | shapeless | 3 `greystone` + 1 `cardstack` | 1 `pry_bar` | `equipment` | 2 x 2 |
| 3 | `cobolcraft:trowel` | shapeless | 2 `greystone` + 1 `cardstack` | 1 `trowel` | `equipment` | 2 x 2 |
| 4 | `cobolcraft:glowtube` | shapeless | 1 `lucite` + 1 `dump_shard` | 2 `glowtube` | `building` | 2 x 2 |
| 5 | `cobolcraft:sod_cake` | shapeless | 4 `turf` + 1 `loam` | 1 `sod_cake` | `misc` | **3 x 3** (5 ingredients) |
| 6 | `cobolcraft:seared_flank` | shapeless | 2 `grazer_flank` + 1 `glowtube` | 2 `seared_flank` | `misc` | 2 x 2 |
| 7 | `cobolcraft:goto_pad` | shapeless | 4 `ledger_tile` + 2 `dump_shard` + 1 `glowtube` | 1 `goto_pad` | `misc` | **3 x 3** (7 ingredients) |
| 8 | `cobolcraft:dump_shard` | shapeless | 2 `cardstack` + 2 `lucite` | 1 `dump_shard` | `misc` | 2 x 2 |
| 9 | `cobolcraft:crafting_bench` | shaped `["##","##"]`, `#` = `ledger_tile` | 4 `ledger_tile` | 1 `crafting_bench` | `building` | 2 x 2 |

(All item names are `cobolcraft:`. The display id is the number the server sends in Recipe Book Add (13 section 3.9). The
order of the stand-in is kept, and the bench is appended as 9 (WT-12); the standard only requires the server to allocate
ids, so any order is valid on the wire.)

```json
// data/cobolcraft/recipe/glowtube.json
{ "type": "minecraft:crafting_shapeless", "category": "building",
  "ingredients": [ "cobolcraft:lucite", "cobolcraft:dump_shard" ],
  "result": { "id": "cobolcraft:glowtube", "count": 2 } }
// data/cobolcraft/recipe/crafting_bench.json
{ "type": "minecraft:crafting_shaped", "category": "building",
  "pattern": [ "##", "##" ], "key": { "#": "cobolcraft:ledger_tile" },
  "result": { "id": "cobolcraft:crafting_bench", "count": 1 } }
```

**Correction to README (two recipes need the bench, not one).** README S65 and WT-12 name recipe 7 (seven ingredients) as the
reason for the bench. A shapeless recipe matches only when the count of non-empty slots equals the number of ingredients
(13 section 3.3), and the inventory grid has four slots (13 section 3.5). Recipe 5 (`sod_cake`) has five ingredients, so it
also needs the 3 x 3 grid. The recipe book hides a shapeless display with more ingredients than the grid has slots (13
section 3.9, "Which collections are listed"). Open question 12 asks that README S65 and the spec text be corrected.

The bench menu is the `CraftingMenu` of 13 section 3.5 with the title `container.crafting` (13 section 3.5); the stand-in's
crafting needs no block rule (standin section 13) is retired (README S65).

**Unlock.** The server decides which recipes a player knows (13 section 3.9); the engine for that is GAP-5b. The interim rule
of README decision 14 is used: a player knows **all ten recipes** from joining (Recipe Book Add with Replace at join, no
toast and no highlight, so `show_notification` and the highlight flag are false). Reason: the stand-in's crafting had no
unlock either, and GAP-5b needs the advancement engine that the cobolcraft content does not otherwise need.

**How each item is obtained in survival (SC-008), updated.** The rows of standin section 13 stay; these change or are added:

| Item | Obtained from |
|---|---|
| `crafting_bench` | recipe 9 in the inventory 2 x 2 grid: 4 `ledger_tile` (starting inventory, or recipe 0) |
| `sod_cake` | recipe 5, at the bench only (4 `turf`, 1 `loam`: starting inventory or terrain) |
| `goto_pad` | recipe 7, at the bench only |

### 5.8 The starting kit

The stand-in kit (standin section 2; README S23, decision 6) is kept in the cobolcraft world type only: the standard world
type starts empty. It is given once to a first-time player in survival mode, as the stand-in says (the player has no
stored player data in the world folder, 07 section 9; a creative player receives nothing).

**Decision CORE-24 (the kit is a small data file).** Vanilla has no starting-kit concept, so no standard schema exists. A
loot table cannot name slots, and a function would need the whole function engine at join. The kit is one JSON file in
the content data of the type, `cobolcraft:starting_kit` (path `data/cobolcraft/starting_kit.json`), whose items use the
item form of 04 section 6 (`{id, count, components}`) and whose slot is the player inventory index (07 section 9). The index here is the inventory index, not the menu index: 0 to 8 is the hotbar (menu index 36 to 44, so inventory
index = menu index - 36, 13 section 3.5), and 9 to 35 is the main inventory, where inventory index = menu index (13 section 3.5).
A kit item in a main slot is therefore placed at its inventory index 9 to 35 directly, and the subtraction of 36 applies to the hotbar only. Reason: the smallest thing that reproduces the stand-in kit exactly and uses only existing
vocabulary.

```json
{ "selected_slot": 0,
  "items": [
    { "slot": 0, "id": "cobolcraft:greystone",   "count": 64 },
    { "slot": 1, "id": "cobolcraft:loam",        "count": 64 },
    { "slot": 2, "id": "cobolcraft:turf",        "count": 64 },
    { "slot": 3, "id": "cobolcraft:grit",        "count": 64 },
    { "slot": 4, "id": "cobolcraft:cardstack",   "count": 64 },
    { "slot": 5, "id": "cobolcraft:lucite",      "count": 64 },
    { "slot": 6, "id": "cobolcraft:glowtube",    "count": 64 },
    { "slot": 7, "id": "cobolcraft:ledger_tile", "count": 64 },
    { "slot": 8, "id": "cobolcraft:pry_bar",     "count": 1 },
    { "slot": 9, "id": "cobolcraft:trowel",      "count": 1 }
  ] }
```

Slots 0 to 7 hold items 2 to 9 in id order, slot 8 the `pry_bar`, slot 9 (the first main slot) the `trowel`, every other
slot is empty, and the held slot is 0 (standin section 2). The bench is not in the kit: the player crafts it. The kit
is not given again on respawn (README S58); a death drops the inventory by the standard rule (17 section 4.10).

### 5.9 The bench as a role

**Decision CORE-25 (a role for the crafting bench).** The menu opened by a crafting bench stays valid only while the block
at its position is the crafting block (13 section 3.5: "while the block is still a crafting table and the player is within 8
blocks"), and a use on that block opens the menu. WT-22 resolves content that has a different key per world type through a
role table; its four roles do not include this one. The core adds a fifth role:

| Role | Standard | Cobolcraft |
|---|---|---|
| The crafting block | `minecraft:crafting_table` | `cobolcraft:crafting_bench` |

Reason: the same as WT-22. The shared menu engine tests the role, not a name. world-types.md must carry the row (section 9).

---

## 6. Which shared engine reads which core entry

| Engine (document section) | Reads | From the core |
|---|---|---|
| Block-break progress (13 section 2.1, 2.2) | the held item's `tool` component, the block's hardness and tool-required flag, `mining_efficiency` | sections 5.1, 5.3, 3.7 |
| Crack overlay and break stage (13 section 2.4) | the same progress | section 5.1 |
| Damage pipeline (17 sections 4.4, 4.5, 4.7), death messages (17 section 4.10) | `damage_type` rows and the 20 damage tags | sections 3.6, 4.3 |
| Fall, fire, drowning, starvation, void (17 sections 4.9, 4.11) | `fall`, `in_fire`, `on_fire`, `lava`, `drown`, `starve`, `out_of_world`, `in_wall`, `cactus`, `lightning_bolt` | section 3.6 |
| Chat and commands (15, 16 section 8) | `chat_type` rows | section 3.5 |
| Sky, fog, clouds, sun, moon, stars (12 section 3) | `dimension_type.attributes`, the `day` and `moon` tracks | sections 3.2, 3.3 |
| Time, `time` command, moon phase (33 section 3, 16 section 4.5); sleeping skip is not a consumer (no beds, bed rules dropped, CORE-6) | `world_clock`, `time_markers`, `gameplay/sky_light_level`, `moon_phase` | sections 3.1, 3.2 |
| Weather (33 section 4) | the dimension type's skylight and ceiling, the biome's `has_precipitation` and temperature | sections 3.3, 3.4 |
| Crafting menus and recipe book (13 section 3) | `recipe` documents, the crafting-block role | sections 5.7, 5.9 |
| Block loot, entity loot (17 section 3.16, 18 section 7.6) | `loot_table` documents | section 5.6 |
| Tag resolution and Update Tags (23 section 6, 04 section 1) | the tag files | section 4 |
| Mob attributes and AI speed (18 section 3) | the attribute rows | section 5.5 |
| First join | the starting kit | section 5.8 |

---

## 7. Worked examples

All numbers are computed from the rows above.

1. **Break times** (13 section 2.1, 2.2; single-precision accumulation). `greystone`, H 1.5, by hand: 1.0 / 1.5 / 30 = 0.02222
   per tick, 45 ticks. With the `pry_bar` (speed 4.0, tag `mineable/pickaxe`, divisor 30 because the block needs no tool):
   4.0 / 1.5 / 30 = 0.08889 per tick, 12 ticks. `lucite`, H 0.3, with a `pry_bar`: the block is in no `mineable` tag, so the
   rule does not match and the speed is the default 1.0: 1.0 / 0.3 / 30 = 0.1111, 9 ticks.
2. **Efficiency.** `pry_bar` on `greystone` with Efficiency III: the tool speed 4.0 is above 1, so the attribute is added:
   3 x 3 + 1 = 10, speed 14.0: 14.0 / 1.5 / 30 = 0.3111, **4 ticks** (against 12). Efficiency V: 26 added, speed 30.0,
   **2 ticks**. On `loam` with a `trowel` and Efficiency V: 1 tick.
3. **A hand with no tool on `slag`.** H 0.4, speed 1.0: 0.08333 per tick, 13 ticks (the accumulated single-precision sum
   of 13 terms first reaches 1.0 at tick 13).
4. **Recipe fit.** The inventory grid (2 x 2): 4 `greystone` in the four slots match recipe 0 (shapeless, four ingredients,
   four non-empty slots), result 2 `ledger_tile`. The same 4 `ledger_tile` in the four slots match recipe 9 (the trimmed
   2 x 2 pattern, symmetric, so no mirror test, 13 section 3.2), result 1 `crafting_bench`. 4 `turf` and 1 `loam` cannot be
   placed in the 2 x 2 grid (five items, four slots) and match recipe 5 only in the bench's 3 x 3 grid. Recipe 7 with its
   seven items likewise needs the bench. Two items `lucite` and `dump_shard` in any two slots of either grid match recipe 4.
5. **Sky light at dusk** (33 section 3.5, `day.json`). The track `gameplay/sky_light_level` (multiply, keyframes 11867: 1.0
   and 13670: 0.26666668): at tick 12000, u = 133 / 1803 = 0.0738, value 0.94590, `L` = 15 x 0.94590 = 14.189, `skyDarken`
   = floor(15 - 14.189) = 0. At tick 12522 the value is 0.73359 and `skyDarken` is 3 (still "bright outside", below 4); at
   tick 12523 the value is 0.73319, `L` 10.9978 and `skyDarken` **4**, the first dark tick. At dawn `skyDarken` drops back
   to 3 at tick 23478 (33 section 3.5 gives the same two ticks). A `time set midnight` moves the clock to the marker
   `minecraft:midnight` = 18000; the sky colour there is the product of the base `#78a7ff` and the track value `#000000`, which is
   black (12 section 3.1, 3.2).
6. **Moon phase.** Game clock 50000 ticks: 50000 mod 192000 = 50000, the keyframe at 48000 is `third_quarter`, held to
   72000 (enum, step). Index 2, brightness 0.5 (33 section 3.7).
7. **Damage ids.** `minecraft:fall` is id 10, `minecraft:starve` 41, `minecraft:out_of_world` 33, `minecraft:player_attack` 35,
   `minecraft:mob_attack` 29, `cobolcraft:hail` 20. A hail hit on a player: type 20, exhaustion 0.1, scaling
   `when_caused_by_living_non_player` (no living cause, so no difficulty scaling, 17 section 4.4), no knockback (id 20 is in
   `no_knockback`), not blockable by a shield (id 20 is in `bypasses_shield`), armor applies (id 20 is not in
   `bypasses_armor`).
8. **Fall damage on the cobolcraft surface** is the standard rule (17 section 4.11): a fall of 10 blocks does 7; the type is
   `minecraft:fall` (id 10), in `is_fall` (ids 10, 8, 40) and in `bypasses_armor` (id 10 is listed), and its
   `death_message_type` is `fall_variants`.
9. **Update Tags, one block tag.** Registry `minecraft:block`, tag `minecraft:mineable/shovel`, entries `[3, 4, 5]`
   (loam, turf, grit): VarInt count 3, then the three VarInts (04 section 1).

---

## 8. Validation: checkable facts

1. The Registry Data total is 20 packets and 82 entries (section 2).
2. `damage_type` has 52 entries: 51 standard plus `cobolcraft:hail`; groups A 18, B 1, C 3, D 7, E 22 (17 section 4.12) plus hail
   in E gives 23 in E.
3. The 25 keys of `DamageSources` and the 24 lazy keys (04 section 3.2 item 6) are all in the table of section 3.6. This item
   fails by design until Open question 1 is closed: 04 names `fell_out_of_world` and the table carries `out_of_world`.
4. `minecraft:plains` is in the biome registry (04 section 3.2 item 6); each of the 13 variant registries has at least one entry.
5. Every tag or entry that a core entry names exists: `dimension_type` names the timelines `minecraft:day`, `minecraft:moon` and
   the clock `minecraft:overworld` (sections 3.1, 3.2); `enchantment` names the item tag `minecraft:enchantable/mining`
   (section 4.2); recipes and loot name only `cobolcraft:` items.
6. Block count 13, state count 19, `ceillog2(19)` = 5; item count 19; recipe count 10; loot tables 11 block tables plus
   2 entity tables; damage tags 20; timelines 2; chat types 8.
7. Marker names of `day` are unique per clock (23 section 9.2): `day`, `noon`, `night`, `midnight`, `wake_up_from_sleep`.
8. Keyframe ticks of `day` are within `[0, 24000]` and at most two share a tick (the three angle tracks), and of `moon`
   within `[0, 192000]` (04 section 6).
9. `bypasses_shield` has 31 members, `no_knockback` 31 members, `bypasses_armor` 19 (17 section 4.12 plus hail in the first two).
10. Break times of section 5.1: `greystone` by hand 45 ticks, with the `pry_bar` 12; `loam` by hand 15 (the same as 13 section 9
    for `dirt`).
11. Ids by CORE-2: chat types 0 `minecraft:chat`, 4 `cobolcraft:say`, 5 `minecraft:say_command`; timelines 0 `day`, 1 `moon`.
12. Break-time boundary cases (section 5.1, float32, order `(speed / H) / 30` then repeated addition): by hand `turf` (H 0.6) 18,
    `cardstack` (0.7) 21, `ledger_tile` and `crafting_bench` (0.8) 24, `lucite` (0.3) 9, `goto_pad` (1.3) 39, `loam` and `grit`
    (0.5) 15, `glowtube` (0.2) 6; with speed 4.0 `ledger_tile` 6, `greystone` 12; `slag` by hand 13 (closed formula 12).
13. The spawn rule: with `monster_spawn_light_level` 0 a vanilla-engine spawn check (spawner block, `/summon` checks) passes at any
    light level in both dimension types (section 3.3, Open question 21); a test pins this behaviour so a change is deliberate.

---

## 9. What other documents must change

| Document | Change |
|---|---|
| `docs/protocol/09-cobolcraft-profile.md` section 3.1 | Registry Data: 20 packets and 82 entries in the order biome, chat_type, 13 variants, dimension_type, damage_type, enchantment, world_clock, timeline; Update Tags no longer empty (sections 2 and 4.4); the fixtures `config-s2c-07-registry-data-chat-type`, `-damage-type`, `-world-clock` and `config-s2c-0e-update-tags` change, and fixtures for `enchantment` and `timeline` are added; the dimension type fixture changes (attributes, timelines, default clock) |
| `docs/design/standin-content.md` | sections 1.1, 1.2 (block 12, state 18), 2 (item 18, components), 13 (recipe 9, recipes 5 and 7 need the bench, obtainability rows), 4.2 to 4.8 (replaced by this document, README S32 to S39), 6 (tags), the starting inventory paragraph of section 2 |
| `docs/design/world-types.md` | WT-22 role table: add the crafting block row (section 5.9); section 7.2 dependency and Open question 7 (the core is now listed here); section 10 Open question 15 (the values owed by standin are in sections 5.1 to 5.8) |
| `docs/design/README.md` | S65 and WT-12: recipes 5 and 7 need the bench (Open question 12); GAP-35 closed by this document; S39 and C3: `block_transformer` carries no entry and `enchantment` one entry (CORE-14, CORE-15); C3 and decision 4: the tier tags (`needs_*`, `incorrect_for_*`) are not carried (CORE-17, Open question 13); S37: the stand-in damage types `impact` and `below_world` are dropped (CORE-11); S36 (the `timelines`, `default_clock` and attributes of `surface`, CORE-5, 7, 8) and S42 (Update Tags no longer empty; the own tags `cobolcraft:hard`, `soft`, `tools` retire, section 4) |
| `docs/protocol/13-client-gameplay-and-controls.md` section 2.1 | state that the break time `ceil(1 / progress per tick)` can differ by one tick from the accumulating single-precision model of 2.2 (CORE-27) |
| `docs/design/builtin-ui-art.md` and the built-in language file | the language keys of Open question 11 |
| `docs/protocol/17-tools-weapons-and-combat.md` section 4.12, `41-item-entity-physics.md` line 329, `04-registry-sync.md` section 3.2 item 6, `18` section 3 and `standin-content.md` section 4.7 | whichever of `out_of_world` and `fell_out_of_world` is wrong (CORE-12, Open question 1); `docs/protocol/41-item-entity-physics.md` line 329 also names `out_of_world` (tag contents), so all five documents are candidates |

**Decision CORE-15 (no `block_transformer` entry).** README C3 and S39 list `block_transformer` among the entries the
cobolcraft type carries. No cobolcraft item has the `block_transformer` component (CORE-19 and section 5.3: the two tools
are mining tools only), so a transformer entry would have no user (17 section 3.1 applies a transformer only for an item
with the component). Creating one would add content (for example a trowel that flattens `turf`), which the ticket forbids
("for now unchanged"). The registry is empty and sends no packet (04 section 3.2 item 5; no validator, 04 section 3). Open
question 15 records the departure from C3.

---

## Open questions

1. **`out_of_world` or `fell_out_of_world`.** 17 section 4.12 and 41 line 329 (tag contents "read from
   `data/minecraft/tags/damage_type/`") say `out_of_world`; 04 section 3.2 item 6, 18 section 3 and standin section 4.7 say
   `fell_out_of_world` (standin calls it "verified against the jar"). The three may have taken the name from the `DamageSources`
   code constant instead of the data key (hypothesis only). Searched in this round: 04, 17, 18, 41, standin; none gives the
   file name of the data entry unambiguously. The core carries `out_of_world` provisionally (CORE-12) and takes no side. A
   clean-room read of `data/minecraft/damage_type/` and the 25-key list of `DamageSources` settles it. The vanilla client's
   configuration check (tier B) fails if the key is wrong; this is a precondition (Readiness table), or an operator decision.
2. **Death message keys.** `message_id` is the key path (CORE-10), except `outside_border`, whose death message `death.attack.outsideBorder` is
   read in 33 section 7.5, so its value is `outsideBorder`. The other 50 values are invented and likely wrong for some types. The built-in
   `en_us` must define a text for each of the 52 types (or the engine needs a generic fallback key), and a vanilla pack stacked
   above it (README C7) would not match wrong keys. The clean-room read of all 51 `message_id` values is a precondition of the
   `damage_type` rows (CORE-10, Readiness table); switching is a one-column change.
3. **Chat type keys.** The key `chat.type.text` of `minecraft:chat` and the registry keys `team_msg_command_incoming` and
   `_outgoing` are (recalled, not verified). The narration parameters of the `msg` and `teammsg` rows are inferred (16 section 8.3,
   8.4 give the narration key only). The key list of 16 section 8 has no row for plain player chat.
4. **Enchantment effect shape.** The inner shape of `minecraft:attributes` (fields `attribute`, `id`, `operation`, `amount`, the
   value of `id`, the level-based value form `levels_squared`) is inferred from the `attribute_modifiers` schema and 13 section 2.1;
   the per-component schemas of the effect components are not expanded in 04 or in any document (no RS8 document exists; searched:
   04 section 6, 17 section 6, 13 section 2.1, 23 section 8). The description key is (recalled, not verified). A wrong shape fails
   the client's Registry Data decode.
5. **Inferred block tags.** `replaceable`, `air`, `causes_suffocation` and the four `blocks_motion*` tags are proposed from the names
   and 24 section 12.2 ("inferred"); their consumers (suffocation, heightmaps, placement) were not read. Confirm each use when the
   placement, light and heightmap rounds read them.
6. **Completeness of `day`.** 12 section 3.2 lists "tracks that affect rendering" and one gameplay track. Whether `day.json` has
   further rendering tracks (for example `visual/block_light_tint`, `visual/night_vision_color`, fog distances) is not stated. The
   gameplay tracks (`monsters_burn`, `bees_stay_in_hive`, and others of 33 section 3.4) were omitted (CORE-6), so the rows of `day` are exact only for the tracks that 12 section 3.2 lists, and a vanilla-engine consumer of an omitted track finds none; 20 and 18 (the `isSunBurnTick` rule) give `monsters_burn` as a step at ticks 12542 and 23460 if a cobolcraft mob ever needs it. Searched in this round: 12, 18, 20, 23 section 8 and 33 section 3.4; they list the attribute names but not the contents of `day.json`. Until the file is read, "the shared engines run on `day`" holds for the tracks of 12 section 3.2 only (Covers row, CORE-6).
7. **The dark horizon.** 12 section 3.4d draws a black "void horizon" disc when the eye is below the horizon height, which is 63 for
   a world that is not flat and `minY` for a flat one. The `cobolcraft:main` terrain is at height 46 to 58 (standin section 5.2), so
   the disc would be drawn almost always. Setting the "is flat" flag of the spawn info to true for `cobolcraft:main` (standin section
   5.1 says false) would put the horizon at 0 and lower the void-darkness onset from 32 to 1 (12 section 3.3). This needs a decision
   in 09 section 3.2 and world-types; it is not a core row.
8. **Food defaults.** `consume_seconds` 1.6 for food and the animation name `eat` are assumed (17 Open question 14: per-food
   values were not tabulated); the saturation 0.0 is the stand-in's.
9. **Experience.** Both cobolcraft mobs give no experience (CORE-26). Whether the operator wants the standard rewards (animals 1 to 3,
   monsters 5) is open; no document gives them.
10. **The mob tags.** No entity type tag lists a cobolcraft mob (section 5.5). If a shared rule is found that reads an entity tag for
    a cobolcraft mob (for example `undead` for the abend), a tag file with `cobolcraft:` values is added.
11. **Language keys the core needs in the built-in `en_us`.** `enchantment.minecraft.efficiency`, `container.crafting`,
    `block.cobolcraft.crafting_bench` and `item.cobolcraft.crafting_bench` (the default description ids of 24 section 4.1 and the
    item equivalent), the `chat.type.*` keys of section 3.5, `commands.message.display.incoming` and `.outgoing`, `death.attack.*` (Open
    question 2; `death.attack.outsideBorder` is read), `death.attack.hail`, and the English text of the new rows. None of these is a core row, so none is written here; they are
    the dependency of `builtin-ui-art.md` and 08 section 10.8.
12. **Recipes 5 and 7.** README S65 and WT-12 say only recipe 7 needs the bench; recipe 5 (five ingredients) also does (section 5.7).
    The README, the spec US10 text and the survival-obtainability table must say both.
13. **Tool requirement.** Every cobolcraft block yields its item without a tool (CORE-17), against README S10's "greystone is like
    `stone`" (which requires a tool). Operator to confirm; the alternative adds `needs_*` tags and a deny-drops rule to the tools.
14. **Break times.** Decision 4's nearest-standard rule changes `greystone` by hand to 2.25 s and `slag` to 0.65 s (section 5.1). The
    alternative is hardness from the stand-in times (`greystone` 1.0, `slag` 0.8), which keeps the stand-in times exactly. `grit` is the largest
    difference: 0.75 s against 0.5 s (hardness 0.3 would give 0.5 s: round(0.5 x 2/3, 1)). Operator to confirm which.
15. **C3 departure.** README C3 and S39 list `block_transformer` and several `enchantment` entries; the core carries none and one
    (CORE-14, CORE-15). The README text should be corrected, or the operator should ask for the larger set.
16. **The retained `cobolcraft:say`.** No shared engine sends it (CORE-13); keep or drop it when 09 is rewritten.
17. **Vanilla-client configuration check.** Whether a vanilla 26.3 client passes the configuration phase against these registries
    depends on 04 Open question 1 (further hard-coded keys, for example `minecraft:efficiency` or timeline keys looked up by the
    client), which is not closed. This is configuration-phase validation only: README R8 says the cobolcraft type is not playable
    by a vanilla client, and C1 keeps tier B.
18. **Attack speed of the two tools** (CORE-20) is copied from the pickaxe and shovel kinds; the stand-in gives none. Operator to
    confirm or give values.
19. **Starting kit location and schema** (CORE-24): the file name and the keys are new; the planner confirms the path in the
    content data of the type.
20. **Standard `minecraft:` vocabulary beyond the core.** world-types Open question 7 asked for the complete list of standard
    effect, enchantment and attribute keys; the effect and attribute registries are static vocabulary held by both types (WT-9),
    so only the synchronized rows above are core rows. The static registries are not authored here.
21. **Spawn light level 0 (departure from the standard).** CORE-26 and section 3.3 set `monster_spawn_light_level` 0 and
    `monster_spawn_block_light_limit` 0 so that no standard natural spawn happens. The same field governs every vanilla-engine spawn
    check, so a spawner block or a `/summon` spawn check passes at any light level in a cobolcraft world, which differs from the
    standard. No document says whether that is acceptable. Operator to accept the departure, or a different mechanism (an empty
    spawn list with the standard light level) is chosen; validation item 13 pins the current behaviour.
