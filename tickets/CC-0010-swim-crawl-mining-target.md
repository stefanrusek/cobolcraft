---
spile: ticket
id: CC-0010
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0010: Mining, placing and attacking while swimming or crawling hit the block in front

## Summary

A swimming or crawling player breaks, places against and attacks what the crosshair points at, with the pick ray
starting at the eye height of the current pose, the same on the client (targeting) and in the core (reach and
line-of-sight check).

## User Stories

### As a Player, I want to mine what I look at while swimming or crawling

- Given I am crawling with pitch 0, when I hold the break button, then the block in front of me at hip height breaks,
  not the block above my head.
- Given I am swimming, when I break, place or attack, then the target is the one under the crosshair, and the core
  accepts the Player Action for that target.

## Functional Requirements

- FR-001: The client's targeting ray, the core's reach check and the pose the client sends all use the eye height of
  the player's pose (standing, sneaking, swimming, crawling, gliding, sleeping; docs/protocol 12 section 1 and 53).
- FR-002: Breaking, placing and attacking share one ray origin.

## Notes

> [!NOTE]
> Operator report (play-test of try19, 2026-11-19): when swimming or crawling, mining the block in front of me instead
> mines the block above my head.

## State at the end of the polish run (2026-11-23)

- Not started. Brief with the candidate causes: scratchpad/pending-lanes.md, section bugswimmine (ids T63400-T63499,
  no lane file was created).
- Observation at origin 30e4c31f: client/src/raycast.cob already takes the eye height from PHYS-EYE USING PL-POSE, so
  the first guess of the brief (a stale standing eye height in the client ray) is probably not the cause. Still to
  check: the pose the client sends to the core, the core's eye height per pose in the break and reach check, the
  camera. Unverified.
- Acceptance to write red first: a client test (crawling, pitch 0, picked block is the one in front), a core test
  (start-destroy for that target is accepted and breaks that block), the same while swimming, and place and attack
  from the same origin.
