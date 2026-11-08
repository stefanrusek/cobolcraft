# 45. Entity NBT, part 6: villagers, wandering trader, illagers and raiders, piglins, hoglin

| Item | Value |
|---|---|
| Covers | Round RS27 part 6 (GAP-8, entity NBT): the save and load keys, value types, defaults, load-order rules and validation of the npc family (villager, wandering trader), the illager and raider family (pillager, vindicator, evoker, illusioner, vex, and the raid state every raider carries), the piglin family (piglin, piglin brute) and the hoglin; the schemas of the trade offers, gossip list, villager data, `InventoryCarrier` inventory and Brain memories those mobs persist; the point-of-interest (POI) region data that villager memories are bound to; the saved-data files `raids` and `wandering_trader` |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Read: `addAdditionalSaveData` / `readAdditionalSaveData` (and their lambdas) of `Villager`, `AbstractVillager`, `WanderingTrader`, `AgeableMob`, `Mob`, `LivingEntity`, `PatrollingMonster`, `Raider`, `SpellcasterIllager`, `Vindicator`, `Pillager`, `Evoker`, `Illusioner`, `Vex`, `EvokerFangs`, `AbstractPiglin`, `Piglin`, `PiglinBrute`, `Hoglin`, `ZombieVillager`; the codecs `VillagerData`, `GossipContainer` (+ `GossipEntry`, `GossipType`), `MerchantOffers`, `MerchantOffer`, `ItemCost`, `ItemStack`, `DataComponentPatch` (+ `PatchKey`), `DataComponentExactPredicate`, `GlobalPos`, `BlockPos`, `UUIDUtil`, `EntityReference`, `Unit`, `NbtOps`; `Brain` (+ `Packed`, `Provider`, `$1`), `MemoryMap`, `MemorySlot`, `ExpirableValue`, `MemoryModuleType`; `PoiManager`, `PoiSection` (+ `Packed`), `PoiRecord` (+ `Packed`), `SectionStorage` (+ `PackedChunk`); `Raids` (+ `RaidWithId`), `Raid` (+ `RaidStatus`), `SavedDataStorage`, `WanderingTraderData`, `WanderingTraderSpawner`; `PiglinAi`, `PiglinBruteAi` and the piglin behaviours; `SimpleContainer`, `InventoryCarrier`, `DropChances`, `TimeUtil` |
| Evidence rule | Every key, type, default and constant below was read in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement taken from memory of a library that is not in the artifact (the serialization library `com.mojang.serialization` is not part of the jar: 0 entries); each is repeated in Open questions |
| Data versus code | Per the operator decisions the trade rows, loot tables, tags, POI type rows and registry JSON are NOT tabulated (the extraction tool writes them). This document specifies the shape of what is stored and the rules that interpret it. The two registries that are code (villager types and professions) are listed completely in section 6 |
| Siblings | `45-entity-nbt-1` (shared model), `-2` (shared mob classes, brain framework), `-3` (Player), `-4` (land animals, which already lists every persisted memory type with its codec in its section 11; this part does not repeat that table), `-5`, `-7` to `-9` (other groups). Where a sibling exists its text rules for shared keys; section 2 here lists the shared keys only so that these mobs can be written without opening the siblings |
| Related | 07 §8 and §9.3 (the `entities/` and `poi/` region payloads these compounds go into), 18 §4 (brain framework), 19 §22 to §24 (villager, wandering trader, trades), 20 §14 (raid lifecycle, patrols), 44 part 3 (POI behaviours, restock persistence in its section 3.2), 46 (registry ids) |

Notation: "tick" is a game tick. A "key" is a named child of an entity's Compound. "Default" is the value used when the key is absent, has the wrong type, or fails its codec (a failed codec read is "absent": the field then keeps the value it had when the entity was constructed). `Byte`, `Short`, `Int`, `Long`, `Float`, `Double`, `String`, `IntArray`, `List`, `Compound` are the NBT types of 07 §1. Item and block keys are identifiers such as `minecraft:emerald`.

## Contents

1. How values are encoded here
2. Keys inherited by the mobs of this part
3. `Inventory` (`InventoryCarrier`)
4. Trade offers (`Offers`)
5. Gossip (`Gossips`)
6. `VillagerData` and the two registries
7. Villager
8. Villager memories and the point-of-interest binding
9. Wandering trader and its saved data
10. Zombie villager (shared helpers only)
11. Illagers, vex, evoker fangs
12. Raid state saved on raiders, and `raids` saved data
13. Piglin, piglin brute, hoglin
14. Worked examples
15. Validation rules
16. Open questions

## 1. How values are encoded here

The primitive read and write rules, the `ItemStack` form and the `UUID`, `BlockPos` and `Unit` forms are those of `45-entity-nbt-4` sections 1 and 2. The forms that matter for this part, with what was read for each:

| Form | NBT encoding | Read from |
|---|---|---|
| Boolean field written with `putBoolean` | Byte 0 or 1 | `ValueOutput.putBoolean` users; `Codec.BOOL` through `NbtOps.createBoolean` also gives a Byte |
| UUID and entity reference | IntArray of 4 ints, most significant first | `UUIDUtil.CODEC` (an int-stream codec), `EntityReference` (`CODEC` is `UUIDUtil.CODEC` mapped; `store` writes the UUID alone) |
| `BlockPos.CODEC` | IntArray of 3 ints (x, y, z) | `BlockPos` static initialiser (int-stream codec) |
| Dimension key | String, the dimension identifier, for example `minecraft:overworld`; in the cobolcraft world type `cobolcraft:main` | `GlobalPos` field `dimension` uses `Level.RESOURCE_KEY_CODEC` (a resource-key codec; String form inferred) |
| `GlobalPos.CODEC` | Compound `{dimension: String, pos: IntArray(3)}`, both required | `GlobalPos` record codec |
| Registry holder by name (`DefaultedRegistry.holderByNameCodec`) | String identifier of the entry | `VillagerData` codec, `PoiRecord$Packed` |
| Enum by serialized name | String, lower case | `GossipType` (`StringRepresentable.fromEnum`), `Raid$RaidStatus` |
| `Unit.CODEC` | Compound `{}` (empty) | `MapCodec.unitCodec` (library; the empty-compound form is (recalled, not verified)) |
| Optional field with a default (`optionalFieldOf(name, default)`, `lenientOptionalFieldOf(name, default)`) | Key may be absent on read (default applies). On write the key is omitted when the value equals the default (recalled, not verified: the library is not in the artifact) | codecs of sections 4, 5, 8 |
| Always-present optional field (`ExtraCodecs.optionalAlwaysPresentFieldOf`) | Absent on read gives the default; **always written** | read in `ExtraCodecs` (decode maps `Optional.orElse(default)`, encode wraps the value in an Optional) |

A reader MUST accept both an omitted default and an explicit default for every optional field. A writer MAY write explicit defaults (a CobolCraft world is not required to be openable by another implementation, 07 §9), and for always-present fields (`count`) MUST write the key.

## 2. Keys inherited by the mobs of this part

The chain is written base class first. Siblings 45-1 and 45-2 are the authority; this is the reference table for the keys that actually appear on these mobs, each read in this round.

| Level | Key | Type | Written when | Read default |
|---|---|---|---|---|
| `LivingEntity` | `Health`, `HurtTime`, `DeathTime`, `AbsorptionAmount`, `attributes`, `active_effects`, `FallFlying`, `sleeping_pos`, `Brain`, `last_hurt_by_player` (+ `_memory_time`), `last_hurt_by_mob` (+ `ticks_since_last_hurt_by_mob`), `equipment`, `locator_bar_icon`, `current_impulse_context_reset_grace_time`, `current_explosion_impact_pos` | as in `45-entity-nbt-4` section 3 | as there | as there |
| `Mob` | `CanPickUpLoot`, `PersistenceRequired`, `LeftHanded` (Byte), `NoAI` (Byte, only when set), `drop_chances` (Compound, only when different from the default table), leash data, `home_radius` + `home_pos` (only when a home is set), `DeathLootTable` / `DeathLootTableSeed` (only when set) | as there | as there | as there |
| `AgeableMob` | `Age` (Int), `ForcedAge` (Int), `AgeLocked` (Byte) | villager, wandering trader and hoglin (they extend `AgeableMob`, the hoglin through `Animal`) | only when `canBeABaby()` is true (read: the method returns true in `AgeableMob`, and no override was found in `Villager`, `AbstractVillager`, `WanderingTrader`, `Hoglin` or `Animal`, so for these mobs the three keys are in practice always written); on read the same condition guards the three keys (when it is false they are not read) | 0, 0, 0 |
| `Animal` | `InLove`, `LoveCause` | hoglin only (it extends `Animal`) | as in 45-4 section 3 | as there |

