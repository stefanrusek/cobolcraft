# Command framework: tree, parser, argument types, dispatch and suggestions

| Item | Value |
|---|---|
| Covers | The Brigadier-style command framework of Java Edition 26.3: command tree structure, permissions, tokenisation and parse rules, every argument type the standard commands use (wire parser id, properties, grammar, errors), the entity selector, execution and feedback rules, the `execute` grammar, chat-command signing, and the tab-completion flow. The per-command catalog (what each command does) is written elsewhere (`16-commands-catalog.md`); here only a table of contents of the root commands is given (§1). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3. This is the artifact already recorded in [README.md](README.md). |
| Method | Static reading of the shipped bytecode (`javap`), with no execution. The jar is client-only but contains the integrated server classes (`net.minecraft.commands.*`, `net.minecraft.server.commands.*`, `net.minecraft.server.permissions.*`, `net.minecraft.util.parsing.packrat.*`) and the English language file. |
| Evidence rule | Every statement is either read from the bundled bytecode or language file of the game jar in this round, or read from the Brigadier library artifact described in [15a](15a-brigadier-command-library.md) (`brigadier-1.3.11.jar`, SHA-256 `9d09cf4819de83dfcd38bcb212d5f2227131791cef3abbfca3321d6fb2b9a64d`; 15a is the source for the string reader, tree, parse, execution, stock argument types and suggestion behaviour, and this document points into it), or marked **(recalled, not verified)** (taken from memory, possibly of another version) or **(inferred)** (deduced from names or call shapes). Marked statements are listed in the Open questions. 15a itself is under review; its `(recalled, not verified)` points (Java platform behaviour) carry over. |
| Read first (not repeated) | [05a](05a-play-clientbound-00-71.md) (Commands 0x10 node layout, parser id table, Command Suggestions 0x0F), [05c](05c-play-serverbound.md) (Chat Command 0x07, signed 0x08, Command Suggestion Request 0x0F), [09](09-cobolcraft-profile.md), [13](13-client-gameplay-and-controls.md), `docs/design/standin-content.md` §16. |

Terminology: *source* is the executor of a command (player, console, command block, function, entity).
*Node* is a vertex of the command tree. *Range* is a start offset and length within the input string.
All offsets are counted in UTF-16 code units of the input string (as Java `String` indices); for text with only
BMP characters this equals the character count. (inferred from the use of Java `String` and `StringReader`; the wire carries UTF-8.)

---

## 1. Table of contents of the standard commands

Registration order is the order of the table (read from `Commands.<init>`). The "level" column is the permission
level a source needs (see §2). A root literal can have aliases that are registered as redirects. Three
registration groups exist: *common* (always), *dedicated-server only* and *integrated-server only* (the
`CommandSelection` of the server: ALL = both, DEDICATED, INTEGRATED).

Common commands (level 0 = no requirement; 2 = gamemaster; 3 = admin; 4 = owner):

| Root literal(s) | Level | Notes |
|---|---|---|
| `advancement` | 2 | |
| `attribute` | 2 | |
| `execute` | 2 | framework; grammar in §11 |
| `bossbar` | 2 | |
| `clear` | 2 | |
| `clone` | 2 | |
| `compute` | 2 | |
| `damage` | 2 | |
| `data` | 2 | |
| `datapack` | 2 for the root (`list`, `enable`, `disable`); only the `create` subcommand requires 4 (`DataPackCommand` references `LEVEL_GAMEMASTERS` and `LEVEL_OWNERS` once each) | |
| `debug` | 3 | |
| `defaultgamemode` | 2 | |
| `dialog` | 2 | |
| `difficulty` | 2 | |
| `effect` | 2 | |
| `me` | 0 | |
| `enchant` | 2 | |
| `experience` (second literal `xp`, read) | 2 | |
| `fill`, `fillbiome` | 2 | |
| `forceload` | 2 | |
| `function` | 2 | |
| `gamemode` | 2 (`Permissions.COMMANDS_GAMEMASTER`) | |
| `gamerule` | 2 | |
| `give` | 2 | |
| `help` | 0 | |
| `item` | 2 | |
| `kick` | 3 | |
| `kill` | 2 | |
| `list` | 0 | |
| `locate` | 2 | |
| `loot` | 2 | |
| `msg` (aliases `tell`, `w`) | 0 | |
| `swing` | 2 | |
| `particle` | 2 | |
| `place` | 2 | |
| `playsound` | 2 | |
| `posteffect` | 2 | |
| `random` | 2 | |
| `reload` | 2 | |
| `recipe` | 2 | |
| `fetchprofile` | 2 | |
| `return` | 2 | |
| `ride` | 2 | |
| `rotate` | 2 | |
| `say` | 2 | |
| `schedule` | 2 | |
| `scoreboard` | 2 | |
| `seed` | 0 on an integrated server, 2 on a dedicated server | |
| `version` | 0 on an integrated server, 2 on a dedicated server | |
| `setblock` | 2 | |
| `spawnpoint` | 2 | |
| `setworldspawn` | 2 | |
| `spectate` | 2 | |
| `spreadplayers` | 2 | |
| `stopsound` | 2 | |
| `stopwatch` | 2 | |
| `summon` | 2 | |
| `tag` | 2 | |
| `team` | 2 | |
| `teammsg` (alias `tm`) | 0 | |
| `teleport` (alias `tp`) | 2 | |
| `tellraw` | 2 | |
| `test` | 2 (registered unconditionally by `TestCommand.register`, between `tellraw` and `tick`) | game-test framework command, listed for completeness |
| `tick` | 3 | |
| `time` | 2 | |
| `title` | 2 | |
| `trigger` | 0 | the argument parse checks the objective, §10.6 |
| `waypoint` | 2 | |
| `weather` | 2 | |
| `worldborder` | 2 | |

Registered only when a developer condition holds (read from the flags tested in `Commands.<init>`; never in a normal run): `jfr` (level 4, only if the JVM profiler is active), `chase` (flag `DEBUG_CHASE_COMMAND`), and, when `DEBUG_DEV_COMMANDS` is set or the game runs inside an IDE, `raid`, `debugpath`, `debugmobspawning`, `warden_spawn_tracker`, `spawn_armor_trims`, `serverpack`, and `debugconfig` (this last one additionally requires the dedicated selection). They are out of scope.

Dedicated-server commands (the `DEDICATED` and `ALL` selections): `ban-ip`, `banlist`, `ban`, `deop`, `op`,
`pardon`, `pardon-ip` (level 3 each), `perf` (4), `save-all`, `save-off`, `save-on` (4), `setidletimeout` (3),
`stop` (4), `transfer` (3), `whitelist` (3).

Integrated-server commands (the `INTEGRATED` and `ALL` selections): `publish`, `unpublish` (level 4).

The registration order matters for one thing only: it fixes the child order of the root node (§3.2).

---

## 2. Permissions

### 2.1 The model (read)

26.3 replaced the bare integer permission level with **permission sets**. A permission set answers
`hasPermission(permission)`. There are two kinds of permission:

| Kind | Meaning |
|---|---|
| `command_level` (level L) | held when the set is level-based and its level is at least L |
| `atom` (a named string) | a named capability, held only when the set explicitly contains it |

The five levels (enum `PermissionLevel`, serialised name, numeric id):

| Id | Name | Constant used by commands |
|---|---|---|
| 0 | `all` | `LEVEL_ALL` (always passes) |
| 1 | `moderators` | `LEVEL_MODERATORS` |
| 2 | `gamemasters` | `LEVEL_GAMEMASTERS` |
| 3 | `admins` | `LEVEL_ADMINS` |
| 4 | `owners` | `LEVEL_OWNERS` |

A **level-based permission set** (the only kind a player, console or rcon source holds) holds the `command_level`
permission for every level less than or equal to its own level. In addition, it holds the atom
`commands/entity_selectors` only when its level is at least 2 (gamemasters). No other atom is held by a level-based set.
Union of two level-based sets is the higher-level one. The empty set `NO_PERMISSIONS` holds nothing.

Other atoms defined: `chat/send_messages`, `chat/send_commands`, `chat/receive_player_messages`,
`chat/receive_system_messages` (grouped as `CHAT_PERMISSIONS`). In the paths read here they are not consulted by the
command code (see Open question 3).

A node requirement `LEVEL_x` (a `PermissionCheck.Require` over the `command_level` permission for level x) passes
for a source whose permission set holds it; `LEVEL_ALL` is `always_pass`. The test is evaluated against the
source's permission set at parse time (not only execution time), see §4.5.

### 2.2 Who holds which level (read)

| Item | Rule (read) |
|---|---|
| `PlayerList.isOp(player)` | true if the operator list contains the player's profile, **or** the player is the single-player owner and the world data allows commands (cheats) |
| Permission set of a player (`MinecraftServer.getProfilePermissions`) | if `isOp`: the level stored in the player's operator-list entry if there is one, else the server's `operatorUserPermissions()` (the `op-permission-level` property, default 4); if not an operator: level 0 (`ALL`) |
| Operator-list entry | JSON object with `uuid`, `name`, `level` (integer 0 to 4, converted with `PermissionLevel.byId`, whose out-of-range strategy is CLAMP; absent means level 0), `bypassesPlayerLimit` (boolean) |
| `op-permission-level` property | default **owner (4)** (`DedicatedServerProperties`) |
| `function-permission-level` property | default **gamemaster (2)** |
| `enforce-secure-profile` property | default **true** |
| Server (console) source | `MinecraftServer.createCommandSourceStack`: permission set owner (4), display name `Server`, position the lower corner of the world respawn block position in the respawn dimension, rotation (0, 0) |
| Rcon source | accepts success and failure messages and informs admins only if `shouldRconBroadcast`; its permission level was not traced (Open question 10) |

When a player's level changes (`op`, `deop`, login), the server sends the player an Entity Event
(05a) for the player's own entity with event id **24 + level** (24 = level 0 ... 28 = level 4; the switch over the five
`PermissionLevel` values was read), then immediately resends the Commands packet (§3.3). The client keeps the level it
last heard.

### 2.3 Entity selectors and permission

A selector (`@a`, `@e[...]`, ...) is accepted only when the source's permission set holds the atom
`commands/entity_selectors` (level at least 2). Read: `EntitySelectorParser.allowSelectors` is the parse-time test, and
`EntitySelector.checkPermissions` **re-checks** the same atom when the selector is evaluated (execution time), so a
selector that parsed (for example one carried inside a `message` argument, §6.3) is refused at execution if the source lacks the
permission. A level 0 or 1 source typing `@p` as an entity argument gets `argument.entity.selector.not_allowed`
("Selector not allowed") at the position of the `@`. A plain player name or UUID needs no permission. (Read:
`EntitySelector.checkPermissions` raises `EntityArgument.ERROR_SELECTORS_NOT_ALLOWED` through `create()`, that is `argument.entity.selector.not_allowed`
**without** input context.)

---

## 3. The command tree

### 3.1 Node kinds (fields and flags from the packet classes; library semantics in [15a](15a-brigadier-command-library.md) §2)

| Kind | Fields | Matching |
|---|---|---|
| root | children | the entry point; has no name |
| literal | name, children, redirect, requirement, command | matches the exact text of `name`, **case-sensitively**, only if the word ends at a space or at the end of input (15a §2.4, §2.5) |
| argument | name, argument type, optional custom suggestions provider, children, redirect, requirement, command | parses the argument type at the current position; the parsed value is stored under `name` |

Common properties of a non-root node:

| Property | Meaning |
|---|---|
| Requirement | a predicate over the source; if false the node is skipped by parsing (15a §3.1 step 1), is not sent to the client (§3.3), and is **not** hidden from the library's completion: `getCompletionSuggestions` does not test requirements (15a §6.1; §14.2) |
| Command (`executes`) | present means "this node can end a command" (executable); a chain whose last context has no command fails with unknown command (15a §4.1) |
| Redirect | after the node and one separator, parsing continues at the target node in a new child context (15a §3.1 step 6); the packet carries a redirect index |
| Modifier (fork) | a redirect with a function from a source to a collection of sources; a missing modifier is the identity; the fork flag changes failure handling and the return value (15a §4.3); modifiers are not transmitted on the wire |

Command trees are built in code by `register` functions with the builder operations of 15a §2.2 (`then`, `executes`, `requires`
(replaces an earlier requirement), `redirect`, `fork`, `suggests`; a redirected node cannot have children). A literal alias is a
second literal that redirects to the first. Read: `tell` and `w` redirect to `msg`, `tm` redirects to `teammsg`, and `tp` redirects to `teleport`;
`tell`, `w` and `tm` carry no requirement of their own, while `tp` is registered **with its own requirement (level 2)** as well as the redirect (15a §2.2:
`register` returns the newly built node, not necessarily the node that ends up in the tree when the name already existed).

### 3.2 Child ordering, name space and merging (15a §2.1, §2.3, §2.4)

- Children are held in one map keyed by name, in **insertion order**; the node-number order of §3.4 follows that order (read).
  **Literals and arguments share one name space**: a literal and an argument cannot have the same name under one parent.
- Adding a child whose name already exists keeps the **old** node in place with its own class, type, requirement, redirect, modifier,
  fork flag and suggestion provider; the new node's attributes are discarded; a command on the new node replaces the old node's command
  (a missing command never clears one); the new node's children are merged into the old node recursively in order.
- Relevant children when parsing (15a §2.4): if the node has any literal child, the word up to the next space is looked up exactly
  in the literal view and, if found, **only that literal** is tried; otherwise every argument child is tried in insertion order.
  Only the space character separates words.

### 3.3 Tree sent to a player (read)

`Commands.sendCommands(player)` builds a **filtered copy** of the dispatcher's tree for that player:

1. A new root is created; the original root is mapped to it.
2. Walking depth-first: for each child of the original node, if `child.canUse(source)` is true for the player's
   source, a builder copy of the child is made (same name/type/requirement/command/suggestions, children dropped), its
   redirect is replaced by the **copy** of the redirect target if that target was already copied (via a map; a redirect
   to a node that was not yet copied becomes absent), the copy is added to the new parent, and the walk descends if the
   original child has children.
3. The copy is serialised into one Commands packet (05a 0x10).

Consequences: a node the player may not use is absent; a node whose redirect target was filtered out loses the
redirect (the node stays, now a dead end unless executable). Executable nodes keep the executable flag. The
requirement itself is not transmitted; its effect is the **restricted** flag (§3.5).

The packet is sent: after login, when the permission level changes (§2.2), and after `/reload` (data packs can change
function-based or registry-based nodes). (read: `PlayerList.sendPlayerPermissionLevel`; reload sends to every
player; the reload path was not traced, Open question 2.)

### 3.4 Wire serialisation of the tree (read; complements 05a)

- **Node indices.** Nodes are numbered in **breadth-first order** starting at the root = 0. A queue starts with the
  root; each polled node that has not yet been numbered gets the next index, then its children (in child order) and
  then its redirect target (if any) are appended to the queue. A node reachable twice (via a redirect) is numbered once.
  A decoder accepts any order, as long as indices are in range; CobolCraft's own profile (09 §3.3) uses pre-order
  and is accepted by the client.
- **Flags** byte: bits 0..1 type (0 root, 1 literal, 2 argument); 0x04 executable; 0x08 has redirect; 0x10 has custom
  suggestions (argument only); 0x20 restricted.
- Executable flag = the node has a command. Restricted flag = the node's requirement fails for a source holding no
  permissions at all (`NO_PERMISSIONS`). Both are computed on the filtered copy.
- Custom suggestions Identifier: the registered name of the node's suggestion provider (§14.4); registered names are
  `minecraft:ask_server`, `minecraft:available_sounds`, `minecraft:summonable_entities`, `minecraft:post_effects`.
  `SuggestionProviders.getName` returns `minecraft:ask_server` for **every** provider that is not one of the registered ones, so any other
  custom or lambda provider is sent as `ask_server`; the 0x10 flag 0x10 is set whenever the node has any custom provider.
- Argument parser id and properties: exactly the table in 05a ("Argument parser registry"); §6 lists the grammar behind
  each id. A node whose argument type is not registered aborts packet creation (`ArgumentTypeInfos.unpack`).

Validation done by a decoder (read, `ClientboundCommandsPacket.validateEntries`): two fixed-point passes over the entry
list, both of which must remove every entry, otherwise the decoder throws `IllegalStateException` with the text
"Server sent an impossible command tree" (the connection fails):

1. **Pass 1 (can build):** an entry that has a redirect can be removed only after the entry it redirects to has been removed;
   an entry without a redirect is removable at once. This rejects redirect cycles.
