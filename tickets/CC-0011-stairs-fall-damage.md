---
spile: ticket
id: CC-0011
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

# CC-0011: Walking down stairs or an incline fast deals no fall damage

## Summary

A player who travels down stairs, slabs or a slope on the ground, even at sprint speed, is on the ground every tick
and takes no fall damage. Fall distance accumulates only while the player is not on the ground.

## User Stories

### As a Player, I want to run down stairs without being hurt

- Given a staircase or slope, when I sprint down it without leaving the ground, then the client sends on-ground true
  for every tick and my health does not change.
- Given a packet sequence that descends 0.5 blocks per tick with on-ground true, when the core handles it, then fall
  distance stays 0 and no damage is dealt.

## Functional Requirements

- FR-001: The client's step-down and ground snap use the block shapes (stair, slab, snow layer) so that the on-ground
  flag of Move Player is true after a step down.
- FR-002: The core resets fall distance on an on-ground packet before it adds the packet's y delta, and a landing
  computes damage = distance - 3 (docs/protocol 12, fall damage).

## Notes

> [!NOTE]
> Operator report (play-test of try19, 2026-11-19): travelling down stairs or an incline too fast causes the player to
> take fall damage despite never leaving the ground.

## State at the end of the polish run (2026-11-23)

- Not started. Brief with three candidate causes (client sends airborne for the tick of a step down; core derives
  distance from the y delta although on-ground is true; client and core shapes differ): scratchpad/pending-lanes.md,
  section bugstairfall (ids T63500-T63599). Unverified.
- Not the lane bugstairlight (light of partial blocks, merged by patch on origin). Fall damage by the landed-on block
  (slime, hay, honey, bed) is on origin since ccaef248 and is not this bug.
- A real single-player convergence case walking down a staircase and a slope is part of the acceptance.

## Fix and verification (bug wave, 2026-11-25, agent A)

Reproduced for real first: `tests/convergence/acc_bugstairfall_walk.cob` (a single-player survival world, the Player walks and sprints down eight stairs, eight
one-block steps and sixteen bottom slabs with W held through the real controls): before the fix every case but one lost 2 to 5 health (stairs 2 and 4, blocks 5
and 3, slabs 1), with no teleport. The per-frame trace showed the client airborne for the whole descent (30 frames in a row), never landing.

Root cause, two halves (client and core), the doc being docs/protocol 18 section 3 (`Entity.move` goes along y first, then x and z, and sets onGround when the
vertical movement was blocked while moving down) and 30-8 14.1 (the server takes the packet's on-ground flag and runs `doCheckFallDamage` with it):
- Client (`client/src/physics.cob` PHYS-TICK): the on-ground flag was a probe under the final position after the whole tick's move. A Player that lands on a step
  and strides off it in the same tick (a stair half is 0.5 deep, a stride 0.2 to 0.28) is over nothing at the end of the tick, so the landing tick was sent as
  airborne and every landing of a descent went unreported. Now a tick whose y move was blocked while moving down (not flying) reports the ground too (`WS-LANDED`).
- Core (`core/src/movement.cob` MOVE-PLAYER): the claim counted as ground only with support at the final position (MOVE-SUPPORTED), so the reported landing was
  refused and the fall start (`PL-FALL-START`) was never reset: the whole descent added up as one fall and the first supported landing paid
  floor(distance - 3). Now the support of a landing claim is also tested at the old column at the new height (the move goes y first), which is where the
  client landed. A claim in the air with no support at either place is still refused (acc_f2us7_onground_claim).
Candidate (3) of the brief (client and core shapes differ) was checked and is not it: the client and core hold the same state and the same collision shape id
for stair cells (trace of `acc_bugstairfall_walk`).

Tests (red first):
- client/tests/test_land_ground.cob (2 cases, walking and sprinting down six one-block steps): red with the old PHYS-TICK (longest time off the ground 30 and 21
  ticks, 0 landings), green with the fix (4 and 6 ticks; 5 and 2 landings).
- core/tests/acc_bugstairfall_landing.cob (2 cases): a landing claim whose final position strides off the step must count as ground and reset the fall start
  (red: ground 0, start 101000); six such landings down six steps deal no damage (red: health 17).
- tests/convergence/acc_bugstairfall_walk.cob (6 cases, real single-player host): green, no health lost, no teleport.

Checks: 527 neighbouring cases (client physics, swim, sneak, glide, controls, flight, climb, sprint; core movement, fall, climb, on-ground claim, step-up, swim,
bounce, drowning, food falls) pass; `make cover-changed SINCE=origin/003-play-test-bugs ONLY="acc_bugstairfall_landing acc_f2us7_onground_claim test_land_ground
test_physics test_movement acc_us7_fall_damage test_on_ground"`: 30 pass, 0 uncovered changed lines; lint core, client and tests/convergence and
`gen_tables.py --check` clean. No shim or ABI change. A fast descent that really leaves the ground for more than 3 blocks still hurts, as in vanilla.
