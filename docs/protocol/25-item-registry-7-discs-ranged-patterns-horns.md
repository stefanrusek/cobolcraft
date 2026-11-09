# Item registry, part 7: music discs, trident, nautilus items, crossbow, suspicious stew, banner patterns and the goat horn (ids 1105 to 1149)

| Item | Value |
|---|---|
| Covers | The 45 registry entries of ids 1105 to 1149 of `net.minecraft.world.item.Items`: the 22 music discs (1105 to 1126), `disc_fragment_5` (1127), `trident` (1128), `nautilus_shell`, the five nautilus armors and `heart_of_the_sea` (1129 to 1135), `crossbow` (1136), `suspicious_stew` (1137), the block item `loom` (1138), the ten banner pattern items (1139 to 1148) and `goat_horn` (1149). For each: key, id, item class, prototype components beyond the common set, every constant the registering code sets. The engines of the code-defined behaviour these items rely on: jukebox playback (item side, song player, level events, client playback), the crossbow (use, charge, load, shoot, multishot), the trident item rules, suspicious stew consumption, banner pattern item rules and the loom's item test, the goat horn (instrument component, use, creation by a goat) |
| Does not cover | Ids 0 to 1104 and 1150 onward (siblings: [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) for the shared model and every column definition; the other parts of document 25 for the other ranges). Weapon tables (17 section 2). The `ThrownTrident` and arrow entities (17 section 3.9, section 3.10, 45 section 8). Rows of data (`jukebox_song`, `instrument`, `banner_pattern` entries, the item tags, item models, language): the extraction tool (22) copies them; this document gives the schemas and the engines |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap targets of lambdas), and of data files in the jar (`unzip -p`), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions |
| Status | Round RS5, part 7 of 8 (design map Part 5 GAP-2, Part 6 row RS5) |

"25 part 1 section N" means section N of [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md);
"17 section N" is [17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md); "19" is
[19-mobs-land-friendly-and-neutral.md](19-mobs-land-friendly-and-neutral.md); "24 section N" is the block registry
([24-block-registry-3-signs-doors-redstone.md](24-block-registry-3-signs-doors-redstone.md) for the jukebox);
"46 section N" is [46-registry-ids.md](46-registry-ids.md); "04 section N" is [04-registry-sync.md](04-registry-sync.md);
"00 section N" is [00-data-types.md](00-data-types.md); "05a" is [05a-play-clientbound-00-71.md](05a-play-clientbound-00-71.md).
The design map is `docs/design/README.md`.

Data versus code (design map R7). The registry (ids, keys, classes, default components, the helpers) and the engines
are code and are specified here. The 22 `jukebox_song` entries, the 8 `instrument` entries, the 43 `banner_pattern`
entries, the item tags (`loom_patterns`, `creeper_drop_music_discs`, the banner pattern tags) and the item model files
are data of the jar and are not tabulated; where a row needs a value of a data file (a song length, a comparator
output) it is quoted as a worked example only.

## Contents

1. Scope, and corrections to the brief and to earlier text
2. Id arithmetic and the 45 statements
3. The rows
4. Music discs: the item rows
5. Jukebox playback (the engines the disc rows feed)
6. `disc_fragment_5`
7. `trident`
8. `nautilus_shell`, the nautilus armors, `heart_of_the_sea`
9. `crossbow`
10. `suspicious_stew`
11. `loom` and the banner pattern items
12. `goat_horn`
13. Worked examples
14. Validation
15. Open questions

## 1. Scope, and corrections to the brief and to earlier text

1. **The brief's range holds more than named.** Ids 1129 to 1135 (`nautilus_shell`, five nautilus armors,
   `heart_of_the_sea`) and 1138 (`loom`) lie between the items the brief names and are in the range; they are
   specified here (sections 8 and 11).
2. **Nautilus armor has no durability and no repair rule.** 17 section 1.4 describes `nautilusArmor` as "like humanoid with the
   body slot (durability multiplier x 16)". The builder `Item$Properties.nautilusArmor` was read in full: it sets
   attributes, the `equippable` component and stack size 1 and nothing else; there is no `durability`, `repairable`
   or `enchantable` call (compare `wolfArmor`, which does set `durability` and `repairable`). Section 8 states the read
   behaviour, which supersedes the 17 wording for the five rows.
3. **Crossbow arrows are critical arrows only when a player shoots.** 17 section 3.9 says the crossbow's `createProjectile`
   passes the constant true. The bytecode of `CrossbowItem.createProjectile` passes its own boolean parameter through to
   `ProjectileWeaponItem.createProjectile`, and `performShooting` supplies `shooter instanceof Player` for it (section 9.5).
   A crossbow fired by a mob therefore makes non-critical arrows. Everything else of 17 section 3.9 that was re-read here
   (charge time, power constants, durability use, multishot offsets) agrees; the sound pitch formulas of section 9.6 are
   more exact than the values listed in 17.
4. The jukebox block and its `has_record` state are 24 section 7.11. The block entity's persistence, ticking and the song player are
   specified here (section 5) because the disc rows are their only input.
5. Conflict for the owner of 17: 17 section 3.9 (crossbow passes constant true for the crit flag) and 17 section 1.4 (nautilus armor durability multiplier x 16) disagree with the bytecode as read here (corrections 2 and 3); this document is not authoritative over 17's text and the orchestrator should have 17 corrected.

## 2. Id arithmetic and the 45 statements

Registry ids follow the registration order of `Items.<clinit>` (25 part 1 section 2); the first statement is `air` = 0. The number of
`putstatic` statements before `MUSIC_DISC_13` was counted in the class and is **1105** (statements 0 to 1104 precede it), which
makes `music_disc_13` id 1105. The 45 statements of this part follow with no gap, in the order of the table below. Statement kinds:
discs: `registerItem(key, Properties)`; `disc_fragment_5`, `trident`, `crossbow`, `goat_horn`: `registerItem(key, Function, Properties)` with an
item class constructor (`DiscFragmentItem`, `TridentItem`, `CrossbowItem`, `InstrumentItem`); the nautilus items, `heart_of_the_sea`,
`suspicious_stew` and the banner patterns: `registerItem(key, Properties)` (class `Item`); `loom`: `registerBlock(BlockItemId, Block, UnaryOperator)` (class `BlockItem`, 25 part 1 section 5.2).

`registerItem(key, function, properties)` does: apply the function to `properties.setId(key)`, register the result in
`BuiltInRegistries.ITEM`, and, for a `BlockItem`, add it to `Item.BY_BLOCK` (25 part 1 section 3).

## 3. The rows

Columns as 25 part 1 section 10. "Prototype" = the 13 common components (25 part 1 section 7.1) plus the components in the last column.
`rarity R` replaces the common `COMMON`. Stack size is the `max_stack_size` of the prototype.

