# 00 — Data types

This document defines the wire encoding of every primitive and shared composite type used by the
packet tables in the other protocol documents. Field tables elsewhere use the type names defined here.

Sources (bytecode): `net.minecraft.network.FriendlyByteBuf`, `net.minecraft.network.codec.ByteBufCodecs`
(and its anonymous inner classes `ByteBufCodecs$1`…`$37`), `net.minecraft.network.VarInt`, `VarLong`,
`Utf8String`, `LpVec3`, `HashedStack`, `HashedPatchMap`, `net.minecraft.core.BlockPos`, `ChunkPos`,
`GlobalPos`, `UUIDUtil`, `net.minecraft.resources.Identifier`, `net.minecraft.world.item.ItemStack`
(and `ItemStack$1`, `$2`, `$3`), `net.minecraft.core.component.DataComponentPatch` (and `$1`, `$2`, `$3`),
`net.minecraft.network.chat.ComponentSerialization`, `net.minecraft.network.syncher.EntityDataSerializers`,
`SynchedEntityData$DataValue`, `net.minecraft.network.protocol.game.ClientboundSetEntityDataPacket`,
`net.minecraft.nbt.NbtIo`, `NbtAccounter`, `net.minecraft.util.Mth`, `net.minecraft.util.ByIdMap`.

## 1. General conventions

- All multi-byte fixed-width numbers are **big-endian** (Netty `ByteBuf` default byte order; the code
  never switches to the `…LE` accessors on the network path) (inferred from the absence of LE calls).
- There is no padding or alignment anywhere. Fields follow one another directly.
- A packet body must be consumed exactly. `PacketDecoder` throws an error if any bytes remain after
  the packet's codec has finished (see 01-transport.md).
- "Registry id" means the numeric index of an entry within a registry as synchronized during the
  configuration phase (see 04-registry-sync.md). Registries are named here, but their content is not.

## 2. Primitive types

| Type | Size (bytes) | Encoding |
|---|---|---|
| Boolean | 1 | `0x00` = false, `0x01` = true. Writers emit only 0/1; Netty `readBoolean` treats any non-zero byte as true. |
| Byte | 1 | Signed two's-complement 8-bit. |
| UByte | 1 | Unsigned 8-bit (0–255). |
| Short | 2 | Signed 16-bit. |
| UShort | 2 | Unsigned 16-bit (0–65535). |
| Int | 4 | Signed 32-bit. |
| Long | 8 | Signed 64-bit. |
| Float | 4 | IEEE-754 binary32. |
| Double | 8 | IEEE-754 binary64. |
| VarInt | 1–5 | See §2.1. |
| VarLong | 1–10 | See §2.1. |

### 2.1 VarInt and VarLong

Both are little-endian base-128 groups:

- Each byte carries 7 data bits in its low bits (`value & 0x7F`) and a continuation flag in bit 7
  (`0x80`). The first byte holds the least-significant 7 bits.
- Writing: while the remaining value has any bit set outside the low 7 bits (`value & ~0x7F != 0`),
  emit `(value & 0x7F) | 0x80` and shift the value right by 7 **logically** (unsigned shift). Then emit
  the final byte `value` (with bit 7 clear).
- Negative numbers are therefore encoded as their 32-bit (VarInt) or 64-bit (VarLong) unsigned two's
  complement bit pattern: a negative VarInt always takes 5 bytes, a negative VarLong always 10 bytes.
- Reading: accumulate `(byte & 0x7F) << (7 * index)`. After each byte the byte counter is incremented;
  if it exceeds the maximum (5 for VarInt, 10 for VarLong) the reader fails with "VarInt too big" /
  "VarLong too big". Reading stops at the first byte whose bit 7 is clear.
- Maximum encoded sizes: VarInt `MAX_VARINT_SIZE = 5`; VarLong `MAX_VARLONG_SIZE = 10`.
- For the 5th VarInt byte, bits beyond bit 31 are silently discarded (Java `int` shift semantics); no
  error is raised for them (inferred from the shift arithmetic).

