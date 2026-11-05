# 03 — Configuration phase and common packets

The configuration phase runs after login (and again whenever the server sends Start Configuration
during play). It synchronizes registries, tags, feature flags, resource packs and similar state before
the client enters the world.

This document also defines, once, the **common packets** (`net.minecraft.network.protocol.common.*`
and the cookie packets) that are registered in both the configuration and the play phase. They have the
same body in both phases but **different packet ids**; both ids are listed for each.

Sources (bytecode): `net.minecraft.network.protocol.configuration.*`, `ConfigurationProtocols`,
`net.minecraft.network.protocol.common.*` (and `common.custom.*`), `net.minecraft.network.protocol.cookie.*`,
`GameProtocols` (for the play ids), `net.minecraft.server.network.ServerConfigurationPacketListenerImpl`,
`ServerCommonPacketListenerImpl`, `net.minecraft.server.network.config.*`,
`net.minecraft.client.multiplayer.ClientConfigurationPacketListenerImpl`, `ClientHandshakePacketListenerImpl`,
`net.minecraft.server.level.ClientInformation`, `net.minecraft.server.ServerLinks`,
`net.minecraft.server.packs.repository.KnownPack`, `net.minecraft.core.RegistrySynchronization$PackedRegistryEntry`,
`net.minecraft.tags.TagNetworkSerialization$NetworkPayload`, `net.minecraft.server.dialog.Dialog`.

Type names are defined in 00-data-types.md. Registry semantics (what Registry Data, Update Tags and
Select Known Packs mean and how numeric ids are assigned) are in 04-registry-sync.md.

## Packet id tables

Clientbound (configuration):

| Id | Packet | Class | Common? | Play id |
|---|---|---|---|---|
| 0x00 (0) | Cookie Request | ClientboundCookieRequestPacket | yes (cookie) | 0x15 (21) |
| 0x01 (1) | Custom Payload | ClientboundCustomPayloadPacket | yes | 0x18 (24) |
| 0x02 (2) | Disconnect | ClientboundDisconnectPacket | yes | 0x20 (32) |
| 0x03 (3) | Finish Configuration | ClientboundFinishConfigurationPacket | no | — |
| 0x04 (4) | Keep Alive | ClientboundKeepAlivePacket | yes | 0x2D (45) |
| 0x05 (5) | Ping | ClientboundPingPacket | yes | 0x3E (62) |
| 0x06 (6) | Reset Chat | ClientboundResetChatPacket | no | — |
| 0x07 (7) | Registry Data | ClientboundRegistryDataPacket | no | — |
| 0x08 (8) | Resource Pack Pop | ClientboundResourcePackPopPacket | yes | 0x51 (81) |
| 0x09 (9) | Resource Pack Push | ClientboundResourcePackPushPacket | yes | 0x52 (82) |
| 0x0A (10) | Post Effects | ClientboundPostEffectsPacket | yes | 0x53 (83) |
| 0x0B (11) | Store Cookie | ClientboundStoreCookiePacket | yes | 0x7A (122) |
| 0x0C (12) | Transfer | ClientboundTransferPacket | yes | 0x84 (132) |
| 0x0D (13) | Update Enabled Features | ClientboundUpdateEnabledFeaturesPacket | no | — |
| 0x0E (14) | Update Tags | ClientboundUpdateTagsPacket | yes | 0x89 (137) |
| 0x0F (15) | Select Known Packs | ClientboundSelectKnownPacks | no | — |
| 0x10 (16) | Custom Report Details | ClientboundCustomReportDetailsPacket | yes | 0x8B (139) |
| 0x11 (17) | Server Links | ClientboundServerLinksPacket | yes | 0x8C (140) |
| 0x12 (18) | Clear Dialog | ClientboundClearDialogPacket | yes | 0x8E (142) |
| 0x13 (19) | Show Dialog | ClientboundShowDialogPacket | yes (different body in play) | 0x8F (143) |
| 0x14 (20) | Code of Conduct | ClientboundCodeOfConductPacket | no | — |

Serverbound (configuration):

