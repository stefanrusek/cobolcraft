---
spile: ticket
id: CC-0015
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
---

# CC-0015: Other players and the third-person figure have the vanilla height

## Summary

The player model is drawn at the 0.9375 scale of docs/protocol 12 section 7.3 step 4, so the third-person figure and
other players are not 6.7 percent too tall.

## User Stories

### As a Player, I want other players to be as tall as they are in Minecraft

- Given the third-person view or another player, when the figure is drawn, then its vertices are scaled by 0.9375
  about the feet.

## Functional Requirements

- FR-001: ENTITY-MODEL-EMIT applies the player's own scale to a "player" model row.
- FR-002: The workaround in client/src/preview.cob (the 0.9375 multiply with a comment to remove it) is removed with
  the fix.

## Notes

> [!NOTE]
> Found by a wrap agent on 2026-11-23 reading the code; not yet confirmed in a play-test: ENTITY-MODEL-EMIT draws the
> "player" row at scale 1.

## State at the end of the polish run (2026-11-23)

- Not started. Brief: scratchpad/pending-lanes.md, section bugplayerscale (ids T63900-T63949).
- Evidence at origin 30e4c31f: client/src/preview.cob line 163 multiplies by 0.9375 itself. Fixing the emit changes
  the expected numbers of many figure tests: re-derive them from the doc in an independent script, not from the code.

## Fix (bug wave, 2026-11-25)

- Root cause: client. ENTITY-MODEL-EMIT (client/src/entities-models.cob) built the "player" row (model code "H") with
  the pipeline of 12 section 7.3 steps 1, 2, 3 and 5 but not step 4 (scale 0.9375 in all axes, AvatarRenderer), so every
  other player and the third-person figure was 1/0.9375 (6.7 percent) too tall; only the inventory preview
  (client/src/preview.cob) multiplied by 0.9375 itself.
- Fix: for the model code "H" a scale (0.9375, 0.9375, 0.9375) operation is inserted before the final translate
  (0, -1.501, 0) (after scale (-1, -1, 1)), in ENTITY-MODEL-EMIT; the 0.9375 workaround and its comment are removed from
  PREVIEW-WIDGET (FR-002). test_inventory_preview is unchanged and green, so the preview is pixel-for-pixel the same.
- Red tests (client/tests/test_entity_pose.cob, expected values worked from the doc formula 0.9375 x (1.501 - y_m / 16) by
  an independent Python script): head top 1876 thousandths (observed 2001 before the fix), lowest vertex 357 millionths
  above the feet (observed 381 before the fix). The lowest vertex is not the sole line (y_m 24, 0.0009375) but the leg
  corner that the legs' zRot and yRot of 0.005 (12 section 7.5, 34-2) lowers to y_m 24.0099.
- Checks: test_entity_pose, test_inventory_preview, test_hand_arm, test_entity_shield, test_entity_anim,
  test_entity_player_skin, acc_f2us17_hitboxes: 219 passed, 0 failed. `make cover-changed SINCE=origin/003-play-test-bugs`
  with those tests: 285 objects, 0 uncovered changed lines. `make -C client lint` and `gen_tables.py --check` pass.
- Visual check (the operator's): another player standing beside you is 1.875 blocks tall to the head top, not 2.0.
