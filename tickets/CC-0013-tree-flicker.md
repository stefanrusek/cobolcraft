---
spile: ticket
id: CC-0013
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

# CC-0013: A tree does not flicker while the camera moves

## Summary

Looking at a tree and turning the camera shows a stable image: no pixels change between frames except those that move.

## User Stories

### As a Player, I want leaves to look steady while I turn the camera

- Given a fixed oak tree, when I rotate the camera a few degrees between frames, then the leaf pixels do not flicker
  between frames.

## Functional Requirements

- FR-001: Leaf cube faces and any overlay or cross quads of the leaves rule never overlap coplanar in one mesh.
- FR-002: Two meshes of the same chunk have the same vertex and layer order.

## Notes

> [!NOTE]
> Operator report (play-test of try21 = 397c19dd, 2026-11-20): a little bit of flicker when staring at a tree and moving
> the camera.

## State at the end of the polish run (2026-11-23)

- Not started. Brief: scratchpad/pending-lanes.md, section bugtreeflicker (ids T63700-T63799). Candidate causes, none
  verified: z-fighting between leaf faces and the cross quads of the leaves cull rule (lane bugleaves, ST-LEAF
  column), nearest-with-edge-blend sampling of cutout leaves at a distance (12 section 2.4), mesh rebuild order of
  translucent and cutout layers.
- Method in the brief: a screenshot sequence of a fixed tree (--screenshot-after-frames) while rotating a few degrees,
  diffed for changing pixels; and a red client mesh test for identical order and no coplanar overlapping quads.
