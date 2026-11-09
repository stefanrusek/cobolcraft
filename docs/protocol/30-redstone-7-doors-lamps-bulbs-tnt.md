# 30 (part 7). Redstone: power-driven openable blocks, lamps, copper bulbs and TNT

| | |
|---|---|
| Covers | The behaviour of the blocks that react to a neighbouring redstone signal without emitting one: `DoorBlock` (every wood door, the iron door, the copper doors and the waxed copper doors) and `WeatheringCopperDoorBlock`; `TrapDoorBlock` (wood, iron, copper, waxed copper) and `WeatheringCopperTrapDoorBlock`; `FenceGateBlock` (every wood type); `RedstoneLampBlock`; `CopperBulbBlock` and `WeatheringCopperBulbBlock`; `TntBlock` (ignition by power, by fire, by projectile, by explosion, by hand, by dispenser) and the creation of the primed TNT entity. Also the two data classes they share: `BlockSetType` and `WoodType` (their sounds and flags). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS12 (GAP-10c of `../design/README.md` Part 5), part 7 of the redstone split. |
| Data versus code | Block loot tables (door lower-half condition, TNT `unstable` condition), tags (`doors`, `wooden_doors`, `trapdoors`, `walls`, `mineable/*`), `sounds.json`, block models and blockstate files are DATA and are not tabulated. This document specifies the engines and the code-defined constants (state machines, flags, sounds by event name, shapes). Block ids and state ids are in 24 and 46. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions.

Related documents: the signal model (`hasNeighborSignal`, `getSignal`, strong and weak power, the conductor rule) is 30-redstone-1 §2; update flags, the `setBlock` pipeline, neighbour and shape updates, scheduled ticks and interaction results are 29 §§1 to 4 and 8 to 9; the oxidation and wax engines of the copper variants are 29b-5 §§4 to 7 (part 5 of document 29b, `29b-falling-growth-fire-5-fungi-moss-copper.md`); the block rows (ids, state counts, shapes, hardness) are 24 parts 2 to 8; the primed TNT entity row and its tick are 21 §8.3; fire spread is 29b-3; the comparator reading a bulb is 30-redstone-2 (sections not cited: the part was not searched for a bulb row); dispensers are 30-redstone-4 (section not cited, Open question 11); the plate and button set-type use is 30-redstone-5 §4. Cross-reference form in this document: `NN §x.y` for a numbered document, `NN-redstone-P §x.y` for a part of document 30, `24 part P §x.y` for a part of the block registry. This document does not repeat them.

## 0. Reader's map

| Question | Section |
|---|---|
| Sound, game event, flag and signal conventions common to these blocks | 1 |
| `BlockSetType` and `WoodType` tables | 2 |
| Door: state, placement, hinge, double door, open by hand, power, half pairing, wind charge, shape | 3 |
| Trapdoor | 4 |
| Fence gate | 5 |
| Redstone lamp (4-tick turn-off delay) | 6 |
| Copper bulb, weathering and waxed variants, comparator output | 7 |
| Per-block table of ids, delays and sounds | 2a |
| TNT and primed TNT creation | 8 |
| Corrections to other documents | 9 |
| Worked examples | 10 |
| Validation | 11 |
| Open questions | 12 |

## 1. Shared conventions

