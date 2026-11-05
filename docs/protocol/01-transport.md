# 01 — Transport

This document describes how packets travel over TCP: framing, compression, encryption, the packet id
prefix, bundles, and the connection's phase state machine.

Sources (bytecode): `net.minecraft.network.Connection`, `Varint21FrameDecoder`,
`Varint21LengthFieldPrepender`, `CompressionEncoder`, `CompressionDecoder`, `CipherBase`, `CipherEncoder`,
`CipherDecoder`, `PacketEncoder`, `PacketDecoder`, `PacketBundlePacker`, `PacketBundleUnpacker`,
`ProtocolSwapHandler`, `UnconfiguredPipelineHandler`, `net.minecraft.network.codec.IdDispatchCodec`,
`net.minecraft.network.protocol.BundlerInfo` (and `$1`, `$1$1`), `ProtocolInfoBuilder`,
`net.minecraft.util.Crypt`, `net.minecraft.server.network.ServerConnectionListener$1`,
`LegacyQueryHandler`, `ServerHandshakePacketListenerImpl`, `ServerLoginPacketListenerImpl`,
`ServerConfigurationPacketListenerImpl`, `ServerGamePacketListenerImpl`, `ServerCommonPacketListenerImpl`,
and the client counterparts `ClientHandshakePacketListenerImpl`, `ClientConfigurationPacketListenerImpl`,
`ClientPacketListener`.

Type names are defined in 00-data-types.md.

## 1. Layering

Each direction of a connection is a pipeline of byte transformations. In send order:

1. **Packet encoding**: VarInt packet id, then the packet body (§5).
2. **Compression** (only after it has been enabled): wraps the encoded packet (§3).
3. **Framing**: prefixes a VarInt length (§2).
4. **Encryption** (only after it has been enabled): AES-CFB8 over the whole byte stream (§4).

Receiving applies the inverse in reverse order: decrypt → split frames → decompress → decode packet →
(play phase only, clientbound) bundle assembly.

The Netty handler names, in pipeline order, are: `timeout`, `legacy_query` (server only), `decrypt`
(added later), `splitter`, `decompress` (added later), `decoder` (or placeholder `inbound_config`),
`bundler`, … and on the outbound side `encoder` (or placeholder `outbound_config`), `unbundler`,
`compress`, `prepender`, `encrypt`. `setEncryptionKey` inserts `decrypt` before `splitter` and `encrypt`
before `prepender`; `setupCompression` inserts `decompress` after `splitter` and `compress` after
`prepender` (outbound handlers run from tail to head, so `compress` runs before `prepender` and
`encrypt` after it).

## 2. Framing

Every packet (after optional compression) is sent as one frame:

| Field | Type | Notes |
|---|---|---|
| Length | VarInt | Number of bytes that follow in this frame. At most 3 bytes long. |
| Data | bytes × Length | The (possibly compressed) packet. |

Rules:

- The length VarInt may be at most **3 bytes** (`MAX_VARINT21_BYTES = 3`), so a frame body is at most
  2²¹ − 1 = **2 097 151 bytes**. On receive, if 3 bytes have been read and the third still has its
  continuation bit set, the connection fails ("length wider than 21-bit"). On send, a body whose length
  VarInt would need more than 3 bytes fails with an encoder error.
- A frame length of **0 is invalid** ("Frame length cannot be zero").
- The splitter waits until the whole frame has arrived; partial frames are buffered.
- Frames are independent of TCP segment boundaries; several frames can arrive in one read.

Before the first frame, the server's `legacy_query` handler inspects the first byte of a new
connection: if it is `0xFE` the connection is treated as a pre-Netty legacy server-list ping and
answered in the legacy format, then closed (format out of scope). Any other first byte removes the
handler and normal framing proceeds.

The server installs a 30-second read timeout (`ReadTimeoutHandler(30)`) on each accepted connection.

## 3. Compression

Compression is off when a connection starts. It is switched on during login by the Set Compression
packet (02-handshake-status-login.md). Once on, it stays on for the rest of the connection in both
directions, including the configuration and play phases.

### 3.1 Compressed frame layout

With compression enabled, the Data of every frame has this layout:

| Field | Type | Notes |
|---|---|---|
| Data length | VarInt | `0` = the rest is uncompressed. Otherwise the length in bytes of the packet **after** decompression. |
| Payload | bytes | Uncompressed packet (if Data length is 0) or a zlib stream (if not). |