Byte size of a VarInt: the smallest `n` in 1..4 such that `value & (-1 << 7n) == 0`, else 5. VarLong is
the same with 1..9 / 10.

### 2.2 Variants of VarInt used for optional or offset values

| Name | Encoding | Source |
|---|---|---|
| OptionalVarInt | VarInt `0` = absent; otherwise VarInt `value + 1`. | `ByteBufCodecs.OPTIONAL_VAR_INT` |
| ContainerId | Plain VarInt. | `ByteBufCodecs.CONTAINER_ID` / `FriendlyByteBuf.readContainerId` |

## 3. Strings and identifiers

### 3.1 String(max N)

| Part | Type | Notes |
|---|---|---|
| Length | VarInt | Number of **bytes** of UTF-8 that follow. |
| Data | bytes | UTF-8 (Netty `ByteBufUtil.writeUtf8`, Java standard UTF-8 decoder). |

Limits (`net.minecraft.network.Utf8String`):

- N is a limit in UTF-16 code units (Java `String.length()`), not bytes.
- Reader: fails if the byte length is greater than `3 × N` (`ByteBufUtil.utf8MaxBytes(N)`), if it is
  negative, or if it exceeds the remaining readable bytes. After decoding, fails if the string has more
  than N UTF-16 code units.
- Writer: fails if the string has more than N code units, or if its UTF-8 encoding exceeds `3 × N` bytes.
- When no limit is stated, N = 32767 (`FriendlyByteBuf.MAX_STRING_LENGTH`). `STRING_UTF8` in
  `ByteBufCodecs` is String(32767).
- `FriendlyByteBuf.MAX_COMPONENT_STRING_LENGTH = 262144` is used for JSON text (see §7.2).

### 3.2 Identifier

Wire form: String(32767). Parsed with `Identifier.parse`:

- If the string contains `:`, the part before the first `:` is the namespace and the rest is the path.
  If it does not contain `:`, the namespace is `minecraft` and the whole string is the path.
- Allowed namespace characters: `a`–`z`, `0`–`9`, `_`, `-`, `.`.
- Allowed path characters: `a`–`z`, `0`–`9`, `_`, `-`, `.`, `/`.
- Upper-case letters are not allowed. An invalid identifier fails decoding.

`ResourceKey` values (registry keys, dimension keys) are sent as a bare Identifier
(`ResourceKey.streamCodec`, `ResourceKey.REGISTRY_STREAM_CODEC`).

### 3.3 PlayerName

String(16) (`ByteBufCodecs.PLAYER_NAME`). The server login code additionally requires every character
to be in the range `0x21`–`0x7E` (`StringUtil.isValidPlayerName`: length ≤ 16 and no char ≤ 32 or ≥ 127).

## 4. Position-like types

### 4.1 Position

A packed Long (`BlockPos.asLong` / `BlockPos.of`), signed two's-complement fields:

| Bits (0 = least significant) | Width | Field |
|---|---|---|
| 38–63 | 26 | X (signed) |
| 12–37 | 26 | Z (signed) |
| 0–11 | 12 | Y (signed) |

Derivation from the bytecode: `PACKED_HORIZONTAL_LENGTH = 1 + log2(smallestEncompassingPowerOfTwo(30000000)) = 26`,
`PACKED_Y_LENGTH = 64 − 2×26 = 12`, `Z_OFFSET = 12`, `X_OFFSET = 38`, `Y_OFFSET = 0`. Packing masks each
coordinate to its width and ORs it in at its offset. Unpacking sign-extends: e.g. X =
`(long << (64 − 38 − 26)) >> (64 − 26)` (arithmetic shift).

### 4.2 ChunkPos

A Long: low 32 bits = chunk X, high 32 bits = chunk Z (`ChunkPos.pack(x, z) = (x & 0xFFFFFFFF) | ((z & 0xFFFFFFFF) << 32)`).

### 4.3 GlobalPos

| Field | Type | Notes |
|---|---|---|
| Dimension | Identifier | Key in the dimension registry. |
| Position | Position | |

