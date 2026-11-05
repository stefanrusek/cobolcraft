# 06 — Chunk format (network)

This document covers the inner structure of chunk payloads and light payloads used in the play phase. It also covers the
packets whose main job is to carry them or to address chunks and sections:

| Id (hex / dec) | Packet |
|---|---|
| 0x2E / 46 | Clientbound Level Chunk With Light (`ClientboundLevelChunkWithLightPacket`) |
| 0x31 / 49 | Clientbound Light Update (`ClientboundLightUpdatePacket`) |
| 0x56 / 86 | Clientbound Section Blocks Update (`ClientboundSectionBlocksUpdatePacket`) |
| 0x26 / 38 | Clientbound Forget Level Chunk (`ClientboundForgetLevelChunkPacket`) |

Ids are clientbound play-phase registration indices (see README).

Sources: `ClientboundLevelChunkPacketData`, `ClientboundLevelChunkPacketData$BlockEntityInfo`,
`ClientboundLightUpdatePacketData`, `LevelChunkSection`, `PalettedContainer`, `PalettedContainer$Data`, `Strategy`,
`Strategy$1`, `Strategy$2`, `Configuration$Simple`, `Configuration$Global`, `SingleValuePalette`, `LinearPalette`,
`HashMapPalette`, `GlobalPalette`, `PalettedContainerFactory`, `net.minecraft.util.SimpleBitStorage`, `ZeroBitStorage`,
`DataLayer`, `Heightmap`, `Heightmap$Types`, `LevelLightEngine`, `SectionPos`, `ChunkPos`.

---

## 1. Terminology and geometry

| Term | Meaning |
|---|---|
| Chunk column | A 16 × 16 block column covering the whole height of a dimension. It is addressed by chunk X and chunk Z (block coordinate >> 4). |
| Section | A 16 × 16 × 16 cube inside a column. It is addressed by section Y (block Y >> 4, arithmetic shift). |
| Section count | The number of block sections in the dimension, equal to height / 16. It comes from the dimension type the client already knows from registry sync. It is never sent in the chunk packet. |
| Min section Y | The lowest section Y of the dimension, equal to `min_y >> 4`. |
| Light section range | Light covers one extra section below the lowest block section and one extra above the highest. `LevelLightEngine.getMinLightSection` = min section Y − 1, and `getLightSectionCount` = section count + 2. |

---

## 2. 0x2E / 46 Clientbound Level Chunk With Light (ClientboundLevelChunkWithLightPacket)

| Field | Type | Notes |
|---|---|---|
| Chunk X | Int | Chunk column X. This is a fixed 4-byte big-endian Int, not a VarInt. |
| Chunk Z | Int | Chunk column Z. This is a fixed 4-byte big-endian Int. |
| Chunk data | ChunkData | See §3. |
| Light data | LightData | See §7. |

## 3. ChunkData (`ClientboundLevelChunkPacketData`)

| Field | Type | Notes |
|---|---|---|
| Heightmaps | HeightmapMap | See §3.1. This is a typed map, not NBT. |
| Section buffer | ByteArray(VarInt len) | The maximum length is 2,097,152 bytes (`TWO_MEGABYTES`). The bytes hold every section of the column, serialized back to back from the lowest section Y to the highest (§4). The server checks that the bytes written exactly fill the precomputed size. |
| Block entities | Prefixed Array of BlockEntityEntry | See §3.2. The VarInt count has no explicit maximum. |

### 3.1 HeightmapMap

The map is encoded by `ByteBufCodecs.map` with an `EnumMap` keyed by `Heightmap$Types`.

| Field | Type | Notes |
|---|---|---|
| Count | VarInt | Number of entries. The decoder pre-sizes to at most 65,536, but the count itself has no cap beyond Int. |
| Entries | Count × (Type, Data) | |
| — Type | Enum HeightmapType (VarInt) | Enum ordinal (`ByIdMap.continuous`, out-of-range → ordinal 0). See table below. |
| — Data | Prefixed Array of Long | VarInt count, then that many Longs. On decode the count must be ≤ readable bytes / 8. |

