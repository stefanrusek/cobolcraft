# 30 (part 1). Redstone: shared model, the signal queries, redstone wire, redstone block, redstone ore, redstone torches

| | |
|---|---|
| Covers | The shared model of the redstone documents: terminology; the signal model (power 0 to 15; weak and strong power; the block hooks `isSignalSource`, `getSignal`, `getDirectSignal`, `ownSignal`, `hasAnalogOutputSignal`, `getAnalogOutputSignal`, `shouldRedstoneWireConnectTo`; the level queries `getSignal`, `getDirectSignal`, `getDirectSignalTo`, `getControlInputSignal`, `getBestNeighborSignal`, `hasNeighborSignal`, `hasSignal`, `getBestOwnOrNeighbourSignal`); the redstone-conductor rule; the census of every block class that overrides a signal hook and which part owns it; the update-order rules as redstone uses them; tick-delay and priority conventions; the doc schemas of parts 2 to 8; the delay table they fill in. Blocks: `redstone_wire` (`RedstoneWireBlock`: connection states, power computation, propagation, update order, the `shouldSignal` flag, particles, colour table, shapes), `redstone_block` (`PoweredBlock`), `redstone_ore` and `deepslate_redstone_ore` (`RedStoneOreBlock`), `redstone_torch` (`RedstoneTorchBlock`) and `redstone_wall_torch` (`RedstoneWallTorchBlock`): lit and unlit inversion, attached-block power, burnout. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS12 part 1 (GAP-10c of `../design/README.md` Part 5) |
| Data versus code | Block registry rows, state ids and property orders are registry data held by 24 (parts 2, 3, 5, 8); loot tables and tags are data (22, 26). This document holds the behaviour. |

"Read" means read in the artifact this round. "(inferred)" marks a deduction from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions.

Related documents. Update flags, `setBlock`, the neighbour updater, shape updates and scheduled-tick queues are in 29 (§1 to §4); this document cites them and does not repeat them. Tick order of a level is 33 §2. Block entities (containers read by comparators, dispensers) are 31. Block registry rows and state ids are 24; item ids 25. Particles are 42. Sibling parts of this document: part 2 repeaters, comparators, observers (`DiodeBlock` family); part 3 pistons; part 4 dispensing and containers; part 5 switches and sensors; part 6 rails (`30-redstone-6-rails.md`); part 7 door-class blocks, lamps and light-driven blocks; part 8 sculk, tripwire, bells, special. A sibling file is cited as "30 part N" and its section as "30 part N §x".

## 0. Reader's map

| Question | Section |
|---|---|
| Terms | 1 |
| The hooks a block has to say what power it gives | 2.1 |
| What a direction argument means | 2.2 |
| The six level queries, exactly | 2.3 |
| Which blocks conduct power | 2.4 |
| Census of signal-hook overrides, by owning part | 2.5 |
| Order in which neighbours are told | 2.6 |
| Experimental evaluator (feature flag) | 2.7 |
| Scheduled tick conventions and priorities | 3 |
| Doc schemas, ids, delay table | 4 |
| Redstone wire | 5 |
| Redstone block | 6 |
| Redstone ore | 7 |
| Redstone and wall torches | 8 |
| Worked examples | 9 |
| Validation | 10 |
| Open questions | 11 |

## 1. Terminology

| Term | Meaning here |
|---|---|
| Power, signal | An integer 0 to 15 (`Redstone.SIGNAL_MIN` 0, `SIGNAL_MAX` 15, `SIGNAL_NONE` 0, `BITS` 4, `MASK` 15, all read). 0 means "off". Every test of "powered" in this family is "greater than 0" or "equals 15" as stated per block. |
| Signal source | A block state for which `isSignalSource` is true: the block may output power. Wire connects sideways only to signal sources (2.1). |
| Weak power (also called "indirect" or "soft") | The value `getSignal(state, level, pos, direction)` that a block gives to a neighbour. A conductor block that receives it from a neighbour passes it on to its own neighbours only through the query `getSignal` of the level (2.3), never through `getDirectSignal`. |
| Strong power (also called "direct") | The value `getDirectSignal(state, level, pos, direction)`. A conductor block adjacent to a block that gives direct power is itself "powered" for all its neighbours (2.3, `getSignal` of the level adds `getDirectSignalTo`). |
| Conductor | A state with `isRedstoneConductor` true (2.4). Only conductors carry strong power to the neighbours that read through them, and wire climbs and descends only around conductors. |
| Own signal | `ownSignal(state, level, pos)`: the value a block outputs regardless of direction; the default `getSignal` returns it (2.1). |
| Analog output | `hasAnalogOutputSignal` and `getAnalogOutputSignal`: the value a comparator reads from a container-like block (part 2). It is not a signal in the sense above. |
| Neighbour-changed, shape update | The two notifications of 29 §3.1. Redstone logic runs from neighbour-changed and from scheduled ticks; wire and torches also use shape updates (5.3, 8.4). |
| Burnout | A redstone torch that toggled 8 times at its position within 60 game ticks stops for 160 ticks (8.3). |

## 2. The signal model

### 2.1 Block hooks (all read in `BlockBehaviour` and `BlockBehaviour.BlockStateBase`)

| Hook (block method) | State wrapper | Default | Meaning |
|---|---|---|---|
| `isSignalSource(state)` | `isSignalSource()` | false | the block can output power |
| `ownSignal(state, level, pos)` | `getOwnSignal(level, pos)` | 0 | direction-free output |
| `getSignal(state, level, pos, direction)` | `getSignal(level, pos, direction)` | returns `ownSignal(state, level, pos)` | weak power towards a neighbour (2.2) |
| `getDirectSignal(state, level, pos, direction)` | `getDirectSignal(level, pos, direction)` | 0 | strong power towards a neighbour (2.2) |
| `hasAnalogOutputSignal(state)` | `hasAnalogOutputSignal()` | false | the block has an analog output (container-like) |
| `getAnalogOutputSignal(state, level, pos, direction)` | `getAnalogOutputSignal(level, pos, direction)` | 0 | the analog value (part 2 reads it) |
| `shouldRedstoneWireConnectTo(state, level, pos, direction)` | `shouldRedstoneWireConnectTo(...)` | `state.isSignalSource() and direction is not null` | whether adjacent wire connects sideways to this block (5.2) |
| `isRedstoneConductor` | `isRedstoneConductor(level, pos)` | block property predicate (2.4) | |

Two overrides of `shouldRedstoneWireConnectTo` exist among the block classes, besides wire itself: `ObserverBlock` and `RepeaterBlock` (census, 2.5; their rules are in part 2). Wire's own override returns true always (5.2).

### 2.2 What the direction argument means

The same direction convention is used by every hook and every level query (read from the callers in `SignalGetter`):

- A **receiver** at `R` asks the block at `R + d` with the argument `d`. So `d` is the direction from the receiver towards the block that is being asked, and the asked block is on the `d` side of the receiver.
- The asked block therefore gives power "towards `-d`". Examples (all read): a standing redstone torch answers 0 when asked with `UP` (a torch gives no weak power to the block it stands on, which is below it); a wall torch answers 0 when asked with its own `facing` (the block it is attached to is on the side opposite its facing); redstone wire answers 0 when asked with `DOWN` (wire does not power the block above it), and answers its power when asked with `UP` (wire powers the block it lies on).
- `getDirectSignalTo(pos)` asks the six neighbours with the direction that leads from `pos` to each of them (below with `DOWN`, above with `UP`, north, south, west, east).

### 2.3 The level queries (`SignalGetter`, implemented for every level; read)

