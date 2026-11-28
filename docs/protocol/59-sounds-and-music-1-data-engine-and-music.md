# Sounds and music, part 1: where the data lives, sound events, sound definitions, the playback engine, music and ambience

| Item | Value |
|---|---|
| Covers | What the artifact does and does not contain about sound (§1); the sound events and their ids on the wire and what the client does with each sound packet (§2); the sound definition file `sounds.json` and the choice of a variant from the packet seed (§3); sound categories, volume and pitch rules, positional audio, concurrency limits and the audio data formats (§4); the sound instances the game creates (§5); subtitles (§6); background music, its delays and its data (§7); ambient loops, additions and mood sounds, underwater sounds, weather (§8); the goat horn instrument to sound table and the jukebox song table (§9). Part 2 (document 60, written) holds the block sound types, the step, landing and swim rules, the entity sounds, the level events with a fixed sound, note blocks, bells, the respawn anchor and thunder; what it does not yet cover (tickable instances, weather, the item data behind the equip, break and consume sounds, ambient block sounds) is in its Open questions (Open question 12). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in the README of this folder; version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap`) and of the data files inside the jar, with no execution. Ticket CC-0064 |
| Related | 05b (the three sound packets), 46 §14 (sound event ids), 13 §7 (options and the Music & Sounds screen), 12 §3.1 and 23 §8 (environment attributes), 33 §3.4 (attribute system), 10 §2.6 (`LegacyRandomSource`), 22 §2.9 (what the jar lacks), 57-2 §3 (menu take sounds) |

Every value below was read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)"; those marks are collected in the Open questions at the end.

## 1. Where the data lives

**The answer first.** The client jar contains the Java code that plays sound and a number of data files that *name* sounds, and it contains **no audio and no sound definition file**. The audio files and `sounds.json` are not in the jar and are not fetched by the game at run time either: the game reads them from an **external asset directory** that is named on the command line (§1.2). That the official launcher prepares that directory is (inferred): the artifact contains no code that downloads or builds it (Open question 9). A client that has only the player's own client jar therefore has no sound at all.

### 1.1 What the jar does not contain (checked)

| Check | Result |
|---|---|
| Files in the jar (`unzip -Z1 ... \| grep -v '/$' \| wc -l`; the archive also holds 1,349 directory entries, 34,227 central records in all, as 22 says) | 32,878 |
| Entries ending `.ogg`, `.wav`, `.mp3`, `.fsb`, `.nbs` | **0** |
| An entry named `sounds.json`, or any path under `assets/minecraft/sounds` | **none** |
| `assets/minecraft` top-level folders present | `atlases`, `blockstates`, `equipment`, `font`, `items`, `lang`, `models`, `particles`, `post_effect`, `shaders`, `texts`, `textures`, `waypoint_style`, plus the files `gpu_warnlist.json` and `regional_compliancies.json` (no `sounds` folder) |
| Languages in `assets/minecraft/lang` | only `en_us.json` and `deprecated.json` (so the other languages come from the same external source) |
| A URL of a sound or asset server in any class (`resources.download.minecraft.net`, `launchermeta`) | **none** (the string `launchermeta` and the download host appear in no class) |

### 1.2 Where the client looks for them

- `SoundManager` (a reload listener of the resource manager) reads the file named **`sounds.json`** of **every namespace** of the resource manager (`ResourceManager.getResourceStack`, so every pack that has the file contributes, lowest pack first; §3.3). The audio file of a sound entry is `sounds/<name>.ogg` in the entry's namespace (`Sound.SOUND_LISTER` is a `FileToIdConverter("sounds", ".ogg")`). Both files are looked up in the same resource manager as textures.
- The vanilla resource pack the game builds (`ClientPackSource.createVanillaPackSource`) has two sources: the jar (`pushJarResources`) and, as a further layer, **the external asset path** (`pushAssetPath(PackType.CLIENT_RESOURCES, <path>)`), exposing the namespaces `minecraft` and `realms`. Since the jar has no `sounds.json`, the vanilla `sounds.json` and every vanilla `.ogg` can only come from that external path (or from a resource pack the player installed).
- The external path comes from two command-line options of `net.minecraft.client.main.Main` (that the official launcher is what passes them is (inferred)): `--assetsDir <dir>` (default: the folder `assets/` inside `--gameDir`, whose default is `.`) and `--assetIndex <name>` (optional). `GameConfig$FolderData.getExternalAssetSource` gives:
  - **without** `--assetIndex`: the directory itself, read as a plain tree whose first level is the namespace (`minecraft/sounds.json`, `minecraft/sounds/...`, `minecraft/lang/...`);
  - **with** `--assetIndex <name>`: a virtual file system built by `IndexedAssetSource.createIndexFs(assetsDir, name)`. It reads `<assetsDir>/indexes/<name>.json`, takes its member `objects` (a JSON object whose keys are resource paths, slash separated, and whose values each carry a member `hash`; `objects` and `hash` are the only member names `createIndexFs` reads from the file, so any other member such as a `size` is ignored, and that the launcher's own index files carry one is (recalled, not verified)), and maps each key to the file `<assetsDir>/objects/<first two characters of hash>/<hash>`. A file that is not in the index does not exist for the game. The index file itself is **not** in the jar (the key spelling, for example `minecraft/sounds.json` and `minecraft/sounds/<path>.ogg`, is therefore (recalled, not verified); the game only requires that the keys, split at `/`, form the path `<namespace>/<path under the namespace>`).
- The jar and `Main` contain no code that downloads the index or the objects. Who obtains them is not in the artifact (that the official launcher does so is (inferred)); a program that wants sound has to do the equivalent itself, or ask the user for a folder that contains the files.

### 1.3 What the jar does contain about sound (all of it is data or code the client can use alone)

| What | Where in the jar | Use |
|---|---|---|
| The sound event registry (names, numeric ids) | code: `net.minecraft.sounds.SoundEvents` static initialiser | 46 §14 (1,991 entries); §2 |
| Subtitle texts | `assets/minecraft/lang/en_us.json`, 1,023 keys starting `subtitles.` | §6 |
| Music and ambience data | environment attributes `minecraft:audio/background_music`, `minecraft:audio/ambient_sounds`, `minecraft:audio/music_volume` in `data/minecraft/worldgen/biome/*.json` (43 of the 67 biome files carry a `background_music` member, counting `pale_garden`'s empty object; both numbers were counted from the archive, and the 43 are the rows of the table in §7.1) and `data/minecraft/dimension_type/*.json`; the boolean `minecraft:audio/firefly_bush_sounds` in `data/minecraft/timeline/day.json` | §7, §8, §8.5 |
| Jukebox songs (sound event, length in seconds, comparator output) | `data/minecraft/jukebox_song/*.json` (22 files) | §9.2 |
| Goat horn instruments (sound event, range, use duration) | `data/minecraft/instrument/*.json` (8 files) | §9.1 |
| Mob sound variants (wolf, pig, cat, cow, chicken) | `data/minecraft/*_sound_variant/*.json` (04 §4) | 60 §4.4 |
| Block and entity sound choices, the playback engine, the music manager, the ambient handlers | code (`net.minecraft.client.sounds`, `net.minecraft.client.resources.sounds`, `com.mojang.blaze3d.audio`, block, entity and level classes) | this document and 60 |
| Tag lists for ambient block sounds | `data/minecraft/tags/block/triggers_ambient_*_block_sounds.json` (22 §2.9 notes them) | not yet read (60 Open question 13) |

### 1.4 The audio data the engine can use

Read from `JOrbisAudioStream` (the only decoder), `OpenAlUtil.audioFormatToOpenAl`, `SoundBuffer` and `ChunkedSampleByteBuf`.

| Property | Rule |
|---|---|
| Container and codec | **Ogg Vorbis**. The Ogg page and packet parser and the Vorbis synthesis are the JOrbis library, the packages `com.jcraft.jogg` and `com.jcraft.jorbis`, which only `JOrbisAudioStream` refers to. **That library is not in the artifact**: the jar has **0 entries** under `com/jcraft/` (counted from the archive, `unzip -Z1 ... | grep -c 'com/jcraft'`; 32,878 entries in all), so the Vorbis internals (header parsing, codebooks, floor and residue decoding, windowing) cannot be read and are **not described in this document**. Everything else in this table is read from the game's own classes `JOrbisAudioStream` (the stream is rejected with "Invalid Ogg file" or "Invalid Ogg identification packet" when the first page or the identification packet is bad), `ChunkedSampleByteBuf`, `OpenAlUtil`, `SoundBuffer` and `Channel`; the rows below that quote library behaviour say so. A file whose name ends `.ogg` is always read as Ogg Vorbis. No other container or codec is read. A client that decodes audio needs its own Ogg Vorbis decoder (Open question 1). |
| Sample rate | whatever the file declares (`Info.rate`); passed unchanged to OpenAL (`alBufferData(buffer, format, data, (int) sampleRate)`). The engine resamples nothing. |
| Channels | the decoder handles 1 and 2 channels directly and any other count through a general interleaving path; **the buffer upload accepts only 1 (mono) or 2 (stereo) channels** (any other count raises `IllegalArgumentException` in `audioFormatToOpenAl`). |
| Decoded form | 16-bit signed little-endian PCM, interleaved. Each decoded float sample `s` becomes the integer `trunc(s x 32767.5 - 0.5)` clamped to -32768..32767 (`ChunkedSampleByteBuf`). The format object is `AudioFormat(rate, 16, channels, signed = true, bigEndian = false)`. |
| OpenAL formats used | mono 8-bit `0x1100`, mono 16-bit `0x1101`, stereo 8-bit `0x1102`, stereo 16-bit `0x1103` (the constants 4352 to 4355 in `audioFormatToOpenAl`; the decoder only produces the 16-bit ones). |
| Positional versus stereo | The engine does not test channel counts when it plays. Whether the shipped sound files of positional sounds are mono and the music files stereo is a property of the audio files, which are not in the artifact: (recalled, not verified) it is so. The OpenAL rule that a stereo source is not spatialised is also (recalled, not verified): no OpenAL code is in the artifact. See Open question 1. |
| Streaming versus whole buffer | Per sound entry (`stream` flag, §3.2). A whole-buffer sound is decoded completely (`readAll`) once, cached per file path in `SoundBufferLibrary` (never evicted until the sound library is reloaded) and attached to the source. A streamed sound is decoded progressively: the buffer size is **one second of audio** (`sampleSizeInBits x channels x sampleRate / 8` bytes), **4 buffers** are queued at the start and one more is queued each tick for every buffer the source finished (`Channel.attachBufferStream`, `updateStream`). |
| Looping | A looping streamed sound re-opens its file at the end (`LoopingAudioStream`). A looping non-streamed sound uses the OpenAL looping flag, except a looping sound with a delay greater than 0, which the engine restarts itself (§4.5). |
| Library requirements | OpenAL 1.1 (the capability `OpenALC11`) and the extensions `AL_EXT_source_distance_model` and `AL_EXT_LINEAR_DISTANCE`; otherwise the sound engine fails to start and the game runs without sound ("Error starting SoundSystem. Turning off sounds & music"). `ALC_SOFT_HRTF` is used when the option Directional Audio is on (13 §7). |

### 1.5 What this means for an implementation (the finding in one place)

1. A program that implements sound needs three things the jar cannot give: the **definition file** (`sounds.json`, §3), the **audio files** (Ogg Vorbis, §1.4) and a **decoder and mixer**. The jar gives the event names, the parameters of every event (volume, pitch, range, source, seed), the music and ambience data, and the subtitle texts.
2. The two missing inputs are what an asset folder of the form read by `createIndexFs` holds (that this is what the official launcher's asset index holds is (inferred)). A client that wants vanilla sound must be handed such a folder (a folder tree, or an `indexes/` plus `objects/` pair), either by the user or by the program's own fetching code; this document cannot say where to fetch it from, because the artifact names no source.
3. Without the files, the behaviour of §2 to §8 is still fully defined as events: a client may run every rule below and send each resolved sound to a no-op output. An unknown or missing sound is never an error for gameplay (§2.4).
4. A third-party resource pack can supply its own `sounds.json` and `sounds/` folder (the engine reads them through the same resource manager, §3.3). Whether CobolCraft's pack format reads them is a decision of 08 (its table currently marks both as "not read").

## 2. Sound events on the wire and in the client

### 2.1 Ids

The static registry `sound_event` has **1,991** entries in the order of the registrations of `SoundEvents.<clinit>` (1,897 single registrations plus six generated groups, 94 names). 46 §14.2 states the rule and §14.3 lists every id. **Verified**: an independent extraction of the 1,897 single names in `<clinit>` order, with the six groups inserted at the documented points, reproduces the 1,991 rows of 46 §14.3 with no difference (every id and key). The numeric id on the wire is the registry id plus one (`Holder` codec: 0 means an inline sound follows, 05b composite types).

`SoundEvents.EMPTY` is one of the registered entries and is never played (the sound library skips it, §2.4).

### 2.2 The three packets

| Packet | Fields (05b has the layouts) | What the client does |
|---|---|---|
| Sound (05b 0x77) | sound holder, source, x, y, z (Int, the block coordinate times 8), volume, pitch, seed | `ClientPacketListener.handleSoundEvent` calls `ClientLevel.playSeededSound(player, x/8.0, y/8.0, z/8.0, sound, source, volume, pitch, seed)`. The level plays only when the excluded entity is the local player, which the handler always passes; it creates a `SimpleSoundInstance` (§5) with `RandomSource.create(seed)` and plays it **immediately: the packet path has no distance delay** (the distance-delay flag is false). There is no client-side range test: the server decided who receives the packet (57-2 §3.2 and §2.3). |
| Sound Entity (05b 0x76) | sound holder, source, entity id, volume, pitch, seed | `handleSoundEntityEvent` looks up the entity by id in the client level; if it is not known, **nothing happens**. Otherwise `playSeededSound(player, entity, ...)` creates an `EntityBoundSoundInstance` (§5) and plays it. The sound's position then follows the entity (§5). |
| Stop Sound (05b 0x79) | flags, optional source, optional sound identifier | `handleStopSoundEvent` calls `SoundManager.stop(name, source)` with a null for each missing field (`SoundEngine.stop(Identifier, SoundSource)`): every playing instance matches when the name is null or equals its identifier **and** the source is null or equals its source; matching instances are stopped. With neither, all sounds are stopped. The comparison is on the instance's event identifier (the event name, not the audio file). |

The position fixed point: x, y and z are `(int) (coordinate x 8.0)` on the server side (`d2i`, truncation toward zero) and `value / 8.0f` on the client, so a sound is placed on a 1/8 block grid.

### 2.3 Inline sounds

An inline sound event (id 0 in the holder) carries an identifier and an optional fixed range. The client uses **only the identifier**: no client class reads the range of an event (`SoundEvent.getRange` is called only by server-side broadcast code, see 57-2 §3.2 for the range test). The identifier is looked up in the same `sounds.json` registry as a registered event, so an inline sound can name any key that `sounds.json` defines, including keys that are not in the 1,991 (a pack-defined event, §3.3). This closes 46 Open question 6 for the first half: an unknown identifier is **accepted by the codec and silently not played** (§2.4).

### 2.4 When a sound is not played

In order (`SoundEngine.play`, which every path ends in):

1. The engine is not loaded (no audio device or a library error): nothing.
2. The instance says it cannot play (`canPlaySound`; it is overridden by six classes, all of which answer "the entity is not silent", §5.3, so it is false only for an instance bound to a silent entity): nothing, and nothing below happens, in particular no random draw.
3. The event identifier is not in `sounds.json` (`getOrResolve` finds no entry): a warning is logged once per identifier until the next reload, and nothing is played. (With the debug flag `DEBUG_SUBTITLES` on, which the shipped game has off, play continues with a placeholder event instead.) For an event that is found, **the weighted draw of §3.3 is made here**, once, with the instance's own random, by `getOrResolve`: the draw happens even when one of the steps below then drops the sound.
4. The chosen sound is the intentionally empty one (`minecraft:intentionally_empty`) : nothing, silently. The chosen sound is the empty sound (`minecraft:empty`, which also stands for an event with no usable file): a warning once, nothing.
5. **Subtitle notification (this step stops nothing).** When the engine has at least one listener (the subtitle overlay, §6), every listener is told about the instance, the event and the range of §6 **now**: after the empty-sound tests of step 4 and **before** the zero-volume test and before a channel is acquired. A sound that is dropped by step 6 (volume 0) or step 7 (no free channel) therefore still reaches the overlay and produces a subtitle line when its event has a subtitle (§6).
6. The final volume (§4.2) is 0, the instance cannot start silent (`canStartSilent` is false for every instance except the three classes of §5.3 that return true) and the source is not MUSIC: nothing ("Skipped playing sound, volume was zero"). A MUSIC sound, or an instance that can start silent, is played anyway at volume 0 (result STARTED_SILENTLY).
7. No channel is free in the pool (§4.4): nothing ("Failed to create new sound handle").

A sound that fails any of steps 1 to 4, 6 or 7 has no other effect (no queue, no retry); the only trace of a sound dropped at step 6 or 7 is the subtitle line of step 5. A sound that passes all steps is registered with its channel (§4.4) and, when the instance is tickable, added to the ticking list (§4.5); the result is STARTED, or STARTED_SILENTLY when it was started at volume 0. (Numbering: items 1 to 4 keep the numbers other documents cite; the notification is inserted as item 5.)

## 3. Sound definitions (`sounds.json`)

### 3.1 File schema

The file is one JSON object. Each key is an event name **without namespace** (the namespace of the key is the namespace of the file's folder: `minecraft:sounds.json` registers `minecraft:<key>`; the key `block.stone.break` is the event `minecraft:block.stone.break`). Each value is an entry:

| Member | Kind | Required | Default | Meaning |
|---|---|---|---|---|
| `replace` | Boolean | optional | false | when true, discards the sounds already registered for this event by lower packs (§3.3) |
| `subtitle` | String | optional | none | a translation key; the event has a subtitle only when present (§6) |
| `sounds` | Array | optional | empty | the variants. Each element is a String (shorthand) or an Object |

Variant forms (`SoundEventRegistrationSerializer`):

| Form | Meaning |
|---|---|
| String `"x"` | file sound named `x` (an `Identifier`: `ns:path`, default namespace `minecraft`) with volume 1.0, pitch 1.0, weight 1, stream false, preload false, attenuation distance 16 |
| Object | members below |

| Member of the Object form | Kind | Required | Default | Constraint |
|---|---|---|---|---|
| `name` | String (Identifier) | **required** | | the file `sounds/<path>.ogg` of the namespace, or, for type `event`, an event key |
| `type` | String | optional | `file` | `file` or `event` (`Sound$Type` names `FILE`, `SOUND_EVENT`; read through `getByName`, an unknown value is an error "Invalid type") |
| `volume` | Float | optional | 1.0 | must be greater than 0, else the whole file fails to parse |
| `pitch` | Float | optional | 1.0 | must be greater than 0 |
| `weight` | Integer | optional | 1 | must be greater than 0 |
| `preload` | Boolean | optional | false | decode the file when the sound library loads (§3.4) |
| `stream` | Boolean | optional | false | play from a stream with the streaming channel pool (§1.4, §4.4) |
| `attenuation_distance` | Integer | optional | 16 | the distance in blocks at which the sound has faded to silence (§4.3) |

Volume and pitch of a variant are constants here (`ConstantFloat`); they multiply the volume and pitch of the instance (§4.2). A parse failure of a file is logged ("Invalid sounds.json in resourcepack") and **that whole pack file is skipped**, other packs' files are kept.

### 3.2 Registration and layering

For every namespace of the resource manager, in the manager's namespace order, the stack of `sounds.json` files (lowest pack first, highest last) is read. For each key of each file:

- if the event has no registration yet, or `replace` is true: a **fresh** registration is made (the new event takes the file's `subtitle`; earlier variants are discarded);
- otherwise the variants of the file are **appended** to the existing list, and the subtitle stays that of the registration that created the event (a later `subtitle` member is not used).

For every variant of type `file`: the file `sounds/<name>.ogg` must exist in the resource manager, else the variant is **dropped** with a warning ("File ... does not exist, cannot add it to event"). A variant of type `event` is **never checked**; it is resolved at play time (§3.5). When all files of an event are dropped the event exists with an empty list and plays as the empty sound.

Two events always exist: `minecraft:empty` (the empty sound, weight 1, a file named `minecraft:empty`) and `minecraft:intentionally_empty`, both as constants of `SoundManager`; neither has a file. (Which events of `sounds.json` use them is the data's business.)

### 3.3 The variant draw

An event is a list of variants with integer weights. Picking one (`WeighedSoundEvents.getSound(random)`):

1. total = the sum of the variants' weights. A variant of type `file` weighs its `weight` member. A variant of type `event` weighs **the total weight of the referenced event** (0 when the referenced event is unknown), not its own `weight` member.
2. If the list is empty or total is 0, the result is the empty sound.
3. Draw one integer `r = random.nextInt(total)` (exactly one draw, only when the total is greater than 0).
4. Walk the list in registration order, subtracting each variant's weight from `r`; the first variant that makes `r` negative is chosen. (So the first variant owns `r` in `[0, w1)`, the second `[w1, w1 + w2)`, and so on.)

### 3.4 The random source and the seed

The Sound and Sound Entity packets carry a 64-bit seed. The client builds `RandomSource.create(seed)`, which is `new LegacyRandomSource(seed)` (read in `RandomSource.create(long)`), the `java.util.Random` linear congruential generator described in 10 §2.6 (`setSeed` scrambles with `0x5DEECE66D`; `nextInt(bound)` for a power-of-two bound is `(bound x next(31)) >> 31`, otherwise the rejection loop on `next(31) % bound`). The instance uses this generator for the variant draw and for nothing else: volume and pitch of a variant are constants and are sampled without a draw. The seed is therefore only a **variant selector**; a server that always sends the same seed always gets the same variant of an event, and one that wants a fresh variant per play sends a random seed (the vanilla server uses a separate generator, 57-2 §3.2).

For a sound the client plays on its own (not from a packet) the seed is `nextLong()` of the client level's own random (`ClientLevel.playLocalSound`) or an unseeded generator (`RandomSource.create()`) for instances built by `forUI`, `forMusic`, `forLocalAmbience` and the like; those draws are not reproducible and do not matter for compatibility.

**Worked examples** (computed with the generator of 10 §2.6 by hand and script, not by running the game): an event of three variants with weights 1, 1, 2 has total 4 and one draw `nextInt(4)`. Seed 0: `nextInt(4)` = 2, which falls in `[2, 4)`, the third variant. Seed 1: also 2 (third variant). Seed 12345: 1, the second variant. Seed -1: 1, the second variant. For a single-variant event (total 1) `nextInt(1)` is 0 for every seed (the draw is still made). For total 3: seed 0 gives 0, seed 12345 gives 1, seed -1 gives 2.

### 3.5 Events that name other events (`type: event`)

The variant refers to another event. At play time the referenced event is looked up in the registry (missing: the empty sound) and **its own draw is made with the same random generator** (the outer draw of §3.3 happened first). The resulting sound is a copy of the inner chosen sound with: volume = inner volume x outer variant volume, pitch = inner pitch x outer variant pitch, weight = the outer weight, type `file`, **stream = inner stream or outer stream**, preload = inner preload, attenuation distance = the inner one. A reference can itself be a reference (the same rule repeats, one more draw each level).

### 3.6 Preload and the sound library

When the sound library loads (resource reload and device change), every variant with `preload` true is decoded in the background (`SoundBufferLibrary.preload`), so its first play does not wait. A non-preloaded, non-streamed file is decoded on its first play and cached; the first play of such a file is started when the decode finishes (the source is acquired immediately and the buffer is attached asynchronously).

## 4. Categories, volume, pitch and positional audio

### 4.1 Sound sources (categories)

`net.minecraft.sounds.SoundSource`, ordinals are the wire ids (05b) and the option order (13 §7):

| Id | Constant | Name (option key suffix and `soundCategory.<name>` text key) |
|---|---|---|
| 0 | `MASTER` | master |
| 1 | `MUSIC` | music |
| 2 | `RECORDS` | record |
| 3 | `WEATHER` | weather |
| 4 | `BLOCKS` | block |
| 5 | `HOSTILE` | hostile |
| 6 | `NEUTRAL` | neutral |
| 7 | `PLAYERS` | player |
| 8 | `AMBIENT` | ambient |
| 9 | `VOICE` | voice |
| 10 | `UI` | ui |

Each source has a volume slider (default 1.0, 13 §7). `MASTER` multiplies every other source.

### 4.2 Final volume and pitch of a playing sound

For one instance the engine computes, once at the start and again each tick for tickable instances:

`volume = clamp(instanceVolume, 0, 1) x clamp(sourceSlider, 0, 1) x categoryGain`

- `instanceVolume` = the instance's volume (packet volume or the factory's constant) multiplied by the chosen variant's volume constant (§3.1).
- `sourceSlider` = the slider of the instance's source, times the master slider unless the source is MASTER (`Options.getFinalSoundSourceVolume`).
- `categoryGain` = a per-source multiplier, **default 1.0** for every source (`gainBySource`), changed only by `SoundEngine.updateCategoryVolume(source, gain)`, which the music fade uses (§7.2).

`pitch = clamp(instancePitch, 0.5, 2.0)` where `instancePitch` is the instance's pitch times the variant's pitch constant. The constants `PITCH_MIN` 0.5, `PITCH_MAX` 2.0, `VOLUME_MIN` 0 and `VOLUME_MAX` 1 are fields of `SoundEngine`. A sound volume above 1 therefore never plays louder than 1; it changes **the audible range** instead (§4.3). A pitch below 0.5 or above 2.0 is clamped without a warning.

**Changing a volume while sounds play** (all read in `SoundEngine`, `SoundManager`, `MusicManager`, `Options` and `SoundPreviewHandler`):

- `updateCategoryVolume(source, gain)` stores `clamp(gain, 0, 1)` in `gainBySource[source]` and then calls `refreshCategoryVolume(source)`. A source with no entry reads **1.0** (the map's default return value). `stopAll` (what `SoundManager.stop()` with no argument calls) clears the whole map, which resets every gain to 1.0. Nothing else resets a gain, so the MUSIC gain written by the music fade (§7.3) **persists after a song has stopped**: the next song is started with that gain, and the fade then continues from the music manager's own `currentGain`, which is also never reset (§7.3).
- `refreshCategoryVolume(source)` does nothing when the engine is not loaded. Otherwise, for every playing channel whose instance has that source, **or for every playing channel when the source is MASTER**, it recomputes the volume of the formula above (instance volume, slider of the instance's source times master, category gain) and sets it on the channel. Pitch and position are untouched. An instance that is still queued for a delayed start (§4.5) has no channel yet and is not touched; it gets the then-current volume when it starts.
- The volume slider of a source (the Music & Sounds screen, 13 §7) runs three steps each time its value changes, in this order: (1) if the source is MASTER or MUSIC **and** the final MUSIC volume (MUSIC slider times MASTER slider) is above 0, `MusicManager.showNowPlayingToastIfNeeded`, which asks the toast manager to show the now-playing toast and sets `toastShown` only when `toastShown` is false (it is false at start-up and after a song that was started silently; `startPlaying` sets it true when it shows the toast itself, §7.3); (2) `refreshCategoryVolume(source)`; (3) only when no world is loaded (`Minecraft.level` is null, so on the title screen and the screens reached from it), the preview below.
- **Slider preview** (`SoundPreviewHandler.preview(source, value)`, with `value` the slider's new value as a float). First, when the previewed source differs from the one of the previous preview (the static `previousCategory`), that source is remembered and the preview instance that is still held (static `activePreview`) is stopped. Then a new preview is started **only when no preview instance is held or the held one is no longer active in the engine** (`SoundManager.isActive`, defined in §4.5): dragging a slider within one category does not restart a preview that is still playing. The event depends on the source:

  | Source | Preview event |
  |---|---|
  | RECORDS | `block.note_block.guitar` |
  | WEATHER | `entity.lightning_bolt.thunder` |
  | BLOCKS | `block.grass.place` |
  | HOSTILE | `entity.zombie.ambient` |
  | NEUTRAL | the ambient event of the CLASSIC cow sound set (`entity.cow.ambient`: the name is the pattern `entity.<set>.ambient` with the set `cow`, read in `SoundEvents.registerCowSoundVariants`) |
  | PLAYERS | `entity.generic.eat` |
  | AMBIENT | `ambient.cave` |
  | UI | `ui.button.click` |
  | MASTER, MUSIC, VOICE | none (the event `EMPTY` is chosen and nothing is played) |

  The preview is `SimpleSoundInstance.forUI(event, pitch 1.0, volume = value)`: its **source is UI** (not the previewed source), attenuation NONE, relative, with an unseeded random, so its final volume is `clamp(value) x clamp(UI slider x master slider) x gain[UI]`: the previewed category's own value is used as the instance volume, and the UI slider and the master slider scale it.

### 4.3 Distance model and range

The instance's attenuation is `LINEAR` (positional) or `NONE`:

| Attenuation | Source state | Result |
|---|---|---|
| `NONE` | distance model off, source **relative** (position is taken relative to the listener) | the engine switches the per-source attenuation off and sets the relative flag (both read); that the sound is therefore heard at full volume wherever the player is, with no panning for a relative sound at the origin, is OpenAL's behaviour ((recalled, not verified), Open question 13). Used by UI, music, local ambience. |
| `LINEAR` | per-source linear distance model, **reference distance 0**, **rolloff factor 1**, **maximum distance D** | the gain falls linearly with the distance to the listener from 1 at distance 0 to 0 at D (formula `gain = 1 - d / D`, floored at 0; (recalled, not verified) OpenAL's linear model: the constants set are read, the formula is OpenAL's). |

`D` is the sound's **attenuation distance** (`attenuation_distance` of the variant, default 16) times `max(instanceVolume, 1)`: a sound of volume 1 or less is audible within 16 blocks (by default), a sound of volume 4.0 within 64 blocks (`Sound.getAttenuationDistance(volume)`, read as `max(volume, 1.0) x distance`), whatever the clamp of §4.2 does to the gain. The listener is the camera: its position, forward vector and up vector are copied to the OpenAL listener every frame (`SoundEngine.updateSource(Camera)`). Panning left and right comes from OpenAL's spatialisation of the source relative to the listener orientation ((recalled, not verified): no OpenAL code is in the artifact, Open question 13), and the Directional Audio option switches the context's HRTF on (`ALC_SOFT_HRTF`, 13 §7).

The OpenAL constants set per source in `Channel` (decimal, hex): the attenuation switch `53248` (0xD000) takes `53251` (0xD003, the linear model) or 0 (none); max distance `4131` (0x1023) = D; rolloff factor `4129` (0x1021) = 1.0; reference distance `4128` (0x1020) = 0.0; relative flag `514` (0x0202); gain `4106`; pitch `4099`; looping `4103`; position `4100`. The per-source distance model is enabled once for the context (`alEnable(512)`).

### 4.4 Concurrency limits

There are **two channel pools**, sized when the library starts (`Library.init`):

- `n` = the number of mono sources the device reports (`ALC_MONO_SOURCES`, attribute `4112`); **30** when the attribute is missing (`DEFAULT_CHANNEL_COUNT`).
- streaming pool size = `clamp(floor(sqrt(n)), 2, 8)`; static (whole-buffer) pool size = `clamp(n - streamingSize, 8, 255)`.

A sound whose variant has `stream` true takes a channel of the streaming pool, every other sound a channel of the static pool. When the pool is full the new sound is **not played** (the oldest are never cut: there is no priority, no distance ranking and no voice stealing; the first sounds to ask win). A channel is released when its source has stopped **and** at least 20 ticks have passed since it started (`MIN_SOURCE_LIFETIME`, read as `tickCount + 20` recorded at start). With the default `n` = 30 the pools are 5 streaming and 25 static channels. A client without OpenAL may use any limits; the vanilla defaults are the reference for behaviour.

### 4.5 Looping, delays and pausing

- `SoundInstance.getDelay()` greater than 0 on a looping instance makes the engine loop it manually: when its channel stops, it is queued again for `tickCount + delay` and played again by a new `play` (so the variant is drawn again with the instance's random).
- `SoundManager.playDelayed(instance, ticks)` queues an instance for `tickCount + ticks` (`tickCount` is the engine's own tick counter, one per unpaused client tick). The queue is worked off **at the end of the engine tick** (step 5 below), not at its start.
- **The engine tick** (`SoundEngine.tick(paused = false)`, called once per client tick by `Minecraft.tick` right after `MusicManager.tick`; `tickInGameSound`), in this order:
  1. `tickCount` is incremented.
  2. The instances handed over with `queueTickingSound` (tickable instances from game code) are filtered by `canPlaySound` and each remaining one is played now (`play`, §2.4); the list is then cleared.
  3. **Ticking pass**, for each instance of the ticking list in list order: if `canPlaySound` is false the instance is stopped; `tick()` is called either way; if the instance reports stopped it is stopped in the engine and nothing more happens to it this tick; otherwise its volume (§4.2), pitch (§4.2) and position are recomputed and set on its channel, and, when the instance is looping, `tickCount mod 10` is 0, its recomputed volume is above 0 and listeners exist, the listeners are notified again (§6).
  4. **Cleanup pass**, for each instance that still has a channel record: when its channel handle has stopped (see step 6) **and** its delete time (`tickCount` at `play` plus `MIN_SOURCE_LIFETIME` 20) has been reached: if it must loop manually (`isLooping` and `getDelay() > 0`) it is queued again for `tickCount + getDelay()`; then the channel record, the delete time, the by-source entry and (for a tickable instance) the ticking-list entry are removed.
  5. **Delayed starts**, for each queued entry (from `playDelayed` and from the manual loops of step 4) whose time is `<= tickCount`: a tickable instance is ticked once, then `play` (§2.4) is called and the entry is removed. A queued sound therefore starts after the ticking and cleanup passes of its tick. An entry queued with `ticks = n >= 1` starts in step 5 of the n-th engine tick after the call; `n = 0` starts in the next engine tick.
  6. After the pass above (and also on a paused tick) the channel pool's own pass is scheduled on the sound executor: every channel's stream is topped up (`updateStream`) and every channel whose OpenAL source is in the stopped state is released (its handle's flag becomes "stopped" and the channel returns to its pool). A stopped instance's handle therefore reads as stopped from the engine tick after that pass has run, never in the tick of the stop.
- **`isActive(instance)`** (`SoundEngine`, used by the music manager, §7.3, and the slider preview, §4.2): false when the engine is not loaded; otherwise true exactly while the instance has a channel record (the record is the entry in the instance-to-channel map; the delete time is stored and removed together with it, so a delete time never exists without the record). The record is created in `play` and removed in exactly three places: **step 4** of the engine tick, the **paused MUSIC pass** (next bullet), and **`stopAll`**, which clears the instance-to-channel map, the delete times, the delayed queue, the ticking list, the queued tickable instances, the by-source map **and the category gain map** in one go (`SoundManager.stop()` with no argument calls it, as do the engine's `destroy` and the level changes of `Minecraft`: `setLevel`, `clearClientLevel`, and `disconnect` when its third argument is true), so after `SoundManager.stop()` with no argument **every** instance is inactive at once, whatever its age. `SoundEngine.stop(instance)` and `stop(name, source)` only ask the channel to stop and remove no record. So a stopped instance **stays active** until its channel has been released **and** 20 ticks have passed since it started (step 4), or until the paused MUSIC pass or `stopAll` removes it. An instance that sits in the delayed queue, or that `play` dropped (§2.4), has no record and is **not active**.
- While the game is paused (`SoundEngine.tick(paused = true)`) the engine runs none of steps 1 to 5 (no volume, pitch or position updates, no queued starts, no ticking of instances); it only removes the records of MUSIC channels that have stopped (`tickMusicWhenPaused`: the record, the delete time and the by-source entry, without the 20-tick wait), so the music manager sees them as ended, and it still schedules step 6. `pauseAllExcept(sources)` pauses every playing channel whose source is not in the list; `resume` unpauses every paused channel. **Callers** (read; the only ones in the jar): the pause computation sits at the **end of `Minecraft.runTick`, which runs once per rendered frame**, after the frame has been rendered (the "Post render" section), not once per client tick (a frame runs zero, one or several client ticks before it is rendered). There `pause` (a field of `Minecraft`) is recomputed as "there is an integrated server, `Gui.isPausing()` is true and the server is not published to LAN", and **on the frame where `pause` turns from false to true** `runTick` calls `pauseAllExcept(MUSIC, UI)`: MUSIC **and** UI keep playing, everything else is paused. `SoundManager.tick(pause)` is called by **`Minecraft.tick`** (the client tick), right after `MusicManager.tick`, with the stored `pause` field, so a client tick sees the value computed at the end of the previous frame. `Gui.isPausing()` is "the screen exists and `isPauseScreen()`, or an overlay that is pausing". `Screen.isPauseScreen` is true by default; the classes that return false are `ChatScreen`, `WaitingForResponseScreen`, `SocialInteractionsScreen`, `AbstractContainerScreen` (the inventory-type screens), `LecternScreen`, `AbstractSignEditScreen`, `TitleScreen`, `LevelLoadingScreen`, `DeathScreen` and `GameModeSwitcherScreen`; `DialogScreen` returns the dialog's own `pause` flag and `WinScreen` returns "not the poem part". `resume` is called by `Gui.setScreen` when the screen it installs is null (the last screen is closed and play continues); no other code calls it, so when `pause` ends because a pause screen is replaced by a non-pause screen (for example the inventory) the paused channels stay paused until no screen is open. The overlay's own `isPausing` was not read (Open question 16).

### 4.6 What the client adds on its own initiative: delay by distance

A sound played through `ClientLevel.playLocalSound(x, y, z, event, source, volume, pitch, distanceDelay)` is delayed only when its `distanceDelay` argument is true; the three sound packets never pass it (§2.2). Let `d2` = the squared distance from the camera to the sound; when the flag is true and `d2 > 100` the instance (already built, with its seed drawn first from the client level's `nextLong`) is queued with `playDelayed` for `(int) (sqrt(d2) / 40.0 x 20)` ticks (a speed of 40 blocks per second, truncated toward zero); otherwise it plays at once. **Which callers pass true** (every one of the 51 classes of the jar that call `playLocalSound` was scanned): among the **level events**, only **3012 to 3016 and 3018 to 3021** (trial spawner, vault, cobweb; 3017 has no sound call), the table of 60 §5.1; every other level event, the global events, thunder (60 §5.5), the block-position sounds of the blocks and the entity sounds pass false and play at once. Outside the level events, one more class passes true: the firework starter particle (`FireworkParticles$Starter.tick`), twice, **and only when the starter's `playSound` field is true** (`ClientLevel.createFireworks(..., playSound)` is called for the rocket's entity event 17 with `!isSilent()` of the rocket; an empty explosion list creates no starter at all, only a few `poof` particles): the blast (AMBIENT, volume 20.0, pitch 0.95 + r x 0.1, `r` a `nextFloat()` of the particle's own random; the event is `entity.firework_rocket.large_blast` when the firework has three or more explosions or any explosion of shape LARGE_BALL, else `entity.firework_rocket.blast`, and the `_far` variant `large_blast_far` or `blast_far` when the particle is far from the camera) at the starter's first tick, and, when an explosion has a twinkle, `entity.firework_rocket.twinkle` or `twinkle_far` (AMBIENT, volume 20.0, pitch 0.9 + r x 0.15) at the end of its life (the tick on which `life` exceeds `lifetime`, followed by the starter's removal). "Far from the camera" (`isFarAwayFromCamera`, evaluated at the moment of each of the two sounds) means that the squared distance from the main camera position to the starter's position is **at least 256.0** (16 blocks or more).

## 5. The sound instances the game creates

### 5.1 Simple instances (`SimpleSoundInstance`)

All have a fixed position (the instance never moves) unless stated.

| Created by | Source | Volume | Pitch | Attenuation | Relative | Notes |
|---|---|---|---|---|---|---|
| a Sound packet or a block-position sound | the packet's | the packet's | the packet's | LINEAR | no | position = the packet position; for a block position the centre (x + 0.5, y + 0.5, z + 0.5) |
| `forUI(event, pitch)` | UI | **0.25** | pitch | NONE | yes | |
| `forUI(event, pitch, volume)` | UI | volume | pitch | NONE | yes | |
| `forMusic(event)` | MUSIC | 1.0 | 1.0 | NONE | yes | |
| `forJukeboxSong(event, pos)` | RECORDS | **4.0** | 1.0 | LINEAR | no | range 64 blocks with the default attenuation distance (§4.3) |
| `forLocalAmbience(event, pitch, volume)` | AMBIENT | volume | pitch | NONE | yes | |
| `forAmbientAddition(event)` | AMBIENT | 1.0 | 1.0 | NONE | yes | (= `forLocalAmbience(event, 1, 1)`) |
| `forAmbientMood(event, random, x, y, z)` | AMBIENT | 1.0 | 1.0 | LINEAR | no | uses the given random; position given |

### 5.2 Entity-bound instances

The Sound Entity packet creates an `EntityBoundSoundInstance(event, source, volume, pitch, entity, seed)`: a tickable instance (LINEAR, not relative, not looping, delay 0, the packet's volume and pitch, `RandomSource.create(seed)`) with these rules, all read in the class:

- **Position.** At construction and on every tick of the instance, x, y and z are the entity's coordinates **rounded through `float`** (each coordinate is converted to a 32-bit float and back to a double). The engine reads the position each tick (§4.5 step 3), so the sound follows the entity at float precision.
- **`canPlaySound` = the entity is not silent** (`Entity.isSilent`, the entity's silent flag). The engine asks it twice: at `play` (§2.4 step 2: a silent entity's sound is never started and no draw is made) and in every ticking pass (§4.5 step 3: when the flag turns true while the sound plays, the instance is stopped at the next engine tick).
- **Stop.** In its `tick` the instance stops itself when `Entity.isRemoved` is true; otherwise it only copies the position. Its `tick` tests nothing else (no health or alive test is read in the class).
- It cannot start silent (`canStartSilent` is the default false), so a final volume of 0 drops it (§2.4 step 6).

(Open question 2, the stop rule, is closed by this list.)

### 5.3 Tickable instances created by game code

The package `net.minecraft.client.resources.sounds` has these tickable instances (all extend `AbstractTickableSoundInstance`, whose `stop()` sets the stopped flag and clears looping, or, for the bee ones, `BeeSoundInstance`): `ElytraOnPlayerSoundInstance`, `MinecartSoundInstance`, `RidingMinecartSoundInstance`, `RidingEntitySoundInstance`, `BeeFlyingSoundInstance`, `BeeAggressiveSoundInstance`, `GuardianAttackSoundInstance`, `SnifferSoundInstance`, `UnderLiquidAmbientSoundInstance`, `UnderLiquidSubSound`, the ambient `LoopSoundInstance` (nested in `BiomeAmbientSoundsHandler`) and `DirectionalSoundInstance`. The ambient and underwater ones are read in §8, `DirectionalSoundInstance` in the next paragraph; the volume ramps and conditions of the others (elytra, minecart, riding, bee, guardian, sniffer) were **not read** (Open question 12).

**`DirectionalSoundInstance`** (read in full): the sound of the End flash, a WEATHER-source instance of the event `weather.end_flash`. `ClientLevel.tick` creates it when the End flash state reports that a flash started in this tick and the current screen is not the credits screen (`WinScreen`), and queues it with `SoundManager.playDelayed(instance, 30)`, so it starts 30 engine ticks later (§4.5). It uses the abstract classes' defaults for volume 1.0, pitch 1.0, not looping, delay 0, not relative, and the level's own random as its generator; its private `setPosition` sets the position to the camera position plus 10 blocks along the direction `Vec3.directionFromRotation(xAngle, yAngle)` and **sets the attenuation to NONE**; the constructor and every `tick` both call it, and nothing else sets the attenuation, so it is NONE from construction on. The two angles are fixed at construction, taken from the End flash state (`EndFlashState.getXAngle` and `getYAngle`, below). Since the attenuation is NONE the position has no effect on the volume, and the sound never stops itself (it ends with its file). It overrides **neither** permission method, so it always may play and cannot start at volume 0.

**`Vec3.directionFromRotation(x, y)`** (`x` the pitch and `y` the yaw, in degrees, as floats; `r` = 0.017453292f, π = 3.1415927f): with `c = -cos(-x r)`, the vector is `(sin(-y r - π) x c, sin(-x r), cos(-y r - π) x c)`. The sine and cosine are the game's table functions: `Mth.sin(v)` is `SIN[(int) ((long) (v x 10430.378350470453) & 65535)]` and `Mth.cos(v)` is `SIN[(int) ((long) (v x 10430.378350470453 + 16384.0) & 65535)]`, with `SIN[i] = (float) sin(i / 10430.378350470453)` for i = 0 to 65535 (the cast to long truncates toward zero). Example: `x` = -30, `y` = 0 gives about (0, 0.5, 0.866): 30 degrees above the horizon toward +z (yaw 0), so the sound sits at the camera position plus (0, 5, 8.66); `y` = 90 gives a negative x component (toward -x, the game's west). With `x` = 10 the y component is -0.174 (below the horizon).

**The End flash state** (`EndFlashState`, one per `ClientLevel` whose dimension type has end flashes, `DimensionType.hasEndFlashes`; `ClientLevel.tick` calls its `tick` once per client tick with the **total ticks of the dimension type's default clock** (`getDefaultClockTime`, 0 when there is none), the clock time `t` below). Constants: period 600 ticks, maximum offset 200, minimum duration 100, maximum duration 380, sound delay 30 ticks.

- **Parameters of a period.** `period = t div 600` (integer division). The state remembers the last period it computed, **initially 0**; when `period` differs from it, the four parameters are drawn from a fresh `SingleThreadedRandomSource(period)` (the same `java.util.Random` linear congruential generator as `RandomSource.create(seed)`, §3.4: `setSeed` scramble, `next(bits)`, `nextInt(bound)`, `nextFloat() = next(24) / 2^24`), in this order: one `nextFloat()` that is **discarded**; `offset` = a uniform integer 0 to 200 (`nextInt(201)`); `duration` = a uniform integer 100 to `min(380, 600 - offset)` (`100 + nextInt(min(380, 600 - offset) - 99)`); `xAngle` = `-60 + nextFloat() x 70`, uniform in [-60, 10) (float arithmetic); `yAngle` = `-180 + nextFloat() x 360`, uniform in [-180, 180). Because the remembered period starts at 0, period 0 (t from 0 to 599) is never computed: offset and duration stay 0 and the angles 0, so **there is no flash while the clock is below 600**. The parameters are a pure function of the period, so every client with the same clock time has the same flash.
- **Intensity.** Each tick the old intensity is kept and the new one is computed from `u = t mod 600`: 0 when `u < offset` or `u > offset + duration`, else `sin((float) (u - offset) x π / duration)` (float product and quotient, widened to double, then the table sine above). It is 0 at `u = offset`, rises to 1 at the middle of the window and ends at the table value of π (about 1.2E-16, positive) at `u = offset + duration`.
- **Start of a flash.** `flashStartedThisTick` is true when the new intensity is greater than 0 and the old one is not: normally at `u = offset + 1`. A new state starts with both values 0.0, so a client that enters the dimension (or changes to a new `ClientLevel`) while `u` is inside the window also gets a start on its first tick. On a start, when the current screen is not `WinScreen`, `ClientLevel.tick` creates the `DirectionalSoundInstance` with the state's two angles and queues it for 30 ticks (`playDelayed`, §4.5).
- **Worked examples** (computed with the generator by script, not by running the game). Period 1 (t 600 to 1199): offset 133, duration 311, `xAngle` -31.479, `yAngle` -105.223: the window is t 733 to 1044, intensity about 1.0 at t 888, the flash starts at t 734 and its sound starts at t 764. Period 2: offset 138, duration 296, `xAngle` -59.709, `yAngle` -1.144. Period 3: offset 86, duration 289, `xAngle` -3.632, `yAngle` -155.837.

**Which classes override the two permission methods** (read in each class; the default of both interface methods is `canPlaySound` true and `canStartSilent` false):

| Class | `canPlaySound` | `canStartSilent` | Subclasses that inherit |
|---|---|---|---|
| `EntityBoundSoundInstance` (§5.2) | the entity is not silent | default (false) | none |
| `SnifferSoundInstance` | the sniffer is not silent | default (false) | none |
| `GuardianAttackSoundInstance` | the guardian is not silent | default (false) | none |
| `RidingEntitySoundInstance` | the riding entity is not silent | **true** | `RidingMinecartSoundInstance` |
| `MinecartSoundInstance` | the minecart is not silent | **true** | none |
| `BeeSoundInstance` | the bee is not silent | **true** | `BeeFlyingSoundInstance`, `BeeAggressiveSoundInstance` |

Every other instance (`SimpleSoundInstance`, `DirectionalSoundInstance`, `ElytraOnPlayerSoundInstance`, the ambient loop and the underwater instances) keeps the defaults: it always may play and cannot start at volume 0 (except a MUSIC-source sound, §2.4 step 6). The three classes with `canStartSilent` true are looping instances (delay 0) whose initial volume can be 0 (read: the minecart and the bee instances start at volume 0; the riding instance starts at its `volumeMin` constructor argument), so the engine accepts them at volume 0 instead of dropping them (§2.4 step 6); their volume and pitch rules belong to document 60.

## 6. Subtitles

- An event has a subtitle exactly when its `sounds.json` entry has a `subtitle` member; the member is a translation key (for example `subtitles.entity.cow.ambient`), resolved through `lang/*.json`. The jar's `en_us.json` has 1,023 keys starting `subtitles.`, so subtitle **text** is available without the asset folder.
- Playing a sound notifies the engine's listeners with the instance, the event and the sound's **range**: infinity for a relative sound or attenuation NONE, else the attenuation distance of §4.3 (`SoundEngine.getRange`). The notification is made inside `play` at step 5 of §2.4: **after** the checks that discard unknown and empty sounds and **before** the zero-volume test and the channel acquisition, so a sound that is dropped because its volume is 0 or because the pool is full still reaches the overlay (whether it shows a line follows the overlay rules below). Looping tickable sounds notify again every **10 ticks** (the engine's `tickCount mod 10` is 0, `LOOPING_SOUND_SUBTITLE_INTERVAL_TICKS`; §4.5 step 3) while their recomputed volume is above 0.
- The subtitle overlay (`SubtitleOverlay`, drawn when the option `showSubtitles` is on, default off, 13 §7) keeps a list of lines keyed by the subtitle text: a repeat of a text already in the list **refreshes** that line (its time and position) instead of adding one. A line is displayed for **3000 ms** (`DISPLAY_TIME`); a looping sound's line is at full brightness for 500 ms after a refresh. The layout (width, direction arrows `<` and `>` according to where the sound is relative to the view, colours, fading) was not read in full: Open question 3.
- With the debug option `DEBUG_SUBTITLES` an event without a subtitle shows its path with " missing"; the shipped game has the flag off.

## 7. Background music

### 7.1 Data

The music to play is an environment attribute, **`minecraft:audio/background_music`** (type `background_music`, **not interpolated**, default `EMPTY` = no music; synced to clients, 23 §8.3). Its value has up to three optional music entries: `default`, `creative`, `underwater`. A music entry is `{sound, min_delay, max_delay, replace_current_music}` (`sound` an event name; `replace_current_music` default false). The attribute `minecraft:audio/music_volume` (Float 0 to 1, default **1.0**) scales the music while it plays (§7.3). 12 §3.1 gives the layering: dimension type attributes, then the biome's attributes at the camera, then timelines and weather.

Rows read from the jar (`data/minecraft/dimension_type/*.json` and `worldgen/biome/*.json`; every entry has `min_delay` 12000 and `max_delay` 24000 unless the row says otherwise):

| Source | `default` | `creative` | `underwater` |
|---|---|---|---|
| dimension type `overworld` and `overworld_caves` | `music.game` | `music.creative` | none |
| dimension type `the_end` | `music.end` (min_delay **6000**, max_delay 24000, **replace_current_music true**) | none | none |
| dimension type `the_nether` | no `background_music` attribute (empty) | | |
| the nine ocean and river biomes (`ocean`, `deep_ocean`, `cold_ocean`, `deep_cold_ocean`, `lukewarm_ocean`, `deep_lukewarm_ocean`, `warm_ocean`, `river`, `frozen_river`) | `music.game` | `music.creative` | `music.under_water` |
| `badlands`, `eroded_badlands`, `wooded_badlands` | `music.overworld.badlands` | none | none |
| `bamboo_jungle` | `music.overworld.bamboo_jungle` | | |
| `birch_forest`, `old_growth_birch_forest`, `dappled_forest`, `dark_forest`, `forest` | `music.overworld.forest` | | |
| `cherry_grove` | `music.overworld.cherry_grove` | | |
| `deep_dark` | `music.overworld.deep_dark` | | |
| `desert` | `music.overworld.desert` | | |
| `dripstone_caves` | `music.overworld.dripstone_caves` | | |
| `flower_forest` | `music.overworld.flower_forest` | | |
| `frozen_peaks` | `music.overworld.frozen_peaks` | | |
| `grove` | `music.overworld.grove` | | |
| `jagged_peaks` | `music.overworld.jagged_peaks` | | |
| `jungle` | `music.overworld.jungle` | | |
| `sparse_jungle` | `music.overworld.sparse_jungle` | | |
| `lush_caves` | `music.overworld.lush_caves` | | |
| `meadow` | `music.overworld.meadow` | | |
| `old_growth_pine_taiga`, `old_growth_spruce_taiga` | `music.overworld.old_growth_taiga` | | |
| `snowy_slopes` | `music.overworld.snowy_slopes` | | |
| `stony_peaks` | `music.overworld.stony_peaks` | | |
| `sulfur_caves` | `music.overworld.sulfur_caves` | | |
| `swamp`, `mangrove_swamp` | `music.overworld.swamp` | | |
| `nether_wastes` | `music.nether.nether_wastes` | | |
| `crimson_forest` | `music.nether.crimson_forest` | | |
| `soul_sand_valley` | `music.nether.soul_sand_valley` | | |
| `warped_forest` | `music.nether.warped_forest` | | |
| `basalt_deltas` | `music.nether.basalt_deltas` | | |
| `pale_garden` | the attribute is an **empty object** (no music at all) | | |

The nine ocean and river biomes contain `music.game`, `music.creative` and `music.under_water` explicitly. A biome that is not in the table (plains, savanna, taiga, beaches, the end biomes, and so on) sets no `background_music` and takes the dimension type's value. `pale_garden` additionally sets `minecraft:audio/music_volume` to **0.0**.

The music sound names are events of `sounds.json`; the event names above are all registered sound events (46 §14.3). Which files each event plays, and how many tracks it has, is in the missing `sounds.json` (§1).

### 7.2 Situational choice (`Minecraft.getSituationalMusic`)

In this order, the first that gives a music wins:

1. the current screen's background music, if the screen has one (`Screen.getBackgroundMusic`, which returns none by default). **Read: the only class that overrides it is `WinScreen` (the credits), which returns `Musics.CREDITS`.** No other screen has music of its own, `TitleScreen` included (a search of every class of the jar for the method name finds only `Screen`, `WinScreen` and `Minecraft`, whose two callers are `getSituationalMusic` and `getMusicVolume`). This closes Open question 4;
2. there is no player (`Minecraft.player` is null: the title screen and all the menu screens, and also the time before the player exists while a world loads): `Musics.MENU`. So the **menu music is `Musics.MENU`** (event `music.menu`, delays 20 to 600, replace true, §7.2 table) and it is chosen only by "no player", not by the title screen itself;
3. the player is in the End and the boss bar overlay says music should play (the dragon fight): `Musics.END_BOSS`;
4. otherwise `BackgroundMusic.select(creative, underwater)` of the value of `minecraft:audio/background_music` from the camera's attribute probe (`Camera.attributeProbe().getValue(BACKGROUND_MUSIC, 1.0F)`; the probe and the choice of biome are read in §7.4), where `creative` is `abilities.instabuild` **and** `abilities.mayfly` (read: exactly these two ability flags; **no game-mode test** is in `getSituationalMusic`; which game modes set both flags was not read here, (inferred) creative mode) and `underwater` is `LocalPlayer.isUnderWater` (the field of §8.3, which the player's `Player.tick` refreshes every tick from "the eyes are in water"): the underwater entry if `underwater` and it exists, else the creative entry if `creative` and it exists, else the default entry; **empty** if the chosen entry is absent (no music, and `getSituationalMusic` then returns null).

The attribute value at the camera is the layered value of 12 §3.1; which biome supplies the biome layer, and why it is not blended for music, is §7.4 (closing Open question 5).

The five built-in music objects (`Musics`; music is `(sound, minDelay, maxDelay, replace)`):

| Constant | Sound event | minDelay | maxDelay | replace |
|---|---|---|---|---|
| `MENU` | `music.menu` | 20 | 600 | **true** |
| `CREATIVE` | `music.creative` | 12000 | 24000 | false |
| `CREDITS` | `music.credits` | 0 | 0 | true |
| `END_BOSS` | `music.dragon` | 0 | 0 | true |
| `END` | `music.end` | 6000 | 24000 | true |
| `GAME`, `UNDER_WATER` | `music.game`, `music.under_water` | 12000 | 24000 | false |

(delays are in ticks.)

### 7.3 The music manager (`MusicManager`, ticked once per client tick)

State: `currentMusic` (the playing instance or none), `nextSongDelay` (ticks, **initial 100**, `STARTING_DELAY`), `currentGain` (float, initial 1.0), `toastShown`, the frequency option, a random source (`RandomSource.create()`, unseeded). Each tick:

1. `target` = `Minecraft.getMusicVolume()`: **1.0 when the current screen has background music** (only the credits screen, §7.2), else the attribute `minecraft:audio/music_volume` at the camera (`Camera.attributeProbe().getValue(MUSIC_VOLUME, 1.0F)`, §7.4: default 1.0, range 0 to 1).
2. If a song is playing and `currentGain != target`: run the fade (below). If the fade reports "no song or finished by stopping", **end the tick**.
3. `music` = the situational music of §7.2. If none: `nextSongDelay = max(nextSongDelay, 100)` and end the tick.
4. If a song is playing and `music.replace_current_music` is true and the identifier of `music`'s sound event differs from the playing instance's identifier (`canReplace`): **ask the engine to stop** the playing instance (`SoundManager.stop(instance)`; the music manager keeps `currentMusic`, it does not forget the instance here) and set `nextSongDelay = nextInt(0, music.minDelay / 2)` (uniform, inclusive, `Mth.nextInt(random, 0, minDelay/2)`).
5. If a song was playing and its instance is **no longer active** in the engine: forget it (`currentMusic` = none) and set `nextSongDelay = min(nextSongDelay, frequencyDelay(music))`. "Active" is `SoundEngine.isActive` as defined in §4.5: the instance still has a channel record, which the engine removes only when the channel has been released **and** 20 ticks have passed since the sound started. An instance that was stopped a moment ago is therefore **still active**, so after a replace-stop the condition of step 4 is still true on the next client ticks (`currentMusic` still holds the old instance, whose identifier still differs from `music`): **step 4 fires again every tick** (a new stop request, and a new draw of `nextInt(0, minDelay/2)` that overwrites `nextSongDelay`) until step 5 finds the record gone. The delay that finally counts is the last draw, then lowered by step 5 and step 6. (How many ticks the repetition lasts depends on when the sound executor releases the channel, §4.5 step 6: usually the first or second tick after the stop; not traced further.) Example: the credits screen opens while a game song plays: `CREDITS` has `replace_current_music` true and `minDelay` 0, so every draw is `nextInt(0, 0)` = 0 and the credits music starts in the tick in which the old song's record is gone and step 7 decrements the delay; for `MENU` (`minDelay` 20) the draw is in 0 to 10.
6. `nextSongDelay = min(nextSongDelay, music.maxDelay)`.
7. If **no** song is playing and the current screen is not the level-loading screen: decrement `nextSongDelay`; when it reaches 0 or below, start the music.

Starting music (`startPlaying`): create `forMusic(music.sound)`, play it; if the engine says STARTED, show the "now playing" toast and remember it; if STARTED_SILENTLY, remember that no toast was shown; in every case set `nextSongDelay = 2147483647` (so the countdown cannot reach 0 until step 5 lowers it when the song ends). The instance is stored in `currentMusic` **before** `play` is called and stays stored whatever the result: a start that returns NOT_STARTED (engine not loaded, no free channel) leaves `toastShown` unchanged, still sets the 2147483647 delay, and the next tick's step 5 finds the instance inactive (it never got a record) and handles it like a finished song.

`frequencyDelay(music)` (the option Music Frequency, 13 §7, `MusicFrequency`): the enum has a field `maxFrequency` = **24000** for DEFAULT, **12000** for FREQUENT, **0** for CONSTANT (read as `20`, `10`, `0` multiplied by `1200` in the constructor). If `music` is null the result is `maxFrequency`. For CONSTANT the result is **100**. Otherwise: `lo = min(music.minDelay, maxFrequency)`, `hi = min(music.maxDelay, maxFrequency)` and the result is a uniform integer in `[lo, hi]` (`Mth.nextInt`, one draw).

Stopping (`stopPlaying()`): **only when a song exists** (`currentMusic` is not none) the engine is asked to stop the instance, **`currentMusic` is then set to none** and the now-playing toast is hidden; the assignment `nextSongDelay = frequencyDelay(situational music) + 100` is made **in every case**, song or not (the situational music is the one of §7.2 read at that moment, null when there is none: `frequencyDelay(null)` is `maxFrequency`). The reset of `currentMusic` is what lets step 7 of the tick (the countdown, which runs only while no song is held) start counting again, and it means step 5 does not fire after a stop made by `stopPlaying` (it does after the replace-stop of step 4, which keeps the instance). `stopPlaying(music)` calls the no-argument form only when that music is the one playing (`isPlayingMusic`). Changing the frequency option immediately recomputes `nextSongDelay` with the new value (`setMinutesBetweenSongs`).

The fade (`fadePlaying(target)`): no song: returns "stop the tick". `currentGain == target`: nothing, continue. If `currentGain < target` (rising): `currentGain += clamp(currentGain, 0.0005, 0.005)`, capped at `target`. Otherwise (falling): `currentGain = target x 0.03 + currentGain x 0.97`, and when `|currentGain - target| < 0.0001` or the result went below `target`, `currentGain = target`. Then `currentGain = clamp(currentGain, 0, 1)`. If `currentGain <= 0.0001` the song is **stopped** (as `stopPlaying`) and the tick ends; otherwise the MUSIC source's category gain (§4.2) is set to `currentGain` and the tick continues. So the music volume attribute and a change of screen fade the music in or out instead of cutting it, but **not over tens of ticks**: rising takes about 200 ticks and falling about 300.

**Fade durations** (computed from the two formulas above, one fade step per client tick, 20 per second; single-precision arithmetic as in the game, the exact-arithmetic count is the same except where noted):

| Fade | Steps | Computation |
|---|---|---|
| Rising from 0 to 1.0 | **204** (10.2 s) | the gain goes 0.0005, 0.001, 0.002, 0.004, 0.008 (the increment is `clamp(currentGain, 0.0005, 0.005)`, so it doubles while the gain is below 0.005), then rises by 0.005 per tick: 5 + ceil((1 - 0.008) / 0.005) = 5 + 199 |
| Rising from 0.5 to 1.0 | 100 exact, 101 in single precision | 0.005 per tick; the sum of 100 float steps stays just below 1.0, so a 101st step caps it |
| Falling from 1.0 to target 0.0 | **303** (15.15 s), then the song is **stopped** | the gain after n steps is `target + (1 - target) x 0.97^n`: 0.97, 0.9409, 0.9127, ...; the fade ends at the first n with `|g - target| < 0.0001`, here `0.97^n < 0.0001`: 0.97^302 = 1.0065e-4 is not below, 0.97^303 = 9.76e-5 is; the gain is set to the target 0, and `0 <= 0.0001` stops the song |
| Falling from 1.0 to target 0.5 | 280 | `0.5 x 0.97^n < 0.0001` first holds at n = 280 (the fade just ends: 0.5 is above 0.0001, nothing is stopped) |

The MUSIC category gain (§4.2) is pushed to `currentGain` after every step that does not stop the song. **The category gain and `currentGain` persist after a song stops** (the stopping step itself does not push a gain; the last pushed value stays in `gainBySource[MUSIC]` and `currentGain` keeps its last value, neither is reset until `stopAll` clears the gain map, §4.2): a song that starts afterwards begins at that stored category gain, and the next fade step moves `currentGain` from where it was toward the new target. Example: a song plays at gain 1.0 and the camera moves into a cell of the pale garden (`music_volume` 0.0, §7.1): the target becomes 0.0 and, if the camera stays there, the song is stopped 303 ticks later.

How a disc interrupts music: the jukebox is the RECORDS source, which is a separate slider; the music manager does **not** look at discs. Music keeps its own schedule and plays under the record unless the player stops it: the shipped game does not pause music for a record in this class (no reference to jukeboxes was found in `MusicManager` or `Minecraft.getSituationalMusic`). (Pausing music while a record plays, if the game does it, is outside these classes: Open question 6.) The single-player pause keeps **MUSIC and UI** playing and pauses every other source (`pauseAllExcept(MUSIC, UI)`, called once when the paused state is entered; it applies only with an integrated server that is not published to LAN, and `resume` is called when the last screen closes: §4.5; this closes Open question 11). While paused, the engine's paused tick still lets the music manager see a stopped MUSIC channel as ended (§4.5), and `MusicManager.tick` itself keeps running.

**Worked example (default option, Overworld, survival, plains):** tick 0 of a new world: `nextSongDelay` is 100 and the screen is the loading screen, so it does not count down. After loading, 100 ticks later (5 s) it reaches 0: `music.game` starts, the toast shows (if the option allows), `nextSongDelay = 2147483647`. When the song ends the music manager sees the instance inactive and sets `nextSongDelay = min(2147483647, nextInt(12000, 24000))` (DEFAULT: `lo = min(12000, 24000)`, `hi = min(24000, 24000)`), then `min(that, 24000)`; 12000 to 24000 ticks (10 to 20 minutes) after the song, the next one starts. With CONSTANT the wait is 100 ticks.

### 7.4 Which biome supplies an audio attribute at a position, and the camera probe (read; closes Open question 5)

The value of an environment attribute at a position (12 §3.1) is built by layers. The **biome layer** is one function per attribute, registered by `EnvironmentAttributeSystem.addBiomeLayerForAttribute`; it works in this order:

1. if the caller passed a spatial interpolator **and** the attribute is flagged `spatiallyInterpolated`: the Gaussian blend of the camera probe (last paragraph);
2. else if the attribute is flagged `fullResolutionBiomes`: the biome at the **block** `floor(x), floor(y), floor(z)` (`BiomeManager.getBiome`);
3. else: the **noise biome of the 4 x 4 x 4 cell** that contains the position (`BiomeManager.getNoiseBiomeAtPosition`: each coordinate is floored and shifted right by 2, `QuartPos.fromBlock`, then `getNoiseBiomeAtQuart`).

In cases 2 and 3 the chosen biome's attribute map then applies its own modifier for the attribute to the running value (a biome entry overrides by default). The builder of an attribute starts with both flags false (`EnvironmentAttribute$Builder` constructor) and the four sound attributes are built with only `defaultValue`, `syncable` and, for `music_volume`, a value range of 0 to 1 (`EnvironmentAttributes.<clinit>`): **none of `audio/background_music`, `audio/music_volume`, `audio/ambient_sounds` and `audio/firefly_bush_sounds` is spatially interpolated or full-resolution**. For all four the biome layer is therefore **case 3: the noise biome of the 4-block cell at the position, with no blending**, even for the float `music_volume` (it jumps at a cell boundary). The positions used are: the **camera position** for music and music volume (§7.2, §7.3), the player's **feet position** (`LocalPlayer.position`) for the biome ambient handler (§8.2), and the block's centre for the firefly bush (`getValue(attribute, BlockPos)` is `getValue` at `Vec3.atCenterOf`, §8.5); a position-less read passes a null interpolator.

The types of `background_music`, `ambient_sounds` and the boolean `firefly_bush_sounds` are built with `AttributeType.ofNotInterpolated`; its four mixing functions are step functions, read as the four `ofStep` arguments: keyframe threshold 1.0, state change 0.0, spatial 0.5, partial tick 0.0 (a step function with threshold `s` returns the second value when the fraction is `>= s` and the first otherwise). `music_volume` is of the `Float` type, which is built with `ofInterpolated` and linear mixing functions (`LerpFunction.ofFloat`); it is nevertheless not flagged `spatiallyInterpolated`, so case 3 above applies to it.

**The camera probe** (`EnvironmentAttributeProbe`, one per `Camera`; `Camera.tick` calls `probe.tick(level, camera position)`, and `Camera.reset` clears it). `getValue(attribute, partialTick)` returns the level's value at the probe's position, or the attribute's default value when the probe has no level or no position yet (so on the title screen `music_volume` reads 1.0). The probe keeps a previous and a new value per attribute and mixes them with the type's partial-tick function: for the not-interpolated types that is a step at threshold 0.0, and with the partial tick **1.0** that Minecraft passes the result is always the **new** value of the current tick, never the previous one; for the `Float` type of `music_volume` the mix is linear (the partial-tick function of that type was not read in detail; with a fraction of 1.0 a linear mix is the new value up to float rounding, (inferred)).

For attributes that **are** spatially interpolated (fog and sky colours, not the sound attributes; the probe is where such camera values come from) the probe blends a 6 x 6 x 6 neighbourhood of quart cells: take `position x 0.25 - (0.5, 0.5, 0.5)`, floor it for the cell index `c`, and keep the fraction `f` per axis; for each axis the six cells `c - 2 .. c + 3` get the weight `lerp(f, k[i+1], k[i])` with `k = 0, 1, 4, 6, 4, 1, 0`, and the weight of a cell is the product of its three axis weights (loops: z outermost, then x, then y innermost, i.e. the sampler is called with x, y, z but visited in that order). Weights of cells whose biomes share the same attribute map are summed; the maps are then combined in first-seen order, each map after the first with `t = its weight / (weights so far including it)` and the type's spatial lerp (for a not-interpolated type the step at 0.5, so a later map replaces the running value when `t >= 0.5`: a running vote, not the largest weight). None of this affects music, ambience or the firefly sound.

## 8. Ambient sounds, mood, underwater, weather

### 8.1 The attribute `minecraft:audio/ambient_sounds`

Value (`AmbientSounds`, not interpolated, default `EMPTY` = no loop, no mood, no additions; codecs read in `AmbientSounds`, `AmbientMoodSettings` and `AmbientAdditionsSettings`):

| Member | Presence | Type |
|---|---|---|
| `loop` | optional | a sound event (`SoundEvent` holder codec) |
| `mood` | optional | an object, below |
| `additions` | optional, **default: the empty list** | `ExtraCodecs.compactListCodec` of the addition object: **either a list of addition objects or one bare object, which is the list of one** (read: the codec is "either a list or a single element"; a one-element list is written back as the bare element). The biome JSON of the jar writes a bare object. |
| `mood.sound` | **required** | a sound event |
| `mood.tick_delay` | **required** | Int |
| `mood.block_search_extent` | **required** | Int |
| `mood.offset` | **required** | Double |
| addition `sound` | **required** | a sound event |
| addition `tick_chance` | **required** | Double |

**There are no defaults for the four members of `mood`: all four must be present, or the whole attribute fails to parse.** The numbers 6000, 8 and 2.0 are only the constants of the Java object `AmbientMoodSettings.LEGACY_CAVE_SETTINGS` (sound `ambient.cave`, tick delay 6000, block search extent 8, offset 2.0), which `AmbientSounds.LEGACY_CAVE_SETTINGS` wraps as a mood with no loop and no additions; they are not substituted for missing JSON members. Every biome and dimension type JSON in the jar writes the same four values (6000, 8, 2.0 with the sound varying), as the table below shows.

Data read from the jar:

| Source | loop | additions (`tick_chance` 0.0111 for every row) | mood sound (tick_delay 6000, extent 8, offset 2.0) |
|---|---|---|---|
| dimension types `overworld`, `overworld_caves`, `the_end` | none | none | `ambient.cave` |
| `nether_wastes` | `ambient.nether_wastes.loop` | `ambient.nether_wastes.additions` | `ambient.nether_wastes.mood` |
| `crimson_forest` | `ambient.crimson_forest.loop` | `ambient.crimson_forest.additions` | `ambient.crimson_forest.mood` |
| `soul_sand_valley` | `ambient.soul_sand_valley.loop` | `ambient.soul_sand_valley.additions` | `ambient.soul_sand_valley.mood` |
| `warped_forest` | `ambient.warped_forest.loop` | `ambient.warped_forest.additions` | `ambient.warped_forest.mood` |
| `basalt_deltas` | `ambient.basalt_deltas.loop` | `ambient.basalt_deltas.additions` | `ambient.basalt_deltas.mood` |

Every other biome has no ambient sound data and takes the dimension type's value (cave mood in the Overworld and the End, nothing in the Nether).

### 8.2 The biome ambient handler (`BiomeAmbientSoundsHandler`, one per local player, ticked each client tick)

Each tick, with the value `A` of the attribute at the player's position (`level.environmentAttributes().getValue(AMBIENT_SOUNDS, position)`):

1. **Loop.** The handler keeps a map from sound event to running loop instance and remembers the loop of the previous tick, `previousLoopSound` (initially none). At the start of the tick every instance in the map that has stopped is removed from it. Then, if `A.loop` (or "none") differs from `previousLoopSound`: `previousLoopSound` is replaced, **every** instance in the map is told `fadeOut`, and, when the new loop exists, the map entry of that event is computed: when there is **no** entry a new `LoopSoundInstance` is created and played (`SoundManager.play`), and **whether the entry is new or existing** `fadeIn` is then called on it. An existing entry (one that was fading out and has not stopped yet) is therefore **reused and turned around** instead of a second instance being started for the same event.

   `LoopSoundInstance` (all read): source AMBIENT; **looping, delay 0, relative, initial volume 1.0**; attenuation the default LINEAR; the position fields are never set, so they stay (0, 0, 0); an unseeded random. State: an integer `fade` (initially 0) and a direction (initially 0: until `fadeIn` or `fadeOut` is called the counter does not move).
   - `fadeIn`: `fade = max(0, fade)`, direction +1. `fadeOut`: `fade = min(fade, 40)`, direction -1.
   - Each tick of the instance (§4.5 step 3): if `fade < 0` the instance **stops** (stopped flag set, looping cleared); then, in every case, `fade = fade + direction` and `volume = clamp(fade / 40, 0, 1)`.
   - There is **no upper cap** on `fade`: while fading in it keeps counting up past 40 (the volume stays 1.0), and a later `fadeOut` first lowers it to 40, so a fade-out always takes the same number of steps however long the loop played.
   - Computed examples: a new instance fading in has fade 1 and volume 0.025 after its first tick and volume 1.0 at tick 40; fading out from 40 it reaches fade 0 (volume 0) at tick 40, fade -1 (volume 0 after the clamp) at tick 41, and at tick 42 the test `fade < 0` stops it; the handler drops it from the map at its next tick. `play` computes the channel volume once from the initial volume 1.0 (§4.2, times the AMBIENT and master sliders); the instance's first tick, in the following engine tick, replaces it by 0.025.
   - Because the instance is **relative** the subtitle range reported for it is infinite (§6) and the engine sets the OpenAL source relative at position (0, 0, 0) while the attenuation stays LINEAR (both read). That this makes the loop a bed that does not depend on where the player stands is OpenAL's meaning of a relative source ((recalled, not verified): Open question 13).
2. **Additions.** For each `additions` entry, in list order: one `nextDouble()` of the **level's random**; if the value is `< tick_chance` play `forAmbientAddition(sound)` (§5.1).
3. **Mood.** If `A.mood` exists, run the mood rule below once per tick.

**Mood rule.** The handler keeps a number `moodiness` (starts 0). Per tick, pick a block position by three independent `nextInt(2 x extent + 1)` draws (level random, in the order x, y, z): `x = floor(player.x + r1 - extent)`, `y = floor(player.eyeY + r2 - extent)`, `z = floor(player.z + r3 - extent)`. Let `sky` be the **sky light** and `block` the **block light** at that position (the client's `getBrightness`).

- If `sky > 0`: `moodiness -= (sky / 15) x 0.001`.
- Otherwise: `moodiness -= (block - 1) / tick_delay`. (So a dark position with block light 0 adds 1/6000, block light 1 changes nothing, higher block light lowers it.)
- If `moodiness >= 1.0`: let `d` be the distance from the player's eye to the centre of the chosen block (x + 0.5, y + 0.5, z + 0.5); play `forAmbientMood(sound, random, eye + (centre - eye) / d x (d + offset))` (a LINEAR, volume 1, pitch 1 AMBIENT sound **offset blocks beyond** the chosen block along the same ray) and set `moodiness = 0`.
- Otherwise `moodiness = max(moodiness, 0)`.

The F3 "sound mood" entry shows `moodiness` (13 §5.4, the `sound_mood` row: it appends " (Mood %d%%)", mood x 100; §6 of 13 is the F5 camera modes). Worked example: standing in a dark cave (sky 0, block 0 everywhere in the 17 x 17 x 17 cube), `moodiness` rises 1/6000 each tick, so the cave sound plays about 6000 ticks (5 minutes) after the last one, from a block within 8 blocks, placed 2 blocks farther away.

### 8.3 Underwater (`UnderwaterAmbientSoundHandler` and its instances)

All of this closes Open question 7. The ambient handlers of the local player are created in the order underwater, bubble column, biome (the constructor's list) and ticked in that order from `LocalPlayer.tick`, after the superclass tick and the first-person hand tick.

- **The flag `isUnderWater` and the enter and exit sounds** (`LocalPlayer.updateIsUnderwater`, which `Player.tick` calls every tick before the entity tick). `LocalPlayer.isUnderWater()` returns the field `wasUnderwater`. The local player's method first remembers the field's old value, then calls the superclass method, which **overwrites the field every tick** with "the eyes are in the water fluid" (`isEyeInFluid(WATER)`). **Spectators:** right after that update, for a spectator the method returns; so the field **is** updated for a spectator as well (the superclass call has already stored the new value before the spectator test; only the comparison below is skipped) and a spectator gets no enter sound, no exit sound and no loop instance. For every other player: when the old value was false and the new one is true, `ambient.underwater.enter` is played (`Level.playLocalSound(x, y, z, event, AMBIENT, volume 1.0, pitch 1.0, distance delay false)` at the player's x, y, z: a positional LINEAR instance at the entity position, no distance delay, seed from the client level's `nextLong`, §3.4, §4.6) and a **new** `UnderLiquidAmbientSoundInstance` (below) is created and played; when the old value was true and the new one is false, `ambient.underwater.exit` is played in the same way (AMBIENT, 1.0, 1.0, player position) and no instance is created or stopped (the loop instance notices the change itself). Consequences, all computed from these rules: a spectator who becomes a survival player while under water has old = new = true, so he gets **no** loop and no enter sound until he leaves the water and enters it again; the underwater additions (below) and the music's `underwater` flag (§7.2) use the same field and are not gated by the spectator test.
- **Loop instance** (`UnderLiquidAmbientSoundInstance`, event `ambient.underwater.loop`, read): AMBIENT, **looping, delay 0, relative, initial volume 1.0**, default LINEAR attenuation and position (0, 0, 0) like the biome loop (§8.2), so its subtitle range is infinite. State: `fade`, initially 0, and a predicate that is `LocalPlayer.isUnderWater` (the method reference of `underwater(player)`). Each tick (§4.5 step 3): if the player `isRemoved` **or** `fade < 0`, the instance stops and nothing else happens this tick; otherwise `fade` is increased by **1** when the predicate holds and decreased by **2** when it does not; then `fade = min(fade, 40)` (`FADE_DURATION` 40; the cap is on top only, there is no lower clamp); then `volume = max(0, min(fade / 40, 1))`. So: **fade-in takes 40 ticks** (volume n/40 after n ticks, 1.0 at tick 40, then pinned at 1.0 while the player stays under water); **fade-out takes about 20 ticks**: from fade 40 the counter reaches 0 at tick 20 (volume 0), is -2 at tick 21 (volume 0), and the test `fade < 0` stops the instance at tick 22 (computed). The instance is also stopped when the local player is removed. Since the predicate is the player's current state and not a one-way fade, an old instance that is still fading out when the player gets under water again climbs again and never stops while the player stays under water, **while the re-entry has created a second instance of the same loop**: within the 22 ticks after leaving the water, re-entering leaves two loop instances playing at once (computed from the rules above); after 22 ticks the old one has stopped.
- **Additions** (`UnderwaterAmbientSoundHandler`; constants `CHANCE_PER_TICK` 0.01, `RARE_CHANCE_PER_TICK` 0.001, `ULTRA_RARE_CHANCE_PER_TICK` 0.0001): the handler keeps a delay `tickDelay` (initially 0), decreases it by 1 each tick and acts only when `tickDelay <= 0` and `LocalPlayer.isUnderWater` is true; it is reset to 0 whenever a sub-sound is started, so it never exceeds 0 and there is no waiting. When acting, one `nextFloat()` of the level's random, `r`: `r < 0.0001` plays `ambient.underwater.loop.additions.ultra_rare`; else `r < 0.001` plays `ambient.underwater.loop.additions.rare`; else `r < 0.01` plays `ambient.underwater.loop.additions`. So per tick under water the chances are 0.0001, 0.0009 and 0.009 (0.01 in total). Each is a new `UnderLiquidSubSound` instance (read): AMBIENT, **not looping**, delay 0, **relative**, **volume 1.0 constant**, pitch the default 1.0, default LINEAR attenuation; its tick stops it when the local player `isRemoved` or `isUnderWater()` is false; there is **no ramp** of any kind (a sub-sound plays at full volume until its file ends or the player leaves the water, which stops it at the next engine tick).
- **Bubble column handler** (`BubbleColumnAmbientSoundHandler`, the second of the three handlers; one per local player object, created with `firstTick` true and `wasInBubbleColumn` false). `LocalPlayer.tick` returns at once while `ClientPacketListener.hasClientLoaded()` is false. Each tick the handler takes the player's bounding box **inflated by (0, -0.4, 0)** (0.4 less at the bottom and at the top: a standing player's box of height 1.8 becomes 1.0 high, from 0.4 to 1.4 above the feet) and then **deflated by 1.0E-6 on every axis**, and looks for the **first block state that is a bubble column** among the states of that box (`getBlockStatesIfLoaded`: the integer positions from `floor(min)` to `floor(max)` on each axis, visited with x changing fastest, then y, then z; the result is **empty when any chunk of that range is not loaded**). When one is found: **if `wasInBubbleColumn` is false, `firstTick` is false and the player is not a spectator**, the handler plays `block.bubble_column.whirlpool_inside` when the state's `drag_down` property is true, else `block.bubble_column.upwards_inside`, through `LocalPlayer.playSound`, that is `Level.playLocalSound(player x, y, z, sound, the player's sound source (PLAYERS), volume 1.0, pitch 1.0, distanceDelay false)` (a one-shot instance at the player's position, the seed from the client level's `nextLong`, §3.4); then `wasInBubbleColumn` becomes true. When none is found `wasInBubbleColumn` becomes false. At the end of every tick `firstTick` becomes false. So the sound plays once per **entry** into a bubble column, never in the first tick of a new local player object (a player who logs in, respawns or changes dimension inside a column is silent until he leaves and enters again) and never for a spectator; when the box touches two columns with different `drag_down` values, the one met first in the order above decides.

### 8.4 Weather

Rain and snow sounds, and thunder, are played from the world renderer and the weather event handling; they are not traced here: see Open question 8 and document 60.

### 8.5 The attribute `minecraft:audio/firefly_bush_sounds` and the firefly bush

**The attribute** (`EnvironmentAttributes.FIREFLY_BUSH_SOUNDS`, read): a Boolean (`AttributeTypes.BOOLEAN`, a not-interpolated type with the boolean modifier library), **default false**, syncable, not spatially interpolated (so a position read takes the noise-biome path of §7.4, although no biome or dimension type sets it).

**Its data in the jar.** Exactly one data file mentions it: `data/minecraft/timeline/day.json` (clock `minecraft:overworld`, `period_ticks` 24000). Its track `minecraft:audio/firefly_bush_sounds` has the modifier **`or`**, no `ease` member, and two keyframes: tick **12600** with value true and tick **23401** with value false. The timeline `minecraft:day` is a member of the tag `minecraft:in_overworld`, which the `overworld` and `overworld_caves` dimension types list as their `timelines`; the tags `in_nether` and `in_end` contain only `#minecraft:universal` (which holds `minecraft:villager_schedule`), so in the Nether and the End the attribute stays at its default false. The `or` modifier combines the running value (false from the default, since no biome or dimension layer sets it) with the track value. The boolean type mixes keyframes with a step of threshold 1.0 (§7.4), i.e. each keyframe's value holds until the next keyframe: the track is therefore **true from clock tick 12600 up to (not including) tick 23401 of each 24000-tick day and false otherwise** ((inferred) for the wrap-around between 23401 and the next 12600, which keeps the last keyframe's false: the timeline sampler was not traced, Open question 15). For orientation in the same file: the track turns true 400 ticks before the time marker `minecraft:night` (tick 13000) and false 599 ticks before the end of the day (tick 24000).

**What `FireflyBushBlock` does with it** (`animateTick(state, level, pos, random)`, the client-side animation tick; read in full). Per call, in this order:

1. One draw `random.nextInt(30)`. When it is **0** (probability 1/30), and the attribute at the bush (`level.environmentAttributes().getValue(FIREFLY_BUSH_SOUNDS, pos)`, a position read at the block centre, §7.4) is true, **and** `level.getHeight(MOTION_BLOCKING_NO_LEAVES, pos)` is **not greater than** the bush's Y (the bush is not under a roof of anything that blocks motion, leaves excepted; the heightmap value convention is (recalled, not verified): the Y just above the highest qualifying block), then `level.playLocalSound(pos, block.firefly_bush.idle, AMBIENT, volume 1.0, pitch 1.0, distance delay false)` is played: the block-position overload, so a LINEAR AMBIENT instance at the block centre (x + 0.5, y + 0.5, z + 0.5), no distance delay (§4.6), seed from the client level's random, §3.4. No further random number is drawn for the sound (the volume and pitch are constants).
2. Independently of step 1 (a particle, not a sound): when `level.getMaxLocalRawBrightness(pos)` is **13 or less**, one `random.nextDouble()` is drawn and, when it is `<= 0.7`, three further `nextDouble()` draws (in the order x, y, z) give a `firefly` particle at `(pos.x + 10 r1 - 5, pos.y + 5 r2, pos.z + 10 r3 - 5)` with zero velocity (`addParticle(FIREFLY, x, y, z, 0, 0, 0)`).

Worked example (sound): a bush at the surface during tick 15000 of the day, in any biome: every `animateTick` call has a 1/30 chance of playing `block.firefly_bush.idle` once; at tick 9000 or in the Nether the attribute is false and the bush never plays it.

## 9. Data-driven item sounds read from the jar: goat horn instruments and jukebox songs

These two tables answer the CC-0014 question (which sound each horn plays) and give the song data the jukebox of 31-4 uses. They are data files of the jar, not code.

### 9.1 Goat horn instruments (`data/minecraft/instrument/*.json`, 8 files)

Each file has `description` (`{"translate": "instrument.minecraft.<name>"}`), `range` 256.0, `sound_event` and `use_duration` 7.0. The sound events are the eight generated registrations `item.goat_horn.sound.0` to `item.goat_horn.sound.7` (46 §14.2, ids 845 to 852, so the Holder VarInt on the wire is 846 to 853).

| Instrument | Sound event | Sound event id | Tag |
|---|---|---|---|
| `ponder_goat_horn` | `item.goat_horn.sound.0` | 845 | `regular_goat_horns` (1st) |
| `sing_goat_horn` | `item.goat_horn.sound.1` | 846 | `regular_goat_horns` (2nd) |
| `seek_goat_horn` | `item.goat_horn.sound.2` | 847 | `regular_goat_horns` (3rd) |
| `feel_goat_horn` | `item.goat_horn.sound.3` | 848 | `regular_goat_horns` (4th) |
| `admire_goat_horn` | `item.goat_horn.sound.4` | 849 | `screaming_goat_horns` (1st) |
| `call_goat_horn` | `item.goat_horn.sound.5` | 850 | `screaming_goat_horns` (2nd) |
| `yearn_goat_horn` | `item.goat_horn.sound.6` | 851 | `screaming_goat_horns` (3rd) |
| `dream_goat_horn` | `item.goat_horn.sound.7` | 852 | `screaming_goat_horns` (4th) |

(The tag membership is from 25 part 7 §12.1, not re-read here; the sound mapping, the range and the use duration were read from the jar.) **Playing** (`InstrumentItem.play`, read again): `Level.playSound(null, player, event, RECORDS, range / 16, 1.0)`, the entity-bound overload, so the server sends a Sound Entity packet (05b 0x76, §2.2) with source RECORDS (2), **volume 16.0**, pitch 1.0 and a seed, to the players within the broadcast range of that volume; the client plays it as an entity-bound instance (§5.2). With the audible range of §4.3 (attenuation distance 16 times `max(volume, 1)` = 256 blocks for a sound entry with the default attenuation distance), the horn is heard up to 256 blocks. The game event `instrument_play` is fired at the player's position (read). The use animation, the cooldown (`floor(use_duration x 20)` = 140 ticks) and the stack handling are in 25 part 7 §12.2 and 58. Which sound **file** each event plays is in the missing `sounds.json` (§1).

### 9.2 Jukebox songs (`data/minecraft/jukebox_song/*.json`, 22 files)

Each file has `description` (`{"translate": "jukebox_song.minecraft.<name>"}`), `sound_event` (`minecraft:music_disc.<name>`), `length_in_seconds` and `comparator_output`. `lengthInTicks` is `ceil(length_in_seconds x 20)` (31-4 §2: the song player; every length in the jar is a whole number of seconds). The client plays the song with `forJukeboxSong` (§5.1: source RECORDS, volume 4.0, LINEAR, so the audible range is 64 blocks for the default attenuation distance), at the block position centre (31-4, level event 1010). The jar's name text for each song is `jukebox_song.minecraft.<name>` in `lang/en_us.json` (for example "C418 - 13"); the "Now Playing: %s" text is `record.nowPlaying`.

Rows are ordered by comparator output, then by name. The 22 `music_disc.<name>` events are registered sound events (46 §14.3).

| Song | Sound event | Length (s) | Length (ticks) | Comparator output |
|---|---|---|---|---|
| `13` | `music_disc.13` | 178 | 3560 | 1 |
| `cat` | `music_disc.cat` | 185 | 3700 | 2 |
| `blocks` | `music_disc.blocks` | 345 | 6900 | 3 |
| `chirp` | `music_disc.chirp` | 185 | 3700 | 4 |
| `far` | `music_disc.far` | 174 | 3480 | 5 |
| `mall` | `music_disc.mall` | 197 | 3940 | 6 |
| `mellohi` | `music_disc.mellohi` | 96 | 1920 | 7 |
| `bounce` | `music_disc.bounce` | 234 | 4680 | 8 |
| `stal` | `music_disc.stal` | 150 | 3000 | 8 |
| `lava_chicken` | `music_disc.lava_chicken` | 134 | 2680 | 9 |
| `strad` | `music_disc.strad` | 188 | 3760 | 9 |
| `tears` | `music_disc.tears` | 175 | 3500 | 10 |
| `ward` | `music_disc.ward` | 251 | 5020 | 10 |
| `11` | `music_disc.11` | 71 | 1420 | 11 |
| `creator_music_box` | `music_disc.creator_music_box` | 73 | 1460 | 11 |
| `creator` | `music_disc.creator` | 176 | 3520 | 12 |
| `wait` | `music_disc.wait` | 238 | 4760 | 12 |
| `pigstep` | `music_disc.pigstep` | 149 | 2980 | 13 |
| `precipice` | `music_disc.precipice` | 299 | 5980 | 13 |
| `otherside` | `music_disc.otherside` | 195 | 3900 | 14 |
| `relic` | `music_disc.relic` | 218 | 4360 | 14 |
| `5` | `music_disc.5` | 178 | 3560 | 15 |

Comparator output 1 to 15 are all used; the values 3 (`blocks`), 4 (`chirp`), 6 (`mall`) and others are unique, while 8 (`bounce`, `stal`), 9 (`lava_chicken`, `strad`), 10 (`tears`, `ward`), 11 (`11`, `creator_music_box`), 12 (`creator`, `wait`), 13 (`pigstep`, `precipice`) and 14 (`otherside`, `relic`) are shared by two songs. Output 15 is `5`.

## 10. Open questions

1. **Channels and positional sounds.** Whether the shipped audio files are mono for positional sounds and stereo for music, and the OpenAL stereo-source behaviour, are properties of files and library code that are not in the artifact (§1.4). A client that decodes the real files must check each file's channel count itself; the engine's only limit is 1 or 2 channels. The Vorbis decoder itself (JOrbis, `com.jcraft.jogg` and `com.jcraft.jorbis`) is **not in the artifact** (0 entries under `com/jcraft/`, §1.4): a client needs its own Ogg Vorbis decoder, and nothing in the jar says how the vanilla one behaves beyond the sample conversion of §1.4.
2. **EntityBoundSoundInstance stop rule.** Closed in §5.2: the instance stops when the entity `isRemoved`; a silent entity (`isSilent`) is refused at `play` and stopped by the ticking pass; the position is copied each tick through `float`.
3. **Subtitle overlay layout.** Width, arrows, colours and fade of `SubtitleOverlay` (a repeat refreshes the line; time 3000 ms; looping line bright for 500 ms) were not read in full.
4. **Screens with background music.** Closed in §7.2: only `WinScreen` overrides `Screen.getBackgroundMusic` (`Musics.CREDITS`); the menu music `Musics.MENU` is chosen when there is no player, not by the title screen.
5. **Biome choice for not-interpolated attributes.** Closed in §7.4: the audio attributes are not flagged `spatiallyInterpolated` or `fullResolutionBiomes`, so the biome layer takes the noise biome of the 4 x 4 x 4 cell at the position (the camera position for music), with no blending.
6. **Records and music.** Whether the game lowers or stops background music while a record plays is not in the classes read here.
7. **Underwater sub-sound volumes.** Closed in §8.3: `UnderLiquidSubSound` is relative, not looping, volume 1.0 and pitch 1.0 with no ramp, and stops when the player is removed or not under water; the loop instance is relative, looping, and fades +1 per tick in and -2 per tick out (cap 40).
8. **Weather sounds** (rain, snow, thunder): not read in this document; 60 §5.5 has thunder and 60 Open question 4 lists the rest.
9. **Fetching the assets.** The artifact names no source for the asset index and objects (§1.2); where a program can fetch them from is not in the artifact. That the official launcher prepares or downloads the asset folder (§1, §1.2, §1.5), and that its index files carry a `size` member, are (inferred) and (recalled, not verified). The key spelling of the index (`minecraft/sounds.json`, `minecraft/sounds/<path>.ogg`) and the audio file inventory are (recalled, not verified).
10. **Unknown sound id.** What the `Holder` codec does when the sound id plus one is greater than 1,991 was not read (inline sounds are the safe form, 46 §14.1).
11. **`pauseAllExcept` callers.** Closed in §4.5 and §7.3: the only caller is `Minecraft.runTick`, with MUSIC and UI exempt, when the single-player pause (integrated server not published, `Gui.isPausing()`) is entered; the only `resume` caller is `Gui.setScreen` with a null screen. One residue: Open question 16.
12. **Part 2.** Document 60 exists (block sound types, step and fall rules, entity sounds, level events, note blocks, bells, respawn anchor, thunder). Still open there and here: the volume ramps and conditions of the tickable sound instances of §5.3 (elytra, minecart, riding, bee, guardian, sniffer; `DirectionalSoundInstance` and the bubble column handler are read), rain and snow sounds (60 Open question 4), the item data behind the equip, break and consume sounds (60 Open question 1) and the ambient block sounds (60 Open question 6).
13. **OpenAL behaviour of relative sources and panning.** The jar sets the relative flag, the attenuation model and the position of each source, but contains no OpenAL code: that a relative source at (0, 0, 0) is heard at constant gain wherever the player is (the biome and underwater loops, the UI and music sounds, §4.3, §8.2, §8.3) and that panning comes from the listener orientation are (recalled, not verified).
14. **The now-playing toast.** `MusicManager` and the slider call `ToastManager.showNowPlayingToast` (§4.2, §7.3); what the toast shows (probably the current music's name key, `getCurrentMusicTranslationKey`) and its layout were not read.
15. **Firefly sound details.** The wrap-around of the boolean track of `firefly_bush_sounds` (true from tick 12600 to 23401, (inferred): the timeline sampler was not traced) and the heightmap value convention behind `getHeight(MOTION_BLOCKING_NO_LEAVES, pos) <= pos.y` (§8.5) are (inferred) and (recalled, not verified).
16. **`Overlay.isPausing`.** `Gui.isPausing` is "pause screen or pausing overlay" (§4.5); the overlay classes' own `isPausing` values were not read.
17. **Probe mix for `music_volume`.** The camera probe's partial-tick function of the `Float` type was not read in detail; at the partial tick 1.0 that `getMusicVolume` passes the result is the new value up to float rounding, (inferred) (§7.4).
18. **Which game modes set `instabuild` and `mayfly`.** The creative music choice tests those two ability flags only (§7.2); that creative mode is the only mode that sets both is (inferred); the ability tables per mode were not read in this document.
19. **Firework and End flash details.** Closed in §4.6 (`isFarAwayFromCamera`: a squared distance of 256.0 or more, and the `playSound` field of the starter) and §5.3 (`EndFlashState` and `Vec3.directionFromRotation`).
