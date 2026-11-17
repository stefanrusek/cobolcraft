#### Phase 20: US9-content — recipes

- [x] T0212 [US9-content] Write test `content/tests/test_recipes_load.cob`: recipes of every type in `docs/protocol/27-recipes-and-unlocks.md` (the data-format chapters of the document: §1, §2, §3, §4, §5, §6, §7, §8) load through the loaders from a fixture data tree (shaped, shapeless, smelting family, stonecutting, smithing, special) with their unlock conditions
- [x] T0213 [US9-content] Implement the recipe loader in `content/src/recipes.cob`
- [x] T0214 [US9-content] Write test `content/tests/test_builtin_recipes.cob`: the cobolcraft recipes (`cobolcraft-standard-core.md`) are rows of the same recipe shapes
- [x] T0215 [US9-content] Implement the built-in recipes in `content/src/builtin-recipes.cob`
- [x] T0216 [US9-content] Gate: run `make gate-content` and record the command and real output
