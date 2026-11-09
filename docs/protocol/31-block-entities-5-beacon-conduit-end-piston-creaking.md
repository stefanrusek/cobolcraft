# 31-5 Block entities, part 5: beacon, conduit, end portal, end gateway, piston moving block, creaking heart

| Item | Value |
|---|---|
| Covers | Six block entity types: `beacon` (`BeaconBlockEntity`, `BeaconBeamOwner`, `BeaconBlock`, `BeaconMenu`, the Set Beacon handler), `conduit` (`ConduitBlockEntity`, `ConduitBlock`), `end_portal` (`TheEndPortalBlockEntity`, `EndPortalBlock`), `end_gateway` (`TheEndGatewayBlockEntity`, `EndGatewayBlock`), `piston` (`PistonMovingBlockEntity`, pointer only) and `creaking_heart` (`CreakingHeartBlockEntity`, `CreakingHeartBlock`). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of data files (`unzip -p`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Round | RS13 (GAP-8 of `../design/README.md` Part 5), sibling of 31 parts 1 to 4 and 6 to 8. This document closes the "31-5 or 31-6 (file absent)" owner column of 31-8 section 11 for these six types. |
| Data versus code | Tags (`beacon_base_blocks`, `beacon_payment_items`, `conduit_effect_block`, `pale_oak_logs`), loot tables, recipes, the `timeline/day` attribute keyframes and the `end_gateway` feature configs are DATA (22, 23). This part specifies the block entity state and the engines around it. |

Related documents, not repeated here: 31-1 (shared block entity model: `saveWithoutMetadata`, `saveCustomOnly`, `loadAdditional`, `components`, update tag and Block Entity Data rules, the type id table), 31-8 section 11 (the per-type summary rows), 05a id 6 (Block Entity Data), 05c id 0x35 (Set Beacon), 46 section 4.1 (the mob effect id plus one encoding of the beacon menu slots), 30-3 (pistons: the whole moving block entity, sections 7 and 8), 29 (block change pipeline, `blockEvent`), 33 (tick order; block entities tick only while the level is not idle), 44-5 (the creaking mob), 45 (entity references and UUID codecs), 26 (loot).

---

## 0. Reader's map

| Question | Section |
|---|---|
| Types, valid blocks, tickers, update packets | 1 |
| Beacon: keys, beam scan, base scan, effects, menu, packet validation, advancement, sounds | 2 |
| Conduit: keys, shape scan, effects, hunting and damage | 3 |
| End portal and end gateway | 4 |
| Piston moving block entity | 5 |
| Creaking heart | 6 |
| Worked examples | 7 |
| Open questions | 8 |

---

## 1. Types, blocks, tickers

| Registry key | Class | Valid block | Own NBT keys | Ticker | Update tag and packet (31-8 section 11) |
|---|---|---|---|---|---|
| `beacon` | `BeaconBlockEntity` | `beacon` | `primary_effect`, `secondary_effect`, `Levels` (written, never read), `CustomName`, `lock` (via `LockCode`) | both sides, `BeaconBlockEntity.tick` | yes: `saveCustomOnly` as update tag, Block Entity Data packet |
| `conduit` | `ConduitBlockEntity` | `conduit` | `Target` (entity reference) | client `clientTick`, server `serverTick` (chosen by `ConduitBlock.getTicker` from `isClientSide`) | yes |
| `end_portal` | `TheEndPortalBlockEntity` | `end_portal` | none | none | none |
| `end_gateway` | `TheEndGatewayBlockEntity` (extends the end portal entity) | `end_gateway` | `Age`, `exit_portal`, `ExactTeleport` | client `beamAnimationTick`, server `portalTick` | yes |
| `piston` | `PistonMovingBlockEntity` | `moving_piston` | see 30-3 section 7 | both | no packet (31-8) |
| `creaking_heart` | `CreakingHeartBlockEntity` | `creaking_heart` | `creaking` (UUID) | server only, and only while the `state` property is not `uprooted` | yes |

The end portal entity writes and reads nothing of its own; the block `end_portal` creates it with the (pos, state) constructor.

---

## 2. Beacon

### 2.1 State

| Field | Type | Persisted | Meaning |
|---|---|---|---|
| `primaryPower`, `secondaryPower` | mob effect or none | yes | the chosen effects |
| `levels` | int | written as `Levels`, never loaded (a loaded entity starts at 0) | pyramid tiers, 0 to 4 |
| `beamSections` | list of (color int, height int) | no | the beam as last completed |
| `checkingBeamSections` | list | no | the beam being scanned |
| `lastCheckY` | int | no | height of the last scanned cell; `setLevel` sets it to `minY - 1` |
| `name` | text component or none | `CustomName` | default display name is the translation key `container.beacon` |
| `lockKey` | `LockCode` | yes (`LockCode.addToTag`, key `lock`) | a locked beacon refuses the menu |

Effect keys hold the effect's identifier string (such as `minecraft:speed`). Loading an effect: read the key with the mob effect registry by-name codec, then keep it only when it is in the valid effect set (the union of the tiers below), else none. Saving writes the key only when an effect is set.

Tier table (`BEACON_EFFECTS`; list index plus one is the tier, called "required levels"):

| Tier (required levels) | Effects |
|---|---|
| 1 | `speed`, `haste` |
| 2 | `resistance`, `jump_boost` |
| 3 | `strength` |
| 4 | `regeneration` |

An effect outside the table has required levels 2147483647.

Item components: `CustomName` reads from and collects to the `custom_name` component and `lock` to the `lock` component (set only when it differs from no-lock); both keys are removed from the tag when components exist (`removeComponentsFromTag`). The block loot table `blocks/beacon` has one pool, one roll, the item `beacon` with `copy_components` of `custom_name` from the block entity.

### 2.2 Tick (`tick`, every tick on both sides)

Let `(x, y, z)` be the beacon cell and `surface = level.getHeight(WORLD_SURFACE, x, z)`.

1. Choose the scan cell `p`. If `lastCheckY < y` (a new scan): `checkingBeamSections` becomes an empty list, `lastCheckY = y - 1`, and `p = (x, y, z)`, the beacon cell itself. Otherwise `p = (x, lastCheckY + 1, z)`.
2. `last` is the last entry of `checkingBeamSections`, or none when it is empty.
3. Scan at most **10** cells upward (`BLOCKS_CHECK_PER_TICK`), stopping early when `p.y > surface`. For each cell, with `state = blockState(p)`:
   - If the block is a beam block (`BeaconBeamBlock`: the beacon, every `stained_glass` and every `stained_glass_pane`; each reports a `DyeColor`, the beacon reports white), let `c` be that colour's texture diffuse colour (an int).
     - If `checkingBeamSections` has 0 or 1 entries: append a new section `(c, height 1)`. (The first beam cell is the beacon itself, which creates the base section; the first coloured glass above it creates its own section with exactly its colour.)
     - Else if `last` exists: when `c` equals `last.color`, `last.height += 1`; otherwise append a section whose colour is `ARGB.average(last.color, c)` and height 1.
   - Any other block: if `last` is none, or (`state.getLightDampening() >= 15` and the block is not bedrock), clear `checkingBeamSections`, set `lastCheckY = surface` and stop scanning (the beam is blocked). Otherwise `last.height += 1`.
   - Next cell: `p = p.above()` and `lastCheckY += 1`.
4. `prevLevels = levels`.
5. If `gameTime % 80 == 0`: when `beamSections` is not empty, `levels = updateBase(level, x, y, z)`; then when `levels > 0` and `beamSections` is not empty, run `applyEffects` (2.4) with the stored effects and play `beacon.ambient` (2.6).
6. If `lastCheckY >= surface` (the scan reached the top): `lastCheckY = minY - 1`; `wasActive = prevLevels > 0`; `beamSections = checkingBeamSections`; and on the server only, `isActive = levels > 0`: when not `wasActive` and `isActive`, play `beacon.activate` and fire the construct-beacon criterion with the current `levels` for every `ServerPlayer` in the advancement box; when `wasActive` and not `isActive`, play `beacon.deactivate`.

Advancement box: corners `(x, y, z)` and `(x, y - 4, z)` inflated by 10 on x, 5 on y and 10 on z, that is x and z within 10 of the beacon and y from `y - 9` to `y + 5`.

As read, `levels` is only recomputed on the 80-tick pulse while the beam is open. A beam that becomes blocked leaves `levels` unchanged until it opens again; effects stop because `beamSections` is empty, and `beacon.deactivate` plays only when `levels` falls to 0 with an open beam, or on removal (2.6).

### 2.3 Base scan (`updateBase`)

For `i = 1, 2, 3, 4` in order, with `yy = y - i`: stop when `yy < level.minY`. The layer passes when every cell `(x', yy, z')` with `|x' - x| <= i` and `|z' - z| <= i` is in the block tag `beacon_base_blocks` (netherite, emerald, diamond, gold, iron block). A pass sets the result to `i` and continues; the first failing layer stops the loop. The result is 0 to 4. Layer `i` is a (2i+1) by (2i+1) square, so the tiers need 9, 25, 49 and 81 blocks.

### 2.4 Effects (`applyEffects`)

Skipped on the client and when `primary` is none.

| Quantity | Value |
|---|---|
| range | `levels * 10 + 10` blocks |
| duration (ticks) | `(9 + 2 * levels) * 20` |
| primary amplifier | 1 when `levels >= 4` and `primary` equals `secondary` (null-safe equality), else 0 |
| search box | the beacon cell box inflated by `range` on all axes, then extended upward by `level.getHeight()` |

Every `Player` in the box receives `(primary, duration, amplifier, ambient = true, visible = true)`. Then, when `levels >= 4`, `primary != secondary` and `secondary` is set, every player of the same list receives `(secondary, duration, amplifier 0, ambient true, visible true)`.

### 2.5 Menu, payment and the Set Beacon handler

- Opening: `BeaconBlock.useWithoutItem` on the server opens the menu through the block entity and awards the statistic `interact_with_beacon`, result success. `createMenu` first checks `lockKey.canUnlock(player)`; when false no menu opens and the locked-container notifications (31-1) are sent for the display name.
- `BeaconMenu`: one payment slot (menu slot 0, screen position 136, 110, max stack size 1, accepts the tag `beacon_payment_items`: netherite ingot, emerald, diamond, gold ingot, iron ingot), then the 36 standard inventory slots (main inventory menu slots 1 to 27, hotbar 28 to 36, inventory drawn from y 137). `stillValid` is the standard check against the `beacon` block at the access position. Closing the menu on the server drops the payment slot content to the player.
- Data slots (3, synced like any container data): 0 = `levels`, 1 = primary effect, 2 = secondary effect. Effects travel as `registry id + 1`, 0 meaning none (46 section 4.1). Setting slot 1 or 2 on the block entity decodes the value and keeps it only when it is in the valid effect set. Setting slot 1 on the server while `beamSections` is non-empty also plays `beacon.power_select`.
- Quick move: from the payment slot into slots 1 to 36 (searching in reverse order); from an inventory slot into the payment slot when it is empty, the stack is a valid payment and its count is exactly 1; otherwise main inventory slots move to the hotbar, hotbar slots to the main inventory, and anything else across slots 1 to 36.
- `updateEffects(primaryOpt, secondaryOpt)` (called by the Set Beacon handler) fails when the payment slot is empty. Otherwise `validateEffects(primary, secondary, levels)` must hold, else it fails. On success: set data slots 1 and 2 to the encoded effects, remove one item from the payment slot, run a level-access callback (body not identified, Open question 1), return true.
- `validateEffects(primary, secondary, levels)`:
  1. if `secondary` is set and `levels < 4`: invalid;
  2. `reqP` and `reqS` are the required levels of each (0 for none);
  3. if `reqP > levels` or `reqS > levels`: invalid;
  4. if `reqP >= 4`: invalid (regeneration is never a primary);
  5. if `reqS != 0` and `reqS < 4` and `primary.equals(secondary)` is false: invalid (a secondary below tier 4 must repeat the primary; the primary is the receiver, the first loaded operand, and the call is not null-safe, unlike the `Objects.equals` of `applyEffects`, so a null primary with a secondary of required level 1 to 3 would fail at that call rather than compare as unequal);
  6. otherwise valid.
- Set Beacon (05c 0x35, two optional mob effects): on the server thread, if the player's open menu is a `BeaconMenu`: when `stillValid` is false, log at debug and ignore; else call `updateEffects`, and when it returns false disconnect the player with the translation `multiplayer.disconnect.generic` and log "tried to set invalid beacon effects". If the open menu is not a beacon menu the packet is ignored.

### 2.6 Sounds and removal

All played at the beacon, category blocks, volume 1, pitch 1, with no source entity.

| Event | Sound |
|---|---|
| beam becomes active | `beacon.activate` |
| ambient pulse (every 80 ticks, active) | `beacon.ambient` |
| deactivation, and `setRemoved` (removal always plays it) | `beacon.deactivate` |
| primary effect changed through the menu with an open beam | `beacon.power_select` |

### 2.7 Client side

The client runs the same `tick` and receives `primary_effect`, `secondary_effect`, `Levels` and `CustomName` in the update tag, but not `beamSections`; it recomputes the beam from its own loaded blocks. The renderer (`BeaconRenderState.Section`), the shader `rendertype_beacon_beam` and `BeaconScreen` are cited, not specified (12).

---

## 3. Conduit

### 3.1 State and NBT

| Field | Persisted | Meaning |
|---|---|---|
| `tickCount` | no | +1 every tick |
| `isActive`, `isHunting` | no | recomputed every 40 ticks |
| `effectBlocks` | no | frame positions found by the last shape scan |
| `destroyTarget` | `Target` (entity reference; `EntityReference.read` and `store`, storage form as 45) | the mob being attacked |
| `nextAmbientSoundActivation` | no | game time of the next short ambient sound |

Constants read: `MIN_ACTIVE_SIZE = 16`, `MIN_KILL_SIZE = 42`, `KILL_RANGE = 8`, `ROTATION_SPEED = -0.0375`, `BLOCK_REFRESH_RATE = 2` and `EFFECT_DURATION = 13` (neither used by the tick code read; the effect duration used is 260, section 3.4). The block has the property `waterlogged` (default true), a fixed shape and is not pathfindable; loot `blocks/conduit` drops the item `conduit` unconditionally.

### 3.2 Shape scan (`updateShape`)

1. Clear `effectBlocks`.
2. Water check: every cell at offset `(dx, dy, dz)` with each coordinate in `-1..1` (27 cells) must satisfy `Level.isWaterAt`; if one does not, return **false** at once with the list empty.
3. Frame scan: for every offset with each coordinate in `-2..2`, skip offsets whose three `|d|` are all at most 1. Keep an offset when one of these holds: `dx == 0` and (`|dy| == 2` or `|dz| == 2`); `dy == 0` and (`|dx| == 2` or `|dz| == 2`); `dz == 0` and (`|dx| == 2` or `|dy| == 2`). For every kept offset whose block is in the tag `conduit_effect_block` (prismarine, prismarine bricks, sea lantern, dark prismarine) append the position.
4. Return `effectBlocks.size() >= 16`.

The kept offsets form three orthogonal 16-cell rings; the six axis points `(0,0,+-2)`, `(0,+-2,0)`, `(+-2,0,0)` lie on two rings and count once, so the maximum is 42, equal to `MIN_KILL_SIZE`.

### 3.3 Server tick (`serverTick`)

1. `tickCount += 1`; `t = gameTime`.
2. If `t % 40 == 0`: `active = updateShape(...)`. When `active` differs from `isActive`, play `conduit.activate` (becoming active) or `conduit.deactivate` at the conduit (blocks, volume 1, pitch 1, no source entity). Set `isActive = active`; `isHunting = (effectBlocks.size() >= 42)`. When `active`: apply effects (3.4) and run `updateAndAttackTarget` (3.5) with `canKill = effectBlocks.size() >= 42`.
3. If `isActive`: when `t % 80 == 0` play `conduit.ambient`; when `t > nextAmbientSoundActivation`, set it to `t + 60 + random.nextInt(40)` (level random) and play `conduit.ambient_short`.

Shape scan, effects and attack therefore run only on game times divisible by 40.

### 3.4 Effects (`applyEffects`)

`n = effectBlocks.size()`; `range = (n / 7) * 16` (integer division). The box is the conduit cell box inflated by `range`, extended upward by `level.getHeight()`. Every `Player` in the box whose `blockPosition` is strictly closer than `range` to the conduit (`BlockPos.closerThan`, Euclidean) and who `isInWaterOrRain()` gets `conduit_power` for 260 ticks, amplifier 0, ambient true, visible true. With 16 blocks the range is 32; with 42 it is 96.

### 3.5 Hunting (`updateAndAttackTarget`)

1. New target `updateDestroyTarget(current, level, pos, canKill)`: not `canKill` gives none; a none current target gives `selectNewTarget`; otherwise resolve the current reference and keep it only when the entity exists, is alive and its `blockPosition` is closer than 8 to the conduit, else none (no new pick on the same pulse).
2. `selectNewTarget`: living entities in the conduit cell box inflated by 8 that are an `Enemy` and `isInWaterOrRain()`; an empty list gives none; else one is chosen with `Util.getRandom(list, level random)` (a uniform index draw).
3. If the resolved target exists: play `conduit.attack_target` at its position (blocks, volume 1, pitch 1) and call `hurtServer(level, magic damage source, 4.0)`.
4. When the new reference differs (null-safe equality) from the stored one, store it and `sendBlockUpdated(pos, state, state, 2)` so clients receive `Target`.

### 3.6 Client tick

The client increments `tickCount`, runs the shape scan on `t % 40 == 0` (setting `isActive` and `isHunting` itself), spawns `nautilus` particles and adds 1 to `activeRotation` each tick while active. Rotation is `(activeRotation + partial) * -0.0375`.

Particles (presentation, level random): with `h = sin((tickCount + 35) * 0.1) / 2 + 0.5` and `b = (h*h + h) * 0.3`, the emitter origin is `(x + 0.5, y + 1.5 + b, z + 0.5)`. For each frame position, with probability 1/50 (`nextInt(50) == 0`), spawn one `nautilus` particle at that origin with velocity `(-0.5 + f1 + dx, -2.0 + f2 + dy, -0.5 + f3 + dz)`, where `d` is the frame cell's offset from the conduit and `f1..f3` are three `nextFloat()` draws in x, y, z order. When a target exists, one particle per tick is spawned from the target's position `(x, eyeY, z)` toward `(( -0.5 + f1) * (3 + bbWidth), -1 + f2 * bbHeight, (-0.5 + f3) * (3 + bbWidth))` (the `-1.0 + f * height` form as read; operand grouping inferred).

---

## 4. End portal and end gateway

### 4.1 End portal

`TheEndPortalBlockEntity` has no state and no NBT. Its only behaviour is `shouldRenderFace(direction)`, true only for faces on the Y axis. The behaviour is in the block:

- `EndPortalBlock.entityInside`: when `entity.canUsePortal(false)`: on the server, in the End dimension, for a `ServerPlayer` that has not seen the credits yet, `showEndCredits()` is called (the intermediate tests are not decoded, Open question 2); then `entity.setAsInsidePortal(block, pos)`.
- `getPortalDestination(level, entity, pos)`. In a level other than the End: the target is the End level at `ServerLevel.END_SPAWN_POINT` (bottom centre); `EndPlatformFeature.createEndPlatform(level, spawn.below(), true)` is run when the entity is not a player-less transition (the guard was not isolated); yaw is `Direction.WEST.toYRot()`, pitch 0, relative flags `DELTA` and `X_ROT`. In the End: the target is the world respawn data (dimension and position); a `ServerPlayer` uses `findRespawnPositionAndUseSpawnBlock(false, do-nothing)`, other entities use `adjustSpawnLocation`; the post-transition steps are play portal sound and place portal ticket.
- The portal travel engine (`Entity.setAsInsidePortal`, portal delay, `changeDimension`) is not specified here (Open question 3). Shape and push reaction (immovable): 24, 30-3 section 5.

### 4.2 End gateway state

| Field | Key | Type and default | Meaning |
|---|---|---|---|
| `age` | `Age` | long, 0 | ticks since placement, always written |
| `exitPortal` | `exit_portal` | block position codec; key absent when null (`storeNullable`) | destination; on load kept only if a predicate accepts it (body not identified, Open question 4) |
| `exactTeleport` | `ExactTeleport` | boolean, false; written only when true | teleport to exactly `exit_portal` instead of searching near it |
| `teleportCooldown` | none | int | remaining cooldown ticks |

Constants: `SPAWN_TIME = 200`, `COOLDOWN_TIME = 40`, `ATTENTION_INTERVAL = 2400`, `EVENT_COOLDOWN = 1` (the block event id), `GATEWAY_HEIGHT_ABOVE_SURFACE = 10`.

`isSpawning` is `age < 200`; `isCoolingDown` is `teleportCooldown > 0`. Beam fractions (client): spawn percent `clamp((age + partial) / 200, 0, 1)`; cooldown percent `1 - clamp((teleportCooldown - partial) / 40, 0, 1)` (read: one minus the clamped quotient, the partial term subtracted from `teleportCooldown`). Face rendering: `shouldRenderFace(direction)` consults `Block.shouldRenderFace` against the neighbour; `getParticleAmount` counts the faces that render.

### 4.3 Tick

- Client `beamAnimationTick`: `age += 1`; when cooling down, `teleportCooldown -= 1`.
- Server `portalTick`: record `wasSpawning` and `wasCooling`; `age += 1`; when cooling down `teleportCooldown -= 1`, otherwise when `age % 2400 == 0` call `triggerCooldown`; finally when `isSpawning` or `isCoolingDown` differs from the recorded value, call `setChanged` (the sync follows 31-1).
- `triggerCooldown`: server only: `teleportCooldown = 40`, `level.blockEvent(pos, block, 1, 0)`, `setChanged`. The block event with id 1 sets `teleportCooldown = 40` on clients (`triggerEvent`).
- `EndGatewayBlock.entityInside`: when `entity.canUsePortal(false)`, on the server, with the block entity present and not cooling down: `entity.setAsInsidePortal(block, pos)`, then `triggerCooldown`.
- The block's `animateTick` spawns `portal` particles (count `getParticleAmount`, random draws from the level random; formula not tabulated, presentation).

### 4.4 Destination

`getPortalPosition(level, pos)` returns an exact bottom-centre position or null:

1. When `exitPortal` is null and the level is the End: `target = findOrCreateValidTeleportPos(level, pos)` raised by 10 blocks; a gateway is generated there with `EndGatewayFeature.knownExit(pos, false)` (`spawnGatewayPortal`, with an unseeded random source); then `setExitPosition(target, exactTeleport)`.
2. When `exitPortal` is non-null: the bottom centre of `exitPortal` itself when `exactTeleport`, else of `findExitPosition(level, exitPortal)`.
3. Otherwise null; the block's `getPortalDestination` then returns the "no destination" transition result.

`findExitPosition(level, exit)` is `findTallestBlock(level, exit + (0, 2, 0), 5, false)` then `.above()`.

`findOrCreateValidTeleportPos(level, gatewayPos)`:
1. `tentative = findExitPortalXZPosTentative(level, gatewayPos)`.
2. Get the chunk at that position (floor division by 16) and call `findValidSpawnInChunk`.
3. When none is found: take the position `(tentative.x + 0.5, 75.0, tentative.z + 0.5)` and run the registered configured feature `end_island` there with a random source seeded by `pos.asLong()`; log "spawning an island".
4. Return `findTallestBlock(level, thatPos, 16, true)`.

`findExitPortalXZPosTentative`: `unit` is the normalised horizontal vector `(gatewayX, 0, gatewayZ)`; `v = unit * 1024`. Step backwards by `unit * -16` while the chunk at `v` is not empty (empty means `getHighestFilledSectionIndex() == -1`), then forwards by `unit * 16` while the chunk at `v` is empty; each loop has its own counter that starts at 16 and is decremented once per passing test, so each loop runs at most 16 steps: the backward loop runs while the chunk at `v` is not empty, stepping `unit * -16`; the forward loop then runs while the chunk is empty, stepping `unit * 16`. The result is the vector `v` (not a block position). The chunk lookup is `floor(v.x / 16), floor(v.z / 16)`. The log lines are "Skipping backwards past nonempty chunk", "Skipping forward past empty chunk" and "Found chunk at".

`findValidSpawnInChunk(chunk)` scans a box with min corner `(minBlockX, 30, minBlockZ)` (the y of 30 is a constant, the same on every call) and max corner `(maxBlockX, highestSectionPosition + 16 - 1, maxBlockZ)`, iterating `BlockPos.betweenClosed` from the min to the max corner. A cell is a candidate when it is `end_stone` and the two cells above it are not full-collision blocks. The distance is `distToCenterSqr` to the world origin `(0, 0, 0)`; a candidate replaces the current best only when its distance is strictly smaller (the first candidate always becomes best). The result is null when there is none.

`findTallestBlock(getter, pos, radius, flag)`:
1. Visit every column `(dx, dz)` with `dx` and `dz` in `-radius..radius`, `dx` as the outer loop and `dz` as the inner.
2. When `flag` is false, skip the column `(0, 0)`.
3. In each column scan `y` downward from the getter's max build height, continuing only while `y` is higher than the best position found so far (or the getter's min y when none yet; re-evaluated at each step).
4. The first cell whose collision shape is a full block is a candidate: it is accepted when `flag` is true, or when `flag` is false and the block is not bedrock (with `flag` false a bedrock full block is passed over and the scan continues downward). An accepted candidate becomes the new best and ends the column.
5. The result is the best position, or the input `pos` when nothing was accepted.

