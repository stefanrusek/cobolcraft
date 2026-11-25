---
spile: ticket
id: CC-0014
type: bug
status: implementing
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0017]
  supersedes: []
implementation:
  branch: 003-play-test-bugs
---

# CC-0014: A goat horn in the hand is raised to the mouth when used

## Summary

Holding a goat horn and pressing use shows the toot pose with the horn, in first person and for other players, and
plays the instrument with its cooldown.

## User Stories

### As a Player, I want my hand to show the goat horn being played

- Given a goat horn in my hand, when I press use, then the hand draws the toot pose (docs/protocol 12 section 6.6)
  holding the horn.
- Given another player doing the same, when I look at them, then their arm shows the toot pose.

## Functional Requirements

- FR-001: The client sends Use Item for the goat horn (CC-0017) and the use-pose table of the hand renderer has the
  toot horn pose.
- FR-002: The core plays the instrument and sets the cooldown (docs/protocol 25 section 6.3).

## Notes

> [!NOTE]
> Operator report (play-test of try21, 2026-11-20): no horn support in hand.

## State at the end of the polish run (2026-11-23)

- Not started as its own lane. Brief: scratchpad/pending-lanes.md, section bughornhand (ids T63800-T63899).
- Partial overlap: lane bugusein (branch 002-lane-bugusein, f01e0c39, not merged) makes the right button send Use Item
  and the release for goat horns; the pose drawing was not checked. The animation table in
  client/src/entmodel-34-2-anim.cob lists TOOT_HORN. Whether the first-person hand draws the pose is unverified.

## Investigation (bug wave, 2026-11-25)

Read of the docs and of the code, no code changed yet. Findings:

- Doc conflict with the requirement text. docs/protocol 12 section 6.6 has no toot-horn pose, and 12 section 6.13 step 4 says
  that `toot_horn` (like `spyglass`) gets nothing beyond step 1 of 6.3 in the first-person hand. So "the hand draws the toot
  pose of 6.6" cannot be built from the docs: the arm transform of a horn in use is the plain held one. What the operator
  sees raised to the mouth in the real game is a different item model while the horn is in use, chosen by the
  `using_item` condition of the item definition (docs/protocol 08 section 6.3 lists `using_item` by name only, 12 section
  6.12 describes the one case of the shield). No doc states what `using_item` reads, which model the horn's definition
  switches to, or the display transform of that model. DOC GAP (clean-room round needed): the item definition
  conditions (`using_item` semantics for the hand and for another entity's held item) and the use model of the goat horn.
- Documented and not built, core: no handler for Use Item with a goat horn (play.cob dispatch of packet 67 has none), so
  the instrument never plays and there is no cooldown (25 section 12.2: sound `item.goat_horn.sound.0` for the default
  `ponder_goat_horn`, source records, volume 16, pitch 1, game event `instrument_play`, cooldown floor(7.0 x 20) = 140
  ticks, use duration 140). The core also never sends the living-entity flags (Set Entity Data entry 8: bit 0 using item,
  bit 1 off hand) for a player (core/src/poses.cob sends entries 0, 6, 15, 16 only), so no viewer can pose another
  player's arm for any use (the client reads EN-LIVING in ENTITY-BLOCKING).
- Documented and not built, client: USE-ITEM-CLASS knows bow, crossbow, trident and shield only, so a right click with
  a horn sends no Use Item (CC-0017 covers the send for the other classes too). The humanoid arm pose TOOT_HORN (12
  section 7.5, 34-2 section 4.2: xRot = clamp(head.xRot, -1.2, 1.2) - 1.4835298, yRot = head.yRot - 0.5235988; constants
  in client/src/entmodel-34-1.cob) exists in EMD-A-POSE-ARM but nothing selects pose 8 (entities-models.cob sets ITEM
  and BLOCK only).

## Bug wave, round 2 (2026-11-25): the core half is built, the pose half waits on the docs

Checked first: `git log origin/003-play-test-bugs -- docs` has no commit after 2026-11-23 and nothing in docs/protocol states the
in-use item model, so only what the docs already say was built. The ticket stays `implementing`.

- Client Use Item: already done by CC-0017. controls.cob (CONTROLS-USE-KIND kind 2, `spyglass`, `goat_horn`, `potion`,
  `ominous_bottle`) sends Use Item on the right press with the horn in a hand and Player Action 6 on release (client/tests/
  test_use_items.cob case 12). USE-ITEM-CLASS needs no horn class: it names only the classes of USE-ITEM-INPUT (bow, crossbow,
  trident, shield) that pose the hand, and the horn has no pose of 12 section 6.6.
- Core (new): `HORN-ITEM-USE` in core/src/horn-use.cob, called from the Use Item dispatch of core/src/play.cob after
  RANGED-ITEM-USE, with `TS-HORN-COOLDOWN` in core/copy/CTOOLS.cpy (cleared by COMBAT-TS-CHECK in core/src/combat.cob).
  Per 25 part 7 section 12.2: a goat_horn in the hand that uses (hand 0 the held slot, hand 1 the off-hand) on its cooldown is
  passed on; else Sound 0x77 of `item.goat_horn.sound.0` (holder 846 = id 845 + 1, source records 2, position in eighths,
  volume 16.0, pitch 1.0) goes to every viewer except the player, the game event `instrument_play` is posted at the player with
  the player as source, and the horn gets a cooldown of floor(7.0 x 20) = 140 ticks, told to the player with Cooldown 0x16
  (group `minecraft:goat_horn`, 17 section on `use_cooldown`). A spectator, a stone in the hand and an empty hand do nothing.
- Red first: core/tests/acc_bughorn_use.cob (15 cases) with the dispatch left out failed 7 of 15 (the sound, the game event, the
  Cooldown packet, the replay after 140 ticks, another player's horn, the off-hand, the survival replay), the other 8 hold
  trivially. Green with the dispatch: passed 15 failed 0.
- Checks: `CC_GENERATED_DIR=.../scratchpad/integ2/gen JOBS=3 make cover-changed SINCE=origin/003-play-test-bugs ONLY=acc_bughorn_use`
  0 uncovered changed lines; `make -C core lint` 2781 files 0 failed; `gen_tables.py --check` clean; regression (the tests that copy
  CTOOLS or call COMBAT-TS-CHECK: acc_us14_combat_wire2, acc_us14_bow, acc_us14_tools_wire, acc_us14_elytra, acc_us15_emitters3,
  acc_us14_spear, acc_us14_trident, acc_us15_ravager_shield, acc_wrapc_bowevents, test_arrow_shield, acc_bugusein_click) passed 295
  failed 0 together with the new test.

What waits on a clean-room documentation round (not guessed):

1. The item in use on the client: what the item definition condition `using_item` reads (08 section 6.3 names it only, 12
   section 6.12 describes the shield case alone), which model the goat horn's definition switches to while it is used, its display
   transform, and what another entity's held item shows.
2. The rule that selects the humanoid arm pose 8 TOOT_HORN (12 section 7.5, 34-2 section 4.2 hold the formula, entities-models.cob
   sets ITEM and BLOCK only): which hand, which use animation, from which entity state.
3. The core's use state of a player (startUsingItem for the horn: 140 ticks, ends on release, completion or a held slot change)
   and its viewers' flags: Set Entity Data entry 8 bit 0 (using item) and bit 1 (off hand) for a player in core/src/poses.cob
   (which sends entries 0, 6, 15 and 16 only), plus the `item_interact_start` and `item_interact_finish` events that pair with
   it (30 part 8 section 14.3.8). 25 section 12.2 and 30-8 name the events and the 140 ticks, but the state is to be built once
   with the in-use model of the docs round so that bow, shield, eating and horn share it.
4. The instrument of a stack: 25 section 12.1 lists the eight instruments and the tag orders but no table of the sound event each
   one plays, nor the registry order of the `instrument` entries (wire id of the component), so every horn plays the default
   `ponder_goat_horn` sound; a horn dropped by a goat carries no instrument in the core (M44-GOAT-DROP-HORN, an existing gap).

## Doc gap closed (clean-room round 58, 2026-11-25)

The DOC GAP above is answered by the new document docs/protocol/58-in-use-item-models-and-arm-poses.md (read from the
artifact recorded in the README header; reader and reviewer rounds, three review rounds, small fix-ups after the third).
Where each question is answered:

- `using_item` semantics for the local hand and for another entity's held item, the stack identity rule, null owner in
  the GUI and the other contexts: 58 section 1.1 (entry points and the owner each passes), section 2.5 (the identity the
  properties test) and section 3.2 (`using_item`). The local player's use state is predicted by the client, not read
  from the flags (2.4); a remote viewer derives it from entry 8 (2.3). Loop order and which use tick the first rendered
  frame shows: 2.6.
- The other item-definition properties with exact arithmetic (`use_duration`, `crossbow/pull`, `use_cycle`, `selected`,
  `display_context`, `cooldown`, `carried`, the rest): 58 sections 1.2 and 3.1 to 3.13.
- The goat horn's in-use model, what it shows and its display transforms (first and third person, left and right, head,
  gui, ground, fixed) as numbers: 58 section 4 (4.1 definition, 4.2 the two models, 4.3 transforms and the difference
  table). The horn stack a viewer receives must carry the `instrument` component: 58 section 5.2 and 8.1.
- The third-person arm pose (TOOT_HORN, ordinal 8): which arm and in which order (5.3), the angle values per arm (5.4),
  where it falls in the animation order (5.5), the held-item layer transform (5.6), the entity pose and the cameras
  (5.7), the data path from the server (5.8). The living-entity flags are entity metadata entry 8: mask 1 = using an
  item, mask 2 = the used hand is the off hand, mask 4 = spin attack (58 section 2.1 calls the masks "bit 1" and
  "bit 2"; they are bit indices 0 and 1 of the byte, as in the Investigation text above). A remote player's main arm,
  which decides the arm: 5.2.1 (entity data entry 15).
- One table of in-use item model selection (bow, crossbow, shield, spyglass, trident and spears, brush, horn, food and
  drink, fishing rod, elytra, bundle): 58 section 6 (6.1 hands drawn in first person, 6.2 brush arm transform, 6.3
  spyglass head item, 6.4 display transforms of the in-use models). Worked examples for tests: 58 section 8.
- Corrections to older text made in the same round: 12 section 7.5 (the left arm's yRot sign of the TOOT_HORN and SPYGLASS
  rows, the idle-bob rule), 34-2 section 4.2 (the arm order rule and the per-arm yRot signs), 18 section 1.4 (entity data
  slot 15 and 16 owners); the full list is 58 section 7. Pointer lines were added in 08 section 6.3, 12 sections 6.6 and
  6.13, 25-7 section 12.2 and 57-1 section 3.4.
- Consequence for the work of this ticket: 12 section 6.13 stays right that the first-person arm transform of a horn is
  the plain held one; the visible change is the item model (`using_item` switches the model) and, for a viewer, the arm
  pose of 58 section 5. The core must send entry 8 for a player using an item (58 section 2.2, 5.8) and keep the
  `instrument` component on the stack it sends. Open questions that stay open are listed in 58 "Open questions" (14).
