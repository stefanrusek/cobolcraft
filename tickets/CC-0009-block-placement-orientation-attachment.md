---
spile: ticket
id: CC-0009
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-14
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0009: Block placement honours orientation and attachment

## Summary

A placed block takes its state from how the player places it: the clicked face, the hit position within that face, the
inside flag and the player's facing. Wall-attached blocks attach to the clicked face and pop off as items when their
support is broken, directional blocks take their orientation by vanilla rules, slabs go to the top or bottom half (and
merge into a double slab), and positions that violate survival rules are rejected. The client predicts the same result
the server computes.

## User Stories

### As a Player, I want wall-attached blocks to attach to the face I click and to pop off when their support is broken

- Given a torch, wall torch, button, lever, sign, ladder, banner, vine or item frame, when the player places it against
  the side of a block, then it attaches to the clicked face with the matching facing.
- Given an attached block, when the block it is attached to is broken, then the attached block pops off and drops as an
  item.
- Given a face that cannot support the block (for example the underside for a torch), when the player clicks it, then
  nothing is placed.

### As a Player, I want directional blocks to take their orientation from my placement

- Given a log or pillar block, when the player places it, then its axis follows the clicked face (up and down gives Y,
  north and south gives Z, east and west gives X).
- Given a stair, when the player places it, then it faces by the player's facing, sits top or bottom by the clicked half
  of the face or block, and takes its shape (straight, inner or outer corner) from its neighbours.
- Given a door, trapdoor, fence gate, furnace, chest, piston, observer, dispenser, hopper, bed, anvil or glazed
  terracotta, when the player places it, then its facing, half, hinge or similar properties follow the vanilla rules from
  the player's facing and the hit position.

### As a Player, I want slabs to place on the half I click and to merge into double slabs

- Given a slab, when the player clicks the top face of a block or the upper half of a side face, then the slab is placed
  as a top slab; otherwise as a bottom slab.
- Given a slab of one kind, when the player places a slab of the same kind onto its open half, then the two become a
  double slab.

### As a Player, I want placement that could not survive to be rejected

- Given a block that needs a floor or a side support, when the player places it where that support is missing, then the
  placement is rejected and no item is consumed.

## Functional Requirements

- FR-001: The server computes the placed block state in a BlockItem.getStateForPlacement equivalent, from the Use Item On
  hit position, face and inside flag and the player's facing (docs/protocol use-item-on and the blocks docs).
- FR-002: After a block change, neighbours get a shape update (updateShape and canSurvive equivalents); a block that
  can no longer survive is removed and drops as an item.
- FR-003: Placement is rejected when the can-survive check fails for the computed state.
- FR-004: The client predicts the placed state with the same rules, so the server's confirmation does not change what
  the player sees.

## Notes

> [!NOTE]
> Operator observation from the try3 build: torches do not attach to walls; breaking the wall does not pop torches or
> buttons; logs always face up; stairs always face one direction; buttons face one direction; slabs only place on the
> lower half.

The operator said these are out of scope for the current run (CC-0001) and to add them to the next SDD run.
