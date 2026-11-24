#### Phase 10: US8-proto — block destruction and player action

**Goal**: encode and decode the break stage and the dig actions with sequence ids (13 §2.3, §2.4).

- [x] T0137 [US8-proto] Extend `proto/tests/contract_wire_provider.cob` with the Block Destruction and Player Action fixtures (decode to fields, re-encode to the same bytes)
- [x] T0138 [US8-proto] Write test cases in `proto/tests/test_composites.cob` for `PB-PUT-BLOCK-DESTRUCTION` and `PB-GET-PLAYER-ACTION` (status, position, face, sequence)
- [x] T0139 [US8-proto] Implement the Block Destruction encoder and Player Action decoder in `proto/src/composites.cob`
- [x] T0140 [US8-proto] Gate: run `make gate-proto` and record the command and real output
