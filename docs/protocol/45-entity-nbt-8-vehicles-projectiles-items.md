# Entity NBT, part 8: items, orbs, blocks, clouds, displays, vehicles, projectiles

| Item | Value |
|---|---|
| Covers | The persistent (NBT) keys, defaults, write conditions and meaning of the non-living, non-decoration entities: `item`, `experience_orb`, `falling_block`, `tnt`, `ominous_item_spawner`, `area_effect_cloud`, `marker`, `interaction`, `text_display`, `item_display`, `block_display`; every boat, raft and chest variant; every minecart; `end_crystal`, `lightning_bolt`, `evoker_fangs`, `llama_spit`, `shulker_bullet`, `eye_of_ender`, `firework_rocket`, `fishing_bobber`; every projectile (`arrow`, `spectral_arrow`, `trident`, `snowball`, `egg`, `ender_pearl`, `experience_bottle`, `splash_potion`, `lingering_potion`, `fireball`, `small_fireball`, `wither_skull`, `dragon_fireball`, `wind_charge`, `breeze_wind_charge`). It also gives the value formats these keys use (UUID, entity reference, block state, potion contents, transformation and others) and the engines that interpret the saved state which no earlier document specifies: the area effect cloud application loop, the spawner (used by the spawner minecart) and the command-block executor (used by the command block minecart). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the `addAdditionalSaveData` and `readAdditionalSaveData` methods of every class above, of the codecs they name and of the engine methods named in section 3.7, 4.5 and 4.6. No execution. Every key, default, range and constant below was read in this round unless marked "(inferred)" or "(recalled, not verified)". |
| Status | Round RS27, part 8. Siblings: part 1 (shared entity model: the `Entity` base keys, `VehicleEntity`, `ContainerEntity` and leash data), parts 2 to 7 and 9 (mobs and decorations). Cross-references use "NN section S" for single documents and "NN part P section S" for the multi-part documents 44 and 45; the content of those documents is not repeated. Part 7 (`45-entity-nbt-7-aquatic-and-misc-mobs.md`) lists several entities of this document as a sweep; this document is the authority for them and the differences are in section 8 (written to be read without the task that produced this round). |

Class names in backticks say where a fact was read; they are not the design. NBT type names are those of [07](07-nbt-and-anvil.md). Registry names, tags, recipes, loot tables, item components and block predicates are data and are not tabulated: the schema and the engine are specified, the rows come from the extracted data pack (22, 23).

## Contents

