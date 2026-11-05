# 05a — Play phase, clientbound packets 0x00–0x47 (0–71)

This document gives the wire layout of the first 72 clientbound packets of the play ("game") phase.
Packet ids are the registration order in the clientbound play protocol builder
(`GameProtocols`, the clientbound template). That order was checked against the bytecode. The
registration is unconditional, so no ids move under any runtime flag.

General notes that apply to every table below:

- All multi-byte fixed-width integers and floats are big-endian (network order), as in
  00-data-types.md.
- "Registry id (VarInt) into registry R" means a plain VarInt holding the numeric id of an entry
  in registry R. The value is never offset and has no inline form. Numeric ids are assigned as
  described in 04-registry-sync.md.
- "Holder<R>" means the registry-or-inline encoding: a VarInt *n*. If *n* = 0, the entry is sent
  inline using the stated inline layout. Otherwise the entry is registry id *n* − 1. Some fields
  are holders that have no inline form; their tables say "registry id (VarInt)" instead.
- `TextComponent` fields in the play phase all use the "trusted" component codec. This is the same
  network-NBT encoding of a component as described in 00-data-types.md, with no extra size check
  on the encoder side.
- Several packets share types that come from the configuration phase. For packets that are
  themselves shared ("common" and "cookie" packets), this file gives only the id and refers to
  03-configuration.md.
- A packet with "no fields" has a zero-length body after the packet id.

---

## 0x00 Clientbound Bundle Delimiter (ClientboundBundleDelimiterPacket) — id 0

No fields.

This packet is registered as the protocol's bundle packet. A delimiter opens a bundle and a second
delimiter closes it. The client gathers every packet received between the two delimiters and handles
them as one unit, in one tick (inferred from `ProtocolInfoBuilder.withBundlePacket` and
`BundlerInfo`). `BundlerInfo.BUNDLE_SIZE_LIMIT` = 4096 caps the number of packets inside one bundle.

## 0x01 Clientbound Add Entity (ClientboundAddEntityPacket) — id 1

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | Network entity id |
| Entity UUID | UUID | |
| Entity type | VarInt | Registry id into the entity type registry |
| X | Double | Position |
| Y | Double | |
| Z | Double | |
| Movement | LpVec3 | Initial velocity, in blocks per tick (see composite types) |
| Pitch (xRot) | Angle | |
| Yaw (yRot) | Angle | |
| Head yaw | Angle | |
| Data | VarInt | Type-specific extra value (for example, the block state for falling blocks) |

## 0x02 Clientbound Animate (ClientboundAnimatePacket) — id 2

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Action | UByte | The class defines constants 0 = wake up, 1 = critical hit, 2 = magic critical hit. Other values are handled client-side (not enumerated here). |

## 0x03 Clientbound Award Stats (ClientboundAwardStatsPacket) — id 3

| Field | Type | Notes |
|---|---|---|
| Count | VarInt | Number of entries |
| Entries | Count × (Stat, VarInt) | Each entry is a `Stat` followed by the VarInt statistic value |

The map is written as a VarInt count and then key/value pairs (`ByteBufCodecs.map`). No maximum is
set.

## 0x04 Clientbound Block Changed Ack (ClientboundBlockChangedAckPacket) — id 4

| Field | Type | Notes |
|---|---|---|
| Sequence | VarInt | Sequence number being acknowledged (from serverbound block-interaction packets) |

## 0x05 Clientbound Block Destruction (ClientboundBlockDestructionPacket) — id 5

| Field | Type | Notes |
|---|---|---|
| Breaker id | VarInt | Id of the entity breaking the block |
| Location | Position | |
| Progress | UByte | Destroy stage. Values outside 0–9 remove the overlay (inferred) |

## 0x06 Clientbound Block Entity Data (ClientboundBlockEntityDataPacket) — id 6

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Block entity type | VarInt | Registry id into the block entity type registry |
| Data | NBT | A compound tag (trusted compound codec: no size quota) |

## 0x07 Clientbound Block Event (ClientboundBlockEventPacket) — id 7

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Param 0 (b0) | UByte | Block-specific action id |
| Param 1 (b1) | UByte | Block-specific action parameter |
| Block | VarInt | Registry id into the block registry (a block id, not a block state id) |

## 0x08 Clientbound Block Update (ClientboundBlockUpdatePacket) — id 8

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Block state | VarInt | Global block state id (`Block.BLOCK_STATE_REGISTRY`) |

## 0x09 Clientbound Boss Event (ClientboundBossEventPacket) — id 9

| Field | Type | Notes |
|---|---|---|
| Bar UUID | UUID | Identifies the boss bar |
| Operation | Enum (VarInt) | 0 ADD, 1 REMOVE, 2 UPDATE_PROGRESS, 3 UPDATE_NAME, 4 UPDATE_STYLE, 5 UPDATE_PROPERTIES |
| Operation data | varies | See below |

Operation data by operation:

| Operation | Fields |
|---|---|
| 0 ADD | TextComponent title; Float progress; Enum (VarInt) color; Enum (VarInt) overlay; UByte flags |
| 1 REMOVE | (none) |
| 2 UPDATE_PROGRESS | Float progress |
| 3 UPDATE_NAME | TextComponent title |
| 4 UPDATE_STYLE | Enum (VarInt) color; Enum (VarInt) overlay |
| 5 UPDATE_PROPERTIES | UByte flags |