`SignalGetter.DIRECTIONS` is `Direction.values()`: DOWN, UP, NORTH, SOUTH, WEST, EAST (read).

| Query | Result |
|---|---|
| `getDirectSignal(pos, d)` | `getBlockState(pos).getDirectSignal(level, pos, d)` |
| `getDirectSignalTo(pos)` | `r = 0`. For `(p, d)` in the order (`pos.below()`, DOWN), (`pos.above()`, UP), (`pos.north()`, NORTH), (`pos.south()`, SOUTH), (`pos.west()`, WEST), (`pos.east()`, EAST): `r = max(r, getDirectSignal(p, d))`, and return `r` at once when `r >= 15`. Return `r`. |
| `getSignal(pos, d)` | `s = getBlockState(pos).getSignal(level, pos, d)`. If that state `isRedstoneConductor(level, pos)`: return `max(s, getDirectSignalTo(pos))`. Otherwise return `s`. So a conductor's power is the stronger of its own weak output and the strong power any neighbour gives to it. |
| `hasSignal(pos, d)` | `getSignal(pos, d) > 0` |
| `getBestNeighborSignal(pos)` | `r = 0`. For `d` in DIRECTIONS order: `s = getSignal(pos + d, d)`; if `s >= 15` return 15; `r = max(r, s)`. Return `r`. This is "the strongest weak or strong power reaching `pos` from any side". |
| `hasNeighborSignal(pos)` | true when, in the order below, above, north, south, west, east, `getSignal(pos + d, d) > 0` for some `d` (returns at the first hit; same value as `getBestNeighborSignal(pos) > 0`, inferred from the two loops, which use the same arguments). |
| `getBestOwnOrNeighbourSignal(pos)` | `max(getBestNeighborSignal(pos), state.isSignalSource() ? state.getOwnSignal(level, pos) : 0)` where `state` is the block at `pos` itself. |
| `getControlInputSignal(pos, d, onlyDiodes)` | `state = getBlockState(pos)`. If `onlyDiodes`: return `getDirectSignal(pos, d)` when `state` is a `DiodeBlock` state (`DiodeBlock.isDiode`: the block is an instance of `DiodeBlock`, which is repeater and comparator), else 0. If not `onlyDiodes`: return 15 when the state is `redstone_block`; the `power` property when it is `redstone_wire`; `getDirectSignal(pos, d)` when it is a signal source; else 0. This is the query a repeater or comparator uses on its back input and, with `onlyDiodes` true, on its side inputs (part 2). Note the wire case reads the stored `power` directly and ignores the connection rule. |

Consequences worth stating once:

1. Wire never feeds itself. While a wire recomputes its target (5.4) the block's `shouldSignal` flag is false, which makes its own `getSignal`, `getDirectSignal` and `isSignalSource` answer 0 or false, so every wire neighbour (and the wire itself seen through a conductor) contributes nothing to `getBestNeighborSignal`. Wire-to-wire power is added separately (5.4).
2. A conductor never outputs power by itself: `ownSignal` of a plain block is 0. Strong power comes only from the blocks that override `getDirectSignal` (census 2.5); the lever, button, plate, torch, repeater, comparator, observer and similar give it in the directions that part 2 and part 5 list.
3. A block that is not a conductor (glass, redstone block, observer, and others flagged in 2.4) cannot be strongly powered: `getSignal` of the level returns only its own weak output for it.

### 2.4 The redstone-conductor rule

The default predicate of the builder is "the state's collision shape is a full block" (`BlockState.isCollisionShapeFullBlock`; read in 24 part 1 §4.1 and again in `Properties` this round: the default is a lambda stored in `isRedstoneConductor`). A block may replace it. Read in the `Blocks` class: `Properties.isRedstoneConductor` is called at exactly 26 sites. 24 pass the shared constant-false predicate (`Blocks.never`, the same bootstrap entry that `leavesProperties` uses for its other predicates) and 2 pass the constant-true predicate (`Blocks.always`). Each site was traced to its block name by the registration that follows it (read). The complete list:

| Predicate | Sites | Blocks |
|---|---|---|
| never, through a shared helper | `leavesProperties` (1 site, 12 callers) | `oak_leaves`, `spruce_leaves`, `birch_leaves`, `jungle_leaves`, `acacia_leaves`, `dark_oak_leaves`, `mangrove_leaves`, `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves`, `azalea_leaves`, `flowering_azalea_leaves` |
| never, helper | `pistonProperties` (1 site, 2 callers) | `piston`, `sticky_piston` |
| never, per-family lambda | 3 sites | the stained-glass family (one lambda over `DyeColor`, sound `GLASS`; registered once as `STAINED_GLASS`, so all 16 colours), the copper-grate family and the copper-bulb family (one lambda each over the four `WeatherState` values; whether the waxed variants reuse them is (inferred) from the registration helper and not traced) |
| never, direct | 19 sites | `cherry_leaves`, `pale_oak_leaves` (both direct, not through the leaves helper), `glass`, `moving_piston`, `tnt`, `ice`, `glowstone`, `beacon`, `redstone_block`, `sea_lantern`, `chorus_flower`, `frosted_ice`, `observer`, `bamboo`, `scaffolding`, `tinted_glass`, `powder_snow`, `pointed_dripstone`, `sulfur_spike` |
| always | 2 sites | `soul_sand`, `mud` |

Total never: 1 + 1 + 3 + 19 = 24 sites; always: 2. `shulkerBoxProperties` does not call `isRedstoneConductor` (read: its only predicate calls are other properties), so shulker boxes keep the default full-collision-shape rule; so does `air` (no call in the table; whether the base `air` class overrides it elsewhere was not read, Open question 3). Cross-check with 24: `chorus_flower`, `frosted_ice`, `observer`, `bamboo` (part 6), `scaffolding`, `redstone_block` (part 5) and `mud` (part 8) were found in the flags column earlier and agree. The flags column of 24 remains the per-state record; this table is the per-block read from `Blocks`. Wire-side tests of "conductor" (5.2, 5.4) use `isRedstoneConductor(level, pos)` on the state at that position.

### 2.5 Census of signal-hook overrides (class level, read from the declared methods of the 410 class files in `net.minecraft.world.level.block` of the jar, of which 330 are top-level classes and 80 inner classes; the census is exact over the 330 top-level classes)

