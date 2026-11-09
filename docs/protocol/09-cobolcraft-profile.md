# 09 — CobolCraft protocol profile

Documents 00 to 08 describe protocol 777 as the vanilla 26.3 artifact implements it. This document is
**CobolCraft's own profile** of that protocol. It states which packets CobolCraft's client and server use, the
choices the protocol leaves to a server, and which document gives the value of each field, for the two world
types of [../design/world-types.md](../design/world-types.md). Nothing here changes a packet layout: every layout is the
one of 00 to 08, and every packet id below was checked against 02, 03, 05a, 05b and 05c.

**Standard trumps stand-in** (CC-0001 Decisions; design README R2). The gameplay rules (health, hunger, damage, hurt
window, movement, day length, weather, ground items, commands, crafting grids, chat) are the standard rules of documents
10 to 21, 33 and 41 in **both** world types. This document therefore names the packet and points to the document that
owns the value, and restates a value only where CobolCraft itself chooses it. The world type selects content only (WT §1):
the **standard** type is Minecraft 26.3 content under `minecraft:` keys, the **cobolcraft** type is the invented
`cobolcraft:` content of [standin-content.md](../design/standin-content.md) plus the hand-authored core of
[cobolcraft-standard-core.md](../design/cobolcraft-standard-core.md).

Reference forms: "NN §x" is a section of docs/protocol/NN-*.md (and "02", "05c 0x29" and so on), "WT §x" is
docs/design/world-types.md, "CORE §x" is docs/design/cobolcraft-standard-core.md, "standin §n" is standin-content.md and
"README" is docs/design/README.md. Sources: `specs/001-cobolcraft-complete/contracts/wire-profile.md` §1 to §4 (the
plan-time record; this document is now the source of truth).

Wire fixtures (`contract/fixtures/wire/`, format `proto-api.md` §3: one packet body per file, packet id first) are
written by hand from this document and the documents it points to. A row whose values do not depend on the world type
has exactly the fixture files named in its last column. A row whose values do depend on it has the named fixture for the
cobolcraft type and one more with the suffix `-standard` before `.hex` for the standard type, unless the row says
"cobolcraft only" or "standard only" (§3). Every fixture file belongs to exactly one row. Fixtures whose values change
under this revision are listed in Open question 12.

## 1. Identity and security (FR-010)

- **Offline mode only** (02, Offline mode). The server never sends Encryption Request (login 0x01) and never
  enables encryption. Login Finished carries the offline UUID (`UUID.nameUUIDFromBytes("OfflinePlayer:" +
  name)`, version 3) and the name from Login Start, with an empty property map. The Login packet's
  `Online mode` field is false.
- **Player names**: 1 to 16 characters from `A`–`Z`, `a`–`z`, `0`–`9`, `_`. The client refuses to start with
  any other name (research R14); command arguments naming players follow 15 §7 and 16 §11.
- **Chat is unsigned.** The client sends Chat (05c 0x09) with no signature and Chat Command (05c 0x07) for
  commands. It never sends Chat Command Signed (05c 0x08) or Chat Session Update (05c 0x0A) (Open question 9). The
  Login packet sets `Enforces secure chat` = false. Player chat and the chat-type commands (`say`, `me`, `msg`,
  `teammsg`) are sent as Player Chat (05a 0x42) or Disguised Chat (05a 0x21) with the standard chat types of 16 §8
  (`minecraft:chat`, `say_command`, `emote_command`, `msg_command_incoming` and `_outgoing`; rows in CORE §3.5 for the
  cobolcraft type, the loaded data pack for the standard type), in both world types (README Part 7 decision 7, an
  adopted default). The chat type `cobolcraft:say` (CORE §3.5, CORE-13) is sent for registry completeness only; no
  shared engine uses it. System Chat (05b 0x7C) carries the messages of the message rule below.
- **Message rule** (operator decision A3, kept). Every message the server composes other than chat is a `translate`
  text component (00 §9) whose key is the **standard** key, in both world types. The three CobolCraft keys that have no
  standard equivalent are the exception (README S72).

  | Message | Packet(s) | Keys |
  |---|---|---|
  | Death messages | Player Combat Kill (05a 0x45) to the victim; System Chat (05b 0x7C) to every connected player | the `death.*` keys of the combat tracker (17 §4.10); the abend uses the generic mob message (README Part 7 decision 5) |
  | Command confirmations and errors, operator-status notices, announcements | System Chat (05b 0x7C) | the framework keys of 15 §5 and the per-command keys of 16 |
  | Refusals at login | Login Disconnect (login 0x00) | the ban keys of 16 §11 (`multiplayer.disconnect.banned`, `.banned.reason`, `.ip_banned`, `.banned_ip.reason`), `multiplayer.disconnect.not_whitelisted` (16 §11.22), and `cobolcraft.disconnect.name_is_host` |
  | Disconnect reasons | Disconnect (configuration 0x02, play 0x20) | `multiplayer.disconnect.kicked` (16 §11.8), `multiplayer.disconnect.server_shutdown` (16 §11.12), other standard keys of 15 §5 and 16; CobolCraft's `cobolcraft.disconnect.host_closed` and `cobolcraft.disconnect.pack_required` |

  The standard keys that no protocol document gives, such as the one for a login replacing an earlier connection, are
  GAP-27 (Open question 10). The arguments of a key are those its definition in 15 §5 or 16 gives. The text of every
  key comes from the `en_us` file of the resource pack stack (08 §10.8, 22): the generated vanilla pack in the standard
  type, and the built-in pack's fallback set in standard wording in the cobolcraft type (README P08-12, WT §7.3), so a
  pack can change it. The server console prints the same messages rendered through the `en_us` texts (operator-surface
  §3). The server-sent keys that the protocol documents name are sent as they define (FR-001):
  `multiplayer.disconnect.incompatible` and `multiplayer.disconnect.outdated_client` (protocol mismatch, §2, 02),
  `multiplayer.disconnect.transfers_disabled` (intent 3, 02), `multiplayer.disconnect.slow_login` (login not finished
  within 600 ticks, 01 §7.5, 02), `multiplayer.disconnect.unexpected_query_response` (an unsolicited Custom Query Answer
  or Cookie Response, 02), `multiplayer.disconnect.invalid_player_movement` (a non-finite or out-of-range position or
  rotation, 05c) and `disconnect.timeout` (keep-alive, 01 §7.5). Their `en_us` texts are in 08 §10.8.4.

