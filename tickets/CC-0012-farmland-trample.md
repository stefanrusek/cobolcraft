---
spile: ticket
id: CC-0012
type: bug
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: [CC-0011]
  relates_to: [CC-0001]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
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

## Progress of the bug wave (2026-11-25, agent A): player half landed, mob half and verification open

No doc gap: docs/protocol/29b part 2 section 9.3 (chance: one level-random nextFloat below d - 0.5; LivingEntity; permission: a player outside spawn protection, any
other living entity needs the game rule mob_griefing; size width x width x height > 0.512), 9.4 (turnToBaseBlock: dirt, flags 3, game event block_change), 9.5
(pushEntitiesUp: an entity overlapping the top 1/16 is lifted onto the dirt) and 14.7 state all of it.

Root cause (core): the fallOn rule `GB2-FARM-TRAMPLE` (growth-29b-2b.cob) was a library with no caller, so no landing ever reached farmland.
Fix so far: `GAME-EVENT-FALL` (game-events-move.cob), the one place where every entity (players and mobs, through ENTITY-MOVE) reaches Block.fallOn with
`EN-FALL-DIST` (Entity.fallDistance, kept in creative too), notes the landing in the EXTERNAL record `FARMLAND.cpy`; the callers that can land on farmland call the new
`FARM-LANDED` (core/src/farm-trample.cob) right after ENTITY-MOVE (`MOVE-PLAYER` for players, `MOB-PHYSICS` for the standard mobs). It draws the level random, applies
`GB2-FARM-TRAMPLE`, turns the cell into dirt (BLOCK-CHANGE, so the crop above loses its ground and breaks), posts block_change and lifts the entities in the top layer
(`FARM-PUSH-UP`; a player by Player Position). Gap: spawn protection is not modelled anywhere in the core (as for the turtle egg), a player is never protected.

Test (player half): core/tests/acc_bugfarmtrample_player.cob, 8 cases, green: d 0.4 never; d 1.0 with draw 0.37 tramples, with 0.58 not; a jump of 1.25 with draw 0.58
tramples, with 0.94 not; a fall of 4.0 tramples (and costs 1 health); the wheat above a trampled cell is gone after the block updates; a creative player tramples. Neighbour
families (game events, movement, falls, climb, egg step, villager farm, mob movement and swim, ride, growth): 551 pass.

Still to do (kept `implementing`): the mob tests (zombie, cow, villager landing from 2 blocks; a chicken and a baby never; mob_griefing off stops mobs but not players),
the red proof of the player test with the call removed, cover-changed and lint of the new file, `acc_bugstep_village` (its farmland feature with jump runs counts core
teleports; a trample lift is a legitimate teleport). Handoff: scratchpad/handoffs/bwA-r2.md.
