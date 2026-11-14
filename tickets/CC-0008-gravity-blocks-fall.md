---
spile: ticket
id: CC-0008
type: bug
status: closed
owner: stefanrusek
resolution: done
blocked_by: []
created: 2026-11-12
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0008: Gravity blocks fall when the block beneath them is broken

## Summary

Sand, gravel and concrete powder are gravity blocks. When the block directly beneath one is broken or removed, the
gravity block should fall until it lands on a solid block, and keep falling through the column of gravity blocks above
it as support disappears.

## User Stories

### As a Player, I want gravity blocks to fall when their support is removed

- Given a sand, gravel or concrete powder block resting on another block, when the player breaks the block beneath,
  then the gravity block falls and comes to rest on the next solid block below.
- Given a column of gravity blocks, when the block beneath the lowest one is broken, then the whole column settles
  downward.
- Given a gravity block placed with air beneath it, when it is placed, then it falls at once.

## Functional Requirements

- FR-001: After any change that removes support beneath a gravity block, the server makes that block fall and sends the
  resulting block changes to clients.

## Notes

> [!NOTE]
> Current behaviour: gravity blocks stay floating in the air after the block beneath them is broken.