| Hook | Classes that declare it (besides the base) | Owner |
|---|---|---|
| `isSignalSource` and `ownSignal` | `BasePressurePlateBlock`, `ButtonBlock`, `DaylightDetectorBlock`, `DetectorRailBlock`, `DiodeBlock`, `JukeboxBlock`, `LecternBlock`, `LeverBlock`, `LightningRodBlock`, `ObserverBlock`, `PoweredBlock`, `RedstoneTorchBlock`, `RedstoneWireBlock`, `SculkSensorBlock`, `TargetBlock`, `TrappedChestBlock`, `TripWireHookBlock`; `ownSignal` also in `TestBlock` | `PoweredBlock`, torches, wire: this document. `DiodeBlock`, `ObserverBlock`: part 2. Plates, buttons, lever, daylight detector, target, lightning rod, jukebox: part 5. Trapped chest: 31-1 section 10.5 and part 5. Lectern: 31-4 and part 5 section 9. Detector rail: part 6. Sculk sensor, tripwire hook: part 8. `TestBlock`: 31-6 (with `CommandBlock` and `StructureBlock`) |
| `getSignal` | `CalibratedSculkSensorBlock`, `DiodeBlock`, `ObserverBlock`, `RedstoneTorchBlock`, `RedstoneWallTorchBlock`, `RedstoneWireBlock` | as above; calibrated sculk sensor: part 8 |
| `getDirectSignal` | `BasePressurePlateBlock`, `ButtonBlock`, `DetectorRailBlock`, `DiodeBlock`, `LecternBlock`, `LeverBlock`, `LightningRodBlock`, `ObserverBlock`, `RedstoneTorchBlock`, `RedstoneWireBlock`, `SculkSensorBlock`, `TrappedChestBlock`, `TripWireHookBlock` | as above |
| `hasAnalogOutputSignal` / `getAnalogOutputSignal` | `AbstractCauldronBlock` (has only; `LavaCauldronBlock`, `LayeredCauldronBlock` give values), `AbstractFurnaceBlock`, `BarrelBlock`, `BeehiveBlock`, `BrewingStandBlock`, `CakeBlock`, `CandleCakeBlock`, `ChestBlock`, `ChiseledBookShelfBlock`, `CommandBlock`, `ComposterBlock`, `CopperBulbBlock`, `CopperGolemStatueBlock`, `CrafterBlock`, `CreakingHeartBlock`, `DecoratedPotBlock`, `DetectorRailBlock`, `DispenserBlock` (covers the dropper), `EndPortalFrameBlock`, `HopperBlock`, `JukeboxBlock`, `LecternBlock`, `RespawnAnchorBlock`, `SculkSensorBlock`, `ShelfBlock`, `ShulkerBoxBlock` | part 2 states the comparator's use; each value is owned by the block's family part (containers: part 4; the rest: parts 5 to 8) |
| `shouldRedstoneWireConnectTo` | `ObserverBlock`, `RepeaterBlock`, `RedstoneWireBlock` | part 2 (the first two) and 5.2 |

`PoweredBlock` is two methods (6). The remaining families are specified by their parts; this document gives the shared algorithms they call.

### 2.6 Notification order and update order

Redstone uses the engine of 29 without change. The facts a redstone implementer needs from it, restated as a checklist (the full text is in 29 §3):

1. **Neighbour-changed order** (`NeighborUpdater.UPDATE_ORDER`): west, east, down, up, north, south. `updateNeighborsAt(pos, block)` tells the six neighbours of `pos` in this order, `block` being the source block passed.
2. **Shape-update order** (`UPDATE_SHAPE_ORDER`): west, east, north, south, down, up.
3. The queue is depth first in order of addition and counts every notification toward `max-chained-neighbor-updates` (29 §3.3).
4. `setBlock` flag 1 (neighbours) tells the neighbours of the position with the **old** block as the source; flag 2 sends the block to clients; wire writes its power with flag 2 only and tells the neighbours itself (5.4).
5. `Direction.values()` order (DOWN, UP, NORTH, SOUTH, WEST, EAST) is used by the signal queries (2.3), by wire's neighbour-set (5.4) and by the torch's `notifyNeighbors` (8.2). `Direction.Plane.HORIZONTAL` is NORTH, EAST, SOUTH, WEST; `Direction.Plane.VERTICAL` is UP, DOWN (read in the plane initializer).
6. **Directional update order** (the order in which a component notifies its neighbours, and whether it skips the neighbour it is attached to) is a per-block rule. Wire: 5.4 and 5.5. Torch: 8.2. `updateNeighborsAtExceptFromFacing(pos, block, skipDirection)` skips one direction (29 §3.1); its redstone callers are wire (5.5) and the `DiodeBlock` family (part 2).

### 2.7 The experimental evaluator

`RedstoneWireBlock.useExperimentalEvaluator(level)` is true when the level's enabled feature flags contain `REDSTONE_EXPERIMENTS`. In `FeatureFlags` the flag key is `redstone_experiments`; `DEFAULT_FLAGS` is `VANILLA_SET` (read), which holds only the `vanilla` flag, so a default world does not enable it (the flag is enabled by a data pack or world setting; the mechanism is 22/23 territory). When enabled: wire uses `ExperimentalRedstoneWireEvaluator` (a different propagation algorithm with an `Orientation` argument carried by neighbour notifications), `neighborChanged` of wire ignores updates whose source block is wire, and torch, repeater and similar blocks pass random or directional `Orientation` values (`ExperimentalRedstoneUtils.initialOrientation`, `withFront`). This document specifies the default evaluator only. The experimental evaluator and `Orientation` (543 lines of bytecode, with a stream codec for the orientation) are not specified (Open question 1); `orientation` arguments are null on a default world (29 §3.3).

## 3. Tick conventions

Mechanics are in 29 §4. What redstone adds:

- **Scheduling call.** A block schedules its own tick with `scheduleTick(pos, block, delay)` or `scheduleTick(pos, block, delay, priority)`; the three-argument form uses priority `NORMAL` (29 §4.1). A delay is in game ticks; the tick runs in the drain of game tick `T + delay` (29 §4.4). Redstone game ticks and "redstone ticks" differ: one **redstone tick** is 2 game ticks (the repeater's smallest delay and the torch's delay of 2 are both one redstone tick). All delay tables in parts 2 to 8 give game ticks.
- **Identity.** A pending tick for the same block at the same position is not added again (29 §4.1). Blocks that must not queue twice test `hasScheduledTick` or `willTickThisTick` first; the torch uses `willTickThisTick` (8.4).
- **Priorities.** `TickPriority` values -3 (`EXTREMELY_HIGH`) to 3 (`EXTREMELY_LOW`), lower first (29 §4.1). The blocks of this document use only the default `NORMAL`. Part 2 lists the priorities the repeater and comparator pick, and part 3 the piston's.
- **Within one game tick** ticks are merged by (priority, sub-tick order) after each chunk's own (trigger time, priority, sub-tick order) order (29 §4.3), so two torches whose ticks are due together run in the order they were scheduled.

## 4. Doc schemas, ids and delays (for parts 2 to 8)

### 4.1 State-property table (every part uses this layout)

