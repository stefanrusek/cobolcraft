---
spile: ticket
id: CC-0032
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0022, CC-0038]
  supersedes: []
implementation: []
---

# CC-0032: Dispensers use shears and brushes and the remaining doc 30-4 behaviours

## Summary

Dispensers behave as docs/protocol 30 part 4 section 4 says for the items not yet built: shears, brushes, glass
bottles and water potions, TNT swallowed by a sulfur cube, and the random yaw draw.

## User Stories

### As a Player, I want a dispenser to do with an item what vanilla does

- Given a dispenser holding shears in front of a sheep, beehive or other shearable, when it fires, then the shear
  happens (4.18) and the shears lose durability.
- Given a dispenser holding a brush in front of a suspicious block or an armadillo, when it fires, then it brushes
  (4.19, with the quirks the doc lists).
- Given glass bottles or a water potion, when it fires, then 4.16 and 4.21 apply.

## Functional Requirements

- FR-001: The shear and brush programs work for a dispenser as well as for a player (MOB-SHEAR-USE and
  MOB-ARMADILLO-BRUSH are bound to a player row today, GC7-BEE-USE has no caller).
- FR-002: TNT-DISPENSE tries the sulfur cube first (4.14).

## Open Questions

- Glass bottle 4.16 and water potion 4.21 need potion contents, which today are a slot patch the docs do not describe
  (see CC-0038).

## State at the end of the polish run (2026-11-23)

- Built by wrap agent B and in lane p46h: the other 30-4 behaviours (armor stand, chests, boats, equipment, honeycomb,
  egg, snowball, experience bottle, shulker boxes, the sulfur cube swallow, the nautilus dispatch RL-DISP-MOB), tests
  acc_wrapb_dispense_*.
- Left on T29574 (lanes/p46h.md): shears 4.18, brush 4.19, glass bottle 4.16, the TNT swallow attempt 4.14, water
  potion 4.21, the random yaw draw of 4.2 and the doubled events of a fallback. Doc conflict recorded: 30-4 4.15 says
  the shulker box facing is always DOWN, 24 part 6 6.12 gives a registry rule; the registry rule is followed.
