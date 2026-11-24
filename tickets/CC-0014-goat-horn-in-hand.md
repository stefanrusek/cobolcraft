---
spile: ticket
id: CC-0014
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0017]
  supersedes: []
implementation: []
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