| Id | Packet | Class | Common? | Play id |
|---|---|---|---|---|
| 0x00 (0) | Client Information | ServerboundClientInformationPacket | yes | 0x0E (14) |
| 0x01 (1) | Cookie Response | ServerboundCookieResponsePacket | yes (cookie) | 0x15 (21) |
| 0x02 (2) | Custom Payload | ServerboundCustomPayloadPacket | yes | 0x16 (22) |
| 0x03 (3) | Finish Configuration (acknowledge) | ServerboundFinishConfigurationPacket | no | — |
| 0x04 (4) | Keep Alive | ServerboundKeepAlivePacket | yes | 0x1C (28) |
| 0x05 (5) | Pong | ServerboundPongPacket | yes | 0x2D (45) |
| 0x06 (6) | Resource Pack Response | ServerboundResourcePackPacket | yes | 0x32 (50) |
| 0x07 (7) | Select Known Packs | ServerboundSelectKnownPacks | no | — |
| 0x08 (8) | Custom Click Action | ServerboundCustomClickActionPacket | yes | 0x44 (68) |
| 0x09 (9) | Accept Code of Conduct | ServerboundAcceptCodeOfConductPacket | no | — |

The ids above were taken from `ConfigurationProtocols` (configuration) and `GameProtocols` (play) by
registration order; no packet in these two classes is registered conditionally.

## Configuration sequence (vanilla server)

On entering configuration (`ServerConfigurationPacketListenerImpl.startConfiguration`), the server sends,
in order:

1. Custom Payload `minecraft:brand` with the server mod name.
2. Server Links, only if the server has any configured links.
3. Update Enabled Features with the world's enabled feature flags.

It then runs a queue of tasks, one at a time; each task sends packets and waits for a specific client
reply before the next task starts:

