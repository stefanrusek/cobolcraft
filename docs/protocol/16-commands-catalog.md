# Commands catalog (every command registered by the 26.3 server)

| Item | Value |
|---|---|
| Covers | The complete list of commands the 26.3 server registers, with, for each command, the grammar (every literal and argument branch, argument types, permission level), behaviour, result values, every feedback and error message key with its English text, and side effects. Also the gamerule table, aliases and the dev/debug availability table |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)); the jar is client-only but contains the integrated server's `net.minecraft.commands.*` and `net.minecraft.server.commands.*` classes and `data/minecraft/` |
| Method | Static reading of the shipped bytecode (`javap -c -p`), with no execution; message texts from `assets/minecraft/lang/en_us.json` in the same jar |
| Companion | The command framework (parser, every argument type, selectors, `execute` grammar, permission model, feedback rules) is in 15-commands-framework.md. This document cross-references it by topic as "15 framework: <topic>" and does not repeat it. Per-command rows give only what is specific to that command |

## Table of contents

1. [How to read this document](#1-how-to-read-this-document)
2. [Registration and availability (dev/debug table)](#2-registration-and-availability)
3. [Index: command, permission level, section](#3-index)
4. [Player and game state](#4-player-and-game-state): gamemode, defaultgamemode, difficulty, gamerule, time, weather, seed, version, setworldspawn, spawnpoint, worldborder, tick
5. [Entities and movement](#5-entities-and-movement): kill, teleport/tp, spreadplayers, spectate, rotate, ride, damage, tag, summon, effect, enchant, attribute, experience/xp, swing, waypoint
6. [Items and inventory](#6-items-and-inventory): give, clear, item, loot, recipe, advancement
7. [World editing](#7-world-editing): setblock, fill, fillbiome, clone, place, forceload, locate, particle, playsound, stopsound
8. [Chat and display](#8-chat-and-display): say, me, msg/tell/w, teammsg/tm, tellraw, title, bossbar, list, help, dialog, posteffect
9. [Scoreboard and teams](#9-scoreboard-and-teams): scoreboard, team, trigger
10. [Data, functions and flow](#10-data-functions-and-flow): data, execute, function, schedule, return, random, compute, stopwatch, datapack, reload
11. [Server administration](#11-server-administration): op, deop, ban, ban-ip, pardon, pardon-ip, banlist, whitelist, kick, save-all, save-on, save-off, stop, publish, unpublish, setidletimeout, transfer, perf, jfr, debug, serverpack, fetchprofile
12. [Dev and debug-only commands](#12-dev-and-debug-only-commands): test, chase, raid, debugpath, debugmobspawning, warden_spawn_tracker, spawn_armor_trims, debugconfig
13. [Gamerule table](#13-gamerule-table)
14. [Aliases](#14-aliases)
15. [Worked examples](#15-worked-examples)
16. [Validation](#16-validation)
17. [Open questions](#17-open-questions)

---

## 1. How to read this document

**Evidence labels.** Unlabelled statements were read from the artifact (class, message key or data file). "(inferred)" means deduced from a call sequence or a message key. "(recalled, not verified)" means the statement comes from memory of other versions or the wiki, was not read in this round, and is listed in section 17; it must not be relied on without a new clean-room round. Grammar branches, permission levels and message keys with English texts are read throughout.

**Permission levels.** `Commands` defines five checks: `LEVEL_ALL` (0, always passes), `LEVEL_MODERATORS` (1), `LEVEL_GAMEMASTERS` (2), `LEVEL_ADMINS` (3), `LEVEL_OWNERS` (4). In this version no command requires level 1. A node's `requires` is evaluated against the source's permission set; how the set is built for players, the console and command blocks is in 15 framework: permission model. Where a sub-branch has a different level from its root, the section says so (only `random reset` and `datapack create` do).

**Level summary of the registered set.** Level 0: `help`, `list`, `me`, `msg` (`tell`, `w`), `teammsg` (`tm`), `trigger`, `random value`, `random roll`, and in an integrated (single-player/LAN host) server `seed` and `version`. Level 2: everything else not listed here, including `gamemode`, `give`, `tp`, `time`, `gamerule`, `execute`, `fill`. Level 3: `ban`, `ban-ip`, `banlist`, `pardon`, `pardon-ip`, `op`, `deop`, `whitelist`, `kick`, `setidletimeout`, `tick`, `transfer`, `debug`, `debugconfig`, `raid`. Level 4: `stop`, `save-all`, `save-on`, `save-off`, `publish`, `unpublish`, `perf`, `jfr`, `datapack create`.

**Argument shorthand** (the full definition of each is in 15 framework: argument types):

| Shorthand | Meaning |
|---|---|
| `<targets>` | entity selector or name/UUID, any number of entities |
| `<players>` | selector resolving to players only (offline names are not accepted) |
| `<target>` / `<entity>` | selector resolving to exactly one entity (error if more) |
| `<player>` | exactly one player |
| `<profiles>` | game-profile argument: a player name (online or not) or a selector resolving to players |
| `<pos>` / `<vec3>` | block position (integers, `~` and `^` allowed) / precise position (doubles) |
| `<vec2>` | x and z doubles |
| `<rot>` | yaw and pitch |
| `<time>` | integer or float with optional unit suffix `d`, `s`, `t` (ticks); a minimum may apply and is written `time(min)` |
| `<id>` | namespaced identifier (`minecraft:` is implied when no namespace is given) |
| `<component>` | JSON/SNBT text component |
| `<message>` | greedy string with embedded selectors (`@a`, `@p` ...) resolved when run |
| `<resource>` | registry entry by identifier |

**Result and success.** Every executable node returns an integer "result" (used by `execute store result`, `return run` and command blocks) and succeeds or fails. Success is "the command ran without throwing"; failure is a thrown error whose message is shown in red. Each section gives the result value. The second argument of every `sendSuccess` / `sendFeedback` call is the broadcast flag: when true the message is also relayed to other operators and the console as far as the `send_command_feedback`/`log_admin_commands` gamerules and source settings allow (15 framework: feedback rules). In the tables below **B** means that flag is true and **Q** that it is false (sent to the invoking source only). Every B/Q mark in this document was extracted from the bytecode of the corresponding `sendSuccess`/`sendFeedback` call (the key, or the tracker response field, was matched to the flag constant pushed immediately before the call), except `commands.random.roll`, which is sent through `PlayerList.broadcastSystemMessage(message, false)` to every player (its boolean is the overlay parameter, not a feedback flag).

**Tracker helper (`CommandResponseTracker`).** Several multi-target commands share one counting scheme. A tracker holds, for the targets processed so far: the number of tracked elements, the sum of their integer values (`totalValue`), the number of elements whose value is non-zero, and the first element of each kind when there is exactly one. `track(element, int value)` adds one element with that value; `track(element)` uses value 1; `track(element, boolean ok)` uses value 1 for true and 0 for false (this is what `effect give`, `effect clear` and similar use: an entity the effect was not applied to is still an element, with value 0). There are two counting modes (`ElementType`): **NON_ZERO** (the default of every `sendFeedback` overload) counts only elements with a non-zero value, and **ANY** counts every tracked element. When the feedback is sent: (1) the count of the chosen mode is computed; (2) if it is zero the command fails with the "failed" message of its message set (the `...failed` keys listed per command); for `advancement` and `clear` this failure check is a separate dispatch on the ANY count made before the feedback; (3) if the mode's count is exactly one the `single` message is sent with that one element (its display name), otherwise the `multiple` message is sent with the count; (4) the message is sent with the broadcast flag of the call; (5) the command result is the sum of all tracked values (`totalValue`), whichever mode was used. Where ANY is used (read): `scoreboard players add`, `remove` and `operation` pass ANY inside `sendFeedback` (3 sites), so for them the failure check and the single/multiple choice both use the ANY count. `advancement` (3 sites) and `clear` (1 site) use ANY only in a separate `dispatch(ANY, ...)` call that throws the failure message before any feedback is sent; their success `sendFeedback` calls (3 for advancement, 1 for clear, which also sends the test message) use NON_ZERO, so for them the failure is decided by the ANY count and the single/multiple choice of the success message by the NON_ZERO count. `DebugCommand$TraceCustomExecutor` also uses ANY in a dispatch. Every other tracker call uses NON_ZERO. A consequence for `tag list`: each entity is tracked with its own tag count as the value, so the NON_ZERO count is the number of entities that have at least one tag; when no target has any tag the no-tags message set is dispatched with a NON_ZERO count of 0, which selects the `commands.tag.list.multiple.empty` text with count 0 even for a single entity (the `single.empty` text is not reachable this way).

**Message arguments.** `%s` in an English text is a positional argument; numbers are formatted by the text component (integers in decimal, floating-point values with the formatting the command states). Entity and player arguments are the target's display name (team-coloured, clickable). Identifiers are written in full with namespace.

---

## 2. Registration and availability

`Commands` registers commands in a fixed order, listed here, then installs the result consumer used for `execute store`. A registration is **unconditional** unless a condition is stated.

| Registered (in order) | Condition |
|---|---|
| advancement, attribute, execute, bossbar, clear, clone, compute, damage, data, datapack, debug, defaultgamemode, dialog, difficulty, effect, me, enchant, experience (+`xp`), fill, fillbiome, forceload, function, gamemode, gamerule, give, help, item, kick, kill, list, locate, loot, msg (+`tell`, `w`), swing, particle, place, playsound, posteffect, random, reload, recipe, fetchprofile, return, ride, rotate, say, schedule, scoreboard | always |
| seed | always; permission level 2 unless the selection is `INTEGRATED`, then level 0 |
| version | always; permission level 2 unless the selection is `INTEGRATED`, then level 0 |
| setblock, spawnpoint, setworldspawn, spectate, spreadplayers, stopsound, stopwatch, summon, tag, team, teammsg (+`tm`), teleport (+`tp`), tellraw, test, tick, time, title, trigger, waypoint, weather, worldborder | always |
| jfr | only if the JVM profiler (JFR) is available at runtime |
| chase | only if the shared debug flag `DEBUG_CHASE_COMMAND` is on |
| raid, debugpath, debugmobspawning, warden_spawn_tracker, spawn_armor_trims, serverpack | only if `DEBUG_DEV_COMMANDS` is on or the game is running from an IDE (`IS_RUNNING_IN_IDE`) |
| debugconfig | same condition as the line above, and additionally only on a dedicated server (the selection includes dedicated) |
| ban-ip, banlist, ban, deop, op, pardon, pardon-ip, perf, save-all, save-off, save-on, setidletimeout, stop, transfer, whitelist | only when the selection includes **dedicated** (dedicated server, selection `ALL` or `DEDICATED`) |
| publish, unpublish | only when the selection includes **integrated** (selection `ALL` or `INTEGRATED`) |

`CommandSelection` values: `ALL` (integrated and dedicated), `DEDICATED` (dedicated only), `INTEGRATED` (integrated only). Read in `MinecraftServer`: its command-registration code picks `DEDICATED` or `INTEGRATED` (a two-way choice), `DEDICATED` for a dedicated server and `INTEGRATED` otherwise; `ALL` is not chosen there. `debug` (profiling) is not conditional. `DEBUG_VERBOSE_COMMAND_ERRORS` is not used by registration; it is tested in `Commands.performCommand`'s handler for uncaught exceptions (read): the handler logs `Command exception: /{}`, sends a failure with the translation `command.failed` ("An unexpected error occurred while trying to execute that command"), and when the flag or `IS_RUNNING_IN_IDE` is set it additionally sends the error description as a failure and logs `'/{}' threw an exception`.

**For CobolCraft** (server is dedicated-style with a single-player host): the "dedicated" group is the right set to register for a headless server; `publish`/`unpublish` apply to a hosted single-player world; the dev/debug group should be left out (section 12).

---

## 3. Index

| Command | Level | Section | Needs (gameplay system) |
|---|---|---|---|
| advancement | 2 | 6.6 | advancements |
| attribute | 2 | 5.12 | attributes, entities |
| ban | 3 (dedicated) | 11.3 | ban list |
| ban-ip | 3 (dedicated) | 11.4 | ban list |
| banlist | 3 (dedicated) | 11.7 | ban list |
| bossbar | 2 | 8.7 | boss bars |
| chase | 0 (dev, `DEBUG_CHASE_COMMAND`) | 12 | none |
| clear | 2 | 6.2 | inventory, item predicates |
| clone | 2 | 7.4 | block entities |
| compute | 2 | 10.9 | number providers |
| damage | 2 | 5.7 | damage types |
| data | 2 | 10.1 | NBT paths, entities, block entities, storage |
| datapack | 2 (`create`: 4) | 10.11 | data packs |
| debug | 3 | 11.19 | tick profiler, functions |
| debugconfig | 3 (dev, dedicated) | 12 | configuration phase |
| debugmobspawning | 2 (dev) | 12 | spawning |
| debugpath | 2 (dev) | 12 | pathfinding |
| defaultgamemode | 2 | 4.2 | none |
| deop | 3 (dedicated) | 11.2 | operator list |
| dialog | 2 | 8.10 | dialogs |
| difficulty | 2 | 4.3 | none |
| effect | 2 | 5.10 | mob effects |
| enchant | 2 | 5.11 | enchantments |
| execute | 2 | 10.2 | all |
| experience / xp | 2 | 5.13 | experience |
| fetchprofile | 2 | 11.20 | profile service |
| fill | 2 | 7.2 | blocks |
| fillbiome | 2 | 7.3 | biomes |
| forceload | 2 | 7.6 | chunk tickets |
| function | 2 | 10.3 | functions |
| gamemode | 2 | 4.1 | none |
| gamerule | 2 | 4.4 / 13 | none |
| give | 2 | 6.1 | items |
| help | 0 | 8.6 | none |
| item | 2 | 6.3 | item modifiers |
| jfr | 4 (if JFR available) | 11.18 | none |
| kick | 3 | 11.8 | none |
| kill | 2 | 5.1 | entities |
| list | 0 | 8.5 | none |
| locate | 2 | 7.7 | structures, biomes, points of interest |
| loot | 2 | 6.4 | loot tables |
| me | 0 | 8.2 | chat types |
| msg / tell / w | 0 | 8.3 | chat types |
| op | 3 (dedicated) | 11.1 | operator list |
| pardon | 3 (dedicated) | 11.5 | ban list |
| pardon-ip | 3 (dedicated) | 11.6 | ban list |
| particle | 2 | 7.8 | particles |
| perf | 4 (dedicated) | 11.17 | none |
| place | 2 | 7.5 | structures, features, templates |
| playsound | 2 | 7.9 | sounds |
| posteffect | 2 | 8.11 | post effects (client) |
| publish | 4 (integrated) | 11.15 | LAN hosting |
| unpublish | 4 (integrated) | 11.16 | LAN hosting |
| raid | 3 (dev) | 12 | raids |
| random | 0 (`reset`: 2) | 10.8 | none |
| recipe | 2 | 6.5 | recipes |
| reload | 2 | 10.12 | data packs |
| return | 2 | 10.6 | function engine |
| ride | 2 | 5.6 | passengers |
| rotate | 2 | 5.5 | none |
| save-all | 4 (dedicated) | 11.9 | persistence |
| save-off | 4 (dedicated) | 11.11 | persistence |
| save-on | 4 (dedicated) | 11.10 | persistence |
| say | 2 | 8.1 | chat types |
| schedule | 2 | 10.4 | function scheduler |
| scoreboard | 2 | 9.1 | scoreboard |
| seed | 2 (0 in integrated) | 4.6 | world seed |
| serverpack | 2 (dev) | 11.21 | resource packs |
| setblock | 2 | 7.1 | blocks |
| setidletimeout | 3 (dedicated) | 11.14 | none |
| setworldspawn | 2 | 4.7 | none |
| spawn_armor_trims | 2 (dev) | 12 | armor trims |
| spawnpoint | 2 | 4.8 | none |
| spectate | 2 | 5.4 | spectator mode |
| spreadplayers | 2 | 5.3 | heightmaps |
| stop | 4 (dedicated) | 11.12 | none |
| stopsound | 2 | 7.10 | sounds |
| stopwatch | 2 | 10.10 | none |
| summon | 2 | 5.8 | entity types |
| swing | 2 | 5.14 | none |
| tag | 2 | 5.9 | none |
| team | 2 | 9.2 | teams |
| teammsg / tm | 0 | 8.4 | teams, chat types |
| teleport / tp | 2 | 5.2 | none |
| tellraw | 2 | 8.8 | text components |
| test | 2 | 12 | game test framework |
| tick | 3 | 4.9 | tick manager |
| time | 2 | 4.5 | world clocks, timelines |
| title | 2 | 8.9 | none |
| transfer | 3 (dedicated) | 11.13 | transfer packets |
| trigger | 0 | 9.3 | scoreboard |
| version | 2 (0 in integrated) | 4.6 | none |
| warden_spawn_tracker | 2 (dev) | 12 | wardens |
| waypoint | 2 | 5.15 | waypoints |
| weather | 2 | 4.10 | none |
| whitelist | 3 (dedicated) | 11.22 | whitelist |
| worldborder | 2 | 4.11 | world border |

Count: 97 registered command names plus 5 aliases (`tp`, `xp`, `tell`, `w`, `tm`). Of these, 8 are dev/debug-only or conditional (chase, raid, debugpath, debugmobspawning, warden_spawn_tracker, spawn_armor_trims, serverpack, debugconfig), `jfr` is conditional on profiler availability, `test` is registered always.

---

## 4. Player and game state

### 4.1 `gamemode`

Level 2. Grammar:

```
gamemode <gamemode>                 -> the executing player (error if source is not a player)
gamemode <gamemode> <targets:players>
```

`<gamemode>` is one of the literals `survival`, `creative`, `adventure`, `spectator` (15 framework: argument types, game mode). Without `<targets>` the source must be a player (otherwise the usual "player required" error, 15 framework: error messages).

Behaviour: for each target, set its game mode; a target already in that mode is skipped. Result = number of players whose mode actually changed (0 is not a failure).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.gamemode.success.self` | mode name | Set own game mode to %s | **B**; chosen per player when the source entity equals that player and the player's mode changed |
| `commands.gamemode.success.other` | target display name, mode name | Set %s's game mode to %s | **B**; target is not the source |
| `gameMode.changed` | mode name | Your game mode has been updated to %s | sent as a system message to the target when the target is not the source and the `send_command_feedback` gamerule is true |

The mode name argument is the translatable `gameMode.<name>`: `gameMode.survival` "Survival Mode", `gameMode.creative` "Creative Mode", `gameMode.adventure` "Adventure Mode", `gameMode.spectator` "Spectator Mode" (`gameMode.hardcore` "Hardcore Mode" exists for the world list). Side effects (read from `ServerPlayer.setGameMode`): a Game Event with id 3 (`CHANGE_GAME_MODE`; packet 05a 0x27) carrying the new mode id as its value is sent to the player; for spectator mode the player also calls `removeEntitiesOnShoulder`, `stopRiding`, `stopUsingItem` and `setCamera(this)`; `onUpdateAbilities` and `updateEffectVisibility` follow.

### 4.2 `defaultgamemode`

Level 2. `defaultgamemode <gamemode>`. Sets the world's game type (`setDefaultGameType`), then calls `enforceGameTypeForPlayers(getForcedGameType())` (read): that routine returns 0 when the forced game type is null; otherwise it sets every online player's mode to it and returns the number of players whose mode changed. `getForcedGameType` returns the world game type (exactly the mode just set) when the `force-gamemode` property is on, else null, on a dedicated server (`DedicatedServer.getForcedGameType`, read); the integrated server returns it only when published and not hardcore. So on a dedicated server with `force-gamemode` on, players are moved to the mode just typed; with it off nobody is moved. Result = the number moved. The success message is sent with broadcast on and its argument is the mode's long display name (`GameType.getLongDisplayName`, the same texts as `gameMode.<name>`).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.defaultgamemode.success` | mode name | The default game mode is now %s | **B** |

### 4.3 `difficulty`

Level 2.

```
difficulty                          -> query
difficulty peaceful|easy|normal|hard
```

The four literals are the serialized names of the `Difficulty` enum (ids 0 to 3 in that order, read from the enum constructor). Setting to the current difficulty fails. Setting writes the world data difficulty and notifies players (read: `MinecraftServer.setDifficulty(difficulty, forced)` is called with forced = true; it ignores a locked difficulty unless forced, makes the value HARD in a hardcore world, stores it in the world data, and `ClientboundChangeDifficultyPacket` (05a 0x0A) is referenced from `MinecraftServer`, `PlayerList` and `ServerPlayer`). Result: set returns 0; query returns the difficulty id (0 peaceful, 1 easy, 2 normal, 3 hard).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.difficulty.query` | display name | The difficulty is %s | Q; query. The name is the difficulty's display-name component, whose key is `options.difficulty.<key>` (Peaceful, Easy, Normal, Hard) |
| `commands.difficulty.success` | display name | The difficulty has been set to %s | **B** |
| `commands.difficulty.failure` | display name | The difficulty did not change; it is already set to %s | error |

### 4.4 `gamerule`

Level 2. The full rule list, types, defaults and ranges are in section 13. Grammar (generated once per rule):

```
gamerule <rule>                     -> query
gamerule <rule> <value>             -> set
```

`<rule>` is a literal and exists twice for every rule: the bare id (`keep_inventory`) and the namespaced id (`minecraft:keep_inventory`). `<value>` is `bool` for boolean rules and `integer(min, max)` for integer rules (ranges in section 13). Rules whose required feature flags are not enabled in the world are not offered. Rules are stored per world (the executing level's `GameRules`).

Behaviour: query sends the current value (not broadcast); set compares the serialized new value with the current one and fails if equal; otherwise stores it (the rule's change hook runs with the server) and sends the success message (broadcast). Result: the rule's command-result function applied to the value: for a boolean rule 1 for true and 0 for false, for an integer rule the integer value itself (both read).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.gamerule.query` | rule id (bare), value text | Game rule %s is currently set to %s | Q |
| `commands.gamerule.set` | rule id (bare), value text | Game rule %s is now set to %s | **B** |
| `commands.gamerule.not_set` | rule id, value text | Game rule %s is already set to %s | error: new value equals current. Note (see 17): the key is named "not_set" but the English text is "already set" |

Value text is `true`/`false` or the decimal integer.

### 4.5 `time`

Level 2. In 26.3 time is driven by **world clocks** (`data/minecraft/world_clock/`: `overworld`, `the_end`, both empty definitions) and **timelines** (`data/minecraft/timeline/`: `day`, `early_game`, `moon`, `villager_schedule`). Each dimension type names a default clock (field `defaultClock`, optional). The `time` nodes act on one clock: the executing dimension's default clock, or the clock named after `of`.

```
time query gametime
time <clock-ops>
time of <clock:resource world_clock> <clock-ops>

<clock-ops> :=
    set <time>                     (time(min 0) argument: ticks, or with s/d/t suffix)
  | set <timemarker:id>            (suggestions: markers flagged show_in_commands)
  | add <time>                     (time argument whose minimum is the int minimum, so negative values are accepted)
  | pause
  | resume
  | rate <rate:float 0.00001..1000>
  | query time
  | query timeline <timeline:resource timeline> [repetition]
```

Data: timeline `day` is bound to clock `minecraft:overworld`, `period_ticks` 24000, and has the command-visible time markers `minecraft:day` 1000, `minecraft:noon` 6000, `minecraft:night` 13000, `minecraft:midnight` 18000 (all `show_in_commands`), plus internal markers `minecraft:roll_village_siege` 18000 and `minecraft:wake_up_from_sleep` 0 (not offered). Timeline `moon` has `period_ticks` 192000 and `villager_schedule` 24000; both are bound to the overworld clock; `early_game` has no period. Whether the `time` literal `day` etc. is accepted without namespace follows the identifier argument rule (15 framework: identifiers).

Behaviour and results (clock id shown as `%s` is the clock's registered id):

| Form | Behaviour | Result |
|---|---|---|
| `query gametime` | sends the level game time (a long); Q | `wrapTime`: the value `lrem` 2147483647 then `toIntExact` |
| `query time` | total ticks of the clock | same reduction |
| `query timeline <t>` | current tick within the timeline's period (`getCurrentTicks`); error if `<t>`'s clock differs from the chosen clock | same reduction |
| `query timeline <t> repetition` | the number of completed periods (`getPeriodCount`); same clock check | same reduction |
| `set <time>` | sets the clock's total ticks; fails if already equal | the int argument (read) |
| `set <timemarker>` | looks up the marker in the clock's registered markers; none: error `no_time_marker_found`; if the marker already occurs at the clock's current time (marker ticks equal total ticks modulo the marker's period, or equal total ticks when it has no period): error `already_at_time_marker`; otherwise the clock total is advanced to the **next** occurrence strictly after now: with period P, current position c = total mod P and marker tick m, the advance is m - c when that is positive, else P + (m - c); for a marker with no period the clock jumps to m; the partial tick is reset to 0 | the clock's total ticks after the move, through `wrapTime` |
| `add <time>` | adds ticks to the clock total | the clock's total ticks after the add, through `wrapTime` |
| `pause` / `resume` | sets the clock paused flag; fails if already in that state | 1 |
| `rate <r>` | sets the clock rate multiplier; fails if equal | 1 |

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.time.query.gametime` | game time | The game time is %s tick(s) | Q |
| `commands.time.query.absolute` | clock id, ticks | Clock %s is at %s tick(s) | Q |
| `commands.time.query.timeline` | timeline id, ticks | Timeline %s is at %s tick(s) | Q |
| `commands.time.query.timeline.repetitions` | timeline id, count | Timeline %s has passed %s repetition(s) | Q |
| `commands.time.set.absolute` | clock id, ticks | Set %s to %s tick(s) | **B**; for both `set <time>` and `add` |
| `commands.time.set.time_marker` | clock id, marker id | Set %s to time marker %s | **B** |
| `commands.time.pause` | clock id | Paused clock %s | **B** |
| `commands.time.resume` | clock id | Resumed clock %s | **B** |
| `commands.time.rate` | clock id, rate | Clock %s will now advance at %sx normal rate | **B** |
| `commands.time.no_default_clock` | dimension id | There is no default clock in dimension %s | error: dimension type has no default clock |
| `commands.time.no_time_marker_found` | marker id, clock id | Time marker %s does not exist for clock %s | error |
| `commands.time.wrong_timeline_for_clock` | timeline id, clock id | Timeline %s is not valid for clock %s | error |
| `commands.time.set.already_at_time` | clock id, ticks | Clock %s is already set to %s tick(s) | error |
| `commands.time.set.already_at_time_marker` | clock id, marker id | Clock %s is already at time marker %s | error |
| `commands.time.pause.already_paused` | clock id | Clock %s is already paused | error |
| `commands.time.pause.already_running` | clock id | Clock %s is already running | error |
| `commands.time.rate.already_same` | clock id, rate | Clock %s is already advancing at %sx normal rate | error |

Notes for CobolCraft: its current world has one clock `cobolcraft:daylight` (09 profile, Set Time packet world_clock id 0). `time set day` style forms map to markers; the Set Time packet carries clock updates (05b).

### 4.6 `seed` and `version`

`seed`: level 2 (level 0 in an integrated server). No arguments. Sends `commands.seed.success` "Seed: %s" (the argument is the seed rendered as a click-to-copy component; Q). Result: the seed's low 32 bits as an int (`l2i`).

`version`: level 2 (0 in integrated). No arguments. Sends these lines, each Q, in order:

| Key | English | Notes |
|---|---|---|
| `commands.version.header` | Server version info: | |
| `commands.version.id` | id = %s | version id |
| `commands.version.name` | name = %s | |
| `commands.version.data` | data = %s | world data version (5023 for this artifact, 07) |
| `commands.version.series` | series = %s | |
| `commands.version.protocol` | protocol = %s (%s) | protocol version, then `Integer.toHexString` of it |
| `commands.version.build_time` | build_time = %s | |
| `commands.version.pack.resource` | pack_resource = %s | resource pack format |
| `commands.version.pack.data` | pack_data = %s | data pack format |
| `commands.version.stable.yes` / `.no` | stable = yes / stable = no | |

Result 1 (read). The header and every line are sent with `sendSystemMessage` (to the source only), not through `sendSuccess`.

### 4.7 `setworldspawn`

Level 2.

```
setworldspawn                                   -> block containing the source position, rotation (0, 0)
setworldspawn <pos:block_pos>                   -> rotation (0, 0)
setworldspawn <pos> <rotation:yaw pitch>
```

Sets the **respawn data** of the executing level (dimension, block position, yaw, pitch; `LevelData.RespawnData`) and succeeds with result 1. Both explicit-position forms read `<pos>` with `BlockPosArgument.getSpawnablePos`, the same accessor as `spawnpoint`.

| Key | Arguments passed | English (en_us) | When |
|---|---|---|---|
| `commands.setworldspawn.success` | x, y, z, yaw, pitch, dimension id (six arguments) | Set the world spawn point to %s, %s, %s [%s] | **B** |

Confirmed by reading the message builder: the code passes six positional arguments in this order: x, y, z (integers), yaw, pitch (floats), dimension id (string). The English text for the key has only four placeholders, so the displayed message uses x, y, z and yaw and silently drops pitch and dimension. The lang file also holds `commands.setworldspawn.success.new` ("Set the world spawn point to %s, %s, %s [%s, %s] in %s") and `commands.setworldspawn.failure.not_overworld` ("Can only set the world spawn for the Overworld"); neither key is referenced from the `SetWorldSpawnCommand` class (they may be used elsewhere or be stale; see 17). Clients are told with Set Default Spawn Position (05b 0x63; read: `ClientboundSetDefaultSpawnPositionPacket` is referenced from `MinecraftServer` and `PlayerList`).

### 4.8 `spawnpoint`

Level 2.

```
spawnpoint                                      -> the source player's block position
spawnpoint <targets:players>                    -> at the source block position
spawnpoint <targets> <pos:block_pos (spawnable)>
spawnpoint <targets> <pos> <rotation:yaw pitch>
```

Sets each target's personal respawn: dimension of the executing level, block position, yaw (wrapped with `wrapDegrees`) and pitch clamped to -90..90, plus a boolean flag passed as true (meaning not traced). Tracker value 1 per player; result = tracker total.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.spawnpoint.success.single` | read: x, y, z, yaw, pitch, dimension id, player display name (seven arguments) | Set spawn point to %s, %s, %s [%s] in %s for %s | **B**, one player |
| `commands.spawnpoint.success.multiple` | read: x, y, z, yaw, pitch, dimension id, player count (seven arguments) | Set spawn point to %s, %s, %s [%s] in %s for %s players | **B** |

Confirmed discrepancy: both messages pass seven positional arguments (x, y, z, yaw, pitch, dimension, then the player or count) but the English text has six `%s` placeholders. Positional substitution therefore shows, for example, `Set spawn point to 10, 64, 10 [0.0] in 0.0 for minecraft:overworld` (the fifth argument, the pitch, lands in the "in" slot and the dimension in the "for" slot; the player name or count is not shown). An implementer reproducing the English output must substitute in argument order. The lang file's `.single.new` / `.multiple.new` texts ("[%s, %s] in %s for %s") fit the seven-argument order but are not referenced from `SetSpawnCommand`.

### 4.9 `tick`

Level 3.

```
tick query
tick rate <rate:float 1..10000>
tick step                       (1 tick)
tick step stop
tick step <time:time(min 1)>
tick sprint <time:time(min 1)>
tick sprint stop
tick freeze
tick unfreeze
```

Controls the server tick manager: target rate, freezing, stepping a frozen game, and sprinting; read: `rate` calls the server tick-rate manager's `setTickRate` (argument range 1.0 to 10000.0); the base `TickRateManager` starts with a rate of 20.0; `step` calls `stepGameIfPaused(n)` and fails with `step.fail` when the game is not frozen; the sprint algorithm was not read.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.tick.query.rate.running` | target rate, average ms, target ms | Target tick rate: %s per second.⏎Average time per tick: %sms (Target: %sms) | Q; `query` when running (the text contains a newline) |
| `commands.tick.query.rate.sprinting` | rate, average ms | Target tick rate: %s per second (ignored, reference only).⏎Average time per tick: %sms | Q; sprinting |
| `commands.tick.query.percentiles` | p50, p95, p99, sample count | Percentiles: P50: %sms P95: %sms P99: %sms. Sample: %s | Q; after the rate lines |
| `commands.tick.status.running` | | The game is running normally | state line: B from `freeze`/`unfreeze`, Q from `query` |
| `commands.tick.status.frozen` | | The game is frozen | state line: B from `freeze`, Q from `query` |
| `commands.tick.status.sprinting` | | The game is sprinting | state line: B from `sprint`, Q from `query` |
| `commands.tick.status.lagging` | | The game is running, but can't keep up with the target tick rate | state line, `query` when average exceeds target |
| `commands.tick.rate.success` | rate | Set the target tick rate to %s per second | **B** |
| `commands.tick.step.success` | ticks | Stepping %s tick(s) | **B** |
| `commands.tick.step.stop.success` | | Interrupted the current tick step | **B** |
| `commands.tick.sprint.stop.success` | | Interrupted the current tick sprint | **B** |
| `commands.tick.step.fail` | | Unable to step the game - the game must be frozen first | error |
| `commands.tick.step.stop.fail` | | No tick step in progress | error |
| `commands.tick.sprint.stop.fail` | | No tick sprint in progress | error |

`freeze` and `unfreeze` first stop a running sprint and a running step (read: `isSprinting`/`stopSprinting`, `isSteppingForward`/`stopStepping`), then call `setFrozen` and send the status key (`status.frozen`, `status.running`); the stop of a sprint uses `sprint.stop.success` when it is done through `tick sprint stop`. Client propagation: `ServerTickRateManager` references `ClientboundTickingStatePacket` (05b 0x82) and `ClientboundTickingStepPacket` (05b 0x83).

### 4.10 `weather`

Level 2.

```
weather clear [<duration:time(min 1)>]
weather rain [<duration>]
weather thunder [<duration>]
```

Calls `MinecraftServer.setWeatherParameters(clearTime, rainTime, raining, thundering)` (read): it works on the server-level `WeatherData` (one object for the whole server, read and written through `getWeatherData`) and sets, in order, clear-weather time, rain time, thunder time (set to the same value as the rain time), the raining flag and the thundering flag. The defaults when `<duration>` is omitted are drawn from uniform integer ranges in ticks (the level's own random source):

| Form | clear time | rain time | raining | thundering | default duration when omitted |
|---|---|---|---|---|---|
| `clear` | duration | 0 | false | false | uniform 12000..180000 (`RAIN_DELAY`) |
| `rain` | 0 | duration | true | false | uniform 12000..24000 (`RAIN_DURATION`) |
| `thunder` | 0 | duration | true | true | uniform 3600..15600 (`THUNDER_DURATION`) |

(The thunder delay range 12000..180000 exists in the level but is not used by this command.) Result = the duration argument as given, or -1 when omitted.

| Key | English | When |
|---|---|---|
| `commands.weather.set.clear` | Set the weather to clear | **B** |
| `commands.weather.set.rain` | Set the weather to rain | **B** |
| `commands.weather.set.thunder` | Set the weather to rain and thunder | **B** |

The setter works on the single server-level `WeatherData` (`MinecraftServer.setWeatherParameters`), not per level. The `advance_weather` rule is read in `ServerLevel` (2 sites) and `MinecraftServer` (1 site); its exact effect there was not traced. `ClientboundGameEventPacket` (05a 0x27) is referenced from `ServerLevel` and `PlayerList`. CobolCraft's own kinds `clear/drizzle/hailstorm` (standin §14) are CobolCraft design; the vanilla set is clear/rain/thunder.

### 4.11 `worldborder`

Level 2. The border belongs to the executing level.

```
worldborder get
worldborder set <distance:double -59999968..59999968> [<time:time(min 0)>]
worldborder add <distance:double -59999968..59999968> [<time:time(min 0)>]
worldborder center <pos:vec2>
worldborder damage amount <damagePerBlock:float min 0>
worldborder damage buffer <distance:float min 0>
worldborder warning distance <distance:integer min 0>
worldborder warning time <time:time(min 0)>
```

Rules:

* `set`: new size must differ from the current size (else `set.failed.nochange`), must be at least 1 (`set.failed.small`), at most 59999968 (`set.failed.big`, argument 59999968). `add` computes current size (or the interpolation target if a change is in progress) plus the distance and applies the same checks. If `<time>` is given and greater than 0 ticks, the border moves linearly over that many ticks (grow or shrink message by comparing with the current size), otherwise it changes immediately.
* `center`: x and z must each satisfy |value| <= 29999984; equal centre gives `center.failed`; out of range gives `set.failed.far` with argument 29999984.
* `damage amount` is damage per block per second beyond the border plus buffer; `damage buffer` the safe distance; `warning distance` blocks, `warning time` seconds (the argument is read as ticks / 20 for display, `formatTicksToSeconds` uses `%.2f`).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.worldborder.get` | size | The world border is currently %s block(s) wide | Q; size formatted with one decimal ("%.1f") |
| `commands.worldborder.set.immediate` | size ("%.1f") | Set the world border to %s block(s) wide | **B** |
| `commands.worldborder.set.grow` | size, seconds ("%.2f") | Growing the world border to %s block(s) wide over %s second(s) | **B** |
| `commands.worldborder.set.shrink` | size, seconds | Shrinking the world border to %s block(s) wide over %s second(s) | **B** |
| `commands.worldborder.center.success` | x, z | Set the center of the world border to %s, %s | **B** |
| `commands.worldborder.damage.amount.success` | amount | Set the world border damage to %s per block each second | **B** |
| `commands.worldborder.damage.buffer.success` | distance | Set the world border damage buffer to %s block(s) | **B** |
| `commands.worldborder.warning.distance.success` | distance | Set the world border warning distance to %s block(s) | **B** |
| `commands.worldborder.warning.time.success` | seconds | Set the world border warning time to %s second(s) | **B** |
| `commands.worldborder.center.failed` | | Nothing changed. The world border is already centered there | error |
| `commands.worldborder.set.failed.nochange` | | Nothing changed. The world border is already that size | error |
| `commands.worldborder.set.failed.small` | | World border cannot be smaller than 1 block wide | error |
| `commands.worldborder.set.failed.big` | max size | World border cannot be bigger than %s blocks wide | error |
| `commands.worldborder.set.failed.far` | max center | World border cannot be further out than %s blocks | error (center out of range; argument 29999984) |
| `commands.worldborder.warning.time.failed` | | Nothing changed. The world border warning is already that amount of time | error |
| `commands.worldborder.warning.distance.failed` | | Nothing changed. The world border warning is already that distance | error |
| `commands.worldborder.damage.buffer.failed` | | Nothing changed. The world border damage buffer is already that distance | error |
| `commands.worldborder.damage.amount.failed` | | Nothing changed. The world border damage is already that amount | error |

Results (read): `get` returns floor(size + 0.5); `center` returns 0; `damage amount` and `damage buffer` return the argument truncated to int; `warning distance` and `warning time` return the argument; `set` returns (int)(new size - size before the change); `add` computes the new size as the border's current size plus the distance and then behaves as `set`, except that with a `<time>` the time used is the border's remaining lerp time plus the given time (`add` with no time uses the no-time form). Border sync (read): the border change listener created in `PlayerList` (class `PlayerList$1`) sends Set Border Center (05b 0x5A), Set Border Lerp Size (0x5B), Set Border Size (0x5C), Set Border Warning Delay (0x5D) and Set Border Warning Distance (0x5E); `PlayerList` also references Initialize Border (0x2C).

---

## 5. Entities and movement

### 5.1 `kill`

Level 2. `kill` (kills the source entity; the source must be an entity) and `kill <targets>`. Calls the entity's kill routine on each target (read: the base `Entity.kill` removes the entity with reason KILLED and emits the ENTITY_DIE game event; `LivingEntity.kill` instead applies the `generic_kill` damage source with the largest float value, i.e. through the normal damage path); tracker with value 1 per target. Players are killed too. Result = number of targets.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.kill.success.single` | display name | Killed %s | **B** |
| `commands.kill.success.multiple` | count | Killed %s entities | **B** |

An empty selector result is the framework's "no entity found" error (15 framework: selectors), not a kill message.

### 5.2 `teleport` (alias `tp`)

Level 2. `tp` is a redirect to `teleport` (same nodes, same level).

```
teleport <location:vec3>                        -> teleports the source entity
teleport <destination:entity>                   -> teleports the source entity to that entity
teleport <targets:entities> <location:vec3>
teleport <targets> <location> <rotation:yaw pitch>
teleport <targets> <location> facing <facingLocation:vec3>
teleport <targets> <location> facing entity <facingEntity:entity> [<facingAnchor:feet|eyes>]
teleport <targets> <destination:entity>
```

Behaviour (read): tracker-style counting, one tracked entry per entity successfully teleported; with zero entries tracked the usual selector error applies upstream.

* **Position forms.** The destination position is checked with the spawnable-bounds test: block X and Z must lie in [-30000000, 30000000) and block Y in [-20000000, 20000000); otherwise error `commands.teleport.invalidPosition`. Each of x, y, z may be relative (`~`): a relative component is added to the entity's current value of that coordinate (relative flags are computed per axis from the coordinate argument; for local `^` coordinates the position flags are taken from the argument's relative flags as well). Yaw and pitch each may be relative to the entity's current yaw and pitch; when no rotation argument is given the entity keeps its yaw and pitch. The resulting yaw and pitch are wrapped to degrees with `wrapDegrees` and passed to the entity's teleport routine with a boolean `true`. If that routine refuses (returns false) the entity is skipped without error and not counted.
* **Facing.** For the `facing` forms, after the teleport the entity is turned to look at the point or at the chosen entity anchor.
* **Side effects after a successful teleport.** If the entity is not a fall-flying living entity, its velocity is multiplied by (1, 0, 1) (vertical speed cleared); the entity's on-ground flag is set true; a pathfinder mob has its navigation stopped.
* **Entity destination.** The destination entity's level, X, Y, Z and its yaw and pitch are used with an empty relative set, so the target takes the destination's position (the use of the destination's rotation is inferred from the getter calls).
* **Messages.** In the location messages x, y and z are formatted with the format `%f` using the root locale, i.e. six digits after the point (for example `0.000000`).

Result = the tracker total (the number of entities teleported).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.teleport.success.entity.single` | teleported display name, destination display name | Teleported %s to %s | **B** |
| `commands.teleport.success.entity.multiple` | count, destination display name | Teleported %s entities to %s | **B** |
| `commands.teleport.success.location.single` | display name, x, y, z | Teleported %s to %s, %s, %s | **B**; formatted `%f`, six decimals |
| `commands.teleport.success.location.multiple` | count, x, y, z | Teleported %s entities to %s, %s, %s | **B** |
| `commands.teleport.invalidPosition` | | Invalid position for teleport | error |

### 5.3 `spreadplayers`

Level 2.

```
spreadplayers <center:vec2> <spreadDistance:float min 0> <maxRange:float min 1> <respectTeams:bool> <targets:entities>
spreadplayers <center> <spreadDistance> <maxRange> under <maxHeight:integer> <respectTeams> <targets>
```

Rules, read from `SpreadPlayersCommand` and its `Position` helper:

1. **Height.** In the `under` form `<maxHeight>` must be at least the level's minimum build height (`getMinY`), else error `commands.spreadplayers.failed.invalid.height` (arguments: maxHeight, minimum). Without `under`, maxHeight is the level's maximum build height plus 1.
2. **Box.** The placement box is the square from (centre x - maxRange, centre z - maxRange) to (centre x + maxRange, centre z + maxRange).
3. **Piles.** The number of positions ("piles") is the number of distinct teams when `respectTeams` is true (a player counts under its team; every non-player entity and every player without a team counts under one shared "no team" key), otherwise the number of target entities.
4. **Initial positions.** Each pile gets a uniformly random x in [minX, maxX] and z in [minZ, maxZ] (a thread-local random source is used).
5. **Relaxation.** Up to **10000** iterations; the loop also stops as soon as an iteration moves nothing. In each iteration, for every pile p: p's own neighbour count n starts at 0 and an accumulator vector starts at (0, 0); for every other pile q the distance d (Euclidean in x and z) is computed and the running minimum distance over all pairs is updated (this minimum is reset to Float.MAX at the start of every iteration, so the failure message reports the minimum of the last iteration); if d < spreadDistance then n is incremented and the vector (other pile - this pile) is added to the accumulator. After the neighbour scan: if n > 0 the accumulator is divided by n; if its length is greater than 0 it is normalised and p is moved away by subtracting the normalised accumulator from p's coordinates (`moveAway` subtracts; since the accumulator points toward the neighbours, p moves away from them); if the length is 0 the pile is given a new random position inside the box; in either case the iteration is marked as having moved. Then p is clamped into the box; if the clamp changed it, the iteration counts as having moved.
6. **Ground check.** When an iteration moved nothing, every pile is tested: the spawn height is computed for its column (rule 8) and the block below must lie below `maxHeight`, not be a liquid and carry the block tag `entities_can_teleport_to`; a pile failing the test is re-randomised and the iteration is marked as moved (so the loop continues).
7. **Failure.** If the iteration counter reaches 10000, the command fails with `commands.spreadplayers.failed.teams` (when `respectTeams`) or `.failed.entities`, with arguments (number of piles, centre x, centre z, the smallest pair distance seen formatted "%.2f"; 0 when no pair was seen).
8. **Spawn height of a column.** Starting at y = maxHeight + 1 above the pile's x/z, the column is scanned downward: track whether the block at y, y-1, y-2 are air; the first position (scanning down, while y is above the level minimum) where the block at y-2 is not air and the two blocks above it are air gives height = (that y) + 1; if the bottom is reached the height is maxHeight + 1.
9. **Teleport.** Each target entity is teleported to x = floor(pile x) + 0.5, y = the spawn height, z = floor(pile z) + 0.5, keeping its yaw and pitch, with an empty relative-flag set (absolute) and the same boolean flag as `teleport` passes.
10. **Success value.** The reported average distance is: for each target entity, the distance to the nearest other pile (a pile compared with itself is skipped); these nearest distances are summed over all target entities and divided by the number of target entities; when there are fewer than 2 target entities the average is 0. Edge case (read: the nearest-distance minimum starts at Double.MAX and a pile is skipped only when it is the entity's own pile): if all targets share one pile (for example one team with `respectTeams`), no other pile exists, so each entity contributes Double.MAX and the reported average is a huge number.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.spreadplayers.success.entities` | count of piles, centre x, centre z, average distance ("%.2f") | Spread %s entity/entities around %s, %s with an average distance of %s block(s) apart | **B** (key is `...success.` + `teams` or `entities`) |
| `commands.spreadplayers.success.teams` | count of piles, centre x, centre z, average distance | Spread %s team(s) around %s, %s with an average distance of %s block(s) apart | **B** |
| `commands.spreadplayers.failed.entities` | piles, x, z, smallest distance | Could not spread %s entity/entities around %s, %s (too many entities for space - try using spread of at most %s) | error |
| `commands.spreadplayers.failed.teams` | piles, x, z, smallest distance | Could not spread %s team(s) around %s, %s (too many entities for space - try using spread of at most %s) | error |
| `commands.spreadplayers.failed.invalid.height` | maxHeight, minimum | Invalid maxHeight %s; expected higher than world minimum %s | error |

Result = the number of piles (the length of the position array).

### 5.4 `spectate`

Level 2.

```
spectate                                         -> stop spectating (source must be a player in spectator mode)
spectate <target:entity>                         -> the source starts spectating
spectate <target> <player:player>                -> that player starts spectating
```

The three error messages show that the spectating player must be in spectator mode, that self-spectating is refused and that some entities cannot be spectated; read: the check order is (1) target is the spectating player itself: `commands.spectate.self`; (2) the spectating player is not in spectator mode: `not_spectator` (argument the player's display name); (3) the target's entity type has a client tracking range of 0: `cannot_spectate` (argument the target's display name); then the player's `setCamera(target)` is called (the Set Camera packet 05b 0x5F is sent by that routine, not read here). The message is sent with broadcast **off** to the source. `ServerPlayer.setCamera` references `ClientboundSetCameraPacket` (05b 0x5F).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.spectate.success.started` | target display name | Now spectating %s | Q (source only; nothing is sent to the spectating player) |
| `commands.spectate.success.stopped` | | No longer spectating an entity | Q |
| `commands.spectate.not_spectator` | player display name | %s is not in spectator mode | error |
| `commands.spectate.self` | | Cannot spectate yourself | error |
| `commands.spectate.cannot_spectate` | target display name | %s cannot be spectated | error |

Result 1 (read).

### 5.5 `rotate`

Level 2.

```
rotate <target:entity> <rotation:yaw pitch>
rotate <target> facing <facingLocation:vec3>
rotate <target> facing entity <facingEntity:entity> [<facingAnchor:feet|eyes>]
```

Sets the target's rotation, or turns it toward a point or an entity anchor. Read: relative yaw/pitch are converted to a delta against the entity's current values and `forceSetRotation(yaw, yawIsRelative, pitch, pitchIsRelative)` is called. Message `commands.rotate.success` "Rotated %s" (target display name, **B**). Result 1.

### 5.6 `ride`

Level 2.

```
ride <target:entity> mount <vehicle:entity>
ride <target> dismount
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.ride.mount.success` | rider, vehicle | %s started riding %s | **B** |
| `commands.ride.dismount.success` | rider, vehicle | %s stopped riding %s | **B** |
| `commands.ride.not_riding` | rider | %s is not riding any vehicle | error (dismount) |
| `commands.ride.already_riding` | rider, vehicle | %s is already riding %s | error (mount) |
| `commands.ride.mount.failure.generic` | rider, vehicle | %s couldn't start riding %s | error (`startRiding` returned false; the code does not distinguish the reason) |
| `commands.ride.mount.failure.cant_ride_players` | | Players can't be ridden | error (vehicle is a player) |
| `commands.ride.mount.failure.loop` | | Can't mount entity on itself or any of its passengers | error |
| `commands.ride.mount.failure.wrong_dimension` | | Can't mount entity in different dimension | error |

Result 1 (read).

### 5.7 `damage`

Level 2.

```
damage <target:entity> <amount:float min 0> [<damageType:resource damage_type>]
damage <target> <amount> <damageType> at <location:vec3>
damage <target> <amount> <damageType> by <entity:entity> [from <cause:entity>]
```

Applies `amount` damage of the given type to the target; `at`, `by` and `from` supply a position, a direct entity and a causing entity. The tree shows the command executable after `amount`; in that form the damage source is the level's `generic` source (read: `damageSources().generic()`). Result 1 on success (read); the default damage type when `<damageType>` is omitted is the level's `generic` damage source (read: `damageSources().generic()`); `at <location>` builds a damage source with a position, `by <entity>` with a direct entity, `from <cause>` with a direct and a causing entity.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.damage.success` | amount, target display name | Applied %s damage to %s | **B** |
| `commands.damage.invulnerable` | | Target is invulnerable to the given damage type | error (the target ignored the damage) |

Damage types available are the 51 files in `data/minecraft/damage_type/` (cross-ref standin §4.7 for the synchronized registry). Damage resolution is outside this document (see 17).

### 5.8 `summon`

Level 2.

```
summon <entity:resource summonable_entity_type> [<pos:vec3> [<nbt:compound>]]
```

Read: `<entity>` accepts only summonable entity types. Without `<pos>` the source's position is used with an empty NBT; with `<pos>` alone, an empty NBT; the mob-initialisation flag ("finalize") is true in those two forms and false when an `<nbt>` is given. Steps: (1) the block containing the position must be inside the spawnable bounds (X, Z in [-30000000, 30000000), Y in [-20000000, 20000000)), else `commands.summon.invalidPosition`; (2) in Peaceful difficulty an entity type that is not allowed in Peaceful fails with `commands.summon.failed.peaceful`; (3) the NBT is copied and its `id` string is set to the entity type's id; (4) the entity is loaded from that NBT (recursively with passengers) as a spawn with reason COMMAND, then moved to the position keeping its own yaw and pitch; a failure to create gives `commands.summon.failed`; (5) when the finalize flag is true and the entity is a mob, its spawn initialisation is run for the local difficulty at its block position with spawn reason COMMAND; (6) the entity (with passengers) is added to the level; if the level refuses (a loaded entity already has that UUID), error `commands.summon.failed.uuid`. Success is **B**, result 1.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.summon.success` | entity display name | Summoned new %s | **B** |
| `commands.summon.failed` | | Unable to summon entity | error |
| `commands.summon.failed.peaceful` | | Monsters cannot be summoned in Peaceful difficulty | error |
| `commands.summon.failed.uuid` | | Unable to summon entity due to duplicate UUIDs | error |
| `commands.summon.invalidPosition` | | Invalid position for summon | error |

### 5.9 `tag`

Level 2.

```
tag <targets:entities> add <name:word>
tag <targets> remove <name:word>               (suggestions: tags present on the targets)
tag <targets> list
```

Entity tags are strings on the entity; the tag limit is read: `addTag` refuses when the entity already has 1024 or more tags. Results (read): `add` and `remove` return the tracker total (entities changed). `list` collects the union of all targets' tags; each target is tracked with its own tag count as the value; if the union is empty the no-tags response is sent (see section 1: `multiple.empty` with count 0), otherwise the list response is sent (`single.success` when exactly one target has tags, else `multiple.success` with the count of targets that have tags); both are quiet (broadcast false). The result is the size of the union of all targets' tags.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.tag.add.success.single` | tag, display name | Added tag '%s' to %s | **B** |
| `commands.tag.add.success.multiple` | tag, count | Added tag '%s' to %s entities | **B** |
| `commands.tag.add.failed` | | Target either already has the tag or has too many tags | error |
| `commands.tag.remove.success.single` | tag, display name | Removed tag '%s' from %s | **B** |
| `commands.tag.remove.success.multiple` | tag, count | Removed tag '%s' from %s entities | **B** |
| `commands.tag.remove.failed` | | Target does not have this tag | error |
| `commands.tag.list.single.success` | display name, count, tags | %s has %s tag(s): %s | Q |
| `commands.tag.list.single.empty` | display name | %s has no tags | Q |
| `commands.tag.list.multiple.success` | entity count, total count, tags | The %s entities have %s total tag(s): %s | Q |
| `commands.tag.list.multiple.empty` | entity count | There are no tags on the %s entities | Q |

### 5.10 `effect`

Level 2.

```
effect give <targets:entities> <effect:resource mob_effect>
effect give <targets> <effect> <seconds:integer 1..1000000> [<amplifier:integer 0..255> [<hideParticles:bool>]]
effect give <targets> <effect> infinite [<amplifier> [<hideParticles>]]
effect clear [<targets> [<effect>]]
```

`effect clear` with no argument clears the source entity. Only living entities are affected; others are skipped silently.

Duration (ticks): `infinite` gives the infinite duration (-1). A given `<seconds>` for a non-instant effect is multiplied by 20; for an **instantaneous** effect the argument is used as is (ticks) — this is how the tick count 1 is chosen. Omitted: 600 ticks (30 s) for a normal effect, 1 tick for an instant one. Default amplifier 0. `hideParticles` default false (particles shown; the command passes the inverse). The effect instance is added with the source entity as the cause. Tracker with value 1 per entity on which the add succeeded (an add is refused when the target is immune or has a stronger effect running). Result: the tracker total (for `give`, one per entity where the add was accepted).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.effect.give.success.single` | effect name, display name | Applied effect %s to %s | **B** |
| `commands.effect.give.success.multiple` | effect name, count | Applied effect %s to %s targets | **B** |
| `commands.effect.give.failed` | | Unable to apply this effect (target is either immune to effects, or has something stronger) | error |
| `commands.effect.clear.everything.success.single` | display name | Removed every effect from %s | **B** |
| `commands.effect.clear.everything.success.multiple` | count | Removed every effect from %s targets | **B** |
| `commands.effect.clear.everything.failed` | | Target has no effects to remove | error |
| `commands.effect.clear.specific.success.single` | effect name, display name | Removed effect %s from %s | **B** |
| `commands.effect.clear.specific.success.multiple` | effect name, count | Removed effect %s from %s targets | **B** |
| `commands.effect.clear.specific.failed` | | Target doesn't have the requested effect | error |

### 5.11 `enchant`

Level 2. `enchant <targets:entities> <enchantment:resource enchantment> [<level:integer min 0>]` (level defaults to 1; the level node is optional).

Rules read from the routine: the level (default 1 when the `<level>` node is omitted) must not exceed the enchantment's maximum level, else `commands.enchant.failed.level` (arguments: level, maximum), checked once before any target. Then, per target: a non-living entity is skipped (when it is the only target: `failed.entity`); the main-hand item is examined: no item is skipped (single target: `failed.itemless`, argument the entity's display name text); if the enchantment can be applied to the item and is compatible with the item's current enchantments, the enchantment is added at the level and the target is tracked (value 1); otherwise it is skipped (single target: `failed.incompatible`, argument the item's hover-name text). With no target tracked the result is `commands.enchant.failed`; otherwise success is **B** (single message for one tracked target, multiple message for several; argument: the enchantment's name), result = the tracker total (number of items enchanted).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.enchant.success.single` | enchantment name, display name | Applied enchantment %s to %s's item | **B** |
| `commands.enchant.success.multiple` | enchantment name, count | Applied enchantment %s to %s entities | **B** |
| `commands.enchant.failed` | | Nothing changed. Targets either have no item in their hands or the enchantment could not be applied | error (nothing succeeded) |
| `commands.enchant.failed.entity` | display name | %s is not a valid entity for this command | error (single target that is not a living entity) |
| `commands.enchant.failed.itemless` | display name | %s is not holding any item | error (single target) |
| `commands.enchant.failed.incompatible` | display name | %s cannot support that enchantment | error (single target) |
| `commands.enchant.failed.level` | level, max level | %s is higher than the maximum level of %s supported by that enchantment | error |

The 43 enchantment definitions are in `data/minecraft/enchantment/`.

### 5.12 `attribute`

Level 2.

```
attribute <target:entity> <attribute:resource attribute> get [<scale:double>]
attribute <target> <attribute> base get [<scale>]
attribute <target> <attribute> base set <value:double>
attribute <target> <attribute> base reset
attribute <target> <attribute> modifier add <id:identifier> <value:double> add_value|add_multiplied_base|add_multiplied_total
attribute <target> <attribute> modifier remove <id>           (suggestions: modifier ids on the attribute)
attribute <target> <attribute> modifier value get <id> [<scale>]
```

`get` forms take an optional `scale` (default 1.0, read: the no-scale branch passes the constant 1.0); the result of every `get` form is (int)(value x scale); `base set`, `base reset` and `modifier add` return 1 (they send their message with broadcast off). The target must have the attribute; `modifier add` fails when the id is already present.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.attribute.value.get.success` | attribute, entity, value | The value of attribute %s for entity %s is %s | Q (`get`) |
| `commands.attribute.base_value.get.success` | attribute, entity, value | The base value of attribute %s for entity %s is %s | Q |
| `commands.attribute.base_value.set.success` | attribute, entity, value | The base value for attribute %s for entity %s set to %s | Q |
| `commands.attribute.base_value.reset.success` | attribute, entity, default | The base value for attribute %s for entity %s reset to default %s | Q |
| `commands.attribute.modifier.add.success` | id, attribute, entity | Added modifier %s to attribute %s for entity %s | Q |
| `commands.attribute.modifier.remove.success` | id, attribute, entity | Removed modifier %s from attribute %s for entity %s | Q |
| `commands.attribute.modifier.value.get.success` | id, attribute, entity, value | The value of modifier %s on attribute %s for entity %s is %s | Q |
| `commands.attribute.failed.entity` | entity | %s is not a valid entity for this command | error |
| `commands.attribute.failed.no_attribute` | entity, attribute | Entity %s has no attribute %s | error |
| `commands.attribute.failed.no_modifier` | attribute, entity, id | Attribute %s for entity %s has no modifier %s | error |
| `commands.attribute.failed.modifier_already_present` | id, attribute, entity | Modifier %s is already present on attribute %s for entity %s | error |

### 5.13 `experience` (alias `xp`)

Level 2. `xp` is a redirect to `experience`.

```
experience add <target:players> <amount:integer> [points|levels]        (default points)
experience set <target:players> <amount:integer min 0> [points|levels]  (default points)
experience query <target:player> points|levels
```

`add` accepts any integer (negative values subtract, since the grammar has no minimum); `set` requires >= 0. All forms use the tracker (one tracked entry per player for which the operation succeeded); the single message is sent for one player, the multiple message with the count otherwise; zero tracked players makes the command fail with the upstream error. Result = tracker total for `add` and `set`, and for `query` the queried value. Specifics read: `set points` succeeds only if the amount is below the points needed for the player's next level (`getXpNeededForNextLevel`), then calls `setExperiencePoints`; otherwise (and when no player qualifies) error `commands.experience.set.points.invalid`. `set levels` calls `setExperienceLevels`. `query points` returns floor(experience progress fraction x points needed for the next level), i.e. the points inside the current level; `query levels` returns the level. When neither `points` nor `levels` is typed, the unit is POINTS (read, for both `add` and `set`).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.experience.add.points.success.single` | amount, display name | Gave %s experience points to %s | **B** |
| `commands.experience.add.points.success.multiple` | amount, count | Gave %s experience points to %s players | **B** |
| `commands.experience.add.levels.success.single` | amount, display name | Gave %s experience levels to %s | **B** |
| `commands.experience.add.levels.success.multiple` | amount, count | Gave %s experience levels to %s players | **B** |
| `commands.experience.set.points.success.single` | amount, display name | Set %s experience points on %s | **B** |
| `commands.experience.set.points.success.multiple` | amount, count | Set %s experience points on %s players | **B** |
| `commands.experience.set.levels.success.single` | amount, display name | Set %s experience levels on %s | **B** |
| `commands.experience.set.levels.success.multiple` | amount, count | Set %s experience levels on %s players | **B** |
| `commands.experience.set.points.invalid` | | Cannot set experience points above the maximum points for the player's current level | error |
| `commands.experience.query.points` | display name, points | %s has %s experience points | Q |
| `commands.experience.query.levels` | display name, levels | %s has %s experience levels | Q |

### 5.14 `swing`

Level 2.

```
swing <targets:entities> mainhand|offhand
swing <targets> <animation:swing_animation> <duration:time(min 1)>     (animation: none, whack, stab)
```

Makes living entities swing; `failed.notliving` shows non-living targets are skipped. Result: not read for `swing`.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.swing.success.single` | display name | Made %s swing an arm | **B** |
| `commands.swing.success.multiple` | count | Made %s entities swing their arms | **B** |
| `commands.swing.failed.notliving` | | No living entities were found to swing | error |

(The registration builds a hand literal helper; the two hand literals are `mainhand` and `offhand`.)

### 5.15 `waypoint`

Level 2.

```
waypoint list
waypoint modify <waypoint:entity> color <color:team_color>
waypoint modify <waypoint> color hex <color:hex_color>
waypoint modify <waypoint> color reset
waypoint modify <waypoint> style reset
waypoint modify <waypoint> style set <style:identifier>
```

Waypoint entities (the `locator_bar` game rule is read by `ServerWaypointManager` and `MinecraftServer`). `list` lists waypoints of the level with clickable coordinates.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.waypoint.list.success` | count, dimension id, list | %s waypoint(s) in %s: %s | Q |
| `commands.waypoint.list.empty` | dimension id | No waypoints in %s | Q |
| `commands.waypoint.modify.color` | colour | Waypoint color is now %s | Q |
| `commands.waypoint.modify.color.reset` | | Reset waypoint color | Q |
| `commands.waypoint.modify.style` | | Waypoint style changed | Q |
| `chat.coordinates` | x, y, z | %s, %s, %s | list entry text |
| `chat.coordinates.tooltip` | | Click to teleport | hover text of a list entry |

---

## 6. Items and inventory

### 6.1 `give`

Level 2. `give <targets:players> <item:item_stack> [<count:integer min 1>]` (default count 1). The `<item>` argument accepts `id[component=value,...]` (15 framework: argument types, item stack).

Rules read: the requested count may not exceed **100 times the item's maximum stack size** (`give.failed.toomanyitems`, arguments max count and item name). For each target the items are given in stacks of at most the maximum stack size; each stack is added to the inventory; whatever does not fit is dropped as an item entity at the player with no pickup delay and the player as the only allowed picker (the entity is "owned" by the player); a fully inserted stack makes a fake item entity effect and plays the item-pickup sound at the player (source PLAYERS, volume 0.2, pitch ((r1 - r2) x 0.7 + 1) x 2 where r1 and r2 are two `nextFloat` draws from the player's random source; read) and the container is synchronised. Tracker value per player = count given. Result = tracker total (inferred).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.give.success.single` | count, item display name, player display name | Gave %s %s to %s | **B** |
| `commands.give.success.multiple` | count, item display name, player count | Gave %s %s to %s players | **B** |
| `commands.give.failed.toomanyitems` | max, item display name | Can't give more than %s of %s | error |

### 6.2 `clear`

Level 2.

```
clear                                               -> the source player's inventory
clear <targets:players>
clear <targets> <item:item_predicate>
clear <targets> <item> <maxCount:integer min 0>
```

Removes matching items from the target's inventory (read: `Inventory.clearOrCountMatchingItems` scans, in order, the main inventory container, the crafting container passed in, and the player's carried (cursor) stack, which is cleared and re-set); without a predicate, everything. `maxCount` 0 means "count only" (nothing is removed; the test messages are used). `maxCount` (read): the routine's test-only flag is true exactly when `maxCount` is 0; the no-limit forms pass -1. Read: for each player the routine `Inventory.clearOrCountMatchingItems(predicate, maxCount, crafting-grid container)` is called with maxCount -1 when no limit is given, tracking the matched count as the element value; when `maxCount` is 0 nothing is removed and the test messages are used; otherwise the container is synchronised with the client. If the tracked total is 0 the command fails with `clear.failed.single` or `clear.failed.multiple` (argument: the player display name, or the player count). Otherwise the success or test message is sent (**B**; single message when exactly one player had a non-zero count). Result = the total number of items matched (removed, or counted when `maxCount` is 0).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.clear.success.single` | count, player display name | Removed %s item(s) from player %s | **B** |
| `commands.clear.success.multiple` | count, player count | Removed %s item(s) from %s players | **B** |
| `commands.clear.test.single` | count, player display name | Found %s matching item(s) on player %s | **B**, maxCount 0 |
| `commands.clear.test.multiple` | count, player count | Found %s matching item(s) on %s players | **B**, maxCount 0 |
| `clear.failed.single` | player display name | No items were found on player %s | error |
| `clear.failed.multiple` | player count | No items were found on %s players | error |

### 6.3 `item`

Level 2. In 26.3 the set family has three verbs (`replace`, `fill`, `override`), all built by one helper; `modify` is separate. `<slots>` is a slot-source argument (it may name several slots, for example `container.*`; 15 framework: slots); `<count>` is `integer(1..99)`.

```
item <verb> <holder> <slots> with <item:item_stack> [<count:integer 1..99>]
item <verb> <holder> <slots> from <holder> <sourceSlots> [<modifier:item_modifier>]
item modify <holder> <slots> <modifier:item_modifier>

<verb>   := replace | fill | override
<holder> := block <pos> | entity <targets:entities>        (for `from`, the source entity form is <sourceEntities>)
```

The verb chooses how the source items are laid onto the target slots (the source is a list of stacks): The code shows three item-distribution strategies named after the verbs: `replace` uses `ItemProvider.of(stacks)`; `fill` uses `ItemProvider.cycle(stacks)` (the stacks repeat over the slots); `override` uses `of(stacks)` followed by `orElseProvide(ItemStack.EMPTY)`, so once the supplied stacks run out the remaining selected slots are set to empty (read). `modify` runs an item modifier (loot function) over the stack in each selected slot and writes the result back. A block holder must be a container block entity; an entity holder accepts only the slots it has.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.item.block.replace.success` | slots changed, x, y, z | Replaced %s slot(s) at %s, %s, %s | **B** |
| `commands.item.block.replace.success.known_item` | slots changed, x, y, z, item | Replaced %s slot(s) at %s, %s, %s with %s | **B** |
| `commands.item.block.modify.success` | slots, x, y, z | Modified %s slot(s) at %s, %s, %s | **B** |
| `commands.item.entity.replace.success.single` | slots, entity | Replaced %s slot(s) on %s | **B** |
| `commands.item.entity.replace.success.single.known_item` | slots, entity, item | Replaced %s slot(s) on %s with %s | **B** |
| `commands.item.entity.replace.success.multiple` | entity count | Replaced slot(s) on %s entities | **B** |
| `commands.item.entity.replace.success.multiple.known_item` | entity count, item | Replaced slot(s) on %s entities with %s | **B** |
| `commands.item.entity.modify.success.single` | slots, entity | Modified %s slot(s) on %s | **B** |
| `commands.item.entity.modify.success.multiple` | entity count | Modified slot(s) on %s entities | **B** |
| `commands.item.target.not_a_container` | x, y, z | Target position %s, %s, %s is not a container | error |
| `commands.item.source.not_a_container` | x, y, z | Source position %s, %s, %s is not a container | error |
| `commands.item.target.no_such_slot` | slot name | The target does not have slot %s | error |
| `commands.item.source.no_such_slot` | slot name | The source does not have slot %s | error |
| `commands.item.target.no_such_slot.unnamed` | | The target does not have specified slots | error |
| `commands.item.source.no_such_slot.unnamed` | | The source does not have specified slots | error |
| `commands.item.target.failed` | | No targets accepted items into specified slots | error |
| `commands.item.target.failed.known_item` | item | No targets accepted item %s into specified slots | error |

Result not traced. Slot names, read from `SlotRanges` (a name with a trailing `.` takes an index suffix): `contents` (single slot 0); `container.0` to `container.53`; `hotbar.0` to `hotbar.8`; `inventory.0` to `inventory.26`; `enderchest.0` to `enderchest.26` (internal ids from 200); `mob.inventory.0` to `mob.inventory.7` (from 300); `horse.0` to `horse.14` (from 500); `weapon.mainhand`, `weapon.offhand`, the range `weapon.*`; `armor.head`, `armor.chest`, `armor.legs`, `armor.feet`, `armor.body`, the range `armor.*`; `saddle`; `horse.chest`; `player.cursor`; `player.crafting.0` to `player.crafting.3`. Numeric internal ids of the equipment and misc slots were not fully decoded. See also (the framework table is in in 15 framework: slots; open question 17).

### 6.4 `loot`

Level 2. Target part, then source part.

```
loot <target> <source>

<target> :=
    replace entity <entities> <slot> [<count:integer min 0>]
  | replace block <targetPos> <slot> [<count>]
  | insert <targetPos>
  | give <players>
  | spawn <targetPos:vec3>

<source> :=
    fish <loot_table> <pos:block_pos> [<tool:item_stack> | mainhand | offhand]
  | loot <loot_table>
  | kill <target:entity>
  | mine <pos:block_pos> [<tool:item_stack> | mainhand | offhand]
```

Rolls the source loot table (loot generation is out of scope) and delivers the items to the target (set slots; insert into a container; give to players' inventories with the same drop-leftovers rule as `give`; spawn as item entities). Loot generation itself is a gameplay system (loot tables, 1447 files in `data/minecraft/loot_table/`); this document specifies only the command layer (see 17).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.drop.success.single` | count, item display name | Dropped %s %s | Q, no table name |
| `commands.drop.success.single_with_table` | count, item, table id | Dropped %s %s from loot table %s | Q |
| `commands.drop.success.multiple` | count | Dropped %s items | Q |
| `commands.drop.success.multiple_with_table` | count, table id | Dropped %s items from loot table %s | Q |
| `commands.drop.no_held_items` | | Entity can't hold any items | error |
| `commands.drop.no_loot_table.block` | block name | Block %s has no loot table | error (`mine`) |
| `commands.drop.no_loot_table.entity` | entity name | (the lang file has `commands.drop.no_loot_table` "Entity %s has no loot table"; the artifact builds the key with the `.entity` suffix, whose text is absent from en_us, see 17) | error (`kill`) |

The `<count>` fills `Math.min(count, number of stacks)` slots starting at `<slot>` (read). Same messages (`commands.item.*`) are used for `replace` targets; `give` uses `commands.drop.success.*`. Result not traced.

### 6.5 `recipe`

Level 2.

```
recipe give <targets:players> <recipe:resource_key recipe>
recipe give <targets> *
recipe take <targets> <recipe>
recipe take <targets> *
```

Unlocks or forgets recipes (read: `ServerRecipeBook` uses the Recipe Book Add (05b 0x4B), Remove (0x4C) and Settings (0x4D) packets). `*` is every recipe (2042 recipe files in `data/minecraft/recipe/`). Result: not traced.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.recipe.give.success.single` | recipe count, display name | Unlocked %s recipe(s) for %s | **B** |
| `commands.recipe.give.success.multiple` | recipe count, player count | Unlocked %s recipe(s) for %s players | **B** |
| `commands.recipe.give.failed` | | No new recipes were learned | error |
| `commands.recipe.take.success.single` | count, display name | Took %s recipe(s) from %s | **B** |
| `commands.recipe.take.success.multiple` | count, player count | Took %s recipe(s) from %s players | **B** |
| `commands.recipe.take.failed` | | No recipes could be forgotten | error |

### 6.6 `advancement`

Level 2.

```
advancement (grant|revoke) <targets:players> only <advancement:resource_key> [<criterion:greedy string>]
advancement (grant|revoke) <targets> from <advancement>
advancement (grant|revoke) <targets> until <advancement>
advancement (grant|revoke) <targets> through <advancement>
advancement (grant|revoke) <targets> everything
```

`only` affects one advancement (or one criterion of it; suggestions list that advancement's criteria); `from` the advancement and all its descendants; `until` the advancement and all its ancestors; `through` ancestors, itself and descendants; `everything` all. `grant` completes all remaining criteria; `revoke` removes progress. Unknown criterion: error `commands.advancement.criterionNotFound` ("The advancement %1$s does not contain the criterion '%2$s'"). The feedback key is `commands.advancement.<grant|revoke>.<criterion|one|many>.to.<one|many>.<success|failure>`, where the middle word is `criterion` for `only <adv> <criterion>`, `one` for `only <adv>`, `many` for the other modes, and `to.one`/`to.many` is the number of target players. Success is **B**; failure is an error (nothing changed). Result not traced.

| Key | Arguments | English |
|---|---|---|
| `commands.advancement.grant.criterion.to.one.success` | criterion, advancement, player | Granted criterion '%s' of advancement %s to %s |
| `commands.advancement.grant.criterion.to.many.success` | criterion, advancement, count | Granted criterion '%s' of advancement %s to %s players |
| `commands.advancement.grant.criterion.to.one.failure` | criterion, advancement, player | Couldn't grant criterion '%s' of advancement %s to %s as they already have it |
| `commands.advancement.grant.criterion.to.many.failure` | criterion, advancement, count | Couldn't grant criterion '%s' of advancement %s to %s players as they already have it |
| `commands.advancement.grant.one.to.one.success` | advancement, player | Granted the advancement %s to %s |
| `commands.advancement.grant.one.to.many.success` | advancement, count | Granted the advancement %s to %s players |
| `commands.advancement.grant.one.to.one.failure` | advancement, player | Couldn't grant advancement %s to %s as they already have it |
| `commands.advancement.grant.one.to.many.failure` | advancement, count | Couldn't grant advancement %s to %s players as they already have it |
| `commands.advancement.grant.many.to.one.success` | number, player | Granted %s advancements to %s |
| `commands.advancement.grant.many.to.many.success` | number, count | Granted %s advancements to %s players |
| `commands.advancement.grant.many.to.one.failure` | number, player | Couldn't grant %s advancements to %s as they already have them |
| `commands.advancement.grant.many.to.many.failure` | number, count | Couldn't grant %s advancements to %s players as they already have them |
| `commands.advancement.revoke.criterion.to.one.success` | criterion, advancement, player | Revoked criterion '%s' of advancement %s from %s |
| `commands.advancement.revoke.criterion.to.many.success` | criterion, advancement, count | Revoked criterion '%s' of advancement %s from %s players |
| `commands.advancement.revoke.criterion.to.one.failure` | criterion, advancement, player | Couldn't revoke criterion '%s' of advancement %s from %s as they don't have it |
| `commands.advancement.revoke.criterion.to.many.failure` | criterion, advancement, count | Couldn't revoke criterion '%s' of advancement %s from %s players as they don't have it |
| `commands.advancement.revoke.one.to.one.success` | advancement, player | Revoked the advancement %s from %s |
| `commands.advancement.revoke.one.to.many.success` | advancement, count | Revoked the advancement %s from %s players |
| `commands.advancement.revoke.one.to.one.failure` | advancement, player | Couldn't revoke advancement %s from %s as they don't have it |
| `commands.advancement.revoke.one.to.many.failure` | advancement, count | Couldn't revoke advancement %s from %s players as they don't have it |
| `commands.advancement.revoke.many.to.one.success` | number, player | Revoked %s advancements from %s |
| `commands.advancement.revoke.many.to.many.success` | number, count | Revoked %s advancements from %s players |
| `commands.advancement.revoke.many.to.one.failure` | number, player | Couldn't revoke %s advancements from %s as they don't have them |
| `commands.advancement.revoke.many.to.many.failure` | number, count | Couldn't revoke %s advancements from %s players as they don't have them |

Dependency: the advancement system (1866 definitions in `data/minecraft/advancement/`) is out of scope here.

---

## 7. World editing

All commands in this section are level 2. Position arguments: `<pos>` is a block position, `<from>`/`<to>`/`<begin>`/`<end>` are block positions, a `ColumnPos` is an x/z pair of integers (15 framework: positions). The limit on blocks changed per command is the game rule `max_block_modifications` (section 13; default 32768); the exact comparison for each command is stated as "(inferred)" when not traced.

**Block update flags** (`Block.UPDATE_*`, read from the class constants; they are combined with bitwise OR and passed to the level's block setter):

| Constant | Value | Meaning of the bit |
|---|---|---|
| `UPDATE_NEIGHBORS` | 1 | update neighbouring blocks |
| `UPDATE_CLIENTS` | 2 | send the change to clients |
| `UPDATE_INVISIBLE` | 4 | clients are not told (invisible change) |
| `UPDATE_IMMEDIATE` | 8 | re-render immediately on the client |
| `UPDATE_KNOWN_SHAPE` | 16 | the shape is known: skip shape updates |
| `UPDATE_SUPPRESS_DROPS` | 32 | do not drop items when replacing |
| `UPDATE_MOVE_BY_PISTON` | 64 | the change comes from a piston move |
| `UPDATE_SKIP_SHAPE_UPDATE_ON_WIRE` | 128 | skip shape update on redstone wire |
| `UPDATE_SKIP_BLOCK_ENTITY_SIDEEFFECTS` | 256 | skip block-entity side effects |
| `UPDATE_SKIP_ON_PLACE` | 512 | skip the block's on-place hook |
| `UPDATE_NONE` | 260 | 4 + 256 |
| `UPDATE_ALL` | 3 | 1 + 2 |
| `UPDATE_ALL_IMMEDIATE` | 11 | 1 + 2 + 8 |
| `UPDATE_SKIP_ALL_SIDEEFFECTS` | 816 | 512 + 256 + 32 + 16 |
| `UPDATE_LIMIT` | 512 | limit constant |

(The bit descriptions in the third column are the constants' names restated; the constants' values are the read facts.) Flags used by the commands: `setblock` and `fill` place with `2 | (strict ? 816 : 256)` (read: `iconst_2` ORed with 816 or 256); `clone` uses a base flag of `2 | (strict ? 816 : 0)`, barrier-clearing passes use that base ORed with 816, and the `move` clearing pass sets air with `strict ? base : 3`.

### 7.1 `setblock`

```
setblock <pos> <block:block_state> [destroy | keep | replace | strict]
```

Read: with no mode literal, and with `replace`, the mode is REPLACE with strict false; `strict` is REPLACE with strict true; `destroy` is the DESTROY mode; `keep` is REPLACE with a predicate that accepts the position only when the block there is empty (air): `LevelReader.isEmptyBlock`, read). Routine: in a debug-world level the command fails; if the predicate rejects the position the command fails; in DESTROY mode the old block is destroyed with drops (`destroyBlock`) before placing; the block is then placed with update flags `2 | 816` when strict, else `2 | 256` (see the flag table above); if placement is refused the command fails; neighbours are updated when the old and new block states differ in airness (the exact condition was not traced). Result 1 on success.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.setblock.success` | x, y, z | Changed the block at %s, %s, %s | **B** |
| `commands.setblock.failed` | | Could not set the block | error |

The position must be loaded (framework error `argument.pos.unloaded`: "That position is not loaded", see 15 framework: positions).

### 7.2 `fill`

```
fill <from> <to> <block> [outline | hollow | destroy | strict]
fill <from> <to> <block> replace [<filter:block_predicate> [outline | hollow | destroy | strict]]
fill <from> <to> <block> keep
```

(Read from the registration: the mode literals `outline`, `hollow`, `destroy`, `strict` are attached to `<block>` and to `<filter>`; `replace` and `keep` are literals under `<block>`; `replace` is itself executable without a filter.)

Rules read from `fillBlocks`: both corners must be in loaded chunks (block-position argument error `argument.pos.unloaded`); the box volume (x span times y span times z span, as a long) must not exceed the game rule `max_block_modifications`, else `commands.fill.toobig` (arguments: the rule value, the volume); a debug-world level fails with `commands.fill.failed`. Every position in the box is visited. Modes:

| Form | Mode | Position filter | Block placed at accepted positions |
|---|---|---|---|
| `<block>` alone, `replace` alone | REPLACE | none | the block |
| `<block> replace <filter>` | REPLACE | block predicate `<filter>` tested on the existing block | the block |
| `<block> keep` | REPLACE | existing block must be empty (`isEmptyBlock`) | the block |
| `outline` | OUTLINE | every position is visited; the block is placed only on the box faces, i.e. where x, y or z equals the box minimum or maximum; interior positions are skipped | the block |
| `hollow` | HOLLOW | faces get the block; interior positions are replaced with air | the block on faces, air inside |
| `destroy` | DESTROY | none | the old block is first destroyed as if broken with drops (`destroyBlock(pos, true)`), then the block is placed |
| `strict` (a flag, combinable with outline/hollow/destroy as a trailing literal) | the mode of the preceding word | as that mode | placement uses update flags 2 OR 816 instead of 2 OR 256, and the post-loop neighbour updates are not run |

(The `<filter>` branch can be followed by `outline`, `hollow`, `destroy` or `strict`; REPLACE is the default.) Without `strict`, each placed position is remembered and after the loop `updateNeighboursOnBlockSet` is called for each. A position counts toward the result when the block was placed or when the DESTROY step reported a change. Result = that count; if it is 0 the command fails with `commands.fill.failed`.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.fill.success` | count | Successfully filled %s block(s) | **B** |
| `commands.fill.failed` | | No blocks were filled | error |
| `commands.fill.toobig` | max, requested | Too many blocks in the specified area (maximum %s, but specified %s) | error |

Result: the count described above.

### 7.3 `fillbiome`

```
fillbiome <from> <to> <biome:resource biome> [replace <filter:biome or #tag>]
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.fillbiome.success.count` | count, x1, y1, z1, x2, y2, z2 | %s biome entry/entries set between %s, %s, %s and %s, %s, %s | **B** |
| `commands.fillbiome.toobig` | max, requested | Too many blocks in the specified volume (maximum %s, but specified %s) | error |
| `commands.fillbiome.no_changes` | | No biome entries were changed | error |
| `argument.pos.unloaded` | | That position is not loaded | error |

Rules read from `FillBiomeCommand`: both corners are quantised down to a multiple of 4 on every axis (`QuartPos.fromBlock` then `toBlock`); the box between the quantised corners must not exceed `max_block_modifications` in volume (`commands.fillbiome.toobig`, arguments: rule value, volume); every chunk column touched must be fully loaded (the chunk is requested at status FULL without loading; absent gives `argument.pos.unloaded`). For each such chunk the biome grid is re-evaluated: cells whose block position lies inside the box and which pass the filter (`replace <filter>`; absent means every cell passes) take the target biome; a cell is counted only when its current biome is not already the target. Chunks where something changed are marked unsaved and their biomes re-sent to clients (`ChunkMap.resendBiomesForChunks`). Result = number of cells changed; 0 gives `commands.fillbiome.no_changes`. The success message is sent with broadcast on and the quantised corner coordinates as arguments.

### 7.4 `clone`

Grammar (read from the registration and its three helper methods, with nesting reconstructed from the builder calls in order):

```
clone [from <sourceDimension:dimension>] <begin> <end> [to <targetDimension:dimension>] <destination> [strict] [<filter-mode>] [<move-mode>]

<filter-mode> := replace | masked | filtered <filter:block_predicate>
<move-mode>   := force | move | normal
```

Every node after `<destination>` is optional (each of `<destination>`, `strict`, `replace`, `masked`, `<filter>` is executable and carries the `force`/`move`/`normal` children). Without `from` the source dimension is the executing level; without `to` the target dimension is the executing level. `strict` is a literal placed after `<destination>` and before the filter mode; it sets a boolean passed to the clone routine. Default filter: accept every block (`replace` and no filter); `masked` accepts a block only when it is not air (the predicate named `FILTER_AIR`); `filtered` uses the given predicate. Default move-mode: `normal`.

Rules, in the order the routine checks them:

1. The source box is the box between `<begin>` and `<end>`; the destination box has the same size with its minimum corner at `<destination>`.
2. If the mode cannot overlap (`normal` cannot; `force` and `move` can), and source and destination are in the same dimension, and the boxes intersect: error `commands.clone.overlap`.
3. If the box volume exceeds the value of game rule `max_block_modifications`: error `commands.clone.toobig` with arguments (maximum, volume).
4. Both boxes must be in loaded chunks, else the framework error `argument.pos.unloaded`.
5. If the level is a debug world: error `commands.clone.failed`.
6. Each source position is tested with the filter against the block in the world; accepted positions are recorded with their block state, and (for block entities) their saved data and components. The recorded blocks are kept in three groups: blocks that have a block entity, blocks that are full solid (solid render or full-block collision shape), and others, with the groups processed in that order (the full blocks are inserted at the front of their queue, which affects placement order; exact ordering of equal groups was not further traced).
7. In `move` mode the source blocks are first cleared (read): the block-entity group and the other groups are first overwritten with barrier blocks using the flags (base | 816), which discards block-entity contents without drops, then every cleared position is set to air with the flags `strict ? base : 3`, where base is `2 | (strict ? 816 : 0)`.
8. The destination positions are written: first a barrier pass over the block-entity and other groups with flags (base | 816), then the block states and block-entity data with the flags `base`, then neighbours are updated (`updateNeighboursOnBlockSet`) for the written blocks, and the source's scheduled block ticks are copied to the destination (`LevelTicks.copyAreaFrom`).
9. If no block was written: error `commands.clone.failed`. Otherwise success.

Result = the number of blocks written. With `strict`, the base flag includes 816 (skip all side effects) instead of 0, as described in step 7 and the flag table.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.clone.success` | count | Successfully cloned %s block(s) | **B** |
| `commands.clone.failed` | | No blocks were cloned | error |
| `commands.clone.toobig` | max, volume | Too many blocks in the specified area (maximum %s, but specified %s) | error |
| `commands.clone.overlap` | | The source and destination areas cannot overlap | error |

### 7.5 `place`

```
place feature <feature:resource_or_id configured_feature> [<pos>]
place jigsaw <pool:resource_key> <target:identifier> <max_depth:integer 1..20> [<position>]
place structure <structure:resource_key> [<pos>]
place template <template:identifier> [<pos> [<rotation> [<mirror> [<integrity:float 0..1> [<seed:integer> [strict]]]]]]
```

(Optional `<pos>` shown where the tree has an executable node before it. Read: for `feature` and `structure` the omitted position is the block containing the source's position; `jigsaw` requires its `position`; for `template` the optional-position default was not read.) `<rotation>` and `<mirror>` are template-rotation and template-mirror arguments (15 framework: argument types).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.place.feature.success` | feature id, x, y, z | Placed "%s" at %s, %s, %s | **B** |
| `commands.place.feature.success.inline` | x, y, z | Placed feature at %s, %s, %s | **B** (inline feature given by value) |
| `commands.place.feature.failed` | | Failed to place feature | error |
| `commands.place.jigsaw.success` | x, y, z | Generated jigsaw at %s, %s, %s | **B** |
| `commands.place.jigsaw.failed` | | Failed to generate jigsaw | error |
| `commands.place.structure.success` | structure id, x, y, z | Generated structure "%s" at %s, %s, %s | **B** |
| `commands.place.structure.failed` | | Failed to place structure | error |
| `commands.place.template.success` | template id, x, y, z | Loaded template "%s" at %s, %s, %s | **B** |
| `commands.place.template.invalid` | template id | There is no template with ID "%s" | error |
| `commands.place.template.failed` | | Failed to place template | error |

Dependency: structures (1511 template files in `data/minecraft/structure/`), configured features and jigsaw pools (worldgen data in `data/minecraft/worldgen/`) are gameplay systems documented elsewhere (see 10 and 11 for terrain and caves; structures are an open question).

### 7.6 `forceload`

```
forceload add <from:column_pos> [<to:column_pos>]
forceload remove <from> [<to>]
forceload remove all
forceload query [<pos:column_pos>]
```

Marks chunks (by column) to stay loaded. Read: the x and z of both corners (block coordinates of the column positions) must lie in [-30000000, 30000000) otherwise the error is `BlockPosArgument.ERROR_OUT_OF_WORLD`; the number of chunks in the box may not exceed **256**, else `commands.forceload.toobig` (arguments: 256, count). `add` and `remove` call `setChunkForced` per chunk and track the returned boolean (value 1 or 0); the result is the number of chunks changed; zero changed gives the `...added.failure` / `...removed.failure` error. `remove all` clears every forced chunk (broadcast on) and returns 0. `query` with a position returns 1 when marked (quiet) and fails with `query.failure` otherwise; `query` without position lists the forced chunks (quiet; `list.single` for one, `list.multiple` otherwise) and returns the count, and when there are none it sends `commands.forceload.added.none` as a failure message (`sendFailure`, not an exception) and returns 0.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.forceload.added.single` | chunk pos, dimension id | Marked chunk %s in %s to be force loaded | **B** |
| `commands.forceload.added.multiple` | count, dimension, from, to | Marked %s chunks in %s from %s to %s to be force loaded | **B** |
| `commands.forceload.removed.single` | chunk pos, dimension | Unmarked chunk %s in %s for force loading | **B** |
| `commands.forceload.removed.multiple` | count, dimension, from, to | Unmarked %s chunks in %s from %s to %s for force loading | **B** |
| `commands.forceload.removed.all` | dimension | Unmarked all force loaded chunks in %s | **B** |
| `commands.forceload.query.success` | chunk pos, dimension | Chunk at %s in %s is marked for force loading | Q |
| `commands.forceload.query.failure` | chunk pos, dimension | Chunk at %s in %s is not marked for force loading | error |
| `commands.forceload.list.single` | dimension, chunk | A force loaded chunk was found in %s at: %s | Q (`query` without argument) |
| `commands.forceload.list.multiple` | count, dimension, list | %s force loaded chunks were found in %s at: %s | Q |
| `commands.forceload.added.none` | dimension | No force loaded chunks were found in %s | failure message (`sendFailure`) from `query` with none |
| `commands.forceload.toobig` | max, requested | Too many chunks in the specified area (maximum %s, but specified %s) | error |
| `commands.forceload.added.failure` | | No chunks were marked for force loading | error |
| `commands.forceload.removed.failure` | | No chunks were removed from force loading | error |

### 7.7 `locate`

```
locate structure <structure:resource_or_tag_key>
locate biome <biome:resource_or_tag>
locate poi <poi:resource_or_tag>
```

Rules read from `LocateCommand`: `structure` resolves the argument to a set of structure holders (an unknown id gives `commands.locate.structure.invalid`), then asks the level's chunk generator for the nearest map-style structure from the source's block position with a search radius of **100** (chunk units, as passed) and a skip-existing flag of false; none gives `commands.locate.structure.not_found`. `biome` searches with `findClosestBiome3d` using radius **6400** and horizontal and vertical steps of **32** and **64**; none gives `commands.locate.biome.not_found`. `poi` queries the point-of-interest manager for the closest match within radius **256** with occupancy ANY; none gives `commands.locate.poi.not_found`. On success the message is sent with broadcast **off** (the invoking source only); the coordinates argument is the translatable `chat.coordinates` with three arguments (x, y, z) wrapped in square brackets, coloured green, with a suggest-command click event whose text is `/tp @s <x> <y|~> <z>` (read) and the hover text `chat.coordinates.tooltip`. For `structure` and `poi` the Y shown is `~` and the distance is horizontal (computed from x and z only); for `biome` the Y is the real Y and the distance is the 3D distance. The distance argument is the floor of that distance. Result = that distance as an int.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.locate.structure.success` | structure name, coordinates, distance | The nearest %s is at %s (%s blocks away) | Q |
| `commands.locate.biome.success` | biome, coordinates, distance | The nearest %s is at %s (%s blocks away) | Q |
| `commands.locate.poi.success` | poi, coordinates, distance | The nearest %s is at %s (%s blocks away) | Q |
| `commands.locate.structure.not_found` | structure | Could not find a structure of type "%s" nearby | error |
| `commands.locate.structure.invalid` | structure | There is no structure with type "%s" | error |
| `commands.locate.biome.not_found` | biome | Could not find a biome of type "%s" within a reasonable distance | error |
| `commands.locate.poi.not_found` | poi | Could not find a point of interest of type "%s" within a reasonable distance | error |

### 7.8 `particle`

```
particle <name:particle> [<pos:vec3> [<delta:vec3> <speed:float min 0> <count:integer min 0> [force | normal] [<viewers:players>]]]
```

(Tree: `<pos>`, then `<delta>` (a vec3 with minimum 0 flag), `<speed>`, `<count>`, then optional `force`/`normal`, each optionally followed by `<viewers>`.) `force` makes the particle visible to viewers within 512 blocks, otherwise 32 blocks (read from the level's particle send routine).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.particle.success` | particle name | Displaying particle %s | **B** |
| `commands.particle.failed` | | The particle was not visible for anybody | error |

### 7.9 `playsound`

```
playsound <sound:identifier> <source> [<targets:players> [<pos:vec3> [<volume:float min 0> [<pitch:float 0..2> [<minVolume:float 0..1>]]]]]
```

Defaults (read): position = the source's position, volume 1.0, pitch 1.0, minVolume 0.0. `<source>` is a literal from the sound source list: `master`, `music`, `record`, `weather`, `block`, `hostile`, `neutral`, `player`, `ambient`, `voice`, `ui`. Sound ids are suggested from the sound registry.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.playsound.success.single` | sound, player | Played sound %s to %s | **B** |
| `commands.playsound.success.multiple` | sound, count | Played sound %s to %s players | **B** |
| `commands.playsound.failed` | | The sound is too far away to be heard | error |

### 7.10 `stopsound`

```
stopsound <targets:players> [* | <source>] [<sound:identifier>]
```

`*` means any source; `<source>` is one of the literals of 7.9.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.stopsound.success.source.sound` | sound, source | Stopped sound '%s' on source '%s' | **B** |
| `commands.stopsound.success.source.any` | source | Stopped all '%s' sounds | **B** |
| `commands.stopsound.success.sourceless.sound` | sound | Stopped sound '%s' | **B** |
| `commands.stopsound.success.sourceless.any` | | Stopped all sounds | **B** |

---

## 8. Chat and display

### 8.1 `say` (level 2) and 8.2 `me` (level 0)

```
say <message>
me <action:message>
```

Both resolve the message (embedded selectors) as a chat message and broadcast it to every player as a chat message with chat type `minecraft:say_command` or `minecraft:emote_command`. Result 1 (read). Chat type data (`data/minecraft/chat_type/`): `say_command` chat key `chat.type.announcement` ("[%s] %s": sender, content), narration `chat.type.text.narrate` ("%s says %s"); `emote_command` chat key `chat.type.emote` ("* %s %s": sender, content), narration the same key. No separate success message.

### 8.3 `msg`, `tell`, `w`

Level 0. `tell` and `w` redirect to `msg`.

```
msg <targets:players> <message>
```

(Result = number of targets, read; an empty target set is stopped upstream by the selector.) Sends each target a chat message of type `minecraft:msg_command_incoming` and sends the sender a copy of type `msg_command_outgoing` (one per target). Chat types: incoming key `commands.message.display.incoming` ("%s whispers to you: %s": sender, content), outgoing `commands.message.display.outgoing` ("You whisper to %s: %s": target, content); both have style grey and italic; narration key `chat.type.text.narrate`. If a message is fully filtered for a target, the sender receives the system message `PlayerList.CHAT_FILTERED_FULL` (text not read here). Result = number of targets.

### 8.4 `teammsg`, `tm`

Level 0. `tm` redirects to `teammsg`.

```
teammsg <message>
```

The sender must be on a team, else error `commands.teammsg.failed.noteam`. The message goes to every player on that team and is also echoed to the sender (sender excluded from the first group). Chat types: incoming `chat.type.team.text` ("%s <%s> %s": team name, sender, content), outgoing `chat.type.team.sent` ("-> %s <%s> %s"). The team name component carries hover text `chat.type.team.hover` ("Message Team") and a click action suggesting the text `/teammsg`. Result = number of recipient players (read: the size of the recipient list, which includes the sender).

| Key | English | When |
|---|---|---|
| `commands.teammsg.failed.noteam` | You must be on a team to message your team | error |

### 8.5 `list`

Level 0.

```
list
list uuids
```

Sends one Q message and returns the number of online players. `list` lists display names; `list uuids` lists each as "name (uuid)".

| Key | Arguments | English |
|---|---|---|
| `commands.list.players` | online count, max players, comma-separated list | There are %s of a max of %s players online: %s |
| `commands.list.nameAndId` | name, uuid | %s (%s) |

### 8.6 `help`

Level 0.

```
help
help <command:greedy_string>
```

`help` with no argument prints a usage line per command the source may run; with an argument it prints the usage of that command; unknown or non-permitted gives the error `commands.help.failed` "Unknown command or insufficient permissions". The usage line format is built by the command dispatcher's usage generator (15 framework: usage strings; not traced here).

### 8.7 `bossbar`

Level 2. Custom boss bars are stored by identifier (`<id:identifier>`; "custom bossbar").

```
bossbar add <id> <name:component>
bossbar remove <id>
bossbar list
bossbar set <id> name <name:component>
bossbar set <id> color pink|blue|red|green|yellow|purple|white
bossbar set <id> style progress|notched_6|notched_10|notched_12|notched_20
bossbar set <id> value <value:integer min 0>
bossbar set <id> max <max:integer min 1>
bossbar set <id> visible <visible:bool>
bossbar set <id> players [<targets:players>]
bossbar get <id> value|max|visible|players
```

`<id>` suggestions list the existing bars. Results (read): `add` and `remove` the number of custom bars afterwards; `list` the number of bars; `set value` and `set max` the argument; `set visible`, `color`, `style` and `name` 0; `set players` the number of players now on the bar; `get value` the value, `get max` the maximum, `get visible` 1 when visible and 0 when hidden (the message is sent with broadcast **on** for every `get`), `get players` the number of online players on the bar. Boss bar packets (05a Boss Event 0x09) are sent by the boss-event objects, not by the command class.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.bossbar.create.success` | bar | Created custom bossbar %s | **B** |
| `commands.bossbar.create.failed` | id | A bossbar already exists with the ID '%s' | error |
| `commands.bossbar.remove.success` | bar | Removed custom bossbar %s | **B** |
| `commands.bossbar.unknown` | id | No bossbar exists with the ID '%s' | error |
| `commands.bossbar.list.bars.none` | | There are no custom bossbars active | Q |
| `commands.bossbar.list.bars.some` | count, list | There are %s custom bossbar(s) active: %s | Q |
| `commands.bossbar.set.name.success` | bar | Custom bossbar %s has been renamed | **B** |
| `commands.bossbar.set.color.success` | bar | Custom bossbar %s has changed color | **B** |
| `commands.bossbar.set.style.success` | bar | Custom bossbar %s has changed style | **B** |
| `commands.bossbar.set.value.success` | bar, value | Custom bossbar %s has changed value to %s | **B** |
| `commands.bossbar.set.max.success` | bar, max | Custom bossbar %s has changed maximum to %s | **B** |
| `commands.bossbar.set.visible.success.visible` | bar | Custom bossbar %s is now visible | **B** |
| `commands.bossbar.set.visible.success.hidden` | bar | Custom bossbar %s is now hidden | **B** |
| `commands.bossbar.set.players.success.none` | bar | Custom bossbar %s no longer has any players | **B** |
| `commands.bossbar.set.players.success.some` | bar, count, list | Custom bossbar %s now has %s player(s): %s | **B** |
| `commands.bossbar.get.value` | bar, value | Custom bossbar %s has a value of %s | **B** |
| `commands.bossbar.get.max` | bar, max | Custom bossbar %s has a maximum of %s | **B** |
| `commands.bossbar.get.visible.visible` | bar | Custom bossbar %s is currently visible | **B** |
| `commands.bossbar.get.visible.hidden` | bar | Custom bossbar %s is currently hidden | **B** |
| `commands.bossbar.get.players.none` | bar | Custom bossbar %s has no players currently online | **B** |
| `commands.bossbar.get.players.some` | bar, count, list | Custom bossbar %s has %s player(s) currently online: %s | **B** |
| `commands.bossbar.set.name.unchanged` | | Nothing changed. That's already the name of this bossbar | error |
| `commands.bossbar.set.color.unchanged` | | Nothing changed. That's already the color of this bossbar | error |
| `commands.bossbar.set.style.unchanged` | | Nothing changed. That's already the style of this bossbar | error |
| `commands.bossbar.set.value.unchanged` | | Nothing changed. That's already the value of this bossbar | error |
| `commands.bossbar.set.max.unchanged` | | Nothing changed. That's already the maximum of this bossbar | error |
| `commands.bossbar.set.visibility.unchanged.visible` | | Nothing changed. The bossbar is already visible | error |
| `commands.bossbar.set.visibility.unchanged.hidden` | | Nothing changed. The bossbar is already hidden | error |
| `commands.bossbar.set.players.unchanged` | | Nothing changed. Those players are already on the bossbar with nobody to add or remove | error |

### 8.8 `tellraw`

Level 2. `tellraw <targets:players> <message:component>`. Sends the component to each target as a system chat message (not an overlay), after resolving selectors/scores/NBT in the component against the source. No success message. Result = number of players the component was sent to (read).

### 8.9 `title`

Level 2.

```
title <targets:players> clear
title <targets> reset
title <targets> title <title:component>
title <targets> subtitle <title:component>
title <targets> actionbar <title:component>
title <targets> times <fadeIn:time> <stay:time> <fadeOut:time>
```

Tracker semantics as in section 1 (single/multiple by player count).

| Key | Arguments | English |
|---|---|---|
| `commands.title.cleared.single` / `.multiple` | player / count | Cleared titles for %s / Cleared titles for %s players |
| `commands.title.reset.single` / `.multiple` | player / count | Reset title options for %s / Reset title options for %s players |
| `commands.title.show.title.single` / `.multiple` | player / count | Showing new title for %s / Showing new title for %s players |
| `commands.title.show.subtitle.single` / `.multiple` | player / count | Showing new subtitle for %s / Showing new subtitle for %s players |
| `commands.title.show.actionbar.single` / `.multiple` | player / count | Showing new actionbar title for %s / Showing new actionbar title for %s players |
| `commands.title.times.single` / `.multiple` | player / count | Changed title display times for %s / Changed title display times for %s players |

All **B** (broadcast flag true). Read: `clear` sends `ClientboundClearTitlesPacket(false)` and `reset` sends `ClientboundClearTitlesPacket(true)` (05a 0x0E, field resetTimes); `times` sends `ClientboundSetTitlesAnimationPacket` (05b 0x75); `title`, `subtitle` and `actionbar` send the Set Title Text (05b 0x74), Set Subtitle Text (05b 0x72) and Set Action Bar Text (05b 0x59) packets (inferred from the three response tables and the class names; the packet classes for these three are created through the lambda passed to `showTitle` and were not individually opened). The component is resolved against the target player (`getResolvedComponent`) for `title`, `subtitle` and `actionbar` (inferred). Result = the tracker total (number of players).

### 8.10 `dialog`

Level 2. `dialog show <targets:players> <dialog:resource_or_id dialog>` and `dialog clear <targets>`. Dialog definitions: 3 files in `data/minecraft/dialog/`. Messages (**B**): `commands.dialog.show.single` "Displayed dialog to %s", `commands.dialog.show.multiple` "Displayed dialog to %s players", `commands.dialog.clear.single` "Cleared dialog for %s", `commands.dialog.clear.multiple` "Cleared dialog for %s players". Needs the dialog screens (client) and Show Dialog / Clear Dialog packets (05a).

### 8.11 `posteffect`

Level 2.

```
posteffect add <targets:players> <posteffect:identifier>
posteffect remove <targets> <posteffect>
posteffect clear <targets>
posteffect list <target:player>
```

Client-side screen post-processing effects pushed by the server. Messages: `commands.posteffect.add.success.single`/`.multiple` ("Added post effect %s to %s" / "Added post effect %s to %s players"), `commands.posteffect.remove.success.single`/`.multiple` ("Removed post effect %s from %s" / "... from %s players"), `commands.posteffect.clear.success.single`/`.multiple` ("Removed all post effects from %s" / "Removed all post effects from %s players"), `commands.posteffect.list.success` ("Player %s has %s post effects: %s"), `commands.posteffect.list.empty` ("Player %s does not have any post effects"); errors `commands.posteffect.add.failed` ("Player already has the specified post effect"), `commands.posteffect.remove.failed` ("Player does not have the specified post effect"), `commands.posteffect.clear.failed` ("Player does not have any post effects to remove").

---

## 9. Scoreboard and teams

### 9.1 `scoreboard`

Level 2. Score holders (`<targets:score_holders>`) are entities by selector, player names or arbitrary strings, or `*` for every tracked holder (15 framework: score holder argument). Objective names (`<objective:word>` when creating) and existing objectives (`<objective:objective>`) are distinct argument types. Grammar:

```
scoreboard objectives list
scoreboard objectives add <objective:word> <criteria:criteria> [<displayName:component>]
scoreboard objectives remove <objective>
scoreboard objectives setdisplay <slot:display_slot> [<objective>]
scoreboard objectives modify <objective> displayname <displayName:component>
scoreboard objectives modify <objective> rendertype integer|hearts
scoreboard objectives modify <objective> displayautoupdate <value:bool>
scoreboard objectives modify <objective> numberformat [blank | fixed <contents:component> | styled <style:style>]
scoreboard players list [<target>]
scoreboard players set <targets> <objective> <score:integer>
scoreboard players get <target> <objective>
scoreboard players add <targets> <objective> <score:integer min 0>
scoreboard players remove <targets> <objective> <score:integer min 0>
scoreboard players reset <targets> [<objective>]
scoreboard players enable <targets> <objective>
scoreboard players operation <targets> <targetObjective> <operation> <source> <sourceObjective>
scoreboard players display name <targets> <objective> [<name:component>]
scoreboard players display numberformat <targets> <objective> [blank | fixed <contents> | styled <style>]
```

Display slots (`<slot>`): `list`, `sidebar`, `below_name`, and sixteen `sidebar.team.<colour>` slots for the colours `black`, `dark_blue`, `dark_green`, `dark_aqua`, `dark_red`, `dark_purple`, `gold`, `gray`, `dark_gray`, `blue`, `green`, `aqua`, `red`, `light_purple`, `yellow`, `white`. Render types: `integer`, `hearts`. The operation argument's operators (`=`, `+=` ...) are in 15 framework: argument types. `players enable` only works on objectives of the `trigger` criterion. Which optional branches are executable (the `[...]` above) follows the bare executable nodes read; branches that clear a value (`setdisplay` without objective, `numberformat` without argument, `reset` without objective, `display name` without name) are inferred from the paired "cleared" messages. Results (read): `objectives list` the number of objectives; `objectives add` and `remove` the number of objectives that exist afterwards; `objectives setdisplay` and every `modify` form 0; `players list` (no target) the number of tracked holders, `players list <target>` the number of scores listed; `players get` the score value; `players set|add|remove|reset|enable|operation` the tracker total (the value tracked per holder was not decoded; the messages are sent through the shared tracker); `players display name|numberformat` forms: tracker total. Message broadcast: list/get messages are quiet, every changing form is **B** (broadcast flag true).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.scoreboard.objectives.list.empty` | | There are no objectives | Q |
| `commands.scoreboard.objectives.list.success` | count, list | There are %s objective(s): %s | Q |
| `commands.scoreboard.objectives.add.success` | objective | Created new objective %s | **B** |
| `commands.scoreboard.objectives.add.duplicate` | | An objective already exists by that name | error |
| `commands.scoreboard.objectives.remove.success` | objective | Removed objective %s | **B** |
| `commands.scoreboard.objectives.display.set` | slot, objective | Set display slot %s to show objective %s | **B** |
| `commands.scoreboard.objectives.display.cleared` | slot | Cleared any objectives in display slot %s | **B** |
| `commands.scoreboard.objectives.display.alreadyEmpty` | | Nothing changed. That display slot is already empty | error |
| `commands.scoreboard.objectives.display.alreadySet` | | Nothing changed. That display slot is already showing that objective | error |
| `commands.scoreboard.objectives.modify.displayname` | objective, new name | Changed the display name of %s to %s | **B** |
| `commands.scoreboard.objectives.modify.rendertype` | objective | Changed the render type of objective %s | **B** |
| `commands.scoreboard.objectives.modify.displayAutoUpdate.enable` | objective | Enabled display auto-update for objective %s | **B** |
| `commands.scoreboard.objectives.modify.displayAutoUpdate.disable` | objective | Disabled display auto-update for objective %s | **B** |
| `commands.scoreboard.objectives.modify.objectiveFormat.set` | objective | Changed default number format of objective %s | **B** |
| `commands.scoreboard.objectives.modify.objectiveFormat.clear` | objective | Cleared default number format of objective %s | **B** |
| `commands.scoreboard.players.list.empty` | | There are no tracked entities | Q |
| `commands.scoreboard.players.list.success` | count, list | There are %s tracked entity/entities: %s | Q |
| `commands.scoreboard.players.list.entity.empty` | holder | %s has no scores to show | Q |
| `commands.scoreboard.players.list.entity.success` | holder, count | %s has %s score(s): | Q |
| `commands.scoreboard.players.list.entity.entry` | objective, score | %s: %s | Q (one per score) |
| `commands.scoreboard.players.get.success` | holder, score, objective | %s has %s %s | Q |
| `commands.scoreboard.players.get.null` | objective, holder | Can't get value of %s for %s; none is set | error |
| `commands.scoreboard.players.set.success.single` | objective, holder, score | Set %s for %s to %s | **B** |
| `commands.scoreboard.players.set.success.multiple` | objective, count, score | Set %s for %s entities to %s | **B** |
| `commands.scoreboard.players.add.success.single` | amount, objective, holder, new score | Added %s to %s for %s (now %s) | **B** |
| `commands.scoreboard.players.add.success.multiple` | amount, objective, count | Added %s to %s for %s entities | **B** |
| `commands.scoreboard.players.remove.success.single` | amount, objective, holder, new score | Removed %s from %s for %s (now %s) | **B** |
| `commands.scoreboard.players.remove.success.multiple` | amount, objective, count | Removed %s from %s for %s entities | **B** |
| `commands.scoreboard.players.reset.all.single` | holder | Reset all scores for %s | **B** |
| `commands.scoreboard.players.reset.all.multiple` | count | Reset all scores for %s entities | **B** |
| `commands.scoreboard.players.reset.specific.single` | objective, holder | Reset %s for %s | **B** |
| `commands.scoreboard.players.reset.specific.multiple` | objective, count | Reset %s for %s entities | **B** |
| `commands.scoreboard.players.enable.success.single` | objective, holder | Enabled trigger %s for %s | **B** |
| `commands.scoreboard.players.enable.success.multiple` | objective, count | Enabled trigger %s for %s entities | **B** |
| `commands.scoreboard.players.enable.failed` | | Nothing changed. That trigger is already enabled | error |
| `commands.scoreboard.players.enable.invalid` | | Enable only works on trigger-objectives | error |
| `commands.scoreboard.players.operation.success.single` | objective, holder, score | Set %s for %s to %s | **B** |
| `commands.scoreboard.players.operation.success.multiple` | objective, count | Updated %s for %s entities | **B** |
| `commands.scoreboard.players.display.name.set.success.single` | name, holder, objective | Changed display name to %s for %s in %s | **B** |
| `commands.scoreboard.players.display.name.set.success.multiple` | name, count, objective | Changed display name to %s for %s entities in %s | **B** |
| `commands.scoreboard.players.display.name.clear.success.single` | holder, objective | Cleared display name for %s in %s | **B** |
| `commands.scoreboard.players.display.name.clear.success.multiple` | count, objective | Cleared display name for %s entities in %s | **B** |
| `commands.scoreboard.players.display.numberFormat.set.success.single` | holder, objective | Changed number format for %s in %s | **B** |
| `commands.scoreboard.players.display.numberFormat.set.success.multiple` | count, objective | Changed number format for %s entities in %s | **B** |
| `commands.scoreboard.players.display.numberFormat.clear.success.single` | holder, objective | Cleared number format for %s in %s | **B** |
| `commands.scoreboard.players.display.numberFormat.clear.success.multiple` | count, objective | Cleared number format for %s entities in %s | **B** |

The argument order in the table is taken from the English placeholders; the artifact's actual argument order was not traced for every key (open question 17). Packets that follow score changes are sent by the scoreboard internals, not by this class; the corresponding packets are in 05a/05b: Set Objective 0x6C, Set Score 0x70, Reset Score 0x50, Set Display Objective 0x64 (the link from command to packet was not read).

### 9.2 `team`

Level 2. Team names are words (`<team:word>` when creating; `<team:team>` for existing).

```
team list [<team>]
team add <team:word> [<displayName:component>]
team remove <team>
team empty <team>
team join <team> [<members:score_holders>]
team leave <members:score_holders>
team modify <team> displayName <displayName:component>
team modify <team> color reset | <value:team_color>
team modify <team> friendlyFire <allowed:bool>
team modify <team> seeFriendlyInvisibles <allowed:bool>
team modify <team> nametagVisibility always|never|hideForOtherTeams|hideForOwnTeam
team modify <team> deathMessageVisibility always|never|hideForOtherTeams|hideForOwnTeam
team modify <team> collisionRule always|never|pushOtherTeams|pushOwnTeam
team modify <team> prefix <prefix:component>
team modify <team> suffix <suffix:component>
```

(`team join <team>` without members joins the source; `team add` without a name uses the team name as the display name; both are inferred from the executable-node positions.)

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.team.list.teams.empty` | | There are no teams | Q |
| `commands.team.list.teams.success` | count, list | There are %s team(s): %s | Q |
| `commands.team.list.members.empty` | team | There are no members on team %s | Q |
| `commands.team.list.members.success` | team, count, list | Team %s has %s member(s): %s | Q |
| `commands.team.add.success` | team | Created team %s | **B** |
| `commands.team.add.duplicate` | | A team already exists by that name | error |
| `commands.team.remove.success` | team | Removed team %s | **B** |
| `commands.team.empty.success` | count, team | Removed %s member(s) from team %s | **B** |
| `commands.team.empty.unchanged` | | Nothing changed. That team is already empty | error |
| `commands.team.join.success.single` | member, team | Added %s to team %s | **B** |
| `commands.team.join.success.multiple` | count, team | Added %s members to team %s | **B** |
| `commands.team.leave.success.single` | member | Removed %s from any team | **B** |
| `commands.team.leave.success.multiple` | count | Removed %s members from any team | **B** |
| `commands.team.option.name.success` | team | Updated the name of team %s | **B** |
| `commands.team.option.name.unchanged` | | Nothing changed. That team already has that name | error |
| `commands.team.option.color.success` | team, colour | Updated the color for team %s to %s | **B** |
| `commands.team.option.color.clear.success` | team | Cleared the color for team %s | **B** |
| `commands.team.option.color.unchanged` | | Nothing changed. That team already has that color | error |
| `commands.team.option.friendlyfire.enabled` | team | Enabled friendly fire for team %s | **B** (key = `commands.team.option.friendlyfire.` + `enabled`) |
| `commands.team.option.friendlyfire.disabled` | team | Disabled friendly fire for team %s | **B** |
| `commands.team.option.seeFriendlyInvisibles.enabled` | team | Team %s can now see invisible teammates | **B** (key built the same way) |
| `commands.team.option.seeFriendlyInvisibles.disabled` | team | Team %s can no longer see invisible teammates | **B** |
| `commands.team.option.friendlyfire.alreadyEnabled` / `.alreadyDisabled` | | Nothing changed. Friendly fire is already enabled for that team / ... disabled for that team | error |
| `commands.team.option.seeFriendlyInvisibles.alreadyEnabled` / `.alreadyDisabled` | | Nothing changed. That team can already see invisible teammates / ... already can't see invisible teammates | error |
| `commands.team.option.nametagVisibility.success` | team, value | Nametag visibility for team %s is now "%s" | **B** |
| `commands.team.option.nametagVisibility.unchanged` | | Nothing changed. Nametag visibility is already that value | error |
| `commands.team.option.deathMessageVisibility.success` | team, value | Death message visibility for team %s is now "%s" | **B** |
| `commands.team.option.deathMessageVisibility.unchanged` | | Nothing changed. Death message visibility is already that value | error |
| `commands.team.option.collisionRule.success` | team, value | Collision rule for team %s is now "%s" | **B** |
| `commands.team.option.collisionRule.unchanged` | | Nothing changed. Collision rule is already that value | error |
| `commands.team.option.prefix.success` | prefix | Team prefix set to %s | Q |
| `commands.team.option.suffix.success` | suffix | Team suffix set to %s | Q |

Read: `team modify` results are 0 for every option except `prefix` and `suffix` (1); `prefix` and `suffix` messages are quiet (broadcast off) while the other option messages are **B**; `add` and `remove` return the number of teams that exist afterwards; `empty` returns the number of members removed; `join` and `leave` use the tracker (total = members affected); `list` returns the number of teams or members listed. The success keys for `friendlyFire` and `seeFriendlyInvisibles` are built as a fixed prefix plus `enabled` or `disabled` (read: two string concatenations over those two words), giving the four keys in the table.

### 9.3 `trigger`

Level 0 (the source must be a player; the objective must be a `trigger` objective whose score for the player exists and is not locked, else `commands.trigger.failed.unprimed`; a non-trigger objective gives `failed.invalid`). Read: on success the player's score is locked (`ScoreAccess.lock`) before the value is changed, so a trigger can be used once per `scoreboard players enable`; `scoreboard players enable` unlocks the score (read: `scoreboard players enable` calls `ScoreAccess.unlock`). Results: simple form = the value returned by `add(1)` (the new value); `add` = the new value; `set` = the value argument.

```
trigger <objective:objective>                       (suggestions: triggerable objectives of the source)
trigger <objective> add <value:integer>
trigger <objective> set <value:integer>
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.trigger.simple.success` | objective | Triggered %s | **B** (no value form) |
| `commands.trigger.add.success` | objective, value | Triggered %s (added %s to value) | **B** |
| `commands.trigger.set.success` | objective, value | Triggered %s (set value to %s) | **B** |
| `commands.trigger.failed.unprimed` | | You cannot trigger this objective yet | error |
| `commands.trigger.failed.invalid` | | You can only trigger objectives that are 'trigger' type | error |

---

## 10. Data, functions and flow

### 10.1 `data`

Level 2. The holder (`<target>`) is one of three kinds, each adding a prefix to the grammar: `entity <target:entity>`, `block <pos>`, `storage <target:identifier>`. Operations:

```
data get <holder> [<path:nbt_path> [<scale:double>]]
data merge <holder> <nbt:compound>
data remove <holder> <path:nbt_path>
data modify <holder> <targetPath:nbt_path> (set | merge | append | prepend | insert <index:integer>) <source>

<source> := value <value:nbt_tag>
          | from <holder> [<sourcePath:nbt_path>]
          | string <holder> [<sourcePath> [<start:integer> [<end:integer>]]]
          | compute (float <provider:float_provider> | integer <provider:int_provider>)   (context sources: see 10.9)
```

(The `compute` source and the `string` source with start/end are read from the registration; `scale` multiplies a numeric value read by `get`.) Block holders must be block entities, entity holders must not be players for modification. Results (read): `get <holder>` (no path) returns 1; `get <holder> <path>` returns `floor(value x scale)` for a numeric tag (with the `scale` form; without it the same floor of the value), the size of a collection tag, the number of keys of a compound, or the length of a string (read: `NumericTag.doubleValue` with `Mth.floor`, `CollectionTag.size`, `CompoundTag.size`, `StringTag.value().length()`); any other kind gives `data.get.unknown`; `merge` returns 1; `remove` and `modify` return the number of items changed (`modify` returns the value computed by the manipulation, `remove` the count of removed elements). `get` messages are quiet (broadcast off); `merge`, `modify` and `remove` messages are **B**. The `get ... scale` printing uses `%.2f`. NBT path and tag syntax: 15 framework: NBT paths and 07.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.data.entity.modified` | entity | Modified entity data of %s | **B** |
| `commands.data.entity.query` | entity, data | %s has the following entity data: %s | Q (`get` without path) |
| `commands.data.entity.get` | path, entity, scale, value | %s on %s after scale factor of %s is %s | Q |
| `commands.data.entity.invalid` | | Unable to modify player data | error |
| `commands.data.block.modified` | x, y, z | Modified block data of %s, %s, %s | **B** |
| `commands.data.block.query` | x, y, z, data | %s, %s, %s has the following block data: %s | Q |
| `commands.data.block.get` | path, x, y, z, scale, value | %s on block %s, %s, %s after scale factor of %s is %s | Q |
| `commands.data.block.invalid` | | The target block is not a block entity | error |
| `commands.data.storage.modified` | id | Modified storage %s | **B** |
| `commands.data.storage.query` | id, data | Storage %s has the following contents: %s | Q |
| `commands.data.storage.get` | path, id, scale, value | %s in storage %s after scale factor of %s is %s | Q |
| `commands.data.merge.failed` | | Nothing changed. The specified properties already have these values | error |
| `commands.data.get.invalid` | path | Can't get %s; only numeric tags are allowed | error |
| `commands.data.get.unknown` | path | Can't get %s; tag doesn't exist | error |
| `commands.data.get.multiple` | | This argument accepts a single NBT value | error |
| `commands.data.modify.expected_object` | value | Expected an object: got %s | error |
| `commands.data.modify.expected_value` | value | Expected a value: got %s | error |
| `commands.data.modify.expected_list` | value | Expected a list: got %s | error |
| `commands.data.modify.invalid_index` | index | Invalid list index: %s | error |
| `commands.data.modify.invalid_substring` | start, end | Invalid substring indices: %s to %s | error |

### 10.2 `execute`

Level 2 (the registration builds the `execute` literal with `requires(LEVEL_GAMEMASTERS)` twice, in the two registration helpers; the inner `run` redirects to the root of the command tree). The framework document owns the full `execute` grammar and the redirect/fork mechanics (15 framework: execute grammar). The branches present in this version, read from the registration, for cross-checking that document:

* Modifiers: `as <targets>`, `at <targets>`, `positioned <pos>` / `positioned as <targets>` / `positioned over <heightmap>`, `rotated <rot>` / `rotated as <targets>`, `facing <pos>` / `facing entity <targets> <anchor>`, `align <axes:swizzle>`, `anchored <anchor>`, `in <dimension>`, `summon <entity>`, `on <relation>` with relations `owner`, `leasher`, `target`, `attacker`, `vehicle`, `controller`, `origin`, `passengers`.
* `if` / `unless` conditions: `block <pos> <predicate>`, `biome <pos> <biome or tag>`, `loaded <pos>`, `dimension <dimension>`, `score <target> <objective> (= | < | <= | > | >=) <source> <sourceObjective>`, `score <target> <objective> matches <range>`, `blocks <start> <end> <destination> (all | masked)`, `entity <entities>`, `predicate <predicate>`, `function <name:function>` (a sibling of `predicate`, forked per function result), `stopwatch <id> <range:float_range>` (new in this version), `data (block|entity|storage) <path>`, `items (block|entity) <slots> <item_predicate>`, `slots (block|entity) <slots>` (new in this version).
* `store (result | success)` into: `score <targets> <objective>`, `bossbar <id> (value | max)`, `data (block|entity|storage) <path> (int|float|short|long|double|byte) <scale>`.
* Condition-sensitive messages (when `execute if|unless` is the whole command, not followed by `run`): `commands.execute.conditional.pass` "Test passed", `commands.execute.conditional.pass_count` "Test passed. Count: %s", `commands.execute.conditional.fail` "Test failed", `commands.execute.conditional.fail_count` "Test failed. Count: %s"; `if blocks` volume too large: `commands.execute.blocks.toobig` "Too many blocks in the specified area (maximum %s, but specified %s)"; `commands.execute.function.instantiationFailure` "Failed to instantiate function %s: %s". The limit for `blocks` is the `max_block_modifications` rule value (inferred); the forking limits are `max_command_forks` and `max_command_sequence_length` (section 13).

### 10.3 `function`

Level 2.

```
function <name:function_or_tag> [<arguments:compound>]
function <name> with (block <pos> | entity <target> | storage <id>) [<path:nbt_path>]
```

Runs a data-pack function or function tag; macro functions need arguments from a compound or from a data holder with an optional path. The function engine (parsing `.mcfunction` files, macros, `return`, depth limits) is a gameplay-independent subsystem not specified here (see 17).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.function.scheduled.single` | function | Running function %s | **B** (queued; function run at the current tick) |
| `commands.function.scheduled.multiple` | list | Running functions %s | **B** |
| `commands.function.success.single` | command count, function | Executed %s command(s) from function '%s' | **B** |
| `commands.function.success.multiple` | command count, function count | Executed %s command(s) from %s functions | **B** |
| `commands.function.success.single.result` | result, function | Function '%2$s' returned %1$s | **B** (positional arguments) |
| `commands.function.success.multiple.result` | function count | Executed %s functions | **B** |
| `commands.function.result` | function, result | Function %s returned %s | **B** |
| `commands.function.scheduled.no_functions` | name | Can't find any functions for name %s | error |
| `commands.function.instantiationFailure` | function, reason | Failed to instantiate function %s: %s | error |
| `commands.function.error.argument_not_compound` | type | Invalid argument type: %s. Expected Compound | error |
| `commands.function.error.missing_argument` | function, argument | Missing argument %2$s to function %1$s | error |
| `commands.function.error.missing_arguments` | function | Missing arguments to function %s | error |
| `commands.function.error.parse` | function, command, error | While instantiating macro %s: Command '%s' caused error: %s | error |

### 10.4 `schedule`

Level 2.

```
schedule function <function:function_or_tag> <time:time> [append | replace]
schedule clear <function:identifier>
```

Schedules a function (or tag) to run after `time` ticks, relative to the game time. `replace` (the default: the plain form and `replace` both pass true, `append` passes false; read) replaces an existing schedule with the same id; `append` adds. A macro function cannot be scheduled; a time of 0 cannot be scheduled (same tick).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.schedule.created.function` | function, ticks, game time | Scheduled function '%s' in %s tick(s) at gametime %s | **B** |
| `commands.schedule.created.tag` | tag, ticks, game time | Scheduled tag '%s' in %s tick(s) at gametime %s | **B** |
| `commands.schedule.cleared.success` | count, id | Removed %s schedule(s) with ID %s | **B** |
| `commands.schedule.cleared.failure` | id | No schedules with ID %s | error |
| `commands.schedule.same_tick` | | Can't schedule for current tick | error |
| `commands.schedule.macro` | | Can't schedule a macro | error |

### 10.5 Result conventions

`execute store result|success` records the integer result of the inner command (success stores 1 or 0). A command that throws counts as failure with result 0. Each section above states the result where it was read; "not traced" results are open (17).

### 10.6 `return`

Level 2.

```
return <value:integer>
return fail
return run <command>
```

Only meaningful inside a function (or as the whole command, where it just yields the value): sets the function's result and stops it; `fail` reports failure to the source's result callback and makes the current function frame return failure (read: `onFailure`, `Frame.returnFailure`, then the frame is discarded); `run` runs the command and returns its result. No feedback message.

### 10.8 `random`

Level 0 for `value` and `roll`; `reset` requires level 2.

```
random value <range:int_range> [<sequence:identifier>]
random roll <range> [<sequence>]
random reset *  [<seed:integer> [<includeWorldSeed:bool> [<includeSequenceId:bool>]]]
random reset <sequence> [<seed> [<includeWorldSeed> [<includeSequenceId>]]]
```

`value` draws a number in the range and reports it privately; `roll` announces it to all players through `PlayerList.broadcastSystemMessage(message, false)` (the false is the overlay parameter). Read: when no `<sequence>` is given the command uses the executing level's random source (`ServerLevel.getRandom`); with a sequence it uses `MinecraftServer.getRandomSequence(id)`. The range is `<min>..<max>` with a missing bound defaulting to the int minimum or maximum; the checks are: max must be greater than min (else `range_too_small`), and (max - min) as a long must be below 2147483647 (else `range_too_large`); the drawn value is `Mth.randomBetweenInclusive(random, min, max)`, and the result is that value. `roll` announces through the player list to every player (`getPlayerList().broadcastSystemMessage`) the message with the source's display name, the value, min and max; `value` sends `random.sample.success` quietly to the source. Range errors: a range of fewer than 1 or more than 2147483647 values.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.random.sample.success` | value | Randomized value: %s | Q (`value`) |
| `commands.random.roll` | player, value, min, max | %s rolled %s (from %s to %s) | all players (`PlayerList.broadcastSystemMessage(msg, false)`; not a feedback flag) |
| `commands.random.reset.success` | sequence | Reset random sequence %s | Q |
| `commands.random.reset.all.success` | count | Reset %s random sequence(s) | Q |
| `commands.random.error.range_too_small` | | The range of the random value must be at least 1 | error |
| `commands.random.error.range_too_large` | | The range of the random value must be at most 2147483647 | error |

The sequence generator algorithm and the meaning of the seed flags are inside `MinecraftServer`/the random-sequence store and were not read.

### 10.9 `compute`

Level 2. Evaluates number providers (`data/minecraft/context_float_provider`, `context_int_provider`; 4 and 26 files).

```
compute float <provider:float_provider> [<scale:float>]        (preceded by context-source nodes)
compute integer <provider:int_provider>
```

The registration also builds a helper that adds "context source" nodes before the provider (the sources that give the provider a position/entity context were not traced; see 17).

| Key | Arguments | English |
|---|---|---|
| `command.compute.result.named.exact` | provider id, value | %s returned value %s |
| `command.compute.result.named.rounded` | provider id, value, rounded | %s returned value %s (rounded to %s) |
| `command.compute.result.named.invalid` | provider id, value | %s returned invalid value (%s) |
| `command.compute.result.unnamed.exact` | value | Number provider returned value %s |
| `command.compute.result.unnamed.rounded` | value, rounded | Number provider returned value %s (rounded to %s) |
| `command.compute.result.unnamed.invalid` | value | Number provider returned invalid value (%s) |

(The key prefix is `command.compute...`, singular `command`, as read.)

### 10.10 `stopwatch`

Level 2.

```
stopwatch create <id:identifier>
stopwatch query <id> [<scale:double>]
stopwatch restart <id>
stopwatch remove <id>
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.stopwatch.create.success` | id | Created stopwatch '%s' | **B** |
| `commands.stopwatch.query` | id, seconds | Stopwatch '%s' has run for %ss | **B** |
| `commands.stopwatch.restart.success` | id | Restarted stopwatch '%s' | **B** |
| `commands.stopwatch.remove.success` | id | Removed stopwatch '%s' | **B** |
| `commands.stopwatch.already_exists` | id | Stopwatch '%s' already exists | error |
| `commands.stopwatch.does_not_exist` | id | Stopwatch '%s' does not exist | error |

A stopwatch measures game time from creation; usable in `execute if stopwatch`.

### 10.11 `datapack`

Level 2 (`create`: level 4).

```
datapack list [available | enabled]
datapack enable <name:string> [first | last | before <existing:string> | after <existing:string>]
datapack disable <name:string>
datapack create <id:string> <description:component>          (level 4)
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.datapack.list.enabled.success` | count, list | There are %s data pack(s) enabled: %s | Q |
| `commands.datapack.list.enabled.none` | | There are no data packs enabled | Q |
| `commands.datapack.list.available.success` | count, list | There are %s data pack(s) available: %s | Q |
| `commands.datapack.list.available.none` | | There are no more data packs available | Q |
| `commands.datapack.modify.enable` | pack | Enabling data pack %s | **B** |
| `commands.datapack.modify.disable` | pack | Disabling data pack %s | **B** |
| `commands.datapack.create.success` | name | Created new empty pack with name '%s' | **B** |
| `commands.datapack.unknown` | name | Unknown data pack '%s' | error |
| `commands.datapack.enable.failed` | name | Pack '%s' is already enabled! | error |
| `commands.datapack.disable.failed` | name | Pack '%s' is not enabled! | error |
| `commands.datapack.enable.failed.no_flags` | pack, flags | Pack '%s' cannot be enabled, since required flags are not enabled in this world: %s! | error |
| `commands.datapack.disable.failed.feature` | pack | Pack '%s' cannot be disabled, since it is part of an enabled flag! | error |
| `commands.datapack.create.invalid_name` | name | Invalid characters in new pack name '%s' | error |
| `commands.datapack.create.invalid_full_name` | name | Invalid new pack name '%s' | error |
| `commands.datapack.create.already_exists` | name | Pack with name '%s' already exists | error |
| `commands.datapack.create.metadata_encode_failure` | name, error | Failed to encode metadata for pack with name '%s': %s | error |
| `commands.datapack.create.io_failure` | name | Can't create pack with name '%s'. Check logs | error |

The pack list is also a pack-selection data flow shared with resource packs (08).

### 10.12 `reload`

Level 2. No arguments. Re-reads data packs; on success the message `commands.reload.success` "Reloading!" (**B**); on failure `commands.reload.failure` "Reload failed; keeping old data". Needs the data-pack loader (not specified here).

---

## 11. Server administration

Commands in 11.1 to 11.7, 11.9 to 11.14, 11.17 and 11.22 exist only when the selection includes dedicated (section 2); 11.15 and 11.16 only when it includes integrated. `<profiles>` is the game-profile argument: a name (the profile is looked up, so a never-seen name is accepted), or a selector yielding players. List storage (`ops.json`, `banned-players.json`, ...) is not specified here (see 17).

### 11.1 `op` and 11.2 `deop` (level 3)

```
op <targets:profiles>            (suggestions: profiles that are not yet operators)
deop <targets:profiles>          (suggestions: current operators)
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.op.success` | name | Made %s a server operator | **B** |
| `commands.op.failed` | | Nothing changed. The player is already an operator | error |
| `commands.deop.success` | name | Made %s no longer a server operator | **B** |
| `commands.deop.failed` | | Nothing changed. The player is not an operator | error |

Read: `op` processes each profile in turn; a profile that is not an operator is made one (`PlayerList.op`) and its success message is sent (**B**, one message per profile, argument: the profile name); a profile that already is one is skipped. If no profile changed, error `commands.op.failed`. Result = number of profiles changed. `deop` is symmetric (`PlayerList.deop`, error `commands.deop.failed` when none changed) and, if at least one profile changed, afterwards calls the server's `kickUnlistedPlayers`. `PlayerList.op` gives the new operator the level in `MinecraftServer.operatorUserPermissions` (read); the list file format is not read. Sending an updated command tree to online players: not read in these classes.

### 11.3 `ban` (level 3)

`ban <targets:profiles> [<reason:message>]`. Profiles already banned are skipped; if none was newly banned the error is `commands.ban.failed`; result = number newly banned. Read: for each profile not already banned, a ban-list entry is created with the profile, the creation time left to default, the source set to the invoking source's text name, no expiry, and the reason text (the string of `<reason>`; none when omitted); the success message is sent per profile (**B**: profile name as a literal, then the entry's reason message); and if that player is online, the player's connection is disconnected with the translatable text the disconnect text `multiplayer.disconnect.banned` ("You are banned from this server"; the longer texts `multiplayer.disconnect.banned.reason` "You are banned from this server.\nReason: %s", `.reason.default` "Banned by an operator.", and `.expiration` "\nYour ban will be removed on %s" exist in the lang file).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.ban.success` | name, reason | Banned %s: %s | **B** |
| `commands.ban.failed` | | Nothing changed. The player is already banned | error |

### 11.4 `ban-ip` (level 3)

`ban-ip <target:word> [<reason:message>]`. `<target>` is an IP address or a player name (the invalid message reads "Invalid IP address or unknown player"; using the player's address is inferred). Read: `<target>` is first tested as an IP literal; otherwise it is looked up as an online player's name and that player's address is used (neither: error `commands.banip.invalid`); an already banned address gives `commands.banip.failed`; otherwise an IP-ban entry is added (source = the invoking source's text name, reason), the success message is sent (**B**: address, reason), and every online player whose address matches is disconnected with the translatable text `multiplayer.disconnect.ip_banned`; if any matched, `commands.banip.info` (count, names) is also sent (**B**). Result = number of players disconnected. Disconnect text ("You have been IP banned from this server"; longer forms `multiplayer.disconnect.banned_ip.reason` "Your IP address is banned from this server.\nReason: %s", `.expiration`).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.banip.success` | ip, reason | Banned IP %s: %s | **B** |
| `commands.banip.info` | count, names | This ban affects %s player(s): %s | **B** (if any online player matched) |
| `commands.banip.invalid` | | Invalid IP address or unknown player | error |
| `commands.banip.failed` | | Nothing changed. That IP is already banned | error |

### 11.5 `pardon` and 11.6 `pardon-ip` (level 3)

`pardon <targets:profiles>` (suggestions: banned profiles); `pardon-ip <target:word>` (suggestions: banned IPs). Read: `pardon` removes each banned profile from the ban list and sends `commands.pardon.success` per removed profile (**B**); if none was banned, `commands.pardon.failed`; result = number removed. `pardon-ip`: the argument must be an IP literal (else `commands.pardonip.invalid`) and must be banned (else `commands.pardonip.failed`); removes it, sends `commands.pardonip.success` (**B**); result 1.

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.pardon.success` | name | Unbanned %s | **B** |
| `commands.pardon.failed` | | Nothing changed. The player isn't banned | error |
| `commands.pardonip.success` | ip | Unbanned IP %s | **B** |
| `commands.pardonip.invalid` | | Invalid IP address | error |
| `commands.pardonip.failed` | | Nothing changed. That IP isn't banned | error |

### 11.7 `banlist` (level 3)

```
banlist             -> both lists (players and IPs together, read)
banlist ips
banlist players
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.banlist.none` | | There are no bans | Q |
| `commands.banlist.list` | count | There are %s ban(s): | Q |
| `commands.banlist.entry` | banned name or IP, banned by, reason | %s was banned by %s: %s | Q (one per entry) |

### 11.8 `kick` (level 3)

`kick <targets:players> [<reason:message>]`. Read: when the server is not published the command fails (`singleplayer.failed`) before touching anyone; a target that is the single-player owner (`isSingleplayerOwner`) is skipped; every other target is disconnected with the reason and a success message **B** is sent per kicked player (arguments: player display name, reason); if no player was kicked (all targets were the owner), error `owner.failed`. Result = number of players kicked. Default reason: the translatable `multiplayer.disconnect.kicked` ("Kicked by an operator"). Disconnects each target with the reason. 

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.kick.success` | player, reason | Kicked %s: %s | **B** |
| `commands.kick.owner.failed` | | Cannot kick the server owner in a LAN game | error |
| `commands.kick.singleplayer.failed` | | Cannot kick in an offline singleplayer game | error |

Result: not traced.

### 11.9 `save-all`, 11.10 `save-on`, 11.11 `save-off` (level 4)

`save-all [flush]`: sends `commands.save.saving` (Q), calls `PlayerList.saveAll` and then `MinecraftServer.saveEverything(false, flush, true)` (the `flush` form passes true as the middle argument; what it does inside was not read), then sends `commands.save.success` (**B**) or fails with `commands.save.failed` if the save routine reports failure; result 1. `save-on` / `save-off` re-enable or suspend automatic saving, send their success message (**B**) and return 1; each fails with the `alreadyOn` / `alreadyOff` message if already in the requested state.

| Key | English | When |
|---|---|---|
| `commands.save.saving` | Saving the game (this may take a moment!) | Q, before the save |
| `commands.save.success` | Saved the game | **B**, after |
| `commands.save.failed` | Unable to save the game (is there enough disk space?) | error |
| `commands.save.enabled` | Automatic saving is now enabled | **B** |
| `commands.save.alreadyOn` | Saving is already turned on | error |
| `commands.save.disabled` | Automatic saving is now disabled | **B** |
| `commands.save.alreadyOff` | Saving is already turned off | error |

### 11.12 `stop` (level 4)

No arguments. Sends `commands.stop.stopping` "Stopping the server" (**B**) and calls the server's `halt(false)`; result 1. The shutdown sequence (and which disconnect text players see; the lang file has `multiplayer.disconnect.server_shutdown` "Server closed") is inside `MinecraftServer` and was not read.

### 11.13 `transfer` (level 3)

`transfer <hostname:string> [<port:integer 1..65535> [<players:players>]]`. Read: the tree makes `<port>` and `<players>` optional (hostname alone and hostname+port are executable); when `<players>` is omitted the target is the source player (`getPlayerOrException`, so a non-player source fails); the default port is 25565 (read: the hostname-only lambda passes 25565). For each target a `ClientboundTransferPacket` is sent (05a 0x84) and the tracker (value 1 per player) produces the single/multiple message; no targets gives `commands.transfer.error.no_players`. Result = the tracker total. No target players: error `commands.transfer.error.no_players` "Must specify at least one player to transfer". Messages (**B**): `commands.transfer.success.single` "Transferring %s to %s:%s" (player, host, port) and `commands.transfer.success.multiple` "Transferring %s players to %s:%s" (count, host, port). A server that does not accept transfers disconnects with `multiplayer.disconnect.transfers_disabled` ("This server does not accept transfers"; that is the receiving side).

### 11.14 `setidletimeout` (level 3)

`setidletimeout <minutes:integer min 0>`. Read: sets the idle timeout (value in minutes) on the server, sends `commands.setidletimeout.success` (**B**; the `.disabled` variant is used when the value is 0), and returns the argument. Read: `ServerGamePacketListenerImpl` kicks a player with `multiplayer.disconnect.idling` ("You have been idle for too long!") once the idle time exceeds the timeout; what a value of 0 does inside that check was not read (the `success.disabled` message suggests "disabled").

| Key | Arguments | English |
|---|---|---|
| `commands.setidletimeout.success` | minutes | The player idle timeout is now %s minute(s) |
| `commands.setidletimeout.success.disabled` | | The player idle timeout is now disabled |

### 11.15 `publish` and 11.16 `unpublish` (level 4, integrated)

`publish [<allowCommands:bool> [<port:integer 0..65535>]]` hosts the single-player world on the LAN. Read: with no arguments, a free port is chosen (`HttpUtil.getAvailablePort`) and allowCommands is false; with only `allowCommands` a free port is chosen; with both, the given port is used. A server already published gives `alreadyPublished.lan` (argument: the port); a failure to host gives `commands.publish.failed`. On success `commands.publish.started.lan` (**B**) and the result is the port. `unpublish` closes it (result 1; `notPublished` error when not published).

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.publish.started.lan` | port | Local game hosted on port %s | **B** |
| `commands.publish.alreadyPublished.lan` | port | Local game is already hosted on port %s | error |
| `commands.publish.failed` | | Unable to host local game | error |
| `commands.unpublish.success` | | Multiplayer game is now unpublished | **B** |
| `commands.unpublish.notPublished` | | No multiplayer game published | error |

(The lang file also has `commands.publish.started`, `.started.online`, `.success`, `.alreadyPublished`, `.alreadyPublished.online`; they are not among the keys referenced from `PublishCommand` read here.)

### 11.17 `perf`, 11.18 `jfr`, 11.19 `debug` (profilers)

`perf start|stop` (level 4, dedicated): a performance profiling run (the started message says 10 seconds); `jfr start|stop` (level 4, only when JFR is available): Java Flight Recorder; `debug start|stop` (level 3) and `debug function <name:function>` (level 3): tick profiling and function tracing. These need the JVM/profiler and are not applicable to CobolCraft; messages are listed for completeness.

| Key | Arguments | English |
|---|---|---|
| `commands.perf.started` | | Started a 10-second performance profiling run (use '/perf stop' to stop early) |
| `commands.perf.stopped` | seconds, ticks, ticks/s | Stopped performance profiling after %s second(s) and %s tick(s) (%s tick(s) per second) |
| `commands.perf.reportSaved` | path | Created debug report in %s |
| `commands.perf.reportFailed` | | Failed to create debug report |
| `commands.perf.alreadyRunning` / `.notRunning` | | The performance profiler is already started / hasn't started |
| `commands.jfr.started` | | JFR profiling started |
| `commands.jfr.stopped` | path | JFR profiling stopped and dumped to %s |
| `commands.jfr.start.failed` | | Failed to start JFR profiling |
| `commands.jfr.dump.failed` | error | Failed to dump JFR recording: %s |
| `commands.debug.started` | | Started tick profiling |
| `commands.debug.stopped` | seconds, ticks, ticks/s | Stopped tick profiling after %s second(s) and %s tick(s) (%s tick(s) per second) |
| `commands.debug.alreadyRunning` / `.notRunning` | | The tick profiler is already started / hasn't started |
| `commands.debug.function.noRecursion` | | Can't trace from inside of function |
| `commands.debug.function.noReturnRun` | | Tracing can't be used with return run |

### 11.20 `fetchprofile` (level 2)

```
fetchprofile name <name:greedy_string>
fetchprofile id <id:uuid>
fetchprofile entity <entity>
```

Asynchronously asks the profile service for a profile, then prints it with click-to-copy components. Needs an online profile service (not available offline). Keys: `commands.fetchprofile.name.success` "Resolved profile for name %s: %s", `.name.failure` "Failed to resolve profile for name %s", `.id.success` "Resolved profile for ID %s: %s", `.id.failure` "Failed to resolve profile for ID %s", `.entity.success` "Resolved profile for entity %s: %s", `.no_profile` "Entity %s has no profile", `.failed_to_serialize` "Failed to serialize profile: %s", and UI texts `.copy_component` "Copy Component", `.give_item` "Give Item", `.summon_mannequin` "Summon Mannequin", `.copy_text` "Copy %s".

### 11.21 `serverpack` (level 2, dev only)

```
serverpack push <url:string> <uuid:uuid> <hash:word>
serverpack pop <uuid:uuid>
```

Pushes/pops a resource pack identified by uuid; read: the class builds `ClientboundResourcePackPushPacket` (05b 0x52) and `ClientboundResourcePackPopPacket` (05b 0x51); see 08 §9 for the packet semantics. No lang messages. Registered only in dev mode (section 2).

### 11.22 `whitelist` (level 3)

```
whitelist on | off | list | reload
whitelist add <targets:profiles>               (suggestions: profiles not yet whitelisted)
whitelist remove <targets:profiles>            (suggestions: whitelisted profiles)
```

| Key | Arguments | English | When |
|---|---|---|---|
| `commands.whitelist.enabled` | | Whitelist is now turned on | **B** |
| `commands.whitelist.disabled` | | Whitelist is now turned off | **B** |
| `commands.whitelist.alreadyOn` | | Whitelist is already turned on | error |
| `commands.whitelist.alreadyOff` | | Whitelist is already turned off | error |
| `commands.whitelist.add.success` | name | Added %s to the whitelist | **B** |
| `commands.whitelist.add.failed` | | Player is already whitelisted | error |
| `commands.whitelist.remove.success` | name | Removed %s from the whitelist | **B** |
| `commands.whitelist.remove.failed` | | Player is not whitelisted | error |
| `commands.whitelist.list` | count, names | There are %s whitelisted player(s): %s | Q |
| `commands.whitelist.none` | | There are no whitelisted players | Q |
| `commands.whitelist.reloaded` | | Reloaded the whitelist | **B** |

Non-whitelisted joiners are disconnected with `multiplayer.disconnect.not_whitelisted` ("You are not white-listed on this server!"). Enforcing the whitelist when turned on (kicking connected non-listed players) is not traced (see 17).

---

## 12. Dev and debug-only commands

Registered only under the conditions in section 2; no player-facing use. Grammar read from the registration:

| Command | Level | Registered when | Grammar | Messages (lang) |
|---|---|---|---|---|
| `test` | 2 | always | `test run <tests:selector> [...]`, `runmultiple`, `runthese`, `runclosest`, `runthat`, `runfailed [onlyRequiredTests]`, `verify`, `locate`, `resetclosest/resetthese/resetthat`, `clearthat/clearthese/clearall [radius]`, `stop`, `pos [var]`, `create <id> [width [height [depth]]]`, `export <test>`, `exportclosest/exportthese/exportthat` | `commands.test.*` and `test.*` keys (game-test framework; not specified) |
| `chase` | 0 | `DEBUG_CHASE_COMMAND` | `chase follow <host:string> <port:integer 1..65535>`; `chase lead <bind_address:string> <port:integer 1024..65535>`; `chase stop` | none referenced |
| `raid` | 3 | dev or IDE | `raid start <omenlvl:integer min 0>`; `raid stop`; `raid check`; `raid sound <type:component>`; `raid spawnleader`; `raid setomen <level:integer min 0>`; `raid glow` | none referenced |
| `debugpath` | 2 | dev or IDE | `debugpath <to:block_pos>` | none |
| `debugmobspawning` | 2 | dev or IDE | `debugmobspawning <mob_category> <at:block_pos>` (the literal list is the spawn categories) | none |
| `warden_spawn_tracker` | 2 | dev or IDE | `warden_spawn_tracker clear`; `warden_spawn_tracker set <warning_level:integer 0..4>` | `commands.warden_spawn_tracker.clear.success.single/.multiple`, `set.success.single/.multiple` (texts not present in en_us keys read) |
| `spawn_armor_trims` | 2 | dev or IDE | `spawn_armor_trims *_lag_my_game` or `spawn_armor_trims <pattern:resource_key>` | none |
| `serverpack` | 2 | dev or IDE | see 11.21 | none |
| `debugconfig` | 3 | (dev or IDE) and dedicated | `debugconfig config <target:player>`; `debugconfig unconfig <target:uuid>`; `debugconfig dialog <target:uuid> <dialog:resource_or_id>` | none |

Tests for CobolCraft: none of these should be registered.

---

## 13. Gamerule table

Rule ids are lower snake case. Each rule is read from the `GameRules` static initialiser: category (`GameRuleCategory`: PLAYER, MOBS, SPAWNING, DROPS, UPDATES, CHAT, MISC), type, default, and for integer rules the minimum and maximum (default maximum 2147483647 when unspecified). `advance_time` and `advance_weather` take their default from a debug flag (false only when `DEBUG_WORLD_RECREATE` is set; otherwise true). `max_minecart_speed` carries the required feature `MINECART_IMPROVEMENTS` (the rule is only offered where that feature is enabled); no other rule carries a feature requirement. 59 rules.

| Rule id | Category | Type | Default | Min | Max | Title (en_us, after load-time rename) |
|---|---|---|---|---|---|---|
| `advance_time` | UPDATES | boolean | true |  |  | Advance time of day |
| `advance_weather` | UPDATES | boolean | true |  |  | Update weather |
| `allow_entering_nether_using_portals` | MISC | boolean | true |  |  | Allow Nether |
| `block_drops` | DROPS | boolean | true |  |  | Drop blocks |
| `block_explosion_drop_decay` | DROPS | boolean | true |  |  | In block interaction explosions, some blocks won't drop their loot |
| `command_blocks_work` | MISC | boolean | true |  |  | Enable Command Blocks |
| `command_block_output` | CHAT | boolean | true |  |  | Broadcast command block output |
| `drowning_damage` | PLAYER | boolean | true |  |  | Deal drowning damage |
| `elytra_movement_check` | PLAYER | boolean | true |  |  | Do elytra movement check |
| `ender_pearls_vanish_on_death` | PLAYER | boolean | true |  |  | Thrown Ender Pearls vanish on death |
| `entity_drops` | DROPS | boolean | true |  |  | Drop entity equipment |
| `fall_damage` | PLAYER | boolean | true |  |  | Deal fall damage |
| `fire_damage` | PLAYER | boolean | true |  |  | Deal fire damage |
| `fire_spread_radius_around_player` | UPDATES | integer | 128 | -1 | 2147483647 | Fire spread radius |
| `forgive_dead_players` | MOBS | boolean | true |  |  | Forgive dead players |
| `freeze_damage` | PLAYER | boolean | true |  |  | Deal freeze damage |
| `global_sound_events` | MISC | boolean | true |  |  | Global sound events |
| `immediate_respawn` | PLAYER | boolean | false |  |  | Respawn immediately |
| `keep_inventory` | PLAYER | boolean | false |  |  | Keep inventory after death |
| `lava_source_conversion` | UPDATES | boolean | false |  |  | Lava converts to source |
| `limited_crafting` | PLAYER | boolean | false |  |  | Require recipe for crafting |
| `locator_bar` | PLAYER | boolean | true |  |  | Enable player Locator Bar |
| `log_admin_commands` | CHAT | boolean | true |  |  | Broadcast admin commands |
| `max_block_modifications` | MISC | integer | 32768 | 1 | 2147483647 | Command modification block limit |
| `max_command_forks` | MISC | integer | 65536 | 0 | 2147483647 | Command context limit |
| `max_command_sequence_length` | MISC | integer | 65536 | 0 | 2147483647 | Command chain size limit |
| `max_entity_cramming` | MOBS | integer | 24 | 0 | 2147483647 | Entity cramming threshold |
| `max_minecart_speed` | MISC | integer | 8 | 1 | 1000 | Minecart max speed |
| `max_snow_accumulation_height` | UPDATES | integer | 1 | 0 | 8 | Snow accumulation height |
| `mob_drops` | DROPS | boolean | true |  |  | Drop mob loot |
| `mob_explosion_drop_decay` | DROPS | boolean | true |  |  | In mob explosions, some blocks won't drop their loot |
| `mob_griefing` | MOBS | boolean | true |  |  | Allow destructive mob actions |
| `natural_health_regeneration` | PLAYER | boolean | true |  |  | Regenerate health |
| `player_movement_check` | PLAYER | boolean | true |  |  | Do player movement check |
| `players_nether_portal_creative_delay` | PLAYER | integer | 0 | 0 | 2147483647 | Player's Nether Portal delay in creative mode |
| `players_nether_portal_default_delay` | PLAYER | integer | 80 | 0 | 2147483647 | Player's Nether Portal delay in non-creative mode |
| `players_sleeping_percentage` | PLAYER | integer | 100 | 0 | 2147483647 | Sleep percentage |
| `projectiles_can_break_blocks` | DROPS | boolean | true |  |  | Projectiles can break blocks |
| `pvp` | PLAYER | boolean | true |  |  | Enable pvp |
| `raids` | MOBS | boolean | true |  |  | Do raids |
| `random_tick_speed` | UPDATES | integer | 3 | 0 | 2147483647 | Random tick speed rate |
| `reduced_debug_info` | MISC | boolean | false |  |  | Reduce debug info |
| `respawn_radius` | PLAYER | integer | 10 | 0 | 2147483647 | Respawn location radius |
| `send_command_feedback` | CHAT | boolean | true |  |  | Send command feedback |
| `show_advancement_messages` | CHAT | boolean | true |  |  | Announce advancements |
| `show_death_messages` | CHAT | boolean | true |  |  | Show death messages |
| `spawner_blocks_work` | MISC | boolean | true |  |  | Enable Spawner Blocks |
| `spawn_mobs` | SPAWNING | boolean | true |  |  | Spawn mobs |
| `spawn_monsters` | SPAWNING | boolean | true |  |  | Spawn Monsters |
| `spawn_patrols` | SPAWNING | boolean | true |  |  | Spawn pillager patrols |
| `spawn_phantoms` | SPAWNING | boolean | true |  |  | Spawn phantoms |
| `spawn_wandering_traders` | SPAWNING | boolean | true |  |  | Spawn Wandering Traders |
| `spawn_wardens` | SPAWNING | boolean | true |  |  | Spawn Wardens |
| `spectators_generate_chunks` | PLAYER | boolean | true |  |  | Allow spectators to generate terrain |
| `spread_vines` | UPDATES | boolean | true |  |  | Vines spread |
| `tnt_explodes` | MISC | boolean | true |  |  | Allow TNT to be activated and to explode |
| `tnt_explosion_drop_decay` | DROPS | boolean | false |  |  | In TNT explosions, some blocks won't drop their loot |
| `universal_anger` | MOBS | boolean | false |  |  | Universal anger |
| `water_source_conversion` | UPDATES | boolean | true |  |  | Water converts to source |

Descriptions (`.description` keys, after the same rename) exist for most rules and are not repeated here; they are in `en_us.json` under `gamerule.minecraft.<id>.description` once the rename below is applied.

Notes on the table:

* Boolean rules take `true`/`false`; their command result is 1/0 (read). Integer rules take `integer(min, max)` with the bounds in the table; negative minimum -1 on `fire_spread_radius_around_player` is part of the read range.
* The `send_command_feedback` rule controls whether command success messages are shown to the invoking source and whether `gameMode.changed`-style notices are sent (read for `gamemode`); the other rules' consumers (damage, spawning, drops...) are gameplay systems outside this document.
* Title lookup (read): the title key is `gamerule.minecraft.<id>` (`GameRule.getDescriptionId` builds it from the namespaced id). The jar's `en_us.json` still stores most titles under older camelCase keys (for example `gamerule.keepInventory`). The client resolves this when it loads a language: `ClientLanguage.loadFrom` (and `Language.loadDefault` for the default language) reads `/assets/minecraft/lang/deprecated.json` through `DeprecatedTranslationsInfo` and calls `applyToMap`, which first removes every key listed under `removed`, then renames each key listed under `renamed` (old key becomes new key; when the source key is missing a warning is logged and the destination key is also removed). `deprecated.json` has 425 removed keys and 148 renamed keys, 92 of the renames concern `gamerule.*` keys (for example `gamerule.doDaylightCycle` becomes `gamerule.minecraft.advance_time`, `gamerule.spawnRadius` becomes `gamerule.minecraft.respawn_radius`, `gamerule.announceAdvancements` becomes `gamerule.minecraft.show_advancement_messages`). After applying it to `en_us.json`, all 59 rule ids have a title, shown in the table. The lookup itself is `getOrDefault(key, default)`; a key that is missing after the rename falls back to the supplied default (the key text). So there is no camelCase fallback at lookup time: the camelCase titles reach the new keys only through the load-time rename. A server that sends the rule id to a client needs nothing more than the id; the client builds the title key.
* Two descriptions are renamed to ids that differ from the old words (for example `gamerule.allowFireTicksAwayFromPlayer.description` becomes `gamerule.minecraft.spread_fire_far_from_player.description`, an id that is not among the 59 registered rule ids; see 17).

---

## 14. Aliases

Aliases are redirect nodes: they share the target's children and permission requirement (the alias node carries its own `requires` where listed).

| Alias | Target | Level |
|---|---|---|
| `tp` | `teleport` | 2 |
| `xp` | `experience` | 2 |
| `tell` | `msg` | 0 |
| `w` | `msg` | 0 |
| `tm` | `teammsg` | 0 |

No other aliases are registered by this version's `Commands` class.

---

## 14a. Result values and failure conditions (summary)

One row per command name (sub-forms grouped; aliases share the row of their target: `tp`/`teleport`, `xp`/`experience`, `tell` and `w`/`msg`, `tm`/`teammsg`; the dev and debug names are in the last block of rows). "Result" is the integer returned (read unless marked), "fails when" lists the conditions that throw. "not read" means the command class was not opened for that detail in this round (see 17).

| Command | Result | Fails when |
|---|---|---|
| `advancement` | tracker total (ANY mode): the sum over players of the advancements (or 1 per criterion) changed | the ANY count is 0 (the `...failure` keys); unknown criterion |
| `attribute get` forms | (int)(value x scale) | target has no such attribute; not a living entity |
| `attribute base set/reset`, `modifier add/remove` | 1 | no attribute; modifier already present / missing |
| `ban` | number newly banned | all already banned |
| `ban-ip` | number of players disconnected | invalid target; address already banned |
| `banlist` | number of entries listed | never |
| `bossbar` | see 8.7 | unknown id; id exists on add; unchanged values |
| `clear` | items matched/removed | total 0 |
| `clone` | blocks written | overlap (normal mode), too big, unloaded, debug world, 0 written |
| `damage` | 1 | target ignored the damage (`invulnerable`) |
| `data` | see 10.1 | invalid holder; path missing; nothing changed (merge) |
| `datapack enable/disable` | the size of the resulting selection list (read: the list size after `reloadPacks`) | unknown pack; already enabled / not enabled; flag errors |
| `datapack list` | enabled count + available count (both lists printed); `list available` / `list enabled`: that list's size | none |
| `datapack create` | 1 | invalid or existing name; io failure |
| `defaultgamemode` | number of players moved to the just-set mode when `force-gamemode` is on (dedicated), 0 otherwise | never |
| `deop` | number changed | none was an operator |
| `difficulty` set / query | 0 / difficulty id | already that difficulty |
| `effect give` | tracker total (each entity is tracked 1 or 0: whether `addEffect` accepted it) | none accepted it |
| `effect clear` | tracker total of entities from which something was removed (each entity is tracked with 1 or 0) | none removed |
| `enchant` | items enchanted | level above maximum; no valid target |
| `experience add/set` | tracker total | `set points` above the level's maximum |
| `experience query` | points in current level / level | none |
| `fill` | blocks placed or destroyed | too big, unloaded, debug world, count 0 |
| `fillbiome` | cells changed | too big, unloaded, none changed |
| `forceload add/remove` | number of chunks changed (tracker, 1 or 0 per chunk) | too many chunks; out of world; none changed |
| `forceload remove all` | 0 | none |
| `forceload query` | 1 (with a position, marked), or the number of forced chunks (no position; 0 and a failure message when none) | position not marked |
| `function` | the result reported through the function callback (`signalResult`); the exact accumulation was not decoded | see 10.3 |
| `gamemode` | players whose mode changed | none |
| `gamerule` | 1/0 for booleans; the integer value for integers | set to the current value |
| `give` | tracker total | too many items |
| `kick` | players kicked | not published; all targets were the owner |
| `kill` | tracker total (entities killed) | none |
| `list` | number of online players | never |
| `locate` | distance in blocks | not found / invalid structure |
| `loot` | the tracker total (items dropped/inserted; quiet) | no loot table; entity cannot hold items |
| `me`, `say` | 1 | none |
| `msg` | number of targets | none |
| `op` | number newly made operators | all already operators |
| `pardon` | number removed | none were banned |
| `pardon-ip` | 1 | invalid IP; not banned |
| `particle` | number of viewers reached | nobody could see it |
| `playsound` | tracker total (players reached) | sound too far away |
| `publish` | the port | already published; failure to host |
| `random value/roll` | the drawn number | range too small/large |
| `random reset` | 1 / number of sequences reset | none |
| `recipe` | tracker total (per player the count returned by `awardRecipes` / the take routine) | no recipe learned / forgotten |
| `reload` | 0 | reload failed is reported through the reload callback, not an exception (inferred) |
| `ride` | 1 | see 5.6 |
| `rotate` | 1 | none |
| `save-all`, `save-on`, `save-off` | 1 | save failed; already in state |
| `schedule function` | floorMod(trigger game time, 2147483647) | same tick; macro |
| `schedule clear` | number removed | none |
| `scoreboard` | see 9.1 | see 9.1 |
| `seed` | the low 32 bits of the seed as an int (read: `l2i`) | none |
| `setblock` | 1 | debug world; predicate refused; placement refused |
| `setidletimeout` | the minutes | none |
| `setworldspawn`, `spawnpoint` | 1 / tracker total | none |
| `spectate` | 1 | see 5.4 |
| `spreadplayers` | number of piles | too crowded (10000 iterations); invalid maxHeight |
| `stop` | 1 | none |
| `stopsound` | number of targets | none |
| `stopwatch create/restart/remove` | 1 | exists / does not exist |
| `stopwatch query` | (int)(elapsed seconds x scale) | does not exist |
| `summon` | 1 | see 5.8 |
| `tag add/remove` | tracker total | no change |
| `tag list` | number of distinct tags | none |
| `team` | see 9.2 | duplicate; unchanged option; empty team |
| `teleport` | tracker total | invalid position |
| `tellraw` | players reached | none |
| `tick` | rate: the rate truncated; query: the average rate expression truncated; step/sprint/stop/freeze: 1 (freeze/unfreeze: 1 or 0 by state, read: boolean to int) | step not frozen; stop with nothing in progress |
| `time` | see 4.5 | see 4.5 |
| `title` | tracker total | none |
| `transfer` | tracker total | no players |
| `trigger` | simple: the new value (`add(1)`); `add`: the new value; `set`: the argument | locked / no score; not a trigger objective |
| `unpublish` | 1 | not published |
| `waypoint` | 0 for modify forms; the count for `list` | none |
| `weather` | duration argument (-1 when omitted) | none |
| `whitelist add/remove/list` | number changed (add/remove); list size | none changed |
| `whitelist on/off/reload` | 1 | already on / already off |
| `worldborder` | see 4.11 | see 4.11 |
| `chase follow/lead/stop` | 0 (stop, and already-running cases); defaults: `follow` host `localhost` port 10000, `lead` bind `0.0.0.0` port 10000 | already running |
| `compute float` / `integer` | the rounded int value (float form: rounded after scaling by `<scale>`, default 1.0); messages quiet | the provider returned an invalid value |
| `debug start` / `stop` | 0 / (int) ticks per second reported | already running / not running |
| `debug function` | not read | no recursion; no `return run` |
| `debugconfig`, `debugmobspawning`, `debugpath`, `test` | not read (dev) | not read |
| `dialog show/clear` | tracker total (broadcast on) | none |
| `execute` | the result of the command run at the end of the chain (as the chain's result consumer reports); `if`/`unless` as a whole command: the pass count or 1/0 | condition false for `if` without `run`; too many blocks (`if blocks`) |
| `fetchprofile` | 1 (the lookup runs asynchronously and prints later) | no profile / cannot resolve |
| `help` | the size of the usage map printed (quiet) | unknown command or no permission (`commands.help.failed`) |
| `item` | tracker total through the accessor's replace/modify response (value tracked per target: the number of slots changed) | target not a container; no such slot; nothing accepted (see 6.3) |
| `jfr start/stop` | 1 (quiet) | start/dump failure |
| `perf start/stop` | 0 (quiet) | already running / not running |
| `place feature/jigsaw/structure/template` | 1 | see 7.5 |
| `posteffect add/remove/clear` | tracker total; `list`: size of the list (quiet) | see 8.11 |
| `raid` (dev) | `start` -1 on failure (failure message sent), 1 otherwise; `stop`, `check`, `setomen`, `glow`, `sound` 1 (stop/check quiet) | no raid / not in a raid |
| `return` | `return <value>`: the value is returned from the function frame; `return fail`: reports failure and returns failure; `return run <cmd>`: returns the result of the command | none |
| `serverpack push/pop` | 0 | none |
| `spawn_armor_trims` (dev) | 1 | none |
| `swing` | tracker total (NON_ZERO) | no living entity |
| `teammsg` | number of recipients (including the sender) | source not on a team |
| `version` | 1 | none |
| `warden_spawn_tracker` (dev) | tracker total | none |

---

## 15. Worked examples

Each example gives the typed command, the expected feedback (key and English) and the result. The result values shown are only those marked as read above.

**Player and game state**

| Command | Source | Outcome |
|---|---|---|
| `/gamemode creative Alice` (Alice survival) | op | to the source: `commands.gamemode.success.other` "Set Alice's game mode to Creative Mode"; to Alice: `gameMode.changed` "Your game mode has been updated to Creative Mode" (rule `send_command_feedback` true); result 1 |
| `/gamemode creative Alice` again | op | no change; result 0; no message (the command still succeeds) |
| `/difficulty hard` (already hard) | op | error `commands.difficulty.failure` "The difficulty did not change; it is already set to Hard" |
| `/gamerule keep_inventory true` (was false) | op | `commands.gamerule.set` "Game rule keep_inventory is now set to true"; result 1 |
| `/gamerule keep_inventory true` again | op | error `commands.gamerule.not_set` "Game rule keep_inventory is already set to true" |
| `/gamerule keep_inventory` | op | `commands.gamerule.query` "Game rule keep_inventory is currently set to true"; result 1 |
| `/gamerule random_tick_speed -1` | op | rejected by the integer range (minimum 0) with the framework's range error (15 framework: argument errors) |
| `/weather rain 6000` | op | `commands.weather.set.rain` "Set the weather to rain"; result 6000 |
| `/weather clear` | op | "Set the weather to clear"; clear time drawn uniformly 12000..180000; result -1 |
| `/time query gametime` | any op | `commands.time.query.gametime` "The game time is 12345 tick(s)" |
| `/time set noon` | op | marker `minecraft:noon` (6000 in timeline `day`) is moved to: `commands.time.set.time_marker` "Set minecraft:overworld to time marker minecraft:noon" |
| `/time pause` twice | op | second: error `commands.time.pause.already_paused` "Clock minecraft:overworld is already paused" |
| `/worldborder set 0.5` | op | error `commands.worldborder.set.failed.small` "World border cannot be smaller than 1 block wide" |
| `/worldborder set 100 10` (from 200) | op | `commands.worldborder.set.shrink` "Shrinking the world border to 100.0 block(s) wide over 10.00 second(s)" |

**Entities and items**

| Command | Source | Outcome |
|---|---|---|
| `/give Alice stone 64` | op | `commands.give.success.single` "Gave 64 Stone to Alice" (item display name) |
| `/give Alice stone 100000` | op | error `commands.give.failed.toomanyitems` with maximum 6400 (stack size 64 times 100) "Can't give more than 6400 of Stone" |
| `/clear Alice` (empty inventory) | op | error `clear.failed.single` "No items were found on player Alice" |
| `/kill @e[type=pig]` (3 pigs) | op | `commands.kill.success.multiple` "Killed 3 entities"; result 3 (tracker total) |
| `/effect give Alice speed infinite 1 true` | op | `commands.effect.give.success.single` "Applied effect Speed to Alice"; effect duration -1 (infinite) |
| `/effect give Alice speed 10` | op | duration 200 ticks (10 seconds x 20; read) |
| `/tp Alice 0 80 0` | op | `commands.teleport.success.location.single` "Teleported Alice to 0.000000, 80.000000, 0.000000" |
| `/spawnpoint Alice 10 64 10` | op | `commands.spawnpoint.success.single` "Set spawn point to 10, 64, 10 [0.0] in 0.0 for minecraft:overworld" (positional substitution of the seven arguments, see 4.8) |

**World, chat, scoreboard, admin**

| Command | Source | Outcome |
|---|---|---|
| `/setblock 0 64 0 stone` | op | `commands.setblock.success` "Changed the block at 0, 64, 0" |
| `/fill 0 0 0 39 39 39 stone` (64000 blocks, default `max_block_modifications` 32768) | op | error `commands.fill.toobig` "Too many blocks in the specified area (maximum 32768, but specified 64000)" |
| `/msg Bob hi` | Alice | Bob: chat type `msg_command_incoming` "Alice whispers to you: hi"; Alice: `msg_command_outgoing` "You whisper to Bob: hi"; result 1 |
| `/teammsg hello` (not on a team) | Alice | error `commands.teammsg.failed.noteam` "You must be on a team to message your team" |
| `/list` (2 online, max 20) | any | `commands.list.players` "There are 2 of a max of 20 players online: Alice, Bob"; result 2 |
| `/scoreboard objectives add kills dummy` | op | `commands.scoreboard.objectives.add.success` "Created new objective kills" |
| `/scoreboard players add Alice kills 3` | op | `commands.scoreboard.players.add.success.single` "Added 3 to kills for Alice (now 3)" |
| `/team add red` twice | op | second: `commands.team.add.duplicate` "A team already exists by that name" |
| `/ban Mallory griefing` | admin | `commands.ban.success` "Banned Mallory: griefing"; online Mallory is disconnected |
| `/op Alice` when already op | admin | error `commands.op.failed` "Nothing changed. The player is already an operator" |
| `/whitelist add Bob` twice | admin | second: `commands.whitelist.add.failed` "Player is already whitelisted" |
| `/save-off` twice | owner | second: `commands.save.alreadyOff` "Saving is already turned off" |

---

## 16. Validation

Checks an implementer can run to confirm a command layer matches this document.

1. **Command inventory.** The set of root literals the server offers to a level-4 operator on a dedicated-style server is exactly the index of section 3 minus `publish`, `unpublish`, minus the dev group of section 12 (except `test`, always registered) and minus `jfr` (profiler-dependent). Count: the index lists 97 names; subtract 2 integrated-only, 7 dev-only (`chase`, `raid`, `debugpath`, `debugmobspawning`, `warden_spawn_tracker`, `spawn_armor_trims`, `serverpack`), `debugconfig` (dev and dedicated: dev gate not satisfied) and `jfr`, giving 86 names on a plain dedicated server with the dev flags off and no profiler (aliases extra). Re-count against the index when adding commands.
2. **Permission matrix.** For a source of level L, a root literal is offered iff L >= its level (section 3); sub-branches `random reset` (2) and `datapack create` (4) are checked at the branch. `seed` and `version` are level 0 only in the integrated selection.
3. **Message keys.** For each command, trigger every error path and compare the produced key and arguments with the tables; English text via `%s` substitution by position. Check the keys that the lang file defines but the classes do not reference (section 17) are not emitted.
4. **Result values.** Use `execute store result score` (15 framework: execute grammar) to read results; compare with the examples (`weather rain 6000` stores 6000, `weather clear` stores -1, `gamerule` on a boolean stores 1 or 0, `list` stores the player count, `msg` stores the target count, `say` and `me` store 1).
5. **Round trips.** `gamerule X` after `gamerule X v` reports v; `time set N` then `time query time` reports N; `team add/remove` and `bossbar add/remove` are inverse; `tag add/remove` likewise.
6. **No-op detection.** Commands documented as failing on "already that value" (difficulty, gamerule, time pause/resume/rate/set, worldborder properties, team options, bossbar options, whitelist, save-on/off, tick step/sprint stop) leave state unchanged and report the error rather than success.
7. **Gamerule table.** 59 rules; 12 integer rules with the bounds of section 13; all others boolean; every rule resolvable as both `<id>` and `minecraft:<id>`.

---

## 17. Open questions

Group A lists statements that remain "(recalled, not verified)" in the text (none after the final round); group B lists what was searched and not found; group C lists detail deliberately left untraced.

**A. Recalled, not verified:** none remain as marks in the text other than those in group C.

**B. Searched and not found:**

1. `setworldspawn` keys `.success.new` and `.failure.not_overworld`, and `spawnpoint` keys `.single.new` / `.multiple.new`: no reference in the command classes (searched the four classes and `DebugCommand`).
2. `commands.drop.no_loot_table.entity`: built by `LootCommand` with an `.entity` suffix; en_us has `commands.drop.no_loot_table` and `.block` only.
3. `spread_fire_far_from_player` is the target of a `deprecated.json` rename but is not a registered gamerule id.

**C. Not traced (left open):**

4. `tick`: the sprint algorithm. `random`: the sequence generator and the meaning of the seed flags. `save-all`: the effect of `flush`. `stop`: the shutdown sequence. `kickUnlistedPlayers` (called after `deop`, `whitelist remove|on|reload`). `help`: usage line format. `clone`: the order of the three block groups. `execute`: result details and the store/on/modifier subtrees (15 framework owns the grammar). `function`: the exact result accumulation.
5. Dev and debug classes: `debugconfig`, `debugmobspawning`, `debugpath`, `test`, `raid` and `chase` messages, `debug function`.
6. `setidletimeout`: what a value of 0 does inside the idle check.
7. `PlayerList.op` list file format; `scoreboard` message argument orders (taken from English placeholders); `scoreboard players set|add|remove|operation` per-holder tracked values; `data get` for tag kinds other than numeric, collection, compound and string.
8. `weather`/`advance_weather`: the exact effect of the rule at its three read sites.
9. `commands.gamerule.not_set` text reads "already set" (use the English text as read).
