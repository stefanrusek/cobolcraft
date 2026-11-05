# 09 — CobolCraft protocol profile

Documents 00 to 08 describe protocol 777 as the vanilla 26.3 artifact implements it. This document is
**CobolCraft's own profile** of that protocol. It states which packets CobolCraft's client and server use, the
choices the protocol leaves to a server, and the game meaning CobolCraft gives to packets for the content of
[../design/standin-content.md](../design/standin-content.md) (as extended by FR-015). Nothing here changes a
packet layout: every layout is the one of 00 to 08, and every packet id below was checked against 02, 03, 05a,
05b and 05c.

Sources: `specs/001-cobolcraft-complete/contracts/wire-profile.md` §1 to §4 (the plan-time record; this
document is now the source of truth), with every content reference resolved against the extended
standin-content. Section references of the form "standin §n" point into standin-content.md; "02", "05c 0x29"
and so on point into this folder.

Wire fixtures (`contract/fixtures/wire/`, format `proto-api.md` §3: one packet body per file, packet id first)
are written by hand from this document and 00 to 08. Every row of the §3 tables has exactly the fixture files
named in its last column, and every fixture file belongs to exactly one row.

## 1. Identity and security (FR-010)

- **Offline mode only** (02, Offline mode). The server never sends Encryption Request (login 0x01) and never
  enables encryption. Login Finished carries the offline UUID (`UUID.nameUUIDFromBytes("OfflinePlayer:" +
  name)`, version 3) and the name from Login Start, with an empty property map. The Login packet's
  `Online mode` field is false.
- **Player names**: 1 to 16 characters from `A`–`Z`, `a`–`z`, `0`–`9`, `_`. The client refuses to start with
  any other name (research R14); command arguments naming players use the same rule (standin §16.1).
- **Chat is unsigned.** The client sends Chat (05c 0x09) with no signature and Chat Command (05c 0x07) for
  commands. It never sends Chat Command Signed (05c 0x08) or Chat Session Update (05c 0x0A). The Login packet
  sets `Enforces secure chat` = false. The server broadcasts player chat as System Chat (05b 0x7C) with the
  literal text `<name> message`. The `chat_type` entry `cobolcraft:say` (standin §4.4) is sent for registry
  completeness only; Player Chat (05a 0x42) and Disguised Chat (05a 0x21) are never sent.
- **Message rule** (operator decision A3). Every message the server composes is a `translate` text component
  (00 §9) whose key and arguments come from standin §10.7, §16 and §17:

  | Message | Packet(s) | Keys |
  |---|---|---|
  | Death messages | Player Combat Kill (05a 0x45) to the victim; System Chat (05b 0x7C) to every connected player | `cobolcraft.death.*` (standin §10.7) |
  | Command confirmations and errors, operator-status notices, private messages, announcements | System Chat (05b 0x7C) | `cobolcraft.command.*` (standin §16.2, §16.4) |
  | Refusals at login | Login Disconnect (login 0x00) | `cobolcraft.disconnect.barred`, `cobolcraft.disconnect.not_on_guestlist`, `cobolcraft.disconnect.name_is_host` (standin §17) |
  | Disconnect reasons | Disconnect (configuration 0x02, play 0x20) | `cobolcraft.disconnect.*` (standin §17) |

  Every argument is a plain literal text (standin §10.7, §16.1, §17). The text of every key is in the
  built-in pack's `en_us` lang file (08 §10.8), so a pack can change it. **Only player-authored chat is
  literal text** (`<name> message`). The server console prints the same messages rendered through the
  `en_us` texts (operator-surface §3). The only server-sent keys outside standin-content are the seven
  disconnect reasons the protocol documents name, sent as they define (FR-001):
  `multiplayer.disconnect.incompatible` and `multiplayer.disconnect.outdated_client` (protocol mismatch,
  §2, 02), `multiplayer.disconnect.transfers_disabled` (intent 3, 02), `multiplayer.disconnect.slow_login`
  (login not finished within 600 ticks, 01 §7.5, 02), `multiplayer.disconnect.unexpected_query_response`
  (an unsolicited Custom Query Answer or Cookie Response, 02), `multiplayer.disconnect.invalid_player_movement`
  (a non-finite or out-of-range position or rotation, 05c) and `disconnect.timeout` (keep-alive, 01 §7.5).
  Their `en_us` texts are in 08 §10.8.4.

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
| S→C | 0x00 (0) | Login Disconnect (banned) | JSON `{"translate":"cobolcraft.disconnect.barred"}` (US2/US14 edge cases). | `login-s2c-00-login-disconnect-banned.hex` |
| S→C | 0x00 (0) | Login Disconnect (not on the allow-list) | JSON `{"translate":"cobolcraft.disconnect.not_on_guestlist"}`. | `login-s2c-00-login-disconnect-not-allow-listed.hex` |
| S→C | 0x00 (0) | Login Disconnect (name in use by the host) | JSON `{"translate":"cobolcraft.disconnect.name_is_host","with":["<name>"]}` (US17 edge case; the host stays). Fixture name: `Alice`. | `login-s2c-00-login-disconnect-name-in-use.hex` |
| S→C | 0x00 (0) | Login Disconnect (protocol mismatch) | JSON `{"translate":"multiplayer.disconnect.incompatible","with":["CobolCraft"]}` (§2; the `outdated_client` form has the same layout). | `login-s2c-00-login-disconnect-protocol-mismatch.hex` |

A second login with a name already online closes the earlier connection first (02, US2 edge case): the earlier
connection gets Disconnect `cobolcraft.disconnect.replaced` (play row `play-s2c-20-disconnect-duplicate-login`
in §3.2, or the configuration Disconnect with the same component).

