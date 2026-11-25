---
spile: ticket
id: CC-0022
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0032]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
  pr:
---

# CC-0022: Furnace, brush, recipe book and F3 fixes saved on lanes reach the tree

## Summary

Four operator-reported bugs were fixed or begun on lanes that were never merged: the blast furnace and smoker cannot
be used, suspicious sand cannot be brushed, the recipe book lacks recipes, and F3 shows 0 fps.

## User Stories

### As a Player, I want these screens and tools to work

- Given a blast furnace or a smoker, when I use it, then its menu opens and it smelts as in Minecraft.
- Given a brush and suspicious sand or gravel, when I hold use on it, then every tenth tick brushes, the tenth
  completes with the loot, and letting go sends Release Use Item.
- Given the recipe book, when I open it, then it lists the recipes I know and marks what I can craft.
- Given the F3 overlay, when it is shown, then the frame rate is the measured one, not 0.

## Functional Requirements

- FR-001: Each fix keeps its red-first test and passes the module gates after the merge.

## Notes

> [!NOTE]
> Operator reports as recorded in the handoff of 2026-11-19: the blast furnace and smoker are not interactable
> (bugfurnaces); suspicious sand brushing does not work (bugbrush); the recipe book lacks recipes (bugrecipebook). The
> F3 report is the message of commit 9d1c519d: F3 showed 0 fps.

## State at the end of the polish run (2026-11-23)

- Commits not on origin by patch-id: bugbrush f0a7ddb9 (core: Use Item On starts the brush, dust and loot, a broken
  suspicious block drops nothing) and 5e9a6a53 (client: release use item for a held brush, T61003); bugfps 9d1c519d
  (the fps measurement holds the epoch clock difference in 64 bits).
- Uncommitted work in worktrees, not reviewed: /Users/stefanrusek/Code/cobolcraft-bugfurnaces (core/src/furnace.cob,
  menu-container.cob, menus.cob, core/tests/acc_bugfurnaces.cob) and /Users/stefanrusek/Code/cobolcraft-bugrecipebook
  (client/copy/CLSTATE.cpy, client/src/protocol-play.cob, client/src/screens/recipe-book.cob,
  client/tests/test_recipe_book_craftable.cob, core/tests/acc_bugrecipebook_unlocks.cob,
  tests/convergence/acc_bugrecipebook_craftable.cob and an untracked lane file).
- Left: merge or finish each, re-gate. The brush also needs the dispenser rules (CC-0032).

## Fix and verification (bug wave, 2026-11-25, agent D)

Each lane was checked against origin/003-play-test-bugs first, re-applied onto the tip and run there. The lane worktrees were only read.

**Blast furnace and smoker (lane bugfurnaces; core).** Three causes, all in core, all still present on the tip:
- `core/src/menu-container.cob` MENU-CONT-OPEN: a block the world generator wrote (a village's smoker and blast furnace, barrels, hoppers, chests without loot, the
  second half of a double chest) has no block entity, so Use Item On found nothing and opened no menu. The entity is now made on first use as if the block had been
  placed (BE-BLOCK-SET), for both halves of a double chest.
- `core/src/furnace.cob` BE2-PROVIDER-LOOKUP: the speed multiplier of the smoker and blast furnace (`cooking/speed_default`) is a `context_float_provider`, but only
  `context_int_provider` was searched, so both cooked at furnace speed (100 ticks did not finish a cook, burn time was not halved). It now falls back to the float registry.
- `FURN-AWARD` and `FURN-TAKEN` (furnace.cob, called by MENU-CLICK in menus.cob): taking items out of the result slot pays the experience of the recipes used
  (31-2 section 3.6, 40-2 section 2.4); the furnaces gave none.
Test `core/tests/acc_bugfurnaces.cob` (superflat world, standard data pack, 76 cases): red on the unfixed tip, 24 failures (every generated container pass 2 case opened nothing,
speed 10 instead of 20, a smoker and blast furnace did not finish in 100 ticks, no orbs); green after (76 pass). I added a generated double chest case, and corrected the lane
test's survey table (brewing stand 11, loom 18 and cartography table 23 are wired on the tip; the beacon opens nothing yet: there is no live beacon window, listed as 99)
and its experience case (it hard-coded recipe row 1, which has no experience on this content set; it now keeps the row the cook recorded and sets ten uses).