### 4.4 Angle

A single Byte representing 1/256 of a full turn (`ByteBufCodecs.ROTATION_BYTE`):

- Encode: `byte = (int) floor(degrees × 256 / 360)` truncated to 8 bits (`Mth.packDegrees`).
- Decode: `degrees = byte × 360 / 256` where `byte` is the **signed** byte value (`Mth.unpackDegrees`),
  so decoded values are in [−180, 180).

### 4.5 Vector3f, Quaternionf, Rotations

| Type | Encoding |
|---|---|
| Vector3f | Float x, Float y, Float z (`ByteBufCodecs.VECTOR3F`). |
| Quaternionf | Float x, Float y, Float z, Float w (`ByteBufCodecs.QUATERNIONF`). |
| Rotations | Float x, Float y, Float z (`Rotations.STREAM_CODEC`). |

### 4.6 LpVec3 (low-precision velocity vector)

`net.minecraft.network.LpVec3`. Variable length: 1 byte, or 6 bytes, or 6 bytes + VarInt.

Reading:

1. Read UByte `b0`. If `b0 == 0` the vector is (0, 0, 0) and nothing else follows.
2. Read UByte `b1`, then an unsigned 32-bit Int `b2_5`.
3. Form a 48-bit value `packed = (b2_5 << 16) | (b1 << 8) | b0`.
4. `scale = b0 & 3`. If bit 2 of `b0` (`0x04`, continuation flag) is set, read a VarInt `s`, and
   `scale = scale | ((s & 0xFFFFFFFF) << 2)`.
5. Each component uses 15 bits: X at bit 3, Y at bit 18, Z at bit 33. For a 15-bit field `q`
   (`(packed >> offset) & 0x7FFF`): `component = (min(q, 32766) × 2 / 32766 − 1) × scale`.

Writing:

1. Each component is sanitized: NaN becomes 0, then clamped to ±1.7179869183E10.
2. `m` = largest absolute component. If `m < 3.051944088384301E-5` write a single `0x00` byte.
3. `scale = ceil(m)` (as a long). If `scale` has bits beyond the low 2, the low byte carries
   `(scale & 3) | 4` and the remainder `scale >> 2` is written afterwards as a VarInt; otherwise the low
   byte carries `scale` (which is 1–3).
4. Each component is quantized as `round((component / scale × 0.5 + 0.5) × 32766)` and placed at bit 3
   (X), 18 (Y), 33 (Z).
5. Emit the low byte (bits 0–7), the next byte (bits 8–15), then an Int holding bits 16–47, then the
   optional VarInt.

## 5. UUID and other fixed composites

| Type | Encoding | Source |
|---|---|---|
| UUID | Long most-significant bits, then Long least-significant bits (16 bytes). | `FriendlyByteBuf.readUUID`, `UUIDUtil.STREAM_CODEC` |
| RGB | 3 bytes: red, green, blue (each 0–255); alpha is implied 255. | `ByteBufCodecs.RGB_COLOR` |
| Instant | Long, milliseconds since the Unix epoch. | `ByteBufCodecs.INSTANT` |
| PublicKey | ByteArray with maximum length 512, containing an X.509 `SubjectPublicKeyInfo` DER encoding of an RSA key. | `ByteBufCodecs.PUBLIC_KEY`, `Crypt.byteToPublicKey` |

## 6. Arrays, sets and containers

### 6.1 ByteArray(max N)

| Part | Type | Notes |
|---|---|---|
| Length | VarInt | Number of bytes. |
| Data | bytes | |

`FriendlyByteBuf.readByteArray()` without an explicit limit uses the number of readable bytes as the
limit; with a limit it fails if `length > N`. `ByteBufCodecs.BYTE_ARRAY` is unbounded (readable bytes);
`ByteBufCodecs.byteArray(N)` enforces N on both read and write.

### 6.2 LongArray

VarInt count followed by that many Longs. The reader fails if `count > readableBytes / 8`.

### 6.3 BitSet (two distinct encodings)

