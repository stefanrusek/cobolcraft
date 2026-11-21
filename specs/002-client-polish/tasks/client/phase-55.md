#### Phase 55: US11-client (a) — replica, mesher and cell model re-base (scheduled first in this lane)

**Goal**: the client holds 16-bit states, any number of sections per dimension and three dimensions, decoding both the 001 and the 24-section chunk forms, so no later client gate sees a form it cannot read (lane note). **Independent Test**: `test_world_replica`, `test_mesher` over the 24-section fixture.

- [x] T2939 [US11-client] Write consumer test `client/tests/contract_content_consumer.cob`: opens a set through a `contract/fixtures/content/` tree, asserts status words and one block lookup
- [x] T2940 [US11-client] Write test cases in `client/tests/test_world_replica.cob` for a 24-section chunk through `PB-GET-CHUNK-24` (16-bit states, 4-bit light, biome containers, rows sized from the dimension's `min_y` and `height`) and for the 001 form
- [x] T2941 [US11-client] Re-base `client/src/world-replica.cob` on `contract/copy/CELLS.cpy` and delete `client/copy/CLCELLS.cpy`; size the replica from the dimension and the content set, no cap smaller than the standard content (`CL-MAX-SECTIONS`, `CL-MAX-STATES`, `CL-MAX-BIOMES` in `client/copy/CLCONST.cpy`)
- [x] T2942 [US11-client] Write test cases in `client/tests/test_mesher.cob` for a 24-section column: per-state opacity and cull tables built once at load from `CONTENT-*`, states above 255 mesh correctly, section height is the dimension's
- [x] T2943 [US11-client] Re-base `client/src/mesher.cob` on the new cell model and the per-state tables (rewrite of the "16-high section" assumption)
- [x] T2944 [US11-client] Update `client/src/protocol-client.cob` chunk handling to decode both forms and split the file by packet family into `client/src/protocol-world.cob`, `protocol-play.cob`, `protocol-config.cob` as it is touched (1,646 lines)
- [x] T2945 [US11-client] Write contract test cases in `client/tests/contract_wire_client.cob` for the chunk, registry and tags fixtures it receives
- [x] T2946 [US11-client] Update `client/src/sp-host.cob` for the new core API (settings, three dimensions) and its tests `client/tests/test_sp_host.cob`
- [x] T2947 [US11-client] Gate: run `make gate-client` and record the command and real output
