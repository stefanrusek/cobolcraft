# Play phase: serverbound packets (ids 0–68)

This document covers every packet the client sends to the server in the **play** phase. Packet ids follow
registration order in `net.minecraft.network.protocol.game.GameProtocols` (the serverbound template,
`lambda$static$1`). That method registers 69 packets in a straight line with no conditional registration, so the ids
are fixed. Two entries have context-dependent decoders (ids 0x0F and 0x39). Their sections describe them.

Packets from the shared "common" package (`net.minecraft.network.protocol.common.*`) have the same layout as in
the configuration phase. Their entries here give only the id and point to [03-configuration.md](03-configuration.md).

Unless a section says otherwise:

- "Enum X" is a VarInt holding the constant's ordinal. Where the codec is an id mapper (`ByteBufCodecs.idMapper`),
  the id equals the ordinal for every enum in this file. The id mapper's out-of-range behaviour is given with the enum.
- "Position" is the packed-Long block position described in [00-data-types.md](00-data-types.md).
- "String(max N)" limits the length in characters. A plain `readUtf()` with no argument uses max 32767.
- A "Container id" is a VarInt (`FriendlyByteBuf.readContainerId` reads a VarInt).
- A "Prefixed Array" with a stated maximum makes the decoder reject a count above that maximum.

---

## 0x00 (0) Serverbound Accept Teleportation (ServerboundAcceptTeleportationPacket)

This packet confirms a clientbound Player Position (teleport) packet. The client sends it after applying the
teleport and includes the position and rotation that resulted.

| Field | Type | Notes |
|---|---|---|
| Teleport id | VarInt | Echo of the id in the clientbound Player Position packet. |
| X | Double | Player's absolute position after the teleport was applied. |
| Y | Double | |
| Z | Double | |
| Yaw (yRot) | Float | Degrees. |
| Pitch (xRot) | Float | Degrees. |

On a matching id, the server snaps the player to its own awaited position and then runs its normal movement handling
with the values in this packet. If X, Y, Z, yaw or pitch is NaN or infinite, or out of range, the server disconnects with
`multiplayer.disconnect.invalid_player_movement`. The range test (`containsInvalidValues`) is assumed to be the same
one the movement packets use (inferred).

## 0x01 (1) Serverbound Attack (ServerboundAttackPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | Network entity id of the entity being attacked. |

## 0x02 (2) Serverbound Block Entity Tag Query (ServerboundBlockEntityTagQueryPacket)

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | Echoed in the clientbound Tag Query response. |
| Location | Position | Block entity to query. |

## 0x03 (3) Serverbound Bundle Item Selected (ServerboundSelectBundleItemPacket)

| Field | Type | Notes |
|---|---|---|
| Slot id | VarInt | Inventory slot that holds the bundle. |
| Selected item index | VarInt | Must be ≥ 0, or exactly −1 (no selection). Any other negative value makes the constructor throw, and the packet fails to decode. |

## 0x04 (4) Serverbound Change Difficulty (ServerboundChangeDifficultyPacket)

| Field | Type | Notes |
|---|---|---|
| Difficulty | Enum Difficulty (VarInt id) | 0 peaceful, 1 easy, 2 normal, 3 hard. The id mapper **wraps** out-of-range values (modulo). |

## 0x05 (5) Serverbound Change Game Mode (ServerboundChangeGameModePacket)

| Field | Type | Notes |
|---|---|---|
| Game mode | Enum GameType (VarInt id) | 0 survival, 1 creative, 2 adventure, 3 spectator. An out-of-range value maps to 0. |

## 0x06 (6) Serverbound Chat Ack (ServerboundChatAckPacket)

| Field | Type | Notes |
|---|---|---|
| Offset | VarInt | Number of received signed chat messages being acknowledged since the last acknowledgement. See "Signed chat". |

The vanilla client sends this packet only while its pending-acknowledgement offset is above 64, so that the server's
tracked list does not grow without bound. The client also sends it on entering configuration. If the server rejects the
offset (negative, or larger than the number of tracked messages), it logs an error and disconnects.

## 0x07 (7) Serverbound Chat Command (ServerboundChatCommandPacket)

This is an unsigned command, the form used when no argument needs a signature.

| Field | Type | Notes |
|---|---|---|
| Command | String(max 32767) | Command text without the leading `/`. |

## 0x08 (8) Serverbound Chat Command Signed (ServerboundChatCommandSignedPacket)

| Field | Type | Notes |
|---|---|---|
| Command | String(max 32767) | Without the leading `/`. Uses `ByteBufCodecs.STRING_UTF8`. |
| Timestamp | Long | `Instant` as milliseconds since the Unix epoch. |
| Salt | Long | Random salt used in each argument signature. |
| Argument signatures | ArgumentSignatures | See "Composite types introduced here". |
| Last seen messages | LastSeenMessagesUpdate | See "Composite types introduced here". |

