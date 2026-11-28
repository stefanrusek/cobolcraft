---
spile: ticket
id: CC-0057
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0060, CC-0062]
  supersedes: []
implementation: []
---

# CC-0057: Crowding entities, boats, minecarts and fishing hooks push the Player

## Summary

A Player is pushed by the bodies of other entities, boats and minecarts among them, is stopped by entities that are
solid, and is pulled by a fishing hook that has hooked them.

## User Stories

### As a Player, I want crowds and hooks to move me

- Given another entity overlapping me, when the tick runs, then I am pushed apart from it.
- Given a boat or a minecart that meets me, when it moves into me, then I am pushed or stopped as in Minecraft.
- Given a fishing hook that has hooked me, when its owner reels it in, then I am pulled toward the owner.

## Functional Requirements

- FR-001: The local player's movement and the server's velocity for the Player apply the entity push of docs/protocol
  59 section 13.4 and the hook pull of 59 section 13.1.
- FR-002: The pushes of boats and minecarts and the entity collision boxes that stop a Player are added to
  docs/protocol by a clean-room round first (59 Open question 3).

## Notes

- The operator left these out of feature `specs/003-vanilla-movement` (its spec, Assumptions, 2026-11-26). Pistons and
  shulker boxes, first recorded here, are built by that feature.

> [!NOTE]
> Today the client's movement code applies no entity push, entity collision or hook pull to the local player.
