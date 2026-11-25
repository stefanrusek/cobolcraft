---
spile: ticket
id: CC-0016
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

## Fix (bug wave, 2026-11-25)

- Root cause (client; the shader is as documented): ITEM-GUI-ICON and SPECIAL-GUI-ICON handed the face's lighting to
  SPECIAL-UI-QUAD (client/src/item-special-draw.cob) as the vertex brightness, but the UI pipeline ignores the vertex
  brightness (shim/shaders/ui.vert, shim-abi section 9: colour = texel x tint), so the three visible faces of a block
  icon came out with the same brightness on the GPU. The fix is the doc's own formula (12 section 6.10: vertexColor =
  colour.rgb x lightAccum): SPECIAL-UI-QUAD writes tint x brightness into the vertex colour and 1 into the brightness
  field. No shader change and no shim ABI change; flat icons (shade 1) are unchanged. Slots, the beds and every other
  code-drawn model take the same path.
- Red tests (the vertex colour is the face's shade; shades from the independent script client/tests/fixtures/gen_item_gui.py,
  doc formula min(1, (max(0, n.L0) + max(0, n.L1)) x 0.6 + 0.4): up 1.0000, east 0.7459, north 0.6797):
  test_item_gui (oak slab: vertices carry the shade, brightness 1; red: 2 of 3 quads wrong), test_special_bed (white bed
  quads; red: 11 of 13 quads wrong), test_item_tint_icons (oak leaves, dirt and grass block: six vertices in each face's
  shade of the tint or white; red: all 18 or 30 vertices unshaded).
- Checks: those three plus test_special_items, test_special_cover, test_special_slots, acc_us4_inventory_screen,
  test_inventory_preview, test_recipe_book_core and test_render_list: 400 passed, 0 failed;
  `make cover-changed SINCE=origin/003-play-test-bugs` with them: 285 objects, 0 uncovered changed lines;
  `make -C client lint` passes.
- Visual check (the operator's; needs the window): block items in the hotbar and inventory show the top lightest and the
  two side faces darker and different from each other (1.0, 0.75 and 0.68 of the texture colour).
