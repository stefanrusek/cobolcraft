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
but its `.dat` schemas are not the vanilla ones, so a vanilla server cannot open it and CobolCraft does not open vanilla saves.
Server worlds and single-player worlds use this one format (FR-004). The folder holds all of a world's dimensions and is
copied as a unit. Everything FR-014 lists as world state is saved here and nowhere else.

### 9.1 Layout

```text
<world>/
  level.dat
  access.dat
  players/<offline-uuid>.dat              one per player who has been in the world
  dimensions/<namespace>/<path>/
    region/r.<rx>.<rz>.mca                chunks (§6 region files, §7 chunk NBT, values in §9.4)
    entities/r.<rx>.<rz>.mca              mobs and ground items (§6 region files, §8, schema in §9.3)
```

| Item | Value |
|---|---|
| `<offline-uuid>` | The offline UUID of 02-handshake-status-login.md "Offline mode", written hyphenated and lower-case |
| `<namespace>/<path>` | The dimension key split at the colon: `cobolcraft/main` for the main dimension ([../design/standin-content.md](../design/standin-content.md) §5.1) and one folder for each extra dimension |
| Region file names | As §6.1, in each dimension's `region/` and `entities/` folders |
| `poi/` | Not written. CobolCraft has no points of interest. |
| `.dat` files | gzip-compressed NBT files (§5.1, `writeCompressed` / `readCompressed`). The root is a Compound in the file framing of §3 (type byte, empty name, payload). The world-folder contract's "unnamed root compound" means this empty name; it is not the network "unnamed root" of §3. |
| `DataVersion` | Every `.dat` root and every region chunk payload carries `DataVersion` (Int) = 5023, the value of §7 |

### 9.2 `.dat` schemas

`level.dat`:

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `LevelName` | String | World name, shown in the single-player world list |
| `GameMode` | Int | The game mode chosen when a single-player world is created. When the world is hosted by the client (core-host-api `CS-HOST-KIND` 1, and 2 for the host) it is the game mode of new players; guests get the guest mode chosen when the world is opened to others. A dedicated server (`CS-HOST-KIND` 0) ignores it and uses its `default-game-mode` setting. |
| `Time` | Long | Time of day in ticks |
| `Spawn` | Compound | `Dimension` (String, dimension key), `X`, `Y`, `Z` (Double), `Yaw` (Float). Changed by command. |
| `Weather` | Compound | One entry per dimension that has weather, named by the dimension key. A dimension without weather (`cobolcraft:subroutine`, standin-content §14.2) has no entry. Each value is a Compound: `Kind` (String, weather kind key) and `Remaining` (Int, ticks left, or −1 meaning "until changed": no countdown, standin-content §14.3). |

Network entity ids are assigned per run and are not stored anywhere in the folder.

`access.dat`:

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `Operators` | List of Compound | Players with operator status |
| `Bans` | List of Compound | Banned players |
| `AllowList` | List of Compound | Allow-listed players |
| `AllowListEnforced` | Byte | 1 if the allow-list is enforced in this world, otherwise 0 |

Each entry of the three lists is an offline identity `{Name: String, UUID: Int Array (4)}`. The UUID is the same offline UUID
as the player file name, stored as four Ints, most significant first (inferred: the vanilla `UUIDUtil` int-array form).

A new world takes `AllowListEnforced` from the `allow-list` configuration setting (dedicated server) or 0 (single-player).
After that, only the allow-list on/off commands change it, and the setting no longer applies to that world. Single-player
worlds behave the same way.

`players/<offline-uuid>.dat`:

| Key | NBT type | Meaning |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `Name` | String | Offline name |
| `Dimension` | String | Dimension key |
| `Pos` | List of 3 Double | Feet position X, Y, Z |
| `Rotation` | List of 2 Float | Yaw, pitch |
| `GameMode` | Int | 0 survival, 1 creative |
| `Health` | Float | Current health |
| `Food` | Int | Food level |
| `Inventory` | List of Compound | One `{Slot: Byte, id: String, count: Int}` per **non-empty** slot. Slots are numbered 0 to 8 (hotbar) and 9 to 35 (main), as in the data model's Inventory. `id` is an item key. |
| `HeldSlot` | Int | Selected hotbar slot, 0 to 8 |

### 9.3 Entity storage (`entities/`)

Each chunk payload is the §8 `entities/` compound, stored as in §6.3 with compression id 2 (zlib, §5.2):

| Key | NBT type | Notes |
|---|---|---|
| `DataVersion` | Int | 5023 |
| `Position` | Int Array (2) | `[chunkX, chunkZ]`. CobolCraft fixes the Int Array form that §8 marks as inferred. |
| `Entities` | List of Compound | One compound per entity in the chunk, as below |

Entity compound:

| Key | NBT type | Applies to | Meaning |
|---|---|---|---|
| `id` | String | all | Entity type key: `cobolcraft:loose_item` for a ground item, or a mob type key of standin-content §3 (as extended) |
| `Pos` | List of 3 Double | all | Position |
| `Motion` | List of 3 Double | all | Velocity |
| `Rotation` | List of 2 Float | all | Yaw, pitch |
| `Health` | Float | mobs | Current health |
| `Item` | Compound | ground items | The stack: `{id: String, count: Int}` |
| `Age` | Int | ground items | Ticks the despawn timer has run. Remaining time = despawn time − `Age`. The timer runs only near players. |

Players are not stored here. They live in `players/` (§9.2).

### 9.4 Chunk storage (`region/`)

Chunk payloads follow §7 as written, with these CobolCraft values:

| Item | Value |
|---|---|
| Compression | Id 2 (zlib, the §5.2 default), as for `entities/` (§9.3) |
| `Status` | `minecraft:full` |
| Block-state palette entries (§7.3) | The block keys and properties of standin-content §1 (as extended) |
| Biome palette entries (§7.3) | The biome keys of standin-content §4.3 (as extended) |
| `block_entities` | No block entities, so the list is empty |
| `LastUpdate` | World time at save: the `level.dat` `Time` value written by the same save (inferred: the world keeps no game-time counter separate from time of day) |

### 9.5 Behaviour

- A world folder without `level.dat` is created new, with all enabled dimensions. Chunks are generated on first use. A
  chunk is saved when it has changed, or when an entity is in it at save time.
- A save writes every changed chunk, every chunk holding entities, the file of every online player and of every player who
  left since the previous save, `level.dat`, and `access.dat`.

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
