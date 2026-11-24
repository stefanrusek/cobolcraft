#### Phase 71: US16-client — Options and `options.txt`

- [x] T3560 [US16-client] Write contract test `client/tests/contract_client_surface.cob`: the documented key to action table (13 §7.3) and the `options.txt` round trip against `contract/fixtures/client/options-*.txt`
- [x] T3561 [US16-client] Write test `client/tests/test_options_file.cob`: read and write of `options.txt` (13 §7.1) for every option (SC-009)
- [x] T3562 [US16-client] Write edge-case test `client/tests/test_options_missing.cob` (spec edge case): a missing `options.txt` yields defaults and the game starts
- [x] T3563 [US16-client] Write edge-case test `client/tests/test_options_unreadable.cob` (spec edge case): an unreadable or corrupt `options.txt` yields defaults and the game starts
- [x] T3564 [US16-client] Write edge-case test `client/tests/test_options_range.cob` (spec edge case): an out-of-range value yields that option's default and the others keep their values
- [x] T3565 [US16-client] Implement `options.txt` load and save in `client/src/options.cob` and replace `OPTIONS-LOAD` and `OPTIONS-SAVE` in `client/src/game-dir.cob`
- [x] T3566 [US16-client] Write test `client/tests/test_options_migration.cob`: with no `options.txt`, the legacy `options.dat` `EnabledPacks` list is read once and never written again (R8)
- [x] T3567 [US16-client] Implement the read-only migration in `client/src/options.cob`
- [x] T3568 [US16-client] Write acceptance test `client/tests/acc_f2us16_options_screen.cob` (US16-1, US16-2, SC-009): Options opens from the title screen and the pause menu; view distance, sensitivity, FOV, GUI scale and every other option of 13 §7.2 and Round OPT change, apply at once and persist across a restart [FR-022]
- [x] T3569 [US16-client] Implement the Options screens in `client/src/screens/options.cob` and wire the buttons in `client/src/screens/title.cob` and `client/src/screens/pause.cob`
- [x] T3570 [US16-client] Write test `client/tests/test_key_bindings.cob`: the default key table of 13 §7.3 and rebinding persisted in `options.txt`
- [x] T3571 [US16-client] Implement the key table in `client/src/controls.cob`
- [x] T3572 [US16-client] Gate: run `make gate-client` and record the command and real output
