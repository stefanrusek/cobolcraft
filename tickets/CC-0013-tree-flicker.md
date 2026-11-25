---
spile: ticket
id: CC-0013
type: bug
status: implementing
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

## Investigation (bug wave, 2026-11-25)

Cause found by reading the mesher, the render list and the shim (client and shim; not core). Not yet fixed.

- With the Fancy default (cutoutLeaves on, CL-LEAVES-CULL 0) the mesher draws every face of every leaf block, including
  the face between two adjacent leaf blocks, which therefore exists twice: one quad per block, in the same plane, facing
  opposite ways, with mirrored texel mapping (client/tests/test_mesher_leaves.cob asserts it: oak beside birch leaves
  draw 12 faces, "the one between them twice"; the 3 x 3 x 3 cube draws 162 quads, 108 more than its 54 outside faces).
  This is the rule of the docs (24 part 1 section 9.1, LeavesBlock.skipRendering) and it relied on the terrain pass
  culling back faces so that only the quad facing the camera is rasterised.
- The leaf quads go to the opaque layer (WR-OP), which render-list.cob draws with CC-PIPE-OPAQUE, and
  shim/src/cc_vk.c line 599 creates every pipeline except CC_PIPE_TRANSLUCENT_CULL with VK_CULL_MODE_NONE. So both quads of
  each shared leaf face are rasterised at the same depth: z-fighting whose winner changes with the camera, between two
  mirrored copies of the leaf texture. That is "a little bit of flicker when staring at a tree and moving the camera",
  and it appeared with the fancy leaves rule of lane bugleaves (before it the shared faces were culled).
- Proposed fix (needs a GPU run to confirm, so it is the operator's check): a new pipeline CC_PIPE_OPAQUE_CULL (id 6, the
  opaque pipeline with the back faces culled, front face clockwise in the y-down framebuffer like
  CC_PIPE_TRANSLUCENT_CULL) used by render-list.cob for the section opaque meshes only (line 423; signs, entities and
  the hand keep CC-PIPE-OPAQUE). The terrain faces are the same baked block faces that the translucent pass already draws
  culled in play. It changes the shim ABI (contract/include/ccshim.h, contract/copy/CCSHIM.cpy, shim/src/cc_vk.c create and
  destroy loops and depthWriteEnable, shim/tests/contract_shim_provider.c, the shim-abi doc) so the shim and contract
  gates must run. Red test to write first: test_render_list.cob expects the world section draws on the new pipeline;
  plus a mesh test that the two coplanar quads of a shared leaf face have opposite winding (one front, one back).
