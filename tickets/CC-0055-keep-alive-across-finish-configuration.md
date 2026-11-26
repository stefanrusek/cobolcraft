---
spile: ticket
id: CC-0055
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-26
relations:
  depends_on: []
  relates_to: [CC-0054]
  supersedes: []
implementation:
  branch:
---

# CC-0055: A keep-alive due while Finish Configuration is on its way is still answered

## Summary

A connection whose keep-alive deadline falls between the core's Finish Configuration and the client's acknowledgement
stays connected: the core sends no configuration Keep Alive after Finish Configuration, or the keep-alive it sends is
one the client answers in the phase it is in.

## User Stories

### As a Player, I want to stay in the world I just joined

- Given a join whose spawn area takes about as long to make as the keep-alive interval, when the keep-alive deadline
  falls on the tick that releases Finish Configuration or on a later tick before the acknowledgement arrives, then the
  player is still in the world 300 ticks later.

## Functional Requirements

- FR-001: Between sending Finish Configuration to a connection and receiving its acknowledgement, the core queues no
  configuration Keep Alive for that connection, and the deadline is taken up again in play.
- FR-002: A test through the real `CORE-TICK` path with a real client connection puts the deadline on the release tick
  and fails when the connection is closed with `disconnect.timeout`.

## Notes

> [!NOTE]
> Found on 2026-11-26 while measuring CC-0054 (main aba05242, release build): a single-player join of a standard world
> ended with "Disconnected: Timed out" 300 ticks after the join. `CORE-TICK` runs `GEN-SPAWN-TICK` (which releases the
> held Finish Configuration) before `SESSION-TICK`, so a deadline on that tick queues Keep Alive (configuration id 0x04)
> behind Finish Configuration (`core/src/session.cob`, `core/src/config-phase.cob`). The client handles Finish first,
> is in play, reads id 4 as Block Changed Ack (`client/src/proto-packet.cob`) and never answers. Forced under a debugger
> (deadline set at the release): the timeout followed 15.2 s later. Seen once in six unforced joins; the first
> keep-alive is due about 15.2 s after start and the release came 1.3 to 2.4 s after it in three of them.
