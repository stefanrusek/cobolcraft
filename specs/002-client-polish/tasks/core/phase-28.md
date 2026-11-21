#### Phase 28: US1-core — packs status

- [x] T0317 [US1-core] Write test `core/tests/test_packs_status.cob` for `CORE-PACKS-STATUS`: it delegates to `CONTENT-PACKS-CHECK` and returns the status word and the English console reason of `docs/protocol/22-extraction-tool.md` §9.2 for each of the five statuses over `contract/fixtures/content/`
- [x] T0318 [US1-core] Implement `CORE-PACKS-STATUS` in `core/src/packs-status.cob`
- [x] T0319 [US1-core] Write consumer test `core/tests/contract_content_consumer.cob`: open a set through a fixture generated directory and assert the status words and one block lookup (`contracts/content-api.md` §4)
- [x] T0320 [US1-core] Gate: run `make gate-core` and record the command and real output
