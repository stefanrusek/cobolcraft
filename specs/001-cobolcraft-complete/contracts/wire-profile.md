# Contract: CobolCraft protocol profile (`client` ↔ `core`, over the wire)

**Status**: frozen at plan time (constitution 3.3). **Docs-first**: the Foundational phase transcribes this
document into `docs/protocol/09-cobolcraft-profile.md` (constitution Principle II, FR-005) and writes one
wire fixture per row of §3 into `contract/fixtures/wire/` (format: `proto-api.md` §3). From then on the doc
is the source of truth and this file is its plan-time record.

Protocol 777 itself (`docs/protocol/00` to `08`) is the base contract (FR-001). This profile states which
parts CobolCraft uses, the choices the protocol leaves to a server, and the game meaning CobolCraft gives to
packets for the content added by FR-015. Content values (ids of new items, entity types, weather kinds,
dimensions) are those of the extended `docs/design/standin-content.md`; this profile refers to them by role.

## 1. Identity and security (FR-010)

- Offline mode only (02, Offline mode). The server never sends Encryption Request; Login Finished carries
  the offline UUID and the name from Login Start, with no properties.
- Login Start name: 1 to 16 characters from `A`-`Z`, `a`-`z`, `0`-`9`, `_` (the client refuses to start
  with any other name, research R14).
- Chat is unsigned: the client sends Chat (05c 0x09) with no signature, Chat Command (05c 0x07) for
  commands, never 0x08 or 0x0A. Login sets `Enforces secure chat` = false. The server broadcasts player chat
  as System Chat (05b 0x7C) with the text `<name> message` (standin-content §4.4 chat type keeps its role
  for registry completeness only).

## 2. Transport choices

- Network connections: Set Compression (02 0x03) with threshold **256** immediately before Login Finished.
- Memory connections (single-player): no Set Compression, no encryption (02).
- Keep-alive: the server sends Keep Alive every 15 s in configuration and play and disconnects on timeout
  as 01 §7.5 defines; the client echoes at once.
- Status (02): `version.name` = `"CobolCraft"`, `version.protocol` = 777, `players.max` = 20 (an informational
  number shown with the count; no join limit is specified), `players.online` = current count,
  `description` = the configured description (US2-2). No favicon. A client with a different protocol
  version is answered per 02 (edge case US2).

## 3. Packet inventory and game meaning

"S→C" clientbound, "C→S" serverbound. Every row has a fixture.

### 3.1 Handshake, status, login, configuration

| Dir | Packet | CobolCraft use |
|---|---|---|
| C→S | Intention, Status Request, Ping Request, Hello (Login Start), Login Acknowledged | As 02. |
| S→C | Status Response, Pong Response, Set Compression, Login Finished, Login Disconnect | As 02. Login Disconnect texts: banned, not on the allow-list (US2/US14 edge cases), name in use by the host (US17 edge case). A second login with a name already online disconnects the earlier connection (02, US2 edge case). |
| S→C | Custom Payload `minecraft:brand` = `"cobolcraft"`, Update Enabled Features (`minecraft:vanilla` only, as standin-content §4.1), Select Known Packs (empty list), Registry Data (every MV/NJ registry of standin-content §4.2 plus the FR-015 additions), Update Tags (no registries), Resource Pack Push (when offered), Finish Configuration | Order of 03 "Configuration sequence"; no code of conduct, no server links. |
| C→S | Custom Payload brand `"cobolcraft"`, Client Information, Select Known Packs (empty), Resource Pack Response, Finish Configuration | As 03. Required-pack decline → server disconnects (08 §9.7). |

### 3.2 Play: world, movement, players (US2 to US4, US6)

| Dir | Packet | CobolCraft use |
|---|---|---|
| S→C | Login (0x32) | Dimension names = every enabled dimension; spawn info for the player's current dimension; view and simulation distance = configured view distance; `Show death screen` = true; `Limited crafting` = false. |
| S→C | Game Event 0x27 event 13, Set Chunk Cache Center 0x60, Chunk Batch Start/Finished, Level Chunk With Light 0x2E, Forget Level Chunk 0x26, Light Update 0x31 | Chunk streaming within view distance (US3-4). |
| S→C | Player Position 0x49, Player Abilities 0x41, Set Default Spawn Position 0x63, Set Time 0x73 (`daylight` clock), Game Event 3 (game mode change), Set Held Slot 0x6B, Set Player Inventory 0x6E, Container Set Content 0x12, Container Set Slot 0x14, Block Update 0x08, Section Blocks Update 0x56, Block Changed Ack 0x04, Block Destruction 0x05 | As 05a/05b. |
| S→C | Player Info Update 0x47 / Remove 0x46, Add Entity 0x01 (`cobolcraft:operator`), Move Entity 0x36/0x37/0x39, Rotate Head 0x55, Teleport Entity 0x80, Remove Entities 0x4E | Other players within view distance in the same dimension (US3-5). |
| S→C | System Chat 0x7C, Disconnect 0x20, Keep Alive 0x2D | Chat lines and all command feedback; disconnect reasons. |
| C→S | Accept Teleportation, Chunk Batch Received, Player Loaded, Client Tick End, Keep Alive, Move Player Pos/PosRot/Rot/Status Only, Player Abilities (flying), Player Action 0/2/3 (break), Use Item On 0x42 (place, glowtube toggle), Set Carried Item 0x36, Container Click 0x12 and Set Creative Mode Slot 0x39 (inventory moves), Chat 0x09 | 05c "Minimum required serverbound traffic" plus gameplay. |

