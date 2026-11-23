---
spile: ticket
id: CC-0017
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0014]
  supersedes: []
implementation: []
---

# CC-0017: Boats, bows, shields and other held items start their use from the real window

## Summary

A right click with a boat, firework rocket, armor, bow, crossbow, trident, shield, spyglass, goat horn, brush or
potion sends Use Item (and the release when the button is let go), and a click that an interactive block took does not
also use the held item.

## User Stories

### As a Player, I want to use the item in my hand

- Given a bow, crossbow, trident, shield, spyglass, goat horn or brush in my hand, when I hold the right button, then
  Use Item is sent, and Release Use Item when I let go.
- Given a boat in my hand, when I click solid ground, then it is placed at the surface where the pick ray meets it.
- Given an ender pearl, snowball or egg, when I click a door or a crafting table, then the block takes the click and
  nothing is thrown.

## Functional Requirements

- FR-001: CONTROLS-INPUT sends Use Item for the use lists of docs/protocol 25 section 6.3, 21 section 8.12 and 17, and
  the release for held items.
- FR-002: A Use Item On that a block took spends the click, so the Use Item of the same tick is ignored.

## Notes

> [!NOTE]
> Found from lane bugeye (merged): the real window sent Use Item only for thrown items (eye, pearl, egg, snowball,
> potions, fishing rod). Boats, bows, crossbows, tridents and shields sent nothing.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-bugusein (tip 4a903140, six commits not on origin by patch-id; the rest is merged):
  f01e0c39 the right button sends Use Item for boats, rockets, armor, bows, crossbows, tridents, shields, spyglass,
  goat horns, brushes and potions and the release (test_use_items, red first 17f5223e); 1ba1e58e a Use Item On that a
  block took spends the click (acc_bugusein_click, red 037f45c9); 4a903140 a boat used on solid ground is placed at
  the pick-ray surface (T63305). Lane ids T63300-T63399; brief in scratchpad/pending-lanes.md.
- Left: the branch was stopped before integration, so it has not been merged into origin or run through the gates
  after a merge. The pull animation and pose of bows and shields were not part of it (see CC-0014 for the horn pose).
