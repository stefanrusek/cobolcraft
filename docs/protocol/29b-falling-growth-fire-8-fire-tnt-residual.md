# 29b. Falling blocks, growth, fire and similar block behaviours, part 8: fire, soul fire, campfire deltas, budding amethyst, and the residual coverage matrix

| | |
|---|---|
| Covers | `FireBlock`, `BaseFireBlock`, `SoulFireBlock` beyond what 17 section 3.3 and 3.3a record: state and placement state, survival and shape update, `onPlace`, the scheduled tick with the order of every random draw, the neighbour burn-out and the spread formulas with worked numbers, the three environment inputs (`infiniburn`, rain, `increased_fire_burnout`, `fire_spread_radius_around_player`), the entity contact rules, the destroy event; the delta of `CampfireBlock` over 24 part 7 section 11.3 and 31 part 4 (shape update, `canLight`, the smoke-signal scan `isSmokeyPos`); `BuddingAmethystBlock` (random tick growth); the ownership table of `TntBlock`, `SpawnerBlock`, `TrialSpawnerBlock`, `VaultBlock`, `ConduitBlock`, `TargetBlock`, `NoteBlock`, `JukeboxBlock`, `LecternBlock`, `BellBlock`, `DaylightDetectorBlock`; and the residual coverage matrix (every class of `world/level/block` that overrides `tick`, `randomTick` or `neighborChanged`, mapped to the document that specifies it, with the unclaimed ones flagged) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in the text, of the `GameRules`, `EnvironmentAttributes`, `Difficulty` and `Direction` constants, and of the data files `tags/block/{infiniburn_overworld,infiniburn_nether,infiniburn_end,soul_fire_base_blocks,sniffer_egg_hatch_boost}.json`, `tags/item/douses_campfires.json`, `tags/fluid/supports_frogspawn.json` and the `worldgen/biome/*.json` and `dimension_type/*.json` attribute entries, with no execution. The matrix of section 7 was built by scanning the declared methods of all 330 top-level classes of `net/minecraft/world/level/block` (counted with `unzip -Z1 ... | grep -v '/$'`: 410 `.class` entries in the directory, of which 80 are inner classes whose names contain `$`; sub-packages `piston` and `entity` are separate). Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 8 |
| Data versus code | The flammability pairs are CODE (`FireBlock.bootStrap`) and live in 17 section 3.3a; they are not repeated. The tags above and the biome attribute values are DATA, read from the extracted data pack (22, 23); this document names the few values it read so examples can be computed. The block, dimension and biome JSON are not tabulated. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each is repeated in the Open questions. The record notation, flags and the probability notation (`1/N`, `P(p)`, `U(a,b)`) are those of `29b-falling-growth-fire-1-model-gravity-bonemeal.md` section 2 (called "29b-1" below). A random draw written `nextInt(N)` is `RandomSource.nextInt(N)`, uniform in 0 to N-1. Block names are registry names (24).

## 0. Reader's map

| Question | Section |
|---|---|
| What fire states exist, the placement state, survival, shape update, `onPlace` | 2.1 to 2.4 |
| The fire tick, step by step, with every random draw in order | 2.5 |
| Neighbour burn-out and spread: formulas, tables | 2.6, 2.7 |
| Rain, infinite burn, increased burnout, the spread radius around players | 2.8 |
| Soul fire | 2.9 |
| Standing in fire, setting entities alight, breaking fire | 2.10, 2.11 |
| Who places fire, portal creation | 2.12 |
| Campfire rules not in 24-7 or 31-4 | 3 |
| TNT, spawners, vault, conduit, target, note block, jukebox, lectern, bell, daylight detector: owners | 4 |
| Budding amethyst | 5 |
| The residual coverage matrix and the unclaimed classes | 6, 7 |
| Worked examples, validation, open questions | 8, 9, 10 |

## 1. Scope, and what other documents already hold

| Topic | Owner (not repeated here) |
|---|---|
| The (ignite, burn) odds table for every flammable block, the fire tick summary, flint and steel, fire charge | 17 sections 3.3, 3.3a |
| Fire block registry rows (512 states of `fire`, 1 of `soul_fire`), the shape table | 24 part 2 (rows 180 and 181; the flammability table of section 5.7) |
| `TntBlock` in full (state, `prime`, the six ignition ways, unstable TNT, the primed TNT summary) | 30 part 7 section 8 (RS12), entity in 21 section 8.3 |
| Lava setting fire (`LiquidBlock`/`LavaFluid` random tick) | 29a section on lava (the rule `canSpreadFireAround` is described there as well) |
| Lightning starting fire | 33 section 4.4 and 29b-3 (`spawnFire`) |
| The game rules `fire_spread_radius_around_player`, `tnt_explodes`, `fire_damage` | 16 section 13 (defaults), 33 (consumers) |
| Inside-block effect ordering (`CLEAR_FREEZE`, `FIRE_IGNITE`, ...) | 29a (collector order), 44-1 |
| Entity fire ticks, burning damage, `igniteForSeconds` | 41, 18 section 2.5 |
| Fire client ambience (`BaseFireBlock.animateTick`, client only): once per animate tick draw `nextInt(24)`; on 0 play the local sound `fire.ambient` at the block centre (+0.5 on each axis), category blocks, volume `1 + nextFloat`, pitch `0.3 + nextFloat * 0.7`; the method then also spawns `large_smoke` particles depending on whether the neighbouring blocks can burn and the floor is sturdy (counts and offsets not recorded here). Read in this review. | 42 part 6 (`FIRE_AMBIENT`), 12 |
| Campfire block entity (cooking, items, tickers) | 31 part 4 section 5 |
| Campfire registry facts (properties, light, shapes, placement, water, douse) | 24 part 7 section 11.3 |