HeightmapType ordinals:

| Ordinal | Name | Sent to client by the server |
|---|---|---|
| 0 | WORLD_SURFACE_WG | no |
| 1 | WORLD_SURFACE | yes |
| 2 | OCEAN_FLOOR_WG | no |
| 3 | OCEAN_FLOOR | no |
| 4 | MOTION_BLOCKING | yes |
| 5 | MOTION_BLOCKING_NO_LEAVES | yes |

The server sends only types whose usage is `CLIENT`, which are ordinals 1, 4 and 5.

Heightmap long array layout (`Heightmap`):
- 256 entries. The entry index for a column at local x, z (0–15) is `x + 16·z`.
- Bits per entry = `ceillog2(dimension height + 1)`. For example, a height of 384 gives 9 bits.
- The stored value is "first available Y minus the dimension's min Y": one above the highest qualifying block, relative to the bottom of the world.
- Packing follows the SimpleBitStorage rules in §6. The long count is therefore `ceil(256 / floor(64 / bits))`. For example, 9 bits gives 7 entries per Long, so 37 Longs.

### 3.2 BlockEntityEntry (`ClientboundLevelChunkPacketData$BlockEntityInfo`)

| Field | Type | Notes |
|---|---|---|
| Packed XZ | Byte | `((blockX & 15) << 4) | (blockZ & 15)`. The high nibble is the section-relative X and the low nibble is the section-relative Z. The decoder recovers X with `packedXZ >> 4` then `& 15`, and Z with `packedXZ & 15`. |
| Y | Short | Absolute world block Y, signed. |
| Type | VarInt | Id in the block entity type registry (`ByteBufCodecs.registry(BLOCK_ENTITY_TYPE)`). |
| Data | OptionalNBT | The block entity's "update tag" compound. An empty compound is sent as absent, which is a single TAG_End byte. See Composite types. |

The absolute block position is `(16·chunkX + x, Y, 16·chunkZ + z)`.

---

## 4. Section (`LevelChunkSection.write`)

The section buffer (§3) contains exactly `section count` of these structures, back to back, ordered by ascending section Y. There
is no count prefix and there are no per-section presence flags.

| Field | Type | Notes |
|---|---|---|
| Non-empty block count | Short | Number of positions in the section whose block state is not air. |
| Fluid count | Short | Number of positions whose block state has a non-empty fluid state. This field is present in this version, between the block count and the block states. |
| Block states | PalettedContainer (block-state strategy) | 4096 entries. Global ids are block state ids (`Block.BLOCK_STATE_REGISTRY`). |
| Biomes | PalettedContainer (biome strategy) | 64 entries, one per 4 × 4 × 4 cell. Global ids index the synchronized biome registry (`Registry.asHolderIdMap()` of `Registries.BIOME`). |

The section's serialized size is 4 + the size of the block-state container + the size of the biome container (`getSerializedSize`).

---

## 5. PalettedContainer (network form)

### 5.1 Wire layout (`PalettedContainer$Data.write` / `PalettedContainer.read`)

| Field | Type | Notes |
|---|---|---|
| Bits per entry | UByte | Written as `storage.getBits()`, the in-memory storage width (§5.3). |
| Palette | depends on kind | See §5.2. The kind is chosen from the bits-per-entry byte and the strategy. |
| Data | N × Long | **No length prefix.** It is read with `readFixedSizeLongArray`. N is implied by the in-memory bits of the selected configuration and the entry count: N = `ceil(entryCount / floor(64 / bits))`, or N = 0 when bits = 0. |

The data array length is **no longer sent**. Earlier protocol versions had a VarInt length prefix before the longs. That prefix is
gone: `Data.write` writes the bits byte, the palette, then `writeFixedSizeLongArray` with no count. `read` fills an array whose size was fixed by the configuration.

