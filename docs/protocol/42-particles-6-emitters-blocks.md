# 42. Particles, part 6: emitters driven by blocks

| | |
|---|---|
| Covers | Every particle emission whose cause is a block: the client-level `animateTick` sampler (range, sample count, marker rule, fluid drips, ambient particles); all `animateTick` overrides of block and fluid classes; block-entity client tickers (campfire, trial spawner, vault, spawner, end gateway, potent sulfur and geyser); block-driven level events (composter, bone meal, wax, scrape, sculk charge and shriek, trial spawner, extinguish, redstone-torch burnout, end-portal frame, note block); block break, hit and crack particles; entity-on-block particles (sprint, landing, honey); block-driven server-sent particles. For each: condition, particle, count, position offset, velocity, probability and random-number order. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `ClientLevel`, `Minecraft` (tick call site), `LevelEventHandler`, `ParticleEngine`, `MultiPlayerGameMode`, `ClientPacketListener.handleParticleEvent`, `net.minecraft.util.ParticleUtils`, `Mth`, `Vec3`, all 53 classes that mention `animateTick`, block entities (`CampfireBlockEntity`, `TrialSpawner`, `TrialSpawnerState$ParticleEmission`, `VaultBlockEntity$Client`, `BaseSpawner`, `PotentSulfurBlockEntity`, `CreakingHeartBlockEntity`), `ComposterBlock`, `HoneyBlock`, `NoteBlock`, `PowderSnowBlock`, `DecoratedPotBlock`, `BoneMealItem`, `Entity`, `LivingEntity`, `Blocks` (constructor arguments). Scratch notes were kept outside the repository. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-15, RS24). Particle sprite definitions and the data attributes that choose ambient particles are DATA, extracted by a tool (see 42-1 section 9); this document specifies the emitters (code). The particle objects themselves (motion, lifetime, rendering) belong to 42-1 (model, `ClientLevel.addParticle` tests in its 7.1, the packet in its 7.2) and to the per-type parts 42-2 to 42-5; they are not repeated here. Entity, item, explosion, weather and other non-block emitters belong to 42-7. |

Conventions. A tick is one client tick (20 per second). `P` is the block position of the emitter (integer corner), `(X, Y, Z)` its coordinates. `rd` = `RandomSource.nextDouble()`, `rf` = `nextFloat()`, `rg` = `nextGaussian()`, `rb` = `nextBoolean()`, `ri(n)` = `nextInt(n)`. A `float` constant stays single precision until it is widened to double. The reader's decompiler printed `0.10000000149011612` and similar for single-precision 0.1 constants; the table below writes the float value. "emit(type, x, y, z, vx, vy, vz)" is `Level.addParticle(type, x, y, z, vx, vy, vz)` (tests of 42-1 section 7.1 apply: override limiter of the type, distance 32 blocks, particle status), unless the row says "always visible", which means `addAlwaysVisibleParticle` (alwaysShow true, so the status downgrade of 42-1 7.1 uses its alternative branch). Random draws are listed in the order the artifact makes them, because a deterministic client test needs it; an implementation is free to use any generator (the draws are not observable across clients). Vec3 offsets and the `Direction` order (down, up, north, south, west, east, the `Direction.values()` order) follow 42-1 and the existing documents. The `Direction.values()` order was read from the static initialiser of `Direction`: constants are declared DOWN, UP, NORTH, SOUTH, WEST, EAST; `Direction$Plane.HORIZONTAL` iterates NORTH, EAST, SOUTH, WEST.

---

## 1. Scheduling: `ClientLevel.animateTick`

### 1.1 Call site

`Minecraft.tick` calls `ClientLevel.animateTick(playerBlockX, playerBlockY, playerBlockZ)` once per client tick, in the step labelled `animateTick`, only when the game is not paused and the level is running normally (`isLevelRunningNormally`), and before the `particles` step (the engine tick, 42-1 5.5).

### 1.2 Sampling

Per call: a thread-local random source `R` is created (this is the source handed to the blocks); the marker target `M` is computed (1.4); then the loop runs 667 times, and each iteration calls `doAnimateTick(px, py, pz, 16, R, M)` and then `doAnimateTick(px, py, pz, 32, R, M)`. So 667 samples with radius 16 and 667 samples with radius 32 per tick, 1334 in all. The radius-32 pass exists so that far, rare emitters (spore blossom, firefly bush) still appear.

`doAnimateTick(cx, cy, cz, r, R, M)`:

1. Pick a cell: `x = cx + L.ri(r) - L.ri(r)`, `y = cy + L.ri(r) - L.ri(r)`, `z = cz + L.ri(r) - L.ri(r)`, where `L` is the level's own random source (`ClientLevel.random`); this is a triangular distribution on (-r+1 .. r-1) per axis, concentrated near the player.
2. Block step: `state = blockAt(x,y,z)`; call `state.block.animateTick(state, level, pos, R)`. Sections 3 and 4 give every override; the base `Block.animateTick` does nothing.
3. Fluid step: `fluid = fluidAt(pos)`. If not empty: call `fluid.animateTick(level, pos, R)` (section 5); then `drip = fluid.getDripParticle()` (water: `dripping_water`; lava: `dripping_lava`; other fluids: none). If `drip` exists and `L.ri(10) == 0` (probability 1/10): `trySpawnDripParticles(pos.below(), state at pos.below(), drip, sturdyBelow)` where `sturdyBelow` is `state.isFaceSturdy(pos, DOWN)` of the cell that holds the fluid (section 2.1).
4. Marker step: if `M` is not null and `state.block == M`: emit `block_marker` with option `state` at `(x+0.5, y+0.5, z+0.5)`, velocity 0 (1.4).
5. Ambient step: if the state's collision shape is not a full block: for each entry of the environment attribute `ambient_particles` at `pos` (a list; data, see 1.3): if `entry.canSpawn(L)` then emit `entry.particle` at `(x + L.rd, y + L.rd, z + L.rd)` with velocity 0.

Note the steps use three random sources: `R` for the block and fluid animate methods, `L` for position picking, the drip chance and the ambient entries.

### 1.3 Ambient particles (data)

The attribute `ambient_particles` (an environment attribute, a list of `{particle, probability}` entries sampled with `canSpawn(random)`) comes from the data pack (biome and dimension environment attributes, for example the underwater suspended-particle and warped, crimson, soul-sand-valley and ash biome emitters). Their values are data rows and are not tabulated here; the engine rule is step 5 above. `AmbientParticle` (a record `{particle, probability}`; codec: field `particle` is a particle type with options, field `probability` is a float in 0..1) was read: `canSpawn(random)` draws one `rf` and is true when `rf <= probability` (inclusive; probability 0 therefore still passes with the draw exactly 0.0, probability 1 always passes). One `rf` draw is made per entry per sampled cell, on the level's own source `L`. The list of environments that carry the attribute is data (Open question 2).

### 1.4 Marker particles (barrier, light)

`getMarkerParticleTarget()` returns a block when all hold: the local player's game mode is creative, the item in the main hand is in the set `{barrier, light}` (`MARKER_PARTICLE_ITEMS`), and the item is a block item; the returned block is that item's block. Otherwise null. Every sampled cell (both radii) whose block equals the target emits one `block_marker` particle as in step 4. There is no probability: every sampled matching cell emits. The barrier and light blocks have no other particle code. (Structure void: no `animateTick` and not in the marker set, so no marker.)

### 1.5 Fluid drip placement (`trySpawnDripParticles(below, belowState, drip, sturdy)`)

Inputs: the position under the fluid cell and its state.