So `findExitPosition` (flag false) skips the centre column and rejects bedrock, while `findOrCreateValidTeleportPos` step 4 (flag true, radius 16) includes the centre column and accepts bedrock.

The data features are `worldgen/feature/end_gateway_return` (`exact: false`) and `end_gateway_delayed` (`exact: true`, `exit: [100, 50, 0]`).

---

## 5. Piston moving block entity

Specified in 30-3: state and constants (section 7), progress per tick (7.2), finishing (7.4), collision shape (7.5), NBT keys `blockState`, `facing`, `progress`, `extending`, `source` (section 7, saved with `saveCustomOnly`, no Block Entity Data packet, per 31-8 row 11), entity pushing (section 8), client (section 10). The entity is created only by code, never by `MovingPistonBlock.newBlockEntity`. Nothing is added here.

---

## 6. Creaking heart

### 6.1 Block

Properties: `axis` (default y), `state` of type `CreakingHeartState` (`uprooted`, `dormant`, `awake`; default `uprooted`) and `natural` (default false). Placement sets `axis` from the clicked face's axis and then runs `updateState`; `rotate` is pillar rotation. The ticker exists on the server only and only when `state != uprooted`. `hasAnalogOutputSignal` is true; the output is 0 for `uprooted`, otherwise the block entity's cached `outputSignal`. `affectNeighborsAfterRemoval` calls `Containers.updateNeighboursAfterDestroy`.

