---
spile: ticket
id: CC-0023
type: bug
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

# CC-0023: Superflat worlds spawn slimes and hostile mobs at the standard rates

## Summary

In a superflat world slimes and hostile mobs spawn by the standard rules (slime chunks, light level, caps and
persistent mobs), and the night sky darkens the spawn light level as in the standard world.

## User Stories

### As a Player, I want superflat worlds to spawn mobs as in Minecraft

- Given a superflat world at night, when time passes, then hostile mobs and slimes spawn at the standard rates and
  light rules.
- Given persistent mobs or mobs in unloaded chunks, when the cycle counts mobs against the caps, then they do not
  count (EN-PERSISTENT test in MS6-CYCLE).

## Functional Requirements

- FR-001: MS6-CYCLE skips unloaded-chunk and persistent mobs when it counts the mob cap.

## Notes

> [!NOTE]
> Operator report as recorded in the handoff of 2026-11-19 (lane bugslimes): superflat slime and hostile spawn rates,
> and the night sky darkening in the spawn light level.

## State at the end of the polish run (2026-11-23)

- Lane bugslimes: no commits beyond origin; uncommitted work in /Users/stefanrusek/Code/cobolcraft-bugslimes
  (core/src/mob-18-6.cob, core/tests/acc_bugslimes_cycle.cob, acc_bugslimes_day.cob, acc_bugslimes_persist.cob), not
  reviewed.
- Open lane line T58503 (bugflatspawn): MS6-CYCLE counts the mobs of the dimension including unloaded-chunk and
  persistent ones, no EN-PERSISTENT test on any ref.