| Name | Encoding | Used through |
|---|---|---|
| BitSet | LongArray: VarInt number of Longs, then the Longs. Bit `i` is bit `i mod 64` of Long `i / 64` (`java.util.BitSet.valueOf(long[])`). | `FriendlyByteBuf.readBitSet` / `writeBitSet` |
| ByteBitSet | ByteArray: VarInt number of bytes, then the bytes. Bit `i` is bit `i mod 8` of byte `i / 8` (`BitSet.valueOf(byte[])`). | `ByteBufCodecs.BIT_SET` |
| FixedBitSet(n) | Exactly `ceil(n / 8)` bytes, no length prefix, same bit order as ByteBitSet. Writer fails if the set has a bit at index ≥ n. | `FriendlyByteBuf.readFixedBitSet`, `ByteBufCodecs.fixedBitSet(n)` |
| EnumSet<E> | FixedBitSet(number of constants of E); bit `i` set ⇔ the constant with ordinal `i` is present. | `FriendlyByteBuf.readEnumSet` |

Packet documents must state which BitSet variant a field uses.

### 6.4 Prefixed Array of X / Collection / List

| Part | Type | Notes |
|---|---|---|
| Count | VarInt | Number of elements. |
| Elements | X × Count | Back-to-back. |

`ByteBufCodecs.collection/list(max)`: the reader fails if `count > max` (`readCount`), the writer fails
likewise (`writeCount`). Without an explicit max the limit is `Integer.MAX_VALUE`. Pre-allocation is
capped at 65536 (`MAX_INITIAL_COLLECTION_SIZE`), which has no wire effect.

`FixedList(n)` (`fixedSizeList`, `fixedSizeCollection`): exactly n elements, no count prefix; the writer
fails if the collection size differs from n.

### 6.5 Map of K to V

VarInt count (with optional max, same rules as §6.4), then `count` pairs of (K, V).

### 6.6 Optional X

| Part | Type | Notes |
|---|---|---|
| Present | Boolean | |
| Value | X | Only if Present is true. |

The same encoding is used for "nullable" fields (`FriendlyByteBuf.readNullable` / `writeNullable`) and
`ByteBufCodecs.optional`.

### 6.7 Either<L, R>

| Part | Type | Notes |
|---|---|---|
| IsLeft | Boolean | true → L follows, false → R follows. |
| Value | L or R | |

(`ByteBufCodecs.either`, `FriendlyByteBuf.readEither`.)

### 6.8 LengthPrefixed(max N) X

`ByteBufCodecs.lengthPrefixed(N)`: VarInt byte length (fails if > N on read or write), then exactly
that many bytes, which contain the encoding of X. The decoder decodes X from a slice of exactly that
length and then advances the reader past the slice.

## 7. Enums

Two different enum encodings exist. Packet documents state which applies.

| Name | Encoding | Source |
|---|---|---|
| Enum X | VarInt Java ordinal (declaration order, starting at 0). Out-of-range ordinals fail (array index error). | `FriendlyByteBuf.readEnum` / `writeEnum` |
| IdEnum X | VarInt explicit id taken from the enum's own id field, mapped through `ByIdMap`. | `ByteBufCodecs.idMapper(...)` with `ByIdMap.continuous` |

For IdEnum, the decoder's handling of out-of-range ids depends on the enum's `OutOfBoundsStrategy`:
`ZERO` (use id 0), `WRAP` (id modulo count, `Mth.positiveModulo`), or `CLAMP` (clamp to the range)
(inferred from the strategy names; the per-strategy arithmetic was not re-read). The strategy is named
per enum where it matters.

## 8. NBT on the network

Network NBT differs from file NBT only in the framing of the root tag (`NbtIo.writeAnyTag` /
`NbtIo.readAnyTag`; the tag payload formats are documented in 07-nbt-and-anvil.md):

| Part | Type | Notes |
|---|---|---|
| Tag type | Byte | The NBT type id of the root tag. Any type is allowed (not only Compound). |
| Payload | (per type) | The root tag's payload. **No root name is written** (file NBT writes a String name here). |

