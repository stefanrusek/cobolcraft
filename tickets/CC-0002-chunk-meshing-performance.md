---
spile: ticket
id: CC-0002
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0002: Chunk mesh building fast enough to play

## Summary

The client spends most of its time building chunk meshes. The convergence test `acc_us3_streaming` takes about 3
minutes uninstrumented, almost all of it in client mesh building. Joining a world or moving into new terrain should
not stall the frame rate. This ticket is the performance input for the second SDD run, together with whatever
profiling of the first manual run shows.

## User Stories

### As a Player, I want terrain to appear without stalling the game

- Given I join a world at the default view distance, when the chunks arrive, then the game keeps responding to input
  while their meshes are built, and the visible terrain is complete within a measured target.
- Given I fly in a straight line, when new chunks load, then the frame rate stays above a measured target.

### As a Contributor, I want the streaming test to run quickly

- Given `make gate`, when `acc_us3_streaming` runs, then it finishes in a fraction of its current 3 minutes.

## Functional Requirements

- Given any performance change, when it lands, then the measured targets and how they are measured are written in
  the feature's spec (constitution 2.7: targets exist only where requested).

## Open Questions

- What are the targets: the frame rate, the time to the first complete view, and the platform they're measured on?
- Profile first. Is the cost in the COBOL mesh loop, in the per-block lookups, or in uploads through the shim?
