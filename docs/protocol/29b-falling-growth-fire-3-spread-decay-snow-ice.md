# 29b. Falling blocks, growth, fire and similar block behaviours, part 3: spreading, decay, leaves, snow, ice, sponges

| | |
|---|---|
| Covers | Spreading snowy blocks (grass block, mycelium; podzol as the non-spreading snowy block), the `snowy` property updates, grass bone meal, nylium decay and bone meal, netherrack bone meal; leaves (the `distance` computation, decay, `persistent`, waterlogging, drops, the variant classes and their client-only particle and sound behaviour, mangrove leaves bone meal, leaf litter); snow layers and the snow block; powder snow (what is specified elsewhere and what this part adds); ice, packed ice, blue ice and frosted ice; the block side of weather-driven changes (the level-tick precipitation step lives in 33 §4.4 and is only cross-referenced); the lightning rod strike and the copper clean-up walk of a lightning bolt; sponge and wet sponge; magma block |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for the bootstrap table of `Blocks`), plus the tag JSON files of the jar's `data/` tree for the tag members quoted in section 1.3. No execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 3 |
| Data versus code | Block loot tables (leaf drops, snow drops), block tags (`snow`, `nylium`, `leaves`, `logs`, `prevents_nearby_leaf_decay`, `cannot_support_snow_layer`, `support_override_snow_layer`, `ice_melts_when_destroyed_above`), the features used by bone meal (the placed feature `grass_bonemeal`, the feature `nylium_bonemeal` of the `worldgen/feature` registry, the per-biome bone meal feature lists) and the dimension environment attribute `water_evaporates` are DATA (22, 23, 26, 35). This part specifies the engines that interpret them and the code-defined rules (constants, orderings, random draws, algorithms). Block registry rows (ids, states, hardness, light, shapes, sounds) are 24 and are not repeated. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. Block names are registry names (24 parts 1 to 8). This part uses the behaviour record, trigger kinds, probability notation and predicate vocabulary of `29b-falling-growth-fire-1-model-gravity-bonemeal.md` §2 (trigger codes RT, ST, PL, NU, SU, EV; `1/N`, `P(p)`, `U(a,b)`); the sibling split proposed in that document's §1.2 was overruled by the round's task text, which names this file; the blocks of the proposed parts 3 and 4 are split by the round instead as stated in 1.3.

## 0. Reader's map

| Question | Section |
|---|---|
| Which blocks are in this part, which are elsewhere, the tags involved | 1 |
| The shared tests: light-dampening "can stay alive", the `U` draw, breadth-first traversal, direction orders | 2 |
| Grass, mycelium, podzol: snowy property, survival, decay, spread, grass bone meal | 3 |
| Nylium and netherrack | 4 |
| Leaves: distance, decay, placement, variants, drops, client behaviour, mangrove, leaf litter | 5 |
| Snow layers and the snow block | 6 |
| Ice, packed ice, blue ice, frosted ice | 7 |
| Powder snow | 8 |
| Weather-driven changes, lightning rod, copper clean-up | 9 |
| Sponge, wet sponge, magma block | 10 |
| Worked examples | 11 |
| Validation | 12 |
| Open questions | 13 |

## 1. Scope and cross-references

### 1.1 Not repeated here (owners)

| Topic | Owner |
|---|---|
| The level-tick precipitation step (random column draw 1/48, freeze, snow accumulation, `shouldFreeze`, `shouldSnow`, cauldron fill by rain and snow, `max_snow_accumulation_height`), `findLightningTargetAround`, skeleton trap, bolt spawning | 33 §2.4, §4.4, §4.5 |
| Powder snow `entityInside`, collision shape, walkers, pickup, landing | 44 part x1 §2.2 (read again here, section 8; they agree) |
| Frost Walker (`replace_disk` of `frosted_ice` age 0) and `prevents_ice_melting` | 28 (enchantment effects), 17 §6 |
| Bone meal item flow, `BonemealableBlock` contract, `NEIGHBOR_SPREADER` particle position | 29b part 1 §5 |
| Falling blocks, crops, saplings | 29b part 1 §3, §6, §7 |
| Copper weathering ticks (`WeatheringCopper`), the lightning rod's weathering variants, and the same bolt strike and copper walk seen from the copper side | 29b part 5 §8 (it and 9.2, 9.3 here agree on every value; 9.3 here adds the `visualOnly` gate of the fire step, which 29b part 5 §8 does not mention) |
| Block ids, state ids, shapes, light levels, sounds, map colours | 24, 46 |
| Particle shapes (`tinted_leaves`, `cherry_leaves`, `dripping_water`, `snowflake`, `mycelium`, bone meal) | 42 parts 4 and 6 |
| Foliage and dry-foliage tints | 43 |
| The update machinery (`setBlock` flags, scheduled ticks, random tick bookkeeping, `neighborChanged`, `updateShape`) | 29 §1 to §6 |
| Light layers and the raw brightness formulas | 32 §1, §2 |
| Fluid flow after a block is replaced by water | the fluids round |
| Bubble columns over magma blocks | 44 part x1 §2.3 |

### 1.2 Flags used

`setBlockAndUpdate` is flags 3 (29 §1). `removeBlock(pos, false)` removes with the "no movement" argument false and no drop. The sponge uses flags 2 for the wet sponge. Pickups use flags 11.

### 1.3 Block to section

| Registry block | Class (read) | Section |
|---|---|---|
| `grass_block` | `GrassBlock extends SpreadingSnowyBlock extends SnowyBlock`, base block `dirt`; random-ticking | 3 |
| `mycelium` | `MyceliumBlock extends SpreadingSnowyBlock`, base block `dirt`; random-ticking | 3 |
| `podzol` | `SnowyBlock` itself (no random tick, no spread, no decay) | 3.1 |
| `crimson_nylium`, `warped_nylium` | `NyliumBlock`; random-ticking | 4 |
| `netherrack` | `NetherrackBlock` (bone meal only) | 4.3 |
| `oak_leaves`, `birch_leaves`, `jungle_leaves`, `acacia_leaves`, `dark_oak_leaves` | `TintedParticleLeavesBlock` | 5 |
| `spruce_leaves` | `LeavesBlock` | 5 |
| `cherry_leaves`, `pale_oak_leaves`, `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves`, `azalea_leaves`, `flowering_azalea_leaves` | `UntintedParticleLeavesBlock` | 5 |
| `mangrove_leaves` | `MangroveLeavesBlock` (a `TintedParticleLeavesBlock`) | 5.7 |
| `leaf_litter` | `LeafLitterBlock` | 5.8 |
| `snow` | `SnowLayerBlock`; random-ticking | 6 |
| `snow_block` | plain `Block`, no behaviour | 6.5 |
| `powder_snow` | `PowderSnowBlock` | 8 |
| `ice` | `IceBlock`; random-ticking | 7.1 |
| `packed_ice` | plain `Block` | 7.2 |
| `blue_ice` | `HalfTransparentBlock` | 7.2 |
| `frosted_ice` | `FrostedIceBlock` (not random-ticking; scheduled ticks) | 7.3 |
| `sponge`, `wet_sponge` | `SpongeBlock`, `WetSpongeBlock` | 10.1, 10.2 |
| `magma_block` | `MagmaBlock` | 10.3 |

The classes of the rows were read from the bootstrap-method table of `Blocks` (the `new` method handle of each registration), which also settles that `podzol` is a `SnowyBlock` and `blue_ice` a `HalfTransparentBlock`. Registry columns (24) agree.

