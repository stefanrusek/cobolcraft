---
spile: ticket
id: CC-0012
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: [CC-0011]
  relates_to: [CC-0001]
  supersedes: []
implementation: []
---

# CC-0012: Farmland turns to dirt when an entity lands on it

## Summary

Farmland is trampled to dirt when a qualifying living entity lands on it (the player, villagers, zombies, animals),
with a chance that rises with the fall distance past the documented threshold, subject to the mob-griefing rule for
entities that are not players. A jump or a one-block drop can trample.

## User Stories

### As a Player, I want farmland to be trampled by landing entities as in Minecraft

- Given farmland, when a player lands on it from a jump (1.25 blocks) or a drop, then it turns to dirt with the
  documented chance, the crop above breaks and drops, and clients get the block update.
- Given a villager stepping off a neighbouring block, a zombie or a cow, when it lands on farmland, then the same rule
  applies, and mob griefing off stops mobs but not players.
- Given a chicken (below the size threshold) or an item, when it lands, then nothing is trampled.

## Functional Requirements

- FR-001: The landing hook exists for players (the Move Player on-ground transition) and for mobs (the ground-entity
  tick), calls the farmland fallOn rule of docs/protocol 29b part 2 section 9.3 and replaces the block with dirt.
- FR-002: Fall distance is correct (CC-0011), because a wrong distance would trample on plain walking.

## Notes

> [!NOTE]
> Operator answer (2026-11-19): farmland is never trampled, for the player or for mobs; the feature is missing, not a
> wrong rate.

## State at the end of the polish run (2026-11-23)

- Not started. Brief: scratchpad/pending-lanes.md, section bugfarmtrample and its UPDATED section (ids T63600-T63699).
- Evidence of the gap at origin 30e4c31f: GB2-FARM-TRAMPLE (core/src/growth-29b-2b.cob, the fallOn rule: draw, living,
  permission, volume test) is built and tested as a library but has no caller anywhere in core/src. Only the turtle
  egg trample (M44-EGG-TRAMPLE, movement.cob) is wired.
- Do it after CC-0011 or share its fall-distance fix.