`drop_chances` is a Compound whose keys are equipment slot names (`mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`) and whose values are non-negative Floats (`DropChances.CODEC` is an unbounded map from slot to non-negative float). The default chance of a slot is 0.085; a "guaranteed drop" is the chance 2.0 (read: `setGuaranteedDrop` stores 2.0). A slot is "preserved" (`DropChances.isPreserved`) only when its chance is **strictly greater than** 1.0 (read: float compare against the constant 1.0, `PRESERVE_ITEM_DROP_CHANCE_THRESHOLD`); a chance of exactly 1.0 is not preserved. The default is 0.085 and the guaranteed value is 2.0. The exact drop rule belongs to 45-2.

The `Brain` key is always written by `LivingEntity` with the form of `45-entity-nbt-4` section 11: a Compound `{memories: Compound}`, each key the memory identifier, each value `{value: <the memory's codec>, ttl: Long (only when the memory expires)}`.

Not saved on any mob of this part (fields that exist but are not in any save method): the Brain's active activity set, sensor timers, walk and look targets, paths, the villager's last traded player and in-progress trade, the villager's `lastRestockCheckDay`, a raider's `ticksOutsideRaid`, `celebrating` and the group leader links held by the `Raid` object, a spellcaster's current spell type and wololo target, a piglin's arm pose and dance flag.

## 3. `Inventory` (`InventoryCarrier`)

`InventoryCarrier` is implemented by `AbstractVillager` (villager, wandering trader), `Pillager`, `Piglin` and `Allay` (the allay is in 45-4 section 10.2). Key: `Inventory`.

