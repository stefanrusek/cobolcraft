# 30 (part 8). Redstone: tripwire, sculk sensors, sculk shrieker, bell, the vibration dispatch, and the catch-all inventory

| | |
|---|---|
| Covers | The redstone-facing behaviour of `TripWireBlock` and `TripWireHookBlock` (string line, `attached`, `powered`, `disarmed`, shears, the hook line search, entity detection, the 10-tick refresh, sounds and game events); `SculkSensorBlock`, `CalibratedSculkSensorBlock`, `SculkSensorPhase` and the sensor block entities (game-event frequency table, ranges, phases, cooldown, signal strength by distance, waterlogging, calibrated input side and frequency filter, comparator output, resonance); `SculkShriekerBlock` (redstone-facing parts only: `can_summon`, `shrieking`, vibration reaction); `BellBlock` and `BellBlockEntity` (attachment types, power ringing, hit-direction rule, resonance and raid detection); the game-event dispatch these blocks use; and the catch-all for the redstone-category blocks no other part owns (`TntBlock`, the redstone-facing part of `BigDripleafBlock`), ending with an inventory of every item and block in the redstone creative tab and the part that covers it. It also holds the member lists of the six vibration tags (3.5.1), the exact occlusion rule (3.6, with 31-8 3.6) and section 14, the emission rules of movement events, projectile events and every poster of the entity-related game events. `SculkCatalystBlock` is excluded (31-8, 35). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS12 part 8 (GAP-10c of `../design/README.md` Part 5) |
| Data versus code | Block registry rows (ids, state layouts, shapes) are 24 and are not repeated beyond what a rule needs. The vibration tags are tabulated in 3.5.1. Tags, loot tables, recipes, sounds and models are otherwise data and are not tabulated: the game-event tags `vibrations`, `shrieker_can_listen`, `ignore_vibrations_sneaking`, the block tags `dampens_vibrations` and the item tag `dampens_vibrations` (the latter read as the four wool tags `wool`, `wool_carpets`, `wool_slabs`, `wool_stairs`), `occludes_vibration_signals`, `vibration_resonators`, the entity-type tag `raiders`. This document specifies the code that interprets them and every code-defined constant. |
| Siblings | Parts of this family are cited as `30-N section M` (never a bare `N section M`, which would read as document 0N). 30-1 (signal model, queries, update order), 30-2 (repeaters, comparators, observers; comparators read the sensor, section 4.7), 30-3 (pistons), 30-4 (dispensers, hoppers, crafters), 30-5 (levers, plates, daylight, note block), 30-6 (rails), 30-7 (doors, trapdoors, gates, lamps, copper bulbs), all in `docs/protocol/`. Numbered documents 00 to 47 are cited `NN section M`. |
| Overlap with other documents | 31-8 sections 2 to 6 (game-event dispatch, the vibration system, sensor, calibrated sensor, shrieker block-entity side), 31-4 section 4 (bell block entity and block side) and 24-4 sections 6.26, 6.27 (tripwire) were written in parallel rounds. This part re-reads the same classes independently, restates the rules from the redstone side (power, timing, worked examples, validation vectors), and records where it agrees. No disagreement was found; a point that this reading adds or words differently is flagged "(adds)". |

"Read" means read in the artifact. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. All times are game ticks (20 per second). Directions: `N`, `E`, `S`, `W`, `U`, `D`; `opp(d)` is the opposite. Receiver and asked-block language follows 30-1 section 2.2: a receiver at `R` asks the block at `R + d` with the argument `d`.

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
14. Game-event emission by entities, projectiles and actors (movement, projectiles, event sources)
15. Open questions (game-event emission)

## 0. Reader's map

| Question | Section |
|---|---|
| Ids, states, delays and sounds of the blocks of this part | 1 |
| Which events reach a listener, in which order, how far | 2 |
| The frequency of every game event; strength by distance; travel time | 3.1 to 3.4 |
| Which vibrations a sensor ignores (sneaking, wool, occlusion) | 3.5, 3.6 |
| Member lists of the game-event, block and item tags and the event versus tag matrix | 3.5.1 |
| Exact line-of-sight rule of the occlusion test | 3.6 and 31-8 3.6.1 to 3.6.6 |
| Who posts `step`, `swim`, `flap`, `hit_ground`, `splash`, `bounce`, `elytra_glide`, mount and dismount events, where and with which context | 14.1 |
| Projectile events (`projectile_shoot`, `projectile_land`) | 14.2 |
| Posters of `entity_damage`, `entity_die`, `entity_place`, `block_place`, `block_destroy` and the other events, with position and source entity | 14.3 |
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

### 3.5.1 The member lists of the six tags

Read from the data files of the artifact of `README.md` (`data/minecraft/tags/game_event/*.json`, `data/minecraft/tags/block/dampens_vibrations.json`, `occludes_vibration_signals.json`, `vibration_resonators.json` and `data/minecraft/tags/item/dampens_vibrations.json`). The tag names containing "vibration" are exactly these (two game-event tags, three block tags, one item tag; the advancement `adventure/avoid_vibration` is not a tag). The game-event registry order below is the order of the `GameEvent` initializer (index 0 to 60); frequencies are those of section 3.1.

**Game-event tags** (`V` = `vibrations`, `W` = `warden_can_listen`, `I` = `ignore_vibrations_sneaking`, `S` = `shrieker_can_listen`, `A` = `allay_can_listen`; Y = member after resolving nested `#` references, - = not a member):

| Flat size (explicit entries in the file) | Tag |
|---|---|
| 56 (56, no nesting) | `vibrations`: every event with a non-zero frequency |
| 57 (57 entries: 56 events plus the reference `#minecraft:shrieker_can_listen`) | `warden_can_listen` = `vibrations` minus `flap`, plus `shriek` and (through the nested tag) `sculk_sensor_tendrils_clicking` |
| 6 (6) | `ignore_vibrations_sneaking`: `hit_ground`, `projectile_shoot`, `step`, `swim`, `item_interact_start`, `item_interact_finish` |
| 1 (1) | `shrieker_can_listen`: `sculk_sensor_tendrils_clicking` |
| 1 (1) | `allay_can_listen`: `note_block_play` |

| Index | Event | Freq | V | W | I | S | A |
|---|---|---|---|---|---|---|---|
| 0 | `block_activate` | 10 | Y | Y | - | - | - |
| 1 | `block_attach` | 10 | Y | Y | - | - | - |
| 2 | `block_change` | 11 | Y | Y | - | - | - |
| 3 | `block_close` | 9 | Y | Y | - | - | - |
| 4 | `block_deactivate` | 9 | Y | Y | - | - | - |
| 5 | `block_destroy` | 12 | Y | Y | - | - | - |
| 6 | `block_detach` | 9 | Y | Y | - | - | - |
| 7 | `block_open` | 10 | Y | Y | - | - | - |
| 8 | `block_place` | 13 | Y | Y | - | - | - |
| 9 | `bounce` | 2 | Y | Y | - | - | - |
| 10 | `container_close` | 9 | Y | Y | - | - | - |
| 11 | `container_open` | 10 | Y | Y | - | - | - |
| 12 | `drink` | 8 | Y | Y | - | - | - |
| 13 | `eat` | 8 | Y | Y | - | - | - |
| 14 | `elytra_glide` | 4 | Y | Y | - | - | - |
| 15 | `entity_damage` | 7 | Y | Y | - | - | - |
| 16 | `entity_die` | 15 | Y | Y | - | - | - |
| 17 | `entity_dismount` | 5 | Y | Y | - | - | - |
| 18 | `entity_interact` | 6 | Y | Y | - | - | - |
| 19 | `entity_mount` | 6 | Y | Y | - | - | - |
| 20 | `entity_place` | 14 | Y | Y | - | - | - |
| 21 | `entity_action` | 4 | Y | Y | - | - | - |
| 22 | `equip` | 5 | Y | Y | - | - | - |
| 23 | `explode` | 15 | Y | Y | - | - | - |
| 24 | `flap` | 1 | Y | - | - | - | - |
| 25 | `fluid_pickup` | 12 | Y | Y | - | - | - |
| 26 | `fluid_place` | 13 | Y | Y | - | - | - |
| 27 | `hit_ground` | 2 | Y | Y | Y | - | - |
| 28 | `instrument_play` | 3 | Y | Y | - | - | - |
| 29 | `item_interact_finish` | 3 | Y | Y | Y | - | - |
| 30 | `item_interact_start` | 0 | - | - | Y | - | - |
| 31 | `jukebox_play` | 0 | - | - | - | - | - |
| 32 | `jukebox_stop_play` | 0 | - | - | - | - | - |
| 33 | `lightning_strike` | 14 | Y | Y | - | - | - |
| 34 | `note_block_play` | 10 | Y | Y | - | - | Y |
| 35 | `prime_fuse` | 10 | Y | Y | - | - | - |
| 36 | `projectile_land` | 2 | Y | Y | - | - | - |
| 37 | `projectile_shoot` | 3 | Y | Y | Y | - | - |
| 38 | `sculk_sensor_tendrils_clicking` | 0 | - | Y | - | Y | - |
| 39 | `shear` | 6 | Y | Y | - | - | - |
| 40 | `shriek` | 0 | - | Y | - | - | - |
| 41 | `splash` | 2 | Y | Y | - | - | - |
| 42 | `step` | 1 | Y | Y | Y | - | - |
| 43 | `swim` | 1 | Y | Y | Y | - | - |
| 44 | `teleport` | 14 | Y | Y | - | - | - |
| 45 | `unequip` | 4 | Y | Y | - | - | - |
| 46 to 60 | `resonate_1` to `resonate_15` (frequency `n`) | n | Y | Y | - | - | - |

Rows that differ from the pattern "member of `vibrations` and `warden_can_listen`, nothing else":

- only in `vibrations` (the warden does not hear it): `flap`;
- only in `warden_can_listen` (not in `vibrations`): `shriek`; and `sculk_sensor_tendrils_clicking`, which is also the one member of `shrieker_can_listen` (a sensor never hears either of them, and a shrieker hears only the tendrils event);
- in `ignore_vibrations_sneaking`: `hit_ground`, `projectile_shoot`, `step`, `swim` and `item_interact_finish` (all also in `vibrations` and `warden_can_listen`), and `item_interact_start` (in none of the three listening tags, so the entry has no effect on the sensors or the warden);
- only `note_block_play` is in `allay_can_listen` (it is also in the other two listening tags);
- in no tag at all: `jukebox_play` and `jukebox_stop_play` (the allay reacts to them through its own listener, not through a tag);
- the 15 `resonate_n` events are in `vibrations` and `warden_can_listen` only.

The shrieker's reaction to an ordinary event never happens through the tag lists of the warden: its `User` listens to `shrieker_can_listen` only (section 6.2).

**Block tags.**

| Tag | Explicit entries | Flat members | Members |
|---|---|---|---|
| `dampens_vibrations` | 4 references | 64 | `#wool` (16 wool blocks), `#wool_carpets` (16 carpets), `#wool_slabs` (16 wool slabs), `#wool_stairs` (16 wool stairs); the colours are white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black, and the block names are `<colour>_wool`, `<colour>_carpet`, `<colour>_wool_slab`, `<colour>_wool_stairs` |
| `occludes_vibration_signals` | 1 reference | 16 | `#wool` only (the 16 `<colour>_wool` blocks; carpets, wool slabs and wool stairs are not in this tag) |
| `vibration_resonators` | 1 | 1 | `amethyst_block` |

