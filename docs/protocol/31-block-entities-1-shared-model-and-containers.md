# 31-1 Block entities, part 1: shared model and plain containers

| Item | Value |
|---|---|
| Covers | The shared block entity model (base class, save and load lifecycle, components, the 49 block entity types with their numeric ids and valid blocks, common NBT conventions, update tag and Block Entity Data rules, chunk storage interplay, tickers, the opener counter and open or close events), then the plain container family: `BaseContainerBlockEntity`, `RandomizableContainerBlockEntity` (loot tables), `ListBackedContainer`, chest, trapped chest, ender chest, double chest merging, `ChestLidController`, barrel, shulker box, `LidBlockEntity`. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Siblings | 31 parts 2 to 8 specify the per-type fields, NBT and logic of every other block entity type (furnaces, dispensers, signs, spawners, and so on). This part does not repeat them. |
| Related | 06 §3.2 (chunk packet block entity list), 05a id 6 (Block Entity Data), 07 §7 and §9.4 (`block_entities` list in chunk NBT), 29 §2.1 step 12 and §12 (creation at placement, lazy creation, removal, ticker plumbing), 29 §7.2 (packets after block changes), 33 §2.1 step 11 (block entities tick only while the level is not idle), 26 (loot tables and `LootTable.fill`), 45 §3 (player `EnderItems` and the item-with-slot element), 46 §5.4 (the registry id table, repeated and checked in section 3), 41 (item entity spawn physics). |

Class names appear in backticks only to say where a fact was read.

---

## 1. Scope and reading guide