- **Text encoding** (CobolCraft's fixed form, so encoders produce identical bytes):

  | Form | Network NBT (00 §9.1: System Chat, Player Combat Kill, configuration and play Disconnect) | JSON (00 §9.2: Login Disconnect, Status `description`) |
  |---|---|---|
  | Literal text | A bare String tag holding the text | A JSON string |
  | `translate` without arguments | Compound with one entry `translate` (String) | `{"translate":"<key>"}` |
  | `translate` with arguments | Compound with `translate` (String), then `with` (List of String, one element per argument, in order) | `{"translate":"<key>","with":["<arg1>",…]}` |

  JSON is written with no whitespace and keys in the order shown; `"` and `\` inside strings are escaped
  as `\"` and `\\`.

## 2. Transport choices

- **Network connections**: Set Compression (login 0x03) with threshold **256** immediately before Login
  Finished (login 0x02). From then on both directions use the compressed frame layout (01 §3).
- **Memory connections** (single-player, core-host-api): no Set Compression and no encryption (02, Offline
  mode). Packet ids and bodies are otherwise the same.
- **Keep-alive**: the server sends Keep Alive (configuration 0x04, play 0x2D) every 15 s in configuration and
  play, and disconnects on a missing or wrong reply as 01 §7.5 defines (reason `disconnect.timeout`, §1). The id is
  any Long the server chooses; the client echoes it at once (configuration 0x04, play 0x1C).
- **Status** (02, status phase). The Status Response JSON is exactly

  ```text
  {"version":{"name":"CobolCraft","protocol":777},"players":{"max":20,"online":<n>},"description":"<description>"}
  ```

  with `<n>` the current number of players in the world and `<description>` the configured `description`
  setting (operator-surface; default `A CobolCraft server`) as a JSON string (US2-2). `players.max` = 20 is an
  informational number shown with the count; no join limit is specified. No `favicon`, no `sample`, no
  `enforcesSecureChat` (its default false applies). Status is answered for any protocol version (02).
- **Different protocol version.** An Intention (handshake 0x00) with intent 2 (login) and a protocol version
  other than 777 is answered as 02 defines: Login Disconnect with `translate`
  `multiplayer.disconnect.incompatible` (client version ≥ 754) or `multiplayer.disconnect.outdated_client`
  (client version < 754), with one argument, the server version name `CobolCraft`, then the connection is
  closed (edge case US2). Intent 3 (transfer) is answered as a login with transfers disabled (02): Login
  Disconnect `multiplayer.disconnect.transfers_disabled`, no argument.

## 3. Packet inventory and game meaning

"S→C" is clientbound, "C→S" serverbound. Ids are shown in hex and decimal, as in 02 to 05c. Each row is one packet, or one variant
of a packet, and lists its fixture file(s). "Same layout as row …" marks a use of a packet that needs no
fixture of its own because only field values differ from a row that has one. A value a row leaves open
(entity ids, positions, state ids, Long challenges, sequences, transaction ids, pack URL and UUID, and so on)
is the fixture's own choice, recorded in its field comments; every value the row fixes is used as stated.
Encoding choices that the layouts of 00 to 08 leave open are fixed in §3.4; encoders and fixtures follow them.

Fixture names follow `<phase>-<dir>-<hex id>-<name>[-<variant>].hex` (proto-api §3), lower-case hex.

**World types in the rows.** Each row gives the value for both types, or the standard value and the cobolcraft value
side by side, or says "cobolcraft only" or "standard only". The server knows its type from `level.dat` (WT §2.1). The
client reads it from the Registry Data of `minecraft:dimension_type` at Finish Configuration (WT §7.4). The roles that
differ by key (the empty block, the player entity, the item entity, the crafting block) are the role table of WT §6.2
(Decision WT-22); a row says "player role" or "item role" where the entity type id depends on it.

Framing fixtures (01 §2, §3; not packets): `frame-uncompressed.hex` (a short packet, no compression),
`frame-compressed.hex` (a body of at least 256 bytes, zlib-wrapped, threshold 256),
`frame-below-threshold.hex` (compressed-mode frame of a short body, data length 0).

### 3.1 Handshake, status, login, configuration

Handshake, status and login:

| Dir | Id | Packet | CobolCraft values and use | Fixture |
|---|---|---|---|---|
| C→S | 0x00 (0) | Intention (handshake) | Protocol 777, the host name and port the client used, intent 1 (status). | `handshake-c2s-00-intention-status.hex` |
| C→S | 0x00 (0) | Intention (handshake) | As above with intent 2 (login). | `handshake-c2s-00-intention-login.hex` |
| C→S | 0x00 (0) | Intention (handshake) | Intent 2 (login) with a protocol other than 777; the fixture uses 776 (≥ 754, so §2's `incompatible` answer). | `handshake-c2s-00-intention-other-protocol.hex` |
| C→S | 0x00 (0) | Status Request | No fields. | `status-c2s-00-status-request.hex` |
| C→S | 0x01 (1) | Ping Request | Any Long. | `status-c2s-01-ping-request.hex` |
| S→C | 0x00 (0) | Status Response | §2 JSON. Fixture: online 0, description `A CobolCraft server`. | `status-s2c-00-status-response.hex` |
| S→C | 0x01 (1) | Pong Response | Echo of the Ping Request Long; the server then closes. | `status-s2c-01-pong-response.hex` |
| C→S | 0x00 (0) | Hello (Login Start) | Name (§1 rule) and the client's offline UUID for that name. Fixture: `Alice`. | `login-c2s-00-hello.hex` |
| C→S | 0x03 (3) | Login Acknowledged | No fields. | `login-c2s-03-login-acknowledged.hex` |
| S→C | 0x03 (3) | Set Compression | Threshold 256 (network connections only, §2). | `login-s2c-03-set-compression.hex` |
| S→C | 0x02 (2) | Login Finished | GameProfile: offline UUID, the Login Start name, 0 properties; Session id: the all-zero UUID (Open question 4). Fixture: `Alice`. | `login-s2c-02-login-finished.hex` |
| S→C | 0x00 (0) | Login Disconnect (banned) | JSON `{"translate":"multiplayer.disconnect.banned"}`, or the `.banned.reason` form with its argument, as 16 §11 gives (US2/US14 edge cases). | `login-s2c-00-login-disconnect-banned.hex` |
| S→C | 0x00 (0) | Login Disconnect (not on the allow-list) | JSON `{"translate":"multiplayer.disconnect.not_whitelisted"}` (16 §11.22). | `login-s2c-00-login-disconnect-not-allow-listed.hex` |
| S→C | 0x00 (0) | Login Disconnect (name in use by the host) | JSON `{"translate":"cobolcraft.disconnect.name_is_host","with":["<name>"]}` (US17 edge case; the host stays). Fixture name: `Alice`. | `login-s2c-00-login-disconnect-name-in-use.hex` |
| S→C | 0x00 (0) | Login Disconnect (protocol mismatch) | JSON `{"translate":"multiplayer.disconnect.incompatible","with":["CobolCraft"]}` (§2; the `outdated_client` form has the same layout). | `login-s2c-00-login-disconnect-protocol-mismatch.hex` |

A second login with a name already online closes the earlier connection first (02, US2 edge case): the earlier
connection gets a Disconnect whose key is the standard duplicate-login key (not in any document, Open question 10), in
the play layout (row `play-s2c-20-disconnect-duplicate-login` in §3.2) or the configuration layout.

Configuration (order of 03 "Configuration sequence"; no Code of Conduct, no Server Links, no Reset Chat):

| Dir | Id | Packet | CobolCraft values and use | Fixture |
|---|---|---|---|---|
| S→C | 0x01 (1) | Custom Payload | Channel `minecraft:brand`, String `cobolcraft`. | `config-s2c-01-custom-payload-brand.hex` |
| C→S | 0x02 (2) | Custom Payload | Channel `minecraft:brand`, String `cobolcraft`. | `config-c2s-02-custom-payload-brand.hex` |
| C→S | 0x00 (0) | Client Information | Language `en_us`; view distance = the client's view distance setting; chat visibility 0 (full); chat colors true; model customisation 0; main hand 1 (right); text filtering false; allows listing true; particle status 0 (all). The server reads only the view distance. | `config-c2s-00-client-information.hex` |
| S→C | 0x0D (13) | Update Enabled Features | One feature, `minecraft:vanilla` (Open question 1). | `config-s2c-0d-update-enabled-features.hex` |
| S→C | 0x0F (15) | Select Known Packs | Empty list, in both world types (04 §2 guidance, CORE §2). | `config-s2c-0f-select-known-packs.hex` |
| C→S | 0x07 (7) | Select Known Packs | Empty list. | `config-c2s-07-select-known-packs.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:worldgen/biome` | **Cobolcraft only:** 3 entries, ids 0–2: `minecraft:plains`, `cobolcraft:upland`, `cobolcraft:ash_flats` (CORE §3.4, CORE-2), each with Data present. | `config-s2c-07-registry-data-worldgen-biome.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:chat_type` | **Cobolcraft only:** 8 entries (CORE §3.5): the standard chat types of 16 §8 and `cobolcraft:say`. | `config-s2c-07-registry-data-chat-type.hex` |
| S→C | 0x07 (7) | Registry Data, each of the 13 MV registries | **Cobolcraft only:** one entry `cobolcraft:placeholder` with the standin §4.5 data, in this order: `wolf_variant`, `wolf_sound_variant`, `pig_variant`, `pig_sound_variant`, `frog_variant`, `cat_variant`, `cat_sound_variant`, `cow_sound_variant`, `cow_variant`, `chicken_sound_variant`, `chicken_variant`, `zombie_nautilus_variant`, `painting_variant` (all `minecraft:` registry keys). One fixture each. | `config-s2c-07-registry-data-wolf-variant.hex`, `config-s2c-07-registry-data-wolf-sound-variant.hex`, `config-s2c-07-registry-data-pig-variant.hex`, `config-s2c-07-registry-data-pig-sound-variant.hex`, `config-s2c-07-registry-data-frog-variant.hex`, `config-s2c-07-registry-data-cat-variant.hex`, `config-s2c-07-registry-data-cat-sound-variant.hex`, `config-s2c-07-registry-data-cow-sound-variant.hex`, `config-s2c-07-registry-data-cow-variant.hex`, `config-s2c-07-registry-data-chicken-sound-variant.hex`, `config-s2c-07-registry-data-chicken-variant.hex`, `config-s2c-07-registry-data-zombie-nautilus-variant.hex`, `config-s2c-07-registry-data-painting-variant.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:dimension_type` | **Cobolcraft only:** 2 entries: `cobolcraft:surface` (id 0), `cobolcraft:sunless` (id 1) (CORE §3.3). | `config-s2c-07-registry-data-dimension-type.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:damage_type` | **Cobolcraft only:** 52 entries, ids by CORE-2 (the 51 standard types with the values of 17 §4.12, and `cobolcraft:hail`; CORE §3.6). | `config-s2c-07-registry-data-damage-type.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:enchantment` | **Cobolcraft only:** 1 entry (CORE §3.7). | `config-s2c-07-registry-data-enchantment.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:world_clock` | **Cobolcraft only:** 1 entry (CORE §3.1); the clock key is the standard one (12 §3.2c). | `config-s2c-07-registry-data-world-clock.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:timeline` | **Cobolcraft only:** 2 entries (CORE §3.2). | `config-s2c-07-registry-data-timeline.hex` |
| S→C | 0x07 (7) | Registry Data (every registry of the loaded data pack) | **Standard only:** one packet per non-empty registry that the loaded `vanilla-data` pack defines, in the order of 04 §3, entries in the id order of 23 §3.4, entry data per the schemas of 04 §6, loaded by 23. No fixture (Open question 11). | none |
| S→C | 0x0E (14) | Update Tags | Cobolcraft: three registries, `block`, `item` and `damage_type` (CORE §4.4). Standard: the tags of the loaded data pack, resolved as 23 §6.6 gives. | `config-s2c-0e-update-tags.hex` (cobolcraft) |
| S→C | 0x09 (9) | Resource Pack Push (optional) | Only when a pack is offered (`pack-url` set, operator-surface): pack id from `pack-id`, URL `pack-url`, hash `pack-sha1` (or empty), Required false, Prompt absent (`pack-prompt` empty). 08 §9. | `config-s2c-09-resource-pack-push-optional.hex` |
| S→C | 0x09 (9) | Resource Pack Push (required, with prompt) | Required true; Prompt present, the `pack-prompt` text as a literal (§1). | `config-s2c-09-resource-pack-push-required-prompt.hex` |
| C→S | 0x06 (6) | Resource Pack Response | The Push's pack id and one action of 03's table, 0 to 7; the server waits for a terminal action (08 §9.2). Declining a required pack (action 1) makes the server send Disconnect `cobolcraft.disconnect.pack_required` (08 §9.7, US18-7). One fixture per action, same pack UUID. | `config-c2s-06-resource-pack-response-0.hex`, `config-c2s-06-resource-pack-response-1.hex`, `config-c2s-06-resource-pack-response-2.hex`, `config-c2s-06-resource-pack-response-3.hex`, `config-c2s-06-resource-pack-response-4.hex`, `config-c2s-06-resource-pack-response-5.hex`, `config-c2s-06-resource-pack-response-6.hex`, `config-c2s-06-resource-pack-response-7.hex` |
| S→C | 0x02 (2) | Disconnect (pack required) | NBT `translate` `cobolcraft.disconnect.pack_required`, no arguments. Other reasons sent during configuration (`cobolcraft.disconnect.host_closed` and the standard keys of §1) use this layout with their key. | `config-s2c-02-disconnect-pack-required.hex` |
| S→C | 0x03 (3) | Finish Configuration | No fields. | `config-s2c-03-finish-configuration.hex` |
| C→S | 0x03 (3) | Finish Configuration | No fields. | `config-c2s-03-finish-configuration.hex` |
| S→C | 0x04 (4) | Keep Alive | Any Long (§2). | `config-s2c-04-keep-alive.hex` |
| C→S | 0x04 (4) | Keep Alive | Echo of the Long. | `config-c2s-04-keep-alive.hex` |

The Registry Data packets are sent in the order of 04 §3. For the cobolcraft type that is the order of CORE §2: **20
packets and 82 entries** (3 biomes, 8 chat types, 13 variants, 2 dimension types, 52 damage types, 1 enchantment, 1 world
clock, 2 timelines); the 12 registries CORE §2 marks "none" get no packet (04 §3.2 item 5). For the standard type the
packets are whatever the loaded data pack defines (WT §4). The old counts (18 packets, 52 entries) are retired.

### 3.2 Play: world, movement, players (US2 to US4, US6)

Values that hold for every play row:

- **Dimensions.** Standard: `minecraft:overworld` (sea level 63, 10 §5) and, when `extra-dimensions` is on,
  `minecraft:the_nether` and `minecraft:the_end` (README Part 7 decision 16); the dimension type id is the entry's id in
  the loaded `minecraft:dimension_type` registry (23 §3.4). Cobolcraft: `cobolcraft:main` (dimension type id 0
  `cobolcraft:surface`, sea level 48, standin §5.1) and, when `extra-dimensions` is on, `cobolcraft:subroutine`
  (dimension type id 1 `cobolcraft:sunless`, sea level 32, standin §15.1).
- **CommonPlayerSpawnInfo** (05a, 05b): dimension type id and dimension key of the player's current dimension; hashed
  seed: standard `obfuscateSeed(Seed)` (10 §7.7, WT §2.1, inferred), cobolcraft 0 (WT §2.1); game mode 0 survival or 1
  creative; previous game mode 0 (absent); is debug false; is flat false; last death location absent; portal cooldown 0;
  sea level of the dimension.
- **Inventory slots.** Container id 0 is the player's inventory menu of **46 slots** in both world types (12 §5.6a,
  13 §3.5); Set Player Inventory uses the inventory index of 13 §3.5. The crafting bench is the 46-slot crafting menu
  (12 §5.6b) opened on the crafting block role (WT-22). Item stacks are encoded as 00 §12.1; cobolcraft items carry an
  empty component patch (standin §2).
- **Entity ids** are per-run network ids (07 §9.2). The joining player's own entity id is the Login `Entity id`.
  Entity type ids: standard 21 §2 (inferred, 46 §3); cobolcraft standin §3.

| Dir | Id | Packet | CobolCraft values and use | Fixture |
|---|---|---|---|---|
| S→C | 0x32 (50) | Login | Hardcore false; dimension names = every enabled dimension of the world type (above); max players 20; view distance and simulation distance = the configured view distance (default 8, FR-009); reduced debug info, show death screen and limited crafting from the game rules of 33 §6.4; spawn info for the player's current dimension; online mode false; enforces secure chat false. Fixture: `extra-dimensions` off, cobolcraft names [`cobolcraft:main`], spawn info of `cobolcraft:main`, view and simulation distance 8; the `-standard` fixture has names [`minecraft:overworld`]. | `play-s2c-32-login-main.hex` |
| S→C | 0x32 (50) | Login (all dimensions) | The same with every dimension of the type (cobolcraft: `cobolcraft:main`, `cobolcraft:subroutine`; standard: overworld, nether, end) (US12). | `play-s2c-32-login-all-dimensions.hex` |
| S→C | 0x27 (39) | Game Event 13 `LEVEL_CHUNKS_LOAD_START` | Value 0.0; sent after Login or Respawn, before the first chunk batch. | `play-s2c-27-game-event-13-wait-chunks.hex` |
| S→C | 0x60 (96) | Set Chunk Cache Center | The chunk of the player's feet; re-sent when the player enters another chunk (US3-4). | `play-s2c-60-set-chunk-cache-center.hex` |
| S→C | 0x0C (12) | Chunk Batch Start | No fields. | `play-s2c-0c-chunk-batch-start.hex` |
| S→C | 0x0B (11) | Chunk Batch Finished | Number of Level Chunk With Light packets in the batch. | `play-s2c-0b-chunk-batch-finished.hex` |
| S→C | 0x2E (46) | Level Chunk With Light | Chunks within view distance of the player's chunk (US3-4); payload per 06 from the generator of the world type (standard: 10, 11 and the worldgen documents; cobolcraft: standin §5.2 and §15.2) with light from the shared light engine (32). Fixture: chunk (0, 0) of `cobolcraft:main` (terrain, marker pillar, biomes, heightmaps and light). | `play-s2c-2e-level-chunk-with-light-spawn.hex` |
| S→C | 0x26 (38) | Forget Level Chunk | A chunk that left view distance. | `play-s2c-26-forget-level-chunk.hex` |
| S→C | 0x31 (49) | Light Update | Light recomputed by the engine of 32 after a block change that affects light. Fixture: the spawn chunk after its marker glowtube is toggled off (cobolcraft; light values per 32, Open question 12). | `play-s2c-31-light-update.hex` |
| S→C | 0x49 (73) | Player Position | Teleport id (per connection, counting up from 1), position, velocity (0, 0, 0), yaw, pitch, relative flags 0 (all absolute). Sent on join, on travel and on teleport. Cobolcraft fixture: spawn feet (4.5, 54.0, 8.5), yaw −90.0, pitch 0.0 (standin §5.2); the standard spawn is the world spawn of 33. | `play-s2c-49-player-position.hex` |
| S→C | 0x41 (65) | Player Abilities (creative) | Flags 0x0D (invulnerable, can fly, instant build; plus 0x02 while flying), flying speed 0.05, walking speed 0.1. The client's speeds are those of 13 §1; it does not use the speed fields. | `play-s2c-41-player-abilities-creative.hex` |
| S→C | 0x41 (65) | Player Abilities (survival) | Flags 0x00, flying speed 0.05, walking speed 0.1. | `play-s2c-41-player-abilities-survival.hex` |
| S→C | 0x63 (99) | Set Default Spawn Position | RespawnData: dimension of the world spawn, the block position of the world spawn (floor of each coordinate), its yaw, pitch 0.0. Cobolcraft fixture: `cobolcraft:main`, (4, 54, 8), yaw −90.0. Re-sent after `setworldspawn` (16 §4.7). | `play-s2c-63-set-default-spawn-position.hex` |
| S→C | 0x73 (115) | Set Time | Contents and send points per 33 §3.8: game time = the overworld game time, then the clock map (rate 0.0 when paused or `advance_time` is false). The clock is the dimension type's `default_clock` (12 §3.2c). | `play-s2c-73-set-time.hex` |
| S→C | 0x27 (39) | Game Event 3 `CHANGE_GAME_MODE` | Value 0.0 survival, 1.0 creative; sent on a game mode change (`gamemode` command, 16 §4.1). Fixture: survival. | `play-s2c-27-game-event-03-game-mode.hex` |
| S→C | 0x6B (107) | Set Held Slot | Held hotbar slot 0–8. | `play-s2c-6b-set-held-slot.hex` |
| S→C | 0x6E (110) | Set Player Inventory | One inventory index (13 §3.5) and its stack. | `play-s2c-6e-set-player-inventory.hex` |
| S→C | 0x12 (18) | Container Set Content (empty) | Container 0, a state id, 46 slots all empty, carried item empty. | `play-s2c-12-container-set-content-empty.hex` |
| S→C | 0x12 (18) | Container Set Content (starting items) | **Cobolcraft only:** the same with the starting kit of CORE §5.8 (the standard type starts empty, README Part 7 decision 6). | `play-s2c-12-container-set-content-starting-items.hex` |
| S→C | 0x14 (20) | Container Set Slot | Container 0, a state id, slot 0–45, stack. | `play-s2c-14-container-set-slot.hex` |
| S→C | 0x08 (8) | Block Update | Position and global block state id of the world type's registry (standard: 24 and 04 §5.2; cobolcraft: standin §1.2 with the bench of CORE §5.1). | `play-s2c-08-block-update.hex` |
| S→C | 0x56 (86) | Section Blocks Update | Several changes in one section. | `play-s2c-56-section-blocks-update.hex` |
| S→C | 0x04 (4) | Block Changed Ack | The sequence of the Player Action or Use Item On it answers. | `play-s2c-04-block-changed-ack.hex` |
| S→C | 0x05 (5) | Block Destruction | Break progress of a block another player is breaking. | `play-s2c-05-block-destruction.hex` |
| S→C | 0x47 (71) | Player Info Update | Actions byte 0x01 (ADD_PLAYER only): profile UUID (offline UUID), name, 0 properties. Sent for every connected player on join and to everyone when a player joins. | `play-s2c-47-player-info-update.hex` |
| S→C | 0x46 (70) | Player Info Remove | The leaving player's UUID. | `play-s2c-46-player-info-remove.hex` |
| S→C | 0x01 (1) | Add Entity (player role) | Another player within view distance in the same dimension (US3-5). Entity type: the player role (standard `minecraft:player`; cobolcraft `cobolcraft:operator`, type 0); entity UUID = the player's offline UUID; position; movement (0, 0, 0); pitch, yaw, head yaw as Angles (00 §4.4); data 0. | `play-s2c-01-add-entity-operator.hex` |
| S→C | 0x36 (54) | Move Entity Pos | Linear form (step count 0) for a position change below 8 blocks per axis; on-ground bit. Used for other players and mobs. | `play-s2c-36-move-entity-pos.hex` |
| S→C | 0x37 (55) | Move Entity Pos Rot | As 0x36 when the yaw or pitch changed too. | `play-s2c-37-move-entity-pos-rot.hex` |
| S→C | 0x39 (57) | Move Entity Rot | Only the yaw or pitch changed. | `play-s2c-39-move-entity-rot.hex` |
| S→C | 0x55 (85) | Rotate Head | Head yaw = the entity's yaw, sent with each rotation change. | `play-s2c-55-rotate-head.hex` |
| S→C | 0x80 (128) | Teleport Entity | PositionMoveRotation (position, current motion, yaw, pitch), relative flags 0, on-ground. Used for moves of 8 blocks or more per axis, where the entity tracker sends an absolute position (21 §2 gives the item entity's update interval), and after teleport. | `play-s2c-80-teleport-entity.hex` |
| S→C | 0x4E (78) | Remove Entities | Entities leaving view, the dimension or the world. | `play-s2c-4e-remove-entities.hex` |
| S→C | 0x42 (66) | Player Chat | Chat type `minecraft:chat` (CORE §3.5); the sender's profile and the message; field values for an unsigned sender are Open question 9. | `play-s2c-42-player-chat.hex` |
| S→C | 0x21 (33) | Disguised Chat | Chat type of the command (`minecraft:say_command` or `minecraft:emote_command`, 16 §8.1; `msg_command_incoming` and `_outgoing`, 16 §8.3); sender name and message as 16 §8 gives. | `play-s2c-21-disguised-chat.hex` |
| S→C | 0x7C (124) | System Chat (command feedback) | `translate` with a key of 15 §5 or 16 and its arguments, overlay false. Fixture: the feedback of `op` (16 §11.1) with the player name. | `play-s2c-7c-system-chat-command-feedback.hex` |
| S→C | 0x7C (124) | System Chat (death message) | `translate` with a `death.*` key of 17 §4.10, overlay false, to every connected player. Fixture: a fall death, argument `Alice`. | `play-s2c-7c-system-chat-death.hex` |
| S→C | 0x20 (32) | Disconnect (server stopping) | `translate` `multiplayer.disconnect.server_shutdown` (US15-2; 16 §11.12). | `play-s2c-20-disconnect-stopping.hex` |
| S→C | 0x20 (32) | Disconnect (host closed the world) | `translate` `cobolcraft.disconnect.host_closed` (US17-4). | `play-s2c-20-disconnect-host-closed.hex` |
| S→C | 0x20 (32) | Disconnect (logged in from another location) | `translate` with the standard duplicate-login key (Open question 10) (US2 edge case). | `play-s2c-20-disconnect-duplicate-login.hex` |
| S→C | 0x20 (32) | Disconnect (kicked) | `translate` `multiplayer.disconnect.kicked` with the reason argument as `kick` gives it (16 §11.8). Fixture reason: `griefing`. | `play-s2c-20-disconnect-kicked.hex` |
| S→C | 0x20 (32) | Disconnect (banned) | `translate` with the ban key of 16 §11, sent when an online player is banned. | `play-s2c-20-disconnect-banned.hex` |
| S→C | 0x2D (45) | Keep Alive | Any Long (§2). | `play-s2c-2d-keep-alive.hex` |
| C→S | 0x00 (0) | Accept Teleportation | The Player Position's teleport id and the applied position and rotation. | `play-c2s-00-accept-teleportation.hex` |
| C→S | 0x0B (11) | Chunk Batch Received | Desired chunks per tick 9.0. | `play-c2s-0b-chunk-batch-received.hex` |
| C→S | 0x2C (44) | Player Loaded | No fields; once per join, respawn and travel. | `play-c2s-2c-player-loaded.hex` |
| C→S | 0x0D (13) | Client Tick End | No fields; every client tick. | `play-c2s-0d-client-tick-end.hex` |
| C→S | 0x1C (28) | Keep Alive | Echo of the Long. | `play-c2s-1c-keep-alive.hex` |
| C→S | 0x1E (30) | Move Player Pos | Feet position; MoveFlags (0x01 on ground, 0x02 horizontal collision). | `play-c2s-1e-move-player-pos.hex` |
| C→S | 0x1F (31) | Move Player Pos Rot | Position, yaw, pitch, MoveFlags. | `play-c2s-1f-move-player-pos-rot.hex` |
| C→S | 0x20 (32) | Move Player Rot | Yaw, pitch, MoveFlags. | `play-c2s-20-move-player-rot.hex` |
| C→S | 0x21 (33) | Move Player Status Only | MoveFlags. | `play-c2s-21-move-player-status-only.hex` |
| C→S | 0x28 (40) | Player Abilities | Flags 0x02 while flying (creative), otherwise 0x00. Fixture: flying. | `play-c2s-28-player-abilities.hex` |
| C→S | 0x29 (41) | Player Action 0 `START_DESTROY_BLOCK` | Break start: block position, face (UByte, 0 down … 5 east), sequence. In creative a break completes on this action alone (13 §2.5). | `play-c2s-29-player-action-start-destroy.hex` |
| C→S | 0x29 (41) | Player Action 2 `ABORT_DESTROY_BLOCK` | Break cancelled. | `play-c2s-29-player-action-abort-destroy.hex` |
| C→S | 0x29 (41) | Player Action 3 `STOP_DESTROY_BLOCK` | Survival break finished after the break time of the shared formula (13 §2.1: hardness, tool, tier; cobolcraft blocks per CORE §5.1). | `play-c2s-29-player-action-stop-destroy.hex` |
| C→S | 0x42 (66) | Use Item On | Hand 0 (main); the hit block, face (VarInt), cursor, inside, world border hit; sequence. Places the held block item and interacts with blocks as 29 gives; the cobolcraft-only interactions (glowtube toggle, `goto_pad` travel) are standin §1.3 and §3.3. | `play-c2s-42-use-item-on.hex` |
| C→S | 0x36 (54) | Set Carried Item | Hotbar slot 0–8 (Short). | `play-c2s-36-set-carried-item.hex` |
| C→S | 0x12 (18) | Container Click | The open container (0 or the bench's), state id, slot per 13 §3.5 (−999 outside), button, click type, changed slots, carried item (HashedStack, 05c). THROW (4) on a slot and PICKUP (0) at −999 throw items (41 §2.3). | `play-c2s-12-container-click.hex` |
| C→S | 0x13 (19) | Container Close | The open container, sent when its screen is left; the carried stack and the crafting grid are handled as 13 §3.5 gives. | `play-c2s-13-container-close.hex` |
| C→S | 0x39 (57) | Set Creative Mode Slot | Inventory index (13 §3.5) and stack; acted on only for a creative player (creative drop: 41 §2.3.1). | `play-c2s-39-set-creative-mode-slot.hex` |
| C→S | 0x09 (9) | Chat | Message (≤ 256 characters); timestamp = the client's clock in ms (not used by the server); salt 0; signature absent; last seen messages: offset 0, acknowledged `00 00 00`, checksum 0 (§1). | `play-c2s-09-chat.hex` |

**Join sequence.** On joining play, and after Respawn (§3.3 travel, death respawn), the server sends the S→C packets of
this table that apply to the player's state and dimension, in the order of 33 §6.4 (read from `placeNewPlayer` and
`sendLevelInfo`), in both world types; the cobolcraft-only rows (starting items) are added where the type has them. The
client relies only on these orders: Login or Respawn first; Game Event 13 before the first chunk batch; chunks only
between Chunk Batch Start and Chunk Batch Finished. This satisfies 05c "Minimum required serverbound traffic" for the
client's replies.

### 3.3 Play: gameplay (shared rules)

The values of every row below are the shared standard rules of documents 12, 13, 15 to 21, 33, 39 and 41; a row names
the packet and the document and states a value only where CobolCraft chooses it. Rows marked "cobolcraft only" belong
to the content of standin-content.md. The old stand-in values (health 30, food 24, hurt cooldown 12, drop delays, 4800
despawn, the 29-command set, crafting without a block) are retired in both world types (README R2).

| Need | Dir | Id | Packet | Values and meaning | Fixture |
|---|---|---|---|---|---|
| Ground items | S→C | 0x01 (1) | Add Entity (item role) | Entity type: the item role (standard `minecraft:item`, cobolcraft `cobolcraft:loose_item`, type 1); entity UUID: most significant 64 bits 0, least significant 64 bits = the entity id; position and initial motion per the spawn source in 41 §2; angles 0; data 0. Followed by Set Entity Data. | `play-s2c-01-add-entity-loose-item.hex` |
| | S→C | 0x65 (101) | Set Entity Data (item stack) | Entity id; the item entity's stack entry with the index and serializer of 21 App A, holding the stack (00 §12.1); then `0xFF`. Sent after Add Entity and whenever the stack changes (merge or pickup, 41 §4). | `play-s2c-65-set-entity-data-item.hex` |
| | S→C | 0x67 (103) | Set Entity Motion | Entity id; motion as LpVec3; when sent: §3.4 rule 6. | `play-s2c-67-set-entity-motion.hex` |
| | S→C | 0x80 (128) | Teleport Entity | As the row of §3.2. | Same layout as row 0x80 of §3.2 |
| | S→C | 0x7F (127) | Take Item Entity | Collected = the item's entity id, collector = the player's, amount = items taken (41 §4.2); then Remove Entities if none remain. | `play-s2c-7f-take-item-entity.hex` |
| | S→C | 0x4E (78) | Remove Entities | Picked up completely, or despawned (lifetime 6000, 18 §6.11). | Same layout as row 0x4E of §3.2 |
| | C→S | 0x29 (41) | Player Action 4 `DROP_ALL_ITEMS` | Throw the whole held stack (41 §2.3). Location (0, 0, 0), face 0, sequence 0. | `play-c2s-29-player-action-drop-all-items.hex` |
| | C→S | 0x29 (41) | Player Action 5 `DROP_ITEM` | Throw one item. Location (0, 0, 0), face 0, sequence 0. | `play-c2s-29-player-action-drop-item.hex` |
| Health | S→C | 0x6A (106) | Set Health | Health, food and saturation as 17 §4.9 gives (food 0 to 20, real saturation); HUD 12 §5.4. | `play-s2c-6a-set-health.hex` |
| | S→C | 0x19 (25) | Damage Event | Damaged entity id; damage type id in the world type's `damage_type` registry (17 §4.12; cobolcraft ids CORE §3.6); source cause id and source direct id = attacker entity id + 1, or 0 with no attacker; source position absent (Open question 12). | `play-s2c-19-damage-event.hex` |
| | S→C | 0x2B (43) | Hurt Animation | Damaged entity id; yaw 0.0. | `play-s2c-2b-hurt-animation.hex` |
| | S→C | 0x45 (69) | Player Combat Kill | The dead player's entity id; message = the death message of 17 §4.10 (`translate`, §1). The death screen shows it as the cause line. | `play-s2c-45-player-combat-kill.hex` |
| | S→C | 0x54 (84) | Respawn (after `PERFORM_RESPAWN`) | Spawn info of the respawn dimension, data to keep 0x00 (Open question 6), then the join sequence; position, health, food and drops per 17 §4.10 (respawn point, else world spawn, 33). | Same layout as `play-s2c-54-respawn-main.hex` (only the data-to-keep byte differs) |
| | C→S | 0x01 (1) | Attack | Target entity id (17 §4.1). | `play-c2s-01-attack.hex` |
| | C→S | 0x0C (12) | Client Command | Action 0 `PERFORM_RESPAWN` (US7-4). Actions 1 and 2 are never sent. | `play-c2s-0c-client-command-respawn.hex` |
| Hunger | S→C | 0x6A (106) | Set Health (food field) | Food display. | Same as the Set Health row |
| | S→C | 0x22 (34) | Entity Event (eating finished) | Entity id (Int) = the eater; event id 9 (Open question 7), to the player and its viewers. | `play-s2c-22-entity-event-eating-finished.hex` |
| | C→S | 0x2A (42) | Player Command 1 `START_SPRINTING` | Entity id = the player's own, data 0; the sprint exhaustion is 17 §4.9. | `play-c2s-2a-player-command-start-sprinting.hex` |
| | C→S | 0x2A (42) | Player Command 2 `STOP_SPRINTING` | As above. | `play-c2s-2a-player-command-stop-sprinting.hex` |
| | C→S | 0x43 (67) | Use Item | Hand 0, sequence, yaw, pitch. Starts consuming the held item per its `consumable` component (17 §1.2, §4.9). | `play-c2s-43-use-item.hex` |
| | C→S | 0x29 (41) | Player Action 6 `RELEASE_USE_ITEM` | Stops consuming early. Location (0, 0, 0), face 0, sequence 0. | `play-c2s-29-player-action-release-use-item.hex` |
| Mobs | S→C | 0x01 (1) | Add Entity (mob) | Entity type id of the mob in the world type's registry (standard 21 §2 and the mob's document 19 to 21; cobolcraft `sodgrazer` type 2 and `abend` type 3, standin §3); UUID as for ground items; position; movement (0, 0, 0); pitch 0, yaw and head yaw = the mob's yaw; data 0; metadata per 21 App A. Fixtures: cobolcraft `sodgrazer` and `abend`; the `-standard` fixture is a `cow`. | `play-s2c-01-add-entity-sodgrazer.hex`, `play-s2c-01-add-entity-abend.hex` |
| | S→C | 0x36 (54) / 0x37 (55) / 0x39 (57), 0x55 (85), 0x80 (128), 0x2B (43), 0x4E (78) | Move Entity, Rotate Head, Teleport Entity, Hurt Animation, Remove Entities | Mob movement per 18 §3, attack feedback and defeat per 17 §4 and 18 §7. | Same layouts as the §3.2 rows and the Hurt Animation row |
| Crafting | S→C | 0x4B (75) | Recipe Book Add | Layout 05b; entries and unlocks per 13 §3.9 and 27, from the recipe set of the type (standard: the loaded data pack; cobolcraft: CORE §5.7). The craftable flag choice of Open question 3 stays until compared with 13 §3.9. There is no crafting screen: crafting is the inventory 2×2 grid and the bench 3×3 grid (README R6). | `play-s2c-4b-recipe-book-add.hex` |
| | C→S | 0x27 (39) | Place Recipe | Container id of the open menu (inventory 0 or the bench), recipe = display id of the Recipe Book Add; the grid fill rule is 13 §3.8. Fixture: display id 0. | `play-c2s-27-place-recipe.hex` |
| | S→C | 0x3C (60) | Open Screen (bench) | Window id, the crafting menu type (46 §5.5, 12 §5.6b), the title (Open question 12); opened on the crafting block role (WT-22: `minecraft:crafting_table`, or `cobolcraft:crafting_bench`, CORE §5.9). | `play-s2c-3c-open-screen-crafting.hex` |
| Weather | S→C | 0x27 (39) | Game Event 1 `START_RAINING` | Value 0.0; sent, with the audiences and order of 33 §4.2, when raining begins and in the join sequence (33 §6.4). | `play-s2c-27-game-event-01-start-raining.hex` |
| | S→C | 0x27 (39) | Game Event 2 `STOP_RAINING` | Value 0.0; as above when raining ends. | `play-s2c-27-game-event-02-stop-raining.hex` |
| | S→C | 0x27 (39) | Game Event 7 `RAIN_LEVEL_CHANGE` | Value = the server's rain level (33 §4.2). Fixture: 1.0. | `play-s2c-27-game-event-07-rain-level.hex` |
| | S→C | 0x27 (39) | Game Event 8 `THUNDER_LEVEL_CHANGE` | Value = the server's thunder level (33 §4.2). Fixture: 1.0. | `play-s2c-27-game-event-08-thunder-level.hex` |
| Dimensions (standard) | S→C | 0x54 (84) | Respawn (portal travel) | **Standard only:** spawn info of the target dimension; data to keep and the arrival rules per 39. | `play-s2c-54-respawn-main-standard.hex` (to `minecraft:overworld`) |
| Dimensions (cobolcraft) | C→S | 0x42 (66) | Use Item On a `goto_pad` | **Cobolcraft only:** the trigger is Use Item On aimed at a `cobolcraft:goto_pad` block (block id 10, state 16), any hand item or none, either game mode (standin §15.5). | Same layout as row 0x42 of §3.2 |
| | S→C | 0x54 (84) | Respawn (to `cobolcraft:main`) | **Cobolcraft only:** spawn info of `cobolcraft:main` (type 0, sea level 48); data to keep 0x03; then the join sequence for that dimension, including its weather. Arrival point per standin §15.5. | `play-s2c-54-respawn-main.hex` |
| | S→C | 0x54 (84) | Respawn (to `cobolcraft:subroutine`) | **Cobolcraft only:** spawn info of `cobolcraft:subroutine` (type 1, sea level 32); data to keep 0x03. | `play-s2c-54-respawn-subroutine.hex` |
| Commands | S→C | 0x10 (16) | Commands (level 0) | The standard command tree filtered for a player with permission level 0 (15 §3.3, §2); wire 15 §3.4 and 05a 0x10; child order 15 §3.2. Sent after login and whenever the permission level changes (15 §3.3). | `play-s2c-10-commands-everyone.hex` |
| | S→C | 0x10 (16) | Commands (operator) | The same for a level 4 player. | `play-s2c-10-commands-operator.hex` |
| | S→C | 0x0F (15) | Command Suggestions | Transaction id of the request; start and length of the word being completed; one entry per suggestion, from the argument's provider (15 §3.5, §6). In the cobolcraft type item, entity type and dimension arguments suggest `cobolcraft:` keys (WT §6.3). | `play-s2c-0f-command-suggestions.hex` |
| | C→S | 0x0F (15) | Command Suggestion | Transaction id; the partial command text. | `play-c2s-0f-command-suggestion.hex` |
| | C→S | 0x07 (7) | Chat Command | The command text without the leading `/` (unsigned form, Open question 9). | `play-c2s-07-chat-command.hex` |
| Packs | S→C | 0x52 (82) | Resource Pack Push (play) | As the configuration rows (08 §9). | `play-s2c-52-resource-pack-push.hex` |
| | C→S | 0x32 (50) | Resource Pack Response (play) | As the configuration row. | `play-c2s-32-resource-pack-response.hex` |

**Weather and the cobolcraft skin.** The wire is the standard one: a rain level and a thunder level (33 §4). In the
cobolcraft type `drizzle` is rain and `hailstorm` is thunder, a drawing skin only (README Part 7 decision 5, standin §14
as re-scoped), so no wire kind exists. Whether a biome has precipitation comes from the biome row (CORE §3.4) and the
rain or snow test of 33 §4.5.

**Command tree.** CobolCraft sends no fixed tree. The commands are the standard set of 15 §1 and 16 in both world types
(README R3); in the cobolcraft type their item, entity type and dimension arguments resolve the `cobolcraft:` registries
(WT §6.3, Decision WT-13: no namespace fallback). The 29-command stand-in set and its 90-node tree are retired
(README S69, S70).

### 3.4 Encoding conventions (byte-exact fixtures)

Where 00 to 08 and the content documents leave a byte-level choice open, CobolCraft's encoders make this one, and the
fixtures follow it:
1. **Indirect palettes** (Linear and HashMap, block states and biomes, 06 §5.2): the palette lists the distinct
   values in order of first occurrence, scanning entry indices from 0 upward (06 §5.4 index order). The block
   Linear kind is written with bits byte 4.
2. **LightData in Level Chunk With Light** (06 §7): every light section index (0 to section count + 1) is
   reported. A layer whose 4096 values are all 0 sets only its bit in the empty mask, for block light as for sky
   light, and sends no array; every other layer is a 2048-byte array. Each ByteBitSet is written with the
   fewest bytes that hold its highest set bit (no trailing zero bytes; an empty set has length 0).
3. **Light Update** (0x31) after a light-emitting block is placed, broken or toggled: one packet per chunk
   whose light changed. It carries only that chunk's light sections in which sky or block light changed, and
   for each of them both kinds (array, or empty-mask bit when all 0, as rule 2); every other bit is clear in all
   four masks. Light that reaches a neighbouring chunk is sent in that chunk's own Light Update.
4. **Block light spread** is the shared light engine of 32 in both world types; the stand-in rule is retired.
5. **Command Suggestion** (C→S 0x0F): the text is the chat line as typed, including its leading `/`.
   Command Suggestions (S→C 0x0F) Start is counted in characters of that text, the `/` included (`/murmur Al`
   completes `Al` at start 8, length 2).
6. **Set Entity Motion** (0x67) for a ground item is sent once, right after its Add Entity and Set Entity Data, when its
   initial motion (41 §2, death drops 17 §4.10) is not (0, 0, 0): it carries that motion. Later movement is sent as the
   entity tracker sends it (Open question 12).
7. **Teleport Entity** (0x80): the motion is the entity's current motion; for a player (moves of 8 blocks or
   more, relocation) it is (0, 0, 0), since the server keeps no player motion.
