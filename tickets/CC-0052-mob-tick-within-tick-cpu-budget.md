---
spile: ticket
id: CC-0052
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-25
relations:
  depends_on: []
  relates_to: [CC-0047]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
---

# CC-0052: A mob tick stays inside the per-tick CPU budget however many chunks are loaded

## Summary

The core ticks beside the renderer in single-player, so a tick that takes more than a small part of a second is a visible
frame hitch. The mob step of the tick (`MOBS-TICK`) must cost about the same in every tick of a world with mobs, however
many chunks the view has loaded and however many chunks were just generated.

## User Stories

### As a Player, I want the game to keep a steady frame rate while the world around me is generated and its mobs move

- Given a standard world with the hostile mobs off and a view of several chunks, when the chunks of the view are
  generated one after another, then no tick spends more than the per-tick CPU budget in the mob step.

## Functional Requirements

- FR-001: The CPU time of `MOBS-TICK` does not grow with the number of loaded chunks, and no tick of it is far above the
  per-tick budget while chunks are generated: a block read of a mob into a chunk that is not loaded never makes the chunk
  inside the tick; the chunk is made by the steps of the generation queue, within the per-tick step budget.
- FR-002: A test through the real `CORE-TICK` path (fixed seed, real packs) measures the CPU time of `MOBS-TICK` in every
  tick of the first generation of a fresh world and fails when one tick is far above the budget.

## Open Questions

- Settled (see Notes, "Fix"): the cost is one block read of one mob into a chunk that is not loaded, not a scan.

## Notes

> [!NOTE]
> The current behaviour, found while fixing CC-0047: in the test world of `core/tests/acc_bugfirstfill_ticks.cob` (seed
> 424242, hostile mobs off) `MOBS-TICK` alone takes 1.3 to 1.8 s of CPU in about one tick per generated chunk once the
> view has more than a few chunks. Measured with timers around each call of `CORE-TICK`; the first-fill
> `GEN-QUEUE-TICK` was the only other call over 0.3 s. The operator reports 15 fps on an M1 MacBook Air.

