---
spile: ticket
id: CC-0048
type: bug
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

# CC-0048: A standard world keeps running while its mobs move

## Summary

Every mob the tick moves belongs to a dimension of the world, so ticking mobs after a player joins a standard world never
reads a dimension that does not exist and never ends the server.

## User Stories

### As a Server operator, I want a standard world to keep running after a player joins

- Given a new standard world, when a player joins and the mobs around it are ticked, then the server keeps running.

## Functional Requirements

- FR-001: The mob tick only moves an entity whose dimension is a dimension of the world.

## Open Questions

- Which step leaves the entity row with dimension 0 (for example a row freed during its own step).

## Notes

> [!NOTE]
> The current behaviour, seen on 2026-11-25 in a debug build of branch `fix/vanilla-client-config` (the branch changes
> configuration packets only): the server exited shortly after a scripted client entered play, with
> `libcob: src/world.cob:285: error: subscript of 'DM-MIN-Y' out of bounds: 0`. Call chain: `CORE-TICK`, `MOBS-TICK`,
> `MOB-STEP`, `STDMOB-STEP`, `MOB-PHYSICS`, `FLUID-TOUCHES-WATER`, `FLUID-CELL`, `WORLD-GET-BLOCK`. Intermittent: two
> of about ten joins of a fresh world (view distance 2). Not reproduced on `main`. An `-O2` build has no subscript check.
>
> Seen again on 2026-11-25 in the same branch while the server console summoned one entity of most types around a
> joined player (`execute at <player> run summon ...`): same error and call chain.