2. **Pass 2 (can resolve):** an entry can be removed only after **all** its children were removed. This rejects child cycles
   (and a child index that points at an entry that can never resolve).

Out-of-range indices are rejected through the same checks (an index that names no entry never becomes removable).
The root index is the value sent in the packet; whether it must be a root-type entry was not traced (Open question 13).

### 3.5 What the client does with the tree (read)

On receiving 0x10 the client builds its own dispatcher (`ClientPacketListener.handleCommands`):

- Each literal becomes a literal node, each argument an argument node whose type is rebuilt from the parser id and its
  properties, with `suggests(...)` set to the provider registered under the custom-suggestions Identifier when the
  flag is set.
- An executable node gets a do-nothing command.
- A restricted node gets a requirement that passes only if the **client-side permission set** holds the client-only
  atom `client/commands/restricted`.
- The client keeps two suggestion providers (sources): the normal one (`suggestionsProvider`) whose permission set is
  the client's known level set **plus** the atom `client/commands/restricted`, and a "restricted" one holding
  nothing. The normal one is used for typing in the chat box and for sending; the restricted one is used when
  deciding whether a clicked chat link (`run_command` click event) may run unattended.

Unattended commands (click events, `ClientPacketListener.sendUnattendedCommand`): the command is parsed with the
restricted provider.

| Result of check | Behaviour |
|---|---|
| parses with the normal provider but not completely (parse errors) | confirmation dialog with `multiplayer.confirm_command.parse_errors` |
| the command has signable (message) arguments | dialog `multiplayer.confirm_command.signature_required`; only "Copy to Chat Screen" is offered |
| fails with the restricted provider but passes with the normal one (a restricted node) | dialog `multiplayer.confirm_command.permissions_required` |
| no issue | sent immediately as an unsigned command |

This is why servers must set the restricted flag correctly: every command above level 0 is "restricted".

### 3.6 Client-side parse for colouring (read, `CommandSuggestions`)

While the chat box holds text starting with `/`, the client parses it with its local dispatcher (using the normal
provider) every time the text changes; the parse result drives:

| Feature | Rule |
|---|---|
| Text colour | The `/` and the first literal word are drawn gray; each following parsed argument range is coloured by cycling the list aqua, yellow, green, light purple, gold (argument index modulo 5); text that did not parse (after the point where parsing stopped) is red. A literal node's text is gray. |
| Error line | If parsing stopped with exactly one exception, the exception message is shown above the box in the usage area, formatted with the key `command.context.parse_error` ("%s at position %s: %s": context, position, message). Usage hints are shown if no error. |
| Usage hints | When there is no error and no suggestions, the client lists the smart usage of the next possible nodes (children that the player can use), as in Brigadier's smart-usage format. |
| Suggestions | `getCompletionSuggestions(parse, cursor)` of the client's own dispatcher is called; for argument nodes with the `ask_server` provider (§14.4) the client sends a Command Suggestion Request; results are shown in a list of at most 10 lines (§14). |
| Message arguments | When the parse contains a `message` argument, suggestions are only requested when the cursor is inside it, and the player-name suggestions of `getCustomTabSuggestions` can be used for the last word. |

The client does **not** execute or validate semantic rules (existence of an item, a team, a loaded chunk); it only
checks the syntactic grammar of the argument types it can rebuild. Entity selector options, block and item
identifiers are checked against the **client's own registries** (the synchronised registries of 04), so unknown
identifiers show as red text.

---

## 4. Tokenising and parsing (the library part is [15a](15a-brigadier-command-library.md); this section keeps what the game adds)

### 4.1 Input

The server removes **one** leading `/` if present (`Commands.trimOptionalPrefix`), so the packet text normally has none; characters
allowed in a chat command are checked on receipt (§13.1). Words are separated by exactly one space (character 32); nothing collapses
or skips whitespace between nodes, and tabs are ordinary characters (15a §2.4, §2.5). Two spaces therefore give an empty argument
position, which an argument type either accepts (an empty `word` or `string`) or rejects with its own `Expected ...` error at that
position (15a §9.1 example 10).

### 4.2 The string reader (15a §1)

The full primitive table, character classes, number and string rules and error cursors are in 15a §1. Facts that 15 relies on:

| Item | Rule (15a) |
|---|---|
| unquoted run | `0-9 A-Z a-z _ - . +` (§1.2) |
| number run | `0-9 . -`; so `1e5` stops at `e`, `+3` is an empty run (§1.2, §1.3) |
| readInt, readLong, readFloat, readDouble | empty run: the `Expected` error, cursor at the start; run rejected by the Java parser: cursor reset to the start and the `Invalid` error with the run text (§1.3); a huge digit string can parse to infinity and then fail the range check (§1.3) |
| quoted string | the escape character is `\`; only the **active** quote character or a backslash may be escaped; any other character after a backslash gives the invalid-escape error with the cursor on the character **after the backslash** (for `name "a\nb"` the position is 8); an unclosed string gives the end-of-quote error with the cursor at the end of the input, also after a trailing backslash (§1.4) |
| `readString` | at the end of input it returns the empty string without error; a quote start begins a quoted string, otherwise it is an unquoted run (§1.4) |
| `readBoolean` | uses **`readString`**: `"true"` is accepted; an empty result gives the `Expected bool` error with the cursor wherever `readString` left it (after the closing quotes for `""`); any other text resets the cursor to the start and gives the `Invalid bool` error (§1.4) |
| `expect(c)` | consumes `c`, else `Expected 'c'` with the cursor unchanged (§1.1) |
| `skipWhitespace` | Java whitespace (platform behaviour, 15a open question 1); the dispatcher never calls it |
| error context | the library text is the raw message plus ` at position <cursor>: <context>` where the context is `...` when the cursor is above 10, the ten characters before the cursor, and `<--[HERE]`; an exception made without a reader has no context (§1.5). The game builds its own two-line presentation from the raw message (§4.6). |

### 4.3 Argument types of the Brigadier library (wire layout read from the game; grammar in 15a §5)

| Id | Type | Grammar | Errors |
|---|---|---|---|
| 0 | `bool` | `readBoolean` (§4.2) | `parsing.bool.expected`, `parsing.bool.invalid` |
| 1 | `float` | `readFloat`, then range check | `parsing.float.*`; `argument.float.low` / `.big` |
| 2 | `double` | `readDouble`, range | `parsing.double.*`, `argument.double.low/big` |
| 3 | `integer` | `readInt`, range | `parsing.int.*`, `argument.integer.low/big` |
| 4 | `long` | `readLong`, range | `parsing.long.*`, `argument.long.low/big` |
| 5 | `string` | kind 0 SINGLE_WORD: `readUnquotedString` (may be empty); kind 1 QUOTABLE_PHRASE: `readString`; kind 2 GREEDY_PHRASE: the entire rest of the input from the cursor, spaces and quotes included, **no escape processing**, may be empty | quote errors of §4.2 |

Range check (15a §5): after reading the value, a value below the minimum resets the cursor to the start of the argument and raises
the `TooLow` error with (value, min); a value above the maximum likewise raises `TooHigh` with (value, max). Float and double
**default bounds are plus or minus the largest finite value** (not infinities), so a value that parsed to infinity fails the maximum
check with found `Infinity`; integer and long defaults are the 32 and 64 bit limits. The NumberRange property of the Commands packet
(05a) uses the same defaults to decide its flags.

Message text. The **library's** default text (15a §8) is `Integer must not be more than 10, found 11` (a comma, limit first then found
value). The **game's** language file, installed over the library provider, reads `Integer must not be more than %s: found %s` (a colon);
the tables of §5 are the game text. The limit and found value are printed with Java's string conversion of the boxed number (platform
behaviour: `1.0`, `1.0E10`, `Infinity`; 15a open question 1).

### 4.4 The dispatcher parse loop (15a §3)

15a §3.1 gives the complete algorithm; the points that matter for the game:

- Candidates are the relevant children (§3.2). A candidate whose requirement is false is skipped silently (no exception recorded).
- Each candidate is parsed on its own copy of the reader and context; after a node's text the reader must be at the end of the input or
  at a space, else the separator error (`command.expected.separator`, cursor just after the node's text); this applies to literals too.
- A syntax exception is stored per candidate. A Java **runtime exception** thrown inside a node's parse is converted into a syntax exception
  `Could not parse command: <runtime message>` (`command.exception`) and stored the same way.
- Continuing past a node needs **at least two** more characters if the node has **no redirect** (a separator and one more), and **at least one**
  if it has a redirect. With too few characters the branch ends where the node ended (a lone trailing space stays unread).
- With enough characters and **no** redirect: skip the separator, recurse into the node's children and add the result to the candidate list.
  With enough characters and a **redirect**: skip the separator, recurse at the redirect target in a new child context, and **return that
  result immediately**: no other candidate is tried and the candidate list is ignored.
- The best result among several is chosen by a stable sort: a result whose reader is at the end of the input first, then a result with no
  recorded exceptions first, otherwise discovery order (§3.3 of 15a).
- If no candidate produced a result the returned parse holds the context and reader as they were passed in and the map of exceptions.

### 4.5 Deciding the error after a parse (read: `Commands.getParseException`, `finishParsing`; identical to the library's `execute`, 15a §4.1)

After `parse`, the server calls the validation:

| Condition (checked in order) | Result |
|---|---|
| The reader has no unread input | no parse error (go on to execution) |
| The exception map has exactly one entry | that exception (its own message and cursor) |
| The consumed range of the context is empty | `command.unknown.command` ("Unknown or incomplete command. See below for error") with the reader's cursor |
| otherwise | `command.unknown.argument` ("Incorrect argument for command") with the reader's cursor |

If there is no parse error but the final node has **no command** (the input ended inside a command), the context chain
cannot be flattened and the error is `command.unknown.command` with the reader's cursor (read:
`finishParsing`'s fallback builds the unknown-command exception from the reader).

Two or more entries in the exception map (e.g. an argument node and a second argument child both failing) give the
generic message, not a specific one. A trailing space after a complete command (reader at the space) gives
`command.unknown.argument`.

### 4.6 Presentation of a parse error (read)

On a parse error the server sends the sender two System Chat messages (05b 0x7C):

1. **Message line:** the exception's raw message as a component, coloured **red** (`sendFailure` wraps in red).
2. **Context line** (only if the exception carries input and a cursor >= 0): an empty component styled gray, with a
   click event `suggest_command` whose value is `/` followed by the full input. Content, in order, with
   `c = min(len(input), cursor)`:
   - if `c > 10`: an ellipsis component `...` first;
   - the text `input[max(0, c-10) .. c)` (up to 10 characters before the cursor), gray;
   - if `c < len(input)`: the text `input[c ..]`, red and underlined;
   - the translated component `command.context.here` ("<--[HERE]"), red and italic.

The two lines are separate messages. The input shown has no leading `/`.

An unexpected exception while executing (read, `Commands.performCommand`): the sender receives a red message built from
the translation key `command.failed` ("An unexpected error occurred while trying to execute that command"); its hover text
is the exception's message (the exception's class name if it has no message). When the logger's debug level is enabled,
the first three stack frames (method name, newline, file name, `:`, line number, each frame preceded by a blank line) are
appended to that hover text. If `DEBUG_VERBOSE_COMMAND_ERRORS` is set or the game runs inside an IDE, a **second** red
message with `Util.describeError` of the exception is also sent and the error is logged.

---

## 5. Framework translation keys (English, read from `assets/minecraft/lang/en_us.json`)

Every message is sent as a `translate` component; the placeholders `%s` are positional. For wire fixtures a
server sends the key and the argument list; the client formats with its language file. These are the keys the
framework and the shared argument types use; command-specific keys belong to the catalog.

### 5.1 Brigadier built-ins and the dispatcher

| Key | English text |
|---|---|
| `command.unknown.command` | Unknown or incomplete command. See below for error |
| `command.unknown.argument` | Incorrect argument for command |
| `command.expected.separator` | Expected whitespace to end one argument, but found trailing data |
| `command.exception` | Could not parse command: %s |
| `command.context.here` | <--[HERE] |
| `command.context.parse_error` | %s at position %s: %s |
| `command.failed` | An unexpected error occurred while trying to execute that command |
| `command.forkLimit` | Maximum number of contexts (%s) reached |
| `command.trailing_data` | Trailing data found: %s |
| `commands.help.failed` | Unknown command or insufficient permissions |
| `parsing.expected` | Expected '%s' |
| `parsing.bool.expected` | Expected boolean |
| `parsing.bool.invalid` | Invalid boolean: expected 'true' or 'false' but found '%s' |
| `parsing.int.expected` | Expected integer |
| `parsing.int.invalid` | Invalid integer '%s' |
| `parsing.long.expected` | Expected long |
| `parsing.long.invalid` | Invalid long '%s' |
| `parsing.float.expected` | Expected float |
| `parsing.float.invalid` | Invalid float '%s' |
| `parsing.double.expected` | Expected double |
| `parsing.double.invalid` | Invalid double '%s' |
| `parsing.quote.escape` | Invalid escape sequence '\%s' in quoted string |
| `parsing.quote.expected.start` | Expected quote to start a string |
| `parsing.quote.expected.end` | Unclosed quoted string |
| `argument.literal.incorrect` | Expected literal %s |
| `argument.integer.low` | Integer must not be less than %s: found %s |
| `argument.integer.big` | Integer must not be more than %s: found %s |
| `argument.long.low` | Long must not be less than %s: found %s |
| `argument.long.big` | Long must not be more than %s: found %s |
| `argument.float.low` | Float must not be less than %s: found %s |
| `argument.float.big` | Float must not be more than %s: found %s |
| `argument.double.low` | Double must not be less than %s: found %s |
| `argument.double.big` | Double must not be more than %s: found %s |
| `permissions.requires.player` | A player is required to run this command here |
| `permissions.requires.entity` | An entity is required to run this command here |
| `chat.type.admin` | [%s: %s] |
| `chat.disabled.invalid_command_signature` | The command had unexpected or missing command argument signatures. |
| `multiplayer.disconnect.illegal_characters` | Illegal characters in chat |
| `multiplayer.disconnect.chat_validation_failed` | Chat message validation failure |
| `chat.validation_error` | Chat validation error |
| `multiplayer.disconnect.too_many_pending_chats` | Too many unacknowledged chat messages |
| `disconnect.spam` | Kicked for spamming |
| `chat.disabled.options` | Chat disabled in client options. |
| `chat_screen.commands_not_allowed` | Sending commands is not allowed |
| `multiplayer.confirm_command.title` | Confirm Command Execution |
| `multiplayer.confirm_command.parse_errors` | You are trying to execute an unrecognized or invalid command.\nAre you sure?\nCommand: %s |
| `multiplayer.confirm_command.permissions_required` | You are trying to execute a command that requires elevated permissions.\nThis might negatively affect your game.\nAre you sure?\nCommand: %s |
| `multiplayer.confirm_command.signature_required` | You are trying to execute a command that will send chat messages using your name.\nIt can only be run from the chat screen.\nCommand: %s |
| `multiplayer.confirm_command.run_command` | Run Command |
| `multiplayer.confirm_command.suggest_command` | Copy to Chat Screen |

For `parsing.*.invalid` and `argument.*.low/big` the arguments are strings (the offending text or the numbers).
`translatableEscape` is used for these: a `%` in an argument is escaped so that it cannot act as a format code.

### 5.2 Selector keys

| Key | English text |
|---|---|
| `argument.entity.invalid` | Invalid name or UUID |
| `argument.entity.notfound.entity` | No entity was found |
| `argument.entity.notfound.player` | No player was found |
| `argument.entity.toomany` | Only one entity is allowed, but the provided selector allows more than one |
| `argument.player.toomany` | Only one player is allowed, but the provided selector allows more than one |
| `argument.player.entities` | Only players may be affected by this command, but the provided selector includes entities |
| `argument.player.unknown` | That player does not exist |
| `argument.entity.selector.not_allowed` | Selector not allowed |
| `argument.entity.selector.missing` | Missing selector type |
| `argument.entity.selector.unknown` | Unknown selector type '%s' |
| `argument.entity.options.unknown` | Unknown option '%s' |
| `argument.entity.options.inapplicable` | Option '%s' isn't applicable here |
| `argument.entity.options.valueless` | Expected value for option '%s' |
| `argument.entity.options.unterminated` | Expected end of options |
| `argument.entity.options.distance.negative` | Distance cannot be negative |
| `argument.entity.options.level.negative` | Level shouldn't be negative |
| `argument.entity.options.limit.toosmall` | Limit must be at least 1 |
| `argument.entity.options.mode.invalid` | Invalid or unknown game mode '%s' |
| `argument.entity.options.sort.irreversible` | Invalid or unknown sort type '%s' |
| `argument.entity.options.type.invalid` | Invalid or unknown entity type '%s' |
| `argument.entity.selector.nearestPlayer` / `allPlayers` / `randomPlayer` / `self` / `allEntities` / `nearestEntity` | Nearest player / All players / Random player / Current entity / All entities / Nearest entity (suggestion tooltips for `@p @a @r @s @e @n`) |
| `argument.entity.options.<name>.description` | tooltips for option names: name "Entity name", distance "Distance to entity", level "Experience level", x "x position", y "y position", z "z position", dx "Entities between x and x + dx", dy "... y and y + dy", dz "... z and z + dz", x_rotation "Entity's x rotation", y_rotation "Entity's y rotation", limit "Maximum number of entities to return", sort "Sort the entities", gamemode "Players with game mode", team "Entities on team", type "Entities of type", tag "Entities with tag", nbt "Entities with NBT", scores "Entities with scores", advancements "Players with advancements", predicate "Custom predicate" |
| `argument.scoreHolder.empty` | No relevant score holders could be found |

### 5.3 Other shared argument keys

| Key | English text |
|---|---|
| `argument.pos.missing.double` | Expected a coordinate |
| `argument.pos.missing.int` | Expected a block position |
| `argument.pos.mixed` | Cannot mix world and local coordinates (everything must either use ^ or not) |
| `argument.pos.outofbounds` | That position is outside the allowed boundaries |
| `argument.pos.outofworld` | That position is out of this world! |
| `argument.pos.unloaded` | That position is not loaded |
| `argument.pos2d.incomplete` | Incomplete (expected 2 coordinates) |
| `argument.pos3d.incomplete` | Incomplete (expected 3 coordinates) |
| `argument.rotation.incomplete` | Incomplete (expected 2 coordinates) |
| `argument.angle.incomplete` | Incomplete (expected 1 angle) |
| `argument.angle.invalid` | Invalid angle |
| `argument.range.empty` | Expected value or range of values |
| `argument.range.ints` | Only whole numbers are allowed; not decimals |
| `argument.range.swapped` | Min cannot be bigger than max |
| `argument.time.invalid_unit` | Invalid unit |
| `argument.time.invalid_tick_count` | The tick count must be non-negative |
| `argument.time.tick_count_too_low` | The tick count must not be less than %s: found %s |
| `argument.uuid.invalid` | Invalid UUID |
| `argument.id.invalid` | Invalid ID |
| `argument.id.unknown` | Unknown ID: %s |
| `argument.dimension.invalid` | Unknown dimension '%s' |
| `argument.gamemode.invalid` | Unknown game mode: %s |
| `argument.anchor.invalid` | Invalid entity anchor position %s |
| `argument.color.invalid` | Unknown color '%s' |
| `argument.hexcolor.invalid` | Invalid hex color code '%s' |
| `argument.component.invalid` | Invalid chat component: %s |
| `argument.style.invalid` | Invalid style: %s |
| `argument.criteria.invalid` | Unknown criterion '%s' |
| `argument.enum.invalid` | Invalid value '%s' |
| `argument.swing_animation.invalid` | Unknown swing animation type: %s |
| `argument.waypoint.invalid` | Selected entity is not a waypoint |
| `argument.scoreboardDisplaySlot.invalid` | Unknown display slot '%s' |
| `argument.message.too_long` | Chat message was too long (%s > maximum %s characters) |
| `argument.block.id.invalid` | Unknown block type '%s' |
| `argument.block.property.duplicate` | Property '%s' can only be set once for block %s |
| `argument.block.property.invalid` | Block %s does not accept '%s' for %s property |
| `argument.block.property.novalue` | Expected value for property '%s' on block %s |
| `argument.block.property.unclosed` | Expected closing ] for block state properties |
| `argument.block.property.unknown` | Block %s does not have property '%s' |
| `argument.block.tag.disallowed` | Tags aren't allowed here; only actual blocks are |
| `arguments.block.tag.unknown` | Unknown block tag '%s' |
| `argument.item.id.invalid` | Unknown item '%s' |
| `argument.item.tag.disallowed` | Tags aren't allowed here; only actual items are |
| `arguments.item.malformed` | Malformed item: '%s' |
| `arguments.item.overstacked` | %s can only stack up to %s |
| `arguments.item.component.expected` | Expected item component |
| `arguments.item.component.malformed` | Malformed '%s' component: '%s' |
| `arguments.item.component.repeated` | Item component '%s' was repeated, but only one value can be specified |
| `arguments.item.component.unknown` | Unknown item component '%s' |
| `arguments.item.predicate.malformed` | Malformed '%s' predicate: '%s' |
| `arguments.item.predicate.unknown` | Unknown item predicate '%s' |
| `arguments.item.tag.unknown` | Unknown item tag '%s' |
| `arguments.function.unknown` | Unknown function %s |
| `arguments.function.tag.unknown` | Unknown function tag '%s' |
| `arguments.nbtpath.node.invalid` | Invalid NBT path element |
| `arguments.nbtpath.nothing_found` | Found no elements matching %s |
| `arguments.nbtpath.too_deep` | Resulting NBT too deeply nested |
| `arguments.nbtpath.too_large` | Resulting NBT too large |
| `argument.nbt.expected.compound` | Expected compound tag |
| `argument.nbt.expected.key` | Expected key |
| `argument.nbt.expected.value` | Expected value |
| `argument.nbt.trailing` | Unexpected trailing data |
| `argument.nbt.array.invalid` | Invalid array type '%s' |
| `argument.nbt.array.mixed` | Can't insert %s into %s |
| `argument.nbt.list.mixed` | Can't insert %s into list of %s |
| `arguments.objective.notFound` | Unknown scoreboard objective '%s' |
| `arguments.objective.readonly` | Scoreboard objective '%s' is read-only |
| `arguments.operation.invalid` | Invalid operation |
| `arguments.operation.div0` | Cannot divide by zero |
| `arguments.swizzle.invalid` | Invalid swizzle: expected combination of 'x', 'y' and 'z' |
| `team.notFound` | Unknown team '%s' |
| `particle.notFound` | Unknown particle: %s |
| `particle.invalidOptions` | Can't parse particle options: %s |
| `slot.unknown` | Unknown slot '%s' |
| `slot.only_single_allowed` | Only single slots allowed: got '%s' |
| `entity.not_summonable` | Can't summon entity of type %s |
| `advancement.advancementNotFound` | Unknown advancement: %s |
| `recipe.notFound` | Unknown recipe: %s |
| `argument.resource.not_found` | Can't find element '%s' of type '%s' |
| `argument.resource.invalid_type` | Element '%s' has wrong type '%s' (expected '%s') |
| `argument.resource_tag.not_found` | Can't find tag '%s' of type '%s' |
| `argument.resource_tag.invalid_type` | Tag '%s' has wrong type '%s' (expected '%s') |
| `argument.resource_or_id.failed_to_parse` | Failed to parse structure: %s |
| `argument.resource_or_id.invalid` | Invalid ID or tag |
| `argument.resource_or_id.no_such_element` | Can't find element '%s' in registry '%s' |
| `argument.resource_selector.not_found` | No matches for selector '%s' of type '%s' |
| `snbt.parser.*` | see §9.4 |

### 5.4 Execution feedback keys used by the framework

| Key | English text |
|---|---|
| `commands.execute.conditional.pass` | Test passed |
| `commands.execute.conditional.pass_count` | Test passed. Count: %s |
| `commands.execute.conditional.fail` | Test failed |
| `commands.execute.conditional.fail_count` | Test failed. Count: %s |
| `commands.execute.blocks.toobig` | Too many blocks in the specified area (maximum %s, but specified %s) |
| `commands.execute.function.instantiationFailure` | Failed to instantiate function %s: %s |
| `commands.function.instantiationFailure` | Failed to instantiate function %s: %s |
| `commands.function.result` | Function %s returned %s |
| `commands.function.scheduled.single` / `.multiple` / `.no_functions` | Running function %s / Running functions %s / Can't find any functions for name %s |
| `commands.function.success.single` | Executed %s command(s) from function '%s' |
| `commands.function.success.multiple` | Executed %s command(s) from %s functions |
| `commands.function.success.single.result` | Function '%2$s' returned %1$s |
| `commands.function.success.multiple.result` | Executed %s functions |
| `commands.function.error.argument_not_compound` | Invalid argument type: %s. Expected Compound |
| `commands.function.error.missing_argument` | Missing argument %2$s to function %1$s |
| `commands.function.error.missing_arguments` | Missing arguments to function %s |
| `commands.function.error.parse` | While instantiating macro %s: Command '%s' caused error: %s |

---

## 6. Argument types (grammar, wire id, properties, results)

For each type: **id** is the parser id of 05a; **props** the property bytes; **grammar** how the text is consumed;
**value** what the executor receives. Unless stated, parsing stops at the first space or end of input and the
cursor is left on the space. "(read)" means read from the bundled classes; "(inferred)" means deduced from names or call shapes; "(recalled, not verified)" means taken from memory.

### 6.1 Overview table

| Id | Parser | Props | Section |
|---|---|---|---|
| 0 | bool | none | §4.3 |
| 1, 2, 3, 4 | float, double, integer, long | NumberRange | §4.3 |
| 5 | string | kind | §4.3 |
| 6 | entity | flags | §7 |
| 7 | game_profile | none | §7.8 |
| 8 | block_pos | none | §8 |
| 9 | column_pos | none | §8 |
| 10 | vec3 | none | §8 |
| 11 | vec2 | none | §8 |
| 12 | block_state | none | §9.1 |
| 13 | block_predicate | none | §9.1 |
| 14 | item_stack | none | §9.2 |
| 15 | item_predicate | none | §9.2 |
| 16 | team_color | exactly the 16 names of `TeamColor` (read): `black dark_blue dark_green dark_aqua dark_red dark_purple gold gray dark_gray blue green aqua red light_purple yellow white`; there is no `reset` | `argument.color.invalid` |
| 17 | hex_color | none | §6.2 |
| 18 | component | none | §9.3 |
| 19 | style | none | §9.3 |
| 20 | message | none | §6.3 |
| 21, 22, 23 | nbt_compound_tag, nbt_tag, nbt_path | none | §9.4, §9.5 |
| 24 | objective | none | §6.4 |
| 25 | objective_criteria | none | §6.4 |
| 26 | operation | none | §6.4 |
| 27 | particle | none | §6.5 |
| 28 | angle | none | §8.5 |
| 29 | rotation | none | §8.4 |
| 30 | scoreboard_slot | none | §6.4 |
| 31 | score_holder | flags (0x01 multiple) | §7.9 |
| 32 | swizzle | none | §8.6 |
| 33 | team | none | §6.4 |
| 34, 35 | item_slot, item_slots | none | §6.6 |
| 36 | resource_location | none | §6.7 |
| 37 | function | none | §6.8 |
| 38 | entity_anchor | none | §6.2 |
| 39, 40 | int_range, float_range | none | §6.9 |
| 41 | dimension | none | §6.7 |
| 42 | gamemode | none | §6.2 |
| 43 | time | Int minimum | §6.10 |
| 44..48 | resource_or_tag, resource_or_tag_key, resource, resource_key, resource_selector | registry key Identifier | §6.7 |
| 49, 50 | template_mirror, template_rotation | none | §6.2 |
| 51 | heightmap | the lower-cased serialised names of the heightmap types kept by `HeightmapTypeArgument.keptTypes` (a filter over `Heightmap.Types.values()`; `Types.keepAfterWorldgen()` is true when the type's usage is not WORLDGEN, and the two `_WG` types have usage WORLDGEN while the other four have CLIENT or LIVE_WORLD): `world_surface`, `ocean_floor`, `motion_blocking`, `motion_blocking_no_leaves` (the filter is `Types.keepAfterWorldgen`, read) | `argument.enum.invalid` |
| 52, 53, 54 | loot_table, loot_predicate, loot_modifier | none | §6.7 |
| 55, 56 | context_float_provider, context_int_provider | none | §6.7 |
| 57 | slot_source | none | §6.6 |
| 58 | dialog | none | §6.7 |
| 59 | feature | none | §6.7 |
| 60 | swing_animation | `none`, `whack`, `stab` (the constants of `SwingAnimationType`, read) | `argument.swing_animation.invalid` |
| 61 | uuid | none | §6.3 |

An argument type that is not in the table is never sent by the standard commands. The `waypoint` argument type
(`argument.waypoint.invalid`) is built on the selector and has no id of its own (it uses entity, §7).

### 6.2 Enumerations (StringRepresentable arguments; read)

Grammar: read an **unquoted run** (§4.2) and look it up exactly (case-sensitive) in the name list; unknown gives the
type's `invalid` key with the run. Cursor after an invalid value (read): the `StringRepresentableArgument` family (heightmap, template_mirror,
template_rotation, swing_animation) leaves the cursor **after the unquoted run** with no reset; `gamemode` and `team_color` do not reset either;
`entity_anchor` **resets to the start** of the run.

| Id | Type | Names (exact) | Invalid key |
|---|---|---|---|
| 42 | gamemode | `survival`, `creative`, `adventure`, `spectator` | `argument.gamemode.invalid` ("Unknown game mode: %s") |
| 38 | entity_anchor | `feet`, `eyes` | `argument.anchor.invalid` |
| 49 | template_mirror | `none`, `left_right`, `front_back` | `argument.enum.invalid` |
| 50 | template_rotation | `none`, `clockwise_90`, `180`, `counterclockwise_90` | `argument.enum.invalid` |
| 51 | heightmap | the lower-cased serialised names of the heightmap types kept by `HeightmapTypeArgument.keptTypes` (a filter over `Heightmap.Types.values()`; `Types.keepAfterWorldgen()` is true when the type's usage is not WORLDGEN, and the two `_WG` types have usage WORLDGEN while the other four have CLIENT or LIVE_WORLD): `world_surface`, `ocean_floor`, `motion_blocking`, `motion_blocking_no_leaves` (the filter is `Types.keepAfterWorldgen`, read) | `argument.enum.invalid` |
| 60 | swing_animation | `none`, `whack`, `stab` (the constants of `SwingAnimationType`, read) | `argument.swing_animation.invalid` |
| 16 | team_color | exactly the 16 names of `TeamColor` (read): `black dark_blue dark_green dark_aqua dark_red dark_purple gold gray dark_gray blue green aqua red light_purple yellow white`; there is no `reset` | `argument.color.invalid` |
| 17 | hex_color | an unquoted run of exactly 3 or 6 hexadecimal digits without `#` (length switch and `parseInt` radix 16 read): 3 digits are doubled each (`F00` = `FF0000`), 6 digits are three byte pairs; value is an RGB integer (ARGB.color) | `argument.hexcolor.invalid` |


### 6.3 Message, uuid

| Id | Type | Grammar and rules | Notes |
|---|---|---|---|
| 20 | message | `MessageArgument.parse` calls `Message.parseText(reader, true)`. (1) If the remaining text is longer than **256** characters (`getRemainingLength() > 256`): `argument.message.too_long` with arguments (length, 256), created **without** input context (no cursor, so no context line, §4.6). (2) A branch controlled by the boolean parameter of `parseText` (false) moves the reader to the end and returns no parts; argument id 20 always passes true, so that branch is never used. (3) Otherwise the text is scanned from the cursor: every `@` starts an entity-selector parse (the selector parser with selectors allowed, §7); a selector parse error of the kind "missing selector type" or "unknown selector type" is swallowed: the cursor is set one character after the `@` and the `@` stays plain text; any other selector error fails the parse. A successfully parsed selector is stored as a part (start, end, selector); all other text is consumed greedily to the end of the line. | signable argument (§13) |
| | message resolution | `Message.resolveComponent(source)` evaluates the selectors only if the source's permission set holds `commands/entity_selectors`; without that permission the **whole text** is used as literal text (selector text included) even though it parsed. With permission, each part is replaced by `EntitySelector.joinNames(findEntities(source))` and the text between parts is kept literally. `joinNames` is `ComponentUtils.formatList` with the default separator, a **gray** `, `; a list of one entity is that entity's display name as is, an empty list gives an empty component. There is no "and" before the last name. | |
| 61 | uuid | `UuidArgument` reads an unquoted run (the class holds the pattern `^([-A-Fa-f0-9]+)`) and converts it to a UUID; failure gives `argument.uuid.invalid` | value is a 128-bit UUID |

### 6.4 Scoreboard-related types (read)

