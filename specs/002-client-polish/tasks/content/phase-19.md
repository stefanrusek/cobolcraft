#### Phase 19: US2-content — content sets, registries, tags, built-in layer

**Goal**: both world types answer the same lookups with the same record shapes (R6). **Independent Test**: `contract_content_provider.cob` returns the worked examples of 24 §16, 46 §15, 23 §3.4 and §6.7.

- [x] T0189 [US2-content] Write contract test `content/tests/contract_content_provider.cob`: block, item, entity and static-id lookups of the standard set return the worked examples (24 §16, 25, 46 §15); unknown keys and ids return row 0 / "not found" (content-api §3)
- [x] T0190 [US2-content] Write test `content/tests/test_content_blocks.cob` for `CONTENT-BLOCK-BY-KEY`, `CONTENT-BLOCK-OF-STATE`, `CONTENT-STATE-PROPS`, `CONTENT-STATE-DEFAULT` (state id rule of 24 part 1 §3, no stored state rows)
- [x] T0191 [US2-content] Implement the block and state lookups in `content/src/blocks.cob` over the generated block tables
- [x] T0192 [US2-content] Write test `content/tests/test_content_items.cob` for `CONTENT-ITEM-BY-KEY`, `CONTENT-ITEM-BY-ID`, `CONTENT-ITEM-COMPONENT`
- [x] T0193 [US2-content] Implement the item lookups in `content/src/items.cob`
- [x] T0194 [US2-content] Write test `content/tests/test_content_entities.cob` for `CONTENT-ENTITY-BY-KEY` and `CONTENT-STATIC-ID`
- [x] T0195 [US2-content] Implement them in `content/src/entities.cob`
- [x] T0196 [US2-content] Write test `content/tests/test_registry_load.cob` for the 23 §3 loading sequence over a fixture `vanilla-data` tree: strict JSON, ids in order, freeze, validate, mandatory keys (04 §3.2); `CONTENT-REGISTRY-ENTRY` and `CONTENT-REGISTRY-COUNT`
- [x] T0197 [US2-content] Implement the registry loader in `content/src/registry.cob`
- [x] T0198 [US2-content] Write test `content/tests/test_tags.cob` for tag resolution (23 §6, worked examples §6.7), `CONTENT-TAG-HAS`, `CONTENT-TAG-MEMBERS`
- [x] T0199 [US2-content] Implement tag loading and resolution in `content/src/tags.cob`
- [x] T0200 [US2-content] Write acceptance test `content/tests/acc_f2us2_content_open.cob`: `CONTENT-OPEN` of the standard type is refused unless the packs check is `ok`; the cobolcraft type opens with an empty generated directory and never reads the generated data pack; the two sets share no rows (WT-25) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [x] T0201 [US2-content] Implement `CONTENT-OPEN` and `CONTENT-CLOSE` (`CT-SET`) in `content/src/content-open.cob`
- [x] T0202 [US2-content] Write test `content/tests/test_builtin_blocks.cob`: the cobolcraft layer answers the same block lookups with the 12 blocks and 18 states of `docs/design/standin-content.md` and `cobolcraft-standard-core.md` (state ids 0 to 17)
- [x] T0203 [US2-content] Implement the built-in block layer in `content/src/builtin-blocks.cob`
- [x] T0204 [US2-content] Write test `content/tests/test_builtin_items.cob`: the 18 items, with their components and tags, as the same record shapes the standard set returns
- [x] T0205 [US2-content] Implement the built-in item layer in `content/src/builtin-items.cob`
- [x] T0206 [US2-content] Write test `content/tests/test_builtin_entities.cob`: the cobolcraft mobs expressed as entity rows, components and tags
- [x] T0207 [US2-content] Implement the built-in entity layer in `content/src/builtin-entities.cob`
- [x] T0208 [US2-content] Write test `content/tests/test_client_registry.cob` for `CONTENT-CLIENT-REGISTRY-ADD` and `CONTENT-CLIENT-FINISH`, including the WT-16 decision of the world type from `minecraft:dimension_type` at Finish Configuration (`docs/design/world-types.md`)
- [x] T0209 [US2-content] Implement the client registry load in `content/src/client-registry.cob`
- [x] T0210 [US2-content] Write implementation tests in `content/tests/test_content_cover.cob` for lines of `content/src` left unexecuted
- [x] T0211 [US2-content] Gate: run `make gate-content` and record the command and real output
