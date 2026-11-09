# 45. Entity NBT, part 1: shared model and the Entity base

| Item | Value |
|---|---|
| Covers | Round RS27 part 1: the rules every entity compound follows (read and write paths, key typing, defaults, failure behaviour, version handling), the `Entity` base keys, passengers and the player's `RootVehicle`, the ItemStack compound with data components, slot lists, and the shared helpers reused by many types (leash, containers with loot tables, inventory carriers, entity references, block and global positions, variant holders, vehicle and hanging bases). It also holds the schema notation of all siblings, the owner index of the 161 entity type keys, and the extension of 07 section 9.3 and 9.4 for the standard world type. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`; protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `Entity`, `EntityType`, `EntityTypes`, `EntityTypeIds`, `TagValueInput`, `TagValueOutput`, `ItemStack`, `Item`, `ItemStackWithSlot`, `DataComponentPatch` and its `PatchKey`, `Removed`, `ContainerHelper`, `SimpleContainer`, `InventoryCarrier` (package `net.minecraft.world.entity.npc`), `ContainerEntity`, `Leashable` and `Leashable$LeashData`, `EntityReference`, `VariantUtils`, `BlockAttachedEntity`, `HangingEntity`, `VehicleEntity`, `TamableAnimal`, `ServerPlayer` (vehicle parts), `EntityStorage`, `PersistentEntitySectionManager`, `PlayerDataStorage`, `UUIDUtil`, `Vec3`, `Vec2`, `BlockPos`, `GlobalPos`, `ExtraCodecs`, `NbtUtils`, `DataFixTypes`. |
| Evidence rule | Every key, type, default and constant below was read in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. Where the artifact differs from common expectation (several base keys are `snake_case` in 26.3), the artifact wins. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-8 entity NBT). Loot tables, recipes and registries are data and are not tabulated here. The DataFixer rules (how old tags are upgraded) are code that this round does not specify (Open question 1). Siblings: part 2 (LivingEntity, Mob, Animal), part 3 (Player), parts 4 to 9 (families, section 12). Cross-references use "NN section"; their content is not repeated. |

Conventions: "compound" is an NBT Compound (07 section 1). Types are written `Byte`, `Short`, `Int`, `Long`, `Float`, `Double`, `String`, `List<T>`, `Compound`, `Int Array(n)`. Yaw and pitch are degrees as Float. "Absent" means the key is not in the compound.

## Contents

1. How a compound is read and written
2. Schema notation used by all siblings
3. Shared value forms
4. Identity: the `id` key, lookup, unknown ids, types that are never saved
5. The Entity base keys
6. Order of load, validation and failure outcomes
7. Passengers and the player's `RootVehicle`
8. The ItemStack compound and data components
9. Slot lists: `Items`, `Inventory`
10. Shared helpers: leash, container entity, inventory carrier, owner, variant, positions
11. Bases without keys of their own: VehicleEntity, HangingEntity, BlockAttachedEntity
12. Owner index of entity type keys
13. Extension of 07 section 9.3 and 9.4
14. Worked examples
15. Validation checklist
16. Open questions

---

## 1. How a compound is read and written

All entity code reads and writes through two small interfaces (`ValueInput`, `ValueOutput`) implemented over an NBT Compound (`TagValueInput`, `TagValueOutput`). Their behaviour is the common rulebook; siblings state only the keys.

### 1.1 Read path (`TagValueInput`)