| Column | Content |
|---|---|
| Property | name as in the blockstate (`lit`, `power`, `facing`, ...) |
| Type | boolean, int range, or enum with the serialized names in order |
| Order | position in the state-index formula (24 part 1 §3 gives the formula: properties are sorted by name, the first property is the most significant digit, each digit runs in the property's value order) |
| Default | the default state's value |

### 4.2 Per-block row (every part uses this layout)

| Column | Content |
|---|---|
| Registry name | key in `minecraft:` |
| Class | the Java class, as in 24 |
| Block id, first state id, state count | absolute values from 24 part 8 (the id tables there), see 4.3 |
| Properties | 4.1 |
| Power output | which hook gives what, for which direction (2.1, 2.2) |
| Input rule | which query reads the inputs (2.3) |
| Delay | game ticks of every scheduled tick the block uses, with priority |
| Sound | the sound events the block plays, with volume and pitch, as read |

### 4.3 Ids

Block ids and state ids are assigned by registration order of the `Blocks` initializer (04 §5.1, 24 part 1 §2); state id = first state id + state index. The part-local last column of the tables in 24 parts 2 to 7 is an offset inside that part (for example `redstone_wire` shows 4992 in 24 part 2 and 5567 in 24 part 8; the difference 575 is the part's base, consistent across rows); this document uses the absolute values of 24 part 8. Item ids (the item `redstone` is the wire's item: block key `redstone_wire`, item key `redstone`) are in 25. Placement and `canSurvive` rules in general are 29 §9; update and removal hooks 29 §2.1.

| Block | Block id | First state id | States | Source |
|---|---|---|---|---|
| `redstone_wire` | 246 | 5567 | 1296 | 24 part 8 |
| `redstone_ore` | 320 | 8551 | 2 | 24 part 8 |
| `deepslate_redstone_ore` | 321 | 8553 | 2 | 24 part 8 |
| `redstone_torch` | 322 | 8555 | 2 | 24 part 8 |
| `redstone_wall_torch` | 323 | 8557 | 8 | 24 part 8 |
| `redstone_block` | 439 | 13078 | 1 | 24 part 8 |

Wire state index: `east * 432 + north * 144 + power * 9 + south * 3 + west`, side value digit up 0, side 1, none 2 (24 part 2). Default (all none, power 0): index 1160, state id 6727 (arithmetic from the two sources above). Torch: `lit` true is the first state, so `redstone_torch` lit = 8555 and unlit = 8556. Ore: `lit` default is false, and the first state is `lit` true, so lit = 8551 (8553 for deepslate) and unlit = 8552 (8554). Wall torch: index = `facing_index * 2 + (lit ? 0 : 1)` with the facing order north, south, west, east (read: the property is built by filtering the `Direction` constants in declaration order, and `Direction` is declared down, up, north, south, west, east, so the filtered order is north, south, west, east; this is not the `Plane.HORIZONTAL` iteration order north, east, south, west of 2.6 item 5, which is used only for iteration); default north, lit true.

### 4.4 Delay table (parts 2 to 8 fill in the rows they own; part 1 rows are final)

Delays in game ticks. "Priority" is the `TickPriority` name; "NORMAL" where the call has no priority argument.

| Block or event | Delay | Priority | Owner | Source |
|---|---|---|---|---|
| redstone torch: re-check after a neighbour change | 2 | NORMAL | this part | 8.4 |
| redstone torch: restart after burnout | 160 | NORMAL | this part | 8.3 |
| redstone wire | none (instant; no scheduled tick) | | this part | 5 |
| redstone block, redstone ore (randomly ticking, no scheduled tick) | none | | this part | 6, 7 |
| repeater, comparator | part 2 | | part 2 | |
| observer | part 2 | | part 2 | |
| piston (extend, retract), piston head events | part 3 | | part 3 | |
| dispenser, dropper, hopper | part 4 | | part 4 | |
| lever, button, pressure plate, daylight detector, target, lightning rod | part 5 | | part 5 | |
| rails (powered, activator, detector) | part 6 | | part 6 | |
| door, trapdoor, fence gate, lamp, copper bulb | part 7 | | part 7 | |
| note block | part 5 (section 8; `NoteBlock`, `NoteBlockInstrument`); neighbour-signal reader also listed in 30 part 8 section 9.3 | | part 5 | |
| sculk sensor, tripwire hook, bell, other | part 8 | | part 8 | |

## 5. Redstone wire (`RedstoneWireBlock`, block `redstone_wire`)

### 5.1 State and shape

| Property | Type | Values in order | Default |
|---|---|---|---|
| `north`, `east`, `south`, `west` | enum `RedstoneSide` | `up`, `side`, `none` (ordinals 0, 1, 2; `isConnected()` is true unless the value is `none`) | `none` |
| `power` | int | 0 to 15 | 0 |

The block has two derived states used as templates: `crossState` (all four sides `side`, power 0 here) and the default state (all `none`). The properties are registered in the order north, east, south, west, power (`createBlockStateDefinition`, read); the index formula of 4.3 is the sorted order.

Shapes (read in `makeShapes` and `Block.box`, `column`, `boxZ`; coordinates in sixteenths of a block, then divided by 16): `box(x0, y0, z0, x1, y1, z1)`; `column(10, 0, 1)` is `box(3, 0, 3, 13, 1, 13)`. Per-side shapes are rotated copies (`Shapes.rotateHorizontal`, whose input shape is the north one): the **side arm** `boxZ(10, 0, 1, 0, 8)` is `box(3, 0, 0, 13, 1, 8)` (north), and the **up arm** `boxZ(10, 16, 0, 1)` is `box(3, 0, 0, 13, 16, 1)` (north: a full-height strip on the north face). A state's shape is the dot `box(3, 0, 3, 13, 1, 13)` unioned with, for each horizontal side: nothing for `none`; the side arm for `side`; the side arm and the up arm for `up` (read: `makeShapes` passes the dot `column(10, 0, 1)` as the first captured argument of the per-state function, which starts from it). The shape is independent of `power`. The block is a no-collision, instant-break block (24 part 2 row 562).

### 5.2 Which neighbours connect

For the wire at `P` and a horizontal direction `d`, `getConnectingSide(level, P, d, allowUp)` (read) examines `N = P + d` with state `S`:

1. Let `canGoUp = allowUp`. `allowUp` is "the block above `P` is **not** a redstone conductor" for the two-argument form (`getConnectingSide(level, P, d)`; read).
2. If `canGoUp`: let `supports` be true when `S`'s block is a trapdoor (`TrapDoorBlock`) or `canSurviveOn(level, N, S)` (5.7: the top face of `S` is sturdy, or `S` is a hopper). If `supports` and `shouldConnectTo(level, N.above())` (the state above `N` is asked with `direction` null): the result is `up` when `S.isFaceSturdy(level, N, d.opposite)` (the face of `N` towards `P` is sturdy), otherwise `side`.
3. Otherwise (no climb): the result is `side` when `shouldConnectTo(S, level, N, d)` (that is `S.shouldRedstoneWireConnectTo(level, N, d)`), or when `S` is **not** a conductor and `shouldConnectTo(level, N.below())` (a wire or source diagonally below, with direction null) holds.
4. Otherwise `none`.

`shouldConnectTo(state, level, pos, direction)` is the block hook of 2.1: for a plain block it is `isSignalSource() and direction != null`; wire itself returns true; the observer and repeater override it (part 2: a repeater or observer connects only along its axis). The `direction == null` form (used for above and below tests) therefore connects only to wire and to blocks whose own override returns true for null; a block using the default hook does not connect through the diagonal tests (the default requires `direction != null`).

`getMissingConnections(level, state, P)` fills every horizontal side that is not yet connected in `state` with `getConnectingSide(level, P, d, !above(P).isRedstoneConductor)`; sides already connected are left as they are.

`getConnectionState(level, state, P)` (the resolver used by placement, by `updateShape` and by `getSignal`):

1. `wasDot` = `state` has all four sides `none`.
2. Start from the **default** state (all `none`) with the power of `state`, and run `getMissingConnections` on it (so all four sides are recomputed from the neighbours).
3. If `wasDot` and the result is again all `none`: return it (a dot stays a dot).
4. Let `n, s, e, w` be "connected" for the four sides of the result, `noNS = not n and not s`, `noEW = not e and not w`. If `not w and noNS`: west = `side`. If `not e and noNS`: east = `side`. If `not n and noEW`: north = `side`. If `not s and noEW`: south = `side`. (The tests use the booleans from the start of this step, so the four assignments are independent.) Effect: a wire with no connection at all becomes a cross (all four `side`) when it was not already a dot; a wire connected on one side only gets a stub on the opposite side, so a straight line shows both arms.
5. Return the result.

### 5.3 Placement, survival and shape updates

- **Placement** (`getStateForPlacement`): `getConnectionState(level, crossState, clickedPos)`. Because `crossState` is not a dot, the result is a cross when nothing connects.
- **Survival** (`canSurvive`): `canSurviveOn(level, P.below(), stateBelow)`: true when the **top** face of the block below is sturdy (`isFaceSturdy(UP)`) or the block below is a hopper. Otherwise the wire is dropped (5.6).
- **`updateShape(state, level, tickAccess, P, d, neighbourPos, neighbourState, random)`** (`d` is the direction towards the changed neighbour, 29 §3.2):
  1. `d == DOWN`: if `canSurviveOn(level, neighbourPos, neighbourState)` is false return air; else return `state`.
  2. `d == UP`: return `getConnectionState(level, state, P)`.
  3. Horizontal `d`: `side = getConnectingSide(level, P, d)` (the two-argument form). If `side.isConnected() == state[d].isConnected()` and `state` is not a cross: return `state` with `d` set to `side` (a cheap local update, including a change between `up` and `side`). Otherwise return `getConnectionState(level, crossState with power = state's power and d = side, P)`.
- **`updateIndirectNeighbourShapes(state, level, P, flags, budget)`** (29 §2.2 step 7 calls it for the old and the new state): for each horizontal `d` (NORTH, EAST, SOUTH, WEST) whose side in `state` is not `none`: let `N = P + d`; if the block at `N` is **not** wire: look at `N.below()`; if that is wire, send `neighborShapeChanged(d.opposite, below-position, P-side-pos, state-at-pos, flags, budget)` where the position passed is `N.below() + d.opposite` (that is `P.below()`), and the receiver's neighbour state is the block at that position; then the same for `N.above()` with `P.above()`. In plain terms: when a wire has a connection towards a non-wire block, the wires below and above that block (receivers at `N.below()` and `N.above()`) are sent a shape-change notification whose neighbour position is `P.below()` or `P.above()` and whose neighbour state is the block found there (the block under or over the sending wire, not the wire at P itself), so that their `up`/`side` connections refresh (the wires attach "across" a conductor). The calls use the neighbour-shape entry of the level (the shape-update queue of 29 §3.2).
- **Use** (`useWithoutItem`): returns PASS unless the player's abilities allow building (`mayBuild`). If the state is a cross or a dot: let `newState` = (cross ? default state : `crossState`) with the same power, passed through `getConnectionState(level, newState, P)`. If `newState` differs from `state`: `setBlockAndUpdate(P, newState)`, run `updatesOnShapeChange` (below) and return SUCCESS; else PASS. So right-clicking an isolated cross toggles it to a dot and back; a cross that has connections reduces to its resolved shape.
- **`updatesOnShapeChange(level, P, oldState, newState)`**: for each horizontal `d`: `N = P + d`; if the connected status of `d` differs between old and new, and the state at `N` is a conductor: `updateNeighborsAtExceptFromFacing(N, wireBlock, d.opposite)` (the neighbours of the conductor except the wire itself, 29 §3.1).
- **Rotation and mirror** (read): `CLOCKWISE_90` moves the old value of `north` to `east`, `east` to `south`, `south` to `west`, `west` to `north`; `COUNTERCLOCKWISE_90` moves `north` to `west`, `west` to `south`, `south` to `east`, `east` to `north`; `CLOCKWISE_180` swaps `north` with `south` and `east` with `west`; no rotation leaves the state. Mirror `LEFT_RIGHT` swaps `north` and `south`; `FRONT_BACK` swaps `east` and `west`; `power` is untouched.

### 5.4 Power computation (the default evaluator, `DefaultRedstoneWireEvaluator`)

Stored power is the `power` property. `updatePowerStrength(level, P, state, orientation, createdOrRemoved)` calls the evaluator. In steps:

1. **Target.** `blockSignal = getBlockSignal(level, P)`: set `shouldSignal = false`, compute `level.getBestNeighborSignal(P)` (2.3), set `shouldSignal = true`, return the value. If `blockSignal == 15` the target is 15. Otherwise the target is `max(blockSignal, incoming)` where `incoming` is the **incoming wire signal** below.
2. **Incoming wire signal** (`getIncomingWireSignal`). `r = 0`. For each horizontal `d` (NORTH, EAST, SOUTH, WEST), with `N = P + d` and `S` the state at `N`:
   1. `r = max(r, wirePower(N, S))`, where `wirePower` is the `power` of `S` when `S` is this wire block and 0 otherwise.
   2. Let `A = P.above()`. If `S` is a conductor and the block at `A` is **not** a conductor: `r = max(r, wirePower(N.above(), state at N.above()))` (a wire on top of the adjacent conductor).
   3. Else if `S` is **not** a conductor: `r = max(r, wirePower(N.below(), state at N.below()))` (a wire diagonally below the adjacent non-conductor).
   Return `max(0, r - 1)`.
3. **Apply.** If the target differs from the stored `power`: if the block at `P` is still `state` (the same state object, read as an identity test), `setBlock(P, state with power = target, flags 2)` (clients only: no neighbour update, no shape update from this write). Then build a hash set holding `P` followed by the six neighbours `P + d` for `d` in `Direction.values()` order (DOWN, UP, NORTH, SOUTH, WEST, EAST), and for each element of the set in the **set's iteration order** call `level.updateNeighborsAt(element, wireBlock)`. If the target equals the stored power nothing happens (no notification).
4. The iteration order of that hash set is the Java `HashSet` order for `BlockPos` keys (this is behaviour: it fixes the order of the seven updates). `BlockPos.hashCode` is `(y + z * 31) * 31 + x` (read in `Vec3i`, 32-bit signed arithmetic). The set is created with the default 16 buckets and holds 7 elements, so no resize happens; an element's bucket is `(h ^ (h >>> 16)) & 15`, buckets are visited in increasing index, and elements sharing a bucket are visited in insertion order (the order P, DOWN, UP, NORTH, SOUTH, WEST, EAST; the standard `HashSet` behaviour is assumed for the bucket rule, recalled, not verified in the jar: Open question 2). For coordinates with small absolute values (`h < 65536`) the spread is the identity. Worked example in 9.2.

### 5.5 The three hooks that call the evaluator, and removal

- **`onPlace(state, level, P, oldState, moved)`**: if the old state is the same block, or on a client level: nothing. Otherwise: `updatePowerStrength(level, P, state, null, true)`; then for `d` in VERTICAL (UP, DOWN): `updateNeighborsAt(P + d, wireBlock)`; then `updateNeighborsOfNeighboringWires(level, P)`.
- **`affectNeighborsAfterRemoval(state, level, P, moved)`**: when `moved` is true (a piston move) nothing is done. Otherwise: for every `d` in `Direction.values()`: `updateNeighborsAt(P + d, wireBlock)`; then `updatePowerStrength(level, P, state, null, false)`; then `updateNeighborsOfNeighboringWires(level, P)`. (This runs for the **old** state after the block has been replaced, 29 §2.1 step 9, so the "wire" being evaluated is gone and the call recomputes with the new block at `P`; the evaluator guards the write with the state-identity test of step 3.)
- **`updateNeighborsOfNeighboringWires(level, P)`**: for `d` in HORIZONTAL: `checkCornerChangeAt(level, P + d)`. Then for `d` in HORIZONTAL with `N = P + d`: if the state at `N` is a conductor: `checkCornerChangeAt(level, N.above())`; else `checkCornerChangeAt(level, N.below())`.
- **`checkCornerChangeAt(level, X)`**: if the block at `X` is not wire: return. Otherwise `updateNeighborsAt(X, wireBlock)` and, for every `d` in `Direction.values()`, `updateNeighborsAt(X + d, wireBlock)`.
- **`neighborChanged(state, level, P, sourceBlock, orientation, moved)`**: on a client level nothing. On a default world (the experimental flag is off) the source block is not tested. If `state.canSurvive(level, P)`: `updatePowerStrength(level, P, state, orientation, false)`. Otherwise `Block.dropResources(state, level, P)` and `level.removeBlock(P, false)` (the wire pops off when its support is gone).
- **The `shouldSignal` flag** is a field of the block object, shared by every wire of the process. It is `true` normally, and `false` only for the duration of one `getBlockSignal` call (single-threaded server tick). `getDirectSignal` returns 0 when it is false, otherwise `state.getSignal(level, P, d)`; `isSignalSource` returns the flag; `getSignal` returns 0 when the flag is false or `d == DOWN`.

### 5.6 What the wire outputs

`getSignal(state, level, P, d)` (read):

1. If `shouldSignal` is false or `d == DOWN`: return 0.
2. `p = power`. If `p == 0` return 0.
3. If `d == UP`: return `p`.
4. Otherwise (`d` horizontal): compute `getConnectionState(level, state, P)` and read its side for `d.opposite` (the side facing the receiver); return `p` when that side is connected, else 0.

`getDirectSignal(state, level, P, d)`: 0 when `shouldSignal` is false, otherwise the same value as `getSignal` above. `ownSignal` is the stored `power`. `isSignalSource` returns `shouldSignal`. So wire gives power to: the block it lies on (`d == UP` at the receiver), and each horizontal neighbour towards which it points (its own connection towards the receiver), and, through the conductor rule of 2.3, a conductor it points at passes the value on. The directional rule means a side wire does **not** power a neighbour that it does not connect to: with the resolved shape of 5.2 step 4 a straight wire still gives power along its axis ends.

`shouldRedstoneWireConnectTo` of wire is always true. `canSurviveOn` is 5.3.

### 5.7 Particles and colour table

Client only. `animateTick(state, level, P, random)`: if `power == 0` return. For each horizontal `d` (NORTH, EAST, SOUTH, WEST) read the side: `up` (ordinal 1 in the switch): call the line-spawner with the colour of the power, base direction `d`, line direction UP, range -0.5 to 0.5, then, falling through, with line direction DOWN, range 0.0 to 0.5. `side`: only the DOWN call with range 0.0 to 0.5. `none`: one DOWN call with range 0.0 to 0.3. (The `none` branch also is the switch default.)

The line-spawner (`spawnParticlesAlongLine(level, random, P, color, dirA, dirB, from, to)`): let `len = to - from`. Draw `random.nextFloat()`; if it is **at least** `0.2 * len`, return (so the chance is `0.2 * len`; `PARTICLE_DENSITY` 0.2). Else draw `t = from + random.nextFloat() * len` (a second `nextFloat`). Position: `x = P.x + 0.5 + 0.4375 * dirA.stepX + t * dirB.stepX` and the same for y and z with their steps (0.4375 is the float constant read). Add the particle `DustParticleOptions(color, 1.0)` with velocity (0, 0, 0). Consequence of the draw order: the first `nextFloat` is the chance test, the second is `t`.

Colour table (`COLORS[0..15]`, built once in the static initializer; for `p` = 0 to 15, `f = p / 15` as float, all arithmetic in float): red `= f * 0.6 + (f > 0 ? 0.4 : 0.3)`; green `= clamp(f * f * 0.7 - 0.5, 0, 1)`; blue `= clamp(f * f * 0.6 - 0.7, 0, 1)`; alpha 1; each channel to 8 bits by `floor(c * 255)` (`ARGB.colorFromFloat(1, r, g, b)`, `as8BitChannel` read). Result (hand-computed in single-precision emulation; the bytecode itself was not executed):

| Power | RGB | Power | RGB |
|---|---|---|---|
| 0 | `#4C0000` | 8 | `#B70000` |
| 1 | `#700000` | 9 | `#C10000` |
| 2 | `#7A0000` | 10 | `#CC0000` |
| 3 | `#840000` | 11 | `#D60000` |
| 4 | `#8E0000` | 12 | `#E00000` |
| 5 | `#990000` | 13 | `#EA0600` |
| 6 | `#A30000` | 14 | `#F41B00` |
| 7 | `#AD0000` | 15 | `#FF3200` |

The colour is also the wire's tint (`getColorForPower`, used by the block colour provider; tint classes are 43). The wire texture itself is data (assets).

## 6. Redstone block (`PoweredBlock`, block `redstone_block`)

Class `PoweredBlock extends Block` with no state. `isSignalSource` returns true; `ownSignal` returns 15. The default `getSignal` therefore returns 15 in every direction (including towards the block below, unlike wire), and `getDirectSignal` stays 0 (default). It is **not** a conductor (`redstoneConductor:never`, 2.4, 24 part 5), so it does not strongly power neighbours and it does not carry power from other sources. It has no tick, no neighbour hook and no placement rule beyond the default. Wire connects to it sideways because `shouldRedstoneWireConnectTo` default is true for a signal source (`direction` not null). `getControlInputSignal` returns 15 for it directly (2.3). Hardness 5.0, resistance 6.0, `FIRE` map colour, `METAL` sound, `PUSH_PULL` (24 part 5 row 439).

## 7. Redstone ore (`RedStoneOreBlock`, blocks `redstone_ore`, `deepslate_redstone_ore`)

The ore gives no power; it is part of this document because its `lit` state drives light and particles. Property `lit` (boolean), default false (the constructor sets it to false; the first state in the index order is `lit` true). Light 9 when lit (24 part 3). Behaviour (all read):

| Trigger | Server | Client |
|---|---|---|
| `attack` (the player starts hitting it) | `interact` then the default attack | same call (particles and `interact`) |
| `stepOn` (an entity steps on it) | if the entity is **not** stepping carefully (not sneaking): `interact`; then the default `stepOn` | |
| `useItemOn` | `interact`, then: if the held item is a `BlockItem` and a `BlockPlaceContext` built from the hit says `canPlace()`: result PASS (so placement continues), else SUCCESS | `spawnParticles` only; the same PASS/SUCCESS decision |
| `interact(state, level, pos)` | `spawnParticles(level, pos)`; if `lit` is false: `setBlockAndUpdate(pos, state with lit = true)` | |
| `isRandomlyTicking` | true only when `lit` | |
| `randomTick` | if `lit`: `setBlockAndUpdate(pos, state with lit = false)` | |
| `animateTick` | | if `lit`: `spawnParticles` |
| `spawnAfterBreak(state, level, pos, tool, dropExperience)` | the default; then when `dropExperience`: `tryDropExperience(level, pos, tool, UniformInt(1, 5))` (the experience rule is 29 §10.5) | |

`spawnParticles(level, pos)`: for each of the six `Direction.values()`: let `n = pos + d`; if the state at `n` is solid-rendering (`isSolidRender`) skip this direction. Otherwise the particle position is, per axis: if `d`'s axis equals this axis, `0.5 + 0.5625 * step` (the block face plus 0.0625), else a fresh `level.getRandom().nextFloat()`; the draw order is x, y, z and a random value is drawn only for the axes that need one. Spawn `DustParticleOptions.REDSTONE` at `(pos.x + x, pos.y + y, pos.z + z)` with velocity 0. Drops, hardness and tool rules are in 24 part 3 (hardness 3.0 and 4.5 for deepslate; drop `redstone` 4 to 5 with fortune).

## 8. Redstone torches (`RedstoneTorchBlock`, `RedstoneWallTorchBlock`)

### 8.1 State

`redstone_torch`: property `lit`, default true. `redstone_wall_torch`: properties `facing` (horizontal) and `lit`; default `facing` north, `lit` true. Shape, survival and placement come from the torch base classes (`BaseTorchBlock`, `WallTorchBlock`): the standing torch needs the block below to support the cell centre from above, the wall torch needs the neighbour at `pos + facing.opposite` to have a sturdy face towards `facing` (24 part 3). The wall torch's `updateShape`: when the direction passed is `facing.opposite` and `canSurvive` is false return air, else the state. Its `getStateForPlacement` takes the placement state of the plain `wall_torch` block (24 part 3's wall torch rule) and copies its `facing` onto the redstone wall torch default state; if the plain wall torch has no state, there is none. `rotate` rotates `facing`; `mirror` applies the mirror's rotation to the state.

