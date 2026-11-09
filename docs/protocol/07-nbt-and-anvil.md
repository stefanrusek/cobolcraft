# 07 — NBT binary format and Anvil region files

Sources: `net.minecraft.nbt.*` (`Tag`, `TagTypes`, `NbtIo`, `NbtIo$StringFallbackDataOutput`, `NbtAccounter`, the `*Tag` and
`*Tag$1` type classes, `NbtUtils`), `net.minecraft.network.FriendlyByteBuf` (`readNbt` / `writeNbt`),
`net.minecraft.world.level.chunk.storage.*` (`RegionFile`, `RegionFile$ChunkBuffer`, `RegionFileVersion`, `RegionFileStorage`,
`SerializableChunkData`, `EntityStorage`, `SectionStorage`), `PalettedContainer`, `Strategy`, `PalettedContainerFactory`,
`BlockState`, `StateHolder`, `Heightmap`, `DataLayer`, `SimpleBitStorage`.

In this version the chunk serializer class is `SerializableChunkData`. There is no `ChunkSerializer` class.

All multi-byte numbers in NBT and in region files are **big-endian** (Java `DataInput` / `DataOutput` / `ByteBuffer` defaults).

---

## 1. NBT tag types

| Id | Name | Payload |
|---|---|---|
| 0 | End | No payload. It marks the end of a compound. As a root, it means "no tag". |
| 1 | Byte | 1 byte, signed |
| 2 | Short | 2 bytes, signed |
| 3 | Int | 4 bytes, signed |
| 4 | Long | 8 bytes, signed |
| 5 | Float | 4 bytes, IEEE-754 single |
| 6 | Double | 8 bytes, IEEE-754 double |
| 7 | Byte Array | Int length N, then N bytes |
| 8 | String | UShort byte length L, then L bytes of Modified UTF-8 (§2) |
| 9 | List | Byte element type id, then Int count N, then N payloads of that type with no type bytes and no names |
| 10 | Compound | A sequence of entries, each `Byte type id ≠ 0`, `String name` (as in id 8), and payload. The sequence ends with a single `Byte 0` (End). |
| 11 | Int Array | Int length N, then N × Int |
| 12 | Long Array | Int length N, then N × Long |

Ids outside 0–12 are rejected (`TagType.createInvalid`, which raises an error on load). `Tag.MAX_DEPTH` = 512.

### 1.1 List rules (`ListTag`, `ListTag$1`)

- On read, a negative count is an error (`NbtFormatException`).
- On read, element type 0 (End) with a count > 0 is an error ("Missing type on ListTag"). An empty list may use any element type. The writer uses 0 for an empty list, because `identifyRawElementType` returns 0 when there are no elements.
- **Heterogeneous lists.** The in-memory list may hold mixed tag types. When written:
  - If every element has the same type, that type id is written and elements are written raw.
  - If the types differ, the element type is written as 10 (Compound). Every element that is not a compound is **wrapped** in a compound holding a single entry whose name is the empty string `""`. A compound element that already looks like a wrapper (exactly one entry, named `""`) is also wrapped. Other compound elements are written as-is.
  - On read, any compound element whose only entry is named `""` is unwrapped and replaced by that entry's value (`addAndUnwrap`).

### 1.2 Compound rules

- Entry order on write follows the in-memory map's iteration order, which is a hash map. Readers must not depend on order.
- If a name repeats in one compound on read, the last value wins (map put).

---

## 2. Strings: Modified UTF-8

NBT strings, including compound entry names and the root name, are read with Java `DataInput.readUTF` and written with
`DataOutput.writeUTF`.

| Aspect | Modified UTF-8 (NBT) | Standard UTF-8 |
|---|---|---|
| Length prefix | UShort **byte** count (0–65535) | — |
| U+0000 | Two bytes `C0 80`, so no zero byte appears in the data | Single byte `00` |
| U+0001–U+007F | 1 byte | 1 byte |
| U+0080–U+07FF | 2 bytes | 2 bytes |
| U+0800–U+FFFF | 3 bytes | 3 bytes |
| Supplementary characters (U+10000+) | Encoded as a UTF-16 surrogate pair, each surrogate written as its own 3-byte sequence, for 6 bytes total | 4 bytes |

Writing a string whose encoding is longer than 65535 bytes fails in Java (`UTFDataFormatException`). The file writer
(`NbtIo.write` → `writeUnnamedTagWithFallback`, through `NbtIo$StringFallbackDataOutput`) catches this and writes the empty
string instead. The network writer (`writeAnyTag`) has no fallback, so encoding fails.

This is different from network protocol strings (`String(max N)` in 00-data-types.md), which use a VarInt prefix and standard UTF-8.

---

## 3. Root framing: file vs network

