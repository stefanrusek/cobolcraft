---
spile: ticket
id: CC-0014
type: bug
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0017]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
---

# CC-0014: A goat horn in the hand is raised to the mouth when used

## Summary

Holding a goat horn and pressing use shows the toot pose with the horn, in first person and for other players, and
plays the instrument with its cooldown.

## User Stories

### As a Player, I want my hand to show the goat horn being played

- Given a goat horn in my hand, when I press use, then the hand draws the toot pose (docs/protocol 12 section 6.6)
  holding the horn.
- Given another player doing the same, when I look at them, then their arm shows the toot pose.

## Functional Requirements

- FR-001: The client sends Use Item for the goat horn (CC-0017) and the use-pose table of the hand renderer has the
  toot horn pose.
- FR-002: The core plays the instrument and sets the cooldown (docs/protocol 25 section 6.3).

## Notes

> [!NOTE]
> Operator report (play-test of try21, 2026-11-20): no horn support in hand.

## State at the end of the polish run (2026-11-23)

- Not started as its own lane. Brief: scratchpad/pending-lanes.md, section bughornhand (ids T63800-T63899).
- Partial overlap: lane bugusein (branch 002-lane-bugusein, f01e0c39, not merged) makes the right button send Use Item
  and the release for goat horns; the pose drawing was not checked. The animation table in
  client/src/entmodel-34-2-anim.cob lists TOOT_HORN. Whether the first-person hand draws the pose is unverified.

## Investigation (bug wave, 2026-11-25)

Read of the docs and of the code, no code changed yet. Findings:

- Doc conflict with the requirement text. docs/protocol 12 section 6.6 has no toot-horn pose, and 12 section 6.13 step 4 says
  that `toot_horn` (like `spyglass`) gets nothing beyond step 1 of 6.3 in the first-person hand. So "the hand draws the toot
  pose of 6.6" cannot be built from the docs: the arm transform of a horn in use is the plain held one. What the operator
  sees raised to the mouth in the real game is a different item model while the horn is in use, chosen by the
  `using_item` condition of the item definition (docs/protocol 08 section 6.3 lists `using_item` by name only, 12 section
  6.12 describes the one case of the shield). No doc states what `using_item` reads, which model the horn's definition
  switches to, or the display transform of that model. DOC GAP (clean-room round needed): the item definition
  conditions (`using_item` semantics for the hand and for another entity's held item) and the use model of the goat horn.
- Documented and not built, core: no handler for Use Item with a goat horn (play.cob dispatch of packet 67 has none), so
  the instrument never plays and there is no cooldown (25 section 12.2: sound `item.goat_horn.sound.0` for the default
  `ponder_goat_horn`, source records, volume 16, pitch 1, game event `instrument_play`, cooldown floor(7.0 x 20) = 140
  ticks, use duration 140). The core also never sends the living-entity flags (Set Entity Data entry 8: bit 0 using item,
  bit 1 off hand) for a player (core/src/poses.cob sends entries 0, 6, 15, 16 only), so no viewer can pose another
  player's arm for any use (the client reads EN-LIVING in ENTITY-BLOCKING).
- Documented and not built, client: USE-ITEM-CLASS knows bow, crossbow, trident and shield only, so a right click with
  a horn sends no Use Item (CC-0017 covers the send for the other classes too). The humanoid arm pose TOOT_HORN (12
  section 7.5, 34-2 section 4.2: xRot = clamp(head.xRot, -1.2, 1.2) - 1.4835298, yRot = head.yRot - 0.5235988; constants
  in client/src/entmodel-34-1.cob) exists in EMD-A-POSE-ARM but nothing selects pose 8 (entities-models.cob sets ITEM
  and BLOCK only).
