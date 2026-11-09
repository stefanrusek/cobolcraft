# 45. Entity NBT, part 2: LivingEntity, Mob, Animal and the shared Brain model

| Item | Value |
|---|---|
| Covers | Round RS27 part 2: the keys that the shared intermediate entity classes write and read (`LivingEntity`, `Mob`, `AgeableMob`, `Animal`, `TamableAnimal`, `ShoulderRidingEntity`, `PatrollingMonster`, and the `NeutralMob` helper), the value forms they use (attribute list, mob effect instance with the hidden-effect chain, equipment map and slot names, drop chances, leash, locator-bar icon, positions), the meaning and lifecycle of the saved numbers (hurt time, death time, age, love, anger), and the shared Brain serialisation model (memory map, expiry TTL, which memory types are serialisable, what is not saved) that parts 4 to 7 refer to for specific memories |
| Does not cover | The `Entity` base keys, the read and write rules, the ItemStack compound and the leash and owner helper forms (part 1, [45-entity-nbt-1-shared-model-and-entity-base.md](45-entity-nbt-1-shared-model-and-entity-base.md), cited as "45-1 §N"); Player and player files (part 3); keys of concrete types (parts 4 to 9); `AbstractVillager` and `InventoryCarrier` (part 6); the value tables of data (effects, attributes, loot tables, tags are registries or data; ids are in [46](46-registry-ids.md)); sensors, behaviours and activities as logic ([18](18-mob-framework.md) §4.5) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `LivingEntity`, `Mob`, `PathfinderMob`, `AgeableMob`, `Animal`, `TamableAnimal`, `ShoulderRidingEntity`, `PatrollingMonster`, `NeutralMob`, `OwnableEntity`, `EquipmentSlot`, `EntityEquipment`, `DropChances`, `Leashable` and `Leashable$LeashData`, `EntityReference`, `ItemStack`, `MobEffectInstance` and `MobEffectInstance$Details`, `AttributeMap`, `AttributeInstance` and its `Packed` record, `AttributeModifier`, `Brain`, `Brain$Packed`, `Brain$1`, `MemoryMap`, `MemorySlot`, `ExpirableValue`, `MemoryModuleType`, `GlobalPos`, `BlockPos`, `Vec3`, `Unit`, `Waypoint$Icon`, `UUIDUtil`, `ExtraCodecs` |
| Evidence rule | Every key, type, default, constant and ordering below was read in this round. "(inferred)" marks a deduction from the shape of the code. "(recalled, not verified)" marks a statement not read. Each such mark is repeated in section 11 (Open questions). Where this artifact differs from older formats the text says so. |

Conventions: types are written `Byte`, `Short`, `Int`, `Long`, `Float`, `Double`, `String`, `List<T>`, `Compound`, `Int Array(n)` as in 45-1. A Boolean is stored as a Byte, 1 or 0 (45-1 §1.2). "Written when" says under which condition a key is present in a saved compound; every key not listed is never written by these classes. "Tick" is 50 ms. Examples use the textual NBT notation (SNBT) only as a way to show a compound; it is not a file format of the game.

The artifact's classes save through two interfaces (`ValueOutput`, `ValueInput`) whose rules (absent key, default on decode error, partial values, unknown keys ignored) are in 45-1 §1. This document states only keys and forms.

---

## 1. Layers and write order

An entity compound is produced by the Entity base first (part 1: `id`, `Pos`, `Motion`, `Rotation`, ... ), then by each class of the chain adding its own keys, the most derived last. For the shared classes the chain is:

| Layer | Keys it adds | Section |
|---|---|---|
| `LivingEntity` | health, timers, attributes, effects, brain, last-hurt references, equipment, locator icon | 2 |
| `PathfinderMob` | none (it has no save code of its own) | |
| `Mob` | pickup and persistence flags, drop chances, leash, home, handedness, death loot table, no-AI | 3 |
| `AgeableMob` | age keys | 4.1 |
| `Animal` | love keys | 4.2 |
| `TamableAnimal` | `Owner`, `Sitting` | 5.1 |
| `ShoulderRidingEntity` | none | 5.2 |
| `Monster` then `PatrollingMonster` | patrol keys (`Monster` itself adds none) | 6 |
| `NeutralMob` helper | `anger_end_time`, `angry_at`, called from the concrete type's own save code | 7 |

Which concrete types extend which of these classes is in the sibling parts (45-1 §12 is the owner index of type keys). On load each class reads its own keys after its parent has read its keys (parent first), so a derived class sees the parent's state.

The `VariantHolder` pattern (key `variant`, an identifier of a registry entry, read through `VariantUtils.readVariant`) is a helper of the concrete types, not of these classes; its form is in 45-1 §10.5, and `OwnableEntity` and `Leashable` are covered in 45-1 §10 and in sections 3 and 5.1 here.

Keys that older formats carried and that these classes do not read or write: `HurtByTimestamp`, `ArmorItems`, `HandItems`, `ArmorDropChances`, `HandDropChances`, `ActiveEffects`, `Attributes` (capitalised), `SleepingX`, `SleepingY`, `SleepingZ`, `Leash` (capitalised), `Leashed`, `Target` (any form of the attack target) and `Invulnerable` for the damage window. They may exist in old save files and are upgraded by the DataFixer (code, not read in this round; Open question 14). Nothing here reads them.

---

## 2. LivingEntity keys

### 2.1 Key table