| Context | Layout | Producer / consumer |
|---|---|---|
| File / region chunk ("named root") | `Byte type id`, then `String name`, then payload. The writer always writes the name as empty (`writeUTF("")` → `00 00`). The reader skips the name (`StringTag.skipString`). `NbtIo.read` requires the root to be a Compound, otherwise it fails with "Root tag must be a named compound tag". | `NbtIo.write(CompoundTag, DataOutput)`, `NbtIo.read(DataInput[, NbtAccounter])` |
| Network ("unnamed root", type `NBT` in this spec) | `Byte type id`, then payload, with **no name**. A type id of 0 is a complete tag (End) with no payload. | `FriendlyByteBuf.writeNbt` → `NbtIo.writeAnyTag`; `FriendlyByteBuf.readNbt` → `NbtIo.readAnyTag` |

On the network, writing a null tag sends End (`00`). `FriendlyByteBuf.readNbt(ByteBuf, NbtAccounter)` returns "absent" for End.
The compound-only variant `readNbt(ByteBuf)` accepts End (absent) or Compound, and rejects any other root type with a decoder
error. Other network codecs (for example text components) may accept any root type. See the documents that use them.

---

## 4. Size and depth limits (`NbtAccounter`)

An accounter has a byte **quota** and a **max depth**. Every `create`/factory method in this jar uses max depth 512.

| Factory | Quota (accounted bytes) | Used for |
|---|---|---|
| `defaultQuota()` | 2,097,152 (`DEFAULT_NBT_QUOTA`) | `FriendlyByteBuf.readNbt(ByteBuf)`, which covers compound NBT read from network packets |
| `uncompressedQuota()` | 104,857,600 (`UNCOMPRESSED_NBT_QUOTA`) | Defined. Call sites were not enumerated. |
| `unlimitedHeap()` | `Long.MAX_VALUE` | `NbtIo.read(DataInput)` (region chunk reads via `RegionFileStorage`), `NbtIo.parse` scans |
| `create(n)` | n | caller-defined |

Depth: entering a Compound or List payload calls `pushDepth`, which fails with `NbtAccounterException` when the current depth is
already ≥ max depth (512). Leaving the payload pops the depth.

Quota: "bytes" are **estimated in-memory costs**, not wire bytes. They are charged as tags are read, and exceeding the quota fails with `NbtAccounterException`.

| Item read | Charge |
|---|---|
| End | 8 |
| Byte | 9 |
| Short | 10 |
| Int | 12 |
| Long | 16 |
| Float | 12 |
| Double | 16 |
| Byte Array | 24 + 1 × N |
| Int Array | 24 + 4 × N |
| Long Array | 24 + 8 × N |
| String (value) | 36 + 2 × (UTF-16 char count) |
| List | 36 + 4 × N, plus the elements |
| Compound | 48, plus for each entry the name (28 + 2 × char count) and the value, plus 36 for each name not already present |

---

## 5. Compression wrappers

### 5.1 Standalone NBT files (`NbtIo`)

| Method | Wrapper |
|---|---|
| `readCompressed` / `writeCompressed` | **gzip** (`GZIPInputStream` / `GZIPOutputStream`) around a named-root NBT stream |
| `read(Path)` / `write(CompoundTag, Path)` | none (raw named-root NBT) |

### 5.2 Region chunk payloads (`RegionFileVersion`)

| Id | Option name | Wrapper (read / write) |
|---|---|---|
| 1 | *(none, so it cannot be selected for writing by name)* | gzip: `GZIPInputStream` / `GZIPOutputStream` |
| 2 | `deflate` | zlib (RFC 1950): `InflaterInputStream` / `DeflaterOutputStream` |
| 3 | `none` | uncompressed |
| 4 | `lz4` | LZ4 block stream from the lz4-java library: `net.jpountz.lz4.LZ4BlockInputStream` / `LZ4BlockOutputStream` with default settings. Its framing is the lz4-java "LZ4Block" stream format (inferred: it is defined by that library, not by Minecraft code). |
| 127 | *(none)* | "custom". Both wrappers throw `UnsupportedOperationException`. The reader handles id 127 specially: the payload begins with a Modified-UTF-8 string naming a compression identifier. This version never decodes it and logs either "Unrecognized custom compression" or "Invalid custom compression id", treating the chunk as unreadable. |

`DEFAULT` (and the initial selection) is **2 / deflate**. The write format is configurable through the server property
`region-file-compression`, using one of the option names above. Readers accept any id in the table regardless of the setting.
An unknown id is logged ("invalid chunk stream version") and the chunk reads as absent.

---

## 6. Anvil region files (`RegionFile`, `RegionFileStorage`)

### 6.1 Files and naming

| Item | Value |
|---|---|
| Region file name | `r.<regionX>.<regionZ>.mca`, where `regionX = chunkX >> 5` and `regionZ = chunkZ >> 5` (arithmetic shift, so floor division by 32). Values are decimal and may be negative. |
| Chunks per region | 32 × 32 |
| Oversized chunk file | `c.<chunkX>.<chunkZ>.mcc`, using absolute chunk coordinates, in the **same directory** as the region file |
| Folders | Each dimension's storage has `region/` (chunks, `ChunkMap`), `entities/` (entity chunks, `ServerLevel`), and `poi/` (points of interest, `ChunkMap`). All three use this exact `.mca` container format. |

