# Redstone, part 5: levers, buttons, pressure plates, daylight detector, target block, lightning rod, note block, jukebox signal

| Item | Value |
|---|---|
| Covers | The behaviour (engines, constants, orderings) of the redstone input and sensor blocks of round RS12 part 5: `LeverBlock`, the 15 `ButtonBlock` blocks (press durations, arrows), `BasePressurePlateBlock` with `PressurePlateBlock` (15 blocks, entity filters) and `WeightedPressurePlateBlock` (light and heavy, the weight formula, an exact threshold table), `DaylightDetectorBlock`, `TargetBlock` (strength by hit position, durations), `LightningRodBlock` and `WeatheringLightningRodBlock` (strike, pulse, the redirect search), `NoteBlock` and `NoteBlockInstrument` (instrument choice, pitch table, powered edge, sounds, particles) and the redstone-facing signal of `JukeboxBlock`. |
| Does not cover | The shared redstone model (`getSignal`, `getDirectSignal`, signal sources, strong and weak power, the neighbour-update order, orientation): sibling part 1 of document 30. Dispensers and droppers: part 4. Doors, trapdoors and gates powering: part 7. Tripwire, sculk: part 8. Block ids, state layouts, shapes, sound types and block set types as registry rows: 24 (cross-referenced below, not repeated). The update flags, scheduled ticks and block events: 29. The lightning bolt entity, the thunder schedule and the redirect call site: 33 section 4 and 44 part 9 (this document adds only what the rod itself does). Jukebox inventory, song player and client playback: 31 part 4 section 2. Sound and particle data files: the extraction tool (22). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `world.level.block.{LeverBlock, ButtonBlock, FaceAttachedHorizontalDirectionalBlock (+$1), BasePressurePlateBlock, PressurePlateBlock (+$1), WeightedPressurePlateBlock, DaylightDetectorBlock, TargetBlock, LightningRodBlock, WeatheringLightningRodBlock, NoteBlock, JukeboxBlock, Block (box helpers), Blocks (constructor arguments)}`, `world.level.block.state.properties.{BlockSetType (+$PressurePlateSensitivity), NoteBlockInstrument (+$Type), AttachFace}`, `world.level.block.state.BlockBehaviour` (default signal methods), `world.level.block.entity.{DaylightDetectorBlockEntity, JukeboxBlockEntity}`, `world.item.JukeboxSongPlayer`, `world.entity.{LightningBolt, Entity, Display, Interaction, Marker, OminousItemSpawner}`, `world.entity.ambient.Bat`, `world.entity.decoration.ArmorStand`, `world.entity.projectile.Projectile`, `server.level.ServerLevel` (rod search), `world.entity.ai.village.poi.PoiManager`, `world.phys.shapes.Shapes` (`rotateAttachFace`), `util.Mth`, `sounds.SoundEvents`, `client.renderer.LevelEventHandler` (event 3002), `client.sounds.SoundEngine` (`calculatePitch`), `world.level.{Level, LevelAccessor}` (`setBlocksDirty`, `playSound`), `world.item.HoneycombItem` (wax-off map), `client.multiplayer.ClientLevel` and `ServerLevel` (`playSeededSound`). Scratch notes were kept outside the repository. |

Scope decisions: standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-10c, round RS12). Registry rows are specified in 24 and the data files (sounds, particle definitions, tags, `jukebox_song`) are extracted by the tool, so they are not tabulated here; this document specifies the code that interprets them.

Recalled knowledge is not evidence: every number below was read from the artifact in this round. Statements marked "(inferred)" are deductions, and anything not read is listed in the Open questions. Class and method names are cited only to say where a fact was read.

## Contents

0. Conventions
1. The face-attached base (lever and button)
2. Lever
3. Buttons
4. Pressure plates
5. Daylight detector
6. Target block
7. Lightning rod
8. Note block
9. Jukebox signal output
10. Worked examples
11. Validation
12. Open questions

## 0. Conventions

- **Update vocabulary.** "`setBlockAndUpdate`" is a block write with flags 3 (29 section 2.2 and 3.5). "Flags 2" is a clients-only write that does not notify neighbours (29 section 1). "Update the neighbours at P" is `Level.updateNeighborsAt(P, block, orientation)`: it sends a neighbour-changed notification to the six neighbours of P (29 section 3). The orientation argument comes from `ExperimentalRedstoneUtils.initialOrientation` and only matters to the experimental wire evaluator of sibling part 1; this document states which direction and up direction it is built from and does not interpret it.
- **Signal methods.** `BlockBehaviour` defaults: `isSignalSource` false, `ownSignal` 0, `getDirectSignal` 0, and `getSignal(state, level, pos, direction)` returns `ownSignal(state, level, pos)` for every direction. So a block that overrides only `ownSignal` and `isSignalSource` powers weakly in all directions (a "weak" signal that reaches wire and, through a conductive block, repeaters and similar), and a block that also overrides `getDirectSignal` powers one neighbour "strongly" (read from `BlockBehaviour`; the strong and weak rules themselves are sibling part 1).
- **Sounds.** `playSound(entity, pos, sound, source)` without volume and pitch uses volume 1.0 and pitch 1.0 (read in `LevelAccessor`). A non-null first argument excludes that player from the sound packet (the server) or limits the sound to that player's own client (`ClientLevel`, see 8.6).
- **Game events** (`BLOCK_ACTIVATE`, `BLOCK_DEACTIVATE`, `BLOCK_CHANGE`, `NOTE_BLOCK_PLAY`, `LIGHTNING_STRIKE`): dispatched through `Level.gameEvent(entity or null, event, pos)`; the vibration listeners are sibling part 8 and 31 part 8.
- **Registry cross references.** Property lists, state counts and ids: 24 part 4 section 6.32 and 8.4 (11 wooden buttons), 24 part 3 section 7.5 (lever and stone button), 24 part 5 section 7.4 and 7.6 (weighted plates, daylight detector), 24 part 2 (note block), 24 part 8 (lightning rods and their shape). Block set type table: 24 part 3 section 6.
- **Push reaction.** All blocks of this document except the note block, the daylight detector, the target block and the jukebox have push reaction `POPPED` (24 rows). Piston behaviour: sibling part 2.

## 1. The face-attached base (lever and button)

`FaceAttachedHorizontalDirectionalBlock` is the base class of the lever and every button. Properties (sorted by name in the state order, 24 section 2): `face` (`AttachFace`: `floor` 0, `wall` 1, `ceiling` 2) and `facing` (a horizontal direction), plus the subclass's `powered`.

**Connected direction** `C(state)` (the direction from the block toward the side that it points away from; read in `getConnectedDirection`):

| `face` | `C` |
|---|---|
| `floor` | UP |
| `ceiling` | DOWN |
| `wall` | the value of `facing` |

The block hangs on the neighbour at `pos + opposite(C)`. So a `floor` button sits on the block below, a `ceiling` button hangs from the block above, and a `wall` block with `facing = north` is attached to the block to its south. (The switch table of the class maps `CEILING` to DOWN and `FLOOR` to UP; read in `FaceAttachedHorizontalDirectionalBlock$1`.)

**Survival** (`canSurvive`): the neighbour at `pos + opposite(C)` must have a sturdy face toward `C` (`isFaceSturdy(level, thatPos, C)`, the support rule of 24 part 1; for a `floor` block this is the top face of the block below).

**Shape update**: when the changed neighbour is the one in direction `opposite(C)` and `canSurvive` is false, the block becomes air (the block item drops through the normal break engine of 29 section 10.5); otherwise the default update.

