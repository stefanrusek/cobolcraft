#### Phase 59: US4-client — Open Pack Folder

- [x] T2985 [US4-client] Write acceptance test `client/tests/acc_f2us4_open_folder.cob` (US4-1, US4-2, Q-2): the client state names the opener program; the test sets `/usr/bin/true`, presses Open Pack Folder, `resourcepacks/` is created if missing and the opener received the folder; a pack copied in is listed after refresh without a restart; one run line names the opener substituted [FR-008; SC-010]
- [x] T2986 [US4-client] Write contract test `client/tests/contract_opener_production.cob`: a fresh client state names exactly `/usr/bin/open`, and a missing opener gives the `CC-NOTFOUND` path shown on the screen without a crash
- [x] T2987 [US4-client] Implement the opener state, the button and `PACK-FOLDER-SCAN` refresh in `client/src/screens/pack-select.cob` and `client/copy/CLSTATE.cpy`
- [x] T2988 [US4-client] Gate: run `make gate-client` and record the command and real output