| Id | Type | Grammar | Errors |
|---|---|---|---|
| 24 | objective | `readUnquotedString` | unknown objective at execution: `arguments.objective.notFound`; read-only: `arguments.objective.readonly` |
| 25 | objective_criteria | the text up to the next space (no character restriction) is looked up by `ObjectiveCriteria.byName`: first in the table of fixed names, else the text must contain a `:` and is split at the **first** `:`: the part before it is turned into an Identifier with `.` as the separator (so `minecraft.mined` means `minecraft:mined`) and looked up in the **stat type** registry, the part after it (also with `.` as separator) is the stat value looked up in that stat type's registry | `argument.criteria.invalid` ("Unknown criterion '%s'") with the cursor reset to the start of the text |
| 26 | operation | the text up to the next space, matched exactly against the nine tokens `=` `+=` `-=` `*=` `/=` `%=` `<` `>` `><` | empty input or unknown token: `arguments.operation.invalid`; division or modulo by zero at execution: `arguments.operation.div0` |
| 30 | scoreboard_slot | `readUnquotedString`, looked up in the `DisplaySlot` names (below) | `argument.scoreboardDisplaySlot.invalid` |
| 33 | team | `readUnquotedString`; looked up at execution | `team.notFound` ("Unknown team '%s'") |
| 31 | score_holder | §7.9 | `argument.scoreHolder.empty` |

Fixed criterion names (`ObjectiveCriteria` constants, read): `dummy`, `trigger`, `deathCount`, `playerKillCount`,
`totalKillCount` (these five are not read-only), `health`, `food`, `air`, `armor`, `xp`, `level` (these six are read-only,
which the `objective` argument and several commands refuse). In addition there are per-team-colour criteria named
`teamkill.<color>` and `killedByTeam.<color>` for each of the 16 `TeamColor` names. The stat form is
`<stattype>:<statvalue>` with `.` in place of `:` inside each half, for example `minecraft.mined:minecraft.stone`
(the stat type and value registries are data of the game, not listed here).

`DisplaySlot` names (read): `list`, `sidebar`, `below_name`, then `sidebar.team.<color>` for each `TeamColor` name
(`black dark_blue dark_green dark_aqua dark_red dark_purple gold gray dark_gray blue green aqua red light_purple yellow white`).

### 6.5 Particle

Grammar: a resource location (the particle type, `minecraft:` default) optionally followed by SNBT options in
`{...}` (since 26.x the particle options are an SNBT compound, example `particle{foo:bar}`). Errors:
`particle.notFound` (type), `particle.invalidOptions` (options parse failure). (read: examples and keys; the option
set per particle type is data-driven, see catalog.)

### 6.6 Item slots (read: `SlotRanges`, `SlotArgument`, `SlotsArgument`)

| Id | Type | Grammar |
|---|---|---|
| 34 | item_slot | `SlotRanges.read` (the text up to the next space is looked up by name; unknown: `slot.unknown`); the range must contain exactly one slot, else `slot.only_single_allowed` with the range's name; value is the slot number |
| 35 | item_slots | the same read; the value is the slot range (a list of slot numbers) |
| 57 | slot_source | used by the `item` commands to name an entity or block as the slot owner (grammar not traced: Open question 6) |

Slot table (read from the static table of `SlotRanges`; `n..m` are generated names `prefix.i`; every `prefix.N`
range also registers `prefix.*` containing all its slots in order):

| Names | Slot numbers |
|---|---|
| `contents` | 0 |
| `container.0` to `container.53`, group `container.*` | 0 to 53 |
| `hotbar.0` to `hotbar.8`, group `hotbar.*` | 0 to 8 |
| `inventory.0` to `inventory.26`, group `inventory.*` | 9 to 35 |
| `enderchest.0` to `enderchest.26`, group `enderchest.*` | 200 to 226 |
| `mob.inventory.0` to `mob.inventory.7`, group `mob.inventory.*` | 300 to 307 (`MOB_INVENTORY_SLOT_OFFSET` 300, `MOB_INVENTORY_SIZE` 8) |
| `horse.0` to `horse.14`, group `horse.*` | 500 to 514 |
| `weapon` and `weapon.mainhand` | 98 |
| `weapon.offhand` | 99 (98 plus the equipment index 1) |
| group `weapon.*` | 98, 99 |
| `armor.feet` | 100 |
| `armor.legs` | 101 |
| `armor.chest` | 102 |
| `armor.head` | 103 |
| `armor.body` | 105 (the body slot has equipment index 0 in its own type, offset 105) |
| group `armor.*` | head, chest, legs, feet, body: 103, 102, 101, 100, 105 (in that order) |
| `saddle` | 106 |
| `horse.chest` | 499 |
| `player.cursor` | 499 |
| `player.crafting.0` to `player.crafting.3`, group `player.crafting.*` | 500 to 503 |

The armor and weapon numbers are `equipment-slot index + base` (base 98 for hands, 100 for the humanoid armor slots, 105 for
the animal armor slot, 106 for the saddle) read from `EquipmentSlot.getIndex(int)` and the equipment slot constants; the
indices (hands 0 and 1; feet 0, legs 1, chest 2, head 3; body 0 of the animal armor type) were read from the enum
constructors. There are **no** `horse.saddle`, `horse.armor` or `villager.N` names in this version.

### 6.7 Resource locations and registry-backed types

`Identifier` (resource location) grammar (read: `Identifier.read(StringReader)`, `readGreedy`, `isAllowedInIdentifier`,
`validNamespaceChar`, `validPathChar`): the reader consumes the longest run of the characters `0-9`, `a-z`, `_`, `:`, `/`, `.`, `-`
(upper case is not allowed), then parses the run; a run that is not a valid identifier resets the cursor to the start and gives
`argument.id.invalid` ("Invalid ID"). Valid namespace characters: `a-z 0-9 _ - .`. Valid path characters: `a-z 0-9 _ - / .`.
Without a `:` the namespace is `minecraft` (the string constant `minecraft` is used by `parse`). Example inputs read from the
class: `foo`, `foo:bar`, `012`. There is also a `readNonEmpty` variant (not traced).

| Id | Type | Value | Not found |
|---|---|---|---|
| 36 | resource_location | an Identifier | none |
| 41 | dimension | an Identifier that must name a loaded level; value is the level key | `argument.dimension.invalid` |
| 46 | resource (registry R) | holder of an element of registry R | `argument.resource.not_found`, wrong registry `argument.resource.invalid_type` |
| 47 | resource_key (registry R) | a resource key in R (advancement, recipe, structure, jigsaw pool) | `advancement.advancementNotFound`, `recipe.notFound`, `commands.place.structure.invalid`, `commands.place.jigsaw.invalid` as the per-registry lookups define |
| 44 | resource_or_tag (R) | an Identifier, or `#` Identifier for a tag | `argument.resource_tag.not_found`, `.invalid_type` |
| 45 | resource_or_tag_key (R) | same, but returns keys | same keys |
| 48 | resource_selector (R) | an identifier pattern with `*` wildcards (examples `*`, `minecraft:*`, `*:asset`) matching registered elements | `argument.resource_selector.not_found` ("No matches for selector '%s' of type '%s'") |
| 52, 53, 54 | loot_table, loot_predicate, loot_modifier | an Identifier of that registry, **or** an inline SNBT/JSON definition starting with `{` (inline definitions are parsed with the data-driven codec) | `argument.resource_or_id.no_such_element`, `.failed_to_parse`, `.invalid` |
| 55, 56 | context_float_provider, context_int_provider | a number, or an Identifier of a provider, or an inline definition `{...}` | same keys |
| 58 | dialog | an Identifier of a dialog or an inline definition | same keys |
| 59 | feature | an Identifier of a configured feature or an inline definition | same keys |

Summonable entity types use `resource` with registry `entity_type` and the suggestion provider
`minecraft:summonable_entities` (§14.4); an entity type that cannot be summoned gives `entity.not_summonable` (read).
The registry key property is an Identifier such as `minecraft:entity_type`, `minecraft:mob_effect`, `minecraft:enchantment`,
`minecraft:attribute`, `minecraft:biome`, `minecraft:structure`, `minecraft:point_of_interest_type`,
`minecraft:potion`, ... (the set of registries comes from the standard commands, listed in the catalog).

### 6.8 Function

| Id | Type | Grammar |
|---|---|---|
| 37 | function | an Identifier naming a function, or `#` followed by an Identifier naming a function tag (the examples read are `foo`, `foo:bar`, `#foo`); value is a list of functions. Unknown: `arguments.function.unknown`, `arguments.function.tag.unknown`. (The `#` prefix is read from the examples; how the argument consumes it was not traced.) |

### 6.9 Ranges (read: `MinMaxBounds`, `MinMaxBounds$Bounds.fromReader`, `RangeArgument`)

Ids 39 `int_range` (`MinMaxBounds$Ints`) and 40 `float_range` (`MinMaxBounds$Doubles`). Shared range reader:

1. If the input is exhausted: `argument.range.empty` ("Expected value or range of values"), at the cursor.
2. Read the **first number** (the longest run of characters that are `0-9` or `-`, or a `.` that is **not** followed by another
   `.`; so `..` is never part of a number). An empty run means "absent".
3. If the next two characters are `..`, skip them and read a **second number** the same way (absent allowed). Both bounds absent
   gives `argument.range.empty`. The result is (min = first, max = second).
4. If there is no `..`, the single number is both min and max (a single value). An empty single value is `argument.range.empty`.
5. The run is converted with the type's parser; a number that does not convert raises the type's invalid-number error
   (`parsing.int.invalid` for integer ranges, `parsing.double.invalid` for float ranges, `parsing.float.invalid` for degree ranges) and the cursor is reset to the start.
6. **Integer ranges and float ranges (`Ints` and `Doubles`):** if min is greater than max, the cursor is reset to the start of the range and
   the error is `argument.range.swapped` ("Min cannot be bigger than max"). **Degree ranges** (`FloatDegrees`, selector `x_rotation` and
   `y_rotation`) have no swapped check (a minimum above the maximum is a valid wrap-around interval, §7.5) and their number conversion fails
   with `parsing.float.invalid` (S8).

Examples (read in the argument classes): int `0..5`, `0`, `-5`, `-100..`, `..100`; float `0..5.2`, `0`, `-5.4`, `-100.76..`, `..100`.
The key `argument.range.ints` exists in the language file but no bundled class uses it, so a decimal in an integer range
gives `parsing.int.invalid`, not `argument.range.ints`. The ranges are also used by the selector options `distance` (Doubles),
`level` (Ints), `scores` (Ints), `x_rotation` and `y_rotation` (FloatDegrees).

### 6.10 Time

Id 43. Grammar (read): a float (read with `readFloat`), then an unquoted run as the unit:

| Unit text | Ticks per unit |
|---|---|
| (empty) | 1 |
| `t` | 1 |
| `s` | 20 |
| `d` | 24000 |

An unknown unit gives `argument.time.invalid_unit` (cursor after the unit). The value is `round(number * unit)` as a Java
`Math.round` of the float product (round half up to a positive integer; negative halves toward positive infinity). If
the result is below the **minimum** carried in the parser's property (Int), the error is
`argument.time.tick_count_too_low` with the minimum and the found value. Examples (minimum 0): `10` = 10 ticks, `10t` = 10,
`1.5s` = 30, `1d` = 24000, `0.5d` = 12000, `-1` with minimum 0 = error `The tick count must not be less than 0: found -1`.
Because `readFloat` stops at `e` (15a §1.3), `1e3s` reads the float `1` and the unit run `e3s`, which is unknown: `argument.time.invalid_unit`.

---

## 7. Entity selectors

### 7.1 Argument types and flags

Id 6 `entity`, properties byte: bit 0x01 = **single** target only, bit 0x02 = **players only**. The four combinations
are the "entity", "entities", "player", "players" argument builders of the commands. Id 7 `game_profile` (§7.8).
Id 31 `score_holder` (§7.9).

Both kinds of text are accepted at one argument position: a **selector** (starts with `@`), or a **player name /
UUID** string.

### 7.2 Top-level grammar (read: `EntitySelectorParser`)

1. If the next character is `@`: if selectors are not allowed for the source (§2.3) → `argument.entity.selector.not_allowed`
   (cursor on the `@`). Otherwise skip `@` and read one character as the **selector type** (error cases below),
   then an optional option list `[ ... ]` immediately after the type character (no space).
2. Otherwise (no `@`): read a **string** with `readString` (so a quoted name or UUID is allowed). If it parses as a UUID
   (Java `UUID.fromString`, lenient: the groups may be shorter than 8-4-4-4-12 digits) the selector matches that
   entity by UUID (includes entities, any dimension). Otherwise it is a **player name**: the string must be non-empty
   and at most 16 characters; else `argument.entity.invalid` ("Invalid name or UUID") with the cursor reset to the
   start. A name selector has limit 1.
3. A selector type missing at end of input: `argument.entity.selector.missing`; an unknown type character `c`:
   cursor set to the character after `@`, `argument.entity.selector.unknown` with `'@c'` as the argument
   (message "Unknown selector type '@c'").
4. After the selector is parsed, `EntityArgument.parse` applies the argument's flags: **single** (flag 0x01) with a selector
   whose maximum result count is greater than 1 gives `argument.entity.toomany` (entity argument) or
   `argument.player.toomany` (players-only argument); **players-only** (flag 0x02) with a selector that includes
   non-player entities, **except `@s`**, gives `argument.player.entities`. For all three checks the cursor is reset with
   `setCursor(0)`, that is to position **0 of the whole input line**, not to the start of the argument. Consequence for
   the context line (§4.6): the gray prefix is empty, the entire input is red and underlined, followed by `<--[HERE]`.
5. At execution (read): a lookup returning nothing gives `argument.entity.notfound.entity` or
   `argument.entity.notfound.player` (players-only), or an empty target list for the "possibly empty" accessor
   (commands choose which).

### 7.3 Selector types (read)

| Text | Meaning | Limit | Includes non-players | Order | Extra |
|---|---|---|---|---|---|
| `@p` | nearest player | 1 | no | nearest | |
| `@a` | all players | unlimited | no | arbitrary (world order) | |
| `@r` | random player | 1 | no | random | |
| `@s` | the executing entity | 1 | yes | n/a (current entity) | `limit` and `sort` options are not applicable (`Option 'limit' isn't applicable here`) |
| `@e` | all entities | unlimited | yes | arbitrary | the extra predicate added for `@e` and `@n` is `Entity::isAlive` (read) |
| `@n` | nearest entity | 1 | yes | nearest | same extra predicate as `@e` |

"Unlimited" is `Integer.MAX_VALUE`. A source without an executing entity that uses `@s` does **not** raise `permissions.requires.entity`: `findEntities` and `findPlayers` return an empty list, and the non-optional accessors then give `argument.entity.notfound.entity` or `argument.entity.notfound.player`.

### 7.4 Option list grammar (read: `parseOptions`)

`[` was consumed. Loop:

1. Skip whitespace. If at end of input or the next character is `]`, leave the loop.
2. Skip whitespace. Remember the cursor. Read the option **key** with `readString`.
3. Look the key up in the option table (§7.5). Unknown: reset the cursor to the start of the key and give
   `argument.entity.options.unknown`. Known but not applicable now (its `canUse` fails): reset the cursor to the start
   of the key and give `argument.entity.options.inapplicable`.
4. Skip whitespace. The next character must be `=`; else reset the cursor to the start of the key and give
   `argument.entity.options.valueless` with the key. Skip `=` and whitespace.
5. Run the option's value reader (§7.5); it consumes the value and registers a predicate or a setting.
6. Skip whitespace. If the next character is `,` consume it and loop (a `,` before `]` is accepted: `[a=1,]`); if it is
   `]` finish; otherwise `argument.entity.options.unterminated` ("Expected end of options") at the cursor.
7. After the loop the next character must be `]` (consumed); at end of input without `]`: `argument.entity.options.unterminated`.

Whitespace inside the brackets is allowed (this is the only place the command string may contain a space inside an
argument without quotes; the selector argument ends at the closing `]`). Keys are case-sensitive.

### 7.5 Options (read: `EntitySelectorOptions`, `InvertableSetOptionState`, `SetOnceOptionState`)

The option table (`bootStrap`) registers these keys in this order: `name`, `distance`, `level`, `x`, `y`, `z`, `dx`, `dy`, `dz`,
`x_rotation`, `y_rotation`, `limit`, `sort`, `gamemode`, `team`, `type`, `tag`, `nbt`, `scores`, `advancements`, `predicate`.
Each option has a value reader, an applicability test (`canUse`) and a tooltip key (§5.2).

