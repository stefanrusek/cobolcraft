---
spile: ticket
id: CC-0047
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0043]
  supersedes: []
implementation: []
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

- Whether the preparation is spread over several steps of the queue or done once while the world opens (the spawn-area
  load has no step budget), and whether the result may be kept between runs.

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