**Brush (lane bugbrush; core and client).** Still broken on the tip: no `brush-use.cob`, Use Item On with a brush did nothing, and removing a suspicious block rolled the
archaeology table as a container's contents (the reported treasure on break). Cherry-picks f0a7ddb9 (core: `core/src/brush-use.cob`, tick rules in growth-29b-1.cob and
blockupd-29.cob, the loot left alone by BE-BLOCK-SET, the brush state in CORESTATE.cpy) and 5e9a6a53 (client: release use item for a held brush, T61003); conflicts were only the
neighbouring state fields in CORESTATE.cpy and CLSTATE.cpy and the use-item lines in controls.cob and protocol-world.cob (both sides kept). Tests: `core/tests/acc_bugbrush_use.cob`
(32 cases through the real packet path: right click starts it, brushes on used ticks 5, 15, ..., dusted 1 to 3, the tenth completes with the rolled item, the brush loses 1
durability, early release decays, breaking drops nothing): red with BRUSH-START unwired in BLOCK-USE-ON, 18 failures; green with it. New
`core/tests/acc_bugbrush_branches.cob` (18 cases: the six faces of the view ray, reach 4.5 and 5.0 in creative, off hand and non-brush starts, the 200-tick limit, a step on a
block without an entity, the cooldown, rule registration once per open). Client `client/tests/acc_bugbrush_control.cob` passes. Note for CC-0017: the same client lines
(`PL-BRUSHING`) are generalised there by `PL-USING`; the brush also needs the dispenser rules of CC-0032.

**Recipe book (lane bugrecipebook; client).** The core is not the cause (`core/tests/acc_bugrecipebook_unlocks.cob`, 13 cases on real data, pass with and without the fix: it unlocks
exactly the recipes whose advancement criteria a held item satisfies). Root cause in the client: Recipe Book Add carries each requirement as a HolderSet (05b: a tag, a list of
up to 8 items, or one item) but `RECIPE-BOOK-READ` kept only the single-item form (`RK-REQ-ITEM`), so every recipe with a tag or list ingredient (planks from logs, sticks, the
crafting table, furnace, stone tools, torches, shield) was never craftable and the default "show craftable" filter hid it. Files: `client/copy/CLSTATE.cpy` (`RK-REQ-ALT`,
`RK-TAG-NAME`), `client/src/protocol-play.cob` (`RK-TAG-INDEX`, `RECIPE-BOOK-READ`), `client/src/screens/recipe-book.cob` (`RK-CRAFTABLE`: requirements matched to units by
augmenting paths as StackedContents does, 13 section 3.9). Tests: `client/tests/test_recipe_book_craftable.cob` (15 cases) and
`tests/convergence/acc_bugrecipebook_craftable.cob` (single-player host, survival with the starting kit plus 64 each of eight items): red on the unfixed client, 36 of the 64 craftable
crafting recipes marked; green after (64). The expected 64 comes from an independent Python model over the extracted data pack (88 recipes unlocked, 64 craftable); the lane's
draft expected 42, which left the starting kit (8 planks, a crafting table, 8 sticks, 16 logs) out of the stock. The test's join wait is 90 seconds because the machine was loaded.

**F3 shows 0 fps (lane bugfps; client).** Already on the tip as 3042961e (`WS-ELAPSED` is `BINARY-DOUBLE` in `client/src/debug-overlay.cob`) with `client/tests/test_fps_clock.cob`
(ae200437); the lane commits 9d1c519d and 4547bf62 have the same content, so the "not on origin" line above was stale. `test_fps_clock` passes (3 cases) in my runs.

Checks: `acc_bugfurnaces acc_bugbrush_use acc_bugbrush_branches acc_bugbrush_control test_recipe_book_craftable acc_bugrecipebook_craftable acc_bugrecipebook_unlocks test_fps_clock
test_smooth_player` 182 pass, 0 fail, and the changed-line report (`tools/coverage.py --changed-since origin/003-play-test-bugs core client`, run by hand with the convergence package
included because `make cover-changed ONLY=...` leaves it out) shows 0 uncovered changed lines; after the merge of the other agents' pushes the core tests above (147 cases) pass
again; lint of core, client and tests/convergence and `gen_tables.py --check` are clean. No shim or ABI change. Not done here: a beacon window (no live window yet), which is not part
of this ticket; the dispenser rules for the brush (CC-0032); the GPU-side checks (none were needed).