**Option states.**
- `InvertableSetOptionState` (used only by `name`, `gamemode`, `team` and `type`) has three values: NONE, SINGLE, MULTIPLE.
  A **positive** value is allowed only from NONE and sets SINGLE. A **negative** (`!`) value is allowed unless the state is
  SINGLE and sets MULTIPLE. So after a positive value nothing more of either polarity is accepted, and after a negative
  value only negatives are. For `type` tags (`#t` and `!#t`): allowed unless the state is SINGLE, and the same tag may
  not be given twice (repeat rejected). A **key-level** refusal (the `canUse`/`canParseAny` test in `EntitySelectorOptions.get`) gives `argument.entity.options.inapplicable` with the cursor
  reset to the start of the key (§7.4). A **value-level** refusal (`canParseElement` failing for `name`, `gamemode`, `team` or `type`, for example a positive
  `type=b` after `type=!a`, or a repeated or disallowed type tag) gives the same error with the cursor reset to the **start of the value**: after the `=`
  and any whitespace, before a `!`.
- `SetOnceOptionState` (used by `limit`, `sort`, `scores`, `advancements`) allows the option once.
- `tag`, `nbt` and `predicate` are always applicable and have no repetition limit.
- `x y z dx dy dz distance level x_rotation y_rotation`: each is applicable only while its own value has not been set.
- `limit` and `sort` are additionally not applicable on `@s` (the current-entity selector).

| Key | Value grammar | Effect |
|---|---|---|
| `x`, `y`, `z` | `readDouble` of the Brigadier reader (no `~`) | sets the origin component; marks the selector "world limited" |
| `dx`, `dy`, `dz` | `readDouble` | sets the box extent component; marks "world limited" |
| `distance` | a double range (§6.9, `MinMaxBounds$Doubles`); if min or max is below 0: `argument.entity.options.distance.negative`, cursor reset to the start of the value | distance bounds |
| `level` | an int range; a negative min or max gives `argument.entity.options.level.negative`, cursor reset to the value start | experience level bounds; calls `setIncludesEntities(false)` (the selector then matches players only) |
| `x_rotation`, `y_rotation` | a degree range (`MinMaxBounds$FloatDegrees`) | rotation test, below |
| `limit` | `readInt`; below 1: `argument.entity.options.limit.toosmall`, cursor reset to the value start | sets the maximum result count |
| `sort` | an unquoted run; one of `nearest`, `furthest`, `random`, `arbitrary`, otherwise `argument.entity.options.sort.irreversible` with the text (cursor reset to the value start) | sets the ordering |
| `gamemode` | optional `!` (inversion), an unquoted run looked up by game-mode name, else `argument.entity.options.mode.invalid` | player's game mode test (inverted by `!`); calls `setIncludesEntities(false)` |
| `team` | optional `!`, an unquoted run (possibly empty) | equals the entity's team name; the empty string is compared against `""` for entities without a team |
| `type` | optional `!`; `#` for a tag; an Identifier | entity type equality, or tag membership; unknown type: `argument.entity.options.type.invalid` with the identifier text; a positive non-tag type calls `limitToType` (it **overwrites** any earlier limitation); positive `type=player` on **any** selector calls `setIncludesEntities(false)` |
| `tag` | optional `!`, an unquoted run (possibly empty) | empty value matches entities whose tag set is empty; otherwise membership in the tag set, inverted by `!` |
| `name` | optional `!`, `readString` (quotes allowed) | equality with the entity's plain-text name |
| `nbt` | optional `!`, an SNBT compound (`TagParser.parseCompoundAsArgument`) | the entity is saved to NBT without its id; for a player holding a non-empty selected item, the item is stored under `SelectedItem`; the compound must match as a subset (`NbtUtils.compareNbt` with partial matching enabled) |
| `scores` | `{` objective `=` int range `,` ... `}` (whitespace allowed around tokens; objective names are unquoted runs) | for every listed objective the entity's score (via the scoreboard of the server) must exist and lie in the range; whether it also restricts to players was not traced (Open question 7) |
| `advancements` | `{` Identifier `=` (`true`/`false` or `{` criterion `=` boolean `,` ... `}`) `,` ... `}` | for a **ServerPlayer** the player's progress must match; non-players fail; calls `setIncludesEntities(false)` |
| `predicate` | optional `!`, an Identifier | loads the predicate from the server's reloadable registries by key `Registries.PREDICATE`; the test builds a loot context with the entity as `THIS_ENTITY` and its position as `ORIGIN` for the `SELECTOR` parameter set, evaluates the condition, and XORs with the inversion; a missing predicate counts as failing |

**Rotation test.** The bounds are `min` (default **0** when absent) and `max` (default **359** when absent); both are passed through `Mth.wrapDegrees` (result in
[-180, 180)). The entity's rotation is wrapped the same way; if the wrapped min is greater than the wrapped max the interval
wraps around and the test is `value >= min || value <= max`, else `min <= value <= max`.

**Predicate rule.** All collected predicates must hold (logical AND). `@e` and `@n` additionally require the entity to be
alive (`Entity::isAlive`, read).

### 7.6 Candidate set, box and ordering (read: `EntitySelectorParser.createAabb`, `getSelector`, `EntitySelector`)

1. **Box.** If any of `dx dy dz` was given, an axis-aligned box is built relative to the origin: for each axis with extent `d`
   (an absent extent counts as 0 once any extent is present) the interval is `[d, 1]` when `d < 0`, else `[0, d + 1]`; the box is
   that interval added to the origin component. With no `dx dy dz` but a **distance maximum**, a prefilter box is used whose minimum
   corner is `-max` and whose maximum corner is `max + 1` on each axis around the origin (the exact distance test still applies).
   An entity passes the box test when its bounding box **intersects** the box.
2. **Origin.** `x y z` where given, else the corresponding component of the source position.
3. **Search.** A selector that is not world-limited (no `x y z dx dy dz distance`) scans all levels (read: the "world limited"
   flag set by those options controls this; the exact scan rules are Open question 7). The `arbitrary` order stops the scan as soon as the
   limit is reached; other orders collect all matches first.
4. **Ordering and limit.** `nearest` ascending distance, `furthest` descending, `random` shuffled, `arbitrary` as scanned
   (the orderings are the four constants `ORDER_NEAREST`, `ORDER_FURTHEST`, `ORDER_RANDOM`, `ORDER_ARBITRARY`, read). Defaults by
   selector type are in §7.3. After ordering the list is cut to the maximum result count.
   **Entity tests (read):** the distance test compares `distanceToSqr(origin)` of the entity with the **squared** distance bounds; when a type
   limitation exists, an `EntityType.isEnabled(featureFlags)` filter is added so that entity types disabled by the level's feature flags
   never match.
5. **`@s`.** The executing entity is tested against the predicates and returned if all pass.
6. **Permission at execution.** `EntitySelector.checkPermissions` re-tests `commands/entity_selectors` for selectors that use `@`
   (§2.3).

### 7.7 Type limitation and the players-only flags

- `@p`, `@a` and `@r` call `limitToType(PLAYER)` while the type character is parsed. This sets a plain **type field** that
  is not part of the option-state check, so a later `type=zombie` on `@p` is **not** reported as inapplicable: `type=...` is
  applied with `limitToType` as well and overwrites the earlier type (the error `inapplicable` for `type` only comes from
  `InvertableSetOptionState`, e.g. a second positive `type`).
- Options that call `setIncludesEntities(false)` (`level`, `gamemode`, `advancements`, a positive `type=player` on any selector) make
  the selector match players only; the parser's `includesEntities` field is what the players-only argument check of §7.2 point 4 reads.

### 7.8 game_profile (id 7)

Read (`GameProfileArgument.parse(reader, allowSelectors)`, with `allowSelectors` the permission test of §2.3): if the next character is
`@` a selector is parsed; if the selector `includesEntities()` the error is `ERROR_ONLY_PLAYERS_ALLOWED` (the key
`argument.player.entities` is the one with that meaning; the exact binding of the exception to the key was not decoded) created at the
reader position after the selector; otherwise the argument is that selector's player list. Without `@` the text up to the next space is
a player name resolved by the command at execution through `services().nameToIdCache()` (read); the key
`argument.player.unknown` ("That player does not exist") is the unknown-player message (key read; its binding to this lookup was not traced).

### 7.9 score_holder (id 31)

Props byte 0x01 = multiple allowed. Read (`ScoreHolderArgument.parse(reader, multiple)`):
- If the next character is `@`, a selector is parsed (with selectors allowed); if the selector can return more than one result and
  `multiple` is false the error is `ERROR_NOT_SINGLE_ENTITY` (`argument.entity.toomany`). The value is that selector.
- Otherwise the text up to the next space is read and classified:

| Text | Meaning (read) |
|---|---|
| exactly `*` | all score holders tracked by the scoreboard (a name provider evaluated at execution) |
| starts with `#` | a name-only holder (`ScoreHolder.forNameOnly`) with the whole text, `#` included, as the name: the usual fake-player form |
| a text accepted by `UUID.fromString` | the holder is resolved at execution by looking the UUID up in every level (`getEntity`); if an entity is found it is the holder, otherwise the text is used as a name-only holder (the fallback is read as a list `List.of(name holder)`) |
| anything else | a name-only holder with that text |

An empty result at execution fails with `ERROR_NO_RESULTS` (`argument.scoreHolder.empty`, created without input context). Whether
`*` is rejected when `multiple` is false was not decoded (Open question 6).

---

## 8. Coordinates

### 8.1 Components (read)

Each coordinate component is one of three forms:

| Form | Syntax | Meaning |
|---|---|---|
| absolute | a number | that value |
| relative | `~` or `~N` | the executor's component plus N (N defaults to 0) |
| local | `^` or `^N` | offset along the executor's local axes (§8.3) |

World forms and local forms cannot be mixed in one argument: if the first component starts with `^` all three must,
otherwise none may. A mismatch gives `argument.pos.mixed`.

### 8.2 World coordinates (read)

For one component (`WorldCoordinate.parseDouble(reader, centerCorrect)`; block positions use `parseInt`):

1. End of input here: `argument.pos.missing.double` ("Expected a coordinate"); for block positions
   `argument.pos.missing.int`.
2. If the next character is `^`: `argument.pos.mixed`, created with the cursor at the `^`.
3. If `~`, consume it and mark the component relative.
4. If more input remains and the next character is not a space: a double is read with the Brigadier `readDouble`; for the
   block-position form an **absolute** component is read with `readInt` and a **relative** one with `readDouble`. Otherwise
   the number is 0.
5. A component that is just `~` is relative with offset 0.
6. **Centre correction:** the double form of an **absolute** component whose text has no `.` and for which `centerCorrect` is true gets
   `+ 0.5` (`0.5d` and the string `.` are read in the code). `Vec3Argument` passes `centerCorrect = true` for the **x and z**
   components and `false` for y (read: `WorldCoordinates.parseDouble` passes the flag for the first and third component and
   `false` for the second). So `5` means 5.5 for x and z and 5.0 for y, while `5.0` stays 5.0.

Components are separated by exactly one space: after each non-final component, if the input has ended **or** the next character is not a space,
the cursor is reset to the start of the argument and the error is `argument.pos3d.incomplete` ("Incomplete (expected 3 coordinates)")
for vec3 and block_pos, `argument.pos2d.incomplete` for vec2 and column_pos (the shared `ERROR_NOT_COMPLETE` of
`Vec3Argument`/`Vec2Argument`; the 2-component error key was read in the class constants).

A relative component is the source's component plus the offset; a block position is the floor of the resulting components.
Block-position accessors (read):

| Accessor | Check (in this order) | Error (created without input context) |
|---|---|---|
| `getLoadedBlockPos` | `ServerLevel.hasChunkAt(pos)` | `argument.pos.unloaded` |
| (same) | `ServerLevel.isInWorldBounds(pos)` | `argument.pos.outofworld` |
| `getSpawnablePos` | `Level.isInSpawnableBounds(pos)` | `argument.pos.outofbounds` |

Limits (read): `isInWorldBounds` requires `-30000000 <= x < 30000000` and `-30000000 <= z < 30000000` (upper bound exclusive) and
`minY <= y <= maxY` of the level; the spawnable check uses `isOutsideSpawnableHeight` plus the same horizontal rule.

### 8.3 Local coordinates (read)

Syntax `^L ^U ^F` = left, up, forward (each optional number, default 0; all three must start with `^`; a component not
starting with `^` gives `argument.pos.mixed` with the cursor at that component). The offset is applied relative to the
**source's anchored position** (the executor position, with `anchored eyes` adding the eye height) and rotation
(pitch p = `Vec2.x`, yaw w = `Vec2.y`, in degrees):

- forward vector F = (cos(w+90°)·cos(−p), sin(−p), sin(w+90°)·cos(−p))
- up vector U = (cos(w+90°)·cos(−p+90°), sin(−p+90°), sin(w+90°)·cos(−p+90°))
- left vector L = −(F × U) (the cross product, scaled by −1)
- result = anchor + F·forward + U·up + L·left (component wise, in that order of terms)

All angles are converted with the factor 0.017453292 (float), the trigonometric functions are the game's `Mth.sin`
and `Mth.cos`, calls that take a double and return a **float** (`Mth.sin(D)F`); that they are table-based and that exact trigonometry differs by less than 1e-4
is **(recalled, not verified)**. Local coordinates
yield no block rounding beyond the usual floor for block positions.

### 8.4 Types

| Id | Type | Components | Result |
|---|---|---|---|
| 10 | vec3 | 3, world (with centre correction) or local | Vec3 |
| 11 | vec2 | 2 (x and z), world only; no centre correction | Vec2 |
| 8 | block_pos | 3, integers (absolute) or relative / local | BlockPos |
| 9 | column_pos | 2, integers | x z column |
| 29 | rotation | 2: yaw then pitch, each absolute or relative (`~`); local not allowed | Vec2 (x = pitch, y = yaw): the text order is **yaw pitch**; the value is stored as (pitch, yaw) |

For rotation the incomplete error is `argument.rotation.incomplete`.

### 8.5 angle (id 28)

Grammar (read): end of input gives `argument.angle.incomplete`; optional `~` (relative), then, if the next char is not a
space, a float; NaN or infinite gives `argument.angle.invalid`. Value: a single angle, relative or absolute, in degrees.
Examples from the class: `0`, `~`, `~-5`.

### 8.6 swizzle (id 32)

Grammar (read): any combination of the letters `x`, `y`, `z`, each at most once, no other characters, e.g. `xyz`, `x`;
a duplicate letter or other character gives `arguments.swizzle.invalid`. The value is the set of axes (used by `align`).

---

## 9. Blocks, items, text and NBT

### 9.1 block_state (12) and block_predicate (13) (read: `BlockStateParser`)

The same parser serves both types, with two switches: whether tags are allowed (block_predicate) and whether the trailing
NBT is allowed.

```
parse := [ '#' tag_id [ '[' vague_properties ']' ]      -- only if tags are allowed, else argument.block.tag.disallowed
         | block_id [ '[' properties ']' ] ]
         [ snbt_compound ]                              -- only if NBT is allowed, only if next char is '{'
```
- `block_id` and `tag_id` are read with the identifier reader (§6.7). An unknown block gives `argument.block.id.invalid` and
  an unknown tag `arguments.block.tag.unknown`, both with the cursor reset to the start of the identifier. When the input
  starts with `#` and tags are not allowed, `argument.block.tag.disallowed` is created at the cursor.
- Inside `[` `]` whitespace is skipped before and after names, `=` and `,`. A property **name** is read with `readString`
  (quotes allowed), the value with `readString` too.
- For a **block**: an unknown property name resets the cursor to the start of the name and gives
  `argument.block.property.unknown` (arguments: block id, name); a name already used gives `argument.block.property.duplicate`
  (cursor reset to the name start); a name not followed by `=` gives `argument.block.property.novalue` (arguments: name,
  block id); a value not valid for the property gives `argument.block.property.invalid` (arguments: block id, value, property
  name) (value applied by `setValue`); after a value the next character must be `,` (continue) or `]` (end), otherwise
  `argument.block.property.unclosed`; end of input before `]` is also `argument.block.property.unclosed`. An empty `[]` is accepted.
- For a **tag** (`readVagueProperties`): the same shape, but names and values are stored as strings (duplicates are refused with
  the same duplicate error, a missing `=` gives `argument.block.property.novalue`) and are matched against states at test time.
- The trailing `{...}` is parsed with the SNBT compound parser of §9.4 and is the block-entity data (partial match for a
  predicate; stored data for a state).
- Examples read from the argument classes: `stone`, `minecraft:stone`, `stone[foo=bar]`, `#stone`, `#stone[foo=bar]{baz=nbt}`.
  (`foo{bar=baz}` and `{baz=nbt}` are class example strings only: SNBT uses `:`, §9.4.)

