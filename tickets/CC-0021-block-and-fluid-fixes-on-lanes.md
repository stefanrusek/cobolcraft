---
spile: ticket
id: CC-0021
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0009, CC-0031]
  supersedes: []
implementation: []
---

# CC-0021: Block placement, update and fluid fixes saved on lanes reach the tree

## Summary

Several operator-reported block and fluid bugs were fixed on lane branches that were never merged. They are recorded
here so that they are merged, re-gated and closed or re-opened as separate bugs.

## User Stories

### As a Player, I want blocks to place and update as in Minecraft

- Given a sea pickle, turtle egg, candle or snow layer, when I use it on its own block, then one more is added (24-6
  sections 6.14 and 6.15, 29b part 7, 24-3 snow).
- Given kelp, seagrass or tall seagrass, when I place it in flowing water or in a column, then it places in falling
  water and the kelp head, body and kelp_plant states connect (29b part 4).
- Given leaves, when a log is removed, then they decay by distance with drops, and placed leaves are persistent (29b
  part 3 section 5).
- Given a wall, fence, pane or bar, when it is placed or a neighbour changes, then its sides follow the neighbours
  (24-7 sections 8.3 and 8.4, 24-3 9.1, 24-4 5.2).
- Given a falling block, when its support goes, then it is an entity that moves over time and the client draws it,
  with the update order and the kelp, bamboo and cane cascade of the docs.
- Given water, when the player stands on it, then the player sinks (no standing on water).

## Functional Requirements

- FR-001: Each fix keeps its own red-first test, and the tree after the merge passes the module gates.

## Notes

> [!NOTE]
> Operator reports as recorded in the handoff of 2026-11-19: the player can stand on water (bugwaterstand); sea pickles,
> candles, turtle eggs and snow do not stack (bugstackplace); falling blocks must be entities moving over time with a
> 2-tick scheduled delay, and the kelp, bamboo and cane break cascade must run in the same tick (bugupdateorder); kelp
> does not place in flowing water and the kelp and kelp_plant connection state is wrong (bugkelpplace). The reports
> behind bugleafdecay, bugfluidwalls and bugbeditem are in their lane files.

## State at the end of the polish run (2026-11-23)

- Commits not on origin by patch-id: bugstackplace 912a9c1f and c33c0f6a; bugkelpplace b8d31701, e6e0e9b5, 1d9f7c5f,
  0c8edaaf; bugleafdecay d46996d3 and a9353e2a (task list T61800-T61810); bugfluidwalls f617b81f (the rest of that
  lane is merged); bugbeditem 48b44f9d (the bed foot under rule 25; the rest is merged); bugupdateorder 21a8c0be (the
  client draws falling_block entities).
- Uncommitted work in worktrees, not reviewed: /Users/stefanrusek/Code/cobolcraft-bugupdateorder
  (core/src/support-29.cob, core/tests/acc_plant_columns_standard.cob, core/tests/acc_update_order_standard.cob:
  falling blocks as entities with a 2-tick scheduled delay and the update order of the brief) and
  /Users/stefanrusek/Code/cobolcraft-bugwaterstand (content/copy/CTBSDATA.cpy,
  client/tests/test_physics_water_stand.cob, tests/convergence/acc_bugwaterstand_pool.cob).
- Left: merge each branch, re-run its tests and the module gates after the merge (several lanes are more than 500
  commits behind origin at 2026-11-23), finish the uncommitted lanes, and write the scaffolding stack placement as
  CC-0031. Open lane lines: T62612 (bed item in third person, in another hand, frame, shelf), T40210 (placement
  blocked by entities other than players and mobs: partly done).
