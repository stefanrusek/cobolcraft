---
spile: ticket
id: CC-0016
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

# CC-0016: 3D block icons in slots are shaded per face

## Summary

A block item drawn as an isometric cube in a slot has its faces at the brightness the doc gives per face, not all at
the same unshaded level.

## User Stories

### As a Player, I want block icons in the inventory to read as cubes

- Given a block item in a slot, when the slot is drawn, then the top, left and right faces differ in brightness as in
  docs/protocol 49 section 4 and 43.

## Functional Requirements

- FR-001: Either the UI vertex shader uses the vertex brightness, or the brightness is folded into the tint as
  client/src/preview.cob does.

## Notes

> [!NOTE]
> Found by a wrap agent on 2026-11-23 by reading, not seen in play: shim/shaders/ui.vert says the UI pipeline ignores
> brightness, but ITEM-GUI-ICON passes IG-BRIGHT as the vertex brightness, so the icons are probably drawn flat on the
> GPU. It could not be checked headless.

## State at the end of the polish run (2026-11-23)

- Not started. Brief: scratchpad/pending-lanes.md, section bugitemicon3d (ids T63950-T63999). Verify by a screenshot
  of the inventory first (needs the game window).
