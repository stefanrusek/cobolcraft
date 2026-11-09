# 44 — Residual mob questions, continuation x2 (round RS26)

| Item | Value |
|---|---|
| Covers | A second partial continuation over the residual open questions of 18 to 21 and 44-1 to 44-x1. It (a) re-checks the scope list item by item against the documents that exist and records which items were already closed (section 1, so nobody re-reads them), (b) specifies the warden spawn tracker and the sculk shrieker that drives it (section 2), (c) specifies the dispenser engine and the complete code-defined table of items bound to dispenser behaviours, including every projectile, boat, minecart, bucket, bottle and equipment behaviour (sections 3 and 4; 25 section 3.8 Open question 3 and 44-8 Open question 11), (d) specifies chest-vehicle container handling (section 5; 44-8 Open question 10), (e) closes the projectile residuals of 44-8 Open questions 15 and 16 (section 6: deltas over 44-8 section 10 for snowball, egg and llama spit, and the closed set of `deflection` overrides), (f) specifies the brain behaviours `TryLaySpawnOnFluidNearLand` and `CopyMemoryWithExpiry` and the tadpole age-up (section 7), (g) records the copper golem oxidation-level table and the horse markings enum (section 8), (h) a later pass (the section numbering has no section 9: sections 2 to 8 are the first pass, sections 10 to 16 the later pass): bodies of eleven generic goals (section 10), the declarative behaviour engine and brain memory write rules (11), the sensor base class and two sensors (12), village strolls and look-and-interact (13), the producers of reputation events including the finding that `golem_killed` has none (14), and dispositions plus residuals of the unmentioned classes (15) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) with no execution. A statement is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)", or names an open question. Nothing here is marked recalled. A fixer pass of this round re-read the artifact for the corrections recorded in sections 1, 2.4, 4.1, 4.5, 6, 14 and Open questions 2, 3, 6, 10, 22 and 24. Every value in sections 2 to 8 was read from the class named beside it in this round. |
| Data versus code | Per the operator decisions (design README Part 0, rule R7), data is not tabulated. Tags that the engines read (`rails`, `beehives`, `convertible_to_mud`, `supports_frogspawn`, `sulfur_cube_swallowable`, `shrieker_can_listen`, `frog_food`) are named, not listed; the tables below are code (which item is bound to which behaviour, the constants of each behaviour). |
| Related | Framework [18](18-mob-framework.md) (4.2 goal catalogue, random-position helpers); [41](41-item-entity-physics.md) section 2.5 (the default dispense: item entity spawn); [25-6](25-item-registry-6-spawn-eggs-and-specials.md) section 3.8 (spawn egg dispense and the default-method selection); [44-1](44-residual-mob-questions-1-shared-model-framework.md) (spawn reasons 4.6; the ordered box scan is in 44-1 section 4 (Answers), section 3 being the shared vocabulary); [44-8](44-residual-mob-questions-8-vehicles-and-projectiles.md) (projectile base, deflection 6.3, minecarts, boats); [20](20-mobs-overworld-hostile.md) section 15 (warden); [44-5](44-residual-mob-questions-5-overworld-hostile.md) section 3 (warden brain); [44-6](44-residual-mob-questions-6-nether.md) section 5.6 (goat ram); 44-9 (decor, display, interaction, marker and area entities); [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) sections 8.8 and 8.11 (boats, happy ghast); [45-8](45-entity-nbt-8-vehicles-projectiles-items.md) 4.2 (chest-vehicle NBT keys); [24-8](24-block-registry-8-blackstone-copper-deepslate-modern.md) (sculk shrieker block state) |

Conventions: "level event N" is `ServerLevel.levelEvent(N, pos, data)` (client effect, not specified here beyond the number). "Facing" is the dispenser block's `FACING` direction. "Front block" is the dispenser position moved one block along facing. `center` is the dispenser block centre (`+0.5` on every axis).

## 1. Dispositions of items that the scope names

The round statement lists items as missing. They were checked against the existing documents; the result decides what this document does and does not repeat.

