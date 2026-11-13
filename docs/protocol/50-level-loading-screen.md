# 50. Level-loading screen: spawn-area preparation, chunk-status grid and the join wait

| Item | Value |
|---|---|
| Covers | (1) The one screen the 26.3 client shows while a world is created, opened, joined or respawned into: texts, layout, background per reason, the chunk-status grid (size, colours, order), the progress bar and what closes it. (2) The server-side preparation of the spawn area (how many chunks, how the percentage is computed). (3) The client wait after Login or Respawn: Game Event 13 `LEVEL_CHUNKS_LOAD_START`, the Player Loaded packet, the readiness conditions and their timeouts. (4) The ten chunk statuses of 26.3 and how they map to the generation pipeline. |
| Source artifact | `minecraft-26.3-client.jar`, version 26.3, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution; the texts come from `assets/minecraft/lang/en_us.json` of the same jar (six keys read, see section 1) |
| Conventions | Class and method names in backticks say where a fact was read; they are provenance, not design. Colours are `#rrggbb` or `#aarrggbb` (ARGB ints are also given). "GUI pixel" and the GUI scale are as in 12 §5.1: x right, y down, origin at the top-left, guiW and guiH are the scaled window size. "Tick" is a 20 Hz client tick unless a row says "ms". Values marked "(inferred)" were deduced; unread items are in section 10. No value was taken from memory of other versions. |
| Related | 05c (Player Loaded 0x2C and "Minimum required serverbound traffic": the server-side 60-tick timer), 05a (Game Event table, value 13), 33 §6.4 (join packet sequence, world spawn) and 09 §3.2 "Join sequence" (the packet order of Login, Game Event 13 and the chunk batches; documented there, not re-read from the server join code in this round), 39 (respawn and dimension change packets), 12 §5.1 and §5.9 (GUI scale, fill helpers, screen backgrounds), 06 (chunk packets), 13 §7 (options) |

## 0. What exists in 26.3 (summary)

