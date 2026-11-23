---
spile: ticket
id: CC-0011
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
