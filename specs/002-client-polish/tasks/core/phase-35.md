#### Phase 35: US11-core (b) — random sources, noise, climate, biome source

- [x] T0409 [US11-core] Write test `core/tests/test_random_sources.cob`: positional random splitters and seed forks of `docs/protocol/10-world-generation-terrain.md` with the worked examples (extends `core/src/rng.cob`)
- [x] T0410 [US11-core] Implement them in `core/src/rng.cob`
- [x] T0411 [US11-core] Write test `core/tests/test_noise.cob`: improved/perlin noise, octave and normal noise via `cc_f64_*` match the worked examples bit for bit (10)
- [x] T0412 [US11-core] Implement the noises in `core/src/noise.cob`
- [x] T0413 [US11-core] Write test `core/tests/test_climate.cob`: the six climate parameters at sample points and the multi-noise biome lookup (10, 37 part 3)
- [x] T0414 [US11-core] Implement climate and the biome source in `core/src/climate.cob`
- [x] T0415 [US11-core] Gate: run `make gate-core` and record the command and real output