| Question | Answer in 26.3 |
|---|---|
| Is there a screen titled "Preparing spawn area: N%"? | **No.** The key `menu.preparingSpawn` ("Preparing spawn area: %s%%") exists, but its only use is a line in the **server log** (`LoggingLevelLoadListener`, section 5.5). No screen draws it. |
| What screen is shown while a single-player world is created or opened? | The same class as for multiplayer: `LevelLoadingScreen`. Text `multiplayer.downloadingTerrain` = "Loading terrain...", a chunk-status grid and a progress bar (section 2). It is opened by `Minecraft.doWorldLoad` before the integrated server starts. There is no separate "receiving level" screen class in the jar (checked with `unzip -Z1`). |
| Does the screen print the percentage? | **No** (the bar only). The percentage text `loading.progress` ("%s%%") is used only for the narrator (section 2.8). |
| Can the screen be cancelled? | **No.** `shouldCloseOnEsc` returns false, the screen has no widgets, and the only close path is the ready condition of section 7. |
| Chunks that must be ready before the player is dropped in | Single player and multiplayer alike ((inferred) from 5.3 and 5.4: the integrated server serves the local client through the normal login and configuration phases, where `PrepareSpawnTask` runs; a remote server's use of the same task was not separately read): a **7 × 7 square (radius 3 chunks, 49 chunks)** around the spawn chunk, each at full status (section 5). |
| Is there a chunk-status grid? | **Yes**, in single player only: a square of (2R + 1)² cells, R = 17 chunks, 2 × 2 GUI pixels per cell, no spacing, centred on the screen centre (section 2.5). Multiplayer shows neither grid nor bar. |
| Multiplayer wait screen | The same `LevelLoadingScreen` without grid or bar: the text "Loading terrain..." only (section 2.3, 7). |
| Relationship of Game Event 13 and Player Loaded | Event 13 starts the client's "wait for the player's chunk" phase; Player Loaded is sent when that phase ends (section 7). |

## 1. Inventory of what was read

Classes: `LevelLoadingScreen` (and `$Reason`), `LevelLoadTracker` (and `$ClientState`, `$WaitingForServer`, `$WaitingForPlayerChunk`,
`$ClientLevelReady`), `LevelLoadListener` (and `$Stage`), `LevelLoadProgressTracker`, `LoggingLevelLoadListener`, `ChunkLoadStatusView`
(implemented anonymously in `MinecraftServer.createChunkLoadStatusView`), `ChunkLoadCounter`, `PrepareSpawnTask` (and `$Preparing`),
`MinecraftServer` (`prepareLevels`, `setInitialSpawn`), `Minecraft.doWorldLoad`, `WorldOpenFlows`, `ClientPacketListener` (login, respawn, game
event, tick, `notifyPlayerLoaded`), `ClientboundGameEventPacket`, `LevelExtractor`, `LevelRenderer` (`isSectionCompiledAndVisible`),
`SectionRenderDispatcher$RenderSection.getVisibility`, `ChunkStatus`, `ChunkPyramid`, `ChunkStep` and `ChunkStep$Builder`, `ChunkDependencies`,
`ChunkLevel`, `ChunkMap.allChunksWithAtLeastStatus`, `ServerChunkCache.addTicketAndLoadWithRadius`, `TicketStorage`, `Screen` (backgrounds),
`GuiGraphicsExtractor` (`centeredText`, `text`), `ARGB.opaque`, `Hud`, `LocalPlayer`, `MusicManager`.

Language keys (all `en_us.json`; nothing else was needed):

| Key | English text | Used by |
|---|---|---|
| `multiplayer.downloadingTerrain` | `Loading terrain...` (three ASCII dots) | The loading screen's only visible text |
| `loading.progress` | `%s%%` | Narrator text of the loading screen (the argument is an integer) |
| `narrator.ready_to_play` | `Ready to play` | Narrator message when the screen closes |
| `menu.preparingSpawn` | `Preparing spawn area: %s%%` | The server log line only (5.5) |
| `menu.working` | `Working...` | `ProgressScreen`, the screen `disconnectWithProgressScreen` opens before the world load starts (Open question 5) |
| `createWorld.preparing` | `Preparing for world creation...` | `CreateWorldScreen` (before the load; Open question 5) |

## 2. The screen (`LevelLoadingScreen`)

### 2.1 Lifetime, input, side effects

- **Opened** (a) for a local world: `Minecraft.doWorldLoad` calls `disconnectWithProgressScreen`, creates a `LevelLoadTracker`, creates the screen with reason `OTHER` and
  shows it **before** the integrated server is spun up; (b) on Login: `ClientPacketListener` (login handling) calls `startWaitingForNewLevel(..., OTHER)`; (c) on every Respawn
  packet (dimension change or not): `startWaitingForNewLevel(..., reason)` with the reason of 2.4. If the current screen already is a `LevelLoadingScreen`, the screen object is
  kept and only receives the new tracker and reason (`update`), so its smoothed progress value is **not** reset; otherwise the chat input is preserved and a new screen replaces the
  current one.
- **Closed** by its own `tick`: when `tracker.isLevelReady()` is true it calls `onClose` (narrator "Ready to play", then the normal screen close). Conditions: section 7.
- **Cancel / Esc**: not possible (`shouldCloseOnEsc` = false; no widgets; no cancel button).
- **Pause**: `isPauseScreen` = false.
- While the screen is the current screen: the HUD is not drawn (`Hud` returns early), the music timer does not count down (`MusicManager`), and the local player's portal-confusion handling is skipped (`LocalPlayer`).
- **Tick rate of the screen**: once per client tick; additionally `doWorldLoad` ticks it itself, in its wait loop, together with a frame render, until the integrated server reports ready and no overlay is up. The loop waits at most `1 s / 60` between iterations (about 60 iterations per second, inferred, Open question 8).

### 2.2 Inputs the screen reads each frame

| Input | Meaning |
|---|---|
| `statusView` | Grid source: `null` for multiplayer, respawn and any tracker without a view; set for a local world (section 2.5). |
| `hasProgress` | True once the server-side listener has received a `start` call for **any** stage (section 4). False for multiplayer and respawn trackers (they never receive one). |
| `serverProgress` | Float 0..1, section 4. |
| `smoothedProgress` | Screen field, starts at 0. Each screen tick: `smoothed += (serverProgress - smoothed) * 0.2`. With a constant target p the value after k ticks is p × (1 − 0.8^k): 36 % of the gap after 2 ticks, 67 % after 5, 89 % after 10, 99 % after 20. |
| `reason` | `NETHER_PORTAL`, `END_PORTAL` or `OTHER` (2.4). |

### 2.3 Layout

Let cx = floor(guiW / 2) and cy = floor(guiH / 2) (integer division of the scaled window size). Everything is drawn in this order: background (2.4), the grid (if any), the text, the bar (if any).

| Case | Grid | Text top y | Bar |
|---|---|---|---|
| `statusView` present (local world) | yes, centred on (cx, cy) | y_t = cy − 2R − 27 (R = grid radius, 9 = font line height, 3 × 9 = 27) | if `hasProgress` |
| no `statusView` (multiplayer, respawn) | no | y_t = cy − 50 | if `hasProgress` (never true here) |

- **Text**: "Loading terrain..." (`multiplayer.downloadingTerrain`), centred horizontally on x = cx (the left edge is cx − floor(width / 2), `centeredText`), top of the glyph row at y_t, colour `#ffffffff` (the int −1) **with shadow**. Font: the default font (12 §5.10).
- **Bar** (`drawProgressBar`), only if `hasProgress`: x = cx − 100, y = y_t + 9 + 3 = y_t + 12, width 200, height 2.
  1. Background rectangle (x, y) to (x + 200, y + 2) in `#ff000000` (int −16777216).
  2. Fill rectangle from (x, y) to (x + round(smoothedProgress × 200), y + 2) in `#ff00ff00` (int −16711936). `round` is `Math.round` of a float (half up). No border, no text on the bar.
- The grid cell size is 2 and the cell spacing is 0 (the arguments `extractChunksForRendering(g, cx, cy, 2, 0, view)`).

### 2.4 Background by reason (`extractBackground`)

| Reason | Background |
|---|---|
| `OTHER` | (Vanilla.) The title-screen **panorama** (the same renderer the title screen uses, full GUI size; not read further, Open question 6), then, if the option `menuBackgroundBlurriness` (13 §7) is ≥ 1, a blur of everything drawn so far, then the standard menu-background tile (12 §5.9: a 32 × 32 texture tiled over the screen): `textures/gui/menu_background.png` when the client has **no level** at that moment, else `textures/gui/inworld_menu_background.png` (80 % alpha in the built-in pack, `../design/builtin-ui-art.md`). In a local-world load the first frames probably have no level (the world load first disconnects any previous session; inferred), later frames (after Login) have one. |
| `NETHER_PORTAL` | The block-atlas sprite that is the particle sprite of the default state of the Nether portal block (`block/nether_portal`, animated) stretched over the full GUI rectangle (0, 0, guiW, guiH), opaque textured-background pipeline. |
| `END_PORTAL` | A full-screen rectangle (0, 0, width, height) drawn with the End-portal pipeline using the two textures `textures/environment/end_sky.png` and `textures/entity/end_portal/end_portal.png` (the same look as the End portal block; shader details not read, Open question 6). |

**Minimal client (a design choice, not vanilla behaviour):** a client may draw only the 12 §5.9 menu-background tile (no panorama, no blur) for `OTHER`, and a flat dark fill or the same tile for the two portal reasons; nothing else on this screen depends on the background.

**Reason selection** (`ClientPacketListener`, login and respawn): Login always gives `OTHER`. For a Respawn packet the reason is computed from three inputs: whether the local player is dead or dying **at that moment**, the respawn packet's target dimension and the player's current dimension. If the player is dead or dying: `OTHER`. Otherwise: if the target or the current dimension is the Nether, `NETHER_PORTAL`; else if the target or the current dimension is the End, `END_PORTAL`; else `OTHER`. The Nether test comes first, and "target or current" means a respawn that stays inside the Nether also gives `NETHER_PORTAL`.

### 2.5 The chunk-status grid (`extractChunksForRendering`)

Present only when the tracker has a status view, which only a local-world load creates (`Minecraft.doWorldLoad`: view radius R, section 5.1).

Parameters: cell size c = 2, spacing s = 0, n = 2R + 1 cells per side, stride t = c + s = 2.

- Total side length L = n × t − s = 2n (70 for R = 17).
- Top-left corner: x0 = cx − floor(L / 2), y0 = cy − floor(L / 2) (integer divisions).
- Cell (i, j), 0 ≤ i, j < n, is the half-open rectangle [x0 + i·t, x0 + i·t + c) × [y0 + j·t, y0 + j·t + c). With c = t there are no gaps and no border; the grid is a solid square.
- Loops: i is the outer loop (columns, left to right), j the inner (rows, top to bottom). The cells are disjoint, so order does not matter.
- Chunk of a cell: the view is centred on the "focus" chunk (fx, fz) set by the server side (section 5.4); cell (i, j) shows chunk (fx + i − R, fz + j − R). Screen x is chunk x (east to the right), screen y is chunk z (south downwards). The centre cell (R, R) is the focus chunk.
- Colour of a cell: the colour of the chunk's **latest** status (`ChunkMap.getLatestStatus`) from the table of 2.6, made opaque (`ARGB.opaque`: OR with `#ff000000`). A chunk with no status (no chunk holder, the view's chunk map not yet set, or a null result) gives `#ff000000` (black): the colour map's default value is 0 and `opaque(0)` = `#ff000000`.
- Order of drawing relative to other things: after the background, before the text.
- **Debug red square** (the F3 debug entry `visualize_chunks_on_server` is enabled): before the cells, a rectangle (cx − h, cy − h) to (cx + h, cy + h) with h = floor(t / 2) + 1 = 2 in `#ffff0000` (int −65536). For c = 2, s = 0 the surrounding cells cover it completely, so it is not visible on this screen. The same routine is also used by the F3 overlay (`DebugScreenOverlay`, with cell size 4 and spacing 1, Open question 7).
- Grid size follows the radius only: n = 2R + 1. R is fixed at 17 (section 5.1), so the grid is 35 × 35 cells, 70 × 70 GUI pixels at any window size; at GUI scale 4 it is 280 × 280 framebuffer pixels.