### 9.2 item_stack (14) and item_predicate (15)

**item_stack** (read: `ItemParser`, `ItemParser$State`):
```
item_stack := item_id [ '[' [ component { ',' component } ] ']' ]
component  := '!' component_type                    -- removes a default component
            | component_type '=' snbt_value
```
- `item_id` is read with the identifier reader and looked up in the item registry: unknown gives `argument.item.id.invalid`
  (cursor reset to the start of the identifier).
- Inside the brackets whitespace is skipped around every token. `component_type` is an identifier of a data component type
  (unknown: `arguments.item.component.unknown`). The same type may appear only once (including `!` forms): a repeat gives
  `arguments.item.component.repeated` (no input context). After `=` the value is an SNBT value (§9.4) which is then decoded with
  the component type's codec; a decode failure gives `arguments.item.component.malformed` (arguments: component type, error text).
  After a `,` the input may not end: `arguments.item.component.expected`. The closing `]` is required (`expect`).
- Transient data-component types (those that cannot be serialised) are treated as unknown: `arguments.item.component.unknown`, cursor reset to the
  start of the identifier.
- There is no `{nbt}` suffix in this version's item grammar (the characters handled are only `[ ] , = !`).
- `ItemInput` checks stack size when a command builds a stack from a count: `arguments.item.overstacked` ("%s can only stack up to %s") (key read).

**item_predicate** (read: the packrat grammar of `ComponentPredicateParser`; characters `[ ] # * , | ! = ~`; `id` is the `IdentifierParseRule`, values
are the SNBT `TagParseRule`):
```
top          := type '[' cut conditions? ']'  |  type
type         := id  |  '#' cut tag  |  '*'          -- element, tag or any
conditions   := alternatives ( ',' conditions )?
alternatives := term ( '|' alternatives )?
term         := test  |  '!' negation               -- negation is a wrapper rule around test; no cut after '!'
test         := component_type '=' cut value        -- the component value must match (SNBT value)
              | predicate_type '~' cut value        -- a named predicate test
              | component_type                      -- the component is present
```
`cut` means that once the introducing character matched, a later failure is reported instead of trying other alternatives. Errors:
`arguments.item.predicate.unknown`, `arguments.item.predicate.malformed` (predicate name, error), `arguments.item.component.unknown` and
`.malformed`, `arguments.item.tag.unknown`, `argument.item.id.invalid`. Examples read: `stick`, `minecraft:stick`, `#stick`, `#stick{foo:'bar'}`
(class example string), and the predicate type `count`.

### 9.3 component (18), style (19)

Read: `ComponentArgument` and `StyleArgument` extend `ParserBasedArgument`: the argument text is parsed by the packrat **SNBT value
grammar** (§9.4) and the resulting value is decoded with the text-component codec (`ComponentSerialization.CODEC`) or the style
codec; a decode failure gives `argument.component.invalid` or `argument.style.invalid` with the codec's error text. Examples read
from the classes: components `"hello world"`, `'hello world'`, `""`, `{text:"hello world"}`, `[""]`; styles `{}`, `{bold: true}`,
`{color: 'red'}`. A resolved component (`getResolvedComponent`) is run through `ComponentUtils.resolve` with the source as context, so
selectors, scores and NBT inside it are evaluated at execution. The argument ends where the SNBT value ends.

### 9.4 nbt_compound_tag (21), nbt_tag (22) and SNBT (read: `SnbtGrammar`, `TagParser`)

`nbt_compound_tag` is `TagParser.parseCompoundAsArgument`: the SNBT value grammar followed by a check that the value is a compound
(`argument.nbt.expected.compound` otherwise). `nbt_tag` accepts any SNBT value. Both use the packrat `Grammar.parseForCommands`.

SNBT value grammar (rule names and characters read from `SnbtGrammar`; the key/value separator of a compound is `:` only,
byte 58, and **no** grammar character is `=`):

| Kind | Syntax (read) |
|---|---|
| compound | `{` entries `}`, entry = key `:` value, separated by `,` (map entries rule names `map_literal`, `map_entries`, `map_entry`, `map_key`); an empty key gives `snbt.parser.empty_key`; a key is a quoted or an unquoted string |
| list | `[` values `,` ... `]` (`list_literal`, `list_entries`) |
| arrays | `[` prefix `;` entries `]` where the prefix letter is `B`, `I` or `L` (`ArrayPrefix` BYTE, INT, LONG; each allows its default type plus some additional suffix types); an element of a type the prefix does not allow gives `snbt.parser.invalid_array_element_type` |
| strings | quoted with `"` or `'`; escapes `\\`, `\"`, `\'`, `\b`, `\f`, `\n`, `\r`, `\s` (maps to a space), `\t`, `\xHH` (2 hex digits), `\uHHHH` (4), `\UHHHHHHHH` (8) and `\N{name}` (Unicode character name); an unquoted string may not start with `0-9`, `+` or `-` (`snbt.parser.invalid_unquoted_start`); its permitted character set was not traced (the pattern `[-a-zA-Z0-9 ]+` in the class belongs to the `\\N{name}` character-name rule) |
| integers | optional sign (`+` or `-`), a numeral in base decimal, hex (`0x` / `0X`) or binary (`0b` / `0B`); `_` separators allowed but not at the start or end (`snbt.parser.undescore_not_allowed`); a decimal numeral may not have a leading zero (`snbt.parser.leading_zero_not_allowed`); optional suffix = an optional signedness letter (`s` / `S` signed or `u` / `U` unsigned) followed by a type letter `b`/`B` byte, `s`/`S` short, `i`/`I` int, `l`/`L` long; with no suffix the type is int |
| floating point | decimal digits with `.` fraction and/or `e`/`E` exponent; type suffix `f`/`F` float or `d`/`D` double; no suffix is double; non-finite values give `snbt.parser.infinity_not_allowed` |
| booleans | `true`, `false` |
| builtin operations | `bool(...)` and `uuid(...)` (`SnbtOperations` registers exactly `bool` and `uuid`); `uuid` takes a string and yields an int array; an unknown operation name gives `snbt.parser.no_such_operation` |

How each numeric kind maps to NBT tag types and how typed lists are checked (`argument.nbt.list.mixed`, `argument.nbt.array.mixed`,
`argument.nbt.array.invalid`) was not traced (Open question 5). Binary NBT is in 07.

The class `getExamples` strings of the NBT arguments (`{foo=bar}`, `{}`, `0`, `0b`, `0l`, `0.0`, `"foo"`, `[0]`) are
examples only: `{foo=bar}` is **not** accepted by the grammar above. The SNBT error keys and English texts are the `snbt.parser.*`
rows below.

| Key | English text |
|---|---|
| `snbt.parser.empty_key` | Key cannot be empty |
| `snbt.parser.expected_binary_numeral` | Expected a binary number |
| `snbt.parser.expected_decimal_numeral` | Expected a decimal number |
| `snbt.parser.expected_float_type` | Expected a floating point number |
| `snbt.parser.expected_hex_escape` | Expected a character literal of length %s |
| `snbt.parser.expected_hex_numeral` | Expected a hexadecimal number |
| `snbt.parser.expected_integer_type` | Expected an integer number |
| `snbt.parser.expected_non_negative_number` | Expected a non-negative number |
| `snbt.parser.expected_number_or_boolean` | Expected a number or a boolean |
| `snbt.parser.expected_string_uuid` | Expected a string representing a valid UUID |
| `snbt.parser.expected_unquoted_string` | Expected a valid unquoted string |
| `snbt.parser.infinity_not_allowed` | Non-finite numbers are not allowed |
| `snbt.parser.invalid_array_element_type` | Invalid array element type |
| `snbt.parser.invalid_character_name` | Invalid Unicode character name |
| `snbt.parser.invalid_codepoint` | Invalid Unicode character value: %s |
| `snbt.parser.invalid_string_contents` | Invalid string contents |
| `snbt.parser.invalid_unquoted_start` | Unquoted strings can't start with digits 0-9, + or - |
| `snbt.parser.leading_zero_not_allowed` | Decimal numbers can't start with 0 |
| `snbt.parser.no_such_operation` | No such operation: %s |
| `snbt.parser.number_parse_failure` | Failed to parse number: %s |
| `snbt.parser.undescore_not_allowed` | Underscore characters are not allowed at the start or end of a number |

### 9.5 nbt_path (23) (read: `NbtPathArgument`)

```
path := node { [ '.' ] node }                  -- loop while input remains and the next char is not a space
node := '{' snbt_compound-rest                 -- first node only: matches the root object (a '{' node elsewhere: arguments.nbtpath.node.invalid)
      | '[' ( '{' snbt_compound ']'            -- list elements that match the compound
            | ']'                              -- all list elements
            | integer ']' )                    -- one list element by index (readInt)
      | quoted_string object_rest              -- readString for a quote start
      | unquoted_name object_rest
object_rest := [ snbt_compound ]               -- a '{' right after the name filters the object child
```
Between two nodes a `.` is required unless the next character is a space, `[` or `{` (it is consumed with `expect('.')`).
An unquoted name is a run of characters other than space, `"`, `'`, `[`, `]`, `.`, `{`, `}` (read:
`isAllowedInUnquotedName`); an empty name gives `arguments.nbtpath.node.invalid`. Examples read from the class: `foo`,
`foo.bar`, `foo[0]`, `[]`, `[0]`, `{foo=bar}` (this last is a class example string, see §9.4). Execution-time keys:
`arguments.nbtpath.nothing_found`, `arguments.nbtpath.too_deep`, `arguments.nbtpath.too_large`, and the
`commands.data.modify.*` keys used by `data` (catalog). The meaning of a negative index, and the numeric limits behind
`too_deep` and `too_large`, were not read (Open question 11).

## 10. Execution

### 10.1 Context chain (read)

