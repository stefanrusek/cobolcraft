#### Phase 22: US11-content — worldgen registries

- [x] T0220 [US11-content] Write test `content/tests/test_worldgen_noise.cob`: noise parameters and density function loaders over a fixture tree, with the shapes of `docs/protocol/10-world-generation-terrain.md` (the by-reference doubles of `cc_f64_from_text`)
- [x] T0221 [US11-content] Implement the noise and density function loaders in `content/src/worldgen-density.cob`
- [x] T0222 [US11-content] Write test `content/tests/test_worldgen_biomes.cob`: biome and multi-noise biome source loaders (10, 37 part 3, 43 tint inputs)
- [x] T0223 [US11-content] Implement the biome loaders in `content/src/worldgen-biomes.cob`
- [x] T0224 [US11-content] Write test `content/tests/test_worldgen_settings.cob`: noise settings, surface rules, carver configurations and ore feature parameters (10, 11, 37 parts 2 and 4)
- [x] T0225 [US11-content] Implement the noise settings, surface rule and carver loaders in `content/src/worldgen-settings.cob`
- [x] T0226 [US11-content] Write test `content/tests/test_dimension_types.cob`: `dimension_type` rows (min_y -64, height 384, sea level 63 for the overworld; 04 §6, 23 §7.3.3) and the three dimension definitions
- [x] T0227 [US11-content] Implement the dimension loaders in `content/src/dimensions.cob`
- [x] T0228 [US11-content] Gate: run `make gate-content` and record the command and real output
