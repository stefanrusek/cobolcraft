#### Phase 3: US3-shim — texture upload with mip levels and sub-rectangle update

**Goal**: the client can upload a pack-resolution atlas and update animated cells (FR-010). **Independent Test**: `shim/tests/test_cc_vk_texture_ex.c` and `test_cc_vk_texture_update.c` read back the uploaded and updated pixels from the real MoltenVK device.

- [x] T0088 [P] [US3-shim] Write test `shim/tests/test_cc_vk_texture_ex.c`: a texture uploaded with `cc_vk_texture_ex(..., mip_levels = 1)` reads back identical to its RGBA input and `cc_vk_texture` still behaves as before
- [x] T0089 [P] [US3-shim] Write test `shim/tests/test_cc_vk_texture_update.c`: after `cc_vk_texture_update` of a rectangle only that rectangle reads back changed
- [x] T0090 [US3-shim] Extend `shim/tests/contract_shim_provider.c` with the new texture entry points' return values and argument shapes
- [x] T0091 [US3-shim] Implement `cc_vk_texture_ex` in `shim/src/cc_vk.c` (`cc_vk_texture` calls it with 1 level)
- [x] T0092 [US3-shim] Implement `cc_vk_texture_update` in `shim/src/cc_vk.c` (staging buffer and copy command)
- [x] T0093 [US3-shim] Gate: run `make gate-shim` and record the command and real output
