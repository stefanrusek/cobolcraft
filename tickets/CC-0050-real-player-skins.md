---
spile: ticket
id: CC-0050
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-25
relations:
  depends_on: []
  relates_to: [CC-0035]
  supersedes: []
implementation: []
---

# CC-0050: A player's own skin is shown to the others

## Summary

A player who has a custom skin on their account is drawn with that skin in a CobolCraft world, not with the default skin
chosen from the offline UUID.

## User Stories

### As a Player, I want to see my friend's own skin

- Given a vanilla client with a custom skin that joined my world, when I look at that player, then their skin and arm
  model are drawn.
- Given no network or a failed download, when I look at a player, then the default skin of docs/protocol 47 section 2 is
  drawn and the connection stays open.

## Functional Requirements

- FR-001: Every skin failure falls back to the default skin (47 section 8 item 5).

## Open Questions

- The server is offline mode only and sends profiles with no properties (09 section 1). A `textures` property has to
  come from the Mojang session service, which means a network request that carries the player's name or UUID. The
  operator decides whether CobolCraft makes it, and which side makes it.
- A vanilla client draws a remote player's skin only from a signed property (47 section 3.3).

## Notes

> [!NOTE]
> The current behaviour is what 47 section 8 describes for an offline-mode server. The play test of 2026-11-25 showed a
> vanilla client's player as `entity/player/wide/steve`, which is the default for that offline UUID.
