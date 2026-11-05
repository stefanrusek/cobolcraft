# Feature Specification: CobolCraft, complete (game client and game server)

**Feature Branch**: `001-cobolcraft-complete`

**Created**: 2026-11-04

**Status**: Draft (revised after operator feedback, 2026-11-04 and 2026-11-05)

**Input**:
- Typed request (orchestrator prompt of 2026-11-04): "CobolCraft, complete: the full original voxel game client and the game server, both implemented per the project constitution. The network layer and file formats are the protocol-777 interoperability specification in docs/protocol/ (the source of truth); the game content is the original stand-in content in docs/design/standin-content.md; resource packs follow docs/protocol/08-resource-packs.md. The client renders with Vulkan only." With seven user stories for the personas Player, Server operator, Pack creator and Contributor (`.specify/memory/personas.md`).
- Operator approval-gate feedback (relayed by the orchestrator, 2026-11-04): "I'd like single-player, health, mobs, crafting, sounds, and every command to be in scope", clarified as CobolCraft's own complete command set (operator and player commands) with original names and behaviour, all content original; followed by "Actually sounds can be out of scope."
- Operator change request (relayed by the orchestrator, 2026-11-05): bring hunger, items lying on the ground, weather, multiple dimensions, and opening a single-player world to other players into scope, all as original `cobolcraft:` content; sounds stay out of scope.

The stories have been regrouped and resequenced below under constitution Principles 2.3 and 2.5; the intent of all inputs is kept in full.

## User Scenarios & Testing *(mandatory)*

Stories are sequenced by dependency (Principle 2.5): building and testing; joining; moving; changing the
world; items on the ground (what breaking produces); chat; health (needs movement for falls); hunger (acts on
health); mobs (need health to attack, drop ground items); crafting (needs gathered ingredients, makes food);
weather (shown in the world); dimensions (each with its own world and weather); the operator's persistence
story (needs all of that state to persist); commands (act on everything above); single-player (contains
everything above); opening a single-player world to others (needs single-player and joining); and resource
packs (restyle everything above).

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

**Why this priority**: Joining is the gateway to every other multiplayer outcome.

**Independent Test**: Start a server with its default configuration, launch the client, add the server's
address and join; the Player stands in the generated world looking at the marker pillar.

**Acceptance Scenarios**:

1. **Given** the client is started, **When** the Player opens the server list, **Then** they can add, edit and remove server entries (name and address), and the entries are still there the next time the client starts.
2. **Given** a running CobolCraft server in the server list, **When** the Player views the list, **Then** the entry shows the server's description text and how many players are online.
3. **Given** a running server and a first-time Player, **When** the Player joins, **Then** they appear at the world spawn point in the main dimension (standin-content §5.2 for a new world), facing east, standing on turf, with the marker pillar (two unpunched cardstacks, one punched cardstack, lucite, and a lit glowtube) four blocks ahead.
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
4. **Given** the Player walks in any direction, **When** they travel any distance, **Then** the world around them is shown out to the view distance in every direction, and areas they leave behind beyond that distance are no longer shown.
5. **Given** another player is connected, in the same dimension and within view distance, **When** that player moves, **Then** the Player sees them as the operator figure described in standin-content §3 at their current position, facing the way they face, and sees them disappear when they disconnect, change dimension or move out of view distance.
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
3. **Given** the Player is in survival mode, **When** they break a block, **Then** breaking takes the break time of standin-content §1.1 and §2 (a quarter of it with the matching tool), the block becomes empty, and the block's item appears on the ground where the block was (US5).
4. **Given** the Player is in creative mode, **When** they break a block, **Then** it breaks at once and no item appears.
5. **Given** the Player aims at a glowtube without holding a block item, **When** they use the place control, **Then** the glowtube switches between lit and unlit and the light around it changes to match.
6. **Given** the Player has an inventory, **When** they open the inventory screen or scroll or press a number key, **Then** they see their items and counts and can choose which hotbar slot is held and move items between slots.
7. **Given** two Players are connected, **When** one of them breaks, places or toggles a block within the other's view distance in the same dimension, **Then** the other Player sees the same change.
8. **Given** a first-time Player in survival mode, **When** they join, **Then** their inventory holds the starting items of standin-content §2.

---

### User Story 5 - As a Player, I want items to lie on the ground where they drop, and to pick them up or throw them (Priority: P1)

Broken blocks, defeated mobs and thrown items leave items on the ground; the Player walks over them to pick
them up; items left alone vanish after a while.

**Why this priority**: It completes the break-and-collect loop of US4; mob yields (US9) build on it.

**Independent Test**: Break a block in survival, see its item on the ground, walk over it and see it enter the
inventory; throw an item, walk away and watch it vanish after the despawn time.

**Acceptance Scenarios**:

1. **Given** an item has dropped on the ground, **When** any player in the same dimension and within view distance looks at it, **Then** they see it as the item's icon (standin-content §3, `loose_item`) at the same position, falling until it rests on a block.
2. **Given** an item on the ground, **When** a survival or creative Player comes within the pickup range set by the stand-in ground-item rules (FR-015), **Then** the item leaves the ground and is added to that Player's inventory.
3. **Given** the Player holds an item, **When** they use the throw control, **Then** one item (or, with the whole-stack modifier, the whole stack) leaves their inventory and lands on the ground in front of them.
4. **Given** an item has lain on the ground for the despawn time set by the stand-in ground-item rules, **When** that time passes, **Then** it disappears for everyone.

---

### User Story 6 - As a Player, I want to chat with other players on the same server (Priority: P2)