`hasRequiredLogs(state, level, pos)`: for both directions along the block's `axis`, the neighbour must be in the tag `pale_oak_logs` (`pale_oak_log`, `pale_oak_wood`, `stripped_pale_oak_log`, `stripped_pale_oak_wood`) and its own `axis` property must equal the heart's `axis`.

`updateState(state, level, pos)` (block): when `hasRequiredLogs` is true and the state is `uprooted`, return the state with `state` set to `awake` when the environment attribute `gameplay/creaking_active` at `pos` is true, else `dormant`; in every other case return the state unchanged. The block never sets `uprooted` here; that is done by the block entity (6.3 step 5). `updateShape` schedules a block tick with delay 1; the scheduled `tick` runs `updateState` and `setBlockAndUpdate` on change.

The attribute `gameplay/creaking_active` is a boolean (default false, syncable). The data `timeline/day` sets it with modifier `or`: true from tick 12600 and false from tick 23401 of a 24000-tick period (read from `data/minecraft/timeline/day.json`). A heart is therefore active from tick 12600 until tick 23401 of the day.

`animateTick` (client, presentation): returns at once when the environment attribute `gameplay/creaking_active` at the position is false, and also when the state property is `uprooted`. Only then it draws `nextInt(16)` and, on 0, tests that all six neighbours are `pale_oak_logs` (tag only, no axis test); when both hold it plays `creaking_heart.idle` with `Level.playLocalSound` at the integer cell coordinates `(x, y, z)` (not the centre), category blocks, volume 1, pitch 1, distance-delay false.

