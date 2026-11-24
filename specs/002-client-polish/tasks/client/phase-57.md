#### Phase 57: US2-client — world type choice, remembered type, refusal

- [x] T2954 [US2-client] Write acceptance test `client/tests/acc_f2us2_create_screen.cob` (US2-1, US2-2, FR-003): with valid packs both types are offered and standard is the default; with packs not `ok` the standard choice stays selectable and Create is refused with the explanation text `cobolcraft.world_type.*` of how to build the packs, and nothing is created; the cobolcraft type creates [SC-011]
- [x] T2955 [US2-client] Add the type choice, the refusal text and the settings fill (`CS-WORLD-TYPE`, `CS-SEED-TEXT`) to `client/src/screens/create-world.cob`
- [x] T2956 [US2-client] Write test `client/tests/test_debug_select.cob` (plan "Operator addition: debug world"): holding Ctrl while clicking the world-type button on the create-world screen selects `debug`; without Ctrl the button cycles only standard and cobolcraft; the word `debug` appears nowhere in the screen's render list or built-in language; Create with `debug` selected is refused with the packs explanation when the packs are not `ok`
- [x] T2957 [US2-client] Implement the hidden Ctrl-click selection in `client/src/screens/create-world.cob` and the Ctrl state read in `client/src/controls.cob`
- [x] T2958 [US2-client] Write acceptance test `client/tests/acc_f2us2_world_list.cob` (US2-3): the world list shows each world's type; opening a standard world with packs not `ok` is refused with the reason (`docs/design/world-types.md` §8.2) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [x] T2959 [US2-client] Implement the type column and the refusal in `client/src/screens/world-list.cob` and `client/src/game-dir.cob`
- [x] T2960 [US2-client] Write test `client/tests/test_wt16.cob`: on a multiplayer join the client decides the world type from `minecraft:dimension_type` at Finish Configuration (WT-16) and opens the matching content set
- [x] T2961 [US2-client] Implement the WT-16 decision in `client/src/net-client.cob`
- [x] T2962 [US2-client] Add built-in-language entries `cobolcraft.packs.*` and `cobolcraft.world_type.*` to `client/src/packs/builtin.cob` (texts from `docs/design/builtin-ui-art.md` §7.2) with their test cases in `client/tests/test_builtin_files.cob`
- [x] T2963 [US2-client] Gate: run `make gate-client` and record the command and real output