| Id | Key | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 1105 | `music_disc_13` | `Item` | 1 | rarity uncommon; `jukebox_playable` song `13` |
| 1106 | `music_disc_cat` | `Item` | 1 | rarity uncommon; song `cat` |
| 1107 | `music_disc_blocks` | `Item` | 1 | rarity uncommon; song `blocks` |
| 1108 | `music_disc_bounce` | `Item` | 1 | rarity uncommon; song `bounce` |
| 1109 | `music_disc_chirp` | `Item` | 1 | rarity uncommon; song `chirp` |
| 1110 | `music_disc_creator` | `Item` | 1 | rarity **rare**; song `creator` |
| 1111 | `music_disc_creator_music_box` | `Item` | 1 | rarity uncommon; song `creator_music_box` |
| 1112 | `music_disc_far` | `Item` | 1 | rarity uncommon; song `far` |
| 1113 | `music_disc_lava_chicken` | `Item` | 1 | rarity **rare**; song `lava_chicken` |
| 1114 | `music_disc_mall` | `Item` | 1 | rarity uncommon; song `mall` |
| 1115 | `music_disc_mellohi` | `Item` | 1 | rarity uncommon; song `mellohi` |
| 1116 | `music_disc_stal` | `Item` | 1 | rarity uncommon; song `stal` |
| 1117 | `music_disc_strad` | `Item` | 1 | rarity uncommon; song `strad` |
| 1118 | `music_disc_ward` | `Item` | 1 | rarity uncommon; song `ward` |
| 1119 | `music_disc_11` | `Item` | 1 | rarity uncommon; song `11` |
| 1120 | `music_disc_wait` | `Item` | 1 | rarity uncommon; song `wait` |
| 1121 | `music_disc_otherside` | `Item` | 1 | rarity **rare**; song `otherside` |
| 1122 | `music_disc_relic` | `Item` | 1 | rarity uncommon; song `relic` |
| 1123 | `music_disc_5` | `Item` | 1 | rarity uncommon; song `5` |
| 1124 | `music_disc_pigstep` | `Item` | 1 | rarity **rare**; song `pigstep` |
| 1125 | `music_disc_precipice` | `Item` | 1 | rarity uncommon; song `precipice` |
| 1126 | `music_disc_tears` | `Item` | 1 | rarity uncommon; song `tears` |
| 1127 | `disc_fragment_5` | `DiscFragmentItem` | 64 | rarity uncommon |
| 1128 | `trident` | `TridentItem` | 1 | rarity rare; `max_damage` 250, `damage` 0; `attribute_modifiers` (section 7); `tool` (empty rules, default speed 1.0, damage per block 2, creative break not allowed); `enchantable` 1; `weapon` (item damage per attack 1, disable-blocking seconds 0.0) |
| 1129 | `nautilus_shell` | `Item` | 64 | rarity uncommon |
| 1130 | `iron_nautilus_armor` | `Item` | 1 | nautilus armor builder, material iron (section 8) |
| 1131 | `golden_nautilus_armor` | `Item` | 1 | material gold |
| 1132 | `diamond_nautilus_armor` | `Item` | 1 | material diamond |
| 1133 | `netherite_nautilus_armor` | `Item` | 1 | material netherite; `fireResistant()` |
| 1134 | `copper_nautilus_armor` | `Item` | 1 | material copper |
| 1135 | `heart_of_the_sea` | `Item` | 64 | rarity uncommon |
| 1136 | `crossbow` | `CrossbowItem` | 1 | `cooking_fuel` burn-time provider `cooking/time_wood_items_small`, speed provider the default `cooking/speed_default` (`Item$Properties.cookingFuel(key)` builds `CookingFuel(key, COOKING_DEFAULT_SPEED_MULTIPLIER)`; 25 part 1 section 9); `max_damage` 465, `damage` 0; `charged_projectiles` = empty; `enchantable` 1 |
| 1137 | `suspicious_stew` | `Item` | 1 | `food` (6, saturation 7.2, always edible); `consumable` = `Consumables.DEFAULT_FOOD`; `suspicious_stew_effects` = empty; `use_remainder` = one `bowl` |
| 1138 | `loom` | `BlockItem` | 64 | registered through `registerBlock` with `BlockItemIds.LOOM` and a `UnaryOperator` lambda (`Items.lambda$static$299`, read in full: its whole body is one `cookingFuel` call with `ContextIntProviders.COOKING_TIME_WOOD_BLOCKS`, and nothing else); `cooking_fuel` burn-time provider `cooking/time_wood_blocks`, speed provider the default `cooking/speed_default` (25 part 1 section 9) |
| 1139 | `flower_banner_pattern` | `Item` | 1 | `provides_banner_patterns` tag `pattern_item/flower` (rarity common) |
| 1140 | `creeper_banner_pattern` | `Item` | 1 | rarity uncommon; tag `pattern_item/creeper` |
| 1141 | `skull_banner_pattern` | `Item` | 1 | rarity rare; tag `pattern_item/skull` |
| 1142 | `mojang_banner_pattern` | `Item` | 1 | rarity rare; tag `pattern_item/mojang` |
| 1143 | `globe_banner_pattern` | `Item` | 1 | rarity common; tag `pattern_item/globe` |
| 1144 | `piglin_banner_pattern` | `Item` | 1 | rarity uncommon; tag `pattern_item/piglin` |
| 1145 | `flow_banner_pattern` | `Item` | 1 | rarity rare; tag `pattern_item/flow` |
| 1146 | `guster_banner_pattern` | `Item` | 1 | rarity rare; tag `pattern_item/guster` |
| 1147 | `field_masoned_banner_pattern` | `Item` | 1 | rarity common; tag `pattern_item/field_masoned` |
| 1148 | `bordure_indented_banner_pattern` | `Item` | 1 | rarity common; tag `pattern_item/bordure_indented` |
| 1149 | `goat_horn` | `InstrumentItem` | 1 | rarity uncommon; `instrument` default = the instrument `ponder_goat_horn` |

Notes on the rows:

- A disc's key is not typed in `ItemIds`: `ItemIds.createMusicDisc(songKey)` derives it as `music_disc_` followed by the path of the
  jukebox song key (a dependent resource key, recipe `music_disc_\u0001`). The song key path of each disc is the text after
  `music_disc_` (so disc `music_disc_11` plays song `11`, `music_disc_5` plays song `5`).
- `jukebox_playable`, `provides_banner_patterns` and `instrument` are **delayed components** (25 part 1 section 6.2): their values
  are built when the item component initialisers run against the loaded registries, because they hold registry entries.
  A client or server that builds prototypes before the `jukebox_song`, `banner_pattern` and `instrument` registries are
  loaded cannot fill them (23 gives the loading order).
- The `rarity` component is always present (common is the default). The rare discs are exactly four: creator, lava_chicken,
  otherside, pigstep. Counts: 22 discs = 18 uncommon + 4 rare; 10 banner patterns = 4 common + 2 uncommon + 4 rare.
- Item description id (translation key) is `item.minecraft.<key>` for every row except `loom`, which is a block item and uses
  `block.minecraft.loom` (25 part 1 section 6.3). The model is `item_model` = the key itself (an item definition file in the resource pack).
- `use_remainder` for the stew is stored as an item stack template of one bowl (`usingConvertsTo`, 25 part 1 section 6.4).

### 3.1 Item tags that name these items (data, names only)

Read from the tag files of the jar: `creeper_drop_music_discs` lists 12 discs (13, cat, blocks, chirp, far, mall, mellohi, stal,
strad, ward, 11, wait); `loom_patterns` lists the ten banner pattern items; `trident` is in `breaks_decorated_pots`, `drowned_preferred_weapons`, `enchantable/trident` and
`enchantable/durability`; `crossbow` is in `piglin_preferred_weapons`, `pillager_preferred_weapons`,
`wither_skeleton_disliked_weapons`, `enchantable/crossbow` and `enchantable/durability`; `golden_nautilus_armor` is in `piglin_loved`.
The `enchantable/*` tags are what make the `enchantable` 1 component usable: the `supported_items` of an enchantment names such a tag
(for example Riptide names `enchantable/trident`; 28). `creeper_drop_music_discs` is the only item tag in the jar with "music" or "disc" in its name
(there is no tag file named `music_discs`). The other 10 discs (creator, creator_music_box, bounce, lava_chicken, otherside, relic, 5, pigstep, precipice, tears) are in no
item tag, and none of `disc_fragment_5`, `suspicious_stew`, `goat_horn`, `heart_of_the_sea`, `nautilus_shell` and `loom` is in any item tag. The engines that
read these tags are in 18 to 21 and in the creeper loot rules; they are data lookups only.

## 4. Music discs: the item rows

### 4.1 The `jukebox_playable` component (type id 66)

`Item$Properties.jukeboxPlayable(songKey)` appends a delayed initialiser that sets `jukebox_playable` to
`JukeboxPlayable(holder of the song from the jukebox_song registry)`; the lookup is `getOrThrow(key)`, so a missing song entry fails the load.