| Item | Rule |
|---|---|
| Type | List of `ItemStack` Compounds `{id: String, count: Int 1..99 (default 1, always written), components: Compound (optional)}`. There is **no `Slot` key**: the list holds only the non-empty stacks, in slot order (`SimpleContainer.storeAsItemList`) |
| Written | Always, even when empty (an empty List) |
| Container size | Villager and wandering trader: 8 (`AbstractVillager` constructor). Piglin: 8. Pillager: 5. (Allay: see 45-4) |
| Load | The container is cleared, then each stack in list order is added with `addItem`. `addItem` copies the stack, first merges it into every slot that already holds the same item with identical components (up to the container's maximum stack size for that stack, the count moved is `min(maxStack - held, incoming)`), and if anything is left puts the remainder into the first empty slot (`moveItemToOccupiedSlotsWithSameType`, then `moveItemToEmptySlots`; remainder that does not fit is lost, `fromItemList` ignores the return value) |
| Consequence | Slot positions are not preserved. Two list entries of the same item merge on load. A list longer than the container loses the surplus. Elements that fail the `ItemStack` codec (count outside 1..99, missing or unknown `id`) are skipped: `InventoryCarrier` reads and writes `Inventory` through the typed list wrapper of `ValueInput.list` / `ValueOutput.list` (`TagValueInput$TypedListWrapper`), which parses each element separately, drops failures and reports a problem for each (read) |
| Absent key | The container is cleared and stays empty |

`ItemStack.CODEC` encodes a stack whose item is the `id`, and `count` and `components` as above. `components` is a data-component patch: a Compound whose keys are component identifiers mapped to that component's value, plus keys with the prefix `!` followed by a component identifier for a component removed from the item's defaults (the `!` prefix was read in `DataComponentPatch$PatchKey`; the value stored under a `!` key is `{}` (inferred, the removal value codec was not read)). Component value schemas are part of the item research and are not specified here.

After loading, `Pillager` calls `setCanPickUpLoot(true)` (so a pillager always can pick up loot after a load, whatever `CanPickUpLoot` said). `Piglin` and `PiglinBrute` set it from `CanPickUpLoot` with a default of **true** when the key is absent (section 13).

## 4. Trade offers (`Offers`)

`AbstractVillager` writes `Offers` only on the server and only when the offers object exists (`offers != null`); a villager or trader whose offers were never generated has **no** `Offers` key. `getOffers()` creates an empty `MerchantOffers` and runs the trade generator (`updateTrades`, 19 §24 and 44 part 3 §10) on the first call when the object is null; a load of a missing `Offers` key leaves the field null (`Optional.orElse(null)`), so the first trade or any call to `getOffers()` generates the offers from the villager data of that moment.

`MerchantOffers.CODEC` is a Compound with one key:

| Key | Type | Notes |
|---|---|---|
| `Recipes` | List of `MerchantOffer` Compounds | Optional with the empty list as default |

`MerchantOffer.CODEC` (all keys; "lenient" optional fields accept a wrong-typed value as absent, recalled for the meaning of "lenient" and not verified):

| Key | Type | Default | Meaning |
|---|---|---|---|
| `buy` | `ItemCost` Compound | required | First cost |
| `buyB` | `ItemCost` Compound | none | Second cost, present only when the offer has one |
| `sell` | `ItemStack` Compound | required | The result (count 1..99; a result with components, such as an enchanted book or a map, stores them under `components`) |
| `uses` | Int | 0 | Times used since the last restock |
| `maxUses` | Int | 4 | Uses before the offer is out of stock |
| `rewardExp` | Byte (Boolean) | true | Whether a trade gives XP orbs to the player |
| `specialPrice` | Int | 0 | The "special price difference": a value added to the first cost's count (negative for discounts). It is saved but is recomputed for a trading player (19 §22.4) |
| `demand` | Int | 0 | Demand counter (19 §22.4) |
| `priceMultiplier` | Float | 0.0 | Multiplier applied to demand (19 §22.4) |
| `xp` | Int | 1 | Villager XP the trade gives |

`ItemCost.CODEC`: Compound `{id: String (item key), count: Int (positive, default 1, always written), components: Compound (optional, default empty)}`. In an `ItemCost`, `components` is an **exact predicate**: a Compound from component identifier to the value the paid stack must carry (`DataComponentExactPredicate.CODEC` is the value-map codec; components flagged transient are never written). It is not a patch: there is no `!` form.

The constructor of a `MerchantOffer` stores `maxUses`, `xp` and `priceMultiplier` as given by the trade; `copy` (used by zombie villager conversion, section 10) copies all ten fields.

Defaults worth stating for the data pack's trade rows: a trade row that omits `max_uses` is the data pack's concern; the stored default 4 applies only to a stored offer that lacks `maxUses`.

## 5. Gossip (`Gossips`)

Written by the villager always (the key exists with an empty List when no gossip is held); read replaces the container (`clear`, then the decoded entries are added) and leaves it empty when the key is absent or fails.

`GossipContainer.CODEC` is a List of `GossipEntry` Compounds, a flat unpack of the internal map (target UUID to gossip type to value) in an order that is (inferred) the map's iteration order and is not specified:

| Key | Type | Meaning |
|---|---|---|
| `Target` | IntArray(4) | UUID of the player, golem or villager the gossip is about |
| `Type` | String | `major_negative`, `minor_negative`, `minor_positive`, `major_positive` or `trading` |
| `Value` | Int | Stored value; the codec requires a **positive** int (at least 1) |

On read, entries are inserted with `put`, so a duplicate (`Target`, `Type`) pair keeps the later entry. The per-type weight, cap, decay per day and decay per transfer are in 19 §22.5; the values as read here: major_negative (weight -5, max 100, decay 10, transfer decay 10), minor_negative (-1, 200, 20, 20), minor_positive (1, 25, 1, 5), major_positive (5, 20, 0, 20), trading (1, 25, 2, 20); the reputation change constants are 25 per event, 20 per everlasting memory and 2 per trade (`GossipType` constants). Stored values below 2 are removed by decay and transfer rules (19 §22.5), so a saved value is normally at least 2 and an entry with value 1 is legal but is dropped by the next decay.

## 6. `VillagerData` and the two registries

`VillagerData.CODEC` is a Compound:

| Key | Type | Default when absent | Notes |
|---|---|---|---|
| `type` | String, a `villager_type` registry entry | `minecraft:plains` | Written always |
| `profession` | String, a `villager_profession` registry entry | `minecraft:none` | Written always |
| `level` | Int | 1 | Always written (always-present optional field). The constructor raises any value below 1 to 1; there is no upper clamp in the record |

`type` and `profession` are read in the bytecode as registry-by-name fields with a default supplied through `orElseGet`, and `level` as an always-present optional field with default 1. What an **unknown but present** `type` or `profession` identifier does (the field falls back to its default, or the whole `VillagerData` Compound fails and counts as absent, section 7) is behaviour of the serialization library, which is not in the artifact (recalled, not verified; Open question 14). A reader MUST accept either outcome; a writer never produces an unknown identifier.

Level and XP: levels run 1 to 5 (`MIN_VILLAGER_LEVEL`, `MAX_VILLAGER_LEVEL`); a villager can level up when `1 <= level < 5`. The lower XP bound of a level is the table entry at index `level - 1` and the upper bound the entry at index `level` of the table `[0, 10, 70, 150, 250]`; at level 5 both bounds are 0. So: level 1 covers XP 0 to 10, level 2 covers 10 to 70, level 3 covers 70 to 150, level 4 covers 150 to 250. (19 §22.2 holds the level-up trigger.)

Registry `villager_type` (code-defined, registration order, ids are positions starting at 0): `desert`, `jungle`, `plains`, `savanna`, `snow`, `swamp`, `taiga` (all in the `minecraft` namespace). The default type key is `plains`.

Registry `villager_profession` (code-defined, registration order starting at 0): `none`, `armorer`, `butcher`, `cartographer`, `cleric`, `farmer`, `fisherman`, `fletcher`, `leatherworker`, `librarian`, `mason`, `nitwit`, `shepherd`, `toolsmith`, `weaponsmith` (15 entries). `none` and `nitwit` hold no job site (both have the "no POI" predicate for the held and the acquirable job site; read in `VillagerProfession`'s static initialiser); every other profession is tied to one POI type (the constructors reference `PoiTypes.ARMORER`, `BUTCHER`, `CARTOGRAPHER`, `CLERIC`, `FARMER`, `FISHERMAN`, `FLETCHER`, `LEATHERWORKER`, `LIBRARIAN`, `MASON`, `SHEPHERD`, `TOOLSMITH`, `WEAPONSMITH` in that order; 44 part 3 §1.2 holds the table of POI types and the block states each accepts). Per-profession requested items (farmer: wheat, wheat seeds, beetroot seeds, bone meal), work sounds and secondary job-site blocks are in 19 §22.2.

## 7. Villager

Entity type `minecraft:villager`. Class chain: `Villager` < `AbstractVillager` < `AgeableMob` < `PathfinderMob` < `Mob` < `LivingEntity` < `Entity` (a villager has no `Animal` keys). Keys of the entity compound, beyond the entity base keys of 45-1 and the chain of section 2:

| Key | Type | Written when | Read default | Notes |
|---|---|---|---|---|
| `Offers` | Compound (section 4) | server, and the offers exist | none (null) | `AbstractVillager` |
| `Inventory` | List of ItemStack (section 3, size 8) | always | empty | `AbstractVillager`; the villager picks up and gives away food, seeds and the profession's requested items (19 §22.6) |
| `VillagerData` | Compound (section 6) | always | see below | |
| `VillagerDataFinalized` | Byte | always | 0 | |
| `FoodLevel` | Byte | always | 0 | Written as the low byte of the int field; read as a byte |
| `Gossips` | List (section 5) | always | empty | |
| `Xp` | Int | always | 0 | Villager XP |
| `LastRestock` | Long | always | 0 | Game time of the last restock |
| `LastGossipDecay` | Long | always | 0 | Game time of the last gossip decay |
| `RestocksToday` | Int | always | 0 | Restocks since the day began |

Write order inside the class: `Offers` (when present), `Inventory`, then `VillagerData`, `VillagerDataFinalized`, `FoodLevel`, `Gossips`, `Xp`, `LastRestock`, `LastGossipDecay`, `RestocksToday` (the order has no meaning for readers).

Load order and the finalisation rule (read, `Villager.readAdditionalSaveData`):

1. The `AbstractVillager` keys are read first (`Offers`, `Inventory`), and before them the whole parent chain (so `Brain` and `equipment` are already restored).
2. `VillagerData` is read through its codec into an optional, and `VillagerDataFinalized` as a boolean defaulting to false.
3. If the finalized flag is true **or** the `VillagerData` read succeeded: the villager is marked finalized, and its data field is set to the read value, or to the default (`plains`, `none`, level 1) when the read failed (a flag of 1 with no usable data gives the default data). If the flag is false and no data was read, the data field is left as constructed (also `plains`, `none`, level 1) and the villager is **not** marked finalized, so spawn finalisation (biome-dependent type) may still choose the type later.
4. `FoodLevel` (byte, default 0), then the gossip container is cleared and refilled from `Gossips`, then `Xp`, `LastRestock`, `LastGossipDecay`, `RestocksToday` (all defaulting to 0).
5. On a server level the brain is refreshed (`refreshBrain`): the brain is packed and rebuilt from the profession and level, keeping every persisted memory (the same pack and unpack as a save and load).
6. The `postDataManipulated` hook (after a command changed the data) refreshes special prices if a player is trading.

The behaviour that uses these fields (restock rules, price formula, level-up, gossip, golem summoning) is in 19 §22 and 44 part 3 §3; the restock persistence note of 44 part 3 §3.2 is consistent with the table above (the "not saved" list is section 2 here). Constants read in `Villager`: `GOSSIP_COOLDOWN` 1200, `GOSSIP_DECAY_INTERVAL` 24000, `MAX_GOSSIP_TOPICS` 10, `BREEDING_FOOD_THRESHOLD` 12, `TIME_SINCE_SLEEPING_FOR_GOLEM_SPAWNING` 24000, the speed modifier 0.5; the "Willing" flag of older saves does not exist in this version: no class constant or string `Willing` is present in `Villager`, and willingness to breed is computed from food (food points in the inventory plus `FoodLevel` against the threshold 12, 19 §22.6), so a `Willing` key in a foreign file is ignored.

Day boundary: `LastRestock` is a game-time stamp, not a day count; after a load `lastRestockCheckDay` restarts at 0 (not saved), so the first restock check re-reads the overworld day (44 part 3 §3.2).

## 8. Villager memories and the point-of-interest binding

### 8.1 What is persisted

The villager's brain slots are the memories its sensors, behaviours and activities require (section 8.3). Of those, these serializable memory types can be present in a villager's `Brain` (value codecs from 45-4 section 11; set sites read in this round):

| Memory identifier | Value (NBT) | `ttl` | Set by | Erased by |
|---|---|---|---|---|
| `home` | `GlobalPos` Compound | no | the bed POI acquirer (`AcquirePoi`, 44 part 3 §2.1); `VillagerMakeLove` sets the child's `home` | `ValidateNearbyPoi` when the bed is invalid or occupied by a non-villager (44 part 3 §2.2); unreachable-target rule (45-1 / 44 part 1 §587); `releasePoi` |
| `job_site` | `GlobalPos` | no | `AssignProfessionFromJobSite` (copies `potential_job_site` when the villager is within 2 blocks, 44 part 3 §2.6) or `AcquirePoi` for a villager that already has the profession | `PoiCompetitorScan`, `ValidateNearbyPoi`, `ResetProfession` conditions, `releasePoi` |
| `potential_job_site` | `GlobalPos` | no | `AcquirePoi` (profession `none`); `YieldJobSite` sets the winner's | `YieldJobSite`, `GoToPotentialJobSite` on stop (timeout 1200 ticks), `AssignProfessionFromJobSite` |
| `meeting_point` | `GlobalPos` | no | `AcquirePoi` (the meeting POI, a bell) | `ValidateNearbyPoi`, `releasePoi` |
| `last_slept` | Long, game time | no | `SleepInBed` when `startSleeping` succeeds (a plain `setMemory` of the game time); read by the golem-summoning test (`now - last_slept < 24000`) | overwritten; no erase was read |
| `last_woken` | Long, game time | no | `Villager.stopSleeping` (game time at waking) | overwritten |
| `last_worked_at_poi` | Long, game time | no | `WorkAtPoi` when it works (plain `setMemory`) | overwritten |
| `golem_detected_recently` | Byte (Boolean) | **yes, set with 599 ticks** | `GolemSensor` (rescans every 200 ticks) and the golem-summoning routine (44 part 3 §4.3, 19 §22.10) | expiry |

A memory that has a time to live is written with `ttl` = the ticks remaining at save time; the ticks count down by one per brain tick while the memory has a value, and the memory is cleared when the counter is 0 or below (`MemorySlot.tick`: the expiry test is made before the decrement, so a stored `ttl` of 1 survives one more tick as a value and is cleared on the following tick). A memory without expiry is written without `ttl`. Memories not in this table (`walk_target`, `look_target`, `interaction_target`, `nearest_*`, `hurt_by`, `heard_bell_time`, `hiding_place`, `secondary_job_site`, `nearest_bed`, `breed_target`, `path` and the others of 44 part 3 §2) have no codec and are never written; a villager therefore resumes with no target and no path.

### 8.2 `GlobalPos` and the dimension rule

A position memory stores the dimension with the position (`{dimension, pos}`). Behaviours compare dimensions first (44 part 3 §2). Consequences for saving: a villager that left through a portal keeps its old memories with the old dimension string; `ValidateNearbyPoi` skips a memory whose dimension is not the entity's and keeps it, and `releasePoi` on death resolves the **memory's** dimension (the server level is looked up by the stored key; if that level does not exist the release is skipped silently). In the cobolcraft world type the dimension strings are the `cobolcraft:` dimension keys (07 §9.1) and the same rules apply.

### 8.3 Load rules for memories

1. Brain construction registers a memory slot for each type in this order: the types declared by the entity class, then the memories the sensors require, then the memories the behaviours of every activity require (and activity conditions). The villager declares only `home`, `job_site`, `potential_job_site`, `meeting_point` in its class initialiser list for the POI map, and gets the rest through its sensors (`nearest_living_entities`, `nearest_players`, `nearest_items`, `nearest_bed`, `hurt_by`, `villager_hostiles`, `villager_babies`, `secondary_pois`, `golem_detected`) and behaviours (45-4's memory table lists the memory side).
2. The packed memories are then applied one by one (`setMemoryInternal`): a memory whose type has **no slot** in that brain is ignored silently; a value that is an empty collection clears the slot.
3. After that the core activities are set and the default activity (idle) is selected: the active activity is never saved, and the schedule (44 part 3 §3.1) picks the activity again at the next brain tick.

### 8.4 POI region data (`poi/`, 07 §8)

POI records are stored in the `poi/` region folder, not in the entity. The payload is the `SectionStorage` compound: `DataVersion` (Int) and `Sections` (Compound) whose keys are section Y indices written as decimal Strings (`Integer.toString`, for example `"-4"`, `"0"`, `"15"`) for every section in the level's min to max section range that has data in memory, and whose values are:

| Key | Type | Default | Meaning |
|---|---|---|---|
| `Valid` | Byte (Boolean) | false (the default `iconst_0` was read; whether a malformed value is tolerated ("lenient") is (recalled, not verified)) | Whether the section's records have been reconciled with its blocks. When false the manager rebuilds the records from the blocks at the next access (44 part 3 §1.3, `ensureLoadedAndValid`) |
| `Records` | List of record Compounds | required | Unordered (the in-memory map is a `Short2ObjectMap` keyed by the section-relative position; save order is its iteration order) |

Record Compound (`PoiRecord$Packed.CODEC`):

| Key | Type | Default | Meaning |
|---|---|---|---|
| `pos` | IntArray(3) | required | Absolute block position |
| `type` | String, a `point_of_interest_type` registry entry | required | For example `minecraft:home`, `minecraft:meeting`, `minecraft:farmer` (the rows are in 44 part 3 §1.2) |
| `free_tickets` | Int | 0 (optional field) | Tickets currently unclaimed; the record's maximum comes from the type |

On load of a section: a section absent from the file simply has no entry; a section whose compound fails the codec is skipped (the reader keeps only sections that decode, `resultOrPartial`). Sections are read for every Y in the level's range.

The binding between a villager's memory and the POI:

1. A claim is **only** the decrement of `free_tickets` on the record (`take`, 44 part 3 §1.3) plus the `GlobalPos` memory in the villager's brain. The villager stores no ticket count; the record stores no owner. The two files (the entity's chunk and the `poi/` region) are therefore only consistent through the rules below, and both may be saved at different moments.
2. Release: `Villager.releasePoi(memory)` runs for `home`, `job_site`, `potential_job_site`, `meeting_point` on death (`releaseAllPois`), in the cases listed in 44 part 3 §2, and when lightning converts the villager into a witch (the thunder-hit conversion calls `releaseAllPois` after the witch is finalised; this is not a death). `releaseAllPois` releases `home`, `job_site`, `potential_job_site`, `meeting_point`, in that order. It reads the memory's `GlobalPos`, finds the level of its dimension, reads the POI type at the position and calls `PoiManager.release(pos)` only when the type satisfies the memory's predicate: `home` needs the type `home`; `job_site` needs the villager's profession's held-job-site predicate (`VillagerProfession.heldJobSite`); `potential_job_site` needs the "any acquirable job" predicate (`ALL_ACQUIRABLE_JOBS`); `meeting_point` needs the type `meeting`. The release returns false (and changes nothing) when all tickets are already free.
3. A villager that is removed without dying (a chunk that unloads and reloads is not removal; `/kill` is death; discarding an entity is removal) does not release. After such a removal a POI keeps its claimed ticket until the section is rebuilt (`Valid` false) or another villager's `ValidateNearbyPoi` clears a stale memory: the ticket count is never recomputed from villagers. This leak is part of the behaviour to reproduce.
4. `PoiSection.refresh` (run when `Valid` is false): the existing records are copied, the section's records are cleared, and the block scan re-adds one record per POI block; an existing record at the same position **is reused as it was** (so its `free_tickets` survive), a new position gets a record with the type's maximum tickets, and a stale record whose block is no longer a POI block is not re-added (so it disappears). `Valid` is then true and the section is marked dirty.
5. `add` of a record where one already exists at the position: same type is a no-op returning false; a different type is an error (logged) and the old record is replaced in the position map.

## 9. Wandering trader and its saved data

Entity type `minecraft:wandering_trader`. Chain: `WanderingTrader` < `AbstractVillager` < `AgeableMob`. Keys beyond the base chain:

| Key | Type | Written when | Read default | Notes |
|---|---|---|---|---|
| `Offers`, `Inventory` | as section 4, section 3 (size 8) | as in section 7 | none, empty | |
| `DespawnDelay` | Int | always | 0 | Ticks before the trader discards itself; the field counts down while above 0 and the trader is not trading (19 §23, 44 part 3 §9). A delay of 0 means "no despawn timer" |
| `wander_target` | IntArray(3) (`BlockPos`) | only when set (`storeNullable`) | none | The block the spawner sent the trader towards (`WanderToPosition`, 44 part 3 §9) |

After reading, the age is raised to 0 when negative (`setAge(max(0, getAge()))`): a wandering trader can never be a baby, whatever `Age` held.

The wandering trader has no brain memories of its own (it is goal-driven). Whether the shared `Brain` key is written for it is Open question 8.

Spawner state, `WanderingTraderData` (saved data id `minecraft:wandering_trader`, one per world is (inferred): `WanderingTraderSpawner` receives a `SavedDataStorage` and calls `computeIfAbsent` on it; which storage is passed was not traced, Open question 15):

| Key | Type | Default | Meaning |
|---|---|---|---|
| `spawn_delay` | Int | 24000 | Ticks until the next spawn roll; the spawner subtracts 1200 every 1200 ticks and rolls at 0 or below (19 §23) |
| `spawn_chance` | Int | 25 | Percent chance used by the roll (see the roll rule below) |

Both keys are optional fields; a fresh world writes the defaults. File framing: section 12.3.

Roll rule (`WanderingTraderSpawner.tick`, read; run only while the game rule `spawn_wandering_traders` is true). The spawner keeps a transient counter that starts a cycle every 1200 ticks:

1. When the counter (decremented each tick) is still above 0, nothing happens. Otherwise it is reset to 1200 and the cycle runs.
2. `new_delay = stored spawn_delay - 1200`; the stored `spawn_delay` is set to `new_delay` and saved. If `new_delay` is above 0 the cycle ends.
3. Otherwise `spawn_delay` is reset to 24000, and the stored `spawn_chance` (call it `old`) is replaced by `clamp(old + 25, 25, 75)` and saved **before** the roll.
4. The roll is a uniform integer `r` in 0 to 99 (`nextInt(100)`). If `r > old` the cycle ends; the spawn is attempted when `r <= old` (inclusive, and the comparison uses the OLD chance, not the raised one).
5. A spawn attempt that returns true resets `spawn_chance` to 25. The attempt returns true when no player is online (nothing is spawned in that case); when a player is picked it first returns false with probability 9/10 (a 1 in 10 draw, `nextInt(10)` equal to 0 continues) and otherwise proceeds with the placement search (19 §23, 44 part 3 §9). A false return leaves the raised chance in place.

Example: stored `spawn_delay` 1200, `spawn_chance` 25. At the cycle: `new_delay` 0, so `spawn_delay` becomes 24000 and `spawn_chance` becomes 50; roll `r = 25` is `<= 25`, so a spawn is attempted. If it fails, the next cycle (20 minutes of game time later) rolls against 50.

## 10. Zombie villager (shared helpers only)

The zombie villager's own keys are in 45-entity-nbt-5-hostile-mobs (45-5). It shares with the villager exactly these codecs, which behave as in sections 4 to 6: `VillagerData` (key `VillagerData`, plus `VillagerDataFinalized` Byte), `Offers` (written with `storeNullable`, so absent when null), `Gossips` (`storeNullable`, absent when the container is null; the same list codec as section 5), `ConversionTime` (Int, **always written**, as -1 when no conversion is running; read default -1, and any value other than -1 starts the conversion with the `ConversionPlayer` UUID, or none when absent), `ConversionPlayer` (IntArray(4), only when set), `Xp` (Int). On curing (`finishConversion`) the villager receives the data (`setVillagerData`, finalized true), the gossips (`setGossips`), a **copy** of the offers (`MerchantOffers.copy`, so `uses`, `demand` and `specialPrice` carry over) and the XP, and refreshes its brain. A zombie villager has no Brain memories of the villager kind, so a cured villager starts with no `home`, `job_site`, `meeting_point`; it re-acquires them.

## 11. Illagers, vex, evoker fangs

Class chains: `AbstractIllager` < `Raider` < `PatrollingMonster` < `Monster`; `SpellcasterIllager` < `AbstractIllager` (evoker, illusioner); pillager and vindicator extend `AbstractIllager` directly. `Witch` and `Ravager` also extend `Raider` (their own keys belong to 45-5); `Vex` extends `Monster` and is not a raider.

| Entity type | Class | Own keys (beyond section 2 and the raider keys of section 12) |
|---|---|---|
| `minecraft:pillager` | `Pillager` | `Inventory` (List of ItemStack, size **5**, always written, section 3). After load `CanPickUpLoot` is forced true |
| `minecraft:vindicator` | `Vindicator` | `Johnny` (Byte): written **only when true** (a vindicator named Johnny); read default 0 |
| `minecraft:evoker` | `Evoker` | `SpellTicks` (Int, from `SpellcasterIllager`, always written, default 0). Nothing else: the wololo target and the current spell are not saved |
| `minecraft:illusioner` | `Illusioner` | `SpellTicks` only |
| `minecraft:vex` | `Vex` | `bound_pos` (IntArray(3), only when set), `life_ticks` (Int, written only when the vex has a limited life), `owner` (IntArray(4), only when the vex has an owner) |

Vex read rules: `bound_pos` read through the `BlockPos` codec with null default; `life_ticks` read with `getInt`, when present the vex gets a limited life of that many ticks (`setLimitedLife`: flag true and counter set), when absent the flag is set false (unlimited life); `owner` read as an entity reference (the summoner, an evoker; the link is by UUID and resolved lazily, `EntityReference.read` gives "none" when the key is missing or invalid). Note the key is lower-case `owner` for the vex and capital `Owner` for evoker fangs.

Evoker fangs (`minecraft:evoker_fangs`) is a projectile entity of the sibling for projectiles (45-8); the keys read here are `Warmup` (Int, written always with `putInt`; read with a default of 0) and `Owner` (IntArray(4), entity reference; written through `EntityReference.store`, so only when a reference exists, (inferred: the helper was not read)). The fangs' behaviour is in 44 part 8.

Illager-specific unsaved state: `AbstractIllager` writes nothing of its own; the raider keys below carry the raid link. The illusioner's blindness and mirror spells and the evoker's summoning use goals and are re-created on load.

## 12. Raid state saved on raiders, and `raids` saved data

### 12.1 Keys on a raider (`PatrollingMonster`, `Raider`)

| Key | Type | Written when | Read default | Source |
|---|---|---|---|---|
| `patrol_target` | IntArray(3) (`BlockPos`) | only when set (`storeNullable`) | none | `PatrollingMonster` |
| `PatrolLeader` | Byte | always | 0 | `PatrollingMonster` |
| `Patrolling` | Byte | always | 0 | `PatrollingMonster` |
| `Wave` | Int | always | 0 | `Raider`: the wave (group number) the raider belongs to |
| `CanJoinRaid` | Byte | always | 0 | `Raider`: whether the raider may join a raid (set true when it joins one; patrol and raid spawners set it) |
| `RaidId` | Int | only when the raider is attached to a raid **and** the level is a server level **and** the raid is still in the level's raid map (`Raids.getId` returns an id) | none | `Raider`: the raid's id in `raids` saved data |

`RaidId` read (server levels only; on a client level nothing is read): when the key is present, `Raids.get(id)` is looked up; a missing raid leaves the raider with no raid (no error). When the raid exists:

1. The raider's raid field is set.
2. `Raid.addWaveMob(level, wave, raider, false)` registers the raider in its wave's set. The set is a set keyed by identity of UUID: an existing member with the same UUID is replaced by this instance (the loaded entity replaces the pre-restart reference). The fourth argument false means the raid's `total_health` is **not** increased by the raider's health (the saved `total_health` of the raid already includes it); the boss bar is refreshed and the raid is marked dirty.
3. If the raider is a patrol leader (`PatrolLeader` true), `Raid.setLeader(wave, raider)` runs: it stores the raider as the wave's leader and **replaces the raider's head slot with a freshly made ominous banner with drop chance 2.0** (guaranteed drop), whatever the saved `equipment.head` held.

A raider with `RaidId` absent but `Wave` and `CanJoinRaid` set stays unattached; the raid's `Raids.tick` and `Raid.updateRaiders` re-attach nearby raiders by their `CanJoinRaid` flag (20 §14.2). Raiders are attached to a raid only when they load after the raid exists in the loaded `raids` data; chunk load order between the entity region and the saved data does not matter because the saved data is read when the level opens.

When the raid is over or the id is gone (a finished raid is removed from the map, 12.2), a raider that was part of it loads without a raid and behaves as an unattached raider.

### 12.2 `raids` saved data

Saved data id `minecraft:raids`. Read: the `ServerLevel` constructor calls `computeIfAbsent` with the `Raids` type on `ServerLevel.getDataStorage()`, which returns the storage of the level's own chunk source. That each dimension's chunk source has its own storage (so one `raids` per dimension) is (inferred; Open question 15). Payload (the codec's compound, wrapped as in 12.3):

| Key | Type | Default | Meaning |
|---|---|---|---|
| `raids` | List of raid Compounds | empty (key may be absent) | Raids in the map, in the map's iteration order (inferred, not traced to the write) |
| `next_id` | Int | required | The last id handed out; a new map starts at 1 |
| `tick` | Int | required | Counter of `Raids.tick` calls; the data is marked dirty every 200th tick |

Raid Compound (`RaidWithId.CODEC`: `id` plus the keys of `Raid.MAP_CODEC` inline in the same Compound; every key is **required**, none has a default):

| Key | Type | Meaning |
|---|---|---|
| `id` | Int | The raid id (the value a raider's `RaidId` holds) |
| `started` | Byte | The raid's first wave has been requested |
| `active` | Byte | The raid is running |
| `ticks_active` | Long | Ticks the raid has been active |
| `raid_omen_level` | Int | The bad omen level the raid was started or extended at (the maximum is 5, `DEFAULT_MAX_RAID_OMEN_LEVEL`) |
| `groups_spawned` | Int | Waves spawned so far |
| `cooldown_ticks` | Int | Ticks until the next wave spawns |
| `post_raid_ticks` | Int | Ticks since the raid ended (victory, loss) |
| `total_health` | Float | Sum of the current health of the raiders in the raid, for the boss bar |
| `group_count` | Int | Number of waves, fixed from the difficulty when the raid is created (`Raid.getNumGroups`; table below) |
| `status` | String | `ongoing`, `victory`, `loss` or `stopped` |
| `center` | IntArray(3) | The raid centre block |
| `heroes_of_the_village` | List of IntArray(4) | UUIDs of players who get the Hero of the Village effect (`UUIDUtil.CODEC_SET`, a list of UUIDs read into a set) |

`Raid.getNumGroups` is a switch over the difficulty ordinal (enum order read in `Difficulty`: peaceful, easy, normal, hard; the switch cases cover ordinals 1 to 4, in that order). The result is the wave count:

| Difficulty | `group_count` |
|---|---|
| peaceful | 0 |
| easy | 3 |
| normal | 5 |
| hard | 7 |

(The default branch builds a `MatchException`; it is not reachable with these four constants.) A bonus wave beyond `group_count` when the omen level is above 1 is in 20 §14.2. Other constants read in `Raid` this round: pre-raid cooldown 300 ticks (`DEFAULT_PRE_RAID_TICKS`), raid timeout 48000, post-raid limit 40, hero of the village duration 48000, valid raid radius 96 (squared 9216), removal threshold squared 12544, maximum omen level 5, spawn attempts 5. The lifecycle is in 20 §14.2 and is not repeated.

Not saved: the per-wave raider sets and leaders (rebuilt from the raiders' `RaidId`, 12.1), the boss bar, the random source, the wave spawn position. A raid whose `status` is `stopped` is removed from the map the next tick (`Raids.tick`), and the data is marked dirty.

Id allocation (read, `Raids.getUniqueId`): `next_id` is incremented first and the **new** value is the id. A new `Raids` object has `next_id` 1, so the first raid of a world gets id **2**, the second id 3, and a saved `next_id` of 5 means the last id handed out was 5.

Raids and the game rule: when the game rule `raids` is false, every raid is stopped on the next tick (`Raids.tick`), and then removed.

### 12.3 Saved-data file framing and placement

`SavedDataStorage` writes each saved-data type to a gzip-compressed NBT file (`NbtIo.writeCompressed`; on read a gzip header is detected by its first two bytes 0x1F 0x8B and, when absent, the file is read as plain uncompressed NBT) whose root Compound has two keys: `data` (Compound, the codec's encoding as in 12.2 or section 9) and `DataVersion` (Int, 5023). The file's path is the data type's identifier with the suffix `.dat`, resolved as `<namespace>/<path>.dat` below the storage's data folder (`Identifier.withSuffix(".dat")` then `resolveAgainst`; a path that escapes the data folder is rejected). The identifiers are `minecraft:raids` and `minecraft:wandering_trader`.

Recommended placement in the CobolCraft world folder (a design choice; the artifact leaves the data folder to the caller, so this is (inferred) and is the edit the orchestrator makes to 07 §9.1 and §9.2): per-dimension saved data in `dimensions/<namespace>/<path>/data/minecraft/raids.dat`; world-wide saved data in `data/minecraft/wandering_trader.dat` at the world root. Both use the §9.1 `.dat` framing. A dimension without villages and raids writes no `raids.dat`; a missing file is a new empty `Raids` (the type's constructor supplier). A file that fails to decode is replaced by a new empty value (`Raids.load` falls back to a new `Raids`, the type's error handler logs and continues).

## 13. Piglin, piglin brute, hoglin

Class chains: `AbstractPiglin` < `Monster`; `Piglin` and `PiglinBrute` extend `AbstractPiglin`; `Hoglin` < `Animal` < `AgeableMob` (and implements `HoglinBase`). Piglins are not `AgeableMob`: they have no `Age` keys.

### 13.1 Keys

| Entity type | Key | Type | Written when | Read default | Notes |
|---|---|---|---|---|---|
| `piglin`, `piglin_brute` | `IsImmuneToZombification` | Byte | always | 0 | When true the piglin never converts in the overworld |
| | `TimeInOverworld` | Int | always | 0 | Ticks spent where it would convert, section 13.3 |
| | `CanPickUpLoot` | Byte | by `Mob`, always | **1 (true)** | `AbstractPiglin` re-reads the key after the parent chain with a default of true and calls `setCanPickUpLoot` with it; a missing key therefore means true (the parent reads it with its own default first) |
| `piglin` | `IsBaby` | Byte | always | 0 | Piglin is a monster with a "baby" synced flag, not an age counter; read calls `setBaby` |
| | `CannotHunt` | Byte | always | 0 | When true the piglin does not hunt hoglins (section 13.2) |
| | `Inventory` | List of ItemStack | always | empty | Size 8 (section 3) |
| `piglin_brute` | none of its own | | | | `PiglinBrute` has no save method of its own; its `home` memory is in its Brain |
| `hoglin` | `IsImmuneToZombification` | Byte | always | 0 | |
| | `TimeInOverworld` | Int | always | 0 | |
| | `CannotBeHunted` | Byte | always | 0 | When true piglins never choose this hoglin as a hunt target |
| | `Age`, `ForcedAge`, `AgeLocked`, `InLove`, `LoveCause` | | | | from `AgeableMob` and `Animal` (sections 2 and 45-4 section 3); the first three are written and read only when `canBeABaby()` is true, which it is for the hoglin (no override found) |

Equipment of a piglin (the `equipment` key and `drop_chances` of section 2): a piglin that picks up an item to wield calls `setItemSlotAndDropWhenKilled(slot, stack)`, which sets the item and sets that slot's drop chance to the guaranteed 2.0, so after a save the compound contains `drop_chances` with that slot at 2.0 and `PersistenceRequired` true (`setPersistenceRequired` is called by both hold routines, with the off-hand exception below). Read: `holdInMainHand` always calls `setPersistenceRequired`; `holdInOffHand` calls it only when the stack is NOT the bartering item (`is(BARTERING_ITEM)` false). The off-hand holds the item being admired, section 13.2.

Death drops: `dropCustomDeathLoot` runs the parent routine, then removes **every** stack from the 8-slot `Inventory` and spawns each as an item entity at the piglin (no chance applies); equipment drops follow `drop_chances`. `finishConversion` (zombification) spawns the inventory the same way before the piglin is replaced by a zombified piglin.

### 13.2 Persisted memories

The persisted memory types a piglin family member can hold (types and codecs: 45-4 section 11), with the set sites read in `PiglinAi`, `PiglinBruteAi` and the piglin behaviours:

| Memory | Value | `ttl` at set time | Set by | Notes |
|---|---|---|---|---|
| `admiring_item` | Byte (true) | **119** ticks (`ADMIRE_DURATION`, `admireGoldItem`; `StartAdmiringItemIfSeen` passes the same constant) | the piglin starts admiring a loved item it holds in the off hand | Erased when a hit by anything interrupts the admiring, when the item is too far (`StopAdmiringIfItemTooFarAway`), and when admiring ends |
| `admiring_disabled` | Byte (true) | **400** ticks (`HIT_BY_PLAYER_MEMORY_TIMEOUT`) | `PiglinAi.wasHurtBy` when the attacker is a **player**, after it stopped holding the off-hand item and erased `celebrate_location`, `dancing` and `admiring_item` | While present the piglin does not start admiring |
| `angry_at` | UUID (IntArray(4)) | **600** ticks (`ANGER_DURATION`) | set on the attacker's UUID when the piglin is hurt (and for the brute when it picks its target) | A load re-resolves the UUID lazily; the memory is ignored if the entity is not found |
| `universal_anger` | Byte (true) | **600** ticks | set together with `angry_at` when the target is a player and the game rule `universal_anger` is true | Makes the piglin attack the nearest attackable player |
| `hunted_recently` | Byte (true) | uniform integer from `PiglinAi.TIME_BETWEEN_HUNTS` (`TimeUtil.rangeOfSeconds(30, 120)`), i.e. **600 to 2400** ticks (30 to 120 s), sampled at set time | **spawn**: `PiglinAi.initMemories`, called from `Piglin.finalizeSpawn` (non-brute piglins only), with the spawn's random source, so a freshly spawned piglin already carries this memory; `RememberIfHoglinWasKilled` samples `TIME_BETWEEN_HUNTS` directly (level random) when it sees a hoglin die; `StartHuntingHoglin` and the hoglin-anger path go through `PiglinAi.dontKillAnyMoreHoglinsForAWhile`, which samples the same range with the level random. A save of a never-hunted piglin therefore usually holds this memory | While present the piglin does not start a hunt |
| `home` (brute only) | `GlobalPos` | none | `PiglinBruteAi.initMemories` at spawn: the brute's dimension and **block position at that moment** | The brute's "guard" position (it returns to it); the piglin (non-brute) has no `home` |

The other memories the piglin AI uses (`celebrate_location`, `dancing`, `disable_walk_to_admire_item`, `time_trying_to_reach_admire_item`, `nearest_*`, `ate_recently`, `avoid_target`, `spear_*`) are not serializable and are lost on save. The hoglin persists **no** memory of its own (`pacified`, `avoid_target`, the visible-count memories and the rest have no codec); apart from the empty `memories` Compound, a hoglin's `Brain` carries nothing a load needs.

Barter state: the barter is carried entirely by equipment and the admiring memory: the gold ingot is in the **off-hand slot** (`equipment.offhand`) with `admiring_item` set; when `admiring_item` expires or is erased with the ingot still held, `StopHoldingItemIfNoLongerAdmiring` makes the piglin stop holding the item and (when the held item is the bartering item) the barter happens; the loot of the barter is generated from the data pack's barter loot table (data, not specified). Persistence implication: a save during admiring writes the ingot in `equipment.offhand` and `admiring_item` with a `ttl` of at most 119; a load resumes the countdown, and when the ttl is gone the piglin resolves the admiring on its next tick.

### 13.3 Conversion counters

`AbstractPiglin.customServerAiStep` (and the identical hoglin step) each server tick: if the mob is converting (not immune to zombification, not `NoAI`, and the environment attribute `piglins_zombify` is true at its position, read in `AbstractPiglin.isConverting`; the hoglin uses the same test on its own position) then `TimeInOverworld` increases by 1, otherwise it is set to 0. When `TimeInOverworld` is **greater than 300** (strictly) the mob converts: a piglin plays the converted sound unless the difficulty is peaceful and calls `finishConversion` (zombified piglin); the hoglin makes its conversion sound and calls `finishConversion`, which converts it to a zoglin and gives the zoglin the effect nausea for 200 ticks at amplifier 0 (read in the conversion callback). So the saved `TimeInOverworld` is the number of consecutive converting ticks so far (0 to 300); a loaded value above 300 converts on the first tick.

## 14. Worked examples

Notation: SNBT-like text, only as an example of tags and types; byte flags are written `1b`, `0b`.

### 14.1 A farmer villager with one trade and one gossip

```
{
  id: "minecraft:villager",
  Age: 0, ForcedAge: 0, AgeLocked: 0b,
  VillagerData: {type: "minecraft:plains", profession: "minecraft:farmer", level: 2},
  VillagerDataFinalized: 1b,
  FoodLevel: 12b,
  Xp: 14,
  LastRestock: 18200L, LastGossipDecay: 12000L, RestocksToday: 1,
  Gossips: [{Target: [I; -1163256000, 1357904128, -1820393200, 805306368], Type: "trading", Value: 4}],
  Inventory: [{id: "minecraft:wheat", count: 17}, {id: "minecraft:bread", count: 3}],
  Offers: {Recipes: [{buy: {id: "minecraft:wheat", count: 20}, sell: {id: "minecraft:emerald", count: 1},
                      uses: 2, maxUses: 16, rewardExp: 1b, specialPrice: -1, demand: 0, priceMultiplier: 0.05f, xp: 2}]},
  Brain: {memories: {
    "minecraft:job_site":  {value: {dimension: "minecraft:overworld", pos: [I; 100, 64, -40]}},
    "minecraft:home":      {value: {dimension: "minecraft:overworld", pos: [I; 96, 64, -44]}},
    "minecraft:last_slept": {value: 17800L},
    "minecraft:golem_detected_recently": {value: 1b, ttl: 340L}
  }}
}
```

Expectations: the villager is level 2, so its XP window is 10 to 70 (section 6); `Xp: 14` is inside it. On load, `Inventory` becomes a container of 8 slots: the wheat stack in slot 0 and the bread stack in slot 1. The memories `job_site`, `home` and `last_slept` have no `ttl`; `golem_detected_recently` has 340 ticks left: the counter reaches 0 after 340 ticks and the memory is cleared by the 341st tick, because the expiry test (`ttl <= 0`) runs before the decrement (see 8.1). In the POI region of the section containing (100, 64, -40) there is a record with `type: "minecraft:farmer"`; its `free_tickets` is 0 (the farmer's POI holds 1 ticket, the villager holds it; the maximum is in 44 part 3 §1.2).

### 14.2 An unfinalized newborn villager

A villager spawned without ever being finalized, for example created by a command with no `VillagerData`, saves `VillagerData` and `VillagerDataFinalized: 0b` as written (a save always writes both). If the file is edited to remove `VillagerData` and the flag, the load leaves `plains`, `none`, level 1 and the unfinalized flag, so spawn finalisation may later pick a biome type. If the file has `VillagerDataFinalized: 1b` and no `VillagerData`, the result is `plains`, `none`, level 1, finalized. If `VillagerData` has `type: "minecraft:volcano"` (unknown), the outcome is not verified (Open question 14), and either is accepted. Outcome A (the field falls back to `plains`, the Compound still decodes): the villager is finalized, with `plains` and the stored `profession` and `level`. Outcome B (the whole Compound fails and is absent): with `VillagerDataFinalized: 0b` the villager is **not** finalized and keeps the constructed defaults; with `1b` it is finalized with the defaults.

### 14.3 Inventory merging on load

Saved `Inventory`: `[{id:"minecraft:wheat",count:40},{id:"minecraft:wheat",count:40}]` (two entries because an earlier version had two slots). Load: the first stack goes to slot 0 (40). The second finds slot 0 with the same item and merges: with a maximum stack of 64, `min(64 - 40, 40) = 24` moves, leaving 16 in the incoming stack, which goes to the first empty slot (slot 1). Result: slot 0 = 64, slot 1 = 16.

### 14.4 A pillager that is a raid patrol leader

```
{
  id: "minecraft:pillager",
  Wave: 2, CanJoinRaid: 1b, RaidId: 2,
  PatrolLeader: 1b, Patrolling: 0b,
  Inventory: [{id: "minecraft:arrow", count: 6}],
  equipment: {mainhand: {id: "minecraft:crossbow", count: 1}, head: {id: "minecraft:white_banner", count: 1}}
}
```

Load on a server level where `raids.dat` holds a raid with `id: 2`: the pillager joins wave 2's set; because `PatrolLeader` is 1 the raid makes it wave 2's leader and **replaces its head item with a new ominous banner** (drop chance 2.0); `total_health` is unchanged. If the raid with id 2 is not in the data (finished earlier), the pillager is unattached and keeps its saved banner. `CanPickUpLoot` is true after the load because the pillager forces it.

### 14.5 `raids.dat`

```
{DataVersion: 5023, data: {
  next_id: 3, tick: 8211,
  raids: [
    {id: 2, started: 1b, active: 1b, ticks_active: 5400L, raid_omen_level: 2, groups_spawned: 2,
     cooldown_ticks: 0, post_raid_ticks: 0, total_health: 71.0f, group_count: 5,
     status: "ongoing", center: [I; 100, 64, -40], heroes_of_the_village: []}
  ]}}
```

A world that has never had a raid has `{DataVersion: 5023, data: {next_id: 1, tick: <n>}}` once the type is first created and saved (the `raids` key is omitted for an empty list; recalled-not-verified). Creating the first raid gives it `id: 2` and `next_id: 2`; creating a second gives `id: 3`, `next_id: 3` (the example above is the state after the second raid was created and the first ended and was removed).

### 14.6 Piglin admiring and holding a hunt grudge

```
{
  id: "minecraft:piglin",
  IsImmuneToZombification: 0b, TimeInOverworld: 0, IsBaby: 0b, CannotHunt: 0b,
  CanPickUpLoot: 1b, PersistenceRequired: 0b,
  Inventory: [{id: "minecraft:gold_nugget", count: 5}],
  equipment: {offhand: {id: "minecraft:gold_ingot", count: 1}},
  Brain: {memories: {
    "minecraft:admiring_item":  {value: 1b, ttl: 57L},
    "minecraft:hunted_recently": {value: 1b, ttl: 1480L},
    "minecraft:angry_at": {value: [I; 12345, -678, 90, 1], ttl: 210L}
  }}
}
```

A save of the same piglin one tick later has `admiring_item.ttl` 56, `hunted_recently.ttl` 1479 and `angry_at.ttl` 209 (each memory is checked for expiry before it is decremented, so a stored `ttl: 0` is still a value, and is cleared on the next tick). The off-hand gold ingot has persistence not forced (`PersistenceRequired` stays what it was) because the bartering item is excluded from the "force persistence" call.

### 14.7 A piglin brute

```
{
  id: "minecraft:piglin_brute",
  IsImmuneToZombification: 0b, TimeInOverworld: 0, CanPickUpLoot: 1b,
  Brain: {memories: {"minecraft:home": {value: {dimension: "minecraft:the_nether", pos: [I; 400, 70, -20]}}}}
}
```

The brute never has `IsBaby`, `CannotHunt` or `Inventory` (it is not a `Piglin`).

## 15. Validation rules

A writer or reader of these entities MUST satisfy these. Each is testable with the examples above.

1. **Types.** Every Byte-valued flag in the tables is written as a Byte 0 or 1 and read from any numeric tag with the "non-zero low byte" rule (45-4 section 1). `FoodLevel` is a Byte, `Xp` and `RestocksToday` are Ints, `LastRestock` and `LastGossipDecay` are Longs.
2. **Villager data.** A saved `VillagerData` Compound contains all three keys (`type`, `profession`, `level`); a read that lacks `type` or `profession` uses `plains` or `none`; `level` below 1 reads as 1; an unknown registry key gives either the field default or an absent Compound (Open question 14); both are accepted.
3. **Finalisation.** `VillagerDataFinalized` is true after a load whenever the flag is 1 or `VillagerData` decoded (section 7, rule 3); it is never set true by an absent flag and absent data.
4. **Offers.** `Offers` is omitted exactly when the offers object is null. A stored offer lacking `uses`, `maxUses`, `rewardExp`, `specialPrice`, `demand`, `priceMultiplier` or `xp` takes the defaults 0, 4, true, 0, 0, 0.0, 1; an offer lacking `buy` or `sell` is invalid. An `ItemCost` `count` below 1 is invalid.
5. **Inventory.** `Inventory` has no `Slot`; it contains only non-empty stacks; on load stacks merge into the first slot of the same item and components, then the first empty slot (section 3); the container size (8, 8, 5, 8) bounds what survives.
6. **Gossip.** `Gossips` is always a List; an entry with `Value` below 1 is invalid; reputation and decay rules use the weights of section 5.
7. **Brain.** Only the memory types with a codec are written; a stored `ttl` is a Long; a memory whose type has no slot in the entity's brain is dropped on load; no activity is stored.
8. **POI claims.** The claim is the record's `free_tickets` only. Releasing a POI whose tickets are all free changes nothing. A refresh keeps the tickets of records whose block is still a POI block.
9. **Raiders.** `RaidId` is written only for a raider attached to a raid still in the map; on load a leader's head slot is replaced by the ominous banner; `total_health` is not changed by a load.
10. **Raids.** A new `Raids` has `next_id` 1; ids are allocated by increment-then-use; every key of a raid Compound is required; a `stopped` raid is removed on the next tick.
11. **Piglin family.** `CanPickUpLoot` of a piglin or brute defaults to true when absent; `TimeInOverworld` is 0 to 300 in a running world and conversion happens strictly above 300; the brute has only the `AbstractPiglin` keys; the hoglin adds `CannotBeHunted` and no persisted memory.
12. **Vex.** `life_ticks` is written only for a limited life; its absence on load makes the vex unlimited.
13. **Wandering trader.** `DespawnDelay` is always written; `wander_target` only when set; a negative `Age` is raised to 0 after load.

## 16. Open questions

1. **Library behaviour of optional fields.** That `optionalFieldOf(name, default)` and `lenientOptionalFieldOf(name, default)` omit the key on write when the value equals the default, that "lenient" treats a malformed value as absent, and that `Unit.CODEC` writes `{}` come from the serialization library, which is not in the artifact (recalled, not verified). The decoder-tolerant rule of section 1 avoids depending on them; a test against a reference file would settle it.
2. **Partial failure of a list.** The `Inventory` list is settled (per-element skipping, section 3). For `Gossips` and `Recipes`: whether one invalid element (for example a gossip entry with `Value` 0, or an offer without `sell`) makes the entire `Gossips` or `Recipes` list fail, or only the element is skipped. `resultOrPartial` was read on the entity-level reads, and `45-entity-nbt-4` section 1 infers per-element skipping for `list` reads; the behaviour of `Codec.listOf` for the `store`-style codec reads used here (`read(key, codec)`) was not read (recalled: a failing element fails the whole list). Until settled, an implementation should drop the invalid element and keep the rest, which is the safer behaviour.
3. **`!` removal values in a component patch.** The value stored under a `!`-prefixed key is `{}` (inferred); the removal value codec was not read.
4. **Which sections `poi/` writes.** `SectionStorage.writeChunk` writes a section when an entry exists in memory for it (non-null and present), for every Y in the level range, with no emptiness filter; whether a section with no records and `Valid` true is created in memory at all (on `getOrCreate` vs on first lookup) was not traced. An implementation that writes only non-empty sections reads back identically (an absent section behaves as one with no records after revalidation).
5. **Record order in `Records`.** The save order is the iteration order of a hash map keyed by section-relative position; no order is specified and none is needed on load.
6. **Placement of saved data.** Section 12.3's folders are a design recommendation. The artifact does not fix where the per-dimension storage lives relative to the dimension folder; 07 §9.1 and §9.2 need the `data/minecraft/raids.dat` and `data/minecraft/wandering_trader.dat` rows added by the orchestrator (this document does not edit 07).
7. **Dimension key string form.** `Level.RESOURCE_KEY_CODEC` is read as a resource-key codec; that it is a plain identifier String in NBT (and not, for example, a compound) is (inferred) from its use in `GlobalPos`; no sample file was available.
8. **Whether the shared `Brain` key is written by goal-driven mobs.** Not decided here (it is `45-1` Open question 5 per `45-entity-nbt-4`); this document assumes the key is written for every `LivingEntity` including the wandering trader and hoglin.
9. **Per-profession POI types.** Section 6 lists the professions in registration order; the POI type for each profession and the block states it accepts are in 44 part 3 §1.2, not rechecked here. Confirm that `mason` maps to the `mason` type.
10. **Conversion carry-over.** Which fields a converted mob inherits (`ConversionParams.single(mob, true, false)` for the hoglin: the two booleans were read as true and false, their meaning is in the shared conversion code of 45-2) was not traced here.
11. **Witch and ravager raider keys.** Both extend `Raider` and therefore write the keys of section 12.1; their own keys belong to 45-entity-nbt-5-hostile-mobs. Ravager and Witch each have their own save methods, which 45-5 must cover.
12. **Villager `Brain` for baby villagers.** The memories persist the same way; the baby schedule (play activity) and baby-specific behaviours are in 44 part 3 §3.1 and were not re-read.
13. **Level range of `Sections`.** The section Y range is the level's height accessor (min to max section), which differs per dimension; the values for the standard dimensions come from the dimension data and the world height rules of 10, not restated here.
14. **Unknown `type` or `profession` in `VillagerData`.** Whether `orElseGet` (the default supplier read on the `type` and `profession` fields) also replaces a present but unresolvable identifier, or the whole Compound fails, is behaviour of `com.mojang.serialization`, which is not in the jar (recalled, not verified). Searched: `VillagerData` bytecode only. Sections 6, 14.2 and 15 accept either outcome.
15. **Saved-data scope.** That `raids` is one file per dimension and `wandering_trader` one per world is (inferred). Read: `ServerLevel` calls `computeIfAbsent(Raids.TYPE)` on its own `getDataStorage()` (the chunk source's storage); `WanderingTraderSpawner` receives a `SavedDataStorage`. Not traced: how each chunk source obtains its storage, and which storage the spawner list passes. Section 12.3's placement follows the inference.
16. **Cross-document coverage.** Section 10 and Open question 11 defer the `Zombie`, `ZombifiedPiglin`, `Witch` and `Ravager` keys to 45-5. Checked: 45-5 lists witch and ravager (its sections 4.6, 4.7 and 6.6), zombie (4.1) and zombified piglin (4.3, 4.10). Item stack `count` 1..99 and the `!` patch form come from 45-4 and 00 and were not re-read here.
