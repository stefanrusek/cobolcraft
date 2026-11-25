---
spile: ticket
id: CC-0021
type: bug
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0009, CC-0031]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
  pr:
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

## Bug wave notes (2026-11-25, agent C, branch 003-play-test-bugs)

- bugstackplace (912a9c1f, c33c0f6a): still present on the tip (acc_stack_place red: passed 28 failed 57). Root cause in core: BLOCK-PLACE put
  the item into the neighbouring cell instead of adding one to the clicked block. Cherry-picked cleanly (lane file dropped: the ticket is the
  record): core/src/place-stack.cob (new), core/src/blocks.cob, core/tests/acc_stack_place.cob. Results: acc_stack_place passed 89 failed 0;
  `make cover-changed SINCE=origin/003-play-test-bugs ONLY=acc_stack_place`: 0 uncovered changed lines; core lint 0 failed; gen_tables --check clean.
- bugkelpplace (b8d31701, e6e0e9b5, 1d9f7c5f, 0c8edaaf): both bugs still present on the tip (acc_kelp_flowing_standard and acc_kelp_column_standard red: 15 failed
  of 95 with the three kelp tests). Root cause in core: SUP-PLACE-OK (support-29.cob) accepted a water plant only in a water source of level text "0", so kelp,
  seagrass and tall seagrass were refused in falling water (levels 8 to 15; 29b part 4 sections 3.2, 9.2, 9.3: full water); and nothing connected the kelp states
  (no head to kelp_plant conversion on a shape update, no body under kelp at placement, no body to head when the top went). Cherry-picked; one hand-resolved conflict in
  place-state.cob (family numbers: the tip uses 18 bed and 19 crafter, so kelp is family 20, table 47 rows). New: core/src/kelp-29b.cob (KELP-SHAPE, PS-KELP), hooks
  in blockupd-29.cob and place-state.cob, support-29.cob. Two tests adapted to the tip: acc_kelp_column_standard reads the Section Blocks Update (packet 86) the tip sends
  for two changed positions of one section (29 section 7.2) instead of a Block Update; acc_support_standard expects a placed kelp head with any age 0 to 24 (it
  expected age 0). Results: acc_kelp_* passed 97 failed 0; cover-changed ONLY=the three kelp tests: 0 uncovered changed lines; regression family (acc_place_*, acc_support_*,
  acc_us4_place*, acc_us9_place*, acc_crop_place_standard, acc_wrapb_*, test_blockupd_29_*, test_support_rules, test_cove_b_support, test_place_more,
  acc_bugfluidwalls_connect) passed 753 failed 1 before the acc_support_standard fix, then 0 failed; core lint 0 failed; gen_tables --check clean.
- bugleafdecay (d46996d3, a9353e2a): still present on the tip. The GC3-LEAF-* helpers of growth-29b-3.cob are called by nothing, so leaves never
  recompute their distance and never decay, and placed leaves are not persistent. Root cause in core. The lane test needs LEAF-CLASS and LEAF-RULES-OPEN, so the red
  run on the tip used two throwaway no-op stubs of them: passed 7 failed 12 (the symptom: distances stay 7, 73 leaves of a log-less canopy never decay, placed
  leaves are persistent=false). Cherry-picked d46996d3 with three hand-resolved conflicts (api.cob, blockupd-29.cob, place-state.cob): the hook effects 11 (taken by
  DG-HOOK on the tip) became 12 (random tick), 13 (scheduled tick), 14 (shape update); the place-state family numbers on the tip are 17 cocoa, 18 bed, 19 crafter,
  20 kelp, so leaves is family 21 (table 48 rows). New: core/src/leaves-29b.cob, core/tests/acc_bugleafdecay.cob; api.cob calls LEAF-RULES-OPEN. a9353e2a (the lane
  task list) is dropped: the ticket is the record. Results: acc_bugleafdecay passed 19 failed 0; cover-changed ONLY=acc_bugleafdecay: 0 uncovered changed lines;
  regression (test_growth_29b_*, test_blockupd_29_*, test_feat_tree*, acc_gen_trees_worker, acc_us12_*, test_worldsim_*, the place, support, kelp and stack
  families) passed 1936 failed 0; core lint 0 failed; gen_tables --check clean.
- bugfluidwalls (f617b81f): already on the tip as 51703cf0 (same subject; the later commits ae0e1457, d74577a3, f45193da extend it). Nothing to apply.
  acc_bugfluidwalls_connect passes on the tip (part of the regression runs above, 0 failed).
- bugbeditem (48b44f9d): already on the tip (SUP-PLACE-OK lets a bed foot through under rule 25, core/src/support-29.cob line 835). Nothing to apply.
  acc_bed_halves, acc_bed_sleep and acc_bugvlbed_house pass on the tip (129 passed, 0 failed). Open lane line T62612 (bed item in third person, in another hand,
  frame, shelf) is client item rendering, not part of this ticket.
- bugupdateorder, client part (21a8c0be, falling_block entities drawn by FALLING-BLOCKS-MESH): dropped, superseded. The tip draws falling blocks through
  ENTITY-FALLING-EMIT (client/src/entities-blocks9.cob, commit 8eec702e, 34-9 section 13) with tests test_entity_blocks_9, test_entity_edges_9, test_entmodel_34_9_1;
  the replica keeps the Add Entity data in EN-BSTATE (entities-replica.cob line 264). Applying 21a8c0be would draw each falling block twice.
- bugwaterstand (uncommitted: CTBSDATA.cpy, client test, convergence test): the report "the player can stand on water" does not reproduce on the tip. The
  CTBSDATA change (four SeaPickleBlock rows, collision as the outline) is already on the tip (rows from T4506, commit 43aad246), so it is dropped. The two lane tests
  are kept as regression tests: client/tests/test_physics_water_stand.cob (no level of water or lava has a collision shape, a Player put at the surface sinks, one
  dropped over the pool lands on the floor, Space rises, a Player over one sea pickle stands at 6.375) and tests/convergence/acc_bugwaterstand_pool.cob (the same
  through the single-player host path, 4 cases). The lane's last case failed in its worktree (y 6.625) because the test ran 100 ticks and sinking in water is 0.025
  a tick (105 ticks from y 9); it now runs 160 ticks and the debug DISPLAY lines are gone. There is no production change, so cover-changed does not apply.
  Results on the tip: test_physics_water_stand passed 5 failed 0; acc_bugwaterstand_pool passed 4 failed 0; client and convergence lint 0 failed.