### 6.2 Layout

| Offset | Size | Contents |
|---|---|---|
| 0 | 4096 | Location table: 1024 × Int |
| 4096 | 4096 | Timestamp table: 1024 × Int |
| 8192 | … | Chunk data in 4096-byte sectors. Sector numbers count from the file start, so sectors 0 and 1 are the header. |

Table index for a chunk = `(chunkX & 31) + (chunkZ & 31) × 32`.

Location entry (Int):

| Bits | Field |
|---|---|
| 8–31 | Sector offset (24 bits, unsigned; max 16,777,215) |
| 0–7 | Sector count (8 bits, 1–255) |

An entry of 0 means the chunk is not present. On open, entries with offset < 2 (overlapping the header), count = 0, or
`offset × 4096 > file size` are logged and treated as absent.

Timestamp entry (Int): seconds since the Unix epoch (`epochMillis / 1000`) of the last write or clear of that chunk.

The file length is padded to a multiple of 4096 on close (`padToFullSector`). A header shorter than 8192 bytes is logged as truncated.

### 6.3 Chunk payload

The payload starts at byte `sectorOffset × 4096` and spans `sectorCount` sectors:

| Field | Type | Notes |
|---|---|---|
| Length | Int | Number of bytes that follow, **including** the compression-type byte. It equals compressed data length + 1. |
| Compression type | Byte | An id from §5.2, possibly with flag `0x80` (§6.4). |
| Data | (Length − 1) bytes | The compressed, named-root NBT compound (§3). |

Reader checks (`getChunkDataInputStream`):
- Fewer than 5 bytes are available: "header is truncated", and the chunk is absent.
- Length = 0: "allocated, but stream is missing", and the chunk is absent.
- Length − 1 > bytes remaining in the allocated sectors: "stream is truncated", and the chunk is absent.
- Negative length: error, and the chunk is absent.

The writer (`RegionFile$ChunkBuffer`) reserves 4 zero bytes, writes the type byte, writes the compressed stream, and then patches
the Length to `total − 5 + 1`. The sector count allocated is `ceil(total / 4096)`.

### 6.4 Oversized chunks (external `.mcc`)

| Item | Value |
|---|---|
| Threshold | Sectors needed (`ceil((5 + data) / 4096)`) ≥ 256 (`EXTERNAL_CHUNK_THRESHOLD`) |
| External file contents | Only the compressed data, without the 5-byte length/type header. It is written to a temp file in the region directory and then moved over `c.<x>.<z>.mcc`. |
| Region stub | One sector containing Int Length = 1 and Byte `type | 0x80` (`EXTERNAL_STREAM_FLAG` = 128). The rest is padding. |
| Reading | If the type byte has bit `0x80` set, the low 7 bits (`type & ~0x80`) select the decompressor and the data is read from the `.mcc` file. A warning is logged if Length − 1 ≠ 0 ("Chunk has both internal and external streams"). If the `.mcc` file is missing or not a regular file, the chunk is absent. |
| Cleanup | Writing a chunk in-region again, or clearing it, deletes any `.mcc` file for that chunk. |

---

## 7. On-disk chunk NBT (`SerializableChunkData`) — `region/`

The root is a Compound. Keys are listed with their NBT types. "When" describes when the writer emits the key.

| Key | NBT type | When / notes |
|---|---|---|
| `DataVersion` | Int | Always. The current world data version (5023). Added by `NbtUtils.addCurrentDataVersion`. |
| `xPos` | Int | Always. Chunk X. |
| `yPos` | Int | Always. Min section Y of the dimension. Written, but **not read** by `parse`, which takes the height from the level. |
| `zPos` | Int | Always. Chunk Z. |
| `LastUpdate` | Long | Always. Game time. |
| `InhabitedTime` | Long | Always |
| `Status` | String | Always. Identifier of the chunk generation status. **If missing on read, the whole chunk is treated as absent** (`parse` returns null). |
| `blending_data` | Compound | Only when present (`storeNullable`) |
| `below_zero_retrogen` | Compound | Only when present |
| `UpgradeData` | Compound | Only when not empty |
| `sections` | List of Compound | Always (may be empty). See §7.1. |
| `isLightOn` | Byte (boolean) | Only when light is correct, written as 1. A missing key reads as false. |
| `block_entities` | List of Compound | Always. Each entry is a block entity's saved compound. Its inner keys are out of scope. |
| `entities` | List of Compound | Only for proto (not fully generated) chunks. Full chunks keep entities under `entities/` (§8). |
| `block_ticks` | List | Always. Scheduled block ticks. |
| `fluid_ticks` | List | Always. Scheduled fluid ticks. |
| `PostProcessing` | List of List of Short | Always. One inner list per section, holding packed section-relative positions. |
| `Heightmaps` | Compound | Always. Keys are heightmap type names (`WORLD_SURFACE`, `MOTION_BLOCKING`, …, the serialization keys of `Heightmap$Types`). Each value is a Long Array packed as in 06-chunk-format.md §3.1: 256 entries, `ceillog2(height + 1)` bits, no spanning. |
| `structures` | Compound | Always. Holds `starts` (Compound keyed by structure id) and `References` (Compound mapping structure id to Long Array of packed chunk positions). Their inner contents are out of scope. |