1. **Signal query.** All blocks of this document ask `Level.hasNeighborSignal(pos)` (`SignalGetter`): true when, for each of the six directions `d` in the order DOWN, UP, NORTH, SOUTH, WEST, EAST, `getSignal(pos + d, d) > 0`; it returns at the first hit. `getSignal(p, d)` is the maximum of the block's `getSignal(level, p, d)` and, when the block at `p` is a redstone conductor, the strong power delivered to `p` (`getDirectSignalTo(p)`). Read in `SignalGetter`; the details are 30-redstone-1 §2.3. The door additionally asks the same query at the other half (3.5).
2. **Sound call.** Every sound below is played with `Level.playSound(excluded entity, blockPos, event, source BLOCKS, volume, pitch)`, which plays at the block centre `(x + 0.5, y + 0.5, z + 0.5)`. The excluded entity is the acting player (so the actor's own client keeps its predicted sound) or null for redstone, explosions and mobs. Doors, trapdoors and gates use volume 1.0 and pitch `random.nextFloat() * 0.1f + 0.9f` (range 0.9 to 1.0, one `nextFloat` draw on the level's random source per sound, read). The copper bulb uses the four-argument form, whose defaults are volume 1.0 and pitch 1.0 (read in `LevelAccessor.playSound`).
3. **Game events.** Opening emits `BLOCK_OPEN`, closing `BLOCK_CLOSE` (`Level.gameEvent(entity, event, pos)`; entity = the actor or null). TNT priming emits `PRIME_FUSE` at the block position; the dispenser TNT item emits `ENTITY_PLACE`; the flint and steel dispenser branch for a non-TNT target emits `BLOCK_CHANGE` (not part of this document). Who listens (vibration frequencies, sculk) is outside this document (Open question 7).
4. **Flags used** (29 §1): hand toggles of doors and gates use 10 (`UPDATE_CLIENTS` + `UPDATE_IMMEDIATE`: clients are told, neighbours are not notified, shape updates run); redstone writes of doors, trapdoors, gates and the lamp use 2 (clients only; shape updates run; no neighbour notification); trapdoor hand toggle uses 2; bulb and gate-explosion writes use `setBlockAndUpdate` (3); TNT removal uses `removeBlock(pos, false)` (3, replaced by the fluid's block or air).
5. **Server only.** `neighborChanged` of the trapdoor, gate and lamp returns at once on a client level; the bulb acts only when the level is a `ServerLevel`; the door's `neighborChanged` has no client test (it runs on both sides in the artifact, but only the server write is authoritative, since clients receive the resulting state).
6. **Orientation.** `neighborChanged` carries an `Orientation` parameter (the experimental wire evaluator, 30-redstone-1 §2.7). None of the blocks of this document reads it.

## 2. `BlockSetType` and `WoodType`

`BlockSetType` (a record read in full) carries: `name`, `canOpenByHand`, `canOpenByWindCharge`, `canButtonBeActivatedByArrows`, `pressurePlateSensitivity` (`EVERYTHING` or `MOBS`), `soundType` (the block's `SoundType`), `doorClose`, `doorOpen`, `trapdoorClose`, `trapdoorOpen`, `pressurePlateClickOff/On`, `buttonClickOff/On`. The single-argument constructor (used by oak, spruce, birch, acacia, jungle, dark_oak, pale_oak, poplar, mangrove) sets the three flags true, sensitivity `EVERYTHING`, `SoundType.WOOD` and the wooden sound events. The door and trapdoor constructors of doors, trapdoors and gates take the block's `SoundType` from the set type (`DoorBlock`, `TrapDoorBlock`: `BlockSetType.soundType`); the fence gate takes its `SoundType` from the `WoodType` (`WoodType.soundType`).

`BlockSetType` also has a private static name-to-type map (`TYPES`, filled by the constructor with each created set type under its `name`), a public `CODEC` over it (a set type is resolved by its name string when data names one) and a `values()` stream; the 18 set types below are the entries it holds in creation order (V3). No block in this document goes through the codec; the blocks reference the static fields.

The plate and button columns were read in the same static initializer. Sensitivity is `MOBS` for `stone` and `polished_blackstone` and `EVERYTHING` for every other set type, including iron, copper and gold (agrees with 30-redstone-5 §4.2 and §4.3). Plate and button click events by set type: `iron`, `copper`, `gold` use `METAL_PRESSURE_PLATE_CLICK_OFF/ON` with `STONE_BUTTON_CLICK_OFF/ON`; `stone` and `polished_blackstone` use `STONE_PRESSURE_PLATE_CLICK_OFF/ON` with `STONE_BUTTON_CLICK_OFF/ON`; `cherry` uses `CHERRY_WOOD_PRESSURE_PLATE_*` and `CHERRY_WOOD_BUTTON_*`; `crimson` and `warped` use `NETHER_WOOD_PRESSURE_PLATE_*` and `NETHER_WOOD_BUTTON_*`; `bamboo` uses `BAMBOO_WOOD_PRESSURE_PLATE_*` and `BAMBOO_WOOD_BUTTON_*`; the nine plain woods (oak, spruce, birch, acacia, jungle, dark_oak, pale_oak, poplar, mangrove) use the wooden defaults of the single-argument constructor. The click events are read as field names of `SoundEvents`; their registry strings were not re-read here. Columns relevant to this document (flags are in the order hand, wind charge, arrows):

| Set type | Flags | Block `SoundType` | Door close / open (event names) | Trapdoor close / open |
|---|---|---|---|---|
| `iron` | false, false, false | IRON | `block.iron_door.close` / `.open` | `block.iron_trapdoor.close` / `.open` |
| `copper` | true, true, false | COPPER | `block.copper_door.close` / `.open` | `block.copper_trapdoor.close` / `.open` |
| `gold` | false, true, false | METAL | `block.iron_door.*` | `block.iron_trapdoor.*` |
| `stone` | true, true, false | STONE | `block.iron_door.*` | `block.iron_trapdoor.*` |
| `polished_blackstone` | true, true, false | STONE | `block.iron_door.*` | `block.iron_trapdoor.*` |
| `oak`, `spruce`, `birch`, `acacia`, `jungle`, `dark_oak`, `pale_oak`, `poplar`, `mangrove` | true, true, true | WOOD | `block.wooden_door.close` / `.open` | `block.wooden_trapdoor.close` / `.open` |
| `cherry` | true, true, true | CHERRY_WOOD | `block.cherry_wood_door.*` | `block.cherry_wood_trapdoor.*` |
| `crimson`, `warped` | true, true, true | NETHER_WOOD | `block.nether_wood_door.*` | `block.nether_wood_trapdoor.*` |
| `bamboo` | true, true, true | BAMBOO_WOOD | `block.bamboo_wood_door.*` | `block.bamboo_wood_trapdoor.*` |

Use counts of the set-type fields in the `Blocks` initializer (read): `BlockSetType.GOLD` once (the light weighted pressure plate), `POLISHED_BLACKSTONE` once (the polished blackstone pressure plate), `IRON` three times (door, trapdoor, heavy weighted pressure plate), `STONE` three times (stone pressure plate, stone button, and the polished blackstone button, which uses `stone`: 30-redstone-5 §5), `COPPER` four times. So `gold` and `polished_blackstone` are plate-only, and iron, gold and copper have no button block; no door, trapdoor or gate uses `gold`, `stone` or `polished_blackstone`. `poplar` is a wood present in this artifact (a set type, a wood type, doors, trapdoors, gates) and must be included wherever a list of woods is built.

`WoodType` (a record: `name`, `setType`, `soundType`, `hangingSignSoundType`, `fenceGateClose`, `fenceGateOpen`) has 13 entries, read from its static initializer in this order: oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, poplar, crimson, warped, mangrove, bamboo. Each uses the set type of the same name. The two-argument constructor gives `SoundType.WOOD`, `SoundType.HANGING_SIGN` and the gate events `block.fence_gate.close` / `block.fence_gate.open`. Four entries override the gate events and the `SoundType`; each of the same four also sets its own `hangingSignSoundType` (cherry: `CHERRY_WOOD_HANGING_SIGN`; crimson and warped: `NETHER_WOOD_HANGING_SIGN`; bamboo: `BAMBOO_WOOD_HANGING_SIGN`, read in the static initializer):

| Wood type | Gate close / open | `SoundType` |
|---|---|---|
| `cherry` | `block.cherry_wood_fence_gate.close` / `.open` | CHERRY_WOOD (hanging sign `CHERRY_WOOD_HANGING_SIGN`) |
| `crimson`, `warped` | `block.nether_wood_fence_gate.close` / `.open` | NETHER_WOOD (hanging sign `NETHER_WOOD_HANGING_SIGN`) |
| `bamboo` | `block.bamboo_wood_fence_gate.close` / `.open` | BAMBOO_WOOD (hanging sign `BAMBOO_WOOD_HANGING_SIGN`) |

All other woods (oak, spruce, birch, acacia, jungle, dark_oak, pale_oak, poplar, mangrove) use `block.fence_gate.*` and `SoundType.WOOD`. The door and trapdoor sounds of `crimson` and `warped` are the nether wood ones (table above), the gate sound is the nether wood one. Which set type each individual door, trapdoor or gate block uses: read for oak, iron and copper (and the waxed and weathering copper constructors, all `copper`); for the others it follows the block name: in `Blocks`, each of the 13 woods (poplar included) references its same-named `BlockSetType` field exactly 4 times (door, trapdoor, pressure plate, button) and its same-named `WoodType` field exactly 5 times (fence gate and the sign blocks), which supports the assignment as read; the per-block lambda was not matched, so it stays partly inferred (Open question 3).

## 2a. Block rows and delays of this part

Ids are block registry ids as tabulated in 24 (parts 2, 3, 5, 6 and 8) and 46. Delay column: scheduled ticks created by the block (29 §4).

| Blocks | Class | Ids | States each | Input rule | Delay (priority) | Sounds |
|---|---|---|---|---|---|---|
| 13 wood doors, `iron_door`, 4 weathering and 4 waxed copper doors (22) | `DoorBlock`, `WeatheringCopperDoorBlock` | `oak_door` 265, `iron_door` 308, spruce to bamboo 702 to 711 (spruce, birch, jungle, acacia, cherry, dark_oak, pale_oak, mangrove, poplar, bamboo), `crimson_door` 989, `warped_door` 990, copper doors 1166 to 1173 | 64 | own and other half's neighbour signal (3.5) | none | set type door close / open |
| 13 wood trapdoors, `iron_trapdoor`, 4 weathering and 4 waxed copper trapdoors (22) | `TrapDoorBlock`, `WeatheringCopperTrapDoorBlock` | `oak_trapdoor` 365 to `bamboo_trapdoor` 375 (oak, spruce, birch, jungle, acacia, cherry, dark_oak, pale_oak, mangrove, poplar, bamboo), `iron_trapdoor` 580, `crimson_trapdoor` 981, `warped_trapdoor` 982, copper trapdoors 1174 to 1181 | 64 | own cell signal | none, except the water fluid tick at `FlowingFluid.getTickDelay` when the resulting state is waterlogged (4.3) | set type trapdoor close / open |
| 13 fence gates | `FenceGateBlock` | `oak_fence_gate` 419, spruce to bamboo 682 to 691 (spruce, birch, jungle, acacia, cherry, dark_oak, pale_oak, mangrove, poplar, bamboo), `crimson_fence_gate` 983, `warped_fence_gate` 984 | 32 | own cell signal | none | wood type gate close / open |
| `redstone_lamp` | `RedstoneLampBlock` | 445 | 2 | own cell signal | turn-off: 4 ticks, default priority (NORMAL); turn-on immediate | none |
| 4 weathering and 4 waxed copper bulbs | `WeatheringCopperBulbBlock`, `CopperBulbBlock` | copper bulbs 1190 to 1197 | 4 | own cell signal, rising edge toggles `lit` | none | `block.copper_bulb.turn_on` / `turn_off` |
| `tnt` | `TntBlock` | 220 | 2 | own cell signal ignites | none (the fuse is the entity's own countdown) | `entity.tnt.primed` |

Counts: doors 13 wood + 1 iron + 8 copper = 22; trapdoors 13 wood + 1 iron + 8 copper = 22; fence gates 13; lamp 1; bulbs 8; TNT 1. The within-range order of the copper door, trapdoor and bulb ids (weathering before waxed) is in 29b-5 §5.2 and was not re-derived here.

## 3. `DoorBlock`

### 3.1 State

Properties (declared in the order `half`, `facing`, `open`, `hinge`, `powered`; the state id order is the sorted-name order of 24 part 3 §7.7): `facing` (north, south, west, east; the default value is NORTH), `half` (`upper`, `lower`), `hinge` (`left`, `right`), `open`, `powered`. Default: facing north, open false, hinge left, powered false, half lower. 64 states. `rotate` rotates `facing`; `mirror` with a mirror other than NONE applies the mirror's rotation to `facing` and then cycles `hinge` (left to right and back). The model-offset seed (`getSeed`) of a door is `Mth.getSeed(x, y', z)` with `y'` the lower half's y (the lower half's own y, or the y one below for the upper half), so both halves share a seed.

Flags of the set type: `canOpenByHand` (hand toggling and `isWoodenDoor`), `canOpenByWindCharge` (explosion hit). The doors of this artifact: wood doors (`oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `mangrove`, `poplar`, `bamboo`, `crimson`, `warped`), `iron_door`, and the eight copper doors (four weathering `WeatheringCopperDoorBlock` and four waxed `DoorBlock`; ids in 29b-5 §5.2). `DoorBlock` has two static overloads, `isWoodenDoor(BlockState)` and `isWoodenDoor(Level, BlockPos)` (the second takes the state at the position; its body was not decoded here beyond the signature, Open question 8). The `BlockState` overload is true for any door block whose set type `canOpenByHand`, so it is also true for copper doors and false for the iron door (despite the name; used by mob door logic, which is outside this document).

### 3.2 Shape

Base shape `boxZ(16, 13, 16)` = the slab x 0 to 16, y 0 to 16, z 13 to 16 (pixels), registered under the key NORTH; the shape for key K is that slab turned so that it lies on the side of the cell opposite to K: key NORTH z 13 to 16, key SOUTH z 0 to 3, key EAST x 0 to 3, key WEST x 13 to 16 (the north entry read; the other three follow the `rotateHorizontal` call and agree with the ladder and trapdoor rows in 24 parts 3 and 5, Open question 1). The key is `facing` when the door is closed; when open it is `facing` turned counter-clockwise if `hinge` is `right`, clockwise if `hinge` is `left` (seen from above). Both halves use the same shape. The door has no collision override (collision = shape) and `isPathfindable`: LAND and AIR give the value of `open`, WATER gives false (switch map read: LAND 1, AIR 2, WATER 3).

### 3.3 Placement (`getStateForPlacement`, then `setPlacedBy`)

The door item places both halves (the item class is `DoubleHighBlockItem` (inferred, Open question 2: the class was read, but which item uses it was not matched); its `placeBlock`, read in full, first writes water into the cell above when `Level.isWaterAt(pos + UP)` is true (a fluid test on that cell, not a test that the block there is water), else air, with flags 27 = 1 + 2 + 8 + 16, then runs the normal `BlockItem.placeBlock`).

1. `getStateForPlacement(context)` returns no state (placement refused) unless `pos.y < level.getMaxY()` and the block at `pos + UP` `canBeReplaced(context)`.
2. `powered` = `hasNeighborSignal(pos)` OR `hasNeighborSignal(pos + UP)`.
3. The state is the default state with `facing` = the placer's horizontal direction (`getHorizontalDirection`, the direction the placer looks, not its opposite), `hinge` from 3.4, `powered` = `open` = the value of step 2, `half` lower.
4. After the lower half is placed, `setPlacedBy` writes the upper half at `pos + UP` with `setBlockAndUpdate` (flags 3) using the lower half's state with `half` upper (so the upper half carries the same facing, hinge, open and powered).
5. Survival (`canSurvive`) is tested by the generic placement pipeline (29 §9): the lower half needs the block below to have its UP face sturdy; the upper half needs the block below to be this same door block.

### 3.4 Hinge side and the double-door rule (`getHinge`)

Inputs: the placer's horizontal direction `d`; the clicked position `p` (the cell of the lower half); `ccw(d)` and `cw(d)` the counter-clockwise and clockwise horizontal directions seen from above; the click point inside the cell `(dx, dz)` = click location minus the cell origin.

1. Four neighbour cells: `A0 = p + ccw(d)`, `A1 = A0 + UP`, `B0 = p + cw(d)`, `B1 = B0 + UP`.
2. Score `s` = (`-1` if `A0` has a full-block collision shape) + (`-1` if `A1` has one) + (`+1` if `B0` has one) + (`+1` if `B1` has one). A "full-block collision shape" is `isCollisionShapeFullBlock(level, pos)` of the state there.
3. `leftDoor` = the block at `A0` is a `DoorBlock` (any door) whose `half` is lower; `rightDoor` = the same for `B0`.
4. If (`leftDoor` and not `rightDoor`) or `s > 0`: hinge is **right**.
5. Else if (`rightDoor` and not `leftDoor`) or `s < 0`: hinge is **left**.
6. Else (tie, including both neighbours being doors) the click point decides, with `(sx, sz)` the step of `d` (each -1, 0 or 1): hinge is **right** when (`sx < 0` and `dz < 0.5`) or (`sx > 0` and `dz > 0.5`) or (`sz < 0` and `dx > 0.5`) or (`sz > 0` and `dx < 0.5`); otherwise **left**.

So a solid wall on one side puts the hinge on that side, and a door already standing on the left makes the new door's hinge right, which builds a double door whose two leaves swing apart; two doors on both sides give the click point rule. The "door" test ignores the neighbour's `facing`, `hinge`, `open` and type: any lower door half counts.

### 3.5 Redstone (`neighborChanged`) and the two halves

Inputs: the door state, `pos`, the changed neighbour's block (`neighborBlock`).

1. `power` = `hasNeighborSignal(pos)` OR `hasNeighborSignal(pos + (UP if half is lower, DOWN if half is upper))`. Each half therefore also sees the other half's neighbours.
2. If the default state of this door block `is` the `neighborBlock` (the update came from the same block, for instance from the other half), do nothing.
3. If `power` equals `powered`, do nothing.
4. If `power` differs from `open`: play the open sound (`power` true) or close sound (`power` false) with entity null, and emit `BLOCK_OPEN` or `BLOCK_CLOSE` with entity null. (No sound when the door is already in the target open state, for example a hand-opened door that then receives power.)
5. Write the state with `powered` = `power` and `open` = `power` at flags 2.

Thus the door follows the signal in both directions: unpowering a door that was opened by hand closes it.

Pairing of halves (`updateShape`, run as a shape update of the neighbouring half after any write; 29 §3.2). Let `h` be this half and `dir` the direction of the changed neighbour:

1. If `dir` is on the Y axis and (`h` is lower) equals (`dir` is UP) (the lower half looking up, the upper half looking down): if the neighbour is a `DoorBlock` whose `half` differs from `h`, the new state of this half is the neighbour's state with `half` set to `h` (this copies facing, hinge, open and powered, and the block, from the other half; this is how a hand toggle of one half and a weathering step reach the other half); otherwise the result is air.
2. Else if `h` is lower and `dir` is DOWN and the state cannot survive (`canSurvive`, 3.3 step 5): air.
3. Else the default `Block.updateShape`.

Only the half that is interacted with is written by hand (3.6); the other half follows through step 1 in the same `setBlock` call because flags 10 and 2 do not set the "known shape" bit.

### 3.6 Use by hand, wind charge, destruction

- `useWithoutItem(state, level, pos, player, hit)`: if the set type's `canOpenByHand` is false, return PASS (so the iron door cannot be opened by hand). Otherwise cycle `open`, write at flags 10, play the sound for the new state with the player excluded (section 1, item 2), emit `BLOCK_OPEN` / `BLOCK_CLOSE` with the player as entity, return SUCCESS. The write is made on whichever half was clicked; 3.5 pairing updates the other.
- `setOpen(entity, level, state, pos, open)` (the public mob and effect entry): returns unless the state is this block and its `open` differs; writes `open` at flags 10, plays the sound (excluded entity = the argument), emits the event with that entity.
- `onExplosionHit` (wind charge and explosions that `canTriggerBlocks`): only the **lower** half, only when `canOpenByWindCharge` and `powered` is false: `setOpen(null, level, state, pos, !open)`. Then the default explosion handling. The iron door (flag false) is never opened by a wind charge.
- `playerWillDestroy`: on the server, when the player prevents drops or has no correct tool, `DoublePlantBlock.preventDropFromBottomPart` runs (the creative or wrong-tool break of the lower half removes the upper half's pair without a drop); then the default. Which half drops is loot-table data (the lower half only).
- Random tick: only the weathering variants, lower half only, 29b-5 §6.1. Waxed copper doors are plain `DoorBlock`.

## 4. `TrapDoorBlock`

### 4.1 State and shape

Properties (declared `facing`, `open`, `half`, `powered`, `waterlogged`; sorted order in 24 part 3 §7.7): `facing` (default NORTH), `open` false, `half` (`top`, `bottom`, default `bottom`), `powered` false, `waterlogged` false; 64 states. The class is `HorizontalDirectionalBlock` plus `SimpleWaterloggedBlock`; the fluid state is the water source when waterlogged (`getFluidState`).

Shape: the same base `boxZ(16, 13, 16)` registered with `rotateAll` for six keys (NORTH z 13 to 16, EAST x 0 to 3, SOUTH z 0 to 3, WEST x 13 to 16, DOWN y 13 to 16, UP y 0 to 3; 24 part 5 §7.16). Lookup: when `open`, the key is `facing` (the leaf stands on the side opposite to `facing`); when closed, the key is DOWN for `half` top and UP for `half` bottom (so a bottom trapdoor is the slab y 0 to 3). Collision = shape. `isPathfindable`: LAND gives `open`, WATER gives `waterlogged`, AIR gives `open` (switch map read: LAND 1, WATER 2, AIR 3).

### 4.2 Placement

Inputs: clicked face `f`, clicked position, `replacingClickedOnBlock`, click point `y` inside the cell.

1. Start from the default state; `fluid` = the fluid at the clicked position.
2. If the placement is not replacing the clicked-on block and `f` is horizontal: `facing = f`; `half` = top when the click's fractional y is greater than 0.5, else bottom (a side click on a block face).
3. Otherwise: `facing` = the opposite of the placer's horizontal direction; `half` = bottom when `f` is UP, else top.
4. If `hasNeighborSignal(clickedPos)`: `open` = `powered` = true.
5. `waterlogged` = the fluid is water.

### 4.3 Use, redstone, explosion

- `useWithoutItem`: when `canOpenByHand` is false (iron) PASS; otherwise `toggle(state, level, pos, player)` and SUCCESS.
- `toggle`: cycle `open`; write at flags 2; if the new state is waterlogged schedule a water fluid tick at `FlowingFluid.getTickDelay(level)` (29a); play the sound (`trapdoorOpen` or `trapdoorClose` of the set type, 1 section rules), emit `BLOCK_OPEN` / `BLOCK_CLOSE` with the player (or null).
- `neighborChanged` (server only): `power` = `hasNeighborSignal(pos)` (this cell only; no other-half query). If `power` equals `powered`, stop. If `open` differs from `power`: set `open` = `power` in the local state, play the sound and emit the event with entity null. Write `powered` = `power` (with the possibly updated `open`) at flags 2. If waterlogged, schedule the water tick. Note that unlike the door, a hand-opened trapdoor that is then powered does not play a sound and does not change `open` again.
- `onExplosionHit`: when the explosion `canTriggerBlocks`, the set type `canOpenByWindCharge` and `powered` is false: `toggle(state, level, pos, null)`; then the default.
- `updateShape`: when waterlogged, schedule the water tick; then the default.
- Random tick: only the weathering variant (`WeatheringCopperTrapDoorBlock`, both halves, no condition: 29b-5 §6.4). Waxed copper trapdoors are plain `TrapDoorBlock`.

The ladder-like climbing rule of an open trapdoor above a ladder and the trapdoor tags are not read here (Open question 9).

## 5. `FenceGateBlock`

### 5.1 State and shapes

Properties (declared `facing`, `open`, `powered`, `in_wall`; the state order is the sorted names `facing`, `in_wall`, `open`, `powered`): defaults facing NORTH, all booleans false; 32 states. The constructor takes a `WoodType` (section 2) which provides the block `SoundType` and the two gate sounds. Shapes are keyed by the axis of `facing` (axis Z for north or south, X for east or west) and are listed in 24 part 5 §7.18 and 24 part 4 §6.9; the values read again: outline `cube(16,16,4)` = z 6 to 10 (axis Z), or the wall variant with the top 3 pixels removed (y 0 to 13) when `in_wall`; collision `column(16,4,0,24)` (y 0 to 24) closed, empty when open; support shape y 5 to 24 closed, empty when open; occlusion two posts moved down 3 pixels (-0.1875) when `in_wall`.

`connectsToDirection(state, dir)` (used by fences and walls): true when the axis of `facing`'s clockwise direction equals the axis of `dir`, that is when `dir` points along the gate's open sides.

`isPathfindable`: LAND and AIR give `open`, WATER false.

### 5.2 Placement and `in_wall`

1. `powered` = `open` = `hasNeighborSignal(clickedPos)`.
2. `facing` = the placer's horizontal direction.
3. `in_wall`: when the axis of `facing` is Z, true if the block at `pos.west()` or `pos.east()` is in tag `walls`; when the axis is X, true if the block at `pos.north()` or `pos.south()` is in tag `walls`.

`updateShape` (a neighbour changed in direction `dir`): when the axis of `dir` equals the axis of `clockwise(facing)` (a side neighbour), `in_wall` = (the changed neighbour state is in tag `walls`) OR (the block at `pos + opposite(dir)` is in tag `walls`), the state is returned with that value; otherwise the default shape update.

### 5.3 Use, redstone, explosion

- `useWithoutItem`: if `open`: set `open` false and write at flags 10. Else: let `pd` = `player.getDirection()`; if the gate's `facing` equals the opposite of `pd`, set `facing` = `pd`; then set `open` true and write at flags 10. The sound is the wood type's open or close sound (section 1, item 2; `random.nextFloat() * 0.1f + 0.9f`), then the event `BLOCK_OPEN` / `BLOCK_CLOSE` with the player; return SUCCESS. (So a gate always swings away from the user: it turns to face the user's direction when the user stands on its front side.) There is no `canOpenByHand` test: gates always open by hand.
- `neighborChanged` (server only): `power` = `hasNeighborSignal(pos)`; if it differs from `powered`: write `powered` = `open` = `power` at flags 2; if the old `open` differs from `power`, play the sound and emit the event with entity null.
- `onExplosionHit`: when the explosion `canTriggerBlocks` and `powered` is false: **toggle** `open` (an open gate closes, a closed gate opens) with `setBlockAndUpdate` (flags 3), play the close sound if it was open else the open sound at the block position with entity null, emit `BLOCK_CLOSE` / `BLOCK_OPEN` with the entity null and the gate's state as context; then the default. The wind-charge flag of the wood type is not consulted.

## 6. `RedstoneLampBlock`

Property `lit` (default false; the property object is the same `LIT` as the redstone torch). Light 15 when lit (registry row, 24 part 4 §6.22).

1. Placement: `lit` = `hasNeighborSignal(clickedPos)`. There is no `onPlace` check.
2. `neighborChanged` (server only): `litNow` = the state's `lit`. If `litNow` differs from `hasNeighborSignal(pos)`: if `litNow` (lit but unpowered): schedule a block tick for this block at delay **4** (`scheduleTick(pos, thisBlock, 4)`, default priority); else (unlit but powered): `cycle(lit)` and write at flags 2 immediately (turn-on has no delay).
3. `tick`: if `lit` and not `hasNeighborSignal(pos)`: `cycle(lit)` (to false) and write at flags 2. If the signal returned meanwhile the tick does nothing.

Because scheduling the same block at the same position is ignored while a tick is pending (29 §4, example 13.4), repeated power losses inside the 4 ticks create one tick. A lamp is therefore a pulse stretcher on the falling edge only: a pulse shorter than 4 ticks that ends before the tick fires keeps the lamp lit to the tick, and a gap shorter than 4 ticks does not extinguish it. Turn-on lights the lamp on the same tick as the update (a lamp that is already lit stays lit across such a gap without any write).

## 7. `CopperBulbBlock` and `WeatheringCopperBulbBlock`

### 7.1 State

Properties (declared `lit`, `powered`; sorted state order in 24 part 8): both default false; 4 states. Output light 15, 12, 8, 4 when lit for unaffected, exposed, weathered, oxidized (the waxed twin by its state), 0 when unlit (registry, 24 part 8). `CopperBulbBlock` is the waxed class (four blocks); `WeatheringCopperBulbBlock(weatherState, properties)` is the weathering class (four blocks) and adds only the random tick and `isRandomlyTicking` (29b-5 §§4 to 6.4; a state-preserving next block, so `lit` and `powered` survive a weathering step). The bulb is `redstoneConductor: never` (24 part 8).

### 7.2 The toggle rule (`checkAndFlip`)

Called on the server only, from `onPlace` and `neighborChanged`.

1. `onPlace(state, level, pos, oldState, moved)`: if `oldState`'s block is the same block as `state`'s block, do nothing (a property change of the same block is not a placement). Otherwise, on a `ServerLevel`, call `checkAndFlip`. (A different block at the position before, including air, the moving-piston block while a piston moves a bulb, or the weathering or waxing predecessor, triggers the check.)
2. `neighborChanged(state, level, pos, neighbour, orientation, moved)`: on a `ServerLevel`, call `checkAndFlip`.
3. `checkAndFlip(state, level, pos)`:
   1. `signal` = `hasNeighborSignal(pos)`.
   2. If `signal` equals `powered`: stop.
   3. If `powered` is false (a rising edge, `signal` true): `state` = `cycle(lit)` (toggle lit); play `block.copper_bulb.turn_on` if the new `lit` is true, else `block.copper_bulb.turn_off`, at the block position with entity null (source BLOCKS, volume 1, pitch 1).
   4. Write `state` with `powered` = `signal` using `setBlockAndUpdate` (flags 3).

A falling edge only clears `powered`; `lit` is unchanged. Every rising edge toggles `lit`. This makes the bulb a T flip-flop on the rising edge with the power state remembered in `powered`. Because the write has flags 3 (neighbour update) and the block has an analog output (7.3), comparators next to it are notified (29 §3.4, `updateNeighbourForOutputSignal`).

### 7.3 Comparator output

`hasAnalogOutputSignal` is true. `getAnalogOutputSignal(state, level, pos, direction)` reads the state at `pos` from the level and returns 15 when `lit` is true, else 0 (independent of the weather state and of the comparator's direction).

### 7.4 Variants

The eight blocks: `copper_bulb`, `exposed_copper_bulb`, `weathered_copper_bulb`, `oxidized_copper_bulb` and their four `waxed_` twins. All have identical redstone behaviour; only light and the random tick differ (7.1). Waxing and scraping change the block while keeping `lit` and `powered` (29b-5 §7), and a block change triggers `onPlace` (7.2 step 1), so `checkAndFlip` runs on the new block; it does nothing when `signal` equals `powered`, which is the normal case.

## 8. `TntBlock`, priming and the primed TNT entity

### 8.1 State

One property, `unstable` (default false); 2 states. Nothing in `TntBlock` sets it to true; it is read in 8.4 only (Open question 4). Registry row (read in `Blocks`): map colour FIRE, instabreak, `SoundType.GRASS`, ignited by lava, an `isRedstoneConductor` override (a lambda predicate, not decoded here; Open question 15), flammability pair 15 and 100 in the fire table (read in `FireBlock` bootstrap as the two numbers given to `setFlammable`; the bytecode has no parameter names, so the reading of 15 as the ignite odds and 100 as the burn odds comes from how `checkBurnOut` and `getBurnOdds` use them later; 29b-3), item and loot are data.

### 8.2 `prime(level, pos[, igniter, stack])`

Returns true when a primed TNT was created. Steps:

1. If the level is not a `ServerLevel`: return false (clients never create it).
2. If the game rule `tnt_explodes` (33 §8) is false: return false.
3. If the igniter is a `Player` in game mode ADVENTURE, the stack must pass `canBreakBlockInAdventureMode` for the block at `pos` (a `can_break` check of the held stack), otherwise return false.
4. Create `PrimedTnt` at `(x + 0.5, y, z + 0.5)` with the igniter (a `LivingEntity` or null) as owner; the constructor (21 §8.3) sets a velocity from one `nextDouble` draw of the level's random (angle `a = draw * 6.2831854820251465`, velocity `(-sin a * 0.02, 0.20000000298023224, -cos a * 0.02)`; literal constants in 8.5) and the fuse 80. Add it with `addFreshEntity`.
5. Play `entity.tnt.primed` at the entity position, source BLOCKS, volume 1.0, pitch 1.0, entity null.
6. Emit game event `PRIME_FUSE` (entity = the igniter, or null) at `pos`.
7. Return true.

`prime` does not remove the block. What happens to the block depends on the caller (8.3): `onPlace`, `neighborChanged` and `onProjectileHit` call `removeBlock(pos, false)` (flags 3) after a successful prime; the hand path writes air with flags 11; the fire path has already replaced the block (age-set fire) or removed it before calling `prime`; the `playerWillDestroy` path calls `prime` and the default destroy then removes the block; `wasExploded` does not call `prime` at all (it builds the entity itself).

### 8.3 Ways to ignite

| Trigger | Entry | Behaviour |
|---|---|---|
| Placement beside power | `onPlace` | If the old state's block is TNT, nothing. Else if `hasNeighborSignal(pos)` and `prime(level, pos)` returns true: `removeBlock(pos, false)`. |
| Power change | `neighborChanged` | If `hasNeighborSignal(pos)` and `prime` returns true: `removeBlock(pos, false)`. (Every neighbour update re-checks, so TNT beside a permanently powered source ignites when placed or on the next update.) |
| Hand | `useItemOn` | When the held item is neither flint and steel nor a fire charge: the default item-use result. Otherwise `prime(level, pos, player, stack)`; on true: write air with flags 11 (1 + 2 + 8), damage flint and steel by 1 (`hurtAndBreak`, in the used hand's slot) or consume 1 fire charge, award the `item_used` statistic of the item; return SUCCESS. On false: if the level is a server level and `tnt_explodes` is false, show the overlay message `block.minecraft.tnt.disabled` and return PASS; otherwise SUCCESS (so the client of a rejected adventure-mode click still swings). |
| Fire | `FireBlock.checkBurnOut` (29b-3) | When a fire burns a flammable block with the odds `nextInt(burnChance) < burnOdds`: the block is replaced by fire (age set) or removed (rain or random), then, if the burnt block was TNT, `prime(level, pos)`. TNT has ignite odds 15 and burn odds 100. |
| Projectile | `onProjectileHit` (server level only) | When the projectile is burning (`isOnFire`) and `mayInteract(level, pos)`: `prime(level, pos, owner (if a LivingEntity, else null), stack)` where `stack` is the arrow's pickup stack for an `AbstractArrow` and empty otherwise; on true `removeBlock(pos, false)`. Who calls `onProjectileHit` (arrows, fire charges, tridents) is projectile code (44 part 8; Open question 5). |
| Explosion of a neighbour | `wasExploded(level, pos, explosion)` | When the rule `tnt_explodes` is true: create a `PrimedTnt` at `(x + 0.5, y, z + 0.5)` with the explosion's indirect source entity as owner, then set its fuse to `getRandomShortFuse(fuse, random)` = `random.nextInt(max(1, fuse / 4)) + fuse / 8` (integer divisions) with the level's random: for fuse 80 this is `nextInt(20) + 10`, a value from 10 to 29 ticks; add it to the level. No sound and no game event. `dropFromExplosion` is false (the block does not drop an item when exploded). |
| Dispenser | 30-redstone-4 | The TNT item: a primed TNT in the faced cell (item shrunk, `entity.tnt.primed`, `ENTITY_PLACE`) when `tnt_explodes` is true. Flint and steel dispensed at a TNT block calls `prime(level, pos, null, stack)` and removes the block on success. |
| Breaking by a player | `playerWillDestroy` | See 8.4. |

### 8.4 Breaking an unstable TNT

`playerWillDestroy(level, pos, state, player)`: on the server, when the player is not in creative mode (`Abilities.instabuild` false) and `unstable` is true: `prime(level, pos)` (owner null, empty stack); then the default destroy (the block is removed; the TNT item is not dropped because the loot table has a condition on `unstable` (data, not read)). A stable TNT breaks normally and drops its item.

### 8.5 Primed TNT creation summary (entity in 21 §8.3)

| Item | Value |
|---|---|
| Type | `tnt`, 0.98 x 0.98, eye 0.15, tracking range 10, update interval 10, fire immune (21 §2) |
| Spawn position | block centre x and z (+0.5), block y (no offset) |
| Initial velocity | one `nextDouble` draw `u`; `a = u * 6.2831854820251465` (the double that is the float value of 2 pi, not the exact double 2 pi); velocity `(-sin a * 0.02, 0.20000000298023224, -cos a * 0.02)` (the vertical value is the float 0.2f widened to double). A bit-exact replay of the motion needs these literal constants; the rounded 2 pi and 0.2 differ in the low bits (all read in the `PrimedTnt` constructor) |
| Fuse | 80 ticks, written to metadata index 8 (VarInt); 10 to 29 after a neighbour explosion (8.3) |
| Explosion at fuse end | `explosionPower` 4.0 (NBT `explosion_power`, read back clamped to 0 to 128), at `(x, y + h, z)` with `h` = the float 0.98f widened to double (0.9800000190734863) times 0.0625 = 0.0612500011920929 (about 0.06125 but not exactly: `PrimedTnt.explode` passes 0.0625 to `Entity.getY(double)`, which reads `getBbHeight()` as a float, widens it with `f2d`, multiplies by the argument as a double and adds `position.y`, read; that the entity height is the float 0.98f is from the entity type row, 21 §2), interaction TNT, no fire, damage source `Explosion.getDefaultDamageSource`; the explosion runs only when `tnt_explodes` is true. A TNT that went through a portal uses a damage calculator that makes the nether portal block unbreakable by it (`PrimedTnt$1`: `shouldBlockExplode` false and an empty resistance for `nether_portal`) |
| NBT | `fuse` (short), `block_state` (default: TNT default state), `explosion_power` (only when not 4.0), `owner` (entity reference) |

The explosion algorithm itself (rays, damage, block destruction) is not part of this document (Open question 6).

## 9. Corrections to other documents

| Document | Statement | Reading in this round |
|---|---|---|
| 24 part 4 §6.9 (fence gate `useWithoutItem`) | "`facing` set to the clicked face direction" | the direction is the **player's** direction (`Player.getDirection`), and the turn happens only when the gate's facing is the opposite of it (5.3). 24 part 5 §7.18 already says "player's direction". |
| 24 part 4 §6.9 and 24 part 5 §7.18 (gate explosion) | "closes an open unpowered gate" / "toggles `open`" | the gate **toggles** (opens a closed one, closes an open one) when not powered; flags 3 (5.3). |
| 24 part 3 §7.7 (trapdoor pathfinding) | "switch order of the cases not decoded (Open question 15)" | decoded: LAND `open`, WATER `waterlogged`, AIR `open` (4.1). |
| 24 part 3 §7.7 (door, wind charge) | "opens or closes" | lower half only, `canOpenByWindCharge`, not powered (3.6). |
| 24 part 3 §7.7 (trapdoor redstone) | "sets `open`, plays the sound" | the trapdoor does not change `open` when `open` already equals the power; the door and gate differ (4.3). |

## 10. Worked examples

1. **Hinge, wall on the left.** A player looking north (`d` = NORTH, `ccw` = WEST, `cw` = EAST) places a door at (0, 64, 0). Stone at (-1, 64, 0) and (-1, 65, 0), air to the east. `A0`, `A1` are full: `s` = -2. Neither neighbour is a door. Step 4 fails (`s` is not positive), step 5 gives hinge **left**. State: facing north, hinge left, half lower, open false, powered false (no signal). The upper half at (0, 65, 0) carries the same properties with half upper. Closed collision: key NORTH, z 13 to 16. Hand-opened: hinge left gives key `clockwise(north)` = EAST, the slab at x 0 to 3 (the leaf lies against the wall on the west).
2. **Double door.** A door D1 (hinge left, any facing) stands at (0, 64, 0). A player looking north places a second door at (1, 64, 0): `ccw(north)` = west, so `A0` = (0, 64, 0) is a lower door half: `leftDoor` true; `B0` = (2, 64, 0) is air: `rightDoor` false. Step 4: hinge **right**. The two doors have opposite hinges; opened, D1 (left) uses key EAST (x 0 to 3) and the new one (right) uses key WEST (x 13 to 16): they swing to the outer edges.
3. **Tie, click point.** Open ground, no doors, `d` = NORTH (`sx` = 0, `sz` = -1); click point `dx` = 0.7: step 6, `sz < 0` and `dx > 0.5`: hinge **right**. With `dx` = 0.3: left. With `d` = EAST (`sx` = 1), `dz` = 0.8: right.
4. **Powered door.** A lever turns on next to the lower half of a closed door. The lower half receives `neighborChanged` with `neighborBlock` = lever: `power` true; the door is not that block; `power` != `powered` (false); `power` != `open`: play `block.wooden_door.open`, emit `BLOCK_OPEN`; write powered true, open true at flags 2. The shape update from this write reaches the upper half, which becomes the lower half's state with half upper (3.5 step 1). The upper half's own `neighborChanged` (from the write, source = the door block itself) returns at step 2. The lever off: both flags false, `block.wooden_door.close`.
5. **Iron door.** Right-click on an iron door: `canOpenByHand` is false: PASS, nothing changes. A powered neighbour opens it by 3.5. A wind charge explosion does nothing (flag false).
6. **Trapdoor placement.** Clicking the east face of a stone block at (5, 64, 5) with a click height 0.7 inside the target cell (the cell (6, 64, 5)), placing a trapdoor; the placement is not replacing the clicked block and the face is horizontal: `facing` = EAST, `half` = top (0.7 > 0.5). Closed: key DOWN, y 13 to 16. Opened: key EAST, x 0 to 3.
7. **Gate in a wall line.** A gate placed at (0, 64, 0) by a player looking east (axis X) with cobblestone walls at (0, 64, -1) (north) and (0, 64, 1) (south): `in_wall` true, outline y 0 to 13. Removing the north wall sends the gate an `updateShape` with `dir` = NORTH (axis Z = axis of `clockwise(east)` = south): `in_wall` = (changed neighbour is a wall: no) OR (block at `pos + SOUTH` is a wall: yes) = true.
8. **Gate use.** A gate with `facing` = NORTH, closed. A player standing north of it looking south (`pd` = SOUTH): opposite of `facing`(north) is south = `pd`, so `facing` becomes SOUTH, `open` true, flags 10; the sound is `block.fence_gate.open` for oak (or `block.cherry_wood_fence_gate.open` for cherry). A player standing south looking north (`pd` = NORTH): `facing` is not turned, `open` true.
9. **Lamp delay.** Game time 100: the lever powering an unlit lamp turns on: neighbour update: `lit` false != signal true: write lit true (flags 2) at tick 100. Time 120: the lever turns off: `lit` true != false: schedule a tick for 124. Time 122: the lever turns on again: `lit` (true) equals the signal (true): nothing. Time 124: the tick runs, `lit` and signal true: nothing (the lamp never went out). Variant: the lever stays off: at 124 `lit` true and signal false: lit false.
10. **Bulb toggle.** A bulb with lit false, powered false is placed next to a lit redstone block. `onPlace` (old block air): `checkAndFlip`: signal true != powered false; powered false: lit = true, play `block.copper_bulb.turn_on`; write lit true, powered true (flags 3). A comparator behind it reads 15. The redstone block is removed: signal false != powered true; powered is true so no flip; write powered false (lit stays true; comparator still 15). Placing the redstone block again: signal true != powered false: lit = false, `block.copper_bulb.turn_off`, powered true; comparator reads 0.
11. **TNT by redstone.** TNT placed adjacent to a powered block: `onPlace`: old block is not TNT; `hasNeighborSignal` true; `prime` creates a `PrimedTnt` at (x + 0.5, y, z + 0.5), fuse 80, plays `entity.tnt.primed`, emits `PRIME_FUSE`; the block is removed with flags 3. With `tnt_explodes` false: `prime` returns false, the TNT stays and nothing happens.
12. **TNT chain.** TNT B at distance 2 from a TNT A whose explosion reaches B: `wasExploded` on B with the rule true: new `PrimedTnt` at B's centre-bottom, fuse `nextInt(20) + 10` (say draw 7: fuse 17), owner = A's explosion source entity. The block B itself is destroyed by the explosion without a drop.
13. **Flint and steel.** A survival player right-clicks TNT with flint and steel: `prime(level, pos, player, stack)` true; the block becomes air (flags 11); the flint and steel loses 1 durability; the `item_used` statistic of `flint_and_steel` increments; SUCCESS. An adventure-mode player with a stack that has no `can_break` entry for TNT: `prime` false; `tnt_explodes` is true so the result is SUCCESS and nothing else happens.

## 11. Validation

| # | Check | Result |
|---|---|---|
| V1 | State counts: door 64 (5 properties: 4 x 2 x 2 x 2 x 2), trapdoor 64 (4 x 2 x 2 x 2 x 2), fence gate 32 (4 x 2 x 2 x 2), lamp 2, bulb 4, TNT 2 | agrees with 24 parts 2 to 8 |
| V2 | Flags: door and gate hand toggles use 10; redstone writes 2; bulb and gate explosion 3; all read as immediate constants of the cited methods | consistent with 29 §1 |
| V3 | The `BlockSetType` list has 18 entries in the order read from the static initializer: iron, copper, gold, stone, polished_blackstone, oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, poplar, crimson, warped, mangrove, bamboo | read; the table in section 2 covers all 18 |
| V4 | `WoodType` list has 13 entries; the four with their own gate sounds are cherry, crimson, warped, bamboo | read |
| V5 | Sound event names (door, trapdoor and gate for each type, copper bulb on and off, tnt primed) were read as the `register` strings of `SoundEvents` | read |
| V6 | Door hinge rule agrees with 24 part 3 §7.7.1 and 24 part 2 §7.11; the click-point branch order was re-derived from the comparison instructions (`dcmpg` and `dcmpl` forms) and matches example 3 | agrees |
| V7 | TNT short fuse example: fuse 80: `nextInt(max(1, 20))` gives 0 to 19, plus 10: 10 to 29 | arithmetic |
| V8 | Section 9 lists five places where earlier text differs from the bytecode; the artifact wins | recorded |
| V9 | Cross-reference form: `NN §x.y`, `NN-redstone-P §x.y`, `24 part P §x.y` (see the related-documents paragraph) | style |

## 12. Open questions

1. The `rotateHorizontal` rotation direction for the EAST, SOUTH and WEST keys was not decoded (`OctahedralGroup.BLOCK_ROT_Y_*` composition); the slab placements for those keys are taken from the key names and agree with 24 part 3 and part 5, not from a computed rotation.
2. The door item's class (`DoubleHighBlockItem`) is inferred, not matched door by door; its `placeBlock` was read in full. `Items` contains 11 lambdas that construct `DoubleHighBlockItem` (22 constant-pool lines: a `new` and an `<init>` each; a reviewer counted 22 lambdas and the artifact gives 11). There are 22 door blocks (13 wood, iron, 8 copper), so doors either share lambdas or use another factory; this was not resolved.
3. The set type of each door, trapdoor and gate (and the wood type of each gate) was read in the `Blocks` constructors for oak, iron and copper (weathering and waxed); for the other woods the 4 and 5 field-reference counts of section 2 support the assignment by block name, but no per-block lambda check was made (partly inferred). Poplar blocks exist in this artifact.
4. What sets `unstable` to true on a TNT block (an item component, creative pick, a command, the structure data) was not found in these classes; only its effect (8.4) and its loot-table use (data) are known.
5. The projectile side of `onProjectileHit` (which projectiles call it, when `isOnFire` is true) was not read (44 part 8 may cover projectiles).
6. The `Explosion` engine (`canTriggerBlocks`, `getIndirectSourceEntity`, rays, damage, block destruction, `Level.explode`) is not described here.
7. Game event listeners (vibration frequency of `BLOCK_OPEN`, `BLOCK_CLOSE`, `PRIME_FUSE`) are not read here.
8. Door-opening goals of mobs (which call `setOpen` and `isWoodenDoor`) are not read here.
9. The trapdoor climbing rule (`climbable` tag plus the ladder below test) and the `doors` and `trapdoors` tags are data and entity code not read here.
10. `Player.getDirection` (yaw to a horizontal direction), `getHorizontalDirection` of the placement context, and `ItemStack.canBreakBlockInAdventureMode` (`can_break` component test) were not decoded in this round; they are used as black boxes with the meanings in 13 and 29 §9.
11. The TNT dispenser row of 8.3 (`DispenseItemBehavior`, `FlintAndSteelDispenseItemBehavior`) is taken from 30-redstone-4 and was not checked against the artifact here. The new dispenser TNT branch calls a helper of a sulfur-cube dispense behaviour class (`dispenseBlock`) before creating the entity; its effect was not read (30-redstone-4 owns dispensers).
12. The level event or particle effects the client plays for TNT priming and bulb toggling (none were found in these classes) were not searched for in client code.
13. Closed: sensitivity and plate and button events per set type are read and given in section 2 (agree with 30-redstone-5 §4). Remaining: the registry strings of the plate and button `SoundEvents` fields were not re-read.
14. Correction to carry to other documents: 21 §8.3 gives the TNT explosion position as `y + 0.0625`; the artifact value is `y + 0.9800000190734863 * 0.0625` = `y + 0.0612500011920929` (8.5; double arithmetic on the widened float). That file was outside this round's edit scope.
15. The `isRedstoneConductor` predicate of the TNT block (the lambda in `Blocks`) and the body of `DoorBlock.isWoodenDoor(Level, BlockPos)` were not decoded; the TNT conductor value is therefore not stated (24 part 1 §5 may hold the per-block value).
