#### Phase 73: US18-client — F5 camera

- [x] T3576 [US18-client] Write acceptance test `client/tests/acc_f2us18_f5.cob` (US18-1): repeated F5 cycles first person, behind, in front, first person (13 §6) [FR-019]
- [x] T3577 [US18-client] Write test `client/tests/test_camera_clip.cob` (US18-2, spec edge case): the third-person camera raycasts against blocks, and inside a one-block-high space it shortens rather than passing through blocks (12 §7)
- [x] T3578 [US18-client] Implement the camera modes and clipping in `client/src/camera.cob` and `client/src/raycast.cob`
- [x] T3579 [US18-client] Write test `client/tests/test_self_model.cob`: the Player's own model is drawn in third person and not in first person
- [x] T3580 [US18-client] Draw the own player model in `client/src/entities-render.cob`
- [x] T3581 [US18-client] Gate: run `make gate-client` and record the command and real output