- Color ordinals (`BossEvent.BossBarColor`): 0 PINK, 1 BLUE, 2 RED, 3 GREEN, 4 YELLOW, 5 PURPLE, 6 WHITE.
- Overlay ordinals (`BossEvent.BossBarOverlay`): 0 PROGRESS, 1 NOTCHED_6, 2 NOTCHED_10, 3 NOTCHED_12, 4 NOTCHED_20.
- Flags: bit 0x01 = darken screen, 0x02 = play boss music, 0x04 = create world fog.

## 0x0A Clientbound Change Difficulty (ClientboundChangeDifficultyPacket) — id 10

| Field | Type | Notes |
|---|---|---|
| Difficulty | VarInt | 0 PEACEFUL, 1 EASY, 2 NORMAL, 3 HARD. Encoded with an id mapper (VarInt), not a byte. Out-of-range values wrap. |
| Locked | Boolean | |

## 0x0B Clientbound Chunk Batch Finished (ClientboundChunkBatchFinishedPacket) — id 11

| Field | Type | Notes |
|---|---|---|
| Batch size | VarInt | Number of chunk packets sent since the matching Chunk Batch Start |

## 0x0C Clientbound Chunk Batch Start (ClientboundChunkBatchStartPacket) — id 12

No fields. This is a singleton (`StreamCodec.unit`).

## 0x0D Clientbound Chunks Biomes (ClientboundChunksBiomesPacket) — id 13

| Field | Type | Notes |
|---|---|---|
| Chunks | Prefixed Array of ChunkBiomeData | VarInt count, no maximum |

`ChunkBiomeData`:

| Field | Type | Notes |
|---|---|---|
| Chunk position | ChunkPos | Packed Long (see composite types) |
| Data | ByteArray(VarInt len) | Maximum 2,097,152 bytes. Holds the biome paletted container of each section, from bottom to top, concatenated. The container format is in 06-chunk-format.md. |

## 0x0E Clientbound Clear Titles (ClientboundClearTitlesPacket) — id 14

| Field | Type | Notes |
|---|---|---|
| Reset | Boolean | Also resets the title timings when true |

## 0x0F Clientbound Command Suggestions (ClientboundCommandSuggestionsPacket) — id 15

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | Echoes the id from the serverbound suggestion request |
| Start | VarInt | Start offset of the replaced text range |
| Length | VarInt | Length of the replaced text range |
| Suggestions | Prefixed Array of SuggestionEntry | VarInt count, no maximum |

`SuggestionEntry`:

| Field | Type | Notes |
|---|---|---|
| Text | String(max 32767) | |
| Tooltip | Optional TextComponent | Boolean present flag, then the component |

## 0x10 Clientbound Commands (ClientboundCommandsPacket) — id 16

| Field | Type | Notes |
|---|---|---|
| Nodes | Prefixed Array of CommandNode | VarInt count, no maximum. A node's index in this array is its node index. |
| Root index | VarInt | Index of the root node |

`CommandNode`:

| Field | Type | Notes |
|---|---|---|
| Flags | Byte | See flag table |
| Children | Prefixed Array of VarInt | VarInt count, then node indices. The count is checked against the readable bytes. |
| Redirect | VarInt | Present only if flag 0x08 is set. Index of the redirect target node. |
| Name | String(max 32767) | Present only for literal (type 1) and argument (type 2) nodes |
| Parser | VarInt | Present only for argument nodes. Registry id into the command argument type registry (table below). |
| Parser properties | varies | Present only for argument nodes. Layout depends on the parser (table below). |
| Suggestions type | Identifier | Present only for argument nodes with flag 0x10 set |

Flags:

| Bits | Meaning |
|---|---|
| 0x03 (mask) | Node type: 0 = root, 1 = literal, 2 = argument. Type 3 is treated as "no stub" (no name or parser follows). |
| 0x04 | Executable |
| 0x08 | Has redirect (the Redirect field is present) |
| 0x10 | Has custom suggestions (the Suggestions type field is present; argument nodes only) |
| 0x20 | Restricted (no extra data) |

The order of fields within a node is: flags, children, redirect, then the type-specific stub (name;
then parser, properties and suggestions for argument nodes).

### Argument parser registry and property layouts

The parser id is the registration order in `ArgumentTypeInfos.bootstrap`. The registration has no
conditions, so the ids below are fixed for this version. Parsers marked "none" carry no property
bytes.

