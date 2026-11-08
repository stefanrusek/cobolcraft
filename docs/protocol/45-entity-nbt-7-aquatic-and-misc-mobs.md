# Entity NBT, part 7: aquatic mobs, nautilus family, strider, bucketed-entity data, and the leftover sweep

| Item | Value |
|---|---|
| Covers | The persistent (NBT) keys of cod, salmon, pufferfish, tropical fish, squid, glow squid, dolphin, axolotl, tadpole, nautilus, zombie nautilus and strider, including the water-animal base classes, the bucket round trip (how a bucket item stores a mob and how the stored data merges into the mob spawned from it), the ItemStack compound form, the brain-memory compound as far as these mobs use it, and the registry-wide sweep that decides which entity types this part owns as "leftover". |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the `addAdditionalSaveData` / `readAdditionalSaveData` methods, the codecs they name, the bucket item and bucket interface, and the enum classes they use. No execution. Every key, default and range below was read in this round; anything else is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Status | Round RS27, part 7. Siblings, all now present: [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) (shared entity model, ItemStack compound, owner index), [45-2](45-entity-nbt-2-living-entity-mob-animal.md) (LivingEntity, Mob, Brain, `attributes`, `active_effects`), [45-3](45-entity-nbt-3-player-and-player-data.md) (Player, `players/data/<uuid>.dat`, ender chest), [45-4](45-entity-nbt-4-land-animals.md), [45-5](45-entity-nbt-5-hostile-mobs.md), [45-6](45-entity-nbt-6-villagers-illagers-piglins.md), [45-8](45-entity-nbt-8-vehicles-projectiles-items.md), [45-9](45-entity-nbt-9-bosses-and-decorations.md). Cross-references use "NN section" and the content of those documents is not repeated. Scope note: this part does not cover the player data file, the ender chest, or the `attributes` and `active_effects` formats; those are owned by 45-3 and 45-2 and were deliberately not re-read here. |

Class names in backticks say where a fact was read; they are not the design. NBT type names are the ones of [07](07-nbt-and-anvil.md) (Byte, Short, Int, Long, Float, Double, String, List, Compound). "Absent key" means the reader falls back to the stated default. "Written always" means the save method writes the key unconditionally.

## Contents