### 5.2 Palette kinds

| Kind | Class | Palette wire form | Meaning of each data entry |
|---|---|---|---|
| Single value | `SingleValuePalette` | VarInt: one global id | None. Bits = 0, and the data array is empty (0 Longs). Every entry is this value. |
| Linear (indirect) | `LinearPalette` | VarInt size, then size × VarInt global id | Index into this palette. Capacity is `1 << bits` entries. A larger size fails to decode (inferred: array overflow). |
| Hash map (indirect) | `HashMapPalette` | VarInt size, then size × VarInt global id | Index into this palette. On the wire this is identical to Linear. It differs only internally. |
| Global (direct) | `GlobalPalette` | *Nothing.* The palette writes and reads zero bytes. | The global id itself. |

Global ids that are out of range for the registry are rejected on read (`IdMap.byIdOrThrow`).

### 5.3 Bits-per-entry thresholds (`Strategy$1` blocks, `Strategy$2` biomes)

The receiver maps the bits byte to a configuration with `getConfigurationForBitCount(byte)`. The configuration fixes the palette
kind and the in-memory width used to size and unpack the data array.

Block states (`Strategy.createForBlockStates`: 4 bits per axis, 4096 entries):

| Bits byte received | Palette kind | In-memory bits used to unpack data |
|---|---|---|
| 0 | Single value | 0 |
| 1, 2, 3, 4 | Linear | **4**. Any byte from 1 to 4 decodes as 4-bit data. |
| 5 | Hash map | 5 |
| 6 | Hash map | 6 |
| 7 | Hash map | 7 |
| 8 | Hash map | 8 |
| ≥ 9 | Global | `ceillog2(number of block states)`. The received byte value is otherwise ignored. |

Biomes (`Strategy.createForBiomes`: 2 bits per axis, 64 entries):

| Bits byte received | Palette kind | In-memory bits |
|---|---|---|
| 0 | Single value | 0 |
| 1 | Linear | 1 |
| 2 | Linear | 2 |
| 3 | Linear | 3 |
| ≥ 4 | Global | `ceillog2(biome registry size)`. The received byte value is otherwise ignored. |

For the Global kind, `Configuration$Global` is built as `(globalPaletteBitsInMemory, requestedBits)`. Storage is always
allocated with `globalPaletteBitsInMemory = ceillog2(registry size)`. A sender must therefore pack direct data at exactly
`ceillog2(registry size)` bits. The server itself writes that value as the bits byte. For blocks with 1–4 bits, data must be
packed at 4 bits. The vanilla server only ever writes 0, 4, 5–8, or the global width for blocks, and 0, 1–3, or the global width for biomes.

Palette size to configuration (sender side, `getConfigurationForPaletteSize`): bits = `ceillog2(distinct values)`, then the
table above. One distinct value gives 0 bits, which is single value.

### 5.4 Entry index order (`Strategy.getIndex`)

`index = ((y << b) | z) << b | x`, with b = bits per axis.

| Container | Index |
|---|---|
| Block states (b = 4) | `y·256 + z·16 + x`, where x, y, z are 0–15 within the section |
| Biomes (b = 2) | `y·16 + z·4 + x`, where x, y, z are 0–3 cell coordinates. Each cell is 4 × 4 × 4 blocks (inferred: block coordinate >> 2 within the section). |

So x varies fastest, then z, then y.

### 5.5 Data array sizes (examples)

| Container | Bits | Entries per Long | Longs |
|---|---|---|---|
| Block states | 4 | 16 | 256 |
| Block states | 5 | 12 | 342 |
| Block states | 6 | 10 | 410 |
| Block states | 7 | 9 | 456 |
| Block states | 8 | 8 | 512 |
| Block states | 15 | 4 | 1024 |
| Biomes | 1 | 64 | 1 |
| Biomes | 2 | 32 | 2 |
| Biomes | 3 | 21 | 4 |
| Biomes | 6 | 10 | 7 |