Configuration (order of 03 "Configuration sequence"; no Code of Conduct, no Server Links, no Reset Chat):

| Dir | Id | Packet | CobolCraft values and use | Fixture |
|---|---|---|---|---|
| S→C | 0x01 (1) | Custom Payload | Channel `minecraft:brand`, String `cobolcraft`. | `config-s2c-01-custom-payload-brand.hex` |
| C→S | 0x02 (2) | Custom Payload | Channel `minecraft:brand`, String `cobolcraft`. | `config-c2s-02-custom-payload-brand.hex` |
| C→S | 0x00 (0) | Client Information | Language `en_us`; view distance = the client's view distance setting; chat visibility 0 (full); chat colors true; model customisation 0; main hand 1 (right); text filtering false; allows listing true; particle status 0 (all). The server reads only the view distance. | `config-c2s-00-client-information.hex` |
| S→C | 0x0D (13) | Update Enabled Features | One feature, `minecraft:vanilla` (Open question 1). | `config-s2c-0d-update-enabled-features.hex` |
| S→C | 0x0F (15) | Select Known Packs | Empty list (standin §4.1). | `config-s2c-0f-select-known-packs.hex` |
| C→S | 0x07 (7) | Select Known Packs | Empty list. | `config-c2s-07-select-known-packs.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:worldgen/biome` | 3 entries, ids 0–2: `minecraft:plains`, `cobolcraft:upland`, `cobolcraft:ash_flats` (standin §4.3), each with Data present. | `config-s2c-07-registry-data-worldgen-biome.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:chat_type` | 1 entry `cobolcraft:say` (standin §4.4). | `config-s2c-07-registry-data-chat-type.hex` |
| S→C | 0x07 (7) | Registry Data, each of the 13 MV registries | One entry `cobolcraft:placeholder` with the standin §4.5 data, in this order: `wolf_variant`, `wolf_sound_variant`, `pig_variant`, `pig_sound_variant`, `frog_variant`, `cat_variant`, `cat_sound_variant`, `cow_sound_variant`, `cow_variant`, `chicken_sound_variant`, `chicken_variant`, `zombie_nautilus_variant`, `painting_variant` (all `minecraft:` registry keys). One fixture each. | `config-s2c-07-registry-data-wolf-variant.hex`, `config-s2c-07-registry-data-wolf-sound-variant.hex`, `config-s2c-07-registry-data-pig-variant.hex`, `config-s2c-07-registry-data-pig-sound-variant.hex`, `config-s2c-07-registry-data-frog-variant.hex`, `config-s2c-07-registry-data-cat-variant.hex`, `config-s2c-07-registry-data-cat-sound-variant.hex`, `config-s2c-07-registry-data-cow-sound-variant.hex`, `config-s2c-07-registry-data-cow-variant.hex`, `config-s2c-07-registry-data-chicken-sound-variant.hex`, `config-s2c-07-registry-data-chicken-variant.hex`, `config-s2c-07-registry-data-zombie-nautilus-variant.hex`, `config-s2c-07-registry-data-painting-variant.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:dimension_type` | 2 entries: `cobolcraft:surface` (id 0), `cobolcraft:sunless` (id 1) (standin §4.6). | `config-s2c-07-registry-data-dimension-type.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:damage_type` | 32 entries: ids 0–2 ours, 3–27 the 25 compat keys, 28–31 ours (standin §4.7). | `config-s2c-07-registry-data-damage-type.hex` |
| S→C | 0x07 (7) | Registry Data `minecraft:world_clock` | 1 entry `cobolcraft:daylight`, empty Compound (standin §4.8). | `config-s2c-07-registry-data-world-clock.hex` |
| S→C | 0x0E (14) | Update Tags | Zero registries (standin §6). | `config-s2c-0e-update-tags.hex` |
| S→C | 0x09 (9) | Resource Pack Push (optional) | Only when a pack is offered (`pack-url` set, operator-surface): pack id from `pack-id`, URL `pack-url`, hash `pack-sha1` (or empty), Required false, Prompt absent (`pack-prompt` empty). 08 §9. | `config-s2c-09-resource-pack-push-optional.hex` |
| S→C | 0x09 (9) | Resource Pack Push (required, with prompt) | Required true; Prompt present, the `pack-prompt` text as a literal (§1). | `config-s2c-09-resource-pack-push-required-prompt.hex` |
| C→S | 0x06 (6) | Resource Pack Response | The Push's pack id and one action of 03's table, 0 to 7; the server waits for a terminal action (08 §9.2). Declining a required pack (action 1) makes the server send Disconnect `cobolcraft.disconnect.pack_required` (08 §9.7, US18-7). One fixture per action, same pack UUID. | `config-c2s-06-resource-pack-response-0.hex`, `config-c2s-06-resource-pack-response-1.hex`, `config-c2s-06-resource-pack-response-2.hex`, `config-c2s-06-resource-pack-response-3.hex`, `config-c2s-06-resource-pack-response-4.hex`, `config-c2s-06-resource-pack-response-5.hex`, `config-c2s-06-resource-pack-response-6.hex`, `config-c2s-06-resource-pack-response-7.hex` |
| S→C | 0x02 (2) | Disconnect (pack required) | NBT `translate` `cobolcraft.disconnect.pack_required`, no arguments. Other standin §17 reasons sent during configuration (`replaced`, `shutdown`, `host_closed`) use this layout with their key. | `config-s2c-02-disconnect-pack-required.hex` |
| S→C | 0x03 (3) | Finish Configuration | No fields. | `config-s2c-03-finish-configuration.hex` |
| C→S | 0x03 (3) | Finish Configuration | No fields. | `config-c2s-03-finish-configuration.hex` |
| S→C | 0x04 (4) | Keep Alive | Any Long (§2). | `config-s2c-04-keep-alive.hex` |
| C→S | 0x04 (4) | Keep Alive | Echo of the Long. | `config-c2s-04-keep-alive.hex` |