The Player opens chat, types a message and sends it; everyone on the server sees it.

**Why this priority**: Social play depends on it, but the world is playable without it. Commands (US14) are
typed in the same place.

**Independent Test**: Two Players on one server exchange messages; each sees both messages with the sender's
name.

**Acceptance Scenarios**:

1. **Given** the Player is in the world, **When** they open chat, type a message and send it, **Then** every connected player, in any dimension and including the sender, sees it as `<name> message` (standin-content §4.4).
2. **Given** chat messages have been received, **When** the Player looks at the chat area, **Then** recent messages are shown in the order they were sent, and the Player can open chat to scroll back through earlier ones.

---

### User Story 7 - As a Player, I want to have health, take damage, die and respawn (Priority: P2)

In survival mode the Player has a health bar; falls, hostile mobs and (where allowed) other players hurt them;
health recovers over time while they are fed; at zero health they die and respawn.

**Why this priority**: Health gives survival play its stakes; hunger (US8) and mobs (US9) build on it.

**Independent Test**: In survival, jump from a high pillar and watch health drop; let another player hit you
on a server with player combat enabled; reach zero health and respawn.

**Acceptance Scenarios**:

1. **Given** the Player is in survival mode, **When** they are in the world, **Then** their current and maximum health are shown on screen.
2. **Given** a survival Player, **When** they fall farther than the safe fall height, are hit by a hostile mob, are hit by another player while player combat is enabled (FR-009), or starve (US8), **Then** they lose the health that the stand-in health rules (FR-015) set for that cause, and they see that they were hurt.
3. **Given** a survival Player with less than full health, **When** time passes without further damage, **Then** their health recovers at the rate and under the hunger condition the stand-in health and hunger rules set, up to the maximum.
4. **Given** a survival Player's health reaches zero, **When** they die, **Then** a death screen shows the cause of death, other players see a death message in chat, and when the Player chooses to respawn they reappear at the world spawn point in the main dimension with full health and full food, with their inventory and any dropped items as the stand-in death rules (FR-015) set.
5. **Given** the Player attacks another player or a mob, **When** they use the attack control aimed at them within reach, **Then** the target takes the damage the stand-in health rules set for the held item.
6. **Given** the Player is in creative mode, **When** anything would damage them, **Then** they take no damage and no health is shown.

---

### User Story 8 - As a Player, I want to get hungry and eat food (Priority: P2)

In survival the Player has a food bar that empties with time and effort; eating food items refills it; an
empty food bar hurts them.

**Why this priority**: Hunger is a survival rule acting on health (US7); food comes from mobs (US9) and
crafting (US10).

**Independent Test**: In survival, run and jump until the food bar drops; eat a food item and see it rise;
let it empty and watch health fall.

**Acceptance Scenarios**:

1. **Given** the Player is in survival mode, **When** they are in the world, **Then** their food level is shown on screen beside their health.
2. **Given** a survival Player, **When** time passes and they walk, run, jump, attack or break blocks, **Then** their food level falls at the rates the stand-in hunger rules (FR-015) set.
3. **Given** a survival Player holding a food item with a food level below full, **When** they use the eat control for the eating time the stand-in hunger rules set, **Then** one food item leaves their inventory and their food level rises by that food's value, up to the maximum.
4. **Given** a survival Player whose food level is full, **When** they try to eat, **Then** nothing is eaten.
5. **Given** a survival Player whose food level is at zero, **When** time passes, **Then** they take starvation damage as the stand-in hunger rules set (US7).
6. **Given** the Player is in creative mode, **When** time passes, **Then** their food level does not change and is not shown.

---

### User Story 9 - As a Player, I want to meet mobs in the world (Priority: P2)

Passive and hostile creatures appear in the world, move around, can be fought, and hostile ones attack
survival players; defeated mobs drop their yield on the ground.

**Why this priority**: Mobs populate the world, give health a purpose and supply food and crafting
ingredients.

**Independent Test**: Walk around a server world in survival; see passive and hostile mobs; get attacked by a
hostile mob; defeat a mob and pick up its yield.

**Acceptance Scenarios**:

1. **Given** a world, **When** the Player explores any dimension, **Then** mobs of the stand-in mob types (FR-015) appear where and when that dimension's stand-in spawning rules allow, with the appearance the active resource packs give them, and move around on their own.
2. **Given** a hostile mob and a survival Player within its notice range, **When** the mob notices the Player, **Then** it moves toward the Player and attacks when in reach, damaging them (US7).
3. **Given** a passive mob, **When** the Player approaches it, **Then** it does not attack.
4. **Given** the Player attacks a mob, **When** its health reaches zero, **Then** the mob disappears and its yield as set by the stand-in mob rules lies on the ground where it was defeated (US5).
5. **Given** two Players near the same mob, **When** the mob moves, attacks or is defeated, **Then** both see the same thing.
6. **Given** the server's hostile-mob setting is off (FR-009), **When** players explore, **Then** no hostile mobs appear and any existing ones are removed.

---

### User Story 10 - As a Player, I want to craft items from what I have collected (Priority: P2)

The Player opens a crafting screen, sees the recipes, and turns ingredients in their inventory into new items.

**Why this priority**: Crafting turns gathered blocks and mob yields into tools, food and building materials.

**Independent Test**: In survival, gather the ingredients of a recipe, open the crafting screen and craft it;
the ingredients leave the inventory and the result arrives.

**Acceptance Scenarios**:

1. **Given** the Player is in the world, **When** they open the crafting screen, **Then** they see every recipe of the stand-in recipe set (FR-015) with its ingredients and result, and the recipes they can make with their current inventory are marked as craftable.
2. **Given** the Player has a recipe's ingredients, **When** they craft it, **Then** the ingredients are removed from their inventory and the result is added.
3. **Given** the Player lacks a recipe's ingredients, **When** they try to craft it, **Then** nothing is crafted and their inventory is unchanged.
4. **Given** the Player crafts a result for which their inventory has no room, **When** they craft, **Then** nothing is crafted and their inventory is unchanged.

---

### User Story 11 - As a Player, I want the weather to change (Priority: P2)

The weather in each dimension changes over time between the stand-in weather kinds, and every player in that
dimension sees the same weather.

**Why this priority**: It is part of the living world but no other gameplay depends on it.

**Independent Test**: Stay in the world through several weather changes (or force one by command, US14); each
kind is shown as the stand-in content describes, and a second Player in the same dimension sees the same.

**Acceptance Scenarios**:

1. **Given** the Player is in a dimension that has weather (FR-015), **When** the weather changes, **Then** the sky and the world around them show the new weather kind as the stand-in weather description sets, in the biomes where that kind applies.
2. **Given** two Players in the same dimension, **When** they look at the weather, **Then** both see the same weather kind at the same time.
3. **Given** a weather kind that the stand-in weather rules give a gameplay effect, **When** it is active, **Then** that effect applies to players and mobs in it.
4. **Given** the server's weather-change setting is off (FR-009), **When** time passes, **Then** the weather stays as it is unless changed by command.

---

### User Story 12 - As a Player, I want to travel between dimensions (Priority: P2)

Besides the main dimension there are further dimensions with their own terrain; the Player travels between them
by the stand-in means of travel.

**Why this priority**: It extends the world; persistence (US13) and commands (US14) must cover it.

**Independent Test**: Use the stand-in means of travel to go to each extra dimension and back; the terrain,
sky and mobs differ as the stand-in content sets, and the inventory travels with the Player.

**Acceptance Scenarios**:

1. **Given** the Player uses the stand-in means of travel (FR-015) to a dimension, **When** the travel completes, **Then** they are in that dimension at the arrival point the stand-in travel rules set, seeing that dimension's terrain, sky, light and weather, with the same inventory, health, food level and game mode.
2. **Given** two Players in different dimensions, **When** either changes the world, **Then** the other does not see that change until they are in that dimension themselves; then they do.
3. **Given** the Player is in an extra dimension, **When** they disconnect and rejoin, **Then** they are in that dimension at the position they left from.
4. **Given** the server's extra-dimension setting is off (FR-009), **When** a Player tries to travel, **Then** they stay where they are, and players found in a disabled dimension when joining are placed at the world spawn point in the main dimension.

---

### User Story 13 - As a Server operator, I want to start a server, have players join, and have the world persist across restarts (Priority: P2)

The operator starts the server from a command line, sees players come and go on the console, stops the
server cleanly, and starts it again with everything as it was.

**Why this priority**: Without persistence the world resets every session; it depends on Stories 2 to 12 for
the state to persist.

**Independent Test**: Start a server, have a Player join, build something, take damage, get hungry, leave items
on the ground, travel to another dimension and leave; stop and restart the server; the Player rejoins in the
same dimension at the same spot with the same inventory, health and food level, and everything else is as it was.

**Acceptance Scenarios**:

1. **Given** no world folder exists, **When** the operator starts the server, **Then** the server creates a new world folder and its console reports that it is ready and the address and port it accepts players on.
2. **Given** a configuration file exists, **When** the operator starts the server, **Then** the server uses the settings in it (FR-009); **Given** none exists, **Then** the server writes one with the default values and uses them.
3. **Given** the server is running, **When** a player joins, leaves, dies or changes dimension, or anyone sends a chat message, **Then** the console shows it with the player's name.
4. **Given** a world folder written by a previous run that ended with a clean stop (US15), **When** the operator starts the server again, **Then**, in every dimension, every block change made before the stop is present, mobs and items on the ground are where they were (with the despawn time they had left), and the weather is what it was; each returning player is in the dimension and at the position they left from with the inventory, health, food level and game mode they had; the time of day, the world spawn point, the operator list, the ban list and the allow-list are as they were.
5. **Given** a world folder, **When** the operator copies it to another machine and starts a server there with it, **Then** players find the same world, including all its dimensions.

---

### User Story 14 - As a Player, I want to use commands from the chat line (Priority: P3)

The Player types commands into chat; ordinary players have the everyday commands, and players the operator has
granted operator status also have the operator commands.

**Why this priority**: Commands act on everything above (players, inventory, health, hunger, mobs, ground
items, time, weather, dimensions), so they come after it.

**Independent Test**: As an ordinary player, run the help, player-list and private-message commands; have the
operator grant operator status; run each operator command and observe its effect; revoke operator status and
see operator commands refused.

**Acceptance Scenarios**:

1. **Given** the Player has the chat line open, **When** they type the command prefix, **Then** the game suggests the commands they are permitted to use, and suggests arguments (such as player names and dimension names) as they type.
2. **Given** a command in the command set (FR-016) that the Player is permitted to use, **When** they run it with valid arguments, **Then** it has the effect FR-016 and the stand-in command definitions (FR-015) give it, and the Player sees a confirmation message.
3. **Given** a command the Player is not permitted to use, **When** they run it, **Then** nothing happens except a message telling them they are not permitted.
4. **Given** text after the command prefix that is not a command, or a command with missing or invalid arguments, **When** the Player runs it, **Then** nothing happens except a message saying what was wrong and how to get help.
5. **Given** the Player has been granted or has lost operator status, **When** that happens, **Then** they are told, and the set of commands they can use changes at once.

