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
| `poi/` | `DataVersion` (Int); `Sections` (Compound keyed by section Y; contents in §10.6) |

---

## 9. CobolCraft world folder

Sections 1 to 8 describe the vanilla formats. This section is **CobolCraft's own** world folder. It reuses those formats,
but its `.dat` schemas are not the vanilla ones, so a vanilla server cannot open it. This section is the folder of the **cobolcraft** world type
(and of the hidden `debug` type, and of standard worlds made by feature 001); a world of the **standard** type, and any folder from a real 26.3 game, is in
the game's own layout of §10, which CobolCraft opens and writes back (operator request; reconciled with design README Part 7, decision 9, which
still describes the CobolCraft schemas of this section). Server worlds and single-player worlds use this
one format (FR-004). The folder holds all of a world's dimensions and is copied as a unit. Everything FR-014 lists as world
state is saved here and nowhere else.

The game has two world types, the **standard** and the **cobolcraft** world type (plus a hidden third value, `debug`, a test tool with the standard content set and one dimension, [../design/debug-world.md](../design/debug-world.md)) ([../design/world-types.md](../design/world-types.md)
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
opened (world-types §2.1, Decision WT-24). §9.5 already applies this rule.

### 9.2 `.dat` schemas

`level.dat`:

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `LevelName` | String | World name, shown in the single-player world list |
| `WorldType` | String | `standard` or `cobolcraft`, or the hidden `debug` (standard content set, test tool only, docs/design/debug-world.md). Written at creation, never changed. Reading rules for an absent or unknown value: world-types §2.1. |
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
| Unknown ids and invalid compounds | As 45-1 §4.2 and §6: skipped on load with a log line, never fatal, never deleting the rest of the chunk. **Exception:** an entity `id` that is missing from the opened world type's registries fails the whole chunk closed under WT-23 (§9.7 rule 6); 45-1 §4.2 step 2 (skip the entity) describes the artifact, and WT-23 overrides it for CobolCraft. |
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

- A world folder without `level.dat` is created new, with the dimension folders of all enabled dimensions made when the world is created, unless it holds `dimensions/` content (§9.1). `region/` files appear only when a chunk is first saved (inferred); §9.7 follows the same rule. (Artifact behaviour, read: it builds every dimension's level at start and creates each dimension's `data/` folder then, `ServerChunkCache`.) Chunks are generated on first use. A
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
| `scheduled_events.dat`, `custom_boss_events.dat`, `ender_dragon_fight.dat` (33 §10) | not specified | Open question 12 |
| `world_gen_settings.dat` (33 §10) | not written: the seed is the `Seed` root key of `level.dat` (§9.2); `generate_structures`, `bonus_chest` and `dimensions` are not specified | Open question 12 |

A cobolcraft world writes none of these files (no raids, no wandering trader; its border is not specified). Clocks, weather, game rules and the
`level.dat` keys of §9.2 stay in `level.dat`: they are not split into saved-data files. That is one of several differences from the 26.3
layout of 33 §10, all listed in §9.7 (kept for Decision WT-21 of the world-type document).

### 9.7 The world-folder contract: what the artifact does, what CobolCraft decides

This section answers world-types Open question 12 for the layout. Source for the "Read" column: static reading of the shipped
26.3 client jar (`tmp/minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, the
artifact recorded in README), with no execution. The classes read are `LevelStorageSource$LevelStorageAccess`, `LevelResource`,
`DimensionType.getStorageFolder`, `Identifier.resolveAgainst`, `PrimaryLevelData`, `SavedDataStorage`, `PlayerDataStorage`,
`ServerChunkCache`, `ChunkMap`, `ServerLevel`, `WorldGenSettings`, `WorldOptions`, and the file-migration classes in
`net.minecraft.util.filefix.fixes` (which name the destination of every file in the current layout). The "CobolCraft" column
is **our design**, not read from the artifact; where a row says so it is marked **(decision)**. Decisions here are adopted
defaults of the design documents and are not operator rulings unless the row says so.

**Folder tree.** Read from the artifact (the 26.3 layout), then CobolCraft's.

| Path below the world folder | Read from the artifact (26.3) | CobolCraft (decision) |
|---|---|---|
| `level.dat` | gzip NBT. The root compound holds one compound `Data` (written by `LevelStorageAccess.saveDataTag`); every key below sits inside `Data`, including `DataVersion` (added by `NbtUtils.addCurrentDataVersion`). Written to a temporary file, then swapped in, with the previous one kept as `level.dat_old` | Same file name and gzip framing. **The keys sit in the root compound itself, with no `Data` wrapper** (§9.2, as feature 001 wrote them). The three added keys `WorldType`, `Seed`, `ContentJar` are root keys beside `DataVersion`. |
| `level.dat_old`, `session.lock`, `icon.png`, `datapacks/`, `generated/`, `resourcepacks/resources.zip` | The names of `LevelResource` (the resource list is `players/advancements`, `players/stats`, `players/data`, `players`, `level.dat`, `level.dat_old`, `icon.png`, `session.lock`, `generated`, `datapacks`, `resourcepacks/resources.zip`, `data`). A folder holds a world when `level.dat` or `level.dat_old` exists | Not part of the CobolCraft contract. A folder is a world only if `level.dat` exists (WT-24, §9.1 **(decision)**); `level.dat_old` does not count. Any other file or folder found is ignored on read and left untouched. |
| `dimensions/<namespace>/<path>/` | One folder per dimension: the dimension key's namespace and path as two folder levels under `dimensions` (`DimensionType.getStorageFolder`; `Identifier.resolveAgainst` rejects a path that escapes the world folder). The three built-in dimensions are `dimensions/minecraft/overworld`, `dimensions/minecraft/the_nether`, `dimensions/minecraft/the_end` (the old names `DIM-1` and `DIM1` are moved here by `DimensionStorageFileFix`, which also renames `chunks.dat` to `minecraft/chunk_tickets.dat` and the old End file `raids_end.dat` to `raids.dat` inside the End folder, and a world with no `dimensions` folder, or an empty one, is assumed by the file fixer's dimension discovery (`FileRelation.discoverDimensions`) to have exactly these three; that is a migration-time rule, not a runtime one). | The same rule. **A standard world has these three folders**, created with the world; their `region/` files appear when a chunk is first saved. A cobolcraft world has `dimensions/cobolcraft/main` and `dimensions/cobolcraft/subroutine` instead (world-types §2.2 **(decision)**). The `WorldType` key, not the folder names, decides the type. |
| `<dimension>/region/` | Chunk region files, `r.<rx>.<rz>.mca` (§6, §7) | Same (§9.4). |
| `<dimension>/entities/` | Entity region files (§8) | Same (§9.3). |
| `<dimension>/poi/` | Points-of-interest region files (§8) | Standard world only (§9.1). |
| `<dimension>/data/<namespace>/<name>.dat` | The dimension's own saved-data store (`ServerChunkCache` creates the folder and a `SavedDataStorage` on it). Files read from the fix classes: `minecraft/raids.dat`, `minecraft/world_border.dat`, `minecraft/chunk_tickets.dat`, and `minecraft/ender_dragon_fight.dat`, which the file fix `LevelDatToSavedDataFileFix` writes into the End dimension's folder (that it is read from there at run time was not traced, (inferred)) | §9.6 (`raids.dat`, `world_border.dat`; the others are not specified). |
| `data/<namespace>/<name>.dat` | The world-wide saved-data store (`MinecraftServer` builds its `SavedDataStorage` on the `data` resource). Files read: `minecraft/weather.dat`, `minecraft/world_clocks.dat`, `minecraft/game_rules.dat`, `minecraft/world_gen_settings.dat`, `minecraft/scheduled_events.dat`, `minecraft/wandering_trader.dat`, `minecraft/custom_boss_events.dat`, `minecraft/scoreboard.dat`, `minecraft/stopwatches.dat`, `minecraft/random_sequences.dat`, `minecraft/maps/last_id.dat`, `minecraft/maps/<n>.dat`, and `<namespace>/command_storage.dat` | §9.6 places `minecraft/wandering_trader.dat` here. **Weather, clocks and game rules are not saved-data files in CobolCraft: they stay in `level.dat`** (§9.2, WT-21 **(decision)**). The remaining files are not specified. |
| `players/` | Player files are `players/data/<uuid>.dat` (`LevelResource.PLAYER_DATA_DIR`, `PlayerDataStorage`; the file name is the UUID in hyphenated text form plus `.dat`; the older folder names `playerdata`, `advancements`, `stats` are moved to `players/data`, `players/advancements`, `players/stats` by `PlayerStorageFileFix`). The previous file is kept as `<uuid>.dat_old` | **`players/<offline-uuid>.dat`, one level shallower** (§9.1 **(decision)**; the key schema is §9.2). No `_old` copy, no `advancements/` or `stats/` folders. |

**Saved-data file framing (read).** Every file of a `data/` folder is gzip NBT. The root compound holds the type's value under
the key `data` and `DataVersion` (Int); the file name is the saved-data type's identifier with `.dat` appended and is
resolved by the same namespace-then-path rule as a dimension. This matches §9.6.

**Where the three CobolCraft keys would sit under the 26.3 layout (read, for the record; not adopted).**

| CobolCraft key | In the 26.3 layout |
|---|---|
| `Seed` | `data/minecraft/world_gen_settings.dat`, `data.seed` (the `WorldOptions` key is `seed`; type Long (inferred, the field is a `long`)). The same compound also has `generate_structures`, `bonus_chest` and `dimensions` (the dimension generator settings). |
| `WorldType` | No counterpart. The artifact has no world-type notion in `level.dat`. |
| `ContentJar` | No counterpart. |
| `LevelName`, `Time` (game time), `spawn`, `GameType` (Int), `difficulty_settings`, `allowCommands`, `initialized`, `version`, `singleplayer_uuid`, `ServerBrands`, `WasModded`, `removed_features`, `version_history`, `LastPlayed`, and the `DataPacks` and `enabled_features` of the data configuration | Inside `Data` of `level.dat` (the key names above were read from `PrimaryLevelData`; the contents of the compound-valued ones were not read, see Open question 14). |

**Contract adopted for feature 002 (adopted default, not an operator ruling; WT-21).** CobolCraft does **not** adopt the 26.3 tree for `level.dat`. Its contract is
the one of §9.1 to §9.6, with these fixed points:

1. A world is a folder with a `level.dat` (§9.1). `WorldType` is `standard` or `cobolcraft`, or the hidden `debug` (standard content set, `minecraft:overworld` only, test tool; docs/design/debug-world.md).
2. `level.dat` is a flat root compound holding `DataVersion`, `LevelName`, `WorldType`, `Seed`, `ContentJar` (absent for a
   cobolcraft world), `GameMode`, `Time`, `Clocks`, `GameRules`, `Spawn`, `Weather` (§9.2). The three added keys are written
   in the order `WorldType`, `Seed`, `ContentJar` when `level.dat` is first created. Order is a writing convention only.
3. Dimensions live in `dimensions/<namespace>/<path>/` exactly as the artifact lays them out: three folders for a standard world
   (`minecraft/overworld`, `minecraft/the_nether`, `minecraft/the_end`), two for a cobolcraft world.
4. Each dimension folder holds `region/`, `entities/`, `poi/` (standard only) and `data/`.
5. Chunks and entities store block states, biomes, items and entity types **by key**, never by numeric id. A block state in a
   section palette is the key form of §7.3 (the key string for a default state, otherwise a compound with `id` and
   `properties`); the numbered state ids of the wire registry never reach disk (§7.3, world-types §7.5).
6. **Foreign keys (WT-23, adopted default, not an operator ruling).** A chunk whose block or biome palette holds a key that is
   not in the opened world type's registries is **not loaded**: not generated over, not rewritten, the region file stays as
   found, and the server prints one console line `chunk <x> <z> in <dimension> holds content of another world type and was not
   loaded`. The same holds for one unknown entity type in an otherwise valid `entities/` chunk, since rewriting would drop it.
   WT-23 therefore takes precedence over the "skipped on load" rule of §9.3 for an unknown entity id: that skip still applies
   to an invalid compound, but an id missing from the registries fails the whole chunk closed. Whether a key that belongs to
   *neither* world type (a corrupt id) should be treated differently is not decided by WT-23's wording (Open question 15).
7. Existing feature-001 worlds, which have no `WorldType`, open as `cobolcraft` (world-types §2.1; specs/002-client-polish
   data-model §6), unless the folder holds `dimensions/minecraft/` (world-types §2.1 rule 3). The 26.3 migration of `Time`, weather, clocks and game rules out of `level.dat` is **not** performed.

A vanilla server cannot open a folder of the CobolCraft layout; CobolCraft opens and writes back the 26.3 layout of §10, and writes it for new standard worlds.
Everything in the first table that the artifact does and the CobolCraft layout does not is a documented difference of that layout, not a gap.

**Worked examples.**

1. Standard world named `Alpha`, seed 42, created from a jar with SHA-256 `H`. After the first save the folder holds
   `level.dat` (root keys include `DataVersion` 5023, `LevelName` `Alpha`, `WorldType` `standard`, `Seed` 42, `ContentJar` `H`),
   `access.dat`, and `dimensions/minecraft/overworld/region/r.0.0.mca` (and the other region files of loaded chunks). The
   other two dimension folders exist from creation (§9.5); their `region/` files appear when a chunk in them is first saved (inferred).
2. A cobolcraft world has `dimensions/cobolcraft/main/region/r.0.0.mca` and no `poi/` folder; `level.dat` has `WorldType`
   `cobolcraft`, a `Seed`, and no `ContentJar` key.
3. Hand-copy `dimensions/minecraft/overworld/` into a cobolcraft world, renaming it `dimensions/cobolcraft/main/`. The chunks
   have palettes with `minecraft:stone`, which the cobolcraft registry lacks. Result: every such chunk is reported with the
   console line of rule 6 and is not loaded; the files are unchanged afterwards.
4. A folder with `dimensions/minecraft/overworld/region/` but no `level.dat` is not a world (§9.1): the world list does not
   offer it as playable (Play is disabled) and the dedicated server refuses to use it (exit code 10, world-types §2.1, WT-24).

---

## 10. The vanilla 26.3 world folder as the game writes it

Source artifact: `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in README), data version 5023. Method: static reading of the shipped bytecode (`javap`), with no execution. Classes read: `PrimaryLevelData`, `LevelStorageSource` and its `LevelStorageAccess`, `LevelResource`, `LevelVersion`, `LevelSettings`, `LevelData$RespawnData`, `WorldDataConfiguration`, `SavedDataStorage`, `SavedDataType` and the saved-data classes named in §10.4, `PlayerDataStorage`, `SectionStorage`, `PoiSection$Packed`, `PoiRecord$Packed`, `EntityStorage`, `DimensionType.getStorageFolder`, `GameRules`, `ItemStack`, and the file fixers under `net.minecraft.util.filefix`.

Purpose: this section is the reference for a reader or writer that must open a real vanilla 26.3 save and save it back without losing data. §9 stays the description of CobolCraft's own folder; where a CobolCraft file shares a name with a vanilla file (`level.dat`, `players/`, region folders), only §9 applies to a CobolCraft world and only §10 to a vanilla one. All NBT is read and written as the gzip-wrapped, named-root form of §3 and §5 (`NbtIo.readCompressed`, `NbtIo.writeCompressed`) unless a row says otherwise. "Byte" for a boolean means a Byte tag with 0 or 1 (`NbtOps.createBoolean` writes a Byte tag).

### 10.1 Folder layout

```text
<world>/
  level.dat                      root {Data: {...}}                 (§10.2)
  level.dat_old                  previous level.dat                 (§10.2)
  session.lock, icon.png         not NBT; ignore
  datapacks/, resourcepacks/resources.zip, generated/<ns>/structure/   not traced further
  data/<ns>/<id>.dat             server-wide saved data             (§10.3, §10.4)
  data/<ns>/maps/<n>.dat, data/minecraft/maps/last_id.dat            map items and their counter (names only)
  players/data/<uuid>.dat        player entity compounds            (§10.5)
  players/advancements/<uuid>.json, players/stats/<uuid>.json        45-3 sections 8 and 9
  dimensions/<ns>/<path>/
      region/ entities/ poi/     Anvil region folders               (§10.6, §6)
      data/<ns>/<id>.dat         per-dimension saved data           (§10.3, §10.4)
```

The fixed names are the constants of `LevelResource` (`players/data`, `players/stats`, `players/advancements`, `level.dat`, `level.dat_old`, `icon.png`, `session.lock`, `generated`, `datapacks`, `resourcepacks/resources.zip`, `data`) and `DimensionType.getStorageFolder`, which returns `<world>/dimensions/<namespace>/<path>` for a dimension key. The overworld is `dimensions/minecraft/overworld`, the nether `dimensions/minecraft/the_nether`, the end `dimensions/minecraft/the_end`. There is no `DIM-1`, `DIM1` or root-level `region/` in this layout; those names exist only as inputs of the migration of §10.7.

### 10.2 `level.dat`

**Container.** Gzip, named root with an empty name, one root key: `Data` (Compound). Nothing else is written at the root (`LevelStorageAccess.saveDataTag` builds a fresh root, puts the compound under `Data`). `DataVersion` is inside `Data`, not at the root. The write is atomic: a temporary file `level*.dat` in the world folder is written, then `Util.safeReplaceFile` makes the old `level.dat` the new `level.dat_old` and the temporary file the new `level.dat` (same step sequence as 45-3 §1.2). Reading uses `NbtAccounter.uncompressedQuota` (§4). A missing `Data` key reads as an empty compound, so every key below falls back to its default.

**Keys written by `PrimaryLevelData.setTagData`, in write order.** All keys are children of `Data`.

| Key | NBT type | Written | Read default / rule |
|---|---|---|---|
| `ServerBrands` | List of String | always (may be empty) | strings that fail to read are skipped; set semantics, insertion order kept (a linked set) |
| `WasModded` | Byte | always | 0 |
| `removed_features` | List of String | only when the set is non-empty | empty set |
| `Version` | Compound | always | see below |
| `version_history` | List of Int | always | empty list |
| `DataVersion` | Int | always | -1 when missing (`NbtUtils.getDataVersion`) |
| `GameType` | Int | always | 0 (survival); id out of range reads as 0 (`ByIdMap` ZERO strategy). 0 survival, 1 creative, 2 adventure, 3 spectator |
| `spawn` | Compound | always | whole compound missing or invalid: overworld, (0,0,0), yaw 0, pitch 0 |
| `Time` | Long | always | 0. This is the game time (ticks since world creation), not the time of day |
| `LastPlayed` | Long | always (`Util.getEpochMillis` at save) | 0 |
| `LevelName` | String | always | empty string |
| `version` | Int | always, constant 19133 | 0; see rule below |
| `allowCommands` | Byte | always | true when `GameType` is creative, else false |
| `initialized` | Byte | always | true |
| `difficulty_settings` | Compound | always | see below; invalid or missing: normal, not hardcore, not locked |
| `singleplayer_uuid` | Int Array [4] | only when a single-player owner UUID is known | absent: null |
| `DataPacks` | Compound | always (merged from `WorldDataConfiguration.MAP_CODEC`) | see below |
| `enabled_features` | List of String | always (same codec) | the vanilla-only set |

`Version` (written by `writeVersionTag`, read only by `LevelVersion.parse`): `Name` String (game version name), `Id` Int (the data version of the saving game), `Snapshot` Byte (1 when the build is not a stable release), `Series` String. Read defaults: `Name` current version name, `Id` current data version, `Series` `main`, `Snapshot` per the current build. The whole key missing: the summary uses version id 0 and unknown name.

`version_history`: the previous list plus the current data version appended when the last entry is not already the current data version.

`spawn` (`LevelData$RespawnData.CODEC`, a map codec used as a field): `dimension` String (dimension key, `minecraft:overworld`), `pos` Int Array [x, y, z] (`BlockPos.CODEC`, an int stream of exactly 3), `yaw` Float in [-180, 180], `pitch` Float in [-90, 90]. All four required; any failure makes the whole `spawn` fall back to the default above.

`difficulty_settings` (`LevelSettings$DifficultySettings.CODEC`): `difficulty` String (`peaceful`, `easy`, `normal`, `hard`), `hardcore` Byte, `locked` Byte. All three required (the codec has no optional members, so a missing member invalidates the compound and the default applies).

`DataPacks` and `enabled_features`: `DataPacks` is `{Enabled: List of String, Disabled: List of String}`, default Enabled `["vanilla"]`, Disabled `[]`. `enabled_features` is a List of String holding feature-flag ids (the registered vanilla flags are `vanilla`, `trade_rebalance`, `redstone_experiments`, `minecart_improvements`; the string form is the namespaced identifier, for example `minecraft:vanilla` (inferred from the identifier codec of the flag registry)). Both members are lenient optional: an invalid value reads as the default (`WorldDataConfiguration.MAP_CODEC`).

**Required to read.** Nothing is individually required, but `version` must be 19133 (or 19132, which the dedicated server refuses with "must be opened in an older version ... to be safely converted"); any other value makes the level summary fail with an `NbtFormatException` ("Unknown data version"). Opening also checks `Version.Series` against the game's series (`DataVersion.isCompatible`: equal series strings); a mismatch is "created by an incompatible version" and the dedicated server stops.

**What is not in `level.dat` any more.** The pre-5023 keys `Player`, `WorldGenSettings`, `DayTime`, `Raining`, `rainTime`, `thundering`, `thunderTime`, `clearWeatherTime`, `BorderCenterX`/`BorderSize`/..., `GameRules`, `CustomBossEvents`, `ScheduledEvents`, `DragonFight`, `WanderingTraderSpawn*`, `SpawnX/Y/Z/Angle`, `Difficulty`, `hardcore` and similar are gone; their data live in the saved-data files of §10.4. `level.dat` is rebuilt from the loaded fields at every save: a key of `Data` that the game does not model is not written back by `saveDataTag` (it is kept only by the paths that edit the compound in place, such as renaming the world).

### 10.3 Saved-data files (`data/<namespace>/<id>.dat`)

`SavedDataStorage` stores one file per saved-data type. The type id is a namespaced identifier; the file is `<dataFolder>/<namespace>/<path>.dat` (an id path may contain `/`, as `maps/last_id`). All 26.3 vanilla ids use the namespace `minecraft`.

| Item | Rule |
|---|---|
| Root | Compound with exactly `data` (the payload; any tag form the type's codec accepts, almost always a Compound) and `DataVersion` (Int, the saving game's data version). Written by `SavedDataStorage.encodeUnchecked` and `LevelStorageSource.writeSavedData`. |
| Framing | Gzip NBT on write. On read `SavedDataStorage.readTagFromDisk` peeks the first two bytes: gzip magic reads as gzip, anything else as raw uncompressed NBT. The server-wide `world_gen_settings` and `game_rules` readers in `LevelStorageSource` accept gzip only. |
| `DataVersion` missing | read as 1343, then the data fixer for the type runs from that version to 5023 (`DataFixTypes.SAVED_DATA_*`). |
| File missing | not an error: `computeIfAbsent` creates the type's default object (its constructor), `get` returns nothing. |
| Parse failure | logged "Failed to parse saved data"; the codec's partial result is used when it has one, otherwise the default object is created. A damaged file is not renamed or deleted. |
| Write | Only objects marked dirty are written, on the periodic and shutdown save, each with `NbtIo.writeCompressed` straight to the final name (no `.dat_old`, no temporary file for these files). |

Which storage a type uses (read from the call sites):

| Storage | Folder | Types |
|---|---|---|
| Server-wide (`MinecraftServer.getDataStorage`) | `<world>/data/` | `world_gen_settings`, `random_sequences`, `weather`, `game_rules`, `world_clocks`, `custom_boss_events`, `scheduled_events`, `scoreboard`, `stopwatches`, `wandering_trader`, `maps/last_id`, `maps/<n>`, and command storage (`<ns>/command_storage`) |
| Per dimension (`ServerChunkCache.getDataStorage`, created by `ServerLevel`) | `<world>/dimensions/<ns>/<path>/data/` | `chunk_tickets`, `raids`, `ender_dragon_fight` (read by the end dimension's level), `world_border` |

So the vanilla file list is, with `<d>` standing for `dimensions/<ns>/<path>`:

| File | Content |
|---|---|
| `data/minecraft/weather.dat` | §10.4.1 |
| `data/minecraft/world_clocks.dat` | §10.4.2 |
| `data/minecraft/game_rules.dat` | §10.4.3 |
| `data/minecraft/world_gen_settings.dat` | §10.4.5 |
| `data/minecraft/wandering_trader.dat` | §10.4.6 |
| `data/minecraft/scheduled_events.dat` | §10.4.7 |
| `data/minecraft/custom_boss_events.dat` | §10.4.8 |
| `data/minecraft/random_sequences.dat`, `scoreboard.dat`, `stopwatches.dat` | present; contents not traced (Open question 20) |
| `data/minecraft/maps/last_id.dat`, `data/minecraft/maps/<n>.dat` | map counter and map items; contents not traced beyond the key names `dimension`, `xCenter`, `zCenter`, `scale`, `colors`, `trackingPosition`, `unlimitedTracking`, `locked`, `banners`, `frames` |
| `data/<ns>/command_storage.dat` | `/data storage` containers, one file per namespace; contents not traced |
| `<d>/data/minecraft/world_border.dat` | §10.4.4, one per dimension |
| `<d>/data/minecraft/raids.dat` | §10.4.9, one per dimension |
| `<d>/data/minecraft/chunk_tickets.dat` | §10.4.11 |
| `dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat` | §10.4.10 |

### 10.4 File schemas

Booleans are Byte tags. "Req" means a missing member fails the whole codec (the file then loads as the default object, §10.3). "Opt(x)" means optional with default x. Members are listed in codec order, which is the write order.

#### 10.4.1 `weather.dat` (`WeatherData.CODEC`)

| Member | NBT | Req/Opt |
|---|---|---|
| `clear_weather_time` | Int | Req |
| `rain_time` | Int | Req |
| `thunder_time` | Int | Req |
| `raining` | Byte | Req |
| `thundering` | Byte | Req |

A missing file or a missing member gives the default object: all Ints 0 and both booleans false (the no-argument constructor leaves the fields at their Java defaults).

#### 10.4.2 `world_clocks.dat` (`ServerClockManager.TYPE`, `PackedClockStates.CODEC`)

`data` is a Compound whose keys are world-clock ids (strings, for example `minecraft:overworld`, `minecraft:the_end`; the two vanilla clocks of `WorldClocks`) and whose values are:

| Member | NBT | Req/Opt |
|---|---|---|
| `total_ticks` | Long | Req, no range check read (the clock's tick count; the overworld day time is this value for the overworld clock (inferred from the migration of §10.7, which creates this file from the old `DayTime`)) |
| `partial_tick` | Float | Opt(0.0), no range check read |
| `rate` | Float | Opt(1.0); must be positive (`ExtraCodecs.POSITIVE_FLOAT`): 0 or a negative value fails that clock entry |
| `paused` | Byte | Opt(false) |

The default object has no entries (`PackedClockStates.EMPTY`). Which clocks the writer lists when the manager holds more or fewer clocks than the file has was not traced (Open question 21).

#### 10.4.3 `game_rules.dat` (`GameRuleMap.CODEC`, `GameRules` static registrations)

`data` is a Compound mapping a rule id to a value. The key is the full registry id **with namespace**, for example `minecraft:advance_time` (the codec is `Registry.byNameCodec` keys of the game-rule registry; every rule is registered by `Registry.register(registry, String, ...)`, which puts it in `minecraft`). The old camel-case names (`doDaylightCycle` and so on) are not valid keys; the data fixer for `SAVED_DATA_GAME_RULES` renames them. Value tag by rule type (`GameRuleType`): BOOL rules are a Byte, INT rules are an Int that must lie in the rule's range (an out-of-range value fails that entry). There are 59 rules, 47 boolean and 12 integer:

| Rule id (all prefixed `minecraft:`) | Type | Default |
|---|---|---|
| `advance_time`, `advance_weather` | Bool | true (false only when the debug-world-recreate constant is set) |
| `allow_entering_nether_using_portals`, `block_drops`, `block_explosion_drop_decay`, `command_blocks_work`, `command_block_output`, `drowning_damage`, `elytra_movement_check`, `ender_pearls_vanish_on_death`, `entity_drops`, `fall_damage`, `fire_damage`, `forgive_dead_players`, `freeze_damage`, `global_sound_events`, `locator_bar`, `log_admin_commands`, `mob_drops`, `mob_explosion_drop_decay`, `mob_griefing`, `natural_health_regeneration`, `player_movement_check`, `projectiles_can_break_blocks`, `pvp`, `raids`, `send_command_feedback`, `show_advancement_messages`, `show_death_messages`, `spawner_blocks_work`, `spawn_mobs`, `spawn_monsters`, `spawn_patrols`, `spawn_phantoms`, `spawn_wandering_traders`, `spawn_wardens`, `spectators_generate_chunks`, `spread_vines`, `tnt_explodes`, `water_source_conversion` | Bool | true |
| `immediate_respawn`, `keep_inventory`, `lava_source_conversion`, `limited_crafting`, `reduced_debug_info`, `tnt_explosion_drop_decay`, `universal_anger` | Bool | false |
| `fire_spread_radius_around_player` | Int | 128, range -1 to 2147483647 |
| `max_block_modifications` | Int | 32768, range 1 to 2147483647 |
| `max_command_forks`, `max_command_sequence_length` | Int | 65536, range 0 to 2147483647 |
| `max_entity_cramming` | Int | 24, range 0 to 2147483647 |
| `max_minecart_speed` | Int | 8, range 1 to 1000; only exists when feature flag `minecart_improvements` is enabled |
| `max_snow_accumulation_height` | Int | 1, range 0 to 8 |
| `players_nether_portal_creative_delay` | Int | 0, range 0 to 2147483647 |
| `players_nether_portal_default_delay` | Int | 80, range 0 to 2147483647 |
| `players_sleeping_percentage` | Int | 100, range 0 to 2147483647 |
| `random_tick_speed` | Int | 3, range 0 to 2147483647 |
| `respawn_radius` | Int | 10, range 0 to 2147483647 |

A rule absent from the file takes its default (the game builds its rule set from all registered rules and overlays the stored map (inferred)). How an unknown key (a rule of a later version or a mod) is treated by the dispatched-map decoder was not traced (Open question 22); a conservative reader keeps unknown keys verbatim.

#### 10.4.4 `world_border.dat` (`WorldBorder$Settings.CODEC`)

One file per dimension. All members Req:

| Member | NBT | Default of a new border | Constraint |
|---|---|---|---|
| `center_x` | Double | 0.0 | range -29999984.0 to 29999984.0 |
| `center_z` | Double | 0.0 | same |
| `damage_per_block` | Double | 0.2 | none |
| `safe_zone` | Double | 5.0 | none |
| `warning_blocks` | Int | 5 | none |
| `warning_time` | Int | 300 | none |
| `size` | Double | 59999968.0 | none |
| `lerp_time` | Long | 0 | remaining ticks of a size change |
| `lerp_target` | Double | 0.0 | target size of the change |

A missing file gives these defaults (`WorldBorder$Settings.DEFAULT`). The migration of §10.7 writes the overworld file from the old border keys and the nether file with the centre divided by 8 (inferred from the constant 8.0 in `LevelDatToSavedDataFileFix`; the exact input keys were not traced).

#### 10.4.5 `world_gen_settings.dat` (`WorldGenSettings.CODEC`)

`data` is a Compound whose members are the world options merged with the dimensions:

| Member | NBT | Req/Opt |
|---|---|---|
| `seed` | Long | Req |
| `generate_structures` | Byte | Opt(true), always written |
| `bonus_chest` | Byte | Opt(false), always written |
| `legacy_custom_options` | String | lenient optional, written only when present |
| `dimensions` | Compound | Req (`WorldDimensions.CODEC`) |

`dimensions` maps a dimension (level-stem) id string to `{type, generator}` (`LevelStem.CODEC`, both Req): `type` is a dimension-type reference (id string such as `minecraft:overworld`, or an inline definition); `generator` is a Compound with a `type` String (`minecraft:noise`, `minecraft:flat` or `minecraft:debug`, the keys of `ChunkGenerators`) and the generator's own members at the same level (inferred from the dispatched map codec): `noise` has `biome_source` (a Compound with its own `type`) and `settings` (noise-settings id string or inline Compound); `flat` has `settings` with `layers` (the only required member), `structure_overrides` and `biome` (lenient optional, no default; an unknown biome logs "Unknown biome, defaulting to plains" instead of failing), and `lakes` and `features` (always-present optional members, always written; their defaults were not read, Open question 31); `debug` has none. The overworld stem must be present ("Overworld settings missing" otherwise). A reader that does not generate terrain from these should keep the `dimensions` compound verbatim. The standard stems are `minecraft:overworld`, `minecraft:the_nether`, `minecraft:the_end`. When the file cannot be read the game logs "Unable to read or access the world gen settings file" and falls back to default settings **with a random seed**, so the file must be preserved.

#### 10.4.6 `wandering_trader.dat` (`WanderingTraderData.CODEC`)

`spawn_delay` Int, Opt(24000); `spawn_chance` Int, Opt(25). Missing file: these defaults.

#### 10.4.7 `scheduled_events.dat` (`TimerQueue$Packed.CODEC`)

`events`: List of Compound (Req). Each event: `trigger_time` Long (Req), `id` String (Req, the event name), `callback` Compound (Req) whose `type` key (inferred, from the dispatched codec of `TimerCallbacks`) selects `function` (member `id`, a function identifier) or `function_tag` (member `id`, a tag identifier; the written id has no `#`, inferred).

#### 10.4.8 `custom_boss_events.dat` (`CustomBossEvents.CODEC`, `CustomBossEvent$Packed.CODEC`)

`data` is a Compound mapping a bar id (identifier string) to a Compound: `Name` (text component, Req), `Visible` Byte Opt(false), `Value` Int Opt(0), `Max` Int Opt(100), `Color` String Opt(`white`; accepted `pink`, `blue`, `red`, `green`, `yellow`, `purple`, `white`), `Overlay` String Opt(`progress`; accepted `progress`, `notched_6`, `notched_10`, `notched_12`, `notched_20`), `DarkenScreen` Byte Opt(false), `PlayBossMusic` Byte Opt(false), `CreateWorldFog` Byte Opt(false), `Players` List of Int Array [4] (UUIDs) Opt(empty).

#### 10.4.9 `raids.dat` (`Raids.CODEC`), per dimension

`raids` List of Compound Opt(empty); `next_id` Int Req; `tick` Int Req. Each raid (`Raid.MAP_CODEC` plus `id`): `id` Int, `started` Byte, `active` Byte, `ticks_active` Long, `raid_omen_level` Int, `groups_spawned` Int, `cooldown_ticks` Int, `post_raid_ticks` Int, `total_health` Float, `group_count` Int, `status` String (`ongoing`, `victory`, `loss`, `stopped`), `center` Int Array [3], `heroes_of_the_village` List of Int Array [4]. All read as Req by the codec (none uses an optional wrapper in the part read).

#### 10.4.10 `ender_dragon_fight.dat` (`EnderDragonFight` codec), end dimension only

| Member | NBT | Kind, default | Written |
|---|---|---|---|
| `needs_state_scanning` | Byte | always-present optional, true | always |
| `dragon_killed` | Byte | always-present optional, false | always |
| `previously_killed` | Byte | always-present optional, false | always |
| `respawn_stage` | String | plain optional, absent | when set; values `start`, `preparing_to_summon_pillars`, `summoning_pillars`, `summoning_dragon`, `end` |
| `respawn_time` | Int | always-present optional, 0 | always |
| `dragon_uuid` | Int Array [4] | lenient optional, absent | when known |
| `exit_portal_location` | Int Array [3] | lenient optional, absent | when known |
| `gateways` | List of Int | lenient optional, empty list | see write rule |
| `respawn_crystals` | List of entity references (UUID form) | plain optional, empty list | see write rule |

Four members are always written: the three Bytes and `respawn_time` (the always-present helper `ExtraCodecs.optionalAlwaysPresentFieldOf` was read). For the other optionals the codec uses DFU's `optionalFieldOf` or `lenientOptionalFieldOf`; that these omit a member equal to its default is DFU behaviour (recalled, not verified; Open question 29), so a reader must accept both presence and absence of them.

#### 10.4.11 `chunk_tickets.dat` (`TicketStorage.CODEC`), per dimension

`tickets`: List of Compound, plain optional (default empty list (inferred)). Each entry merges the chunk position with the ticket members at one level (pair codec; flattening inferred): `chunk_pos` Int Array [x, z] (Req); `type` String (Req; the registered ticket type names are `player_spawn`, `spawn_search`, `dragon`, `player_loading`, `player_simulation`, `forced`, `portal`, `ender_pearl`, `unknown`, written with the `minecraft:` namespace (inferred)); `level` Int (Req, non-negative, `ExtraCodecs.NON_NEGATIVE_INT`); `ticks_left` Long, Opt(0). Forced chunks use the `forced` type. Which types are persisted (some may be transient) was not traced (Open question 30).

### 10.5 Player files

All paths are relative to the world folder; the file semantics (temporary file, `.dat_old`, `_corrupted_` copy, load order, first join) are 45-3 §1. This section adds what that document leaves implicit.

| Item | Rule |
|---|---|
| Path | `players/data/<uuid>.dat`, `<uuid>` the hyphenated lower-case string of `Player.getStringUUID` (45-3 §1.1). |
| Online-mode server | the Mojang account UUID of the profile. |
| Offline-mode server | the UUID is the name-based (version 3) UUID of the UTF-8 bytes of `OfflinePlayer:<name>` (`UUIDUtil.createOfflinePlayerUUID`, `UUID.nameUUIDFromBytes`). The name case is preserved as typed. |
| Single-player (integrated) owner | `isSingleplayerOwner` is true for the integrated server when the name equals (ignoring case) the single-player profile name, and `PlayerList` then loads the file named by `level.dat` `singleplayer_uuid` (45-3 §1.5). The dedicated server always answers false, so it never uses `singleplayer_uuid`; it preserves the key if present. |
| Root | the compound of `Player.saveWithoutId`; no `id` key at the root; `DataVersion` Int is written by `Player.addAdditionalSaveData` and read with default -1 before `DataFixTypes.PLAYER` runs. Key tables: 45-3 §2 and §3. |
| Item stack | `{id: String (item id with namespace, for example `minecraft:snowball`; the codec is the item registry's by-name codec, so an id is always written with its namespace), count: Int in 1 to 99 (default 1, **always written**, never omitted), components: Compound (omitted when the patch is empty)}`; inventory and `EnderItems` elements add `Slot` Byte (45-3 §4.1). |
| Equipment | `equipment` Compound with slot-name keys and bare item stacks (no `Slot`) (45-3 §4.3). |
| Ender chest | `EnderItems`, List of slot elements, 27 slots (45-3 §5). |
| Other per-player files | `players/advancements/<uuid>.json` and `players/stats/<uuid>.json` (45-3 §8, §9); same UUID rule. |

### 10.6 Dimension folder contents

`<d>/region/r.<x>.<z>.mca` holds chunk payloads (§7), `<d>/entities/r.<x>.<z>.mca` entity payloads and `<d>/poi/r.<x>.<z>.mca` point-of-interest payloads, all in the container of §6; `<d>/data/` holds the per-dimension saved data of §10.3. When a chunk's entity list is empty the game does not write a payload with an empty `Entities` list; it writes through its "store empty" supplier (`IOWorker.STORE_EMPTY`), an empty entry (inferred).

**`entities/` payload** (`EntityStorage`): `DataVersion` Int; `Position` Int Array [chunkX, chunkZ] (`ChunkPos.CODEC`, a 2-element int stream); `Entities` List of Compound. Each entity compound carries `id` String (namespaced entity-type id) and the keys of 45-1 to 45-9, with `Pos`, `UUID`, `Passengers` and the rest of the entity layer. A `Position` that does not equal the file slot's chunk is logged as "in the wrong location" (07 §8; what is then done with the payload was not traced).

**`poi/` payload** (`SectionStorage`, `PoiSection$Packed`, `PoiRecord$Packed`): `DataVersion` Int; `Sections` Compound whose keys are the decimal section Y strings (for example `"4"`, `"-1"`), limited on read to the dimension's minimum and maximum section Y (the bounds come from the dimension's height, not from the file). A section key appears only when the section object packs to a value. Each value is a Compound:

| Member | NBT | Req/Opt |
|---|---|---|
| `Valid` | Byte | lenient optional, default 0 (false) |
| `Records` | List of Compound | Req |

Each record: `pos` Int Array [x, y, z] (absolute block position, Req), `type` String (point-of-interest type id with namespace such as `minecraft:home`, Req; a registry holder, so an inline definition is also accepted), `free_tickets` Int, Opt(0). A section whose `Valid` is false is rescanned from the chunk when next needed, so a reader that does not keep POI may drop the `poi/` folder without losing player-visible data (inferred from the flag name; the rescan code was not read).

**`block_entities`** in a chunk payload (§7 `block_entities`): each entry holds `id` String (namespaced type), `x`, `y`, `z` Int (absolute coordinates), `components` Compound (always present, empty compound when no component data (inferred)), the type's own keys (31-2 to 31-8), and `keepPacked` Byte (0 for a live entity, 1 for one the game could not instantiate; 31-1 §6). A reader that cannot interpret a type keeps the compound verbatim and sets nothing else.

### 10.7 What the game does at load, and what must survive a round trip

1. **Data version.** The game reads `Data.DataVersion` of `level.dat` (default -1) and runs the data fixers for the level type up to 5023. The codecs read here do not reject a **newer** data version than 5023. The series check of §10.2 and the version recorded in `Version` drive the downgrade warning (`LevelSummary.backupStatus`, not read in full; Open question 23). Every payload (chunk, entity, POI, saved data, player) carries its own `DataVersion`; the fixers run per payload from that payload's own value.
2. **File fixer.** Before any of this, `FileFixerUpper.requiresFileFixing` compares the level's data version (values below 4772 count as 0) with the newest registered file fix. The file fixes are registered at data versions 1493 (legacy structures), 4772 (resource-pack location `resources.zip` to `resourcepacks/resources.zip`; dimension storage; `playerdata`, `stats`, `advancements` to `players/data`, `players/stats`, `players/advancements`; `level.dat` content to the saved-data files; obsolete files removed), 4773 (`generated/<ns>/structures` to `structure`) and 4899 (spectators-generate-chunks re-enabled in hardcore worlds). A world whose `level.dat` data version is at or above 4899 already has the layout of §10.1 to §10.6 (4899 is the newest registered fix, read in `DataFixers`); an older world is rewritten on disk by the game (the dedicated server `Main` calls the fixer at start-up and the fixer logs "Starting upgrade for world"; whether it asks for confirmation was not read). The dimension fix moves `DIM-1` and `DIM1` into `dimensions/minecraft/the_nether` and `the_end`, root `region`, `entities` and `poi` into the overworld folder, and `data/<name>.dat` files (`raids`, `raids_end`, `chunks`, `world_border`, `idcounts`, `map_<n>`, `random_sequences`, `scoreboard`, `stopwatches`, `command_storage_<ns>`) into the `data/minecraft/...` names of §10.3. CobolCraft can therefore accept a vanilla world only at data version 4899 or later without implementing these migrations (inferred policy, not a game rule).
3. **Unknown keys.** Codec-based files ignore members they do not know (a record codec reads only its own members) and the game does not write them back, so a loaded and re-saved vanilla file loses unknown members. `level.dat` is rebuilt from fields (§10.2). For the lossless round trip this section's reader asked for, a CobolCraft implementation must keep and rewrite: the whole `Data` compound including unknown children, `ServerBrands` (adding its own brand is what `setModdedInfo` does), `version_history` (append the saving data version only when it differs from the last entry), `Version` (rewrite with the writer's name, id, series), `DataVersion` (the writer's own; a writer that saves entities, chunks or block entities it did not interpret must keep each payload's original `DataVersion` next to it, since the payload is only valid for that version), every saved-data file it does not interpret (byte-for-byte, including its own `DataVersion`), all `block_entities` compounds it cannot interpret with `keepPacked` unchanged, `Entities` compounds it cannot interpret, and the `poi/` and `entities/` folders as a whole. Chunk, entity and POI payloads are read and written under §6 and §7.
4. **Missing optional files** are never errors: absent saved-data files mean defaults (§10.3), absent `players/data/<uuid>.dat` is a first join (45-3 §1.6), absent `poi/` or `entities/` region files mean no POIs and no entities in those chunks (the chunk files alone define the terrain), absent `level.dat` is not a world, and an unreadable `level.dat` (read exception or NBT format error) falls back to `level.dat_old`; the game then restores the old file as `level.dat` and moves the bad file to a timestamped corrupted-copy name (`LevelDirectory.corruptedDataFile`, `Util.safeReplaceOrMoveFile`; the exact name was not read).
5. **Integer, Byte and boolean tolerance.** Writers always use Byte for booleans, Int for the Ints above and Long for `Time`, `LastPlayed`, `seed`, `trigger_time`, `ticks_active`, `total_ticks`, `lerp_time`. The `...Or` accessors and the DFU primitive codecs accept any numeric tag where a number is expected (inferred from `NbtOps` conventions; not traced), so a reader should accept Byte, Short, Int, Long, Float or Double for a numeric member and write the canonical type.

**Worked examples.**

1. Minimal `level.dat` of a fresh survival world named `Alpha`, written by the 26.3 dedicated server: root `{Data: {ServerBrands: ["vanilla"], WasModded: 0b, Version: {Name: "26.3", Id: 5023, Snapshot: 0b, Series: "main"}, version_history: [5023], DataVersion: 5023, GameType: 0, spawn: {dimension: "minecraft:overworld", pos: [I; 0, 64, 0], yaw: 0.0f, pitch: 0.0f}, Time: 0L, LastPlayed: <epoch ms>L, LevelName: "Alpha", version: 19133, allowCommands: 0b, initialized: 1b, difficulty_settings: {difficulty: "normal", hardcore: 0b, locked: 0b}, DataPacks: {Enabled: ["vanilla"], Disabled: []}, enabled_features: ["minecraft:vanilla"]}}`. The example values `64` (the rule that picks a new world's spawn Y was not traced), `"vanilla"` (the brand a dedicated server writes in `ServerBrands` was not read), `"26.3"` and the namespaced feature string are illustrative (inferred), not read constants. `removed_features` and `singleplayer_uuid` are absent.
2. `data/minecraft/weather.dat` for clear weather, 12000 ticks until the next change: `{data: {clear_weather_time: 12000, rain_time: 0, thunder_time: 0, raining: 0b, thundering: 0b}, DataVersion: 5023}` (12000 is illustrative).
3. `data/minecraft/game_rules.dat` with keep-inventory on: `{data: {"minecraft:keep_inventory": 1b}, DataVersion: 5023}`; every other rule has its default.
4. Offline-mode server, player `Steve`: the file is `players/data/<uuid>.dat` with `<uuid>` the version-3 UUID of the bytes `OfflinePlayer:Steve`.

---

### 10.8 What CobolCraft writes in this layout (CobolCraft's own choices, not read from the artifact)

A standard world made by CobolCraft, and any folder opened in this layout, is saved as follows. These are design choices of the vanfmt lane (operator rule: the standard type uses the game's own layout, §9 intro); where a value was never read from the artifact it is the least surprising one.

| Item | Rule |
|---|---|
| New standard world | Created in this layout. `level.dat` gets `LevelName`, `GameType`, `spawn`, `Time`, `DataVersion` 5023, `LastPlayed` and the defaults `ServerBrands` (empty list), `WasModded` 0, `Version` (`Name` "26.3", `Id` 5023, `Snapshot` 0, `Series` "main": the name and series are not read from this artifact's runtime, only from its `version.json`), `version_history` [5023], `version` 19133, `allowCommands` (1 in creative), `initialized` 1, `difficulty_settings` (normal, not hardcore, not locked), `DataPacks` (Enabled ["vanilla"], Disabled []) and `enabled_features` ["minecraft:vanilla"] (the namespaced form is inferred; a real snapshot save was seen without this key). No `WorldType`, no `ContentJar`: the type is standard because `Data` is present (world-types §2.1 rule 3a). |
| Existing folder | `level.dat` is rewritten with the keys CobolCraft owns (`DataVersion`, `GameType`, `spawn`, `Time` = loaded game time + ticks run, `LastPlayed`, `LevelName`) and every other child of `Data` copied unchanged; the old file becomes `level.dat_old`. |
| Saved-data files | `weather.dat`, `world_clocks.dat` (the overworld `total_ticks` is the core's day time on top of the days read; `partial_tick`, `rate`, `paused` and the other clocks are kept), `game_rules.dat` (rules not at their default, with `minecraft:`; unknown rules kept) and `world_gen_settings.dat` (`seed`; a new file also gets `generate_structures` true and `bonus_chest` false; the `dimensions` map is **not** written for a new world, so the game itself would refuse such a folder, Open question 32) are written at every save. `world_border.dat`, `raids.dat`, `chunk_tickets.dat`, `scoreboard.dat` and the rest are never touched. |
| Chunks | Saved with the keys CobolCraft models (`DataVersion`, positions, `LastUpdate`, `Status`, `sections` with block states and biomes, `block_entities`, `Heightmaps` of three types, `PostProcessing`); `InhabitedTime`, `structures`, `block_ticks`, `fluid_ticks` and any other key of the chunk as the region file holds it are kept; `isLightOn` is dropped (no light arrays are written). |
| Entities, block entities | A known entity or block entity keeps the keys of its saved compound that the new compound lacks (the whole compound is held in memory up to 2048 bytes; a larger one loses its extra keys). Entities and block entities of types the core does not hold are written back unchanged (at most 256 per chunk). |
| poi | A saved chunk's `poi/` payload is rewritten with every section `Valid` 0 and the records unchanged, so the game rescans the sections from the blocks. |
| Players | `players/data/<offline uuid>.dat`; a file at `players/<uuid>.dat` is still read when the new place has none. |
| Not kept | `access.dat` is still written (CobolCraft's own, ignored by the game); the real lists live in other files this section does not cover. |

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
12. §9.6: the other saved-data files of 33 §10 (`scheduled_events.dat`, `custom_boss_events.dat`, `ender_dragon_fight.dat`; of `world_gen_settings.dat` only `generate_structures`, `bonus_chest` and `dimensions`, the seed being `Seed`) are not
    specified for the CobolCraft folder. 33 Open question 4 (the wrapper keys and the border path) applies to the files that are.
13. §9.2 `access.dat`: the stored form of an operator level, of a ban's time and expiry text, and the absence of IP bans are CobolCraft choices (README
    decision 8); the vanilla list files are not specified (16 §11 intro). The default level a new operator gets was not read (16 §11.1).
14. §9.7: the contents of the compound-valued `level.dat` keys of the 26.3 layout (`spawn`, `difficulty_settings`, `DataPacks`, `enabled_features`, `version`,
    `version_history`) and the exact NBT types of `Seed` in `world_gen_settings.dat` were not traced; they matter only if the 26.3 layout is ever adopted.
15. §9.7 rule 6: WT-23 fails a chunk closed for a key "not in the world type's registries". Whether a key unknown to both types should instead be skipped
    like an invalid entity (§9.3) is a decision for the owners of world-types; until then WT-23 applies as written.
16. Inventory size of `players/<offline-uuid>.dat` (§9.2 `Inventory`): §9.2 stores the 36 storage slots (0 to 35) and writes armor and off-hand through `equipment`, while design README C5 says container 0 is the 46-slot inventory menu. These are consistent only if the 46 counts menu slots (crafting, armor, off-hand) that are not saved as `Inventory`; that reading is (inferred) and is not confirmed by the owners of 45-3 and 13. Also world-types Open question 12.
17. §10.2 `Version` read defaults, and the exact failure when `Version.Series` differs from the game's series: only the call chain was read, not the user-facing flow. The dedicated server stops on "incompatible version" (`LevelSummary.isCompatible`); the downgrade backup flag (`backupStatus`) was not read in full.
18. §10.2: `Data` keys the game does not model are dropped by `saveDataTag`; whether any 26.3 path (a plugin point, `modifyLevelDataWithoutDatafix`) preserves them was only seen for rename and drop-player. A lossless CobolCraft round trip therefore keeps them by its own rule, which is a CobolCraft choice, not game behaviour.
19. §10.2: the constant 19133 is what `LevelStorageSource.getStorageVersion` returns and 19132 is the other accepted value (what each stands for is (recalled, not verified) and not needed here); the refusal text for 19132 comes from the dedicated server `Main`. The write order of `Data` keys is the order in `PrimaryLevelData.setTagData`; compound key order in the file is the order of the in-memory map and was not checked in a real file.
20. §10.3: the payloads of `random_sequences.dat`, `scoreboard.dat`, `stopwatches.dat`, `maps/last_id.dat`, `maps/<n>.dat` (beyond the member names listed) and `<ns>/command_storage.dat` were not traced.
21. §10.4.2: which clock entries are written when a dimension's clock was never touched, and what a missing entry means for the overworld day time (0 or the dimension type's default), were not traced.
22. §10.4.3: the decoder's behaviour for an unknown rule id or a rule gated by a disabled feature flag (`max_minecart_speed`) was not traced; neither was whether the writer lists every rule or only changed ones.
23. §10.7: behaviour for a `level.dat` or saved-data file with a data version newer than 5023 (the game's downgrade warning) was not traced.
24. §10.4.5: the contents of `generator.settings` and `biome_source` are given by the registries and the world-generation documents (10, 35, 37), and the flattening of the dispatched `generator` compound is inferred, not read from a real file.
25. §10.4.7: the `callback` dispatch key name (`type`) and the identifier form of `function_tag` are inferred from the codec structure.
26. §10.6: the rescan behaviour for a POI section with `Valid` false, and the exact conditions under which a `Sections` entry is omitted, were not read.
27. §10.4.4: the nether border centre scaling on migration (division by 8) is inferred from a constant; whether live nether borders are linked to the overworld border at run time was not traced.
28. §10.7 item 5: numeric-tag tolerance on read (accepting Byte, Short, Int, Long, Float or Double for a number) was not traced and is inferred from the data-codec conventions.
29. §10.4.10: whether `optionalFieldOf` / `lenientOptionalFieldOf` omit a member that equals its default on write (DFU behaviour) was not read; the same applies to every plain optional member in §10.4 (`Valid`, `free_tickets`, `spawn_delay`, `ticks_left` and similar).
30. §10.4.11: which ticket types are saved to `chunk_tickets.dat` and which are transient was not traced.
31. §10.4.5: the default values of the flat generator settings members `lakes` and `features` were not read, nor the element form of `layers`.
32. §10.8: a new standard world is written without the `dimensions` map of `world_gen_settings.dat`, which §10.4.5 says the game requires; what the game does with such a file (refuse, or rebuild the default dimensions) was not read. The shape of that map for the default standard dimensions is §10.4.5, but CobolCraft does not yet write it.
