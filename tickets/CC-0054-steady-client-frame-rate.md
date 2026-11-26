---
spile: ticket
id: CC-0054
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0002, CC-0047, CC-0052]
  supersedes: []
implementation:
  branch: 004-perf-frame
---

# CC-0054: The client holds a steady frame rate at the agreed target in a standard world

## Summary

In a standard single-player world the client draws at a steady frame rate that meets a target agreed with the operator
for a named machine, view distance and window size. The target is a measured number (constitution 2.7); it is not set
yet and is agreed before any code changes.

## User Stories

### As a Player, I want the game to draw smoothly while I stand, walk and fly in a standard world

- Given a release build, a standard world and the agreed view distance and window size on the agreed machine, when the
  player stands still after the view has loaded, then the F3 overlay shows a frame rate at or above the agreed target.
- Given the same setup, when the player walks or flies so that new chunks arrive, then the frame rate stays at or above
  the agreed lower bound for movement.

## Functional Requirements

- FR-001: The cause of the reported frame rate is found by measurement of a release build before code changes: the
  share of a frame spent in the core tick, the client tick, meshing, the render list, the window submit and the present.
- FR-002: The frame rate target (machine, world, view distance, window size, standing and moving) is agreed with the
  operator and recorded here.
- FR-003: Each change made for this ticket has a test through the real code path with real data that fails before the
  change.

## Notes

> [!NOTE]
> Reported on 2026-11-26: a steady frame rate of about 15 on an M1 MacBook Air, with the vanilla client at 60 on the
> same machine and no other load. Build, world type, view distance and single-player or server were not recorded.
> Measured so far (M4 Pro, -O2 build of main aba05242, `acc_perfframe_bench`, view 12, 24 mobs): mean CPU time of one
> frame step 8541 us, slowest 35383 us. The window submit and the present are not in that number and are not measured
> on any machine yet. They can only be measured with a window on the screen; that check is the operator's.
