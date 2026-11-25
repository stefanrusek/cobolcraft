---
spile: ticket
id: CC-0052
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-25
relations:
  depends_on: []
  relates_to: [CC-0047]
  supersedes: []
implementation: []
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
  per-tick budget while chunks are generated.
- FR-002: A test through the real `CORE-TICK` path (fixed seed, real packs) measures the CPU time of `MOBS-TICK` in every
  tick of the first generation of a fresh world and fails when one tick is far above the budget.

## Open Questions

- Which part of `MOBS-TICK` is the cost and why it falls into about one tick per generated chunk (to be measured).

## Notes

> [!NOTE]
> The current behaviour, found while fixing CC-0047: in the test world of `core/tests/acc_bugfirstfill_ticks.cob` (seed
> 424242, hostile mobs off) `MOBS-TICK` alone takes 1.3 to 1.8 s of CPU in about one tick per generated chunk once the
> view has more than a few chunks. Measured with timers around each call of `CORE-TICK`; the first-fill
> `GEN-QUEUE-TICK` was the only other call over 0.3 s. The operator reports 15 fps on an M1 MacBook Air.
