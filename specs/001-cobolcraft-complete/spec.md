# Feature Specification: CobolCraft, complete (game client and game server)

**Feature Branch**: `001-cobolcraft-complete`

**Created**: 2026-11-04

**Status**: Draft

**Input**: User description (typed request, orchestrator prompt of 2026-11-04): "CobolCraft, complete: the full original voxel game client and the game server, both implemented per the project constitution. The network layer and file formats are the protocol-777 interoperability specification in docs/protocol/ (the source of truth); the game content is the original stand-in content in docs/design/standin-content.md; resource packs follow docs/protocol/08-resource-packs.md. The client renders with Vulkan only." With seven user stories for the personas Player, Server operator, Pack creator and Contributor (`.specify/memory/personas.md`). The stories have been regrouped and resequenced below under constitution Principles 2.3 and 2.5; their intent is kept in full.

## User Scenarios & Testing *(mandatory)*

Stories are sequenced by dependency (Principle 2.5): building and testing comes first, then joining, then
moving, then changing the world, then chat, then the operator's persistence story (which needs world changes
to persist), then resource packs (which need a rendered world and a server to push from).

### User Story 1 - As a Contributor, I want to build the client and the server and run their tests locally (Priority: P1)

A Contributor clones the repository, follows its documentation, builds both programs and runs the full test
suite from a terminal.

**Why this priority**: Every other story is verified by building and testing; nothing can be demonstrated
until this works.

**Independent Test**: On a fresh checkout on a supported platform, follow only the repository's documentation;
both programs build and the test run reports its result.

**Acceptance Scenarios**:

1. **Given** a fresh checkout on a supported platform (FR-011) with the documented prerequisites installed, **When** the Contributor runs the documented build command, **Then** a runnable client and a runnable server are produced.
2. **Given** a built checkout, **When** the Contributor runs the documented test command, **Then** the tests of both the client and the server run and the output states how many passed and failed.
3. **Given** a test that fails, **When** the test command finishes, **Then** the output names the failing test and what it expected versus what it observed, and the command exits unsuccessfully.

---

### User Story 2 - As a Player, I want to start the game, connect to a CobolCraft server and enter the world (Priority: P1)

The Player launches the client, picks a server from the server list (or enters its address), connects, and
appears in the world at the spawn point.

**Why this priority**: Joining is the gateway to every other Player outcome.

**Independent Test**: Start a server with its default configuration, launch the client, add the server's
address and join; the Player stands in the generated world looking at the marker pillar.

**Acceptance Scenarios**:

1. **Given** the client is started, **When** the Player opens the server list, **Then** they can add, edit and remove server entries (name and address), and the entries are still there the next time the client starts.
2. **Given** a running CobolCraft server in the server list, **When** the Player views the list, **Then** the entry shows the server's description text and how many players are online.
3. **Given** a running server and a first-time Player, **When** the Player joins, **Then** they appear at the spawn point defined in standin-content §5.2, facing east, standing on turf, with the marker pillar (two unpunched cardstacks, one punched cardstack, lucite, and a lit glowtube) four blocks ahead.
4. **Given** the Player is in the world, **When** they look around, **Then** every block they see is drawn with the appearance the active resource packs give it (FR-003), with per-face shading, the transparent lucite showing what is behind it, and the lit glowtube visibly lighting nearby blocks.
5. **Given** the Player is in the world, **When** they press the disconnect control, **Then** they return to the server list.

---

### User Story 3 - As a Player, I want to walk around and look at the world, which streams in as I move (Priority: P1)

The Player moves with keyboard and mouse; terrain keeps appearing ahead and other players are visible.

**Why this priority**: Moving through and seeing the world is the core of the game.

**Independent Test**: Join, walk several hundred blocks in a straight line, then turn around; terrain is
present all the way out to the view distance in every direction and the ground under the Player is solid.

**Acceptance Scenarios**:

1. **Given** the Player is in the world, **When** they use the movement keys and the mouse, **Then** they walk forward, backward and sideways, turn and look up and down, and jump.
2. **Given** the Player is walking, **When** they meet a solid block, **Then** they cannot pass through it, and when there is no block beneath them they fall until they land on one.
3. **Given** the Player is in creative mode, **When** they use the fly control, **Then** they fly and can stop flying.
4. **Given** the Player walks in any direction, **When** they travel any distance, **Then** the world around them is shown out to the server's view distance in every direction, and areas they leave behind beyond that distance are no longer shown.
5. **Given** another player is connected and within view distance, **When** that player moves, **Then** the Player sees them as the operator figure described in standin-content §3 at their current position, facing the way they face, and sees them disappear when they disconnect or move out of view distance.
6. **Given** the Player stays in the world, **When** time passes, **Then** the sky goes through a day and night cycle whose full length is the day length set in standin-content §4.8.

