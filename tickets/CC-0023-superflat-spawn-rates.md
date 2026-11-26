---
spile: ticket
id: CC-0023
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
  pr:
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

## Fix and verification (bug wave, 2026-11-25, agent D)

Root cause (core, `core/src/mob-18-6.cob` MS6-CYCLE): the count that feeds the monster cap and the player's local cap included persistence-required mobs (`EN-PERSISTENT`: a name tag, a village's or
structure's mob, a caught one), but 18 section 6.1 step 1 counts only entities that are not persistence-required. 80 such zombies near the only player held the cap (70 x chunks / 289) and nothing
spawned, in a superflat world as anywhere. The count now skips them.

Tests (the lane's three, copied from the read-only worktree; real data pack, new superflat world, seed 12345): `core/tests/acc_bugslimes_persist.cob` (80 persistent zombies 99 blocks from the only player by day: the
slimes of the slime chunks still spawn within 400 ticks) is red on the tip (expected 1, observed 0) and green after; `core/tests/acc_bugslimes_cycle.cob` (night spawns of zombies, skeletons, spiders and creepers, then the player
1000 blocks away by day: the monsters left behind are despawn-checked beyond 128 blocks and the slimes fill the cap near the new place; light 0 to 7 after the sky darkening) and `core/tests/acc_bugslimes_day.cob` (a
full day of slime chunks: many slimes of sizes 1, 2 and 4, almost all in a slime chunk, and no light-bound monster) already pass on the tip, where the lane bugflatspawn's MOBS-TICK fix is. 9 cases pass, 0 fail.
`tools/coverage.py --changed-since HEAD core` after those three tests: 0 uncovered changed lines; lint of core clean. No shim or ABI change.

Not changed, and why: the open line T58503 and FR-001's "unloaded-chunk mobs". This core keeps every mob in its entity table whatever its chunk does (`CHUNKS-UNLOAD` leaves entities alone), so there is no
unloaded-chunk state of a mob to skip; the doc (18 section 6.1) says "every entity in the level" and names only the persistence rule. Far mobs leave the count by the despawn rule (the cycle test). If the
operator still sees too few hostile mobs after a long flight, the next suspect is that count of far mobs of the table, not the persistent ones.

