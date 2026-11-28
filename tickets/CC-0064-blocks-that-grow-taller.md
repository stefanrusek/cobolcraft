---
spile: ticket
id: CC-0064
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0062]
  supersedes: []
implementation: []
---

# CC-0064: Farmland, paths, mud, snow and sculk change into taller blocks as in Minecraft

## Summary

Every block change that makes a block taller in Minecraft happens on a CobolCraft server, and lifts the Player there.

## User Stories

### As a Player, I want the ground to change as it does in Minecraft

- Given farmland that dries out or can no longer survive, when its tick comes, then it turns back into dirt.
- Given a dirt path that can no longer survive, when it is placed or its tick comes, then it turns into dirt.
- Given falling snow and a snow height rule above one, when it snows on a snow layer, then the layer grows.
- Given a dripstone drawing water from mud, when the transfer happens, then the mud turns into clay.
- Given a spreading sculk charge or a placed sculk patch, when it converts a block, then the block turns into sculk.
- Given a Player on any of these blocks, when it grows taller, then the Player is lifted.

## Functional Requirements

- FR-001: Each change follows the list of docs/protocol 29b part 2 section 9.5.3 and the rules it cites.
- FR-002: Each change lifts entities by 29b part 2 section 9.5 and 59 section 13.6.

## Notes

- Found while planning feature `specs/003-vanilla-movement`, which builds the lift and calls it from the changes the
  server already performs: trampled farmland and an eye of ender filling an end portal frame.

> [!NOTE]
> The server performs none of the changes above: the rules for farmland ticks and mud to clay have no caller, falling
> snow never stacks, sculk catalysts are not ticked and `place feature` reports failure.