| Id | Parser | Properties |
|---|---|---|
| 0 | brigadier:bool | none |
| 1 | brigadier:float | NumberRange(Float) |
| 2 | brigadier:double | NumberRange(Double) |
| 3 | brigadier:integer | NumberRange(Int) |
| 4 | brigadier:long | NumberRange(Long) |
| 5 | brigadier:string | Enum (VarInt) string kind: 0 SINGLE_WORD, 1 QUOTABLE_PHRASE, 2 GREEDY_PHRASE (ordinals from the Brigadier library, which is not in the unpacked classes, inferred) |
| 6 | entity | Byte flags: 0x01 single, 0x02 players only |
| 7 | game_profile | none |
| 8 | block_pos | none |
| 9 | column_pos | none |
| 10 | vec3 | none |
| 11 | vec2 | none |
| 12 | block_state | none |
| 13 | block_predicate | none |
| 14 | item_stack | none |
| 15 | item_predicate | none |
| 16 | team_color | none |
| 17 | hex_color | none |
| 18 | component | none |
| 19 | style | none |
| 20 | message | none |
| 21 | nbt_compound_tag | none |
| 22 | nbt_tag | none |
| 23 | nbt_path | none |
| 24 | objective | none |
| 25 | objective_criteria | none |
| 26 | operation | none |
| 27 | particle | none |
| 28 | angle | none |
| 29 | rotation | none |
| 30 | scoreboard_slot | none |
| 31 | score_holder | Byte flags: 0x01 allows multiple |
| 32 | swizzle | none |
| 33 | team | none |
| 34 | item_slot | none |
| 35 | item_slots | none |
| 36 | resource_location | none |
| 37 | function | none |
| 38 | entity_anchor | none |
| 39 | int_range | none |
| 40 | float_range | none |
| 41 | dimension | none |
| 42 | gamemode | none |
| 43 | time | Int minimum |
| 44 | resource_or_tag | Identifier: registry key (name of the registry) |
| 45 | resource_or_tag_key | Identifier: registry key |
| 46 | resource | Identifier: registry key |
| 47 | resource_key | Identifier: registry key |
| 48 | resource_selector | Identifier: registry key |
| 49 | template_mirror | none |
| 50 | template_rotation | none |
| 51 | heightmap | none |
| 52 | loot_table | none |
| 53 | loot_predicate | none |
| 54 | loot_modifier | none |
| 55 | context_float_provider | none |
| 56 | context_int_provider | none |
| 57 | slot_source | none |
| 58 | dialog | none |
| 59 | feature | none |
| 60 | swing_animation | none |
| 61 | uuid | none |

`NumberRange(T)`: a Byte of flags (0x01 = has minimum, 0x02 = has maximum), then the minimum as T if
0x01 is set, then the maximum as T if 0x02 is set. An absent minimum or maximum means the type's
extreme value. For Float, the encoder sets 0x01 only when the minimum is not −3.4028235e38, and 0x02
only when the maximum is not +3.4028235e38. Double, Int and Long work the same way with their own
extremes.

If a client reads a parser id that is not in its registry, it reads no property bytes for that node.
The argument then has no parser.

## 0x11 Clientbound Container Close (ClientboundContainerClosePacket) — id 17

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | Container ids are VarInts on the wire (`readContainerId`) |

## 0x12 Clientbound Container Set Content (ClientboundContainerSetContentPacket) — id 18

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| State id | VarInt | Revision counter |
| Slots | Prefixed Array of ItemStack | VarInt count, no maximum. Each element uses the optional ItemStack form (an empty slot is allowed). |
| Carried item | ItemStack | Optional form: the stack held on the cursor |

## 0x13 Clientbound Container Set Data (ClientboundContainerSetDataPacket) — id 19

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Property | Short | Property index |
| Value | Short | |

## 0x14 Clientbound Container Set Slot (ClientboundContainerSetSlotPacket) — id 20

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| State id | VarInt | |
| Slot | Short | |
| Item | ItemStack | Optional form |

## 0x15 Clientbound Cookie Request (ClientboundCookieRequestPacket) — id 21

Shared cookie packet. See 03-configuration.md (and 02-handshake-status-login.md) for the layout.

## 0x16 Clientbound Cooldown (ClientboundCooldownPacket) — id 22

| Field | Type | Notes |
|---|---|---|
| Cooldown group | Identifier | |
| Duration | VarInt | In ticks |

## 0x17 Clientbound Custom Chat Completions (ClientboundCustomChatCompletionsPacket) — id 23

| Field | Type | Notes |
|---|---|---|
| Action | VarInt | 0 ADD, 1 REMOVE, 2 SET. Id mapper: out-of-range values map to 0. |
| Entries | Prefixed Array of String(max 32767) | VarInt count, no maximum |

## 0x18 Clientbound Custom Payload (ClientboundCustomPayloadPacket) — id 24

Shared common packet. See 03-configuration.md. The play phase registers it with
`GAMEPLAY_STREAM_CODEC` rather than the configuration codec. Both codecs decode the `minecraft:brand`
payload. Both fall back to an identifier followed by raw remaining bytes (at most 1,048,576) for any
other channel, so the wire layout is the same. The gameplay codec is built from a list that a static
initializer can extend. In this build that initializer adds no channels (inferred: its body is empty).

## 0x19 Clientbound Damage Event (ClientboundDamageEventPacket) — id 25

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | The entity that was damaged |
| Damage type | VarInt | Registry id into the damage type registry (no inline form) |
| Source cause id | VarInt | Entity id + 1. 0 means none. |
| Source direct id | VarInt | Entity id + 1. 0 means none. |
| Source position | Optional Vec3d | Boolean present flag, then three Doubles X, Y, Z |

## 0x1A Clientbound Debug Block Value (ClientboundDebugBlockValuePacket) — id 26

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Update | DebugSubscriptionUpdate | See composite types |

## 0x1B Clientbound Debug Chunk Value (ClientboundDebugChunkValuePacket) — id 27

| Field | Type | Notes |
|---|---|---|
| Chunk position | ChunkPos | Packed Long |
| Update | DebugSubscriptionUpdate | |

## 0x1C Clientbound Debug Entity Value (ClientboundDebugEntityValuePacket) — id 28

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Update | DebugSubscriptionUpdate | |

## 0x1D Clientbound Debug Event (ClientboundDebugEventPacket) — id 29

| Field | Type | Notes |
|---|---|---|
| Event | DebugSubscriptionEvent | See composite types |