| Scope item | Disposition |
|---|---|
| Item 2: generic goal classes "named in no 44 file" | Already specified in 18 section 4.2 (Float, Panic, Melee, ZombieAttack, RangedAttack, RangedBowAttack, RangedCrossbowAttack, RandomStroll, LookAtPlayer, AvoidEntity, Breed, Tempt, FollowParent, FollowOwner, FollowMob, OpenDoor, BreakDoor, RestrictSun, FleeSun, EatBlock, MoveToBlock, MoveTowardsRestriction, MoveTowardsTarget, LeapAtTarget, TryFindLiquid, BreathAir, ClimbOnTopOfPowderSnow, Swell, OcelotAttack, RandomStand, FollowFlockLeader, and the target goals), with the selector arbitration in 18 section 4.1 (full evaluation order, priority and flag replacement rules, tick-delay scaling). The few generic goals that 18 names only in a parameter list (`SitWhenOrderedToGoal`, `OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`, `NonTameRandomTargetGoal`, `MoveThroughVillageGoal`, `DoorInteractGoal`, `InteractGoal`, `UseItemGoal`, `TradeWithPlayerGoal`, `LookAtTradingPlayerGoal`, `PathfindToRaidGoal`) are not re-read in this document: they are listed in Open question 1 and need a later round. |
| Item 1: `DefaultRandomPos.getPosTowards`, `RandomPos.generateRandomPos` sampling, `GoalUtils` | Already complete in 18 section 4.2 "Random position helpers". Re-read here against `RandomPos`, `DefaultRandomPos` and `GoalUtils`: ten attempts, strictly-greater replacement, the within-radians direction (`atan2(dz, dx) - 1.5707963705062866`, `sqrt` of a double draw lerped between the minimum and maximum range and multiplied by `Mth.SQRT_OF_TWO`, rejected when either horizontal offset exceeds the maximum range, then `nextInt(2v+1) - v + yOffset`), the home nudge, and the four rejection tests all agree. Closed. One restatement that 18 words differently: `GoalUtils.mobRestricted(mob, range)` is true when the mob has a home and the home centre is **closer** than `homeRadius + range + 1` (`BlockPos.closerToCenterThan(position, ...)`), so "restricted" means "near enough to home that the pick must stay inside home". |
| Item 1: `BlockPos.manhattanOrdered` visiting order (44-4 Open question 1) | Already specified in 44-1 section 3 "ordered box scan" and in 35-7 section 2.3. Re-read here against `BlockPos$3` (the iterator): order, depth termination and the positive-then-mirrored z agree exactly. The three public wrappers differ only in the depth limit: `withinManhattan(pos, r)` uses reach `(r, r, r)` and maximum depth `r`; `withinClippedManhattan(pos, rx, ry, rz)` uses maximum depth `max(rx, ry, rz)`; `withinBoxByManhattanDistance(pos, rx, ry, rz)` uses maximum depth `rx + ry + rz`. Closed. |
| Item 5 and 18 Open question 11: `EntitySpawnReason` gates | Answered in 44-1 section 4.6 (RQ-1.18, the matrix of which reasons run `checkSpawnRules` and `checkSpawnObstruction`) and 44-2 section 2.5 (spawner-side predicates). The status line in x1 Open question 1 ("18 Open q11 still open") is stale. This document does not repeat the matrix. The one reason this document adds a producer for is `TRIGGERED` (the warden, section 2.4) and `DISPENSER` (boat, minecart, armor stand, spawn egg: sections 3.4 and 4). |
| Item 6 and 18 Open question 12: projectiles | `ShulkerBullet` flight is in 44-9 (the "not re-read" remark at 44-8 Open question 16 is stale), `EyeOfEnder` in 21 section 8.12, `FireworkRocketEntity` in 21 section 8.7, `ThrownExperienceBottle` in 21 section 8.13, `FishingHook` in 17 section 3.11 and 44-8 section 10.1, evoker fangs in 20 section 13, thrown potions in 44-8 section 10.2 and 17 section 3.15, llama spit in 44-8 section 10.3 and 21 section 8.14, snowball, egg and experience bottle in 44-8 section 10.4. Section 6 of this document only records deltas. |
| Item 8: block blast resistance (44-1 Open question 7) | Tabulated in 44-5 section 6 and in the block registry documents (24). The deferral in 44-1 Open question 7 is superseded. |
| Item 8: 44-4 Open question 3 (`cat_does_not_teleport_to` consumer) | Answered: the only consumer of block tag `cat_does_not_teleport_to` is `Cat$CatRelaxOnOwnerGoal`, which passes the tag to `Cat.randomTeleport(x, y, z, flag, tag)` (byte search over every class of the jar's `net/minecraft` tree: `BlockTags`, `VanillaBlockTagsProvider` (data generation) and that goal reference the field). The teleport body was not read; Open question 4. |
| Item 8: 44-4 Open question 12, tadpole age-up, `TryLaySpawnOnFluidNearLand`, `CopyMemoryWithExpiry`, `GoToWantedItem` | Tadpole, `TryLaySpawnOnFluidNearLand` and `CopyMemoryWithExpiry`: section 7. `GoToWantedItem`: already in 44-6 section 5.4 (not re-read). |
| Item 7: copper golem oxidation levels, painting variants, `Markings` | Copper golem oxidation levels and `Markings`: section 8. Cat, cow, pig, chicken, frog, wolf and zombie-nautilus variants and painting variants are registry **data** (design README rule R7); only the engines that select them (spawn-time variant selection) are in 19, 21 and 44-4 to 44-7. Villager type and profession tables: 19 section 22 and 44-3. |
| Item 3, 4: `StrollAroundPoi`, `VillageBoundRandomStroll`, `InsideBrownianWalk`, `SetLookAndInteract`, `SetEntityLookTarget`, `NearestItemSensor`, `PlayerSensor`, `AnimalMakeLove`, `PrepareRamNearestTarget` | `SetEntityLookTarget` and `AnimalMakeLove` have bodies in 44-4, 44-6 and 44-7. `VillageBoundRandomStroll`, `InsideBrownianWalk` and `SetLookAndInteract` are specified in section 13, `NearestItemSensor` and `PlayerSensor` in section 12 (declarative engine they run on: section 11); they appear by name in 18 section 4.6 and 4.7 and 19 section 22. `StrollAroundPoi` is only partly covered (see Open question 2). `PrepareRamNearestTarget`: 44-6 section 5.6 holds the constants and the walk/look behaviour, and the candidate selection is answered in section 1.2 below. The warden part of item 4 is section 2. |

### 1.1 Map of the section 15 scope list to the documents that close it

Open question 15 lists work that this document does not do. Where another document already holds it, the table gives the pointer. A pointer was located by searching headings and names in the documents named; it says where the topic is treated, not that this round re-verified the content there. "Open" means no document found treats it.

| Item | Where treated | Status |
|---|---|---|
| Villager, point-of-interest and raid brain behaviours (acquire, work, schedule, gossip, panic, hide, celebrate) | [44-3](44-residual-mob-questions-3-villagers-poi-raids.md) sections 1 to 5 (schedule 3.1, work 2.7, strolls to POI 2.8, raid hide 2.10); gossip and reputation in [19](19-mobs-land-friendly-and-neutral.md) 22.5 and section 14 here; raids in 20 section 14 | Covered elsewhere |
| `StrollAroundPoi`, `VillageBoundRandomStroll` | section 13 here, 44-3 2.8 | Partly covered, see Open question 2 |
| Warden brain: digging, emerging, roar, sniffing (`TryToSniff`) | [44-5](44-residual-mob-questions-5-overworld-hostile.md) sections 3.2 to 3.5; 20 section 15 | Covered elsewhere (roar not located by heading, Open question 24) |
| `LongJump` behaviours | [44-4](44-residual-mob-questions-4-land-animals.md) section 1.1 | Covered elsewhere |
| Nautilus behaviours, nautilus `ChargeAttack` | [44-7](44-residual-mob-questions-7-aquatic.md) sections 10.5 to 10.8 | Covered elsewhere |
| Piglin `ChargeAttack`, `RamTarget`, spear behaviours | [44-6](44-residual-mob-questions-6-nether.md) (spear 2.11; `RamTarget` and `PrepareRamNearestTarget` in 5.6: time-outs 200 and 160, force factor 1.65, cooldown ranges `TIME_BETWEEN_RAMS` 600 to 6000 and screamer 100 to 300, ram prepare time 20, distances 4 and 7); 44-4 and 19 for goat ram | Covered elsewhere (goat cooldown ranges are in 44-6 5.6, not open) |
| `PrepareRamNearestTarget` candidate selection | section 1.2 here (answer); constants in 44-6 5.6 | Answered (not read: `RamCandidate` consumers beyond its three fields) |
| Armor stand, item frame, painting, display entities, interaction, marker, area effect cloud | [44-9](44-residual-mob-questions-9-end-bosses-decor.md) (44-8 Open question 20) | Covered elsewhere |
| Boats and minecart physics | 44-8 sections 3 and 4; 21 section 8.8 | Covered elsewhere |
| Happy ghast | 21 section 8.11 | Covered elsewhere |
| `CrossbowAttack` state machine | none found as a section; 44-5 section 2 holds the crossbow item arithmetic only | **Open** (Open question 22) |
| Quick-charge arithmetic | [44-5](44-residual-mob-questions-5-overworld-hostile.md) sections 2.1 to 2.3 (enchantment value engine, charge time and use). This document has no section for it; the earlier mention here was a scope item, not content | Covered elsewhere |
| `FoxMoveControl` | name appears only in 44-4 (fox section 4); body not located | **Open** (Open question 22) |
| Panda roll and sneeze | 44-4 section 7 | Covered elsewhere (not re-checked for roll and sneeze specifically) |
| Bee attack and hive timers | 44-4 section 15; 19 section 16 | Covered elsewhere (not re-checked for hive timers specifically) |
| Turtle behaviours and position helpers | 44-4 section 11; 21 section 4.12 | Covered elsewhere for the behaviours; position helpers are Open question 22 |

### 1.2 `PrepareRamNearestTarget` candidate selection (answers 44-6 Open question 4)

Classes read: `PrepareRamNearestTarget`, `PrepareRamNearestTarget$RamCandidate`. `calculateRammingStartPosition(goat, target)` returns an optional position:
1. Let `T` be the target's block position. If `isWalkableBlock(goat, T)` is false: no candidate.
2. For each horizontal direction in `Direction.Plane.HORIZONTAL` order (north, east, south, west): start at `T` and take up to `maxRamDistance` steps outward in that direction. Before each step is accepted the block moved to is tested: while it is walkable continue; when it is not walkable step back one block and stop. (Walking the full number of steps ends at the last walkable block.)
3. If the Manhattan distance from the resulting position to `T` is at least `minRamDistance`, add the position to the candidate list.
4. Sort the list ascending by squared distance (`Vec3i.distSqr`) from the goat's own block position. Keep the first candidate for which `navigation.createPath(position, 0)` is non-null and the path `canReach()`. The result is that position, or none.

`isWalkableBlock(goat, pos)` is true when `navigation.isStableDestination(pos)` holds and the goat's pathfinding malus for the path type `WalkNodeEvaluator.getPathTypeStatic(goat, pos)` equals exactly 0. `chooseRamPosition` clears the stored "reached ram position" timestamp, then maps the optional start position to a `RamCandidate` of (start position, the target's block position, the target entity). `minRamDistance` and `maxRamDistance` are 4 and 7 for the goat (44-6 5.6). Worked example: goat at (0, 64, 0), target block (10, 64, 0), open flat ground: east candidate walks 7 steps to (17, 64, 0), Manhattan distance 7 >= 4, added; west candidate (3, 64, 0) distance 7, added; north and south candidates (10, 64, -7) and (10, 64, 7) distance 7, added. Sorted by squared distance from the goat: (3,64,0) = 9, then (10,64,-7) and (10,64,7) = 149 (equal; list order keeps north before south because the sort is stable), then (17,64,0) = 289. The first reachable one is chosen.

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

**Respawn and dimension change**: `ServerPlayer.restoreFrom` copies the **reference** of the old player's tracker into the new player object (not a copy of the three numbers), for every reason (death, end exit, dimension change); the level therefore survives death. `reset()` exists (all three counters to 0). Callers of `reset()` and `setWarningLevel` outside the tracker exist: the command class `WardenSpawnTrackerCommand` registers `warden_spawn_tracker`, guarded by the permission check `LEVEL_GAMEMASTERS`, with two subcommands. `clear` calls `reset()` on the tracker of every targeted player; `set warning_level <int>` calls `setWarningLevel` on the tracker of every targeted player, the integer argument being bounded **0 to 4** (read: `IntegerArgumentType.integer(0, 4)`), and the tracker clamps again. The player-selector form and the success message keys (`commands.warden_spawn_tracker.clear.success.single` / `.multiple`, `.set.success.single` / `.multiple`) are the only other facts read; the target argument type was not decoded beyond "a collection of players". Callers: a byte search over every class of the jar's `net/minecraft` tree finds `WardenSpawnTracker` referenced only by `Commands` (registration), `WardenSpawnTrackerCommand`, `ServerPlayer` and `SculkShriekerBlockEntity`; neither the `Warden` nor any block other than the shrieker's block entity refers to it.

### 2.2 `tryWarn(level, shriekerPos, player)` (static)

