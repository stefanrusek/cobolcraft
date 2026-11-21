#### Phase 37: US11-core (d) — carvers and caves

- [x] T0425 [US11-core] Write test `core/tests/test_carvers.cob`: the cave and canyon carvers over the documented seed and chunk with the worked examples (11)
- [x] T0426 [US11-core] Implement the carvers in `core/src/carvers.cob`
- [x] T0427 [US11-core] Write test `core/tests/test_noise_caves.cob`: the large cavern, long tunnel and thin noodle passages from the density router (US11-1; 11). The caves are non-positive regions of final_density (11 section 2), already evaluated by the density stage (T0416, test_density_final covers the cheese, spaghetti, entrance, pillar and noodle terms); this test checks the fill of a chunk on the fixture `core/tests/fixtures/final`: stone exactly where the density is above 0 in 8 columns over 384 blocks, stone and open cells in deep rock. It passed on first run (no red possible: no new code is needed). The real-data check stays a Convergence test
- [x] T0428 [US11-core] Implement the noise caves in `core/src/noise-caves.cob` (EVIDENCE ONLY: no `noise-caves.cob` exists or is needed; the caves are part of the density router functions (density.cob grids for cheese, spaghetti and noodle nodes) and the fill (terrain.cob); `test_noise_caves` passes)
- [x] T0429 [US11-core] Gate: run `make gate-core` and record the command and real output
