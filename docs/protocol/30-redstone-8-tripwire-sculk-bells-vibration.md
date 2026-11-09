# 30 (part 8). Redstone: tripwire, sculk sensors, sculk shrieker, bell, the vibration dispatch, and the catch-all inventory

| | |
|---|---|
| Covers | The redstone-facing behaviour of `TripWireBlock` and `TripWireHookBlock` (string line, `attached`, `powered`, `disarmed`, shears, the hook line search, entity detection, the 10-tick refresh, sounds and game events); `SculkSensorBlock`, `CalibratedSculkSensorBlock`, `SculkSensorPhase` and the sensor block entities (game-event frequency table, ranges, phases, cooldown, signal strength by distance, waterlogging, calibrated input side and frequency filter, comparator output, resonance); `SculkShriekerBlock` (redstone-facing parts only: `can_summon`, `shrieking`, vibration reaction); `BellBlock` and `BellBlockEntity` (attachment types, power ringing, hit-direction rule, resonance and raid detection); the game-event dispatch these blocks use; and the catch-all for the redstone-category blocks no other part owns (`TntBlock`, the redstone-facing part of `BigDripleafBlock`), ending with an inventory of every item and block in the redstone creative tab and the part that covers it. `SculkCatalystBlock` is excluded (31-8, 35). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS12 part 8 (GAP-10c of `../design/README.md` Part 5) |
| Data versus code | Block registry rows (ids, state layouts, shapes) are 24 and are not repeated beyond what a rule needs. Tags, loot tables, recipes, sounds and models are data and are not tabulated: the game-event tags `vibrations`, `shrieker_can_listen`, `ignore_vibrations_sneaking`, the block tags `dampens_vibrations` and the item tag `dampens_vibrations` (the latter read as the four wool tags `wool`, `wool_carpets`, `wool_slabs`, `wool_stairs`), `occludes_vibration_signals`, `vibration_resonators`, the entity-type tag `raiders`. This document specifies the code that interprets them and every code-defined constant. |
| Siblings | Parts of this family are cited as `30-N section M` (never a bare `N section M`, which would read as document 0N). 30-1 (signal model, queries, update order), 30-2 (repeaters, comparators, observers; comparators read the sensor, section 4.7), 30-3 (pistons), 30-4 (dispensers, hoppers, crafters), 30-5 (levers, plates, daylight, note block), 30-6 (rails), 30-7 (doors, trapdoors, gates, lamps, copper bulbs), all in `docs/protocol/`. Numbered documents 00 to 47 are cited `NN section M`. |
| Overlap with other documents | 31-8 sections 2 to 6 (game-event dispatch, the vibration system, sensor, calibrated sensor, shrieker block-entity side), 31-4 section 4 (bell block entity and block side) and 24-4 sections 6.26, 6.27 (tripwire) were written in parallel rounds. This part re-reads the same classes independently, restates the rules from the redstone side (power, timing, worked examples, validation vectors), and records where it agrees. No disagreement was found; a point that this reading adds or words differently is flagged "(adds)". |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. All times are game ticks (20 per second). Directions: `N`, `E`, `S`, `W`, `U`, `D`; `opp(d)` is the opposite. Receiver and asked-block language follows 30-1 section 2.2: a receiver at `R` asks the block at `R + d` with the argument `d`.

## Contents

0. Reader's map
1. Per-block rows (ids, properties, power, delays, sounds)
2. The game-event dispatch these blocks use
3. The vibration system as the sensors use it (frequencies, strength, travel, selection, occlusion, validity)
4. Sculk sensor block
5. Calibrated sculk sensor
6. Sculk shrieker (redstone-facing)
7. Tripwire and tripwire hook
8. Bell
9. Catch-all: TNT block, big dripleaf, pointers for other signal readers
10. Inventory of the redstone category
11. Worked examples
12. Validation
13. Open questions

## 0. Reader's map

| Question | Section |
|---|---|
| Ids, states, delays and sounds of the blocks of this part | 1 |
| Which events reach a listener, in which order, how far | 2 |
| The frequency of every game event; strength by distance; travel time | 3.1 to 3.4 |
| Which vibrations a sensor ignores (sneaking, wool, occlusion) | 3.5, 3.6 |
| Sensor phases and timeline; output power; comparator reading | 4 |
| Calibrated sensor back input and filter | 5 |
| Shrieker states and reaction | 6 |
| Hook line search and the exact state calculation | 7.3, 7.4 |
| What triggers the tripwire and how long it stays powered | 7.5 |
| Bell hit rule and redstone ringing | 8 |
| TNT block, big dripleaf | 9 |
| Every redstone-tab item and its owner | 10 |

## 1. Per-block rows

Layout of 30-1 section 4.2. Ids from 24 part 8 (absolute block id, first state id, state count). Sorted property order is the state-index order (24 part 1 section 3).

| Block (class) | Block id | First state id | States | Properties (default) | Power output | Input rule | Delay | Sound and game event |
|---|---|---|---|---|---|---|---|---|
| `tripwire_hook` (`TripWireHookBlock`) | 452 | 11325 | 16 | `attached` false, `facing` north, `powered` false | signal source always; weak 15 to every direction while `powered`; strong 15 only when asked with direction equal to `facing` (7.2) | none; driven by the string line (7.3) | tick 10, normal priority, scheduled by a wire (7.3) and by the hook calculation | click on, click off, attach, detach with events (7.4) |
| `tripwire` (`TripWireBlock`, constructed with the hook block) | 453 | 11341 | 128 | `attached`, `disarmed`, `east`, `north`, `powered`, `south`, `west`, all false | none (not a signal source) | entities inside its box (7.5) | 10 (powered recheck), 1 (after release) | none itself; `shear` event when cut by shears |
| `sculk_sensor` (`SculkSensorBlock`) | 1118 | 30520 | 96 | `power` 0, `sculk_sensor_phase` inactive, `waterlogged` false | signal source always; weak `power` to every direction; strong `power` only when asked with `UP` | vibrations (3) | active 30, cooldown 10 | clicking and clicking stop; events `sculk_sensor_tendrils_clicking`, resonance |
| `calibrated_sculk_sensor` (`CalibratedSculkSensorBlock`) | 1119 | 30616 | 384 | as the sensor plus `facing` north | as the sensor, but weak power 0 when asked with `facing`; strong as the sensor | back input and vibrations (5) | active 10, cooldown 10 | as the sensor |
| `sculk_shrieker` (`SculkShriekerBlock`) | 1123 | 31131 | 8 | `can_summon` false, `shrieking` false, `waterlogged` false | none | none (no signal hook is overridden) | shriek 90 | level event 3007, event `shriek` |
| `bell` (`BellBlock`) | 938 | 24162 | 32 | `attachment` floor, `facing` north, `powered` false | none | neighbour signal rising edge (8.3) | none | `block.bell.use`, event `block_change` |
| `tnt` (`TntBlock`) | 220 | 3833 | 2 | `unstable` false | none | neighbour signal, placement (9.1) | fuse of the entity | `entity.tnt.primed`, event `prime_fuse` |
| `big_dripleaf` (`BigDripleafBlock`) | 1235 | 33713 | 32 | `facing` north, `tilt` none, `waterlogged` false | none | neighbour signal resets the tilt (9.2) | 10, 10, 100 | tilt sounds, event `block_change` |

Registry facts read in the `Blocks` initializer (adds): `tripwire_hook` is no-collision, sound WOOD, push reaction POPPED, no strength call (default 0); `tripwire` is no-collision, push reaction POPPED, default sound, no strength call; `bell` is `forceSolidOn`, strength 5, sound ANVIL, push reaction POPPED, map colour GOLD; `sculk_sensor` is strength 1.5, map colour COLOR_CYAN, sound SCULK_SENSOR, a constant light level 1 for every state, and emissive rendering when the phase is `active`; `calibrated_sculk_sensor` copies the sensor's properties (`ofLegacyCopy`); `sculk_shrieker` is strength 3 and 3, sound SCULK_SHRIEKER; `tnt` is instabreak, sound GRASS, map colour FIRE, ignited by lava, never a redstone conductor. 24 holds the full rows.

## 2. The game-event dispatch these blocks use

The registry facts (61 events, ids in registration order, 46 section 5.2) and the per-section listener registry are in 31-8 sections 2.1 to 2.4. This section restates what a redstone implementer needs.

