---
spile: ticket
id: CC-0028
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

# CC-0028: Mob movement uses the travel input of the doc (zza and xxa)

## Summary

Mobs walk by the travel input of docs/protocol 18 section 3.1 (forward and strafe input scaled by the movement speed,
then the entity's travel), so observed walking speeds match vanilla for pig, zombie and the other mobs.

## User Stories

### As a Player, I want mobs to move at their vanilla speeds

- Given a pig, a zombie or any other walking mob, when it follows a path, then its speed per tick matches the doc's
  formula, not a per-species constant fitted in code.

## Functional Requirements

- FR-001: The travel input (zza, xxa) of 18 section 3.1 drives the mob step, as an engine of its own and not a change
  to every species brain.
- FR-002: The speed convention in use today (movement_speed times modifier, squared, over 0.454, the SM table) is
  replaced or proven equal.

## Open Questions

- 18 section 3.2.1 assumes zza equals the speed; cross-check against observed vanilla speeds for pig, zombie and
  others (doc-gaps note, group A).

## State at the end of the polish run (2026-11-23)

- Not started, on purpose: the lane brief said it is its own lane (wrap agent I3, scratchpad/handoffs/wrapI3-r5.md).
  Species brains return hx, hz and walk (1 walk, 2 stand) from STDMOB-STEP's EVALUATE, species ticks are called from
  about line 1365 of core/src/stdmobs.cob (wrapC-r4.md).
- Note for the work: a change to STDMOBS.cpy or WCSTATE.cpy recompiles most of core.
