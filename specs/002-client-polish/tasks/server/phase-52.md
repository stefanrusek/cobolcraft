#### Phase 52: US1-server — generated-dir key and console texts

- [x] T2924 [US1-server] Write test `server/tests/test_config_generated_dir.cob`: the `generated-dir` key of `server.properties` (default `<game dir>/generated`) fills `CS-GENERATED-DIR`
- [x] T2925 [US1-server] Implement the key in `server/src/config-file.cob`
- [x] T2926 [US1-server] Write acceptance test `server/tests/acc_f2us1_startup_packs.cob` (US1-3, US1-4): at start-up the server prints the packs status line of `docs/protocol/22-extraction-tool.md` §9.2 for each of the five statuses and the cobolcraft type still starts [FR-001, FR-002; SC-012] (done 002-lane-sdd: the five statuses are tested through the cobolcraft type over contract/fixtures/content; the ok case prints no notice since 22 9.2 gives no ok text)
- [x] T2927 [US1-server] Implement the start-up check and console texts in `server/src/main.cob` and `server/src/console.cob` (done 002-lane-sdd in `server/src/world-open.cob` (SV-WORLD-OPEN, called by SV-START), not main.cob/console.cob)
- [x] T2928 [US1-server] Write contract tests (extended) `server/tests/contract_coreapi_consumer.cob` for the new settings fields and statuses
- [x] T2929 [US1-server] Free-port test fix (CC-0005): make `server/tests/` tests that listen on the default port 25565 choose a free port at run time and check the configured default value without binding; add `server/tests/test_default_port_free.cob`
- [ ] T2930 [US1-server] Gate: run `make gate-server` and record the command and real output, including a run while a listener holds port 25565
