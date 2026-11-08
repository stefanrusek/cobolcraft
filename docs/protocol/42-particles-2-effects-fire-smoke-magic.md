# 42. Particles, part 2: effects, fire, smoke, magic, explosions, fireworks

| | |
|---|---|
| Covers | The behaviour and the client rendering numbers of 41 particle types (heart, angry villager, happy villager, composter, cloud, poof, sneeze, crit, damage indicator, enchanted hit, sweep attack, dragon breath, effect, instant effect, entity effect, witch, enchant, end rod, explosion emitter, explosion, firework, flash, the four flames, soul, large smoke, smoke, white smoke, the two campfire smokes, note, totem of undying, elder guardian, spit, portal, reverse portal, lava, pause mob growth, reset mob growth) and of the sibling types that share their classes (infested, nautilus, dolphin, egg crack, glow, wax on, wax off, electric spark, scrape). For each: provider, class chain, sprite set and how a sprite is chosen, lifetime, gravity, friction, size, colour, fade, collision, light, render layer, initial velocity, per-tick behaviour, and the order of random draws. Also the firework starter (the rocket explosion director), the explosion emitter seed, and the elder guardian pointer. Emitters (who asks for these particles, with which arguments) are parts 6 and 7 and are not repeated. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.client.particle.` `HeartParticle`, `SuspendedTownParticle`, `CritParticle`, `AttackSweepParticle`, `ExplodeParticle`, `SpitParticle`, `PlayerCloudParticle`, `SpellParticle`, `DragonBreathParticle`, `FlyTowardsPositionParticle`, `EndRodParticle`, `TotemParticle`, `HugeExplosionParticle`, `HugeExplosionSeedParticle`, `FireworkParticles` (and `$Starter`, `$SparkParticle`, `$OverlayParticle`, the two providers, the switch map), `FlameParticle`, `RisingParticle`, `EmissiveRisingParticle`, `BaseAshSmokeParticle`, `SmokeParticle`, `LargeSmokeParticle`, `WhiteSmokeParticle`, `CampfireSmokeParticle`, `NoteParticle`, `ElderGuardianParticle` and its group, `PortalParticle`, `ReversePortalParticle`, `LavaParticle`, `SimpleVerticalParticle`, `GlowParticle`, `SimpleAnimatedParticle`, `SingleQuadParticle`, `Particle`, `Particle$LifetimeAlpha`, `ParticleResources` (provider table, from its bootstrap-method table), `ParticleEngine`, `ParticleGroup`; `ParticleTypes` (registration order and override flags), `SpellParticleOption`, `ColorParticleOption`, `PowerParticleOption`, `LightCoordsUtil`, `Mth` (sine table), `ARGB`, `DyeColor` (black), `FireworkExplosion$Shape`, `ClientLevel` (`createFireworks`); the shader pair `assets/minecraft/shaders/core/particle.vsh` and `.fsh`; the sprite definition files `assets/minecraft/particles/*.json`. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-15). Sprite definition files are data: the extraction tool copies them (42 part 1 §9), and this document gives only the sprite count and the first and last sprite of each set as validation numbers. Everything that is code (the provider-to-class binding, the per-class numbers, the firework shape tables) is given completely. Sounds are named only where a particle class plays one; the sound event definitions are another document. |

Related documents: [42-particles-1-shared-model-engine.md](42-particles-1-shared-model-engine.md) (called "part 1" below; it owns the particle record schema, the 128-entry registry, option wire forms, `Particle`/`SingleQuadParticle` fields and tick, movement and collision, the engine, limits, entry paths, sprite sets, and the shared base classes `RisingParticle`, `SimpleAnimatedParticle`, `SimpleVerticalParticle`, `BaseAshSmokeParticle`), [12-client-rendering.md](12-client-rendering.md) (lighting, atlases), [34-entity-models-1-shared-model-and-framework.md](34-entity-models-1-shared-model-and-framework.md) (the guardian model geometry), 05a (Level Particles packet and particle option wire forms).

Conventions: those of part 1 §1.1 apply (ticks, `f32` single-precision quantities, no seeded generator, draw order matters for tests). `r` always means a fresh `nextFloat` of the particle's own random source unless a row says otherwise. The words "Base7" and "Base2" abbreviate two draw sequences of part 1:

- **Base7(v)**: the chain `SingleQuadParticle(level, x, y, z, vx, vy, vz, sprite)`: 7 draws, in order: the lifetime draw, three velocity-noise draws (x, y, z), two speed draws, then the `quadSize` draw (part 1 §4.1, §4.3). The velocity it leaves is the normalised, re-scaled form of part 1 §4.1 (magnitude `s * 0.4` with `s` in [0.15, 0.45), plus 0.1 on y); the supplied velocity `v` is only a bias before normalisation.
- **Base2**: the chain `SingleQuadParticle(level, x, y, z, sprite)`: 2 draws: the lifetime draw, then the `quadSize` draw. Velocity is zero.

`quadSize` is a half extent: the drawn square has side `2 * quadSize` (part 1 §4.3). The default `quadSize` after either chain is `0.1 * (r * 0.5 + 0.5) * 2`, in [0.1, 0.2). "Growth rule G" means `getQuadSize(partial) = quadSize * clamp(32 * (age + partial) / lifetime, 0, 1)`: the quad grows from nothing to full size during the first 1/32 of the lifetime. Ages in ticks, `partial` the partial tick in [0, 1).

Sections: 0 Resolved. 1 Provider and class index. 2 Shared formulas used here (light, sine table, colour options). 3 Per-class records. 4 Rendering of these particles. 5 Worked examples. 6 Validation. Open questions.

---

## 0. Resolved: rules that apply to both world types

The behaviour here is client rendering and is a shared standard rule (design README R2): the world type changes which blocks, items and mobs emit particles, not what a particle does once it exists. Which resource pack supplies the sprite files in each world type is decided by 08 and the design README, not here.

Part 1's partition (its Open question 9) gave `lava` to part 3, the two campfire smokes to part 4 and `elder_guardian` to part 5. The scope sheet of this round lists them here, so they are specified here (lava 3.21, campfire 3.17, elder guardian 3.19); the sibling parts may cross-reference instead of repeating. Other overlaps with sibling assignments, all specified here: `dolphin` (3.2; part 1 Open question 9 assigns it to part 3), `pause_mob_growth` and `reset_mob_growth` (assigned to part 5 elsewhere), and `egg_crack` (part 4, section 10.1, assigns it elsewhere; 3.2 here). Part 4 and part 5 may cross-reference instead of repeating.

## 1. Provider and class index

Ids are registry ids (part 1 §2). "Ovr" is the registration's override-limiter flag (it skips the distance and status tests of part 1 §7.1). "Spr" is the number of sprites in the type's definition file. "Sprite pick": **age** = `SpriteSet.get(age, lifetime)` re-evaluated during the particle's life, **rnd** = one `get(random)` draw by the provider before the constructor, **first** = sprite 0 for life. "Layer" is the render layer of part 1 §4.3: O = `OPAQUE`, T = `TRANSLUCENT` (both on the `particles` atlas). "Phys" = `hasPhysics` (block collision, part 1 §4.4).

| Id | Type | Ovr | Provider (class `net.minecraft.client.particle.*`) | Particle class | Spr | Sprite pick | Layer | Phys | Section |
|---|---|---|---|---|---|---|---|---|---|
| 55 | `heart` | no | `HeartParticle$Provider` | `HeartParticle` | 1 | rnd | O | no | 3.1 |
| 0 | `angry_villager` | no | `HeartParticle$AngryVillagerProvider` | `HeartParticle` | 1 | rnd | O | no | 3.1 |
| 53 | `happy_villager` | no | `SuspendedTownParticle$HappyVillagerProvider` | `SuspendedTownParticle` | 1 | rnd | O | no | 3.2 |
| 54 | `composter` | no | `SuspendedTownParticle$ComposterFillProvider` | `SuspendedTownParticle` | 1 | rnd | O | no | 3.2 |
| 13 | `crit` | no | `CritParticle$Provider` | `CritParticle` | 1 | rnd | O | no | 3.3 |
| 25 | `enchanted_hit` | no | `CritParticle$MagicProvider` | `CritParticle` | 1 | rnd | O | no | 3.3 |
| 14 | `damage_indicator` | yes | `CritParticle$DamageIndicatorProvider` | `CritParticle` | 1 | rnd | O | no | 3.3 |
| 77 | `sweep_attack` | yes | `AttackSweepParticle$Provider` | `AttackSweepParticle` | 8 | age | O | no motion | 3.4 |
| 69 | `poof` | yes | `ExplodeParticle$Provider` | `ExplodeParticle` | 8 | age | O | yes | 3.5 |
| 75 | `spit` | yes | `SpitParticle$Provider` | `SpitParticle` (extends `ExplodeParticle`) | 8 | age | O | yes | 3.5 |
| 11 | `cloud` | no | `PlayerCloudParticle$Provider` | `PlayerCloudParticle` | 8 | age | T | no | 3.6 |
| 74 | `sneeze` | no | `PlayerCloudParticle$SneezeProvider` | `PlayerCloudParticle` | 8 | age | T | no | 3.6 |
| 23 | `effect` | no | `SpellParticle$InstantProvider` | `SpellParticle` | 8 | age | T | no | 3.7 |
| 56 | `instant_effect` | no | `SpellParticle$InstantProvider` | `SpellParticle` | 8 | age | T | no | 3.7 |
| 28 | `entity_effect` | no | `SpellParticle$MobEffectProvider` | `SpellParticle` | 8 | age | T | no | 3.7 |
| 81 | `witch` | no | `SpellParticle$WitchProvider` | `SpellParticle` | 8 | age | T | no | 3.7 |
| 40 | `infested` | no | `SpellParticle$Provider` | `SpellParticle` | 1 | age | T | no | 3.7 |
| 15 | `dragon_breath` | no | `DragonBreathParticle$Provider` | `DragonBreathParticle` | 3 | age | O | no | 3.8 |
| 26 | `enchant` | no | `FlyTowardsPositionParticle$EnchantProvider` | `FlyTowardsPositionParticle` | 26 | rnd | O | no | 3.9 |
| 85 | `nautilus` | no | `FlyTowardsPositionParticle$NautilusProvider` | `FlyTowardsPositionParticle` | 1 | rnd | O | no | 3.9 |
| 27 | `end_rod` | no | `EndRodParticle$Provider` | `EndRodParticle` (extends `SimpleAnimatedParticle`) | 8 | age | T | no | 3.10 |
| 78 | `totem_of_undying` | no | `TotemParticle$Provider` | `TotemParticle` (extends `SimpleAnimatedParticle`) | 8 | age | T | yes | 3.11 |
| 30 | `explosion` | yes | `HugeExplosionParticle$Provider` | `HugeExplosionParticle` | 16 | age | O | no motion | 3.12 |
| 29 | `explosion_emitter` | yes | `HugeExplosionSeedParticle$Provider` | `HugeExplosionSeedParticle` | none | none | no render | no | 3.12 |
| 37 | `firework` | no | `FireworkParticles$SparkProvider` | `FireworkParticles$SparkParticle` (extends `SimpleAnimatedParticle`) | 8 | age | T | yes | 3.13 |
| 52 | `flash` | no | `FireworkParticles$FlashProvider` | `FireworkParticles$OverlayParticle` | 1 | rnd | T | no motion | 3.13 |
| 39 | `flame` | no | `FlameParticle$Provider` | `FlameParticle` (extends `RisingParticle`) | 1 | rnd | O | no | 3.14 |
| 103 | `small_flame` | no | `FlameParticle$SmallFlameProvider` | `FlameParticle` | 1 | rnd | O | no | 3.14 |
| 50 | `soul_fire_flame` | no | `FlameParticle$Provider` | `FlameParticle` | 1 | rnd | O | no | 3.14 |
| 12 | `copper_fire_flame` | no | `FlameParticle$Provider` | `FlameParticle` | 1 | rnd | O | no | 3.14 |
| 51 | `soul` | no | `EmissiveRisingParticle$Provider` | `EmissiveRisingParticle` (extends `RisingParticle`) | 11 | age | T | yes | 3.15 |
| 72 | `smoke` | no | `SmokeParticle$Provider` | `SmokeParticle` (extends `BaseAshSmokeParticle`) | 8 | age | O | yes | 3.16 |
| 65 | `large_smoke` | no | `LargeSmokeParticle$Provider` | `LargeSmokeParticle` (extends `SmokeParticle`) | 8 | age | O | yes | 3.16 |
| 73 | `white_smoke` | no | `WhiteSmokeParticle$Provider` | `WhiteSmokeParticle` (extends `BaseAshSmokeParticle`) | 8 | age | O | yes | 3.16 |
| 87 | `campfire_cosy_smoke` | yes | `CampfireSmokeParticle$CosyProvider` | `CampfireSmokeParticle` | 12 | rnd | T | yes | 3.17 |
| 88 | `campfire_signal_smoke` | yes | `CampfireSmokeParticle$SignalProvider` | `CampfireSmokeParticle` | 12 | rnd | T | yes | 3.17 |
| 68 | `note` | no | `NoteParticle$Provider` | `NoteParticle` | 1 | rnd | O | yes | 3.18 |
| 24 | `elder_guardian` | yes | `ElderGuardianParticle$Provider` | `ElderGuardianParticle` | none | model | elder guardian group | no motion | 3.19 |
| 70 | `portal` | no | `PortalParticle$Provider` | `PortalParticle` | 8 | rnd | O | no | 3.20 |
| 101 | `reverse_portal` | no | `ReversePortalParticle$ReversePortalProvider` | `ReversePortalParticle` (extends `PortalParticle`) | 8 | rnd | O | no | 3.20 |
| 66 | `lava` | no | `LavaParticle$Provider` | `LavaParticle` | 1 | rnd | O | yes | 3.21 |
| 60 | `pause_mob_growth` | no | `SimpleVerticalParticle$PauseMobGrowthProvider` | `SimpleVerticalParticle` | 1 | rnd | O | yes | 3.22 |
| 61 | `reset_mob_growth` | no | `SimpleVerticalParticle$ResetMobGrowthProvider` | `SimpleVerticalParticle` | 1 | rnd | O | yes | 3.22 |
| 86 | `dolphin` | no | `SuspendedTownParticle$DolphinSpeedProvider` | `SuspendedTownParticle` | 1 | rnd | O | no | 3.2 |
| 116 | `egg_crack` | no | `SuspendedTownParticle$EggCrackProvider` | `SuspendedTownParticle` | 1 | rnd | O | no | 3.2 |
| 110 | `glow` | yes | `GlowParticle$GlowSquidProvider` | `GlowParticle` | 1 | age | O | no | 3.23 |
| 111 | `wax_on` | yes | `GlowParticle$WaxOnProvider` | `GlowParticle` | 1 | age | O | no | 3.23 |
| 112 | `wax_off` | yes | `GlowParticle$WaxOffProvider` | `GlowParticle` | 1 | age | O | no | 3.23 |
| 113 | `electric_spark` | yes | `GlowParticle$ElectricSparkProvider` | `GlowParticle` | 1 | age | O | no | 3.23 |
| 114 | `scrape` | yes | `GlowParticle$ScrapeProvider` | `GlowParticle` | 1 | age | O | no | 3.23 |

Notes on the table:

1. The binding was read from `ParticleResources.registerProviders`, whose sprite providers are lambdas; each lambda's target class was read from the class's bootstrap-method table. Four registrations share a provider class: `flame`, `soul_fire_flame` and `copper_fire_flame` all use `FlameParticle$Provider` (they differ only in their sprite file), and `effect` and `instant_effect` both use `SpellParticle$InstantProvider` (they differ only in their sprite file: `effect_*` and `spell_*`). `entity_effect` and `witch` share the sprite names with `effect` and `instant_effect` respectively (the lists are in section 6, V3).
2. Sprite files read (`assets/minecraft/particles/<type>.json`): `heart` 1 (`heart`), `angry_villager` 1 (`angry`), `happy_villager`, `composter`, `pause_mob_growth`, `reset_mob_growth`, `egg_crack`: 1 each (`glint`), `crit` 1 (`critical_hit`), `enchanted_hit` 1 (`enchanted_hit`), `damage_indicator` 1 (`damage`), `sweep_attack` 8 (`sweep_0` to `sweep_7`), `cloud`, `poof`, `sneeze`, `spit`, `large_smoke`, `smoke`, `white_smoke` 8 each (`generic_7` down to `generic_0`; index 0 is `generic_7`), `portal` and `reverse_portal` 8 (`generic_0` up to `generic_7`; index 0 is `generic_0`), `dragon_breath` 3 (`generic_5`, `generic_6`, `generic_7`, in that order), `effect` and `entity_effect` 8 (`effect_7` down to `effect_0`), `instant_effect` and `witch` 8 (`spell_7` down to `spell_0`), `enchant` 26 (`sga_a` to `sga_z`), `end_rod` and `totem_of_undying` 8 (`glitter_7` down to `glitter_0`), `explosion` 16 (`explosion_0` to `explosion_15`), `firework` 8 (`spark_7` down to `spark_0`), `flash` 1 (`flash`), `flame` and `small_flame` 1 (`flame`), `soul_fire_flame` 1 (`soul_fire_flame`), `copper_fire_flame` 1 (`copper_fire_flame`), `soul` 11 (`soul_0` to `soul_10`), both campfire smokes 12 (`big_smoke_0` to `big_smoke_11`), `note` 1 (`note`), `lava` 1 (`lava`), `nautilus` 1 (`nautilus`), `dolphin` 1 (`generic_0`), `glow`, `wax_on`, `wax_off`, `electric_spark`, `scrape` 1 each (`glow`). `infested` 1 (`infested`). `explosion_emitter` and `elder_guardian` have no definition file (the first draws nothing, the second draws a model).
3. The 1-sprite "age" rows pick the same sprite for life; the row says "age" only because the class calls the age-based setter.
4. `SpellParticle`, `PlayerCloudParticle`, `EndRodParticle` and the others read their sprite set once at construction through `SpriteSet.first()` and then re-evaluate by age; only the classes marked "rnd" take a random sprite once and keep it.

## 2. Shared formulas used here

### 2.1 Light, the emission ramp, and the two light packings

All light values below are a pair of 8-bit channels: block light and sky light, each 0 to 240 (a level L of 0 to 15 is `16 * L`). The two storage forms in `LightCoordsUtil` coincide for whole levels: the packed form puts block in bits 4 to 7 and sky in bits 20 to 23 (`(block << 4) | (sky << 20)`); the smooth form puts block in bits 0 to 7 and sky in bits 16 to 23. The result is the same integer when the levels are whole (block level 15 is bits 0xF0 in both). Full bright is block 240 and sky 240, the integer 15728880 (`0xF000F0`); "full sky" is 15728640 (`0xF00000`). The renderer multiplies the vertex colour by the lightmap sample at these two coordinates (`particle.vsh`: `vertexColor = Color * sample_lightmap(Sampler2, UV2)`; the lightmap itself is 12 §1).

- **Default light** (`Particle.getLightCoords`, part 1 §4.3): the world light at the block containing the particle's current position, with the block channel raised to the block's own light emission when that is higher; an unloaded chunk gives full sky; an emissive-rendering block gives full bright.
- **Emission ramp** `E(L, f)` (`LightCoordsUtil.addSmoothBlockEmission`): let `f' = clamp(f, 0, 1)`; the block channel of `L` is increased by `floor(f' * 240)` (240 is the constant, the conversion truncates) and capped at 240; the sky channel is unchanged. Used by flame, glow, portal and enchant, each with its own `f`.
- **`withBlock(L, 15)`**: keeps only the sky channel of `L` (bits 16 to 23) and sets the block channel to 15 levels (240): the particle is at least block-lit at 15 and its sky light is the world's. Used by lava.

### 2.2 The sine used by note, portal-type and flash code

`Mth.sin(x)` is a table lookup: the index is `(long)(x * 10430.378350470453)` masked with 65535, and the table entry `i` is `(float) sin(i / 10430.378350470453)` (the table is 65536 entries, built in the static initialiser). This answers part 1's Open question 8: the sine is quantised to 65536 steps per turn (2 pi * 10430.378... = 65536.0 within rounding), so a reimplementation using a true sine differs by under 1e-4. `Mth.cos(x)` adds 16384 to the scaled argument before masking.

### 2.3 Colour options

`ColorParticleOption` (wire: one Int, ARGB, part 1 §3) is read as `red/green/blue/alpha = byte / 255.0`; `SpellParticleOption` (wire: Int colour, Float power) is read the same way for red, green, blue and its alpha byte is unused. `ARGB.colorFromFloat(a, r, g, b)` converts each channel by `floor(channel * 255)` (truncation, not rounding) and packs alpha in the top byte: this answers part 1's Open question 5. A colour `c` supplied by option goes to the particle's `rCol, gCol, bCol` as those fractions.

### 2.4 Provider call shape

Every provider is `(options, level, x, y, z, vx, vy, vz, engineRandom)`. Part 1 §6.4 gives the order: the provider's own sprite draw (for "rnd" rows) comes first, then the constructor chain, then provider setters. Providers pass `(vx, vy, vz)` to the constructor unless a row below says it ignores them.

## 3. Per-class records

Every record gives: the constructor, in order; the per-tick behaviour beyond part 1 §4.2; light; layer; and the draw order. Constants are read values unless marked "(inferred)". A **tick** that "calls the base tick" is part 1 §4.2: remember its order (old age compared with lifetime before the increment; gravity `yd -= 0.04 * gravity`; move; speed-up; friction; ground factor 0.7).

### 3.1 `HeartParticle`: `heart`, `angry_villager`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, sprite)`: Base7(0, 0, 0) with that sprite. Then `speedUpWhenYMotionIsBlocked = true`; `friction = 0.86`; `xd, yd, zd` each multiplied by `0.009999999776482582`; then `yd += 0.1`; `quadSize *= 1.5`; `lifetime = 16` (overrides the drawn one); `hasPhysics = false`. |
| Velocity | The provider's `vx, vy, vz` are **ignored** (the constructor takes none). After the constructor `yd` is in [0.0992, 0.1028] (base `yd` in [-0.08, 0.28], times 0.01, plus 0.1). |
| Gravity | 0 (base default). |
| Size | `quadSize` in [0.15, 0.30) (default 0.1 to 0.2 times 1.5); `getQuadSize` is growth rule G. |
| Colour, alpha | 1, 1, 1, 1. |
| Tick | Base tick only. With `hasPhysics` false there is no collision, `speedUp` therefore fires only when `yd` is exactly 0. |
| Light | Default. |
| Layer | `OPAQUE`. |
| `heart` provider | `new HeartParticle(level, x, y, z, sprites.get(random))`. |
| `angry_villager` provider | As `heart` but the particle is placed at `y + 0.5`, then `setColor(1, 1, 1)` (a no-op on a fresh particle). Both types use different sprite files (`heart`, `angry`). |
| Draws | provider sprite (1), Base7 (7); nothing else. |

Rise: over its 16 ticks the heart rises `0.1 * (1 - 0.86^16) / (1 - 0.86)`, about 0.65 blocks (section 5, E1).

### 3.2 `SuspendedTownParticle`: `happy_villager`, `composter`, `dolphin`, `egg_crack`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprite)`: Base7(vx, vy, vz). Then: one draw `r`, grey `c = r * 0.1 + 0.2` set on all three colour channels; `setSize(0.02, 0.02)`; one draw `r`, `quadSize *= r * 0.6 + 0.5`; `xd, yd, zd` each multiplied by `0.019999999552965164` (the supplied velocity only biases the direction; it is not added); one draw `r`, `lifetime = (int)(20 / (r * 0.8 + 0.2))`, range 20 (r near 1) to 100 (r = 0). |
| Movement | `move` is overridden: the box is moved by the delta with **no collision**. Velocity magnitude after the multiply is between 0.0012 and 0.0036 blocks per tick plus about 0.002 upward (the base `yd` carries a 0.1 before the 0.02 multiply). |
| Tick | Not the base tick. Steps: (1) `xo, yo, zo` = position; (2) if `lifetime` (before the decrement) is 0 or less, remove and stop, else decrement `lifetime` (so `lifetime` counts down and `age` stays 0); (3) `move(xd, yd, zd)`; (4) multiply `xd, yd, zd` each by 0.99. A particle with drawn lifetime L moves for L ticks and is removed on tick L + 1. |
| Sprite | One sprite chosen at random by the provider; it never changes. |
| Light, layer | Default light; `OPAQUE`. |
| Size over life | Constant (default `getQuadSize`). |
| `happy_villager` provider | Build, then `setColor(1, 1, 1)`. Lifetime as drawn. |
| `composter` provider | Build, `setColor(1, 1, 1)`, then `lifetime = 3 + nextInt(5)` using the **client level's** random source (not the particle's), so 3 to 7 ticks. |
| `egg_crack` provider | Build, `setColor(1, 1, 1)`. |
| `dolphin` provider | Build, `setColor(0.3, 0.5, 1.0)`, then `alpha = 1 - r * 0.7` with a draw from the **engine's** random source (the provider's `random` argument), then `lifetime = lifetime / 2` (integer division). |
| Draws | provider sprite (1), Base7 (7), colour (1), size (1), lifetime (1); then the provider's setter draw (composter: one level draw; dolphin: one engine draw). |

### 3.3 `CritParticle`: `crit`, `enchanted_hit`, `damage_indicator`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprite)`: Base7(0, 0, 0) (the supplied velocity is **not** a bias here). Then `friction = 0.7`, `gravity = 0.5`; `xd, yd, zd` each multiplied by `0.10000000149011612`; then `xd += vx * 0.4`, `yd += vy * 0.4`, `zd += vz * 0.4` (the supplied velocity is added, scaled by 0.4000000059604645); one draw `r`, grey `c = r * 0.3 + 0.6` on all three channels; `quadSize *= 0.75`; one draw `r`, `lifetime = max((int)(6 / (r * 0.8 + 0.6)), 1)`, range 4 to 10; `hasPhysics = false`; then **`tick()` is called once inside the constructor**. |
| Tick | Base tick (gravity 0.5, so `yd` falls by 0.02 per tick; friction 0.7), then `gCol *= 0.96` and `bCol *= 0.9` (the colour drifts to red as it ages; the red channel is untouched). The constructor's own tick therefore applies one age step, one move, one friction step and one colour step before the particle is first seen: it is created at `age` 1. |
| Size | Growth rule G. |
| Light, layer | Default light; `OPAQUE`. |
| `crit` provider | `new CritParticle(level, x, y, z, vx, vy, vz, sprites.get(random))`. |
| `enchanted_hit` provider | As `crit`, then after construction (so after the constructor's tick) `rCol *= 0.3` and `gCol *= 0.8`: a blue-green shade (`r` = 0.3 c, `g` = 0.8 * 0.96 c, `b` = 0.9 c). |
| `damage_indicator` provider | As `crit` but the vertical velocity argument is `vy + 1.0`, and after construction `lifetime = 20` (overrides the drawn 4 to 10; the constructor's tick has already run against the drawn lifetime). Override flag: yes. |
| Draws | provider sprite (1), Base7 (7), colour (1), lifetime (1). |

### 3.4 `AttackSweepParticle`: `sweep_attack`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, scale, sprites)` where the provider passes its **first velocity argument `vx` as `scale`** (its `vy` and `vz` are ignored): Base7(0, 0, 0) with `sprites.first()`; `lifetime = 4`; one draw `r`, grey `c = r * 0.6 + 0.4` on all three channels; `quadSize = 1.0 - (float)scale * 0.5` (a direct assignment replacing the drawn size); then the sprite is set from age 0. |
| Tick | Own tick (no motion, no gravity, no friction, no collision): `xo, yo, zo` = position; compare the old age with `lifetime` and increment; remove when old age is 4 or more; otherwise set the sprite from age. |
| Sprite | `get(age, 4)` over the 8 sprites: index `age * 7 / 4` (integer): the frames displayed on ticks 0 to 4 are ages 0, 1, 2, 3, 4 giving indices 0, 1, 3, 5, 7. The particle exists for five ticks (age 0 at creation, ages 1 to 4 after the four non-removing ticks; the fifth tick removes it). |
| Light | Full bright, 15728880. |
| Layer | `OPAQUE`. |
| Draws | Base7 (7), colour (1). The provider has no sprite draw (it passes the whole set). |

### 3.5 `ExplodeParticle` and `SpitParticle`: `poof`, `spit`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: Base2 with `sprites.first()`; `gravity = -0.1`; `friction = 0.9`; three draws `a, b, c` (x, y, z order): `xd = vx + (a * 2 - 1) * 0.05`, `yd = vy + (b * 2 - 1) * 0.05`, `zd = vz + (c * 2 - 1) * 0.05` (the supplied velocity is the centre of a small uniform noise, with no normalisation); one draw `r`, grey `c = r * 0.3 + 0.7` on all channels; two draws `p, q`: `quadSize = 0.1 * (p * q * 6 + 1)`, range 0.1 to 0.7; one draw `r`, `lifetime = (int)(16 / (r * 0.8 + 0.2)) + 2`, range 18 (r = 1) to 82 (r = 0); then the sprite is set from age 0. |
| Tick | Base tick (gravity -0.1 means `yd` rises by 0.004 per tick; friction 0.9; **block collision on**), then the sprite from age. |
| Size | Constant (default `getQuadSize`). |
| Light, layer | Default light; `OPAQUE`. |
| Provider | `new ExplodeParticle(level, x, y, z, vx, vy, vz, sprites)`; override flag: yes. |
| `spit` | `SpitParticle` runs the same constructor and then sets `gravity = 0.5` (so `yd` falls by 0.02 per tick instead of rising). It uses the same provider shape and 8 sprites (`generic_7` to `generic_0`). Override flag: yes. |
| Draws | Base2 (2), x y z (3), colour (1), size (2), lifetime (1). |

### 3.6 `PlayerCloudParticle`: `cloud`, `sneeze`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: Base7(0, 0, 0) with `sprites.first()`; `friction = 0.96`; `xd, yd, zd` each multiplied by 0.10000000149011612 and then the supplied `vx, vy, vz` added; one draw `r`, grey `c = 1 - r * 0.3` on all channels (so 0.7 to 1.0); `quadSize *= 1.875`; one draw `r`, `i = (int)(8 / (r * 0.8 + 0.3))`, `lifetime = (int) max(i * 2.5, 1)`, range 17 (r = 1: i = 7) to 65 (r = 0: i = 26); `hasPhysics = false`; the sprite is set from age 0. |
| Tick | Base tick (gravity 0, friction 0.96, no collision). Then, if the particle is not removed: set the sprite from age; find the nearest player within 2.0 blocks of the particle (`getNearestPlayer(x, y, z, 2.0, false)`: the last argument selects the player filter, true = excludes creative and spectator players, false = excludes spectators only, read in `EntityGetter`; so creative players count); if there is one and that player's Y is **above** the particle's Y: `y += (playerY - y) * 0.2`; `yd += (player vertical velocity - yd) * 0.2`; then `setPos(x, y, z)`. This makes a cloud lift toward a player standing above it (a jumping player's trail). |
| Size | Growth rule G (applied to `quadSize` in 0.1875 to 0.375). |
| Light, layer | Default light; `TRANSLUCENT`. |
| `cloud` provider | `new PlayerCloudParticle(level, x, y, z, vx, vy, vz, sprites)`. |
| `sneeze` provider | As `cloud`, then `setColor(0.22, 1.0, 0.53)` (a green) and `setAlpha(0.4)`; this overwrites the grey drawn in the constructor (the draw is still consumed). |
| Draws | Base7 (7), colour (1), lifetime (1). No provider sprite draw. |

### 3.7 `SpellParticle`: `effect`, `instant_effect`, `entity_effect`, `witch`, `infested`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, xa, ya, za, sprites)`. The super call is Base7 with the velocity `(0.5 - R1, ya, 0.5 - R2)` where `R1` and `R2` are `nextDouble` draws from a **static random source shared by all spell particles** (a separate `RandomSource` created once, not the particle's), taken in x then z order before the particle's own draws; `xa` and `za` are not used as velocity. Then: `originalAlpha = 1.0`; `friction = 0.96`; `gravity = -0.1`; `speedUpWhenYMotionIsBlocked = true`; `yd *= 0.20000000298023224`; **if `xa == 0` and `za == 0` exactly**, `xd *= 0.10000000149011612` and `zd *= 0.10000000149011612`; `quadSize *= 0.75`; one draw `r`, `lifetime = (int)(8 / (r * 0.8 + 0.2))`, range 8 to 40; `hasPhysics = false`; the sprite is set from age 0 (`sprites.first()` was the construction sprite); finally, if the **scoping test** (below) holds, `setAlpha(0)`. |
| `setAlpha(a)` | Overridden: sets `alpha` and also `originalAlpha = a`. |
| Tick | Base tick (gravity -0.1: `yd` rises 0.004 per tick; friction 0.96), then the sprite from age, then: if the scoping test holds, `alpha = 0`; otherwise `alpha += (originalAlpha - alpha) * 0.05` (a 5 percent step back toward the original alpha each tick). There is **no alpha fade with age** in this class. |
| Scoping test | True when the local player exists, the distance squared from the player's eye position to the particle is at most 9.0 (3 blocks), the camera is first person, and the player is scoping through a spyglass. The effect: the particle is hidden while the player looks through a spyglass from nearby; because the constructor's `setAlpha(0)` also sets `originalAlpha`, a particle created in that state never reappears. |
| Size | Constant. |
| Light, layer | Default light; `TRANSLUCENT`. |
| `effect`, `instant_effect` provider | Option class `SpellParticleOption` (colour, power). Build, then `setColor(option red, green, blue)` and `setPower(option power)` (part 1 §4.1: `xd *= p`, `yd = (yd - 0.1) * p + 0.1`, `zd *= p`). The option's alpha byte is not used. |
| `entity_effect` provider | Option class `ColorParticleOption`. Build, then `setColor(option red, green, blue)` and `setAlpha(option alpha)` (alpha 0 to 1 from the top byte; this sets `originalAlpha` too). |
| `witch` provider | Simple option. Build, then one draw `r` from the **engine's** random (the provider argument): `m = r * 0.5 + 0.35` and `setColor(1.0 * m, 0.0 * m, 1.0 * m)`: a purple of strength 0.35 to 0.85. |
| `infested` provider | Simple option: build only (white, alpha 1). Registered through `SpellParticle$Provider`. |
| Draws | Static source (2: x then z), Base7 on the particle's source (7), lifetime (1); then the provider's setter (witch: 1 engine draw). The scoping test draws nothing. |

### 3.8 `DragonBreathParticle`: `dragon_breath`

Option class `PowerParticleOption` (wire: one Float).

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: Base2 with `sprites.first()`; `friction = 0.96`; `xd = vx`, `yd = vy`, `zd = vz` (exact, no noise); colour by `Mth.nextFloat(random, min, max)` (which returns `min + r * (max - min)` and returns `min` **without a draw** when `min >= max`): `rCol` from 0.7176471 to 0.8745098 (draw 1), `gCol` from 0.0 to 0.0 (no draw, 0), `bCol` from 0.8235294 to 0.9764706 (draw 2); `quadSize *= 0.75`; one draw `r`, `lifetime = (int)(20 / (r * 0.8 + 0.2))`, range 20 to 100; `hasPhysics = false`; `hasHitGround = false`; the sprite is set from age 0. The colour constants correspond to the integers 11993298 (`0xB700D2`) and 14614777 (`0xDF00F9`) (the class holds both as constants). |
| Provider | After construction `setPower(option power)` (part 1 §4.1). |
| Tick | Own tick, **not** the base tick, so no gravity: (1) `xo, yo, zo` = position; (2) compare the old age with `lifetime`, increment, and remove if the old age was `lifetime` or more; (3) set the sprite from age (3 sprites: index `age * 2 / lifetime`); (4) if `onGround`: `yd = 0` and `hasHitGround = true`; (5) if `hasHitGround`: `yd += 0.002`; (6) `move(xd, yd, zd)`; (7) if `y == yo` exactly: `xd *= 1.1`, `zd *= 1.1`; (8) `xd *= friction`, `zd *= friction`; (9) if `hasHitGround`: `yd *= friction`. Note that `yd` is **not** damped by friction until the ground has been hit. |
| Dead branch (confirmed) | `onGround` is set only by a collision-resolved move, and `hasPhysics` is false, so `onGround` never becomes true and steps (4), (5) and (9) never run (confirmed statically: in `Particle.move`, `onGround` is assigned from "requested dy differs from resolved dy and requested dy < 0", and with `hasPhysics` false the resolved delta equals the requested one). The particle therefore keeps its (power-scaled) vertical velocity for life, and only its horizontal velocity decays at 0.96 per tick. |
| Size | Growth rule G. |
| Light, layer | Default light; `OPAQUE`. |
| Draws | Base2 (2), red (1), blue (1), lifetime (1). The provider has no sprite draw. |

### 3.9 `FlyTowardsPositionParticle`: `enchant`, `nautilus`

The class has two constructors; the providers read here use the short one, which sets `isGlowing = false` and `lifetimeAlpha = ALWAYS_OPAQUE` (start alpha 1, end alpha 1, start age 0, end age 1). Other providers of the same class (the vault connection) use the long form and are part 5.

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprite)`: Base2 with the given sprite; `alpha = lifetimeAlpha.startAlpha = 1`; `xd, yd, zd` = the supplied `vx, vy, vz` (exact); remember `xStart, yStart, zStart` = the given position; set the previous position `xo, yo, zo` = start + velocity (per axis), and set `x, y, z` = `xo, yo, zo` (the position is changed directly, the box is not recentred until the particle moves, and the box is not used because there is no collision); one draw `r`, `quadSize = 0.1 * (r * 0.5 + 0.2)` (a direct assignment, with no factor 2: 0.02 to 0.07); one draw `r`, `c = r * 0.6 + 0.4` and `rCol = 0.9 * c`, `gCol = 0.9 * c`, `bCol = c` (a blue-white); `hasPhysics = false`; one draw `r`, `lifetime = (int)(r * 10) + 30`, 30 to 39. |
| Meaning of the velocity | The velocity argument is the **starting offset** from the given position: the particle begins at (position + velocity) and flies to the given position over its life. |
| Tick | Own tick: `xo, yo, zo` = position; compare the old age with `lifetime`, increment, remove when the old age is `lifetime` or more; then with `t = age / lifetime` (float, no partial tick): `f = 1 - t`, `u = t^4`; position `x = xStart + xd * f`, `y = yStart + yd * f - u * 1.2`, `z = zStart + zd * f`. So the particle drops an extra 1.2 blocks toward the end (the fourth power keeps it small until late). |
| Alpha | In the render extract step (before the quad is built) `alpha = lifetimeAlpha.currentAlphaForAge(age, lifetime, partial)`: when start alpha equals end alpha (compared with `Mth.equal`) it is that alpha; otherwise the alpha is interpolated and clamped between them over the normalised-age window (the formula: `inverseLerp((age + partial) / lifetime, startAtNormalizedAge, endAtNormalizedAge)` fed to `clampedLerp(startAlpha, endAlpha, .)`). For the providers here it is always 1. |
| Layer | `OPAQUE` when the life alpha is opaque (both start and end alpha are 1 or more; always for these providers), else `TRANSLUCENT`. |
| Light | Not glowing: `E(defaultLight(partial), t^4)` where `t = age / lifetime` (no partial) and `t^4` is the square of the square of `t`: the particle ramps from the world light to block light 240 as it nears its destination. (Glowing would instead set the block channel to 15.) |
| Sprite | `enchant`: one of 26 glyph sprites chosen at random once (`sga_a` to `sga_z`); `nautilus`: its single sprite. The `nautilus` provider makes the same short-constructor call. |
| Draws | provider sprite (1), Base2 (2), size (1), colour (1), lifetime (1). |

### 3.10 `EndRodParticle`: `end_rod`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: `SimpleAnimatedParticle(level, x, y, z, sprites, gravity 0.0125)` (Base2 with `sprites.first()`; `friction = 0.91`; part 1 §8.2); `xd = vx`, `yd = vy`, `zd = vz` (exact); `quadSize *= 0.75`; one draw `n = nextInt(12)`, `lifetime = 60 + n` (60 to 71); `setFadeColor(0xF2DEC9)` (the integer 15916745); the sprite is set from age 0. |
| Movement | `move` is overridden: no collision. Gravity 0.0125 makes `yd` fall by 0.0005 per tick. |
| Tick | `SimpleAnimatedParticle` tick (part 1 §8.2): base tick, sprite from age (index `age * 7 / lifetime`), and after half life the alpha `1 - (age - lifetime / 2) / lifetime` and the colour 20 percent step toward `#F2DEC9`. |
| Light, layer | Full bright 15728880; `TRANSLUCENT`. |
| Draws | Base2 (2), lifetime (1). |

### 3.11 `TotemParticle`: `totem_of_undying`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: `SimpleAnimatedParticle(level, x, y, z, sprites, gravity 1.25)`; `friction = 0.6` (overrides the 0.91); `xd = vx`, `yd = vy`, `zd = vz` (exact); `quadSize *= 0.75`; one draw `n = nextInt(12)`, `lifetime = 60 + n`; sprite from age 0; then one draw `k = nextInt(4)`: if `k == 0` the colour is `(0.6 + r1 * 0.2, 0.6 + r2 * 0.3, r3 * 0.2)` (a yellow-gold), else `(0.1 + r1 * 0.2, 0.4 + r2 * 0.3, r3 * 0.2)` (a green), where `r1, r2, r3` are three draws taken in that order. |
| Movement | Not overridden, so **block collision applies**; gravity 1.25 makes `yd` fall by 0.05 per tick; friction 0.6 per tick kills horizontal and vertical velocity quickly (a burst that falls). |
| Tick, alpha, light, layer | As end rod (the `SimpleAnimatedParticle` tick: alpha fade in the second half; no fade colour is set); full bright 15728880; `TRANSLUCENT`. |
| Draws | Base2 (2), lifetime (1), colour selector (1), colour (3). |

### 3.12 `HugeExplosionParticle` and `HugeExplosionSeedParticle`: `explosion`, `explosion_emitter`

**`explosion` (`HugeExplosionParticle`)**

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, scale, sprites)`; the provider passes its first velocity argument `vx` as `scale` (the other two are ignored): Base7(0, 0, 0) with `sprites.first()`; `lifetime = 6 + nextInt(4)` (a draw, 6 to 9); one draw `r`, grey `c = r * 0.6 + 0.4`; `quadSize = 2.0 * (1.0 - (float)scale * 0.5)` (direct assignment); the sprite is set from age 0. |
| Tick | Own tick: `xo, yo, zo` = position; compare the old age with `lifetime`, increment, remove when the old age is `lifetime` or more; set the sprite from age (16 sprites: index `age * 15 / lifetime`). No motion, gravity or collision. |
| Light, layer | Full bright 15728880; `OPAQUE`. |
| Override | yes (always created). |
| Draws | Base7 (7), lifetime (1), colour (1). |

**`explosion_emitter` (`HugeExplosionSeedParticle`)**: a no-render particle (group `NO_RENDER`, part 1 §5.7) that spawns `explosion` particles over time. Constructor: `NoRenderParticle(level, x, y, z, 0, 0, 0)` (the `Particle` velocity chain: 6 draws, lifetime then the five velocity draws; the velocity is unused), then `lifetime = 8`. Tick (not the base tick; there is no motion): repeat 6 times: three offsets, each `(nextDouble - nextDouble) * 4.0` taken as two draws per axis in x, y, z order (so a triangular distribution in (-4, 4) per axis); call `level.addParticle(EXPLOSION, x + dx, y + dy, z + dz, age / lifetime, 0, 0)` (float division of the current age by 8 as the `scale` argument, evaluated before the age increment) through the normal entry (part 1 §7.1; `explosion` has the override flag, so it is never culled by distance or status). After the six spawns `age += 1`, and when `age == lifetime` the seed removes itself. So the seed acts on 8 consecutive ticks (ages 0 to 7), 48 explosion particles in all, with `scale` arguments 0, 0.125, 0.25, ..., 0.875, so later puffs are drawn smaller: `quadSize = 2 * (1 - scale / 2)` ranges from 2.0 down to 1.125. The seed's own draws per tick: 36 `nextDouble`.

### 3.13 Fireworks: `firework`, `flash`, and the starter

The firework system has four parts: the **starter** (a no-render particle created by `ClientLevel.createFireworks`, not through a provider), the **spark** (`firework` type), the **flash** (`flash` type, `OverlayParticle`), and the shape generators inside the starter. Sparks and flashes are created by the starter through `ParticleEngine.createParticle` directly, so the distance (32 blocks) and status tests of part 1 §7.1 do **not** apply to them (the starter itself is added with `ParticleEngine.add`, with the same bypass).

**Entry (`ClientLevel.createFireworks(x, y, z, vx, vy, vz, explosions, playSound)`).**
- If the explosion list is **empty**: instead of a starter, spawn small puffs: repeat while `i < nextInt(3) + 2` (the count draw is repeated on every loop test, using the level's random, as read; the expected count is therefore a little over 2.0), with `i` starting at 0 and incremented once per puff: `level.addParticle(POOF, x, y, z, gaussian * 0.05, 0.005, gaussian * 0.05)`, each gaussian a fresh `nextGaussian` (x then z).
- Otherwise add `Starter(level, x, y, z, vx, vy, vz, engine, explosions, playSound)` to the engine (queued like any particle).
The emitter that calls this (the rocket entity's event, and the packet that carries the explosions) is part 7.

**`FireworkExplosion` data read by the starter**: `shape` (an enum of five), `colors` (a list of RGB integers), `fadeColors` (a list), `hasTrail`, `hasTwinkle`. The shape enum, in ordinal order: `SMALL_BALL` (0, name `small_ball`), `LARGE_BALL` (1), `STAR` (2), `CREEPER` (3), `BURST` (4). If `colors` is empty the colour list becomes the single value `DyeColor.BLACK.getFireworkColor()`, the integer 1973019 (`0x1E1B1B`; the black dye constant row's firework colour, not its text-diffuse 1908001).

**Starter construction.** `NoRenderParticle(level, x, y, z)` (the position-only `Particle` chain: 1 draw, the lifetime, which the starter then replaces), then `xd, yd, zd` = the given velocity (the rocket's velocity, exact), the engine, `playSound` and the explosion list stored. An empty list throws an argument error ("Cannot create firework starter with no explosions"). `lifetime = 2 * explosionCount - 1`. Then, scanning the explosions in order, the first one with `hasTwinkle` sets `twinkleDelay = true`, adds 15 to `lifetime` and stops the scan. `life` (the starter's own counter) starts at 0; the engine's `age` is not used.

**Starter tick** (it does not call the base tick; the rocket's velocity is kept for the burst shape and the starter does not move). In order:
1. If `life == 0` and `playSound`: `far` = (squared distance from the camera to the starter) is 256 or more (16 blocks). `large` = the explosion count is 3 or more, or else any explosion's shape is `LARGE_BALL` (checked in list order; the first hit stops the scan). The sound event is chosen: large and far: `FIREWORK_ROCKET_LARGE_BLAST_FAR`; large and near: `..._LARGE_BLAST`; small and far: `..._BLAST_FAR`; small and near: `..._BLAST`. It is played locally at the starter position, source AMBIENT, volume 20.0, pitch `0.95 + r * 0.1` (a draw), with the flag that applies a distance delay (the sound definitions and the delay rule are not in this document).
2. If `life` is even and `life / 2 < explosionCount`: let `e` = explosion number `life / 2` (0-based). Take `trail = hasTrail`, `twinkle = hasTwinkle`, the colour list (replaced by black if empty) and the fade list. Run the shape generator for `e.shape` (below). Then create a `flash` particle at the starter position with the `ColorParticleOption` whose colour integer is the **first colour in the list** (`getInt(0)`, the possibly-replaced list) and zero velocity.
3. `life += 1`.
4. If `life > lifetime`: if `twinkleDelay` and `playSound`, play `FIREWORK_ROCKET_TWINKLE_FAR` when far (the far test is recomputed now) else `FIREWORK_ROCKET_TWINKLE`, AMBIENT, volume 20.0, pitch `0.9 + r * 0.15`; then remove the starter.
Timeline: explosions fire on `life` = 0, 2, 4, ... (every second tick). With n explosions and no twinkle the starter lives until `life` exceeds `2n - 1`, that is it is removed on tick `2n` (the tick during which `life` becomes `2n`); with a twinkle explosion present the removal comes 15 ticks later and the twinkle sound plays then (section 5, E8).

**Spark creation (`createParticle(x, y, z, vx, vy, vz, colors, fades, trail, twinkle)` inside the starter).** Create a `firework` particle at the given position and velocity via `ParticleEngine.createParticle(FIREWORK, ...)`; set `trail`, set `twinkle`, `setAlpha(0.99)`; `setColor(c)` where `c` is a random element of the colour list (`Util.getRandom` = list element at `nextInt(size)`, one draw on the starter's random, which is drawn even with a single-element list); if the fade list is not empty, `setFadeColor(f)` with a random element of the fade list (another draw). Shapes call this once per spark. The draws of the colour and fade selection come **after** the shape's own draws for that spark.

**Shape generators** (all positions are the starter's position; "spark" means one call of the spark creation above; random draws are on the starter's `random`).

1. **Ball** (`SMALL_BALL`: size 0.25, count 2; `LARGE_BALL`: size 0.5, count 4). Three nested loops over integer indices `a` (outermost), `b`, `c` (innermost), each from `-count` to `count`. A cell is skipped when it is interior: when `a` and `b` are both strictly between `-count` and `count`, the innermost index jumps from `-count` straight to `+count` (only those two cells are used); otherwise every `c` is used. (The used cells are the surface of the cube: 98 for count 2, 386 for count 4: `(2n+1)^3 - (2n-1)^3`.) For each used cell, draw three pairs of `nextDouble` in this order: `vx = b + (d1 - d2) * 0.5`, `vy = a + (d3 - d4) * 0.5`, `vz = c + (d5 - d6) * 0.5` (note the pairing: the x component takes the middle index, y the outermost, z the innermost). Then `len = sqrt(vx^2 + vy^2 + vz^2) / size + nextGaussian * 0.05` (one gaussian draw), and the spark velocity is `(vx / len, vy / len, vz / len)`. So sparks leave on a rough sphere of radius about `size` in blocks per tick. Draw order per cell: 6 doubles, 1 gaussian, then the spark's colour draw and fade draw.
2. **Star** (`STAR`) and **Creeper** (`CREEPER`): the shape routine takes `size` 0.5, a coordinate table, and a flag (false for the star, true for the creeper). Steps: (1) one spark at velocity `(t0x * size, t0y * size, 0)` where `(t0x, t0y)` is table row 0; (2) one draw `r`, base angle `ang0 = r * pi` (float); the angle step is `pi * k` with `k` = 0.034 for the creeper and 0.34 for the star (note: the creeper uses the small value); (3) for `m` = 0, 1, 2: `angle = ang0 + m * pi * k` (with `m * pi` computed in float, the product with `k` in double); `prev` = row 0; for each following table row `cur` (rows 1 to end): for `s` = 0.25, 0.5, 0.75, 1.0 (the loop adds 0.25 while `s <= 1.0`): `px = size * lerp(s, prev.x, cur.x)`, `py = size * lerp(s, prev.y, cur.y)` (`lerp(s, a, b) = a + s * (b - a)`), `sx = px * sin(angle)` (that is the z velocity) and `px = px * cos(angle)` (here `sin` and `cos` are the standard double-precision functions, `Math.sin` and `Math.cos`, read in the starter, **not** the 65536-entry table `Mth.sin` of section 2.2 used by flash, note and elder guardian; the difference is under 1e-4 per component but exact velocity comparisons would show it); then for `dir` = -1 and +1: one spark at velocity `(px * dir, py, sx * dir)`; after the four interpolation steps `prev = cur`. Nothing is drawn by the geometry except `r` once; every spark then draws its colour and fade. The star table has 6 rows and the creeper table 12 rows (below); the total spark count is `1 + 3 * (rows - 1) * 4 * 2`: 121 for the star, 265 for the creeper.
3. **Burst** (`BURST`): draw `g1 = nextGaussian * 0.05` and `g2 = nextGaussian * 0.05`; then 70 sparks, each: `vx = xd * 0.5 + nextGaussian * 0.15 + g1`, `vz = zd * 0.5 + nextGaussian * 0.15 + g2`, `vy = yd * 0.5 + nextDouble * 0.5` where `xd, yd, zd` is the starter's velocity (the rocket's). Draw order per spark: gaussian (x), gaussian (z), double (y), then colour and fade draws. Evaluation order in the artifact is x, z, y.

**Shape tables** (read exactly; rows are `(x, y)`; the numbers are the values stored in the starter's static initialiser).

| Row | Star `x` | Star `y` |
|---|---|---|
| 0 | 0.0 | 1.0 |
| 1 | 0.3455 | 0.309 |
| 2 | 0.9511 | 0.309 |
| 3 | 0.3795918367346939 | -0.12653061224489795 |
| 4 | 0.6122448979591837 | -0.8040816326530612 |
| 5 | 0.0 | -0.35918367346938773 |

| Row | Creeper `x` | Creeper `y` |
|---|---|---|
| 0 | 0.0 | 0.2 |
| 1 | 0.2 | 0.2 |
| 2 | 0.2 | 0.6 |
| 3 | 0.6 | 0.6 |
| 4 | 0.6 | 0.2 |
| 5 | 0.2 | 0.2 |
| 6 | 0.2 | 0.0 |
| 7 | 0.4 | 0.0 |
| 8 | 0.4 | -0.6 |
| 9 | 0.2 | -0.6 |
| 10 | 0.2 | -0.4 |
| 11 | 0.0 | -0.4 |

**`SparkParticle` (`firework`).**

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, engine, sprites)`: `SimpleAnimatedParticle(level, x, y, z, sprites, gravity 0.1)` (Base2, friction 0.91); `xd = vx`, `yd = vy`, `zd = vz` (exact); store the engine; `quadSize *= 0.75`; one draw `n = nextInt(12)`, `lifetime = 48 + n` (48 to 59); sprite from age 0. The provider (used by a bare `firework` emission) additionally calls `setAlpha(0.99)` and takes the engine from the client instance. |
| Flags | `trail` and `twinkle`, both false until set by the starter. |
| Tick | `SimpleAnimatedParticle` tick (part 1 §8.2: base tick, sprite from age, alpha fade and colour fade toward the fade colour in the second half), then, if `trail` and `age < lifetime / 2` (integer half) and `(age + lifetime)` is even: create a **trail spark**: a `SparkParticle` at the current position with zero velocity, `setAlpha(0.99)`, the current colour channels, `age = (its own lifetime) / 2` (so it is already at half life and begins fading at once), `twinkle` copied, and add it with `ParticleEngine.add`. The trail spark's fade copy is a **no-op as read**: the class declares its own private fade fields and `hasFade` flag separate from the base class's, and nothing sets them (the starter's `setFadeColor` call reaches the base class's fields), so the copy block never runs and a trail spark never fades its colour, only its alpha (confirmed statically: `SparkParticle` declares its own private `fadeR`, `fadeG`, `fadeB`, `hasFade`; neither it nor the starter sets them, because the starter's `setFadeColor` is the `SimpleAnimatedParticle` method). |
| Twinkle (render) | In the extract step, the spark is **not drawn** when `twinkle` is true and `age >= lifetime / 3` (integer division) and `((age + lifetime) / 3)` (integer division) is odd; it is drawn in every other case. The result is a blink with a period of about two thirds of a lifetime after the first third. |
| Gravity and collision | Gravity 0.1 (`yd` falls by 0.004 per tick); collision on (the class does not override `move`). |
| Light, layer | Full bright; `TRANSLUCENT`. |
| Draws | Base2 (2), lifetime (1). |

**`OverlayParticle` (`flash`).** Option class `ColorParticleOption`.

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, sprite)`: Base2; `lifetime = 4`. |
| Provider | Sprite `get(random)` (1 draw before), then `setColor(option red, green, blue)` and `setAlpha(option alpha)` (the alpha set here is overwritten in the extract step below). |
| Tick | Base tick (no velocity, gravity 0; the particle does not move). |
| Render | In the extract step, before building the quad, with `u = (age + partial - 1) * 0.25`: `alpha = 0.6 - u * 0.5` and the quad half size is `7.1 * sin(u * pi)` (`Mth.sin`). Values at partial 0: age 0: `u` = -0.25, size -5.02 (a negative size mirrors the quad through its centre), alpha 0.725; age 1: size 0, alpha 0.6; age 2: size 5.02, alpha 0.475; age 3: size 7.1, alpha 0.35; age 4: size 5.02, alpha 0.225. The particle is removed on the fifth tick, so it is drawn for ages 0 to 4: a flash that swells from nothing to 7.1 half extent and back. |
| Light, layer | Default light; `TRANSLUCENT`. |
| Draws | provider sprite (1), Base2 (2). |

### 3.14 `FlameParticle` (extends `RisingParticle`): `flame`, `small_flame`, `soul_fire_flame`, `copper_fire_flame`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprite)`: `RisingParticle` (part 1 §8.1): Base7(vx, vy, vz); `friction = 0.96`; each velocity component `= component * 0.01 + supplied`; position jitter (six draws, `(a - b) * 0.05` per axis); `lifetime = (int)(8 / (r * 0.8 + 0.2)) + 4`, range 12 to 44. Nothing more. |
| Movement | `move` is overridden: no collision. Gravity 0, friction 0.96. |
| Size | `getQuadSize(partial)` with `s = (age + partial) / lifetime`: `quadSize * (1 - s * s * 0.5)`: shrinks to half at the end of life. |
| Light | `E(defaultLight(partial), (age + partial) / lifetime)`: block light rises linearly from the world value to 240 over the life. |
| Alpha, colour | 1; white. |
| Layer | `OPAQUE`. |
| Providers | `flame`, `soul_fire_flame`, `copper_fire_flame`: `new FlameParticle(level, x, y, z, vx, vy, vz, sprites.get(random))` (they differ only in the sprite file). `small_flame`: the same, then `scale(0.5)` (`quadSize *= 0.5` and the box 0.1 by 0.1). |
| Draws | provider sprite (1), Base7 (7), position jitter (6), lifetime (1). |

### 3.15 `EmissiveRisingParticle`: `soul`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: `RisingParticle` with `sprites.first()` (the same Rising chain: Base7, jitter, lifetime); then `scale(1.5)` (`quadSize *= 1.5`, box 0.3 by 0.3); then the sprite is set from age 0. |
| Provider | `setAlpha(1.0)` after construction. (`EmissiveProvider`, the glowing variant with `isGlowing = true`, is registered for another type, not in this part: its light is `withBlock(light, 15)`.) |
| Tick | `RisingParticle` tick is the base tick (gravity 0, friction 0.96), then the sprite from age: index `age * 10 / lifetime` over 11 sprites. Collision is **on** (`move` is not overridden). |
| Light | Default (`isGlowing` is false for `soul`). |
| Layer | `TRANSLUCENT`. |
| Draws | Base7 (7), jitter (6), lifetime (1); no provider sprite draw. |

### 3.16 Smoke family: `smoke`, `large_smoke`, `white_smoke` (`BaseAshSmokeParticle`)

All three are `BaseAshSmokeParticle` (part 1 §8.5) with these constructor arguments `(level, x, y, z, vxMul, vyMul, vzMul, ax, ay, az, scale, sprites, colourMul, lifetimeBase, gravity, hasPhysics)`: velocity multipliers `0.1, 0.1, 0.1`; add-on `(vx, vy, vz)` from the provider; `colourMul = 0.3`; `lifetimeBase = 8`; `gravity = -0.1`; `hasPhysics = true`. The shared steps of §8.5 then give: Base7(0, 0, 0); `friction = 0.96`; `speedUpWhenYMotionIsBlocked = true`; `xd = xd * 0.1 + vx` (and y, z likewise); grey `r * 0.3`; `quadSize *= 0.75 * scale`; `lifetime = max((int)(8 / (r * 0.8 + 0.2) * scale), 1)`; sprite from age 0.

| Type | Class | `scale` | Final colour | `quadSize` range | `lifetime` range |
|---|---|---|---|---|---|
| `smoke` | `SmokeParticle` | 1.0 | grey `r * 0.3` (0 to 0.3: near black) | 0.075 to 0.15 | 8 to 40 |
| `large_smoke` | `LargeSmokeParticle` (calls `SmokeParticle` with 2.5) | 2.5 | as `smoke` | 0.1875 to 0.375 | 20 to 100 |
| `white_smoke` | `WhiteSmokeParticle` | 1.0 | overwritten after construction to `(0.7294118, 0.69411767, 0.7607843)` (the RGB24 integer 12235202, `0xBAB1C2`); the grey draw is consumed first | 0.075 to 0.15 | 8 to 40 |

Per-tick behaviour is the base tick (gravity -0.1: `yd` rises by 0.004 per tick; friction 0.96; collision on; when the vertical move is blocked, `xd` and `zd` are multiplied by 1.1) then the sprite from age (8 sprites; index `age * 7 / lifetime`). Size over life: growth rule G. Light default; layer `OPAQUE`. The providers (`SmokeParticle$Provider`, `LargeSmokeParticle$Provider`, `WhiteSmokeParticle$Provider`) pass the scale (1.0, 2.5, 1.0) and the whole sprite set, with no provider sprite draw. Draws: Base7 (7), colour (1), lifetime (1). Lava particles also create `smoke` (3.21).

### 3.17 `CampfireSmokeParticle`: `campfire_cosy_smoke`, `campfire_signal_smoke`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, signal, sprite)`: Base2 with the sprite; `scale(3.0)` (`quadSize *= 3`, box 0.6 by 0.6) then `setSize(0.25, 0.25)` (the box becomes 0.25 by 0.25); if `signal` is true `lifetime = 280 + nextInt(50)` (280 to 329) else `lifetime = 80 + nextInt(50)` (80 to 129) (a draw); `gravity = 3.0E-6`; `xd = vx`; `yd = vy + nextFloat / 500` (a draw: up to 0.002 added); `zd = vz`. The provider passes `signal` = false for the cosy smoke and true for the signal smoke. |
| Provider | Sprite `get(random)` (1 draw, once, never changes), construct, then `setAlpha(0.9)` for cosy and `setAlpha(0.95)` for signal. |
| Tick | Own tick (the base tick is not called, so `friction` is unused and there is no ground factor): (1) `xo, yo, zo` = position; (2) compare the old age with `lifetime` and increment; remove when the old age is `lifetime` or more, **or when `alpha <= 0`**, and stop; (3) `xd += (nextFloat / 5000) * s1` where `s1` is +1 or -1 from a `nextBoolean` (the float draw comes first, then the boolean); the same for `zd` with a second float and a second boolean; (4) `yd -= gravity` (a subtraction of 0.000003 per tick, **not** multiplied by 0.04); (5) `move(xd, yd, zd)` (collision on); (6) if `age >= lifetime - 60` and `alpha > 0.01`: `alpha -= 0.015`. So the fade is exactly 60 ticks long: 60 subtractions of 0.015 happen, on ages `lifetime - 60` to `lifetime - 1`. It ends at about 0 for cosy smoke (0.9) and at 0.05 for signal smoke (0.95). The signal value stays above 0.01, so it never fails the alpha test and signal smoke is always removed by the age test, never by `alpha <= 0`. Part of the final 0.05 is below the fragment discard threshold of 0.1 (section 4), so that tail is invisible. |
| Size | Constant `quadSize` in [0.3, 0.6) (default 0.1 to 0.2 times 3). |
| Light, layer | Default light; `TRANSLUCENT`. |
| Override | yes (both types: always created). |
| Draws | provider sprite (1), Base2 (2), lifetime (1), `yd` noise (1); per tick: 2 floats and 2 booleans. |

### 3.18 `NoteParticle`: `note`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, note, sprite)`; the provider passes its first velocity argument `vx` as `note` (the other two velocity arguments are ignored): Base7(0, 0, 0); `friction = 0.66`; `speedUpWhenYMotionIsBlocked = true`; `xd, yd, zd` each multiplied by 0.009999999776482582; `yd += 0.2`; the colour from `note` as three phases of a sine: `rCol = max(0, sin(2 pi * note) * 0.65 + 0.35)`, `gCol = max(0, sin(2 pi * (note + 1/3)) * 0.65 + 0.35)`, `bCol = max(0, sin(2 pi * (note + 2/3)) * 0.65 + 0.35)` (the offsets are the floats 0.33333334 and 0.6666667; `2 pi` is the float 6.2831855; `sin` is `Mth.sin`, section 2.2); `quadSize *= 1.5`; `lifetime = 6`. |
| Tick | Base tick (gravity 0; friction 0.66; collision on; `speedUp` when the vertical move is blocked). |
| Size | Growth rule G. |
| Light, layer | Default light; `OPAQUE`. |
| Draws | provider sprite (1), Base7 (7). |

The note colours cycle once per unit of `note`; a note block's emitter calls `addParticle(NOTE, x + 0.5, y + 1.2, z + 0.5, note / 24.0, 0, 0)` (read in `NoteBlock`; the y offset 1.2 is given here for part 6 to cite): section 5, E4 gives two values.

### 3.19 `ElderGuardianParticle`: `elder_guardian`

Specified in part 1 §5.9 (class, lifetime 30, group `ELDER_GUARDIANS`, the render state: alpha `0.05 + 0.5 * sin(t * pi)` with `t = (age + partial) / lifetime`; pose: camera rotation, X rotation by `60 - 150 * t` degrees, scale `(0.42553192, -0.42553192, -0.42553192)`, translate `(0, -0.56, 3.5)`; full bright 15728880, no overlay). This part adds only what was read in this round: the constructor is `Particle(level, x, y, z)` (position-only chain: 1 draw, velocity zero), then `gravity = 0` and `lifetime = 30`; the model is the elder guardian layer baked from the client's model set and the texture is the elder guardian entity texture with the translucent entity render type; the particle model class `GuardianParticleModel` adds no geometry of its own (its constructor only wraps the baked root part; the geometry is the elder guardian model of 34). The `Mth.sin` of the alpha is the table sine of section 2.2. Override flag: yes. The particle has no sprite and no definition file.

### 3.20 `PortalParticle` and `ReversePortalParticle`: `portal`, `reverse_portal`

**`portal`**

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprite)`: Base2; `xd = vx`, `yd = vy`, `zd = vz` (exact); `x, y, z` set directly to the given position again; remember `xStart, yStart, zStart` = the position; one draw `r`, `quadSize = 0.1 * (r * 0.2 + 0.5)` (direct assignment: 0.05 to 0.07); one draw `r`, `c = r * 0.6 + 0.4`, `rCol = c * 0.9`, `gCol = c * 0.3`, `bCol = c` (a magenta-purple); one draw `r`, `lifetime = (int)(r * 10) + 40` (40 to 49). |
| Meaning of the velocity | As the enchant particle: the velocity is a starting offset, not a speed. |
| Tick | Own tick: `xo, yo, zo` = position; compare the old age with `lifetime`, increment, remove when the old age is `lifetime` or more; with `t = age / lifetime` (float, no partial): `f = 1 - (-t + 2 t^2) = 1 + t - 2 t^2`; position `x = xStart + xd * f`, `y = yStart + yd * f + (1 - t)`, `z = zStart + zd * f`. `f` is 1 at t = 0, 1.125 at 0.25, 1 at 0.5, 0.625 at 0.75 and 0 at t = 1: the particle starts at (start + velocity + 1 block up), swells outward slightly, then rushes to the start point. |
| Movement | `move` overridden (no collision; not used by the tick anyway). |
| Size | `quadSize * (1 - (1 - t')^2)` with `t' = (age + partial) / lifetime` (grows quickly to full). |
| Light | `E(defaultLight(partial), (age / lifetime)^4)` (`age / lifetime` without partial, squared twice). |
| Layer | `OPAQUE`. |
| Provider | `new PortalParticle(level, x, y, z, vx, vy, vz, sprites.get(random))`. |
| Draws | provider sprite (1), Base2 (2), size (1), colour (1), lifetime (1). |

**`reverse_portal` (`ReversePortalParticle`, extends `PortalParticle`)**

| Field | Value |
|---|---|
| Constructor | The portal constructor, then `quadSize *= 1.5` and `lifetime = (int)(r * 2) + 60` (a draw; 60 or 61, replacing the drawn lifetime). |
| Tick | Own tick: `xo, yo, zo` = position; old-age removal as above; with `t = age / lifetime` the velocity is **added to the position cumulatively**: `x += xd * t`, `y += yd * t`, `z += zd * t` (the start position and the portal formula are not used; here the velocity is an ordinary speed that ramps linearly with age; no collision). |
| Size | `quadSize * (1 - (age + partial) / (lifetime * 1.5))`: shrinks to a third of its size at the end. |
| Light, layer | As `portal` (inherited): the `t^4` emission ramp; `OPAQUE`. |
| Draws | As `portal` plus one lifetime draw. |

### 3.21 `LavaParticle`: `lava`

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, sprite)`: Base7(0, 0, 0); `gravity = 0.75`; `friction = 0.999`; `xd, yd, zd` each multiplied by 0.800000011920929; then `yd = r * 0.4 + 0.05` (a draw: 0.05 to 0.45, replacing `yd`); one draw `r`, `quadSize *= r * 2 + 0.2`; one draw `r`, `lifetime = (int)(16 / (r * 0.8 + 0.2))`, range 16 to 80. |
| Velocity | The provider's `vx, vy, vz` are ignored (the constructor takes none). |
| Tick | Base tick (gravity 0.75: `yd` falls by 0.03 per tick; friction 0.999; collision on), then, if the particle is not removed: with `t = age / lifetime` (float, no partial), draw `r`; if `r > t`, spawn a `smoke` particle at the lava particle's current position with the lava particle's velocity `(xd, yd, zd)` through the normal entry of part 1 §7.1. The chance per tick of a smoke puff is `1 - t`: about certain at birth, never at the end of life. |
| Size | `quadSize * (1 - s * s)` with `s = (age + partial) / lifetime`: shrinks to nothing. |
| Light | `withBlock(defaultLight, 15)` (section 2.1): block light 15 regardless of the world. |
| Layer | `OPAQUE`. |
| Provider | `new LavaParticle(level, x, y, z, sprites.get(random))`. |
| Draws | provider sprite (1), Base7 (7), `yd` (1), size (1), lifetime (1); per tick one draw for the smoke test. |

### 3.22 `SimpleVerticalParticle`: `pause_mob_growth`, `reset_mob_growth`

The class is specified in part 1 §8.3 (private constructor `(level, x, y, z, vx, vy, vz, sprite, up)`: Base7(vx, vy, vz); exact velocity `(vx, vy, vz)`; gravity 0; `yd += 0.03` when `up` else `yd -= 0.03`; `quadSize *= r * 0.6 + 0.5`; `lifetime = 8`; layer `OPAQUE`). Read in this round, the providers: `pause_mob_growth` passes `up = false`, so `yd = vy - 0.03` (the sprite floats down); `reset_mob_growth` passes `up = true`, so `yd = vy + 0.03`. Both draw the sprite at random (1 draw, `glint` is the only sprite). Collision on, friction default 0.98, light default, no size change over life. Draws: provider sprite (1), Base7 (7), size (1).

### 3.23 `GlowParticle`: `glow`, `wax_on`, `wax_off`, `electric_spark`, `scrape`

These five types (assigned to this part by part 1's Open question 9) share one class.

| Field | Value |
|---|---|
| Constructor | `(level, x, y, z, vx, vy, vz, sprites)`: Base7(vx, vy, vz) with `sprites.first()`; `friction = 0.96`; `speedUpWhenYMotionIsBlocked = true`; `quadSize *= 0.75`; `hasPhysics = false`; sprite from age 0. |
| Tick | Base tick, then the sprite from age (1 sprite: no visible change). |
| Light | `E(defaultLight(partial), (age + partial) / lifetime)` (as flame). |
| Layer | `OPAQUE`. Override flag: yes for all five. |
| `glow` provider | Velocity argument `(0.5 - nextDouble, vy, 0.5 - nextDouble)`... precisely: the constructor gets `vx = 0.5 - d1`, `vy` as supplied, `vz = 0.5 - d2` (`d1`, `d2` are two `nextDouble` draws on the provider's engine random, x then z, taken **before** the constructor); then one `nextBoolean` picks the colour: true `(0.6, 1.0, 0.8)`, false `(0.08, 0.4, 0.4)`; then `yd *= 0.2`; if the supplied `vx == 0` and `vz == 0` exactly, `xd *= 0.1` and `zd *= 0.1`; then `lifetime = (int)(8 / (r * 0.8 + 0.2))` with `r` a `nextDouble` on the engine random. |
| `wax_on` | Constructed with zero velocity, colour `(0.91, 0.55, 0.08)`, then `setParticleSpeed(vx * 0.01 / 2, vy * 0.01, vz * 0.01 / 2)` (replacing the velocity), `lifetime = nextInt(30) + 10` on the engine random. |
| `wax_off` | As `wax_on` with colour `(1.0, 0.9, 1.0)`. |
| `electric_spark` | Zero velocity, colour `(1.0, 0.9, 1.0)`, `setParticleSpeed(vx * 0.25, vy * 0.25, vz * 0.25)`, `lifetime = nextInt(2) + 2` on the engine random (2 or 3). |
| `scrape` | Zero velocity, a `nextBoolean` on the engine random picks the colour: true `(0.29, 0.58, 0.51)`, false `(0.43, 0.77, 0.62)`; `setParticleSpeed(vx * 0.01, vy * 0.01, vz * 0.01)`; `lifetime = nextInt(30) + 10`. |
| Note | The wax, spark and scrape providers store two local integers (2 and 4, or 10 and 40) that nothing reads (confirmed leftover: stored and never loaded). The velocity of `wax_*`, `electric_spark` and `scrape` is exact after `setParticleSpeed`; for `glow` it is the damped noisy form above. |

## 4. Rendering of these particles

The vertex shader (`particle.vsh`) projects the position and outputs `texCoord0 = UV0` and `vertexColor = Color * lightmap(UV2)`, plus spherical and cylindrical fog distances. The fragment shader (`particle.fsh`) outputs `texture * vertexColor * ColorModulator` and **discards fragments whose alpha is below 0.1** (the shader has two further compile paths besides the plain one, an order-independent-transparency accumulate path, `OIT_ACCUMULATE`, and an alpha-only phase, `OIT_ALPHA_ONLY`; the discard is common to all variants) (so a fading particle with a small alpha disappears entirely when `alpha * texel alpha` drops under 0.1), then applies fog with the fog colour (the fog parameters are 12 §3). The `OPAQUE` layer uses the opaque particle pipeline (no blending, the default colour target state) and the `TRANSLUCENT` layer the translucent particle pipeline (the standard translucent blend function; its factors were not read, Open question 9); both use the `particles` atlas (sources: the whole `particle` texture directory, empty prefix; `assets/minecraft/atlases/particles.json`). Quads are camera-facing (mode `LOOKAT_XYZ`) for every particle in this part; the half extent is `getQuadSize(partial)` and the colour is `colorFromFloat(alpha, r, g, b)` (section 2.3) (part 1 §4.3, §5.6).

Opaque-layer particles draw with a hard edge (texture alpha below 0.1 discarded). Every class of this part keeps `alpha` 1 on the opaque layer except `dolphin`: `DolphinSpeedProvider` sets `alpha = 1 - r * 0.7` (0.3 to 1.0) on a `SuspendedTownParticle`, whose layer is `OPAQUE`, so the alpha is set but the particle is drawn on the opaque layer (whether the opaque pipeline blends was not read: Open question 9). Every other class here that varies or sets `alpha` below 1 uses the translucent layer: `SimpleAnimatedParticle` (end rod, totem, spark), `CampfireSmokeParticle`, `SpellParticle`, `PlayerCloudParticle` (sneeze 0.4), the flash, and `EmissiveRisingParticle` (soul).

## 5. Worked examples

All use exact arithmetic on the stated draws unless noted.

**E1: heart rise.** A heart has `lifetime` 16 and `yd` about 0.1 (take exactly 0.1). Each tick `move` applies `yd`, then `yd *= 0.86` (gravity 0 and no collision). Heights after each tick: sum over `k = 0..15` of `0.1 * 0.86^k = 0.1 * (1 - 0.86^16) / 0.14`. `0.86^2 = 0.7396`, `^4 = 0.5470`, `^8 = 0.2992`, `^16 = 0.0895`; the sum is `0.1 * 0.9105 / 0.14 = 0.650` blocks. The heart is removed on tick 17. At age 8 and partial 0.5, `getQuadSize` = `quadSize * clamp(32 * 8.5 / 16, 0, 1) = quadSize` (growth finished long before).

**E2: flame size and light.** A flame has `lifetime` 17 (draw `r = 0.5`: `(int)(8 / 0.6) + 4 = 13 + 4`) and `quadSize` 0.15 (`r = 0.5`: `0.1 * 0.75 * 2`). At age 8, partial 0.5: `s = 8.5 / 17 = 0.5`; size = `0.15 * (1 - 0.25 * 0.5) = 0.15 * 0.875 = 0.13125`. Light in a cave at block level 0, sky level 0: block channel `0 + floor(0.5 * 240) = 120`; sky 0. In full daylight (sky 15 = 240) the same particle has sky 240 and block 120.

**E3: cosy campfire smoke alpha.** A cosy smoke has `alpha` 0.9 and `lifetime` 100 (draw `nextInt(50)` = 20). The fade starts at `age >= 40`: ticks with age 40, 41, ... each subtract 0.015, so alpha at age 40 (after the subtraction in that tick) is 0.885, at age 70 it is `0.9 - 31 * 0.015 = 0.435`, and at age 99 it is `0.9 - 60 * 0.015 = 0`; once `alpha > 0.01` fails the subtraction stops and the next tick's `alpha <= 0` test removes it (it would be removed at age 100 anyway). The particle also drifts: each tick `xd` changes by up to 0.0002 (`nextFloat / 5000`) in a random direction, and `yd` starts near 0.0 to 0.002 above `vy`.

**E4: note colour.** `note` = 0: red `max(0, sin(0) * 0.65 + 0.35) = 0.35`, green `max(0, sin(2 pi / 3) * 0.65 + 0.35) = 0.866 * 0.65 + 0.35 = 0.913`, blue `max(0, sin(4 pi / 3) * 0.65 + 0.35) = max(0, -0.2129) = 0`: a green `(0.35, 0.913, 0.0)`. `note` = 0.25: red `sin(pi/2) * 0.65 + 0.35 = 1.0`; green `sin(2 pi * 0.5833)` = -0.5, `max(0, -0.325 + 0.35) = 0.025`; blue `sin(2 pi * 0.9167)` = -0.5, 0.025: a red `(1.0, 0.025, 0.025)`. (Table sine within 1e-4 of these.)

**E5: portal flight.** A portal particle with start position (0, 64, 0), velocity (2, 1, 0) (the starting offset), `lifetime` 40. At age 20, `t = 0.5`: `f = 1 + 0.5 - 2 * 0.25 = 1.0`, so `x = 0 + 2 * 1.0 = 2`, `y = 64 + 1 * 1.0 + (1 - 0.5) = 65.5`, `z = 0`. At age 30, `t = 0.75`: `f = 1 + 0.75 - 1.125 = 0.625`: `x = 1.25`, `y = 64 + 0.625 + 0.25 = 64.875`. At age 40 (removed on the next tick; the last position at age 40): `f = 1 + 1 - 2 = 0`: `x = 0`, `y = 64 + 0 + 0 = 64`. Light at age 20: `t^4 = 0.0625`, block channel `floor(0.0625 * 240) = 15` above the world value.

**E6: enchant glyph flight.** `xStart` 0, velocity `(1.5, 1.0, 0)`, `lifetime` 30. At age 15: `t = 0.5`, `f = 0.5`, `u = t^4 = 0.0625`: `x = 0.75`, `y = 0 + 1.0 * 0.5 - 0.0625 * 1.2 = 0.425`, `z = 0`. At age 30: `x = 0`, `y = 0 + 0 - 1.2 = -1.2` (the final drop). Initial position (age 0, before the first tick) is (1.5, 1.0, 0).

**E7: firework ball counts.** A `LARGE_BALL` (size 0.5, count 4) uses `9^3 - 7^3 = 729 - 343 = 386` cells: outer and middle indices on the boundary (`a` or `b` equal to -4 or 4): `81 - 49 = 32` index pairs with 9 `c` values each (288), plus the 49 interior pairs with 2 `c` values each (98): 386. A `SMALL_BALL` (count 2): `5^3 - 3^3 = 98`: 16 boundary pairs * 5 + 9 interior pairs * 2 = 80 + 18. A star makes `1 + 3 * 5 * 4 * 2 = 121` sparks; a creeper `1 + 3 * 11 * 4 * 2 = 265`. A burst makes 70. Velocity of one ball cell with indices `(a, b, c) = (4, 0, 0)` and zero noise: `vx = 0`, `vy = 4`, `vz = 0`; `len = 4 / 0.5 + g * 0.05 = 8` (g = 0); velocity `(0, 0.5, 0)` per tick.

**E8: starter timeline.** Two explosions, the second has twinkle. `lifetime = 2 * 2 - 1 = 3`, plus 15 for the twinkle explosion: 18. `twinkleDelay` true. Tick 1 (`life` 0): the launch sound is chosen and played (first test is `life == 0`); explosion 0 is created (0 is even and `0 / 2 < 2`), with its flash; `life` becomes 1. Tick 2 (`life` 1): odd, nothing; `life` 2. Tick 3 (`life` 2): explosion 1 (index `2 / 2 = 1`); flash; `life` 3. Ticks 4 to 19: `life` 3, 4, ... 18 become 4 to 19 at the end; at the end of tick 19 `life` is 19, which is greater than 18: the twinkle sound plays and the starter is removed. The same input without the twinkle: `lifetime` 3; at the end of tick 4, `life` becomes 4 > 3: removed on tick 4.

**E9: spark twinkle blink.** A twinkle spark with `lifetime` 50: it can blink from `age >= 16` (`50 / 3 = 16`). Ages 16, 17, 18: `(age + 50) / 3 = 22`, even, shown. Ages 19, 20, 21: 23, odd, hidden. Ages 22, 23, 24: 24, shown. Ages 25, 26, 27: 25, hidden. Ages 28, 29, 30: 26, shown. So it alternates in runs of three ticks.

**E10: explosion emitter.** The seed at (0, 64, 0): on its first tick (age 0) it spawns six `explosion` particles, each at an offset of `(d1 - d2) * 4` per axis, with scale argument 0; each draws `quadSize = 2 * (1 - 0 * 0.5) = 2.0`. On its last tick (age 7) the scale argument is 0.875 and `quadSize = 2 * (1 - 0.4375) = 1.125`. After that tick the age becomes 8 and the seed is removed. An `explosion` particle with `lifetime` 8 shows the sprite at age 4: index `4 * 15 / 8 = 7`.

**E11: spell particle alpha recovery.** A spell particle created with `alpha` 0.8 (entity effect) while the player is scoping from 2 blocks away: `setAlpha(0)` in the constructor sets both `alpha` and `originalAlpha` to 0, so it stays invisible for life. A particle created at 5 blocks (not scoping-close) with `alpha` 0.8 that later has `alpha` forced to 0 by the scoping test when the player starts scoping within 3 blocks recovers once scoping stops: each tick `alpha += (0.8 - alpha) * 0.05`, giving 0.04 after one tick, 0.078 after two.

**E12: poof lifetime and rise.** `r = 0.5` for the lifetime draw: `(int)(16 / 0.6) + 2 = 26 + 2 = 28`. Its `yd` gains `0.04 * 0.1 = 0.004` per tick from gravity -0.1 before friction 0.9 (so the upward speed tends to `0.004 * 0.9 / (1 - 0.9) = 0.036` blocks per tick, the initial velocity decaying away at 0.9 per tick): section 3.5.

## 6. Validation

| # | Check | Expected |
|---|---|---|
| V1 | Types specified in this part | 41 listed in the scope plus 9 siblings: 50 |
| V2 | Distinct provider classes for the 41 listed types | `HeartParticle$Provider`, `HeartParticle$AngryVillagerProvider`, `SuspendedTownParticle$HappyVillagerProvider`, `SuspendedTownParticle$ComposterFillProvider`, `PlayerCloudParticle$Provider`, `ExplodeParticle$Provider`, `PlayerCloudParticle$SneezeProvider`, `CritParticle$Provider`, `CritParticle$DamageIndicatorProvider`, `CritParticle$MagicProvider`, `AttackSweepParticle$Provider`, `DragonBreathParticle$Provider`, `SpellParticle$InstantProvider` (twice), `SpellParticle$MobEffectProvider`, `SpellParticle$WitchProvider`, `FlyTowardsPositionParticle$EnchantProvider`, `EndRodParticle$Provider`, `HugeExplosionSeedParticle$Provider`, `HugeExplosionParticle$Provider`, `FireworkParticles$SparkProvider`, `FireworkParticles$FlashProvider`, `FlameParticle$Provider` (three times), `FlameParticle$SmallFlameProvider`, `EmissiveRisingParticle$Provider`, `LargeSmokeParticle$Provider`, `SmokeParticle$Provider`, `WhiteSmokeParticle$Provider`, `CampfireSmokeParticle$CosyProvider`, `CampfireSmokeParticle$SignalProvider`, `NoteParticle$Provider`, `TotemParticle$Provider`, `ElderGuardianParticle$Provider`, `SpitParticle$Provider`, `PortalParticle$Provider`, `ReversePortalParticle$ReversePortalProvider`, `LavaParticle$Provider`, `SimpleVerticalParticle$PauseMobGrowthProvider`, `SimpleVerticalParticle$ResetMobGrowthProvider`: 41 registrations over 38 distinct provider classes |
| V3 | Sprite sets that coincide (counts) | 8 sprites: cloud, poof, sneeze, spit, large smoke, smoke, white smoke (all `generic_7` to `generic_0`), portal and reverse portal (`generic_0` to `generic_7`), effect and entity effect (`effect_7` to `effect_0`), instant effect and witch (`spell_7` to `spell_0`), end rod and totem (`glitter_7` to `glitter_0`), firework (`spark_7` to `spark_0`), sweep attack (`sweep_0` to `sweep_7`); 3: dragon breath; 26: enchant; 16: explosion; 11: soul; 12: both campfire smokes; 1: all others |
| V4 | Override flags among the 41 | yes for `poof`, `spit`, `sweep_attack`, `damage_indicator`, `explosion`, `explosion_emitter`, `elder_guardian`, `campfire_cosy_smoke`, `campfire_signal_smoke` (9); no for the other 32 (cross-checked against part 1 §2) |
| V5 | Lifetime ranges | heart 16; sweep 4; elder guardian 30; explosion 6 to 9; crit 4 to 10; flame 12 to 44; smoke 8 to 40; large smoke 20 to 100; cloud 17 to 65; spell 8 to 40; dragon breath 20 to 100; happy villager 20 to 100; end rod and totem 60 to 71; spark 48 to 59; enchant 30 to 39; portal 40 to 49; reverse portal 60 or 61; note 6; campfire cosy 80 to 129, signal 280 to 329; lava 16 to 80; vertical 8; seed 8 |
| V6 | Gravity values (multiplier of 0.04 per tick) | crit 0.5; poof -0.1; spit 0.5; spell -0.1; smoke family -0.1; end rod 0.0125; totem 1.25; spark 0.1; lava 0.75; campfire 3.0E-6 (subtracted directly, not times 0.04); all others 0 |
| V7 | Friction values | heart 0.86; crit 0.7; poof 0.9; cloud 0.96; spell 0.96; dragon breath 0.96; flame and soul 0.96; smoke family 0.96; note 0.66; totem 0.6; end rod and spark 0.91; lava 0.999; glow family 0.96; default 0.98 |
| V8 | Fixed colours | white smoke `(0.7294118, 0.69411767, 0.7607843)`; sneeze `(0.22, 1.0, 0.53)` alpha 0.4; end rod fade `#F2DEC9`; firework empty colour list `#1E1B1B` (1973019); witch `(m, 0, m)` with `m` in [0.35, 0.85); dragon breath red 0.7176471 to 0.8745098, green 0, blue 0.8235294 to 0.9764706 |
| V9 | Light overrides | full bright 15728880: sweep, explosion, end rod, totem, spark; emission ramp: flame (`f` = `(age + partial) / lifetime`), glow family (same), portal and reverse portal (`(age / lifetime)^4`), enchant (same, not glowing); `withBlock(15)`: lava; default: all others |
| V10 | Firework counts | seed: 8 ticks, 6 particles per tick, 48; ball 98 or 386 cells; star 121; creeper 265; burst 70; flash lifetime 4; starter lifetime `2n - 1` (+15 with a twinkle explosion) |
| V11 | Sine table | 65536 entries, scale 10430.378350470453; cosine adds 16384 |
| V12 | `SpriteSet.get(age, lifetime)` examples | sweep (8 sprites, lifetime 4): ages 0, 1, 2, 3, 4 give 0, 1, 3, 5, 7; explosion (16 sprites, lifetime 8): age 4 gives 7; dragon breath (3 sprites, lifetime 50): age 25 gives 1 |
| V13 | Spyglass scoping test | distance squared 9.0, first person, scoping |
| V14 | Layer: translucent | cloud, sneeze, effect, instant effect, entity effect, witch, infested, end rod, totem, spark, flash, soul, both campfire smokes; opaque: all others in this part |

## Open questions

1. **Emitter arguments** (parts 6 and 7): this part states what each provider does with its `(vx, vy, vz)`; which arguments the emitting code passes (for example that a sweep attack passes a size in `vx`, a note block passes the note in `vx`, an explosion passes a size) was not read here. The roles of `vx` in 3.4 and 3.12 describe what the provider consumes, not what any emitter sends; the `note / 24.0` and y offset 1.2 of the note block are read (3.18); the other emitters remain unread.
2. **Block collision** (`Entity.collideBoundingBox`, part 1 Open question 12) was not read; the classes marked "Phys yes" (poof, spit, totem, spark, soul, smoke family, campfire smoke, note, lava, vertical) depend on it, and so does the `stoppedByCollision` freeze after a vertical block hit.
3. **Sounds**: `ClientLevel.playLocalSound` (the distance-delay rule and the volume and pitch model) and the six firework sound event definitions were not read; the starter's calls (event, source, volume 20.0, pitch formulas) are given.
4. **`RandomSource`** algorithm (part 1 Open question 6) was not read; `nextGaussian` in particular is used for firework shapes and the packet spread.
5. **`getNearestPlayer`** (resolved): the final boolean selects the filter; false excludes spectators only (3.6). Nothing remains open except the distance test inside the player search, which was not read.
6. **`LightCoordsUtil$BrightnessGetter.DEFAULT`** (how the packed brightness at a position is read) was not read (part 1 Open question 11); the light section 2.1 assumes whole levels from the light engine (32 if present).
7. **Texture content**: the sprite pixel data (alpha, size) of the particle atlas was not read; the discard threshold of 0.1 is the only alpha rule read.
8. **Elder guardian geometry** (`GuardianParticleModel` wraps the elder guardian model layer) is model data (34), not read here.
9. **Blend function factors** of the translucent particle pipeline (`BlendFunction.TRANSLUCENT`), whether the opaque pipeline blends (relevant to the `dolphin` alpha of 0.3 to 1.0 on the opaque layer, 3.2) and the order-independent-transparency variants were not read (part 1 Open question 3). The only alpha rule read for these layers is the `< 0.1` discard in `particle.fsh`.
10. **Trail spark fade copy** (3.13): resolved statically (own private fade fields never set); no client run was done, none is needed for the claim as stated.
11. **Dragon breath ground branch** (3.8): resolved statically from `Particle.move` (`onGround` needs a resolved delta that differs from the requested one, impossible with `hasPhysics` false).
12. **`ambient_entity_effect`** (the 115th definition file, part 1 §9) has no provider; no type in this part uses it.
13. **Other `FlyTowardsPositionParticle` constructor** (the glowing and fading-alpha form used by the vault connection and the ominous spawn) and `FlyStraightTowardsParticle` were not read; they are part 5.
14. **`ParticleEngine.createParticle` bypass**: the claim that firework sparks and flashes skip the 32-block and status tests rests on the starter calling the engine directly (read); whether that matches player-visible behaviour with the MINIMAL particle setting was not tested.
15. **`SpellParticle` colour semantics of emitters** (the `effect` colour for potions and the `entity_effect` alpha) belong to the emitter parts; the `infested` sprite name is read (`infested`, 1 sprite). The types `raid_omen` and `trial_omen` (the `SpellParticle$Provider` that `infested` uses; part 5, section 2.19), `mycelium` (the plain `SuspendedTownParticle$Provider`; part 4, section 10.1) and `sculk_soul` (`EmissiveRisingParticle$EmissiveProvider`) share classes with this part and are specified in those parts.