## 0x1E Clientbound Debug Sample (ClientboundDebugSamplePacket) — id 30

| Field | Type | Notes |
|---|---|---|
| Sample | Prefixed Array of Long | VarInt count, then Longs (`readLongArray`) |
| Sample type | Enum (VarInt) | 0 TICK_TIME (the only value) |

## 0x1F Clientbound Delete Chat (ClientboundDeleteChatPacket) — id 31

| Field | Type | Notes |
|---|---|---|
| Message signature | PackedMessageSignature | See composite types |

## 0x20 Clientbound Disconnect (ClientboundDisconnectPacket) — id 32

Shared common packet. See 03-configuration.md.

## 0x21 Clientbound Disguised Chat (ClientboundDisguisedChatPacket) — id 33

| Field | Type | Notes |
|---|---|---|
| Message | TextComponent | |
| Chat type | ChatTypeBound | See composite types |

## 0x22 Clientbound Entity Event (ClientboundEntityEventPacket) — id 34

| Field | Type | Notes |
|---|---|---|
| Entity id | Int | A fixed 4-byte Int, not a VarInt |
| Event id | Byte | Entity-specific status code |

## 0x23 Clientbound Entity Position Sync (ClientboundEntityPositionSyncPacket) — id 35

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Position | PositionPath | Absolute position, or a path of timed steps (see composite types) |
| Yaw (yRot) | Float | Degrees, full float |
| Pitch (xRot) | Float | Degrees, full float |
| On ground | Boolean | |

## 0x24 Clientbound Explode (ClientboundExplodePacket) — id 36

| Field | Type | Notes |
|---|---|---|
| Center | Vec3d | Three Doubles |
| Radius | Float | |
| Block count | Int | Fixed 4-byte Int |
| Player knockback | Optional Vec3d | Boolean present flag, then three Doubles |
| Explosion particle | Particle | See composite types |
| Explosion sound | Holder<sound_event> | Inline layout: SoundEventInline |
| Block particles | Prefixed Array of WeightedExplosionParticle | VarInt count, no maximum |
| Play sound | Boolean | |

`WeightedExplosionParticle`: Particle; Float scaling; Float speed; VarInt weight. The first three
fields are the `ExplosionParticleInfo`. The weight is appended by the weighted-list codec.

## 0x25 Clientbound Add Transient Block (ClientboundAddTransientBlockPacket) — id 37

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Block state | VarInt | Global block state id |

## 0x26 Clientbound Forget Level Chunk (ClientboundForgetLevelChunkPacket) — id 38

| Field | Type | Notes |
|---|---|---|
| Chunk position | ChunkPos | Packed Long |

## 0x27 Clientbound Game Event (ClientboundGameEventPacket) — id 39

| Field | Type | Notes |
|---|---|---|
| Event | UByte | Event type id (table below). The client looks it up in a map; unknown ids yield no event. |
| Value | Float | Event parameter |

| Id | Event |
|---|---|
| 0 | NO_RESPAWN_BLOCK_AVAILABLE |
| 1 | START_RAINING |
| 2 | STOP_RAINING |
| 3 | CHANGE_GAME_MODE (value = game mode id) |
| 4 | WIN_GAME |
| 5 | DEMO_EVENT |
| 6 | PLAY_ARROW_HIT_SOUND |
| 7 | RAIN_LEVEL_CHANGE |
| 8 | THUNDER_LEVEL_CHANGE |
| 9 | PUFFER_FISH_STING |
| 10 | GUARDIAN_ELDER_EFFECT |
| 11 | IMMEDIATE_RESPAWN |
| 12 | LIMITED_CRAFTING |
| 13 | LEVEL_CHUNKS_LOAD_START |

## 0x28 Clientbound Game Rule Values (ClientboundGameRuleValuesPacket) — id 40

| Field | Type | Notes |
|---|---|---|
| Count | VarInt | No maximum |
| Entries | Count × (Identifier, String(max 32767)) | Key: a game rule resource key (identifier into the game rule registry). Value: the rule's value as a string. |

## 0x29 Clientbound Game Test Highlight Pos (ClientboundGameTestHighlightPosPacket) — id 41

| Field | Type | Notes |
|---|---|---|
| Absolute position | Position | |
| Relative position | Position | |

## 0x2A Clientbound Mount Screen Open (ClientboundMountScreenOpenPacket) — id 42

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Inventory columns | VarInt | |
| Entity id | Int | Fixed 4-byte Int |

## 0x2B Clientbound Hurt Animation (ClientboundHurtAnimationPacket) — id 43

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Yaw | Float | Direction the hit came from |

## 0x2C Clientbound Initialize Border (ClientboundInitializeBorderPacket) — id 44

| Field | Type | Notes |
|---|---|---|
| Center X | Double | |
| Center Z | Double | |
| Old size | Double | |
| New size | Double | |
| Lerp time | VarLong | Duration of the size transition |
| Absolute max size | VarInt | |
| Warning blocks | VarInt | |
| Warning time | VarInt | |

## 0x2D Clientbound Keep Alive (ClientboundKeepAlivePacket) — id 45

Shared common packet. See 03-configuration.md.

## 0x2E Clientbound Level Chunk With Light (ClientboundLevelChunkWithLightPacket) — id 46