### 7.1 Section compound (elements of `sections`)

Sections are written for every light section Y from (min section Y − 1) to (max section Y + 1). Sections outside the block range
carry only light. A section compound that would be empty is not written at all.

| Key | NBT type | Notes |
|---|---|---|
| `Y` | Byte | Section Y, signed |
| `block_states` | Compound | Only for sections inside the block range. See §7.2. If missing on read, the section is filled with the default state (air). |
| `biomes` | Compound | Only for sections inside the block range. See §7.2. If missing on read, the section is filled with the default biome. |
| `BlockLight` | Byte Array (2048) | Present only when a block-light layer exists and is not empty. Nibble layout as in 06-chunk-format.md §7.1. A length other than 2048 is rejected by `DataLayer`. |
| `SkyLight` | Byte Array (2048) | The same rules, for sky light |

A section whose `Y` lies outside [min section Y, max section Y] keeps only its light arrays on read. Any `block_states`/`biomes` it has are ignored.

### 7.2 Paletted container on disk (`PalettedContainer.codecRW` / `codecRO`, `pack` / `unpack`)

The disk form **differs from the network form**:

| Key | NBT type | Notes |
|---|---|---|
| `palette` | List | **Always a local palette**, even for many distinct values. The disk form never stores global ids. Entry format is in §7.3. |
| `data` | Long Array | Optional (lenient). It is omitted when bits = 0, which means the palette has exactly one entry. When present, each entry is an index into `palette`. |

Bits per entry on disk are **not stored**. The reader derives them from the palette size n: bits = `getConfigurationForPaletteSize(n).bitsInStorage()`.

| Palette size n | Block states: bits on disk | Biomes: bits on disk |
|---|---|---|
| 1 | 0 (no `data`) | 0 (no `data`) |
| 2 | 4 | 1 |
| 3–4 | 4 | 2 |
| 5–8 | 4 | 3 |
| 9–16 | 4 | 4 (= ceillog2 n) |
| 17–32 | 5 | 5 |
| 33–64 | 6 | 6 |
| 65–128 | 7 | 7 |
| 129–256 | 8 | 8 |
| > 256 | ceillog2(n) | ceillog2(n) |

So the **minimum width for a block-state container with more than one palette entry is 4 bits**. Biomes go down to 1 bit. For
sizes above the strategy's indirect range (blocks > 256, biomes > 8), the configuration is Global, but `bitsInStorage` is still
`ceillog2(n)` and the data still indexes the local palette. The loader re-encodes it to global ids in memory.

Packing of `data` follows SimpleBitStorage (06-chunk-format.md §6): `floor(64 / bits)` entries per Long, entries never span Longs,
LSB first, and the Long count must equal `ceil(entryCount / floor(64 / bits))` exactly (otherwise there is a load error). Entry order
is the same as on the network: index `y·256 + z·16 + x` for blocks (4096 entries) and `y·16 + z·4 + x` for biomes (64 entries).

Palette order written by the vanilla server: distinct values in order of first occurrence while scanning indices 0 → entryCount−1
(the result of `pack` re-encoding into a fresh `HashMapPalette`). Readers accept any order consistent with `data`.

Load errors (reported, chunk section rejected or logged): n > 1 with no `data` ("Missing values for non-zero storage"), and a data length mismatch.

### 7.3 Palette entry formats

Block states (`BlockState.CODEC`, which in this version is an "either" codec):

| Form | When written | Layout |
|---|---|---|
| String | The state is its block's default state | Block identifier, e.g. `"ns:path"` |
| Compound | Any non-default state | `id`: String block identifier. `properties`: Compound mapping property name → value (String, inferred). The compound is dispatched on `id`. `properties` is optional and lenient: if it is missing or invalid, the block's default state is used. Blocks with a single state have no `properties`. |

When decoding, the string form is tried first and then the compound form. The key names are lowercase `id` and `properties`
(`StateHolder.codec`). This version does not use the older capitalized `Name` / `Properties` names. Property names and values are
registry content and are out of scope.

Biomes (`Registry.holderByNameCodec`): each entry is a String biome identifier.

---

## 8. `entities/` and `poi/` region folders

Both use the region container (§6) and the same compression ids. Each chunk payload is a named-root compound:

| Folder | Top-level keys |
|---|---|
| `entities/` | `DataVersion` (Int); `Position` (chunk position via `ChunkPos.CODEC`, an int stream, so an Int Array `[chunkX, chunkZ]` (inferred)); `Entities` (List of Compound, contents out of scope). On read, a `Position` mismatch is logged as "in the wrong location". |
| `poi/` | `DataVersion` (Int); `Sections` (Compound keyed by section Y, contents out of scope) |

---

