#### Phase 75: US20-client — hand and held item

- [x] T3586 [US20-client] Write acceptance test `client/tests/acc_f2us20_hand.cob` (US20-1, US20-2): in first person the hand is in the render list at the lower right holding the selected item or block as a small 3D model after a depth clear, and breaking, placing or attacking plays the swing (12 §6) [FR-021]
- [x] T3587 [US20-client] Implement the hand pass in `client/src/hand.cob` and its submit order in `client/src/submit.cob` with `cc_vk_clear_depth`
- [x] T3588 [US20-client] Gate: run `make gate-client` and record the command and real output