### 2.1 Posting

1. `Level.gameEvent` has four overloads that end in one operation on a server level: post (event, position `Vec3`, context) to the level's dispatcher. A client level does not dispatch (not read in detail; the sensors live on the server). The overload taking a block position uses the block centre `Vec3.atCenterOf(pos)`; the overloads taking an entity use the position the caller gives (the entity's position when the caller is the entity, the block centre when the call is `gameEvent(entity, event, pos)`).
2. A context is (source entity or none, affected block state or none). The sensors ignore nothing about it except through section 3.5.
3. `GameEventDispatcher.post(event, pos, context)`: let `r` be the event's notification radius and `B = BlockPos.containing(pos)`. The scanned section box runs, per axis, from `blockToSectionCoord(B - r)` to `blockToSectionCoord(B + r)` (arithmetic shift right by 4). For `x` from the low to the high section X, then `z` from low to high, then `y` from low to high: take the loaded chunk at (x, z) (skip when it is not loaded), and ask the listener registry of its section `y` to visit the in-range listeners.
4. A registry visits its listeners in registration order. A listener is "in range" when the block distance squared between `BlockPos.containing(listenerPosition)` and `B` is at most its own `getListenerRadius()` squared (the event's radius only chooses which sections are scanned; it is not a range test) and its position source can answer.
5. Each in-range listener is either queued or called at once: a listener whose delivery mode is `BY_DISTANCE` is queued, every other listener is called immediately in visiting order. After the scan the queue (if not empty) is sorted by squared distance from the event position to the listener (stable ascending) and delivered in that order. The vibration listener of the sensors and the shrieker does not override the delivery mode (read: no `getDeliveryMode` in `VibrationSystem$Listener`), so it is delivered immediately; no listener of the blocks of this part uses `BY_DISTANCE`. The sorted distance queue therefore never applies to this part, and an implementer need not build it for these blocks (3.3 starts from the immediate call).

Notification radius: 16 for every event except `jukebox_play` and `jukebox_stop_play` (10) and `shriek` (32) (read in the `GameEvent` initializer; default constant 16). Consequence: a calibrated sensor (listener radius 16) hears an event whose radius is 16 up to 16 blocks, and a sensor (radius 8) up to 8 blocks; the `shriek` event scans out to 32 but a sensor (8 or 16) ignores it anyway (frequency 0, section 3.1).

### 2.2 Registration

A block entity whose block implements `EntityBlock` and whose block entity is a listener provider is registered, when the block entity is added to a server-level chunk, in the registry of the chunk section that contains it (`LevelChunk.addGameEventListener`), and unregistered on removal. The default `EntityBlock.getListener` returns the block entity's listener when it is a `GameEventListener.Provider`, else none. The sensor, calibrated sensor and shrieker block entities provide `VibrationSystem$Listener`. Their position source is the block position (`BlockPositionSource`), whose position is the block centre. Moving listeners (`DynamicGameEventListener`, for entities) re-register in the new section when the section changes; blocks never move, so this part does not use it.

### 2.3 Events emitted by the blocks of this part

| Emitter | Event (frequency, section 3.1) | Source entity | Position |
|---|---|---|---|
| hook, line becomes powered | `block_activate` (10) | none | the hook (each of the two hooks) |
| hook, line unpowers | `block_deactivate` (9) | none | each hook |
| hook, line becomes attached | `block_attach` (10) | none | each hook |
| hook, line detaches | `block_detach` (9) | none | each hook |
| tripwire cut by shears | `shear` (6) | the player | the wire |
| sensor activates | `sculk_sensor_tendrils_clicking` (0), then `resonate_n` from resonators (n) | the entity that caused the vibration | the sensor; each resonator block |
| shrieker shrieks | `shriek` (0), notification radius 32 | the player | the shrieker |
| bell rung | `block_change` (11) | the ringing entity | the bell |
| big dripleaf changes to a vibrating tilt | `block_change` (11) | none | the leaf |
| TNT primed | `prime_fuse` (10) | the igniter or none | the block position |

A sensor next to a hook therefore hears the hook's `block_activate` and so on at their frequencies; a bell next to a calibrated sensor is heard at 11.

## 3. The vibration system as the sensors use it

Persistence (`last_vibration_frequency`, `listener` compound, `Data`, `VibrationInfo`, `VibrationSelector` NBT) is 31-8 sections 3.4 and 4.1; this part does not repeat the keys.

### 3.1 Frequency of every game event (`VibrationSystem.getGameEventFrequency`)

An event that is not in the table has frequency 0 and is never received by a sensor. Read from the table initializer:

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
| `n` (1 to 15) | `resonate_n` |
| 0 | the remaining five: `item_interact_start`, `jukebox_play`, `jukebox_stop_play`, `sculk_sensor_tendrils_clicking`, `shriek` |

41 listed events plus 15 resonance events give 56 non-zero events; with the five zero events that is the 61 of the registry. `getResonanceEventByFrequency(f)` is `resonate_f` (a list of 15 indexed `f - 1`).

### 3.2 Redstone strength and travel time

- Strength for a received vibration: `max(1, 15 - floor((15 / radius) * distance))`, computed in double arithmetic with `distance` the block-position distance (section 3.3), `radius` the listener radius (8 sensor and shrieker, 16 calibrated). Strength is always 1 to 15.
- Travel time: `floor(distance)` ticks, where `distance` is the float distance from the event position to the listener position (both exact `Vec3`; the listener is the block centre). The default `User` rule is used by all three users (none overrides `calculateTravelTimeInTicks`).

Strength by block distance (radius 8, factor 1.875):

| Distance `d` | 0 | 1 | sqrt 2 | sqrt 3 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `floor(1.875 d)` | 0 | 1 | 2 | 3 | 3 | 5 | 7 | 9 | 11 | 13 | 15 |
| Strength | 15 | 14 | 13 | 12 | 12 | 10 | 8 | 6 | 4 | 2 | 1 |

Strength is `15 - k` for `d` in `[k / 1.875, (k + 1) / 1.875)`; boundaries of the 15 bands: 0.533, 1.067, 1.6, 2.133, 2.667, 3.2, 3.733, 4.267, 4.8, 5.333, 5.867, 6.4, 6.933, 7.467 and 8 (all rounded to 3 decimals). Radius 16 (factor 0.9375): `d` 0 and 1 give 15; 2 gives 14; 4 gives 12; 8 gives 8; 16 gives 1.

### 3.3 The listener and the two distances

`handleGameEvent(level, event, context, eventPos)` (the listener of the owner), in order; the first failing step returns false and nothing happens:
1. a vibration is already in flight (`currentVibration` set): ignore;
2. `user.isValidVibration(event, context)` fails (3.5): ignore;
3. the listener position is unknown: ignore;
4. `user.canReceiveVibration(level, BlockPos.containing(eventPos), event, context)` fails: ignore;
5. the path is occluded (3.6): ignore;
6. otherwise add a candidate to the selector (3.4) with the float distance `eventPos.distanceTo(listenerPos)` and the level's game time; return true.

Two different distances exist: the float `Vec3` distance (candidate, travel time) and, when the vibration finally arrives, the distance recomputed between the two block positions (`BlockPos.distSqr` square root, as float), which alone feeds the strength (`receiveVibration`). A sensor with a vibration in flight ignores every other event until that vibration has been received (step 1), so two events in the same period are not both answered.

### 3.4 Selection and the ticker

1. Candidates arriving in the same game tick compete; at most one is kept. A new candidate replaces the kept one when: there is none; or the kept one is from the same tick and the new distance is smaller; or the same tick, equal distances and the new frequency is strictly greater. A candidate from another tick never replaces (the kept one is chosen first).
2. The owner's ticker runs every tick on a server level. With no vibration in flight it asks the selector for its candidate; a candidate counts only when its tick is strictly earlier than the current game time. A chosen candidate becomes the vibration in flight with travel time `floor(distance)`; a `vibration` particle is sent; the selector is cleared.
3. Each tick with a vibration in flight: decrement the travel time (not below 0); when it is 0 or less the vibration is received: the owner needs the 3 by 3 chunk neighbourhood of its block to be loaded and block-ticking, else the vibration waits and is retried every tick; otherwise `onReceiveVibration(level, eventBlockPos, event, sourceEntity, projectileOwner, blockDistance)` is called and the vibration is cleared.

Timing consequence (derived from 1 to 3): an event posted in game tick `T` is chosen in tick `T + 1` at the earliest. With travel time `n = floor(distance)` the owner is told in tick `T + max(n, 1)`.

### 3.5 Which vibrations count (`VibrationSystem$User.isValidVibration`)

In order, first match returns:
1. the event is not in the user's listenable tag (`vibrations` for the sensors, `shrieker_can_listen` for the shrieker): not valid;
2. when the context has a source entity: a spectator is not valid; an entity that `isSteppingCarefully()` (read: `Entity.isSteppingCarefully` returns the shift-key-down state; `Cat` and `Ocelot`, both in package `animal.feline`, each override it as `isCrouching()` OR the superclass result, so a crouching cat or ocelot also counts) and an event in `ignore_vibrations_sneaking` is not valid, and when the user `canTriggerAvoidVibration()` (true for the sensors) and the entity is a server player the advancement trigger `avoid_vibration` fires; an entity whose `dampensVibrations()` is true is not valid (read: the warden, and `ItemEntity`, which overrides it to return whether its item stack is in the item tag `dampens_vibrations`; item entities are valid vibration sources, so a dropped item in that tag is silenced; the tag lists `#wool`, `#wool_carpets`, `#wool_slabs`, `#wool_stairs`, membership being data);
3. when the context has an affected block state: valid unless that state is in block tag `dampens_vibrations` (this is how wool silences a step on it);
4. otherwise valid.

### 3.6 Occlusion (`VibrationSystem$Listener.isOccluded`)

Both the event position and the listener position are first snapped to their block centres (`floor(coordinate) + 0.5` per axis). For each of the six directions `d` the start point is the snapped event centre moved 0.00001 (9.999999747378752E-6 in the read constant) along `d`; a ray from that point to the snapped listener centre is tested for the first block state in block tag `occludes_vibration_signals` (the level's block-in-line query). The vibration is occluded only when **all six** rays meet such a block: a single clear ray lets it through. The ray semantics are inferred from the call and its result type (Open question 5).

## 4. Sculk sensor block

### 4.1 State and phases

`SculkSensorPhase` serialized names: `inactive`, `active`, `cooldown` (ordinals 0, 1, 2). `canActivate(state)` is true only in `inactive`. `power` is the output (0 when not active).

| Phase | Entered by | Output power | Leaves by |
|---|---|---|---|
| `inactive` | placement; end of `cooldown` | 0 | a received vibration |
| `active` | `activate(...)` | the strength of the vibration (3.2) | scheduled tick after 30 (sensor) or 10 (calibrated) |
| `cooldown` | `deactivate(...)` | 0 | scheduled tick after 10 |

### 4.2 `activate(entity, level, pos, state, power, frequency)`

1. Set phase `active` and `power` (`setBlockAndUpdate`).
2. Schedule a block tick after `getActiveTicks()` (30; 10 for the calibrated sensor).
3. `updateNeighbours`: tell the neighbours of `pos` and of `pos.below()` (block as source). Receivers of the output below the sensor (strong power via `UP`) are thereby updated.
4. Resonance: for each of the six `Direction.values()` neighbours in tag `vibration_resonators`, post the event `resonate_frequency` at that block with context (entity, that block's state), and play `amethyst_block_resonate` at the neighbour, blocks source, volume 1, pitch `2^((note - 12) / 12)` where `note` = `{0, 0, 2, 4, 6, 7, 9, 10, 12, 14, 15, 18, 19, 21, 22, 24}[frequency]` (pitch table of 16 floats; index 0 unused). Pitch for frequency 1 is 0.5 (note 0), for 8 is 1.0 (note 12), for 15 is 4.0 (note 24).
5. Post `sculk_sensor_tendrils_clicking` at `pos` with the entity as source.
6. When not waterlogged: play `sculk_clicking` at the block centre, blocks source, volume 1, pitch `random.nextFloat() * 0.2 + 0.8` (level random).

### 4.3 Block tick

Phase `active`: `deactivate` = set phase `cooldown` and `power` 0 (`setBlockAndUpdate`), schedule a tick after 10, `updateNeighbours`. Phase `cooldown`: set `inactive` (`setBlockAndUpdate`); when not waterlogged play `sculk_clicking_stop` at the position, blocks source, volume 1, pitch `random.nextFloat() * 0.2 + 0.8`. Phase `inactive`: nothing.

So a sensor that has been activated is deaf for `30 + 10 = 40` ticks, a calibrated sensor for `10 + 10 = 20` ticks (from the activation tick to the tick it is `inactive` again).

### 4.4 Other block rules read

- Placement: waterlogged from the fluid at the position; fluid state is the source water fluid when waterlogged; `updateShape` schedules a water tick when waterlogged.
- `onPlace` (server, previous block not this one): when `power > 0` and no block tick is scheduled at the position, set `power` 0 with flags 18 (clients and no shape updates). This clears a power value that came from a saved or pasted state.
- `affectNeighborsAfterRemoval`: when the removed phase was `active`, `updateNeighbours` (so receivers learn the output is gone).
- `stepOn(level, pos, state, entity)` (server): when `canActivate`, the entity is not a warden, a sensor block entity exists, and the user's `canReceiveVibration(level, pos, step, Context.of(state))` holds: `forceScheduleVibration(level, step, Context.of(entity), entity.position())`. This bypasses the listenable tag, sneaking, occlusion and the in-flight check; the candidate still goes through the selector and the ticker. The frequency of `step` is 1.
- Destruction: when the block is broken and drops (`spawnAfterBreak` with a drop flag) it drops 5 experience (constant int provider 5).
- Not pathfindable; uses its shape for light occlusion; shape `column(16, 0, 8)` (lower half; 24).
- Client animation (`animateTick`): while `active`, with a random direction other than UP or DOWN, a particle with the option `DustColorTransitionOptions.SCULK_TO_REDSTONE` at a point on the side of the block (x or z at `0.5 + step * 0.6`, or `0.5 - random` along the other horizontal axis, y 0.25), velocity `(0, random * 0.04, 0)` (reference only).

### 4.5 The block entity's `User` (sensor)

| Member | Value |
|---|---|
| Listener radius | 8 (calibrated: 16) |
| `canTriggerAvoidVibration` | true |
| `requiresAdjacentChunksToBeTicking` | true |
| `canReceiveVibration(level, pos, event, context)` | false when `pos` equals the sensor's own block and the event is `block_destroy` or `block_place`; false when the frequency is 0; else `canActivate(state)` |
| `onReceiveVibration` | when the state can still activate: `f` = event frequency; store `f` in `last_vibration_frequency`; strength by 3.2 with radius 8 and the block distance; `activate(sourceEntity, level, pos, state, strength, f)` |
| `onDataChanged` | mark the block entity changed |

`last_vibration_frequency` is never cleared on deactivation (the comparator ignores it unless `active`).

### 4.6 Signals

| Query | Result |
|---|---|
| `isSignalSource` | true (also in `inactive` and `cooldown`) |
| `ownSignal` | `power` |
| `getSignal(d)` (not overridden) | `ownSignal`: weak `power` toward every neighbour |
| `getDirectSignal(d)` | `power` when `d` is `UP`, else 0 (so the block under the sensor is strongly powered, the others only weakly) |

### 4.7 Comparator

`hasAnalogOutputSignal` true. `getAnalogOutputSignal`: while the phase is `active` and the block entity exists, `last_vibration_frequency` (1 to 15), else 0. This reading is consumed by 30-2 section 5; note it is the **frequency**, not the strength, so a comparator can tell which kind of event the sensor heard.

## 5. Calibrated sculk sensor

`CalibratedSculkSensorBlock extends SculkSensorBlock`; the block entity extends the sensor's entity and has its own type `calibrated_sculk_sensor`.

- Extra property `facing` (horizontal, default north). Placement: `facing` is the placing entity's horizontal direction (not its opposite), so the **back** of the sensor (`opp(facing)`) is the side toward the placer. `rotate` and `mirror` act on `facing` only.
- Listener radius 16; active ticks 10 (section 4.1).
- Input side. `back = level.getSignal(pos.relative(opp(facing)), opp(facing))` (the full level query of 30-1 section 2.3, so power from a repeater, a conductor block with strong power, or wire all count). `canReceiveVibration`: when `back != 0` and the event's frequency is not equal to `back`, false; otherwise the plain sensor rule (4.5). So `back = 0` accepts every frequency; `back = n` accepts only events of frequency `n`. Events with frequency 0 are never accepted.
- Output side. `getSignal(d)` is 0 when `d` equals `facing` (the receiver is at the back of the sensor, so the back gives no output into its own input), else `ownSignal`. `getDirectSignal(d)` is inherited: `UP` only, via `getSignal(UP)`.
- The sensor still supplies the comparator reading of 4.7 and the resonance of 4.2.

Strength with radius 16 (3.2): `distance 0 or 1` gives 15; `4` gives 12; `8` gives 8; `16` gives 1.

## 6. Sculk shrieker (redstone-facing parts)

The shrieker has no redstone input and no output: it overrides no signal hook and no analog-output hook (checked against the census of 30-1 section 2.5 and the signal calls found in the block classes). Its redstone relevance is as a vibration listener and as a source of the `shriek` event. The warden logic is 44-x2 section 2 and 31-8 section 6.

### 6.1 State

`can_summon` (default false; the code never sets it itself; how structure data sets it for ancient cities is a worldgen matter, recalled, not verified, Open question 14), `shrieking` (default false), `waterlogged`. Collision and occlusion shape `column(16, 0, 8)`; light occlusion by shape. Drops 5 experience when broken with drops.

### 6.2 What makes it shriek

- A vibration (listener radius 8) in the tag `shrieker_can_listen`, valid under 3.5, whose source entity resolves through `tryGetPlayer` to a server player: the player itself; else the controlling passenger of a vehicle when it is a player (read: the vehicle test happens for a non-player entity that has a controlling passenger); else the owner of a projectile when that is a player; else the owner of an item entity when that is a player. `canReceiveVibration` additionally requires the block not to be `shrieking`. The player used by the reaction is the projectile owner when one is given, else the source entity.
- Stepping on the block (`stepOn`, server): when `tryGetPlayer(entity)` finds a player and the block entity exists, `tryShriek` at once (no vibration, no travel).

### 6.3 `tryShriek(level, player)`

1. Do nothing when the player is absent or the block is already `shrieking`.
2. Set `warning_level` 0.
3. When `canRespond(level)` (`can_summon` and difficulty not peaceful and game rule `spawn_wardens`): ask the player's warden-spawn tracker to warn (44-x2); when it declines, stop here without shrieking.
4. `shriek`: set `shrieking` true (`setBlock`, flags 2), schedule a block tick after 90, level event 3007 (data 0) at the position, post the event `shriek` at the position with the player as source.

### 6.4 Block tick and removal

The tick (when `shrieking`): set `shrieking` false (`setBlockAndUpdate`), then `tryRespond`. Breaking a shrieking block runs `tryRespond` once before removal. `tryRespond`: when `canRespond` and `warning_level > 0`: try to summon a warden (needs level at least 4; one `SpawnUtil` spawn call for the warden type with spawn reason triggered, the numeric arguments 20, 5 and 6 in that parameter order, strategy on top of a collider, collision check off; their meaning is 44-x2); when that does not spawn, play the reply sound for the level (1 `warden_nearby_close`, 2 `warden_nearby_closer`, 3 `warden_nearby_closest`, 4 `warden_listening_angry`) at the position offset by a random integer in `-10..10` on each axis, hostile source, volume 5, pitch 1; then apply the darkness effect around the block centre with radius 40.

## 7. Tripwire and tripwire hook

### 7.1 Geometry and states

- Hook: `facing` horizontal, pointing from its support block toward the line. Shape `rotateHorizontal(boxZ(6, 0, 10, 10, 16))`: for `facing` north, x 5 to 11, y 0 to 10, z 10 to 16 (pixels); no collision. Survival: the block at `pos.relative(opp(facing))` has a sturdy face toward `facing`. Placement: of the horizontal directions in the placer's nearest-looking order, the first `d` for which the state with `facing = opp(d)` survives; none: not placeable. `updateShape`: when the changed direction is `opp(facing)` and the block cannot survive, it becomes air. After placement (`setPlacedBy`) the hook calculation runs once without notifying neighbours (7.3).
- Wire: shape `column(16, 1, 2.5)` (full width, y 1 to 2.5 pixels) when `attached`, `column(16, 0, 8)` (y 0 to 8) when not. Its inside-block collision shape equals its shape. Horizontal sides `north`, `east`, `south`, `west`: side `d` is true when the neighbour in `d` is a hook with `facing == opp(d)` (it faces the wire) or is another wire. Placement computes the four sides; an update from a horizontal direction recomputes that side. `rotate` and `mirror` permute the four sides.

### 7.2 Signals

Hook: `isSignalSource` true. `ownSignal` and weak `getSignal(d)` (not overridden) are 15 while `powered`, else 0, for every direction. `getDirectSignal(d)` is 15 only when `powered` and `d == facing`, else 0: the block the hook hangs on (the receiver at `pos - facing`, which asks with `facing`) is strongly powered and so conducts to everything touching it; every neighbour of the hook is weakly powered while powered. Wire: no signal hook.

### 7.3 The hook state calculation (`TripWireHookBlock.calculateState`)

Inputs: the level; the hook position `P` and state; `removing`; `notify` (whether to tell the neighbours of the hook at the end); `c`, the distance of one cell to be treated as a wire in a given state (`-1` means none); `W`, the state to assume in that cell (null when `c = -1`). A state without a readable `facing` makes the call a no-op. Let `f` = the hook's `facing`; `wasAttached` and `wasPowered` its stored values.

Scan. For `k` = 1 to 41 inclusive (the loop bound is 42, exclusive; the scratch array has 42 entries; so a line holds at most 40 wires between two hooks):
1. Read the state `S` at `P + f * k`.
2. When `S` is a tripwire hook: when its `facing` is `opp(f)` the scan ends with `D = k`; when it faces another way the scan ends with `D = 0`.
3. Else when `S` is a tripwire, or `k == c`: when `k == c` use `W` in place of `S` (the first non-null of `W` and `S`, so a null `W` leaves `S`). `armed` = not `disarmed`; `pow` = `powered`. `anyPowered` becomes true when `armed` and `pow`. Record the state in cell `k`. When `k == c`: schedule a tick at `P` after 10 (normal priority) and `attached` is combined with `armed` (a disarmed changed cell clears it).
4. Else (air or any other block, not the changed cell): record "none" in cell `k` and set `attached` false. The scan **continues** (a gap does not end it).

Result flags: `attached = (start true unless removing) and (no gap) and (the changed cell armed) and D > 1`; `powered = anyPowered and attached`. (The initial `attached` is `not removing`.)

Writes, in order, with `H` = the default hook state with `attached` and `powered` set:
1. When `D > 0`: let `Q = P + f * D`. Set `Q` to `H` with `facing = opp(f)` (`setBlockAndUpdate`, flags 3); notify the neighbours of `Q` (7.6); when the block at `P` is no longer a tripwire hook after that (the far hook's updates may have removed it), run the removal handler (7.7) with `H` and stop; otherwise emit the transition effects (7.4) at `Q` comparing `(attached, powered)` with `(wasAttached, wasPowered)`.
2. Emit the transition effects at `P` with the same comparison.
3. When not `removing`: set `P` to `H` with `facing = f` (`setBlockAndUpdate`); when `notify` is true, notify the neighbours of `P` (7.6).
4. When `attached != wasAttached`: for each `k` from 1 to `D - 1`: when cell `k` recorded a state and the block now at `P + f * k` is a tripwire or a hook, set it to the recorded state with `attached` replaced by the new value (`setBlockAndUpdate`).

Callers: placement (`removing` false, `notify` false, `c = -1`); the hook's own scheduled tick (`removing` false, `notify` true, `c = -1`, the 10-tick refresh); a wire's `updateSource` (7.5; `notify` true, `c` = the wire's distance from the hook, `W` = the wire's state); the removal handler (`removing` true, `notify` false, `c = -1`).

### 7.4 Transition effects (`emitState(level, pos, attached, powered, wasAttached, wasPowered)`)

Exactly one of these, first match:

| Condition | Sound (blocks source, no source entity) | Event (no entity) |
|---|---|---|
| `powered` and not `wasPowered` | `tripwire_click_on`, volume 0.4, pitch 0.6 | `block_activate` |
| not `powered` and `wasPowered` | `tripwire_click_off`, 0.4, pitch 0.5 | `block_deactivate` |
| `attached` and not `wasAttached` | `tripwire_attach`, 0.4, pitch 0.7 | `block_attach` |
| not `attached` and `wasAttached` | `tripwire_detach`, 0.4, pitch `1.2 / (random.nextFloat() * 0.2 + 0.9)` | `block_detach` |

The detach pitch therefore lies between `1.2 / 1.1 = 1.0909` and `1.2 / 0.9 = 1.3333` (level random).

### 7.5 The wire: entity detection, shears, refresh

- **`entityInside`** (server): when the wire is not `powered` and no tick is already scheduled at its position, run `checkPressed` over the single entity that is inside (the inside-block pass: 29a section 8.6). An already-powered wire does nothing here.
- **`checkPressed(level, pos, entities)`**: `pressed` = at least one entity in the list for which `isIgnoringBlockTriggers()` is false. When `pressed != powered`: set `powered = pressed` (`setBlockAndUpdate`) and run `updateSource`. Then, when `pressed`: schedule a tick after 10; else when it was `powered`: schedule a tick after 1.
- **Scheduled tick**: when the wire is not `powered`, nothing. Otherwise gather the entities (every entity except spectators, the level's default entity query) whose box overlaps the wire's current shape bounds moved to its position, and run `checkPressed` over that list. A powered wire therefore re-checks every 10 ticks while something stands on it, and releases at the first check that finds nothing. A release is noticed at the next 10-tick check, so it follows the departure of the last entity by 0 to 10 ticks (inferred from the cycle; the check phase depends on when the entity first stepped in).
- **Entities that never trigger** (`isIgnoringBlockTriggers` true, read): `Display` entities, `Interaction`, `Marker`, `OminousItemSpawner`, `Bat`, and an `ArmorStand` that is a marker (the same method is read by `BasePressurePlateBlock`; see 30-5 section 4); every other entity (default false) triggers: players, mobs, item entities, experience orbs, arrows, boats.
- **`onPlace`** (previous block not this wire): `updateSource` with its own state. **Removal** (`affectNeighborsAfterRemoval`, not caused by a piston): `updateSource` with the removed state **with `powered` forced true**. Effect: the removed cell still counts as a powered wire in the calculation (unless the old state was `disarmed`), so cutting a wire without shears pulses the hooks (`powered` true for the check) and the 10-tick recheck then finds the gap (7.3 step 4) and drops `attached` and `powered`.
- **`updateSource(level, pos, state)`**: for `d` in {S, W}: for `i` = 1 to 41: read the block at `pos + d * i`; a hook whose `facing == opp(d)` runs the calculation of 7.3 for that hook with `removing` false, `notify` true, `c = i`, `W = state` and ends this direction; a hook facing otherwise ends it; any block that is not this wire ends it; a wire continues. Only south and west are scanned because the calculation of the found hook covers the whole line and updates the hook at the other end; a hook found in the north or east is reached from the far end.
- **Shears**: `playerWillDestroy` on a server, when the player's main hand is non-empty shears: set `disarmed` true (flags 260: no neighbour updates, no entity side effects), post `shear` at the wire with the player as source, then run the normal destruction. A disarmed wire counts as absent for `powered` and clears `attached` (7.3 step 3), so cutting a wire with shears never pulses the hooks and the wire does not trigger them again.

### 7.6 Notifying neighbours (`notifyNeighbors(block, level, pos, direction)`)

Update the neighbours of `pos` and then the neighbours of `pos.relative(opp(direction))` with the hook block as source, passing the redstone orientation built from `opp(direction)` and `UP` (the orientation is used only by the experimental evaluator; 30-1 section 2.7). With `direction = facing` the second block is the support block, whose attached components (wire, lamps) therefore see the strong power change.

### 7.7 The hook's own removal

`affectNeighborsAfterRemoval` (not caused by a piston) runs the removal handler on the removed state: when it was `attached` or `powered`, run the calculation with `removing` true, `notify` false; when it was `powered`, notify the neighbours of the removed hook as in 7.6 with its old `facing`. The tick of the hook (`tick`) runs the calculation with `notify` true (it also re-notifies the neighbours of both hooks even when nothing changed).

## 8. Bell

### 8.1 State and placement

`facing` (default north), `attachment` (`floor`, `ceiling`, `single_wall`, `double_wall`; ordinals 0 to 3; default `floor`), `powered` (default false). Placement, shapes, survival and `updateShape` are 24-7 section 11.5 and are not repeated; they were re-read and agree. `rotate`/`mirror` act on `facing`. The block is not pathfindable.

### 8.2 The hit rule (`isProperHit(state, hitFace, relY)`)

A hit rings the bell only when: the hit face is not on the Y axis, and `relY` (hit y minus block y) is not greater than 0.8123999834060669 (strict "greater than"; the float 0.8124 widened); and by attachment: `floor`: the axis of the hit face equals the axis of `facing`; `single_wall` and `double_wall`: the axes differ; `ceiling`: always. Hits on the top or bottom face never ring. The mapping from attachment type to the three branches was read in the switch-map class `BellBlock$1` (floor is case 1, single wall case 2, double wall case 3, ceiling case 4); case 1 requires equal axes, cases 2 and 3 require different axes, case 4 always rings, matching the list above. Example: a floor bell with `facing` north rings from the north or south face (axis Z), not the east or west face; a wall bell with `facing` north rings from the east or west face.

### 8.3 Ring sources

| Source | Rule |
|---|---|
| Use without item | `onHit(level, state, hit, player, check = true)`; returns SUCCESS when the hit counted, else PASS |
| Projectile hit | the projectile's owner when it is a player (else none); `onHit` with `check = true` |
| Explosion that can trigger blocks | `attemptToRing(level, pos, no direction)`, then the default explosion handling |
| Redstone | `neighborChanged`: `s = level.hasNeighborSignal(pos)` (30-1 section 2.3); when `s != powered`: when `s` is true, `attemptToRing(level, pos, no direction)`; then set `powered = s` (`setBlockAndUpdate`). Rings on the rising edge only; the falling edge only clears `powered`. |

`onHit`: `dir` is the hit direction and `check` counts the hit only when `isProperHit` (both call sites pass `check = true`); a counted hit calls `attemptToRing(player, level, pos, dir)` and, when that rang and a player is known, awards the custom statistic `bell_ring`; the method returns whether the hit counted.

`attemptToRing(entity, level, pos, dir)`: only on a server level and when the block entity is a bell, otherwise false. When `dir` is absent it is the state's `facing`. Then: the block entity's `onHit(dir)` (8.4); play `bell_block` (`block.bell.use`) at the position, blocks source, no source entity, volume 2.0, pitch 1.0; post `block_change` at `pos` with the ringing entity as source (frequency 11, so sensors hear a bell); return true.

### 8.4 The block entity (`BellBlockEntity`)

Fields (not saved: the entity has no NBT of its own): `shaking`, `ticks`, `clickDirection`, `resonating`, `resonationTicks`, `lastRingTimestamp`, and the cached `nearbyEntities`. Constants: shake duration 50, resonance delay 5, resonance length 40, entity search radius 48 (box), "hears the bell" radius 32, glow duration 60, entity-list refresh interval 60.

- `onHit(dir)`: `clickDirection = dir`; when already shaking `ticks = 0`, else `shaking = true`; queue the block event (type 1, value `dir.get3DDataValue()`). Delivery of the event to the entity's `triggerEvent` and to clients is 29 section 6.
- `triggerEvent(1, v)`: refresh the entity list (below), `resonationTicks = 0`, `clickDirection = from3DDataValue(v)`, `ticks = 0`, `shaking = true`, return true.
- Refresh (`updateEntities`): when the game time is greater than `lastRingTimestamp + 60` or there is no cached list: `lastRingTimestamp` = game time, and the cached list = every `LivingEntity` in the block's box inflated by 48. On the server, every list entry that is alive, not removed, and whose position is closer than 32 to the block centre (`closerToCenterThan`) gets the brain memory `heard_bell_time` set to the game time (villager reaction: 44-x2 section 2.11a). This server loop runs on every refresh call, not only when the list was rebuilt.
- Tick (both sides; the block supplies the same logic with a different end action), per tick in this order: (1) when `shaking`, `ticks += 1`; (2) when `ticks >= 50`, `shaking = false` and `ticks = 0`; (3) when `ticks >= 5` and `resonationTicks == 0` and a living, alive, not removed entity of tag `raiders` is within 32 of the block centre among the cached entities: `resonating = true` and play `bell_resonate` (blocks source, volume 1, pitch 1, no source entity); (4) when `resonating`: when `resonationTicks < 40` increment it, else run the end action and clear `resonating`.
- End action, server: every raider (alive, not removed, tag `raiders`, closer than 48) receives the `glowing` effect for 60 ticks. End action, client: particles (31-4 section 4).
- `resonationTicks` is not reset when the resonance ends, so a second resonance needs a new ring (the event resets it).

Redstone consequence: a pulse train on the bell restarts the shake (`ticks` back to 0) and, because every ring resets `resonationTicks`, a bell rung every 40 ticks or less may extend a resonance; the glow still comes only at its end action.

## 9. Catch-all

### 9.1 TNT block (`TntBlock`, block `tnt`)

State `unstable` (default false; set by data and by the block's own use, not by a piston). Never a redstone conductor (24). `isSignalSource` false: it only reads power.

| Hook | Rule |
|---|---|
| `onPlace` (previous block not TNT) | when `level.hasNeighborSignal(pos)`: `prime(level, pos)`; when it returned true, `removeBlock(pos, false)` |
| `neighborChanged` | same two lines, without the previous-block test (so any neighbour change while powered primes it) |
| `playerWillDestroy` | on a server, when the player is not in creative (`instabuild` false) and `unstable` is true: `prime(level, pos)`; then the normal destruction |
| `wasExploded` (destroyed by another explosion) | when game rule `tnt_explodes` is true: spawn a primed TNT at `(x + 0.5, y, z + 0.5)` whose owner is the explosion's indirect source entity, with fuse `rng.nextInt(max(1, 80 / 4)) + 80 / 8` = `nextInt(20) + 10`, i.e. 10 to 29 ticks (80 is the entity's default fuse, 21 section 8.3; integer divisions), then add the entity. The TNT item is not dropped (`dropFromExplosion` is false). |
| `useItemOn` | flint and steel or fire charge only (else the default): `prime(level, pos, player, stack)`; on true: set the block to air with flags 11, damage the flint and steel by 1 (or consume one fire charge), award the item-used statistic, return SUCCESS; on false: when on a server and `tnt_explodes` is false send the overlay text `block.minecraft.tnt.disabled` and return PASS; else SUCCESS |
| `onProjectileHit` | on a server, when the projectile is on fire and may interact with the block: `prime(level, pos, owner if living else none, the arrow's pickup stack else empty)`; when true, `removeBlock(pos, false)` |

`prime(level, pos, owner, stack)`: false unless the level is a server level and `tnt_explodes` is true; false when the owner is a player in adventure mode who may not break this block with the stack (`canBreakBlockInAdventureMode`); otherwise create a primed TNT entity at `(x + 0.5, y, z + 0.5)` with that owner (fuse 80, the entity constructor sets the default fuse and a small random horizontal velocity; 21 section 8.3), add it, play `tnt_primed` at the entity, blocks source, volume 1, pitch 1, post `prime_fuse` (frequency 10) with the owner as source, return true. Explosion strength and the later explosion are 21 section 8.3 and 33 section on the rule `tnt_explodes`; the dispenser path is 30-4 section 4.

Powering a TNT block with any neighbour signal (lever, wire, torch) primes it the moment the power arrives or the block is placed next to a powered source.

### 9.2 Big dripleaf (`BigDripleafBlock`, redstone-facing part only)

Shape, growth, bone meal and survival are 24 and 29b. The tilt state machine (`tilt`: `none`, `unstable`, `partial`, `full`; serialized in that order) reads the neighbour signal:

| Event | Rule |
|---|---|
| Entity inside the leaf (server) | when `tilt` is `none`, `canEntityTilt` (the entity is on the ground and its y is greater than `pos.y + 0.6875`), and `hasNeighborSignal(pos)` is false: set `unstable`, no sound, schedule a tick after the delay of the new tilt |
| `neighborChanged` | when `hasNeighborSignal(pos)`: `resetTilt` |
| Scheduled tick | when `hasNeighborSignal(pos)`: `resetTilt` and stop. Else by `tilt`: `unstable` becomes `partial` with `big_dripleaf_tilt_down`; `partial` becomes `full` with `big_dripleaf_tilt_down`; `full` runs `resetTilt`; `none` nothing |
| Projectile hit | set `full` at the hit block with `big_dripleaf_tilt_down` (no power check) |
| `resetTilt` | set `none`; when the previous tilt was not `none`, play `big_dripleaf_tilt_up` |

Delay until the next state (ticks): `unstable` 10, `partial` 10, `full` 100, `none` none. `setTilt` writes the new state with flags 2 (clients, no neighbour updates) and posts `block_change` when the new tilt "causes a vibration" (`none` true, `unstable` false, `partial` true, `full` true) and differs from the old. Tilt sounds are played with the pitch `Mth.randomBetween(random, 0.8, 1.2)` (read: `Mth.randomBetween(rng, min, max)` is `rng.nextFloat() * (max - min) + min`, uniform in [0.8, 1.2); the floats 0.8 and 1.2 read), volume 1, blocks source, no source entity. A powered leaf therefore stays flat, and powering a tilting leaf returns it to `none` at once.

### 9.3 Pointers for the other blocks that read a neighbour signal

A scan of every block class (1618 classes of `world.level.block`, `world.entity` and `world.item`) for calls of the neighbour-signal queries gives the following readers. Those not owned by a part of this family are specified elsewhere.

| Reader | Where specified |
|---|---|
| `DoorBlock`, `TrapDoorBlock`, `FenceGateBlock`, `RedstoneLampBlock`, `CopperBulbBlock`, `NoteBlock` | 30-7 (and 30-5 section 8 for the note block) |
| `DispenserBlock` (dropper), `HopperBlock`, `CrafterBlock` | 30-4 |
| `BaseRailBlock`/`PoweredRailBlock`, `DetectorRailBlock` | 30-6 |
| `PistonBaseBlock` and `DiodeBlock`, `ObserverBlock` | 30-3 and 30-2 |
| `CommandBlock`, `StructureBlock`, `TestBlock` | 31-6 |
| `ShelfBlock` (powered shelf), `AbstractSkullBlock` (powered head) | 31-3 sections 6 and (skull) |
| `LecternBlock` (powered output), `JukeboxBlock` | 31-4 and 30-5 section 9 |
| `TrappedChestBlock` (signal = open count 0 to 15, strong `UP`) | 31-1 section 10.5 and 30-5 |
| `BellBlock`, `SculkSensorBlock`, `TripWireHookBlock`, `TntBlock`, `BigDripleafBlock` | this part |
| `CarvedPumpkinBlock` (calls neighbour updates for the golem pattern; no signal read) | not redstone; entity documents |

## 10. Inventory of the redstone category

The item set of the creative tab `itemGroup.redstone` (key `redstone_blocks`, top row, column 4) was read from the tab's display-items generator: 67 entries (66 `accept` calls and one `forEach` over the waxed copper bulbs), with no conditions. Order of the tab; "Part" is the document that specifies the behaviour. Only a representative of each variant family is listed in the tab (read: one `oak_button`, one `stone_button`, one `oak_pressure_plate`, one `stone_pressure_plate`, one `oak_door`, one `oak_trapdoor`, one `oak_fence_gate`, one `oak_chest_boat`, white wool only); the sibling variants share the class and the owner of the representative.

| # | Item (block) | Part |
|---|---|---|
| 1 | `redstone` (block `redstone_wire`) | 30-1 section 5 |
| 2 | `redstone_torch` (blocks `redstone_torch`, `redstone_wall_torch`) | 30-1 section 8 |
| 3 | `redstone_block` | 30-1 section 6 |
| 4, 5 | `repeater`, `comparator` | 30-2 |
| 6 | `target` | 30-5 section 6 |
| 7 | `copper_bulb`: the waxed variants (all four oxidation states, read as a per-state `forEach`; the four-state reading is inferred) | 30-7; analog output 30-2 section 5 |
| 8 | `lever` | 30-5 section 2 |
| 9, 10 | `oak_button`, `stone_button` (all 15 buttons) | 30-5 section 3 |
| 11, 12 | `oak_pressure_plate`, `stone_pressure_plate` (all 15 plain plates) | 30-5 section 4 |
| 13, 14 | `light_weighted_pressure_plate`, `heavy_weighted_pressure_plate` | 30-5 section 4 |
| 15 | `sculk_sensor` | this part, 4 |
| 16 | `calibrated_sculk_sensor` | this part, 5 |
| 17 | `sculk_shrieker` | this part, 6 |
| 18 | `amethyst_block` (a vibration resonator target: the tag `vibration_resonators` decides which blocks resonate, section 4.2; no other redstone behaviour) | this part, 4.2 |
| 19 | `white_wool` (wool is in the tag `dampens_vibrations`; membership is data) | this part, 3.5 |
| 20 | `tripwire_hook` | this part, 7 |
| 21 | `string` (item of block `tripwire`) | this part, 7 |
| 22 | `lectern` | 31-4 section 3; analog output 30-2 section 5 |
| 23 | `daylight_detector` | 30-5 section 5 |
| 24 | `lightning_rod`: the waxed unaffected variant (read: `waxed().unaffected()`) | 30-5 section 7 |
| 25, 26 | `piston`, `sticky_piston` | 30-3 |
| 27, 28 | `slime_block`, `honey_block` (stickiness of the structure resolver) | 30-3 section 4 |
| 29, 30 | `dispenser`, `dropper` | 30-4 |
| 31 | `crafter` | 30-4 section 6 |
| 32 | `hopper` | 30-4 section 5 |
| 33 | `chest` | 31-1 section 10; analog output 30-2 section 5 |
| 34 | `copper_chest`: the waxed unaffected variant | 31-1; 30-2 section 5 |
| 35 | `barrel` | 31-1; 30-2 section 5 |
| 36 | `chiseled_bookshelf` | 31 (block entities); 30-2 section 5 |
| 37 | `oak_shelf` (all shelves) | 31-3 section 6 |
| 38 | `furnace` | 31-2; 30-2 section 5 |
| 39 | `trapped_chest` | 31-1 section 10.5; 30-5 |
| 40 | `jukebox` | 31-4 section 2; 30-5 section 9 |
| 41 | `decorated_pot` | 31-3; 30-2 section 5 |
| 42 | `observer` | 30-2 section 6 |
| 43 | `note_block` | 30-5 section 8 |
| 44 | `composter` | 30-2 section 5 |
| 45 | `cauldron` (comparator reading of the filled variants) | 30-2 section 5 |
| 46 | `rail` | 30-6 |
| 47 | `powered_rail` | 30-6 section 5 |
| 48 | `detector_rail` | 30-6 section 6 |
| 49 | `activator_rail` | 30-6 section 5 |
| 50 | `minecart` | 30-6 section 8 |
| 51 | `hopper_minecart` | 30-4 section 5 and 30-6 section 8 |
| 52 | `chest_minecart` | 30-6 section 8; entity 21, 45-8 |
| 53 | `furnace_minecart` | 30-6 section 8; entity 21, 45-8 |
| 54 | `tnt_minecart` (activator rail ignites it) | 30-6 section 8; 21 |
| 55 | `oak_chest_boat` (all chest boats) | no redstone behaviour read; entity 21, 45-8 |
| 56 | `bamboo_chest_raft` | as 55 |
| 57, 58 | `oak_door`, `iron_door` (all doors) | 30-7 |
| 59 | `oak_fence_gate` (all gates) | 30-7 |
| 60, 61 | `oak_trapdoor`, `iron_trapdoor` | 30-7 |
| 62 | `tnt` | this part, 9.1 |
| 63 | `redstone_lamp` | 30-7 |
| 64 | `bell` | this part, 8 |
| 65 | `big_dripleaf` | this part, 9.2 |
| 66 | `armor_stand` (no signal call was found in its class; no signal call was found and no redstone reason for its presence in the tab was read (Open question 10), and a marker armor stand does not trigger tripwires, 7.5) | entity 45-9 section 11 |
| 67 | `redstone_ore` (and `deepslate_redstone_ore`) | 30-1 section 7 |

The table has one row per tab entry (67). Blocks of the family that have no tab item of their own: `redstone_wire` (item `redstone`), `redstone_wall_torch` (item `redstone_torch`), `tripwire` (item `string`), `piston_head` and `moving_piston` (3), `deepslate_redstone_ore` (1), the command, structure, jigsaw and test blocks (31-6), `copper_bulb` variants other than waxed.

Items that belong to the family but are not in the tab (read from the other parts): the dispensable items (30-4 section 3), `repeater` and `comparator` use their items, `redstone` placed as a block, `observer`, and the 15 buttons and plates beyond the representatives.

## 11. Worked examples

### 11.1 A sensor hears a step

Sensor at S (radius 8). A player (not sneaking, standing on a block not in `dampens_vibrations`) steps at the block centre 3 blocks east of S, event `step` (frequency 1, listenable) posted in game tick `T`. Section 2: the event's sections include S's; S is in range (3 squared is at most 64). Section 3.3: valid, no vibration in flight, `canReceiveVibration` true (frequency 1, phase `inactive`), no occluder: candidate (distance 3.0, tick `T`). Tick `T + 1`: chosen, travel time `floor(3.0) = 3`. `T + 1`: 2; `T + 2`: 1; `T + 3`: 0, received. Strength: block distance 3, `floor(1.875 * 3) = 5`, power 10. Activate: phase `active`, `power` 10, `last_vibration_frequency` 1; tick scheduled for `T + 33`; neighbours of S and S-below updated; `sculk_sensor_tendrils_clicking` posted; `sculk_clicking` played. A comparator beside S reads 1. At `T + 33`: `cooldown`, power 0, tick for `T + 43`. At `T + 43`: `inactive`. Events heard during `T + 3` to `T + 43` are ignored (not `inactive`; and an event during `active` while the previous vibration is already received is dropped by `canActivate`).

### 11.2 Calibrated filter

Calibrated sensor C facing south (player faced south when placing), a repeater behind it (north side, `pos.relative(opp(S)) = pos.relative(N)`) outputting 6 into C. `back = 6`. A `shear` (frequency 6) or `entity_mount` or `entity_interact` event within 16 blocks passes the filter; a `step` (1) or `block_open` (10) does not. With the repeater off (`back = 0`) all non-zero events pass. Comparator reading while active = the accepted frequency. C is deaf for 20 ticks after activation.

### 11.3 Tripwire line pulse (hooks A and B, three wires)

A at `P` facing east, wires at `P+1`, `P+2`, `P+3`, B at `P+4` facing west, all idle but attached (`attached` true everywhere, none `powered`). An entity enters the wire at `P+2` in tick `T`:
1. `entityInside`: wire not powered, no tick scheduled: `checkPressed` finds one entity that triggers: set `P+2` to `powered`, run `updateSource`.
2. `updateSource` direction W (the first direction S finds no hook): `i = 1` is a wire, `i = 2` is hook A with `facing` east equal to `opp(W)`: calculation for A with `c = 2`, `W` = the powered wire. Scan: `k = 1` wire, `k = 2` the override (armed, powered): `anyPowered`, a tick for A at `T + 10`, `attached` kept; `k = 3` wire; `k = 4` hook B facing west equal to `opp(E)`: `D = 4`. `attached = true`, `powered = true`.
3. B is set `attached`, `powered` (`facing` west); B's and its support's neighbours notified; transition effects at B: `powered` rose, so `tripwire_click_on` (0.4, 0.6) and `block_activate`. Then the same at A, then A is set and notified. `attached` did not change, so the wires keep `attached` true.
4. Tick `T + 10` (wire `P+2`): the entity is still there: stays powered, tick again at `T + 20`. Tick `T + 10` (hook A): recalculation with the world states: nothing changes, no sound, but both hooks' neighbours are notified.
5. The entity leaves. The wire's next tick finds no entity: `P+2` becomes unpowered, `updateSource` recalculates: `anyPowered` false, so `powered` false: `tripwire_click_off` (0.4, 0.5) and `block_deactivate` at B and at A. (Release happens at the first 10-tick check after the entity left.)
The hook output is 15 on both neighbours while `powered`, so a wire or lamp touching the hooks, and anything touching their support blocks, is lit for that period.

### 11.4 Cutting with and without shears

Same line. Shears in the main hand: `disarmed` true set silently (flags 260), `shear` posted (frequency 6, heard by sensors), then the block is removed; the removal `updateSource` passes the removed state (disarmed) as the changed cell at `c = 2`: `armed` false clears `attached` and `anyPowered` is false: both hooks become `attached` false, `powered` false; `tripwire_detach` plays (the line detaches). No `click_on`. Without shears: the removal state is passed with `powered` forced true and `disarmed` false: `anyPowered` true, `attached` true (the changed cell counts as present), so both hooks become `powered` (click on), a tick is scheduled at `T + 10`; at that tick the scan finds a gap at `k = 2`: `attached` false and `powered` false, both hooks click off, then detach plays (`wasAttached` true, `attached` false). So a plain cut sends a short pulse of about 10 ticks.

### 11.5 Bell

A floor bell facing north gets a signal rising edge in tick `T`: `neighborChanged`, `hasNeighborSignal` true, `powered` false: `attemptToRing(level, pos, none)`: direction = `facing` (north); block entity `onHit(north)`: shaking, event queued; sound `bell_block` volume 2.0; `block_change` posted at the bell (frequency 11); `powered` set true. A second neighbour update with the signal still present changes nothing. When the signal drops: `powered` false, no ring. A player striking the east face of this bell does not ring it (axes differ from the floor rule); striking the north face at relative height 0.85 does not ring either (above 0.8124).

### 11.6 TNT and dripleaf

TNT placed next to a lit lamp-driven wire (a powered neighbour): `onPlace`: `hasNeighborSignal` true: `prime` creates the entity at `(x + 0.5, y, z + 0.5)`, plays `tnt_primed`, posts `prime_fuse`, and the block is removed. A TNT block exploded by a neighbouring TNT's explosion yields a primed entity with a fuse of 10 to 29 ticks. A big dripleaf stepped on at `T` (entity on the ground above `pos.y + 0.6875`, no neighbour signal): `unstable` at `T` (silent), `partial` at `T + 10` (tilt down sound, `block_change`), `full` at `T + 20` (tilt down sound, `block_change`, collision removed per 24), back to `none` at `T + 120` (tilt up sound, `block_change`). If a signal reaches it before `T + 120`: the next neighbour update resets it to `none` at once.

## 12. Validation

| # | Check | Expected |
|---|---|---|
| V1 | Sensor, distance 3, `step` (section 11.1) | active at `T + 3`, power 10, comparator 1, inactive at `T + 43` |
| V2 | Strength table 3.2 | radius 8: d 0 gives 15, 1 gives 14, 2 gives 12, 3 gives 10, 4 gives 8, 5 gives 6, 6 gives 4, 7 gives 2, 8 gives 1 |
| V3 | Strength, radius 16 | d 0 and 1 give 15; 4 gives 12; 8 gives 8; 16 gives 1 |
| V4 | Frequency of `note_block_play`, `block_attach`, `prime_fuse`, `block_activate`, `block_open`, `container_open` | all 10 |
| V5 | Frequency of `shriek`, `sculk_sensor_tendrils_clicking`, `jukebox_play`, `item_interact_start` | 0 (a sensor never receives them) |
| V6 | Two events in the same tick at equal distance with frequencies 3 and 8 | the frequency 8 candidate is kept |
| V7 | An event in tick `T`, sensor ticker in tick `T` | not chosen in tick `T` (needs candidate tick strictly earlier) |
| V8 | Event with distance 0.4 | travel 0, received in tick `T + 1` |
| V9 | Sneaking player steps next to a sensor | ignored (`step` is in `ignore_vibrations_sneaking`); advancement `avoid_vibration` fires |
| V10 | Step on a block in `dampens_vibrations` | ignored |
| V11 | All six occlusion rays hit occluders | ignored; one clear ray lets it pass |
| V12 | Calibrated, back signal 6, event of frequency 6 and of frequency 5 | 6 accepted, 5 rejected |
| V13 | Calibrated sensor output toward its `facing` side | 0 (the back input side gets no output); other sides `power` |
| V14 | Sensor `getDirectSignal` for `UP` versus `N` | `power` versus 0 |
| V15 | Sensor deaf period | 40 ticks (sensor), 20 ticks (calibrated) from activation |
| V16 | Resonance pitch for frequency 1, 8, 15 | 0.5, 1.0, 4.0 |
| V17 | Shrieker, `can_summon` false, a player steps on it | `shrieking` true for 90 ticks, `shriek` posted, no warden logic runs (`canRespond` false: no warning, still shrieks) |
| V18 | Hook line of 2 hooks with 40 wires between (hooks 41 apart) | attached (scan reaches `k = 41`); with 41 wires (hooks 42 apart) the scan ends at `k = 41` without finding the far hook: `D = 0` |
| V19 | Wire press and release | powered the tick of entry; rechecked every 10 ticks; released at the first check without an entity, 0 to 10 ticks after the last entity left |
| V20 | Wire cut with shears versus without (11.4) | no pulse versus a pulse of about 10 ticks |
| V21 | Bell hit: floor bell facing north, east face | no ring; north face at 0.5 relative height rings; at 0.85 does not |
| V22 | Bell redstone | rings on the rising edge only; `powered` follows the signal |
| V23 | Bell resonance with a raider within 32 | resonance starts when `ticks >= 5`, ends 40 ticks later with `glowing` 60 ticks on raiders within 48 |
| V24 | TNT with a powered neighbour at placement | primes at once; block removed |
| V25 | Big dripleaf stepped on | tilt 10, 10, 100 ticks; powered leaf stays flat |
| V26 | Event counting | 61 game events; notification radius 16 except 10 (jukebox play and stop) and 32 (`shriek`) |

## 13. Open questions

1. **Tab variants.** The redstone tab lists only representative variants (one button, one plate, white wool, one door family member, waxed copper variants). Whether the client's creative tab search or a separate mechanism shows the rest was not read; the full families are the ownership of their classes (24, 25).
2. **Copper bulb count.** The four-state expansion of the waxed copper bulb collection (`ByState.forEach`) is inferred from the name; the `ByState` class was not read.
3. **Spectators and the inside-block pass.** The wire's `tick` path filters spectators (default entity query); whether spectators ever enter the inside-block pass of `entityInside` was not read (inferred: they do not collide).
4. **Block-entity versus event order inside one game tick.** The statement "chosen in tick `T + 1` at the earliest" holds for either order (candidate tick strictly earlier); the position of block-entity ticking and entity ticking inside a tick is 33 section 2.
5. **`Level.isBlockInLine` (occlusion).** The ray semantics (first matching block along the segment, result type BLOCK when found) is inferred from the call and the result test; the clip algorithm itself was not read here. 31-8 section 3.6 holds the same inference.
6. **`WardenSpawnTracker.tryWarn` and `Warden.applyDarknessAround`.** Not re-read here; 44-x2 section 2 owns them.
7. **`Entity.stepOn` call conditions** (which entities and ground states reach `SculkSensorBlock.stepOn` and `SculkShriekerBlock.stepOn`, including the sneaking and flying cases) were not read; they are an entity-movement rule (33 or 13).
8. **Experimental redstone evaluator.** The orientation passed by `notifyNeighbors` (`ExperimentalRedstoneUtils.initialOrientation`) matters only under the `redstone_experiments` flag (30-1 section 2.7); its construction was not read.
9. **Registry data not tabulated.** Memberships of the six tags and of `raiders`, the `vibration` and `sculk_clicking` sound entries and the pitch of those events come from the data and resource packs.
10. **Armor stand in the tab.** No reason for its presence was found in code (no signal call); it may be a pure creative-tab placement choice (recalled, not verified).
11. **Hook scan bound.** The artifact scans `k = 1` to 41 with a 42-entry array, so two hooks may be at most 41 blocks apart. 24-4 section 6.26 also states 1 to 41.
12. **`ByState`, `ColorCollection` accessors** (`waxed`, `unaffected`, `white`) were read as calls; their return values (which concrete items) are registry matters (25).
13. **Bell client-side effects** (model, particle colours) are 31-4 section 4; this part restates only the end-action contract.
14. **`can_summon` in ancient cities.** 6.1 says structure data sets `can_summon` for ancient-city shriekers; this is a worldgen matter and was not read (recalled, not verified). Searched: the `SculkShriekerBlock` class only (the property default and constructor); structure and template data were not searched.