### 8.2 Notifying neighbours

`notifyNeighbors(level, pos, state)`: for each `d` in `Direction.values()` (DOWN, UP, NORTH, SOUTH, WEST, EAST) in that order, `level.updateNeighborsAt(pos + d, thisBlock)` (with an `Orientation` argument only in the experimental mode: `randomOrientation`, which for the standing torch is `initialOrientation(level, null, UP)` and for the wall torch `initialOrientation(level, facing.opposite, UP)`). Each call tells the six neighbours of `pos + d`, so the torch's own position is told once per call as well and a block two steps away is also told. Callers: `onPlace` (always) and `affectNeighborsAfterRemoval` (when the removal is **not** a piston move). The torch therefore announces both its placement and its removal to everything within one block of its neighbours, which is what makes the block above, the sideways wires, and the blocks diagonal to the torch update.

### 8.3 The inverter, the tick, burnout

Constants (read): `RECENT_TOGGLE_TIMER` 60, `MAX_RECENT_TOGGLES` 8, `RESTART_DELAY` 160, `TOGGLE_DELAY` 2.

**Input** (`hasNeighborSignal(level, pos, state)`): standing torch: `level.hasSignal(pos.below(), DOWN)`, that is, the block it stands on is powered (a conductor with strong power around it, or weakly powered through `getSignal(pos.below(), DOWN)` of 2.3). Wall torch: `level.hasSignal(pos + facing.opposite, facing.opposite)`: the block it is attached to is powered. The test is the level query of 2.3 on that **attachment block**, not on the torch's other sides. Read in the bytecode: one local holds `facing.opposite`, and that same local is both the argument to `pos.relative(...)` and the second argument of `hasSignal` (no other direction is used). Worked example: a wall torch at (0, 64, 0) with `facing` north is attached to the block to its south at (0, 64, 1); `facing.opposite` is south; the input is `hasSignal((0,64,1), SOUTH)`, which asks whether (0,64,1) receives power as seen from the torch's side (2.3: strong power from any of the six sides, or weak power from the neighbour in direction SOUTH). The torch's output side is the mirror: `getSignal(NORTH)` is 0 because `d == facing`.