Hand-off to the owners of neighbour documents (this document does not edit them): (a) 17 section 3.3a step 7 (around line 485) says "dimension environment attribute" for `increased_fire_burnout`; the artifact reads it through the level's environment attributes at the fire position, true in exactly the 8 biomes of 2.8 and in none of the 4 `dimension_type` files, so 17 should say "environment attribute at the fire position (biome data)". (b) 30 part 7 section 8.1 and 8.3 cite "29b-3" for the `FireBlock` bootstrap table and for `checkBurnOut`; neither is in 29b part 3. The table is 17 section 3.3a and the burn-out step is 2.7 below.

## 2. Fire

### 2.1 Facts

| Item | Value (read) |
|---|---|
| Classes | `FireBlock extends BaseFireBlock`; `SoulFireBlock extends BaseFireBlock`; `BaseFireBlock extends Block` |
| `fire` properties | `age` (`AGE_15`, 0 to 15), `north`, `east`, `south`, `west`, `up` (booleans, the `PipeBlock` properties); no `down`. Default state: `age` 0 and all five flags false |
| `soul_fire` properties | none |
| `FireBlock` constants | `MAX_AGE` 15; fire damage of the class **1.0** (constructor argument to `BaseFireBlock`); the odds map `igniteOdds`/`burnOdds` filled by `bootStrap` (17 section 3.3a) |
| `SoulFireBlock` constants | fire damage **2.0** |
| Floor shape | `BaseFireBlock.SHAPE` = `column(16, 0, 1)`, a 1-pixel floor sheet. `FireBlock` shapes are the union of the rotated 1-pixel wall sheets of the set side flags (all six rotations are built; the property set has no `down`), or the floor sheet when no flag is set; the shape does not depend on `age` (24 part 2 gives the sheet table) |
| Random ticks | none. Fire is driven only by scheduled ticks (section 2.4); `soul_fire` has no tick at all |
| `canBurn(state)` | `FireBlock`: the state's ignite odds are greater than 0, and 0 when the state has the property `waterlogged` set true. `SoulFireBlock`: always true (and not called by any fire code read; Open question 7) |

Ignite and burn odds of a state (`getIgniteOdds(state)`, `getBurnOdds(state)`): 0 when the state has the property `waterlogged` and it is true; otherwise the pair registered for the state's block, 0 when the block is not registered (17 section 3.3a).

### 2.2 The placement state (`BaseFireBlock.getState(level, pos)`)

Used by `getStateForPlacement`, by flint and steel, fire charge and the dispenser (17 section 3.3, 30 part 4 section 4.10), by every spread (2.6, 2.7) and by the shape update (2.3).

1. If the block below `pos` is in tag `soul_fire_base_blocks` (data: `soul_sand`, `soul_soil`): result is the default state of `soul_fire`.
2. Otherwise `FireBlock.getStateForPlacement(level, pos)`:
   1. `below` = the state under `pos`. If `canBurn(below)` (it is flammable) **or** `below` has a sturdy UP face: the result is the default `fire` state (age 0, all side flags false).
   2. Otherwise start from the default `fire` state and set each of `north`, `east`, `south`, `west`, `up` to `canBurn(state of the neighbour in that direction)`; there is no `down` entry. (A fire in the air hanging on the sides of flammable blocks.)
3. The age is applied only by the callers that need it (`getStateWithAge(level, pos, age)`: when the result of this function is `fire`, it sets `age`; a `soul_fire` result is returned unchanged). So a fire that spreads onto a cell above soul sand or soul soil becomes `soul_fire`.

### 2.3 Survival and shape update

| Rule | Value |
|---|---|
| `FireBlock.canSurvive(state, level, pos)` | the block below has a sturdy UP face, **or** `isValidFireLocation(level, pos)` (any of the six neighbours has `canBurn` true) |
| `SoulFireBlock.canSurvive` | the block below is in tag `soul_fire_base_blocks` (`canSurviveOnBlock`) |
| `FireBlock.updateShape` (any direction) | if `canSurvive`: `getStateWithAge(level, pos, current age)` (so the side flags are recomputed from the neighbours, and the block turns into soul fire when the block below became soul sand or soil); else air |
| `SoulFireBlock.updateShape` | `canSurvive`: its default state; else air |

### 2.4 `onPlace`

`BaseFireBlock.onPlace(state, level, pos, oldState, moved)`:
1. If `oldState` is the same block (a fire state changing within fire): nothing.
2. If the dimension is the Overworld or the Nether (`inPortalDimension`): `PortalShape.findEmptyPortalShape(level, pos, axis X)`; when a shape is present, `createPortalBlocks(level)` is called on it and `onPlace` ends. (The portal shape search is not specified in the docs; Open question 3.)
3. Otherwise, if the new state cannot survive (`canSurvive`), the block is removed (`removeBlock(pos, false)`, flags 3).

`FireBlock.onPlace` calls the base method first and then always schedules a tick of the fire block at `pos` after `30 + nextInt(10)` ticks (`getFireTickDelay`; the draw is on `Level.getRandom`). It schedules even when step 2 or 3 ended the fire (the scheduled tick then finds another block). `SoulFireBlock` has no `onPlace` of its own beyond step 1 to 3, so it is never scheduled.

### 2.5 The fire tick (`FireBlock.tick(state, level, pos, random)`)

17 section 3.3a lists the steps; this section fixes the order of the draws and three details 17 does not state. `age` is the age read from `state` at entry and it is **not** updated inside the tick (every later use of `age` below is this entry value, including the burn-out chance and the spread divisor).

