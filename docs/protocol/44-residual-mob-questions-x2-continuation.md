# 44 — Residual mob questions, continuation x2 (round RS26)

| Item | Value |
|---|---|
| Covers | A second partial continuation over the residual open questions of 18 to 21 and 44-1 to 44-x1. It (a) re-checks the scope list item by item against the documents that exist and records which items were already closed (section 1, so nobody re-reads them), (b) specifies the warden spawn tracker and the sculk shrieker that drives it (section 2), (c) specifies the dispenser engine and the complete code-defined table of items bound to dispenser behaviours, including every projectile, boat, minecart, bucket, bottle and equipment behaviour (sections 3 and 4; 25 section 3.8 Open question 3 and 44-8 Open question 11), (d) specifies chest-vehicle container handling (section 5; 44-8 Open question 10), (e) closes the projectile residuals of 44-8 Open questions 15 and 16 that were not yet closed: snowball, egg, llama spit, the set of `deflection` overrides (section 6), (f) specifies the brain behaviours `TryLaySpawnOnFluidNearLand` and `CopyMemoryWithExpiry` and the tadpole age-up (section 7), (g) records the copper golem oxidation-level table and the horse markings enum (section 8) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) with no execution. A statement is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)", or names an open question. Nothing here is marked recalled: every value in sections 2 to 8 was read from the class named beside it in this round. |
| Data versus code | Per the operator decisions (design README Part 0, rule R7), data is not tabulated. Tags that the engines read (`rails`, `beehives`, `convertible_to_mud`, `supports_frogspawn`, `sulfur_cube_swallowable`, `shrieker_can_listen`, `frog_food`) are named, not listed; the tables below are code (which item is bound to which behaviour, the constants of each behaviour). |
| Related | Framework [18](18-mob-framework.md) (4.2 goal catalogue, random-position helpers); [41](41-item-entity-physics.md) section 2.5 (the default dispense: item entity spawn); [25-6](25-item-registry-6-spawn-eggs-and-specials.md) section 3.8 (spawn egg dispense and the default-method selection); [44-1](44-residual-mob-questions-1-shared-model-framework.md) (spawn reasons 4.6, ordered box scan, random positions); [44-8](44-residual-mob-questions-8-vehicles-and-projectiles.md) (projectile base, deflection 6.3, minecarts, boats); [20](20-mobs-overworld-hostile.md) section 10 (warden); [44-5](44-residual-mob-questions-5-overworld-hostile.md) section 3 (warden brain); [45-8](45-entity-nbt-8-vehicles-projectiles-items.md) 4.2 (chest-vehicle NBT keys); [24-8](24-block-registry-8-blackstone-copper-deepslate-modern.md) (sculk shrieker block state) |

Conventions: "level event N" is `ServerLevel.levelEvent(N, pos, data)` (client effect, not specified here beyond the number). "Facing" is the dispenser block's `FACING` direction. "Front block" is the dispenser position moved one block along facing. `center` is the dispenser block centre (`+0.5` on every axis).

## 1. Dispositions of items that the scope names

The round statement lists items as missing. They were checked against the existing documents; the result decides what this document does and does not repeat.

| Scope item | Disposition |
|---|---|
| Item 2: generic goal classes "named in no 44 file" | Already specified in 18 section 4.2 (Float, Panic, Melee, ZombieAttack, RangedAttack, RangedBowAttack, RangedCrossbowAttack, RandomStroll, LookAtPlayer, AvoidEntity, Breed, Tempt, FollowParent, FollowOwner, FollowMob, OpenDoor, BreakDoor, RestrictSun, FleeSun, EatBlock, MoveToBlock, MoveTowardsRestriction, MoveTowardsTarget, LeapAtTarget, TryFindLiquid, BreathAir, ClimbOnTopOfPowderSnow, Swell, OcelotAttack, RandomStand, FollowFlockLeader, and the target goals), with the selector arbitration in 18 section 4.1 (full evaluation order, priority and flag replacement rules, tick-delay scaling). The few generic goals that 18 names only in a parameter list (`SitWhenOrderedToGoal`, `OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`, `NonTameRandomTargetGoal`, `MoveThroughVillageGoal`, `DoorInteractGoal`, `InteractGoal`, `UseItemGoal`, `TradeWithPlayerGoal`, `LookAtTradingPlayerGoal`, `PathfindToRaidGoal`) are not re-read in this document: they are listed in Open question 1 and need a later round. |
| Item 1: `DefaultRandomPos.getPosTowards`, `RandomPos.generateRandomPos` sampling, `GoalUtils` | Already complete in 18 section 4.2 "Random position helpers". Re-read here against `RandomPos`, `DefaultRandomPos` and `GoalUtils`: ten attempts, strictly-greater replacement, the within-radians direction (`atan2(dz, dx) - 1.5707963705062866`, `sqrt` of a double draw lerped between the minimum and maximum range and multiplied by `Mth.SQRT_OF_TWO`, rejected when either horizontal offset exceeds the maximum range, then `nextInt(2v+1) - v + yOffset`), the home nudge, and the four rejection tests all agree. Closed. One restatement that 18 words differently: `GoalUtils.mobRestricted(mob, range)` is true when the mob has a home and the home centre is **closer** than `homeRadius + range + 1` (`BlockPos.closerToCenterThan(position, ...)`), so "restricted" means "near enough to home that the pick must stay inside home". |
| Item 1: `BlockPos.manhattanOrdered` visiting order (44-4 Open question 1) | Already specified in 44-1 section 3 "ordered box scan" and in 35-7 section 2.3. Re-read here against `BlockPos$3` (the iterator): order, depth termination and the positive-then-mirrored z agree exactly. The three public wrappers differ only in the depth limit: `withinManhattan(pos, r)` uses reach `(r, r, r)` and maximum depth `r`; `withinClippedManhattan(pos, rx, ry, rz)` uses maximum depth `max(rx, ry, rz)`; `withinBoxByManhattanDistance(pos, rx, ry, rz)` uses maximum depth `rx + ry + rz`. Closed. |
| Item 5 and 18 Open question 11: `EntitySpawnReason` gates | Answered in 44-1 section 4.6 (RQ-1.18, the matrix of which reasons run `checkSpawnRules` and `checkSpawnObstruction`) and 44-2 section 2.5 (spawner-side predicates). The status line in x1 Open question 1 ("18 Open q11 still open") is stale. This document does not repeat the matrix. The one reason this document adds a producer for is `TRIGGERED` (the warden, section 2.4) and `DISPENSER` (boat, minecart, armor stand, spawn egg: sections 3.4 and 4). |
| Item 6 and 18 Open question 12: projectiles | `ShulkerBullet` flight is in 44-9 (the "not re-read" remark at 44-8 Open question 16 is stale), `EyeOfEnder` in 21 section 8.12, `FireworkRocketEntity` in 21 section 8.7, `ThrownExperienceBottle` in 21 section 8.13, `FishingHook` in 17 section 3.11, evoker fangs in 20 section 13. The remaining unread ones are specified in section 6 (snowball, egg, llama spit, deflection overrides). Not read: `AbstractThrownPotion.onHit` internals beyond 17 section 3.10 (Open question 3). |
| Item 8: block blast resistance (44-1 Open question 7) | Tabulated in 44-5 section 6 and in the block registry documents (24). The deferral in 44-1 Open question 7 is superseded. |
| Item 8: 44-4 Open question 3 (`cat_does_not_teleport_to` consumer) | Not searched in this round; Open question 4. |
| Item 8: 44-4 Open question 12, tadpole age-up, `TryLaySpawnOnFluidNearLand`, `CopyMemoryWithExpiry`, `GoToWantedItem` | Tadpole, `TryLaySpawnOnFluidNearLand` and `CopyMemoryWithExpiry`: section 7. `GoToWantedItem`: already in 44-6 section 5.4 (not re-read). |
| Item 7: copper golem oxidation levels, painting variants, `Markings` | Copper golem oxidation levels and `Markings`: section 8. Cat, cow, pig, chicken, frog, wolf and zombie-nautilus variants and painting variants are registry **data** (design README rule R7); only the engines that select them (spawn-time variant selection) are in 19, 21 and 44-4 to 44-7. Villager type and profession tables: 19 section 22 and 44-3. |
| Item 3, 4: `StrollAroundPoi`, `VillageBoundRandomStroll`, `InsideBrownianWalk`, `SetLookAndInteract`, `SetEntityLookTarget`, `NearestItemSensor`, `PlayerSensor`, `AnimalMakeLove`, `PrepareRamNearestTarget` | `SetEntityLookTarget` and `AnimalMakeLove` have bodies in 44-4, 44-6 and 44-7; the others appear in 18 section 4.6 and 4.7 and 19 section 22. Not re-read here. The warden part of item 4 is section 2. |