## 0x09 (9) Serverbound Chat (ServerboundChatPacket)

| Field | Type | Notes |
|---|---|---|
| Message | String(max 256) | Chat text. |
| Timestamp | Long | `Instant` as milliseconds since the Unix epoch. |
| Salt | Long | |
| Signature | Optional MessageSignature | Boolean present flag, then exactly 256 raw bytes. Absent for unsigned chat. |
| Last seen messages | LastSeenMessagesUpdate | |

## 0x0A (10) Serverbound Chat Session Update (ServerboundChatSessionUpdatePacket)

This packet announces the client's chat-signing session and public key.

| Field | Type | Notes |
|---|---|---|
| Session id | UUID | Random per session. The client generates it with `UUID.randomUUID`. |
| Public key | ProfilePublicKeyData | See "Composite types introduced here". |

## 0x0B (11) Serverbound Chunk Batch Received (ServerboundChunkBatchReceivedPacket)

This packet acknowledges a clientbound Chunk Batch Finished packet.

| Field | Type | Notes |
|---|---|---|
| Desired chunks per tick | Float | Client's requested chunk send rate. The server clamps it to 0.01–64.0, and NaN becomes 0.01. |

The server's chunk sender starts at 9.0 chunks/tick and allows **one** unacknowledged batch. After the first
acknowledgement, the allowance rises to 10 unacknowledged batches. If the client never acknowledges, the server stops
sending chunks after the first batch.

## 0x0C (12) Serverbound Client Command (ServerboundClientCommandPacket)

| Field | Type | Notes |
|---|---|---|
| Action | Enum (VarInt ordinal) | 0 `PERFORM_RESPAWN`, 1 `REQUEST_STATS`, 2 `REQUEST_GAMERULE_VALUES`. |

## 0x0D (13) Serverbound Client Tick End (ServerboundClientTickEndPacket)

This packet has no fields (a unit codec). The vanilla client sends it at the end of every client tick while connected
and not paused (`Minecraft.tick`). The server uses it to close its per-tick movement bookkeeping: it clears the
"received movement / position this tick" flags, and if no movement arrived it sets the player's known movement to
zero.

## 0x0E (14) Serverbound Client Information (ServerboundClientInformationPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x0F (15) Serverbound Command Suggestion (ServerboundCommandSuggestionPacket)

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | Echoed in the clientbound Command Suggestions response. |
| Text | String(max 32500 or 256) | Partial command text. |

The codec depends on the context (`GameProtocols.dispatchCodec`). If the server context allows the player to use
command blocks, the decoder accepts up to 32500 characters. Otherwise it uses a "chat-only" decoder limited to
256 characters, and a decode failure raises `SkipPacketDecoderException`, so the packet is **dropped silently** rather
than disconnecting. The encoder always uses the 32500 limit.

## 0x10 (16) Serverbound Configuration Acknowledged (ServerboundConfigurationAcknowledgedPacket)

This packet has no fields (a unit codec). The client sends it in reply to the clientbound Start Configuration packet.
After sending it, the client switches its outbound protocol to configuration (see [01-transport.md](01-transport.md)).

## 0x11 (17) Serverbound Container Button Click (ServerboundContainerButtonClickPacket)

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Button id | VarInt | Meaning depends on the open menu. |

## 0x12 (18) Serverbound Container Click (ServerboundContainerClickPacket)

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| State id | VarInt | Last state id the client received for this container. |
| Slot | Short | Clicked slot index (signed 16-bit; −999 means a click outside the window: `AbstractContainerMenu.SLOT_CLICKED_OUTSIDE`). |
| Button | Byte | Mouse button or hotbar key, interpreted with the click type. |
| Click type | Enum ContainerInput (VarInt id) | 0 `PICKUP`, 1 `QUICK_MOVE`, 2 `SWAP`, 3 `CLONE`, 4 `THROW`, 5 `QUICK_CRAFT`, 6 `PICKUP_ALL`. An out-of-range value maps to 0. |
| Changed slots | Prefixed Map of Short → HashedStack, max 128 | VarInt count (≤ 128), then that many (slot: Short, predicted contents: HashedStack) pairs. |
| Carried item | HashedStack | Client's predicted cursor stack. |

`HashedStack` is the hashed item-stack form defined in [00-data-types.md](00-data-types.md). The client does not send
full item data here. It sends the item id, the count, and a CRC-style hash of each data component in the patch, so
the server can detect a misprediction. The summary below is for convenience, and the data-types file is normative:

| Part | Type | Notes |
|---|---|---|
| Present | Boolean | False means the empty stack, and nothing follows. |
| Item | VarInt | Item registry id (`holderRegistry(ITEM)`: registry id only, with no inline form). |
| Count | VarInt | |
| Added components | Prefixed Array (max 256) of (VarInt, Int) | Data-component-type registry id and 32-bit hash of that component's value. |
| Removed components | Prefixed Array (max 256) of VarInt | Data-component-type registry ids. |

## 0x13 (19) Serverbound Container Close (ServerboundContainerClosePacket)

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |

## 0x14 (20) Serverbound Container Slot State Changed (ServerboundContainerSlotStateChangedPacket)

| Field | Type | Notes |
|---|---|---|
| Slot id | VarInt | |
| Container id | VarInt | |
| New state | Boolean | Enabled or disabled state of a toggleable slot. |

## 0x15 (21) Serverbound Cookie Response (ServerboundCookieResponsePacket)

This is the cookie packet (package `protocol.cookie`). Its layout is the same as in login and configuration. See
[02-handshake-status-login.md](02-handshake-status-login.md).

| Field | Type | Notes |
|---|---|---|
| Key | Identifier | |
| Payload | Optional ByteArray(VarInt len, max 5120) | Boolean present flag (nullable), then the bytes. |

## 0x16 (22) Serverbound Custom Payload (ServerboundCustomPayloadPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x17 (23) Serverbound Debug Subscription Request (ServerboundDebugSubscriptionRequestPacket)

| Field | Type | Notes |
|---|---|---|
| Subscriptions | Prefixed Array (max 32) of VarInt | Registry ids in the `debug_subscription` registry (`ByteBufCodecs.registry`). Decoded into a set. |

## 0x18 (24) Serverbound Edit Book (ServerboundEditBookPacket)

| Field | Type | Notes |
|---|---|---|
| Slot | VarInt | Inventory slot that holds the book. |
| Pages | Prefixed Array (max 100) of String(max 1024) | |
| Title | Optional String(max 32) | Present when signing the book. |

## 0x19 (25) Serverbound Entity Tag Query (ServerboundEntityTagQueryPacket)

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | |
| Entity id | VarInt | |

## 0x1A (26) Serverbound Interact (ServerboundInteractPacket)

This packet is a use or interaction on an entity. Attacks have their own packet (0x01).

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Hand | Enum InteractionHand (VarInt id) | 0 main hand, 1 off hand. An out-of-range value maps to 0. |
| Location | LpVec3 | Interaction point, encoded with the low-precision vector codec (`Vec3.LP_STREAM_CODEC`). See "Composite types introduced here". |
| Using secondary action | Boolean | Sneak state. |

## 0x1B (27) Serverbound Jigsaw Generate (ServerboundJigsawGeneratePacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Levels | VarInt | |
| Keep jigsaws | Boolean | |

## 0x1C (28) Serverbound Keep Alive (ServerboundKeepAlivePacket)

Common packet. See [03-configuration.md](03-configuration.md). The client must echo the Long id from the clientbound
Keep Alive. See "Minimum required serverbound traffic".

## 0x1D (29) Serverbound Lock Difficulty (ServerboundLockDifficultyPacket)

| Field | Type | Notes |
|---|---|---|
| Locked | Boolean | |

## 0x1E (30) Serverbound Move Player Pos (ServerboundMovePlayerPacket$Pos)

| Field | Type | Notes |
|---|---|---|
| X | Double | Feet position. |
| Y | Double | |
| Z | Double | |
| Flags | UByte | MoveFlags: see below. |

**MoveFlags** (all four move packets): the encoder writes a byte and the decoder reads it as unsigned.

| Bit (mask) | Meaning |
|---|---|
| 0 (0x01) | On ground. |
| 1 (0x02) | Horizontal collision. |
| 2–7 | Not used. The client writes 0, and the decoder ignores them. |

## 0x1F (31) Serverbound Move Player Pos Rot (ServerboundMovePlayerPacket$PosRot)

| Field | Type | Notes |
|---|---|---|
| X | Double | |
| Y | Double | |
| Z | Double | |
| Yaw (yRot) | Float | Degrees. |
| Pitch (xRot) | Float | Degrees. |
| Flags | UByte | MoveFlags. |

## 0x20 (32) Serverbound Move Player Rot (ServerboundMovePlayerPacket$Rot)

| Field | Type | Notes |
|---|---|---|
| Yaw (yRot) | Float | |
| Pitch (xRot) | Float | |
| Flags | UByte | MoveFlags. |

## 0x21 (33) Serverbound Move Player Status Only (ServerboundMovePlayerPacket$StatusOnly)

| Field | Type | Notes |
|---|---|---|
| Flags | UByte | MoveFlags. |