8. **Play Resource Pack Push** (0x52): the fixture uses the optional form (Required false, Prompt absent),
   like `config-s2c-09-resource-pack-push-optional.hex`; the required form has the layout of
   `config-s2c-09-resource-pack-push-required-prompt.hex`.
9. **Registry Data entry NBT** (§3.1): each Compound holds its fields in the order of the schema of 04 §6 for its
   registry, in both world types, with NBT types per 04 §6. For the cobolcraft type the values are those of the CORE §3
   rows (CORE writes them as JSON, which is not an order: Open question 11). A field a row gives as absent is not
   written; a value a row states is written even when it equals the codec default. Colour strings are written exactly as
   the row writes them (upper-case hex). Booleans are Byte 0 or 1. An empty List (`infiniburn`) has element type 0 (07
   §1.1). A sound is the inline Compound `{sound_id}`; the painting `title` is a bare String tag.
10. **Angle** (00 §4.4): encode `floor(degrees × 256 / 360)` truncated to 8 bits; 180.0 encodes as `0x80`,
    which decodes (signed) as −180.0, the same direction. Fixtures that state 180.0 expect −180.0 from a
    decoder.

## 4. Packets CobolCraft never sends

Everything not listed in §3. Neither side implements packets outside this inventory. Receiving one is
handled as 01 §5 defines for a packet the receiver cannot decode: the connection is closed (or, for a packet
the protocol marks skippable, the frame is discarded). The exception is an unsolicited Custom Query Answer
(login) or Cookie Response (login, configuration, play): as 02 defines, the server disconnects with
`multiplayer.disconnect.unexpected_query_response` (Login Disconnect in login, Disconnect otherwise) and
closes the connection. In particular CobolCraft never uses Encryption Request
and Response, Custom Query, cookies, Transfer, Code of Conduct, Server Links, dialogs, Bundle Delimiter (the server
never sends it; whether the client must accept it from a vanilla-like server is Open question 12), Chat Session Update,
signed chat commands or Start Configuration. Player Chat and Disguised Chat are used (§3.2).

