#### Phase 50: US19-core — off-hand swap

- [x] T2917 [US19-core] Write test `core/tests/test_offhand_swap.cob`: the Player Action swap exchanges the held hotbar item with slot 45 and sends Set Slot for both; Container Click swap with the off-hand slot in the inventory menu (13 §4, US19-1, US19-2)
- [x] T2918 [US19-core] Write edge-case test `core/tests/test_offhand_empty.cob` (spec edge case): swap with an empty hand and a full off hand, a full hand and an empty off hand, and both empty (nothing changes, no packet error)
- [x] T2919 [US19-core] Implement the swap in `core/src/menu-inventory.cob` and the Player Action handler
- [x] T2920 [US19-core] Gate: run `make gate-core` and record the command and real output