The vanilla client (`LocalPlayer.sendPosition`) picks the variant each tick. It sends a position variant if the
squared distance moved exceeds 2.0E-4 or a 20-tick reminder counter has expired. It sends a rotation variant if yaw
or pitch changed. It sends Status Only if only the flags changed (inferred from the comparisons in that method).

## 0x22 (34) Serverbound Move Vehicle (ServerboundMoveVehiclePacket)

| Field | Type | Notes |
|---|---|---|
| X | Double | `PositionAndRotation`: Vec3 as three Doubles … |
| Y | Double | |
| Z | Double | |
| Yaw | Float | … then yaw … |
| Pitch | Float | … then pitch. |
| On ground | Boolean | |

## 0x23 (35) Serverbound Paddle Boat (ServerboundPaddleBoatPacket)

| Field | Type | Notes |
|---|---|---|
| Left paddle | Boolean | |
| Right paddle | Boolean | |

## 0x24 (36) Serverbound Pick Item From Block (ServerboundPickItemFromBlockPacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Include data | Boolean | |

## 0x25 (37) Serverbound Pick Item From Entity (ServerboundPickItemFromEntityPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Include data | Boolean | |

## 0x26 (38) Serverbound Ping Request (ServerboundPingRequestPacket)

This is the ping packet (package `protocol.ping`), the same packet as in the status phase. See
[02-handshake-status-login.md](02-handshake-status-login.md).

| Field | Type | Notes |
|---|---|---|
| Time | Long | Echoed by the clientbound Pong Response. |

## 0x27 (39) Serverbound Place Recipe (ServerboundPlaceRecipePacket)

| Field | Type | Notes |
|---|---|---|
| Container id | VarInt | |
| Recipe | VarInt | `RecipeDisplayId`: an index the server assigned in its recipe-book packets. |
| Use max items | Boolean | |

## 0x28 (40) Serverbound Player Abilities (ServerboundPlayerAbilitiesPacket)

| Field | Type | Notes |
|---|---|---|
| Flags | Byte | Only bit 0x02 (flying) is written and read. Other bits are ignored. |

## 0x29 (41) Serverbound Player Action (ServerboundPlayerActionPacket)

| Field | Type | Notes |
|---|---|---|
| Action | Enum (VarInt ordinal) | See table below. |
| Location | Position | Target block. The client still sends it for non-block actions. |
| Face | UByte | Direction 3D data value: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east. The decoder takes the absolute value modulo 6. |
| Sequence | VarInt | Block-change sequence number. The server acknowledges it with the clientbound Block Changed Ack. |

| Ordinal | Action |
|---|---|
| 0 | `START_DESTROY_BLOCK` |
| 1 | `CHANGE_DESTROY_DIRECTION` |
| 2 | `ABORT_DESTROY_BLOCK` |
| 3 | `STOP_DESTROY_BLOCK` |
| 4 | `DROP_ALL_ITEMS` |
| 5 | `DROP_ITEM` |
| 6 | `RELEASE_USE_ITEM` |
| 7 | `SWAP_ITEM_WITH_OFFHAND` |
| 8 | `STAB` |

## 0x2A (42) Serverbound Player Command (ServerboundPlayerCommandPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | The player's own entity id. |
| Action | Enum (VarInt ordinal) | 0 `STOP_SLEEPING`, 1 `START_SPRINTING`, 2 `STOP_SPRINTING`, 3 `START_RIDING_JUMP`, 4 `STOP_RIDING_JUMP`, 5 `OPEN_INVENTORY`, 6 `START_FALL_FLYING`. |
| Data | VarInt | Extra value. Used with riding jump as jump strength (inferred). Otherwise 0. |

## 0x2B (43) Serverbound Player Input (ServerboundPlayerInputPacket)

| Field | Type | Notes |
|---|---|---|
| Input | Byte | Bit flags. See below. |

| Mask | Key held |
|---|---|
| 0x01 | Forward |
| 0x02 | Backward |
| 0x04 | Left |
| 0x08 | Right |
| 0x10 | Jump |
| 0x20 | Shift (sneak) |
| 0x40 | Sprint |

## 0x2C (44) Serverbound Player Loaded (ServerboundPlayerLoadedPacket)

This packet has no fields (a unit codec). The client sends it once, when its level-load tracker reports the level ready
after joining or respawning (`ClientPacketListener.tick`, then `notifyPlayerLoaded`). See "Minimum required
serverbound traffic".

## 0x2D (45) Serverbound Pong (ServerboundPongPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x2E (46) Serverbound Punch (ServerboundPunchPacket)

This packet has no fields (a unit codec).

## 0x2F (47) Serverbound Recipe Book Change Settings (ServerboundRecipeBookChangeSettingsPacket)

