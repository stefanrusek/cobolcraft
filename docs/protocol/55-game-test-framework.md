# 55. The game-test framework and the `/test` command

| Item | Value |
|---|---|
| Covers | The `/test` command (every subcommand, its grammar, selectors, permission and messages), the test registries and their data formats (`test_instance`, `test_environment`, and the three code-registered registries behind them), the runner (test areas, grid placement, batches, environments, ticks, timeouts, success and failure, retries, `verify`, clean-up), the way the test block and test instance block take part in a run (closes Open question 6 of 31-6), what players see and which packets are involved, what gates the framework, and worked examples. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution; counts of archive entries taken with `unzip -Z1 <jar> \| grep -v '/$'`. Packages read: `net.minecraft.gametest` and `net.minecraft.gametest.framework` (80 class files; read in full or in the parts the questions need, `GameTestHelper`, `GameTestSequence`, the entity and mob builders and the reporters only as far as §6.5 and §5.7 state), `TestBlock`, `TestBlockEntity`, `TestInstanceBlockEntity`, `ResourceSelectorArgument`, `Commands`, `MinecraftServer` (the tick call), `SharedConstants`, the two client renderers `TestInstanceRenderer` and `GameTestBlockHighlightRenderer`, and the language file `assets/minecraft/lang/en_us.json` for English texts. Class and method names are cited to say where a fact was read; they are not a design. Every value was read in this round; anything not read is marked "(inferred)" and listed in Open questions. |
| Extends | 31-6 §9 and §10 (the two block entities; this document closes its Open question 6 and corrects one condition in §9.2, see §6.3), 16 §12 (the `test` row), 15 (selectors, permissions, feedback), 23 (registry loading), 36-2 (structure templates), 40 (the block screens), 05a id 0x29, 05b id 0x81, 05c ids 0x3D and 0x41 (packets), 44 (the `test_instance` POI type). |

"Tick" means a server tick (20 per second) unless stated. "Read" marks a value taken from the bytecode; "(inferred)" marks a deduction.
Texts of messages are the English values of `en_us.json`; `%s` is replaced by position. No text of the artifact's code is reproduced.

---

## 1. What the framework is

The framework is a developer testing tool that ships in the game. A **test** is a data entry in the `test_instance` registry. It names a
structure template (the test area's contents), an environment, limits (ticks), and a way to decide the verdict. A **run** places the
template in the world, sets up the environment, lets the world tick, and reports pass or fail. The framework is driven by the `/test`
command (§4), by the Test Instance Block's screen (31-6 §10.4, 40), or by a separate headless server entry point (§2.3).

| Part | Class (cited) | Role |
|---|---|---|
| Command | `TestCommand` | the whole command tree, the finders, the messages (§4) |
| Definition | `GameTestInstance`, `BlockBasedTestInstance`, `FunctionGameTestInstance`, `TestData` | what a test is (§3) |
| Environment | `TestEnvironmentDefinition` and seven nested types | state set up before and torn down after a batch (§3.5) |
| Runner | `GameTestRunner`, `GameTestBatchFactory`, `GameTestBatch`, `StructureGridSpawner`, `GameTestTicker` | batching, placement, ticking (§5) |
| One test | `GameTestInfo`, `GameTestSequence`, `GameTestHelper` | the per-test state machine and the API function tests use (§5.5, §6) |
| Reporting | `ReportGameListener`, `MultipleTestTracker`, `FailedTestTracker`, `GlobalTestReporter`, `LogTestReporter`, `JUnitLikeTestReporter` | chat lines, counts, the failed set, logs (§5.7, §9) |
| Blocks | `TestBlock`/`TestBlockEntity`, `TestInstanceBlock`/`TestInstanceBlockEntity` | in-world switches and the test area owner (31-6; §6) |
| Headless | `net.minecraft.gametest.Main`, `GameTestMainUtil`, `GameTestServer` | a dedicated test server process (§2.3) |

---

## 2. Gating: what makes `/test` available (scope question 5)

### 2.1 The command

- `TestCommand.register` is called unconditionally from the command-registration routine of `Commands` (between `tellraw` and `tick`
  in registration order). It is not behind `DEBUG_DEV_COMMANDS`, not behind the integrated or dedicated selector, and no
  option, system property, game rule or "gametest" flag exists in the regular server start-up. A scan of every class outside
  `net.minecraft.gametest` finds the framework package referenced only from: `Commands` (the registration), `MinecraftServer` (the tick),
  `BuiltInRegistries`, `Registries`, `RegistryDataLoader` and `VanillaRegistries` (the registries), `TestInstanceBlockEntity` and its
  `Data`, `ServerGamePacketListenerImpl` and `ServerboundTestInstanceBlockActionPacket` (the block actions), `StructureTemplateManager`
  (the test template directories, §3.6) and `TestInstanceBlockEditScreen` (client). No class starts the headless server except
  its own `Main`.
- The root literal `test` requires permission level 2 (`Commands.LEVEL_GAMEMASTERS`; 15 §2). Every subcommand inherits it; none adds a
  stricter check.
- Four subcommands, `export`, `exportclosest`, `exportthese` and `exportthat`, are registered only when the static flag
  `SharedConstants.IS_RUNNING_IN_IDE` is true. The flag is a plain `static boolean` that defaults to false; where it is set was not
  traced (Open question 1). On a normal server `/test` therefore has 17 literals, and 21 with the flag.
- The list in 16 §12 is complete: the artifact has exactly these 21 literals (run, runmultiple, runthese, runclosest, runthat,
  runfailed, verify, locate, resetclosest, resetthese, resetthat, clearthat, clearthese, clearall, stop, pos, create, export,
  exportclosest, exportthese, exportthat). No literal is missing from it.

### 2.2 The tick hook

`MinecraftServer`'s tick calls `GameTestTicker.SINGLETON.tick()` in a profiler section named `gameTests`, but only while the server tick
rate manager "runs normally" (not frozen; `ServerTickRateManager.runsNormally()`). With no runner set the call does nothing.
A frozen game therefore pauses every running test.

### 2.3 The headless test server (dev only)

`net.minecraft.gametest.Main` is a separate entry point (not reachable from the regular server `Main`). It parses these options
(`GameTestMainUtil`, joptsimple; unrecognised options are allowed):

| Option | Value | Default | Meaning |
|---|---|---|---|
| `universe` | path | `gametestserver` | folder where the throw-away world is created; an existing folder is deleted and re-created |
| `report` | file | none | write a JUnit-style XML report there (replaces the logging reporter) |
| `tests` | selector | none (= all) | namespaced id selector with wildcards (the selector of §3.8); "empty means run all" |
| `verify` | boolean | false | run each selected test 100 times for each of the four rotations (needs `tests`, else it logs an error and exits with -1); `repeatCount` is then ignored |
| `repeatCount` | integer | 1 | run each selected test this many times |
| `packs` | folder | none | folder of data packs copied into the world's `datapacks` folder (folders with a `pack.mcmeta`, and `.zip` files) |
| `help` | flag | | print the usage |

`GameTestServer` is a `MinecraftServer` with: world name "Test Level", creative, default difficulty, the `OWNER` permission set, dedicated
command selection, the data-pack list "vanilla" first, a special player list (`GameTestServer$1`). It loads the level, evaluates the selection (tests with
`manual_only` true are excluded; an empty result logs "Test selection matcher ({}) found no tests" and exits with -1), sets the overworld
respawn position to a random block (x and z drawn from -14999992 to 14999992, y = 4), builds one runner over all batches with a
`StructureGridSpawner` of 8 tests per row anchored at that position, and starts it on the first tick. Once per 20 game ticks, and once more at completion (just before the "GAME TESTS COMPLETE" line), it logs the
progress bar of §5.7 (defined there). When the tracker is done it halts the server; it logs "{} GAME TESTS COMPLETE IN {}", the failed required tests,
"All {} required tests passed :)" or "{} required tests failed :(", "{} optional tests failed", and exits with -1 when any required test
failed. A server crash exits with 1. This mode is a continuous-integration facility; our server does not need it (§8).

---

## 3. Registries and data formats (scope question 2)

### 3.1 The five registries

| Registry key (`Registries`) | Kind | Content | Built-in entries (read) |
|---|---|---|---|
| `test_instance_type` | static, filled by code | the codec of each kind of test definition | `block_based`, `function` (2) |
| `test_function` | static, filled by code (`TestFunctionLoader` loaders) | named code consumers `Consumer<GameTestHelper>` | `always_pass` (1; calls `GameTestHelper.succeed`) |
| `test_environment_definition_type` | static, filled by code | the codec of each kind of environment | `all_of`, `clock_time`, `difficulty`, `function`, `game_rules`, `timeline_attributes`, `weather` (7) |
| `test_environment` | data-driven (data pack, JSON) | environment definitions | 1 file: `data/minecraft/test_environment/default.json` |
| `test_instance` | data-driven (data pack, JSON) | test definitions | 1 file: `data/minecraft/test_instance/always_pass.json` |

The two data-driven registries are loaded by the generic loader of 23 and are synchronized to clients (23's registry table rows 41 and
42), because the Test Instance Block screen needs the test ids. Their data files live at `data/<namespace>/test_environment/<path>.json`
and `data/<namespace>/test_instance/<path>.json`. The archive contains exactly one file in each directory (counted without directory
entries). The static registries have no data files; the bootstrap code of §3.3 to §3.5 fills them.

### 3.2 The test definition (`TestData`, shared by every test type)

A `test_instance` JSON object has a `type` key (an id in `test_instance_type`, namespace optional: `minecraft:function`) that selects the
codec, then the common fields of `TestData` at the same level, then the type's own fields.

| Field | Kind | Required | Default | Allowed values and meaning |
|---|---|---|---|---|
| `environment` | environment holder | yes | | an id of `test_environment` (string) or an inline definition object (§3.5) |
| `dimension` | dimension key | no | `minecraft:overworld` | the dimension the test runs in (a `dimension` registry id) |
| `structure` | identifier | yes | | id of the structure template placed as the test area (§3.6) |
| `max_ticks` | integer | yes | | positive (>= 1); the timeout, §5.5 |
| `setup_ticks` | integer | no | 0 | non-negative; extra ticks to wait before the test starts, §5.5 |
| `required` | boolean | no | true | a failing required test makes the summary report failure; optional ones are reported separately |
| `rotation` | rotation | no | `none` | `none`, `clockwise_90`, `180`, `counterclockwise_90`; the test's own rotation, composed with any extra rotation (§5.2) |
| `manual_only` | boolean | no | false | excluded from the headless server's selection (§2.3); `/test` ignores it |
| `max_attempts` | integer | no | 1 | positive; flaky-test attempts, §5.7 |
| `required_successes` | integer | no | 1 | positive; successes needed among the attempts, §5.7 |
| `sky_access` | boolean | no | false | when true the barrier shell has no top layer, §6.4 |
| `padding` | integer | no | 0 | 0 to 128; extra margin around the structure that is cleared and reserved, §5.3 and §6.4 |

(All read in `TestData.CODEC`; the integer ranges are those of `ExtraCodecs.POSITIVE_INT`, `NON_NEGATIVE_INT` and `intRange(0, 128)`.)

### 3.3 The two test types

| Type id | Extra fields | What running it does |
|---|---|---|
| `block_based` | none | the verdict comes from test blocks inside the structure (START, ACCEPT, FAIL, LOG); the exact algorithm is §6.1 |
| `function` | `function` (required): a key of the `test_function` registry | at the start tick the named code consumer runs with a `GameTestHelper`; it decides the verdict by calling `succeed` or `fail`, or by registering checks and sequences (§6.5). A missing function raises an `IllegalStateException` with the text "Trying to access missing test function: <function id>" (read), which the runner wraps as `test.error.unknown` (§9.3) |

Type descriptions shown in the status text: `test_instance.type.block_based` "Block-Based Test", `test_instance.type.function`
"Built-in Function Test".

### 3.4 Built-in contents (names; nothing is bulk-copied)

- `test_instance`: `minecraft:always_pass`: type `minecraft:function`, `function` `minecraft:always_pass`, `environment`
  `minecraft:default`, `structure` `minecraft:empty`, `max_ticks` 1, `setup_ticks` 1, `required` false (so the default dimension, rotation,
  attempts, padding and sky access apply).
- `test_environment`: `minecraft:default`: type `minecraft:all_of` with an empty `definitions` list (does nothing).
- `test_function`: `minecraft:always_pass` (only).
- No other `test_instance` exists: the framework ships no gameplay tests. Every real test comes from a data pack.

### 3.5 Environment definitions

`TestEnvironmentDefinition<T>` has `setup(level)` returning a saved value `T`, and `teardown(level, saved)` taking it back. An
**activation** pairs the definition, the level and the saved value; tearing it down calls `teardown`. JSON: `type` selects the codec, the
other keys are the type's. Anywhere an environment is a field (the test's `environment`, the elements of `all_of.definitions`) it is a
holder: a registry id string, or an inline object.

