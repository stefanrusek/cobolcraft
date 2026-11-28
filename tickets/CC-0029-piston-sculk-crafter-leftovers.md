---
spile: ticket
id: CC-0029
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0038, CC-0062]
  supersedes: []
implementation: []
---

# CC-0029: Pistons stick to honey, sculk occlusion and the shrieker work, and the redstone leftovers of lane p46h

## Summary

Pistons handle honey sticking and the indirect neighbour shape updates of vacated cells, the sculk system has
vibration occlusion, sneaking and spectator sources, resonance and the shrieker, and the other redstone leftovers of
lane p46h (lightning rod redirect, detector rail power, minecart containers under comparators and hoppers) work, as
docs/protocol 30 part 3, part 5 and part 8 describe.

## User Stories

### As a Player, I want redstone contraptions to work as in Minecraft

- Given a piston pushing a honey block, when entities stand on it, then they stick (30-3 sections 8.2 and 8.3), and
  the neighbours of vacated cells get their shape updates (section 6 steps 9 and 11).
- Given a sculk sensor, when a vibration crosses wool or other occluders, then it is blocked, and sneaking sources,
  resonance and the shrieker act as in doc 30 part 8.

## Functional Requirements

- FR-001: The core tracks isSupportedBy for the honey test, applies the stuck-speed multiplier, handles the vacated
  cells in the doc's order (the JDK hash map order of 6.1), and keeps flag 256 of a moving cell.

## State at the end of the polish run (2026-11-23)

- Done in lane p46h and by wrap agent B: live pistons (resolver, moving_piston, push limit 12), entity pushing
  (core/src/piston-push.cob, acc_wrapb_piston_push), saving and loading a moving block entity
  (core/src/piston-save.cob, acc_wrapb_piston_save), the placed facing, the crafter, sculk sensors and the first sculk
  dispatch.
- Left, task lines T29571 (honey sticking 8.2, stuck speed 8.3, indirect shape updates, the hash map order, flag 256
  of a moving cell), T29572 (the lightning rod redirect of a thunderstorm bolt within 128 blocks,
  updatePowerToConnected of the detector rail, comparators and droppers with minecart containers, the hopper minecart,
  hoppers over crafters and double chests; the crafting remainder and the advancement trigger have no data in this
  version) and T29573 (tags vibrations, dampens_vibrations and occludes_vibration_signals, occlusion 3.6, sneaking and
  spectator sources 3.5, resonance 4.2 step 4, the step-on activation, particles, the shrieker) in lanes/p46h.md. The
  occlusion doc is on branch docs-gameevents (87224845), whose copy on origin should be checked first.
- Planning of feature `specs/003-vanilla-movement` (2026-11-26) builds the honey carry and the stuck-speed multiplier
  for Players; for the other entities both stay here. The other open approximations of core/src/piston-push.cob are
  CC-0062.
- Doc conflict recorded: 30-3 7.6 names the moving block's blockState keys Name and Properties, 07 7.3 the lowercase
  id and properties of this version; 07 is followed (see CC-0038).