**Output.** Standing torch: `isSignalSource` true; `ownSignal` is 15 when lit and 0 when unlit; `getSignal(d)` is `ownSignal` for every `d` except `UP` (0): a torch does not weakly power the block it stands on. `getDirectSignal(d)` is `getSignal(d)` when `d == DOWN` and 0 otherwise, so a torch strongly powers only the block **above** it (that block asks with DOWN, 2.2). Wall torch: the same except `getSignal(d)` returns 0 when `d == facing` (the block it is attached to is not weakly powered), else `ownSignal`; `getDirectSignal` is inherited unchanged (strong power to the block above). The standard 15 is a constant; the power never varies.

**`neighborChanged(state, level, pos, source, orientation, moved)`**: if `lit == hasNeighborSignal(level, pos, state)` and the level's block tick queue does not report `willTickThisTick(pos, thisBlock)`: `level.scheduleTick(pos, thisBlock, 2)` (NORMAL priority). In words: when the torch is lit but its attachment is powered, or unlit but not powered, it wants to flip, and one tick is queued 2 game ticks ahead (not when one is already due this very tick; 29 §4.3).

**`tick(state, level, pos, random)`** (a block tick of 29 §4.3):

1. `powered = hasNeighborSignal(level, pos, state)`.
2. Prune the level's toggle list (below) for this level: while it is non-empty and `gameTime - first.when > 60`, remove the first entry.
3. If the state is lit:
   1. If `powered`: `setBlockAndUpdate(pos, state with lit = false)`. Then `isToggledTooFrequently(level, pos, true)` (this records the toggle, below). If it returns true: `levelEvent(1502, pos, 0)` (the burnout effect, 8.5) and schedule a tick for the block **now at** `pos` with delay 160 (NORMAL).
   2. If not `powered`: nothing.
