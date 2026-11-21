#### Phase 38: US11-core (e) — ores and ore drops

- [x] T0430 [US11-core] Write acceptance test `core/tests/acc_f2us11_ores.cob` (US11-2): each ore's height distribution (uniform or triangle), vein size and count per chunk, depth and biome limits (11) [FR-029, FR-030; SC-007]
- [x] T0431 [US11-core] Implement ore placement in `core/src/ores.cob`
- [x] T0432 [US11-core] Write edge-case test `core/tests/test_ore_edges.cob` (spec edge case): an ore exposed in a cave or aquifer keeps its exposure rule (11), and a vein crossing a chunk border is placed identically from either chunk
- [x] T0433 [US11-core] Write test `core/tests/test_ore_veins.cob`: the large ore vein and the copper/iron vein noise of 11 (fixture `core/tests/fixtures/veins`, independent Python evaluation `expected.py`; red output scratchpad/wg6/red-test-ore-veins.txt; real-data vein noise values are a Convergence test)
- [x] T0434 [US11-core] Implement the large veins in `core/src/ores.cob` (implemented in the new `core/src/ore-veins.cob` (ORE-VEIN-ROOTS, ORE-VEIN-RULE) with hooks in surface.cob (rule type), gen-job.cob (grids), and the ore_vein fields in content/ (CTWORLDGEN WGN-TEXT-3, worldgen-types.cob))
- [x] T0435 [US11-core] Write acceptance test `core/tests/acc_f2us11_ore_drops.cob` (US11-3): ore blocks broken in survival drop their items through the loot tables (11 §9, 26) [FR-029, FR-030; SC-007]
- [x] T0436 [US11-core] Implement the loot engine of 26 (conditions, functions, rolls) in `core/src/loot.cob`
- [x] T0437 [US11-core] Implement block drops from loot tables in `core/src/block-drops.cob`
- [x] T0438 [US11-core] Gate: run `make gate-core` and record the command and real output (`make gate-core` on 002-lane-loot after merging 002-client-polish (ore files T0430-T0434 present): lint 425 files 0 failed, `passed 3338 failed 0`, `coverage: 99 objects, 0 uncovered lines`, exit 0; log scratchpad/loot2/gate-core-4.log)
