#### Phase 5: US5-shim — mip chain and sampler

**Goal**: textures do not shimmer or bleed at any distance (FR-011). **Independent Test**: readback of mip level 1 and the sampler state.

- [x] T0098 [P] [US5-shim] Write test `shim/tests/test_cc_vk_mips.c`: with `mip_levels` 4 a known 8x8 pattern reads back a box-filtered level 1 and level 2 (`docs/protocol/12-client-rendering.md` §2.4)
- [x] T0099 [P] [US5-shim] Write test `shim/tests/test_cc_vk_mip_update.c`: `cc_vk_texture_update` on a multi-level texture regenerates the touched mip levels
- [x] T0100 [US5-shim] Implement the box-filter mip chain generation in `shim/src/cc_vk.c`
- [x] T0101 [US5-shim] Implement the sampler of 12 §2.4 (filter and mipmap mode, replacing the `NEAREST` filters at `cc_vk.c:413-415`) and mip regeneration in `cc_vk_texture_update`
- [x] T0102 [US5-shim] Gate: run `make gate-shim` and record the command and real output