## Open questions

1. ~~**Update Enabled Features.**~~ Resolved: the single flag `minecraft:vanilla`, as §3.1 and contracts/wire-profile.md
   §3.1 state, in both world types.
2. ~~**Protocol-defined disconnect keys and the message rule.**~~ Resolved. The server sends the seven protocol-named keys
   of §1 as 01, 02 and 05c define them (FR-001), each with an `en_us` text in 08 §10.8.4. The declined-required-pack case
   is settled by 08 §9.8: the server sends `cobolcraft.disconnect.pack_required`.
3. **Craftable flag.** The contract asks for a per-player "craftable flag" in Recipe Book Add, but 05b's
   RecipeBookAddEntry has no such field (its Flags byte holds only notification and highlight). Until it is compared with
   13 §3.9 and 27, craftability is the presence of the `Crafting requirements` field (present = craftable), which
   `contract/copy/PROTO.cpy` (`PB-RD-REQ-PRESENT`) already models. The recipe book category is fixed at 0 (the static
   `recipe_book_category` registry is never synchronized). The old fixture note (nine cobolcraft recipes, per-inventory
   craftability) is retired; the cobolcraft recipes are CORE §5.7.
4. **Login Finished session id.** 02 shows a `Session id` UUID after the profile; the contract does not mention it.
   CobolCraft sends the all-zero UUID and the client ignores it.
