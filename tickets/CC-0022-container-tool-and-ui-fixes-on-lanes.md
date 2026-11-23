---
spile: ticket
id: CC-0022
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0032]
  supersedes: []
implementation: []
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