| `type` | Fields | `setup` | `teardown` |
|---|---|---|---|
| `all_of` | `definitions`: list of environments | activates each element in list order; the saved value is the list of activations | tears the activations down in reverse list order |
| `clock_time` | `clock`: a world clock (a `world_clock` holder, 04/23); `time`: non-negative integer | remembers the clock's total ticks, then sets the clock's total ticks to `time` | sets the total ticks back to the remembered value |
| `difficulty` | `difficulty`: `peaceful`, `easy`, `normal` or `hard` | remembers the level's difficulty and calls the server's set-difficulty with it and the flag true | restores the remembered difficulty, flag true |
| `function` | `setup`, `teardown`: each an optional function id (`function` data pack function) | runs the `setup` function if present | runs the `teardown` function if present. A function runs through the server function manager, with a server command source at permission set GAMEMASTER (level 2), output suppressed, in the batch's level. An id that is not a loaded function logs the error "Test Batch failed for non-existent function {}" and continues |
| `game_rules` | `rules`: a game rule map (rule id to value, the `GameRuleMap` codec; the same shape as the `game_rules` of the saved data, 07 §10, inferred) | records the current value of every rule named in the map, then applies the map with the server's set-all | applies the recorded values the same way |
| `timeline_attributes` | `timelines`: list of `timeline` holders | replaces the level's environment attribute system with one built from the default layers plus one timeline layer per listed timeline (bound to the server clock manager); the saved value is the previous system | sets the previous system back |
| `weather` | `weather`: `clear`, `rain` or `thunder` | remembers the current weather (thunder if thundering, else rain if raining, else clear) and applies the chosen one | resets the level's weather cycle, then applies the remembered weather |

`weather` values apply `setWeatherParameters(clearTime, rainTime, raining, thundering)` on the server with these constants (read from the
enum): `clear` (100000, 0, false, false); `rain` (0, 100000, true, false); `thunder` (0, 100000, true, true).

### 3.6 The structure template of a test

`structure` is an identifier looked up by the structure template manager exactly as 36-2 §2 describes (`data/<ns>/structure/<path>.nbt`
in a data pack, plus the other loader sources). A test whose template cannot be found is refused when selected (`/test run` and the
other commands that build a run print `commands.test.error.structure_not_found` and drop that test). The built-in template used by the
only shipped test is `minecraft:empty`: `data/minecraft/structure/empty.nbt`, a gzip-compressed NBT file with `size` = (1, 1, 1), an empty
`entities` list, one block at position (0, 0, 0) with state index 0, a one-entry palette `minecraft:air`, and `DataVersion` 5023. The
structure's size (from the template) is what the test instance block stores as `size` (§5.2). A template saved from a test area through the
block screen's Save action (31-6 §10.4) is the way test authors produce new templates.