### 1.4 Tag members read from the jar (data, listed only to make the examples concrete)

| Tag | Members in this jar |
|---|---|
| `snow` (block) | `snow`, `snow_block`, `powder_snow` |
| `nylium` | `crimson_nylium`, `warped_nylium` |
| `prevents_nearby_leaf_decay` | `#logs` |
| `cannot_support_snow_layer` | `ice`, `packed_ice`, `barrier` |
| `support_override_snow_layer` | `honey_block`, `soul_sand`, `mud` |
| `ice_melts_when_destroyed_above` | `#blocks_motion` |
| `required_for_poplar_leaf_ambience` | `#overworld_natural_logs` (the satisfying-block tag of the poplar ambient sound, 5.6) |
| `leaves` | the 14 leaves blocks of 1.3 |
| enchantment tag `prevents_ice_melting` | `silk_touch` |

A reimplementation takes these from the extracted data pack (23), not from this table.

## 2. Shared tests

### 2.1 The "light gets through" test (`getLightDampeningInto`)

`LightEngine.getLightDampeningInto(from, to, dir, defaultValue)` (read; the same text as 32 §2.1): let `fromEmpty` and `toEmpty` be the engine's `isEmptyShape` of each state. `isEmptyShape` is read as "the state cannot occlude, **or** it does not use its shape for light occlusion" (`!canOcclude || !useShapeForLightOcclusion`). It is therefore true for every non-occluding state (glass, leaves, ice, water, powder snow, anything built with `noOcclusion`) and also for ordinary full blocks (which occlude but do not use their shape); it is false only for an occluding state whose class asks for the shape to be used (snow layers, slabs, stairs and similar). When both are empty the result is `defaultValue`. Otherwise the face of `from` toward `dir` (the empty shape when `fromEmpty`) and the face of `to` toward the opposite direction (empty when `toEmpty`) are merged (`Shapes.mergedFaceOccludes`, read: true at once when either face is the full square; otherwise the two faces are cut to the plane that touches the shared boundary and the test is whether together they cover the whole unit square); when they cover it the result is **16**, else `defaultValue`.

The shape used is the state's **occlusion shape**, which `BlockBehaviour.getOcclusionShape` returns as the state's **outline shape** (`getShape` with the empty block getter at the origin; read). No separate occlusion table exists for a block unless its class overrides that method.

Both callers pass `from` = the spreader's own state, `to` = the state above, `dir` = UP and `defaultValue` = the above state's `getLightDampening()`. The result is compared with 15: "survives" is `result < 15`. Consequences:

- Air, glass, leaves (dampening 1), water (dampening 1 and not a full fluid), powder snow (dampening 1, section 8): `toEmpty` is true and so is `fromEmpty` for a full-block spreader, so the result is the above state's own dampening (0 or 1): survive.
- An opaque full block above (dampening 15): never survives.
- **A snow layer above, with any `layers` value from 1 to 8, gives 16.** Read: `SnowLayerBlock.getShape` is `SHAPES[layers]`, a column 16 pixels wide from the bottom up to `2 x layers` pixels (`Block.column(16, 0, 2k)`), so for every `layers` from 1 to 8 its DOWN face is the full unit square; the registry builder for `snow` has no `noOcclusion` (read in the `Blocks` bootstrap: `replaceable`, `forceSolidOff`, random ticks, strength, tool gate, sound, view blocking, push reaction) and the class returns true from `useShapeForLightOcclusion`, so `isEmptyShape` is false for it. One layer of snow therefore blocks exactly like eight. What lets a grass block or mycelium survive one layer is only the explicit exception in 3.2 step 2; the nylium test of 4.1 has no such exception (example 10).
- A block above whose bottom face covers the unit square (a bottom slab): never survives (result 16; (inferred) from the same rule and the slab shapes of 24).
- A top slab above (bottom face empty, dampening by 24): survives (inferred).

### 2.2 `U(a,b)`, nextIntBetweenInclusive, list pick

- `Mth.nextInt(random, a, b)` is `a` when `a >= b`, else `a + nextInt(b - a + 1)` (read).
- `RandomSource.nextIntBetweenInclusive(a, b)` is `a + nextInt(b - a + 1)` (read): `between(-1, 1)` is one `nextInt(3)` draw minus 1.
- `Util.getRandom(list, random)` is `list[nextInt(size)]` (read).

### 2.3 Orders

`Direction.values()` is DOWN, UP, NORTH, SOUTH, WEST, EAST (read this round: the order in which `Direction.$values` stores the six constants, indices 0 to 5). `Direction.Plane.HORIZONTAL` iterates north, east, south, west (29b part 1 §2.5). The leaves distance scan, the frosted ice neighbour counts and the sponge search all use `Direction.values()`.

### 2.4 Breadth-first traversal (`BlockPos.breadthFirstTraversal`)

Inputs: a start position, `maxDepth`, `maxCount`, a neighbour provider and a node function that returns ACCEPT, SKIP or STOP. Output: the number of accepted positions.

1. A FIFO queue starts with (start, depth 0). A set of visited positions is empty. `count` = 0.
2. Take the front node. If its position is already in the visited set, drop it and continue; otherwise add it to the set.
3. Call the node function on the position. SKIP: continue with the next queue entry (the position stays visited, is not counted and is not expanded). STOP: return `count`.
4. ACCEPT: `count += 1`; if `count >= maxCount` return `count` at once.
5. If the node's depth is `>= maxDepth` do not expand; otherwise the neighbour provider adds each neighbour with depth + 1 to the **back** of the queue (no visited check at enqueue time, so a position may be queued more than once; the visited test of step 2 drops repeats).

The node function runs when a node is taken, so its side effects happen in queue order.

## 3. Snowy blocks, grass, mycelium, podzol

### 3.1 `SnowyBlock` (grass block, mycelium, podzol)

Property `snowy` (boolean, default false; 1 extra property, 2 states per block). `isSnowySetting(state)` is "the state is in block tag `snow`".

| Trigger | Rule |
|---|---|
| SU | for a shape update from direction UP: return the state with `snowy = isSnowySetting(neighbour state)`; every other direction: the generic rule (state unchanged) |
| PL (placement) | `getStateForPlacement`: the default state with `snowy = isSnowySetting(block at clickedPos.above())` |

So a snow layer, snow block or powder snow placed on top turns `snowy` on by a shape update, and removing it turns it off. No tick is involved. `podzol` has only this behaviour; it never spreads and never reverts.

### 3.2 `SpreadingSnowyBlock` (grass block and mycelium)

Field: `baseBlock`, the registry key of `dirt` for both (read: `BlockItemIds.DIRT.block()`). The block is random-ticking (registry flag).