| Order | Task (type name) | Sends | Completes on |
|---|---|---|---|
| 1 | `synchronize_registries` | Select Known Packs (server's known packs) | Client's Select Known Packs. The server then sends one Registry Data per synchronized registry and one Update Tags, and the task completes. A Select Known Packs while no negotiation is active is an error. |
| 2 | `server_code_of_conduct` (only if the server has a code of conduct) | Code of Conduct (text chosen by the client's language, default `en_us`) | Client's Accept Code of Conduct. |
| 3 | `server_resource_pack` (only if a server resource pack is configured) | Resource Pack Push | Client's Resource Pack Response with a terminal action (any action except Accepted and Downloaded). |
| 4 | prepare spawn | (none on the wire; server-side world preparation) | Server-side readiness. |
| 5 | `join_world` | Finish Configuration | Client's Finish Configuration (acknowledge), which moves both sides to play (01-transport.md §7.3). |

Meanwhile the client sends, right after Login Acknowledged, a Custom Payload `minecraft:brand` and a
Client Information packet. Keep Alive, Ping/Pong and the other common packets may occur at any time.

# Configuration-only packets

## 0x03 (3) Clientbound Finish Configuration (ClientboundFinishConfigurationPacket)

No fields. Terminal (01-transport.md §7.2). Tells the client that configuration is complete.

## 0x06 (6) Clientbound Reset Chat (ClientboundResetChatPacket)

No fields. Tells the client to discard its stored chat state.

## 0x07 (7) Clientbound Registry Data (ClientboundRegistryDataPacket)

Field table only; semantics in 04-registry-sync.md.

| Field | Type | Notes |
|---|---|---|
| Registry | Identifier | Registry key. |
| Entries | Prefixed Array of PackedRegistryEntry | No maximum. |

PackedRegistryEntry (`RegistrySynchronization$PackedRegistryEntry`):

| Field | Type | Notes |
|---|---|---|
| Id | Identifier | Entry key. |
| Data | Optional NBT | **Boolean-prefixed** Optional (00-data-types.md §6.6) of network NBT (`ByteBufCodecs.TAG`, 2 MiB quota; an End root is invalid). Absent when the entry's data is known to the client from a shared known pack. |

## 0x0D (13) Clientbound Update Enabled Features (ClientboundUpdateEnabledFeaturesPacket)

| Field | Type | Notes |
|---|---|---|
| Features | Prefixed Array of Identifier | Enabled feature flag names (a set; no maximum). |

## 0x0F (15) Clientbound Select Known Packs (ClientboundSelectKnownPacks)

Field table only; semantics in 04-registry-sync.md.

| Field | Type | Notes |
|---|---|---|
| Known packs | Prefixed Array of KnownPack | No maximum. |

KnownPack (`KnownPack.STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| Namespace | String(32767) | The vanilla pack uses `minecraft`. |
| Id | String(32767) | |
| Version | String(32767) | The vanilla pack uses the game version id. |

## 0x14 (20) Clientbound Code of Conduct (ClientboundCodeOfConductPacket)

| Field | Type | Notes |
|---|---|---|
| Code of conduct | String(32767) | Plain text to show to the player. |

The server waits for Accept Code of Conduct before continuing.

## 0x03 (3) Serverbound Finish Configuration (ServerboundFinishConfigurationPacket)

No fields. Terminal. Acknowledges Clientbound Finish Configuration; the client switches its outbound
codec to play right after sending it.

## 0x07 (7) Serverbound Select Known Packs (ServerboundSelectKnownPacks)

Field table only; semantics in 04-registry-sync.md.

| Field | Type | Notes |
|---|---|---|
| Known packs | Prefixed Array of KnownPack | At most **64** entries (`ByteBufCodecs.list(64)`). |

## 0x09 (9) Serverbound Accept Code of Conduct (ServerboundAcceptCodeOfConductPacket)

No fields. Completes the code-of-conduct task.

# Common packets

Each heading gives the configuration id; the play id is in the Notes line below it.

## 0x00 (0) Clientbound Cookie Request (ClientboundCookieRequestPacket)

Play: 0x15 (21). Also login 0x05. See 02-handshake-status-login.md for the table: one Identifier field
(cookie key).

## 0x01 (1) Clientbound Custom Payload (ClientboundCustomPayloadPacket)

Play: 0x18 (24).

| Field | Type | Notes |
|---|---|---|
| Channel | Identifier | Payload type id. |
| Data | (per channel) | Rest of the packet. |

- Known channel: `minecraft:brand`, whose Data is a single String(32767) (`BrandPayload`).
- Any other channel is read as opaque bytes up to the end of the packet; at most **1 048 576** bytes
  (larger fails decoding). The vanilla client ignores unknown channels.
- Configuration uses `CONFIG_STREAM_CODEC`, play uses `GAMEPLAY_STREAM_CODEC`; both know only the brand
  payload in this build, so the bytes are identical.

## 0x02 (2) Clientbound Disconnect (ClientboundDisconnectPacket)

Play: 0x20 (32).

| Field | Type | Notes |
|---|---|---|
| Reason | ContextFreeTextComponent | Network NBT text component (00-data-types.md §9.1), unlimited quota. Note that login uses JSON instead. |

## 0x04 (4) Clientbound Keep Alive (ClientboundKeepAlivePacket)

Play: 0x2D (45).

| Field | Type | Notes |
|---|---|---|
| Id | Long | Challenge value; the client must echo it in Serverbound Keep Alive. |

Timing rules: 01-transport.md §7.5.

## 0x05 (5) Clientbound Ping (ClientboundPingPacket)

Play: 0x3E (62).

| Field | Type | Notes |
|---|---|---|
| Id | Int | The client replies with Pong carrying the same Id. |

## 0x08 (8) Clientbound Resource Pack Pop (ClientboundResourcePackPopPacket)

Play: 0x51 (81).

| Field | Type | Notes |
|---|---|---|
| Pack id | Optional UUID | Boolean-prefixed. Present: remove that pack. Absent: remove all server packs. |

## 0x09 (9) Clientbound Resource Pack Push (ClientboundResourcePackPushPacket)

Play: 0x52 (82).

| Field | Type | Notes |
|---|---|---|
| Pack id | UUID | Identifies the pack in later responses and pops. |
| URL | String(32767) | Download location. |
| Hash | String(40) | Hex SHA-1 of the pack file, or empty. Longer than 40 characters is rejected. |
| Required | Boolean | If true and the client declines, the server may disconnect it. |
| Prompt | Optional ContextFreeTextComponent | Boolean-prefixed. Custom prompt text. |

## 0x0A (10) Clientbound Post Effects (ClientboundPostEffectsPacket)

Play: 0x53 (83).

| Field | Type | Notes |
|---|---|---|
| Post effects | Prefixed Array of Identifier | Ids of client post-processing effects to apply (content out of scope). |

## 0x0B (11) Clientbound Store Cookie (ClientboundStoreCookiePacket)

Play: 0x7A (122).

| Field | Type | Notes |
|---|---|---|
| Key | Identifier | Cookie name. |
| Payload | ByteArray(5120) | Cookie data; at most 5120 bytes (`MAX_PAYLOAD_SIZE`). |

The client keeps cookies for the duration of its session with the server, including across a Transfer,
and returns them on Cookie Request (inferred from the client storing cookies in the listener cookie map
that is carried between connections).

## 0x0C (12) Clientbound Transfer (ClientboundTransferPacket)

Play: 0x84 (132).

| Field | Type | Notes |
|---|---|---|
| Host | String(32767) | Server to connect to. |
| Port | VarInt | Port. |

The client disconnects and opens a new connection to Host:Port, sending Intention with intent 3
(transfer).

## 0x0E (14) Clientbound Update Tags (ClientboundUpdateTagsPacket)

Play: 0x89 (137). Field table only; semantics in 04-registry-sync.md.

| Field | Type | Notes |
|---|---|---|
| Registries | Map of Identifier to TagPayload | VarInt count of registries, then pairs. Key = registry key. |

TagPayload (`TagNetworkSerialization$NetworkPayload`):

| Field | Type | Notes |
|---|---|---|
| Tags | Map of Identifier to Prefixed Array of VarInt | VarInt count of tags, then pairs: tag name, then the list of registry ids of the tag's members. |

## 0x10 (16) Clientbound Custom Report Details (ClientboundCustomReportDetailsPacket)

Play: 0x8B (139).

| Field | Type | Notes |
|---|---|---|
| Details | Map of String(128) to String(4096) | At most 32 entries. Key/value strings attached to client crash reports. |

## 0x11 (17) Clientbound Server Links (ClientboundServerLinksPacket)

Play: 0x8C (140).

| Field | Type | Notes |
|---|---|---|
| Links | Prefixed Array of ServerLink | No maximum. |

ServerLink (`ServerLinks$UntrustedEntry`):

| Field | Type | Notes |
|---|---|---|
| Type | Either<IdEnum KnownLinkType, ContextFreeTextComponent> | Boolean true → a VarInt known link type follows; false → a text component label follows. |
| URL | String(32767) | |

KnownLinkType ids (`ServerLinks$KnownLinkType`, IdEnum): 0 = bug report, 1 = community guidelines,
2 = support, 3 = status, 4 = feedback, 5 = community, 6 = website, 7 = forums, 8 = news,
9 = announcements.

## 0x12 (18) Clientbound Clear Dialog (ClientboundClearDialogPacket)

Play: 0x8E (142). No fields. Closes the currently shown dialog.

## 0x13 (19) Clientbound Show Dialog (ClientboundShowDialogPacket)

Play: 0x8F (143). **The body differs between phases.**

Configuration (`CONTEXT_FREE_STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| Dialog | NBT | The dialog definition, inline, as trusted network NBT (unlimited quota) produced by `Dialog.DIRECT_CODEC`. Dialog content is out of scope. |

Play (`STREAM_CODEC`):

| Field | Type | Notes |
|---|---|---|
| Dialog | Holder<dialog> | VarInt `0` followed by the inline dialog as in configuration (trusted NBT with registry context), or VarInt `id + 1` referring to an entry of the dialog registry (00-data-types.md §10.2). |

## 0x00 (0) Serverbound Client Information (ServerboundClientInformationPacket)

Play: 0x0E (14).

| Field | Type | Notes |
|---|---|---|
| Language | String(16) | Locale, e.g. `en_us`. The reader limits it to 16 characters (`MAX_LANGUAGE_LENGTH`); the writer does not enforce that limit (it writes with the 32767 default). |
| View distance | Byte | Requested render distance in chunks. |
| Chat visibility | IdEnum ChatVisiblity (VarInt) | 0 = full, 1 = system, 2 = hidden. Out-of-range ids wrap. |
| Chat colors | Boolean | |
| Model customisation | UByte | Displayed skin parts bit mask. |
| Main hand | IdEnum HumanoidArm (VarInt) | 0 = left, 1 = right. Out-of-range ids map to 0. |
| Text filtering enabled | Boolean | |
| Allows listing | Boolean | Whether the player may appear in the status sample list. |
| Particle status | IdEnum ParticleStatus (VarInt) | 0 = all, 1 = decreased, 2 = minimal. Out-of-range ids wrap. |

Defaults used by the server before the packet arrives: `en_us`, view distance 2, full chat, colors on,
customisation 0, default main hand, filtering off, listing off, particles all.

## 0x01 (1) Serverbound Cookie Response (ServerboundCookieResponsePacket)

Play: 0x15 (21). Also login 0x04. Table in 02-handshake-status-login.md: Identifier key, then
Optional ByteArray(5120) payload. The vanilla server disconnects on unsolicited responses.

## 0x02 (2) Serverbound Custom Payload (ServerboundCustomPayloadPacket)

Play: 0x16 (22).

| Field | Type | Notes |
|---|---|---|
| Channel | Identifier | Payload type id. |
| Data | (per channel) | Rest of the packet. |

- Known channel: `minecraft:brand` (String(32767)).
- Unknown channels: opaque bytes to the end of the packet, at most **32 767** bytes (larger fails
  decoding). Note the smaller limit than the clientbound direction.

## 0x04 (4) Serverbound Keep Alive (ServerboundKeepAlivePacket)

Play: 0x1C (28).

| Field | Type | Notes |
|---|---|---|
| Id | Long | Must equal the Id of the outstanding Clientbound Keep Alive; otherwise the server disconnects (`disconnect.timeout`). |

## 0x05 (5) Serverbound Pong (ServerboundPongPacket)

Play: 0x2D (45).

| Field | Type | Notes |
|---|---|---|
| Id | Int | The Id from Clientbound Ping. |

## 0x06 (6) Serverbound Resource Pack Response (ServerboundResourcePackPacket)

Play: 0x32 (50).

| Field | Type | Notes |
|---|---|---|
| Pack id | UUID | From Resource Pack Push. |
| Action | Enum Action (VarInt ordinal) | See below. |

Action ordinals:

| Ordinal | Action | Terminal? |
|---|---|---|
| 0 | successfully loaded | yes |
| 1 | declined | yes |
| 2 | failed download | yes |
| 3 | accepted | no |
| 4 | downloaded | no |
| 5 | invalid URL | yes |
| 6 | failed reload | yes |
| 7 | discarded | yes |

A terminal action completes the configuration resource-pack task. If the action is "declined" and the
server requires its resource pack, the server disconnects the player
(`multiplayer.requiredTexturePrompt.disconnect`).

## 0x08 (8) Serverbound Custom Click Action (ServerboundCustomClickActionPacket)

Play: 0x44 (68).

| Field | Type | Notes |
|---|---|---|
| Id | Identifier | Action id (from a dialog or text click event). |
| Payload | LengthPrefixed(65536) Optional NBT | VarInt byte length (≤ 65536), then network NBT where an End root (`0x00`) means "no payload" (00-data-types.md §8). Decoding uses an NBT quota of 32 768 bytes and maximum depth 16. |

# Composite types introduced here

- **PackedRegistryEntry**, **KnownPack**, **TagPayload**, **ServerLink**, **KnownLinkType**: defined above.
- **Resource pack Action**, **ChatVisiblity**, **ParticleStatus**: enum tables above.

# Open questions

1. How the client stores cookies across transfers (lifetime, per-server scoping, maximum number) was
   not traced; only the wire limits are certain.
2. The server-side handling of a client that never sends Accept Code of Conduct (timeout or wait
   forever) was not traced.
3. The client's behavior on a Show Dialog it cannot decode, and on unknown Post Effects ids, was not
   examined.
