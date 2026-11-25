---
spile: ticket
id: CC-0017
type: bug
status: unverified
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0014]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
  pr:
---

# CC-0017: Boats, bows, shields and other held items start their use from the real window

## Summary

A right click with a boat, firework rocket, armor, bow, crossbow, trident, shield, spyglass, goat horn, brush or
potion sends Use Item (and the release when the button is let go), and a click that an interactive block took does not
also use the held item.

## User Stories

### As a Player, I want to use the item in my hand

- Given a bow, crossbow, trident, shield, spyglass, goat horn or brush in my hand, when I hold the right button, then
  Use Item is sent, and Release Use Item when I let go.
- Given a boat in my hand, when I click solid ground, then it is placed at the surface where the pick ray meets it.
- Given an ender pearl, snowball or egg, when I click a door or a crafting table, then the block takes the click and
  nothing is thrown.

## Functional Requirements

- FR-001: CONTROLS-INPUT sends Use Item for the use lists of docs/protocol 25 section 6.3, 21 section 8.12 and 17, and
  the release for held items.
- FR-002: A Use Item On that a block took spends the click, so the Use Item of the same tick is ignored.

## Notes

> [!NOTE]
> Found from lane bugeye (merged): the real window sent Use Item only for thrown items (eye, pearl, egg, snowball,
> potions, fishing rod). Boats, bows, crossbows, tridents and shields sent nothing.

## State at the end of the polish run (2026-11-23)

- Built on branch 002-lane-bugusein (tip 4a903140, six commits not on origin by patch-id; the rest is merged):
  f01e0c39 the right button sends Use Item for boats, rockets, armor, bows, crossbows, tridents, shields, spyglass,
  goat horns, brushes and potions and the release (test_use_items, red first 17f5223e); 1ba1e58e a Use Item On that a
  block took spends the click (acc_bugusein_click, red 037f45c9); 4a903140 a boat used on solid ground is placed at
  the pick-ray surface (T63305). Lane ids T63300-T63399; brief in scratchpad/pending-lanes.md.
- Left: the branch was stopped before integration, so it has not been merged into origin or run through the gates
  after a merge. The pull animation and pose of bows and shields were not part of it (see CC-0014 for the horn pose).

## Fix and verification (bug wave, 2026-11-25, agent D)

The six lane commits (17f5223e, f01e0c39, 037f45c9, 1ba1e58e, d5b9a4ed, 4a903140) were re-applied onto the tip, tests first, and run there. Root causes, in client and core:
- Client (`client/src/controls.cob` CONTROLS-INPUT): the right button sent Use Item only for buckets and the thrown items. Now `CONTROLS-USE-KIND` names, by item key, what the press sends: kind 1 (Use Item only) for buckets,
  the thrown items, boats and rafts, firework rockets, armor and elytra; kind 2 (Use Item, then Player Action 6 release use item when the button is let go, the held item changes or the screen is left, `PL-USING`)
  for the spyglass, goat horn, potion and ominous bottle; kind 3 for the brush.
- Core (`core/src/blocks.cob` BLOCK-USE-ON, `play.cob`, `core/copy/CTOOLS.cpy` `TS-CLICK-TICK`): a Use Item On that a block took (a menu, switch, sign, bell, bed, a placed block, a started brush ...) spends the click: the Use Item
  the client sends in the same tick is ignored, so a pearl, snowball or egg used on a door or crafting table no longer also flies (FR-002).
- Core (`core/src/mob-21-boat.cob` BOAT-ITEM-USE): the pick ray stopped one step inside a solid cell, so the boat's box overlapped the ground and a boat used on solid ground was refused; the point is now brought back to the
  surface by halving the step (44 part 8).

Tests (red first, on the unfixed tip): `client/tests/test_use_items.cob` and `core/tests/acc_bugusein_click.cob`, 32 failures together (26 client: no Use Item for boats, rockets, armor, elytra, spyglass, horn, potion, ominous bottle and no release;
6 core: the pearl, snowball and egg thrown after a door, table or lever click, and the boat refused on stone); green after (49 cases with the two I added: a boat used with the eye inside the ground is refused and kept; a bucket sends Use Item).
`tests/convergence/acc_bugusein_use.cob` (the real single-player host and mouse: a boat on the ground makes one oak_boat and is used up; a bow held ten ticks and let go shoots exactly one arrow and uses one arrow; a pearl on the ground is thrown; a pearl
on a crafting table opens it and is not thrown) passes, with `acc_bugeye_throw`, `test_use_item`, `test_thrown_use` and `acc_bugbrush_control`.

Deviations from the lane, because the tip had moved: the bow, crossbow, trident and shield (and a shield in the off hand) are already driven by `USE-ITEM-INPUT` (use-item.cob: ammo, pose state), so the lane's CONTROLS-INPUT lines for them were left out, otherwise
a press would send two Use Items; `test_use_items` now checks that a trident sends exactly one Use Item and one release. The brush is kind 3: the docs start it with Use Item On only (17 section 3.5, 25 part 8 section 7), so a press at a block sets
`PL-USING` (it replaces the CC-0022 lane's `PL-BRUSHING`) and the release is sent, and in the air it sends nothing; a started brush counts as a taken click. The convergence test now levels the ground (a stone floor with air above) first: its terrain
came from a random seed (the host has no seed field), and a boat whose box would overlap sloping ground is refused, as in Minecraft, which made the lane's boat case flaky.

Checks: the tests above plus `test_smooth_player` and the brush tests: 176 pass, 0 fail in the instrumented run; the changed-line report (`tools/coverage.py --changed-since origin/003-play-test-bugs core client`, run by hand with the convergence
package included) left two lines, both covered by the cases I then added (bucket kind, the boat clamp); lint of core, client and tests/convergence clean. No shim or ABI change. Not done: the goat horn pose (CC-0014), the spyglass zoom, and the bow
and shield poses, which are other lanes' work on the tip.