- If the type byte is `0` (End), nothing follows. `FriendlyByteBuf.readNbt` then returns "null".
- `NBT` (`ByteBufCodecs.TAG`, `tagCodec`): fails on an End root ("Expected non-null compound tag").
- `CompoundNBT` (`COMPOUND_TAG`): fails unless the root is a Compound.
- `Optional NBT` (`optionalTagCodec`) and `OptionalCompoundNBT` (`OPTIONAL_COMPOUND_TAG`): an End root
  means "absent". **This is not the Boolean-prefixed Optional of §6.6**; absence is signalled by the
  single byte `0x00`.
- Size accounting (`NbtAccounter`): default quota 2 097 152 bytes (`DEFAULT_NBT_QUOTA`) and maximum
  nesting depth 512. "Trusted" codecs (`TRUSTED_TAG`, `TRUSTED_COMPOUND_TAG`, `fromCodecTrusted`,
  `fromCodecWithRegistriesTrusted`) use an unlimited byte quota (still depth 512). Individual packets may
  use a custom accounter (stated in their tables).
- Types serialized "via codec over NBT" (`ByteBufCodecs.fromCodec`, `fromCodecWithRegistries`) are
  encoded to an NBT tree with `NbtOps` (or registry-aware `RegistryOps` over `NbtOps`) and then written
  as network NBT as above.

## 9. Text components

### 9.1 TextComponent (network NBT form)

`ComponentSerialization.STREAM_CODEC` and its variants encode a chat component by running
`ComponentSerialization.CODEC` through registry-aware NBT ops and writing the result as network NBT
(§8). Variants:

| Name used in tables | Source field | Quota | Registry context |
|---|---|---|---|
| TextComponent | `ComponentSerialization.STREAM_CODEC` | 2 MiB | yes (play only) |
| TrustedTextComponent | `TRUSTED_STREAM_CODEC` | unlimited | yes |
| ContextFreeTextComponent | `TRUSTED_CONTEXT_FREE_STREAM_CODEC` | unlimited | no (usable before registries exist) |
| Optional TextComponent | `OPTIONAL_STREAM_CODEC` / `TRUSTED_OPTIONAL_STREAM_CODEC` | as above | Boolean-prefixed Optional (§6.6) |

The byte layout is identical for all variants; they differ only in decoder limits and in whether
registry-dependent component content can be resolved. The schema of the component tree itself (keys
such as text, translate, extra, style) is the component codec's NBT schema and is not repeated here.

### 9.2 JsonTextComponent

A few pre-configuration packets carry text as JSON instead (`ByteBufCodecs.lenientJson(N)`):
String(max N) containing JSON produced by Gson with HTML escaping disabled, parsed leniently
(`LenientJsonParser`). The JSON is the same component codec rendered through `JsonOps`. Used by
Login Disconnect (N = 262144) and inside the status response (N = 32767).

## 10. Registry references

Let R be a registry.

### 10.1 RegistryId<R>