The Registry Data packets are sent in the order of standin §4.2 (biome, chat_type, the 13 MV registries,
dimension_type, damage_type, world_clock): 18 packets, 52 entries. Registries left empty (OE, standin §4.9)
get no packet.

### 3.2 Play: world, movement, players (US2 to US4, US6)

Values that hold for every play row:

- **Dimensions.** `cobolcraft:main` (dimension type id 0 `cobolcraft:surface`, sea level 48, standin §5.1)
  and, when `extra-dimensions` is on, `cobolcraft:subroutine` (dimension type id 1 `cobolcraft:sunless`, sea
  level 32, standin §15.1).
- **CommonPlayerSpawnInfo** (05a, 05b): dimension type id and dimension key of the player's current
  dimension; hashed seed 0; game mode 0 survival or 1 creative; previous game mode 0 (absent); is debug false;
  is flat false; last death location absent; portal cooldown 0; sea level of the dimension.
- **Inventory slots.** Container id 0 is the player's inventory. CobolCraft numbers its slots as the data
  model's Inventory: 0–8 hotbar, 9–35 main, 36 slots in all (Open question 5). This numbering is used by
  Container Set Content, Container Set Slot, Set Player Inventory, Container Click and Set Creative Mode Slot.
  Item stacks never carry data components (standin §2).
