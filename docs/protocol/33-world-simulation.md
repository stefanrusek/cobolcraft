# World simulation: server and level tick order, clocks and time, weather, sleeping, world spawn, world border, game rules, difficulty

| Item | Value |
|---|---|
| Covers | The order in which the server and each level tick; game time, world clocks and timelines and their gameplay effects; sky darkness; the moon; standard weather (timers, levels, packets, precipitation, snow and ice, lightning and skeleton traps); sleeping and night skip; the world spawn point, the initial world spawn search, the first-join player spawn search and the respawn overview; the world border; every one of the 59 game rules with the places where its effect happens; difficulty effects that documents 17 to 21 do not already hold; the saved-data layout of this state in 26.3 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in the README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of data files with `unzip -p`, with no execution. The game-rule consumer index was built by scanning every one of the 10,737 `net/minecraft` classes of the jar for references to the `GameRules` constants. Arithmetic examples were recomputed outside the artifact with 32-bit float emulation. |
| Round | RS16 (GAP-11, GAP-21, GAP-28 of `../design/README.md` Part 5) |
| Data versus code | Timeline keyframes, world clocks, dimension types, biome climate, noise-settings `spawn_target` and the loot-table `weather_check` condition are DATA, extracted by the tool (22). This document specifies their schema, the engines that read them and the semantics of the attributes they feed. The numbers needed for worked examples are quoted, not tabulated. |

Section references use the forms "12 §3.2", "16 §4.5", "17 §4.10", "18 §6.1", "20 §3.2", "21 §8.6", "44 §1.7". "Read" means read in the artifact this round. "(inferred)" marks values deduced from what was read. The quoted class and method names say where a fact was read and are not a design.

## 0. Reader's map

| Question | Section |
|---|---|
| What runs in which order each server tick and each level tick | 1, 2 |
| Game time, day time, clocks, pausing, the Set Time packet, timelines, `skyDarken`, moon phase | 3 |
| Rain and thunder: timers, levels, packets, snow, ice, cauldrons, lightning | 4 |
| Beds, `players_sleeping_percentage`, night skip | 5 |
| World spawn, spawn search, respawn, spawn protection | 6 |
| World border | 7 |
| The 59 game rules | 8 |
| Difficulty | 9 |
| What is saved where | 10 |
| Worked examples and validation | 11, 12 |
| Open questions | 13 |

Where other documents already hold the behaviour this document points at it and does not repeat it: the `time`, `weather`, `gamerule`, `difficulty`, `setworldspawn`, `spawnpoint`, `worldborder` and `tick` commands (16 §4), weather rendering layers (12 §3.5), the day timeline keyframes (12 §3.2), natural spawning (18 §6), local difficulty (18 §7.1.3, 20 §3.2), death and respawn flow (17 §4.10), the lightning bolt entity (21 §8.6), the skeleton trap goal (19), the cat spawner and village siege (44 §1.6, 44 §1.7), patrols and phantoms (20 §14.1, 20).

## 1. Server tick order (`MinecraftServer.tickServer`, `tickChildren`)

### 1.1 `tickServer` (once per server tick)