| Aspect | Value |
|---|---|
| Record | `JukeboxPlayable(song: Holder<JukeboxSong>)` |
| Persistent form (item component JSON/NBT) | `JukeboxSong.CODEC` = a registry holder codec: a song identifier string (`minecraft:13`), or an inline direct song object (`JukeboxSong.DIRECT_CODEC`, section 4.2) |
| Wire form | `Holder<JukeboxSong>` (00 section 10.2): VarInt `id + 1` for a registered song, or `0` followed by the inline song (4.2 wire). The id is the index in the `jukebox_song` registry (04 section 6, 23); it is the order that registry's entries were sent in, not a property of the disc |
| `cacheEncoding` | not set for this type (the other four components of this part set it) |
| Tooltip | one line: the song's `description` with style colour gray (`JukeboxPlayable.addToTooltip`), merged on the description's own style |

### 4.2 The `jukebox_song` entry (`JukeboxSong.DIRECT_CODEC`; data, schema only)

| Field | Type | Rule |
|---|---|---|
| `sound_event` | sound event holder (identifier string or inline) | the music played |
| `description` | text component | shown in the tooltip and as the "now playing" text |
| `length_in_seconds` | float | strictly positive (`POSITIVE_FLOAT`) |
| `comparator_output` | int | 0 to 15 (`ExtraCodecs.intRange(0, 15)`) |

Wire (`JukeboxSong.DIRECT_STREAM_CODEC`): sound event (its stream codec), text component, Float, VarInt, in the order of the table
(`sound_event`, `description`, `length_in_seconds`, `comparator_output`). 04 section 6 and 23 give the registry-level schema checks.
The jar holds 22 song files (counted from the archive), one per disc of this part. Derived (`JukeboxSong`):

- `lengthInTicks = ceil(length_in_seconds x 20)` (float arithmetic, `Mth.ceil`).
- `hasFinished(t) = t >= lengthInTicks + 20` (a 20 tick pause after the music).

## 5. Jukebox playback (the engines the disc rows feed)

The block is 24 section 7.11 (`has_record`, signal, empty-hand pop). Items and ticks:

### 5.1 Inserting a disc (`JukeboxPlayable.tryInsertIntoJukebox`, called from the jukebox's use-with-item)

Inputs: level, block position, the held stack, the player. Steps:

1. If the stack has no `jukebox_playable`, return "try with empty hand" (the block then runs its empty-hand rule).
2. If the block at the position is not a `jukebox`, or its `has_record` is true, return "try with empty hand".
3. On the server only: take one item from the stack (`consumeAndReturn(1, player)`: creative players keep theirs, 17 section 1 / 13 section 3); get the block
   entity; if it is a `JukeboxBlockEntity`, call `setTheItem(taken)` (5.2); fire game event `block_change` (source: the player and the block state);
   award the custom stat `play_record` to the player.
4. Return success (on both sides; the client side does nothing else).

### 5.2 The block entity (`JukeboxBlockEntity`, id in 46 section 5 block entity types)

State: one item (`item`, default empty) and a `JukeboxSongPlayer`. Persistence: NBT field `RecordItem` (an item stack, written only when non-empty)
and `ticks_since_song_started` (long, written only when the player has a song). Loading: read `RecordItem` (default empty); if the stored stack
is different from the current one (item or components) and the current is non-empty, the player is stopped (5.3 stop); store the loaded stack;
then, if `ticks_since_song_started` exists, call `setSongWithoutPlaying(song of the stack, ticks)` (lost if the song `hasFinished` at that tick count).
(The loading routine, the song player and the client event are re-specified with their block coupling in 31 section 2 (31 part 4), which closes Open question 7 and is the authority if the two texts differ.)

| Rule | Value |
|---|---|
| Capacity | 1 (`getMaxStackSize` = 1) |
| `canPlaceItem` | the stack has `jukebox_playable` and the slot is empty |
| `canTakeItem` | the container still has any item matching a predicate (hopper rule; the predicate itself is a lambda not traced) |
| `setTheItem(stack)` | store; set the block state `has_record` = (stack non-empty) with flag 2 (block update to clients), fire `block_change`; then: if non-empty and the stack has a song, `play(level, song)`; else `stop` |
| `splitTheItem(n)` | returns the item and sets the slot empty (always the whole item) |
| Comparator output | the song's `comparator_output`, or 0 when the item has no song |
| `popOutTheItem` (server only; also on block removal, `preRemoveSideEffects`) | if non-empty: take the item out, spawn an item entity at `Vec3.atLowerCornerWithOffset(pos, 0.5, 1.01, 0.5)` displaced by `offsetRandomXZ(random, 0.7)` (a random horizontal offset of at most 0.7), default pickup delay (10, 44 / 18 section 6.11), then `onSongChanged` |
| `onSongChanged` | update neighbours of the position for this block, mark the entity changed |
| `setRemoved` | fire game event `jukebox_stop_play`, send level event 1011 (data 0) |
| Tick | `JukeboxSongPlayer.tick(level, state)` every tick (the block only ticks while `has_record`, 24 section 7.11) |

### 5.3 The song player (`JukeboxSongPlayer`)

See also 31 section 2 (31 part 4), which restates this player and is the authority on any difference.

State: `song` (empty or a holder), `ticksSinceSongStarted` (long). `PLAY_EVENT_INTERVAL_TICKS` = 20.

- `play(level, song)`: set the song, `ticks = 0`, send **level event 1010** at the block position with data = the song's index in the `jukebox_song`
  registry, then `onSongChanged`.
- `stop(level, state)`: if no song, nothing. Else clear the song and `ticks = 0`, fire game event `jukebox_stop_play`, send **level event 1011** (data 0),
  `onSongChanged`.
- `tick`: if no song, return. If `song.hasFinished(ticks)`, `stop` and return. Otherwise (1) when `shouldEmitJukeboxPlayingEvent` holds (`ticks mod 20 == 0`, a long remainder): fire game
  event `jukebox_play` and spawn note particles (below); (2) in every case, whether or not step 1 ran, `ticks = ticks + 1`. Order read in the bytecode: finished check, then stop and
  return; else the optional emit; then the unconditional increment.
- Note particles (server): at the block's bottom centre plus (0, 1.2000000476837158, 0) (the double widened from the float 1.2; 31 section 2 gives it exactly), the particle `note`, count 0, offset x = `nextInt(4) / 24.0` (float), y = 0, z = 0,
  speed 1.0 (so the colour of the note comes from the x offset); `nextInt(4)` uses the level's random source.
- `setSongWithoutPlaying(song, ticks)`: ignored when `hasFinished(ticks)`, else set the song and ticks without sending an event.

Level events travel in the Level Event packet (05a 0x2F: Int event, Position, Int data, Boolean global).

### 5.4 Client playback (`LevelEventHandler`)

- Event 1010 (data = song index): look the song up by registry index (`Registry.get(int)`); if present, `playJukeboxSong(song, pos)`: stop any sound already playing at
  that position (the client keeps a map position to sound instance), create a sound with `SimpleSoundInstance.forJukeboxSong(sound, centre of the block)`:
  source `records`, **volume 4.0**, pitch 1.0, linear attenuation, not looping, no delay, position = centre of the block; register it; set the HUD "now playing" text to the
  song `description`; notify living entities within the block's box inflated by **3.0** (`setRecordPlayingNearby(pos, true)`, declared in `LivingEntity` as an empty method, not in `Entity`; `Parrot` overrides it to store the jukebox position, 19; the notified set is the `LivingEntity`
  instances in that box; a scan of every `net/minecraft` class for the name `setRecordPlayingNearby` finds only `LivingEntity` (declaration), `Parrot` (override) and `LevelEventHandler` (caller), so the Parrot is the only overrider).
- Event 1011: stop the sound at the position and notify the same entities with false.

## 6. `disc_fragment_5`

`DiscFragmentItem` extends `Item` with no extra state. Rarity uncommon, stack size 64. It overrides two methods (read): `getDisplayName()` returns a translatable component whose key is the item's description id followed by `.desc` (so
`item.minecraft.disc_fragment_5.desc`), and `appendHoverText` adds exactly that component (the result of `getDisplayName()`) as one tooltip line styled gray. The stack's own name (`getName` and the `item_name` component) is
untouched, so the `.desc` text appears only as the tooltip line. `DiscFragmentItem` is the only item class found that appends a `.desc` line (section 11.2). It is a crafting ingredient only (recipes are data).

