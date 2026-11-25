---
spile: ticket
id: CC-0014
type: bug
status: unverified
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

## Bug wave, round 3 (2026-11-25), core half: the use state and the viewers' flags (doc 58)

Root cause of the missing viewer pose: core. The core had no use state of a horn and no living entity flags (entry 8) and sent no Set
Equipment for a player at all. Built from docs/protocol/58 sections 2.1, 2.2, 5.2, 5.8 and 6:

- `core/src/horn-use.cob`: `HORN-ITEM-USE` now starts the use (LivingEntity.startUsingItem: 140 ticks, `TS-HORN-USE-START` and `TS-HORN-USE-HAND` of
  `core/copy/CTOOLS.cpy`, ignored while another item is in use, `item_interact_start` at the player, then the existing sound, `instrument_play` and
  cooldown). New `HORN-USE-STOP` (stopUsingItem: `item_interact_finish` when a use was going) and `HORN-USE-TICK` (the used hand must still hold a
  goat_horn, completion at 140 ticks, then `USE-FLAGS-SYNC`). `HUNGER-CANCEL` (the shared stop of Player Action 6, a changed held slot, death,
  dimension change, a menu) calls `HORN-USE-STOP`; `HUNGER-TICK` calls `HORN-USE-TICK` once a tick for every alive player.
