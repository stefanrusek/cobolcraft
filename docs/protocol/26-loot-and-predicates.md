# 26 Loot tables and predicates: the engine

| Item | Value |
|---|---|
| Covers | The ENGINE that interprets loot tables, loot conditions (predicates), loot functions, number providers, entry types and the predicate system (entity, item, block, fluid, location, damage source, data component and NBT predicates), plus how each part of the game calls it: block break, explosion, mob death, chests and containers, fishing, archaeology, gifts, bartering, vaults, trial spawners, shearing |
| Does not cover | The rows: the 1447 loot table files, the 3 predicate files and the number-provider files are DATA, copied by the extraction tool (22) and loaded by the registry loader (23 §V18, §RELOADABLE). Enchantment definitions and the enchanting-table selection are in 17 §6; item entity spawning in 41 §2; explosion ray casting in 20 (explosion section) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the shipped data files (`unzip -p`), with no execution. Every value is read in this round unless marked "(inferred)" or "(recalled, not verified)". Counts use `unzip -Z1 | grep -v '/$'` |
| Principal classes | `net.minecraft.world.level.storage.loot.*` (`LootTable`, `LootPool`, `LootContext`, `LootParams`, `entries.*`, `functions.*`, `predicates.*`, `providers.*`, `parameters.*`, `IntLimit`, `IntRangePredicate`, `FloatRangePredicate`), `net.minecraft.advancements.predicates.*` (including `entity.*`), `net.minecraft.core.component.predicates.*`, `net.minecraft.world.item.enchantment.LevelBasedValue`, `net.minecraft.world.RandomSequences` |

Version note: the 26.3 engine differs from the 1.18 to 1.21 engine in several places, and this document follows only
the artifact. The main differences found: (1) a pool, an entry and a table each take a single `condition` and a single
`modifier` (a function; a JSON list is the inline form of the `sequence` function, section 1); (2) every number a table uses is a *context number provider* that can
also be a registry reference (section 9); (3) there is an extra entry type `slots`; (4) there are 42 function types and
20 condition types (sections 7, 8); (5) the entity predicate is a flat map of 24 keyed parts, not a fixed object
(section 10.8); (6) `time_check` reads a world *clock* (section 8).

---

## 1. Layout of the data the engine reads

