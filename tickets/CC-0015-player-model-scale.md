---
spile: ticket
id: CC-0015
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0015: Other players and the third-person figure have the vanilla height

## Summary

The player model is drawn at the 0.9375 scale of docs/protocol 12 section 7.3 step 4, so the third-person figure and
other players are not 6.7 percent too tall.

## User Stories

### As a Player, I want other players to be as tall as they are in Minecraft

- Given the third-person view or another player, when the figure is drawn, then its vertices are scaled by 0.9375
  about the feet.

## Functional Requirements

- FR-001: ENTITY-MODEL-EMIT applies the player's own scale to a "player" model row.
- FR-002: The workaround in client/src/preview.cob (the 0.9375 multiply with a comment to remove it) is removed with
  the fix.

## Notes

> [!NOTE]
> Found by a wrap agent on 2026-11-23 reading the code; not yet confirmed in a play-test: ENTITY-MODEL-EMIT draws the
> "player" row at scale 1.

## State at the end of the polish run (2026-11-23)

- Not started. Brief: scratchpad/pending-lanes.md, section bugplayerscale (ids T63900-T63949).
- Evidence at origin 30e4c31f: client/src/preview.cob line 163 multiplies by 0.9375 itself. Fixing the emit changes
  the expected numbers of many figure tests: re-derive them from the doc in an independent script, not from the code.
