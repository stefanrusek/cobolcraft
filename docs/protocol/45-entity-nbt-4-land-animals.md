# 45. Entity NBT, part 4: land animals

| Item | Value |
|---|---|
| Covers | Round RS27 part 4: the save and load keys, value types, defaults and validation of the land animals and their variant holders, plus the Brain memories each of them can persist. Mobs: cow, mooshroom, pig, sheep, chicken, rabbit, horse, donkey, mule, llama, trader llama, skeleton horse, zombie horse, camel, camel husk, cat, ocelot, wolf, fox, panda, polar bear, goat, sniffer, armadillo, turtle, bee, frog, allay, parrot, happy ghast, copper golem, iron golem, snow golem, bat. Excludes villagers and illagers (part 6) and aquatic animals and nautilus (part 7, `45-entity-nbt-7-aquatic-and-misc-mobs.md`). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Read: the `addAdditionalSaveData` and `readAdditionalSaveData` methods (and their lambdas) of every class listed above and of the classes they inherit from, `TagValueInput`, `EntityReference`, `VariantUtils`, `Brain$Packed`, `MemoryMap`, `ExpirableValue`, `MemoryModuleType`, `InventoryCarrier`, `SimpleContainer`, `ItemStackWithSlot`, `ItemStack`, `EntityEquipment`, `NeutralMob`, the enums used as codecs, the Brain set-memory sites of each mob. |
| Evidence rule | Every key, type, default and constant below was read in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. |
| Siblings | `45-entity-nbt-1` (shared model), `-2` (shared mob classes), `-3` (Player), `-5` to `-9` (other mob groups). This part gives the shared chain of keys only as a reference table (section 3) so that a land animal can be written without opening the siblings; where a sibling exists, its text rules. |
| Related | 07 §9.3 (the entity compound the keys of this document go into), 18 (mob framework, breeding, taming), 19 and [44 part 4](44-residual-mob-questions-4-land-animals.md) (behaviour of these mobs), [45-1](45-entity-nbt-1-shared-model-and-entity-base.md) and [45-2](45-entity-nbt-2-living-entity-mob-animal.md) (shared keys), 46 (registry ids) |

Notation: "tick" is a game tick. A "key" is a named child of the entity's compound. "Default" is the value used when the key is absent or has the wrong type. `Byte`, `Short`, `Int`, `Long`, `Float`, `Double`, `String`, `IntArray`, `List`, `Compound` are the NBT types of 07 §1.

## Contents

1. How the keys are read (rules shared by every mob)
2. Shared codecs and value formats
3. The inherited chain of keys (reference)
4. Variant holders
5. Per mob: cow family, pig, sheep, chicken, rabbit
6. Per mob: equines
7. Per mob: camel and camel husk
8. Per mob: cat, ocelot, wolf, fox, panda, polar bear
9. Per mob: goat, sniffer, armadillo, turtle, bee
10. Per mob: frog, allay, parrot, happy ghast, golems, bat
11. Brain memories
12. Worked examples
13. Validation and migration rules
14. Open questions

---

## 1. How the keys are read

Entities are saved through a write interface and loaded through a read interface (`ValueOutput`, `ValueInput`) that, for the disk format, is a Compound tag (`TagValueInput`). Each class saves its own keys after those of its parent: the order of the keys inside the Compound has no meaning, but the class chain is walked from the base class up (section 3).

Primitive reads (`TagValueInput`):

| Read | Rule |
|---|---|
| `getIntOr`, `getInt` | Accepts any numeric tag at the key (Byte, Short, Int, Long, Float, Double) and converts it with the tag's own integer conversion (next paragraph). A key that is missing or is not numeric gives the default (`getInt` gives "absent"). |
| `getLongOr`, `getLong`, `getFloatOr`, `getShortOr`, `getByteOr` | Same rule, with the matching conversion. |
| `getBooleanOr` | Numeric tag whose Byte conversion is not zero gives true. An Int of 256 therefore reads as false (the low 8 bits are zero), and a Float of 0.5 reads as false (floor is 0). A non-numeric tag gives the default. |
| `getString` | Only a String tag counts; any other type is "absent". |
| `read(key, codec)` | Decodes the child with the codec. A missing child is "absent". On a decode error a problem is reported (not thrown) and the read returns the error result's partial value when the codec produced one, otherwise "absent" (as stated in 45-1 section 1). Whether a given codec produces a partial value on a bad element was not traced per codec (Open question 5); the calling code applies its default or leaves the field unchanged when the result is absent, as each table says. |
| `listOrEmpty`, `list` | A List tag whose elements decode. Elements that fail to decode are skipped (inferred from the existence of per-element problem classes; Open question 6). |

Writes: `putBoolean` writes a **Byte** 0 or 1; `putInt`, `putLong`, `putFloat`, `putShort`, `putByte` write the matching type; `store(key, codec, value)` writes the codec's encoding; `storeNullable` writes nothing when the value is null; `list(key, codec)` writes a List.

Integer conversions of the numeric tags (read from the tag classes):

| Source tag | To Int | To Short | To Byte |
|---|---|---|---|
| Long | low 32 bits | low 16 bits | low 8 bits |
| Float, Double | `Mth.floor` of the value (rounds toward negative infinity, not toward zero) | floor, then `& 65535` | floor, then `& 255` |