### 2.6 Colours per chunk status

The client keeps one colour per status. The ten statuses of 26.3 are exactly these (section 3), in generation order. All values are ARGB after `opaque` (alpha `ff`).

| # | Status | RGB int (as in the jar) | `#rrggbb` | Notes |
|---|---|---|---|---|
| 0 | `EMPTY` | 5526612 | `#545454` | new, not generated |
| 1 | `STRUCTURE_STARTS` | 10066329 | `#999999` | |
| 2 | `STRUCTURE_REFERENCES` | 6250897 | `#5f6191` | |
| 3 | `BIOMES` | 8434258 | `#80b252` | |
| 4 | `TERRAIN` | 3159410 | `#303572` | |
| 5 | `FEATURES` | 2213376 | `#21c600` | |
| 6 | `INITIALIZE_LIGHT` | 13421772 | `#cccccc` | |
| 7 | `LIGHT` | 16769184 | `#ffe0a0` | |
| 8 | `SPAWN` | 15884384 | `#f26060` | |
| 9 | `FULL` | 16777215 | `#ffffff` | finished chunk |
| – | no status / unknown | (default 0) | `#000000` | black |

Every one of the ten statuses has an entry, so there is no status that falls back to black while a chunk exists.

### 2.7 Worked example: layout at GUI size 480 × 270 (a 1920 × 1080 window at scale 4, 12 §5.1), local world, R = 17

- cx = 240, cy = 135; n = 35; L = 70; x0 = 240 − 35 = 205; y0 = 135 − 35 = 100.
- The grid covers x 205 to 275 and y 100 to 170 (half-open). Cell (i, j) is [205 + 2i, 207 + 2i) × [100 + 2j, 102 + 2j). The focus chunk is cell (17, 17): x 239 to 241, y 134 to 136. The chunk 3 east and 2 north of the focus is cell (20, 15): x 245 to 247, y 130 to 132.
- y_t = 135 − 34 − 27 = 74. The bar: x 140 to 340, y 86 to 88. With smoothedProgress 0.5 the green part is x 140 to 240.
- Gap between the bar (bottom y = 88) and the grid (top y = 100): 12 GUI pixels.

Multiplayer (no grid): y_t = 135 − 50 = 85, text only.

### 2.8 Narration and the percentage text

`updateNarratedWidget` adds, only if `hasProgress`, the translatable `loading.progress` with the integer floor(serverProgress × 100) ("42%"). A narration is triggered on the first rendered frame (`lastNarration` starts at −1) and then whenever more than 2000 ms have passed since the previous one (`NARRATION_DELAY_MS`). `shouldNarrateNavigation` is false. On close the narrator says `narrator.ready_to_play` immediately. Nothing visible shows the number.

## 3. Statuses and the generation pipeline in 26.3

### 3.1 The status list