5. ~~**Inventory slot numbering.**~~ Resolved: container 0 is the 46-slot inventory menu in both world types (§3.2). A
   vanilla client can play only the standard world type (README R8); the cobolcraft type passes configuration only
   (04 §5, WT §1).
6. **Choices this document fixes that no source gave**, so that encoders agree byte for byte: Player Info Update actions
   (ADD_PLAYER only), UUIDs of mobs and ground items (entity id in the low 64 bits), Respawn after death with data to keep
   0x00 (the contract gives 0x03 only for travel), Hurt Animation yaw 0.0, Login max players 20, Player Abilities speeds
   0.05 and 0.1, Chunk Batch Received 9.0, Chat salt 0, and the text encoding of §1.
7. **Entity Event 9.** The event id for "eating finished" is CobolCraft's own (05a 0x22 does not enumerate event ids);
   the standin §11.6 rule that cited it is retired, and 17 §4.9 owns consumption.
8. **Brigadier string kinds** (05a Open question 1): inferred ordinals; both ends are CobolCraft's. The Commands packet's
   parsers are now those of 15 §6 and 15a.
9. **Chat signing under standard chat.** README Part 7 decision 7 (an adopted default, not an operator ruling) sends
   Player Chat and Disguised Chat. Not settled by any document: the field values of Player Chat for an unsigned sender, and
   whether a client with no chat session sends Chat Command Signed for commands with signed arguments (`msg`, `say`, `me`).