Examples: a Double -1.5 read as Int gives -2 (not -1); a Float 0.5 read as a boolean gives false (floor 0, Byte 0); a Float 255.9 read as Byte gives floor 255, `& 255` = 255 (as a signed byte, -1, non-zero, so a boolean reads true). A Long of 4294967296 (2^32) read as Int gives 0.

Because every numeric read converts from any numeric type, files written by tools that store Short or Long where the game stores Int are accepted. The game always writes the types given in the tables below.

## 2. Shared codecs and value formats

| Codec or format | NBT form | Notes |
|---|---|---|
| UUID (`UUIDUtil.CODEC`, entity reference) | IntArray of exactly 4 ints, most significant first | Any other length fails. An entity reference is saved as this UUID alone (`EntityReference.store`). Read `EntityReference.read` gives "none" when the key is missing or invalid. |
| Owner reference with old-name conversion (`readWithOldOwnerConversion`) | The key is read first as a UUID IntArray; if that fails it is read as a String and the server's old-user conversion turns the player name into a UUID; if both fail the result is "none" | Used by `Owner` on tameable animals and horses. |
| `BlockPos.CODEC` | IntArray of exactly 3 ints (x, y, z) | Fixed size 3. |
| `Vec3.CODEC` | List of 3 Doubles | (listed for the vibration data only) |
| `GlobalPos.CODEC` | Compound `{dimension: String (dimension key), pos: IntArray(3)}` | Used in memories. |
| Registry key codec (`ResourceKey.codec(registry)`) | String, an identifier such as `minecraft:ashen` | A key whose entry does not exist in the loaded registry is ignored (see section 4). |
| Enum by name (`StringRepresentable.fromEnum`) | String, the lower-case serialized name | Used for `Type` (mooshroom, fox), panda genes, armadillo `state`, copper golem `weather_state`. An unknown name makes the read "absent". |
| Enum by legacy id | Int | Id tables in the sections that use them. Out-of-range handling is stated per enum. |
| Dye colour (`DyeColor.LEGACY_ID_CODEC`) | Int 0 to 15: 0 white, 1 orange, 2 magenta, 3 light_blue, 4 yellow, 5 lime, 6 pink, 7 gray, 8 light_gray, 9 cyan, 10 purple, 11 blue, 12 brown, 13 green, 14 red, 15 black | An id outside 0 to 15 maps to element 0, white (the id map uses the ZERO out-of-bounds strategy of `ByIdMap`, which was read: it returns element 0 of the sorted array when the id is below 0 or at or above the length). |
| Unit (`Unit.CODEC`) | An empty Compound `{}` | The "flag" memories. |
| `ItemStack.CODEC` | Compound `{id: String (item key), count: Int 1 to 99 (default 1), components: Compound (optional, default empty patch)}` | `id` must name a non-air item. An empty stack cannot be encoded; callers skip empty slots. Strict validation checks (such as `validateStrict`) are not run by this codec. The `components` Compound is a data-component patch; its form, and the component handling on load, are specified in 45-1 section 8 (and 00). |
| `ItemStackWithSlot.CODEC` | The `ItemStack` fields above inline, plus `Slot`: unsigned byte (default 0, always written). `ExtraCodecs.UNSIGNED_BYTE` is built on the plain Byte codec: **written as a Byte tag**; on write an Int above 255 is an error, otherwise it is narrowed to a signed byte (so 128 to 255 appear as negative Bytes; an Int below 0 has no check in the write lambda, read in this round); on read the Byte is converted to an unsigned Int 0 to 255. | Used by chested-horse `Items`. |
| `EntityEquipment.CODEC` | Compound whose keys are equipment slot names and whose values are `ItemStack` Compounds | Slot names: `mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`. Empty stacks are removed on read (a key holding an empty stack is dropped). The full form, with `drop_chances`, is in 45-2 section 2 and section 3. |

## 3. The inherited chain of keys (reference)

These are written by every land animal below; the siblings 45-1 (see section 5 and section 10) and 45-2 (sections 2 to 7) are the authority and this table only lets this part stand alone. The key names of the `LivingEntity`, `Mob`, `AgeableMob`, `Animal` and `TamableAnimal` rows were re-checked against the string constants of those classes in the fixing pass and all appear (`leash` is handled by a separate mechanism, 45-1 section 10.1); the per-key defaults and write conditions defer to 45-1 and 45-2.

| Level | Key | Type | Default on read | Written when |
|---|---|---|---|---|
| `LivingEntity` | `Health` | Float | max health | always |
| | `HurtTime`, `DeathTime` | Short | 0 | always |
| | `AbsorptionAmount` | Float | 0 | always |
| | `attributes` | List of packed attribute instances | none | always |
| | `active_effects` | List of effect instances | none | only when at least one effect is active |
| | `FallFlying` | Byte | 0 | always |
| | `sleeping_pos` | IntArray(3) | none | only when sleeping |
| | `Brain` | Compound `{memories: ...}` | fresh brain | always, with an empty `memories` Compound for mobs without brain memories (section 11; 45-2 section 8.1) |
| | `last_hurt_by_player`, `last_hurt_by_mob` | UUID IntArray | none | when set; with `last_hurt_by_player_memory_time` (Int, 0) and `ticks_since_last_hurt_by_mob` (Int: ticks since the hit, 0) |
| | `equipment` | Compound (section 2) | empty | only when not empty |
| | `locator_bar_icon` | Compound | none | only when it holds data |
| | `current_impulse_context_reset_grace_time`, `current_explosion_impact_pos` | Int, Vec3 | none | always, nullable |
| `Mob` | `CanPickUpLoot`, `PersistenceRequired`, `LeftHanded`, `NoAI` | Byte (NoAI only when set) | 0 | always except `NoAI` |
| | `drop_chances` | Compound | default chances | only when different from the default |
| | `leash` | see 45-1 section 10.1 | none | when leashed |
| | `home_radius`, `home_pos` | Int, IntArray(3) | -1 (no home) | only when a home is set |
| | `DeathLootTable`, `DeathLootTableSeed` | String key, Long | none, 0 | only when set (seed only when not 0); read details in 45-2 section 3 |
| `AgeableMob` | `Age`, `ForcedAge` (Int, 0), `AgeLocked` (Byte, 0) | | | only for classes that can be babies (all land animals here; allay, golems and bat have no `Age`) |
| `Animal` | `InLove` | Int | 0 | always |
| | `LoveCause` | UUID IntArray | none | when set |
| `TamableAnimal` | `Owner` | UUID IntArray | none | when owned |
| | `Sitting` | Byte | 0 | always |