1. [How a 26.3 entity compound is built](#1-how-a-263-entity-compound-is-built)
2. [Inherited layers used by this part's mobs](#2-inherited-layers-used-by-this-parts-mobs)
3. [Water animals and fish](#3-water-animals-and-fish)
4. [Squid, glow squid, dolphin](#4-squid-glow-squid-dolphin)
5. [Axolotl and the brain memory compound](#5-axolotl-and-the-brain-memory-compound)
6. [Tadpole](#6-tadpole)
7. [Nautilus, zombie nautilus, strider](#7-nautilus-zombie-nautilus-strider)
8. [Bucketed-entity data and the merge into the spawned mob](#8-bucketed-entity-data-and-the-merge-into-the-spawned-mob)
9. [ItemStack and spawn-egg entity data](#9-itemstack-and-spawn-egg-entity-data)
10. [Registry sweep and the leftover set](#10-registry-sweep-and-the-leftover-set)
11. [Leftover entities: where their keys are](#11-leftover-entities-where-their-keys-are)
12. [Differences from the task's expected key names](#12-differences-from-the-tasks-expected-key-names)
13. [Worked examples](#13-worked-examples)
14. [Validation](#14-validation)
15. [Open questions](#15-open-questions)

## 1. How a 26.3 entity compound is built

Every entity class overrides a save method and a read method (`addAdditionalSaveData`, `readAdditionalSaveData`); each one first calls its parent's, then writes or reads its own keys. The saved compound of an entity is therefore the union of the keys of every class in its chain, in chain order: Entity (part 1), then LivingEntity, Mob, PathfinderMob, the family classes, then the leaf. A class that does not override either method adds no keys. Read methods use "get X or default" access: an absent or wrongly typed key yields the default stated in the tables, never an error. (read: all classes in this part)

Consequences for an implementer: write each key from the class that owns it (the tables say which), read with the stated default, and ignore unknown keys. Registry-typed values are written by their string key (`minecraft:...` for registry entries, a lower-case serialized name for enum codecs).

## 2. Inherited layers used by this part's mobs

The keys below are owned by parts 1 and 2; they are listed only so the chains in later sections are complete. They were read here as a by-product and are not re-specified.

| Layer | Keys written (read here) | Owner |
|---|---|---|
| `LivingEntity` | `Health`, `HurtTime`, `DeathTime`, `AbsorptionAmount`, `current_impulse_context_reset_grace_time`, `current_explosion_impact_pos`, `attributes`, `active_effects`, `FallFlying`, `Brain`, `last_hurt_by_player`, `last_hurt_by_player_memory_time`, `last_hurt_by_mob`, `ticks_since_last_hurt_by_mob`, `equipment`, `locator_bar_icon`; the reader also reads `sleeping_pos` | part 2 |
| `Mob` | `CanPickUpLoot`, `PersistenceRequired`, `drop_chances`, `home_radius`, `home_pos`, `LeftHanded`, `DeathLootTable`, `DeathLootTableSeed`, `NoAI` | part 2 |
| `PathfinderMob`, `WaterAnimal`, `AbstractSchoolingFish`, `AgeableWaterCreature`, `Cod`, `Squid`, `Nautilus`, `Strider`, `Guardian`, `ElderGuardian`, `Giant`, `Monster` | no save or read override of their own | none |
| `Marker`, `LightningBolt` | both declare the two methods, with bodies that are a bare return: nothing is written and nothing is read | none |
| `AgeableMob` | `Age` (Int, absent 0) and `ForcedAge` (Int, absent 0) and `AgeLocked` (Boolean, absent false); all three are written only when the mob can be a baby (`canBeABaby`) | part 2 |
| `Animal` | `InLove` (Int, absent 0), `LoveCause` (entity reference) | part 2 |
| `TamableAnimal` | `Owner` (entity reference, written only when set), `Sitting` (Boolean, written always, absent false). Reading: a present `Owner` marks the animal tame; an absent one marks it not tame | part 2 |
| `Entity` | includes `HasVisualFire` (Boolean); the rest of the entity-level keys are part 1 | part 1 |

The `equipment` compound is a map from the serialized equipment-slot name to an ItemStack (section 9; full form in 45-1 section 8): `EntityEquipment.CODEC` is an unbounded map keyed by the slot codec. The slot names read from `EquipmentSlot` are `mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`. The saddle of a strider or nautilus, and the contents of a sulfur cube, are carried only in this compound (slots `saddle`, `body`); there is no separate saddle key (section 12).

## 3. Water animals and fish

Chain: `AbstractFish` extends `WaterAnimal` extends `PathfinderMob`. `AbstractSchoolingFish` extends `AbstractFish`. Cod, salmon and tropical fish extend `AbstractSchoolingFish`; pufferfish and tadpole extend `AbstractFish`.

| Class | Key | NBT type | Written | Read default and rule |
|---|---|---|---|---|
| `AbstractFish` | `FromBucket` | Boolean | always | false |
| `Cod` | none | | | |
| `Salmon` | `type` | String | always | The variant's serialized name: `small`, `medium`, `large` (ids 0, 1, 2). Absent or unknown name: `medium` (the default). |
| `Pufferfish` | `PuffState` | Int | always | Absent 0; the value read is clamped to at most 2 (the minimum of the read value and 2). No lower clamp was read. |
| `TropicalFish` | `Variant` | Int | always | The packed variant (below). Absent: the default variant (below). |

Salmon variant table (`Salmon$Variant`): `small` id 0, bounding-box scale 0.5; `medium` id 1, scale 1.0 (read: the constructor takes a float and the `medium` entry passes the constant 1.0); `large` id 2, scale 1.5. The id codec used in stream and component form clamps out-of-range ids to the ends.

Tropical fish packed variant (`TropicalFish`, `Pattern`, `Base`, `Variant`). The compound stores one Int (the codec is an Int mapped to the record pattern, base color, pattern color):

| Bits of the Int | Field | Rule |
|---|---|---|
| 0 to 15 | pattern packed id | `base id` plus 256 times `pattern index` (below); on read the value `Int & 65535` is looked up among the 12 packed ids; an unknown value yields `kob`. |
| 16 to 23 | base color | dye id (0 to 15), `(Int >> 16) & 255`; ids out of range map to dye id 0 (white). |
| 24 to 31 | pattern color | dye id, `(Int >> 24) & 255`; same out-of-range rule. |

Writing: `(pattern.packedId & 65535) | ((baseColor.id & 255) << 16) | ((patternColor.id & 255) << 24)`.

Base ids: `small` 0, `large` 1. Pattern table (name, base, index within base, packed id = base + 256 index):

| Pattern | Base | Index | Packed id |
|---|---|---|---|
| `kob` | small | 0 | 0 |
| `sunstreak` | small | 1 | 256 |
| `snooper` | small | 2 | 512 |
| `dasher` | small | 3 | 768 |
| `brinely` | small | 4 | 1024 |
| `spotty` | small | 5 | 1280 |
| `flopper` | large | 0 | 1 |
| `stripey` | large | 1 | 257 |
| `glitter` | large | 2 | 513 |
| `blockfish` | large | 3 | 769 |
| `betty` | large | 4 | 1025 |
| `clayfish` | large | 5 | 1281 |

The default variant is pattern `kob`, base color white, pattern color white, so packed Int 0. Dye ids 0 to 15 are the order of the `DyeColor` static initializer: white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black (read; the id lookup is a continuous by-id map whose out-of-bounds strategy is ZERO, so any id outside 0 to 15 gives white). The sized model (small or large body) follows the pattern's base; that is rendering (12, 44 part 7), not NBT.

The 22 spawn-time "common variants" of tropical fish are an array created in the `TropicalFish` static initializer (size 22, each entry a record built as pattern, base color, pattern color; read in this round, all 22 entries). They are spawn data, not saved data; the rules for choosing among them are in [44 part 7](44-residual-mob-questions-7-aquatic.md). The table gives the entries in array order, with the packed Int computed from the formula above:

| Index | Pattern | Base color | Pattern color | Packed Int (pattern id + 65536 x base id + 16777216 x pattern-color id) |
|---|---|---|---|---|
| 0 | `stripey` | orange | gray | 117506305 |
| 1 | `flopper` | gray | gray | 117899265 |
| 2 | `flopper` | gray | blue | 185008129 |
| 3 | `clayfish` | white | gray | 117441793 |
| 4 | `sunstreak` | blue | gray | 118161664 |
| 5 | `kob` | orange | white | 65536 |
| 6 | `spotty` | pink | light_blue | 50726144 |
| 7 | `blockfish` | purple | yellow | 67764993 |
| 8 | `clayfish` | white | red | 234882305 |
| 9 | `spotty` | white | yellow | 67110144 |
| 10 | `glitter` | white | gray | 117441025 |
| 11 | `clayfish` | white | orange | 16778497 |
| 12 | `dasher` | cyan | pink | 101253888 |
| 13 | `brinely` | lime | light_blue | 50660352 |
| 14 | `betty` | red | white | 918529 |
| 15 | `snooper` | gray | red | 235340288 |
| 16 | `blockfish` | red | white | 918273 |
| 17 | `flopper` | white | yellow | 67108865 |
| 18 | `kob` | red | white | 917504 |
| 19 | `sunstreak` | gray | white | 459008 |
| 20 | `dasher` | cyan | yellow | 67699456 |
| 21 | `flopper` | yellow | yellow | 67371009 |

The default variant (section above) is separate from this array: it is `kob`, white, white, which is not an array entry. The selection rule that uses the array (uniform choice, probabilities, the separate rare random path) was not read in this round and is not asserted here (Open question 6).

## 4. Squid, glow squid, dolphin

| Class | Key | NBT type | Written | Read default and rule |
|---|---|---|---|---|
| `Squid` | none | | | chain `AgeableWaterCreature` then `AgeableMob`, so the squid carries the `AgeableMob` keys (section 2) |
| `GlowSquid` | `DarkTicksRemaining` | Int | always | absent 0 |
| `Dolphin` | `GotFish` | Boolean | always | false |
| `Dolphin` | `Moistness` | Int | always | absent 2400 |

The dolphin keeps its treasure position only in a field that is neither written nor read: neither `TreasurePos` nor `CanFindTreasure` exists in the saved data (section 12). The dolphin's chain is `AgeableWaterCreature` then `AgeableMob`.

## 5. Axolotl and the brain memory compound

Chain: `Axolotl` extends `Animal` (so it has `Age`, `ForcedAge`, `AgeLocked`, `InLove`, `LoveCause` from section 2).

| Key | NBT type | Written | Read default and rule |
|---|---|---|---|
| `Variant` | Int | always | Written as the variant id through the legacy Int codec: `lucy` 0, `wild` 1, `gold` 2, `cyan` 3, `blue` 4. Read: ids out of range (including negative) map to id 0 `lucy`; absent key also `lucy` (the default). |
| `FromBucket` | Boolean | always | false |

Variant table (`Axolotl$Variant`): common-spawn flag true for lucy, wild, gold, cyan; false for blue (the rare variant). The same enum also has a string codec (`lucy`, `wild`, `gold`, `cyan`, `blue`) used by the item component, not by the entity compound. The spawn-time choices (common versus rare) are spawn behaviour in [44 part 7](44-residual-mob-questions-7-aquatic.md).

Brain memories are written by `LivingEntity` under `Brain` (part 2). The compound form, read from `Brain$Packed`, `MemoryMap`, `ExpirableValue`:

| Path | Type | Meaning |
|---|---|---|
| `Brain` | Compound | one key: `memories` |
| `Brain.memories` | Compound | one entry per persisted memory: key = memory type id (a `minecraft:` registry key such as `minecraft:play_dead_ticks`), value = the entry compound below |
| entry `value` | the memory type's codec (Int or Boolean here) | the stored value |
| entry `ttl` | Long | optional (read leniently); present only when the memory expires, and then the remaining ticks |

Only memory types registered with a codec are persisted; every other memory (targets, nearest entities, walk targets and so on) is dropped on save and starts empty on load. Types that carry a codec among those used by the aquatic mobs: `play_dead_ticks` (Int codec), `has_hunting_cooldown` (Boolean codec), `temptation_cooldown_ticks` (Int), `gaze_cooldown_ticks` (Int), `long_jump_cooling_down` (Int), `ram_cooldown_ticks` (Int); the full list of persisted types is the set of `MemoryModuleType` registrations that pass a codec (the others use the no-codec registration). The axolotl brain's sensor set is nearest living entities, nearest adult, hurt-by, axolotl attackables and food temptations (44 part 7 section 9 specifies the sensors).

Axolotl play-dead state is therefore the pair `play_dead_ticks` (remaining ticks, with a `ttl` when it was set with an expiry) and the hunting cooldown (`has_hunting_cooldown` true with `ttl` of remaining cooldown ticks). Loading restores the memory with that expiry, so the remaining time continues counting after a reload. The play-dead behaviour itself (trigger, duration, health restore) is in [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) section 4 and [44 part 7](44-residual-mob-questions-7-aquatic.md) section 8.

## 6. Tadpole

Chain: `Tadpole` extends `AbstractFish`, so `FromBucket` applies (section 3).

| Key | NBT type | Written | Read default |
|---|---|---|---|
| `Age` | Int | always (its own field, not `AgeableMob`) | 0 |
| `AgeLocked` | Boolean | always | false |

The tadpole does not extend `AgeableMob`, so it has no `ForcedAge`. Growth into a frog is a tick rule (19 section on frogs, 44 part 7), not saved data.

## 7. Nautilus, zombie nautilus, strider

| Class | Chain | Own keys | Notes |
|---|---|---|---|
| `Nautilus` | `AbstractNautilus` then `TamableAnimal` then `Animal` | none | Tameness and sitting are `Owner` and `Sitting` (section 2). The saddle and the body armor sit in `equipment` slots `saddle` and `body` (the class tests the saddle slot for `isSaddled`). |
| `ZombieNautilus` | `AbstractNautilus` | `variant` | String: the variant's registry key (`temperate`, `warm`; the two variant data files are `minecraft/zombie_nautilus_variant/temperate.json` and `warm.json`, extracted by the data tool). Written as the key's identifier through the identifier codec, with the registry namespace `minecraft`. Read: absent or unresolvable key leaves the value as constructed, which is the `temperate` entry (or, when missing from the registry, any entry; inferred as the constructor default). |
| `Strider` | `Animal` | none | The class has no save or read override. The saddle is the `saddle` slot of `equipment`. There is no boost-time key: boost state belongs to the steering helper and is not persisted. |

`AbstractNautilus` has no save or read override of its own either; its owner, sitting and saddle data all come from the inherited layers. For zombie nautilus the same `TamableAnimal` keys apply (it also extends `AbstractNautilus`). The variant helper writes the key `variant` (lower-case, lowercase text constant `variant` in `VariantUtils`).

## 8. Bucketed-entity data and the merge into the spawned mob

A bucket item holds a mob as two things: item components set on the stack, and a compound in the component `bucket_entity_data` (a custom-data compound). The mob classes that implement the bucket interface (`Bucketable`) are the fish (`AbstractFish`: cod, salmon, pufferfish, tropical fish), the axolotl, the tadpole and the sulfur cube.

**Picking up (`saveToBucketTag`).** The bucket item stack is created for the mob (cod bucket, salmon bucket, pufferfish bucket, tropical fish bucket, axolotl bucket, tadpole bucket, sulfur cube bucket). Then:

1. The mob's custom name is copied to the stack (component `custom_name`).
2. The default data is written into `bucket_entity_data` (table below).
3. Type-specific components are copied: salmon `salmon/size`; tropical fish `tropical_fish/pattern`, `tropical_fish/base_color`, `tropical_fish/pattern_color`; axolotl `axolotl/variant`; sulfur cube `sulfur_cube_content`. Cod and pufferfish copy nothing extra.
4. The axolotl, tadpole and sulfur cube add their own keys to the same compound (second table).

Default data (`Bucketable.saveDefaultDataToBucketTag`), each written only under the stated condition:

| Key | Type | Written when |
|---|---|---|
| `NoAI` | Boolean | the mob has AI disabled |
| `Silent` | Boolean | the mob is silent |
| `NoGravity` | Boolean | the mob has no gravity |
| `Glowing` | Boolean | the mob has the glowing flag |
| `Invulnerable` | Boolean | the mob is permanently invulnerable |
| `PersistenceRequired` | Boolean | persistence is required |
| `Health` | Float | always |

Per-type additional bucket keys (all rows read in this round from the `saveToBucketTag` / `loadFromBucketTag` bodies and their save lambdas of `Axolotl`, `Tadpole` and `SulfurCube`: the sulfur cube writes `age` with the Int writer and `age_locked` with the Boolean writer, loads them with `getIntOr` and `getBooleanOr` defaults 0 and false, and copies the `sulfur_cube_content` stack component; the sibling [45-5](45-entity-nbt-5-hostile-mobs.md) section 6.3 describes the same round trip):

| Mob | Key | Type | Written | Load rule |
|---|---|---|---|---|
| axolotl | `Age` | Int | always | `getIntOr` 0 |
| axolotl | `AgeLocked` | Boolean | always | false |
| axolotl | `HuntingCooldown` | Long | only when the hunting-cooldown memory is present, value = remaining ticks | present: set the memory true with that expiry; absent: clear the memory |
| tadpole | `Age` | Int | always | applied only if present |
| tadpole | `AgeLocked` | Boolean | always | false |
| sulfur cube | `age` | Int | always | `getIntOr` 0 (lower-case key) |
| sulfur cube | `age_locked` | Boolean | always | `getBooleanOr` false (lower-case key) |

**Releasing (`MobBucketItem.spawn`).** On the server, when the bucket's fluid is emptied at a position:

1. The mob type of the bucket is created at the position with the spawn reason BUCKET, using the default stack configuration: the item's components are applied to the new entity through each class's component hook (tropical fish pattern, base color, pattern color; salmon size; axolotl variant), and a stack `entity_data` component, when present, is merged as in section 9.
2. If the mob is bucketable, the compound `bucket_entity_data` (empty if the component is missing) is passed to `loadFromBucketTag`: first the default keys, then the type-specific ones. The default loader reads each key as optional and applies only those present: `NoAI`, `Silent`, `NoGravity`, `Glowing`, `Invulnerable` (Booleans, each applied with its stored value) and `Health` (Float: an optional `getFloat`, applied through the entity's `setHealth`, which stores the value clamped to the range 0 to the mob's current maximum health; the loader itself applies no other clamp, so a stored `Health` above the maximum loads as the maximum and a negative one as 0). `PersistenceRequired` is different: when present it is applied only if the stored Boolean is true (the call is the no-argument "set persistence required" on a true value), so a stored false leaves the mob's own persistence setting unchanged and never clears it. An absent key leaves the new mob's own default.
3. `FromBucket` is set true (so the mob is marked as bucketed and persisted with `FromBucket` true for fish, axolotl and sulfur cube as `from_bucket`).
4. The entity is added with its passengers and plays its ambient sound; the game event `entity_place` is emitted at the position.

The following keys named in the task are not bucket-data keys in 26.3: `Age` (only for axolotl, tadpole and sulfur cube, as in the table), `HasVisualFire` (a plain `Entity` key, not read or written by the bucket code) and the old `BucketVariantTag`, which no longer exists (the tropical fish variant travels in the three `tropical_fish/*` stack components).

Mob buckets are water buckets that can hold the fluid: `MobBucketItem` extends the fluid bucket class; picking up requires a water bucket in hand and an alive mob (`bucketMobPickup`), plays the type's pickup sound, replaces the held bucket with the mob bucket, sends the filled-bucket advancement trigger to a server player, drops any leash, and discards the entity. The shared pickup rules (hand, sound, leash, discard) are as stated; no other conditions were read.

## 9. ItemStack and spawn-egg entity data

ItemStack compound (`ItemStack.CODEC`, a record codec applied recursively):

| Key | Type | Rule |
|---|---|---|
| `id` | String | item registry key (written always) |
| `count` | Int | integer range 1 to 99 (`ExtraCodecs.intRange`), written always; read as an optional field with default 1 (rule and strictness: 45-1 section 8, not re-read here) |
| `components` | Compound | the component patch (only differences from the item's default components); optional, absent means empty patch. Component compound formats: [00](00-data-types.md) section 12 (item stacks) and 45-1 section 8 |

The optional form (`ItemStack.OPTIONAL_CODEC`, used for slots that may be empty) writes an empty stack as an empty compound and reads an empty compound as the empty stack. The `id` codec carries bound components, so `id` alone resolves the item's defaults. Component validation (`validateStrict`) rejects stacks whose components fail the checks and contained item sizes; the failing stack is not loaded.

Spawn-egg style data (`TypedEntityData`): a stack `entity_data` component holds a compound with the entity `id` (the leading `id` key is stripped on storage and the type is carried alongside). On spawn it is merged into the entity: the entity is saved without id to a fresh compound, the stored compound is deep-merged over it (stored keys win, nested compounds merge), the entity's UUID is kept, and the result is loaded back through the normal read methods. An entity type flagged "only operators can set NBT" skips the merge unless the using player is an operator (the check is server-side only).

## 10. Registry sweep and the leftover set

The sweep was done on the artifact: `EntityTypeIds` declares 161 keys and the `EntityTypes` static initializer registers 161 types (same 161 names, both counted). The same count appears in [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) section 2. All 161 registered names are, in alphabetical order:

acacia_boat, acacia_chest_boat, allay, area_effect_cloud, armadillo, armor_stand, arrow, axolotl, bamboo_chest_raft, bamboo_raft, bat, bee, birch_boat, birch_chest_boat, blaze, block_display, bogged, breeze, breeze_wind_charge, camel, camel_husk, cat, cave_spider, cherry_boat, cherry_chest_boat, chest_minecart, chicken, cod, command_block_minecart, copper_golem, cow, creaking, creeper, cushion, dark_oak_boat, dark_oak_chest_boat, dolphin, donkey, dragon_fireball, drowned, egg, elder_guardian, end_crystal, ender_dragon, ender_pearl, enderman, endermite, evoker, evoker_fangs, experience_bottle, experience_orb, eye_of_ender, falling_block, fireball, firework_rocket, fishing_bobber, fox, frog, furnace_minecart, ghast, giant, glow_item_frame, glow_squid, goat, guardian, happy_ghast, hoglin, hopper_minecart, horse, husk, illusioner, interaction, iron_golem, item, item_display, item_frame, jungle_boat, jungle_chest_boat, leash_knot, lightning_bolt, lingering_potion, llama, llama_spit, magma_cube, mangrove_boat, mangrove_chest_boat, mannequin, marker, minecart, mooshroom, mule, nautilus, oak_boat, oak_chest_boat, ocelot, ominous_item_spawner, painting, pale_oak_boat, pale_oak_chest_boat, panda, parched, parrot, phantom, pig, piglin, piglin_brute, pillager, player, polar_bear, poplar_boat, poplar_chest_boat, pufferfish, rabbit, ravager, salmon, sheep, shulker, shulker_bullet, silverfish, skeleton, skeleton_horse, slime, small_fireball, sniffer, snow_golem, snowball, spawner_minecart, spectral_arrow, spider, splash_potion, spruce_boat, spruce_chest_boat, squid, stray, strider, sulfur_cube, tadpole, text_display, tnt, tnt_minecart, trader_llama, trident, tropical_fish, turtle, vex, vindicator, wandering_trader, warden, wind_charge, witch, wither, wither_skeleton, wither_skull, wolf, zoglin, zombie, zombie_horse, zombie_nautilus, zombie_villager, zombified_piglin.

Ownership. The authoritative owner index is [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) section 12 (all 161 names mapped to parts) with the all-entities index of [45-9](45-entity-nbt-9-bosses-and-decorations.md) section 13; this part does not repeat it. This part owns exactly these 12 types, specified in sections 3 to 8: cod, salmon, pufferfish, tropical_fish, squid, glow_squid, dolphin, axolotl, tadpole, nautilus, zombie_nautilus, strider. Every other name belongs to a sibling: player to [45-3](45-entity-nbt-3-player-and-player-data.md); the land, friendly and neutral animals to [45-4](45-entity-nbt-4-land-animals.md); the hostile, cube and guardian families to [45-5](45-entity-nbt-5-hostile-mobs.md); villagers, illagers and piglins to [45-6](45-entity-nbt-6-villagers-illagers-piglins.md); items, orbs, blocks, clouds, markers, displays, vehicles and projectiles to [45-8](45-entity-nbt-8-vehicles-projectiles-items.md); bosses, decorations, mannequin and cushion to [45-9](45-entity-nbt-9-bosses-and-decorations.md). The earlier per-group partition table of this part was removed because it duplicated those documents.

Counts: this part 12, the other parts 149 (161 in all). A final check an implementer can repeat: the union of the sibling owner groups of 45-1 section 12 equals the 161 names above and no name is in two groups.

## 11. Leftover entities: where their keys are

The leftover set of the sweep (types that no family of this part covers) is specified in the sibling documents; the duplicated key rows were removed from this part. Look the keys up there:

| Types | Document and section |
|---|---|
| guardian, elder_guardian, giant (no keys of their own) | [45-5](45-entity-nbt-5-hostile-mobs.md) section 5.8 |
| sulfur_cube and `AbstractCubeMob` (`Size`, `wasOnGround`, `pickup_timer`, `from_bucket`, `fuse`) | 45-5 sections 6.1 and 6.3 |
| item, experience_orb, falling_block, tnt, ominous_item_spawner, area_effect_cloud, marker, interaction | [45-8](45-entity-nbt-8-vehicles-projectiles-items.md) sections 3.1 to 3.8 |
| block_display, item_display, text_display (all displays) | 45-8 section 3.9 |
| lightning_bolt (no keys: both overrides are a bare return) | 45-8 section 6 |
| mannequin, cushion | [45-9](45-entity-nbt-9-bosses-and-decorations.md) sections 12 and 10 |

Entity-level keys (45-1) and the `LivingEntity` and `Mob` layers (section 2, 45-2) apply to the mobs among them.

## 12. Differences from the task's expected key names

The task statement expected these names; the artifact differs:

| Expected | Found in 26.3 |
|---|---|
| dolphin `CanFindTreasure`, `TreasurePos` | Not saved. Only `GotFish` and `Moistness` are. The treasure position is a transient field. |
| strider `Saddle`, `BoostTime` | No key. Saddle is the `saddle` slot of `equipment`; no boost value is persisted. |
| nautilus `saddle`, `tame` | Saddle in `equipment.saddle`; tame is `Owner` plus `Sitting` from `TamableAnimal`. |
| zombie nautilus variants | `variant` String (identifier), data files `temperate`, `warm`. |
| tropical fish `BucketVariantTag` | Does not exist; the bucket carries three stack components (section 8). |
| axolotl "memories including play-dead" | `Brain.memories` with `play_dead_ticks` Int and `has_hunting_cooldown` Boolean (section 5). |
| tadpole `Age`, `FromBucket` | Confirmed (`Age`, `AgeLocked` own; `FromBucket` inherited). |
| bucket data `Age`, `HasVisualFire` | `Age` only for axolotl, tadpole, sulfur cube; `HasVisualFire` is an `Entity` key, not a bucket key. |
| squid | No keys of its own. |

## 13. Worked examples

1. **Tropical fish.** Large body, pattern `stripey`, base orange, pattern color gray. Packed pattern id = 1 + 256*1 = 257. Int = 257 + (1 << 16) + (7 << 24) = 257 + 65536 + 117440512 = 117506305. Compound: `{id:"minecraft:tropical_fish", FromBucket:0b, Variant:117506305, ...}`. Reading `Variant:0` yields kob, white, white. Reading `Variant:5` yields pattern `kob` (5 is not a packed id), base white, pattern white.
2. **Salmon.** `type:"large"` gives scale 1.5; `type:"huge"` (unknown) gives `medium`.
3. **Pufferfish.** `PuffState:7` loads as 2; `PuffState` absent loads as 0.
4. **Glow squid.** `{id:"minecraft:glow_squid", DarkTicksRemaining:80, ...}`; absent key restores 0. A squid or glow squid carries `Age`, `ForcedAge` and `AgeLocked` (section 2) only when its class reports `canBeABaby`; a squid that cannot be a baby saves none of the three, so no `Age` appears in this example unless that condition holds (whether the squid classes report it was not read here, Open question 14).
5. **Dolphin.** `{GotFish:1b, Moistness:1200}` restores both; a dolphin with no `Moistness` starts at 2400.
6. **Axolotl, play dead.** `Variant:4` is blue. A play-dead axolotl: `Brain:{memories:{"minecraft:play_dead_ticks":{value:150, ttl:150L}}}` restores the memory with 150 ticks left. A fresh axolotl bucket from a blue axolotl: item `axolotl_bucket` with component `axolotl/variant:"blue"` and `bucket_entity_data:{Health:14.0f, Age:0, AgeLocked:0b}` plus `HuntingCooldown:<ticks>L` only if the cooldown memory exists.
7. **Releasing a tropical fish bucket.** Stack components `tropical_fish/pattern:"stripey"`, `tropical_fish/base_color:"orange"`, `tropical_fish/pattern_color:"gray"` and `bucket_entity_data:{Health:3.0f, NoAI:1b}`. Spawn order: components set the variant, then `loadFromBucketTag` applies `Health` 3.0 and no-AI, then `FromBucket` true, then the entity is added.
8. **Strider save.** A saddled strider's saved form has no strider key: only `equipment:{saddle:{id:"minecraft:saddle", count:1}}` plus the inherited keys.
9. **Zombie nautilus.** `{variant:"minecraft:warm", Owner:<ref>, Sitting:0b}` reloads as the warm variant, tame, standing.
10. **Experience orb.** `{Health:5s, Age:100s, Value:3s, Count:1}` restores value 3 count 1; a missing `Count` restores 1.

## 14. Validation

An implementation of this part is correct when all of these hold.

1. Writing then reading each mob of section 3 to 7 yields the same field values (round trip), for every variant id and for the default.
2. Reading an empty compound for each mob produces exactly the defaults of the tables (tropical fish `kob/white/white`, salmon `medium`, pufferfish 0, dolphin `Moistness` 2400, axolotl `lucy`, glow squid 0).
3. Out-of-range inputs behave as specified: pufferfish `PuffState` above 2 loads as 2; axolotl `Variant` outside 0 to 4 loads as `lucy`; tropical fish colors outside 0 to 15 load as white; unknown salmon type loads as `medium`.
4. A saved water animal never contains keys of other families (no `Saddle`, `BoostTime`, `CanFindTreasure`, `TreasurePos`, `BucketVariantTag`).
5. Bucket round trip: picking up and releasing a mob yields the same variant, name, health, and the flags of section 8 (NoAI, Silent, NoGravity, Glowing, Invulnerable, and PersistenceRequired only when true) and sets `FromBucket`.
6. The 161-name sweep: every registry name is owned by exactly one part of 45-1 section 12.
7. A reference client does not read these compounds; the check against vanilla is a vanilla server or client loading a world written by this implementation (R8 of the design map). No client wire data is added by this part.

## 15. Open questions

1. Closed: ownership is no longer restated here; section 10 points to 45-1 section 12 and 45-9 section 13, and section 11 is a pointer table. Whether those indexes agree with each other type by type was not re-diffed in this part.
2. Entity-level keys (Pos, Motion, Rotation, UUID, Air, Fire, custom name and so on) and `LivingEntity`/`Mob` key semantics are only listed (section 2) and belong to parts 1 and 2; their types and defaults were not read here.
3. The reference formats of `Owner`, `Thrower`, `LoveCause`, `last_hurt_by_*` (entity references) were not read; they are part 2's.
4. Closed: salmon medium scale and the dye id order were read (section 3).
5. The zombie nautilus read behaviour when `variant` is absent or names an unknown variant is inferred from the constructor default (`temperate`, else any registered variant).
6. Partly closed: the 22 tropical fish common variants are now tabulated (section 3). Not read: the spawn code that picks among them and the nautilus and axolotl spawn variant selection; spawn rules are 44 part 7.
7. Which memory types are persisted is the set registered with a codec (read: the memory-map key codec accepts a type only when `canSerialize` is true, otherwise it reports an error); only the ones used by the aquatic mobs were named here. The complete persisted list is in 45-2 section 8.4 (not re-verified here).
8. Closed for the class: both `Marker` overrides are a bare return. Whether the entity base (45-1) writes any extra compound for it was not checked here.
9. Not read: the display `interpolation` details; see 45-8 section 3.9.
10. Closed for the bucket path: the bucket `Health` load is an optional `getFloat` applied through `setHealth`, which clamps to 0 to maximum health (section 8); no loader-level clamp exists. Write conditions of other optional keys were read as shown in the section 8 tables.
11. Partly closed: the `Brain` key is read with an optional codec read; a missing key gives no brain data, and a decode failure is reported as a problem and the codec's partial value, if any, is used instead (read in the value-input reader). Whether a partial value keeps the valid memories of a map that also holds an unknown or non-serializable memory type, or drops the whole map, depends on the dispatched-map codec library and was not read (the library is not in the readable game classes examined here).
12. Player, ServerPlayer and PlayerList save, the player data file, the ender chest and the `attributes` and `active_effects` formats were not read in this part; 45-3 and 45-2 own them.
13. Entity compounds written by an older data version (datafixers) are not covered; only the 26.3 form is.
14. Whether `Squid`, `GlowSquid` and `Dolphin` report `canBeABaby` as true (so that `Age`, `ForcedAge`, `AgeLocked` are actually written) was not read in this part; see 45-2 for the `AgeableMob` condition.
