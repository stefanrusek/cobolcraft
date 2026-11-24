---
spile: ticket
id: CC-0034
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0033, CC-0037]
  supersedes: []
implementation: []
---

# CC-0034: Compass and clock glint, fox and panda held items and the creeper swirl

## Summary

The remaining held-item and glint cases are drawn: the compass and clock enchantment glint in every context, the fox's
mouth item, the panda's held item, the creeper charge swirl, and the biome tint of a carried grass block or leaves.

## User Stories

### As a Player, I want enchanted and held items to look right

- Given an enchanted compass or clock, when it is drawn in a frame, a mob's hand or on the ground, then the glint
  follows the projection of 54 section 19.3.
- Given a fox or panda holding an item, when I look at it, then the item is drawn at its mouth or hold position.
- Given a charged creeper, when I look at it, then the charge swirl scrolls.

## Functional Requirements

- FR-001: The glint of items and armour exists on origin (CC_PIPE_GLINT, held and ground items); the fog fade of the
  glint and the stale glint of a locally moved stack are added.

## Open Questions

- Compass and clock SPECIAL glint: 54 section 19.3 gives the projection but not the unit of the projected position nor
  the decal pose factor outside the GUI (0.5) and first person (0.75).
- Fox mouth item and panda held item: 34-5 sections 4.4 and 5.4 say submit the item without an item display context or
  default display transform.
- All three are in CC-0037.

## State at the end of the polish run (2026-11-23)

- Built by wrap agent A (origin): glint of mobs' held items, dropped items and item frames (ITEM_STACK metadata
  decoded in proto, PB-ITEM-STACK-FOIL, core patch for dropped items), llama decor, the snow golem pumpkin, the
  enderman block, the copper golem's held items and antenna block, the baby and zombie villager armour layers.
- Left: T9903 (lanes/models5.md: compass and clock coordinates, the creeper swirl needing a repeat texture id, fog
  fade, stale slot glint) and T9905 (fox mouth item, panda held item, the biome tint of carried blocks, the hurt flash
  of head layers, the copper golem idle animation start rule).