---

## 6. Long packing (`net.minecraft.util.SimpleBitStorage`)

| Rule | Value |
|---|---|
| Allowed widths | 1–32 bits (`Validate.inclusiveBetween(1, 32, bits)`). A width of 0 uses `ZeroBitStorage`, which holds no Longs. |
| Entries per Long | `valuesPerLong = floor(64 / bits)` |
| Long count | `ceil(size / valuesPerLong)`. A supplied array of any other length is rejected (`SimpleBitStorage$InitializationException`). |
| Entry i location | Long index `i / valuesPerLong` (integer division). Bit offset inside that Long is `(i − longIndex·valuesPerLong) · bits`. |
| Bit order | Least significant first. Entry 0 of each Long occupies the lowest `bits` bits. The value is `(long >> offset) & ((1 << bits) − 1)`. |
| Spanning | **Entries never span two Longs.** When 64 is not a multiple of `bits`, the top `64 − valuesPerLong·bits` bits of every Long are unused padding. The last Long may also have unused trailing entry slots. Padding is written as zero by the vanilla server (inferred: new arrays are zero-initialized and only entry bits are set). |
| Byte order on the wire | Each Long is a big-endian 8-byte Long. |

---

## 7. LightData (`ClientboundLightUpdatePacketData`)

| Field | Type | Notes |
|---|---|---|
| Sky light mask | ByteBitSet | Bit i set means a sky-light array is included for light-section index i. |
| Block light mask | ByteBitSet | Bit i set means a block-light array is included for index i. |
| Empty sky light mask | ByteBitSet | Bit i set means the sky-light layer for index i exists and is all zero. No array is sent for it. |
| Empty block light mask | ByteBitSet | The same, for block light. |
| Sky light arrays | Prefixed Array of ByteArray(VarInt len, max 2048) | One array per set bit in the sky light mask, in ascending bit order. |
| Block light arrays | Prefixed Array of ByteArray(VarInt len, max 2048) | One array per set bit in the block light mask, in ascending bit order. |

Bit index i maps to section Y = (min section Y − 1) + i. The range is i = 0 to section count + 1 inclusive, which covers one section
below the world and one section above.