- The standard world type is the target (operator decision, ticket CC-0001): block entity NBT written by this server must be readable by the standard client's chunk packet and by standard worlds, and the reverse.
- Content that is data (loot tables, tags, recipes, item definitions) is not tabulated here. The engines that read it are cited.
- "Block event" means the queued per-block message (`Level.blockEvent` followed by the block's `triggerEvent` and a Block Event packet to clients); its engine is in 29 and 33, and this part only states which ids the containers use.

---

## 2. The block entity base model (`BlockEntity`)

### 2.1 State of one block entity

| Field | Meaning |
|---|---|
| `type` | The `BlockEntityType` it was created from; never changes. |
| `level` | The level, set when the entity is placed in a chunk that is in a level; null for a detached entity. |
| `worldPosition` | Immutable block position (copied at construction). |
| `blockState` | The cached state of the block at that position. |
| `remove` | Removed flag. `setRemoved` sets it, `clearRemoved` clears it, `isRemoved` reads it. |
| `components` | A data component map of the entity's own persisted components, default empty. |

Construction validates the block state: if the state's block is not in the type's valid block set (section 3), construction fails with an error naming the entity, the position and the state. `setBlockState` repeats the same check. `isValidBlockState` is `type.isValid(state)`, a set membership test on the state's block.

### 2.2 Saving

Three public forms exist, all built from the same pieces:

| Form | Content |
|---|---|
| "without metadata" (`saveWithoutMetadata`) | the type's own keys (`saveAdditional`), then the key `components` holding the component map |
| "with full metadata" (`saveWithFullMetadata`) | "without metadata", plus the metadata keys |
| "custom only" (`saveCustomOnly`) | only the type's own keys: no `components`, no metadata |
| "with id" (`saveWithId`) | "without metadata" plus only the `id` key |

Metadata keys: `id` (String: the registry key of the type, such as `minecraft:chest`; written with the block entity type registry's by-name codec), `x`, `y`, `z` (Int, absolute block coordinates). The chunk file stores the "with full metadata" form (section 6). The key `components` is written by the base class after the type's own keys, using the data component map codec; the key is written for every type, including types with no own data (the ender chest saves `id`, `x`, `y`, `z` and `components` only). Whether an empty component map is written as an empty compound or omitted was not traced (Open question 1).

`saveAdditional` is the extension point each type overrides; the base class writes nothing.

### 2.3 Loading

1. `loadStatic(pos, state, tag, registries)` (the entry point used for chunk loading and for the item `block_entity_data` component): read `id` with the type registry's by-name codec. If it does not decode to a type, log "Skipping block entity with invalid type" and return nothing (the entry is dropped).
2. Create the entity with `type.create(pos, state)`. The factory is the type's constructor taking position and state (section 3). A factory that fails or a state not valid for the type logs "Failed to create block entity ... for block ... at position ..." and returns nothing.
3. `loadWithComponents(input)`: run the type's `loadAdditional(input)`, then read `components` with the component map codec; a missing or undecodable `components` becomes the empty map.
4. A failure while loading logs "Failed to load data for block entity ..." and returns nothing.
5. `loadCustomOnly(input)` runs only `loadAdditional`: it is used where the data holds no components.

`loadAdditional` is the type's extension point; the base class reads nothing. Keys that are absent read as the type's defaults (each type's reads use "get or default" forms).

`getPosFromTag(chunkPos, tag)`: read `x`, `y`, `z` as Int, each defaulting to 0 when absent. If the section coordinates of `(x, z)` differ from the chunk's coordinates, log "Block entity ... found in a wrong chunk, expected position from chunk ...", and relocate: keep `y`, and replace x and z by the chunk's own block x and z for the section-relative offsets (0 to 15) of the tag's x and z. Worked example in section 14.

### 2.4 Changes and removal

- **`setChanged()`**: if the entity has a level, call `Level.blockEntityChanged(pos)`: if the level has a chunk at the position, mark that chunk unsaved (it will be written at the next save). Then, if the cached state is not air, call `updateNeighbourForOutputSignal(pos, block)` so comparators next to the block recompute. `setChanged` sends nothing to clients; client synchronisation is section 5.
- **`setRemoved` / `clearRemoved`**: only flip the flag. The chunk removes tickers, listener registrations and map entries (section 6).
- **`preRemoveSideEffects(pos, state)`**: default: if the entity is a `Container` and has a level, drop all its stacks as item entities at the block (`Containers.dropContents`). `ShulkerBoxBlockEntity` overrides it to do nothing (its contents travel in the dropped item, 13.4). It is called from the block change pipeline (29 §2.1) unless flag 256 is set.
- **`triggerEvent(id, param)`**: default returns false (event not handled). The container types handle id 1 (section 8.3).
- **`getUpdatePacket()`**: default null (no packet). **`getUpdateTag(registries)`**: default an empty compound. Section 5.
- **`onlyOpCanSetNbt()`** is on the type, not the entity: true when the type is one of the six operator-only types (section 3.2).

### 2.5 Components

Block entities participate in item data components (used by pick-block, placement from an item stack, and the drop of a shulker box):

| Operation | Behaviour |
|---|---|
| `applyComponentsFromItemStack(stack)` | `applyComponents(stack prototype, stack patch)`. |
| `applyComponents(defaults, patch)` | Build the stack's effective component map. Call `applyImplicitComponents(getter)` so the type takes the components it understands (for containers: `custom_name`, `lock`, `container`, `container_loot`). Components the type did not consume are kept: the entity's `components` field becomes the stack's added components, excluding `block_entity_data` and `block_state` (those two are always excluded, and consumed components are removed from the patch). |
| `collectComponents()` | The `components` field plus whatever `collectImplicitComponents(builder)` adds (for containers: `custom_name` when set, `lock` when locked, `container` (all slots), `container_loot` when a loot table is set). |
| `removeComponentsFromTag(output)` | Each type discards the NBT keys that are now represented as components (containers: `CustomName`, `lock`, `Items`, and for loot containers `LootTable`, `LootTableSeed`). Caller not traced (Open question 2). |

### 2.6 Where the entity is found

`Level.getBlockEntity(pos)` returns nothing outside valid bounds; on a server level it also returns nothing when called off the level's thread; otherwise it asks the chunk with creation mode `IMMEDIATE` (29 §12 "Lazy creation"). Client levels look up by type through `ClientLevel.getBlockEntity(pos, type)`, which returns the entity only if its type matches.

---

## 3. `BlockEntityType` and the registry

A `BlockEntityType` holds a factory (constructor taking position and block state), the set of valid blocks, and an intrusive registry holder. The factory is invoked by `create(pos, state)`. `isValid(state)` tests the block against the valid set. `getBlockEntity(getter, pos)` returns the entity at the position when its type is this type, else nothing. Registration (`BlockEntityTypes.register`) warns "Block entity type ... requires at least one valid block to be defined!" for an empty set; the resource key of each type comes from `BlockEntityTypeIds`.

### 3.1 The 49 types in registration order

The numeric id is the registration order (0 to 48). It is the VarInt written for the type in Block Entity Data and in the chunk packet (05a id 6, 06 §3.2). The order of the static initialiser, the order of `BlockEntityTypeIds` and 46 §5.4 were compared in this round and agree.

| Id | Key | Class (factory) | Valid blocks |
|---|---|---|---|
| 0 | `furnace` | `FurnaceBlockEntity` | furnace |
| 1 | `chest` | `ChestBlockEntity` | chest, plus the copper chest family: 4 weathering states times unwaxed and waxed = 8 blocks (collection `COPPER_CHEST`) |
| 2 | `trapped_chest` | `TrappedChestBlockEntity` | trapped chest |
| 3 | `ender_chest` | `EnderChestBlockEntity` | ender chest |
| 4 | `jukebox` | `JukeboxBlockEntity` | jukebox |
| 5 | `dispenser` | `DispenserBlockEntity` | dispenser |
| 6 | `dropper` | `DropperBlockEntity` | dropper |
| 7 | `sign` | `SignBlockEntity` | 26 blocks: standing and wall signs of oak, spruce, birch, acacia, cherry, jungle, dark oak, pale oak, crimson, warped, mangrove, bamboo, poplar |
| 8 | `hanging_sign` | `HangingSignBlockEntity` | 26 blocks: hanging and wall hanging signs of the same 13 woods |
| 9 | `mob_spawner` | `SpawnerBlockEntity` | spawner |
| 10 | `creaking_heart` | `CreakingHeartBlockEntity` | creaking heart |
| 11 | `piston` | `PistonMovingBlockEntity` (package `block.piston`) | moving piston |
| 12 | `brewing_stand` | `BrewingStandBlockEntity` | brewing stand |
| 13 | `enchanting_table` | `EnchantingTableBlockEntity` | enchanting table |
| 14 | `end_portal` | `TheEndPortalBlockEntity` | end portal |
| 15 | `beacon` | `BeaconBlockEntity` | beacon |
| 16 | `skull` | `SkullBlockEntity` | 14 blocks: floor and wall variants of skeleton skull, creeper head, dragon head, zombie head, wither skeleton skull, player head, piglin head |
| 17 | `daylight_detector` | `DaylightDetectorBlockEntity` | daylight detector |
| 18 | `hopper` | `HopperBlockEntity` | hopper |
| 19 | `comparator` | `ComparatorBlockEntity` | comparator |
| 20 | `banner` | `BannerBlockEntity` | 32 blocks: the 16 colours of standing banner and of wall banner (colour collections) |
| 21 | `structure_block` | `StructureBlockEntity` | structure block |
| 22 | `end_gateway` | `TheEndGatewayBlockEntity` | end gateway |
| 23 | `command_block` | `CommandBlockEntity` | command block, chain command block, repeating command block |
| 24 | `shulker_box` | `ShulkerBoxBlockEntity` | 17 blocks: the 16 dyed shulker boxes (collection `DYED_SHULKER_BOX`) and the undyed shulker box |
| 25 | `conduit` | `ConduitBlockEntity` | conduit |
| 26 | `barrel` | `BarrelBlockEntity` | barrel |
| 27 | `smoker` | `SmokerBlockEntity` | smoker |
| 28 | `blast_furnace` | `BlastFurnaceBlockEntity` | blast furnace |
| 29 | `lectern` | `LecternBlockEntity` | lectern |
| 30 | `bell` | `BellBlockEntity` | bell |
| 31 | `jigsaw` | `JigsawBlockEntity` | jigsaw |
| 32 | `campfire` | `CampfireBlockEntity` | campfire, soul campfire |
| 33 | `beehive` | `BeehiveBlockEntity` | bee nest, beehive |
| 34 | `sculk_sensor` | `SculkSensorBlockEntity` | sculk sensor |
| 35 | `calibrated_sculk_sensor` | `CalibratedSculkSensorBlockEntity` | calibrated sculk sensor |
| 36 | `sculk_catalyst` | `SculkCatalystBlockEntity` | sculk catalyst |
| 37 | `sculk_shrieker` | `SculkShriekerBlockEntity` | sculk shrieker |
| 38 | `chiseled_bookshelf` | `ChiseledBookShelfBlockEntity` | chiseled bookshelf |
| 39 | `shelf` | `ShelfBlockEntity` | 13 shelf blocks: acacia, bamboo, birch, cherry, crimson, dark oak, jungle, mangrove, oak, pale oak, spruce, warped, poplar |
| 40 | `brushable_block` | `BrushableBlockEntity` | suspicious sand, suspicious gravel |
| 41 | `decorated_pot` | `DecoratedPotBlockEntity` | decorated pot |
| 42 | `crafter` | `CrafterBlockEntity` | crafter |
| 43 | `trial_spawner` | `TrialSpawnerBlockEntity` | trial spawner |
| 44 | `vault` | `VaultBlockEntity` (package `entity.vault`) | vault |
| 45 | `test_block` | `TestBlockEntity` | test block |
| 46 | `test_instance_block` | `TestInstanceBlockEntity` | test instance block |
| 47 | `copper_golem_statue` | `CopperGolemStatueBlockEntity` | the copper golem statue family: 8 blocks (4 weathering states times unwaxed and waxed) |
| 48 | `potent_sulfur` | `PotentSulfurBlockEntity` | potent sulfur |

The block keys inside each collection (the copper, colour and wood names) are rows of the block registry (24 parts 1 to 8); the table gives only membership and counts. Valid blocks form a set, so their order is not significant. `BlockEntityTypes` also keeps the key of each type in the field named after it (`FURNACE`, `CHEST`, ... `POTENT_SULFUR`), which is how other classes refer to a type.

### 3.2 Operator-only types (`onlyOpCanSetNbt`)

The set `OP_ONLY_CUSTOM_DATA` holds exactly six types: `command_block`, `lectern`, `sign`, `hanging_sign`, `mob_spawner`, `trial_spawner`. For these, placing an item whose `block_entity_data` component targets the type is honoured only for operators (the check is in the placement code, 29 §9.6 step 6.2).

---

## 4. Common NBT conventions

| Key | NBT type | Owner | Rules |
|---|---|---|---|
| `id`, `x`, `y`, `z` | String, Int, Int, Int | every entity, chunk file only | section 2.2. Not part of `saveCustomOnly` or of update tags. |
| `components` | Compound | every entity | section 2.5. Written by the base class after the type's own keys. |
| `Items` | List of Compound | containers | One element per non-empty slot; see 45 §3 (section 4.1 of that document) for the element (`Slot` plus the stack fields). Written only when at least one slot is non-empty: with no non-empty slot the key is removed (`saveAllItems` with its "always write" flag false, which chest, barrel and shulker box use). On load all slots first start empty, then each element whose `Slot` satisfies `0 <= Slot < size` is placed (invalid slots are skipped). |
| `lock` | an item predicate (compound) | `BaseContainerBlockEntity` | Written only when the lock is not "no lock" (the empty item predicate). Read with default "no lock". |
| `CustomName` | text component | `BaseContainerBlockEntity` | Written only when set (`storeNullable`). Read with a lenient reader: an unreadable value becomes "no custom name". |
| `LootTable` | String (resource key of a loot table) | `RandomizableContainerBlockEntity` | Written when a loot table is set. |
| `LootTableSeed` | Long | same | Written only when the seed is non-zero and a loot table is set; read with default 0. |

Loot interplay: a randomizable container writes `LootTable` (and the seed) **instead of** `Items` while the table is unopened (`trySaveLootTable` returns true and the item list is skipped). On load, if `LootTable` is present the item list is not read (`tryLoadLootTable` returns true); the slots stay empty until the table is unpacked (section 9.3). The result is that a container never carries both.

---

## 5. Client synchronisation

### 5.1 Update tag and update packet

| Hook | Default | Meaning |
|---|---|---|
| `getUpdateTag(registries)` | empty compound | The compound sent to clients in the chunk packet and inside Block Entity Data. |
| `getUpdatePacket()` | null | The packet sent after a block change at that position (29 §7.2). The overriding types return `ClientboundBlockEntityDataPacket.create(this)`. |

`ClientboundBlockEntityDataPacket.create(entity)` builds the packet from the entity's position, its type and `entity.getUpdateTag(registries)` (the method reference is `getUpdateTag`). Wire format: 05a id 6: block position, type as a VarInt registry id, then a compound (the trusted, unlimited compound codec). The packet carries no entity id, so it is only meaningful when the client holds a block entity of that type at that position.

### 5.2 Which types sync

Types that override `getUpdatePacket` (all use `create(this)`) and what their update tag is:

| Type (class) | `getUpdateTag` |
|---|---|
| banner | the "without metadata" form (own keys plus `components`) |
| beacon, conduit, creaking heart, decorated pot, jigsaw, sign, skull, structure block, test block, test instance block, end gateway | "custom only" |
| spawner | "custom only" with the key `SpawnPotentials` removed |
| brushable block | the base tag plus `hit_direction` (legacy direction id, when set) and `item` (the item stack, when not empty) |
| campfire | the `Items` list only, saved with the "always write" flag set to true (the key is present even when no slot is occupied); the campfire's own fields are in a later part |
| shelf | the `Items` list and the Boolean `align_items_to_bottom` |
| trial spawner | the state data's update tag, computed with the block's current `STATE` property |
| vault | a compound with one key, `shared_data` |
| copper golem statue | overrides only the packet: its update tag is the default (empty) |
| piston (moving), and any type of 31 parts 2 to 8 not in this list | the piston class lives in package `block.piston` and was not read here; every class of package `entity` and `entity.vault` that was not listed has neither hook, so it never sends a Block Entity Data packet and sends an empty tag in the chunk packet |

The plain containers of this document (chest, trapped chest, ender chest, barrel, shulker box) have **neither** hook. Their contents reach a client only through the open menu (menu synchronisation is RS14), and their open or close animation only through block events (section 8.3).

### 5.3 Chunk load

When a chunk packet is built, every live block entity of the chunk (`LevelChunk.getBlockEntities`, not the pending ones) becomes one entry: packed XZ byte (section-relative x in the high nibble and z in the low nibble, as in 06 §3.2), Short y, the type id, and the entity's `getUpdateTag(registries)`; an empty tag is sent as absent. Hence every chest, barrel and shulker box is announced to the client with type and position but no data.

### 5.4 Client application

- On Block Entity Data: look up the client's block entity at the position with the packet's type; if present, run `loadWithComponents` on the packet's tag (so the tag may carry `components`). After that, if the entity is a command block and the open screen is the command block screen, the screen refreshes.
- On a chunk packet (`replaceWithPacketData`): all existing block entities of the client chunk are cleared; for each entry, the client gets or creates (`IMMEDIATE`) the block entity at the position and, only if one exists and its type equals the entry's type, loads the entry's tag with `loadWithComponents`. An absent tag loads nothing.

---

## 6. Interplay with chunk storage (07 §7 and §9.4, 29 §12)

A `LevelChunk` holds two maps: live entities (`blockEntities`, position to entity) and **pending** saved compounds (`pendingBlockEntities`, position to compound). The block entity position set of a chunk is the union of both.

1. **Saving** (`SerializableChunkData`): for each position in the union, `getBlockEntityNbtForSaving(pos)`: if a live entity exists and is not removed, its "with full metadata" compound with an extra Boolean `keepPacked` = true; otherwise, if a pending compound exists, a copy of it with `keepPacked` = true; otherwise nothing is written for that position. The list is stored under `block_entities` (07 §7). Positions with nothing to write are skipped.
2. **Loading a full chunk** (`SerializableChunkData` building the `LevelChunk` from disk): for each compound of `block_entities`: if `keepPacked` is true (the usual case for files written by this version), store it as pending (`setBlockEntityNbt`, which refuses it when a live entity already occupies the position). Otherwise, create the entity immediately: position from `getPosFromTag`, state from the chunk, `loadStatic`, then `setBlockEntity`.
3. **Promotion**: `LevelChunk.getBlockEntity(pos, mode)`: use the live entity if present; else remove the pending compound for the position and promote it; else, in mode `IMMEDIATE`, create a fresh entity from the block (`EntityBlock.newBlockEntity`) and register it; a live entity whose removed flag is set is dropped from the map and nothing is returned. Promotion (`promotePendingBlockEntity`): the state at the position is read; if the compound's `id` is the text `DUMMY` (an unreadable-entity placeholder), a fresh entity is created from the block when the state has a block entity (otherwise log "Tried to load a DUMMY block entity ... but found not block entity block"); else `loadStatic`. A non-null result gets the level and is registered (`addAndRegisterBlockEntity`); failure logs "Tried to load a block entity for block ... but failed at location ...".
4. **`setBlockEntity(entity)`**: if the state at the entity's position has no block entity, or the entity's type does not accept the state, log "Trying to set block entity ... but state ... does not allow it" and do nothing. If the entity's cached state differs from the chunk's state it is refreshed (a warning "Block state mismatch on block entity ..." is logged when the blocks differ). Then the entity gets the level, its removed flag is cleared, it is stored in the map, and a different entity previously stored at the position is marked removed.
5. **`addAndRegisterBlockEntity`**: `setBlockEntity`; when the chunk is in the level: on a server level register a game event listener (types that listen); tell the level (`onBlockEntityAdded`); refresh the ticker (section 7).
6. **Proto chunks to level chunks**: a chunk promoted from proto generation moves the proto chunk's live entities through `setBlockEntity` and copies its pending compounds; positions present in both maps log "Chunk at ... contains duplicated block entities".
7. **Writing an entity to the world** (placement, removal and the rest): 29 §2.1 step 12 and §12.

Because pending compounds are saved verbatim, a block entity that was never promoted survives a save and reload without being parsed.

---

## 7. Tickers

- A block that has a ticking entity returns a `BlockEntityTicker` from its `getTicker(level, state, type)`. The ticker interface is a single callback with the level, position, state and entity. The helper `createTickerHelper(givenType, expectedType, ticker)` returns the ticker only when the two types are identical, otherwise nothing; a block therefore ticks only the type it owns.
- When a ticker is registered or refreshed, removed or run is in 29 §12 "Tickers" and 33 §2.1 step 11, and is not repeated.
- Of the types in this part: the chest and ender chest tick **on the client only** (the lid animation, section 10.4); the shulker box ticks **on both sides** (section 13.2); the trapped chest inherits the chest's ticker; the barrel has no ticker. Server-side upkeep of open counts uses scheduled block ticks instead (section 8.2).
- Block entities with no ticker still receive `setChanged`, `triggerEvent` and the block's other callbacks.

---

## 8. Container openers and open or close events

### 8.1 Entities that open containers

An entity that can hold a container open implements `ContainerUser`: `getContainerInteractionRange()` (the maximum distance, for a player the `block_interaction_range` attribute, default 4.5, 17 §2 and 18 attributes) and `hasContainerOpen(counter, pos)` (for a player: `counter.isOwnContainer(player)`, section 8.2). A container user that is not a living entity is an error.

`Container.startOpen(user)` and `stopOpen(user)` are no-ops by default. The chest, barrel and ender chest implement them with a `ContainerOpenersCounter`; the shulker box keeps its own counter (13.3). Both ignore the call when the entity is removed or the user is a spectator.

### 8.2 `ContainerOpenersCounter`

State: `openCount` (int) and `maxInteractionRange` (double). The owner supplies four hooks: `onOpen`, `onClose`, `openerCountChanged(level, pos, state, oldCount, newCount)`, `isOwnContainer(player)`.

| Operation | Steps |
|---|---|
| `incrementOpeners(entity, level, pos, state, range)` | 1. old = openCount; openCount += 1. 2. If old was 0: `onOpen`; game event `CONTAINER_OPEN` with the entity as source at pos; schedule a block tick for the block at pos with delay 5 ticks (`CHECK_TICK_DELAY`). 3. `openerCountChanged(old, openCount)`. 4. maxInteractionRange = max(range, maxInteractionRange). |
| `decrementOpeners(entity, level, pos, state)` | 1. old = openCount; openCount -= 1. 2. If openCount is now 0: `onClose`; game event `CONTAINER_CLOSE` with the entity as source; maxInteractionRange = 0. 3. `openerCountChanged(old, openCount)`. |
| `recheckOpeners(level, pos, state)` (run from the scheduled block tick) | 1. Find `getEntitiesWithContainerOpen`. 2. maxInteractionRange = 0, then the maximum of the users' interaction ranges. 3. n = number of users. If n differs from openCount: with old = openCount, if n > 0 and old == 0 then `onOpen` and `CONTAINER_OPEN` (source none); else if n == 0 then `onClose` and `CONTAINER_CLOSE` (source none); set openCount = n; `openerCountChanged(old, n)`. 4. If n > 0, schedule another block tick with delay 5. |
| `getEntitiesWithContainerOpen(level, pos)` | Entities in the box of the block at pos inflated by `maxInteractionRange + 4.0` (the constant 4.0 is `DEFAULT_DISTANCE_BUFFER`) that are `ContainerUser`s, not spectators, and answer `hasContainerOpen(counter, pos)`. |

The scheduled tick is the block's `tick` callback: chest, ender chest and barrel blocks call `recheckOpen()` on their entity if it is the expected class (the entity method is a null-safe call to `recheckOpeners` and does nothing when the entity is removed). This keeps the count honest when a player walks away or disconnects without a close event.

`isOwnContainer(player)`: chest: the player's open menu is a chest menu whose container is this chest entity or a compound container that contains it; barrel: the open menu is a chest menu whose container is this barrel; ender chest: `player.getEnderChestInventory().isActiveChest(this)`.

### 8.3 Block events used by containers

Block event id **1** carries the number of openers as its parameter (`EVENT_SET_OPEN_COUNT = 1`). The chest family and the ender chest send it from `openerCountChanged` as `level.blockEvent(pos, block, 1, newCount)`. The shulker box sends it from `startOpen` and `stopOpen`. Receivers: chest and ender chest set the lid controller's `shouldBeOpen` to `newCount > 0` (section 10.3); the shulker box sets its open count and animation status (13.3). Any other event id falls through to the base `triggerEvent` (not handled). The queue, the Block Event packet and the call to `triggerEvent` are in 29 and 33.

---

## 9. The container family

### 9.1 `Container` defaults used by block entities

| Member | Value |
|---|---|
| `getMaxStackSize()` | 99 |
| `getMaxStackSize(stack)` | `min(getMaxStackSize(), stack's own max stack size)` |
| `stillValid(player)` for block entities | `Container.stillValidBlockEntity(entity, player)`: the entity must still be the one the level holds at its position and `player.isWithinBlockInteractionRange(pos, 4.0)`: squared distance from the player's eye to the block's box is less than `(blockInteractionRange + 4.0)^2`. |
| `canPlaceItem`, `canTakeItem` | default allow (true); overridden by sided containers |
| `getEntitiesWithContainerOpen()` | empty list |

### 9.2 `BaseContainerBlockEntity`

Adds to the base block entity: `lockKey` (default no lock), `name` (custom name, default none).

- Own keys: `lock` and `CustomName` (section 4).
- `getName()` returns the custom name or `getDefaultName()` (a translatable text per type). `getDisplayName()` equals `getName()`. `hasCustomName` is `name != null`.
- `canOpen(player)`: `lockKey.canUnlock(player)`: true when the player is a spectator or the lock's item predicate matches the player's main hand stack.
- `createMenu(id, inventory, player)`: if `canOpen`: the type's menu; otherwise `sendChestLockedNotifications(center of block, player, display name)`, and the result is no menu.
- `sendChestLockedNotifications`: send the actionbar (overlay) message translatable `container.isLocked` with the display name as argument; if the level is not client-side, play `CHEST_LOCKED` at the position, source blocks, volume 1.0, pitch 1.0.
- `getItems()` and `setItems(list)` are the list accessors each concrete type implements; `isEmpty` checks all slots; `getItem(i)` indexes; `removeItem(i, n)` splits up to n from the slot (`ContainerHelper.removeItem`: nothing when the index is out of range, the slot is empty, or n is not positive) and calls `setChanged` when something was removed; `removeItemNoUpdate(i)` takes the whole slot and leaves empty (no `setChanged`); `setItem(i, stack)` stores, clamps the stack to `getMaxStackSize(stack)` (`limitSize`), and calls `setChanged`; `clearContent` empties the list.
- Components: `applyImplicitComponents` takes `custom_name`, `lock` (default no lock) and `container` (copied into the slot list); `collectImplicitComponents` is the inverse (section 2.5).
- `getLootContext(level)`: a loot context from loot parameters `block_state`, `block_entity` (this), `origin` (center of the block) and `container` (this), in the parameter set `CONTAINER_PROCESS`, with no random sequence. Its users are in 31 parts 2 to 8 and 26.

### 9.3 `RandomizableContainerBlockEntity` and `RandomizableContainer`

Adds `lootTable` (resource key, default none) and `lootTableSeed` (long, default 0).

1. Every read or write of slots (`isEmpty`, `getItem`, `removeItem`, `removeItemNoUpdate`, `setItem`) first calls `unpackLootTable(null)`, then does the base behaviour.
2. `unpackLootTable(player)` (from `RandomizableContainer`): requires a level, a position, a loot table key and a server on the level; if any is missing nothing happens. Otherwise: fetch the table from the server's reloadable registries; if the player is a server player, fire the `GENERATE_LOOT` advancement trigger for the table key; **clear** the loot table key (the seed stays); build loot parameters: `origin` = center of the block, `luck` and `this_entity` only when a player is present; parameter set `CHEST`; call `table.fill(container, params, lootTableSeed)`. The fill algorithm (random sequence, shuffling, slot placement) is in 26.
3. `canOpen(player)`: false when a loot table is set and the player is a spectator (a spectator may not trigger generation); otherwise the base check.
4. `createMenu(id, inventory, player)`: if `canOpen`: `unpackLootTable(inventory.player)` then the menu; otherwise, when the player is not a spectator, the locked notification of 9.2, and no menu.
5. `setBlockEntityLootTable(getter, random, pos, key)` (static, used by worldgen and structure placement): if the block entity at the position is randomizable, set the table and a seed drawn as `random.nextLong()`.
6. `tryLoadLootTable(input)`: read `LootTable` (String key, absent becomes none) and `LootTableSeed` (default 0); returns whether a loot table is present. `trySaveLootTable(output)`: returns false when no loot table is set (nothing written); else writes the key, and writes the seed only when non-zero, and returns true.
7. Components: `container_loot` (a pair of table key and seed) is applied from and collected into the two fields.

### 9.4 `ListBackedContainer` (interface)

A container whose slots are a list returned by `getItems()` and that supplies the standard behaviour as defaults: `count()` (number of non-empty slots), `getContainerSize()` (list size), `clearContent`, `isEmpty` (all empty), `getItem`, `removeItem` (as in 9.2, then `setChanged` when non-empty result), `setItem` (stores through `setItemNoUpdate`, which clamps with `getMaxStackSize(stack)`, then `setChanged`), `canPlaceItem(slot, stack)` (`acceptsItemType(stack)` and the slot is empty or holds fewer than `getMaxStackSize(stack)` items; `acceptsItemType` defaults true), and a `removeItemNoUpdate` that removes using the container's own max stack size as the amount (read as such; its callers are in sibling parts). The plain containers of this document implement the base class instead; the interface serves the newer shelf-style entities of the parts that follow.

### 9.5 Comparator signal of a container

`AbstractContainerMenu.getRedstoneSignalFromContainer(container)` gives 0 for no container; otherwise let `f = (sum over non-empty slots of count / container.getMaxStackSize(stack)) / containerSize`, evaluated in single precision, and the signal is `lerpDiscrete(f, 0, 15)`, where `lerpDiscrete(f, a, b) = a + floor(f * (b - a - 1)) + (f > 0 ? 1 : 0)`. So the signal is 0 only for an empty container, 15 only when `f` is at least 1, and otherwise `floor(f * 14) + 1`. `getRedstoneSignalFromBlockEntity(be)` applies it when the entity is a `Container`, else 0. Barrel and shulker box use the block entity form; the chest uses the container form with the double chest merge (10.2). Containers that hold the comparator signal change by calling `setChanged` (2.4).

---

## 10. Chest, trapped chest, double chest, lid

### 10.1 `ChestBlockEntity`

- 27 slots; `getContainerSize() = 27`. Default name: translatable `container.chest`. Menu: a three-row chest menu over the container (menus: RS14).
- Own NBT: base keys, then either `LootTable` / `LootTableSeed` or `Items` (section 4). Load: first create a 27-slot list of empty stacks, then the loot-table-or-items rule.
- Has an opener counter (8.2) and a `ChestLidController` (10.3).
- Sounds: `onOpen` and `onClose` play the chest block's open or close sound (`ChestBlock.getOpenChestSound` and `getCloseChestSound`, per block, so the copper chests supply their own). The sound is skipped when the state's `TYPE` is LEFT (only one half of a double chest sounds). Position: block center (+0.5 on each axis); when `TYPE` is RIGHT the position is moved by half a block toward the connected half (`getConnectedDirection` step x and z times 0.5). Source: blocks. Volume 0.5. Pitch `random.nextFloat() * 0.1 + 0.9`, drawn from the level's random.
- `openerCountChanged` calls `signalOpenCount(level, pos, state, old, new)`: `level.blockEvent(pos, block, 1, new)`.
- `triggerEvent(1, n)`: `lidController.shouldBeOpen(n > 0)`; returns true. Other ids: base.
- `startOpen` and `stopOpen` as in 8.1; `recheckOpen` as in 8.2; `getEntitiesWithContainerOpen` delegates to the counter.
- `getOpenNess(partialTick)` is the lid controller's interpolated openness. `ChestBlockEntity.getOpenCount(getter, pos)` is the counter's count when the position holds a chest entity and the state has a block entity, else 0. `swapContents(a, b)` swaps the two item lists (`setItems`).
- A chest is a `LidBlockEntity` (interface with a single method `getOpenNess(float)`), as are the ender chest and shulker box: renderers use it.

### 10.2 Double chests

A chest half is a block with `FACING` (horizontal), `TYPE` in {SINGLE, LEFT, RIGHT} and waterlogging (block rows: 24 parts and 29 for placement and shape; the partner choice at placement and the shape update are block behaviour, not this document). The merge is read as follows.

- `ChestBlock.getBlockType(state)`: TYPE SINGLE becomes `SINGLE`, RIGHT becomes `FIRST`, LEFT becomes `SECOND`.
- `getConnectedDirection(state)`: the facing rotated clockwise when TYPE is LEFT, counter-clockwise otherwise (for RIGHT). `getConnectedBlockPos(pos, state)` is `pos` moved one block in that direction.
- `DoubleBlockCombiner.combineWithNeigbour(type, blockTypeOf, directionOf, facingProperty, state, level, pos, ignoreBlocked)`:
  1. Read the entity at `pos`: none gives the "none" result.
  2. When `ignoreBlocked` is false, the "is blocked" test on `pos` (section below) true gives "none". When `ignoreBlocked` is true the test is skipped (that lambda is the constant false).
  3. `SINGLE` state gives a single result of this entity.
  4. Otherwise look at the neighbour in the connected direction: it is used only if it is the same block, its type is not SINGLE, its type differs from this half's type, and its facing equals this half's facing. If the blocked test (when applied) is true for the neighbour, the result is "none"; if the neighbour has no entity of the type, the result is single (this entity); else the result is double with order **(first, second)** where the half of type `FIRST` (RIGHT) comes first and `SECOND` (LEFT) second, whichever of the two is `pos`.
  5. Anything else: single.
- **Chest blocked** (`isChestBlockedAt`): the block above is a redstone conductor (`isRedstoneConductor`), **or** a cat in a sitting pose has its body in the box `x..x+1, y+1..y+2, z..z+1` (entities of class Cat in that box with `isInSittingPose`).
- `CHEST_COMBINER` (the container): double gives `CompoundContainer(first, second)` (slot i < size of first is in the first, else slot `i - sizeOfFirst` of the second; size is the sum; `getMaxStackSize` is the first's; `setChanged`, `startOpen`, `stopOpen` apply to both; `stillValid` needs both; `canPlaceItem` and the other per-slot methods delegate by index); single gives that entity; none gives no container. `ChestBlock.getContainer(block, state, level, pos, ignoreBlocked)` returns the merged container or none.
- `MENU_PROVIDER_COMBINER`: double gives a menu provider over the compound container whose `createMenu` requires `canOpen` on both halves (otherwise, for a non-spectator, the locked notification at the center of the first half moved half a block toward the second, and no menu); on success unpacks the loot tables of both halves with the opening player and opens a **six-row** chest menu over the compound container. Its display name: the first half's display name if the first half has a custom name, else the second's if it has one, else translatable `container.chestDouble`. Single gives the chest entity itself as the provider. `getMenuProvider(state, level, pos)` calls the combiner with `ignoreBlocked = false`, so a blocked chest has no provider and cannot be opened.
- Opening: `ChestBlock.useWithoutItem`: on a server level, take the menu provider; if there is one, `player.openMenu(provider)`, award the `open_chest` custom statistic (trapped chest: its own statistic, `getOpenChestStat` overridden), anger nearby piglins (`PiglinAi.angerNearbyPiglins(level, player, true)`), result success. If there is no provider (the chest is blocked) none of this happens and the method falls through to its final return (the value of that return was not read, Open question 12).
- `ChestBlock.openness combiner`: for a double chest the openness shown for the pair is `max(first.getOpenNess(t), second.getOpenNess(t))`; single: that entity's; none: the given entity's own.
- Comparator: `ChestBlock.getAnalogOutputSignal` = `getRedstoneSignalFromContainer(getContainer(..., ignoreBlocked = false))`: a double chest reads both halves together with 54 slots; a blocked chest has no container and gives 0.
- Removal: `affectNeighborsAfterRemoval` updates neighbours for the output signal (`Containers.updateNeighboursAfterDestroy`: `updateNeighbourForOutputSignal(pos, block)`); contents drop through `preRemoveSideEffects` (2.4): one item entity per non-empty slot; the spawn offsets and velocities are `Containers.dropItemStack` (the stack is split into pieces of `10 + nextInt(21)` items, each at a random point in the block with the item entity's width as margin, velocity `triangle(0.0, 0.11485)` on x and z and `triangle(0.2, 0.11485)` on y); entity physics in 41.

### 10.3 `ChestLidController`

Three fields: `shouldBeOpen` (false), `openness` and `oldOpenness` (0.0). Each tick (`tickLid`): `oldOpenness = openness`; then when `shouldBeOpen` is false and `openness > 0`: `openness = max(openness - 0.1, 0)`; when `shouldBeOpen` is true and `openness < 1`: `openness = min(openness + 0.1, 1)`. `getOpenness(partialTick) = lerp(partialTick, oldOpenness, openness)`. The step 0.1 is a float constant, so a full opening takes 10 ticks. It is client-side state only; the server never ticks it.

### 10.4 Lid ticking

`ChestBlock.getTicker` and `EnderChestBlock.getTicker` return the lid tick (`lidAnimateTick`) only when the level is client-side. The client runs it every tick for every loaded chest entity of the right type.

### 10.5 `TrappedChestBlockEntity`

A chest whose type is `trapped_chest` and whose valid block is the trapped chest. Its `signalOpenCount` first does the chest's block event, then, when the old and new counts differ, updates the neighbours of the block and of the block below it (the block's own neighbour updates, with a redstone orientation built from the opposite of the facing and UP), so the redstone power change propagates. The trapped chest block is a signal source whose own power is `clamp(openCount, 0, 15)` (`ChestBlockEntity.getOpenCount`), delivered as a direct (strong) signal only toward UP (`getDirectSignal` returns the power for UP, 0 for other directions).

---

## 11. `EnderChestBlockEntity`

- Not a container. It holds no items and no own NBT: its saved compound is only the base keys (section 2.2). The items are the **player's** `PlayerEnderChestContainer` (27 slots, stored in player data under `EnderItems`, 45 §3), which remembers the one ender chest entity that is currently "active" for it.
- `EnderChestBlock.useWithoutItem`: if the entity at the position is not an ender chest entity, return success without opening. If the block above is a redstone conductor, return success without opening. On a server level: `player.getEnderChestInventory().setActiveChest(entity)`; open a menu (chest menu, three rows, over the player's ender container) with the title translatable `container.enderchest`; award the `open_enderchest` statistic; anger nearby piglins; success.
- Opening: `PlayerEnderChestContainer.startOpen(user)` forwards to the active chest's `startOpen`, then to the simple container's; `stopOpen` forwards, then clears the active chest. `stillValid(player)`: when an active chest exists it must itself be `stillValid` (8.1 range test), else the simple container's rule.
- Opener counter hooks: `onOpen` plays `ENDER_CHEST_OPEN` and `onClose` plays `ENDER_CHEST_CLOSE`, at the block center, source blocks, volume 0.5, pitch `random.nextFloat() * 0.1 + 0.9`; `openerCountChanged` sends block event 1 with the new count for the ender chest block; `isOwnContainer(player)` is `getEnderChestInventory().isActiveChest(this)`.
- `triggerEvent(1, n)`: `shouldBeOpen(n > 0)` on its lid controller; `getOpenNess` delegates to it. Client ticker as in 10.4. Scheduled block tick: `recheckOpen`.

---

## 12. `BarrelBlockEntity`

- 27 slots, default name translatable `container.barrel`, menu: three-row chest menu. NBT as the chest (section 4). `getContainerSize() = 27`.
- Opener counter hooks: `onOpen` plays `BARREL_OPEN` then sets the block state property `OPEN` to true (`setBlockAndUpdate`, flags 3); `onClose` plays `BARREL_CLOSE` then sets `OPEN` to false; `openerCountChanged` does nothing. There is no lid controller and no block event: clients see the `OPEN` property change through normal block update packets.
- Sound position: block center plus half a unit along the facing direction (`FACING` unit vector divided by 2.0 on each axis), source blocks, volume 0.5, pitch `random.nextFloat() * 0.1 + 0.9`.
- `isOwnContainer(player)`: the open menu is a chest menu over this barrel (8.2).
- Block: `BarrelBlock.useWithoutItem` on a server level opens the menu if the entity is a barrel entity, awards `open_barrel`, angers nearby piglins, success. Its scheduled `tick` calls `recheckOpen`. Comparator signal: `getRedstoneSignalFromBlockEntity` (9.5). Removal: `affectNeighborsAfterRemoval` calls `updateNeighboursAfterDestroy`; contents drop through `preRemoveSideEffects`.

---

## 13. `ShulkerBoxBlockEntity`

### 13.1 Fields and constants

| Item | Value |
|---|---|
| Slots | 27 (`CONTAINER_SIZE`; 9 columns, 3 rows); all faces expose all 27 slots (`getSlotsForFace` returns slots 0..26) |
| Default name | translatable `container.shulkerBox`; menu: shulker box menu |
| `color` | a `DyeColor` or none. Set by construction only: from the block state's block (a dyed shulker box block gives its colour, the undyed block gives none). It is **not** saved. |
| `openCount` | int, number of current openers; **not** saved |
| `animationStatus` | `CLOSED`, `OPENING`, `OPENED`, `CLOSING` (ordinals 0 to 3); initial `CLOSED`; not saved |
| `progress`, `progressOld` | float lid progress 0.0 to 1.0 and its previous value |
| Constants | `OPENING_TICK_LENGTH` 10, `MAX_LID_HEIGHT` 0.5, `MAX_LID_ROTATION` 270.0, `EVENT_SET_OPEN_COUNT` 1 |

Own NBT: base keys plus `LootTable` / `LootTableSeed` or `Items` (section 4, the item list omitted when empty). Load rebuilds a 27-slot list, then applies the loot-or-items rule (the load logic is exposed as `loadFromTag`, also used by the item placement path).

Sided access: `canPlaceItemThroughFace(slot, stack, face)` is true only when the stack's item is **not** a shulker box block (shulker boxes cannot be placed inside shulker boxes through automation); `canTakeItemThroughFace` is always true. Direct menu interaction is restricted by the menu (RS14).

### 13.2 Animation tick (both sides)

Each tick, for the entity at a loaded position: `progressOld = progress`, then by status:

| Status | Step |
|---|---|
| CLOSED | `progress = 0` |
| OPENING | `progress += 0.1`; if `progressOld == 0`: neighbour updates (below); if `progress >= 1`: status becomes OPENED, `progress = 1`, neighbour updates; then in every tick of this status: move the entities that collide with the opening lid (13.5) |
| OPENED | `progress = 1` |
| CLOSING | `progress -= 0.1`; if `progressOld == 1`: neighbour updates; if `progress <= 0`: status becomes CLOSED, `progress = 0`, neighbour updates |

Neighbour updates: `blockState.updateNeighbourShapes(level, pos, 3)` and `level.updateNeighborsAt(pos, block)`. `getProgress(partialTick) = lerp(partialTick, progressOld, progress)`. `isClosed()` is `status == CLOSED`. With a 0.1 step the lid takes 10 ticks (matching `OPENING_TICK_LENGTH`) to open or close (the exact single-precision sum is not traced, so the tick on which the threshold is crossed is (inferred)).

### 13.3 Open and close

- `startOpen(user)` (ignored when removed or spectator): if `openCount < 0` set 0; `openCount += 1`; `level.blockEvent(pos, block, 1, openCount)`; when `openCount == 1`: game event `CONTAINER_OPEN` (source: the user) and the sound `SHULKER_BOX_OPEN` at the block position, source blocks, volume 0.5, pitch `random.nextFloat() * 0.1 + 0.9`.
- `stopOpen(user)` (same guards): `openCount -= 1`; `level.blockEvent(pos, block, 1, openCount)`; when `openCount <= 0`: game event `CONTAINER_CLOSE` and the sound `SHULKER_BOX_CLOSE` (same volume and pitch rule).
- `triggerEvent(1, n)`: `openCount = n`; if `n == 0` the status becomes CLOSING; if `n == 1` it becomes OPENING; returns true. (A value of 2 or more changes neither status, so a box already opening or open stays so.) Other ids: base.
- There is no opener counter and no scheduled recheck; a viewer that vanishes leaves the box open until the count is corrected by a close (open question 6).

### 13.4 Block behaviour

- `ShulkerBoxBlock.useWithoutItem`: server level only; the entity must be a shulker box entity and `canOpen` must hold; then `openMenu`, award `open_shulker_box`, anger piglins, success. `canOpen`: true when the status is not CLOSED; otherwise only when the lid's full-open box has no collision (the box of `Shulker.getProgressDeltaAabb(1.0, facing, 0.0, 0.5, bottom center of the block)` deflated by 1.0E-6 collides with nothing in `level.noCollision`).
- Breaking (`playerWillDestroy`): if the entity is a shulker box: on a server level, when the player prevents block drops (creative) and the box is not empty, create an item stack of the block with the entity's `collectComponents()` applied and spawn it as an item entity at the block center (0.5 on each axis) with the default pick-up delay; otherwise (not creative, or empty) `unpackLootTable(player)`. Then the base behaviour.
- Drops (`getDrops`): the loot parameters get a dynamic drop under the identifier `contents` that adds every slot's stack; the block's loot table (data) copies the components and contents (the table is a data file: 26). Because `preRemoveSideEffects` is empty, no loose item drop of the contents happens.
- Comparator: `getRedstoneSignalFromBlockEntity`. Removal updates output-signal neighbours.

### 13.5 Lid geometry

The lid's reach is computed by the shulker entity helpers `getProgressAabb` and `getProgressDeltaAabb` (their shape formulas belong to the shulker mob, document 34 and 45 entity parts). `getBoundingBox(state)` for the entity is `Shulker.getProgressAabb(1.0, facing, 0.5 * getProgress(1.0), Vec3(0.5, 0, 0.5))`. While OPENING, entities in the delta box between `progressOld` and `progress` (`getProgressDeltaAabb(1.0, facing, progressOld, progress, bottom center of the block)`) whose push reaction is not "ignore entity" are moved by `MoverType.SHULKER_BOX` with the vector `((boxXsize + 0.01) * stepX, (boxYsize + 0.01) * stepY, (boxZsize + 0.01) * stepZ)`, where the sizes belong to the delta box and the steps to the facing direction.

---

## 14. Worked examples

1. **Chunk entry on disk**: a chest at (35, 64, -3) holding 10 cobblestone in slot 0 and nothing else is stored as a compound with `id` = `minecraft:chest`, `x` 35, `y` 64, `z` -3, `Items` = one element (slot 0, id `minecraft:cobblestone`, count 10; element layout 45 §3), `components` (the empty map, section 2.2), and `keepPacked` = 1. An empty chest at the same place has no `Items` key at all. A chest that was just filled by a structure has `LootTable` = `minecraft:chests/simple_dungeon` (an example key, a data row) and `LootTableSeed` = a non-zero long, and no `Items`.
2. **Relocation**: tag x = 35, y = 64, z = -3 read for the chunk (0, -1): the section coordinate of x is 2, which is not 0, so the position is wrong; relocated x = chunk 0's block x for offset `35 mod 16 = 3` = 3, z = chunk -1's block z for offset `-3 mod 16 = 13` = -3, giving (3, 64, -3); a warning is logged.
3. **Comparator**: a single chest holding 14 full stacks of 64 cobblestone (14 of 27 slots): f = 14 / 27 = 0.5185; `floor(0.5185 * 14) + 1 = 7 + 1 = 8`. One cobblestone in one slot: f = (1/64)/27 = 0.00058; `floor(0.0081) + 1 = 1`. A chest of 27 stacks of 16 ender pearls, each slot full: f = 1; signal 15. Empty: 0. A blocked chest (solid block above): 0 regardless of contents.
4. **Double chest slots**: a double chest with the RIGHT half at P and the LEFT half at Q: the merged container's slots 0 to 26 are the RIGHT half's slots, 27 to 53 the LEFT half's (the RIGHT half has type `FIRST`). Total size 54; the comparator signal for a half is computed over all 54 slots.
5. **Opener counting**: player A opens a chest: count 0 to 1, open sound, event `CONTAINER_OPEN`, block tick scheduled 5 ticks ahead, block event 1 with 1 (clients' lid opens over 10 ticks). Player B opens too: count 2, event 1 with 2 (no sound). A moves away without closing: at the next block tick the recheck counts 1 user, sets count 1, sends event 1 with 1, schedules another tick. B closes: count 0, close sound, `CONTAINER_CLOSE`, event 1 with 0 (lid closes over 10 ticks); no further tick is scheduled.
6. **Shulker box animation**: `startOpen` once: event 1 with 1 reaches `triggerEvent`: status OPENING. Tick 1: `progressOld = 0`, `progress = 0.1`, neighbour updates, entity push. Ticks 2 to 9: progress 0.2 up to 0.9 with pushes. Tick 10: progress reaches 1 (single-precision sum, (inferred) tick), status OPENED, neighbour updates. Close: event 1 with 0: status CLOSING; each tick progress falls by 0.1; when `progressOld == 1` the first closing tick does neighbour updates; at progress at most 0 status CLOSED.
7. **Locked chest**: a chest with `lock` = an item predicate for the item named "key": a player holding that item (main hand) or a spectator may open it; anyone else gets the actionbar message `container.isLocked` (argument: the chest's display name) and the sound `CHEST_LOCKED`.

---

## 15. Validation

A conforming implementation passes these checks (inputs are as described, results are the read behaviour):

1. The registry table of section 3.1 has 49 entries with ids 0 to 48 in the stated order; `chest` is 1, `shulker_box` is 24, `barrel` is 26, `potent_sulfur` is 48; ids match 46 §5.4.
2. A chunk with a chest, a barrel and a shulker box serialises each to a compound with `id`, `x`, `y`, `z`, `components`, `keepPacked`, and `Items` only when non-empty. Reloading yields identical contents and, for a loot chest, identical `LootTable` and `LootTableSeed` with no `Items`.
3. Loading a compound with `LootTable` present ignores any `Items` in the same compound.
4. `getPosFromTag` defaults missing coordinates to 0 and relocates a tag from another chunk as in example 2.
5. The chunk packet carries one entry per live block entity, with an absent tag for chests, barrels, shulker boxes and ender chests, and with the update tag of section 5.2 for signs, skulls, banners and the other listed types.
6. `setChanged` marks the chunk unsaved and updates comparators; it sends nothing to clients.
7. Open and close counting follows 8.2 and example 5: sound and game event only on the 0 to 1 and 1 to 0 transitions; a recheck tick every 5 ticks while count is positive; an inconsistent count is repaired by the recheck.
8. A double chest of two valid halves merges into 54 slots; blocked by a conductor block above or a sitting cat: cannot open, comparator 0.
9. The redstone signal formula of 9.5 gives 0, 1, 8, 15 for the inputs of example 3.
10. A shulker box opens in 10 ticks and cannot be opened (when closed) if its lid path collides; a shulker box item dropped from a creative break carries the contents.
11. The six operator-only types of 3.2 are the only ones for which `onlyOpCanSetNbt` is true.

---

## Open questions

1. Whether an empty component map is written as `"components": {}` or omitted for entities with no components (the codec's behaviour on an empty map was not traced).
2. The callers of `removeComponentsFromTag` (read only as discarding the container keys; presumably pick-block and item-from-block paths, inferred).
3. The exact order in which the ticker, listener and level hooks of `addAndRegisterBlockEntity` run relative to `setBlockEntity` for chunks that are not yet in the level (the `isInLevel` condition was read, but not the chunk status condition behind it).
4. Where `Level.blockEvent` routes to `Block.triggerEvent` and then `BlockEntity.triggerEvent` (queue and packet are in 29 and 33; the per-block `triggerEvent` forwarding to the entity was not read here for the chest family).
5. The campfire's update tag uses the "always write" form of the item list, so the `Items` key is written even when empty; the campfire's own part must confirm (not read here).
6. The shulker box has no scheduled recheck of its open count, so a viewer lost without a close event could leave the lid open; whether another path (menu removal on disconnect) always closes it was not traced.
7. The formula of `Shulker.getProgressAabb` and `getProgressDeltaAabb` (lid geometry) belongs to the shulker mob documents and is not reproduced.
8. The float sum of ten additions of 0.1 and therefore the exact tick on which the lid animations reach their end (assumed tick 10; (inferred)).
9. The `DoubleBlockCombiner` lambda labelled "blocked" for `ignoreBlocked = false` was read as `ChestBlock.isChestBlockedAt` by the shape of the bytecode (the other lambda is the constant false); confirmed by name only for the constant one.
10. The piston block entity (package `block.piston`) was not read for update hooks; its part is a sibling document.
11. The trapped chest `getSignal` default (power given in the non-UP directions, 0 direct signal) relies on the block base class `ownSignal` path, which was read only through the trapped chest overrides.
12. The result value of `ChestBlock.useWithoutItem` when the server finds no menu provider (blocked chest) was not read.
13. The block entity `fillCrashReportCategory`, debug value registration and game event listener contracts were not specified (not behaviour visible to a player).