---

### User Story 4 - As a Player, I want to break and place blocks and see other players' changes (Priority: P1)

The Player picks an item in the hotbar, places blocks, breaks blocks and toggles glowtubes; changes made by
anyone show up for everyone.

**Why this priority**: Changing the world is the game's defining activity.

**Independent Test**: Two Players join the same server; one breaks and places blocks and the other watches
each change appear.

**Acceptance Scenarios**:

1. **Given** the Player is in the world, **When** they look at a block, **Then** the block they are aiming at is highlighted.
2. **Given** the Player holds a block item and aims at a face of a block, **When** they use the place control, **Then** the block appears in the empty position next to that face, in the state set by standin-content §1.3 (for cardstack, its axis follows the clicked face).
3. **Given** the Player is in survival mode, **When** they break a block, **Then** breaking takes the break time of standin-content §1.1 and §2 (a quarter of it with the matching tool), the block becomes empty, and its item is added to their inventory.
4. **Given** the Player is in creative mode, **When** they break a block, **Then** it breaks at once and nothing is added to their inventory.
5. **Given** the Player aims at a glowtube without holding a block item, **When** they use the place control, **Then** the glowtube switches between lit and unlit and the light around it changes to match.
6. **Given** the Player has an inventory, **When** they open the inventory screen or scroll or press a number key, **Then** they see their items and counts and can choose which hotbar slot is held and move items between slots.
7. **Given** two Players are connected, **When** one of them breaks, places or toggles a block within the other's view distance, **Then** the other Player sees the same change.
8. **Given** a first-time Player in survival mode, **When** they join, **Then** their inventory holds the starting items of standin-content §2 (items 2 to 9, 64 each, and the pry bar in the hotbar; the trowel in the first main-inventory slot).

---

### User Story 5 - As a Player, I want to chat with other players on the same server (Priority: P2)

The Player opens chat, types a message and sends it; everyone on the server sees it.

**Why this priority**: Social play depends on it, but the world is playable without it.

**Independent Test**: Two Players on one server exchange messages; each sees both messages with the sender's
name.

**Acceptance Scenarios**:

1. **Given** the Player is in the world, **When** they open chat, type a message and send it, **Then** every connected player, including the sender, sees it as `<name> message` (standin-content §4.4).
2. **Given** chat messages have been received, **When** the Player looks at the chat area, **Then** recent messages are shown in the order they were sent, and the Player can open chat to scroll back through earlier ones.

---

### User Story 6 - As a Server operator, I want to start a server, have players join, and have the world persist across restarts (Priority: P2)

The operator starts the server from a command line, sees players come and go on the console, stops the
server cleanly, and starts it again with everything as it was.

**Why this priority**: Without persistence the world resets every session; it depends on Stories 2 and 4 to
have players and changes to persist.

**Independent Test**: Start a server, have a Player join, build something, move away and leave; stop and
restart the server; the Player rejoins at the same spot with the same inventory and the build is intact.

**Acceptance Scenarios**:

1. **Given** no world folder exists, **When** the operator starts the server, **Then** the server creates a new world folder and its console reports that it is ready and the address and port it accepts players on.
2. **Given** a configuration file exists, **When** the operator starts the server, **Then** the server uses the settings in it (FR-009); **Given** none exists, **Then** the server writes one with the default values and uses them.
3. **Given** the server is running, **When** a player joins or leaves, **Then** the console shows the player's name and that they joined or left.
4. **Given** players have changed the world, **When** the operator types the stop command on the console, **Then** the server saves the world, disconnects the players and exits.
5. **Given** a world folder written by a previous run, **When** the operator starts the server again, **Then** every block change made before the clean stop is present, and each returning player is at the position they left from, with the inventory and game mode they had.
6. **Given** a world folder, **When** the operator copies it to another machine and starts a server there with it, **Then** players find the same world.

---

### User Story 7 - As a Pack creator, I want to make a resource pack that changes how blocks and items look, and have players use it locally or receive it from a server (Priority: P3)

The Pack creator authors textures, models and metadata in their usual tools, drops the pack into the game's
packs folder or has a server offer it, and sees the game drawn with it.

**Why this priority**: It changes appearance only and depends on everything above being drawn and served.

**Independent Test**: Make a pack that replaces the greystone texture and the trowel icon; enable it on the
pack selection screen and see the change; then configure a server to offer the same pack and join.

