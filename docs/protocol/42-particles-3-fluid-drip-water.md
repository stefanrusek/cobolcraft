# 42. Particles, part 3: fluid drips, bubbles, water, ink and their emitters

| | |
|---|---|
| Covers | The per-type behaviour of 30 scope particle types (the `glow` type is a 31st, outside the scope list, covered by its class `GlowParticle` and the `GlowSquid` emitter 9.9): the drip family (`dripping_*`, `falling_*`, `landing_*` for lava, water, honey, obsidian tear, dripstone lava and dripstone water, plus `falling_nectar` and `falling_spore_blossom`), the bubble family (`bubble`, `bubble_pop`, `bubble_column_up`, `current_down`, `sulfur_bubbles`), the water family (`underwater`, `splash`, `rain`, `fishing`), `dolphin`, `nautilus`, `squid_ink`, `glow_squid_ink`, and the class `GlowParticle` (registered for the type `glow`). For every type: the registry id, the provider that builds it, constructor draws, per-tick order, state transitions, spawned follow-up particles and sounds, colour, size, light, removal. The emitters of these particles: the client random-tick scan, fluid and block `animateTick` methods, the weather scan, the bee, dolphin, glow squid and conduit ticks, and the server-sent particles of the squid and the fishing hook. Four worked examples and a validation section. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `DripParticle` and all nested classes, `BubbleParticle`, `BubblePopParticle`, `BubbleColumnUpParticle`, `WaterCurrentDownParticle`, `WaterDropParticle`, `SplashParticle`, `WakeParticle`, `SquidInkParticle`, `SimpleAnimatedParticle`, `GlowParticle`, `SulfurBubbleParticle`, `SuspendedParticle`, `SuspendedTownParticle`, `FlyTowardsPositionParticle`, `Particle`, `SingleQuadParticle`, `Particle$LifetimeAlpha`, `ParticleResources` (provider registration and `MutableSpriteSet`), `ParticleTypes`, `ClientLevel` (`animateTick`, `doAnimateTick`, drip and weather methods, `calculateParticleLevel`, `doAddParticle`), `ClientPacketListener.handleParticleEvent`, `Minecraft.tick`, `ParticleUtils`, the block classes `BubbleColumnBlock`, `LeavesBlock`, `WetSpongeBlock`, `BeehiveBlock`, `SporeBlossomBlock`, `CryingObsidianBlock`, `PointedDripstoneBlock`, `SpeleothemBlock`, `PotentSulfurBlock`, the fluid classes `WaterFluid`, `LavaFluid`, `Fluid`, the entities `Bee`, `Dolphin`, `Squid`, `FishingHook`, and `ConduitBlockEntity`. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-15). Particle textures and the per-type sprite lists live in the vanilla resource pack (data, extracted by the tool, 22) and are not tabulated; this document specifies the engines that use them. Sibling documents: part 1 (shared particle model, `ParticleEngine`, render layers), part 2 (effects, fire, smoke, magic), part 4 (block, item, dust, ambient), part 5 (special, sculk, trial, wind, sulfur), part 6 (block emitters), part 7 (other emitters). They are cross-referenced as "part N" and their content is not repeated beyond the minimum needed here. |