Breaking and explosions: `playerWillDestroy` calls `removeProtector(playerAttack damage source)` and then `tryAwardExperience`. `onExplosionHit`, for a server explosion whose block interaction affects block-like entities, calls `removeProtector(explosion damage source)` and, when the indirect source is a player, `tryAwardExperience`. `tryAwardExperience` pops experience `nextIntBetweenInclusive(20, 24)` when the player does not prevent block drops, is not a spectator, the block has `natural = true` and the level is a `ServerLevel` (an `instanceof` test, then a cast); the amount comes from the level random. Loot `blocks/creaking_heart`: an `alternatives` entry whose first child, conditioned on `tool/can_silk_touch`, drops `creaking_heart`; the second child drops the item `resin_clump` with four modifiers in order: `set_count` uniform 1 to 3; `apply_bonus` fortune with formula `uniform_bonus_count` and `bonusMultiplier` 1; `limit_count` max 9; `explosion_decay`. `rolls` is 1 and `random_sequence` is `blocks/creaking_heart`.

### 6.2 Block entity state

| Field | Persisted | Meaning |
|---|---|---|
| `creakingInfo` | key `creaking` (UUID, `UUIDUtil.CODEC`), written only when set | either a live `Creaking` (left) or its UUID (right) |
| `ticksExisted` | no | +1 per server tick; reset to 0 whenever the UUID form is stored |
| `ticker` | no | countdown to the next logic run |
| `emitter` | no | remaining ticks of the hurt particle trail, up to 100 |
| `emitterTarget` | no | the creaking's centre when it was hurt |
| `outputSignal` | no | cached comparator output |

