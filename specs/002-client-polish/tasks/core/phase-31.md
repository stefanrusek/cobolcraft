#### Phase 31: US8-core — break progress and stages

- [x] T0365 [US8-core] Write test `core/tests/test_break_progress.cob`: progress per tick from the formula of `docs/protocol/13` §2.1 (hardness, tool speed, tier, effects, on-ground, in-water) with the worked examples of §9
- [x] T0366 [US8-core] Implement the progress formula in `core/src/breaking.cob`
- [x] T0367 [US8-core] Write edge-case test `core/tests/test_break_interrupted.cob` (spec edge case): break progress resets and sends stage -1 when the held item changes, when the target block changes, and when another player breaks the block first (13 §2.4)
- [x] T0368 [US8-core] Write edge-case test `core/tests/test_break_many.cob` (spec edge case): several players break different blocks at once and each stage goes only to the players who can see that block, per block
- [x] T0369 [US8-core] Write test `core/tests/test_break_sequence.cob`: Player Action start, abort and finish handling with sequence ids and acknowledgements (13 §2.3), a changed held item or target aborts
- [x] T0370 [US8-core] Implement the sequence handling in `core/src/breaking.cob`
- [x] T0371 [US8-core] Write acceptance test `core/tests/acc_f2us8_destroy_stage.cob` (US8-1 to US8-3): Block Destruction stage 0 to 9 goes to the breaker and to other players who can see the block; abort and finish send stage -1; a block broken by another player ends the progress (13 §2.4) [FR-023; SC-006]
- [x] T0372 [US8-core] Implement the stage broadcast in `core/src/breaking.cob`
- [x] T0373 [US8-core] Write contract tests in `core/tests/contract_wire_server.cob` for the Block Destruction fixture
- [x] T0374 [US8-core] Gate: run `make gate-core` and record the command and real output
