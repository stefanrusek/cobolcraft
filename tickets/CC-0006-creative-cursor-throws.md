---
spile: ticket
id: CC-0006
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

# CC-0006: A creative player's carried stack can be thrown out of the inventory window

## Summary

In creative mode the client moves items on the inventory screen with Set Creative Mode Slot, so the cursor stack is
the client's alone and the server never knows it. Q over a slot works in both modes, but a stack dragged or clicked
outside the window in creative mode disappears instead of becoming a ground item (standin-content §9.1 says the
inventory-screen throw works in any game mode). A creative player should be able to throw the carried stack the same
way a survival player can.

## User Stories

### As a Player, I want to throw what I carry in creative mode

- Given a creative player carrying a stack on the inventory screen, when they release a left click or drag outside the
  window, then the whole stack appears as a ground item in front of them, as in survival.
- Given the same, when they right-click outside the window, then one item is thrown and the rest stays on the cursor.

## Functional Requirements

- FR-001: The server learns a creative player's carried stack, or the client sends a creative throw the server acts
  on, so that Container Click PICKUP at slot -999 throws it in creative as in survival. Any new wire use is documented
  in docs/protocol/09 first.

## Notes

> [!NOTE]
> Current behaviour (Phase 49, T1088): in creative mode the client predicts the outside throw and sends Container Click
> at -999, but the server's cursor is empty, so nothing is thrown and the stack is lost. Closing the screen puts the
> carried stack back in both modes (the creative client sends Set Creative Mode Slot for the slots it fills).
