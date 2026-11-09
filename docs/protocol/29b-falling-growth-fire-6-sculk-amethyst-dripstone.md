# 29b. Falling blocks, growth, fire and similar block behaviours, part 6: sculk family (live behaviour), amethyst, speleothems (pointed dripstone, sulfur spike)

| | |
|---|---|
| Covers | The ticking and state-changing behaviour of the sculk family as a consolidated map onto the documents that already specify the engine (`SculkSpreader`, `ChargeCursor`, `SculkBehaviour`, `SculkBlock`, `SculkVeinBlock`, the catalyst bloom, the sensor, calibrated sensor and shrieker phases), with the facts re-read this round and the gaps closed; `AmethystBlock` (projectile chime), `AmethystClusterBlock` (the cluster and the three buds: survival, shape update, placement, waterlogging), `BuddingAmethystBlock` (random tick growth and the four-stage chain); the whole `SpeleothemBlock` rule set shared by `pointed_dripstone` and `sulfur_spike` (properties, survival, shape update and thickness states, placement, tip merging, stalactite and stalagmite growth, falling, projectile breaking), and the `PointedDripstoneBlock` extras (drip fluid, fluid transfer into cauldrons and mud to clay, stalagmite fall damage, the cauldron side of the hand-off) the sulfur spike differences and the block-level rules of `PotentSulfurBlock` (9.3). The hand-off from a falling stalactite to the `FallingBlockEntity` of `29b-falling-growth-fire-1-model-gravity-bonemeal.md` section 4 is specified here. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas) and of the data files `data/minecraft/tags/block/speleothems.json`, `sculk_replaceable_world_gen.json`, `vibration_resonators.json`, `sulfur_spike_replaceable_blocks.json` and `data/minecraft/tags/entity_type/impact_projectiles.json`, with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 6 |
| Data versus code | Tags (`speleothems`, `vibration_resonators`, `sculk_replaceable`, `sculk_replaceable_world_gen`, `sculk_growth_inhibitors`, `impact_projectiles`), loot tables and the environment attribute values are DATA, read from the extracted packs (22, 23, 26). This document specifies the engines and the code-defined rules: constants, formulas, orderings and random draws. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. Block names are registry names (24 parts 1 to 8). The record model, the trigger kinds (RT, ST, PL, NU, SU, EV, ET), the probability notation (`1/N`, `P(p)`) and the flag vocabulary are those of `29b-falling-growth-fire-1-model-gravity-bonemeal.md` section 2 and are not repeated.

## 0. Reader's map

| Question | Section |
|---|---|
| Which document specifies which sculk behaviour; what this round re-read | 1 |
| Sculk: the kill-to-spread life cycle, checks of the existing rules, residual facts | 2 |
| Amethyst block, cluster and buds, budding amethyst | 3 |
| The shared speleothem model: state, helpers, survival, shape update, thickness, placement | 4 |
| Speleothem growth (stalactite, stalagmite, merging) | 5 |
| Falling stalactites and the hand-off to the falling block entity; projectile break | 6 |
| Pointed dripstone: drip fluid, cauldron and clay transfer, stalagmite damage | 7 |
| The cauldron side, level events and sounds | 8 |
| Sulfur spike differences, behaviour rows, potent sulfur block | 9 |
| Worked examples | 10 |
| Validation | 11 |
| Open questions | 12 |

## 1. Scope and where each behaviour is specified

| Behaviour | Specified in | This round |
|---|---|---|
| Vibration system (frequencies, listeners, selector, ticker, occlusion) | `31-block-entities-8-sculk-and-remaining-types.md` section 3 | not repeated |
| Sculk sensor phases, power, active and cooldown ticks, resonance | 31-8 sections 4.1 to 4.4 | constants re-read (2.2) |
| Calibrated sculk sensor | 31-8 section 5 | constants re-read (2.2) |
| Sculk shrieker: shriek, warning level, warden summon, block tick (90 ticks) | `44-residual-mob-questions-x2-continuation.md` section 2; block-entity side 31-8 section 6 | not repeated |
| Sculk catalyst: listener, `addCursors`, bloom, pulse tick | 31-8 sections 7.1 to 7.4 | re-read (2.2) |
| Live `SculkSpreader`: parameters, cursor merge pass, level events, sounds | 31-8 section 7.3 | re-read (2.2) |
| `ChargeCursor.update`, `getValidMovementPos`, `SculkBlock`, `SculkVeinBlock`, `MultifaceSpreader` | `35-worldgen-features-6-underground.md` sections 8.3 to 8.6 | re-read (2.2) |
| Geode and speleothem world generation (`growSpeleothem`, `buildBaseToTipColumn`) | 35-6 sections 4 to 7 | cross-reference only |
| Falling block entity (spawn, tick, landing, drops, damage) | 29b part 1 section 4 | the stalactite use is section 6 here |
| `PotentSulfurBlock` (geyser block entity block) | block-level rules 9.3 here; ticker constants partly read, remainder open (Open question 1) | new this round |
| Block registry rows (ids, shapes, light, sounds, push reaction) of these blocks | `24-block-registry-8-blackstone-copper-deepslate-modern.md` (amethyst rows 777 to 782, dripstone rows 847 to 849) | not repeated |
| Fluid rules (waterlogging, fluid tick delay 5, `isFull`) | `29a-fluids.md` | cited |
| Other scope items of the round (coral, turtle eggs, frogspawn, honey, candle, TNT, copper, snow and ice, cauldron filling from precipitation) | the sibling parts `29b-falling-growth-fire-1` to `-5` and `-7` (for example `29b-falling-growth-fire-7-*` section 8 and `24-block-registry-4-stems-glass-skulls.md` for the cauldron precipitation chances 0.05 and 0.1); not this part | not repeated. The cauldron material in section 8 here is ONLY the stalactite-drip side (`receiveStalactiteDrip`), not the whole cauldron behaviour |
| Client side drip particle and `animateTick` | `42-particles-3-fluid-drip-water.md` (section on `PointedDripstoneBlock`) | server side `getFluidAboveStalactite` is authoritative here (7.1) |
| Damage amounts of `stalagmite` and `falling_stalactite` | `17-tools-weapons-and-combat.md` (fall formula, damage tags) | the inputs are in 6.3 and 7.5 |
| Schedule ticks, shape updates, `setBlock` flags | `29-block-updates-and-placement.md` sections 3 and 4 | cited |
| `Block.pushEntitiesUp` | `29b-falling-growth-fire-2-crops-and-stems.md` section 9.5 | cited (7.3) |

The proposed scope of this part in `29b-falling-growth-fire-1-...` section 1.2 (dripleaf, hanging moss, glow lichen, firefly bush) is superseded by the round's scope given in the header; those blocks are specified in `29b-falling-growth-fire-4-growing-plants.md` (big and small dripleaf and the dripleaf stem in its section 12, `hanging_roots` in 13.1, `pale_hanging_moss` in 13.3, the firefly bush in 10.7, glow lichen via 24 part 4 and 35 part 4). The potent sulfur block is treated in 9.3.

## 2. Sculk family: live behaviour

### 2.1 The life cycle in one table

| Step | What happens | Where specified |
|---|---|---|
| 1 | A living entity dies; the game event `entity_die` is posted at its position before its loot and experience drop | 31-8 section 7.2 (read in `LivingEntity.die`) |
| 2 | A catalyst within 8 blocks (by distance, after immediate listeners) takes the event; if the entity's experience was not yet consumed it adds cursors of total charge `reward` at the block containing (position + 0.5 up), marks experience consumed, and blooms | 31-8 sections 7.2, 7.4 |
| 3 | Every tick the catalyst calls `updateCursors(level, catalystPos, random, true)` on its spreader | 31-8 section 7.2 |
| 4 | A cursor updates only on a server level, only when its block position is in an entity-ticking area, and only when `charge > 0`; the effective update rate is every second pass (delay 1) | 31-8 section 7.3 and 35-6 section 8.4 |
| 5 | On a vein with the spread flag set the cursor converts a neighbouring `sculk_replaceable` block to `sculk` (charge minus 1); on a sculk block it decays or grows a sensor or shrieker above it | 35-6 section 8.5 |
| 6 | A live-grown shrieker has `can_summon` false; sensors and shrikers then run their own ticking | 31-8 sections 4 and 6, 44-x2 section 2 |

