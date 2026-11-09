# 45-3 Entity and player NBT: the player, its data file, advancements and statistics

| Item | Value |
|---|---|
| Covers | The standard world type's per-player persistence: `players/data/<uuid>.dat` (location, atomic write, backup, load fallbacks, first join, single-player owner), every key of the Player and ServerPlayer save compounds, the item-stack and inventory slot codecs, the ender chest, the recipe book compound, the respawn and last-death forms, the Mannequin keys, the join sequence (what is merged into the joining player, position and dimension fallback, vehicle and ender pearl restore), `players/advancements/<uuid>.json` and `players/stats/<uuid>.json`. Keys inherited from Entity and LivingEntity are only listed by name here; sibling documents 45 section 1 (shared entity model) and 45 section 2 (LivingEntity) own their meaning. |
| Round | RS27 (design map `../design/README.md`, GAP-8 entity NBT, Part 6 row RS27). Part 3 of the RS27 set. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited in backticks only to say where a fact was read. |
| World type | Standard world type. CobolCraft's own layout (07 section 9.2) is compared in section 12 and is extended only where the standard differs. |
| Data versus code | Advancement definitions, recipes, stat registries' rows and similar are data and are not tabulated. The codecs, defaults, file handling and the list of custom statistics (code-defined) are specified. |

Notation: "Optional key" means the key is omitted when the value is absent or equal to the stated default, and a missing key on load takes the stated default. "Required" means a load without the key makes the codec fail for that value (the load of that single value is dropped, see section 1.4). Numeric types are NBT types.

---

## 1. The player data file

### 1.1 Location and names (`PlayerDataStorage`, `LevelResource`)

All per-player files live under the world folder's `players/` directory. The directory names are constants of `LevelResource`:

| Content | Path under the world folder | Format |
|---|---|---|
| Player entity data | `players/data/<uuid>.dat` | gzip NBT (07 section 5.1), root framing of 07 section 3 |
| Backup of the previous save | `players/data/<uuid>.dat_old` | same |
| Temporary file during a save | `players/data/<uuid>-<random>.dat` | same, deleted by the replace step |
| Corrupted-file copy | `players/data/<uuid>_corrupted_<yyyy-MM-dd_HH-mm-ss>.dat` | a byte copy |
| Advancements | `players/advancements/<uuid>.json` | JSON, section 8 |
| Statistics | `players/stats/<uuid>.json` | JSON, section 9 |

`<uuid>` is the player's UUID in the hyphenated lower-case string form (`Player.getStringUUID`, `UUID.toString`). The directory `players/data/` is created when the storage object is created (`mkdirs`). The date in the corrupted-file name (`FileNameDateFormatter`, `Locale.ROOT`, local time from `ZonedDateTime.now`) is: year, `-`, month, `-`, day, `_`, hour, `-`, minute, `-`, second. Month, day, hour, minute and second are two digits. The year has at least four digits (minimum 4, maximum 10, sign style "exceeds pad"), so a year above 9999 is printed with a leading plus sign.

### 1.2 Save (`PlayerDataStorage.save`, `Util.safeReplaceFile`)

1. Build a fresh NBT compound by running `Player.saveWithoutId` into a `TagValueOutput` created with the registry context (so item components and holders encode by key).
2. Create a temporary file in `players/data/` whose name starts with `<uuid>-` and ends with `.dat` (`Files.createTempFile`).
3. Write the compound to it as gzip NBT (`NbtIo.writeCompressed`).
4. Replace, with three paths (final `<uuid>.dat`, temporary file, backup `<uuid>.dat_old`):
   a. If the final file exists: delete the old backup, then rename the final file to the backup name.
   b. Delete the final path if it is still there and check that it is gone.
   c. Rename the temporary file to the final name and check that it exists.
   d. If step c failed (and the move-only mode is off, which it is for players), rename the backup back to the final name.
   The retry unit is a whole step sequence, not a single file operation. `Util.runWithRetries` (count 10) runs the members of one sequence in order until one returns false, and repeats the whole sequence up to 10 times. There are four sequences: (a) delete the backup, rename the final file to the backup name, check the backup exists (only when the final file exists); (b) delete the final path, check it is gone; (c) rename the temporary file to the final name, check the final file exists; (d) rename the backup to the final name, check the final file exists (only when c failed, and not in move-only mode). Each failed attempt logs "Failed to <action>, retrying n/10" (n counts from 0); after 10 failed attempts it logs "Failed to <action>, aborting, progress might be lost" and the sequence yields false. If sequence a or b yields false, the replace returns false at once and c and d never run. If c yields false, d is attempted and the replace returns false whatever d gives. Failures are logged, never thrown to the caller.
5. Any exception in the whole save is caught and logged as "Failed to save player data for <plain name>"; the game continues.

Result: after a successful save the final file is the new data and `.dat_old` holds the previous final file (one generation). A first save leaves no `.dat_old`. Saves are not incremental: the file always holds the full compound.

### 1.3 Load (`PlayerDataStorage.load`, two overloads)

Input: a name-and-id pair. Output: an optional compound.

1. Try `players/data/<uuid>.dat`. It counts as present when it exists and is a regular file and reads without exception (gzip NBT, `NbtAccounter.unlimitedHeap`, so no size limit). A read exception is logged as "Failed to load player data for <name>" and counts as absent.
2. If absent (missing or unreadable): run the backup step, which copies `<uuid>.dat` to `<uuid>_corrupted_<date>.dat` if `<uuid>.dat` is a regular file (copy replaces an existing target and copies attributes; failure is logged "Failed to copy the player.dat file for <name>"). For a missing file there is nothing to copy.
3. If absent, try `players/data/<uuid>.dat_old` the same way (step 1 rules, but no backup copy follows a failure of this one).
4. If a compound was found, run the data fixer for the Player type: `DataFixTypes.PLAYER.updateToCurrentVersion(fixer, tag, version)` where version is the compound's `DataVersion` Int (`NbtUtils.getDataVersion`, with the default -1 when the key is missing: the one-argument `getDataVersion(CompoundTag)` passes the constant -1; the `Dynamic` overload also defaults to -1). The current data version is 5023 (07 section 7).

The player file is read twice per join (section 7, steps 1 and 6), each read running this whole procedure, so a corrupt `.dat` can trigger the `_corrupted_` copy twice, once per read; the second copy has the same or a later timestamp in its name (the name has one-second resolution, and an existing target is replaced).

So a corrupt `.dat` is preserved as a `_corrupted_` copy and the player continues from the previous generation `.dat_old`; the next save then moves the (corrupt) `.dat` aside as the new `.dat_old`.

### 1.4 What decoding failures do

All reads go through `ValueInput` over the compound. The accessors named `...Or(key, default)` return the default when the key is missing or of the wrong type. `read(key, codec)` returns an empty optional on a missing key or a codec failure (the failure is reported to the problem reporter and logged, never fatal). `listOrEmpty` and `childOrEmpty` return an empty list or compound when missing. List-element decoding failures drop that element only.

