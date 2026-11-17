#### Phase 60: US5-client — seamless textures

- [x] T2989 [US5-client] Write acceptance test `client/tests/acc_f2us5_seams.cob` (US5-1, SC-002): atlas readback shows padding around each cell per 12 §2.2 and §2.3 so a mip level of any cell never contains a neighbour's colour (fixtures with distinct cell colours at 16 and 32 pixels) [FR-011]
- [x] T2990 [US5-client] Implement padded stitching and the mip level count in `client/src/atlas.cob` and the `cc_vk_texture_ex` call in `client/src/render-list.cob`
- [x] T2991 [US5-client] Write test `client/tests/test_weather_atlas.cob` (CC-0003): rain and snow images of co-prime heights (17 and 19) produce a bounded weather atlas
- [x] T2992 [US5-client] Bound the weather atlas in `client/src/weather-render.cob` and `client/src/atlas.cob`
- [x] T2993 [US5-client] Gate: run `make gate-client` and record the command and real output