| Field | Type | Notes |
|---|---|---|
| Book type | Enum RecipeBookType (VarInt ordinal) | 0 crafting, 1 furnace, 2 blast furnace, 3 smoker. |
| Is open | Boolean | |
| Is filtering | Boolean | |

## 0x30 (48) Serverbound Recipe Book Seen Recipe (ServerboundRecipeBookSeenRecipePacket)

| Field | Type | Notes |
|---|---|---|
| Recipe | VarInt | `RecipeDisplayId` index. |

## 0x31 (49) Serverbound Rename Item (ServerboundRenameItemPacket)

| Field | Type | Notes |
|---|---|---|
| Name | String(max 32767) | |

## 0x32 (50) Serverbound Resource Pack (ServerboundResourcePackPacket)

Common packet. See [03-configuration.md](03-configuration.md).

## 0x33 (51) Serverbound Seen Advancements (ServerboundSeenAdvancementsPacket)

| Field | Type | Notes |
|---|---|---|
| Action | Enum (VarInt ordinal) | 0 `OPENED_TAB`, 1 `CLOSED_SCREEN`. |
| Tab | Identifier | **Present only when Action = 0 (`OPENED_TAB`).** |

## 0x34 (52) Serverbound Select Trade (ServerboundSelectTradePacket)

| Field | Type | Notes |
|---|---|---|
| Selected offer | VarInt | Index into the merchant's offer list. |

## 0x35 (53) Serverbound Set Beacon (ServerboundSetBeaconPacket)

| Field | Type | Notes |
|---|---|---|
| Primary effect | Optional VarInt | Boolean present flag, then the mob-effect registry id (`holderRegistry(MOB_EFFECT)`: registry id only). |
| Secondary effect | Optional VarInt | Same encoding. |

## 0x36 (54) Serverbound Set Carried Item (ServerboundSetCarriedItemPacket)

| Field | Type | Notes |
|---|---|---|
| Slot | Short | Selected hotbar slot. |

## 0x37 (55) Serverbound Set Command Block (ServerboundSetCommandBlockPacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Command | String(max 32767) | |
| Mode | Enum (VarInt ordinal) | 0 `SEQUENCE`, 1 `AUTO`, 2 `REDSTONE`. |
| Flags | Byte | 0x01 track output, 0x02 conditional, 0x04 automatic. |

## 0x38 (56) Serverbound Set Command Minecart (ServerboundSetCommandMinecartPacket)

| Field | Type | Notes |
|---|---|---|
| Entity id | VarInt | |
| Command | String(max 32767) | |
| Track output | Boolean | |

## 0x39 (57) Serverbound Set Creative Mode Slot (ServerboundSetCreativeModeSlotPacket)

| Field | Type | Notes |
|---|---|---|
| Slot | Short | |
| Item | ItemStack (optional form) | `ItemStack.OPTIONAL_UNTRUSTED_STREAM_CODEC` wrapped in `validatedStreamCodec`. A count of 0 means empty. See [00-data-types.md](00-data-types.md). |

This packet is registered with the `HAS_INFINITE_MATERIALS` codec modifier (`GameProtocols$1`). If the server-side
context reports that the player lacks infinite materials, decoding throws `SkipPacketDecoderException` and the
packet is **dropped** without disconnecting. On the encoding side, the matching `SkipPacketEncoderException` means
the client does not send it at all.

## 0x3A (58) Serverbound Set Game Rule (ServerboundSetGameRulePacket)

| Field | Type | Notes |
|---|---|---|
| Entries | Prefixed Array of GameRuleEntry | No explicit maximum. |

GameRuleEntry:

| Field | Type | Notes |
|---|---|---|
| Rule | Identifier | Resource key in the `game_rule` registry (`ResourceKey.streamCodec`: the Identifier only). |
| Value | String(max 32767) | Value as text. |

## 0x3B (59) Serverbound Set Jigsaw Block (ServerboundSetJigsawBlockPacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Name | Identifier | |
| Target | Identifier | |
| Pool | Identifier | |
| Final state | String(max 32767) | |
| Joint type | String(max 32767) | Serialized name, `rollable` or `aligned`. An unknown name decodes as `aligned`. |
| Selection priority | VarInt | |
| Placement priority | VarInt | |