The catalyst itself is a normal block entity ticker: on a server level it runs every tick (31-8 section 7.2). `bloom` is the block state property (`bloom` in 24; the class constant is named `PULSE`, read in `SculkCatalystBlock`): the block tick resets it to false when it is true and does nothing otherwise (read, `SculkCatalystBlock.tick`).

### 2.2 Facts re-read this round (all agree with the cited documents)

| Fact | Value read | Class |
|---|---|---|
| Cursor limit, max charge, max distance, shrieker rate | 32, 1000, 1024, 11 (`MAX_CURSORS`, `MAX_CHARGE`, `MAX_CURSOR_DISTANCE`, `SHRIEKER_PLACEMENT_RATE`) | `SculkSpreader` |
| Maximum growth-rate radius, maximum decay factor | 24 and 0.5 (used in the decay penalty) | `SculkSpreader` |
| Level spreader parameters (`createLevelSpreader`) | not world generation; growth cost 10; no-growth radius 4; charge decay rate 10; additional decay rate 5 (the constants `10, 4, 10, 5` appear in that order) | `SculkSpreader` |
| Level event 3006 data | `S` is the summed charge of all cursors standing on one position (the spreader groups cursors by position). The event is sent for a position only when `S > 0` and that position's facing set is non-null; data = `((int)(ln(1 + S) / d) + 1) << 6` plus the packed facings, where `d` is the float constant 2.3 widened to double (2.2999999523162842). Separately, a cursor whose charge is 0 or less sends event 3006 with data 0 at its own position (the discharge) | `SculkSpreader` |
| `SculkBlock` experience when broken | `ConstantInt(1)`, passed to `DropExperienceBlock` by the `SculkBlock` constructor | `SculkBlock` constructor |
| `SculkBlock.attemptUseCharge` draws and results (full table in 35-6 section 8.5) | 1. Charge not 0: draw `nextInt(chargeDecayRate)` (live value 10); a non-zero draw returns the charge unchanged (so roughly 1 of 10 effective updates proceeds). 2. When `near` (closer than `noGrowthRadius`) or the cell above is unusable: draw `nextInt(additionalDecayRate)` (live value 5); a non-zero draw returns the charge unchanged; a zero draw returns `charge - 1` when `near`, else `charge - getDecayPenalty`. 3. Otherwise (growth branch): draw `nextInt(growthSpawnCost)` (live 10); when it is below the charge, draw the growth state `nextInt(11)` and place the sensor or shrieker; the result is `max(0, charge - growthSpawnCost)` whether or not anything was placed | `SculkBlock` |
| Decay penalty | `max(1, (int)(charge x min(1, square(sqrt(distSqr) - r) / square(24 - r)) x 0.5))` (floats) | `SculkBlock.getDecayPenalty` |
| Growth cell test | the cell above is air or a water source block, and at most 2 blocks of tag `sculk_growth_inhibitors` in the box (-4, 0, -4) to (+4, +2, +4) around the cursor block | `SculkBlock.canPlaceGrowth` |
| Growth sound | the place sound of the placed state, at the cursor's block, blocks source, volume 1, pitch 1 | `SculkBlock.attemptUseCharge` |
| `canChangeBlockStateOnSpread` of `sculk` | false | `SculkBlock` |
| Sensor `ACTIVE_TICKS` 30, `COOLDOWN_TICKS` 10; calibrated `getActiveTicks()` 10 | read | `SculkSensorBlock`, `CalibratedSculkSensorBlock` |
| Shrieker `SHRIEKING_TICKS` 90; `WARNING_SOUND_RADIUS` 10; sensor, shrieker and catalyst experience | 90, 10; 5, 5, 5 (the values are right; they are built differently: the catalyst creates `ConstantInt.of(5)` in its constructor, stores it in its `xpRange` field and passes it to `tryDropExperience` from `spawnAfterBreak`; the sensor and the shrieker create `ConstantInt.of(5)` inside `spawnAfterBreak`; all only when experience drops are allowed) | `SculkShriekerBlockEntity`, `SculkSensorBlock`, `SculkShriekerBlock`, `SculkCatalystBlock` |
| Shrieker block tick | when `shrieking`: set it false with `setBlockAndUpdate`, then `tryRespond(level)` | `SculkShriekerBlock.tick` |
| Shrieker step | server level only: a player resolved by `tryGetPlayer` makes the block entity `tryShriek(level, player)` | `SculkShriekerBlock.stepOn` |

### 2.3 Residual facts that no sibling stated

1. `sculk_shrieker` is a waterloggable block entity block; its `getStateForPlacement` sets `waterlogged` from "the fluid at the clicked position is `Fluids.WATER`" and its `updateShape` schedules a water fluid tick (delay 5, 29a) when waterlogged, then defers to the base class (read). Its collision and occlusion shape is `column(16, 0, 8)` (a half-height slab, `TOP_Y` = 0.5 from the maximum of that shape), `useShapeForLightOcclusion` is true.
2. The shrieker's `can_summon` default is false; only world-generation placements through `SculkBlock.getRandomGrowthState` with the flag `isWorldGeneration` set it true (31-8 section 7.3 states the live consequence).
3. `SculkBlock` extends `DropExperienceBlock` and `SculkBehaviour`; every method of the behaviour interface that `SculkBlock` does not override takes the interface default listed in 35-6 section 8.5.
4. No random tick: none of the sculk blocks is random-ticking in 24; all their activity comes from the catalyst's per-tick spreader, block ticks scheduled by sensors, shrieker and catalyst, and the vibration tickers.

### 2.4 Worked example: a zombie kills a villager next to a catalyst

Inputs: catalyst at (0, 64, 0), sculk floor below it; a mob with an experience reward of 5 dies at (3.2, 64.0, 0.4). Steps: the event reaches the catalyst (distance 3.2 is within radius 8); `addCursors(BlockPos.containing(3.2, 64.5, 0.4) = (3, 64, 0), 5)` adds one cursor of charge 5 at `(3, 64, 0)`; the block sets `bloom` true and schedules a tick 8 ticks later; `sculk_soul` particles and the bloom sound play (31-8 section 7.4). On the following ticks the cursor updates every second tick (first update at once, `updateDelay` 0, then 1). Each effective update runs the default behaviour of 35-6 section 8.5 on vein and air cells and `SculkBlock.attemptUseCharge` on a sculk block. A cursor on a non-sculk, non-vein cell follows the default `decayDelay` rule of 35-6 section 8.5 and dies on its second effective update there. A cursor with charge 5 on an air cell that touches stone first plants veins in its own cell (same-space spreader, no random draw) and then moves to a neighbouring sculk or vein cell it can reach.

Once it stands on a sculk block, each effective update first passes the gate `nextInt(10) == 0` (chargeDecayRate 10): on any other draw (9 of 10) the charge is returned unchanged and nothing else happens, so a growth attempt occurs on about 1 of 10 effective updates, not on every update. When the gate passes: near the catalyst (inside the live no-growth radius 4) or under an unusable cell, a second gate `nextInt(5) == 0` (additionalDecayRate) applies, and only a zero draw lowers the charge (by 1 when near, else by the decay penalty); there is no growth. Elsewhere (the growth branch) the update draws `nextInt(10)` and places a sensor or shrieker only when the draw is below the charge (5 of 10 for charge 5), and whether or not it placed anything the charge becomes `max(0, 5 - 10) = 0`; the cursor then discharges (event 3006 data 0). So a charge-5 cursor ends at its first growth attempt, which is reached after the 1-in-10 gate passes (35-6 section 8.5, `SculkBlock` rule 4).

## 3. Amethyst

### 3.1 `AmethystBlock` (`amethyst_block`)

Class `AmethystBlock extends Block`. The only behaviour is `onProjectileHit(level, state, hit, projectile)`, which is inherited by `BuddingAmethystBlock` and `AmethystClusterBlock`:

| Item | Value |
|---|---|
| Trigger | EV: a projectile hit on the block (the shared call is `Projectile.onHitBlock`, which calls `state.onProjectileHit(level, state, hit, projectile)`) |
| Condition | server level only (nothing on a client) |
| Effect | `level.playSound(null, hitBlockPos, AMETHYST_BLOCK_CHIME, BLOCKS, 1.0, pitch)` with `pitch = 0.5 + nextFloat() x 1.2` (the level's random, one draw) |
| Sound key | `block.amethyst_block.chime` (46) |
| Notes | no block change; the arrow stays or is removed by its own entity rules; the sound is a normal world sound (positioned at the block centre, 29 section 7) |

The block's other roles are data or other classes' behaviour: the tag `vibration_resonators` contains only `amethyst_block` (read) and makes a sensor resonate (31-8 section 4.3, step 4); `amethyst_block` and `budding_amethyst` are full cubes. The `Blocks` registration of `amethyst_block` sets only map colour, strength 1.5, the amethyst sound type and requires-correct-tool-for-drops; it sets no push reaction, so its push reaction is the `Properties` default (`PUSH_PULL`, cited from 24-8; the `Properties` initialiser was not read in this class, Open question 11). `budding_amethyst` sets `POPPED` explicitly (24-8).

### 3.2 `AmethystClusterBlock` (`amethyst_cluster`, `large_amethyst_bud`, `medium_amethyst_bud`, `small_amethyst_bud`)

Class `AmethystClusterBlock extends AmethystBlock implements SimpleWaterloggedBlock`. Constructor arguments `(height, width)` (cluster 7 and 10, large bud 5 and 10, medium bud 4 and 10, small bud 3 and 8) and the block rows are in 24-8 section 4.2 and 5. Properties `waterlogged` (default false) and `facing` (default `up`).

| Method | Rule (read) |
|---|---|
| `canSurvive(state, level, pos)` | with `F` = the state's `facing`: the state at `pos + opposite(F)` is sturdy on its face toward `F` (`isFaceSturdy(level, support, F)`). The support is the block the crystal grows out of |
| `updateShape(...)` | 1. when `waterlogged`: schedule a water fluid tick (delay `FlowingFluid.getTickDelay`, 5). 2. when the notifying direction equals `opposite(facing)` and the state cannot survive: return **air** (the default state of `air`; a waterlogged crystal therefore leaves no water source behind from this call, a later fluid update may fill it, 29a). 3. otherwise the base-class result (the state unchanged) |
| `getStateForPlacement(ctx)` | `waterlogged` = the fluid at the clicked position is `Fluids.WATER`; `facing` = the clicked face. No survival test here (the generic placement code runs `canSurvive`, 29 section 9.6) |
| `getFluidState` | the water source (`getSource(false)`) when waterlogged, else the base result |
| `rotate`, `mirror` | `facing` through `Rotation.rotate` and `Mirror.getRotation` |
| `getShape` | the table of 24-8 section 5 (box rotated by `facing`) |
| Random tick / scheduled tick | none (the four blocks do not random-tick) |

### 3.3 `BuddingAmethystBlock` (`budding_amethyst`)

Class `BuddingAmethystBlock extends AmethystBlock`; the block is random-ticking (24-8: `randomTicks`). Constants read: `GROWTH_CHANCE` 5; `DIRECTIONS` is `Direction.values()`, which is the order down, up, north, south, west, east (read in `Direction`).

`randomTick(state, level, pos, random)` (RT):

1. Draw `nextInt(5)`. If it is not 0, stop (4 of 5 ticks do nothing).
2. Draw `nextInt(6)` and take `dir = DIRECTIONS[index]` (0 down, 1 up, 2 north, 3 south, 4 west, 5 east). `target = pos + dir`; `s` = the state at `target`.
3. Choose the new block `N` by the first rule that holds:

| Order | Condition on `s` | `N` |
|---|---|---|
| 1 | `canClusterGrowAtState(s)`: `s` is air, or `s` is the block `water` (the water block, not a waterlogged block) with a full fluid state (`FluidState.isFull`, 29a) | `small_amethyst_bud` |
| 2 | `s` is `small_amethyst_bud` and its `facing` equals `dir` | `medium_amethyst_bud` |
| 3 | `s` is `medium_amethyst_bud` and its `facing` equals `dir` | `large_amethyst_bud` |
| 4 | `s` is `large_amethyst_bud` and its `facing` equals `dir` | `amethyst_cluster` |
| 5 | anything else (including a finished cluster, a bud facing another way, any solid block, a waterlogged non-water block) | none: nothing is written |

4. When `N` exists: write its default state with `facing = dir` and `waterlogged` = the fluid state of `s` is `Fluids.WATER` (`FluidState.is(T)` comes from `TypedInstance` and compares the fluid object held by the state's type holder with the argument by reference, read; flowing water is a different object, so a falling-water cell that passed rule 1 gives `waterlogged` false), using `setBlockAndUpdate` (flags 3, 29 section 3.5). No survival test is made: the new crystal's support is the budding block itself, which is a full cube.

`canClusterGrowAtState(s)` is public and static. Its only caller outside this class among the jar's classes is `GeodeFeature.place` (searched; no other caller found). `FluidState.isFull` is `getAmount() == 8`, which also holds for falling flowing water, so rule 1's "full fluid state" is not limited to a source. The geode feature differs in one point: it sets `waterlogged` from `FluidState.isSource`, whereas the budding block uses `FluidState.is(Fluids.WATER)`; the two differ for a falling-water cell (see Open question 2 for the note to the 35-6 owner).

Rate. One face advances one stage with probability `1/5 x 1/6 = 1/30` per random tick of the budding block, independent of the stage. Starting from an empty face, the number of random ticks until a finished cluster is the sum of four independent geometric waits of mean 30, mean 120 ticks (inferred arithmetic). With `random_tick_speed` 3 a block receives `3/4096` random ticks per game tick on average (29b part 1 section 2.4), so about 163,840 game ticks (inferred arithmetic). A bud never moves to another face and a cluster never grows past `amethyst_cluster`.

Unwanted interaction rules read: when the budding block is pushed by a piston its push reaction `POPPED` breaks it (24-8); the budding block has no drop in the normal loot (data, 26), and the clusters drop through loot tables (data, 26).

## 4. The speleothem model (`SpeleothemBlock`, abstract)

`pointed_dripstone` is `PointedDripstoneBlock` and `sulfur_spike` is `SulfurSpikeBlock`, both subclasses of the abstract class `SpeleothemBlock extends Block implements SimpleWaterloggedBlock, Fallable`. The block tag `speleothems` is exactly these two blocks (read). Throughout, "speleothem" in a test means a state in tag `speleothems`, and "this block" means the exact block object of the class instance running the method (so two different speleothem blocks can sit next to each other and continue each other's thickness, but never merge tips, section 5.4).

### 4.1 State, constants and per-block constructor data

| Item | Value (read) |
|---|---|
| Properties | `vertical_direction` (the tip direction, `up` or `down`; the code calls it `TIP_DIRECTION`), `thickness` (`tip_merge`, `tip`, `frustum`, `middle`, `base`), `waterlogged`. Default state: `up`, `tip`, false (24-8) |
| `blockToGrowOn` (constructor state) | `pointed_dripstone`: the default state of `dripstone_block`; `sulfur_spike`: the default state of `sulfur` (read in the `Blocks` lambdas) |
| `DELAY_BEFORE_FALLING` | 2 (named constant; the same literals 2 and 1 appear in `updateShape`) |
| `MIN_TRIDENT_VELOCITY_TO_BREAK_SPELEOTHEM` | 0.6 |
| Falling damage constants | `STALACTITE_DAMAGE_PER_FALL_DISTANCE_AND_SIZE` 1.0, `STALACTITE_MAX_DAMAGE` 40, `MAX_STALACTITE_HEIGHT_FOR_DAMAGE_CALCULATION` 6 |
| Growth constants | `GROWTH_PROBABILITY_PER_RANDOM_TICK` 0.011377778 (float), `MAX_GROWTH_LENGTH` 7 (the base value of `getMaxGrowthLength`), `MAX_STALAGMITE_SEARCH_RANGE_WHEN_GROWING` 10, `AVERAGE_DAYS_PER_GROWTH` 5.0 (documentation constant; it only explains the probability: `1 / (5 x 24000 x 3 / 4096) = 0.0113778`, inferred arithmetic) |
| Registration properties (read in the `Blocks` registrations of both `pointed_dripstone` and `sulfur_spike`; rows in 24-8) | `randomTicks`, `dynamicShape`, offset type XZ, strength (1.5, 3.0), `noOcclusion` called twice, `forceSolidOn`, instrument `BASEDRUM`, a custom `isRedstoneConductor` predicate (the same shared predicate for both), and push reaction **`POPPED`** (a piston push breaks the block as an item drop, 29 section on piston reactions). Map colours differ (terracotta brown, colour yellow) and the sounds are their own sound types. Every state of both blocks is therefore random-ticking (used in 5.1) |
| Shapes and the XZ offset | 24-8 section 5.2 (`column(6,0,16)` for `tip_merge`, tip up `column(6,0,11)`, tip down `column(6,5,16)`, frustum 8, middle 10, base 12; each moved by `BlockState.getOffset`; `getMaxHorizontalOffset` is the minimum X of the base shape, 0.125) |
| `isCollisionShapeFullBlock` | false; `isPathfindable` false for every computation type |

### 4.2 Helper predicates (all read)

Notation: `T` is a tip direction and `O = opposite(T)`.

| Helper | Definition |
|---|---|
| `isSpeleothemWithDirection(s, d)` | `s` is in tag `speleothems` and its `vertical_direction` equals `d` |
| `isStalactite(s)` | `isSpeleothemWithDirection(s, DOWN)` (a stalactite hangs: its tip points down) |
| `isStalagmite(s)` | `isSpeleothemWithDirection(s, UP)` |
| `isTip(s, includeMerged)` | `s` is a speleothem and (`thickness == tip`, or `includeMerged` and `thickness == tip_merge`) |
| `isFreeHangingStalactite(s)` | `isStalactite(s)` and `thickness == tip` (exactly, not merged) and not `waterlogged` |
| `isUnmergedTipWithDirection(s, d)` (instance method) | `isTip(s, false)` and `s.vertical_direction == d` and `s` is this block |
| `isStalactiteStartPos(s, level, pos)` | `isStalactite(s)` and the block at `pos + up` is **not** the same block as `s` (that is, `s` is the topmost piece of a stalactite) |
| `isValidSpeleothemPlacement(level, pos, T)` | `base = pos + O`; true when the state at `base` is sturdy on its face toward `T` (`isFaceSturdy(level, base, T)`) **or** is a speleothem with direction `T` and is this block |
| `calculateTipDirection(level, pos, T)` | `T` when `isValidSpeleothemPlacement(level, pos, T)`; else `O` when `isValidSpeleothemPlacement(level, pos, O)`; else null (no placement) |
| `findBlockVertical(level, start, axisDirection, pass, stop, maxIter)` | `i = 1 .. maxIter - 1`: move one block along the axis (positive for up, negative for down); if `stop(state)` return that position; else if the position is outside the build height or `pass(pos, state)` is false return none; after the loop return none. Only `maxIter - 1` cells are examined |
| `findTip(s, level, pos, maxIter, includeMerged)` | `pos` itself when `isTip(s, includeMerged)`; else `findBlockVertical` from `pos` along the state's own tip direction, with `pass` = "the state is the same block as `s` and has the same tip direction" and `stop` = `isTip(state, includeMerged)` |
| `canDripThrough(level, pos, s)` (pointed dripstone) | true for air; false when `s.isSolidRender()` (a full opaque cube, 24 part 4 section on light dampening); false when `s` has a non-empty fluid; otherwise true exactly when the collision shape of `s` has an empty intersection with the column `Block.column(4, 0, 16)` (the central 4 x 4 prism through the cell, x and z from 6/16 to 10/16) |

### 4.3 Placement (`getStateForPlacement`)

Inputs: the placement context. Steps:

1. `D = opposite(getNearestLookingVerticalDirection())`: the vertical look direction is UP when the player's view pitch is below 0, else DOWN (read in `Direction.getFacingAxis`), so looking up gives tip DOWN and looking level or down gives tip UP.
2. `T = calculateTipDirection(level, clickedPos, D)`; when null the placement fails.
3. `merge = not isSecondaryUseActive()` (a sneaking player does not merge tips).
4. `thickness = calculateSpeleothemThickness(level, clickedPos, T, merge)` (4.5).
5. The result is the default state with `vertical_direction = T`, that thickness and `waterlogged` = the fluid at the clicked position is `Fluids.WATER`.

### 4.4 Survival and shape update

`canSurvive(state, level, pos)` is `isValidSpeleothemPlacement(level, pos, state.vertical_direction)`.

`updateShape(state, level, tickAccess, pos, dir, neighbourPos, neighbourState, random)` (SU), in order:

1. When `waterlogged`: schedule a water fluid tick (delay 5).
2. When `dir` is neither UP nor DOWN: return `state` (horizontal neighbours never change a speleothem).
3. Let `T` = the state's tip direction. When `T == DOWN` and a block tick of this block is already scheduled at `pos` (`hasScheduledTick`): return `state`.
4. When `dir == opposite(T)` (the change came from the side it rests on) and `canSurvive` is false: schedule a block tick of this block at `pos` after **2** ticks when `T == DOWN` or after **1** tick when `T == UP`, and return `state` unchanged. (The block is not removed here; the tick decides, section 6.)
5. Otherwise return `state` with `thickness` replaced by `calculateSpeleothemThickness(level, pos, T, thickness == tip_merge)`.

### 4.5 `calculateSpeleothemThickness(level, pos, T, merge)`

`n` = the state at `pos + T`; `O = opposite(T)`.

| Order | Condition | Result |
|---|---|---|
| 1 | `isSpeleothemWithDirection(n, O)` and `n` is this block (an opposing tip faces this one) | `tip_merge` when `merge` or `n.thickness == tip_merge`, else `tip` |
| 2 | not `isSpeleothemWithDirection(n, T)` (nothing continues beyond; this is the end) | `tip` |
| 3 | `n.thickness` is `tip` or `tip_merge` (a tip continues beyond) | `frustum` |
| 4 | the state at `pos + O` is not a speleothem with direction `T` | `base` |
| 5 | otherwise | `middle` |

So a column of height 4 growing downward, read from the support, is base, middle, frustum, tip; the order matches 35-6 section 5.3. The thickness of a piece is recomputed whenever a vertical neighbour changes (rule 5 above), and a changed state in turn updates its own vertical neighbours (29 section 3.2), so a whole column converges after one growth.

## 5. Growth

### 5.1 The random tick

`SpeleothemBlock.randomTick(state, level, pos, random)` (RT; every state of both blocks is random-ticking, 24-8):

1. Draw `nextFloat()` (always one draw). Continue only when it is `< 0.011377778` **and** `isStalactiteStartPos(state, level, pos)`.
2. `growStalactiteOrStalagmiteIfPossible`.

For the pointed dripstone the override `PointedDripstoneBlock.randomTick` first draws one `nextFloat()` and runs `maybeTransferFluid(state, level, pos, thatFloat)` (section 7.2), then calls the base `randomTick`, so a pointed dripstone random tick makes two `nextFloat` draws, in that order (plus the draws inside `growStalactiteOrStalagmiteIfPossible`). The sulfur spike has no fluid transfer and makes the single draw.

### 5.2 `growStalactiteOrStalagmiteIfPossible(state, level, pos, random)`

1. `canGrow(level, pos)` must hold: base rule: the block above `pos` is the block of `blockToGrowOn` (dripstone block, or sulfur). The pointed dripstone adds: the fluid state at `pos + up(2)` is the still water fluid and a source (`FluidState.is(Fluids.WATER)` and `isSource`), so only a stalactite hanging from a dripstone block that has a water source directly above that block grows.
2. `tipPos = findTip(state, level, pos, getMaxGrowthLength(), false)`; none: stop. `getMaxGrowthLength()` is 7 for the pointed dripstone and 2 for the sulfur spike (`MAX_GROWING_LENGTH`).
3. `tipState` = the state at `tipPos`. Both must hold: `isFreeHangingStalactite(tipState)` and `canTipGrow(tipState, level, tipPos)`; otherwise stop. `canTipGrow`: the cell `c` below the tip (in its tip direction): false when its fluid state is non-empty; true when it is air; else `isUnmergedTipWithDirection(c, opposite(tipDirection))` (an unmerged tip of this block pointing up).
4. Draw `nextBoolean()`: true: `grow(level, tipPos, DOWN)` (extend the stalactite, or merge); false: `growStalagmiteBelow(level, tipPos)` (5.3).

Length bound (inferred arithmetic from `findBlockVertical`, which examines `maxIter - 1` cells): a pointed dripstone stalactite grows while its tip is at most 6 cells below its top piece, so growth stops at 8 pieces; a sulfur spike grows while its tip is at most 1 cell below its top piece, so it stops at 3 pieces. Stalagmites have no length limit of their own.

### 5.3 `growStalagmiteBelow(level, tipPos)`

1. `p` starts at `tipPos`. Repeat for `i = 0 .. 9` (10 iterations): move `p` one block **down**; `s` = the state at `p`.
2. If `s`'s fluid state is not empty: stop (nothing grows).
3. If `isUnmergedTipWithDirection(s, UP)` (an existing stalagmite tip): if `canTipGrow(s, level, p)`: `grow(level, p, UP)` and stop. Otherwise continue with step 4.
4. If `isValidSpeleothemPlacement(level, p, UP)` (the cell below `p` can carry a stalagmite) and the cell `p + down` is not water (`isWaterAt`, fluid in tag `water`): `grow(level, p + down, UP)`, which writes at `p`, and stop.
5. If `blocksStalagmiteScan(level, p, s)`: stop. For the pointed dripstone this is `not canDripThrough(level, p, s)` (a block that would stop a drop ends the search); for the sulfur spike it is always false. Otherwise the loop continues.

After 10 iterations nothing happened.

### 5.4 `grow(level, tipPos, T)`, `createSpeleothem`, `createMergedTips`

`grow` (the new cell is `target = tipPos + T`, `s` = its state):
1. If `isUnmergedTipWithDirection(s, opposite(T))` (an opposing unmerged tip of this block is there): `createMergedTips(s, level, target)`.
2. Else when `s` is air or the block `water` (any `water` block state): `createSpeleothem(level, target, T, tip)`.
3. Otherwise nothing.

`createSpeleothem(level, pos, T, thickness)`: write this block's default state with `vertical_direction = T`, the given thickness and `waterlogged` = the fluid at `pos` is `Fluids.WATER`, with `setBlockAndUpdate` (flags 3). The thickness is written directly (no `calculateSpeleothemThickness`); the neighbours' shape updates (4.4 rule 5) then repair the pieces beside it.

`createMergedTips(s, level, pos)`: when `s.vertical_direction == UP` then `lower = pos` and `upper = pos + up`; otherwise `upper = pos` and `lower = pos + down`. Then `createSpeleothem(upper, DOWN, tip_merge)` and `createSpeleothem(lower, UP, tip_merge)` (in that order). Both blocks are this block, so a pointed dripstone never merges with a sulfur spike (rule 1 requires "this block").

Result: the upper and lower pieces become a `tip_merge` pair that touches (the column then reads as one continuous column; a merged tip does not grow, drip, or count as a free-hanging tip).

## 6. Falling and breaking

### 6.1 The block tick

`tick(state, level, pos, random)` (ST), scheduled by 4.4 rule 4:
1. If `isStalagmite(state)` and `canSurvive(state, level, pos)` is false: `level.destroyBlock(pos, true)` (the block breaks with drops, 29 section 10.6; no entity).
2. Otherwise: `spawnFallingStalactite(state, level, pos)`. This branch also runs for a stalactite that can currently survive: a scheduled tick on a stalactite always makes it fall (the only way a stalactite tick is scheduled is 4.4 rule 4, but a tick scheduled earlier is not cancelled when the support returns) and does nothing for a stalagmite that survives (it is not a stalactite).

### 6.2 `spawnFallingStalactite(state, level, pos)`

Walk from `pos` downward with a cursor `c` (starting at `pos`) and a state `s` (starting at the ticking state):

1. While `isStalactite(s)`:
   1. `e = FallingBlockEntity.fall(level, c, s)` (29b part 1 section 4.1): the entity takes `s` with `waterlogged` cleared, spawns at the block's centre bottom and the block at `c` is replaced with its fluid's legacy block (water or air) with flags 3.
   2. If `isTip(s, true)` (a tip or merged tip, the end of the column): `h = max(1 + pos.y - c.y, 6)` (the bytecode pushes 6 and calls `Math.max`, read; the floor of 6 is what the artifact does), `e.setHurtsEntities(1.0 x h, 40)` (damage per fall distance `1.0 x h`, maximum 40) and stop.
   3. Else move `c` one block down and read the state `s` there.
2. A column therefore becomes one falling entity per piece, from the top piece down to the tip; only the tip's entity hurts entities.
3. The loop stops without a tip (and without damage) when the column below ends before a tip (for example after a partial break).

### 6.3 Landing and damage (what the speleothem adds to 29b part 1 section 4)

| Item | Rule |
|---|---|
| `Fallable.onLand` | not overridden (nothing) |
| `Fallable.onBrokenAfterFall(level, pos, entity)` | when the entity is not silent: `level.levelEvent(landingSound, pos, 0)` where `landingSound` is 1045 for the pointed dripstone and 1052 for the sulfur spike (8.2); called by 29b-1 section 4.3 steps 3, 5c (when `setBlockAndUpdate` fails and the item drops) and 6 |
| `Fallable.getFallDamageSource(entity)` | damage type `falling_stalactite` (not the default `falling_block`) |
| Damage formula | 29b part 1 section 4.6 with `fallDamagePerDistance = 1.0 x h` and `fallDamageMax = 40`: `n = ceil(fallDistance - 1)`, `damage = min(floor(n x h), 40)`; reductions per 17 |
| Does the piece place itself again? | the entity's `canSurvive` needs a sturdy block or a speleothem above (the entity rests on the ground below, so above is normally air): normally no. It is discarded, the landing event is sent and the block's item drops when `dropItem` and the `entity_drops` rule hold (29b part 1 section 4.3 step 6, 4.5) |

### 6.4 Projectile breaking (`onProjectileHit`)

Server level only. The block is destroyed with drops (`level.destroyBlock(pos, true)`) when all hold: the level is a `ServerLevel`; `projectile.mayInteract(level, pos)`; `projectile.mayBreak(level, pos)`; the projectile is a trident (`ThrownTrident`); and its velocity vector length is greater than 0.6.

`mayInteract`: the owner is a player: the player's own `mayInteract(level, pos)` (spawn protection and game mode, 29 section 11); the owner is another entity: the game rule `mob_griefing` must be true; no owner: true. `mayBreak`: the projectile's entity type is in `impact_projectiles` (arrows, firework rocket, snowball, fireball, small fireball, egg, trident, dragon fireball, wither skull, wind charge, breeze wind charge, read in the tag) **and** the game rule `projectiles_can_break_blocks` is true (default true, 16) **and** `canBreakBlockInAdventureMode`: true when the owner is absent and the server's default game type is not adventure, or the owner is a player not in adventure mode; otherwise it is the projectile's own `canBreak` adventure predicate (null for ordinary projectiles, which fails). So a trident thrown by a non-player owner never breaks a speleothem (read in `Projectile.canBreakBlockInAdventureMode`: a non-player owner skips the first two tests and ends at the `canBreak` predicate, which is null for ordinary projectiles).

## 7. Pointed dripstone: fluid, cauldron, mud, damage

### 7.1 `getFluidAboveStalactite(level, pos, state)` and `findRootBlock`

Returns a record `(pos, fluid, sourceState)` or nothing. Steps:

1. Nothing unless `isStalactite(state)`.
2. `root = findRootBlock(level, pos, state, 11)`: `findBlockVertical` from `pos` going **up**, `pass` = the state is the same block as `state` with the same tip direction, `stop` = the state is **not** the same block as `state`. At most 10 cells are examined; the position of the first non-pointed-dripstone block above the column is the root (a column taller than 10 pieces, or one met by a different-direction piece, gives nothing).
3. `above = root + up`; `a` = the state at `above`.
   - When `a` is `mud` and the environment attribute `water_evaporates` at `above` is **false**: `fluid = Fluids.WATER` (the still fluid object) regardless of what the mud holds.
   - Otherwise `fluid` = the type of the fluid state at `above` (`FluidState.getType`: flowing water is not the still water object, so flowing water drips nothing).
4. The result is `(above, fluid, a)`.

`getCauldronFillFluidType(level, tipPos)`: the `fluid` of `getFluidAboveStalactite(level, tipPos, state at tipPos)` when it exists and is lava or water (`canFillCauldron`: identity with `Fluids.LAVA` or `Fluids.WATER`), else `Fluids.EMPTY`.

`findStalactiteTipAboveCauldron(level, cauldronPos)`: `findBlockVertical` from the cauldron going **up**, up to 10 cells, `pass` = `canDripThrough`, `stop` = `isFreeHangingStalactite`; the tip position or none.

`findFillableCauldronBelowStalactiteTip(level, tipPos, fluid)`: `findBlockVertical` going **down** from the tip, up to 10 cells, `pass` = `canDripThrough`, `stop` = the block is an `AbstractCauldronBlock` whose `canReceiveStalactiteDrip(fluid)` is true; the cauldron position or none.

### 7.2 `maybeTransferFluid(state, level, pos, roll)` (the random tick part)

`roll` is the `nextFloat()` drawn by `randomTick` (5.1). Constants read: water 0.17578125, lava 0.05859375 (`WATER_TRANSFER_PROBABILITY_PER_RANDOM_TICK`, `LAVA_TRANSFER_PROBABILITY_PER_RANDOM_TICK`), search length 11 (the max-iteration constant of `findBlockVertical`; 10 cells are examined, see 7.3).

1. Return when `roll > 0.17578125` (the check against the lava constant is in the same condition and adds nothing).
2. Return unless `isStalactiteStartPos(state, level, pos)`.
3. `info = getFluidAboveStalactite(level, pos, state)`; none: return.
4. The fluid's threshold: `Fluids.WATER` 0.17578125, `Fluids.LAVA` 0.05859375, any other fluid: return. Return when `roll >= threshold`.
5. `tipPos = findTip(state, level, pos, 11, false)` (an unmerged tip within 10 cells below); none: return.
6. **Mud to clay.** When `info.sourceState` is `mud` and the fluid is water: `setBlockAndUpdate(info.pos, clay default)`; `Block.pushEntitiesUp(info.sourceState, clay, level, info.pos)` (29b-2 section 9.5); game event `block_change` at `info.pos` with the clay state as context; level event **1504** at `tipPos` data 0; stop.
7. Otherwise `cauldron = findFillableCauldronBelowStalactiteTip(level, tipPos, fluid)`; none: return.
8. Level event **1504** at `tipPos`; `delay = 50 + (tipPos.y - cauldron.y)`; schedule a block tick of the cauldron's block at `cauldron` with that delay (ST; the cauldron tick is section 8.1).

So per random tick of a qualifying stalactite top piece the water probability is 0.17578125 (45/256) and the lava probability is 0.05859375 (15/256); lava needs a lava source directly above the root.

### 7.3 Other `PointedDripstoneBlock` members

| Member | Rule |
|---|---|
| `getStalactiteLandingSound()` | 1045 |
| `fallOn(level, state, pos, entity, distance)` | when the state is a pointed dripstone with tip direction UP and thickness exactly `tip`: `entity.causeFallDamage(distance + 2.5, 2.0f, damageSources.stalagmite())` (constants `STALAGMITE_FALL_DISTANCE_OFFSET` 2.5, `STALAGMITE_FALL_DAMAGE_MODIFIER` 2); otherwise the base `fallOn` (the ordinary block rule of 29b part 1 section 4.6, so no extra damage) |
| `animateTick` (client) | the drip particle: 42-3; the constants are `DRIP_PROBABILITY_PER_ANIMATE_TICK` 0.02 and `..._IF_UNDER_LIQUID_SOURCE` 0.12 |
| `canGrow` | the base rule plus a water source two above (5.2) |
| `blocksStalagmiteScan` | `not canDripThrough` (5.3) |
| Search constants | `MAX_SEARCH_LENGTH_BETWEEN_STALACTITE_TIP_AND_CAULDRON` = 11, and the same 11 for the drip-type (root) search of 7.1. 11 is the `findBlockVertical` max-iteration argument, not a cell count: 10 cells are examined (4.2), as in 7.1 and 7.2 ("search length 11") |

### 7.4 What the drip does not do

The stalactite does not by itself fill any cauldron: it only schedules the cauldron's tick after the random-tick roll; the fill itself is decided by the cauldron (8.1) which re-reads the stalactite and the fluid at that time.

## 8. The cauldron side, level events and sounds

### 8.1 `AbstractCauldronBlock.tick` and the receivers

`AbstractCauldronBlock.tick(state, level, pos, random)` (ST on the cauldron):
1. `tip = findStalactiteTipAboveCauldron(level, pos)`; none: stop.
2. `fluid = getCauldronFillFluidType(level, tip)`.
3. When `fluid != EMPTY` and `canReceiveStalactiteDrip(fluid)`: `receiveStalactiteDrip(state, level, pos, fluid)`.

| Class | `canReceiveStalactiteDrip(fluid)` | `receiveStalactiteDrip(state, level, pos, fluid)` |
|---|---|---|
| `AbstractCauldronBlock` (default; `lava_cauldron` uses it) | false | nothing |
| `CauldronBlock` (empty `cauldron`) | true for any fluid (only water and lava reach it) | water: set `water_cauldron` default state (level 1) with `setBlockAndUpdate`, game event `block_change` at `pos` with that state, level event **1047** at `pos`; lava: set `lava_cauldron` default, game event `block_change`, level event **1046**; any other fluid: nothing |
| `LayeredCauldronBlock` (`water_cauldron`, `powder_snow_cauldron`) | true only for `Fluids.WATER` and when the block's precipitation type is `RAIN` (so the powder snow cauldron never accepts) | when the state is full (`level == 3`): nothing; else `level + 1` with `setBlockAndUpdate`, game event `block_change`, level event **1047** |

### 8.2 Level events and sounds of this part

| Event | Sent by | Client effect (read in `LevelEventHandler`) |
|---|---|---|
| 1045 `SOUND_POINTED_DRIPSTONE_LAND` | `onBrokenAfterFall` of a pointed dripstone | local sound `block.pointed_dripstone.land` at the block, blocks source, volume 2.0, pitch `0.9 + nextFloat() x 0.1` |
| 1052 `SOUND_SULFUR_SPIKE_LAND` | `onBrokenAfterFall` of a sulfur spike | same, sound `block.sulfur_spike.land` |
| 1046 `SOUND_DRIP_LAVA_INTO_CAULDRON` | `CauldronBlock` lava receive | same shape, sound `block.pointed_dripstone.drip_lava_into_cauldron` |
| 1047 `SOUND_DRIP_WATER_INTO_CAULDRON` | water receive (empty and layered cauldron) | same shape, sound `block.pointed_dripstone.drip_water_into_cauldron` |
| 1504 `DRIPSTONE_DRIP` | `maybeTransferFluid` | no sound: calls `PointedDripstoneBlock.spawnDripParticle(level, pos, state at pos)` (42-3) |
| 3006 `PARTICLES_SCULK_CHARGE` | the sculk spreader | particles only (31-8 section 7.3, 42-6 section 6) |
| 3007 | the shrieker's `shriek` | 44-x2 section 2 |

(The 1048 event, which a neighbouring entry of the same handler maps to a stray conversion sound, is not part of this document.)

## 9. Sulfur spike differences and the behaviour rows

### 9.1 `SulfurSpikeBlock` against `PointedDripstoneBlock`

| Item | `pointed_dripstone` | `sulfur_spike` |
|---|---|---|
| Base class members | `SpeleothemBlock` | `SpeleothemBlock` (same properties, shapes, survival, shape update, falling, projectile rules) |
| `blockToGrowOn` | `dripstone_block` | `sulfur` |
| `canGrow` | block above is `dripstone_block` **and** water source two above | block above is `sulfur` only (no fluid condition) |
| `getMaxGrowthLength()` | 7 (stalactite stops at 8 pieces) | 2 (stalactite stops at 3 pieces) |
| `blocksStalagmiteScan` | `not canDripThrough` | never (the scan always continues until a fluid, a growth, or 10 cells) |
| Random tick draws | `nextFloat` for fluid transfer, `nextFloat` for growth | `nextFloat` for growth only |
| Drip, cauldron fill, mud to clay | yes | none |
| `fallOn` stalagmite damage | tip up: `distance + 2.5`, multiplier 2.0 | none |
| Landing level event | 1045 | 1052 |
| `getFallDamageSource` | `falling_stalactite` | `falling_stalactite` |
| Tag for world generation replacement | `dripstone_replaceable_blocks` (35-6) | `sulfur_spike_replaceable_blocks` = `sulfur`, `cinnabar` (read) |

### 9.2 Behaviour rows (record of 29b part 1 section 2.1)

| Block | Trigger | Source | Condition | Probability | Effect | Flags | Events | Notes |
|---|---|---|---|---|---|---|---|---|
| `budding_amethyst` | RT | `BuddingAmethystBlock.randomTick` | the table of 3.3 | `1/5` then `1/6` per face | write the next bud stage facing the face | 3 | none | draws `nextInt(5)` then `nextInt(6)` |
| `amethyst_cluster`, the 3 buds | SU | `AmethystClusterBlock.updateShape` | support face no longer sturdy | always | the state becomes air | via the update | none | waterlogged: water tick first |
| `amethyst_block` family | EV | `AmethystBlock.onProjectileHit` | server | always | chime sound | none | sound pitch `0.5 + 1.2 r` | |
| `pointed_dripstone`, `sulfur_spike` | SU | `SpeleothemBlock.updateShape` | vertical neighbour change | always | thickness recomputed; unsupported: tick in 2 (stalactite) or 1 (stalagmite) | via the update | none | 4.4 |
| same | ST | `SpeleothemBlock.tick` | stalagmite unsupported: destroy; else stalactite falls | always | destroy with drops, or one falling entity per piece | 3 | 1045 or 1052 on landing | 6 |
| same | RT | `SpeleothemBlock.randomTick` | 5.2 | `P(0.011377778)` | grow stalactite, merge, or grow stalagmite | 3 | none | 5 |
| `pointed_dripstone` | RT | `maybeTransferFluid` | 7.2 | water `P(0.17578125)`, lava `P(0.05859375)` | schedule cauldron tick `50 + height`; or mud to clay | 3 | 1504 | 7 |
| `cauldron`, `water_cauldron` | ST | `AbstractCauldronBlock.tick` | tip above and water or lava | always | fill one step | 3 | 1046 or 1047 | 8.1 |
| `sculk_shrieker` | ST | `SculkShriekerBlock.tick` | `shrieking` true | always | set `shrieking` false (`setBlockAndUpdate`), then `tryRespond(level)` | 3 | none here | 2.2; block entity side 31-8 section 6, warden logic 44 section 2 |
| `sculk_catalyst` | ST | `SculkCatalystBlock.tick` | `bloom` true | always | set `bloom` false; nothing when already false | 3 | none | 2.1; bloom start 31-8 section 7.4 |
| `sculk_sensor`, `calibrated_sculk_sensor` | ST | `SculkSensorBlock.tick` and the calibrated override | phase ticks (active, cooldown) | always | phase and power change | per 31-8 | per 31-8 | owned by 31-8 sections 4 and 5; vibration ticker 31-8 section 3 |
| `sculk`, `sculk_vein` | none (driven by the spreader, not by block triggers) | `SculkSpreader` via the catalyst ticker | 2.1 steps 3 to 5 | see 2.4 | convert, decay or grow | per 35-6 section 8 | 3006 | 2.1 to 2.4; 35-6 sections 8.3 to 8.6 |

### 9.3 `PotentSulfurBlock` (block level; geyser block entity block)

`PotentSulfurBlock extends BaseEntityBlock`, registered in 24 part 8 as field 798 without behaviour. Property `state` (the enum `PotentSulfurState`, serialized names `dry`, `wet`, `dormant`, `erupting`, `continuous`; default `dry`). Constant `ALLOWED_WATER_BLOCKS_ABOVE` = 4. It has a block entity (`PotentSulfurBlockEntity`, fields `waitingCountdown`, `eruptionTick`, saved key `countdown`).

`validBlockState(state, level, pos)` is used both by `getStateForPlacement` and by `updateShape` (any direction; the result replaces the state). It reads the fluid above (`pos + up`) and the block below (`pos + down`, tags `causes_continuous_geyser_eruptions` = `lava` and `causes_periodic_geyser_eruptions` = `magma_block`, read):

| Order | Condition | Result `state` |
|---|---|---|
| 1 | the fluid at `pos + up` is not a water source (`isSourceOfType(WATER)`) | `dry` |
| 2 | the block below is in `causes_continuous_geyser_eruptions` and its fluid state is empty or a source | `continuous` |
| 3 | the block below is in `causes_periodic_geyser_eruptions` and its fluid state is empty or a source | when the current state is neither `erupting` nor `dormant`, the block entity's `resetCountdown` is called first; then the result is `erupting` when the current state is `erupting`, else `dormant` |
| 4 | otherwise | `wet` |

`onPlace`: when the new state is `erupting` or `continuous`: `blockEvent(pos, block, 0, 0)`, the sound `geyser_continuous_start` (continuous) or `geyser_eruption_start` (erupting), blocks source, volume 1, pitch 1, and game event `block_activate` with the state as context. `triggerEvent` stores the level game time into the block entity's `eruptionTick` and returns true. `animateTick` (client): nothing when `dry`; needs a water source above; spawns two bubble particle bursts (`sulfur_bubbles`) at the cell above and, with probability 1/10, the local ambient sound `noxious_gas`.

`getTicker` selects the block entity tickers by state: `dry` none; `wet` client noxious gas ticker, server nausea effect ticker; `dormant` client noxious gas ticker, server (waiting countdown ticker then nausea effect ticker); `erupting` client geyser plume ticker (sound `geyser_eruption_active`) then the launch entity ticker, server launch entity ticker then waiting countdown ticker; `continuous` client geyser plume ticker (sound `geyser_continuous_active`) then launch entity ticker, server launch entity ticker alone. Constants read in the block entity: nausea effect every 10 ticks, effect duration 80 ticks (4.0 s), effect range 3.0 (candidate box 2.5), particle period 20, sound period 40, geyser base launch speed 0.3, launch force 0.2, geyser salt -904011478, geyser scan limit 6 blocks. The countdown ranges, the launch velocity formula and the nausea effect application were not fully read (Open question 1).

## 10. Worked examples

**E1. Budding amethyst, one random tick.** Budding amethyst at P with a small bud facing north at P+north, and air elsewhere. Draw `nextInt(5)` = 3: stop. Draw `nextInt(5)` = 0, then `nextInt(6)` = 2 (north): the target holds `small_amethyst_bud` with `facing` north, rule 2 applies, `medium_amethyst_bud[facing=north, waterlogged=false]` is written. Draw index 3 (south) instead: the target is air, rule 1: a new `small_amethyst_bud[facing=south]` appears. Draw index 1 (up) with a stone block above: rule 5, nothing.

**E2. Stalactite growth (pointed dripstone).** `dripstone_block` at y=10, water source at y=11, a single `pointed_dripstone[down, tip]` at y=9, air below. A random tick draws `nextFloat` twice: the first (fluid transfer) is irrelevant here, the second must be `< 0.011377778`. The tick position is the start piece (`isStalactiteStartPos`), `canGrow` holds, `findTip` returns y=9 (it is itself a tip), it is free hanging, the cell y=8 is air so `canTipGrow` holds; `nextBoolean()` true: `grow(y9, DOWN)` writes `[down, tip]` at y=8. The shape update of y=9 (direction down) recomputes its thickness: the cell below is a speleothem with the same direction and thickness `tip`, so `frustum`. The column is now `frustum (y9), tip (y8)`. After one more growth: the update of y=9 finds a `frustum` below it and `dripstone_block` (not a speleothem) above: `base`. Column: `base (y9), frustum (y8), tip (y7)`, as in 35-6 section 5.3.

**E3. Tips meeting.** Stalactite tip at y=8 (down), a stalagmite tip at y=6 (up), air at y=7. Growth of the stalactite (`nextBoolean` true): `grow(y8, DOWN)` writes the new tip at y=7 (`tip`). Now the tips touch with no gap. Next growth: `canTipGrow(y7)`: the cell y=6 is an unmerged tip pointing up, true; `grow(y7, DOWN)`: the target y=6 is an unmerged tip with direction up (the opposite of DOWN), so `createMergedTips(state at y6, y6)`: its tip direction is UP, `lower = y6`, `upper = y7`; both are rewritten `tip_merge`. The same final state results when `nextBoolean` is false (the stalagmite scan finds y6 as an unmerged tip pointing up, `canTipGrow` true, `grow(y6, UP)` targets y7, merge with `upper = y7`).

**E4. A stalactite falls.** Column `base y12, frustum y11, tip y10` under a ceiling block at y13; the player breaks the ceiling block. The shape update of y12 (direction up, the opposite of the tip direction DOWN): the support is now air, not sturdy, not a speleothem: schedule a block tick in 2 ticks. After 2 ticks `tick` runs: y12 is not a stalagmite, so `spawnFallingStalactite`: falling entities are made for y12, y11, y10 in that order; at y10 (`isTip`): `h = max(1 + 12 - 10, 6) = max(3, 6) = 6`: `setHurtsEntities(6.0, 40)`. A zombie below receives, when the tip entity lands after falling 5 blocks: `n = ceil(5 - 1) = 4`, `damage = min(floor(4 x 6), 40) = 24`. After 8 blocks: `n = 7`, `floor(42) = 42`, capped to 40. Each entity lands, cannot place itself (no support above), is discarded, level event 1045 plays and a pointed dripstone item drops for each piece.

**E5. Stalagmite fall damage.** A player (safe fall distance 3, multiplier 1.0) falls 5 blocks onto a stalagmite tip: `fallOn` calls `causeFallDamage(5 + 2.5 = 7.5, 2.0, stalagmite)`; with 17's formula the damage is `floor((7.5 + 0.000001 - 3.0) x 2.0 x 1.0) = 9`. Landing on a stalagmite `frustum` (not `tip`) uses the ordinary rule: `floor((5 + 1e-6 - 3) x 1 x 1) = 2`.

**E6. Cauldron fill by a stalactite.** Stalactite top piece at y=70, tip at y=70 (a one-piece stalactite), water source above the root dripstone block; a `cauldron` at y=66, air at y=67 to 69. A random tick whose first `nextFloat` is 0.10 (< 0.17578125): the top piece qualifies, `getFluidAboveStalactite` returns water, `findTip` returns y=70, the source is not mud, `findFillableCauldronBelowStalactiteTip` scans y=69, 68, 67 (air passes `canDripThrough`) and finds the cauldron at y=66. Level event 1504 at y=70; the cauldron's tick is scheduled in `50 + (70 - 66) = 54` ticks. At that tick the cauldron finds the tip at y=70 within 4 cells above, the fluid is water, the empty cauldron becomes `water_cauldron[level=1]`, event 1047 (sound volume 2.0). Two more such cycles give level 2 and 3; further cycles do nothing (`isFull`).

**E7. Mud to clay.** A mud block sits directly above the dripstone block that roots a stalactite, in the overworld (`water_evaporates` false). `getFluidAboveStalactite` reports water with source state mud. A random tick with roll below 0.17578125 turns the mud into clay (event 1504 at the tip). In the Nether (`water_evaporates` true) the mud rule does not apply, the fluid is whatever the cell holds, so nothing happens.

## 11. Validation: checkable facts

1. `speleothems` contains exactly `pointed_dripstone` and `sulfur_spike`; `vibration_resonators` exactly `amethyst_block`; `sulfur_spike_replaceable_blocks` exactly `sulfur`, `cinnabar`.
2. Growth probability float 0.011377778 equals `1 / 87.890625` (rounded); water transfer 0.17578125 equals 45/256; lava 0.05859375 equals 15/256.
3. `BuddingAmethystBlock.GROWTH_CHANCE` is 5; `DIRECTIONS` order is down, up, north, south, west, east.
4. Thickness table of 4.5 for a downward column of height 1, 2, 3, 4: `[tip]`, `[frustum, tip]`, `[base, frustum, tip]`, `[base, middle, frustum, tip]` read from the support.
5. A pointed dripstone stalactite stops growing at 8 pieces, a sulfur spike at 3 (both inferred arithmetic, 5.2).
6. Landing events: 1045 and 1052; cauldron fill events 1046 (lava) and 1047 (water); drip particle event 1504; the sound volume of these events is 2.0 and the pitch `0.9 + 0.1 r`.
7. Cauldron tick delay `50 + (tip y - cauldron y)`.
8. `max(1 + pos.y - tip.y, 6)` (a lower bound of 6 on the damage factor, 6.2).
9. Chime pitch range of an amethyst hit is `[0.5, 1.7)`.
10. The mud-to-clay path needs `water_evaporates` false at the cell above the root.

## 12. Open questions

1. `PotentSulfurBlockEntity` (geyser): block-level rules are in 9.3, but the waiting countdown ranges (the bytecode shows the constants 10, 15, 30 and a 20-tick period in the countdown ticker), the transition `dormant` to `erupting` and back, the launch entity velocity formula and the nausea effect application and its entity predicate were not fully read this round. The block entity is not specified in 31 either; it needs an owner (a block-entity round).
2. For the owner of 35-6: its line on `canClusterGrowAtState` glosses "fluid state is full" as "i.e. a source"; in the artifact `FluidState.isFull` is `getAmount() == 8`, which also holds for falling flowing water. This part's description is the correct one. The geode feature also sets `waterlogged` from `FluidState.isSource`, while `BuddingAmethystBlock` uses `FluidState.is(Fluids.WATER)`; the two differ for a falling-water cell.
3. Timing of the first update of a cursor after `addCursors` relative to the catalyst's own tick order (the catalyst ticker runs in the block-entity phase of the level tick, 33) was not re-read.
4. `Level.playSound(null, pos, ...)` position handling (block centre) is stated from the call shape (29 section 7); the sound engine's attenuation is not covered here.
5. The game rules `mob_griefing` and `projectiles_can_break_blocks` defaults are those of 16 and 33 section 5; their rule class was not re-read.
6. The environment attribute `water_evaporates` is sampled positionally at the cell above the root block; the attribute system (dimension, biome, time modifiers) is 23 and 33, not re-read.
7. Item drop contents of the speleothem and amethyst blocks when broken (loot tables) are data (26) and not tabulated; the budding amethyst drop (none) is stated from the push reaction and loot convention, not from the loot table, which was not read.
8. The client rendering of the amethyst cluster crossed models, thickness model variants and the drip particle fall chain are not in this document (12 and 42).
9. Table 1.2 of `29b-falling-growth-fire-1-...` still shows part 6 as not yet written; that is the concern of that part or the README, not of this document.
10. Unverified sections (review note): the sculk spreader constants, `SculkBlock.attemptUseCharge`, the level event 3006 data formula (section 2.2) and the `PotentSulfurBlock` table (9.3) were not independently re-read by a second reader; they need a second check. Until Open question 1 is resolved, 9.3 is not sufficient to implement the geyser.
11. The `BlockBehaviour.Properties` initialiser (default push reaction `PUSH_PULL` for `amethyst_block`) was not read; the default is taken from 24-8 and enum order, not from this class.