The template manager has two **development-only template locations**, both public static `Path` fields of `StructureUtils` that are null
unless something sets them (what sets them was not traced, Open question 10): `testStructuresTargetDir`, when non-null, makes the manager
hold a `TemplatePathFactory` for it (`StructureTemplateManager.testTemplates()`; the `export` routine writes there and says "Test structure
exporting is disabled" when it is null); `testStructuresSourceDir`, when non-null, adds a directory template source for `.snbt` text
templates read from that folder. The manager's source list is, in order: the world's `generated` directory (`.nbt`), the optional text
directory, and the resource-manager source (data packs). On a normal server both fields are null, so test templates come from data packs
and from `generated` (where the Save action writes, 36-2 §2).

### 3.7 Tags

The framework uses no tag of its own: the `<tests>` selector (§3.8) never resolves tags (`#` is not a legal character), and the archive has
no `test`-related tag file. The only registry link outside the test registries is the point-of-interest type `test_instance` (44 §1.2), registered for the test instance block (block states of that block, 0 tickets, valid range 1); the commands find test instance blocks through the POI manager (§4.2). Any
spatial index that returns the test instance blocks near a position is an equivalent implementation.

### 3.8 The selector argument (`<tests:selector>`)

The argument is `ResourceSelectorArgument` on the `test_instance` registry (argument type 48 `resource_selector`, 15 §6.7).
- Syntax: a run of characters taken greedily from: the identifier characters `0-9`, `a-z`, `_`, `:`, `/`, `.`, `-` (the set of
  `Identifier.isAllowedInIdentifier`), plus `*` and `?`. Anything else ends the token (a following space starts the next argument).
- Normalisation: if the token contains no `:`, the text `minecraft:` is put in front of it (`always_pass` becomes `minecraft:always_pass`;
  `*` becomes `minecraft:*`; `mymod:*` is unchanged).
- Matching: the normalised pattern is matched, as a whole, against the full `namespace:path` text of every registered id by
  `FilenameUtils.wildcardMatch` of the Apache commons-io library, which is outside the artifact; its rules are therefore **(recalled, not
  verified)**: `*` matches any run of characters including none, `?` matches exactly one character, the comparison is case-sensitive,
  everything else matches itself (Open question 15). Result: every matching registry entry, in registry order (a list).
- Empty result: error `argument.resource_selector.not_found` with arguments (the original normalised pattern text, the registry id
  `minecraft:test_instance`): "No matches for selector '%s' of type '%s'". (The pattern is the text after normalisation.)
- Suggestions: the ids of the registry, with the `minecraft:` prefix removed from ids of the default namespace (`displayTestId`), filtered
  by the lower-case text typed so far.
- (recalled, not verified: these hold only if the recalled rules above hold; the artifact shows only that matching is delegated to the commons-io wildcard matcher on the full `namespace:path` text) Because a `*` also crosses `:` and `/`, `*` selects every test, `mymod:*` every test of the namespace, `mymod:door/*` a folder.

---

## 4. The `/test` command (scope question 1)

### 4.1 Grammar

Brigadier argument names are shown as `<name:type>`. Every node below requires level 2 through the root. `[...]` marks an optional tail
that is itself a valid end of the command ("executes" on that node). Integers have no stated bounds unless written.

Retry tail (call it **R**): `[<numberOfTimes:integer >= 0> [<untilFailed:bool>]]`. Build-info tail (**B**) extends it:
`[<numberOfTimes> [<untilFailed> [<rotationSteps:integer> [<testsPerRow:integer>]]]]`. Each value is a child node of the previous one
(`numberOfTimes`, then `untilFailed`, then `rotationSteps`, then `testsPerRow`), and every node of the chain has its own executor, so
any prefix of the chain is a complete command (read in `runWithRetryOptions` and `runWithRetryOptionsAndBuildInfo`).

| Command | Grammar | Notes |
|---|---|---|
| run | `test run <tests:selector> [B]` | places new test areas for the selected tests on a grid and runs them (§4.3) |
| runmultiple | `test runmultiple <tests:selector> [<amount:integer>]` | like `run` with the selected list repeated `amount` times; no retry or rotation arguments |
| runthese | `test runthese [R]` | runs the test instance blocks within 250 blocks, in place |
| runclosest | `test runclosest [R]` | runs the nearest test instance block within 15 blocks, in place |
| runthat | `test runthat [R]` | runs the test instance block being looked at (within 250 blocks), in place |
| runfailed | `test runfailed [B]` and `test runfailed <onlyRequiredTests:bool> [B]` | re-runs the tests that failed in the last run; with `onlyRequiredTests` true only the required ones |
| verify | `test verify <tests:selector>` | stress-runs each selected test, §5.8 |
| locate | `test locate <tests:selector>` | lists test instance blocks of the selected tests, §4.3 |
| resetclosest, resetthese, resetthat | `test resetclosest`, `test resetthese`, `test resetthat` | re-place the template of the nearest (15), nearby (250) or looked-at test instance block |
| clearthat, clearthese | `test clearthat`, `test clearthese` | remove the looked-at test area, or every one within 250 blocks |
| clearall | `test clearall [<radius:integer>]` | remove every test area within the radius (default 250; the value is clamped to 0..1024) |
| stop | `test stop` | halts the running tests, §4.3 |
| pos | `test pos [<var:word>]` | prints the looked-at position relative to its test area, §4.3 |
| create | `test create <id:identifier>`, `test create <id> <width:integer>`, `test create <id> <width> <height:integer> <depth:integer>` | creates an empty test area, §4.3. Read: `height` has no executor of its own, so the forms are id only, id with width, and id with width, height and depth; `create <id> <width> <height>` is not a complete command |
| export (flag) | `test export <test:resource(test_instance)>` | only when `IS_RUNNING_IN_IDE`; the argument is a single registry entry (argument type 46 `resource`), not a selector |
| exportclosest, exportthese, exportthat (flag) | no arguments | only when `IS_RUNNING_IN_IDE` |

Defaults when the optional parts are absent: `numberOfTimes` absent = no retries (the retry options `noRetries`: 1 try, halt on failure);
`rotationSteps` 0; `testsPerRow` 8; `runmultiple` without `amount` = one pass (the plain run). In `runthese`, `runclosest` and `runthat` the
rotation and row count are not arguments (rotation steps 0 and 8 per row are passed, but those commands run existing blocks, so neither
is used).

Meaning of the retry tail: `RetryOptions(numberOfTries, haltOnFailure)` with `numberOfTries` = `numberOfTimes` and `haltOnFailure` =
`untilFailed` (false when absent). `numberOfTimes` 0 means unlimited tries (`unlimitedTries` is `numberOfTries < 1`); `numberOfTimes` 1 means
no retry mode at all (`hasRetries` is `numberOfTries != 1`). With retries on, a test is re-run after each result while
`hasTriesLeft(attempts, successes)` holds: (the tries are unlimited or `attempts` < `numberOfTries`) and (no failure so far or
`haltOnFailure` is false). `untilFailed` true therefore means "repeat until the first failure" (and with unlimited tries, forever
otherwise); `rotationSteps` must be 0 to 3, else the command throws an `IllegalArgumentException` ("rotationSteps must be a value from 0-3.
Got value N"), which the framework reports as the generic unexpected-error failure (16 §2, `command.failed`).
`rotationSteps` n maps to the extra rotation `none`, `clockwise_90`, `180`, `counterclockwise_90`.
`testsPerRow` values below 1 make every test start a new row (the row counter is compared with `>=`).

### 4.2 Finders: which tests a command acts on

A command builds a **finder** (`TestFinder`) with two parts: the test definitions to place new (from a selector or the failed list), and
the existing test instance blocks to act on. The existing blocks come from the POI manager of each searched level.

| Finder | Test definitions | Existing blocks |
|---|---|---|
| `byResourceSelection` (run, runmultiple, verify, locate) | the selector's entries | none (locate searches blocks differently, below) |
| `failedTests(onlyRequired)` (runfailed) | the remembered failed set (§5.7), filtered to required ones when asked | none |
| `nearest` (resetclosest, runclosest, exportclosest) | none | the single test instance block with the smallest Manhattan distance to the source block position among those within 15 blocks, in the source's level |
| `allNearby` (resetthese, runthese, clearthese, exportthese) | none | every test instance block within 250 blocks of the source position, in the source's level |
| `radius(r)` (clearall) | none | every test instance block within `r` blocks (r clamped to 0..1024) |
| `lookedAt` (resetthat, runthat, clearthat, exportthat) | none | among the test instance blocks within 250 blocks, those whose structure bounds (the structure's box, no padding, 31-6 §10.3) are crossed by the ray from the player's camera eye along the look direction for 250 blocks; of those the one chosen sorts first by a comparator keyed on the source block position (inferred: nearest to the source) |
| `createMultipleCopies(n)` (runmultiple) | the list repeated `n` times (`n` = 0 gives an empty list) | the same repetition applied to existing blocks |

The source position is the command source's position truncated to a block position; "within" is the POI manager's `findAll` with the
radius (a spherical radius test of that engine; the POI type is `test_instance`, any occupancy).

### 4.3 What each command does and returns

Common first step: every command except `locate`, `pos`, `create` and `export*` first calls `stopTests()`: it clears the global ticker
(halting any running runner: its environment is torn down, §5.9) and returns. "Feedback" below is `CommandSourceStack` feedback
(15): `sendSuccess(message, broadcast)`, `sendFailure`, or `sendSystemMessage`. `Fail` means a command exception (the command fails with
that message and no result).

| Command | Behaviour | Result |
|---|---|---|
| run, runmultiple, runthese, runclosest, runthat, runfailed | Build the test list (below). Empty: feedback `commands.test.no_tests` (not broadcast), result 0. Otherwise forget the failed set, send `commands.test.run.running` (count, not broadcast), build a runner (§5.2) and start it. Tests from selectors get a new area on the grid (the area's first corner is `createTestPositionAround`, §5.3); tests from existing blocks run in place | 1 when started |
| verify | Build the list as for `run` (selector tests only), expand it (§5.8) and start a runner with halt-on-error | 1 |
| locate | Feedback `commands.test.locate.started` (system message). For each test instance block that the finder yields (existing blocks, plus, across every loaded dimension, every block within 250 blocks of the source position, with the same coordinates in every dimension, whose test is among the selected ones): send `commands.test.locate.found` with (a coordinate text, the horizontal distance), not broadcast, then count it. None found: Fail `commands.test.error.no_test_instances`. Then the player-coordinates line (§5.10), and `commands.test.locate.done` (count, broadcast). The coordinate text is the block position as `chat.coordinates` followed by " ->[<dimension path>]", wrapped in square brackets, coloured green, with a click action that suggests `/execute in <dimension id> run tp @s X Y Z YAW 0` (X Y Z = the block position moved 3 blocks in the direction `NORTH` rotated by the test block's effective rotation; YAW = the integer of the opposite of that direction's yaw) and the hover text `chat.coordinates.tooltip`. The distance is `floor(sqrt(dx*dx + dz*dz))` as text when the block is in the source's dimension, else the text `N/A` | the number of located test instance blocks (the count of `commands.test.locate.done`; read in `TestCommand.locate`, which returns that counter after the broadcast success; 57-4 §7.65 states the same) |
| resetclosest, resetthese, resetthat | Build infos from the existing blocks (below). None: Fail `commands.test.clear.error.no_tests` (the "clear" text, read: the reset path throws the clear exception; the `commands.test.reset.error.no_tests` exception exists but is never thrown). For each: `TestInstanceBlockEntity.resetTest` (31-6 §10.4) with its messages going to the source as system messages. Then `commands.test.reset.success` (count, broadcast) | the count |
| clearthat, clearthese, clearall | For each found block: clear the test bounding box (31-6 §10.4's `clearSpaceForStructure`: air, scheduled ticks and block events cleared, non-player entities discarded), remove the barriers (§6.4), then destroy the test instance block without drops. None: Fail `commands.test.clear.error.no_tests`. Otherwise `commands.test.clear.success` (count, broadcast) | the count |
| stop | `stopTests()` only; no message | 1 |
| pos | Needs a player (else the standard "requires a player" failure of 15). Casts a ray from the player (reach 10.0, fluids ignored) and takes the block position of the hit (the end point on a miss). Searches for a test instance block whose structure box contains that position: radius 15 first, then radius 250. None: Fail `commands.test.error.no_test_containing_pos` with the picked position. The entity must be a test instance block entity, else Fail `commands.test.error.test_instance_not_found`. The relative position = picked position minus the entity's structure position (31-6 §10.3, unrotated). Sends (not broadcast) `commands.test.relative_position` (test name text, coordinate text), where the coordinate text is `commands.test.coordinates` ("x, y, z" of the relative position), bold and green, hover `commands.test.coordinates.copy`, with a copy-to-clipboard action whose text is `final BlockPos <var> = new BlockPos(x, y, z);` (`var` defaults to the word `pos`). It also sends the player a Game Test Highlight Pos packet (05a 0x29) with (picked absolute position, relative position) | 1 |
| create | If width, height or depth is greater than 48: Fail `commands.test.error.too_large` with the argument 48 (so up to 48 is allowed although the text says "less than"). Otherwise: the first corner is `createTestPositionAround` for the source's level (§5.3); create an empty test (below); fill the lowest layer of the structure volume (x from the structure position to +width-1, z to +depth-1, at the structure position's y) with bedrock using block updates; feedback `commands.test.create.success` (test name text, broadcast). `create <id>` uses 5 x 5 x 5; `create <id> <w>` uses w x w x w | 1 |
| export, exportclosest, exportthese, exportthat | IDE only. `export <test>` writes the test's template through `TestInstanceBlockEntity.export` (needs `StructureUtils.testStructuresTargetDir` to be non-null, §3.6; otherwise the red message "Test structure exporting is disabled"); the other three go through each found block's `exportTest` (save, then export). For a found position that holds no test instance block entity: Fail `commands.test.error.test_instance_not_found`. Every processed block is counted, whether or not its export succeeded; a failed export only clears an all-succeeded flag. Count 0: Fail "Could not find any structures to export" (literal text). Otherwise the literal "Exported N structures" (N = the count, broadcast) | 1 when every export succeeded, else 0 (read from the flag; the `export <test>` form returns 1 or 0 by the routine's result the same way) |

**Test list building for run** (`toGameTestInfos` and `toGameTestInfo`):
- *From existing blocks* (`createGameTestInfo`, for each found position): the block entity must be a test instance block entity, else the
  position is dropped with `commands.test.error.test_instance_not_found.position` (x, y, z; failure feedback). The block's test key must
  resolve in the registry, else dropped with `commands.test.error.non_existant_test` (the block's test name text). The test's structure
  template must exist, else dropped with `commands.test.error.structure_not_found` (the structure id). A kept test becomes a `GameTestInfo`
  with the extra rotation = the entity's effective rotation (31-6 §10.3), the retry options of the command, and the block position set.
- *From selection* (`toGameTestInfo`): each selected test whose template exists and whose dimension is loaded becomes a `GameTestInfo`
  with the extra rotation of `rotationSteps` and the retry options; a test whose dimension is not loaded prints the red-failure text
  "Could not resolve level for dimension: <dimension id>" and is dropped. No block position (new area).
- For `run`, selected tests and existing blocks are concatenated in that order (existing blocks first, from `findTestPos`, then the
  selection).

**Creating an empty test** (`StructureUtils.createNewEmptyTest(id, pos, size, rotation, level)`): compute the structure position
(31-6 §10.3, padding 0), clear the transformed bounding box (air, ticks, events, non-player entities), set a `test_instance_block` at `pos`,
and store the data: test = the key `id` in `test_instance` (whether or not such a test exists), the given size, the rotation (`none`),
`ignore_entities` false, status `cleared`, no error.

### 4.4 Result messages

Every key, argument list and English text is in §9.1. In summary: counts are carried as integers; the single test instance name
argument is the test id text (`namespace:path`, the registered name); positions are the three integers x, y, z.

---

## 5. The runner (scope question 3)

### 5.1 Objects and who owns what

- `GameTestInfo` holds one test run: the test holder, the level, an optional test block position, the retry options, an extra rotation,
  `tickCount`, the state flags (`placedStructure`, `chunksLoaded`, `started`, `done`), the failure (`error`), scheduled actions
  (`runAtTickTimeMap`), the sequences, a stopwatch and its listeners. `timeoutTicks` is the test's `max_ticks`.
- `GameTestRunner` holds a list of batches, the list of all infos, the current activation, two structure spawners (for infos with a
  block position, and for infos without), and the flags `haltOnError` and `clearBetweenBatches`.
- `GameTestTicker.SINGLETON` is the global list of infos being ticked; it is cleared by `stopTests()`.
- `MultipleTestTracker` counts the infos of one set (per batch for the runner, per run for the reports).

### 5.2 Building a run

1. The command builds the info list (§4.3) and calls `GameTestRunner.Builder.fromInfo(infos, server)`.
2. **Batching** (`GameTestBatchFactory.fromGameTestInfo`, batch size 50): infos that are non-null are grouped by the key (environment
   holder, dimension). Each group is cut into consecutive lists of at most 50; each list is a batch whose `index` is its position within
   its group (0, 1, ...). The batches are then run one after another (the order is the grouping order of the map, so it is not defined by
   the test ids; inferred). A batch is never empty.
3. Every info gets a new `ReportGameListener` (§5.7).
4. `run` sets only the new-area spawner: a `StructureGridSpawner` with `testsPerRow` as given (8 by default), `clearOnBatch` false and a
   first-corner function `createTestPositionAround(source, dimension)`. The other spawner is the default `IN_PLACE`: for an info that already
   has a block position it calls `prepareTestStructure` and then `startExecution(1)`.
5. `trackAndStartRunner` attaches a batch listener that sends `commands.test.batch.starting` (environment id text, batch index; broadcast),
   a `MultipleTestTracker` over the infos with the summary listener of §5.10 and a failure listener that remembers each failed test in the
   failed set (§5.7), and starts the runner: `start()` runs batch 0.

**Rotation:** the info's effective rotation is the test's own `rotation` composed with the info's extra rotation
(`Rotation.getRotated`). When an existing test instance block is run, the extra rotation passed is that block entity's own effective
rotation (read in `createGameTestInfo`), and `prepareTestStructure` then stores it as the entity's `rotation` data. The effective rotation
of the next run is the test's own rotation composed once more with it, so a test whose own `rotation` is not `none` accumulates its
rotation on each re-run of an existing block (observed in the instructions; not run-verified, Open question 9).

### 5.3 Where a test area goes: the grid

`createTestPositionAround(source, dimension)`: let `P` be the player's block position (the source position when the source is no player).
`surfaceY` = the y of `Heightmap.Types.WORLD_SURFACE` at the column of `P` in that dimension (the chunk at (P.x, P.z) is fetched first, so
it is loaded). The first corner is the block `(P.x, surfaceY, P.z + 3)`. The three-block offset puts the first test just south of the player.

`StructureGridSpawner` keeps, per dimension, a grid state: the first corner, a moving `nextCorner` (starts at the first corner), a
`rowBounds` box (starts as the unit box at the first corner), a `currentRowCount` (0) and the list of tests placed in the last batch.
For each info (`spawnStructure`):
1. The info's block position is the current `nextCorner`.
2. `prepareTestStructure` (§5.5) creates the test instance block at that position and places the template. If it fails to produce a block
   entity the info is skipped (empty result).
3. `startExecution(1)` (§5.5).
4. `bounds` = the entity's **test bounds** (the structure's box inflated by `padding`, as an AABB; 31-6 §10.3 gives the structure box).
   `rowBounds` becomes the union of `rowBounds` and `bounds`.
5. `nextCorner` moves by (`trunc(bounds.xsize) + 5`, 0, 0): tests in a row are separated by 5 blocks along +x (measured after the test's
   own width including padding).
6. `currentRowCount` increases by one; when it reaches `testsPerRow` (comparison `>=`): it resets to 0, `nextCorner` moves by
   (0, 0, `trunc(rowBounds.zsize) + 6`) (6 blocks of gap along +z beyond the row's depth), `nextCorner.x` is set back to the first corner's
   x, and `rowBounds` is reset to the unit box at the new `nextCorner`.
7. The info is added to the list of the last batch.

`onBatchStart` (called before each batch): when `clearOnBatch` is false (as for `run`) it does nothing, so the grid keeps advancing across
batches. When it is true (only `verify`) each previous test of the last batch has its test bounding box cleared (air, ticks, events,
non-player entities), the list is emptied, and the grid state is reset to the first corner (so each batch reuses the same area).

All the infos of one batch are placed in one go when the batch starts (§5.4), before any of them runs.

### 5.4 Starting a batch (`GameTestRunner.runBatch(i)`)

1. If `i` is past the last batch: end the current environment (§5.9), run scheduled re-runs (§5.7), and return.
2. When `i` > 0 and `clearBetweenBatches` (only `verify`): for each info of the previous batch clear its test bounding box (air, ticks,
   events, entities) and destroy its test instance block without drops.
3. Call `onBatchStart` on both spawners.
4. Spawn every info of the batch (the `NOT_SET` default spawner for an info without a block position returns no result, so only a
   configured spawner places new areas); keep the infos that were placed.
5. Log (info): "Running test environment '{}' batch {} ({} tests)..." (environment id, batch index, number placed).
6. End the previous environment and activate the batch's environment (`TestEnvironmentDefinition.activate`) in the batch's dimension level.
   So the **environment is set up after the structures are placed and before the first tick of the batch**.
7. Notify the batch listeners (`testBatchStarting`: the chat line `commands.test.batch.starting`).
8. Create a `MultipleTestTracker` for the batch with a listener that detects completion (§5.9) and add every placed info to the global ticker.

Tests of one batch run at the same time, each on its own area.

### 5.5 The life of one test (`GameTestInfo`)

`prepareTestStructure` (called by the spawner): creates (`setBlockAndUpdate`) the `test_instance_block` at the block position and sets its
data: test = the test's key, size = the template's size (`StructureTemplate.getSize`, or (1, 1, 1) when the template is missing),
rotation = the extra rotation, `ignore_entities` false, status `cleared`, no error. Then `placeStructure`:
- If a test instance block entity cannot place the template, the info fails at once with `test.error.structure.failure` (the test name).
- `TestInstanceBlockEntity.placeStructure` (31-6 §10.4): force-load the structure's chunks, clear the test bounding box (air), discard
  non-player entities in the test bounds, place the template at the start corner with the effective rotation, `ignore_entities` and
  known-shape flags, with flags 818.
- `encaseStructure`: put `barrier` blocks on the boundary shell (§6.4).
- Clear scheduled block ticks and block events in the test bounding box.
- Notify the listeners (`testStructureLoaded`: the report listener counts one attempt).

`startExecution(n)` sets `tickCount` = -(`n` + `setup_ticks` + 1). Both spawners use n = 1, so `tickCount` starts at -(`setup_ticks` + 2).

Per server tick the ticker calls `info.tick(runner)` for every info in the list (and removes those that are done afterwards):
1. If done: return.
2. If the structure was never placed: fail with `test.error.ticking_without_structure`. If the entity is missing: fail with
   `test.error.missing_block_entity`.
3. If there is already an error: mark done (`finish`); the tick still continues with step 5 (it runs once more), then step 6.
4. If the chunks are not yet confirmed: wait (return) until every chunk intersecting the structure bounding box satisfies
   `ServerLevel.areEntitiesActuallyLoadedAndTicking`; then remember that they are loaded. The tick counter does not advance while waiting.
5. `tickInternal`: increase `tickCount` by 1. If `tickCount` >= 0 and the test has not started: `startTest`. Then run every scheduled
   action whose time is <= `tickCount` (and remove it); an exception from an action fails the test (a non-framework exception is wrapped
   as `test.error.unknown`, message of the exception). Then the timeout rule: when `tickCount` > `max_ticks`: if the test has no sequences,
   fail with `test.error.timeout.no_result` (`max_ticks`); otherwise let every sequence fail if not complete, and if there is still no
   error fail with `test.error.timeout.no_sequences_finished` (`max_ticks`). When `tickCount` <= `max_ticks`, tick every sequence.
6. If the test is done after steps 1 to 5: with an error, notify `testFailed`; without, `testPassed`.

`startTest` marks the test started, starts the stopwatch, sets the block entity's status to `running` (31-6 §10.2; the client beam turns
grey), and calls the test definition's `run(helper)`. An exception from it fails the test.

**Ticks.** A test with `setup_ticks` S and `max_ticks` M: the first `info.tick` that advances the counter to 0 is call number S + 2; that
tick runs `startTest` (the test's first tick, `getTick()` = 0), the scheduled actions of tick 0, and so on. The test may run through tick
M; it fails by timeout in tick M + 1 (the check is `tickCount > max_ticks`). A failure raised during a tick is stored but the info is
not marked done until its next `tick` call (step 3), so the failed state is reported one tick later than the failing tick (the chat
line shows the tick of the failure through `test.error.tick`/`test.error.position`).

**Success and failure state.** `succeed()` (only when no error is stored): mark done now and discard every non-player entity inside the
structure's box inflated by one block. `fail(component)` stores a `GameTestAssertException` carrying the message and the current tick
(the stored error is replaced by a later `fail`: last write wins, inferred from a plain field store). `hasSucceeded` = done and no error;
`hasFailed` = an error is stored (also before the info is done); `isDone` = done flag.

### 5.6 Test types and the verdict

The verdict is decided by the test definition's `run` (§6.1 for `block_based`; §6.5 for `function`). The runner only reacts to
`succeed` and `fail`, and to the timeout of §5.5.

### 5.7 Reports, retries and flaky tests (`ReportGameListener`)

One listener instance per info keeps `attempts` and `successes`. `testStructureLoaded` adds an attempt (a re-run copy shares the same
listener, so the counts carry across re-runs). The three outcome handlers:

- **`testPassed`**: `successes` + 1. With retry mode on (`RetryOptions.hasRetries`, i.e. the command's `numberOfTimes` != 1): `handleRetry(true)`
  and stop. Else if the test is not flaky (`max_attempts` <= 1): `reportPassed`: set the block entity's status to finished with no
  error, send the green line `<id> passed! (<ms>ms / <tick>gameticks)` to every online player, and tell the global reporter of the
  success. Else (flaky): when `successes` >= `required_successes`: `reportPassed` with `<id> passed <successes> times of <attempts> attempts.`;
  otherwise send the green line `Flaky test <id> succeeded, attempt: <attempts> successes: <successes>` and re-run the test.
- **`testFailed`**: if not flaky: `reportFailure` (below); with retry mode on also `handleRetry(false)`. If flaky: send the yellow line
  `Flaky test <test> failed, attempt: <attempts>/<max_attempts>` (where `<test>` is the default string form of the definition object, not
  the id: the artifact has no text for it), plus `, successes: <successes> (<required_successes> required)` when `required_successes` > 1;
  then if `max_attempts - attempts + successes >= required_successes` re-run the test, else `reportFailure` with an
  `ExhaustedAttemptsException` ("Not enough successes: <successes> out of <attempts> attempts. Required successes: <required_successes>.
  max attempts: <max_attempts>.", caused by the test's last error).
- **`handleRetry(passed)`**: build a status text `[Run: %4d, Ok: %4d, Fail: %4d` (attempts, successes, attempts - successes),
  plus `, Left: %4d` (`numberOfTries - attempts`) when the tries are not unlimited, then `]`; the description is `<id> passed! <ms>ms` or
  `<id> failed! <ms>ms`; the line is the status padded on the right with spaces to 53 characters (`%-53s`) followed by the description.
  A pass goes through `reportPassed` with that line; a failure is sent as a red line. Then, if `hasTriesLeft(attempts, successes)`,
  the test is re-run.
- **`reportFailure(info, error)`**: the failure description = for a framework assertion error its description (`test.error.tick` or, with a
  position, `test.error.position`), else `Util.describeError(error)`: the same function applied to the cause when there is one, else the
  exception's message when it is not null, else its string form (so a timeout is stored as its plain message without a tick suffix). Store it as the block entity's
  error message (status finished, 31-6 §10.2). Then `visualizeFailedTest`: the line is `(optional)` (no trailing space) when the test is
  optional, then the id, then ` failed! `, then the error's message, then ` cause: <cause>` when the error has a cause; it is sent to every
  online player in red when the test is required and in yellow when optional. When the root cause is an assertion at a position
  (`GameTestAssertPosException`), the block entity gets an **error marker** (31-6 §10.1) at that absolute position with the message. Finally
  the global reporter is told of the failure.

**Re-running** (`GameTestRunner.rerunTest(info)`): `info.copyReset()` makes a fresh info with the same test, extra rotation, level, retry
options and block position; each listener of the old info is told (`testAddedForRerun`: the report listener and the tracker attach to the
copy); the copy is appended to the runner's info list and the re-run list. If the runner is idle (stopped) the re-runs start at once;
otherwise they start when the last batch ends (§5.4 step 1): the runner re-batches the re-run list, logs
"Starting re-run of tests: {}" with the ids joined by ", ", and runs those batches (each in place, on the same block position). A re-run
of an area first re-places the template (the structure is rebuilt each attempt).

**The failed set** (`FailedTestTracker`): a global set of test holders. `trackAndStartRunner` adds a test to it on every failure
(the failure listener). It is cleared by `run` (when it has tests to run), `verify`, `test run` through the block (31-6 §10.4's `runTest`), and
not cleared when a run finds no tests. `runfailed` reads it.

**Required and optional:** `required` decides (a) the colour of the failure line, (b) the count that the summary uses (§5.10), (c) the
colour of the beam on the block (31-6 §10.3), (d) the `onlyRequiredTests` filter of `runfailed`. A failing optional test never turns the
summary into a failure.

**The progress bar** (`MultipleTestTracker.getProgressBar`, used by the headless server): `[`, then one character per test in tracker order, then `]`: a space for a test not started, `+` succeeded, `X` failed and required, `x` failed and optional, `_` otherwise (started, running).

**The global reporter** is a `LogTestReporter` unless replaced (headless server with `report`): on a failure it logs, at error level for a
required test, "{id} failed at {x, y, z}! {error}" (the position is the block position's short string), and for an optional test, at warn
level, "(optional) {id} failed at {x, y, z}. {error}". The JUnit-like reporter (headless only) writes `testsuite`, `testcase` (attributes
`name`, `classname` = the id, `time`) and `failure` or `skipped` elements; its exact layout is not needed (Open question 8).

### 5.8 `verify`

`/test verify <tests>`: stop, build the list as for `run`. For each info of that list, for each of the four rotations in the order
`none`, `clockwise_90`, `180`, `counterclockwise_90`: make 100 fresh infos for the test (the given rotation as the extra rotation, retry
options (1 try, halt on failure), the original info's block position) and wrap them as one batch (`index` = the rotation's ordinal,
environment and dimension of the test). All these batches are run by one runner with: a grid spawner of **10 tests per row** as the
new-area spawner and as the existing-area spawner (the same instance, inferred from the call sequence) with `clearOnBatch` true; `haltOnError`; `clearBetweenBatches`; and a re-batcher of 100 per batch.
`haltOnError`: when any test fails, the runner ends the current environment, un-forces every force-loaded chunk of the level, clears the
ticker and stops: no further batch starts (and the failing area is left as it is). The failed set is cleared first.
So `verify` of N tests runs 400 N test executions in 4 N batches of 100, each batch on the same grid positions.

### 5.9 Clean-up, reset and teardown

- **After each test**: a passed test has its barriers removed at once (the runner's per-test listener calls `removeBarriers`; the block
  entity's status is finished, no error). A failed test keeps its barrier shell and its error marker so it can be inspected (31-6 §10.3's
  red or orange beam).
- **After each batch** (all infos of the batch done): the batch listeners get `testBatchFinished` (no feedback by the command), **every
  force-loaded chunk of the level is un-forced** (including chunks the operator forced; the runner reads the level's whole set, observed),
  and the next batch starts. With no next batch the runner ends the environment and runs scheduled re-runs.
- **Environment teardown** happens: at the start of the next batch, at the end of the last batch, when `stop` or any other command calls
  `stopTests()` (the ticker's `clear` stops the runner, which ends the activation), and on `haltOnError`.
- The test areas are **not** removed automatically (only `verify` clears between batches). `resetclosest/these/that` re-place the
  template; `clearthat/these/all` delete the areas and the test instance blocks (§4.3).
- `stop` leaves in-flight tests as they are: their structures and barriers remain.

### 5.10 What players see

All chat lines go through two channels:
- **Command feedback** to the source (`sendSuccess`, `sendFailure`, `sendSystemMessage`): the `commands.test.*` messages of §9.1.
  The batch line, the summary lines, `clear.success`, `reset.success`, `create.success` and `locate.done` are sent with the broadcast flag
  set (so operators see them as command feedback per 15); `run.running`, `no_tests`, `locate.found` and the `pos` lines are not.
- **Broadcast to every online player** (system message, no sender): the report lines of §5.7 (green passes, red or yellow failures,
  yellow and green flaky lines). They use `ReportGameListener.say`, which iterates the player list; they are plain literal text (not
  translatable) with the colours above.

The **summary**, when the run's tracker is done (every info of the run, counting re-run copies, is done): feedback
`commands.test.summary` (total count, white, broadcast); then, if any required test failed, failure feedback
`commands.test.summary.failed` (number of failed required tests); otherwise `commands.test.summary.all_required_passed` in green
(broadcast); then if any optional test failed a system message `commands.test.summary.optional_failed` (count); then the coordinate
lines: `test.player.coordinates` and `test.run.coordinates` (§9.3). The counts come from the tracker: a test is failed when it has an error;
required or optional by its `required` field. The block-run path sends the same summary to the console source.

**The two coordinate lines.** Each is the translation with four arguments, wrapped in square brackets, and coloured with a click action that
**suggests a command** (the text goes into the chat box) and the hover text `chat.coordinates.tooltip` ("Click to teleport"):
- `test.player.coordinates` (gold): "Player coordinates: [x, y, z] in <dimension path>": the player's block position, the dimension id
  text after its first `:`; the suggested command is `/execute in <dimension id> run tp @s x y z <yaw> <pitch>` with the player's current
  yaw and pitch floored.
- `test.run.coordinates` (yellow): "Test coordinates: [x, y, z] in <dimension path>": (player x, `surfaceY`, player z) where tests were
  put; the suggested command is `/execute in <dimension id> run tp @s x surfaceY z 0 0`.
Which of the two lines is printed in which situation (they depend on the player being in the single test dimension and on the dimension
being the overworld) was read only in outline (Open question 3).

**On the blocks** (client-visible state): the test instance block entity's `status` and `error_message` (31-6 §10.1) are in the block
entity data, so the client sees them through the normal block entity update: the beam colour (31-6 §10.3: grey while running, green on
success, red for a failed required test, orange for a failed optional one) and, for each stored error marker, a translucent red box
(alpha 0.375, colour red) around the marker's block (inflated by 0.02) with the marker's text drawn as billboard text (white, centred, scale
0.16, always on top, 1.2 blocks above the block's lower corner, offset 0.5 in x and z). `TestInstanceRenderer` draws these, plus the
structure box (31-6 §10.3).

There are **no sounds and no particles** anywhere in the framework (no `SoundEvents`, `ParticleTypes` or sound or particle packets are
referenced by any class read).

---

## 6. The test blocks and the runner (scope question 4; closes Open question 6 of 31-6)

### 6.1 `BlockBasedTestInstance.run` and the per-tick check

At the test's first tick (§5.5, `startTest`) the runner calls `run(helper)` of the block-based test:
1. **Find the START block.** Scan every position of the structure box (`forEveryBlockInStructure` iterates the structure's relative AABB
   shrunk by 1 on its max sides, which with the inclusive iteration is exactly the structure's positions, rotation applied) and collect the test
   blocks whose mode is START. None: the test fails now with `test_block.error.missing`
   (argument: the mode's display name, `test_block.mode.start` "Start"). More than one: fails with `test_block.error.too_many` (the same
   argument). A failure here is an exception thrown from `startTest`, which fails the test (§5.5).
2. **Trigger it.** Call `trigger()` on the START block's entity. In mode START that powers the block (`powered` true, neighbours updated,
   output 15, 31-6 §9.2) and logs its message if not blank. Nothing else is done to START blocks afterwards.
3. **Schedule the check for every tick** from the current tick (0) up to but not including `max_ticks`: the check is run as scheduled
   actions at ticks 0, 1, ..., `max_ticks` - 1 (`GameTestHelper.onEachTick`; same tick 0, after `run` returns, because the action loop of
   `tickInternal` runs after `startTest`).

**The check** (each tick):
1. Collect all ACCEPT blocks in the structure. None: the test fails with `test_block.error.missing` (the mode name `test_block.mode.accept`
   "Accept").
2. If **any** ACCEPT block has `hasTriggered()` true: the test succeeds (`succeed()`); the check for this tick ends.
3. Otherwise, for each FAIL block (in scan order) with `hasTriggered()` true: fail the test with the block's `message` as plain text (a
   literal, not a translation): the failure shown is that message wrapped by the tick description (`test.error.tick`: "<message> on tick
   <n>"). The failure is thrown (`GameTestHelper.fail` throws), so the first triggered FAIL block ends the check for that tick: later FAIL
   blocks and the LOG step are not reached, and that FAIL block's `reset()` (which would follow the consumer) is not reached either; the
   test is failed anyway.
4. For each LOG block with `hasTriggered()` true: call `trigger()` (which logs the block's message, 31-6 §9.2, and sets `triggered` again) and
   then `reset()`.

So within a test: ACCEPT wins over FAIL in the same tick (ACCEPT is tested first and ends the check); a FAIL fails the test on the tick it is
seen; LOG blocks only produce server log lines; and the test times out (`test.error.timeout.no_result`) if no ACCEPT trigger happens within
the ticks 0 to `max_ticks`. After success the runner discards the entities and the per-test listener removes the barriers.

### 6.2 Who calls `trigger()` and `reset()`

| Mode | Who calls `trigger()` | With what | `reset()` |
|---|---|---|---|
| START | the block-based test, once at tick 0 (§6.1 step 2); also `TestBlock.neighborChanged` is **not** used for START (§6.3) | nothing (no argument) | `TestBlock.tick` calls it; the runner never calls it for START blocks; nothing schedules `TestBlock.tick` in the code read (Open question 4) |
| ACCEPT, FAIL, LOG | `TestBlock.neighborChanged` on the server, when the block's neighbour signal rises while the block's `powered` flag is false (§6.3). The check of §6.1 also calls `trigger()` itself for triggered LOG blocks | nothing | the check of §6.1 calls `reset()` on each triggered LOG block after its `trigger()`; a triggered FAIL block fails the test before any reset; ACCEPT blocks are never reset (the test ends on them) |

`TestBlockEntity.trigger()` has no parameters. For non-START modes it logs (LOG mode only) and sets the transient `triggered` flag; the
runner's check polls `hasTriggered()`. It is the redstone signal that makes ACCEPT, FAIL and LOG blocks trigger.

### 6.3 Correction to 31-6 §9.2

(31-6 §9.2 has been corrected to match this; the text below records what the earlier wording said.)

`TestBlock.neighborChanged` (server only) returns at once when the entity's mode is **START**. For the other three modes it computes `p` =
`hasNeighborSignal(pos)` and compares it with the entity's `powered`: `p` true and `powered` false: `setPowered(true)` then `trigger()`;
`p` false and `powered` true: `setPowered(false)`; otherwise nothing. The earlier text of 31-6 §9.2 said "when the mode is START" for this
rule (now corrected); the bytecode has the opposite test (the START mode is the one excluded). The rest of §9.2 (the `trigger`, `reset`, `ownSignal` and
`tick` rules, and the START block powering its neighbours) is confirmed.

### 6.4 The test instance block and the area

The Run, Reset and Save actions of the block screen (05c 0x41, 31-6 §10.4) are the same operations as the commands:
- Run: the block entity (31-6 §10.4 `runTest`) places the template, clears its error markers, clears the ticker and the failed set, sends
  `test_instance_block.starting` (the test's registry id text), makes a `GameTestInfo` (retry options: none; extra rotation = the entity's
  stored `rotation`; block position = the entity's), builds a runner with `Builder.fromInfo` (default spawners: in place), and starts it
  through `trackAndStartRunner` with the server's **console command source**, so the summary lines go to the console and to operators, not to
  the player who pressed the button.
- Reset: `resetTest` (31-6 §10.4): remove barriers, clear markers, re-place the template, send `test_instance_block.reset_success` (the test name) to the player.

**The barrier shell** (`encaseStructure`, `removeBarriers`, `processStructureBoundary`): let `B` be the structure bounding box as an AABB
(min = box min, max = box max + 1, so it spans exactly the structure's blocks; 31-6 §10.3). The shell box runs from `containing(B.min) - (1, 1, 1)`
to `containing(B.max)` (both inclusive), which is the structure's inclusive box enlarged by one block on every side. A position of that box is on the shell when its x, z or y equals a bound of that box on the x, z or lower y faces, and, unless the test has
`sky_access`, also on the top y face. `encaseStructure` sets a `barrier` block on every shell position whose block is not a test instance
block (any other block is overwritten); `removeBarriers` sets air on every shell position that currently holds a barrier. Both use
`setBlockAndUpdate`. With `padding` greater than 0 the shell is still around the structure itself (the padding region is cleared and
reserved, not walled).

### 6.5 `function` tests (not needed to implement `block_based`)

`GameTestHelper` is the API of function tests: about 170 public methods in these groups: asserting (`assertBlock*`, `assertEntity*`,
`assertItem*`, `assertContainer*`, `assertValue*`, `assertTrue`, `assertFalse`, `assertRedstoneSignal`, etc.), spawning and moving
(`spawn*`, `spawnMob`, `spawnItem`, `makeMockPlayer`, `moveTo`), world edits (`setBlock`, `placeBlock`, `destroyBlock`, `useBlock`,
`pullLever`, `pressButton`, `pulseRedstone`, `setBiome`, `setTime`), coordinate conversion (`absolutePos`, `relativePos`, `absoluteVec`,
`relativeVec`, `getBounds`, `getTestRotation`, `getTestDirection`), and control (`succeed`, `fail`, `succeedIf`, `succeedWhen`,
`succeedOnTickWhen`, `failIf`, `failIfEver`, `onEachTick`, `runAtTickTime`, `runAfterDelay`, `runBeforeTestEnd`, `startSequence`). A
`fail` throws an assertion exception carrying the message and the current tick; the runner catches it from the action that raised it.
`GameTestSequence` (the object `startSequence` returns) is a list of timed events (`thenIdle`, `thenExecute`, `thenWaitUntil`,
`thenSucceed`, `thenFail`, `thenTrigger`, ...) run in order, one pass per tick; a sequence event that throws an assertion exception is retried the
next tick, and when `tickCount` passes `max_ticks` the sequences fail (the timeout rule of §5.5). The shipped game has only the
function `always_pass`, so none of this is exercised by the built-in data. The assertion helpers' message keys are listed in §9.4; their
argument order and exact use were not traced (Open question 2).

---

## 7. Packets and client-side effects

| Packet | Id | When | Content | Cross-reference |
|---|---|---|---|---|
| Game Test Highlight Pos (clientbound) | 05a 0x29 | `test pos` (to the executing player only) | absolute position, relative position (two Position values) | 05a. Client effect (`GameTestBlockHighlightRenderer.highlightPos`): a marker keyed by the absolute position is stored for 10000 ms (client clock) with the text = the relative position's short string ("x, y, z") and colour `0x6000FF00` (ARGB: alpha 0x60, green); each frame, until it expires, a filled cuboid on the block (inflated by 0.02) and a billboard text of the marker's text (white, centred, scale 0.16, always on top, at lower corner + (0.5, 1.2, 0.5)) are drawn. `clear()` empties the markers (not called by any packet path read) |
| Test Instance Block Status (clientbound) | 05b 0x81 | reply to the INIT and QUERY actions (31-6 §10.4) | the description text, optional size | 05b; 40 §8 |
| Test Instance Block Action (serverbound) | 05c 0x41 | the block screen's buttons | position, action, test key, size, rotation, ignore entities | 05c; 31-6 §10.4 |
| Set Test Block (serverbound) | 05c 0x3D | the test block screen | position, mode, message | 05c; 31-6 §9.2 |
| Block Entity Data / Block Update | existing | any change of a test block entity or test instance block entity (`status`, `error_message`, `errors`, markers, the `mode` property) | the "custom only" update tags of 31-6 | 31-1 |

No other packet is added by the framework. The test instance block's status, error text and error markers travel as the block entity's
normal update data (31-6 §10.1 keys `data` and `errors`), which is why the client can draw the beam and the markers.

---

## 8. What a server may omit (scope question 5)

(Recommendations, inferred from the read structure; each is marked by the part it refers to.)

| Part | Needed for a testing facility? | Notes |
|---|---|---|
| `/test` root, `run`, `runmultiple`, `runthese`, `runclosest`, `runthat`, `runfailed`, `stop`, `clear*`, `reset*`, `create` | the useful core | `locate` and `pos` are convenience; `pos` needs the highlight packet |
| `export*` | no | gated behind the IDE flag in the artifact; needs a development tree |
| `verify` and the headless `Main`/`GameTestServer`/JUnit report | no | continuous-integration tooling; `verify` is `run` with 400 copies |
| `test_instance` loader, `block_based` type | yes | the simplest useful test type; needs the test block and the barrier block, bedrock |
| `function` type, `test_function` registry, `GameTestHelper`, `GameTestSequence` | no | only `always_pass` ships; it can be modelled as a block-less test that succeeds at its first tick |
| `test_environment` and its seven types | at least `all_of`, `weather`, `clock_time`, `game_rules` | `default` (empty `all_of`) must exist because the shipped test names it |
| Retries, flaky tests, failed set, `required` | optional | the `required` flag is needed for the summary text |
| Grid placement | yes | the layout rule of §5.3 is what makes areas not overlap |
| Test Instance Block screen packets | only if the block UI is wanted | Run, Reset, Save are the same operations as the commands |
| Sounds and particles | none exist | |

Order of dependencies for a minimal implementation: (1) the two registries and the shipped files; (2) the template manager and the empty
template; (3) the test instance block and a position index; (4) the barrier shell, clear and place routines (31-6 §10.4, 36-2); (5) the
ticker, the info state machine and the block-based check; (6) the grid spawner and batching; (7) the command tree and the summary.

---

## 9. Message keys and English texts (every key read)

### 9.1 `commands.test.*` (the command; 26 keys in the language file, all listed)

| Key | Arguments (in order) | English text | Used by |
|---|---|---|---|
| `commands.test.batch.starting` | environment id text, batch index | Starting environment %s batch %s | batch listener, broadcast |
| `commands.test.clear.error.no_tests` | none | Could not find any tests to clear | `clear*` and `reset*` failure |
| `commands.test.clear.success` | count | Cleared %s structure(s) | `clear*`, broadcast |
| `commands.test.coordinates` | x, y, z (integers) | %s, %s, %s | `pos` |
| `commands.test.coordinates.copy` | none | Click to copy to clipboard | `pos` hover |
| `commands.test.create.success` | test name text | Created test setup for test %s | `create`, broadcast |
| `commands.test.error.no_test_containing_pos` | x, y, z | Can't find a test instance that contains %s, %s, %s | `pos` failure |
| `commands.test.error.no_test_instances` | none | Found no test instances | `locate` failure |
| `commands.test.error.non_existant_test` | test name text | Test %s could not be found | building from blocks |
| `commands.test.error.structure_not_found` | structure id (a translation argument holding the identifier text) | Test structure %s could not be found | any build of tests |
| `commands.test.error.test_instance_not_found` | none | Test instance block entity could not be found | `pos`, `export*` |
| `commands.test.error.test_instance_not_found.position` | x, y, z | Test instance block entity could not be found for test at %s, %s, %s | building from blocks |
| `commands.test.error.too_large` | 48 | The structure size must be less than %s blocks along each axis | `create` |
| `commands.test.locate.done` | count | Finished locating: found %s structure(s) | `locate`, broadcast |
| `commands.test.locate.found` | coordinate text, distance text | Found structure at: %s (distance: %s) | `locate` |
| `commands.test.locate.started` | none | Started locating test structures. This might take a while... | `locate`, system message |
| `commands.test.no_tests` | none | No tests to run | `run`-family, not broadcast |
| `commands.test.relative_position` | test name text, coordinate text | Position relative to %s: %s | `pos` |
| `commands.test.reset.error.no_tests` | none | Could not find any tests to reset | defined, never thrown (the reset path throws the `clear` text) |
| `commands.test.reset.success` | count | Reset %s structure(s) | `reset*`, broadcast |
| `commands.test.run.no_tests` | none | No tests found | in the language file; no class read uses it |
| `commands.test.run.running` | count | Running %s test(s)... | `run`-family, not broadcast |
| `commands.test.summary` | total count | Game Test complete! %s test(s) were run | summary, white, broadcast |
| `commands.test.summary.all_required_passed` | none | All required tests passed :) | summary, green, broadcast |
| `commands.test.summary.failed` | failed required count | %s required test(s) failed :( | summary, failure feedback |
| `commands.test.summary.optional_failed` | failed optional count | %s optional test(s) failed | summary, system message |

Also used by the command, from other families: `chat.coordinates` ("%s, %s, %s", `locate`), `chat.coordinates.tooltip` ("Click to teleport",
`locate` and the two coordinate lines), `argument.resource_selector.not_found` (15 §6.7).
Literal (untranslated) texts: "Could not find any structures to export", "Exported %s structures" (count substituted), "Could not resolve level for
dimension: <id>", "Could not find a test instance block entity at the given coordinate <pos>" (an internal error message, not shown to
players), and "Test structure exporting is disabled" (red) from the export routine.

### 9.2 `test_block.*`, `test_instance_block.*`, `test_instance.*`

| Key | Arguments | English text | Used by |
|---|---|---|---|
| `test_block.error.missing` | mode display name | Test structure missing %s block | block-based check (§6.1) |
| `test_block.error.too_many` | mode display name | Too many %s blocks | block-based check |
| `test_block.mode.start`, `.log`, `.fail`, `.accept` | none | Start, Log, Fail, Accept | mode display names |
| `test_block.mode_info.start` | none | Start Mode - The starting point for a test | block screen (40) |
| `test_block.mode_info.log` | none | Log Mode - Log a message | block screen |
| `test_block.mode_info.fail` | none | Fail Mode - Fail the test | block screen |
| `test_block.mode_info.accept` | none | Accept Mode - Accept success for (part of) a test | block screen |
| `test_block.message`, `test_block.invalid_timeout` | none; value | Message: ; Invalid timeout (%s) - must be a positive number of ticks | block screen |
| `test_instance_block.starting` | test registry id text | Starting test %s | Run action |
| `test_instance_block.reset_success` | test name text | Reset succeeded for test: %s | Reset action |
| `test_instance_block.error.no_test` | x, y, z | Unable to run test instance at %s, %s, %s since it has an undefined test | Run action |
| `test_instance_block.error.no_test_structure` | x, y, z | Unable to run test instance at %s, %s, %s since it has no test structure | Run action |
| `test_instance_block.error.unable_to_save` | x, y, z | Unable to save test structure template for test instance at %s, %s, %s | Save action |
| `test_instance_block.invalid_test` | none | no entry in `en_us.json` (the key is shown as written) | the name text (`INVALID_TEST_NAME`, 31-6 §10.1) used when a block has no test; it is the argument of `commands.test.error.non_existant_test` in that case |
| `test_instance_block.entities`, `.rotation`, `.size`, `.test_id`, `.invalid` | none | Entities:, Rotation:, Test Structure Size, Test Instance ID, [invalid] | block screen |
| `test_instance.action.reset`, `.run`, `.save` | none | Reset and Load, Load and Run, Save Structure | block screen |
| `test_instance.type.block_based`, `.function` | none | Block-Based Test, Built-in Function Test | description |
| `test_instance.description.type` | type text (blue) | Type: %s | description |
| `test_instance.description.function` | function id | Function: %s | description of function tests |
| `test_instance.description.structure` | structure id | Structure: %s | description |
| `test_instance.description.batch` | environment id | Environment: %s | description |
| `test_instance.description.dimension` | dimension id | Dimension: %s | description |
| `test_instance.description.no_test`, `.invalid_id`, `.failed` | none; none; message | No such test, Invalid test ID, Failed: %s | status (31-6 §10.4, 40) |

A test's description text (05b 0x81, `GameTestInstance.describe`) is the concatenation of rows. A row is the translation with one argument, the argument
styled blue, followed by the literal text "\n". The rows, in order: `test_instance.description.type` (the type's text), for `function` tests
`test_instance.description.function` (the function id), then `test_instance.description.structure` (the structure id),
`test_instance.description.batch` (the environment's registered id text, `Holder.getRegisteredName`), and
`test_instance.description.dimension` (the dimension id).

### 9.3 Runner-level `test.*` keys (the ones the framework itself raises)

| Key | Arguments | English text | Raised when |
|---|---|---|---|
| `test.error.structure.failure` | test name text | Failed to place test structure for %s | the template could not be placed (§5.5) |
| `test.error.ticking_without_structure` | none | Ticking test before placing structure | §5.5 step 2 |
| `test.error.missing_block_entity` | none | Missing block entity | §5.5 step 2 |
| `test.error.timeout.no_result` | `max_ticks` | Didn't succeed or fail within %s ticks | §5.5 |
| `test.error.timeout.no_sequences_finished` | `max_ticks` | No sequences finished within %s ticks | §5.5 |
| `test.error.tick` | message, tick | %s on tick %s | wraps every assertion failure without a position (the displayed failure) |
| `test.error.position` | message, absolute x, y, z, relative x, y, z, tick | %s at %s, %s, %s (relative: %s, %s, %s) on tick %s | wraps an assertion failure at a position |
| `test.error.unknown` | exception message | Unknown internal error: %s | an unexpected exception in a test action |
| `test.error.fail` | none | Fail conditions met | a helper's fail-if condition |
| `test.player.coordinates` | x, y, z, dimension path | Player coordinates: [%s, %s, %s] in %s | §5.10 |
| `test.run.coordinates` | x, y, z, dimension path | Test coordinates: [%s, %s, %s] in %s | §5.10 |
| `test_block.error.missing`, `test_block.error.too_many` | (§9.2) | | block-based check |

### 9.4 The other `test.error.*` keys

The language file has 49 `test.error.*` keys in all. The ones the runner itself raises are in §9.3. The remaining 40 (the
`expected_*`, `unexpected_*`, `block_property_*`, `entity_property*`, `value_*`, `state_not_equal`, `too_many_entities`, `spawn_failure`,
`set_biome`, `wrong_block_entity`, `not_a_block_item`, `invalid_block_type` and `sequence.*` keys) exist and are raised by function-based
tests only (`GameTestHelper`, `GameTestSequence`); the shipped data has no such test, so they are not tabulated (Open question 2).


---

## 10. Worked examples

Assumptions for all examples: the player stands at block (10, 64, 20) in the overworld; the world-surface height of that column is 64
(flat ground whose top block is y = 63). Then `createTestPositionAround` gives P = (10, 64, 23). Test data pack ids are illustrative.

### 10.1 Creating a test area

Command: `/test create mymod:door 3 2 4` by a level-2 operator.
1. Sizes 3, 2, 4 are all <= 48.
2. `createNewEmptyTest(mymod:door, (10,64,23), size (3,2,4), none)`: structure position = (10,64,23) + (0,1,1) = (10,65,24); the structure box
   is (10..12, 65..66, 24..27); that box is cleared to air; a `test_instance_block` is set at (10,64,23); its data = test `mymod:door`,
   size (3,2,4), rotation `none`, `ignore_entities` false, status `cleared`, no error.
3. Bedrock is placed on the floor layer: x 10..12, z 24..27 at y = 65 (12 blocks).
4. Feedback (broadcast): "Created test setup for test mymod:door".
5. Result 1. (At this point no `test_instance` named `mymod:door` is required to exist; the block's Save action then writes the template
   `mymod:door`, and a data pack file `data/mymod/test_instance/door.json` makes it runnable.)

`/test create mymod:door 49` fails with "The structure size must be less than 48 blocks along each axis". `/test create mymod:door 3 2` is
an incomplete command (Brigadier "incorrect argument for command").

### 10.2 A data pack test

File `data/mymod/test_instance/door.json`:

```json
{"type": "minecraft:block_based", "environment": "minecraft:default", "structure": "mymod:door",
 "max_ticks": 100, "setup_ticks": 0}
```

(`required` true, `dimension` overworld, rotation none, padding 0.) The template `mymod:door` must contain exactly one START test block and at
least one ACCEPT test block, for instance a START block next to a redstone line that ends at a block that powers an ACCEPT block.

### 10.3 A test that passes (the shipped `always_pass`)

`/test run always_pass`
1. The selector `always_pass` becomes `minecraft:always_pass` and matches one entry. Existing blocks: none. The template
   `minecraft:empty` exists. One info, rotation `none`, no retries.
2. Not empty: forget the failed set; feedback (not broadcast) "Running 1 test(s)...".
3. One batch (key: environment `minecraft:default`, overworld), index 0, 1 test. Batch start: grid first corner P = (10, 64, 23); the test
   instance block is set at P; data: test `minecraft:always_pass`, size (1,1,1) (the template's size), rotation `none`; structure position
   (10,65,24); the single air block is placed there; the barrier shell: the structure AABB is (10,65,24)-(11,66,25), the shell box runs
   from (9,64,23) to (11,66,25): 26 positions around the centre, one of which is the test instance block itself (10,64,23), so 25 barriers
   are placed (`sky_access` false, so the top layer is included).
4. Log: Running test environment 'minecraft:default' batch 0 (1 tests)...; the environment `all_of []` does nothing; chat (broadcast)
   "Starting environment minecraft:default batch 0".
5. `startExecution(1)`: `tickCount` = -(1 + 1 + 1) = -3. Ticker calls: tick 1 -> -2; tick 2 -> -1; tick 3 -> 0: `startTest`: status
   `running`; the function `always_pass` calls `succeed()` at once: done, entities in the inflated box discarded.
6. The same tick: no error and done -> `testPassed`: `successes` 1, not in retry mode, not flaky: `reportPassed`: status `finished`, no error;
   chat to every player in green: `minecraft:always_pass passed! (<n>ms / 0gameticks)`. The per-test listener removes the 25 barriers.
7. The tracker is done: summary: "Game Test complete! 1 test(s) were run" (white); no required failures: "All required tests passed :)"
   (green); no optional failures (the test is optional but passed); then the coordinate lines of §5.10.
8. Batch finished: forced chunks un-forced; no next batch: the environment is torn down; no re-runs: the runner stops. Command result was 1.

### 10.4 A block-based test that fails by a FAIL block, and one that times out

For `mymod:door` of §10.2 run with `/test run mymod:door` (same start as §10.3, template placed at the grid corner, test starts on call
number 2 since `setup_ticks` is 0: `tickCount` -(1+0+1) = -2, tick 2 reaches 0).
- At tick 0: the START block is found (exactly one) and triggered: `powered` true, output 15, log line "Test start (at <x, y, z>): <message>" if
  the block has a message. The check is scheduled for ticks 0 to 99.
- Failure: at tick 7 a redstone signal reaches a FAIL block with the message `door opened early`; `TestBlock.neighborChanged` sets its
  `triggered`. At tick 7's check the ACCEPT blocks are not triggered, the FAIL block is: the test fails with the text
  "door opened early" (the FAIL block is not reset: the failure is thrown before the reset, §6.1 step 3; as `test.error.tick`: "door opened early on tick 7"). Done on the next call (tick 8). The block entity gets error
  message "door opened early on tick 7" and the status finished (red beam). The server console log: `mymod:door failed at <x, y, z>! ...`
  (error level, required). Chat to all players (red): `mymod:door failed! door opened early on tick 7`. Summary: "Game Test complete! 1 test(s) were
  run" and the failure feedback "1 required test(s) failed :(". The barriers stay.
- Timeout: no ACCEPT trigger ever occurs. Checks ran at ticks 0 to 99. At tick 101 (`tickCount` > 100) the test has no sequences, so it fails
  with "Didn't succeed or fail within 100 ticks". Chat (red): `mymod:door failed! Didn't succeed or fail within 100 ticks`.
- Success: a signal triggers an ACCEPT block at tick 12 -> the check at tick 12 calls `succeed()`: pass, even if a FAIL block triggers in
  the same tick.

### 10.5 Retry and the status line

`/test run mymod:door 3 false` (three tries, do not halt on failure). After the first run (passed after 52 ms): `attempts` 1, `successes` 1,
tries 3: `handleRetry(true)`: status `[Run:    1, Ok:    1, Fail:    0, Left:    2]` (45 characters, then 8 spaces up to 53) followed by
`mymod:door passed! 52ms`; green. `hasTriesLeft(1, 1)` is true (1 < 3), so the test is re-run after the rest of the batch finishes (the
copy is placed again on the same block position). With `/test run mymod:door 0 true` (unlimited tries, halt on first failure) the loop continues
while every attempt passes, and stops after the first failure (`hasTriesLeft` false once a failure exists and `haltOnFailure` is true).

### 10.6 Grid layout of several tests

`/test run mymod:* 1 false 0 2` (the selector's matching is recalled, not verified; one try, rotation steps 0, two tests per row) with three tests whose structures are 3 wide (x) and 4 deep (z), padding 0:
first corner P = (10, 64, 23). Test 1 at (10, 64, 23): bounds x size 3 (structure AABB 3 wide), so `nextCorner` = (10 + 3 + 5, 64, 23) = (18, 64, 23);
test 2 at (18, 64, 23); the row has 2 tests (`testsPerRow` 2): `rowBounds` is the union of the unit box at P and the two tests' bounds; its z size is
the depth from z = 23 (the corner box) to the far side of the structures at z = 24 + 4 = 28, so 5; `nextCorner` moves by (0, 0, 5 + 6) to
z = 34 and x returns to 10: test 3 at (10, 64, 34). (Illustrative numbers computed from the rule of §5.3; the AABB of the union includes the
unit box at the corner.)

### 10.7 Reading a position with `pos`

The player looks at the block (11, 66, 25) of the area of §10.1. `/test pos` -> the ray (reach 10) hits (11, 66, 25); the test instance block
whose structure box (10..12, 65..66, 24..27) contains it is found within radius 15; the relative position = (11,66,25) - (10,65,24) = (1, 1, 1).
Chat: "Position relative to mymod:door: 1, 1, 1" (the second argument is bold green, hover "Click to copy to clipboard"; clicking copies
`final BlockPos pos = new BlockPos(1, 1, 1);`). The player also receives packet 05a 0x29 with absolute (11, 66, 25) and relative (1, 1, 1): a green translucent box at the block and the
text "1, 1, 1" above it for 10 s. If no test area is within 250 blocks: "Can't find a test instance that contains 11, 66, 25".

---

## Open questions

1. Where `SharedConstants.IS_RUNNING_IN_IDE` is assigned (it is a plain field read by the export subcommands and by many unrelated classes);
   how the launcher decides it. The conditions of the export subcommands and the block screen's Export button (40 §8) depend on it.
2. The argument order and use of the `test.error.*` keys raised by `GameTestHelper` assertions and by `GameTestSequence` (§9.4); the
   precise semantics of every helper method (§6.5); how a `GameTestSequence` event list advances beyond the summary of §6.5. None of this is
   exercised by the shipped data (only `always_pass` exists).
3. The exact branches of the two coordinate lines (`test.player.coordinates`, `test.run.coordinates`, §5.10): the condition under which
   the second is printed per dimension was read only in outline, and which dimension the second line's command uses. The counts and texts of the summary are exact.
4. Where the START block's `powered` flag is cleared. `TestBlockEntity.reset()` clears it and `TestBlock.tick` calls `reset()`, but no code
   read schedules that tick, and the runner never resets START blocks. Re-placing the template re-creates the block from the template's
   saved NBT (31-6 §9.1 keys), which is the only other way found.
5. The AABB `clip` and the sort key used by the looked-at finder (§4.2: the comparator's key is a function of the source block position;
   "nearest" is inferred), and the exact meaning of the POI manager's `findAll` radius test (46 and 44 give the POI type; the search shape
   was not read).
6. The meaning of `ServerLevel.areEntitiesActuallyLoadedAndTicking` per chunk (§5.5 step 4); an implementation can treat it as "the chunk is
   loaded, entity-ticking and its entities are loaded".
7. The `GameRuleMap` codec shape for the `game_rules` environment (§3.5 says inferred, same as the saved `game_rules` key) and the exact
   codecs of `world_clock` and `timeline` holders (ids; 23, 04).
8. The JUnit-like report layout (headless only) beyond the element and attribute names of §5.7.
9. The rotation accumulation of §5.2 (an existing block's effective rotation is passed back in as the extra rotation) was read in the
   instructions and never executed; a test whose own `rotation` is not `none` might behave as the text says or the stored value might
   be normalised elsewhere.
10. What assigns `StructureUtils.testStructuresTargetDir` and `testStructuresSourceDir` (§3.6), the file layout that `export` writes
    below the target directory (the `TemplatePathFactory` rules, 36-2 §2), and the `.snbt` text-template reading; 31-6 Open question 9
    stays open for the same reason. `saveTest` (31-6 §10.4) is a different path: it writes through the manager's save to the world's
    `generated` directory (36-2 §2).
11. Whether a negative or zero `create` size is rejected: only the upper limit 48 is tested in the command; the behaviour for values
    below 1 follows from the box routines of 36-2 and was not traced.
12. (Closed in §3.3: the missing-function text was read.) The number is kept so the numbering of this section stays stable.
13. `GameTestInfo.fail` overwrites the stored error (inferred from a plain assignment); whether any caller guards against overwriting was
    not checked beyond `GameTestInfo`, `GameTestSequence` and `GameTestHelper.fail` (which throws).
14. (Closed for `locate`: its result is the located count, §4.3 and 57-4 §7.65.) `test export`'s result when a save fails (0 or 1 depending on the branch) is still open.
15. The wildcard rules of the selector (§3.8) belong to a library (`FilenameUtils.wildcardMatch`) that is not in the artifact; they are
    stated from recall and not verified. 15 §6.7 gives only the examples `*`, `minecraft:*` and `*:asset`.