| # | Step | Draws and notes |
|---|---|---|
| 1 | Schedule the next tick at `30 + nextInt(10)` (30 to 39) ticks | one draw, on `ServerLevel.getRandom` (Open question 1) |
| 2 | If `level.canSpreadFireAround(pos)` is false: end (the fire stays, and keeps its schedule) | no draw. Rule in 2.8 |
| 3 | If `state.canSurvive` is false: `removeBlock(pos, false)`. **The tick does not end here**: it continues with the same stale `state` | see quirk A |
| 4 | `belowState` = the block below; `infiniburn` = `belowState` is in the tag the dimension type names as `infiniburn` | no draw |
| 5 | If not `infiniburn`, **and** `level.isRaining()`, **and** `isNearRain(pos)`: draw `nextFloat`; if it is below `0.2 + 0.03 * age`: `removeBlock(pos, false)` and end | draw only when all three tests hold. `isNearRain` = `isRainingAt` is true for `pos` or any of the four horizontal neighbours (west, east, north, south order; short circuit) |
| 6 | `newAge = min(15, age + nextInt(3) / 2)` (integer division: the draw 0, 1, 2 adds 0, 0, 1, so the age rises with probability 1/3). If `newAge != age`: write the state with the new age, flags **260** | one draw, always |
| 7 | If not `infiniburn`: **7a** if `isValidFireLocation(level, pos)` is false: remove the fire when (the block below has no sturdy UP face) **or** (`age > 3`), then end in every case. **7b** otherwise (a flammable neighbour exists): if `age == 15` **and** `nextInt(4) == 0` **and** `canBurn(belowState)` is false: remove and end | 7b draws `nextInt(4)` only when `age == 15` |
| 8 | `burnout` = `-50` when the environment attribute `gameplay/increased_fire_burnout` at `pos` is true, else 0 | no draw. Attribute in 2.8 |
| 9 | `checkBurnOut` on the six neighbours, in this order, each with the given chance and the entry `age`: east `300 + burnout`, west `300 + burnout`, below `250 + burnout`, above `250 + burnout`, north `300 + burnout`, south `300 + burnout` | draws in 2.7 |
| 10 | The spread loop (2.6) | draws in 2.6 |

Quirks:
- **A.** After step 3 removes a fire, the tick still reaches step 6 and may write the stale state back with a new age (only when the draw makes `newAge != age`, probability 1/3). Step 7a then removes it again, because a fire that cannot survive has no sturdy floor and no flammable neighbour (its `canSurvive` is exactly (sturdy floor) or (valid location)); 7a is skipped only on an `infiniburn` floor, and an infiniburn block (netherrack, magma block in the data read) is sturdy at its top, so a fire on it survives anyway. The net effect is the removal. Side effect of the write-back (inferred, not run: `onPlace` is not skipped by flags 260): the cell holds air at that moment, so writing the fire state replaces air with fire and runs `FireBlock.onPlace` (2.4). Its base part removes the block again because `canSurvive` is false, and then `FireBlock.onPlace` schedules another fire tick (`30 + nextInt(10)`, a `Level.getRandom` draw). So in that case one extra random draw occurs and one more scheduled tick is left on a cell that holds air (it finds another block when it runs). A faithful reimplementation that must keep the random stream aligned should reproduce this draw.
- **B.** The age write of step 6 uses flags 260 (29b-1 section 2.3): neighbours are not notified and clients are not sent the change (inferred from the flag set, 29 section 1), so a client never sees a fire's age.
- **C.** `infiniburn` fire is never removed by rain, by 7a or by 7b, but it still ages to 15 and burns its neighbours.

### 2.6 The spread loop (step 10)

Loop order, which fixes the draw order: `dx` from -1 to 1 (outermost), then `dz` from -1 to 1, then `dy` from -1 to 4 (innermost). The cell `(0, 0, 0)` is skipped, so 53 cells are visited. For each cell `q = pos + (dx, dy, dz)`:

1. `bound = 100`; when `dy > 1`: `bound = 100 + (dy - 1) * 100` (so dy 2, 3, 4 give 200, 300, 400).
2. `o = getIgniteOdds(level, q)`: 0 unless `q` is an empty block (air); otherwise the **maximum** over the six neighbours of `q` of `getIgniteOdds(state)` (a neighbour that is itself fire contributes 0, fire not being in the map). If `o <= 0` skip the cell (no draw).
3. `chance = (o + 40 + 7 * difficultyId) / (age + 30)` in integer division, `difficultyId` = `Difficulty.getId` (read: peaceful 0, easy 1, normal 2, hard 3). When the attribute of step 8 is true, `chance = chance / 2` (integer).
4. If `chance <= 0` skip (no draw).
5. Draw `nextInt(bound)`; the cell catches fire only when the draw is **less than or equal to** `chance` (so `chance + 1` of `bound` outcomes).
6. If it is raining and `isNearRain(q)`: skip (the draw of step 5 was already made).
7. Otherwise draw `nextInt(5)`; `newAge = min(15, age + draw / 4)` (so the age rises by 1 only when the draw is 4, probability 1/5), and `setBlockAndUpdate(q, getStateWithAge(level, q, newAge))` (flags 3). The placed block is `fire` with that age or, above soul sand or soil, `soul_fire` (2.2).

Table: the per-tick probability that one given empty cell with neighbour ignite odds `o` catches fire (before the rain test), for `age` 0 and 15, `bound` 100 (dy -1 to 1) and 200 (dy 2):

| `o` | difficulty | age 0: chance, P (bound 100), P (bound 200) | age 15: chance, P (bound 100) |
|---|---|---|---|
| 5 | normal (2) | (5+40+14)/30 = 1; 2%; 1% | 59/45 = 1; 2% |
| 15 | normal | 69/30 = 2; 3%; 1.5% | 69/45 = 1; 2% |
| 30 | peaceful (0) | 70/30 = 2; 3%; 1.5% | 70/45 = 1; 2% |
| 30 | normal | 84/30 = 2; 3%; 1.5% | 84/45 = 1; 2% |
| 30 | hard (3) | 91/30 = 3; 4%; 2% | 91/45 = 2; 3% |
| 60 | normal | 114/30 = 3; 4%; 2% | 114/45 = 2; 3% |
| 60 | hard | 121/30 = 4; 5%; 2.5% | 121/45 = 2; 3% |