## 7. `trident`

Class `TridentItem`; the numbers of the throw, Loyalty, Riptide and Channeling are in 17 section 3.10; this section adds the registering constants and the rules the item class itself
enforces, in call order.

**Prototype.** `max_damage` 250 (so stack 1, `damage` 0), rarity rare, `enchantable` 1, `weapon` (1 durability per attack, disable-blocking 0.0 s).
`attribute_modifiers`: `attack_damage` +8.0 (operation add value, identifier `minecraft:base_attack_damage`, main hand) and `attack_speed` -2.9000000953674316
(`minecraft:base_attack_speed`, main hand); with the player base values (17 section 1.5, 4.0 attack speed and 1.0 attack damage) that gives damage 9 and speed 1.1.
`tool`: no rules, default mining speed 1.0, 2 durability per block, `can_destroy_blocks_in_creative` false.
Use animation `trident`; use duration constant 72000 ticks (`getUseDuration`).

**Use** (`TridentItem.use`): (1) if the next point of damage would break the stack (`nextDamageWillBreak`), FAIL. (2) Let `s` = the trident spin attack strength
(Riptide, 28 / 17 section 3.10). If `s > 0` and the player is not in water or rain, FAIL. (3) Start using the item; CONSUME.

**Release** (`TridentItem.releaseUsing(stack, level, entity, remainingUseTicks)`), in order; it returns false for every early exit and, as step 8 states, also for a normal throw on a non-server level:

1. Only for a player; `used = 72000 - remainingUseTicks`; if `used < 10` return false.
2. `s` = spin attack strength. If `s > 0` the player must be in water or rain and not a passenger, else false.
3. If the next damage would break the stack, false.
4. Choose the throw sound: the highest-level `trident_sound` enchantment effect, default `item.trident.throw`.
5. Award the `item_used` stat for the trident.
6. On a `ServerLevel`: `hurtWithoutBreaking(1, player)` (the stack loses 1 durability and is never destroyed by this call). Then, only when `s == 0`: take one item from the
   hand stack, spawn a `ThrownTrident` from the player's rotation with extra pitch 0, **velocity 2.5, inaccuracy 1.0**; if the player has infinite materials the entity's pickup mode is
   `CREATIVE_ONLY`; play the chosen sound with `Level.playSound(except = none, source = the spawned ThrownTrident, sound, source players, volume 1.0, pitch 1.0)` (descriptor Entity, Entity, SoundEvent, SoundSource, float, float; read: the entity argument is the local that holds the spawned projectile, not the player), then return true. Only the Riptide sound of step 7 uses the player as that entity.
7. If `s > 0` (Riptide): normalise the look vector `(-sin(yaw) cos(pitch), -sin(pitch), cos(yaw) cos(pitch))` (angles in radians via 0.017453292), scale it to length `s`, push the player by it, start the auto-spin attack for **20 ticks with 8.0 damage**
   carrying the stack; if on ground first move the player up by 1.2 blocks (the value 1.1999999 as a float, 1.1999999284744263 as a double); play the sound of step 4 (the same holder; there is no separate riptide constant in `TridentItem`) at the player with source players, volume 1.0, pitch 1.0 and no excluded entity; return true.
   The data of Riptide (`data/minecraft/enchantment/riptide.json`) sets `trident_sound` to three events in this order: `item.trident.riptide_1`, `item.trident.riptide_2`, `item.trident.riptide_3`. `EnchantmentHelper.pickHighestLevel` (read) takes the effect list and the highest enchantment level L and returns the list element at index `min(L, list size) - 1`: levels 1 to 3 give `riptide_1` to `riptide_3`, and a level above the list size gets the last entry (strength numbers in 17 section 3.10: linear base 1.5, 0.75 per level above first, read in the data). **Step 7 is not inside the `ServerLevel` check**: the bytecode of step 6 jumps past the server-only block when the level is not a `ServerLevel`, so the push, the 1.2 block move, the spin attack
   and the sound also run on the client side.
8. The method returns true in exactly two places: after the `s == 0` throw on a `ServerLevel` (step 6) and after the Riptide branch (step 7). The remaining case is a non-server (client) level with `s == 0`: step 6 is skipped and the bytecode returns false. So for a normal throw the client-side result of release (false) differs from the server's (true); a Riptide release returns true on both sides.

**Dispenser** (`asProjectile`): a `ThrownTrident` at the dispenser position with a one-item copy of the stack, pickup mode `ALLOWED`.

## 8. `nautilus_shell`, the nautilus armors, `heart_of_the_sea`

- `nautilus_shell` (1129) and `heart_of_the_sea` (1135): plain `Item`, stack 64, rarity uncommon, nothing else. (Their uses are in recipes, nautilus loot and 21.)
- The five armors are `Item` instances built by `Item$Properties.nautilusArmor(material)` with `ArmorMaterials` iron, gold, diamond, netherite, copper. What the builder sets, all read:
  1. `attribute_modifiers` = `ArmorMaterial.createAttributes(BODY)`: an `armor` modifier of the material's body defense, added with identifier `minecraft:armor.body` (recipe `armor.\u0001` with the armor type name `body`), main slot group "body"
     (`EquipmentSlotGroup.bySlot(BODY)`), operation add value; an `armor_toughness` modifier with the material's toughness; a `knockback_resistance` modifier only when the material's value is above 0.
     The numbers per material are the "Body" column of 17 section 2.5 (copper 4, iron 5, golden 7, diamond 11, netherite 19), toughness diamond 2, netherite 3, others 0, knockback resistance netherite 0.1.
  2. `equippable`: slot body; equip sound `armor.equip_nautilus`; asset = the material's asset id; allowed entities = the entity type tag `can_wear_nautilus_armor`; `damage_on_hurt` **false**;
     `equip_on_interact` true; `can_be_sheared` true; shearing sound `armor.unequip_nautilus`. (Equipment asset and the dispense behaviour are data and 21.)
  3. `max_stack_size` 1.
  4. `netherite_nautilus_armor` additionally sets `damage_resistant` (the fire-damage tag, `fireResistant()`).
- There is no `max_damage`, `damage`, `repairable` or `enchantable` component on these rows (section 1, correction 2), and `damage_on_hurt` is false, so the armor never loses durability.

## 9. `crossbow`

Class `CrossbowItem extends ProjectileWeaponItem`. Constants: `MAX_CHARGE_DURATION` 1.25 s; `DEFAULT_RANGE` 8; `START_SOUND_PERCENT` 0.2; `MID_SOUND_PERCENT` 0.5; `ARROW_POWER` 3.15; `FIREWORK_POWER` 1.6; `MOB_ARROW_POWER` 1.6;
`getDefaultProjectileRange()` 8. Prototype: section 3 (465 durability, `charged_projectiles` empty, enchantable 1, burn time `cooking/time_wood_items_small` (speed provider the default `cooking/speed_default`), which is the integer provider `300 / factor` where factor 1 in a furnace and 2 in a smoker or blast furnace: 300 ticks; 25 part 1 section 9).
Use animation `crossbow`; `getUseDuration` 72000. The instance holds two booleans for the loading sounds (`startSoundPlayed`, `midLoadSoundPlayed`, both false initially); they are per item type, not per stack (inferred from the fields being on the item instance; Open question 8).

### 9.1 Projectile predicates

`ProjectileWeaponItem.ARROW_ONLY` = the stack is in item tag `arrows`; `ARROW_OR_FIREWORK` = `ARROW_ONLY` or the stack is `firework_rocket`. For the crossbow: held projectiles (`getSupportedHeldProjectiles`) = `ARROW_OR_FIREWORK`;
projectiles searched in the inventory (`getAllSupportedProjectiles`) = `ARROW_ONLY`.

`Player.getProjectile(weaponStack)`: if the weapon item is not a `ProjectileWeaponItem`, empty. Else (1) `getHeldProjectile(player, held predicate)`: test the **off hand first**, then the **main hand**, return the first that matches; if not empty, that is the result.
(2) Otherwise scan inventory slots in index order (0 up, the whole container) and return the first stack matching the all-projectiles predicate. (3) If neither the held stacks nor the scan match: when the player has infinite materials, a new stack of the plain `arrow` item; otherwise the empty stack. A creative player with no ammunition can therefore start charging and load a plain arrow;
by 9.4 step 1 its cost is 0, so the loaded arrow is an intangible copy.

