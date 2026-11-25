---
spile: ticket
id: CC-0047
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0043]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
---

# CC-0047: The first fill step of a freshly loaded chunk stays inside the per-tick step budget

## Summary

The generation queue runs a limited number of generation steps per tick and stops a tick when the wall time of
`GQ-MS-HUNDREDTHS` is used up. That limit is only checked between steps, so it holds only while every step is short. The
first fill step of a chunk must be a step of the same order as the others, so that loading terrain never makes one tick
take a large part of a second.

## User Stories

### As a Player, I want newly loaded terrain to appear without the game stopping for a moment

- Given a world whose structure data has not been used yet in this process, when the first chunk of the view is
  generated, then the tick that runs its first fill step ends within the per-tick step budget (`GQ-STEP-BUDGET` steps,
  `GQ-MS-HUNDREDTHS` of wall time, checked between steps) as every later tick does.
- Given the same world, when later chunks are generated, then their fill steps take no more time than before the first
  fill step was changed.

## Functional Requirements

- FR-001: The first fill step of a chunk of the standard pipeline stays inside the per-tick step budget
  `GQ-MS-HUNDREDTHS`: the work of making the structure data of the beardifier ready (`STRUCT-BEARD-PREPARE`) is not one
  step that runs from cold data, so the check between steps can hold the budget.
- FR-002: A test through the real generation path measures the CPU time of every tick of the first generation of a
  fresh world and fails when one tick is far above the budget, without ticking the generation to completion first (the
  workaround that `core/tests/test_cmd_locate_ticks.cob` uses today).

## Open Questions

- Settled (see Notes, "Fix"): the preparation is spread over the steps of the queue; it is not done once while the world
  opens, and nothing is kept between runs.

## Notes

> [!NOTE]
> The current behaviour: since the merge of lane p45h (fbfc67f2: StructureStart store, start NBT, StructureCheck,
> beardifier collection and density node) the first fill step of a chunk runs `STRUCT-BEARD-PREPARE`
> (`core/src/struct-beard.cob`) from cold structure data. That is one single step of about 0.5 to 0.65 s of CPU.
> Sampled, `GEN-QUEUE-TICK` took 378 ms before the merge and 920 ms after it. `GQ-MS-HUNDREDTHS` is 1
> (`core/copy/GENQUEUE.cpy`, checked between steps by `GEN-QUEUE-STEPS` in `core/src/gen-queue.cob`), so one long step
> overruns it by far. In play the hitch falls into the spawn-area load; in a test world it falls into a tick.