`ChunkStatus` declares exactly ten statuses in this order (index 0 to 9): `EMPTY`, `STRUCTURE_STARTS`, `STRUCTURE_REFERENCES`, `BIOMES`, `TERRAIN`, `FEATURES`, `INITIALIZE_LIGHT`, `LIGHT`, `SPAWN`, `FULL`. The generation pyramid (`ChunkPyramid.GENERATION_PYRAMID`) has exactly one step for each. There is no separate `NOISE`, `SURFACE`, `CARVERS` or `LIQUID_CARVERS` status and no separate `HEIGHTMAPS` status in 26.3: the field list of `ChunkStatus` contains none, and the colour table above covers all ten. The surface, carver and noise-fill work therefore has to happen inside the `TERRAIN` step (inferred: `ChunkStatusTasks` calls only six `ChunkGenerator` methods, `createStructures`, `createReferences`, `createBiomes`, `buildTerrain`, `applyBiomeDecoration` and `spawnOriginalMobs`, and the `TERRAIN` step calls `buildTerrain` and then primes the heightmaps). The loading pyramid (used for chunks read from disk) has the same ten steps; its steps were not decoded.

### 3.2 What each status does (task of the step)

| Status | Step task (`ChunkStatusTasks`) | What it means for the pipeline docs |
|---|---|---|
| `EMPTY` | none | a new proto-chunk exists |
| `STRUCTURE_STARTS` | `generateStructureStarts` (`ChunkGenerator.createStructures`) | structure start positions: 10 §stage order, 36 |
| `STRUCTURE_REFERENCES` | `generateStructureReferences` (`createReferences`) | each chunk learns which nearby starts reach it |
| `BIOMES` | `generateBiomes` (`createBiomes`, with a `Blender`) | biome palette per section: 10 |
| `TERRAIN` | `buildTerrain` (`ChunkGenerator.buildTerrain`) then heightmap priming | noise fill, aquifers, surface, carvers: 10, 11 |
| `FEATURES` | `generateFeatures` (`applyBiomeDecoration`, then border ticks) | decoration and structure pieces placed: 35, 36 |
| `INITIALIZE_LIGHT` | `initializeLight` (`initializeLightSources`, light engine `initializeLight`) | light-source seeding: 32 |
| `LIGHT` | `light` (light engine `lightChunk`) | light propagation: 32 |
| `SPAWN` | `generateSpawn` (`spawnOriginalMobs`) | initial mob spawns of the chunk (method name read, effect not traced): 18 |
| `FULL` | `full` (converts to the live level chunk, post-load work) | the chunk becomes a live level chunk (method names `full` and `postLoadProtoChunk` read; body not traced): playable |

### 3.3 Step dependencies (`ChunkPyramid`, generation pyramid)

Each step needs its **parent** (the previous status) on the chunk itself and may require other statuses on neighbours within a Chebyshev radius. Read from the ten step definitions (the lambda numbering was matched to the status order through the bootstrap method table):

| Step | Extra requirement (status at radius) | Block-state write radius (`-1` = none given) |
|---|---|---|
| `EMPTY` | none | −1 |
| `STRUCTURE_STARTS` | none | −1 |
| `STRUCTURE_REFERENCES` | `STRUCTURE_STARTS` at 8 | −1 |
| `BIOMES` | `STRUCTURE_STARTS` at 8 | −1 |
| `TERRAIN` | `STRUCTURE_STARTS` at 8, `BIOMES` at 1 | 0 |
| `FEATURES` | `STRUCTURE_STARTS` at 8, `TERRAIN` at 1 | 1 |
| `INITIALIZE_LIGHT` | none | −1 |
| `LIGHT` | `INITIALIZE_LIGHT` at 1 | −1 |
| `SPAWN` | `BIOMES` at 1 | −1 |
| `FULL` | none | −1 |

**Accumulated dependencies of `FULL`** (the status each ring around a chunk that is to become `FULL` must reach; computed by evaluating the builder's accumulation rule over the table above: a step's list is the element-wise maximum of its own requirements and its parent's accumulated list shifted outwards by the largest radius at which the step itself requires the parent's status or later): index = Chebyshev distance d from the chunk, value = required status:

| d | 0 | 1 | 2 | 3 | 4 to 11 |
|---|---|---|---|---|---|
| status | `SPAWN` (the chunk itself ends at `FULL`) | `INITIALIZE_LIGHT` | `TERRAIN` | `BIOMES` | `STRUCTURE_STARTS` |

So `ChunkLevel.RADIUS_AROUND_FULL_CHUNK` = **11** (the list has 12 entries; the value is `size − 1` and is computed in a static initialiser, not stored as a literal; derived here) and `MAX_LEVEL` = 33 + 11 = **44**. The chunk levels are: full 33, block ticking 32, entity ticking 31 (`ChunkLevel`).

### 3.4 Which status each ring shows at rest (after the spawn load of section 5) (inferred, Open question 1)

The spawn load adds a ticket with level 33 − 3 = **30** at the focus chunk. The level of a chunk at Chebyshev distance k from the focus is 30 + k (the +1 per ring rule is inferred, Open question 1). The status the generator drives a chunk to is: `FULL` if level ≤ 33, else the entry at index (level − 33) of the table above, and nothing (not loaded) if level > 44.

| Distance k from the focus | Level | Final status | Cells (colour) |
|---|---|---|---|
| 0 to 3 | 30 to 33 | `FULL` | 7 × 7 = 49, white |
| 4 | 34 | `INITIALIZE_LIGHT` | ring of 9 × 9 − 49 = 32 cells, `#cccccc` |
| 5 | 35 | `TERRAIN` | ring of 11 × 11 − 81 = 40, `#303572` |
| 6 | 36 | `BIOMES` | ring of 13 × 13 − 121 = 48, `#80b252` |
| 7 to 14 | 37 to 44 | `STRUCTURE_STARTS` | rings up to 29 × 29, `#999999` |
| ≥ 15 | ≥ 45 | not loaded | black (the outer three rings of the R = 17 grid) |