> [!NOTE]
> Measured (2026-11-25, temporary timers and a temporary probe test, both removed; world of `core/tests/acc_bugfirstfill_ticks.cob`:
> seed 424242, view distance 2, hostile mobs off, no generation workers, 20000 ticks of the real `CORE-TICK`). `MOBS-TICK` over
> 50 ms: debug build (`-debug`, what the tests use) 32 ticks, 31 of them 1.19 to 2.68 s and one 53 ms; optimised build
> (`-O2`, no `-debug`, the Makefile's `RELEASE=1` flags, built under the scratch dir `scratchpad/bwa-o2build`) 17 ticks, 0.52 to
> 0.70 s. Split by call inside `MOBS-TICK`: the scan of the entity table at most 0.16 ms, `MS6-DESPAWN-TICK` for every mob at
> most 0.06 ms, `BEE-HIVES-TICK` at most 0.02 ms (debug); everything else is one `MOB-STEP` of one mob per tick (a bat in 26 of
> the 32 debug ticks, a cow 1, pigs 2, sheep 3). There is no scan over all chunks or all mobs and no passive spawn pass in it.
> The `sample` of the process (debug, 40 s) puts 16857 of 30046 samples in `MOBS-TICK`, 15805 of them in `BAT-TICK` and 14689
> in the chain `WORLD-GET-BLOCK`, `WORLD-CHUNK-LOAD`, `WORLDGEN-DIM-CHUNK`, `WORLDGEN-STANDARD-CHUNK`, `GEN-STANDARD-INSTALL`,
> `GEN-JOB-RUN-ALL`: the whole generation pipeline of one chunk run by one block read.

> [!NOTE]
> Fix (2026-11-25, unverified: the operator checks by playing). Root cause is in core. `WORLD-GET-BLOCK` generates a chunk that
> is not loaded where the read stands, unless generation workers serve the dimension (`WORLD-GET-DEFER`: void read, chunk
> queued). A mob reads blocks near itself: a flying bat picks a new target (once in 30 ticks, or when it has arrived) within 7 blocks of itself and
> reads the block there (`BAT-TICK`), an animal's box covers the cells next to it (`MOB-PHYSICS`). At the edge of the loaded
> chunks such a read is a read of an unloaded chunk, which is why the spike falls into about one tick per chunk the mob reaches
> (later reads of the same chunk are cheap). Cause class: only without workers (the tests, a server with
> `generation-workers=0`). The single-player client starts the pool with `GEN-WORKERS-AUTO` (`client/src/sp-host.cob`), where
> the read was already deferred: control run with 2 workers, `-O2`, 6000 ticks with a 10 ms pause per tick: no `MOBS-TICK` over
> 50 ms, slowest `CORE-TICK` 0.131 s (a chunk install), 35 chunks loaded (the 25 of the view and 10 that mobs wanted). So this
> spike does not explain the operator's 15 fps in play by itself; it is the tick cost in the tests and on a worker-less server.
>
> Change: `MOBS-TICK` (`core/src/mobs.cob`) sets the new `GQ-DEFER-READS` (`GEN-DEFER` external record, `core/copy/GENQUEUE.cpy`)
> to 1 at its start and to 0 at its end; `WORLD-GET-DEFER` (`core/src/gen-worker.cob`) defers a read of an unloaded chunk of the
> standard pipeline when workers serve the chunks (as before) or `GQ-DEFER-READS` is 1: the read is void and the chunk is
> queued (`GEN-QUEUE-WANT`), and the steps of the queue make it within `GQ-STEP-BUDGET` steps and `GQ-MS-HUNDREDTHS` of wall
> time per tick, as every view chunk is made. Not changed: reads outside `MOBS-TICK` (a test or command calling `MOB-STEP`
> directly, the spawn search, `/locate`, player actions) still generate where they stand; dimensions of other generators
> (flat, nether) are unaffected; a mob whose own chunk is not loaded already does nothing (`STDMOB-READY`).
>
> Numbers after the fix, same world and run: `MOBS-TICK` over 50 ms in 20000 ticks: 0 in the debug build and 0 in the `-O2`
> build (before: 32 and 17). The slowest whole tick of such a run is no longer a mob tick: 0.64 s (`-O2`) and 1.36 s (debug) in
> one run, 2.2 s and 3.06 s in another (the number of queue steps per tick depends on the wall clock, so the mobs and chunks of
> two runs differ). With no `MOBS-TICK` over 50 ms in the same runs, these are the unit-of-work calls of structure starts that
> CC-0047 left (a single `STRUCT-CHUNK-STARTS` of 0.37 s, 1.2 s or 3 s) inside the queue's steps of chunks that mobs now want
> beyond the view; the queue's own calls were not timed separately here.
>
> Test: `core/tests/acc_bugmobtick_ticks.cob` (7 cases, real data, skipped as a pass without the generated packs). It ticks the
> real `CORE-TICK` until the chunk of the player is loaded, loads and lights a chunk three chunks east (outside the view, inside
> the 64 block range of `MOB-ACTIVE`), puts a cow on its east edge with its box over an unloaded chunk and times `MOBS-TICK`
> alone (C `clock()`): at most ten times the budget (`GQ-MS-HUNDREDTHS * 10000 * 10` us = 0.1 s); the read chunk is not loaded
> by that tick and is in the queue; then a cow on the north edge and the whole `CORE-TICK` below thirty times the budget (0.3 s,
> the queue's steps are in it). Red on the unmodified code (debug build): `MOBS-TICK` 1.296 s and `CORE-TICK` 1.491 s, 4 of 7
> cases fail ("at most ten times the budget", "not loaded after it", "in the generation queue", the whole tick). Red in the
> `-O2` build with the same code: `MOBS-TICK` 0.597 s and `CORE-TICK` 0.696 s (that run used a one second whole-tick bound,
> which 0.696 s met; the 0.3 s bound now in the file is below it, the ten-times case fails at `-O2` as it stands). Green after
> the fix: 7 of 7, debug `MOBS-TICK` 0.015 s and `CORE-TICK` 0.008 s, `-O2` 0.012 s and 0.005 s; 8 to 10 s for the program.
>
> Checks: regression of 44 programs (the 30 programs that `COPY GENQUEUE` (the copybook changed; they include
> `acc_bugmobtick_ticks` and `acc_bugfirstfill_ticks`), the programs that call `MOBS-TICK` (`test_stdmob_hostile`, `test_stdmob_speed`, `test_stdmob_bench`,
> `test_stdmob_cube_hop`, `test_stdmob_cube_10_1`, `test_bench_village`) and the standard-world tick tests
> (`acc_kelp_standard`, `acc_spider_standard`, `acc_us15_warden_body`, `acc_us15_warden_nonplayer`, `acc_us15_warden_touch`,
> `test_cmd_locate_cost`, `acc_bugvillage_spawns`, `acc_bugtrade_village`)): 652 passed, 0 failed, no expectation changed.
> `make cover-changed` with `acc_bugmobtick_ticks`, `test_stdmob_hostile` and `test_gen_worker`: 70 passed, 0 uncovered
> changed lines. `make -C core lint`: 2787 files, 0 failed. `python3 tools/gen/gen_tables.py --check`: 0 differing files.
>
> Left, not done: the queue's unit-of-work calls above (CC-0047, resumable height walks); other game ticks (arrows, thrown
> items, ground items) were not seen to generate a chunk in these runs and were not changed. Chunks that mobs want stay loaded
> like any chunk (pre-existing with workers: 10 extra chunks in 6000 ticks).
