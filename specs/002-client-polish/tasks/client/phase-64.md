#### Phase 64: US9-client — inventory screen and recipe book

- [x] T3016 [US9-client] Write acceptance test `client/tests/acc_f2us9_inventory.cob` (US9-1, US9-3): the inventory screen is the 46-slot menu with the 2x2 grid, result slot and off-hand slot, laid out per 12 §5.6a; clicks send Container Click [FR-024, FR-025, FR-028; SC-005]
- [x] T3017 [US9-client] Rewrite `client/src/screens/inventory.cob` and `client/src/inventory-replica.cob` for the 46-slot menu and item stacks with components
- [x] T3018 [US9-client] Write acceptance test `client/tests/acc_f2us9_recipe_book.cob` (US9-2, SC-005): known recipes listed with makeable ones marked, tabs and toasts per Round GUI, choosing one sends Place Recipe and the grid fills (13 §3.8, §3.9) [FR-024, FR-025, FR-028]
- [x] T3019 [US9-client] Implement the recipe book panel in `client/src/screens/recipe-book.cob`
- [x] T3020 [US9-client] Write edge-case test `client/tests/test_recipe_book_edges.cob` (spec edge case): the recipe book with no known recipes shows the empty state; a bench-only recipe in the inventory screen is shown unavailable; a failed fill with a full inventory leaves the grid and shows nothing broken
- [x] T3021 [US9-client] Write acceptance test `client/tests/acc_f2us9_creative_throw.cob` (CC-0006): in creative a cursor stack released outside the window sends the drop [FR-024, FR-025, FR-028; SC-005]
- [x] T3022 [US9-client] Implement the creative throw in `client/src/screens/inventory.cob`
- [x] T3023 [US9-client] Remove the 001 crafting screen and the C key (FR-028, US9-4): delete `client/src/screens/crafting.cob`, `client/tests/acc_us10_crafting_screen.cob`, `client/tests/test_crafting.cob`, the C key binding in `client/src/screens/common.cob`, and the 16-recipe client table (`CL-MAX-RECIPES`)
- [x] T3024 [US9-client] Write contract test cases in `client/tests/contract_wire_client.cob` for the container and recipe-book fixtures
- [x] T3025 [US9-client] Gate: run `make gate-client` and record the command and real output