- `core/src/poses.cob`: `USE-FLAGS-GET` derives the byte of entry 8 from the use states that exist (a raised shield `TS-BLOCK-START` with its hand, a bow, crossbow or
  trident being drawn `TS-USE-START`, eating `PL-EATING-ITEM`, the horn): 1 = using an item, 2 = the used hand is the off hand, and with nothing in use bit 2
  of the byte last sent is kept (58 section 2.1: only the next start rewrites it). `USE-FLAGS-SYNC` sends a changed byte as Set Entity Data entry 8
  (`LIVING-DATA-BUILD`) to the players who see the player and to the player itself (18 section 9.2); when bit 1 rises it first sends Set Equipment (0x68) of
  the used hand (slot 0 or 1, the stack with its component patch through `SP-EXPORT`), the order of 58 section 2.2 and 2.3 (the viewer's start test needs the stack in the hand).
- The `instrument` component: 58 section 5.2 says the stack a viewer receives needs it and that leaving the prototype default in place is enough (a patch that
  removes it is the only way to lose it). The core sends the stack with the patch it has (an empty patch for a creative or given horn), so the prototype default
  stands and nothing is written; M44-GOAT-DROP-HORN needs no change for the viewer's 140 ticks. NOT BUILT (Open question, not guessed): the instrument a goat's
  horn carries (the registry order of the `instrument` entries and the sound event of each one are in no document; data component type `instrument` is id 63 in 46
  section 8.1), so every horn still plays `item.goat_horn.sound.0`.
- Gaps found, not built: (1) the core sends no Set Equipment of a player's hands or armour at any other time (join pairing, a held-slot change, an item swap): a viewer
  sees an empty hand until the first use of an item sets that hand's stack; the general equipment sync of players needs its own ticket. (2) A viewer who starts tracking a
  player already using an item is not sent entry 8 (58 section 2.3: the vanilla pairing order makes that start fail too). (3) Potion drinking and the brush are not part of
  the flags (no `TS-` state of the same shape; 58 section 6 lists them, behaviour not added).
- Red first: `core/tests/acc_bughorn_state.cob` (24 cases, real packets through the play path, a second player as the viewer) failed 19 of 24 with the core half
  removed (log scratchpad/bwb-r4/red1.log), passes 24 of 24 with it (green1.log). `acc_bughorn_use` expects `instrument_play` as the second event now (item_interact_start first).
- Checks: regression of 27 core modules that copy CTOOLS or call the use hooks (acc_bughorn_state, acc_bughorn_use, acc_bugusein_click, acc_eat_standard, acc_itemcomp_drink,
  acc_itemcomp_food, acc_us14_bow, acc_us14_crossbow, acc_us14_elytra, acc_us14_spear, acc_us14_tools_wire, acc_us14_combat_wire2, acc_us14_trident, acc_us15_emitters,
  acc_us15_emitters3, acc_us15_ravager_shield, acc_us16_throw_item, acc_us8_creative, acc_us8_eat, acc_us7_death_respawn, acc_wrapc_bowevents, acc_wrapc_windcharge,
  test_arrow_shield, test_poses, test_pose_eye, test_player_parts, test_tool_special_shield) passed 478 failed 0; `make -C core lint` 2787 files 0 failed;
  `gen_tables.py --check` 0 differing files.

## Bug wave, round 4 (2026-11-25), client half: the pose, the use count, the raised horn (doc 58)

Root cause of the missing pose and model on the client: the client had no use state of another entity (only the flags byte EN-LIVING), selected only the ITEM and BLOCK arm poses for a player, had the
left-arm yRot of TOOT_HORN and SPYGLASS with the right arm's sign and substituted the main arm for a two-handed pose also while an item is in use, and drew the model of an item the same whether or not it
was in use. Built from docs/protocol/58 sections 2.3, 3.2, 4, 5.1, 5.3, 5.4 and 8.1; commits 92023f77 (formulas) and the client half after it.

- Arm formulas, `client/src/entmodel-34-2-anim.cob`: EMD-A-POSE-ARM WHEN 8 and WHEN 7 use `head.yRot - sign * constant` (right +1, left -1; WS-SIGN); EMD-A-POSES poses the arm of the used hand first without
  the two-handed main-arm substitution when using (L-S(16) not 0), and substitutes only when not using (58 section 5.3, 34-2 section 4.2 as corrected). `client/tests/test_entmodel_34_2_4.cob`: the two cases that
  encoded the old text ("spyglass crouching and toot horn", "spyglass on the left arm only", the left arm's yRot) were re-derived by `scratchpad/bwb-r5/ref_arms.py` from the corrected documents (the script
  with the old rules reproduces the old expected values, with the new rules gives 0.785398180 and 0.471238904) and six cases added (doc 58 section 8.1 arm numbers right and left, left-handed sneaking pitch 80 yaw 30,
  pitch -90, using versus not using with a two-handed pose). Red 6 of 1768 before the fix, green 1768 of 1768.
- Pose selection, `client/src/entities-models.cob` (case "H"): WS-ST(16) = bit 0 of EN-LIVING, WS-ST(17) = the arm of the used hand (bit 1: main hand = main arm), pose 8 on the arm whose hand is the used hand
  with a remaining count above 0 and a goat horn in it (`ENTITY-HORN-POSE`, 58 section 5.1 step 3: it reads the count and the used hand, not bit 0).
- The viewer's use state, new file `client/src/entity-use.cob`, fields EN-USE-ACTIVE / EN-USE-ITEM / EN-USE-LEFT in `client/copy/CLSTATE.cpy`: `ENTITY-USE-ENTRY8` (called at every received entry 8 in
  `ENTITY-PACKET`: start test, 140 for a goat horn, 0 for a horn whose patch removes component 63 (EN-EQ-NOINST, set in `ENTITY-EQ-COMPONENTS`) and for any other item, an empty hand leaves the use unstarted
  until a later entry 8, clear test), `ENTITY-USE-TICK` (called by `ENTITIES-ANIM-TICK`: count down, stop when the used hand holds another item), `ENTITY-USING-HAND` (the `using_item` property for a hand's stack),
  `ENTITY-HORN-POSE`, `ITEM-GOAT-HORN`.
- The model while in use, new file `client/src/item-in-use.cob` (`ITEM-IN-USE-ID`): an item whose definition is a `condition` on `using_item` with a plain `on_true` model (only the goat horn of the five
  definitions with using_item; bow, crossbow, trident and shield are range_dispatch / select / special and are NOT done) gets a virtual item id (2040 to 2047, CL-USE-VIRT, table IS-USE-* reset where
  `models.cob` resets IS-SPRITE); `ITEM-SPRITE-OF` reads `model.on_true.model` of the real item for a virtual id, so ITEM-HAND-DISPLAY and ITEM-DISPLAY return the tooting model's transforms. First person:
  `HAND-EQUIP` sets CL-HAND-SHOWN / CL-OHAND-SHOWN (the in-use id while PL-USING and the shown stack is the live one, 58 section 2.5), `HAND-MESH` builds from them (and the still-hand cache key follows).
  Third person: `ENTITY-HELD-POSED` draws the in-use variant while `ENTITY-USING-HAND` says the entity uses the stack of that hand.
- Red first: `client/tests/test_entity_use_horn.cob` (22 cases through the real packet path: Set Equipment then Set Entity Data entry 8; arm frames against the document's angles through the chain of
  test_entity_shield, `scratchpad/bwb-r5/ref_frame.py`) failed 15 of 22 with the five hooks removed (log scratchpad/bwb-r5/red2a.log); `client/tests/test_horn_in_use_model.cob` (30 cases, real generated vanilla
  pack: the 58 section 4.3 table through ITEM-HAND-DISPLAY / ITEM-DISPLAY, the first-person mesh against the plain one: diagonal x 1/0.68, normal turned 35 degrees, centre moved 0.6463 block; the third-person
  quad: centre, diagonal ratio 0.5/0.55, normal turned 55 degrees, the plain horn's centre validating the chain) failed 7 of 29 (red2b.log; a thirtieth case, the stand-in set, was added after). Green: 22 of 22 and 30 of 30.
- Not done, by decision: (1) the explicit left-hand display entries are applied as authored (`ITEM-POSED-DRAW` uses a cached `thirdperson_lefthand` entry as it is and the first-person left entry is not
  cached; 12 section 8.2 says an explicit left entry is mirrored once more); an existing behaviour for every item with such an entry (test_entity_held_pose encodes it), so the in-use horn in the left hand
  (a left-handed player, the off hand) is posed with the authored left values; the mirrored-once-more question needs its own change and test update. (2) A player's own main arm (entry 15, HUMANOID_ARM
  serializer 42, 58 section 5.2.1) is not read by the replica (only a mob's BYTE entry 15 is), so another player is always drawn right-handed: the horn arm of a left-handed player is the right one until that is
  read. (3) The fallback quad of `ENTITY-HELD-EMIT` (an entity without arm frames) does not switch models. (4) No `using_item` model for the bow, crossbow, shield and trident. (5) The use count of items
  other than the horn is not modelled (no pose reads it).
- Still the operator's check in play: the look of the raised horn in first person (the tooting model's transform) and the arm pose of another player who toots (the third-person pose and the held horn),
  with the core half (Set Equipment and entry 8 sent at the use start). The gap that the viewer sees no hands or armour of another player until the first used item is CC-0053.
- Checks: `cover-changed` over 39 client modules (hands, entity held items and models, replica, item sprites, the 34-2 animation family, the two new tests): 3110 passed, 0 failed, 0 uncovered changed lines
  (scratchpad/bwb-r5/cover-c.log); `make -C client lint` 901 files 0 failed; `gen_tables.py --check` 0 differing files. Known failure NOT from this change, seen in the first cover run and alone:
  `client/tests/test_entities_digest.cob` (the expected digest of the entity mesh of every model in four states); its rows have no use state (EN-LIVING 0, EN-USE-* 0), so none of the new paths is reached, and the
  player model scale commit d271886c (CC-0015, another lane) changed the player mesh without taking the digest again (not confirmed by reverting this change); it was left out of the later run and needs its digest
  taken again by whoever owns CC-0015.
