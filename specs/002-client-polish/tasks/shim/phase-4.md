#### Phase 4: US4-shim — path opener

**Goal**: the client can start the system file browser on a folder (Q-2). **Independent Test**: `shim/tests/test_cc_open.c`.

- [x] T0094 [US4-shim] Write test `shim/tests/test_cc_open.c`: `cc_open_path("/usr/bin/true", dir)` returns 0 at once; a missing opener path returns `CC-NOTFOUND`; the call does not wait for the child
- [x] T0095 [US4-shim] Implement `cc_open_path` with `posix_spawn` in `shim/src/cc_open.c` and register it in `shim/Makefile`
- [x] T0096 [US4-shim] Extend `shim/tests/contract_shim_provider.c` with the `cc_open_path` shape
- [x] T0097 [US4-shim] Gate: run `make gate-shim` and record the command and real output