## 9. CobolCraft world folder

Sections 1 to 8 describe the vanilla formats. This section is **CobolCraft's own** world folder. It reuses those formats,
but its `.dat` schemas are not the vanilla ones, so a vanilla server cannot open it and CobolCraft does not open vanilla saves
(design README Part 7, decision 9: vanilla-loadable saves are not a goal). Server worlds and single-player worlds use this
one format (FR-004). The folder holds all of a world's dimensions and is copied as a unit. Everything FR-014 lists as world
state is saved here and nowhere else.

The game has two world types, the **standard** and the **cobolcraft** world type ([../design/world-types.md](../design/world-types.md)
§1). They share this one folder format and this one schema (world-types Decision WT-21). The type is the `WorldType` key of
`level.dat` (§9.2); it selects the content set (keys of dimensions, blocks, items, entity types, biomes) and nothing in the
byte formats. Where a key's content differs by type, the tables below name both.

### 9.1 Layout

```text
<world>/
  level.dat
  access.dat
  players/<offline-uuid>.dat              one per player who has been in the world
  data/minecraft/wandering_trader.dat     standard world only, written when there is a value (§9.6)
  dimensions/<namespace>/<path>/
    region/r.<rx>.<rz>.mca                chunks (§6 region files, §7 chunk NBT, values in §9.4)
    entities/r.<rx>.<rz>.mca              entities: mobs, ground items, vehicles (§6 region files, §8, schema in §9.3)
    poi/r.<rx>.<rz>.mca                   points of interest, standard world only (§9.6)
    data/minecraft/raids.dat              standard world only, written when there are raids (§9.6)
```

| Item | Value |
|---|---|
| `<offline-uuid>` | The offline UUID of 02-handshake-status-login.md "Offline mode", written hyphenated and lower-case |
| `<namespace>/<path>` | The dimension key split at the colon. Standard world: `minecraft/overworld`, `minecraft/the_nether`, `minecraft/the_end`. Cobolcraft world: `cobolcraft/main` (the main dimension, [../design/standin-content.md](../design/standin-content.md) §5.1) and `cobolcraft/subroutine`, and one folder for each extra dimension. The two sets of names never coincide (world-types §2.2); the `WorldType` key decides, not the folder names. |
| Region file names | As §6.1, in each dimension's `region/`, `entities/` and `poi/` folders |
| `poi/` | Standard world: written, villagers and bees use points of interest (19 §22, 44 part 3); the format is §8. Cobolcraft world: not written, it has no points of interest. |
| `.dat` files | gzip-compressed NBT files (§5.1, `writeCompressed` / `readCompressed`). The root is a Compound in the file framing of §3 (type byte, empty name, payload). The world-folder contract's "unnamed root compound" means this empty name; it is not the network "unnamed root" of §3. |
| `DataVersion` | Every `.dat` root and every region chunk payload carries `DataVersion` (Int) = 5023, the value of §7 |

A folder is a world if and only if `level.dat` is present, and a folder with `dimensions/` content but no `level.dat` is not
opened (world-types §2.1, Decision WT-24). That replaces the first sentence of §9.5 for such a folder.

### 9.2 `.dat` schemas

`level.dat`:

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `LevelName` | String | World name, shown in the single-player world list |
| `WorldType` | String | `standard` or `cobolcraft`. Written at creation, never changed. Reading rules for an absent or unknown value: world-types §2.1. |
| `Seed` | Long | The world seed. The standard generator reads it (10 §7); the Login hashed seed is `obfuscateSeed(Seed)` (10 §7.7, world-types §2.1). Written for both types; a cobolcraft world stores it and never reads it. Input and hashing rules of the seed text: world-types §2.1, Decision WT-19. |
| `ContentJar` | String | Lower-case hex SHA-256 of the jar the standard world was created from (22 §6.4). Absent for a cobolcraft world. Informational (world-types Decision WT-6). |
| `GameMode` | Int | The game mode chosen when a single-player world is created. When the world is hosted by the client (core-host-api `CS-HOST-KIND` 1, and 2 for the host) it is the game mode of new players; guests get the guest mode chosen when the world is opened to others. A dedicated server (`CS-HOST-KIND` 0) ignores it and uses its `default-game-mode` setting. |
| `Time` | Long | **Game time**: ticks since the world was created, +1 per overworld tick whether or not the day advances (33 §3 and §10). It is not the time of day. Earlier worlds of feature 001 stored the time of day here (§9.2 before this revision); see "Time and clocks" below. |
| `Clocks` | Compound | Time-of-day state, one entry per world clock, named by the clock key (`minecraft:overworld`, `minecraft:the_end`; `cobolcraft:daylight` in a cobolcraft world, 09 §3.2). Each value is a Compound with the four fields of 33 §10 (world clocks): `total_ticks` (Long), `partial_tick` (Float, default 0), `rate` (Float, default 1.0), `paused` (Byte, default 0). The time of day is `total_ticks` taken modulo the period of the dimension's timeline (24000 for the reference timeline, 12 §3.2c). |
| `GameRules` | Compound | One entry per rule id with its value (Byte for a boolean rule, Int for an integer rule); an absent entry means the default of 16 §13. The server has one set (33 §8.1). The rule `advance_time` (default true) stops `total_ticks` of the clocks that have a daylight cycle from advancing when false; it never stops `Time` (33 §10, 33 §3). |
| `Spawn` | Compound | `Dimension` (String, dimension key), `X`, `Y`, `Z` (Double), `Yaw` (Float). Changed by command. The standard spawn search that fills it for a new world is 33 §6.2. |
| `Weather` | Compound | See "Weather" below; the form depends on `WorldType`. |