10. **Standard keys that no document gives** (GAP-27): the duplicate-login disconnect key, the argument forms of the ban
    and kick keys, and the generic mob death message key. Fixtures use them only after a read round gives them.
11. **Fixtures of the standard world type and field order.** The standard Registry Data rows come from the generated data
    pack (22), so no byte fixture of them exists until the loader of 23 does. 04 §6 gives schemas but this document has not
    checked that its field order is the wire order for every registry; CORE writes rows as JSON.
12. **Revision leftovers.** (a) Fixtures to regenerate: every row of §3.2 and §3.3 whose text changed, the Registry
    Data and Update Tags fixtures (CORE §2 counts), the Light Update and Level Chunk fixtures (light now from 32), the Login
    fixtures (46-slot menu, hashed seed), and `play-s2c-27-game-event-07-rain-level.hex`, `-08-thunder-level.hex` and
    the death, kick and ban fixtures (new keys). (b) Not checked here: the Open Screen title for the bench, the recipients
    of Set Health, the source fields of Damage Event, whether `Teleport Entity` or motion packets carry later item motion,
    whether the client must accept Bundle Delimiter, the Respawn data-to-keep for portals (39), the sea level of
    `cobolcraft:main` (not a `dimension_type` field, CORE Open question 26), and the fixture policy for the `-standard`
    variants.