| Key | NBT type | Default on load | Written when | Meaning and notes |
|---|---|---|---|---|
| `Health` | Float | the entity's maximum health at the moment of loading | always | Current health. The setter clamps to the range 0 to the current maximum health (the `max_health` attribute value at that moment). |
| `HurtTime` | Short | 0 | always | Ticks left of the red hurt flash. Set to 10 (the hurt duration) when damage is taken; the value counts down by 1 each tick while above 0. Saved and reloaded as is. |
| `DeathTime` | Short | 0 | always | Ticks spent dying. Starts counting when health reaches 0; when it reaches 20 the entity is removed (reason "killed") and the entity event 60 is broadcast (its client handler calls `makePoofParticles`, read: 20 `POOF` particles; for each, three `nextGaussian` values times 0.02 give the velocity, and the position is `getRandomX(1.0)`, `getRandomY()`, `getRandomZ(1.0)` each minus 10 times the matching velocity component). |
| `AbsorptionAmount` | Float | 0.0 | always | Extra health pool that damage uses before `Health`. Read first, before attributes. |
| `current_impulse_context_reset_grace_time` | Int | 0 | always | Counter belonging to the wind-charge and mace "impulse" context. Its tick behaviour was not read (Open question 6). |
| `current_explosion_impact_pos` | `List<Double>` of 3 | none | when set | Position of the last impulse impact (`Vec3`, 45-1 §3). |
| `attributes` | `List<Compound>` | no list: attribute bases and modifiers stay at the type's defaults | always (the list may be empty) | Section 2.2. Read only on the server side. |
| `active_effects` | `List<Compound>` | empty list (no effects) | only when there is at least one effect | Section 2.3. Order of the written list is the iteration order of the effect map (not significant; Open question 7). On load the effect map is cleared (read: `Map.clear` is called before the decoded elements are put) and then filled from the saved list, so the saved list REPLACES whatever effects the freshly built entity had, unlike `attributes`, which merge (section 2.2 rule 3). |
| `FallFlying` | Byte | 0 | always | Whether the entity is gliding. Loading sets shared flag bit 7 of the entity flags accordingly (shared flag index 7 of the entity-flags metadata byte, see 18 §1.4). |
| `sleeping_pos` | `Int Array(3)` | none | only while sleeping | Block position of the bed. On load: the position is set, the pose is set to sleeping, and, when this is not the entity's first tick, the entity is moved to the bed (`setPosToBed`); if that fails it wakes up at once. When the key is absent the sleeping position is cleared. |
| `Brain` | `Compound {memories: Compound}` | a fresh brain with no memories | always, even when no memory is stored (`{memories:{}}`) | Section 8. |
| `last_hurt_by_player` | `Int Array(4)` (UUID) | none | only when set | Player (or tamed wolf's owner) credited for the last damage. Used for loot (player kill flag) and experience. |
| `last_hurt_by_player_memory_time` | Int | 0 | only together with `last_hurt_by_player` | Ticks the credit remains valid. Counts down 1 per tick; when it is 0 or less the reference is cleared. Set to 100 when a player (or a tamed wolf's owner) damages the entity. |
| `last_hurt_by_mob` | `Int Array(4)` (UUID) | none | only when set | The last mob that damaged this entity (the revenge target). |
| `ticks_since_last_hurt_by_mob` | Int | 0 | only together with `last_hurt_by_mob` | Entity age (`tickCount`) minus the tick when it was hurt. On load the timestamp is rebuilt as the new age (0 on a fresh load) minus this value. The reference is cleared when the target is dead or when the entity age minus the timestamp exceeds 100. |
| `equipment` | `Compound` (slot name to ItemStack) | all slots empty | only when at least one slot is non-empty | Section 2.4. |
| `locator_bar_icon` | `Compound {style: String, color?: ...}` | the default icon (style `minecraft:default`, no colour) | only when the icon differs from the default (style not default, or a colour is present) | Section 2.5. |

The writer emits the keys in the order of the table (the order of the compound's own iteration on disk is not significant). The loader reads in this order: `AbsorptionAmount`, `attributes` (server only), `active_effects`, `Health`, `HurtTime`, `DeathTime`, `FallFlying`, `sleeping_pos`, `Brain`, `last_hurt_by_player`, `last_hurt_by_player_memory_time`, `last_hurt_by_mob`, `ticks_since_last_hurt_by_mob`, `equipment`, `locator_bar_icon`, `current_impulse_context_reset_grace_time`, `current_explosion_impact_pos`. Because `attributes` is read before `Health`, a saved permanent modifier on maximum health is in force when `Health` is clamped (Open question 8 covers effect modifiers).

The damage window ("hurt cooldown", 20 ticks, `damageCooldownTime`) and the last damage amount are NOT saved: they restart at 0 on load. The intended damage numbers are in [17](17-tools-weapons-and-combat.md) and [18](18-mob-framework.md) §7.

### 2.2 The `attributes` list

Each element is a Compound (the `Packed` record of an attribute instance):

| Key | NBT type | Default on load | Written when | Notes |
|---|---|---|---|---|
| `id` | String | none: REQUIRED | always | Attribute registry key (`minecraft:max_health` form; the registry and its ids are in [46](46-registry-ids.md) §4). An unknown name is a decode error; whether it loses only that element or the whole list is not shown (Open question 2b). |
| `base` | Double | 0.0 | always (written even when it equals the default) | Base value of the attribute for this entity. |
| `modifiers` | `List<Compound>` | empty | only when the list is not empty (inferred: an optional field with an empty default is omitted when equal to the default) | The PERMANENT modifiers only. Transient modifiers (those added by effects, equipment and sprinting) are never written. |

A modifier compound has exactly three required keys:

| Key | NBT type | Notes |
|---|---|---|
| `id` | String (identifier) | Modifier id, unique within its attribute instance. A second modifier with the same id replaces the first. |
| `amount` | Double | |
| `operation` | String | One of `add_value`, `add_multiplied_base`, `add_multiplied_total` (the three constants, in this declaration order; their evaluation order is in [18](18-mob-framework.md) §1.3). |

Load rules (`AttributeMap.apply`):

1. The whole list is applied only when the entity is on the server side.
2. For each element, the entity's attribute instance for `id` is obtained. When the entity's type does not have that attribute (its supplier lacks it) the instance does not exist and the element is ignored.
3. For an existing instance (`AttributeInstance.apply`, read): `base` replaces the base value; every listed modifier is put into the instance's id map, its per-operation map and its permanent map (a later duplicate id in the list wins); then the instance is marked dirty so the client is sent an update. Nothing is cleared first: the listed modifiers are MERGED into the set, so modifiers with other ids that the freshly constructed entity already has are kept.
4. Instances not mentioned keep the type defaults.

Save rule: the list contains one element for every attribute instance that exists in the map when saving. Instances in the map are created lazily on first access (reading a value, adding a modifier). Therefore which attributes appear in a saved file depends on which ones the entity touched; a reader must accept any subset. An implementation may write every attribute the type has (it loads identically; it is not byte-identical to the vanilla file; Open question 9).

### 2.3 The `active_effects` list: the MobEffectInstance codec

Each element is a Compound (a record of the effect id merged with the effect's details):

| Key | NBT type | Default on load | Written when | Notes |
|---|---|---|---|---|
| `id` | String | none: REQUIRED | always | Mob effect registry key (40 entries, [46](46-registry-ids.md) §4.1). |
| `amplifier` | Byte | 0 | declared with default 0 (plain optional-field form); whether a default-valued field is written is Open question 19. As a byte, values 128 to 255 appear as negative bytes in the tag | Level minus 1. The codec is the "unsigned byte" codec and the constructor also clamps to 0 to 255. Decoding treats the byte as unsigned 0 to 255 (inferred from the codec's name, its range check and the constant `MAX_AMPLIFIER` = 255). |
| `duration` | Int | 0 | declared with default 0; written or not: Open question 19 | Remaining ticks, or -1 for an infinite effect (`INFINITE_DURATION`). |
| `ambient` | Byte (boolean) | false | declared with default false; written or not: Open question 19 | Beacon-style effect: reduced particles. |
| `show_particles` | Byte (boolean) | true | declared with default true; written or not: Open question 19 | The jar declares these four with the plain optional-field form with a default, unlike the attribute `base`, which uses the always-present form. Implementers accept both present and absent fields on load. |
| `show_icon` | Byte (boolean) | the value of `show_particles` | always (written explicitly) | HUD icon. |
| `hidden_effect` | Compound (same keys as this table EXCEPT `id`) | none | only when the instance has a hidden effect | The weaker, longer effect that takes over when this one runs out. It is the same record again, nested: it carries `amplifier`, `duration`, `ambient`, `show_particles`, `show_icon` and possibly its own `hidden_effect`. The effect id is not repeated: a hidden effect always has the same effect as its parent. The chain is recursive without a fixed limit. |

On load each element becomes an instance and is put in the entity's effect map keyed by the effect, so two elements with the same `id` collapse to the last one. Loading marks the effects as dirty (the client is sent them), it does not run the effect's start hook (Open question 8).

**Update rule** (`MobEffectInstance.update`): called when an instance of the same effect is applied to an entity that already has it. Let E be the existing instance, N the new one. "A is shorter than B" means: A is not infinite and (A.duration < B.duration or B is infinite).

1. If N.amplifier > E.amplifier:
   - if N is shorter than E, a copy of E (with E's current hidden effect as the copy's hidden effect) becomes E's new hidden effect;
   - then E takes N's amplifier and duration; changed.
2. Otherwise (N.amplifier <= E.amplifier), when E is shorter than N:
   - equal amplifiers: E takes N's duration; changed;
   - N weaker: if E has no hidden effect, a copy of N becomes the hidden effect; otherwise `update` is applied recursively to the hidden effect with N.
3. The flags: ambient is copied from N when changed so far, or when N is not ambient and E is ambient (so a non-ambient application clears ambient); `show_particles` and `show_icon` are copied from N when they differ. The result is "something changed", which triggers a client update.

**Tick rule** (server, `tickServer`): an instance with no remaining duration (not infinite and duration <= 0) is dead. Otherwise the effect's per-tick hook runs when its period predicate says so for (duration, amplifier) (for an infinite instance the entity's age stands in for the duration); a hook returning false removes the effect. Then `tickDownDuration`: the hidden effect (and its chain) is ticked down first, then the duration is reduced by 1 unless the instance is infinite or already 0. Then `downgradeToHiddenEffect`: when the duration is exactly 0 and a hidden effect exists, the instance takes the hidden effect's amplifier, duration, ambient, particle and icon values, and its hidden effect becomes the hidden effect's own hidden effect (the next link of the chain); the entity is told the effect changed. The instance survives while it still has remaining duration.

### 2.4 Equipment: `equipment` and the slot names

The key `equipment` holds a map from slot name to an ItemStack compound (45-1 §8). There is no list and no slot number. Empty stacks are removed before writing; when every slot is empty the key is absent. On load a missing key means "all slots empty".

The eight slot names (`EquipmentSlot`, a closed enum; the name is the string key, in this declaration order):

| Ordinal | Name | Type | Index in type | Wire id | Count limit | Notes |
|---|---|---|---|---|---|---|
| 0 | `mainhand` | hand | 0 | 0 | none | |
| 1 | `offhand` | hand | 1 | 5 | none | |
| 2 | `feet` | humanoid armor | 0 | 1 | 1 | |
| 3 | `legs` | humanoid armor | 1 | 2 | 1 | |
| 4 | `chest` | humanoid armor | 2 | 3 | 1 | |
| 5 | `head` | humanoid armor | 3 | 4 | 1 | |
| 6 | `body` | animal armor | 0 | 6 | 1 | armor of animals; the type name `ANIMAL_ARMOR` was read. Classes that reference `EquipmentSlot.BODY` (read, by scanning the entity and level packages): `AbstractHorse`, `Horse`, `ZombieHorse`, `Wolf`, `AbstractNautilus`, `ZombieNautilus`, `HappyGhast`, `SulfurCube`, `ArmorStand`, plus `Mob` and `LivingEntity` themselves |
| 7 | `saddle` | saddle | 0 | 7 | 1 | |

"Count limit" is the largest stack the slot accepts (1 for armor, body and saddle); hand slots have no slot limit (`NO_COUNT_LIMIT` = 0). "Wire id" is the id used by `BY_ID` and the stream codec of the enum. The clientbound Set Equipment packet (05b 0x68) does NOT use it: it writes the slot ORDINAL (first column, offhand = 1) as a byte, with 0x80 set as a continuation bit on every pair except the last. So the packet uses the Ordinal column, and every other user of the enum codec uses the Wire id column (offhand = 5). The four armor indices 0 to 3 run feet to head. The saved form does not check that a mob type uses a given slot: any listed slot loads. Gameplay code decides what a type does with it (Open question 11).

Decoding rules (inferred from the map codec and its shape): an unknown slot name or an invalid stack (bad item id, count outside 1 to 99) is a decode error for the map (45-1 §1.1 gives the failure rule: the `equipment` read yields nothing or a partial map and the entity starts with the part that decoded). The decoded map replaces all current equipment.

### 2.5 `locator_bar_icon`

| Key | NBT type | Notes |
|---|---|---|
| `style` | String (identifier) | Key in the waypoint style registry (`waypoint_style_asset`); the default is `minecraft:default` (the root of the family is a registry key named `waypoint_style_asset`; another constant in the same class is `bowtie`). Required. |
| `color` | Int, or `List<Float>` of 3 | Optional colour. The codec is `RGB_COLOR_CODEC`, an alternative of an Int and a 3-float vector (read). The vector components are on a 0.0 to 1.0 scale; the vector form is converted with `ARGB.colorFromFloat` with alpha 1.0 and each channel as floor(component x 255), giving an ARGB Int with alpha 0xFF, i.e. 0xFFRRGGBB (negative as a signed Int). (1.0, 0.0, 0.0) therefore becomes 0xFFFF0000 = -65536. What a plain Int input does with its alpha byte was not read (Open question 12). |

The icon is what the locator bar (13 / 12) shows for this entity. It is written only when it carries data (non-default style or a colour).

---

## 3. Mob keys

| Key | NBT type | Default on load | Written when | Meaning and notes |
|---|---|---|---|---|
| `CanPickUpLoot` | Byte (boolean) | false | always | Whether the mob picks up items it wants. |
| `PersistenceRequired` | Byte (boolean) | false | always | A mob with this flag never despawns for distance. Also set by name tags, taming and similar. |
| `drop_chances` | `Compound` (slot name to Float) | all slots at the default chance | only when the chances differ from the default for any slot | Section 3.1. |
| `leash` | `Compound {UUID: Int Array(4)}` or `Int Array(3)` | none | only when leashed | Form, load behaviour and pending restoration are in 45-1 §10.1. When the loaded compound has no `leash` and the mob currently has leash data, the leash is removed. |
| `home_radius` | Int | -1 | only when a home exists (`hasHome`: radius != -1) | The radius in blocks the mob stays within. -1 means "no home". |
| `home_pos` | `Int Array(3)` | `[0,0,0]` | only together with `home_radius` | Centre of the home area. Read only when `home_radius` >= 0. |
| `LeftHanded` | Byte (boolean) | false | always | Handedness. Stored in the mob-flags metadata byte as bit 2 (value 2). |
| `DeathLootTable` | String (loot table key) | none: use the entity type's own table | only when an override is set | Overrides the loot table used on death. |
| `DeathLootTableSeed` | Long | 0 | only when not 0 | Seed handed to the loot context for the death table (the loot engine is [18](18-mob-framework.md) §7.6). |
| `NoAI` | Byte (boolean) | false | only when true | Disabled AI. Stored in the mob-flags byte as bit 0 (value 1). |

The mob-flags metadata byte (`DATA_MOB_FLAGS_ID`) has three bits: 1 no AI, 2 left-handed, 4 aggressive. The aggressive bit is NOT saved: it is recomputed at runtime (so a saved mob restarts non-aggressive until its goals or brain set it). The attack target is not saved either (Mob has no `Target` key; revenge and anger are saved only through `last_hurt_by_mob` (2.1), the Brain memories (8) and the `NeutralMob` keys (7)).

The writer emits `CanPickUpLoot`, `PersistenceRequired`, `drop_chances`, `leash`, `home_radius` and `home_pos`, `LeftHanded`, `DeathLootTable`, `DeathLootTableSeed`, `NoAI` in this order after the `LivingEntity` keys. The loader reads `CanPickUpLoot`, `PersistenceRequired`, `drop_chances`, `leash`, `home_radius`, `home_pos`, `LeftHanded`, `DeathLootTable`, `DeathLootTableSeed`, `NoAI`.

### 3.1 `drop_chances`

The form is a map from slot name (section 2.4) to a Float, with these properties:

| Item | Value |
|---|---|
| Default chance per slot | 0.085 (`DEFAULT_EQUIPMENT_DROP_CHANCE`) |
| Value range on load | 0.0 up to the largest finite Float (a negative value is a decode error) |
| Encoding | slots whose chance equals 0.085 are omitted; the key is omitted altogether when every slot is at the default |
| Decoding | listed slots take their value; unlisted slots take 0.085 |
| "Preserved" | a slot whose chance is greater than 1.0 (`PRESERVE_ITEM_DROP_CHANCE_THRESHOLD`) is preserved: its item drops whatever the kill, undamaged by the random wear step. The helper that sets a guaranteed drop writes 2.0 (`PRESERVE_ITEM_DROP_CHANCE`). |

Use on death (`Mob.dropCustomDeathLoot`, read): for every slot in the order of `EquipmentSlot.VALUES` (the `playerKill` parameter is the boolean passed to the method): a chance of exactly 0 skips the slot; the "preserved" test is taken on the ORIGINAL chance, before the enchantment step; then `EnchantmentHelper.processEquipmentDropChance` is applied to the chance whenever the damage source's entity is a living entity (on a server level), for every slot including preserved ones, and its result replaces the chance used in the random test (its body was not read, Open question 13); the stack is skipped when empty or when it carries the "prevent equipment drop" enchantment effect; when `playerKill` is false the slot is skipped unless it is preserved (so with a false flag only preserved slots, chance greater than 1.0, can drop); then a uniform float below the chance drops the stack; a non-preserved damageable item (checked after the chance test passed) gets random wear before it is dropped: new damage value = maximum damage minus `nextInt(1 + nextInt(max(maximum damage - 3, 1)))`, where the inner random value is added to 1 and that sum is the bound of the outer draw (read). Order of the random calls for one slot: `nextFloat` for the chance test, then the inner `nextInt`, then the outer `nextInt`. A preserved item skips the wear step. After the stack is spawned as an item entity, that equipment slot is set to EMPTY: the item leaves the mob, which matters for the saved `equipment` after a partial drop (slots that did not pass the chance test keep their items).

`Mob.dropPreservedEquipment(level, predicate)` (read) is a separate path with no random draw: for each slot in `EquipmentSlot.VALUES` order, an empty slot is skipped; a stack for which the predicate fails is not dropped and its slot is added to the returned set; otherwise, when the slot is preserved (chance above 1.0), the slot is set to empty first and the stack is spawned as an item. The one-argument overload uses a predicate that is always true and discards the set. Callers found in the jar: `CopperGolem`, `ZombieVillager`, the trial spawner state data (what triggers them is outside this part, Open question 20).

Worked example: a skeleton killed by a player with looting 0 and default chances drops each equipped slot with probability 0.085. A pillager captain's banner slot at 2.0 always drops.

---

## 4. AgeableMob and Animal

### 4.1 `AgeableMob`

The three keys are written and read ONLY when the type can be a baby (`canBeABaby()`; a type that never has babies saves none of them and ignores them on load).

| Key | NBT type | Default on load | Written when | Meaning |
|---|---|---|---|---|
| `Age` | Int | 0 | when `canBeABaby` | Negative: a baby, counting up to 0. Zero: an adult ready to breed. Positive: an adult on breeding cooldown, counting down to 0. |
| `ForcedAge` | Int | 0 | when `canBeABaby` | Accumulated growth added by feeding (the "forced age" bookkeeping, see below). |
| `AgeLocked` | Byte (boolean) | false | when `canBeABaby` | A locked baby does not grow up. Item flow (read): in `mobInteract` the held item must be the golden dandelion, the mob must be a baby, its `ageLockParticleTimer` must be 0 and the type must not be in the entity-type tag `cannot_be_age_locked` (`EntityTypeTags.CANNOT_BE_AGE_LOCKED`; the tag members are in the tag data, not read here). If so the static `setAgeLocked` helper runs these steps in order: (1) it calls the instance consumer `setAgeLockedData`, which flips the lock to the opposite of its current value, then ALWAYS sets the age to the type's baby start age (default -24000, Sniffer -48000), in both directions with no branch between the two steps (so unlocking also resets a baby to its baby start age), then sets `ageLockParticleTimer` to 40; (2) it consumes one item; (3) it reads the NEW lock state; (4) it calls `setPersistenceRequired` when that new state is on; (5) it plays the golden-dandelion use sound (lock on) or unuse sound (lock off) in the players sound category. The timer is therefore a 40-tick cooldown between uses; while it is above 0 on the server tick the `makeAgeLockedParticle` helper emits particles and returns the new timer value. |

Constants: a newborn baby starts at the type's baby start age, the overridable method `getBabyStartAge`: -24000 in `AgeableMob` (24000 ticks = 20 minutes to grow up) and -48000 in `Sniffer` (read: scanning the entity package found only these two definitions; any override in a class outside it is not excluded). `setBaby(true)`, the baby-chance branch of spawn finalisation and `setAgeLockedData` all use this method; the per-type parts own any further override. A Sniffer therefore takes twice as long to grow up, and a bred baby Sniffer is spawned at -48000. `AGE_LOCK_COOLDOWN_TICKS` is 40 (the value `setAgeLocked` stores in `ageLockParticleTimer`, a transient counter that is not saved); the forced-age particle runs for 40 ticks (`FORCED_AGE_PARTICLE_TICKS`).

Behaviour of the saved numbers:

1. Setting the age stores it and, when the sign crosses zero (a baby becomes non-negative or an adult becomes negative), updates the shared "is baby" metadata flag and calls the age boundary hook. On load `setAge(Age)` runs, so a saved negative age makes the mob a baby; a saved 0 or positive makes it an adult. On the client the age is read as -1 for a baby and 1 for an adult from the flag.
2. Each server tick on a living mob (`aiStep`), in this order: if `forcedAgeTimer` > 0, a happy-villager particle is sent every 4 ticks and the timer drops by 1; then, when alive: if the mob is a baby and not age-locked the age goes up by 1; otherwise a positive age goes down by 1. (Breeding cooldown therefore falls 1 per tick: 6000 ticks, 5 minutes.) The age lock keeps a locked baby at its age.
3. `ageUp(seconds, forced)`: (a) new age = old age + seconds x 20, capped at 0, and it is stored with `setAge`; (b) ONLY when `forced` is true: the difference (new - old) is added to `ForcedAge`, and `forcedAgeTimer` is set to 40 if it was 0; (c) for EVERY call, forced or not: if the age is now 0, it is set to the accumulated `ForcedAge`. So a growth step that finishes growing up can leave a positive age (a cooldown) when earlier forced steps accumulated `ForcedAge`.
4. A mob that stops being a baby while riding a boat that is too small dismounts (age boundary hook).

### 4.2 `Animal`

| Key | NBT type | Default on load | Written when | Meaning |
|---|---|---|---|---|
| `InLove` | Int | 0 | always | Ticks left in love mode. 0: not in love. Fed breeding food sets it to 600 (30 seconds), broadcasting the entity event 18 (client handler `Animal.handleEntityEvent`: 7 heart particles, each with a Gaussian 0.02 velocity jitter; read); it counts down 1 per tick in `aiStep` on both sides, and the heart particle on every tick where the new value is a multiple of 10 is client-side only (it uses `Level.addParticle`). |
| `LoveCause` | `Int Array(4)` (UUID) | none | only when set | The player who fed the animal (set only when the feeder is a server player). Used for the breeding advancement and experience credit. |

Rules read in the artifact:

1. `isInLove` is `InLove > 0`. Whenever the animal's age is not 0 (a baby, or an adult on cooldown) `InLove` is forced back to 0 in `aiStep` (both sides) and in `customServerAiStep` (server), so a saved `InLove` on a mob with a non-zero `Age` is lost at the first tick. The countdown by 1 also runs in `aiStep` on both sides.
5. Damage cancels love: `Animal.actuallyHurt` calls `resetLove` (InLove becomes 0) before the `AgeableMob` damage code, so any damage that reaches `actuallyHurt` clears `InLove` (`LoveCause` stays, rule 4).
2. Two animals can mate when they are different entities, have exactly the same class, and both are in love.
3. After a successful breeding (`finalizeSpawnChildFromBreeding`): the credit for the advancement goes to the `LoveCause` of either parent; both parents get age 6000 (5 minutes cooldown) and `resetLove` (InLove 0); the entity event 18 is broadcast; when the `mob_drops` game rule is true an experience orb of 1 to 7 points is spawned (1 + a random integer below 7). The baby is spawned with the baby's baby start age (-24000, Sniffer -48000; section 4.1) at the first parent's position with yaw and pitch 0.
4. `LoveCause` is not cleared by `resetLove` (only `InLove` is zeroed; this was read from the method bodies).

Worked example (breeding): two cows, both Age 0, InLove 0. The player feeds both: each gets `InLove: 600`, `LoveCause` the player. They meet, breed: the calf spawns with `Age: -24000, ForcedAge: 0, AgeLocked: 0, InLove: 0`; each parent becomes `Age: 6000, InLove: 0` with `LoveCause` still set.

---

## 5. TamableAnimal and ShoulderRidingEntity

### 5.1 `TamableAnimal`

| Key | NBT type | Default on load | Written when | Meaning |
|---|---|---|---|---|
| `Owner` | `Int Array(4)` (UUID) | none | only when an owner exists (the helper writes nothing for a null reference) | The owning player. |
| `Sitting` | Byte (boolean) | false | always | Ordered to sit. |

Load: the owner is read with the legacy conversion (45-1 §10.4): the UUID form first; when absent, a String under the same key is converted by the server's old-users converter (a name or a UUID text) and may be absent when the conversion fails. When an owner is present: the owner metadata is set and the animal becomes tame (`setTame(true, false)`; the second argument is "no side effects"); an exception inside this block makes it untame (`setTame(false, true)`). When no owner: the owner metadata is cleared and the animal is set untame (`setTame(false, true)`). Then `Sitting` is read into the "ordered to sit" state and the sitting pose is applied accordingly (`setInSittingPose`). The per-species effect of taming (health, attributes) is in the species parts.

### 5.2 `ShoulderRidingEntity`

The class extends `TamableAnimal` and the parrot class extends it (read); it declares no keys. The player's `ShoulderEntityLeft` and `ShoulderEntityRight` compounds, which hold a full entity compound for a parrot, are in part 3.

---

## 6. PatrollingMonster

The base of patrol members (read: it extends `Monster`; `Raider` extends it and `AbstractIllager` extends `Raider`). It adds three keys to the `Monster` keys (a `Monster` adds none):

| Key | NBT type | Default on load | Written when | Meaning |
|---|---|---|---|---|
| `patrol_target` | `Int Array(3)` | none | only when a target is set | Block position the patrol walks to. |
| `PatrolLeader` | Byte (boolean) | false | always | The captain. |
| `Patrolling` | Byte (boolean) | false | always | The mob is on a patrol. |

Runtime facts read: `findPatrolTarget` sets the target to the entity's own block position offset by x in [-500, 499] (-500 plus a random integer below 1000), y 0, z in [-500, 499] (each from the entity's own random source), and sets `Patrolling`. `setPatrolTarget` also sets `Patrolling`. At finalising a spawn whose reason is not PATROL, EVENT or STRUCTURE there is a 6 percent chance (a uniform float below 0.06) that the mob becomes the leader when the type allows it; a leader gets the ominous banner on its head slot with a head drop chance of 2.0. A spawn with reason PATROL sets `Patrolling`. Despawn: the mob may be removed when far away unless it is patrolling and within squared distance 16384 (128 blocks) of the nearest player. Spawn rule: block light at the position must be 8 or below, then the any-light monster rule applies. The ominous banner stack itself is built from the banner pattern registry (the raid document, part 6).

---

## 7. The `NeutralMob` helper (anger)

Some concrete types (which ones: the owner index of 45-1 §12 and the species parts; read: the classes that reference the `NeutralMob` interface are Bee, Wolf, IronGolem, PolarBear, Enderman and ZombifiedPiglin, plus the reset-universal-anger goal) call the helper from their own save code. The helper adds:

| Key | NBT type | Default on load | Written when | Meaning |
|---|---|---|---|---|
| `anger_end_time` | Long | see load rule | always | Game time (the world tick counter) at which the anger ends. -1 (`NO_ANGER_END_TIME`) means not angry. |
| `angry_at` | `Int Array(4)` (UUID) | none | only when an anger target exists | The entity this mob stays angry at. |

Load rule: if `anger_end_time` is present it is used. Otherwise the legacy Int key `AngerTime` (remaining ticks) is read when present and converted to an end time of the current game time plus that value; otherwise the end time is set to -1. `angry_at` is read only when the level is a server level; after reading, `setTarget` is called UNCONDITIONALLY with the result of resolving the reference to a living entity in that level: an absent or unresolvable `angry_at` therefore calls `setTarget(null)`, which clears the attack target. The method returns early on a client level, so none of this (the `angry_at` read and the target set) happens there; the end-time handling above runs on both sides.

Meaning: the mob is angry (`isAngry`) when the end time is greater than 0 and the end time minus the current game time is positive. `stopBeingAngry` clears the last-hurt-by mob, the anger target, the attack target and sets the end time to -1. The per-tick maintenance (`updatePersistentAnger`) clears the anger when the target is dead (for a mob target), when the angry state lapses with a target that is not a valid player target, or when the target is a player who is in creative mode or spectator, or when the difficulty is Peaceful. A damaging target is recorded as the anger target (the entity reference) and the anger timer restarts. Two more read helpers (also in [18](18-mob-framework.md) section 4.8): `playerDied(level, player)` calls `stopBeingAngry` when the game rule `forgive_dead_players` is true and the persistent anger target matches the dead player (it returns at once when the rule is false or there is no matching target). `isAngryAtAllPlayers(level)` is true when the game rule `universal_anger` is true, the mob `isAngry`, and it has NO persistent anger target. `isAngryAt(entity, level)` is false when `canAttack(entity)` is false; true for a valid player target when `isAngryAtAllPlayers` holds; otherwise true when the persistent anger target matches the entity. The Brain memory `universal_anger` is a separate Boolean (section 8.4).

Note: the Brain-driven mobs store their anger in the `angry_at` memory instead (section 8.4), with the same UUID form.

---

## 8. The shared Brain serialisation model

### 8.1 What is saved

Every `LivingEntity` writes the key `Brain` (section 2.1), even types that have no brain (their brain has no registered memories and saves `{memories:{}}`). The Brain's saved form is the `Packed` record:

| Key | NBT type | Required | Notes |
|---|---|---|---|
| `memories` | `Compound` | yes (a `Brain` compound without it is a decode error, so the whole key counts as absent) | A map from memory module type key to a stored value. |

Nothing else of the Brain is saved. Specifically NOT saved: the active activities, the current schedule position, the running behaviours and their state, the sensor timers, the last schedule update tick, and every memory of a type that is not serialisable (section 8.4). After loading, the brain starts in its default activity: a brain is constructed from its type's lists (sensors, memory types, activities with their behaviours and conditions), the core activity is set as the permanent core, the default activity is activated, and the schedule re-selects the activity at the first update (the last schedule update is initialised to -9999 so the first check always runs). The behaviour is therefore: saved memories survive a restart, but what the mob was "doing" is re-derived from its memories and the time of day.

### 8.2 The memory map form

`memories` is a compound whose keys are memory module type keys (registry names, `minecraft:home` form; the registry `memory_module_type` has 115 entries and its ids are not on the wire, [46](46-registry-ids.md) Open question 1) and whose values are `ExpirableValue` compounds:

| Key | NBT type | Default | Notes |
|---|---|---|---|
| `value` | the form of that memory type (section 8.4) | none: REQUIRED | The remembered value. |
| `ttl` | Long | none (no expiry) | Remaining ticks until the memory is forgotten. Present only for memories with an expiry. The field is "lenient": a `ttl` of the wrong type is ignored (the memory then never expires) instead of failing the entry. |

Key rules:

1. Only serialisable memory types are written (section 8.4). A memory that is not set (empty slot) is not written. A memory without expiry is written without `ttl`; a memory with an expiry is written with its remaining ticks.
2. The key is looked up by name in the registry; the codec is `validate`d so that only serialisable types are accepted. An unknown key, or a known key of a non-serialisable type, is a decode error (the exact reach of the error, whether the entry or the whole `memories` map is lost, is not visible in the read code, Open question 2).
3. The value codec of each entry is the type's own codec wrapped as above, chosen by the key (a dispatched map).

### 8.3 Expiry and load behaviour

Expiry model (`MemorySlot`): each memory type of a brain has one slot with a value (or none) and a remaining time-to-live; the "never expires" sentinel is the largest Long (9223372036854775807). Each brain tick, before sensors and behaviours run (the brain tick order is: forget outdated memories, tick sensors, start non-running behaviours, tick running behaviours), every slot that holds a value and can expire is processed: when the remaining time is 0 or less the slot is cleared, otherwise the remaining time goes down by 1. So a memory set with a TTL of N lives for N further brain ticks and is cleared on the tick after the counter has reached 0 (the clear check happens before the decrement).

Writing (`Brain.pack`): each memory slot is visited. An empty slot is skipped. A slot with a value is written only when its type is serialisable, as a value with TTL when it can expire (the stored TTL is the remaining ticks) and without TTL otherwise.

Loading (`Brain` constructor from `Packed`): the brain is built for its mob type first (the type fixes which memory types the brain owns: those of the type's list and those its sensors require). Then each saved memory is set. A saved memory of a type that the brain does not own is silently ignored. A saved value that is an empty collection is treated as no memory (the slot is cleared). A saved TTL becomes the remaining time; a saved value of TTL 0 or less is thus cleared at the first brain tick. Sensors are created with a random start delay.

The brain is created on load from the saved data (`makeBrain(packed)`). A type without a brain returns an empty brain and ignores `Brain`.

### 8.4 Which memory types are serialisable

Of the 115 registered memory types (registration order is the index, 0 to 114, fixed by 18 §4.5's list), 52 have a codec and are serialisable; the other 63 are runtime only and are never written. The registration of a type with a codec is the only place that declares serialisability. Value forms:

| Form name | NBT form |
|---|---|
| `GlobalPos` | `Compound {dimension: String, pos: Int Array(3)}` (45-1 §3) |
| `BlockPos` | `Int Array(3)` |
| `UUID` | `Int Array(4)` |
| Boolean | Byte |
| Int | Int |
| Long | Long |
| Unit | an empty compound `{}` (the "presence only" value; the `Unit` codec is reached through `Unit.CODEC`, which is built with `MapCodec.unitCodec` (read), which encodes as an empty compound; that decoding accepts any compound is (inferred) from the codec's name) |
| `List<GlobalPos>` | list of `GlobalPos` compounds. The list is stored as a set in memory for two of the three types (an `xmap` converts; inferred); duplicates collapse on load. |

The 52 serialisable types (id is the registration index):

| Id | Key | Value form |
|---|---|---|
| 1 | `home` | GlobalPos |
| 2 | `job_site` | GlobalPos |
| 3 | `potential_job_site` | GlobalPos |
| 4 | `meeting_point` | GlobalPos |
| 31 | `golem_detected_recently` | Boolean |
| 32 | `danger_detected_recently` | Boolean |
| 33 | `last_slept` | Long |
| 34 | `last_woken` | Long |
| 35 | `last_worked_at_poi` | Long |
| 39 | `play_dead_ticks` | Int |
| 41 | `temptation_cooldown_ticks` | Int |
| 42 | `gaze_cooldown_ticks` | Int |
| 43 | `long_jump_cooling_down` | Int |
| 45 | `has_hunting_cooldown` | Boolean |
| 46 | `ram_cooldown_ticks` | Int |
| 48 | `is_in_water` | Unit |
| 49 | `is_pregnant` | Unit |
| 50 | `is_panicking` | Boolean |
| 52 | `visited_block_positions` | List of GlobalPos |
| 53 | `unreachable_transport_block_positions` | List of GlobalPos |
| 55 | `charge_cooldown_ticks` | Int |
| 56 | `attack_target_cooldown` | Int |
| 62 | `angry_at` | UUID |
| 63 | `universal_anger` | Boolean |
| 64 | `admiring_item` | Boolean |
| 67 | `admiring_disabled` | Boolean |
| 68 | `hunted_recently` | Boolean |
| 87 | `recent_projectile` | Unit |
| 88 | `is_sniffing` | Unit |
| 89 | `is_emerging` | Unit |
| 90 | `roar_sound_delay` | Unit |
| 91 | `dig_cooldown` | Unit |
| 92 | `roar_sound_cooldown` | Unit |
| 93 | `sniff_cooldown` | Unit |
| 94 | `touch_cooldown` | Unit |
| 95 | `vibration_cooldown` | Unit |
| 96 | `sonic_boom_cooldown` | Unit |
| 97 | `sonic_boom_sound_cooldown` | Unit |
| 98 | `sonic_boom_sound_delay` | Unit |
| 99 | `liked_player` | UUID |
| 100 | `liked_noteblock` | GlobalPos |
| 101 | `liked_noteblock_cooldown_ticks` | Int |
| 102 | `item_pickup_cooldown_ticks` | Int |
| 103 | `sniffer_explored_positions` | List of GlobalPos |
| 107 | `breeze_jump_cooldown` | Unit |
| 108 | `breeze_shoot` | Unit |
| 109 | `breeze_shoot_charging` | Unit |
| 110 | `breeze_shoot_recover` | Unit |
| 111 | `breeze_shoot_cooldown` | Unit |
| 112 | `breeze_jump_inhaling` | Unit |
| 113 | `breeze_jump_target` | BlockPos |
| 114 | `breeze_leaving_water` | Unit |

Every other memory in the 18 §4.5 list (the entity-reference memories such as `attack_target`, `hurt_by_entity`, `nearest_visible_player`, the path and walk target, `nearest_bed`, `secondary_job_site`, `ride_target`, `breed_target`, `interaction_target`, `tempting_player`, the piglin and hoglin sensors' outputs, the spear memories, `dummy`) is NOT serialisable: a living reference, a path, or a per-tick sensor product. After a restart they are rebuilt by sensors and behaviours. A memory such as a villager's `home` or `job_site` survives because it is a `GlobalPos`.

Per-memory TTL values (how long each is set for by its behaviour) belong to the concrete behaviours and are in the sibling parts (4 to 7); this document gives only the model.

### 8.5 How parts 4 to 7 refer to memories

A sibling part that lists a concrete type's `Brain` states: (a) the memory types the type's brain owns (the others are ignored on load, 8.3), (b) which of them are in the 52 above, with the value form of 8.4, and (c) any TTL the type sets. It does not repeat the compound shape of 8.2.

---

## 9. Worked examples

### 9.1 A mob with the shared keys only (an adult animal, no effects, no equipment)

```
Health: 10.0f, HurtTime: 0s, DeathTime: 0s, AbsorptionAmount: 0.0f,
current_impulse_context_reset_grace_time: 0,
attributes: [ {id: "minecraft:max_health", base: 10.0d}, {id: "minecraft:movement_speed", base: 0.2d} ],
FallFlying: 0b,
Brain: {memories: {}},
CanPickUpLoot: 0b, PersistenceRequired: 0b, LeftHanded: 0b,
Age: 0, ForcedAge: 0, AgeLocked: 0b, InLove: 0
```

Reading notes. `active_effects` and `equipment` are absent (nothing to store). `drop_chances`, `leash`, `home_*`, `DeathLootTable*`, `NoAI`, `sleeping_pos` and `locator_bar_icon` are absent. The attribute elements have no `modifiers`. The `Health` and `base` numbers (10.0, 0.2) are arbitrary test data, not read from the jar and not attribute bases of any type; real bases depend on the type and are in the per-type parts. Do not use them as defaults (section 11 question 22). `NoAI` is written only when true.

### 9.2 Equipment, drop chances, home and death table

All values below (items, chances, the home radius and position, the loot table id, the seed) are arbitrary test data, not read facts (section 11 question 22). Only the key names and the 0.085 default and the preserved rule (above 1.0) are read.

```
equipment: {mainhand: {id: "minecraft:iron_sword", count: 1}, head: {id: "minecraft:iron_helmet", count: 1}},
drop_chances: {head: 2.0f, mainhand: 0.5f},
home_radius: 16, home_pos: [I; 100, 64, -20],
DeathLootTable: "minecraft:entities/zombie", DeathLootTableSeed: 123456789L, NoAI: 1b
```

Reading notes: empty slots are not listed; slots not in `drop_chances` take 0.085; `head` at 2.0 is preserved (always dropped). `mainhand: 0.5` drops half the time, and only if the kill counts as a player kill. `home_pos` is read because `home_radius` is 16 (>= 0).

### 9.3 Effect update and the hidden chain

Start: the entity has Speed amplifier 0, duration 1200 (no hidden effect). A potion applies Speed amplifier 1, duration 600.

1. N.amplifier 1 > E.amplifier 0, and N (600) is shorter than E (1200): a copy of E becomes the hidden effect; E becomes amplifier 1, duration 600. Saved form:
   `{id:"minecraft:speed", amplifier:1b, duration:600, ambient:0b, show_particles:1b, show_icon:1b, hidden_effect:{amplifier:0b, duration:1200, ambient:0b, show_particles:1b, show_icon:1b}}` (whether vanilla omits the default-valued `amplifier`, `ambient` and `show_particles` is Open question 19; a compound with or without them loads identically).
2. After 600 ticks the hidden effect was ticked down in step: it has 600 left. At the tick E reaches duration 0 it takes the hidden effect's details (amplifier 0, duration 600) and loses the hidden effect (the hidden effect's own hidden effect, none here).
3. A further Speed amplifier 0, duration 3000: N.amplifier 0 is not greater than E 0; E (600) is shorter than N and the amplifiers are equal, so E takes duration 3000.

### 9.4 Brain memories

A villager with a home bed, a job site, and a recent golem sighting (memories in the serialisable set; the positions, TTL 140 and the `last_slept` value are arbitrary test data, section 11 question 22):

```
Brain: {memories: {
  "minecraft:home": {value: {dimension: "minecraft:overworld", pos: [I; 12, 64, 40]}},
  "minecraft:job_site": {value: {dimension: "minecraft:overworld", pos: [I; 15, 64, 44]}},
  "minecraft:golem_detected_recently": {value: 1b, ttl: 140L},
  "minecraft:last_slept": {value: 5120L}
}}
```

Loading this into a villager's brain: the four memories are set (the villager owns these types), `golem_detected_recently` has 140 ticks left. Loading the same compound into a mob whose brain does not own `golem_detected_recently` ignores that entry.

### 9.5 Age and love

A calf (a type whose baby start age is -24000): `Age: -24000, ForcedAge: 0, AgeLocked: 0b, InLove: 0`. Each tick the age rises by 1 (unless age-locked), so after 24000 ticks `Age` is 0 and the "is baby" flag clears. A player feeding it breeding food while it is a baby calls `ageUp(seconds, true)` with seconds = truncate(float(integerDivide(-Age, 20)) x 0.1f) (`getSpeedUpSecondsWhenFeeding`, read; the argument is the remaining baby ticks), so each feeding advances the baby by 10 percent of its remaining baby time in whole seconds. For Age -24000: 1200 x 0.1 = 120 seconds = 2400 ticks, new Age -21600. Because `forced` is true, the difference (2400) is added to `ForcedAge` and `forcedAgeTimer` is set to 40 when it was 0 (section 4.1 rule 3). An adult fed breeding food: `InLove: 600`, hearts every 10th tick.

### 9.6 Tamed and sitting animal

`Owner: [I; 1, 2, 3, 4], Sitting: 1b`: loads tame, ordered to sit, in the sitting pose, plus all `Animal`, `AgeableMob`, `Mob` and `LivingEntity` keys.

---

## 10. Validation checklist

An implementation of this document is correct when:

1. A saved living entity compound contains `Health`, `HurtTime`, `DeathTime`, `AbsorptionAmount`, `current_impulse_context_reset_grace_time`, `attributes`, `FallFlying` and `Brain` always, and the conditional keys of section 2.1 only under the stated conditions.
2. A mob compound adds `CanPickUpLoot`, `PersistenceRequired` and `LeftHanded` always, and `NoAI` only when true.
3. Loading a compound with every optional key absent yields: health = max health, no effects, empty equipment, default drop chances, no leash, no home (radius -1), not left-handed, no override loot table, AI enabled, age 0, not in love.
4. Equipment round-trips with slot names `mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`, and a compound with only empty stacks is not written.
5. Drop chances: a map equal to the default is not written; a slot written with 2.0 is preserved.
6. Attributes: transient modifiers never appear in the saved list; an unknown attribute id is a decode error (reach unread, Open question 2b); the safe default for an implementation is to skip only that element and keep the rest of the list; `base` is written even when 0.0.
7. Effects: an amplifier 200 round-trips as byte -56 and loads as 200 (default-valued fields may be present or absent: Open question 19); a missing `show_icon` takes the value of `show_particles`; the hidden chain of three levels round-trips; an infinite effect writes duration -1 and does not tick down.
8. Brain: only the 52 serialisable memory types are written; a memory with an expiry writes `ttl`; a memory of an unowned type is ignored on load; an unknown or non-serialisable memory key: skip only that entry (implementer's choice, Open question 2); activities and the schedule are not saved and are rebuilt.
9. Age keys are written and read only for types that can be babies.
10. An animal with a non-zero `Age` and `InLove > 0` has `InLove` set to 0 at the first tick.
11. A tameable with `Owner` loads tame; without `Owner` loads untame; `Sitting` independent of both.
12. Patrol keys are written for patrol members and the leader flag defaults to false.

Test inputs for the unit tests: the compounds in 9.1 to 9.6 and the update rule's three steps in 9.3.

---

## 11. Open questions

1. Library behaviour not read. The marks "(inferred)" on optional-field omission (an empty `modifiers` list, a default `show_particles`) and on partial decode rely on the codec library's behaviour. That library is not part of the classes read; 45-1 §1 gives the same assumption. A save written by an implementation that always writes the empty list loads identically.
2. A non-serialisable or unknown memory key inside `memories`: the codec rejects it with an error, but whether the whole `Brain` is dropped or only that entry is skipped depends on the map decoder, which was not read. Implementers should skip only the bad entry (the safer behaviour); the vanilla outcome is unverified.
2b. The `attributes` list uses the plain list codec; the artifact does not show whether an unknown attribute id loses only that entry or the whole list. Implementers should skip only the bad entry; 45-1 section 1 gives the shared failure rule.
3. `amplifier` decoding as unsigned (values above 127) is inferred from the codec's name and range check; the decode lambda was not disassembled.
4. Which concrete types can be babies (the `canBeABaby` gate for the three age keys) and which types own which memories are per-type facts in parts 4 to 9.
5. (Closed: the `Unit` codec is `MapCodec.unitCodec`, read; see section 8.4. Only the decode leniency for a non-empty compound remains (inferred).)
6. `current_impulse_context_reset_grace_time` and `current_explosion_impact_pos`: the tick logic that decrements or clears them (the name suggests the wind charge and mace impulse; inferred) was not read.
7. The iteration order of the written `active_effects` list and of the written `attributes` list is the order of hash maps and is not significant on load.
8. When the effect-start hook runs for effects restored from `active_effects`, and whether `Health` is clamped to a maximum health that does not yet include modifiers added by those effects (for example Health Boost). Loading sets the effects dirty and reads `Health` after `active_effects` in the same call; the dirty-effects pass runs later. The consequence for a saved Health above the base maximum was not traced.
9. Which attribute instances vanilla writes depends on lazy instance creation; whether a type creates all of its instances at construction was not traced for every type.
10. The behaviour of a saved `Brain` whose `memories` contains a TTL of the wrong type: the field is lenient, so the memory loads without expiry (read), but the consequences for specific memories were not examined.
11. Whether a mob type can hold armor in the `body` and `saddle` slots is per type; the saved form accepts any slot on any mob.
12. The plain-Int form of `locator_bar_icon.color`: whether its alpha byte is kept or forced was not read (only the vector-derived form was, section 2.5).
13. The body of `EnchantmentHelper.processEquipmentDropChance` (how it changes a drop chance) was not read; only its call site (section 3.1).
14. DataFixer upgrades of the old keys listed at the end of section 1 are code not read in this round (45-1 Open question on version handling).
15. How the `Player` class and `ServerPlayer` extend the `LivingEntity` keys (for example whether the player compound writes `Brain`, `equipment`, `attributes`, `active_effects`) is part 3; the `LivingEntity` code path is as in section 2.
16. Whether `ShoulderRidingEntity` declares keys in a subclass that this round did not read (the parrot's own keys are in part 7) was not verified beyond the class itself having none.
17. Not read: the members of the tag `cannot_be_age_locked`, and the particle type and count of `makeAgeLockedParticle`.
18. No statement is currently marked "(recalled, not verified)" except the item in question 19; the worked-example numbers are covered by question 22; the body-slot users, events 18 and 60 and the `NeutralMob` users are read (sections 2.1, 2.4, 4.2, 7).
19. Whether `amplifier`, `duration`, `ambient` and `show_particles` of an effect are omitted when equal to their default depends on the codec library's optional-field encoder (recalled, not verified; the jar uses the plain optional-field form for them and the always-present form for the attribute `base`). Implementers accept both forms on load.
20. What triggers `Mob.dropPreservedEquipment` in `CopperGolem`, `ZombieVillager` and the trial spawner state data (the callers found by scanning the entity and level packages) is not described here; it belongs to those types' parts.
21. `getBabyStartAge` overrides were searched only in the entity package (found: `AgeableMob`, `Sniffer`); overrides elsewhere are not excluded.
22. The worked examples in 9.1, 9.2 and 9.4 use numbers that were not read from the jar: max_health 10.0, movement_speed 0.2, the iron sword and helmet, drop chance 0.5, home_radius 16, home_pos [100,64,-20], loot table `minecraft:entities/zombie`, seed 123456789, the villager home and job positions, ttl 140 and last_slept 5120. They are arbitrary test data to show the shape of the compound, not facts, and not recalled game values. Per-type attribute bases were not read in this part.
