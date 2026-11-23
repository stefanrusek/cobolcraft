---
spile: ticket
id: CC-0042
type: feature
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

# CC-0042: Saved entities and players keep the values the docs list and act on them

## Summary

The keys that entity and player saves keep (NoAI, LeftHanded, CustomName in sent metadata, advancements and stats
files, backup rotation, forced game type, XpSeed, peaceful skip, leash give-up) are used by the game as docs/protocol
45 describes, not only stored.

## User Stories

### As a Server operator, I want a saved world to behave the same after a restart

- Given an entity saved with NoAI, LeftHanded or a CustomName, when the world reloads, then the behaviour and the sent
  metadata follow the saved value.

## Functional Requirements

- FR-001: Each kept value that changes behaviour has a test of the behaviour, not only of the round trip.

## State at the end of the polish run (2026-11-23)

- Task line T31090 (lanes/p49m.md): the behaviour of kept values and the files above; the 2026-11-19 analysis called
  it large and low value and suggested splitting it or cutting most of it. The round trip itself is built
  (core/src/entity-keep.cob, player-keep.cob, SPXTAB.cpy species rows; T31091 notes untested rows that share code with
  proven rows).