| Operation | Behaviour |
|---|---|
| `read(key, codec)` | Key absent: no value. Present: the codec decodes the tag. On a decode error a problem (key, tag, message) is reported to the problem collector (logged with the entity's path) and the call returns the partial value if the codec produced one, otherwise no value. The caller then applies its own default (most calls use `orElse(default)`). |
| Numeric getters (`getBooleanOr`, `getByteOr`, `getShortOr`, `getIntOr`, `getLongOr`, `getFloatOr`, `getDoubleOr`) | Key absent: the default. Present and any numeric tag (Byte, Short, Int, Long, Float, Double): converted with the narrowing conversion of the requested type (`byteValue`, `shortValue`, `intValue`, `longValue`, `floatValue` and `doubleValue` were all read in the getters). Present and not numeric: a problem is reported ("expected a number") and the default is returned. |
| Boolean | `getBooleanOr` tests the tag's `byteValue` for non-zero. So Byte 1 and Int 1 are true, Int 256 narrows to Byte 0 and is false (a quirk to keep for byte-exact behaviour). |
| `getString`, `getStringOr` | The tag must be String; any other tag type reports a type problem and counts as absent. |
| `getString` (Optional form), `getIntArray` | Typed-tag lookup: only a String tag (respectively an Int Array tag) is accepted; absent or any other type is an empty Optional. |
| `getInt`, `getLong` (Optional forms) | Go through the same numeric lookup as the `...Or` getters: ANY numeric tag (Byte, Short, Int, Long, Float, Double) is accepted and narrowed with `intValue` (respectively `longValue`). Only absent or a non-numeric tag gives an empty Optional. The narrowing is read in the tag classes. `DoubleTag.intValue`, `shortValue` and `byteValue` use `Mth.floor(double)` (`Math.floor`, then a saturating double-to-int; short and byte then keep the low 16 or 8 bits of that int). `DoubleTag.longValue` is `Math.floor` then a saturating double-to-long. `FloatTag.intValue`, `shortValue` and `byteValue` use `Mth.floor(float)` (widened to double, floored, saturating int). `FloatTag.longValue` is a plain float-to-long conversion that truncates toward zero, NOT a floor. So `{x: 3b}` reads as Int 3, `{x: 2.9d}` as Int 2, `{x: -2.9d}` as Int -3 and `{x: -0.5d}` as Int -1; a Float -2.9f as Long reads -2 but as Int reads -3. The boolean test uses the floored byte, so `0.5d` is false and `1.5d` is true. |
| `child(key)`, `childOrEmpty(key)` | Compound child (empty Optional or an empty reader when absent or not a compound). |
| `childrenList(key)`, `childrenListOrEmpty(key)` | List of compounds. Elements that are not compounds are rejected with a problem (inferred from the nested problem classes `UnexpectedListElementTypeProblem`). |
| `list(key, codec)`, `listOrEmpty(key, codec)` | List decoded element by element with the codec; each element error reports a problem for that element (class `DecodeFromListFailedProblem`) and the rest continue (inferred). |

Unknown keys are ignored: there is no strict mode. A compound can carry extra keys (for example `data`, or keys of mods) and they are dropped on the next save, except under the `data` key (section 5).

### 1.2 Write path (`TagValueOutput`)

| Operation | Behaviour |
|---|---|
| `putBoolean(key, b)` | Writes a Byte, 1 or 0. |
| `putByte`, `putShort`, `putInt`, `putLong`, `putFloat`, `putDouble`, `putString`, `putIntArray` | Writes the tag of that type. |
| `store(key, codec, value)` | Encodes with the codec and puts the tag. An encode error is reported as a problem and the partial value is stored if present. |
| `storeNullable(key, codec, value)` | Null value: nothing is written. Otherwise as `store`. This is the "optional-key omission" form. |
| `child(key)`, `childrenList(key)`, `list(key, codec)` | Opens a nested compound, a list of compounds or a typed list. A list can `discardLast()` (drop the element just added) and be tested `isEmpty()`. |
| `discard(key)` | Removes a key that was already written (used to drop an empty `Passengers` or `Items`). |

Insertion timing (read in `TagValueOutput.child`, `childrenList` and `list`): each of the three creates its (initially empty) Compound or List and puts it into the parent compound at the moment of the call, before anything is added to it. Consequence: a nested compound or list whose content stays empty is still present in the output as an empty compound or empty list, unless the caller removes it with `discard(key)`. Search done in this round: every `invokeinterface ValueOutput.discard` call in the classes of `net.minecraft.world.entity.*` (all subpackages), `net.minecraft.world.Container*`, `SimpleContainer`, `ServerPlayer` and `net.minecraft.world.level.block.entity.*` was listed. In the entity classes the only caller is `Entity` (the `Passengers` code of section 7.1); outside them `ContainerHelper` (the optional-omission form of section 9.1) calls it, and so do several block entity classes (not described here). The rest of `net.minecraft` (other packages) was not scanned (Open question 17). So within the scanned entity classes every other typed list, for example `Inventory` (section 9.2), is therefore written even when empty.

A save never aborts on a codec problem; the problem is logged and the compound is still produced. A thrown exception inside a save becomes a crash report "Saving entity NBT" (`Entity being saved`); a thrown exception inside a load is wrapped as "Loading entity NBT" and then caught by the loader (section 6).

### 1.3 Key naming

Keys are case-sensitive. 26.3 mixes two styles: legacy keys in PascalCase that predate the change (`Pos`, `Motion`, `Rotation`, `Fire`, `Air`, `OnGround`, `Invulnerable`, `PortalCooldown`, `UUID`, `CustomName`, `CustomNameVisible`, `Silent`, `NoGravity`, `Glowing`, `TicksFrozen`, `HasVisualFire`, `Tags`, `Passengers`, `Team`) and keys in `snake_case` (`id`, `fall_distance`, `invulnerable_time`, `data`, `leash`, `block_pos`, `variant`). Do not normalize: the reader looks up the exact string. Note: `FallDistance` (PascalCase) is NOT the key in this version; it is `fall_distance` (a Double). `invulnerable_time` is new relative to common expectation.

### 1.4 Version handling

| Where | Rule |
|---|---|
| `DataVersion` | An Int in the root compound of an `entities/` chunk payload and of a player `.dat`. Written as the current data version (5023 in this artifact) by `NbtUtils.addCurrentDataVersion` on every save. Entity compounds inside the `Entities` list do NOT carry their own `DataVersion`. |
| Entity chunk read | The payload is passed through the DataFixer type `ENTITY_CHUNK` from its stored `DataVersion` to 5023 before any entity is built. The call in `EntityStorage` is `upgradeChunkTag(tag, -1)`; the two-argument `upgradeChunkTag` supplies the current version (5023, from the game's `WorldVersion`) as target. The stored version is `NbtUtils.getDataVersion(tag, -1)`: the stored numeric `DataVersion`, or -1 when the key is absent or not numeric (-1 is the fallback for a missing version, not a default fixer version). If the stored version is greater than or equal to 5023, the tag is returned unchanged and no fixer runs, so a payload from a newer game is read as is and is not refused. Otherwise the fixer of the `DataFixTypes` constant of the storage runs from the stored version to 5023 and `DataVersion` 5023 is written into the tag (a fixer exception becomes a crash report "Updated chunk"). `DataFixTypes.ENTITY_CHUNK` is referenced from `ServerLevel`, not from `EntityStorage`. |
| Player read | The `.dat` is passed through the DataFixer type `PLAYER` the same way. |
| Entity compounds inside other containers (spawn eggs, spawners, buckets, `data` of items) | The fixer type `ENTITY` applies; not specified here (Open question 1). The `entity_data` item component (`TypedEntityData`, spawn eggs) and `bucket_entity_data` (buckets) are specified in part 7 (`45-entity-nbt-7-aquatic-and-misc-mobs.md`) sections 8 and 9; not repeated here. |
| Interim rule for CobolCraft | Accept `DataVersion` equal to 5023; refuse older payloads with a clear message (the fixers are not specified). A version above 5023 is passed through unchanged by the game itself (row above); whether CobolCraft should accept it is a project decision (Open question 2). (This is a project decision, not an artifact finding.) |

---

## 2. Schema notation used by all siblings

Every per-type table uses these columns:

| Column | Meaning |
|---|---|
| Key | Exact key string. |
| NBT type | The tag written. `Int Array(3)` is a fixed-length Int Array. A codec name from section 3 may appear instead (for example `UUID`). |
| Default | The value used when the key is absent or fails to decode. "none" means absence is meaningful (null, empty, or "unset"). |
| Validation | Range, clamp, rejection or side effect on load. "-" means none was read. |
| Written when | "always", or the condition under which the key is omitted. |

Rules for sibling tables:

1. A table lists the keys written by that class only; inherited keys are named by a reference line "inherits: Entity base (45 section 5), ..." and never copied.
2. The save order follows the order of the class chain: base (this part), then each subclass from the most generic to the most specific. Order inside a compound does not matter to a reader (compounds are unordered, 07 section 1.2), but writers should keep it for diff-friendliness.
3. A key written conditionally is marked with the condition; a reader must treat absence as the default.
4. Worked examples use the compact textual form `{key: value}` with type suffixes `b` (Byte), `s` (Short), `L` (Long), `f` (Float), `d` (Double), unsuffixed integers as Int, and `[I; a, b, c]` for Int Arrays.

---

## 3. Shared value forms

| Form | NBT form | Decode rule | Read at |
|---|---|---|---|
| `Vec3` (Pos, Motion) | `List<Double>` of exactly 3 | The element codec is Double (numeric tags coerce); a list with a length other than 3 is an error ("fixed size"). Order x, y, z. | `Vec3.CODEC` |
| `Vec2` (Rotation) | `List<Float>` of exactly 2 | Order yaw (`yRot`), pitch (`xRot`), in degrees. Other length is an error. | `Vec2.CODEC` |
| `UUID` | `Int Array(4)` | `[a, b, c, d]` gives most-significant long `(a << 32) | (b & 0xFFFFFFFF)` and least-significant long `(c << 32) | (d & 0xFFFFFFFF)`. Writing is the inverse: the high 32 bits of the most-significant long first. A length other than 4 is an error. A String form is NOT accepted by the plain codec (only the profile codec has an alternative). | `UUIDUtil.CODEC` |
| `BlockPos` | `Int Array(3)` | `[x, y, z]`. | `BlockPos.CODEC` |
| `GlobalPos` | `Compound {dimension: String, pos: Int Array(3)}` | `dimension` is a dimension resource key (an identifier such as `minecraft:overworld`), `pos` a `BlockPos`; both required. | `GlobalPos.CODEC` |
| `ChunkPos` | `Int Array(2)` | `[chunkX, chunkZ]` (07 section 9.3). | `ChunkPos.CODEC` |
| Identifier | `String` | `namespace:path`; a string without a colon is read in the namespace `minecraft` (inferred from `Identifier.tryParse` and the constant `DEFAULT_NAMESPACE = "minecraft"`). Writers always write the full form. | `Identifier.CODEC` |
| Registry key / holder | `String` identifier | Looked up by name in the registry named by the context; an unknown name is a decode error (inferred), which the caller turns into "absent". | `byNameCodec`, `holderByNameCodec` |
| Text component | String, Compound or List per the component codec | The JSON-shaped text component in NBT form (00 section 9.1 for the wire form; here the on-disk form is the same codec without the network wrapper). | `ComponentSerialization.CODEC` |
| Entity reference | `Int Array(4)` (a UUID) | Section 10.4. | `EntityReference.codec()` |

---

## 4. Identity: the `id` key, lookup, unknown ids, types never saved

### 4.1 Writing `id`

`Entity.save` (top level) and `saveAsPassenger` (passengers, section 7) write `id` as a String: the entity type's registry key as a full identifier, for example `minecraft:pig` (`getEncodeId`: the key of the type's holder, `Identifier.toString`). Nothing is written, and the call returns `false`, when:

1. the entity has a removal reason whose `shouldSave` is false. The enum `Entity$RemovalReason` has five constants, each built with two booleans; read as (first, second) = (KILLED: true, false), (DISCARDED: true, false), (UNLOADED_TO_CHUNK: false, true), (UNLOADED_WITH_PLAYER: false, false), (CHANGED_DIMENSION: false, false). The two constructor fields are named `destroy` (first) and `save` (second) and `shouldSave()` returns `save` (field names and getters read), so only `UNLOADED_TO_CHUNK` saves. An entity with no removal reason (alive) saves;
2. the type's `serialize` flag is false (section 4.3);
3. (top-level `save` only) the entity is a passenger (it is saved by its vehicle).

### 4.2 Loading: lookup and unknown ids

`EntityType.create(ValueInput, level, request)` is the loader entry:

1. Read `id` through the entity type registry's by-name codec (identifier string to type). Absent, malformed or unknown: no type.
2. No type: log a warning "Skipping Entity with id {}" with the raw `id` string (the text `[invalid]` when `id` is absent or not a String) and produce no entity. Nothing else is touched: the rest of the compound is dropped. On the next save of that chunk the entry is gone (the data of an unknown type is lost, not preserved).
3. Type found: `type.create(level, request)` builds a fresh entity with a random UUID, then `Entity.load` (section 6) applies the compound. The request is an `EntitySpawnRequest` record of two fields, `reason` (an `EntitySpawnReason`) and a boolean `ignoreChecks`. When `ignoreChecks` is false, `create` first runs the type's `canSpawn(level)` and returns no entity when it fails: `canSpawn` is false when the type is not enabled by the level's enabled feature flags, or when the type is not allowed in peaceful (its `allowedInPeaceful` flag is false) and the level difficulty is PEACEFUL; otherwise true. A null result is an empty Optional and is logged like an unknown id ("Skipping Entity with id {}"). Every request built by the chunk loader and the player-vehicle loader has `ignoreChecks` false (the reason-taking loader overloads construct `(reason, false)`), so in a peaceful world a type with `allowedInPeaceful` false is skipped on load and lost at the next save of its chunk. The 38 types with that flag false (a `notInPeaceful` call in their `EntityTypes` builder) are tabulated in section 12.1. `piglin` is NOT among them (`piglin_brute` and `zombified_piglin` are).
4. Any `RuntimeException` during steps 3 or `load` (including the "Entity has invalid position" and "Entity has invalid rotation" errors, and a `ReportedException` wrapping a thrown error) is caught by `loadStaticEntity`: a warning "Exception loading entity:" with the exception is logged and the entity is skipped. The catch covers ONLY this create-and-load stage (the exception table of both `loadStaticEntity` overloads spans just the call to `create`); an exception thrown later by the entity processor (step 5) or while loading passengers is not caught here.
5. The loader then runs the entity processor (an `EntityProcessor`: a function from an entity to an entity; the constant `NOP` returns its argument), then loads passengers (section 7). The loader chains these on the Optional as map(processor) then map(load passengers), so a failed step 1 to 4 skips both.

The spawn reason used by chunk loading and by player-vehicle loading is `LOAD`. Mobs consult it (for example to skip spawn-time equipment and variant rolls); the effect is stated by siblings that read it.

### 4.3 Types that are never saved

`EntityType.canSerialize()` is false for exactly four types in this artifact (read from the `noSave` calls in `EntityTypes`):

| Type | Also `noSummon` | Note |
|---|---|---|
| `minecraft:player` | yes | Saved in its own file (section 7.3 and part 3). |
| `minecraft:fishing_bobber` | yes | Lost on unload. |
| `minecraft:lightning_bolt` | no | Lost on unload. |
| `minecraft:leash_knot` | no | Never saved: its holder position is stored on each leashed mob (`leash` as a block position, section 10.1) and the knot is recreated on load. |

`onlyOpCanSetNbt` is true for `falling_block`, `command_block_minecart` and `spawner_minecart` (the set `OP_ONLY_CUSTOM_DATA`): a command that sets entity NBT on these needs operator permission (15 section 2 documents the command permission model; the command catalog in 16 does not repeat it).

---

## 5. The Entity base keys

Written by `Entity.saveWithoutId` in the table order below (the write order of the strings was read; `Team` is read-only and is the one row with no write), then `addAdditionalSaveData` of the concrete class chain (siblings), then `Passengers`. `id` is written before all of them by the caller (section 4.1).

| Key | NBT type | Default on load | Validation on load | Written when |
|---|---|---|---|---|
| `Pos` | `List<Double>(3)` | `[0.0, 0.0, 0.0]` when absent or undecodable | Each of x and z is clamped to the range -30000512 to 30000512 (the literal `3.0000512E7`), y to -20000000 to 20000000, then the three must be finite. Each component goes through `Mth.clamp(value, min, max)`, which returns min when value is below min and otherwise the smaller of value and max (the comparison with NaN is false, so NaN falls to `Math.min(NaN, max)` = NaN). Therefore +Infinity becomes the max and -Infinity the min, both finite, and only NaN fails the finiteness check ("Entity has invalid position"). Example: `Pos: [Infinity, 0, 0]` loads at x = 30000512. A passenger's own `Pos` is overwritten by the vehicle link (section 7). | always. For a passenger, the value written is the VEHICLE's position, not the passenger's. |
| `Motion` | `List<Double>(3)` | `[0, 0, 0]` | Each component whose absolute value exceeds 10.0 is replaced by 0.0 (per component, not per vector). The entity is marked as needing a sync. | always |
| `Rotation` | `List<Float>(2)` yaw, pitch | `[0.0, 0.0]` | Both must be finite, with no clamp: NaN and both infinities fail ("Entity has invalid rotation"). After applying, the old rotation fields are reset to the new values, head rotation and body rotation are set to the yaw, and `setRot(yaw, pitch)` runs (normalization inside `setRot` was not read, Open question 3). | always |
| `fall_distance` | Double | 0.0 | - | always |
| `Fire` | Short | 0 | Read with the Short getter, so a stored Int is narrowed to 16 bits. Stored in `remainingFireTicks`. | always (the value written is the remaining fire ticks as a Short) |
| `Air` | Short written, read as Int | the type's maximum air supply (300 for the base class; the constant was read in `getMaxAirSupply`; subclasses override) | Applied through `setAirSupply`. | always (written as Short from `getAirSupply`) |
| `OnGround` | Byte (boolean) | false | - | always |
| `Invulnerable` | Byte (boolean) | false | The permanent-invulnerability flag (creative and similar), distinct from `invulnerable_time`. | always |
| `PortalCooldown` | Int | 0 | - | always (written BEFORE `invulnerable_time`; on load `invulnerable_time` is read first, so the two are read in the reverse of their write order) |
| `invulnerable_time` | Int | 0 | - | only when greater than 0 (the post-hit invulnerability counter) |
| `UUID` | UUID (`Int Array(4)`) | the random UUID the entity got at creation | Applied when present and valid. A duplicate of a UUID already in the world is rejected at insertion time, not at load (section 6). | always |
| `CustomName` | text component | none (no name) | Decode errors leave the name unset. | only when a name is set (`storeNullable`) |
| `CustomNameVisible` | Byte | false | - | only when true |
| `Silent` | Byte | false | - | only when true |
| `NoGravity` | Byte | false | - | only when true |
| `Glowing` | Byte | false | Sets the glowing TAG (the data flag that makes the entity glow); effects such as spectral arrows set the same field. | only when the glowing tag is set |
| `TicksFrozen` | Int | 0 | Applied through `setTicksFrozen`. | only when greater than 0 |
| `HasVisualFire` | Byte | false | - | only when true |
| `Tags` | `List<String>` (at most 1024 entries) | empty | The set is cleared first, then filled. A list longer than 1024 fails the size limit and the codec reports an error (the tag set stays empty unless the codec returns a partial list; Open question 4). The same limit holds at run time: `Entity.addTag` returns false without adding when the set already holds 1024 entries, so a 1025th tag is refused (read: size compared with 1024). | only when the set is non-empty. Order written follows `List.copyOf` of the set (no defined order). |
| `data` | Compound (custom data) | empty | The codec is the custom-data codec: a Compound, with an alternative of a String holding SNBT that is parsed (inferred from the `COMPOUND_TAG_CODEC` built with `withAlternative`). It is the only free-form storage for commands and data packs. | only when non-empty |
| `Team` | String | none | READ ONLY in the base. On load the level's scoreboard is asked for a team with the stored name. If it exists, the entity is added to it under the entity's UUID string (`getStringUUID`, the textual UUID, NOT the entity's name). If the team is missing or the add fails, the warning `Unable to add entity to team "{}" (that team probably doesn't exist)` is logged (with the stored name) and the entity loads without a team. The string `Team` occurs once in `Entity` (the load) and not at all in `ServerPlayer`; `LivingEntity`, `Mob`, `Player` and `Animal` were checked for a save of `Team` and none exists (the team membership lives in the scoreboard data, Open question 5). | never in these classes |
| `Passengers` | `List<Compound>` | none | Section 7. | only when the entity has passengers and at least one of them saved. |

Notes:

1. `Fire`, `Air`, `fall_distance`, `OnGround`, `Invulnerable` and `PortalCooldown` are written every time even at their default values, so a freshly saved compound is never smaller than these six plus `id`, `Pos`, `Motion`, `Rotation`, `UUID`.
2. The Short types of `Fire` and `Air` limit them to -32768 to 32767. `Air` is read as Int (the getter takes any numeric tag) but always written as Short.
3. `Glowing` is the stored TAG only; whether the entity currently renders as glowing also depends on the glowing effect and the shared flag (18 section 1.4 for the entity metadata base slots and the flags byte; 12 section 7 only covers the player model).
4. `Entity.restoreFrom(other)` (used for dimension travel and respawn copies) round-trips through a temporary compound with `saveWithoutId` then `load`, so anything that is not in the save list is not carried over (part 3 for the player case). Exceptions read: because it uses `saveWithoutId` there is no `id` key and `Passengers` is saved but not reloaded onto the copy by the entity loader; and after the load it copies `portalCooldown` and the `portalProcess` field directly from the source entity, so these two are carried over even though `portalProcess` is never persisted.

---

## 6. Order of load, validation and failure outcomes

`Entity.load(ValueInput)` runs, in this order, inside a guard that converts a thrown error into the "Loading entity NBT" report:

1. Read `Pos`, `Motion`, `Rotation` (defaults zero).
2. Replace each `Motion` component beyond magnitude 10 by 0 and set the motion; mark the entity needing a sync.
3. Clamp and set the raw position; set yaw and pitch; reset old position and rotation; set head and body rotation to the yaw.
4. Read `fall_distance`, `Fire`, `Air`, `OnGround`, `Invulnerable`, `invulnerable_time`, `PortalCooldown`.
5. Read `UUID` (applied if present).
6. Check position finiteness (x, y, z) then rotation finiteness (yaw, pitch). Position was clamped in step 3, so infinities are already finite and only a NaN position component throws "Entity has invalid position". Rotation has no clamp: a NaN or infinite yaw or pitch throws "Entity has invalid rotation".
7. Re-apply the position to the bounding box (`reapplyPosition`), `setRot`.
8. Read `CustomName`, `CustomNameVisible`, `Silent`, `NoGravity`, `Glowing`, `TicksFrozen`, `HasVisualFire`.
9. Read `data`, clear the tag set, read `Tags`, read `Team` (joins the scoreboard team by the entity's UUID string, or logs the "Unable to add entity to team" warning; row `Team` in section 5).
10. Call `readAdditionalSaveData` of the concrete class (siblings). Inside a sibling, the same defaults-on-failure rule applies; a sibling that throws aborts the whole entity.
11. If `repositionEntityAfterLoad` is true (the base returns true; some classes override to false), re-apply the position once more (a sibling may have changed the dimensions). `BlockAttachedEntity` is an override that returns false (read), so paintings, item frames and leash knots keep the block position set by their own read (section 11.3).

Outcomes:

| Failure | Result |
|---|---|
| Key absent | Default of the table row. No log. |
| Key present with a wrong tag type or a codec error | Problem logged; default (or partial value). The entity still loads. |
| NaN position (infinite positions are clamped and load), non-finite rotation, an exception in a sibling read, a registry lookup throwing | The entity is skipped with the warning "Exception loading entity:" (section 4.2 step 4). Its passengers are not loaded either (they are loaded from the same compound after the entity exists). |
| Unknown `id` | Skipped with "Skipping Entity with id {}". |
| A UUID already in use by a loaded entity | The insertion into the world refuses the entity: a warning "UUID of added entity already exists: {}" and the entity is not added (`PersistentEntitySectionManager.addEntityUuid`). A vehicle that is refused still has its passengers created and attached to it as objects (section 7.3: the UUID refusal happens in the processor, after which the entity is returned regardless); each passenger then goes through the processor on its own, so each is tried individually. |
| Position is outside the stored chunk | Not checked. The entity is filed under the chunk of its position at insertion (section 13), not under the chunk of the file it was read from. |

---

## 7. Passengers and the player's `RootVehicle`

### 7.1 Saving passengers

For an entity that is a vehicle, `saveWithoutId` writes `Passengers` as a list of compounds: for each passenger in `getPassengers()` order, a new child compound is added and `saveAsPassenger` fills it (section 4.1 writes `id` then everything of section 5). If `saveAsPassenger` returns false (a player, a fishing bobber, a removed entity), the child is discarded again. If the list ends up empty, the `Passengers` key is removed. A passenger's `Pos` is the vehicle's position (section 5) and the nested passengers recurse (a boat carrying a villager leading a pet: depth is unbounded by the format).

`Entity.save` (top level) returns false for a passenger: passengers are never stored as separate entries of the chunk list.

### 7.2 Which vehicles are saved in a chunk

`shouldBeSaved` is false when: the removal reason does not save; or the entity is a passenger; or the entity is a vehicle with EXACTLY ONE player passenger anywhere under it. The last case moves the whole vehicle tree into the player's file (section 7.3). A vehicle carrying two players is saved in the chunk without the players, and neither player gets a `RootVehicle`.

### 7.3 Loading passengers

`EntityType.loadEntityRecursive` loads the root, passes it to the processor (which adds it to the world), then `loadPassengersRecursive`: reads `Passengers` with `childrenListOrEmpty`, for each compound runs the whole loader again (so unknown ids and failures skip only that passenger), and attaches each successfully loaded passenger with `startRiding(vehicle, force = true, sendEvents = false)`. Read from the bytecode: the loader maps the processor over the Optional and then maps the passenger loader over the result. The chunk-load processor (the callback behind `loadEntitiesRecursive`) calls its consumer (which may refuse the entity, for example on a duplicate UUID) and then returns the entity unconditionally. Passengers are therefore always created and attached to the (possibly not added) vehicle object; the UUID refusal happens later, inside the consumer, and never stops passenger loading. The reason-taking overloads give passengers a request `(reason, ignoreChecks = false)` (section 4.2); the request-taking overload passes its request through to passengers unchanged. The processor contract: it returns the entity to continue with, and the chunk path never returns null. Because each entity is passed to the processor before its passengers, the chunk's entity stream is depth-first, vehicle first. A passenger that fails to load is simply absent; the other passengers still attach.

### 7.4 `RootVehicle` in a player file

Written by `ServerPlayer.saveParentVehicle` when the player has a vehicle, the root of the vehicle chain is not the player, and that root has exactly one player passenger:

| Key | NBT type | Meaning |
|---|---|---|
| `RootVehicle` | Compound | Present only in the above case. |
| `RootVehicle.Attach` | UUID (`Int Array(4)`) | The UUID of the entity the player directly rides. |
| `RootVehicle.Entity` | Compound | The full save of the root vehicle (its `id`, base keys, `Passengers` tree, which excludes the player), written with `save` (not `saveAsPassenger`). |

Load (`loadAndSpawnParentVehicle`, called after the player is placed in the world): no `RootVehicle` means nothing happens. Otherwise load the root with `loadEntityRecursive` (reason `LOAD`, processor adds it to the player's level). Then find the attach target: if the root's UUID equals `Attach`, the player `startRiding(root, true, false)`; otherwise the first indirect passenger whose UUID equals `Attach` is used; if none matches or the player is still not a passenger afterwards, log "Couldn't reattach entity to player" and discard the root and all its indirect passengers (the vehicle is lost). A missing or unreadable `Attach` reads as a null UUID and therefore falls through to the failure case.

Save-side ordering (read in `saveParentVehicle`): the `RootVehicle` child compound is created, `Attach` is stored, and the `Entity` child compound is created, all BEFORE `Entity.save` of the root is called, and the boolean result of that save is ignored. Because `child()` inserts at call time (section 1.2), a root whose save returns false (removal reason that does not save, or a non-serialisable type) leaves `RootVehicle: {Attach: <uuid>, Entity: {}}` in the player file. On load the empty `Entity` compound has no valid `id`, the loader skips it (section 4.2) and `loadAndSpawnParentVehicle` returns without attaching anything (a null root returns early).

---

## 8. The ItemStack compound and data components

Everywhere an item stack is stored in NBT (container slots, equipment, ground items, villager inventories) the codec is `ItemStack.CODEC` (a record of three fields merged into the surrounding compound; `ItemStack.MAP_CODEC` is the same record usable inline).

| Key | NBT type | Default on load | Validation | Written when |
|---|---|---|---|---|
| `id` | String (item identifier) | none: REQUIRED | Must name a registered item (unknown id: decode error). The item `minecraft:air` is rejected ("Item must not be minecraft:air"). The item must also be one whose default components are bound (always true after registries are loaded). | always |
| `count` | Int | 1 | Range 1 to 99 inclusive; outside the range is a decode error. The value is NOT compared with the item's own maximum stack size by this codec (a stack of 64 swords decodes; the strict check `validateStrict` is applied by other paths that apply components, not by this codec). A present but non-numeric `count` is an error (the field is strict). | ALWAYS (even for 1) |
| `components` | Compound (patch) | empty patch | See below. The field is strict: a present but undecodable value is an error. | only when the patch is not empty |

Notes on `count`: the written type is Int. The 99 limit is the codec's constant; an item whose maximum stack size is 1 or 16 can still be stored with `count` up to 99 and is only normalised by gameplay code that merges or splits.

### 8.1 The components patch

`components` is a map from a component key to a value, the serialised form of a `DataComponentPatch` (the difference between the item's prototype components and the stack's actual components; 00 section 12.2 for the wire form and 17 section 1 for the item data-component model):

| Entry form | Meaning |
|---|---|
| `"minecraft:damage": <value>` | The component is set to `<value>` (overriding the prototype). The value's NBT form is the codec of that component type (the component documents; 00 section 12.2 lists the wire form, the on-disk form is the component's own codec). |
| `"!minecraft:max_damage": {}` | A removal marker: the key is the component identifier with a leading `!`, and the value is an EMPTY compound (the unit codec). It removes a component that the prototype has. |
| An entry for a component equal to the prototype | Not written (the patch only holds differences). |

Rules:

1. Keys are written as `namespace:path` (full form). On read the key text (after an optional leading `!`) is parsed as an identifier and looked up in the data component type registry; an unknown key is an error ("Unknown component"), and a TRANSIENT component type (one that is never persisted, such as client-only state) is an error on read ("transient", `PatchKey` decode).
2. Writing: the patch encoder builds its map by SKIPPING every transient component type silently (no error, the entry is simply absent from the output). Only a component type with no registry key is a write error (`PatchKey` encode reports it to the problem collector). Transient types are therefore an error only on read, never on write.
3. A `!` entry whose value is not an empty compound fails to decode.
4. A patch cannot both set and remove the same component; the map has one entry per key.
5. After decoding, the stack's components are the prototype's, with removals applied and sets applied. Strict validity checks are applied by the paths that call `ItemStack.validateStrict` (for example `applyComponentsAndValidate`, which applies a patch and then validates, logging the error; the recovery after the log was not read, Open question 13), not by `ItemStack.CODEC`. `validateStrict` first runs `validateComponents` over the stack's full component map (prototype plus patch), then compares the stack's own count with its item's maximum stack size and fails when the count is larger. `validateComponents` fails when any of these holds, tested in this order: (a) `max_damage` is present AND `max_stack_size` (default 1 when that component is absent) is above 1, message "Item cannot be both damageable and stackable"; (b) a non-empty stack inside `container` has a count above its own item's maximum; (c) a stack inside `bundle_contents` has a count above its item's maximum; (d) `bundle_contents` weight cannot be computed (`BundleContents.weight()` returns an error; its failure cases were not read, Open question 12); (e) a stack inside `charged_projectiles` has a count above its item's maximum. Open question 6 covers what the loader does with a bad component entry: the codec framework's partial-result rule decides whether the whole stack or only that entry is lost.

Empty stacks: `ItemStack.CODEC` cannot encode an empty stack (the item would be `minecraft:air`), so containers never write empty slots (section 9). The variant `ItemStack.OPTIONAL_CODEC` wraps the codec with an "empty map means empty stack" rule: `{}` decodes to the empty stack, any other compound decodes through `CODEC`, and the empty stack encodes as `{}` (encoding side inferred from the `optionalEmptyMap` wrapper). The lenient single-field form `ItemStack.lenientOptionalFieldOf(name)` reads a field that is absent or undecodable as the empty stack and omits an empty stack on write (inferred from the method name and its two lambdas). Siblings state which form each equipment or hand slot uses.

---

## 9. Slot lists: `Items` and `Inventory`

### 9.1 `Items`: sparse list with slot numbers (`ContainerHelper`)

Used by chests, hoppers and other block-entity-like containers, and by container entities (section 10.2).

Element codec `ItemStackWithSlot`: a compound holding

| Key | NBT type | Default | Validation |
|---|---|---|---|
| `Slot` | Byte | 0 | The codec is `ExtraCodecs.UNSIGNED_BYTE`: the byte codec flat-mapped so that on read the stored byte is converted with an unsigned conversion (a stored negative byte is read as 128 to 255) and on write a value above 255 is an error. A slot read as 128 to 255 then fails the container range test of `loadAllItems` (below) for every container smaller than 129 slots and is skipped silently. The key is ALWAYS written (it is an "always present" field), including `0b` for slot 0. |
| `id`, `count`, `components` | as section 8 | | The ItemStack fields are inlined next to `Slot` (no nested `item` compound). |

Save (`saveAllItems(output, list)`): iterate the slots in index order; skip empty stacks; add `{Slot, id, count[, components]}` for each. The two-argument form passes "always write list" true, so the `Items` list is written even when empty (an empty List). The three-argument form with the flag false removes an empty `Items` key (used by callers that want omission).

Load (`loadAllItems`): the target list is the container's slot list, already sized and filled with empty stacks by the caller (it is NOT cleared by this helper). Read `Items` as a list of `ItemStackWithSlot` (absent is an empty list), and for each element whose `Slot` satisfies `0 <= Slot < size` set that slot; an element with an out-of-range slot is skipped silently. Later elements overwrite earlier ones for the same slot. An element that fails to decode (bad `id`, count out of range) is dropped with a logged problem and the others still load.

### 9.2 `Inventory`: compact list without slots (`InventoryCarrier` in `net.minecraft.world.entity.npc`, `SimpleContainer` in `net.minecraft.world`)

Used by mobs that carry a small inventory (villagers, allays, pillagers and similar; each sibling names the key use; the key text constant is `Inventory`). Element codec is plain `ItemStack.CODEC` (no `Slot`).

Save (`writeInventoryToTag`, `storeAsItemList`): the container's slots in index order, skipping empty stacks, so the list is COMPACTED (slot gaps are not stored). The key is written via a typed list; an empty inventory writes an empty list: the typed list is inserted into the parent when it is opened (section 1.2) and nothing in this path discards it, so `Inventory: []` is present.

Load (`readInventoryFromTag`, `fromItemList`): if the key is absent nothing happens (the inventory keeps its current content). If present: clear the container, then for each element call `addItem` (merge into an existing partial stack of the same item first, otherwise the first empty slot). Therefore slots after a round trip are compacted and merged, and elements that do not fit (more than the container size) are lost without notice (the overflow is returned by `addItem` and ignored, inferred).

### 9.3 Equipment and other lists

Mob equipment (`equipment`, `drop_chances` and similar), shoulder entities, horse and llama inventories and bundle contents have their own forms. They are in part 2 and the family parts; they reuse section 8 for the stack and may use either list style above.

---

## 10. Shared helpers

### 10.1 Leash (`Leashable`)

| Key | NBT type | Default | Validation | Written when |
|---|---|---|---|---|
| `leash` | Compound `{UUID: Int Array(4)}` OR `Int Array(3)` | none (not leashed) | An exclusive-or of two forms (a value matching both or neither is an error): the Compound form names the holder entity by UUID; the Int Array(3) form is the block position of a leash knot on a fence (a `leash_knot` entity is created there). | only when the mob is leashed (`storeNullable`). The knot form is written when the holder is a leash knot; otherwise the holder's UUID; the encoder has three outcomes, tested in this order: (1) the holder is a `LeashFenceKnotEntity`: the knot's block position (Int Array(3)); (2) any other non-null holder: its UUID in the Compound form; (3) no holder: the pending stored form is written back unchanged, and when there is no pending form either the encoder fails a null-check with the message "Invalid LeashData had no attachment" (an exception, NOT an omitted key; a leash data object with neither holder nor pending info is an invalid state and its save throws, which becomes the "Saving entity NBT" crash of section 1.2 unless the caller guards). |

Load: `readLeashData` reads `leash` (absent or undecodable gives null). If the mob currently has leash data and the decoded value is null, the leash is removed first. Then, in every case, `setLeashData` is called with the decoded value (null when the key was absent), so the loaded data is stored as PENDING (or cleared when null). Pending data is therefore only replaced by this call. The actual attachment runs later (`restoreLeashFromSave`, called from the mob's tick while the data is pending). It does nothing unless the pending data holds a delayed holder and the level is a server level. Then:

1. UUID form: look the UUID up in the server level. Found: attach the mob to that entity and stop. Not found: fall through to step 3.
2. Block position form: `getOrCreateKnot` always yields a knot (it finds or creates one at that block), so the mob always attaches to it and the function stops. This form can never fail and never reaches the give-up test.
3. Give-up test (reached only by the not-found UUID form): when the mob's `tickCount` is above 100, a lead item is spawned at the mob and the leash data is set to null. At 100 or below nothing happens and the test repeats on a later tick.

### 10.2 ContainerEntity (chest boats, chest and hopper minecarts)

| Key | NBT type | Default | Validation | Written when |
|---|---|---|---|---|
| `LootTable` | String (loot table identifier) | none | Decoded with the loot table resource-key codec. | only when a loot table is set |
| `LootTableSeed` | Long | 0 | - | only when a loot table is set AND the seed is not 0 |
| `Items` | List of ItemStackWithSlot (section 9.1) | all slots empty | - | only when NO loot table is set; written with the always-write form, so present even when empty |

Load (`readChestVehicleSaveData`): first all slots are cleared; `LootTable` is read (absent or undecodable means none) and applied; `LootTableSeed` read with default 0 and applied; `Items` is read ONLY when no loot table is set. A container with a loot table keeps its contents unrolled until a player opens it or it is broken. The unrolling (`unpackChestVehicleLootTable(player)`, the player may be null) does nothing unless a loot table key is set and a server exists. Then, in order:

1. Resolve the table from the server's reloadable registries by key.
2. If a player is present: fire the `GENERATE_LOOT` advancement trigger for that player (a `ServerPlayer`) with the loot table key. It fires whenever the key is set, before the table is rolled; it is part of the advancements round (a future document, not yet written; not document 28, which covers enchantment effect components).
3. Set the stored loot table to null (so a re-entry does nothing). `LootTableSeed` is NOT reset: it stays at its value and is still written only while a loot table is set.
4. Build the loot parameters in the level: `ORIGIN` = the entity position always; only when a player is present also the player's luck and `THIS_ENTITY` = the player. With no player (a broken vehicle) only `ORIGIN` is set.
5. Fill the container from the table with the parameter set `chest` and the seed `LootTableSeed`.

The loot-table engine itself is in 26; this part only fixes the persisted fields and this ordering.

### 10.3 InventoryCarrier

Key `Inventory`, section 9.2.

### 10.4 Owner and entity references

An `EntityReference` is stored as a UUID (`Int Array(4)`) under a key chosen by the user class (for example `Owner` for tameable animals, read through the legacy conversion below). Writing: nothing when the reference is null. Reading: absent or undecodable gives a null reference. `readWithOldOwnerConversion` first tries the UUID form; if that is not present it reads a String under the same key and converts it as a legacy owner (a player name) to a UUID through the server's old-users converter (a profile lookup by name); a failed conversion gives null. The reference holds only the UUID; resolving it to an entity is a world lookup at use time (an offline owner resolves to nothing). `TamableAnimal` adds `Owner` and `Sitting` (Byte, default false); the rest of tameable data is part 4.

### 10.5 Variant holders

`VariantUtils.writeVariant` writes `variant` as a String identifier when the holder has a registry key (it always has for registered variants; an inline unregistered variant writes nothing). `readVariant(input, registryKey)` reads `variant` as an identifier, turns it into a key in the given registry and looks up the holder; unknown or absent gives no value, and the mob picks its own default (sibling-specific). Mobs with a second variant axis use their own key (for example the cat's `sound_variant`).

### 10.6 Positions

`BlockPos` is `Int Array(3)`, `GlobalPos` the compound of section 3, entity position `List<Double>(3)`. A block position is never stored as three separate keys by the classes read here; classes that store a home or target position name the key in their sibling table and use these forms.

---

## 11. Bases without keys of their own

### 11.1 VehicleEntity (boats, minecarts)

The base class adds three synchronised values (hurt time, hurt direction, damage) but NO save keys: `hurt time`, `hurt dir` and `damage` are not persisted and reset to their defaults on every load. Behaviour that part 8 and the engines rely on (the rule of `hurtServer`, re-read in this round):

1. A hit on a removed vehicle returns true and does nothing. A hit the vehicle is invulnerable to (the base invulnerability test for that damage source) returns false.
2. Otherwise: the hurt direction is negated, the hurt time is set to 10, the entity is marked hurt, the damage value increases by `amount * 10.0` (Float arithmetic), and a damage game event is emitted with the attacker (the source's entity, possibly null) as the actor.
3. Instabuild is true when the source's entity is a player whose abilities have instabuild set. The vehicle is destroyed (`destroy`, which drops it per class) when EITHER the damage value is greater than 40.0 and instabuild is false, OR `shouldSourceDestroy(source)` is true (a per-class hook; the base returns false). When it is not destroyed and instabuild is true, the vehicle is discarded with no drop. The call returns true in all these cases.

### 11.2 HangingEntity

`HangingEntity` has no save keys of its own (the class has no save or read method and no key string; read). The direction and the item or art keys are written by the concrete classes (part 9 section 6.2 and the type sections there).

### 11.3 BlockAttachedEntity

`BlockAttachedEntity` writes one key. Its full description, survival re-check and load order are in part 9 (`45-entity-nbt-9-bosses-and-decorations.md`) section 6; the row is repeated here only as the schema entry:

| Key | NBT type | Default | Validation | Written when |
|---|---|---|---|---|
| `block_pos` | `Int Array(3)` | none | Must be present and STRICTLY closer than 16.0 to the entity's own block position: the test is `closerThan(other, 16.0)`, true only when the squared distance is less than `16.0 * 16.0` = 256, so a distance of exactly 16 is rejected. On failure (key absent, or too far) the error "Block-attached entity at invalid position: {}" is logged with the loaded value (the text `null` when the key is absent) and the read returns; the `pos` field keeps its previous value (for a freshly created entity the block under its loaded position) and the entity stays alive until its survival check removes it. On success the `pos` field is set to the loaded `block_pos` (not to the entity's own position). The class overrides `repositionEntityAfterLoad` to false (section 6 step 11), so no re-application of the entity position follows the read. | always |

The entity checks `survives()` every 100 ticks (`CHECK_INTERVAL`); a failed check removes it and drops it per its class. The facing key and the item or art keys are in part 9.

---

## 12. Owner index of entity type keys

All 161 keys of `EntityTypeIds` (read from the artifact, counted from the constant pool strings: 161) and the part that specifies their keys. The table below follows the Covers lines of the sibling documents as they stand (those lines win over any earlier plan); the authoritative per-type index is part 9 section 13 (`45-entity-nbt-9-bosses-and-decorations.md`, all-entities index), which this table does not replace. Part 2 (shared mob classes) and part 3 (Player) own base classes, not the types, except `minecraft:player` for part 3.

| Part | Count | Entity type keys (all in namespace `minecraft`) |
|---|---|---|
| 3 | 1 | `player` |
| 4 | 34 | `cow`, `mooshroom`, `pig`, `sheep`, `chicken`, `rabbit`, `horse`, `donkey`, `mule`, `llama`, `trader_llama`, `skeleton_horse`, `zombie_horse`, `camel`, `camel_husk`, `cat`, `ocelot`, `wolf`, `fox`, `panda`, `polar_bear`, `goat`, `sniffer`, `armadillo`, `turtle`, `bee`, `frog`, `allay`, `parrot`, `happy_ghast`, `copper_golem`, `iron_golem`, `snow_golem`, `bat` |
| 5 | 34 | `zombie`, `husk`, `drowned`, `zombie_villager`, `zombified_piglin`, `skeleton`, `stray`, `bogged`, `parched`, `wither_skeleton`, `spider`, `cave_spider`, `creeper`, `enderman`, `endermite`, `silverfish`, `slime`, `magma_cube`, `sulfur_cube`, `ghast`, `blaze`, `phantom`, `giant`, `vex`, `witch`, `shulker`, `guardian`, `elder_guardian`, `warden`, `breeze`, `creaking`, `ravager`, `zoglin`, `hoglin` |
| 6 | 10 | `villager`, `wandering_trader`, `pillager`, `vindicator`, `evoker`, `illusioner`, `vex`, `piglin`, `piglin_brute`, `hoglin` |
| 7 | 12 | `cod`, `salmon`, `pufferfish`, `tropical_fish`, `squid`, `glow_squid`, `dolphin`, `axolotl`, `tadpole`, `nautilus`, `zombie_nautilus`, `strider` (part 7 section 10 also sweeps leftovers) |
| 8 | 63 | `end_crystal`, `acacia_boat`, `acacia_chest_boat`, `bamboo_raft`, `bamboo_chest_raft`, `birch_boat`, `birch_chest_boat`, `cherry_boat`, `cherry_chest_boat`, `dark_oak_boat`, `dark_oak_chest_boat`, `jungle_boat`, `jungle_chest_boat`, `mangrove_boat`, `mangrove_chest_boat`, `oak_boat`, `oak_chest_boat`, `pale_oak_boat`, `pale_oak_chest_boat`, `poplar_boat`, `poplar_chest_boat`, `spruce_boat`, `spruce_chest_boat`, `minecart`, `chest_minecart`, `furnace_minecart`, `hopper_minecart`, `tnt_minecart`, `spawner_minecart`, `command_block_minecart`, `arrow`, `spectral_arrow`, `trident`, `snowball`, `egg`, `ender_pearl`, `experience_bottle`, `splash_potion`, `lingering_potion`, `fireball`, `small_fireball`, `dragon_fireball`, `wind_charge`, `breeze_wind_charge`, `wither_skull`, `shulker_bullet`, `llama_spit`, `fishing_bobber`, `eye_of_ender`, `firework_rocket`, `evoker_fangs`, `falling_block`, `tnt`, `item`, `experience_orb`, `area_effect_cloud`, `lightning_bolt`, `ominous_item_spawner`, `marker`, `interaction`, `block_display`, `item_display`, `text_display` |
| 9 | 9 (+1 cross-reference) | `ender_dragon`, `wither`, `armor_stand`, `painting`, `item_frame`, `glow_item_frame`, `leash_knot`, `mannequin`, `cushion` (and `end_crystal`, cross-reference only; part 8 owns its keys) |

Note on part 6: `vex` and `hoglin` are also in part 5's Covers line; both parts describe them.

Distinct types: 1 + 34 + 34 (part 5) + 8 (part 6 types not already in part 5: `villager`, `wandering_trader`, `pillager`, `vindicator`, `evoker`, `illusioner`, `piglin`, `piglin_brute`) + 12 + 63 + 9 = 161. Types with no save path (section 4.3): `player`, `fishing_bobber`, `lightning_bolt`, `leash_knot`; their rows in parts 3, 8 and 9 are limited to what a command or a bucket path can still see. `cushion` and `sulfur_cube` and `camel_husk`, `parched`, `copper_golem`, `mannequin`, `poplar_*` are types that exist in 26.3 and that earlier-version knowledge does not cover; each owning part reads them from the artifact. The two types listed by both part 5 and part 6 (`vex`, `hoglin`) are covered twice on purpose; `45-entity-nbt-7` section 10 contains the registry sweep that settles leftovers.

---

### 12.1 Types with `allowedInPeaceful` false (skipped on load in a PEACEFUL world)

Read from the 38 `notInPeaceful` builder calls in `EntityTypes`: `blaze`, `bogged`, `breeze`, `cave_spider`, `creaking`, `creeper`, `drowned`, `elder_guardian`, `enderman`, `endermite`, `evoker`, `ghast`, `giant`, `guardian`, `hoglin`, `husk`, `illusioner`, `magma_cube`, `parched`, `phantom`, `piglin_brute`, `pillager`, `ravager`, `silverfish`, `skeleton`, `slime`, `spider`, `stray`, `vex`, `vindicator`, `warden`, `witch`, `wither`, `wither_skeleton`, `zoglin`, `zombie`, `zombie_villager`, `zombified_piglin`. All other types (including `piglin`, `villager`, `wandering_trader`, `sulfur_cube`, `shulker`) load in peaceful.

## 13. Extension of 07 section 9.3 and 9.4

07 section 9.3 describes a stand-in entity compound. For the standard world type the compound is replaced as follows; the file layout, the region container, the compression and the `Position` / `Entities` / `DataVersion` framing of 07 section 8 and 9.3 stay.

| 07 item | Standard rule |
|---|---|
| Entity compound `id` | The entity type registry key in full form (section 4.1), for example `minecraft:pig`. In the cobolcraft world type the key is `cobolcraft:...` (registry of that type). |
| Keys `Pos`, `Motion`, `Rotation` | As section 5 (same names, same list forms; `Pos` is the vehicle position for a passenger). |
| `Health` | Not a base key. It is written by LivingEntity (part 2) in its own form; the 07 mention is superseded. The ground item (`minecraft:item`) also writes its own `Health` key, as a Short, and reads it with `getShortOr`. |
| `Item`, `Age` | Ground items: part 8 (`minecraft:item`: `Item` is an ItemStack compound of section 8, `Age` a Short; see 41 for the physics). `ItemEntity` writes `Health`, `Age`, `PickupDelay`, `Thrower`, `Owner` and `Item` itself. 07 section 9.3 lists `Age` as an Int: that is stale, `Age` is a Short, and the ground-item `Health` is a Short. |
| Extra base keys | Section 5: `fall_distance`, `Fire`, `Air`, `OnGround`, `Invulnerable`, `invulnerable_time`, `PortalCooldown`, `UUID`, name, flags, `Tags`, `data`, `Passengers`. |
| Passengers | Nested in the vehicle's compound (section 7), never top-level entries. |
| Players | Not in `entities/`. A vehicle with exactly one player passenger is not in `entities/` either (section 7.2). |

Chunk placement and storage (07 section 9.4 ties to `entities/`):

1. Each entity is filed in the section of `blockPosition()` (floor of Pos on each axis), and a chunk file stores the sections of one chunk: chunk x = floor(x / 16), chunk z = floor(z / 16). So a compound's `Pos` and the chunk it sits in always agree at save time; a compound whose `Pos` was edited by hand moves to the chunk of the edited position at the next insert.
2. A chunk file's top level is `DataVersion`, `Position` (`Int Array(2)`), `Entities` (list of compounds). An empty `ChunkEntities` never writes a compound (read in `EntityStorage.storeEntities`). The first empty save of a chunk in a session adds the chunk to the known-empty set and issues the `STORE_EMPTY` write (the region slot is cleared; that meaning is inferred, Open question 8), then returns; later empty saves of the same chunk do nothing. A write failure logs "Failed to store entity chunk {}" (read in `EntityStorage`). A non-empty save builds the `Entities` list first, then writes `DataVersion`, `Entities` and `Position`, and removes the chunk from the known-empty set. An `Entities` list can therefore be empty only when every entity of a non-empty chunk failed to save. On load, an absent payload adds the chunk to the known-empty set and returns an empty chunk; a chunk already in the set loads as empty without reading the file.
3. On read: `Position` must equal the chunk requested. A mismatch logs "Chunk file at {} is in the wrong location. (Expected {}, got {})" and reports a misplaced chunk, and a `Position` that cannot be parsed logs "Failed to parse chunk {} position info" and reports a load failure; in both cases the code path continues to the data fixer (confirmed from the bytecode control flow: both branches jump to the `upgradeChunkTag` call), so the entities are still loaded. A missing `Position` key is an exception thrown by the lookup and is handled by the same "Failed to parse chunk" branch.
4. Read pipeline: region read, the DataFixer `ENTITY_CHUNK` (section 1.4), `Entities` through `loadEntitiesRecursive` with spawn reason `LOAD`. A chunk read error ("Failed to load entity chunk {}") reports a load failure for that chunk.
5. Entities are added to the world one at a time with UUID de-duplication (section 6). They become visible and ticking according to chunk status (33 world simulation covers the entity tick conditions).
6. Save: when a chunk is unloaded or autosaved, every entity of its sections with `shouldBeSaved` is written through `save`; the compound list is built with one problem-reporter path per entity, so a problem in one entity never blocks the chunk.

---

## 14. Worked examples

### 14.1 UUID forms

UUID `00112233-4455-6677-8899-aabbccddeeff`: `[I; 1122867, 1146447479, -2003195205, -857870593]`. Check: the four 32-bit words are `0x00112233`, `0x44556677`, `0x8899aabb` (negative as a signed Int: 2291772091 - 4294967296 = -2003195205), `0xccddeeff` (3437096703 - 4294967296 = -857870593).

### 14.2 A minimal pig (base keys only, plus `variant` and sibling keys elided)

```
{id: "minecraft:pig", Pos: [12.5d, 64.0d, -3.5d], Motion: [0.0d, 0.0d, 0.0d],
 Rotation: [90.0f, 0.0f], fall_distance: 0.0d, Fire: 0s, Air: 300s, OnGround: 1b,
 Invulnerable: 0b, PortalCooldown: 0, UUID: [I; 1122867, 1146447479, -2003195205, -857870593]}
```
(`Fire: 0s` is the value of a fresh entity: the `remainingFireTicks` field has no assignment in the `Entity` constructor, and the base `getFireImmuneTicks()` returns 0. `Motion` is shown as zero, the load default of section 5; a real compound carries whatever motion the entity has at save time, which depends on gravity constants of the Entity and LivingEntity classes specified in part 2 and is not derived here.) This entity lives in chunk (0, -1): floor(12.5 / 16) = 0, floor(-3.5 / 16) = -1.

### 14.3 Defaults on load

A compound `{id: "minecraft:pig"}` loads at `Pos` (0, 0, 0), zero motion, zero rotation, air 300, a random UUID, no name. A compound `{id: "minecraft:pig", Pos: [1.0d, NaN, 2.0d]}` fails with "Entity has invalid position" and is skipped. `Pos: [Infinity, 0.0d, 0.0d]` does NOT fail: x is clamped to 30000512 (and `-Infinity` to -30000512, an infinite y to 20000000 or -20000000). `Rotation: [Infinity, 0.0f]` fails with "Entity has invalid rotation". `Motion: [0.0d, 25.0d, 3.0d]` becomes motion (0, 0, 3). `Pos: [9e7d, 100.0d, 0.0d]` becomes x = 30000512.

### 14.4 An item stack

```
{Slot: 3b, id: "minecraft:diamond_pickaxe", count: 1,
 components: {"minecraft:damage": 5, "!minecraft:max_damage": {}}}
```
Decodes to a pickaxe in slot 3 with damage 5 and the `max_damage` component removed (this stack passes `validateStrict`: the damageable-and-stackable rule only fires when `max_damage` is present in the final component map, and the `!` marker removed it, so the rule cannot fire here. It would apply to a patch that re-adds `max_damage` while `max_stack_size` is above 1). A stack `{id: "minecraft:air", count: 1}` fails ("Item must not be minecraft:air"), `{id: "minecraft:stone", count: 100}` fails (range 1 to 99), `{id: "minecraft:stone"}` loads as count 1, `{count: 3}` fails (no `id`).

### 14.5 Container entity

A chest boat with items and no loot table:
```
{id: "minecraft:oak_chest_boat", ..., Items: [{Slot: 0b, id: "minecraft:bread", count: 12}, {Slot: 26b, id: "minecraft:stick", count: 64}]}
```
With a loot table: `{..., LootTable: "minecraft:chests/village/village_toolsmith", LootTableSeed: 123456789L}` and NO `Items`. A seed of 0 omits `LootTableSeed`. On load of a compound that has both `LootTable` and `Items`, `Items` is ignored.

### 14.6 Leash

A mob held by a player entity: `leash: {UUID: [I; ...]}`. A mob held by a fence knot at block (10, 64, -5): `leash: [I; 10, 64, -5]`.

### 14.7 Passengers

A boat carrying a villager and a zombie (player absent):
```
{id: "minecraft:oak_boat", Pos: [0.0d, 63.0d, 0.0d], ..., Passengers: [
  {id: "minecraft:villager", Pos: [0.0d, 63.0d, 0.0d], ...},
  {id: "minecraft:zombie",   Pos: [0.0d, 63.0d, 0.0d], ...}]}
```
Both passengers' `Pos` equal the boat's. On load the boat is created and added, then each passenger is created and attached with force. If `minecraft:villager` is unregistered, only the zombie attaches. A player riding the same boat alone: the boat is in the player's `RootVehicle.Entity`, `RootVehicle.Attach` is the boat UUID, and the chunk has no entry for the boat.

### 14.8 Block-attached

A painting at block (100, 70, 100) read when the entity is at block (100, 70, 100): `block_pos: [I; 100, 70, 100]` is closer than 16 (squared distance 0 < 256), accepted, and `pos` becomes (100, 70, 100). Read at an entity block position 20 blocks away: squared distance 400 is not below 256, rejected with the error log, `pos` left unchanged. Exactly 16 blocks away on one axis (squared distance 256) is also rejected. A compound with no `block_pos` logs "Block-attached entity at invalid position: null".

---

## 15. Validation checklist

An implementation conforms to this part when all of these hold.

1. Every base key of section 5 round-trips with the stated types (`fall_distance` Double, `Fire` Short, `Air` Short, flags Byte).
2. Conditional keys (`invulnerable_time`, `CustomName`, `CustomNameVisible`, `Silent`, `NoGravity`, `Glowing`, `TicksFrozen`, `HasVisualFire`, `Tags`, `data`, `Passengers`) are omitted at their default and read back to the default.
3. `Pos` is clamped (x and z at plus or minus 30000512, y at plus or minus 20000000) a NaN position component (infinities are clamped) or a NaN or infinite rotation component skips the entity with a warning; `Motion` components above 10 in magnitude become 0.
4. A missing `Pos` loads at the origin; a missing `id` or unknown id skips only that entry; one bad entry never prevents the other entries of the chunk from loading.
5. `UUID` is an Int Array of 4 with the word order of section 3 (test vector 14.1).
6. `Passengers` nest, the passenger `Pos` equals the vehicle's, a player in a vehicle is excluded from `Passengers`, a vehicle with exactly one player passenger is excluded from the chunk and appears as `RootVehicle` in the player file with `Attach` and `Entity`.
7. ItemStack: `id` required and not air, `count` default 1 and in 1 to 99, always written, `components` omitted when empty, `!` markers carry an empty compound.
8. `Items` lists write `Slot` as Byte for every non-empty slot only; load ignores out-of-range slots; a container with a loot table writes `LootTable` and no `Items`, and ignores `Items` on load.
9. `Inventory` lists are compact; load merges.
10. `leash` forms: Compound `{UUID}` or `Int Array(3)`; a leash that cannot be resolved within 100 ticks yields a lead item; saving leash data with no holder and no pending form throws ("Invalid LeashData had no attachment").
11. `block_pos` of block-attached entities strictly closer than 16.0 to the entity (squared distance below 256; exactly 16 is rejected); a missing key is rejected with the log; on success `pos` is the loaded value and the entity position is not re-applied after load.
12. `entities/` chunk files carry `DataVersion` 5023, `Position` `Int Array(2)` and `Entities`, and each entity is filed under the chunk of its position.
13. The four non-saving types are never written.
14. Unknown extra keys on read are ignored, and keys inside `data` survive a round trip unchanged.
15. Loading uses `ignoreChecks` false: a type disabled by feature flags, or not allowed in peaceful while the difficulty is PEACEFUL, is skipped with "Skipping Entity with id {}". Passengers are created and attached even when the vehicle is refused by the UUID check.

---

## 16. Open questions

1. DataFixer content: the fixers for `ENTITY_CHUNK`, `PLAYER` and `ENTITY` (renamed keys, old formats of items such as the pre-component `tag`) are code in the `datafix` packages and are not specified. Until a round covers them, only `DataVersion` 5023 is accepted (interim rule, section 1.4).
2. Settled by reading `SimpleRegionStorage.upgradeChunkTag` (section 1.4): a version at or above 5023 is returned unchanged, an older or absent one is fixed from the stored version (or -1). What stays open is the project decision whether to accept newer payloads, and the fixer content (question 1).
3. `Entity.setRot` normalization (wrapping of yaw, clamping of pitch) and the `setYHeadRot` / `setYBodyRot` details were not read.
4. A `Tags` list longer than 1024: whether the size-limited list codec returns a partial list or nothing was not followed; section 5 says the set stays empty (inferred).
5. `Team`: the load side is fully read (section 5, joined by the entity's UUID string); the save side does not exist in `Entity`, `LivingEntity`, `Mob`, `Player`, `Animal` or `ServerPlayer`. Where team membership is persisted (the scoreboard saved data) and how the scoreboard re-establishes members on server start needs a scoreboard round (not read; searched: the entity classes above for a `Team` write).
6. Component patch decode errors: whether a bad component entry drops the whole stack or only that entry depends on the codec framework's partial-result handling for `DataComponentPatch.CODEC` (a dispatched map) and was not followed. The NBT value forms of individual components are in the component documents, not here.
7. `EntityReference` legacy owner conversion calls a profile lookup (`OldUsersConverter`): its offline behaviour (no profile) is not specified.
8. The `STORE_EMPTY` write (section 13 item 2) is inferred to clear the region slot; the region-file side was not read here (07 section 6 covers the region container).
9. The meaning and fields of the types `cushion`, `sulfur_cube`, `mannequin`, `parched`, `camel_husk` and `copper_golem` are for their owning parts; this part only fixes their ids.
10. `FallingBlock`, `command_block_minecart` and `spawner_minecart` are `OP_ONLY_CUSTOM_DATA`: the permission check itself (the command side) is in 16 and was not re-read.
11. Settled in this round and kept only as a pointer: a vehicle refused by the UUID check still gets its passengers created and attached (section 7.3, read from `loadEntityRecursive` and the chunk-load processor). What remains unread is how the world handles an attached passenger whose vehicle was never added (searched: `PersistentEntitySectionManager.addEntityUuid` only).
12. `BundleContents.weight()` returns an error result in some cases (used by `validateComponents`, section 8.1 rule 5 item d); its failure conditions were not read. Searched: `ItemStack.validateComponents` only.
13. `ItemStack.applyComponentsAndValidate`: what happens to the patch after the logged `validateStrict` error (revert or keep) was not read past the log call.
14. Closed: the Float and Double narrowing was read in `DoubleTag` and `FloatTag` (section 1.1).
15. The `allowedInPeaceful` list is closed (section 12.1: 38 `notInPeaceful` calls, each attributed to its id constant by the preceding `EntityTypeIds` reference and re-confirmed). Still open: the meaning of the player-vehicle loader's request (its `ignoreChecks` value) was read only through the reason-taking overloads.
16. Scope not covered by part 1 and left to the sibling reviewers: LivingEntity, Mob, equipment and drop chances, attributes, effects, brain memories, Player and `player.dat` contents (also the CobolCraft world folder layout, 07 section 9), deferred to parts 2 and 3.
17. `ValueOutput.discard` callers outside `net.minecraft.world.entity.*`, `net.minecraft.world.Container*`, `ServerPlayer` and `net.minecraft.world.level.block.entity.*` were not scanned (section 1.2 states the search done).
18. Player-save keys for part 3, read as written by `ServerPlayer` in this round and not described here: `recipeBook`, `Dimension`, `respawn`, `spawn_extra_particles_on_fall`, `raid_omen_position`, `post_effects`, `ShoulderEntityLeft`, `ShoulderEntityRight`.