- **Entity ids** are per-run network ids (07 §9.2). The joining player's own entity id is the Login `Entity
  id`.

| Dir | Id | Packet | CobolCraft values and use | Fixture |
|---|---|---|---|---|
| S→C | 0x32 (50) | Login | Hardcore false; dimension names = every enabled dimension (standin §5.1: [`cobolcraft:main`] or [`cobolcraft:main`, `cobolcraft:subroutine`]); max players 20; view distance and simulation distance = the configured view distance (default 8); reduced debug info false; show death screen true; limited crafting false; spawn info for the player's current dimension; online mode false; enforces secure chat false. Fixture: `extra-dimensions` off, so names [`cobolcraft:main`], spawn info of `cobolcraft:main`, view and simulation distance 8. | `play-s2c-32-login-main.hex` |
| S→C | 0x32 (50) | Login (all dimensions) | The same with names [`cobolcraft:main`, `cobolcraft:subroutine`] (US12). | `play-s2c-32-login-all-dimensions.hex` |
| S→C | 0x27 (39) | Game Event 13 `LEVEL_CHUNKS_LOAD_START` | Value 0.0; sent after Login or Respawn, before the first chunk batch. | `play-s2c-27-game-event-13-wait-chunks.hex` |
| S→C | 0x60 (96) | Set Chunk Cache Center | The chunk of the player's feet; re-sent when the player enters another chunk (US3-4). | `play-s2c-60-set-chunk-cache-center.hex` |
| S→C | 0x0C (12) | Chunk Batch Start | No fields. | `play-s2c-0c-chunk-batch-start.hex` |
| S→C | 0x0B (11) | Chunk Batch Finished | Number of Level Chunk With Light packets in the batch. | `play-s2c-0b-chunk-batch-finished.hex` |
| S→C | 0x2E (46) | Level Chunk With Light | Chunks within view distance of the player's chunk (US3-4); payload per 06 with the standin §5.2 / §15.2 generator and light policy. Fixture: chunk (0, 0) of `cobolcraft:main` (terrain, marker pillar, biomes, heightmaps and light). | `play-s2c-2e-level-chunk-with-light-spawn.hex` |
| S→C | 0x26 (38) | Forget Level Chunk | A chunk that left view distance. | `play-s2c-26-forget-level-chunk.hex` |
| S→C | 0x31 (49) | Light Update | Recomputed light after a light-emitting block is placed, broken or toggled (standin §5.2). Fixture: the spawn chunk after its marker glowtube is toggled off. | `play-s2c-31-light-update.hex` |
| S→C | 0x49 (73) | Player Position | Teleport id (per connection, counting up from 1), position, velocity (0, 0, 0), yaw, pitch, relative flags 0 (all absolute). Sent on join, on travel and on the relocate command. Fixture: spawn feet (4.5, 54.0, 8.5), yaw −90.0, pitch 0.0 (standin §5.2). | `play-s2c-49-player-position.hex` |
| S→C | 0x41 (65) | Player Abilities (creative) | Flags 0x0D (invulnerable, can fly, instant build; plus 0x02 while flying), flying speed 0.05, walking speed 0.1. The client's real speeds are standin §11.4; it does not use the speed fields. | `play-s2c-41-player-abilities-creative.hex` |
| S→C | 0x41 (65) | Player Abilities (survival) | Flags 0x00, flying speed 0.05, walking speed 0.1. | `play-s2c-41-player-abilities-survival.hex` |
| S→C | 0x63 (99) | Set Default Spawn Position | RespawnData: dimension `cobolcraft:main`, the block position of the world spawn (floor of each coordinate), its yaw, pitch 0.0. Fixture: (4, 54, 8), yaw −90.0. Re-sent to players in main after the `homestead` command. | `play-s2c-63-set-default-spawn-position.hex` |
| S→C | 0x73 (115) | Set Time | Game time = `Time` (standin §4.8; CobolCraft keeps no separate game-time counter, 07 §9.4); one clock update: world_clock id 0 (`cobolcraft:daylight`), total ticks = `Time`, partial tick 0.0, rate 1.0. Sent on join, every 20 ticks, and after the `clock` command. | `play-s2c-73-set-time.hex` |
| S→C | 0x27 (39) | Game Event 3 `CHANGE_GAME_MODE` | Value 0.0 survival, 1.0 creative; sent on a game mode change (`mode` command, FR-007). Fixture: survival. | `play-s2c-27-game-event-03-game-mode.hex` |
| S→C | 0x6B (107) | Set Held Slot | Held hotbar slot 0–8. | `play-s2c-6b-set-held-slot.hex` |
| S→C | 0x6E (110) | Set Player Inventory | One slot (0–35) and its stack. | `play-s2c-6e-set-player-inventory.hex` |
| S→C | 0x12 (18) | Container Set Content (empty) | Container 0, a state id, 36 slots all empty, carried item empty. | `play-s2c-12-container-set-content-empty.hex` |
| S→C | 0x12 (18) | Container Set Content (starting items) | The same with the standin §2 starting inventory: slots 0–7 items 2–9 × 64, slot 8 one `pry_bar` (10), slot 9 one `trowel` (11), others empty. | `play-s2c-12-container-set-content-starting-items.hex` |
| S→C | 0x14 (20) | Container Set Slot | Container 0, a state id, slot 0–35, stack. | `play-s2c-14-container-set-slot.hex` |
| S→C | 0x08 (8) | Block Update | Position and global block state id (standin §1.2, 0–17). | `play-s2c-08-block-update.hex` |
| S→C | 0x56 (86) | Section Blocks Update | Several changes in one section. | `play-s2c-56-section-blocks-update.hex` |
| S→C | 0x04 (4) | Block Changed Ack | The sequence of the Player Action or Use Item On it answers. | `play-s2c-04-block-changed-ack.hex` |
| S→C | 0x05 (5) | Block Destruction | Break progress of a block another player is breaking. | `play-s2c-05-block-destruction.hex` |
| S→C | 0x47 (71) | Player Info Update | Actions byte 0x01 (ADD_PLAYER only): profile UUID (offline UUID), name, 0 properties. Sent for every connected player on join and to everyone when a player joins. | `play-s2c-47-player-info-update.hex` |
| S→C | 0x46 (70) | Player Info Remove | The leaving player's UUID. | `play-s2c-46-player-info-remove.hex` |
| S→C | 0x01 (1) | Add Entity (`cobolcraft:operator`) | Another player within view distance in the same dimension (US3-5). Entity type 0; entity UUID = the player's offline UUID; position; movement (0, 0, 0); pitch, yaw, head yaw as Angles (00 §4.4); data 0. | `play-s2c-01-add-entity-operator.hex` |
| S→C | 0x36 (54) | Move Entity Pos | Linear form (step count 0) for a position change below 8 blocks per axis; on-ground bit. Used for other players and mobs. | `play-s2c-36-move-entity-pos.hex` |
| S→C | 0x37 (55) | Move Entity Pos Rot | As 0x36 when the yaw or pitch changed too. | `play-s2c-37-move-entity-pos-rot.hex` |
| S→C | 0x39 (57) | Move Entity Rot | Only the yaw or pitch changed. | `play-s2c-39-move-entity-rot.hex` |
| S→C | 0x55 (85) | Rotate Head | Head yaw = the entity's yaw, sent with each rotation change. | `play-s2c-55-rotate-head.hex` |
| S→C | 0x80 (128) | Teleport Entity | PositionMoveRotation (position, current motion, yaw, pitch), relative flags 0, on-ground. Used for moves of 8 blocks or more per axis, for ground-item moves (standin §9.2) and after relocation. | `play-s2c-80-teleport-entity.hex` |
| S→C | 0x4E (78) | Remove Entities | Entities leaving view, the dimension or the world. | `play-s2c-4e-remove-entities.hex` |
| S→C | 0x7C (124) | System Chat (player chat) | Literal `<name> message` (§1), overlay false. | `play-s2c-7c-system-chat-chat.hex` |
| S→C | 0x7C (124) | System Chat (command feedback) | `translate` with a standin §16 key and its arguments, overlay false. Fixture: `cobolcraft.command.promote.done` [`Alice`]. Notices, private messages and announcements (`promote.notice`, `murmur.incoming`, `announce.message`, …) use this layout. | `play-s2c-7c-system-chat-command-feedback.hex` |
| S→C | 0x7C (124) | System Chat (death message) | `translate` with a standin §10.7 key, overlay false, to every connected player. Fixture: `cobolcraft.death.fall` [`Alice`]. | `play-s2c-7c-system-chat-death.hex` |
| S→C | 0x20 (32) | Disconnect (server stopping) | `translate` `cobolcraft.disconnect.shutdown` (US15-2). | `play-s2c-20-disconnect-stopping.hex` |
| S→C | 0x20 (32) | Disconnect (host closed the world) | `translate` `cobolcraft.disconnect.host_closed` (US17-4). | `play-s2c-20-disconnect-host-closed.hex` |
| S→C | 0x20 (32) | Disconnect (logged in from another location) | `translate` `cobolcraft.disconnect.replaced` (US2 edge case). | `play-s2c-20-disconnect-duplicate-login.hex` |
| S→C | 0x20 (32) | Disconnect (ejected) | `translate` `cobolcraft.disconnect.ejected` [reason] (`eject` with a reason, standin §16 row 6). Fixture reason: `griefing`. `eject` without a reason sends `cobolcraft.disconnect.ejected_plain` with no arguments in this layout. | `play-s2c-20-disconnect-kicked.hex` |
| S→C | 0x20 (32) | Disconnect (barred) | `translate` `cobolcraft.disconnect.barred`, sent when an online player is barred. | `play-s2c-20-disconnect-banned.hex` |
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
| C→S | 0x29 (41) | Player Action 0 `START_DESTROY_BLOCK` | Break start: block position, face (UByte, 0 down … 5 east), sequence. In creative a break completes on this action alone (standin §2). | `play-c2s-29-player-action-start-destroy.hex` |
| C→S | 0x29 (41) | Player Action 2 `ABORT_DESTROY_BLOCK` | Break cancelled. | `play-c2s-29-player-action-abort-destroy.hex` |
| C→S | 0x29 (41) | Player Action 3 `STOP_DESTROY_BLOCK` | Survival break finished after the standin §1.1 break time (divided by 4 with the matching tool, standin §2). | `play-c2s-29-player-action-stop-destroy.hex` |
| C→S | 0x42 (66) | Use Item On | Hand 0 (main); the hit block, face (VarInt), cursor, inside, world border hit; sequence. Places the held block item (standin §1.3), toggles a `glowtube` with no block item held, or starts travel when the block is a `goto_pad` (§3.3). | `play-c2s-42-use-item-on.hex` |
| C→S | 0x36 (54) | Set Carried Item | Hotbar slot 0–8 (Short). | `play-c2s-36-set-carried-item.hex` |
| C→S | 0x12 (18) | Container Click | Container 0, state id, slot 0–35 (−999 outside), button, click type, changed slots, carried item (HashedStack, no components). | `play-c2s-12-container-click.hex` |
| C→S | 0x39 (57) | Set Creative Mode Slot | Slot 0–35 and stack; acted on only for a creative player. | `play-c2s-39-set-creative-mode-slot.hex` |
| C→S | 0x09 (9) | Chat | Message (≤ 256 characters); timestamp = the client's clock in ms (not used by the server); salt 0; signature absent; last seen messages: offset 0, acknowledged `00 00 00`, checksum 0 (§1). | `play-c2s-09-chat.hex` |

**Join sequence.** On joining play, and after Respawn (§3.3 travel, death respawn), the server sends the
S→C packets of this table that apply to the player's state and dimension: Login (join only) or Respawn,
Commands and Recipe Book Add (join only, §3.3), Player Abilities, Set Held Slot and Container Set Content
(join only), Set Health (§3.3), Set Default Spawn Position, Set Time, the weather events of §3.3, Game Event
13, Set Chunk Cache Center, the chunk batches, Player Position, then Player Info Update and Add Entity (with
Set Entity Data for ground items) for what is in view. The client relies only on these orders: Login or
Respawn first; Game Event 13 before the first chunk batch; chunks only between Chunk Batch Start and
Chunk Batch Finished. This satisfies 05c "Minimum required serverbound traffic" for the client's replies.

### 3.3 Play: added gameplay (FR-015 content)

| Need | Dir | Id | Packet | CobolCraft values and meaning | Fixture |
|---|---|---|---|---|---|
| Ground items (US5) | S→C | 0x01 (1) | Add Entity (`cobolcraft:loose_item`) | Entity type 1; entity UUID: most significant 64 bits 0, least significant 64 bits = the entity id; position; movement = initial motion (standin §9.1); angles 0; data 0. Followed by Set Entity Data. | `play-s2c-01-add-entity-loose-item.hex` |
| | S→C | 0x65 (101) | Set Entity Data (item stack) | Entity id; one entry: index 0, serializer 7 (`ITEM_STACK`), the stack (00 §12.1, no components); then `0xFF`. Sent after Add Entity and whenever the stack changes (partial pickup, standin §9.3). | `play-s2c-65-set-entity-data-item.hex` |
| | S→C | 0x67 (103) | Set Entity Motion | Entity id; motion as LpVec3. | `play-s2c-67-set-entity-motion.hex` |
| | S→C | 0x80 (128) | Teleport Entity | After each tick in which the item's position changed (standin §9.2). | Same layout as row 0x80 of §3.2 |
| | S→C | 0x7F (127) | Take Item Entity | Collected = the item's entity id, collector = the player's, amount = items taken (standin §9.3); then Remove Entities if none remain. | `play-s2c-7f-take-item-entity.hex` |
| | S→C | 0x4E (78) | Remove Entities | Picked up completely, or despawned at age 4800 (standin §9.2). | Same layout as row 0x4E of §3.2 |
| | C→S | 0x29 (41) | Player Action 4 `DROP_ALL_ITEMS` | Throw the whole held stack (US5-3, standin §9.1). Location (0, 0, 0), face 0, sequence 0. | `play-c2s-29-player-action-drop-all-items.hex` |
| | C→S | 0x29 (41) | Player Action 5 `DROP_ITEM` | Throw one item. Location (0, 0, 0), face 0, sequence 0. | `play-c2s-29-player-action-drop-item.hex` |
| Health (US7) | S→C | 0x6A (106) | Set Health | Health 0–30 (Float), food 0–24 (VarInt), saturation 0.0 (standin §10.1, §11.1). Sent to survival players only. | `play-s2c-6a-set-health.hex` |
| | S→C | 0x19 (25) | Damage Event | Damaged entity id; damage type id of standin §10.3 (0, 1, 28, 29, 30 or 31); source cause id and source direct id = attacker entity id + 1, or 0 with no attacker; source position absent. | `play-s2c-19-damage-event.hex` |
| | S→C | 0x2B (43) | Hurt Animation | Damaged entity id; yaw 0.0. | `play-s2c-2b-hurt-animation.hex` |
| | S→C | 0x45 (69) | Player Combat Kill | The dead player's entity id; message = the standin §10.7 death message (`translate`). The death screen shows it as the cause line. Fixture: `cobolcraft.death.mob.abend` [`Alice`]. | `play-s2c-45-player-combat-kill.hex` |
| | S→C | 0x54 (84) | Respawn (after `PERFORM_RESPAWN`) | Spawn info of `cobolcraft:main` with data to keep 0x00 (nothing of the dead player's entity is kept: health and food are reset, standin §10.6), then the join sequence; the player reappears at the world spawn (standin §10.6). | Same layout as `play-s2c-54-respawn-main.hex` (Dimensions row; only the data-to-keep byte differs) |
| | C→S | 0x01 (1) | Attack | Target entity id: a player (`operator`) or a mob (US7-5, US9-4, standin §10.4). | `play-c2s-01-attack.hex` |
| | C→S | 0x0C (12) | Client Command | Action 0 `PERFORM_RESPAWN` (US7-4). Actions 1 and 2 are never sent. | `play-c2s-0c-client-command-respawn.hex` |
| Hunger (US8) | S→C | 0x6A (106) | Set Health (food field) | Food display. | Same as the Set Health row |
| | S→C | 0x22 (34) | Entity Event (eating finished) | Entity id (Int) = the eater; event id 9 (standin §11.6), to the player and its viewers. | `play-s2c-22-entity-event-eating-finished.hex` |
| | C→S | 0x2A (42) | Player Command 1 `START_SPRINTING` | Entity id = the player's own, data 0. The server applies the standin §11.2 sprint exhaustion until action 2 (US8-2). | `play-c2s-2a-player-command-start-sprinting.hex` |
| | C→S | 0x2A (42) | Player Command 2 `STOP_SPRINTING` | As above. | `play-c2s-2a-player-command-stop-sprinting.hex` |
| | C→S | 0x43 (67) | Use Item | Hand 0, sequence, yaw, pitch. Starts eating the held food (standin §11.6, US8-3). | `play-c2s-43-use-item.hex` |
| | C→S | 0x29 (41) | Player Action 6 `RELEASE_USE_ITEM` | Stops eating early; nothing is eaten (US8 edge case). Location (0, 0, 0), face 0, sequence 0. | `play-c2s-29-player-action-release-use-item.hex` |
| Mobs (US9) | S→C | 0x01 (1) | Add Entity (`cobolcraft:sodgrazer`) | Entity type 2; UUID as for ground items; position; movement (0, 0, 0); pitch 0, yaw and head yaw = the mob's yaw; data 0. | `play-s2c-01-add-entity-sodgrazer.hex` |
| | S→C | 0x01 (1) | Add Entity (`cobolcraft:abend`) | Entity type 3; otherwise as the sodgrazer. | `play-s2c-01-add-entity-abend.hex` |
| | S→C | 0x36 (54) / 0x37 (55) / 0x39 (57), 0x55 (85), 0x80 (128), 0x2B (43), 0x4E (78) | Move Entity, Rotate Head, Teleport Entity, Hurt Animation, Remove Entities | Mob movement (standin §12.2), attack feedback, defeat (standin §12.5). | Same layouts as the §3.2 rows and the Hurt Animation row |
| Crafting (US10) | S→C | 0x4B (75) | Recipe Book Add | Replace = true; one entry per standin §13 recipe, display ids 0–8 in order. Entry: Display id; RecipeDisplay type 0 `crafting_shapeless` with one SlotDisplay type 5 `item_stack` (item, count, empty patch) per ingredient line in standin §13 order, result as SlotDisplay type 5 with the result item and count, crafting station SlotDisplay type 0 `empty`; group 0 (none); category 0; **crafting requirements present if and only if the recipe is craftable for this player** (standin §13), holding one HolderSet of the single item per ingredient line (Open question 3); flags 0x00. Sent on join and re-sent whenever the player's inventory changes. Fixture: see the note below the table. | `play-s2c-4b-recipe-book-add.hex` |
| | C→S | 0x27 (39) | Place Recipe | Container id 0, recipe = display id, use max items false. "Craft one": all ingredients removed and the result added atomically, or nothing (US10-2 to US10-4). Fixture: display id 0. | `play-c2s-27-place-recipe.hex` |
| Weather (US11) | S→C | 0x27 (39) | Game Event 1 `START_RAINING` | Value 0.0; sent first when the kind's rain level is above 0. | `play-s2c-27-game-event-01-start-raining.hex` |
| | S→C | 0x27 (39) | Game Event 2 `STOP_RAINING` | Value 0.0; sent first when the rain level is 0 (clear, and always in a dimension without weather). | `play-s2c-27-game-event-02-stop-raining.hex` |
| | S→C | 0x27 (39) | Game Event 7 `RAIN_LEVEL_CHANGE` | Value = the kind's rain level. Fixture: hailstorm, 1.0. | `play-s2c-27-game-event-07-rain-level.hex` |
| | S→C | 0x27 (39) | Game Event 8 `THUNDER_LEVEL_CHANGE` | Value = the kind's thunder level. Fixture: hailstorm, 1.0. | `play-s2c-27-game-event-08-thunder-level.hex` |
| Dimensions (US12) | C→S | 0x42 (66) | Use Item On a `goto_pad` | The trigger is **Use Item On** aimed at a `cobolcraft:goto_pad` block (block id 10, state 16), any hand item or none, either game mode (standin §15.5). Walking into a goto_pad does nothing. | Same layout as row 0x42 of §3.2 |
| | S→C | 0x54 (84) | Respawn (to `cobolcraft:main`) | Spawn info of `cobolcraft:main` (type 0, sea level 48); data to keep 0x03; then the join sequence of §3.2 for that dimension, including its weather. Arrival point per standin §15.5. | `play-s2c-54-respawn-main.hex` |
| | S→C | 0x54 (84) | Respawn (to `cobolcraft:subroutine`) | Spawn info of `cobolcraft:subroutine` (type 1, sea level 32); data to keep 0x03. | `play-s2c-54-respawn-subroutine.hex` |
| Commands (US14) | S→C | 0x10 (16) | Commands (everyone) | The tree below with only `howto`, `roster`, `murmur` (6 nodes). Sent on join and when operator status is revoked (US14-5). | `play-s2c-10-commands-everyone.hex` |
| | S→C | 0x10 (16) | Commands (operator) | The full tree below (90 nodes). Sent on join to operators and when operator status is granted. | `play-s2c-10-commands-operator.hex` |
| | S→C | 0x0F (15) | Command Suggestions | Transaction id of the request; start and length of the word being completed; one entry per suggestion, no tooltip (player names, dimension paths, mob type paths, item key paths: standin §16.3). | `play-s2c-0f-command-suggestions.hex` |
| | C→S | 0x0F (15) | Command Suggestion | Transaction id; the partial command text. | `play-c2s-0f-command-suggestion.hex` |
| | C→S | 0x07 (7) | Chat Command | The command text without the leading `/` (unsigned form). | `play-c2s-07-chat-command.hex` |
| Packs (US18) | S→C | 0x52 (82) | Resource Pack Push (play) | As the configuration rows (08 §9). | `play-s2c-52-resource-pack-push.hex` |
| | C→S | 0x32 (50) | Resource Pack Response (play) | As the configuration row. | `play-c2s-32-resource-pack-response.hex` |

**Weather values** (standin §14.1, §14.4). The server sends, to each player in the dimension on join, on
every change of kind and on arrival by travel or teleport: Game Event 1 (if the rain level is above 0) or 2
(otherwise), then 7 with the rain level, then 8 with the thunder level.

| Kind | (rain level, thunder level) | Events sent |
|---|---|---|
| `cobolcraft:clear` | (0.0, 0.0) | 2 (0.0), 7 (0.0), 8 (0.0) |
| `cobolcraft:drizzle` | (1.0, 0.0) | 1 (0.0), 7 (1.0), 8 (0.0) |
| `cobolcraft:hailstorm` | (1.0, 1.0) | 1 (0.0), 7 (1.0), 8 (1.0) |

The client maps a pair back to the kind: rain level below 0.5 → clear; otherwise thunder level below 0.5 →
drizzle; otherwise hailstorm. `cobolcraft:subroutine` has no weather and always gets the clear sequence. Biome
`has_precipitation` (standin §4.3: 1 for `minecraft:plains` and `cobolcraft:upland`, 0 for
`cobolcraft:ash_flats`) decides where the kind is drawn and has its effect.

**Recipe Book Add fixture.** The fixture is the packet for a player whose inventory holds only 4
`greystone` (one slot): all nine recipes, with crafting requirements present only for display id 0 (4
`greystone` → 2 `ledger_tile`) and absent for 1 to 8. For comparison, a player with the full standin §2
starting inventory has requirements present for display ids 0, 1, 2, 3, 5 and 8, and absent for 4 and 7
(they need `dump_shard`) and 6 (it needs `grazer_flank`).

**Command tree** (standin §16.2, §16.3). The Commands packet holds the nodes in **depth-first pre-order**:
the root is node 0 (and the root index), then each child subtree in the order listed below, which is the
standin §16.2 table order. No node is shared between parents and no redirect is used. Literal nodes have
type 1; argument nodes type 2. Flag 0x04 (executable) is set on the nodes marked *exec* (where a usage string
may end); flag 0x10 (custom suggestions, type `minecraft:ask_server`) on every `player`, `target`, `item`,
`mob`, `what` and `dimension` argument; flag 0x20 is never set.

| Argument node name | Parser (05a) | Properties (bytes per 05a) |
|---|---|---|
| `player`, `target` | 7 `game_profile` | none |
| `item`, `mob`, `what`, `dimension` | 5 `brigadier:string` | kind 0 (single word) |
| `message`, `reason` | 5 `brigadier:string` | kind 2 (greedy phrase) |
| `x`, `z`, `x1`, `z1`, `x2`, `z2` | 2 `brigadier:double` | flags 0x03, min −30000000.0, max 30000000.0 |
| `y`, `y1`, `y2` | 2 `brigadier:double` | flags 0x03, min 0.0, max 256.0 |
| `count` | 3 `brigadier:integer` | flags 0x03, min 1, max 2304 |
| `amount` under `vitality` | 3 `brigadier:integer` | flags 0x03, min 0, max 30 |
| `amount` under `ration` | 3 `brigadier:integer` | flags 0x03, min 0, max 24 |
| `ticks` | 3 `brigadier:integer` | flags 0x03, min 0, max 29999 |
| `seconds` | 3 `brigadier:integer` | flags 0x03, min 1, max 86400 |

Tree (literal names plain, argument names in angle brackets):

```text
(root)
  howto *exec*
  roster *exec*
  murmur
    <player>
      <message> *exec*
  promote
    <player> *exec*
  demote
    <player> *exec*
  eject
    <player> *exec*
      <reason> *exec*
  bar
    <player> *exec*
  unbar
    <player> *exec*
  barlist *exec*
  guestlist
    on *exec*
    off *exec*
    add
      <player> *exec*
    remove
      <player> *exec*
    show *exec*
  mode
    <player>
      survival *exec*
      creative *exec*
  relocate
    <player>
      at
        <x>
          <y>
            <z> *exec*
              <dimension> *exec*
      to
        <target> *exec*
  supply
    <player>
      <item> *exec*
        <count> *exec*
  empty
    <player> *exec*
  vitality
    <player>
      <amount> *exec*
      full *exec*
      zero *exec*
  ration
    <player>
      <amount> *exec*
      full *exec*
      zero *exec*
  conjure
    <mob>
      <x>
        <y>
          <z> *exec*
            <dimension> *exec*
  sweep
    <what>
      everywhere *exec*
      area
        <dimension>
          <x1>
            <y1>
              <z1>
                <x2>
                  <y2>
                    <z2> *exec*
  clock
    <ticks> *exec*
  skies
    <dimension>
      clear *exec*
        <seconds> *exec*
      drizzle *exec*
        <seconds> *exec*
      hailstorm *exec*
        <seconds> *exec*
  homestead
    <x>
      <y>
        <z> *exec*
  announce
    <message> *exec*
  persist *exec*
  shutdown *exec*