(Arithmetic from the formula; the 7 per difficulty step is read.) With `increased_fire_burnout` true the chance is halved: `o` 30, normal, age 0 gives chance 1 and P 2%.

### 2.7 `checkBurnOut(level, pos, chance, random, age)`

`burnOdds` = `getBurnOdds` of the block at `pos` (17 section 3.3a, 0 when not flammable or waterlogged).
1. Draw `nextInt(chance)`; if it is not below `burnOdds` end. (So P = `burnOdds / chance`, capped at 1; a non-flammable block never passes.)
2. Draw `nextInt(age + 10)`. If it is below 5 **and** `level.isRainingAt(pos)` is false: draw `nextInt(5)`, `newAge = min(15, age + draw / 4)` and `setBlockAndUpdate(pos, getStateWithAge(level, pos, newAge))` (the burning block is replaced by fire or soul fire, flags 3). Otherwise `removeBlock(pos, false)` (the block is destroyed without drops).
3. If the block that was there before step 2 was a `TntBlock`: `TntBlock.prime(level, pos)` (owner null; 30 part 7 section 8.2). The priming happens after the block was replaced or removed, in both outcomes of step 2.

The second draw (step 2) happens only when the first passed, and the third only on the fire outcome.

### 2.8 Environment inputs

| Input | Value (read) |
|---|---|
| `infiniburn` | the dimension type field `infiniburn` names a block tag. Data read: `infiniburn_overworld` = `netherrack`, `magma_block`; `infiniburn_nether` = the overworld tag; `infiniburn_end` = the overworld tag and `bedrock`. Mapping read in the four `dimension_type` files: `overworld` and `overworld_caves` name `#minecraft:infiniburn_overworld`, `the_nether` names `infiniburn_nether`, `the_end` names `infiniburn_end` |
| `level.canSpreadFireAround(pos)` | the rule `fire_spread_radius_around_player` (default 128, second argument `-1`, 16 section 13): true when the rule is -1, else true when `ChunkMap.anyPlayerCloseEnoughTo(pos, rule)` (33 section 8 describes the distance test). With no player near, fires neither age nor spread nor burn out, and they keep rescheduling (step 1 runs before step 2) |
| `isRaining()` and `isRainingAt(pos)` | the level rain flag and the rain-at-position test of 33 section 4 (4.4 step 3; the consumer list there names `FireBlock`) |
| `gameplay/increased_fire_burnout` | an environment attribute of type boolean, default **false** (read in `EnvironmentAttributes`), looked up at the fire's position. In the shipped data it is set to true by 8 biomes: `bamboo_jungle`, `frozen_peaks`, `jagged_peaks`, `jungle`, `mangrove_swamp`, `mushroom_fields`, `snowy_slopes`, `swamp`; none of the four `dimension_type` files sets it (read). This corrects 17 section 3.3a step 7, which names the "dimension environment attribute" |
| `difficulty` | the level difficulty id (2.6 step 3) |

### 2.9 Soul fire

A `soul_fire` block is inert: it has no scheduled tick (so no aging, no spread, no burn-out, no rain extinguishing), it survives only on a block of tag `soul_fire_base_blocks`, it is removed by the shape update the moment that support goes (2.3), and it is created in place of fire wherever 2.2 finds soul sand or soil below. It deals fire damage **2.0** (2.10). It is a light source and a particle emitter by the registry (24 part 2, 42 part 6); this document adds nothing to those.

### 2.10 Standing in fire (`BaseFireBlock.entityInside`)

On any entity inside the block's cell, in this order within the inside-block-effect collector (29a for the ordering): the effect `CLEAR_FREEZE`, the effect `FIRE_IGNITE`, and an action registered to run after `FIRE_IGNITE` that hurts the entity with the damage source `in_fire` for the class fire damage (1.0 fire, 2.0 soul fire; the damage type is in 17 section 4.12). The `FIRE_IGNITE` effect calls `BaseFireBlock.fireIgnite(entity)`:
1. If the entity is fire immune: nothing.
2. If `remainingFireTicks < 0`: `remainingFireTicks += 1`.
3. Else if the entity is a `ServerPlayer`: `remainingFireTicks += nextInt(1, 3)` (one draw from the level random; the two-argument `nextInt(origin, bound)` has an exclusive upper bound and returns origin + nextInt(bound - origin), so the addend is **1 or 2**, each with probability 1/2; this is not the inclusive U(a,b) of 29b-1 section 2).
4. If now `remainingFireTicks >= 0`: `igniteForSeconds(8.0)`.

So an entity first gets the fire timer started at 8 seconds on the first tick it stands in the fire (the timer being at its resting negative value is counted up first; the meaning of the negative resting value is in 41 and 18 section 2.5). The rule `fire_damage` (a player-category boolean, default true, read in `GameRules`) is applied by the damage code, not here (Open question 4).

### 2.11 Breaking fire

`BaseFireBlock.playerWillDestroy` (a player hits the fire): on the server, level event **1009** (data 0) at the position with no source entity, then the default destroy. The client effect of event 1009 (the fire extinguish sound and smoke) is in 42 part 6 and 42 part 7; the same event id is used by the campfire douse (24 part 7 section 11.3). `spawnDestroyByEntityParticles` of fire does nothing.

### 2.12 Who places fire (pointers) and the portal hook