`occludes_vibration_signals` (16) is a subset of `dampens_vibrations` (64); the 48 members of `dampens_vibrations` that do not occlude are the carpets, wool slabs and wool stairs.

**Item tag `dampens_vibrations`**: the same four references `#wool`, `#wool_carpets`, `#wool_slabs`, `#wool_stairs` resolved in the item tag namespace (`data/minecraft/tags/item/wool*.json`, 16 items each), 64 members. It is read only by `ItemEntity.dampensVibrations` (an item entity whose stack is in the tag is silent as a vibration source, section 3.5).

**Who reads which tag.** `VibrationSystem$User.isValidVibration` (section 3.5) reads `ignore_vibrations_sneaking` and `dampens_vibrations` (block); the listenable tag is `vibrations` for the sensors and the allay's vibration user reads `allay_can_listen`, the shrieker `shrieker_can_listen`, the warden `warden_can_listen` (class references found: `VibrationSystem$User`, `VibrationSystem$Listener`, `Warden$VibrationUser`, `SculkShriekerBlockEntity$VibrationUser`, `Allay$VibrationUser`, `ItemEntity`, plus the data generators `GameEventTagsProvider` and the block and item tag providers).

**Crouching cats and ocelots (confirmed).** `Cat` and `Ocelot` override `isSteppingCarefully` as "the pose is `CROUCHING`, or the base rule", the base rule being the shift-key flag. A crouching cat or ocelot therefore makes every event in `ignore_vibrations_sneaking` invalid while it is the context's source entity. The six events can be posted by such a mob as follows: `step` and `swim` (movement, 14.1), `hit_ground` (landing, 14.1.7); the other three need a projectile or an item use, which a cat does not do. Other entities that crouch (a fox sets its own crouching flag; its `isSteppingCarefully` is not overridden, so a crouching fox is not "careful") are not silenced. The pose change of the cat does not stop its movement events (the sneak rule of 14.1.10 about the emission applies only to players), so a crouching cat still posts them and it is the sensor that discards them.

### 3.6 Occlusion (`VibrationSystem$Listener.isOccluded`)

