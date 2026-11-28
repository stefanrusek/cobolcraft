---
spile: ticket
id: CC-0060
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0057]
  supersedes: []
implementation: []
---

# CC-0060: Weapons, commands and teleports change movement and fall damage as in Minecraft

## Summary

The things other than blocks and the effects and enchantments of feature 003 that change how a Player moves or falls
behave as in Minecraft.

## User Stories

### As a Player, I want my weapons and commands to move me as in Minecraft

- Given a trident with Riptide, a spear with Lunge, a mace smash or a Wind Burst, when I use it, then I am moved as in
  Minecraft and the fall damage that follows is Minecraft's.
- Given an operator changes my gravity, step height, scale, jump strength or another movement attribute, when I move,
  then my movement changes accordingly.
- Given I am teleported while falling, when I land, then the fall damage counts the whole fall.
- Given I leave a world while falling, when I join again and land, then the fall damage counts the fall so far.

## Functional Requirements

- FR-001: Each rule is taken from docs/protocol; those that 59 Open question 2 names as found and not specified are
  documented by a clean-room round first.
- FR-002: The wind charge and mace impulse rule of 59 section 12.4 limits the fall damage after such a push.

## Notes

- Found while planning feature `specs/003-vanilla-movement`, whose specification covers movement under the Player's
  own control, blocks, and the named effects and enchantments.
- 59 Open question 2 also names Wind Charged, Frost Walker and spear kinetic attacks. Elytra gliding, fireworks and
  riding are unchanged by feature 003.
- The server resets the fall at a teleport today; 59 section 12.2 found no reset in the plain teleport path.
- Minecraft disconnects a client that answers a teleport a second time with the newest id, or with values that are not
  finite (59 section 13.2). Feature 003 ignores a second answer and builds no disconnect.
