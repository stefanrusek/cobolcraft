---
spile: ticket
id: CC-0039
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0041]
  supersedes: []
implementation: []
---

# CC-0039: The built mob rule functions are called by the tick

## Summary

The pure rule functions of doc 44 that are built and tested but have no caller in the tick are wired in, so the
behaviours they describe happen in play.

## User Stories

### As a Player, I want mobs to follow all the rules the docs give

- Given a rule function with tests and no caller (the Q7, Q8 and Q9 families, the X2 family, StrollAroundPoi and
  VillageBoundRandomStroll, GAME-EVENT-SENSORS), when the tick runs, then the rule acts on the mobs it governs.

## Functional Requirements

- FR-001: Each function is called where the doc places it, with a test through the real tick.
- FR-002: The expectations of the seeded spawn tests whose draw order changes are re-derived from the doc.

## State at the end of the polish run (2026-11-23)

- Open task lines: T24201 (lanes/p49j-a.md, Q9- not called anywhere, Q7 only inside q44-44-7.cob), T24222
  (lanes/p49j-b.md, Q8- not called outside q44-44-8.cob), T24405 (lanes/p49j-b.md, no tick calls the X2-* functions;
  the warden tracker per player is stored), T37009 (lanes/p49q.md, StrollAroundPoi and VillageBoundRandomStroll in
  q44-44-x2.cob have no tick caller), T56410 (lanes/p49z.md, GAME-EVENT-SENSORS in game-events.cob is an empty body;
  the sculk dispatch VIB-POST is in redstone-live-l.cob).
- T24303 (X1-FINALIZE-DEFAULTS) is ticked; the wiring changes the draw order of seeded spawn tests, which is why these
  were left for one deliberate pass.