Read: after a successful parse the context is built (`CommandContextBuilder.build`) and flattened (`ContextChain.tryFlatten`) into a chain;
a top-level command is queued as the initial execution of a fresh `ExecutionContext` (unless one is already current in the thread, in which case
it reuses it), and the queue is then run (`runCommandQueue`). Recalled, not verified: each fork or redirect with a modifier is a stage mapping one
source to several sources, the last stage holds the command, and `execute as @a at @s run say hi` is the chain `as`, `at`, `run`, `say`. Two game
rules size the execution context (read: `Commands.executeCommandInContext` reads both from the level's game rules):

| Game rule | Name | Default | Effect |
|---|---|---|---|
| max command sequence length | `max_command_sequence_length` | 65536 (`GameRules.MAX_COMMAND_SEQUENCE_LENGTH`, integer, registered with minimum 0) | the value, raised to at least 1 (`Math.max(1, value)`), is the first constructor argument of the execution context |
| max command forks | `max_command_forks` | 65536 (`GameRules.MAX_COMMAND_FORKS`) | second constructor argument of the execution context; the limit is applied in `BuildContexts` as described in §10.2 |

Read: a command run while an execution context is already current in the thread (a function call or nested command) reuses that context
(`CURRENT_EXECUTION_CONTEXT` thread-local), so the sizes above are global to the outer command.

### 10.2 Result of a command (library behaviour, 15a §4.3, §4.4; the game's own path is different)

Library `CommandDispatcher.execute` (15a): a command's `executes` returns an int and the library gives no meaning to 0 (`Command.SINGLE_SUCCESS` is 1).
No modifier contexts: the executable runs once and its int is the result. Otherwise the sources are expanded modifier by modifier (a missing modifier is the
identity); an empty source list gives the result 0; then the executable runs once per source; the return value is the **sum** of the results when
not forked and the **number of successful runs** when forked; a syntax exception reports (context, false, 0) to the result consumer and, when forked, is
swallowed.

**These rules are the library's `execute` only.** `Commands.performCommand` never calls it: it flattens the parse with `ContextChain.tryFlatten` and runs it
through the game's `ExecutionContext` and `BuildContexts` queue, with errors going through `CommandSourceStack.handleError(forked)` (§10.4). The result and
callback combination across forks in that queue was not decoded (Open question 4). The fork limit **is** read: in `BuildContexts`, when the number of
sources already collected plus the new sources produced by a modifier reaches the fork limit (`max_command_forks`), `ERROR_FORK_LIMIT_REACHED`
(`command.forkLimit`, "Maximum number of contexts (%s) reached") is raised through `handleError(forked)`.

`execute store result` and `execute store success` take their values from the (success, result) pair given to the result consumer; the game installs
its consumer (`ExecutionCommandSource.resultConsumer`, read).

### 10.3 Command feedback (read: `CommandSourceStack`)

| Operation | Rule |
|---|---|
| `sendSuccess(message, broadcastToAdmins)` | the message supplier is evaluated only if it will be used. To the **source**: if the source accepts success (a player source accepts it only when the game rule `send_command_feedback` is true in the player's level; console, rcon and the server always accept) and the stack is not silent. To the **admins**: if `broadcastToAdmins` and the source says it informs admins (every player source, the console and rcon when `shouldRconBroadcast`) and the stack is not silent. |
| `sendFailure(message)` | if the source accepts failure (always for players, console and rcon) and not silent: the message coloured **red** (`withStyle(RED)`) is sent to the source. Failures ignore the game rule. |
| `sendSystemMessage` (to a player) | System Chat packet (05b 0x7C), overlay false |
| Admin broadcast | the message is wrapped as `chat.type.admin` ("[%s: %s]") with the argument 1 = the executing source's display name and argument 2 = the original message, **gray and italic**. It is sent to every online operator (those for whom `PlayerList.isOp` is true) **except** the source itself, only if the game rule `send_command_feedback` is true. If the source is not the server and the game rule `log_admin_commands` is true (default true) it is also logged to the server console. |
| Silent | a source stack can be made silent (used by function execution with feedback suppressed and by `execute` in some contexts); silent stacks send neither success nor failure |

Console sources print the message through the language file (plain text); `command_block_output` governs command blocks.
`send_command_feedback` default true, `log_admin_commands` default true, `command_block_output` default true.

The broadcast flag is chosen by each command (most state-changing commands pass true; queries like `data get`,
`scoreboard players get`, `list`, `help` pass false). That per-command choice belongs in the catalog.

### 10.4 Error message styling

| Origin | Presentation |
|---|---|
| parse error | two messages, §4.6 |
| `CommandSyntaxException` thrown by a command during execution | the exception's raw message component, red (`CommandSourceStack.handleError` calls `sendFailure`); no context line is built on this path; `handleError` sends **nothing** when its boolean argument (`ChainModifiers.isForked`) is true, so failures inside forked chains (including `execute if/as/at ...`) are not shown to the source (read) |
| a plain `sendFailure` | red |
| unexpected Java exception | `command.failed`, red, with the exception message as hover text; debug extras as in §4.6 |

### 10.5 Result callbacks (read)

A command source carries a result consumer (`ExecutionCommandSource.resultConsumer`) that Brigadier calls with
(context, success, result) after every command; `execute store` and `return` and command blocks install their own.
A top-level player command installs the empty callback.

### 10.6 Triggered objectives

The `trigger` command is level 0; its argument is an objective name and the check that the objective is a
`trigger` criterion and enabled for the player is done at execution by the command (catalog).

---

## 11. The `execute` command grammar (clause names, argument types and most clause lambdas read from `ExecuteCommand`)

Root `execute` (level 2) has one set of children that every clause can loop back to; each clause redirects to the
`execute` root so that clauses chain in any order. Notation: `<name:type>` is an argument node with its parser; `|`
alternatives; `[..]` optional; every clause ends by returning to the start (so any further clause or `run` may follow),
and a node marked ⏎ is executable (can end the command).

```
execute
  run <command...>                     redirect to the command root (executes a normal command with the current source)
  if|unless <condition>                (conditions below; as the last clause it is executable and gives pass/fail feedback)
  as <targets:entities>                fork: one source per target entity (same position/rotation/level; entity := target)
  at <targets:entities>                fork: one source per target; keeps the entity, takes position, rotation and level from the target
  store result|success <store target>  see below; redirects to the execute root
  positioned <pos:vec3>                position := vec3 (relative to the old position)
  positioned as <targets:entities>     fork: position := each target's position
  positioned over <heightmap>          position.y := the level's height of that heightmap at floor(x), floor(z) (error if the column is not loaded)
  rotated <rot:rotation>               rotation := rotation (relative to the old rotation)
  rotated as <targets:entities>        fork: rotation := each target's rotation
  facing <pos:vec3>                    rotation := the rotation that looks from the source (anchored position) to pos
  facing entity <targets:entities> <anchor:entity_anchor>   fork: look at each target's feet or eyes
  align <axes:swizzle>                 position := position with the listed axes floored
  anchored <anchor:entity_anchor>      anchor := feet or eyes (affects ^ coordinates and facing)
  in <dimension:dimension>             level := that dimension (position unchanged)
  summon <entity:resource(entity_type)>  spawn an entity of the type at the current position and fork to it as the new source (executor)
  on <relation>                        fork over related entities of the current entity (below)
```

Read from the clause lambdas of `ExecuteCommand.register`: `positioned <pos>` calls `withPosition`; `positioned over` checks that the
chunk of the current x/z is loaded (otherwise it throws a context-free `SimpleCommandExceptionType`) and sets y to
`ServerLevel.getHeight(heightmap, floor(x), floor(z))`; `rotated <rot>` calls `withRotation` with the coordinates' rotation; `facing <pos>`
calls `CommandSourceStack.facing(Vec3)`; `align` calls `Vec3.align(axes)` then `withPosition`; `anchored` calls `withAnchor`; `in` calls
`withLevel`; `summon` calls `spawnEntityAndRedirect` for a summonable entity type. Also read: `as` calls `withEntity` only; `at` calls `withLevel`, `withPosition` and `withRotation` taking the values from the entity; `positioned as` calls
`withPosition`; `rotated as` calls `withRotation` from `getRotationVector`; `if` and `unless` are **forks** whose modifier returns the singleton source when the
predicate result equals the clause (`if`: true, `unless`: false) and an empty list otherwise. Not traced (Open question 4): `facing entity`, `summon`, and the
internals of the `data`, `items` and `blocks` conditions.

### 11.1 Conditions (`if` and `unless`)

| Condition | Arguments | True when |
|---|---|---|
| `block <pos:block_pos> <block:block_predicate>` | | the block at pos matches |
| `biome <pos:block_pos> <biome:resource_or_tag(biome)>` | | the biome at pos matches |
| `loaded <pos:block_pos>` | | the chunk at pos is loaded |
| `dimension <dimension:dimension>` | | the source's level is that dimension |
| `score <target:score_holder> <targetObjective:objective> (= \| < \| <= \| > \| >=) <source:score_holder> <sourceObjective:objective>` | | the comparison of the two scores holds; both holders must have a score, else false |
| `score <target> <targetObjective> matches <range:int_range>` | | the target's score is in the range |
| `blocks <start:block_pos> <end:block_pos> <destination:block_pos> (all \| masked)` | | the two regions of equal size match block-for-block (`masked` ignores air in the source region); the region size is limited by `max_block_modifications` (default 32768) else `commands.execute.blocks.toobig`; counts as the number of compared blocks |
| `entity <entities:entities>` | | at least one entity is selected (counted) |
| `predicate <predicate:loot_predicate>` | | the loot predicate passes with the source entity and position |
| `function <name:function>` | | the function(s) return a result: success if the return value is non-zero (gated by return rules) |
| `stopwatch <id:resource_location> <range:float_range>` | | the elapsed time of the stopwatch is in the range |
| `data (block <pos> \| entity <target> \| storage <source>) <path:nbt_path>` | | the path matches something in the data (counted as the number of matches) |
| `items (block <pos> \| entity <targets>) <slots:item_slots> <predicate:item_predicate>` | | at least one slot matches (counted) |

Behaviour of the last clause: `if` or `unless` without `run` ends the command. Executed as the final clause, it
reports: success with `commands.execute.conditional.pass` ("Test passed") or `commands.execute.conditional.pass_count`
("Test passed. Count: %s") when counted, failure with `commands.execute.conditional.fail` or
`commands.execute.conditional.fail_count`. The command result is 1 (or the count) on pass and 0 on failure. When
followed by another clause, a failed condition (after `unless` inversion) **drops the source** (the chain stops for
that source: the modifier returns an empty list, read); a passed one continues with the same source. The counting forms (`blocks`, `entity`, `items`, `data`) return the count
as the result.

### 11.2 `store`

`store result|success` then one target, then back to the execute root:

| Target | Syntax | Effect |
|---|---|---|
| score | `score <targets:score_holder(multiple)> <objective:objective>` | set the objective score of each holder to the stored value |
| boss bar | `bossbar <id:resource_location> (value \| max)` | set the boss bar value or maximum |
| data | `(block <pos> \| entity <target> \| storage <target>) <path:nbt_path> (int \| float \| short \| long \| double \| byte) <scale:double>` (node names `path`, `scale` and the six type literals read) | write `value * scale` converted to the NBT type at the path (recalled, not verified) |

(recalled, not verified) The stored value is the **result** for `store result` and 1 or 0 for `store success`; `store` takes effect when the final
command completes, even if it fails (stores 0); `commands.data.entity.invalid` is the key used for a player target (key read, use recalled).

### 11.3 `on` relations (read from the relation lambdas of `ExecuteCommand.createRelationOperations`)

`on` takes one of the literals below and forks to the related entity or entities of the current executor; a source without an entity yields no
sources. Related entities pass a filter `!entity.isRemoved()`; the source becomes that entity (entity replaced) while position, rotation and level
stay the old ones.

| Literal | Relation (method used) | One-to-many |
|---|---|---|
| `owner` | `OwnableEntity.getOwner` | no |
| `leasher` | `Leashable.getLeashHolder` | no |
| `target` | `Targeting.getTarget` | no |
| `attacker` | `Attackable.getLastAttacker` | no |
| `vehicle` | `getVehicle` | no |
| `controller` | `getControllingPassenger` | no |
| `origin` | `TraceableEntity.getOwner` | no |
| `passengers` | `getPassengers()` | yes |

---

## 12. Functions (brief)

Read from `CommandFunction.fromLines`, `FunctionBuilder`, `StringTemplate`, `MacroFunction` (the `.mcfunction` file location and the tag
mechanics were not traced; Open question 9):

**Line parsing.** The function is a list of text lines. For each line:
1. The line is trimmed of whitespace on **both** sides.
2. **Continuation:** if the trimmed line ends with a backslash (`\`), the backslash is removed and the next line, also trimmed, is
   appended; this repeats while the result still ends with a backslash. A continuation on the last line fails with
   `Line continuation at end of file`. The joined line length is checked after every append and for every line: more than
   2,000,000 characters fails with an `IllegalStateException` that quotes the first 512 characters and the length.
3. The (joined) line is read: a line that is empty or whose first character is `#` is a comment (ignored). Otherwise, a line whose first
   character is `/` is **never accepted** in a function file: after the first `/`, a second `/` gives "Unknown or invalid command '...' on
   line N (if you intended to make a comment, use '#' not '//')", and otherwise the error text is "Unknown or invalid command '...' on line N
   (did you mean '...'? Do not use a preceding forwards slash.)" (N is the 1-based line number). A line whose first character is `$` is a
   **macro line**; any other line is parsed as a command with the function's command dispatcher and an execution source
   (a syntax error is re-thrown as `Line <n>: <message>` text).

**Macro lines.** `$` is removed; the rest is split into literal text and variables: `$(name)` where `name` consists of letters,
digits (`Character.isLetterOrDigit`) and `_` only (`isValidVariableName`); an invalid name, or a `$(` with no closing `)`
(`Unterminated macro variable`), is an error; a macro line with **no** variable is an error `No variables in macro`.

**Calling a macro function.** The caller must pass an argument compound; none gives `commands.function.error.missing_arguments`
(argument: function id). Each distinct variable is looked up in the compound; absent gives `commands.function.error.missing_argument`
(arguments: function id, variable name); the compound value is turned into text (`stringify`). The substituted lines are parsed as
commands (a failure uses `commands.function.error.parse` with macro line, command text and error). The instantiated function for a
given list of values is cached in a small LRU of 8 entries (a map with size limit 8 whose oldest entry is removed).

The other keys of §5.4 (`commands.function.*`) are used by the `function` command; result and permission handling of called functions
(including the `function-permission-level` of §2.2) belong to the catalog. Running functions share the caller's execution context and so the
limits of §10.1 (recalled, not verified).

## 13. Chat commands on the wire

### 13.1 Server handling of 0x07 and 0x08 (read, except where marked)

1. `tryHandleChat(text, isCommand = true, task)` (called by `handleChatCommand`; the signed handler calls it the same way, not
   re-read): a text containing a character that is not allowed in chat disconnects the player with
   `multiplayer.disconnect.illegal_characters` (a character is rejected if it is U+00A7, below U+0020, or U+007F;
   `StringUtil.isAllowedChatCharacter`).
2. The "chat visibility HIDDEN" check (`chat.disabled.options`, red, System Chat, not overlay) applies only when the call is **not** a command
   (`isCommand` false): commands are not blocked by it.
3. The player's last-action (idle) timer is reset and the task is queued on the server thread (`MinecraftServer.execute`).
4. The task parses the text with the **player's own source** (`createCommandSourceStack`) and runs it through
   `Commands.performCommand` (parse errors and execution as in §4 and §10).
5. **Unsigned** (0x07, `performUnsignedChatCommand`): if the server enforces secure profiles (property `enforce-secure-profile`,
   default true) **and** the parse contains signable arguments, the server logs an error and sends one System Chat with
   `chat.disabled.invalid_command_signature` and does **not** run the command. Otherwise it runs.
6. **Signed** (0x08, `performSignedChatCommand`): the parse is made, the signable arguments are extracted
   (`SignableCommand.of`), and each signature entry of the packet is matched **by argument name** against the parsed signable arguments
   (`collectSignedArguments`): a signature for a name that is not a signable argument of the parsed command, or a signable argument
   with no signature, breaks the message chain and fails with the mismatch exception (`createSignedArgumentMismatchException`), handled by
   `handleMessageDecodeFailure`. Each entry is verified through the chain decoder (`unpack` with the signature and a message body built from
   the argument text, the packet timestamp and salt, and the last-seen list; 05c). A `CommandSigningContext$SignedArguments` holding the
   verified arguments is attached to the source and the command runs. Failure of the last-seen validation disconnects with
   `multiplayer.disconnect.chat_validation_failed`. (The exact disconnect text of a mismatch or of an invalid signature was not traced.)
7. Rate limiting (read): both command handlers call `detectCommandRateSpam` **after** executing the command, using a separate
   `commandSpamThrottler` (a `TickThrottler(20, 20 x command-spam-threshold-seconds)`, the value from
   `MinecraftServer.getCommandSpamThresholdSeconds`); an excess disconnects with `disconnect.spam` unless the player is an operator or the
   single-player owner. The signed handler calls `unpackAndApplyLastSeen` before `tryHandleChat`. The semantics of the throttler beyond its construction
   were not decoded (Open question 9).

The argument type implementing `SignedArgument` in the bundled arguments is `MessageArgument` (read: `implements SignedArgument<...>`);
other signable argument classes were not searched exhaustively (a class-by-class search of `net/minecraft/commands/arguments` for the
interface found only that one). A command with no `message` argument is always sent as 0x07 by the vanilla client (§13.2).
CobolCraft's profile (09) sends only 0x07 and accepts unsigned play when `enforce-secure-profile` is false (the join flag of 09).

### 13.2 What the client sends (read)

`sendCommand(text)`: parse locally with the client dispatcher and normal provider; if the parse has **no** signable
arguments send 0x07; otherwise sign each signable argument separately (05c) and send 0x08 with the argument
signatures (name max 16, signature 256 bytes), timestamp (now), salt and the last-seen update. The text sent has no
leading `/`.

---

## 14. Suggestions (tab completion)

### 14.1 Request and response flow

1. The player edits the chat line; the client (§3.6) parses the line locally and calls its dispatcher's completion at the
   cursor. If the node at the cursor has an `ask_server` provider, or the line is not parseable locally, the client sends
   Command Suggestion Request (05c 0x0F): a transaction id and the **whole line as typed including the leading `/`**.
2. Server queueing (read, `ServerCommandSuggestionsProvider`): `request(text)` stores the request in a single-slot atomic reference
   (`lastRequest`) and returns a future; a request stored while another is still pending replaces it. `tick()` runs every tick: the
   per-tick budget flag is set when `tickCount % MIN_INTERVAL_TICKS == 0` (`MIN_INTERVAL_TICKS` = 1, so every tick) and
   `tryProcessRequest` takes at most one stored request per budget. `request()` schedules processing at once on the server thread when no request was pending and
   the budget flag is set. After parsing, if a newer request has been queued the older one is dropped without a reply; a replaced request's future is
   never completed or cancelled (read).
3. Processing (read): the text is wrapped in a `StringReader`; if its first character is `/`, one character is skipped (the reader
   keeps counting from the start of the whole string, so ranges include the slash); it is parsed with the player's source and the
   dispatcher's completion is requested for the parse. The result passes through `limitSuggestionCount`, which cuts a list longer
   than **1000** entries to the first 1000 (same range) before it is sent as Command Suggestions (05a 0x0F) with the request's
   transaction id, the range start and length, and each entry's text and optional tooltip.
4. The client shows the list with the matching range replaced when the player chooses an entry.

### 14.2 How the dispatcher computes suggestions (library: 15a §6; game call path read here)

Library behaviour (15a §6.1 to §6.4), in brief: the suggestion context is found from the parse and the cursor (15a §6.3: the last node at or
before the cursor, or the previous node when the cursor is inside a word); **every child** of that parent node is asked to list suggestions,
**without testing its requirement**; a child that throws a syntax exception yields nothing; the results are merged over the union of their ranges
and duplicates (equal range, text and tooltip) are removed; the list is sorted by **case-insensitive text only** (integer suggestions
among themselves numerically); entries equal ignoring case have no specified order (15a open question 2), so there is **no** tie-break by the
original text. A literal suggests its name when its lower-cased name starts with the lower-cased typed text; `suggest(text)` ignores a
suggestion **equal** to the typed text (case-sensitive), `suggest(integer)` does not.

Game-side facts (read):
- `ServerCommandSuggestionsProvider.tryProcessRequest` parses with the player's source and calls the dispatcher's completion directly on that parse; it
  does not filter the children by requirement, so on this server path the children of the parent node are suggested even if the player's source
  could not use them (a consequence of 15a §6.1 step 3 and the unfiltered call; not exercised). The **client** completes against the tree it received
  (§3.3), which holds only usable nodes (`CommandSuggestions.updateCommandInfo` calls `getCompletionSuggestions` on the client dispatcher, read).
- The wire form (Command Suggestions) carries the common range start and length and each text and optional tooltip; per-suggestion ranges, integer
  kind and numeric key are not sent, so numeric order survives only as list order (15a §6.5).

Matching helper for most game text sources (read: `SharedSuggestionProvider.suggest`, `matchesSubStr`): a candidate `c` matches the typed text `t`
(both lower-cased) if `c` starts with `t` **or** if some position of `c` immediately after one of the characters `.` `_` `/` starts with `t` (so typing
`sword` matches `iron_sword`; typing `ron` does not). For resource locations (`suggestResource`): if `t` contains `:` the whole `namespace:path` string
is matched with the same rule; otherwise `t` matches when the namespace matches **or** the path matches (so `dia` matches `minecraft:diamond`
through its path).

### 14.3 Suggestions per type

Library types (read, 15a §5): only `bool` suggests anything (`true` then `false`, each only if the typed text is a prefix; `true` is not suggested when
the typed text is exactly `true`; after sorting `false` precedes `true`). The number types (integer, long, float, double) and the string types suggest
**nothing**. A node with a custom provider uses it instead of its type (15a §6.1). The `ask_server` provider and the other provider ids are in §14.4.

Game types (the `listSuggestions` of the game's own argument classes was not decoded; this table is **(recalled, not verified)** except the matching
helpers of §14.2 and the provider ids of §14.4):

| Type | Suggests |
|---|---|
| entity / game_profile / score_holder | online player names, the six selector heads `@p @a @r @s @e @n` with their `argument.entity.selector.*` tooltips (selectors only if the permission allows); within `[...]`: option names with `=` and their tooltips (read: `suggestNames`), values per option |
| block_pos / vec3 / column_pos / vec2 | `~`, `^` and the coordinates of the block the player looks at, formatted with up to two decimals for vec, integers for block positions |
| objective / team / dimension / resource types | the names of existing things |
| gamemode and other enums | the enumerated names |
| item_stack / block_state | identifiers, then `[` / component names / property names and values per grammar position |
| function | function ids and `#tags` |
| time | the unit letters `d s t` after a number |
| nbt_path | child names/keys of the target data when the data source is known |

### 14.4 Custom suggestion providers (read)

| Registered id | Provider |
|---|---|
| `minecraft:ask_server` | the client sends a request (14.1) and displays what the server returns; the server evaluates the node's real provider on the server |
| `minecraft:available_sounds` | the client lists sound event ids from its own sound registry |
| `minecraft:summonable_entities` | the client lists entity types that are summonable and enabled by feature flags |
| `minecraft:post_effects` | the client lists post-effect ids from its resources |

### 14.5 Chat-screen display rules (read: `CommandSuggestions`)

Suggestion list height is at most 10 lines (`suggestionLineLimit` 10 in chat); Tab and arrow keys cycle; usage hints use
12-pixel lines. `autoSuggestions` (client option, default true) controls whether suggestions open automatically. The
client falls back to completing player names (`getCustomTabSuggestions`) in plain chat that is not a command.
The text colours are listed in §3.6.

---

## 15. Worked examples

All inputs are the text after the `/`. "Pos" is the cursor of the exception (index into the input). Messages 1/2 are
the two System Chat lines of §4.6. A `^` below the context line marks the cursor.

### 15.1 Error display

The cases below combine the library's traced behaviour ([15a](15a-brigadier-command-library.md) §9.1, example numbers cited as 15a #n) with the game's
choice of message text and presentation (§4.5, §4.6). Message texts are the **game's** (§5); the library's own default texts differ in a few
places (15a §8). Rows that name a real command assume the shape of its tree as stated in the row (the catalog documents the trees).

| Input | Source | Result |
|---|---|---|
| `foo` | any | no root literal matches and the root has no argument children: nothing parsed, reader at 0, consumed range empty (15a #14): `command.unknown.command` at pos 0. Message 1: red "Unknown or incomplete command. See below for error". Message 2: no gray prefix, `foo` red underlined, then red italic `<--[HERE]` (the line reads `foo<--[HERE]`). |
| `gamemode` | level 2 | the literal has children but no command and the reader is at the end (8) (15a #13): `getParseException` returns no error, the chain cannot be flattened and `finishParsing` raises `command.unknown.command` with cursor 8. Message 2: gray `gamemode` then `<--[HERE]`. |
| `gamemode ` with a trailing space | level 2 | one character remains after the literal, fewer than the two needed to continue, so the branch ends with the space unread and no exception (15a #11, #23); the range is not empty: `command.unknown.argument` ("Incorrect argument for command") at pos 8. Message 2: gray `gamemode` (the 8 characters before the cursor), the remaining space red underlined, then `<--[HERE]`. |
| `kill @x` | level 2 | assuming `kill`'s only child is its `targets` argument: after skipping `@` the cursor is 6; on the unknown type the cursor is reset to 6 and `argument.entity.selector.unknown` is thrown with `'@x'` (§7.2); as the only recorded exception it is the one shown (15a §4.1): message 1 red "Unknown selector type '@x'"; message 2: gray `kill @`, red underlined `x`, `<--[HERE]`. |
| `msg @a hi` | level 0 | assuming the first argument of `msg` is a player-selector argument (catalog): the selector parser refuses `@` for a source without `commands/entity_selectors`: `argument.entity.selector.not_allowed` at pos 4 (§2.3). Message 2: gray `msg `, red underlined `@a hi`, `<--[HERE]`. |
| `give` typed by a level 0 player | level 0 | the root literal's requirement fails, so parsing skips it (15a §3.1 step 1) and nothing matches: unknown command at pos 0 (the Commands packet does not contain it either, §3.3). |
| hypothetical tree `demo <n:integer 1..10>`, input `demo 11` | | the number reader returns 11, above the maximum: cursor reset to the start of the number, `argument.integer.big` with ("10", "11") at pos 5 (15a #4). Message "Integer must not be more than 10: found 11" (game text; the library's own text uses a comma); context gray `demo `, red underlined `11`. |
| same tree, input `demo 5x` | | the integer reader stops at `x`; `command.expected.separator` at pos 6 (15a #9). |
| same tree, input `demo abc` | | `abc` contains no number characters, so the run is empty: `parsing.int.expected` ("Expected integer") at pos 5 (15a #6); `parsing.int.invalid` needs a non-empty run. |
| same tree, input `demo 1.5` | | the run `1.5` is rejected by the integer parser: cursor reset to 5, `parsing.int.invalid` with `1.5` at pos 5 (15a #7). |
| hypothetical `name <s:string>`, input `name "a\nb"` | | the active quote is `"`; `\n` is not an allowed escape: `parsing.quote.escape` with `n`, cursor on the `n` (the character after the backslash), pos 8 (15a #20). Message text "Invalid escape sequence '\n' in quoted string" (the game text writes a backslash before the character). Message 2: gray `name "a\`, red underlined `nb"`, `<--[HERE]`. |
| same tree, input `name "abc` | | `parsing.quote.expected.end` ("Unclosed quoted string") with the cursor at the end, pos 9 (15a #21). |
| hypothetical `b <flag:bool>`, input `b ""` | | `readBoolean` uses `readString`; the empty string is an empty result: `parsing.bool.expected` ("Expected boolean") with the cursor after the closing quotes, pos 4 (15a #26). `b "true"` is accepted. |
| error at pos 25 in a 40-character input | | message 2: the ellipsis component `...` first (cursor above 10), then input characters 15 to 24 in gray (the ten characters before the cursor), then input from 25 in red underlined, then `<--[HERE]` red italic. |
| `@e[type=player,type=player]` entity argument | level 2 | `argument.entity.options.inapplicable` with `type`, a value-level refusal: cursor reset to the start of the second value (the `p` of the second `player`). |
| single-target argument given `@a` | level 2 | `argument.entity.toomany` with the cursor at position 0 of the whole input (§7.2 point 4): message 2 has no gray prefix, the whole input red underlined, then `<--[HERE]`. |

### 15.2 Argument parsing

| Argument type | Input | Result |
|---|---|---|
| vec3, executor at (1.0, 64.0, -3.0) | `~ ~1 ~-2` | (1.0, 65.0, -5.0) |
| vec3 | `0 0 0` | (0.5, 0.0, 0.5) (centre correction on x and z; no `.` in the text) |
| vec3 | `0.0 0 0.0` | (0.0, 0.0, 0.0) |
| vec3 | `~ ^ ~` | `argument.pos.mixed`, cursor at the `^` (pos 2) |
| vec3 | `1 2` | `argument.pos3d.incomplete`, cursor reset to the start |
| block_pos | `10 64 -3` | (10, 64, -3) |
| block_pos, executor (1.5, 64.0, 2.5) | `~ ~-1 ~` | (1, 63, 2) (floor of the sums) |
| vec3 local, executor at (0, 64, 0) facing south (yaw 0, pitch 0) | `^ ^ ^3` | approximately (0.0, 64.0, 3.0) (forward is +z at yaw 0; by the formula F = (cos 90°·1, 0, sin 90°·1) = (0, 0, 1); the true x is a tiny non-zero value) |
| vec3 local, yaw 90 (facing west), pitch 0 | `^ ^ ^1` | F = (cos 180°, 0, sin 180°) = (−1, 0, 0): approximately (−1.0, 64.0, 0.0) |
| time (min 0) | `1.5s` | 30 |
| time | `2d` | 48000 |
| time | `5x` | `argument.time.invalid_unit` |
| int_range (R) | `..5` | min absent, max 5; `3..` min 3; `4` min = max = 4 (single value); `5..3` error `argument.range.swapped` at the start of the range (float ranges, id 40, behave the same: `5.0..3.0`); `1.5` error `parsing.int.invalid` (the key `argument.range.ints` is unused) |
| operation | `><` | swap; `=` assign |
| entity selector | `@e[type=zombie,distance=..10,limit=2,sort=nearest]` | all entities of type zombie within 10 blocks of the source, nearest first, at most 2 |
| entity selector | `@a[gamemode=!creative, level=5..]` | players not in creative and with level 5 or more (whitespace after the comma and before `=` is tolerated) |
| entity selector | `@e[limit=0]` | `argument.entity.options.limit.toosmall`, cursor reset to the value (the `0`) |
| entity selector | `@e[x=1` | `argument.entity.options.unterminated` at the end |
| entity selector | `@e[foo=1]` | `argument.entity.options.unknown` with `foo`, cursor on `f` |
| entity selector | `@e[limit]` | `argument.entity.options.valueless` with `limit`, cursor on `l` |
| entity selector | `@p[type=zombie]` | parses without an inapplicable error: the positive `type` is applied with `limitToType` and overwrites the `PLAYER` limitation set by `@p` (what such a selector then matches was not traced, Open question 7) |
| entity selector | `@e[type=player,type=player]` | the second positive `type` is refused by `InvertableSetOptionState` (state SINGLE): `argument.entity.options.inapplicable` with `type`, a value-level refusal: cursor reset to the start of the second value |
| entity selector | `@e[tag=a,tag=!b,tag=a]` | all accepted: `tag` has no option state |
| entity selector | `Steve` | name selector, limit 1 |
| entity selector | `ThisNameIsTooLongForMinecraft` | `argument.entity.invalid` |
| entity selector | `a1b2c3d4-0000-0000-0000-000000000001` | UUID selector |
| block_state | `oak_stairs[facing=north,half=top]` | block with those properties |
| block_state | `stone[foo=bar]` | `argument.block.property.unknown` ("Block minecraft:stone does not have property 'foo'") |
| block_predicate | `#minecraft:logs` | tag match |
| score_holder | `*` | all tracked holders (multiple) |
| score_holder | `#total` | fake player `#total` |
| uuid | `dd12be42-52a9-4a91-a8a1-11c01849e498` | the UUID |
| hex_color | `F00` | 0xFF0000 |
| scoreboard_slot | `sidebar.team.red` | the red team sidebar slot |
| nbt_path | `Items[0].Slot` | name `Items`, index 0, name `Slot` |
| nbt_path | `Inventory[{id:"minecraft:stone"}]` | list elements matching the compound |
| snbt | `{a:1b,b:[1,2,3],c:"x y"}` | compound with a byte, an int list and a string |

### 15.3 The Commands packet for a filtered tree (constructed example, not a captured packet)

Tiny tree: root with literal `a` (no requirement, executable) and literal `b` (requirement level 2, no command) that has an argument
child `n:integer(1..10)` (executable, no own requirement) and a literal child `c` that redirects to the root (no own requirement).
For a level 0 player `b` is filtered out, so the copy is root and `a` (2 nodes). For a level 2 player the breadth-first numbering
(§3.4) is 0 root, 1 `a`, 2 `b`, 3 `n`, 4 `c`. The restricted flag is computed **per node** from that node's own requirement against a
source with no permissions; only `b` has a requirement, so only `b` is restricted.

| Index | Flags | Children | Redirect | Name | Parser | Props |
|---|---|---|---|---|---|---|
| 0 | 0x00 (root) | [1, 2] | | | | |
| 1 | 0x05 (literal 1 + executable 4) | [] | | `a` | | |
| 2 | 0x21 (literal 1 + restricted 32) | [3, 4] | | `b` | | |
| 3 | 0x06 (argument 2 + executable 4) | [] | | `n` | 3 (integer) | flags 0x03 (min and max), min 1, max 10 |
| 4 | 0x09 (literal 1 + redirect 8) | [] | 0 | `c` | | |

Root index 0.

## 16. Validation (what an implementation must pass)

1. **Tree filtering.** For a level 0 and a level 2 source, the Commands packet lists exactly the nodes whose requirement passes, executable and restricted flags correct, redirect indices valid, and the client accepts it.
2. **Permission atoms.** A level 1 source cannot parse `@s`, a level 2 source can; a name or UUID always parses.
3. **Error positions.** The examples in §15.1 reproduce the same message key, argument list and cursor; the context line shows at most 10 characters before the cursor, the ellipsis when the cursor is more than 10 from the start, the remainder red and underlined, and `<--[HERE]`.
4. **Separator rule.** `5x` for an integer fails with `command.expected.separator` at the `x`; `give  @s stone` (two spaces) fails as an empty argument position; the continue rule needs two characters after a node without a redirect and one after a redirect node; a redirect branch is returned immediately.
5. **Quoted strings.** Inputs `"a\"b"` (escape, a string argument), `"unterminated` (`parsing.quote.expected.end`, cursor at the end), `"bad\q"` (`parsing.quote.escape` with `q`, cursor on the `q`); `"true"` is a valid bool; `""` as a bool is `parsing.bool.expected` with the cursor after the quotes.
6. **Numbers.** Int overflow (`2147483648`) is `parsing.int.invalid`; range violation is `argument.integer.low/big` with both numbers.
7. **Coordinates.** Centre correction, relative and local formulas, mixing error, incomplete error.
8. **Selector.** Every type letter, every option with its error, sort/limit defaults per §7.6, the `@e` alive rule, `@s` option restrictions.
9. **Time.** Units `t s d`, rounding, minimum.
10. **Ranges.** All five forms and both errors.
11. **Feedback.** With `send_command_feedback` false a player gets no success messages but still gets failures; operators other than the executor receive `[Name: message]` in gray italics only when the rule is true; the console log follows `log_admin_commands`.
12. **Execute.** `execute as @a at @s run ...` forks per entity; the library's `execute` returns the count of successful runs for a fork, the sum of results for an unforked chain, and 0 for a modifier yielding no sources (library only, §10.2; the game's queue was not decoded); `if`/`unless` pass/fail feedback and counts; `store result score` captures the return value; the fork limit and sequence limit stop runaway chains with `command.forkLimit`.
13. **Suggestions.** Latest request wins (single slot); at most one request processed per tick; the range includes the leading `/`; matching after `. _ /` (read); resource ids matched by namespace or path (read); at most 1000 entries (read); sorting by case-insensitive text with numeric order among integer suggestions only and no tie-break by the original text (15a §6.4).
14. **Signing.** An unsigned command with a `message` argument is rejected when secure profiles are enforced; names of signed arguments must match the parsed signable arguments.

---

## Open questions

1. **Java platform behaviour carried over from 15a.** `Integer.parseInt` and friends (accepted grammar, overflow to infinity), the printed form of boxed numbers, `Character.isWhitespace`, and `String.compareToIgnoreCase` for non-ASCII are Java specification, not read from either jar (15a open question 1). Entries equal ignoring case in a suggestion list have no specified order (15a open question 2).
2. **Commands packet after `/reload`.** Read: `sendPlayerPermissionLevel` resends it on a level change; the reload path was not traced (§3.3).
3. **Chat permission atoms** (`chat/send_messages`, `chat/send_commands`, `chat/receive_player_messages`, `chat/receive_system_messages`) are defined but their consumers were not found on the command path.
4. **`execute` and the game's execution queue** (§10.2, §11): `facing entity`, `summon`, the internals of the `data`, `items` and `blocks` conditions, the details of `store` (target writing, scaling, timing), and the exact result and callback combination across forks in the game's own `ExecutionContext`/`BuildContexts` queue.
5. **SNBT details** (§9.4): the permitted characters of an unquoted SNBT string, how each numeric literal maps to an NBT tag type, typed list and array checks.
6. **Argument types not traced:** `particle` option grammar per particle type (§6.5), `resource_selector` pattern rules beyond the examples, `slot_source` grammar, the inline-definition grammar of `loot_*`, `context_*_provider`, `dialog` and `feature`; whether `score_holder` `*` is refused when multiple is false.
7. **Selector details** (§7.6): the world scan rules for non-world-limited selectors, what `@p[type=zombie]` matches, whether `scores` implies players-only.
8. **Suggestion contents of the game's own argument types** (§14.3 table): entity, block_pos, item, function, nbt_path and the rest were not decoded (the library part is read, 15a §5).
9. **Function resource location and tags** (§12), and `commandSpamThrottler` semantics beyond its construction (§13.1 item 7).
10. **Rcon permission level** (§2.2), and the behaviour of a source below level 2 that types `@` text in a `message` argument (it parses; resolution uses the literal text).
11. **NBT path limits** (§9.5): the `too_deep` and `too_large` limits and the meaning of a negative index.
12. **Restricted flag nesting** (§15.3): computed per node from the node's own requirement (read); how the standard commands place requirements on child nodes was not surveyed.
13. **Root-type check in the Commands decoder** (§3.4): whether the root index must be a root-type entry.
14. **Server suggestion path and requirements** (§14.2): the server's request path calls the dispatcher's completion without filtering by requirement (read) and the library does not test requirements (15a §6.1), so a reply may name children the player cannot use; this follows from the code and was not exercised.
15. **Disconnect text of a signed-argument mismatch** (§13.1 item 6).
16. **Still recalled, not verified:** the `store` details of §11.2 and the shared limits of functions (§12), and every statement marked **(recalled, not verified)** inline.