**Acceptance Scenarios**:

1. **Given** a pack (zip file or folder) in the game's packs folder, **When** the Pack creator opens the pack selection screen, **Then** the pack is listed with its description, its icon if it has one, and whether it is compatible, too old, too new or of unknown version (08 §2.3).
2. **Given** several packs, **When** the Pack creator enables them and orders them on the pack selection screen, **Then** for every block and item a higher pack's file wins over a lower pack's file at the same path, the built-in default pack is always at the bottom, and the choice and order are kept the next time the game starts.
3. **Given** an enabled pack that replaces a block state file, a block or item model, an item definition, a texture or a language entry in the `cobolcraft` namespace, **When** the game is shown, **Then** only the blocks and items that the replaced files affect look different, and everything else looks as before.
4. **Given** a pack whose version information marks it as too old, too new or unknown, **When** the Pack creator enables it, **Then** the game asks for confirmation first, and enables it if they confirm.
5. **Given** a pack with invalid metadata or a file the game cannot read, **When** packs are loaded, **Then** the game shows an error message that names the pack and what is wrong, and a block or item whose appearance cannot be resolved from any pack is drawn with the missing-texture stripes (standin-content §1.4).
6. **Given** a server configured to offer a pack, **When** a Player joins, **Then** the Player is asked whether to accept it (unless they have already told the game to always accept or always decline that server's packs, 08 §9.1), and on accepting, the game is shown with that pack above all local packs until they disconnect.
7. **Given** a server that marks its pack as required, **When** the Player declines it, **Then** the Player is disconnected with a message saying the server requires its pack.
8. **Given** the Player has already downloaded a server's pack, **When** they rejoin and the server offers the same pack unchanged, **Then** the pack is applied without downloading it again.

---

### Edge Cases

Each edge case names the story it qualifies (Principle 2.4).

- **US2** - A player joins with the same name as a player already online: the player already online is disconnected and the new one joins (02, Login sequence).
- **US2** - A client using a different protocol version tries to join: the server list shows it as incompatible and the join ends with the disconnect behaviour the protocol spec defines (02).
- **US3** - The Player tries to go below the bottom layer: the baseplate at Y 0 cannot be broken (US4), so the floor of the world cannot be passed.
- **US4** - The Player tries to break the baseplate: nothing happens and the block stays.
- **US4** - The Player tries to place a block at a position that is not empty, outside Y 0 to 255, or where it would overlap any player: nothing is placed and, in survival, the item is not used up.
- **US4** - In survival, a placed block uses up one item from the held stack; in creative it does not.
- **US4** - A survival Player breaks a block while their inventory has no room for that item: the item is discarded (standin-content §1.3).
- **US4** - Two Players change the same block at about the same moment: both end up seeing the same final block.
- **US4** - Lucite next to lucite shows no face between them; lucite next to an opaque block shows the face on the lucite side only (standin-content §1.1).
- **US6** - The server is started with an existing world folder from an earlier run and a changed configuration file: the world is kept and the new settings apply.
- **US7** - Two server packs are offered: the one offered last is on top (08 §9.6).
- **US7** - A server pack fails to download, fails its integrity check, or cannot be loaded: the game follows 08 §9.1 to §9.2 (the pack is not applied, and the server is told the outcome).
- **US7** - A local pack contains only some files: every file it does not contain comes from the packs below it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001** (US2, US3, US4, US5, US6, US7): The client and the server communicate only as the protocol-777 interoperability specification in `docs/protocol/` (files 00 to 07) defines: framing, compression, encryption, connection phases, keep-alive and timeouts, status, login, configuration, registry synchronization, play packets and chunk encoding. Behaviour that specification defines, including its disconnect behaviours, is required behaviour.
- **FR-002** (US2, US3, US4, US5, US6): All game content, on both client and server, is the stand-in content in `docs/design/standin-content.md`: the block registry and block state numbering (§1), placement rules (§1.3), item registry, stack sizes and tool rules (§2), entity types (§3), synchronized registries (§4), dimension, world generator, light policy and spawn point (§5). Where that document leaves a choice open, this specification decides it as follows:
  - the server sends every registry marked MV, NJ or MV + NJ in §4.2, including the 25 compatibility damage-type keys, the `chat_type` entry and the `world_clock` entry with the dimension's `default_clock`;
  - the server sends one tag update with no registries (§6) and does not send the optional tags; client and server both use the fixed hard and soft block classes of §2;
  - the optional `loose_item` entity (§3) is not used; broken blocks go straight to the inventory (§1.3);
  - procedurally generated textures are identical on every machine (§1.4), and the generated terrain for a given position is the same in every new world (§5.2).
- **FR-003** (US2, US3, US4, US7): All block and item appearance in the client comes from resource packs read in the format, stacking order and server-push behaviour of `docs/protocol/08-resource-packs.md`. The client includes the built-in stand-in default pack of 08 §10, required and fixed at the bottom of the stack; the missing-texture stripes are drawn by the client and are not a pack file.
- **FR-004** (US6): The server stores the world on disk in the NBT and region-file formats of `docs/protocol/07-nbt-and-anvil.md`, in one world folder that can be copied as a unit.
- **FR-005** (all stories): Where `docs/protocol/` or `docs/design/standin-content.md` is missing, ambiguous or wrong for a behaviour this specification requires, the document is corrected first and the behaviour is then built to the corrected document (constitution Principle II).
- **FR-006** (US2, US3, US4, US7): The client draws the game using Vulkan and no other graphics interface; there is no alternative rendering path.
- **FR-007** (US4, US6): The server decides each player's game mode, creative or survival, from its configuration. Creative mode allows flying and instant breaking and does not use up placed items; survival mode applies break times, tool speed-ups and item use-up.
- **FR-008** (US4, US6): The server is the single authority over the world: every block change made by any player is checked against the rules of FR-002 and FR-007 by the server, and every player within view distance is shown the result.
- **FR-009** (US2, US6, US7): The server's configuration file sets at least: the port it listens on, the game mode given to players, the description shown in the server list, the view distance, and an optional resource pack offer (its download address, its integrity hash, a stable identifier, whether it is required, and an optional prompt message). Defaults: port 25565, creative mode, view distance 8 (standin-content §5.1), no pack offer.
- **FR-010** (US2, US6): Player identity and login: [NEEDS CLARIFICATION: How are players identified and authenticated? The protocol spec describes an "online mode" that verifies players against an external session service whose endpoints are not in `docs/protocol/` (02, Open question 1), and an "offline mode" where a player is whoever their typed name says, with no encryption. Options: (A) offline mode only — player chooses a name in the client, no accounts, no encryption; (B) offline identity but with the connection still encrypted; (C) online mode against an account service CobolCraft would have to provide or choose.]
- **FR-011** (US1, US2): Supported platforms: [NEEDS CLARIFICATION: Which operating systems and CPU architectures must the client and the server build, run and pass tests on? For example (A) macOS on Apple silicon only; (B) macOS and Linux (x86-64 and arm64); (C) macOS, Linux and Windows. This sets the Contributor's build environments and the Vulkan availability the client relies on.]
- **FR-012** (US2, US6, US7): Failure handling: conditions whose handling is defined by `docs/protocol/` (for example disconnect reasons, login timeout, pack download outcomes and pack format validation) are handled as defined there. Any other failure is not handled specially and fails loudly and visibly (constitution 5.6). [NEEDS CLARIFICATION: Beyond what the reference documents define, which failures need specified handling? Candidates: what the Player sees when the server cannot be reached or the connection drops; whether the world must survive a server crash or power loss (and how much recent change may be lost), or only a clean stop; what the operator sees when the port is in use or the world folder cannot be read or written. Option (A): none — all of these fail loudly; (B) a named subset, with the behaviour for each.]
- **FR-013** (US5): Chat messages are plain text, delivered by the server to every connected player in the order the server received them. Message length limits are those of `docs/protocol/`.
- **FR-014** (US2, US3, US4, US5, US7): Player-visible text (block and item names, chat format, menus) comes from the language files of the active resource packs; the built-in pack provides English (`en_us`, 08 §10.8 and standin-content §4.4).

### Key Entities *(include if feature involves data)*

- **World**: the persistent place players join (personas term): its terrain, every block in it, and the stored state of each player who has been in it.
- **Block**: a position's content, one of the 16 block states of standin-content §1.2.
- **Item and inventory**: the 11 items of standin-content §2; each player's inventory is a set of slots (hotbar and main) each holding an item and a count up to its stack size.
- **Player**: a connected person, with a name, a position and facing, a game mode and an inventory.
- **Server configuration**: the operator's settings of FR-009.
- **Server list entry**: a name and address the Player saved in the client.
- **Resource pack**: textures, models and metadata in the format of 08 (personas term), either local (with an enabled flag and a position in the order) or offered by a server (with an identifier and an integrity hash).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On every supported platform (FR-011), a Contributor starting from a fresh checkout builds both programs and gets a passing test run using only the commands in the repository's documentation.
- **SC-002**: With two Players on one server, 100% of the block changes either one makes within the other's view distance are seen by the other.
- **SC-003**: After a clean stop and restart, 100% of block changes made before the stop are present, and 100% of returning players are at their last position with their last inventory.
- **SC-004**: All 16 block states and all 11 items are drawn with the stand-in appearance of the built-in pack, matching the recipes of standin-content §1.4 and §2 pixel for pixel in the textures used.
- **SC-005**: A pack that replaces exactly one texture changes the appearance of exactly the blocks or items that use that texture and of nothing else.
- **SC-006**: 100% of chat messages sent while players are connected are seen by every connected player, in the same order for all of them.
- **SC-007**: A Player walking 1,000 blocks in a straight line from spawn in each of the four compass directions finds terrain present out to the view distance at every point along the way.

## Reference Artifacts

Identified under constitution Principle 2.6. All are already version-controlled in this repository. They
are **not** copied into `specs/001-cobolcraft-complete/`: project Principle II makes `docs/protocol/` the single
source of truth and requires gaps to be fixed there, and a second copy under `specs/` would be a second,
divergent source. Project principles take precedence over the amendment where more specific (constitution,
amendment preamble). The files below are binding as stated by the requirement that names each.

| Artifact | Location | Relevance | Used by |
|---|---|---|---|
| Protocol 777 interoperability spec, index | `docs/protocol/README.md` | Lists the documents, protocol version 777, world data version 5023 | FR-001 |
| Data types, transport, handshake/status/login, configuration, registry sync, play packets (clientbound and serverbound), chunk format | `docs/protocol/00-data-types.md` to `docs/protocol/06-chunk-format.md` (including `05a`, `05b`, `05c`) | The entire network layer | FR-001, FR-010, FR-012, FR-013 |
| NBT and region files | `docs/protocol/07-nbt-and-anvil.md` | World storage format | FR-004 |
| Resource packs | `docs/protocol/08-resource-packs.md` | Pack format, stacking, server-pushed packs, built-in default pack | FR-003, FR-012, FR-014 |
| Stand-in content | `docs/design/standin-content.md` | All game content and the world generator | FR-002, FR-014 |

Each reference document ends with an "Open questions" section and marks some facts "(inferred)". Those are
resolved under FR-005 when a required behaviour depends on them.

## Assumptions

- **Content will be replaced later.** The stand-in content is the binding content for this feature. Its §7 list records that it is expected to be replaced by later features; that does not weaken it here.
- **Multiplayer only.** The client always plays against a separate server. A built-in single-player mode is out of scope.
- **Out of scope** because neither the input nor the reference content asks for them: health, damage and fall damage, hunger, mobs, item drops on the ground, crafting, weather, sounds and music, chat commands, and server console commands other than stop.
- **No performance targets.** None were requested, and timing constraints are not inferred (constitution 2.7). Timeouts and limits that `docs/protocol/` defines still apply through FR-001.
- **Player-to-player visibility** in US3 and change visibility in US4 apply within the server's view distance.
- **Survival item use-up** (placing a block uses one item) and **no placing into players** are decisions of this specification, made because standin-content §1.3 is silent on them.

## Plan-Phase Handoff

Non-binding. Each item is a hypothesis for the plan phase to confirm, refute or supersede (Principle 2.6).

- Constitution Principle I: game logic in GnuCOBOL 3.x for both programs; a minimal C shim for Vulkan, sockets, zlib and cryptography only. Windowing and input (keyboard, mouse) are not on that list; the plan must decide how window creation and input fit the shim boundary, possibly with a constitution question.
- On macOS, Vulkan is normally provided through a portability layer (MoltenVK); this bears on FR-006 and FR-011.
- Protocol 777 has signed-chat machinery; with offline identity (FR-010 option A) chat would be sent unsigned. Verify what 05a/05c allow.
- The session service is absent from 02; FR-010 option C would need a source outside `docs/protocol/`.
- Per-player stored data (position, inventory, game mode) is not covered by 07's region-file sections (which cover `region/`, `entities/`, `poi/`); its on-disk format likely needs a design or a spec addition under FR-005.
- standin-content §4.8 and Open question 7 doubt whether `world_clock` is needed; FR-002 keeps it.
- standin-content §5.2's light policy is deliberately crude (no sideways sky light); the renderer still needs a per-face brightness policy (§1.4 "Shading").
- 08 Open question 4 (element rotation order) and 6 (default face UVs) affect the renderer's model baking.
- Resource pack download needs HTTP and HTTPS in the client, and the server's pack offer needs a host serving the zip; neither HTTP nor TLS is on the constitution's shim list.
