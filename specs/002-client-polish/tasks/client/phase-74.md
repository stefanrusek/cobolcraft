#### Phase 74: US19-client — off-hand swap

- [x] T3582 [US19-client] Write acceptance test `client/tests/acc_f2us19_swap.cob` (US19-1 to US19-3): F with no screen sends the swap action; F over a hovered slot in the inventory screen sends a Container Click swap with slot 45; the off-hand slot draws beside the hotbar [FR-020]
- [x] T3583 [US19-client] Write edge-case test `client/tests/test_swap_empty.cob` (spec edge case): F with an empty hand, an empty off hand, or both sends the swap and the screen shows no stale stack
- [x] T3584 [US19-client] Implement the F key and the off-hand HUD in `client/src/controls.cob` and `client/src/screens/hud.cob`, and the hovered-slot swap in `client/src/screens/inventory.cob`
- [x] T3585 [US19-client] Gate: run `make gate-client` and record the command and real output