For each index the server includes it (the server's request masks may limit which indices it looks at):
- If no light data layer exists for that section, neither bit is set (no information).
- If the layer is empty (`DataLayer.isEmpty`), only the empty-mask bit is set.
- Otherwise the mask bit is set and a copy of the 2048-byte array is appended.

A bit is never set in both a mask and its empty mask (inferred from the if/else in `prepareSectionData`).

### 7.1 Nibble array layout (`DataLayer`)

| Property | Value |
|---|---|
| Length | 2048 bytes, holding 4096 4-bit values. The wire codec accepts up to 2048 bytes. `DataLayer(byte[])` rejects any length other than exactly 2048 (inferred: the client builds a `DataLayer` from each array). |
| Value index | `index = (y << 8) | (z << 4) | x`, with x, y, z in 0–15 within the section. |
| Byte index | `index >> 1` |
| Nibble | Even index (`index & 1 == 0`) uses the low nibble (bits 0–3). Odd index uses the high nibble (bits 4–7). |
| Values | 0–15 |

---

## 8. 0x31 / 49 Clientbound Light Update (ClientboundLightUpdatePacket)

| Field | Type | Notes |
|---|---|---|
| Chunk X | VarInt | **VarInt** here, unlike the Int in 0x2E. |
| Chunk Z | VarInt | |
| Light data | LightData | §7 |

---

## 9. 0x56 / 86 Clientbound Section Blocks Update (ClientboundSectionBlocksUpdatePacket)

| Field | Type | Notes |
|---|---|---|
| Section position | SectionPos (Long) | See Composite types. |
| Count | VarInt | Number of changed blocks. |
| Blocks | Count × VarLong | Each value is `(blockStateId << 12) | localPos`. On decode, `localPos = value & 0xFFF` and `blockStateId = value >>> 12`. Block state id indexes `Block.BLOCK_STATE_REGISTRY`. |

`localPos` is a 12-bit packed section-relative position (`SectionPos.sectionRelativePos`):

| Bits | Meaning |
|---|---|
| 8–11 | x (0–15) |
| 4–7 | z (0–15) |
| 0–3 | y (0–15) |

Absolute block = `(sectionX·16 + x, sectionY·16 + y, sectionZ·16 + z)`.

---

## 10. 0x26 / 38 Clientbound Forget Level Chunk (ClientboundForgetLevelChunkPacket)

| Field | Type | Notes |
|---|---|---|
| Chunk position | ChunkPos (Long) | `FriendlyByteBuf.writeChunkPos`, which is `writeLong(ChunkPos.pack())`. See Composite types. |

---

## Composite types introduced here

### ChunkData
The structure in §3: HeightmapMap, ByteArray section buffer (max 2 MiB), and Prefixed Array of BlockEntityEntry.

### HeightmapMap
VarInt count, followed by that many pairs of (VarInt HeightmapType ordinal, Prefixed Array of Long). See §3.1.

### BlockEntityEntry
Byte packed XZ, Short Y, VarInt block entity type id, OptionalNBT. See §3.2.

### OptionalNBT
Network NBT (unnamed root: one tag-type byte, then the payload) in which a lone TAG_End (byte `0x00`) means "absent". There is
**no** Boolean presence prefix. On read, the root must be a compound or End. Any other root type raises a decoder error. Reading
uses `NbtAccounter.defaultQuota()` (2,097,152 accounted bytes, depth 512). See 07-nbt-and-anvil.md.

### Section
Short non-empty count, Short fluid count, PalettedContainer (blocks), and PalettedContainer (biomes). See §4.

### PalettedContainer
UByte bits, then a palette whose form depends on kind, then implied-length Long data. See §5.

### LightData
4 × BitSet, then 2 × Prefixed Array of ByteArray(max 2048). See §7.

### SectionPos (Long)
A 64-bit signed Long (`SectionPos.asLong`):

| Bits | Field | Width | Notes |
|---|---|---|---|
| 42–63 | section X | 22 | Signed. Decode with `long >> 42` (arithmetic). |
| 20–41 | section Z | 22 | Signed. Decode with `(long << 22) >> 42`. |
| 0–19 | section Y | 20 | Signed. Decode with `(long << 44) >> 44`. |

Encode: `((x & 0x3FFFFF) << 42) | ((z & 0x3FFFFF) << 20) | (y & 0xFFFFF)`.

### ChunkPos (Long)
`(x & 0xFFFFFFFF) | ((z & 0xFFFFFFFF) << 32)`. The low 32 bits hold chunk X and the high 32 bits hold chunk Z, each as a signed Int.

---

## Open questions

1. Client-side validation of the section buffer: the client reads exactly `section count` sections from the byte array. This was
   not traced in the client's chunk handler (`ClientChunkCache` / `LevelChunk.replaceWithPacketData`), so it is not known whether
   trailing bytes, or a buffer shorter than needed, are tolerated or rejected.
2. The exact client behaviour when a Linear/HashMap palette size exceeds `1 << bits` was not confirmed.
   An exception is likely (inferred).
3. Whether the client checks the non-empty and fluid counts against the data, or trusts them, was not traced.
4. The vanilla server writes zero padding bits in Longs (inferred). Whether the client ignores nonzero padding was not verified.
   It probably does, because `get` masks the bits.
5. How the client handles a light array length other than 2048 bytes was not traced past the codec, which allows ≤ 2048. `DataLayer` requires exactly 2048.
