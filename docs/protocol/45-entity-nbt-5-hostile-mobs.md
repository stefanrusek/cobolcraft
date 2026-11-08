# 45 — Entity NBT, part 5: hostile mobs (round RS27)

| Item | Value |
|---|---|
| Covers | The on-disk NBT keys that each hostile-mob class adds on top of the shared entity, living-entity and mob keys: zombie, husk, drowned, zombie villager, zombified piglin, skeleton, stray, bogged, parched, wither skeleton, spider, cave spider, creeper, enderman, endermite, silverfish, slime, magma cube, sulfur cube, ghast, blaze, phantom, giant, vex, witch, shulker, guardian, elder guardian, warden, breeze, creaking, ravager (base-class sense), zoglin, hoglin. For each key: NBT type, default on load, clamp or validation, and what the field drives. Also the serialisable brain memories of warden, breeze, creaking, hoglin and zoglin, the warden anger table and spawn tracker, the generic conversion timer used by the zombie family and the skeleton, the zombie villager cure timer, the hoglin zombification timer, and the embedded codecs these classes use (entity reference, block state, villager data, gossip, merchant offer, item stack). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Every key name, default, constant and ordering below was read from the `addAdditionalSaveData` / `readAdditionalSaveData` pair of the class named in the section (the 26.3 `ValueOutput` / `ValueInput` form), from the codec it names, or from the tick code that consumes the field. Anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Data versus code | Per the operator decisions (design README Part 0, rule R7), no data row is tabulated: loot tables, tags (`speeds_up_zombie_villager_curing`, ...), registry JSON and environment-attribute values (`piglins_zombify`) are data the extraction tool supplies. This document specifies the schema, the defaults and the engines that read them. |
| Not covered here | Keys of `Entity`, `LivingEntity`, `Mob`, `PathfinderMob` (specified in [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) section 5 for `Entity` and [45-2](45-entity-nbt-2-living-entity-mob-animal.md) sections 2 to 4 for `LivingEntity`, `Mob`, `AgeableMob` and `Animal`; section 1 only names them), the `Player` and `ServerPlayer` files ([45-3](45-entity-nbt-3-player-and-player-data.md); the one key needed from it, `warden_spawn_tracker`, is specified there in section 6.3 and its engine here in 7.3), illagers, piglins, villagers and the full trade, gossip and villager-data schemas ([45-6](45-entity-nbt-6-villagers-illagers-piglins.md) sections 4 to 6, 11 and 13; section 9 here repeats only the parts the zombie villager needs), animals ([45-2](45-entity-nbt-2-living-entity-mob-animal.md) section 4, 45-4), aquatic and miscellaneous mobs (45-7), vehicles, projectiles and items (45-8), vehicles and projectiles. Mob behaviour is in [20](20-mobs-overworld-hostile.md), [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) and the 44 series; behaviour is repeated here only where a saved field cannot be understood without it. |
| Related | The shared Brain serialisation model [45-2](45-entity-nbt-2-living-entity-mob-animal.md) section 8 (7.1 here lists the memories of this part's mobs); `NeutralMob` helper [45-2](45-entity-nbt-2-living-entity-mob-animal.md) section 7; NBT tag types and `entities/` storage [07](07-nbt-and-anvil.md) §1, §8, §9.3 (this document is the per-type content of the `Entities` list entries of 07 §9.3 for the mobs above); block-state compound form [07](07-nbt-and-anvil.md) §7.3; mob framework [18](18-mob-framework.md); warden and sulfur cube behaviour [44-5](44-residual-mob-questions-5-overworld-hostile.md); villager side of conversion [44-3](44-residual-mob-questions-3-villagers-poi-raids.md); nether mobs [44-6](44-residual-mob-questions-6-nether.md) |

Reading guide. Section 2 gives the read and write conventions that hold for every key. Section 3 lists the inheritance chain of every type, so an implementer knows which tables apply. Sections 4 to 6 give the key tables (shared mid-level classes first, then each mob). Section 7 is brain, warden and vibration state. Section 8 is the engines behind the saved timers. Section 9 is the embedded codecs. Section 10 is the load-time validation rules, section 11 the worked examples, section 12 a per-type summary matrix.

---

## 1. Where the shared keys come from (names only)

The first compound level of every mob is written by the chain `Entity` → `LivingEntity` → `Mob` → (`PathfinderMob` → `AgeableMob` → `Animal` for some types) → the class itself. The key names found at the top of that chain are listed to say where this document starts. Their types, defaults and meaning belong to [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) (section 5, `Entity`) and [45-2](45-entity-nbt-2-living-entity-mob-animal.md) (sections 2 and 3, `LivingEntity` and `Mob`) and are not repeated.

| Class | Key names written (read in this round, semantics out of scope) |
|---|---|
| `LivingEntity` | `Health`, `HurtTime`, `DeathTime`, `AbsorptionAmount`, `current_impulse_context_reset_grace_time`, `current_explosion_impact_pos`, `attributes`, `active_effects`, `FallFlying`, `sleeping_pos`, `Brain`, `last_hurt_by_player`, `last_hurt_by_player_memory_time`, `last_hurt_by_mob`, `ticks_since_last_hurt_by_mob`, `equipment`, `locator_bar_icon` |
| `Mob` | `CanPickUpLoot`, `PersistenceRequired`, `drop_chances`, leash data, `home_radius`, `home_pos`, `LeftHanded`, `DeathLootTable`, `DeathLootTableSeed`, `NoAI` |

`Brain` is the one shared key this document needs: its content for the mobs of this part is 7.1. `home_pos` matters for the creaking (6.5). The `equipment` compound also carries the item a sulfur cube has swallowed (6.3).

---

## 2. Read and write conventions (apply to every table)

Read from `TagValueOutput`, `TagValueInput` and `CompoundTag`:

| Rule | Detail |
|---|---|
| Boolean | Written as a Byte tag, 1 for true and 0 for false. Read as `byteValue != 0` of any numeric tag. |
| Numbers are read leniently | `getIntOr`, `getByteOr`, `getShortOr`, `getLongOr` accept any numeric tag type (Byte, Short, Int, Long, Float, Double) and convert it with the Java narrowing of the target type. A missing key or a non-numeric tag gives the default. The tables state the type that is written; a reader must accept any numeric type. |
| `getXOr(key, default)` | The default applies when the key is absent or not numeric. No read of this part fails: a mob with an empty compound loads with the defaults in the tables. |
| `store(key, codec, value)` | Writes the value with the codec under the key. |
| `storeNullable(key, codec, value)` | Writes the key only when the value is non-null. A null field leaves the key out (it is not written as empty). |
| `read(key, codec)` | Returns an optional. A missing key, or a value the codec rejects, gives an empty optional; every caller below then applies its own default through `orElse`, `orElseGet` or an `ifPresent` that does nothing (inferred: a rejected value is treated like a missing one; the log behaviour was not read). |
| UUID (`UUIDUtil.CODEC`) | Int Array of 4, most significant 32 bits first (same form as 07 §9.2). |
| `BlockPos` (`BlockPos.CODEC`) | Int Array `[x, y, z]` (`INT_STREAM` codec; length 3 inferred). |
| `Vec3` (`Vec3.CODEC`) | List of Double (length 3 inferred). |
| Block state (`BlockState.CODEC`) | The compound of 07 §7.3 (`id`, optional `properties`). |
| Entity reference (`EntityReference.store` / `.read`) | The key holds a UUID in the Int Array form above. A missing or invalid value reads as no reference. The target is looked up by UUID later; a reference to an entity that is not loaded is kept as a bare UUID. |
| Order | Each class writes the superclass first and its own keys after, except where a section says the read order differs (cube mobs, sulfur cube, zombie villager). A compound is unordered, so order on write matters only for key collisions (6.5). |

---

## 3. Inheritance chain and key sources

Each entry lists the classes whose `addAdditionalSaveData` / `readAdditionalSaveData` apply after the shared chain of section 1. "Section" is where the keys are given.

| Entity type | Class chain after `Mob` | Own keys (section) |
|---|---|---|
| zombie | `PathfinderMob` → `Monster` → `Zombie` | `IsBaby`, `CanBreakDoors`, `InWaterTime`, `DrownedConversionTime` (4.1) |
| husk | `Zombie` | none of its own; the conversion timer targets zombie (8.1) |
| drowned | `Zombie` | none; `convertsInWater` is false so the timer never runs, but the two timer keys are still written (4.1) |
| zombie_villager | `Zombie` → `ZombieVillager` | the `Zombie` keys plus `VillagerData`, `VillagerDataFinalized`, `Offers`, `Gossips`, `ConversionTime`, `ConversionPlayer`, `Xp` (4.2) |
| zombified_piglin | `Zombie` → `ZombifiedPiglin` | the `Zombie` keys plus `anger_end_time`, `angry_at` (4.3, 4.10) |
| skeleton | `Monster` → `AbstractSkeleton` → `Skeleton` | `FreezingTime`, `StrayConversionTime` (4.4) |
| stray, parched, wither_skeleton | `AbstractSkeleton` | none |
| bogged | `AbstractSkeleton` → `Bogged` | `sheared` (4.5) |
| spider, cave_spider, silverfish, blaze, giant, guardian, elder_guardian, breeze | `Monster` (guardian classes and breeze have no override) | none |
| creeper | `Monster` → `Creeper` | `powered`, `Fuse`, `ExplosionRadius`, `ignited` (5.1) |
| enderman | `Monster` → `Enderman` | `carriedBlockState`, `anger_end_time`, `angry_at` (5.2) |
| endermite | `Monster` → `Endermite` | `Lifetime` (5.3) |
| ghast | `Mob` → `Ghast` | `ExplosionPower` (5.4) |
| phantom | `Mob` → `Phantom` | `anchor_pos`, `size` (5.5) |
| vex | `Monster` → `Vex` | `bound_pos`, `life_ticks`, `owner` (5.6) |
| shulker | `PathfinderMob` → `AbstractGolem` → `Shulker` | `AttachFace`, `Peek`, `Color` (5.7) |
| slime, magma_cube | `PathfinderMob` → `AgeableMob` → `AbstractCubeMob` | `Size`, `wasOnGround`; the `AgeableMob` keys are skipped because `canBeABaby` is false (6.1) |
| sulfur_cube | `AgeableMob` → `AbstractCubeMob` → `SulfurCube` | `Size`, `wasOnGround`, `Age`, `ForcedAge`, `AgeLocked`, `pickup_timer`, `from_bucket`, `fuse` (6.3) |
| witch | `PathfinderMob` → `PatrollingMonster` → `Raider` | `patrol_target`, `PatrolLeader`, `Patrolling`, `Wave`, `CanJoinRaid`, `RaidId` (4.6, 4.7) |
| ravager | `PatrollingMonster` → `Raider` → `Ravager` | the witch keys plus `AttackTick`, `StunTick`, `RoarTick` (6.6) |
| warden | `Monster` → `Warden` | `anger`, `listener` (6.4) |
| creaking | `Monster` → `Creaking` | `home_pos` (6.5) |
| zoglin | `Monster` → `Zoglin` | `IsBaby` (6.7) |
| hoglin | `AgeableMob` → `Animal` → `Hoglin` | `Age`, `ForcedAge`, `AgeLocked`, `InLove`, `LoveCause`, `IsImmuneToZombification`, `TimeInOverworld`, `CannotBeHunted` (4.8, 4.9, 6.8) |

"No own keys" was established by finding no override of either save method in the class and reading the parent that applies. The `Brain` compound is written for every type (7.1).

---

## 4. Shared mid-level classes

### 4.1 `Zombie` (zombie, husk, drowned, zombie villager, zombified piglin)

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `IsBaby` | Byte (boolean) | false | Read calls `setBaby`, which sets the synched baby flag and, on the server, re-adds the transient speed modifier named `baby` (operation add-multiplied-base, amount 0.5; removed first if present). The modifier is never saved. |
| `CanBreakDoors` | Byte (boolean) | false | Read calls `setCanBreakDoors`. The setter acts only when the path navigation can navigate ground: it then switches the navigator's door-opening ability and adds or removes the break-door goal at goal priority 1 (the `addGoal` call in `setCanBreakDoors` passes the constant 1; read). When the navigator cannot navigate ground, a request to set true does nothing, and a flag that is already true is cleared and the goal removed. Otherwise the flag stays false. |
| `InWaterTime` | Int | 0 | The `afflictionTime` of the conversion tracker (8.1). Written as `afflictionTime` when the mob's eyes are in water at the moment of saving, otherwise as `-1`. |
| `DrownedConversionTime` | Int | -1 | The `conversionTime` of the tracker (8.1): remaining ticks while converting, otherwise `-1`. On read, a value other than `-1` calls `startConversion(value)` (converting flag on, remaining time set); `-1` clears the flag. |

Order on write: `Monster` keys, `IsBaby`, `CanBreakDoors`, then the tracker pair.

Husk and drowned reuse these tag names. A converting husk carries `DrownedConversionTime` although it becomes a zombie. A drowned never ticks the tracker (`convertsInWater` is false), yet its two keys are written and read like any zombie's.

### 4.2 `ZombieVillager`

All `Zombie` keys (4.1) apply, then:

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `VillagerData` | Compound `{type, profession, level}` (9.1), `store` | see the read rule below | The villager data carried over to the cured villager. |
| `VillagerDataFinalized` | Byte (boolean) | false | Whether the villager type has been finalised from the biome at spawn. |
| `Offers` | Compound `{Recipes: [offer...]}` (9.3), `storeNullable` | null | The trades carried over. An absent or invalid value reads as null. |
| `Gossips` | List of gossip entries (9.4), `storeNullable` | null | Carried over. |
| `ConversionTime` | Int | -1 | Remaining cure ticks while curing, else `-1`. A value other than `-1` calls `startConverting(player, value)` (8.2); `-1` clears the converting flag and sets the remaining time to `-1`. |
| `ConversionPlayer` | UUID, `storeNullable` | null | The player who started the cure. Second argument of `startConverting`. |
| `Xp` | Int | 0 | Villager experience carried over. |

Read order: `Zombie` keys; then `VillagerData` is read (kept aside); then `VillagerDataFinalized`; then, **only when** `VillagerDataFinalized` is true **or** the `VillagerData` key decoded, the finalised flag is set to true and the synched villager data becomes the decoded value, or, when it did not decode, a fresh `initializeZombieVillagerData(random)` value (read: it starts from `Villager.createDefaultVillagerData()` and, when the profession registry yields an entry, replaces the profession with one drawn by `DefaultedRegistry.getRandom`; the draw is over the whole registry, so it can also pick the `none` profession). When neither holds, the villager data is left as the constructor made it and the flag stays false (a later `finalizeSpawn` picks the type from the biome). Then `Offers`, `Gossips`, `ConversionTime` with `ConversionPlayer`, and `Xp`.

### 4.3 `ZombifiedPiglin`

All `Zombie` keys, then the persistent anger pair of 4.10: `anger_end_time` and `angry_at`.

### 4.4 `Skeleton`

`AbstractSkeleton` writes no key; on read it reassesses the weapon goal after the parent read (the bow or melee goal follows the main-hand item loaded from `equipment`). `Skeleton` adds the conversion tracker pair:

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `FreezingTime` | Int | 0 | Ticks spent in powder snow (8.1). Written as the affliction time while the skeleton is in powder snow, `-1` otherwise. |
| `StrayConversionTime` | Int | -1 | Remaining ticks of the shaking phase that ends in conversion to a stray; `-1` when not converting (8.1). |

The skeleton's tracker ticks on every server tick (no water gate). Parameters are in 8.1.

### 4.5 `Bogged`

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `sheared` | Byte (boolean) | false | Whether the mushrooms have been sheared. Read calls `setSheared`. |

### 4.6 `PatrollingMonster` (parent of `Raider`, so of witch and ravager)

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `patrol_target` | `BlockPos`, `storeNullable` | null | The patrol destination. |
| `PatrolLeader` | Byte (boolean) | false | Whether this mob leads its patrol. |
| `Patrolling` | Byte (boolean) | false | Whether the patrol is active. |

### 4.7 `Raider` (parent of witch and ravager)

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `Wave` | Int | 0 | The raid wave this raider belongs to. |
| `CanJoinRaid` | Byte (boolean) | false | Whether the mob may be recruited into a raid. |
| `RaidId` | Int | none | Written only when the raider has a raid, the level is a server level and the raid registry knows its id. On read, a present `RaidId` on a server level is looked up and the raider is attached to that raid by the raid code (raid code: see 44-3); a raid that no longer exists leaves the raider without one. |

A witch has no key of its own: its saved state is the `Raider` and `PatrollingMonster` keys. Its drinking state and potion timers are not saved.

### 4.8 `AgeableMob` (hoglin, sulfur cube)

Written and read only when `canBeABaby()` is true. The default of `canBeABaby()` is true; `Slime` and `MagmaCube` override it to false, so those two never write or read these keys.

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `Age` | Int | 0 | Growth timer. Negative means baby and counts up to 0. Read calls `setAge`, which updates the synched baby flag (baby when below 0) and calls `ageBoundaryReached` on crossing the boundary. |
| `ForcedAge` | Int | 0 | The pending forced-age amount. |
| `AgeLocked` | Byte (boolean) | false | Growth is frozen. Read calls `setAgeLocked`. |

### 4.9 `Animal` (hoglin)

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `InLove` | Int | 0 | Remaining love ticks. |
| `LoveCause` | UUID reference (section 2), written only when non-null | none | The player who fed the animal. |

### 4.10 `NeutralMob` persistent anger (enderman, zombified piglin)

Both classes call `addPersistentAngerSaveData` / `readPersistentAngerSaveData`:

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `anger_end_time` | Long | see below | Game time (ticks) at which the anger ends. Always written. |
| `angry_at` | UUID, `storeNullable` | none | The persistent anger target. |

Read, in order:

1. If `anger_end_time` is present, the end time becomes that value.
2. Otherwise, if the legacy key `AngerTime` (Int, remaining ticks) is present, the end time becomes `gameTime + AngerTime`.
3. Otherwise the end time becomes `-1`.
4. If the level is not a server level, stop.
5. `angry_at` is read as an entity reference and set as the persistent target, and the live target is set to that entity if it is loaded (null when not loaded).

A mob created without a tag has end time 0 (neither constructor sets it; inferred from the absence of a store in the constructors), so a never-angered mob writes `anger_end_time: 0L`. `isAngry` is true only when the end time is greater than 0 and greater than the current game time. `stopBeingAngry` clears the last-hurt-by, the persistent target and the live target and sets the end time to `-1`.

Neutral-mob anger update (what a saved `anger_end_time` and `angry_at` are later interpreted by; read from `NeutralMob.updatePersistentAnger` and `isAngryAt`, specified with the mob framework in [18](18-mob-framework.md) section 4.8 and [45-2](45-entity-nbt-2-living-entity-mob-animal.md) section 7): the update calls `stopBeingAngry` when the anger target is dead or dying and is a mob, when the mob is no longer angry (end time reached) and is not tracking a valid player target, when the anger target is a creative or spectator player, or when the level difficulty is peaceful (a player target is valid only when it is neither creative nor spectator and the difficulty is not peaceful). So a saved anger whose `angry_at` player is now in creative or spectator mode, or on a peaceful world, is cleared on the first update after load. A saved `angry_at` that resolves to no loaded entity leaves the live target null until the entity is found (step 5 above); `anger_end_time` still counts down in game time. The 20 to 39 second duration below is sampled by each type's `startPersistentAngerTimer`, which `updatePersistentAnger` calls when the mob acquires a new target; the saved end time is never resampled on load.

Anger duration: both types set `anger_end_time = gameTime + sample` with `sample` uniform over `20 * 20` to `39 * 20` ticks (`TimeUtil.rangeOfSeconds(20, 39)` multiplies both bounds by 20; the inclusive upper bound is the `UniformInt` convention, inferred).

---

## 5. Mobs with their own keys (monster family)

### 5.1 Creeper

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `powered` | Byte (boolean) | false | Charged creeper. Read sets the synched powered flag directly. |
| `Fuse` | Short | 30 | `maxSwell`, the swell ticks needed to explode. Written as `(short) maxSwell`; read as a short, stored as an int. |
| `ExplosionRadius` | Byte | 3 | Explosion radius multiplier. Written as `(byte) explosionRadius`. |
| `ignited` | Byte (boolean) | false | The fuse has been lit by flint and steel. On read, true calls `ignite()` (sets the synched ignited flag). |

A new creeper (no tag) has `maxSwell = 30` and `explosionRadius = 3`.

Not saved: the current `swell` counter. After a load the swell is 0 even for an ignited creeper, so the fuse starts over. Each tick of a living creeper: the previous swell is remembered; if `ignited`, the swell direction is forced to +1; when the direction is positive and the swell is 0, the primed sound plays (volume 1.0, pitch 0.5) and the `prime_fuse` game event fires; the swell increases by the direction, is clamped below at 0, and at `swell >= maxSwell` it is set to `maxSwell` and the creeper explodes. The explosion test does not depend on the direction: with a stored `Fuse` of 0 or below the test `0 >= maxSwell` already holds on the first living tick, so the creeper explodes on that tick even with the default direction -1, with no ignition and no approaching player (read from the tick body; see section 10).

Explosion: a server-level explosion at the creeper's position with radius `factor * explosionRadius`, `factor` 2.0 when powered and 1.0 otherwise, interaction type `mob`. Then the lingering cloud is spawned, death-triggered effects run (removal reason killed) and the creeper is discarded. Block damage and knockback are the explosion algorithm of 20 §6.2.

### 5.2 Enderman

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `carriedBlockState` | Block state compound (07 §7.3), written only when a block is carried | none | The block in the enderman's hands. |
| `anger_end_time`, `angry_at` | as 4.10 | | Persistent anger. |

Read order: parent, `carriedBlockState`, persistent anger. The carried state is filtered: a state that is air reads as no carried block, as does a compound that does not decode. `setCarriedBlock` is called in all cases (with null for none).

### 5.3 Endermite

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `Lifetime` | Int | 0 | Age in ticks since spawn. |

Engine: on the server, each `aiStep` of an endermite that does not require persistence increases the counter by 1; at 2400 or more the endermite is discarded. A persistent endermite never advances.

### 5.4 Ghast

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `ExplosionPower` | Byte | 1 | Power of the fireball explosion. Written as `(byte) explosionPower`. |

A new ghast has `explosionPower = 1` and experience reward 5.

### 5.5 Phantom

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `anchor_pos` | `BlockPos`, `storeNullable` | null (the field stays null) | The point the phantom circles. |
| `size` | Int | 0 | Read calls `setPhantomSize`, which clamps to `[0, 64]` and stores the synched size. |

A size change (`updatePhantomSizeInfo`) refreshes the dimensions and sets the base attack damage to `6 + size`. At spawn (`finalizeSpawn`), `anchor_pos` becomes the spawn block position raised by 5 and the size becomes 0 (spawner code that wants a larger phantom sets it afterwards). A phantom saved without `anchor_pos` loads with a null anchor (Open question 5).

### 5.6 Vex

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `bound_pos` | `BlockPos`, `storeNullable` | null | The bound origin it stays near. |
| `life_ticks` | Int | absent | Written only when the vex has a limited life. On read, a present value calls `setLimitedLife(value)` (limited life on, remaining ticks = value); an absent value turns limited life off. |
| `owner` | UUID reference (section 2) | none | The summoner. Written through the entity-reference store (key omitted when null). |

Engine: around the parent tick `noPhysics` is on, and gravity is off. With limited life on, the counter decreases by 1 each tick; when it reaches 0 or below it is set to 20 and the vex takes starvation-type damage of 1.0, so an expired vex takes 1 damage every 20 ticks until it dies.

### 5.7 Shulker

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `AttachFace` | Byte (`Direction.LEGACY_ID_CODEC`) | the default attach face (down) | The face the shulker is attached to. The byte is the 3D direction id: down 0, up 1, north 2, south 3, west 4, east 5 (read from the constructors of `net.minecraft.core.Direction`: the third constructor argument of DOWN, UP, NORTH, SOUTH, WEST, EAST is 0, 1, 2, 3, 4, 5). `LEGACY_ID_CODEC` is the Byte codec mapped with `from3DDataValue` for decoding and `get3DDataValue` (cast to byte) for encoding (read: the two method handles in the class constant pool). `from3DDataValue(i)` indexes the id-sorted table of six directions with `abs(i % 6)`: the Java remainder first (it keeps the sign of the dividend), then the absolute value, so 6 gives down, 7 gives up, -1 gives up, -7 gives up, and -128 gives `abs(-128 % 6)` = 2 = north. |
| `Peek` | Byte | 0 | The shell peek amount (the synched byte). |
| `Color` | Byte | 16 | The dye colour id; 16 is the undyed shulker. |

Read order: parent, `AttachFace` (via `setAttachFace`), then `Peek` and `Color` straight into the synched data.

### 5.8 Types with no own keys

Husk and drowned (timers: 4.1), stray, parched, wither skeleton, spider, cave spider, silverfish, blaze, giant, guardian, elder guardian, breeze. A guardian's laser target, a spider's climb flag, a blaze's fire state and a breeze's wind state are synched data or brain state and are not saved. The breeze state is in `Brain` (7.1).

---

## 6. Mobs with their own keys (continued)

### 6.1 `AbstractCubeMob` (slime and magma cube)

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `Size` | Int | 0 | **Stored as `size - 1`.** Written as `getSize() - 1`; read as `Size + 1`. A slime of size 4 stores `Size: 3`, and a file without the key loads as size 1. |
| `wasOnGround` | Byte (boolean) | false | The previous tick's ground flag used by the squish animation and the landing sound. |

Read order (differs from "parent first"): `Size` first, applied with `setSize(size, resetHealth=false)`, then the parent (`AgeableMob`) read, then `wasOnGround`. The parent chain reads `Health` afterwards, so the saved health wins (`resetHealth=false` leaves health untouched; Open question 14).

`setSize(size, resetHealth)`:

1. `size = clamp(size, 1, 127)`.
2. The synched size becomes `size`; position and dimensions are refreshed.
3. `setCubeMobHealth(size)` sets the base value of `max_health` to `size * size` (slime and magma cube; the sulfur cube overrides it, 6.3).
4. The base value of `movement_speed` becomes `0.2 + 0.1 * size` (float arithmetic: `0.1f * size` added to `0.2f`, widened to double).
5. If `resetHealth` is true, health becomes the new maximum health.

Spawn size of the base class (`AbstractCubeMob.setSpawnSize`, read from the bytecode): draw `e = nextInt(3)`; when `e < 2` and then `nextFloat() < 0.5 * specialMultiplier` (the local-difficulty special multiplier), `e` increases by 1; the size is `1 << e`, applied with `setSize(size, resetHealth=true)`. So the spawn size is 1, 2 or 4: `e = 2` (probability 1/3) always gives 4 (the float is not drawn), `e = 0` or `1` gives 2 or 4 only when the float test passes. (An earlier text of this section said "size 1 when ..."; the bytecode disagrees and it is replaced.) Subclasses may override; spawn rules: 20, 44-4. Split on death: a cube mob of size above 1 that dies on the server spawns `getSplitCount()` smaller cubes; the children are saved with their own `Size`. The split rules are in the mob documents.

Neither slime nor magma cube has `Age`, `ForcedAge` or `AgeLocked` in its file.

### 6.2 Slime and magma cube

No further keys. Sounds, particles and attack damage by size are not saved.

### 6.3 Sulfur cube

In addition to the `AbstractCubeMob` keys (6.1) and the `AgeableMob` keys (4.8; `canBeABaby` is true for the sulfur cube, so `Age`, `ForcedAge` and `AgeLocked` are written and read):

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `pickup_timer` | Int | 0 | Ticks left before the cube may swallow another item (`pickUpItem` needs it at 0 or below). |
| `from_bucket` | Byte (boolean) | false | The cube came out of a bucket (synched flag). |
| `fuse` | Int | -1 | Remaining ticks of a primed cube. Negative is "not primed"; `getFuse() >= 0` is "primed" (`isPrimed`). |

Read order: `pickup_timer`, `from_bucket`, `fuse`; then the synched `max_fuse` is set to the loaded fuse; then the `AbstractCubeMob` read (`Size`, then `AgeableMob`, then `wasOnGround`). The swallowed item is the BODY slot of `equipment` (shared key); the archetype, explosion data and contact damage are derived from that body item and are not stored.

Engine facts needed to interpret `fuse`:

| Fact | Value |
|---|---|
| Countdown | each tick a fuse above 0 is decremented first; when it equals 0 and the cube has explosion data, the cube dies by explosion (leash dropped) |
| Explosion | at the cube's position with y raised by 0.0625, power and fire flag from the archetype's explosion data; interaction type `tnt` when the `mob_griefing` rule is true, `none` otherwise; no explosion when the `tnt_explodes` rule is false; then death effects (removal reason killed) and discard |
| Priming (`primeTime(boolean randomFuse)`, returns a boolean) | refused (returns false) when the cube has no explosion data, is not alive, is not on a server level, the `tnt_explodes` rule is false, or it is already primed. Otherwise the fuse value is the archetype explosion-data fuse; when the parameter is true the value is `PrimedTnt.getRandomShortFuse(archetype fuse, random)` instead, when false the archetype fuse is used directly. `fuse` and the synched `max_fuse` are set to that value, the cube becomes permanently invulnerable, the TNT-primed sound plays and `prime_fuse` fires, and the call returns true. Callers read from the bytecode: the redstone path (`primeWhenOnPoweredPosition`) and the `mobInteract` call pass false; `hurtServer` contains one call with false and one with true (the conditions in `hurtServer` were not traced). Nothing in `primeTime` substitutes 1 for a zero archetype fuse (an earlier statement of such a rule was not found and is dropped) |
| Redstone priming | each tick a server cube that can explode and whose block position has a best own-or-neighbour signal above 0 primes itself |
| Baby rule | `setSize` called with `resetHealth` true for size 1 on a non-baby makes it a baby; when a baby reaches the age boundary and is no longer a baby it grows to size 2 with `resetHealth` true; split children are made babies |
| Max health | `4 * size` (not `size * size`) |
| Bucket round trip | `saveToBucketTag` writes the custom name, the `bucket_entity_data` component (the `Bucketable` defaults `NoAI` and `Silent` when set, and further flags `NoGravity`, `Glowing` as the default writer does) plus `age` (Int) and `age_locked` (Byte), and copies the `sulfur_cube_content` component; `loadFromBucketTag` restores `NoAI`, `Silent`, `NoGravity`, `Glowing`, persistence, then `age` and `age_locked` |

The `getRandomShortFuse` helper and the archetype data are in 44-5 and 20 §18.2; the helper formula was not re-read here (Open question 6); the `hurtServer` conditions that choose the true or false form were not traced (Open question 6). The `NoGravity` and `Glowing` writer lines of the default bucket writer were seen only as the reader's list (Open question 15).

### 6.4 Warden

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `anger` | Compound (anger table, 7.2), `store` | a fresh table with no suspects | Anger per entity. |
| `listener` | Compound (vibration listener data, 7.4), `store` | a fresh listener | The vibration listener state. |

Read order: parent, `anger` (then the client-visible anger level is re-synchronised), `listener`. Both use `read` with a default: a bad or absent compound gives the default.

### 6.5 Creaking

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `home_pos` | `BlockPos`, `storeNullable` | none | The creaking heart position it is bound to (the synched optional home position; `getHomePos` returns it or null). |

Read: the parent read first, then a present `home_pos` is passed to `setTransient(pos)`, which stores the home position and sets path-finding malus values: damaging blocks, powder snow and lava 8.0; fire and fire-in-neighbour 0.0.

Key collision: `Mob` also writes `home_pos` (with `home_radius`) when it has a restriction, and the creaking writes its own `home_pos` after the parent. The creaking's value, when non-null, overwrites the `Mob` one in the same compound. On read, `Mob` reads `home_pos` only when `home_radius >= 0` (default -1), then the creaking reads it again.

### 6.6 Ravager

Patrol and raid keys of 4.6 and 4.7, plus:

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `AttackTick` | Int | 0 | Ticks left in the attack animation. |
| `StunTick` | Int | 0 | Ticks left stunned. |
| `RoarTick` | Int | 0 | Ticks left in the roar. |

### 6.7 Zoglin

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `IsBaby` | Byte (boolean) | false | Read calls `setBaby`. |

A zoglin extends `Monster`, not `AgeableMob`, so it has no `Age` keys. Its brain holds no serialisable memory (7.1).

### 6.8 Hoglin

Keys of `AgeableMob` (4.8) and `Animal` (4.9), plus:

| Key | Type written | Default on load | Meaning |
|---|---|---|---|
| `IsImmuneToZombification` | Byte (boolean) | false | The synched immunity flag. Read calls `setImmuneToZombification`. |
| `TimeInOverworld` | Int | 0 | Ticks the hoglin has spent where it zombifies (8.3). |
| `CannotBeHunted` | Byte (boolean) | false | Piglins skip this hoglin as prey. Read calls `setCannotBeHunted`. |

---

## 7. Brain, warden anger, spawn tracker, vibration listener

### 7.1 The `Brain` key

`LivingEntity` writes `Brain` as the record `Brain.Packed`, whose only field is `memories`:

| Path | Type | Meaning |
|---|---|---|
| `Brain` | Compound | Always written (also when empty). |
| `Brain.memories` | Compound keyed by memory-type id, **required** | One entry per memory that is present and serialisable. Keys are registry names (`minecraft:is_sniffing`, ...). The field is declared with `fieldOf` in `Brain.Packed` (read), not as an optional field: a `Brain` compound without `memories` fails the Packed codec. |
| `Brain.memories.<id>` | Compound `{value, ttl?}` | `value` is required and is encoded by the memory type's own codec (table below); `ttl` is a lenient optional field (below). `ttl` is a Long written only when the memory is timed: the remaining ticks. A memory without time to live has no `ttl` key. |

Rules read from `MemoryMap`, `ExpirableValue` and `Brain.pack`:

1. Only memory types registered with a codec (`canSerialize`) are packed. Memories registered without one (walk target, attack target, nearest-entity lists, ...) are never written.
2. Empty memories (`acceptEmpty`) are skipped; only memories holding a value are written.
3. `ttl` decodes through a lenient optional: a bad `ttl` reads as absent.
4. The map key is validated: a key that names a memory type with no codec is an error. `Brain.Packed` holds the memories as a dispatched map keyed by the memory registry name, and its `validate` step rejects a memory type that has no codec (it calls `orElseThrow` on the codec lookup). Load side (read): `LivingEntity.readAdditionalSaveData` reads `Brain` with `read("Brain", Brain.Packed.CODEC)` and applies the result only through `Optional.ifPresent` (calling `makeBrain(packed)`); when the codec fails or the key is absent nothing is applied and the entity keeps the brain its constructor built from `Brain.Packed.EMPTY` (read: the constructor calls `makeBrain` with the EMPTY constant). So a missing `memories`, or any entry that the codec rejects, discards the whole `Brain` compound and the mob starts with an empty brain (all memories absent). Whether the failure is logged was not traced (Open question 2).
5. A `Unit`-codec value is an empty compound `{}` (`MapCodec.unitCodec`; inferred).
6. `ttl` is the remaining expiry at save time (`ExpirableValue.of(value, ttl)` is the packing call); after load the memory expires after that many more ticks (inferred; Open question 4).

Serialisable memory types (every type registered with a codec in `MemoryModuleType`; value codecs read from the registrations):

| Memory id | Value codec | Used by (this part) |
|---|---|---|
| `home`, `job_site`, `potential_job_site`, `meeting_point` | `GlobalPos` | villagers (not this part) |
| `golem_detected_recently`, `danger_detected_recently` | Boolean (`Codec.BOOL`) | villagers |
| `last_slept`, `last_woken`, `last_worked_at_poi` | Long | villagers |
| `play_dead_ticks`, `long_jump_cooling_down`, `ram_cooldown_ticks`, `charge_cooldown_ticks`, `attack_target_cooldown` | Int | other mobs |
| `temptation_cooldown_ticks`, `gaze_cooldown_ticks`, `item_pickup_cooldown_ticks`, `liked_noteblock_cooldown_ticks` | Int | other mobs |
| `is_in_water`, `is_pregnant` | Unit | other mobs |
| `is_panicking`, `has_hunting_cooldown`, `universal_anger`, `admiring_item`, `admiring_disabled`, `hunted_recently` | Boolean (`Codec.BOOL`; each registration in `MemoryModuleType` was read) | piglins, animals |
| `visited_block_positions` | list of `GlobalPos` | other mobs |
| `unreachable_transport_block_positions` | list of `GlobalPos` (a list codec passed through `xmap`, like `visited_block_positions`) | other mobs |
| `angry_at` | UUID (`UUIDUtil.CODEC`) | piglin family |
| `recent_projectile`, `is_sniffing`, `is_emerging`, `roar_sound_delay`, `dig_cooldown`, `roar_sound_cooldown`, `sniff_cooldown`, `touch_cooldown`, `vibration_cooldown`, `sonic_boom_cooldown`, `sonic_boom_sound_cooldown`, `sonic_boom_sound_delay` | Unit | **warden** |
| `liked_player` | UUID (`UUIDUtil.CODEC`) | allay |
| `liked_noteblock` | `GlobalPos` | allay |
| `sniffer_explored_positions` | list of `GlobalPos` | sniffer |
| `breeze_jump_cooldown`, `breeze_shoot`, `breeze_shoot_charging`, `breeze_shoot_recover`, `breeze_shoot_cooldown`, `breeze_jump_inhaling`, `breeze_leaving_water` | Unit | **breeze** |
| `breeze_jump_target` | `BlockPos` (Int Array 3) | **breeze** |

(The registered id of the breeze recovery memory is `breeze_shoot_recover`, although the constant the behaviour code uses is `BREEZE_SHOOT_RECOVERING`.)

Per mob of this part:

| Mob | Serialisable memories its code can hold | Resulting `Brain.memories` |
|---|---|---|
| warden | `is_emerging`, `is_sniffing`, `sniff_cooldown`, `dig_cooldown`, `touch_cooldown`, `vibration_cooldown`, `recent_projectile`, `roar_sound_delay`, `roar_sound_cooldown`, `sonic_boom_cooldown`, `sonic_boom_sound_cooldown`, `sonic_boom_sound_delay` (every serialisable memory referenced in `WardenAi`, `Warden`, and the `Digging`, `Emerging`, `Roar`, `Sniffing`, `SonicBoom`, `TryToSniff` behaviours) | any subset, normally `{value: {}, ttl: n}` each |
| breeze | `breeze_jump_cooldown`, `breeze_shoot`, `breeze_shoot_charging`, `breeze_shoot_recover`, `breeze_shoot_cooldown`, `breeze_jump_inhaling`, `breeze_jump_target`, `breeze_leaving_water` (referenced in `Slide`, `LongJump`, `Shoot`, `ShootWhenStuck`, `Breeze`) | any subset |
| creaking | none (`CreakingAi` and `Creaking` use the attack target and nearest-player lists only) | `{}` |
| hoglin, zoglin | none (`HoglinAi` and `Zoglin` use the attack target, avoid target, breed target, pacified, nearest-entity and count memories, none serialisable) | `{}` |
| all other mobs of this document | none (inferred; their AI code was not searched for serialisable memories; Open question 16) | `{}` (inferred) |

A saved mid-emerge warden resumes because `is_emerging` is restored with its remaining ticks.

### 7.2 Warden `anger`

Codec of `AngerManagement`:

| Path | Type | Meaning |
|---|---|---|
| `anger` | Compound | |
| `anger.suspects` | List of Compound, default empty (lenient optional field: a list that fails to decode, for example one entry with a negative `anger`, reads as the empty default, read from the codec) | One entry per suspect. |
| `anger.suspects[i].uuid` | UUID (Int Array 4) | The suspect's UUID. |
| `anger.suspects[i].anger` | Int, non-negative | The anger value. A negative value fails the entry's decode. |

Written list: first one entry per live suspect (in the internal suspect-list order, the sorted order below), then one entry for every UUID that has anger but is not currently loaded (`angerByUuid`). On read every entry goes into `angerByUuid` (the unresolved map); entries become live entities as they resolve (below).

Constants:

| Name | Value |
|---|---|
| Maximum anger per suspect | 150 |
| Decay per tick | 1 |
| Conversion delay | random integer 0 to 2 inclusive at creation, 2 after each conversion step (the step runs when the delay, decremented once per tick, is 0 or below) |

Operations (as read):

1. `increaseAnger(entity, amount)`: the suspect's anger becomes `min(150, old + amount)` (`old` is 0 for a new suspect). For a new suspect, the pending value stored for that UUID in `angerByUuid` (0 if none) is removed and **added** to the result, and that sum is stored without a second clamp (so the stored value can exceed 150); the suspect is appended to the list; the list is re-sorted. Returns the stored anger.
2. `clearAnger(entity)`: removes the suspect and re-sorts.
3. `tick(level, filter)`, each warden server tick:
   1. decrement the conversion delay; at 0 or below run the conversion (step 4) and set it to 2;
   2. for every unresolved UUID entry: remove it when its anger is 1 or less, otherwise reduce it by 1;
   3. for every live suspect: drop it when its anger is 1 or less, or the filter rejects the entity, or the entity has a removal reason. When it is dropped because of a removal reason of changed-dimension, unloaded-to-chunk or unloaded-with-player and its anger is above 1, the suspect is moved to the unresolved map with anger − 1 (so it survives an unload); other drops lose the anger. A suspect that stays loses 1;
   4. re-sort and recompute the highest anger.
4. Conversion: every unresolved UUID that resolves to a loaded entity (`level.getEntity`) moves to the live map and the suspect list and leaves the unresolved map.
5. `getActiveAnger(entity)`: the entity's anger, or the highest anger when the argument is null.
6. `getActiveEntity()`: the first suspect in sorted order that passes the filter, if it is a living entity.

Sort order of suspects: equal entities compare equal; otherwise a suspect whose anger level is `angry` sorts before one that is not; with equal angriness, players sort before non-players; then the higher anger first.

Anger levels (`AngerLevel.byAnger`: the highest level whose minimum is at or below the anger, else calm):

| Level | Minimum anger | Is angry |
|---|---|---|
| calm | 0 | no |
| agitated | 40 | no |
| angry | 80 | yes |

`canTargetEntity` (the filter): the entity is a living entity in the same level as the warden, is not creative or spectator, is not allied to the warden, is not an armor stand, is not a warden, is not invulnerable, is not dead or dying, and its bounding box is within the world border.

`increaseAngerAt(entity, amount, playSound)` on the warden is ignored when the warden has no AI or the entity cannot be targeted. Otherwise the dig cooldown is set and the table is increased; the anger is increased (the call returns the stored anger of that entity), and the `attack_target` memory is erased, so the warden re-selects, only when all three hold: the angered entity is a `Player`, the warden's current target is not a player (a null target counts as not a player), and the anger returned by the increase is at the `angry` level (80 or more). A non-player entity never causes the erase, whatever the current target. The listening sound plays last when `playSound` was requested. (Read from the method body; the order is no-AI test, `canTargetEntity` test, dig cooldown, the target-is-not-player flag taken before the increase, the increase, the erase test, the sound.)

### 7.3 Warden spawn tracker (`warden_spawn_tracker` on `ServerPlayer`)

The key lives in the player file ([45-3](45-entity-nbt-3-player-and-player-data.md) section 6.3 specifies it as part of the player compound; the codec is repeated here because the engine is a warden mechanic). Written with `store`, read with `read`, default a fresh tracker.

| Key | Type | Default | Note |
|---|---|---|---|
| `ticks_since_last_warning` | Int, non-negative | 0 | |
| `warning_level` | Int, non-negative | 0 | the setter clamps to `[0, 4]` |
| `cooldown_ticks` | Int, non-negative | 0 | |

Per player per tick (`tick`):

1. If `ticks_since_last_warning >= 12000`: decrease the warning level by 1 (clamped at 0) and reset the counter to 0; otherwise increment the counter.
2. If `cooldown_ticks > 0`, decrement it.

`tryWarn(level, pos, player)` (a shrieker shriek):

1. Let `centre` be the centre of the shrieker block (`Vec3.atCenterOf(pos)`, block corner plus 0.5 on each axis). If any warden lies in `AABB.ofSize(centre, 48, 48, 48)` (a cube 48 wide, half-extent 24 on each axis, centred on `centre`), return empty (no warning).
2. Collect the players that are not spectators, are alive and whose position is `closerThan(centre, 16.0)`; add the shrieking player if absent.
3. If any collected player's own tracker is on cooldown (`cooldown_ticks > 0`; this is the test `lambda$tryWarn$0`), return empty.
4. Among the collected players' trackers take the one with the highest `warning_level` (a maximum comparison by level; which tracker wins a tie was not determined). Call `increaseWarningLevel` on that one tracker only: it is a no-op while the tracker is on cooldown, otherwise `ticks_since_last_warning` becomes 0, `cooldown_ticks` becomes 200 and `warning_level` becomes level + 1 clamped to `[0, 4]`. Then copy that tracker's three fields (`ticks_since_last_warning`, `warning_level`, `cooldown_ticks`) onto the tracker of every collected player (`copyData`). Return the resulting level of the chosen tracker. Because step 3 already rejected cooldowns, the increase always acts when step 4 is reached. All collected players therefore end with identical tracker values.

Constants: maximum warning level 4; decay interval 12000 ticks; cooldown between increases 200 ticks; player search radius 16.0 (against the block centre); warden search box 48 wide (half-extent 24) centred on the block centre.

### 7.4 Warden `listener` (vibration listener data)

| Path | Type | Default | Meaning |
|---|---|---|---|
| `listener.event` | Compound, optional (lenient optional field) | none | The vibration currently travelling. |
| `listener.event.game_event` | registry name string | required inside the event | The game event. |
| `listener.event.distance` | Float, range `[0, 3.4028235E38]` | required | Distance travelled. |
| `listener.event.pos` | Vec3 (List of Double) | required | Source position. |
| `listener.event.source` | UUID, optional (lenient) | none | The source entity. |
| `listener.event.projectile_owner` | UUID, optional (lenient) | none | The owner when the source is a projectile. |
| `listener.selector` | Compound, required (`fieldOf`) | | The pending-vibration chooser. If it is absent or fails to decode, the whole `listener` read fails and the warden falls back to a fresh listener data. |
| `listener.selector.event` | as `listener.event` (lenient optional field) | none | The chosen vibration. |
| `listener.selector.tick` | Long, **required** (`Codec.LONG.fieldOf("tick")`) | none | Game tick of the choice. On save it is the chosen vibration's tick, or `-1` when no event is chosen (read from the getter). A selector compound without `tick` fails to decode. |
| `listener.event_delay` | Int, non-negative (always-present optional field) | 0 | Ticks left until the travelling vibration arrives. |

The worked example in 11.10 supplies `tick`, so it decodes. How a present `tick` with an absent `event` maps to selector state (the `-1` constant appears in the selector class; it is read as the saved tick of an empty selector, the load-side use was not traced) is Open question 8.

---

## 8. Engines behind the saved timers

### 8.1 Generic conversion tracker (`ConversionTracker`)

Used by the zombie family (water to drowned; husk to zombie) and the skeleton (powder snow to stray). Constructed with the mob, a synched converting flag, the target type, a level-event id for the conversion sound, an "afflicted" predicate, an affliction tag name and total, a conversion tag name and total, and an optional post-step.

| Owner | Afflicted when | Affliction tag, total | Conversion tag, total | Target | Level event | Post step |
|---|---|---|---|---|---|---|
| zombie | eyes in water | `InWaterTime`, 600 | `DrownedConversionTime`, 300 | drowned | 1040 | `handleAttributes(local-difficulty special multiplier, conversion spawn reason)` |
| husk | eyes in water (same predicate) | `InWaterTime`, 600 | `DrownedConversionTime`, 300 | zombie (`convertsToWhenDrowning`) | 1041 | as zombie |
| drowned | never ticks (`convertsInWater` false) | | | | | |
| zombie villager | never ticks (`convertsInWater` false); it has its own cure, 8.2 | | | | | |
| zombified piglin | never ticks (`convertsInWater` false, read); it still writes `InWaterTime` and `DrownedConversionTime` through the shared `Zombie` code (4.1) | | | | | |
| skeleton | in powder snow | `FreezingTime`, 140 | `StrayConversionTime`, 300 | stray | 1048 | none |

Tracker tick (the zombie family ticks it only when `convertsInWater()` is true, the skeleton always; only on a server level, only while alive and not `NoAI`):

1. If afflicted:
   1. If converting: `conversionTime -= 1`; if it is now below 0, run the conversion.
   2. Otherwise: `afflictionTime += 1`; if it is at least the affliction total, start converting with the conversion total (`conversionTime = total`, flag on).
2. If not afflicted: `afflictionTime = -1` and the converting flag is cleared (`conversionTime` keeps its value but is ignored until the next start).

Conversion: the mob is converted to the target type with `ConversionParams.single(mob, keepEquipment=true, preserveCanPickUpLoot=true)` (the new mob carries the old mob's team; the generic `convertTo` copy rules belong to the shared-model sibling), the post-step runs on the new mob, and unless the old mob was silent the level event is broadcast at the old block position.

Save and load of the tracker is as in 4.1 and 4.4: the affliction tag is written as `afflictionTime` when the predicate is true at save time and `-1` otherwise; the conversion tag as `conversionTime` while converting and `-1` otherwise. On read the affliction time defaults to 0 and a conversion tag other than `-1` restarts conversion with that remaining time.

Timelines: a fresh zombie (affliction 0) that keeps its eyes in water reaches `afflictionTime` 600 on tick 600 and starts converting with 300; `conversionTime` drops below 0 on the 301st tick after, so it converts on tick 901. A fresh skeleton in powder snow reaches 140 on tick 140 and converts on tick 441. After any tick without the afflicting condition the counter is `-1`, so the next run needs one extra tick.

The synched converting flag drives the client's shaking (`isShaking` for the skeleton, `isUnderWaterConverting` for the zombie family).

### 8.2 Zombie villager cure

The zombie villager does not use the tracker.

Start (`mobInteract`): a player holding a golden apple while the zombie villager has the weakness effect: one apple is consumed, and on the server the cure starts with duration `nextInt(2401) + 3600` ticks (3600 to 6000) and the player's UUID; the result is "success on server" for that case and "consume" on the client; otherwise the parent decides.

`startConverting(player, time)` (also called by the load): the starter UUID and remaining time are set, the synched converting flag is set, the weakness effect is removed, a strength effect with duration `time` and amplifier `min(difficultyId - 1, 0)` is added (so amplifier 0 above peaceful and -1 on peaceful: read as a minimum; Open question 12), and entity event 16 is broadcast (the client's cure particles).

Per tick on the server while alive and converting: `villagerConversionTime -= getConversionProgress()`; at 0 or below, `finishConversion`.

`getConversionProgress()` per tick: base 1. With probability 1/100 (`nextFloat() < 0.01`) a scan runs over positions `x` in `[trunc(x) - 4, trunc(x) + 4)`, outermost loop, where `trunc` is the Java double-to-int narrowing cast (truncation toward zero, not floor: for -0.5 it gives 0, where the floor would give -1; read: the entity coordinates are converted with a plain narrowing conversion, and the same holds for y and z); inside it `y` over the same width, inside that `z`; a counter `j` of matched blocks starts at 0 and every loop level ends as soon as `j` reaches 14. For each block in the block tag `speeds_up_zombie_villager_curing`: `j += 1`, and with probability 0.3 (`nextFloat() < 0.3`) the progress increases by 1. So a tick adds at most 14 extra steps, and only on about 1 tick in 100.

`finishConversion` converts into a `villager` with `ConversionParams.single(mob, keepEquipment=false, preserveCanPickUpLoot=false)` and the after step:

1. Equipment items that do not carry the `prevent_armor_change` enchantment effect are dropped; each dropped slot's item is moved into the villager's slot index `300 + slot index` where the villager exposes it.
2. The villager receives the finalised flag, the `VillagerData`, the gossips (when non-null), a copy of the offers (when non-null) and the XP.
3. The villager is finalised (`finalizeSpawn` with the local difficulty and the `conversion` spawn reason) and its brain refreshed.
4. If the starter UUID resolves to a player in the level: the cured-zombie-villager advancement trigger fires and the `zombie_villager_cured` reputation event is sent.
5. A nausea effect, duration 200 ticks, amplifier 0, is added to the villager; unless the zombie villager was silent, level event 1027 is broadcast at its position.

`removeWhenFarAway` is true only when the zombie villager is not converting and has `Xp == 0`. The opposite conversion (a villager killed by a zombie) uses `ConversionParams.single(mob, true, true)` into `zombie_villager` (`Zombie.convertVillagerToZombieVillager`). Its after step, in order: the zombie villager's finalised flag is set from the villager's; `finalizeSpawn` runs with the local difficulty at the zombie villager's position, the `conversion` spawn reason and a `ZombieGroupData` constructed with the two booleans (false, true); then the zombie villager receives the villager's `VillagerData`, a copy of its gossips, a copy of its offers and its villager XP; finally, unless the zombie was silent, level event 1026 is broadcast at the zombie's block position. (Whether the conversion happens at all is decided by the caller of `Zombie.convertVillagerToZombieVillager`, not by this step; the caller was not traced.) The dropped-equipment predicate of the cure (step 1 above) was confirmed: an item is dropped when it does not have the `prevent_armor_change` enchantment effect.

### 8.3 Hoglin zombification

Each server tick after the brain step: if `isConverting()`, `TimeInOverworld += 1`, and when it is greater than 300 (the 301st consecutive tick) the hoglin plays the converted-to-zombified sound and converts to a zoglin; otherwise `TimeInOverworld` is set to 0.

`isConverting()` is true when the hoglin is not immune, not `NoAI`, and the environment attribute `piglins_zombify` evaluated at its position is true (data: the dimension and biome attribute values; the engine is the environment-attribute lookup in the world-type documents).

Conversion: `ConversionParams.single(mob, keepEquipment=true, preserveCanPickUpLoot=false)` to `zoglin`, then a nausea effect of 200 ticks, amplifier 0, on the new zoglin.

`TimeInOverworld` is saved, so progress survives a save; returning to a non-zombifying position resets it on the next tick.

---

## 9. Embedded codecs

Cross-reference: the authoritative statements of these codecs are the item stack form in [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) section 8, trade offers in [45-6](45-entity-nbt-6-villagers-illagers-piglins.md) section 4, gossip in [45-6](45-entity-nbt-6-villagers-illagers-piglins.md) section 5 and `VillagerData` in [45-6](45-entity-nbt-6-villagers-illagers-piglins.md) section 6; this section keeps only what the zombie villager and its conversions need and was read independently.

### 9.1 `VillagerData`

| Key | Type | Default when absent |
|---|---|---|
| `type` | registry name of a villager type (`holderByNameCodec`), `fieldOf(...).orElseGet(...)` | the `DEFAULT_TYPE` key, which is the plains type (the static initialiser stores `VillagerType.PLAINS`, read) |
| `profession` | registry name of a profession, `fieldOf(...).orElseGet(...)` | `none` |
| `level` | Int (plain `Codec.INT`, optional with default 1; no clamp is applied by the codec: the constants 1 and 5 exist in the class but are not used by it) | 1 |


### 9.2 `ItemStack` (`ItemStack.CODEC`)

| Key | Type | Default | Validation |
|---|---|---|---|
| `id` | registry name of an item | required | a registered item that is not air |
| `count` | Int | 1 | range 1 to 99 inclusive |
| `components` | Compound (component patch) | empty | keys are component ids; a key with the prefix `!` removes that component from the item's defaults |

`OPTIONAL_CODEC` (used where a stack may be empty) writes an empty compound `{}` for the empty stack. The NBT form of each component value is not specified here (Open question 9).

### 9.3 `MerchantOffers` and `MerchantOffer`

`Offers` is `{Recipes: [offer, ...]}` (the list key is `Recipes`, default empty). The full trade schema is [45-6](45-entity-nbt-6-villagers-illagers-piglins.md) section 4; the defaults below were read independently from the codec in class `net.minecraft.world.item.trading.MerchantOffer`: `buy` and `sell` use `fieldOf`, `buyB` uses `lenientOptionalFieldOf`, and `uses`, `maxUses`, `rewardExp`, `specialPrice`, `demand`, `priceMultiplier`, `xp` use `lenientOptionalFieldOf` with the defaults in the table (0, 4, true, 0, 0, 0.0, 1).

| Offer key | Type | Default when absent |
|---|---|---|
| `buy` | `ItemCost` compound | required |
| `buyB` | `ItemCost` compound (lenient optional) | none |
| `sell` | `ItemStack` (9.2) | required |
| `uses` | Int | 0 |
| `maxUses` | Int | 4 |
| `rewardExp` | Byte (boolean) | true |
| `specialPrice` | Int | 0 |
| `demand` | Int | 0 |
| `priceMultiplier` | Float | 0.0 |
| `xp` | Int | 1 |

`ItemCost`: `id` (item registry name, required), `count` (Int, positive via `POSITIVE_INT`; an always-present optional field with default 1, read), `components` (an exact component predicate, optional, default empty).

### 9.4 Gossip

`Gossips` is a list of entries.

| Entry key | Type | Validation |
|---|---|---|
| `Target` | UUID | |
| `Type` | one of `major_negative`, `minor_negative`, `minor_positive`, `major_positive`, `trading` | by name |
| `Value` | Int, positive | a value of 0 or less fails the entry |

Gossip type constants (weight, max, decay per day, decay per transfer; read from the enum constructor arguments of `net.minecraft.world.entity.ai.gossip.GossipType`; the gossip schema and engine are in [45-6](45-entity-nbt-6-villagers-illagers-piglins.md) section 5):

| Type | Weight | Max | Decay per day | Decay per transfer |
|---|---|---|---|---|
| `major_negative` | -5 | 100 | 10 | 10 |
| `minor_negative` | -1 | 200 | 20 | 20 |
| `minor_positive` | 1 | 25 | 1 | 5 |
| `major_positive` | 5 | 20 | 0 | 20 |
| `trading` | 1 | 25 | 2 | 20 |

Per-event change constants: 25 per reputation event, 20 per everlasting memory, 2 per trade; container discard threshold 2 (a decayed value at or below it is dropped; inferred from the constant name). The gossip engine belongs to the villager documents (44-3).

---

## 10. Load-time validation and defaults (consolidated)

| Rule | Detail |
|---|---|
| Missing keys | Every key above has a default; nothing is required. An entity with only the shared keys loads as a default mob of its type. |
| Wrong tag type | A numeric key given any numeric type loads. A numeric key given a string or compound loads as the default. A compound key given a non-compound loads as the default (the codec failure reads empty). |
| `Size` of cube mobs | `Size + 1` clamped to `[1, 127]`: `-5` loads as size 1; `200` loads as 127. |
| `size` of a phantom | Clamped to `[0, 64]`. |
| `ExplosionPower` of a ghast | Read as a byte, no clamp. |
| `Fuse` of a creeper | Read as a short, no clamp. A value of 0 or below makes the creeper explode on its first living tick: the tick adds the swell direction (default -1) to the swell, clamps the swell below at 0, and then explodes whenever `swell >= maxSwell`, which holds for `0 >= maxSwell`. No ignition and no nearby player is needed; the swell is set to `maxSwell` just before the explosion. |
| `ExplosionRadius` of a creeper | Read as a byte, no clamp. |
| Brain | A `Brain` compound that fails the codec (for example one without `memories`, or with an entry naming a memory type that has no codec) is dropped as a whole and the mob keeps the empty brain made by its constructor (read, 7.1). |
| Persistent anger | Both `anger_end_time` and the legacy `AngerTime` are accepted; `anger_end_time` wins. |
| Timers | `-1` means "not converting"; any other value restarts the timer with that many remaining ticks, including other negative values (a conversion whose first tick drives it below 0 converts at once; inferred from the tick rules). |
| Anger table | A suspect entry with a negative `anger` rejects the entry's decode. `suspects` is a lenient optional field with an empty default, so the list then reads as empty and the warden starts with no suspects (read; the `anger` compound itself still decodes). |
| Item stacks | `count` outside 1 to 99 or an unknown `id` rejects the stack; a rejected `sell` rejects its offer; a rejected offer list reads as null `Offers` for a zombie villager (inferred). |
| Unknown keys | Ignored. |
| UUID fields | An Int Array of length other than 4 is rejected (fixed size 4). |

---

## 11. Worked examples

SNBT-style data: `1b` a Byte, `3s` a Short, `5L` a Long, `[I; a, b, c, d]` an Int Array. Only the keys of this document are shown (shared keys omitted).

**11.1 Baby zombie in open air, can break doors**

```
IsBaby: 1b, CanBreakDoors: 1b, InWaterTime: -1, DrownedConversionTime: -1
```
Loads as baby with the transient `baby` speed modifier added (+0.5 of the base speed, add-multiplied-base) and door breaking enabled when the navigator can navigate ground. A zombie with its eyes in water that has accumulated 120 ticks saves `InWaterTime: 120`.

**11.2 Zombie converting to drowned**

Eyes in water, conversion started at tick 600, 100 ticks later: `InWaterTime: 600, DrownedConversionTime: 200`. On load `startConversion(200)` runs and the zombie converts 201 ticks later if its eyes are still in water; if not, the first tick sets `afflictionTime` to -1 and clears the flag.

**11.3 Husk after 100 ticks in water**

`InWaterTime: 100, DrownedConversionTime: -1`. At 600 it starts `DrownedConversionTime: 300`, and at the end becomes a zombie (not a drowned), level event 1041.

**11.4 Creeper, charged and lit**

```
powered: 1b, Fuse: 30s, ExplosionRadius: 3b, ignited: 1b
```
Loads with `ignite()`; the swell restarts from 0, so it explodes 30 ticks later with radius `2.0 * 3 = 6.0`.

**11.5 Enderman carrying grass, angry at a player**

```
carriedBlockState: {id: "minecraft:grass_block", properties: {snowy: "false"}}
anger_end_time: 48000L
angry_at: [I; 1, 2, 3, 4]
```
At game time 47000 it stays angry for 1000 more ticks and targets the player at once if loaded.

**11.6 Slime of size 4 at full health**

```
Size: 3, wasOnGround: 0b, Health: 16.0f
```
Loads as size 4: max health 16.0 (`4 * 4`), base speed `0.2 + 0.4 = 0.6`. Size 1 stores `Size: 0`; size 2 stores `Size: 1`. A magma cube has the same form.

**11.7 Ghast with a stronger fireball**

```
ExplosionPower: 4b
```

**11.8 Phantom of size 3**

```
anchor_pos: [I; 100, 70, -30], size: 3
```
Base attack damage 9.0 (`6 + 3`).

**11.9 Vex with a lifetime**

```
bound_pos: [I; 10, 64, 10], life_ticks: 600, owner: [I; 11, 12, 13, 14]
```
After 600 ticks the vex takes 1.0 damage, then 1.0 every 20 ticks.

**11.10 Warden, angry at one entity and remembering another**

```
anger: {suspects: [
   {uuid: [I; 7, 8, 9, 10], anger: 95},
   {uuid: [I; 1, 1, 1, 1],  anger: 12}]}
listener: {selector: {tick: -1L}, event_delay: 0}
Brain: {memories: {"minecraft:sniff_cooldown": {value: {}, ttl: 80L}}}
```
On load both suspects start unresolved; within the first few ticks those that resolve become live. The 95 is at the `angry` level (80 or more) and sorts first. Each tick every anger value drops by 1.

**11.11 Anger arithmetic**

A suspect with anger 148 receiving +10 stores `min(150, 158) = 150`. A new suspect with a pending unresolved value of 30 receiving +25 computes `min(150, 25) = 25`, then adds 30: stored 55 (no second clamp).

**11.12 Spawn tracker on a player**

```
warden_spawn_tracker: {ticks_since_last_warning: 11999, warning_level: 3, cooldown_ticks: 0}
```
One tick later the counter is 12000; the next tick lowers the level to 2 and resets the counter to 0.

**11.13 Zombie villager mid-cure**

```
VillagerData: {type: "minecraft:plains", profession: "minecraft:librarian", level: 3},
VillagerDataFinalized: 1b, ConversionTime: 2400, ConversionPlayer: [I; 5, 6, 7, 8], Xp: 20
```
On load the cure restarts with 2400 remaining ticks (weakness removed, strength added for 2400 ticks); the resulting villager has level 3, XP 20 and the saved offers and gossips.

**11.14 Hoglin 200 ticks into zombification**

```
Age: 0, ForcedAge: 0, AgeLocked: 0b, InLove: 0, IsImmuneToZombification: 0b, TimeInOverworld: 200, CannotBeHunted: 0b
```
It converts after 101 more consecutive ticks at a zombifying position.

**11.15 Shulker attached to the north face, half open**

```
AttachFace: 2b, Peek: 50b, Color: 16b
```

**11.16 Sulfur cube, primed**

```
Size: 1, wasOnGround: 0b, Age: 0, ForcedAge: 0, AgeLocked: 0b, pickup_timer: 0, from_bucket: 0b, fuse: 35
```
plus a BODY entry in `equipment`. A size-2 cube (stored `Size: 1`) has max health 8 (`4 * 2`).

**11.17 Skeleton shaking in powder snow**

```
FreezingTime: 140, StrayConversionTime: 120
```
On load `startConversion(120)` runs; if the skeleton leaves powder snow, the next tick resets the affliction time to -1 and stops the shaking.

---

## 12. Per-type summary matrix

| Type | Keys beyond section 1 (the `Brain` compound is written for every type) |
|---|---|
| zombie, husk, drowned | `IsBaby`, `CanBreakDoors`, `InWaterTime`, `DrownedConversionTime` |
| zombie_villager | the four above plus `VillagerData`, `VillagerDataFinalized`, `Offers`, `Gossips`, `ConversionTime`, `ConversionPlayer`, `Xp` |
| zombified_piglin | the four above plus `anger_end_time`, `angry_at` |
| skeleton | `FreezingTime`, `StrayConversionTime` |
| stray, parched, wither_skeleton | none |
| bogged | `sheared` |
| spider, cave_spider, silverfish, blaze, giant, guardian, elder_guardian, breeze | none (breeze state is in `Brain`) |
| creeper | `powered`, `Fuse`, `ExplosionRadius`, `ignited` |
| enderman | `carriedBlockState`, `anger_end_time`, `angry_at` |
| endermite | `Lifetime` |
| slime, magma_cube | `Size`, `wasOnGround` |
| sulfur_cube | `Size`, `wasOnGround`, `Age`, `ForcedAge`, `AgeLocked`, `pickup_timer`, `from_bucket`, `fuse` |
| ghast | `ExplosionPower` |
| phantom | `anchor_pos`, `size` |
| vex | `bound_pos`, `life_ticks`, `owner` |
| witch | `patrol_target`, `PatrolLeader`, `Patrolling`, `Wave`, `CanJoinRaid`, `RaidId` |
| ravager | the witch set plus `AttackTick`, `StunTick`, `RoarTick` |
| shulker | `AttachFace`, `Peek`, `Color` |
| warden | `anger`, `listener` (`Brain` holds the cooldown and state memories) |
| creaking | `home_pos` |
| zoglin | `IsBaby` |
| hoglin | `Age`, `ForcedAge`, `AgeLocked`, `InLove`, `LoveCause`, `IsImmuneToZombification`, `TimeInOverworld`, `CannotBeHunted` |

---

## Open questions

1. The shared-chain keys of section 1 (`Entity`, `LivingEntity`, `Mob`) are named but not specified here; they are specified in [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) section 5 and [45-2](45-entity-nbt-2-living-entity-mob-animal.md) sections 2 and 3. Keep those documents authoritative when the two disagree. `docs/protocol/README.md` has no Documents row for the 45 series yet: this is a required item left for the orchestrator (the fixer may not edit the README).
2. Whether a rejected codec value (a malformed `Brain` or `anger` compound, or a `Brain.memories` key naming a memory without a codec) is logged, ignored or fails the whole entity load was not traced. 7.1 now states the `Brain` load path as read (a failed codec leaves the constructor's empty brain; logging not traced); sections 2 and 10 state the observable default for the other compounds (inferred).
3. `Unit` memory values are said to be an empty compound (inferred from `MapCodec.unitCodec`); the stored byte form was not checked.
4. The `ttl` semantic (remaining ticks versus absolute game time) is inferred from the packing call; the load-side application was not read (see [45-2](45-entity-nbt-2-living-entity-mob-animal.md) section 8.3 for the shared model). The value codecs of every registration in 7.1 were read in `MemoryModuleType` (closed: all Boolean rows use `Codec.BOOL`, `angry_at` and `liked_player` use `UUIDUtil.CODEC`, `breeze_jump_target` uses `BlockPos.CODEC`, every warden and other breeze memory uses `Unit.CODEC`).
5. A phantom loaded without `anchor_pos` has a null anchor. The consumers of the anchor (the move goals) were not read for null handling.
6. The `PrimedTnt.getRandomShortFuse(fuse, random)` helper used by the sulfur cube was not read, the archetype and explosion-data JSON schema is only named (data), and the conditions under which `hurtServer` calls `primeTime(true)` versus `primeTime(false)` were not traced.
7. Closed: the rejecting test of `tryWarn` is the player's own tracker being on cooldown (7.3 step 3).
8. The vibration selector's lenient pair (`event` optional, `tick` required) and how it maps to the selector state were not traced.
9. The NBT form of every component value inside `ItemStack.components` (the per-component codec) is not specified.
10. Closed: `Direction` (`net.minecraft.core.Direction`) was located; ids 0 to 5 and the `abs(i % 6)` decode were read, and the `LEGACY_ID_CODEC` decoder is the `from3DDataValue` method handle (5.7).
11. The creeper explosion call was read as `explode(entity, x, y, z, radius, interaction)`; the `Level.explode` semantics belong to the explosion algorithm of 20 §6.2.
12. A zombie villager's strength amplifier on start is `min(difficulty id - 1, 0)`, which is -1 on peaceful. This is read from the bytes and looks unintended; the client effect for amplifier -1 was not traced.
13. The hoglin `piglins_zombify` environment attribute is data; the lookup engine is in the world-type documents and was not re-read.
14. The loading of `Health` after `Size` for cube mobs relies on the `AgeableMob` read chain reaching `LivingEntity.readAdditionalSaveData`; that chain was read only down to `AgeableMob.readAdditionalSaveData`.
15. The default bucket writer (`Bucketable.saveDefaultDataToBucketTag`) was read for `NoAI` and `Silent` (written) and its loader for `NoAI`, `Silent`, `NoGravity`, `Glowing` and persistence; the writer's remaining keys (`NoGravity`, `Glowing`, `Invulnerable`, `Health`) were not each confirmed.
16. The AI code of the monsters other than warden, breeze, creaking, hoglin and zoglin was not searched for serialisable memories; the table in 7.1 states none for them without that search (not verified that they use goal selectors rather than brains; the 7.1 cells are marked inferred; the `Brain` compound is written regardless).
20. The `Enderman` carried-block filter was re-read: the decoded state is kept unless `BlockState.isAir()` (5.2 confirmed). The `Warden.increaseAngerAt` order was not re-read in this round (7.2 stands as written earlier).
17. Closed: the erase condition of `Warden.increaseAngerAt` is read (7.2).
18. Closed: the after step of `Zombie.convertVillagerToZombieVillager` is read (8.2).
19. Closed: the `ItemCost` `count` default is 1 and the `VillagerData` default type is plains (9.1, 9.3).