**Placement** (`getStateForPlacement`): take the player's "nearest looking directions" (29 section 9.5, six directions ordered by how closely the look vector points along them). For each direction `d` in that order:

1. If `d` is vertical: `face` = `ceiling` when `d` is UP, else `floor`; `facing` = the player's horizontal direction.
2. Otherwise: `face` = `wall`, `facing` = `opposite(d)`.
3. The first candidate (all other properties at their defaults) for which `canSurvive(level, clickedPos)` is true is the result. If none survives the placement is refused.

Default state: `facing` north, `face` wall, `powered` false.

## 2. Lever

Properties `face`, `facing`, `powered`; default wall, north, false. The lever is a signal source (`isSignalSource` true).

### 2.1 Signals

| Query | Result |
|---|---|
| `ownSignal` (so `getSignal` in every direction) | 15 when `powered`, else 0 |
| `getDirectSignal(direction)` | 15 when `powered` and `direction == C(state)`, else 0 |

`direction` here is the direction from the asking block toward the lever. A block Q that is the support of the lever has the lever at `Q + C` (support is at `lever + opposite(C)`, so the lever is at `support + C`), so exactly the support block receives the strong power. Worked: a floor lever (`C` = UP) strongly powers the block below it; a wall lever facing north strongly powers the block to its south.

### 2.2 Use

`useWithoutItem` (right click with an empty hand or when the held item does not use the block):

1. **Client side:** compute the toggled state (`powered` flipped). When the new value is true, spawn the red dust particle with alpha 1.0 (2.5). Return SUCCESS. The client does not write the block.
2. **Server side:** `pull(state, level, pos, null)` and return SUCCESS. The player argument is **not** forwarded: the right-click path passes a null player (read: a null constant is pushed before the call), so for a lever nobody is excluded from the click sound and no entity is the actor of the game event. (Contrast the button, 3.3, which does forward the player.)

`pull` (also reached from explosions, 2.3):

1. `state' = state` with `powered` flipped.
2. `setBlockAndUpdate(pos, state')`.
3. Update the neighbours (2.4).
4. Play `block.lever.click` (source BLOCKS) with volume 0.3 and pitch 0.6 when `state'.powered`, else pitch 0.5; the `pull` player argument is the excluded entity, and it is always null for a lever (both the right click, 2.2 step 2, and the explosion, 2.3, pass null), so the server sends the sound to every player in range, the clicking player included. The client branch of the right click plays no sound (it only spawns the particle), so the clicking player hears the server's packet.
5. Game event `BLOCK_ACTIVATE` when `state'.powered`, else `BLOCK_DEACTIVATE`, with a null acting entity (the same null argument).

The lever never schedules a tick; it keeps its state until toggled again.

### 2.3 Explosion and removal

- `onExplosionHit`: when the explosion `canTriggerBlocks`, `pull(state, level, pos, null)`; then the default (the block is not destroyed by this). (Whether the block is removed afterwards is the default `onExplosionHit` of 29; the lever itself only pulls.)
- `affectNeighborsAfterRemoval(state, level, pos, movedByPiston)`: when the lever was `powered` and it was not moved by a piston, update the neighbours (2.4), so wires fall back.

### 2.4 Neighbour update pair