Time and clocks. A world written before this revision has no `Clocks` compound. It is read as follows: the value of `Time` is
both the game time and `total_ticks` of the world's single clock, and the next save writes both keys. (inferred: the only
existing writers keep one counter, 09 §3.2, so the two values were equal.) A cobolcraft world and a standard world differ only in
the clock key and in the number of clocks.

Weather. **Standard world:** one compound named `Weather` for the whole server with the five fields of 33 §10 (weather): `clear_weather_time`,
`rain_time`, `thunder_time` (Int) and `raining`, `thundering` (Byte). A dimension's rain level is derived from these and from the dimension's
own flags (33 §4), so there is no per-dimension entry. A missing field reads as 0 or 0 (false), which starts a fresh cycle (33 §4.1).
**Cobolcraft world:** one entry per dimension that has weather, named by the dimension key. A dimension without weather
(`cobolcraft:subroutine`, standin-content §14.2) has no entry. Each value is a Compound: `Kind` (String, weather kind key) and `Remaining`
(Int, ticks left, or −1 meaning "until changed": no countdown, standin-content §14.3). Whether the cobolcraft world's
weather timers also move to the standard record is Open question 10.

The world border (one record per dimension in 33 §10) is stored in the dimension folder as `data/minecraft/world_border.dat` with the framing of §9.6.
Network entity ids are assigned per run and are not stored anywhere in the folder.

`access.dat`:

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `Operators` | List of Compound | Players with operator status. An entry is an identity plus `Level` (Int, 1 to 4), the permission level of 15 §2.1 (1 moderators, 2 gamemasters, 3 admins, 4 owners). A player not in the list has level 0. |
| `Bans` | List of Compound | Banned players. An entry is an identity plus `Created` (String, the creation time as text), `Source` (String, the text name of the source that banned: 16 §11.3), `Expires` (String, `forever` when there is no expiry) and `Reason` (String, absent when none was given). |
| `AllowList` | List of Compound | Allow-listed players (identity only). The standard commands are `whitelist` (16 §11.22). |
| `AllowListEnforced` | Byte | 1 if the allow-list is enforced in this world, otherwise 0 |

An **identity** is `{Name: String, UUID: Int Array (4)}`. The UUID is the same offline UUID as the player file name, stored as four
Ints, most significant first (inferred: the vanilla `UUIDUtil` int-array form). A new operator gets the level the server grants by
default (16 §11.1: `PlayerList.op` gives the level of the server's `operatorUserPermissions`; the value was not read, so the
CobolCraft default is 4, Open question 13). IP bans (16 §11.4) are not part of this schema, because offline mode has no stable address
identity worth keeping (Open question 13).

A new world takes `AllowListEnforced` from the `allow-list` configuration setting (dedicated server) or 0 (single-player).
After that, only the allow-list on/off commands change it, and the setting no longer applies to that world. Single-player
worlds behave the same way.

`players/<offline-uuid>.dat`:

The file keeps CobolCraft's own path and framing. Its keys are the standard player keys of 45-3 §2 and §3, so that the standard
rules (45-3 §1.3 load, §1.6 first join, §3.2 load order, §7 join sequence) apply unchanged, plus three CobolCraft keys.

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `Name` | String | Offline name (CobolCraft key; 45-3 §12 notes that the standard file has no such key) |
| `Dimension` | String | Dimension key (CobolCraft key) |
| `Pos`, `Rotation` | List of 3 Double, List of 2 Float | Entity base keys (45-1 §5). `Pos` is the feet position. |
| `playerGameType`, `previousPlayerGameType` | Int | Game mode, numbering 0 to 3 (45-3 §3.4). Replaces the CobolCraft key `GameMode`. |
| `Health` | Float | Current health (LivingEntity key, 45-2) |
| `foodLevel`, `foodSaturationLevel`, `foodExhaustionLevel`, `foodTickTimer` | Int, Float, Float, Int | Hunger state, defaults 20, 5.0, 0.0, 0 (45-3 §2.3; 17 §4.9). Replaces the CobolCraft key `Food`. |
| `XpP`, `XpLevel`, `XpTotal`, `XpSeed`, `Score` | Float, Int, Int, Int, Int | Experience (45-3 §2.1; 17 §4.10) |
| `Inventory` | List of Compound | One `{Slot: Byte, id: String, count: Int}`, plus `components` when the stack has any (45-3 §4.1), per **non-empty** slot of the 36 storage slots. Slots 0 to 8 are the hotbar and 9 to 35 the main grid (45-3 §2.4). `id` is an item key. `count` is 1 to 99 (45-3 §12). |
| `SelectedItemSlot` | Int | Selected hotbar slot, 0 to 8. Replaces the CobolCraft key `HeldSlot`. |
| `equipment` | Compound | Armor and off-hand, keyed by slot name (45-3 §4.3). In the container numbering of 13 §3.5 and 45-3 §2.4 the armor slots are 36 to 39 and the off-hand is 40; this file never writes those numbers into `Inventory`. |
| `active_effects`, `respawn`, `LastDeathLocation`, `abilities`, `EnderItems`, `recipeBook`, `Air`, `Fire`, `fall_distance` and the other keys of 45-3 §2 and §3 and 45-2 | various | As written in those sections. A key absent on read takes the default given there. |