---

### User Story 15 - As a Server operator, I want to run commands on the server console (Priority: P3)

The operator administers the running server by typing commands at its console.

**Why this priority**: Console commands administer everything above; stop is what makes US13's restart clean.

**Independent Test**: With players connected, run each command from the console and observe its effect in the
console output and from what players report.

**Acceptance Scenarios**:

1. **Given** the server is running, **When** the operator types any command of the command set (FR-016) at the console, **Then** it runs with operator permission and its result is printed on the console.
2. **Given** players have changed the world, **When** the operator runs the stop command, **Then** the server saves the world, disconnects the players with a message that the server is stopping, and exits.
3. **Given** the operator types something that is not a command, or a command with missing or invalid arguments, **When** they run it, **Then** the console prints what was wrong and how to get help.

---

### User Story 16 - As a Player, I want to play a world on my own without a server (Priority: P3)

From the client's main menu the Player creates, opens and deletes their own worlds and plays them alone,
with the same game as on a server.

**Why this priority**: It contains every game feature above, including commands.

**Independent Test**: Create a single-player world in survival, build, craft, eat, fight a mob, visit another
dimension, use a command, quit to the menu, reopen the world; everything is as left.

**Acceptance Scenarios**:

1. **Given** the client's main menu, **When** the Player opens the single-player world list, **Then** they can create a world (giving it a name and choosing creative or survival), open a world, and delete a world after confirming.
2. **Given** the Player opens a single-player world, **When** they play, **Then** the world, its rules and its content are the same as on a server with default settings (US2 to US12), without the Player starting or connecting to a separate server.
3. **Given** a single-player world, **When** the Player uses chat commands, **Then** every command of the command set that applies without other players is available to them.
4. **Given** the Player opens the pause menu in a single-player world that is not open to others (US17), **When** the menu is open, **Then** the game is paused.
5. **Given** the Player quits a single-player world to the menu, **When** they open it again, **Then** it is as they left it (as US13 scenario 4 describes for a server).
6. **Given** a single-player world folder, **When** an operator starts a server with it, **Then** players find the same world; and a server's world folder can be opened as a single-player world.

---

### User Story 17 - As a Player, I want to open my single-player world to other players (Priority: P3)

While playing a single-player world, the Player opens it so friends can join it from their own game, as they
would join a server.

**Why this priority**: It needs single-player (US16) and joining (US2).

**Independent Test**: Open a single-player world to others, read the address the game shows, have a second
Player add that address to their server list and join; both play together; the host quits and the guest is
disconnected.

**Acceptance Scenarios**:

1. **Given** the Player is in a single-player world, **When** they choose to open it to others from the pause menu, **Then** they choose the game mode for joining players and whether joining players may use operator commands, and the game shows the address others can join at.
2. **Given** a world opened to others, **When** another Player adds that address to their server list and joins, **Then** they enter the host's world and play as on a server (US2 to US14), with the host holding operator status.
3. **Given** a world opened to others, **When** the host opens the pause menu, **Then** the game does not pause.
4. **Given** guests are in the host's world, **When** the host quits the world, **Then** the world is saved and every guest is disconnected with a message that the host closed the world.
5. **Given** a guest has played in the host's world, **When** the host opens the world again and opens it to others, and the guest rejoins, **Then** the guest's stored state (position, dimension, inventory, health, food level) is as they left it.

---

### User Story 18 - As a Pack creator, I want to make a resource pack that changes how blocks, items and mobs look, and have players use it locally or receive it from a server (Priority: P3)

The Pack creator authors textures, models and metadata in their usual tools, drops the pack into the game's
packs folder or has a server offer it, and sees the game drawn with it.

**Why this priority**: It changes appearance only and depends on everything above being drawn and served.

**Independent Test**: Make a pack that replaces the greystone texture, the trowel icon and one mob's texture;
enable it on the pack selection screen and see the change; then configure a server to offer the same pack and
join.

**Acceptance Scenarios**:

1. **Given** a pack (zip file or folder) in the game's packs folder, **When** the Pack creator opens the pack selection screen, **Then** the pack is listed with its description, its icon if it has one, and whether it is compatible, too old, too new or of unknown version (08 §2.3).
2. **Given** several packs, **When** the Pack creator enables them and orders them on the pack selection screen, **Then** a higher pack's file wins over a lower pack's file at the same path, the built-in default pack is always at the bottom, and the choice and order are kept the next time the game starts.
3. **Given** an enabled pack that replaces a block state file, a model, an item definition, a texture or a language entry in the `cobolcraft` namespace, **When** the game is shown, **Then** only the blocks, items, mobs, weather and text that the replaced files affect look different, and everything else looks as before.
4. **Given** a pack whose version information marks it as too old, too new or unknown, **When** the Pack creator enables it, **Then** the game asks for confirmation first, and enables it if they confirm.
5. **Given** a pack with invalid metadata or a file the game cannot read, **When** packs are loaded, **Then** the game shows an error message that names the pack and what is wrong, and anything whose appearance cannot be resolved from any pack is drawn with the missing-texture stripes (standin-content §1.4).
6. **Given** a server configured to offer a pack, **When** a Player joins, **Then** the Player is asked whether to accept it (unless they have already told the game to always accept or always decline that server's packs, 08 §9.1), and on accepting, the game is shown with that pack above all local packs until they disconnect.
7. **Given** a server that marks its pack as required, **When** the Player declines it, **Then** the Player is disconnected with a message saying the server requires its pack.
8. **Given** the Player has already downloaded a server's pack, **When** they rejoin and the server offers the same pack unchanged, **Then** the pack is applied without downloading it again.

---

### Edge Cases

Each edge case names the story it qualifies (Principle 2.4).

- **US2** - A player joins with the same name as a player already online: the player already online is disconnected and the new one joins (02, Login sequence).
- **US2** - A client using a different protocol version tries to join: the server list shows it as incompatible and the join ends with the disconnect behaviour the protocol spec defines (02).
- **US2, US14** - A banned player, or a player not on the allow-list while it is enabled, tries to join: they are disconnected with a message saying why.
- **US3** - The Player tries to go below the bottom layer: the baseplate at Y 0 cannot be broken (US4), so the floor of the world cannot be passed.
- **US4** - The Player tries to break the baseplate: nothing happens and the block stays.
- **US4** - The Player tries to place a block at a position that is not empty, outside the dimension's height range, or where it would overlap any player or mob: nothing is placed and, in survival, the item is not used up.
- **US4** - In survival, a placed block uses up one item from the held stack; in creative it does not.
- **US4** - Two Players change the same block at about the same moment: both end up seeing the same final block.
- **US4** - Lucite next to lucite shows no face between them; lucite next to an opaque block shows the face on the lucite side only (standin-content §1.1).
- **US5** - Two Players reach the same ground item at the same moment: exactly one of them gets it.
- **US5** - A Player's inventory has room for only part of a ground stack: they pick up what fits and the rest stays on the ground.
- **US5** - A Player's inventory is full: ground items they walk over stay on the ground.
- **US5** - A ground item is in a part of the world no player is near: its despawn time does not run until a player is near it again, as the stand-in ground-item rules set (FR-015).
- **US7** - A player switches from survival to creative while hurt or hungry: they stop taking damage and their food level stops changing; switching back restores the displays with the values they had.
- **US7** - Player combat is disabled (FR-009): attacking another player does no damage.
- **US8** - The Player stops using the eat control before the eating time is up: nothing is eaten.
- **US9** - A hostile mob's target switches to creative mode, disconnects, dies or changes dimension: the mob stops pursuing that player.
- **US11** - A Player is in a dimension without weather (FR-015): no weather is shown there, whatever the weather elsewhere.
- **US12** - A Player travels while mobs or ground items are near them: those stay in the dimension they were in.
- **US13** - The server is started with an existing world folder from an earlier run and a changed configuration file: the world is kept and the new settings apply.
- **US14** - A command names a player who is not online, or a dimension that does not exist: the command does nothing and the sender is told what was not found.
- **US14, US15** - An operator revokes their own operator status, or the last player with operator status loses it: it takes effect; the console always keeps operator permission.
- **US16** - The Player tries to create a single-player world with the name of an existing one: the game keeps both worlds apart (the new world is created alongside, distinguishable in the list).
- **US17** - A guest joins with the same name as the host: the guest is refused with a message that the name is in use, and the host stays.
- **US18** - Two server packs are offered: the one offered last is on top (08 §9.6).
- **US18** - A server pack fails to download, fails its integrity check, or cannot be loaded: the game follows 08 §9.1 to §9.2 (the pack is not applied, and the server is told the outcome).
- **US18** - A local pack contains only some files: every file it does not contain comes from the packs below it.

## Clarifications

### Session 2026-11-05

- Q: How are players identified and authenticated when they join a CobolCraft server or a single-player world opened to others (FR-010)? → A: Option A — offline mode only, the same mechanism Minecraft offline mode uses: the player's identity (name) is supplied to the client as a command-line argument; no accounts, no encryption; bans, allow-list, operator status and stored player data are keyed by that offline identity.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001** (US2–US18): The client and the server communicate only as the protocol-777 interoperability specification in `docs/protocol/` (files 00 to 07) defines: framing, compression, encryption, connection phases, keep-alive and timeouts, status, login, configuration, registry synchronization, play packets and chunk encoding. Behaviour that specification defines, including its disconnect behaviours, is required behaviour. Single-player play (US16) needs no network connection but uses the same game rules; a world opened to others (US17) is joined over the same protocol as a server.
- **FR-002** (US2–US18): All game content, on both client and server, is the stand-in content in `docs/design/standin-content.md`, as extended under FR-015: the block registry and block state numbering (§1), placement rules (§1.3), item registry, stack sizes and tool rules (§2), entity types (§3), synchronized registries (§4), dimensions, world generators, light policy and spawn point (§5). Where that document leaves a choice open, this specification decides it as follows:
  - the server sends every registry marked MV, NJ or MV + NJ in §4.2, including the 25 compatibility damage-type keys, the `chat_type` entry and the `world_clock` entry with the dimension's `default_clock`, plus whatever the FR-015 extension adds (such as further `dimension_type` and `worldgen/biome` entries);
  - the server sends one tag update with no registries (§6) and does not send the optional tags; client and server both use the fixed hard and soft block classes of §2;
  - the `loose_item` entity (§3) is used, and **every yield becomes an item on the ground**: a block broken in survival and a defeated mob both leave their yield on the ground for pickup (US5), replacing §1.3's "added straight to the inventory" rule; the FR-015 extension updates §1.3 and §3 to match;
  - procedurally generated textures are identical on every machine (§1.4), and the generated terrain for a given position in a given dimension is the same in every new world (§5.2 and the FR-015 extension).
- **FR-003** (US2–US12, US16–US18): All block, item, mob and weather appearance and all player-visible text in the client come from resource packs read in the format, stacking order and server-push behaviour of `docs/protocol/08-resource-packs.md`. The client includes the built-in stand-in default pack of 08 §10, extended with the assets for everything the FR-015 extension adds, required and fixed at the bottom of the stack; the missing-texture stripes are drawn by the client and are not a pack file. The built-in pack provides English (`en_us`, 08 §10.8 and standin-content §4.4).
- **FR-004** (US13, US16, US17): Server worlds and single-player worlds are stored on disk in the same format, using the NBT and region-file formats of `docs/protocol/07-nbt-and-anvil.md`, each in one world folder, holding all its dimensions, that can be copied as a unit.
- **FR-005** (all stories): Where `docs/protocol/` or `docs/design/standin-content.md` is missing, ambiguous or wrong for a behaviour this specification requires, the document is corrected first and the behaviour is then built to the corrected document (constitution Principle II).
- **FR-006** (US2–US12, US16–US18): The client draws the game using Vulkan and no other graphics interface; there is no alternative rendering path.
- **FR-007** (US4, US5, US7, US8, US9, US13, US16, US17): Each player is in creative or survival mode. Creative mode allows flying and instant breaking, produces no block yields, does not use up placed items, and has no damage and no hunger; survival mode applies break times, tool speed-ups, item use-up, health and hunger. A new player's mode comes from the server configuration (or, in single-player, the world's chosen mode; for guests, the mode chosen when opening the world), and can be changed by command (FR-016).
- **FR-008** (US4, US5, US7–US12, US14): The server (or the single-player game, including when opened to others) is the single authority over the world: every block change, pickup, attack, meal, craft, travel and command is checked against the rules of this specification and the stand-in content, and every player within view distance in the same dimension is shown the result.
- **FR-009** (US2, US7, US9, US11, US12, US13, US14, US18): The server's configuration file sets at least: the port it listens on, the game mode given to new players, the description shown in the server list, the view distance, whether player combat is enabled, whether hostile mobs appear, whether the weather changes on its own, whether players can travel to the extra dimensions, whether the allow-list is enforced, and an optional resource pack offer (its download address, its integrity hash, a stable identifier, whether it is required, and an optional prompt message). Defaults: port 25565, creative mode, view distance 8 (standin-content §5.1), player combat enabled, hostile mobs enabled, weather changes enabled, extra dimensions enabled, allow-list not enforced, no pack offer.
- **FR-010** (US2, US13, US14, US15, US16, US17): Player identity and login use offline mode only, as the protocol spec's offline mode defines it (02, Offline mode): the Player's name is supplied to the client as a command-line argument when the client is started, and the client presents that name at login; the server accepts it without verification against any account or session service, and the connection is not encrypted. A player's identity is that offline identity (the name and the offline UUID 02 derives from it). Bans, the allow-list, operator status and each player's stored state in a world are keyed by that offline identity, on a server, in a single-player world and in a world opened to others (where guests are identified the same way). There are no accounts and no online mode.
- **FR-011** (US1, US2, US16, US17): Supported platforms: [NEEDS CLARIFICATION: Which operating systems and CPU architectures must the client and the server build, run and pass tests on? For example (A) macOS on Apple silicon only; (B) macOS and Linux (x86-64 and arm64); (C) macOS, Linux and Windows. This sets the Contributor's build environments and the Vulkan availability the client relies on.]
- **FR-012** (US2, US13, US15, US16, US17, US18): Failure handling: conditions whose handling is defined by `docs/protocol/` (for example disconnect reasons, login timeout, pack download outcomes and pack format validation) or by this specification's acceptance scenarios and edge cases (for example command errors) are handled as defined there. Any other failure is not handled specially and fails loudly and visibly (constitution 5.6). [NEEDS CLARIFICATION: Beyond those, which failures need specified handling? Candidates: what the Player sees when the server or an opened world cannot be reached or the connection drops; whether a world (server or single-player) must survive a crash or power loss (and how much recent change may be lost), or only a clean stop; what the operator sees when the port is in use or the world folder cannot be read or written. Option (A): none — all of these fail loudly; (B) a named subset, with the behaviour for each.]
- **FR-013** (US6): Chat messages are plain text, delivered by the server to every connected player in every dimension, in the order the server received them. Message length limits are those of `docs/protocol/`.
- **FR-014** (US5, US7, US8, US9, US11, US12, US13): Everything below belongs to the world and is part of what is saved and restored (US13 scenario 4): each player's dimension, position, inventory, health, food level and game mode; and, per dimension, its blocks, its mobs (type, position, health), its ground items (item, count, position, remaining despawn time) and its weather (kind and how long it has left).
- **FR-015** (US5, US7–US12, US14–US18): Before any implementation of ground items, health, hunger, mobs, crafting, weather, extra dimensions or commands, `docs/design/standin-content.md` is extended (FR-005, docs first) with original stand-in content for each of the following, all in the `cobolcraft:` namespace. None of it is copied from Minecraft or any other game's names, values or lists; textures, models and visual effects are described procedurally, like the existing §1.4 recipes:
  - **Ground-item rules**: the `loose_item` entity made non-optional; pickup range; how a thrown item moves; despawn time and when it runs; whether nearby identical ground items merge; and §1.3 updated so survival block yields drop on the ground.
  - **Health and death rules**: player maximum health; damage per cause (falling beyond a safe height, each hostile mob's attack, each held item's attack against players and mobs, starvation, and any weather effect); health recovery rate and the food level it requires; what happens to the inventory on death (kept, or dropped as ground items); the death and respawn messages; and the `damage_type` entries these causes use.
  - **Hunger rules and food items**: maximum food level; how fast it falls with time and with each activity; eating time; the food items (as new items in the item registry with icons), each with its food value; and how each food item is obtained (mob yields, recipes or both).
  - **Mobs**: at least one passive and one hostile mob type, each with an entity type id and key, size, health, movement and behaviour (for hostile: notice range, attack reach, attack damage), spawning rules per dimension (where, when, how many), yield on defeat, and procedurally described appearance.
  - **Recipes**: the recipe set (ingredients and result for each recipe), and any new items the recipes need, added to the item registry with icons; every ingredient obtainable in survival from blocks, mob yields or other recipes.
  - **Weather**: the weather kinds, with original names; in which dimensions and biomes each applies; how often and for how long each occurs; how each is drawn; and any gameplay effect each has. Biome entries (§4.3) are updated to match.
  - **Extra dimensions**: at least one dimension besides `cobolcraft:main`, each with an original level key, its own `dimension_type` entry (height range, light, sky, clock) and biome entries, its terrain generator, its light policy, whether it has weather, and its mob spawning; the means of travel between dimensions (for example a block or structure the player builds or uses) and the arrival-point rule on each side.
  - **Command set**: for every command of FR-016, its original name, argument syntax, who may use it (everyone, operator status, console), its effect, and the confirmation and error text it shows.
- **FR-016** (US14, US15, US16, US17): CobolCraft's command set provides at least the following capabilities. Names and syntax come from the FR-015 extension.
  - *Everyone*: list the commands the sender may use with their usage; list online players; send a private message to one player.
  - *Operator status and console*: grant and revoke operator status; disconnect a player with a reason; ban and unban a player and list bans; turn the allow-list on or off and add, remove and list players on it; set a player's game mode; move a player to a position (in any dimension) or to another player; give a player an item and count; clear a player's inventory; set a player's health and food level, including to full or to zero; spawn a mob of a given type at a position; remove mobs or ground items in an area or of a type; set the time of day; set the weather in a dimension, for a duration or until changed; set the world spawn point; send a message to all players as the server; save the world now; stop the server.
  - In single-player, the Player may use every command that applies without other players (US16); in a world opened to others, the host holds operator status and guests hold it only if the host allowed it (US17).
  - The console always has operator permission. Who holds operator status, the ban list and the allow-list are saved with the server (US13 scenario 4).
- **FR-017** (US16, US17): A single-player world runs entirely within the client, uses the same game rules and content as a server with default settings, and is stored as FR-004 describes. While it is not opened to others, no other player can join it. Once the host opens it (US17), it accepts players over the network until the host quits; it then stays open for the rest of that session.

### Key Entities *(include if feature involves data)*

- **World**: the persistent place players join (personas term): its dimensions, its time of day and spawn point, and the stored state of each player who has been in it.
- **Dimension**: one of the world's separate places (the main dimension and the stand-in extra dimensions), with its own terrain, blocks, mobs, ground items and weather.
- **Block**: a position's content, one of the block states of standin-content §1.2 (as extended).
- **Item and inventory**: the items of standin-content §2 (as extended by FR-015, including food); each player's inventory is a set of slots (hotbar and main) each holding an item and a count up to its stack size.
- **Ground item**: an item and count lying at a position in a dimension, with the time left before it disappears.
- **Player**: a person in a world, identified by their offline identity (FR-010: the name given to the client on its command line), with a dimension, a position and facing, a game mode, health, a food level, an inventory, and whether they hold operator status.
- **Mob**: a creature of a stand-in mob type, with a dimension, a position, facing and health.
- **Recipe**: a set of ingredient items and counts and the item and count it produces.
- **Weather**: the current weather kind of a dimension and how long it has left.
- **Command**: a named action from FR-016, with its arguments and the permission it requires.
- **Server configuration**: the operator's settings of FR-009, plus the saved operator list, ban list and allow-list.
- **Server list entry**: a name and address the Player saved in the client.
- **Single-player world entry**: a name and game mode the Player chose, and the world it opens.
- **Resource pack**: textures, models and metadata in the format of 08 (personas term), either local (with an enabled flag and a position in the order) or offered by a server (with an identifier and an integrity hash).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On every supported platform (FR-011), a Contributor starting from a fresh checkout builds both programs and gets a passing test run using only the commands in the repository's documentation.
- **SC-002**: With two Players on one server in the same dimension, 100% of the block changes, ground-item appearances and pickups, mob movements, attacks and defeats, and weather changes within one Player's view are seen identically by the other.
- **SC-003**: After a clean stop and restart, 100% of block changes, mobs and ground items in every dimension are as they were, and 100% of returning players are in their last dimension and position with their last inventory, health and food level.
- **SC-004**: All block states, items (including food), mob types and weather kinds of the stand-in content are drawn with the appearance of the built-in pack, matching the stand-in recipes pixel for pixel in the textures used.
- **SC-005**: A pack that replaces exactly one texture changes the appearance of exactly the blocks, items, mobs or weather that use that texture and of nothing else.
- **SC-006**: 100% of chat messages sent while players are connected are seen by every connected player, in the same order for all of them.
- **SC-007**: A Player walking 1,000 blocks in a straight line from the arrival point in each of the four compass directions, in every dimension, finds terrain present out to the view distance at every point along the way.
- **SC-008**: Every recipe of the stand-in recipe set, and every food item, can be obtained in a survival world starting from the starting inventory and what the world provides.
- **SC-009**: Every command of the command set produces its defined effect when run by a permitted sender from each surface it is permitted on (chat with operator status, chat without it, console, single-player, an opened world as host and as guest), and is refused for every sender it is not permitted to.
- **SC-010**: A world created in single-player and then served by a server (and the reverse) shows 100% of its dimensions, blocks, players' stored state, mobs and ground items unchanged.
- **SC-011**: No item is ever duplicated or lost by pickup: across any sequence of drops and pickups by any number of players, every item ends up in exactly one inventory, on the ground, or despawned after its full despawn time.
- **SC-012**: A Player who travels to every extra dimension and back arrives each time with an unchanged inventory, health, food level and game mode.
- **SC-013**: A second Player can join a single-player world opened to others using only the address the host's game shows, and both see 100% of each other's block changes.

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
| Resource packs | `docs/protocol/08-resource-packs.md` | Pack format, stacking, server-pushed packs, built-in default pack | FR-003, FR-012 |
| Stand-in content | `docs/design/standin-content.md` | All game content, dimensions and world generators; to be extended under FR-015 | FR-002, FR-003, FR-015, FR-016 |

Each reference document ends with an "Open questions" section and marks some facts "(inferred)". Those are
resolved under FR-005 when a required behaviour depends on them.

## Assumptions

- **Content will be replaced later.** The stand-in content, including the FR-015 extension, is the binding content for this feature. Its §7 list records that it is expected to be replaced by later features; that does not weaken it here.
- **Out of scope**: sounds and music (removed by the operator), and finding an opened single-player world automatically on the local network (guests join by the address the host's game shows, US17).
- **No performance targets.** None were requested, and timing constraints are not inferred (constitution 2.7). Timeouts and limits that `docs/protocol/` defines still apply through FR-001. Durations that are game content (break times, day length, health recovery, hunger rates, eating time, ground-item despawn time, weather durations) are content, not performance targets.
- **Visibility** of other players, block changes, ground items, mobs and weather applies within the view distance and within the same dimension.
- **Decisions of this specification** where the stand-in content is silent or is superseded: every yield becomes a ground item (FR-002); survival item use-up; no placing into players or mobs; respawning in the main dimension; chat reaching every dimension; the default server settings of FR-009; the command capabilities of FR-016; pausing in single-player only while not opened to others; the host holding operator status in an opened world.
- **Players with operator status**, single-player hosts and guests are Players (personas record); no new persona is needed, because they use the same game window, menus and chat surface.

## Plan-Phase Handoff

Non-binding. Each item is a hypothesis for the plan phase to confirm, refute or supersede (Principle 2.6).

- Constitution Principle I: game logic in GnuCOBOL 3.x for both programs; a minimal C shim for Vulkan, sockets, zlib and cryptography only. Windowing and input (keyboard, mouse) are not on that list; the plan must decide how window creation and input fit the shim boundary, possibly with a constitution question.
- On macOS, Vulkan is normally provided through a portability layer (MoltenVK); this bears on FR-006 and FR-011.
- Protocol 777 has signed-chat and signed-command machinery (05c Chat Command and Chat Command Signed); with offline identity (FR-010) chat and commands are sent unsigned. Verify what 05a/05c allow.
- Command suggestions (US14 scenario 1) map onto the Commands tree and Command Suggestions packets (05a ids 15 and 16, 05c id 15); the command tree's node and argument-parser vocabulary must be checked against what our command set needs.
- Health, hunger and respawn map onto Set Health and Respawn (05b ids 106 and 84) and the Client Command packet (05c id 12); crafting may map onto Update Recipes, the recipe-book packets and Place Recipe (05b ids 75–77, 136; 05c id 39), or onto a simpler container interaction; the plan must pick and check against 05a–05c.
- Weather probably maps onto the Game Event packet's rain/thunder events and the biome `has_precipitation` field (04 §4.3); whether original weather kinds fit those protocol slots or need a different signal must be checked, and docs updated under FR-005.
- Extra dimensions need further `dimension_type` entries, the Login packet's dimension names list, and Respawn for dimension changes (05b id 84); the client's handling of a dimension change must be checked against 01 §7 and 05b.
- Ground items are the `loose_item` entity; pickup likely maps onto Take Item Entity and entity metadata carrying the item stack (00 §12, 05a/05b).
- Single-player (US16) is plausibly an in-process server sharing the server's game logic; the protocol notes that in-memory connections use neither encryption nor compression (02, Offline mode). Opening to others (US17) would then start that server's network listener; LAN discovery is not in `docs/protocol/`.
- Mobs need entity spawn, movement and removal packets (05a/05b) and new `entity_type` entries; mob appearance needs entity model and texture handling in the client that 08 does not yet describe for our namespace (likely an FR-005 spec addition).
- Per-player stored data (dimension, position, inventory, game mode, health, food level, operator status), per-dimension weather, and server-level lists (operators, bans, allow-list) are not covered by 07's region-file sections; their on-disk format likely needs a design or a spec addition under FR-005. Mobs and ground items likely go in 07 §8's `entities/` region folder; extra dimensions need a per-dimension folder layout.
- standin-content §4.8 and Open question 7 doubt whether `world_clock` is needed; FR-002 keeps it.
- standin-content §5.2's light policy is deliberately crude (no sideways sky light); the renderer still needs a per-face brightness policy (§1.4 "Shading").
- 08 Open question 4 (element rotation order) and 6 (default face UVs) affect the renderer's model baking.
- Resource pack download needs HTTP and HTTPS in the client, and the server's pack offer needs a host serving the zip; neither HTTP nor TLS is on the constitution's shim list.
- If sounds return to scope later, they would need 08 §8's `sounds.json` and `sounds/**` asset paths and an audio output path in the client (not on the shim list).
