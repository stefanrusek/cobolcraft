# 57. Client closures, part 4: the command node tree

| Item | Value |
|---|---|
| Covers | The node tree of the Commands packet (0x10) that the 26.3 server sends: the packet layout re-read against the artifact (§2); how command requirements are expressed in 26.3 and what each permission level sees (§3); the exact rules that turn the registered commands into the packet's node list, including the structural equality that merges nodes (§4); node counts for the levels 0 to 4 and for the dedicated and integrated selections (§5); per-command node counts and the rule for pruning to a subset of commands (§6); the node tree of every command with parser ids, property values, executable and restricted flags, redirects and suggestion providers (§7); suggestion tooltips (§8); vanilla counts against the stand-in counts of project documents and against a 28-node tree (§9); byte-level listings of the level-0 packets and a fixture checklist (§10) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Second artifact | `brigadier-1.3.11.jar`, SHA-256 `9d09cf4819de83dfcd38bcb212d5f2227131791cef3abbfca3321d6fb2b9a64d` (the second artifact recorded in README). Read only for the node classes' `equals`, the builder `then` and `addChild` semantics, the stock argument types' `equals` and factories, and the `StringType` ordinals |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants` and `-v` for the bootstrap tables), with no execution of the game. The command trees were obtained by evaluating the bytecode of every `register` method and of the helper methods and lambdas it calls symbolically, with a script run over the `javap` text (the script interprets the builder calls, the loops over enum constants and static lists, and the constructors of argument types; it does not run the game). Checks of that evaluation are in §4.7. Clean-room round "client closures, part 4" (reader c4 only; a reviewer follows) |
| Extends | 05a (0x10 Commands, 0x0F Command Suggestions), 15 §2 (permissions), §3 (tree), §14 (suggestions), 16 §3 (index of levels), 09 §3.5.2 (fixtures) |

All counts include the root node (index 0) unless a sentence says otherwise. "Dedicated" is the registration group of a dedicated server (`CommandSelection` with `includeDedicated`), "integrated" the group of a single-player or LAN-host server (15 §1). The reference selection of this document is **dedicated, without `jfr`**; the other cases are given as deltas.

---

## 1. What the earlier documents already state

**Gap closed:** which parts of the command-tree topic needed no new text, and what the earlier text left open or got wrong.

| Topic | Where | Status after this round |
|---|---|---|
| Commands packet field layout, flags byte, parser id table 0 to 61, property layouts | 05a 0x10 | Correct. Every item was re-read (§2.1). Not repeated here, except where a value was missing (§2.1 marks them) |
| Which nodes a player receives (filtered copy, redirect map) | 15 §3.3 | Correct. §4 adds the equality rule that governs the redirect map and the numbering |
| Node numbering | 15 §3.4 | The order (breadth first, children then redirect) is correct. The sentence "a node reachable twice (via a redirect) is numbered once" is incomplete: the jar numbers **structurally equal** nodes once (§2.2) |
| Permission model | 15 §2.1, §2.2 | Correct (re-read in §3) |
| Registered commands and their levels | 15 §1, 16 §3 | Complete and consistent with the jar: the 102 registered names (97 commands and 5 aliases) of 16 §3 are exactly the names the jar registers; no command is missing from 16 and none is extra (§6). One level fact of 16 needs a correction (§3.3: the `<sequence>` nodes of `random`) |
| Restricted flag, client dispatcher, unattended commands | 15 §3.5 | Unchanged. Open question 12 of 15 (how the standard commands place requirements below the root) is closed by §3.3 |
| Suggestions flow and `ask_server` | 15 §14 | Unchanged. §8 adds the tooltip sources |
| Command Suggestions packet | 05a 0x0F | Correct (§8.1) |

New in this document: the node tree itself (§7), the node counts (§5, §6), the structural-equality rule (§2.2, §4), the exact list of requirements below the root (§3.3), and the tooltip sources (§8).

---

## 2. The Commands packet as the artifact reads and writes it

**Gap closed:** exactness of the 0x10 layout (05a), and the facts the layout alone does not give.

### 2.1 Re-read items

Read from `ClientboundCommandsPacket` (constructor, `enumerateNodes`, `createEntries`, `createEntry`, `readNode`, `read`), `ClientboundCommandsPacket$Entry`, `Commands$1` (the node inspector), `ArgumentTypeInfos.bootstrap` and the `ArgumentTypeInfo` implementations.

| Item | Result |
|---|---|
| Packet body | VarInt node count, the nodes in index order, VarInt root index. The server's root index is always 0 (the enumeration starts at the root) |
| Node | Byte flags; children as a VarInt array (count then indices); VarInt redirect index only when flag 0x08; then the stub: literal = name (string); argument = name (string), VarInt parser id, the parser's property bytes, and an Identifier (string) only when flag 0x10 |
| Flag bits written | 0x03 type (0 root, 1 literal, 2 argument); 0x04 the node has a command; 0x08 the node has a redirect; 0x10 (argument nodes only) the node has a custom suggestion provider; 0x20 the node's own requirement fails for a source with no permissions. The root node is 0x00 |
| Combination | 0x04 and 0x08 occur together: 44 nodes of the full tree are executable and also redirect (for example every `execute if|unless ... <last argument>`; §7 marks them `x ->/execute`) |
| Parser ids | The 62 registrations of `ArgumentTypeInfos.bootstrap` are in the order and with the names of the table in 05a (0 `brigadier:bool` ... 61 `uuid`). Re-read item by item |
| Number properties | `brigadier:integer` (3), `long` (4), `float` (1), `double` (2): a flags Byte (bit 0 = a minimum follows, bit 1 = a maximum follows); the bit is set when the value differs from the type's extreme (Int.MIN/MAX, Long.MIN/MAX, -/+3.4028235e38 for float, -/+1.7976931348623157e308 for double); then the minimum, then the maximum, written big endian with the type's own width (`writeInt`, `writeLong`, `writeFloat`, `writeDouble`). A node with neither bound has the single property byte 0x00 |
| `brigadier:string` (5) | One VarInt: the ordinal of `StringArgumentType$StringType` (`writeEnum` writes the ordinal as a VarInt). Read from the Brigadier jar: `SINGLE_WORD` 0, `QUOTABLE_PHRASE` 1, `GREEDY_PHRASE` 2. This closes Open question 1 of 05a (the ordinals were inferred there). The factories map `word()` to 0, `string()` to 1, `greedyString()` to 2 |
| `entity` (6) | One Byte: bit 0 (0x01) single entity only, bit 1 (0x02) players only. `entity()` is 0x01, `entities()` 0x00, `player()` 0x03, `players()` 0x02 |
| `score_holder` (31) | One Byte: bit 0 (0x01) multiple allowed |
| `time` (43) | One Int (4 bytes, big endian): the minimum |
| Registry-key parsers 44 to 48 (`resource_or_tag`, `resource_or_tag_key`, `resource`, `resource_key`, `resource_selector`) | One Identifier written as a string in the form `namespace:path`: the identifier of the registry key, for example `minecraft:enchantment`, `minecraft:worldgen/biome` (`writeResourceKey` writes `ResourceKey.identifier()` through `writeIdentifier`, which writes `Identifier.toString()`). The key paths used by the tree are in §7 next to each argument |
| All other parsers | No property bytes (`SingletonArgumentInfo`), including 52 to 59 and the three that carry an inner definition in the type object (`heightmap`, `template_mirror`, `template_rotation`) |
| Custom suggestions Identifier | Written with the same string form, for example `minecraft:ask_server` (the four registered names are in §2.3) |
| Unknown parser id on read | The client looks the id up in the registry; a missing entry returns no stub and no property bytes are read (as 05a states) |
| Parser ids that occur | 59 of the 62 ids occur in the full tree; the three that never occur are 4 `long`, 28 `angle` and 35 `item_slots` (no node of the standard tree uses them; §5.3) |

### 2.2 Structural equality merges nodes (new)

`enumerateNodes` keys a hash map by the node objects themselves, and `createEntries` and the children and redirect indices look nodes up in the same map. The Brigadier node classes define `equals` structurally (read in the Brigadier jar, `CommandNode.equals`, `LiteralCommandNode.equals`, `ArgumentCommandNode.equals`, `RootCommandNode.equals`), so two nodes that are equal get **one index**:

| Compared | Not compared |
|---|---|
| node kind (root, literal, argument); the literal text or the argument name; for an argument, the argument type object; the children (the set of name and child pairs, order ignored, each child compared recursively); the command object (both absent, or the same object) | the requirement, the redirect target, the redirect modifier and fork flag, the custom suggestion provider |

Argument type equality: the four Brigadier number types (`IntegerArgumentType`, `LongArgumentType`, `FloatArgumentType`, `DoubleArgumentType`) compare their minimum and maximum; `BoolArgumentType`, `StringArgumentType` and every argument type class of the game define no `equals` and so compare by object identity (two nodes with such types are equal only when they hold the very same type object).

