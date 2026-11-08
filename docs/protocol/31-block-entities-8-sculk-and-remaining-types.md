# 31 Block entities, part 8: sculk family, statue, potent sulfur, test blocks and the registry sweep

| Item | Value |
|---|---|
| Covers | The game-event dispatch that block-entity listeners depend on; the vibration system (`VibrationSystem`, `Data`, `VibrationInfo`, `VibrationSelector`, `Listener`, `Ticker`, `User`); `SculkSensorBlockEntity`, `CalibratedSculkSensorBlockEntity`, `SculkShriekerBlockEntity` (block-entity side), `SculkCatalystBlockEntity` and its `CatalystListener` with the live `SculkSpreader`; `CopperGolemStatueBlockEntity`; `PotentSulfurBlockEntity`; `TestBlockEntity` and `TestInstanceBlockEntity`; and the completeness sweep of all 49 types of `BlockEntityTypes` |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap methods of one class), with no execution. Round RS13, part 8. Classes read: `net.minecraft.world.level.block.entity.{BlockEntity, BlockEntityType, BlockEntityTypes, BlockEntityTypeIds, SculkSensorBlockEntity (+ $VibrationUser), CalibratedSculkSensorBlockEntity (+ $VibrationUser), SculkShriekerBlockEntity (+ $VibrationUser), SculkCatalystBlockEntity (+ $CatalystListener), CopperGolemStatueBlockEntity, PotentSulfurBlockEntity, TestBlockEntity, TestInstanceBlockEntity (+ $Data, $Status, $ErrorMarker)}`, `...gameevent.{GameEvent, GameEvent$Context, GameEvent$ListenerInfo, GameEventDispatcher, GameEventListener, EuclideanGameEventListenerRegistry, DynamicGameEventListener, BlockPositionSource}`, `...gameevent.vibrations.*`, `...block.{SculkSensorBlock, CalibratedSculkSensorBlock, SculkShriekerBlock, SculkCatalystBlock, SculkBlock, SculkSpreader (+ $ChargeCursor), PotentSulfurBlock, CopperGolemStatueBlock, WeatheringCopperGolemStatueBlock, TestBlock, NoteBlock.getPitchFromNote}`, `...state.properties.{PotentSulfurState, SculkSensorPhase, TestBlockMode}`, `LevelChunk` (listener registration), `LevelAccessor.gameEvent`, `LivingEntity.die`, `Entity`, `Warden`, `ItemEntity`, `Cat`, `Ocelot`, `CopperGolem.turnToStatue`, `ClientboundBlockEntityDataPacket.create` |
| Related documents | 06 (chunk packet block-entity list), 07 (NBT, region files), 10 section 2 (Xoroshiro random source and positional factories), 24-8 (block rows of the blocks named here), 29 (`setBlock` pipeline, block events), 33 (tick order), 35-6 section 8 (the sculk spreader in world generation), 42-5, 42-6, 42-7 (particles, level event 3006), 44-x2 section 2 (sculk shrieker block and warden spawn tracker), 46 section 5.2 and 5.4 (game event and block entity type ids) |

Scope note. This document specifies **code-defined** behaviour: engines, constants, formulas, NBT keys and the registry of block
entity types. The data rows it depends on are not tabulated: the tags `vibrations`, `ignore_vibrations_sneaking` and
`shrieker_can_listen` (game events), `dampens_vibrations`, `occludes_vibration_signals`, `vibration_resonators`,
`sculk_replaceable`, `sculk_replaceable_world_gen`, `sculk_growth_inhibitors`, `copper_golem_statues`,
`causes_continuous_geyser_eruptions`, `causes_periodic_geyser_eruptions` (blocks), `dampens_vibrations` (items) and
`not_affected_by_geysers` (entity types) come from the vanilla data pack that the extraction tool builds (22, 23). Only the
tag **names** and the places where the engines read them are given here.

Correction to the round brief. The brief speaks of 50 registered block entity types. The artifact registers **49**:
`BlockEntityTypes` has 49 registration call sites (the 50th `register` invocation in the bytecode is the list overload calling the
array overload), `BlockEntityTypeIds` has 49 keys, and 46 section 5.4 lists 49 ids. Section 9 uses 49.

---

## 1. Facts of the `BlockEntity` base used here

Part 1 of this series owns the base class. These are the facts this part relies on, each read from `BlockEntity`.

| Fact | Value |
|---|---|
| Chunk-storage compound (`saveWithFullMetadata`) | the type's own `saveAdditional` keys, then the key `components` (the entity's `DataComponentMap`, `DataComponentMap.CODEC`), then the metadata `id` (the type key), `x`, `y`, `z` (ints) |
| Loading | `loadAdditional` for the type's keys, then `components` read with the same codec, defaulting to the empty map when absent |
| Default `getUpdateTag` | an **empty** compound |
| Default `getUpdatePacket` | none (null) |
| Sent to clients in a chunk packet | the update tag, so a type that does not override `getUpdateTag` sends an empty compound, which the chunk packet writes as a single `TAG_End` byte (06 section 3.2) |
| `onlyOpCanSetNbt` | true for exactly the six types `command_block`, `lectern`, `sign`, `hanging_sign`, `mob_spawner`, `trial_spawner` (the set `OP_ONLY_CUSTOM_DATA`) |
| Valid block states | `BlockEntityType.isValid(state)` is membership of the state's block in the type's valid-block set; a block entity constructed for a block outside the set throws |

The five types this part owns outright (`sculk_sensor`, `calibrated_sculk_sensor`, `sculk_catalyst`, `sculk_shrieker`,
`potent_sulfur`) override neither `getUpdateTag` nor `getUpdatePacket`: clients receive an empty tag for them and never receive a
block-entity-data packet for them. `copper_golem_statue` overrides `getUpdatePacket` only (section 7).

---

## 2. Game events as seen by block-entity listeners

A block entity that implements `GameEventListener$Provider` (the sculk sensor, calibrated sensor, shrieker and catalyst) is a
listener. This section is the delivery engine; the emitters (who posts which event) are spread over the other documents.

### 2.1 The game-event registry facts the engine uses

`GameEvent` has a notification radius. `DEFAULT_NOTIFICATION_RADIUS = 16`. Three events differ: `jukebox_play` 10,
`jukebox_stop_play` 10, `shriek` 32. All other events (58 of 61) use 16. The 61 keys and ids are in 46 section 5.2.

### 2.2 Posting an event (`GameEventDispatcher.post(event, position, context)`)

The context holds an optional source entity and an optional affected block state (`GameEvent$Context.of(entity)`, `of(state)`,
`of(entity, state)`). The block-position overloads of `LevelAccessor.gameEvent` post at the **centre** of the block
(`Vec3.atCenterOf`); the overload taking a registry key looks the event up in the `game_event` registry first. On a
`ServerLevel`, `gameEvent(event, Vec3, context)` hands straight to the dispatcher.

1. `r` = the event's notification radius; `P` = the block position containing the event position.
2. The section box is `[sectionOf(P.x - r), sectionOf(P.x + r)]` in x, the same in y and z (`blockToSectionCoord`, i.e. coordinate shifted right by 4).
3. For each chunk column (x outer, z inner) in the box whose chunk is loaded (`getChunkNow`, so no chunk is loaded or generated), for each section index y of the box (low to high), ask that section's listener registry to visit its listeners (section 2.3). Sections outside the box are never asked, whatever a listener's own radius.
4. The visit gives each qualifying listener to the dispatcher, which handles it by its delivery mode:
   - `UNSPECIFIED` (the default, used by the sensor, calibrated sensor and shrieker): `handleGameEvent` is called **immediately**, during the visit.
   - `BY_DISTANCE` (used by the catalyst): the listener is queued with the squared distance between the event position and the listener position.
5. After the whole box has been visited, the queue is sorted by that squared distance, **ascending** (a stable sort, so equal distances keep visit order), and `handleGameEvent` is called for each entry.

### 2.3 The per-section registry (`EuclideanGameEventListenerRegistry`)

A section registry holds its listeners in registration order. For each listener it visits: the listener's source position is
asked from its `PositionSource` (a `BlockPositionSource` returns the block centre and is always present); the listener qualifies
when the **block** distance squared between `BlockPos.containing(listenerPosition)` and `BlockPos.containing(eventPosition)` is
`<= listenerRadius * listenerRadius`. Note that only the listener's own radius filters; the event's radius only decides which
sections are asked. A listener registered or unregistered while a visit is running is deferred to the end of the visit.
Removing the last listener of a section removes the section registry.

### 2.4 Registration lifecycle of block-entity listeners

When a block entity is added to a chunk that is in a level (`LevelChunk.setBlockEntity` path, `isInLevel`) and the level is a
`ServerLevel`, `LevelChunk.addGameEventListener` runs: if the block of the entity's state is an `EntityBlock` and
`EntityBlock.getListener(level, entity)` returns a listener (the default returns the entity's `getListener()` when it is a
`GameEventListener$Provider`, else none), the listener is registered in the registry of the section that contains the entity's block
position. Removal of the entity unregisters it from the same section (`removeGameEventListener`). Client levels never register.

---

## 3. The vibration system

