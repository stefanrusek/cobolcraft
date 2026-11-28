---
spile: ticket
id: CC-0061
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0002]
  supersedes: []
implementation: []
---

# CC-0061: The Player moves at full speed when the frame rate is low

## Summary

The game runs twenty ticks a second whatever the frame rate, so a Player moves at the same speed on a slow frame rate
as on a fast one.

## User Stories

### As a Player, I want a slow machine not to slow me down

- Given the window draws fewer than twenty frames a second, when I walk for ten seconds, then I cover the same
  distance as at a high frame rate.

## Functional Requirements

- FR-001: A frame runs every client tick that is due, at most ten (docs/protocol 59 section 2.1).

## Notes

- Found while planning feature `specs/003-vanilla-movement`, which excludes frame rate and stutter (spec
  Assumptions). The play-test slowdown on the M1 MacBook Air is investigated separately.

> [!NOTE]
> Today client/src/loop.cob runs at most one tick a frame and drops the ticks that are overdue, so below twenty frames
> a second the Player moves slower than the documented speeds.