| Field | Type | Notes |
|---|---|---|
| Chunk X | Int | Fixed 4-byte Int (unlike Light Update, which uses VarInt) |
| Chunk Z | Int | Fixed 4-byte Int |
| Chunk data | ChunkData | Heightmaps, section buffer and block entities. Layout in 06-chunk-format.md. |
| Light data | LightData | Sky/block light masks and arrays. Layout in 06-chunk-format.md. |

At the top level, `ChunkData` is: a heightmap map (VarInt count; each entry is a heightmap type and
a Prefixed Array of Long), then a ByteArray(VarInt len, max 2,097,152) section buffer, then a
Prefixed Array of block entity entries. `LightData` is: four BitSets (sky mask, block mask, empty
sky mask, empty block mask), then a Prefixed Array of sky light arrays, then a Prefixed Array of
block light arrays. Each array is a ByteArray(VarInt len) of at most 2048 bytes. The internals of
each part are in 06-chunk-format.md.

## 0x2F Clientbound Level Event (ClientboundLevelEventPacket) — id 47

| Field | Type | Notes |
|---|---|---|
| Event type | Int | Fixed 4-byte Int, level event id |
| Location | Position | |
| Data | Int | Event-specific data |
| Global | Boolean | When true, the event plays regardless of distance |

## 0x30 Clientbound Level Particles (ClientboundLevelParticlesPacket) — id 48

| Field | Type | Notes |
|---|---|---|
| Particle | Particle | Type id plus type-specific data (see composite types) |
| Override limiter | Boolean | |
| Always show | Boolean | |
| X | Double | |
| Y | Double | |
| Z | Double | |
| X distance | Float | Spread |
| Y distance | Float | |
| Z distance | Float | |
| X max speed | Float | |
| Y max speed | Float | |
| Z max speed | Float | |
| Count | VarInt | |
| Randomization | VarInt | 0 DEFAULT, 1 ALTERNATIVE, 2 ALTERNATIVE_WITH_SPEED. Out-of-range values map to 0. |

The particle data comes first, before the coordinates.

## 0x31 Clientbound Light Update (ClientboundLightUpdatePacket) — id 49

| Field | Type | Notes |
|---|---|---|
| Chunk X | VarInt | |
| Chunk Z | VarInt | |
| Light data | LightData | Same structure as in Level Chunk With Light. See 06-chunk-format.md. |

## 0x32 Clientbound Login (ClientboundLoginPacket) — id 50

| Field | Type | Notes |
|---|---|---|
| Entity id | Int | Fixed 4-byte Int: the player's network entity id |
| Hardcore | Boolean | |
| Dimension names | Prefixed Array of Identifier | VarInt count, no maximum. Keys in the dimension (level) registry. |
| Max players | VarInt | |
| View distance | VarInt | Chunk radius |
| Simulation distance | VarInt | |
| Reduced debug info | Boolean | |
| Show death screen | Boolean | |
| Limited crafting | Boolean | |
| Spawn info | CommonPlayerSpawnInfo | See composite types |
| Online mode | Boolean | |
| Enforces secure chat | Boolean | |

## 0x33 Clientbound Low Disk Space Warning (ClientboundLowDiskSpaceWarningPacket) — id 51

No fields. This is a singleton.

## 0x34 Clientbound Map Item Data (ClientboundMapItemDataPacket) — id 52

| Field | Type | Notes |
|---|---|---|
| Map id | VarInt | |
| Scale | Byte | |
| Locked | Boolean | |
| Decorations | Optional Prefixed Array of MapDecoration | Boolean present flag, then a VarInt count and the entries |
| Color patch | MapPatch | Has its own presence encoding (see composite types) |

## 0x35 Clientbound Merchant Offers (ClientboundMerchantOffersPacket) — id 53

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Offers | Prefixed Array of MerchantOffer | VarInt count, no maximum |
| Villager level | VarInt | |
| Villager XP | VarInt | |
| Show progress | Boolean | |
| Can restock | Boolean | |

## 0x36 Clientbound Move Entity Pos (ClientboundMoveEntityPacket$Pos) — id 54

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Properties | VarInt | Bit 0 = on ground. Bits 1 and up (value shifted right by 1) = step count. |
| Delta | VecDelta | Read using the step count from Properties (see composite types) |

## 0x37 Clientbound Move Entity Pos Rot (ClientboundMoveEntityPacket$PosRot) — id 55

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Properties | VarInt | As in Move Entity Pos |
| Delta | VecDelta | |
| Yaw | Angle | |
| Pitch | Angle | |

## 0x38 Clientbound Move Minecart Along Track (ClientboundMoveMinecartPacket) — id 56

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Lerp steps | Prefixed Array of MinecartStep | VarInt count, no maximum |

## 0x39 Clientbound Move Entity Rot (ClientboundMoveEntityPacket$Rot) — id 57

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| On ground | Boolean | Note the order: the on-ground flag comes before the angles |
| Yaw | Angle | |
| Pitch | Angle | |

## 0x3A Clientbound Move Vehicle (ClientboundMoveVehiclePacket) — id 58

| Field | Type | Notes |
|---|---|---|
| Position | Vec3d | Three Doubles |
| Yaw | Float | |
| Pitch | Float | |

## 0x3B Clientbound Open Book (ClientboundOpenBookPacket) — id 59

| Field | Type | Notes |
|---|---|---|
| Hand | VarInt | 0 MAIN_HAND, 1 OFF_HAND. Out-of-range values map to 0. |