| Registry (data directory under `data/minecraft/`) | Files in the artifact | Decoded by | Notes |
|---|---|---|---|
| `loot_table/` | 1447 | `LootTable.DIRECT_CODEC` | `blocks` 1201, `entities` 109, `chests` 58, `gameplay` 26, `shearing` 22, `charged_creeper` 6, `archaeology` 6, `spawners` 5, `harvest` 3, `equipment` 3, `dispensers` 3, and one each of `till`, `pots`, `carve`, `brush`, `barrels`. (`entities/` is 93 files at top level plus 16 in the nested directory `entities/sheep/` (one per dye colour), 109 in all, counted with `unzip -Z1 | grep -v '/$'`. 18 §7.6 gives 94: that is the top-level count taken from a listing that includes the directory entry `entities/sheep/` (93 + 1), so it is a directory-entry miscount, not a different artifact. The `type` values in the data: all 1201 `blocks/*` tables are `minecraft:block`, all 109 `entities/*` are `minecraft:entity`, `chests/*` `minecraft:chest` (the row's 58 counts the top-level files of `chests/`; the whole directory holds 63 files, the 5 further ones being in the nested directory `chests/trial_chambers/`, which also holds the trial-chamber reward tables; counted with `unzip -Z1 | grep -v '/$'`: 63 in all, so the other counts of the row, which are top-level, should be read the same way), `gameplay/fishing*` `minecraft:fishing`, `gameplay` gift tables `minecraft:gift`, the piglin table `minecraft:barter`, `shearing/*` `minecraft:shearing`, `archaeology/*` `minecraft:archaeology`; see 2.1.) |
| `predicate/` | 3 | `LootItemCondition.DIRECT_CODEC` | `block/fast_cooking`, `tool/can_shear`, `tool/can_silk_touch`. A condition field may name one of these by id (for example `"minecraft:tool/can_silk_touch"`) |
| `context_int_provider/` | 26 | `ContextIntProviders.DIRECT_CODEC` | named integers: `compostable/*` (5), `cooking/time_*` and `cooking/*_reduction_factor` (20), `brewing/uses_default` |
| `context_float_provider/` | 4 | `ContextFloatProviders.DIRECT_CODEC` | `cooking/speed_default`, `cooking/normal_speed_multiplier`, `cooking/fast_speed_multiplier`, `brewing/speed_default` |
| `item_modifier/` | 0 | `LootItemFunctions.DIRECT_CODEC` | the registry exists (a function field may name a modifier by id) but the artifact ships none |
| `slot_source/` | 0 | `SlotSources.DIRECT_CODEC` | the registry exists; none shipped |

The loader treats these eight registries as RELOADABLE (23 §RELOADABLE). Program-defined parts, not data: the registries of
entry types, function types, condition types, number-provider types, nbt-provider types, score-provider types,
slot-source types, entity-sub-predicate keys and data-component-predicate keys (sections 6 to 10 list them all), the
parameter sets (section 3), and every algorithm in this document.

A field typed "holder" in the schema below accepts three forms (read from the codec composition `Registry.holder(key, DIRECT_CODEC)`):
an inline object (the direct form), a string naming a registry entry, and, for number providers only, a bare
number (section 9.1). A condition or function holder set (`terms`, `functions`) accepts a list of those. For
`modifier`, the shipped data uses either one function object or a list of function objects (for example
`"modifier":[{set_count},{explosion_decay}]` in `blocks/diamond_ore`; a single object in the zombie potato entry). Read from
`LootItemFunctions`: the function codec accepts a JSON list through `SequenceFunction.INLINE_CODEC` (a sequence with no
`condition`, field `functions`; the inline form is used when encoding only if the sequence has no condition), so a list IS a
`sequence` function and applies its members in list order, each receiving the previous result. The entry, pool and table
`modifier` fields are `Optional<Holder<LootItemFunction>>` and are installed with `LootItemFunction.decorate(modifier, consumer, ctx)`,
which wraps a consumer so that each stack first goes through the function (`apply(stack, ctx)`) and then to the inner consumer.
The order of application is therefore: entry modifier, then pool modifier, then table modifier (5.3 step 5).

---

## 2. Schema

### 2.1 Loot table

| Field | Type | Default | Meaning |
|---|---|---|---|
| `type` | parameter-set id (section 3.2) | `generic` (`ALL_PARAMS`) | which context parameters the table may use; checked at validation time. Read from the shipped data: every block table has `"type": "minecraft:block"`, entity tables `minecraft:entity`, fishing tables `minecraft:fishing` (`gameplay/fishing` and its sub-tables), chests `minecraft:chest`, shearing `minecraft:shearing`, archaeology `minecraft:archaeology`, gifts `minecraft:gift`, bartering `minecraft:barter` (counts in section 1) |
| `random_sequence` | identifier | absent | the named random sequence the table draws from (section 4). The data sets it on the tables read (`blocks/stone`, `blocks/diamond_ore`: `minecraft:blocks/<name>`; `entities/zombie`: `minecraft:entities/zombie`; `gameplay/fishing`: `minecraft:gameplay/fishing`; `chests/simple_dungeon`: `minecraft:chests/simple_dungeon`), so the sequence id equals the table key |
| `pools` | list of pool | empty list | |
| `modifier` | function | absent | applied to every stack the table produces, after the pool and entry functions |

### 2.2 Pool

| Field | Type | Default | Meaning |
|---|---|---|---|
| `entries` | list of entry | required | |
| `condition` | condition | absent | the pool does nothing when it fails |
| `modifier` | function | absent | applied to every stack of the pool, after the entry function |
| `rolls` | int provider | required | number of draws |
| `bonus_rolls` | float provider | constant 0.0 | multiplied by the context luck |

### 2.3 Entry (common fields)

Every entry has `type` (section 6), optional `condition` and optional `modifier`. The single-item style entries
(`item`, `empty`, `dynamic`, `slots`) and the expandable entries (`tag`, `loot_table`) also have `weight` (int, default 1) and
`quality` (int, default 0); `tag` and `loot_table` also have `expand` (boolean, default false). The composite entries
(`alternatives`, `sequence`, `group`) have `children` (list of entry, default empty) and neither weight nor quality.

---

## 3. Loot context

A **loot context** is built from `LootParams` (the server level, a typed parameter map, a luck float, a map of dynamic
drops) plus a random source (section 4). The parameter map is validated against a parameter set when built:
every *required* key of the set must be present, no key outside the set (required or optional) may be set.

### 3.1 Parameter keys (`LootContextParams`)

| Key id | Value type | Used by |
|---|---|---|
| `this_entity` | entity | `entity_properties` with target `this`, `entity_scores`, `fill_player_head`, `copy_name`, number providers, enchanted-item sets |
| `interacting_entity` | entity | target `interacting_entity` |
| `target_entity` | entity | target `target_entity` |
| `last_damage_player` | player | `killed_by_player`, target `attacking_player`; its presence means "killed by a player" |
| `damage_source` | damage source | `damage_source_properties` |
| `attacking_entity` | entity | target `attacker`; `enchanted_count_increase` and `random_chance_with_enchanted_bonus` read the enchantment level from it |
| `direct_attacking_entity` | entity | target `direct_attacker` |
| `origin` | position (x, y, z doubles) | `location_check`, `entity_properties` (distance, relative checks), `damage_source_properties`, `exploration_map` |
| `block_state` | block state | `match_block`, `copy_state` |
| `block_entity` | block entity | `match_block` with block entity predicates, `copy_components`, `copy_name`, `copy_custom_data` |
| `tool` | item stack | `match_tool`, `table_bonus`, `apply_bonus` |
| `explosion_radius` | float | `survives_explosion`, `explosion_decay` |
| `enchantment_level` | int | `enchantment_level` float provider; set by the enchantment effect code for the `enchanted_*` and `hit_block` sets (28 §7.1, §7.2) |
| `enchantment_active` | boolean | `enchantment_active_check`; set only for the `enchanted_location` set by the location-changed hook (28 §7.1, §7.4) |
| `additional_cost_component_allowed` | marker | `enchant_with_levels`, `enchant_randomly` (`include_additional_cost_component`) |
| `container` | slot provider | `slot_source` `slot_range` |

The producing call sites of `enchantment_level` and `enchantment_active` are in the enchantment effect engine, 28 §7 and §8 (they are not set by any loot-table caller of section 11).

Targets accepted wherever a function or condition names an entity (`entity` field, `LootContext$EntityTarget`):
`this`, `attacker`, `direct_attacker`, `attacking_player`, `target_entity`, `interacting_entity`, mapping to the keys
`this_entity`, `attacking_entity`, `direct_attacking_entity`, `last_damage_player`, `target_entity`, `interacting_entity`.
Block-entity targets: `block_entity`. Item-stack targets: `tool`. A *context argument* field (`LootContextArg`, used by `copy_name.source`,
`copy_components.source` and the slot source `slot_range.source`) is a string naming one context key; it is built from `LootContextArg.createArgCodec` by listing the accepted serial names: `copy_name` accepts the entity targets and `block_entity`; `copy_components` accepts entity targets, `block_entity` and `tool`; `slot_range.source` accepts the entity targets, `block_entity` and the extra name `container` (the `container` parameter), default `container`. A `LootContextArg` reads its value with `get(ctx)` (null when the key is absent) and reports the key it reads as a referenced parameter (13.1).

Luck: `LootContext.getLuck()` returns the `LootParams` luck float. It scales bonus rolls (section 5.1) and entry quality
(section 5.2). The callers set it (section 11).

### 3.2 Parameter sets (`LootContextParamSets`): 31 sets

R = required, o = optional (read from the builder lambdas; the registered name is the `type` value, `minecraft:` omitted).

| Set | Required | Optional | Used for |
|---|---|---|---|
| `empty` | | | trial spawner reward ejection with no context (11.9) |
| `generic` | all 16 keys of 3.1 (every key is declared required, read from the builder; see Open question 11) | | the default table type |
| `chest` | origin | this_entity | containers (11.6) |
| `command` | origin | this_entity | `/loot`, `execute if predicate` |
| `command_slot_source` | origin, container | this_entity | slot sources run from commands |
| `command_compute_default` | origin | this_entity | |
| `command_compute_position` | origin, block_state | this_entity, block_entity | |
| `command_compute_entity` | origin, target_entity | this_entity | |
| `selector` | origin, this_entity | | entity selector `predicate=` option |
| `villager_trade` | origin, this_entity, additional_cost_component_allowed | | trade-specific tables |
| `fishing` | origin, tool | this_entity | fishing (11.7) |
| `entity` | this_entity, origin, damage_source | attacking_entity, direct_attacking_entity, last_damage_player | mob death (11.4) |
| `equipment` | origin, this_entity | | spawn equipment tables |
| `archaeology` | origin, this_entity, tool | | brushing (11.8) |
| `gift` | origin, this_entity | | villager gifts, cat gifts (11.10) |
| `barter` | this_entity | | piglin bartering (11.10) |
| `vault` | origin | this_entity, tool | vault reward (11.9) |
| `advancement_reward` | this_entity, origin | | advancement rewards |
| `advancement_entity` | this_entity, origin | | advancement entity conditions, predicate context (10.8) |
| `advancement_location` | this_entity, origin, tool, block_state | block_entity | |
| `block_use` | this_entity, origin, block_state | | |
| `block` | block_state, origin, tool | this_entity, block_entity, explosion_radius | block drops (11.1) |
| `shearing` | origin, this_entity, tool | | shearing (11.5) |
| `entity_interact` | target_entity, tool | interacting_entity | |
| `block_interact` | block_state, origin | block_entity, interacting_entity, tool | |
| `container_process` | block_entity, block_state, container, origin | | |
| `enchanted_damage` | this_entity, enchantment_level, origin, damage_source | direct_attacking_entity, attacking_entity | enchantment effect conditions |
| `enchanted_item` | tool, enchantment_level | | |
| `enchanted_location` | this_entity, enchantment_level, origin, enchantment_active | | |
| `enchanted_entity` | this_entity, enchantment_level, origin | | |
| `hit_block` | this_entity, enchantment_level, origin, block_state | | |

The "Used for" column is confirmed from code for the sets that section 11 reads (`block`, `entity`, `chest`, `fishing`, `archaeology`, `gift`, `barter`, `vault`, `shearing`, `empty`, `advancement_entity`); for the other sets it is by name only.

---

## 4. Randomness

1. A `LootTable` call receives either a seed, a `RandomSource`, or nothing.
2. **Explicit seed `s != 0`**: the context random is `RandomSource.create(s)`, which is the Java LCG
   (`LegacyRandomSource`, 10 §2.6). A seed of 0 means "no seed" (`RANDOMIZE_SEED = 0`).
3. **Explicit `RandomSource`**: used as is.
4. **Otherwise**: if the table has `random_sequence = id`, the random is the server's named sequence `id`
   (`MinecraftServer.getRandomSequence(id)` = `RandomSequences.get(id, worldSeed)`); if the table has no sequence, the
   level's own random (`ServerLevel.random`) is used.
5. **Sequence seeding** (read from `RandomSequences.createSequence` and `RandomSequence.createSequence`). `RandomSequences` keeps one persistent sequence per id (saved data `random_sequences`; each sequence stores its Xoroshiro state, so the next call continues). A new sequence for id `id` and world seed `W` is created in two stages:
   1. `S = (includeWorldSeed ? W : 0) xor (long)(int) salt` (the int `salt` is sign-extended to a long before the xor).
   2. `seed128 = upgradeSeedTo128bitUnmixed(S)`; when `includeSequenceId` is true (a present id), `seed128 = seed128 xor seedForKey(id)` (xor of both 64-bit words); then `seed128 = mixed(seed128)`; the generator is `XoroshiroRandomSource(seed128)` (Xoroshiro128++, 10 §2.3).
   `upgradeSeedTo128bitUnmixed(S)`: `lo = S xor 7640891576956012809` (0x6A09E667F3BCC909), `hi = lo + (-7046029254386353131)` (0x9E3779B97F4A7C15 as a signed 64-bit constant, wrapping add); both words are the pair of the 128-bit seed, with no mixing yet. `mixed()` applies `mixStafford13` to both words (10 §2.2). `seedForKey(id)` is `seedFromHashOf(id.toString())`, the MD5 construction of 10 §2.4. The formula is read; the constants above are the literals read from the bytecode.
   **The three parameters are state, not constants.** `salt` (int), `includeWorldSeed` and `includeSequenceId` are fields of the saved data (JSON `salt`, `include_world_seed`, `include_sequence_id`; the booleans default to true when absent from the saved data, and a fresh `RandomSequences` has `includeWorldSeed = includeSequenceId = true`; the salt of a fresh object is 0, (inferred: the constructor stores no value)). `RandomSequences.setSeedDefaults(salt, includeWorldSeed, includeSequenceId)` changes them for sequences created afterwards, `reset(id, worldSeed [, salt, includeWorldSeed, includeSequenceId])` replaces one sequence, and `clear()` drops all sequences (which then re-seed on next use). Already-created sequences keep their stored state. An implementation must persist the three values and the per-id generator states.
6. All random draws below use the generator's `nextInt(bound)`, `nextFloat()`, `nextBoolean()`; for the Xoroshiro
   generator the definitions are 10 §2.3, for the Java LCG 10 §2.6.
7. Helper formulas read from `Mth`/`Util`: `Mth.nextInt(r, min, max)` = `min` if `min >= max` else `r.nextInt(max - min + 1) + min`;
   `Mth.nextFloat(r, min, max)` = `min` if `min >= max` else `r.nextFloat() * (max - min) + min`;
   `Util.shuffle(list, r)`: for `i` from `size` down to 2: `j = r.nextInt(i)`; swap the elements at `i - 1` and `j`.
8. **Table to table**: when a table is evaluated through `LootTable.getRandomItems`, one context (one random) serves the table and every nested table of `loot_table` entries.

---

## 5. Evaluating a table

### 5.1 `LootTable.getRandomItems(params [, seed | random])`

1. Build the context (section 4) and a fresh result list.
2. Mark the table as *visited* in the context (a set of (type, element) pairs). If it is already in the set (a nested table
   that loops back), log "Detected infinite loop in loot tables" and produce nothing for this call. Otherwise continue and, at the end, remove it again.
3. The output consumer chain is: the final consumer, wrapped by the table `modifier` if present. (Wrapping means: every stack first passes through the function, then reaches the inner consumer.)
4. For each pool in order, run the pool (5.2).
5. Final consumer (the one `getRandomItems` installs, `createStackSplitter`): a stack whose item is not enabled by the level's feature flags is dropped; a stack with
   `count < maxStackSize` is passed on unchanged (this includes counts of 0 or below; callers drop empty stacks); a stack with `count >= maxStackSize` is split
   into stacks of `maxStackSize` and one remainder, in that order, until the count is used up. Example: 70 of a 64-stack becomes 64 then 6; exactly 64 becomes one stack of 64.
   The nested form `getRandomItemsRaw` used by `loot_table` entries does not split.

### 5.2 Running a pool

1. If the pool has a `condition` and it fails: stop (no random draw is made for the pool).
2. Wrap the consumer with the pool `modifier`.
3. `n = rolls.getInt(ctx) + floor(bonus_rolls.getFloat(ctx) * luck)` (`rolls` is evaluated first, then `bonus_rolls`; `floor` is `Mth.floor` on a float, an `int`).
4. Repeat `n` times (zero or negative `n`: no iteration) the draw (5.3).

### 5.3 One draw from a pool

1. Walk the pool's entries in order; each calls `expand(ctx, collector)` (section 6). `expand` returns false when the entry's own `condition` fails; otherwise the entry (or its children) emits zero or more *leaf entries* to the collector.
   The collector keeps a leaf only if its **effective weight** is positive, adds that weight to a running total, and appends it to the candidate list. Effective weight of a leaf is
   `max(0, floor(weight + quality * luck))` (float arithmetic: `weight` and `quality` are converted to float, multiplied/added, floored).
2. If the total is 0 or the list is empty: the draw produces nothing and uses no random number.
3. If the list has exactly one leaf: that leaf produces its stacks; **no random number is drawn**.
4. Otherwise `r = random.nextInt(total)`; walk the leaves in order subtracting each effective weight from `r`; the first leaf for which the result is below 0 is chosen and produces its stacks.
5. A chosen leaf's stacks pass through the entry `modifier` (if the entry that produced the leaf has one), then the pool modifier, then the table modifier (section 5.1 step 3, nesting order: entry first, table last).

Note: random numbers consumed *while expanding* (conditions with `random_chance`, number providers inside conditions) are consumed before step 4, in entry order. A condition on an entry is evaluated once per draw, not once per table evaluation.

### 5.4 Filling a container (`LootTable.fill(container, params, seed)`)

Used by chests and other containers (11.6). Steps: roll the table into a list `L` (with splitting, 5.1); `random` is the context random;
`slots` = the indices of the *empty* slots of the container, shuffled (`Util.shuffle`). Then `shuffleAndSplitItems(L, slots.size, random)`:
1. Remove empty stacks from `L`; every stack with count > 1 is moved to a separate list `S`.
2. While `slots.size - L.size - S.size > 0` and `S` is not empty: take a stack from `S` at `Mth.nextInt(random, 0, S.size - 1)`; draw `k = Mth.nextInt(random, 1, count / 2)`; split `k` items off it into a new stack; for each of the two stacks (the remainder first, then the split-off one): if its count is still > 1 and `random.nextBoolean()` is true it goes back to `S`, otherwise to `L`.
3. Append all of `S` to `L`; shuffle `L` with `Util.shuffle`.
Then for each stack of `L`, take the last slot of `slots`; if `slots` is empty, log "Tried to over-fill a container" and stop; an empty stack clears its slot, otherwise it is placed. (The order of `nextBoolean` draws: remainder first, then split-off. This is read from the bytecode order.)

---

## 6. Entry types (`LootPoolEntries`, 9 types)

`expand` of every entry first tests the entry's `condition` (false if it fails: nothing is collected, and it counts as "did not run" for `alternatives` and `sequence`). It then calls the type's own expansion.

| `type` | Extra fields | Behaviour | Returns |
|---|---|---|---|
| `item` | `name` (item id) | one leaf; produces one stack of the item, count 1, default components | true |
| `empty` | | one leaf that produces nothing | true |
| `tag` | `items` (item tag / id list), `expand` | if `expand` is false: one leaf that produces one stack of **every** member of the tag, in tag order; if true: one leaf per member (each with this entry's weight and quality), each producing one stack | true |
| `loot_table` | `value` (a loot table id, a list of ids, or a tag of tables), `expand` | if `expand` false: one leaf that runs **every** referenced table in order with the same context via `getRandomItemsRaw` (no stack splitting, loop guard of 5.1); if true: one leaf per referenced table | true |
| `dynamic` | `name` (identifier) | one leaf; produces the stacks the caller registered for that name in `LootParams` dynamic drops (`LootParams.addDynamicDrops(name, consumer)`); nothing if none registered | true |
| `slots` | `slot_source` (slot source, section 6.2) | one leaf; produces a copy of every non-empty item the slot source provides | true |
| `alternatives` | `children` | expands the children in order and stops at the first child whose `expand` returned true (a child whose condition fails returns false; a child that ran, even with weight 0, returns true). With 0 children: always false. With 1 child: that child | true when some child ran |
| `sequence` | `children` | expands the children in order and stops at the first child that returns false. With 0 children: true | true when all ran |
| `group` | `children` | expands every child in order, always | true |

For `alternatives`, `sequence` and `group` only the children's own weights matter (the composite itself has no weight): the leaves of all children that ran are added to the same candidate list of the pool draw.
Each leaf of one `alternatives` entry competes in the same weighted draw as the leaves of the pool's other entries.

### 6.1 Validation of entries (what the engine reports)

A composite with no children reports "Empty children list"; an `alternatives` entry whose non-final child has no `condition` reports "Unreachable entry!" (the final child may be unconditional). These are validation problems (23 §V18), not runtime errors.

### 6.2 Slot sources (`SlotSources`, 6 types; package `net.minecraft.world.item.slot`)

A slot source maps a loot context to a **slot collection** (`SlotCollection`: an ordered collection of slot accessors with `size`, `itemCopies` (copies of the stacks in the slots, in order), `filter(item predicate)`, `limit(n)`, `flatMap(stack to collection)` and `concat(list)`). The registered names are `group`, `filtered`, `limit_slots`, `slot_range`, `contents`, `empty`. A slot source field accepts a direct object, a registry id (registry `slot_source`, empty in the artifact) or, for `group`, a list.

| `type` | Fields | Result |
|---|---|---|
| `group` | `terms` (a list of slot sources; the list may be written inline in place of the object) | the concatenation (`SlotCollection.concat`) of the members' collections in list order (a group of 0 is the empty collection, of 1 is that member) |
| `filtered` | `slot_source`, `item_filter` (item predicate, 10.1) | the inner collection with `filter(item_filter)`: only slots whose stack matches |
| `limit_slots` | `slot_source`, `limit` (int) | the inner collection with `limit(limit)`: the first `limit` slots |
| `slot_range` | `source` (a context argument, default `container`, see 3.1), `slots` (a slot range: a named range of the target's slot numbering, resolved to a list of slot indices by `SlotRange.slots()`) | if the value read from `source` is a slot provider (an entity or a block entity container), `getSlotsFromRange(slots)`; otherwise the empty collection (inferred from the instance test in `provide`; the final fallback branch was not traced) |
| `contents` | `slot_source`, `component` (container component: `container`, `bundle_contents` or `charged_projectiles`) | `flatMap` over the inner collection: for each stack, the stacks stored inside its container component (an empty collection for a stack without the component) |
| `empty` | | the empty collection |

`slot_range` references the context parameter named by `source` (13.1); `group`, `filtered`, `limit_slots` and `contents` validate their inner source recursively. A `slots` entry (section 6) then produces a copy of every **non-empty** stack of the collection (`itemCopies`), one leaf. The per-slot position order of `SlotRange.slots()` and the slot-name tables are the entity and container slot documents' matter (not read here, Open question 1). No shipped table uses a `slots` entry.

## 7. Functions (`LootItemFunctions`: 42 types)

A function maps (stack, context) to a stack. Every function except `filtered` and `discard` derives from the *conditional function* (`sequence` does too: `SequenceFunction` extends it, with an optional `condition` that gates the whole list; the inline list form has none): it has an optional `condition`; when that fails the stack is returned unchanged. Functions mutate the stack in place unless noted. Where a function says "if the stack is empty, nothing happens" it returns the stack as is.

### 7.1 Core functions

| `type` | Fields (default) | Semantics (read) |
|---|---|---|
| `set_count` | `count` (int provider), `add` (false) | new count = (`add` ? current count : 0) + `count.getInt(ctx)` |
| `set_item` | `item` | replace the item, keep count and components (`transmuteCopy`) |
| `limit_count` | `limit` (an `IntLimit`: `{min?, max?}` of int providers, or both) | count = clamp: both bounds: `Mth.clamp(count, min, max)`; only min: `max(min, count)`; only max: `min(max, count)`. A bound is evaluated from its provider per call |
| `explosion_decay` | | if `explosion_radius` is present: `p = 1.0f / radius`; count = number of items among the original `count` for which a fresh `random.nextFloat() <= p` (one draw per item, in order; `count` draws). Without the parameter: unchanged |
| `enchanted_count_increase` | `enchantment` (default `looting`), `count` (float provider), `limit` (0) | if the `attacking_entity` is a living entity: `L = EnchantmentHelper.getEnchantmentLevel(enchantment, attacker)` (the highest level over the entity's equipped items in the slots that enchantment's definition lists); if `L = 0` unchanged; else grow the stack by `Math.round(L * count.getFloat(ctx))` (round half up; may be negative) and, if `limit > 0`, cap the count at `limit` (`limitSize`). For `looting`, the data uses `count` = uniform(0.0, 1.0) |
| `apply_bonus` | `enchantment`, `formula`, `parameters` | requires `tool`; `L` = level of the enchantment on the tool stack (`getItemEnchantmentLevel`); new count = formula(random, count, L). Formulas: `uniform_bonus_count` (`bonusMultiplier`): `count + random.nextInt(bonusMultiplier * L + 1)`; `ore_drops`: if `L > 0`: `m = max(0, random.nextInt(L + 2) - 1)`, count = `count * (m + 1)`, else `count`; `binomial_with_bonus_count` (`extra`, `probability`): `n = L + extra` Bernoulli trials, each `random.nextFloat() < probability`, new count = `count` + number of successes. Without a tool: unchanged |
| `furnace_smelt` | `use_input_count` (true) | empty stack: unchanged. Look up a smelting recipe for the single input stack (`RecipeType.SMELTING`, `SingleRecipeInput`); if one exists and its assembled result is not empty: the result stack with count = (`use_input_count` ? input count : 1) × result count, capped at the result's max stack size. If there is no recipe the stack is returned unchanged (a warning is logged) |
| `discard` | | returns the empty stack (the output stack then has count 0 / is empty) |
| `sequence` | `functions` | apply the listed functions in order |
| `filtered` | `item_filter` (item predicate), `on_pass`, `on_fail` | if the predicate (10.1) matches the stack: apply `on_pass` (if present) else, when not matching, `on_fail` (if present); absent branch = identity |

### 7.2 Enchantment functions

The level used by `enchanted_count_increase` and the bonus conditions on an *entity* is `EnchantmentHelper.getEnchantmentLevel(enchantment, entity)`: the **maximum** over the stacks of `Enchantment.getSlotItems(entity)` (a map from equipment slot to stack, containing the slots in which the enchantment's definition is active) of `getItemEnchantmentLevel(enchantment, stack)`, which is the level in the stack's `enchantments` component (0 if absent). `apply_bonus` and `table_bonus` read only `getItemEnchantmentLevel` on the `tool` stack. The slots per enchantment are data (28 §2).

| `type` | Fields (default) | Semantics |
|---|---|---|
| `enchant_with_levels` | `levels` (int provider), `options` (enchantment list/tag, default: every enchantment in the registry), `include_additional_cost_component` (false) | `EnchantmentHelper.enchantItem(random, stack, levels, options)` = the enchanting-table selection of 17 §6.5 with `level = levels.getInt(ctx)` and the pool = `options`; a `book` becomes `enchanted_book` with the chosen enchantments, any other item is enchanted in place. Then, if `include_additional_cost_component` and the context has `additional_cost_component_allowed` and the stack is non-empty and `levels > 0`: set the component `additional_trade_cost` to `levels` |
| `enchant_randomly` | `options` (default all), `only_compatible` (true), `include_additional_cost_component` (false) | candidate list = `options` (or the whole registry) filtered, when the stack is not a `book` and `only_compatible`, by `Enchantment.canEnchant(stack)`; choose one at random with `Util.getRandomSafe(list, random)`; if none: log "Couldn't find a compatible enchantment" and return unchanged; level = `Mth.nextInt(random, enchantment.minLevel, enchantment.maxLevel)`; a `book` becomes `enchanted_book`; add the enchantment at that level. If `include_additional_cost_component` and the context allows it: set `additional_trade_cost` = `2 + random.nextInt(5 + 10 * level) + 3 * level` (draw order: after the level draw) |
| `set_enchantments` | `enchantments` (map enchantment to int provider), `add` (false) | a `book` is first converted to `enchanted_book`; for each entry: new level = `clamp((add ? current level : 0) + provider.getInt(ctx), 0, ...)`: the sum is clamped with `Mth.clamp(x, 0, 255)` (`sipush 255`, read at both clamp sites of `SetEnchantmentsFunction`, the `add` and the non-`add` path); level 0 removes the enchantment |

### 7.3 Item data functions

| `type` | Fields | Semantics |
|---|---|---|
| `set_damage` | `damage` (float provider: fraction of durability *remaining*), `add` (false) | only for damageable items (otherwise log "Couldn't set damage of loot item"). Let `max` = max damage, `base = add ? 1 - currentDamageValue/max : 0` (`currentDamageValue` is the stack's existing damage, not the `damage` provider; the provider value is `p`); new damage value = `floor((1 - clamp(p + base, 0, 1)) * max)`. Worked example with `add` true, stack of max 100 with current damage 40, `p` = 0.25: `base = 1 - 40/100 = 0.6`; `clamp(0.85, 0, 1) = 0.85`; new damage `floor(0.15 × 100) = 15` (the item ends with more durability remaining) |
| `set_name` | `name` (text component), `entity` (entity target, optional), `target` (serial names `custom_name` or `item_name`; default `custom_name`, read: the codec is `optionalFieldOf("target", CUSTOM_NAME)`; the `entity` field is an optional entity target) | sets the chosen component to the name after resolving selector/score/NBT components against a command source built from the `entity` (permission level game master); a resolution failure logs "Failed to resolve text component" and uses the unresolved text |
| `set_lore` | `lore` (list of components), `mode` (a *list operation*, 7.5), `entity` | applies the list operation to the stack's existing lore lines with the (resolved) new lines; an empty result list is allowed |
| `copy_name` | `source` (entity or block entity target) | if the source object has a custom name: set `custom_name` to it |
| `copy_state` | `block`, `properties` (list of property names of that block's state definition; unknown names dropped at load) | requires `block_state`; updates the `block_state` item component: for each listed property that the context block state has, copy its value |
| `copy_components` | `source`, `include` (list of component types, optional), `exclude` (list, default empty) | reads the component map of the source (block entity: its collected components; entity or tool: its components); copies every component type that is in `include` (when given; else every registered component type) and not in `exclude`, when the source has a value for it |
| `set_components` | `components` (a component patch) | applies the patch and validates the result (`applyComponentsAndValidate`) |
| `set_custom_data` | `tag` (a compound) | merges the tag into the `custom_data` component (`CustomData.update`) |
| `copy_custom_data` | `source` (NBT provider, 9.5), `ops` (list of {`source` path, `target` path, `op`}) | `op` is `replace` (set the target path to the last source value), `append` (append copies of the source values to the list at the target path), `merge` (merge each source compound into the compound at the target path). Applied in list order on a working copy of the stack's `custom_data`, stored back if any op ran; an op whose source path yields no values is skipped; a missing source tag skips all |
| `set_attributes` | `modifiers` (list of {`id`, `attribute`, `operation`, `amount` (float provider), `slot` (one slot group or a list)}), `replace` (true) | for each modifier in order: choose the slot with `Util.getRandom(slots, random)` (one draw even for a single slot, same as a list of one; (inferred) a single value is a list of one), amount = `amount.getFloat(ctx)`, add the attribute modifier. `replace` starts from an empty modifier list, else keeps the existing ones |
| `set_potion` | `id` | set the `potion_contents` potion |
| `set_random_potion` | `options` (potion set, default all potions) | choose with `HolderSet.getRandomElement(random)` (or `Registry.getRandom` when no options) and set it as `potion_contents`; nothing if none |
| `set_stew_effect` | `effects` (list of {`type`, `duration` (int provider)}) | only for `suspicious_stew` with a non-empty list: choose one entry with `Util.getRandom`; the duration in ticks = provider value, times 20 unless the effect is instantaneous; set `suspicious_stew_effects` (adds to existing) |
| `set_instrument` | `options` (instrument set) | choose with `getRandomElement(random)` and set it |
| `set_ominous_bottle_amplifier` | `amplifier` (int provider) | set `ominous_bottle_amplifier` to `clamp(value, 0, 4)` |
| `set_random_dyes` | `number_of_dyes` (int provider) | `n = provider value`; if `n <= 0` unchanged; draw `n` colours with `Util.getRandom(DyeColor.VALUES)` and apply them with the dyed-colour mixing (`DyedItemColor.applyDyes`) |
| `set_banner_pattern` | `patterns`, `append` | the pattern layers; `append` adds to the existing layers else replaces |
| `set_book_cover` | `title`, `author`, `generation` | written-book metadata (each optional) |
| `set_written_book_pages` / `set_writable_book_pages` | `pages`, `mode` (list operation) | edit the book page list with the list operation |
| `set_fireworks` / `set_firework_explosion` | `explosions` (list operation), `flight_duration` / `shape`, `colors`, `fade_colors`, `trail`, `twinkle` | set the firework components |
| `set_custom_model_data` | `floats`, `flags`, `strings`, `colors` (each with a list operation) | edit the `custom_model_data` lists |
| `toggle_tooltips` | `toggles` (map component type to boolean) | update `tooltip_display` hidden components accordingly |
| `fill_player_head` | `entity` | if the stack is a `player_head` and the entity target is a player: set `profile` to the resolved game profile of that player |
| `exploration_map` | `destination` (a holder set of `Registries.STRUCTURE`: a structure id, a list of ids or a tag, for example the `#minecraft:on_*_explorer_maps` tags of the data; not a structure *set*), `decoration` (map decoration type, default the `woodland_mansion` decoration type), `zoom` (byte, default 2), `search_radius` (default 50), `skip_existing_chunks` (true) | if the stack is empty, nothing; needs `origin` (else unchanged); finds the nearest structure with `ServerLevel.findNearestMapStructure(destination, originBlock, search_radius, skip_existing_chunks)`; if found, makes the stack a filled map centred on that structure with scale `zoom`, renders the biome preview, and adds a target decoration with the key `+` and the given type; if none found, unchanged (details of the map rendering are not covered) |

### 7.4 Container functions

| `type` | Fields | Semantics |
|---|---|---|
| `set_contents` | `component` (`container`, `bundle_contents` or `charged_projectiles`), `entries` (entries as 6) | empty stack: nothing. Otherwise the entries are expanded and rolled as one pool draw each... **not traced**; the function builds the contents from the produced stacks and stores them in the component (Open question 2) |
| `modify_contents` | `component`, `modifier` | for each item stack inside the component, replace it by `modifier(stack)` |
| `set_loot_table` | `loot_table_id`, `seed` (0) | set the `container_loot` component to (table key, seed) (an unopened chest keeps a table until first opened, 11.6) |

### 7.5 List operations (`ListOperation`)

Used by `set_lore`, book pages, `set_custom_model_data`, `set_fireworks`. Field `mode` selects the form; `max` is the component's size limit (a function-specific bound):

| `mode` | Fields | Result |
|---|---|---|
| `replace_all` | | the new list |
| `replace_section` | `offset` (default 0), `size` (optional) | if `offset > current size`: log error and keep the list. Result = current[0, offset) + new + current[min(offset + size, current size) ..), where `size` defaults to the length of the new list; if the result is longer than `max`: log "Contents overflow in section replacement" and keep the list |
| `insert` | `offset` (default 0) | `offset > size` or result longer than `max`: error, keep; else current[0, offset) + new + current[offset ..) |
| `append` | | result longer than `max`: error, keep; else current + new |

---

## 8. Conditions (`LootItemConditionTypes`: 20 types)

A condition returns a boolean from the context. Evaluation never consumes the random source unless stated.

| `type` | Fields | Semantics |
|---|---|---|
| `inverted` | `term` | `not term` |
| `all_of` | `terms` | every term true, evaluated in list order, **stopping at the first false** (an empty list is true). Read from `AllOfCondition.combine` and `Util.allOf`: every variant is an `&&` chain or a loop that returns false at the first failing term, so later terms are not evaluated and consume no random numbers |
| `any_of` | `terms` | some term true, evaluated in list order, **stopping at the first true** (empty list false); read from `AnyOfCondition.combine` and `Util.anyOf` (a loop returning true at the first passing term). Later terms are not evaluated and consume no random numbers. Example: `oak_leaves` pool 1 `all_of[survives_explosion, table_bonus]` draws for `table_bonus` only if `survives_explosion` passed (it draws once itself when `explosion_radius` is present) |
| `random_chance` | `chance` (float provider) | `random.nextFloat() < chance` (one draw, always; the provider is evaluated first) |
| `random_chance_with_enchanted_bonus` | `unenchanted_chance` (float), `enchanted_chance` (a level-based value, 8.1), `enchantment` | `L` = level of `enchantment` on the `attacking_entity` (0 when absent or not living); `chance = L > 0 ? enchanted_chance(L) : unenchanted_chance`; result `random.nextFloat() < chance` (one draw). In the zombie table `enchanted_chance = linear(base 0.035, per_level_above_first 0.01)`, `unenchanted_chance = 0.025` |
| `killed_by_player` | | the `last_damage_player` parameter is present |
| `survives_explosion` | | if `explosion_radius` present: true iff `random.nextFloat() <= 1.0f / radius` (one draw); no parameter: true |
| `table_bonus` | `enchantment`, `chances` (list of floats) | `L` = level on the `tool` stack (0 without a tool); `p = chances[min(L, size - 1)]`; true iff `random.nextFloat() < p` (one draw) |
| `match_tool` | `predicate` (item predicate, optional) | `tool` present and (no predicate or it matches, 10.1) |
| `match_block` | `blocks`, `state`, `nbt`/`components` (a block predicate, 10.3) | the `block_state` matches the block and property parts, and, when the predicate has block-entity parts, the `block_entity` matches them (false when absent) |
| `damage_source_properties` | `predicate` (damage source predicate, 10.9) | needs `damage_source` and `origin`; true when the predicate is absent or matches |
| `entity_properties` | `entity` (target), `predicate` (entity predicate, 10.8) | entity from the target key (may be absent), `origin`; true when the predicate is absent, else `EntityPredicate.matches(level, origin, entity)` (false for an absent entity) |
| `entity_scores` | `entity`, `scores` (map objective to int range) | the entity exists and, for each (objective, range): the entity has a score in that objective and it is in the range |
| `location_check` | `predicate` (location predicate, 10.4), three flat optional integer fields `offsetX`, `offsetY`, `offsetZ` (each default 0, read: `optionalFieldOf(name, 0)`; the wire form is the three flat fields, e.g. `"offsetY": 1`, never a nested object; the engine holds them as one `Vec3i`) | needs `origin`; matches `LocationPredicate.matches(level, origin.x + (double) offsetX, origin.y + (double) offsetY, origin.z + (double) offsetZ)`; without a `predicate` the condition is true once `origin` is present (inferred from the optional field) |
| `weather_check` | `raining`, `thundering` (booleans, optional) | each present field must equal `ServerLevel.isRaining()` / `isThundering()` |
| `time_check` | `value` (int range, tested with the int-range predicate), `clock` (a world clock holder), `period` (long, optional) | `t = level.clockManager().getInstance(clock).totalTicks()` (a long); with `period`, `t = t rem period` (long remainder, `lrem`); then `t` is narrowed to an int (`l2i`) and passed to `IntRangePredicate.test(ctx, int)` (all read) |
| `int_value_check` | `value` (int provider), `range` (int range predicate) | `range.test(ctx, value)` |
| `float_value_check` | `value` (float provider), `range` | same with floats |
| `enchantment_active_check` | `active` (boolean) | the `enchantment_active` parameter exists and equals `active` |
| `environment_attribute_check` | `attribute`, `value` | `ServerLevel.environmentAttributes().getValue(ctx, attribute)` equals `value` (object equality); positional attributes need `origin` |

There is no `block_state_property` type in this artifact: block-state matching is `match_block` with a `state` part. There is no `reference` type either: a condition is referenced by giving its registry id string in place of the object (section 1).

### 8.1 Level-based values (`LevelBasedValue`)

A float function of an enchantment level. A bare number is a constant. Typed forms (`type`): `linear` (`base`, `per_level_above_first`): `base + per_level_above_first * (level - 1)`; `lookup` (`values`, `fallback`): `values[level - 1]` when `level <= values.size`, else `fallback(level)`; `exponent` (`base`, `power`, each a level-based value): `pow(base(level), power(level))` (double pow, narrowed to float); `clamped` (`value`, `min`, `max`): clamp; `fraction` (`numerator`, `denominator`): 0 when the denominator is 0, else the quotient; `levels_squared` (`added`): `level * level + added`.

---

## 9. Number providers

### 9.1 The two families and their forms

The int family (`ContextIntProvider`) and the float family (`ContextFloatProvider`) are separate registries of types (`context_int_provider_type`, `context_float_provider_type`). A provider field accepts (a) a bare number (a `constant`), (b) an object `{"type": ..., ...}`, (c) a string id of an entry of the data registry `context_int_provider` / `context_float_provider` (section 1).

Evaluation entry points: `getIntUnsafe(ctx)` may throw `ArithmeticException`; **`getInt(ctx)` returns 0 when it throws**. `getFloat(ctx)` returns 0.0 when the unsafe value is not finite (NaN or infinity) or an exception occurs. `getFloatOrThrow` throws instead. Int arithmetic is overflow-checked (`addExact` style), so an overflow is an error and therefore 0 through `getInt`.

### 9.2 Int provider types (23)

| `type` | Fields | Value |
|---|---|---|
| `constant` | `value` | the number |
| `uniform` | `min`, `max` (int providers) | `Mth.nextInt(random, min, max)` (inclusive; `min >= max` gives `min` with no draw) |
| `binomial` | `n` (int provider), `p` (float provider, `getFloatOrThrow`) | `n` Bernoulli trials, each `random.nextFloat() < p`, the count of successes |
| `weighted_list` | `distribution` (weighted list of int providers) | pick one with the weighted-list random pick (`WeightedList.getRandomOrThrow(random)`), then evaluate it |
| `conditional` | `condition`, `on_true`, `on_false` (default constant 0) | evaluate the chosen branch |
| `number_dispatcher` | `cases` (list of {`condition`, `value`}), `default` | the first case whose condition holds, else `default` |
| `abs` | `input` | `Math.absExact` |
| `negate` | `input` | `negateExact` |
| `avg` | `inputs` | `(sum as long) / count` (long division, truncated), narrowed to int with an overflow check |
| `add` | `inputs` | sum as long, narrowed with an overflow check |
| `mul` | `inputs` | product as long, narrowed with an overflow check |
| `min`, `max` | `inputs` | minimum / maximum (start values `Integer.MAX_VALUE` / `Integer.MIN_VALUE`) |
| `sub` | `left`, `right` | `subtractExact` |
| `div` | `left`, `right` | truncating integer division (error on division by zero) |
| `floor_div` | `left`, `right` | `floorDivExact` |
| `mod` | `left`, `right` | truncating remainder |
| `floor_mod` | `left`, `right` | `floorMod` |
| `pow` | `base`, `exponent` | `powExact`; `0^0` raises "Result of 0 to the power of 0 is undefined" |
| `from_float` | `input` (float provider) | the float, rejected when not finite, converted by `(long)` truncation, narrowed with an overflow check |
| `environment_attribute` | `attribute` | the attribute value converted to int (only attributes whose type defines an int conversion are accepted at load) |
| `score` | `target` (score name provider, 9.4), `score` (objective name), `fallback` (default constant 0) | the scoreboard value of that holder in that objective, else the fallback |
| `storage` | `storage` (identifier), `path` (NBT path), `fallback` (default 0) | the numeric tag at the path in the command storage `storage` (when the path yields exactly one numeric tag), converted with `intValue`, else the fallback |

### 9.3 Float provider types (28)

Same shape; arithmetic is float. `constant`, `uniform` (`Mth.nextFloat(random, min, max)`: `min` if `min >= max`, else `nextFloat() * (max - min) + min`), `weighted_list`, `conditional`, `number_dispatcher`, `abs`, `negate`, `avg` (`sum / (float) count`), `add`, `mul` (`product`, start 1.0), `min`/`max` (start +/- `Float.MAX_VALUE`), `sub`, `div` (plain `left / right`), `mod` (`NaN` when `right == 0`, else the float remainder), `pow` (`NaN` for 0^0, else `Math.pow` narrowed), `environment_attribute`, `storage`, and the float-only types:

| `type` | Fields | Value |
|---|---|---|
| `ceil` | `input` | `(float) Mth.ceil(x)` |
| `floor` | `input` | `(float) floor(x)` (double floor) |
| `round` | `input` | `(float) Math.round(x)` (half up) |
| `truncate` | `input` | towards zero (`floor` for positive, `ceil` otherwise) |
| `sqrt` | `input` | `Mth.sqrt` |
| `length` | `inputs` | `Mth.sqrt(sum of squares)` |
| `sin`, `cos` | `input` | `Mth.sin(double)` / `Mth.cos(double)`: **table lookups**. `SIN[i] = (float) Math.sin(i / 10430.378350470453)` for `i` in 0..65535; `sin(x) = SIN[(int)((long)(x * 10430.378350470453) & 65535)]`; `cos(x) = SIN[(int)((long)(x * 10430.378350470453 + 16384.0) & 65535)]` |
| `from_int` | `input` (int provider) | the int as a float |
| `enchantment_level` | `amount` (a level-based value, 8.1) | `amount(level)`, where `level` = the `enchantment_level` parameter (level 0 when the parameter is absent) |

### 9.4 Score name providers

`fixed` (`name`: a literal score holder name) and `context` (`target`: an entity target, the entity's score-holder name).

### 9.5 NBT providers

`context` (`target`: an entity or block entity target; its saved NBT) and `storage` (`source`: a command storage id). Used by `copy_custom_data`.

### 9.6 Where the named values are used

The data-registry values (section 1) feed fuel burn times, compost chances and brewing and cooking speeds (named as in the file names). They are consumed by the furnace, composter and brewing systems; the engine only evaluates them. Which file feeds which code is outside this document.

---

## 10. Predicates

The shapes below are the JSON schemas the engine decodes. All predicate fields are optional unless stated; an absent field imposes no condition. "Bounds" are 10.10.

### 10.1 Item predicate (`ItemPredicate`)

| Field | Test |
|---|---|
| `items` | the stack's item is in the id list or tag (`ItemInstance.is(HolderSet)`) |
| `count` | the stack count is in the int bounds |
| `components` | exact component match (10.2) |
| `predicates` | partial component predicates (10.2) |

Evaluation order: items, count, then components (`DataComponentMatchers.test`: the exact predicate, then every partial predicate).

### 10.2 Data component predicates

`DataComponentMatchers` holds `components` (an exact list) and `predicates` (a map from a predicate key to a predicate).

* **Exact** (`DataComponentExactPredicate`): a list of (component type, value) pairs; true iff for every pair the getter's value of that type equals the expected value (`Objects.equals`). Transient component types are excluded at decode.
* **Partial**: keys (`DataComponentPredicates`, 14 keys), each tested on the component getter:

| Key | Fields | Test |
|---|---|---|
| `damage` | `durability` (int bounds), `damage` (int bounds) | needs the `damage` component (else false); `durability = max_damage - damage` (max_damage defaults 0) must be in the `durability` bounds and the damage value in the `damage` bounds |
| `enchantments`, `stored_enchantments` | list of enchantment predicates (`enchantments`: id set; `levels`: int bounds) | every list entry must be satisfied by the stack's enchantments (`EnchantmentPredicate.containedIn`): with `enchantments` given, SOME enchantment in that set must be present with a level in `levels` (level 0 = absent; no `levels` means any level); without `enchantments` and with `levels`: some enchantment on the stack has a level in `levels`; with neither, the stack has at least one enchantment |
| `potion_contents` | `potions` (potion set), `effects` (collection predicate, 10.11) | if `potions` is given, the stack has a base potion in the set; `effects` tests all effects of the contents |
| `custom_data` | an NBT compound | `CustomData.matchedBy`: partial compound comparison, 10.12 |
| `container`, `bundle_contents` | `items` (collection predicate of item predicates) | tests the contained stacks |
| `firework_explosion` | `shape`, `has_twinkle`, `has_trail` | |
| `fireworks` | `explosions` (collection predicate), `flight_duration` (int bounds) | |
| `writable_book_content`, `written_book_content` | `pages` (collection predicates), written: `author`, `title`, `generation`, `resolved` | |
| `attribute_modifiers` | `modifiers` (collection of {`attribute`, `id`, `amount` bounds, `operation`, `slot`}) | |
| `trim` | `material`, `pattern` | |
| `jukebox_playable` | `song` | |
| `villager/variant` | the villager type set | |

The rows from `firework_explosion` down are read as to their fields only; the per-field comparison is the plain equality or bounds test the field type implies (Open question 3).

### 10.3 Block predicate (`BlockPredicate`) and state properties

| Field | Test |
|---|---|
| `blocks` | the block state's block is in the id list or tag |
| `state` | state properties (below) |
| `nbt` | block-entity NBT: partial comparison (10.12) of the block entity's saved data (`matchesBlockEntityData`) |
| `components` / `predicates` | data component matchers against the block entity's components |

`matchesState` = blocks then state; the predicate "will match a block entity" when `nbt` or any component matcher is present (then a block entity is needed; `match_block` reports `block_state` and `block_entity` as referenced parameters).

**State properties** (`StatePropertiesPredicate`): a map from property name to a matcher; every entry must match. A property name not in the state definition: the entry fails. Matchers: an exact string (the property's value, parsed with the property's own parser; the state's value must compare equal, `compareTo == 0`; an unparsable string fails), or a range `{min?, max?}` of strings (parsed likewise; the state's value must be `>= min` and `<= max` in the property's ordering: false < true for booleans, enum ordinal order, numeric order for integers; an unparsable bound fails).

### 10.4 Fluid predicate (`FluidPredicate`)

`fluids` (fluid id/tag: `FluidState.is`) and `state` (state properties on the fluid's state definition).

### 10.5 Location predicate (`LocationPredicate`)

| Field | Test |
|---|---|
| `position` | `x`, `y`, `z` double bounds on the coordinates |
| `dimension` | the level's dimension key equals it |
| `biomes` | the biome at the block position is in the set (the chunk must be loaded) |
| `structures` | `StructureManager.getStructureWithPieceAt(pos, structures)` is a valid start |
| `smokey` | equals `CampfireBlock.isSmokeyPos` |
| `light` | light predicate (10.6) |
| `block` | block predicate at the block position (10.3) |
| `fluid` | fluid predicate at the block position (10.4) |
| `can_see_sky` | equals `ServerLevel.canSeeSky(pos)` |

Position tests use the double coordinates; block and light tests use `BlockPos.containing(x, y, z)` (floor). Most terms require the position to be in a loaded chunk, else the predicate fails.

### 10.6 Light predicate

`light` (int bounds): `ServerLevel.getMaxLocalRawBrightness(pos)` in the bounds (false when not loaded).

### 10.7 Distance, movement and misc leaf predicates

* **Distance** (`DistancePredicate`): `x`, `y`, `z` (bounds on `|dx|`, `|dy|`, `|dz|`), `horizontal` (bounds on `sqrt(dx^2 + dz^2)`, tested as the squared value against the squared bounds), `absolute` (bounds on the 3-D distance, likewise squared).
* **Mob effects** (`MobEffectsPredicate`): a map effect id to {`amplifier`, `duration` (int bounds), `ambient`, `visible` (booleans)}; true iff every listed effect is active on the entity and its instance matches; the entity must be living.
* **Collection predicates**: `contains` (a contents predicate), `count` (per element counted tests), `size` (int bounds), all of those present must hold.
* **Tag predicate** `{id, expected}`: holder in the set equals `expected`.
* **Food** (`level`, `saturation` bounds), **game type** (survival, creative, adventure, spectator set), **input** (`forward`, `backward`, `left`, `right`, `jump`, `sneak`, `sprint`: booleans) are leaves of the player predicate (10.8).

### 10.8 Entity predicate

`EntityPredicate` is a **flat object whose keys are the registered part names**; each key's value is decoded by that part's own codec; the predicate matches when **every** present part matches (the parts are sorted by a fixed comparator and combined with logical and: only evaluation order, not outcome, depends on the order). `matches(level, origin, entity)` is false for an absent entity; `origin` is used by the `distance` part (false when `origin` is absent).

The 24 part names (read from `EntitySubPredicates.bootstrap`):

| Key | Fields | Test |
|---|---|---|
| `entity_type` | id / list / tag | the entity's type is in the set |
| `location` | a location predicate (10.5) | at the entity's exact position |
| `stepping_on` | a location predicate | the entity is on the ground and the location test passes at the centre of the block it stands on (`getOnPos`) |
| `movement_affected_by` | a location predicate | at the centre of the block that affects its movement (`getBlockPosBelowThatAffectsMyMovement`) |
| `distance` | a distance predicate (class `DistanceToPlayerPredicate`, field `distance`; despite the class name it takes the context `origin`, not a player) | false when `origin` is absent; else the distance predicate is applied between `origin` (x, y, z) and the entity's position |
| `movement` | `x`, `y`, `z`, `speed`, `horizontal_speed`, `vertical_speed`, `fall_distance` (double bounds) | the entity's known movement vector scaled by 20 (blocks per second): each component in its bounds; `speed` and `horizontal_speed` as squared vs squared bounds; `vertical_speed` on `|y|`; `fall_distance` on `Entity.fallDistance` |
| `effects` | mob effects | 10.7 |
| `nbt` | an NBT compound | `NbtPredicate.getEntityTagToCompare(entity)` (the entity's saved data, for a player plus `SelectedItem`) compared partially (10.12) |
| `flags` | `is_on_ground`, `is_on_fire`, `is_sneaking`, `is_sprinting`, `is_swimming`, `is_flying`, `is_baby`, `is_in_water`, `is_fall_flying` (booleans) | each present flag equals the entity's state |
| `equipment` | `head`, `chest`, `legs`, `feet`, `body`, `mainhand`, `offhand` (item predicates) | the entity must be a living entity; each present item predicate must match that slot's stack |
| `periodic_tick` | an int | `entity.tickCount mod periodic_tick == 0` (inferred remainder test) |
| `vehicle` | an entity predicate | on the entity's vehicle |
| `passenger` | an entity predicate | on at least one passenger |
| `targeted_entity` | an entity predicate | for a mob: on its attack target |
| `team` | a team name | the entity's team name equals it |
| `slots` | a slots predicate | against the entity's slot provider |
| `components` | exact components | the entity's data components |
| `predicates` | partial component predicates | |
| `entity_tags` | `any_of`, `all_of`, `none_of` (lists of strings) | against the entity's scoreboard tags: at least one of `any_of`, all of `all_of`, none of `none_of` |
| `type_specific/lightning` | `blocks_set_on_fire` (int bounds), `entity_struck` | for a lightning bolt |
| `type_specific/fishing_hook` | `in_open_water` | for a fishing hook: equals `isOpenWaterFishing` |
| `type_specific/player` | `level`, `food`, `gamemode`, `stats`, `recipes`, `advancements`, `looking_at`, `input` | for a player; fields in 10.8.1 |
| `type_specific/cube_mob` | `size` (int bounds) | for a slime or magma cube |
| `type_specific/raider` | `has_raid`, `is_captain` | for a raider |
| `type_specific/sheep` | `sheared` | for a sheep |

A type-specific part fails when the entity is not of that kind.

#### 10.8.1 Player part fields (read from `PlayerPredicate`)

All fields are optional. Tests run in this order and the first failure gives false: (1) the entity must be a server player; (2) `level` (int bounds) on the experience level; (3) `food` (10.7) on the food data; (4) `gamemode` (10.7); (5) `stats`: a list of `{type, stat, value}` where `type` is a stat type registry name, `stat` a holder of that type's registry and `value` int bounds (default any); each entry matches when the player's counter for that stat lies in the bounds; (6) `recipes`: a map recipe id to boolean; each entry requires the player's recipe book `contains(recipe) == boolean`; (7) `advancements`: a map advancement id to either a boolean (matches when the advancement's progress `isDone` equals it) or a map criterion name to boolean (each named criterion must exist in the progress and its done state equal the boolean; an unknown criterion name gives false); an advancement id the server does not know is skipped (counts as a pass); (8) `looking_at` (an entity predicate): from the eye position along the view vector for 100 blocks, find the nearest entity hit (spectators excluded by a filter; the search box is inflated by a small margin (value not recorded)); false when there is none or the hit is not an entity; the entity predicate must match that entity (with the player's position as the origin, not recorded in detail) and the player must have line of sight to it; (9) `input` (10.7) on the player's last client input. Example from the data (fishing): `"predicate":{"minecraft:type_specific/fishing_hook":{"in_open_water":true}}`; (zombie) `"predicate":{"minecraft:vehicle":{"minecraft:entity_type":"minecraft:zombie_horse"}}` (the key spelling in the data carries the `minecraft:` namespace).

### 10.9 Damage source predicate and damage predicate

* `DamageSourcePredicate`: `tags` (list of {`id`, `expected`}: the damage type is (or is not) in the tag), `direct_entity` and `source_entity` (entity predicates applied to the direct and the causing entity), `is_direct` (boolean equal to `DamageSource.isDirect`). All present parts must hold.
* `DamagePredicate` (advancement triggers; not used by loot tables): `dealt`, `taken` (double bounds), `source_entity`, `blocked`, `type` (a damage source predicate).

### 10.10 Bounds (`MinMaxBounds`)

Ints and doubles: `{min?, max?}` or a bare number meaning exact; the test is `min <= v` and `v <= max` for each present bound (inclusive). `matchesSqr` compares against the squared bounds. Angles use the same shape. The loot-level **range predicates** (`IntRangePredicate`, `FloatRangePredicate`, used by `limit_count`, `time_check`, `entity_scores`, `int_value_check`, `float_value_check`) are different: a bare provider (`Point`: equality with the provider value, floats compared with `==`) or `{min?, max?}` of providers (`Line`: reject when below `min` or above `max`, inclusive; both bounds are evaluated through the context).

### 10.11 Collection predicates

`contains` (all listed element predicates each matched by at least one element), `count` (for each element predicate, the number of matching elements in a bounds), `size`. A `Zero`/`Single`/`Multiple` internal split is only an optimisation of the same tests.

### 10.12 NBT predicates

`NbtUtils.compareNbt(expected, actual, partialLists = true)`, in order: same object: true; `expected` null: true; `actual` null: false; different tag classes: false. Compounds: `actual.size >= expected.size` and every expected key's value must compare with the actual value of that key (recursively, same flag; a missing key fails). Lists (with the flag): an empty expected list requires an empty actual list; otherwise `actual.size >= expected.size` and every expected element must compare with some actual element (recursively). Everything else: tag equality. `custom_data` uses this on the stack's custom data compound.

---

## 11. How the game uses the engine

Item entities are always spawned with the popResource family (41 §2.1, §2.2); the engine only produces stacks.

### 11.1 Block drops

1. The block's table key is `blocks/<block id path>` unless the block has `noLootTable` (no drops) or an override (derived from the data layout, 1201 files, each with `type` `minecraft:block` and `random_sequence` `minecraft:blocks/<name>`; the derivation in code, `BlockBehaviour$Properties.effectiveDrops`, was not traced, Open question 4). `BlockBehaviour.getDrops(state, paramsBuilder)`: if the block has no table, no drops; else set `block_state`, build with set `block`, and call `LootTable.getRandomItems(params)` (random from the table's `random_sequence`).
2. **Static helper** `Block.getDrops(state, level, pos, blockEntity [, entity, tool])`: `origin = center of pos` (x + 0.5, y + 0.5, z + 0.5), `tool` = the given stack or the **empty stack**, `block_entity` optional, `this_entity` optional.
3. **Player break** (`ServerPlayerGameMode.destroyBlock`, 13 §2): the block is removed first; if the player is not in a mode that prevents drops (`preventsBlockDrops`, creative) and `player.hasCorrectToolForDrops(state)` was true (computed **before** the tool is damaged, from a copy of the held stack), `Block.playerDestroy` runs: awards the `block_mined` statistic, adds 0.005 exhaustion, then `dropResources(state, level, pos, blockEntity, player, tool copy)`, which calls `getDrops` with the tool **copy taken before `mineBlock` damaged the tool** and spawns each stack with `popResource` (41 §2.1), then `spawnAfterBreak` (experience, extra effects). `popResource` is skipped when the stack is empty or the game rule `block_drops` is false.
4. **Non-player removal with drops** (`dropResources(state, level, pos)`): tool = empty stack, no entity.

### 11.2 Explosion drops

`BlockBehaviour.onExplosionHit` runs once per destroyed block, in the shuffled order of 20. Steps, read in this order:
1. **Early exit:** if the block state is air, or the explosion's block interaction is `TRIGGER_BLOCK`, return at once: no drops, no replacement by air and no `wasExploded`.
2. `playerCaused` = whether the explosion's indirect source entity (`getIndirectSourceEntity`) is a `Player`.
3. If `Block.dropFromExplosion(explosion)` is true (true by default; blocks override it): get the block entity if the state has one (else none); build `LootParams` with `origin` = block centre, `tool` = the **empty stack**, optional `block_entity`, optional `this_entity` = the explosion's direct source entity (`getDirectSourceEntity`); **only when the interaction is `DESTROY_WITH_DECAY`** also set `explosion_radius` = the explosion radius `R` (other interactions leave it unset, so `survives_explosion` and `explosion_decay` pass everything); then call `BlockState.spawnAfterBreak(level, pos, emptyStack, playerCaused)` (experience and block-specific extras), and **then** `getDrops` (set `block`, table lookup as 11.1). Note the order: `spawnAfterBreak` runs after the parameters are built (including `explosion_radius`) and before the table is rolled.
4. The stacks from `getDrops` are handed to the explosion's collector callback with the block position (below), not spawned immediately.
5. Whether or not step 3 ran (it is skipped when `dropFromExplosion` is false), the block is then replaced by air with `ServerLevel.setBlockAndUpdate(pos, air)`, and finally `Block.wasExploded(level, pos, explosion)` is called on the original block. So the air replacement and `wasExploded` happen after the drop branch and for every non-air block of a non-`TRIGGER_BLOCK` explosion.

The collector is `ServerExplosion.interactWithBlocks`: it merges the stacks (`addOrAppendStack`): for each new stack it tries each existing collector entry in order; stacks merge while the item and components are mergeable and the entry's count stays at most **16** (`MAX_DROPS_PER_COMBINED_STACK`, `ItemEntity.merge`); an unmerged remainder starts a new entry positioned at the block that produced it. After all blocks, each entry is spawned with `popResource` at its block position.

### 11.3 Shearing and similar

`LivingEntity.dropFromShearingLootTable`: set `shearing` with `origin` = the entity position, `this_entity`, `tool` = the shears; tables in `loot_table/shearing/` (22 files), spawned by the caller.

### 11.4 Mob death

`LivingEntity.dropAllDeathLoot` (see 18 §7.6 for the death sequence):
1. `killedByPlayer = lastHurtByPlayerMemoryTime > 0` (tested first, before `shouldDropLoot`).
2. If `shouldDropLoot` (game rule `mob_drops`): `dropFromLootTable(level, source, killedByPlayer)`: table key = the entity type's default table `entities/<type>` unless the mob has `DeathLootTable` (NBT, `Mob.lootTable` override; the override is cleared after one use (`Mob.dropFromLootTable` resets it to empty)); none: nothing.
3. Params: `this_entity` = the mob, `origin` = its position, `damage_source`, optional `attacking_entity` (`DamageSource.getEntity`), optional `direct_attacking_entity` (`getDirectEntity`); when `killedByPlayer` and the last-hurt-by player is non-null: `last_damage_player` = that player and **luck = that player's luck** (`Player.getLuck`); set `entity`.
4. `LootTable.getRandomItems(params, seed = getLootTableSeed(), consumer)`: for a non-`Mob` living entity the seed is 0 (random sequence); a `Mob` returns its stored `LootTableSeed`. Each stack is spawned as an item entity at the mob's position (18 §7.6, 41 §2).
5. Ordering and conditionality (read from `dropAllDeathLoot`): inside the `shouldDropLoot` (`mob_drops`) branch, right after `dropFromLootTable`, `dropCustomDeathLoot(level, source, killedByPlayer)` is called. So with `mob_drops` false neither the table nor `dropCustomDeathLoot` runs. After that branch, **unconditionally**, `dropEquipment(level)` and then `dropExperience(level, source.getEntity())` run (the experience call takes the damage source's causing entity).

Looting is not a global bonus: the loot functions and conditions of the table (`enchanted_count_increase`, `random_chance_with_enchanted_bonus`) read the enchantment level of the `attacking_entity`'s equipped items.

### 11.5 Gifts

`LivingEntity.dropFromGiftLootTable(level, key, callback)`: params `origin` = the entity position, `this_entity` = the giver, set `gift` (villager hero-of-the-village gifts `gameplay/hero_of_the_village/*_gift` (15 files), cat morning gift `gameplay/cat_morning_gift`, and so on). All stacks go to the callback.

### 11.6 Containers (chests, barrels, minecarts, vaults of structures)

`RandomizableContainer.unpackLootTable(player)`: runs when a container with a `LootTable` key (NBT `LootTable`, `LootTableSeed` (0 if absent)) is opened or broken: loads the table; the `generate_loot` advancement trigger fires for a server player; the key is cleared; params `origin` = block centre, optional `this_entity` = the player with luck = `player.getLuck()` (no luck without a player); set `chest`; then `LootTable.fill(container, params, seed)` (5.4).

### 11.7 Fishing

`FishingHook.retrieve`: when a bite is on (nibble > 0): params `origin` = hook position, `tool` = the rod stack, `this_entity` = the hook, **luck = (float) hook luck + player luck** (`hook.luck` is the Luck of the Sea level of the rod, 17 §3.11); set `fishing`; table `gameplay/fishing`; each produced stack becomes an item entity at the hook's position with a velocity toward the player (17 §3.11). The shipped table is one pool with three `loot_table` entries: `fishing/junk` weight 10 quality -2, `fishing/treasure` weight 5 quality 2 (condition: the hook `in_open_water`), `fishing/fish` weight 85 quality -1.

### 11.8 Archaeology

`BrushableBlockEntity.unpackLootTable`: params `origin` = block centre, luck = `entity.getLuck()`, `this_entity` = the brusher, `tool` = the brush, set `archaeology`, seed = the block entity's `lootTableSeed`; the `generate_loot` trigger fires for a server player. The result is expected to be at most one stack: with 0 stacks the item is empty, with 1 that stack, with more than one the first (and a warning "Expected max 1 loot from loot table"). The brushing counters are in the brushing rules (not covered here).

### 11.9 Vault, trial spawner

Vault: params `origin`, `this_entity` = the player, `tool` = the key item, luck = player luck, set `vault`; rolled with `getRandomItems(params)`. Trial spawner reward ejection: set `empty`, no parameters, luck 0, rolled with the empty set (`TrialSpawner.ejectReward`). Both are driven by their own block entities.

### 11.10 Piglin bartering

`PiglinAi.getBarterResponseItems`: params `this_entity` = the piglin, set `barter`, table `gameplay/piglin_bartering`; the table is rolled once per barter by the piglin AI (how many ingots per barter, and the timing, are in the piglin documents; inferred).

### 11.11 Others using the engine

Composter harvests (`harvest/*`), carving (`carve/pumpkin`), `till/rooted_dirt`, sniffer digging (`gameplay/sniffer_digging`), turtle scute (`gameplay/turtle_grow`), chicken egg (`gameplay/chicken_lay`), panda sneeze (`gameplay/panda_sneeze`), armadillo scutes (`gameplay/armadillo_shed`, `brush/armadillo`), charged creeper heads (`charged_creeper/*`) and `equipment/*` (spawn equipment) use the same engine with the sets named in 3.2; their table keys are in `BuiltInLootTables` (121 string constants in `BuiltInLootTables`). Only the table keys and the parameter sets are fixed here; the per-caller parameter details and luck of the sniffer, turtle, armadillo, chicken, panda and charged-creeper callers were not read (Open question 14).

---

## 12. Worked examples

All random draws use the table's context random (section 4); results below are the distributions, from the formulas of this document.

**E1. Stone without silk touch.** `blocks/stone`: one pool, one entry `alternatives` with children (a) `item stone` with condition `tool/can_silk_touch`, (b) `item cobblestone` with condition `survives_explosion`. Mined by hand or pickaxe, no explosion: the pool runs once (`rolls = 1`, `bonus_rolls` 0, luck irrelevant). Expansion: child (a) fails its condition (`match_tool`: the tool has no silk touch), child (b): `survives_explosion` with no `explosion_radius` is true; one leaf, weight 1. The list has one leaf: no random draw. Result: one cobblestone.

**E2. Diamond ore with Fortune III.** Entry `alternatives`: (a) `diamond_ore` if silk touch, (b) `diamond` with functions `apply_bonus` (`fortune`, `ore_drops`) then `explosion_decay`. With Fortune III (L = 3): `m = max(0, nextInt(5) - 1)`; draws 0, 1, 2, 3, 4 give m = 0, 0, 1, 2, 3 and counts `1 x (m + 1)` = 1, 1, 2, 3, 4, so the distribution is 1 with p 0.4, then 2, 3, 4 with p 0.2 each (mean 2.2). With Fortune II (L = 2): `nextInt(4)` gives m = 0, 0, 1, 2, counts 1 (0.5), 2 (0.25), 3 (0.25) (mean 1.75). Fortune 0: count 1 and **no draw** is made (the formula tests `L > 0` first). Without an `explosion_radius`, `explosion_decay` does nothing.

**E3. Explosion decay.** A block hit by `DESTROY_WITH_DECAY` with `R = 4.0` and a drop stack of 3 items: `p = 0.25`; three `nextFloat()` draws, each `<= 0.25` keeps one item: the final count is Binomial(3, 0.25) (mean 0.75), possibly 0 (an empty stack, which `popResource` skips). The leaf-level `survives_explosion` condition (stone) uses the same `p` once.

**E4. Oak leaves, fortune 0 versus fortune 3.** Pool 1 (no condition, `rolls` 1): `alternatives` [(a) leaves with `any_of(can_shear, can_silk_touch)`, (b) sapling with `all_of(survives_explosion, table_bonus fortune [0.05, 0.0625, 0.083333336, 0.1])`]. No tool, no explosion: (a) fails; (b): `survives_explosion` true (no draw), `table_bonus`: tool present (empty stack, level 0), `p = chances[0] = 0.05`, one `nextFloat()` draw, sapling iff `< 0.05`. With Fortune III: `p = chances[3] = 0.1`; Fortune V: `chances[min(5, 3)] = 0.1`. Pools 2 and 3 only run when the tool is neither shears nor silk touch (`inverted any_of`); stick: `table_bonus [0.02, 0.022222223, 0.025, 0.033333335, 0.1]`, count `set_count uniform(1, 2)`.

**E5. Zombie with Looting II.** Pool 1: `rotten_flesh`, `set_count uniform(0, 2)` (draw `nextInt(3)`), then `enchanted_count_increase` looting with `count = uniform(0.0, 1.0)`: `L = 2`; the provider draws `Mth.nextFloat(r, 0, 1) = r.nextFloat()` once; grow by `Math.round(2 × f)`: 0 when `f < 0.25`, 1 when `0.25 <= f < 0.75`, 2 when `f >= 0.75`. Final count 0 to 4. Pool 3 (iron ingot, carrot, potato) requires `killed_by_player` and a `random_chance_with_enchanted_bonus` of `0.025` unenchanted, `0.035 + 0.01 × (L - 1)` = 0.045 with Looting II; when the pool passes, its three entries (weight 1 each) are chosen by `nextInt(3)`; the potato entry has a `furnace_smelt` modifier gated by an `any_of`: (a) `entity_properties` target `this` with `flags.is_on_fire = true`, or (b) `entity_properties` target `direct_attacker` with `equipment.mainhand` whose item predicate has `predicates.minecraft:enchantments = [{enchantments: "#minecraft:smelts_loot"}]`, i.e. the **direct attacker's main-hand stack** (a projectile or other direct attacker has no main hand and fails) has an enchantment in tag `smelts_loot`. The full zombie table has four pools: (1) rotten flesh as above; (2) `red_mushroom`, `set_count uniform(0,1)` then looting, gated by `entity_properties` target `this` with `vehicle` = entity type `zombie_horse`; (3) as above; (4) `music_disc_lava_chicken`, gated by `all_of[killed_by_player, entity_properties this {flags.is_baby = true, vehicle = entity_type chicken}]`, `rolls` 1.

**E6. Fishing with luck.** `gameplay/fishing`: effective weights `max(0, floor(weight + quality × luck))`: luck 0: junk 10, treasure 5 (only when the hook is in open water), fish 85 (total 100 in open water; 95 otherwise, because the treasure leaf is then not collected). Luck 3 (Luck of the Sea III, player luck 0): junk `floor(10 - 6) = 4`, treasure `floor(5 + 6) = 11`, fish `floor(85 - 3) = 82` (total 97 in open water). A draw: `nextInt(97)`; the first leaf (junk) is chosen for 0..3, treasure for 4..14, fish for 15..96. The chosen leaf runs the sub-table (`gameplay/fishing/fish` and so on) with the same context and random.

**E7. Pool bonus rolls.** A pool with `rolls` 1 and `bonus_rolls` 1.0 under luck 2.7: `n = 1 + floor(1.0 × 2.7) = 3` draws; under luck -0.5: `n = 1 + floor(-0.5) = 0` draws (floor of a negative float is -1).

**E8. Splitting.** A leaf producing 130 `cobblestone` (max 64) through `getRandomItems`: final consumer yields 64, 64, 2.

**E9. Chest fill.** A chest of 27 slots, table produces `[arrow x20, apple x1]`: both stacks are collected; `L` after step 1 = `[apple]`, `S = [arrow]`; `27 - 1 - 1 > 0` so a split: choose index `Mth.nextInt(r, 0, 0) = 0`, `k = Mth.nextInt(r, 1, 10)`, split `k` arrows off; the remainder (20 - k, if > 1) goes back to `S` with `nextBoolean` true, else to `L`; the split-off part likewise; the loop repeats while empty slots exceed the number of stacks, so a stack of 20 arrows can become up to many smaller stacks scattered over random empty slots.

---

## 13. Validation (what an implementation must check, and test vectors)

### 13.1 Load-time validation (`Validatable`, `ValidationContext`)

At load, every table, predicate, modifier and slot source is validated with a context of its declared parameter set. Problems reported (all logged; which are fatal is Open question 5):
1. a condition, function, provider or entity target that references a parameter key that the table's parameter set neither requires nor allows ("parameters not provided");
2. a recursive reference (a table that reaches itself through `loot_table` entries, or a tag that contains itself) ("recursive element reference");
3. `alternatives` with an unconditional non-final child ("Unreachable entry!") and composite entries with no children ("Empty children list");
4. number providers with invalid bounds, and holder references that do not resolve.
The referenced parameters of each function and condition are known from its code: `enchanted_count_increase`: `attacking_entity`; `apply_bonus` and `table_bonus` and `match_tool`: `tool`; `random_chance_with_enchanted_bonus`: `attacking_entity`; `survives_explosion`, `explosion_decay`: `explosion_radius`; `killed_by_player`: `last_damage_player`; `entity_properties`: `origin` and the target key; `damage_source_properties`: `origin` and `damage_source`; `location_check`: `origin`; `copy_state`: `block_state`; `match_block`: `block_state` and, with block-entity parts, `block_entity`; `entity_scores` and `set_name` / `fill_player_head`: the target key; `enchantment_active_check`: `enchantment_active`; positional `environment_attribute_check`: `origin`.

### 13.2 Test vectors

| # | Input | Expected |
|---|---|---|
| T1 | `rolls` 2, pool with a single `item` entry weight 3, luck any | two draws, each returns the item, no `nextInt` consumed (one leaf) |
| T2 | entries A(weight 1), B(weight 3), `r.nextInt(4)` = 0 / 1 / 2 / 3 | A, B, B, B |
| T3 | `quality` -1, `weight` 10, luck 25 | `floor(10 - 25) = -15`, clamped to 0: the leaf is dropped; if all leaves are dropped the draw yields nothing |
| T4 | `set_count` count 3 `add` true on a stack of 2 | 5 |
| T5 | `limit_count` min 2 max 5 on counts 1, 3, 9 | 2, 3, 5 |
| T6 | `ore_drops`, L = 0, count 1, `nextInt` not called | 1 |
| T7 | `ore_drops`, L = 1, `nextInt(3)` = 0 / 1 / 2 | m = max(0, -1) = 0, 0, 1: counts 1, 1, 2 |
| T8 | `uniform_bonus_count` multiplier 2, L = 3, count 1, `nextInt(7)` = 6 | 7 |
| T9 | `binomial_with_bonus_count` extra 2, probability 0.5, L = 1: three floats 0.1, 0.9, 0.4 | successes 2: count + 2 |
| T10 | `survives_explosion`, R = 2.0, `nextFloat` = 0.5 | true (0.5 <= 0.5); with 0.51: false |
| T11 | `random_chance` 0.3, `nextFloat` = 0.3 | false (strict `<`) |
| T12 | `table_bonus` chances [0.1, 0.2], L = 5 | uses 0.2 |
| T13 | `set_damage` damage 0.25, `add` false on a 100-durability stack | new damage `floor((1 - 0.25) × 100) = 75` |
| T14 | `enchanted_count_increase` L = 3, provider returns 0.5 | `round(1.5) = 2` more items |
| T15 | int provider `div` 7 / 2; `floor_div` -7 / 2; `mod` -7 % 2; `floor_mod` -7 % 2 | 3; -4; -1; 1 |
| T16 | int provider `div` by 0, via `getInt` | 0 (the exception is swallowed) |
| T17 | float provider `div` 1.0 / 0.0 via `getFloat` | 0.0 (not finite) |
| T18 | `entity_properties` with a missing target entity and a present predicate | false; absent predicate: true |
| T19 | NBT predicate expected `{a:1b}` against `{a:1b,b:2b}` | true; expected `{a:1b,c:3b}` against `{a:1b,b:2b}`: false (key count equal, key missing) |
| T20 | state predicate `{"half":"upper"}` on a block without a `half` property | false |
| T21 | stack count 70 (max 64) | 64, 6 |
| T22 | `alternatives` [A with failing condition, B without], B ran | only B's leaf; A's leaf absent |
| T23 | `sequence` [A passes, B fails, C passes] | leaves of A only (B returned false and stopped the sequence) |
| T24 | explosion merge: three stacks of 10 `dirt` from three blocks | first entry 16, second entry 14 (merge up to 16 into the first, the rest starts a second at the second block's position) |

---

## Open questions

0. **Finding resolved against the artifact (`DistanceToPlayerPredicate`).** The reviewer listed it as an unmentioned class outside the 24 keys. It is the codec registered for the `distance` key (`EntitySubPredicates` pushes `DistanceToPlayerPredicate.CODEC` right after the `distance` string), so it is already row `distance` of 10.8 (now named there). `EntitySlotsPredicate` is the `slots` key, `EntityEquipmentPredicate` the `equipment` key, `FishingHookPredicate` `type_specific/fishing_hook`, `PlayerPredicate$StatMatcher` and `$Advancement*Predicate` are the player fields now in 10.8.1. The `looking_at` search-box inflation value and the origin passed to its nested predicate were not recorded.

1. **Slot ranges.** The slot source types are read (6.2). Not read: `SlotRange.slots()` and the table of named slot ranges, and the exact fallback result of `slot_range` when the context value is not a slot provider; both belong to the container and entity slot rules.
2. **`set_contents` internals.** Only the call to the container manipulator was read, not how entries are rolled into the stream (a table-style roll per entry versus a single expansion); the `ContainerComponentManipulators` message "No items in component" and the per-function `ListOperation` size limits were not read.
3. **Rarely used component predicates and functions** (10.2 rows from `firework_explosion` down, `attribute_modifiers`, `trim`, `jukebox_playable`; 7.3 book, firework, banner, custom-model-data and toggle-tooltips functions) were read to field-name level only.
4. **Block table key.** The block-to-table key `blocks/<id path>` is confirmed by the data (`random_sequence` and file names) but the code path (`BlockBehaviour$Properties.effectiveDrops`, `DependantName`) was not traced, and `overrideLootTable` / `noLootTable` usages per block are in 24.
5. **Which validation problems are fatal** (`ProblemReporter$Collector.hasFatalProblems`) is not read (see 23 open question 14). The `LootContextUser`/`Validatable` referenced-parameter lists of 13.1 were read for the functions and conditions named there, not for every type.
6. **`time_check` clock.** Reading of the long, `lrem` and the int narrowing is done (8); the world clocks themselves (`ServerClockManager`, 26.x) and time-of-day gameplay are in 33.
7. **`Mth.sin` is a table lookup** (9.3): the implementation must reproduce `SIN[]` exactly as listed; only `sin`/`cos` float providers use it in this engine.
8. **Player luck.** `Player.getLuck()` (the `luck` attribute) is used as read; its attribute modifiers (Luck, Bad Luck, Luck of the Sea, effects) are in the effect and attribute documents.
9. **Part order of the entity predicate** (`PREDICATE_TYPE_ORDER`) affects only evaluation order; the comparator was not read.
10. **`PlayerPredicate` parts**: matching logic now read (10.8.1) except the `looking_at` details named in question 0, the stat type registry contents, and how advancement progress is produced (advancement-system behaviour, not covered).
11. **The `generic` parameter set.** `generic` declares all 16 keys as required (read from the builder); that none of the shipped call sites uses it (tables in the data declare a specific `type`) was observed from the type counts in section 1 for the directories counted, not verified for all 1447 files.
11b. (Closed: the `chests/` count of 63 versus 58 is explained in section 1.)
12. **Entity count note.** Closed: 93 top-level + 16 in `entities/sheep/` = 109; 18 §7.6's 94 is the top-level count including the directory entry (section 1). 18 should be corrected by its owner.
13. **Unchanged earlier searches, now closed:** `set_enchantments` clamp (255, 7.2), `set_name` default target (7.3), sequence seeding (4.5), `all_of`/`any_of` short-circuit (8), modifier list form (1), `time_check` narrowing (8).
14. **Callers of 11.11** (sniffer, turtle, armadillo, chicken, panda, charged creeper): parameter sets and luck were not read per caller.