Conventions: "tick" is one client tick (20 per second). Every particle ticks once per client tick, in creation order (the engine's order is part 1). `f32` marks a value the artifact computes in single precision; the doc gives the decimal value the artifact stores, for example `0.0625`. `r()` is one `nextFloat()` of the particle's own random source (`RandomSource.create()`, unseeded and per particle, so particle motion is not reproducible; the draws are listed so that the distributions are). `rd()` is one `nextDouble()`. "Level random" is the client level's own random source. A velocity is `(xd, yd, zd)` in blocks per tick. "Fluid check" always means `ClientLevel.getFluidState(BlockPos.containing(x, y, z))`.

## 1. What this document needs from the shared model (restated, read)

These facts come from `Particle` and `SingleQuadParticle` and are restated so that the sections below are self-contained. Part 1 is the owner of the full model.

| Fact | Value |
|---|---|
| Field defaults of `Particle` | `hasPhysics` true, `bbWidth` 0.6, `bbHeight` 1.8 then immediately `setSize(0.2, 0.2)`, `friction` 0.98, `gravity` 0, `speedUpWhenYMotionIsBlocked` false, `onGround` false, velocity `(0, 0, 0)` |
| 4-argument constructor `(level, x, y, z)` | `setPos`, previous position equals position, `lifetime = (int)(4.0f / (r() * 0.9f + 0.1f))` (f32; range 4 to 40, the single draw is the first draw of every particle) |
| 7-argument constructor `(level, x, y, z, xa, ya, za)` | the 4-argument constructor, then `xd = xa + (r() * 2 - 1) * 0.4`, `yd = ya + (r() * 2 - 1) * 0.4`, `zd = za + (r() * 2 - 1) * 0.4` (draw order x, y, z), then `f = (r() + r() + 1.0f) * 0.15f`, `n = sqrt(xd^2 + yd^2 + zd^2)`, `xd = xd / n * f * 0.4`, `yd = yd / n * f * 0.4 + 0.1`, `zd = zd / n * f * 0.4` (the constants 0.4 and 0.1 are the doubles of the f32 values 0.4 and 0.1) |
| `SingleQuadParticle` 5-argument constructor | colour `(1, 1, 1)`, alpha 1, then `quadSize = 0.1f * (r() * 0.5f + 0.5f) * 2.0f` (one draw, after the lifetime draw). The 8-argument form (with velocity) calls the 7-argument `Particle` constructor first, then draws `quadSize` the same way |
| `setSize(w, h)` | changes only the bounding box (width, height), not the drawn size, which is `quadSize` (part 1) |
| Base `tick` | previous position := position; `age++`; if `age >= lifetime` remove and stop; `yd -= 0.04 * gravity`; `move(xd, yd, zd)`; if `speedUpWhenYMotionIsBlocked` and `y == yo` then `xd, zd *= 1.1`; `xd, yd, zd *= friction`; if `onGround` then `xd, zd *= 0.7` (the double 0.699999988079071) |
| `move(dx, dy, dz)` | does nothing once `stoppedByCollision`. With `hasPhysics`, a non-zero move and `dx^2 + dy^2 + dz^2 < 100.0`, the movement is clipped by the collision shapes of the level (no entities, `Entity.collideBoundingBox`). The box is translated and the position taken from the box (x and z from the box centre, y from the box minimum). `stoppedByCollision` becomes true when the requested `|dy|` was `>= 1e-5` and the resulting `|dy|` is `< 1e-5`. `onGround = (requested dy != resulting dy) and requested dy < 0`. If the resulting `dx` differs from the requested one then `xd = 0`; the same for `z`. `yd` is never zeroed by `move` |
| Light of a particle | `getLightCoords`: the packed light of the block containing the particle (12 section 1.4 packing), or 15728640 (sky 15, block 0) when the chunk is not loaded. Overrides are stated per type |
| `SpriteSet.get(random)` | picks `sprites[random.nextInt(count)]` using the random source the provider was given (the engine's own, part 1). `first()` is `sprites[0]`. `get(age, lifetime)` is `sprites[(age * (count - 1)) / lifetime]` with integer arithmetic. `setSpriteFromAge(set)` does `get(age, lifetime)` unless removed |
| `Particle.LifetimeAlpha.ALWAYS_OPAQUE` | start alpha 1; `isOpaque` is true when both start and end alpha are `>= 1` |

## 2. Registry, providers and render layers

The ids are those of the `particle_type` registry (46 section 5.1). The provider is registered in `ParticleResources.registerProviders` (the type's sprite set comes from the data file `particles/<name>.json`, 22). "Layer" is `getLayer()`; the layer semantics are part 1. The override-limiter flag (the second argument of `ParticleTypes.register`, read) is true for exactly three rows of this table, `squid_ink`, `glow_squid_ink` and `glow` (in `ParticleTypes` the registrations run glow_squid_ink true, glow true, wax_on true, and so on), and false for the other 28 of the 31 rows; the effect of the flag is `ClientLevel.addParticle` (part 1).

**Frame counts** (read: the number of `textures` entries of `assets/minecraft/particles/<name>.json` in the artifact). They fix the animation indices through `get(age, lifetime) = sprites[(age * (n - 1)) / lifetime]`.

| Frames `n` | Types |
|---|---|
| 8 | `squid_ink`, `glow_squid_ink` (textures `generic_7` down to `generic_0`, in that order) |
| 5 | `bubble_pop` |
| 4 | `fishing`, `rain`, `splash` (all three list `splash_0` to `splash_3`) |
| 1 | the other 24 table types (`bubble`, `sulfur_bubbles`, every `dripping_*`, `falling_*` and `landing_*`, `underwater`, `current_down`, `bubble_column_up`, `nautilus`, `dolphin`) and `glow` |

Consequences: `fishing` shows `(i % 4) * 3 / 4`, that is frames 0, 0, 1, 2 for `i % 4 = 0..3`, and never frame 3; `bubble_pop` (n = 5, lifetime 4) shows frames 0, 1, 2, 3 on ticks 0 to 3 and never frame 4 (age 4 removes it first); `squid_ink` and `glow_squid_ink` show `(age * 7) / lifetime`. With `n = 1` every `get(random)` still consumes one `nextInt(1)` draw (Open question 1).

| Type | id | Provider, which builds | Sprite selection | Layer | Per-type section |
|---|---|---|---|---|---|
| `bubble` | 3 | `BubbleParticle$Provider`, `BubbleParticle` | `get(random)` | OPAQUE | 5.1 |
| `sulfur_bubbles` | 4 | `SulfurBubbleParticle$Provider`, `SulfurBubbleParticle` | `get(random)` | OPAQUE | 6.4 |
| `dripping_lava` | 16 | `DripParticle$LavaHangProvider`, `CoolingDripHangParticle` | `get(random)` | OPAQUE | 3.3 |
| `falling_lava` | 17 | `DripParticle$LavaFallProvider`, `FallAndLandParticle` | `get(random)` | OPAQUE | 3.4 |
| `landing_lava` | 18 | `DripParticle$LavaLandProvider`, `DripLandParticle` | `get(random)` | OPAQUE | 3.5 |
| `dripping_water` | 19 | `DripParticle$WaterHangProvider`, `DripHangParticle` | `get(random)` | OPAQUE | 3.3 |
| `falling_water` | 20 | `DripParticle$WaterFallProvider`, `FallAndLandParticle` | `get(random)` | OPAQUE | 3.4 |
| `fishing` | 38 | `WakeParticle$Provider`, `WakeParticle` | `first()` then `get(i % 4, 4)` each tick | OPAQUE | 5.4 |
| `rain` | 71 | `WaterDropParticle$Provider`, `WaterDropParticle` | `get(random)` | OPAQUE | 5.3 |
| `squid_ink` | 76 | `SquidInkParticle$Provider`, `SquidInkParticle` | `first()` then `get(age, lifetime)` | TRANSLUCENT | 7 |
| `underwater` | 79 | `SuspendedParticle$UnderwaterProvider`, `SuspendedParticle` | `get(random)` | OPAQUE | 6.1 |
| `splash` | 80 | `SplashParticle$Provider`, `SplashParticle` | `get(random)` | OPAQUE | 5.3 |
| `bubble_pop` | 82 | `BubblePopParticle$Provider`, `BubblePopParticle` | `first()` then `get(age, lifetime)` | OPAQUE | 5.2 |
| `current_down` | 83 | `WaterCurrentDownParticle$Provider`, `WaterCurrentDownParticle` | `get(random)` | OPAQUE | 5.6 |
| `bubble_column_up` | 84 | `BubbleColumnUpParticle$Provider`, `BubbleColumnUpParticle` | `get(random)` | OPAQUE | 5.5 |
| `nautilus` | 85 | `FlyTowardsPositionParticle$NautilusProvider`, `FlyTowardsPositionParticle` | `get(random)` | OPAQUE (alpha is always 1) | 6.3 |
| `dolphin` | 86 | `SuspendedTownParticle$DolphinSpeedProvider`, `SuspendedTownParticle` | `get(random)` | OPAQUE | 6.2 |
| `dripping_honey` | 89 | `DripParticle$HoneyHangProvider`, `DripHangParticle` | `get(random)` | OPAQUE | 3.3 |
| `falling_honey` | 90 | `DripParticle$HoneyFallProvider`, `HoneyFallAndLandParticle` | `get(random)` | OPAQUE | 3.4 |
| `landing_honey` | 91 | `DripParticle$HoneyLandProvider`, `DripLandParticle` | `get(random)` | OPAQUE | 3.5 |
| `falling_nectar` | 92 | `DripParticle$NectarFallProvider`, `FallingParticle` | `get(random)` | OPAQUE | 3.6 |
| `falling_spore_blossom` | 93 | `DripParticle$SporeBlossomFallProvider`, `FallingParticle` | `get(random)` | OPAQUE | 3.6 |
| `dripping_obsidian_tear` | 98 | `DripParticle$ObsidianTearHangProvider`, `DripHangParticle` | `get(random)` | OPAQUE | 3.3 |
| `falling_obsidian_tear` | 99 | `DripParticle$ObsidianTearFallProvider`, `FallAndLandParticle` | `get(random)` | OPAQUE | 3.4 |
| `landing_obsidian_tear` | 100 | `DripParticle$ObsidianTearLandProvider`, `DripLandParticle` | `get(random)` | OPAQUE | 3.5 |
| `dripping_dripstone_lava` | 105 | `DripParticle$DripstoneLavaHangProvider`, `CoolingDripHangParticle` | `get(random)` | OPAQUE | 3.3 |
| `falling_dripstone_lava` | 106 | `DripParticle$DripstoneLavaFallProvider`, `DripstoneFallAndLandParticle` | `get(random)` | OPAQUE | 3.7 |
| `dripping_dripstone_water` | 107 | `DripParticle$DripstoneWaterHangProvider`, `DripHangParticle` | `get(random)` | OPAQUE | 3.3 |
| `falling_dripstone_water` | 108 | `DripParticle$DripstoneWaterFallProvider`, `DripstoneFallAndLandParticle` | `get(random)` | OPAQUE | 3.7 |
| `glow_squid_ink` | 109 | `SquidInkParticle$GlowInkProvider`, `SquidInkParticle` | as `squid_ink` | TRANSLUCENT | 7 |
| `glow` (not in the scope list, its class is) | 110 | `GlowParticle$GlowSquidProvider`, `GlowParticle` | `first()` then `get(age, lifetime)` | OPAQUE | 8 |

Notes: all providers accept `(x, y, z, vx, vy, vz)` from the particle packet or from `addParticle`; each provider reads only what its section says. `getLayer` is OPAQUE for every `DripParticle` subclass. The names "hang", "fall" and "land" are the artifact's class stems; the registry names are `dripping_*` (hang), `falling_*` (fall) and `landing_*` (land).

## 3. The drip family (`DripParticle`)

### 3.1 Base class

`DripParticle(level, x, y, z, fluid, sprite)` extends `SingleQuadParticle` with the 5-argument constructor (so the draws are the lifetime draw then the `quadSize` draw), then:

1. `setSize(0.01, 0.01)`.
2. `gravity = 0.06f`.
3. `type = fluid` (a field; `Fluids.EMPTY` for honey, obsidian, nectar and spore blossom). `isGlowing` false.

Velocity arguments are never used: a drip particle always starts with velocity `(0, 0, 0)`, whatever the emitter passed.

`getLightCoords(pt)`: the ordinary packed light, except that with `isGlowing` the block component is replaced by 15 (`LightCoordsUtil.withBlock(light, 15)`, sky component unchanged).

`tick` (all drip classes use this one; the subclasses override two hooks):

1. previous position := position.
2. `preMoveUpdate()`. If the particle is now removed, stop.
3. `yd -= gravity` (the gravity field is subtracted directly, there is no 0.04 factor as in the base `tick`).
4. `move(xd, yd, zd)` (collision as in section 1).
5. `postMoveUpdate()`. If removed, stop.
6. `xd, yd, zd *= 0.98` (the double 0.9800000190734863).
7. If `type` is `EMPTY`, stop. Otherwise take the fluid at the particle's block; if that fluid state is of `type` and `y < blockY + fluidHeight` (the fluid state's `getHeight`, a float widened to double) then remove (the particle is inside the fluid body).

Default hooks: `preMoveUpdate` does `lifetime--` and removes the particle when `lifetime <= 0`; `postMoveUpdate` does nothing. `friction`, `age` and the base `tick` are not used (the `age` counter does not advance).

### 3.2 Class table

| Class | Parent | Constructor effect | `preMoveUpdate` | `postMoveUpdate` |
|---|---|---|---|---|
| `DripHangParticle(…, fluid, fallingParticle, sprite)` | `DripParticle` | stores the follow-up `fallingParticle`; `gravity *= 0.02f` (f32: 0.06 x 0.02 = 0.0012); `lifetime = 40` | `lifetime--`; at `<= 0`: remove and `level.addParticle(fallingParticle, x, y, z, xd, yd, zd)` at the current position (the velocity is passed but the falling provider ignores it) | `xd, yd, zd *= 0.02` |
| `CoolingDripHangParticle` | `DripHangParticle` | none | first sets `rCol = 1`, `gCol = 16.0f / (40 - lifetime + 16)`, `bCol = 4.0f / (40 - lifetime + 8)` (f32 division, `lifetime` before the decrement), then the `DripHangParticle` step | as `DripHangParticle` |
| `FallingParticle` | `DripParticle` | none | default | if `onGround` remove |
| `FallAndLandParticle(…, fluid, landParticle, sprite)` | `FallingParticle` | `lifetime = (int)(64.0 / (r() * 0.8 + 0.2))` (r widened to double; range 64 to 320); stores `landParticle` | default | if `onGround`: remove and `level.addParticle(landParticle, x, y, z, 0, 0, 0)` |
| `DripstoneFallAndLandParticle` | `FallAndLandParticle` | none | default | if `onGround`: remove, add the landing particle as above, then play a local sound (3.7) |
| `HoneyFallAndLandParticle` | `FallAndLandParticle` | none | default | if `onGround`: remove, add the landing particle as above, then play a local sound (3.5) |
| `DripLandParticle` | `DripParticle` | `lifetime = (int)(16.0 / (r() * 0.8 + 0.2))` (range 16 to 80) | default | none |

Because a hang particle's `postMoveUpdate` multiplies the velocity by 0.02 and step 6 multiplies by 0.98 again, a hanging drop drifts only a few hundredths of a block: with `gravity = 0.0012` the velocity before each move is about `-0.0012` (the carried velocity is about `-2.4e-5` after step 6), so over the 39 ticks that move, the drop sinks about `39 x 0.0012 = 0.047` blocks (derived).

### 3.3 Hang providers (`dripping_*`)

Each provider constructs the class below at `(x, y, z)` with the given fluid and follow-up type, then applies the listed adjustments (in this order). The follow-up is the particle type id to spawn when the hang time ends. The hang ticks are fixed constants (40, or the provider's `lifetime = 100`), not random draws, so no random source is involved.

| Type | Class, fluid | Follow-up | Adjustments by the provider | Hang ticks |
|---|---|---|---|---|
| `dripping_lava` | `CoolingDripHangParticle`, LAVA | `falling_lava` | none (the colour is driven by the class, see 3.2) | 40 |
| `dripping_water` | `DripHangParticle`, WATER | `falling_water` | colour `(0.2, 0.3, 1.0)` | 40 |
| `dripping_honey` | `DripHangParticle`, EMPTY | `falling_honey` | `gravity *= 0.01f` (so `0.06 x 0.02 x 0.01 = 1.2e-5`, f32), `lifetime = 100`, colour `(0.622, 0.508, 0.082)` | 100 |
| `dripping_obsidian_tear` | `DripHangParticle`, EMPTY | `falling_obsidian_tear` | `isGlowing = true`, `gravity *= 0.01f`, `lifetime = 100`, colour `(0.51171875, 0.03125, 0.890625)` | 100 |
| `dripping_dripstone_lava` | `CoolingDripHangParticle`, LAVA | `falling_dripstone_lava` | none | 40 |
| `dripping_dripstone_water` | `DripHangParticle`, WATER | `falling_dripstone_water` | colour `(0.2, 0.3, 1.0)` | 40 |

### 3.4 Fall providers (`falling_*` that land)

| Type | Class, fluid | Landing particle | Adjustments by the provider | Lifetime (before landing) |
|---|---|---|---|---|
| `falling_lava` | `FallAndLandParticle`, LAVA | `landing_lava` | colour `(1.0, 0.2857143, 0.083333336)` | `(int)(64 / (r*0.8+0.2))` |
| `falling_water` | `FallAndLandParticle`, WATER | `splash` | colour `(0.2, 0.3, 1.0)` | same |
| `falling_honey` | `HoneyFallAndLandParticle`, EMPTY | `landing_honey` | `gravity = 0.01f` (assigned, not multiplied), colour `(0.582, 0.448, 0.082)` | same |
| `falling_obsidian_tear` | `FallAndLandParticle`, EMPTY | `landing_obsidian_tear` | `isGlowing = true`, `gravity = 0.01f`, colour `(0.51171875, 0.03125, 0.890625)` | same |

The lifetime is reached only by particles that never touch ground; a normal drop lands first. The `r` in the lifetime column is a draw of the particle's own random source (the `FallAndLandParticle`/`DripParticle` constructor); only the provider-side replacements in 3.5 and the nectar lifetime in 3.6 use the provider's `RandomSource` argument of `createParticle`.

### 3.5 Land providers (`landing_*`)

| Type | Class, fluid | Adjustments by the provider | Lifetime |
|---|---|---|---|
| `landing_lava` | `DripLandParticle`, LAVA | colour `(1.0, 0.2857143, 0.083333336)` | `(int)(16 / (r*0.8+0.2))` (16 to 80) |
| `landing_honey` | `DripLandParticle`, EMPTY | colour `(0.522, 0.408, 0.082)`; lifetime is replaced by `(int)(128.0 / (r() * 0.8 + 0.2))` (128 to 640; the provider draws from the provider's random source, not the particle's) | 128 to 640 |
| `landing_obsidian_tear` | `DripLandParticle`, EMPTY | `isGlowing = true`; lifetime replaced by `(int)(28.0 / (r() * 0.8 + 0.2))` (provider random; 28 to 140); colour `(0.51171875, 0.03125, 0.890625)` | 28 to 140 |

A landing particle keeps `gravity = 0.06`: it presses on the ground (its `yd` keeps falling but `move` clips the motion, and `onGround` stays true) until its lifetime ends, or until the lava test of step 7 removes it. It spawns nothing.

`HoneyFallAndLandParticle` sound on landing: `SoundEvents.BEEHIVE_DRIP`, source BLOCKS, volume `Mth.randomBetween(random, 0.3f, 1.0f)` (a particle-random draw; `Mth.randomBetween(random, a, b)` is `random.nextFloat() * (b - a) + a` in f32, read; here `0.3f` to `1.0f`), pitch 1.0, no distance delay, played with `ClientLevel.playLocalSound(x, y, z, …)` at the landing position, after the landing particle was added.

### 3.6 Fall providers without landing (`falling_nectar`, `falling_spore_blossom`)

Both build `FallingParticle` (EMPTY fluid; removed on ground contact, no landing particle, no sound, no fluid check since the type is `EMPTY`).

| Type | `lifetime` set by the provider | `gravity` | Colour |
|---|---|---|---|
| `falling_nectar` | `(int)(16.0 / (r() * 0.8 + 0.2))` (provider random; 16 to 80) | `0.007f` | `(0.92, 0.782, 0.72)` |
| `falling_spore_blossom` | `(int)(64.0f / Mth.randomBetween(random, 0.1f, 0.9f))` (the particle's own `random` field, read; `randomBetween` as in 3.5; about 71 to 640) | `0.005f` | `(0.32, 0.5, 0.22)` |

### 3.7 Dripstone fall providers

| Type | Class, fluid | Landing particle | Colour | Landing sound |
|---|---|---|---|---|
| `falling_dripstone_lava` | `DripstoneFallAndLandParticle`, LAVA | `landing_lava` | `(1.0, 0.2857143, 0.083333336)` | `POINTED_DRIPSTONE_DRIP_LAVA` |
| `falling_dripstone_water` | `DripstoneFallAndLandParticle`, WATER | `splash` | `(0.2, 0.3, 1.0)` | `POINTED_DRIPSTONE_DRIP_WATER` |

On landing (`onGround`): remove, `addParticle(landParticle, x, y, z, 0, 0, 0)`, then `playLocalSound(x, y, z, sound, BLOCKS, volume, 1.0, false)` with `volume = Mth.randomBetween(random, 0.3f, 1.0f)` (a particle-random draw; formula as in 3.5). The sound is chosen by the particle's fluid type: lava gives the lava sound, any other fluid the water sound. `gravity` stays 0.06 and the lifetime is the `FallAndLandParticle` one.

### 3.8 Two sampled trajectories (derived from 3.1)

Falling drop, gravity 0.06, from rest. `yd` before the move, displacement per tick and cumulative drop (the friction 0.98 is applied after each move):

| Tick | `yd` used for the move | Cumulative drop |
|---|---|---|
| 1 | -0.06 | 0.06 |
| 2 | -0.1188 | 0.1788 |
| 3 | -0.176424 | 0.355224 |
| 4 | -0.23289552 | 0.58811952 |
| 5 | -0.2882376096 | 0.8763571296 |
| 6 | -0.3424728574 | 1.2188299870 |

A drop released 1 block above the floor therefore reaches the floor on tick 6 (the move on that tick is clipped to the remaining 0.1236 blocks and `onGround` is set), and the landing particle is created on that same tick at the floor. Terminal speed is `0.06 / 0.02 = 3.0` blocks per tick (derived); the 1.0-gravity of the base model never applies.

Cooling lava hang: the colour set at the start of each tick, where `L` is the lifetime before the decrement:

| Tick | `L` | `gCol` | `bCol` |
|---|---|---|---|
| 1 | 40 | 16/16 = 1.0 | 4/8 = 0.5 |
| 21 | 20 | 16/36 = 0.4444 | 4/28 = 0.1429 |
| 40 | 1 | 16/55 = 0.2909 | 4/47 = 0.0851 |

The tick-40 value is replaced in the same tick by the removal (`lifetime` reaches 0) and the spawn of `falling_lava`, whose provider colour `(1, 0.2857143, 0.083333336)` equals the formula at `L = 0` (16/56, 4/48).

## 4. How the client emits drip particles

Drip particles are created by client-side scans, never by packets in normal play. All of them go through `ClientLevel.addParticle` (part 1 for the distance and particle-status gate).

### 4.1 The random-tick scan (`ClientLevel.animateTick`, `doAnimateTick`)

`Minecraft.tick` calls `ClientLevel.animateTick(px, py, pz)` once per client tick (not while paused, only when the level runs normally) with the block position of the local player. `animateTick` creates one thread-local random source (`RandomSource.createThreadLocalInstance`, called `scanRandom` below) and then repeats 667 times: `doAnimateTick(px, py, pz, 16, …)` and then `doAnimateTick(px, py, pz, 32, …)`. That is 1334 sampled positions per tick (derived), in two spherical-ish shells of different spread.

One `doAnimateTick(cx, cy, cz, r, scanRandom, markerBlock, pos)`:

1. Pick `x = cx + level_random.nextInt(r) - level_random.nextInt(r)`, then the same for `y` (with `cy`) and `z` (with `cz`). The draw order is x-plus, x-minus, y-plus, y-minus, z-plus, z-minus, all from the level random (so the offsets are triangular, in `(-r, r)`).
2. `state = block at pos`. Call `state.getBlock().animateTick(state, level, pos, scanRandom)` (the block emitters of section 4.3).
3. `fluid = fluid state at pos`. If it is not empty: call `fluid.animateTick(level, pos, scanRandom)` (section 4.2); then `drip = fluid.getDripParticle()`. If `drip` exists (water gives `dripping_water`, lava gives `dripping_lava`, the base fluid gives none) and `level_random.nextInt(10) == 0`: `sturdy = state.isFaceSturdy(level, pos, DOWN)`; `below = pos.below()`; call `trySpawnDripParticles(below, state_at(below), drip, sturdy)` (section 4.4).
4. If `markerBlock` (a creative player holding a marker item that is a block item, part 4) equals the block, add `block_marker` (part 4).
5. If the block's collision shape is not a full block, take the environment attribute `ambient_particles` at the position (a list of entries, part 4) and for each entry that passes `canSpawn(level_random)` add its particle at `(x + rd(), y + rd(), z + rd())` with zero velocity (draws from the level random, in x, y, z order).

### 4.2 Fluid `animateTick`

| Fluid | Rule |
|---|---|
| Water (`WaterFluid.animateTick`) | If the fluid is flowing and not falling (not a source and not the falling state): when `scanRandom.nextInt(64) == 0`, play the local sound `WATER_AMBIENT` (source AMBIENT, at the block centre, volume `scanRandom.nextFloat() * 0.25f + 0.75f`, pitch `scanRandom.nextFloat() + 0.5f`, no distance delay). Otherwise (source, or a falling flowing state): when `scanRandom.nextInt(10) == 0`, add `underwater` at `(bx + rd(), by + rd(), bz + rd())`, zero velocity (the three `rd()` come from `scanRandom`, order x, y, z). |
| Lava (`LavaFluid.animateTick`) | `above = pos.above()`. Only if the block above is air and is not solid-render: when `scanRandom.nextInt(100) == 0`: `(px, py, pz) = (bx + rd(), by + 1.0, bz + rd())` (x draw first), add the `lava` particle (part 2) there with zero velocity and play `LAVA_POP` (AMBIENT) at the same point with volume `0.2f + r * 0.2f` and pitch `0.9f + r * 0.15f` (`scanRandom` floats, volume draw first); independently, when `scanRandom.nextInt(200) == 0`, play `LAVA_AMBIENT` (AMBIENT) at `(bx, by, bz)` (the block corner, not the centre) with the same volume and pitch formulas. |

The source/flowing test of the water branch is `FluidState.isSource()` and the `falling` state property; both read from `WaterFluid`.

### 4.3 Block emitters of the drip family

All run from step 2 of 4.1 (`scanRandom` is the random passed to `animateTick`).

**Leaves** (`LeavesBlock.animateTick`, after the block's own base animation and before the ambient leaves sound player of part 6): let `below = pos.below()`. Return unless `level.isRainingAt(pos.above())`. Return unless `scanRandom.nextInt(15) == 1`. Return if the block below `canOcclude` and its UP face is sturdy. Otherwise `ParticleUtils.spawnParticleBelow(level, pos, scanRandom, dripping_water)`: add `dripping_water` at `(bx + rd(), by - 0.05, bz + rd())` with zero velocity (x draw first).

**Wet sponge** (`WetSpongeBlock.animateTick`): `d = Direction.getRandom(scanRandom)` (read: `Direction.getRandom(rs)` is `Util.getRandom(Direction.VALUES, rs)`, which returns `array[rs.nextInt(array.length)]`, so one `nextInt(6)` and a uniform pick; the order of `Direction.VALUES` was not read and matters only for exact random-stream replay, see Open question 3). If `d` is UP, stop. Let `n = pos.relative(d)`. If this block `canOcclude` and the neighbour's face toward the block (`d.getOpposite()`) is sturdy, stop. Otherwise the spawn point starts at the block corner `(bx, by, bz)` and then:

| `d` | x | y | z |
|---|---|---|---|
| DOWN | `bx + rd()` | `by - 0.05` | `bz + rd()` |
| EAST | `bx + 1.1` | `by + rd() * 0.8` | `bz + rd()` |
| WEST | `bx + 0.05` | `by + rd() * 0.8` | `bz + rd()` |
| SOUTH | `bx + rd()` | `by + rd() * 0.8` | `bz + 1.1` |
| NORTH | `bx + rd()` | `by + rd() * 0.8` | `bz + 0.05` |

Draw order: for DOWN the y offset is a constant and the draws are x then z; for the side faces the y draw `rd()` comes first, then the draw for the free horizontal axis. Add `dripping_water` there, zero velocity.

**Beehive and bee nest** (`BeehiveBlock.animateTick`): when the `honey_level` state is `>= 5`, the loop `for (i = 0; i < scanRandom.nextInt(1) + 1; i++)` runs once (`nextInt(1)` is 0 and is drawn twice, once per condition test; the draws do not change the outcome but they advance `scanRandom`). Each pass calls `trySpawnDripParticles(level, pos, state)`:

1. Return if the block's own fluid state is not empty, or if `level_random.nextFloat() < 0.3f` (so 70% of passes continue; the draw is from the level random).
2. `shape = collision shape`; `maxY = shape.max(Y)`. Continue only if `maxY >= 1.0` and the block is not in the block tag `impermeable`.
3. `minY = shape.min(Y)`. If `minY > 0`: spawn at height `by + minY - 0.05`. Otherwise (`minY <= 0`): take the block below; if (its `maxY < 1` or it is not a full-block collision shape) and its fluid state is empty, spawn at height `by - 0.05`; else nothing.
4. The spawn (`spawnParticle`) is a `dripping_honey` at `(lerp(rd(), bx + shape.minX, bx + shape.maxX), height, lerp(rd(), bz + shape.minZ, bz + shape.maxZ))`, with the two `rd()` drawn from the level random, x first, and `lerp(t, a, b) = a + t * (b - a)`. Zero velocity.

**Spore blossom** (`SporeBlossomBlock.animateTick`): add `falling_spore_blossom` at `(bx + scanRandom.nextDouble(), by + 0.7, bz + scanRandom.nextDouble())` (x draw first), zero velocity. Then 14 times: pick `(bx + nextInt(-10, 10), by - scanRandom.nextInt(10), bz + nextInt(-10, 10))` where `nextInt(min, max)` is `Mth.nextInt` (inclusive bounds, `min + nextInt(max - min + 1)`; draw order x, y, z); if the block there is not a full-block collision shape, add `spore_blossom_air` (part 4) at `(x + rd(), y + rd(), z + rd())` with zero velocity.

**Crying obsidian** (`CryingObsidianBlock.animateTick`): if `scanRandom.nextInt(5) != 0` stop; `d = Direction.getRandom(scanRandom)`; if `d` is UP stop; let `n = pos.relative(d)`; if this block `canOcclude` and the neighbour's `d.getOpposite()` face is sturdy, stop. The position offsets `(ox, oy, oz)` are computed per axis: if the axis step of `d` is 0 the offset is `scanRandom.nextDouble()` (draw order x, y, z, only for the zero axes), else `0.5 + step * 0.6`. Add `dripping_obsidian_tear` at `(bx + ox, by + oy, bz + oz)`, zero velocity.

**Pointed dripstone** (`PointedDripstoneBlock.animateTick`), constants: probability `0.02` (water or lava not above a cauldron) and `0.12` (when the block above the dripstone root holds a source or is mud; the cap), `MAX_SEARCH_LENGTH_WHEN_CHECKING_DRIP_TYPE = 11`:

1. Return unless this block is a free-hanging stalactite: the `vertical_direction` property is DOWN (a stalactite), `thickness` is `tip`, and not waterlogged.
2. `f = scanRandom.nextFloat()`. Return if `f > 0.12`.
3. `info = getFluidAboveStalactite` (below). Keep it only if `f < 0.02` or the info's fluid is lava or water (the fluid can fill a cauldron). If kept, call `spawnDripParticle`.
4. `getFluidAboveStalactite`: walk upward from the tip (`findRootBlock`): up to 10 steps (`i = 1 .. 10`); at each step move one block up; if the new block is not a pointed dripstone, that position is the root; otherwise if the new position is outside the build height or the block is not a pointed dripstone with the same `vertical_direction`, there is no result. With the root `R`: `above = R.above()`; if the block at `above` is mud and the environment attribute `water_evaporates` at `above` is false the fluid is water; otherwise the fluid is the type of the fluid state at `above` (empty if none). The result carries the position `above`, the fluid and the block state at `above`.
5. `spawnDripParticle(level, tipPos, state, fluid, abovePos)`: position `x = tipX + 0.5 + offset.x`, `y = tipY + STALACTITE_DRIP_START_PIXEL - 0.0625`, `z = tipZ + 0.5 + offset.z`, where `offset` is `BlockState.getOffset(tipPos)` (24 section 4.4). Constants are in the parent class `SpeleothemBlock` (read): `SHAPE_TIP_DOWN` is `Block.column(6, 5, 16)` and `STALACTITE_DRIP_START_PIXEL` is its minimum Y, 5 pixels, so `5/16 = 0.3125`; `SHAPE_BASE` is `Block.column(12, 0, 16)` and the maximum horizontal offset is its minimum X as a float, 2 pixels, so `0.125`. `column(size, minY, maxY)` spans `8 - size/2` to `8 + size/2` horizontally in pixels (read). The division of pixels by 16 inside `box` was not read (inferred, Open question 12). This gives `y = tipY + 0.3125 - 0.0625 = tipY + 0.25`. The particle is chosen by `getDripParticle(level, fluid, pos)`: an empty fluid gives the environment attribute `default_dripstone_particle` at the position (a particle option; its default is the dripping dripstone water particle, 23 section on environment attributes; the per-biome values are data, part 6 4.3 repeats the rule), a lava fluid gives `dripping_dripstone_lava`, anything else gives `dripping_dripstone_water`. Zero velocity.

**Bee** (`Bee.tick`, client and server run the entity tick): if the bee carries nectar, fewer than 10 crops were grown since pollination and `random.nextFloat() < 0.05f`, then for `i = 0; i < random.nextInt(2) + 1; i++` (the bound is redrawn every pass) call `spawnFluidParticle(level, x - 0.3, x + 0.3, z - 0.3, z + 0.3, getY(0.5), falling_nectar)`, which adds the particle at `(lerp(rd(), x0, x1), y, lerp(rd(), z0, z1))` with the draws from the level random (x first) and zero velocity. `getY(0.5)` is the bee's feet y plus half its bounding-box height.

### 4.4 The generic fluid-drip placement (`ClientLevel.trySpawnDripParticles`)

Input: `pos` is the block below the sampled fluid block, `state` its block state, `drip` the particle, `sturdy` whether the sampled block's DOWN face is sturdy.

1. Return if `state` has a non-empty fluid state.
2. `shape = collision shape of state at pos`, `maxY = shape.max(Y)`.
3. If `maxY < 1.0`: only when `sturdy`, spawn across the whole block cell at `y = pos.y + 1 - 0.05` (x from `px` to `px + 1`, z from `pz` to `pz + 1`); otherwise nothing.
4. Else (`maxY >= 1.0`): return if `state` is in the block tag `impermeable`. `minY = shape.min(Y)`. If `minY > 0`: spawn with the shape's X and Z extents at `y = pos.y + minY - 0.05`. Otherwise (`minY <= 0`): `below2 = pos.below()`; if its collision `maxY < 1.0` and its fluid state is empty, spawn with the shape's X and Z extents at `y = pos.y - 0.05`.

The spawn is `spawnFluidParticle(x0, x1, z0, z1, y, drip)`: add `drip` at `(lerp(rd(), x0, x1), y, lerp(rd(), z0, z1))` with the draws from the level random (x first) and zero velocity. `spawnParticle(pos, drip, shape, y)` calls it with `x0 = px + shape.min(X)`, `x1 = px + shape.max(X)`, `z0 = pz + shape.min(Z)`, `z1 = pz + shape.max(Z)`. The constant 0.05 is `FLUID_PARTICLE_SPAWN_OFFSET`.

Note the asymmetry with the beehive's own `trySpawnDripParticles` (4.3), which tests the block's own shape instead of the block below.

## 5. Bubbles, splashes and water currents

### 5.1 `bubble` (`BubbleParticle`)

Constructor `(level, x, y, z, vx, vy, vz, sprite)` (provider passes the packet velocity): the 5-argument `SingleQuadParticle` constructor (lifetime draw, `quadSize` draw), `setSize(0.02, 0.02)`, then in order:

1. `quadSize *= r() * 0.6f + 0.2f`.
2. `xd = vx * 0.2 + (r() * 2 - 1) * 0.02`, `yd = vy * 0.2 + (r() * 2 - 1) * 0.02`, `zd = vz * 0.2 + (r() * 2 - 1) * 0.02` (the 0.2 is the double 0.20000000298023224; draw order x, y, z).
3. `lifetime = (int)(8.0 / (r() * 0.8 + 0.2))` (8 to 40).

Tick (own, not the base): previous position := position; `lifetime--`, remove at `<= 0` and stop; `yd += 0.002`; `move(xd, yd, zd)`; `xd, yd, zd *= 0.85` (0.8500000238418579); then remove unless the fluid check finds a fluid in the tag `water` (any water, source or flowing). No age counter, no sprite change.

Steady rise: with `v` the velocity after friction, `v = (v + 0.002) * 0.85`, so `v` converges to `0.01133` and the per-tick displacement to `0.01333` blocks (derived).

### 5.2 `bubble_pop` (`BubblePopParticle`)

Constructor `(level, x, y, z, vx, vy, vz, sprites)`: 5-argument `SingleQuadParticle` constructor with `sprites.first()`, `lifetime = 4`, `gravity = 0.008f`, `xd = vx`, `yd = vy`, `zd = vz` (assigned directly; no randomisation), `setSpriteFromAge`. Tick: previous position := position; `age++`; at `age >= lifetime` remove and stop; `yd -= gravity` (direct); `move`; `setSpriteFromAge` (sprite index `(age * (n - 1)) / 4`). No friction, no fluid check. The type has no emitter in the artifact apart from the particle packet and the `/particle` command (the class search found the constant only in the registration).

### 5.3 `rain` (`WaterDropParticle`) and `splash` (`SplashParticle`)

`WaterDropParticle(level, x, y, z, sprite)`: the 7-argument `SingleQuadParticle` constructor with velocity `(0, 0, 0)` (so section 1's randomisation is applied, draw order: lifetime, then the three velocity draws, then the two `f` draws, then `quadSize`), then:

1. `xd *= 0.3`, `zd *= 0.3`; `yd = r() * 0.2f + 0.1f` (one draw, replacing the computed `yd`).
2. `setSize(0.01, 0.01)`; `gravity = 0.06f`.
3. `lifetime = (int)(8.0 / (r() * 0.8 + 0.2))` (8 to 40).

Tick: previous position := position; `lifetime--` and remove at `<= 0` (stop); `yd -= gravity` (direct); `move`; `xd, yd, zd *= 0.98`; if `onGround`: remove when `r() < 0.5`, then `xd, zd *= 0.7`; then, every tick (also when not on ground): `p = block position of the particle`, `d = max(collisionShape(block at p).max(Y, x - p.x, z - p.z), fluidHeight(p))` (the shape's top at the particle's local x and z; `fluidHeight` is the fluid state's height as a double); if `d > 0` and `y < p.y + d`, remove (the drop is inside a block or a fluid surface).

`SplashParticle(level, x, y, z, vx, vy, vz, sprite)` is a `WaterDropParticle` (so it draws the same sequence) followed by `gravity = 0.04f`; then, only when `vy == 0` and (`vx != 0` or `vz != 0`): `xd = vx`, `yd = 0.1`, `zd = vz`. With `vy != 0` or all three zero it keeps the random water-drop velocity.

Emitter of `rain`: section 9.1. Emitters of `splash`: the landing of falling water (section 3.4), the fishing hook (9.5), and entities, potions and dispensers (part 7).

### 5.4 `fishing` (`WakeParticle`)

Constructor `(level, x, y, z, vx, vy, vz, sprites)`: the 7-argument `SingleQuadParticle` constructor with velocity `(0, 0, 0)` and `sprites.first()` (same draw sequence as the water drop), then `xd *= 0.3`, `yd = r() * 0.2f + 0.1f`, `zd *= 0.3` (all overwritten below), `setSize(0.01, 0.01)`, `lifetime = (int)(8.0 / (r() * 0.8 + 0.2))`, `setSpriteFromAge`, `gravity = 0`, and finally `xd = vx`, `yd = vy`, `zd = vz` (assigned: the packet velocity is the real motion).

Tick: previous position := position; `i = 60 - lifetime` (computed before the decrement); `lifetime--`, remove at `<= 0` (stop); `yd -= gravity` (zero); `move`; `xd, yd, zd *= 0.98`; `s = i * 0.001f`; `setSize(s, s)`; sprite `sprites.get(i % 4, 4)`, that is `sprites[(i % 4) * (n - 1) / 4]`. The first draw order after creation consumes the same draws as the water drop. No fluid check: the wake rides on its initial velocity, which is horizontal in practice (section 9.5).

### 5.5 `bubble_column_up` (`BubbleColumnUpParticle`)

Constructor `(level, x, y, z, vx, vy, vz, sprite)`: the 5-argument `SingleQuadParticle` constructor, `gravity = -0.125f`, `friction = 0.85f`, `setSize(0.02, 0.02)`, `quadSize *= r() * 0.6f + 0.2f`, `xd = vx * 0.2 + (r() * 2 - 1) * 0.02` (y and z likewise, same as section 5.1 step 2), `lifetime = (int)(40.0 / (r() * 0.8 + 0.2))` (40 to 200).

Tick: the base `tick` (section 1: `yd -= 0.04 * -0.125` that is `+0.005` per tick, move with collision, friction 0.85, age and lifetime), then remove unless the fluid check finds the tag `water`. Steady rise: `v = (v + 0.005) * 0.85` so `v` converges to `0.02833` and the displacement to `0.03333` blocks per tick (0.667 blocks per second, derived).

### 5.6 `current_down` (`WaterCurrentDownParticle`)

Constructor `(level, x, y, z, sprite)` (velocity arguments are ignored): the 5-argument `SingleQuadParticle` constructor, then `lifetime = (int)(r() * 60.0f) + 30` (30 to 89), `hasPhysics = false`, `xd = 0`, `yd = -0.05`, `zd = 0`, `setSize(0.02, 0.02)`, `quadSize *= r() * 0.6f + 0.2f`, `gravity = 0.002f` (stored, unused: the tick below does not read it). The field `angle` starts at 0.

Tick (own): previous position := position; `age++`, remove at `age >= lifetime` (the code does not stop afterwards; the remaining steps run harmlessly once); `xd += 0.6f * cos(angle)`, `zd += 0.6f * sin(angle)`; `xd *= 0.07`, `zd *= 0.07`; `move(xd, yd, zd)` (no collision because `hasPhysics` is false, the bounding box just moves); remove if the fluid check does not find the tag `water`, or if `onGround` (never true without physics, kept for completeness); `angle += 0.08f`. `yd` stays `-0.05`; `Mth.cos` and `Mth.sin` take the angle as a double and return a float; they are lookup-table functions (read): `sin(x) = SIN[(int)(long)(x * 10430.378350470453) & 65535]` and `cos(x) = SIN[(int)(long)(x * 10430.378350470453 + 16384.0) & 65535]` (the contents of `SIN[]` were not read, see Open question 4). The horizontal velocity is `0.07 x (previous + 0.6 cos(angle))`, so the particle traces a small circle (radius order 0.006 blocks per tick) while sinking 0.05 blocks per tick.

## 6. Suspended, glow and flying particles

### 6.1 `underwater` (`SuspendedParticle`, 5-argument form)

Provider `UnderwaterProvider`: build the particle at `(x, y, z)` with `sprite.get(random)` (the provider's draw happens before the particle's constructor draws), then `setColor(0.4, 0.4, 0.7)`. Constructor: `SingleQuadParticle` 5-argument constructor at `(x, y - 0.125, z)` (the y is lowered by 0.125 in the constructor); `setSize(0.01, 0.01)`; `quadSize *= r() * 0.6f + 0.2f`; `lifetime = (int)(16.0 / (r() * 0.8 + 0.2))` (16 to 80); `hasPhysics = false`; `friction = 1.0`; `gravity = 0`. Velocity `(0, 0, 0)`; the base `tick` removes it at `age >= lifetime`. It never moves. Emitter: water `animateTick` (4.2).

### 6.2 `dolphin` (`SuspendedTownParticle`)

Provider `DolphinSpeedProvider`: create `SuspendedTownParticle(level, x, y, z, vx, vy, vz, sprite.get(random))`, then `setColor(0.3, 0.5, 1.0)`, then `setAlpha(1.0 - provider_random.nextFloat() * 0.7f)`, then `setLifetime(getLifetime() / 2)` (integer division).

Constructor: the 8-argument `SingleQuadParticle` constructor (section 1: randomised, normalised velocity), then `v = r() * 0.1f + 0.2f` and `rCol = gCol = bCol = v` (replaced by the provider's colour), `setSize(0.02, 0.02)`, `quadSize *= r() * 0.6f + 0.5f`, `xd, yd, zd *= 0.02` (0.019999999552965164), `lifetime = (int)(20.0 / (r() * 0.8 + 0.2))` (20 to 100; halved by the provider: 10 to 50).

Tick (own): previous position := position; `lifetime--`, remove at `<= 0`; `move(xd, yd, zd)`; `xd, yd, zd *= 0.99`. The override `move` translates the bounding box without any collision. Layer: OPAQUE even though the alpha is below 1 (alpha is applied by the renderer; part 1).

### 6.3 `nautilus` (`FlyTowardsPositionParticle`)

Provider: `FlyTowardsPositionParticle(level, x, y, z, vx, vy, vz, sprite.get(random))` (no colour change). The meaning of the arguments: `(x, y, z)` is the **target** the particle converges on, and `(vx, vy, vz)` is the **offset from the target to the starting point**.

Constructor (the 8-argument form chains to a 10-argument form with `glowing = false` and `LifetimeAlpha.ALWAYS_OPAQUE`): the 5-argument `SingleQuadParticle` constructor, alpha = start alpha (1); `(xd, yd, zd) = (vx, vy, vz)` (stored, used as the offset, not as a velocity); `(xStart, yStart, zStart) = (x, y, z)`; previous position and position := `(x + vx, y + vy, z + vz)` (the particle starts at the far end); `quadSize = 0.1f * (r() * 0.5f + 0.2f)` (replaces the earlier value); `c = r() * 0.6f + 0.4f`, `rCol = gCol = 0.9f * c`, `bCol = c`; `hasPhysics = false`; `lifetime = (int)(r() * 10.0f) + 30` (30 to 39). Draw order: lifetime draw, `quadSize` draw of the base, `quadSize` draw, `c` draw, lifetime draw.

Tick: previous position := position; `age++`, remove at `age >= lifetime`; `t = 1 - age / lifetime` (f32 division, int operands converted to float), `u = (1 - t)^4` (the square of the square of `1 - t`, f32); then `x = xStart + xd * t`, `z = zStart + zd * t`, `y = yStart + yd * t - u * 1.2`. At `age = 0` the particle is at `start + offset`, at `age = lifetime` at `start - 1.2` blocks below the target (it dips by up to 1.2 near the end because `u` grows to 1 when `t` is 0; removal comes first, at `age == lifetime`, so the last drawn position has `u = ((lifetime - 1) / lifetime)^4`). `move` is overridden to translate the box only.

Light: not glowing, so `lightCoords = addSmoothBlockEmission(base light, (age / lifetime)^4)` with `age / lifetime` in f32, raised to the 4th power in f32, and no partial tick. The base light is the 12 section 1.4 packing, whose helpers `smoothBlock`, `smoothSky` and `smoothPack` are used here unchanged (the blend is 12 section 1.5). New here, `addSmoothBlockEmission(p, t)` (read): `t` clamped to `[0, 1]`, `e = (int)(clamp(t) * 240.0f)`, result `smoothPack(min(smoothBlock(p) + e, 240), smoothSky(p))`. So the emission is ADDED to the existing block value and the sum is capped at 240; the sky value is unchanged. The renderer calls `LifetimeAlpha.currentAlphaForAge(age, lifetime, partial)`: with equal start and end alpha it returns the start alpha, so the alpha is constant 1.

### 6.4 `sulfur_bubbles` (`SulfurBubbleParticle`)

The provider passes the packet velocity as `(vx, vy)` into the constructor's two horizontal parameters (so the second horizontal component takes the packet's `vy`, as read; emitters send 0 so it has no effect, see Open question 6).

Constructor `(level, x, y, z, hx, hz, sprite)`: the 5-argument `SingleQuadParticle` constructor, `gravity = -0.04f`, `friction = 0.85f`, `setSize(0.02, 0.02)`, `xd = hx * 0.2 + (r() * 2 - 1) * 0.02`, `zd = hz * 0.2 + (r() * 2 - 1) * 0.02` (`yd` stays 0), `sizeStart = 0.02f + 0.02f * r()` (0.02 to 0.04), `quadSize = sizeStart`, `lifetime = 2147483647`, `yStart = y` (the initial `yo`), `yEnd = yo + 4.0 - 1.0 = y + 3`, `yPrev = y` (the constructor argument).

Tick: the base `tick` (section 1 with `gravity = -0.04`: `yd += 0.0016` per tick, friction 0.85); then, in this order and each guarded by "not yet removed": (a) remove unless the fluid at the particle is a **water source** (`isSourceOfType(WATER)`, flowing water does not qualify); (b) remove if `y >= yEnd`; (c) remove if `y <= yPrev` (no upward progress this tick); then `xd += w()`, `zd += w()` with `w() = r() * 0.003f * (nextBoolean ? +1 : -1) * 0.5` (a float draw then a boolean draw, per call; x call first); `move(xd, 0, zd)` (a horizontal-only move, collision applies); `t = (y - yStart) / (yEnd - yStart)` (double, narrowed to float), `quadSize = sizeStart + t * (0.15f - sizeStart)` (growing from `sizeStart` to 0.15); `yPrev = y`. Rise: the base steady state of 5.1 with `0.0016`: `v` converges to 0.009067 and the displacement to 0.010667 blocks per tick (derived), so a bubble needs about 280 ticks (14 s) plus the acceleration phase to rise the 3 blocks. Emitter: section 9.8.

## 7. Squid ink (`squid_ink`, `glow_squid_ink`)

`SquidInkParticle(level, x, y, z, vx, vy, vz, argb, sprites)` extends `SimpleAnimatedParticle` (constructor `(level, x, y, z, sprites, gravity = 0)`: the 5-argument `SingleQuadParticle` constructor with `sprites.first()`, `friction = 0.91f`, `gravity = 0`). Then:

1. `friction = 0.92f`, `quadSize = 0.5f`, `setAlpha(1)`.
2. `setColor(redFloat(argb), greenFloat(argb), blueFloat(argb))` (each channel `/ 255`).
3. `lifetime = (int)(quadSize * 12.0f / (r() * 0.8f + 0.2f))` that is `(int)(6.0f / (r() * 0.8f + 0.2f))` (6 to 30).
4. `setSpriteFromAge(sprites)`, `hasPhysics = false`, `xd = vx`, `yd = vy`, `zd = vz` (assigned).

Providers: `squid_ink`: `argb = -16777216` (opaque black, `0xFF000000`, so colour `(0, 0, 0)`); `glow_squid_ink`: `argb = ARGB.colorFromFloat(1.0, 0.2, 0.8, 0.6)`, channels `floor(255 x value)` = 51, 204, 153 (the order `(alpha, red, green, blue)` of the four arguments is inferred), so colour `(0.2, 0.8, 0.6)`. The class is TRANSLUCENT and its light is the full-bright constant 15728880 (block 15, sky 15; `SimpleAnimatedParticle.getLightCoords`).

Tick: the `SimpleAnimatedParticle` tick, then the ink-specific part. `SimpleAnimatedParticle.tick` is the base `tick` (section 1 with `gravity = 0`, friction 0.92; with `hasPhysics` false the `move` is a bounding-box translation without collision), then `setSpriteFromAge`, then when `age > lifetime / 2` (integer division): `alpha = 1 - (age - lifetime / 2) / lifetime` (f32; `lifetime / 2` converted to float after the integer division), and, if a fade colour was set (never for ink), the colour is blended toward it by 0.2 per tick. `SquidInkParticle.tick` then, if the particle is not removed, repeats `setSpriteFromAge` and the same alpha formula (idempotent), and finally, if the block at the particle's position is air, subtracts `0.0074` from `yd` (the double 0.007400000002235174): ink sinks in air and drifts in water. Note: the velocity is multiplied by 0.92 every tick by the base step.

The squid emits it on the server, see section 9.4.

## 8. `GlowParticle` (the `glow` type, `GlowSquidProvider`)

`GlowParticle(level, x, y, z, vx, vy, vz, sprites)`: the 8-argument `SingleQuadParticle` constructor with `sprites.first()`, `friction = 0.96f`, `speedUpWhenYMotionIsBlocked = true`, `quadSize *= 0.75f`, `hasPhysics = false`, `setSpriteFromAge`. Tick: the base `tick`, then `setSpriteFromAge`. Light: `addSmoothBlockEmission(base light, (age + partial) / lifetime)` (the helper of 6.3; the argument is `(age + partial) / lifetime` in f32, read, linear rather than the 4th power of the nautilus). Layer OPAQUE.

`GlowSquidProvider.createParticle(x, y, z, vx, vy, vz, random)` (the engine's random): construct with velocity `(0.5 - random.nextDouble(), vy, 0.5 - random.nextDouble())` (x draw first; the second argument is the packet's `vy`), so the 8-argument constructor adds its own randomisation; then (a) `random.nextBoolean()`: true gives colour `(0.6, 1.0, 0.8)`, false gives `(0.08, 0.4, 0.4)`; (b) `yd *= 0.2`; (c) if the packet's `vx == 0` and `vz == 0`: `xd *= 0.1` and `zd *= 0.1`; (d) `setLifetime((int)(8.0 / (random.nextDouble() * 0.8 + 0.2)))` (8 to 40).

## 9. Server and entity emitters of the scope types

### 9.1 Rain (`ClientLevel.tickWeatherEffects`)

Called every client tick (part 1 for the call site). Inputs: the particle status option (ALL, DECREASED, MINIMAL), the weather-radius option `R` (an integer slider with range 3 to 10 and default 10), `rain = getRainLevel(1.0)`.

1. Return if `rain <= 0`.
2. `weatherRandom = RandomSource.createThreadLocalInstance(gameTime * 312987231)` (a seed derived from the game time, so the spawn pattern is a function of the tick).
3. `centre = block position of the camera`. `N = (2R + 1)^2`. `count = (int)(0.225f * N * rain * rain) / (DECREASED ? 2 : 1)` (the float product is truncated to an int first, then integer-divided).
4. Repeat `count` times: `dx = weatherRandom.nextInt(2R + 1) - R`, `dz = weatherRandom.nextInt(2R + 1) - R` (x first). `top = heightmap position MOTION_BLOCKING` at `centre + (dx, 0, dz)`. Skip this iteration unless `top.y > minY` and `|top.y - centre.y| <= 10` (precisely: `top.y <= centre.y + 10` and `top.y >= centre.y - 10`) and the precipitation at `top` is RAIN (the biome's precipitation type, with temperature rules of the world docs). Otherwise `ground = top.below()` is remembered (it is also used by the rain sound, which is not covered here); then, **if the status is MINIMAL stop the whole loop** (no particles; only the position is remembered). Else draw `u = weatherRandom.nextDouble()`, `v = weatherRandom.nextDouble()`; let `h = max(collisionShape(ground).max(Y, u, v), fluidHeight(ground))`; the particle is `smoke` (part 2) if the ground fluid is in the tag `lava`, or the block is magma, or it is a lit campfire; otherwise `rain`; add it at `(ground.x + u, ground.y + h, ground.z + v)` with zero velocity.

### 9.2 Bubble column block (`BubbleColumnBlock.animateTick`)

`(x, y, z)` = block corner. When `drag_down` is true: add `current_down` through `addAlwaysVisibleParticle` at `(x + 0.5, y + 0.8, z)` (the z has no 0.5; read) with zero velocity; then, when `scanRandom.nextInt(200) == 0`, play `BUBBLE_COLUMN_WHIRLPOOL_AMBIENT` (BLOCKS, at the block corner, volume `0.2f + r * 0.2f`, pitch `0.9f + r * 0.15f`, no distance delay). When `drag_down` is false: add `bubble_column_up` at `(x + 0.5, y, z + 0.5)` with velocity `(0, 0.04, 0)`, then a second `bubble_column_up` at `(x + r(), y + r(), z + r())` with velocity `(0, 0.04, 0)` (`scanRandom` floats, x first), both through `addAlwaysVisibleParticle`; then, when `scanRandom.nextInt(200) == 0`, play `BUBBLE_COLUMN_UPWARDS_AMBIENT` with the same volume and pitch formulas.

### 9.3 Conduit (`ConduitBlockEntity.clientTick` and `animationTick`)

`clientTick` runs every client tick: it increments the block entity's tick count; every 40th game tick it recomputes the frame (active) and the hunting target; it then calls `animationTick(level, pos, effectBlocks, targetEntity, tickCount)` (the list is empty when the frame is not complete, so no frame particles appear then, inferred; the gating of the list was not read, Open question 7). `animationTick` with `rnd` = the level random:

1. `b = sin((tickCount + 35) * 0.1) / 2 + 0.5` (f32; `Mth.sin`), `b = (b * b + b) * 0.3` (f32 then double). The anchor is `(px + 0.5, py + 1.5 + b, pz + 0.5)`.
2. For each frame block position `F` in the list: `if rnd.nextInt(50) != 0` skip it; else `d = F - pos` (block offsets), the offset vector `(−0.5 + rnd.nextFloat() + d.x, −2.0 + rnd.nextFloat() + d.y, −0.5 + rnd.nextFloat() + d.z)` (f32, x then y then z), and add `nautilus` at the anchor with that offset as the velocity argument.
3. If there is a hunting target entity: `eye = (target.x, target.eyeY, target.z)`; `ox = (−0.5 + rnd.nextFloat()) * (3.0 + bbWidth)`, `oy = −1.0 + rnd.nextFloat() * bbHeight`, `oz = (−0.5 + rnd.nextFloat()) * (3.0 + bbWidth)` (f32; draw order x, y, z); add `nautilus` at `eye` with velocity `(ox, oy, oz)`.

By section 6.3 the first form converges onto the conduit anchor from the frame blocks; the second converges onto the target's eye from a point at the offset.

### 9.4 Squid ink (server): `Squid.spawnInk`, `GlowSquid`

`getInkParticle` is `squid_ink` for a squid and `glow_squid_ink` for a glow squid. `spawnInk` (the server side of the squid's ink burst): play the squirt sound; `origin = rotate((0, -1, 0)) + position` where `rotate(v) = yRot(-yBodyRotO in radians)(xRot(xBodyRotO in radians)(v))` (`xBodyRotO`, `yBodyRotO` are the body rotations of the previous tick). Then 30 times: `dir = rotate((r1 * 0.6 - 0.3, -1.0, r2 * 0.6 - 0.3))` (`r1`, `r2` are `nextFloat` of the squid's random source, widened; r1 drawn first), `k = (baby ? 0.1 : 0.3)` (f32), `vel = dir.scale(k + r3 * 2)` (`r3` a third float draw per iteration), then `ServerLevel.sendParticles(inkParticle, origin.x, origin.y + 0.5, origin.z, count 0, vel.x, vel.y, vel.z, speed 0.1)`. With `count = 0` the client takes the packet's offsets as a velocity: `ClientPacketListener.handleParticleEvent` computes `(maxSpeed * xDist, maxSpeed * yDist, maxSpeed * zDist)` as the velocity and spawns one particle at the exact packet position (the other branches of the handler, with randomised positions, are the particle-packet doc 05a 0x30 and part 1). So each ink particle has a velocity of `0.1 * vel`.

### 9.5 Fishing hook (server): `FishingHook.catchingFish` particles

Runs on the server while the bobber is in water (the timers and the catch are the fishing-mechanics docs). Positions `(px, py, pz)` below are always computed as follows; `fishAngle` and the timers are fields of the hook. The three phases:

| Phase | Condition | Particles |
|---|---|---|
| Fish approaching | `timeUntilHooked > 0` after being decremented and still `> 0` | `fishAngle += triangle(0, 9.188)` (the random source's `triangle(centre, spread)`); `a = fishAngle * 0.017453292`, `s = sin(a)`, `c = cos(a)`; `(px, py, pz) = (hook.x + s * timeUntilHooked * 0.1, floor(hook.y) + 1, hook.z + c * timeUntilHooked * 0.1)`; only if the block at `(px, py - 1, pz)` is water: with probability 15% (`nextFloat() < 0.15`) send `bubble` at `(px, py - 0.1, pz)`, count 1, offsets `(s, 0.1, c)`, speed 0; then send `fishing` at `(px, py, pz)` twice, count 0, speed 1.0, with offsets `(c * 0.04, 0.01, -s * 0.04)` and `(-c * 0.04, 0.01, s * 0.04)` (so velocity equals the offsets). |
| Bite | `timeUntilHooked` reaches 0 | the splash sound, then `bubble` and `fishing` at `(hook.x, hook.y + 0.5, hook.z)` each with count `(int)(1 + bbWidth * 20)`, offsets `(bbWidth, 0, bbWidth)`, speed 0.2; then `nibble = nextInt(20, 40)` and the biting flag. |
| Lure | `timeUntilLured > 0`, per tick | `p = 0.15`, `+ (20 - t) * 0.05` when `t < 20`, else `+ (40 - t) * 0.02` when `t < 40`, else `+ (60 - t) * 0.01` when `t < 60`, with `t = timeUntilLured`; if `nextFloat() < p`: `angle = nextFloat(0, 360) * 0.017453292`, `dist = nextFloat(25, 60)` (the angle draw is first); `(px, py, pz) = (hook.x + sin(angle) * dist * 0.1, floor(hook.y) + 1, hook.z + cos(angle) * dist * 0.1)`; if the block at `(px, py - 1, pz)` is water: send `splash` at `(px, py, pz)`, count `2 + nextInt(2)`, offsets `(0.1, 0, 0.1)`, speed 0. |

Counts above zero use the packet's randomised path: all three `ServerLevel.sendParticles` overloads used here pass `RandomizationType.DEFAULT` (read), which is mode 0 of 05a Level Particles and is described in part 1. On the client each particle then takes six `nextGaussian` draws, offsets first and velocities after: position = packet position + gaussian * offset distance per axis, velocity = gaussian * maxSpeed per axis. This is the path of the counted `bubble`, `fishing` (bite) and `splash` sends and of the squid-ink case of 9.4 with count 0 (where the velocity is `maxSpeed * dist` instead, read per axis).

### 9.6 Dolphin (`Dolphin.tick`, client side only)

Condition: the level is the client, the dolphin is in water and `deltaMovement.lengthSqr() > 0.03`. Let `v = getViewVector(0)`, `a = cos(yRot * 0.017453292) * 0.3` (f32), `b = sin(yRot * 0.017453292) * 0.3`, `d = 1.2f - r * 0.7f` (one `nextFloat` of the dolphin's random source, drawn once). The loop counter runs 0 and 1 (two passes) and EACH pass adds BOTH particles, in this order, with the single `d` draw made before the loop: first at `(x - v.x * d + a, y - v.y, z - v.z * d + b)`, then at `(x - v.x * d - a, y - v.y, z - v.z * d - b)`; the velocity argument is zero for all of them. The result is 4 `dolphin` particles per qualifying tick, as two identical pairs (the pass index is not used in the coordinates). `Mth.cos` and `Mth.sin` are the table functions of 5.6. (Read.)

### 9.7 Other emitters of scope types

Splash and bubble effects of generic entities (entity in or out of water, boats, wolves, villagers, potions, dispensers, arrows, thrown projectiles, guardians, the eye of ender, nautilus mobs) are in part 7; the particle behaviours they feed are in this document. The class search showed these classes referencing `bubble` or `splash`: `Entity`, `LivingEntity`, `AbstractBoat`, `FishingHook`, `Wolf`, `Villager`, `PotionItem`, `DispenseItemBehavior`, `AbstractNautilus`, `Squid$SquidFleeGoal`, `Guardian`, `EyeOfEnder`, `ThrowableProjectile`, `AbstractArrow`, `AbstractHurtingProjectile`.

### 9.8 Sulfur bubbles (`PotentSulfurBlock.animateTick`)

Return if the `state` property equals `dry`. Return unless the fluid state above the block is a water source. Then call the helper `spawnBubbleParticlesAt(level, scanRandom, bx, by + 1, bz)` twice. The helper adds `sulfur_bubbles` through `addAlwaysVisibleParticle` at `(x + nextFloat(), y + nextFloat(), z + nextFloat())` (float draws from `scanRandom` widened to double, order x, y, z) with velocity `(0, 0, 0)`. After the two calls, when `scanRandom.nextInt(10) == 0`, play `NOXIOUS_GAS` (AMBIENT) at `(bx, by, bz)` with volume 1.0 and pitch 1.0, no distance delay.

### 9.9 Glow squid (`GlowSquid.aiStep`, emitter of `glow`)

`GlowSquid.aiStep` runs `Squid.aiStep`, then reads the dark-ticks field (`getDarkTicksRemaining`) and, if it is above 0, writes it back decreased by 1 (`setDarkTicks`; `hurtServer` sets it to 100 when the damage was taken). Then, on every call with no random gate and regardless of the dark ticks, it calls `Level.addParticle(glow, getRandomX(0.6), getRandomY(), getRandomZ(0.6), 0, 0, 0)`. The position is a random point in the entity's bounding box, read from `Entity`: `getRandomX(s) = getX((2 * r - 1) * s)` with `getX(k) = x + bbWidth * k` (so x ranges over `x +- 0.6 * bbWidth`; `getRandomZ` is the same with `getZ` and `bbWidth`, a separate `nextDouble` of the entity's random source per axis), and `getRandomY() = getY(r)` with `getY(k) = y + bbHeight * k` (so y ranges over `y` to `y + bbHeight`). The draw order is x, y, z, from the entity's own random source. The zero velocity is then replaced by the glow provider's randomisation (section 8). The type `glow` is outside the 30-type scope list of the Covers line and is covered here by its class (section 8) and this emitter.

## 10. Worked examples

1. **A lava drip, full life.** A lava block at `(10, 64, 10)` is sampled with `nextInt(10) == 0`; the block below at `(10, 63, 10)` is air with `sturdy = true` for the lava block's DOWN face. Step 3 of 4.4 does not apply (an empty block has collision `maxY` 0, below 1), and `sturdy` is true, so the particle spawns across the cell of the block below at `y = 63 + 1 - 0.05 = 63.95`, with x and z uniform in `[10, 11)`. The class is `CoolingDripHangParticle` (40 ticks, colour `(1, 16/(56 - L), 4/(48 - L))`). After 40 ticks it creates `falling_lava` at about `y = 63.95 - 0.047 = 63.90`; that particle falls as in the section 3.8 table (6 ticks for a 1-block drop); on landing it creates `landing_lava`, whose lifetime is 16 to 80 ticks, and is removed with it.
2. **A leaf drip.** On a rainy tick a leaf block at `(0, 70, 0)` is sampled; the block above is exposed to rain; `nextInt(15) == 1` holds; the block below is air. The particle `dripping_water` appears at `(rd(), 69.95, rd())`, hangs 40 ticks, then becomes `falling_water`, lands on `splash` at the floor (the splash velocity is zero with `vy = 0` and `vx = vz = 0`, so the random water-drop velocity applies: `xd` is 0.3 of the normalised draw, `yd` 0.1 to 0.3, gravity 0.04).
3. **A bubble column.** An upward column block at `(5, 60, 5)` emits two `bubble_column_up` per tick at `(5.5, 60, 5.5)` and a random point in the cell, both with velocity `(0, 0.04, 0)`. Each particle's `yd` starts at `0.04 * 0.2 + (r*2 - 1) * 0.02 = 0.008 +- 0.02`, reaches 0.0283 per tick in steady state (section 5.5), and is removed within 40 to 200 ticks or when it leaves water.
4. **A dolphin trail.** A dolphin moving at 0.2 blocks per tick (`lengthSqr = 0.04 > 0.03`) facing yaw 0 (`cos 0 = 1`, `sin 0 = 0`): `a = 0.3`, `b = 0`; with `d = 1.2` the pair is at `(x - v.x * 1.2 + 0.3, y - v.y, z - v.z * 1.2)` and `(x - v.x * 1.2 - 0.3, y - v.y, z - v.z * 1.2)`, and the same pair is spawned a second time in the second loop pass, so 4 particles appear that tick (two coincident pairs, each with its own lifetime and colour draws). Each lives 10 to 50 ticks (the halved lifetime), is blue-grey with alpha `1 - r * 0.7` and drifts at 0.02 of its normalised random velocity.

## 11. Validation

A conforming implementation should satisfy these checks (each derived from a section above):

1. **Registry coverage:** the 30 scope types plus `glow` (31 rows in section 2; `glow` is outside the scope list but covered by its class in section 8 and the emitter 9.9) resolve to the ids and providers of section 2; `squid_ink` and `glow_squid_ink` have the override-limiter flag, and so does `glow`; the other 28 do not (the flag is true for exactly those three, section 2).
2. **Hang times:** a `dripping_water`, `dripping_lava`, `dripping_dripstone_*` particle spawns its follow-up on tick 40 exactly; `dripping_honey` and `dripping_obsidian_tear` on tick 100; the follow-up appears at the hang particle's position of that tick.
3. **Fall dynamics:** a falling drop of gravity 0.06 has cumulative drops 0.06, 0.1788, 0.355224, 0.58811952, 0.8763571296, 1.2188299870 after ticks 1 to 6 (section 3.8). Honey and obsidian-tear falls use gravity 0.01; nectar 0.007; spore blossom 0.005.
4. **Landing:** a `FallAndLandParticle` spawns its landing particle (and for the dripstone and honey classes plays the sound) on the first tick in which `move` set `onGround`, never on lifetime expiry. `falling_nectar` and `falling_spore_blossom` spawn nothing.
5. **Lifetimes:** `FallAndLand` 64 to 320, `DripLand` 16 to 80, `landing_honey` 128 to 640, `landing_obsidian_tear` 28 to 140, `falling_nectar` 16 to 80, `bubble` 8 to 40, `bubble_column_up` 40 to 200, `underwater` 16 to 80, `dolphin` 10 to 50, `nautilus` 30 to 39, `current_down` 30 to 89, `squid_ink` 6 to 30, `bubble_pop` exactly 4.
6. **Cooling colour:** `dripping_lava` and `dripping_dripstone_lava` have `rCol = 1`, `gCol = 16 / (56 - L)`, `bCol = 4 / (48 - L)` at the start of tick, with `L` the remaining lifetime (section 3.8 table).
7. **Colours:** water drips `(0.2, 0.3, 1.0)`; honey hang `(0.622, 0.508, 0.082)`, fall `(0.582, 0.448, 0.082)`, land `(0.522, 0.408, 0.082)`; obsidian `(0.51171875, 0.03125, 0.890625)` and emissive (block light 15); nectar `(0.92, 0.782, 0.72)`; spore blossom `(0.32, 0.5, 0.22)`; underwater `(0.4, 0.4, 0.7)`; dolphin `(0.3, 0.5, 1.0)`; glow ink `(0.2, 0.8, 0.6)`.
8. **Friction and gravity styles:** drip classes subtract the gravity field directly and multiply the velocity by 0.98; `bubble` adds 0.002 and multiplies by 0.85; water drops subtract gravity directly and multiply by 0.98; the base `tick` (bubble column, sulfur bubbles, ink, glow) uses `0.04 * gravity`.
9. **Water removal:** `bubble`, `bubble_column_up` and `current_down` are removed on the tick they find no `water`-tag fluid at their block; `sulfur_bubbles` additionally require a source and stop at 3 blocks above the start.
10. **Emitters:** per tick 1334 sampled positions (667 each for r = 16 and r = 32) from the player's block; the water and lava probabilities `1/64` (ambient sound), `1/10` (`underwater`), `1/100` (lava pop), `1/200` (lava sound); leaves `1/15` while raining; crying obsidian `1/5`; beehive passes continue with probability 0.7; pointed dripstone at most 0.12.
11. **Rain count:** for `R = 10` and full rain, `(int)(0.225f * 441 * 1 * 1) = 99` attempts per tick (halved to 49 in DECREASED); none in MINIMAL.
12. **Dolphin:** a moving dolphin in water (`lengthSqr > 0.03`) spawns 4 `dolphin` particles per tick, as two identical pairs (9.6); a glow squid spawns 1 `glow` particle per tick (9.9).
13. **Packet path:** a `count = 0` particle packet gives velocity `maxSpeed * offset` per axis (squid ink: factor 0.1).

## Open questions

1. Resolved (read): the frame counts are tabulated in section 2 from `particles/<name>.json`. What remains: `SpriteSet.get(random)` consumes a draw from the provider's random even when `n = 1` (`nextInt(1)`), which only matters for exact random-stream replay. The animation consequences are stated in section 2 (fishing never shows frame 3, bubble_pop never frame 4).
2. Resolved (read): `Mth.randomBetween(random, a, b)` is `random.nextFloat() * (b - a) + a` in f32; used for the honey and dripstone landing volumes (0.3 to 1.0) and the spore-blossom lifetime divisor (0.1 to 0.9). Nothing remains open.
3. `Direction.getRandom(rs)` = `Util.getRandom(Direction.VALUES, rs)` = `array[rs.nextInt(array.length)]` (read): one `nextInt(6)`, uniform. Only the order of the `Direction.VALUES` array was not read; it matters only for exact random-stream replay of the wet sponge and crying obsidian emitters.
4. `Mth.sin` and `Mth.cos` (used by `current_down`, the conduit bob, the dolphin and the fishing hook) are read as lookup-table functions (5.6). Only the contents of the `SIN[]` table were not read; add them only if an exact table is required.
5. `LightCoordsUtil.addSmoothBlockEmission`, `smoothBlock`, `smoothSky` and `smoothPack` are read in full (6.3). Not read: how the renderer converts the smooth 0 to 240 scale to the final lightmap lookup (12).
6. `SulfurBubbleParticle` takes its second horizontal velocity input from the provider's `vy` argument. All known emitters pass zero; whether the particle-packet or command path can pass non-zero values is the packet doc's question (05a).
7. `ConduitBlockEntity.clientTick` (read) calls `updateShape` and `updateHunting` only when the game time is a multiple of 40, then `animationTick` every tick, so the list is whatever `updateShape` last produced; what `updateShape` leaves in the list for an incomplete frame was not read. The hunting target selection and the frame update are conduit mechanics, not covered here.
8. Resolved (read): `Entity.getY(scale)` is `y + bbHeight * scale`, `getX(scale)` is `x + bbWidth * scale`.
9. Resolved (read): `Level.addParticle` (both overloads) has an empty body and `ServerLevel` does not override it, so the server-side `addParticle` calls of the bee and the glow squid do nothing, and the dolphin's client guard is redundant. Nothing remains open.
10. The rain sound branch of `tickWeatherEffects`, the biome precipitation rules (`getPrecipitationAt`) and `getRainLevel(1.0)` are in the world docs and were not repeated; the thread-local random is unseeded in `animateTick` but seeded from the game time in `tickWeatherEffects`, so only the latter is reproducible.
11. `ParticleEngine.createParticle`/`add`, the particle limit (`getParticleLimit`), the `addParticle` distance gate (1024 blocks squared for non-forced particles) and `ParticleStatus` sampling are summarised in part 1. For reference, `ClientLevel.calculateParticleLevel(forced)` (read): if the call is forced and the option is MINIMAL, the result is DECREASED with probability 1 in 10 (`nextInt(10) == 0`); then, if the (possibly changed) status is DECREASED, the result is MINIMAL with probability 1 in 3 (`nextInt(3) == 0`). `addParticle` drops the particle when the final status is MINIMAL (non-forced path, after the 1024 distance gate), so DECREASED keeps about two thirds; see part 1 for the rest; this document only relies on `addParticle` and `addAlwaysVisibleParticle`.
12. Pointed dripstone: the `column` arguments are read (4.3, class `SpeleothemBlock`); only the pixel-to-block division by 16 inside `Block.box` is (inferred), so `0.3125` and `0.125` rest on it.
13. Part 7 was checked for the 9.7 emitter list: every listed class except `Squid$SquidFleeGoal` by that name is present, and the flee goal is its row 6.21; the `default_dripstone_particle` default comes from 23 (part 4 does not state it).
