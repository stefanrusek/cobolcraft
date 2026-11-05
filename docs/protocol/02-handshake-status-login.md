# 02 — Handshake, status, login and cookies

Packet tables for the handshake, status and login phases, the cookie packets that appear in login,
configuration and play, and the login/authentication sequence.

Sources (bytecode): `net.minecraft.network.protocol.handshake.*`, `…status.*`, `…ping.*`, `…login.*`,
`…cookie.*`, `HandshakeProtocols`, `StatusProtocols`, `LoginProtocols`,
`net.minecraft.server.network.ServerHandshakePacketListenerImpl`, `ServerStatusPacketListenerImpl`,
`ServerLoginPacketListenerImpl` (and `$1`), `net.minecraft.client.multiplayer.ClientHandshakePacketListenerImpl`,
`net.minecraft.util.Crypt`, `net.minecraft.core.UUIDUtil`, `net.minecraft.util.StringUtil`,
`net.minecraft.network.protocol.status.ServerStatus` (and `$Players`, `$Version`, `$Favicon`),
`net.minecraft.server.players.NameAndId`.

Type names are defined in 00-data-types.md. Framing, compression and encryption are in 01-transport.md.

# Handshake phase

Only one packet exists in this phase. It is terminal: after sending it the client switches to the
phase selected by Intent.

## 0x00 (0) Serverbound Intention (ClientIntentionPacket)

| Field | Type | Notes |
|---|---|---|
| Protocol version | VarInt | Client's protocol version. This version: 777. |
| Host name | String(255) | Address the client used to connect (informational). |
| Port | UShort | Port the client used to connect. |
| Intent | IdEnum ClientIntent (VarInt) | 1 = status, 2 = login, 3 = transfer. Any other value fails decoding (`ClientIntent.byId` throws). |

Server handling (`ServerHandshakePacketListenerImpl`):

- Intent 1 (status): switch to the status phase. If the server is configured not to answer status
  requests, it disconnects (`disconnect.ignoring_status_request`) instead.