## 0x3C Clientbound Open Screen (ClientboundOpenScreenPacket) — id 60

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Menu type | VarInt | Registry id into the menu registry |
| Title | TextComponent | |

## 0x3D Clientbound Open Sign Editor (ClientboundOpenSignEditorPacket) — id 61

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Side | VarInt | 0 BACK, 1 FRONT (`SignTextSlot`). Out-of-range values map to 0. |

This is a change from older protocols, where this field was a Boolean "is front text". It is now a
VarInt enum, and its ordinal 0 means BACK.

## 0x3E Clientbound Ping (ClientboundPingPacket) — id 62

Shared common packet. See 03-configuration.md.

## 0x3F Clientbound Pong Response (ClientboundPongResponsePacket) — id 63

This is the ping-protocol packet that is also used in the status phase.

| Field | Type | Notes |
|---|---|---|
| Time | Long | Echoes the value from the serverbound ping request |

## 0x40 Clientbound Place Ghost Recipe (ClientboundPlaceGhostRecipePacket) — id 64

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Recipe display | RecipeDisplay | See composite types |

## 0x41 Clientbound Player Abilities (ClientboundPlayerAbilitiesPacket) — id 65

| Field | Type | Notes |
|---|---|---|
| Flags | Byte | 0x01 invulnerable, 0x02 flying, 0x04 can fly, 0x08 instant build (creative) |
| Flying speed | Float | |
| Walking speed | Float | |

## 0x42 Clientbound Player Chat (ClientboundPlayerChatPacket) — id 66

| Field | Type | Notes |
|---|---|---|
| Global index | VarInt | |
| Sender | UUID | |
| Index | VarInt | Per-sender message index |
| Signature | Optional MessageSignature | Boolean present flag, then exactly 256 bytes |
| Body | SignedMessageBodyPacked | See composite types |
| Unsigned content | Optional TextComponent | |
| Filter mask | FilterMask | |
| Chat type | ChatTypeBound | |

## 0x43 Clientbound Player Combat End (ClientboundPlayerCombatEndPacket) — id 67

| Field | Type | Notes |
|---|---|---|
| Duration | VarInt | |

## 0x44 Clientbound Player Combat Enter (ClientboundPlayerCombatEnterPacket) — id 68

No fields. This is a singleton.

## 0x45 Clientbound Player Combat Kill (ClientboundPlayerCombatKillPacket) — id 69

| Field | Type | Notes |
|---|---|---|
| Player id | VarInt | Entity id of the player who died |
| Message | TextComponent | Death message |

## 0x46 Clientbound Player Info Remove (ClientboundPlayerInfoRemovePacket) — id 70

| Field | Type | Notes |
|---|---|---|
| Profile ids | Prefixed Array of UUID | VarInt count, no maximum |

## 0x47 Clientbound Player Info Update (ClientboundPlayerInfoUpdatePacket) — id 71

| Field | Type | Notes |
|---|---|---|
| Actions | FixedBitSet(8) | Exactly 1 byte (ceil(8/8)). Bit *n* set means action with ordinal *n* is present. |
| Entries | Prefixed Array of PlayerInfoEntry | VarInt count, no maximum |

`PlayerInfoEntry` is a UUID (profile id) followed by one block per action whose bit is set, in
ascending ordinal order:

| Ordinal | Action | Fields written for this action |
|---|---|---|
| 0 | ADD_PLAYER | String(max 16) name; GameProfileProperties |
| 1 | INITIALIZE_CHAT | Boolean present; if present, RemoteChatSessionData |
| 2 | UPDATE_GAME_MODE | VarInt game mode (0 SURVIVAL, 1 CREATIVE, 2 ADVENTURE, 3 SPECTATOR; out of range maps to 0) |
| 3 | UPDATE_LISTED | Boolean |
| 4 | UPDATE_LATENCY | VarInt latency in milliseconds |
| 5 | UPDATE_DISPLAY_NAME | Boolean present; if present, TextComponent |
| 6 | UPDATE_LIST_ORDER | VarInt |
| 7 | UPDATE_HAT | Boolean show hat |

The bit set is read as raw bytes in little-endian bit order, which is Java `BitSet.valueOf` on a
byte array: bit 0 is the lowest bit of the first byte.

---

## Composite types introduced here

Types already defined in 00-data-types.md (ItemStack, data components, TextComponent, NBT, Position,
Angle, BitSet, UUID, Identifier) are not repeated here.

### Vec3d
Three Doubles: X, Y, Z (`Vec3.STREAM_CODEC`).

### ChunkPos
One Long. The chunk X is in the low 32 bits and the chunk Z is in the high 32 bits:
value = (X & 0xFFFFFFFF) | ((Z & 0xFFFFFFFF) << 32).

