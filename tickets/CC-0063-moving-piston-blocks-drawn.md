---
spile: ticket
id: CC-0063
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

# CC-0063: The Player sees pistons and the blocks they push move

## Summary

While a piston extends or retracts, the Player sees its head and the pushed blocks slide to their new places.

## User Stories

### As a Player, I want to see a piston move

- Given a piston that extends or retracts, when it moves, then the head and the pushed blocks are drawn on their way.

## Functional Requirements

- FR-001: The moving blocks are drawn at their offsets as docs/protocol 30 part 3 section 10.2 states.

## Notes

- Found while planning feature `specs/003-vanilla-movement`, which makes the moving blocks push the Player but asks
  for no change to how they look.

> [!NOTE]
> Today the client draws nothing between a block leaving its cell and its arrival.
