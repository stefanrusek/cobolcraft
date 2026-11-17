#### Phase 53: US2-server — world-type key

- [x] T2931 [US2-server] Write test `server/tests/test_config_world_type.cob`: key `world-type` accepts `standard` and `cobolcraft`, default `standard`, rejects other values with the documented message; an existing world's recorded type wins (done 002-lane-sdd: the default is `auto`, written to the new file, per world-types WT-2 and WT-20, not `standard`; the invalid-value message is WT-20)
- [x] T2932 [US2-server] Implement the key in `server/src/config-file.cob`
- [x] T2933 [US2-server] Write acceptance test `server/tests/acc_f2us2_refusal.cob`: a standard world with packs not `ok`, or a foreign folder, makes the server stop with exit code 10 and the reason on the console (core-host-delta §2, world-types.md §2.1) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [x] T2934 [US2-server] Implement the refusal exit in `server/src/main.cob` (done 002-lane-sdd in `server/src/world-open.cob`; -3 (no or unknown WorldType) prints the "missing" text because core returns one status for both)
- [ ] T2935 [US2-server] Gate: run `make gate-server` and record the command and real output
