#### Phase 7: US20-shim — depth clear for the hand pass

**Goal**: the first-person hand draws over the world (12 §6). **Independent Test**: `test_cc_vk_clear_depth.c`.

- [x] T0112 [US20-shim] Write test `shim/tests/test_cc_vk_clear_depth.c`: a near and a far quad drawn, depth cleared, a second quad behind the first draws over it (readback)
- [x] T0113 [US20-shim] Implement `cc_vk_clear_depth` in `shim/src/cc_vk.c`
- [x] T0114 [US20-shim] Gate: run `make gate-shim` and record the command and real output
