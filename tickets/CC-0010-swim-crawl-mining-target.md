---
spile: ticket
id: CC-0010
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
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

## Fix and verification (bug wave, 2026-11-25, agent A)

Root cause: the client targeting ray. Until T58602 (46e48620, 2026-11-23, after the try19 report) `client/src/raycast.cob`
started the ray at `PL-Y + 1.6` whatever the pose, so a crawling or swimming player (eye 0.4 above the feet, docs/protocol
53 section 2.1) aimed from inside the block above the head; the eye's own cell is never a target, so the ray hit the block in
front one row higher. Break, place (Use Item On) and the entity ray share that origin. T58602 already moved it to
`PHYS-EYE USING PL-POSE`; the ticket was stale on the client side. The core never checks the reach of a break or a place
(`UI-RANGE-OK` has no caller), so it was not the cause of the wrong block; it did use a fixed eye (RULE-ATTACK-EYE-MILLI,
1.6) for the attack reach, the leash knot, mob interaction, boat use and the spear jab, which docs 53 section 7 contradicts
(the entity's own pose eye height is what the server and the picking ray use).

Changes (core, FR-001): new `POSE-EYE` (core/src/poses.cob: standing 1.62 and crouching 1.27 with a standard set, 1.6 and
1.25 for the stand-in set, swimming/crawling/gliding 0.4, sleeping 0.2) used by `HEALTH-ATTACK` (health.cob), `MOB-INTERACT`
and the knot reach (mob-18-8.cob), `BOAT-USE` (mob-21-boat.cob) and `RANGED-STAB` (ranged-spear.cob). Not changed:
`BREATH-EYE-IN-WATER` (breath.cob) still reads feet + 1.6 (air supply, not an interaction).

Tests (red first):
- client/tests/test_pose_target.cob (5 cases): crawling in a gap 1.0 high, pitch 0: target is the wall block (21, 10, 3);
  Start Destroy names it; the left button attacks a boat on the tunnel floor; swimming in a pool: target is (13, 7, 0).
  Red proof: with raycast.cob temporarily put back to `PL-Y + 1.6`, 4 of 5 fail (target (21, 11, 1), Start Destroy y 11,
  no Attack, target (13, 9, 0), i.e. exactly the reported block above); restored, 5 pass.
- core/tests/test_pose_eye.cob (4 cases): eye per pose for both content sets; an Attack on a chicken whose box edge is 3.95
  away is out of reach from a standing eye and in reach from a crawling one (red before the call sites changed:
  expected 1 observed 0).

Checks: `test_pose_target` 5 pass; 23 neighbouring core families (attack, health, spear, leash, boat, interact, golem, wind
redirect, defeat, food falls, ride) 368 pass; `make cover-changed SINCE=origin/003-play-test-bugs ONLY="test_pose_eye
test_attack_zombie acc_us14_spear test_mob_18_knot test_mob_21_boat_seats test_mob_chest_boat test_mob_21_8_8 acc_us7_attack
acc_us15_feed_species acc_us15_breeding"`: 238 pass, 0 uncovered changed lines; `make lint` core (2756 files) and client
(892 files) clean; `gen_tables.py --check` clean. No shim or ABI change, so no shim or contract gate. Visual check of the
crosshair while swimming is left to the operator (no window run here).