Returns an optional int: empty means "no warning level was produced"; a value is the new level.
1. If any `Warden` entity exists inside the axis-aligned box of size 48 x 48 x 48 centred on the shrieker block centre: return empty.
2. Collect the candidate players: every non-spectator, alive `ServerPlayer` in the level whose position is closer than 16.0 to the shrieker block centre (`Vec3.closerThan`); if the triggering player is not in that list, add him (so he counts even when he stands farther than 16 blocks, for instance when a projectile or item of his reached the shrieker).
3. If **any** candidate's tracker is on cooldown: return empty.
4. Pick the candidate whose tracker has the highest warning level (`max` by level; the first such candidate in list order wins a tie, list order being the level's player order with the triggering player appended last if he was added). Increase that tracker's level (section 2.1; cooldown was off for every candidate, so the increase happens). Then copy that tracker's three counters (level, cooldown, ticks since) into **every** candidate's own tracker (they all share the winner's values afterwards). Return the winner's level.

### 2.3 The shrieker block entity

Block state (24-8): `shrieking`, `waterlogged`, `can_summon` (all default false). Constants: listener radius 8 (the vibration listener), `SHRIEKING_TICKS = 90`, `WARNING_SOUND_RADIUS = 10`, `WARDEN_SPAWN_ATTEMPTS = 20`, `WARDEN_SPAWN_RANGE_XZ = 5`, `WARDEN_SPAWN_RANGE_Y = 6`, `DARKNESS_RADIUS = 40`. The block entity keeps its own `warning_level` int (saved under that key, default 0) next to the vibration `listener` data; this is the level of the **last** shriek, not the player's. `can_summon` producers: `SculkBlock.getRandomGrowthState` draws `nextInt(11)`; on 0 it places a sculk shrieker with `can_summon` set from a boolean parameter (the place that sets that parameter was not traced), otherwise a sculk sensor (waterlogged copied from the fluid). Sculk spread therefore creates shriekers with `can_summon`; `CaveFeatures` also references the property.

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
3. **Find a floor** (`moveToPossibleSpawnPosition`): let `cursor = start` and `above = block state at start`; repeat for `k = v` down to `-v` inclusive (that is `2v + 1 = 13` steps for `v = 6`): move the cursor one block down; `floor = block state at the cursor`; if the strategy accepts `(cursor, floor state, above position, above state)` then the candidate position is the block **above** the cursor (cursor moved back up one) and the search ends; otherwise `above = floor` and continue. Failing every step skips the attempt.
4. If `checkAABB` is true (it is false for the warden call) the entity-type spawn box at `(x + 0.5, y, z + 0.5)` must be free of collisions.
5. Create the mob at the candidate (random yaw handled by the create call); if it passes its own `checkSpawnRules(level, reason)` and `checkSpawnObstruction(level)`, add it with passengers, play its ambient sound, and return it. Otherwise discard it and continue.
After all attempts: no mob (empty).

Strategy `ON_TOP_OF_COLLIDER` (read, the one the warden uses): accept when the state **above** the cursor has an **empty collision shape** at the above position AND the floor state's collision shape at the cursor has a **full upward face** (`Block.isFaceFull(shape, UP)`). `ON_TOP_OF_COLLIDER_NO_LEAVES` additionally refuses a **floor** state (the block at the cursor) that is in the `leaves` tag. Read: the strategy receives (level, cursor position, floor state, above position, above state); it accepts when the above state's collision shape is empty, the floor state is not in the `leaves` tag, and the floor's collision shape has a full upward face. The leaves test is on the floor state, not on the above state (an earlier draft had it the other way round). The legacy iron golem strategy is the block-list one in 44-2 section 2.5.

### 2.5 Worked examples

1. **Four shrieks.** A fresh player stands on a `can_summon` shrieker (no warden within 48 blocks, nobody else near). Tick 0: shriek 1, tracker level 0 to 1, cooldown 200, shrieker stores 1 (sound `nearby_close`). The shrieker cannot shriek again for 90 ticks (`shrieking`); at tick 91 he steps again: the tracker is still on cooldown (200 - 91 = 109), so `tryWarn` is empty, `tryShriek` returns before shrieking, and the shrieker stays silent. Cooldown reaches 0 after 200 decrements; whether shriek 2 can happen at tick 200 or 201 depends on the order, inside the player's own tick, of the tracker's `tick()` (the cooldown decrement) and the movement that steps on the block. That order was not read. What was read: `ServerLevel.tick` runs scheduled block ticks, fluid ticks, raids, the chunk source and block events **before** its `entities` section, so the shrieker's 90-tick block tick (which only clears `shrieking`) always precedes the player ticks of the same game tick and does not decide the 200 versus 201 question. This example **assumes** the decrement comes before the step-on within the player's tick **(inferred)**. On that assumption shriek 2 is at tick 201 (level 2, `nearby_closer`); shriek 3 at tick 402 (level 3, `nearby_closest`); shriek 4 at tick 603: level 4, and the block tick 90 ticks later runs `tryRespond`: a warden is spawned near the shrieker (no reply sound), Darkness is applied within 40 blocks. If every one of the 20 spawn attempts fails, the `listening_angry` sound plays instead.
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

`DispenseItemBehavior.bootStrap` makes **53** direct `registerBehavior` call sites in its own body (including the undyed shulker box), plus **1** inside a lambda that registers every dyed shulker box: **54** `registerBehavior` call sites in all, of which 1 is inside the dyed shulker box lambda and 53 are direct (re-counted in this round: 54 call sites in the class, one of them in the lambda method). Separately **13** `registerProjectileBehavior` calls; no other class registers a behaviour (the only classes in the jar that reference the registration methods are `DispenseItemBehavior` and `DispenserBlock`). Items below not listed use the default selection of 3.2.

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
| firework rocket | `FireworkRocketEntity` with a one-item copy at the position, flag "shot at angle" true | the item's position function, which is a direct method reference (bootstrap method handle) to the private static helper `getEntityJustOutsideOfBlockPos(BlockSource, Direction)`: `center + facing step x 0.5000099999997474` per axis (the constant read three times, one per axis). The config was read as uncertainty 1.0, power 0.5, event 1004. The item's separate constant `ROCKET_PLACEMENT_OFFSET = 0.15` belongs to the player-use path, not the dispenser | **1.0** | **0.5** | **1004** |
| fire charge | `SmallFireball` at the position with the **normalised** vector `(triangle(stepX, 0.11485000000000001), triangle(stepY, 0.11485000000000001), triangle(stepZ, 0.11485000000000001))` (draws in x, y, z order from the level random source), then the stack is set as its item | `getDispensePosition(source, 1.0, (0,0,0))` | **6.6666665** | **1.0** | **1018** |
| wind charge | `WindCharge` at the position with the movement vector `(triangle(stepX, 0.11485000000000001), triangle(stepY, ...), triangle(stepZ, ...))` handed to its constructor; that vector is **overwritten** as delta movement by `Projectile.shoot` (below) | `getDispensePosition(source, 1.0, (0,0,0))` | **6.6666665** | **1.0** | **1051** |

`triangle(c, d) = c + d x (nextDouble() - nextDouble())`. The splash and lingering rows share one item class (`ThrowablePotionItem`), whose config multiplies the defaults by 0.5 and 1.25 exactly like the experience bottle (read). The constant 0.11485000000000001 equals `0.0172275 x 6.666666...` (computed).

Shoot-path note (read from `ProjectileDispenseBehavior`, `FireChargeItem`, `WindChargeItem`): the dispenser always calls `Projectile.spawnProjectileUsingShoot`, i.e. `Projectile.shoot(dx, dy, dz, power, uncertainty)` with the facing step, never the item's own `shoot`; the `shoot` overrides of `FireChargeItem` and `WindChargeItem` are empty methods and are off this path, and `AbstractHurtingProjectile`, `SmallFireball` and `WindCharge` do not override `shoot`. So the **only** noise applied to the final velocity of a dispensed wind charge is the one in `shoot`: `normalize(step) + triangle(0, 0.0172275 x 6.6666665) per axis`, times power 1.0 (the draws of `shoot` happen after the item's three draws in the same random source). The item's own vector (`triangle(step, 0.11485000000000001)`, three draws x, y, z) is a **separate earlier** draw; it is not added to the shoot noise and, for the wind charge, has no lasting effect. For both the fire charge and the wind charge the item's vector has **no lasting effect** (read: the `AbstractHurtingProjectile` constructor taking a vector only calls `assignDirectionalMovement(vector, accelerationPower)`, which sets the delta movement to `normalize(vector) x accelerationPower` and a sync flag; `accelerationPower` is a separate field defaulting to 0.1 and is not derived from the vector; `Projectile.shoot` then overwrites the delta movement). `Projectile.shoot` reaches its noise through `getMovementToShoot(dx, dy, dz, power, uncertainty)`: `normalize(d)`, plus `triangle(0, 0.0172275 x uncertainty)` per axis in x, y, z order, times power; only the `Projectile` class of the entity chain defines `getMovementToShoot`. An implementer therefore draws 3 (item vector) + 3 (shoot noise, per axis) triangle values per dispensed fire or wind charge and applies the second set to the velocity only (the first three draws still advance the random source).

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
Otherwise `AbstractMinecart.createMinecart(level, x, y + o, z, type, DISPENSER, the dispensed stack, null player)` (read: the call passes the stack; `createMinecart` applies `EntityType.createDefaultStackConfig(level, stack, null)` to the new cart, so the stack's custom name and custom data are applied, as for boats in 4.4 and armor stands in 4.2; only the player is null); when it was created it is added to the level and the stack shrinks by 1. The stack is returned.

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
- **Destruction** (`chestVehicleDestroyed(damageSource, level, entity)`): nothing unless the game rule `entity_drops` is true; then `Containers.dropContents(level, entity, container)` (every stack as an item entity); then if the damage source's **direct entity** is a `Player`, nearby piglins are angered (`PiglinAi.angerNearbyPiglins(level, player, true)`; the final `true` is read in section 5.1 below; this is the chest-minecart anger path that 44-6 left open).
- **Save format**: if a loot table is set: `LootTable` (string, the key identifier) and, when the seed is non-zero, `LootTableSeed` (long), and **no** `Items`; else `Items` (the standard item list). Reading: clears the list first, reads `LootTable` (optional) and `LootTableSeed` (default 0), and reads `Items` only when there is no loot table. (Same keys as 45-8 section 4.2.)

**5.1 `PiglinAi.angerNearbyPiglins(level, player, requireSight)`** (read in the fixer pass; the reviewer's reading that `true` means "no line of sight needed" is **wrong**, the bytecode says the opposite). Piglins (`Piglin`, not brutes) inside the player's bounding box inflated by 16.0 pass a first filter `PiglinAi.isIdle` (the piglin's brain has the `IDLE` activity active). The second filter: when `requireSight` is false every remaining piglin passes; when it is **true** the piglin must also pass `BehaviorUtils.canSee(piglin, player)`. So the final `true` of the chest-vehicle destruction path means "only idle piglins that can see the player". Each remaining piglin: when the `universal_anger` game rule is true, `setAngerTargetToNearestTargetablePlayerIfFound`, else `setAngerTarget(level, piglin, player)`.

Worked example: a chest minecart from a mineshaft carries `LootTable = chests/abandoned_mineshaft`, seed 0. A hopper below it pulls an item: the first accessor call unpacks with a null player, fills the 27 slots using a random seed, clears the key, then returns the slot's item. A player opening it afterwards sees the already-generated content and no advancement fires (the key is gone).

## 6. Projectile residuals

### 6.1 Snowball, egg and llama spit: deltas over 44-8 and 21

The rules themselves are already in [44-8](44-residual-mob-questions-8-vehicles-and-projectiles.md) section 10.2 (thrown potion engine), 10.3 (llama spit order) and 10.4 (snowball, egg, experience bottle), and in [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) section 8.14 (spit spawn position, gravity 0.06, drag 0.99, damage 1.0). They are not repeated here (an earlier draft of this section did, and the dispositions that called them unread were stale: 44-8 Open question 16 lists them as done). This document re-read `Snowball`, `ThrownEgg` and `LlamaSpit` against those texts and found them correct, with these additions only.

### 6.2 Deltas (the sentences that are new)

| Item | New fact (read in this round) |
|---|---|
| Snowball type test | 44-8 10.4 marks the hit-damage type test "inferred". It is read: `instanceof Blaze` (any `Blaze` subclass), damage **3**, else damage **0**; the call is `Entity.hurt` with the `thrown` source (direct entity: the snowball; causing entity: its owner), and the zero-damage hit still produces knockback and the hurt animation. |
| Snowball client event 3 | **8** particles at the snowball position with zero velocity: the item particle of the thrown stack when the stack is non-empty, else the snowball-item particle. |
| Egg client event 3 | **8** egg item particles at the egg, each with the three velocity components `(nextFloat() - 0.5) x 0.08` (x, y, z draws in that order per particle); the item particle of the stack when non-empty. |
| Egg hatching counts | 1 in 8 hit eggs hatch; one chick with probability 31/32, four with 1/32 (the product of the two rolls in 44-8 10.4). |
| Llama spit, client side | On creation from the add-entity packet it takes the packet velocity as its movement and emits **7** `spit` particles: for `i = 0 .. 6`, `f = 0.4 + 0.1 x i`, each at the spit position with velocity `movement x f` on every axis (exact form of the jitter that 44-8 10.3 words loosely). No synched entity data. |
| Spit post-attack | When damage was dealt (owner is a living entity) the post-attack enchantment effects run for the target; a non-living owner does nothing. |

### 6.3 Potions

Nothing new: `AbstractThrownPotion`, `ThrownSplashPotion` and `ThrownLingeringPotion` are specified in 44-8 section 10.2 and 17 section 3.15 (not 17 section 3.10, which is the trident). The dispenser-side throw is in 4.1.

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

## 10. Generic goals that 18 only named (closes the bodies of x2 Open question 1)

Classes read in this round: `SitWhenOrderedToGoal`, `OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`, `NonTameRandomTargetGoal`, `InteractGoal`, `LookAtTradingPlayerGoal`, `TradeWithPlayerGoal`, `UseItemGoal`, `DoorInteractGoal`, `MoveThroughVillageGoal`, `PathfindToRaidGoal`. The goal selector rules (flags, `canContinueToUse` defaulting to `canUse`, tick-delay scaling) are in 18 section 4.1 and are not repeated. "Flags" means the goal flag set.

### 10.1 `SitWhenOrderedToGoal(tamable)` (flags JUMP and MOVE)

| Member | Behaviour |
|---|---|
| `canUse` | Let `s` = `isOrderedToSit`. In this order: (1) false when `s` is false and the animal is not tame; (2) false while in water; (3) false while not on the ground; (4) true when `getOwner()` is null or the owner is in a different level (so an ownerless or cross-dimension pet sits); (5) false when the owner is closer than 12 blocks (squared distance below 144.0) and the owner has a last-hurt-by mob (`getLastHurtByMob` non-null); (6) otherwise `s`. |
| `canContinueToUse` | `isOrderedToSit` |
| `start` | stop the navigation, then `setInSittingPose(true)` |
| `stop` | `setInSittingPose(false)` |

So a tame pet ordered to sit actually sits only on dry ground, and it gets up (stays standing) when the owner within 12 blocks has been attacked by a mob. A wild animal for which `isOrderedToSit` is true (a state a tame animal can reach by being ordered, then losing tameness through other code) passes check (1).

### 10.2 Owner-linked target goals (flag TARGET; they extend `TargetGoal` with `mustSee` false)

- **`OwnerHurtByTargetGoal(tamable)`**, `canUse`: the animal is tame and not ordered to sit; its owner exists; `owner.getLastDamageSource(100)` (the argument is the maximum age in ticks: the method returns the stored source, or nothing when game time minus the last-damage tick stamp is greater than the argument; read; the no-argument form uses 40) is non-null and is **not** in the damage-type tag `NO_WOLF_RETALIATION` (a missing source, or a tagged one, gives false); let `t = owner.getLastHurtByMob`; true when the owner's `getLastHurtByMobTimestamp` differs from the goal's stored `timestamp`, the animal `canAttack(t, TargetingConditions.DEFAULT)` and `tamable.wantsToAttack(t, owner)` (the per-species hook, read where each tameable is specified in 19). `start`: `setTarget(t)`; store the owner's current `getLastHurtByMobTimestamp` in `timestamp` (when the owner exists); then the base `TargetGoal.start`.
- **`OwnerHurtTargetGoal(tamable)`**: identical, with `getLastHurtMob` and `getLastHurtMobTimestamp` of the owner in place of the hurt-by pair, and **no** damage-source or tag check.
- **`NonTameRandomTargetGoal(tamable, class, checkVisibility, selector)`**: a `NearestAttackableTargetGoal` built with random interval **10**, `mustReach` false, the given visibility flag and selector. `canUse` = the animal is **not** tame and the base `canUse` holds. `canContinueToUse`: when the goal has a `targetConditions` object, the result is `targetConditions.test(level, mob, currentTarget)` (the base class's follow-range and reachability checks are skipped); otherwise the base result.

Worked example: a tame wolf, not sitting; its owner is hit by a zombie at tick 500 (the owner's hurt-by timestamp becomes 500; the stored goal timestamp is 0). Evaluation: the damage source is younger than 100 ticks and not tagged, the timestamps differ, the zombie passes `DEFAULT` conditions and `wantsToAttack` is true, so the wolf targets the zombie and stores 500. At the next evaluation the timestamps are equal, so the goal does not retarget the same hit.

### 10.3 Dialogue goals

| Goal | Behaviour |
|---|---|
| `InteractGoal(mob, class, range [, probability])` | A `LookAtPlayerGoal` (18 section 4.2) with flags set to LOOK and MOVE (the parent has LOOK only), so the mob also stands still while looking. Nothing else is overridden. |
| `LookAtTradingPlayerGoal(villager)` | A `LookAtPlayerGoal` for class `Player`, range 8.0. `canUse`: when `isTrading`, set the look-at entity to `getTradingPlayer` and return true; otherwise false. |
| `TradeWithPlayerGoal(villager)` (flags JUMP and MOVE) | `canUse` is false when any of: the villager is not alive, is in water, is not on the ground, was hurt recently (`wasHurtRecently`), has no trading player, or the trading player is farther than 4 blocks (squared distance above 16.0); true otherwise. `canContinueToUse` is not overridden (the default, which is `canUse`). `start`: stop the navigation. `stop`: `setTradingPlayer(null)`, which closes the trade for the player. |
| `UseItemGoal(mob, stack, finishSound, predicate)` (no flags) | `canUse` = `predicate(mob)`. `canContinueToUse` = `mob.isUsingItem`. `start`: set the main-hand slot to a copy of the stored stack and `startUsingItem(MAIN_HAND)`. `stop`: set the main hand to the empty stack; when a finish sound is configured, play it with volume 1.0 and pitch `0.9 + 0.2 * nextFloat` (the mob's random source). |

### 10.4 `DoorInteractGoal` (abstract base of `OpenDoorGoal` and `BreakDoorGoal`)

Construction fails with an error unless the mob has ground path navigation (`GoalUtils.hasGroundPathNavigation`). State: `doorPos` (initially `BlockPos.ZERO`), `hasDoor`, `passed`, and two floats `doorOpenDirX`, `doorOpenDirZ`. Subclass behaviour is in 18 section 4.2; this is the shared part.

1. `canUse`: false without ground navigation; false unless the mob has `horizontalCollision`; false when the navigation has no path or the path is done. Then for `i` from 0 up to (exclusive) `min(path.nextNodeIndex + 2, path.nodeCount)`: take node `i`, set `doorPos = (node.x, node.y + 1, node.z)`; skip it when `distanceToSqr(doorPos.x, mob.y, doorPos.z) > 2.25`; otherwise set `hasDoor = DoorBlock.isWoodenDoor(level, doorPos)` and return true as soon as it is true. If no node qualified: `doorPos = mob.blockPosition().above()`, `hasDoor = isWoodenDoor(level, doorPos)`, and return `hasDoor`. (Wooden means a door block whose material is not iron, per `isWoodenDoor`; not re-read here.)
2. `isOpen`: false when `hasDoor` is false; if the block at `doorPos` is no longer a door block, `hasDoor` becomes false and the result is false; else the door's `OPEN` property.
3. `setOpen(open)`: only when `hasDoor` and the block is a door: call the door block's `setOpen(mob, level, state, doorPos, open)`.
4. `start`: `passed = false`; `doorOpenDirX = doorPos.x + 0.5 - mob.x` and `doorOpenDirZ = doorPos.z + 0.5 - mob.z` (floats).
5. `requiresUpdateEveryTick` is true. `tick`: with `dx = doorPos.x + 0.5 - mob.x`, `dz = doorPos.z + 0.5 - mob.z` (floats), set `passed = true` when `dx * doorOpenDirX + dz * doorOpenDirZ < 0` (the mob has crossed the door plane).
6. `canContinueToUse` = `not passed`.

### 10.5 `MoveThroughVillageGoal(mob, speed, onlyAtNight, distanceToPoi, canDealWithDoors)` (flag MOVE)

Fields: the chosen `poiPos`, a path, and a `visited` list of positions (capacity trimmed to 15, see step 1). Needs ground path navigation (error otherwise). `canDealWithDoors` is a boolean supplier, evaluated at path-creation time.

`canUse`:

1. Fail without ground navigation. Trim `visited`: when it holds more than 15 entries, remove the **first** (oldest) one (one removal per call).
2. Fail when `onlyAtNight` and the level `isBrightOutside`.
3. Fail unless `ServerLevel.isCloseToVillage(mob.blockPosition(), 6)` (six sections; semantics in 44-2 section 1 of the village table).
4. Pick a position with `LandRandomPos.getPos(mob, 15, 7, scorer)` where the scorer of a candidate block `p` is: `-infinity` when `p` is not in a village (`isVillage`); otherwise the negated squared distance from `p` to the nearest occupied POI of tag `village` within 10 blocks that has not been visited (`PoiManager.find(typeFilter = tag village, posFilter = not visited, centre p, radius 10, occupancy IS_OCCUPIED)`), and `-infinity` when no such POI exists. Failing to find a position fails the goal.
5. Find the nearest such POI (same filter, radius 10, centred on the **picked position** converted to a block). None: fail. Store it as `poiPos`.
6. With door opening set by the supplier, create a path to `poiPos` (accuracy 0), then restore door opening to true. If the path is null, try a fallback: pick `DefaultRandomPos.getPosTowards(mob, 10, 7, bottomCentre(poiPos), PI/2)` (1.5707963705062866); null fails the goal; else, again with the supplier setting, path to that point (accuracy 0), restore door opening to true; still null fails.
7. Scan the path nodes in order: for each node, check the block at `(node.x, node.y + 1, node.z)`; if it is a wooden door (`DoorBlock.isWoodenDoor`: a door block whose set type can be opened by hand), replace the path with a new path to that **node** position (accuracy 0, with door opening left at the restored value) and stop scanning. Succeed when the path is non-null.

`start`: `navigation.moveTo(path, speed)`. `canContinueToUse`: false when the navigation is done; otherwise true while the mob is **not** within `mob.bbWidth + distanceToPoi` of `poiPos` (`closerToCenterThan`), i.e. it keeps walking until near the POI. `stop`: the POI is appended to `visited` when the navigation **is done**, or when it is not done but the mob is within `distanceToPoi` of the POI; in the remaining case (still walking, farther than `distanceToPoi`) nothing is recorded.

Constants: village-closeness 6 sections, wander radii 15 and 7, POI search radius 10, fallback `getPosTowards` radii 10 and 7 with angle PI/2, `visited` capacity 15.

### 10.6 `PathfindToRaidGoal(raider)` (flag MOVE, speed 1.0, recruitment delay 20)

The raider goal list of 20 describes the behaviour; re-read here and confirmed, with these residuals. `canUse` and `canContinueToUse` differ only in the target test: `canUse` additionally requires no attack target and no controlling passenger. `tick`, when the raider has an active raid: `recruitmentTick` is compared with `tickCount` (the raider's own age): when `tickCount > recruitmentTick`, `recruitmentTick = tickCount + 20` and `recruitNearby(raid)` runs. `recruitNearby`: only when the raid is active; collect every `Raider` in the box of the raider inflated by 16 on every axis that has **no** active raid and for which `Raids.canJoinRaid` is true (a set, so each once); each one is added with `raid.joinRaid(level, raid.groupsSpawned, thatRaider, null, true)` (the final `true` read as "already existing entity"; the null is the position). Then, when the raider is not path finding, a position from `DefaultRandomPos.getPosTowards(raider, 15, 4, bottomCentre(raid.center), PI/2)`; when non-null, `moveTo(x, y, z, 1.0)`.

## 11. The declarative behaviour engine (`BehaviorBuilder`, `MemoryCondition`, `MemoryAccessor`)

Closes the `MemoryAccessor` and `MemoryCondition` part of x2 Open question 2. Classes read: `MemoryCondition` and its `Absent`, `Present`, `Registered` records, `MemoryAccessor`, `BehaviorBuilder` (and its `Instance`, `PureMemory`, `$1`), `OneShot`, `Brain` (memory methods).

### 11.1 Conditions

A behaviour built with `BehaviorBuilder.create` lists its inputs as conditions on memory types, evaluated **left to right, short-circuit**; the first failing condition makes the whole trigger fail. Each condition has a status name used for the behaviour's required-memory entry (`getRequiredMemories`):

| Condition | Required status | Passes when | Accessor given to the body |
|---|---|---|---|
| `registered(m)` | `REGISTERED` | the mob's brain has memory type `m` registered (always, when it is) | read gives the optional value (may be empty); can set, erase, set with expiry |
| `present(m)` | `VALUE_PRESENT` | `m` registered **and** holds a value | read gives the value |
| `absent(m)` | `VALUE_ABSENT` | `m` registered **and** holds no value | no readable value |

A memory type that is **not registered** in the brain fails every condition (the internal lookup `Brain.getMemoryInternal` returns null for an unregistered type, and that null fails the condition). `Brain.checkMemory(type, status)` (used for the plain `Behavior` entry conditions) agrees: false when unregistered; `REGISTERED` always true otherwise; `VALUE_PRESENT` and `VALUE_ABSENT` test whether the slot has a value.

`OneShot` behaviours: `tryStart` runs the trigger; when it returns true the status becomes RUNNING and `tryStart` returns true; `tickOrStop` immediately calls `doStop`, which sets the status back to STOPPED. So a one-shot never survives into the next tick. The trigger returns true for "ran" (even if it chose to do nothing visible), false for "did not apply"; the brain's behaviour runner (18, the brain tick description) uses that boolean to continue or to move on to the next behaviour of the activity.

### 11.2 Memory writes (`Brain`)

| Operation | Rule |
|---|---|
| `setMemory(type, value)` | a no-op when `type` is not registered; when `value` is null **or an empty collection** the slot is cleared; otherwise the slot holds `value` with no expiry |
| `setMemory(type, Optional)` | the optional's value or null, then the rule above |
| `setMemoryWithExpiry(type, value, ttl)` | same null/empty/unregistered rules; otherwise the value with a time to live of `ttl` ticks |
| `eraseMemory(type)` | clears the slot if the type is registered |
| `getMemory(type)` | an optional of the slot's value (the slot is required to exist) |
| `isMemoryValue(type, v)` | slot exists and its value equals `v` (`Objects.equals`) |
| accessor `set`, `setOrErase`, `setWithExpiry`, `erase` | forward to the four operations above (`set` wraps in an optional) |

Consequence for implementers: writing an empty list to a list memory erases it, and writing to an unregistered memory silently does nothing.

## 12. Sensor base class, `NearestItemSensor`, `PlayerSensor`

Classes read: `Sensor`, `NearestItemSensor`, `PlayerSensor`. Closes the sensor part of x2 Open question 2; 18 (the sensor list) gives the outline, this adds the exact objects.

### 12.1 `Sensor` base

- Fields: `scanRate` (constructor argument; the no-argument constructor uses **20**), `timeToTick`. `randomlyDelayStart(random)` sets `timeToTick = random.nextInt(scanRate)` (called when the brain installs the sensor).
- `tick`: `timeToTick -= 1`; when the new value is not above 0, `timeToTick = scanRate`, then `updateTargetingConditionRanges(mob)` and `doTick`. So a sensor with rate 20 scans on every 20th tick after its random start offset.
- `updateTargetingConditionRanges`: sets the `range` of all six shared conditions below to the mob's `follow_range` attribute value (the shared objects are mutated at every scan; they carry the last scanning mob's range).
- Default range before any scan is 16.0.

| Shared condition (static) | Kind | Range | Line of sight | Invisibility test |
|---|---|---|---|---|
| `TARGET_CONDITIONS` | non-combat | 16 | yes | yes |
| `TARGET_CONDITIONS_IGNORE_INVISIBILITY_TESTING` | non-combat | 16 | yes | no |
| `ATTACK_TARGET_CONDITIONS` | combat | 16 | yes | yes |
| `ATTACK_TARGET_CONDITIONS_IGNORE_INVISIBILITY_TESTING` | combat | 16 | yes | no |
| `ATTACK_TARGET_CONDITIONS_IGNORE_LINE_OF_SIGHT` | combat | 16 | no | yes |
| `ATTACK_TARGET_CONDITIONS_IGNORE_INVISIBILITY_AND_LINE_OF_SIGHT` | combat | 16 | no | no |

Static tests (all `TargetingConditions.test(level, mob, target)`, rules in 18, the targeting-conditions text): `isEntityTargetable` uses the `..._IGNORE_INVISIBILITY_TESTING` non-combat object when the mob's `attack_target` memory **equals** the candidate (already fighting it), else `TARGET_CONDITIONS`; `isEntityAttackable` the same with the combat pair (`ATTACK_TARGET_CONDITIONS_IGNORE_INVISIBILITY_TESTING` when it is the current target, else `ATTACK_TARGET_CONDITIONS`); `isEntityAttackableIgnoringLineOfSight` the same with the two line-of-sight-free objects. `rememberPositives(n, predicate)` builds a predicate with a counter starting at 0: when the inner predicate is true the counter is set to `n` and the result is true; when false the counter is decremented and the result is true while the **decremented** value is still `>= 0`, else false. `wasEntityAttackableLastNTicks(n, mob)` is `rememberPositives(n, isEntityAttackable(level, mob, x))`; the counter is per built predicate (one per mob and use). Worked example: `n = 3`; a target is attackable on one call (true, counter 3), then not attackable on four consecutive calls: the results are true (counter 2), true (1), true (0), false (-1).

### 12.2 `NearestItemSensor` (required memory `nearest_visible_wanted_item`)

Scan every 20 ticks (default rate). Item entities in the box of the mob's bounding box inflated by **(32, 16, 32)** (no entity predicate) are sorted by squared distance to the mob, ascending (stable, so ties keep the entity scan order); the first item that passes all three filters, in this order, becomes the memory value: (1) `mob.wantsToPickUp(level, itemStack)`; (2) the item is within **32** blocks of the mob (`closerThan`, 3D distance); (3) `mob.hasLineOfSight(item)`. The memory is set from the resulting optional, so no candidate **erases** the memory. (The brain-memory names `nearest_items` of the scope list correspond to the registry sensor id `nearest_items`; the memory it fills in this version is `nearest_visible_wanted_item`.)

### 12.3 `PlayerSensor` (memories `nearest_players`, `nearest_visible_player`, `nearest_visible_attackable_player`, `nearest_visible_attackable_players`)

Scan every 20 ticks. `getFollowDistance(mob)` = the mob's `follow_range` attribute value. Steps:

1. Take `level.players()`, drop spectators (`EntitySelector.NO_SPECTATORS`), keep those within the follow distance of the mob (`closerThan`), sort by squared distance to the mob ascending, and store the list in `nearest_players` (a list value; an empty list is cleared by the write rule of 11.2).
2. `nearest_visible_player` = the first player of that list that passes `isEntityTargetable(level, mob, player)`; none gives null (erase).
3. `nearest_visible_attackable_players` = the sublist of players passing `isEntityAttackable`; `nearest_visible_attackable_player` = its first element or null.

Both visible lists keep the distance order of step 1. The line-of-sight and invisibility rules are inside the conditions of 12.1.

## 13. Village-bound strolls and look-and-interact (bodies behind the 18 behaviour table)

Classes read: `StrollAroundPoi`, `VillageBoundRandomStroll`, `InsideBrownianWalk`, `SetLookAndInteract`. A walk target is `WalkTarget(position, speed, closeEnoughDistance)`.

| Behaviour | Inputs | Conditions | Effect |
|---|---|---|---|
| `StrollAroundPoi(memory, speed, maxDistance)` | `walk_target` registered; the given global-position memory present; a private timer starting at 0 | the stored position is in the mob's dimension **and** within `maxDistance` of the mob (`closerToCenterThan`); otherwise returns false (did not apply) | when the game time is not above the timer: returns true and does nothing; else a position from `LandRandomPos.getPos(mob, 8, 6)` (null erases `walk_target`) becomes the walk target with speed `speed` and **close-enough 1**, and the timer is set to `gameTime + 180`. Constants: 180 (minimum gap), 8, 6. |
| `VillageBoundRandomStroll(speed [, xz = 10, y = 7])` | `walk_target` absent | none | if the mob's block is in a village (`isVillage`): `LandRandomPos.getPos(mob, xz, y)`; else: `closest = BehaviorUtils.findSectionClosestToVillage(level, sectionOf(mob block), 2)`; when `closest` is not the mob's own section, `DefaultRandomPos.getPosTowards(mob, xz, y, bottomCentre(closest.center), PI/2)`, otherwise `LandRandomPos.getPos(mob, xz, y)`. The result (null erases) becomes the walk target with the speed and **close-enough 0**. Always returns true. |
| `InsideBrownianWalk(speed)` | `walk_target` absent | returns false (no action) when the mob's block can see the sky | take the 27 block positions of the cube `block +- 1`, shuffle them (the artifact calls the JDK's default `Collections.shuffle`, a private unseeded generator, **not** the mob's random source; any uniform shuffle is equivalent), and take the first that satisfies, all three: the position cannot see the sky; `loadedAndEntityCanStandOn(position, mob)`; and `level.noCollision(mob)` (note: the compiled test takes the mob only, so it does **not** depend on the candidate position and is the same for all candidates: it asks whether the mob's current box is collision free). It becomes the walk target (speed, close-enough 0). Returns true. |
| `SetLookAndInteract(type, distance)` | `look_target` registered, `interaction_target` absent, `nearest_visible_living_entities` present | the closest visible entity that is of `type` and within `distance` (squared distance `<= distance * distance`, the square taken as an int) exists; otherwise false | sets `interaction_target` to that entity and `look_target` to an entity tracker on it with `trackEyeHeight` true; returns true |

Worked example (`StrollAroundPoi`, `maxDistance 16`, speed 0.5): game time 1000, timer 0, the mob 10 blocks from its stored position in the same dimension: it applies; a position is picked and the timer becomes 1180. At game time 1100 it returns true and does nothing. At 1181 it picks again.

## 14. Reputation events: who raises them (closes the `golem_killed` question)

Classes read: `ReputationEventType`, `ReputationEventHandler`, `Villager`, `ZombieVillager`, `ServerLevel.onReputationEvent`. A byte search over every class of the jar's `net/minecraft` tree for the type's class name finds exactly these classes: `ReputationEventType`, `ReputationEventType$1`, `ReputationEventHandler`, `Villager`, `ZombieVillager` and `ServerLevel`. The conclusion holds: `GOLEM_KILLED` is referenced only inside `ReputationEventType` itself, so the table is the complete set of producers.

| Event (registry-style name) | Raised by | Receiver and gossip applied by `Villager.onReputationEventFrom` |
|---|---|---|
| `zombie_villager_cured` | `ZombieVillager` conversion finishing (with the curing player; the advancement trigger runs just before) | `major_positive` +20 and `minor_positive` +25 for the player's UUID |
| `trade` | a completed trade (the villager's trade-notification path, to the trading player) | `trading` +2 |
| `villager_hurt` | `Villager.setLastHurtByMob(attacker)` on a server level with a non-null attacker: the villager is told about the attacker | `minor_negative` +25 |
| `villager_killed` | `Villager.die` when the damage source has an entity: `tellWitnessesThatIWasMurdered(killer)` takes the villager's `nearest_visible_living_entities` memory (nothing happens when absent) and tells every visible entity that implements `ReputationEventHandler` (only `Villager` does) | `major_negative` +25 |
| `golem_killed` | **no producer exists in the artifact**: no class other than those listed above refers to the field, and `onReputationEventFrom` has no branch for it | none |

After the gossip branch, `onReputationEventFrom` also checks: when the villager's current trading player has the same UUID as the event's entity, it calls `updateSpecialPrices(player)` on that player (so a price change from fresh gossip applies at once to an open trade screen). The `GossipContainer.add` arithmetic (caps, decay, transfer) is in 44-3 (gossip container) and was not re-read.

`ServerLevel.onReputationEvent(type, entity, handler)` has no logic of its own: it calls `handler.onReputationEventFrom(type, entity)`. (The iron golem's villager-protection goals read reputation through `getPlayerReputation`, 44-3 (iron golem); nothing writes `golem_killed`.)

## 15. Dispositions of class names that the scope lists as unmentioned

| Class | Disposition |
|---|---|
| `BreezeAi`, `BreezeUtil`, `Breeze$1`, `LongJump`, `Shoot`, `Slide`, `BreezeAi$SlideToTargetSink` | specified under descriptive names in 20 (breeze) (activities CORE, IDLE, FIGHT, the shoot, long jump and slide behaviours) and 44-5 (breeze sensor) (the sensor); the one gap there, `ShootWhenStuck`, is 15.1 |
| `CreakingAi`, `Creaking$*` controls | 20 (creaking) (activities IDLE, FIGHT, freeze-when-watched, heart binding) and 44-5 (creaking heart) (heart block entity) |
| `TadpoleAi`, `Tadpole` | 44-7 (tadpole) (activities) and section 7.3 of this document (growth) |
| `AbstractCow` | 19 (cow and mooshroom entries) (goals, food, attributes, milking); the small residuals are 15.2 |
| Dragon phases: `DragonHoldingPatternPhase`, `DragonStrafePlayerPhase`, `DragonLandingApproachPhase`, `DragonLandingPhase`, `DragonTakeoffPhase`, `DragonSittingScanningPhase`, `DragonSittingAttackingPhase`, `DragonSittingFlamingPhase`, `DragonChargePlayerPhase`, `DragonHoverPhase`, `DragonDeathPhase`, `AbstractDragonSittingPhase`, `EnderDragonPhaseManager` | 21 (ender dragon, phase table 6.4) (table of the eleven phase ids and each phase's behaviour, under the names "Landing approach", "Landing", "Takeoff", "Sitting scanning", "Sitting attacking", "Sitting flaming", "Charging player", "Hovering", "Dying") and 44-9 section 1 (crystal hooks, strafe path); `DragonFlightHistory` in 34-7 |
| `ClientSideMerchant` | 15.3 |
| `InventoryCarrier`, `ItemSupplier`, `Npc`, `VillagerDataHolder`, `ReputationEventHandler` | 15.4 |
| `CopperGolemOxidationLevel` | section 8.1 of this document |

### 15.1 `ShootWhenStuck` (breeze FIGHT behaviour 3)

Required memories: `attack_target` present; `breeze_jump_inhaling`, `breeze_jump_target`, `walk_target` and `breeze_shoot` all absent. It starts only when the breeze is a passenger, **or** is in water, **or** has the Levitation effect. `canStillUse` is false, so it ends right after its start. `start`: set `breeze_shoot` with an expiry of **60** ticks (value: the unit marker). The shoot behaviour of 20 (breeze) then runs because its `breeze_shoot` memory is present (the stuck breeze shoots without needing to walk).

### 15.2 `AbstractCow` residuals

Goal priorities and constants are as in 19 (cow and mooshroom entries) (0 float; 1 panic 2.0; 2 breed 1.0; 3 tempt 1.25 with item tag `cow_food` and `scareOff` false; 4 follow parent 1.25; 5 water-avoiding stroll 1.0; 6 look at player 6.0; 7 random look around), re-read here. Attributes: `max_health` 10.0, `movement_speed` 0.20000000298023224 on top of the animal base. Food: tag `cow_food`. Sound volume 0.4; step sound at volume 0.15 and pitch 1.0 taken from the cow's sound variant (`CowSoundVariant`: ambient, hurt, death, step, default set `CLASSIC`). Baby dimensions: the adult `cow` dimensions scaled by 0.5 with eye height 0.665. Milking: an empty `bucket` in hand on a non-baby cow: the `cow_milk` sound at volume 1 pitch 1 to the player, the bucket stack is replaced by one milk bucket (`ItemUtils.createFilledResult`, so a creative player keeps the empty bucket and a stack of buckets loses one), result SUCCESS; otherwise the animal default interaction.

### 15.3 `ClientSideMerchant`

The merchant stand-in a client uses for the trading screen. It holds the viewing player, an offers list (initially empty), and an XP integer; `setTradingPlayer` does nothing; `overrideOffers` and `overrideXp` replace the stored values; `notifyTrade(offer)` calls `offer.increaseUses`; `isClientSide` is the player level's client flag; `stillValid(p)` is true only for the stored player; `showProgressBar` is true; the notify-trade sound is `villager_yes`; `notifyTradeUpdated` does nothing. Server-side trading is `AbstractVillager` (19 (villager entries)).

### 15.4 Marker and small interfaces

- `Npc`: a marker interface with no members (villager and wandering trader implement it; it exists only for type tests).
- `ItemSupplier`: one method returning the item stack the entity shows (implemented by the item-showing projectiles: eye of ender, firework rocket, wind charges, fireballs and the throwable-item projectile base).
- `VillagerDataHolder`: `getVillagerData`, `setVillagerData`, `getVillagerDataFinalized`, `setVillagerDataFinalized`, and a default `finalizeVillagerType(level, pos)` (villager and zombie villager implement it; the type chosen from the biome is in 19 (villager entries)).
- `InventoryCarrier`: NBT key `Inventory` (a list of item stacks, via the simple container's item-list store and load); the static `pickUpItem(level, mob, carrier, itemEntity)`: when `mob.wantsToPickUp(level, stack)`: if the carrier's inventory cannot add the stack, stop; else `mob.onItemPickup(entity)`, add the stack to the inventory (a remainder may come back), `mob.take(entity, countBefore - remainderCount)`, and when the remainder is empty discard the item entity, else set the entity's stack count to the remainder count.

## 16. Validation

What was verified and how:
- Every constant in sections 2 to 8 was read from the class named beside it with `javap -c -p -constants` in this round (`WardenSpawnTracker`, `SculkShriekerBlockEntity` and `$VibrationUser`, `SculkShriekerBlock`, `ServerPlayer`, `SpawnUtil` and `$Strategy`, `DispenserBlock`, `DispenserBlockEntity`, `DefaultDispenseItemBehavior`, `OptionalDispenseItemBehavior`, `DispenseItemBehavior` and its 13 anonymous classes, `ProjectileDispenseBehavior`, `BoatDispenseItemBehavior`, `MinecartDispenseItemBehavior`, `EquipmentDispenseItemBehavior`, `ShulkerBoxDispenseBehavior`, `ShearsDispenseItemBehavior`, `FlintAndSteelDispenseItemBehavior`, `SulfurCubeBlockDispenseItemBehavior`, `ProjectileItem` and its `DispenseConfig` and builder, the item classes `ExperienceBottleItem`, `FireChargeItem`, `FireworkRocketItem`, `ThrowablePotionItem`, `WindChargeItem`, `ArrowItem`, `SpectralArrowItem`, `EggItem`, `SnowballItem`, `ContainerEntity`, `Snowball`, `ThrownEgg`, `LlamaSpit`, `TryLaySpawnOnFluidNearLand`, `CopyMemoryWithExpiry`, `Tadpole`, `AgeableMob.getSpeedUpSecondsWhenFeeding`, `CopperGolemOxidationLevels`, `Markings`).
- Binding-count cross-check: `DispenseItemBehavior.bootStrap` contains **13** projectile registrations and **53** direct `registerBehavior` sites, plus **1** `registerBehavior` site in the dyed-shulker-box lambda (54 `registerBehavior` sites; counted again in this round from the bytecode: 53 in the method body, 54 in the whole class); the table in section 4 accounts for them as 1 (armor stand) + 1 (chest) + 22 (boats and chest boats) + 10 (filled buckets) + 1 (empty bucket) + 1 (flint and steel) + 1 (bone meal) + 1 (TNT) + 1 (skull) + 1 (pumpkin) + 1 (shulker box) + 1 (glass bottle) + 1 (glowstone) + 1 (shears) + 1 (brush) + 1 (honeycomb) + 1 (potion) + 6 (minecarts) = **53**, matching the 53 direct call sites (the undyed shulker box is among them); the 54th site is the lambda that registers one behaviour for each dyed colour (the count of 16 in section 4 is the number of colours, inferred from the 16 `*_shulker_box` item models, not counted from the colour collection).
- Only `DispenseItemBehavior` and `DispenserBlock` reference the registration methods (searched across all classes in the jar's `net/minecraft` tree), so the table is complete.
- The `deflection` closure of 6.4 was checked by listing the declared methods of `Entity`, `Breeze`, `AbstractArrow`, `WindCharge` and `Projectile`, and by searching every class under `world` for the string.
- Existing documents re-read against the bytecode (section 1): the random-position helpers of 18 section 4.2 and the ordered box scan of 44-1 section 3 agree.
- Sections 10 to 15 (a later pass of the same round): read with `javap -c -p -constants` from `SitWhenOrderedToGoal`, `OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`, `NonTameRandomTargetGoal`, `InteractGoal`, `LookAtTradingPlayerGoal`, `TradeWithPlayerGoal`, `UseItemGoal`, `DoorInteractGoal`, `MoveThroughVillageGoal`, `PathfindToRaidGoal`, `MemoryCondition` (and records), `MemoryAccessor`, `BehaviorBuilder` (with `$1`, `Instance$1` to `$3`, `PureMemory$1`), `OneShot`, `Brain`, `Sensor`, `NearestItemSensor`, `PlayerSensor`, `StrollAroundPoi`, `VillageBoundRandomStroll`, `InsideBrownianWalk`, `SetLookAndInteract`, `Villager`, `ZombieVillager`, `ServerLevel` (reputation method), `ReputationEventType`, `ShootWhenStuck`, `AbstractCow`, `ClientSideMerchant`, `Npc`, `InventoryCarrier`, `ItemSupplier`, `VillagerDataHolder`. Producer search for reputation events: every class file under `net/minecraft` was byte-searched for the type name; the six classes listed in section 14 match.
- Fixer pass (same round, re-read with `javap -c -p -constants`): `SpawnUtil$Strategy` (leaves test on the floor state), `AbstractHurtingProjectile` and `Projectile` (`assignDirectionalMovement`, `getMovementToShoot`, `shoot`), `MinecartDispenseItemBehavior` and `AbstractMinecart.createMinecart` (stack passed, null player), `FireworkRocketItem` (method handle and constants), `PrepareRamNearestTarget` and `$RamCandidate`, `PiglinAi` (`angerNearbyPiglins` and its two filters, `isIdle`), `SculkBlock.getRandomGrowthState`, `ServerLevel.tick` section order, and byte searches over every class of the `net/minecraft` tree for `ReputationEventType`, `cat_does_not_teleport_to` and `WardenSpawnTracker`. One reviewer finding was rejected because the artifact disagrees: the meaning of the boolean of `angerNearbyPiglins` (section 5.1).
- Worked examples to turn into tests: 10.2 (owner hit timestamps), 12.1 (`rememberPositives` with n = 3 gives true, true, true, false), 13 (`StrollAroundPoi` timer 1000, 1180, 1181).
- Where a lambda's receiver was hidden by compiler output (the filter order inside `InsideBrownianWalk`), the order is stated only where it changes the result; the filters are pure, so the order does not.

## Open questions

1. **(Closed by section 10 except the per-species hooks.)** Generic goals formerly without a body. `SitWhenOrderedToGoal`, `OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`, `NonTameRandomTargetGoal`, `MoveThroughVillageGoal`, `DoorInteractGoal`, `InteractGoal`, `UseItemGoal`, `TradeWithPlayerGoal`, `LookAtTradingPlayerGoal`, `PathfindToRaidGoal` appear in 18 and 19 to 21 only by name or by parameter list and were not read in this round. Also not re-read: per-mob goal internals of sheep, cow, pig, chicken, mooshroom, ocelot, horse family, camel, wolf, bee pollinate hover offset, allay `StayCloseToTarget`, `SnifferAi`, `FollowTemptation`, and the frog `RunOne` trigger predicates (44-4 Open questions 16 and 17, x1 Open question 1, minus the items closed in section 1).
2. **(Mostly closed by sections 1.2 and 11 to 13.)** Brain behaviours: `PrepareRamNearestTarget` selection is answered in 1.2; goat ram cooldown ranges are in 44-6 5.6 (600 to 6000, screamer 100 to 300). Still not read: the spear retreat arithmetic and the `CrossbowAttack` state machine (44-6 Open questions 5, 12), and the `RamCandidate` consumers beyond its three fields.
3. **(Closed.)** `AbstractThrownPotion`, `ThrownSplashPotion`, `FishingHook` and the other thrown items are specified in 44-8 section 10 (Open question 16 there lists them done); only the lingering cloud creation detail is as 44-8 and 17 section 3.15 give it. The earlier wording of this question cited 17 section 3.10 (the trident) in error.
4. **44-4 Open question 3**: consumer found (`Cat$CatRelaxOnOwnerGoal`, section 1); the body of `Cat.randomTeleport(x, y, z, flag, tag)` and the goal's trigger were not read.
5. **Warden tracker residuals.** Callers are closed (section 2.1: only the command, the player and the shrieker). Still not read: `Warden.applyDarknessAround` internals beyond 20 section 15, the level event 3007 client effect, and the site that passes the `can_summon` boolean into `SculkBlock.getRandomGrowthState` (section 2.3). The tie rule of step 4 in 2.2: the artifact picks the winner with a `Stream.max` over a `comparingInt` comparator on the level, and which of several equal levels wins depends on the JDK reduction rule, which is not part of the artifact; the "first in list order" wording of 2.2 is therefore **(inferred)**, not read. Because every candidate then receives the winner's three counters, only a tie between different `ticks_since_last_warning` or cooldown values is observable.
6. **(Closed.)** Firework rocket dispense position: the position function is a direct method handle to `getEntityJustOutsideOfBlockPos` (4.1); config uncertainty 1.0, power 0.5, event 1004 read. The shoot-versus-item-vector question is closed in the shoot-path note after 4.1.
7. **Chest dispense onto a horse.** Closed: see 4.3 (full stack passed, slot access rules, dispenser shrinks by 1). No residual.
8. **Flint and steel.** Closed: see 4.8. Residual: the part of `SulfurCube.primeTime` after its four early-false conditions was not read (20 section 18 and Open question 9).
9. **Sulfur cube.** `SulfurCube.equipItem`, `primeTime(boolean)` and the swallow rules are not read here (20 section 18.2 holds the attributes only).
10. **(Closed.)** `PiglinAi.angerNearbyPiglins`: section 5.1. Residual: `BehaviorUtils.canSee` and `setAngerTargetToNearestTargetablePlayerIfFound` bodies were not re-read here.
11. **Spawn reasons.** The x1 Open question 1 line for 18 Open questions 11 and 12 is stale: 11 is answered by 44-1 section 4.6, 12 by 44-8 and by section 6 here. The README and x1 should be updated to say so (the reader may not edit them in this round).
12. **Variants.** Cat, cow, pig, chicken, frog, wolf and zombie nautilus variants and their sound variants, painting variants, villager types and professions are data (rule R7) and are not tabulated; the engines choosing a variant at spawn (biome-tag and condition rules) were not re-read. The sound registry paths for the copper golem sounds (8.1) were inferred from the field names.
13. **Not resolvable by static reading** (as in the round statement): the entity-id check against a captured registry sync (19 Open question 31, 20 Open question 25); `46-registry-ids.md` section 11 verifies ids from registration order.
14. **Minecart and boat interpolation** (`NewMinecartBehavior` `lerpSteps`, `adjustToRails`, the boat handlers), the dragon and shulker level events 2006 and 2016, happy ghast leash pull and rider movement, mannequin profile resolution and display text `LineSplitter`: not read in this round.
15. **Scope not covered by this document.** Item-by-item pointers are in section 1.1 (villager, raid and POI behaviours: 44-3; warden brain: 44-5; `LongJump`: 44-4; nautilus: 44-7; piglin `ChargeAttack`, `RamTarget`, spear: 44-6; armor stand, item frame, painting, display, interaction, marker and area effect cloud: 44-9; boats and minecarts: 44-8 sections 3 and 4 and 21 section 8.8; happy ghast: 21 section 8.11; thrown potions: 44-8 section 10.2). Of the original list only the `CrossbowAttack` state machine remains without any section, with the items of Open question 22.
16. **`TamableAnimal.wantsToAttack`** and the per-species overrides (10.2) were not re-read; only their call site was.
17. **(Closed.)** `DoorBlock.isWoodenDoor` (10.4, 10.5) was read: the block must be a `DoorBlock` whose block set type reports `canOpenByHand` true. So the name "wooden" means "openable by hand", not "not iron" as an earlier draft inferred; which set types are openable by hand is block-set-type data (not tabulated here). The `BlockSetType.canOpenByHand` flag values were not enumerated.
18. **`LandRandomPos.getPos` with a scorer** (10.5 step 4): the scorer form of the helper (how the score replaces the default comparison) was not re-read; 18 describes the unscored form.
19. **`BehaviorUtils.findSectionClosestToVillage`** (13) was not expanded here; 44-3 gives the section-distance search it uses.
20. **`OpenDoorGoal` and `BreakDoorGoal`** bodies were not re-read against the base class of 10.4.
21. **(Closed.)** `getLastDamageSource(int)` argument unit (10.2): read, it is a tick age compared with game time minus the last-damage stamp.
22. **Still not read in this document** (not enumerated by the earlier rounds either): the `CrossbowAttack` state machine, the spear behaviours, `FoxMoveControl`, panda roll and sneeze, bee attack and hive timers, turtle position helpers, `StayCloseToTarget`, `SkeletonTrapGoal`, `RunAroundLikeCrazyGoal`, `NewMinecartBehavior` interpolation, `EvokerFangs` and `SmallFireball` internals, `findNearestMapStructure`, bastion template pools, `SulfurCube.primeTime`, per-block entity effects, `StatFormatter`, the atan2 and inverse-square-root tables, the `highestAnger` tie (not answerable statically). They need further rounds.
23. **README index** and the stale pointers in x1 Open question 1 and 44-5 section 11 still need an editor pass (the reader may not edit them).
24. **Player tick internals and warden roar.** Read: `ServerLevel.tick` runs `blockTicks`, `fluidTicks`, raids, the chunk source and block events before its `entities` section; the player's own tick is in the entity section (not traced further), so the shrieker's 90-tick block tick precedes player ticks in a game tick. Not read: the order inside `ServerPlayer.tick` of the tracker `tick()` and the movement that steps on a shrieker, so the 200 versus 201 timing of shriek 2 (and 402, 603) in 2.5 stays **(inferred)**. The warden roar behaviour was not located by heading in 20 or 44-5 (names only) and was not searched for further.
