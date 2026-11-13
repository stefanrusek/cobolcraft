# Standard-world chunk generation in a worker process

Status: operator decision. Scope: the standard world type (`cobolcraft` type unchanged).

## Decision

Chunk generation of the standard pipeline runs outside the game loop, in worker processes that the game process
forks and talks to over pipes. The game loop (50 ms tick, rendering) only sends small requests, polls the pipes and
installs finished chunks. A worker thread was evaluated first and rejected, see Evidence.

## Evidence: why not a thread

A GnuCOBOL program shares its WORKING-STORAGE, the EXTERNAL records and the libcob call state (current module,
call parameters, the `-debug` frame stack) between all callers in the process. The build is fixed to
`-debug -fstatic-call`. Experiment: two threads (pthread) each call one COBOL entry 200000 times
(`scratchpad/thr/main.c`, `inc.cob`). Four of four runs aborted: three with `attempt to reference invalid memory
address (signal)`, one with `libcob: error: LINKAGE item L-OUT (size 4) too small in the caller (size 0)`. The
generator also shares the noise tables, memo tables and chunk job of the game process. Generation in a second
thread would need a second copy of the COBOL runtime state, which a process gives and a thread does not.

## Design

- C shim `cc_wk` (shim/src/cc_wk.c, shim-abi section 15): generic worker-process glue with no game logic.
  `cc_wk_spawn` forks and returns 0 in the child, a slot id in the parent; the parent reads the response pipe
  non-blocking, writes requests, stops a worker (graceful: close and wait; forced: kill and wait). The child closes every
  pipe end it inherited from other slots, so a worker sees end of file when the game process ends and exits.
- The child is a copy of the game process taken at the first dispatch of the open world: it holds the content tables,
  the block table, the world seed and settings exactly as the game process does, and shares no memory with it
  afterwards. It runs one COBOL program (GEN-WORKER-SERVE): read a request (dimension, chunk x, chunk z), run
  GEN-JOB-RUN-ALL (the atomic reference, the bytes that test_gen_golden pins), write marker-y and the 304640
  chunk bytes, repeat until end of file, then `_exit`. It never touches the window, GPU or sockets.
- Game side (core/src/gen-worker.cob): `GEN-WORKERS-CONFIG` sets the pool size (host option, default 0 = the existing
  in-tick stepped generation, so every existing test and host keeps its behaviour). Each tick GEN-QUEUE-TICK
  calls GEN-WORKERS-TICK: collect finished chunks (incremental non-blocking reads into a per-worker buffer), install
  them through WORLD-CHUNK-LOAD (GEN-STANDARD-INSTALL takes the finished buffer first), then give every idle worker the
  nearest queued standard chunk. One request per worker is in flight, so the nearest-first order follows the player.
  Chunks of other generators stay on the in-tick path.
- Determinism: a chunk is a pure function of (seed, settings, content, dimension, x, z). Which worker makes it and
  when it arrives changes only when the chunk appears, never what it holds. A chunk loaded another way meanwhile is
  not replaced by a late result.
- Shutdown: GEN-QUEUE-RESET (world open over another, world close, CORE-STOP) kills and reaps every worker. A worker
  of a game process that died ends by end of file. No thread is ever created.
- Pool size: 3 in the client, the game process keeps the other cores.

## Reads of unloaded chunks

Profiling showed the random-tick precipitation reading blocks across a chunk border into an unloaded chunk, which generated it inside
the tick (5 s). With workers serving the dimension, WORLD-GET-BLOCK on an unloaded chunk returns void and queues the chunk
(WORLD-GET-DEFER), as a read outside the loaded world does. Without workers the read generates the chunk where it stands.

## Initial spawn (docs/protocol/33 section 6.2)

The spawn search keeps its rules and result. With workers on, CORE-WORLD-OPEN stores the provisional spawn and starts
an asynchronous search (GEN-SPAWN-BEGIN): each tick GEN-SPAWN-TICK asks the queue for the next spiral chunks (as many
ahead as there are workers), scans the columns of the next loaded chunk in order within a small per-tick time budget,
and stops at the first column with a respawn position. A joining player's Finish Configuration is held (config step 4)
while the search runs and released the tick it ends, so the player never joins at a provisional position over
ungenerated terrain, and the open path does no generation. With workers off the search is the synchronous one
(WORLDSIM-INITIAL-SPAWN), unchanged.

## Progress for a loading screen

The core exposes the search progress (chunks of the spiral done, total looked at so far) in GEN-RESUME
(GQ-SP-STATE, GQ-SP-DONE, GQ-SP-TOTAL). The loading screen itself (text, layout, spawn-area radius and the chunk
grid) is not described in docs/ and needs a clean-room round before it is built.