Plain VarInt registry id of an entry of R (`ByteBufCodecs.registry`, `holderRegistry`; the latter
returns the entry's holder but encodes identically). No inline form. Unknown ids fail decoding
(`IdMap.byIdOrThrow`).

### 10.2 Holder<R> (also called IdOr<X>)

`ByteBufCodecs.holder(registryKey, directCodec)` (`ByteBufCodecs$33`):

| Part | Type | Notes |
|---|---|---|
| Selector | VarInt | `0` = an inline value follows. `n > 0` = registry entry with id `n − 1`; nothing follows. |
| Inline value | X | Only if Selector is 0. Encoded with the type's direct codec (stated per use). |

On write, a holder that refers to a registered entry ("reference" kind) is written as `id + 1`; a
"direct" holder (an unregistered inline value) is written as `0` followed by the value.

### 10.3 HolderSet<R>

`ByteBufCodecs.holderSet` (`ByteBufCodecs$34`):

| Part | Type | Notes |
|---|---|---|
| Selector | VarInt | `0` = a tag reference follows. `n > 0` = an explicit list of `n − 1` entries follows. |
| Tag name | Identifier | Only if Selector is 0. Names a tag of R. |
| Entries | RegistryId<R> × (n − 1) | Only if Selector > 0. |

## 11. Game profile

### 11.1 GameProfile (`ByteBufCodecs.GAME_PROFILE`)

| Field | Type | Notes |
|---|---|---|
| Id | UUID | |
| Name | String(16) | |
| Properties | PropertyMap | See below. |

### 11.2 PropertyMap (`ByteBufCodecs.GAME_PROFILE_PROPERTIES`, `ByteBufCodecs$35`)

| Field | Type | Notes |
|---|---|---|
| Count | VarInt | At most 16. |
| Properties | Property × Count | |

Property:

| Field | Type | Notes |
|---|---|---|
| Name | String(64) | |
| Value | String(32767) | |
| Signature | Optional String(1024) | Boolean-prefixed. |

## 12. Item stacks

### 12.1 ItemStack (optional form; `ItemStack.OPTIONAL_STREAM_CODEC`, `ItemStack$1`)

| Field | Type | Notes |
|---|---|---|
| Count | VarInt | If `≤ 0` the stack is empty and **no further fields follow**. Writers emit `0` for an empty stack. |
| Item | RegistryId<item> | Present only if Count > 0. |
| Components | DataComponentPatch | Present only if Count > 0. |

Variants:

| Name | Difference | Source |
|---|---|---|
| ItemStack | As above; empty allowed. | `OPTIONAL_STREAM_CODEC` |
| NonEmptyItemStack | Same bytes; decoding an empty stack fails ("Empty ItemStack not allowed"), and so does encoding one. | `ItemStack.STREAM_CODEC` (`ItemStack$2`) |
| UntrustedItemStack | Same as ItemStack but the patch uses DelimitedDataComponentPatch (§12.3). | `OPTIONAL_UNTRUSTED_STREAM_CODEC` |
| ItemStackList | Prefixed Array of ItemStack (no max). | `OPTIONAL_LIST_STREAM_CODEC` |

`ItemStack.validatedStreamCodec` (`ItemStack$3`) adds a semantic validation pass after decoding; it does
not change the bytes.

### 12.2 DataComponentPatch (`DataComponentPatch.STREAM_CODEC`, `DataComponentPatch$3`)

| Field | Type | Notes |
|---|---|---|
| AddedCount | VarInt | Number of components set to a value. |
| RemovedCount | VarInt | Number of components explicitly removed. |
| Added | AddedEntry × AddedCount | |
| Removed | RegistryId<data_component_type> × RemovedCount | |

AddedEntry:

| Field | Type | Notes |
|---|---|---|
| Type | RegistryId<data_component_type> | |
| Value | (type-specific) | Encoded with that component type's own stream codec (`DataComponentType.streamCodec()`). The per-type content is not documented here. |

If both counts are 0 the patch is empty. Writers emit all added entries first, then all removed entries.

### 12.3 DelimitedDataComponentPatch (`DataComponentPatch.DELIMITED_STREAM_CODEC`, `DataComponentPatch$2`)

Identical to §12.2 except that each AddedEntry's Value is wrapped in LengthPrefixed (§6.8) with maximum
`Integer.MAX_VALUE`: a VarInt byte length precedes the value. This lets a receiver skip components it
cannot decode.

### 12.4 HashedStack (`net.minecraft.network.HashedStack`)

Sent by the client in place of a full ItemStack when it only needs to describe a stack it believes the
server already knows.

| Field | Type | Notes |
|---|---|---|
| Present | Boolean | false = empty stack; nothing else follows. |
| Item | RegistryId<item> | If Present. |
| Count | VarInt | If Present. |
| Components | HashedPatchMap | If Present. |

HashedPatchMap (`HashedPatchMap.STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| AddedCount | VarInt | At most 256. |
| Added | (RegistryId<data_component_type>, Int hash) × AddedCount | |
| RemovedCount | VarInt | At most 256. |
| Removed | RegistryId<data_component_type> × RemovedCount | |

Each hash is a 32-bit value: the server builds it by encoding the component value with its codec
through `HashOps.CRC32C_INSTANCE` (a `DynamicOps` that feeds a structural encoding into Guava
`Hashing.crc32c()`) and taking `HashCode.asInt()` (`ServerPlayer$1$1`). The exact byte stream fed to
CRC32C is defined by `net.minecraft.util.HashOps` and is outside this document's scope.

## 13. Entity metadata (SynchedEntityData)

### 13.1 Wire structure

Used as the body of the play packet Set Entity Data (`ClientboundSetEntityDataPacket`, after its
VarInt entity id) and anywhere else `SynchedEntityData$DataValue` lists are written.

A metadata list is a sequence of entries terminated by a single UByte `0xFF` (`EOF_MARKER = 255`):

| Field | Type | Notes |
|---|---|---|
| Index | UByte | Data slot index (0–254). The value `0xFF` instead terminates the list. |
| Serializer | VarInt | Serializer id from §13.2. Unknown ids fail decoding. |
| Value | (per serializer) | |

### 13.2 Serializer id table

Ids are assigned sequentially from 0 in `registerSerializer` call order in
`EntityDataSerializers.<clinit>` (stored in a `CrudeIncrementalIntIdentityHashBiMap`; sequential
allocation from 0 is inferred from that class). The registration order differs from the field
declaration order; the table follows registration order.

| Id | Serializer | Wire type |
|---|---|---|
| 0 | BYTE | Byte |
| 1 | INT | VarInt |
| 2 | LONG | VarLong |
| 3 | FLOAT | Float |
| 4 | STRING | String(32767) |
| 5 | COMPONENT | TrustedTextComponent (§9.1) |
| 6 | OPTIONAL_COMPONENT | Optional TrustedTextComponent (Boolean-prefixed) |
| 7 | ITEM_STACK | ItemStack (§12.1, empty allowed) |
| 8 | BOOLEAN | Boolean |
| 9 | ROTATIONS | Rotations (3 Floats) |
| 10 | BLOCK_POS | Position |
| 11 | OPTIONAL_BLOCK_POS | Optional Position (Boolean-prefixed) |
| 12 | DIRECTION | IdEnum Direction (VarInt id; out-of-bounds strategy WRAP) |
| 13 | OPTIONAL_LIVING_ENTITY_REFERENCE | Optional UUID (Boolean-prefixed) |
| 14 | BLOCK_STATE | VarInt block state id (global block state id map `Block.BLOCK_STATE_REGISTRY`) |
| 15 | OPTIONAL_BLOCK_STATE | VarInt: `0` = absent, otherwise a block state id. Note that block state id 0 therefore cannot be expressed as "present". |
| 16 | PARTICLE | Particle: RegistryId<particle_type> followed by that type's own options encoding (`ParticleTypes.STREAM_CODEC`, a dispatch codec) |
| 17 | PARTICLES | Prefixed Array of Particle |
| 18 | VILLAGER_DATA | RegistryId<villager_type>, RegistryId<villager_profession>, VarInt level |
| 19 | OPTIONAL_UNSIGNED_INT | VarInt: `0` = absent, otherwise `value + 1` |
| 20 | POSE | IdEnum Pose (VarInt id) |
| 21 | CAT_VARIANT | RegistryId<cat_variant> |
| 22 | CAT_SOUND_VARIANT | RegistryId<cat_sound_variant> |
| 23 | COW_VARIANT | RegistryId<cow_variant> |
| 24 | COW_SOUND_VARIANT | RegistryId<cow_sound_variant> |
| 25 | WOLF_VARIANT | RegistryId<wolf_variant> |
| 26 | WOLF_SOUND_VARIANT | RegistryId<wolf_sound_variant> |
| 27 | FROG_VARIANT | RegistryId<frog_variant> |
| 28 | PIG_VARIANT | RegistryId<pig_variant> |
| 29 | PIG_SOUND_VARIANT | RegistryId<pig_sound_variant> |
| 30 | CHICKEN_VARIANT | RegistryId<chicken_variant> |
| 31 | CHICKEN_SOUND_VARIANT | RegistryId<chicken_sound_variant> |
| 32 | ZOMBIE_NAUTILUS_VARIANT | RegistryId<zombie_nautilus_variant> |
| 33 | OPTIONAL_GLOBAL_POS | Optional GlobalPos (Boolean-prefixed) |
| 34 | PAINTING_VARIANT | Holder<painting_variant> (§10.2; inline form allowed) |
| 35 | SNIFFER_STATE | IdEnum (VarInt; strategy ZERO) |
| 36 | ARMADILLO_STATE | IdEnum (VarInt; strategy ZERO) |
| 37 | COPPER_GOLEM_STATE | IdEnum (VarInt; strategy ZERO) |
| 38 | WEATHERING_COPPER_STATE | IdEnum (VarInt) |
| 39 | VECTOR3 | Vector3f |
| 40 | QUATERNION | Quaternionf |
| 41 | RESOLVABLE_PROFILE | ResolvableProfile (§13.3) |
| 42 | HUMANOID_ARM | IdEnum HumanoidArm: 0 = left, 1 = right (strategy ZERO) |
| 43 | DYE_COLOR | IdEnum DyeColor (VarInt id) |

The meaning of individual metadata indices per entity type is gameplay content and is out of scope.

### 13.3 ResolvableProfile

`ResolvableProfile.STREAM_CODEC`:

| Field | Type | Notes |
|---|---|---|
| Profile | Either<GameProfile, PartialProfile> | Boolean true → full GameProfile (§11.1); false → PartialProfile. |
| Skin patch | PlayerSkinPatch | |

PartialProfile (`ResolvableProfile$Partial`):

| Field | Type |
|---|---|
| Name | Optional String(16) |
| Id | Optional UUID |
| Properties | PropertyMap |

PlayerSkinPatch (`PlayerSkin$Patch`):

| Field | Type | Notes |
|---|---|---|
| Body texture | Optional Identifier | Asset id (`ClientAsset$ResourceTexture`). |
| Cape texture | Optional Identifier | (inferred field meaning from order) |
| Elytra texture | Optional Identifier | (inferred field meaning from order) |
| Model | Optional Boolean | `PlayerModelType` mapped from a Boolean; true = slim (inferred). |

## 14. Composite types introduced here

All composite types are defined in the sections above: OptionalVarInt and ContainerId (§2.2),
PlayerName (§3.3), ChunkPos and GlobalPos (§4), Vector3f, Quaternionf, Rotations (§4.5), LpVec3 (§4.6),
RGB, Instant, PublicKey (§5), ByteBitSet, FixedBitSet, EnumSet (§6.3), FixedList (§6.4), Either (§6.7),
LengthPrefixed (§6.8), IdEnum (§7), CompoundNBT and Optional NBT (§8), TrustedTextComponent,
ContextFreeTextComponent, JsonTextComponent (§9), RegistryId, Holder/IdOr, HolderSet (§10), GameProfile,
PropertyMap (§11), NonEmptyItemStack, UntrustedItemStack, ItemStackList, DataComponentPatch,
DelimitedDataComponentPatch, HashedStack, HashedPatchMap (§12), entity metadata list and
ResolvableProfile (§13).

## Open questions

1. `HashOps` (CRC32C structural hashing used by HashedStack) was not traced byte-for-byte; a server
   that wants to compare client hashes must reproduce it exactly.
2. The precise out-of-range arithmetic of `ByIdMap.OutOfBoundsStrategy` WRAP / CLAMP was not re-read.
3. The entity-data serializer ids rely on `CrudeIncrementalIntIdentityHashBiMap.add` allocating ids
   0, 1, 2, … in call order; the allocator's code was not separately disassembled.
4. Particle option encodings per particle type, and data component value encodings per component type,
   are not documented here (by design); they are needed by any implementation that sends items or
   particles with options.
5. The meaning of the second and third PlayerSkinPatch textures (cape / elytra) is inferred from
   position only.