When the enumeration meets a second node equal to one already numbered it skips it; the first node met supplies the flags, redirect and suggestion Identifier of the shared entry, and every parent that holds an equal child lists the shared index. (The map is fastutil's `Object2IntOpenHashMap`, created by its no-argument constructor; that its default key comparison is `equals` and `hashCode` is recalled, not verified: Open question 8.) The wire form is therefore a directed acyclic graph, not a tree. A decoder needs nothing special for it (05a: indices in any order are accepted; shared children are only more edges).

In the full 26.3 tree exactly **10 classes of equal nodes** exist, holding 78 nodes and saving 68 entries. No two nodes that carry a command are equal: every `executes` call site of the registration code yields a command object that no other node holds (a lambda that captures state, an instance of an anonymous class, or a non-capturing lambda at its own call site; checked across the `register` methods and the helpers they call, including the repeated helper calls of `execute`, `data`, `item` and `gamerule`). Every merged node therefore has **no command**, and the merges do not depend on how the JVM treats lambda objects: whether a repeated non-capturing lambda is one object or several, no two executable nodes become equal.

| Equal class (node, in the unfiltered tree) | Instances | Saved | Where |
|---|---|---|---|
| argument `scale` (double, no bounds), no children, no command, redirect `/execute` | 36 | 35 | `execute store (result\|success) (entity\|block\|storage) ... <path> (int\|float\|short\|long\|double\|byte) <scale>` |
| literals `int`, `float`, `short`, `long`, `double`, `byte` (each with the one child `scale`) | 6 each | 5 each (30) | same place: three stores times two (`result`, `success`) |
| literal `run` (no children, no command, redirect `/`) | 2 | 1 | `execute run` and `return run` |
| literals `value` and `max` (redirect `/execute`) | 2 each | 1 each (2) | `execute store (result\|success) bossbar <id> (value\|max)` |

For a subset of commands the merge applies only to the commands that are present (§6.2).

### 2.3 Custom suggestion Identifiers

`SuggestionProviders.getName` returns the registered name when the provider is one of the four registered providers and `minecraft:ask_server` for every other provider (read, as 15 §3.4 states). In the full tree 131 nodes carry flag 0x10:

| Identifier | Nodes | Meaning (15 §14.4) |
|---|---|---|
| `minecraft:ask_server` | 114 | the client sends a Command Suggestion Request and shows the server's answer |
| `minecraft:available_sounds` | 13 | client-side list of sound ids (`playsound`, `stopsound`) |
| `minecraft:summonable_entities` | 2 | client-side list of summonable entity types (`summon`, `execute summon`); the only provider that returns tooltips locally (§8.3) |
| `minecraft:post_effects` | 2 | client-side list of post-effect ids (`posteffect`) |

In the listings of §7 a node with `sug=ask` carries `minecraft:ask_server`; the other three show their name. The origin of each `ask` provider (the class that defines it) is in §8.4.

---

## 3. Requirements: how 26.3 expresses them and who sees what

**Gap closed:** the permission model the jar uses for command nodes, the visibility of every command per level, and the requirements that sit below the root literal.

### 3.1 The model used by the tree

26.3 expresses a command requirement as a `PermissionCheck` evaluated against the source's `PermissionSet` (the old integer `hasPermission(level)` is gone). Read in `Commands`, `Permissions`, `PermissionCheck$Require`, `PermissionCheck$AlwaysPass`, `PermissionProviderCheck`, `LevelBasedPermissionSet`, `PermissionLevel`:

| Item | Read |
|---|---|
| Node requirement | `Commands.hasPermission(check)` builds a `PermissionProviderCheck` (a predicate over any object that supplies a permission set); the node's requirement is that predicate, tested with the player's command source |
| Checks defined | `LEVEL_ALL` (`AlwaysPass`, true for every set), `LEVEL_MODERATORS`, `LEVEL_GAMEMASTERS`, `LEVEL_ADMINS`, `LEVEL_OWNERS` (each a `Require` of a `HasCommandLevel` permission for the level 1, 2, 3, 4) |
| Level test | A level-based set (the only kind a player has, 15 §2.1) holds `HasCommandLevel(L)` when its own level id is greater than or equal to L (`PermissionLevel.isEqualOrHigherThan` compares the ids 0 to 4). The set of a player is level 0 when the player is not an operator (15 §2.2) |
| Used by the tree | Only `LEVEL_GAMEMASTERS`, `LEVEL_ADMINS` and `LEVEL_OWNERS` (one command, `gamemode`, uses its own static `PERMISSION_CHECK`, a `Require` of `Permissions.COMMANDS_GAMEMASTER`, the same permission that `LEVEL_GAMEMASTERS` wraps; both static initialisers read). **`LEVEL_MODERATORS` is used by no node** (no command requires level 1). **`LEVEL_ALL` is used only by `seed` and `version`**: `SeedCommand.register` and `VersionCommand.register` always call `requires(hasPermission(check))` with `LEVEL_GAMEMASTERS` when their Boolean is true and `LEVEL_ALL` when it is false (read), so in the integrated selection these two nodes carry a requirement that always passes. Every other level-0 command has no `requires` call at all. No node requires a named atom: the atom `commands/entity_selectors` is consulted by the argument parsers, not by the tree (15 §2.3) |
| Predicate form | No node uses a lambda predicate or a combined predicate; all requirements are the checks above |
| Restricted flag | A node is flagged 0x20 exactly when its **own** requirement is present **and fails** for a source with no permissions (`Commands$1.isRestricted` tests the node's requirement against a source built with `NO_PERMISSIONS`). Every `Require` fails for such a source; `LEVEL_ALL` (`AlwaysPass`) passes, so the integrated `seed` and `version` are not flagged (0x05, §10.2). A node below a restricted parent is not flagged unless it has a requirement of its own (the 86 flagged nodes of the full tree are the 81 restricted root literals and the 5 inner nodes of §3.3) |

### 3.2 Levels

The tree a player receives depends only on the level (15 §3.3; filter rule in §4.3). Roots are the children of the root node; the counts are in §5.

| Level | Root literals first visible at this level (dedicated) |
|---|---|
| 0 | 10: `me`, `help`, `list`, `msg`, `tell`, `w`, `random`, `teammsg`, `tm`, `trigger`. The inner nodes of `random` that need level 2 are hidden (§3.3) |
| 1 | none: no node requires level 1, so a level 1 player receives exactly the level 0 tree |
| 2 | 63 (`advancement`, `attribute`, `execute`, `bossbar`, `clear`, `clone`, `compute`, `damage`, `data`, `datapack`, `defaultgamemode`, `dialog`, `difficulty`, `effect`, `enchant`, `experience`, `xp`, `fill`, `fillbiome`, `forceload`, `function`, `gamemode`, `gamerule`, `give`, `item`, `kill`, `locate`, `loot`, `swing`, `particle`, `place`, `playsound`, `posteffect`, `reload`, `recipe`, `fetchprofile`, `return`, `ride`, `rotate`, `say`, `schedule`, `scoreboard`, `seed`, `version`, `setblock`, `spawnpoint`, `setworldspawn`, `spectate`, `spreadplayers`, `stopsound`, `stopwatch`, `summon`, `tag`, `team`, `teleport`, `tp`, `tellraw`, `test`, `time`, `title`, `waypoint`, `weather`, `worldborder`) |
| 3 | 13 (`debug`, `kick`, `tick`, `ban-ip`, `banlist`, `ban`, `deop`, `op`, `pardon`, `pardon-ip`, `setidletimeout`, `transfer`, `whitelist`) |
| 4 | 5 (`perf`, `save-all`, `save-off`, `save-on`, `stop`), and the sub-branch `datapack create` |

In the integrated selection `seed` and `version` are level 0: their `register` takes a Boolean that selects `LEVEL_GAMEMASTERS` when true and `LEVEL_ALL` (always passes) when false, and `Commands.<init>` passes true for every selection except INTEGRATED (read). `publish` and `unpublish` are level 4, and the dedicated-only commands (`ban`, `ban-ip`, `banlist`, `deop`, `op`, `pardon`, `pardon-ip`, `perf`, `save-all`, `save-off`, `save-on`, `setidletimeout`, `stop`, `transfer`, `whitelist`) do not exist.

### 3.3 Requirements below the root literal (closes Open question 12 of 15)

Exactly five nodes of the unfiltered tree carry a requirement below a root literal:

| Node path | Requirement | Effect |
|---|---|---|
| `datapack create` | level 4 (`LEVEL_OWNERS`) | `datapack` is level 2; the `create` branch (3 nodes) appears only at level 4 |
| `debug function` | level 3 | the parent `debug` is already level 3, so the check adds nothing |
| `random reset` | level 2 | the `reset` branch (9 nodes) is hidden at level 0 and 1 |
| `random value <range> <sequence>` | level 2 | the optional sequence argument node (1 node) is hidden at level 0 and 1 |
| `random roll <range> <sequence>` | level 2 | same (1 node) |

Corrections to 16: §10.8 is wrong where it gives the grammar `random value <range> [<sequence>]` (and `roll`) under "Level 0": the jar requires level 2 for the `<sequence>` node of both. The level summary of 16 §1 is imprecise: it lists `random value` and `random roll` at level 0 without saying that their optional sequence node is level 2. The nodes with no requirement are `random`, `value`, `roll` and their `<range>` nodes (5 nodes at level 0). 16 §3 lists `seed` and `version` as "2 (0 in integrated)", which agrees with §3.2.

### 3.4 Selection groups (registration conditions)

Read from `Commands.<init>`: 76 root literals (including the aliases `xp`, `tell`, `w`, `tm`, `tp`) are registered by every selection, in the order of the first column of §6.1; `seed` and `version` are among them; the 15 dedicated-only roots follow in the order `ban-ip`, `banlist`, `ban`, `deop`, `op`, `pardon`, `pardon-ip`, `perf`, `save-all`, `save-off`, `save-on`, `setidletimeout`, `stop`, `transfer`, `whitelist`; `publish` and `unpublish` close the integrated group. `jfr` is added when `JvmProfiler.isAvailable()` is true (the `jdk.jfr` module is present in the runtime layer and `FlightRecorder.isAvailable()` is true; a runtime fact, Open question 2); eight developer commands (`chase`, `raid`, `debugpath`, `debugmobspawning`, `warden_spawn_tracker`, `spawn_armor_trims`, `serverpack`, `debugconfig`) are added only under the debug flags of 15 §1 and are not part of any normal tree; their sizes are in §6.3.

---

## 4. How the node list is computed

**Gap closed:** the exact procedure that yields the packet's nodes and counts, so that a catalogue-subset tree can be checked.

### 4.1 Building the full tree

1. The roots are registered in the order of §3.4. A root literal is added to the dispatcher's root; adding a name that already exists keeps the old node and merges the new node's children into it, replacing the old command when the new node has one (15 §3.2). `execute` is registered twice in this way (the first registration only fixes the node that the redirects point to).
2. Brigadier's `then(builder)` **builds the child immediately** and adds the built node with the same merge rule; a node cannot receive children after it has a redirect (read in the Brigadier jar). Children therefore appear in the order of the `then` calls.
3. Loops in the registration code take their elements in the order of the source collection: `difficulty` and `playsound` and `stopsound` iterate the enum constants of `Difficulty` and `SoundSource` in declaration order; the data-accessor lists of `data`, `execute data`, `item` and `function with` are `List.of` lists (entity, block, storage for data; entity, block for item sources); `gamerule` visits the game rules (§7, `gamerule`).

### 4.2 Aliases

An alias is a root literal with a redirect to the target node (15 §3.1). `tell` and `w` redirect to `msg`, `tm` to `teammsg`, `xp` to `experience` and `tp` to `teleport`. Aliases carry no children. `tp` and `xp` carry their own level-2 requirement (flags 0x29); `tell`, `w` and `tm` carry none (flags 0x09), so they are level 0 like their targets (§6.1 shows the level of every alias).

### 4.3 The per-player filter

`Commands.sendCommands` copies the tree for the player: walking depth first in child order, a child is copied when its own requirement passes for the player's source; the copy's redirect is the copy of the original redirect target when that target was copied earlier in the same walk (the map is keyed by structural equality, §2.2), otherwise the copy has no redirect; the walk descends only into copied nodes that have children. So:

- a node is sent only if it and every ancestor pass: `random value <range> <sequence>` is absent at level 0 even though a level 0 source could parse a plain word there;
- a redirect to a node copied later would be lost; in the 26.3 tree no redirect is a forward reference (checked for the levels 2 and 4: 0 redirects lost), every target (`/execute`, `/`, `/msg`, `/teammsg`, `/experience`, `/teleport`) is an ancestor or an earlier root;
- there is no pruning of "unreachable" commands beyond this: a command with no executable node would still be sent.

### 4.4 Numbering and counting

The packet nodes are the equivalence classes (§2.2) of the nodes reachable from the root of the filtered copy, found breadth first: a queue starts with the root; each polled node that is not yet numbered gets the next index, then its children in child order and then its redirect target are appended. **The root is counted** (index 0). A redirect target is numbered once, like every node (it is a node of the tree anyway). The index of a node is the number of distinct classes polled before it.

Consequences: the root's children are numbered 1 to n in child order (registration order of §3.4 restricted to the visible roots); the nodes below follow level by level.

### 4.5 Counting rule

Packet node count = 1 (root) + the number of nodes of the filtered copy − (the number of nodes merged by §2.2). The filtered copy's node count is the number of nodes of the visible root subtrees (§6.1 gives it per command and level).

- Is the root counted? Yes: it is index 0.
- Are redirect targets shared? Yes. A redirect target is itself a node of the tree, so it is one entry and the redirecting node holds its index (`tell` holds the index of `msg`); equal nodes (§2.2) are shared too.
- Are unreachable commands pruned? Only by the filter: a node is dropped when it or an ancestor fails its requirement. A visible command with no executable node is still sent. Nothing else is pruned.

### 4.6 Selection and feature dependence

- **Selection:** dedicated and integrated differ as §3.2 says.
- **Feature flags:** the `gamerule` subtree has one entry per enabled game rule; the rule `max_minecart_speed` requires the feature flag `minecart_improvements`, which is not in the default flag set (`FeatureFlags.DEFAULT_FLAGS` holds only `vanilla`; that a world uses the default set unless it enables more is inferred), so the default tree holds 58 rules (§7, `gamerule`). With the flag enabled the tree is 4 nodes larger at every level of 2 and above.
- **Developer flags:** `SharedConstants.IS_RUNNING_IN_IDE` and the `DEBUG_*` flags are plain false fields; with them false the `test` command has no `export`, `exportclosest`, `exportthese` or `exportthat` branch (55 says the same) and no developer command is registered.

### 4.7 Checks of the evaluation

- The set of root names the evaluation produced for all groups together (the 91 roots of the dedicated tree, `publish`, `unpublish`, `jfr` and the eight developer commands) is exactly the 102 names of 16 §3, and the level of every one of them (own requirement of the root literal, dedicated flags) equals the first level number in the "Level" column of 16 §3.
- Every call that passed a node, a callback or a visitor to a method the evaluation does not interpret was logged. The only such call that could add nodes is `GameRules.visitGameRuleTypes` (the game-rule visitor); it is handled by reading the 59 registrations of `GameRules.<clinit>` (§7). Calls into argument-type constructors and grammar builders (the component, item-predicate and style parsers) do not add command nodes.
- The node and argument names of eight of the largest or most irregular listings (`scoreboard`, `item`, `loot`, `playsound`, `stopsound`, `team`, `test`, `worldborder`) were compared with the names the registering bytecode pushes: every difference is explained by names that come from enum constants (`SoundSource`, `Difficulty`, scoreboard render types), by the argument-provider lambdas of `data` and `item` (entity, block, storage), by the developer-flag branches of `test` (§4.6), or by the root literal itself.
- The tree is closed under the subset rule of §6.2: the node count of 300 random subsets of the roots, at levels 0, 2, 3 and 4, equals the formula of §6.2 (checked by building both).

---

## 5. Node counts

**Gap closed:** the node counts of the tree sent at each level, for both selections, with the arithmetic.

### 5.1 Counts (with root)

| Selection | Level | Nodes sent | Filtered copy before merging | Root children |
|---|---|---|---|---|
| dedicated | 0 | **26** | 26 | 10 |
| dedicated | 1 | **26** | 26 | 10 |
| dedicated | 2 | **2333** | 2401 | 73 |
| dedicated | 3 | **2385** | 2453 | 86 |
| dedicated | 4 | **2396** | 2464 | 91 |
| dedicated with `jfr` | 0 | **26** | 26 | 10 |
| dedicated with `jfr` | 1 | **26** | 26 | 10 |
| dedicated with `jfr` | 2 | **2333** | 2401 | 73 |
| dedicated with `jfr` | 3 | **2385** | 2453 | 86 |
| dedicated with `jfr` | 4 | **2399** | 2467 | 92 |
| integrated | 0 | **28** | 28 | 12 |
| integrated | 1 | **28** | 28 | 12 |
| integrated | 2 | **2333** | 2401 | 73 |
| integrated | 3 | **2353** | 2421 | 76 |
| integrated | 4 | **2360** | 2428 | 78 |

- Dedicated, level 0 and level 1: **26 nodes** (the root and 25 nodes; listing in §10.1). Level 1 equals level 0.
- Integrated, level 0 and level 1: **28 nodes** (the dedicated tree plus `seed` and `version`; listing in §10.2).
- Dedicated, highest level (4, operator): **2396 nodes**; with `jfr` 2399; integrated 2360.
- Level deltas, dedicated: level 2 adds 2307 nodes over level 0 (the nodes of the 63 level-2 roots and the 11 `random` nodes hidden below level 2, less the one merged entry of §2.2); level 3 adds 52 (the 13 level-3 roots and `debug function`); level 4 adds 11 (the 5 level-4 roots and the 3 nodes of `datapack create`).
- `gamerule` with the feature `minecart_improvements` enabled: add 4 nodes at levels 2 to 4 (§4.6).

### 5.2 Totals by node kind (dedicated)

| Measure | Level 0 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|
| Nodes (with root) | 26 | 2333 | 2385 | 2396 |
| Literal nodes | 15 | 1116 | 1148 | 1157 |
| Argument nodes | 10 | 1216 | 1236 | 1238 |
| Executable (0x04) | 12 | 1371 | 1406 | 1414 |
| Redirect (0x08) | 3 | 78 | 78 | 78 |
| Executable and redirect | 0 | 44 | 44 | 44 |
| Restricted (0x20) | 0 | 66 | 80 | 86 |
| Custom suggestions (0x10) | 1 | 121 | 131 | 131 |

Integrated, level 0: 17 literal nodes, 10 argument nodes, 14 executable, 3 redirect, 0 restricted, 1 custom suggestions. These columns are invariants a fixture can check without knowing the tree (§10.4).

### 5.3 Argument parsers in the level-4 dedicated tree

Number of argument nodes per parser id (the 59 ids that occur; sum = 1238):

| id, parser, argument nodes | id, parser, argument nodes | id, parser, argument nodes |
|---|---|---|
| 0 `bool`: 113 | 1 `float`: 46 | 2 `double`: 12 |
| 3 `integer`: 165 | 5 `string`: 17 | 6 `entity`: 146 |
| 7 `game_profile`: 6 | 8 `block_pos`: 116 | 9 `column_pos`: 5 |
| 10 `vec3`: 22 | 11 `vec2`: 2 | 12 `block_state`: 2 |
| 13 `block_predicate`: 11 | 14 `item_stack`: 21 | 15 `item_predicate`: 5 |
| 16 `team_color`: 2 | 17 `hex_color`: 1 | 18 `component`: 16 |
| 19 `style`: 2 | 20 `message`: 7 | 21 `nbt_compound_tag`: 5 |
| 22 `nbt_tag`: 15 | 23 `nbt_path`: 114 | 24 `objective`: 28 |
| 25 `objective_criteria`: 1 | 26 `operation`: 1 | 27 `particle`: 1 |
| 29 `rotation`: 5 | 30 `scoreboard_slot`: 1 | 31 `score_holder`: 27 |
| 32 `swizzle`: 1 | 33 `team`: 5 | 34 `item_slot`: 2 |
| 36 `resource_location`: 79 | 37 `function`: 5 | 38 `entity_anchor`: 4 |
| 39 `int_range`: 4 | 40 `float_range`: 2 | 41 `dimension`: 6 |
| 42 `gamemode`: 2 | 43 `time`: 18 | 44 `resource_or_tag`: 5 |
| 45 `resource_or_tag_key`: 1 | 46 `resource`: 11 | 47 `resource_key`: 12 |
| 48 `resource_selector`: 4 | 49 `template_mirror`: 1 | 50 `template_rotation`: 1 |
| 51 `heightmap`: 1 | 52 `loot_table`: 14 | 53 `loot_predicate`: 2 |
| 54 `loot_modifier`: 14 | 55 `context_float_provider`: 48 | 56 `context_int_provider`: 48 |
| 57 `slot_source`: 28 | 58 `dialog`: 1 | 59 `feature`: 1 |
| 60 `swing_animation`: 2 | 61 `uuid`: 1 |  |

---

## 6. Per-command counts and the subset rule

**Gap closed:** per-command node counts, so a tree built from a subset of the catalogue can be checked, and the rule that prunes a subset.

### 6.1 Counts per root literal

"Nodes" is the number of packet nodes the command contributes when it is the only command (its own literal, all visible descendants, merged nodes of §2.2 counted once, the root not counted), at the levels 0, 2, 3 and 4 (a level shows 0 when the command is invisible; level 1 equals level 0). The index column is the node index at level 4 (dedicated), which is the position in root order. Level is the command's own requirement (15 §1, 16 §3).

| Index | Root literal | Own level | Level 0 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|---|---|
| 1 | `advancement` | 2 | 0 | 25 | 25 | 25 |
| 2 | `attribute` | 2 | 0 | 24 | 24 | 24 |
| 3 | `execute` | 2 | 0 | 222 | 222 | 222 |
| 4 | `bossbar` | 2 | 0 | 39 | 39 | 39 |
| 5 | `clear` | 2 | 0 | 4 | 4 | 4 |
| 6 | `clone` | 2 | 0 | 123 | 123 | 123 |
| 7 | `compute` | 2 | 0 | 21 | 21 | 21 |
| 8 | `damage` | 2 | 0 | 10 | 10 | 10 |
| 9 | `data` | 2 | 0 | 752 | 752 | 752 |
| 10 | `datapack` | 2 | 0 | 14 | 14 | 17 |
| 11 | `debug` | 3 | 0 | 0 | 5 | 5 |
| 12 | `defaultgamemode` | 2 | 0 | 2 | 2 | 2 |
| 13 | `dialog` | 2 | 0 | 6 | 6 | 6 |
| 14 | `difficulty` | 2 | 0 | 5 | 5 | 5 |
| 15 | `effect` | 2 | 0 | 13 | 13 | 13 |
| 16 | `me` | 0 | 2 | 2 | 2 | 2 |
| 17 | `enchant` | 2 | 0 | 4 | 4 | 4 |
| 18 | `experience` | 2 | 0 | 15 | 15 | 15 |
| 19 | `xp` (alias of `experience`) | 2 | 0 | 1 | 1 | 1 |
| 20 | `fill` | 2 | 0 | 15 | 15 | 15 |
| 21 | `fillbiome` | 2 | 0 | 6 | 6 | 6 |
| 22 | `forceload` | 2 | 0 | 10 | 10 | 10 |
| 23 | `function` | 2 | 0 | 13 | 13 | 13 |
| 24 | `gamemode` | 2 | 0 | 3 | 3 | 3 |
| 25 | `gamerule` | 2 | 0 | 233 | 233 | 233 |
| 26 | `give` | 2 | 0 | 4 | 4 | 4 |
| 27 | `help` | 0 | 2 | 2 | 2 | 2 |
| 28 | `item` | 2 | 0 | 103 | 103 | 103 |
| 29 | `kick` | 3 | 0 | 0 | 3 | 3 |
| 30 | `kill` | 2 | 0 | 2 | 2 | 2 |
| 31 | `list` | 0 | 2 | 2 | 2 | 2 |
| 32 | `locate` | 2 | 0 | 7 | 7 | 7 |
| 33 | `loot` | 2 | 0 | 121 | 121 | 121 |
| 34 | `msg` | 0 | 3 | 3 | 3 | 3 |
| 35 | `tell` (alias of `msg`) | 0 | 1 | 1 | 1 | 1 |
| 36 | `w` (alias of `msg`) | 0 | 1 | 1 | 1 | 1 |
| 37 | `swing` | 2 | 0 | 8 | 8 | 8 |
| 38 | `particle` | 2 | 0 | 10 | 10 | 10 |
| 39 | `place` | 2 | 0 | 20 | 20 | 20 |
| 40 | `playsound` | 2 | 0 | 68 | 68 | 68 |
| 41 | `posteffect` | 2 | 0 | 11 | 11 | 11 |
| 42 | `random` | 0 | 5 | 16 | 16 | 16 |
| 43 | `reload` | 2 | 0 | 1 | 1 | 1 |
| 44 | `recipe` | 2 | 0 | 9 | 9 | 9 |
| 45 | `fetchprofile` | 2 | 0 | 7 | 7 | 7 |
| 46 | `return` | 2 | 0 | 4 | 4 | 4 |
| 47 | `ride` | 2 | 0 | 5 | 5 | 5 |
| 48 | `rotate` | 2 | 0 | 8 | 8 | 8 |
| 49 | `say` | 2 | 0 | 2 | 2 | 2 |
| 50 | `schedule` | 2 | 0 | 8 | 8 | 8 |
| 51 | `scoreboard` | 2 | 0 | 70 | 70 | 70 |
| 52 | `seed` | 2 | 0 | 1 | 1 | 1 |
| 53 | `version` | 2 | 0 | 1 | 1 | 1 |
| 54 | `setblock` | 2 | 0 | 7 | 7 | 7 |
| 55 | `spawnpoint` | 2 | 0 | 4 | 4 | 4 |
| 56 | `setworldspawn` | 2 | 0 | 3 | 3 | 3 |
| 57 | `spectate` | 2 | 0 | 3 | 3 | 3 |
| 58 | `spreadplayers` | 2 | 0 | 10 | 10 | 10 |
| 59 | `stopsound` | 2 | 0 | 26 | 26 | 26 |
| 60 | `stopwatch` | 2 | 0 | 10 | 10 | 10 |
| 61 | `summon` | 2 | 0 | 4 | 4 | 4 |
| 62 | `tag` | 2 | 0 | 7 | 7 | 7 |
| 63 | `team` | 2 | 0 | 45 | 45 | 45 |
| 64 | `teammsg` | 0 | 2 | 2 | 2 | 2 |
| 65 | `tm` (alias of `teammsg`) | 0 | 1 | 1 | 1 | 1 |
| 66 | `teleport` | 2 | 0 | 12 | 12 | 12 |
| 67 | `tp` (alias of `teleport`) | 2 | 0 | 1 | 1 | 1 |
| 68 | `tellraw` | 2 | 0 | 3 | 3 | 3 |
| 69 | `test` | 2 | 0 | 48 | 48 | 48 |
| 70 | `tick` | 3 | 0 | 0 | 12 | 12 |
| 71 | `time` | 2 | 0 | 30 | 30 | 30 |
| 72 | `title` | 2 | 0 | 14 | 14 | 14 |
| 73 | `trigger` | 0 | 6 | 6 | 6 | 6 |
| 74 | `waypoint` | 2 | 0 | 13 | 13 | 13 |
| 75 | `weather` | 2 | 0 | 7 | 7 | 7 |
| 76 | `worldborder` | 2 | 0 | 20 | 20 | 20 |
| 77 | `ban-ip` | 3 | 0 | 0 | 3 | 3 |
| 78 | `banlist` | 3 | 0 | 0 | 3 | 3 |
| 79 | `ban` | 3 | 0 | 0 | 3 | 3 |
| 80 | `deop` | 3 | 0 | 0 | 2 | 2 |
| 81 | `op` | 3 | 0 | 0 | 2 | 2 |
| 82 | `pardon` | 3 | 0 | 0 | 2 | 2 |
| 83 | `pardon-ip` | 3 | 0 | 0 | 2 | 2 |
| 84 | `perf` | 4 | 0 | 0 | 0 | 3 |
| 85 | `save-all` | 4 | 0 | 0 | 0 | 2 |
| 86 | `save-off` | 4 | 0 | 0 | 0 | 1 |
| 87 | `save-on` | 4 | 0 | 0 | 0 | 1 |
| 88 | `setidletimeout` | 3 | 0 | 0 | 2 | 2 |
| 89 | `stop` | 4 | 0 | 0 | 0 | 1 |
| 90 | `transfer` | 3 | 0 | 0 | 4 | 4 |
| 91 | `whitelist` | 3 | 0 | 0 | 9 | 9 |

Sum of the "Level 4" column: 2396; adding the root and subtracting the one merge between `execute` and `return` (§2.2) gives 2396, the count of §5.1. The levels 0, 2 and 3 are checked the same way (26, 2333, 2385).

Commands present in other selections or conditions:

| Root literal | Selection | Own level | Level 0 | Level 2 | Level 3 | Level 4 |
|---|---|---|---|---|---|---|
| `seed` | integrated | 0 | 1 | 1 | 1 | 1 |
| `version` | integrated | 0 | 1 | 1 | 1 | 1 |
| `publish` | integrated | 4 | 0 | 0 | 0 | 3 |
| `unpublish` | integrated | 4 | 0 | 0 | 0 | 1 |
| `jfr` | dedicated, if the profiler is available | 4 | 0 | 0 | 0 | 3 |

(`seed` and `version` in the dedicated table above are level 2 with one node each; in the integrated selection they are level 0 with one node each.)

### 6.2 Rule for pruning to a subset

Given a set of root literals (aliases count as roots) and a permission level L:

1. Take the visible roots of the set: a root is visible when L is at least its own level. The roots keep the order of the table in §6.1 (registration order); an alias keeps its redirect only if its target is also in the set (the alias is one node either way).
2. The packet node count is **1 + the sum of the per-command counts of the column for level L - 1 if both `execute` and `return` are in the set and L is at least 2** (their literals `run` are equal nodes and share one entry). No other merge crosses commands: all other merged classes (§2.2) lie inside `execute`.
3. The index of the visible roots is 1 to n in that order; the nodes below are numbered breadth first as in §4.4.
4. Inside a command nothing is pruned except by level: the hidden nodes of `random` (below level 2), `datapack create` (below level 4), `debug function` (always visible when `debug` is) follow §3.3.

The rule was verified against the full procedure of §4 on 300 random subsets at levels 0, 2, 3 and 4 (0 mismatches).

Worked examples (dedicated):

| Subset | Level | Count |
|---|---|---|
| `me`, `help`, `list`, `msg`, `tell`, `w`, `random`, `teammsg`, `tm`, `trigger` | 0 | 1 + 2 + 2 + 2 + 3 + 1 + 1 + 5 + 2 + 1 + 6 = **26** |
| the same plus `seed` and `version` at level 0 (integrated levels) | 0 | 26 + 1 + 1 = **28** |
| the same ten roots with `random` at level 2 (every `random` node visible) | 2 | 26 + (16 - 5) = **37** |
| all roots | 4 | **2396** |
| all roots without `data` and `gamerule` | 4 | 2396 - 752 - 233 = **1411** |

### 6.3 Developer-only commands (not in any normal tree)

Level and size (the root not counted): `chase` level 0, 8 nodes, `raid` level 3, 11 nodes, `debugpath` level 2, 2 nodes, `debugmobspawning` level 2, 17 nodes, `warden_spawn_tracker` level 2, 4 nodes, `spawn_armor_trims` level 2, 3 nodes, `serverpack` level 2, 7 nodes, `debugconfig` level 3, 8 nodes.

---

## 7. The node tree of every command

**Gap closed:** the node tree itself: for every command its literals, argument nodes with parser ids and property values, executable flags, redirects, requirements and suggestion providers.

### 7.1 Notation

One line per node, children indented two spaces under their parent (child order is the order of the lines). The tree is the unfiltered tree (all levels); lines marked `R` and everything below them are filtered out at the lower levels.

| Mark | Meaning |
|---|---|
| `name` | a literal node |
| `<name:parser#id(props)>` | an argument node with the parser name, parser id (05a) and the property values (empty parentheses are omitted when the parser has no properties). `integer`, `float`, `double`: `min=`, `max=` appear only when the bound differs from the type extreme (flag bits of §2.1); float values are Java float literals (the one non-integral lower bound, `1.0E-5`, is the float `1.0E-5f`, big-endian bytes `37 27 C5 AC`); `entity`: `single`, `players`; `score_holder`: `multiple`; `time`: `min=`; `string`: `word`, `phrase`, `greedy`; registry parsers: the registry key identifier |
| `x` | the node has a command (flag 0x04) |
| `R2`, `R3`, `R4` | the node has its own requirement of that level (flag 0x20) |
| `->/path` | redirect (flag 0x08) to the node with that path; `->/` is the root |
| `sug=ask`, `sug=available_sounds`, `sug=summonable_entities`, `sug=post_effects` | custom suggestion provider (flag 0x10) with the Identifier of §2.3 |
| `{Tn}` | the children of this node follow and are reused below |
| `{=Tn}` | the children of this node are identical to those of the node marked `{Tn}` earlier in the same command (same names, parsers, properties, flags, redirects, providers, and nested structure); they are not repeated. Labels are local to one command |

An argument node that is `x` and has `->/execute` is both executable and a redirect (flags 0x0C). The merge of §2.2 is not applied in these listings (each listing is the unmerged tree; its node count is given in the heading as "tree nodes", and the wire count is the one of §6.1).

### 7.2 `advancement` (level 2, 25 tree nodes)

```
advancement R2
  grant  {T1}
    <targets:entity#6(players)>
      only
        <advancement:resource_key#47(minecraft:advancement)> x
          <criterion:string#5(greedy)> x sug=ask
      from
        <advancement:resource_key#47(minecraft:advancement)> x
      until
        <advancement:resource_key#47(minecraft:advancement)> x
      through
        <advancement:resource_key#47(minecraft:advancement)> x
      everything x
  revoke  {=T1}
```

### 7.3 `attribute` (level 2, 24 tree nodes)

```
attribute R2
  <target:entity#6(single)>
    <attribute:resource#46(minecraft:attribute)>
      get x
        <scale:double#2> x
      base
        set
          <value:double#2> x
        get x
          <scale:double#2> x
        reset x
      modifier
        add
          <id:resource_location#36>
            <value:double#2>
              add_value x
              add_multiplied_base x
              add_multiplied_total x
        remove
          <id:resource_location#36> x sug=ask
        value
          get
            <id:resource_location#36> x sug=ask
              <scale:double#2> x
```

### 7.4 `execute` (level 2, 289 tree nodes, 222 wire nodes)

```
execute R2
  run ->/
  if  {T1}
    block
      <pos:block_pos#8>
        <block:block_predicate#13> x ->/execute
    biome
      <pos:block_pos#8>
        <biome:resource_or_tag#44(minecraft:worldgen/biome)> x ->/execute
    loaded
      <pos:block_pos#8> x ->/execute
    dimension
      <dimension:dimension#41> x ->/execute
    score
      <target:score_holder#31> sug=ask
        <targetObjective:objective#24>
          =
            <source:score_holder#31> sug=ask
              <sourceObjective:objective#24> x ->/execute
          <
            <source:score_holder#31> sug=ask
              <sourceObjective:objective#24> x ->/execute
          <=
            <source:score_holder#31> sug=ask
              <sourceObjective:objective#24> x ->/execute
          >
            <source:score_holder#31> sug=ask
              <sourceObjective:objective#24> x ->/execute
          >=
            <source:score_holder#31> sug=ask
              <sourceObjective:objective#24> x ->/execute
          matches
            <range:int_range#39> x ->/execute
    blocks
      <start:block_pos#8>
        <end:block_pos#8>
          <destination:block_pos#8>
            all x ->/execute
            masked x ->/execute
    entity
      <entities:entity#6> x ->/execute
    predicate
      <predicate:loot_predicate#53> x ->/execute
    function
      <name:function#37> ->/execute sug=ask
    stopwatch
      <id:resource_location#36> sug=ask
        <range:float_range#40> x ->/execute
    data
      entity
        <source:entity#6(single)>
          <path:nbt_path#23> x ->/execute
      block
        <source:block_pos#8>
          <path:nbt_path#23> x ->/execute
      storage
        <source:resource_location#36> sug=ask
          <path:nbt_path#23> x ->/execute
    items
      entity
        <source:entity#6>
          <slots:slot_source#57>
            <item_predicate:item_predicate#15> x ->/execute
      block
        <source:block_pos#8>
          <slots:slot_source#57>
            <item_predicate:item_predicate#15> x ->/execute
    slots
      entity
        <source:entity#6>
          <slots:slot_source#57> x ->/execute
      block
        <source:block_pos#8>
          <slots:slot_source#57> x ->/execute
  unless  {=T1}
  as
    <targets:entity#6> ->/execute
  at
    <targets:entity#6> ->/execute
  store
    result  {T2}
      score
        <targets:score_holder#31(multiple)> sug=ask
          <objective:objective#24> ->/execute
      bossbar
        <id:resource_location#36> sug=ask
          value ->/execute
          max ->/execute
      entity
        <target:entity#6(single)>  {T3}
          <path:nbt_path#23>
            int
              <scale:double#2> ->/execute
            float
              <scale:double#2> ->/execute
            short
              <scale:double#2> ->/execute
            long
              <scale:double#2> ->/execute
            double
              <scale:double#2> ->/execute
            byte
              <scale:double#2> ->/execute
      block
        <target:block_pos#8>  {=T3}
      storage
        <target:resource_location#36> sug=ask  {=T3}
    success  {=T2}
  positioned
    <pos:vec3#10> ->/execute
    as
      <targets:entity#6> ->/execute
    over
      <heightmap:heightmap#51> ->/execute
  rotated
    <rot:rotation#29> ->/execute
    as
      <targets:entity#6> ->/execute
  facing
    entity
      <targets:entity#6>
        <anchor:entity_anchor#38> ->/execute
    <pos:vec3#10> ->/execute
  align
    <axes:swizzle#32> ->/execute
  anchored
    <anchor:entity_anchor#38> ->/execute
  in
    <dimension:dimension#41> ->/execute
  summon
    <entity:resource#46(minecraft:entity_type)> ->/execute sug=summonable_entities
  on
    owner ->/execute
    leasher ->/execute
    target ->/execute
    attacker ->/execute
    vehicle ->/execute
    controller ->/execute
    origin ->/execute
    passengers ->/execute
```

### 7.5 `bossbar` (level 2, 39 tree nodes)

```
bossbar R2
  add
    <id:resource_location#36>
      <name:component#18> x
  remove
    <id:resource_location#36> x sug=ask
  list x
  set
    <id:resource_location#36> sug=ask
      name
        <name:component#18> x
      color
        pink x
        blue x
        red x
        green x
        yellow x
        purple x
        white x
      style
        progress x
        notched_6 x
        notched_10 x
        notched_12 x
        notched_20 x
      value
        <value:integer#3(min=0)> x
      max
        <max:integer#3(min=1)> x
      visible
        <visible:bool#0> x
      players x
        <targets:entity#6(players)> x
  get
    <id:resource_location#36> sug=ask
      value x
      max x
      visible x
      players x
```

### 7.6 `clear` (level 2, 4 tree nodes)

```
clear x R2
  <targets:entity#6(players)> x
    <item:item_predicate#15> x
      <maxCount:integer#3(min=0)> x
```

### 7.7 `clone` (level 2, 123 tree nodes)

```
clone R2
  <begin:block_pos#8>  {T1}
    <end:block_pos#8>
      <destination:block_pos#8> x  {T2}
        replace x
          force x
          move x
          normal x
        masked x
          force x
          move x
          normal x
        filtered  {T3}
          <filter:block_predicate#13> x
            force x
            move x
            normal x
        strict x
          replace x
            force x
            move x
            normal x
          masked x
            force x
            move x
            normal x
          filtered  {=T3}
      to
        <targetDimension:dimension#41>
          <destination:block_pos#8> x  {=T2}
  from
    <sourceDimension:dimension#41>
      <begin:block_pos#8>  {=T1}
```

### 7.8 `compute` (level 2, 21 tree nodes)

```
compute R2
  default  {T1}
    float
      <provider:context_float_provider#55> x
        <scale:float#1> x
    integer
      <provider:context_int_provider#56> x
  block
    <computePos:block_pos#8>  {=T1}
  entity
    <computeTarget:entity#6(single)>  {=T1}
```

### 7.9 `damage` (level 2, 10 tree nodes)

```
damage R2
  <target:entity#6(single)>
    <amount:float#1(min=0)> x
      <damageType:resource#46(minecraft:damage_type)> x
        at
          <location:vec3#10> x
        by
          <entity:entity#6(single)> x
            from
              <cause:entity#6(single)> x
```

### 7.10 `data` (level 2, 752 tree nodes)

```
data R2
  merge
    entity
      <target:entity#6(single)>
        <nbt:nbt_compound_tag#21> x
    block
      <target:block_pos#8>
        <nbt:nbt_compound_tag#21> x
    storage
      <target:resource_location#36> sug=ask
        <nbt:nbt_compound_tag#21> x
  get
    entity
      <target:entity#6(single)> x
        <path:nbt_path#23> x
          <scale:double#2> x
    block
      <target:block_pos#8> x
        <path:nbt_path#23> x
          <scale:double#2> x
    storage
      <target:resource_location#36> x sug=ask
        <path:nbt_path#23> x
          <scale:double#2> x
  remove
    entity
      <target:entity#6(single)>
        <path:nbt_path#23> x
    block
      <target:block_pos#8>
        <path:nbt_path#23> x
    storage
      <target:resource_location#36> sug=ask
        <path:nbt_path#23> x
  modify
    entity
      <target:entity#6(single)>  {T1}
        <targetPath:nbt_path#23>
          insert
            <index:integer#3>  {T2}
              from
                entity
                  <source:entity#6(single)> x
                    <sourcePath:nbt_path#23> x
                block
                  <source:block_pos#8> x
                    <sourcePath:nbt_path#23> x
                storage
                  <source:resource_location#36> x sug=ask
                    <sourcePath:nbt_path#23> x
              string
                entity
                  <source:entity#6(single)> x
                    <sourcePath:nbt_path#23> x
                      <start:integer#3> x
                        <end:integer#3> x
                block
                  <source:block_pos#8> x
                    <sourcePath:nbt_path#23> x
                      <start:integer#3> x
                        <end:integer#3> x
                storage
                  <source:resource_location#36> x sug=ask
                    <sourcePath:nbt_path#23> x
                      <start:integer#3> x
                        <end:integer#3> x
              compute
                default  {T3}
                  float
                    <provider:context_float_provider#55> x
                  integer
                    <provider:context_int_provider#56> x
                block
                  <computePos:block_pos#8>  {=T3}
                entity
                  <computeTarget:entity#6(single)>  {=T3}
              value
                <value:nbt_tag#22> x
          prepend  {=T2}
          append  {=T2}
          set  {=T2}
          merge  {=T2}
    block
      <target:block_pos#8>  {=T1}
    storage
      <target:resource_location#36> sug=ask  {=T1}
```

### 7.11 `datapack` (level 2, 17 tree nodes)

```
datapack R2
  enable
    <name:string#5(phrase)> x sug=ask
      after
        <existing:string#5(phrase)> x sug=ask
      before
        <existing:string#5(phrase)> x sug=ask
      last x
      first x
  disable
    <name:string#5(phrase)> x sug=ask
  list x
    available x
    enabled x
  create R4
    <id:string#5(phrase)>
      <description:component#18> x
```

### 7.12 `debug` (level 3, 5 tree nodes)

```
debug R3
  start x
  stop x
  function R3
    <name:function#37> x sug=ask
```

### 7.13 `defaultgamemode` (level 2, 2 tree nodes)

```
defaultgamemode R2
  <gamemode:gamemode#42> x
```

### 7.14 `dialog` (level 2, 6 tree nodes)

```
dialog R2
  show
    <targets:entity#6(players)>
      <dialog:dialog#58> x
  clear
    <targets:entity#6(players)> x
```

**Semantics (read in `DialogCommand`, `CommandResponseTracker`, `ResourceOrIdArgument`, `ServerPlayer.openDialog`).** The root requirement (level 2) covers both branches. `dialog show <targets> <dialog>` is executable at `<dialog>`, `dialog clear <targets>` at `<targets>`. `<targets>` is an entity selector for any number of players (`entity#6(players)`; an empty selection raises the selector's standard no-player error, 15). `<dialog>` is the `ResourceOrIdArgument` of the `dialog` registry (parser id 58): either an Identifier, which becomes a reference to that registry entry, or an inline definition written as SNBT, decoded with `Dialog.DIRECT_CODEC`; its error keys and suggestions (the registry's entries) are 15 §6.7.

*`show`.* For each selected player in the selector's order the server calls `ServerPlayer.openDialog(holder)`, which sends one `ClientboundShowDialogPacket(holder)` on the player's play connection (05b 0x8F: a registry reference as VarInt id + 1, an inline dialog as VarInt 0 followed by the network NBT of the definition) and counts that player with value 1. Nothing is stored on the server: it keeps no per-player dialog state and never learns what the client does with the packet. The result is the sum of the values, i.e. the number of players the packet was sent to. Feedback is sent once with broadcast **true**: when exactly one player was counted, `commands.dialog.show.single` (that player's display name; "Displayed dialog to %s"), otherwise `commands.dialog.show.multiple` (the count; "Displayed dialog to %s players"). The failure handler of the message set is absent, so a zero count would not fail (it cannot happen: the selector throws first).

*`clear`.* The same loop sends `ClientboundClearDialogPacket` (no fields, 05b 0x8E) to each target and counts it with value 1; result and feedback are the same with the keys `commands.dialog.clear.single` ("Cleared dialog for %s") and `commands.dialog.clear.multiple` ("Cleared dialog for %s players"), broadcast true.

Worked example: `/dialog clear @a` with three players online sends three Clear Dialog packets, returns 3 and reports "Cleared dialog for 3 players"; with one player online it returns 1 and reports "Cleared dialog for <name>". What a dialog screen shows (the three shipped definitions, their types and actions) and the client's handling of a Show Dialog for an unknown reference were not read here (Open question 12).

### 7.15 `difficulty` (level 2, 5 tree nodes)

```
difficulty x R2
  peaceful x
  easy x
  normal x
  hard x
```

### 7.16 `effect` (level 2, 13 tree nodes)

```
effect R2
  clear x
    <targets:entity#6> x
      <effect:resource#46(minecraft:mob_effect)> x
  give
    <targets:entity#6>
      <effect:resource#46(minecraft:mob_effect)> x
        <seconds:integer#3(min=1,max=1000000)> x
          <amplifier:integer#3(min=0,max=255)> x
            <hideParticles:bool#0> x
        infinite x
          <amplifier:integer#3(min=0,max=255)> x
            <hideParticles:bool#0> x
```

### 7.17 `me` (level 0, 2 tree nodes)

```
me
  <action:message#20> x
```

### 7.18 `enchant` (level 2, 4 tree nodes)

```
enchant R2
  <targets:entity#6>
    <enchantment:resource#46(minecraft:enchantment)> x
      <level:integer#3(min=0)> x
```

### 7.19 `experience` (level 2, 15 tree nodes)

```
experience R2
  add
    <target:entity#6(players)>
      <amount:integer#3> x
        points x
        levels x
  set
    <target:entity#6(players)>
      <amount:integer#3(min=0)> x
        points x
        levels x
  query
    <target:entity#6(single,players)>
      points x
      levels x
```

### 7.20 `fill` (level 2, 15 tree nodes)

```
fill R2
  <from:block_pos#8>
    <to:block_pos#8>
      <block:block_state#12> x
        outline x
        hollow x
        destroy x
        strict x
        replace x
          <filter:block_predicate#13> x
            outline x
            hollow x
            destroy x
            strict x
        keep x
```

### 7.21 `fillbiome` (level 2, 6 tree nodes)

```
fillbiome R2
  <from:block_pos#8>
    <to:block_pos#8>
      <biome:resource#46(minecraft:worldgen/biome)> x
        replace
          <filter:resource_or_tag#44(minecraft:worldgen/biome)> x
```

### 7.22 `forceload` (level 2, 10 tree nodes)

```
forceload R2
  add
    <from:column_pos#9> x
      <to:column_pos#9> x
  remove
    <from:column_pos#9> x
      <to:column_pos#9> x
    all x
  query x
    <pos:column_pos#9> x
```

### 7.23 `function` (level 2, 13 tree nodes)

```
function R2
  <name:function#37> x sug=ask
    <arguments:nbt_compound_tag#21> x
    with
      entity
        <source:entity#6(single)> x
          <path:nbt_path#23> x
      block
        <source:block_pos#8> x
          <path:nbt_path#23> x
      storage
        <source:resource_location#36> x sug=ask
          <path:nbt_path#23> x
```

### 7.24 `gamemode` (level 2, 3 tree nodes)

```
gamemode R2
  <gamemode:gamemode#42> x
    <target:entity#6(players)> x
```

### 7.25 `gamerule` (level 2, 233 tree nodes)

The `gamerule` node has no direct argument. For each enabled game rule (a `GameRuleCommand$1` visitor over `GameRules.visitGameRuleTypes`) it has **two literal children**: the plain id and the namespaced form `minecraft:<id>`; each of them is executable (query) and has one child, the argument `value`, which is executable (set). The argument type is the rule's own type object: `brigadier:bool` for boolean rules, `brigadier:integer` with the rule's bounds for integer rules. So every rule contributes 4 nodes, and none of them merges (the commands capture the rule and are distinct objects). Tree nodes: 1 + 4 x 58 = 233.

The rules are read from the 59 `registerBoolean` / `registerInteger` calls of `GameRules.<clinit>`, in registration order; 58 are enabled with the default feature set and the 59th, `max_minecart_speed`, needs the feature `minecart_improvements` (§4.6). The order of the children of the `gamerule` node is the iteration order of the rule map's key set, which was not traced (Open question 1); the table below is in registration order. Each rule: id, the argument `value` (bounds only when they differ from the type extreme), and whether it needs the feature. The default values are in 16 §13.

| Rule id | `value` argument | Needs feature `minecart_improvements` |
|---|---|---|
| `advance_time` | bool#0 | no |
| `advance_weather` | bool#0 | no |
| `allow_entering_nether_using_portals` | bool#0 | no |
| `block_drops` | bool#0 | no |
| `block_explosion_drop_decay` | bool#0 | no |
| `command_blocks_work` | bool#0 | no |
| `command_block_output` | bool#0 | no |
| `drowning_damage` | bool#0 | no |
| `elytra_movement_check` | bool#0 | no |
| `ender_pearls_vanish_on_death` | bool#0 | no |
| `entity_drops` | bool#0 | no |
| `fall_damage` | bool#0 | no |
| `fire_damage` | bool#0 | no |
| `fire_spread_radius_around_player` | integer#3(min=-1) | no |
| `forgive_dead_players` | bool#0 | no |
| `freeze_damage` | bool#0 | no |
| `global_sound_events` | bool#0 | no |
| `immediate_respawn` | bool#0 | no |
| `keep_inventory` | bool#0 | no |
| `lava_source_conversion` | bool#0 | no |
| `limited_crafting` | bool#0 | no |
| `locator_bar` | bool#0 | no |
| `log_admin_commands` | bool#0 | no |
| `max_block_modifications` | integer#3(min=1) | no |
| `max_command_forks` | integer#3(min=0) | no |
| `max_command_sequence_length` | integer#3(min=0) | no |
| `max_entity_cramming` | integer#3(min=0) | no |
| `max_minecart_speed` | integer#3(min=1,max=1000) | yes |
| `max_snow_accumulation_height` | integer#3(min=0,max=8) | no |
| `mob_drops` | bool#0 | no |
| `mob_explosion_drop_decay` | bool#0 | no |
| `mob_griefing` | bool#0 | no |
| `natural_health_regeneration` | bool#0 | no |
| `player_movement_check` | bool#0 | no |
| `players_nether_portal_creative_delay` | integer#3(min=0) | no |
| `players_nether_portal_default_delay` | integer#3(min=0) | no |
| `players_sleeping_percentage` | integer#3(min=0) | no |
| `projectiles_can_break_blocks` | bool#0 | no |
| `pvp` | bool#0 | no |
| `raids` | bool#0 | no |
| `random_tick_speed` | integer#3(min=0) | no |
| `reduced_debug_info` | bool#0 | no |
| `respawn_radius` | integer#3(min=0) | no |
| `send_command_feedback` | bool#0 | no |
| `show_advancement_messages` | bool#0 | no |
| `show_death_messages` | bool#0 | no |
| `spawner_blocks_work` | bool#0 | no |
| `spawn_mobs` | bool#0 | no |
| `spawn_monsters` | bool#0 | no |
| `spawn_patrols` | bool#0 | no |
| `spawn_phantoms` | bool#0 | no |
| `spawn_wandering_traders` | bool#0 | no |
| `spawn_wardens` | bool#0 | no |
| `spectators_generate_chunks` | bool#0 | no |
| `spread_vines` | bool#0 | no |
| `tnt_explodes` | bool#0 | no |
| `tnt_explosion_drop_decay` | bool#0 | no |
| `universal_anger` | bool#0 | no |
| `water_source_conversion` | bool#0 | no |

### 7.26 `give` (level 2, 4 tree nodes)

```
give R2
  <targets:entity#6(players)>
    <item:item_stack#14> x
      <count:integer#3(min=1)> x
```

### 7.27 `help` (level 0, 2 tree nodes)

```
help x
  <command:string#5(greedy)> x
```

### 7.28 `item` (level 2, 103 tree nodes)

```
item R2
  replace  {T1}
    entity
      <target:entity#6>  {T2}
        <slots:slot_source#57>
          from
            entity
              <source:entity#6>
                <sourceSlots:slot_source#57> x
                  <modifier:loot_modifier#54> x
            block
              <source:block_pos#8>
                <sourceSlots:slot_source#57> x
                  <modifier:loot_modifier#54> x
          with
            <item:item_stack#14> x
              <count:integer#3(min=1,max=99)> x
    block
      <target:block_pos#8>  {=T2}
  fill  {=T1}
  override  {=T1}
  modify
    entity
      <target:entity#6>
        <slots:slot_source#57>
          <modifier:loot_modifier#54> x
    block
      <target:block_pos#8>
        <slots:slot_source#57>
          <modifier:loot_modifier#54> x
```

### 7.29 `kick` (level 3, 3 tree nodes)

```
kick R3
  <targets:entity#6(players)> x
    <reason:message#20> x
```

### 7.30 `kill` (level 2, 2 tree nodes)

```
kill x R2
  <targets:entity#6> x
```

### 7.31 `list` (level 0, 2 tree nodes)

```
list x
  uuids x
```

### 7.32 `locate` (level 2, 7 tree nodes)

```
locate R2
  structure
    <structure:resource_or_tag_key#45(minecraft:worldgen/structure)> x
  biome
    <biome:resource_or_tag#44(minecraft:worldgen/biome)> x
  poi
    <poi:resource_or_tag#44(minecraft:point_of_interest_type)> x
```

### 7.33 `loot` (level 2, 121 tree nodes)

```
loot R2
  replace
    entity
      <entities:entity#6>  {T1}
        <slot:item_slot#34>
          fish  {T2}
            <loot_table:loot_table#52>  {T3}
              <pos:block_pos#8> x
                <tool:item_stack#14> x
                mainhand x
                offhand x
          loot
            <loot_table:loot_table#52> x
          kill
            <target:entity#6(single)> x
          mine  {=T3}
          <count:integer#3(min=0)>  {T4}
            fish  {=T2}
            loot
              <loot_table:loot_table#52> x
            kill
              <target:entity#6(single)> x
            mine  {=T3}
    block
      <targetPos:block_pos#8>  {=T1}
  insert
    <targetPos:block_pos#8>  {=T4}
  give
    <players:entity#6(players)>  {=T4}
  spawn
    <targetPos:vec3#10>  {=T4}
```

### 7.34 `msg` (level 0, 3 tree nodes)

```
msg
  <targets:entity#6(players)>
    <message:message#20> x
```

### 7.35 `swing` (level 2, 8 tree nodes)

```
swing x R2
  <targets:entity#6> x
    mainhand x
      <animation:swing_animation#60> x
        <duration:time#43(min=1)> x
    offhand x
      <animation:swing_animation#60> x
        <duration:time#43(min=1)> x
```

**Semantics (read in `SwingCommand`).** Every `x` node above is executable and the executable forms resolve their omitted parts as follows: `/swing` with **no target** swings the **executing entity** (`CommandSourceStack.getEntityOrException`, so a source without an entity, such as the console or a command block, fails with that exception) with the **main hand**, as a one-element target list; `/swing <targets>` swings the targets with the main hand; `/swing <targets> mainhand|offhand` chooses the hand; the animation `type` defaults to `SwingAnimation.DEFAULT`'s type and `duration` to its duration: `SwingAnimation.DEFAULT` is type `whack` with duration 6 (ticks); the three types are `none`, `whack`, `stab` (`SwingAnimationType` constants read). For each target that is a `LivingEntity` the command calls `LivingEntity.swing(hand, SwingAnimation(type, duration), updateSelf = true)` and counts it (non-living targets are skipped and not counted; the boolean returned by `swing`, false when the entity is already swinging, does not change the count). `LivingEntity.swing` starts the swing state only when it is able to (`SwingState.startIfAble` with `getModifiedSwingDuration(duration)`), and only then, on a server level, sends `ClientboundSwingAnimationPacket` to the players tracking the entity and, because `updateSelf` is true, to the entity itself when it is a player. Result: the **number of living targets counted** (each adds 1), so the result is 1 for `/swing` and for a single living target; feedback: error `commands.swing.failed.notliving` when none was counted, else the success message `commands.swing.success.single` (display name) when exactly one was counted and `commands.swing.success.multiple` (count) otherwise, sent with `sendSuccess(..., broadcast = true)`. (The state machine of the swing and the duration modification by effects are 54 section 2.)

### 7.36 `particle` (level 2, 10 tree nodes)

```
particle R2
  <name:particle#27> x
    <pos:vec3#10> x
      <delta:vec3#10>
        <speed:float#1(min=0)>
          <count:integer#3(min=0)> x
            force x
              <viewers:entity#6(players)> x
            normal x
              <viewers:entity#6(players)> x
```

### 7.37 `place` (level 2, 20 tree nodes)

```
place R2
  feature
    <feature:feature#59> x
      <pos:block_pos#8> x
  jigsaw
    <pool:resource_key#47(minecraft:worldgen/template_pool)>
      <target:resource_location#36>
        <max_depth:integer#3(min=1,max=20)> x
          <position:block_pos#8> x
  structure
    <structure:resource_key#47(minecraft:worldgen/structure)> x
      <pos:block_pos#8> x
  template
    <template:resource_location#36> x sug=ask
      <pos:block_pos#8> x
        <rotation:template_rotation#50> x
          <mirror:template_mirror#49> x
            <integrity:float#1(min=0,max=1)> x
              <seed:integer#3> x
                strict x
```

### 7.38 `playsound` (level 2, 68 tree nodes)

```
playsound R2
  <sound:resource_location#36> x sug=available_sounds
    master x  {T1}
      <targets:entity#6(players)> x
        <pos:vec3#10> x
          <volume:float#1(min=0)> x
            <pitch:float#1(min=0,max=2)> x
              <minVolume:float#1(min=0,max=1)> x
    music x  {=T1}
    record x  {=T1}
    weather x  {=T1}
    block x  {=T1}
    hostile x  {=T1}
    neutral x  {=T1}
    player x  {=T1}
    ambient x  {=T1}
    voice x  {=T1}
    ui x  {=T1}
```

### 7.39 `posteffect` (level 2, 11 tree nodes)

```
posteffect R2
  add
    <targets:entity#6(players)>
      <posteffect:resource_location#36> x sug=post_effects
  clear
    <targets:entity#6(players)> x
  list
    <target:entity#6(single,players)> x
  remove
    <targets:entity#6(players)>
      <posteffect:resource_location#36> x sug=post_effects
```

### 7.40 `random` (level 0, 16 tree nodes)

```
random
  value
    <range:int_range#39> x
      <sequence:resource_location#36> x R2 sug=ask
  roll
    <range:int_range#39> x
      <sequence:resource_location#36> x R2 sug=ask
  reset R2
    * x
      <seed:integer#3> x
        <includeWorldSeed:bool#0> x
          <includeSequenceId:bool#0> x
    <sequence:resource_location#36> x sug=ask
      <seed:integer#3> x
        <includeWorldSeed:bool#0> x
          <includeSequenceId:bool#0> x
```

**Semantics (read in `RandomCommand`, `RandomSequences`, `RandomSequence`, `RandomSupport`, `Mth.randomBetweenInclusive`, `MinecraftServer.getRandomSequence`, `SavedDataStorage`).** This section specifies the sequence generator and the seed flags. Levels: `value` and `roll` and their `<range>` nodes need none (level 0), the optional `<sequence>` node of both needs level 2, and the whole `reset` branch needs level 2 (§3.3). Parser ids: `<range>` is `int_range` (39), `<sequence>` is an Identifier (`resource_location`, 36), `<seed>` is a plain 32-bit `integer`, the two flags are `bool`.

*Draws (`value`, `roll`).* The value is drawn from the level random of the source's level (`ServerLevel.getRandom`) when no `<sequence>` is given, and from the stored sequence generator of that Identifier when one is (`MinecraftServer.getRandomSequence(id)`, below). The range is the `int_range` of 15 (a missing bound is the int minimum or maximum; a range whose lower bound exceeds the upper bound fails already at parsing, `MinMaxBounds.ERROR_SWAPPED`). Then, with `w = max - min` computed as a 64-bit number: `w = 0` raises `commands.random.error.range_too_small`; `w >= 2147483647` raises `commands.random.error.range_too_large`; otherwise the value is `nextInt(w + 1) + min` (32-bit arithmetic, `nextInt(bound)` as 10 §2.3 for a Xoroshiro generator). The tested condition is equality with zero; 16 §10.8's "max must be greater than min" is the same rule once the swapped case is excluded by the parser. The result is the drawn value. `value` sends `commands.random.sample.success` (value) to the source only (not broadcast); `roll` sends `commands.random.roll` (the source's display name, the value, min, max) to every player through `PlayerList.broadcastSystemMessage(message, false)`.

| Range text | Outcome |
|---|---|
| `1..6` | value in 1 to 6 |
| `5`, `5..5` | `range_too_small` (one value) |
| `..5` | min is -2147483648, `w` = 2147483653: `range_too_large` |
| `0..2147483647` | `w` = 2147483647: `range_too_large` |
| `1..2147483647` | `w` = 2147483646, bound 2147483647: allowed |

*The store.* All named sequences live in one world-wide object (`RandomSequences`, saved data type `random_sequences`) that holds three defaults and a map from Identifier to generator: `salt` (int, initial value 0), `includeWorldSeed` (initial true), `includeSequenceId` (initial true), and the generators. `get(id, worldSeed)` returns the stored generator of `id`, or creates it first from the three defaults as they are at that moment; `worldSeed` is `WorldOptions.seed` (the same number for every dimension). The creation formula is the one of 26 §4 item 5, restated here with the field names of the commands: `S = (includeWorldSeed ? worldSeed : 0) xor (long) salt` (the int salt is sign-extended); the 128-bit seed is `lo0 = S xor 0x6A09E667F3BCC909`, `hi0 = lo0 + 0x9E3779B97F4A7C15` (mod 2^64); when `includeSequenceId` is true both words are then xored with the two big-endian 64-bit halves of the MD5 of the UTF-8 text `namespace:path` of the Identifier (the same MD5 halves as 10 §2.4 `fromHashOf`, which xors them with the fixed words of a positional factory, whereas here they are xored with the seed-derived words `lo0` and `hi0`: `a` from bytes 0 to 7 into `lo0`, `b` from bytes 8 to 15 into `hi0`); finally both words are passed through `mixStafford13` (10 §2.2) and become the state `(lo, hi)` of a Xoroshiro128++ generator (the zero-pair replacement of 10 §2.1 applies). A generator keeps its state between calls, so the sequence continues where it stopped; the object returned by `get` is a wrapper that marks the store modified before each of its draws (`nextInt`, `nextInt(bound)`, `nextLong`, `nextBoolean`, `nextFloat`, `nextDouble`, `nextGaussian`) and before `setSeed`, `fork`, `forkPositional`.

*`reset` forms.* The grammar tail is `[<seed> [<includeWorldSeed> [<includeSequenceId>]]]` (every prefix is executable); an omitted flag counts as true. The `<seed>` argument is an `int` and is used as the **salt**, never as a world seed.

| Command | Effect on the store | Result | Message (all not broadcast) |
|---|---|---|---|
| `random reset *` | removes every stored generator; the three defaults stay as they are | the number of generators removed | `commands.random.reset.all.success` (count) |
| `random reset * <seed> [<iws> [<isi>]]` | first sets the defaults to (`seed`, `iws`, `isi`), then removes every generator (nothing is created now: each id is created again, with the new defaults, at its next `get`) | the number of generators removed | `commands.random.reset.all.success` (count) |
| `random reset <sequence>` | replaces (or creates) the generator of that id, built at once by the creation formula with the world seed of the source's level and the current defaults; the id is not checked against anything, so any Identifier makes a new sequence | 1 | `commands.random.reset.success` (the id as a text argument) |
| `random reset <sequence> <seed> [<iws> [<isi>]]` | same, but this one generator is built with salt `seed` and flags `iws`, `isi`; the stored defaults do not change | 1 | `commands.random.reset.success` |

*Persistence (inferred from the code that was read, marked where it is).* `SavedDataStorage` writes only saved data that is marked modified (`collectDirtyTagsToSave` keeps the entries whose dirty flag is set and clears it). `clear`, `reset` and `setSeedDefaults` of the store contain no call that marks it modified (read); only the wrapper draws above do, and the storage marks an object once when it first creates it (`SavedDataStorage.computeIfAbsent` calls `set`, which marks it). So a `random reset` that is followed by no draw from any sequence is not written by the next save (inferred: only the reading of the save selection was done, not the stop path); an implementation that writes the store at every save also satisfies every observable command result. The file is `<world>/data/minecraft/random_sequences.dat` (gzip NBT written with `NbtIo.writeCompressed`; 07 §10): root compound `{data: {...}, DataVersion: int}` with `data` = `salt` (int), `include_world_seed` (bool, optional when reading, default true), `include_sequence_id` (bool, optional, default true; whether the writer omits a value equal to the default is not decoded, Open question 10) and `sequences`, a compound from the id text (`namespace:path`) to a compound `{source: long array of exactly 2: [lo, hi]}`, the generator state as signed 64-bit numbers (read: `RandomSequence.CODEC` has the single field `source`; `Xoroshiro128PlusPlus.CODEC` is a two-element long stream and `NbtOps.createLongList` makes a long array). This answers the `random_sequences.dat` part of 07 Open question 20.

*Suggestions.* The server-side provider behind the three `<sequence>` nodes (`sug=ask`) offers the text `namespace:path` of every id in the store at that moment (no tooltip; `SharedSuggestionProvider.suggest` on a list of strings, so the prefix rule of 15 §14 applies). A world with no stored sequence offers nothing. (Loot-table draws create sequences too, 26 §4 item 4, so ids such as `minecraft:blocks/stone` appear once such a table has rolled.)

*Worked examples (computed from the formulas above with a script over the formulas; not read from the artifact as results, so a test built on them also tests the reading).* Draws are `random value 1..6` repeated, i.e. `nextInt(6) + 1`. The pair is the state right after creation, before the first draw. MD5 of `minecraft:test` is `1a2b64f5d3bdb4612e96d0a422fe68a7`.

| World seed | salt | iws | isi | id | State `(lo, hi)` after creation | First five values |
|---|---|---|---|---|---|---|
| 0 | 0 | false | false | any | `3564B439CD1E1F16`, `63CFC62A2B097592` (agrees with the seed-0 pair of 10 §2.7) | 6, 2, 1, 2, 6 |
| 0 | 0 | true | true | `minecraft:test` | `8E7593F5564F3759`, `1496374F91108179` | 5, 5, 1, 1, 5 |
| 12345 | 0 | true | true | `minecraft:test` | `AC66966A683673D2`, `F190065EED58B14A` | 5, 6, 4, 3, 2 |
| 12345 | 5 | true | false | `minecraft:test` | `E0BD326CDA796318`, `2C97D84E2C530A74` | 5, 6, 5, 1, 3 |
| 12345 | 7 | false | true | `minecraft:test` | `D17224413E9C4A17`, `A9550D65B79B742E` | 5, 3, 4, 1, 3 |
| 0 | -1 | false | false | any | `FE766AB13AFAB784`, `28B159DEFD9C7FBA` | 4, 3, 2, 6, 2 |
| 12345 | 0 | true | true | `minecraft:blocks/stone` (MD5 `77c5c643ddbe0f28ee760458118d8b9d`) | `D8564274A204C9C9`, `ED0DF1666B1CD0F5` | 6, 4, 4, 5, 3 |

Command sequence test (computed from the table above, not read as a result; world seed 12345, fresh store): `/random reset * 7 false` sets salt 7, `includeWorldSeed` false, `includeSequenceId` true and returns 0 (nothing stored); the next `/random value 1..6 minecraft:test` creates the generator of the fifth row above and answers 5; the next three answers are 3, 4, 1. `/random reset *` then returns 1 and leaves the defaults at (7, false, true); `/random reset minecraft:test` returns 1 and creates the generator again at its start state, so the next three answers are again 5, 3, 4. `/random reset minecraft:test 0 true true` returns 1 and builds the third row's generator without changing the stored defaults.

### 7.41 `reload` (level 2, 1 tree node)

```
reload x R2
```

### 7.42 `recipe` (level 2, 9 tree nodes)

```
recipe R2
  give
    <targets:entity#6(players)>
      <recipe:resource_key#47(minecraft:recipe)> x
      * x
  take
    <targets:entity#6(players)>
      <recipe:resource_key#47(minecraft:recipe)> x
      * x
```

### 7.43 `fetchprofile` (level 2, 7 tree nodes)

```
fetchprofile R2
  name
    <name:string#5(greedy)> x
  id
    <id:uuid#61> x
  entity
    <entity:entity#6(single)> x
```

### 7.44 `return` (level 2, 4 tree nodes)

```
return R2
  <value:integer#3> x
  fail x
  run ->/
```

### 7.45 `ride` (level 2, 5 tree nodes)

```
ride R2
  <target:entity#6(single)>
    mount
      <vehicle:entity#6(single)> x
    dismount x
```

### 7.46 `rotate` (level 2, 8 tree nodes)

```
rotate R2
  <target:entity#6(single)>
    <rotation:rotation#29> x
    facing
      entity
        <facingEntity:entity#6(single)> x
          <facingAnchor:entity_anchor#38> x
      <facingLocation:vec3#10> x
```

### 7.47 `say` (level 2, 2 tree nodes)

```
say R2
  <message:message#20> x
```

### 7.48 `schedule` (level 2, 8 tree nodes)

```
schedule R2
  function
    <function:function#37> sug=ask
      <time:time#43(min=0)> x
        append x
        replace x
  clear
    <function:resource_location#36> x sug=ask
```

### 7.49 `scoreboard` (level 2, 70 tree nodes)

```
scoreboard R2
  objectives
    list x
    add
      <objective:string#5(word)>
        <criteria:objective_criteria#25> x
          <displayName:component#18> x
    modify
      <objective:objective#24>
        displayname
          <displayName:component#18> x
        rendertype
          integer x
          hearts x
        displayautoupdate
          <value:bool#0> x
        numberformat x  {T1}
          blank x
          fixed
            <contents:component#18> x
          styled
            <style:style#19> x
    remove
      <objective:objective#24> x
    setdisplay
      <slot:scoreboard_slot#30> x
        <objective:objective#24> x
  players
    list x
      <target:score_holder#31> x sug=ask
    set
      <targets:score_holder#31(multiple)> sug=ask
        <objective:objective#24>
          <score:integer#3> x
    get
      <target:score_holder#31> sug=ask
        <objective:objective#24> x
    add
      <targets:score_holder#31(multiple)> sug=ask
        <objective:objective#24>
          <score:integer#3(min=0)> x
    remove
      <targets:score_holder#31(multiple)> sug=ask
        <objective:objective#24>
          <score:integer#3(min=0)> x
    reset
      <targets:score_holder#31(multiple)> x sug=ask
        <objective:objective#24> x
    enable
      <targets:score_holder#31(multiple)> sug=ask
        <objective:objective#24> x sug=ask
    display
      name
        <targets:score_holder#31(multiple)> sug=ask
          <objective:objective#24> x
            <name:component#18> x
      numberformat
        <targets:score_holder#31(multiple)> sug=ask
          <objective:objective#24> x  {=T1}
    operation
      <targets:score_holder#31(multiple)> sug=ask
        <targetObjective:objective#24>
          <operation:operation#26>
            <source:score_holder#31(multiple)> sug=ask
              <sourceObjective:objective#24> x
```

### 7.50 `seed` (level 2, 1 tree node)

```
seed x R2
```

### 7.51 `version` (level 2, 1 tree node)

```
version x R2
```

### 7.52 `setblock` (level 2, 7 tree nodes)

```
setblock R2
  <pos:block_pos#8>
    <block:block_state#12> x
      destroy x
      keep x
      replace x
      strict x
```

### 7.53 `spawnpoint` (level 2, 4 tree nodes)

```
spawnpoint x R2
  <targets:entity#6(players)> x
    <pos:block_pos#8> x
      <rotation:rotation#29> x
```

### 7.54 `setworldspawn` (level 2, 3 tree nodes)

```
setworldspawn x R2
  <pos:block_pos#8> x
    <rotation:rotation#29> x
```

### 7.55 `spectate` (level 2, 3 tree nodes)

```
spectate x R2
  <target:entity#6(single)> x
    <player:entity#6(single,players)> x
```

### 7.56 `spreadplayers` (level 2, 10 tree nodes)

```
spreadplayers R2
  <center:vec2#11>
    <spreadDistance:float#1(min=0)>
      <maxRange:float#1(min=1)>
        <respectTeams:bool#0>
          <targets:entity#6> x
        under
          <maxHeight:integer#3>
            <respectTeams:bool#0>
              <targets:entity#6> x
```

### 7.57 `stopsound` (level 2, 26 tree nodes)

```
stopsound R2
  <targets:entity#6(players)> x
    *
      <sound:resource_location#36> x sug=available_sounds
    master x
      <sound:resource_location#36> x sug=available_sounds
    music x
      <sound:resource_location#36> x sug=available_sounds
    record x
      <sound:resource_location#36> x sug=available_sounds
    weather x
      <sound:resource_location#36> x sug=available_sounds
    block x
      <sound:resource_location#36> x sug=available_sounds
    hostile x
      <sound:resource_location#36> x sug=available_sounds
    neutral x
      <sound:resource_location#36> x sug=available_sounds
    player x
      <sound:resource_location#36> x sug=available_sounds
    ambient x
      <sound:resource_location#36> x sug=available_sounds
    voice x
      <sound:resource_location#36> x sug=available_sounds
    ui x
      <sound:resource_location#36> x sug=available_sounds
```

### 7.58 `stopwatch` (level 2, 10 tree nodes)

```
stopwatch R2
  create
    <id:resource_location#36> x
  query
    <id:resource_location#36> x sug=ask
      <scale:double#2> x
  restart
    <id:resource_location#36> x sug=ask
  remove
    <id:resource_location#36> x sug=ask
```

### 7.59 `summon` (level 2, 4 tree nodes)

```
summon R2
  <entity:resource#46(minecraft:entity_type)> x sug=summonable_entities
    <pos:vec3#10> x
      <nbt:nbt_compound_tag#21> x
```

### 7.60 `tag` (level 2, 7 tree nodes)

```
tag R2
  <targets:entity#6>
    add
      <name:string#5(word)> x
    remove
      <name:string#5(word)> x sug=ask
    list x
```

### 7.61 `team` (level 2, 45 tree nodes)

```
team R2
  list x
    <team:team#33> x
  add
    <team:string#5(word)> x
      <displayName:component#18> x
  remove
    <team:team#33> x
  empty
    <team:team#33> x
  join
    <team:team#33> x
      <members:score_holder#31(multiple)> x sug=ask
  leave
    <members:score_holder#31(multiple)> x sug=ask
  modify
    <team:team#33>
      displayName
        <displayName:component#18> x
      color
        reset x
        <value:team_color#16> x
      friendlyFire
        <allowed:bool#0> x
      seeFriendlyInvisibles
        <allowed:bool#0> x
      nametagVisibility  {T1}
        never x
        hideForOtherTeams x
        hideForOwnTeam x
        always x
      deathMessageVisibility  {=T1}
      collisionRule
        never x
        pushOwnTeam x
        pushOtherTeams x
        always x
      prefix
        <prefix:component#18> x
      suffix
        <suffix:component#18> x
```

### 7.62 `teammsg` (level 0, 2 tree nodes)

```
teammsg
  <message:message#20> x
```

### 7.63 `teleport` (level 2, 12 tree nodes)

```
teleport R2
  <location:vec3#10> x
  <destination:entity#6(single)> x
  <targets:entity#6>
    <location:vec3#10> x
      <rotation:rotation#29> x
      facing
        entity
          <facingEntity:entity#6(single)> x
            <facingAnchor:entity_anchor#38> x
        <facingLocation:vec3#10> x
    <destination:entity#6(single)> x
```

### 7.64 `tellraw` (level 2, 3 tree nodes)

```
tellraw R2
  <targets:entity#6(players)>
    <message:component#18> x
```

### 7.65 `test` (level 2, 48 tree nodes)

```
test R2
  run
    <tests:resource_selector#48(minecraft:test_instance)> x sug=ask  {T1}
      <numberOfTimes:integer#3(min=0)> x
        <untilFailed:bool#0> x
          <rotationSteps:integer#3> x
            <testsPerRow:integer#3> x
  runmultiple
    <tests:resource_selector#48(minecraft:test_instance)> x sug=ask
      <amount:integer#3> x
  runthese x
    <numberOfTimes:integer#3(min=0)> x
      <untilFailed:bool#0> x
  runclosest x
    <numberOfTimes:integer#3(min=0)> x
      <untilFailed:bool#0> x
  runthat x
    <numberOfTimes:integer#3(min=0)> x
      <untilFailed:bool#0> x
  runfailed x
    <onlyRequiredTests:bool#0> x  {=T1}
    <numberOfTimes:integer#3(min=0)> x
      <untilFailed:bool#0> x
        <rotationSteps:integer#3> x
          <testsPerRow:integer#3> x
  verify
    <tests:resource_selector#48(minecraft:test_instance)> x sug=ask
  locate
    <tests:resource_selector#48(minecraft:test_instance)> x sug=ask
  resetclosest x
  resetthese x
  resetthat x
  clearthat x
  clearthese x
  clearall x
    <radius:integer#3> x
  stop x
  pos x
    <var:string#5(word)> x
  create
    <id:resource_location#36> x
      <width:integer#3> x
        <height:integer#3>
          <depth:integer#3> x
```

**Semantics (the behaviour of this command is document 55, restated here only where stated).** Level: the root `test` is level 2 and no subcommand adds a check; the command is registered unconditionally (55 §2.1). The tree above has the 17 literals that exist without `SharedConstants.IS_RUNNING_IN_IDE`; `export`, `exportclosest`, `exportthese` and `exportthat` (55 §4.1) exist only when that flag is set and are not in the 48-node tree (counted: 1 root + `run` 6 + `runmultiple` 3 + `runthese` 3 + `runclosest` 3 + `runthat` 3 + `runfailed` 10 + `verify` 2 + `locate` 2 + the three `reset*` 3 + `clearthat` and `clearthese` 2 + `clearall` 2 + `stop` 1 + `pos` 2 + `create` 5 = 48). Every `x` node is a complete command, so any prefix of an argument chain executes with the later values at their defaults (55 §4.1: `numberOfTimes` absent = one try, `untilFailed` false, `rotationSteps` 0, `testsPerRow` 8, `amount` absent = one pass, `create` size 5 x 5 x 5; `create <id> <width>` makes a cube; `create <id> <width> <height>` is not a command, because the `height` node has no `x`).

| Branch | What it does | Result | Feedback and errors (keys in 55 §9.1) |
|---|---|---|---|
| `run`, `runmultiple`, `runthese`, `runclosest`, `runthat`, `runfailed` | first step `stopTests` (clears the global ticker, which halts any running tests; read as the first call of `TestCommand.run`), then build the test list (new areas on a grid for selector tests, in place for existing test instance blocks), start a runner (55 §4.3, §5) | 1 when started, 0 when the list is empty | empty list: `commands.test.no_tests` is **plain success feedback** (`sendSuccess` with broadcast false), not a failure and not an error, and the result is 0; otherwise the failed-test memory is cleared and `commands.test.run.running` (count) is sent, not broadcast |
| `verify` | first step `stopTests`, then stress-runs each selected test (55 §5.8); read: `TestCommand.verify` has no empty-list message | 1 | none |
| `locate` | lists the test instance blocks of the selected tests with click-to-teleport coordinates; **no `stopTests` step** (read: `TestCommand.locate` begins with the `locate.started` message) | the number of located test instance blocks (the count of `commands.test.locate.done`; read: `locate` returns that counter after the broadcast success; 55 §4.3 states the same) | `commands.test.locate.started` (system message), `.found` per block, `.done` (count, broadcast); none: error `commands.test.error.no_test_instances` |
| `resetclosest`, `resetthese`, `resetthat` | first step `stopTests`, then re-place the template of the nearest (15 blocks), nearby (250) or looked-at test instance blocks | the count | `commands.test.reset.success` (count, broadcast); none: error `commands.test.clear.error.no_tests` |
| `clearthat`, `clearthese`, `clearall [<radius>]` | first step `stopTests`, then clear the test area, remove its barriers and destroy the block; `clearall` radius default 250, clamped to 0 to 1024 | the count | `commands.test.clear.success` (count, broadcast); none: error `commands.test.clear.error.no_tests` |
| `stop` | `stopTests` only: halts the running tests (clears the global ticker) | 1 | none |
| `pos [<var>]` | needs a player; prints the looked-at position relative to its test area and sends Game Test Highlight Pos (05a 0x29) | 1 | `commands.test.relative_position` with a copy-to-clipboard action; errors `commands.test.error.no_test_containing_pos`, `.test_instance_not_found` |
| `create <id> [<width> [<height> <depth>]]` | creates an empty test area (a bedrock floor layer) on the grid | 1 | `commands.test.create.success` (broadcast); error `commands.test.error.too_large` (argument 48) when any size exceeds 48 |

Read in `TestCommand`: the constants 15 (nearby radius), 250 (full search radius and default clear radius), 1024 (maximum clear radius), 3 (position offset from the player), the default size 5 x 5 x 5, and in `createNewStructure` the limit test `size > 48` on each of the three sizes (so 48 passes), the result 1 with broadcast success; and in `stopTests` the global ticker clear and the result 1. All of this agrees with 55 §4. The server-side provider behind the four `sug=ask` selector nodes is `TestCommand.suggestTestInstanceIds` (its content was not decoded, Open question 6).

### 7.66 `tick` (level 3, 12 tree nodes)

```
tick R3
  query x
  rate
    <rate:float#1(min=1,max=10000)> x sug=ask
  step x
    stop x
    <time:time#43(min=1)> x sug=ask
  sprint
    stop x
    <time:time#43(min=1)> x sug=ask
  unfreeze x
  freeze x
```

### 7.67 `time` (level 2, 30 tree nodes)

```
time R2
  set
    <time:time#43(min=0)> x
    <timemarker:resource_location#36> x sug=ask
  add
    <time:time#43(min=-2147483648)> x
  pause x
  resume x
  rate
    <rate:float#1(min=1.0E-5,max=1000)> x
  query
    time x
    <timeline:resource#46(minecraft:timeline)> x sug=ask
      repetition x
    gametime x
  of
    <clock:resource#46(minecraft:world_clock)>
      set
        <time:time#43(min=0)> x
        <timemarker:resource_location#36> x sug=ask
      add
        <time:time#43(min=-2147483648)> x
      pause x
      resume x
      rate
        <rate:float#1(min=1.0E-5,max=1000)> x
      query
        time x
        <timeline:resource#46(minecraft:timeline)> x sug=ask
          repetition x
```

### 7.68 `title` (level 2, 14 tree nodes)

```
title R2
  <targets:entity#6(players)>
    clear x
    reset x
    title
      <title:component#18> x
    subtitle
      <title:component#18> x
    actionbar
      <title:component#18> x
    times
      <fadeIn:time#43(min=0)>
        <stay:time#43(min=0)>
          <fadeOut:time#43(min=0)> x
```

### 7.69 `trigger` (level 0, 6 tree nodes)

```
trigger
  <objective:objective#24> x sug=ask
    add
      <value:integer#3> x
    set
      <value:integer#3> x
```

### 7.70 `waypoint` (level 2, 13 tree nodes)

```
waypoint R2
  list x
  modify
    <waypoint:entity#6(single)>
      color
        <color:team_color#16> x
        hex
          <color:hex_color#17> x
        reset x
      style
        reset x
        set
          <style:resource_location#36> x
```

### 7.71 `weather` (level 2, 7 tree nodes)

```
weather R2
  clear x
    <duration:time#43(min=1)> x
  rain x
    <duration:time#43(min=1)> x
  thunder x
    <duration:time#43(min=1)> x
```

### 7.72 `worldborder` (level 2, 20 tree nodes)

```
worldborder R2
  add
    <distance:double#2(min=-59999968,max=59999968)> x
      <time:time#43(min=0)> x
  set
    <distance:double#2(min=-59999968,max=59999968)> x
      <time:time#43(min=0)> x
  center
    <pos:vec2#11> x
  damage
    amount
      <damagePerBlock:float#1(min=0)> x
    buffer
      <distance:float#1(min=0)> x
  get x
  warning
    distance
      <distance:integer#3(min=0)> x
    time
      <time:time#43(min=0)> x
```

### 7.73 `ban-ip` (level 3, 3 tree nodes)

```
ban-ip R3
  <target:string#5(word)> x
    <reason:message#20> x
```

### 7.74 `banlist` (level 3, 3 tree nodes)

```
banlist x R3
  ips x
  players x
```

### 7.75 `ban` (level 3, 3 tree nodes)

```
ban R3
  <targets:game_profile#7> x
    <reason:message#20> x
```

### 7.76 `deop` (level 3, 2 tree nodes)

```
deop R3
  <targets:game_profile#7> x sug=ask
```

### 7.77 `op` (level 3, 2 tree nodes)

```
op R3
  <targets:game_profile#7> x sug=ask
```

### 7.78 `pardon` (level 3, 2 tree nodes)

```
pardon R3
  <targets:game_profile#7> x sug=ask
```

### 7.79 `pardon-ip` (level 3, 2 tree nodes)

```
pardon-ip R3
  <target:string#5(word)> x sug=ask
```

### 7.80 `perf` (level 4, 3 tree nodes)

```
perf R4
  start x
  stop x
```

### 7.81 `save-all` (level 4, 2 tree nodes)

```
save-all x R4
  flush x
```

### 7.82 `save-off` (level 4, 1 tree node)

```
save-off x R4
```

### 7.83 `save-on` (level 4, 1 tree node)

```
save-on x R4
```

### 7.84 `setidletimeout` (level 3, 2 tree nodes)

```
setidletimeout R3
  <minutes:integer#3(min=0)> x
```

### 7.85 `stop` (level 4, 1 tree node)

```
stop x R4
```

### 7.86 `transfer` (level 3, 4 tree nodes)

```
transfer R3
  <hostname:string#5(phrase)> x
    <port:integer#3(min=1,max=65535)> x
      <players:entity#6(players)> x
```

### 7.87 `whitelist` (level 3, 9 tree nodes)

```
whitelist R3
  on x
  off x
  list x
  add
    <targets:game_profile#7> x sug=ask
  remove
    <targets:game_profile#7> x sug=ask
  reload x
```

### 7.88 Alias nodes

Each alias is a literal with a redirect and no children (flags 0x09, or 0x29 when it has its own requirement). Their position in root order is in §6.1.

```
xp R2 ->/experience
tell ->/msg
w ->/msg
tm ->/teammsg
tp R2 ->/teleport
```

### 7.89 `publish` and `unpublish` (level 4, integrated selection only; 3 and 1 tree nodes)

Read in `PublishCommand` and `UnpublishCommand`: both literals require `Commands.LEVEL_OWNERS` (level 4) and are registered only by the integrated selection (§3.4, §6.1). In the notation of §7.1 (parser ids from §5.3: `bool` 0, `integer` 3):

```
publish x R4
  <allowCommands:bool#0> x
    <port:integer#3(min=0,max=65535)> x
unpublish x R4
```

All three `publish` nodes and `unpublish` are executable (flag bit 4 set). Counts: 3 nodes (`publish`, `allowCommands`, `port`) and 1 node (`unpublish`), matching §6.1. With these two listings the fixtures for the integrated levels 2 to 4 can be generated from this section.

**Semantics (read).** The three forms of `publish` all end in one helper that takes the port and the `allowCommands` flag:

| Form | Port | `allowCommands` |
|---|---|---|
| `publish` | `HttpUtil.getAvailablePort()` (a free port chosen at that moment) | false |
| `publish <allowCommands>` | `HttpUtil.getAvailablePort()` | the argument |
| `publish <allowCommands> <port>` | the argument (0 to 65535) | the argument |

The helper, in order: (1) if `MinecraftServer.isPublished()` is true and `MinecraftServer.getPort()` is greater than -1, it fails with `commands.publish.alreadyPublished.lan` (the current port as the argument; English "Local game is already hosted on port %s"); (2) it calls `MinecraftServer.publishServer(LAN, allowCommands, port)`; when that returns false it fails with `commands.publish.failed` ("Unable to host local game"); (3) otherwise it sends `commands.publish.started.lan` ("Local game hosted on port %s"; the argument is the port as text wrapped by `ComponentUtils.copyOnClickText`, so clicking it copies the port number) to the source with broadcast true, and the **result is the port**. The effects inside `publishServer` (opening the listener, the game mode and the command flag it applies) were not read (Open question 11).

`unpublish` has one form: it calls `MinecraftServer.unpublishServer()`; when that returns false it fails with `commands.unpublish.notPublished` ("No multiplayer game published"); otherwise it sends `commands.unpublish.success` ("Multiplayer game is now unpublished") with broadcast true and the result is 1. The same keys and texts are in 16 §11.15.

---

## 8. Suggestion tooltips

**Gap closed:** where the optional tooltip of a command suggestion exists, the packet layout, and which providers return one.

### 8.1 The Command Suggestions packet (0x0F)

Re-read from `ClientboundCommandSuggestionsPacket` and its `Entry` record; 05a states the same layout:

| Field | Type | Notes |
|---|---|---|
| Transaction id | VarInt | echoes the request id |
| Start | VarInt | start of the replaced range (counted in the typed line, including the leading `/`) |
| Length | VarInt | length of the replaced range |
| Entries | VarInt count, then entries | no maximum on the wire (the server cuts the list to 1000 before sending, 15 §14.1) |
| Entry text | String (the codec's default maximum, 32767) | the suggestion text |
| Entry tooltip | Optional, trusted text component | a Boolean, then the component in the network form of 00 when present |

On the way out the packet turns each Brigadier suggestion's tooltip message into a component (`ComponentUtils.fromMessage`: a message that already is a component is kept, any other message becomes a literal text component). On the way in, a missing tooltip becomes "no tooltip". Per-entry ranges and the integer-versus-text distinction of Brigadier suggestions are not on the wire (15 §14.2).

### 8.2 What the client does with a tooltip

In `CommandSuggestions$SuggestionsList.extractRenderState` the rows are drawn with the selected row yellow (0xFFFFFF00) and the others gray (0xFFAAAAAA). While the mouse pointer is over the rows (a local flag the method sets when the pointer is inside a row), the tooltip of the **currently selected** suggestion (if it has one) is queued for the next frame at the pointer position (`setTooltipForNextFrame`, after `ComponentUtils.fromMessage`). The narration of a suggestion adds the key `narration.suggestion.tooltip` when a tooltip exists. There is no other client use of tooltips.

### 8.3 Which suggestions have tooltips

The Brigadier call that adds a suggestion with a tooltip (`SuggestionsBuilder.suggest(String, Message)`) is made from exactly three classes of the artifact; no other class of the jar calls it (checked by scanning the constant pool of every class of the jar for the method descriptor). The integer form `suggest(int, Message)` is called by none.

| Source | Tooltip | Where it runs |
|---|---|---|
| `EntitySelectorParser.fillSelectorSuggestions`: the six selector heads | `@p` `argument.entity.selector.nearestPlayer`; `@a` `argument.entity.selector.allPlayers`; `@r` `argument.entity.selector.randomPlayer`; `@s` `argument.entity.selector.self`; `@e` `argument.entity.selector.allEntities`; `@n` `argument.entity.selector.nearestEntity`. Translatable components, translated by the client (the language texts were not copied here; a server may omit tooltips) | The parser adds the six heads, in this order and without a prefix test, only when the source's permission set holds the atom `commands/entity_selectors` (level 2 or more, 15 §2.3) and only at the start of an entity argument or just after a bare `@` (inferred from the two parser states `suggestNameOrSelector` and `suggestSelector`, both read). The `entity` (6) nodes carry no custom provider, and neither does `ban <targets>` (`game_profile`); for these the **client**'s dispatcher runs the type's own suggestion code (15a §6.1: a node without a custom provider asks its type; `EntityArgument.listSuggestions` and `GameProfileArgument.listSuggestions` call the parser's `fillSuggestions`, read). The other five `game_profile` nodes (`deop`, `op`, `pardon` and `whitelist add|remove`, `<targets>`) carry `sug=ask`, so the server answers for them with that provider (§8.4), not with the type with the permission level the client last heard (15 §2.2); no packet is needed |
| `EntitySelectorOptions.suggestNames`: the option names | the option's description component, key `argument.entity.options.<name>.description` (table below) | the same parser, in its states after the opening bracket and after a comma (`suggestOptionsKey`, `suggestOptionsKeyOrClose`); the text is the option name followed by `=` (the concatenation recipe is read); an option is offered only when its `canUse` test passes for the parser (the tests themselves are in 15 §7.5); `entity` and `game_profile` nodes: on the client |
| `SharedSuggestionProvider.suggest` and `suggestResource` (the overloads that take a tooltip function) | the provider-supplied component | the only caller outside the helper class itself is `SuggestionProviders` (below) |

Only one registered provider uses the tooltip helper: `minecraft:summonable_entities`. It lists every entity type the client's registry marks summonable and enabled for the feature flags, with the identifier as text and as tooltip the entity type's `getDescription()` (a translatable component built from the type's description id, for example the name shown in the language, texts not read here). It runs on the client (15 §14.4), so no tooltip for it ever travels in a packet.

**What the server sends.** A server answers only requests for nodes with `minecraft:ask_server` (§2.3). Of the 114 such nodes, the only providers that produce tooltips are those of the `score_holder` nodes (27 nodes, in `execute`, `scoreboard` and `team`): `ScoreHolderArgument.SUGGEST_SCORE_HOLDERS` runs the entity-selector parser with the requesting source's permission, so its answer contains the six selector heads (when the source holds the selector atom), the option names after `@x[`, and the player names (no tooltip). Every other `ask` provider (§8.4) lists plain texts without tooltips. A server that omits the selector heads or sends no tooltips is protocol-valid; the loss is only the hover text.

At level 0 the tree has one `ask` node (`trigger <objective>`) and no `score_holder` node, so a level 0 session sees no tooltip at all: the `msg` and `teammsg` `entity` nodes would offer heads only with the selector atom, which level 0 does not hold.

**Option names** (registration order of `EntitySelectorOptions.bootStrap`; each has the tooltip key `argument.entity.options.<name>.description`, a translatable component; the language texts are not reproduced):

| # | Suggestion text |
|---|---|
| 1 | `name=` |
| 2 | `distance=` |
| 3 | `level=` |
| 4 | `x=` |
| 5 | `y=` |
| 6 | `z=` |
| 7 | `dx=` |
| 8 | `dy=` |
| 9 | `dz=` |
| 10 | `x_rotation=` |
| 11 | `y_rotation=` |
| 12 | `limit=` |
| 13 | `sort=` |
| 14 | `gamemode=` |
| 15 | `team=` |
| 16 | `type=` |
| 17 | `tag=` |
| 18 | `nbt=` |
| 19 | `scores=` |
| 20 | `advancements=` |
| 21 | `predicate=` |

### 8.4 Origin of the `ask_server` providers

The server-side provider behind each `sug=ask` node (the field or lambda that defines it; the provider code itself was not decoded except `ScoreHolderArgument.SUGGEST_SCORE_HOLDERS`, so only the field names tell what a provider is about):

| Provider (defining class, field or lambda) | Nodes | Commands |
|---|---|---|
| `ScoreHolderArgument.SUGGEST_SCORE_HOLDERS` (read, §8.3) | 27 | `execute`, `scoreboard`, `team` |
| `StorageDataAccessor.SUGGEST_STORAGE` | 39 | `data`, `execute`, `function` |
| `BossBarCommands.SUGGEST_BOSS_BAR` | 5 | `bossbar`, `execute` |
| `FunctionCommand.SUGGEST_FUNCTION` | 5 | `debug`, `execute`, `function`, `schedule` |
| `StopwatchCommand.SUGGEST_STOPWATCHES` | 5 | `execute`, `stopwatch` |
| `TestCommand.suggestTestInstanceIds` | 4 | `test` |
| `RandomCommand.suggestRandomSequence` | 3 | `random` |
| `DataPackCommand` lambdas (two) | 4 | `datapack` |
| `TimeCommand.addClockNodes` lambdas (two) | 4 | `time` |
| `TickCommand` lambdas (three) | 3 | `tick` |
| `AdvancementCommands` lambdas (two) | 2 | `advancement` |
| `AttributeCommand` lambdas (two) | 2 | `attribute` |
| `WhitelistCommand` lambdas (two) | 2 | `whitelist` |
| one lambda each: `DeOpCommands`, `OpCommand`, `PardonCommand`, `PardonIpCommand`, `PlaceCommand`, `ScheduleCommand`, `ScoreboardCommand`, `TagCommand`, `TriggerCommand` | 1 each (9) | `deop`, `op`, `pardon`, `pardon-ip`, `place`, `schedule`, `scoreboard`, `tag`, `trigger` |

Total 114. What each of these lists was not decoded (Open question 6); the tree fact the client needs is only that the node carries `minecraft:ask_server`.

---

## 9. Vanilla counts against the stand-in counts and a 28-node tree

**Gap closed:** what node counts a vanilla tree has at level 0 and level 4, how they relate to counts that appear in project documents, and what a fixture has to check.

Project documents mention trees of 6 and 90 nodes (the retired stand-in command set, §9.3) and a tree of 28 nodes for a level-0 player. This section states what the jar's tree gives for those cases.

### 9.1 What the jar says

| Case | Nodes |
|---|---|
| Level 0 (and 1), dedicated | **26** |
| Level 0 (and 1), integrated | **28** |
| Level 4, dedicated (all registered commands, no `jfr`) | **2396** |
| Level 4, integrated | 2360 |

The numbers 6 and 90 are not the node count of any vanilla tree: a vanilla level 0 tree has 26 or 28 nodes and a vanilla level 4 tree has at least 2360.

### 9.2 Where 28 can come from

Two different compositions give 28, and the jar admits only one as vanilla:

| Composition | Count | Vanilla? |
|---|---|---|
| the integrated level-0 tree: the 25 non-root nodes of the dedicated level-0 tree plus `seed` and `version` | 1 + 25 + 1 + 1 = **28** | yes: this is exactly the tree the integrated selection sends (§10.2) |
| the dedicated level-0 tree plus the two `<sequence>` nodes of `random value` and `random roll`, as 16 §10.8 describes them at level 0 | 26 + 2 = **28** | no: the jar requires level 2 for those two nodes (§3.3); a level 0 player must not receive them |

A 28-node level-0 tree therefore matches vanilla only if its non-root nodes are the listing of §10.2. The count alone cannot tell the two compositions apart; the node listing decides (Open question 4).

### 9.3 The stand-in counts

Project document 09 §3.3 says: "The 29-command stand-in set and its 90-node tree are retired (README S69, S70)" (as 09 cites them), and standin-content §16 lists the invented names of the retired set (for example `howto`, `roster`, `murmur`) with the standard command each became. A 90-node tree of invented commands is therefore a documented, retired design, not a count of the jar's commands, and the jar contradicts both 6 and 90 as vanilla counts (§9.1). No document says what a 6-node tree was (Open question 3).

### 9.4 Expected counts and what a correct fixture checks

16 lists every registered command with its level (16 §3) but does not say which commands the project implements. Therefore:

- The vanilla tree for the commands 16 lists at level 0 is §10.1 (dedicated) or §10.2 (integrated). The per-command counts of §6.1 give the sum for any subset: the level 0 subset above sums to 26.
- The vanilla tree for all commands at level 4 is 2396 nodes (dedicated); for a subset use §6.2. Any other count at level 4 is a count of a subset of commands or of reduced grammars, which the per-command table lets one test.

A correct fixture for level 0 checks, in this order:

1. the node count (26 dedicated, 28 integrated) and root index 0;
2. node order = §4.4 breadth-first numbering (the root's children are 1 to 10 or 12 in registration order: `me`, `help`, `list`, `msg`, `tell`, `w`, `random`, `[seed`, `version]`, `teammsg`, `tm`, `trigger`);
3. the flag byte of every node (the table of §10.1): the aliases `tell`, `w`, `tm` are 0x09 (literal + redirect) with no children; `help` and `list` are 0x05 (executable); `me`, `msg`, `random`, `teammsg`, `trigger` are 0x01; no node has the restricted bit (0x20) at level 0;
4. the parsers and properties: `msg <targets>` is `entity` (6) with property byte 0x02 (players only); `me <action>`, `msg ... <message>`, `teammsg <message>` are `message` (20); `help <command>` is `string` (5) with kind 2 (greedy); `random value|roll <range>` are `int_range` (39); `trigger <objective>` is `objective` (24) with the Identifier `minecraft:ask_server` (flag 0x16 = argument + executable + custom suggestions); `trigger ... add|set <value>` are `integer` (3) with property byte 0x00;
5. no `sequence` node and no `reset` branch under `random`.

A level 4 fixture checks the count (2396 for all commands), the invariants of §5.2 (1414 executable, 78 redirect, 86 restricted, 131 custom-suggestion nodes), and the root order of §6.1.

---

## 10. Worked listings and fixture checks

**Gap closed:** byte-checkable listings of the level-0 packets (dedicated and integrated) and the invariants of larger trees.

### 10.1 Level 0, dedicated: 26 nodes

Columns: node index, flags byte, children (node indices), redirect index, name, parser id and name with property values, custom suggestion Identifier. Index 0 is the root.

| Index | Flags | Children | Redirect | Name | Parser |
|---|---|---|---|---|---|
| 0 | 0x00 | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] |  |  |  |
| 1 | 0x01 | [11] |  | me |  |
| 2 | 0x05 | [12] |  | help |  |
| 3 | 0x05 | [13] |  | list |  |
| 4 | 0x01 | [14] |  | msg |  |
| 5 | 0x09 | [] | 4 | tell |  |
| 6 | 0x09 | [] | 4 | w |  |
| 7 | 0x01 | [15, 16] |  | random |  |
| 8 | 0x01 | [17] |  | teammsg |  |
| 9 | 0x09 | [] | 8 | tm |  |
| 10 | 0x01 | [18] |  | trigger |  |
| 11 | 0x06 | [] |  | action | 20 message |
| 12 | 0x06 | [] |  | command | 5 string (greedy) |
| 13 | 0x05 | [] |  | uuids |  |
| 14 | 0x02 | [19] |  | targets | 6 entity (players) |
| 15 | 0x01 | [20] |  | value |  |
| 16 | 0x01 | [21] |  | roll |  |
| 17 | 0x06 | [] |  | message | 20 message |
| 18 | 0x16 | [22, 23] |  | objective | 24 objective sug=minecraft:ask_server |
| 19 | 0x06 | [] |  | message | 20 message |
| 20 | 0x06 | [] |  | range | 39 int_range |
| 21 | 0x06 | [] |  | range | 39 int_range |
| 22 | 0x01 | [24] |  | add |  |
| 23 | 0x01 | [25] |  | set |  |
| 24 | 0x06 | [] |  | value | 3 integer |
| 25 | 0x06 | [] |  | value | 3 integer |

Packet payload after the packet id (VarInt 0x10), 265 bytes (derived by applying the layout of §2.1 to the table above; not a captured packet):

```
1a000a0102030405060708090a01010b026d6505010c0468656c7005010d046c69737401010e036d73670900040474656c6c090004017701020f100672616e646f6d010111077465616d6d736709000802746d0101120774726967676572060006616374696f6e14060007636f6d6d616e6405020500057575696473020113077461726765747306020101140576616c756501011504726f6c6c0600076d6573736167651416021617096f626a65637469766518146d696e6563726166743a61736b5f7365727665720600076d6573736167651406000572616e67652706000572616e676527010118036164640101190373657406000576616c7565030006000576616c7565030000
```

### 10.2 Level 0, integrated: 28 nodes

`seed` and `version` are inserted between `random` and `teammsg` (their registration position), which shifts the indices of everything after them.

| Index | Flags | Children | Redirect | Name | Parser |
|---|---|---|---|---|---|
| 0 | 0x00 | [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] |  |  |  |
| 1 | 0x01 | [13] |  | me |  |
| 2 | 0x05 | [14] |  | help |  |
| 3 | 0x05 | [15] |  | list |  |
| 4 | 0x01 | [16] |  | msg |  |
| 5 | 0x09 | [] | 4 | tell |  |
| 6 | 0x09 | [] | 4 | w |  |
| 7 | 0x01 | [17, 18] |  | random |  |
| 8 | 0x05 | [] |  | seed |  |
| 9 | 0x05 | [] |  | version |  |
| 10 | 0x01 | [19] |  | teammsg |  |
| 11 | 0x09 | [] | 10 | tm |  |
| 12 | 0x01 | [20] |  | trigger |  |
| 13 | 0x06 | [] |  | action | 20 message |
| 14 | 0x06 | [] |  | command | 5 string (greedy) |
| 15 | 0x05 | [] |  | uuids |  |
| 16 | 0x02 | [21] |  | targets | 6 entity (players) |
| 17 | 0x01 | [22] |  | value |  |
| 18 | 0x01 | [23] |  | roll |  |
| 19 | 0x06 | [] |  | message | 20 message |
| 20 | 0x16 | [24, 25] |  | objective | 24 objective sug=minecraft:ask_server |
| 21 | 0x06 | [] |  | message | 20 message |
| 22 | 0x06 | [] |  | range | 39 int_range |
| 23 | 0x06 | [] |  | range | 39 int_range |
| 24 | 0x01 | [26] |  | add |  |
| 25 | 0x01 | [27] |  | set |  |
| 26 | 0x06 | [] |  | value | 3 integer |
| 27 | 0x06 | [] |  | value | 3 integer |

Payload, 284 bytes (derived, not captured):

```
1c000c0102030405060708090a0b0c01010d026d6505010e0468656c7005010f046c697374010110036d73670900040474656c6c0900040177010211120672616e646f6d0500047365656405000776657273696f6e010113077465616d6d736709000a02746d0101140774726967676572060006616374696f6e14060007636f6d6d616e6405020500057575696473020115077461726765747306020101160576616c756501011704726f6c6c0600076d6573736167651416021819096f626a65637469766518146d696e6563726166743a61736b5f7365727665720600076d6573736167651406000572616e67652706000572616e67652701011a0361646401011b0373657406000576616c7565030006000576616c7565030000
```

### 10.3 Encoded examples

- `list` (index 3 of §10.1): flags 0x05 (literal, executable), one child index 13: `05 01 0d 04 6c 69 73 74` (flags, child count, child, name length, `list`).
- `tell` (index 5): flags 0x09, no children, redirect 4: `09 00 04 04 74 65 6c 6c`.
- `<targets>` of `msg` (index 14): flags 0x02, one child 19, name `targets`, parser 6, property 0x02: `02 01 13 07 74 61 72 67 65 74 73 06 02`.
- `<objective>` of `trigger` (index 18): flags 0x16, children 22 and 23, name `objective`, parser 24, no properties, Identifier `minecraft:ask_server`: `16 02 16 17 09 6f 62 6a 65 63 74 69 76 65 18 14 6d 69 6e 65 63 72 61 66 74 3a 61 73 6b 5f 73 65 72 76 65 72`.
- `<value>` of `trigger add` (index 24): flags 0x06, name `value`, parser 3, property byte 0x00: `06 00 05 76 61 6c 75 65 03 00`.

### 10.4 Invariants of the larger trees

Counts any implementation can check without the full listing (dedicated, §5.2): level 2: 1116 literal, 1216 argument, 1371 executable, 78 redirect, 66 restricted, 121 custom suggestion; level 4: 1157 literal, 1238 argument, 1414 executable, 78 redirect, 86 restricted, 131 custom suggestion. Redirect targets at level 4 (nodes of the unmerged tree): `/execute` 109, `/` 2, `/msg` 2, and one each `/experience`, `/teammsg`, `/teleport`.

---

## Open questions

1. **Children order of the `gamerule` node.** The visitor walks `GameRuleMap.keySet()`; `GameRuleMap` holds a fastutil `Reference2ObjectMap` created as a `Reference2ObjectOpenHashMap` (read). The order of that key set is a hash order (that a `Reference2...` map hashes keys by object identity, so the order is not stable between runs, is recalled, not verified). The artifact therefore does not fix the order of the 116 literal children of `gamerule` or the node indices below them: a fixture must not depend on it, and an implementer may use the registration order of the table in §7. The count (233 nodes, 4 per rule) does not depend on it.
2. **`jfr` presence.** `/jfr` (3 nodes, level 4) is registered when `jdk.jfr` is in the runtime layer and `FlightRecorder.isAvailable()` is true: a property of the JVM running the server, not of the artifact. The reference count excludes it; with it the level-4 count is 2399.
3. **The 6-node tree.** 09 §3.3 describes a 90-node stand-in tree as retired; nothing in the documents or the jar says what a 6-node tree was. Neither number is a vanilla count (§9.1). The jar could not answer this.
4. **Composition of a 28-node level-0 tree.** The count alone cannot distinguish the integrated level-0 tree from the dedicated level-0 tree plus the two `<sequence>` nodes (§9.2); the node listing is needed. The jar could not answer this.
5. **Other enabled feature flags.** The trees are for the default flag set (`vanilla`); the flags `trade_rebalance`, `redstone_experiments` and `minecart_improvements` exist. Read: of all command classes only `GameRuleCommand.register` consults the enabled feature set while the tree is built (the other uses, in `DataPackCommand`, are in executions and suggestion providers), and the only rule gated by a non-default flag is `max_minecart_speed` (`minecart_improvements`, +4 nodes). A world that enables other flags changes suggestions (summonable entities, registry-backed ids), not nodes.
6. **Behaviour of the `ask` providers.** §8.4 names the provider behind each node; what each one lists was not decoded (only the `score_holder` provider was read far enough to say it carries tooltips). `RandomCommand.suggestRandomSequence` was decoded (§7.40: the text of every stored sequence id, no tooltip); the other providers are not decoded.
7. **Tooltip texts of `summonable_entities`.** The tooltip is the entity type's description component (read: `getDescription()` builds a translatable component from the type's description id); the id strings (for example the exact key form `entity.<namespace>.<name>`) were not read here.
8. **fastutil `Object2IntOpenHashMap` key comparison (recalled, not verified).** The packet constructor creates the map with the no-argument constructor (read) and then looks nodes up by their own `equals` and `hashCode` (read: the calls are `containsKey`, `put`, `getInt` on the node objects). That the default strategy of this fastutil class is `equals` and `hashCode` is recalled, not verified: the library is not in the artifact. The node counts of §5 (68 merged entries) depend on it; a decoder is unaffected either way.
9. **Bare `/publish`** (closed): the zero-argument form uses a free port and `allowCommands` false, and the message keys of `publish` and `unpublish` were read (§7.89). Only the effects inside `MinecraftServer.publishServer` remain, as Open question 11.
10. **Writer of the optional flags of `random_sequences.dat`** (§7.40): whether the writer omits `include_world_seed` and `include_sequence_id` when they equal the default true (the codec declares them optional with a default; the library that decides this is not in the artifact), so an implementation must accept both forms.
11. **Inside `MinecraftServer.publishServer(scope, allowCommands, port)`** (§7.89): opening the LAN listener, the game mode and the command flag it applies, and what `unpublishServer` tears down were not read; only the two commands were.
12. **Dialog content** (§7.14): the three shipped dialog definitions and the client's handling of a Show Dialog for an unknown registry reference or a malformed inline definition were not read; only the command, the argument and the two packets were.