## 2. Warden spawn tracker and sculk shrieker

Classes read: `WardenSpawnTracker`, `SculkShriekerBlockEntity` (and its `VibrationUser`), `SculkShriekerBlock`, `ServerPlayer` (the field, tick, copy and NBT calls), `SpawnUtil` and `SpawnUtil$Strategy`.

### 2.1 The tracker (one per player)

Every `ServerPlayer` owns a `WardenSpawnTracker` created with all three counters 0. It is saved with the player under the key `warden_spawn_tracker` (a compound with three optional-always-present int fields, each non-negative, default 0):

| NBT key | Field | Meaning |
|---|---|---|
| `ticks_since_last_warning` | `ticksSinceLastWarning` | counts up each tick; reset to 0 when the level increases or decays |
| `warning_level` | `warningLevel` | 0 to 4 (`MAX_WARNING_LEVEL = 4`); `setWarningLevel` clamps to `[0, 4]` |
| `cooldown_ticks` | `cooldownTicks` | counts down to 0 each tick; the tracker is "on cooldown" while it is above 0 |

Constants (read): player search radius 16.0 (blocks, measured from the shrieker's block centre to the player position); warden check box diameter 48 on each axis; decay interval 12000 ticks; increase cooldown 200 ticks.

**Per-tick update** (`ServerPlayer.tick` calls `tick()` once per server tick for every player, alive or not, in survival or creative): if `ticksSinceLastWarning >= 12000`, the warning level decreases by 1 (clamped at 0) and `ticksSinceLastWarning` becomes 0; otherwise it is incremented. Then, independently, a positive `cooldownTicks` is decremented. (So the decay step runs the tick after the counter reaches 12000 and the counter restarts from 0.)

**Increase** (`increaseWarningLevel`, private): does nothing while on cooldown. Otherwise: `ticksSinceLastWarning = 0`, `cooldownTicks = 200`, then the level is incremented and clamped to 4.

**Respawn and dimension change**: `ServerPlayer.restoreFrom` copies the **reference** of the old player's tracker into the new player object (not a copy of the three numbers), for every reason (death, end exit, dimension change); the level therefore survives death. `reset()` exists (all three counters to 0). Callers of `reset()` and `setWarningLevel` outside the tracker exist: the command class `WardenSpawnTrackerCommand` registers `warden_spawn_tracker`, guarded by the permission check `LEVEL_GAMEMASTERS`, with two subcommands. `clear` calls `reset()` on the tracker of every targeted player; `set warning_level <int>` calls `setWarningLevel` on the tracker of every targeted player, the integer argument being bounded **0 to 4** (read: `IntegerArgumentType.integer(0, 4)`), and the tracker clamps again. The player-selector form and the success message keys (`commands.warden_spawn_tracker.clear.success.single` / `.multiple`, `.set.success.single` / `.multiple`) are the only other facts read; the target argument type was not decoded beyond "a collection of players". Whether other classes (a block, the warden) call them was not searched beyond the player-side paths (Open question 5).

### 2.2 `tryWarn(level, shriekerPos, player)` (static)

Returns an optional int: empty means "no warning level was produced"; a value is the new level.
1. If any `Warden` entity exists inside the axis-aligned box of size 48 x 48 x 48 centred on the shrieker block centre: return empty.
2. Collect the candidate players: every non-spectator, alive `ServerPlayer` in the level whose position is closer than 16.0 to the shrieker block centre (`Vec3.closerThan`); if the triggering player is not in that list, add him (so he counts even when he stands farther than 16 blocks, for instance when a projectile or item of his reached the shrieker).
3. If **any** candidate's tracker is on cooldown: return empty.
4. Pick the candidate whose tracker has the highest warning level (`max` by level; the first such candidate in list order wins a tie, list order being the level's player order with the triggering player appended last if he was added). Increase that tracker's level (section 2.1; cooldown was off for every candidate, so the increase happens). Then copy that tracker's three counters (level, cooldown, ticks since) into **every** candidate's own tracker (they all share the winner's values afterwards). Return the winner's level.

### 2.3 The shrieker block entity

Block state (24-8): `shrieking`, `waterlogged`, `can_summon` (all default false). Constants: listener radius 8 (the vibration listener), `SHRIEKING_TICKS = 90`, `WARNING_SOUND_RADIUS = 10`, `WARDEN_SPAWN_ATTEMPTS = 20`, `WARDEN_SPAWN_RANGE_XZ = 5`, `WARDEN_SPAWN_RANGE_Y = 6`, `DARKNESS_RADIUS = 40`. The block entity keeps its own `warning_level` int (saved under that key, default 0) next to the vibration `listener` data; this is the level of the **last** shriek, not the player's.

**Triggers.**
- `stepOn(entity)` (server only): `tryGetPlayer(entity)` gives a player, then `tryShriek(level, player)`. No sneaking test is made by the block.
- Vibrations: the listener only accepts events of the tag `shrieker_can_listen`, and `canReceiveVibration` is true only when the block is **not** `shrieking` and the event's source entity resolves to a player. `onReceiveVibration` then calls `tryShriek` with that player.
- `tryGetPlayer(entity)` resolves in this order: the entity is itself a `ServerPlayer`; else its controlling passenger is a `ServerPlayer`; else it is a `Projectile` whose owner is a `ServerPlayer`; else it is an `ItemEntity` whose owner is a `ServerPlayer`; else none.

**`tryShriek(level, player)`**:
1. A null player or a block already `shrieking`: return.
2. Set the block entity's `warningLevel` to 0.
3. If `canRespond(level)`: call `tryToWarn`; if that returns false (no level produced) return **without shrieking**. If `canRespond` is false the warning is skipped and the shriek goes ahead.
4. `shriek`: set `shrieking` true (block update flag 2), schedule a block tick 90 ticks later, level event **3007** (data 0) at the block, game event `SHRIEK` at the block with the player as source entity.

`canRespond(level)` = the block's `can_summon` is true AND difficulty is not Peaceful AND the game rule `spawn_wardens` is true.

`tryToWarn(level, player)` calls `tryWarn` (2.2) with the block position; when a level comes back the block entity stores it in its own `warningLevel`; the result is "a level was produced".

**Block tick (90 ticks after the shriek)**: if the block is `shrieking`, set it false (`setBlockAndUpdate`); then call `tryRespond(level)` on the block entity. Breaking the block while `shrieking` (`preRemoveSideEffects`) also calls `tryRespond` once.

**`tryRespond(level)`**: only when `canRespond` and the stored `warningLevel > 0`:
1. `trySummonWarden`: needs the stored level `>= 4`; spawns a `warden` with reason `TRIGGERED` through `SpawnUtil.trySpawnMob(warden, TRIGGERED, level, shriekerPos, attempts 20, horizontal 5, vertical 6, ON_TOP_OF_COLLIDER, check-spawn-AABB false)` (section 2.4). It returns whether a mob was spawned.
2. If no warden was spawned: play the reply sound for the stored level (below).
3. In both cases apply Darkness: `Warden.applyDarknessAround(level, blockCentre, null, 40)` (the effect rules are in 20 section 10: radius here is 40 blocks).

**Reply sound** (`playWardenReplySound`): table by stored level: 1 `warden.nearby_close`, 2 `warden.nearby_closer`, 3 `warden.nearby_closest`, 4 `warden.listening_angry`; any other level plays nothing. Position: the shrieker's block position plus three independent offsets, each `randomBetweenInclusive(-10, 10)` drawn in x, y, z order from the level's random source; source category HOSTILE, volume 5.0, pitch 1.0, no source entity. (Level 4 with a failed warden spawn plays the angry sound.)

### 2.4 `SpawnUtil.trySpawnMob` and the `ON_TOP_OF_COLLIDER` strategy

Parameters: type, spawn reason, level, centre `pos`, `attempts`, `horizontal` range `h`, `vertical` range `v`, strategy, `checkAABB`. The golem call with the legacy strategy is in 44-2 section 2.5 (same routine); this section gives the routine in full once.

For each attempt `i = 0 .. attempts - 1`:
1. Draw `dx = randomBetweenInclusive(-h, h)`, then `dz = randomBetweenInclusive(-h, h)` (x first, then z).
2. `start = pos + (dx, v, dz)`. Skip the attempt if `start` is outside the world border.
3. **Find a floor** (`moveToPossibleSpawnPosition`): let `cursor = start` and `above = block state at start`; repeat for `k = v` down to `-v` inclusive (that is `2v + 1 = 13` steps for `v = 6`): move the cursor one block down; `floor = block state at the cursor`; if the strategy accepts `(floor, cursor, above state, above position)` then the candidate position is the block **above** the cursor (cursor moved back up one) and the search ends; otherwise `above = floor` and continue. Failing every step skips the attempt.
4. If `checkAABB` is true (it is false for the warden call) the entity-type spawn box at `(x + 0.5, y, z + 0.5)` must be free of collisions.
5. Create the mob at the candidate (random yaw handled by the create call); if it passes its own `checkSpawnRules(level, reason)` and `checkSpawnObstruction(level)`, add it with passengers, play its ambient sound, and return it. Otherwise discard it and continue.
After all attempts: no mob (empty).

Strategy `ON_TOP_OF_COLLIDER` (read, the one the warden uses): accept when the state **above** the cursor has an **empty collision shape** at the above position AND the floor state's collision shape at the cursor has a **full upward face** (`Block.isFaceFull(shape, UP)`). `ON_TOP_OF_COLLIDER_NO_LEAVES` additionally refuses an above state in the `leaves` tag (note the leaves test sits on the above state). The legacy iron golem strategy is the block-list one in 44-2 section 2.5.

### 2.5 Worked examples

1. **Four shrieks.** A fresh player stands on a `can_summon` shrieker (no warden within 48 blocks, nobody else near). Tick 0: shriek 1, tracker level 0 to 1, cooldown 200, shrieker stores 1 (sound `nearby_close`). The shrieker cannot shriek again for 90 ticks (`shrieking`); at tick 91 he steps again: the tracker is still on cooldown (200 - 91 = 109), so `tryWarn` is empty, `tryShriek` returns before shrieking, and the shrieker stays silent. Cooldown reaches 0 after 200 decrements; whether shriek 2 can happen at tick 200 or 201 depends on whether the shrieker's block tick runs before or after the player's own `tick()` within a game tick, which was not read, so this example **assumes** the shrieker's tick runs after the player's tick (a shriek is possible "at least 200 ticks later"). On that assumption shriek 2 is at tick 201 (level 2, `nearby_closer`); shriek 3 at tick 402 (level 3, `nearby_closest`); shriek 4 at tick 603: level 4, and the block tick 90 ticks later runs `tryRespond`: a warden is spawned near the shrieker (no reply sound), Darkness is applied within 40 blocks. If every one of the 20 spawn attempts fails, the `listening_angry` sound plays instead.
2. **Decay.** Level 3 and no further shriek: the counter was reset to 0 by the last increase. It is incremented once per tick, so it reaches 12000 after 12000 ticks and the next tick takes the decay branch: the level drops to 2 and the counter is set to 0 (that tick does not increment it). Each decay step therefore takes 12001 ticks (computed from the two branches of the per-tick update), and a full decay from 4 to 0 takes 48004 ticks.
3. **Two players.** Players A (level 2) and B (level 0) within 16 blocks, B steps on the shrieker; neither is on cooldown. Candidates are A, B (B is in the list already). The winner is A (higher level): A goes to 3 with cooldown 200; both trackers become (3, 200, 0); `tryWarn` returns 3.
4. **Warden present.** Any warden within the 48-box makes `tryWarn` empty: with `can_summon` the shrieker never shrieks while a warden is that close.

## 3. The dispenser engine

Classes read: `DispenserBlock`, `DispenserBlockEntity`, `DefaultDispenseItemBehavior`, `OptionalDispenseItemBehavior`, `DispenseItemBehavior` (and its anonymous behaviours), `BlockSource`.

### 3.1 Block and block entity

- Block state `facing` (six values) and `triggered`; the placement facing is the **opposite** of the placing player's nearest looking direction (24-2). Container size **9** (`DispenserBlockEntity.CONTAINER_SIZE`), default name key `container.dispenser`. A player opening it awards stat `inspect_dispenser` (`inspect_dropper` for a dropper). The comparator signal is the standard container fill signal (`getRedstoneSignalFromBlockEntity`).
- **Redstone**: `neighborChanged` computes `powered = hasNeighborSignal(pos) OR hasNeighborSignal(pos.above())` (the quasi-connectivity rule). If `powered` and not `triggered`: schedule a block tick in **4** ticks (`TRIGGER_DURATION`) and set `triggered` true (flag 2). If not `powered` and `triggered`: set `triggered` false (flag 2). Nothing else.
- **Block tick** runs `dispenseFrom(level, state, pos)`.

### 3.2 `dispenseFrom`

1. The block entity must exist; otherwise log a warning and stop.
2. `slot = getRandomSlot(random)`. If `slot < 0` (no item): level event **1001** (data 0, the "click fail" sound) and game event `BLOCK_ACTIVATE` at the dispenser (context: the block state); stop.
3. Otherwise `stack = item in slot`; `behaviour = getDispenseMethod(level, stack)`. Unless it is `NOOP` (never returned by the dispenser), the slot is set to `behaviour.dispense(source, stack)` (the returned stack, which may be the same stack object shrunk, a different stack (remainder) or empty).

**`getRandomSlot(random)`** (the item loot is unpacked first, `unpackLootTable(null)`): uniform choice among the non-empty slots by a single pass: keep `result = -1`, `k = 1`; for each slot index `0 .. 8` in order, if the slot is non-empty then draw `nextInt(k)` and **post-increment `k`**; when the draw is 0, `result = this index`. One draw is made per non-empty slot, including the first (`nextInt(1)`, always 0, which consumes a random value). The pass therefore selects each non-empty slot with equal probability `1 / (number of non-empty slots)`.

**`getDispenseMethod(level, stack)`**: if the item is not enabled by the active feature flags: the default behaviour. Else the explicit map lookup (identity map from `Item`; section 4); else the default selection of 25-6 section 3.8 (stack has `equippable`: equipment behaviour; stack in tag `sulfur_cube_swallowable`: sulfur-cube behaviour; a spawn egg item with the component `entity_data`: spawn-egg behaviour; otherwise the default behaviour).

### 3.3 Behaviour protocol

`dispense(source, stack)` (final in `DefaultDispenseItemBehavior`): `result = execute(source, stack)`; `playSound(source)`; `playAnimation(source, facing)`; return `result`. Defaults: `playSound` = level event **1000** (data 0); `playAnimation` = level event **2000** with data = `facing.get3DDataValue()` (at the dispenser position). Subclasses that override `playSound` (listed per behaviour below) change only the first event. `OptionalDispenseItemBehavior` adds a `success` flag (initially **true**, and it is **not** reset between calls: each subclass sets it as stated) and overrides `playSound` to level event **1000** when `success` and **1001** otherwise. Behaviours built on it are marked "(optional)" below.

- Default `execute`: split one item and drop it as an item entity (41 section 2.5: position = centre + 0.7 x facing step, y lowered 0.125 (vertical) or 0.15625, accuracy 6, no pickup delay).
- **`consumeWithRemainder(source, stack, remainder)`**: shrink the stack by 1; if the stack is now empty return `remainder` (the dispenser slot now holds the remainder item); otherwise `addToInventoryOrDispense(remainder)` and return the shrunk stack. `addToInventoryOrDispense` first tries `DispenserBlockEntity.insertItem(remainder)` (fills matching stacks in slot order up to the stack limit, then the first empty slot: for each slot, a non-empty slot of a different item or components is skipped; an empty slot takes the remainder by split); when something is left over it is dropped like the default behaviour (accuracy 6 at the standard dispense position, level events 1000 then 2000 played by the helper).

### 3.4 Dispense position helper

`DispenserBlock.getDispensePosition(source, distance, extra)` = `center + facing step x distance + extra` (per axis). The default form uses distance **0.7** and extra `(0, 0, 0)`.

## 4. Behaviour table: every explicit binding

`DispenseItemBehavior.bootStrap` makes **53** direct `registerBehavior` call sites in its own body (including the undyed shulker box), plus **1** `registerBehavior` call inside a lambda that registers every dyed shulker box, for **54** `registerBehavior` sites in all (the lambda is already inside the 54), plus **13** `registerProjectileBehavior` calls; no other class registers a behaviour (the only classes in the jar that reference the registration methods are `DispenseItemBehavior` and `DispenserBlock`). Items below not listed use the default selection of 3.2.

| Items | Behaviour (section) |
|---|---|
| arrow, tipped arrow, spectral arrow, egg, blue egg, brown egg, snowball, experience bottle, splash potion, lingering potion, firework rocket, fire charge, wind charge | projectile behaviour (4.1) |
| armor stand | 4.2 |
| chest | 4.3 |
| the ten wood boats `oak, spruce, birch, jungle, dark_oak, acacia, cherry, mangrove, poplar, pale_oak` and the `bamboo` raft (11 items), and the 11 chest variants of the same list (22 bindings in all) | boat behaviour (4.4), with the entity type of the item |
| minecart, chest minecart, furnace minecart, tnt minecart, hopper minecart, command block minecart (not the spawner minecart) | minecart behaviour (4.5) |
| lava, water, powder snow, salmon, cod, pufferfish, tropical fish, axolotl, sulfur cube and tadpole buckets | filled bucket (4.6) |
| empty bucket | 4.7 |
| flint and steel | 4.8 |
| bone meal | 4.9 |
| tnt (block item) | 4.10 |
| wither skeleton skull | 4.11 |
| carved pumpkin | 4.12 |
| shulker box and all 16 dyed shulker boxes | 4.13 |
| glass bottle | 4.14 |
| glowstone | 4.15 |
| shears | 4.16 |
| brush | 4.17 |
| honeycomb | 4.18 |
| potion (any potion item, the behaviour tests the contents) | 4.19 |
| anything with `equippable` (default selection) | 4.20 |
| sulfur-cube swallowable items (default selection) | 4.21 |

### 4.1 Projectile behaviour (`ProjectileDispenseBehavior`)

Each bound item must be a `ProjectileItem`; the behaviour reads the item's **dispense config** (position function, uncertainty, power, optional overriding level event) at construction.

`execute`: `facing`; `pos = config.positionFunction(source, facing)`; `projectile = item.asProjectile(level, pos, stack, facing)`; then `Projectile.spawnProjectileUsingShoot(projectile, level, stack, dx, dy, dz, power, uncertainty)` with `(dx, dy, dz)` = the facing step (so a dispenser facing up shoots `(0, 1, 0)`); the velocity formula is `shoot` in 44-8 section 6.1 (`normalize(d) + triangle noise of spread 0.0172275 x uncertainty, times power`); then the stack shrinks by 1 and is returned. `playSound` = level event = the config's override if present, else **1002** (data 0). The animation event 2000 follows as usual.

Default config (builder defaults, read): position `getDispensePosition(source, 0.7, (0, 0.1, 0))`, uncertainty **6.0**, power **1.1**, no event override.

| Item (`ProjectileItem`) | Entity created (`asProjectile`) | Position function | Uncertainty | Power | Level event |
|---|---|---|---|---|---|
| arrow | `Arrow`, copy of one item, pickup mode ALLOWED | default | 6.0 | 1.1 | 1002 |
| tipped arrow | as arrow (the item subclass of the arrow item; the potion comes with the stack copy) | default | 6.0 | 1.1 | 1002 |
| spectral arrow | `SpectralArrow`, copy of one item, pickup ALLOWED | default | 6.0 | 1.1 | 1002 |
| egg, blue egg, brown egg | `ThrownEgg` with the stack | default | 6.0 | 1.1 | 1002 |
| snowball | `Snowball` with the stack | default | 6.0 | 1.1 | 1002 |
| experience bottle | `ThrownExperienceBottle` with the stack | default | 6.0 x 0.5 = **3.0** | 1.1 x 1.25 = **1.375** | 1002 |
| splash potion, lingering potion | `createPotion(level, position, stack)` of the throwable potion item (splash or lingering entity) | default | 3.0 | 1.375 | 1002 |
| firework rocket | `FireworkRocketEntity` with a one-item copy at the position, flag "shot at angle" true | the item's position lambda, which calls a private helper "just outside the block": `center + facing step x 0.5000099999997474` per axis (the constant read three times, one per axis; that the lambda calls this helper was read from the invokedynamic target, not traced further, **(inferred)** for the exact link). The item's separate constant `ROCKET_PLACEMENT_OFFSET = 0.15` belongs to the player-use path, not the dispenser | **1.0** | **0.5** | **1004** |
| fire charge | `SmallFireball` at the position with the **normalised** vector `(triangle(stepX, 0.11485000000000001), triangle(stepY, 0.11485000000000001), triangle(stepZ, 0.11485000000000001))` (draws in x, y, z order from the level random source), then the stack is set as its item | `getDispensePosition(source, 1.0, (0,0,0))` | **6.6666665** | **1.0** | **1018** |
| wind charge | `WindCharge` at the position with the movement vector `(triangle(stepX, 0.11485000000000001), triangle(stepY, ...), triangle(stepZ, ...))` handed to its constructor; that vector is **overwritten** as delta movement by `Projectile.shoot` (below) | `getDispensePosition(source, 1.0, (0,0,0))` | **6.6666665** | **1.0** | **1051** |

`triangle(c, d) = c + d x (nextDouble() - nextDouble())`. The splash and lingering rows share one item class (`ThrowablePotionItem`), whose config multiplies the defaults by 0.5 and 1.25 exactly like the experience bottle (read). The constant 0.11485000000000001 equals `0.0172275 x 6.666666...` (computed).

Shoot-path note (read from `ProjectileDispenseBehavior`, `FireChargeItem`, `WindChargeItem`): the dispenser always calls `Projectile.spawnProjectileUsingShoot`, i.e. `Projectile.shoot(dx, dy, dz, power, uncertainty)` with the facing step, never the item's own `shoot`; the `shoot` overrides of `FireChargeItem` and `WindChargeItem` are empty methods and are off this path, and `AbstractHurtingProjectile`, `SmallFireball` and `WindCharge` do not override `shoot`. So the **only** noise applied to the final velocity of a dispensed wind charge is the one in `shoot`: `normalize(step) + triangle(0, 0.0172275 x 6.6666665) per axis`, times power 1.0 (the draws of `shoot` happen after the item's three draws in the same random source). The item's own vector (`triangle(step, 0.11485000000000001)`, three draws x, y, z) is a **separate earlier** draw; it is not added to the shoot noise and, for the wind charge, has no lasting effect. For the fire charge the constructor vector's only lasting effect is on the projectile's acceleration **(inferred: the `AbstractHurtingProjectile` constructor was not read)**. An implementer therefore draws 3 (item vector) + 3 (shoot noise, per axis) triangle values per dispensed fire or wind charge and applies the second set to the velocity only.

### 4.2 Armor stand

Spawn at the front block with reason `DISPENSER` through the entity type's `spawn(level, post-spawn processor, position, reason, false, false)`; the processor sets the stand's yaw to the **facing's y rotation** (`Direction.toYRot`: south 0, west 90, north 180, east 270) and applies the item's default stack config (custom data and name from the stack); on success the stack shrinks by 1. If nothing spawned the stack is returned unchanged. Default sound (1000) and animation.

### 4.3 Chest (loads a chest onto a donkey, mule or other chested horse)

(optional) Looks at every alive chested horse (`AbstractChestedHorse` without a chest) inside the front block's cell: for the first that is **tamed** and whose equipment slot **499** (the chest slot access) accepts the stack, the stack shrinks by 1, `success` is set true and the stack is returned. If no horse took it, the default `execute` runs (the chest is dropped as an item) and `success` keeps its previous value (initially true, never set false), so the sound is always 1000 for this behaviour. The stack handed to `SlotAccess.set` is the **full, unsplit** stack; the dispenser then shrinks it by 1 itself. The slot access (`AbstractChestedHorse$1`, slot 499) never keeps the stack it is given: an **empty** stack removes the chest (clears the chest flag if set and rebuilds the inventory) and returns true; a stack that **is the chest item** sets the chest flag if the horse has none, rebuilds the inventory, and returns true; any other stack returns false. (Reading the slot's get side: with a chest it returns a one-item chest stack, without one an empty stack.) The dispenser's entity filter requires alive and no chest, and the behaviour additionally requires the horse to be tamed, so for a dispenser-supplied chest stack the set always succeeds.

### 4.4 Boats and rafts (`BoatDispenseItemBehavior`, own `playSound` = level event 1000 only)

Let `w` be the boat entity type's width (`EntityType.getWidth`; the boat types are 1.375 wide, 21 section 1) and `half = 0.5625 + w / 2`. Position `(x, y, z) = (center.x + stepX x half, center.y + (float)(stepY x 1.125f), center.z + stepZ x half)`. Water offset `o`: if the front block's **fluid** is in tag `water`: `o = 1.0`; else if the front block is **air** and the block below the front block has water: `o = 0.0`; else the whole behaviour is replaced by the default drop (item entity), nothing else happens. Otherwise: create the boat entity with reason `DISPENSER`; if creation succeeded: `setInitialPos(x, y + o, z)`, apply the default stack config (custom name and data), yaw = `facing.toYRot()` (horizontal facings; up and down yield the Direction rotation constant), add it to the level, shrink the stack by 1. The stack is returned.

### 4.5 Minecarts (`MinecartDispenseItemBehavior`, `playSound` = level event 1000 only)

Position `(x, y, z) = (center.x + stepX x 1.125, floor(center.y) + stepY, center.z + stepZ x 1.125)`. Vertical offset `o`:
1. if the **front block** is in tag `rails`: `o = 0.6` when its rail shape is a slope (`RailShape.isSlope`: ascending shapes), else `0.1`. (A rail block that is not a `BaseRailBlock` counts as `north_south`.)
2. else if the front block is **air** and the block **below** the front block is in tag `rails`: the below rail's shape is looked up the same way; `o = -0.9` when the facing is **down** or the below shape is not a slope; `o = -0.4` when it is a slope and the facing is not down.
3. else (not a rail, and not air over a rail): replaced by the default drop.
Otherwise `AbstractMinecart.createMinecart(level, x, y + o, z, type, DISPENSER, no stack config, no player)`; when it was created it is added to the level and the stack shrinks by 1. The stack is returned.

### 4.6 Filled buckets (shared behaviour, default `playSound`)

Calls the bucket item's `emptyContents(null player, level, front block, null hit)`; when it returned true: `checkExtraContent` (a fish bucket spawns its mob), then `consumeWithRemainder` with an empty `bucket` as remainder (the dispenser slot becomes an empty bucket when the stack is exhausted, otherwise the empty bucket goes into the dispenser container or is dropped). When emptying fails the default drop runs.

### 4.7 Empty bucket

Reads the front block state; when its block is a `BucketPickup`, `pickupBlock(null, level, front, state)` is called: if the returned item is empty the default drop runs; otherwise game event `FLUID_PICKUP` at the front block, and `consumeWithRemainder` with the picked-up bucket item as the remainder. A non-pickup block runs the default drop.

### 4.8 Flint and steel (optional)

`success` is set true; then, in order, the first that applies: (1) `tryIgniteExplosiveEntities`: the cubes in the front block's cell passing the filter `SulfurCube.canExplode()` are collected; if none, the step is false; otherwise the **first** has `primeTime(false)` called and the step returns **true whatever `primeTime` returned** (so a cube that cannot be primed still ends the chain with success and the tool still takes damage); `primeTime` returns false when the explosion data is empty, the cube is dead, the `tnt_explodes` rule is false, or the cube is already primed (the rest of the method was not read); (2) fire can be placed at the front block with the dispenser facing (`BaseFireBlock.canBePlacedAt`): set the fire state, game event `BLOCK_PLACE`; (3) the front block can be lit as a campfire, candle or candle cake (`canLight` of each): set `lit` true, game event `BLOCK_CHANGE`; (4) the block is TNT: `TntBlock.prime` and, if it primed, `removeBlock(pos, false)`; when it did not prime, `success` is false. When none of (1) to (4) applies the code path ends with `success` still true and no change (the item is still damaged, below; confirmed from the bytecode: the only write of `success` false is the TNT-did-not-prime branch). When `success` ends true the tool takes **1** durability damage (no player; the break callback is an empty method); the stack is returned.

### 4.9 Bone meal (optional)

`success` true; `BoneMealItem.growCrop(stack, level, front)` OR `growWaterPlant(stack, level, front, null)`; on a hit and on the server: level event **1505** with data **15** at the front block (the grow particles). On neither: `success` false. The stack is returned (the item is consumed inside the grow helpers).

### 4.10 TNT (optional)

If the game rule `tnt_explodes` is false: `success` false, nothing happens, stack returned unchanged. Otherwise first `SulfurCubeBlockDispenseItemBehavior.dispenseBlock(level, front, stack)` (4.21): if a sulfur cube swallowed it, return. Else spawn a `PrimedTnt` at `(front.x + 0.5, front.y, front.z + 0.5)` (no igniter), play `tnt_primed` (BLOCKS, volume 1, pitch 1) at its position, game event `ENTITY_PLACE`, shrink the stack by 1, `success` true.

### 4.11 Wither skeleton skull (optional)

If the front block is empty (`isEmptyBlock`) and `WitherSkullBlock.canSpawnMob(level, front, stack)`: set `wither_skeleton_skull` with `rotation = RotationSegment.convertToSegment(facing)`, game event `BLOCK_PLACE`; when the block entity is a skull entity call `WitherSkullBlock.checkSpawn` (the wither pattern check); shrink 1; success. Otherwise the equipment behaviour (4.20): `success` = whether it equipped a mob.

### 4.12 Carved pumpkin (optional)

Front block empty and `CarvedPumpkinBlock.canSpawnGolem(level, front)`: on the server set the carved pumpkin state (default state), game event `BLOCK_PLACE`; shrink 1; success true. Otherwise the equipment behaviour (4.20). (The golem is created by the block's own placement logic, not here.)

### 4.13 Shulker boxes (optional, `ShulkerBoxDispenseBehavior`)

`success` false first. For a `BlockItem`: `placeDir = facing` if the block **below the front block** is empty, else `UP`; the item is placed with a `DirectionalPlaceContext(level, front, facing, stack, placeDir)`; `success` = the placement `consumesAction`. Exceptions are caught and logged (`Error trying to place shulker box at {pos}`), leaving `success` false. The stack is returned (the placement shrank it).

### 4.14 Glass bottle (optional)

`success` false first. In order: (1) the front block is in tag `beehives`, has the `honey_level` property, is a `BeehiveBlock`, and `honey_level >= 5`: release the bees (`releaseBeesAndResetHoneyLevel`, release status BEE_RELEASED, no player), `success` true, and the result is `takeLiquid` with a honey bottle; (2) else the front block's fluid is in tag `water`: `success` true and `takeLiquid` with a potion item holding the water potion; (3) else the default drop (`success` stays false: sound 1001). `takeLiquid` plays game event `FLUID_PICKUP` at the dispenser position then `consumeWithRemainder` with the filled bottle.

### 4.15 Glowstone (optional)

`success` true; when the front block is a respawn anchor: if `charge != 4` call `RespawnAnchorBlock.charge(null, level, front, state)` and shrink 1; if it is already full `success` false (stack unchanged). When it is not a respawn anchor the default drop runs (success stays true: sound 1000).

### 4.16 Shears (optional)

On the server only. `success` = `tryShearBeehive OR tryShearEntity`. The beehive case: the front block is a beehive (tag `beehives`, `BeehiveBlock`) with `honey_level >= 5`: play `beehive_shear` (BLOCKS, volume 1, pitch 1), drop honeycombs (`BeehiveBlock.dropHoneycomb`, no player, no entity), release the bees with BEE_RELEASED and reset the level, game event `SHEAR`. The entity case: for each entity in the front cell that is not a spectator, in list order: if it has leash connections they are all cut (`shearOffAllLeashConnections(null)`) and the behaviour ends with success; else if it is alive, `Shearable` and `readyForShearing`, it is sheared (`shear(level, BLOCKS, stack)`), game event `SHEAR`, success; otherwise the next entity. On success the shears take **1** durability damage (no player). The stack is returned.

### 4.17 Brush (optional)

Looks at the `Armadillo` entities in the front cell (not spectators). None: `success` false. Otherwise for the first one for which `brushOffScute(null, stack)` is true: damage the brush by **16** (no player) and return (success stays true); if no armadillo yielded a scute: `success` false. The stack is returned.

### 4.18 Honeycomb (optional)

If `HoneycombItem.getWaxed(front block state)` exists: replace the block with it (`setBlockAndUpdate`), level event **3003** (data 0), play `honeycomb_wax_on` (BLOCKS, 1, 1), shrink 1, `success` true. Otherwise the default drop (success keeps its value, true).

### 4.19 Potion

Not optional (default sound). If the potion contents are not the water potion: the default drop (so only water bottles do anything). Else, if the front block is in tag `convertible_to_mud`: on the server five `splash` particle sends (count 1, speed 1.0, spread 0) at `(front.x + nextDouble(), front.y + 1, front.z + nextDouble())` drawn per particle in x, z order; sound `bottle_empty` (BLOCKS, 1, 1) at the front block; game event `FLUID_PLACE`; the front block becomes `mud`; the result is `consumeWithRemainder` with a glass bottle. A water bottle facing any other block runs the default drop.

### 4.20 Equipment (`EquipmentDispenseItemBehavior`)

`dispenseEquipment(source, stack)`: among the `LivingEntity` inside the front block's cell, those with `canEquipWithDispenser(stack)`; none: return false. For the **first** in list order: slot = `getEquipmentSlotForItem(stack)`; one item is split off and set in that slot; for a `Mob`, `setGuaranteedDrop(slot)` and `setPersistenceRequired()`; return true. The behaviour's `execute` returns the stack when it equipped something, else the default drop. It is the bound behaviour of every `equippable` stack not in the map (armor, elytra, heads, carpets for llamas, saddles and so on, per the data component) and the fallback of the wither skull and carved pumpkin.

### 4.21 Sulfur cube behaviour

`dispenseBlock(level, front, stack)`: for each `SulfurCube` in the front block's cell (no extra filter), `equipItem(stack)`; the first that accepts it shrinks the stack by 1 and the helper returns true. As a bound behaviour (stacks in tag `sulfur_cube_swallowable`) `execute` returns the stack if swallowed, else the default drop. The sulfur cube's own `equipItem` rules are in 20 section 18 (Open question 9).

### 4.22 Worked examples

1. **Slot choice.** Dispenser slots hold items in slots 1, 4 and 8 (the rest empty). Draws: slot 1: `nextInt(1)` (always 0) so `result = 1`, `k = 2`; slot 4: `nextInt(2)`; slot 8: `nextInt(3)`. The probability that slot 8 wins is 1/3, slot 4 wins when its draw is 0 and the slot-8 draw is not 0: `1/2 x 2/3 = 1/3`, slot 1: `1/2 x 2/3 = 1/3`.
2. **Arrow, facing east**, dispenser block at `(0, 64, 0)`: centre `(0.5, 64.5, 0.5)`; position `(0.5 + 0.7, 64.5 + 0.1, 0.5) = (1.2, 64.6, 0.5)`; shoot direction `(1, 0, 0)`; noise spread `0.0172275 x 6.0 = 0.103365` per axis (each component `0.103365 x (nextDouble() - nextDouble())`); the velocity is `(normalize((1,0,0)) + noise) x 1.1` as in 44-8 section 6.1; level event 1002 then 2000 with data 5 (east).
3. **Experience bottle, facing up**: position `(0.5, 64.5 + 0.7 + 0.1, 0.5) = (0.5, 65.3, 0.5)`; direction `(0, 1, 0)`; spread `0.0172275 x 3.0 = 0.0516825`; power 1.375.
4. **Oak boat, facing east, water in the front block**: `w = 1.375`, `half = 0.5625 + 0.6875 = 1.25`; `x = 0.5 + 1.25 = 1.75`, `y = 64.5 + 0 + 1.0 = 65.5`, `z = 0.5`; yaw 270 (east). With air in the front block and water below it: `o = 0.0`, `y = 64.5`. With solid ground in the front block: the boat item is dropped.
5. **Minecart, facing east, flat rail in the front block**: `(0.5 + 1.125, floor(64.5) + 0 + 0.1, 0.5) = (1.625, 64.1, 0.5)`. Ascending rail: `y = 64.6`. Air in the front block with a flat rail below it: `y = 64 - 0.9 = 63.1`.
6. **Water bucket facing a solid block**: `emptyContents` fails: the bucket item is dropped. Facing air: water placed at the front block; the bucket stack shrinks; with one bucket in the slot the slot becomes an empty bucket.
7. **Glass bottle facing water**: result `potion` with the water potion in the slot when the bottle stack was one item (remainder), else the potion goes to the dispenser container, else it is dropped; sound 1000.
8. **Flint and steel facing a cell holding TNT block**: the block is primed and removed with no drop; the tool takes 1 damage.

## 5. Chest vehicles (`ContainerEntity`)

Implemented by the chest boats and rafts (`AbstractChestBoat`) and the minecart containers (`AbstractMinecartContainer`); sizes (27 for the chest boat and chest minecart, 5 for the hopper minecart) are in 44-8. All handling below is the shared interface default code.

- **Interaction** (`interactWithContainerVehicle(player)`): opens the entity's menu for the player (`Player.openMenu(this)`); the result is SUCCESS. The decision whether a click opens the menu or boards is made by the subclass (44-8 section 3 for chest boats: secondary use opens the menu; otherwise the player boards).
- **Loot table unpacking** (`unpackChestVehicleLootTable(player)`, called by every item access method with a null player, and by the menu opening path with the opening player): runs only on a server with a non-null loot table key. Order: (1) look up the table; (2) if `player` is non-null, fire the `generate_loot` criterion for that player and the table key; (3) clear the table key (so it is generated once; the **seed is not cleared**); (4) build loot parameters: `origin` = the entity position; when the player is non-null also `luck` = `Player.getLuck()` and `this_entity` = the player; parameter set **`chest`**; (5) `LootTable.fill(container, params, seed)` with the stored seed (0 means a random seed is chosen inside the fill; see 26). Every accessor (`getChestVehicleItem`, `removeChestVehicleItem`, `removeChestVehicleItemNoUpdate`, `setChestVehicleItem`, `clearChestVehicleContent`) unpacks first with a null player, so an unopened loot chest that is read by a hopper or a comparator generates its loot without the criterion and without luck.
- **Accessors**: `removeChestVehicleItemNoUpdate(i)` returns the item and leaves empty (or empty if it was empty); `removeChestVehicleItem(i, n)` is the standard `ContainerHelper.removeItem`; `setChestVehicleItem(i, stack)` stores the stack and limits its size to the container's maximum stack size for that stack; `clearChestVehicleContent` unpacks (null player) then clears the list; `isChestVehicleEmpty` is true when every stack is empty; `getChestVehicleSlot(i)` gives a slot access for `0 <= i < containerSize`, else none.
- **Validity** (`isChestVehicleStillValid(player)`): the entity is not removed and the player is within entity interaction range (bounding box, extra margin **4.0**) (`isWithinEntityInteractionRange(box, 4.0)`).
- **Destruction** (`chestVehicleDestroyed(damageSource, level, entity)`): nothing unless the game rule `entity_drops` is true; then `Containers.dropContents(level, entity, container)` (every stack as an item entity); then if the damage source's **direct entity** is a `Player`, nearby piglins are angered (`PiglinAi.angerNearbyPiglins(level, player, true)`; the meaning of the final `true` was not re-read, Open question 10; this is the chest-minecart anger path that 44-6 left open).
- **Save format**: if a loot table is set: `LootTable` (string, the key identifier) and, when the seed is non-zero, `LootTableSeed` (long), and **no** `Items`; else `Items` (the standard item list). Reading: clears the list first, reads `LootTable` (optional) and `LootTableSeed` (default 0), and reads `Items` only when there is no loot table. (Same keys as 45-8 section 4.2.)

Worked example: a chest minecart from a mineshaft carries `LootTable = chests/abandoned_mineshaft`, seed 0. A hopper below it pulls an item: the first accessor call unpacks with a null player, fills the 27 slots using a random seed, clears the key, then returns the slot's item. A player opening it afterwards sees the already-generated content and no advancement fires (the key is gone).

## 6. Projectile residuals

### 6.1 Snowball (`Snowball`)

`getDefaultItem` = snowball. On entity hit: damage = **3** when the hit entity is a `Blaze`, otherwise **0**, with the `thrown` damage source (direct entity: the snowball; causing entity: its owner); the call is `Entity.hurt` (the zero-damage hit still triggers knockback and the hurt animation). On any hit (`onHit`), on the server only: broadcast entity event **3** and discard. Entity event 3 on the client: 8 particles at the snowball position with zero velocity, using the **item particle** of the thrown stack when the stack is non-empty, else the snowball-item particle. Gravity and drag are those of `ThrowableProjectile` (44-8 section 6.4).

### 6.2 Thrown egg (`ThrownEgg`)

`getDefaultItem` = egg (the blue and brown eggs are the same entity with the stack's variant). On entity hit: `thrown` damage of amount **0**. On any hit (`onHit`), server side only:
1. Roll `nextInt(8) == 0`. If it fails nothing hatches.
2. If it succeeds: the number of chicks is **1**, but a second independent roll `nextInt(32) == 0` makes it **4** (so 1 in 8 hit eggs hatch, one chick with probability 31/32 and four with 1/32).
3. For each chick: create a `chicken` with reason `TRIGGERED`; set its age to **-24000** (a baby); move it to the egg's position with the egg's yaw and pitch 0; copy the egg stack's `chicken_variant` component if present; nudge the chicken out of collisions for the 0 x 0 reference size (`fudgePositionAfterSizeChange` with a zero-sized dimensions); if the nudge fails stop spawning further chicks; add it to the level.
4. In every case broadcast entity event **3** and discard the egg.
Entity event 3 on the client: 8 egg item particles at the egg, each with the three velocity components `(nextFloat() - 0.5) x 0.08` (x, y, z draws in that order per particle), item particle of the stack when non-empty.

### 6.3 Llama spit (`LlamaSpit`)

- Spawn position (`LlamaSpit(level, llama)`): `x = llama.x - (llama.width + 1) x 0.5 x sin(llama.yBodyRot x 0.017453292)`, `y = llama.eyeY - 0.10000000149011612`, `z = llama.z + (llama.width + 1) x 0.5 x cos(llama.yBodyRot x 0.017453292)`; owner = the llama. The llama's shot direction and speed are in 19 (llama).
- Physics: gravity **0.06** per tick (`getDefaultGravity`), air drag **0.99** (`getAirDrag`). Each tick: base tick, then the movement hit-scan (`ProjectileUtil.getHitResultOnMoveVector` with the entity filter) and `hitTargetOrDeflectSelf`; position advances by the pre-hit velocity; rotation updates; the spit is **discarded** when no block in its bounding box is air (it is stuck inside a solid), or when it is in water; otherwise velocity = velocity x 0.99, then gravity.
- Entity hit: when the owner is a living entity, the target takes **1.0** damage from the `spit` source (direct = the spit, causing = the owner) via `hurtServer`; when damage was dealt the post-attack enchantment effects run for the target. When the owner is not a living entity nothing happens. Block hit: on the server the spit is discarded.
- Client: on creation from the add-entity packet it takes the packet velocity as its movement and emits **7** `spit` particles: for `i = 0 .. 6` with `f = 0.4 + 0.1 x i` the particle is at the spit position with velocity `movement x f` (each axis). No synched entity data.

### 6.4 `deflection` overrides (44-8 Open question 15)

Closed: exactly two classes define `Entity.deflection(Projectile)`: `Entity` itself (`reverse` when the entity type is in tag `deflects_projectiles`, else none; 44-8 section 6.3) and `Breeze` (its own deflection constant, wind charges excluded; 44-8 section 6.3). No other class in `world.entity` overrides it. The related `deflect(...)` method (which applies a deflection to a projectile) is overridden only by `WindCharge` (the 5-tick no-deflect window, 44-8). `AbstractArrow` and `Projectile` define the hit helpers that call `deflection`.

## 7. Brain behaviours and the tadpole

### 7.1 `TryLaySpawnOnFluidNearLand(block)` (frog, 44-4 section 1)

Memory conditions: `attack_target` absent, `walk_target` present, `is_pregnant` present. Trigger (one-shot):
1. If the frog is in water or is **not** on the ground: fail (return false).
2. `base = frog.blockPosition().below()`.
3. For each horizontal direction in the order **north, east, south, west** (`Direction.Plane.HORIZONTAL`): `p = base.relative(direction)`. Skip when the block at `p` has a collision shape whose **upward face is not empty** (the neighbour must be open at the top). Skip unless the fluid at `p` is in tag `supports_frogspawn` OR the block at `p` is in block tag `supports_frogspawn`. Skip unless the block above `p` is air. For the first `p` that passes: set the frogspawn block (the behaviour's `block` argument, default state) at `p.above()`, game event `BLOCK_PLACE` (source entity = the frog, with the block state) at `p.above()`, play `frog_lay_spawn` (BLOCKS, volume 1, pitch 1) at the frog, **erase** `is_pregnant`, and return true.
4. If no direction passed the trigger still returns **true** (it does not erase the memory; the frog keeps trying while the activity runs).

### 7.2 `CopyMemoryWithExpiry(sourceType, targetType, predicate, duration)`

Memory conditions: `sourceType` present, `targetType` absent. Trigger (one-shot): if `predicate(entity)` is false return false; else set `targetType` to the value of `sourceType` with an expiry of `duration.sample(random)` ticks (a `UniformInt` draw, one draw) and return true. The source memory is left in place.

### 7.3 Tadpole growth (`Tadpole`)

- `ticksToBeFrog = abs(-24000) = 24000`. Field `age` (int, default 0, saved as `Age`, also saved in the bucket tag; `AgeLocked` boolean saved likewise and synched).
- Per `aiStep` on the server: when not age-locked, `setAge(age + 1)`; every tick on both sides the age-lock particle timer is updated by the shared `AgeableMob.makeAgeLockedParticle` (initial timer 0; resets to 40 when the lock changes).
- `setAge(a)`: stores `a`; when `a >= 24000` the tadpole converts (`ageUp`).
- Feeding (`mobInteract`): a `frog_food` item (item tag) while not age-locked: one item is consumed (`ItemStack.consume(1, player)` in the player's hand), then `age += 20 x getSpeedUpSecondsWhenFeeding(ticksLeft)` where `ticksLeft = max(0, 24000 - age)` and `getSpeedUpSecondsWhenFeeding(t) = (int)((t / 20) x 0.1f)` (integer division of `t` by 20, then times 0.1f in float, truncated: for a fresh tadpole `24000 / 20 = 1200`, `1200 x 0.1 = 120` seconds = 2400 ticks); `happy_villager` particles (one at a random position within the entity's width, y plus 0.5). Result SUCCESS. A golden dandelion (the shared age-lock helper `AgeableMob.canUseGoldenDandelion`/`setAgeLocked`) locks or unlocks the age: toggling to locked sets `age` to 0 and the particle timer to 40. Otherwise the bucket pickup (`Bucketable`) is tried, then the fish interaction. Tadpole attributes (maximum health 6.0 among them) are defined in the class but not tabulated in this document (20 section 18-style attribute tables are the place for them). The golden dandelion path was re-read: it contains `setAge(0)` and the constant 40, as stated.
- Conversion (`ageUp()`, server): `convertTo(frog, ConversionParams.single(tadpole, false, false), after)`; the callback finalises the frog with reason **`CONVERSION`** (difficulty at the frog's block, no group data), sets persistence required, nudges the position out of collisions for the frog's dimensions of the tadpole's pose, and plays `tadpole_grow_up` (volume 0.15, pitch 1.0). `shouldDropExperience` is false.
- Hitbox 0.4 x 0.3 (constants). The brain sensors are nearest living entities, nearest players, hurt-by and frog temptations; the tadpole activities (swim, flee when hurt, tempt) are in 44-7 section 2.

Worked example: a tadpole with age 23000 is fed: `ticksLeft = 1000`, `(1000 / 20) = 50`, `50 x 0.1 = 5.0`, `ageUp(5)` adds `5 x 20 = 100`: age 23100. Fed again: `ticksLeft = 900`, `45 x 0.1 = 4.5` truncated to `4`, adds 80: age 23180.

## 8. Variant and data classes

### 8.1 Copper golem oxidation levels (`CopperGolemOxidationLevels`)

A static map from the four `WeatheringCopper.WeatherState` values to a record of six fields (spin-head sound, hurt sound, death sound, step sound, texture, eye texture); the lookup is `getOxidationLevel(weatherState)`:

| Weather state | Spin head | Hurt | Death | Step | Texture | Eye texture |
|---|---|---|---|---|---|---|
| unaffected | `copper_golem.spin` | `copper_golem.hurt` | `copper_golem.death` | `copper_golem.step` | `textures/entity/copper_golem/copper_golem.png` | `.../copper_golem_eyes.png` |
| exposed | (same four sounds as unaffected) | | | | `.../copper_golem_exposed.png` | `.../copper_golem_eyes_exposed.png` |
| weathered | `copper_golem.weathered_spin` | `..._hurt` | `..._death` | `..._step` (each with the `weathered_` infix) | `.../copper_golem_weathered.png` | `.../copper_golem_eyes_weathered.png` |
| oxidized | `copper_golem.oxidized_spin` | `..._hurt` | `..._death` | `..._step` (`oxidized_` infix) | `.../copper_golem_oxidized.png` | `.../copper_golem_eyes_oxidized.png` |

(The sound event names are the `SoundEvents` field names lowercased with dots; the exact registry paths are in the sound registry.) Unaffected and exposed share all four sounds; only the textures differ.

### 8.2 Horse markings (`Markings`)

Enum with ids: `NONE` 0, `WHITE` 1, `WHITE_FIELD` 2, `WHITE_DOTS` 3, `BLACK_DOTS` 4. `byId` uses `ByIdMap.continuous` with the **WRAP** out-of-bounds strategy, so id `n` maps to `n mod 5` (for non-negative n; a negative id wraps as the shared helper does). The coat colour variant and the packed variant metadata are in 19 section 17; the marking textures are the `horse_markings_*` pack files (data).

## 9. Validation

What was verified and how:
- Every constant in sections 2 to 8 was read from the class named beside it with `javap -c -p -constants` in this round (`WardenSpawnTracker`, `SculkShriekerBlockEntity` and `$VibrationUser`, `SculkShriekerBlock`, `ServerPlayer`, `SpawnUtil` and `$Strategy`, `DispenserBlock`, `DispenserBlockEntity`, `DefaultDispenseItemBehavior`, `OptionalDispenseItemBehavior`, `DispenseItemBehavior` and its 13 anonymous classes, `ProjectileDispenseBehavior`, `BoatDispenseItemBehavior`, `MinecartDispenseItemBehavior`, `EquipmentDispenseItemBehavior`, `ShulkerBoxDispenseBehavior`, `ShearsDispenseItemBehavior`, `FlintAndSteelDispenseItemBehavior`, `SulfurCubeBlockDispenseItemBehavior`, `ProjectileItem` and its `DispenseConfig` and builder, the item classes `ExperienceBottleItem`, `FireChargeItem`, `FireworkRocketItem`, `ThrowablePotionItem`, `WindChargeItem`, `ArrowItem`, `SpectralArrowItem`, `EggItem`, `SnowballItem`, `ContainerEntity`, `Snowball`, `ThrownEgg`, `LlamaSpit`, `TryLaySpawnOnFluidNearLand`, `CopyMemoryWithExpiry`, `Tadpole`, `AgeableMob.getSpeedUpSecondsWhenFeeding`, `CopperGolemOxidationLevels`, `Markings`).
- Binding-count cross-check: `DispenseItemBehavior.bootStrap` contains **13** projectile registrations and **53** direct `registerBehavior` sites, plus **1** `registerBehavior` site in the dyed-shulker-box lambda (54 `registerBehavior` sites; counted again in this round from the bytecode: 53 in the method body, 54 in the whole class); the table in section 4 accounts for them as 1 (armor stand) + 1 (chest) + 22 (boats and chest boats) + 10 (filled buckets) + 1 (empty bucket) + 1 (flint and steel) + 1 (bone meal) + 1 (TNT) + 1 (skull) + 1 (pumpkin) + 1 (shulker box) + 1 (glass bottle) + 1 (glowstone) + 1 (shears) + 1 (brush) + 1 (honeycomb) + 1 (potion) + 6 (minecarts) = **53**, matching the 53 direct call sites (the undyed shulker box is among them); the 54th site is the lambda that registers one behaviour for each dyed colour (the count of 16 in section 4 is the number of colours, inferred from the 16 `*_shulker_box` item models, not counted from the colour collection).
- Only `DispenseItemBehavior` and `DispenserBlock` reference the registration methods (searched across all classes in the jar's `net/minecraft` tree), so the table is complete.
- The `deflection` closure of 6.4 was checked by listing the declared methods of `Entity`, `Breeze`, `AbstractArrow`, `WindCharge` and `Projectile`, and by searching every class under `world` for the string.
- Existing documents re-read against the bytecode (section 1): the random-position helpers of 18 section 4.2 and the ordered box scan of 44-1 section 3 agree.

## Open questions

1. **Generic goals still without a body.** `SitWhenOrderedToGoal`, `OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`, `NonTameRandomTargetGoal`, `MoveThroughVillageGoal`, `DoorInteractGoal`, `InteractGoal`, `UseItemGoal`, `TradeWithPlayerGoal`, `LookAtTradingPlayerGoal`, `PathfindToRaidGoal` appear in 18 and 19 to 21 only by name or by parameter list and were not read in this round. Also not re-read: per-mob goal internals of sheep, cow, pig, chicken, mooshroom, ocelot, horse family, camel, wolf, bee pollinate hover offset, allay `StayCloseToTarget`, `SnifferAi`, `FollowTemptation`, and the frog `RunOne` trigger predicates (44-4 Open questions 16 and 17, x1 Open question 1, minus the items closed in section 1).
2. **Brain behaviours not re-read.** `StrollAroundPoi`, `VillageBoundRandomStroll`, `InsideBrownianWalk`, `SetLookAndInteract`, `NearestItemSensor`, `PlayerSensor`, `MemoryAccessor` and `MemoryCondition` semantics, `PrepareRamNearestTarget` selection arithmetic, goat ram cooldown ranges, the spear retreat arithmetic and the `CrossbowAttack` state machine (44-6 Open questions 4, 5, 12).
3. **`AbstractThrownPotion.onHit`** and the lingering cloud creation were read only as far as 17 section 3.10 gives them; the potion entity classes (`ThrownSplashPotion`, `ThrownLingeringPotion`, `AbstractThrownPotion`) were not re-read here. `FishingHook` was not re-read either (17 section 3.11 holds it).
4. **44-4 Open question 3** (`cat_does_not_teleport_to` consumer) was not searched.
5. **Warden tracker residuals.** `reset()` and `setWarningLevel` are called by `WardenSpawnTrackerCommand` (section 2.1; argument bounds 0 to 4 read). Searched: that class only, plus the player-side NBT, tick and copy paths; whether any block or the warden itself resets or sets the tracker was not searched. Also not read: `Warden.applyDarknessAround` internals beyond 20 section 10, the level event 3007 client effect, and how a shrieker gets `can_summon` true (placed by worldgen with the flag; the creating site was not searched). The tie rule of step 4 in 2.2: the artifact picks the winner with a `Stream.max` over a `comparingInt` comparator on the level, and which of several equal levels wins depends on the JDK reduction rule, which is not part of the artifact; the "first in list order" wording of 2.2 is therefore **(inferred)**, not read. Because every candidate then receives the winner's three counters, only a tie between different `ticks_since_last_warning` or cooldown values is observable.
6. **Firework rocket dispense position.** Closed except one link: the item's position lambda was traced to the helper using `center + step x 0.5000099999997474` (4.1); that the lambda body is exactly that helper call was inferred from the invokedynamic target. The shoot-versus-item-vector question is closed in the shoot-path note after 4.1.
7. **Chest dispense onto a horse.** Closed: see 4.3 (full stack passed, slot access rules, dispenser shrinks by 1). No residual.
8. **Flint and steel.** Closed: see 4.8. Residual: the part of `SulfurCube.primeTime` after its four early-false conditions was not read (20 section 18 and Open question 9).
9. **Sulfur cube.** `SulfurCube.equipItem`, `primeTime(boolean)` and the swallow rules are not read here (20 section 18.2 holds the attributes only).
10. **`PiglinAi.angerNearbyPiglins(level, player, boolean)`**: the meaning of the final `true` (which piglins are angered) was not re-read; 44-6 gives the piglin anger rules for the player-breaks-gold path.
11. **Spawn reasons.** The x1 Open question 1 line for 18 Open questions 11 and 12 is stale: 11 is answered by 44-1 section 4.6, 12 by 44-8 and by section 6 here. The README and x1 should be updated to say so (the reader may not edit them in this round).
12. **Variants.** Cat, cow, pig, chicken, frog, wolf and zombie nautilus variants and their sound variants, painting variants, villager types and professions are data (rule R7) and are not tabulated; the engines choosing a variant at spawn (biome-tag and condition rules) were not re-read. The sound registry paths for the copper golem sounds (8.1) were inferred from the field names.
13. **Not resolvable by static reading** (as in the round statement): the entity-id check against a captured registry sync (19 Open question 31, 20 Open question 25); `46-registry-ids.md` section 11 verifies ids from registration order.
14. **Minecart and boat interpolation** (`NewMinecartBehavior` `lerpSteps`, `adjustToRails`, the boat handlers), the dragon and shulker level events 2006 and 2016, happy ghast leash pull and rider movement, mannequin profile resolution and display text `LineSplitter`: not read in this round.
15. **Scope not covered by this document (needs an x3 round).** Villager, raid and point-of-interest brain behaviours (`StrollAroundPoi`, `VillageBoundRandomStroll`, the work, schedule and gossip classes), the warden brain package (digging, emerging, roar, sniffing), `LongJump` behaviours, `TryToSniff`, nautilus behaviours, piglin `ChargeAttack` and `RamTarget`, the `CrossbowAttack` state machine and quick-charge arithmetic, boat and minecart entity physics, area effect cloud, armor stand, item frame, painting, display, interaction and marker entities, the remaining happy ghast items, `AbstractThrownPotion.onHit` and the wandering trader and villager open items. These are not folded into 18 to 21 by this round; Open questions 1 to 4 and 12 to 14 record the same gap.