Both the event position and the listener position are first snapped to their block centres (`floor(coordinate) + 0.5` per axis). For each of the six directions `d` (order DOWN, UP, NORTH, SOUTH, WEST, EAST) the start point is the snapped event centre moved 0.00001 (9.999999747378752E-6 in the read constant) along `d`; a ray from that point to the snapped listener centre is tested for the first block state in block tag `occludes_vibration_signals` (the level's block-in-line query). The vibration is occluded only when **all six** rays meet such a block: a single clear ray lets it through.

The exact semantics: the traversal visits the **start cell and the end cell and every cell between**; the per-cell test is a tag test on the block state only (no shape test); the tag holds only the 16 wool blocks (3.5.1), so carpets, wool slabs and wool stairs dampen a step on them (3.5) but do not occlude; the traversal's tie-break (Z over Y over X) and the six offsets together decide the diagonal and corner cases. The full algorithm, the combination of the six rays and worked examples (a wool block at distance 3 on one axis, a diagonal, a corner-touching case) are in 31-8 sections 3.6.1 to 3.6.6.

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
5. **`Level.isBlockInLine` (occlusion).** (answered: the traversal, the per-cell test and the six-ray rule are in 31-8 sections 3.6.1 to 3.6.6.)
6. **`WardenSpawnTracker.tryWarn` and `Warden.applyDarknessAround`.** Not re-read here; 44-x2 section 2 owns them.
7. **`Entity.stepOn` call conditions** (answered in 14.1.11: every tick, for an on-ground entity without `noPhysics`, on the block at `getOnPosLegacy()`, with no sneaking or flying test; the movement-event rules are 14.1).
8. **Experimental redstone evaluator.** The orientation passed by `notifyNeighbors` (`ExperimentalRedstoneUtils.initialOrientation`) matters only under the `redstone_experiments` flag (30-1 section 2.7); its construction was not read.
9. **Registry data not tabulated.** Memberships of the six tags and of `raiders`, the `vibration` and `sculk_clicking` sound entries and the pitch of those events come from the data and resource packs. (answered for the game-event, block and item vibration tags in 3.5.1.)
10. **Armor stand in the tab.** No reason for its presence was found in code (no signal call); it may be a pure creative-tab placement choice (recalled, not verified).
11. **Hook scan bound.** The artifact scans `k = 1` to 41 with a 42-entry array, so two hooks may be at most 41 blocks apart. 24-4 section 6.26 also states 1 to 41.
12. **`ByState`, `ColorCollection` accessors** (`waxed`, `unaffected`, `white`) were read as calls; their return values (which concrete items) are registry matters (25).
13. **Bell client-side effects** (model, particle colours) are 31-4 section 4; this part restates only the end-action contract.
14. **`can_summon` in ancient cities.** 6.1 says structure data sets `can_summon` for ancient-city shriekers; this is a worldgen matter and was not read (recalled, not verified). Searched: the `SculkShriekerBlock` class only (the property default and constructor); structure and template data were not searched.

## 14. Game-event emission by entities, projectiles and actors

Sections 2 and 3 say what happens after an event has been posted. This section says **who posts which event, where, and with which context**, as read from the classes of the artifact of `README.md` (`javap -c -p -constants`, no execution). Everything here is server-side: a client level does not dispatch (section 2.1), and all the movement rules below run on the server for every entity, including players (whose movement arrives as packets, 14.1.1). "Read" and "(inferred)" have the meanings given at the top of this document; "Open question N" refers to section 15.

### 14.0 Posting forms and vocabulary

Every post is one of these forms. "Position" is the exact `Vec3` handed to the dispatcher (section 2.1 step 3); the dispatcher converts it with `BlockPos.containing` to choose sections and ranges, and the sensor uses the exact value for the travel time and the block-snapped value for occlusion (section 3.6).

| Form (names are where it was read) | Position | Context source entity | Context affected state |
|---|---|---|---|
| `Entity.gameEvent(event)` | the entity's own position (`position()`: x, y at the feet, z) | the entity itself | none |
| `Entity.gameEvent(event, other)` | the entity's own position | `other`, which may be null (then the context has no source) | none |
| `Level.gameEvent(entity, event, Vec3)` | that `Vec3` | `entity`, may be null | none |
| `Level.gameEvent(entity, event, BlockPos)` | the block centre (`Vec3.atCenterOf`) | `entity`, may be null | none |
| `Level.gameEvent(event, Vec3, Context)` and `(event, BlockPos, Context)` | that `Vec3`, or the block centre | as given by the context | as given by the context |

Two kinds of entity occur in a damage or projectile situation and the artifact distinguishes them: the **direct** entity (the arrow, the TNT, the entity physically involved; `DamageSource.getDirectEntity`) and the **causing** entity (the owner or attacker, `DamageSource.getEntity`). The rule for each event below says which one goes into the context; the warden then derives "projectile owner" from the context's source entity when that entity is a projectile with an owner (20 section 15, Vibrations paragraph; section 6.2 for the shrieker), so a projectile as source entity is how the warden learns who shot.

### 14.1 Movement events (`step`, `swim`, `flap`, `hit_ground`, `splash`, `bounce`, `elytra_glide`, `entity_mount`, `entity_dismount`)

#### 14.1.1 Where the movement pipeline runs

Everything starts in `Entity.move(moverType, movement)`. In order:

1. An entity with `noPhysics` (a spectator player, or any entity whose flag is set) only has the movement added to its position and the method ends: **no collision, no fall handling, no movement events, no `stepOn` (14.1.11)**.
2. Otherwise the movement is limited (pistons), scaled or zeroed by the stuck-speed multiplier (cobweb and the like), moved back from an edge (a sneaking player does not walk off an edge, `maybeBackOffFromEdge`) and resolved against collisions; the resolved vector is called `m` below (the **collided movement**). The position is set to `position + m` when `|m|^2 > 1.0E-7`, or when the squared length of the wanted movement exceeds `|m|^2` by less than 1.0E-7; a wanted move that is almost completely blocked (`|m|^2 <= 1.0E-7` while the wanted squared length is larger by 1.0E-7 or more) leaves the position unchanged. Before the position is set, when `fallDistance` is not 0 and `|m| >= 1`, a clip ray from the position along `m` (length `min(|m|, 8)`, clip type "fall-damage-resetting" for blocks, water for fluids) that hits anything resets the fall distance.
3. The horizontal collision flag is set when the resolved x or z differs from the wanted one (the wanted movement is the one after the edge back-off; the comparison is `Mth.equal`, a tolerance test). The vertical flags and the on-ground flag are updated **only when the wanted movement has a non-zero y component, or when the entity is locally authoritative on the server** (step 4 defines "authoritative"; players and ridden vehicles are not): then `verticalCollision` is true when the resolved y differs from the wanted y, `verticalCollisionBelow` is `verticalCollision` with a wanted y below 0, and `onGround` is set to `verticalCollisionBelow` through `setOnGroundWithMovement(verticalCollisionBelow, horizontalCollision, m)`, which also recomputes the supporting block (14.1.3). When the wanted y is exactly 0 and the entity is not authoritative (a player or ridden vehicle replaying a packet whose vertical displacement is 0), none of this runs: `onGround`, the vertical flags and the supporting block keep the values left by the previous call or packet.
4. `checkFallDamage(m.y, onGround, stateAt(legacy cell), legacy cell)` runs **only when the entity is locally authoritative on the server**: `isLocalInstanceAuthoritative` is `!isClientAuthoritative` on a server, and `isClientAuthoritative` is true for every `Player` and for any entity whose controlling passenger is client-authoritative (a ridden horse or boat). So for a player or a ridden vehicle this call is **skipped inside `move`** and made by the packet handler instead (14.1.7).
5. If the entity was removed during the fall handling the method ends. Otherwise the restitution step runs (`restituteMovementAfterCollisions`: bounce, 14.1.9) when `canSimulateMovement()` is true **and** ((the wanted y is not 0 and `verticalCollision`) or `horizontalCollision`). `canSimulateMovement` follows the entity's move-simulation type: true for the server-and-client simulated entities (`ItemEntity`, `PrimedTnt`, `FallingBlockEntity`, `ExperienceOrb`, `EnderDragon`, every `Projectile`), `isLocalInstanceAuthoritative` for the default type, and true on a server for `Player` (type authoritative-side-and-server), so a player's server replay can bounce.
6. **Movement emission**: when the level is a server level (or the entity is locally authoritative on a client), `getMovementEmission().emitsAnything()` is true and the entity is **not a passenger**, `applyMovementEmissionAndPlaySound(emission, m, legacy cell, legacy state)` runs (14.1.4). A passenger never runs it: the vehicle posts instead (14.1.10).
7. The block speed factor scales the stored velocity.

Who calls `move`:

- **Players.** `ServerGamePacketListenerImpl.handleMovePlayer` (for the position-carrying packets) calls `ServerPlayer.move(PLAYER, delta)` where `delta` = the packet position minus the last accepted position (`lastGood`), subject to the checks of the handler: a packet rejected **before** the replay for moving too fast teleports the player back and posts nothing; a movement whose final position collides with the world is teleported back **after** the replay, so the events of the replay were already posted (the fall handling and the removal of the latest movement recording still run). So the movement events of a player are produced by the **server's own collision-resolved replay** of the packet displacement, after which the server snaps the player to the packet position (`absSnapTo`), applies `setOnGroundWithMovement(packet.onGround, packet.horizontalCollision, positionDelta)` and then `doCheckFallDamage(dx, dy, dz, packet.onGround)` (14.1.7), where `(dx, dy, dz)` is the player's position after that snap minus its position when the handler started (before the replay), and finally, when the packet's vertical displacement (packet y minus the last accepted y) is greater than 0, `resetFallDistance()`. The packet coordinates are first clamped: x and z to [-3.0E7, 3.0E7], y to [-2.0E7, 2.0E7]; packets containing NaN or non-finite values disconnect the player. Consequences: the position of a `step` event is the player's position after the server-side replay and before the snap; the on-ground flag used by the emission test (14.1.4) is the one the replay computed (`verticalCollisionBelow`) when the packet's vertical displacement is not 0, and **the flag left by the latest earlier write** when the vertical displacement is exactly 0 (step 3 above): either the previous packet's `setOnGroundWithMovement(packet.onGround, ...)` or the player's own server-side self-simulation of a later tick (next bullets); the fall handling uses the current packet's flag.
- **Players, the server's own tick.** Every server tick `ServerPlayer` also runs `aiStep` every tick (from `LivingEntity.tick`; `ServerPlayer` overrides neither `aiStep` nor `travel`, but `Player` overrides both: `Player.aiStep` calls the living-entity `aiStep`, and `Player.travel` has passenger, swimming and flying branches, each of which ends in the living-entity travel pipeline, with the swimming and flying branches adjusting `deltaMovement` around it). `Player.isEffectiveAi()` is true on a server and `canSimulateMovement()` is true for a `Player` on a server, so `aiStep` calls `travel` with the input vector (`xxa`, `yya`, `zza`), which is **always zero on the server** (no packet handler writes these fields; `applyInput` only scales them by 0.98). The movement is therefore driven only by the server's own `deltaMovement` (gravity, friction, impulses such as knockback): no handler writes it from packets (`setDeltaMovement` does not occur in `ServerGamePacketListenerImpl` or `ServerPlayer`; the handler stores only the client's last movement for the attack code). `travel` ends in `Entity.move(SELF, deltaMovement)`: the same pipeline with the wanted y non-zero (gravity), so **this call recomputes the vertical flags and `onGround` every tick** (step 3), and the emission pass runs again with its own collided movement `m`. On flat ground that `m` is 0, adds nothing to `moveDist`, but the pass still evaluates 14.1.4 and can post a pending event if `moveDist > nextStep`; in the air it adds `v3` to `flyDist`. The fall handling is not run for it (step 4: players are client-authoritative), and `applyEffectsFromBlocks` (14.1.11) runs after it.
- **End to end, a player walking on flat ground at normal speed.** Per server tick: one self-simulation pass with `m` = 0 (no counter advance), and per received movement packet one replay pass with the packet's collided horizontal displacement, which adds 0.6 x its horizontal length to `moveDist`. `step` is posted in the replay pass of the packet that makes `moveDist` exceed `nextStep`, provided the on-ground flag is true at that moment. With a vertical displacement of 0 that flag is the **latest write** among (a) the self-simulation of the most recent server tick (on flat ground gravity makes it recompute `onGround` true) and (b) the previous packet's `setOnGroundWithMovement(packet.onGround, ...)`; with a non-zero vertical displacement it is the replay's own `verticalCollisionBelow`. Which of (a) and (b) is later in a given server tick depends on when the queued packet handler runs relative to `tickChildren` (Open question 17). A player standing still posts nothing (`m` = 0 in both passes).
- **First packet after joining.** A new player has `onGround` false, no supporting block and `onGroundNoBlocks` false (a fresh `Entity`). A player loaded from saved data has `onGround` = the saved `OnGround` value (default false when absent) written directly into the field, so the supporting block stays empty until `setOnGround` or `setOnGroundWithMovement` next runs; the first self-simulation tick (non-zero wanted y) or the first replay with a non-zero vertical displacement then recomputes both.
- **Vehicles controlled by a player.** `handleMoveVehicle` calls `vehicle.move(PLAYER, delta)` (emission by the vehicle), then sets the on-ground flag from the packet and calls `doCheckFallDamage` for the vehicle.
- **Mobs and everything else.** `LivingEntity.travel` (called from `aiStep` when `canSimulateMovement()` and `isEffectiveAi()`) and the tick code of each class (boats, minecarts, the dragon, fireworks, fishing hooks, items, TNT, falling blocks, experience orbs) call `move`. Arrows, thrown projectiles and hurting projectiles set their position directly and **never call `move`**, so they never post movement events.

#### 14.1.2 Movement emission classes

`Entity.getMovementEmission()` returns one of four values: `NONE`, `SOUNDS`, `EVENTS`, `ALL` (`emitsEvents` is true for `EVENTS` and `ALL`, `emitsSounds` for `SOUNDS` and `ALL`, `emitsAnything` for the three non-`NONE` ones). The default is `ALL`.

| Emission | Entity classes (and their subclasses) |
|---|---|
| `NONE` | `EndCrystal`, `FallingBlockEntity`, `ExperienceOrb`, `PrimedTnt`, `ItemEntity`, `Shulker`, `AbstractArrow`, `FishingHook` |
| `EVENTS` (events, no step sounds) | `Bat`, `Squid`, `Breeze`, `Endermite`, `Guardian`, `Silverfish`, `AbstractBoat`, `AbstractMinecart` |
| `NONE` or `ALL` by state | `Player`: `NONE` when `abilities.flying` is true, or when the player is on the ground (`onGround()`) and sneaking (`isDiscrete()` = the shift-key flag); `ALL` otherwise |
| `ALL` (default) | every other class, including `FireworkRocketEntity` (it calls `move`), the dragon, all land, water and air mobs not listed above, `Warden`, `Creaking`, cats, horses |
| `SOUNDS` | no class returns it |

A `NONE` entity runs no emission pass at all: `moveDist` does not advance (14.1.3). In particular **a player who is sneaking on the ground, or flying in creative or spectator-style flight, posts no `step`, `swim` or `flap` event** and does not even accumulate walked distance; a sneaking player in the air (a jump with the sneak key held) is `ALL` again. The `ignore_vibrations_sneaking` filter of section 3.5 therefore only matters for sneaking players when they are in the air or in water, for the events not tied to the emission (landing, item use, shooting), and for cats and ocelots (section 3.5.1).

#### 14.1.3 Counters, constants and the two "on" cells

Fields of `Entity` (all `float`): `moveDist` (starts 0), `flyDist` (starts 0), `nextStep` (starts **1.0**). In the artifact's world and server classes they are written only by the emission pass below (every `putfield` of the three fields was searched): no teleport, dimension change, respawn or mounting resets them. (The client keeps a separate `walkDist` for the view bob: 53 section 15.2.)

One emission pass receives `m` (the collided movement):

- `v3` = `(float)(|m| x 0.6000000238418579)` (the double constant is the float 0.6 widened; `|m|` is the three-dimensional length);
- `vh` = `(float)(horizontalLength(m) x 0.6000000238418579)`;
- `moveDist = moveDist + (climbable ? v3 : vh)`; `flyDist = flyDist + v3`; both in float arithmetic;
- `climbable` is true when the state of the `getOnPos` cell is in block tag `climbable` or is `powder_snow` (`isStateClimbable`).

`nextStep()` computes the next threshold: by default `(float)((int)moveDist + 1)` (the next integer above the current `moveDist`, truncating toward zero). Overrides: `Turtle` `moveDist + 0.15`, `Warden` `moveDist + 0.55`, `Strider` `moveDist + 0.6`.

The two cells (both are block cells of the entity's surroundings, used to look up the stepped-on state):

- `getOnPos()` is `getOnPos(1.0E-5)`: when the entity has a **main supporting block** (below) that cell, else the cell containing `(x, y - 1.0E-5, z)`.
- `getOnPosLegacy()` is `getOnPos(0.2)`: when a main supporting block exists and its state is a fence, a wall or a fence gate (fences count only for offsets of 0.5 or less, true here) that supporting cell; when it exists and is anything else, the supporting cell's column with `y = floor(entityY - 0.2)` (so for a thin block such as a carpet, which is 0.0625 high, the cell **below** the carpet); with no supporting block, the cell containing `(x, y - 0.2, z)`.
- The **main supporting block** is recomputed whenever `onGround` is set (`checkSupportingBlock`): while on the ground, the cell whose collision shape touches the strip `[minX, maxX] x [minY - 1.0E-6, minY] x [minZ, maxZ]` of the entity's box (the bottom face thickened downward by one millionth) and whose centre is nearest the entity's position (equal distances: the smaller `BlockPos` order); the result of the first search is taken at once when it found a cell **or** when `onGroundNoBlocks` was already true from the previous update (so an empty result stays empty). Only when the first search found nothing, `onGroundNoBlocks` was false, **and** a movement vector was supplied, a second search is made with the strip shifted by `(-m.x, 0, -m.z)` (where the entity stood before the move) and its result (possibly empty) is stored. When the first search found nothing, `onGroundNoBlocks` was false and **no movement vector** was supplied (a plain `setOnGround`), the previous supporting block is left unchanged. `onGroundNoBlocks` is then set to whether the final result is empty. While not on the ground, `onGroundNoBlocks` is false and the supporting block is cleared.

#### 14.1.4 One emission pass (`applyMovementEmissionAndPlaySound`)

Let `P0`, `S0` be the legacy cell and its state, `P1`, `S1` the `getOnPos()` cell and its state. The pass, in order:

1. Update the counters (14.1.3).
2. When `moveDist > nextStep` **and** `S1` is not air:
   1. `same` = (`P1` equals `P0`).
   2. `r1` = `stepAttempt(P0, S0, playSound = emission.emitsSounds(), postEvent = same, m)`.
   3. When not `same`: `r2` = `stepAttempt(P1, S1, playSound = false, postEvent = emission.emitsEvents(), m)`.
   4. When `r1` or `r2` succeeded: `nextStep = nextStep()` (14.1.3). Otherwise, when the entity `isInWater()` (the water flag of the fluid interaction, 29a section 8.1): `nextStep = nextStep()`, the swim sound plays when the emission emits sounds, and when it emits events **`swim` is posted** (14.1.6).
3. Otherwise, when `S1` is air: `processFlappingMovement` (14.1.6).
4. Otherwise (`moveDist <= nextStep` with a solid floor): nothing.

`stepAttempt(cell, state, playSound, postEvent, m)`:

- It fails (returns false) when `state` is air.
- It succeeds only when **(the entity is on the ground, or `state` is climbable, or (the entity `isCrouching()` and `m.y == 0`), or the entity is on rails (`isOnRails`, true only for minecarts)) and the entity is not swimming** (`isSwimming()`, the swimming flag, 29a section 8.4). `isCrouching()` is the pose test `CROUCHING` (a fox overrides it with its own crouching flag, Open question 1).
- On success the step sound plays when `playSound`, and when `postEvent` the event **`step`** is posted (14.1.5). It returns true.

When `same` is true the event flag of the first attempt is `true` regardless of `emission.emitsEvents()` (read; no class has an emission that emits sounds but not events, so this has no observable effect today).

#### 14.1.5 `step`

| Property | Value |
|---|---|
| Posted by | any entity with emission `EVENTS` or `ALL` that is not a passenger, from the pass above |
| When | the step test of 14.1.4 succeeds in a pass in which `moveDist` crossed `nextStep` |
| Position | the entity's own position (`position()`), **not** the stepped-on block centre |
| Source entity | the moving entity |
| Affected state | `S1`, the state of the `getOnPos()` cell (in the "not same" case the event comes from the second attempt; in the "same" case `S0` and `S1` are the same state) |

Because `S1` is the **supporting** block rather than the block 0.2 below the feet, an entity standing on a carpet posts a step whose affected state is the carpet (silenced by `dampens_vibrations`, section 3.5) while the step sound is the one of the block below the carpet (`P0` differs from `P1`). An entity on a fence, wall or fence gate has `P0 == P1` (the legacy rule returns the supporting cell), so the state is the fence's. On wool (a full block) the supporting block is the wool block and the event is silenced.

#### 14.1.6 `swim` and `flap`

**`swim`.** Posted in step 2.4 of the pass: `moveDist > nextStep`, `S1` is not air, no step attempt succeeded and the entity `isInWater()`. Position: the entity's own position; source entity: the swimming entity; affected state: none. Examples of when no step attempt succeeds in water: the entity is above the floor (not on the ground and not climbing, which includes a mob mid-water and a player wading in deep water), or it is `isSwimming()` (a sprint-swimming player, even while touching the bottom). An entity that walks on the bottom of shallow water on the ground, not swimming, posts `step` (with the floor's state), not `swim`. The condition `S1` not air holds for any water cell below the feet.

**`flap`.** Posted by `processFlappingMovement`, reached in step 3 of the pass whenever the `getOnPos()` state is air (the cell below the feet is air), on every `move` call regardless of `moveDist`: when the entity's `isFlapping()` is true, `onFlap()` runs and, when the emission emits events, **`flap` is posted** at the entity's own position with the entity as source and no state. The default `isFlapping()` is false. Overrides read:

| Entity | `isFlapping()` is true when | Notes |
|---|---|---|
| `Bat` | not resting and `tickCount` is a multiple of 10 (float remainder 0) | emission `EVENTS` |
| `Allay` | not on the ground | |
| `Bee` | flying and `tickCount mod TICKS_PER_FLAP == 0` | `TICKS_PER_FLAP` = `ceil(1.4959966)` = 2 |
| `Phantom` | `(uniqueFlapTickOffset + tickCount) mod TICKS_PER_FLAP == 0` | `TICKS_PER_FLAP` = `ceil(24.166098)` = 25 |
| `Vex` | `tickCount mod TICKS_PER_FLAP == 0` | `TICKS_PER_FLAP` = `ceil(3.9269907)` = 4 |
| `Chicken`, `Parrot` | `flyDist > nextFlap` (a private float, starts 1.0); `onFlap()` then sets `nextFlap = flyDist + flapSpeed / 2` | `flapSpeed` is updated every `aiStep`: `flapSpeed = clamp(flapSpeed + (onGround [Parrot: onGround or passenger] ? -1 : 4) x 0.3, 0, 1)`; `Parrot.onFlap` also plays a sound |
| `EnderDragon` | `cos(2 pi oFlapTime) <= -0.3` (the previous phase) and `cos(2 pi flapTime) >= -0.3` (the current phase): the phase crosses -0.3 | `EnderDragon.aiStep` calls `processFlappingMovement` **directly as its first statement** (so the dragon can post `flap` there, with the phase values left by the previous tick, in addition to the `move` pass of 14.1.4 when the cell below is air). Later in the same method `oFlapTime = flapTime`; when the dragon is dead or dying the method then spawns particles and returns (no advance and no movement); otherwise `flapTime` advances by `f = (0.2 / (horizontalSpeed x 10 + 1)) x 2^(vy)` (`vy` the vertical velocity), by 0.1 when the dragon's phase is sitting, by `f / 2` while it is inside a wall, else by `f`; a dragon with no AI sets `flapTime` to 0.5 at the end |

The sensors hear `flap` (frequency 1); the warden does not (section 3.5.1).

#### 14.1.7 `hit_ground` and the fall handling

`Entity.checkFallDamage(dy, onGround, state, cell)`, in order:

1. When the entity is **not in water** and `dy < 0`: `fallDistance = fallDistance - (double)(float)dy` (the fall distance grows by the downward movement, cast through a float).
2. When `onGround`: when `fallDistance > 0`: call `state.getBlock().fallOn(level, state, cell, entity, fallDistance)` (damage and block reactions: 29b section 4.6), then **post `hit_ground`**: position = the entity's own position; source entity = the entity; affected state = the state of the **main supporting block cell** when the entity has one, else `state` (the legacy cell's state, 14.1.3). Then, whether or not anything was posted, `fallDistance` is reset to 0.

There is **no distance threshold**: any `fallDistance > 0` at the moment of ground contact posts the event, so a jump landing posts it, a walk down a stair step or slab edge posts it (each downward component adds to the distance, and `onGround` is true again in the same call), and walking on flat ground does not (every collided `dy` is 0). The fall handling does not depend on the emission class: an item entity, a falling block, a primed TNT or an experience orb that calls `move` and lands with a positive `fallDistance` also posts `hit_ground` (source = that entity; a dropped item whose stack is in the item tag `dampens_vibrations` is then discarded by the sensor, section 3.5). Water: `fallDistance` is reset to 0 as the entity enters water (29a section 8.3 step 2), and does not grow while in water, so landing on the floor of a pool posts nothing. On the packet path the whole call returns first when the entity touches an unloaded chunk (`touchingUnloadedChunk`), posting nothing.

Entry points: (a) an authoritative entity runs it inside `Entity.move` (14.1.1 step 4) with `dy = m.y` and the legacy cell and state, `onGround` just computed; (b) a client-authoritative player or vehicle runs `doCheckFallDamage(dx, dy, dz, onGround)` from the packet handler: it first recomputes the supporting block from the packet's flag and the movement delta (14.1.3), then calls `checkFallDamage(dy, onGround, state of legacy cell, legacy cell)` with `(dx, dy, dz)` = the player's position after the snap to the packet position minus its position when the handler started (before the replay), and `onGround` the packet's flag (set just before by `setOnGroundWithMovement`); for a vehicle the same differences are taken on the vehicle. Overrides: `LivingEntity.checkFallDamage` updates the fluid interaction first when the entity is not in water, then runs its landing-particle bookkeeping, then the base rule; `ServerPlayer` adds its own particle bookkeeping then the base rule; **`Bat`, `Allay`, `Bee`, `HappyGhast`, `Ghast`, `Parrot` and `Phantom` override it with an empty body, so these mobs never post `hit_ground` and never take fall damage**; `Strider` resets the fall distance while in lava and otherwise uses the animal rule; `AbstractBoat` never posts `hit_ground` (it records its last vertical speed, returns when it is a passenger, resets the fall distance on ground, and otherwise adds the fall while the cell below is not water).

#### 14.1.8 `splash`

Posted by `Entity.doWaterSplashEffect` at its end (after the sound and the particles of 29a section 8.7), when the entity enters water: in `Entity.updateFluidInteraction`, in water, when `wasTouchingWater` was false and it is not the first tick (29a section 8.3, called once per `baseTick`; items, TNT and minecarts call it from their own tick as well). Position: the entity's own position. Source entity: **the splashing entity itself**, not the controlling passenger (the passenger only matters for the volume). Affected state: none. Only water counts (the fluid-tag test `water`, 29a section 8.3): entering lava posts nothing. `Player.doWaterSplashEffect` posts nothing for a spectator; `ExperienceOrb` and the cube mobs have their own override or direct call (Open question 3).

The second poster is `AbstractBoat.onAboveBubbleColumn(down, pos)` (called by the bubble column block while the boat is over it): when the boat is **not under water** and a draw `nextInt(100)` is 0 (1 in 100 per call), it plays the swim-splash sound at the boat, adds a splash particle and posts `splash` at the boat's position with the boat's **controlling passenger** as source entity (null when nobody drives it) and no state.

#### 14.1.9 `bounce`, `elytra_glide`, `entity_mount`, `entity_dismount`

**`bounce`** is posted by `Entity.restituteMovementAfterCollisions(state, xCollision, zCollision, wantedMovement)` when the pass decided the entity bounced. Let `b0` = 0 when the entity is suppressing the bounce (`isSuppressingBounce` = the shift-key flag), else `getEntityBounciness()` (0 for entities in general; for a `LivingEntity` the value of the attribute `bounciness`). Horizontal: when x (or z) collided, that velocity component becomes `-vx x b0` (`-vz x b0`); `bounced` is `b0 > 0 and (x or z collided)`. Vertical (only when `verticalCollision`): for a collision from above `b` stays `b0`; for a collision from below (`verticalCollisionBelow`) `b` = 0 if the entity is suppressing the bounce, or its downward speed does not exceed the effective gravity, or the block is in tag `suppresses_bounce`; otherwise `b = max(b0, blockBounciness)` where `blockBounciness` is the block's `bounceRestitution` property (multiplied by 0.8 when the entity is not a `LivingEntity`); when `b > 0` the vertical speed is reflected (a value derived from the ratio of the resolved to the wanted vertical movement, the effective gravity and the air drag; not transcribed) and `bounced` becomes true. When `bounced`: `block.bounceOn(...)` runs (the shelf-mushroom block plays its sound for entities other than items and primed TNT), **`bounce` is posted** (entity position, source = the entity, no state) and a position sync is requested. Blocks with a `bounceRestitution` property in the registry: `slime_block` 1.0 (its 0.8 is its friction); `shelf_mushroom` 0.75; and a per-dye-colour collection (16 blocks; the beds, name inferred from the adjacent registration lambda that reads `BedBlock.PART`) with strength 0.2, wood sound, `bounceRestitution` 0.75, `fallDistanceReduction` 0.5, no occlusion, ignited by lava and push reaction POPPED. `Block.fallOn` multiplies the fall distance by `1 - fallDistanceReduction` before the damage (29b section 4.6), so a bed halves fall damage. The exact reflected vertical value was not transcribed (Open question 7).

**`elytra_glide`** is posted by `LivingEntity.updateFallFlying`, called from `aiStep` while the entity `isFallFlying()` (the shared flag 7) and the level is a server level. When the entity can no longer glide (`canGlide()` false) the flag is cleared and nothing is posted. Otherwise, with `n` = `fallFlyTicks + 1` (the count of gliding ticks, incremented once per tick in `LivingEntity.tick` while `isFallFlying()` and reset to 0 otherwise): when `n mod 10 == 0` the event is posted at the entity's own position with the entity as source and no state, i.e. **every 10th gliding tick** (`fallFlyTicks` = 9, 19, 29, ...); on every second such moment (`(n / 10)` even, i.e. every 20 ticks) one randomly chosen equipment slot whose stack can glide (`canGlideUsing`) is damaged by 1 (the elytra wear, 17 section 3.13) before the post.

**`entity_mount`** is posted by `Entity.startRiding(vehicle, force, emitEvent)` when `emitEvent` is true: **after** the rider has become a passenger (the rider's `vehicle` field is set and `addPassenger` has run), by `Level.gameEvent(rider, entity_mount, vehicle.position)`: position = the **vehicle's** position, source entity = the **rider**, no state. The one-argument `startRiding(vehicle)` always emits. Callers that pass `emitEvent = false` are the loaders and converters: restoring passengers from saved data (`Entity` load path), a `ServerPlayer` restoring its vehicle, and `ConversionType` (a converted mob keeps its vehicle without an event); `/ride` passes true.

**`entity_dismount`** is posted by `Entity.removeVehicle` (called from `stopRiding` and the other ways of leaving): after the rider's vehicle field is cleared and `removePassenger` ran, when the rider has **no removal reason or a removal reason that destroys it** (`RemovalReason.shouldDestroy`; a rider that is merely unloaded or changing dimension posts nothing): `Level.gameEvent(rider, entity_dismount, vehicle.position)`: position = the vehicle's position, source entity = the rider, no state.

#### 14.1.10 Sneaking, flying, spectators, riders, silence and damping (summary)

| Situation | Effect on movement events |
|---|---|
| Player on the ground with the shift key down | emission `NONE`: no `step`, `swim`, `flap`, and `moveDist` stands still (14.1.2). The landing `hit_ground` is still posted by the fall handling and is discarded at the sensor (`isSteppingCarefully`, section 3.5). |
| Player in the air or in water with the shift key down | emission `ALL`: `swim` (in water) is posted and discarded at the sensor; `step` needs the on-ground or climbing test and is not posted in the air |
| Player with `abilities.flying` | emission `NONE` (no `step`, `swim`, `flap`); `hit_ground` can still be posted on landing if `fallDistance` grew |
| Spectator (`noPhysics`) | `move` returns before any emission (14.1.1 step 1); spectators are also rejected as sources by the sensor (section 3.5) |
| Passenger (any entity with `isPassenger()`) | no emission pass for the rider; the **vehicle** posts its own events with the vehicle as source (a boat and a minecart: `EVENTS`; a horse or pig: `ALL`); the shrieker and warden resolve a controlling passenger player through `tryGetPlayer` (section 6.2) |
| Silent entity (`isSilent`, the silent flag) | only the **sound** calls test it (`Entity.playSound` returns when silent); events are unaffected: a silent entity still posts `step`, `swim`, `hit_ground` |
| `Warden`, and an `ItemEntity` whose stack is in the item tag `dampens_vibrations` | still post their events; the sensor discards them (`dampensVibrations`, section 3.5) |
| Wool, carpet, wool slab or wool stairs as the stepped-on block | the `step` event's affected state is that block (14.1.5): discarded by the sensor (`dampens_vibrations`, section 3.5.1) |
| Crouching cat, ocelot (pose `CROUCHING`) | still posts; the sensor discards `step`, `swim`, `hit_ground` (section 3.5.1) |

The names `isMovementNoisy`, `canSpawnSprintParticle` and similar were searched for in `Entity` and found to be absent from the movement emission path (sprint particles are a client concern).

#### 14.1.11 `stepOn` of the sculk blocks (answer to the open question of section 13, item 7)

`SculkSensorBlock.stepOn` and `SculkShriekerBlock.stepOn` (sections 4.4 and 6.2) are reached through `Block.stepOn(level, pos, state, entity)`, whose only caller in the movement code is `Entity.applyEffectsFromBlocks(movements)`:

- It is called once per tick for every living entity at the end of `LivingEntity.aiStep` (after `travel`; on a server level always), and from the own tick code of the other entity classes (items, projectiles, TNT, falling blocks, minecarts, boats, experience orbs, the dragon, fishing hooks, fireworks, and by `PistonMovingBlockEntity` for carried entities). A `ServerPlayer` runs `aiStep` from `LivingEntity.tick` like any living entity.
- Inside it: nothing happens when the entity is removed or has `noPhysics` (`isAffectedByBlocks`: spectators are excluded); when `onGround()` is true, `stepOn` runs once on the **block at `getOnPosLegacy()`** (the cell 0.2 below the feet or the fence-like supporting block, 14.1.3), with that block's state.
- There is **no sneaking, flying, creative, pose, silent or entity-type test** in this path: a sneaking player standing on a sensor or shrieker triggers `stepOn` every tick (the sensor's own `stepOn` excludes only a warden, and requires the block's phase to allow activation, section 4.4). It runs every tick the entity is on the ground over the block, not once per step distance.
- The `stepOn` of the sensor posts nothing through `gameEvent`; it hands a `step` candidate straight to the listener (`forceScheduleVibration`, section 4.4) with the entity as source and the entity's position, skipping occlusion, the tags and the in-flight check.

#### 14.1.12 Worked examples

All distances are the horizontal length of the collided movement `m` per call; the walk is on a full block on the ground, `isSwimming()` false, emission `ALL`, `nextStep` starting at 1.0 (a fresh entity). `moveDist` is accumulated in float arithmetic.

| # | Input | Expected |
|---|---|---|
| 1 | a mob walks 0.18 blocks per call | `vh` = 0.108 per call; `moveDist` > 1.0 at call 10 (1.08): `step` at call 10, `nextStep` becomes 2.0; call 19 (2.052): `step`, `nextStep` 3.0; call 28 (3.024): `step`. Steps at calls 10, 19, 28 |
| 2 | a player walks 0.2158 per tick (illustrative input, not read from the artifact) | steps at ticks 8 (1.0358), 16 (2.0717), 24 (3.1075), 31 (4.0139), 39 (5.0497) |
| 3 | a player sprints 0.2806 per tick (illustrative input, not read from the artifact) | steps at ticks 6, 12, 18, 24, 30, 36 |
| 4 | an entity climbs a ladder straight up 0.12 per call (horizontal 0) | `climbable` true, so `v3 = 0.072` per call is added: `step` at call 14 (1.008) and 28 (2.016). Without the climbable state `vh` = 0 and `moveDist` would never advance |
| 5 | a sneaking player walks on the ground | `getMovementEmission()` is `NONE`: no pass, `moveDist` unchanged, no event |
| 6 | an entity stands on a carpet (`P0` the block under the carpet, `P1` the carpet) and its `moveDist` crosses `nextStep` | `r1` plays the sound of the block under the carpet and posts nothing; `r2` posts `step` with affected state = the carpet |
| 7 | a player jumps and lands (fall distance 1.25 after the arc; illustrative input, not read from the artifact) on stone | `hit_ground` at the player's position, affected state stone, then `fallDistance` = 0 |
| 8 | a player walks down a slab-high step (`dy = -0.5` and on the ground again in the same packet) | `fallDistance` = 0.5 then `hit_ground` posted (and reset); walking on flat ground posts none |
| 9 | an entity drops into water | `fallDistance` resets in `updateFluidInteraction` before `splash`; `splash` posted once (source = the entity); landing on the pool floor posts no `hit_ground` |
| 10 | a bat flies (not resting) over open air at `tickCount` 20 | the `getOnPos()` cell is air, `isFlapping()` true: `flap` posted at tick 20, 30, 40, ... |
| 11 | a player glides with an elytra | `elytra_glide` posted at the 10th, 20th, ... gliding tick; the elytra loses 1 durability at the 20th, 40th, ... |
| 12 | a player mounts a boat | `entity_mount`, position = the boat's position, source = the player, frequency 6; dismounting posts `entity_dismount`, frequency 5, same position and source |

### 14.2 Projectiles

#### 14.2.1 `projectile_shoot`

Posted by `Projectile.tick` on the **first** tick of every `Projectile` entity on a level where the call has effect (server): when `hasBeenShot` is false it posts `Entity.gameEvent(projectile_shoot, owner)` (position = the **projectile's** own position at that moment, source entity = the **owner** (`getOwner()`, null for an owner-less projectile such as one from a dispenser: then the context has no source), no state) and sets `hasBeenShot`. The flag is saved (`HasBeenShot` in the projectile's NBT) so a reloaded projectile does not post again.

Order inside the projectile's own tick differs per class (read):

- `ThrowableProjectile` (snowball, egg, ender pearl, thrown potions, experience bottle, and the like): first `handleFirstTickBubbleColumn`, gravity and inertia, the hit test along the movement, then **`setPos`** (to the **hit location** when the movement hit something, else to position plus movement), `applyEffectsFromBlocks`, then `Projectile.tick` (so `projectile_shoot` is posted at the position **after** the first move, which is the hit point when the very first move already hit something), then `hitTargetOrDeflectSelf` when the movement hit something.
- `AbstractHurtingProjectile` (fireballs, wither skulls, wind charges, dragon fireballs): the hit test and `setPos`, then `Projectile.tick`, then `hitTargetOrDeflectSelf`.
- `AbstractArrow`: its own `stepMoveAndHit` (which can call `hitTargetOrDeflectSelf`) runs **before** `Projectile.tick`, so an arrow that strikes something in its very first tick posts `projectile_land` **before** `projectile_shoot`.
- `ShulkerBullet`, `LlamaSpit` and `FireworkRocketEntity`: `Projectile.tick` first; `FishingHook`: `Projectile.tick` early in its tick, then its own movement (it calls `move`, emission `NONE`).

Bows, crossbows, tridents, snowballs, eggs, pearls, potions, wind charges, fireworks and fishing rods all create a `Projectile` and add it to the level, so they all post through this single place at the first tick of the entity (inferred from the class hierarchy of the projectile entities; each item class was not read); the player's item use additionally posts the `item_interact_start` / `item_interact_finish` events of 14.3.8 from the use code. Dispenser-fired projectiles have no owner (source entity null). **Explicit second poster:** `EnderEyeItem.use` posts `projectile_shoot` itself at the eye of ender's spawn position with the **player** as source, immediately before adding the entity (the eye of ender is not a `Projectile`, so it never posts through `Projectile.tick`).

#### 14.2.2 `projectile_land`

Posted only by `Projectile.onHit(hitResult)`, which is called by `hitTargetOrDeflectSelf` (14.2.3). Every override in the artifact (`DragonFireball`, `LargeFireball`, `SmallFireball`, `AbstractWindCharge`, `WitherSkull`, `ShulkerBullet`, `AbstractThrownPotion`, `Snowball`, `ThrownEgg`, `ThrownEnderpearl`, `ThrownExperienceBottle`, and their super chain through `Fireball`, `AbstractHurtingProjectile`, `ThrowableItemProjectile`) calls the superclass `onHit` **first**, so the event precedes the class's own effect (explosion, potion splash, teleport, discard).

| Hit type | Order | Position | Source entity | Affected state |
|---|---|---|---|---|
| Entity hit | `onRedirectProjectile` when the target is a redirectable projectile (tag `redirectable_projectile`), then `onHitEntity` (damage and effects), **then** the event | the hit location (`HitResult.getLocation()`, the exact point on the target's box) | the **projectile itself** (the direct entity, not the owner) | none |
| Block hit | `onHitBlock` (an arrow becomes `inGround` here, a pearl lands, and so on), **then** the event | the **centre of the hit block** (`Level.gameEvent` with a `BlockPos`) | the projectile itself | the block state at the hit position, read after `onHitBlock` ran |
| Miss | no call | | | |

A piercing arrow posts one event per entity it hits (`hitTargetsOrDeflectSelf` loops over the entities in order of distance until the arrow is removed or is not piercing any more). An arrow stuck in the ground does not hit again (`stepMoveAndHit` is skipped while `inGround`), so a landing posts once.

#### 14.2.3 `hitTargetOrDeflectSelf` (when `onHit` is reached)

Input: the hit result. Output: the deflection used (`NONE` when `onHit` ran).

- **Entity hit.** `D` = the target's `deflection(projectile)`. When `D` is not `NONE` the method returns `D` **without calling `onHit`** (nothing is posted): this happens for every non-`NONE` deflection. Before returning, when the target is not the entity that last deflected this projectile (`lastDeflectedBy`), the projectile is deflected (`deflect(D, target, owner, false, 1.0)`) and when that call returns true `lastDeflectedBy` is set to the target. `Projectile.deflect` returns true unconditionally; only the `WindCharge` override returns false, while its `noDeflectTicks` counter is above 0 (otherwise it defers to the base method). A false result or an equal `lastDeflectedBy` changes nothing but still returns without `onHit`. When `D` is `NONE`, `onHit` runs (14.2.2).
- **Block hit, not a world-border hit.** When the block at the hit position is air the method returns `NONE` without calling `onHit` (nothing posted); otherwise `onHit` runs and posts the block variant of 14.2.2.
- **World-border hit.** When `shouldBounceOnWorldBorder()` is true the projectile is deflected with the `REVERSE` deflection (`deflect(REVERSE, none, owner, false, 0.2)`) and the method returns `REVERSE` without `onHit` (nothing posted), except for a `WindCharge` whose `noDeflectTicks` is above 0 (its `deflect` returns false), which falls through to `onHit`. A projectile that does not bounce on the world border calls `onHit` and posts the block variant at the block position of the hit result.

#### 14.2.4 Other projectile-related events

| Event | Poster | Position | Source entity | State |
|---|---|---|---|---|
| `explode` | `FireworkRocketEntity.explode` (after entity event 17), `Entity.gameEvent(explode, owner)` | the rocket's position | the **owner** of the rocket (may be null) | none |
| `explode` | `ServerExplosion.explode` (all other explosions: creeper, TNT entity, fireballs, wind charge uses a different knock-back class, beds) | the explosion centre | the explosion's `source` entity, which is the **direct** exploder (the `PrimedTnt` entity, the creeper, the fireball, not its igniter or owner); null for a bed or respawn anchor | none |
| `entity_damage` | `ShulkerBullet.destroy` (when the bullet is shot down or hits) | the bullet's position | the bullet itself | none |

The `ThrowableProjectile`, `AbstractArrow` and `FishingHook` classes post no other event of their own. `AbstractArrow` ground behaviour (frozen in place, despawn timers, pickup) is in 44 part 8.

#### 14.2.5 Examples

| # | Input | Expected |
|---|---|---|
| 1 | a player shoots an arrow that hits a zombie | tick 1 of the arrow: the stepMoveAndHit of that tick hits the zombie: `onHitEntity` (damage; the zombie posts its own `entity_damage`), then `projectile_land` at the hit point with the arrow as source (the warden's projectile owner is the player), then `Projectile.tick` posts `projectile_shoot` (position = the arrow's position, source = the player) |
| 2 | a skeleton's arrow flies 20 blocks and sticks in a wooden plank | `projectile_shoot` on the first tick (source = the skeleton); `projectile_land` once, at the plank's block centre, source = the arrow, affected state = the plank; no further events while it is stuck |
| 3 | a snowball thrown by a player hits a wall | tick 1: move, `projectile_shoot` (position after the first move, source = the player), hit test: `projectile_land` at the wall block centre (source = the snowball, state = the wall) and the snowball is discarded afterwards |
| 4 | an arrow hits a shield-blocking player so that the shield deflects it | no `projectile_land` (deflected, `onHit` not called); the shield and the damage rules are 17 |
| 5 | a dispenser fires an arrow | `projectile_shoot` on the arrow's first tick with no source entity (the owner is null), position = the arrow's position |

### 14.3 Sources of the other events

The posters below were found by scanning every class of `net/minecraft` in the artifact (about 10,700) for references to the `GameEvent` constants; the lists are the result of that scan and each row was read at its call site. Where a row says "none" for the source entity, the call passes a null entity (the context has no source and the sensor's source-entity checks of section 3.5 are skipped). "Block centre" means the `BlockPos` form of 14.0.

#### 14.3.1 Direct versus causing entity (rules)

| Event | Which entity goes into the context |
|---|---|
| `entity_damage` of a living victim (including players) | the **victim itself**; the attacker is not in the context at all |
| `entity_damage` of an armor stand, an item entity, a boat or minecart | the **causing** entity (`DamageSource.getEntity`: owner, shooter or attacker, never the arrow or other direct entity), null when there is none |
| `entity_die` | the victim itself (a living entity, a player, the dragon), or the killer when one is passed in (armor stand and other block-attached entities), else the entity itself |
| `projectile_land`, `projectile_shoot` | landing: the **projectile** (the direct entity); shooting: the projectile's **owner** (14.2) |
| `explode` | the explosion's `source` entity (the **direct** exploder: the TNT entity, the creeper, the fireball), or the owner for a firework rocket; null for a bed or an anchor (14.3.10) |
| `prime_fuse` | the **igniter** passed to `TntBlock.prime` (null when none: redstone, fire, explosion chain), the creeper or cube mob itself for those entities |
| `entity_place`, `block_place`, `block_destroy`, `container_*`, `fluid_*`, `shear` by a player | the player |
| the same by a mob | the mob; the **actor**, not an owner |
| the same by a dispenser | none |

#### 14.3.2 `entity_damage` and `entity_die`

| Event | Poster and moment | Position | Source entity | State |
|---|---|---|---|---|
| `entity_damage` | `LivingEntity.actuallyHurt`, and the `Player.actuallyHurt` override: after the damage was reduced by armor, enchantments and absorption, recorded in the combat tracker, and subtracted from health and absorption. **Nothing is posted when the damage left after armor, enchantments and absorption is 0** (the method returns before the event, so a hit that is entirely absorbed posts no event) | the victim's position | the victim | none |
| `entity_damage` | `ArmorStand.hurtServer` (a hit that damages but does not break the stand) and `ArmorStand.causeDamage` | the stand's position | `DamageSource.getEntity()` (may be null) | none |
| `entity_damage` | `ItemEntity.hurtServer`, after the item's health was reduced and before it is destroyed | the item's position | `DamageSource.getEntity()` | none |
| `entity_damage` | `VehicleEntity.hurtServer` (every boat and minecart), after the damage value was increased by `damage x 10` | the vehicle's position | `DamageSource.getEntity()` | none |
| `entity_damage` | `ShulkerBullet.destroy` (the bullet is discarded) | the bullet's position | the bullet | none |
| `entity_die` | `LivingEntity.die`: after kill credit, sleeping and item-use cleanup, `handleKillingBlow`; on a server level: when there is no killer or the killer's `killedEntity(level, victim, source)` returns true, the event is posted, then the death loot and the wither rose. A killer whose `killedEntity` returns false (the `Zombie` override returns false when the victim is converted instead of dying: its logic was not decoded further) suppresses both the event and the loot | the victim's position | the victim | none |
| `entity_die` | `ServerPlayer.die`: posted **first** in the method, before the death message and the base `die` | the player | the player | none |
| `entity_die` | `Entity.kill(level)` (the `/kill` and void kill path): after `remove(KILLED)` | the entity | the entity | none |
| `entity_die` | `EnderDragon.kill` and the end of `EnderDragon.tickDeath`: after `remove(KILLED)` | the dragon | the dragon | none |
| `entity_die` | `ArmorStand.kill(level, killer)` and `BlockAttachedEntity.kill(level, killer)` (item frames, paintings): after `remove(KILLED)` | the entity | `killer` when not null, else the entity itself | none |

Because the entity is removed before the post in the kill paths, the position read is its last position. The sculk catalyst listens for `entity_die` with a living source entity (31-8 section 7.2).

#### 14.3.3 Every poster of `entity_place`

| Poster | Trigger | Position | Source entity |
|---|---|---|---|
| `DispenseItemBehavior` anonymous class 6 (TNT from a dispenser) | after the primed TNT was added and its sound played | block centre of the cell in front of the dispenser | none |
| `SpawnEggItemBehavior` (a spawn egg in a dispenser) | after the mob spawned | block centre of the **dispenser itself** (`BlockSource.pos`) | none |
| `SpawnEggItem.spawnMob` | a player used a spawn egg: after `EntityType.spawn` returned an entity and the stack was consumed | block centre of the target cell | the player (the using `LivingEntity`) |
| `MobBucketItem.checkExtraContent` | the bucketed mob was placed | block centre of the placement cell | the user |
| `ArmorStandItem.useOn` | after the stand was placed and its sound played | the stand's position | the player |
| `CushionItem.useOn` | after the cushion was placed and its sound played | the cushion's position | the player |
| `BoatItem.use` (every boat and chest boat) | after the boat was added to the level (the placement check `noCollision` passed) | the **click location** (the exact `HitResult` location) | the player |
| `MinecartItem.useOn` | after the cart was added | block centre of the rail cell | the player; **affected state = the block below the rail cell** (`pos.below()`) |
| `EndCrystalItem.useOn` | after the crystal was added | block centre of the cell above the clicked block | the player |
| `HangingEntityItem.useOn` (item frame, glow item frame, painting) | after the placement sound, before `addFreshEntity`, only when the entity survives | the hanging entity's position | the player |
| `OminousItemSpawner.spawnItem` | after the item entity was added and level event 3021 | the spawner's position | the spawned item entity (inferred) |
| `Armadillo.customServerAiStep` | when it drops a scute | the armadillo's position | the armadillo |
| `Chicken.aiStep` | when it lays an egg | the chicken's position | the chicken |
| `Evoker$EvokerAttackSpellGoal.createSpellEntity` | each evoker fang added | the fang's position (x, block y plus the offset, z) | the evoker |
| `Evoker$EvokerSummonSpellGoal.performSpellCasting` | each vex summoned | block centre of the vex's spawn cell | the evoker |
| `BaseSpawner.serverTick` (monster spawner block) | after the mob was added and level event 2004 | block centre of the cell containing the spawn position | the spawned entity |
| `TrialSpawner.spawnMob` | after the mob was added and the flame level events 3011 / 3012 | block centre of the cell containing the spawn position | the spawned mob |
| `CreakingHeartBlockEntity.spawnProtector` | after the creaking spawned | the creaking's position | the creaking |

Spawn paths that do **not** post `entity_place` (read): natural spawning, breeding, the iron golem and snow golem pattern build (`CarvedPumpkinBlock`), the wither build, `TntBlock.prime` (it posts `prime_fuse`), the boat and minecart dispensers (`BoatDispenseItemBehavior`, `MinecartDispenseItemBehavior` contain no game-event reference), the default dispenser item drop and projectile creation (the projectile posts `projectile_shoot`, 14.2.1). Two dispenser behaviours (anonymous classes 1 and 12) contain no game-event reference and were not identified.

#### 14.3.4 Every poster of `block_place`

| Poster | Trigger | Position | Source entity | Affected state |
|---|---|---|---|---|
| `BlockItem.place` | a block item placed by a player (or by a dispenser placing through `BlockItem` with no player) after the block was set and the place sound played | block centre of the placed cell | the placing player (null when there is none) | the placed state |
| `FireChargeItem.useOn` | fire placed | block centre of the fire cell | the player | none |
| `FlintAndSteelItem.useOn` | fire placed | block centre | the player | none |
| `FlintAndSteelDispenseItemBehavior` | fire placed | block centre of the front cell | none | none |
| `DispenseItemBehavior` anonymous classes 7 (wither skeleton skull) and 8 (carved pumpkin) | block set from a dispenser | block centre of the front cell | none | none |
| `HarvestFarmland` (villager replanting) | after `setBlockAndUpdate` of the new crop (the harvest itself is a `block_destroy`, 14.3.5) | block centre of the cell above the farmland | the villager | the new crop state |
| `TryLaySpawnOnFluidNearLand` (frog) | frogspawn placed | block centre | the frog | the spawn state |
| `SnowGolem.aiStep` | each snow layer left behind | block centre of that cell | the snow golem | the snow state |
| `Turtle$TurtleLayEggGoal.tick` | turtle egg placed | block centre | the turtle | the egg state |
| `Enderman$EndermanLeaveBlockGoal.tick` | the carried block set down | block centre | the enderman | the placed state |
| `SnifferEggBlock.onPlace` | whenever the egg block is placed (for any reason) | block centre | none | the egg state |
| `CreakingHeartBlockEntity` (lambda in the creaking-hurt handler) | resin placed | block centre of the resin cell | none | the state of the **creaking heart block itself** (not the resin) |
| enchantment effect `replace_disk` with `trigger_game_event` (data: `frost_walker` names `block_place`) | once per replaced (frozen) block, after `setBlockAndUpdate` | block centre of that block | the entity wearing the enchantment | none |

Not posters of `block_place` (no reference in the scan): pistons (moved blocks create no placement event; blocks crushed by a piston post `block_destroy`), fluid placement (it posts `fluid_place`), crops, saplings, vines and other growth, and block placement by commands.

#### 14.3.5 Every poster of `block_destroy`

| Poster | Trigger | Position | Source entity | Affected state |
|---|---|---|---|---|
| `Block.playerWillDestroy` | a player breaks a block, **before** the block is removed (creative and survival) | block centre | the player | the block's state |
| `Level.destroyBlock(pos, drop, breaker, depth)` | when the block was not air: particles, optional drops, the position set to its fluid state's block, and **only when that `setBlock` succeeded** the event | block centre | the `breaker` argument (the 2-argument overload passes a null breaker, the 3-argument overload passes the given breaker with the depth limit 512; the 4-argument form with an explicit depth is the poster) | the state **before** the destruction |
| `Enderman$EndermanTakeBlockGoal.tick` | after `removeBlock` of the picked block | block centre | the enderman | the block's state |
| `BrushableBlock.onBrokenAfterFall` | a falling suspicious sand or gravel block broke on landing | the falling block entity's position | the **falling block entity** | none |
| `CakeBlock.eat` | the last slice eaten and the cake removed | block centre | the player | none |
| `IceBlock.melt` | ice replaced by water or air | block centre | none | the ice state |
| `SnowLayerBlock.randomTick` | a snow layer melted away | block centre | none | the snow state |
| `TurtleEggBlock` (`decreaseEggs`, `randomTick` hatch) | an egg removed or the block removed | block centre | none | the state |
| `PistonBaseBlock.moveBlocks` | each block crushed by the piston | block centre | none | the destroyed block's state |

Callers of `Level.destroyBlock` and the entity they pass: `HarvestFarmland` (the villager), `WitherBoss` (the wither), `Ravager` (the ravager, leaves), `Silverfish$SilverfishWakeUpFriendsGoal` (the silverfish), `Rabbit$RaidGardenGoal` (the rabbit), `AbstractThrownPotion` (the potion entity, extinguishing), `EatBlockGoal` (a sheep eating tall grass: the 2-argument form, **no source**), and many plant, growth, fluid and worldgen classes with a null breaker (`CropBlock`, `CactusBlock`, `SugarCaneBlock`, `BambooStalkBlock`, `ChorusFlowerBlock`, `ChorusPlantBlock`, `GrowingPlantBlock`, `HangingMossBlock`, `LilyPadBlock`, `PowderSnowBlock`, `ScaffoldingBlock`, `SnifferEggBlock`, `TurtleEggBlock`, `FrogspawnBlock`, `BigDripleafStemBlock`, `DecoratedPotBlock`, `PitcherCropBlock`, `SpeleothemBlock`, `SimpleWaterloggedBlock`, `PistonHeadBlock`, `BucketItem`, `EnderEyeItem`, the End platform and podium and huge-fungus features, `LevelWriter`; the breaker argument of each of these was not read one by one, Open question 9). Sheep eating a grass **block** (turning it into dirt) and a sheep or other mob's `ate()` post only `eat`. The sculk sensor refuses `block_destroy` and `block_place` events at its own cell (section 4.5).

#### 14.3.6 Containers (`container_open`, `container_close`)

| Poster | Trigger | Position | Source entity |
|---|---|---|---|
| `ContainerOpenersCounter.incrementOpeners` (chests, barrels, ender chests, and the other opener-counted containers) | an entity starts using the container **and the open count goes from 0 to 1** (a second opener posts nothing), after `onOpen`; a recheck is scheduled | block centre of the container | the opening `LivingEntity` passed in (the one who made the count 1) |
| `ContainerOpenersCounter.decrementOpeners` | an entity stops **and the count reaches 0** (earlier closers post nothing), after `onClose` | block centre | the closing `LivingEntity` passed in (the one who made the count 0) |
| `ContainerOpenersCounter.recheckOpeners` | every recheck recounts the actual openers (the entities with the container open). When the recount differs from the stored count: `container_open` when the stored count was 0 and the recount is above 0, `container_close` when the recount is 0 and the stored count was not (a change between two non-zero counts posts nothing), then the stored count is replaced. On **every** recheck, equal or not, `openerCountChanged(stored, recount)` is called, and when the recount is above 0 the next recheck is scheduled 5 ticks later. So the event post and the store happen only when the counts differ; the notification call and the 5-tick reschedule happen every time | block centre | **none** |
| `ShulkerBoxBlockEntity.startOpen` / `stopOpen` | a user opens or closes | block centre | the user's `LivingEntity` |
| `AbstractChestBoat.interact`, `openCustomInventoryScreen` | a player opens it | the boat's position | the player |
| `AbstractChestBoat.stopOpen`, `MinecartChest.stopOpen` | closed | the vehicle's position | the closing user |
| `MinecartChest.interact` | a player opens it | the cart's position | the player |
| `Shulker.setRawPeekAmount` (the **mob**) | each call of the setter on a server level: with 0 it adds the covered-armor modifier, plays the close sound and posts `container_close`; with a non-zero value it plays the open sound and posts `container_open` | the shulker's position | the shulker |

#### 14.3.7 `entity_interact` and `entity_action`

| Event | Poster and moment | Position | Source entity |
|---|---|---|---|
| `entity_interact` | `Mob.interact` (both exits): after the common interactions or `mobInteract` returned a result that consumes the action (so every right-click on a mob that does something) | the mob's position | the interacting player |
| `entity_interact` | `Player.interactOn`: when the target's `interact` did not consume the action and the held item's `interactLivingEntity` did (name tag, dye, and the like) | the target's position | the player |
| `entity_interact` | `Entity.interact` when a leashed entity was untied by its holder | the entity's position | the player |
| `entity_interact` | `Armadillo.brushOffScute`, `SulfurCube.mobInteract` | the mob's position | the mob itself |
| `entity_interact` | `ShelfBlock.swapHotbar` hands the event to `ShelfBlockEntity.setChanged(event)` rather than posting it itself (what that method does with it was not read, Open question 10) | | |
| `entity_action` | `Entity.interact` when the player ties held leashed mobs to this entity (for example a leash knot) | the entity's block centre | the player |
| `entity_action` | `Armadillo.rollUp` and `rollOut` | the armadillo's position | the armadillo |
| `entity_action` | `Camel.handleStartJump` (dash), `sitDown`, `standUp`, `standUpInstantly`; `AbstractNautilus.handleStartJump` | the mount's position | the mount |
| `entity_action` | `Sniffer.emitDiggingParticles` (on the digging cadence) | block centre of the sniffer's head block | the sniffer |
| `entity_action` | `Turtle.aiStep` (the laying-egg digging step, after its level event) | the turtle's position | the turtle |
| `entity_action` | `Wolf.tick` when it starts shaking off water (with the shake sound) | the wolf's position | the wolf |
| `entity_action` | `Ravager.roar` after the knockback loop | the ravager's position | the ravager |
| `entity_action` | `Creaking.hurtServer` (after entity event 66), `Creaking.aiStep` (each time the freshly computed `checkCanMove()` differs from the synced `CAN_MOVE` flag, that is each time it starts or stops being frozen), `Creaking.activate`, `Creaking.deactivate` | the creaking's position | the creaking |

#### 14.3.8 `equip`, `unequip`, item use, `drink`, `eat`

| Event | Poster and moment | Position | Source entity |
|---|---|---|---|
| `equip`, `unequip` | `LivingEntity.onEquipItem(slot, old, new)`: on a server level, not for a spectator, not when the old and new stacks are the same item with the same components, and not on the entity's first tick. `equip` when the new stack has an `equippable` component (of **any** slot), else `unequip` (including an empty stack); the equip sound plays only when the entity is not silent and the new stack's equippable slot equals the slot. Only when `doesEmitEquipEvent(slot)`: true for every slot of a non-player; for a `Player` only for the **humanoid armor** slots (so hand and offhand changes of a player post nothing) | the entity's position | the entity |
| `item_interact_start` | `LivingEntity.startUsingItem` (drawing a bow, eating, blocking) after the use flags are set; `FishingRodItem.use` when casting | the user's position | the user |
| `item_interact_finish` | `LivingEntity.stopUsingItem` when the entity was using an item (release or completion); `LivingEntity.checkTotemDeathProtection` after a totem triggered (a player also gets the totem statistic and advancement before); `FishingRodItem.use` when reeling in; `BoneMealItem.useOn` when bone meal is applied | the user's position | the user |
| `drink`, `eat` | `Consumable.onConsume` (any consumable item completed): `drink` when the item's use animation is DRINK, else `eat` | the consumer's position | the consumer |
| `drink` | `Witch.aiStep` when it drinks a potion | the witch's position | the witch |
| `eat` | `Mob.ate()` (sheep eating, foxes and others call it), `Camel.handleEating`, `AbstractHorse.handleEating`, `Panda.handleEating`; `CakeBlock.eat` (LevelAccessor form, block centre, the player) | the mob's position | the mob |

All `item_interact_*` posts from item use go through `ItemStack.causeUseVibration(entity, event)`, which posts `Entity.gameEvent(event)` only when the stack's `use_effects` component has `interact_vibrations` true. `DataComponents.COMMON_ITEM_COMPONENTS` gives every item the default `UseEffects(can_sprint false, interact_vibrations true, speed_multiplier 0.2)`; the spear family overrides it with `(true, false, 1.0)`: spears post no `item_interact_*` events. The warden hears `item_interact_finish` but not `item_interact_start` (section 3.5.1), and both are in the sneaking filter.

#### 14.3.9 `shear` and fluids

| Event | Poster and moment | Position | Source entity |
|---|---|---|---|
| `shear` | `Mob.shearItem` (removing a mob's shearable equipment), `Sheep`, `MushroomCow`, `SnowGolem`, `CopperGolem`, `Bogged`, `SulfurCube` `mobInteract` after the shear call | the mob's position | the player |
| `shear` | `Entity.dropAllLeashConnections` (shearing leashes), when at least one leash was dropped | the entity's position | the player (the argument) |
| `shear` | `BeehiveBlock.useItemOn`, `PumpkinBlock.useItemOn`, `TripWireBlock.playerWillDestroy` (section 7.5) | block centre | the player |
| `shear` | `ShearsDispenseItemBehavior` (a beehive, or an entity) | block centre of the `BlockPos` handed to the helper (the dispenser's target cell) | none |
| `fluid_pickup` | `BucketItem.use` (filling), `BottleItem.use` (water at the hit block, block centre; dragon's breath at the player's position), `BeehiveBlock.useItemOn` (honey bottle, block centre), the dispenser bucket and bottle behaviours (none source) | as stated | the player, none for dispensers |
| `fluid_pickup`, `fluid_place` | `CauldronInteractions` (bucket in a cauldron, water bottle, and so on) | block centre of the cauldron | **none**, even when a player does it |
| `fluid_place` | `BucketItem.playEmptySound` (every bucket emptied into the world), `SolidBucketItem.emptyContents` (powder snow), `PotionItem.useOn` (a water bottle on mud, source none), the dispenser bucket behaviour (anonymous class 13, none) | block centre of the filled cell | the player; none for the potion and the dispenser |

#### 14.3.10 `explode`, `lightning_strike`, `teleport`, `prime_fuse`

| Event | Poster and moment | Position | Source entity |
|---|---|---|---|
| `explode` | `ServerExplosion.explode`: first thing in the method, before the blocks and entities are processed | the explosion centre | the explosion's `source` entity (the direct entity; the `PrimedTnt` for TNT, the creeper, the fireball), null for a bed or a respawn anchor |
| `explode` | `FireworkRocketEntity.explode` | the rocket's position | the rocket's owner |
| `lightning_strike` | `LightningBolt.tick` on the tick where its `life` counter equals 2, server side only, after the fire spread (normal and hard difficulty), the lightning-rod power and the copper de-oxidation | the bolt's position | the bolt |
| `teleport` | `Enderman.teleport(x, y, z)` after a successful teleport | the position **before** the move (the departure point) | the enderman |
| `teleport` | `Shulker.teleportSomewhere` after the new position was set | block centre of the **departure** block position | the shulker |
| `teleport` | `TeleportRandomlyConsumeEffect.apply` (chorus fruit) after `randomTeleport` succeeded | the position before the move | the consumer |
| `prime_fuse` | `TntBlock.prime(level, pos, igniter)` after the entity was added and `tnt_primed` played (the block was removed first) | block centre of the TNT block | the **igniter** passed in (a player with flint and steel, a projectile's owner, a creeper..., null for redstone or fire) |
| `prime_fuse` | `Creeper.tick` when the swell direction is positive and the swell counter is 0 (fuse starts) | the creeper's position | the creeper |
| `prime_fuse` | `SulfurCube.primeTime` | the cube's position | the cube |

#### 14.3.11 Rules that post nothing (read)

- A zombie (or other `BreakDoorGoal` mob) breaking a door: `removeBlock` and level events only; **no `block_destroy`**.
- The ender dragon destroying blocks (`checkWalls`): `removeBlock`; **no `block_destroy`**. The wither does post (`Level.destroyBlock` with the wither as breaker).
- A sheep eating a grass block (to dirt), and a silverfish merging into stone (it only sets the infested block): no block event.
- Blocks moved by a piston post nothing for the move itself (the piston posts `block_activate` / `block_deactivate`); crushed blocks post `block_destroy` without a source.
- Fully absorbed damage posts no `entity_damage` (14.3.2).
- A passenger's own movement and a `NONE`-emission entity's movement (14.1.2).
- Boat and minecart dispensers post no `entity_place`.

#### 14.3.12 Index of all other posters (class names only; not decoded)

`block_activate` / `block_deactivate`: pressure plates, buttons, levers, dispensers (`dispenseFrom`), pistons (`triggerEvent`), shelves, the tripwire hook, `PotentSulfurBlock`; `block_attach` / `block_detach`: the tripwire hook, `LeashFenceKnotEntity.interact`, `LeadItem.bindPlayerMobs`; `block_change`: `Fox$FoxEatBerriesGoal`, `Rabbit$RaidGardenGoal`, `ItemFrame` (hurt, drop, interact), `FireChargeItem`, `FlintAndSteelItem`, `HoneycombItem`, `JukeboxPlayable`, `ShearsItem`, `SpawnEggItem` (on a spawner), the enchantment effect `SetBlockProperties`, `AbstractCandleBlock`, `BellBlock`, `BigDripleafBlock`, `CakeBlock`, `CampfireBlock`, `CauldronBlock`, `LayeredCauldronBlock`, `CaveVines`, `ChiseledBookShelfBlock` and its entity, `ComposterBlock`, `CopperGolemStatueBlock`, `DaylightDetectorBlock`, `DecoratedPotBlock`, `DriedGhastBlock`, `EyeblossomBlock`, `FarmlandBlock`, `PathBlock`, `FlowerPotBlock`, `LecternBlock`, `PointedDripstoneBlock`, `RespawnAnchorBlock`, `SignBlock`, `SweetBerryBushBlock`, `TurtleEggBlock`, `BeehiveBlockEntity`, `CampfireBlockEntity`, `JukeboxBlockEntity`; `block_open` / `block_close`: doors, trapdoors, fence gates; `instrument_play`: `InstrumentItem.play`; `note_block_play`: `NoteBlock.playNote`; `jukebox_play` / `jukebox_stop_play`: `JukeboxSongPlayer`, `JukeboxBlockEntity.setRemoved`; `shriek` and `sculk_sensor_tendrils_clicking`: sections 4 and 6; `ShelfBlockEntity.setChanged` posts `block_activate`, and `ShelfBlock.neighborChanged` posts `block_activate` / `block_deactivate`.

## 15. Open questions (game-event emission)

Numbering restarts here; section 13 keeps its own list. Each item says what was searched.

1. **Fox crouching flag.** `Fox.isCrouching` returns a synced flag (flag bit 4); its setter conditions (when a fox crouches) were not read. It matters for the step test of 14.1.4 (`isCrouching() and m.y == 0`). Searched: `Entity.isCrouching`, `Fox.isCrouching`; `isSteppingCarefully` is not overridden by the fox.
2. **Passengers and `stepOn`.** 14.1.11 shows no passenger test in `Entity.applyEffectsFromBlocks`; whether a passenger's `onGround()` can be true while riding (so that a rider triggers `stepOn` of the block under the vehicle) was not read. Searched: `Entity.applyEffectsFromBlocks`, `LivingEntity.aiStep`.
3. **Splash overrides.** `ExperienceOrb` overrides `doWaterSplashEffect` and `AbstractCubeMob` calls it directly; their bodies and whether they post `splash` (14.1.8) were not read. Searched: callers and overrides by name.
4. (closed: the dragon's flap phase advance is read, 14.1.6.)
5. **Chunk loading by the occlusion ray.** See 31-8 open question 16.
6. **Player tick order.** The order of the movement packet handling (14.1.1) against `ServerPlayer.tick` / `aiStep` (and so of `stepOn` relative to the step event within one server tick) is the tick order of 33 section 2 and was not re-traced for a player.
7. **Bounce details.** The reflected vertical value in `Entity.restituteMovementAfterCollisions` (a function of the resolved to wanted vertical ratio, the effective gravity and the air drag) was not transcribed; the guard, the block restitution values and the per-dye collection are in 14.1.1 step 5 and 14.1.9. Searched: `Entity.restituteMovementAfterCollisions`, the `Blocks` initializer by the property calls.
8. **`killedEntity` returning false.** 14.3.2 states the `entity_die` post is skipped when the killer's `killedEntity` returns false; the `Zombie` override's false case (assumed: a villager converted to a zombie villager) and the `Creeper` and `Player` overrides' return values were only skimmed. Searched: the four declaring classes.
9. **Breakers of the growth callers of `Level.destroyBlock`.** 14.3.5 lists the callers; the breaker argument was read only for the entity callers and `EatBlockGoal`.
10. **Shelf events.** `ShelfBlock.swapHotbar` and `swapSingleItem` pass `entity_interact` / `item_interact_finish` to `ShelfBlockEntity.setChanged(event)`; how that method posts it (position, source) was not read.
11. **Dispenser behaviour classes 1 and 12.** `DispenseItemBehavior` anonymous classes 1 and 12 contain no game-event reference and were not identified.
12. **`OminousItemSpawner` source entity.** The entity passed as source is inferred to be the item entity the method just added; its identity was not confirmed by a named accessor.
13. **Spawning with a vehicle.** `EntityType.spawn`'s `startRiding` call passes an emit flag that was not read (it is one of the callers listed in 14.1.9 only as the 3-argument form).
14. **Block placement by dispensers through `BlockItem`.** Whether the dispenser's shulker-box and similar placements reach `BlockItem.place` with a null player (so that `block_place` has no source) was inferred from the nullable player of the placing context, not traced through `DispenserBlock`.
15. **`ItemStack.interactLivingEntity` items.** Which items consume the action there (14.3.7, second row) was not enumerated.
16. (closed: the warden touch candidates, including the `isPushable` overrides, are in 20 section 15.5.)
17. **Packet handler versus level tick.** The position of the queued movement-packet handler (`ServerGamePacketListenerImpl.handleMovePlayer`, queued by `ensureRunningOnSameThread`) relative to the level tick that runs the player's self-simulation (33 section 1.2 steps 6 and 7) inside one server tick was not traced; it decides whether, with a vertical displacement of 0, the on-ground flag seen by the replay pass comes from the last self-simulation or from the previous packet (14.1.1). Searched: `handleMovePlayer`, `handlePlayerPositionChange`, `PacketUtils.ensureRunningOnSameThread` (by name), `LivingEntity.aiStep`, `Player.travel`, `LivingEntity.applyInput`.