`TamableAnimal` read sets the tame flag from the presence of `Owner`: a readable owner makes the animal tamed and owned; a missing or unreadable one makes it not tamed. `Sitting` sets both the "ordered to sit" field and the sitting pose.

`NeutralMob` persistent anger (used by wolf, polar bear, bee, iron golem; see also 45-2 section 7):

| Key | Type | Meaning | Written when | Read |
|---|---|---|---|---|
| `anger_end_time` | Long | Game time (the level's tick counter) at which the anger ends | Always, with `putLong` (the value is -1 when not angry) | If present, used as is. |
| `AngerTime` | Int | Legacy: ticks of anger remaining | Never written | Read only when `anger_end_time` is absent: end time becomes game time now plus this value. |
| (neither) | | | | End time is -1 (not angry). |
| `angry_at` | UUID IntArray | The angry-at target | Only when set (`storeNullable`) | Read (and the target resolved into the mob's attack target) only when the level is a server level. |

## 4. Variant holders

A "variant holder" is a registry entry chosen per animal. Two forms exist.

**Registry-key form** (cow, pig, chicken, cat, wolf, frog; `VariantUtils`): key `variant`, a String identifier of an entry of the variant registry. Writing stores the identifier of the held entry. Reading looks the identifier up in the loaded registry and sets the variant only when the entry exists: a missing key, a malformed identifier or an entry not in the registry leaves the variant at the value the mob had before the read (the value given at creation, see the default column). The entries themselves (textures, spawn conditions, model type) are data of the data pack and are not specified here.

**Sound-variant form** (cow, pig, chicken, cat, wolf): key `sound_variant`, a String identifier of an entry of the matching sound-variant registry; written when the held entry has a key, read with the same "unknown key leaves it unchanged" rule. The registries are `cow_sound_variant`, `pig_sound_variant`, `chicken_sound_variant`, `cat_sound_variant`, `wolf_sound_variant`.

| Mob | Variant registry | Default entry key (code constant) | Sound-variant key |
|---|---|---|---|
| cow | `cow_variant` | `temperate` | `sound_variant` |
| pig | `pig_variant` | `temperate` | `sound_variant` |
| chicken | `chicken_variant` | `temperate` | `sound_variant` |
| cat | `cat_variant` | `black` (the `DEFAULT_VARIANT` constant of the cat class) | `sound_variant` |
| wolf | `wolf_variant` | `pale` | `sound_variant` |
| frog | `frog_variant` | `temperate` (the `DEFAULT_VARIANT` constant of the frog class) | none |

Defaults of cow, pig, chicken and wolf are the `DEFAULT` constants of the variant key classes. Which entry a newly spawned animal gets (biome conditions) is the data-driven spawn-variant engine and is not part of the save format; the saved value always wins on load.

**Enum forms** (not registry holders):

| Mob | Key | Type | Values |
|---|---|---|---|
| mooshroom | `Type` | String enum | `red` (default), `brown` |
| rabbit | `RabbitType` | Int | 0 brown (default), 1 white, 2 black, 3 white_splotched, 4 gold, 5 salt, 99 evil. An Int not in this set maps to the default (brown) (sparse id map with a default entry). |
| fox | `Type` | String enum | `red` (default), `snow` |
| llama and trader llama | `Variant` | Int | 0 creamy, 1 white, 2 brown, 3 gray. CLAMP strategy (read in `ByIdMap`: the id is clamped to 0 through length-1): a value above 3 maps to gray, below 0 to creamy. Default creamy when absent. |
| parrot | `Variant` | Int | 0 red_blue (default), 1 blue, 2 green, 3 yellow_blue, 4 gray; CLAMP strategy (above 4 gives gray, below 0 gives red_blue). |
| horse | `Variant` | Int | A packed value, section 6. |

Strategy meanings (read in `ByIdMap`): ZERO returns element 0 for an out-of-range id; CLAMP is `Mth.clamp(id, 0, length-1)`; WRAP is `Mth.positiveModulo(id, length)`. Fox type, panda genes, armadillo `state`, mooshroom `Type` and copper golem `weather_state` are not id-mapped in the save format (they use by-name codecs); only their network stream codecs use `ByIdMap`.

## 5. Cow family, pig, sheep, chicken, rabbit

### 5.1 Cow (`minecraft:cow`)

Chain: `Animal` (section 3), then:

| Key | Type | Default | Notes |
|---|---|---|---|
| `variant` | String | unchanged (`temperate` at creation) | section 4 |
| `sound_variant` | String | unchanged | section 4 |

The shared cow base class adds no key.

### 5.2 Mooshroom (`minecraft:mooshroom`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `Type` | String enum `red` or `brown` | `red` | Written always. An unknown name reads as red. |
| `stew_effects` | List of `{id: effect key (String), duration: Int (default 160)}` | none (no stew effect) | Written only when set. The codec is `SuspiciousStewEffects.CODEC`, a list of entries `{id, duration}`; `id` is read through the `MobEffect` codec (a registry identifier String; its form was not traced further, Open question 7). Read: absent leaves the field null (none), as read. |

The mooshroom does not use `variant` or `sound_variant` (it inherits the cow base class only).

### 5.3 Pig (`minecraft:pig`)

`variant`, `sound_variant` as for the cow, after the `Animal` chain. The saddle is an equipment slot (`equipment.saddle`), not a key of the pig (section 6.1 explains the mechanism).

### 5.4 Sheep (`minecraft:sheep`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `Sheared` | Byte | 0 | |
| `Color` | Int, dye colour id | 0 (white) | Written as Int. Out-of-range ids read as white. |

### 5.5 Chicken (`minecraft:chicken`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `IsChickenJockey` | Byte | 0 | |
| `EggLayTime` | Int | unchanged (the countdown set at creation) | Read only when present. |
| `variant`, `sound_variant` | String | unchanged | section 4 |

### 5.6 Rabbit (`minecraft:rabbit`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `RabbitType` | Int | 0 (brown) | section 4 |
| `MoreCarrotTicks` | Int | 0 | |

## 6. Equines

### 6.1 AbstractHorse (horse, donkey, mule, skeleton horse, zombie horse, camel, camel husk)

After the `Animal` chain:

| Key | Type | Default | Notes |
|---|---|---|---|
| `EatingHaystack` | Byte | 0 | |
| `Bred` | Byte | 0 | |
| `Temper` | Int | 0 | No clamp on read. |
| `Tame` | Byte | 0 | |
| `Owner` | UUID IntArray | none | Written when set (the null case writes nothing). Read with the old-name conversion of section 2. |

**There is no `SaddleItem` key and no `ArmorItem` key in this version.** The saddle is the `saddle` slot and horse or llama armor and the llama carpet are the `body` slot of the `equipment` Compound of `LivingEntity` (section 3). A horse is "saddled" when the `saddle` slot is non-empty. `AbstractHorse` allows the `saddle` slot only while the horse is alive, not a baby and tamed; any other slot defers to the `Animal` rule (read in `canUseSlot`). The llama and trader llama override it and allow every slot. The `body` slot rule for equine animals was not traced (Open question 8). Files from older games that hold `SaddleItem` or `ArmorItem` are not read by these classes (a migration, if the data fixer exists, is outside this round).

### 6.2 Horse (`minecraft:horse`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `Variant` | Int | 0 | Packed: low 8 bits are the colour id, bits 8 to 15 are the marking id. Packing: `value = (colour & 255) | ((marking << 8) & 65280)`. Unpacking: colour = `value & 255`, marking = `(value & 65280) >> 8`. |

Colour ids: 0 white, 1 creamy, 2 chestnut, 3 brown, 4 black, 5 gray, 6 dark_brown (the colour id map uses the WRAP strategy, positive modulo of 7, so 7 reads as white and -1 as dark_brown). Marking ids: 0 none, 1 white, 2 white_field, 3 white_dots, 4 black_dots (the marking id map also uses WRAP, modulo 5, so a marking id of 5 reads as 0, none).

### 6.3 Donkey and mule (`minecraft:donkey`, `minecraft:mule`)

Both extend the chested horse base (6.5) and add no key.

### 6.4 Skeleton horse and zombie horse

| Mob | Key | Type | Default |
|---|---|---|---|
| skeleton horse | `SkeletonTrap` | Byte | 0 |
| skeleton horse | `SkeletonTrapTime` | Int | 0 |
| zombie horse | none | | |

### 6.5 AbstractChestedHorse (donkey, mule, llama, trader llama)

| Key | Type | Default | Notes |
|---|---|---|---|
| `ChestedHorse` | Byte | 0 | Whether a chest is attached. |
| `Items` | List of `ItemStackWithSlot` | empty | Written only when the chest flag is set; one element per **non-empty** slot with its `Slot` index. |

Read order: `ChestedHorse` is read, then the inventory is created (size below), then, only when the chest flag is set, each `Items` element whose `Slot` is `>= 0` and `< size` is placed in that slot (an element with an invalid slot is dropped).

Inventory size: `3 * columns`, where `columns` is 0 when there is no chest. Donkey and mule: 5 columns with a chest, so 15 slots. Llama and trader llama: the columns equal the llama's `Strength` (1 to 5) with a chest, so 3 to 15 slots. Without a chest the size is 0 and any `Items` is ignored.

### 6.6 Llama (`minecraft:llama`) and trader llama (`minecraft:trader_llama`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `Variant` | Int | 0 (creamy) | section 4 |
| `Strength` | Int | 0 on read, then clamped | The setter clamps the stored value to 1 to 5, so an absent or zero key gives strength 1 (the setter's lower bound 1 and upper bound 5 were read). |
| trader llama: `DespawnDelay` | Int | **47999** | Written always; the read default is 47999 when absent. |

**Order matters on read:** `Strength` is read **before** the chested-horse keys, because the inventory size depends on it. The carpet (decor) is the `body` slot of `equipment`; there is no `DecorItem` key.

## 7. Camel and camel husk

| Key | Type | Default | Notes |
|---|---|---|---|
| `LastPoseTick` | Long | 0 | The tick counter of the last sit or stand change. A negative value means "sitting" (the synched value is negative while sitting; the sign convention is read from the "is sitting" test: value `< 0`). Read: when the loaded value is negative the pose is set to `SITTING`; then the last-pose-change value is set to the loaded value. |

The `AbstractHorse` keys (6.1) apply. `camel_husk` extends the camel and adds no key. Saddle: `equipment.saddle`.

## 8. Cat, ocelot, wolf, fox, panda, polar bear

### 8.1 Cat (`minecraft:cat`)

Chain: `TamableAnimal`. Keys: `variant`, `sound_variant` (section 4), `CollarColor` (Int dye colour id, default **14 red**; written always).

### 8.2 Ocelot (`minecraft:ocelot`)

Chain: `Animal`. Key: `Trusting` (Byte, 0). The ocelot does not have `Owner` or `Sitting`.

### 8.3 Wolf (`minecraft:wolf`)

Chain: `TamableAnimal`. Keys: `CollarColor` (Int, default 14 red), `variant`, `sound_variant`, and the persistent anger keys of section 3 (`anger_end_time`, `angry_at`; legacy `AngerTime`).

### 8.4 Fox (`minecraft:fox`)

| Key | Type | Default | Notes |
|---|---|---|---|
| `Trusted` | List of UUID IntArray (a list of entity references through `TRUSTED_LIST_CODEC`; each element is an entity reference saved as its UUID, section 2; the list codec itself was not traced further, Open question 9) | empty | The players the fox trusts. Read: the trust list is cleared first, then each UUID is added. |
| `Sleeping` | Byte | 0 | |
| `Type` | String enum `red` or `snow` | `red` | |
| `Sitting` | Byte | 0 | Fox-specific; the fox is an `Animal`, not tameable. |
| `Crouching` | Byte | 0 | |

After the read, on a server level the fox rebuilds its target goals (the goal set depends on the loaded type and trust). The fox has no `Owner`.

### 8.5 Panda (`minecraft:panda`)

| Key | Type | Default |
|---|---|---|
| `MainGene` | String enum | `normal` |
| `HiddenGene` | String enum | `normal` |

Gene table: `normal`, `lazy`, `worried`, `playful`, `brown` (recessive), `weak` (recessive), `aggressive` (ids 0 to 6; the recessive flag is the last constructor value). An unknown name reads as `normal` (the read supplies the `NORMAL` default).

### 8.6 Polar bear (`minecraft:polar_bear`)

Chain: `Animal`, then the persistent anger keys of section 3.

## 9. Goat, sniffer, armadillo, turtle, bee

### 9.1 Goat

| Key | Type | Default | Notes |
|---|---|---|---|
| `IsScreamingGoat` | Byte | 0 | |
| `HasLeftHorn` | Byte | **1** | A goat that lost a horn stores 0. |
| `HasRightHorn` | Byte | **1** | |

Brain memories: section 11.

### 9.2 Sniffer

The sniffer class defines **no save keys** of its own. Its state (`idling`, `feeling_happy`, `scenting`, `sniffing`, `searching`, `digging`, `rising`; ids 0 to 6) and its drop-seed tick are synched entity data only, with defaults `idling` and 0; they are not written, so a reloaded sniffer is idling. What the sniffer persists is in the Brain: `sniffer_explored_positions` (section 11).

### 9.3 Armadillo

| Key | Type | Default | Notes |
|---|---|---|---|
| `state` | String enum | `idle` | `idle`, `rolling`, `scared`, `unrolling` |
| `scute_time` | Int | unchanged (the countdown picked at creation) | Read only when present. |

State table: `idle` (id 0, not threatened, duration 0), `rolling` (id 1, threatened, 10), `scared` (id 2, threatened, 50), `unrolling` (id 3, threatened, 30); "threatened" is the flag the state carries and the last number is the animation duration in ticks. Reading `state` switches to the state with the state-switch routine (so the switch side effects run), with `idle` when the key is absent or unknown.

### 9.4 Turtle

| Key | Type | Default | Notes |
|---|---|---|---|
| `home_pos` | IntArray(3) | the turtle's own block position | Written always. On read the home is set first, **before** the parent keys. |
| `has_egg` | Byte | 0 | |

The travel target and the "digging" flags are not saved.

### 9.5 Bee

| Key | Type | Default | Notes |
|---|---|---|---|
| `hive_pos` | IntArray(3) | none | Written only when set. |
| `flower_pos` | IntArray(3) | none | The saved flower position; written only when set. |
| `HasNectar` | Byte | 0 | |
| `HasStung` | Byte | 0 | |
| `TicksSincePollination` | Int | 0 | Backed by a field named `ticksWithoutNectarSinceExitingHive`; the reading "ticks without nectar since leaving the hive" is taken from that field name only (inferred, Open question 10). |
| `CannotEnterHiveTicks` | Int | 0 | |
| `CropsGrownSincePollination` | Int | 0 | |
| persistent anger | | | section 3 |

## 10. Frog, allay, parrot, happy ghast, golems, bat

### 10.1 Frog

Key `variant` (section 4). The tongue target is not saved. Brain: section 11.

### 10.2 Allay

Chain: `PathfinderMob` (no `Age`, no `InLove`). The allay's held item is `equipment.mainhand`.

| Key | Type | Default | Notes |
|---|---|---|---|
| `Inventory` | List of `ItemStack` (without slot) | empty | `InventoryCarrier` (`TAG_INVENTORY`): save is `storeAsItemList`, one element per non-empty slot, in slot order. Load is `fromItemList`: the container is cleared and each element is added with the add-item operation (stacks merge into earlier slots of the same item). The allay constructor creates a `SimpleContainer` of 1 slot, so at most one stack persists. |
| `listener` | Compound (vibration listener state) | the default state | Fields: `selector` (required Compound `{tick: Long (required), event?: VibrationInfo}`), `event_delay` (non-negative Int, default 0, always written), `event` (optional VibrationInfo `{game_event: id, distance: Float, pos: Vec3, source?: UUID, projectile_owner?: UUID}`). In `selector`, `event` is a lenient optional field. In VibrationInfo `distance` is a required field (no default) restricted to the range 0 to 3.4028235E38 (the constant is the upper bound); `source` and `projectile_owner` are lenient optional fields. |
| `DuplicationCooldown` | Long | 0 | **Written as Long, read through the Int accessor**: a stored value above 2147483647 is truncated to its low 32 bits (section 1 conversion). |

### 10.3 Parrot

Chain: `TamableAnimal` through the shoulder-riding base (which adds no key). Key `Variant` (Int, section 4, default 0 red_blue). The shoulder-mount state of players belongs to part 3.

### 10.4 Happy ghast

| Key | Type | Default |
|---|---|---|
| `still_timeout` | Int | 0 |

The harness is `equipment.body`.

### 10.5 Copper golem

Chain: `PathfinderMob` (no `Age`).

| Key | Type | Default | Notes |
|---|---|---|---|
| `next_weather_age` | Long | **-1** | The game time of the next weathering step; -1 means none scheduled. |
| `weather_state` | String enum | `unaffected` | `unaffected` (0), `exposed` (1), `weathered` (2), `oxidized` (3). Unknown name gives `unaffected`. |

The item it carries is `equipment.mainhand`. The golem's action state is not saved. Its brain memories: section 11.

### 10.6 Iron golem

Keys: `PlayerCreated` (Byte, 0) and the persistent anger keys of section 3.

### 10.7 Snow golem

Key: `Pumpkin` (Byte, default **1**).

### 10.8 Bat

Chain: ambient creature (a `Mob`, no `Age`). Key: `BatFlags` (Byte, default 0): read with `getByteOr` and written with `putByte`; it is the synched flag byte. Bit 0 (value 1, constant `FLAG_RESTING`) is the resting flag; no other bit constant exists in the class.

## 11. Brain memories

`LivingEntity` writes the key `Brain`, a Compound `{memories: Compound}`. In `memories`, each key is the identifier of a memory module type and each value is an expirable-value Compound `{value: <the type's codec>, ttl: Long (optional)}`; `ttl` is present only for a memory that expires, and is the ticks remaining. Only memory types that have a codec are written (the `Brain` write never contains the others); a memory type without a codec cannot be read back (the validation rejects it as an error). The shared model is in 45-2 section 8.

Codec classes of the persisted memory types (all of them, for reading a file):

| Codec | Memory identifiers |
|---|---|
| Boolean (Byte) | `golem_detected_recently`, `danger_detected_recently`, `has_hunting_cooldown`, `is_panicking`, `universal_anger`, `admiring_item`, `admiring_disabled`, `hunted_recently` |
| Long | `last_slept`, `last_woken`, `last_worked_at_poi` |
| Int | `play_dead_ticks`, `temptation_cooldown_ticks`, `gaze_cooldown_ticks`, `long_jump_cooling_down`, `ram_cooldown_ticks`, `charge_cooldown_ticks`, `attack_target_cooldown`, `liked_noteblock_cooldown_ticks`, `item_pickup_cooldown_ticks` |
| Unit `{}` | `is_in_water`, `is_pregnant`, `recent_projectile`, `is_sniffing`, `is_emerging`, `roar_sound_delay`, `dig_cooldown`, `roar_sound_cooldown`, `sniff_cooldown`, `touch_cooldown`, `vibration_cooldown`, `sonic_boom_cooldown`, `sonic_boom_sound_cooldown`, `sonic_boom_sound_delay`, `breeze_jump_cooldown`, `breeze_shoot`, `breeze_shoot_charging`, `breeze_shoot_recover`, `breeze_shoot_cooldown`, `breeze_jump_inhaling`, `breeze_leaving_water` |
| `GlobalPos` | `home`, `job_site`, `potential_job_site`, `meeting_point`, `liked_noteblock` |
| `BlockPos` | `breeze_jump_target` |
| UUID | `angry_at`, `liked_player` |
| List of `GlobalPos` | `visited_block_positions`, `unreachable_transport_block_positions` (both a set stored as a list), `sniffer_explored_positions` (a list; order matters) |

All other memory types (walk target, look target, attack target, path, nearest-entity lists, `ride_target`, `transport_items_cooldown_ticks`, `sniffer_sniffing_target`, `sniffer_digging`, `sniffer_happy`, `spear_*`, and the rest) are not saved.

### Memories of the mobs of this part

Rule: any persisted memory present in the brain at save time is written, so the sets below are the persisted memory types that the mob's code sets (read in the mob classes, their AI class, and the shared behaviours they run); sensors may set `is_in_water` and similar flags at any time.

| Mob | Persisted memories the code sets | Values read |
|---|---|---|
| Allay | `liked_player` (UUID of the player who gave an item; no expiry; erased when the allay gives items back), `liked_noteblock` (`GlobalPos`, no expiry; set when a note block sounds nearby, erased when unusable), `liked_noteblock_cooldown_ticks` (Int set to 600 by `AllayAi`, in its note-block-heard handler: set together with `liked_noteblock` when no note block is liked yet, and set again to 600 when the heard position equals the liked one; a different position leaves it unchanged), `item_pickup_cooldown_ticks` (Int) | The two cooldowns are driven by the "count down cooldown" behaviour (`CountDownCooldownTicks`, read): it starts only while the memory value is greater than 0, each run sets value minus 1, and its stop action erases the memory (so the memory is erased once the value is no longer above 0). The same decrement-then-erase shape applies to both cooldown memories. |
| Frog | `is_pregnant` (Unit, set after breeding), `long_jump_cooling_down` (Int, initial `U(100, 140)`: the static constant `FrogAi.TIME_BETWEEN_LONG_JUMPS`, sampled in `FrogAi.initMemories`, which `Frog` calls on creation of its brain; the same constant is the cooldown range of the frog's long-jump behaviours), `temptation_cooldown_ticks`, `is_in_water` (Unit, from the sensor) | `U(a, b)` is a uniform integer. |
| Sniffer | `sniffer_explored_positions` (List of `GlobalPos`; a new position is inserted at index 0 after the existing list is limited to its first 20 entries, so the list holds at most 21 entries), `temptation_cooldown_ticks`, `is_panicking` | |
| Goat | `long_jump_cooling_down` (initial `U(600, 1200)`), `ram_cooldown_ticks` (initial `U(600, 6000)`), `temptation_cooldown_ticks`. A screaming goat uses `U(100, 300)` for the ram cooldown (the constant `TIME_BETWEEN_RAMS_SCREAMER`). | |
| Camel | `gaze_cooldown_ticks`, `temptation_cooldown_ticks` | |
| Armadillo | `danger_detected_recently` (Boolean, set true with an expiry of **80** ticks when hurt by a living entity), `gaze_cooldown_ticks`, `is_panicking`, `temptation_cooldown_ticks` | |
| Happy ghast | `is_panicking`, `temptation_cooldown_ticks` | |
| Copper golem | `gaze_cooldown_ticks`; when it runs the container-transport behaviour: `visited_block_positions` (at most 10 positions) and `unreachable_transport_block_positions` (at most 50), both set with an expiry of **6000** ticks and erased when a target is found or after a failed search; `transport_items_cooldown_ticks` is not persisted | |

The brain of the other mobs of this part (cow, pig, sheep, chicken, rabbit, horse family except the camel, cat, ocelot, wolf, fox, panda, polar bear, turtle, bee, parrot, iron golem, snow golem, bat) uses goals, not a Brain, apart from the shared `Brain` key every `LivingEntity` writes (an empty `memories` Compound for them: `LivingEntity` writes `Brain` unconditionally and `Brain$Packed` requires `memories`, so `{memories:{}}` is always present; 45-2 section 8.1).

## 12. Worked examples

All examples use the notation `key: Type value`. Common chain keys are omitted except where shown.

**Example 1: adult tamed wolf, red collar, angry.** Game time is 100000.

```text
id: "minecraft:wolf"
Health: Float 40.0   Age: Int 0   ForcedAge: Int 0   AgeLocked: Byte 0   InLove: Int 0
Owner: IntArray [I; 1, 2, 3, 4]    Sitting: Byte 0
CollarColor: Int 14
variant: "minecraft:pale"     sound_variant: "minecraft:classic"
anger_end_time: Long 100600    angry_at: IntArray [I; 9, 8, 7, 6]
```

Reading it: tamed with owner (1,2,3,4); collar red; anger ends at game tick 100600, so 600 ticks of anger remain; the target is resolved only on a server level. Removing `anger_end_time` and adding `AngerTime: Int 600` gives the same end time (100000 + 600).

**Example 2: llama with a chest, strength 3.**

```text
id: "minecraft:llama"
Strength: Int 3   Variant: Int 2   ChestedHorse: Byte 1
Items: [ {Slot: Byte 0, id: "minecraft:apple", count: 5}, {Slot: Byte 8, id: "minecraft:bread", count: 1} ]
equipment: { body: {id: "<a carpet item key>", count: 1} }
```

Strength 3 and a chest give 3 columns, so 9 slots (0 to 8). Both elements are valid. An element with `Slot: 9` would be dropped. `Strength: 9` reads as 9 but the setter clamps it to 5; the inventory is created with the clamped value because `Strength` is read first.

**Example 3: horse packed variant.** Colour chestnut (2), marking white_dots (3): `(2 & 255) | ((3 << 8) & 65280) = 2 | 768 = 770`. Saving writes `Variant: Int 770`; loading 770 gives colour `770 & 255 = 2` and marking `(770 & 65280) >> 8 = 3`.

**Example 4: camel.** `LastPoseTick: Long -40` loads as sitting (negative), with last-pose-change set to -40. `LastPoseTick: Long 0` (or absent) loads as standing.

**Example 5: mooshroom with stew.** `Type: "brown"`, `stew_effects: [ {id: "minecraft:night_vision", duration: 100} ]`. A list entry without `duration` uses 160.

**Example 6: bee.** `HasNectar: 1`, `hive_pos: [I; 100, 64, -20]`, `TicksSincePollination: 250`; absent `flower_pos` means no remembered flower.

**Example 7: sniffer Brain.**

```text
Brain: { memories: {
  "minecraft:sniffer_explored_positions": { value: [ {dimension: "minecraft:overworld", pos: [I; 10, 70, 10]} ] },
  "minecraft:temptation_cooldown_ticks": { value: 40, ttl: Long 40 } } }
```

Position list newest first; the `ttl` field is present when the memory expires.

## 13. Validation and migration rules

1. Key names are case-sensitive. Mixed styles are exact: `CollarColor`, `RabbitType`, `EggLayTime`, `HasNectar` (upper camel) against `home_pos`, `hive_pos`, `has_egg`, `scute_time`, `state`, `variant`, `sound_variant`, `still_timeout`, `weather_state`, `next_weather_age`, `anger_end_time`, `angry_at` (snake case).
2. A type mismatch never raises an error: numeric keys accept any numeric tag (section 1), String keys accept only Strings, and the default applies otherwise. A Byte-valued boolean key accepts any numeric whose Byte conversion is non-zero.
3. Out-of-range enum ids: dye colour (ZERO), llama and parrot (CLAMP), horse colour and marking (WRAP) map by the strategies in section 2 and 4; rabbit maps unknown ids to brown; unknown enum names give the default shown.
4. `Strength` is clamped to 1 to 5 by the setter; `Temper` is not clamped.
5. A variant identifier that does not exist in the loaded registry is ignored and the variant keeps its creation value; the same holds for `sound_variant`. A world therefore loads when a data pack drops a variant.
6. Chested-horse items outside `0..size-1`, items on a mob without a chest, and `Items` elements that fail to decode are dropped silently.
7. `Owner`: a UUID IntArray of the wrong length is ignored; a String is converted by the old-user conversion.
8. The `equipment` Compound drops slot entries holding empty stacks; a slot key that is not one of the eight names makes that entry fail to decode. What the whole-map outcome is after a failed entry depends on whether the map codec yields a partial value (section 1, `read(key, codec)`; Open question 5), so a bad entry does not necessarily discard the whole value.
9. The Brain `memories` map has one entry per persisted memory. A type with no codec is rejected by validation. Because a failed field read returns the codec's partial value when there is one (section 1), a bad entry does not necessarily discard the whole Brain; whether the memories codec produces a partial map was not traced (Open question 5).
10. When a TamableAnimal's `Owner` is unreadable, the animal loads untamed even if the old game saved `Tame` (there is no `Tame` key on tameable animals; the tamed flag derives from `Owner`). Horses differ: they have both `Tame` and `Owner`.
11. `DuplicationCooldown` of the allay is written as Long and read as Int; a value written by this game is a small positive number, so the narrowing is harmless in practice.

## 14. Open questions

1. The default entry of `variant` for animals created without a registry lookup (for example by a command that gives no variant) comes from the data-driven spawn-variant engine; only the code constants are given here.
2. The legacy data fixers (`SaddleItem`, `ArmorItem`, `Tame`, old `Variant` values, the `Color` Byte of sheep) are applied before the entity classes read and live in the data fixer, which this round did not read. These classes read `Color` and `RabbitType` through numeric conversion, so Byte values load.
3. The behaviour that sets `item_pickup_cooldown_ticks` on the allay (argument 60 of the give-items behaviour) was read as a constant; whether it is the cooldown length was not traced. The 600 of `liked_noteblock_cooldown_ticks` is read in `AllayAi` (no longer open).
4. `sniffer` drop seeds: the spec asked for "sniffer state and seeds"; the artifact stores neither (section 9.2). The seed items dropped by digging come from a loot table of the data pack (not read here). `still_timeout` of the happy ghast and `next_weather_age` of the copper golem are saved counters whose use (the tick logic) is in 44 part 4 and 19 and was not re-read in this round.
5. (Searched again: the client jar contains no `com/mojang/serialization` classes, so the DFU codec implementations cannot be read from it; this stays open.) Partial-value behaviour per codec: `TagValueInput.read` returns the error result's partial value, but whether the `equipment` map codec, the Brain `memories` dispatched-map codec, the variant codecs and the list codecs produce a partial value for one bad entry was not traced (searched: `TagValueInput.read`, which was read; the codec classes were not).
6. The per-element skip behaviour of `listOrEmpty` and `list` (section 1) is inferred from the existence of per-element problem classes and was not read in the list wrapper methods.
7. (Resolved in this fixing pass.) `MobEffect.CODEC` is the built-in mob-effect registry's `holderByNameCodec`, which is the identifier codec (a String such as `minecraft:speed`) flat-mapped to a registry reference. The mooshroom `stew_effects` `id` is therefore an identifier String. What an unknown identifier does (expected: a decode error for that element) was not traced.
8. The `body` slot rule (which items an equine or llama accepts) was not traced; only the saddle rule was read.
9. The `Fox` `TRUSTED_LIST_CODEC` was seen as a list codec of entity references; its exact form (list of UUID IntArrays) follows from section 2 and was not traced in the codec itself (inferred).
10. The meaning of the bee `TicksSincePollination` counter is taken from the field name only (section 9.5); its tick logic was not read.