The frame Length (§2) covers both the Data length VarInt and the Payload.

### 3.2 Sender rules (`CompressionEncoder`)

- Let `n` be the size of the encoded packet (id + body).
- If `n > 8 388 608` (8 MiB) the encoder fails ("Packet too big").
- If `n < threshold`: write VarInt `0`, then the packet bytes unchanged.
- Otherwise: write VarInt `n`, then the packet compressed with `java.util.zip.Deflater` using its
  default settings (zlib format with header and Adler-32 trailer, default compression level). The
  deflater is reset after each packet (each packet is an independent zlib stream).

### 3.3 Receiver rules (`CompressionDecoder`)

- Read VarInt Data length. If it is `0`, the rest of the frame is the packet, taken as is.
- Otherwise, if validation is enabled:
  - fail if Data length `< threshold` ("Badly compressed packet - size of … is below server threshold of …");
  - fail if Data length `> 8 388 608` ("… larger than protocol maximum of 8388608").
- Inflate with `java.util.zip.Inflater` (zlib format). The number of bytes produced must equal Data length
  exactly, otherwise fail ("actual length of uncompressed payload … does not match declared size …").
- The constant `MAXIMUM_COMPRESSED_LENGTH = 2 097 152` exists in the class but the decoder does not
  test it; the frame limit of §2 bounds compressed sizes in practice.

Validation is **on for the server's decoder** (the server calls `setupCompression(threshold, true)`) and
**off for the client's decoder** (`setupCompression(threshold, false)`). A client may therefore send
small packets compressed only to servers that do not validate; a vanilla server rejects them.

### 3.4 Threshold semantics

- The threshold is a VarInt sent in Set Compression. Packets of size `≥ threshold` are compressed;
  packets of size `< threshold` are sent with Data length 0.
- A **negative** threshold given to `setupCompression` removes the compression handlers entirely
  (compression off). The vanilla server only sends Set Compression when its configured threshold is
  `≥ 0`; if it is negative it never sends the packet and compression stays off.
- A threshold of `0` compresses every packet.
- Calling `setupCompression` again while compression is on only updates the threshold (and validation flag).
- Compression is never enabled on in-memory (singleplayer) connections.

## 4. Encryption

### 4.1 Algorithm

- Cipher: `AES/CFB8/NoPadding` (`Crypt.getCipher`). AES with a 128-bit key in 8-bit cipher feedback mode.
- Key: the 16-byte shared secret generated by the client (`Crypt.generateSecretKey`: AES `KeyGenerator`
  initialized to 128 bits).
- IV: the **same 16 bytes as the key** (`new IvParameterSpec(key.getEncoded())`).
- Two independent cipher instances are created on each side: one for encrypting (send) and one for
  decrypting (receive). Each instance is a continuous stream across the whole connection: the CFB8 state
  carries over from frame to frame and is never reset.
- Encryption applies to the raw TCP byte stream, i.e. to the frame length prefixes as well as frame
  contents (the `encrypt` handler sits outside `prepender`; `decrypt` sits outside `splitter`).
- Because CFB8 is a stream mode with no padding, ciphertext length equals plaintext length.

### 4.2 When it starts

The key exchange is described in 02-handshake-status-login.md. The switch points are:

- **Client**: sends Encryption Response (Key) unencrypted. After that packet has been written to the
  socket (send-completion listener), it installs the ciphers. Every byte it sends afterwards is encrypted,
  and it expects every byte it receives afterwards to be encrypted.
- **Server**: on receiving Encryption Response, decrypts the shared secret and immediately installs the
  ciphers before sending anything else. All server bytes after that point are encrypted; all client bytes
  following the Encryption Response frame are decrypted.

Encryption is only used when the server sends Encryption Request, which the vanilla server does only when
online-mode authentication is on (`usesAuthentication`) and the connection is not in-memory. In offline
mode the whole connection stays unencrypted.

## 5. Packet encoding

Inside a frame (after decompression), a packet is:

| Field | Type | Notes |
|---|---|---|
| Packet id | VarInt | Index of the packet type within the current phase and direction. |
| Body | bytes | Packet-specific fields. |

