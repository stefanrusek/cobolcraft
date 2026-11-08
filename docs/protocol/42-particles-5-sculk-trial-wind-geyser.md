# 42. Particles, part 5: sculk, trial, wind, vault, sulfur and geyser particles

| | |
|---|---|
| Covers | The behaviour of 28 particle types (24 that have a particle definition file and 4 plain types without one; the table in 1.2 has 29 rows because it also lists `elder_guardian`, which 42-1 owns) and their particle classes, with their emitters: `sculk_soul`, `sculk_charge`, `sculk_charge_pop`, `shriek`, `sonic_boom`, `vibration`, `trail`, `gust`, `small_gust`, `gust_emitter_large`, `gust_emitter_small`, `dust_plume`, `trial_spawner_detection`, `trial_spawner_detection_ominous`, `vault_connection`, `ominous_spawning`, `raid_omen`, `trial_omen`, `noxious_gas`, `noxious_gas_cloud`, `geyser`, `geyser_base`, `geyser_poof`, `geyser_plume`, and, besides those 24 names, the four types that 42-1 section 2 assigns to this part (`sulfur_bubbles`, `pause_mob_growth`, `reset_mob_growth`, `sulfur_cube_goo`; `elder_guardian` is already specified in 42-1 section 5.9). The 24 names listed first include the four plain types (`gust_emitter_large`, `gust_emitter_small`, `geyser`, `noxious_gas_cloud`); 24 + 4 = 28 types, of which 24 have definition files. For each: provider, constructor draws, tick, size, colour, light, layer, and the places that emit it (level events, block entities, entities, server packets), with worked examples and a validation table. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.client.particle` (`SculkChargeParticle`, `SculkChargePopParticle`, `ShriekParticle`, `SonicBoomParticle`, `HugeExplosionParticle`, `VibrationSignalParticle`, `TrailParticle`, `GustParticle`, `GustSeedParticle`, `DustPlumeParticle`, `TrialSpawnerDetectionParticle`, `FlyTowardsPositionParticle`, `FlyStraightTowardsParticle`, `NoxiousGasParticle`, `NoxiousGasCloudParticle`, `GeyserBaseParticle`, `GeyserEruptionParticle`, `GeyserPlumeParticle`, `EmissiveRisingParticle`, `SulfurBubbleParticle`, the providers of `SimpleVerticalParticle`, `BreakingItemParticle` (sulfur cube) and `SpellParticle`, `Particle$LifetimeAlpha`, `ParticleResources` registrations), `ParticleUtils`, `LightCoordsUtil`, `ARGB`, `Mth`, `Vec3`, `LevelEventHandler`, `TrialSpawner`, `VaultBlockEntity$Client`, `OminousItemSpawner`, `SculkCatalystBlockEntity$CatalystListener`, `DecoratedPotBlock`, `PotentSulfurBlock`, `PotentSulfurBlockEntity`, `AgeableMob`, `SonicBoom` (warden), `VibrationSystem$Ticker`, `CreakingHeartBlockEntity`, `EyeblossomBlock$Type`, `WindCharge`, `BreezeWindCharge`, `WindChargedMobEffect`, `MultifaceBlock`, `SculkShriekerBlock`; added in the review revision: `VaultConfig`, `VaultSharedData`, `VaultState` and its constant bodies, `UniformInt`, `Direction`, `Block` (box and column helpers). |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-15). The particle definition files (`assets/minecraft/particles/<name>.json`, sprite lists) are data that the extraction tool copies (42-1 section 9): not tabulated here. This part specifies the engines (classes) and the emission sites. Sound is out of scope (sound names are cited only to locate code). |

Cross-references: `42-N section X` is section X of the document `42-particles-N-*` (N = 1 shared model and engine, 2 effects, fire, smoke and magic, 3 fluid drips and water, 4 block, item, dust and ambient, 6 emitters driven by blocks, 7 emitters for entities, events and commands); a bare number such as 4.3 is a section of this document. Conventions are those of 42-1 section 1 and its base classes (42-1 section 4 and section 8): `Particle` fields, `Particle.tick` (4.2), `Particle.move` (4.4), the velocity-jitter constructor (4.1), `SingleQuadParticle` (4.3), `RisingParticle` (8.1), `BaseAshSmokeParticle` (8.5), `SimpleVerticalParticle` (8.3), the entry paths (7.1) and the Level Particles packet (7.2), each as 42-1 section N.M. This document does not repeat them. `f32` marks a single-precision quantity. "Draw" means one call of the particle's own `RandomSource` (the provider uses the engine's, a few emitters use the level's; each case is stated). Where a base constructor is cited, its draws come first (4.1: 5 draws and the lifetime draw for a constructor with velocity, 1 draw for a constructor without; then the `SingleQuadParticle` quad-size draw).

"Override" below is the registration's override-limiter flag from the table of 42-1 section 2 (when it is yes the particle skips the distance and status tests of 42-1 section 7.1).

## 1. Partition, leftover check, and shared helpers

### 1.1 Which classes belong to this part

The `net.minecraft.client.particle` package has 230 class files (counted with `unzip -Z1 ... | grep -v '/$'`): 88 top-level (87 classes and `package-info`) and 142 nested. The leftover check against the class list was done as follows. Claimed here: the 20 top-level classes read in the Method line plus nested providers. Claimed by 42-1: `Particle`, `ParticleDescription`, `ParticleEngine`, `ParticleGroup`, `ParticleProvider`, `ParticleRenderType`, `ParticleResources`, `SingleQuadParticle`, `SpriteSet`, `QuadParticleGroup`, `NoRenderParticle`, `NoRenderParticleGroup`, `TrackingEmitter`, `ItemPickupParticle`, `ItemPickupParticleGroup`, `ElderGuardianParticle`, `ElderGuardianParticleGroup`, `SimpleAnimatedParticle`, `SimpleVerticalParticle`, `RisingParticle`, `FallingParticle`, `BaseAshSmokeParticle`. The 45 top-level classes left, which belong to 42-2 to 42-4 and are not specified here: `AshParticle`, `AttackSweepParticle`, `BlockMarker`, `BreakingItemParticle` (class; only its sulfur-cube provider is here, 2.20), `BubbleColumnUpParticle`, `BubbleParticle`, `BubblePopParticle`, `CampfireSmokeParticle`, `CritParticle`, `DragonBreathParticle`, `DripParticle`, `DustColorTransitionParticle`, `DustParticle`, `DustParticleBase`, `EndRodParticle`, `ExplodeParticle`, `FallingDustParticle`, `FallingLeavesParticle`, `FireflyParticle`, `FireworkParticles`, `FlameParticle`, `GlowParticle`, `HeartParticle`, `HugeExplosionSeedParticle`, `LargeSmokeParticle`, `LavaParticle`, `NoteParticle`, `PlayerCloudParticle`, `PortalParticle`, `ReversePortalParticle`, `SmokeParticle`, `SnowflakeParticle`, `SpellParticle` (class; only the `raid_omen` and `trial_omen` registration is here, 2.19), `SpitParticle`, `SplashParticle`, `SquidInkParticle`, `SuspendedParticle`, `SuspendedTownParticle`, `TerrainParticle`, `TotemParticle`, `WakeParticle`, `WaterCurrentDownParticle`, `WaterDropParticle`, `WhiteAshParticle`, `WhiteSmokeParticle`. Each of the 45 names appears in at least one of 42-2, 42-3 and 42-4 (checked by searching those three documents for each class name; Open question 1). `HugeExplosionParticle` is read here because `SonicBoomParticle` extends it (2.5); 42-2 section 3.12 also specifies it (the `explosion` type), and the two descriptions must agree (Open question 1).

### 1.2 Table of types

Ids, providers, sprite counts and override flags are from 42-1 section 2 (not re-derived, except the registrations of the two gust emitters in 2.9 and the provider arguments, which were read in `ParticleResources`).

| Id | Type | Option kind | Override | Class that holds the behaviour | Section |
|---|---|---|---|---|---|
| 4 | `sulfur_bubbles` | simple | no | `SulfurBubbleParticle` | 2.17 |
| 5 | `noxious_gas` | simple | no | `NoxiousGasParticle` (base `BaseAshSmokeParticle`) | 2.14 |
| 6 | `noxious_gas_cloud` | simple | no | `NoxiousGasCloudParticle` (`NoRenderParticle`) | 2.15 |
| 7 | `geyser` | geyser | yes | `GeyserEruptionParticle` (`NoRenderParticle`) | 2.16 |
| 8 | `geyser_base` | geyser-base | yes | `GeyserBaseParticle` (`BaseAshSmokeParticle`) | 2.16 |
| 9 | `geyser_poof` | geyser-base | yes | `GeyserBaseParticle` | 2.16 |
| 10 | `geyser_plume` | geyser | yes | `GeyserPlumeParticle` | 2.16 |
| 24 | `elder_guardian` | simple | yes | `ElderGuardianParticle` | 42-1 section 5.9 |
| 31 | `gust` | simple | yes | `GustParticle` | 2.8 |
| 32 | `small_gust` | simple | no | `GustParticle` (small provider) | 2.8 |
| 33 | `gust_emitter_large` | simple | yes | `GustSeedParticle` | 2.9 |
| 34 | `gust_emitter_small` | simple | yes | `GustSeedParticle` | 2.9 |
| 35 | `sonic_boom` | simple | yes | `SonicBoomParticle` | 2.5 |
| 47 | `sculk_soul` | simple | no | `EmissiveRisingParticle` (base `RisingParticle`) | 2.1 |
| 48 | `sculk_charge` | sculk-charge | yes | `SculkChargeParticle` | 2.2 |
| 49 | `sculk_charge_pop` | simple | yes | `SculkChargePopParticle` | 2.3 |
| 58 | `vibration` | vibration | yes | `VibrationSignalParticle` | 2.6 |
| 59 | `trail` | trail | no | `TrailParticle` | 2.7 |
| 60 | `pause_mob_growth` | simple | no | `SimpleVerticalParticle` | 2.18 |
| 61 | `reset_mob_growth` | simple | no | `SimpleVerticalParticle` | 2.18 |
| 115 | `shriek` | shriek | no | `ShriekParticle` | 2.4 |
| 117 | `dust_plume` | simple | no | `DustPlumeParticle` (base `BaseAshSmokeParticle`) | 2.10 |
| 118 | `trial_spawner_detection` | simple | yes | `TrialSpawnerDetectionParticle` | 2.11 |
| 119 | `trial_spawner_detection_ominous` | simple | yes | `TrialSpawnerDetectionParticle` | 2.11 |
| 120 | `vault_connection` | simple | yes | `FlyTowardsPositionParticle` | 2.12 |
| 122 | `ominous_spawning` | simple | yes | `FlyStraightTowardsParticle` | 2.13 |
| 123 | `raid_omen` | simple | no | `SpellParticle` | 2.19 |
| 124 | `trial_omen` | simple | no | `SpellParticle` | 2.19 |
| 127 | `sulfur_cube_goo` | simple | no | `BreakingItemParticle` (sulfur provider) | 2.20 |

(Section numbering below follows reading order, not id order.)

### 1.3 Shared helpers read in this round

These are used by several particles below.

**Light, `LightCoordsUtil`.** A packed light value has a block level in bits 4 to 7 and a sky level in bits 20 to 23 (the "block" and "sky" getters shift by 4 and 20 and mask 15). Constants read: `FULL_BRIGHT` = 15728880 (`0xF000F0`), `FULL_SKY` = 15728640. Two operations matter here:
- `withBlock(light, level)` keeps only bits 16 to 23 of `light` (the mask is 16711680, `0xFF0000`) and sets the block level to `level << 4`. Applied with 15 it yields "block light 15, sky light unchanged": **"emissive"** below.
- `addSmoothBlockEmission(light, e)`: `e` is clamped to [0, 1]; `add = (int)(e * 240)` (f32 product, truncated); the smooth block value is `min(smoothBlock(light) + add, 240)` where `smoothBlock` is the low 8 bits of `light`; the result is `smoothPack(block, smoothSky(light))`, whose block part is the low 8 bits and sky part is bits 16 to 23. So the block light is raised by up to 240 on a 0 to 240 scale. Used by 2.12.

**`ARGB`.** `scaleRGB(color, fr, fg, fb)` multiplies each of the red, green and blue bytes of `color` by its factor (as f32), truncates to int, clamps to 0 to 255, and keeps the alpha byte. `srgbLerp(t, a, b)` interpolates each of the four bytes independently as `a + floor(t * (b - a))` (`Mth.lerpInt`; no gamma conversion despite the name). `red/green/blue/alpha(c)` are the four bytes; a channel float is byte / 255.0.

**`Mth`.** `lerp(t, a, b)` is `a + t * (b - a)` (the double version used for positions). `randomBetween(rng, a, b)` is one `nextFloat` r with the result `r * (b - a) + a` (f32). `nextInt(rng, a, b)` with a < b is `a + nextInt(b - a + 1)` (one draw); `nextDouble(rng, a, b)` returns `a` if a >= b, else `a + r * (b - a)` with one `nextDouble` r (read). `randomBetweenInclusive(rng, a, b)` is `a + nextInt(b - a + 1)` (one draw; read). `UniformInt.sample(rng)` is `randomBetweenInclusive(rng, minInclusive, maxInclusive)` (read). `clampedLerp(t, a, b)`: a when t < 0, b when t > 1, else `lerp(t, a, b)`. `inverseLerp(v, a, b)` is `(v - a) / (b - a)` (read; the float and double versions agree).

**`Vec3` helpers.** `offsetRandom(rng, s)` adds to each component `(nextFloat - 0.5) * s` (three draws in x, y, z order; f32 product widened). `vectorTo(p)` is `p - this`. `atCenterOf(blockPos)` is block + (0.5, 0.5, 0.5); `atBottomCenterOf` is block + (0.5, 0, 0.5); `atLowerCornerOf` is the block corner.

**`ParticleUtils` face emission.** Used by the sculk charge level event (3.1).
- `spawnParticlesOnBlockFace(level, pos, options, count provider, face, velocity supplier, offset)`: draw `n = count.sample(level random)` (one sampling of the `IntProvider`), then repeat n times: call the supplier (it returns a vector; each call draws), then `spawnParticleOnFace`.
- `spawnParticleOnFace(level, pos, face, options, speed vector, offset)`: let c = block centre, (sx, sy, sz) the face's step vector. For each axis in x, y, z order: if the step on that axis is 0 the coordinate is `c + Mth.nextDouble(rng, -0.5, 0.5)` (one draw), else `c + step * offset`. Then the velocity: for each axis, if the step is 0 the speed vector's component on that axis, else 0. The level random is used for the position draws. The particle is added by the normal entry (`addParticle`, 42-1 section 7.1). So a particle is placed on the face, spread over the face, offset `offset` blocks beyond the block centre along the normal, and moves only tangentially.
- `getRandomSpeedRanges` (default supplier of `spawnParticlesOnBlockFaces`) is three `Mth.nextDouble(rng, -0.5, 0.5)`; `spawnParticlesOnBlockFaces` uses offset 0.55 for all six faces. Neither is used by the particles of this part; they are listed for the parts that call them.

## 2. Per-type records

Each record lists: provider (draws before construction), constructor (draws), tick, size, colour, light, layer, velocity. Anything not mentioned is inherited from 42-1 section 4 and 8 (for example friction 0.98 and gravity 0 for a plain `SingleQuadParticle`).

### 2.1 `sculk_soul` (id 47), `EmissiveRisingParticle`

- **Provider** (`EmissiveRisingParticle$EmissiveProvider`, sprite set, 11 sprites): builds the particle with the supplied velocity, sets `alpha` 1.0, sets `isGlowing` true. No provider draws.
- **Class:** extends `RisingParticle` (42-1 section 8.1). Constructor: base constructor with velocity and the first sprite; `scale(1.5)` (quad size and box times 1.5); `setSpriteFromAge(sprites)`.
- **Tick:** `RisingParticle.tick`, then `setSpriteFromAge(sprites)`.
- **Light:** when `isGlowing` (always true for this provider) the light is the default light with the block level forced to 15 (`withBlock(light, 15)`); otherwise the default light.
- **Layer:** `TRANSLUCENT`.
- **Emitter:** the sculk catalyst "bloom" (4.3).

### 2.2 `sculk_charge` (id 48), `SculkChargeParticle`

- **Options:** `SculkChargeParticleOptions` (a float `roll`, radians; 42-1 section 3).
- **Provider** (`SculkChargeParticle$Provider`, a record over the sprite set; 7 sprites): constructs the particle from the supplied velocity, then in this order: `alpha` = 1.0; `setParticleSpeed(vx, vy, vz)` (exact overwrite of `xd, yd, zd`, discarding the constructor's jitter); `oRoll` = `roll` and `roll` = `roll` (both the option value, so the roll is constant); `setLifetime(8 + nextInt(12))` with one draw of the **engine's** random after the constructor, so lifetime is 8 to 19.
- **Constructor:** base constructor with velocity and the first sprite (so 6 draws + 1 quad-size draw); `friction` = 0.96; `scale(1.5)`; `hasPhysics` = false; `setSpriteFromAge(sprites)`. Gravity stays 0.
- **Tick:** `SingleQuadParticle` base tick (4.2; friction applies to the exact velocity), then `setSpriteFromAge`.
- **Light:** the default light with block level forced to 15 (`withBlock(light, 15)`).
- **Layer:** `TRANSLUCENT`. Roll is applied by the standard rule of 42-1 section 4.3 (rotation about the local Z axis by `lerp(partial, oRoll, roll)`), so the quad is drawn rotated by `roll` radians.
- **Emitter:** level event 3006 (3.1).

### 2.3 `sculk_charge_pop` (id 49), `SculkChargePopParticle`

Identical to 2.2 except: no options (simple type), no roll (stays 0), `scale(1.0)` (so the quad size is the base draw only), lifetime `6 + nextInt(4)` (6 to 9; one draw of the engine's random after construction), 4 sprites. Provider order: construct, `alpha` 1.0, `setParticleSpeed(vx, vy, vz)`, `setLifetime`. Light emissive, layer `TRANSLUCENT`, friction 0.96, `hasPhysics` false, sprite by age (constructor and each tick).
- **Emitter:** level event 3006 with zero charge (3.1).

### 2.4 `shriek` (id 115), `ShriekParticle`

- **Options:** `ShriekParticleOption(delay)` (a VarInt, ticks; 42-1 section 3).
- **Provider** (`ShriekParticle$Provider`, 1 sprite): draws one sprite with `SpriteSet.get(random)` (engine's random, before the constructor), constructs the particle with the option's delay, sets `alpha` 1.0.
- **Constructor** `(level, x, y, z, delay, sprite)`: base constructor with zero velocity (6 draws, then the quad-size draw), then: `quadSize` = 0.85 (overwrites the draw); `delay` as given; `lifetime` = 30; `gravity` = 0; `xd` = 0; `yd` = 0.1; `zd` = 0. Friction (0.98) and `hasPhysics` (true) are inherited, so the particle collides with blocks.
- **Tick:** while `delay > 0`: `delay -= 1` and nothing else (age does not advance, no movement, the particle is not drawn). When `delay` is 0 the base tick runs, so the particle then lives 30 ticks. The total movement over its life is `0.1 * sum(0.98^k)` for k = 0 to 29, which is 0.1 * (1 - 0.98^30) / 0.02 = 0.1 * (1 - 0.5455) / 0.02 = about 2.27 blocks upward (arithmetic; 0.98^30 = 0.5455; an unobstructed particle).
- **Size:** `getQuadSize(partial)` = `quadSize * clamp((age + partial) / lifetime * 0.75, 0, 1)` (f32); it grows linearly from 0 to 0.75 * 0.85 = 0.6375 over the life. The drawn square has a side of twice this (42-1 section 4.3).
- **Colour and alpha:** at each draw (`extract`), `alpha = 1 - clamp((age + partial) / lifetime, 0, 1)`; colour white. The particle is skipped entirely (nothing drawn) while `delay > 0`.
- **Geometry:** it is drawn as **two quads at the same position**, each with a fixed orientation instead of the camera's. The first quad uses the rotation about the X axis by -1.0472 rad (-60 degrees, constant `1.0472f`); the second uses a rotation of yaw -3.1415927 (-pi), pitch 1.0472, roll 0 (Euler order Y, X, Z). Both are passed to the quad builder as the facing quaternion (`extractRotatedQuad`), so the two faces are two sides of one tilted quad, visible from above and below. The tilt does not depend on where the camera is.
- **Light:** block level forced to 15 (`withBlock(light, 15)`). **Layer:** `TRANSLUCENT`.
- **Emitter:** level event 3007 (3.2): ten particles with delays 0, 5, ..., 45 at the shrieker's top.

### 2.5 `sonic_boom` (id 35), `SonicBoomParticle` (extends `HugeExplosionParticle`)

- **Base class `HugeExplosionParticle`** (read because it is shared): constructor `(level, x, y, z, size, sprites)`: `SingleQuadParticle` constructor with zero velocity and the first sprite (6 + 1 draws); `lifetime = 6 + nextInt(4)` (one draw, own random); one `nextFloat` r: `rCol = gCol = bCol = r * 0.6 + 0.4`; `quadSize = 2 * (1 - size * 0.5)` (f32; `size` is the constructor's double argument narrowed to f32); sprite from age. Light is always 15728880 (full bright). Layer `OPAQUE`. **Tick** (replaces the base): `xo, yo, zo` = position; compare the old age with the lifetime then increment (remove when old age >= lifetime); `setSpriteFromAge`. There is no movement and no gravity, so the velocity jitter is unused.
- **`SonicBoomParticle` constructor:** base constructor, then `lifetime = 16`, `quadSize = 1.5`, `setSpriteFromAge`. The provider passes the supplied x velocity as `size`, but the final quad size is the constant 1.5, so `size` has no visible effect. No provider draws (the first sprite is used, then the sprite follows the age: 16 sprites over 16 ticks).
- **Draws:** base `SingleQuadParticle` (lifetime, 5 velocity, quad size) = 7, `HugeExplosionParticle` lifetime (1), colour (1) = 9 in all; the colour draw gives a grey 0.4 to 1.0 shade (opaque layer, full bright).
- **Emitter:** the warden's sonic boom (3.8), which spawns many through the Level Particles packet.

### 2.6 `vibration` (id 58), `VibrationSignalParticle`

- **Options:** `VibrationParticleOption(destination position source, arrival ticks)` (42-1 section 3).
- **Provider** (1 sprite): draws one sprite `SpriteSet.get(random)` (engine's random), constructs with the destination source and the arrival ticks, sets `alpha` 1.0.
- **Constructor** `(level, x, y, z, target, arrival, sprite)`: base constructor with zero velocity (7 draws); `quadSize` = 0.3; `target` stored; `lifetime` = arrival. Then, if the target's position (`PositionSource.getPosition(level)`) is present, with d = (current position) - (target position): `rot = atan2(dx, dz)` and `pitch = atan2(dy, sqrt(dx^2 + dz^2))` (f32), and `rotO = rot`, `pitchO = pitch`. When the position is absent the angles stay 0.
- **Tick** (replaces the base): `xo, yo, zo` = position; compare the old age with the lifetime then increment (remove when old age >= lifetime); look the target position up again, and **remove the particle if it is absent**; let `remaining = lifetime - age` (age already incremented) and `t = 1.0 / remaining` (double); each coordinate becomes `lerp(t, current, target)`; then `rotO = rot`, `rot = atan2(current x - target x, current z - target z)` and `pitchO = pitch`, `pitch = atan2(current y - target y, sqrt(dx^2 + dz^2))`, with the offsets measured after the move. The particle thus closes 1/remaining of the remaining distance each tick. On the final live tick `remaining` is 0, so `t` is positive infinity and the position becomes non-finite (the quad is not visible for that one frame; inferred consequence of the arithmetic, Open question 2). An implementation may snap to the target on that tick; this is visually equivalent.
- **Draw:** at `extract`: `s = 2 * sin((age + partial - 2*pi) * 0.05)` (`2*pi` is the constant `6.2831855f`); `rot' = lerp(partial, rotO, rot)`; `pit' = lerp(partial, pitchO, pitch) + pi/2` (`1.5707964f`). Two quads are built from fixed quaternions: the first is `rotateY(rot')`, then `rotateX(-pit')`, then `rotateY(s)`; the second is `rotateY(-pi + rot')`, then `rotateX(pit')`, then `rotateY(s)`. So the quad lies along the line of travel, its faces turned to both sides, and it wobbles about its axis by up to +/- 2 rad as the sine of the age.
- **Size:** constant 0.3 (side 0.6). **Light:** block level 15 (`withBlock`). **Layer:** `TRANSLUCENT`. Alpha 1, white.
- **Emitter:** the vibration system ticker (3.9).

### 2.7 `trail` (id 59), `TrailParticle`

- **Options:** `TrailParticleOption(target Vec3, colour RGB24, duration)`.
- **Provider** (1 sprite): draws one sprite `SpriteSet.get(random)`, constructs with the supplied velocity, the target and the colour, then `setLifetime(duration)`. (No alpha call: alpha stays 1.)
- **Constructor** `(level, x, y, z, vx, vy, vz, target, colour, sprite)`: base constructor **with** velocity (5 + 1 draws and the quad-size draw); then three `nextFloat` draws a, b, c in this order: each of the three colour channels of `colour` is multiplied by `0.875 + a * 0.25` (red), `0.875 + b * 0.25` (green), `0.875 + c * 0.25` (blue) through `ARGB.scaleRGB` (truncated, clamped to 255); `rCol, gCol, bCol` are the resulting bytes / 255; `quadSize` = 0.26 (overwrites the draw); `target` stored.
- **Tick** (replaces the base, so the velocity is never used): `xo, yo, zo` = position; compare old age with lifetime and increment (remove when old age >= lifetime); `remaining = lifetime - age` (after the increment), `t = 1.0 / remaining`; each coordinate becomes `lerp(t, current, target)`. The same final-tick note as 2.6 applies (`remaining` is 0 on the last live tick).
- **Light:** always 15728880. **Layer:** `OPAQUE`. Size constant 0.26 (the base `getQuadSize`). Sprite: chosen once.
- **Emitters:** creaking heart (3.10) and eyeblossom (3.11): both pass the target and a duration.

### 2.8 `gust` (id 31) and `small_gust` (id 32), `GustParticle`

- **Providers:** `GustParticle$Provider` (`gust`, 12 sprites) constructs `GustParticle(level, x, y, z, sprites)` and returns it; `GustParticle$SmallProvider` (`small_gust`, 7 sprites) does the same and then calls `scale(0.15)`. The velocity arguments are ignored by both.
- **Constructor:** `SingleQuadParticle` constructor **without velocity** (lifetime draw, quad-size draw: 2 draws); first sprite then `setSpriteFromAge(sprites)`; `lifetime = 12 + nextInt(4)` (one more draw; 12 to 15 ticks); `quadSize = 1.0`; `setSize(1.0, 1.0)` (box 1 by 1). `small_gust` then scales the quad size and box by 0.15 (quad size 0.15).
- **Tick:** advance age and remove when the old age >= lifetime, then `setSpriteFromAge`; there is no movement, no gravity.
- **Light:** always 15728880. **Layer:** `OPAQUE`. Sprites: by age (so the 12-frame gust animation completes over 12 to 15 ticks; 42-1 section 6.3 for the age-to-sprite rule).
- **Draw order of random calls:** lifetime draw, quad-size draw, `nextInt(4)`.
- **Emitters:** `gust` is spawned by `gust_emitter_*` (2.9); `small_gust` is the particle of the wind charged effect (the mob effect's `particleFactory`, 3.7).

### 2.9 `gust_emitter_large` (id 33) and `gust_emitter_small` (id 34), `GustSeedParticle`

- **Registration** (`ParticleResources`): both use `GustSeedParticle$Provider(scale, lifetime, tickDelayInBetween)`: large = (3.0, 7, 0), small = (1.0, 3, 2). No sprite set (plain providers, 42-1 section 2).
- **Class:** extends `NoRenderParticle` (no drawing). Constructor `(level, x, y, z, scale, lifetime, delay)` with zero velocity; `lifetime` as given.
- **Tick** (replaces the base): if `age % (delay + 1) == 0`, three times: choose a point at `pos + (nextDouble - nextDouble) * scale` on each axis (x draws first, then y, then z; each axis uses two `nextDouble` draws of the **particle's own random**), and add a `gust` particle there through `ClientLevel.addParticle` (the normal entry) with velocity (`age / lifetime`, 0, 0) (the velocity is ignored by `GustParticle`). Then `age += 1`; when `age == lifetime` the particle removes itself.
- **Counts:** large: delay 0 means every tick, ages 0 to 6, 7 ticks, so 7 x 3 = 21 gusts; small: delay 2 means ages divisible by 3 among 0 to 2, so only age 0: 3 gusts. Each gust draw order is: x (2 draws), y (2), z (2), then the gust constructor.
- **Emitter:** explosion particle options of wind charges (3.7).

### 2.10 `dust_plume` (id 117), `DustPlumeParticle` (extends `BaseAshSmokeParticle`, 42-1 section 8.5)

- **Provider** (8 sprites): `DustPlumeParticle(level, x, y, z, vx, vy, vz, 1.0, sprites)`; no provider draws (the `scale` argument is the constant 1.0).
- **Constructor:** the `BaseAshSmokeParticle` constructor with: velocity multipliers (0.7, 0.6, 0.7); velocity add-ons (vx, vy + 0.15000000596046448, vz); `scale` as given; colour multiplier 0.5; lifetime base 7; gravity 0.5; `hasPhysics` false. After it, one `nextFloat` r: the grey of the base is replaced by the fixed colour 12235202 (RGB `0xBAB1C2`: red 186, green 177, blue 194, i.e. 0.7294, 0.6941, 0.7608) minus r * 0.2 on each of the three channels (the same r for all three: one draw, shade 0 to 0.2 darker). The base lifetime is `(int)(7 / (r2 * 0.8 + 0.2) * scale)`, at least 1 (8 to 35 for scale 1), and the size `0.75 * scale * quadSize`.
- **Tick:** each tick `gravity *= 0.88` and `friction *= 0.92` **before** the base tick (the fields compound: after n ticks gravity is 0.5 * 0.88^n and friction is 0.96 * 0.92^n); then `BaseAshSmokeParticle.tick`. So the plume bursts, decelerates strongly and falls gently.
- **Light:** default. **Layer:** `OPAQUE` (the base class). Growth of size: the `getQuadSize` of 8.5.
- **Draws:** base 7, plus the base's colour (1) and lifetime (1) draws, then this class's shade draw (1): 10.
- **Emitter:** inserting an item into a decorated pot (3.5).

### 2.11 `trial_spawner_detection` (id 118) and `trial_spawner_detection_ominous` (id 119), `TrialSpawnerDetectionParticle`

- **Provider** (5 sprites each; both types share the provider): `TrialSpawnerDetectionParticle(level, x, y, z, vx, vy, vz, 1.5, sprites)`; no provider draws.
- **Constructor** `(level, x, y, z, vx, vy, vz, scale, sprites)`: `SingleQuadParticle` constructor **with zero velocity** and the first sprite (6 + 1 draws; the velocity arguments are not passed up); `friction` = 0.96; `gravity` = -0.1 (so velocity y increases by 0.004 per tick); `speedUpWhenYMotionIsBlocked` = true; then `xd = 0`, `yd = yd * 0.9`, `zd = 0` (the jitter keeps only 90 percent of y); then `xd += vx`, `yd += vy`, `zd += vz` (the supplied velocity, which the emitter sets to 0); `quadSize *= 0.75 * scale`; `lifetime = (int)(8 / randomBetween(0.5, 1.0) * scale)` (one draw; 12 to 24 for scale 1.5), then `max(lifetime, 1)`; sprite from age; `hasPhysics` = true.
- **Tick:** the base tick, then `setSpriteFromAge`. **Size:** `getQuadSize(partial)` = `quadSize * clamp((age + partial) / lifetime * 32, 0, 1)`. **Facing:** `LOOKAT_Y` (the only particle of this part with a non-default facing; rule in 42-1 section 4.3). **Light:** block level 15. **Layer:** `OPAQUE`.
- **Which type:** the two types differ only by their sprites (data) and the emitter's choice (3.3).

### 2.12 `vault_connection` (id 120), `FlyTowardsPositionParticle`

- **Provider** (`VaultConnectionProvider`, 1 sprite): chooses one sprite `SpriteSet.get(random)` (engine's), constructs `FlyTowardsPositionParticle(level, x, y, z, vx, vy, vz, isGlowing = true, LifetimeAlpha(0.0, 0.6, 0.25, 1.0), sprite)`, then `scale(1.5)`.
- **`Particle.LifetimeAlpha`** (a record of four floats: `startAlpha`, `endAlpha`, `startAtNormalizedAge`, `endAtNormalizedAge`): `isOpaque` is true when both alphas are >= 1.0; `currentAlphaForAge(age, lifetime, partial)` is `startAlpha` when the two alphas are equal (`Mth.equal`), otherwise `clampedLerp(inverseLerp((age + partial) / lifetime, startAt, endAt), startAlpha, endAlpha)` (inverse-lerp formula read, 1.3). The shared constant `ALWAYS_OPAQUE` is (1, 1, 0, 1). Here: alpha 0 until 25 percent of the life, then rises linearly to 0.6 at the end.
- **Constructor** (the 5-arg-velocity form with a `LifetimeAlpha`): `SingleQuadParticle` constructor without velocity (lifetime draw and quad-size draw, 2 draws); `alpha` = `startAlpha` (0.0); `xd, yd, zd` = the supplied vector (exact: it is the displacement from the start); `xStart, yStart, zStart` = the spawn position; the previous and current positions are set to **start + displacement** (`xo = x = xStart + xd`, and so on), so the particle begins at the far end; `quadSize = 0.1 * (nextFloat * 0.5 + 0.2)` (one draw, f32; 0.02 to 0.07; the provider's `scale(1.5)` makes it 0.03 to 0.105); then one `nextFloat` r: `f = r * 0.6 + 0.4`; `rCol = 0.9 * f`, `gCol = 0.9 * f`, `bCol = f`; `hasPhysics` = false; `lifetime = (int)(nextFloat * 10) + 30` (one draw; 30 to 39). Draw order: lifetime, quad size (base), size, colour, lifetime.
- **Move:** `move(dx, dy, dz)` is overridden to shift the bounding box by the delta and re-derive the position (no collision).
- **Tick** (replaces the base): `xo, yo, zo` = position; compare old age with lifetime, increment (remove when old age >= lifetime); let `q = age / lifetime` (f32, after the increment), `r = 1 - q`, `p = 1 - r` (= q), `p4 = p^4` (squared twice); then `x = xStart + xd * r`; `y = yStart + yd * r - p4 * 1.2`; `z = zStart + zd * r`. The particle flies in a straight line from start + displacement to start, and on the way sags downward by up to 1.2 blocks, mostly near the end.
- **Alpha at draw:** `alpha = lifetimeAlpha.currentAlphaForAge(age, lifetime, partial)` before the quad is built.
- **Light:** when `isGlowing` (always true for this provider) the default light with block level forced to 15. (For a non-glowing instance, which this part does not create, the block light would be raised by `addSmoothBlockEmission(light, (age / lifetime)^4)`; that branch was read but no type of this part uses it.)
- **Layer:** `OPAQUE` if `LifetimeAlpha.isOpaque`, else `TRANSLUCENT`; here `TRANSLUCENT`.
- **Other providers of this class** (`EnchantProvider`, `NautilusProvider`, ids outside this part) are not specified here (Open question 3).
- **Emitter:** vault connection (3.4).

### 2.13 `ominous_spawning` (id 122), `FlyStraightTowardsParticle`

- **Provider** (`OminousSpawnProvider`, 1 sprite): chooses one sprite `SpriteSet.get(random)`, constructs `FlyStraightTowardsParticle(level, x, y, z, vx, vy, vz, startColour = -12210434, endColour = -1, sprite)`, then `scale(randomBetween(level random, 3.0, 5.0))` (one draw of the **level's** random, a factor of 3 to 5 applied to the quad size and box; `ClientLevel.getRandom`).
- **Colours:** `-12210434` is `0xFF45AEFE` (alpha 255, red 69, green 174, blue 254, a light blue); `-1` is `0xFFFFFFFF` (white). Both alpha bytes are 255.
- **Constructor:** `SingleQuadParticle` constructor without velocity (2 draws); `xd, yd, zd` = the supplied vector (exact displacement); start = spawn position; previous and current position = start + displacement; `quadSize = 0.1 * (nextFloat * 0.5 + 0.2)` (one draw); `hasPhysics` = false; `lifetime = (int)(nextFloat * 5) + 25` (one draw; 25 to 29); the two colours stored.
- **Tick** (replaces the base): `xo, yo, zo` = position; compare old age with lifetime, increment (remove when old age >= lifetime); `q = age / lifetime`, `r = 1 - q`; `position = start + displacement * r` on each axis (a straight line, no sag, no easing); the colour is `srgbLerp(q, startColour, endColour)`, applied as `setColor(red, green, blue)` (bytes / 255), and the alpha as `setAlpha(alpha / 255)` (always 1). So the colour fades from the light blue to white as the particle arrives.
- **`move`:** overridden to do nothing. **Light:** default with block level forced to 15. **Layer:** `OPAQUE`.
- **Emitter:** the ominous item spawner (3.6).

### 2.14 `noxious_gas` (id 5), `NoxiousGasParticle` (extends `BaseAshSmokeParticle`)

- **Provider** (8 sprites): `NoxiousGasParticle(level, x, y, z, vx, vy, vz, 3.0, sprites)`; no provider draws.
- **Constructor:** the `BaseAshSmokeParticle` constructor with multipliers (0.1, 0.1, 0.1), add-ons (vx, vy, vz), `scale` 3.0, colour multiplier 0.3, lifetime base 5, gravity -0.02 (rising), `hasPhysics` true. After it: colour set to white (1, 1, 1), then `lifetime = (int)(6.0 / (r * 0.5 + 0.5) * scale)` with one `nextFloat` r (18 to 36 for scale 3.0; this replaces the base lifetime), and `fadeOutStartingPoint = lifetime / 2.0` (f32, not an integer division).
- **Tick:** the base tick (friction 0.96, sprite by age), then if `age > fadeOutStartingPoint`: `alpha = (lifetime - (age - fadeOutStartingPoint)) / lifetime` (f32; 1 at the fade start, falling to 0.5 at the end of life). Before the fade starts alpha stays 1.
- **Size:** `0.75 * 3.0 * quadSize` and the growth of 8.5. **Layer:** `TRANSLUCENT` (the only particle of this section whose layer differs from the `OPAQUE` of the base). **Light:** default.
- **Draws:** 7 (base) + colour (1) + lifetime (1) + this class's lifetime (1).
- **Emitter:** the noxious gas cloud particle (2.15).

### 2.15 `noxious_gas_cloud` (id 6), `NoxiousGasCloudParticle`

- **Provider:** no sprite; `NoxiousGasCloudParticle(level, x, y, z)`.
- **Class:** extends `NoRenderParticle`; `lifetime` = 20.
- **Tick:** the `NoRenderParticle` tick (base tick: age is incremented, removal as in 4.2), then **only when the age is even** (the check is `age % 2 == 0`, using the age after the increment; so at ages 2, 4, ..., 20, i.e. 10 attempts per cloud): let `pos` be the block containing the particle position; `point = pickRandomParticleSpawnPoint(level, pos)`; if `PotentSulfurBlockEntity.canBeReachedByNoxiousGas(level, pos, point)` is true then spawn a `noxious_gas` particle at `point` with zero velocity through `Level.addAlwaysVisibleParticle` (the always-visible entry, 42-1 section 7.1).
- **`pickRandomParticleSpawnPoint(level, pos)`:** with the level's random: two `nextFloat` draws a, b (x, then z); `dir = normalize((a - 0.5, 0, b - 0.5))`; one more `nextFloat` c: `dist = c * 3.0` (f32); the point is `blockCentre(pos) + dir * dist - (0, 0.25, 0)`. (A zero vector, which would normalise to zero or NaN, was not guarded: negligible probability, Open question 4.)
- **`canBeReachedByNoxiousGas(level, source, point)`** (shared with the server logic of the sulfur block entity): with `P = block containing point`: false unless the block at P is air, water (the block `water`) or has an empty collision shape ("geyser passable"; the collision context used has the y of the block below P); false if the squared distance from `point` to the centre of `source` exceeds 9.0 (3 blocks); otherwise take `c = centre of the block below source` and `q = point with y reduced by 1.0`; true when `q` lies in a water source fluid block and a ray from `c` to `q` (block collider clip, ignoring fluids, empty collision context) does **not** hit a block.
- **Emitter:** the sulfur block entity client ticker (3.12): one cloud every 20 game ticks.

### 2.16 Geyser: `geyser` (id 7), `geyser_base` (8), `geyser_poof` (9), `geyser_plume` (10)

Options: `geyser` and `geyser_plume` carry `GeyserParticleOptions(waterBlocks)` (`w`, a positive int); `geyser_base` and `geyser_poof` carry `GeyserBaseParticleOptions(w, burstImpulseBase)` (42-1 section 3).

**Eruption `geyser` (`GeyserEruptionParticle`, plain provider, no sprites).** Extends `NoRenderParticle`; constructor `(level, x, y, z, xa, ya, za, options)` stores the velocity arguments as `xa, ya, za` (not used as its own motion), `w = options.waterBlocks`, `lifetime = 20`, and creates three option objects: plume (`geyser_plume`, `w`), base (`geyser_base`, `w`, burst impulse 1.5), poof (`geyser_poof`, `w`, burst impulse 2.0).
- **Tick:** the `NoRenderParticle` tick first (age incremented to 1 on the first tick; removal as in 4.2). **Rule (read in the bytecode of `Particle.tick` and of this class):** the base tick removes the particle at the call where the old age is already >= `lifetime` (here the 21st call, when the age becomes 21) and returns, but a subclass tick that calls the base tick first and then does its own work has no check of the removed state, so its own work still runs on that final call. Any custom tick of this part that follows the base tick behaves the same way (the work after the base call runs one extra time, on the call that removes the particle, with the already incremented age). So the particle acts on ages 1 to 21; the tests below use that age. Then, in this order:
  1. if `age % 2 == 0` (ages 2, 4, ..., 20: 10 times; age 21 fails the test): add 2 base particles (`geyser_base`) at the eruption position with velocity (`xa, ya, za`);
  2. on **every** call, with no age test (21 times, ages 1 to 21, the last one being the removal call): add `w + 2` plume particles (`geyser_plume`) at the eruption position with velocity (`xa, ya, za`);
  3. if `age % 10 == 0` (ages 10 and 20: twice; age 21 fails the test): add 20 poof particles (`geyser_poof`, base class with burst 2.0) with velocity (`xa, ya, za`).
  All through `ClientLevel.addParticle` (the normal entry, but the three types have the override flag set, so there is no distance or status test).
- **Totals per eruption:** 20 base + 21 * (w + 2) plume + 40 poof (the plume count is one call longer than the base and poof counts, see the rule above).

**Base and poof (`GeyserBaseParticle`, extends `BaseAshSmokeParticle`, 8 sprites; same provider class for both types).**
- **Provider** (three draws of the engine's random before construction, in this order): `ux = vx + (nextFloat - 0.5) * 0.5`; `uy = vy + (nextFloat - 0.5) * 0.5 + 0.2` (the 0.2 is `0.20000000298023224`); `uz = vz + (nextFloat - 0.5) * 0.5`. (The first term of each is the supplied velocity, read in the provider's disassembly: the velocity argument is loaded and the spread term added to it; the eruption supplies the velocity (`xa, ya, za`), which is 0 in practice. The spreads are exactly `(nextFloat - 0.5) * 0.5` on x and z, and on y `(nextFloat - 0.5) * 0.5` plus the constant 0.20000000298023224.) Then constructs `GeyserBaseParticle(level, x, y, z, ux, uy, uz, w, burst, sprites)`.
- **Constructor:** `m = burst + 0.25 * w` (the velocity multiplier, f32) and `s = 3.0 + 0.125 * w` (the scale). The `BaseAshSmokeParticle` constructor with multipliers (m, m, m), add-ons (ux, uy, uz), scale s, colour multiplier 0, lifetime base 0, gravity 0, `hasPhysics` true. After it: `friction` = 0.725; colour (1, 1, 1); `yd = |yd|` (so the particle never starts downward); one `nextFloat` r drawn from the **level's** random: `lifetime = (int)(25 * (0.8 + 0.2 * r))` (20 to 24 ticks).
- **Size:** `0.75 * s * quadSize` with the growth of 8.5; for w = 1 the scale is 3.125, so the quad half-size is about 0.1 * (0.5 to 1) * 2 * 0.75 * 3.125 = 0.47 to 0.94 (arithmetic).
- **Tick:** `BaseAshSmokeParticle.tick` (sprite by age); with friction 0.725 the burst decays fast. **Layer:** `OPAQUE`. **Light:** default.
- **Velocity example:** supplied (0, 0, 0), burst 1.5, w = 1: m = 1.75; the initial jitter velocity (about 0.1 to 0.2 in magnitude, 42-1 section 4.1 and the 0.4 factors) is multiplied by 1.75 and the add-on of up to +/-0.25 per axis (plus 0.2 up) is added; then `yd` is made positive.

**Plume (`GeyserPlumeParticle`, extends `SingleQuadParticle`, 8 sprites).**
- **Provider** (three draws of the engine's random): `ux = vx + (nextFloat - 0.5) * 0.2`; `uy = vy + nextFloat`; `uz = vz + (nextFloat - 0.5) * 0.2` (read: the supplied velocity component is the first term of each sum, and the y term adds a bare `nextFloat`), then `GeyserPlumeParticle(level, x, y, z, ux, uy, uz, options, sprites)`.
- **Constants read:** initial propulsion factor 1.45, gravity exponent 3.0, gradual gravity factor 0.12, initial spray spread 0.2, linear spray spread 0.2, remaining frames after max height 5, min scale factor 2.0, max scale factor 3.0.
- **Constructor:** `SingleQuadParticle` constructor with velocity and the first sprite (draws of the **particle's own** random, in this order: the 5 velocity-jitter draws, the lifetime draw and the quad-size draw); `n = 5 * max(1, w)` (the plume height in blocks and the time base); `hasPhysics` = true; `speedUpWhenYMotionIsBlocked` = true; `lifetime = 5 * n` (= 25 * max(1, w) ticks); `yd` = 0; `startY` = spawn y; `maxY = startY + n - 1`; `horizontalSprayX = (nextFloat - 0.5) * 0.2` and then `horizontalSprayZ` the same, **both drawn from the level's random** (`ClientLevel.getRandom`, two draws, x first, after the constructor draws above; the particle's own random is not used for them); `friction` = 1.0; `initialPropulsion = (1.5 if w == 1 else 1.0) * n * 1.45`; `gravity = -initialPropulsion`; with `b = quadSize * 0.75`: `minSize = b * (2.0 + n / 8)` and `maxSize = b * (3.0 + n / 8)` (f32, `n` as float), `quadSize = minSize`; sprite from age.
- **Tick:** 1. the base tick (4.2; on the first tick the negative gravity gives `yd = 0.04 * initialPropulsion`, an upward velocity). 2. If not yet `done`: if `yd < 0`, or `y > maxY`, or `y == yo` (blocked or not moving), then `lifetime = min(lifetime, age + 5)`, `friction = 0` and `done = true` (the plume freezes its horizontal and vertical velocity one tick later and lingers 5 more ticks). 3. In every tick, done or not: `t = clamp((y - startY) / (maxY - startY), 0, 1)` (double); `gravity = initialPropulsion * t^3 * 0.12` (so gravity is 0 at the bottom and grows to `0.12 * initialPropulsion` at the top; it is positive, a downward pull); `xd = t * horizontalSprayX`, `zd = t * horizontalSprayZ` (the sideways drift grows with height); sprite from age; `quadSize = minSize + t * (maxSize - minSize)`.
- **Layer:** `OPAQUE`. **Light:** default. Because `friction` is 1.0 until `done`, the particle neither slows nor stops except by the gravity above.
- **Emitter:** the eruption above; the eruption is emitted by the sulfur block entity (3.12).

### 2.17 `sulfur_bubbles` (id 4), `SulfurBubbleParticle`

- **Provider** (1 sprite): chooses a sprite with `SpriteSet.get(random)` (engine's), then constructs `SulfurBubbleParticle(level, x, y, z, vx, vy, sprite)`: note that the provider passes the supplied **x and y velocity** (the 2nd and 3rd double after the position are `vx` and `vy`) and that `vz` is not passed. The constructor treats its two doubles as the x and z velocities (so a supplied `vy` becomes `zd`; emitters supply 0, so there is no effect, Open question 5).
- **Constructor:** `SingleQuadParticle` constructor without velocity (2 draws); `gravity` = -0.04 (so velocity y increases by 0.0016 each tick); `friction` = 0.85; `setSize(0.02, 0.02)`; `xd = vx * 0.2 + (nextFloat * 2 - 1) * 0.02` and `zd = vz' * 0.2 + (nextFloat * 2 - 1) * 0.02` (two draws; x then z); `sizeStart = 0.02 + nextFloat * 0.02` (one draw); `quadSize = sizeStart`; `lifetime` = 2147483647 (effectively unbounded); `yStart = yo`; `yEnd = yo + 4.0 - 1.0 = yo + 3.0`; `yPrev` = the supplied y.
- **Tick:** 1. the base tick. 2. If still alive, the fluid at the block containing the position must be a **water source**, otherwise remove. 3. If still alive and `y >= yEnd`, remove. 4. If still alive and `y <= yPrev` (not rising), remove. 5. `xd += wiggle()` and `zd += wiggle()` where `wiggle` is `nextFloat * 0.003 * (nextBoolean ? 1 : -1)` times 0.5 (two draws per call: a float, then a boolean; the 0.5 factor is the constant `0.5d`); 6. `move(xd, 0, zd)` (an extra horizontal-only move after the base move); 7. `quadSize = sizeStart + ((y - yStart) / (yEnd - yStart)) * (0.15 - sizeStart)` (the bubble grows from its start size to 0.15 as it rises); 8. `yPrev = y`.
- **Constants read:** `SIZE_START` 0.02, `SIZE_END` 0.15, `UPWARDS_SPEED` 0.04, `HORIZONTAL_WIGGLING` 0.003. **Layer:** the class overrides `getLayer` and returns `OPAQUE` (read). **Light:** there is no `getLightCoords` override, so the default light of 42-1 section 4.3 applies.
- **Emitter:** the potent sulfur block's `animateTick` (3.12): two per tick, through the always-visible entry.