Loading a present `creaking` calls `setCreakingInfo(uuid)`; with the key absent the link is cleared. Every `setCreakingInfo` and `clearCreakingInfo` calls `setChanged`.

### 6.3 Server tick (`serverTick`)

1. `ticksExisted += 1`. If the level is not a `ServerLevel`, stop.
2. `signal = computeAnalogOutputSignal()`; when it differs from `outputSignal`, store it and call `updateNeighbourForOutputSignal(pos, creaking_heart)`.
3. If `emitter > 0`: when `emitter > 50` emit particles twice, `emitParticles(level, 1, true)` then `(1, false)`; otherwise once, `(1, false)`. When `emitter % 10 == 0` and `emitterTarget` is set: if a protector exists set `emitterTarget` to the centre of its bounding box; then play `creaking_heart.hurt` (blocks, volume 1) at the block containing `emitterTarget + (heartCentre - emitterTarget) * (0.2 + 0.8 * (100 - emitter) / 100)`, with pitch `0.5 + (emitter / 2) / 100`. Then `emitter -= 1`.
4. `ticker -= 1`; when `ticker >= 0` stop. Otherwise `ticker = 20 + random.nextInt(5)` (level random; 20 when no level).
5. `newState = updateCreakingState(...)`: when it differs from the block's state, `setBlockAndUpdate`; when the new `state` is `uprooted`, stop. `updateCreakingState` returns `uprooted` when the heart lacks required logs and has no linked creaking; otherwise `awake` when the attribute is true, else `dormant`.
6. When a link exists (`creakingInfo` non-null): resolve the protector (6.5). When present, remove the link with `removeProtector(null)` if any of these holds: the attribute is false and the creaking does not require persistence (`isPersistenceRequired`); `distanceToCreaking() > 34`; `creaking.playerIsStuckInYou()` is true. Stop.
7. No link: stop unless `state == awake`. Stop when `level.isSpawningMonsters()` is false or the difficulty is `peaceful`. When `getNearestPlayer(x, y, z, 32.0, false)` finds a player: `spawnProtector`; when it returns a creaking, `setCreakingInfo(creaking)`, the creaking plays `creaking.spawn` and the block plays `creaking_heart.spawn` (blocks, volume 1, pitch 1, no source entity).