### 9.2 Use (`CrossbowItem.use(level, player, hand)`)

1. Read `charged_projectiles` of the held stack. If present and non-empty: `performShooting(level, player, hand, stack, power, 1.0, null)` with `power` = **1.6 if the charged list contains a `firework_rocket`, else 3.15** (`getShootingPower`); return CONSUME.
2. Else if `player.getProjectile(stack)` is non-empty: set both sound flags false, start using the item, return CONSUME.
3. Else FAIL.

### 9.3 Charging, loading, release

- `getChargeDuration(stack, entity)` = `floor(modifyCrossbowChargingTime(stack, entity, 1.25) x 20)` ticks (the `crossbow_charge_time` effect: Quick Charge level L subtracts 0.25 s per level, 28; so 25, 20, 15, 10 ticks for L = 0 to 3).
- `getPowerForTime(usedTicks) = min(usedTicks / chargeDuration, 1.0)` (float division).
- `onUseTick(level, entity, stack, remainingUseTicks)` runs each tick of use, **server only**. Let `progress = (stack.getUseDuration(entity) - remainingUseTicks) / chargeDuration` (float). Charging sounds `(start, mid, end)` are the highest-level `crossbow_charging_sounds` enchantment effect of the stack, default (`item.crossbow.loading_start`, `item.crossbow.loading_middle`, `item.crossbow.loading_end`). Then:
  1. if `progress < 0.2`: both flags false;
  2. if `progress >= 0.2` and the start flag is false: set it, play the start sound if present;
  3. if `progress >= 0.5` and the mid flag is false: set it, play the mid sound if present;
  4. if `progress >= 1.0` and the stack is not charged and `tryLoadProjectiles` succeeds: play the end sound if present.
  Quick Charge (`quick_charge.json`) sets `crossbow_charging_sounds` to three entries, one per level, with no `mid` key (so no mid sound while it applies): level 1 start `item.crossbow.quick_charge_1`, level 2 `item.crossbow.quick_charge_2`, level 3 `item.crossbow.quick_charge_3`; the end sound is `item.crossbow.loading_end` for all three. Its `crossbow_charge_time` is linear, base -0.25, -0.25 per level above first (20, 15, 10 ticks for levels 1 to 3). The pick is `EnchantmentHelper.pickHighestLevel`: the entry at index `min(L, list size) - 1` for highest level L (read), so level L gets entry L here and `quick_charge_3` for any level above 3; 28 owns the enchantment effect components.
  Start and mid sounds are played at the entity's position, source `players`, volume 0.5, pitch 1.0. The end sound is played at the entity's position with the entity's own sound source, volume 1.0, pitch `1.0 / (random.nextFloat() x 0.5 + 1.0) + 0.2` using the level's random source.
  (Read: the bootstrap methods of `onUseTick` bind `lambda$onUseTick$0` to the start step, `$1` to the mid step and `$2` to the end step; `$0` and `$1` have identical bodies, `$2` is the different one.)
- `tryLoadProjectiles(shooter, stack)`: `list = draw(stack, shooter.getProjectile(stack), shooter)`; if the list is non-empty, set `charged_projectiles` to `ChargedProjectiles.ofNonEmpty(list)` and return true; else false.
- `releaseUsing(stack, level, entity, remaining)`: returns true only when `getPowerForTime(useDuration - remaining) >= 1.0` and the stack is already charged. It loads nothing and fires nothing: stopping early cancels charging.
  `useOnRelease(stack)` is true for crossbow stacks.
- `isCharged(stack)` = `charged_projectiles` (default empty) is non-empty.

### 9.7 The `charged_projectiles` component (type id 51; `ChargedProjectiles`)

Read from `ChargedProjectiles` and its registration in `DataComponents`. 17 line 92 calls it a "list of item stacks"; precisely it is a list of **item templates**.