```

The operator tree has 90 nodes (root included). The everyone tree is the root with `howto`, `roster` and
`murmur` and their subtrees: 6 nodes, in the same order.

### 3.4 Encoding conventions (byte-exact fixtures)

Where 00 to 08 and standin-content leave a byte-level choice open, CobolCraft's encoders make this one, and the
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
4. **Block light spread** (standin §5.2): the level at a cell is L minus the length of the shortest path of
   face-adjacent steps from the source through non-opaque cells (void, lucite), never below 0; the source cell
   itself has L; opaque cells other than sources have 0; the highest level from any source wins.
5. **Command Suggestion** (C→S 0x0F): the text is the chat line as typed, including its leading `/`.
   Command Suggestions (S→C 0x0F) Start is counted in characters of that text, the `/` included (`/murmur Al`
   completes `Al` at start 8, length 2).
6. **Set Entity Motion** (0x67) for a ground item is sent once, right after its Add Entity and Set Entity Data,
   when its initial motion (standin §9.1, §10.6) is not (0, 0, 0): thrown items and death drops. It carries
   that motion. It is not sent otherwise: later motion travels in Teleport Entity (standin §9.2).
7. **Teleport Entity** (0x80): the motion is the entity's current motion; for a player (moves of 8 blocks or
   more, relocation) it is (0, 0, 0), since the server keeps no player motion.
8. **Play Resource Pack Push** (0x52): the fixture uses the optional form (Required false, Prompt absent),
   like `config-s2c-09-resource-pack-push-optional.hex`; the required form has the layout of
   `config-s2c-09-resource-pack-push-required-prompt.hex`.
9. **Registry Data entry NBT** (§3.1): each Compound holds its fields in the order of the standin §4 table that
   gives them (§4.3 column order, `effects` as `water_color`, `grass_color`, `foliage_color`; §4.4, §4.5 cell
   order; §4.6 row order; §4.7 column order), with NBT types per 04 §6. A field standin gives as absent or
   "absent (default)" is not written; a value standin states is written even when it equals the codec default
   (for example `model` `"normal"`, `has_ceiling` 0). Colour strings are written exactly as standin writes them
   (`"#3A6EA5"`, upper-case hex). Booleans are Byte 0 or 1. An empty List (`infiniburn`) has element type 0
   (07 §1.1). A sound is the inline Compound `{sound_id}`; the painting `title` is a bare String tag.
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
and Response, Custom Query, cookies, Transfer, Code of Conduct, Server Links, dialogs, Bundle Delimiter,
Player Chat, Chat Session Update, signed chat commands or Start Configuration.

## Open questions

1. ~~**Update Enabled Features.**~~ Resolved: standin §4.1 and §8 question 11 now state the single flag
   `minecraft:vanilla`, as contracts/wire-profile.md §3.1, tasks T098 and §3.1 here do.
2. ~~**Protocol-defined disconnect keys and the message rule.**~~ Resolved. The server sends the seven
   protocol-named keys of §1 as 01, 02 and 05c define them (FR-001; tasks T095 asks for "the reason 02
   defines"), and 08 §10.8.4 gives each one an `en_us` text as an **[engine name]** key. The
   declined-required-pack case is settled by 08 §9.8: CobolCraft's client does not disconnect itself, and
   the server sends `cobolcraft.disconnect.pack_required` (standin §17).
3. **Craftable flag.** The contract asks for a per-player "craftable flag" in Recipe Book Add, but 05b's
   RecipeBookAddEntry has no such field (its Flags byte holds only notification and highlight). This
   document carries craftability in the presence of the `Crafting requirements` field (present = craftable),
   which `contract/copy/PROTO.cpy` (`PB-RD-REQ-PRESENT`) already models. The recipe book category
   (RegistryId of the static `recipe_book_category` registry, which is never synchronized) is fixed at 0.
4. **Login Finished session id.** 02 shows a `Session id` UUID after the profile; the contract does not
   mention it. CobolCraft sends the all-zero UUID and the client ignores it.
5. **Inventory slot numbering.** Container 0 uses the data model's 36-slot numbering (0–8 hotbar, 9–35 main),
   not the vanilla inventory menu layout (crafting, armour, main, hotbar, off-hand: 46 slots). This only
   matters for a vanilla client in play, which tier B does not cover (standin §0).
6. **Choices this document fixes that the contract left open**, so that encoders agree byte for byte: the
   Commands node order (pre-order, §3.3), Player Info Update actions (ADD_PLAYER only), UUIDs of mobs and
   ground items (entity id in the low 64 bits), Respawn after death with data to keep 0x00 (the contract
   gives 0x03 only for travel; 0x00 matches 05b's meaning, since nothing of the dead player's entity data or
   attributes carries over to the respawned player), Hurt Animation yaw 0.0, Login max players 20, Player Abilities speeds 0.05 and
   0.1, Chunk Batch Received 9.0, Set Time every 20 ticks, Chat salt 0, and the text encoding of §1.
7. **Entity Event 9.** Standin §11.6 cites contracts/wire-profile.md §3.3 for event id 9, but the contract
   names the event only as "eating-finished". The number 9 is CobolCraft's (05a 0x22 does not enumerate
   event ids).
8. **Brigadier string kinds** (05a Open question 1): kinds 0 and 2 are inferred ordinals; client and server
   are both CobolCraft's, so they agree either way (standin §8 question 13).