`VibrationSystem` is an interface implemented by the sculk sensor, calibrated sensor and shrieker block entities. Each holds:
a `Data` object (persisted), a `Listener` (the game-event listener, section 3.5), and a `User` (the policy object, section 3.3).

### 3.1 Frequencies

`getGameEventFrequency(event)` maps a game event key to an int 0 to 15; events not listed give 0 (`NO_VIBRATION_FREQUENCY`).

| Frequency | Events |
|---|---|
| 1 | `step`, `swim`, `flap` |
| 2 | `projectile_land`, `hit_ground`, `splash`, `bounce` |
| 3 | `item_interact_finish`, `projectile_shoot`, `instrument_play` |
| 4 | `entity_action`, `elytra_glide`, `unequip` |
| 5 | `entity_dismount`, `equip` |
| 6 | `entity_interact`, `shear`, `entity_mount` |
| 7 | `entity_damage` |
| 8 | `drink`, `eat` |
| 9 | `container_close`, `block_close`, `block_deactivate`, `block_detach` |
| 10 | `container_open`, `block_open`, `block_activate`, `block_attach`, `prime_fuse`, `note_block_play` |
| 11 | `block_change` |
| 12 | `block_destroy`, `fluid_pickup` |
| 13 | `block_place`, `fluid_place` |
| 14 | `entity_place`, `lightning_strike`, `teleport` |
| 15 | `entity_die`, `explode` |
| `n` for `n` = 1 to 15 | `resonate_n` |
| 0 | the five remaining events: `item_interact_start`, `jukebox_play`, `jukebox_stop_play`, `sculk_sensor_tendrils_clicking`, `shriek` |

(41 explicit events plus 15 resonate events give the 56 events with a non-zero frequency; with the five zero events that is the 61 of
the registry.) `getResonanceEventByFrequency(f)` returns the event `resonate_f` (the list of 15 is indexed `f - 1`).

### 3.2 Redstone strength and travel time

- `getRedstoneStrengthForDistance(distance, radius)`: `max(1, 15 - floor((15.0 / radius) * distance))`, with `distance` a float widened to double and `15.0 / radius` a double. The strength is always 1 to 15.
- `User.calculateTravelTimeInTicks(distance)` (default, not overridden by the three users): `floor(distance)` as an int.
- `Listener.distanceBetweenInBlocks(a, b)`: `(float) sqrt(distSqr(a, b))` of two block positions.

### 3.3 The `User` policy object

| Member | Default | Notes |
|---|---|---|
| `getListenerRadius()` | none | sensor 8, calibrated sensor 16, shrieker 8 |
| `getPositionSource()` | none | a `BlockPositionSource` of the entity's block position |
| `getListenableEvents()` | tag `vibrations` | the shrieker overrides it with tag `shrieker_can_listen` |
| `canTriggerAvoidVibration()` | false | true for the sensor and calibrated sensor |
| `requiresAdjacentChunksToBeTicking()` | false | true for all three |
| `calculateTravelTimeInTicks(f)` | `floor(f)` | |
| `isValidVibration(event, context)` | see below | |
| `canReceiveVibration(level, pos, event, context)` | none | per user |
| `onReceiveVibration(level, pos, event, sourceEntity, projectileOwner, distance)` | none | per user |
| `onDataChanged()` | nothing | the three users call `setChanged()` on the block entity |

`isValidVibration(event, context)`, in order (first match returns):
1. the event is not in `getListenableEvents()`: false.
2. the context has a source entity:
   a. a spectator: false;
   b. the entity `isSteppingCarefully()` and the event is in tag `ignore_vibrations_sneaking`: when the user `canTriggerAvoidVibration()` and the entity is a `ServerPlayer`, fire the criterion `avoid_vibration` for that player; return false;
   c. the entity `dampensVibrations()`: false.
3. the context has an affected state: true unless that state is in block tag `dampens_vibrations`.
4. otherwise true.

Entity predicates (read): `Entity.isSteppingCarefully()` is `isShiftKeyDown()`; `Cat` and `Ocelot` return true when crouching or when the base rule holds. `Entity.dampensVibrations()` is false; `Warden` returns true; `ItemEntity` returns whether its item stack is in item tag `dampens_vibrations`.

### 3.4 Persisted data and its NBT

`Data` has four fields: `currentVibration` (a `VibrationInfo` or none), `travelTimeInTicks` (int), `selectionStrategy` (a `VibrationSelector`),
`reloadVibrationParticle` (boolean, not persisted). The persisted form is a compound stored by the owner under the key `listener`:

| Key | Type | Rule |
|---|---|---|
| `event` | `VibrationInfo` compound | optional; absent when there is no vibration in flight; read leniently (an unreadable value counts as absent) |
| `selector` | `VibrationSelector` compound | **required**: when it is missing the whole `listener` value fails to decode and the owner uses a fresh `Data` |
| `event_delay` | int >= 0 | always written; default 0 on read; it is the remaining travel time |

On load the object is built with `reloadVibrationParticle = true`.

`VibrationInfo` compound (the `event` of the data and of the selector):

| Key | Type | Rule |
|---|---|---|
| `game_event` | registry holder of `game_event` | the key string, for example `minecraft:step` |
| `distance` | float, 0 to the maximum float | required |
| `pos` | `Vec3` | a list of three doubles x, y, z (the codec is `Codec.DOUBLE.listOf()` mapped to `Vec3`; the length check is inferred) |
| `source` | UUID | optional, lenient; the source entity's UUID, an int array of four ints (the codec is `UUIDUtil.CODEC`, an int stream mapped to a UUID; the length check is inferred) |
| `projectile_owner` | UUID | optional, lenient; the owner of the source entity when that entity is a projectile with an owner |

`VibrationInfo` also carries a runtime `entity` reference (not persisted). `getEntity(level)` is the runtime entity, else the entity found by the `source` UUID in the level; `getProjectileOwner(level)` is the source entity's owner when the source is a projectile, else the entity found by the `projectile_owner` UUID.

`VibrationSelector` compound: `event` (a `VibrationInfo`, optional, lenient) and `tick` (long, **required**). The save writes `tick = -1` when there is no candidate. When a candidate is read back it is the pair (info, tick).

### 3.5 `Listener.handleGameEvent` (the owner's game-event listener)

Steps, each returning false (event not accepted) on failure:
1. A vibration is already in flight (`currentVibration` present): false.
2. `user.isValidVibration(event, context)` is false: false.
3. The user's position source gives no position: false (the block position source always gives one).
4. `user.canReceiveVibration(level, BlockPos.containing(eventPosition), event, context)` is false: false.
5. The vibration is occluded (section 3.6): false.
6. Otherwise add a candidate to the selector (section 3.7) with `VibrationInfo(event, distance = eventPosition.distanceTo(listenerPosition) as float, eventPosition, source entity)` and the level's game time; return true.

`forceScheduleVibration(level, event, context, position)` skips steps 1 to 5: if the listener position is known it adds the candidate exactly as step 6 does. It is used by `SculkSensorBlock.stepOn` (section 4.4).

### 3.6 Occlusion

`isOccluded(level, eventPos, listenerPos)`: both positions are snapped to the centre of their block (`floor(coordinate) + 0.5` on each axis). For each of the six directions `d` (`Direction.values()` order), take the point `snappedEvent` moved by `0.00001` (9.999999747378752E-6) in direction `d` and ask the level whether a ray from that point to `snappedListener` meets a block state in block tag `occludes_vibration_signals` (`Level.isBlockInLine` with a `ClipBlockStateContext` and that predicate; a result of type BLOCK means such a block was met; that reading of the method is inferred from its name and use). If **any** of the six rays does not meet such a block the vibration is not occluded; it is occluded only when all six rays meet one.

### 3.7 Candidate selection (`VibrationSelector`)

State: at most one candidate (info, tick). `addCandidate(info, now)` replaces the candidate when:
1. there is no candidate; or
2. (a candidate exists) the new tick equals the candidate's tick **and**, in this order: the new distance is smaller than the candidate's, or (distances equal) the new frequency is strictly greater than the candidate's. A larger distance never replaces; an equal distance and an equal or lower frequency never replaces. A different tick never replaces.

`chosenCandidate(now)`: the candidate's info when `candidate.tick < now` (strictly earlier than the current game time), else none. `startOver()` clears the candidate.

### 3.8 The ticker (`VibrationSystem$Ticker.tick(level, data, user)`)