### 3.3 Play: added gameplay (FR-015 content)

| Need | Dir | Packet | Meaning |
|---|---|---|---|
| Ground items (US5) | S→C | Add Entity 0x01 type `cobolcraft:loose_item`; Set Entity Data 0x65 (item-stack metadata entry, 00 §12); Set Entity Motion 0x67; Teleport Entity 0x80; Take Item Entity 0x7F; Remove Entities 0x4E | Appear, fall, rest, picked up (Take Item Entity then Remove), despawn (Remove). |
| | C→S | Player Action 5 `DROP_ITEM` / 4 `DROP_ALL_ITEMS` | Throw one / whole stack (US5-3). |
| Health (US7) | S→C | Set Health 0x6A (health, food, saturation = 0); Damage Event 0x19 and Hurt Animation 0x2B (seen as hurt); Player Combat Kill 0x45 (death screen text = cause); Respawn 0x54 (after PERFORM_RESPAWN) | Health display, hurt feedback, death screen, respawn at world spawn in the main dimension. |
| | C→S | Attack 0x01 (on a player or mob entity id); Client Command 0x0C action 0 | Attack (US7-5, US9-4); respawn (US7-4). |
| Hunger (US8) | S→C | Set Health 0x6A food field; Entity Event 0x22 eating-finished event | Food display; meal completed. |
| | C→S | Use Item 0x43 (start eating); Player Action 6 `RELEASE_USE_ITEM` (stop early, nothing eaten) | Eat control (US8-3, US8 edge case). |
| Mobs (US9) | S→C | Add Entity (mob type ids from the extension), Move Entity 0x36/0x37/0x39, Rotate Head, Teleport Entity, Hurt Animation, Remove Entities | Mob appearance, movement, attack feedback, defeat. |
| Crafting (US10) | S→C | Recipe Book Add 0x4B (`Replace` = true) with one entry per recipe: display = ingredients and result; `craftable` flag computed per player and re-sent when the inventory changes | Recipe list and craftable marking (US10-1). |
| | C→S | Place Recipe 0x27 (container id 0, recipe display id, `Use max items` = false) | "Craft one": server crafts atomically (removes ingredients, adds result) or does nothing (US10-2 to 4). |
| Weather (US11) | S→C | Game Event 1 START_RAINING / 2 STOP_RAINING / 7 RAIN_LEVEL_CHANGE / 8 THUNDER_LEVEL_CHANGE | Each weather kind of the extension is assigned a fixed (rain level, thunder level) pair; the server sends the pair on join, on change and on dimension change; the client maps the pair back to the kind. A dimension without weather always sends STOP_RAINING. Biome `has_precipitation` decides where the kind is drawn. |
| Dimensions (US12) | C→S | Use Item On 0x42 on the extension's travel block, or Move Player into it (the extension chooses one of these two triggers) | Start travel. |
| | S→C | Respawn 0x54 (new dimension's spawn info, `Data to keep` = 0x03) followed by the join sequence of §3.2 for that dimension | Travel; arrival point per the extension. |
| Commands (US14) | S→C | Commands 0x10 (tree filtered to what the player may use; re-sent when operator status changes, US14-5); Command Suggestions 0x0F | Suggestions for commands and arguments (player names, dimension names, mob types, item keys). |
| | C→S | Command Suggestion 0x0F; Chat Command 0x07 | As above; command execution. |
| Packs (US18) | S→C | Resource Pack Push (config 0x09 / play 0x52) | Server-offered pack (08 §9). |
| | C→S | Resource Pack Response (config 0x06 / play 0x32) | 08 §9.2 sequences. |

Command-tree argument parsers used: `brigadier:integer` (3), `brigadier:double` (2), `brigadier:string`
(5; single word and greedy phrase), `game_profile` (7) with suggestions type `minecraft:ask_server`
(05a 0x10).

## 4. Packets CobolCraft never sends

Everything not listed above. Neither side implements packets outside this inventory; receiving one is
handled as `docs/protocol/01-transport.md` defines for a packet the receiver cannot decode.
