---
spile: ticket
id: CC-0035
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0037]
  supersedes: []
implementation: []
---

# CC-0035: Players show their cape, ears and elytra, and the skin options screen exists

## Summary

A player's skin parts are customisable: the Skin Customization screen sends the model parts, the main hand option is
offered, hat layers show in the tab list, and a player can wear a cape, ears and the elytra layer.

## User Stories

### As a Player, I want my player and others to look as chosen

- Given the options, when I open Skin Customization, then I can toggle the skin parts and the main hand, and the
  choice is sent and saved.
- Given a player with a cape, ears or elytra, when I look at them, then the layer is drawn.
- Given Player Info packets with actions other than 1, when they arrive, then the tab list takes them.

## Functional Requirements

- FR-001: The client sends UPDATE_HAT in the join packet and resends on a change (OPTIONS-SET + OPTIONS-SAVE are
  wired).
- FR-002: Armour of a slim player uses meshes that fit its arms.

## Open Questions

- A cape needs a skin download (docs/protocol 47 section 8 item 7); the elytra third-person attitude is an open doc
  gap (CC-0037).

## State at the end of the polish run (2026-11-23)

- Built (wrap agents A and D, origin): the player skin by UUID with slim or wide default skins (LOCAL-FIGURE-KEY,
  PLAYER-SKIN-FOR-UUID callers), the slim first-person arm and its sleeves, Client Information parts on the core side
  (PL-MODEL-PARTS, metadata entry 16).
- Left: T51007 (lanes/p70h.md; T51214 on lanes/p70i.md is its duplicate): no Skin Customization screen, no main hand
  option, no UPDATE_HAT in the join packet, Player Info actions other than 1 ignored, no cape, ears or elytra layer,
  and the preview extras (armour, held items, cape; the mount screen preview of 40-6 6.4).