Let `s = opposite(C)` (the direction to the support). Both of these updates use the same orientation, built from direction `s` and the up direction `UP` when `s` is horizontal, else `FACING` (the lever's own `facing`):

1. update the neighbours at the lever's position;
2. update the neighbours at `pos + s` (the support block), because it is the strongly powered block.

### 2.5 Particles

`animateTick` (client only, every frame tick for each lever near the player): when `powered` and `random.nextFloat() < 0.25`, spawn the red dust particle with alpha 0.5. The particle (`DustParticleOptions`, colour 0xFF0000 = 16711680, scale = the alpha argument) spawns at

`(X + 0.5 + 0.1 * step(opposite(facing)) + 0.2 * step(opposite(C)), the same for Y and Z)` with zero velocity,

where `step(d)` is the integer unit vector of `d`. (Read as such in `makeParticle`; for a wall lever facing north, `opposite(facing)` = south and `opposite(C)` = south, so the particle sits 0.3 toward the south, i.e. against the wall.)

### 2.6 Shape

The outline does not depend on `powered`. The base box is `boxZ(6, 8, 10, 16)`: for a `wall` lever facing north, x 5 to 11, y 4 to 12, z 10 to 16 (pixels, sixteenths of a block). `rotateAttachFace` (read in `Shapes`) gives WALL = the horizontal turns of the base, FLOOR = the horizontal turns after `BLOCK_ROT_X_270` ((x, y, z) to (x, 16 - z, y)), CEILING = the horizontal turns after `BLOCK_ROT_Y_180` composed with `BLOCK_ROT_X_90`. The horizontal turns are NORTH as written, EAST (x, z) to (16 - z, x), SOUTH (16 - x, 16 - z), WEST (z, 16 - x); the group formulas are those of 24 part 4 section 2.4. For the ceiling the X turn (x, y, z) to (x, z, 16 - y) is applied first (the operand order traced in 24 part 4 section 2.4 and 6.32); the half turn about Y that follows maps this box onto itself because the box is symmetric in x and z about the block centre, so the order does not change the result. Evaluated (the lever's `facing` selects the horizontal turn; the wall box is the stated base turned, floor and ceiling were computed here from those formulas):

| `face` | `facing` | Box (pixels) |
|---|---|---|
| WALL | north | x 5 to 11, y 4 to 12, z 10 to 16 |
| WALL | east | x 0 to 6, y 4 to 12, z 5 to 11 |
| WALL | south | x 5 to 11, y 4 to 12, z 0 to 6 |
| WALL | west | x 10 to 16, y 4 to 12, z 5 to 11 |
| FLOOR | north or south | x 5 to 11, y 0 to 6, z 4 to 12 |
| FLOOR | east or west | x 4 to 12, y 0 to 6, z 5 to 11 |
| CEILING | north or south | x 5 to 11, y 10 to 16, z 4 to 12 |
| CEILING | east or west | x 4 to 12, y 10 to 16, z 5 to 11 |

That is all 24 states (the 8 `powered` and `facing`/`face` combinations repeat per `powered`), and it agrees with the boxes stated in 24 part 3 section 5.2 (floor north `box(5,0,4,11,6,12)`, ceiling north `box(5,10,4,11,16,12)`). The button's 24 outlines are the table of 24 part 4 section 6.32. The lever has no collision (24 part 3 section 7.5).

## 3. Buttons

15 blocks of class `ButtonBlock`. Properties `face`, `facing`, `powered`; default wall, north, false (24 part 4 section 6.32; `stone_button` 24 part 3 section 7.5). The block takes its sound type from its `BlockSetType` (24 part 3 section 6).

### 3.1 Table (constructor arguments, read from `Blocks`)

| Block | `BlockSetType` | Ticks to stay pressed | Arrows press it |
|---|---|---|---|
| `stone_button` | `stone` | 20 | no |
| `polished_blackstone_button` | `stone` (not `polished_blackstone`) | 20 | no |
| `oak_button`, `spruce_button`, `birch_button`, `jungle_button`, `acacia_button`, `cherry_button`, `dark_oak_button`, `pale_oak_button`, `mangrove_button`, `poplar_button`, `bamboo_button` | the set type of the same name | 30 | yes |
| `crimson_button`, `warped_button` | `crimson`, `warped` | 30 | yes |

Arrow rule: a button can be pressed by an arrow exactly when its set type's `canButtonBeActivatedByArrows` is true: true for the wood types (including cherry, crimson, warped, bamboo) and false for `iron`, `copper`, `gold`, `stone` and `polished_blackstone` (24 part 3 section 6). The polished blackstone button uses the `stone` set type (the lambda that builds it passes `BlockSetType.STONE`), so only its pressure plate (4.2) uses the `polished_blackstone` type; the two types have identical flags and sounds.

### 3.2 Signals

Same as the lever (2.1): `ownSignal` 15 when `powered` else 0; `getDirectSignal(direction)` is 15 when `powered` and `direction == C(state)`; the button is a signal source.

### 3.3 Press

`useWithoutItem`: when `powered`, return CONSUME and do nothing; otherwise `press(state, level, pos, player)` and return SUCCESS. (No side check: the client predicts the write, the server decides.)

`press(state, level, pos, player)`:

1. `setBlockAndUpdate(pos, state with powered = true)`.
2. Update the neighbours (3.7).
3. `scheduleTick(pos, block, ticksToStayPressed)` (default priority, 29 section 4).
4. Play the click-on sound of the set type (`buttonClickOn`) with volume 1.0 and pitch 1.0, source BLOCKS, excluding the pressing player (`playSound(player, ..., true)` passes the player as the excluded entity; the release passes none).
5. Game event `BLOCK_ACTIVATE` with the player.

Explosion: `onExplosionHit` presses the button (player null) when the explosion `canTriggerBlocks` and the button is not yet powered.

### 3.4 Scheduled tick (release and arrow re-check)

`tick(state, level, pos, random)`:

1. If not `powered`, return.
2. Otherwise `checkPressed(state, level, pos)` (3.5).

### 3.5 `checkPressed`

Inputs: the current state. Steps:

1. `arrowPresent`: if the set type allows arrows, take the button's current outline (the shape of the current state, its bounding box, moved to the block position) and look for entities of class `AbstractArrow` overlapping that box; `arrowPresent` is whether the first match exists. For types that do not allow arrows `arrowPresent` is false without any search.
2. `wasPowered` = the `powered` property.
3. If `arrowPresent != wasPowered`: write `powered = arrowPresent` with `setBlockAndUpdate`, update the neighbours (3.7), play the click sound (`buttonClickOn` when `arrowPresent`, else `buttonClickOff`; no excluded entity), and send game event `BLOCK_ACTIVATE` (new value true) or `BLOCK_DEACTIVATE`.
4. If `arrowPresent`: `scheduleTick(pos, block, ticksToStayPressed)` again.

So a stone button always releases `ticksToStayPressed` ticks after it was pressed; a wooden button releases at the first scheduled tick at which no arrow overlaps it, and while an arrow stays it re-arms itself every 30 ticks.

### 3.6 Arrows pressing a button (`entityInside`)

`entityInside(state, level, pos, entity, effectApplier, flag)` does something only when all hold: the level is the server level, the set type allows arrows, and the button is not `powered`. Then `checkPressed` (3.5) runs, which finds the arrow (the entity argument is not used for the decision) and presses the button (step 3 with `arrowPresent` true: the write, the neighbour update, the click-on sound, `BLOCK_ACTIVATE`, and the 30-tick re-arm). The engine that calls `entityInside` for entities whose box overlaps the block's outline is entity movement (18, 33; Open question 1). A powered wooden button is therefore kept pressed by arrows only through the scheduled re-check, not through `entityInside`.

### 3.7 Neighbour update pair and removal

`updateNeighbours` is identical to the lever's (2.4): the orientation is built from `opposite(C)` (UP when that is horizontal, else `facing`), then the neighbours at the button and at the support `pos + opposite(C)` are updated. After removal (`affectNeighborsAfterRemoval`), when the button was `powered` and was not moved by a piston, this update runs once.

### 3.8 Shape

For `wall` facing north the unpressed outline is the box `box(5,6,14,11,10,16)` (2 deep) and the pressed outline `box(5,6,15,11,10,16)` (1 deep), computed as a base box minus a cube (`ONLY_FIRST`): the base `boxZ(6, 4, 8, 16)` = `box(5,6,8,11,10,16)` minus `cube(12)` when unpowered or minus `cube(14)` when powered. The floor, ceiling and east and west forms: 24 part 4 section 6.32 (worked there). No collision.

## 4. Pressure plates

### 4.1 `BasePressurePlateBlock` (shared)

Constants: the outline of an unpressed plate is `column(14, 0, 1)` = `box(1,0,1)-(15,1,15)`, of a pressed plate `column(14, 0, 0.5)` = `box(1,0,1)-(15,0.5,15)`; "pressed" means `getSignalForState(state) > 0`. The **touch box** is the first box of `column(14, 0, 4)`, i.e. `box(1,0,1)-(15,4,15)`, moved to the plate's position, so it is 4 sixteenths tall, narrower than the block by one sixteenth on each horizontal side. Collision: none (24 rows). The constructor applies the set type's sound type.

| Aspect | Rule |
|---|---|
| Survival | `canSurvive`: the block below supports a rigid block on its upper face (`canSupportRigidBlock`) or supports the centre of its upper face (`canSupportCenter(UP)`). `updateShape` toward DOWN returns air when `canSurvive` is false; otherwise the default. |
| `isPossibleToRespawnInThis` | true |
| `getPressedTime` | 20 ticks (the weighted plate overrides it, 4.3) |
| Signal source | yes; `ownSignal` = `getSignalForState(state)`; `getDirectSignal(direction)` = `getSignalForState(state)` when `direction` is UP, else 0 (the block above the plate is strongly powered) |
| `getSignalStrength(level, pos)` | subclass |
| `getSignalForState`, `setSignalForState` | subclass |
| Neighbour update | the neighbours at the plate and at `pos.below()` (no explicit orientation is built) |
| After removal | when not moved by a piston and `getSignalForState > 0`, run the neighbour update |

**`entityInside(state, level, pos, entity, effectApplier, flag)`:** client side: nothing. Server side: `old = getSignalForState(state)`; when `old == 0` run `checkPressed(entity, level, pos, state, old)`. A plate that is already pressed ignores `entityInside`; it is re-evaluated by its scheduled tick.

**`tick(state, level, pos, random)`:** `old = getSignalForState(state)`; when `old > 0` run `checkPressed(null, level, pos, state, old)`, else nothing.

**`checkPressed(entity, level, pos, state, old)`:**

1. `new = getSignalStrength(level, pos)`.
2. `wasOn = old > 0`, `isOn = new > 0`.
3. If `old != new`: write `setSignalForState(state, new)` with flags 2, update the neighbours (the plate and the block below), then `level.setBlocksDirty(pos, oldState, newState)` (the "blocks dirty" notification, 4.4).
4. If `!isOn && wasOn`: play the set type's `pressurePlateClickOff` (volume 1.0, pitch 1.0, source BLOCKS, no excluded entity) and game event `BLOCK_DEACTIVATE` with `entity` (possibly null). Else if `isOn && !wasOn`: play `pressurePlateClickOn` and game event `BLOCK_ACTIVATE` with `entity`.
5. If `isOn`: `scheduleTick(pos, block, getPressedTime())`.

Observations: writes use flags 2 (clients only) and notify neighbours through the explicit neighbour update, so the plate changes `power` of a weighted plate from 4 to 5 without a sound (only the on and off edges sound); the re-check keeps running as long as something stands on the plate; an `entityInside` call on a pressed plate never changes anything.

The entity-counting helper `getEntityCount(level, box, class)` counts entities of the given class that overlap `box`, with the filter "not a spectator and `isIgnoringBlockTriggers()` is false". `Entity.isIgnoringBlockTriggers` is false for every entity except: `Display` (and so all display entities), `Interaction`, `Marker`, `OminousItemSpawner` (true), and `ArmorStand` (true when it is a marker armour stand), and `Bat` (`net.minecraft.world.entity.ambient.Bat`, true unconditionally). A bat therefore never presses a plate and is not counted by a weighted plate (`Bat` returns true unconditionally, `ArmorStand` returns `isMarker()`). That is six overriding classes (five unconditional, one conditional). Outside the entity package only `BasePressurePlateBlock` and `TripWireBlock` mention the method. (Verified by a full method-listing scan of every `net.minecraft` class: exactly these six overrides plus the base method in `Entity`.)

### 4.2 `PressurePlateBlock` (on and off, 15 blocks)

Property `powered`, default false. `getSignalForState` = 15 when powered else 0; `setSignalForState` sets `powered` to `signal > 0`. Signal strength:

- set type sensitivity `EVERYTHING`: the count of **all** entities (class `Entity`) in the touch box, after the filter of 4.1;
- sensitivity `MOBS`: the count of `LivingEntity` instances in the touch box, after the same filter;
- the result is 15 when the count is above 0, else 0.

(The sensitivity is read through a switch table in `PressurePlateBlock$1`: `EVERYTHING` selects `Entity`, `MOBS` selects `LivingEntity`.) A player in spectator mode is excluded; dropped items, arrows, boats, minecarts and other non-living entities count for `EVERYTHING` plates and do not count for `MOBS` plates.

| Plate | `BlockSetType` | Sensitivity |
|---|---|---|
| `stone_pressure_plate` | `stone` | MOBS |
| `polished_blackstone_pressure_plate` | `polished_blackstone` | MOBS |
| `oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `mangrove`, `poplar`, `bamboo` `_pressure_plate` | the same-named wood set type | EVERYTHING |
| `crimson_pressure_plate`, `warped_pressure_plate` | `crimson`, `warped` | EVERYTHING |

Click sounds come from the set type: `block.stone_pressure_plate.click_on/off` for `stone` and `polished_blackstone`, `block.wooden_pressure_plate.click_on/off` for the plain woods, the `cherry_wood_`, `nether_wood_` and `bamboo_wood_` variants for those types (24 part 3 section 6). Pressed time is 20 ticks.

### 4.3 `WeightedPressurePlateBlock` (light and heavy)

Property `power` 0 to 15 (default 0); field `maxWeight` from the constructor.

| Block | `maxWeight` | `BlockSetType` | Pressed time |
|---|---|---|---|
| `light_weighted_pressure_plate` | 15 | `gold` | 10 ticks |
| `heavy_weighted_pressure_plate` | 150 | `iron` | 10 ticks |

`getSignalForState` = `power`; `setSignalForState` writes `power`. Signal strength (`getSignalStrength`):

1. `n` = the number of entities of class `Entity` (every kind) in the touch box, after the filter of 4.1 (a weighted plate has no `MOBS` mode).
2. `s = min(n, maxWeight)`.
3. If `s <= 0`: 0.
4. Otherwise `strength = ceil( (float(min(maxWeight, s)) / float(maxWeight)) * 15.0f )`, computed in 32-bit float arithmetic, and the ceiling is `Mth.ceil(float)` (convert to double, `Math.ceil`, truncate to int).

Because the arithmetic is float, the results are exact thresholds, not the real-number ones. Computed from that formula with IEEE 754 binary32 operations:

| Plate | Entity count `n` to reach each `power` |
|---|---|
| light (`maxWeight` 15) | `power` = `min(n, 15)` for `n` from 0 to 15 (1 entity gives 1, 2 gives 2, ... 15 gives 15; more than 15 stay at 15) |
| heavy (`maxWeight` 150) | `n` = 0: 0; 1 to 10: 1; 11 to 20: 2; 21 to 30: 3; 31 to 40: 4; 41 to 50: 5; 51 to 60: 6; 61 to 70: 7; 71 to 80: 8; 81 to 90: 9; 91 to 100: 10; 101 to 110: 11; 111 to 120: 12; 121 to 130: 13; 131 to 140: 14; 141 or more: 15 |

(The thresholds were computed by evaluating the formula in single precision for every `n` from 0 to 153; the rows above are the full result.)

Weighted plates sound with the metal click sounds (`block.metal_pressure_plate.click_on/off`) for both `gold` and `iron`, and make their re-check every 10 ticks while pressed.

### 4.4 `setBlocksDirty`

`Level.setBlocksDirty(pos, oldState, newState)` is called after a plate's state change. In `Level` the method has an empty body and `ServerLevel` does not override it, so on the server it does nothing. `ClientLevel` overrides it and forwards the position, old state and new state to the render extractor's `setBlockDirty`, which marks the affected section for re-render. Nothing in the artifact ties it to pathfinding. It is not a block update.

## 5. Daylight detector

One block `daylight_detector` (`DaylightDetectorBlock`), properties `power` 0 to 15 and `inverted` (default 0 and false); block entity `daylight_detector` (`DaylightDetectorBlockEntity` has only a constructor and no data). Outline `column(16, 0, 6)` = `box(0,0,0)-(16,6,16)`; `useShapeForLightOcclusion` is true. Signal source: `ownSignal` = `power` (so every direction, weak). Block rows: 24 part 5 section 7.6 (which also repeats the formula below; this section is the read-again version and agrees with it).

**Ticker.** `getTicker` returns a ticker only when the level is a server level and the dimension has sky light. The ticker runs every tick and, when `gameTime mod 20 == 0`, calls `updateSignalStrength(state, level, pos)`. So the output changes only on game ticks that are multiples of 20 and the first update after placement is on the next such tick.

**`updateSignalStrength`:**

1. `s` = `Level.getEffectiveSkyBrightness(pos)` (an integer 0 to 15; 32 section "Daylight detector").
2. `a` = `float(SUN_ANGLE attribute value at the level) * 0.017453292f` (single precision; the attribute is in degrees, 12 and 23).
3. If `inverted`: `s = 15 - s`. (The sun angle is read but unused.)
4. Else if `s > 0`: `target = 0` when `a < 3.1415927f`, else `6.2831855f`; `a = a + (target - a) * 0.2f` (single precision); `s = round(float(s) * cos(a))`, where `cos` is the table `Mth.cos(double)` of 11 (trigonometry) and `round` is `Math.round(float)` (the integer nearest, ties upward: `floor(x + 0.5)`).
5. `s = clamp(s, 0, 15)`.
6. If `s != power`, write `power = s` with `setBlockAndUpdate`; otherwise do nothing.

**Use.** `useWithoutItem`: if the player cannot build (`mayBuild` false), the default (`BaseEntityBlock`) result. Else on the server side: write `inverted` flipped with flags 2, send game event `BLOCK_CHANGE` with the player and the new state as context, and call `updateSignalStrength` at once (so the output changes immediately, whatever the tick phase). Return SUCCESS on both sides.

## 6. Target block

One block `target` (`TargetBlock`), property `power` 0 to 15 (named `OUTPUT_POWER`, default 0); a signal source with `ownSignal` = `power`; no direct signal. Constants: arrow duration 20 ticks, other projectiles 8 ticks.

**Projectile hit.** `Projectile.onHitBlock(hitResult)` calls `state.onProjectileHit(level, state, hitResult, projectile)` for the hit block; this is the only trigger (so every projectile type whose `onHitBlock` reaches the base method, including arrows and wind charges, triggers it; the subclass overrides read for arrows and wind charges both call the base method). The target block's handler:

1. `strength` = `getRedstoneStrength(hitResult, hitLocation)` (6.1).
2. `duration` = 20 when the projectile is an `AbstractArrow` (every arrow type), else 8.
3. If the block has no scheduled tick pending at the hit position (`getBlockTicks().hasScheduledTick(pos, block)` false): write `power = strength` with `setBlockAndUpdate` and `scheduleTick(pos, block, duration)`. If a tick is already pending nothing is written and the pending tick keeps its time; the strength is not raised.
4. If the projectile's owner is a `ServerPlayer`: award the statistic `target_hit` and fire the criterion trigger `target_block_hit` with the hit location and the strength (the strength of step 1 even when step 3 skipped the write).

**Release.** `tick`: when `power != 0`, write `power = 0` with `setBlockAndUpdate`; otherwise nothing.

**On placement** (`onPlace`, server side only; skipped when the previous state is already this block): when `power > 0` and no tick is scheduled, write `power = 0` with flags 18 (clients only, no neighbour shape update, no neighbour notification).

### 6.1 Strength from the hit position

Input: the hit location `(x, y, z)` in world coordinates and the face `d` that was hit. Let `fx = |frac(x) - 0.5|`, `fy`, `fz` likewise (`frac(v) = v - floor(v)`). The deviation `m` from the centre of the hit face is the larger of the two deviations on the axes other than the face's axis:

| Face axis | `m` |
|---|---|
| Y (top, bottom) | `max(fx, fz)` |
| Z (north, south) | `max(fx, fy)` |
| X (east, west) | `max(fy, fz)` |

`strength = max(1, ceil( 15 * clamp((0.5 - m) / 0.5, 0, 1) ))`, in double precision with `Mth.ceil(double)`. The centre of a face (m = 0) gives 15; a hit at the very edge (m = 0.5) gives 1 because of the floor of 1. The strength is `k` when `m` lies in `[(15-k)/30, (16-k)/30)` for `k` from 2 to 15 (`m < 1/30` gives 15, since `m = 1/30` gives `ceil(14) = 14`; `m >= 14/30` gives 1, since `m = 14/30` gives `ceil(1) = 1`); at a boundary the double rounding of the subtraction decides, so an implementation that wants exact agreement must use the same double operations.

## 7. Lightning rod

Blocks: the weathering collection `lightning_rod` (4 weathering stages, plain and waxed: 8 blocks, ids in 24 part 8). `LightningRodBlock` extends `RodBlock`; `WeatheringLightningRodBlock` is the plain-stage subclass (24 part 4 section 5.5 for the weathering engine). Properties `facing` (6 directions, default UP), `powered` (default false) and `waterlogged` (default false); outline `cube(4,4,16)` along the facing axis (24 part 8). Constants: activation ticks 8, search range 128, spark cycle 200.

| Aspect | Rule |
|---|---|
| Placement | `facing` = the clicked face; `waterlogged` = whether the fluid at the position is water |
| Shape update | when waterlogged, schedule a water tick (the flowing-fluid tick delay) before the default |
| Fluid | water source when waterlogged, else the default |
| Signal source | yes |
| `ownSignal` | 15 when `powered`, else 0 (weak, all directions) |
| `getDirectSignal(direction)` | 15 when `powered` and `direction == facing`, else 0 |

### 7.1 Being struck

`onLightningStrike(state, level, pos)`:

1. Write `powered = true` with `setBlockAndUpdate`.
2. Update the neighbours at `pos + opposite(facing)` (the support) with an orientation built from `opposite(facing)` and no second axis (the up argument is null, read: `initialOrientation(level, opposite(facing), null)`).
3. `scheduleTick(pos, block, 8)`.
4. Send level event 3002 with data = the ordinal of `facing`'s axis (X 0, Y 1, Z 2).

The caller is the `LightningBolt` entity: in the tick where its `life` equals 2, on the server, after the optional fire start, `powerLightningRod` takes the strike position `containing(x, y - 0.000001, z)` of the bolt and, when the block there is a `LightningRodBlock` (any weathering stage and waxed or not), calls `onLightningStrike` once. The bolt then clears copper at the strike position (7.6) and sends game event `LIGHTNING_STRIKE`. A bolt that strikes a rod anywhere in the rod's column of influence, i.e. wherever the redirect of 7.3 sent it, ends at the rod's own position plus one block (7.3), so `y - 0.000001` falls in the rod's block.

### 7.2 Release and persistence

- `tick`: write `powered = false` with `setBlockAndUpdate` and update the neighbours as in 7.1 step 2. It is the only thing that clears `powered`.
- `onPlace` (skipped when the previous state is the same block): when `powered` and no tick is pending, schedule a tick with delay 8 (so a rod that arrives powered in a chunk releases).
- `affectNeighborsAfterRemoval`: when `powered`, run the update of 7.1 step 2.

The pulse therefore lasts exactly 8 ticks from the strike, and a second strike while powered writes the same state and schedules another tick (the tick queue holds both; the first clears `powered`, the second finds it already clear and writes it again).

### 7.3 Redirect: the rod search

This is the code reached by `ServerLevel.findLightningTargetAround(pos)` (called from the thunder schedule, 33 section 4). The rod-related step, read here:

1. `heightPos` = the position at the column's `MOTION_BLOCKING` heightmap (`getHeightmapPos`).
2. The point-of-interest manager is asked for the closest POI of type `lightning_rod` (occupancy ANY, i.e. including POIs with no free tickets) within **128 blocks** of `heightPos`, among POIs whose y equals the `WORLD_SURFACE` height of their own column minus 1 (the rod must be the top block of its column).
3. "Within 128" is a **sphere** test: the POI candidates come from the square of side 2*128 centred on the origin (chunk sections), then are filtered by squared distance `<= 128 * 128` (read in `PoiManager.getInRange`); the winner is the one with the smallest distance to `heightPos` (`Comparator.comparingDouble`; ties are decided by the stream order, Open question 5).
4. The target is that rod's position plus one block upward (`above(1)`).
5. If there is such a rod it is the target and the animal and mob steps of 33 section 4 do not run for the redirect (the later steps of that method run only when no rod was found).

The strike position of the bolt is the bottom centre of that target block, so the bolt's `y - 0.000001` lies in the block below it, which is the rod (7.1).

The skeleton-trap rule of the same schedule refuses a trap when the block under the target is in the block tag `lightning_rods` (33 section 4 step 5), so a strike directed to a rod never spawns a trap.

### 7.4 Weathering rod

`WeatheringLightningRodBlock`: randomly ticked only when the weathering collection has a next stage for the block (`isRandomlyTicking`: `WeatheringCopper.getNext(block)` is present); `randomTick` calls `changeOverTime` (24 part 4 section 5.5). It adds no behaviour to the strike. The waxed rods are plain `LightningRodBlock`.

### 7.5 Client effects

Level event 3002 (client, `LevelEventHandler`): when the data is a valid axis ordinal (0 to 2), spawn `electric_spark` particles along that axis: `ParticleUtils.spawnParticlesAlongAxis(axis, level, pos, 0.125, ELECTRIC_SPARK, UniformInt(10, 19))`; otherwise spawn `electric_spark` on the block's faces with `UniformInt(3, 5)` per face. The data -1 sent by the copper cleaning of 7.6 takes this second branch (it is the copper-cleaning spark). Particle details: 42 part 6.

`animateTick`: when `level.isThundering()` and `random.nextInt(200) <= gameTime mod 200` and the rod's y equals `WORLD_SURFACE height(x, z) - 1`, spawn `electric_spark` along the rod's axis with offset 0.125 and `UniformInt(1, 2)` particles. The probability per frame tick is `(g + 1) / 200` where `g = gameTime mod 200`.

### 7.6 Copper cleaning after a strike

`LightningBolt.clearCopperOnLightningStrike(level, strikePos)` runs in the same tick as the strike (7.1), after `powerLightningRod`. It has two parts.

1. **Strike block.** Nothing happens unless the block at the strike position is a `WeatheringCopper` block or has an entry in the `HoneycombItem` wax-off map (so a waxed block passes the test). When it is a `WeatheringCopper` block it is replaced with `WeatheringCopper.getFirst` of its state (the unweathered state) by `setBlockAndUpdate`. A waxed block is not changed by this step.
2. **Random walks.** `3 + nextInt(3)` walks run (3 to 5), each starting at the strike position. A walk takes `nextInt(8) + 1` steps (1 to 8). A step takes up to 10 random positions from `BlockPos.randomInCube(random, 10, current, 1)` (the cube of radius 1 around the current position) and picks the first whose block is `WeatheringCopper`. That block is set with `setBlockAndUpdate` to `WeatheringCopper.getPrevious` of its state (one stage less weathered; no change if there is none), level event 3002 is sent at it with data -1, and the walk moves to that position. When none of the samples matches, the walk ends.

The test of part 1 gates the whole method: when the strike block is neither weathering copper nor waxed (wax-off map entry), the method returns before the walks, so the walks run only for those two kinds of strike block.

## 8. Note block

One block `note_block` (`NoteBlock`) with properties `instrument` (27 values), `powered` and `note` (0 to 24); defaults harp, false, 0; state id formula in 24 part 2. Constant `NOTE_VOLUME` 3.

### 8.1 Instruments (`NoteBlockInstrument`, in enum order)

The property value order is the declaration order, the serialized name is in the second column. Type `BASE_BLOCK` instruments are tunable; type `MOB_HEAD` and `CUSTOM` are not. Sound event ids are the resource locations of the `SoundEvents` constants (read), and the sound files are data (the tool).

| # | Name | Sound event | Type |
|---|---|---|---|
| 0 | `harp` | `block.note_block.harp` | BASE_BLOCK |
| 1 | `basedrum` | `block.note_block.basedrum` | BASE_BLOCK |
| 2 | `snare` | `block.note_block.snare` | BASE_BLOCK |
| 3 | `hat` | `block.note_block.hat` | BASE_BLOCK |
| 4 | `bass` | `block.note_block.bass` | BASE_BLOCK |
| 5 | `flute` | `block.note_block.flute` | BASE_BLOCK |
| 6 | `bell` | `block.note_block.bell` | BASE_BLOCK |
| 7 | `guitar` | `block.note_block.guitar` | BASE_BLOCK |
| 8 | `chime` | `block.note_block.chime` | BASE_BLOCK |
| 9 | `xylophone` | `block.note_block.xylophone` | BASE_BLOCK |
| 10 | `iron_xylophone` | `block.note_block.iron_xylophone` | BASE_BLOCK |
| 11 | `cow_bell` | `block.note_block.cow_bell` | BASE_BLOCK |
| 12 | `didgeridoo` | `block.note_block.didgeridoo` | BASE_BLOCK |
| 13 | `bit` | `block.note_block.bit` | BASE_BLOCK |
| 14 | `banjo` | `block.note_block.banjo` | BASE_BLOCK |
| 15 | `pling` | `block.note_block.pling` | BASE_BLOCK |
| 16 | `trumpet` | `block.note_block.trumpet` | BASE_BLOCK |
| 17 | `trumpet_exposed` | `block.note_block.trumpet_exposed` | BASE_BLOCK |
| 18 | `trumpet_oxidized` | `block.note_block.trumpet_oxidized` | BASE_BLOCK |
| 19 | `trumpet_weathered` | `block.note_block.trumpet_weathered` | BASE_BLOCK |
| 20 | `zombie` | `block.note_block.imitate.zombie` | MOB_HEAD |
| 21 | `skeleton` | `block.note_block.imitate.skeleton` | MOB_HEAD |
| 22 | `creeper` | `block.note_block.imitate.creeper` | MOB_HEAD |
| 23 | `dragon` | `block.note_block.imitate.ender_dragon` | MOB_HEAD |
| 24 | `wither_skeleton` | `block.note_block.imitate.wither_skeleton` | MOB_HEAD |
| 25 | `piglin` | `block.note_block.imitate.piglin` | MOB_HEAD |
| 26 | `custom_head` | `ui.button.click` (a placeholder, never played: 8.5) | CUSTOM |

Note the order: `trumpet_oxidized` (18) precedes `trumpet_weathered` (19). Predicates: `isTunable` = type is `BASE_BLOCK`; `hasCustomSound` = type is `CUSTOM`; `worksAboveNoteBlock` = type is not `BASE_BLOCK` (true for the six mob heads and `custom_head`).

The instrument of each block is a builder setting `instrument(...)` on the block's properties (default `harp`); the per-block values (for example `note_block` itself is `bass`, the copper trumpet blocks are the four `trumpet_*` values) are the Instrument column of the 24 documents (24 part 2 section 5 and the later parts). A scan of `Blocks` shows the setting in use for `BASS`, `BASEDRUM`, `SNARE`, `HAT` and the four trumpet values among others; the full per-block assignment is not repeated here (Open question 2).

### 8.2 Choosing the instrument

`setInstrument(level, pos, state)` (placement and vertical shape updates):

1. `above` = the instrument setting of the block state at `pos + up`. If `above.worksAboveNoteBlock` (a mob head or the custom head above), the result is `state` with `instrument = above`.
2. Otherwise `below` = the instrument setting of the block state at `pos + down`; the result's instrument is `harp` when `below.worksAboveNoteBlock` (a head below), else `below`.

(24 part 2 section 7.10 states the same rule.) Hooks: placement (`getStateForPlacement` applies it to the default state); `updateShape`: when the changed neighbour lies on the Y axis, the new state is the result of `setInstrument` (the note and powered values are kept, since it starts from the current state); horizontal neighbour changes use the default update.

### 8.3 Powering

`neighborChanged(state, level, pos, block, orientation, movedByPiston)`:

1. `powerNow = level.hasNeighborSignal(pos)` (sibling part 1: true when any of the six neighbours supplies a signal to this position, strong or weak, including the quasi-connectivity rule of that part).
2. If `powerNow != powered`: when `powerNow` is true, run `playNote(null, state, level, pos)`; then in either case write `powered = powerNow` with `setBlockAndUpdate`.

So a note plays on the rising edge only, never on the falling edge, and the sound is sent before the state is rewritten.

### 8.4 Playing and tuning

`playNote(entity, state, level, pos)`: when the block's instrument `worksAboveNoteBlock` **or** the block at `pos + up` is air: queue a block event at `pos` for this block with event id 0 and parameter 0 (`level.blockEvent(pos, block, 0, 0)`; processed in the block-event phase, 29 section 6) and send game event `NOTE_BLOCK_PLAY` with `entity`. Otherwise (a non-head instrument with a solid block above) nothing happens: the note block is muted by a block above it unless that block is a head.

- **Right click** (`useWithoutItem`, server side): `note = (note + 1) mod 25` (`cycle`), `setBlockAndUpdate`, `playNote(player, newState, ...)`, award the statistic `tune_noteblock`; return SUCCESS on both sides (the client does nothing but succeed).
- **Left click** (`attack`, server side only): `playNote(player, state, ...)` and the statistic `play_noteblock`. No state change.
- `useItemOn` returns PASS (the right click goes on to the block) when the held item is in the item tag `note_block_top_instruments` and the clicked face is UP (so a head can be placed on the top); every other held item takes the base item-use path.

### 8.5 The block event (`triggerEvent`)

The event runs on the server when the event queue is drained, and runs again on every client that receives the block event packet. Event id and parameter are ignored.

1. `instrument` = the block's instrument. If `isTunable`: `note` = the block's `note`; pitch `p = getPitchFromNote(note)`; add the particle `note` at `(X + 0.5, Y + 1.2, Z + 0.5)` with velocity `(note / 24.0, 0, 0)` (the first velocity component selects the particle colour on the client; `Level.addParticle` only has an effect on the client). Else (not tunable): `p = 1.0`, no particle.
2. If `hasCustomSound` (`custom_head`): the sound id is `getCustomSoundId` = the note block sound stored by the skull block entity at `pos + up` (`SkullBlockEntity.getNoteBlockSound`, 31 part 3); if the block entity at `pos + up` is not a skull or has no sound, the event **returns false** (no sound and no packet: `ServerLevel.runBlockEvents` sends the block event packet to the players in range only when `doBlockEvent`, which returns the value of `BlockState.triggerEvent`, returns true; 29 section 6). Otherwise the sound is a variable-range event built from that id.
3. Otherwise the sound is the instrument's sound event.
4. `level.playSeededSound(null, X + 0.5, Y + 0.5, Z + 0.5, sound, source RECORDS, volume 3.0, pitch p, seed = level.getRandom().nextLong())`; return true.

Two effects follow. On the server `playSeededSound` with no excluded player broadcasts a sound packet to the players within the sound's audible range (`getRange(3.0)`), seed included; on a client `playSeededSound` plays locally only when the excluded entity is the local player, and the null entity of the note block therefore plays nothing there: the sound a player hears is the server's packet. The server consumes one `nextLong` from the level's random per played note. (Where the block event packet is built and which clients receive it: 29 section 6 and 05a.)

**Pitch** `getPitchFromNote(n) = float(2^((n - 12) / 12))` (`Math.pow` in double, converted to float). Values (single precision, seven decimals):

| note | pitch | note | pitch | note | pitch |
|---|---|---|---|---|---|
| 0 | 0.5000000 | 9 | 0.8408964 | 18 | 1.4142135 |
| 1 | 0.5297316 | 10 | 0.8908987 | 19 | 1.4983071 |
| 2 | 0.5612310 | 11 | 0.9438743 | 20 | 1.5874010 |
| 3 | 0.5946035 | 12 | 1.0000000 | 21 | 1.6817929 |
| 4 | 0.6299605 | 13 | 1.0594631 | 22 | 1.7817974 |
| 5 | 0.6674199 | 14 | 1.1224620 | 23 | 1.8877486 |
| 6 | 0.7071068 | 15 | 1.1892071 | 24 | 2.0000000 |
| 7 | 0.7491536 | 16 | 1.2599211 | | |
| 8 | 0.7937005 | 17 | 1.3348398 | | |

`SoundEngine.calculatePitch` clamps the instance pitch to the range 0.5 to 2.0 (`Mth.clamp`), so the note pitches 0.5 to 2.0 are never altered by it.

### 8.6 Particle and sound summary

| What | Where | Value |
|---|---|---|
| Particle | `note` at `(X+0.5, Y+1.2, Z+0.5)` | x velocity `note/24.0`; only for tunable instruments |
| Sound | `(X+0.5, Y+0.5, Z+0.5)` | source RECORDS, volume 3.0, pitch from 8.5, seeded |
| Game event | the block | `NOTE_BLOCK_PLAY` with the actor |

## 9. Jukebox signal output

Block `jukebox` (`JukeboxBlock`, property `has_record`); the song player, insertion, ejection and playback events are 31 part 4 section 2. Redstone aspects only:

| Aspect | Rule |
|---|---|
| Signal source | yes |
| `ownSignal` (weak power in all directions) | 15 when the block entity at the position is a `JukeboxBlockEntity` whose song player `isPlaying` (a song is set); else 0. It does not depend on `has_record`: a jukebox that holds a disc whose song has ended gives 0. |
| `hasAnalogOutputSignal` | true |
| `getAnalogOutputSignal` (what a comparator reads) | `JukeboxBlockEntity.getComparatorOutput()`: the `comparator_output` value (0 to 15) of the song named by the disc stack's `jukebox_playable` component, or 0 when the slot is empty or the stack has no song. It does not depend on whether the song is playing: it is the disc's own output while the disc is inside, also after the song ended (31 part 4 section 2 worked example 2). |
| Neighbour updates | none from this class when `has_record` changes beyond what the block entity does (31 part 4); after removal, `Containers.updateNeighboursAfterDestroy` (as for containers). |

## 10. Worked examples

1. **Wall lever.** A lever `face=wall, facing=north` at (10, 64, 10). `C` = north. Support is `pos + south` = (10, 64, 11); the support block's `getDirectSignal(NORTH)` query, which looks at the lever at (10, 64, 10), returns 15 once powered. A right click on the server writes `powered = true`, updates the neighbours at (10,64,10) and (10,64,11) with orientation (south, up), plays `block.lever.click` at volume 0.3, pitch 0.6, sends `BLOCK_ACTIVATE`. A second click gives pitch 0.5 and `BLOCK_DEACTIVATE`.
2. **Placement of a lever.** The player looks mostly down at the top of a stone block: the first looking direction is DOWN (a vertical direction), so the candidate is `face=floor`, `facing` = the player's horizontal direction. It survives when the block below has a sturdy top face. If the player looks mostly north, the first candidate is `wall` with `facing = south` (the opposite of the looking direction): `C` = south, so the support is `pos + north`, the block the player looks at.
3. **Stone button.** Pressed at game tick T: written powered at T, tick scheduled for T+20, click-on sound; at T+20 `tick` runs `checkPressed` with no arrow search (stone type) so `arrowPresent` is false; the button is rewritten unpowered, neighbours updated, `block.stone_button.click_off` plays, `BLOCK_DEACTIVATE`. Pressing it again between T and T+20 returns CONSUME.
4. **Wooden button and an arrow.** An arrow sticks in the side of an oak button's box at tick T (not powered): `entityInside` runs `checkPressed`, the arrow is found, the button powers and a tick is scheduled for T+30. At T+30 the arrow is still inside the box: `arrowPresent` equals `powered`, nothing is written, a new tick is scheduled for T+60. If the arrow is removed before T+60 the button releases at T+60 with the click-off sound.
5. **Heavy weighted plate.** 25 non-spectator entities (including dropped items) stand on it: `s = 25`, `25f/150f*15f = 2.5` and the ceiling is 3, so `power = 3` (row 21 to 30). A light plate with 3 entities has `power = 3`. Each state change of `power` notifies the plate and the block below; only the 0 to positive and positive to 0 edges play a sound.
6. **Plate re-check.** A wooden plate with a player standing on it: `entityInside` fires while unpressed, `checkPressed` writes `powered`, plays click-on, schedules at +20. At +20 `tick` sees `old = 15`, `new = 15` (the player is still inside the touch box): nothing is written and a new tick is scheduled at +20 again. When the player leaves, the next tick writes `powered = false`, plays click-off and `BLOCK_DEACTIVATE` with a null entity and stops rescheduling.
7. **Target block.** An arrow hits the top face at x frac 0.75, z frac 0.5: `fx = 0.25`, `fz = 0`, `m = 0.25`, `strength = max(1, ceil(15 * 0.5)) = 8`. The block writes `power = 8` and is released after 20 ticks (an arrow); a snowball would release after 8. A second arrow in the next 20 ticks writes nothing but still fires the player criterion with its own strength. A hit on the exact centre of a face gives 15; a hit with `m` just above 1/30 (for example 0.0334) gives 14.
8. **Lightning rod.** A thunderstorm picks a position; `findLightningRod` finds a rod 90 blocks away that is its column's top block: the strike is redirected to the block above the rod. At `life = 2` of the bolt `onLightningStrike` writes `powered = true`, updates the support block's neighbours, schedules a tick for 8 ticks later, and sends event 3002 with the axis ordinal (1 for an upward rod). After 8 ticks `tick` writes `powered = false`. Rods that are not the top block of their column are never chosen, since they fail the height condition of 7.3.
9. **Note block.** A note block with air above, a zombie head below it: `above` is air (instrument harp, tunable, does not work above), `below` is the zombie head block whose instrument is `zombie` (works above a note block), so the result is `harp` (a head below gives harp). With a zombie head above it: `instrument = zombie`; powered, the event plays `block.note_block.imitate.zombie` at pitch 1.0 with no particle. A harp note block with a solid block above (not a head) is muted: `playNote` queues nothing. Note 5 with a bell below: pitch 0.6674199, particle velocity 5/24.
10. **Daylight detector.** Full sky brightness (15). Not inverted: sun angle 0 degrees gives `a = 0`, `target = 0`, `a = 0`, `cos = 1`, `power = 15`; 45 degrees gives `a = 0.7854`, `a = 0.7854 + (0 - 0.7854) * 0.2 = 0.6283`, `cos = 0.809`, `15 * 0.809 = 12.13`, round 12; 90 degrees gives `a = 1.2566`, `cos = 0.309`, 4.6 rounds to 5; 180 degrees gives `a` = 3.1415927 (not below pi) so the target is 6.2831855, `a = 3.7699`, `cos` negative, the product is negative, round and clamp give 0; 270 degrees gives `a = 5.0265` and 5. Inverted at the same sky brightness 15: `s = 0` whatever the angle; at brightness 0: `s = 15`.
11. **Jukebox.** A jukebox holds `music_disc_13` and the song is playing: `ownSignal` 15 (weak power to neighbours), a comparator beside it reads `comparator_output` 1. After the song ends (31 part 4: tick offset 3580) `ownSignal` is 0 and a comparator still reads 1.

## 11. Validation

| # | Check | Expected |
|---|---|---|
| V1 | Count of button blocks built by `ButtonBlock` in `Blocks` | 15 (stone, polished blackstone, 11 woods, crimson, warped) |
| V2 | Count of `PressurePlateBlock` constructions in `Blocks` | 15; `WeightedPressurePlateBlock`: 2 (150 with `iron`, 15 with `gold`) |
| V3 | Button ticks | 20 for the two stone-type buttons, 30 for the 13 wood-type buttons (read from the bipush argument of each construction) |
| V4 | `BlockSetType` of the polished blackstone button | `stone` (not `polished_blackstone`); the polished blackstone plate uses `polished_blackstone` |
| V5 | Plate filter | `Entity` for `EVERYTHING`, `LivingEntity` for `MOBS`; spectators and `isIgnoringBlockTriggers` true entities (Display, Interaction, Marker, OminousItemSpawner, marker ArmorStand, Bat) excluded |
| V6 | Heavy weighted plate threshold table | Reproduced by evaluating `ceil(float(s)/150f * 15f)` in binary32 for `n` = 0 to 153; first `n` of each power: 1, 11, 21, ..., 141. The light plate reproduces `min(n, 15)`. |
| V7 | Daylight detector examples of section 10 | Reproduced with the table cosine (`Mth.cos`, 11) in binary32: angles 0, 45, 90, 180, 270 degrees give 15, 12, 5, 0, 5 at brightness 15 |
| V8 | Target strength thresholds | `m` = 0 gives 15, 0.25 gives 8, 0.4 gives 3, 0.49 gives 1, 0.5 gives 1 (double arithmetic) |
| V9 | Note pitch table | 25 values, notes 0 and 24 give 0.5 and 2.0 exactly; note 12 gives 1.0 |
| V10 | Instrument enum | 27 constants in the order of 8.1; `trumpet_oxidized` precedes `trumpet_weathered`; tunable = 20 constants, mob head = 6, custom = 1 |
| V11 | Lever pitch and volume | volume 0.3; pitch 0.6 on, 0.5 off |
| V12 | Lightning rod pulse | exactly 8 ticks; event 3002 data = axis ordinal; search sphere radius 128 |
| V13 | Cross-check with the 24 documents | Shapes of the button (24 part 4 section 6.32), the weighted plate (24 part 5 section 7.4), the daylight detector formula (24 part 5 section 7.6) and the note block instrument rule (24 part 2 section 7.10) agree with this document |

## 12. Open questions

1. **`entityInside` dispatch.** This document states what `entityInside` does for buttons and plates; the engine that decides when to call it (which entities, which box against the block's outline or the touch box, per tick or on movement, `checkInside` order) belongs to the entity movement documents (18, 33) and was not re-read here. In particular the touch box of the plates (4.1) is used only for counting; the call that starts `checkPressed` depends on the block's outline.
2. **Per-block instrument table.** The instrument of each block is the Instrument column of the 24 documents; it was not re-tabulated here. A consumer needs only the setting per block state (`BlockStateBase.instrument()`).
3. **`Level.getEffectiveSkyBrightness` and the `SUN_ANGLE` attribute** are specified in 32 and 12; this document uses their results and does not re-derive them.
4. **Copper cleaning**: resolved, see 7.6. Not read: the `WeatheringCopper.getFirst` and `getPrevious` stage maps themselves (24 part 4 section 5.5), and `ParticleUtils.spawnParticlesOnBlockFaces` placement details (42 part 6).
5. **Tie-break of `PoiManager.findClosest`.** `Stream.min` with a double comparator keeps the first of equal minima in stream order; the stream order (POI storage order within sections and chunks) was not read.
6. **`Level.setBlocksDirty`**: resolved, see 4.4 (empty on the server, render notification on the client).
7. **`isIgnoringBlockTriggers` overrides**: resolved, verified by a scan of all `net.minecraft` classes (4.1).
8. **Shapes of the lever on the floor and ceiling**: resolved, computed in 2.6.
9. **`ExperimentalRedstoneUtils.initialOrientation`** and the orientation argument of `updateNeighborsAt`: sibling part 1.
10. **Sound pitch clamp**: resolved, 0.5 to 2.0 in `SoundEngine.calculatePitch` (8.5).
11. **`playSound` without volume and pitch**: resolved. `LevelAccessor.playSound(Entity, BlockPos, SoundEvent, SoundSource)` is a default method passing volume 1.0 and pitch 1.0, and `Level` declares no override of the four-argument form.
12. **Block event packet delivery for `triggerEvent`** (which clients receive the note block event, range) is 29 section 6 and 05a; not re-read.
