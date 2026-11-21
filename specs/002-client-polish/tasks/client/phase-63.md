#### Phase 63: US8-client — break overlay

- [x] T3010 [US8-client] Write acceptance test `client/tests/acc_f2us8_overlay.cob` (US8-1 to US8-4): Block Destruction stages 0 to 9 draw the crack overlay on the block, stage -1 and a released button remove it, another player's stage draws too, and the overlay uses the pack's break-stage textures (12 §4, `faithful-pack-mapping.md`) [FR-023; SC-006]
- [x] T3011 [US8-client] Implement the break overlay in `client/src/break-overlay.cob` and its draw in `client/src/render-list.cob`
- [x] T3012 [US8-client] Write edge-case test `client/tests/test_overlay_many.cob` (spec edge cases): several players break different blocks at once and each block shows its own stage; progress interrupted by a held-item change, a changed target or another player's break removes the overlay
- [x] T3013 [US8-client] Write test `client/tests/test_dig_actions.cob`: the client sends Player Action start, abort and finish with sequence ids (13 §2.3) and aborts on a held item change
- [x] T3014 [US8-client] Implement the dig action sending in `client/src/controls.cob`
- [x] T3015 [US8-client] Gate: run `make gate-client` and record the command and real output