4. If the state is unlit: if **not** `powered` and `isToggledTooFrequently(level, pos, false)` is false: `setBlockAndUpdate(pos, state with lit = true)`. (While burned out, the check keeps the torch off even when its input has dropped; the tick scheduled in 3.1 at +160 is the retry.)

**The toggle list.** `RECENT_TOGGLES` is a weak-key map from the level object to a list of records `(pos, when)` (`when` is the game time). `isToggledTooFrequently(level, pos, record)` gets or creates the level's list; when `record` is true it appends `(pos.immutable(), gameTime)`; then it counts the entries in the whole list whose `pos` equals this `pos` (block position equality) and returns true as soon as the count reaches 8. The list is global to the level and not saved (it is a static map): after a restart the count is empty (inferred: the map is a static field, nothing writes it to disk). The list is pruned (step 2) only from its head, by age more than 60 game ticks, at the start of every torch tick of that level, so the entries of all torches share one chronological list. Count rule: with 8 entries of the same position within the prune window, the 8th recording returns true, so the 8th unlit transition burns the torch out.

### 8.4 One flip cycle in detail

A lit torch whose attachment block becomes powered: `neighborChanged` queues a tick at +2. At +2 the tick writes `lit = false` with `setBlockAndUpdate` (flags 3). Inside that write, in the order of 29 §2.1 and §2.2: the chunk write runs the new state's `onPlace`, which is the torch's `notifyNeighbors` (8.2, the wide announcement), then flag 1 tells the six neighbours with the old block as source, then the clients are sent the block. Wire above and beside, and the block above (which was strongly powered), re-evaluate in that cascade. When the attachment loses power the unlit torch's `neighborChanged` queues a tick at +2, and that tick (step 4 of 8.3) relights it unless it is burned out. So every toggle runs both the wide announcement and the six-neighbour update.

### 8.5 Burnout effect (client, level event 1502; `LevelEventHandler`)

On the client the event plays `REDSTONE_TORCH_BURNOUT` at the block position (not distance-delayed), source `BLOCKS`, volume 0.5, pitch `2.6 + (random.nextFloat() - random.nextFloat()) * 0.8` (two draws, first minus second), and then spawns 5 `SMOKE` particles with velocity 0 at `(x + a * 0.6 + 0.2, y + b * 0.6 + 0.2, z + c * 0.6 + 0.2)`, where `a, b, c` are three draws of `random.nextDouble()` in the order x, y, z, once per particle (read: each axis is `pos + nextDouble * 0.6 + 0.2`, a multiply then two adds, one draw per axis; the sound call has distance delay false). The packet itself is a Level Event packet (05a, 29 §7.4).

### 8.6 Torch particles (client, `animateTick`)

Only when lit. Standing torch: one `DustParticleOptions.REDSTONE` at `(x + 0.5 + (r1 - 0.5) * 0.2, y + 0.7 + (r2 - 0.5) * 0.2, z + 0.5 + (r3 - 0.5) * 0.2)` with three draws of `nextDouble` in the order x, y, z, velocity 0. Wall torch: `d = facing.opposite`; `x + 0.5 + (r1 - 0.5) * 0.2 + 0.27 * d.stepX`, `y + 0.7 + (r2 - 0.5) * 0.2 + 0.22`, `z + 0.5 + (r3 - 0.5) * 0.2 + 0.27 * d.stepZ`, same draw order.