## 0x3C (60) Serverbound Set Structure Block (ServerboundSetStructureBlockPacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Update type | Enum (VarInt ordinal) | 0 `UPDATE_DATA`, 1 `SAVE_AREA`, 2 `LOAD_AREA`, 3 `SCAN_AREA`. |
| Mode | Enum StructureMode (VarInt ordinal) | 0 save, 1 load, 2 corner, 3 data. |
| Name | String(max 32767) | |
| Offset X | Byte | The decoder clamps it to −48..48. |
| Offset Y | Byte | Clamped −48..48. |
| Offset Z | Byte | Clamped −48..48. |
| Size X | Byte | Clamped 0..48. |
| Size Y | Byte | Clamped 0..48. |
| Size Z | Byte | Clamped 0..48. |
| Mirror | Enum Mirror (VarInt ordinal) | 0 none, 1 left_right, 2 front_back. |
| Rotation | Enum Rotation (VarInt id) | 0 none, 1 clockwise 90, 2 180, 3 counterclockwise 90. The id mapper wraps. |
| Metadata | String(max 128) | |
| Integrity | Float | Clamped 0.0–1.0. |
| Seed | VarLong | |
| Flags | Byte | 0x01 ignore entities, 0x02 show air, 0x04 show bounding box, 0x08 strict. |

## 0x3D (61) Serverbound Set Test Block (ServerboundSetTestBlockPacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Mode | Enum TestBlockMode (VarInt id) | 0 start, 1 log, 2 fail, 3 accept. An out-of-range value maps to 0. |
| Message | String(max 32767) | |

## 0x3E (62) Serverbound Sign Update (ServerboundSignUpdatePacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Lines | 4 × String(max 384) | **Fixed-size list. No count prefix.** Exactly four strings follow, and the encoder rejects any other count. |
| Side | Enum SignTextSlot (VarInt id) | 0 back, 1 front. An out-of-range value maps to 0. |

## 0x3F (63) Serverbound Spectator Action (ServerboundSpectatorActionPacket)

| Field | Type | Notes |
|---|---|---|
| Spectate entity | OptionalVarInt | A single VarInt. 0 means absent, and n > 0 means entity id n − 1 (`ByteBufCodecs.OPTIONAL_VAR_INT`). |

## 0x40 (64) Serverbound Teleport To Entity (ServerboundTeleportToEntityPacket)

| Field | Type | Notes |
|---|---|---|
| Target | UUID | Entity UUID (spectator teleport). |

## 0x41 (65) Serverbound Test Instance Block Action (ServerboundTestInstanceBlockActionPacket)

| Field | Type | Notes |
|---|---|---|
| Location | Position | |
| Action | Enum (VarInt id) | 0 `INIT`, 1 `QUERY`, 2 `SET`, 3 `RESET`, 4 `SAVE`, 5 `EXPORT`, 6 `RUN`. An out-of-range value maps to 0. |
| Data | TestInstanceData | See "Composite types introduced here". |

## 0x42 (66) Serverbound Use Item On (ServerboundUseItemOnPacket)

| Field | Type | Notes |
|---|---|---|
| Hand | Enum InteractionHand (VarInt id) | 0 main, 1 off. |
| Hit | BlockHitResult | See below. |
| Sequence | VarInt | Block-change sequence number. |