### 6.4 Spawning (`spawnProtector`)

`SpawnUtil.trySpawnMob(creaking type, spawn reason SPAWNER, level, heart position, attempts 5, horizontal range 16, vertical range 8, strategy ON_TOP_OF_COLLIDER_NO_LEAVES, check collisions true)`. When it returns empty nothing spawns. Otherwise: `gameEvent(creaking, ENTITY_PLACE, position)`, `broadcastEntityEvent(creaking, 60)` and `creaking.setTransient(heartPos)`. The placement search and the Creaking mob are cited, not specified (44-5, Open question 5).

### 6.5 Link resolution (`getCreakingProtector`)

- No info: none.
- Left (entity): when not removed, that entity; when removed, convert to its UUID with `setCreakingInfo(uuid)` (resets `ticksExisted`) and continue as right.
- Right (UUID), on a server level only: look the entity up by UUID; when it is a `Creaking`, store it as left and return it. When it is not found: if `ticksExisted >= 30` (`TICKS_GRACE_PERIOD`) clear the link. Return none.

### 6.6 Hurt, resin, removal, comparator

- `creakingHurt()` (called when the creaking takes damage): needs a protector and a server level; stop when `emitter > 0`. Emit 20 particles (`emitParticles(level, 20, false)`). When the heart is `awake`: `n = nextIntBetweenInclusive(2, 3)` (level random); `n` times call `spreadResin` and for each returned position play `resin_place` there and fire the game event `block_place` with the heart's state. Then `emitter = 100` and `emitterTarget` = the centre of the protector's bounding box.
- `spreadResin`: breadth-first traversal from the heart position over `pale_oak_logs` cells (`BlockPos.breadthFirstTraversal`, max depth 2, max 64 cells); each cell's neighbours are produced in a random order (`Util.shuffledCopy` of the six directions with the level random). A neighbour that is not a pale oak log is accepted but not expanded. For an expanded log, for each direction in a freshly shuffled order, look at the neighbour: air gives a `resin_clump` with the face opposite to that direction set; a water source gives a waterlogged `resin_clump` with that face; an existing `resin_clump` lacking that face gets the face added (`setBlockAndUpdate`); the first success records the position and stops the traversal. At most one block per call.
- `emitParticles(level, count, reverse)`: nothing without a protector. Colour int is 16545810 when `reverse` is true, else 6250335. A double counter runs from 0 up to `count` in steps of 1 and every iteration emits exactly one trail particle (there is no random gate). Each iteration draws a start point (the creaking's bounding-box min corner plus `nextDouble` fractions of the x, y, z sizes) and a target point (the heart's lower corner plus three `nextDouble` fractions). When `reverse` is true the two are swapped, so the particle leaves the heart and flows to the creaking; when false it leaves the creaking and flows to the heart. The particle is a `TrailParticleOption` with the target, the colour and duration `10 + nextInt(40)`, sent at the start point with `sendParticles` (count 1, spread 0, speed 0, both boolean flags true).
- `removeProtector(source)`: when a protector exists: for a null `source` call `tearDown()`; otherwise `creakingDeathEffects(source)`, `setTearingDown()` and `setHealth(0)`; then `clearCreakingInfo`. `preRemoveSideEffects` (entity removal) calls `removeProtector(null)`.
- `distanceToCreaking()` is the distance from the creaking to the bottom centre of the heart cell, 0 when there is no protector.
- Comparator `computeAnalogOutputSignal`: 0 when there is no link or no protector; else with `d = distanceToCreaking()`: `15 - floor(15 * clamp(d, 0, 32) / 32)`.