1. [How an entity compound is built](#1-how-an-entity-compound-is-built)
2. [Value formats used by these keys](#2-value-formats-used-by-these-keys)
3. [Items, orbs, blocks, clouds, markers and displays](#3-items-orbs-blocks-clouds-markers-and-displays)
4. [Vehicles](#4-vehicles)
5. [Projectiles](#5-projectiles)
6. [Entities with no keys of their own, and entities that are never saved](#6-entities-with-no-keys-of-their-own-and-entities-that-are-never-saved)
7. [Master table: layers per entity type](#7-master-table-layers-per-entity-type)
8. [Naming differences and corrections to other documents](#8-naming-differences-and-corrections-to-other-documents)
9. [Worked examples](#9-worked-examples)
10. [Validation](#10-validation)
11. [Open questions](#11-open-questions)

## 1. How an entity compound is built

1. Every entity class may override a save method (`addAdditionalSaveData`) and a read method (`readAdditionalSaveData`). Each override first calls its parent and then writes or reads its own keys, so the saved compound is the union of the layers of the class chain, parent first. Layer 0 is the `Entity` base (`Pos`, `Motion`, `Rotation`, `UUID`, `Tags`, `data`, `Passengers` and the others, owned by part 1); the leaf layers are in section 7.
2. Writing uses four operations. `putX(key, v)` always writes the key with the NBT type X. `store(key, codec, v)` always writes the key encoded by the named codec. `storeNullable(key, codec, v)` writes the key only when `v` is not null. Where a table says "when ..." the save method tests the condition first.
3. Reading uses `getXOr(key, default)`: an absent or wrongly typed key yields the default and never an error. `read(key, codec)` yields "empty" when the key is absent or the value does not decode, and the reader then substitutes the stated fallback. Unknown keys are ignored.
4. Numeric narrowing on write is part of the format: a Java int stored with `putShort` is truncated to 16 bits (the item `Age`, the orb `Value`, the furnace minecart `Fuel`, every spawner counter).
5. **Entities that are never saved.** Two entity types in this document are registered "no save": `fishing_bobber` and `lightning_bolt` (read in `EntityTypes`: the builder call `noSave`; the other no-save types are `leash_knot` and `player`, which belong to other documents). They never appear in an `entities/` compound. Section 6 gives the consequence.
6. **Registry flags that affect persistence or fire only** (read in `EntityTypes`): `tnt`, `area_effect_cloud` and `end_crystal` are fire immune; `area_effect_cloud` and `end_crystal` have no update interval. Sizes and tracking ranges are in 21 section 8 and Appendix A and are not repeated.
7. **Entity type keys** are the registry keys of 46. Boats and rafts are separate entity types (section 4.1); there is no `Type` key in any boat compound.

## 2. Value formats used by these keys

Each row names the codec as read and the NBT shape it produces.

| Format | NBT shape | Read in |
|---|---|---|
| UUID (`UUIDUtil.CODEC`) | Int Array of exactly 4 ints: `[most >> 32, most low 32 bits, least >> 32, least low 32 bits]`, each as a signed int. A wrong length fails to decode. | `UUIDUtil` |
| Entity reference (`EntityReference.store` and `read`) | The UUID format above under the given key. A null reference writes nothing. On read an absent or invalid value gives no reference. The reference is resolved to a live entity by UUID lookup when it is used (owner, thrower, target). | `EntityReference` |
| Item stack (`ItemStack.CODEC`) | Compound `{id: String item key, count: Int in 1..99 (written always, default 1 when absent), components: Compound patch (optional, absent = empty)}`. The `id` carries the item's default components. The component patch and the empty-stack form `OPTIONAL_CODEC` (an empty stack is `{}`) are as in 45 part 7 section 9. `ItemStack.CODEC` itself does not accept an empty stack; save methods that may hold an empty stack test `isEmpty` first (section 3.1, 3.10) or use the optional form. | `ItemStack` |
| Item stack with slot (`ItemStackWithSlot.CODEC`) | The item stack compound above plus the `Slot` key; specified in 45 part 3 section 4.1 (unsigned-byte codec, decode cannot fail, a stored -1 loads as 255). Not repeated here. | `ItemStackWithSlot` |
| Container contents (`ContainerHelper.saveAllItems` and `loadAllItems`) | Key `Items`: List of Compound, one item-stack-with-slot per non-empty slot, in slot order. When the list is empty the key is still written for the normal save. On read, `loadAllItems` does not clear the container: it reads `Items` (absent or wrong type counts as an empty list), skips entries whose `Slot` is outside `0 <= slot < size` and sets the slot of every other entry. Clearing is done by the callers (the chest-vehicle read clears the item list first). | `ContainerHelper` |
| Block state (`BlockState.CODEC`, section 2.1) | A String (the block key) when the state is the block's default state, otherwise a Compound `{id: String block key, properties: Compound of String to String}`. | `BlockState`, `StateHolder` |
| Block position (`BlockPos.CODEC`) | Int Array of 3 ints `[x, y, z]` (index order inferred from the accessor order 0, 1, 2). | `BlockPos` |
| Direction legacy id (`Direction.LEGACY_ID_CODEC`) | Byte: 0 down, 1 up, 2 north, 3 south, 4 west, 5 east (the constructor order of `Direction`). Decoding wraps with `abs(value mod 6)` (`from3DDataValue`). The encoder and decoder are the method references of the static initialiser (inferred to be `get3DDataValue` and `from3DDataValue`). | `Direction` |
| Arrow pickup (`AbstractArrow$Pickup.LEGACY_CODEC`) | Byte: 0 `DISALLOWED`, 1 `ALLOWED`, 2 `CREATIVE_ONLY`. `byOrdinal` maps a negative value to 0 and a value greater than 3 to 0 (the bound test is "value above the count"; see Open question 2 for the value 3). | `AbstractArrow$Pickup` |
| Sound event (`Registry.byNameCodec` of `SOUND_EVENT`) | String registry key, for example a hit sound's key. Unknown keys do not decode. | `AbstractArrow` |
| Potion contents (`PotionContents.CODEC`) | Written as the full compound `{potion: String (optional, a potion key), custom_color: Int (optional), custom_effects: List of effect instance (default empty), custom_name: String (optional)}`. On read a bare String is also accepted and means `{potion: that key}` (the codec is the full record with a potion-key alternative). | `PotionContents` |
| Effect instance (`MobEffectInstance.CODEC`) | Compound `{id: String effect key, amplifier: Byte (default 0), duration: Int (default 0), ambient: Boolean (default false), show_particles: Boolean (default true), show_icon: Boolean (optional; absent means the same as show_particles (inferred)), hidden_effect: Compound effect instance without `id` ... as the same details record (optional)}`. | `MobEffectInstance`, `MobEffectInstance$Details` |
| Particle options (`ParticleTypes.CODEC`) | Compound whose `type` key (inferred: the default key of a dispatch codec) is the particle type key; the remaining keys are the options of that particle type. Simple particles have only `type`. | `ParticleTypes` |
| Transformation, extended (`Transformation.EXTENDED_CODEC`) | Written in the decomposed form: Compound `{translation: List of 3 Float, left_rotation: quaternion, scale: List of 3 Float, right_rotation: quaternion}`. Reading also accepts a List of 16 Float, the 4x4 matrix (the extended alternative). | `Transformation`, `ExtraCodecs` |
| Quaternion (`ExtraCodecs.QUATERNIONF`) | Written as a List of 4 Float (component order x, y, z, w, read from the constructor call of the list decoder). **Reading the list form builds the quaternion from the four floats in that order and then normalises it**, so `[0, 0, 0, 2]` loads as `[0, 0, 0, 1]` (the list length of 4 is checked in the neighbouring validation lambda). Reading also accepts Compound `{angle: Float, axis: List of 3 Float}`. The identity quaternion is `[0, 0, 0, 1]` (inferred). | `ExtraCodecs` |
| Brightness (`Brightness.CODEC`) | Compound `{block: Int 0..15, sky: Int 0..15}`. | `Brightness` |
| Compound (`CompoundTag.CODEC`) | An arbitrary compound stored as is (falling-block `TileEntityData`, spawner entity data). | `CompoundTag` |
| Text component (`ComponentSerialization.CODEC`) | The text component format (a String for plain text, or a Compound/List form). Not re-specified here; see Open question 1. | `ComponentSerialization` |
| Adventure predicate (`AdventureModePredicate.CODEC`) | A non-empty list of block predicates; a single predicate may be written without the list (compact list codec). The predicate schema is data (advancement block predicates). | `AdventureModePredicate` |
| Spawn data (`SpawnData.CODEC`) | Compound `{entity: Compound (the entity compound, normally with `id`), custom_spawn_rules: Compound (optional), equipment: Compound (optional)}`. `custom_spawn_rules` is `{block_light_limit: inclusive int range, sky_light_limit: inclusive int range}`, each lenient and defaulting to the full light range. `equipment` is an equipment table (data). | `SpawnData`, `SpawnData$CustomSpawnRules` |
| Weighted list of spawn data (`SpawnData.LIST_CODEC`) | List of Compound `{data: spawn data, weight: Int}`. A weight below 0 is rejected. | `WeightedList`, `Weighted` |
| Loot table key (`LootTable.KEY_CODEC`, and `putString` of the identifier on write) | String (an identifier). Written with `putString` of `identifier.toString`. | `ContainerEntity` |

### 2.1 Block state compound

1. The block is looked up by the key in `id`; the properties come from the `properties` compound.
2. If the state equals the block's default state, the writer produces only the block key as a String (the "constant" form). The reader accepts both forms.
3. If the block has no properties at all (a singleton state) the `properties` key is absent.
4. Otherwise `properties` has one String entry per property of the block, named by the property name, whose value is the property value name (`"true"`, `"north"`, `"3"`). All properties are written, not only those that differ from the default. A missing property on read takes the default state's value; an invalid value is handled leniently by the default.
5. The key names in 26.3 are lower case `id` and `properties`. Documents written against older formats use `Name` and `Properties`; the 26.3 reader reads the lower-case form (see 06 and 07 for chunk palettes, which are a different codec and are not changed by this section).

## 3. Items, orbs, blocks, clouds, markers and displays

### 3.1 `item` (`ItemEntity`, layer over `Entity`)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `Health` | Short | always | 5 | Hit points left; damage and its rules are in 41 section 5.2 |
| `Age` | Short | always | 0 | Ticks lived; the lifetime rules, including the special ages -6000 and -32768, are in 41 section 5.1. Stored as a 16-bit value |
| `PickupDelay` | Short | always | 0 | Ticks before a player can pick it up; the value 32767 means never (41 section 4.2) |
| `Thrower` | Int Array (entity reference) | when set | none | The entity that threw or dropped the item (used for the thrower-based advancement trigger and for the pickup rules of 41) |
| `Owner` | Int Array (UUID) | when set (`storeNullable`) | none | The only player allowed to pick the item up while the pickup restriction applies. Note the different name and the same format as `Thrower` |
| `Item` | Compound item stack | when the stack is not empty | the empty stack | The stack (section 2). `Item` is omitted for an empty stack |

Write order: `Health`, `Age`, `PickupDelay`, `Thrower`, `Owner`, `Item`. After reading, an item entity whose stack is empty is discarded immediately (the entity never enters the world).

### 3.2 `experience_orb` (`ExperienceOrb`)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `Health` | Short | always | 5 | Hit points |
| `Age` | Short | always | 0 | Ticks lived (the 6000-tick lifetime and merge rules are in 21 section 8.2) |
| `Value` | Short | always | 0 | Experience carried by one merged unit. Truncated to 16 bits on write (Open question 8) |
| `Count` | Int | always | 1 | How many orbs of this value have merged into this entity. On read the value must be positive (a zero or negative value does not decode and the default 1 applies) |

The total carried is `Value x Count` (inferred from the names; the award code is in 21 section 8.2).

### 3.3 `falling_block` (`FallingBlockEntity`)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `BlockState` | block state (section 2.1) | always | the default state of sand | The block the entity will place or break into |
| `Time` | Int | always | 0 | Ticks since spawn |
| `DropItem` | Boolean | always | true | Whether the block drops as an item when it cannot be placed |
| `HurtEntities` | Boolean | always | true when the loaded block state is in the block tag `anvil`, else false | Whether landing damages entities |
| `FallHurtAmount` | Float | always | 0.0 | Damage per block fallen |
| `FallHurtMax` | Int | always | 40 | Cap of the damage |
| `TileEntityData` | Compound | when not null | none | The block entity data to apply to the placed block |
| `CancelDrop` | Boolean | always | false | When true the block is not dropped as an item and not placed (set by the engine when the entity is cancelled) |

Write order: `BlockState`, `Time`, `DropItem`, `HurtEntities`, `FallHurtAmount`, `FallHurtMax`, `TileEntityData` (when set), `CancelDrop`. The ordering on read differs (the `anvil` test uses the state just read, so `BlockState` is read first). The falling-block tick engine was not located in a numbered document (33 mentions only the `entity_drops` rule for it); the only persisted-state facts it needs are: an air block state makes the entity discard itself on the first tick, `Time` increments each tick, and `CancelDrop` suppresses the drop and the placement.

### 3.4 `tnt` (`PrimedTnt`)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `fuse` | Short | always | 80 | Ticks until the explosion |
| `block_state` | block state | always | the default state of the TNT block | The block rendered |
| `explosion_power` | Float | only when not 4.0 | 4.0; the value read is clamped to 0.0 to 128.0 | Explosion radius power |
| `owner` | Int Array (entity reference) | when set | none | The igniter. Note lower case (the projectile keys are `Owner`) |

### 3.5 `ominous_item_spawner` (`OminousItemSpawner`)

| Key | NBT type | Written | Absent on read |
|---|---|---|---|
| `item` | Compound item stack | when not empty | the empty stack |
| `spawn_item_after_ticks` | Long | always | 0 |

The behaviour (it spawns the item after the delay) is in 21 section 8.17.

### 3.6 `area_effect_cloud` (`AreaEffectCloud`)

Keys, in write order:

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `Age` | Int | always | 0 | The entity's tick count (the field `tickCount`) |
| `Duration` | Int | always | -1 | Ticks the cloud lives after waiting; -1 means no limit |
| `WaitTime` | Int | always | 20 | Ticks during which the cloud is "waiting" and does nothing |
| `ReapplicationDelay` | Int | always | 20 | Ticks before the same entity can be affected again |
| `DurationOnUse` | Int | always | 0 | Added to `Duration` each time a victim is affected |
| `RadiusOnUse` | Float | always | 0.0 | Added to the radius each time a victim is affected |
| `RadiusPerTick` | Float | always | 0.0 | Added to the radius every tick after waiting |
| `Radius` | Float | always | 3.0 | Current radius; setting it clamps to 0.0 to 32.0 |
| `custom_particle` | particle options | when not null | none (the default particle is the entity-effect particle coloured by the potion colour) | Overrides the particle |
| `Owner` | Int Array (entity reference) | when set | none | The living entity credited with the effects |
| `potion_contents` | potion contents | unless equal to the empty value | the empty value | Effects applied: the potion's effects followed by `custom_effects` |
| `potion_duration_scale` | Float | only when not 1.0 | 1.0 | Multiplies the duration of each applied effect |

The older keys `effects`, `Particle`, `Color` and `Potion` are not read or written in 26.3 (section 8). The victims map is runtime state and is not saved: after a reload every entity is eligible immediately.

**Dimensions.** The bounding box is `2 x Radius` wide and `0.5` high (scalable dimensions); changing the radius re-centres the box on the same position.

**Particle colour.** When `custom_particle` is null the synced particle is the entity-effect particle with colour `opaque(potion colour)`; `potion colour` is the colour of the potion contents (`custom_color` when set, otherwise the mix of the effect colours, as in 43 section 7.3).

**Creation from a stack.** The cloud accepts four item components when created from a stack (`applyComponentsFromItemStack`, which calls `applyImplicitComponents`). The cloud layer applies `potion_contents` first (set as the potion contents) and `potion_duration_scale` second (set as the scale), each only when the stack carries it; it then calls the base entity layer (45 part 1), which applies `custom_name` (set as the entity's custom name) and `custom_data` (stored as the entity's custom data, as is) the same way, each only when present. Any other component is ignored. The cloud therefore takes the item's custom name and custom data as well as the two potion components.

#### 3.6.1 The server tick (`serverTick`)

Run once per tick on the server, after the base entity tick. Let `t` be `tickCount` as seen by the method. The increment is made in the common entity tick (`Entity.commonTick`), which the level's non-passenger entity tick calls immediately before the entity's `tick`; the cloud's `tick` calls the base `tick` and then `serverTick`, so `serverTick` sees the already incremented value (read).

1. If `Duration != -1` and `t - WaitTime >= Duration`: discard and stop.
2. `waiting = t < WaitTime`. Update the synced waiting flag when it changes. If `waiting`: stop (nothing else happens while waiting, not even the radius change).
3. `r = Radius`. If `RadiusPerTick != 0`: `r = r + RadiusPerTick`; if `r < 0.5` discard and stop; otherwise store `r` (clamped by the setter).
4. Only when `t mod 5 = 0` do steps 5 to 9 run (`TIME_BETWEEN_APPLICATIONS` is 5, 21 section 8.5).
5. Drop every victim entry whose expiry value is `<= t` (`t >= expiry`).
6. If the potion contents have no effects: clear the victims map and stop.
7. Build the effect list: every effect of the potion contents with its duration scaled by `potion_duration_scale` (`forEachEffect`).
8. Take all living entities whose bounding box intersects the cloud's bounding box. For each entity, in the order returned by the level query, skip it when: it is already in the victims map; it is not affected by potions (`isAffectedByPotions`); or no effect of the list can be applied to it (a `noneMatch` test of the entity against the list; inferred to be the per-effect `canBeAffected` test). Otherwise measure `dx` and `dz` between the entity position and the cloud position; the entity is affected only when `dx^2 + dz^2 <= r^2` (the local `r`, which includes any change made for earlier victims in the same pass). Precision: `dx` and `dz` are doubles (entity coordinate minus cloud coordinate) and their squares are summed in double; the right-hand side `r*r` is a single-precision float product, widened to double afterwards. The test fails only when the left side is greater, so equality passes. At boundary distances the float rounding of `r*r` therefore decides the result.
9. For an affected entity: put it in the victims map with expiry `t + ReapplicationDelay`. For each effect in the list: if the effect is instantaneous, apply it with `applyInstantaneousEffect(level, cloud, owner, target, amplifier, 0.5)` (the proximity factor is the constant 0.5); otherwise add a copy of the effect instance to the entity with the cloud as its source. Then: if `RadiusOnUse != 0`: `r = r + RadiusOnUse`; if `r < 0.5` discard and stop, else store `r`. Then if `DurationOnUse != 0` and `Duration != -1`: `Duration = Duration + DurationOnUse`; if `Duration <= 0` discard and stop.

**Timeline of a lingering potion cloud (from 3.6.2 values).** `Radius` 3.0, `RadiusPerTick` -0.005, `WaitTime` 10: ticks 0 to 9 do nothing; from tick 10 the radius is changed by -0.005 each tick. The radius is a 32-bit float that is read, added to and stored every tick, so the result is the float accumulation, not exact arithmetic (simulated in single precision): after the 91 shrinking ticks at `t = 10` to `t = 100` the radius is 2.5449896, not 2.55; the first value below 0.5 is 0.49998 after the 500th shrinking tick (exact arithmetic would suggest the 501st). With the first shrink at `t = 10` the 500th is at `t = 509` (with the `tickCount` numbering read in 3.6.1), where step 3 discards the cloud; this is before the 600-tick `Duration` rule (step 1 would trigger at `t = 610`). A victim pass runs at `t mod 5 = 0` after the shrink of the same tick, so the first pass (`t = 10`) sees a radius of 2.995 (float 2.995 less than 3.0 by one step); each victim then removes 0.5 (`RadiusOnUse`). Five victims in one pass leave 2.995 - 2.5 = 0.495 (float 0.49499989), below 0.5, so the cloud is discarded at the fifth victim, not the sixth; a cloud that has not shrunk (radius exactly 3.0, for example a hand-written one with `RadiusPerTick` 0) is discarded at the sixth victim (3.0 - 3.0 = 0.0).

#### 3.6.2 Cloud creation by a lingering potion (`ThrownLingeringPotion.onHitAsPotion`)

On hit: a cloud at the hit entity's position (when an entity was hit) or the projectile's position; owner = the projectile's owner when it is a living entity; `Radius` 3.0; `RadiusOnUse` -0.5; `Duration` 600; `WaitTime` 10; `RadiusPerTick = -Radius / Duration` (so -0.005); then the stack's `potion_contents` and `potion_duration_scale` are copied in; the cloud is added to the level. `ReapplicationDelay` keeps its default 20. The splash potion applies its effects directly (a 4 x 2 x 4 box inflation around the hit, 17 section 3.15 and 44 part 8 section 10) and creates no cloud. The dragon's cloud values are in 21 section 6.4.

### 3.7 `marker` (`Marker`)

`Marker` overrides the save and read methods with empty bodies: it has no keys of its own. Its "data" is the `data` compound of the `Entity` base layer (part 1): an arbitrary compound that commands can write, kept by every entity. The marker has no physics (`noPhysics` true), does nothing on tick, and defines no synced data.

### 3.8 `interaction` (`Interaction`)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `width` | Float | always | 1.0 | Box width |
| `height` | Float | always | 1.0 | Box height |
| `attack` | Compound `{player: UUID Int Array, timestamp: Long}` | when not null | none | The last player who attacked it and the game time of the attack |
| `interaction` | the same compound | when not null | none | The last player who used (right-clicked) it and the game time |
| `response` | Boolean | always | false | Whether the entity swings the player's arm and plays the interaction response |

After reading the bounding box is rebuilt from the new width and height (scalable dimensions anchored at the position). Behaviour: the entity is pickable; a player's attack (`skipAttackInteraction`) records `attack = {player UUID, game time}`, fires the "player hurt entity" trigger for server players (`PlayerHurtEntityTrigger.trigger(player, entity, damageSource, float, float, boolean)`) with the generic damage source, the two float arguments both 1.0 (damage dealt and damage taken; roles inferred from the signature) and the blocked flag false (all read from the call), and returns "skip the normal attack" unless `response` is true; a use (`interact`) on the server records `interaction` and returns `CONSUME`, on the client returns `SUCCESS` when `response` is true and `CONSUME` otherwise. `tick` does nothing.

### 3.9 Display entities (`Display` and subclasses)

All three display entities share the `Display` layer. Write order: `transformation`, `billboard`, `interpolation_duration`, `teleport_duration`, `view_range`, `shadow_radius`, `shadow_strength`, `width`, `height`, `glow_color_override`, `brightness`; then the subclass layer.

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `transformation` | transformation (section 2), decomposed on write | always | identity (translation 0, rotations identity, scale 1) | Model transform applied to the content |
| `billboard` | String: `fixed`, `vertical`, `horizontal` or `center` | always | `fixed` | Which axes turn the content towards the viewer |
| `interpolation_duration` | Int | always | 0 | Ticks over which a changed transformation is interpolated |
| `start_interpolation` | Int | **never written**; read only | 0 | Ticks of delay before the interpolation starts; written to the synced data with the "force update" flag |
| `teleport_duration` | Int | always | 0 on read, then clamped to 0..59 | Ticks over which a position or rotation change is interpolated |
| `view_range` | Float | always | 1.0 | Render distance factor |
| `shadow_radius` | Float | always | 0.0 | Shadow size |
| `shadow_strength` | Float | always | 1.0 | Shadow opacity |
| `width` | Float | always | 0.0 | Culling box width |
| `height` | Float | always | 0.0 | Culling box height |
| `glow_color_override` | Int | always | -1 | ARGB glow colour; -1 means "none" (the team colour is used) |
| `brightness` | Compound `{block, sky}` | when not null | none | Fixed light level; absent means "use the world light" |

#### 3.9.1 `text_display`

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `text` | text component | always | the empty text | The text. On read it is decoded, then resolved (selectors, scores and other dynamic parts are evaluated) with the permission level of a game master on a server level, or replaced by the empty text on a non-server level. A failed or absent decode gives an empty optional and leaves the text at its default or previous value, silently. The warning "Failed to parse display entity text {}" is logged only when the resolution step throws (the catch of any exception covers the resolve and set steps, not the decode); the text then also stays unchanged |
| `line_width` | Int | always | 200 | Pixel width at which lines wrap |
| `background` | Int | always | 1073741824 (hex 0x40000000: black at 25 percent opacity) | ARGB background colour used when `default_background` is false |
| `text_opacity` | Byte | always | -1 (255 as an unsigned value) | Text opacity 0 to 255 stored as a signed byte |
| `shadow` | Boolean | always | false | Flag bit value 1 |
| `see_through` | Boolean | always | false | Flag bit value 2 |
| `default_background` | Boolean | always | false | Flag bit value 4 (use the default chat-style background) |
| `alignment` | String: `center`, `left` or `right` | always | `center` | Text alignment |

Write order after the `Display` layer: `text`, `line_width`, `background`, `text_opacity`, `shadow`, `see_through`, `default_background`, `alignment`. In the synced flags byte the three booleans use bits 1, 2 and 4 and the alignment uses bits 8 (left) and 16 (right); neither bit means centre, and if both were set the left bit wins (`getAlign` tests bit 8 first). Reading starts the flags at 0, sets each boolean's bit when the key is true, and adds the alignment bit when `alignment` is present and is `left` or `right`.

#### 3.9.2 `item_display`

| Key | NBT type | Written | Absent on read |
|---|---|---|---|
| `item` | Compound item stack | when not empty | the empty stack |
| `item_display` | String: `none`, `thirdperson_lefthand`, `thirdperson_righthand`, `firstperson_lefthand`, `firstperson_righthand`, `head`, `gui`, `ground`, `fixed`, `on_shelf` | always | `none` |

The ten names are the serialized names of the enum in declaration order (ids 0 to 9, `none` is 0 and `on_shelf` is 9).

#### 3.9.3 `block_display`

| Key | NBT type | Written | Absent on read |
|---|---|---|---|
| `block_state` | block state | always | the default state of air |

Interpolation of the transformation, the position and the rotation is client behaviour; the client-side numbers are in 12 and 21 Appendix A (metadata ids). The persisted values above are all the server keeps.

## 4. Vehicles

### 4.1 Boats, rafts and chest variants

The entity types are `oak_boat`, `spruce_boat`, `birch_boat`, `jungle_boat`, `acacia_boat`, `dark_oak_boat`, `pale_oak_boat`, `mangrove_boat`, `cherry_boat`, `poplar_boat`, `bamboo_raft` and the chest variant of each (`oak_chest_boat` ... `poplar_chest_boat`, `bamboo_chest_raft`): 22 types, read in `EntityTypes`. Each type is registered with a factory that carries its drop item (the item with the same name as the entity type, read in the 22 supplier lambdas: for example `oak_boat` drops `oak_boat`, `bamboo_chest_raft` drops `bamboo_chest_raft`). The bamboo types use the raft classes (`Raft`, `ChestRaft`), all the others the boat classes (`Boat`, `ChestBoat`); the class split is inferred from the factory method names. **The wood is therefore carried by the entity type, never by a key.**

| Class layer | Keys | Notes |
|---|---|---|
| `VehicleEntity` | none of its own in this document | The vehicle base keys (damage state is synced data only) belong to part 1; `VehicleEntity` has no save or read override |
| `AbstractBoat` | `leash` | The leash compound, stored with `storeNullable`, read with `readLeashData` (a present leash on a boat that had none is applied, an absent one removes an existing leash). The compound format is part 1's (`Leashable$LeashData.CODEC`) |
| `AbstractChestBoat` (chest boats and chest rafts) | `Items`, or `LootTable` and `LootTableSeed` | Chest-vehicle data, section 4.2 |

Boat and raft classes `Boat`, `Raft`, `ChestBoat` and `ChestRaft` do not override either method.

### 4.2 Chest vehicle data (`ContainerEntity.addChestVehicleSaveData` and `readChestVehicleSaveData`)

Used by the chest boats, chest rafts, chest minecarts and hopper minecarts.

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `LootTable` | String | when the container has an unopened loot table | none | Identifier of the loot table that fills the container on first open |
| `LootTableSeed` | Long | when `LootTable` is written and the seed is not 0 | 0 | Seed of that roll |
| `Items` | List of Compound item-stack-with-slot | **only when there is no loot table** | empty | The contents (section 2) |

1. Writing: if the loot table is set, write `LootTable`, then `LootTableSeed` unless it is 0, and do not write `Items`; otherwise write `Items` with the standard container writer (the slot counts of the boats and carts are in 44 part 8 sections 3 and 4; slots outside the container's size are dropped on read).
2. Reading: first clear the container; read `LootTable` (a failed decode gives none) and `LootTableSeed` (default 0); then **only if no loot table was read**, load `Items`.
3. Consequence: a container with a pending loot table has no `Items` key in its saved compound, and a saved `Items` next to a `LootTable` is ignored on load.

### 4.3 Minecart common layer (`AbstractMinecart`)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `DisplayState` | block state | when a custom display block state is set | the minecart's default display state | The block shown in the cart |
| `DisplayOffset` | Int | only when it differs from the cart's default offset | the cart's default offset | Vertical offset of the displayed block in 1/16 block |
| `FlippedRotation` | Boolean | always | false | Whether the cart's orientation is flipped relative to its movement |
| `HasTicked` | Boolean | always | false | Whether the cart has run its first tick (a flag set by the per-tick routine, 44 part 8 section 4.2, whose own use is not described there; Open question 12) |

Defaults per cart type (read in `getDefaultDisplayBlockState` and `getDefaultDisplayOffset`):

| Entity type | Class | Drop item | Default display state | Default display offset |
|---|---|---|---|---|
| `minecart` | `Minecart` | `minecart` | air | 6 |
| `chest_minecart` | `MinecartChest` | `chest_minecart` | chest facing north | 8 |
| `furnace_minecart` | `MinecartFurnace` | `furnace_minecart` | furnace facing north, lit when it has fuel | 6 (the base value; the class does not override it) |
| `hopper_minecart` | `MinecartHopper` | `hopper_minecart` | hopper | 1 |
| `tnt_minecart` | `MinecartTNT` | `tnt_minecart` | TNT | 6 |
| `spawner_minecart` | `MinecartSpawner` | `minecart` | spawner | 6 |
| `command_block_minecart` | `MinecartCommandBlock` | `minecart` | command block | 6 |

(The pick-result item of the spawner minecart is `minecart`; of the command block minecart it is `command_block_minecart`. Offsets of classes that print no override equal the base value 6.)

The movement, rail and collision rules of all carts are in 44 part 8 section 4; this section only gives the persisted state.

### 4.4 Subtype layers

| Entity | Layer keys (written after the common layer, and after `Items` or `LootTable` where the cart is a container) |
|---|---|
| `minecart` | none |
| `chest_minecart` (`AbstractMinecartContainer`) | chest vehicle data (section 4.2) |
| `hopper_minecart` | chest vehicle data, then `Enabled` (Boolean, always written, absent on read true: whether the hopper collects items; it is switched by powered activator rails) |
| `furnace_minecart` | `PushX` (Double, always, absent 0.0), `PushZ` (Double, always, absent 0.0), `Fuel` (Short, always, absent 0) |
| `tnt_minecart` | `fuse` (Int, always, absent -1 meaning not ignited), `explosion_power` (Float, only when not 4.0, absent 4.0, clamped on read to 0.0 to 128.0), `explosion_speed_factor` (Float, only when not 1.0, absent 1.0, clamped on read to 0.0 to 128.0) |
| `spawner_minecart` | the spawner state, section 4.5 |
| `command_block_minecart` | the command block state, section 4.6 |

Furnace minecart facts needed to interpret the keys (the rest is in 44 part 8 section 4): the push vector's Y is always 0; `Fuel` is decremented by 1 each server tick while above 0, and when it reaches 0 or below the push is reset to zero; the cart is "lit" when `Fuel > 0`; the maximum speed is 0.5 of the base maximum (0.75 of it in water). The Fuel Short truncates (Open question 8). Persisted-state rules: the engine constant `MAX_FUEL_TICKS` is 32000 and each fuel item (item tag `furnace_minecart_fuel`) adds 3600 (`FUEL_TICKS_PER_ITEM`) only when `Fuel + 3600 <= 32000`, so play can never produce a `Fuel` above 32000 (at most 8 items from 0 give 28800; a ninth would give 32400 and is refused). A `Fuel` outside 0..32000 can therefore only come from hand-edited NBT.

### 4.5 Spawner state (`BaseSpawner.save` and `load`) and the spawner engine

Used by `spawner_minecart` (the spawner block entity uses the same object; its other keys are in the block-entity document of RS13).

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `Delay` | Short | always | 20 | Ticks until the next spawn attempt (`spawnDelay`); -1 means "pick a delay at the next tick" |
| `MinSpawnDelay` | Short | always | 200 | Lower bound of the random delay |
| `MaxSpawnDelay` | Short | always | 800 | Upper bound of the random delay |
| `SpawnCount` | Short | always | 4 | Number of attempts per spawn round |
| `MaxNearbyEntities` | Short | always | 6 | Cap of same-class entities near the spawner |
| `RequiredPlayerRange` | Short | always | 16 | Distance within which a living player must be |
| `SpawnRange` | Short | always | 4 | Horizontal spread of the spawn position and radius of the crowd check |
| `SpawnData` | spawn data | when a "next" spawn data is chosen | none (see below) | The entity that the next round spawns |
| `SpawnPotentials` | weighted list of spawn data | always | a list containing the current `SpawnData` (or, when none, the default spawn data) with weight 1 | The pool the next spawn data is drawn from |

Write order: `Delay`, `MinSpawnDelay`, `MaxSpawnDelay`, `SpawnCount`, `MaxNearbyEntities`, `RequiredPlayerRange`, `SpawnRange`, `SpawnData`, `SpawnPotentials`. The write side stores the delay and counters through `putShort`, so values above 32767 wrap. The read side reads the counters as Ints from Short or Int tags alike (the min, max, count, nearby, range and spawn range values with `getIntOr` for all but `Delay`, which uses `getShortOr`). The default spawn data is `{entity: {}}` (an empty entity compound), which cannot spawn anything (step 6 below). The spawner minecart's initial state is the object default (inferred: the constructor builds the spawner with no explicit values).

**Engine (`serverTick`, runs on the server each tick for the cart; the cart's block position stands for the block position).**

1. If no living player is within `RequiredPlayerRange` of the point `(x + 0.5, y + 0.5, z + 0.5)` of the block position, or the level's "spawner blocks enabled" setting is off: stop (the delay does not count down).
2. If `Delay == -1`: choose a new delay (the `delay` procedure, below), then continue. If `Delay > 0` (also after step 2's choice): decrement and stop.
3. `spawned = false`. Take the "next spawn data": the stored `SpawnData`, or if there is none a random pick from `SpawnPotentials` (weighted; the empty result gives the default spawn data), which becomes the stored `SpawnData`.
4. Repeat `SpawnCount` times (attempts):
   1. Decode the entity compound of the spawn data. If it has no valid `id`: run `delay`, stop the whole tick.
   2. Position: if the compound has a `Pos` (a list of 3 doubles), use it. Otherwise `x = bx + (rand01() - rand01()) * SpawnRange + 0.5`, `y = by + nextInt(3) - 1`, `z = bz + (rand01() - rand01()) * SpawnRange + 0.5`, where `rand01()` is `nextDouble` and the draws happen in the order x1, x2, then y, then z1, z2 (a double draw for x, an int draw for y, a double pair for z).
   3. If the spawn box of the entity type at the position (`getSpawnAABB`) collides with anything: this attempt fails (continue with the next attempt).
   4. Rules: if `custom_spawn_rules` is present: a non-friendly mob category fails on Peaceful difficulty; the position must satisfy the block-light and sky-light ranges. Otherwise the standard spawn placement rules for the entity type with the reason `SPAWNER` must pass. A failure ends the attempt.
   5. Create the entity from the compound with the chosen position (the creation processor sets the position and clears the entity id to -1).
   6. Crowd check: count entities of exactly the same class, excluding spectators, inside the box of the block (1 x 1 x 1) inflated by `SpawnRange`. If the count is `>= MaxNearbyEntities`: run `delay` and stop the tick.
   7. Set the entity's yaw to `nextFloat() * 360` and pitch 0 at its position.
   8. If the entity is a `Mob`: when no custom rules are present it must pass the mob's own spawn rules (reason `SPAWNER`); it must pass the spawn obstruction check; and if the spawn data compound has exactly one key and that key is a String `id`, the mob is finalised (`finalizeSpawn`, with difficulty at its block position, reason `SPAWNER`) and the optional `equipment` table is applied. A failure ends the attempt.
   9. Add the entity with its passengers; if that fails: run `delay` and stop the tick.
   10. Level event 2004 at the block, game event `ENTITY_PLACE`, and the mob's spawn animation. `spawned = true`.
5. After the loop, if `spawned`: run `delay`.

**`delay`.** `Delay = MinSpawnDelay` when `MaxSpawnDelay <= MinSpawnDelay`; otherwise `Delay = MinSpawnDelay + nextInt(MaxSpawnDelay - MinSpawnDelay)`. Then, if `SpawnPotentials` is not empty, pick one entry by weight and make it the stored `SpawnData`. Finally broadcast block event 1 (the client restarts the spawn animation).

The client tick only spins the displayed mob and emits smoke and flame particles at a random point of the block while a player is in range.

### 4.6 Command block state (`BaseCommandBlock.save` and `load`) and the executor

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `Command` | String | always | "" | The command text (without the leading slash handling of 16: the executor uses `performPrefixedCommand`) |
| `SuccessCount` | Int | always | 0 | Number of successful command results of the last run |
| `CustomName` | text component | when not null | none (default name used) | Name shown as the command source |
| `TrackOutput` | Boolean | always | true | Whether the last output is remembered |
| `LastOutput` | text component | when `TrackOutput` is true and the output is not null | none | Output text of the last run |
| `UpdateLastExecution` | Boolean | always | true | Whether the executor refuses to run twice in the same game tick |
| `LastExecution` | Long | when `UpdateLastExecution` is true and the value is not -1 | -1 | The game time of the last run |

On read, `LastOutput` is read only when `TrackOutput` is true (otherwise it becomes none) and `LastExecution` only when `UpdateLastExecution` is true (otherwise -1). After loading, the command minecart copies the command and the last output into its synced data.

**Executor (`performCommand`).**

1. If the level's game time equals `LastExecution`: return false (it already ran this tick).
2. If the command equals "Searge" ignoring case: `LastOutput` becomes the literal text `#itzlipofutzli`, `SuccessCount` = 1, return true (a built-in joke command).
3. `SuccessCount = 0`. If command blocks are enabled and the command is not empty: `LastOutput = none`; build the command source (below) and run the command text with the prefixed-command entry of the command manager (16, 15 section "execution"); every result callback with success adds 1 to `SuccessCount`.
4. Set `LastExecution` to the game time when `UpdateLastExecution` is true, else -1. Return true.

The command-block minecart's source is the cart itself: position = cart position, rotation = the cart's rotation, permission = game master, level = the cart's level, entity = the cart. It runs when an activator rail under it is powered: `activateMinecart(..., powered)` runs `performCommand` when `powered` and `tickCount - lastActivated >= 4`, then sets `lastActivated = tickCount` (so at most once per 4 ticks). `lastActivated` is not saved.

## 5. Projectiles

### 5.1 `Projectile` layer (every projectile except `evoker_fangs`, `eye_of_ender`, `end_crystal` which are plain `Entity` subclasses)

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `Owner` | Int Array (entity reference) | when set | none | The shooter |
| `LeftOwner` | Boolean | only when true | false | The projectile has left the owner's collision range, so it can hit the owner now (44 part 8 section 6.1) |
| `HasBeenShot` | Boolean | always | false | Whether the shoot game event was already sent |
| `can_break` | adventure predicate | when not null | none | Blocks this projectile may break in adventure-mode rules (applies to the owner's permission) |

Write order: `Owner`, `LeftOwner` (when true), `HasBeenShot`, `can_break` (when set). `leftOwnerChecked` and `lastDeflectedBy` are runtime state and are not saved.

### 5.2 Hurting projectiles (`AbstractHurtingProjectile`)

Layer keys: `acceleration_power` (Double, always, absent 0.1). It is the per-tick thrust of the constant-thrust motion model (44 part 8 section 6.4). Subclasses:

| Entity | Class | Extra keys | Defaults and notes |
|---|---|---|---|
| `fireball` | `LargeFireball` over `Fireball` | `Item` (Compound item stack, always), `ExplosionPower` (Byte, always) | `Item` absent: the stack `fire_charge`. `ExplosionPower` absent: 1 |
| `small_fireball` | `SmallFireball` over `Fireball` | `Item` | as above; no explosion key |
| `wither_skull` | `WitherSkull` | `dangerous` (Boolean, always) | absent false: whether the skull is the dangerous (blue) variant; its effects are in 21 section 7.2 |
| `dragon_fireball` | `DragonFireball` | none | creates the dragon cloud of 21 section 6.4 on impact |
| `wind_charge`, `breeze_wind_charge` | `WindCharge`, `BreezeWindCharge` over `AbstractWindCharge` | none | The explosion parameters are in 44 part 8 section 8 and 21 section 8.18 |

### 5.3 Thrown item projectiles (`ThrowableItemProjectile`)

Layer key: `Item` (Compound item stack, always written). On read an absent or invalid `Item` becomes a new stack of the class's default item: `snowball` gives `snowball`, `egg` gives `egg`, `ender_pearl` gives `ender_pearl`, `experience_bottle` gives `experience_bottle`, `splash_potion` gives `splash_potion`, `lingering_potion` gives `lingering_potion`. The stack of a potion carries the `potion_contents` and `potion_duration_scale` components used by section 3.6.2. Its motion and hit rules are in 44 part 8 section 6.5 and section 10.

**Ender pearl.** Setting the owner (also at load) removes the pearl from the previous owner's registry and registers it with the new owner when the owner is a server player; removal for any reason except "unloaded with the player" deregisters it. Pearls in flight are therefore saved twice: in the chunk's entity list and, with the extra key `ender_pearl_dimension`, in the owner's `ender_pearls` list (45 part 3 section 3.7).

### 5.4 Arrows (`AbstractArrow` and subclasses)

Write order after the `Projectile` layer:

| Key | NBT type | Written | Absent on read | Meaning |
|---|---|---|---|---|
| `life` | Short | always | 0 | Ticks stuck in a block; the arrow disappears at 1200 (44 part 8 section 7.1) |
| `inBlockState` | block state | when not null | none | The block the arrow is stuck in |
| `shake` | Byte | always | 0 (the value read is masked with 255) | Remaining wobble ticks after sticking |
| `inGround` | Boolean | always | false | Whether the arrow is stuck |
| `pickup` | Byte (pickup legacy) | always | 0 `DISALLOWED` | Who may pick it up. The ordinal map sends a value below 0 or above 3 to 0 and then indexes the 3-constant array, so a stored Byte of exactly 3 indexes outside the array and throws (section 11, question 2) |
| `damage` | Double | always | 2.0 | Base damage (`baseDamage`) |
| `crit` | Boolean | always | false | Critical arrow flag |
| `PierceLevel` | Byte | always | 0 | Entities it can pass through |
| `SoundEvent` | String sound key | always | the class's default hit-ground sound | Sound played on hitting a block: the arrow's `arrow_hit` event for arrows and spectral arrows, the trident-hit-ground event for the trident (read in `getDefaultHitGroundSoundEvent`) |
| `item` | Compound item stack | always | the class's default pickup stack | The stack given back on pickup; also carries the potion for tipped arrows |
| `weapon` | Compound item stack | when not null | none | The bow or crossbow stack that fired it (used by enchantment effects) |

Class defaults of the pickup stack: `arrow` gives `arrow`, `spectral_arrow` gives `spectral_arrow`, `trident` gives `trident`. Subclass keys:

| Entity | Extra keys |
|---|---|
| `arrow` (`Arrow`) | none. Tipping is carried by the `potion_contents` component inside `item`; the synced colour (`ID_EFFECT_COLOR`) is derived, not saved: it is -1 when the stack's potion contents equal the empty value, else the colour of the contents. The colour is recomputed whenever the pickup stack is set, including at load |
| `spectral_arrow` (`SpectralArrow`) | `Duration` (Int, always, absent 200): ticks of the glowing effect applied on hit |
| `trident` (`ThrownTrident`) | `DealtDamage` (Boolean, always, absent false): the trident already hit something and returns to the owner without hitting again. After reading, the loyalty level (`ID_LOYALTY`, synced) is recomputed from the stack's enchantments (the return acceleration, clamped to 0..127, and 0 on a non-server level) and is therefore not saved |

**Potion duration scale of tipped arrows.** The `tipped_arrow` item is registered with `potion_contents` default empty and `potion_duration_scale` default 0.125 (float, read in `Items`), unlike the lingering potion's 0.25 (section 3.6.2). An arrow saved with potion contents carries the scale in the `item` stack's components; a stack without the component takes the 0.125 item default. How the arrow applies the scale on hit is in 44 part 8 (not re-read here).

`inGroundTime` (44 part 8 section 7.1) is not saved. The water drag of arrows is 0.6 and of the trident 0.99 (read in `getWaterInertia`).

### 5.5 Other projectiles

| Entity | Class | Keys after the `Projectile` layer | Notes |
|---|---|---|---|
| `llama_spit` | `LlamaSpit` | none | |
| `shulker_bullet` | `ShulkerBullet` | `Target` (Int Array UUID of the final target, when set), `Dir` (Byte direction legacy id, when not null), `Steps` (Int, always, absent 0), `TXD`, `TYD`, `TZD` (Double, always, absent 0.0) | Written in this order. `Target` is read as an entity reference. `Dir` is the current move direction (absent: none). `Steps` counts the flight steps left before the bullet picks a new axis; `TXD` to `TZD` are the target delta. The pursuit logic is in 21 section 6.2 |
| `firework_rocket` | `FireworkRocketEntity` | `Life` (Int, always, absent 0), `LifeTime` (Int, always, absent 0), `FireworksItem` (Compound item stack, always, absent: a new `firework_rocket` stack), `ShotAtAngle` (Boolean, always, absent false) | `FireworksItem` is the synced item that holds the `fireworks` component (flight duration and explosions); `ShotAtAngle` marks a crossbow shot. A saved `LifeTime` of 0 is read back as 0 (the lifetime is not recomputed at load; Open question 6). The behaviour is in 21 section 8.7 and 17 |
| `fishing_bobber` | `FishingHook` | none; **never saved** | Section 6 |
| `eye_of_ender` | `EyeOfEnder` (plain `Entity`) | `Item` (Compound item stack, always, absent: `ender_eye`) | Flight state is not saved (21 section 8.12) |
| `evoker_fangs` | `EvokerFangs` (plain `Entity`) | `Warmup` (Int, always, absent 0), `Owner` (Int Array entity reference, when set) | No `LeftOwner` or `HasBeenShot`; the owner is the evoker |

## 6. Entities with no keys of their own, and entities that are never saved

| Entity | Reason | Consequence |
|---|---|---|
| `marker` | empty save and read overrides | only the `Entity` layer is saved; the marker carries its information in `data` |
| `lightning_bolt` | registered no-save, empty overrides | Never in a chunk. A world saved while a bolt exists loses it; the bolt lives about a second |
| `fishing_bobber` | registered no-save (also no-summon), empty overrides | Never in a chunk. A hook is removed when its owner leaves or the chunk unloads |
| `llama_spit`, `dragon_fireball`, `wind_charge`, `breeze_wind_charge` | no overrides beyond the base layers of section 5 | `llama_spit` has the projectile layer only; the hurting ones add `acceleration_power` |
| `end_crystal` | its own two keys | section below |
| `boat`, `raft`, plain `minecart` | no keys beyond the layers of section 4 | |

**`end_crystal` (`EndCrystal`, plain `Entity`):** `beam_target` (Int Array block position, when not null; the block the beam points at) and `ShowBottom` (Boolean, always, absent true; whether the bedrock base is drawn). Write order `beam_target`, `ShowBottom`. Fire immune. The fight behaviour is in 21 section 6.3.

## 7. Master table: layers per entity type

"E" is the `Entity` base layer of part 1. The keys of each layer are in the section named in the last column.

| Entity type key | Layers, in order | Section |
|---|---|---|
| `item` | E, item | 3.1 |
| `experience_orb` | E, orb | 3.2 |
| `falling_block` | E, falling block | 3.3 |
| `tnt` | E, tnt | 3.4 |
| `ominous_item_spawner` | E, spawner item | 3.5 |
| `area_effect_cloud` | E, cloud | 3.6 |
| `marker` | E | 3.7 |
| `interaction` | E, interaction | 3.8 |
| `text_display` | E, Display, text | 3.9, 3.9.1 |
| `item_display` | E, Display, item | 3.9, 3.9.2 |
| `block_display` | E, Display, block | 3.9, 3.9.3 |
| the 10 boat types and `bamboo_raft` | E, leash | 4.1 |
| the 10 chest boat types and `bamboo_chest_raft` | E, leash, chest vehicle data | 4.1, 4.2 |
| `minecart` | E, minecart common | 4.3 |
| `chest_minecart` | E, minecart common, chest vehicle data | 4.3, 4.2 |
| `hopper_minecart` | E, minecart common, chest vehicle data, `Enabled` | 4.4 |
| `furnace_minecart` | E, minecart common, `PushX`, `PushZ`, `Fuel` | 4.4 |
| `tnt_minecart` | E, minecart common, `fuse`, `explosion_power`, `explosion_speed_factor` | 4.4 |
| `spawner_minecart` | E, minecart common, spawner state | 4.5 |
| `command_block_minecart` | E, minecart common, command block state | 4.6 |
| `end_crystal` | E, `beam_target`, `ShowBottom` | 6 |
| `lightning_bolt`, `fishing_bobber` | not saved | 6 |
| `evoker_fangs` | E, `Warmup`, `Owner` | 5.5 |
| `llama_spit` | E, projectile | 5.1 |
| `shulker_bullet` | E, projectile, shulker bullet | 5.5 |
| `eye_of_ender` | E, `Item` | 5.5 |
| `firework_rocket` | E, projectile, firework | 5.5 |
| `arrow` | E, projectile, arrow | 5.1, 5.4 |
| `spectral_arrow` | E, projectile, arrow, `Duration` | 5.4 |
| `trident` | E, projectile, arrow, `DealtDamage` | 5.4 |
| `snowball`, `egg`, `ender_pearl`, `experience_bottle`, `splash_potion`, `lingering_potion` | E, projectile, `Item` | 5.3 |
| `fireball` | E, projectile, hurting, `Item`, `ExplosionPower` | 5.2 |
| `small_fireball` | E, projectile, hurting, `Item` | 5.2 |
| `wither_skull` | E, projectile, hurting, `dangerous` | 5.2 |
| `dragon_fireball`, `wind_charge`, `breeze_wind_charge` | E, projectile, hurting | 5.2 |

## 8. Naming differences and corrections to other documents

| Name or claim as it may be expected (older versions, other documents) | What 26.3 does |
|---|---|
| `Type` on boats | No such key. Boats, rafts and chest variants are 22 entity types; the wood is the type |
| `Cancellable` on `falling_block` | The key is `CancelDrop` |
| `fuse`, `block_state`, `explosion_power` on `tnt` | Correct; the owner key is lower case `owner`; `explosion_power` is omitted at 4.0 |
| `effects`, `particle`, `Color`, `Potion` on `area_effect_cloud` | Replaced by `potion_contents` (with `custom_effects`), `custom_particle` and `potion_duration_scale`; `Age` is the tick count |
| `data` on `marker` | The marker has no keys; `data` is the `Entity` base key of part 1 |
| `potion colour` on arrows | Not saved; derived from the stack in `item` |
| `item` / `weapon` on arrows, `pickup`, `life`, `shake`, `inGround`, `crit`, `damage`, `SoundEvent` | Correct. Extra keys read: `inBlockState`, `PierceLevel`. The key `PierceLevel` (not `pierce_level` as 44 part 8 section 7.1 states) is the written name |
| Projectile base `Owner`, `LeftOwner`, `HasBeenShot` | Correct, plus `can_break` (new). `LeftOwner` is written only when true |
| Minecart `TNTFuse` | The key is `fuse` (plus `explosion_power`, `explosion_speed_factor`) |
| Command block minecart `Command`, `LastOutput`, `TrackOutput`, `SuccessCount` | Correct, plus `CustomName`, `UpdateLastExecution`, `LastExecution` |
| Hopper minecart `Enabled`, furnace `Fuel`, `PushX`, `PushZ` | Correct |
| `Items`, `LootTable` on chest vehicles | Correct, plus `LootTableSeed`; `Items` is not written next to a loot table |
| 45 part 7 section 11, `falling_block`: "`FallHurtAmount` Float (read default not read)" | The read default is 0.0 |
| 45 part 7 section 11, `text_display`: "`text_opacity` (written as a byte-range value)" | A Byte, absent value -1 |
| 44 part 8 section 7.1 "`inGroundTime`" among saved fields | It is not saved |
| Older block state keys `Name`/`Properties` | 26.3 block state compounds use `id` and `properties`, and a default state is a bare String |

## 9. Worked examples

Each example lists the top-level keys after the `Entity` layer of part 1. Types follow section 1.

**9.1 A dropped dirt stack, 40 ticks old, 3 items.** `Health` Short 5, `Age` Short 40, `PickupDelay` Short 10, `Thrower` and `Owner` absent, `Item` `{id: "minecraft:dirt", count: 3}` (the `components` key is absent when there are no component changes). Reading it back gives the same values. An `Item` key `{id: "minecraft:dirt", count: 0}` fails the 1..99 range, the stack is empty and the entity is discarded.

**9.2 Falling gravel.** `BlockState` `"minecraft:gravel"` (the default state, a bare String), `Time` Int 12, `DropItem` true, `HurtEntities` false, `FallHurtAmount` Float 0.0, `FallHurtMax` Int 40, `CancelDrop` false; no `TileEntityData`. An anvil that was dropped from a dispenser writes `BlockState` as `{id: "minecraft:anvil", properties: {facing: "east"}}` and reads `HurtEntities` default true when the key is absent.

**9.3 Primed TNT.** Fresh: `fuse` Short 80, `block_state` `"minecraft:tnt"` (the default state of the TNT block is written as a bare String; a state with non-default properties, for example the TNT block's boolean `unstable` property (a boolean block property named `UNSTABLE` in the block class, read), would be a compound `{id, properties: {unstable: "true"}}`), no `explosion_power`, no `owner`. With owner and a power of 6: `explosion_power` Float 6.0 and `owner` the 4-int array of the igniter's UUID. A saved `explosion_power` of 500 is read as 128.

**9.4 Lingering potion cloud (section 3.6.2).** `Age` 0, `Duration` 600, `WaitTime` 10, `ReapplicationDelay` 20, `DurationOnUse` 0, `RadiusOnUse` -0.5, `RadiusPerTick` -0.005, `Radius` 3.0, `Owner` the thrower, `potion_contents` `{potion: "minecraft:..."}` from the stack; `potion_duration_scale` is 0.25: the default `lingering_potion` item carries that component (float 0.25 in the item registration, 17 section 3.15) and the cloud copies it, so a normal lingering cloud writes 0.25 (only a scale of exactly 1.0 is omitted). The `tipped_arrow` default differs (0.125, section 5.4). The dragon's cloud also uses 0.25 (21 section 6.4).

**9.5 Cloud timing.** `Radius` 3.0, `RadiusPerTick` -0.005, `WaitTime` 10, no victims: the radius after the tick at `t = 10` is 2.995 (float 2.995); at `t = 100` (91 shrinking ticks) it is 2.5449896 (float accumulation); it first drops below 0.5 at the 500th shrinking tick (0.49998), which is `t = 509` with the numbering read in 3.6.1, and the cloud is discarded then.

**9.6 Tipped arrow stuck in a block.** `Owner` the shooter, `HasBeenShot` true, `life` Short 20, `inBlockState` the block, `shake` Byte 5, `inGround` true, `pickup` Byte 1, `damage` Double 2.0, `crit` false, `PierceLevel` Byte 0, `SoundEvent` the arrow-hit key, `item` `{id: "minecraft:tipped_arrow", count: 1, components: {potion_contents: ...}}`, `weapon` `{id: "minecraft:bow", ...}`. After loading, the synced colour equals the colour of the contents in `item`.

**9.7 Chest minecart with an unopened loot table.** After the common layer (`DisplayState` absent, `DisplayOffset` absent, `FlippedRotation` false, `HasTicked` true): `LootTable` `"minecraft:chests/..."` and `LootTableSeed` Long 0 is omitted (seed 0), and no `Items`. After the player opens it the loot table is cleared and the next save contains `Items` with the generated stacks.

**9.8 Furnace minecart.** `PushX` 0.5, `PushZ` 0.0, `Fuel` Short 3600 (one fuel item, 3600 ticks). After 3600 server ticks `Fuel` is 0, the push resets to zero and the lit state clears.

**9.9 Spawner minecart defaults.** `Delay` 20, `MinSpawnDelay` 200, `MaxSpawnDelay` 800, `SpawnCount` 4, `MaxNearbyEntities` 6, `RequiredPlayerRange` 16, `SpawnRange` 4, `SpawnPotentials` a list of one entry with `weight` 1 (the entry's `data` is `{entity: {}}` unless set by a command). With `SpawnData {entity: {id: "minecraft:zombie"}}` the zombie is finalised on spawn (one key, `id`); with `{entity: {id: ..., Health: ...}}` it is not.

**9.10 Text display.** A display with text "Hi" aligned left, shadow on: `transformation` `{translation: [0,0,0], left_rotation: [0,0,0,1], scale: [1,1,1], right_rotation: [0,0,0,1]}`, `billboard` `"fixed"`, `interpolation_duration` 0, `teleport_duration` 0, `view_range` 1.0, `shadow_radius` 0.0, `shadow_strength` 1.0, `width` 0.0, `height` 0.0, `glow_color_override` -1; no `brightness`; `text` as the component, `line_width` 200, `background` 1073741824, `text_opacity` Byte -1, `shadow` true, `see_through` false, `default_background` false, `alignment` `"left"`. The flags byte after reading is `1 + 8 = 9`.

## 10. Validation

Each case is a test an implementer can write from the text above.

1. Round trip a default `item` entity: the saved keys are exactly `Health` 5, `Age` 0, `PickupDelay` 0, `Item` (no `Thrower`, no `Owner`).
2. An item compound whose `Item` is absent loads an empty stack and the entity is discarded.
3. A `falling_block` with `BlockState` an anvil and no `HurtEntities` loads with `HurtEntities` true; with a sand block state and no key it loads false.
4. A `tnt` with `explosion_power` 500 loads 128.0; with -3 loads 0.0; a `tnt` with power 4.0 saves no `explosion_power`.
5. A cloud with `Radius` 40 saved in a file loads with radius 32.0 (the setter clamp applies on read as well, since the read calls the setter).
6. Cloud simulation with `WaitTime` 20 and `Duration` 100: nothing is applied before tick 20; at `t = 120` the cloud is discarded; victims are only evaluated when `t mod 5 = 0`.
7. Two entities in a cloud with `ReapplicationDelay` 20, `Radius` 3: each is affected once; the next application of the same entity is at the first `t mod 5 = 0` with `t >= first + 20`.
8. A cloud with `RadiusOnUse -0.5` and radius 1.0 that has three eligible entities in one pass: after the first the radius is 0.5 (not below 0.5, kept), after the second it would be 0.0 (below 0.5), so the cloud is discarded and the third entity is not affected.
9. A chest boat saved with both `LootTable` and `Items` loads without the items.
10. A hopper minecart without `Enabled` loads enabled.
11. A furnace minecart loaded from hand-edited NBT with `Fuel` 40000 (unreachable in play, section 4.4) saves the Short value 40000 truncated to 16 bits (-25536).
12. A block state compound with a missing property loads the default value for it; the default state is written as a bare String, and any non-default state writes every property.
13. A UUID round trip: the UUID `00112233-4455-6677-8899-aabbccddeeff` is written as `[0x00112233, 0x44556677, 0x8899aabb, 0xccddeeff]` as signed ints.
14. A `text_display` with both alignment bits set in a hand-built flags byte reads back as left (bit 8 tested first).
15. Entities `lightning_bolt` and `fishing_bobber` never produce a compound in the chunk entity list.
16. A spawner round with `SpawnCount` 4 where the second attempt hits the crowd limit performs no further attempts, spawns nothing more and runs `delay`.
17. A command block minecart ran at game time 100 with `UpdateLastExecution` true: a second call in the same tick returns false; an activator signal at `tickCount - lastActivated < 4` does nothing.

## 11. Open questions

1. The text component codec (`ComponentSerialization.CODEC`) used by `text`, `CustomName` and `LastOutput` was not read in this round; its string, compound and list forms are assumed to be specified by the document that owns text components (45 part 1 or 15), and are not specified here.
2. `AbstractArrow$Pickup.byOrdinal` (resolved): a value below 0 or above 3 becomes 0; the array has 3 constants (ordinals 0 to 2), so a saved `pickup` Byte of exactly 3 indexes outside the array and throws an out-of-bounds exception. The legacy codec is a plain byte codec with a mapping function, not a flat-map, so the exception is not converted into a decode error (read from the codec construction). What the surrounding loader does with an uncaught exception was not traced.
3. The unit of `angle` in the axis-angle alternative (radians) is inferred from the library type, not read. The x, y, z, w order and the normalisation of the list form were read (section 2).
4. The `Direction` legacy codec's functions are inferred to be the 3D data value accessors (method references with no lambda body to read).
5. In the cloud tick (step 8) the stream predicate that decides whether a potion effect list can affect an entity was not disassembled; "can be affected" is inferred.
6. `firework_rocket` `LifeTime` is read as saved. How a freshly shot rocket computes its lifetime (flight duration and random addition) is in 21 section 8.7 and was not re-read here; a loaded rocket with `LifeTime` 0 is expected to explode at once (inferred).
7. The block spawner (the block entity) uses the same save and engine; its other keys, the "spawner blocks enabled" level setting and the client event 1 handling were not read here (RS13).
8. `Value` (orb), `Fuel` (furnace minecart), `Age` (item), `Health` and the spawner counters are written with a 16-bit truncation; the read side also reads 16-bit values (with sign extension for `getShortOr`, inferred from the `I` return). Values above 32767 therefore wrap to negative on reload; no code in the artifact clamps them.
9. The component schemas inside an item stack's `components` (for example `potion_contents`, `fireworks`, `enchantments`) are in the data and in 17; they were not enumerated here.
10. The `custom_spawn_rules` validity check (`isValidPosition`) and the equipment table were not disassembled; only their key names and the call points are stated.
11. `ThrownEnderpearl` has chunk-ticket or cross-dimension handling (it overrides `teleport`, `canTeleport`, `onRemoval`) that was read only for the owner registration; the dimension-change behaviour is not specified here.
12. `AbstractMinecart.HasTicked` is saved and read but its use in the new minecart behaviour (experimental pack) was not read.
13. (Closed) The spawner class constants were read: `DEFAULT_SPAWN_DELAY` 20, `DEFAULT_MIN_SPAWN_DELAY` 200, `DEFAULT_MAX_SPAWN_DELAY` 800, `DEFAULT_SPAWN_COUNT` 4, `DEFAULT_MAX_NEARBY_ENTITIES` 6, `DEFAULT_REQUIRED_PLAYER_RANGE` 16 and `DEFAULT_SPAWN_RANGE` 4, equal to the read defaults; the default spawn data is an empty compound with empty optionals, which gives `{entity: {}}`. Whether the field initialisers use these constants was not disassembled (inferred from the names).
