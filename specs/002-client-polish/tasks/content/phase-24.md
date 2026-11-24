#### Phase 24: US13-content — registries the commands name

- [x] T0280 [US13-content] Write test `content/tests/test_command_sources.cob`: every registry the argument types of `docs/protocol/16-commands-catalog.md` complete against (items, blocks, entity types, enchantments, effects, biomes, structures, particle types, game rules, ...) enumerates through `CONTENT-REGISTRY-ENTRY` in id order for both sets
- [x] T0281 [US13-content] Fill the missing registry sources in `content/src/registry.cob` so the test passes
- [x] T0282 [US13-content] Gate: run `make gate-content` and record the command and real output
