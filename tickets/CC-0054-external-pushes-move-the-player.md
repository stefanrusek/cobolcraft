---
spile: ticket
id: CC-0054
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0029]
  supersedes: []
implementation: []
---

# CC-0054: Pistons, opening shulker boxes and crowding entities push the Player

## Summary

A Player is moved by the things that push it from outside: a moving piston (including the launch and drag of slime and
honey blocks on a piston), an opening shulker box and the bodies of other entities.

## User Stories

### As a Player, I want pistons and crowds to push me

- Given a piston pushing a block into the space I stand in, when it extends, then I am moved ahead of it.
- Given a slime block on a piston under my feet, when the piston extends, then I am launched.
- Given another entity overlapping me, when the tick runs, then I am pushed apart from it.

## Functional Requirements

- FR-001: The local player's movement applies the piston, shulker box and entity push rules of docs/protocol
  (30 part 3, 18 section 3.3 `pushEntities`).

## Notes

- Found while planning feature `specs/003-vanilla-movement`. Its acceptance scenario US1-15 covers blocks the Player
  walks on, jumps from, or moves into, through or against; being pushed by a moving block or an entity is none of
  these, so building it there would need the specification to say something different (constitution 1.4 b).

> [!NOTE]
> Today the client's movement code (client/src/physics.cob) applies no piston, shulker box or entity push to the
> local player.