| Aspect | Value |
|---|---|
| Value | a record holding `List<ItemStackTemplate>` (a template is the id, count and component patch of a stack without the stack's mutable state; the template codecs are the item stack codecs of 00 and 25 part 1); empty value `EMPTY` is the empty list |
| Size limit | `MAX_SIZE` = 1024 entries. The record constructor throws `IllegalArgumentException` for a larger list; the persistent codec is `sizeLimitedListOf(1024)` of the `ItemStackTemplate` codec, so oversized input fails to decode, and `ofNonEmpty` truncates with `limit(1024)` and logs the warning "Tried to load invalid items as charged projectiles" when any entry was dropped |
| Persistent codec | a list of the `ItemStackTemplate` codec, mapped to and from the record |
| Wire | a list (VarInt count, bounded at 1024) of the `ItemStackTemplate` stream codec |
| `cacheEncoding` | set (read in the registering lambda, together with `persistent` and `networkSynchronized`) |
| `ofNonEmpty(stacks)` | drops empty stacks, converts the rest to templates |
| Tooltip | a tooltip provider, added by the generic component loop of `ItemStack.addDetailsToTooltip` (it sits between written book content and fireworks). It groups consecutive equal stacks (`ItemStack.matches`) and emits per group one translatable line: `item.minecraft.crossbow.projectile.single` with the stack's display name when the count is 1 ("Projectile: %s"), or `item.minecraft.crossbow.projectile.multiple` with the count and the hover name ("Projectile: %s x %s"). After each such line it adds the projected stack's own detail lines (`addDetailsToTooltip` with the normal flag and no player), each line prefixed by a short literal and styled gray. No flag test (advanced or creative) was found in either method, so these nested lines are not conditional on advanced tooltips (the earlier reading in this review that they are advanced-only is not supported by the bytecode) |

### 9.4 Drawing the ammunition (`ProjectileWeaponItem.draw`, `useAmmo`)

`draw(weapon, ammoStack, shooter)`: if `ammoStack` is empty, return an empty list. Let `n` = `processProjectileCount(level, weapon, shooter, 1)` on a `ServerLevel` (the effect `projectile_count`, Multishot adds 2, 28), else 1.
Take a working copy of the ammo stack. For `i` in 0 to `n - 1`: `useAmmo(weapon, source, shooter, extra = i > 0)` where `source` is the real stack for `i = 0` and the working copy for later `i`; append every non-empty result.

`useAmmo(weapon, ammo, shooter, extra)`:
1. `cost` = 0 when `extra` is true or the shooter has infinite materials or the level is not a server level; else `processAmmoUse(level, weapon, ammo, 1)` (the effect `ammo_use`, Infinity reduces it to 0, 28).
2. If `cost > ammo.count`, result empty.
3. If `cost == 0`: result = a one-item copy of the ammo marked with the `intangible_projectile` component (type id 22, a Unit: no payload on the wire; a marker, so the arrow cannot be picked up as an item: it can only be picked up in the creative-only mode). Tooltip (read): `ItemStack.addDetailsToTooltip` has a unit-component branch for it that adds the translatable component `item.intangible` ("Intangible" in `en_us.json`) styled gray, when the stack has the component and the stack's `tooltip_display` shows it (the generic unit-component test: has component and shows type); the ammo stack is untouched.
4. Else: result = `ammo.split(cost)`; if the ammo stack became empty and the shooter is a player, remove it from the player's inventory. Return the result.
Consequence: with Multishot (n = 3) and no Infinity, the first arrow costs one item and the two extras are free intangible copies.

### 9.5 Firing (`performShooting`, `ProjectileWeaponItem.shoot`)

`performShooting(level, shooter, hand, stack, power, inaccuracy, target)`: only on a `ServerLevel`. Set `charged_projectiles` to empty and keep the previous value; if it was null or empty return. The previous list's item copies are the projectiles. Call
`shoot(level, shooter, hand, stack, projectiles, power, inaccuracy, isCrit = (shooter is a Player), target)`. Then, for a `ServerPlayer`: trigger the `shot_crossbow` criterion with the stack, award the `item_used` stat for the crossbow.

`shoot(...)`:
1. `spread` = `processProjectileSpread(level, weapon, shooter, 0.0)` (effect `projectile_spread`, 28; the crossbow's value is 10 degrees only when Multishot adds it: 17 section 3.9 reads 10).
2. `n` = list size. `step` = 0 if `n == 1`, else `2 x spread / (n - 1)`. `base` = `((n - 1) mod 2) x step / 2`. A direction sign starts at +1.
3. For `i` in 0 to `n - 1`, with `p = list[i]`: if `p` is empty, skip to the next `i` **before** the sign flip (read: the empty branch jumps to the loop increment, past the flip), so the sign alternates only over non-empty entries while `i` (and so the `floor((i + 1) / 2)` factor) still counts every entry. Otherwise `angle = base + sign x floor((i + 1) / 2) x step` (integer division by 2 of `i + 1`); then `sign = -sign`.
   Create the projectile (`createProjectile`, 9.5.1), then spawn it with a callback that calls `shootProjectile(shooter, projectile, i, power, inaccuracy, angle, target)` before the entity enters the world.
   Then the weapon loses `getDurabilityUse(p)` durability (hurt and break, in the hand's equipment slot): **3 when `p` is a firework rocket, else 1**. If the weapon stack became empty, stop the loop.
   Offsets for n = 3 and spread 10: `i=0`: 0; `i=1`: -10; `i=2`: +10 (degrees). For n = 2 and spread 10: step 20, base 10: `i=0`: +10; `i=1`: -10.

### 9.5.1 `createProjectile(level, shooter, weapon, ammo, isCrit)`

- If `ammo` is a `firework_rocket`: a `FireworkRocketEntity` with the stack, owner the shooter, at `(shooter.x, shooter.eyeY - 0.15000000596046448, shooter.z)` (the float 0.15 widened to a double) with the "shot at angle" flag true.
- Else: the base rule creates an arrow through the arrow item's `createArrow(level, ammo, shooter, weapon)` (the `ArrowItem` of the ammo stack, or the plain `arrow` item when the ammo is not an `ArrowItem`), and sets the crit flag when `isCrit` is true; for an `AbstractArrow` the crossbow then sets its hit sound to `item.crossbow.hit` (the sound event read in `CROSSBOW_HIT`).

### 9.6 `shootProjectile` and the sound

`shootProjectile(shooter, projectile, index, power, inaccuracy, angle, target)`:
- **With no target** (a player): `dir` = the shooter's view vector (partial tick 1.0) rotated by `angle` degrees (converted with 0.017453292) about the shooter's up vector (`getUpVector(1.0)`); call `projectile.shoot(dir.x, dir.y, dir.z, power, inaccuracy)` (the shot adds the shooter's movement and the random inaccuracy: 17 section 3.9).
- **With a target** (a mob): the aim vector is `(target.x - shooter.x, target.getY(0.3333333333333333) - projectile.y + 0.20000000298023224 x horizontalDistance (the float 0.2 widened to a double), target.z - shooter.z)` with `horizontalDistance = sqrt(dx^2 + dz^2)` of the first and third components; it is normalised and rotated by `angle` about an axis computed from cross products with the world up vector, with a fallback to the shooter's up vector when the first cross product is shorter than 1e-3 (squared length at most 1e-7); then `projectile.shoot` as above. The exact rotation composition is Open question 2.
- Then play `item.crossbow.shoot` (the sound event) at the shooter's position with the shooter's sound source, **volume 1.0** and pitch `getShotPitch(random, index)` where the random source is the shooter's.

`getShotPitch(random, index)`: `index == 0` gives **1.0**; otherwise `base = 0.63` when `index` is odd, `0.43` when even, and the pitch is `1.0 / (random.nextFloat() x 0.5 + 1.8) + base`.
Ranges: odd index 1.0648 to 1.1856 (nextFloat in [0,1)), even index 0.8648 to 0.9856.

## 10. `suspicious_stew`

Prototype: stack 1; `food` = `Foods.SUSPICIOUS_STEW` (nutrition 6, saturation modifier 0.6 so saturation = 6 x 0.6 x 2 = 7.2, **can always eat**; the `stew(n)` helper plus `alwaysEdible`, 25 part 1 section 8.2);
`consumable` = `Consumables.DEFAULT_FOOD` (1.6 s, animation eat, sound `entity.generic.eat`, particles on, no extra effects; 25 part 1 section 8.3); `suspicious_stew_effects` = empty list; `use_remainder` = one `bowl`.

### 10.1 The component (type id 55)

`SuspiciousStewEffects(effects: List<Entry>)`, `Entry(effect: Holder<MobEffect>, duration: int)`. `DEFAULT_DURATION` = 160 ticks.

| Aspect | Value |
|---|---|
| Persistent codec | a list of objects `{id: mob effect (identifier string), duration: int (optional, lenient, default 160)}` |
| Wire | VarInt count, then per entry: the mob effect (its stream codec: a registry id, 46 mob effects) and a VarInt duration |
| `cacheEncoding` | set |
| Effect created | `MobEffectInstance(effect, duration)` (read): it delegates to the 3-argument constructor with amplifier 0, which delegates to the 5-argument constructor with ambient false and visible true, which passes `visible` on as the show-icon flag, so show-icon is also true. Result: amplifier 0, ambient false, visible true, show-icon true |
| Tooltip | only when the tooltip flag is creative (advanced tooltips in creative): the potion tooltip list of the effects, duration scale 1.0 and the tick rate of the level |

### 10.2 Eating

`Consumable.onConsume(level, entity, stack)` (25 part 1 section 8) does, in order: emit the consume particles and sounds (16 particles on the client path); for a `ServerPlayer` award `item_used` and trigger `consume_item`;
**for every component of the stack that implements `ConsumableListener`** call its `onConsume(level, entity, stack, consumable)` (the `food` component feeds the player, 17 section 4.9; `suspicious_stew_effects` adds every entry's effect with `LivingEntity.addEffect`); on the server run the consumable's own `on_consume_effects` (none here); fire game event `eat`;
consume one item (`stack.consume(1, entity)`), and the `use_remainder` bowl takes its place. The order among listeners is the iteration order of the stack's component map (Open question 1); the effect set and the hunger change do not depend on each other.

## 11. `loom` and the banner pattern items

**`loom`** (1138): `BlockItem` for block `loom` (24 section 7, loom row), registered through `registerBlock` (`BlockItemIds.LOOM` and the `UnaryOperator` lambda `Items.lambda$static$299`, whose whole body adds) `cooking_fuel` with provider `cooking/time_wood_blocks` (300 ticks in a furnace; the data file `context_int_provider/cooking/time_wood_blocks.json` is `300 / (conditional on block/fast_cooking: cooking/fast_burn_time_reduction_factor, else cooking/normal_burn_time_reduction_factor)`, the same shape as `time_wood_items_small`; speed provider the default `cooking/speed_default`, 25 part 1 section 9). Placement rules: 29.

### 11.1 The component `provides_banner_patterns` (type id 67)

Value: a **holder set of the `banner_pattern` registry**. Persistent codec `RegistryCodecs.holderSet(banner_pattern)` (a `#`-prefixed tag, a single identifier or a list, 04 section 6); wire `ByteBufCodecs.holderSet(banner_pattern)` (00 section 10.3); `cacheEncoding` set.
The registering code gives each of the ten items a **delayed** value: the named tag of the banner pattern registry (`HolderLookup.Provider.getOrThrow(tag)` returns the tag's holder set).

| Item (id) | Banner pattern tag | Pattern in the tag (data of the jar) |
|---|---|---|
| `flower_banner_pattern` (1139) | `pattern_item/flower` | `flower` |
| `creeper_banner_pattern` (1140) | `pattern_item/creeper` | `creeper` |
| `skull_banner_pattern` (1141) | `pattern_item/skull` | `skull` |
| `mojang_banner_pattern` (1142) | `pattern_item/mojang` | `mojang` |
| `globe_banner_pattern` (1143) | `pattern_item/globe` | `globe` |
| `piglin_banner_pattern` (1144) | `pattern_item/piglin` | `piglin` |
| `flow_banner_pattern` (1145) | `pattern_item/flow` | `flow` |
| `guster_banner_pattern` (1146) | `pattern_item/guster` | `guster` |
| `field_masoned_banner_pattern` (1147) | `pattern_item/field_masoned` | `bricks` |
| `bordure_indented_banner_pattern` (1148) | `pattern_item/bordure_indented` | `curly_border` |

The tag file path is `data/minecraft/tags/banner_pattern/<tag>.json`. The tag `no_item_required` lists 32 patterns that need no item (the 32 basic patterns); the jar holds 43 `banner_pattern` files = 32 + 10 + 1: after removing the 32 of `no_item_required` and the 10 of the `pattern_item/*` tags, the one left is `base` (read by set difference of the file names against the tag contents).

Banner pattern entry schema (data): `{asset_id: identifier, translation_key: string}`, for example `asset_id minecraft:flower`, `translation_key block.minecraft.banner.flower`.

### 11.2 The item's behaviour

The pattern items have no class and no use behaviour (`Item`): right click does nothing beyond the generic `Item.use` fall-through (PASS). Their only function is the component, read by the loom menu.

`LoomMenu` item rules (the menu itself, slots, result and packets belong to the menu round RS13; only the item tests are recorded):

- A stack is accepted in the pattern slot only if it is in item tag `loom_patterns` **and** has `provides_banner_patterns` (`isPatternItem`).
- `getSelectablePatterns(patternStack)`: when the pattern slot is empty, the holders of tag `banner_pattern/no_item_required` (empty list if the tag is absent); otherwise the holders of the stack's `provides_banner_patterns` set (empty if the value is null).
- Tooltips (read): `ItemStack.addDetailsToTooltip` has no branch for `provides_banner_patterns` (the component is not a tooltip provider there), and no class in `net/minecraft` was found that reads the language keys `item.minecraft.<pattern>_banner_pattern.desc` or `.new`, although `en_us.json` holds both keys for the pattern items (for example `.desc` "Creeper Charge", `.new` "Creeper Charge Banner Pattern"; the plain item name is "Banner Pattern"). A search for the string `.desc` in the item classes found only `DiscFragmentItem` (section 6) appending such a line. So the pattern items get no component tooltip line from code and the use of those keys was not found (Open question 16).
- A dye is accepted if in item tag `loom_dyes` and it has the `dye` component.

## 12. `goat_horn`

Class `InstrumentItem extends Item`. Prototype: rarity uncommon, stack 1, `instrument` (type id 63) = `InstrumentComponent(Holder<Instrument>)` with the holder of instrument `ponder_goat_horn` (delayed value, resolved from the `instrument` registry; the lookup is `getOrThrow`).

### 12.1 The `instrument` component and the `instrument` entry

`InstrumentComponent(instrument: Holder<Instrument>)`; persistent codec: `Instrument.CODEC` = `RegistryCodecs.holder(instrument, DIRECT_CODEC)` (an identifier or an inline instrument); wire: `Instrument.STREAM_CODEC` = `ByteBufCodecs.holder(instrument, DIRECT_STREAM_CODEC)` (00 section 10.2); `cacheEncoding` set.
Tooltip: the instrument's `description` with the gray style.

`Instrument` entry (`Instrument.DIRECT_CODEC`; data, schema only):

| Field | Type | Rule | Default |
|---|---|---|---|
| `sound_event` | sound event holder | | required |
| `use_duration` | float | non-negative | required |
| `range` | float | positive | required |
| `durability_damage` | int | non-negative | 0 (optional) |
| `description` | text component | | required |

Wire (`DIRECT_STREAM_CODEC`): sound event, Float `use_duration`, Float `range`, VarInt `durability_damage`, text component. The jar holds 8 instrument files (`ponder`, `sing`, `seek`, `feel`, `admire`, `call`, `yearn`, `dream` goat horns), all with `use_duration` 7.0 and `range` 256.0 (read); no entry sets `durability_damage`.
Tags (data): `regular_goat_horns` = ponder, sing, seek, feel (in that order); `screaming_goat_horns` = admire, call, yearn, dream (in that order); `goat_horns` includes both tags.

### 12.2 Use (`InstrumentItem.use(level, player, hand)`)

1. Read the instrument of the held stack; if absent return FAIL.
2. Start using the item (the use animation `toot_horn`); play the instrument sound: the instrument's sound event at the player's position (the call takes the player as the "except" and "source" entity), source `records`, **volume = range / 16** (256 / 16 = 16.0 for the vanilla horns), **pitch 1.0**; fire game event `instrument_play` at the player's position with the player as context.
3. If `durability_damage > 0`, damage the stack that much (hurt and break in the hand's slot).
4. If `use_duration > 0`, add an item cooldown on the stack of `floor(use_duration x 20)` ticks (7.0 gives 140).
5. Award stat `item_used`, return CONSUME.

`getUseDuration(stack)` = `floor(use_duration x 20)` of the stack's instrument, 0 if none. The horn has no `max_damage`, so step 3 never runs for vanilla data.

### 12.3 Creating a horn (`InstrumentItem.create(item, holder)` and `Goat.createHorn`)

`InstrumentItem.create(item, holder)` = a new stack of the item with `instrument` set to the holder. `Goat.createHorn()`: a `SingleThreadedRandomSource` (a 48-bit LCG, 11 and 34 section 7) created by `RandomSource.createThreadLocalInstance(long)` and seeded with the `hashCode` of the goat's UUID widened to long (`i2l`; all read); the tag is `screaming_goat_horns` for a screaming goat, else `regular_goat_horns`; pick
`list.get(random.nextInt(list.size()))` over the tag's elements in their tag order. The confirmed chain (all read): `Goat.createHorn` calls `Registry.getRandomElementOf(tag, random)` directly on the instrument registry (obtained through `RegistryAccess.lookupOrThrow(instrument)` of the goat's level), maps the resulting holder to a horn stack with `InstrumentItem.create`, and falls back with `orElseGet` to a plain `goat_horn`; the lookup is `get(tag)` flat-mapped to `HolderSet$Named.getRandomElement(random)`; `HolderSet$Named` extends `HolderSet$ListBacked`, whose `getRandomElement(random)` is `Util.getRandomSafe(contents(), random)`; `Util.getRandom(list, random)` is `list.get(random.nextInt(list.size()))` and `getRandomSafe` returns empty for an empty list. If the tag is empty, a plain `goat_horn` stack (which then carries the item default `ponder_goat_horn`).
The goat's horn drop timing and counts are in 19 (Horns row).

## 13. Worked examples

1. **Id of `music_disc_tears`.** 22 disc statements start at 1105 in the order of section 3: `music_disc_13` 1105, then 21 more; the last is the 22nd, 1105 + 21 = **1126**. It is uncommon, stack 1, song `tears`.
2. **Song `13`.** `length_in_seconds` 178.0, `comparator_output` 1, sound event `minecraft:music_disc.13` (read in the jar). `lengthInTicks = ceil(178.0 x 20) = 3560`; `hasFinished(t)` is true from `t = 3580`. A jukebox holding `music_disc_13` outputs comparator level 1.
   Insert at tick 0: `play` sets ticks 0, sends level event 1010 with the index of song `13` in the registry. Ticks 0, 20, 40, ... emit `jukebox_play` and note particles. At the tick where `ticks = 3580` the player stops and sends event 1011.
3. **Song `creator_music_box`.** length 73.0 s, comparator 11 (read). `lengthInTicks = 1460`, finished at 1480.
4. **Crossbow charge.** Quick Charge 0: `getChargeDuration = floor(1.25 x 20) = 25`. Start sound at progress 0.2 = tick 5 of use; mid sound at 0.5 = tick 12.5 so the first tick whose progress is at least 0.5 is **13**; loaded and end sound at tick 25. Quick Charge 3: duration `floor((1.25 - 0.75) x 20) = 10`, start at tick 2 with `item.crossbow.quick_charge_3`, no mid sound (the effect has no mid key; the timing of tick 5 applies only to the default sounds), loaded at tick 10 with `item.crossbow.loading_end`.
5. **Multishot.** n = 3, spread 10: step 10, base 0, offsets 0, -10, +10 degrees; durability cost 1 + 1 + 1 = 3 with three arrows (a loaded rocket costs 3 on its own). Ammo: the first arrow costs 1 from the stack, the two others are free intangible copies. Shot pitches: index 0 is 1.0 (no random draw); index 1 is `1/(r1 x 0.5 + 1.8) + 0.63`; index 2 is `1/(r2 x 0.5 + 1.8) + 0.43`, with `r1`, `r2` the next two `nextFloat` values of the shooter's random source. With r1 = 0.0: 0.5556 + 0.63 = 1.1856.
6. **Firework shot.** Charged list = one firework: power 1.6, projectile at eye height minus 0.15, durability cost 3.
7. **Goat horn use.** Vanilla horn: cooldown 140 ticks, sound volume 16.0 pitch 1.0 source records.
8. **Stew.** A stew with effects `[{id: night_vision, duration: 100}, {id: blindness}]` (hypothetical data): eating adds night vision for 100 ticks and blindness for 160 ticks (default), feeds 6 nutrition and 7.2 saturation (even at full hunger), and returns a bowl.
9. **Trident release.** A trident with Riptide level 1: `s` = 1.5 (17 section 3.10); in water: player pushed with a vector of length `s`, spin for 20 ticks with 8.0 damage, 1 durability lost, the item stays; out of water and rain the release returns false and the use itself was refused (FAIL in `use`). A normal (non-Riptide) throw returns true on the server and false on the client.
10. **Pattern slot.** A stack of `skull_banner_pattern`: in `loom_patterns` and has the component: accepted; selectable patterns = the holders of tag `pattern_item/skull` (one pattern, `skull`). With an empty pattern slot: the 32 patterns of `no_item_required`.

## 14. Validation

Checks an implementer can run against a loaded registry (all derived from this document):

1. The 45 ids 1105 to 1149 have the keys of section 3 in that order; `air` is id 0 and `music_disc_13` is the 1106th registered item (statement count 1105 before it).
2. Exactly 22 items have `jukebox_playable`; each song key equals the item key minus `music_disc_`; each key exists as a `jukebox_song` entry; the registry holds 22 songs (archive count of `data/minecraft/jukebox_song/*.json`).
3. Rarity census: 22 discs = 18 uncommon + 4 rare; banner patterns 4 common + 2 uncommon + 4 rare; `disc_fragment_5`, `nautilus_shell`, `heart_of_the_sea`, `goat_horn` uncommon; `trident` rare; `crossbow`, `suspicious_stew`, the five armors and `loom` common.
4. Stack sizes: 1 for all discs, `trident`, `crossbow`, `suspicious_stew`, the ten patterns, `goat_horn`, the five nautilus armors; 64 for `disc_fragment_5`, `nautilus_shell`, `heart_of_the_sea`, `loom`.
5. Durability: only `trident` (250) and `crossbow` (465) have `max_damage`; the validator "damage and stack above 1" passes for every row.
6. Components present: `provides_banner_patterns` on exactly the ten patterns (holder sets of 1 element each in vanilla data); `instrument` on `goat_horn` only, default `ponder_goat_horn`; `charged_projectiles` (section 9.7) on `crossbow` only; `suspicious_stew_effects` on `suspicious_stew` only; `weapon` and `tool` on `trident` only in this range; `cooking_fuel` on `crossbow` (300 ticks furnace) and `loom` (300).
7. Archive counts (with `unzip -Z1 ... | grep -v '/$' | grep ... | wc -l`): `data/minecraft/jukebox_song/` 22, `data/minecraft/instrument/` 8, `data/minecraft/banner_pattern/` 43, `assets/minecraft/items/music_disc*` 22.
8. Crossbow arithmetic: `getChargeDuration` 25, 20, 15, 10 for Quick Charge 0 to 3; multishot offsets 0, -10, +10; `getShotPitch(index 0)` exactly 1.0; shot power 3.15 or 1.6.
9. Jukebox: `hasFinished` exactly at `ceil(length x 20) + 20` ticks; events 1010 and 1011 carry the song index and 0.
10. Wire: a `jukebox_playable` component with a registered song encodes `id + 1` as a VarInt; a `goat_horn` instrument component encodes the same way over the `instrument` registry.
11. Nautilus armor: no `max_damage` and `repairable`; `equippable.damage_on_hurt` false.

## 15. Open questions

1. The order in which `ConsumableListener` components of one stack run (`ItemStack.getAllOfType` iterates the component map); the iteration order of the prototype map was not traced. It affects only the order of effects in the log, not the results.
2. The exact vector composition of `getProjectileShotVector` for mob shooters (cross products with the world up vector, a 90 degree rotation and the angle rotation): the operations were listed but the axis of the angle rotation was not derived. Players use the simple rule of 9.6.
3. Closed: the end-sound lambda is `lambda$onUseTick$2`, read from the bootstrap table (section 9.3).
4. The registry index used in level event 1010 is the index in the `jukebox_song` registry of the connection; the order of those entries on the wire is by the registry sync (04 section 4, 23) and was not re-derived here.
5. The HUD "now playing" display (timing, fade) after `Hud.setNowPlaying` was not read (12 section 5 owns HUD details).
6. Closed: `HolderSet$ListBacked.getRandomElement` is `Util.getRandomSafe(contents(), random)` and `HolderSet$Named` extends `ListBacked` (section 12.3). The order of a nested tag's elements after resolution (goat horns use non-nested tags) was not needed.
7. Closed in 31 section 2 (31 part 4): `JukeboxBlockEntity.loadAdditional`, the stopping of the player and the restoring of `ticks_since_song_started`.
8. Whether the crossbow's two sound flags are shared by all stacks and players: they are fields of the item instance (one instance per item type), so the sharing is by construction; the visible effect (a second player resetting a first player's flags) was not analysed.
9. Closed: the last branch of `Player.getProjectile` was read (section 9.1).
10. Closed: the constructor chain was read, giving amplifier 0, ambient false, visible true and show-icon true (section 10.1).
11. The `banner_pattern` registry holds 43 entries; 32 are in `no_item_required` and 10 are item patterns; the 43rd entry is `base` (section 11.1, closed). The banner application engine (layers, the result item of the loom) is not specified here (menu round RS13).
12. Item model files, translation keys for the 45 items (`item.minecraft.*`, `jukebox_song.minecraft.*`, `instrument.minecraft.*`, `block.minecraft.banner.*`) and the Faithful pack replacements are data (22, 14).
13. Mob use of the crossbow (`MOB_ARROW_POWER` 1.6 and the piglin and pillager ranged goals) is 19 to 21; only the item side was read here.
14. Closed: `EnchantmentHelper.pickHighestLevel` was read (index `min(L, list size) - 1`), sections 7 and 9.3.
15. Closed: the only overrider of `LivingEntity.setRecordPlayingNearby` is `Parrot` (archive scan, section 5.4).
16. The consumer of the banner pattern language keys `item.minecraft.*_banner_pattern.desc` and `.new` (present in `en_us.json`) was not found: searched `ItemStack.addDetailsToTooltip` (no `provides_banner_patterns` branch) and the item classes for the string `.desc` (only `DiscFragmentItem` matches); a user of the keys outside `net/minecraft/world/item` (for example a screen or a data-driven lookup built from a concatenated key) was not searched for.
17. The tooltip prefix literal used for the nested projectile detail lines (section 9.7) was not decoded beyond "a short literal".
18. For the owner of 17: section 3.9 (crossbow crit flag is true only for a player shooter, section 1 item 3), section 1.4 (nautilus armor has no durability multiplier, section 1 item 2) and line 545 (charge time is `floor(modified seconds x 20)` already computed by `getChargeDuration`, not `floor(20 x getChargeDuration)`) disagree with this document; the text of 17 must be corrected by its owner. Line 92 of 17 should read "list of item templates" (section 9.7).
