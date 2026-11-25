---
spile: ticket
id: CC-0009
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-14
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
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

### As a Player, I want to break a torch by hitting it

- Given a torch, wall torch or redstone torch in the world, when the player hits it in survival (and in creative), then
  it breaks, drops as an item (survival) and is removed, the same as any other block.

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
- FR-005: A torch, wall torch and redstone torch can be targeted and broken by hitting them, in survival and creative.

## Notes

> [!NOTE]
> Operator observation from the try3 build: torches do not attach to walls; breaking the wall does not pop torches or
> buttons; logs always face up; stairs always face one direction; buttons face one direction; slabs only place on the
> lower half.

> [!NOTE]
> Operator observation from a later try build: "I couldn't break torches" - hitting a torch did not break it. Cause not
> yet investigated (candidates: the torch has no hit shape or selection box so the ray never targets it, the break
> progress or dig path rejects the torch, or the torch state is placed as a block the client cannot target). Reproduce
> on the current build before fixing; an acceptance test must dig a torch and a wall torch and see the block removed.

The operator said these are out of scope for the current run (CC-0001) and to add them to the next SDD run.

## Staleness check and fix (bug wave, agent A round 2, 2026-11-25): unverified, the operator checks by playing

Most of the ticket landed in the polish run (lane wallitems, bugtorch, bugplacehead, bugbed, bugsw). Each requirement against the tests that exist on the branch (all through the real Use Item On or Player Action path, standard world):
- Wall-attached blocks attach to the clicked face (torch, wall torch, button, lever, sign, hanging sign, ladder, banner, vine, coral fan, lantern, tripwire hook, skull): core/tests/acc_torch_standard.cob and the 131-row table of core/tests/acc_place_state_standard.cob; item frames: core/tests/acc_us16_frames.cob.
- They pop off with an item when the support is broken: core/tests/acc_wall_items_pop_standard.cob (and acc_support_standard.cob for snow, kelp and sugar cane).
- A face that cannot support the block places nothing and keeps the item: the table rows "not placed" (ladder, sign, hanging sign, lantern, vine, lever, tripwire hook) and acc_torch_standard (a torch under a block); the canSurvive check is SUP-PLACE-OK.
- Hitting a torch breaks it: core/tests/acc_break_soft_standard.cob (torch, wall torch, redstone torch; survival and creative).
- Logs and pillars by the clicked face, stairs (facing, half, the five corner shapes), slabs (top, bottom, double), doors (hinge), trapdoors, fence gates, furnace, anvil, dispenser, piston, observer and the other facing blocks: the table of acc_place_state_standard; chests (facing, left and right halves, the sneaking join): core/tests/acc_us12_containers.cob and acc_us12_sneak.cob; beds: core/tests/acc_bed_halves.cob.
- FR-004 (the client predicts the same state): there is no client prediction to disagree with. The client sends Use Item On with the face and the in-block hit point of its ray (client/src/raycast.cob TG-CX, TG-CY, TG-CZ, clamped 0 to 1; CONTROLS-SEND-USE; the packet bytes are asserted by client/tests/acc_bugbrush_control.cob, TG-CZ by test_physics_shapes.cob) and draws what the server answers with Block Update. The server computes the state (FR-001).

Missing and now written (red first): a hopper placed against a side face and a glazed terracotta of any colour.
- Root cause (core): the hopper had no placement rule, and in addition BE-PLACE-STATE (be-world.cob, run after PLACE-STATE in BLOCK-PLACE) rebuilt every block-entity block from its default state, so a hopper always faced down; a glazed terracotta was not in the families of PS-FAMILY, so it always faced north.
- Fix: core/src/place-state.cob (family 22 hopper: facing is the opposite of a horizontal clicked face, down for a vertical one, 24 part 5 section 7.8; the glazed terracotta suffix joins family 7, facing the opposite of the player's horizontal direction, 24 part 6 section 6.13; the family table grew from 48 to 50 rows, rows past the OCCURS were never scanned), core/src/be-world.cob (BE-PLACE-STATE leaves the hopper alone).
- Red tests: ten rows added to core/tests/acc_place_state_standard.cob (hopper on the top face, the four side faces and the underside; glazed terracotta looking south, west, north, a second colour looking east). Before the fix 7 of the 10 failed (the four hoppers on side faces, three glazed terracotta facings; the hopper on top and underside and the glazed terracotta looking south equal the default state).
- Checks: acc_place_state_standard, acc_us12_containers, acc_us12_sneak, acc_wrapb_hopper_faces, acc_wrapb_hopper_more, acc_us12_hopper_dispenser: 175 pass (run ps4); acc_torch_standard, acc_place_head_standard and acc_wall_items_pop_standard pass in run ps3 (before the be-world change, which only reaches the hopper family). `make cover-changed SINCE=origin/003-play-test-bugs ONLY="acc_place_state_standard acc_us12_containers acc_wrapb_hopper_more"`: 160 pass, 0 uncovered changed lines. `make -C core lint`: 2778 files, 0 failed. gen_tables --check: 0 differing files.
- Doc gap (not guessed): the facing of a carved pumpkin and a jack o'lantern at placement (docs/protocol/24 part 3 lists only the property and the golem build, not getStateForPlacement); they are not in the ticket's list. Barrel and ender chest facings are coded in BE-PLACE-STATE and are not part of the table.