Other constants read: `CREAKING_ROAMING_RADIUS 32`, `PLAYER_DETECTION_RANGE 32`, `DISTANCE_CREAKING_TOO_FAR 34`, `SPAWN_RANGE_XZ 16`, `SPAWN_RANGE_Y 8`, `ATTEMPTS_PER_SPAWN 5`, `UPDATE_TICKS 20`, `UPDATE_TICKS_VARIANCE 5`, `HURT_CALL_TOTAL_TICKS 100`, `NUMBER_OF_HURT_CALLS 10`, `HURT_CALL_INTERVAL 10`, `HURT_CALL_PARTICLE_TICKS 50`, `MAX_DEPTH 2`, `MAX_COUNT 64`, `TICKS_GRACE_PERIOD 30`.

---

## 7. Worked examples

1. **Tier-2 beacon.** Beacon at `(0, 64, 0)`, a 3x3 of iron blocks at y 63 and a 5x5 of gold blocks at y 62 (the 5x5 includes the centre), open sky. On a game time divisible by 80, `updateBase` passes i=1 and i=2 and fails i=3 (y 61 not in the tag): `levels = 2`. Range 30, duration `(9 + 4) * 20 = 260` ticks. A player 20 blocks away is in the box and receives the primary effect for 260 ticks. With `levels < 4` the secondary must be none (validate step 1).
2. **Stained glass.** Cells above the beacon: air, red glass, red glass, blue glass, air. Sections: the base (white) gets height 2 (beacon cell plus the air cell); red starts as its own section (height 1) because only the base exists, then the second red makes it height 2; blue creates a section coloured `average(red, blue)`, height 1; the air above makes it height 2.
3. **Set Beacon validation.** `levels = 4`, payment present, primary `speed`, secondary `regeneration`: reqP 1, reqS 4, both at most 4; reqP below 4; step 5 is skipped because reqS is 4: valid. With primary `regeneration`, reqP is 4 and the request is invalid and the sender is disconnected.
4. **Conduit.** 42 frame blocks: range `(42 / 7) * 16 = 96`, hunting on; each 40-tick pulse an `Enemy` in water within 8 blocks takes 4.0 magic damage. 16 frame blocks: range `(16 / 7) * 16 = 32`, no hunting.
5. **Creaking heart comparator.** Creaking 8 blocks away gives `15 - floor(15 * 8 / 32) = 15 - 3 = 12`; 32 or more gives 0; distance 0 gives 15; no link gives 0.