Reading is lenient in both directions. A file with the earlier keys (`GameMode`, `Food`, `HeldSlot`) and without the standard ones
is read through them (the value of `Food` is `foodLevel`; saturation 5.0 and exhaustion 0.0), and the next save writes the
standard keys only. In a cobolcraft world the item keys in `Inventory` and `equipment` are `cobolcraft:` keys; the
slot rules are the same in both types (README rule R2).

### 9.3 Entity storage (`entities/`)

Each chunk payload is the §8 `entities/` compound, stored as in §6.3 with compression id 2 (zlib, §5.2):

| Key | NBT type | Notes |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `Position` | Int Array (2) | `[chunkX, chunkZ]`. CobolCraft fixes the Int Array form that §8 marks as inferred. On read it must equal the chunk requested (45-1 §13, rule 3). |
| `Entities` | List of Compound | One compound per entity in the chunk, as below |

The entity compound is the **standard entity compound**. 45-1 §13 extends this section for the standard world type and fixes the
placement of each entity in the chunk of its position, the empty-chunk rule, the read pipeline and the save order; 45-1 §5 gives the
base keys, 45-1 §7 the nesting of passengers, and 45-1 §4 the identity rules. This section keeps only what CobolCraft decides.

| Item | Rule |
|---|---|
| `id` | The entity type key in full form: `minecraft:pig`, `minecraft:item` in a standard world; the `cobolcraft:` key of the type's registry (`cobolcraft:loose_item`, a mob type key of standin-content §3, as extended) in a cobolcraft world (45-1 §13). |
| Keys of each type | Per type, in the sibling documents: 45-1 (base, items, passengers), 45-2 (living entities, mobs, animals), 45-4 (land animals), 45-5 (hostile mobs), 45-6 (villagers, illagers, piglins), 45-7 (aquatic and miscellaneous mobs), 45-8 (vehicles, projectiles, ground items), 45-9 (bosses, decorations). |
| Ground item | A standard world writes `minecraft:item` as 45-8 specifies (`Item`, `Age` as Short, `Health` as Short, `PickupDelay`, `Thrower`, `Owner`). The earlier CobolCraft keys (`Item` as `{id, count}`, `Age` as Int) remain the form of the cobolcraft world's `cobolcraft:loose_item` until it adopts the standard item compound (Open question 11). |
| Unknown ids and invalid compounds | As 45-1 §4.2 and §6: skipped on load with a log line, never fatal, never deleting the rest of the chunk. |
| Players | Not stored here. They live in `players/` (§9.2). A vehicle whose only passenger is a player is not stored here either (45-1 §7.2). |
| Other entity-related saved data | Villager and raid state: §9.6. Brain, leash and owner references: 45-1 §10 and 45-2. |

The `Health` key of the earlier schema is now the LivingEntity key of 45-2 (a Float; a Short for `minecraft:item`).

### 9.4 Chunk storage (`region/`)

Chunk payloads follow §7 as written, with these CobolCraft values:

| Item | Value |
|---|---|
| Compression | Id 2 (zlib, the §5.2 default), as for `entities/` (§9.3) |
| `Status` | `minecraft:full` |
| Block-state palette entries (§7.3) | Standard world: the block keys and properties of the vanilla registry (24, 46; 04 §5.1). Cobolcraft world: the block keys and properties of standin-content §1 (as extended). |
| Biome palette entries (§7.3) | Standard world: the vanilla biome keys (04 §3.2, the generated data pack). Cobolcraft world: the biome keys of standin-content §4.3 (as extended). |
| `block_entities` | Standard world: one compound per block entity, in the form of 31-1 §2.2 ("with full metadata": `id`, `x`, `y`, `z`, `components` and the type's own keys) plus `keepPacked` as 31-1 §6 describes. The keys of each type are in 31-2 to 31-8 (31-1 §3.1 lists the 49 types). Cobolcraft world: the list is empty, it has no block entities. |
| `LastUpdate` | **Game time** at save: the `level.dat` `Time` value written by the same save (§9.2). |
| Block ticks and fluid ticks | Standard world: the saved ticks of 29 §12 (`block_ticks`, `fluid_ticks`). Cobolcraft world: empty lists. |

### 9.5 Behaviour

- A world folder without `level.dat` is created new, with all enabled dimensions, unless it holds `dimensions/` content (§9.1). Chunks are generated on first use. A
  chunk is saved when it has changed, or when an entity is in it at save time.
- A save writes every changed chunk, every chunk holding entities, the file of every online player and of every player who
  left since the previous save, `level.dat`, `access.dat`, and the saved-data files of §9.6 that changed.

### 9.6 Other saved data

The standard world keeps the saved-data files of 33 §10 and 45-6 §12.3 in the framing of 45-6 §12.3: gzip NBT, root keys `data` (the type's compound)
and `DataVersion` (Int, 5023), path `<namespace>/<path>.dat` below a `data/` folder. Placement (a design choice, because the artifact leaves the data folder to
the caller): world-wide data in `<world>/data/`, per-dimension data in `<world>/dimensions/<namespace>/<path>/data/`.

| File | Placement | Content |
|---|---|---|
| `minecraft/wandering_trader.dat` | world | 45-6 §12 |
| `minecraft/raids.dat` | dimension | 45-6 §12 (a missing file is an empty value) |
| `minecraft/world_border.dat` | dimension | the nine fields of 33 §10 (world border) |
| the remaining files of 33 §10 (`scheduled_events.dat`, `custom_boss_events.dat`, `ender_dragon_fight.dat`, `world_gen_settings.dat`) | not specified | Open question 12 |

A cobolcraft world writes none of these files (no raids, no wandering trader; its border is not specified). Clocks, weather, game rules and the
`level.dat` keys of §9.2 stay in `level.dat`: they are not split into saved-data files. That is the one place where this folder differs from the 26.3
layout of 33 §10, kept for Decision WT-21 of the world-type document.

---

## Composite types introduced here

None beyond those defined inline above. This file describes byte formats, not packet fields.

---

## Open questions

1. The exact on-disk byte layout of the lz4 wrapper (block size, checksum) is defined by the bundled lz4-java library, which was not disassembled here.
2. The serialization of each block-state property value (always a String?) comes from `StateDefinition.propertiesCodec` / `Property.codec`. Those were not disassembled, so it is marked inferred.
3. The `ChunkPos.CODEC` int-stream encoding for `entities/` `Position` was not fully traced (array length check and the int array vs list form).
4. Which call sites use `NbtAccounter.uncompressedQuota()` (for example `level.dat` or player data) was not enumerated.
5. Exact behaviour when a `block_states`/`biomes` compound fails to decode (whole chunk rejected vs. section reset) is handled
   inside `lambda$parse$3/$5`. That code was only partly read. An error is reported through `ChunkReadException` or the logger (inferred).
6. The sector allocation strategy for new writes (`RegionBitmap.allocate`, presumably first-fit) does not affect readers and was not documented in detail.
7. The DataVersion constant was taken from the brief (5023) and not re-read from `SharedConstants` / the `version.json` inside the jar.
8. §9.2: the world-folder contract gives the `UUID` entries as an Int Array of 4 but does not fix the Int order. Most
   significant first (vanilla `UUIDUtil`) is assumed.
9. §9.4: "§7 as written" makes CobolCraft write every key §7 marks "Always" (`Heightmaps`, `PostProcessing`, `block_ticks`,
   `fluid_ticks`, `structures`, `InhabitedTime`, `yPos`, and so on). The contract does not give CobolCraft values for them
   beyond those in §9.4. Empty lists and compounds (`structures` = `{starts: {}, References: {}}`, `PostProcessing` = one empty list per
   section), `InhabitedTime` 0, and heightmaps computed as in 06-chunk-format.md §3.1 are
   assumed.
10. §9.2 `Time`: this section makes it the game time (33 §3) and moves the time of day to `Clocks`. 09 §3.2 (Set Time: "Game time = `Time`") and
    standin-content §4.8 still describe the earlier single counter, and the cobolcraft world's day length of 30000 ticks is retired
    by the shared rules (README R2, 12 §3.2c). Whether the cobolcraft weather timers (`Kind`, `Remaining`) also move to the standard weather record
    is open (README GAP-11).
11. §9.3: whether the cobolcraft world's `cobolcraft:loose_item` adopts the standard item compound (45-8) is open. The shared rules say the ground-item
    physics are the standard ones (README R2); the stored keys are content-neutral.
12. §9.6: the other saved-data files of 33 §10 (`scheduled_events.dat`, `custom_boss_events.dat`, `ender_dragon_fight.dat`, `world_gen_settings.dat`) are not
    specified for the CobolCraft folder. 33 Open question 4 (the wrapper keys and the border path) applies to the files that are.
13. §9.2 `access.dat`: the stored form of an operator level, of a ban's time and expiry text, and the absence of IP bans are CobolCraft choices (README
    decision 8); the vanilla list files are not specified (16 §11 intro). The default level a new operator gets was not read (16 §11.1).