**BlockHitResult** encoding (`BlockHitResult.STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| Block | Position | Block that was hit. |
| Face | Enum Direction (VarInt id) | 0 down, 1 up, 2 north, 3 south, 4 west, 5 east. The id mapper wraps. **This is a VarInt here, but a UByte in Player Action.** |
| Cursor X | Float | Hit point minus the block's integer X. The receiver adds the block coordinate back. Normally 0.0–1.0. |
| Cursor Y | Float | Hit point minus the block's Y. |
| Cursor Z | Float | Hit point minus the block's Z. |
| Inside | Boolean | The hit started inside the block. |
| World border hit | Boolean | |

The "miss" flag of a hit result is not transmitted. The decoder always constructs a non-miss result.

## 0x43 (67) Serverbound Use Item (ServerboundUseItemPacket)

| Field | Type | Notes |
|---|---|---|
| Hand | Enum InteractionHand (VarInt id) | |
| Sequence | VarInt | Block-change sequence number. |
| Yaw (yRot) | Float | Player's rotation at the moment of use. |
| Pitch (xRot) | Float | |

## 0x44 (68) Serverbound Custom Click Action (ServerboundCustomClickActionPacket)

Common packet. See [03-configuration.md](03-configuration.md).

---

## Signed chat

Signed chat applies to packets 0x06, 0x08, 0x09 and 0x0A. This section describes only what the bytecode shows. Servers
that do not enforce secure chat accept unsigned chat: an absent signature in 0x09, and plain 0x07 for commands.

**Session setup.** On each new session, the client generates a random session UUID and sends Chat Session Update
(0x0A) with that UUID and its profile public key data. The data contains the expiry instant, the RSA public key, and
the key signature issued by the account service. The client signs with algorithm `SHA256withRSA` using the private key
of the profile key pair (`LocalChatSession`). A server that enforces secure chat checks the key signature against the
service's key (inferred). A COBOL client without a service-issued key pair therefore cannot satisfy such a server and
should send unsigned chat.

**What a message signature covers.** The signed byte stream is built by `PlayerChatMessage.updateSignature`,
`SignedMessageLink.updateSignature`, `SignedMessageBody.updateSignature` and `LastSeenMessages.updateSignature`. It is
the concatenation of these parts, with all integers big-endian:

| Order | Bytes | Content |
|---|---|---|
| 1 | 4 | Int constant 1 (signature format version). |
| 2 | 16 | Sender UUID (the player's profile UUID), most significant half first. |
| 3 | 16 | Session UUID (from 0x0A). |
| 4 | 4 | Int link index: the message's position in this session's chain. It starts at 0 and increases by one per signed message (inferred from `SignedMessageChain`). |
| 5 | 8 | Long salt (same as the packet's Salt field). |
| 6 | 8 | Long timestamp in **seconds** since the epoch (`Instant.getEpochSecond`). The packet itself carries milliseconds. |
| 7 | 4 | Int byte length of the message text in UTF-8. |
| 8 | n | Message text, UTF-8. |
| 9 | 4 | Int count of last-seen signatures. |
| 10 | 256 × count | Each last-seen message signature, in list order. |

The resulting 256-byte RSA signature is the MessageSignature in 0x09.

**Signed commands (0x08).** The client signs each signable command argument separately
(`ArgumentSignatures.signCommand`). The value that is signed is the argument's text, used as the message text in the
structure above, together with the packet's timestamp, salt and last-seen list (inferred). Each argument signature is
sent with the argument's name (max 16 chars). At most 8 arguments can be signed.

**Last-seen tracking.** The server keeps a window of 20 tracked messages. In LastSeenMessagesUpdate:

- Offset: the number of new messages the client has received since its last update. The server discards that many
  entries from the front of its tracking list.
- Acknowledged: a 20-bit set over that window that marks which messages the client has seen. A set bit for an
  untracked slot is an error.
- Checksum: a one-byte check over the acknowledged signatures. It starts with h = 1. For each acknowledged signature in
  order, h = 31·h + H, where H is the standard Java `Arrays.hashCode` of the 256 signed bytes, computed with 32-bit
  wrap-around. The checksum is the low byte of h, and 1 is used if that byte is 0. A checksum of 0 (`IGNORE_CHECKSUM`)
  tells the server not to verify it. A mismatch is a validation error, and the server disconnects.

Chat Ack (0x06) carries only an offset. It advances the window without sending a chat message.

---

## Minimum required serverbound traffic

The obligations below come from `ClientPacketListener`, `ClientCommonPacketListenerImpl` and `Minecraft.tick` (what
the vanilla client sends), checked against the server's handlers (`ServerCommonPacketListenerImpl`,
`ServerGamePacketListenerImpl`, `PlayerChunkSender`).

**Keep Alive (0x1C).** This is the one hard requirement for staying connected. The server sends a clientbound Keep Alive
with a Long challenge every 15000 ms. If the previous challenge is still unanswered when the next 15-second interval
arrives, the server disconnects with a timeout. A reply with the wrong id also disconnects. The client must echo each
challenge as soon as it arrives (`handleKeepAlive`).

**Accept Teleportation (0x00).** The server sends a clientbound Player Position on join and on every forced teleport.
Until it receives a matching Accept Teleportation, it ignores the client's movement packets. It also re-sends the
teleport every 20 ticks (`updateAwaitingTeleport`). The connection does not drop, but the player stays frozen.
The vanilla client replies at once, from `handleMovePlayer`, with the teleport id and the position and rotation it
applied. It does not send a separate Move Player packet for that teleport.

**Chunk Batch Received (0x0B).** The server sends chunks in batches framed by Chunk Batch Start / Chunk Batch Finished.
The vanilla client answers each Chunk Batch Finished with Chunk Batch Received (`handleChunkBatchFinished`). Without
this acknowledgement, the server stops after the first batch, so the client would never receive the chunks around
the player. A fixed value such as 9.0 (the server's starting rate) is acceptable (inferred).

**Player Loaded (0x2C).** The vanilla client sends this once per join or respawn, when it considers the level ready.
The server starts a 60-tick "client loaded" timer on join or respawn. While the timer runs and Player Loaded has not
arrived, the server treats the player as not loaded and skips or ignores several kinds of input, including player
input and vehicle movement. When the timer expires, the server treats the player as loaded anyway, so a missing Player
Loaded delays play by about 3 seconds but does not disconnect. Clients should send it promptly once chunks around the
spawn point have arrived.

**Client Tick End (0x0D).** The vanilla client sends this every tick. It is not needed to stay connected. The server
uses it to reset per-tick movement state, and sending it after each tick's movement packets matches vanilla behavior.

**Configuration Acknowledged (0x10).** When the server sends Start Configuration during play, the client must reply
with Configuration Acknowledged and switch to the configuration protocol. Otherwise the server never moves the
connection back to configuration (see [03-configuration.md](03-configuration.md)).

**Pong (0x2D), Cookie Response (0x15), Resource Pack (0x32).** These answer the matching clientbound requests. The
vanilla client always answers them (`ClientCommonPacketListenerImpl.handlePing`, `handleRequestCookie`,
`handleResourcePackPush`). See 02 and 03 for each request's semantics.

**Movement.** No movement packet is required to stay connected. The vanilla client sends a position packet at least
every 20 ticks as a reminder, even when standing still.

A minimal join therefore sends: Accept Teleportation for the initial position packet, Chunk Batch Received after each
batch, Player Loaded once the spawn area has loaded, and Keep Alive replies forever after. Client Tick End once per
tick and periodic Move Player Status Only or Pos are recommended for vanilla-like behavior.

---

## Composite types introduced here

### LpVec3
Defined in [00-data-types.md §4.6](00-data-types.md#46-lpvec3-low-precision-velocity-vector).

### MessageSignature

| Field | Type | Notes |
|---|---|---|
| Bytes | 256 raw bytes | Fixed length. No length prefix. |

### LastSeenMessagesUpdate (`LastSeenMessages$Update`)

| Field | Type | Notes |
|---|---|---|
| Offset | VarInt | |
| Acknowledged | FixedBitSet(20) | Exactly 3 bytes (ceil(20/8)), with no prefix. Bit i is bit (i mod 8) of byte (i div 8), least significant bit first (`BitSet.valueOf` order). The encoder rejects a set with a bit at index 20 or higher. |
| Checksum | Byte | See "Signed chat". 0 means "do not verify". |

### ArgumentSignatures

| Field | Type | Notes |
|---|---|---|
| Entries | Prefixed Array (max 8) of ArgumentSignatureEntry | |

ArgumentSignatureEntry:

| Field | Type | Notes |
|---|---|---|
| Argument name | String(max 16) | Name of the command argument node. |
| Signature | MessageSignature | 256 raw bytes. |

### ProfilePublicKeyData (`ProfilePublicKey$Data`)

| Field | Type | Notes |
|---|---|---|
| Expires at | Long | `Instant` as milliseconds since the epoch. |
| Public key | ByteArray(VarInt len, max 512) | The key's `getEncoded()` bytes: X.509 SubjectPublicKeyInfo DER for an RSA key (inferred from the JDK encoding). |
| Key signature | ByteArray(VarInt len, max 4096) | Signature over the key, issued by the account service. |

### TestInstanceData (`TestInstanceBlockEntity$Data`)

| Field | Type | Notes |
|---|---|---|
| Test | Optional Identifier | Resource key in the `test_instance` registry. |
| Size | 3 × VarInt | `Vec3i.STREAM_CODEC`: x, y, z. |
| Rotation | Enum Rotation (VarInt id) | 0 none, 1 cw 90, 2 180, 3 ccw 90. Wraps. |
| Ignore entities | Boolean | |
| Status | Enum (VarInt id) | 0 cleared, 1 running, 2 finished. An out-of-range value maps to 0. |
| Error message | Optional TextComponent | `ComponentSerialization.STREAM_CODEC`. |

### OptionalVarInt

This is a single VarInt `v`. If v is 0, the value is absent. If v > 0, the value is v − 1.

---

## Open questions

1. **`containsInvalidValues` bounds.** The server calls a static `containsInvalidValues(DDDFF)` on Accept Teleportation
   and the move packets. This document does not give its exact coordinate and rotation limits. They are not needed
   for the wire format, but a client should keep values finite and within world bounds.
2. **Argument-signature link indices.** Each signed command argument is probably signed with its own chain link index,
   so the index rises once per argument, but this was inferred and not traced through
   `ClientPacketListener.sendCommand` / `SignedMessageChain$Encoder`. Implementers who need signed commands should
   confirm it.
3. **Player Command "data" field.** Its meaning for actions other than riding jump was not traced. Vanilla appears to
   send 0 for those actions.
4. **Container Click slot −999.** The "outside window" slot value is conventional and was not read from this jar.
5. **Secure-chat enforcement.** This document does not trace how a server that enforces secure chat treats a client
   that never sends Chat Session Update (rejection message versus disconnect).
6. **HashedStack component hash.** The hash function for each component, which the server compares against its own,
   is defined in [00-data-types.md](00-data-types.md) (the `HashedPatchMap$HashGenerator` path) and was not re-derived
   here.