Run once per server tick by the owner's block ticker (server levels only; section 4.1). Does nothing on a client level.
1. If `currentVibration` is absent: `trySelectAndScheduleVibration`: ask the selector for `chosenCandidate(gameTime)`; if present: set `currentVibration` to it; set `travelTimeInTicks = user.calculateTravelTimeInTicks(info.distance)`; send one `vibration` particle (option: the user's position source and the travel time) at the info position through `sendParticles` (count 1, no offset, speed 0); call `user.onDataChanged()`; `selector.startOver()`.
2. If `currentVibration` is still absent: return.
3. `ticking = travelTimeInTicks > 0`.
4. `tryReloadVibrationParticle` (section 3.9).
5. Decrement the travel time, not below 0.
6. If the travel time is now `<= 0`: `ticking = receiveVibration(...)` (section 3.10).
7. If `ticking` is true: `user.onDataChanged()`.

### 3.9 Reloading the particle after a load

Only while `reloadVibrationParticle` is set. If `currentVibration` is absent, clear the flag and stop. Otherwise: `from` = the info position; `to` = the user's position-source position (default `from`); `T` = the stored travel time; `total` = `user.calculateTravelTimeInTicks(info.distance)`; `f = 1.0 - T / total` (double division); send a `vibration` particle (position source, travel time `T`) at `lerp(f, from, to)` on each axis through `sendParticles` (count 1, speed 0). The flag is cleared only when the call reports at least one recipient.

### 3.10 `receiveVibration`

1. `vibrationBlock` = `BlockPos.containing(info.pos)`; `listenerBlock` = the position source position as a block position (default `vibrationBlock`).
2. If `user.requiresAdjacentChunksToBeTicking()` and the 3 by 3 chunk neighbourhood of `listenerBlock` is not fully block-ticking and loaded (`shouldTickBlocksAt` and `getChunkNow` non-null for every one of the nine chunks): return false and **keep** the vibration (it is retried every tick).
3. Call `user.onReceiveVibration(level, vibrationBlock, event, sourceEntity or null, projectileOwner or null, distanceBetweenInBlocks(vibrationBlock, listenerBlock))`. The distance passed is recomputed from the two block positions, not the stored `info.distance`.
4. `currentVibration = none`; return true.

---

## 4. Sculk sensor (`sculk_sensor`, id 34)

Block entity class `SculkSensorBlockEntity`. Valid blocks: `sculk_sensor`.

### 4.1 Persistence

| Key | Type | Default | Meaning |
|---|---|---|---|
| `last_vibration_frequency` | int | 0 | frequency of the last vibration the block activated for; never cleared on deactivation |
| `listener` | compound | fresh `Data` | the vibration data of section 3.4 |

Written in that order by `saveAdditional`. Update tag: empty; no update packet.

The block (`SculkSensorBlock.getTicker`) supplies a ticker on **server levels only**; the ticker calls `Ticker.tick(level, data, user)` every tick. The listener (radius 8, section 3.3) is registered by section 2.4.

### 4.2 The sensor's `User`

- Listener radius 8 (`LISTENER_RANGE`). Position source: the entity's block position.
- `canReceiveVibration(level, pos, event, context)`:
  1. if `pos` equals the sensor's own position and the event is `block_destroy` or `block_place`: false;
  2. if the event's frequency is 0: false;
  3. otherwise `SculkSensorBlock.canActivate(state)`: true only in phase `inactive`.
- `onReceiveVibration(...)`: when the block's current state can activate: `frequency = getGameEventFrequency(event)`; store it into `last_vibration_frequency`; `power = getRedstoneStrengthForDistance(distance, 8)`; call `SculkSensorBlock.activate(sourceEntity, level, pos, state, power, frequency)`.
- `onDataChanged()`: `setChanged()`. `requiresAdjacentChunksToBeTicking()`: true. `canTriggerAvoidVibration()`: true.

### 4.3 The block side that the block entity drives (`SculkSensorBlock`)

State properties: `sculk_sensor_phase` (`inactive`, `active`, `cooldown`; default `inactive`), `power` (0 to 15), `waterlogged`. Constants: `ACTIVE_TICKS = 30`, `COOLDOWN_TICKS = 10`.

`activate(entity, level, pos, state, power, frequency)`:
1. Set the block to phase `active` with the given `power` (`setBlockAndUpdate`).
2. Schedule a block tick after `getActiveTicks()` (30 for the sensor, 10 for the calibrated sensor).
3. `updateNeighbours`: update the neighbours of `pos` and of `pos.below()` with this block as source.
4. `tryResonateVibration(entity, level, pos, frequency)`: for each of the six directions: if the block there is in block tag `vibration_resonators`, post the game event `resonate_frequency` at that block position (context: the entity and that block's state), and play `SoundEvents.AMETHYST_BLOCK_RESONATE` (key `block.amethyst_block.resonate`, 46 section 14.3; blocks source, volume 1) with the pitch `RESONANCE_PITCH_BEND[frequency]`.
5. Post the game event `sculk_sensor_tendrils_clicking` at `pos` with the entity as source (frequency 0, so sensors ignore it).
6. If not waterlogged: play `SoundEvents.SCULK_CLICKING` at the block centre, blocks source, volume 1, pitch `random.nextFloat() * 0.2 + 0.8` (the level's random).

`RESONANCE_PITCH_BEND[i]` for `i = 0..15` is `2^((note[i] - 12) / 12)` as a float, with the note table `note = {0, 0, 2, 4, 6, 7, 9, 10, 12, 14, 15, 18, 19, 21, 22, 24}` (the function is `NoteBlock.getPitchFromNote`). Index 0 is never used (frequencies reaching it are 1 to 15).

Block tick (`SculkSensorBlock.tick`): phase `active`: `deactivate`; phase `cooldown`: set phase `inactive` (`setBlockAndUpdate`) and, when not waterlogged, play `SoundEvents.SCULK_CLICKING_STOP` at the block position, blocks source, volume 1, pitch `random.nextFloat() * 0.2 + 0.8`; phase `inactive`: nothing. `deactivate(level, pos, state)`: set phase `cooldown` and `power` 0, schedule a tick after 10, `updateNeighbours`.

Other block members read: `onPlace` (server): when the state is new (the old block was not this block) and its `power > 0` and no block tick is scheduled at the position, reset `power` to 0 with flags 18; `affectNeighborsAfterRemoval`: `updateNeighbours` when the phase was `active`. Redstone: the block is a signal source, `getDirectSignal` is the power only toward `UP`, comparator output (`hasAnalogOutputSignal`) is `last_vibration_frequency` of the block entity while the phase is `active`, else 0.

### 4.4 Stepping on the sensor

`SculkSensorBlock.stepOn(level, pos, state, entity)` on a server level: when `canActivate(state)` and the entity is not a `warden` and a `SculkSensorBlockEntity` exists at `pos`: if the user's `canReceiveVibration(level, pos, step, Context.of(state))` holds, call `listener.forceScheduleVibration(level, step, Context.of(entity), entity.position())`. This bypasses the `vibrations` tag, sneaking, occlusion and the in-flight check, but the candidate still goes through the selector and the ticker.

---

## 5. Calibrated sculk sensor (`calibrated_sculk_sensor`, id 35)

Block entity class `CalibratedSculkSensorBlockEntity extends SculkSensorBlockEntity`; same persistence and keys (section 4.1); same ticker shape (the calibrated block supplies it with its own type `calibrated_sculk_sensor`). Valid blocks: `calibrated_sculk_sensor`.

Differences, all in its `User` and block:
- Listener radius **16**.
- `canReceiveVibration`: `back = level.getSignal(pos.relative(facing.opposite), facing.opposite)` where `facing` is the block's `facing` (horizontal). When `back != 0` and the event's frequency is **not equal** to `back`: false. Otherwise the sensor rule of section 4.2.
- `getActiveTicks()` is 10 (`CalibratedSculkSensorBlock`).
- Redstone output: `getSignal(state, level, pos, direction)` is 0 when `direction` equals the block's `facing`, else the sensor's power.

Worked values: radius 16 gives `15 / 16 = 0.9375` per block: distance 0 is power 15; distance 4 is `15 - floor(3.75) = 12`; distance 16 is `max(1, 15 - 15) = 1`.

---

## 6. Sculk shrieker (`sculk_shrieker`, id 37), block-entity side

The shrieker's behaviour (`tryShriek`, `tryToWarn`, `canRespond`, `tryRespond`, the warden spawn, the reply sound, the player's `WardenSpawnTracker`) is specified in 44-x2 section 2 and is not repeated. This part adds only what 44-x2 did not need.

| Item | Value |
|---|---|
| Valid blocks | `sculk_shrieker` |
| Persisted keys (order of writing) | `warning_level` (int, default 0), `listener` (the vibration data, section 3.4) |
| Update tag / packet | empty / none |
| Ticker | server levels only: `Ticker.tick` every tick (`SculkShriekerBlock.getTicker`) |
| `User` | listener radius 8; listenable events: tag `shrieker_can_listen`; `canReceiveVibration` is true only when the block is **not** `shrieking` and the event's source entity resolves (through `tryGetPlayer`, 44-x2 2.3) to a player; `onReceiveVibration` calls `tryShriek` with the player resolved from the **projectile owner when one is given, else the source entity**; `onDataChanged` is `setChanged`; `requiresAdjacentChunksToBeTicking` true; `canTriggerAvoidVibration` false (default) |
| `isValidVibration` | the generic rule of section 3.3, so a sneaking player is ignored when the event is in `ignore_vibrations_sneaking`, but no avoid-vibration criterion fires for the shrieker |
| `preRemoveSideEffects` | when the removed state is `shrieking` and the level is a server level: `tryRespond` once (44-x2 2.3) |
| Constants | `WARNING_SOUND_RADIUS` 10 and the reply-sound offsets are as in 44-x2; the `shriek` game event has notification radius 32 (section 2.1) |

---

## 7. Sculk catalyst (`sculk_catalyst`, id 36)

Block entity class `SculkCatalystBlockEntity`. Valid blocks: `sculk_catalyst`. The entity owns one `CatalystListener`, which owns one **live** `SculkSpreader` (`createLevelSpreader`).

### 7.1 Persistence

`saveAdditional` calls the spreader's `save` **before** the base class; `loadAdditional` calls the base class then the spreader's `load`.

| Key | Type | Rule |
|---|---|---|
| `cursors` | list of cursor compounds | always written (an empty list when there are none); on load the spreader's cursor list is first cleared, then the list is read with a size limit of 32 entries (a longer or malformed list reads as empty) and each entry is added through `addCursor`, which refuses a 33rd |

Cursor compound:

| Key | Type | Default | Range |
|---|---|---|---|
| `pos` | block position | required | the block-position codec (an int triple, inferred) |
| `charge` | int | 0 | 0 to 1000 |
| `decay_delay` | int | 1 | 0 to 1 |
| `update_delay` | int | 0 | 0 to the maximum int |
| `facings` | list of direction names | absent (null) | optional, lenient; a set, so duplicates collapse |

A debug flag in `SculkSpreader.save` can add statistics keys; it is false in the shipped game and is not specified.

The update tag is empty; there is no update packet.

### 7.2 The listener

Listener radius 8, delivery mode `BY_DISTANCE` (section 2.2, so catalysts receive an event after all immediate listeners, nearest first), position source: the block position. The constant `PULSE_TICKS = 8`.

`handleGameEvent(level, event, context, eventPosition)`:
1. If the event is not `entity_die`, or the context's source entity is not a `LivingEntity`: return false.
2. `entity` = that living entity. If `entity.wasExperienceConsumed()` is already true, skip to step 6.
3. `source` = the entity's last damage source; `reward = entity.getExperienceReward(level, killer)` where `killer` is that source's entity (or none).
4. If `entity.shouldDropExperience()` and `reward > 0`: `spreader.addCursors(BlockPos.containing(eventPosition moved 0.5 up), reward)` (section 7.3), and `tryAwardItSpreadsAdvancement` (below).
5. `entity.skipDropExperience()` (this happens **whenever** step 2 did not skip, even when the reward was 0 or the entity does not drop experience). Then `bloom` at the listener's position source block (section 7.4).
6. Return true.

`tryAwardItSpreadsAdvancement(level, entity)`: when `entity.getLastHurtByMob()` is a `ServerPlayer`, fire the criterion `kill_mob_near_sculk_catalyst` for that player with the entity and the entity's last damage source (a `playerAttack` damage source for that player when the entity has none).

Ordering that makes this work (read in `LivingEntity.die`): when the dying entity's killer (if any) accepts the kill, the game event `entity_die` is posted at the entity **before** `dropAllDeathLoot`; `dropExperience` checks `wasExperienceConsumed()` and `shouldDropExperience()`, so a catalyst that handled the event prevents the experience orbs.

`SculkCatalystBlockEntity.serverTick(level, pos, state, entity)` (supplied only on server levels by `SculkCatalystBlock.getTicker`): `spreader.updateCursors(level, pos, level.getRandom(), true)`, every tick, origin = the catalyst's position, spread flag always true.

### 7.3 Live `SculkSpreader` rules

The world-generation use is in 35-6 section 8 and the cursor update (`ChargeCursor.update`), the block behaviours and the vein spreader are read there and are the same code. This section lists what differs for the live spreader and what 35-6 left out.

Parameters of the live spreader: not world generation; replaceable tag `sculk_replaceable`; `growthSpawnCost` 10; `noGrowthRadius` 4; `chargeDecayRate` 10; `additionalDecayRate` 5. Constants: at most 32 cursors; `MAX_CHARGE` 1000; maximum cursor distance 1024 (Chebyshev, `distChessboard`).

- `addCursors(pos, amount)`: while `amount > 0`: `c = min(amount, 1000)`; add a cursor `(pos, c)` with `decayDelay` 1, `updateDelay` 0, `facings` null; `amount -= c`. A cursor is silently dropped when the list already holds 32. So a reward of 1500 makes cursors of 1000 and 500; a reward of 5 makes one cursor of charge 5.
- A cursor may update only when its charge is above 0 **and**, for the live spreader, the level is a `ServerLevel` and `shouldTickBlocksAt(cursor position)` holds (world generation updates unconditionally). Otherwise `update` returns without any effect, and the cursor stays in the list unchanged.
- Live differences inside `ChargeCursor.update` (35-6 section 8.4): after a successful vein spread (step 4) the sound `SoundEvents.SCULK_BLOCK_SPREAD` is played at the cursor position (blocks source, volume 1, pitch 1); in step 7, a cursor with **no** valid movement target is **not** killed (the world-generation branch that zeroes the charge does not run live); it keeps its position and charge and tries again at the next effective update.
- Live differences in `updateCursors` (the position-merge rule): process cursors in list order; for each cursor `c`: drop it when `c.pos` is farther than 1024 (Chebyshev) from the origin; update it; if its charge is now `<= 0`, send level event **3006** with data 0 at its position and drop it; otherwise add its charge to a per-position sum and look up the cursor already kept for that position: if none, keep `c` and remember it; if one exists and the sum of the two charges is `<= 1000`, merge into the existing cursor (`existing.charge += c.charge`, `c.charge = 0`, `existing.updateDelay = min(both)`) and drop `c`; otherwise keep `c` as a separate cursor, and when `c.charge < existing.charge` remember `c` as the cursor for that position in place of `existing`.
- After the pass, for each position with a summed charge `S > 0` whose remembered cursor has a non-null `facings`: send level event 3006 at the position with data `((int)(ln(1 + S) / 2.299999952316284) + 1) << 6` plus `MultifaceBlock.pack(facings)` (a byte); this event only drives client particles (42-6 section 6).
- Block placement sounds: `SculkBlock` growth plays the place sound of the placed state (`sculk_sensor` or `sculk_shrieker` sound type) at the **cursor's** position, blocks source, volume 1, pitch 1; `SculkVeinBlock.attemptPlaceSculk` plays `SoundEvents.SCULK_BLOCK_SPREAD` (blocks source, volume 1, pitch 1) at the position where the sculk block was placed (the slot is inferred from the local variable use).
- Live growth rule: a placed `sculk_shrieker` has `can_summon` false (the flag is `isWorldGeneration`). A live-grown shrieker therefore has `can_summon` false and never summons a warden (44-x2 section 2.3 gives the summoning rule that needs it true).

### 7.4 `bloom`

`bloom(level, pos, state, random)`, with `pos` the catalyst's block position:
1. Set the block state to the **construction-time** state of the listener (the state the block entity was created with, cached in the listener) with property `bloom` set true, `setBlockAndUpdate`. (The catalyst's only property is `bloom`, so this is the catalyst with `bloom = true`.)
2. Schedule a block tick after 8 ticks (`PULSE_TICKS`); `SculkCatalystBlock.tick` resets `bloom` to false when it is true.
3. `sendParticles(sculk_soul, x + 0.5, y + 1.15, z + 0.5, count 2, offset 0.2, 0, 0.2, speed 0)` (42-6 section 4.5, 42-7).
4. Play `SoundEvents.SCULK_CATALYST_BLOOM` (key `block.sculk_catalyst.bloom`) at `pos`, blocks source, volume 2.0, pitch `0.6 + random.nextFloat() * 0.4`, with the `random` passed in (the level's random source).

Block members read: the block drops experience (constant 5 when broken with experience allowed, 24-8); there is no other behaviour.

---

## 8. Copper golem statue (`copper_golem_statue`, id 47)

Block entity class `CopperGolemStatueBlockEntity`. Valid blocks: the eight `copper_golem_statue` blocks of the weathering collection (unaffected, exposed, weathered, oxidized and the four waxed ones; `WeatheringCopperCollection.asList` has 8 elements). Block rows: 24-8.

The block entity has **no fields of its own**. Its `saveAdditional` and `loadAdditional` are the base ones, so a statue stores only `components`, `id`, `x`, `y`, `z`. The only component it uses is `custom_name`.

| Operation | Behaviour |
|---|---|
| `createStatue(golem)` | builds a component map from the existing components and sets `custom_name` to the golem's custom name (absent name sets the component absent), stores it with `setComponents`, then `setChanged` |
| `removeStatue(state)` | creates a `copper_golem` entity with spawn reason `TRIGGERED` in the entity's level; when creation succeeds it sets the golem's custom name from the `custom_name` component and then positions it (below); returns null when creation fails |
| golem placement | position `(x centre of the block, block y, z centre of the block)`, yaw `facing.toYRot()`, pitch 0; head and body yaw set to that yaw; the golem plays its spawn sound |
| `getItem(stack, pose)` | applies `collectComponents()` to the stack, then sets the stack's `block_state` component to the pose (`copper_golem_pose` = the given pose) and returns the stack |
| `getUpdatePacket` | `ClientboundBlockEntityDataPacket.create(this)`, which carries `getUpdateTag`, which is **not** overridden, so the packet carries an empty tag (the custom name never reaches clients) |

Related block behaviour read, for the lifecycle:
- A copper golem becomes a statue in `CopperGolem.turnToStatue` (mob document 44): the block is set to the **oxidized** statue block with a random pose (`nextInt(0, 4)` over the four poses in order `standing`, `sitting`, `running`, `star`) and `facing = Direction.fromYRot(golem yaw)`; then `createStatue`, preserved equipment drops, the golem is discarded, `SoundEvents.COPPER_GOLEM_BECOME_STATUE` plays, and a leash is dropped (when the `entity_drops` rule is on) or removed.
- Using an item on a statue (`CopperGolemStatueBlock.useItemOn`): an axe passes; otherwise the pose advances (`updatePose`): play `SoundEvents.COPPER_GOLEM_BECOME_STATUE` (blocks source), set `copper_golem_pose` to the next pose (cycle `standing`, `sitting`, `running`, `star`, `standing`; ids past the last wrap to the first through `ByIdMap.continuous` with the ZERO strategy), post `block_change`. In the weathering subclass: an axe on an **unaffected** (unoxidised) statue with a block entity calls `removeStatue`, then damages the axe by 1 in the used hand's slot (this happens before the golem is checked), then, when a golem was created, adds it to the level and removes the block (`removeBlock(pos, false)`) and returns success; when no golem was created the result passes; an axe on a weathered or oxidised weathering statue passes, and an axe on a waxed statue (the base class, which has no removal) passes; honeycomb on a weathering statue passes; any other item advances the pose and succeeds.
- `shouldChangedStateKeepBlockEntity(state)` is true when the new state is in block tag `copper_golem_statues` (so weathering and waxing keep the entity and its name).
- Comparator output is `pose.ordinal + 1` (1 to 4).

---

## 9. Potent sulfur (`potent_sulfur`, id 48)

Block entity class `PotentSulfurBlockEntity`. Valid blocks: `potent_sulfur`. The block rows and the placement state rule `validBlockState` are in 24-8 (the rule calls `resetCountdown()` when the new state is neither `erupting` nor `dormant`); the client particle tickers are in 42-6 section 4.6 and 42-3 section 9.8. This section closes the open item of 24-8: the full server behaviour.

### 9.1 Fields and persistence

| Field | Type | Initial | Persisted |
|---|---|---|---|
| `waitingCountdown` | int | -1 | key `countdown` (int); on load only set when the key is present |
| `eruptionTick` | long | -1 | no |

`setLevel(level)`: after the base call, when `eruptionTick` is -1 it becomes the level's current game time (so a loaded entity starts its plume clock at load). `resetCountdown()` sets `waitingCountdown = -1`. The update tag is empty and there is no update packet. The entity sets `eruptionTick = gameTime` from the block event of section 9.2.

### 9.2 Block hooks

- `onPlace(state, level, pos, oldState, moved)`: base call, then **only when the new state is `erupting` or `continuous`**: queue a block event `(pos, block, 0, 0)` (it runs through the block-event queue of 29 section 6: the event is broadcast to nearby clients and run on the server), play `SoundEvents.GEYSER_CONTINUOUS_START` (state `continuous`) or `SoundEvents.GEYSER_ERUPTION_START` (`erupting`) at `pos` (blocks source, volume 1, pitch 1), and post `block_activate` at `pos` with the new state as context. Since `onPlace` also runs for a state change of the same block (29 section 2.1 step 11), the countdown toggle of section 9.5 into `erupting` triggers all three.
- `triggerEvent(state, level, pos, id, param)`: when a `PotentSulfurBlockEntity` exists at `pos`, set its `eruptionTick = level.getGameTime()` (on the server and, from the broadcast block event, on the client); always return true.
- `getTicker(level, state, type)`: the table of section 9.3.

### 9.3 Ticker set by state and side

The block's `STATE` ordinals are `dry` 0, `wet` 1, `dormant` 2, `erupting` 3, `continuous` 4. `A.andThen(B)` runs A then B on every tick.

| State | Client ticker | Server ticker |
|---|---|---|
| `dry` | none | none |
| `wet` | noxious-gas particles (42-6) | nausea effect (9.4) |
| `dormant` | noxious-gas particles | waiting countdown (9.5), then nausea effect |
| `erupting` | geyser plume with sound `SoundEvents.GEYSER_ERUPTION_ACTIVE`, then launch entity (9.6) | launch entity, then waiting countdown |
| `continuous` | geyser plume with sound `SoundEvents.GEYSER_CONTINUOUS_ACTIVE`, then launch entity | launch entity |

(The launch-entity ticker therefore also runs on the client, which moves client-simulated entities; the nausea, countdown and effect logic runs on the server only.)

### 9.4 Shared helpers

- `findNoxiousGasSourceBlock(level, P)` (`P` the sulfur block position): scan cells `P + 1`, `P + 2`, ... while `y <= P.y + 5`. For each cell: when its fluid is a **source of water** (`FluidState.isSourceOfType(WATER)`) and its block is the water block or is geyser-passable, move up and continue; otherwise (not a water source, or a water-source cell holding some other non-passable block) the cell is the result when it is air or geyser-passable, else the scan ends with none. Running past `P.y + 5` gives none. Geyser-passable: air, the water block, or a state with an empty collision shape for a position-context at that cell's level (`CollisionContext.positionContext`). `ALLOWED_WATER_BLOCKS_ABOVE = 4` in the block corresponds to a source cell at most at `P.y + 5`.
- Column height `h = source.y - P.y - 1`: the number of water cells below the source cell (1 to 4 when a source is found).
- `getUnobstructedBlockCount(level, start, h)`: `limit = 6 * h`; walk `i = 0 .. limit - 1` over `start.above(i)`; return the first `i` whose state is **not** geyser-passable, else `limit`.
- Applying nausea: `addEffect(MobEffectInstance(nausea, 80 ticks, amplifier 0, ambient true, visible true))`.
- `EFFECT_PREDICATE`: not a spectator and still alive.
- `geyserPositional(level, P)`: `new XoroshiroRandomSource(levelSeed xor GEYSER_SALT).forkPositional().at(P)` with `GEYSER_SALT = -904011478` (a signed 64-bit constant; `levelSeed xor GEYSER_SALT` is a 64-bit exclusive or); seeding, `forkPositional` and `at` are 10 sections 2.2 to 2.4. `levelSeed` is `ServerLevel.getSeed()`.

### 9.5 Server tickers

**Nausea effect** (every 10 ticks, `gameTime % 10 == 0`):
1. `source = findNoxiousGasSourceBlock(P)`; none: stop.
2. For each living entity (predicate section 9.4) in the box of the **source** cell inflated by 2.5 in x, 0 in y and 2.5 in z (the box of the single cell, so full-cell height 1 and 6 wide): if `canBeReachedByNoxiousGas(level, source, eyePosition)`, apply nausea.

`canBeReachedByNoxiousGas(level, source, eye)`: false unless the eye block (`BlockPos.containing(eye)`) is geyser-passable (position context at the eye block's `below()` y); false when `eye.distanceToSqr(centre of source) > 9.0` (range 3.0, `EFFECT_RANGE`); then `from = centre of source.below()` and `to = eye` with y lowered by 1; true when `to` lies in a water **source** cell and a collider ray (`ClipContext.Block.COLLIDER`, fluid none, empty context) from `from` to `to` does not hit a block.

**Waiting countdown** (every 20 ticks, `gameTime % 20 == 0`):
1. `source = findNoxiousGasSourceBlock(P)`; none: stop.
2. If `waitingCountdown <= 0`: `h` as above; `rng = geyserPositional(level, P)`. If the state is `dormant`: `waitingCountdown = 10 * (h - 1) + rng.nextIntBetweenInclusive(15, 30)`. Otherwise (the `erupting` state): draw and discard one `rng.nextInt()` (the full 32-bit draw), then `waitingCountdown = (h - 1) + rng.nextIntBetweenInclusive(1, 2)`.
3. If `waitingCountdown > 0`: decrement it by 1.
4. If `waitingCountdown == 0`: the new state is `erupting` when the current state is `dormant`, else `dormant`; `setBlockAndUpdate(P, state with STATE = new)`; when the new state is `dormant`, post `block_deactivate` at `P` with the **previous** state as context.

The unit of the countdown is therefore 20 ticks. The dormant wait is `10(h-1) + [15, 30]` units; the eruption is `(h-1) + [1, 2]` units. The countdown stays 0 after a toggle and is recomputed on the next 20-tick pass. Because `rng` is created fresh for each pass at the same position, the sequence of values for one block depends only on the level seed and `P`.

### 9.6 Launch entity ticker (both sides, every tick)

1. `source = findNoxiousGasSourceBlock(P)`; none: stop.
2. `h = source.y - P.y - 1`; `n = getUnobstructedBlockCount(level, P.above(), h)`.
3. The box is the cell `P.above()` expanded toward +y by `n - 1` (`AABB(P.above()).expandTowards(0, n - 1, 0)`). Collect `Entity` instances in it that satisfy `EFFECT_PREDICATE`.
4. For each: `velocity = deltaMovement` (read before the next call); `checkFallDistanceAccumulation()` (when `deltaMovement.y > -0.5` and `fallDistance > 1` set `fallDistance = 1`); skip when `!canSimulateMovement()`, when the entity is a player whose abilities are flying, when it is a passenger, or when its type is in tag `not_affected_by_geysers`. Otherwise, when `velocity.y < 0.30000001192092896 + h * 0.1`, add `(0, 0.20000000298023224, 0)` to its delta movement.

(`GEYSER_BASE_LAUNCH_SPEED` 0.3f and `GEYSER_LAUNCH_FORCE` 0.2f are the float constants of the two doubles above; `EFFECT_APPLICATION_FREQUENCY_TICKS` 10, `PARTICLE_FREQUENCY_TICKS` 20 and `SOUND_FREQUENCY_TICKS` 40 are the periods used by these tickers and by the client plume.)

### 9.7 Client tickers (reference only)

Noxious-gas particles and the geyser plume (period 20 for the particle, 40 for the sound, relative to `eruptionTick`) are specified in 42-6 section 4.6. They are not part of the server state machine.

---

## 10. Test-only block entities

Both types belong to the game-master test tooling (`GameMasterBlock`s that only a player allowed to use game-master blocks can open). A standard-content server need not implement their screens; the persistence is specified so that worlds containing them load.

### 10.1 `test_block` (id 45): `TestBlockEntity`

Valid blocks: `test_block`. Mode enum `TestBlockMode`: `start` (id 0), `log` (1), `fail` (2), `accept` (3).

| Key | Type | Default |
|---|---|---|
| `mode` | `TestBlockMode` (string name) | `fail` when the key is unreadable; a new entity takes the mode of the block state's `mode` property |
| `message` | string | empty |
| `powered` | boolean | false |

(`triggered` is a runtime flag, not persisted.) The update tag is `saveCustomOnly` (the three keys), and `getUpdatePacket` is the standard packet carrying it. `setMode(m)` stores the mode and, when the block at the position is a `test_block`, rewrites its `mode` property (`setBlock` flags 2). `reset()` clears `triggered`; in mode `start` it also sets `powered` false and updates the neighbours. `trigger()`: in mode `start` with a level, set `powered` true, update the neighbours, then `log()`; in mode `log`, `log()`; then set `triggered` true. `log()` writes an informational line `Test <mode> (at <pos>): <message>` when the message is not blank.
Block behaviour read: neighbour change (not in mode `start`) turns a rising redstone signal into `powered = true` plus `trigger()` and a falling one into `powered = false`; a scheduled tick calls `reset()`; in mode `start` the block outputs power 15 while powered, else 0; use opens the screen for a player allowed to use game-master blocks; the clone item and placement carry the mode in the `block_state` component.

### 10.2 `test_instance_block` (id 46): `TestInstanceBlockEntity`

Valid blocks: `test_instance_block`. The entity renders a bounding box and a beacon-style beam (both are client concerns).

| Key | Type | Notes |
|---|---|---|
| `data` | compound | required for loading the data; see below |
| `errors` | list of error markers | each marker: `pos` (block position) and `text` (a text component); cleared and re-read on load |

`data` compound: `test` (optional resource key of a game test instance), `size` (a `Vec3i`), `rotation` (a `Rotation`), `ignore_entities` (boolean), `status` (`cleared`, `running` or `finished`), `error_message` (optional text component). A new entity holds: no test, size (0, 0, 0), rotation none, `ignore_entities` false, status `cleared`, no message. `setChanged` also sends a block update (`sendBlockUpdated`, flags 3) on server levels. The update tag is `saveCustomOnly`; the update packet is the standard one. The structure region starts at the block position plus the fixed offset `(0, 1, 1)`. The test framework behaviour (reset, save, export, beam colours, error markers) was not read in this round (Open question 8).

---

## 11. Registry sweep: all 49 types

The registry `block_entity_type` is filled by `BlockEntityTypes` in the order of the table; the id is the position (46 section 5.4 is the id table). `BlockEntityTypes` is the only class that constructs a `BlockEntityType` (checked by a search of every class of `net/minecraft` for the supplier type). The registry-visible data of a type is the key, the factory and the valid-block set; nothing else is registered (no extra codecs or ticking data).

Reading the columns. **Blocks** is the number of block entries of the valid-block set (a "collection" counts its members). **Direct keys** are the literal NBT keys read from the class's own `saveAdditional`, `loadAdditional` and related methods in this round; "inherit" means the class has none and uses its superclass; "helper" means the persistence is delegated to a helper whose keys are not literal in the class (items, loot table, lock and name keys of containers, and so on). **Update** lists which of `getUpdateTag` (T) and `getUpdatePacket` (P) the class overrides. **Family** is the grouping used to assign ownership (inferred from the class); **Coverage** names the document that specifies the type, taken from the scope lines of the sibling files that existed when this part was finished (31-1, 31-2, 31-3, 31-4 and 31-7; the files for parts 5 and 6 did not exist yet, Open question 2).

| Id | Key | Class (extends) | Blocks | Direct keys | Update | Family | Coverage |
|---|---|---|---|---|---|---|---|
| 0 | `furnace` | `FurnaceBlockEntity` (abstract furnace) | 1 | inherit | none | cooking | 31-2 |
| 1 | `chest` | `ChestBlockEntity` (randomizable container, lid) | 9: `chest` plus the eight copper chests | helper | none | container | 31-1 |
| 2 | `trapped_chest` | `TrappedChestBlockEntity` (chest) | 1 | inherit | none | container | 31-1 |
| 3 | `ender_chest` | `EnderChestBlockEntity` | 1 | none | none | container | 31-1 |
| 4 | `jukebox` | `JukeboxBlockEntity` | 1 | `RecordItem`, `ticks_since_song_started` | none | item holder | 31-4 |
| 5 | `dispenser` | `DispenserBlockEntity` (randomizable container) | 1 | helper | none | container | 31-2 (engine also 44-x2 section 3) |
| 6 | `dropper` | `DropperBlockEntity` (dispenser) | 1 | inherit | none | container | 31-2 |
| 7 | `sign` | `SignBlockEntity` | 26 (13 wood types, standing and wall) | `allow_op_features`, `front_text`, `back_text`, `is_waxed` | T, P | display | 31-3 |
| 8 | `hanging_sign` | `HangingSignBlockEntity` (sign) | 26 (13 wood types, ceiling and wall) | inherit | T, P (inherited) | display | 31-3 |
| 9 | `mob_spawner` | `SpawnerBlockEntity` | 1 | helper (spawner data) | T (`SpawnPotentials` kept), P | spawner | 31-7 |
| 10 | `creaking_heart` | `CreakingHeartBlockEntity` | 1 | `creaking` | T, P | mob link | 31-5 or 31-6 (file absent), mob side 44-5 |
| 11 | `piston` | `PistonMovingBlockEntity` (valid block `moving_piston`) | 1 | `blockState`, `facing`, `progress`, `extending`, `source` | T (`saveCustomOnly`; no packet override, closing the item left open in 31-1 section 5.2) | piston | 31-5 or 31-6 (file absent) |
| 12 | `brewing_stand` | `BrewingStandBlockEntity` | 1 | `BrewTime`, `total_brew_time`, `Fuel`, `total_fuel`, `speed_multiplier` | none | cooking | 31-2 |
| 13 | `enchanting_table` | `EnchantingTableBlockEntity` | 1 | `CustomName` | none | named | 31-4 |
| 14 | `end_portal` | `TheEndPortalBlockEntity` | 1 | none | none | portal | 31-5 or 31-6 (file absent) |
| 15 | `beacon` | `BeaconBlockEntity` | 1 | `primary_effect`, `secondary_effect`, `Levels` (written only), `CustomName` | T, P | effects | 31-5 or 31-6 (file absent; 31-3 names part 5 for the beam owner) |
| 16 | `skull` | `SkullBlockEntity` | 14 (seven head kinds, floor and wall) | `profile`, `note_block_sound`, `custom_name` | T, P | display | 31-3 |
| 17 | `daylight_detector` | `DaylightDetectorBlockEntity` | 1 | none | none | redstone | 31-2 |
| 18 | `hopper` | `HopperBlockEntity` | 1 | `TransferCooldown` plus helper | none | container | 31-2 |
| 19 | `comparator` | `ComparatorBlockEntity` | 1 | `OutputSignal` | none | redstone | 31-2 |
| 20 | `banner` | `BannerBlockEntity` | 32 (the 16 banners and 16 wall banners) | `patterns`, `CustomName` | T, P | display | 31-3 |
| 21 | `structure_block` | `StructureBlockEntity` | 1 | `name`, `author`, `metadata`, `posX`, `posY`, `posZ`, `sizeX`, `sizeY`, `sizeZ`, `rotation`, `mirror`, `mode`, `ignoreEntities`, `strict`, `powered`, `showair`, `showboundingbox`, `integrity`, `seed` | T, P | builder | 31-5 or 31-6 (file absent) |
| 22 | `end_gateway` | `TheEndGatewayBlockEntity` (end portal) | 1 | `Age`, `exit_portal`, `ExactTeleport` | T, P | portal | 31-5 or 31-6 (file absent) |
| 23 | `command_block` | `CommandBlockEntity` | 3 (normal, chain, repeating) | `powered`, `conditionMet`, `auto` plus helper (command logic) | none | command | 31-5 or 31-6 (file absent) |
| 24 | `shulker_box` | `ShulkerBoxBlockEntity` | 17 (undyed plus 16 dyed) | helper | none | container | 31-1 |
| 25 | `conduit` | `ConduitBlockEntity` | 1 | `Target` | T, P | effects | 31-5 or 31-6 (file absent) |
| 26 | `barrel` | `BarrelBlockEntity` | 1 | helper | none | container | 31-1 |
| 27 | `smoker` | `SmokerBlockEntity` (abstract furnace) | 1 | inherit | none | cooking | 31-2 |
| 28 | `blast_furnace` | `BlastFurnaceBlockEntity` (abstract furnace) | 1 | inherit | none | cooking | 31-2 |
| 29 | `lectern` | `LecternBlockEntity` | 1 | `Book`, `Page` | none | item holder | 31-4 |
| 30 | `bell` | `BellBlockEntity` | 1 | none | none | ticking | 31-4 |
| 31 | `jigsaw` | `JigsawBlockEntity` | 1 | `name`, `target`, `pool`, `final_state`, `joint`, `placement_priority`, `selection_priority` | T, P | builder | 31-5 or 31-6 (file absent) |
| 32 | `campfire` | `CampfireBlockEntity` | 2 (campfire, soul campfire) | `CookingTimes`, `CookingTotalTimes` plus items | T, P | cooking | 31-4 |
| 33 | `beehive` | `BeehiveBlockEntity` | 2 (bee nest, beehive) | `bees`, `flower_pos` | none | mob holder | 31-4 |
| 34 | `sculk_sensor` | `SculkSensorBlockEntity` | 1 | `last_vibration_frequency`, `listener` | none | sculk | **this part, sections 3 to 4** |
| 35 | `calibrated_sculk_sensor` | `CalibratedSculkSensorBlockEntity` | 1 | inherit | none | sculk | **this part, section 5** |
| 36 | `sculk_catalyst` | `SculkCatalystBlockEntity` | 1 | `cursors` (through the spreader) | none | sculk | **this part, section 7** |
| 37 | `sculk_shrieker` | `SculkShriekerBlockEntity` | 1 | `warning_level`, `listener` | none | sculk | **this part, section 6**, behaviour 44-x2 section 2 |
| 38 | `chiseled_bookshelf` | `ChiseledBookShelfBlockEntity` | 1 | `last_interacted_slot` plus items | none | item holder | 31-2 |
| 39 | `shelf` | `ShelfBlockEntity` | 13 (one per wood type) | `align_items_to_bottom` plus items | T (`align_items_to_bottom`), P | item holder | 31-3 |
| 40 | `brushable_block` | `BrushableBlockEntity` | 2 (suspicious sand, suspicious gravel) | `item` (save and load), `hit_direction` (literal in load and in the update tag) | T (`hit_direction`, `item`), P | archaeology | 31-4 |
| 41 | `decorated_pot` | `DecoratedPotBlockEntity` | 1 | `sherds`, `item` | T, P | item holder | 31-3 |
| 42 | `crafter` | `CrafterBlockEntity` | 1 | `crafting_ticks_remaining` (save and load), `disabled_slots` and `triggered` (literal in load only; the save side goes through a helper) plus items | none | container | 31-2 |
| 43 | `trial_spawner` | `TrialSpawnerBlockEntity` | 1 | helper (trial spawner state) | T, P | spawner | 31-7 |
| 44 | `vault` | `VaultBlockEntity` | 1 | `config`, `shared_data`, `server_data` | T, P | loot | 31-7 |
| 45 | `test_block` | `TestBlockEntity` | 1 | `mode`, `message`, `powered` | T (`saveCustomOnly`), P | test-only | **this part, section 10.1** |
| 46 | `test_instance_block` | `TestInstanceBlockEntity` | 1 | `data`, `errors` | T (`saveCustomOnly`), P | test-only | **this part, section 10.2** |
| 47 | `copper_golem_statue` | `CopperGolemStatueBlockEntity` | 8 | none (components only) | P (empty tag) | statue | **this part, section 8** |
| 48 | `potent_sulfur` | `PotentSulfurBlockEntity` | 1 | `countdown` | none | effects | **this part, section 9** |

Notes on the sweep:
- **Copper chests.** They are **not** a separate type. `chest` (id 1) has nine valid blocks: the eight members of `Blocks.COPPER_CHEST` (a `WeatheringCopperCollection` of 8) plus `chest`. There is no `copper_chest` block entity key, and no copper-specific class: the copper chests use `ChestBlockEntity`. (The block rows are 24-8.)
- **Sign and banner counts** are the registry-visible block-set sizes read from `BlockEntityTypes`; the block keys themselves are block-registry data (24).
- **Types with no persistence of their own** in this table (`ender_chest`, `end_portal`, `daylight_detector`, `bell`, `copper_golem_statue`): their compound holds only the base keys of section 1.
- **Unused or test-only types.** Types 45 and 46 are test-only (section 10). No type in the registry is unused by a block: every one of the 49 has at least one valid block, and the registry warning for an empty valid set therefore never fires.
- **Update overrides** (read from each class's own methods): 19 classes declare `getUpdateTag` (`sign`, `mob_spawner`, `creaking_heart`, `piston`, `beacon`, `skull`, `banner`, `structure_block`, `end_gateway`, `conduit`, `jigsaw`, `campfire`, `shelf`, `brushable_block`, `decorated_pot`, `trial_spawner`, `vault`, `test_block`, `test_instance_block`); 19 declare `getUpdatePacket` (the same list without `piston`, plus `copper_golem_statue`); `hanging_sign` inherits both from `sign`. Every other type sends an empty tag in a chunk packet and no block-entity-data packet.
- Entities that are listeners (`GameEventListener$Provider`): exactly the four of this part (`sculk_sensor`, `calibrated_sculk_sensor`, `sculk_catalyst`, `sculk_shrieker`).

---

## 12. Worked examples

1. **Sensor strength.** Sensor (radius 8, factor 1.875). Event 0 blocks away: `15 - floor(0) = 15`. 1: `15 - 1 = 14`. 2: `15 - floor(3.75) = 12`. 3: `15 - 5 = 10`. 4: `15 - 7 = 8`. 5 (an event at offset (3, 4, 0)): `15 - 9 = 6`. 6: `15 - 11 = 4`. 7: `15 - 13 = 2`. 8: `15 - 15 = 0`, raised to 1. Calibrated sensor (factor 0.9375): distance 10: `15 - floor(9.375) = 6`.
2. **A step five blocks away (timeline).** A player steps 5.0 blocks from a sensor centre at game time `T`; the sensor is `inactive`, nothing in flight. The `step` event (frequency 1) passes steps 1 to 5 of 3.5; the selector holds `(info, T)`. The sensor's ticker at time `T` (if it runs after the event in the same tick) finds `chosenCandidate(T)` empty because `T < T` is false. At `T + 1`: the candidate is chosen, `currentVibration` set, `travelTimeInTicks = floor(5.0) = 5`, a `vibration` particle is sent, then the same call continues: travel 5 > 0, decrement to 4. At `T + 2`: 3; `T + 3`: 2; `T + 4`: 1; `T + 5`: 0, so `receiveVibration` runs: the sensor's `canReceiveVibration` is **not** re-checked at delivery, `onReceiveVibration` activates the block with power `15 - floor(1.875 * 5) = 6`, `last_vibration_frequency = 1`; the block schedules its tick for `T + 35` (30 active ticks), then cooldown for 10, so it can activate again at about `T + 45`. If the ticker runs before the event in tick `T`, nothing changes: the candidate is still chosen at `T + 1`.
3. **Selector ties.** In one tick candidate A (`step`, distance 3.0, frequency 1) is held. B (`entity_damage`, distance 3.0, frequency 7) arrives: same tick, equal distance, 7 > 1: B replaces A. C (`flap`, distance 2.5, frequency 1) arrives: closer: C replaces B. D (`explode`, distance 9.0, frequency 15) arrives: farther: rejected. E arrives in the next tick: rejected (different tick) and, if no vibration was selected yet, it also fails because the ticker will have selected C first at that tick.
4. **Calibrated filter.** A calibrated sensor faces north; redstone dust on the south side gives it signal 7. `entity_damage` (frequency 7) is accepted; `step` (frequency 1) is rejected at step 4 of 3.5. With no signal behind it (0), any event with a non-zero frequency is accepted.
5. **Persisted vibration.** A sensor saved with a vibration 3 ticks from arrival stores `listener: {event: {game_event: "minecraft:step", distance: 5.0f, pos: [x, y, z], source: [i, i, i, i]}, selector: {tick: -1L}, event_delay: 3}` plus `last_vibration_frequency: 1`. After a load, `reloadVibrationParticle` is true, so at the next tick the particle is re-sent at `lerp(1 - 3/5, pos, listenerCentre)` = 40 percent of the way, and the travel then continues 2, 1, 0 at the following ticks.
6. **Catalyst reward.** A creature worth 5 experience dies 6 blocks from a catalyst at 10:00 game time; the catalyst is the only listener within range. `entity_die` is posted before the loot; the catalyst's `handleGameEvent` adds one cursor `(containing(deathPos + 0.5 up), charge 5)`, marks the experience consumed (no orbs), and blooms: `bloom = true`, block tick scheduled for 10:08, two `sculk_soul` particles above the block, `sculk_catalyst_bloom` at volume 2 with pitch between 0.6 and 1.0. The next catalyst tick runs `updateCursors` with the live parameters; with a charge of 5 on a non-sculk cell the cursor moves to an adjacent sculk or vein cell if there is one, else it waits (live) and is dropped only after its charge reaches 0 (`decayDelay` 1 gives it one more effective update, then the default behaviour sets the charge to 0).
7. **Potent sulfur schedule.** A `dormant` sulfur block with a water column of `h = 3` (sulfur at y 60, water at 61, 62, 63, air at 64): `findNoxiousGasSourceBlock` returns y 64 (`h = 64 - 60 - 1 = 3`). On the first pass with `gameTime % 20 == 0` after the entity is created (countdown -1) the stored countdown becomes `10 * 2 + r`, with `r` in 15 to 30 from the positional random: 35 to 50, then is decremented to 34 to 49. After that many further passes (34 to 49 passes of 20 ticks, i.e. 680 to 980 ticks) the countdown reaches 0 and the block becomes `erupting` (`onPlace` queues the block event, plays `geyser_eruption_start`, posts `block_activate`). The next pass recomputes: `erupting`: discard one `nextInt()`, countdown `2 + [1, 2]` = 3 or 4, decremented to 2 or 3; after 2 or 3 further passes (40 to 60 ticks) the block becomes `dormant` and posts `block_deactivate`. While `erupting` an entity with `velocity.y < 0.3 + 3 * 0.1 = 0.6` standing in the unobstructed part of the column (up to `6 * 3 = 18` cells, box of height `n`) gains +0.2 in y each tick.
8. **Statue lifecycle.** A named copper golem oxidises and turns into an oxidised statue with pose `running` facing south: block `oxidized_copper_golem_statue[copper_golem_pose=running, facing=south]`; the entity stores `components: {custom_name: ...}` only. A player using a stick on it: pose becomes `star`; again: `standing` (the id after `star` wraps). Comparator output follows `pose.ordinal + 1`: `running` 3, `star` 4, `standing` 1. An axe on an **unaffected** statue creates a golem with the stored name facing the statue's yaw and removes the block; an axe on a weathered or oxidised statue (not unaffected) leaves the block alone (the result passes).

---

## 13. Validation

A conforming implementation satisfies these checks.

1. **Registry.** `block_entity_type` has 49 entries in the order of section 11; the ids match 46 section 5.4; `chest` accepts nine blocks, `sign` 26, `skull` 14, `banner` 32, `shulker_box` 17, `command_block` 3, `copper_golem_statue` 8; no `copper_chest` type exists.
2. **Frequencies.** `getGameEventFrequency` returns the table of 3.1 for all 61 events: 56 non-zero (41 explicit, 15 resonate) and 5 zero; `resonate_n` returns `n`.
3. **Strength.** `max(1, 15 - floor((15.0 / r) * d))`: for `r = 8`, the values 15, 14, 12, 10, 8, 6, 4, 2, 1 for `d` = 0 to 8; for `r = 16` and `d` = 0, 4, 16: 15, 12, 1.
4. **Delivery.** A listener in a section outside the event's notification-radius box receives nothing; a listener inside the box but farther than its own radius receives nothing; `BY_DISTANCE` listeners run after all `UNSPECIFIED` ones, nearest first.
5. **Selector.** Replacement only in the same tick; closer wins; equal distance resolves to the strictly higher frequency; `chosenCandidate(now)` needs `tick < now`.
6. **Ticker.** A vibration chosen at time `S` with distance `d >= 1` is delivered at `S + floor(d) - 1`; with `d < 1` at `S`; while it is in flight no new event is accepted (`handleGameEvent` returns false); if the 3 by 3 chunk area is not ticking, delivery is retried every tick and the travel time stays 0.
7. **Persistence round trip.** The sensor's compound has the keys `last_vibration_frequency` and `listener`; the listener compound has `selector` (with `tick`) always, `event_delay` always, `event` only when a vibration is in flight; a missing `selector` yields a fresh `Data`; `tick` is -1 when no candidate exists.
8. **Sensor phases.** `inactive` receives; `active` lasts 30 ticks (10 calibrated), then `cooldown` 10 ticks, then `inactive`; the comparator reads `last_vibration_frequency` only while `active`; stepping on a sensor skips occlusion and the tag check; a warden stepping does nothing.
9. **Shrieker.** `warning_level` and `listener` round trip; `canReceiveVibration` is false while `shrieking`; the player is resolved from the projectile owner first, then the source entity.
10. **Catalyst.** A reward of 0, or an entity that does not drop experience, still sets `skipDropExperience` and still blooms; `addCursors(p, 1500)` makes cursors of 1000 and 500 (cap 32); the cursor list round trips through `cursors` with `decay_delay` default 1; a live cursor with no movement target survives; two cursors on one position with a charge sum of at most 1000 merge.
11. **Statue.** Persistence holds only `components`; the update packet carries an empty tag; the pose cycle is standing, sitting, running, star, standing.
12. **Sulfur.** The countdown key is `countdown` and defaults to absent (-1); the nausea ticker applies an 80-tick, amplifier 0, ambient and visible nausea every 10 ticks to reachable living entities within the 2.5 box; the dormant wait is `10(h-1) + [15, 30]` and the eruption `(h-1) + [1, 2]` passes of 20 ticks, each pass seeded from the level seed xor `-904011478` and the block position.
13. **Test blocks.** `test_block` mode default `fail`; `test_instance_block` status default `cleared`; both send the saved keys as their update tag.

---

## Open questions

1. **Registry count of the brief.** The brief names 50 types; the artifact has 49 (section above and 11). If the brief counted something else (for example a type registered by a data pack at run time), that is not in the client jar.
2. **Reconciliation with parts 5 and 6.** When this part was finished, `docs/protocol/` held 31-1, 31-2, 31-3, 31-4 and 31-7 but not the files of parts 5 and 6. The table was reconciled against the scope lines of the five that exist (31-1 also lists the 49 types, and its counts and update-hook rows agree with section 11, with the one addition about `piston`); it names "31-5 or 31-6" for the nine types of the unwritten files (`creaking_heart`, `piston`, `end_portal`, `beacon`, `structure_block`, `end_gateway`, `command_block`, `conduit`, `jigsaw`). If those parts do not claim a type, it has no owner and must be added to this part.
3. **`components` encoding.** For a block entity with an empty component map (the statue before `createStatue`, every type without components), whether `DataComponentMap.CODEC` writes an empty compound or omits the key was not read (it is a codec detail). Section 1 states the key is always stored (inferred from the unconditional store call).
4. **`Level.isBlockInLine` semantics.** Section 3.6 reads the ray test as "the ray meets a block state matching the predicate"; the `ClipBlockStateContext` traversal class was not read (inferred from the name and from the use as a boolean "type == BLOCK" test).
5. **Codec shapes.** `Vec3` (three doubles), UUID (four ints) and block position (three ints) lengths are inferred from the codec composition; the exact length validation was not read.
6. **Level random source.** `SculkCatalystBlockEntity.serverTick` and `SculkBlock` draws use `Level.getRandom()` and the cursor `RandomSource` parameter; the concrete generator of a `ServerLevel` (its seeding and thread behaviour) belongs to 33 and was not re-read, so a bit-exact replay of live sculk growth needs that document.
7. **Client use of level event 3006.** The data layout (level and packed facings) is given from the server side; its consumer is 42-6 section 6 and was not re-read here.
8. **Test instance framework.** The reset, save, export, beam and error-marker logic of `TestInstanceBlockEntity` and the screens of both test blocks were not read; only the persistence is specified.
9. **Tag membership.** The tags listed in the scope note are data. Their contents (notably which game events are in `vibrations`, `ignore_vibrations_sneaking` and `shrieker_can_listen`, which blocks are in `dampens_vibrations`, `occludes_vibration_signals`, `vibration_resonators`) were not read in this round; they come from the data pack.
10. **Order of ticker and event within a tick.** The sensor timeline (worked example 2) states both orders; which order the level tick produces for a given emitter depends on 33 section 2 (block-entity tick versus entity tick order), not re-derived here.
11. **Experience reward and entity positions.** `getExperienceReward` per entity type and the position at which `entity_die` is posted (`Entity.gameEvent(Holder)`) are entity-document facts not re-read here.
12. **Sculk vein sound position.** The position of the `sculk_block_spread` sound in `attemptPlaceSculk` is inferred from a local-variable slot, not from a named accessor.
13. **`sculk_sensor` redstone neighbours.** `Level.getSignal` (used by the calibrated sensor's back signal) and the neighbour-update ordering of `updateNeighbours` belong to the redstone engine (30) and are cited, not re-specified.
