#### Phase 11: US9-proto — item stack with components, containers, recipe book

**Goal**: the inventory, crafting and recipe-book packets (00, 27, 40).

- [x] T0141 [US9-proto] Extend `proto/tests/contract_wire_provider.cob` with the container and recipe-book fixtures
- [x] T0142 [US9-proto] Write tests in `proto/tests/test_item_stack.cob` for the item stack with a non-empty data component patch (add and remove lists, 00), replacing the empty patch at `proto/src/composites.cob:123`
- [x] T0143 [US9-proto] Implement `PB-PUT-ITEM-STACK` and `PB-GET-ITEM-STACK` with components in `proto/src/item-stack.cob`
- [x] T0144 [US9-proto] Write tests in `proto/tests/test_containers.cob` for Container Set Slot, Content, Click (changed slots, cursor), Set Cursor Item, Open Screen, Container Close
- [x] T0145 [US9-proto] Implement the container packet encoders and decoders in `proto/src/containers.cob`
- [x] T0146 [US9-proto] Write tests in `proto/tests/test_recipe_book.cob` for Place Recipe and Recipe Book Add, Remove, Settings, Seen (27)
- [x] T0147 [US9-proto] Implement the recipe-book encoders and decoders in `proto/src/recipe-book.cob`
- [x] T0148 [US9-proto] Gate: run `make gate-proto` and record the command and real output