- Packet ids are assigned by registration order in the phase's `…Protocols` class
  (`ProtocolInfoBuilder` → `IdDispatchCodec`): the first registered packet type is id 0, the next id 1,
  and so on. Ids are separate per phase **and** per direction.
- The decoder rejects ids `< 0` or `≥` the number of registered packets ("Received unknown packet id …").
- After the body has been decoded, any leftover bytes in the frame are an error (`PacketDecoder` throws
  an `IOException` naming the phase, packet and number of extra bytes).
- An empty body is legal (several packets have no fields).
- If decoding fails for a packet marked skippable, the frame is discarded instead of closing the
  connection (`SkipPacketException`); otherwise any decoding error closes the connection.

## 6. Bundles (play phase, clientbound only)

The clientbound play protocol registers a bundle delimiter as packet id **0x00** (`CLIENTBOUND_BUNDLE`,
class `ClientboundBundleDelimiterPacket`, no fields). Only the clientbound play protocol has a bundler;
other phases and serverbound play have none.

Semantics (`BundlerInfo`, `PacketBundlePacker`, `PacketBundleUnpacker`):

- A bundle is sent on the wire as: delimiter, then the member packets each in its own frame, then
  another delimiter.
- The receiver, on seeing a delimiter while not inside a bundle, starts collecting. Packets received
  until the next delimiter are buffered and then handed to the game together as one unit, so that they
  are applied in the same tick.
- At most **4096** packets may be in one bundle; one more fails ("Too many packets in a bundle").
- A terminal packet (§7.2) inside a bundle is an error ("Terminal message received in bundle").
- Bundles do not nest. A bundle has no length field and no id of its own beyond the delimiter.

## 7. Connection phases

### 7.1 Phases and transitions

```
                   ┌──────────────► STATUS (closed after ping)
HANDSHAKE ─intent─┤
                   └──────────────► LOGIN ──► CONFIGURATION ⇄ PLAY
              (LOGIN or TRANSFER intent)
```

| From | Trigger | To |
|---|---|---|
| (connect) | — | HANDSHAKE (both sides) |
| HANDSHAKE | C→S Intention with intent 1 (status) | STATUS |
| HANDSHAKE | C→S Intention with intent 2 (login) | LOGIN |
| HANDSHAKE | C→S Intention with intent 3 (transfer) | LOGIN (marked as transferred), or disconnect if the server does not accept transfers |
| STATUS | S→C Pong Response | (server closes the connection) |
| LOGIN | S→C Login Finished, then C→S Login Acknowledged | CONFIGURATION |
| CONFIGURATION | S→C Finish Configuration, then C→S Finish Configuration (acknowledge) | PLAY |
| PLAY | S→C Start Configuration, then C→S Configuration Acknowledged | CONFIGURATION |

Packet ids involved:

| Packet | Phase / direction | Id |
|---|---|---|
| Intention | handshake, serverbound | 0x00 (0) |
| Login Finished | login, clientbound | 0x02 (2) |
| Login Acknowledged | login, serverbound | 0x03 (3) |
| Finish Configuration | configuration, clientbound | 0x03 (3) |
| Finish Configuration | configuration, serverbound | 0x03 (3) |
| Start Configuration | play, clientbound | 0x78 (120) |
| Configuration Acknowledged | play, serverbound | 0x10 (16) |

### 7.2 Terminal packets and codec switching

Packets that end a phase in their direction are **terminal** (`Packet.isTerminal()` returns true):

- `ClientIntentionPacket` (handshake, serverbound)
- `ClientboundLoginFinishedPacket` (login, clientbound)
- `ServerboundLoginAcknowledgedPacket` (login, serverbound)
- `ClientboundFinishConfigurationPacket` (configuration, clientbound)
- `ServerboundFinishConfigurationPacket` (configuration, serverbound)
- `ClientboundStartConfigurationPacket` (play, clientbound)
- `ServerboundConfigurationAcknowledgedPacket` (play, serverbound)

Mechanics (`ProtocolSwapHandler`, `UnconfiguredPipelineHandler`):

- **Sending a terminal packet**: immediately after encoding it, the sender's packet encoder is replaced by
  a placeholder (`outbound_config`). Nothing else can be encoded in that direction until the listener
  installs the next phase's outbound codec (`Connection.setupOutboundProtocol`).