### 1.5 Single-player owner (`PlayerList.loadPlayerData`)

`loadPlayerData(nameAndId)` returns the stored compound for the joining player:

1. If the server reports that this player is the single-player owner (`MinecraftServer.isSingleplayerOwner`, abstract here, true for the integrated server's host) and `level.dat` carries a `singleplayer_uuid` (Int Array, `PrimaryLevelData.SINGLEPLAYER_UUID`), load the file of that stored UUID instead (logged "loading single player"), using a name-and-id of that UUID and the name `<singleplayer owner>`. The owner therefore keeps the same file when the account UUID changes (for example offline to online).
2. Otherwise load the file of the joining player's own UUID (section 1.3).

The loaded compound is then used as is. Nothing renames the file to the joining UUID, and the next save writes `<joining uuid>.dat` (from `Player.getStringUUID`, which `Player.readAdditionalSaveData` forces to the game profile's id, see section 2.1).

The legacy root key `Player` in `level.dat` (`PrimaryLevelData.OLD_PLAYER`) exists as a constant for the pre-split single-player format; its conversion is not traced (Open question 3).

### 1.6 First join

If no compound is found, nothing is loaded: the player entity keeps its constructor defaults (full health, survival-style defaults from the entity classes, empty inventory, food 20 / saturation 5 / exhaustion 0 by the field defaults that match the `FoodData` load defaults of section 2.3, XP 0, no respawn point) and is placed at the world spawn found by the spawn finder (section 7). The game mode is computed as in section 3.4 with no stored mode, so it comes from the server's default game type unless a forced game type applies. The first save happens on leave, on a periodic save-all and on shutdown (`PlayerList.remove`, `PlayerList.saveAll`; the interval of automatic saves belongs to the server loop, see Open question 7).

---

## 2. Player keys (`Player.addAdditionalSaveData`, `readAdditionalSaveData`)

`ServerPlayer` extends `Player`, which extends `Avatar` (no keys of its own), then `LivingEntity`, then `Entity`. A save writes in this order: the Entity keys (section 2.5), the LivingEntity keys (45 section 2), the Player keys of this section, then the ServerPlayer keys of section 3. A load reads in the same layering, then the join sequence of section 7 applies on top.

### 2.1 Player keys

| Key | NBT type | Written | Load default and processing |
|---|---|---|---|
| `DataVersion` | Int | always (`NbtUtils.addCurrentDataVersion`) | 5023 on write. Read only by the loader of section 1.3. |
| `Inventory` | List of Compound | always (empty list when empty) | `listOrEmpty`; elements decoded by the slot codec of section 4.1. The 36 slots are cleared first, then each valid element is placed. |
| `SelectedItemSlot` | Int | always | 0. Passed to `Inventory.setSelectedSlot`; the hotbar index (0 to 8; out-of-range handling not traced, Open question 4). |
| `SleepTimer` | Short | always (the sleep counter, truncated to Short) | 0 |
| `XpP` | Float | always | 0.0 (progress to next level, 0 to 1) |
| `XpLevel` | Int | always | 0 |
| `XpTotal` | Int | always | 0 |
| `XpSeed` | Int | always (the enchantment seed) | 0, and when the loaded value is 0 a new seed is drawn: `nextInt()` from the entity's random source. |
| `Score` | Int | always | 0 |
| `foodLevel` | Int | always | 20 (see 2.3) |
| `foodTickTimer` | Int | always | 0 |
| `foodSaturationLevel` | Float | always | 5.0 |
| `foodExhaustionLevel` | Float | always | 0.0 |
| `abilities` | Compound | always | Optional: when the key is absent or fails, the abilities keep their current values. See 2.2. |
| `EnderItems` | List of Compound | always | `listOrEmpty`; section 5. |
| `LastDeathLocation` | Compound | only when present | Optional. A global position: section 6.2. |

Load side effects, in order: set the entity UUID from the game profile id (the file's `UUID` is ignored for a player); load the inventory and selected slot; sleep counter; experience fields (`XpP` into progress, `XpLevel` into level, `XpTotal` into total); seed fix-up; score; food data; abilities (when present), then set the base value of the movement-speed attribute to the abilities' walking speed; ender items; last death location.

Not saved for a player (read from the save methods, no key exists): the shoulder-parrot cooldown state, `current_impulse_context`, `ignore_fall_damage_from_current_explosion`, any fall-flying counter other than `FallFlying` (LivingEntity key, 45 section 2) and the current screen or container. The names `current_impulse_context` and `ignore_fall_damage_from_current_explosion` do not occur as persisted keys in the artifact's save methods. Explosion-related state that is persisted uses two key names in the player compound: the LivingEntity keys `current_impulse_context_reset_grace_time` and `current_explosion_impact_pos` (section 2.5), and the ServerPlayer key `last_explosion_impact_pos` (section 3.1). In `ServerPlayer` the key `last_explosion_impact_pos` is written (`storeNullable` with the Vec3 codec) and read (`read(...).orElse(null)`, so absent means null) through the field `currentExplosionImpactPos`. The LivingEntity key `current_explosion_impact_pos` is stored in a different field, `currentImpulseImpactPos`, declared in `LivingEntity` (read from its save and load methods; `LivingEntity` declares no field named `currentExplosionImpactPos`). The two keys are therefore two independent values; implementers keep both and must not alias them.

Totals: the Player layer writes 16 keys (15 always, `LastDeathLocation` the only optional one, written when present).

### 2.2 `abilities` compound (`Abilities$Packed.CODEC`)

All keys are optional with the defaults below (each is written, since the packed form writes its fields always, `optionalAlwaysPresentFieldOf`):

| Key | Type | Default | Meaning |
|---|---|---|---|
| `invulnerable` | Boolean (Byte 0/1) | false | cannot take damage |
| `flying` | Boolean | false | currently flying |
| `mayfly` | Boolean | false | allowed to fly (note the lower-case f) |
| `instabuild` | Boolean | false | creative mode block behaviour |
| `mayBuild` | Boolean | true | allowed to modify the world |
| `flySpeed` | Float | 0.05 | flying speed |
| `walkSpeed` | Float | 0.1 | walking speed |

Applied by copying the seven values into the live abilities object (`Abilities.apply`). The game mode load (section 3.4) then recomputes most of them, unconditionally (see below).

Game type to abilities (`GameType.updatePlayerAbilities`): creative sets mayfly, instabuild and invulnerable true (flying untouched); spectator sets mayfly true, instabuild false, invulnerable true, flying true; survival and adventure set mayfly, instabuild, invulnerable and flying all false. `mayBuild` becomes the negation of "block placing restricted" for the mode; the body of `isBlockPlacingRestricted` was read and is true exactly for adventure and spectator, so `mayBuild` is false for those two and true for survival and creative.

The recomputation always runs on load: `ServerPlayerGameMode.setGameModeForPlayer(current, previous)` stores both modes and then calls `GameType.updatePlayerAbilities` on the player's abilities with no condition, and `ServerPlayer.readAdditionalSaveData` calls it (section 3.4) after the `abilities` compound has been applied (Player layer first, ServerPlayer layer second). So on every load the stored mode overrides the stored `invulnerable`, `mayfly`, `instabuild` and `mayBuild`. It also overrides `flying`, except for creative, which leaves the stored `flying` as loaded: survival and adventure force `flying` false, spectator forces it true. `flySpeed` and `walkSpeed` are never touched by the recomputation.

Worked example: stored `abilities` = `mayfly` true, `flying` true, `invulnerable` false, `instabuild` false, `mayBuild` true, with `playerGameType` 0 (survival). After load `mayfly` is false, `flying` false, `invulnerable` false, `instabuild` false, `mayBuild` true. The same abilities with `playerGameType` 1 (creative) load as `mayfly` true, `instabuild` true, `invulnerable` true, `mayBuild` true and `flying` true (as stored). With `playerGameType` 2 (adventure) `mayBuild` loads false.

### 2.3 Food (`FoodData`)

Four keys, always written: `foodLevel` Int, `foodTickTimer` Int, `foodSaturationLevel` Float, `foodExhaustionLevel` Float. Load defaults: 20, 0, 5.0, 0.0. The tick and exhaustion rules are in 13 and 17 (not repeated here).

### 2.4 Inventory model

`Inventory` has `items` (36 slots, `INVENTORY_SIZE`), `selected` (hotbar index, `SELECTION_SIZE` is 9) and an `EntityEquipment` for armor, off-hand, body and saddle. Container indices (constants of `Inventory`): 0 to 8 hotbar, 9 to 35 main, then the equipment indices 36 to 39 (feet 36, legs 37, chest 38, head 39, in `EquipmentSlot` index order feet 0, legs 1, chest 2, head 3, each plus 36 in the mapping `EQUIPMENT_SLOT_MAPPING`), 40 off-hand (`SLOT_OFFHAND`), 41 body armor (`SLOT_BODY_ARMOR`), 42 saddle (`SLOT_SADDLE`).

Persistence differs from the older numbering (slots 100 to 103 for armor and -106 for the off-hand): in 26.3 the `Inventory` list holds only the 36 `items` entries (`Inventory.save` iterates `items` from 0 and writes one element per non-empty stack, nothing else). Armor, off-hand, body and saddle are saved in the LivingEntity key `equipment` (a compound keyed by slot name, section 4.3). A save never writes the numbers 100 to 103 or -106. A load of a file that still has the old numbers is the data fixer's job (Open question 6); the load code itself places only elements whose slot is in 0 to 35 (`isValidInContainer`).

The main hand is not stored in `equipment`: for a player the `MAINHAND` slot of the equipment object is redirected to the selected inventory slot (`PlayerEquipment`), so the held item exists once, in `Inventory` at `SelectedItemSlot`.

### 2.5 Entity-layer keys written into the player compound (names only)

`Entity.saveWithoutId` writes (owned by 45 section 1): `Pos` (3 doubles), `Motion` (3 doubles), `Rotation` (2 floats), `fall_distance`, `Fire`, `Air`, `OnGround`, `Invulnerable`, `PortalCooldown`, `invulnerable_time`, `UUID`, `CustomName`, `CustomNameVisible`, `Silent`, `NoGravity`, `Glowing`, `TicksFrozen`, `HasVisualFire`, `Tags`, `data` (custom data), and `Passengers` when there are non-player passengers. `Team` is read but written elsewhere. The `id` key is not written for a player (`saveWithoutId`). Entity load validates position (each coordinate within a fixed range of plus or minus 3.0000512E7 horizontally and plus or minus 2.0E7 vertically, else the load fails with "Entity has invalid position") and rotation ("Entity has invalid rotation"); motion components are clamped to a magnitude of 10.0 (constant 10.0d appears three times in the load).

LivingEntity layer keys that apply to the player (names only, owned by 45 section 2): `Health`, `HurtTime`, `DeathTime`, `AbsorptionAmount`, `current_impulse_context_reset_grace_time`, `current_explosion_impact_pos`, `attributes`, `active_effects`, `FallFlying`, `Brain`, `last_hurt_by_player`, `last_hurt_by_player_memory_time`, `last_hurt_by_mob`, `ticks_since_last_hurt_by_mob`, `equipment`, `locator_bar_icon` (the 16 keys `LivingEntity.addAdditionalSaveData` writes, in that order). `sleeping_pos` is also a LivingEntity key, read in its load.

---

## 3. ServerPlayer keys (`ServerPlayer.addAdditionalSaveData`, `readAdditionalSaveData`)

### 3.1 Table

| Key | NBT type | Written | On load |
|---|---|---|---|
| `warden_spawn_tracker` | Compound | always | Optional; when absent a fresh tracker is created. Section 6.3. |
| `playerGameType` | Int | always | Section 3.4. |
| `previousPlayerGameType` | Int | only when a previous mode exists | Optional. |
| `seenCredits` | Byte (boolean) | always | false |
| `entered_nether_pos` | List of 3 Double | only when set (`storeNullable`) | Optional; the overworld position at which the player last entered the Nether (used by the portal rules). Null when absent. |
| `last_explosion_impact_pos` | List of 3 Double | only when set | Optional; the position of the last explosion impact on this player. Null when absent. |
| `RootVehicle` | Compound | only when riding, see 3.3 | read by the join sequence, not by this method |
| `recipeBook` | Compound | always | Optional. Section 3.5. |
| `Dimension` | String (dimension key, namespaced) | always | read by the join sequence (section 7), not by this method |
| `respawn` | Compound | only when a respawn point is set | Optional. Section 6.1. |
| `spawn_extra_particles_on_fall` | Byte | always | false |
| `raid_omen_position` | Int Array [x, y, z] | only when set | Optional; a block position of an active raid omen. |
| `ender_pearls` | List of Compound | only when at least one pearl is in flight | read by the join sequence |
| `post_effects` | List of String (identifiers) | always (list, may be empty) | Optional; appended to the player's post-effect list (screen shader effects). |
| `ShoulderEntityLeft` | Compound | only when non-empty | Optional; default empty compound. Section 3.6. |
| `ShoulderEntityRight` | Compound | only when non-empty | Optional; default empty compound. |

Order of writing: `warden_spawn_tracker`, game types, `seenCredits`, `entered_nether_pos`, `last_explosion_impact_pos`, `RootVehicle`, `recipeBook`, `Dimension`, `respawn`, `spawn_extra_particles_on_fall`, `raid_omen_position`, `ender_pearls`, `post_effects`, shoulder entities. The ServerPlayer layer is 16 keys, 9 of them conditional: `previousPlayerGameType`, `entered_nether_pos`, `last_explosion_impact_pos`, `RootVehicle`, `respawn`, `raid_omen_position`, `ender_pearls`, `ShoulderEntityLeft`, `ShoulderEntityRight`.

Name mapping against the scope list of this round: `enteredNetherPosition` is saved as `entered_nether_pos`; `current_explosion_impact_pos` (LivingEntity layer, persisted under that name together with `current_impulse_context_reset_grace_time`) and `last_explosion_impact_pos` (ServerPlayer layer) are two keys that both exist in the player compound; the ServerPlayer key is saved and loaded through the field named `currentExplosionImpactPos` (section 2.1; a different field from the one behind `current_explosion_impact_pos`); `seen_credits` is saved as `seenCredits`; `spawn point` is the `respawn` compound. `current_impulse_context` and `ignore_fall_damage_from_current_explosion` are not persisted (section 2.1).

### 3.2 Load order

1. Player layer (section 2.1).
2. `warden_spawn_tracker`, `entered_nether_pos`, `last_explosion_impact_pos`, `seenCredits`.
3. `recipeBook` (section 3.5).
4. If the player is sleeping after the above, wake it (`stopSleeping`): a saved `sleeping_pos` never keeps the player in bed after a load.
5. `respawn`, `spawn_extra_particles_on_fall`, `raid_omen_position`.
6. Game modes (section 3.4), `post_effects`, shoulder entities.

### 3.3 Vehicle (`saveParentVehicle`, `loadAndSpawnParentVehicle`)

Save: when the player has a vehicle, the player is not itself the root, and the root vehicle has exactly one player passenger, write `RootVehicle` = compound with `Attach` (the immediate vehicle's UUID as an Int Array of 4, `UUIDUtil.CODEC`) and `Entity` (the complete save compound of the root vehicle, `Entity.save`, so it includes `id`; its passengers are nested inside it through `Passengers`, with the player omitted). When the root has several players or the player rides nothing, nothing is written.

The save of a leaving player happens before the player is dismounted (`PlayerList.remove` calls `save` first, then, only when the player is a passenger and its root vehicle has exactly one player passenger, logs "Removing player mount" (debug level), calls `stopRiding` and marks the root vehicle and each entity of `getPassengersAndSelf` as removed with the reason `UNLOADED_WITH_PLAYER`; the player's `unRide` is called afterwards unconditionally), so the vehicle is recorded.

Load (after `placeNewPlayer`, section 7): if `RootVehicle` is absent, do nothing. Otherwise load the entity compound under `Entity` (an empty compound when missing) recursively with the LOAD spawn reason into the player's level. The recursive load hands every loaded entity to an entity processor, which adds it to the level keeping its saved UUID (`addWithUUID`); the nested `Passengers` lists are loaded through the same recursive load, so each passenger is added the same way. If the root's add fails the processor yields null and the load stops silently (no log line, no riding). If the loaded root's UUID equals `Attach`, the player starts riding it (`startRiding(entity, force true, sendEvent false)`); otherwise search the root's indirect passengers for the one whose UUID equals `Attach` and ride that one. If the player is not a passenger afterwards, log "Couldn't reattach entity to player", discard the loaded root and all its indirect passengers.

### 3.4 Game modes

`playerGameType` and `previousPlayerGameType` use the legacy numeric codec (`GameType.LEGACY_ID_CODEC`): Int 0 survival, 1 creative, 2 adventure, 3 spectator (the names are `survival`, `creative`, `adventure`, `spectator`). `playerGameType` is written always; `previousPlayerGameType` only when non-null.

On load: read both as nullable. The current mode passes through `calculateGameModeForNewPlayer(stored)`:

1. If the server has a forced game type (`MinecraftServer.getForcedGameType`), and the server is a dedicated server, the forced type is the result; if it is not dedicated, the forced type is the result unless the player has the gamemaster permission level (`Permissions.COMMANDS_GAMEMASTER`), in which case step 2 applies.
2. Otherwise the result is the stored mode when present, else the server's default game type.

Then `ServerPlayerGameMode.setGameModeForPlayer(result, previousStored)` is called, which stores both modes and recomputes the abilities from the result (section 2.2). A previous mode that cannot be decoded is null.

### 3.5 `recipeBook` compound (`ServerRecipeBook$Packed.CODEC`, `RecipeBookSettings`)

One compound whose keys are the settings merged flat with two lists:

| Key | Type | Default | Meaning |
|---|---|---|---|
| `isGuiOpen` | Boolean | false | crafting book open |
| `isFilteringCraftable` | Boolean | false | crafting "craftable only" filter |
| `isFurnaceGuiOpen` | Boolean | false | furnace book open |
| `isFurnaceFilteringCraftable` | Boolean | false | |
| `isBlastingFurnaceGuiOpen` | Boolean | false | |
| `isBlastingFurnaceFilteringCraftable` | Boolean | false | |
| `isSmokerGuiOpen` | Boolean | false | |
| `isSmokerFilteringCraftable` | Boolean | false | |
| `recipes` | List of String (recipe keys, identifiers) | required | the recipes the player has unlocked (the "known" set) |
| `toBeDisplayed` | List of String | required | recipes unlocked but not yet shown (highlight set) |

The eight settings are optional; the two lists are required, so a `recipeBook` compound without both lists is rejected as a whole and the book stays empty.

Load (`ServerRecipeBook.loadUntrusted`): both sets are cleared, settings replaced from the compound, then each listed recipe key is kept only if the server's recipe manager still has a recipe with that key; an unknown key is dropped with the log line "Tried to load unrecognized recipe: <key> removed now." Kept keys go into the known set or the highlight set respectively. On join the book is sent to the client (`sendInitialRecipeBook`; packets in 05a/05b).

Save: the packed form of the current sets and settings, always written.

### 3.6 Shoulder entities

`ShoulderEntityLeft` and `ShoulderEntityRight` hold a complete entity save compound (including `id`) of a parrot sitting on the player's shoulder, or are absent. They are opaque here: the compound is stored exactly as the entity wrote it (the codec is the raw compound codec). The parrot's keys are in the sibling documents for concrete types. Absent keys give empty compounds.

### 3.7 Ender pearls in flight (`saveEnderPearls`, `loadAndSpawnEnderPearls`)

Save: for every thrown ender pearl owned by the player (a set held by the player entity), if the pearl is not removed, add one compound to `ender_pearls`: the pearl's full `save` compound plus the extra key `ender_pearl_dimension` (the level resource key of the level the pearl is in, a dimension key string). A pearl already removed at save time is skipped with a warning "Trying to save removed ender pearl, skipping". If the set is empty the key is omitted.

Load (after `placeNewPlayer`): for each element, read `ender_pearl_dimension`; if missing, skip. Look up that level on the server and continue as follows.

1. `ender_pearl_dimension` missing or undecodable as a dimension key: skip the element silently.
2. The level is not loaded: log a warning "Trying to load ender pearl without level (<key>) being loaded, skipping" and skip.
3. Otherwise load the element recursively with the LOAD spawn reason, with an entity processor that adds the entity to that level keeping its UUID. If the load or the add fails, log a warning "Failed to spawn player ender pearl in level (<key>), skipping".
4. On success place a chunk ticket of type `ender_pearl` with radius 2 at the pearl's chunk (`placeEnderPearlTicket`). The ticket type is registered with a timeout of 40 (a long constant; the third registration argument, 14, was not interpreted, Open question 17). The returned timeout is ignored here.

On leave (`PlayerList.remove`) pearls still in flight are removed with the reason "unloaded with player" after the save.

---

## 4. Item stack and slot codecs

### 4.1 Slot element (`net.minecraft.world.ItemStackWithSlot.CODEC`)

An inventory list element is a compound containing the stack's fields at the same level plus one extra key:

| Key | NBT type | Default | Meaning |
|---|---|---|---|
| `Slot` | Byte | 0 (read: the codec's default constant is 0) | Slot index. The codec is the unsigned byte codec (`ExtraCodecs.UNSIGNED_BYTE`): a Byte decodes through an unsigned conversion that cannot fail, so a stored Byte of -1 loads as 255. Only the encode direction can error (an Integer above 255). A loaded slot outside the container size is dropped later by `isValidInContainer`, not by the codec. Written as a Byte. |
| `id` | String | required | The item key, e.g. a namespaced item identifier. An unknown key fails the element (the element is dropped). |
| `count` | Int | 1 | Always written, even when it is 1 (the field is an always-present optional with default 1, so a stack of one carries `count: 1`). Stack size, range 1 to 99 (`ExtraCodecs.intRange(1, 99)`); outside that range fails the element; a missing key loads as 1. |
| `components` | Compound | omitted when empty | A patch of data components applied on top of the item's default components (`DataComponentPatch.CODEC`; written only when the patch is non-empty; removed defaults are written with a key prefixed by `!`, see below). The component schemas are data driven by the registry and are in 17 section 1; they are not repeated here, so the content of `components` values is specified there, not in this document. |

`components` patch syntax (`DataComponentPatch.CODEC`, read): a map from key string to value. A key is a component type identifier, optionally prefixed by `!`. Without the prefix the value is encoded by that component type's own codec and sets the component. With the prefix the entry removes a default component of that type; its value is encoded by the `Removed` codec (a marker type with a single instance; its exact NBT form was not read, Open question 20). On load the prefix is stripped, the identifier parsed and looked up in the data-component-type registry: an unknown identifier fails the decode, and so does a type marked transient (not persisted).

An element is accepted into a container of size n when 0 <= Slot < n (`isValidInContainer`).

Worked example (a stack of 16 snowballs in hotbar slot 2, no extra components):

| Element | Value |
|---|---|
| `Slot` | Byte 2 |
| `id` | String `minecraft:snowball` |
| `count` | Int 16 |

The element has exactly three keys; `components` is absent. A single snowball in the same slot is written with `count` Int 1, not with the key omitted.

### 4.2 Inventory list rules

- Only non-empty stacks are written, in slot order 0 to 35.
- On load all 36 slots are first emptied, then elements are placed in list order (a later element for the same slot replaces an earlier one).
- The list type is List of Compound; an empty inventory is an empty list (the key is still written).

### 4.3 `equipment` (LivingEntity key, applies to the player)

`EntityEquipment.CODEC` is a compound mapping slot names to item stacks (stack fields `id`, `count`, `components` directly inside, no `Slot`). Slot names (`EquipmentSlot` serialized names): `mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`. Empty stacks are removed before writing (`removeIf` on empty), so an empty equipment is an empty compound. Each stored stack always carries `count`, including 1 (section 4.1), and `components` only when its patch is non-empty. For a player `mainhand` never appears (section 2.4). On load a missing `equipment` key yields an empty equipment object that replaces the current one.

---

## 5. The ender chest container (`PlayerEnderChestContainer`)

27 slots (the container's constructor size, constant 27, three rows of nine). Stored under `EnderItems` with the same slot element as the inventory (section 4.1): only non-empty slots, slot 0 to 26. On load all 27 slots are emptied first, then elements with 0 <= Slot < 27 are placed. The container also remembers the one ender chest block entity that has it open (`setActiveChest`), which is not persisted; `stillValid` checks that active chest. The opening and closing animation and the viewer count are in the block entity document (RS13, 31).

---

## 6. Compound forms used above

### 6.1 `respawn` (`ServerPlayer$RespawnConfig.CODEC`, `LevelData$RespawnData.MAP_CODEC`, `GlobalPos.MAP_CODEC`)

One flat compound:

| Key | Type | Constraint | Default |
|---|---|---|---|
| `dimension` | String | a dimension key | required |
| `pos` | Int Array of 3 (x, y, z) | block position | required |
| `yaw` | Float | -180.0 to 180.0 | required |
| `pitch` | Float | -90.0 to 90.0 | required |
| `forced` | Boolean | | false (optional; a forced spawn point set by command stays valid without a bed) |

The same four keys `dimension`, `pos`, `yaw`, `pitch` form the world spawn (`RespawnData`) in `level.dat` (07 section 7 for the standard `level.dat`), which is why the join sequence reads the world spawn with the same type.

### 6.2 `LastDeathLocation` (`GlobalPos.CODEC`)

A compound with `dimension` (String key) and `pos` (Int Array of 3). Written only if the player has died at least once (the optional is set on death and by commands); cleared never by save.

### 6.3 `warden_spawn_tracker` (`WardenSpawnTracker.CODEC`)

A compound of three optional non-negative Ints (`NON_NEGATIVE_INT`), all default 0 (each codec default read as 0; the 12000 constant in the class is the decrease interval, not a field default, and the no-argument constructor sets all three fields to 0): `ticks_since_last_warning`, `warning_level`, `cooldown_ticks`. Constants in the class: `MAX_WARNING_LEVEL` 4, `WARNING_CHECK_DIAMETER` 48, `DECREASE_WARNING_LEVEL_EVERY_INTERVAL` 12000, `WARNING_LEVEL_INCREASE_COOLDOWN` 200. The tracker logic belongs to the warden section (45 section for deep dark mobs and 21).

### 6.4 `Vec3` and `BlockPos` encodings

`Vec3` is a List of exactly 3 Doubles (read as a list of doubles, indexed 0 to 2). `BlockPos` is an Int Array of 3 (`Codec.INT_STREAM`, stable). `UUID` fields use the Int Array of 4 form (`UUIDUtil.CODEC`), most significant int first.

---

## 7. Join sequence (what is merged into the joining player)

Reading `PrepareSpawnTask.start`, `PrepareSpawnTask$Ready.spawn` and `PlayerList.placeNewPlayer`:

1. **Start (configuration phase, before the play state).** Load the compound with `PlayerList.loadPlayerData` (section 1.5), the first of two reads of the player file in a join (step 6 reads it again). If a compound exists, decode a "saved position" from it (`ServerPlayer$SavedPosition.MAP_CODEC`): three optional keys at the top level: `Dimension` (String), `Pos` (3 Doubles), `Rotation` (2 Floats, yaw then pitch, read as a 2-element float list). No compound or a failed decode gives a saved position with all three empty.
2. **Dimension.** If the saved `Dimension` names a level that exists on this server, that level is the spawn level. Otherwise (key missing or the level does not exist) use the level named by the world spawn's `dimension` (`overworldData().getRespawnData()`), and if that level does not exist either, the overworld.
3. **Position.** If a saved `Pos` exists it is used as is (also when the dimension fell back, the position is not reset). Otherwise run the spawn finder (`PlayerSpawnFinder.findSpawn(level, worldSpawn.pos)`) in the spawn level, asynchronously; its algorithm is GAP-28 (10 section 5 for the spawn target).
4. **Rotation.** If a saved `Rotation` exists use it, otherwise the world spawn's `yaw` and `pitch`.
5. **Wait.** The task prepares and waits until the target chunk and its neighbours are ready (state machine `Preparing` then `Ready`).
6. **Spawn.** Wait for entities of the chunk containing the target position within radius 3 (`waitForEntities(chunkPos, 3)`); construct the `ServerPlayer` in the spawn level with the game profile and the client information; call `PlayerList.loadPlayerData` a second time (`PrepareSpawnTask$Ready.spawn`), so the compound loaded into the player is the result of this second read, while the saved position, dimension and rotation of steps 1 to 4 came from the first read (a file changed between the reads would give a mix; the section 1.3 backup step also runs per read); load that compound into it (`Player.load`, i.e. the Entity layer, LivingEntity layer, Player layer, ServerPlayer layer in that order, section 2); then force the position and rotation with `snapTo(position, yaw, pitch)` so the file's `Pos` and `Rotation` can never place the player somewhere that disagrees with the fallbacks above.
7. **Place.** `PlayerList.placeNewPlayer` runs: name cache update, the login packet and initial state (packets 05a/05b; abilities packet, held-slot packet, recipes, permission level, stats `markAllDirty`, recipe book, scoreboard), the join message (`multiplayer.player.joined`, or `multiplayer.player.joined.renamed` when the cached name differs), the teleport confirmation to the final position, player-info packets, adding the player to the level, active effects and post effects.
8. **Restore riders.** After placement, in this order: ender pearls (section 3.7) then `RootVehicle` (section 3.3).

The `Dimension` of the compound is the dimension of the last save (`ServerLevel.dimension` identifier string) and is stored by the ServerPlayer layer, so a player that last saved in the Nether rejoins in the Nether at the saved `Pos`.

---

## 8. `advancements/<uuid>.json`

Path `players/advancements/<uuid>.json`, UTF-8 JSON, written pretty-printed (`GsonBuilder.setPrettyPrinting`, Gson's default of two spaces per level) directly to the file (not through a temporary file; the write replaces the file in place). The parent directory is created if needed.

Root object: one member per advancement that has progress, whose name is the advancement identifier, plus the member `DataVersion` (Int, written by the type wrapper `DataFixTypes.ADVANCEMENTS.wrapCodec`; the default when absent is the helper's default, and the type's data fixer runs from that version).

Each advancement member is an object:

| Member | JSON type | Meaning |
|---|---|---|
| `criteria` | object | one member per criterion that has been **obtained**, name = criterion name, value = string timestamp in the pattern `yyyy-MM-dd HH:mm:ss Z` (root locale, the zone offset as `+0000`-style text; the instant is the moment obtained). Unobtained criteria are not written. |
| `done` | boolean | true when the advancement is complete. Optional with default false. |

Which advancements are written (`asData`): only those whose progress object has at least one obtained criterion (`hasProgress`). An advancement with no obtained criteria is absent.

Loading (`PlayerAdvancements.load`): if the file is a regular file, parse it with the strict JSON parser, decode through the codec with the data fixer, and apply (`applyFrom`): for each member, look up the advancement in the server's advancement manager; if it no longer exists, log a warning "Ignored advancement '<id>' in progress file <path> - it doesn't exist anymore?" and skip it. Otherwise install the progress (criteria names that the advancement no longer has are handled by the progress object, not traced), mark it changed and update the visibility tree. A parse or IO failure is logged ("Couldn't parse player advancements in <path>" / "Couldn't access player advancements in <path>") and the player starts with no progress. After loading, automatic triggers are checked and trigger listeners are registered for every incomplete advancement.

Worked example:

```json
{
  "minecraft:story/root": {
    "criteria": { "crafting_table": "2026-11-06 14:03:22 +0000" },
    "done": true
  },
  "DataVersion": 5023
}
```

Timestamps are written in the zone the formatter uses for the instant (`temporalCodec` over the instant; the zone used when none is given is not traced, Open question 9).

The advancement definitions (criteria, rewards, display) are data and are not specified here; the client sync packets for advancements are in 05b.

---

## 9. `stats/<uuid>.json`

Path `players/stats/<uuid>.json`, UTF-8 JSON, pretty-printed, written in place (create parent directories, then write). Loading happens in the `ServerStatsCounter` constructor if the file is a regular file: parse strictly, run the STATS data fixer from `DataVersion` (default **1343** when the member is absent, `NbtUtils.getDataVersion(dynamic, 1343)`), take the member `stats` (empty object when missing) and decode it. Read and parse failures are logged ("Couldn't read statistics file <path>", "Couldn't parse statistics file <path>") and the counter starts empty. A decode error for part of `stats` is logged per error and the rest that decoded is kept (`resultOrPartial`).

Root object:

| Member | Type | Meaning |
|---|---|---|
| `stats` | object | category name to object of key to Int |
| `DataVersion` | number | 5023 on write |

Layout of `stats`: `{ "<stat type key>": { "<registry entry key>": <Int>, ... }, ... }`. The outer key is a stat type identifier from the stat-type registry; the inner key is an entry of the registry that type counts over, as a namespaced identifier; values are Int counts (`Codec.INT`). A stat type with no counts is not written. An outer key not in the stat-type registry or an inner key not in the type's registry fails that part of the decode.

Stat types and their key registries (the nine type names and the registry each counts over are read from the `Stats` static initializer, which creates each type through `makeRegistryStatType`):

| Stat type | Counts over | Meaning |
|---|---|---|
| `mined` | block registry | blocks broken |
| `crafted` | item registry | items crafted |
| `used` | item registry | items used (placed, consumed, used on) |
| `broken` | item registry | tools or armor broken |
| `picked_up` | item registry | items picked up |
| `dropped` | item registry | items dropped |
| `killed` | entity-type registry | mobs killed |
| `killed_by` | entity-type registry | times killed by a mob |
| `custom` | custom-stat registry | the table below |

Custom statistics (`Stats`): 78 identifiers, all in the standard namespace, registered in the order below through `makeCustomStat`, each with a formatter read from the call site. Formatter meanings: default (plain integer), distance (centimetres shown as metres or kilometres), divide by ten (tenths), time (ticks shown as a duration). Counts: 49 default, 17 distance, 7 divide by ten, 5 time.

| # | Identifier | Formatter |
|---|---|---|
| 1 | `leave_game` | default |
| 2 | `play_time` | time |
| 3 | `total_world_time` | time |
| 4 | `time_since_death` | time |
| 5 | `time_since_rest` | time |
| 6 | `sneak_time` | time |
| 7 | `walk_one_cm` | distance |
| 8 | `crouch_one_cm` | distance |
| 9 | `sprint_one_cm` | distance |
| 10 | `walk_on_water_one_cm` | distance |
| 11 | `fall_one_cm` | distance |
| 12 | `climb_one_cm` | distance |
| 13 | `fly_one_cm` | distance |
| 14 | `walk_under_water_one_cm` | distance |
| 15 | `minecart_one_cm` | distance |
| 16 | `boat_one_cm` | distance |
| 17 | `pig_one_cm` | distance |
| 18 | `happy_ghast_one_cm` | distance |
| 19 | `horse_one_cm` | distance |
| 20 | `aviate_one_cm` | distance |
| 21 | `swim_one_cm` | distance |
| 22 | `strider_one_cm` | distance |
| 23 | `nautilus_one_cm` | distance |
| 24 | `jump` | default |
| 25 | `drop` | default |
| 26 | `damage_dealt` | divide by ten |
| 27 | `damage_dealt_absorbed` | divide by ten |
| 28 | `damage_dealt_resisted` | divide by ten |
| 29 | `damage_taken` | divide by ten |
| 30 | `damage_blocked_by_shield` | divide by ten |
| 31 | `damage_absorbed` | divide by ten |
| 32 | `damage_resisted` | divide by ten |
| 33 | `deaths` | default |
| 34 | `mob_kills` | default |
| 35 | `animals_bred` | default |
| 36 | `player_kills` | default |
| 37 | `fish_caught` | default |
| 38 | `talked_to_villager` | default |
| 39 | `traded_with_villager` | default |
| 40 | `eat_cake_slice` | default |
| 41 | `fill_cauldron` | default |
| 42 | `use_cauldron` | default |
| 43 | `clean_armor` | default |
| 44 | `clean_banner` | default |
| 45 | `clean_shulker_box` | default |
| 46 | `interact_with_brewingstand` | default |
| 47 | `interact_with_beacon` | default |
| 48 | `inspect_dropper` | default |
| 49 | `inspect_hopper` | default |
| 50 | `inspect_dispenser` | default |
| 51 | `play_noteblock` | default |
| 52 | `tune_noteblock` | default |
| 53 | `pot_flower` | default |
| 54 | `trigger_trapped_chest` | default |
| 55 | `open_enderchest` | default |
| 56 | `enchant_item` | default |
| 57 | `play_record` | default |
| 58 | `interact_with_furnace` | default |
| 59 | `interact_with_crafting_table` | default |
| 60 | `open_chest` | default |
| 61 | `sleep_in_bed` | default |
| 62 | `sleep_in_straw_bed` | default |
| 63 | `open_shulker_box` | default |
| 64 | `open_barrel` | default |
| 65 | `interact_with_blast_furnace` | default |
| 66 | `interact_with_smoker` | default |
| 67 | `interact_with_lectern` | default |
| 68 | `interact_with_campfire` | default |
| 69 | `interact_with_cartography_table` | default |
| 70 | `interact_with_loom` | default |
| 71 | `interact_with_stonecutter` | default |
| 72 | `bell_ring` | default |
| 73 | `raid_trigger` | default |
| 74 | `raid_win` | default |
| 75 | `interact_with_anvil` | default |
| 76 | `interact_with_grindstone` | default |
| 77 | `target_hit` | default |
| 78 | `interact_with_smithing_table` | default |

The string `sleep_in_straw_bed` is exactly as read; it is a real custom statistic: registered through `makeCustomStat` with the default formatter, directly after `sleep_in_bed` (read). The formatter of every identifier is in the table above. A text search for `makeCustomStat` gives 79 hits because it includes the method definition itself; the 78 identifiers above match the call sites in order.

Behaviour: `increment(player, stat, n)` adds n (saturating at the Int range, (inferred, not traced)) and `setValue` replaces; both mark the stat dirty for the next stats packet (`getDirty`, `sendStats`). `PlayerList.remove` increments `leave_game` before saving. Saves occur from `PlayerList.save` (called by leave and save-all) as `ServerStatsCounter.save` (when the counter exists for that UUID) and `PlayerAdvancements.save`, after the player data write.

Legacy: a file with `DataVersion` below the current one (or with no `DataVersion`, taken as 1343) goes through the STATS data fixer before decoding. The fixer's steps (the old flat `stat.<category>.<key>` names) are not read in this round (Open question 8).

Worked example:

```json
{
  "stats": {
    "minecraft:mined": { "minecraft:stone": 12, "minecraft:dirt": 3 },
    "minecraft:custom": { "minecraft:leave_game": 1, "minecraft:play_time": 4800 }
  },
  "DataVersion": 5023
}
```

---

## 10. Mannequin (`net.minecraft.world.entity.decoration.Mannequin`)

The Mannequin extends `Avatar`, as `Player` does, but it does **not** share the Player codec: `Avatar` itself has no save methods, and the Mannequin writes its own keys after the LivingEntity and Entity layers:

| Key | NBT type | Written | On load |
|---|---|---|---|
| `profile` | Compound (`ResolvableProfile.CODEC`, a game profile by name or id and optional skin patch) | always | optional; keeps the current profile when absent |
| `hidden_layers` | the model-layer set codec (`LAYERS_CODEC`, encodes the skin-layer bitmask from the synched value `DATA_PLAYER_MODE_CUSTOMISATION`) | always | default: all layers shown (`ALL_LAYERS`) |
| `main_hand` | String (`HumanoidArm.CODEC`, `left` or `right`) | always | default `DEFAULT_MAIN_HAND` |
| `pose` | String (limited pose codec `POSE_CODEC`) | always | default standing |
| `immovable` | Byte | always | false |
| `description` | text component (`ComponentSerialization.CODEC`) | only when a description exists and differs from the default description `DEFAULT_DESCRIPTION` | the default description (translation key `entity.minecraft.mannequin.label`) |
| `hide_description` | Byte | written (true) only when the description is absent | false |

The skin layer bit values and the pose limit list are in 12 (player model) and 47; the exact members of `POSE_CODEC` and `LAYERS_CODEC` are not traced (Open question 11). A Mannequin is a normal entity in `entities/` storage (not a player file) and carries `id` there.

---

## 11. Save-time sequences

| Event | Order of writes |
|---|---|
| Leave | `leave_game` stat plus one; `PlayerDataStorage.save`; stats file; advancements file; only when a passenger whose root vehicle has exactly one player passenger: log, `stopRiding`, root and its passengers removed (`UNLOADED_WITH_PLAYER`); `unRide` of the player; remove pearls; remove player from level. |
| Periodic or manual save-all | for each online player: `.dat` (section 1.2), stats, advancements. |
| First join | none until the first of the above. |

Files are independent: a failed write of one of the three does not stop the others.

---

## 12. Differences from CobolCraft's own layout (07 section 9.2)

| Item | CobolCraft (07 section 9.2) | Standard (this document) |
|---|---|---|
| Path | `players/<offline-uuid>.dat` | `players/data/<uuid>.dat` with `.dat_old` backup and `_corrupted_` copies |
| Write | in place | temporary file, backup rotation, retries |
| Keys | `Name`, `Dimension`, `Pos`, `Rotation`, `GameMode` (Int), `Health`, `Food`, `Inventory`, `HeldSlot` | Section 2 and 3. No `Name`, no `GameMode`, no `Food`, no `HeldSlot`. |
| `Inventory` element | `{Slot: Byte, id, count}` slots 0 to 35, `count` Int | same shape plus optional `components`; `count` 1 to 99; armor, off-hand not in this list |
| Held slot | `HeldSlot` | `SelectedItemSlot` |
| Game mode | `GameMode` Int | `playerGameType` Int (same numbering 0 to 3) and `previousPlayerGameType` |
| Food | `Food` | four `food*` keys |
| Dimension | key, folder `cobolcraft/main` | key `minecraft:overworld` etc. |

The cobolcraft world type keeps 07 section 9.2 unchanged. The standard world type uses this document. Both use gzip NBT with `DataVersion` 5023.

---

## 13. Validation

Implementation checks, each stated with inputs and expected results:

1. Save then load a default player. Expected compound has exactly these top-level key groups: the Entity and LivingEntity keys of 45 sections 1 and 2, the Player keys `DataVersion`, `Inventory` (empty list), `SelectedItemSlot` 0, `SleepTimer` 0, `XpP` 0.0, `XpLevel` 0, `XpTotal` 0, `XpSeed` (non-zero after a fresh seed), `Score` 0, `foodLevel` 20, `foodTickTimer` 0, `foodSaturationLevel` 5.0, `foodExhaustionLevel` 0.0, `abilities` (seven keys), `EnderItems` (empty list), and the ServerPlayer keys `warden_spawn_tracker`, `playerGameType`, `seenCredits`, `recipeBook`, `Dimension`, `spawn_extra_particles_on_fall`, `post_effects`. Absent: `LastDeathLocation`, `previousPlayerGameType`, `entered_nether_pos`, `last_explosion_impact_pos`, `RootVehicle`, `respawn`, `raid_omen_position`, `ender_pearls`, both shoulder keys.
2. Slot round trip: 16 snowballs in slot 2, a stack in `EnderItems` slot 26, a stack in the feet slot. Expected: `Inventory` has one element `{Slot: 2b, id, count: 16}` (a stack of 1 would still write `count: 1`); `EnderItems` has `Slot: 26b`; `equipment` has `feet` only, whose stack carries `id` and `count` (always, also when 1). A hand-edited element with `Slot: 36b` in `Inventory` is dropped on load; `count: 0` and `count: 100` are dropped.
3. Atomic write: start with `<uuid>.dat` = A. Save B. Expected: `.dat` = B, `.dat_old` = A, no temp file remains. Save C: `.dat` = C, `.dat_old` = B.
4. Corruption: make `.dat` an unreadable file and `.dat_old` = A. Load. Expected: a `<uuid>_corrupted_<date>.dat` copy appears, the returned compound is A.
5. First join: no files. Expected: no compound, spawn level from the world spawn's `dimension`, position from the spawn finder at the world spawn position, rotation = world spawn yaw and pitch, game mode = server default.
6. Dimension fallback: saved `Dimension` names a removed level, saved `Pos` present. Expected: the spawn level is the world spawn's level, position stays the saved `Pos`.
7. Forced game type: dedicated server with forced type adventure, file `playerGameType` 1. Expected: adventure. Integrated server, forced adventure, player with gamemaster permission: creative; without: adventure.
8. Recipe book: `recipes` contains a key not in the recipe manager. Expected: dropped with the log line, the others kept; a compound missing `toBeDisplayed` is rejected whole.
9. Vehicle: player alone on a boat saved. Expected `RootVehicle.Attach` = the boat's UUID as 4 Ints and `RootVehicle.Entity` has `id` for the boat; on rejoin the player rides it. With two players in the boat: no `RootVehicle`.
10. Stats: `leave_game` increments by one at each leave; a stats file without `DataVersion` goes through the fixer from 1343.
11. Advancements: an advancement without obtained criteria is absent from the file; one that was removed from the data pack is skipped with the warning on load.

---

## Open questions

1. (Resolved: `DataVersion` defaults to -1, section 1.3.)
2. The fixer steps of `DataFixTypes.PLAYER` (what old files are upgraded and how, including the old slot numbers 100 to 103 and -106) were not read; only that the fixer runs from the file's version.
3. How the legacy `Player` compound in `level.dat` (`OLD_PLAYER`) is converted into a per-player file was not traced.
4. Range handling of `SelectedItemSlot` in `Inventory.setSelectedSlot` for values outside 0 to 8 was not traced.
5. (Resolved: `setGameModeForPlayer` calls `GameType.updatePlayerAbilities` unconditionally and the player load calls it after applying `abilities`, section 2.2; `isBlockPlacingRestricted` is true for adventure and spectator only.)
6. Whether any 26.3 code path other than the fixer reads armor from `Inventory` slots 100 to 103 was not found.
7. The interval of the periodic player save (the server's autosave tick) is in the server loop and not in this document.
8. The stats fixer's behaviour for legacy flat names was not read.
9. The time zone of the advancement timestamps (`ExtraCodecs.temporalCodec`) was not traced; the pattern was read.
10. (Resolved: `sleep_in_straw_bed` is a registered custom statistic and the per-identifier formatter table is in section 9.)
11. The member lists of `Mannequin.POSE_CODEC` and `LAYERS_CODEC` were not traced.
12. (Resolved: the `Slot` default 0 was read, section 4.1.)
13. (Resolved: the registry of each stat type was read from `Stats`, section 9.)
14. (Resolved: the `!` removal syntax was read from `DataComponentPatch.CODEC`, section 4.1.) The per-component value schemas are not in this document; they belong to 17 section 1.
15. The position handling `Entity.load` applies to a player file's `Pos` that is outside the world border is not traced.
16. (Resolved: the two keys use different fields, `currentExplosionImpactPos` and `currentImpulseImpactPos`, section 2.1.)
17. The ender pearl chunk ticket is registered with timeout 40 and a third registration argument 14; the meaning of that argument and the ticket's effect in the chunk system were not interpreted here (see the chunk-ticket documents when they exist).
18. The inbound keys read by the spawn-preparation task (`PrepareSpawnTask$Ready`) were taken from the class list and not re-verified in this document.
19. A table of load defaults for the keys inside the `recipeBook` compound beyond section 3.5 was not made.
20. The NBT form written by the `Removed` codec for a `!`-prefixed component entry was not read.
21. Not re-verified by the fixer pass of this round (the review did not reach them): the LivingEntity key list and order of section 2.5, the Entity load validation constants, the Mannequin keys of section 10, the `PrepareSpawnTask` radius and second read, the ender pearl ticket numbers, and the `ServerStatsCounter` default 1343. They keep the reader's original reading.
22. Whether the sibling documents 45 section 1 and 45 section 2 fully specify `Brain` memories, `attributes`, `active_effects`, `locator_bar_icon` and the leash keys was not checked here; this document only lists those names.
