---
spile: ticket
id: CC-0004
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: []
  supersedes: []
implementation: []
---

# CC-0004: Players reliably see why the server shut down

## Summary

When the operator stops the server, every connected player should see the shutdown reason, not a generic "connection
lost". Today the server makes one flush attempt to deliver the Disconnect packet before closing the sockets (server
Phase 30). A player whose socket buffer is full at that moment misses the reason.

## User Stories

### As a Player, I want to know the server was stopped

- Given I am connected and the operator runs `shutdown`, when the server stops, then my client shows the shutdown
  reason.
- Given my connection cannot take the Disconnect within a bounded time, when that time passes, then the server closes
  my connection anyway and finishes shutting down.

## Functional Requirements

- Given a shutdown, when it runs, then it never waits longer than the bound for any one connection. The bound comes
  from the operator surface, not from code.

## Notes

> [!NOTE]
> Current behaviour: one `cc_net` write attempt per connection after the Disconnect is queued, then close.