1. If `belowState` has a fluid: stop.
2. `shape = belowState.getCollisionShape(level, below)`; `top = shape.max(Y)` (0 when the shape is empty).
3. If `top < 1` (the lower block does not fill its cell): if `sturdy` (the fluid cell's own bottom face is sturdy) emit one drip at the unit square of `below` at `y = below.Y + 1 - 0.05` (position by 1.6 with box x in `[X, X+1]`, z in `[Z, Z+1]`); if not sturdy, emit nothing. Stop either way.
4. Else (`top >= 1`): if `belowState` is in tag `impermeable`, stop (confirmed against the bytecode). `bottom = shape.min(Y)`. If `bottom > 0`: emit with the shape's x and z extents at `y = below.Y + bottom - 0.05`; stop. Else (bottom is 0): `under = below.below()`, `us = state(under)`; `ut = us.collisionShape.max(Y)`; if `ut < 1` and `us` has no fluid, emit with the shape's x and z extents at `y = below.Y - 0.05`; otherwise emit nothing.

Note the cell the drip starts from is the one under the fluid (`below`); the lower tests read one block further down. The branch order above was checked against the bytecode a second time; `sturdy` is the boolean argument computed in 1.2 step 3.

### 1.6 Drip position (`spawnFluidParticle`)

`emit(drip, lerp(L.rd, x1, x2), y, lerp(L.rd, z1, z2), 0, 0, 0)` with `lerp(t, a, b) = a + t(b-a)`. Draw order: the x draw first, then the z draw. `x1 = X + shape.minX`, `x2 = X + shape.maxX` (and likewise z) when the shape extents are used; the unit-square variant uses `X`, `X+1`, `Z`, `Z+1`. The same helper in `BeehiveBlock` uses the block's own `getRandom()` (section 4, honey).

---

## 2. Shared helper algorithms

### 2.1 `ParticleUtils` (net.minecraft.util)

| Helper | Behaviour |
|---|---|
| `spawnParticleBelow(level, pos, rnd, opts)` | emit at `(X + rd, Y - 0.05, Z + rd)`, velocity 0 (x draw, then z). |
| `spawnParticlesOnBlockFaces(level, pos, opts, countProvider)` | for each of the six directions (order of `Direction.values()`): `spawnParticlesOnBlockFace(..., dir, supplier=randomSpeedRanges, offset 0.55)`. |
| `spawnParticlesOnBlockFace(level, pos, opts, countProvider, dir, velocitySupplier, offset)` | `n = countProvider.sample(level.random)`; repeat n times: `spawnParticleOnFace(level, pos, dir, opts, velocitySupplier(), offset)`. The supplier is evaluated first for each particle. |
| `randomSpeedRanges(rnd)` | vector of three draws `Mth.nextDouble(rnd, -0.5, 0.5)` = `rd - 0.5`, order x, y, z. |
| `spawnParticleOnFace(level, pos, dir, opts, speed, offset)` | `c = pos + (0.5, 0.5, 0.5)`. For each axis a: if `dir.step[a] != 0` the coordinate is `c[a] + dir.step[a] * offset`; else `c[a] + Mth.nextDouble(rnd, -0.5, 0.5)`. Velocity on axis a is 0 when `dir.step[a] != 0`, else `speed[a]`. Position draws are made in x, y, z order, only for axes that are not the face axis. |
| `spawnParticlesAlongAxis(axis, level, pos, spread, opts, countProvider)` | `c` = block centre. `n = countProvider.sample(rnd)`. Per particle, for each axis a in x, y, z order: coordinate `c[a] + Mth.nextDouble(rnd, -1, 1) * (a == axis ? 0.5 : spread)`; then velocity draws, only for `a == axis`: `Mth.nextDouble(rnd, -1, 1)`, all other velocity components 0. Draw order: three positions, then the one velocity. |
| `spawnParticleInBlock(level, pos, count, opts)` | `h = state.isAir ? 1 : state.shape.max(Y)`; then `spawnParticles(level, pos, count, spread 0.5, height h, freeFloat true, opts)`. |
| `spawnParticles(level, pos, count, spread, height, ignoreFloor, opts)` | per particle: vx, vy, vz = `rg * 0.02` each (three draws first); `x = X + (0.5 - spread) + rd * spread * 2`; `y = Y + rd * height`; `z = Z + (0.5 - spread) + rd * spread * 2`; if `ignoreFloor` is false and the block below the particle position is air, skip the particle (the draws are still made); emit. |
| `spawnSmashAttackParticles(level, pos, data)` | not a block emitter; see 42-7. |

`Mth.nextDouble(rnd, a, b)` returns `a` when `a >= b`, else `rd * (b - a) + a`.

### 2.2 Direction pick

`Direction.getRandom(rnd)` returns one of the six directions uniformly (`Util.getRandom(VALUES, rnd)`, one draw).

---

## 3. `animateTick` of block classes

The probability and count columns are per sampled cell (section 1.2): a block sits in a sampled cell with chance about 1/(2r)^3-shaped; the numbers below are per call. "Hit" = condition true.

### 3.1 Torches and fire-like flames

| Block class (blocks) | Condition | Emission | Notes |
|---|---|---|---|
| `TorchBlock` (torch, soul torch, copper torch) | always | `smoke` then `flameParticle` at `(X+0.5, Y+0.7, Z+0.5)`, velocity 0 | no random draws. `flameParticle`: torch `flame`, soul torch `soul_fire_flame`, copper torch `copper_fire_flame` (constructor argument read in `Blocks`). |
| `WallTorchBlock` (wall variants) | always | `smoke`, then the flame particle, both at `(X+0.5 + 0.27*ox, Y+0.7+0.22, Z+0.5 + 0.27*oz)`, where `(ox, oz)` is the step of the direction opposite the block's `facing` property; velocity 0 | flame types as the standing variant (wall torch `flame`, soul `soul_fire_flame`, copper `copper_fire_flame`). |
| `RedstoneTorchBlock` | `lit` | `dust` with option `DustParticleOptions.REDSTONE` at `(X+0.5 + (rd-0.5)*0.2, Y+0.7 + (rd-0.5)*0.2, Z+0.5 + (rd-0.5)*0.2)` | draws x, y, z. |
| `RedstoneWallTorchBlock` | `lit` | same option at `(X+0.5 + (rd-0.5)*0.2 + 0.27*ox, Y+0.7 + (rd-0.5)*0.2 + 0.22, Z+0.5 + (rd-0.5)*0.2 + 0.27*oz)`, `(ox,oz)` = step of the opposite of `facing` | draws x, y, z. |
| `EndRodBlock` | always evaluated; emits with probability 1/5 | `end_rod` at `base + step(facing) * s`, where for each axis `base = P + 0.55 - rf*0.1` (three draws x, y, z), `s = 0.4f - (rf + rf) * 0.4f` (two draws, the float widened), velocity `(rg*0.005, rg*0.005, rg*0.005)` | the `ri(5) == 0` test is drawn last, after the base and s draws (the artifact computes the geometry first, then tests). |

`DustParticleOptions.REDSTONE` was read from the static initialiser of `DustParticleOptions`: colour int 16711680 (0xFF0000) and scale 1.0. Redstone wire builds its own option per power level (colour from the table in 3.3, scale 1); the lever builds a separate option with the same colour and scale 0.5 (3.3); neither is the REDSTONE constant. The torches, repeater and redstone ore use the REDSTONE constant itself (scale 1).

### 3.2 Fire, campfire, candle, furnace family

| Class | Condition | Emission |
|---|---|---|
| `BaseFireBlock` (fire, soul fire) | (a) with probability 1/24 (`ri(24) == 0`): sound only (fire ambient: volume `1 + rf`, pitch `rf*0.7 + 0.3`). (b) smoke: let `below` be the state under the fire. If `canBurn(below)` or `below.isFaceSturdy(UP)`: emit 3 `large_smoke` at `(X + rd, Y + rd*0.5 + 0.5, Z + rd)`, velocity 0 (draw order x, y, z per particle). Else, for each side whose neighbour `canBurn` (checked in the order west, east, north, south, up): west: 2 `large_smoke` at `(X + rd*0.1f, Y + rd, Z + rd)`; east: `(X+1 - rd*0.1f, Y + rd, Z + rd)`; north: `(X + rd, Y + rd, Z + rd*0.1f)`; south: `(X + rd, Y + rd, Z+1 - rd*0.1f)`; up: `(X + rd, Y+1 - rd*0.1f, Z + rd)`. | `canBurn` is the block's own flammability test (the fire block class). The side loop only runs when the floor test failed. Note: the floor branch and the side branches are exclusive. |
| `CampfireBlock` (campfire, soul campfire) | `lit`. Sound: 1/10 (`ri(10)==0`), volume `0.5 + rf`, pitch `rf*0.7 + 0.6`. Particles only if the block's `spawnParticles` constructor flag is true (campfire: true, fire damage 1; soul campfire: false, fire damage 2; both read from the two registration lambdas, mapped by bootstrap entry) and `ri(5) == 0`: loop `ri(1) + 1` times (the bound is evaluated every iteration; `ri(1)` is always 0, so one iteration): emit `lava` at `(X+0.5, Y+0.5, Z+0.5)` with velocity `(rf/2, 0.00005, rf/2)`. | The smoke columns are a block-entity ticker (4.1). |
| `AbstractCandleBlock` (candle, candle cake) | `lit`. For each offset `o` of `getParticleOffsets(state)` (candles: table below; candle cake: one offset): `p = o + P`; draw `f = rf`; if `f < 0.3f`: emit `smoke` at p velocity 0; and if `f < 0.17f` (nested inside the first test, same draw `f`; both thresholds and the sound formula read from `AbstractCandleBlock.addParticlesAndSound`) also play the candle ambient sound (volume `1 + rf`, pitch `rf*0.7+0.3`) at the particle position plus `(0.5, 0.5, 0.5)` per axis (that is, `P + o + 0.5` on each axis). Always: emit `small_flame` at p, velocity 0. | candle cake offset: `(8,16,8)/16`. |
| `FurnaceBlock` | `lit`. Sound with probability 0.1 (`rd < 0.1`). `facing` axis `a`: `r = rd*0.6 - 0.3` (one draw; only one horizontal axis is free, the axis that is not the facing axis, and `r` is used for that one component only); `x-off = (a == X) ? step(facing).x * 0.52 : r`; `y-off = rd * 6/16`; `z-off = (a == Z) ? step.z * 0.52 : r` (so exactly one of the two takes `r`, the other takes the 0.52 step); emit `smoke` then `flame` at `(X+0.5 + x-off, Y + y-off, Z+0.5 + z-off)`, velocity 0 | draw order: sound test draw, `r`, `y-off`. |
| `BlastFurnaceBlock` | same as furnace but only `smoke` (no flame) and `y-off = rd * 9/16` | sound `blast furnace fire crackle`. |
| `SmokerBlock` | `lit`; sound with probability 0.1; one `smoke` at `(X+0.5, Y+1.1, Z+0.5)` velocity 0 | no randomised offset. |

Candle offsets (candle count `n` -> pixel offsets divided by 16; `x, y, z` of the offset, added to `P`):

| n | offsets (x, y, z in sixteenths) |
|---|---|
| 1 | (8, 8, 8) |
| 2 | (6, 7, 8), (10, 8, 7) |
| 3 | (8, 5, 10), (6, 7, 8), (9, 8, 7) |
| 4 | (7, 5, 9), (10, 7, 9), (6, 7, 6), (9, 8, 6) |

Extinguishing a candle (not an `animateTick`) emits `smoke` at the same offsets with velocity `(0, 0.1f, 0)` (lambda of `extinguish`).

### 3.3 Redstone family

| Class | Condition | Emission |
|---|---|---|
| `RedstoneWireBlock` | `power > 0`. For each horizontal direction `d` (north, east, south, west in `Direction.Plane.HORIZONTAL` order) with connection `c = state.side(d)`: `UP`: two lines: `line(d, UP, -0.5, 0.5)` and `line(DOWN, d, 0, 0.5)`; `SIDE`: `line(DOWN, d, 0, 0.5)`; `NONE`: `line(DOWN, d, 0, 0.3)`. | `line(a, b, from, to)`: `len = to - from`; if `rf >= 0.2f * len`: stop (probability of emitting = `0.2*len`: 0.2, 0.1, 0.06); else `t = from + len * rf2`, where `rf2` is a second, separate `rf` draw made after the probability-test draw (two draws per call that passes the test; one if it fails); position `P + 0.5 + 0.4375f * step(a) + t * step(b)` per axis (computed in float, widened); emit `dust` with option colour `COLORS[power]` and scale 1, velocity 0. |
| wire colour table | `COLORS[p]` for p = 0..15: `f = p / 15`; `r = f*0.6 + (f > 0 ? 0.4 : 0.3)`; `g = clamp(f*f*0.7 - 0.5, 0, 1)`; `b = clamp(f*f*0.6 - 0.7, 0, 1)`; colour = `colorFromFloat(1, r, g, b)` (alpha 1). | power 15 gives (1.0, 0.2, 0.0); power 1 gives about (0.44, 0, 0). The same table is `RedstoneWireBlock.getColorForPower` (also used by the tint source of the item and block colour, see 43). |
| `RepeaterBlock` | `powered`. `facing` f. `(cx, cy, cz) = (X+0.5 + (rd-0.5)*0.2, Y+0.4 + (rd-0.5)*0.2, Z+0.5 + (rd-0.5)*0.2)` (three draws). `s = -5.0f`; if `rb`: `s = (delay*2 - 1)` (delay is the `delay` property, 1..4); `s = s / 16.0f`; offset `(s * step(f).x, 0, s * step(f).z)`. Emit `dust` REDSTONE at `(cx + dx, cy, cz + dz)`. | so the dust sits at the torch-slot row: with `rb` false it is at `-5/16` along facing (the output torch), with `rb` true at `(2*delay-1)/16` (the delay torch). Comparator: no `animateTick` was found (the comparator class does not override it). |
| `RedStoneOreBlock` (redstone ore, deepslate redstone ore) | `lit`. For each of the six directions in `Direction.values()` order: neighbour `n`; if `n` is `isSolidRender` skip; else on axis `a` of that direction: coordinate on `a` = `0.5 + 0.5625 * step[a]`; the two other axes `rf` each (a float widened). Emit `dust` REDSTONE at `P + (cx, cy, cz)`, velocity 0. | one particle per exposed face, so up to 6; draws x, y, z in order, only for axes that are not the face axis. |
| `LeverBlock` | `powered` and `rf < 0.25f`: emit `dust` with option colour 0xFF0000 (16711680) and scale 0.5 at `P + 0.5 + 0.1*step(opposite(facing)) + 0.2*step(opposite(connectedDirection))` per axis, velocity 0. | `facing` and `connectedDirection` derive from the attach face; the formula is from `makeParticle`. |
| `SculkSensorBlock` (also calibrated) | phase `ACTIVE`; direction `d = getRandom`; if `d` is UP or DOWN: stop. Position: for x and z: `P + 0.5 + (step != 0 ? step*0.6 : 0.5 - rd)`; `y = Y + 0.25`; velocity `(0, rf*0.04, 0)`; emit `dust_color_transition` with option `SCULK_TO_REDSTONE` (from sculk blue to redstone red; the option values are data of 42-1 section 3). | draws: direction, x (if free), z (if free), then the `rf` for vy. |
| `LightningRodBlock` | the level is thundering and `ri(200) <= gameTime % 200` and the block's Y equals `heightmap(WORLD_SURFACE, x, z) - 1` | `spawnParticlesAlongAxis(axisOf(facing), level, P, 0.125, electric_spark, UniformInt(1,2))`. |

### 3.4 Nature and fluids as blocks

| Class | Condition | Emission |
|---|---|---|
| `LeavesBlock` (all leaves) | call the base, then if `level.isRainingAt(P.above())` and `ri(15) == 1` and the block below is not (`canOcclude` and top face sturdy): `spawnParticleBelow(dripping_water)`; then the ambient leaves sound player (sound only; data tag `required_for_poplar_leaf_ambience` for poplar) | the draw `ri(15)` is made only when raining. |
| `FallingParticlesLeavesBlock` (subclasses: `TintedParticleLeavesBlock`, `UntintedParticleLeavesBlock`, mangrove) | after the leaves behaviour: if `rf < leafParticleChance` and the block below does not have a full top face (`isFaceFull(collisionShape, UP)` false): spawn the leaf particle with `spawnParticleBelow` | the draw order is `rf` first. Tinted: option `tinted_leaves` colour from `getClientLeafTintColor(state, level, pos)` (the client tint source, see 43). Untinted: the stored option. |
| leaf chances and particles (all values read in this round from the registration lambdas of `Blocks`; the lambda-to-name mapping was resolved through the bootstrap-method table and the registration order: oak, spruce, birch, jungle, acacia, cherry, dark oak, pale oak, mangrove, red, orange, yellow poplar, azalea, flowering azalea) | oak, birch, jungle, acacia, dark oak, mangrove (`MangroveLeavesBlock` was read: it extends `TintedParticleLeavesBlock` and passes its constructor chance straight up; it overrides no `animateTick` and no particle code, only bone meal behaviour, whose particle position (`getParticlePos`) is the cell below the leaves): tinted, chance 0.01f; cherry: `cherry_leaves`, 0.1; pale oak: `pale_oak_leaves`, 0.02; red, orange and yellow poplar: `red_poplar_leaves`, `orange_poplar_leaves`, `yellow_poplar_leaves`, 0.01 each; azalea and flowering azalea: `tinted_leaves` with the fixed colour int -9399763 (0xFF70922D), 0.01f; spruce: no falling particle (plain `LeavesBlock`) | The per-block assignment is confirmed (not inferred): each `BlockItemIds.*_LEAVES` reference is followed by one `invokedynamic` whose bootstrap entry names the lambda holding the constructor call. |
| `MyceliumBlock` | base, then with probability 1/10: `mycelium` at `(X + rd, Y+1.1, Z + rd)` velocity 0 | |
| `SporeBlossomBlock` | always: one `falling_spore_blossom` at `(X + rd, Y + 0.7, Z + rd)`; then 14 tries: `p = (X + nextInt(-10,10), Y - ri(10), Z + nextInt(-10,10))` (`Mth.nextInt` is inclusive both ends: `ri(21) - 10`); if the state at `p` is not a full collision block: `spore_blossom_air` at `(p.x + rd, p.y + rd, p.z + rd)` | |
| `FireflyBushBlock` | `getMaxLocalRawBrightness(P) <= 13` and `rd <= 0.7`: `firefly` at `(X + rd*10 - 5, Y + rd*5, Z + rd*10 - 5)` velocity 0 | the sound branch uses `ri(30) == 0` and the environment attribute `firefly_bush_sounds`. |
| `WitherRoseBlock` | 3 trials; each trial with `rb`: `smoke` at `(X + c.x + rd/5, Y + 0.5 - rd, Z + c.z + rd/5)` where `c` is the centre of the block's shape bounds | the `rb` is drawn first each trial. |
| `FallingBlock` (sand, gravel, concrete powder, ...) | `ri(16) == 0` and the block below is "free" (`FallingBlock.isFree(belowState)`, read: true when the state is air, or is in tag `fire`, or is a liquid, or `canBeReplaced`; the sampling draw `ri(16)` is made first and `isFree` only when it is 0) | `spawnParticleBelow(falling_dust with block option = this state)`. |
| `BrushableBlock` (suspicious sand and gravel) | `ri(16) == 0` and the block below is free | `falling_dust` with this state at `(X + rd, Y - 0.05, Z + rd)` velocity 0 (no helper; same shape). |
| `WetSpongeBlock` | `d = getRandom`; if `d` is UP: stop; if the block can occlude and the neighbour at `d` has a sturdy face towards the block: stop. Else: start `(X, Y, Z)`; DOWN: `y = Y - 0.05`, `x += rd`, `z += rd`; horizontal: `y = Y + rd*0.8`; for X axis: `z += rd`, `x += (EAST ? 1.1 : 0.05)`; for Z axis: `x += rd`, `z += (SOUTH ? 1.1 : 0.05)`. Emit `dripping_water` | |
| `CryingObsidianBlock` | `ri(5) == 0` only; `d = getRandom`; stop if UP; if the block can occlude and the neighbour at `d` is sturdy towards the block: stop. Per axis: `step != 0 ? 0.5 + step*0.6 : rd`. Emit `dripping_obsidian_tear` at `P + that` | the call continues only when `ri(5) == 0` (probability 1/5). |
| `PointedDripstoneBlock` | only a free-hanging stalactite (stalactite, thickness `tip`, not waterlogged: `isFreeHangingStalactite`); `f = rf`; stop if `f > 0.12`. Look up the fluid above (2.3). Keep the info only if `f < 0.02` or the fluid is water or lava; then spawn a drip (2.3). | |
| `NetherPortalBlock` | 4 particles per call: `x = X + rd, y = Y + rd, z = Z + rd`, velocity `((rf-0.5)*0.5)` on each axis (draws x, y, z positions then three velocities); `s = ri(2)*2 - 1`; if the west or east neighbour is a portal block: `z = Z + 0.5 + 0.25*s`, `vz = rf*2*s`; else `x = X + 0.5 + 0.25*s`, `vx = rf*2*s`. Emit `portal`. Sound with probability 1/100. | the loop is four iterations, each with its own `s`. |
| `EndPortalBlock` | always | one `smoke` at `(X + rd, Y + 0.8, Z + rd)` velocity 0 |
| `EndGatewayBlock` | needs the block entity; `n = getParticleAmount()` = the number of faces the gateway renders (`shouldRenderFace` per direction); loop n times: `x = X + rd`, `y = Y + rd`, `z = Z + rd`, velocities `(rd-0.5)*0.5` each (draws in order x, y, z, vx, vy, vz), `s = ri(2)*2 - 1`; if `rb`: `z = Z + 0.5 + 0.25*s`, `vz = rf*2*s`; else `x = X + 0.5 + 0.25*s`, `vx = rf*2*s`. Emit `portal` | |
| `EnderChestBlock` | 3 particles per call: `a = ri(2)*2 - 1`, `b = ri(2)*2 - 1`; `x = X+0.5 + 0.25*a`; `y = Y + rf`; `z = Z+0.5 + 0.25*b`; velocity `(rf*a, (rd-0.5)*0.125, rf*b)`; emit `portal` | |
| `EnchantingTableBlock` | base, then for each offset in `BOOKSHELF_OFFSETS`: `ri(16) == 0` and `isValidBookShelf` (the block at `P+off` is in tag `enchantment_power_provider` and the block at `P + (off.x/2, off.y, off.z/2)` is in tag `enchantment_power_transmitter`): emit `enchant` at `(X+0.5, Y+2, Z+0.5)` with velocity `(off.x + rf - 0.5, off.y - rf - 1, off.z + rf - 0.5)` (the floats widen) | `BOOKSHELF_OFFSETS`: all cells of the box x -2..2, y 0..1, z -2..2 with `|x| == 2` or `|z| == 2` (32 entries). Iteration order, read from `BlockPos.betweenClosed` (the iterator behind `betweenClosedStream`) and the static initialiser: the box is x -2..2, y 0..1, z -2..2 filtered by `|x| == 2 or |z| == 2`; the index runs with x fastest, then y, then z slowest. The first entries are therefore (-2,0,-2), (-1,0,-2), (0,0,-2), (1,0,-2), (2,0,-2), (-2,1,-2), ... and the last is (2,1,2). The offset test draws `ri(16)` once per entry in this order. |
| `RespawnAnchorBlock` | `charge > 0`; sound with 1/100; always one `reverse_portal` at `(X + 0.5 + (0.5 - rd), Y + 1, Z + 0.5 + (0.5 - rd))`, velocity `(0, rf*0.04, 0)` | draws x, z, vy. |
| `BrewingStandBlock` | always | `smoke` at `(X+0.4 + rf*0.2, Y+0.7 + rf*0.3, Z+0.4 + rf*0.2)` |
| `BeehiveBlock` | `honey_level >= 5`: `ri(1) + 1` iterations (always one) of `trySpawnDripParticles`: continue only when the hive has no fluid and the level random float is below 0.3. Then, when the hive shape's max Y is at least 1 and the state is not in tag `impermeable`: if the shape's min Y is above 0, emit `dripping_honey` at `Y + minY - 0.05`; else look at the block below: if its collision max Y is below 1 or it is not a full block, and it has no fluid, emit at `Y - 0.05`. | position by `lerp(level.random.rd, shape.minX+X, shape.maxX+X)` then z. |
| `BubbleColumnBlock` | `drag_down` true: always-visible `current_down` at `(X+0.5, Y+0.8, Z)` velocity 0; sound 1/200. else: always-visible `bubble_column_up` at `(X+0.5, Y, Z+0.5)` velocity `(0, 0.04, 0)` and another at `(X + rf, Y + rf, Z + rf)` velocity `(0, 0.04, 0)`; sound 1/200 | |
| `PotentSulfurBlock` (sulfur) | `state != DRY` and the fluid above is a water source: two always-visible `sulfur_bubbles` at `(X + rf, Y+1 + rf, Z + rf)` (each call draws its own three floats), velocity 0; sound with 1/10 | |
| `DriedGhastBlock` | not waterlogged: sound 1/40 with a tag test; `ri(6) == 0`: `white_smoke` at the block centre, velocity `(0, 0.02, 0)`. waterlogged: sound 1/40; `ri(6) == 0`: `happy_villager` at `(cx + ((rf*2-1)/3), cy + 0.4, cz + ((rf*2-1)/3))` velocity `(0, rf, 0)` | |
| Sound-only blocks | `CreakingHeartBlock` (sound 1/16 when surrounded by logs), `EyeblossomBlock`, `HangingMossBlock` (pale), `SandBlock`, `DryVegetationBlock`, `ShortDryGrassBlock`, `TallDryGrassBlock`: no particle reference in `animateTick` (checked: no `addParticle`, `ParticleUtils` or `ParticleTypes` use). `BellBlock` has no `animateTick` at all (it is not among the 53 classes, 12.10). | |

No other block or fluid overrides `animateTick`: magma block, honey block (its particles are entity-driven, 7.3), ice, snow, TNT, beacon, soul sand, structure void and cauldrons have none. Dripstone and the sculk catalyst work through events (section 6) or tickers.

### 3.5 Pointed dripstone: fluid above and drip spawn (2.3)

`getFluidAbove(level, P, state)`: only for a stalactite (tip direction down). Walk up from `P` through blocks of this same block with the same `tip_direction` (at most 10 steps; the helper allows `11 - 1`), stopping at the first non-dripstone block `root` (the ceiling); if the walk leaves the build height or meets another block first, there is no fluid. The fluid cell is the block above the root (`root.above()`); call its state `s`. If `s` is mud and the environment attribute `water_evaporates` is false at it: fluid = water; otherwise fluid = the fluid type of that cell's fluid state (possibly empty).

Drip spawn at the tip: offset `o = state.getOffset(P)` (the block's random horizontal offset); `x = X + 0.5 + o.x`; `y = Y + 0.3125 - 0.0625` (the tip-down shape starts at 5/16, so `y = Y + 0.25`); `z = Z + 0.5 + o.z`; velocity 0. Particle: fluid empty: the environment attribute `default_dripstone_particle` at the fluid cell (data); lava: `dripping_dripstone_lava`; otherwise `dripping_dripstone_water`.

Probability summary (animateTick): the cell is sampled by 1.2; then the random float `f` must be `<= 0.12`; the entry is kept when `f < 0.02` or the fluid can fill a cauldron (water or lava).

---

## 4. Block-entity client tickers

### 4.1 Campfire (`CampfireBlockEntity.particleTick`, client side)

1. With `rf < 0.11f`: loop `ri(2) + 2` times (the bound is re-drawn each pass; expected passes about 2.5): `makeParticles(level, pos, signalFire, false)`.
2. For each of the `items` slots `i` (the stored food): if the item is not empty and `rf < 0.2f`: `d = Direction.from2DDataValue((i + facing.get2DDataValue()) mod 4)`; position `(X+0.5 - step(d).x * 0.3125 + step(cw(d)).x * 0.3125, Y+0.5, Z+0.5 - step(d).z*0.3125 + step(cw(d)).z * 0.3125)` (`cw` = clockwise); emit `smoke` four times at that position, velocity `(0, 0.0005, 0)`.

`makeParticles(level, pos, signal, extra)`: type = `campfire_signal_smoke` if `signal` else `campfire_cosy_smoke`; always-visible with override-limiter true (the first boolean of the long form): `x = X+0.5 + (rd/3) * (rb ? 1 : -1)`, `y = Y + rd + rd`, `z = Z+0.5 + (rd/3) * (rb ? 1 : -1)`, velocity `(0, 0.07, 0)`; if `extra`: one `smoke` (normal emit) at `(X+0.5 + (rd/4)*sign, Y+0.4, Z+0.5 + (rd/4)*sign)` velocity `(0, 0.005, 0)`. Signal fire is the `signal_fire` blockstate property. `CampfireBlock.douse` (client side, when the fire is put out) calls `makeParticles(..., signal, true)` 20 times. `isSmokeyPos` (the smoke-signal height test: a lit campfire within 5 blocks below through a hay-bale-like column) belongs to the entity-level `smoke` behaviour of 42-3 and is not an emitter.

### 4.2 Trial spawner (`TrialSpawnerState.emitParticles`, per client tick)

Per state (`ominous` selects the soul-fire variant):

| State | Emission rule |
|---|---|
| inactive | none |
| waiting for players, waiting for reward ejection, ejecting reward (`SMALL_FLAMES`) | with `ri(2) == 0`: `p = centre(P) + offsetRandom(0.9)`; emit `small_flame` (normal) or `soul_fire_flame` (ominous) at `p`, velocity 0 |
| active (`FLAMES_AND_SMOKE`) | `p = centre + offsetRandom(1.0)`; emit `smoke` at p; emit `flame` (normal) or `soul_fire_flame` (ominous) at the same p |
| cooldown (`SMOKE_INSIDE_AND_TOP_FACE`) | `p = centre + offsetRandom(0.9)`; with `ri(3) == 0`: `smoke` at p. If `gameTime % 20 == 0`: `q = centre + (0, 0.5, 0)`, `n = level.random.ri(4) + 20`; emit `smoke` n times at `q`, velocity 0 |

`offsetRandom(rnd, k)` of `Vec3`: three draws `(rf - 0.5f) * k`, added to x, y, z in order.

The emission mode of each state was read from the `TrialSpawnerState` constructor arguments (confirmed by a second pass):

| State | Emission mode |
|---|---|
| `INACTIVE` | `NONE` |
| `WAITING_FOR_PLAYERS` | `SMALL_FLAMES` |
| `ACTIVE` | `FLAMES_AND_SMOKE` |
| `WAITING_FOR_REWARD_EJECTION` | `SMALL_FLAMES` |
| `EJECTING_REWARD` | `SMALL_FLAMES` |
| `COOLDOWN` | `SMOKE_INSIDE_AND_TOP_FACE` |

### 4.3 Monster spawner (`BaseSpawner.clientTick`)

Only when a player is near (`isNearPlayer`) and a display entity exists: `x = X + rd`, `y = Y + rd`, `z = Z + rd`; emit `smoke` then `flame` at that point, velocity 0 (once per tick); decrement `spawnDelay` if positive; the spin used for the rotating mob display is not a particle.

### 4.4 Vault (`VaultBlockEntity$Client`)

| Emission | Rule |
|---|---|
| idle | with `rf <= 0.5f`: `p = randomPosInsideCage`; emit `smoke` at p; if the shared data has a display item: also the flame type given (`small_flame` normal, `soul_fire_flame` ominous) at p |
| activation (level event 3015) | the connection particles for connected players in range; then 20 times: `p = randomPosInsideCage`; emit `smoke` then the flame at p |
| deactivation (3016) | 20 times: `p = randomPosCenterOfCage`; velocity `(rg*0.02, rg*0.02, rg*0.02)`; emit the flame particle |
| connection (per connected player within `connectedParticlesRange`) | `k = Mth.nextInt(rnd, 2, 5)` particles; `v = (player.position + (0, height/2, 0)) - keyhole`, jittered by `offsetRandom(1.0)`; emit `vault_connection` at the keyhole position with velocity `v` |

`randomPosInsideCage(P) = P + (nextDouble(0.1, 0.9), nextDouble(0.25, 0.75), nextDouble(0.1, 0.9))`; `randomPosCenterOfCage(P) = P + (nextDouble(0.4,0.6) x3)`; `keyholePos = bottomCenter(P) + (0.5*step(facing).x, 1.75, 0.5*step(facing).z)`.

### 4.5 End gateway, creaking heart, sculk catalyst

End gateway particles are in 3.4. The creaking heart sends server particles (section 9). The sculk catalyst bloom (`CatalystListener.bloom`) was read: it sets `pulse` true, schedules a block tick in 8 ticks, and sends `sculk_soul` through `ServerLevel.sendParticles` with count 2, position `(X + 0.5, Y + 1.15, Z + 0.5)`, offset distances `(0.2, 0, 0.2)` and speed 0 (the packet decoding is section 9; the row also appears in 42-7). The `SculkSpreader` and its `ChargeCursor` contain no particle code at all; the spreader's visible effect is the level event 3006 (section 6).

### 4.6 Potent sulfur and geyser (client tickers)

The `PotentSulfurBlock` is a new block whose block-state property `STATE` has five values, in ordinal order `dry`, `wet`, `dormant`, `erupting`, `continuous`. `PotentSulfurBlock.getTicker` chooses the ticker per state and per side (read from its switch):

| `STATE` | Client ticker | Server tickers (for completeness) |
|---|---|---|
| `dry` | none | none |
| `wet` | noxious gas | nausea effect |
| `dormant` | noxious gas | waiting countdown, then nausea effect |
| `erupting` | geyser plume with the sound `geyser_eruption_active`, then the launch-entity ticker | launch-entity, then waiting countdown |
| `continuous` | geyser plume with the sound `geyser_continuous_active`, then the launch-entity ticker | launch-entity only |

The launch-entity ticker (both sides) moves entities and is not a particle emitter. The geyser plume ticker is parameterised by a sound event; the block entity carries `eruptionTick` (a game time).

| Ticker | Behaviour |
|---|---|
| client noxious gas | every 20 game ticks (`gameTime % 20 == 0`): `src = findNoxiousGasSource(P)`; if found emit `noxious_gas_cloud` at the centre of `src`, velocity 0 |
| client geyser plume | `src = findNoxiousGasSource(P)`; if none, nothing. Else `t = gameTime - eruptionTick`; if `t % 20 == 0`: emit `geyser` (option: integer height `src.Y - P.Y - 1`) at `(src.X + 0.5, src.Y, src.Z + 0.5)`, velocity 0; independently if `t % 40 == 0`: play the ticker's sound (volume 1, pitch 1, blocks source, no distance delay) at `(src.X + 0.5, src.Y + 0.5, src.Z + 0.5)` |

`findNoxiousGasSource(P)` (read): scan cells from `P + 1` up to `Y + 5` inclusive. A cell whose fluid is a water source continues the scan when its block is the water block or is geyser-passable. Otherwise (not a water source, or a water-source cell holding some other non-passable block) the cell is the source when it is air or geyser-passable, else the scan ends with none. Running past `Y + 5` also gives none. "Geyser passable" = air, the water block, or a block with an empty collision shape.

---

## 5. Fluid `animateTick`

| Fluid | Rule |
|---|---|
| water | if the state is a source or falling: with `ri(10) == 0` emit `underwater` at `(X + rd, Y + rd, Z + rd)` velocity 0. Else (flowing, not falling): with `ri(64) == 0` play the ambient water sound (volume `rf*0.25 + 0.75`, pitch `rf + 0.5`). |
| lava | only when the cell above is air and not `isSolidRender`: with `ri(100) == 0`: `lava` at `(X + rd, Y + 1, Z + rd)` velocity 0 and the lava pop sound; then with `ri(200) == 0` the lava ambient sound. |

The generic drip (water `dripping_water`, lava `dripping_lava`) is the 1/10 step of 1.2 with the placement of 1.5.

---

## 6. Block-driven level events (client `LevelEventHandler.levelEvent(type, pos, data)`)

Events are sent by the server (the existing packet "Level Event"). Only particle effects are listed; sounds are documented elsewhere. `LevelEventHandler.levelEvent` dispatches exactly these ids (read from the switch): 1000-1002, 1004, 1009-1011, 1015-1022, 1024-1027, 1029-1035, 1039-1054, 1500-1505, 2000-2004, 2006-2020, 3000-3009, 3011-3021. The ids 2005 and 3010 are not cases of the switch and do nothing. Ids with particles that are not block emitters are assigned to 42-7 in the last rows of the table (2002, 2003, 2006, 2007, 2008, 3000); 3001 is sound only. `globalLevelEvent` (a separate method) handles 1023, 1028 and 1038 with sounds only.

| Event | Block cause | Particles |
|---|---|---|
| 2001 | any block break | the break sound (volume `(v+1)/2`, pitch `p*0.8`) when the state is not air, then `addDestroyBlockEffect(pos, stateById(data))` (section 7.1). Data is the block-state id. |
| 2014 | block destroyed by other cause | `addDestroyBlockEffect(pos, stateById(data))` (no sound) |
| 2019, 2020 | block hit effect | `addBreakingBlockEffects(pos, Direction[clamp(data, 0, 5)], playSound = (type == 2020))`; the crack (section 7.2). Sender: `ServerPlayerGameMode.tick`, see 7.2: one event per server tick while a player is mining a non-air block, sent to all players (no excluded player), data = the ordinal of the mined face |
| 1500 composter | fill | `handleFill(level, pos, data > 0)`: sound; shape height `h = shape.maxY at (0.5, 0.5)` (with a default of 0.5) `+ 0.03125`; 10 times: velocities `rg*0.02` (x, y, z, drawn first); emit `composter` at `(X + 0.1875 + 0.625*rf, Y + h + rf*(1 - h), Z + 0.1875 + 0.625*rf)` |
| 1501 | lava fire extinguish | sound; 8 `large_smoke` at `(X + rd, Y + 1.2, Z + rd)` velocity 0 |
| 1502 | redstone torch burnout | sound; 5 `smoke` at `(X + rd*0.6 + 0.2, Y + rd*0.6 + 0.2, Z + rd*0.6 + 0.2)` |
| 1503 | end portal frame filled | sound; 16 `smoke` at `(X + (5 + rd*6)/16, Y + 0.8125, Z + (5 + rd*6)/16)` |
| 1505 | bone meal | `BoneMealItem.addGrowthParticles(level, pos, data)` (below), sound |
| 2000 / 2010 | dispenser (smoke / white smoke) | `shootParticles(directionData, pos, rnd, type)`: 10 times: `s = rd*0.2 + 0.01`; position per axis a: `P[a] + step[a]*0.6 + 0.5 + step[a]*0.01` plus, for the two other axes, `(rd - 0.5) * step[other axis pairing] * 0.5` (x uses `step.z`, y uses `step.y`, z uses `step.x`); velocity `step[a]*s + rg*0.01`; the particle type is `smoke` (2000) or `white_smoke` (2010) |
| 2004 | spawner | 20 times: `p = P + 0.5 + ((rd - 0.5)*2)` per axis; emit `smoke` then `flame` |
| 2009 | water evaporates (nether) | 8 `cloud` at `(X + rd, Y + 1.2, Z + rd)` |
| 2011 | bone meal in water (happy villager) | `spawnParticleInBlock(level, pos, data, happy_villager)` |
| 2012 | | same, `happy_villager`, count data |
| 2013 | | smash attack particles: 42-7 |
| 3002 | lightning rod / copper | `axis = data`: if valid: `spawnParticlesAlongAxis(axis, level, pos, 0.125, electric_spark, UniformInt(10, 19))`; else `spawnParticlesOnBlockFaces(electric_spark, UniformInt(3, 5))` |
| 3003 / 3004 / 3005 | wax on / wax off / scrape | `spawnParticlesOnBlockFaces(wax_on / wax_off / scrape, UniformInt(3, 5))` |
| 3006 | sculk charge | data bits: `charge = data >> 6`, `faceMask = data & 63`. If `charge > 0`: with `rf < 0.3 + charge*0.1` play the charge sound; then if the mask is 0: for each of the six directions emit `sculk_charge` particles (option roll `pi` when the direction is DOWN, else 0) with count `UniformInt(0, charge)`, offset 0.57 (Y axis 0.65), via `spawnParticlesOnBlockFace`; else for each face in the mask: roll `pi` for UP else 0, offset 0.35. Velocity supplier: three `nextDouble(-0.005, 0.005)`. If `charge <= 0` (a pop): `full = state.isCollisionShapeFullBlock`; `n = full ? 40 : 20`; `spread = full ? 0.45 : 0.25`; n times: `v = (2*rf - 1)` per axis; emit `sculk_charge_pop` at `P + 0.5 + v*spread`, velocity `v * 0.07` |
| 3007 | shrieker | 10 `shriek` particles with delay option `i*5` (i = 0..9) at `(X + 0.5, Y + 0.5, Z + 0.5)` (the Y is `Y + TOP_Y`, TOP_Y = 0.5 from the collision shape `column(16, 0, 8)`), velocity 0; shriek sound unless waterlogged |
| 3008 | brushing completes | `addDestroyBlockEffect(pos, stateById(data))` and the completion sound |
| 3009 | egg crack | `spawnParticlesOnBlockFaces(egg_crack, UniformInt(3, 6))` |
| 3011 | trial spawner: flame data | `addSpawnParticles(level, pos, rnd, flame by data)`: 20 times: `p = centre + (rd-0.5)*2` per axis; emit `smoke` then the flame at p |
| 3012 | mob spawn | the same spawn particles and the sound |
| 3013 | detect player | `addDetectPlayerParticles(level, pos, rnd, data, trial_spawner_detected_player)`: `30 + min(data, 10)*5` times: `dx = (2*rf - 1)*0.65`, `dz = (2*rf - 1)*0.65`; emit at `(X + 0.5 + dx, Y + 0.1 + rf*0.8, Z + 0.5 + dz)` velocity 0 |
| 3019 | detect player ominous | same with `trial_spawner_detected_player_ominous` |
| 3020 | ominous activate | detect particles with data 0 (ominous option), then `addBecomeOminousParticles`: 20 times: `p = centre + (rd - 0.5)*2`, velocity `rg*0.02` each; emit `trial_omen` then `soul_fire_flame` at p |
| 3014 | eject item | `addEjectItemParticles`: 20 times: `p = P + 0.4 + rd*0.2` per axis; velocity `rg*0.02` per axis; emit `small_flame` with vz scaled by 0.25, then `smoke` with full vz |
| 3017 | eject item (no sound) | same particles |
| 3018 | cobweb placed | 10 `poof` at `(X + rd, Y + rd, Z + rd)` with velocity `rg*0.02` per axis |
| 3015 / 3016 | vault activate / deactivate | section 4.4; data 0 normal, other ominous |
| 3021 | trial spawner spawn item | spawn particles with the flame by data |
| 2015..2018 | enderman teleport markers | 42-7 |
| 2002, 2007 | splash and instant splash potion | 42-7 section 8.4 (not block emitters) |
| 2003 | eye of ender breaks | 42-7 section 8 |
| 2006, 2008 | dragon fireball breath; explosion at block | 42-7 (event table) |
| 3000 | end gateway spawn | 42-7 (one forced always-visible `explosion_emitter` at the block centre) |
| 3001 | dragon growl | sound only, no particles |
| 1504 | pointed dripstone drip | `PointedDripstoneBlock.spawnDripParticle(level, pos, state)` (3.5) |

`BoneMealItem.addGrowthParticles(level, pos, count)`: let `block = state.block`. If it is a bone-meal-able block: `pp = block.getParticlePos(pos)`; a neighbour spreader (grass, moss) type calls `spawnParticles(level, pp, count*3, spread 3.0, height 1.0, ignoreFloor false, happy_villager)`; a grower (crop, sapling) type calls `spawnParticleInBlock(level, pp, count, happy_villager)`. Otherwise, if the block is water: `spawnParticles(level, pos, count*3, 3.0, 1.0, false, happy_villager)`.

The three-draw velocity of the faces helper at 2.1 gives wax, scrape and egg particles their velocities; the particle types themselves belong to 42-4 and 42-5.

---

## 7. Block break, hit and crack

### 7.1 Destroy effect (`ClientLevel.addDestroyBlockEffect`)

Condition: the state is not air and `shouldSpawnTerrainParticles()` is true. The shape used is the block's outline shape (`getShape(level, pos)`, not the collision shape). The particles are added straight to the engine (`ParticleEngine.add`), with no distance, status or limiter test (42-1 5.4 limit group still applies: the terrain group limit).

For every box `(minX, minY, minZ, maxX, maxY, maxZ)` of the shape (the shape's boxes in its own order):

1. `sx = min(1, maxX - minX)`, `sy = min(1, maxY - minY)`, `sz = min(1, maxZ - minZ)`.
2. `nx = max(2, ceil(sx / 0.25))`, `ny = max(2, ceil(sy / 0.25))`, `nz = max(2, ceil(sz / 0.25))`.
3. For `i` in 0..nx-1, `j` in 0..ny-1, `k` in 0..nz-1 (i outermost, k innermost): `fx = (i + 0.5)/nx`, `fy = (j + 0.5)/ny`, `fz = (k + 0.5)/nz`; position `P + (fx*sx + minX, fy*sy + minY, fz*sz + minZ)`; initial velocity `(fx - 0.5, fy - 0.5, fz - 0.5)`; add `TerrainParticle(level, pos..., velocity..., state, P)` (section 7.3).

A full block therefore gives `4*4*4 = 64` particles, a half-height slab `4*2*4 = 32`, a block with a 0.125 by 0.625 by 0.125 box `2*3*2 = 12` (the torch box is given as an example only; its extents are inferred).

### 7.2 Crack (`ClientLevel.addBreakingBlockEffects`, `addBreakingParticles`)

`addBreakingBlockEffects(pos, face, playSound)`: stop if the state is air. If `playSound`: play the block hit sound at `(volume+1)/8` volume and `pitch*0.5`. If the state's render shape is not invisible and `shouldSpawnTerrainParticles()`: `addBreakingParticles(pos, face, state)`.

`addBreakingParticles`: `b = state.shape.bounds()` (outline). Positions: `x = X + rd*((b.maxX - b.minX) - 0.2f) + 0.1f + b.minX`, `y` likewise with Y, `z` likewise with Z (draw order x, y, z; the constants are the float 0.2 and 0.1). Then override one coordinate by the face: DOWN: `y = Y + b.minY - 0.1f`; UP: `y = Y + b.maxY + 0.1f`; NORTH: `z = Z + b.minZ - 0.1f`; SOUTH: `z = Z + b.maxZ + 0.1f`; WEST: `x = X + b.minX - 0.1f`; EAST: `x = X + b.maxX + 0.1f`. One `TerrainParticle(level, x, y, z, 0, 0, 0, state, P)` is created, then `setPower(0.2f)` (velocity `v = v*0.2` on x and z, and `y = (y - 0.1f)*0.2f + 0.1f`) and `scale(0.6f)` (size `0.2f*0.6f`), and added to the engine. So one crack particle per call.

Callers: `MultiPlayerGameMode.startDestroyBlock` calls `addBreakingBlockEffects(destroyPos, destroyDirection, true)` when the start-destroy action is sent; the level events 2019 and 2020 call it with the direction in the event data. A per-tick crack while the attack key is held does exist, and it is server driven (read from `ServerPlayerGameMode.tick`, the only class in the server and level packages that references the ids 2019 and 2020). Each server tick, while the player is in the mining state and the mined block is not air: `n = gameTicks - destroyProgressStart`; the progress is advanced; then `levelEvent(null player, type, destroyPos, destroyDirection.ordinal())` with `type = 2020` when `n % 4 == 0` and `2019` otherwise. So every tick produces one crack particle on every client in range, and every fourth tick (starting at the tick the progress counter is 0) also plays the hit sound (volume `(v+1)/8`, pitch `p*0.5`). When the block has become air the progress is cleared (no event). No event is sent while the delayed-destroy state is active. The local client's own `startDestroyBlock` call (above) adds one more crack, with sound, at the moment the dig starts.

### 7.3 `TerrainParticle` (summary for emitters; full behaviour in 42-5)

Base colour 0.6 per channel; gravity 1.0; the colour is multiplied by the block's tint source of tint index 0 as a terrain particle colour when the block has one (`colorAsTerrainParticle`, see 43); the sprite is the block's particle sprite (08 `particle` texture slot). The engine's behaviour of the base `Particle` constructor on the passed velocity is in 42-1 4.1.

---

## 8. Entity-on-block particles

### 8.1 Sprint dust (client, every entity tick in `Entity.baseTick`)

Condition `canSpawnSprintParticle()`: sprinting, not in water, not spectator, not crouching, not in lava, alive. `bp = getOnPosLegacy()`, `st = state(bp)`; skip if `st.renderShape` is invisible. `v = deltaMovement`; `x = entity.x + (rd - 0.5) * width`, `z = entity.z + (rd - 0.5) * width`; if `blockPosition.x != bp.x`: clamp `x` to `[bp.x, bp.x + 1]`; likewise z. Emit `block` with option `st` at `(x, entity.y + 0.1, z)` with velocity `(v.x * -4, 1.5, v.z * -4)`. One particle per tick.

### 8.2 Landing (server, `LivingEntity.checkFallDamage`, sent through the Level Particles packet)

On the server, when the entity lands on a non-air block with `fallDistance > 0`: `power = max(0, floor(fallDistance + 1e-6 - safeFallDistanceAttribute))`; if `power > 0`: position `(x, y, z)` of the entity, but if the supporting block position differs horizontally from the entity's block position: `dx = x - (bx + 0.5)`, `dz = z - (bz + 0.5)`, `m = max(|dx|, |dz|)`, `x = bx + 0.5 + (dx/m)*0.5`, `z = bz + 0.5 + (dz/m)*0.5` (a point on the supporting block's edge). `amount = min(0.2 + power/15, 2.5)`; `count = (int)(150 * amount)`; `sendParticles(block with the landed state, x, y, z, count, 0, 0, 0, speed 0.15)`. In packet terms: count > 0, distances 0, max speeds 0.15, randomisation DEFAULT, so the client draws the offsets as `rg * 0` (zero) and the velocities as `rg * 0.15` per axis (section 9).

### 8.3 Honey block

`HoneyBlock.showSlideParticles(entity)`: 5 `block` particles with option the honey block state at the entity position `(x, y, z)`, velocity 0; `showJumpParticles`: 10 of them. Client side only. The slide effect is signalled by entity event 53, sent by the server with probability 1/5 per slide tick for living entities, minecarts, TNT and boats; the jump particles are called from the jump code.

### 8.4 Powder snow

Server, while a living entity is inside powder snow and moving horizontally: with `rb`, `sendParticles(snowflake, entity.x, P.y + 1, entity.z, count 1, dist 0,0,0, velocity `(randomBetween(-1, 1) * 0.083333336, 0.05, randomBetween(-1, 1) * 0.083333336)`, randomisation ALTERNATIVE)`.

### 8.5 Decorated pot

Server, when an item is inserted: `sendParticles(dust_plume, X + 0.5, Y + 1.2, Z + 0.5, count 7, dist 0, speed 0)`.

---

## 9. Server-sourced particle semantics (how block-driven `sendParticles` arrives)

The client `handleParticleEvent` turns a packet into particles (05a 0x30; fields named there):

| Condition | Result |
|---|---|
| `count == 0` | one particle at `(x, y, z)` with velocity `(xMaxSpeed * xDist, yMaxSpeed * yDist, zMaxSpeed * zDist)` |
| `count > 0`, randomisation ALTERNATIVE or ALTERNATIVE_WITH_SPEED | `count` particles; offset `(rd * xDist, rd * yDist, rd * zDist)` (the draws in x, y, z order); velocity `(xMaxSpeed, yMaxSpeed, zMaxSpeed)`, each multiplied by an extra `rd` for ALTERNATIVE_WITH_SPEED |
| `count > 0`, DEFAULT | `count` particles; offset `(rg*xDist, rg*yDist, rg*zDist)`; velocity `(rg*xMaxSpeed, rg*yMaxSpeed, rg*zMaxSpeed)` (six draws) |

Each particle goes through `Level.addParticle(options, overrideLimiter, alwaysShow, ...)` (42-1 7.1) and if one is refused (exception), the rest are skipped. The block-driven server emissions: landing (8.2), snowflake (8.4), dust plume (8.5), creaking heart (a `trail` particle with the heart colour, override and always-show true: position random inside the protector's bounding box and inside the heart cell; colours 0x5F5F5F... closed `6250335`, open `16545810`; duration `ri(40) + 10`), eyeblossom transform (`trail`), sculk catalyst bloom (4.5).

---

## 10. Per-block summary

| Particle | Blocks that emit it |
|---|---|
| `smoke` | torches, wall torches, furnace, smoker, blast furnace, brewing stand, end portal, wither rose, campfire food, candle (30%), trial spawner states, spawner, vault, redstone torch burnout, end-portal frame |
| `flame` | furnace, spawner, trial spawner active (normal) |
| `soul_fire_flame` | soul torch, ominous trial spawner and vault |
| `copper_fire_flame` | copper torch |
| `small_flame` | candle, trial spawner, vault |
| `large_smoke` | fire, soul fire, lava extinguish |
| `lava` | lava fluid pop, campfire ember |
| `dust` | redstone wire, redstone torches, repeater, redstone ore, lever |
| `dripping_water` | wet sponge, leaves while raining, water drips from fluid cells |
| `dripping_lava` | lava fluid drips |
| `dripping_honey` | beehive with `honey_level >= 5` |
| `dripping_obsidian_tear` | crying obsidian |
| `dripping_dripstone_water`, `dripping_dripstone_lava` | pointed dripstone |
| `falling_dust` | sand and gravel family, brushable blocks |
| `portal` | nether portal, end gateway, ender chest |
| `reverse_portal` | respawn anchor |
| `enchant` | enchanting table |
| `mycelium` | mycelium |
| `falling_spore_blossom`, `spore_blossom_air` | spore blossom |
| `firefly` | firefly bush |
| `end_rod` | end rod |
| `electric_spark` | lightning rod, copper events |
| `current_down`, `bubble_column_up` | bubble column |
| `sculk_charge`, `sculk_charge_pop`, `shriek` | sculk events |
| `dust_color_transition` | sculk sensor (active) |
| `white_smoke`, `happy_villager` | dried ghast |
| `sulfur_bubbles`, `noxious_gas_cloud`, `geyser` | sulfur, geyser |
| `campfire_cosy_smoke`, `campfire_signal_smoke` | campfire |
| `underwater` | water |
| `block` | sprint, landing, honey; `block_marker`: barrier and light; `dust_pillar`: smash (42-7) |

---

## 11. Worked examples

1. Torch at (10, 64, 5): every sample hits it: `smoke` and `flame` at (10.5, 64.7, 5.5), velocity 0. A wall torch at the same cell with `facing = east`: opposite is west, step (-1, 0); position (10.5 - 0.27, 64.92, 5.5) = (10.23, 64.92, 5.5).
2. Redstone wire power 15 with a connection `SIDE` to the north: `line(DOWN, north, 0, 0.5)`: emitted with probability `0.2*0.5 = 0.1`; if `rf = 0.3` (`< 0.1`? no) nothing; if `rf = 0.05` it emits: `t = 0 + 0.5*rf2` (say `rf2 = 0.5`: `t = 0.25`); position per axis: `0.5 + 0.4375*step(DOWN) + t*step(north)`: x 0.5, y `0.5 - 0.4375 = 0.0625`, z `0.5 - 0.25 = 0.25`; colour (1.0, 0.2, 0.0).
3. Furnace facing east (axis X) at (0,64,0): `x-off = 1*0.52 = 0.52`; `z-off = r = rd*0.6 - 0.3`, e.g. `rd = 0.5` gives 0; `y-off = rd*6/16`, e.g. `rd = 0.5` gives 0.1875; emit `smoke` and `flame` at (1.02, 64.1875, 0.5). Sound: with 10% a crackle.
4. Break a stone block: 64 particles; centre cell (i=1, j=1, k=1 of 4): `f = 0.375` gives position `P + 0.375`, velocity `(-0.125, -0.125, -0.125)`.
5. Landing from a 10 block fall (safe distance 3: the default of the `safe_fall_distance` attribute, a ranged attribute with default 3.0, minimum -1024, maximum 1024, read in `Attributes`): `power = floor(10 + 1e-6 - 3) = 7`; `amount = min(0.2 + 7/15, 2.5) = 0.6667`; `count = (int)(150*0.6667) = 100`; one packet, speed 0.15.
6. Candle cake lit at (0,0,0): offset (0.5, 1.0, 0.5); each sample: `small_flame` always; with `f = 0.1` also `smoke` and the sound.
7. Wire colour: power 1: `f = 0.0667`, `r = 0.04 + 0.4 = 0.44`, `g = clamp(0.0031 - 0.5) = 0`, `b = 0`.

---

## 12. Validation

1. Sampling: 667 iterations at radius 16 and 667 at 32 per tick; each coordinate is a difference of two `ri(r)`, so values lie in `[-(r-1), r-1]` around the player and 0 is the most likely.
2. A flowing-water cell never emits `underwater`; a source or falling cell never plays the ambient sound.
3. A lit furnace in 1000 samples of its own cell emits about 1000 smoke and 1000 flame particles; about 100 sounds.
4. The destroy grid: a full cube 64, a slab 32; the sum of fractions: velocity components are in `[-0.375, 0.375]` (`(i+0.5)/4 - 0.5`).
5. Wire: power 0 emits nothing; each connection line emits at most one particle per call.
6. Repeater: `delay` 1..4 gives `s` in `{1, 3, 5, 7}/16` or `-5/16`.
7. Landing: no packet is sent when `power <= 0`.
8. Leaf rules: spruce leaves never emit falling particles; cherry emits ten times as often as oak.
9. Particles pass the limiter tests of 42-1 7.1; the crack and destroy particles bypass them.
10. Cross-check (counted in this round by scanning every class of the jar for the constant): 53 classes mention `animateTick`: `Minecraft`, `ClientLevel`, `Block`, `Fluid`, `FluidState`, 46 block classes other than `Block`, and the two fluid classes `LavaFluid` and `WaterFluid`. Every block and fluid class with particle code is in section 3 or 5; the sound-only ones are listed in 3.4 (the seven listed there were re-read: none references a particle).

---

## Open questions

1. Resolved in this round: the crack events 2019 and 2020 are sent by `ServerPlayerGameMode.tick` (7.2). Not read: the range within which `ServerLevel.levelEvent` with no excluded player reaches clients (it is the same Level Event packet, 05a); no other classes were searched for senders of these ids.
2. The data rows of the `ambient_particles` attribute (which environments carry it and with which probabilities) are data for the extraction tool (42-1 section 9); the engine rule (`AmbientParticle.canSpawn`, `rf <= probability`) was read and is in 1.3.
3. Resolved in this round: the iteration order of the enchanting-table offsets (3.4).
4. Potent sulfur: the state-to-ticker binding is resolved (4.6). Not read: the exact semantics of `GeyserParticleOptions` height in the particle's own rendering (42-1 and the per-type parts); the launch-entity, waiting-countdown and nausea tickers (server behaviour, not particles).
5. Resolved in this round: the registration-name mapping for the leaf particles and the campfire flag (read through the bootstrap-method table of `Blocks`); the leaf chances, azalea colour and candle thresholds are read values. Sections 6 to 9 were spot-checked against the artifact (the dispatch id list of `levelEvent`, event counts and positions of 1501, 1502, 1503, 2009 and 3018) and matched; the remaining rows of sections 6 to 9 were not re-read in this round and carry the earlier reader's reading.
6. Block entities read in this pass and assigned: `BellBlockEntity` and `ConduitBlockEntity` particle emission is specified in 42-7 sections 9.4 and 9.3; `BeaconBlockEntity` contains no particle code (only effect application); `ComparatorBlock` and `DiodeBlock` have no `animateTick` and no particle reference, so the comparator has no torch-slot particles (confirmed absent). `SculkCatalystBlockEntity$CatalystListener.bloom` is in 4.5; `SculkSpreader` has none.
