---
spile: ticket
id: CC-0044
type: feature
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

# CC-0044: Small client leftovers: slot counts, sign editor, bed item, heads, slime bounce

## Summary

A set of small client polish items that lanes listed as not done and that need no new doc.

## User Stories

### As a Player, I want the screens and models to match Minecraft in the small details

- Given an item stack in a slot, when its count is drawn, then it sits where vanilla draws it (3 px right and 2 px
  down of today's position).
- Given a bed item, when it is in third person, in another player's hand, in a frame or on a shelf, then it is drawn
  as in Minecraft.
- Given a piglin or dragon head, a flower pot, a conduit or a banner pattern item, when it is drawn, then it has its
  model.
- Given a slime block, when I step on it slowly, then the horizontal slow-down of stepOn applies (24-5).

## Functional Requirements

- FR-001: Every item below has a red-first client test with expected numbers from the docs, not from the code.

## State at the end of the polish run (2026-11-23)

- Open task lines: T59502 (lanes/bugdiscount.md, UI-SLOT count offset, a global FR-014 change); T53031 and T53032
  (lanes/signtext.md: per-line styles never reach the renderer, the visible-section test and polygon offset of sign
  text); T62612 (lanes/bugbeditem.md); T42451 (lanes/bugbeitems.md, heads need half-pixel pivots; pot, conduit,
  patterns); T61220 (lanes/bugbounce.md, slime stepOn, client only); T59710 (lanes/bugguiitems.md, item tints on
  icons: check the note, part is done).
