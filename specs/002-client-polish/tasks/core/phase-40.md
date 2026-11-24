#### Phase 40: US11-core (g) — debug world generator (test tool, plan "Operator addition: debug world")

**Goal**: a hidden `debug` world type whose chunks hold every block state of the standard set in state-id order, per `docs/design/debug-world.md` (our own record; nothing from the jar). **Independent Test**: `test_debug_grid`, `test_debug_codec`.

- [x] T0444 [US11-core] Write test `core/tests/test_debug_grid.cob`: every block and every state of the standard set (counts of 24 §17 and 46) appears exactly once at the position the record's formula gives, in state-id order, and the cell next to the grid is air
- [x] T0445 [US11-core] Implement the generator in `core/src/worldgen-debug.cob` and select it by world type in `core/src/worldgen-standard.cob`
- [x] T0446 [US11-core] Write test `core/tests/test_debug_no_terrain.cob`: no noise, climate, density, carver, ore or feature stage runs for a debug chunk, and a chunk outside the grid is empty
- [x] T0447 [US11-core] Make `core/src/worldgen-debug.cob` call no terrain stage (satisfies `test_debug_no_terrain`)
- [x] T0448 [US11-core] Write test `core/tests/test_debug_no_ticks.cob`: in a debug world `CORE-TICK` runs no block update, fluid, growth, redstone, mob, weather, spawning or generation-queue work and the world time does not advance
- [x] T0449 [US11-core] Add the debug-type bypass of the world tick in `core/src/world-tick.cob` and `core/src/api.cob`
- [x] T0450 [US11-core] Write test `core/tests/test_debug_open.cob`: `CORE-WORLD-OPEN` with `CS-WORLD-TYPE` `debug` writes `WorldType = debug`, opens the content set of the standard type, is refused with the packs status word when the packs are not `ok`, and reopens as `debug` (`core/tests/test_debug_open.cob`; it passed on its first run: the debug open was already in api.cob and level-data.cob; the success path with packs ok cannot be built over fixture trees, asserted at level.dat and the type decision)
- [x] T0451 [US11-core] Accept `debug` in `core/src/level-data.cob` and `core/src/api.cob` (opening the standard content set) (EVIDENCE ONLY: `WORLD-TYPE-DECIDE`, `WORLD-CONTENT-OPEN` and `LEVEL-DATA` accept debug already; `test_debug_open` and `acc_f2us2_world_type` pass)
- [x] T0452 [US11-core] Write test `core/tests/test_debug_codec.cob`: the grid chunks round-trip through `PB-PUT-CHUNK-24` and `PB-GET-CHUNK-24` with every 16-bit state identical (palettes above 256 distinct states use the direct form)
- [x] T0453 [US11-core] Make `test_debug_codec` pass in `core/src/chunks-stream.cob`; if it already passes when written, record that evidence and mark this task done
- [x] T0454 [US11-core] Gate: run `make gate-core` and record the command and real output