- **Receiving a terminal packet**: immediately after decoding it, the receiver turns off socket
  auto-read and replaces the decoder with a placeholder (`inbound_config`). Further bytes stay buffered
  in the socket/Netty until the listener installs the next phase's inbound codec
  (`Connection.setupInboundProtocol`), which re-enables reading. Bytes that already arrived are then
  decoded with the new phase's ids.

Therefore each direction switches independently, exactly at the terminal packet in that direction. An
implementation must switch its encoder right after writing a terminal packet and its decoder right after
reading one.

### 7.3 Exact switch sequence per transition

**Handshake → Status / Login** (client initiated)

1. Client sets its inbound protocol to the target phase's clientbound codec, sends Intention, then sets
   its outbound protocol to the target phase's serverbound codec.
2. Server, on Intention: sets outbound to the target clientbound codec, then inbound to the target
   serverbound codec. For login it first checks the protocol version (02-handshake-status-login.md).

**Status**

- The server answers one Status Request with Status Response (a second request causes disconnect with
  `multiplayer.status.request_handled`), answers Ping Request with Pong Response carrying the same
  value, and then closes the connection. If the server is configured not to reply to status, it
  disconnects on Intention with `disconnect.ignoring_status_request`.

**Login → Configuration**

1. Server sends Login Finished (terminal outbound). Server outbound is now paused.
2. Client receives it (terminal inbound), installs the configuration clientbound codec as inbound,
   sends Login Acknowledged (terminal outbound), then installs the configuration serverbound codec as
   outbound. The client then immediately sends a Custom Payload `minecraft:brand` and Client Information
   in the configuration phase.
3. Server receives Login Acknowledged (terminal inbound), installs configuration clientbound as outbound,
   installs configuration serverbound as inbound, and starts the configuration sequence
   (03-configuration.md).

**Configuration → Play**

1. Server sends Finish Configuration (terminal outbound).
2. Client receives it, installs the play clientbound codec (bound to the synchronized registries) as
   inbound, sends Finish Configuration (terminal outbound), installs play serverbound as outbound.
3. Server receives Finish Configuration, installs play clientbound (bound to its registries) as outbound,
   then places the player into the world; the play serverbound codec is installed as inbound as part of
   that (inferred: `handleConfigurationFinished` only shows the outbound switch; the inbound switch
   happens in the player placement path, `PrepareSpawnTask.spawnPlayer`).

**Play → Configuration** (re-configuration)

1. Server removes the player from the world, sends Start Configuration (terminal outbound) and installs
   configuration clientbound as outbound.
2. Client receives it, installs configuration clientbound as inbound, sends Configuration Acknowledged
   (terminal outbound), installs configuration serverbound as outbound.
3. Server receives Configuration Acknowledged (an error if it did not request reconfiguration: "Client
   acknowledged config, but none was requested"), installs configuration serverbound as inbound and runs
   the configuration sequence again.

### 7.4 Registry context

Play-phase codecs (and some configuration fields) need registry data synchronized during configuration
(`RegistryFriendlyByteBuf`). The play protocols are "bound" to the registry access at the moment of the
Configuration → Play switch. Types marked as needing registry context in 00-data-types.md can only be
decoded after that point.

### 7.5 Keep-alive and timeouts (configuration and play)

Implemented in `ServerCommonPacketListenerImpl` (applies to configuration and play):

- Every 15 000 ms (`LATENCY_CHECK_INTERVAL`) the server checks keep-alive. If a previous Keep Alive is
  still unanswered, it disconnects the client (`disconnect.timeout`). Otherwise it sends a new Keep Alive
  whose Long id is the current time in milliseconds (inferred from `Util.getMillis()` being stored as the
  challenge) and marks it pending.
- When a Keep Alive response with the matching id arrives, the pending flag clears and the latency is
  updated. A response with a non-matching id or with nothing pending disconnects the client
  (`disconnect.timeout`), except for the singleplayer owner.
- The login phase has its own timeout: 600 ticks (`multiplayer.disconnect.slow_login`).
- The 30-second socket read timeout of §2 applies in every phase.

## Open questions

1. The place where the server installs the play-phase serverbound decoder after Finish Configuration
   was not traced in bytecode (inferred to be in the player placement path).
2. The legacy (0xFE) server-list ping response format is not documented here.
3. Keep-alive id semantics (time in ms) are inferred; a client should simply echo whatever Long it
   receives.
