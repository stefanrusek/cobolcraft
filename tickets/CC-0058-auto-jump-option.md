---
spile: ticket
id: CC-0058
type: feature
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

# CC-0058: The Auto-Jump option makes the Player jump up obstacles

## Summary

With Auto-Jump switched on, a Player who walks into an obstacle they can clear with a jump jumps it without pressing
the jump key.

## User Stories

### As a Player, I want Auto-Jump to work when I switch it on

- Given Auto-Jump is on, when I walk into a ledge one block high with room above, then I jump onto it.
- Given Auto-Jump is off, when I walk into the same ledge, then I stop against it.

## Functional Requirements

- FR-001: The rule that arms auto-jump is added to docs/protocol by a clean-room round first: 59 states only how an
  armed auto-jump is consumed (section 2.2 step 13) and that its trigger was not read (Open question 1).

## Notes

- Found while planning feature `specs/003-vanilla-movement`, whose scope is the movement document 13 section 1
  describes. The option is off by default (13 section 7.2).

> [!NOTE]
> Today the option `autoJump` is stored and listed by the client's options but no movement code reads it.
