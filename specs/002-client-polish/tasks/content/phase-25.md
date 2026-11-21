#### Phase 25: US14-content — item components

- [x] T0283 [US14-content] Write test `content/tests/test_item_components.cob`: `CONTENT-ITEM-COMPONENT` returns tool rules, weapon damage, armor, durability, enchantable and attribute components for the tools and armors of `docs/protocol/17-tools-weapons-and-combat.md` §1 (standard set) and for the cobolcraft items
- [x] T0284 [US14-content] Implement the component defaults in `content/src/item-components.cob`
- [x] T0285 [US14-content] Write test `content/tests/test_enchantment_load.cob`: enchantment, damage type and equipment registries load (28)
- [x] T0286 [US14-content] Implement the enchantment and damage type loaders in `content/src/enchantments.cob`
- [x] T0287 [US14-content] Gate: run `make gate-content` and record the command and real output