While chunks are still being generated each cell shows the status the chunk has reached so far, passing through the colours of 2.6 in order (a new chunk starts at `EMPTY` grey). `STRUCTURE_REFERENCES`, `FEATURES`, `LIGHT` and `SPAWN` are therefore seen only transiently (they are never the final status of a ring at rest).

## 4. Progress model (`LevelLoadProgressTracker`)

The tracker used by the screen is constructed with `includePlayerChunks = true` (the server's own logging tracker is also constructed that way for a local world; the dedicated server uses false and never draws anything).

### 4.1 Stages

`LevelLoadListener.Stage` has four members: `START_SERVER`, `PREPARE_GLOBAL_SPAWN`, `LOAD_INITIAL_CHUNKS`, `LOAD_PLAYER_CHUNKS`. `START_SERVER` is **never started** by any class of the jar (it only appears in the enum). Only two stages contribute to the percentage: `LOAD_INITIAL_CHUNKS` and (because `includePlayerChunks` is true) `LOAD_PLAYER_CHUNKS`. `PREPARE_GLOBAL_SPAWN` does not contribute but still turns `hasProgress` on (the screen's `serverStage` is set on **every** `start`), so the bar appears (at 0) as soon as the first `start` of any stage arrives.

### 4.2 Weights and formula

Constants: `PREPARE_SERVER_WEIGHT` = 10, `EXPECTED_PLAYER_CHUNKS` = 7² = **49** (a constant, not the real chunk count).

| Event | Effect |
|---|---|
| `start(LOAD_INITIAL_CHUNKS, n)` | totalWeight = 10 + n + 49. A segment of weight 10 is begun and finished at once (finalizedWeight = 10), then a segment of weight n begins with fraction 0. |
| `update(LOAD_INITIAL_CHUNKS or LOAD_PLAYER_CHUNKS, ready, total)` | segmentFraction = 0 if total = 0, else ready / total (float division). |
| `finish(stage)` | finalizedWeight += segmentWeight; segmentWeight = 0. |
| `start(LOAD_PLAYER_CHUNKS, ·)` | a segment of weight 49 begins, fraction 0 (the count argument is ignored). |
| any change | progress = (finalizedWeight + segmentFraction × segmentWeight) / totalWeight as a 32-bit float; 0 while totalWeight = 0. |

**General form.** With f1 = ready / total of the initial-chunk stage (0 if total is 0) and f2 = ready / total of the player-chunk stage (0 if total is 0), and n the initial-chunk count reported at `start`: progress = (10 + n × f1 + 49 × f2) / (59 + n) while each stage is in progress (f1 = 1 once it has finished, f2 = 0 before it starts); at the final `finish` progress is exactly 1. With n = 0 and the player stage running: percent = floor((10 + 49 × ready / total) / 59 × 100).

**What to report when the counted total is not 49:** report the real counted ready and total; the fraction is ready / total and the player segment still weighs 49 (so progress still ends at 1.0). The count 49 is never reported by the screen; it is only the weight.

Because the segment weights are fixed, a world whose real counts differ still reaches exactly 1.0 at the last `finish`. Updates for untracked stages are ignored.

### 4.3 Worked example (a world with no persistent chunks, n = 0)

| Moment | finalized | segment | progress | Bar target (200 px) |
|---|---|---|---|---|
| before `LOAD_INITIAL_CHUNKS` starts | 0 | 0 | 0 (totalWeight 0) | 0 |
| after `start(LOAD_INITIAL_CHUNKS, 0)` | 10 | 0 | 10 / 59 = 0.1695 | 33.9 |
| after its `finish` | 10 | 0 | 0.1695 | 33.9 |
| `start(LOAD_PLAYER_CHUNKS)` | 10 | 49 | 0.1695 | 33.9 |
| `update(…, 25, 49)` | 10 | 49 | (10 + 25) / 59 = 0.5932 (59 %) | 118.6 |
| `update(…, 49, 49)` | 10 | 49 | 1.0 | 200 |
| `finish(LOAD_PLAYER_CHUNKS)` | 59 | 0 | 59 / 59 = 1.0 | 200 |

If fewer than 49 chunks are counted (some already loaded, section 5.2), `update` still divides by the real total and the segment still ends at weight 49. If the counted total is 0, the fraction stays 0 until `finish` and the bar then jumps to 1.0.

## 5. The spawn area on the server

### 5.1 Radius and count

| Item | Value | Source |
|---|---|---|
| Spawn-area load radius | **3 chunks** (`PREPARE_CHUNK_RADIUS`) | `PrepareSpawnTask` |
| Square side | 2 × 3 + 1 = 7; total **49** chunks | `ServerChunkCache.getChunkRangeFuture` iterates (2r + 1)² chunks; `EXPECTED_PLAYER_CHUNKS` = 7² |
| Required status | `FULL` for every chunk of the square | the status function of `addTicketAndLoadWithRadius` always returns `FULL` |
| Ticket | type `PLAYER_SPAWN`, level 33 − 3 = 30, at the focus chunk | `TicketStorage.addTicketWithRadius` |
| Focus chunk | the chunk containing the player's spawn position (the saved position of the player data if any, else the world respawn data) | `PrepareSpawnTask$Preparing.tick` |
| Grid radius R (view only) | max(5, 3) + 11 + 1 = **17**: the literal 5, the spawn radius 3 (inferred to be the same constant), the pyramid radius 11 of 3.3, and 1 | `Minecraft.doWorldLoad` |

The grid is wider than the loaded square on purpose: it also shows the 11 rings of lower-status chunks the pyramid needs (3.4), plus a margin of 3 black rings.

### 5.2 How the count and the done count are measured (`ChunkLoadCounter.track`)

`track(level, action)`: (1) run the level's pending ticket updates; (2) record the set of chunks whose holder already has a ticket level ≤ 33 (that is, chunks that already are, or are already scheduled to become, `FULL`); (3) run the action (the ticket addition); (4) run the ticket updates again; (5) every chunk holder with ticket level ≤ 33 that is **not** in the recorded set is added to a pending list and counted in `totalChunks`. `pendingChunks()` removes every holder whose latest status is exactly `FULL` and returns the remaining size; `readyChunks()` = total − pending.

So the counted total is 49 minus the chunks that were already scheduled full before; in a fresh start it is 49 (inferred from the geometry: level 30 + k ≤ 33 gives the 7 × 7 square).

### 5.3 Percent derivation (what the displayed bar and the log show)

- The percentage is **not** done / total of the 49 chunks alone. It is progress × 100 from section 4.2: the 10-weight "prepare server" block and the initial-chunks block count first, then the player chunks scale the last 49 of (59 + n) weight units. With n = 0: percent = floor((10 + 49 × ready / total) / 59 × 100); for n > 0 use the general form of 4.2.
- Rounding: the log line and the narrator use `Mth.floor(progress × 100.0f)` (floor, float arithmetic): 99.9 gives 99; 100 only when progress is exactly 1.0. The bar uses `Math.round(smoothed × 200)`.
- `PrepareSpawnTask$Preparing.tick` (run once per tick of the configuration task list while the player is in the configuration phase; inferred, Open question 8) does, in this order: wait until the spawn position future is done; the first time, add the ticket through `track`, call `start(LOAD_PLAYER_CHUNKS, total)` and `updateFocus(dimension, focus chunk)`; every call, `update(LOAD_PLAYER_CHUNKS, ready, total)`; when the chunk-range future is done, `finish(LOAD_PLAYER_CHUNKS)` and become ready. The player is then created in the level (`spawnPlayer`) and the play-phase packets follow (33 §6.4, "Join packet sequence").

### 5.4 The two earlier stages (single-player start, `MinecraftServer`)

- **`PREPARE_GLOBAL_SPAWN`** (`setInitialSpawn`, only for a level that has not been initialised yet, i.e. a new world): `start(…, 0)`, `updateFocus(dimension, origin chunk of the generator)`, the world-spawn search, `finish`. The progress tracker ignores this stage; the grid focus is the generator origin chunk meanwhile. The spawn search itself is described with the world spawn (33); its chunk-load pattern was not traced (Open question 9).
- **`LOAD_INITIAL_CHUNKS`** (`prepareLevels`): for every level, `track` is run on an action that re-activates the saved (deactivated) tickets of that level; `start(LOAD_INITIAL_CHUNKS, total)`; then every iteration `update(ready, total)`, a wait of 10 ms (`PREPARE_LEVELS_DEFAULT_DELAY_NANOS` = 10 × 1 000 000 ns) until the next server tick, and a check of `pendingChunks() > 0`; then `finish`. 26.3 has no always-loaded spawn region: nothing else is requested here, so n is normally 0 unless a level has forced or persistent tickets (n and its flags: Open question 10). Before this stage the focus is the chunk of the respawn-data position of the overworld data (`selectLevelLoadFocusPos`, with that position's dimension key).
- The server is "ready" after `prepareLevels`; `doWorldLoad`'s loop ends and the client connects through an in-memory channel and logs in like a remote client. The tracker object is handed to the connection through the cookie, so the same tracker (and the same screen) continues into the login: `startWaitingForNewLevel` calls `startClientLoad` on the same tracker, and the screen shows a full bar (progress 1.0) while the client waits (section 7).

### 5.5 Server log line (not a screen)

`LoggingLevelLoadListener` (the integrated server composes it with the screen's tracker; the dedicated server uses it alone): on each `update`, if more than 500 ms have passed since the next-log time, it advances the next-log time by 500 ms and logs one line whose text is the English `menu.preparingSpawn` with the floor percentage: `Preparing spawn area: 42%`. It also logs, at `start`: `Selecting global world spawn...` (`PREPARE_GLOBAL_SPAWN`), `Loading {} persistent chunks...` (`LOAD_INITIAL_CHUNKS`, count n) and `Loading {} chunks for player spawn...` (`LOAD_PLAYER_CHUNKS`, counted total), and `Time elapsed: {} ms` at the last `finish` (`LOAD_PLAYER_CHUNKS` when player chunks are included, else `LOAD_INITIAL_CHUNKS`); after that it ignores all calls. This is the only place the "Preparing spawn area" text is used.

## 6. Summary of single-player order (what the player sees)

1. World list or Create World confirms: `Minecraft.doWorldLoad(..., fresh)`; the tracker gets a close delay of **500 ms** if `fresh` is true (new world: `WorldOpenFlows.createFreshLevel` and `createLevelFromExistingSettings`) and **0** otherwise (opening an existing world: `openWorldDoLoad`). The screen opens at once: panorama background, grid all black (no chunk map yet), text at y_t, no bar (`hasProgress` false).
2. Server start: the bar appears at the first `start` (new world: `PREPARE_GLOBAL_SPAWN`; existing world: `LOAD_INITIAL_CHUNKS`); the grid focus moves; chunk colours rise through the table of 2.6; `LOAD_INITIAL_CHUNKS` finishes (bar at 10 / 59 when n = 0). The server is then ready and `doWorldLoad`'s wait loop ends.
3. The client connects through an in-memory channel and logs in like a remote client (02). The tracker travels in the connection cookie.
4. Configuration phase: `PrepareSpawnTask` runs (5.3) and the bar goes from 10/59 to 100 %; the grid shows the 7 × 7 white square with its status rings (3.4).
5. Play Login is handled: `startWaitingForNewLevel` calls `startClientLoad` on the same tracker; the screen object is kept (progress 1.0, bar full); from here section 7 applies. The `OTHER` background now uses the in-world menu tile because the client has a level.
6. Game Event 13, chunk batches, the camera section is meshed, Player Loaded is sent, the screen closes (section 7).

## 7. The client wait after Login or Respawn (`LevelLoadTracker` client states)

### 7.1 State machine

| State | Entered | Leaves when |
|---|---|---|
| none (no tracker) | start | – |
| `WaitingForServer` | `startClientLoad(player, level)`, called by `startWaitingForNewLevel` on Login and on every Respawn; deadline `timeoutAfter` = now + **30 000 ms** (`CLIENT_WAIT_TIMEOUT_MS`, wall clock `Util.getMillis`) | `loadingPacketsReceived()` (below) moves to `WaitingForPlayerChunk` with the same deadline. Nothing else leaves this state: its tick does nothing and the deadline is **not** checked here. |
| `WaitingForPlayerChunk` | Game Event 13 received (below) | each tick, `isReady()`: see 7.2; when true the state becomes `ClientLevelReady(readyAt = now)` |
| `ClientLevelReady` | as above | `isLevelReady()` = (now ≥ readyAt + closeDelay) |

`loadingPacketsReceived()` is called from the game-event handler when the event type is `LEVEL_CHUNKS_LOAD_START` (**value 13**, verified in the type's registration order; the event's float value is ignored) and a tracker exists. If the packet never arrives the client stays in `WaitingForServer` forever (no timeout applies; the server's own 60-tick timer, 05c, concerns only the server's treatment of the player). A packet that arrives in any other state changes nothing.

### 7.2 `isReady()` of `WaitingForPlayerChunk` (checked in this order, each client tick)

1. If the current time is **after** `timeoutAfter` (30 s counted from the Login or Respawn, not from event 13): log a warning ("Timed out while waiting for the client to load chunks, letting the player into the world anyway") and return true.
2. Let p be the block position of the main camera (eye position). If p.y is outside the level's build height (min y to max y of the dimension, `isOutsideBuildHeight`), or the local player is a spectator, or the local player is not alive: return true.
3. Otherwise return the `playerSectionReady` flag (false until set).

**The flag** is set by a callback that exists only while the state is `WaitingForPlayerChunk` (otherwise `getPlayerCompiledSectionCallback` returns null). Each rendered frame the level extractor stores the callback in the render state; after the section compile and upload steps of that frame the renderer runs it when `isSectionCompiledAndVisible(camera block position, fadeMillis)` is true: the render section (16 × 16 × 16 block cell) that contains the camera block position (a) exists in the view area, (b) has a mesh that is not the "uncompiled" placeholder, and (c) has visibility ≥ **0.3**, where visibility = 1 if (now − upload time of the mesh) ≥ fadeMillis, else (now − upload time) / fadeMillis. fadeMillis = `chunkSectionFadeInTime` option × 1000 (default 0.75 s = 750 ms, inferred from the constructor's argument order, Open question 4; value 0 gives visibility 1 immediately). With the default, the section must have been uploaded at least 0.3 × 750 = 225 ms ago.

The client therefore needs: the chunk data of the section around the camera (packets of 06), the neighbour data the mesher needs, and one finished mesh upload. A CobolCraft client with its own renderer may use its own equivalent ("the section under the player has a drawable mesh") and keep the 30 s timeout and the build-height, spectator and dead exceptions.

### 7.3 Player Loaded

Every client tick (`ClientPacketListener.tick`), if a tracker exists: `tickClientLoad()`; if `isLevelReady()` then `notifyPlayerLoaded()` and the listener's tracker field is cleared. `notifyPlayerLoaded` sends **Serverbound Player Loaded (0x2C)** (no fields, 05c) once, guarded by a "client loaded" flag which Login and every Respawn reset to false and the send sets to true. So Player Loaded goes out in the tick in which the level becomes ready **and** the close delay has elapsed (7.1): 0 ms after `readyAt` for multiplayer joins and respawns, 500 ms for a freshly created local world, 0 ms for an opened local world. Timeline for a normal join:

| Time | Event |
|---|---|
| t0 | Login handled: screen shown or updated, tracker in `WaitingForServer`, deadline t0 + 30 s, client-loaded flag false |
| t0 + δ | Game Event 13 arrives (the server sends it after Set Default Spawn Position and before the tick-rate update: order stated in 33 §6.4, not re-read from the server join code in this round; (inferred) for this document) → `WaitingForPlayerChunk` |
| t1 | the camera section is uploaded and visible ≥ 0.3 → flag set → at the next tick `ClientLevelReady(readyAt)` |
| t1 + closeDelay | `isLevelReady()` true: Player Loaded sent; the screen's tick closes the screen ("Ready to play") |

In the worst case (no chunk ever drawable) the screen closes and Player Loaded is sent at t0 + 30 s (plus up to one tick) after Game Event 13 has arrived. The tick-count limit of 60 ticks that the server applies when Player Loaded does not arrive (05c) is independent and is not a client condition: **the client has no tick-count timeout, only the 30 000 ms wall-clock one**.

### 7.4 Respawn and dimension change

Every Respawn packet resets the client-loaded flag and calls `startWaitingForNewLevel` (even if the dimension does not change). The tracker created for a respawn is a **new** tracker with close delay 0, no status view and no server progress (the one of the first join was cleared after ready), so the screen has no grid and no bar and draws the text at y_t = cy − 50; its background follows the reason of 2.4. The server sends Game Event 13 after Respawn as after Login (39, 09).

## 8. Implementer summary

Screen (client): background per 2.4; if the world is local, the grid of 2.5 with the colours of 2.6, the text of 2.3 above it, and the bar under the text; otherwise the text alone at cy − 50. Percentage is never printed. No cancel.

Server: radius-3 square of `FULL` chunks around the spawn chunk (49 chunks), the percent of 4.2 and 5.3, the status list of section 3 for any grid. **Recipe for a server that makes the spawn chunks synchronously:** report `start(LOAD_INITIAL_CHUNKS, 0)` (progress 0 to 10/59, bar about 17 %), then `finish`, then `start(LOAD_PLAYER_CHUNKS)`, `update(ready, total)` with whatever counts it has (for example once with 0 / 49 and once with 49 / 49) and `finish` (progress to 1.0); if everything completes in one step, the sequence 0, 10/59, 1.0 is enough. Progress never needs to be reported more often than the screen ticks (20 Hz). A server may report each stage with its counts at the granularity it has; the displayed colours then only need the statuses it really passes through (at minimum `EMPTY` and `FULL`).

Join wait: send Game Event 13 after Login or Respawn and before the first chunk batch (order in 33 §6.4 and 09 §3.2; for this document (inferred): the client code only requires that event 13 arrives, and that chunks arrive for the camera section); the client sends Player Loaded as in 7.3 and the server treats the player as loaded then (05c); a client that never sends Player Loaded costs 60 server ticks (05c).

## 9. Validation (checkable facts)

| # | Fact | Where |
|---|---|---|
| V1 | Ten statuses; colour ints 5526612, 10066329, 6250897, 8434258, 3159410, 2213376, 13421772, 16769184, 15884384, 16777215 in order | 2.6 |
| V2 | R = 17, n = 35, L = 70, y_t = cy − 61, bar at y_t + 12, 200 × 2, black `#ff000000` and green `#ff00ff00` | 2.3, 2.5 |
| V3 | Weights 10 + n + 49; 49 = 7²; progress 10/59 after the initial stage when n = 0 | 4 |
| V4 | Spawn radius 3 (49 chunks), ticket level 30, `FULL` required | 5.1 |
| V5 | RADIUS_AROUND_FULL_CHUNK = 11, MAX_LEVEL 44, ring statuses 3.4 | 3.3, 3.4 |
| V6 | Client deadline 30 000 ms, section visibility threshold 0.3, default fade 750 ms (inferred), close delay 500 ms (fresh worlds) or 0 | 7 |
| V7 | Game Event `LEVEL_CHUNKS_LOAD_START` = 13; Player Loaded id 0x2C = 44 (05c) | 7.1 |
| V8 | Smoothed progress factor 0.2 per tick; bar width round(s × 200) | 2.2, 2.3 |
| V9 | Log line `Preparing spawn area: N%` every 500 ms, N = floor(progress × 100) | 5.5 |

## 10. Open questions

1. **Ticket level propagation.** That a chunk at Chebyshev distance k from a ticket of level L has level L + k (and so the ring table of 3.4 and the count 49) was not read from `DistanceManager`/`ChunkTracker`; it is inferred from `EXPECTED_PLAYER_CHUNKS` = 7², the (2r + 1)² range loop and the level constants.
2. **`ChunkMap.getLatestStatus` for a missing holder.** Assumed to return null (drawn black); not read. Whether a chunk that is being generated reports its last completed status or its target status was not read.
3. **Empty sections and the camera section.** Whether a section containing only air gets a compiled mesh with an upload time (which the ready check of 7.2 needs), and `ViewArea.getRenderSectionAt`, were not read; the camera position used before the first frame after Login (stale values) was not traced.
4. **Default fade time.** 0.75 s for `chunkSectionFadeInTime` is inferred from the argument order of the option constructor (range 0 to 2, then 0.75), like the other defaults of 12 Open question 11; the `OptionInstance` field meanings were not decoded.
5. **Pre-load screens.** `ProgressScreen` ("Working...", opened by `disconnectWithProgressScreen` at the start of `doWorldLoad`; two centred text lines at y = 70 and 90 as far as read) and the "Preparing for world creation..." text of `CreateWorldScreen` were not traced further.
6. **Backgrounds.** The panorama renderer (rotation speed and timing), the blur (`blurBeforeThisStratum`) and the End-portal pipeline's look were not read; 14 lists the panorama faces. The Nether-portal sprite's frame animation was not read.
7. **F3 chunk visualisation.** `DebugScreenOverlay` calls the grid routine with cell size 4 and spacing 1; its centre, size and the default state of the `visualize_chunks_on_server` entry were not traced.
8. **Loop cadence.** The 60 Hz figure of the `doWorldLoad` wait loop (`managedBlock` to a deadline of `1 s / 60`) and the exact tick rate at which `ConfigurationTask.tick` (hence `PrepareSpawnTask$Preparing.tick`) is called were not traced; the screen tick outside `doWorldLoad` is assumed to be the normal 20 Hz screen tick.
9. **Global spawn search.** The chunk-load pattern of the world-spawn search under `PREPARE_GLOBAL_SPAWN` (and `SPAWN_SEARCH` tickets) was not traced; see 33 for the spawn position rules.
10. **Persistent tickets.** The flags that decide which tickets persist (`TicketType` registrations, `FLAG_PERSIST`) and hence n in `LOAD_INITIAL_CHUNKS` were not decoded; n is assumed 0 for a world with no forced chunks.
11. **Loading pyramid.** The ten steps of `ChunkPyramid.LOADING_PYRAMID` (chunks read from disk) were not decoded; only the generation pyramid was.
12. **`ChunkStatus` ordering API.** `getIndex`, `isOrAfter`, `max` are used as plain index order (the declaration order of 3.1), which the field order and the two pyramids support but the method bodies were not read.