### LpVec3
Defined in [00-data-types.md §4.6](00-data-types.md#46-lpvec3-low-precision-velocity-vector).

### VecDelta (used by Move Entity Pos / PosRot)
The step count *k* comes from the Properties VarInt that precedes it.

- If *k* = 0 (linear form): three Shorts dX, dY, dZ.
- If *k* > 0 (stepped form): *k* repetitions of {VarInt ticks; Short dX; Short dY; Short dZ}. The
  decoder rejects the packet if *k* > (readable bytes ÷ 7).

Each Short is a delta in units of 1/4096 block. It is computed as round(new × 4096) − round(base ×
4096) per axis. Here "base" is the last position known to the client for that entity. In the
stepped form, each step's delta is relative to the previous step's decoded position (the base
advances per step).

### PositionPath (used by Entity Position Sync)
| Field | Type | Notes |
|---|---|---|
| Kind | VarInt | 0 LINEAR, 1 STEPPED. Out-of-range values map to 0. |
| LINEAR payload | Vec3d | End position |
| STEPPED payload | Prefixed Array of PositionStep | VarInt count. The end position is the last step's position. |

`PositionStep`: Vec3d position; VarInt tick offset.

### MinecartStep
Vec3d position; Vec3d movement; Angle yaw; Angle pitch; Float weight. The yaw and pitch use the
rotation-byte codec, which is the Angle type.

### Stat
VarInt stat type (registry id into the stat type registry), then a VarInt registry id into the
registry that this stat type ranges over. For example, an item-based stat type indexes the item
registry, and the "custom" stat type indexes the custom stat registry.

### PackedMessageSignature
VarInt *n*. If *n* = 0, a full MessageSignature (exactly 256 raw bytes) follows. Otherwise the
signature is a reference to cache index *n* − 1 and nothing follows.

### MessageSignature
Exactly 256 bytes, with no length prefix.

### SignedMessageBodyPacked
| Field | Type | Notes |
|---|---|---|
| Content | String(max 256) | |
| Timestamp | Long | Epoch milliseconds (Instant) |
| Salt | Long | |
| Last seen | Prefixed Array of PackedMessageSignature | VarInt count, maximum 20 |

### FilterMask
| Field | Type | Notes |
|---|---|---|
| Kind | VarInt | 0 PASS_THROUGH, 1 FULLY_FILTERED, 2 PARTIALLY_FILTERED |
| Mask | ByteBitSet | Present only for PARTIALLY_FILTERED |

### ChatTypeBound
| Field | Type | Notes |
|---|---|---|
| Chat type | Holder<chat_type> | Inline layout: ChatTypeInline |
| Sender name | TextComponent | |
| Target name | Optional TextComponent | |

`ChatTypeInline`: ChatTypeDecoration chat; ChatTypeDecoration narration.

`ChatTypeDecoration`:
- String(max 32767) translation key.
- Prefixed Array of VarInt parameters: 0 SENDER, 1 TARGET, 2 CONTENT; out-of-range values map to 0.
- Style: the style is encoded through the trusted registry-aware codec, the same NBT-based mechanism
  as TextComponent. See 00-data-types.md.

### Particle
| Field | Type | Notes |
|---|---|---|
| Particle type | VarInt | Registry id into the particle type registry |
| Options | varies | Selected by the particle type |

Particle types not listed below use the simple type and carry no option bytes. The types with
options are listed by identifier. Their numeric ids follow from the registry order (04-registry-sync.md).

| Particle type(s) | Option layout |
|---|---|
| block, block_marker, falling_dust, dust_pillar, block_crumble | VarInt global block state id |
| dust | Int color (RGB), Float scale |
| dust_color_transition | Int from-color, Int to-color, Float scale |
| effect, instant_effect | Int color, Float power |
| entity_effect, tinted_leaves, flash | Int color (ARGB) |
| dragon_breath | Float power |
| sculk_charge | Float roll |
| shriek | VarInt delay |
| item | ItemStackTemplate |
| vibration | PositionSource destination; VarInt arrival ticks |
| trail | Vec3d target; Int color; VarInt duration |
| geyser, geyser_plume | Int water blocks |
| geyser_base, geyser_poof | Int water blocks; Float burst impulse base |

### PositionSource
VarInt source type (registry id into the position source type registry, where 0 = block and
1 = entity in registration order), then:
- block: Position.
- entity: VarInt entity id; Float y offset.

### ItemStackTemplate
VarInt item (registry id into the item registry); VarInt count; DataComponentPatch (see
00-data-types.md).

### SoundEventInline
Identifier sound id; Optional Float fixed range (Boolean present flag, then Float).

### CommonPlayerSpawnInfo
This type is shared with the Respawn packet in 05b.

| Field | Type | Notes |
|---|---|---|
| Dimension type | VarInt | Registry id into the dimension type registry (no inline form) |
| Dimension | Identifier | Key in the dimension (level) registry |
| Hashed seed | Long | |
| Game mode | VarInt | 0 SURVIVAL, 1 CREATIVE, 2 ADVENTURE, 3 SPECTATOR |
| Previous game mode | OptionalVarInt | 0 = none, otherwise game mode id + 1 |
| Is debug | Boolean | |
| Is flat | Boolean | |
| Last death location | Optional GlobalPos | Boolean present flag, then GlobalPos |
| Portal cooldown | VarInt | |
| Sea level | VarInt | |

`GlobalPos`: Identifier dimension; Position.

`OptionalVarInt`: a VarInt where 0 means absent and *n* > 0 means the value *n* − 1.

### MapDecoration
| Field | Type | Notes |
|---|---|---|
| Type | VarInt | Registry id into the map decoration type registry (no inline form) |
| X | Byte | |
| Y | Byte | |
| Rotation | Byte | |
| Name | Optional TextComponent | Uses the non-trusted optional component codec. The wire layout is identical. |

### MapPatch
| Field | Type | Notes |
|---|---|---|
| Width | UByte | If 0, there is no patch and nothing else follows |
| Height | UByte | Present only if width > 0 |
| Start X | UByte | |
| Start Z (startY) | UByte | |
| Colors | ByteArray(VarInt len) | Map color indices |

### MerchantOffer
| Field | Type | Notes |
|---|---|---|
| Cost A | ItemCost | |
| Result | ItemStack | The non-optional form (must not be empty) |
| Cost B | Optional ItemCost | Boolean present flag, then ItemCost |
| Out of stock | Boolean | |
| Uses | Int | |
| Max uses | Int | |
| XP | Int | |
| Special price diff | Int | |
| Price multiplier | Float | |
| Demand | Int | |

`ItemCost`:
- VarInt item (registry id into the item registry).
- VarInt count.
- DataComponentExactPredicate: a Prefixed Array of typed data components, each a component type id
  followed by its value, as in 00-data-types.md.

### RecipeDisplay
A VarInt recipe display type (registry id into the recipe display registry, in registration order
below), followed by that type's fields.

| Id | Type | Fields |
|---|---|---|
| 0 | crafting_shapeless | Prefixed Array of SlotDisplay ingredients; SlotDisplay result; SlotDisplay crafting station |
| 1 | crafting_shaped | VarInt width; VarInt height; Prefixed Array of SlotDisplay ingredients; SlotDisplay result; SlotDisplay crafting station |
| 2 | furnace | SlotDisplay ingredient; SlotDisplay fuel; SlotDisplay result; SlotDisplay crafting station; VarInt duration; Float experience |
| 3 | stonecutter | SlotDisplay input; SlotDisplay result; SlotDisplay crafting station |
| 4 | smithing | SlotDisplay template; SlotDisplay base; SlotDisplay addition; SlotDisplay result; SlotDisplay crafting station |

### SlotDisplay (recursive)
A VarInt slot display type (registry id into the slot display registry, in registration order
below), followed by that type's fields.

| Id | Type | Fields |
|---|---|---|
| 0 | empty | (none) |
| 1 | any_fuel | (none) |
| 2 | with_any_potion | SlotDisplay display |
| 3 | only_with_component | SlotDisplay source; VarInt data component type (registry id) |
| 4 | item | VarInt item (registry id into the item registry) |
| 5 | item_stack | ItemStackTemplate |
| 6 | tag | HolderSet<item> |
| 7 | dyed | SlotDisplay dye; SlotDisplay target |
| 8 | smithing_trim | SlotDisplay base; SlotDisplay material; Holder<trim_pattern> pattern (inline: Identifier asset id; TextComponent description; Boolean decal) |
| 9 | with_remainder | SlotDisplay input; SlotDisplay remainder |
| 10 | composite | Prefixed Array of SlotDisplay |

`HolderSet<R>`: VarInt *n*. If *n* = 0, an Identifier follows and names a tag of registry R.
Otherwise *n* − 1 VarInt registry ids follow.

### DebugSubscriptionUpdate / DebugSubscriptionEvent
- Update: VarInt subscription type (registry id into the debug subscription registry), then
  Optional value (Boolean present flag, then the value). An absent value clears the entry.
- Event: VarInt subscription type, then the value with no presence flag.

The value layout is defined separately for each debug subscription type. These packets are sent
only to clients that ask for debug subscriptions, so a server that never sends them does not need
the value layouts (see Open questions).

### GameProfileProperties
| Field | Type | Notes |
|---|---|---|
| Count | VarInt | Maximum 16 |
| Properties | Count × Property | |

`Property`: String(max 64) name; String(max 32767) value; Optional String(max 1024) signature
(Boolean present flag, then the String).

### RemoteChatSessionData
| Field | Type | Notes |
|---|---|---|
| Session id | UUID | |
| Expires at | Long | Epoch milliseconds |
| Public key | ByteArray(VarInt len) | Maximum 512 bytes. An encoded RSA public key (X.509 form, inferred from `Crypt.byteToPublicKey`). |
| Key signature | ByteArray(VarInt len) | Maximum 4096 bytes |

### FixedBitSet(n)
ceil(n/8) raw bytes, with no length prefix. Bit *i* is bit (i mod 8) of byte (i div 8).

---

## Open questions

1. **Brigadier string parser ordinals.** The `brigadier:string` property enum (`StringArgumentType.StringType`) comes from the Brigadier library. That library is not in the unpacked classes. The ordinals 0 SINGLE_WORD, 1 QUOTABLE_PHRASE, 2 GREEDY_PHRASE are inferred.
2. **Debug subscription values.** This file does not enumerate the value layouts of each debug subscription type (`DebugSubscriptions`) used by packets 0x1A–0x1D. These are debug-only. Someone needs to decide whether they belong in this specification.
3. **Animate action ids.** Only ids 0–2 are named in `ClientboundAnimatePacket`. Other action values (for example, arm swings) are interpreted in the client handler, which was not traced.
4. **Bundle semantics.** The handling of the bundle delimiter is inferred from the builder and the `BundlerInfo` limit (4096). The client-side bundling code path was not traced in detail.
5. **Custom payload channel list in play.** `ClientboundCustomPayloadPacket.GAMEPLAY_STREAM_CODEC` uses a list that a static lambda can extend. In this build it appears to add nothing beyond `minecraft:brand` (inferred). This should be confirmed if exact channel handling matters.
6. **Movement delta base.** The rule that the VecDelta base is the client's last known entity position, and that the base advances per step, is inferred from `VecDeltaCodec` and `VecDelta.Stepped.decode`. The server-side choice between the linear form, the stepped form, and Entity Position Sync was not traced.
