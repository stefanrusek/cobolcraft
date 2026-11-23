---
spile: ticket
id: CC-0024
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0038]
  supersedes: []
implementation: []
---

# CC-0024: Block shapes follow doc 51 round 4: offset rule, scaffolding, shulker lid, light data, step-up

## Summary

Collision, outline and occlusion shapes of the cauldron family, hopper, bell, scaffolding, composter, lectern,
grindstone, pistons, shulker lid states, sculk, end portal frame, brewing stand, conduit and dragon egg follow
docs/protocol 51 sections 1.8 and 3.8, and a move steps up by the heights of the colliders' boxes.

## User Stories

### As a Player, I want to walk, stand and aim against blocks by their real shapes

- Given a hopper, cauldron, composter, scaffolding, shulker box or sculk block, when I collide with it or aim at it,
  then the collision shape, the outline and the targeted face follow doc 51.
- Given a flower, bamboo, speleothem or mangrove propagule, when it has a model offset, then the offset moves its
  shape; for every other offset block only the model moves (51 section 1.4).

## Functional Requirements

- FR-001: The shape tables (content/copy/CTBSDATA.cpy, content/src/block-shapes.cob BSH-*) hold the round 4 rows, with
  light and occlusion data for every state (51 sections 1.8.1 and 3.8.11, 32 section 7).
- FR-002: Scaffolding collides by entity (51 section 3.8.5): stable top and posts above, plate for an unstable one,
  none for a sneaking player.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-p70f (tip 4a7a9465, 16 commits, none on origin; lane ids T44500-T44999, brief in
  scratchpad/pending-lanes.md): the doc commits a2ba2b6e and 1cecbd93 (round 4 of doc 51, offset corrections in 24-1,
  24-2, 24-5, bell floor shape, 29b-4 and 31-1 corrections, copied from branch docs-struct b43ba393); d33011f1 offset
  rule; 555df2bc hopper, cauldron legs and the short piston head against an independent model; b5c6b16b and 4bbf0d39
  scaffolding by entity; 365bd0e4 interaction shapes of the cauldrons, composter, hopper and scaffolding; 14a66634
  shulker lid as collision and outline; b197b9ff light and occlusion data of every state; 243b9545 move axes in
  axisStepOrder and step-up by collider heights; 358cf25c shrieker and cake shapes; the lane notes d6143767.
- Left: the branch is more than 900 commits behind origin and was never merged, so it needs a merge with review of the
  shape tables and the state-table digest tests; origin already has the earlier shapes (0c1f4649). Lane lines T44590
  and T44591 (physics approximations with no consumer) were judged not worth building.
