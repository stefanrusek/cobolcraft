---
spile: ticket
id: CC-0012
type: bug
status: unverified
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

Still to do at that point (all done, see the next section): the mob tests, the red proof, cover-changed and lint, `acc_bugstep_village`.

## Fix and verification (bug wave, agent A round 2, 2026-11-25): unverified, the operator checks by playing

Root cause (core): the fallOn rule `GB2-FARM-TRAMPLE` (growth-29b-2b.cob) was a library with no caller, so no landing of a player or a mob ever reached farmland (the client and the shim are not involved: the client sends Move Player, the block change comes from the core as a Block Update and the lift as a Player Position).

Files: core/copy/FARMLAND.cpy (the EXTERNAL landing record), core/src/farm-trample.cob (FARM-LANDED, FARM-PUSH-UP), core/src/game-events-move.cob (GAME-EVENT-FALL notes the landing, GAME-EVENT-MOVED clears it), core/src/movement.cob (MOVE-PLAYER) and core/src/mobs.cob (MOB-PHYSICS, which every standard mob steps through) call FARM-LANDED right after ENTITY-MOVE.
Second round changes in FARM-LANDED: a LivingEntity is ENTITY-IS-LIVING (not only the standard-mob table), and the baby half box also covers the zombie family (EN-VARIANT 1 of zombie, zombie villager, husk) next to the animals' baby flag (MOB-DATA-VALUES).

Red tests (all through the real tick or Move Player path, level random seeded where the draw matters):
- core/tests/acc_bugfarmtrample_player.cob, 10 cases: d 0.4 never; d 1.0 with draw 0.37 tramples and with 0.58 not; a jump of 1.25 with draw 0.58 tramples and with 0.94 not; a fall of 4.0 tramples (1 health); the wheat above is gone after the block updates; a creative player tramples; mob_griefing off does not stop a player; a landing on a dirt path (same 15/16 shape) leaves it.
- core/tests/acc_bugfarmtrample_mobs.cob, 8 cases: a zombie, a cow and a villager that fall 2.5 blocks onto a farmland patch turn one cell into dirt and stand on it (101.0); a chicken (0.112), a baby cow, a baby zombie never; a dropped item never; a zombie with mob_griefing off never.
- Red proof: with the FARM-LANDED calls in MOVE-PLAYER and MOB-PHYSICS taken out, 9 of the 17 cases that existed then fail (3 mobs, 6 player: bwa-red1.log); the 8 "never" cases pass either way (the dirt path case was added after). The baby zombie case was red on its own before the baby test of the zombie family was added.

Checks (run in the worktree, FPFAST=1, JOBS=3):
- acc_bugfarmtrample_player + acc_bugfarmtrample_mobs: 18 pass (runs m3). Regression of the player half r16: 551 pass (game events, movement, falls, egg step, villager farm, mob movement, ride, growth).
- `make cover-changed SINCE=8025a43c ONLY="acc_bugfarmtrample_player acc_bugfarmtrample_mobs test_game_event_move"`: 77 pass, 0 uncovered changed lines; farm-trample.cob, the changed lines of game-events-move.cob, movement.cob and mobs.cob have no uncovered line in the full report.
- `make -C core lint`: 2767 files, 0 failed; `python3 tools/gen/gen_tables.py --check`: 0 differing files.
- tests/convergence/acc_bugstep_village.cob (runs v1, v2): v1 failed once, feature 6 farmland, run 3 (sprint jump), `teleports 1`: the landing from the hop trampled a cell and the core lifted the Player by one Player Position, which is the legitimate teleport of 9.5. The expectation is adapted for feature 6 only: teleports must equal the number of cells of the field that are dirt after the run (BS-DIRT-COUNT), so any teleport that no trample explains is still a failure and every other feature keeps 0. v2: 65 pass.

Gaps: spawn protection is not modelled in the core (as for the turtle egg), a player is never protected. Baby boxes are taken as half the adult box for every species (docs/protocol/19 lists other baby scales: horse 0.7, goat 0.55, turtle 0.3, armadillo 0.6, camel 0.6), so a baby horse never tramples here although its box (about 1.07) would; no per-species baby table exists in the core. Mobs of the cobolcraft stand-in set (MOB-INDEX rows) are LivingEntity here too but are not tested (the tests use the standard set). Items never trample (their physics is itemphys-41, not ENTITY-MOVE). The Block Update and the lift reach clients as the generic block change and Player Position packets; the client replica is not changed, and the lift of 1/16 as it looks on screen is for the operator to check.
