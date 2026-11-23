---
spile: ticket
id: CC-0025
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0037]
  supersedes: []
implementation: []
---

# CC-0025: Chat, title, boss bar and scoreboard HUD, particle options and piglin crossbow pose

## Summary

The client draws the chat (wrap, fade, history, delay queue), the title and action bar, boss bars and the scoreboard
(sidebar, teams, below-name, tab list) as docs/protocol 57 part 5 describes, decodes the 22 option-carrying particle
types of Level Particles, and poses a piglin's arms for a crossbow.

## User Stories

### As a Player, I want the standard HUD parts a server can show

- Given a server that sends a title, an action bar, a boss bar or a scoreboard, when the packets arrive, then the
  client draws them with the layout, timing and sprites of doc 57 part 5.
- Given a Level Particles packet with options (dust and the other 21 types), when it arrives, then the client decodes
  the options and an empty item option is a decode error.
- Given a piglin holding or charging a crossbow, when I look at it, then its arms take the crossbow poses.

## Functional Requirements

- FR-001: Chat validators trust all messages as NOT_SECURE, with history and wrapping per 57 part 5.
- FR-002: The 22 option-carrying particle types decode per 57 part 3 section 2.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-p70g (tip c2ca3b78, 19 commits, none on origin; lane ids T47000-T47499, brief in
  scratchpad/pending-lanes.md): 750c09f1 and the tests f1a2ae01, 0401c407, fe4d8bf1, 4bc9d8cf, 3bd6b575 (chat, title
  and action bar, boss bars, scoreboard of 57-5); 4bd22db4 (option-carrying particle decode); fbf20d95 (piglin
  crossbow arm poses and the charged_projectiles component in proto); d2f7e47c (view pose in the corrected order,
  death roll, hurt tilt); c2ca3b78 (glint layers stay out of the opaque loop).
- Overlap with origin: the first-person fire overlay (e3af1b61 on origin, 9f37bd2d on the branch) and the leather
  overlay layer (202a706a on origin, 23316bed on the branch) were later built directly on origin; keep origin's
  versions when merging. The chat, title, boss bar, scoreboard and particle option work exists only on the branch.
- Left: merge with conflict review and re-gate (client and proto). Doc 57 itself reached origin by a separate
  cherry-pick of docs-client d9198253.
