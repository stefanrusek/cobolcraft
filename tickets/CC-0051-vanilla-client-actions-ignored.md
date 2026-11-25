---
spile: ticket
id: CC-0051
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-25
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0051: The actions of a vanilla client that the server discards take effect

## Summary

The play packets a vanilla client sends that the server reads and discards (09 section 4) do what the player expects.

## User Stories

### As a Player, I want my vanilla client's actions to work

- Given a vanilla client that breaks a block or swings at the air, when I watch that player, then their arm swings
  (Punch, 05c 0x2E; Swing Animation, 05b 0x7B).
- Given a vanilla client, when the player middle-clicks a block or an entity, then the matching item is picked.
- Given a vanilla client, when the player scrolls in a bundle, opens the advancements screen or the ping chart, then the
  server answers as the protocol documents describe.
- Given a vanilla client, when the player runs `/msg`, `/say` or `/me` and the client sends Chat Command Signed, then
  the command runs.

## Notes

> [!NOTE]
> Until the fix of 2026-11-25 each of these packets closed the connection. Whether a vanilla client on this offline
> server sends Chat Command Signed was not tried (09 Open question 9).
