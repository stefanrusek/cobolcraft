---
spile: ticket
id: CC-0056
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0056: A spectator flies through blocks

## Summary

A Player in spectator mode passes through blocks and is not affected by them.

## User Stories

### As a Player, I want to look inside the terrain as a spectator

- Given I am a spectator, when I fly into a wall or the ground, then I pass through it.
- Given I am a spectator on a world hosted by CobolCraft, when I am inside a block, then I am not pulled back.

## Functional Requirements

- FR-001: A spectator's movement has no collision and no block effects (docs/protocol 30 part 8 section 14.1.1 step 1
  and section 14.1.11), and the server accepts its positions inside blocks.

## Notes

- Found while planning feature `specs/003-vanilla-movement`. That specification covers the movement of document 13
  section 1, which gives a spectator permanent flight but not passage through blocks.

> [!NOTE]
> Today a spectator collides with blocks: client/src/physics.cob PHYS-MOVE and core/src/movement.cob MOVE-PLAYER
> test collision whatever the game mode.