Helper `canStayAlive(state, level, pos)` (state = the spreading block's state):

1. `above` = the state at `pos.above()`.
2. If `above` is `snow` with `layers == 1`: true.
3. If the fluid state of `above` is full (`FluidState.isFull`, amount 8: a source): false.
4. `d = getLightDampeningInto(state, above, UP, above.getLightDampening())` (2.1); true when `d < 15`.

Helper `canPropagate(state, level, pos)` = `canStayAlive(state, level, pos)` **and** the fluid at `pos.above()` is **not** in fluid tag `water`.

**RT (`randomTick`)**, with `dirtKey` resolved from the block registry (if it cannot be resolved the tick does nothing):

1. If `canStayAlive(state, level, pos)` is false: `setBlockAndUpdate(pos, dirt default state)` and stop. (The `snowy` value is not carried; the dirt has no such property.)
2. If `getMaxLocalRawBrightness(pos.above()) < 9` (32 §1.2; the sky term uses `skyDarken`): stop.
3. Let `S` = this block's **default** state (snowy false). Repeat 4 times: draw `dx = nextInt(3) - 1`, then `dy = nextInt(5) - 3`, then `dz = nextInt(3) - 1` (in that order) and let `t = pos + (dx, dy, dz)`. If the block at `t` is `dirt` (only the plain dirt block; coarse dirt, podzol, rooted dirt and other grasses do not count) **and** `canPropagate(S, level, t)`: `setBlockAndUpdate(t, S with snowy = isSnowySetting(block at t.above()))`.

Notes: the target offsets reach x and z in -1..1 and y in -3..+1 (the y range is skewed downward by design). The four attempts are independent and one random tick can convert up to four dirt blocks. The decay step 1 runs on every random tick, before the light test. Light is measured one block above the spreader; the survival test measures the cover above the spreader (dampening and fluid), and propagation tests the cover above the **target**.

Client only (`MyceliumBlock.animateTick`): after the generic `animateTick`, draw `nextInt(10)`; when it is 0 add a `mycelium` particle at `(x + nextDouble, y + 1.1, z + nextDouble)` with zero velocity (draws in that order). Grass block has no ambient behaviour.

### 3.3 Grass block bone meal (`GrassBlock`)

Type `NEIGHBOR_SPREADER`. `isValidBonemealTarget`: the block above is air **and** `pos.above()` is inside the build height. `isBonemealSuccess`: always true.

`performBonemeal(level, random, pos, state, source)`: let `above = pos.above()`. For `i = 0` to `127`:

1. `p = above`; `steps = i / 16` (integer division: 0 for `i` 0 to 15, 1 for 16 to 31, ... 7 for 112 to 127).
2. Repeat `steps` times: `dx = between(-1, 1)`; `dy = (between(-1, 1) * nextInt(3)) / 2` (the product is an integer in -2..2 and the division truncates toward zero, so `dy` is -1 for product -2, +1 for product +2 and 0 otherwise); `dz = between(-1, 1)`; the draws are made in the order `dx`, the `between` of `dy`, the `nextInt(3)` of `dy`, `dz`. `p += (dx, dy, dz)` (the walk is cumulative). After each step apply `stopBonemealSpread(level, p)`: **true** when the state at `p.below()` is not this very block (the grass block) **or** the collision shape at `p` is a full block (`isCollisionShapeFullBlock`). If true, abandon this `i` (go to the next `i`, placing nothing).
3. When all steps passed: `placeBonemealEffect(level, random, p, source)`.

`placeBonemealEffect` at `p`:

1. `s` = the state at `p`. If `s` is `short_grass` **and** `nextFloat() < 0.1` (the draw is skipped when `s` is not short grass): if the short grass block's `isValidBonemealTarget(level, p, s, source)` holds, call its `performBonemeal(level, random, p, s, source)` (the growth of short grass is a sibling part).
2. Continue only when `s` (the state read before step 1) is air and `p` is inside the build height; otherwise stop.
3. Draw `nextFloat()`. If `< 0.125`: take the biome's bone meal feature list (`BiomeGenerationSettings.getBoneMealFeatures`, data); if the list is empty stop, else pick one entry with `Util.getRandom(list, random)` and place that entry (a `Feature` object, as held by the `worldgen/feature` registry; read: the list type is `List<Feature>`) at `p` with the signature (level, chunk generator, the same random, `p`).
4. Otherwise: if the placed feature `grass_bonemeal` exists in the `Registries.PLACED_FEATURE` registry (file `worldgen/placed_feature/grass_bonemeal.json`, data), place it at `p` with the chunk generator, the random and `p`.

So of the cells that reach step 3, about 1 in 8 grows a flower of the biome (if it has bone meal flowers) and 7 in 8 place the grass patch feature; a cell that is not air does nothing. Feature placement is 35 part 1 §"features outside decoration" (the feature `place` with the live random).

## 4. Nylium and netherrack

### 4.1 `NyliumBlock` survival and decay

Helper `canBeNylium(state, level, pos)`: `above` = the state at `pos.above()`; `d = getLightDampeningInto(state, above, UP, above.getLightDampening())`; true when `d < 15` (2.1). It has **no** snow-layer exception and **no** fluid test, unlike 3.2. Consequence of 2.1: a snow layer of **any** height (1 to 8 layers) above nylium gives result 16, so `canBeNylium` is false (and only in 3.2 does one layer get a pass); a snow layer on nylium makes the nylium revert to netherrack on its next random tick.

RT: if `canBeNylium` is false: `setBlockAndUpdate(pos, netherrack default state)`. There is no spreading in a random tick and no light threshold.

### 4.2 Nylium bone meal

Type `NEIGHBOR_SPREADER`. `isValidBonemealTarget`: the block above is air and `pos.above()` is inside the build height. `isBonemealSuccess`: always true. `performBonemeal`: `above = pos.above()`; if `above` is inside the build height, place the feature `nylium_bonemeal` (looked up in `Registries.FEATURE`, registry path `worldgen/feature`, key `NetherFeatures.NYLIUM_BONEMEAL`, file `worldgen/feature/nylium_bonemeal.json`, type `overlay`, data; there is no `configured_feature` registry in this jar, see 35 part 1 §1 and its Open question 2) with the chunk generator, the random and `above`; if the feature is absent nothing happens.

### 4.3 `NetherrackBlock` bone meal

Type `NEIGHBOR_SPREADER`. Let the **cube** be the 27 positions `pos + (-1..1, -1..1, -1..1)` (the block itself included; it is netherrack, so it never matches).

- `isValidBonemealTarget`: the state above `propagatesSkylightDown` (32 §7; air and other transparent states) **and** at least one position of the cube holds a block in tag `nylium`.
- `isBonemealSuccess`: always true.
- `performBonemeal`: scan the cube and note whether a `warped_nylium` and whether a `crimson_nylium` exist (the scan stops as soon as both are found; the scan order is the engine's `findBlocksIn` order, which does not matter for the result). If both exist: `setBlockAndUpdate(pos, nextBoolean() ? warped_nylium : crimson_nylium)` (one draw). If only warped: warped. If only crimson: crimson. If neither: nothing (not reachable after a valid target check unless the neighbourhood changed).

## 5. Leaves

### 5.1 State

Properties (declaration order of `createBlockStateDefinition`): `distance` 1 to 7 (default 7), `persistent` (default false), `waterlogged` (default false); 7 x 2 x 2 = 28 states (24 part 1 confirms 28). `getLightDampening` is 1; `getBlockSupportShape` is empty; `getFluidState` is the water source when waterlogged. The registry builder (24 part 2 `leavesProperties`) sets random ticks; the class overrides which states really random-tick (5.4).

### 5.2 Distance of a block to the nearest log

`getOptionalDistanceAt(state)`:
1. A state in block tag `prevents_nearby_leaf_decay` (here `#logs`): 0.
2. Else a state that has the `distance` property (any leaves block): its `distance` value.
3. Else: empty (treated as 7 by `getDistanceAt`).

`updateDistance(state, level, pos)`: `m = 7`; for each direction of `Direction.values()` in order: `m = min(m, getDistanceAt(state at pos + direction) + 1)`; stop the loop early when `m == 1`. Return `state` with `distance = m`. A neighbour that is neither log nor leaves contributes 8 (no effect on the minimum of 7). So `distance` is `1 + min(neighbour distance)` capped at 7: a leaf next to a log is 1, a chain of leaves away from the log counts up to 7 (7 means "no log within 6 leaf steps").

### 5.3 Triggers

| Trigger | Rule |
|---|---|
| PL | `getStateForPlacement`: the default state with `persistent = true` and `waterlogged = (fluid at the clicked position is water)`, then `updateDistance` at the clicked position. Player-placed leaves therefore never decay. |
| SU | (a) if `waterlogged`, schedule a fluid tick for water at the position with the water fluid's tick delay. (b) `d = getDistanceAt(neighbour state) + 1` where the neighbour is the one that sent the update (`neighborState` argument; **only that neighbour** is looked at). If `d != 1` **or** the state's own `distance != d`: schedule a block tick for this block at its position with delay **1**. The state is returned unchanged. |
| ST (delay 1) | `setBlockAndUpdate(pos, updateDistance(state, level, pos))` (flags 3: the full recomputation, neighbours are told, so the change propagates one block per game tick). |
| RT | see 5.4 |

`isRandomlyTicking(state)`: true only when `distance == 7` **and** `persistent` is false.

### 5.4 Decay

`decaying(state)` is `!persistent && distance == 7`. RT: when `decaying`: `Block.dropResources(state, level, pos)` (the block's loot table with no tool; DATA, 26), then `removeBlock(pos, false)`. There is no game event. Worked drop (`oak_leaves` table read this round): pool 1 gives the leaves item when the tool `can_shear` or `can_silk_touch`, else `oak_sapling` with a fortune `table_bonus` (chances 0.05, 0.0625, 0.083333336, 0.1); pool 2 (only without shear or silk touch) gives 1 to 2 `stick` with chances 0.02, 0.022222223, 0.025, 0.033333335, 0.1; pool 3 (same condition) gives `apple` with chances 0.005, 0.0055555557, 0.00625, 0.008333334, 0.025. Decay has no tool, so the leaves item is never dropped and the fortune level is 0: the first chance of each list applies, i.e. 5% sapling, 2% sticks, 0.5% apple per decayed oak leaf block (read: the sapling and apple entries carry the condition `survives_explosion`; the stick entry carries the function `explosion_decay` instead; with no explosion the radius parameter is absent and both are taken as having no effect, inferred). Random-tick rate: 33 §2.4 and 29b part 1 §2.4. Because the random tick only exists at `distance == 7`, a leaf block whose distance is stale (says 7 while a log is near) is corrected by the scheduled tick of 5.3 before it can decay in the common case; the random tick itself does not recompute the distance (inferred from the code: `randomTick` only tests `decaying`).

Worldgen note: feature placement writes leaves with the distance computed by the tree placer (35 part 3), not by this code path.

### 5.5 Variants

All variants share 5.1 to 5.4. Registry rows are in 24 part 1 §14 and part 2; this table adds what the classes do. `chance` is `leafParticleChance` (a float compared with `nextFloat()`).

| Block | Class | chance | Falling-leaf particle (client) | Ambient sound |
|---|---|---|---|---|
| `oak_leaves`, `birch_leaves`, `jungle_leaves`, `acacia_leaves`, `dark_oak_leaves` | `TintedParticleLeavesBlock` | 0.01 | `tinted_leaves` with the client's leaf tint colour at the position (`Level.getClientLeafTintColor`, 43) | none |
| `spruce_leaves` | `LeavesBlock` | n/a | none | none |
| `mangrove_leaves` | `MangroveLeavesBlock` | 0.01 | as the tinted row | none |
| `cherry_leaves` | `UntintedParticleLeavesBlock` | 0.1 | `cherry_leaves` | none |
| `pale_oak_leaves` | `UntintedParticleLeavesBlock` | 0.02 | `pale_oak_leaves` | none |
| `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves` | `UntintedParticleLeavesBlock` | 0.01 | `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves` respectively | `poplar_leaves_ambient` (5.6) |
| `azalea_leaves`, `flowering_azalea_leaves` | `UntintedParticleLeavesBlock` | 0.01 | `tinted_leaves` with the **fixed** colour -9399763 (0xFF70922D, ARGB, (inferred) from the particle option's colour argument; RGB 112, 146, 45) | none |

(The bootstrap-table order of the 14 lambdas gives the mapping; the poplar family and the azalea colour were read here and agree with 42 part 6.)

### 5.6 Client behaviour (`animateTick`, behaviour only)

Order in `LeavesBlock.animateTick` (variants with falling particles add step 4 after it):
1. Generic block `animateTick`.
2. Rain drip: if it is raining at `pos.above()` (`isRainingAt`), and `nextInt(15) == 1`, and **not** (the block below `canOcclude` and its UP face is sturdy): spawn a `dripping_water` particle below the block (`ParticleUtils.spawnParticleBelow`, 42 part 4). (The draw is skipped when it is not raining.)
3. Ambient sound (`AmbientLeavesBlockSoundPlayer.playAmbientLeavesSounds`, only when the variant has one; the player is a record of sound, `chance` 300, a satisfying-block tag, required counts 1 and 3): draw `nextInt(300)`; when 0, walk the four horizontal neighbours in order, counting `a` = neighbours in the satisfying tag (the tag `required_for_poplar_leaf_ambience` for the poplars, whose content in this jar is `#overworld_natural_logs`, 1.4; counts only when the tag is set) and `b` = neighbours that are the **same block**; after each neighbour, if `a == 1` and `b == 3` exactly, play the sound locally (volume 1, pitch 1, category AMBIENT) at `(x, y, z)` of the block (not centred) and stop. The test is equality, not at least. The `noAmbientSound` player does nothing.
4. Falling leaves (`FallingParticlesLeavesBlock`): draw `nextFloat()`; if `>= chance` stop; if the block below has a full UP collision face (`Block.isFaceFull(belowState.getCollisionShape(level, below), UP)`) stop; else spawn the variant's particle below the block.

`MangroveLeavesBlock.getParticlePos` is `pos.below()` (the bone meal particle position, 5.7). These particles are client-side only and are not part of the server state or any packet.

Client face culling (`LeavesBlock.skipRendering`, read this round): a static flag `cutoutLeaves` (default true, set by `setCutoutLeaves`). When the flag is false and the neighbour state is any `LeavesBlock`, the face is skipped; otherwise the generic `skipRendering` rule applies. So with cutout leaves on (the default) leaves cull like any other block.

### 5.7 Mangrove leaves bone meal

Type is the default (`GROWER`) with `getParticlePos` overridden to `pos.below()`. `isValidBonemealTarget`: the block below is air (no height test). `isBonemealSuccess`: always true. `performBonemeal`: `setBlock(pos.below(), MangrovePropaguleBlock.createNewHangingPropagule(), flags 2)` (a hanging propagule, `age` 0; its states are 24, its own growth is a sibling part).

### 5.8 `leaf_litter`

`LeafLitterBlock` (a `VegetationBlock` with the segmentable mixin): properties `facing` (horizontal, default north) and the segment amount (1 to 4, default 1); survival: the block below has a sturdy UP face; replaceable by another leaf litter (segment placement of 24 part 8 §5.2). It has **no** random tick, scheduled tick, particle or decay behaviour in the class read. (The word "litter" in the round's scope refers to this block; the falling-leaf particles of 5.6 are the only particle behaviour of the leaf family.)

## 6. Snow layers and the snow block

### 6.1 `SnowLayerBlock`

Property `layers` 1 to 8 (default 1). Shapes: `SHAPES[k]` for k = 0 to 8 is a column of width 16 and height `2k` pixels (`Block.boxes(8, ...)`, indices 0 to 8 inclusive, read). Selection: outline, support shape and visual shape use `SHAPES[layers]`; the **collision** shape uses `SHAPES[layers - 1]` (so one layer has an empty collision box, two layers 2 px, ..., eight layers 14 px). Shade brightness is 0.2 at 8 layers, else 1.0. `useShapeForLightOcclusion` is true. Land pathfinding is allowed when `layers < 5`. The registry builder (24 part 3 §7.10) has `replaceable`, `forceSolidOff`, random ticks, `requiresCorrectToolForDrops`, `isViewBlocking` true when `layers >= 8` (read: `Blocks` lambda).

### 6.2 Triggers

| Trigger | Rule |
|---|---|
| survival (`canSurvive`) | with `b` = the state below: false when `b` is in `cannot_support_snow_layer`; true when `b` is in `support_override_snow_layer`; else true when the UP face of `b`'s collision shape is a full square (`Block.isFaceFull`) **or** `b` is a snow layer with `layers == 8`; else false |
| SU | if `canSurvive` fails: return air; else the generic rule |
| RT | `level.getBrightness(BLOCK, pos) > 11` (the **block** light layer only, sky light is ignored): `dropResources(state, level, pos)`, `removeBlock(pos, false)`, game event `block_destroy` at `pos` with the old state as context |
| `canBeReplaced(state, context)` (placement) | with `n = layers`: if the held item is `snow` and `n < 8`: when the placement replaces the clicked block (`replacingClickedOnBlock`), true only when the clicked face is UP; else true; otherwise (item not snow or `n == 8`) true only when `n == 1` |
| `getStateForPlacement` | if the state at the clicked position is already `snow`: `layers = min(8, layers + 1)`; else the generic placement |

There is no melting by sun or by biome in this block's code: only the block-light random tick of the row RT. Accumulation by snowfall is 33 §4.4 step 2.1 (raises `layers` up to `min(rule, 8)`); that step requires the snow default state's `canSurvive` at the position.

### 6.3 Snow and the snowy property

`snow` in tag `snow` makes a grass block, mycelium or podzol below `snowy = true` (3.1). A one-layer snow does not kill grass or mycelium only because of the explicit exception of 3.2 step 2; the occlusion shape of every layer count blocks light (result 16, 2.1), so two or more layers kill them, and any layer count kills nylium (4.1).

### 6.4 Drops

The loot table of `snow` (`loot_table/blocks/snow.json`, DATA, read this round) is one pool whose condition is `entity_properties` on `this` with an empty predicate. Inside it two branches are tried in order. Branch one applies when the tool does **not** have silk touch (`inverted` `tool/can_silk_touch`) and gives `snowball` with count equal to `layers` (1 to 8). Branch two gives the `snow` item with count equal to `layers` for 1 to 7 and `snow_block` at 8. The table has no tool-class (shovel) condition; `requiresCorrectToolForDrops` in the registry is only the harvest gate for players. Read this round: `LootItemEntityPropertyCondition.test` reads the entity parameter named by `entity` as an optional value and, when its `predicate` field is present, calls `EntityPredicate.matches` with it; `EntityPredicate.matches` returns false at once for a null entity. `Block.dropResources(state, level, pos)` builds the loot parameters from the origin, an empty tool and an optional block entity only (no entity parameter), so the pool condition fails and the block-light melt of 6.2 RT **drops nothing**. (That the table's `"predicate": {}` decodes to a present, empty predicate and not to an absent one is inferred from the codec's field type being an optional and from the class's `entityPresent` helper, which wraps an empty entity predicate builder; the codec was not disassembled further.) A player break passes an entity, so the drops of the two branches apply there.

### 6.5 `snow_block`

A plain block with `requiresCorrectToolForDrops`: no random tick, no melting, no behaviour.

## 7. Ice

### 7.1 `IceBlock` (`ice`)

Random-ticking. `meltsInto()` is the water default state (a source).

| Trigger | Rule |
|---|---|
| RT | if `getBrightness(BLOCK, pos) > 11 - state.getLightDampening()` call `melt` (the dampening of `ice` is 1, 24 part 3 §7.10; so the test is block light above 10). Sky light never melts ice. |
| `melt(state, level, pos)` | if the environment attribute `water_evaporates` at `pos` is true: `removeBlock(pos, false)` and stop (no event). Otherwise `setBlockAndUpdate(pos, water)`, `level.neighborChanged(pos, water block, no orientation)`, game event `block_destroy` at `pos` with the old state as context. |
| `playerDestroy` (after the normal player destroy) | unless the tool has an enchantment in tag `prevents_ice_melting`: if `water_evaporates` at `pos`: `removeBlock(pos, false)` and stop; else with `b` = the state below: when `b` is in `ice_melts_when_destroyed_above` **or** `b` is a liquid (`liquid()`), `setBlockAndUpdate(pos, water)` (read again this round: the test is an OR of the two) |

Ice has a loot table only for silk touch (`blocks/ice.json`: a single pool conditioned on `tool/can_silk_touch` yielding `ice`; the row is in 24 part 3 §3.3, "silk touch only"); without silk touch it drops nothing and, when the support below blocks motion or is liquid, leaves water.

**Discrepancy with 24 part 3 §7.10 (ice row).** That row says the block becomes water when the block below "is a liquid and not in tag `ice_melts_when_destroyed_above`". The artifact says the opposite combination (in the tag **or** a liquid), as in the table above, so this document is correct and 24 part 3 should be corrected by its owner (noted for the reader or orchestrator of 24 part 3; that file was not edited in this round).

### 7.2 `packed_ice` and `blue_ice`

`packed_ice` is a plain `Block` (friction 0.98, strength 0.5), `blue_ice` is a `HalfTransparentBlock` (strength 2.8, friction 0.989). Neither random-ticks, melts, nor reacts to neighbours. `HalfTransparentBlock` only affects client face culling (a face is skipped against the same block); `IceBlock` extends it too, so `ice` and `frosted_ice` inherit the culling. Friction values matter for entity movement (13 §1).

### 7.3 `FrostedIceBlock` (`frosted_ice`)

Property `age` 0 to 3 (default 0; 4 states). Constants: `MAX_AGE` 3, `NEIGHBORS_TO_AGE` 4, `NEIGHBORS_TO_MELT` 2. Not random-ticking: it works by scheduled ticks. `getCloneItemStack` is empty. Light dampening and shape are those of ice. Builder values (read this round from `Blocks`, agreeing with 24 part 6): friction 0.98, strength 0.5, sound glass, `noOcclusion`.

`fewerNeighboursThan(level, pos, limit)`: counting, over `Direction.values()`, neighbours that are `frosted_ice`, return false as soon as the count reaches `limit`; true after the loop.

`slightlyMelt(state, level, pos)`: if `age < 3`: `setBlock(pos, state with age + 1, flags 2)` and return **false**; else `melt` (7.1) and return **true**.

| Trigger | Rule |
|---|---|
| PL | schedule a tick for this block at its position with delay `U(60, 120)` |
| ST | 1. Draw `nextInt(3)`. Continue to step 2 when that draw is 0 **or** `fewerNeighboursThan(level, pos, 4)` (the second test is not evaluated when the draw is 0). Otherwise go to step 6. 2. `L` = the block light at `pos` when the level's dimension is the End, else `getMaxLocalRawBrightness(pos)` (32 §1.2). 3. If `L > 11 - age - state.getLightDampening()`: call `slightlyMelt(state)`; if it returned **true** (the block melted away) go to step 4; if it returned false go to step 6. If the light test failed go to step 6. 4. For each direction in `Direction.values()` order: if the neighbour is `frosted_ice`, call `slightlyMelt(neighbour)` (this ages the neighbour at once, or melts it); when that returned **false** schedule the neighbour's tick with delay `U(20, 40)`. 5. Return. 6. Schedule this block's tick with delay `U(20, 40)` (also after a successful age increment of step 3). |
| NU | when the changed neighbour block is `frosted_ice` and `fewerNeighboursThan(level, pos, 2)`: `melt` at once; then the generic rule |

Reading note: ageing happens only inside `slightlyMelt` called from step 3, one age per accepted tick; a block that reached age 3 melts on its next accepted tick, and only then are its frosted neighbours aged. The numbers for the Frost Walker disk and radius are 28 and 17 §6.

## 8. Powder snow

44 part x1 §2.2 is the specification (stuck multiplier `(0.9, 1.5, 0.9)`, snowflake particles, the `FREEZE` and `EXTINGUISH` effects and the burning-entity destruction callback, landing sound without fall damage, collision shape with the 2.5 fall-distance threshold and the 0.9 high "falling" box, walkers by tag `powder_snow_walkable_mobs` or leather boots, inside-box rule, pickup with level event 2001, `skipRendering` against the same block, `isPathfindable` true). This part re-read every one of those rows against the artifact and found no difference. Items this part adds:

- Registry (24 part 4): not random-ticking, strength 0.25, `dynamicShape`, `noOcclusion`, `isRedstoneConductor` never; class `PowderSnowBlock`.
- It is in tag `snow` (1.4), so it sets `snowy` below grass (3.1). It does not kill grass by dampening (read this round): `PowderSnowBlock` overrides only the collision shape, the visual shape (empty) and the entity-inside shape, so its **outline and occlusion shape is the default full block**. Because it is built with `noOcclusion`, `isEmptyShape` is true for it (2.1) and the test of 2.1 returns the state's own dampening, which is **1** (the default rule: not solid-render, and `propagatesSkylightDown` is false for a full outline shape or a fluid-bearing state, so 1 and not 0). 1 is below 15, so grass and mycelium under powder snow survive.
- The powder snow cauldron and its fill by snowfall are 33 §4.4 step 2.2 and 24 part 4 §6; its pickup path uses the bucket item flow (25 part 5).
- Walking mobs: the goal that climbs on top of powder snow is 18 (mob framework).

## 9. Weather-driven changes and lightning

### 9.1 What is where

| Change | Where specified |
|---|---|
| Water to ice, air to snow layer, snow layer stacking, cauldron fill, per-column attempt rate | 33 §2.4, §4.4 (block side in 6.2 and 7.1 here) |
| Ice, snow layer and frosted ice melting by block light | 6.2, 7.1, 7.3 |
| Frosted ice creation (Frost Walker) | 28, 17 §6 |
| Selection of the lightning target and bolt spawn | 33 §4.4 `tickThunder` |
| Fire started by a bolt (`spawnFire`, difficulty gate and `visualOnly` gate, 9.4) | 33 §4.4 and 33 section on game rules (`fire_spread_radius_around_player`) |

### 9.2 Lightning rod strike (`LightningRodBlock`, ticking part)

Constants: `ACTIVATION_TICKS` 8, `RANGE` 128 (used by the target search of 33), `SPARK_CYCLE` 200. Properties `facing` (default UP), `waterlogged`, `powered` (default false).

| Trigger | Rule |
|---|---|
| strike (`onLightningStrike`, called by the bolt, 9.4) | `setBlockAndUpdate(pos, powered = true)`; tell the neighbours (`updateNeighbours`: `updateNeighborsAt(pos.relative(facing.opposite), this block, initial orientation)`); schedule a block tick for this block with delay **8**; level event **3002** at `pos` with data = the ordinal of the axis of `facing` (X 0, Y 1, Z 2; 42 part 6 for the spark effect) |
| ST | `setBlockAndUpdate(pos, powered = false)`; `updateNeighbours` (as above) |
| PL | if the old block is not this block and `powered` and no tick of this block is scheduled at `pos`: schedule a tick with delay 8 (this restores the timer after a chunk reload) |
| removal | if the state was `powered`, `updateNeighbours` |
| signals | signal source; `ownSignal` 15 when powered else 0; `getDirectSignal` 15 toward the direction equal to `facing` while powered, else 0 |
| client `animateTick` | only when the level is thundering: draw `nextInt(200)` from the level's own random; continue only when the draw is **at most** `gameTime mod 200` (`<=`); then continue only when the block's Y equals the `WORLD_SURFACE` height of its column minus 1 (it is the top block of the column); then spawn `UniformInt(1, 2)` `electric_spark` particles along the axis of `facing` with spacing 0.125 |

The `animateTick` condition was re-read this round: the long comparison of the draw against the remainder jumps to the return when the draw is greater, so sparks need draw `<=` `gameTime mod 200`. Early in each 200-tick cycle sparks are rare, late in it they are frequent.

The weathering variants (`exposed_`, `weathered_`, `oxidized_lightning_rod`) are `WeatheringLightningRodBlock`; their ticking is the copper part. Waxed variants are `LightningRodBlock`.

### 9.3 Copper clean-up on a strike (`LightningBolt.clearCopperOnLightningStrike`)

Runs on the server when the bolt's life counter equals 2 (the first tick of the strike, after the optional fire step and `powerLightningRod`, before the game event `lightning_strike`); neither `powerLightningRod` nor `clearCopperOnLightningStrike` is gated on the bolt's `visualOnly` flag (the flag gates the fire step, 9.4, and the later entity damage). The same strike and walk are described from the copper side in 29b part 5 §8; the two agree on every value (strike position, 3 to 5 walks of 1 to 8 steps, 10 candidates per step, events 3002 with data -1), so only the points that matter for this part are kept below.

Strike position `strike`: the block containing `(bolt.x, bolt.y - 1.0E-6, bolt.z)` (so the bolt standing on the bottom face of a target cell strikes the block below it; for a rod target of 33 the bolt is placed on the rod's upper face and the strike block is the rod itself).

1. `powerLightningRod`: if the block at `strike` is a `LightningRodBlock` (any of the weathering or waxed variants), call its `onLightningStrike(state, level, strike)` (9.2).
2. `clearCopperOnLightningStrike(level, strike)`:
   1. `s` = the block state at `strike`; `waxed` = the block is a key of `HoneycombItem.WAX_OFF_BY_BLOCK` (the waxed to unwaxed map); `weathering` = the block is a `WeatheringCopper`. If neither: stop.
   2. If `weathering`: `setBlockAndUpdate(strike, WeatheringCopper.getFirst(s))` (the unaffected variant with the same properties).
   3. `walks = 3 + nextInt(3)` (3 to 5). Repeat `walks` times: `steps = 1 + nextInt(8)` (1 to 8); `randomWalk(level, strike, steps)`.
   4. `randomWalk`: the cursor is reset to `strike`; repeat up to `steps` times: `randomStep(level, cursor)`; if it returns nothing stop this walk, else move the cursor to the returned position.
   5. `randomStep(level, cursor)`: iterate lazily over **10** random positions in the cube `cursor +- 1` (the helper is `BlockPos.randomInCube(random, 10, cursor, 1)`, which delegates to `randomBetweenClosed`; each position draws `nextInt(3)` for x, then y, then z; the draws are made as positions are consumed). For each position in turn: if its block is a `WeatheringCopper`: `prev = WeatheringCopper.getPrevious(state)`; when present, `setBlockAndUpdate(position, prev)`; send level event **3002** at the position with data **-1**; return that position (even when there was no previous state). Positions that are not weathering copper are skipped. After the 10 positions return nothing.
   The random source is the level's.

So a strike scrapes one oxidation step off up to a few connected pieces of weathering copper around the strike block; waxed copper is never changed (a waxed struck block still starts the walks); an unwaxed struck block is reset to the unaffected variant.

### 9.4 Bolt tick order (blocks only)

On the server at life 2: (a) on Normal and Hard difficulty **and only when the bolt is not `visualOnly`** (`spawnFire` itself returns at once for a visual-only bolt, which is the skeleton-trap bolt of 33 §4.4 step 7) `spawnFire(4)` (33), (b) `powerLightningRod`, (c) `clearCopperOnLightningStrike(strike)`, (d) game event `lightning_strike`; steps (b) to (d) run for a visual-only bolt too. The bolt's later life steps (damage, flashes, removal) are 21 §8.6.

## 10. Sponge, wet sponge, magma

### 10.1 `SpongeBlock` (`sponge`)

Constants: `MAX_DEPTH` 6, `MAX_COUNT` 64. The search uses `Direction.values()` for neighbours and the traversal of 2.4 with `maxDepth` 6 and `maxCount` **65** (the start counts as the first accepted node, so at most 64 other positions are absorbed).

| Trigger | Rule |
|---|---|
| PL | if the old state is already this block: nothing; else `tryAbsorbWater(level, pos)` |
| NU | `tryAbsorbWater(level, pos)`, then the generic rule (any neighbour change) |

`tryAbsorbWater`: run the traversal of 2.4 from `pos`; it returns the accepted count `n`. When `n > 1` (at least one position other than the sponge was accepted): `setBlock(pos, wet_sponge default state, flags 2)` and play `sponge_absorb` at `pos` (category BLOCKS, volume 1, pitch 1, no player exclusion). Otherwise nothing changes.

Node function for a position `q` (called when the node is taken):
1. `q == pos` (the sponge): ACCEPT.
2. If the fluid at `q` is not in fluid tag `water`: SKIP (so the search moves only through water).
3. Let `b` = the block at `q`. If `b` is a `BucketPickup` (a water liquid block, or a waterlogged block) and `pickupBlock(null, level, q, state)` returned a non-empty stack: ACCEPT. (`LiquidBlock.pickupBlock`, read: for fluid level 0 (a source) sets air with flags 11 and returns a bucket of the fluid, otherwise empty. `SimpleWaterloggedBlock.pickupBlock`, read: for a waterlogged state sets `waterlogged = false` with flags 3, destroys the block with drops when the unwatered state can no longer survive, and returns a water bucket.)
4. Else if `b` is a `LiquidBlock` (flowing water, which could not be picked up): `setBlockAndUpdate(q, air)`, ACCEPT.
5. Else if the state is `kelp`, `kelp_plant`, `seagrass` or `tall_seagrass`: drop its resources with its block entity (none) and no tool, `setBlockAndUpdate(q, air)`, ACCEPT.
6. Else SKIP.

All removals use flags that notify neighbours, so a neighbour change can re-enter step "NU" of the sponge while the traversal is still running (Open question 3).

### 10.2 `WetSpongeBlock` (`wet_sponge`)

PL only: when the environment attribute `water_evaporates` at `pos` is true: `setBlockAndUpdate(pos, sponge default state)`; level event **2009** at `pos` data 0 (42 part 7: 8 `cloud` particles above the block); play `wet_sponge_dries` at `pos` (category BLOCKS, volume 1.0, pitch `(1.0 + nextFloat() * 0.2) * 0.7`, one draw from the level's random). There is no other server behaviour (no drying by sun, no re-absorb). Client `animateTick`: pick a random direction (`Direction.getRandom`); unless it is UP, and unless the neighbour in that direction `canOcclude` and has a sturdy face toward this block, spawn a `dripping_water` particle at a position on that face (down: `y - 0.05`, x and z plus `nextDouble` each; side faces: `y + nextDouble * 0.8`, the face coordinate offset by 1.1 or 0.05, the other horizontal coordinate plus `nextDouble`), velocity 0.

### 10.3 `MagmaBlock`

`stepOn(level, pos, state, entity)`: when the entity is **not** stepping carefully (sneaking) **and** is a `LivingEntity`: `entity.hurt(hotFloor damage source, 1.0)`; then the generic `stepOn`. Nothing else in the class (no tick, no bubble column code; 44 part x1 §2.3 for bubble columns). Registry values (24 part 6 §6.11): light level 3, strength 0.5, valid spawn only for fire-immune entity types, `emissiveRendering` always, `postProcess` always. Frost Walker boots grant `damage_immunity` to `burn_from_stepping` (17 §6).

## 11. Worked examples

1. **Grass bone meal walk.** Clicked grass at (0, 64, 0), air above, so `above = (0, 65, 0)`. For `i = 40`, `steps = 2`. Step 1 draws `nextInt(3) = 2` (`dx = +1`), `nextInt(3) = 0` (the factor is -1), `nextInt(3) = 2` (product -2, `dy = -1`), `nextInt(3) = 1` (`dz = 0`): `p = (1, 64, 0)`. `stopBonemealSpread`: the block below `(1, 63, 0)` must be grass, and `(1, 64, 0)` must not have a full collision shape; if it is a grass block with air at `(1, 64, 0)` the walk continues. Step 2 moves `p` again from `(1, 64, 0)`. For `i = 5` (`steps = 0`) the effect is placed at `(0, 65, 0)` itself.
2. **Dirt spread.** Grass at `(10, 70, 10)` with sky light 15 above and air above: step 3 of 3.2. Draws `(nextInt(3), nextInt(5), nextInt(3)) = (2, 0, 0)` give `t = (11, 67, 9)`. If that cell is `dirt` with air above at `(11, 68, 9)` (dampening 0, no fluid), it becomes grass block; `snowy` is true only when the block at `(11, 68, 9)` is in tag `snow`. A podzol or coarse dirt at `t` is never converted.
3. **Grass under cover.** A grass block with a stone above: `canStayAlive` is false on its next random tick; the block becomes dirt. With a one-layer snow above it stays grass and `snowy` is true; with a two-layer snow above it becomes dirt (2.1: the occlusion shape of a snow layer has a full bottom face for every layer count, so the result is 16; only the explicit exception of 3.2 step 2 saves the one-layer case).
4. **Leaves distance.** A log at `(0, 0, 0)`; leaves at `(1, 0, 0)`, `(2, 0, 0)` ... `(8, 0, 0)` placed by world generation with default `distance` 7 and `persistent` false. After the scheduled ticks (one block per tick) the distances are 1, 2, ..., 7 for x = 1 to 7 and 7 for x = 8 (`min(7, 6 + 1)`). The leaves at x = 7 and x = 8 are random-ticking and decay (drops by the loot table, removal); the one at x = 6 does not. A leaf player-placed at x = 8 keeps `persistent = true`, never random-ticks and never decays.
5. **Frosted ice life.** Placed in full daylight in an open area (fewer than 4 frosted neighbours, so every tick passes the filter): first tick after `U(60, 120)` ticks, ages 0 to 1; then ticks every `U(20, 40)`: ages 1 to 2, 2 to 3, then the fourth accepted tick melts it (water, or removal when `water_evaporates`). Total: between 60 + 3 x 20 = 120 and 120 + 3 x 40 = 240 ticks. At night (raw brightness 0) the light test fails at every age (`0 > 11 - 0 - 1 = 10` is false), so it only reschedules and never melts by itself; neighbouring melts through `neighborChanged` (fewer than 2 frosted neighbours when one of them changes) still melt it.
6. **Frosted ice in a dense disk.** A block with 4 or more frosted neighbours passes the filter only when `nextInt(3) == 0`, so it ages on about a third of its ticks; a block with at least 2 frosted neighbours is not melted by `neighborChanged`.
7. **Snow melting.** `snow` with block light 12 at its cell: random tick drops it and removes it. Block light 11: nothing, however bright the sky. `snow_block` never melts. `ice` with block light 11: `11 > 10`, it melts (water, or removed in a dimension with `water_evaporates`); block light 10 does not melt it.
8. **Sponge.** A sponge placed on a 1x1 pond (one water source, solid around it): the traversal accepts the sponge and the source (count 2), removes the source, the sponge becomes `wet_sponge` (flags 2) and `sponge_absorb` plays. A sponge placed in a large body of water with all neighbours water absorbs at most 64 positions: the layers around it at traversal distance 0, 1, 2, 3 hold 1, 6, 18, 38 positions (all water), cumulative 63; two positions of distance 4 are then taken and the count reaches 65, so 64 water cells are removed (the ones nearest by queue order, neighbours in the order down, up, north, south, west, east). A sponge with no water within 6 steps stays a sponge.
9. **Wet sponge in the Nether.** Placed in a dimension with `water_evaporates`: immediately becomes `sponge`, event 2009, sound pitch between 0.7 and 0.84 (`(1 + r x 0.2) x 0.7`, r in [0, 1)).
10. **Nylium and netherrack.** Crimson nylium with a stone block above: `canBeNylium` is false (opaque cover), it becomes netherrack on a random tick. Netherrack with air above and only crimson nylium within one block: bone meal turns it into crimson nylium; with both kinds present it picks one with `nextBoolean`. **Nylium under snow:** crimson nylium with a **one-layer** snow above: `getLightDampeningInto` gives 16 (2.1), `canBeNylium` is false, and the nylium becomes netherrack on its next random tick, whereas a grass block under the same snow survives (3.2 step 2). The same holds for 2 to 8 layers. Powder snow above nylium leaves it alone (dampening 1, section 8).
11. **Lightning rod.** A rod struck at game tick T: `powered` true at once, neighbours behind it updated, `ST` at T + 8 turns it off. A second strike during those 8 ticks sets `powered` again and schedules another tick; the block therefore unpowers at the first of the scheduled ticks (two ticks may be pending: Open question 4).

## 12. Validation

An implementation is validated against this document when:

1. Grass: a grass block with opaque cover, a full fluid source above, or a snow above of two or more layers reverts to dirt on its next random tick; with air, glass, leaves, water that is not a source, or a one-layer snow above it stays. With light at `pos.above()` of 8 or less it never spreads; with 9 or more each random tick makes 4 attempts with offsets x -1..1, y -3..1, z -1..1 and converts only plain `dirt` whose cover passes `canPropagate`. Mycelium follows the same rule. Podzol never changes by itself.
2. The `snowy` property follows the block in tag `snow` above on every shape update from above and on placement.
3. Grass bone meal: 128 attempts, walk length `i / 16`, abandon on the stop rule, short grass bonus 0.1, flower 0.125, empty flower list placing nothing.
4. Nylium: reverts to netherrack on a random tick when covered by an opaque block or by a snow layer of any height (1 to 8); bone meal places the `nylium_bonemeal` feature; netherrack bone meal chooses the nylium type as in 4.3.
5. Leaves: 28 states; `distance` is the minimum neighbour distance plus one with logs at 0, capped at 7; placement sets `persistent`; a scheduled tick (delay 1) recomputes the distance; random ticks exist only for `distance == 7` and `persistent == false`; decay drops by loot and removes without an event; waterlogged leaves schedule a water tick on every shape update.
6. Snow layer: collision shape height 2(layers - 1) pixels, outline 2 x layers; survival rule of 6.2; random tick melts above block light 11 with a game event; placement merges up to 8.
7. Ice melts above block light 10 (dampening 1); frosted ice timing, age stepping and neighbour rules as 7.3; packed ice and blue ice are inert.
8. Sponge: at most 64 water positions, depth at most 6, water only, flags 2 for the wet sponge; wet sponge dries only on placement where `water_evaporates`.
9. Lightning: the rod powers for 8 ticks; the copper walk uses 3 to 5 walks of 1 to 8 steps with 10 candidate cells per step and never changes waxed blocks.
10. Random-draw orders given in 3.2, 3.3, 7.3, 9.3 and 10.2 are followed when a deterministic replay is wanted.

## 13. Open questions

1. **Data behind bone meal.** The contents of the placed feature `grass_bonemeal`, the feature `nylium_bonemeal` (`worldgen/feature` registry) and each biome's bone meal feature list are data (35) and were not tabulated; only their use is specified.
2. **Client side of sponge and leaves.** `SpongeBlock.onPlace` and `neighborChanged` take a `Level`, not a `ServerLevel`. Whether the client runs them (predictively) was not read; 29 §2 decides which side calls `onPlace` and `neighborChanged`. The server behaviour is specified.
3. **Re-entrancy in the sponge search.** The traversal removes water with calls that notify neighbours; those notifications reach the sponge's `neighborChanged` before the sponge becomes wet, which can start a nested `tryAbsorbWater`. The net effect on how many positions are absorbed was not traced (inferred: the outer search continues; the inner search finds fewer targets because the queue positions were already emptied).
4. **Rod timer on a second strike.** `onLightningStrike` schedules a tick without checking for an existing one, so two ticks may be pending; whether the scheduled-tick queue deduplicates (29 §4) was not re-checked here.
5. **Colour byte order of the azalea particle** (0xFF70922D read as ARGB) is (inferred) from the option's colour argument; 42 and 43 own the particle colour model.
6. **Other leaf tables.** `oak_leaves` and `snow` were read (5.4, 6.4); the other leaf blocks have their own loot tables, not read here (26 owns them). That `dropResources` passes no entity and an empty tool was read (6.4).
7. **Weathering copper** (`WeatheringCopper.getFirst`, `getPrevious`, the next-block map) is only used here; its ticking and the waxing map are the copper part and 24 part 4 §"weathering".
8. **Tolerance of `isShapeFullBlock`.** `Block.isFaceFull(shape, dir)` was read as exactly `isShapeFullBlock(shape.getFaceShape(dir))` (the shape's face in that direction), with the result cached; the numeric tolerance inside `isShapeFullBlock`'s computation was not read, which matters only for shapes with edges that differ from the unit square by tiny amounts. `isCollisionShapeFullBlock` is used by name (24 part 1 §6).
9. **Sound details** (`sponge_absorb`, `wet_sponge_dries`, `poplar_leaves_ambient`) are named, not mapped to files; sounds are 08 and the extraction tool.