1. **Pause when empty.** Let `P` be the dedicated-server property `pause-when-empty-seconds` times 20 (the property default is 60, so 1200 ticks; read from `DedicatedServerProperties`). When `P > 0`: if no player is connected and the tick-rate manager is not sprinting, a counter `emptyTicks` is incremented, otherwise it is reset to 0. When `emptyTicks >= P`, the tick does nothing but the network connection tick (`tickConnection`) and returns: the tick counter, the clocks, every level and game time stand still. On the first such tick (`emptyTicks == P`) an autosave runs once. A property value of 0 or below disables the pause. (The integrated server has no such property; whether it pauses was not read.)
2. `tickCount` is incremented (the server's own counter; it drives the 20-tick time sync of 1.2 and the 600-tick latency broadcast of 1.2 step 9).
3. The tick-rate manager ticks (freeze, step and sprint bookkeeping; 16 §4.9).
4. `tickChildren` runs (1.2).
5. The cached server status (player count, motd) is rebuilt when it is older than the status expiry constant (value not read).
6. The autosave countdown `ticksUntilAutosave` is decremented; at 0 or below the world is saved and the countdown is reset to `max(100, (int)(tickrate x 300))` ticks (6000 ticks, 5 minutes, at 20 ticks per second; `300.0f` and `100` read). While sprinting the tickrate used is 1,000,000,000 ns divided by (average tick time + 1 ns).

### 1.2 `tickChildren` (in this order)

| # | Step | Notes |
|---|---|---|
| 1 | For each player: suspend packet flushing (batching) | resumed in step 11 |
| 2 | Command functions tick (`ServerFunctionManager.tick`) | `tick.json` function tag and scheduled commands (16 §10.3) |
| 3 | If the tick manager `runsNormally`: `ServerClockManager.tick` | all world clocks, section 3.1 |
| 4 | If `tickCount mod 20 == 0`: broadcast Set Time (05b 0x73) with the overworld game time and an **empty** clock map | a game-time heartbeat, sent even while frozen |
| 5 | Recompute the effective world respawn data (6.5) | |
| 6 | For each level, in level-map order: `ServerLevel.tick` (section 2) | overworld first, then the other `LevelStem` registry entries in the iteration order of that registry's entry set; read: the level map is an insertion-ordered map (`Maps.newLinkedHashMap`), the overworld is inserted first and skipped in the loop over the registry entries; the registry's own entry order for the non-overworld stems (Nether, End, data-pack dimensions) was not read (inferred: load order). CobolCraft rule (design choice, not read): tick overworld, then Nether, then End; an exception here is fatal ("Exception ticking world") |
| 7 | Network connections tick | |
| 8 | `PlayerList.tick`: every time its counter exceeds 600 ticks, broadcast the latency player-info update (Player Info Update, action UPDATE_LATENCY) to all players and reset the counter | |
| 9 | Debug subscribers; game tests (only if `runsNormally`) | |
| 10 | Registered tickables (server GUI refresh) | |
| 11 | For each player: send the next chunks of its chunk sender, then resume packet flushing | chunks reach clients last, after the whole simulation of the tick |
| 12 | Activity monitor tick | |

Only the overworld has the flag `tickTime` set when the levels are created; the other levels use derived level data that delegates game time to the overworld (6.5 and 3.2). Consequently game time advances, and scheduled functions run, in the overworld level tick only.

## 2. Level tick order (`ServerLevel.tick`)

`runs` below means `TickRateManager.runsNormally`: true unless the game is frozen, and also true during a tick step or sprint (16 §4.9). A frozen game still runs the sleep check (2.1 step 3, including the night skip and weather reset), still updates `skyDarken` (2.1 step 4) and still runs the entity and block-entity phase for players and their passengers (2.1 step 11). Only the world border, the weather cycle and the time tick sit behind `runs` in the first part of the tick (the `runsNormally` result is tested once for border and weather, and again for `tickTime`).

### 2.1 Steps of one level tick

1. Mark the level as handling a tick; invalidate the per-tick environment-attribute cache (3.5).
2. **If `runs`:**
   1. World border tick (7.3).
   2. Weather cycle (`advanceWeatherCycle`, section 4.2), including the rain and thunder packets.
3. **Sleep check, unconditionally** (it runs on every level tick, also while the game is frozen; the branch of step 2 jumps over to it). Let `pct` be the rule `players_sleeping_percentage`. If the sleep status says enough players are sleeping for `pct` **and** enough players are sleeping deeply (5.4): (a) if the rule `advance_time` is true and the dimension type has a default clock, move that clock to the time marker `wake_up_from_sleep` (3.3); (b) wake every player in this level (5.5); (c) if `advance_weather` is true and `ServerLevel.isRaining()` is true, reset the weather cycle (4.6).
4. Recompute `skyDarken` (3.5). This runs every tick, also while frozen.
5. If `runs`: **time tick** (`tickTime`): only when the level's `tickTime` flag is set (overworld): game time is incremented by 1 and then the scheduled-function timer queue is run for the new game time.
6. If the level is not a debug world and `runs`: tick the scheduled **block ticks** and then the scheduled **fluid ticks** that are due at the current game time (at most 65,536 per queue per call; the constant 65536 was read).
7. If `runs`: raids tick (`Raids.tick`: raids are in 20 and 44; with the rule `raids` false every raid is stopped, 8.2).
8. **Chunk source tick** (`ServerChunkCache.tick`, 2.2).
9. If `runs`: run the queued block events (pistons, note blocks and similar), then clear the "handling tick" flag.
10. **Empty-level counter**: if the chunk source has active tickets the counter `emptyTime` is reset to 0; if `runs`, `emptyTime` is incremented by 1.
11. **Entities and block entities** run only while `emptyTime < 300`:
    1. if the level has a dragon fight and `runs`: the fight ticks;
    2. every entity in the entity tick list ticks (2.3);
    3. block entities tick.
12. Entity manager tick (sections of entities are loaded, unloaded and saved), debug synchronizers, random-state garbage collection.

A level with no tickets for 300 consecutive ticks therefore stops simulating its entities and block entities, but keeps ticking its weather, time, border and scheduled ticks.

### 2.2 `ServerChunkCache.tick` and the chunk loops

1. Ticket bookkeeping (stale tickets are purged only when `runs`), distance-manager updates.
2. Unless the level is a debug world: **if `runs`**, run `tickChunks` (below); the changed blocks of each chunk holder are broadcast to its players in every case.
3. Chunk map tick and the unload step.

`tickChunks` does, in order:

1. Count the natural-spawn chunks and build the spawn state (18 §6.1 step 1); read the rules `spawn_mobs` and `random_tick_speed`.
2. If `spawn_mobs` is true, compute the category list for this tick (the friendly cycle runs when `gameTime mod 400 == 0`; 18 §6.1 step 2); otherwise the list is empty.
3. Collect the spawn-candidate chunks (those within the player distance tracker that have a ticking holder and a nearby player; 18 §6.2) and **shuffle** them with the level's random source.
4. For each such chunk in that order (`tickSpawningChunk`): (a) increment the chunk's inhabited time by 1 (a long counter that feeds local difficulty, 18 §7.1.3); (b) if the chunk is in the entity-ticking range: **thunder** (`tickThunder`, 4.4); (c) if the category list is empty, stop for this chunk; (d) if the chunk is inside the world border and entities may tick there: `NaturalSpawner.spawnForChunk` (18 §6.5).
5. For each chunk of the **entity-ticking set** (the chunks that tick blocks; `forEachBlockTickingChunk` iterates the distance manager's entity-ticking chunks): `ServerLevel.tickChunk(chunk, random_tick_speed)` (2.4). The iteration order is the order of that set (not specified further; Open question 1).
6. If `spawn_mobs` is true: tick the level's **custom spawners** with the "spawn enemies" flag (the level flag that the server sets to `spawn_mobs and spawn_monsters`, 8.5). Only the overworld has any, in this order: phantom spawner, patrol spawner, cat spawner, village siege, wandering trader spawner (`MinecraftServer.createLevels` read: a five-element list for the overworld, an empty list for every other level).

### 2.3 What ticks an entity (the lambda over the entity tick list)

For each entity: skip it if it was removed; skip it if the game is not running normally and it is neither a player nor carries a player passenger (`isEntityFrozen`); run `checkDespawn`; then skip it unless it is a player or its chunk is in the entity-ticking range; if it has a vehicle that is removed or no longer lists it as a passenger, stop riding (and skip this tick when the vehicle is valid and ticks it); otherwise `tickNonPassenger` (common tick, entity tick, then each passenger). Per-mob order inside the tick is 18 §2.

### 2.4 `ServerLevel.tickChunk(chunk, speed)` (random ticks, ice and snow)

Let `(cx, cz)` be the chunk's minimum block coordinates.

1. **Ice and snow.** Repeat `speed` times: draw `nextInt(48)` from the level random; if it is 0, take a random position `p = randomBlockPos(cx, 0, cz, 15)` and run `tickPrecipitation(p)` (4.4); only the x and z of `p` matter because the function re-projects to the height map.
2. **Random block and fluid ticks.** If `speed > 0`, for each chunk section in index order (bottom to top) that contains random-ticking blocks or fluids (a per-section flag), repeat `speed` times: take `p = randomBlockPos(cx, sectionMinY, cz, 15)`; read the block state at `p`; if that state is random-ticking, call its random tick with the level random; then read the fluid state at `p` and, if it is random-ticking, call the fluid's random tick.

**`randomBlockPos(x0, y0, z0, mask)`** uses a per-level integer `randValue` that is **not** the level random: it is initialised to a random integer when the level object is created (not seeded, so not reproducible), and each call does `randValue = randValue x 3 + 1013904223` (32-bit wrapping) and then `i = randValue >> 2` (arithmetic shift). The result is `(x0 + (i & 15), y0 + ((i >> 16) & mask), z0 + ((i >> 8) & 15))`. With `randValue = 0` before the call: `randValue` becomes 1013904223, `i = 253476055`, offsets x 7, y 11, z 12.

The rule `random_tick_speed` (default 3) is therefore "random positions per section per tick" and, for ice and snow, "attempts per chunk per tick, each with probability 1/48".

## 3. Game time, clocks and timelines

### 3.1 Two different counters

| Counter | Where | Advances | Used for |
|---|---|---|---|
| **Game time** (`Time` in `level.dat`) | `ServerLevelData.gameTime`, one value for the server (overworld data; derived levels read it) | +1 in the overworld level tick when `runs` (2.1 step 5). Not affected by `advance_time`, clock pause or clock rate | scheduled block and fluid ticks, scheduled functions, `time query gametime`, the `gameTime mod 400` friendly-spawn cycle, the Set Time `game time` field |
| **World clock total ticks** | `ServerClockManager`, one `ServerClockInstance` per registry entry of `world_clock` (26.3 ships `minecraft:overworld` and `minecraft:the_end`, both empty JSON objects) | by the clock rate each server tick, subject to 3.2 | timelines (3.4), time markers, sleeping, `time set/add/query` (16 §4.5), local difficulty (9.3) |

There is **no** separate "day time" counter any more: what older worlds called day time is the overworld clock's total ticks. Both start at 0 in a new world (all clocks are created with total 0, partial tick 0, rate 1.0, not paused; no initial time is set except by the debug-world setup, which moves the overworld clock to the marker `noon`).

### 3.2 Clock instance and the per-tick advance

Each instance holds `totalTicks` (long), `partialTick` (float), `rate` (float, default 1.0) and `paused` (boolean).

`ServerClockManager.tick` (1.2 step 3, only when the game `runs`):

1. Read the rule `advance_time` **of the overworld's rules** (`getGlobalGameRules`; the rule set is one object per server, 8.1).
2. If it is true, for every clock that is not paused: `partialTick += rate`; let `n = floor(partialTick)`; `partialTick -= n`; `totalTicks += n`. (So a rate of 0.5 adds one tick every second server tick; a rate of 2 adds two per tick; `rate` is 0.00001 to 1000 by the command.) The manager is marked dirty (saved).
3. If it is false nothing advances.

All writes that go through the manager (`setTotalTicks`, `addTicks`, `moveToTimeMarker`, `setPaused`, `setRate`) do these things afterwards: build the network state of that clock, broadcast **one** Set Time packet (game time plus the one changed clock) to **all** players, mark dirty, and invalidate the attribute tick cache of every level. `setTotalTicks` also resets `partialTick` to 0; `addTicks` adds an int and clamps the total at 0 from below (a negative `time add` cannot go below tick 0); `moveToTimeMarker` sets the total to the marker's resolved tick and the partial tick to 0 (3.3).

### 3.3 Time markers

A time marker is `(clock, ticks, optional period_ticks, show_in_commands)`, registered per clock from the timelines (the marker ids and values of the vanilla `day` timeline are in 16 §4.5). Two operations:

* `occursAt(total)`: with no period, `ticks == total`; with period `P`, `ticks == total mod P`.
* `resolveTimeToMoveTo(total)`: with no period, the marker's tick; with period `P`, `c = total mod P`, `d = ticks - c` and the result is `total + d` if `d > 0` otherwise `total + P + d` (always strictly in the future).

`moveToTimeMarker` returns NO_TIME_MARKER_FOUND when the clock has no such marker, NOT_MOVED when `occursAt(total)` already holds, otherwise it moves. The built-in marker keys read in `ClockTimeMarkers`: `day`, `noon`, `night`, `midnight`, `wake_up_from_sleep`, `roll_village_siege`. Code that moves or reads markers: the `time` command (16 §4.5), the sleep skip (2.1 step 3, marker `wake_up_from_sleep`, which `data/minecraft/timeline/day.json` defines as tick 0 (the same file defines `day` 1000, `noon` 6000, `night` 13000, `midnight` 18000 and `roll_village_siege` 18000); `day.json` also gives `clock` `minecraft:overworld` and `period_ticks` 24000, read this round), `VillageSiege.tick` (marker `roll_village_siege`, 44 §1.7) and the debug world (`noon`).

Night skip example: clock total 15000, marker tick 0, period 24000: `c = 15000`, `d = -15000`, the new total is `15000 + 24000 - 15000 = 24000`.

### 3.4 Timelines and environment attributes on the server

A **timeline** (`data/minecraft/timeline/*.json`, registry `timeline`) names a clock, an optional `period_ticks`, optional `time_markers` and a map `attribute id -> track`. A **track** is a list of keyframes `(ticks, value)` plus an optional `ease` and a `modifier` (default `override`). `getCurrentTicks` is `total` with no period or `total mod period`; `getPeriodCount` is 0 with no period or `floor(total / period)`.

The **attribute system** of a level composes, per attribute, layers over the attribute's default: dimension-type attributes, biome attributes (positional; blended), then each timeline listed by the dimension type's `timelines` (a tag), then, only when the level can have weather, the weather layers (3.6). The timeline layer (`AttributeTrackSampler`) samples its track at the **integer** `totalTicks` of the timeline's clock (the partial tick is not used on the server; the sample is cached for the current tick and recomputed after any clock write or tick), and applies the track modifier to the running value. Interpolation between keyframes, the cyclic wrap at the period and easing are described in 12 §3.2; the extra facts read here are the interpolation rules of non-numeric types:

| Attribute type | Between two keyframes (`keyframeLerp`) | Weather layer switch (`stateChangeLerp`) |
|---|---|---|
| float, integer, angle, colours | linear (angles use their own degree lerp) | the layer value is lerped in by the weather level `w` |
| boolean, enum (moon phase, activity), bed rule and the other non-interpolated types | step: the value of the **earlier** keyframe is held until the progress reaches 1.0, i.e. the value changes exactly at the next keyframe tick | step with threshold 0.0: as soon as `w > 0` the layer's modified value replaces the running value |

The vanilla timelines (data): `day` (clock overworld, period 24000), `moon` (period 192000), `early_game` (no period), `villager_schedule` (period 24000). The dimension types name timeline tags: the overworld `in_overworld` (`universal`, `day`, `moon`, `early_game`), the Nether `in_nether` and the End `in_end` (both only `universal`, which holds `villager_schedule`). Note that the End and Nether still tick the `villager_schedule` timeline against the **overworld** clock.

The gameplay attributes that timelines or dimension types feed, and the code that reads them (the keyframes are data, 12 §3.2 for the `day` ones):

| Attribute (`minecraft:gameplay/...`) | Type | Read by |
|---|---|---|
| `sky_light_level` | float 0..15, default 15 | `Level.updateSkyBrightness` (3.5) |
| `monsters_burn` | boolean | `Mob.isSunBurnTick` (18 §2.6) |
| `bees_stay_in_hive` | boolean | `Bee.wantsToEnterHive`, `BeehiveBlockEntity.releaseOccupant` |
| `creaking_active` | boolean | `CreakingHeartBlock`, `CreakingHeartBlockEntity` |
| `cat_waking_up_gift_chance` | float | `Cat$CatRelaxOnOwnerGoal.stop` (19) |
| `turtle_egg_hatch_chance` | float | `TurtleEggBlock.shouldUpdateHatchLevel` |
| `surface_slime_spawn_chance` | float | `Slime.checkSlimeSpawnRules` (21) |
| `can_pillager_patrol_spawn` | boolean (`early_game`: false for the first 120000 ticks, modifier `and`) | `PatrolSpawner.tick` (20 §14.1) |
| `villager_activity`, `baby_villager_activity` | activity | the villager brain schedule (19 §22) |
| `eyeblossom_open` | boolean | `EyeblossomBlock.tryChangingState`, `FlowerPotBlock.randomTick` |
| `can_start_raid` | boolean (Nether: false) | `Raids.createOrExtendRaid` (raids are never created where false) |
| `bed_rule`, `straw_bed_rule` | bed rule | sleeping (5.1) |
| `visual/moon_phase` | enum | `ServerLevel.getMoonBrightness`, the moon variant check (3.7) |
| `respawn_anchor_works` | boolean | `RespawnAnchorBlock.canSetSpawn` (17 §4.10) |
| `nether_portal_spawns_piglin`, `piglins_zombify`, `fast_lava`, `snow_golem_melts`, `water_evaporates`, `increased_fire_burnout` | boolean | other rounds (portals, fluids, fire) |

### 3.5 Sky darkness (`skyDarken`) and bright/dark outside

Each tick (2.1 step 4) the level computes `skyDarken = (int)(15.0f - L)` where `L` is the dimension-wide value of `gameplay/sky_light_level` (layers: default 15; dimension attributes; timelines; weather layers; the attribute range is 0..15). The integer cast truncates.

| Predicate | Definition |
|---|---|
| `isBrightOutside` | the dimension type has **no** fixed time and `skyDarken < 4` |
| `isDarkOutside` | the dimension type has no fixed time and not `isBrightOutside` |
| effective sky brightness at a position | `max(0, skyLight(pos) - skyDarken)` (`LevelReader.getEffectiveSkyBrightness`) |
| max local raw brightness at a position (spawn light checks, 18 §6.8) | the raw brightness with `skyDarken` subtracted from the sky component |

`skyDarken` is also read by `PhantomSpawner.tick` (20). Dimension types with fixed time (Nether, End: `has_fixed_time` true in the dimension data) are never bright and never dark by these predicates.

With the vanilla overworld data (the `day` track multiplies from 1.0 at tick 11867 to `0.26666668` at tick 13670 and back from tick 22330 to 133 of the next day; arithmetic done with 32-bit floats and `Mth.lerp(t, a, b) = a + t x (b - a)`, read):

* day: `L = 15`, `skyDarken = 0`;
* night plateau: `15 x 0.26666668` is `4.0` in float, so `L = 4`, `skyDarken = 11`;
* `skyDarken` first reaches 4 at clock tick **12523** (dusk) and drops below 4 again at tick **23478** (dawn) (inferred by the emulation; these two ticks are the sleeping window of 5.2 in clear weather);
* weather layers (3.6) lower `L` by day: full rain gives `L = 11.5625`, `skyDarken = 3` (still "bright"); full thunder gives `L = 9.19921875`, `skyDarken = 5` ("dark").

### 3.6 Weather layers on attributes

When the level can have weather (4.1) a layer is added for every attribute in the fixed weather set. For each such attribute, with `t` the thunder level and `r' = rainLevel - thunderLevel` (both 0..1, 4.2): if the rain map has an entry for the attribute and `r' > 0`, the running value becomes `lerp(r', value, rainModifier(value))` (using the type's state-change lerp, 3.4); then if the thunder map has an entry and `t > 0`, the running value becomes `lerp(t, value, thunderModifier(value))`. For `sky_light_level` the rain modifier is an alpha blend towards `4.0` with alpha `0.3125`, the thunder modifier an alpha blend towards `4.0` with alpha `0.52734375` (read in `WeatherAttributes`; the other attributes in the weather set are visual and are in 12 §3.5).

### 3.7 Moon phase

The attribute `visual/moon_phase` comes from the `moon` timeline (period 192000, one keyframe every 24000 ticks, an enum so the value is held from keyframe to keyframe). Phase index and brightness (`DimensionType.MOON_BRIGHTNESS_PER_PHASE`, read as eight floats):

| Index | Phase | Brightness | Clock ticks of the 192000 cycle (data) |
|---|---|---|---|
| 0 | `full_moon` | 1.0 | 0 .. 23999 |
| 1 | `waning_gibbous` | 0.75 | 24000 .. 47999 |
| 2 | `third_quarter` | 0.5 | 48000 .. |
| 3 | `waning_crescent` | 0.25 | 72000 .. |
| 4 | `new_moon` | 0.0 | 96000 .. |
| 5 | `waxing_crescent` | 0.25 | 120000 .. |
| 6 | `first_quarter` | 0.5 | 144000 .. |
| 7 | `waxing_gibbous` | 0.75 | 168000 .. 191999 |

`ServerLevel.getMoonBrightness(pos)` returns the table value for the moon-phase attribute at the position. Local difficulty uses it as `M` (18 §7.1.3). The `surface_slime_spawn_chance` track of the same timeline falls from 0.5 at full moon in steps of 0.125 per phase to 0.0 at new moon (data).

### 3.8 Set Time contents and when it is sent

Set Time (05b 0x73): `game time` (Long) = the **overworld** game time, then the clock map `world_clock id -> (total ticks VarLong, partial tick Float, rate Float)`. The `rate` on the wire is **0.0 when the clock is paused or the rule `advance_time` is false**, otherwise the clock's rate; so a client keeps clocks stopped without any other message. Sent: (a) to a joining player as the full map (`sendLevelInfo`, 6.4); (b) to everybody with the one changed clock on every manager write (3.2); (c) to everybody as the full map when `advance_time` is changed by `gamerule`; (d) to everybody with an empty map every 20 server ticks (1.2 step 4).

## 4. Weather

### 4.1 State

There is **one** `WeatherData` for the whole server (not one per dimension), loaded at startup and shared by every level (`MinecraftServer.getWeatherData`). Fields: `clearWeatherTime`, `rainTime`, `thunderTime` (ints, ticks), `raining`, `thundering` (booleans). Each level additionally keeps four floats: `rainLevel`, `oRainLevel`, `thunderLevel`, `oThunderLevel` (0..1; `o` = the value before this tick).

A level **can have weather** when its dimension type has sky light, has no ceiling and the level is not `minecraft:the_end` (`Level.canHaveWeather`). With the vanilla dimension types only the overworld qualifies. Every weather-capable level runs the cycle of 4.2 and so would advance the shared timers once per tick each (matters only for custom dimension types; Open question 5).

When a level object is created and can have weather, its `rainLevel` is set to 1 if `WeatherData.raining` and its `thunderLevel` to 1 if `thundering` too, so a saved storm resumes at full strength without a fade.

Derived values: `getRainLevel(f) = lerp(f, oRainLevel, rainLevel)`; `getThunderLevel(f) = lerp(f, oThunderLevel, thunderLevel) x getRainLevel(f)`. On the server the game logic uses `f = 1`, i.e. the current values. **`isRaining()` is `canHaveWeather and rainLevel > 0.2`; `isThundering()` is `canHaveWeather and thunderLevel x rainLevel > 0.9`** (double comparisons, thresholds 0.2 and 0.9 read).

### 4.2 The weather cycle (`advanceWeatherCycle`, once per level tick when the game runs)

Let `wasRaining = isRaining()` at the start. If the level can have weather:

**A. If the rule `advance_weather` is true** (otherwise skip to B), take local copies `clear`, `thunderT`, `rainT`, `thunder`, `rain` from `WeatherData`:

1. If `clear > 0`: `clear -= 1`; `thunderT = 0` if `thunder` was true else 1; `rainT = 0` if `rain` was true else 1; `thunder = false`; `rain = false`.
2. Otherwise, thunder part: if `thunderT > 0`: `thunderT -= 1` and when it reaches 0 the flag toggles (`thunder = not thunder`) and nothing is sampled in this tick; otherwise (`thunderT` was already 0 or below at the start of this tick; no decrement and no toggle happen in this tick): when `thunder` is true set `thunderT = sample(THUNDER_DURATION)`, else `thunderT = sample(THUNDER_DELAY)`.
3. Rain part (in the same branch as 2): if `rainT > 0`: `rainT -= 1` and at 0 the flag toggles; otherwise (`rainT` was already 0 or below at the start of this tick; no toggle in this tick): when `rain` is true `rainT = sample(RAIN_DURATION)`, else `rainT = sample(RAIN_DELAY)`.
4. Write all five values back to `WeatherData` (each setter marks it dirty).

The four distributions are uniform integers, both bounds inclusive (`UniformInt.sample` is `randomBetweenInclusive`), drawn from the **level random** in the order thunder before rain:

| Name | Range (ticks) | Minutes at 20 ticks per second |
|---|---|---|
| `RAIN_DELAY` | 12000 .. 180000 | 10 .. 150 |
| `RAIN_DURATION` | 12000 .. 24000 | 10 .. 20 |
| `THUNDER_DELAY` | 12000 .. 180000 | 10 .. 150 |
| `THUNDER_DURATION` | 3600 .. 15600 | 3 .. 13 |

Consequences, derived from the steps above (inferred): rain and thunder have **independent** timers and flags, so `thundering` can be true while `raining` is false (no visible thunder then, since the thunder level is multiplied by the rain level). When the clear-weather time expires, step 1 has left `thunderT = rainT = 1` (for flags that were off), so on the next tick both counters reach 0 and **both flags toggle on**: a storm begins right after a `weather clear` countdown (with the command default of 12000 to 180000 ticks of clear time this is the natural end of clear weather).

**B. Level smoothing** (always, also with `advance_weather` false): `oThunderLevel = thunderLevel`; then `thunderLevel += 0.01f` if `WeatherData.thundering` else `thunderLevel -= 0.01f`; clamp to 0..1. Then the same for rain with `WeatherData.raining`. A full fade therefore takes 100 ticks (5 seconds); `isRaining()` flips when `rainLevel` crosses 0.2 (float arithmetic: after 20 additions of `0.01f` the float is 0.20000002 which is above 0.2d, so the flip happens on the 20th tick, and when fading out the level first drops to or below 0.2 on the 81st tick from 1.0).

**C. Packets** (the level's weather-capable test applies to A and B, not to C):

1. If `oRainLevel != rainLevel`: send Game Event 7 (RAIN_LEVEL_CHANGE, value = `rainLevel`) to the players **of this dimension**. If `oThunderLevel != thunderLevel`: Game Event 8 (THUNDER_LEVEL_CHANGE, value = `thunderLevel`), same audience.
2. If `isRaining()` differs from `wasRaining`: send Game Event 2 (STOP_RAINING, value 0) if it was raining else Game Event 1 (START_RAINING, 0) to **all** players, followed by Game Event 7 and Game Event 8 with the current levels to **all** players.

(Event ids and the packet: 05a 0x27.) A joining player or a player entering a level receives, in `sendLevelInfo` (6.4 order), if `isRaining()` is true: Game Event 1, Game Event 7 with `getRainLevel(1)` and Game Event 8 with `getThunderLevel(1)`; nothing otherwise.

### 4.3 Setting the weather from outside

`MinecraftServer.setWeatherParameters(clearTime, rainTime, raining, thundering)` writes `clearWeatherTime`, `rainTime`, **`thunderTime = rainTime`**, `raining`, `thundering` (16 §4.10 has the three command forms and their default durations). The new flags take effect on the level through B above (a fade, not a jump); the sky changes over 5 seconds.

### 4.4 Per-chunk weather effects

**`tickPrecipitation(p)`** (2.4 step 1; `p` is a column; only x and z matter). Let `top` be the position of the `MOTION_BLOCKING` height map at the column (06 heightmap table: the first free block above the highest motion-blocking block, fluids included) and `below = top - 1`, `biome` the biome at `top`.

1. **Freeze (does not need rain).** If `biome.shouldFreeze(level, below)` the block at `below` becomes ice (`minecraft:ice` default state, with block update). `shouldFreeze(pos)` is false when the biome is warm enough for rain at `pos` (4.5); otherwise true when `pos` is inside the build height, the **block light** at `pos` is below 10, the fluid at `pos` is source water in a liquid block, and **not all four horizontal neighbours are water** (a source block that has at least one non-water side).
2. If `isRaining()`:
   1. `h` = the rule `max_snow_accumulation_height` (default 1, range 0..8 per 16 §13: by default a single snow layer, never stacked). If `h > 0` and `biome.shouldSnow(level, top)`: if the block at `top` is a snow layer block with `layers < min(h, 8)`, increase `layers` by 1 (entities standing in the way are pushed up first); any other block at `top` (air) becomes one snow layer. `shouldSnow(pos)` requires: the precipitation type at `pos` is SNOW (4.5), `pos` is inside the build height, block light at `pos` below 10, the block at `pos` is air or snow, and the snow block's default state `canSurvive` at `pos`.
   2. `p` = `biome.getPrecipitationAt(below, seaLevel)`. If it is not NONE, call `handlePrecipitation(state, level, below, p)` on the block at `below`.
   (Implemented overrides in this artifact: the empty cauldron: with `p` RAIN and `nextFloat() < 0.05` it becomes a water cauldron (level 1), with `p` SNOW and `nextFloat() < 0.1` a powder-snow cauldron; the layered cauldron of the same fluid kind below level 3 gets one level more, using the same two probabilities; constants `RAIN_FILL_CHANCE` 0.05 and `POWDER_SNOW_FILL_CHANCE` 0.1 read.)

**`tickThunder(chunk)`** (2.2 step 4b; the chunk is in the entity-ticking range and in the shuffled spawn-candidate list). Let `(cx, cz)` be the chunk's minimum block coordinates.

1. Proceed only if `isRaining()` and `isThundering()` and `random.nextInt(100000) == 0` (the level random; the `nextInt` is evaluated only when the first two hold). Expected frequency: one strike per 100,000 chunk-ticks per candidate chunk.
2. `pos = randomBlockPos(cx, 0, cz, 15)` (2.4 formula; this advances `randValue`, not the level random). `target = findLightningTargetAround(pos)`:
   1. `col` = the `MOTION_BLOCKING` height-map position of the column of `pos`.
   2. **Lightning rod:** query the point-of-interest manager for the closest POI of type `lightning_rod` within **128 blocks** of `col` (occupancy ANY) whose y equals `WORLD_SURFACE height - 1` at its column (i.e. the rod is the top block there). If one exists, `target` is that rod's position plus 1 in y.
   3. **Otherwise** collect living entities that are alive and can see the sky (`canSeeSky` at their block position) inside the box from `col` up to `maxY + 1` at the same x and z, inflated by **3.0** in each direction; if any, choose one uniformly (`nextInt(count)` on the level random) and `target` is its block position.
   4. **Otherwise** `target = col`, except that when `col.y == minY - 1` (an empty column) `target = col + 2` in y.
3. Require `isRainingAt(target)`: `precipitationAt(target) == RAIN`, which needs `isRaining()`, `canSeeSky(target)` (**the sky light level at `target` equals 15**, so the lighting engine, GAP-24, decides), the `MOTION_BLOCKING` height at the column not above `target.y`, and the biome's precipitation at `target` (4.5) to be RAIN (not SNOW, not NONE).
4. Compute the local difficulty at `target` (18 §7.1.3; uses the chunk's inhabited time and the moon) and let `e` be its effective difficulty.
5. **Skeleton trap:** `trap` is true when the rule `spawn_mobs` is true **and** `random.nextDouble() < e x 0.01` **and** the block under `target` is not in the block tag `lightning_rods` (the `nextDouble` is drawn only when `spawn_mobs` is true).
6. If `trap`: create a `skeleton_horse` (spawn reason EVENT), set its trap flag, age 0, position `(target.x, target.y, target.z)` (the integer coordinates used as doubles, i.e. the block's minimum corner) and add it to the level. Its trap behaviour (spawning skeletons on approach) is 19.
7. Create a `lightning_bolt` (spawn reason EVENT) at the **bottom centre** of `target`, with `visualOnly = trap`, and add it. The entity's life cycle, fire, damage and effects are 21 §8.6 and 17 §4.11; on Normal or Hard it also starts fires (`spawnFire`, gated by the rule `fire_spread_radius_around_player`, 8).

Ordering inside one chunk tick (2.2): the level random is used by the shuffle, `nextInt(100000)` and (maybe) entity choice and `nextDouble`; `randomBlockPos` uses only `randValue`.

### 4.5 Biome precipitation and temperature at a position

* `Biome.hasPrecipitation` is a per-biome climate-settings flag (data). `getPrecipitationAt(pos, seaLevel)`: NONE if the biome has no precipitation; SNOW if `coldEnoughToSnow`; otherwise RAIN.
* `warmEnoughToRain(pos, sea)` is `temperature(pos, sea) >= 0.15f`; `coldEnoughToSnow` is its negation. (So `shouldFreeze` and `shouldSnow` use the same 0.15 threshold.)
* `temperature(pos, sea)`: let `T0` be the biome base temperature after its temperature modifier (`frozen` modifier biomes use the noises described in 10 §10, iceberg melt paragraph and item 8). For `pos.y <= sea + 17`, the result is `T0`. For `pos.y > sea + 17`: `T0 - (N x 8 + y - (sea + 17)) x 0.05f / 40.0f`, where `N = TEMPERATURE_NOISE(x / 8, z / 8)`, a fixed-seed simplex noise (`SimplexNoise(WorldgenRandom(LegacyRandomSource(1234)), true)`, 10 Open-question item 8) read at the two coordinates divided by 8. (The result is cached per position in a 1024-entry per-thread cache, a linked map that removes its first (oldest-inserted) entry when the size reaches 1024 and does not reorder on `get`, so eviction is insertion-order, not least-recently-used; that is an optimisation only and does not change values.)
* Example: a biome with base temperature 0.25 and `N = 0` at sea level 63: at `y = 160` the term is `(0 + 160 - 80) x 0.05 / 40 = 0.1`, the temperature is exactly 0.15, so it is still "warm enough" (rain); at `y = 161` it is below 0.15 and precipitation there is SNOW.

### 4.6 Sleeping and weather

When a night skip happens (2.1 step 3) and the rule `advance_weather` is true and `ServerLevel.isRaining()` is true, the cycle is reset: `rainTime = 0`, `raining = false`, `thunderTime = 0`, `thundering = false` (the clear time is left alone). The levels then fade out over about 80 to 100 ticks (B of 4.2 keeps running). With both times 0 and both flags false, the next cycle only draws fresh `THUNDER_DELAY` and `RAIN_DELAY` values, so a new storm is at least 12000 ticks away.

### 4.7 Where weather is consumed outside this section (index, read)

`Level.isRaining` / `isRainingAt` / `isThundering` / `precipitationAt`: `Entity.isInRain` (rain wets and extinguishes: `Entity.baseTick` family, 18 §2.5), `FarmlandBlock.randomTick` (moisture), `FireBlock` (`isNearRain`, `checkBurnOut`, `tick`: rain extinguishes and slows fire), `LeavesBlock` (drip particles), `FishingHook.catchingFish` (rain bonus), `Bee` pollination goals (no pollination in rain), `Fox` and `Panda` (shelter and scared), `Monster.isDarkEnoughToSpawn` (thunder lowers the light threshold, 18 §6.8), `LightningRodBlock.animateTick`, `HappyGhast.continuousHeal`, and the loot predicate `weather_check` (the engine of the data-pack condition, GAP-4). Their own rules belong to their rounds.

## 5. Sleeping

### 5.1 The bed rule

The attribute `gameplay/bed_rule` (and `straw_bed_rule` for the second bed family) holds a **bed rule** with fields `can_sleep` and `can_set_spawn` (each `always`, `when_dark` or `never`), `destroy_on_use` (default false), `destroy_on_leave` (default false) and an optional `error_message` text. Rule test: `always` is true; `never` is false; `when_dark` is `Level.isDarkOutside()` (3.5). Three presets exist in code (`BedRule`): CAN_SLEEP_WHEN_DARK (sleep when dark, set spawn always, error "block.minecraft.bed.no_sleep"), DESTROY_ON_USE (sleep never, spawn never, destroyOnUse) and DESTROY_ON_LEAVE (sleep when dark, spawn never, destroyOnLeave, same error). The vanilla dimension types (data) use: overworld `bed_rule` = sleep when dark, set spawn always; overworld `straw_bed_rule` = sleep when dark, set spawn never, destroy on leave; Nether and End: sleep never, spawn never, destroy on use (both attributes). Texts (en_us): `block.minecraft.bed.no_sleep` "You can sleep only at night or during thunderstorms"; `.too_far_away` "You may not rest now; the bed is too far away"; `.obstructed` "This bed is obstructed"; `.not_safe` "You may not rest now; there are monsters nearby"; `.occupied` "This bed is occupied"; `block.minecraft.set_spawn` "Respawn point set".

### 5.2 Using a bed (server side, in order)

`AbstractBedBlock.useWithoutItem`: (1) on the client the use returns success and does nothing else; (2) if the clicked half is not the head, the position moves to the head (one block along the bed's facing); if the block there is not the same bed with the head part, the use is consumed with no effect; (3) read the bed rule at the head: if `destroy_on_use`, send the rule's error message (if any) and run the block's destroy-on-use (the explosion of nether and end beds) and stop; (4) if the bed's `occupied` property is set: try to kick a villager out of it, and when none was sleeping there send the overlay text `.occupied`; stop; (5) `startSleepInBed`; a failure sends its message (if it has one) as an overlay line.

`ServerPlayer.startSleepInBed(bed, state, rule, pos)`, in order:

1. If the player is already sleeping or is dead: OTHER_PROBLEM (no message).
2. `canSleep = rule.canSleep(level)`, `canSetSpawn = rule.canSetSpawn(level)`.
3. **Range:** the player's `x`, `y`, `z` must satisfy `|x - (bx + 0.5)| <= 3.0`, `|y - by| <= 2.0`, `|z - (bz + 0.5)| <= 3.0` for the clicked bed position **or** for the other half of the bed (`pos - facing`); otherwise TOO_FAR_AWAY.
4. **Obstruction:** the block above the head and the block above the position opposite the facing must both be free (no collision); otherwise OBSTRUCTED.
5. If `canSetSpawn`: set the player's respawn config to `(this dimension, bed pos, player yaw, player pitch, forced = false)` and, when it differs from the old one, send the system message "Respawn point set". **This happens before the sleep test**, so using a bed in daylight sets the spawn but does not put you to sleep.
6. If not `canSleep`: fail with the rule's error message (the text of `no_sleep` when the rule has one).
7. If the player is not in creative mode: look for monsters in the box centred on the bed's bottom centre, `+-8` in x and z and `+-5` in y, for which `Monster.isPreventingPlayerRest(level, player)` is true (per-mob rules 20); any one gives NOT_SAFE.
8. `Player.startSleepInBed`: `startSleeping(pos)` (pose, bed position, the `time_since_rest` statistic is reset to 0 and the player is teleported to its own position to settle it); a failure is OTHER_PROBLEM; then `sleepCounter = 0`.
9. On success: award the bed's "slept in" stat (`sleep_in_bed` for beds) and, if `canSetSpawn`, trigger the advancement trigger `slept_in_bed`.
10. If the rule `players_sleeping_percentage` is above 100: send the overlay line `sleep.not_possible` "No amount of rest can pass this night" to the player.
11. `updateSleepingPlayerList` (5.4).

### 5.3 The sleep counter and waking

Each player tick: while sleeping, `sleepCounter` is incremented and capped at **100**; on the server, if the player's block is a bed whose rule no longer allows sleeping (`canSleep` false, e.g. morning came), the player wakes (`stopSleepInBed(false, true)`). While not sleeping and `sleepCounter > 0`, the counter keeps counting up and resets to 0 when it reaches **110** (this tail drives the client wake-up overlay, `Player.getSleepTimer`). `isSleepingLongEnough` is "sleeping and `sleepCounter >= 100`" (100 ticks = 5 seconds in bed).

`stopSleepInBed(wakeImmediately, updateLevel)`: broadcasts Animate (action 0, wake up) to the trackers and the player, clears the pose, sets `sleepCounter` to 0 if `wakeImmediately` else to 100, and when `updateLevel` is true calls `ServerLevel.updateSleepingPlayerList`. Callers: disconnect (`true`, `false`), teleport (`true`, `true`), loading player data of a sleeping player, the night skip (5.5, `false`, `false`) and the generic `stopSleeping` (`true`, `true`).

### 5.4 Sleep status and the percentage rule

`SleepStatus` keeps two counters, `activePlayers` and `sleepingPlayers`. `update(players)` recounts: `activePlayers` = players that are not spectators; `sleepingPlayers` = those of them that are sleeping; it returns "changed" when either number differs from before **and** (the old or the new sleeping count is above 0). **The recount is called only from `startSleepInBed` and from `stopSleepInBed` with `updateLevel`** (`ServerLevel.updateSleepingPlayerList`, which does nothing if the level has no players); a player joining, leaving or changing game mode does not refresh it (inferred from the two call sites that were found).

With `pct` = the rule (integer, default 100, 0 to 2147483647):

| Quantity | Definition |
|---|---|
| `sleepersNeeded(pct)` | `max(1, ceil(activePlayers x pct / 100.0f))`: the product `activePlayers x pct` is a 32-bit **int** product (it can overflow for huge `pct`), then a float division |
| `areEnoughSleeping(pct)` | `sleepingPlayers >= sleepersNeeded(pct)` |
| `areEnoughDeepSleeping(pct, players)` | the number of the level's players with `isSleepingLongEnough` is `>= sleepersNeeded(pct)` |
| `canSleepThroughNights` | `pct <= 100` |

The tick check (2.1 step 3) needs **both** `areEnoughSleeping` and `areEnoughDeepSleeping`. `pct = 0` still needs one sleeping player (the minimum is 1); `pct > 100` makes the night impossible to skip (the needed number exceeds the active players) and the player is told `sleep.not_possible` when going to bed.

`announceSleepStatus` (after a change, 5.2 step 11 and 5.3): nothing if `pct > 100`; nothing on an unpublished single-player world; otherwise every player of the level receives an **overlay** line: `sleep.skipping_night` "Sleeping through this night" when `areEnoughSleeping(pct)`, else `sleep.players_sleeping` "%s/%s players sleeping" with `sleepingPlayers` and `sleepersNeeded(pct)`.

### 5.5 The night skip

When the tick check passes (2.1 step 3), in this order: (a) with `advance_time` true and a default clock, the clock moves to `wake_up_from_sleep` (3.3), which broadcasts Set Time; (b) `wakeUpAllPlayers`: `sleepingPlayers` is set to 0 and every sleeping player of the level gets `stopSleepInBed(false, false)`; (c) weather reset (4.6). This happens on every level tick, including while the tick rate manager has the game frozen (2.1 step 3), so a frozen game still skips the night once enough players are deeply asleep (the clock does not advance by itself while frozen, but the move to the marker is a direct move). With `advance_time` false the time does not move but the players are still woken. Note that the check runs every tick while the counters stay as they were, so it passes on the first tick at which both counters are satisfied.

## 6. World spawn, initial spawn search, respawn

### 6.1 The respawn data

`RespawnData` = a **global position** (dimension key plus block position) and `yaw` and `pitch` floats. Factory `of(dim, pos, yaw, pitch)` stores `pos` immutable, wraps `yaw` to the range -180 to 180 and clamps `pitch` to -90 to 90. Codec fields: the global position fields, `yaw` (range-limited -180 to 180) and `pitch` (-90 to 90); default value yaw 0, pitch 0. The world spawn is stored once, in the **overworld's** level data (`spawn` in `level.dat`), and may name any dimension. On the wire it is Set Default Spawn Position (05b 0x63).

`MinecraftServer.setRespawnData(data)` (used by `/setworldspawn`, 16 §4.7): if it differs from the stored data, store it, broadcast Set Default Spawn Position with the data to **all** players, then recompute the effective data (6.5).

### 6.2 Initial world spawn (done once, when a level's data is not yet initialised: world creation)

The server runs `setInitialSpawn(overworld)` (after the overworld exists and before the other levels are created):

1. Skip this section's steps for the debug world options (fixed spawn `(0, 64, -100)` or `(0, 80, 0)`; shortcuts used only by developer flags).
2. `origin` = `generator.getOrigin(randomState)`: for the noise generator, the chunk containing the result of the **noise spawn finder** (6.3) when the noise settings' `spawn_target` list is non-empty, else chunk `(0, 0)`. (The vanilla overworld settings have a two-entry list; the amplified and large-biomes settings also have non-empty lists, of which only the first entry's first key was looked at; the Nether, End, caves and floating-islands settings have empty lists, read.)
3. Provisional spawn = the origin chunk's minimum corner plus `(8, y, 8)`, with `y = generator.getSpawnHeight(level)`: **64** for the noise generator (a constant of the base generator), and `minY + min(levelHeight, number of layers)` for the flat generator; if that `y` is below the level's minimum y, `y` is the `WORLD_SURFACE` height at the chunk centre `(minX + 8, minZ + 8)`. Yaw 0, pitch 0. This is stored immediately (it is what stays if the next step finds nothing).
4. **Spiral search over 121 chunks** around `origin` (11 x 11 chunks, i.e. offsets -5 to 5): visit the offsets of a square spiral in this order: `(0,0)`, `(1,0)`, `(1,1)`, `(0,1)`, `(-1,1)`, `(-1,0)`, `(-1,-1)`, `(0,-1)`, `(1,-1)`, `(2,-1)`, `(2,0)`, `(2,1)`, `(2,2)`, `(1,2)`, `(0,2)`, `(-1,2)`, `(-2,2)`, `(-2,1)`, `(-2,0)`, `(-2,-1)`, `(-2,-2)`, `(-1,-2)`, `(0,-2)`, `(1,-2)`, `(2,-2)`, `(3,-2)`, and so on (the turn rule: the direction `(dx, dz)` becomes `(-dz, dx)` after the cell whose `x == z`, or `x < 0 and x == -z`, or `x > 0 and x == 1 - z`; the start direction is `(0, -1)`; 121 cells are visited and they are exactly the 121 offsets in `[-5, 5] x [-5, 5]`, each once, checked by enumeration). For each offset call `getSpawnPosInChunk(chunk origin + offset)`; the **first** non-null result becomes the world spawn (yaw 0, pitch 0) and the search ends.
5. If the world option "bonus chest" is on, the bonus-chest feature is then placed near the spawn (feature engine, RS19).

`getSpawnPosInChunk(level, chunk)`: null for the debug void terrain; otherwise iterate the chunk's 16 x 16 columns with **x as the outer loop and z as the inner loop, both ascending from the chunk's minimum**, and return the first column for which `getLevelRespawnPos` is non-null.

`getLevelRespawnPos(level, x, z)` (the chunk is loaded to FULL status, which forces generation):
1. `topY` = the dimension's generator spawn height (64) if the dimension type has a ceiling, else the chunk's `MOTION_BLOCKING` height at the column; if `topY < minY` the column is rejected (null).
2. `surface` = the `WORLD_SURFACE` height; reject the column if `surface <= topY` **and** `surface > OCEAN_FLOOR height` (a water-covered column: the surface is the water, the floor is lower).
3. For `y` from `topY + 1` **down** to `minY`: read the block state at `(x, y, z)`; if its fluid state is not empty, reject the column; if the **up face of its collision shape is a full face**, return the position `(x, y + 1, z)`; if the loop ends, reject.

### 6.3 The noise spawn finder (`NoiseSpawnFinder`, from the noise settings' `spawn_target`)

Input: the list of **spawn target points**; each is a map from a density function to a parameter interval `[min, max]` (the vanilla overworld has two points; they use `overworld/continents` in [-0.11, 1.0], `erosion` [-1.0, 1.0], `temperature` [-1.0, 1.0], `vegetation` [-1.0, 1.0] and `ridges` in [-1.0, -0.16] for the first and [0.16, 1.0] for the second; 10 §5 has the same table). The functions are evaluated by the density machinery of 10 §6.

`fitness(x, z)`:
1. Align the coordinates to the biome grid for the density sampling only: `qx = (x >> 2) << 2`, `qz = (z >> 2) << 2` (`QuartPos.fromBlock` then `toBlock`). The unaligned `x` and `z` are kept for the distance term and for the returned position.
2. For each spawn target point, `s = sum over its entries of distance(q(f(qx, 0, qz)))^2`, where `f` is the density function evaluated at block position `(qx, 0, qz)`, `q(v) = (long)(v x 10000.0f)` (truncation toward zero) and `distance(v)` for an interval with quantised bounds is `v - max` if that is above 0, else `max(min - v, 0)`. `s` is a long.
3. `m = min over the points of s`. Result: `fitness = m x 2048^2 + x^2 + z^2` (a long; `2048^2 = 4194304`; `x` and `z` are the **unaligned** inputs, squared as longs) at the position `(x, 0, z)` with the **original, unaligned** `x` and `z` (read in `getSpawnPositionAndFitness`: the density samples use the aligned values, the squares and the returned `BlockPos` use the inputs). A position in all intervals has `m = 0` and so fitness equal to its squared distance from the world origin. The search positions of step 3 below are not multiples of 4 in general, so the aligned and unaligned values differ there.

Search (lower fitness wins; **strictly** lower replaces, so the first of equal candidates stays):
1. `best = fitness(0, 0)`.
2. **Pass 1** (`maxRadius = 2048`, `step = 512`) around the current best position `c`. **Pass 2** (`maxRadius = 512`, `step = 32`) around the best position after pass 1.
3. A pass: `angle = 0`, `radius = step`; while `radius <= maxRadius`: candidate `(c.x + (int)(sin(angle) x radius), c.z + (int)(cos(angle) x radius))` (float angle and radius widened to double; the cast truncates toward zero); evaluate and keep it if its fitness is lower than the best so far; then `angle += step / radius` (float); if `angle > 6.283185307179586` set `angle = 0` and `radius += step`. The centre `c` of one pass does not change during the pass.
4. The result is the best position; its chunk is the **origin** of 6.2.

Probe count (inferred arithmetic): pass 1 has rings at 512, 1024, 1536 and 2048 with 7, 13, 19 and 26 probes, pass 2 has 16 rings from 32 to 512 with `floor(2 pi k) + 1` probes (`k = radius / 32`), 862 in total; plus the initial probe, 1 + 7 + 13 + 19 + 26 + 862 = 928 evaluations of at most 10 density samples each. Rings at `r = 512 k` and `r = 32 k` therefore search the whole annulus coarsely first and then refine within 512 blocks.

### 6.4 A player's first spawn and the join sequence (`PrepareSpawnTask`, `PlayerSpawnFinder`)

For a connecting player the server first reads the saved player data (06/07: dimension, position, rotation). Then: the **dimension** is the saved one if that level exists, else the dimension of the world respawn data, else the overworld; the **position** is the saved position if present, else `PlayerSpawnFinder.findSpawn(level, worldRespawn.pos)`; the **rotation** is the saved rotation, else the respawn data's yaw and pitch.

`findSpawn(level, suggestion)`:
1. If the world's **default game type** is ADVENTURE: no search; use `fixupSpawnHeight(suggestion)` (below) directly.
2. `radius = max(0, respawn_radius)` (rule, default 10). Let `d = floor(border.getDistanceToBorder(suggestion.x, suggestion.z))`: if `d < radius` then `radius = d`; if `d <= 1` then `radius = 1`.
3. `n = 2 radius + 1`; `candidateCount = min(1024, n^2)`; `coprime = candidateCount - 1` if `candidateCount <= 16` else the **constant 17** (no gcd test: when `candidateCount` is a multiple of 17, e.g. 289, the stride 17 visits only 17 distinct cells; a quirk read as is); `offset = a uniform random integer in [0, candidateCount)` from an unseeded thread-local random source.
4. For candidate `i = 0, 1, ...` while `i < candidateCount`: `k = (offset + coprime x i) mod candidateCount`; `x = suggestion.x + (k mod n) - radius`; `z = suggestion.z + (k div n) - radius`. Load the chunk of `(x, z)` (ticket of type spawn search, radius 0) and evaluate on the main thread: `p = getLevelRespawnPos(level, x, z)` (6.2) and require that the player's bounding box at the bottom centre of `p` collides with nothing and no liquid (`noCollisionNoLiquid`: block collisions with the liquid flag set (inferred meaning of the flag), no entity collision, no border collision); the first success completes the search with position `(p.x + 0.5, p.y, p.z + 0.5)`.
5. If all candidates fail: `fixupSpawnHeight(suggestion)`.

`fixupSpawnHeight(pos)`: (1) starting at `pos`, move up one block at a time while the player box at the bottom centre is blocked or liquid-filled and `y < maxY`; (2) step down one block, then keep stepping down while the box is free and `y > minY`; (3) step up one block; the result is the bottom centre of that position.

Worked example: `respawn_radius` 10 gives `n = 21`, `candidateCount = 441`, `coprime = 17`; with `offset = 100`, `i = 0` gives `k = 100`, offset `(100 mod 21 - 10, 100 div 21 - 10) = (6, -6)` from the suggestion, `i = 1` gives `k = 117`, offset `(2, -5)`.

**Join packet sequence** (`PlayerList.placeNewPlayer` and `sendLevelInfo`, order read): Login (the flags `showDeathScreen = not immediate_respawn`, `reducedDebugInfo`, `doLimitedCrafting` come from the three rules, 8), Change Difficulty (difficulty and locked), Player Abilities, Set Held Slot, Update Recipes, permission level, recipe book, scoreboard, the join message, teleport to the player's position, server status, player-info updates, then `sendLevelInfo`: **Initialize Border**, **Set Time (full)**, **Set Default Spawn Position (effective world respawn data)**, then if raining Game Events 1, 7, 8 (4.2), then Game Event 13 (LEVEL_CHUNKS_LOAD_START), then the tick-rate state update for the joining player; the level adds the player; boss bars, effects and the inventory menu follow.

### 6.5 Effective respawn data and spawn protection

* Every server tick (1.2 step 5) `effectiveRespawnData` is recomputed: take the overworld's stored respawn data; find its dimension's level (`findRespawnDimension`, the overworld when that level does not exist); if the stored position is **outside that level's world border**, replace the position by the `MOTION_BLOCKING` height-map position above `(border centre x, 0, border centre z)`, keeping yaw, pitch and dimension. This effective value is what Set Default Spawn Position carries, what `ServerLevel.getRespawnData` returns and what the player respawn flow falls back to (17 §4.10: `TeleportTransition.createDefault`).
* **Respawn flow overview** (details 17 §4.10): the player's own respawn config (bed or anchor, set by sleeping 5.2 step 5, by `/spawnpoint`, or by an anchor) is tried first; if it is unusable the player is told `block.minecraft.spawn.not_valid` "You have no home bed or charged respawn anchor, or it was obstructed" and goes to the effective world spawn; a first spawn without saved data uses 6.4; the rule `respawn_radius` is **not** applied to a death respawn at the world spawn by `findRespawnPositionAndUseSpawnBlock` (it applies in `findSpawn`, i.e. first join and any other caller of `adjustSpawnLocation`; whether the death respawn at world spawn calls it is not read here, Open question 7).
* **Spawn protection** (dedicated server only, `DedicatedServer.isUnderSpawnProtection`; the base server class answers false): a block position is protected for a player when, in this order: the level's dimension equals the dimension of the world respawn data (else not protected); the operator list is not empty; the player is not an operator; the property `spawn-protection` (default 16) is above 0; and `max(|x - spawn.x|, |z - spawn.z|) <= spawn-protection` (a square, not a circle). It is checked by `ServerLevel.mayInteract` (a player may interact only if the position is not protected and inside the world border), block-break actions, `handleUseItemOn`, farmland trampling and turtle-egg destruction.

## 7. World border

### 7.1 State

Each **level** has its own `WorldBorder` (a saved-data object per dimension, 10): `centerX`, `centerZ` (doubles, clamped by the codec to +-29999984), `damagePerBlock` (default 0.2), `safeZone` (default 5.0), `warningBlocks` (int, default 5), `warningTime` (int, default 300), `size` (default 59999968.0), `lerpTime` (long, default 0), `lerpTarget` (default 0.0), plus `absoluteMaxSize`, set from the server's maximum world size (property `max-world-size`, default 29999984) when the levels are created. `MAX_SIZE` is 59999968 and `MAX_CENTER_COORDINATE` 29999984 (constants read). The wire commands and the five border packets are 16 §4.11. The defaults are applied once, when the border is first initialised (`applyInitialSettings(gameTime)`): centre, damage, safe zone, warning values are set; if `lerpTime > 0` the border resumes a lerp from `size` to `lerpTarget` over `lerpTime` ticks, else the size is set directly. (`warning_time` is in ticks: `WorldBorderCommand` reads the argument with `TimeArgument`, which yields ticks, and `setWarningTime` stores that value directly; the default 300 is 300 ticks, 15 s; consistent with 16 §4.11.)

### 7.2 Extents

The border always has an **extent**: static or moving.

* Static (size `S`): `minX = clamp(cx - S/2, -A, A)`, `maxX = clamp(cx + S/2, -A, A)` and the same for z, where `A = absoluteMaxSize`. Status STATIONARY, lerp speed 0.
* Moving (`from`, `to`, duration `D` ticks): the remaining time `lerpProgress` starts at `D`; its size is `lerp((D - progress) / D, from, to)` (a progress of `D` gives `from`, 0 gives `to`; the last value is exactly `to`), and the min and max are computed from the interpolated size between the previous tick's size and the current size by the render tick fraction (`lerp(f, previousSize, size)`), clamped to `+-A`. Status SHRINKING if `to < from`, else GROWING. Lerp speed is `|from - to| / (lerpEnd - lerpBegin)` blocks per tick.

`setSize(s)` replaces the extent by a static one and notifies the listeners (Set Border Size); `lerpSizeBetween(from, to, time, gameTime)` makes a static extent if `from == to` else a moving one (Set Border Lerp Size); `setCenter` updates the box (Set Border Center). All of them mark the saved data dirty.

### 7.3 Per-tick behaviour

Each level tick (2.1 step 2a, only when `runs`) the extent updates: a moving extent decrements `lerpProgress`, sets `previousSize = size`, recomputes `size`, marks the border dirty and **turns into a static extent** when `lerpProgress <= 0`; a static extent does nothing.

### 7.4 Geometry and where it is used

| Function | Definition |
|---|---|
| `isWithinBounds(x, z, margin = 0)` | `minX - margin <= x < maxX + margin` and the same for z: **the minimum edge is inclusive, the maximum edge exclusive** |
| block position | tested with `(x, z)` as doubles |
| chunk | both its minimum and maximum block corners are within |
| bounding box | `(minX, minZ)` and `(maxX - 9.999999747378752E-6, maxZ - 9.999999747378752E-6)` (the constant is the float `1.0E-5f` widened) must both be within |
| `clampVec3ToBound` | `x` clamped to `[minX, maxX - 9.999999747378752E-6]`, `z` likewise, `y` unchanged |
| `getDistanceToBorder(x, z)` | the smallest of `z - minZ`, `maxZ - z`, `x - minX`, `maxX - x` (negative outside) |
| `isInsideCloseToBorder(entity, box)` | with `m = max(1, max(box x size, box z size))`: the entity's `getDistanceToBorder` is below `2m` and the entity's `(x, z)` is within bounds with margin `m` |
| collision shape | an "infinite" box minus the box `[floor(minX), ceil(maxX)] x [floor(minZ), ceil(maxZ)]` (all y): the whole outside of the border is solid |

Consumers (read): entity movement collision includes the border shape for entities that are close to the border (`CollisionGetter.borderCollision`, using `isInsideCloseToBorder`); `LivingEntity.baseTick` damage (7.5); `ServerLevel.mayInteract` (player interaction only inside); `ServerGamePacketListenerImpl.handleAttack`/`handleInteract` ignore targets whose block position is outside; `ServerLevel.canSpawnEntitiesInChunk` and `LevelChunk.isTicking` (chunks and positions outside the border do not tick or spawn); `PistonBaseBlock.isPushable` (a block outside cannot be pushed); portal creation and destination (`NetherPortalBlock.getPortalDestination`, `PortalForcer.createPortal`), `Level.getWorldBorderAdjustedRespawnData` (6.5), `PlayerSpawnFinder.findSpawn` (6.4), `SpawnUtil.trySpawnMob`, `LivingEntity.randomTeleport` and `Shulker.teleportSomewhere`, `DragonEggBlock.teleport`, `DismountHelper`, `AbstractBedBlock.getStateForPlacement`, `Warden` target and vibration filters, goat and nautilus ram targets, `GoToWantedItem`, `Sniffer` dig position and `SpawnPlacementTypes` (spawn position checks). Each test is "inside the border" except where noted.

### 7.5 Damage

In `LivingEntity.baseTick` (every tick, living entity alive, server side) the border test is the **else-branch of the in-wall test**. If the entity `isInWall`, it takes 1.0 damage of type `in_wall` and the border test is skipped that tick. Otherwise, for **players only**: if the player's bounding box is not within bounds, compute `d = distanceToBorder(player) + safeZone`; if `d < 0` and `damagePerBlock > 0`, hurt the player with the damage type `outside_border` (death message `death.attack.outsideBorder` "%1$s left the confines of this world") for `max(1, floor(-d x damagePerBlock))` points. The hurt window of 17 §4.7 limits how often it lands. Worked example: border size 100 (half-width 50) centred at the origin, `safeZone` 5, `damagePerBlock` 0.2, a player at x = 60 with the box outside the bounds: if the player is also inside a wall block, the tick deals 1.0 `in_wall` damage and no border damage; if not, the distance to the border is -10, `d = -10 + 5 = -5`, damage `max(1, floor(5 x 0.2)) = max(1, 1) = 1`. At x = 80: `d = -25`, `floor(25 x 0.2) = 5`, damage 5. (The distance is the smallest of the four edge distances, negative outside, 7.4.) The warning blocks and warning time only drive the client vignette.

## 8. Game rules

### 8.1 Mechanism

There is **one** `GameRules` object per server (the overworld's rules are what every level and `getGlobalGameRules` read; `ServerLevel.getGameRules` returns the server's), stored in the world as the saved data `game_rules` (10). A rule is registered with its id, category, type (boolean or integer), default, and for integers min and max (16 §13 lists all 59). Reading an unregistered or feature-disabled rule throws; setting one that is not available only logs a warning. `GameRules.set(rule, value, server)` **always** stores the value and then calls `MinecraftServer.onGameRuleChanged(rule, value)` (also when the value is unchanged; the `gamerule` command itself refuses an unchanged value, 16 §4.4). The server hook does, by rule:

| Rule | What the change does immediately |
|---|---|
| (any) | the notification manager is informed (the Game Rule Values packet 05a 0x28 and operator-visible updates use it) |
| `reduced_debug_info` | every player gets Entity Event 22 (true) or 23 (false) about itself |
| `limited_crafting` | every player gets Game Event 12 (LIMITED_CRAFTING) with value 1.0 or 0.0 |
| `immediate_respawn` | every player gets Game Event 11 (IMMEDIATE_RESPAWN) with value 1.0 or 0.0 |
| `locator_bar` | every level re-evaluates its waypoint connections |
| `spawn_monsters` | `updateMobSpawningFlags`: for every level the "spawn enemies" flag becomes `spawn_mobs and spawn_monsters` |
| `advance_time` | full Set Time to everybody (3.8) |

At join the same three flag rules are sent in the Login packet (6.4). `DedicatedServer.initServer` additionally sets `show_advancement_messages` from the property `announce-player-achievements` when that property is present.

### 8.2 The 59 rules: where each takes effect

Defaults, types and ranges are not repeated here: 16 §13 is the sole source for the default and type of each rule (this document confirmed the count of 59 and the rule names from the registration; a later comparison of the registration against 16 §13 found them in agreement, for example `fire_spread_radius_around_player` 128 with minimum -1, `max_snow_accumulation_height` 1 with range 0..8, `max_minecart_speed` 8 with range 1..1000) "Level" below is the level of the acting entity, block or player; the rule is always read from the one rules object. Sites are class and method names read in the jar (a method name alone means a gate at its start).

| Rule | Exact effect |
|---|---|
| `advance_time` | 3.2 (clock advance), 3.8 (network rate 0 when false, full sync on change), 2.1 step 3 (night skip moves the clock only when true) |
| `advance_weather` | 4.2 (timers and flags stand still when false; smoothing continues), 4.6 (sleep reset), debug-world setup sets it false |
| `allow_entering_nether_using_portals` | `ServerLevel.isAllowedToEnterPortal(destination level)`: false only when the destination is the Nether and the rule is false; consulted by `Entity.teleportToPortalDestination` (the portal does nothing for that entity) |
| `block_drops` | `Block.popResource` (no item entity for a non-empty stack), `Block.popExperience` (no block experience orbs), `BeehiveBlock.playerWillDestroy` (its bee and honey handling runs only with the rule on and a player whose `preventsBlockDrops` is false), `InfestedBlock.spawnAfterBreak` (the infestation spawn happens only with the rule on and a tool that does not carry the enchantment tag `prevents_infested_spawns`) |
| `block_explosion_drop_decay` | `ServerLevel.explode` with interaction BLOCK: true gives `DESTROY_WITH_DECAY`, false `DESTROY` (8.3) |
| `command_blocks_work` | `ServerLevel.isCommandBlockEnabled`: a command block or command minecart does not run its command (`BaseCommandBlock.performCommand`) and the set-command packets are rejected (`handleSetCommandBlock`, `handleSetCommandMinecart`) |
| `command_block_output` | `BaseCommandBlock$CloseableCommandBlockSource.shouldInformAdmins`: a command block's results are broadcast to operators only when the rule is on and the source is open |
| `drowning_damage`, `fall_damage`, `fire_damage`, `freeze_damage` | `Player.isInvulnerableTo`: a **player** is invulnerable to damage tagged `is_drowning`, `is_fall`, `is_fire`, `is_freezing` respectively while the rule is false (checked in that order; mobs are unaffected) |
| `elytra_movement_check`, `player_movement_check` | `ServerGamePacketListenerImpl.shouldCheckPlayerMovement`: the movement validation of an incoming position packet is skipped for a single-player owner or a player changing dimension, skipped when `player_movement_check` is false, and for a gliding player also skipped when `elytra_movement_check` is false |
| `ender_pearls_vanish_on_death` | `ThrownEnderpearl.tick`: when the owner (found even if dead) is a `ServerPlayer` that is not alive and has not "won the game", the pearl is discarded with the rule on |
| `entity_drops` | with the rule off these do not drop their item or contents: `FallingBlockEntity.tick` (the landing block that cannot be placed is not dropped as an item), `ItemFrame.dropItem`, `Painting.dropItem`, `Cushion.dropItem`, `VehicleEntity.destroy` (the vehicle item), `ContainerEntity.chestVehicleDestroyed` (the contents), `Leashable.tickLeash` (a broken leash is removed instead of dropping the lead; `CopperGolem.turnToStatue` likewise) |
| `fire_spread_radius_around_player` | `ServerLevel.canSpreadFireAround(pos)`: true if the rule is -1, else true when some non-spectator player **of this level's chunk map** (`ChunkMap.anyPlayerCloseEnoughTo(pos, r)` iterates only the players of that map; players in other dimensions never count) has `distance < r` **strictly** (`Vec3.distanceTo` from the player position to the block-position vector, so a player exactly `r` blocks away does not count). When false: `FireBlock.tick` re-schedules itself and then does nothing, `LavaFluid.randomTick` does nothing, `LightningBolt.spawnFire` places no fire |
| `forgive_dead_players` | when a player dies, the rule is read in `ServerPlayer.die`, which, with the rule on, calls its private helper `tellNeutralMobsThatIDied` (the helper itself does not read the rule); the helper calls `NeutralMob.playerDied` and, with the rule on, a neutral mob whose persistent anger target is that player stops being angry; `StartCelebratingIfTargetDead` and `StopBeingAngryIfTargetDead` (brain mobs) erase their attack-target memory when the dead target is a player and the rule is on |
| `global_sound_events` | `ServerLevel.globalLevelEvent`: with the rule on, every player of the server receives the level event; a player in the same level within 32 blocks of the event receives it at its position, a farther one at a point 32 blocks from itself towards the event, a player in another level at its own position (the packet carries the "global" flag); off: an ordinary level event heard by nearby players only |
| `immediate_respawn` | Login `showDeathScreen = not rule`, Game Event 11 on change (8.1); the client skips the death screen |
| `keep_inventory` | 17 §4.10: no inventory drop, `restoreFrom` copies inventory, experience and score to the respawned player, base experience reward 0 |
| `lava_source_conversion`, `water_source_conversion` | `LavaFluid.canConvertToSource`, `WaterFluid.canConvertToSource`: whether flowing fluid next to two source blocks over a solid or source becomes a source (`FlowingFluid.getNewLiquid`; rules in the fluid round) |
| `limited_crafting` | Login flag, Game Event 12 on change; `RecipeCraftingHolder.setRecipeUsed(player, recipe)` allows a **non-special** recipe only if the player's recipe book contains it (special recipes always) |
| `locator_bar` | `ServerWaypointManager.isLocatorBarEnabledFor(player)` (the player's level); change hook (8.1) |
| `log_admin_commands` | `CommandSourceStack.broadcastToAdmins`: the line goes to the server console when the source is not the console and the rule is on |
| `max_block_modifications` | `/fill`, `/clone`, `/fillbiome` refuse more blocks than the rule (16 §7) |
| `max_command_forks`, `max_command_sequence_length` | the execution context of every command run is created with `max(1, sequence length)` and the forks limit (15); `CommandBlock.executeChain` stops a chain after that many chained command blocks |
| `max_entity_cramming` | `LivingEntity.pushEntities` (once per entity tick): with `L > 0`, if the number of pushable entities touching it exceeds `L - 1` and `nextInt(4) == 0`, count those that are not passengers; if that count exceeds `L - 1` the entity takes 6.0 `cramming` damage. `OozingMobEffect.onMobRemoved`: the number of slimes spawned when an oozing mob dies is limited by the number of slimes already close, against `L` |
| `max_minecart_speed` | `NewMinecartBehavior.getMaxSpeed`: `rule x (0.5 if in water else 1.0) / 20.0` blocks per tick (the rule is available only with the minecart-improvements feature) |
| `max_snow_accumulation_height` | 4.4 step 2.1: snow layers stack up to `min(rule, 8)`; 0 disables new snow (ice still forms) |
| `mob_drops` | `LivingEntity.shouldDropLoot` (true for adults only: not a baby, and the rule), `Monster.shouldDropLoot` (the rule), `LivingEntity.dropExperience` (a death's experience orbs need the rule), breeding rewards `Animal.finalizeSpawnChildFromBreeding`, `Fox$FoxBreedGoal.breed`, `Turtle.ageBoundaryReached` and `Turtle$TurtleBreedGoal.breed` (experience orbs and the scute), `Panda.afterSneeze` (the sneeze item), `EnderDragon.tickDeath` (the death experience) |
| `mob_explosion_drop_decay` | `ServerLevel.explode` with interaction MOB (8.3) |
| `mob_griefing` | see 8.4 |
| `natural_health_regeneration` | `FoodData.tick`: the saturated-fast and the slow regeneration branches (17 §4.9) run only with the rule on (starvation does not depend on it); `ServerPlayer.tickRegeneration` (Peaceful regeneration: every 20 ticks +1 health when hurt and +1 saturation below 20, every 10 ticks +1 food when hungry) runs only with the rule on |
| `players_nether_portal_creative_delay` | `NetherPortalBlock.getPortalTransitionTime(level, entity)`: for a player with the invulnerable ability (creative) the delay is this rule (ticks, floor 0); other entities have 0 |
| `players_nether_portal_default_delay` | the same for other players; additionally `ClipContext$Block` treats a nether portal block as a full block for the clip of a player when this rule is 0 (inferred effect: with a zero delay portals are solid to block raycasts; the shape rule itself was read, its use was not) |
| `players_sleeping_percentage` | 2.1 step 3, 5.2 step 10, 5.4 |
| `projectiles_can_break_blocks` | `Projectile.mayBreak`: a projectile may break a block of the "projectile breakable" tag only with the rule on and when `canBreakBlockInAdventureMode` allows it for the owner |
| `pvp` | `ServerLevel.isPvpAllowed` and `ServerPlayer.canHarmPlayer`: a player can damage another player only with the rule on (17 §4.4 server player gating) |
| `raids` | `Raids.tick` stops every active raid when false; `Raids.createOrExtendRaid` returns nothing when false |
| `random_tick_speed` | 2.2, 2.4; also read by `ServerWatchdog` (via `getAsString`) for the "Random tick rate" line of its crash report |
| `reduced_debug_info` | Login flag; Entity Event 22/23 on change (8.1); read only in `MinecraftServer.onGameRuleChanged` and `PlayerList.placeNewPlayer` |
| `respawn_radius` | 6.4 step 2 (`PlayerSpawnFinder.findSpawn` radius) |
| `send_command_feedback` | `CommandSourceStack.sendSuccess` and `CommandSource.acceptsSuccess` of players and command blocks: success lines go to the executing source only with the rule on; `broadcastToAdmins` sends the grey italic "[source: text]" line to every operator player other than the source only with the rule on; `/gamemode` on another player skips the "gameMode.changed" notice to that player; `CommandBlock.setPlacedBy` sets the new command block's "track output" flag from the rule |
| `show_advancement_messages` | `PlayerAdvancements.award`: the chat announcement is broadcast only when the advancement display announces to chat and the rule is on |
| `show_death_messages` | `ServerPlayer.die`: the death message is sent (Player Combat Kill and the team-visibility broadcast, 17 §4.10) only with the rule on; `TamableAnimal.die`: the pet's death message goes to its owner player |
| `spawner_blocks_work` | `ServerLevel.isSpawnerBlockEnabled`: `BaseSpawner.serverTick` does nothing, `SpawnEggItem.useOn` cannot change a spawner, `TrialSpawner.canSpawnInLevel` is false |
| `spawn_mobs` | 2.2 steps 2 and 6 (no natural spawning, no custom spawners), `ServerLevel.isSpawningMonsters` (monsters need both this rule and `spawn_monsters`), 4.4 step 5 (skeleton trap), `TrialSpawner.canSpawnInLevel` (unless the spawner overrides the rule), `NaturalSpawner.spawnMobsForChunkGeneration` (no chunk-generation mobs) |
| `spawn_monsters` | `isSpawningMonsters`; change hook; also the flag that `Strider`, `Zombie.hurtServer` (reinforcements), `ThrownEnderpearl.onHit` (endermite), `CreakingHeartBlockEntity.serverTick` and `NetherPortalBlock.randomTick` (zombified piglin) read through `isSpawningMonsters` |
| `spawn_patrols` | `PatrolSpawner.tick` (20 §14.1) |
| `spawn_phantoms` | `PhantomSpawner.tick` (20) |
| `spawn_wandering_traders` | `WanderingTraderSpawner.tick` (19 trader spawner); with the rule off the tick returns before its countdown |
| `spawn_wardens` | `SculkShriekerBlockEntity.canRespond`: a shrieker can summon a warden only if the rule is on and the difficulty is not Peaceful (and its other condition) |
| `spectators_generate_chunks` | `ChunkMap.skipPlayer`: with the rule off a spectator player is skipped by the player map used for chunk loading and ticking, so the spectator does not load or generate chunks |
| `spread_vines` | `VineBlock.randomTick` returns immediately when false |
| `tnt_explodes` | `TntBlock.prime` (no priming), `TntBlock.wasExploded` (no chain primed TNT), `TntBlock.useItemOn` (a Pass result and the overlay text `block.minecraft.tnt.disabled` "TNT explosions are disabled" to the player), `PrimedTnt.explode` (the entity is removed without exploding), `MinecartTNT.explode`/`primeFuse`, the TNT dispenser behaviour, `SulfurCube` fuse methods |
| `tnt_explosion_drop_decay` | `ServerLevel.explode` with interaction TNT (8.3); default false |
| `universal_anger` | `NeutralMob.isAngryAtAllPlayers` (a neutral angry mob with no persistent target is angry at every player) and the neutral targeting goals `HurtByTargetGoal`, `ResetUniversalAngerTargetGoal` and the Piglin anger methods `PiglinAi.maybeRetaliate`, `setAngerTarget`, `angerNearbyPiglins` (19, 21) |
| `water_source_conversion` | see `lava_source_conversion` |

### 8.3 Explosion interaction by rule (`ServerLevel.explode`)

`Level.ExplosionInteraction` has five values; the block interaction used by the explosion is:

| Interaction | Block interaction | Used by (examples) |
|---|---|---|
| NONE | KEEP (blocks untouched) | explosions that only hurt |
| BLOCK | `block_explosion_drop_decay` true: DESTROY_WITH_DECAY, false: DESTROY | block-caused explosions (beds, anchors) |
| MOB | if `mob_griefing` is true: `mob_explosion_drop_decay` true: DESTROY_WITH_DECAY, false: DESTROY; if `mob_griefing` is false: KEEP | creepers, ghast fireballs, wither |
| TNT | `tnt_explosion_drop_decay` true: DESTROY_WITH_DECAY, false: DESTROY | TNT, TNT minecart |
| TRIGGER | TRIGGER_BLOCK (only triggers block behaviours) | wind charges |

DESTROY_WITH_DECAY applies the `explosion_decay` loot behaviour (items from destroyed blocks may be lost; data engine GAP-4); DESTROY drops everything. `ServerExplosion.canTriggerBlocks`: for TRIGGER interaction from a breeze wind charge the rule `mob_griefing` must be true; `shouldAffectBlocklikeEntities`: with `mob_griefing` false only wind charges still push block-like entities.

### 8.4 `mob_griefing` sites (all read; each is "does nothing when the rule is false" unless stated)

| Class and method | Gated behaviour |
|---|---|
| `ServerLevel.explode` | MOB explosions keep blocks (8.3) |
| `WeavingMobEffect.onMobRemoved` | cobwebs spawned around a mob that dies with weaving (non-players only) |
| `HarvestFarmland.checkExtraStartConditions` | villager farmers harvesting and planting |
| `BreakDoorGoal.canUse` | zombies breaking doors (also requires a valid difficulty) |
| `EatBlockGoal.tick` | sheep eating grass (the block is not removed; the "ate" behaviour still happens) |
| `RemoveBlockGoal.canUse` | zombie turtle-egg stomping and similar block removal goals |
| `Allay.wantsToPickUp` | allay item pickup |
| `Fox$FoxEatBerriesGoal.onReachedTarget` | foxes picking sweet berries |
| `GoatAi`, `NautilusAi` (ram target tests) | rams may hit armor stands only with the rule on (an armor stand is an excluded target when off) |
| `SnowGolem.aiStep` | snow trail |
| `Rabbit$RaidGardenGoal.canUse` | rabbits eating crops |
| `EnderDragon.checkWalls` | the dragon destroys blocks that are not dragon-immune only with the rule on |
| `WitherBoss.customServerAiStep` | wither block breaking while it is hurt |
| `ArmorStand.hurtServer`, `BlockAttachedEntity.hurtServer` (paintings, frames), `ItemEntity.hurtServer` | a `Mob` damage source cannot hurt them |
| `LivingEntity.createWitherRose` | a wither kill leaves a wither rose only with the rule on |
| `Mob.aiStep` | mobs picking up items |
| `SulfurCube.tickFuse` | the explosion interaction chosen (TNT or lesser) |
| `Enderman$EndermanLeaveBlockGoal.canUse`, `EndermanTakeBlockGoal.canUse` | endermen placing and taking blocks |
| `Evoker$EvokerWololoSpellGoal.canUse` | the wololo spell |
| `Piglin.wantsToPickUp` | piglin item pickup |
| `Ravager.aiStep`, `Ravager.roar` | leaf breaking while charging; the roar's target filter changes to the one without block damage |
| `Silverfish$SilverfishMergeWithStoneGoal.canUse`, `SilverfishWakeUpFriendsGoal.tick` | hiding in stone; wake-up breaking infested blocks |
| `LargeFireball.onHit` | the explosion's fire flag equals the rule |
| `SmallFireball.onHitBlock` | blaze fireballs from a mob light fires |
| `Projectile.mayInteract` | a projectile of a mob owner may interact with blocks (buttons, bells) only with the rule on |
| `VehicleEntity.ignoreExplosion` | vehicles ignore explosions of mobs when the rule is off |
| `CropBlock.entityInside`, `PitcherCropBlock.entityInside` | a ravager breaks crops |
| `FarmlandBlock.fallOn` | non-player entities (volume above 0.512) trample farmland only with the rule on |
| `PowderSnowBlock.entityInside` | a burning entity melts powder snow (a non-mob player acts regardless of the rule if `mayInteract`) |
| `TurtleEggBlock.canDestroyEgg` | living entities trampling turtle eggs |
| `ServerExplosion.canTriggerBlocks`, `shouldAffectBlocklikeEntities` | 8.3 |

### 8.5 The "spawn enemies" level flag

`ServerLevel.isSpawningMonsters()` is `spawn_mobs and spawn_monsters`. The server stores that value in every level's chunk source (`ServerChunkCache.setSpawnSettings`) when a level is created and whenever `spawn_monsters` or the difficulty changes (`updateMobSpawningFlags`); the difficulty setter calls it too (9.1). The natural spawner reads the stored flag (2.2 steps 2 and 6, 18 §6.1).

## 9. Difficulty

### 9.1 The setting

`Difficulty` has four values with id, key: PEACEFUL 0 `peaceful`, EASY 1 `easy`, NORMAL 2 `normal`, HARD 3 `hard`. The world data keeps `difficulty`, `hardcore` and `locked` (the codec `difficulty_settings`, default NORMAL, not hardcore, not locked). `MinecraftServer.setDifficulty(d, force)`: ignored unless `force` or the difficulty is not locked; stores `d`, **except that a hardcore world always stores HARD**; then `updateMobSpawningFlags` and sends Change Difficulty (difficulty id and locked flag) to every player. The debug world forces PEACEFUL and locked. Join sends Change Difficulty (6.4).

### 9.2 Difficulty effects held in other documents

| Effect | Where |
|---|---|
| Damage scaling of mob attacks and `scales_with_difficulty` damage against a player: Peaceful 0, Easy `min(d/2 + 1, d)`, Normal `d`, Hard `d x 3 / 2` (`Player.hurtServer`) | 20 §3.1, 17 §4.12 (scaling column) |
| Starvation damage floors, regeneration | 17 §4.9 |
| Local ("regional") difficulty and its special multiplier | 18 §7.1.3, 20 §3.2 |
| Mob despawn on Peaceful, spawn rules per mob, monster aggression, door breaking, reinforcements, raids, patrols, siege, wither, shulker, guardian, zombie conversion chances, equipment and enchant chances, slime size | 18 §6, 19, 20, 21, 44 |

### 9.3 Difficulty effects added by this round

| Site | Effect |
|---|---|
| `DifficultyInstance` time input | the formula of 20 §3.2 takes its time `T` from the **overworld clock's total ticks** (`Level.getOverworldClockTime`), not from game time (20 §3.2 says game time; they differ when the clock was set, paused or `advance_time` is off). The chunk input is the chunk's inhabited time (2.2 step 4a); the moon input is 3.7 |
| `ServerLevel.getCurrentDifficultyAt(pos)` | uses inhabited time 0 and moon 0 when the chunk is not loaded to FULL status |
| `LightningBolt.tick` | on **Normal or Hard** the main strike also starts up to 4 fires (`spawnFire(4)`, gated by `fire_spread_radius_around_player`); on Easy and Peaceful only the visual and the damage happen |
| `FireBlock.tick` | the odds used when fire tries to ignite neighbours include `difficulty id x 7` (the exact formula belongs to the fire round, RS11) |
| `NetherPortalBlock.randomTick` | a zombified piglin can spawn at a portal only if the level spawns monsters, the difficulty is not Peaceful, the dimension attribute `nether_portal_spawns_piglin` is true, `nextInt(2000) < difficulty id` (so 1/2000 per random tick on Easy, 1/1000 on Normal, 3/2000 on Hard) and a player is close enough for spawning (18 §6.2) |
| `ThrownEnderpearl.onHit` | an endermite may spawn only when the level spawns monsters and the difficulty is not Peaceful (probability in 17) |
| `EyeblossomBlock.entityInside` | a bee in a closed eyeblossom is poisoned only when the difficulty is not Peaceful |
| `SculkShriekerBlockEntity.canRespond`, `BadOmenMobEffect.applyEffectTick`, `Zombie.hurtServer`, `Strider.finalizeSpawn`, `TrialSpawner.canSpawnInLevel`, `CreakingHeartBlockEntity.serverTick`, `WitherBoss.checkDespawn`, `RangedAttackMob.rangedAttackUncertainty`, `AbstractArrow.setBaseDamageFromMob` | a Peaceful difficulty disables the behaviour (wardens, raid omen, reinforcements, jockeys, trial spawners, creaking, wither despawn) or scales it (arrow uncertainty and mob arrow damage by difficulty id) as the mob documents describe; none of these sites had its numbers read in this round |
| `ServerPlayer.tickRegeneration` | Peaceful regeneration (8.2, `natural_health_regeneration`) |

## 10. What is saved where (26.3 layout of this state)

Read from `PrimaryLevelData`, the `SavedData` types and the file fix `LevelDatToSavedDataFileFix` (which names the destinations). The vanilla layout is given because the standard world type targets it (R8); the CobolCraft world folder is `07 §9`.

| Saved item | File | Fields |
|---|---|---|
| Game time, world spawn, difficulty, game type, name, flags | `level.dat`, compound `Data` | `Time` (long, game time), `spawn` (`RespawnData`: global position fields, `yaw`, `pitch`), `difficulty_settings` (`difficulty`, `hardcore`, `locked`), `GameType`, `LevelName`, `allowCommands`, `initialized`, `version`, `singleplayer_uuid`, `ServerBrands`, `WasModded`, `removed_features`, `version_history` (names read; types of the unread ones not read) |
| Weather | `data/minecraft/weather.dat` (saved data id `weather`) | `clear_weather_time`, `rain_time`, `thunder_time` (ints), `raining`, `thundering` (booleans) |
| World clocks | `data/minecraft/world_clocks.dat` (id `world_clocks`) | a map from world-clock id to `{total_ticks` long, `partial_tick` float default 0, `rate` float default 1.0, `paused` boolean default false`}` (the root wrapper keys were not read) |
| Game rules | `data/minecraft/game_rules.dat` (id `game_rules`) | the rule values keyed by rule id (the codec is a map codec; exact keys not read) |
| World border | `minecraft/world_border.dat` in the saved-data folder of **each** dimension | `center_x`, `center_z`, `damage_per_block`, `safe_zone` (doubles), `warning_blocks`, `warning_time` (ints), `size` (double), `lerp_time` (long), `lerp_target` (double) |
| Scheduled functions | `data/minecraft/scheduled_events.dat` | not read |
| Other global state moved out of `level.dat` | `wandering_trader.dat`, `custom_boss_events.dat`, `world_gen_settings.dat`, `ender_dragon_fight.dat` (End only) | not read |

Points of difference from older layouts, worth noting for the world format of the standard type: weather timers and flags, the clocks, the game rules and the world border are **not** in `level.dat` in this version; time of day is not a field of `level.dat`.

Notes for CobolCraft (not read from the artifact): `07 §9.2` lists `Time` ("time of day") and a per-dimension `Weather` compound of kind and remaining ticks; for the standard world type this document replaces them by: `Time` is **game time**, plus the clock states, the shared weather record, the rule set and one border record per dimension above (design edit P07-3 of `../design/README.md`).

## 11. Worked examples

1. **Weather timers.** `WeatherData(clear 0, rain 0, thunder 0, raining false, thundering false)` (a new world). Tick 1: the thunder part sees `thunderT = 0` and `thundering` false, so it draws `THUNDER_DELAY`, say 15000; the rain part draws `RAIN_DELAY`, say 20000. Ticks 2 to 15000 decrement `thunderT`; on the tick it reaches 0 (about tick 15001) `thundering` becomes true; the next tick `thunderT` is 0 with `thundering` true, so it draws `THUNDER_DURATION`, say 5000. At about tick 20000 `rainT` hits 0 and `raining` becomes true; from then `rainLevel` grows by `0.01f` per tick, `isRaining()` is true (inferred by float emulation) from the 20th tick of growth, `thunderLevel x rainLevel` exceeds 0.9 at the 95th tick of simultaneous growth (float emulation, inferred: 0.9024988), so the thunder-dependent logic (4.4 `tickThunder`) starts about 95 ticks after both flags are on.
2. **`weather clear 6000`** (16 §4.10 values): `clear 6000, rain 0, thunder 0, raining false`; 6000 ticks of clear; on the last of them `thunderT = rainT = 1`; the next tick both reach 0, `thundering` and `raining` become true: a storm. After it ends the delays are drawn again.
3. **Night skip.** Four players, one in spectator mode, `players_sleeping_percentage` 50: `activePlayers = 3`, `sleepersNeeded = max(1, ceil(3 x 50 / 100.0)) = max(1, ceil(1.5)) = 2`. Two players in beds: `areEnoughSleeping` true at once, but the skip waits until both have `sleepCounter >= 100` (about 100 ticks after the later one lay down). On that tick the clock (total 15000) moves to 24000 (3.3), both players wake, and if it was raining the weather resets (this would also happen with the game frozen, 2.1 step 3). Morning begins at clock tick 24000 (skyDarken is below 4 from tick 23478, so the bed rule `when_dark` would already refuse new sleepers from then).
4. **Sleeping window.** Clear weather: beds are usable from clock tick 12523 to 23477 of each day; at tick 23478 sleeping players are woken by 5.3. By day in a thunderstorm `skyDarken` is 5, so beds work; in plain rain it is 3, so they do not.
5. **Random block position.** `randValue = 0`: `randValue' = 1013904223`; `i = 1013904223 >> 2 = 253476055`; in section `(cx, sy, cz) = (32, 64, -48)` with mask 15: x = 32 + 7 = 39, y = 64 + 11 = 75, z = -48 + 12 = -36.
6. **Spawn spiral.** A world whose origin chunk is `(3, -2)`: the provisional spawn is `(56, 64, -24)` (`3 x 16 + 8`, `-2 x 16 + 8`); the first chunk tried is `(3, -2)` itself, then `(4, -2)`, `(4, -1)`, `(3, -1)`, `(2, -1)`, ... In the first chunk the columns are tried `(48, -32)`, `(48, -31)`, ..., `(48, -17)`, `(49, -32)`, ... (x outer, z inner).
7. **Spawn-finder fitness.** At `(512, 0)` a candidate inside every interval has `m = 0`, fitness `512^2 = 262144`; the start `(0, 0)` with one interval violated by 900 quantised units has `m = 810000` and fitness `810000 x 4194304`, so any in-interval point within 2048 blocks beats it. Two in-interval candidates compare by squared distance from `(0, 0)` of their unaligned coordinates only (the figures above are for multiples of 4, where aligned and unaligned values coincide; for `(513, 0)` the density samples are taken at `(512, 0)` but the fitness is `513^2 = 263169`).
8. **Border.** Size 100 at `(0, 0)`: bounds x in `[-50, 50)`. `getDistanceToBorder(10, 0)` is `min(60, 40, 50, 50) = 40`. A player at `x = 60` with the default safe zone 5 and damage 0.2: `d = -10 + 5 = -5 < 0`; damage `max(1, floor(5 x 0.2)) = max(1, 1) = 1` per landing hit. A lerp from 100 to 200 over 200 ticks with 150 ticks remaining is at `lerp(50/200, 100, 200) = 125`.
9. **Random ticks.** `random_tick_speed` 3, one chunk with 4 randomly-ticking sections: per tick 12 block positions are sampled, plus three `nextInt(48)` draws for ice and snow (about one precipitation attempt every 16 ticks per chunk).
10. **Cramming.** `max_entity_cramming` 24: an entity surrounded by 30 pushable non-passenger entities takes 6.0 damage with probability 1/4 per tick; by 20 entities it takes none (the list needs more than 23 others).
11. **Sky darkness thresholds.** Day: `skyDarken` 0. Night plateau (ticks 13670 to 22330): `L = 4.0`, `skyDarken = 11`. (All figures here are inferred by float emulation, see 12.) Tick 12523: `L = 10.99778`, `skyDarken = 4` (first dark tick). Tick 23478: `L = 11.00388`, `skyDarken = 3` (first bright tick).

## 12. Validation

| Check | Method | Result |
|---|---|---|
| All 59 rules have a consumer | a scan of all 10,737 `net/minecraft` classes for `GameRules` constants, grouped by class and method | every one of the 59 constants has at least one site; the sites are the ones in 8.2 (the client-only sites in the world-creation screen were excluded) |
| Rule defaults and counts | cross-read of `GameRules` registration with 16 §13 | consistent with 16 §13 (59 rules) |
| Weather algorithm | read the full `advanceWeatherCycle`, `resetWeatherCycle`, `prepareWeather`, `Level.isRaining/isThundering/getRainLevel/getThunderLevel`, the four `UniformInt` constants in the static initialiser | 4.1, 4.2 as written; constants match 16 §4.10 and the design map row S66 |
| Float thresholds | the thresholds `0.2d` (`isRaining`), `0.9d` (`isThundering`), the `0.01f` step and the clamp 0..1 were read in the artifact; the step counts come from a 32-bit float emulation of the ramps, not from a class | thresholds read; `isRaining` after 20 steps (0.20000002 > 0.2d), thunder product above 0.9 at step 95 (0.9024988), fade-out below 0.2 at step 81: all three (inferred) |
| Sky darkness | emulated `a + t x (b - a)` between the `sky_light_level` keyframes of the `day` track in `data/minecraft/timeline/day.json` (keyframe values and ticks: 12 §3.2; the lerp input is the fraction between two keyframes) | dusk 12523, dawn 23478, `L` 10.99778 and 11.00388: (inferred) by the emulation, reproducible from those keyframes; consistent with the bed message "only at night or during thunderstorms" |
| Spawn spiral | enumerated the turn rule for 121 steps | the 121 cells are exactly `[-5, 5]^2`; first cells as in 6.2 |
| `randomBlockPos` example | recomputed with 32-bit wrap | 7, 11, 12 |
| Sleep status | read `SleepStatus`, `ServerLevel.tick/announceSleepStatus/updateSleepingPlayerList`, `ServerPlayer.startSleepInBed`, `Player.startSleepInBed/stopSleepInBed/tick`, `AbstractBedBlock.useWithoutItem`, `BedRule` | 5.1 to 5.5 |
| Callers of `updateSleepingPlayerList` | whole-jar reference scan | only the two sleep entry points |
| Cross-document consistency | compared with 12 §3.1 to §3.5, 16 §4.4 to §4.11, §13, 17 §4.10, 18 §6 and §7.1.3, 20 §3.2, 21 §8.6 | no contradiction except the two notes below |
| Differences found and noted | | 20 §3.2 says the difficulty time input is game time: the artifact reads the overworld clock total (9.3). 07 §9.2 `Time`/`Weather` keys do not exist as such in 26.3 (10). 16 §4.10 said the `advance_weather` effect was not traced: it is 4.2 and 2.1 |

## 13. Open questions

1. **Which chunks block-tick.** `forEachBlockTickingChunk` iterates the distance manager's entity-ticking chunks; the ticket levels and the simulation-distance rule that define that set (and its order) were not re-read here. 18 §6.2 gives the spawn-candidate set (8 chunks) only.
2. **Level iteration order of the non-overworld levels.** Read: the level map is a linked (insertion-ordered) map, the overworld is inserted first, and the other stems are inserted in the iteration order of the `LevelStem` registry's entry set (1.2 step 6). Not read: the order in which that registry holds the Nether, the End and data-pack stems (inferred: load order). CobolCraft decision: overworld, Nether, End.
3. **Integrated server pause.** The `pause-when-empty-seconds` property is a dedicated-server property; the integrated server's behaviour was not read. The status refresh interval constant (`STATUS_EXPIRE_TIME_NANOS`) was not read.
4. **Root wrapper keys of saved-data files** (`world_clocks.dat`, `game_rules.dat`, `weather.dat`, `world_border.dat`): the field names inside are read; the wrapper (for example whether the payload is under a `data` key and where `DataVersion` sits) was not, and the path of each dimension's `world_border.dat` relative to the dimension folder is inferred from the file fix.
5. **Weather in custom dimensions.** Every weather-capable level advances the shared timers; vanilla has exactly one such dimension. Whether the Nether-like or End-like data-pack dimensions with sky light and no ceiling are intended to double the speed was not examined.
6. **`FireBlock` ignition formula** and `FireBlock.isNearRain`, `Entity.isInRain`, `FarmlandBlock.randomTick` rain effects: belong to RS11 (GAP-10b); only their use of the weather and of `difficulty id x 7` is recorded here.
7. **Death respawn at the world spawn.** Whether `PlayerList.respawn` runs `PlayerSpawnFinder.findSpawn` (and so applies `respawn_radius`) when the player's own respawn config is missing was not read; 17 §4.10 only says it uses `createDefault` and the default respawn data.
8. **Noise spawn finder dependencies.** The evaluation of the five `spawn_target` density functions at the aligned point `(qx, 0, qz)` relies on the density-function machinery of 10 §6 (shifted noise and the six climate functions); whether the noise-router caches used by `enableCaches` change any value (they should not) was not tested.
9. **`noCollisionNoLiquid` flag.** The boolean passed to `noCollision(entity, box, flag)` was inferred to mean "liquids count as collisions" from the helper's name; the block-collision routine that interprets it was not read.
10. **`Monster.isPreventingPlayerRest`** (it affects sleeping: the NOT_SAFE branch of 5.2; candidate for a follow-up round) (the NOT_SAFE test) and the per-mob rules were not read here (20 for the mobs).
11. **Beehive rule gate.** `BeehiveBlock.playerWillDestroy` is gated by `block_drops` and a non-creative player; what it then does to bees and honey was not read in this round.
12. **Bed types.** Which block classes use `straw_bed_rule` instead of `bed_rule` and what `destroyOnUse` and `destroyOnLeave` do exactly (explosion size, replacing the block) were not read; only the rule fields and `AbstractBedBlock` were.
13. **Hardcore mode.** The stored difficulty is forced to HARD; the death handling of hardcore worlds (spectator, kick) was not read.
14. **`global_sound_events` event list.** The events sent through `globalLevelEvent` (wither spawn, dragon death, portal sounds) were not enumerated.
15. **Fractional clock rate and the partial tick.** The server samples timelines at the integer total; whether any other server code uses `partialTick` was not checked (the Set Time packet carries it for clients, 12).
16. **`ClipContext$Block` portal shape.** The exact effect on interaction raycasts of treating a nether portal as a full block when `players_nether_portal_default_delay` is 0 was read at the shape level only.
17. **Spawn protection default radius.** The property default 16 was read in `DedicatedServerProperties`; the full `server.properties` set is outside the artifact (design GAP-22).
18. **`AbstractArrow.setBaseDamageFromMob` and `RangedAttackMob.rangedAttackUncertainty`** difficulty terms and the other sites in 9.3 whose numbers were not read; 20 and 21 hold the mob-side values where read.
19. **Weather attribute layers (3.6).** Which environment attributes carry rain and thunder layers is held in 12 §3.5 and was not re-enumerated here.