| Producer | Where |
|---|---|
| Flint and steel, fire charge, dispenser with flint and steel | 17 section 3.3 (`canBePlacedAt`: the target is air and (the placement state can survive or an Overworld or Nether portal frame is found next to it, `isPortal`)), 30 part 4 section 4.10 |
| Lava random tick, lightning | 29a, 33, 29b-3 (the `spawnFire` reference in 33 and in 30-7 should be checked by their owners, see section 1) |
| Fire spread and burn-out | 2.6, 2.7 |
| End crystal beam fire (the fire cell under a crystal) | 21 (the crystal's `FireBlock.getState` use) |
| Nether portal creation on `onPlace` | 2.4 step 2 (shape search and block creation not specified: Open question 3) |

## 3. Campfire: the delta over 24 part 7 section 11.3 and 31 part 4

Constructor arguments (`spawnParticles`, `fireDamage`): campfire (true, 1), soul campfire (false, 2) (read in the two `Blocks` lambdas; 24-7 gives the same). Everything in 24-7 section 11.3 (properties, shape, placement, water, douse, fire arrow lighting, damage) was read again and agrees. Additional rules read:

| Rule | Value |
|---|---|
| `updateShape` | when the block is `waterlogged`, schedule a water tick (`FlowingFluid.getTickDelay`); when the changed direction is DOWN, `signal_fire` becomes "the neighbour below is a `hay_block`" (`isSmokeSource`), nothing else changes; every other direction calls the base method |
| `canLight(state)` (used by flint and steel, fire charge, the dispenser) | the state is in block tag `campfires`, `waterlogged` is false and `lit` is false |
| Contact | `entityInside`: when `lit` is true and the entity is a `LivingEntity`: `hurt(campfire damage source, fireDamage as float)`; then the base inside logic. There is no fire-immunity test and no ignition of the entity (a campfire does not set entities alight); a fire-immune entity ignores the damage through the damage type tags (17 section 4.12) |
| Block tick | none. A campfire has no scheduled tick, no random tick and no neighbour hook; the only timed behaviour is the block entity ticker (31-4 section 5.3). It does not spread fire |
| `isSmokeyPos(level, pos)` (the "smoky" test used by bee sedation, 31-4 section 5.9, and the loot predicate `smokey`, 26) | scan `i` from 1 to 5: let `p = pos` moved down by `i`. (a) If the state at `p` is a lit campfire (`isLitCampfire`: has `lit`, is in tag `campfires`, `lit` true): return true. (b) Else if the collision shape of the state at `p` (evaluated with the empty collision context) intersects the post shape `SHAPE_VIRTUAL_POST` = `column(4, 0, 16)` (a 4 by 4 pixel post, full height, centred): return whether the state **one more block down** (`p.below()`) is a lit campfire. (c) Else continue. After `i = 5` return false. So smoke passes through up to 5 cells without a blocking collision, and a blocking cell stops the scan but still counts a lit campfire directly beneath it (the campfire may therefore be up to 6 below `pos`) |
| Smoke particle constants | `makeParticles` (client): 42 part 6 section 4.1 |

## 4. The other blocks named in the round scope

The override scan of section 7 found no `tick`, `randomTick` or `neighborChanged` method in `SpawnerBlock`, `TrialSpawnerBlock`, `VaultBlock`, `ConduitBlock`, `JukeboxBlock` or `DaylightDetectorBlock`; their timed behaviour is entirely in block entity tickers. The rest are owned elsewhere.

| Class | Overrides found (read) | Owner |
|---|---|---|
| `TntBlock` | `onPlace`, `neighborChanged`, `useItemOn`, `onProjectileHit`, `playerWillDestroy`, `wasExploded`, `dropFromExplosion`; `prime`; no tick | 30 part 7 section 8 (read again: `prime` steps, spawn at x+0.5, y, z+0.5, fuse 80, `PRIME_FUSE`, the chain fuse `nextInt(max(1, fuse/4)) + fuse/8`, `tnt_explodes` gates, all agree). Fire handoff: 2.7 step 3. Explosion algorithm: not specified (30-7 Open question 6; `PrimedTnt.explode` calls `Level.explode` with power 4.0 at y + 0.0625, no fire, interaction TNT: 21 section 8.3) |
| `SpawnerBlock` | none of the three (spawn-after-break experience only) | 31 part 7 |
| `TrialSpawnerBlock` | none | 31 part 7 |
| `VaultBlock` | `useItemOn` only | 31 part 7 section on vault use |
| `ConduitBlock` | `updateShape`: when `waterlogged`, schedule a water tick (`FlowingFluid.getTickDelay`), then the base method; block entity ticker (client and server) | 24 part 8 (registry row 626), block entity in 31 (`conduit` row 25 of 31-8, whose own part file is absent: see Open question 8) |
| `TargetBlock` | `onPlace`, `onProjectileHit`, `tick` (resets `power` to 0 when not 0) | 30 part 5 section 6 (activation ticks 20 for arrows, 8 otherwise, strength from the hit position) |
| `NoteBlock` | `neighborChanged`, `updateShape`, `useItemOn`, `useWithoutItem`, `attack`, `triggerEvent` | 30 part 5 section 8 |
| `JukeboxBlock` | `useItemOn`, `useWithoutItem`, `affectNeighborsAfterRemoval` | 31 part 4 section 2, 30 part 5 section 9 |
| `LecternBlock` | `tick` (clears `powered`), `useItemOn`, `useWithoutItem`, `affectNeighborsAfterRemoval` | 31 part 4 section 3.7 |
| `BellBlock` | `neighborChanged` (rising edge rings), `onProjectileHit`, `onExplosionHit`, `updateShape`, `useWithoutItem` | 31 part 4 section 4.5, 30 part 8 |
| `DaylightDetectorBlock` | `useWithoutItem` only | 30 part 5 section 5 |

## 5. Budding amethyst (`BuddingAmethystBlock`)

Owned by 29b-6 section 3.3 (one owner, so the two cannot drift). Re-read here and in agreement: `GROWTH_CHANCE` 5; `nextInt(5)` must be 0; then `nextInt(6)` indexes `Direction.values()` (down, up, north, south, west, east); the four-stage chain small, medium, large, cluster requires `facing` equal to the chosen face; `waterlogged` from the fluid of the replaced state. Per random tick one given face grows with probability 1/30. Worked example 10 below uses that rule.

## 6. Method of the residual sweep

1. The set: all 330 top-level classes (410 `.class` files, 80 of them inner classes) under `net/minecraft/world/level/block` were disassembled and the declared (not inherited) methods named `tick`, `randomTick`, `neighborChanged` were listed (105 classes; the match was on declared members of any visibility, private ones included, so a repeat of the scan with `javap -p` gives the same set; the subclasses of `WeatheringCopper*` and the abstract bases are included, the inner classes are not). The sub-packages `piston` and `entity` were not scanned for these three names (pistons are 30 part 3; block entities are 31).
2. For each class every document in `docs/protocol/` that names it was listed, and the claims below were checked by reading the cited section, not by the name alone.
3. Status: **Covered** (a document specifies the behaviour, cited to a section), **Partial** (the document specifies one aspect, the missing aspect is named), **Unclaimed** (no document specifies the tick or the neighbour rule).

## 7. Coverage matrix (class to document)

Documents present when this matrix was revised: 29b parts 1 to 8 (part 4 is growing plants, part 6 is sculk, amethyst and dripstone, part 7 is aquatic eggs, honey and cauldron), 29a, 30 parts 1 to 8, 31 parts 1 to 4 and 6 to 8, 24 parts 1 to 8. The `Weathering*` abbreviation in the copper row below stands for the ten classes `WeatheringCopperBarsBlock`, `WeatheringCopperBulbBlock`, `WeatheringCopperChainBlock`, `WeatheringCopperChestBlock`, `WeatheringCopperDoorBlock`, `WeatheringCopperGolemStatueBlock`, `WeatheringCopperGrateBlock`, `WeatheringCopperSlabBlock`, `WeatheringCopperStairBlock`, `WeatheringCopperTrapDoorBlock` (each declares the weathering random tick; all ten were counted in the 105).

| Class (hooks declared) | Status | Document |
|---|---|---|
| `FireBlock` (`tick`, `onPlace`, `updateShape`), `BaseFireBlock`, `SoulFireBlock` | Covered | 17 section 3.3a plus this document sections 2 |
| `FallingBlock` (`tick`, `onPlace`, `updateShape`) | Covered | 29b-1 section 3 |
| `ScaffoldingBlock`, `BrushableBlock` | Covered | 29b-1 sections 3.7, 3.5; 31-4 |
| `SaplingBlock` | Covered | 29b-1 section 7 |
| `CropBlock`, `BeetrootBlock`, `TorchflowerCropBlock`, `PitcherCropBlock`, `NetherWartBlock`, `CocoaBlock`, `SweetBerryBushBlock`, `StemBlock`, `MangrovePropaguleBlock`, `FarmlandBlock`, `PathBlock` | Covered | 29b-1 section 6, 29b-2 |
| `SpreadingSnowyBlock`, `NyliumBlock`, `LeavesBlock`, `SnowLayerBlock`, `IceBlock`, `FrostedIceBlock`, `SpongeBlock` | Covered | 29b-3 |
| `MushroomBlock`, `WeatheringCopperFullBlock`, `...SlabBlock`, `...StairBlock`, `...BarsBlock`, `...ChainBlock`, `...GrateBlock`, `...BulbBlock`, `...ChestBlock`, `...DoorBlock`, `...TrapDoorBlock`, `...GolemStatueBlock`, `WeatheringLanternBlock`, `WeatheringLightningRodBlock` (random tick = the oxidation engine) | Covered | 29b-5 |
| `LightningRodBlock` (`tick`, `onPlace`) | Covered | 30 part 5 section 7, 29b-3 |
| `CoralBlock`, `CoralPlantBlock`, `CoralFanBlock`, `CoralWallFanBlock`, `TurtleEggBlock` (random tick), `SnifferEggBlock`, `FrogspawnBlock`, `AbstractCauldronBlock` (`tick`: stalactite fill), `HoneyBlock`, beehive | Covered | 29b-7 sections 2 to 9 (and 24 parts 6 and 8) |
| `LiquidBlock`, `BubbleColumnBlock`, `GrowingPlantHeadBlock` (water tick only) | Covered / Partial | 29a; `GrowingPlantHeadBlock` growth: see below |
| `RedstoneWireBlock`, `RedstoneTorchBlock`, `RedStoneOreBlock`, `CopperBulbBlock` | Covered | 30 parts 1 and 7 |
| `DiodeBlock`, `ComparatorBlock`, `ObserverBlock` | Covered | 30 part 2 |
| `PistonBaseBlock` family | Covered | 30 part 3 (outside the scan) |
| `DispenserBlock`, `HopperBlock`, `CrafterBlock` | Covered | 30 part 4 |
| `ButtonBlock`, `BasePressurePlateBlock`, `TargetBlock`, `NoteBlock`, `DaylightDetectorBlock`, `LeverBlock` | Covered | 30 part 5 |
| `BaseRailBlock`, `DetectorRailBlock`, `PoweredRailBlock` | Covered | 30 part 6, 29 |
| `DoorBlock`, `TrapDoorBlock`, `FenceGateBlock`, `RedstoneLampBlock`, `TntBlock` | Covered | 30 part 7 |
| `TripWireBlock`, `TripWireHookBlock`, `SculkSensorBlock`, `SculkShriekerBlock`, `BellBlock` | Covered | 30 part 8, 31 part 8, 31-4 |
| `SculkCatalystBlock` (`tick` resets `bloom`) | Covered | 31 part 8 section on the catalyst |
| `BarrelBlock`, `ChestBlock`, `EnderChestBlock` (`tick` = lid recheck) | Covered | 31 part 1 |
| `CommandBlock`, `StructureBlock`, `TestBlock` | Covered | 31 part 6 |
| `AbstractSkullBlock` (`neighborChanged`), `ShelfBlock` | Covered | 31 part 3, 30 part 1 |
| `LecternBlock` | Covered | 31 part 4 |
| `CactusBlock`, `SugarCaneBlock`, `ChorusFlowerBlock`, `ChorusPlantBlock`, `ComposterBlock`, `NetherPortalBlock` (random tick spawn), `CreakingHeartBlock` | Covered in the registry documents | 24 part 3 section 7.10.1 and 7.10.2, 24 part 6 (chorus, kelp, bamboo builders), 24 part 7 section 14.1, 24 part 3 (portal row), 24 part 2 section 7.12 |
| `BuddingAmethystBlock` | Covered | 29b-6 section 3.3 (owner); section 5 here is a pointer |
| `EyeblossomBlock` (random tick: open and close by the `eyeblossom_open` attribute) | Covered | 29b-4 section 10.3 |
| `FlowerPotBlock` (`randomTick`, `isRandomlyTicking`: only `potted_open_eyeblossom` and `potted_closed_eyeblossom` tick) | **Partial** (specified here, section 7.1) | 29b-4 does not name the pot; the rule is in section 7.1 below |
| `VineBlock` (`randomTick`: spread, gated by `spread_vines`) | Covered | 29b-4 section 7 (full text 24 part 4 section 6.7; gate in 33) |
| `BambooSaplingBlock`, `BambooStalkBlock` (`randomTick`, `tick`, `updateShape`) | Covered | 29b-4 section 6 |
| `GrowingPlantBlock` (`tick`), `GrowingPlantHeadBlock` (`randomTick`, `isRandomlyTicking`), the body class: kelp, weeping and twisting vines, cave vines | Covered | 29b-4 section 3 (3.2 engine, 3.3 to 3.5 per plant) |
| `BigDripleafBlock`, `BigDripleafStemBlock` (`tick`: tilt), `HangingMossBlock` (`tick`) | Covered | 29b-4 sections 12 (dripleaf) and 13.3 (hanging moss); rows in 24 part 8, redstone note in 30 part 8 |
| `SpeleothemBlock`, `PointedDripstoneBlock` (pointed dripstone, sulfur spike: `randomTick`, `tick`, `onProjectileHit`, `fallOn`, and the overrides `PointedDripstoneBlock` declares itself) | Covered | 29b-6 sections 4 to 9 (growth 5, falling 6, fluid and cauldron 7 and 8); also 29b-1 section 3.8, 29b-7 section 8.6 |
| `DriedGhastBlock` (`tick`, `randomTick`, `updateShape`) | Covered | 24 part 6 (rows and the hydration rules); not re-read here |
| `DragonEggBlock` (`attack`, `useWithoutItem`), `ConcretePowderBlock`, `ColoredFallingBlock` | Covered | 29b-1 |

The matrix lists only the three hook names `tick`, `randomTick` and `neighborChanged`; it is not the whole answer to what ticks or reacts. Other hook families are covered elsewhere: `updateShape`, `entityInside`, `fallOn` (farmland and turtle egg trampling), `onPlace` schedulers and block entity tickers are in the owner documents of each block (24, 29, 30, 31, 29a); candles (`CandleBlock`, `AbstractCandleBlock`) are in 29b-7, 24 part 8 and 31 part 4 mentions; `SculkSpreader`, `SculkBlock` and `SculkVeinBlock` are driven from the catalyst block entity (29b-6, 31-8); honey and slime movement is in 29b-7 and 18.

Remaining work list: only the `FlowerPotBlock` random tick was not claimed by another part; it is specified in 7.1 below. Everything else flagged in the first version of this matrix is now Covered by 29b-4 and 29b-6.

### 7.1 `FlowerPotBlock` random tick (residual)

The pot is random-ticking only when its state is `potted_open_eyeblossom` or `potted_closed_eyeblossom` (read: `isRandomlyTicking`). Its `randomTick`:
1. `open` = whether the pot's contained block is `open_eyeblossom`.
2. `want` = the attribute `gameplay/eyeblossom_open` at the pot position (tri-state) turned into a boolean with `open` as the default for the unset case (as 29b-4 section 10.3).
3. If `want == open`: nothing else of this rule happens.
4. Else: `setBlockAndUpdate(pos, opposite(state))` (the other potted eyeblossom, flags 3); the transform particle of the new type (`spawnTransformParticle`, as 29b-4 section 10.3); then `ServerLevel.playSound` is called with no source entity (null), the pot position, the long switch sound of the NEW type (the type obtained by transforming the type derived from the old open flag), category blocks, volume 1.0 and pitch 1.0 (read to the end of the method).
5. In every case the inherited `Block.randomTick` is then called (no effect read).
The method contains no game event and no neighbour or tick scheduling (read, whole method), so no `BLOCK_CHANGE` game event is sent beyond whatever `setBlockAndUpdate` does by default. The sequence is: `setBlockAndUpdate`, particle, `playSound`, then the inherited `Block.randomTick`.

## 8. Worked examples

1. **Spread chance next to leaves, normal difficulty.** An empty cell beside `oak_leaves` (ignite odds 30) next to a fire of age 0 on normal (id 2): chance = (30 + 40 + 14) / 30 = 84 / 30 = 2. The cell at `dy` 0 (bound 100) catches fire when `nextInt(100)` is 0, 1 or 2: 3%. The same cell at `dy` 2 has bound 200: 1.5%. At age 15 the divisor is 45: chance 1, 2%.
2. **Burn-out of planks.** Fire age 0 with an `oak_planks` block (burn odds 20) east of it: `nextInt(300) < 20` is 20/300 = 6.67%. On success `nextInt(10) < 5` (50%) with no rain turns the planks into fire (`nextInt(5)/4` is 0 unless the draw is 4, so mostly age 0), else the planks are removed. Per tick: 3.33% becomes fire, 3.33% is simply removed. Planks below the fire use chance 250: 20/250 = 8%. At fire age 5 the "becomes fire" branch is `nextInt(15) < 5`: 33%.
3. **Leaves are faster.** `oak_leaves` (burn odds 60) east of an age-0 fire: 60/300 = 20% per tick pass the first draw; with `increased_fire_burnout` the chance is 250: 24%.
4. **Rain.** In rain, a fire (not on netherrack) of age 3 ending up in step 5 is removed with probability 0.2 + 0.03 * 3 = 0.29 each tick it is processed; at age 15 it is 0.65.
5. **An isolated fire.** A fire on a sturdy non-flammable floor with no flammable neighbour: step 6 raises the age with probability 1/3 per tick; step 7a removes it when the entry age is above 3. The age is 4 or more at entry after on average 12 ticks, and it is removed in the next one: about 13 ticks of 34.5 game ticks on average (30 + mean of 0 to 9 is 34.5): about 450 game ticks, 22 seconds (inferred arithmetic, mean of a sum of geometric waits).
6. **Fire on netherrack.** Same fire on `netherrack`: `infiniburn` is true, step 7 is skipped, rain is ignored, the fire ages to 15 and stays; if a flammable block is next to it the burn-out and spread steps keep running.
7. **Soul fire by spreading.** A fire spreads (step 10) to an empty cell whose floor is `soul_sand`: `getStateWithAge` finds `getState` = `soul_fire`, returns it without an age, and the new block is a soul fire that never ticks.
8. **Chain to TNT.** A fire next to `tnt` (burn odds 100) at east, age 0, no rain: P(`nextInt(300) < 100`) = 33%; the TNT block is then replaced (50%: fire) or removed (50%), and in both cases `prime` creates a primed TNT at the cell (30 part 7).
9. **Smoke scan.** A lit campfire at (0, 60, 0), a trapdoor-free column above, `isSmokeyPos` at (0, 65, 0): `i` 5 gives (0, 60, 0): lit campfire, true. A `stone` block at (0, 62, 0) stops the scan at `i` 3 (its collision overlaps the post) and the cell under it (0, 61, 0) is air: false.
10. **Budding amethyst.** A budding block with air above and a small bud already at its east side facing east: a tick draws 0 on `nextInt(5)` (1/5), then the face draw picks EAST (index 5, 1/6): the small bud becomes a medium bud with `facing = east`; a pick of any other face with a non-air, non-bud neighbour does nothing.

## 9. Validation (checkable facts)

1. `fire` has 512 states and `soul_fire` 1; `age` 0 to 15; no `down` flag (24 part 2).
2. Fire tick delay = 30 + nextInt(10): 30 to 39; scheduled on every `onPlace` of a fire (including the `onPlace` calls caused by `setBlock` without skip-on-place).
3. A fire whose entry age is 3 on a sturdy floor with no flammable neighbour is not removed by step 7a; at entry age 4 it is.
4. The spread loop has 53 cells; the `bound` of a cell at `dy` 4 is 400.
5. `chance` uses the entry age and integer division; on peaceful `o` 15 gives (15 + 40) / 30 = 1.
6. After a burn-out the burnt TNT is primed even when the cell became fire.
7. `soul_fire` has no scheduled tick: an unlit world step never ages it.
8. `isSmokeyPos` scans 5 cells below, and a lit campfire 6 below a blocking cell counts.
9. `increased_fire_burnout` default false; true in exactly the 8 biomes of 2.8 in the shipped data.
10. A budding amethyst needs 1 of 5, then 1 of 6, before any growth is considered.
11. The sweep set is 105 classes of 330 top-level block classes (410 `.class` files including 80 inner classes) (the count of declared overrides, not subclass-inherited ones).

## 10. Open questions

1. **Which random source.** `FireBlock.tick` receives a `random` argument and also calls `ServerLevel.getRandom` for the reschedule delay (and `onPlace` uses `Level.getRandom`); whether the two are the same object when the scheduled tick runs was not read. An implementation with one source differs from the artifact only if they are distinct streams.
2. **Level event 1009 on the client.** The id is read on the server (fire destroy, campfire douse); its sound and particle mapping was not re-read (42 part 7).
3. **Nether portal creation by fire.** `BaseFireBlock.onPlace` calls `PortalShape.findEmptyPortalShape` and `createPortalBlocks`, and `isPortal` is used when placing fire (17 section 3.3): the portal frame rules (sizes, axes, the frame predicate, the portal block creation, `PortalShape.findAnyShape` for `updateShape`) are specified in no document.
4. **The `fire_damage` rule.** `GameRules.FIRE_DAMAGE` exists (boolean, default true, player category). Where it is consulted (the damage code, for `in_fire` and `on_fire`) was not read.
5. **`isRainingAt` and `anyPlayerCloseEnoughTo` bodies** are cited from 33 and 29a, not re-read here.
6. **`Explosion` chain and `PrimedTnt.explode`.** Only the handoff is covered; the explosion algorithm is an open question of 30 part 7 as well.
7. **`SoulFireBlock.canBurn` returns true** and no fire code read calls it on a soul fire (inferred unused).
8. **`conduit` block entity.** 31-8 lists `conduit` as owned by "31-5 or 31-6" (file absent); the `ConduitBlockEntity` ticker and the effect rules are in no document.
9. **Difficulty ids.** Read from the `Difficulty` constants (peaceful 0, easy 1, normal 2, hard 3); the ids as used by the damage scaling are not repeated.
10. **Residual ticks.** All classes flagged in the first version of section 7 are now owned by 29b-4 and 29b-6 except the `FlowerPotBlock` tick, specified in 7.1 (read in full).
11. **Client age of fire.** That the client never receives fire age changes (flags 260) is inferred from the flag meanings of 29 section 1; the shipped client's use of `age` (rendering) was not read.
12. **The sub-packages** `block/piston` and `block/entity` were not scanned for `tick`, `randomTick`, `neighborChanged` in section 7; pistons are 30 part 3 and the block entities 31.
13. (Closed.) The dimension to `infiniburn` tag mapping was read in the four `dimension_type` files and is in 2.8.
14. (Closed.) `FlowerPotBlock.randomTick` was read to its end and is in 7.1.