> [!NOTE]
> Found by the terminal run of the polish spec as a failure of `core/tests/test_cmd_locate_ticks.cob` ("no tick spent
> more than 0.3 s of CPU": 0.65 to 0.83 s for the mansion search). Bisected with plain builds of archive copies: the
> slowest tick of that test was 0.058 s at fbfc67f2^1 and at 90415341, and about 0.7 s at fbfc67f2, 65f3b695 and
> e85e3cee. The ticks of the search also carry the chunk generation of the view, which is why the search showed it.
> Commit 5c8489fd changed only the test: it ticks until the queue and the job are empty before it times the searches,
> so that test no longer shows the hitch. No production code was changed for this ticket.

> [!NOTE]
> Fix (2026-11-25, unverified: the operator checks by playing). Root cause is in core. `STRUCT-BEARD-PREPARE`, called by
> slab 0 of the fill stage, scans the 17 x 17 chunks around the chunk (`STRUCT-CHUNK-STARTS` for each of the 289), and
> the start of a chunk is only known after its point is found (`STRUCT-FIND-POINT`: one walk of the density corners per
> start, 20 to 350 ms each). Measured with temporary timers (removed): the first window of seed 424242 is 0.62 s, of
> which 4 of the 289 calls are 19, 18, 365 and 176 ms (the shipwreck point 311 ms, its beached variant 56 ms, the two
> ruined portal variants 65 and 109 ms) and the other 285 about 40 ms together. It is not cold data: a repeated
> `STRUCT-FIND-POINT` takes 36 us (the heights are memoised), and the windows of the later chunks add only the starts of
> 17 new chunks (0.3 to 2 ms, at most 61 ms measured). The probe of 70 other seeds shows the same shape: 0.16 to 0.6 s
> for a first window, 3.3 to 3.6 s where a trial chambers start is in it (the point of that start alone is 3.0 to 3.4 s,
> its capture 1.2 s).
>
> Why spread and not "once while the world opens": the cost belongs to every new window (a teleport or a long walk pays
> it again) and is the sum of units that no schedule makes smaller; a warm-up at the open would pay for one window only
> and the world open of the tests (`COPY NOSPAWN`) does not run the production spawn code. Why not prune the scan to the
> adapting structures: `STRUCT-DECORATE` (the features stage, `core/src/struct-place.cob`) scans the same window and
> needs the starts of every structure, so the heights of the shipwrecks and portals would only be paid one stage later.
>
> Change: the body of the scan for one chunk of the window is the new program `STRUCT-BEARD-SCAN`
> (`core/src/struct-beard.cob`; `STRUCT-BEARD-PREPARE` calls it for the 289 chunks in the order it always scanned them).
> `STRUCT-BEARD-AHEAD USING chunk x, chunk z, step` scans positions `4 * step` to `4 * step + 3` of the same order, and
> `GEN-STAGE-BIOMES` (`core/src/gen-stages.cob`, 96 steps of a few milliseconds before the fill stage) calls it with its
> own step, so the window is done by biome step 72 and the fill step finds the start list cache and the stored starts
> ready. The results are the same by construction: the scan only fills the store of starts and the cache (pure
> functions of seed and data), in the same order, with the beardifier of the chunk before switched off while it runs as
> `PREPARE` switches its own off (its records are not touched, `SBD-GEN` changes each way). Nothing runs while no
> structure is gated on. The number of generation steps did not change (`GENSTEPS.cpy` is untouched).
>
> Numbers (plain build, seed 424242, `CORE-TICK` timed with `clock()`, 349 ticks before and 367 after, until the
> second chunk is installed): the tick that runs the first fill step 0.618 s before, 0.005 s after; the slowest tick of
> the first generation 0.618 s before, 0.392 s after (that is the single 365 ms call of the shipwreck point, now in a
> biome tick: a unit of work, see below). The first fill steps of the second chunk are in the same test (2 fill ticks
> seen).
>
> Tests: `core/tests/acc_bugfirstfill_ticks.cob` (7 cases, real data, skipped as a pass without the generated packs;
> FR-002). Red on the unmodified code: "the tick of a first fill step takes at most ten times the budget of the queue in
> CPU time" fails (0.618 s against 0.1 s, run alone as well); the "both fill steps seen" and the loose "no tick takes a
> hundred times the budget" cases pass before and after. Green after the fix: 7 of 7 (also in the coverage build).
> Checks: `bwa-run` of 19 programs that touch structure starts, the beardifier, the start cache, locate and the real
> data generation hashes (`test_gen_hashes`, `acc_f2us12_structures`, `acc_f2us12_features`, `test_struct_beard_cost`,
> `test_struct_startcache`, `test_struct_beard`, `test_struct_beard_prepare`, `test_struct_beard_density`,
> `test_struct_36_1_9`, `test_cmd_locate_ticks`, `test_cmd_locate_gen`, `test_cmd_locate_cost`, `test_nether_37_2_10`,
> `acc_bugvillage_spawns`, `acc_bugtrade_village`, `test_struct_new_real`, `test_struct_height_real`, `test_gen_cost`,
> `test_chunk_feed`): 445 passed, 0 failed, no fixture or expectation changed. `make cover-changed` with those new and
> naming tests: 120 passed, 0 uncovered changed lines. `make -C core lint`: 2782 files, 0 failed.
> `python3 tools/gen/gen_tables.py --check`: 0 differing files.
>
> Left, not done (a unit of work that cannot be cut is not a step the budget can hold): the single `STRUCT-CHUNK-STARTS`
> call of a start, up to 0.37 s in this seed, and in other seeds 3 s (the trial chambers point) and 1.2 s (a capture)
> still make one tick that long wherever they fall. Cutting those means resumable height walks in `STRUCT-BASE-HEIGHT`,
> a design of its own; with generation workers (`GQ-WORKERS` above 0) none of it is in the game loop. The test therefore
> bounds the tick of the first fill step tightly (the ticket's own case) and every tick of the first generation only
> loosely (a hundred times the budget).
>
> Found on the way, not part of this ticket: in the same test world `MOBS-TICK` alone takes 1.3 to 1.8 s of CPU in about
> one tick per generated chunk once the view has more than a few chunks (hostile mobs off); measured with timers around
> each call of `CORE-TICK`, the first-fill `GEN-QUEUE-TICK` was the only other call over 0.3 s. Worth its own ticket.