- Intent 2 (login): switch outbound to login. If Protocol version ≠ 777, send Login Disconnect with
  `multiplayer.disconnect.outdated_client` (if the client's version is < 754) or
  `multiplayer.disconnect.incompatible` (otherwise), both with the server version name as argument, and
  close. Otherwise switch inbound to login.
- Intent 3 (transfer): if the server does not accept transfers, switch outbound to login, send Login
  Disconnect `multiplayer.disconnect.transfers_disabled` and close. Otherwise proceed as for login, with
  the "transferred" flag set (it is carried into the configuration phase).

The protocol version check is skipped for status: any version may query status.

# Status phase

Packet ids: clientbound 0 = Status Response, 1 = Pong Response; serverbound 0 = Status Request,
1 = Ping Request.

## 0x00 (0) Serverbound Status Request (ServerboundStatusRequestPacket)

No fields.

## 0x00 (0) Clientbound Status Response (ClientboundStatusResponsePacket)

| Field | Type | Notes |
|---|---|---|
| Status | JSON String(32767) | `ByteBufCodecs.lenientJson(32767)` (00-data-types.md §9.2) holding a ServerStatus JSON object. |

ServerStatus JSON object (`ServerStatus.CODEC`); all top-level fields are optional and decoded
leniently (a malformed optional field is ignored):

| JSON field | JSON type | Notes |
|---|---|---|
| `description` | text component (JSON) | Defaults to empty text. |
| `players` | object | See below. |
| `version` | object | See below. |
| `favicon` | string | Must start with `data:image/png;base64,`; the remainder is base64 PNG data (newlines are stripped before decoding). |
| `enforcesSecureChat` | boolean | Defaults to false. |

`players` object (`ServerStatus$Players`):

| JSON field | JSON type | Notes |
|---|---|---|
| `max` | integer | Required. |
| `online` | integer | Required. |
| `sample` | array of objects | Optional, default empty. Each object has `id` (UUID as a hyphenated string, `UUIDUtil.STRING_CODEC`) and `name` (string) (`NameAndId.CODEC`). |

`version` object (`ServerStatus$Version`):

| JSON field | JSON type | Notes |
|---|---|---|
| `name` | string | Required. The vanilla server sends its version name. |
| `protocol` | integer | Required. The vanilla server sends 777. |

The server answers only the first Status Request; a second one disconnects
(`multiplayer.status.request_handled`).

## 0x01 (1) Serverbound Ping Request (ServerboundPingRequestPacket)

| Field | Type | Notes |
|---|---|---|
| Time | Long | Arbitrary value chosen by the client (the client uses a timestamp). |

The same packet type is also registered in the play phase (serverbound id 0x26, 38).

## 0x01 (1) Clientbound Pong Response (ClientboundPongResponsePacket)

| Field | Type | Notes |
|---|---|---|
| Time | Long | Copy of the Ping Request's Time. |

After sending this in the status phase the server closes the connection. The same packet type is also
registered in the play phase (clientbound id 0x3F, 63).

# Login phase

Packet ids:

| Id | Clientbound | Serverbound |
|---|---|---|
| 0x00 (0) | Login Disconnect | Hello (Login Start) |
| 0x01 (1) | Hello (Encryption Request) | Key (Encryption Response) |
| 0x02 (2) | Login Finished | Custom Query Answer |
| 0x03 (3) | Login Compression (Set Compression) | Login Acknowledged |
| 0x04 (4) | Custom Query | Cookie Response |
| 0x05 (5) | Cookie Request | — |

## 0x00 (0) Clientbound Login Disconnect (ClientboundLoginDisconnectPacket)

| Field | Type | Notes |
|---|---|---|
| Reason | JSON String(262144) | A text component as JSON (`lenientJson(262144)` with `ComponentSerialization.CODEC` over `JsonOps`). Not NBT. |

The server closes the connection after sending it.

## 0x01 (1) Clientbound Hello / Encryption Request (ClientboundHelloPacket)

| Field | Type | Notes |
|---|---|---|
| Server id | String(20) | The vanilla server always sends the empty string. |
| Public key | ByteArray | The server's RSA public key, X.509 `SubjectPublicKeyInfo` DER encoding. The vanilla key is 1024-bit RSA (`Crypt.generateKeyPair`). |
| Challenge | ByteArray | Verify token. The vanilla server sends 4 bytes (a random Int, big-endian, `Ints.toByteArray`). |
| Should authenticate | Boolean | true = the client must authenticate with the session service before replying. |

## 0x02 (2) Clientbound Login Finished (ClientboundLoginFinishedPacket)

Terminal (01-transport.md §7.2).

| Field | Type | Notes |
|---|---|---|
| Profile | GameProfile | 00-data-types.md §11.1: UUID, String(16) name, PropertyMap. |
| Session id | UUID | The server's session identifier (`ServerConnectionListener.getSessionId()`), used by the client for telemetry. |

## 0x03 (3) Clientbound Login Compression / Set Compression (ClientboundLoginCompressionPacket)

| Field | Type | Notes |
|---|---|---|
| Threshold | VarInt | Compression threshold (01-transport.md §3.4). |

The server enables compression on its side immediately after this packet has been written; the client
enables it as soon as it handles the packet. All later packets in both directions use the compressed
frame layout. This packet itself is sent uncompressed.

## 0x04 (4) Clientbound Custom Query (ClientboundCustomQueryPacket)

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | Echoed in the answer. |
| Channel | Identifier | Payload type. |
| Data | bytes (rest of packet) | Raw payload; at most 1 048 576 bytes. Unknown channels are read as opaque bytes and skipped. |

The vanilla client knows no query channels; it always answers with an absent payload.

## 0x05 (5) Clientbound Cookie Request (ClientboundCookieRequestPacket)

| Field | Type | Notes |
|---|---|---|
| Key | Identifier | Name of the cookie being requested. |

Also registered in configuration (clientbound 0x00) and play (clientbound 0x15, 21). The client answers
with Cookie Response containing the stored cookie for that key, or an absent payload.

## 0x00 (0) Serverbound Hello / Login Start (ServerboundHelloPacket)

| Field | Type | Notes |
|---|---|---|
| Name | String(16) | Player name. The server rejects names with any character outside `0x21`–`0x7E` ("Invalid characters in username"). |
| Profile id | UUID | The client's profile UUID. The vanilla server does not use it for authentication. |

## 0x01 (1) Serverbound Key / Encryption Response (ServerboundKeyPacket)

| Field | Type | Notes |
|---|---|---|
| Shared secret | ByteArray | The client's 16-byte AES key, RSA-encrypted with the server's public key. |
| Challenge | ByteArray | The Challenge from Encryption Request, RSA-encrypted with the server's public key. |

RSA here uses `Cipher.getInstance("RSA")` with the key's algorithm name, which in the standard Java
provider means RSA/ECB/PKCS1Padding (inferred from Java defaults; the transformation string in the jar
is just "RSA"). With a 1024-bit key each field is 128 bytes.

The server decrypts the challenge and compares it with what it sent; a mismatch, or any decryption
failure, is a protocol error ("Protocol error") that closes the connection.

## 0x02 (2) Serverbound Custom Query Answer (ServerboundCustomQueryAnswerPacket)

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | From the Custom Query. |
| Has payload | Boolean | Written by the client: false for "no answer". |
| Payload | bytes (rest of packet) | Only if Has payload. Opaque; at most 1 048 576 bytes. |

The vanilla server reads the Transaction id and then skips the entire rest of the packet (up to
1 048 576 bytes, the Boolean included) without interpreting it. The vanilla server never sends Custom
Query and disconnects on receiving an answer (`multiplayer.disconnect.unexpected_query_response`).

## 0x03 (3) Serverbound Login Acknowledged (ServerboundLoginAcknowledgedPacket)

No fields. Terminal. Sent by the client in reply to Login Finished; it switches both sides to the
configuration phase (01-transport.md §7.3). The server rejects it unless Login Finished has been sent
("Unexpected login acknowledgement packet").

## 0x04 (4) Serverbound Cookie Response (ServerboundCookieResponsePacket)

| Field | Type | Notes |
|---|---|---|
| Key | Identifier | The requested cookie's key. |
| Payload | Optional ByteArray(5120) | Boolean-prefixed. Absent if the client has no cookie with that key. |

Also registered in configuration (serverbound 0x01) and play (serverbound 0x15, 21). The vanilla server
never requests cookies and disconnects on an unsolicited response (`multiplayer.disconnect.unexpected_query_response`).

# Login sequence

## Online mode (authentication enabled)

| Step | Direction | Packet / action |
|---|---|---|
| 1 | C→S | Hello: name, profile UUID. |
| 2 | S→C | Encryption Request: server id `""`, public key, 4-byte challenge, Should authenticate = true. |
| 3 | client | Generates a 16-byte AES shared secret; computes the server hash (below); if Should authenticate, calls the session service "join" with its access token, profile UUID and the hash. |
| 4 | C→S | Encryption Response (unencrypted). The client then enables encryption. |
| 5 | server | Verifies the challenge, decrypts the secret, enables encryption, computes the same server hash, and asks the session service "has joined" with the requested name, the hash and (optionally) the client's IP address. |
| 6 | S→C | (optional) Set Compression, if the server threshold is ≥ 0. Compression is enabled after it is written. |
| 7 | S→C | Login Finished with the authenticated profile (UUID and properties from the session service). |
| 8 | C→S | Login Acknowledged. Both sides are now in configuration. |

Steps 6–7 happen when the server's login tick sees the verified profile. If a player with the same UUID
is already online, the server first disconnects that player and waits for that to complete before
step 7.

## Offline mode

The server skips steps 2–5: after Hello it creates an offline profile and continues with step 6. The
offline UUID is `UUID.nameUUIDFromBytes(("OfflinePlayer:" + name) encoded as UTF-8)`, i.e. a version 3
(MD5-based) UUID (`UUIDUtil.createOfflinePlayerUUID`). No encryption is used.

Encryption and compression are also never used on in-memory (singleplayer) connections.

## Server hash ("server id hash")

Both sides compute the hash string sent to the session service the same way (`Crypt.digestData` then
`new BigInteger(bytes).toString(16)`):

1. Build a SHA-1 digest over the concatenation, in this order, of:
   1. the server id string (from Encryption Request; the vanilla server uses `""`) encoded as
      ISO-8859-1 bytes,
   2. the 16 raw bytes of the shared secret,
   3. the server's public key in its encoded (X.509 DER) form — the same bytes sent in Encryption
      Request.
2. Interpret the 20-byte digest as a **signed** two's-complement big-endian integer (Java `BigInteger(byte[])`).
3. Format it in base 16 with lower-case digits, no leading zeros, and a leading `-` if the number is
   negative (Java `BigInteger.toString(16)`). For a negative number the magnitude (two's-complement
   negation of the 160-bit value) is printed after the `-`.

## Session service

The jar does not contain `com.mojang.authlib` (the authentication library ships separately), so the
session server's URLs and JSON field names are **not present in this artifact**. What the jar shows:

- The client calls `SessionService.joinServer(profileId UUID, accessToken String, serverHash String)`
  before sending Encryption Response. Failures map to the messages
  `disconnect.loginFailedInfo.serversUnavailable`, `…invalidSession`, `…insufficientPrivileges`,
  `…userBanned`, or the exception message.
- The server calls `SessionService.hasJoinedServer(requestedName String, serverHash String, address InetAddress)`
  and uses the returned profile (UUID, name, properties) as the authenticated profile. The address is
  passed only when the server's `prevent-proxy-connections` option is on (otherwise null) (inferred from
  `getAddress` reading `getPreventProxyConnections`). A null result disconnects with
  `multiplayer.disconnect.unverified_username`; an unavailable service disconnects with
  `multiplayer.disconnect.authservers_down`. A singleplayer-hosted server instead falls back to an
  offline profile in both cases.

## Login timeouts and errors

- The server disconnects a login that has not completed within 600 ticks
  (`multiplayer.disconnect.slow_login`).
- Hello in any state other than the initial one, Key outside the "waiting for key" state, and Login
  Acknowledged before Login Finished are protocol errors.

# Composite types introduced here

- **ServerStatus JSON**: described above (field names only).
- **ClientIntent**: 1 = status, 2 = login, 3 = transfer (explicit ids, not ordinals).

# Open questions

1. Session service endpoint URLs and request/response JSON are inside `com.mojang.authlib`, which is
   not in this jar. They must be taken from another source.
2. The exact RSA padding scheme is inferred from Java's default for the transformation `"RSA"`
   (PKCS#1 v1.5).
3. Whether the client validates the length of the public key or challenge it receives was not checked;
   the vanilla server always sends a 1024-bit key and a 4-byte challenge.