## 9. Worked examples

### 9.1 A strong-power chain

A redstone block `B` at (0, 64, 0) is a signal source of 15 but a non-conductor, and gives `getSignal` 15 in all directions, `getDirectSignal` 0.

- A wire at (1, 64, 0) is a neighbour of `B` (east of it). The wire computes `getBestNeighborSignal((1,64,0))`: for `d` = WEST it asks `getSignal((0,64,0), WEST)`. The state is `redstone_block`: `getSignal` (default) = `ownSignal` = 15; `B` is not a conductor so the result is 15; `getBestNeighborSignal` returns 15 immediately. Target 15 (5.4 step 1 stops at 15). The wire's power becomes 15. Its connection towards `B` is `side` because `B` is a signal source (5.2 step 3).
- A wire at (2, 64, 0) east of the first has `blockSignal` 0 (no source adjacent) and `incoming` = `max(0, 15 - 1)` = 14. Its power becomes 14. Each further wire loses 1.

### 9.2 The update order of a wire power change at (5, 64, 3)

When the wire at (5, 64, 3) changes power, seven positions are told, in the `HashSet` order. Hashes (`(y + 31 z) * 31 + x`): P (5,64,3) 4872; DOWN (5,63,3) 4841; UP (5,65,3) 4903; NORTH (5,64,2) 3911; SOUTH (5,64,4) 5833; WEST (4,64,3) 4871; EAST (6,64,3) 4873. Buckets (hash & 15, values below 65536): P 8, DOWN 9, UP 7, NORTH 7, SOUTH 9, WEST 7, EAST 9. Visit order: bucket 7 in insertion order (UP, NORTH, WEST), bucket 8 (P), bucket 9 (DOWN, SOUTH, EAST). So `updateNeighborsAt` is called for: UP, NORTH, WEST, P itself, DOWN, SOUTH, EAST. The calls are queued depth first (29 §3.3): each call is one top-level cascade when not already nested; when the wire change was itself raised inside a cascade, all seven enter the shared queue as nested entries appended to the layer, and run after the current notification finishes.

### 9.3 Redstone torch burnout

Torch `T` stands at (0, 64, 0) on a stone block powered by a clock. Game time 100: the block is powered; `neighborChanged` schedules a tick for 102. At 102: `powered`; `lit` true; set `lit` false; `isToggledTooFrequently(level, pos, true)` records (pos, 102); count is 1; false. At 104 the block is unpowered; `neighborChanged` (unlit == not powered is false... for unlit the condition is `lit == hasNeighborSignal`, that is `false == false`, true) schedules 106; at 106 `not powered` and `isToggledTooFrequently(..., false)` (count 1) is false: set `lit` true. Assume the clock keeps this cadence: the input is powered at 100, 108, 116, ... and unpowered at 104, 112, ...; the off-transitions then fall at 102, 110, 118, ... so their spacing is P = 8 ticks (the tick fires 2 after each power-up). In general the eighth recording is at 102 + 7 * P, which for P = 8 is 158; the count reaches 8 within the 60-tick window (the prune only drops entries older than 60 ticks: 158 - 102 = 56), so at 158 the torch is turned off, level event 1502 fires, and a tick is scheduled for 158 + 160 = 318 (in general 102 + 7 * P + 160). With P = 4 (a faster clock) the same rule gives 130 and 290; the worked example uses P = 8. At 318 the torch is unlit and not powered only if its input has dropped; the check `isToggledTooFrequently(..., false)` counts entries whose age is at most 60 after pruning at the start of the tick: all were older than 60 (158 + 160 > 60), so they are pruned and the count is 0; the torch lights.

### 9.4 Wire shape resolution

A wire placed on a block with a lever block (a signal source) on its east side and nothing else: `getMissingConnections` marks east `side` (the lever is a signal source: 5.2 step 3). `n = false, s = false, e = true, w = false`. `noNS` true, `noEW` false (e is connected). West: `not w and noNS` true, so west = `side`. East: `not e` false, keep. North: `not n and noEW` false. South: same false. Result: east and west `side`: a straight line. A wire with no neighbours at all: nothing connected, `wasDot` of the template (`crossState`) false, so step 3 does not return; all four become `side` by step 4 (west by the `noNS` rule, east likewise, north and south by the `noEW` rule): a cross.

## 10. Validation

1. The bit-level constants of 2.3 (the six directions in `getDirectSignalTo`, `hasNeighborSignal`, the early return at 15 in `getBestNeighborSignal` and `getDirectSignalTo`) were checked against the bytecode.
2. Wire: the dot and cross rules, the four assignments of 5.2 step 4 and their variables (`n` 5, `s` 6, `e` 7, `w` 8, `noNS` 9, `noEW` 10 in the local-variable table) were checked line by line; the evaluator's step 3 write flag 2 and the set order were read.
3. The colour table was computed by a single-precision emulation of the read formula; an implementation should compare its table with the 16 values above.
4. Torch: constants 60, 8, 160, 2 and the order of tick steps were read.
5. Cross checks: the state counts 1296, 2, 2, 2, 8, 1 agree with 24; the state index formula and default 1160 agree with 24 part 2; the conductor flags agree with 24 parts 1 and 5.
6. Tests an implementer should write: 9.1 (wire chain 15, 14, 13), 9.2 (order), 9.3 (burnout at game time 158 with off-transition spacing 8, retry at 318), a wire placed with no neighbours (cross), a wire next to a repeater (part 2), a torch below a conductor with power both from above and below.

## 11. Open questions

1. The experimental redstone evaluator (`ExperimentalRedstoneWireEvaluator`, `Orientation`, `Orientation.SideBias`, `ExperimentalRedstoneUtils`) is not specified. It is only active when the `redstone_experiments` flag is enabled (2.7); how a world enables it is registry and pack territory and was not traced.
2. The `HashSet` bucket rule used in 5.4 step 4 (16 buckets, spread `h ^ (h >>> 16)`, insertion order inside a bucket, no resize at 7 elements) is the standard `java.util.HashSet` behaviour (recalled, not verified in the artifact; `HashSet` is JDK code and not in the jar). If the order differs, only the order of the seven neighbour updates changes.
3. The list in 2.4 was read from the 26 `isRedstoneConductor` call sites of `Blocks` (24 never, 2 always). Not resolved: whether the waxed copper-grate and copper-bulb variants share the weathering lambdas (inferred), and whether a block class overrides conductor behaviour outside `Properties` (searched only `Blocks`). The flags rows of 24 for glass, ice, tnt and the others in the table were not re-searched; 24 should be checked against 2.4.
4. (closed: facing order read, see 4.3.)
5. (closed: burnout smoke arithmetic read, see 8.5.)
6. (closed: wire dot shape read, see 5.1.)
7. `Level.updateNeighborsAt`'s orientation argument and the `REDSTONE_EXPERIMENTS` branches of the torch (`randomOrientation`) are described but not specified (open question 1).
8. The sound of wire, torch and ore placement (`SoundType`) is in 24 and was not re-read here.
9. `getSignal` for blocks other than the ones read here (comparator, repeater, observer, lever, plates, and so on) belongs to the sibling parts; the census in 2.5 lists the classes only.
10. The per-hook class tables of 2.5 rest on the reader's own scan of the declared methods and were not independently re-derived in the review round. The sibling-owned components (repeater, comparator, observer, pistons, dispensers, sensors, rails and others) are specified only in their own parts, which need their own review; part 1 covers them by the census alone.