---

## 8. Open questions

1. The callback run through the beacon menu's level access after a successful `updateEffects` (a lambda in `BeaconMenu`); searched `BeaconMenu` for the lambda, body not captured. Probably marks the block entity changed; unverified.
2. The `EndPortalBlock.entityInside` conditions between the dimension test and `showEndCredits` (an entity type test and a credits-seen test) were identified only by jump targets.
3. The portal travel engine (`Entity.setAsInsidePortal`, portal delay, `changeDimension`, post-transition steps) and the `createEndPlatform` guard in `EndPortalBlock.getPortalDestination`; belong to an entity round.
4. The predicate applied to a loaded `exit_portal` (lambda in `TheEndGatewayBlockEntity.loadAdditional`); body not decoded.
5. `SpawnUtil.trySpawnMob` with strategy `ON_TOP_OF_COLLIDER_NO_LEAVES` and the Creaking mob methods (`setTransient`, `tearDown`, `playerIsStuckInYou`, `creakingDeathEffects`, `isPersistenceRequired`); owned by 44-5.
6. The numeric `DyeColor.getTextureDiffuseColor` values and whether `ARGB.average` averages per channel (inferred, not read).
7. `BeaconBlock`, `ConduitBlock` and `EndPortalBlock` shapes and light levels, and the item `lock` component details; owned by 24 and 31-1.