### 2.18 `pause_mob_growth` (id 60) and `reset_mob_growth` (id 61), `SimpleVerticalParticle`

The class is specified in 42-1 section 8.3. The providers (`PauseMobGrowthProvider`, `ResetMobGrowthProvider`, 1 sprite each) draw one sprite `SpriteSet.get(random)` (engine's) and construct `SimpleVerticalParticle(level, x, y, z, vx, vy, vz, sprite, up)` with `up = false` for `pause_mob_growth` and `up = true` for `reset_mob_growth`. So the pause particle drifts downward (`yd -= 0.03`) and the reset particle upward (`yd += 0.03`), with the velocity otherwise exactly the supplied one. Emitter: 3.13.

### 2.19 `raid_omen` (id 123) and `trial_omen` (id 124), `SpellParticle`

Registered with `SpellParticle$Provider` (the plain provider, sprite set, 1 sprite each): the provider constructs `SpellParticle(level, x, y, z, vx, vy, vz, sprites)` with the supplied velocity and no provider draws; the `SpellParticle` class is specified in 42-2 section 3.7. The only thing this part adds is the emitters: `trial_omen` is spawned by the trial spawner's become-ominous burst (3.3) and by the mob effect of the same name; `raid_omen` is the particle of the raid omen mob effect (3.7).

### 2.20 `sulfur_cube_goo` (id 127), the `BreakingItemParticle$SulfurCubeProvider`

A sprite provider (1 sprite) that constructs `BreakingItemParticle(level, x, y, z, firstSprite)`: the five-argument form (no velocity is passed; the supplied velocity is ignored) with the first sprite of the set, no provider draws. The class (`BreakingItemParticle`) and this provider are specified in 42-4 section 7 (7.4 for this type). Emitter: the sulfur cube mob (class `SulfurCube`; its landing emission is tabulated in 42-7 section 6, row 6.34; the cadence was not read here: Open question 6).

## 3. Emitters

Common: server-side emitters reach the client by the Level Particles packet (42-1 section 7.2): `ServerLevel.sendParticles(options, x, y, z, count, dx, dy, dz, speed)` carries count, the three distances and the speed (the position spread and the speed factor). With `speed` 0 and `count` > 0 every particle receives velocity 0 (the velocity is the gaussian draw times the max speed) and the position is offset by a gaussian times the distance on each axis. Emitters that call `Level.addParticle` on the client directly use the entries of 42-1 section 7.1.

### 3.1 Level event 3006: sculk charge and pop (`LevelEventHandler.levelEvent`)

Level event numbers (the server's `levelEvent(type, pos, data)`) read in the handler's jump table: 3006 (sculk charge), 3007 (shriek), 3013 (trial spawner detects player), 3015 and 3016 (vault activation and deactivation, 3.4), 3019 (trial spawner detects player, ominous), 3020 (trial spawner becomes ominous), 3021 (trial spawner spawn mob particles; the flame particle comes from the event data), and, also present in the jump table, 3014 and 3017 (both call `TrialSpawner.addEjectItemParticles`, 3.3) and 3018 (ten `poof` particles; 42-7 section 8 row 3018). 42-7 section 8 tabulates 3014, 3017 and 3018 from the handler's side. The sender of 3007 is `SculkShriekerBlockEntity` (its bytecode contains the constant 3007; when it fires was not followed); the sender of 3006 (the sculk spreader and charge code) was not read (Open question 7); the sender of 3015 and 3016 was read (3.4). The same events are tabulated from the handler's side in 42-7 section 8.

Data layout of 3006: `charge = data >> 6` and `faces = data & 63` (a 6-bit mask, bit i set means the direction with ordinal i; directions are in the order DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5, read from the array of constants `Direction` builds, which lists them with ordinals 0 to 5 in that order).

**charge > 0:**
1. With one draw (the level's random) r: if `r < 0.3 + charge * 0.1` play the charge sound at the block with volume `0.15 + 0.02 * charge * charge * r2` and pitch `0.4 + 0.3 * charge * r3` (two more draws; the sound itself is out of scope).
2. The count provider is `UniformInt(0, charge)` (so each face gets a number of particles between 0 and `charge`; `UniformInt.sample` is `randomBetweenInclusive(0, charge)` = `nextInt(charge + 1)`, one draw, read in 1.3). The velocity supplier is three `Mth.nextDouble(-0.005, 0.005)`.
3. If `faces == 0`: for each of the six directions in ordinal order, emit with roll `pi` for DOWN and 0 for the other five directions, offset 0.65 when the face is on the Y axis and 0.57 on the X or Z axis, through `spawnParticlesOnBlockFace` (1.3); the particle option is `sculk_charge` with that roll.
4. Otherwise: for each direction in the mask (in ordinal order, `EnumSet` iteration), roll `pi` for UP and 0 for the other directions, offset 0.35, same emission.

**charge == 0** (the "pop"): play the charge sound (volume 1, pitch 1). `full = block's collision shape is a full block`. `count = 40 if full else 20`; `spread = 0.45 if full else 0.25`; speed factor 0.07. For each of the `count` particles: three draws `a, b, c`, each `nextFloat * 2 - 1` (level's random; x, y, z order); add a `sculk_charge_pop` particle at (`block x + 0.5 + a * spread`, `block y + 0.5 + b * spread`, `block z + 0.5 + c * spread`) with velocity (`a * 0.07`, `b * 0.07`, `c * 0.07`), through the normal entry (the type has the override flag).

### 3.2 Level event 3007: shrieker (`LevelEventHandler.levelEvent`)

For `i` in 0 to 9: add a `shriek` particle with delay `i * 5` at (`x + 0.5`, `y + TOP_Y`, `z + 0.5`) with velocity 0. `TOP_Y` is the top of the shrieker's collision column: the column shape is built from the arguments (16, 0, 8) so the top is 8 pixels: `TOP_Y` is the maximum Y of that shape, and the shape builder divides every pixel coordinate by 16, giving 0.5 blocks (read). Then, unless the block at the position is waterlogged, play the shriek sound at that position with volume 2 and pitch `0.6 + nextFloat * 0.4` (out of scope).

### 3.3 Trial spawner events (`LevelEventHandler`, `TrialSpawner` static helpers: `addDetectPlayerParticles`, `addBecomeOminousParticles`, `addSpawnParticles` and `addEjectItemParticles`)

- **Event 3013** (detected player): play the detect sound, then `addDetectPlayerParticles(level, pos, random, data, trial_spawner_detection)`. **3019** is the same with `trial_spawner_detection_ominous`. **3020** (become ominous): detect particles with the ominous type and player count 0, then `addBecomeOminousParticles`.
- **`addDetectPlayerParticles(count n, particle)`**: spawns `30 + min(n, 10) * 5` particles (so 30 for 0 players up to 80 for 10 or more). Per particle, in this order: `dx = (nextFloat * 2 - 1) * 0.65`, `dz = (nextFloat * 2 - 1) * 0.65`, then the y draw `nextFloat`; position (`x + 0.5 + dx`, `y + 0.1 + nextFloat * 0.8`, `z + 0.5 + dz`); velocity (0, 0, 0); normal entry.
- **`addBecomeOminousParticles`:** 20 times: position `(x + 0.5 + (nextDouble - 0.5) * 2, y + 0.5 + (nextDouble - 0.5) * 2, z + 0.5 + (nextDouble - 0.5) * 2)` (three `nextDouble` draws x, y, z); velocity (`gaussian * 0.02` on each axis: three `nextGaussian`, x, y, z); spawn a `trial_omen` particle then a `soul_fire_flame` particle with the same position and velocity (both through the normal `addParticle`).
- **`addEjectItemParticles(level, pos, random)`** (events 3014 and 3017; 42-7 section 8 rows 3014, 3017): 20 iterations. Per iteration, in this order: the position `(x + 0.4 + nextDouble * 0.2, y + 0.4 + nextDouble * 0.2, z + 0.4 + nextDouble * 0.2)` (three `nextDouble` draws, x, y, z; so a point inside the central 0.2 cube of the block's 0.4 to 0.6 range); the velocity `(g1 * 0.02, g2 * 0.02, g3 * 0.02)` (three `nextGaussian`, x, y, z); then a `small_flame` particle at the position with the velocity multiplied by 0.25, then a `smoke` particle at the same position with the full velocity (both through `Level.addParticle`, the normal entry). Total 20 small_flame and 20 smoke.
- **`addSpawnParticles(type)`** (event 3021; the flame type from the data): 20 times: the same position as `addBecomeOminousParticles`'s position draws (three `nextDouble` offsets), velocity 0; a `smoke` particle then the flame particle at that position. (Included for the particles of this part's neighbours: smoke and flame belong to other parts.)

### 3.4 Vault connection (`VaultBlockEntity$Client`)

Client ticker (every client tick): updates the display item spin; every 20 game ticks (`gameTime % 20 == 0`) emits connection particles for nearby players; every tick emits idle particles (flame choice by the OMINOUS block property: `soul_fire_flame` when ominous, else `small_flame`) and plays idle sounds.
- **Connection** (every 20 ticks, only when the shared data lists connected players): `keyholePos = block bottom centre + (stepX * 0.5, 1.75, stepZ * 0.5)` where the step is the block's FACING direction. For each connected player (looked up by UUID; skipped if absent or if not within range): the range test is `distSqr(player's block position, vault block position) <= connectedParticlesRange^2` (read: the squared distance between the two block positions compared, less than or equal, with the square of the range). `delta = (player position + (0, bbHeight / 2, 0)) - keyholePos`; `n = Mth.nextInt(rng, 2, 5)` (so 2 to 5 particles); each particle: `v = delta.offsetRandom(rng, 1.0)` (three draws); add a `vault_connection` particle at `keyholePos` with velocity `v` (the particle flies from `keyholePos + v` back to `keyholePos`, 2.12).
- **`connectedParticlesRange`** (read): the field of `VaultSharedData` is set to `VaultConfig.deactivationRange` by both of its constructors, is written from a double argument by `updateConnectedPlayersWithinRange` (the server passes `config.deactivationRange` in the key-insertion path read), and is saved and synced under the codec key `connected_particles_range` (default `deactivationRange`). `VaultConfig.DEFAULT` is built with the two constants 4.0 and 4.5; the record declares its fields in the order `activationRange`, `deactivationRange`, so the default deactivation range, and with it the default `connectedParticlesRange`, is **4.5 blocks** (the mapping of the two constants onto the fields is by declaration order only: inferred). A vault whose config overrides `deactivation_range` uses that value. (Open question 8.)
- **Idle** (every tick): with probability 0.5 (`nextFloat <= 0.5`): a `smoke` particle at a random point inside the cage: `block corner + (nextDouble(0.1, 0.9), nextDouble(0.25, 0.75), nextDouble(0.1, 0.9))` with velocity 0; and if the vault displays active effects (it has a display item) the flame particle at the same point with velocity 0.
- **Constants** (read in `VaultBlockEntity$Client`): `PARTICLE_TICK_RATE` 20, `IDLE_PARTICLE_CHANCE` 0.5, `ACTIVATION_PARTICLE_COUNT` 20, `DEACTIVATION_PARTICLE_COUNT` 20; idle cage positions use `nextDouble(0.1, 0.9)`, `nextDouble(0.25, 0.75)`, `nextDouble(0.1, 0.9)` for x, y, z.
- **Activation** (`emitActivationParticles(level, pos, state, shared data, flame option)`): first the connection particles for nearby players (the same routine as the 20-tick connection above), then 20 times: a random point inside the cage (the idle point formula), a `smoke` particle there with velocity 0, then the flame option at the same point with velocity 0.
- **Deactivation** (`emitDeactivationParticles(level, pos, flame option)`): 20 times: a point `block corner + nextDouble(0.4, 0.6)` per axis (x, y, z draws), velocity of three `nextGaussian * 0.02` (x, y, z), and the particle added is the **flame option argument** (not smoke).
- **Callers** (read in `LevelEventHandler.levelEvent`): level event **3015** (activation): if the block entity at the position is a `VaultBlockEntity`, call `emitActivationParticles` with the block entity's position, state and shared data and the flame option, then play the activate sound (volume 1, pitch `1 + (nextFloat - nextFloat) * 0.2`). Level event **3016** (deactivation): call `emitDeactivationParticles(level, pos, flame option)` (no block-entity test), then play the deactivate sound. For both, the flame option is chosen by the event data: data 0 gives `small_flame`, any other value gives `soul_fire_flame` (the handler tests only whether the data is zero).
- **Senders** (read, server): the vault state objects send the events when a state is entered, with data 1 when the block has the OMINOUS property and 0 otherwise: entering ACTIVE (after choosing a display item from the loot table if there is none) sends 3015; entering INACTIVE (after clearing the display item) sends 3016. (Entering EJECTING also sends level event 3017 after spawning the reward; its particles are those of `addEjectItemParticles`, 3.3.)

### 3.5 Decorated pot (`DecoratedPotBlock.useItemOn`)

After a successful insertion on the server (a matching or empty pot, the stack below the stack limit), plays the insert sound and sends `dust_plume` with `sendParticles(count 7, distances (0, 0, 0), speed 0)` at (`x + 0.5`, `y + 1.2`, `z + 0.5`). On the client via the packet (42-1 section 7.2): 7 particles, each with six gaussian draws that are multiplied by 0, so all start at the same point with the supplied velocity (0, 0, 0) plus the constructor's add-on.

### 3.6 Ominous item spawner (`OminousItemSpawner.addParticles`)

Runs on the client in `tickClient` when `level.getGameTime() % 5 == 0`. Count `nextIntBetweenInclusive(1, 3)` (one draw of the entity's random, 1 to 3). For each particle: a random point `q = p + (0.4 * (g1 - g2), 0.4 * (g3 - g4), 0.4 * (g5 - g6))` (six `nextGaussian` draws, x, y, z; `p` = the entity position); add an `ominous_spawning` particle at `p` with velocity `q - p` (`vectorTo`). The particle (2.13) flies from `q` to `p`. (The spawner entity also has a server tick that plays a sound at 36 ticks before the item spawns and spawns the item after 60 to 120 ticks; constants `SPAWN_ITEM_DELAY_MIN` 60, `SPAWN_ITEM_DELAY_MAX` 120, `TICKS_BEFORE_ABOUT_TO_SPAWN_SOUND` 36.)

### 3.7 Wind: wind charges and the wind charged effect

- **Wind charge burst:** `WindCharge.explode` and `BreezeWindCharge.explode` call `Level.explode` with the small particle `gust_emitter_small` and the large particle `gust_emitter_large` as the explosion's two particle options: radius 1.2 for the wind charge and 3.0 for the breeze wind charge, interaction type TRIGGER, a block-interaction flag false and the wind-burst sound. Which of the two particles the client uses is decided by the explosion packet handler (42-7 section 3.2; not repeated here). `WindChargedMobEffect.onMobRemoved`, on kill, produces the same two options at the entity's centre with radius `3.0 + 2 * nextFloat`. The Wind Burst enchantment (`Enchantments`) references the same two types in its effect data.
- **Wind charged mob effect:** the effect's ambient particle is `small_gust` (the particle factory passed to the `MobEffect` constructor; the cadence and count of mob effect particles are in 42-7 section 5).
- **Raid and trial omen effects:** `MobEffects` registers `raid_omen` and `trial_omen` as the particles of the corresponding mob effects (same remark: 42-7 section 5).

### 3.8 Warden sonic boom (`SonicBoom` behaviour, server)

On start: broadcast entity event 62 (the client animation) and play the charge sound. The boom (a delayed lambda in `tick`): `origin = warden position + chest attachment (rotated by yaw)`; `delta = target eye position - origin`; `dir = normalize(delta)`; for `i = 1` to `floor(|delta|) + 6` (the loop bound is `floor(length) + 7` exclusive): `sendParticles(sonic_boom, origin + dir * i, count 1, distances 0, speed 0)`; then the boom sound, then damage 10.0 (damage type sonic boom) and a push of `dir * (2.5 * (1 - knockbackResistance))` horizontally and `0.5 * (1 - knockbackResistance)` vertically. Constants read: `DISTANCE_XZ` 15, `DISTANCE_Y` 20, `COOLDOWN` 40. So the particle line runs from one block in front of the chest to about six blocks past the target. On the client each is one particle at the given point (no spread).

### 3.9 Vibration (`VibrationSystem$Ticker`, server)

`tryReloadVibrationParticle` (called from the vibration system's tick while a vibration is in flight and the "reload" flag is set): with `info.pos` the vibration's origin and `dest` the receiver's position (`PositionSource.getPosition`, default the origin), `total = calculateTravelTimeInTicks(distance)` and `remaining = data.travelTimeInTicks`: the interpolation factor is `1 - remaining / total` and the particle position is `lerp(factor, origin, dest)` on each axis; sends `vibration` with the option `VibrationParticleOption(position source, remaining)`, count 1, spread 0, speed 0. When the send reaches at least one player the reload flag is cleared. (So the particle spawns where the vibration currently is, and arrives after `remaining` ticks. The initial send when a vibration is first scheduled, `lambda$trySelectAndScheduleVibration`, sends the same option from the origin: its body was read only to the extent that it sets the current vibration; Open question 9.)

### 3.10 Creaking heart (`CreakingHeartBlockEntity.emitParticles`, server)

Colour 16545810 (`0xFC7812`, red 252, green 120, blue 18) when the active flag argument is true, else 6250335 (`0x5F5F5F`, grey 95). For each of `count` repetitions (the argument): a start point inside the creaking's bounding box (min corner + `nextDouble * size` per axis) when a creaking exists, with the target = a point in the heart block (`block corner + nextDouble` per axis), and the trail option `(target, colour, duration = 10 + nextInt(40))`; sent with `sendParticles(option, override true, always show true, x, y, z, count 1, distances 0, speed 0)`. (The creaking-exists branch and the branch that swaps start and target when the first test fails were not followed in detail: Open question 10.)

### 3.11 Eyeblossom (`EyeblossomBlock$Type.spawnTransformParticle`, server)

`s = 0.5 + nextDouble` (one draw); `v = ((nextDouble - 0.5), (nextDouble + 1), (nextDouble - 0.5))`, a start offset `blockCentre + v * s`; trail option `(target, type.particleColor, duration = (int)(20 * s))`; `sendParticles(option, ..., count 1, distances 0, speed 0)`. The particle colour is the `particleColor` field of the type (read in `EyeblossomBlock$Type`): OPEN 16545810 (`0xFC7812`, red 252, green 120, blue 18) and CLOSED 6250335 (`0x5F5F5F`, grey 95). The trail option is therefore (target, colour, `(int)(20 * s)`) with `s` the draw above.

### 3.12 Potent sulfur block and block entity (client side)

- **Bubbles (`PotentSulfurBlock.animateTick`):** unless the state property `STATE` is `DRY`, and only if the fluid in the block above is a water source: **two** `sulfur_bubbles` particles per call at (`x + nextFloat`, `y + 1 + nextFloat`, `z + nextFloat`) with velocity 0 through `addAlwaysVisibleParticle` (the always-visible entry), then with probability 1/10 a sound (`NOXIOUS_GAS`, ambient). The cadence of `animateTick` is that of block animation (42-6 section 1; the client tickers of this block are also in 42-6 section 4.6).
- **Noxious gas cloud (client ticker `CLIENT_NOXIOUS_GAS_TICKER`):** every 20 game ticks, find the noxious gas source block of the block entity; if there is one, spawn a `noxious_gas_cloud` particle at the source's centre with zero velocity (normal entry). `findNoxiousGasSource(level, pos)`: scan upward from `pos + 1` to `pos + 5` inclusive (`y + 4 + 1`); at each position: if the fluid is a water **source** and the block is the water block or passable, continue upward; otherwise if the block is air or passable, that position is the source; otherwise (a solid block) there is none; running past the limit is none. "Passable" here is `isGeyserPassableBlock`: air, the water block, or an empty collision shape.
- **Geyser (client ticker `CLIENT_GEYSER_PLUME_TICKER`, built per sound):** for each tick, if the source block exists, let `elapsed = gameTime - eruptionTick`: every 20 ticks (`elapsed % 20 == 0`) spawn the geyser eruption particle (`geyser`, 2.16) at (`source x + 0.5`, `source y`, `source z + 0.5`) with velocity 0 and `w = source y - block y - 1` (the number of water blocks between the sulfur block and the source); every 40 ticks (`elapsed % 40 == 0`) play the geyser sound at the source's centre. `eruptionTick` is the block entity's field (set to the game time when the entity is created into a level if it is -1). Which block states run this ticker (the "erupting" state) was not read (Open question 11).

### 3.13 Ageable mob growth (`AgeableMob.makeAgeLockedParticle`, server)

For a positive `age` that is even and a server level: choose `pause_mob_growth` when the boolean argument is true (offset 0.2) else `reset_mob_growth` (offset 0); the position is (`mob.getRandomX(1.0)`, `mob.getRandomY(0.2) + bbHeight + offset`, `mob.getRandomZ(1.0)`). In `Entity` (read), `getRandomY(s)` is `getY((2 * nextDouble - 1) * s)` with one `nextDouble` of the entity's random, and `getY(f)` is `feet y + bbHeight * f`. So particle y = feet y + bbHeight * (2r - 1) * 0.2 + bbHeight + offset (r one `nextDouble`; offset 0.2 for pause, 0 for reset), i.e. within 0.2 bbHeight above or below the top of the bounding box (plus the offset); x and z use `getRandomX(1.0)` and `getRandomZ(1.0)` (each one draw, spread over the box width); `sendParticles(type, position, count 1, distances 0, speed 0)`; the function returns the age reduced by 1. The callers (which pass pause or reset) are in the animal feeding and growth code (the server emission is also listed in 42-7 section 1.4).

### 3.14 Completeness of the emitter search

No other class in the artifact references the particle types of this part, except the explosion particle options and effect data noted in 3.7 and `SulfurCube` (2.20); the scan used `grep` over the 171 classes that reference `ParticleTypes`, then a disassembly search for each field name.

## 4. Worked examples

All values are computed from the formulas above (f32 rounding not emulated; differences are in the last digits).

**E1. Sculk charge pop, solid block.** Block (4, 70, -3) is a full block. Count 40, spread 0.45. Take draws a = 0.5, b = -1.0, c = 0.0 (raw nextFloat 0.75, 0.0, 0.5): position (4.5 + 0.225, 70.5 - 0.45, -2.5), velocity (0.035, -0.07, 0). The provider sets the velocity exactly, lifetime `6 + nextInt(4)`, e.g. draw 2 gives 8 ticks. The particle moves for 8 ticks with friction 0.96: after 8 ticks the displacement in x is `0.035 * (1 - 0.96^8) / 0.04` = 0.035 * (1 - 0.7214) / 0.04 = 0.2438 blocks (arithmetic). It passes through blocks (`hasPhysics` false).

**E2. Event 3006 decoding.** `data = 133` gives `charge = 133 >> 6 = 2`, `faces = 133 & 63 = 5 = 0b000101`: bits 0 and 2, i.e. DOWN and NORTH. The sound plays with probability `0.3 + 0.2 = 0.5`. Each of the two faces gets between 0 and 2 particles (offset 0.35, roll 0 on both because only UP gets pi). A DOWN-face particle (step (0, -1, 0)): x = centre x + nextDouble(-0.5, 0.5), y = centre y - 0.35, z = centre z + nextDouble(-0.5, 0.5); velocity = (sx, 0, sz) with the supplier's components in +/-0.005. `data = 0` gives charge 0 and so the pop of E1. `data = 64` gives charge 1, faces 0: all six faces, DOWN with roll pi, offsets 0.65 (DOWN, UP) and 0.57 (the four sides), each face between 0 and 1 particles.

**E3. Shrieker.** Event 3007 at block (0, 64, 0): ten particles at (0.5, 64.5, 0.5), delays 0, 5, ..., 45. The particle with delay 45 is drawn first at tick 46 and removed after its 30 life ticks, so the effect lasts 75 ticks (3.75 s). The first particle at age 15: size factor `clamp(15 / 30 * 0.75, 0, 1)` = 0.375, so the half-size is 0.85 * 0.375 = 0.319, alpha `1 - 0.5` = 0.5.

**E4. Vault connection.** Vault block (10, 64, 10) facing NORTH (step (0, 0, -1)): `keyholePos` = (10.5, 64, 10.5) + (0, 1.75, -0.5) = (10.5, 65.75, 10.0). A player at (10.5, 64, 6.5) with bounding-box height 1.8: target (10.5, 64.9, 6.5); delta = (0, -0.85, -3.5). With all three offset draws equal to 0.5 the velocity is exactly delta. A particle with lifetime 35 at age 18: `r = 1 - 18/35 = 0.4857`, `p = 0.5143`, `p4 = 0.0700`; position = (10.5, 65.75 - 0.85 * 0.4857 - 0.07 * 1.2, 10.0 - 3.5 * 0.4857) = (10.5, 65.253, 8.300). Alpha: age fraction 0.514, `inverseLerp(0.514, 0.25, 1.0)` = 0.352, alpha = 0.352 * 0.6 = 0.211. The light is block 15 (glowing).

**E5. Trial spawner detection.** Three players: `30 + 3 * 5` = 45 particles; 12 players: `30 + 10 * 5` = 80. A particle with draws dx-raw 0.75, dz-raw 0.25, y-raw 0.5 at block (0, 64, 0): dx = 0.325, dz = -0.325, position (0.5 + 0.325, 64.1 + 0.4, 0.5 - 0.325) = (0.825, 64.5, 0.175).

**E6. Gust emitters.** Large: scale 3.0, lifetime 7, delay 0: 7 ticks x 3 = 21 gust particles, each at the emitter position plus per axis `(nextDouble - nextDouble) * 3.0` (range -3 to 3). Small: scale 1.0, lifetime 3, delay 2: only age 0 passes the test (age % 3 == 0): 3 gust particles, offsets in -1 to 1. A gust particle lives 12 to 15 ticks; the 12-sprite animation by age.

**E7. Geyser with w = 1.** Eruption: 20 base + 21 * 3 = 63 plume + 40 poof (the plume loop also runs on the removal call, age 21). Plume parameters: n = 5, lifetime 25 (reduced when done), `maxY = startY + 4`, `initialPropulsion = 1.5 * 5 * 1.45 = 10.875`, so the initial upward velocity after the first tick is `0.04 * 10.875 = 0.435` blocks per tick and `minSize = 0.75 * q * (2 + 5/8)`. A numeric run of the formulas (double precision, no obstacles, spawn y = 0) gives: heights 0.435, 0.870, 1.304, 1.737, 2.165, 2.585, 2.991, 3.375, 3.728, 4.039 after ticks 1 to 10; at tick 10 the particle is above `maxY` (4.0), so `done` is set, lifetime becomes `min(25, 10 + 5)` = 15, friction 0; the plume reaches about 4.30 at tick 11 and then sinks about 0.05 blocks per tick until it is removed after tick 15. For w = 3 (`n` = 15, `ip` = 21.75, lifetime 75, `maxY` = 14) the same run gives heights 0.87, 1.74, 2.61, 3.48, 4.35 for ticks 1 to 5, 13.85 at tick 19 and 14.04 at tick 20; the vertical speed is still +0.19 at tick 20, so `done` is set at tick 20 by the `y > maxY` test, not by `yd < 0`. The plume reaches 14.13 at tick 21, then sinks about 0.10 per tick and is removed on the 26th call; the lifetime is `min(75, 20 + 5)` = 25.

**E8. Noxious gas.** Provider scale 3.0: lifetime = `(int)(6 / (r * 0.5 + 0.5) * 3)`: r = 0 gives 36, r = 1 gives 18 (r = 0.5: 6 / 0.75 * 3 = 24). With lifetime 24, `fadeOutStartingPoint` = 12.0; at age 18 alpha = `(24 - 6) / 24` = 0.75. A cloud acts at ages 2, 4, ..., 20: point candidates are within 3 blocks of the source horizontally, 0.25 below its centre, and must be within water below that point (`canBeReachedByNoxiousGas`).

**E9. Dust plume.** A decorated pot insert: 7 particles at (x + 0.5, y + 1.2, z + 0.5), supplied velocity 0. Constructor: velocity = jitter * (0.7, 0.6, 0.7) + (0, 0.15, 0); colour = (0.729 - s, 0.694 - s, 0.761 - s) with `s = nextFloat * 0.2`; lifetime `(int)(7 / (r * 0.8 + 0.2))`: 8 (r = 1) to 35 (r = 0); at tick n: gravity 0.5 * 0.88^n, friction 0.96 * 0.92^n; after 5 ticks gravity is 0.264 and friction 0.633.

**E10. Sonic boom.** Warden at (0, 64, 0), target eye at (0, 65.6, 12) with chest origin (0, 65.3, 0.2): `delta` = (0, 0.3, 11.8) of length 11.8, `floor` = 11; loop bound `11 + 7` = 18 exclusive, so `i` = 1 to 17: 17 `sonic_boom` particles, the last at origin + dir * 17 (beyond the target by about 5 blocks).

## 5. Validation

| # | Check | Expected |
|---|---|---|
| V1 | Types in this part | 29 rows in section 1.2; 28 are specified here (`elder_guardian` is 42-1's); `raid_omen`, `trial_omen` and `sulfur_cube_goo` are providers and emitters only |
| V2 | Particle definition files for the types in the scope list (24 names: all listed `sculk_*`, `shriek`, `sonic_boom`, `vibration`, `trail`, `gust`, `small_gust`, `dust_plume`, `trial_spawner_detection*`, `vault_connection`, `ominous_spawning`, `raid_omen`, `trial_omen`, `noxious_gas`, `geyser_base`, `geyser_poof`, `geyser_plume`, `sulfur_bubbles`, `pause_mob_growth`, `reset_mob_growth`, `sulfur_cube_goo`) | 24 files exist under `assets/minecraft/particles/` (counted with `unzip -Z1 | grep -v '/$'`); the 4 plain types (`gust_emitter_large`, `gust_emitter_small`, `geyser`, `noxious_gas_cloud`) have none |
| V3 | Sprite counts (42-1) | `sculk_soul` 11, `sculk_charge` 7, `sculk_charge_pop` 4, `sonic_boom` 16, `gust` 12, `small_gust` 7, geyser base, poof and plume 8 each, `noxious_gas` 8, `dust_plume` 8, trial detection 5 each, others 1 |
| V4 | Lifetime ranges | sculk charge 8 to 19; pop 6 to 9; shriek 30 (after its delay); sonic boom 16; vibration = arrival ticks; trail = duration; gust 12 to 15; dust plume 8 to 35; trial detection 12 to 24 (scale 1.5); vault connection 30 to 39; ominous spawning 25 to 29; noxious gas 18 to 36; noxious cloud 20; geyser eruption 20; geyser base and poof 20 to 24; plume `25 * max(1, w)` capped at `age + 5` once done |
| V5 | Emission counts | pop 40 or 20; shriek 10; trial detect `30 + 5 * min(n, 10)`; become-ominous 20 pairs; gust emitters 21 (large) and 3 (small); geyser eruption 20 base, `21 * (w + 2)` plume (ages 1 to 21), 40 poof; dust plume 7; sulfur bubbles 2 per animate tick; vault connection 2 to 5 per player per 20 ticks; ominous spawning 1 to 3 per 5 ticks; sonic boom `floor(length) + 6` |
| V6 | Constants | sculk shrieker top 0.5; sculk charge roll `pi` on DOWN (no face mask) or UP (mask); trail colour scaling 0.875 + r * 0.25; vault `LifetimeAlpha` (0, 0.6, 0.25, 1); ominous colours 0xFF45AEFE to 0xFFFFFFFF; dust plume colour 0xBAB1C2; creaking colours 0xFC7812 and 0x5F5F5F |
| V7 | Layers | `OPAQUE`: trail, gust, small gust, sonic boom, trial detection, ominous spawning, geyser base, poof and plume, dust plume, `sulfur_bubbles`, `pause_mob_growth`, `reset_mob_growth` (the `getLayer` of `SimpleVerticalParticle`, read), noxious cloud (none: no render); `TRANSLUCENT`: sculk soul, sculk charge, pop, shriek, vibration, vault connection, noxious gas |
| V8 | Emissive light (block level 15, sky kept) | sculk soul, charge, pop, shriek, vibration, trial detection, ominous spawning, vault connection (glowing); full bright 15728880: trail, gust, small gust, sonic boom |
| V9 | Level event numbers | 3006 charge, 3007 shriek, 3013, 3019, 3020 trial detect and ominous, 3021 trial spawn particles, 3015 vault activation and 3016 deactivation (data 0 small flame, else soul fire flame) |
| V10 | Class counts | 230 class files in `net/minecraft/client/particle/` of which 88 top level and 142 nested; 45 top-level classes left to 42-2 to 42-4 (not claimed by this part or 42-1) |

## Open questions

1. The 45 top-level classes of section 1.1 each appear by name in at least one of 42-2, 42-3 and 42-4 (searched by class name; whether each is specified as a full record there was not audited). `HugeExplosionParticle` is described both here (2.5) and in 42-2 section 3.12; the two must agree, and a reviewer should compare them.
2. `VibrationSignalParticle`, `TrailParticle`: on the last live tick `remaining = lifetime - age` is 0 after the increment, so `t = 1.0 / 0` is infinite and the position becomes non-finite (the lerp of an infinite factor). Whether the artifact tolerates this or the visible effect is a one-frame disappearance was not examined; the recommendation to snap to the target is a design choice, not a reading.
3. `FlyTowardsPositionParticle$EnchantProvider` and `$NautilusProvider` (other types) are not covered here; 42-2 mentions the enchant provider (searched by name); whichever part owns `enchant` and `nautilus` must specify them.
4. A zero-length vector in `NoxiousGasCloudParticle.pickRandomParticleSpawnPoint` (both horizontal draws exactly 0.5) normalises without a guard.
5. `SulfurBubbleParticle` takes the supplied y velocity as its z velocity (the provider does not pass `vz`); emitters supply zero, so there is no visible effect; whether the quirk matters for any other caller is unknown.
6. `SulfurCube`'s emission cadence for `sulfur_cube_goo` was not read here (42-7 section 6, row 6.34 tabulates the landing emission); the `BreakingItemParticle` five-argument constructor is in 42-4.
7. The server code that sends level event 3006 (the sculk spreader and charge code: when, with which charge value and face mask) was not read; for 3007 only the sender class (`SculkShriekerBlockEntity`) was identified, not the condition or timing.
8. The vault: `connectedParticlesRange` was read (default 4.5 blocks, 3.4; the mapping of the constants 4.0 and 4.5 to `activationRange` and `deactivationRange` is by declaration order only, inferred) and the callers of `emitActivationParticles` and `emitDeactivationParticles` were found (level events 3015 and 3016 in `LevelEventHandler`, 3.4). Still not read: whether any server path passes a value other than `config.deactivationRange` to `updateConnectedPlayersWithinRange` (only the key-insertion call was inspected; searched `VaultBlockEntity$Server`).
9. `VibrationSystem$Ticker.trySelectAndScheduleVibration`'s first particle send was not read in detail.
10. `CreakingHeartBlockEntity.emitParticles`: the branches that choose between creaking and heart as the start and the target were only partly followed.
11. Which `PotentSulfurState` values run the geyser, noxious gas and nausea tickers, and the server-side geyser launch force and salt, were not read (only the client emission numbers above).
12. The explosion packet handler's use of `gust_emitter_small` and `gust_emitter_large` is specified in 42-7 section 3.2 and was not re-read here.
13. Mob effect particle emission (the `small_gust`, `raid_omen`, `trial_omen` effect particles: count, cadence, colour) is specified in 42-7 section 5 and was not re-read here.
