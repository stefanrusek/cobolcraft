#### Phase 12: US11-proto — 24-section chunks, registries and tags

**Goal**: the chunk codec for 16-bit states and 24 sections, and the configuration packets of the standard world (04, 06).

- [x] T0149 [US11-proto] Extend `proto/tests/contract_wire_provider.cob` with the chunk, Registry Data and Update Tags fixtures
- [x] T0150 [US11-proto] Write tests in `proto/tests/test_chunk_palette.cob` for paletted containers: single value, indirect, direct, with bits per entry from the 06 rules, for blocks (4096 cells) and biomes (64 cells)
- [x] T0151 [US11-proto] Implement the paletted container encoder and decoder in `proto/src/chunk-palette.cob` (additive: the 001 chunk functions in `proto/src/chunk.cob` stay until Polish)
- [x] T0152 [US11-proto] Write tests in `proto/tests/test_chunk24.cob` for a 24-section chunk packet with 26 light indices, heightmaps and block entities (06 worked examples)
- [x] T0153 [US11-proto] Implement `PB-PUT-CHUNK-24` and `PB-GET-CHUNK-24` in `proto/src/chunk24.cob`
- [x] T0154 [US11-proto] Write tests in `proto/tests/test_registry_tags.cob` for Registry Data entries (with and without inline data) and Update Tags (04 worked examples)
- [x] T0155 [US11-proto] Implement the Registry Data and Update Tags encoders and decoders in `proto/src/registry-tags.cob`
- [x] T0156 [US11-proto] Gate: run `make gate-proto` and record the command and real output
