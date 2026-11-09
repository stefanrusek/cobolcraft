# 42. Particles, part 1: shared model, registry, options and engine core

| | |
|---|---|
| Covers | The common model every particle part uses: the per-particle record and the emitter record (schemas, number and RNG conventions); the 128 particle types in registration order with ids, option kinds, provider classes and owning part; every `ParticleOptions` class with its wire form and its JSON and NBT form; the client engine core (`ParticleEngine`, `Particle`, `SingleQuadParticle`, render types and groups, limits, culling, ordering, `NoRenderParticle`, `TrackingEmitter`, `ItemPickupParticle`, `ElderGuardianParticleGroup`); the particle definition resources (`ParticleDescription`, `ParticleResources`, sprite sets); the entry path of the Level Particles packet; the shared base-class physics (`RisingParticle`, `SimpleAnimatedParticle`, `SimpleVerticalParticle`, `FallingParticle`, `BaseAshSmokeParticle`); the particle definition files the extraction tool writes. This document is part 1 of the particle round (RS24). The sibling documents are cited as "42-particles-N section" and, in the running text of this document, as "part N": 42-particles-2 simple effect particles, 42-particles-3 fluid and water particles, 42-particles-4 block, item, dust and ambient particles, 42-particles-5 special, sculk, trial, wind and sulfur particles, 42-particles-6 block emitters, 42-particles-7 entity, event, level event and command emitters. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.core.particles.*` (all 22), `net.minecraft.client.particle.*` (the engine, group, render-type, resource, base and provider classes named in the text; the 230 class files of the package were listed and each provider was mapped from `ParticleResources`), `ClientLevel` (`addParticle`, `doAddParticle`, `calculateParticleLevel`), `ClientPacketListener.handleParticleEvent` and `tryAddParticle`, `QuadParticleRenderState`, `LightCoordsUtil`, `ParticleStatus`, `Vec3` stream codec, `ExtraCodecs` colour codecs; data files `assets/minecraft/particles/*.json` (115). |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-15). The particle definition JSON files (sprite lists) are data: the extraction tool copies them (section 9); this document specifies their schema and the engine that reads them, and gives per-type sprite counts only as validation numbers. The behaviour of individual particle classes is in the sibling parts; this part owns what they share. Sound is out of scope. |

Conventions: "tick" is one client tick (20 per second); the particle engine runs once per client tick. Vectors are (x, y, z) with y up. `f32` marks a quantity the artifact holds in single precision; widen to double when stored in a double field, and a reimplementation in doubles differs only in the last digits. `nextFloat` is a uniform float in [0, 1), `nextDouble` a uniform double in [0, 1), `nextBoolean` a fair coin, `nextInt(n)` uniform in [0, n), `nextGaussian` a standard normal double. Names in backticks say where a fact was read; they are not the design. Wire types are those of 00 (Int is a fixed 4-byte big-endian integer, VarInt, Float, Double). Section references "05a" are to `05a-play-clientbound-00-71.md`.

## 1. Common rules for all particle parts

### 1.1 Number and random-number conventions

- **No particle uses a seeded generator.** Every `Particle` owns its own `RandomSource` created unseeded at construction (`RandomSource.create()`); `ParticleEngine` owns one (used by providers and by the group reservoir test), `ClientLevel` owns one (used by the particle-status test), and `ClientPacketListener` owns one (used for the Level Particles packet spread). Behaviour is therefore statistical: tests must inject a sequence of draws, and each part documents the **draw order** because a test that injects draws needs it. `RandomSource.create()` is read as `create(RandomSupport.generateUniqueSeed())`, and `create(long)` builds a `LegacyRandomSource` (read: `RandomSource.create(long)` constructs it directly; the constants of `LegacyRandomSource` read: `MODULUS_BITS` 48, `MODULUS_MASK` 281474976710655, `MULTIPLIER` 25214903917, `INCREMENT` 11, so it is a 48-bit linear congruential generator, and `next(bits)` multiplies, adds and masks with those constants); `generateUniqueSeed` multiplies a static counter by 1181783497276652981 and xors the result with `System.nanoTime`. So every particle generator is a legacy generator with a unique, time-mixed seed; statistical behaviour is all a test can rely on.
- Draw order inside a constructor chain is base class first. Each class body in the parts states its own draws; this part gives the draws of `Particle`, `SingleQuadParticle` and the base classes of section 8.
- Velocities and positions are doubles; sizes, colours, alpha, friction, gravity and roll are `f32`.
- Colours are `f32` channels in [0, 1]. A packed colour is ARGB (alpha in the top byte). Helper conversions read: a channel byte is divided by 255.0 (`ColorParticleOption.getRed` and the like); `ARGB.colorFromFloat(a, r, g, b)` packs four floats, alpha first, converting each of the four channels with `as8BitChannel(c) = floor(c * 255.0f)` (`Mth.floor`, so truncation toward negative infinity, not rounding) and packing the bytes as ARGB; example: alpha 0.55 gives byte 140 and 0.4955 gives 126; `ARGB.vector3fFromRGB24` splits the low 24 bits into three floats.
- Light is a packed integer: `(block << 4) | (sky << 20)`, each level 0 to 15 (`LightCoordsUtil.pack`), so full bright is 15728880 (`0xF000F0`) and "full sky" is 15728640 (`0xF00000`).

### 1.2 Per-particle record

Every particle part describes each particle type with one record with these fields (rows of the table below are the schema; a part writes "inherited" when the class body does not set a field and the base value of section 4 or 8 applies).

| Field | Meaning |
|---|---|
| Registry id, name | Section 2. |
| Options class | Section 3 (`simple` means no option bytes). |
| Provider class | The class that builds the particle from options, position and velocity (column "Provider" of section 2); "plain" providers get no sprite set, "sprite" providers get the type's sprite set (section 6). |
| Particle class and base class | The class that holds the behaviour and its chain to `Particle`. |
| Sprite set | How the sprite is chosen: by age (`SpriteSet.get(age, lifetime)`), at random once at construction (`get(RandomSource)`), the first sprite, or not a sprite (block, item). |
| Lifetime | The formula for `lifetime` in ticks, with its random draws; the base value is in 4.1. |
| Gravity, friction | `gravity` (the multiplier of 0.04 per tick, 4.1) and `friction` (default 0.98). |
| Size | The `quadSize` formula (default in 4.2) and the bounding box (default 0.2 by 0.2). |
| Colour, alpha, fade | `rCol`, `gCol`, `bCol`, `alpha` and any per-tick change. |
| Collision | `hasPhysics` (default true) and `speedUpWhenYMotionIsBlocked` (default false). |
| Light | The override of `getLightCoords`, else 4.1. |
| Render type | Group (section 5) and, for single quads, the layer (4.3). |
| Initial velocity | How the provider's `xd`, `yd`, `zd` arguments and the constructor change the velocity. |
| Emitted by | Cross-references to the emitter records of parts 6 and 7 (and 2 to 5 for particles that spawn particles). |

### 1.3 Emitter record

An emitter is anything that asks for particles. Parts 6 and 7 use this record for every emission site.

| Field | Meaning |
|---|---|
| Source | The block class (`animateTick`), entity class, level event number, game event, command, or packet that emits. |
| Trigger | The condition and the cadence (every client tick, a random chance per tick, an event, a server packet), including any distance or random pre-test. |
| Particle | The particle options, with option values (colour, block state, item, scale). |
| Count | How many particles per trigger, as a number or a loop bound. |
| Position | The spawn position formula (block position plus offsets, entity box fraction), with the draws. |
| Spread | The random offset around the position, per axis. |
| Velocity | The (xd, yd, zd) arguments. |
| Speed | The `maxSpeed` style scalar when the emission is a packet (section 7), else "none". |
| Randomisation | The draw order and distribution of the offsets and velocities. |
| Call | Which entry point of 7.1 is used: normal, always visible, or forced. |

An emission that goes through the Level Particles packet (server-sourced) also fixes the packet fields of 05a 0x30: particle, override limiter, always show, x, y, z, x distance, y distance, z distance, x max speed, y max speed, z max speed, count, randomisation.

## 2. Registry: the 128 particle types

Registration order of `ParticleTypes` is the numeric id (0-based): 128 types, ids 0 to 127, from `angry_villager` to `sulfur_cube_goo`. Wire id is a VarInt (`ByteBufCodecs.registry`); see 05a Particle composite, 04 for registry id assignment, and 46 for the registry ids. Every type is namespaced `minecraft:`.

Columns: **Options**: option kind of section 3 (`simple` = `SimpleParticleType`, no bytes). **Override**: the registration's `overrideLimiter` flag (`ParticleType.getOverrideLimiter`); when true the particle skips the distance and status tests of 7.1. **Provider**: the class (in `net.minecraft.client.particle`) that `ParticleResources.registerProviders` binds to the type; two types can share a provider class with different options or sprite sets. **Sprites**: number of entries of `textures` in `assets/minecraft/particles/<name>.json` (`-` for providers that take no sprite set). **Part**: the sibling part whose index lists the type first and specifies its behaviour (the table follows the siblings' own partition as read in their indexes; where two siblings both treat a type the overlap is named in the notes below; Open question 9).

| Id | Name | Options | Override | Provider | Sprites | Part |
|---|---|---|---|---|---|---|
| 0 | `angry_villager` | simple | no | `HeartParticle$AngryVillagerProvider` | 1 | 2 |
| 1 | `block` | block | no | `TerrainParticle$Provider` | - | 4 |
| 2 | `block_marker` | block | yes | `BlockMarker$Provider` | - | 4 |
| 3 | `bubble` | simple | no | `BubbleParticle$Provider` | 1 | 3 |
| 4 | `sulfur_bubbles` | simple | no | `SulfurBubbleParticle$Provider` | 1 | 5 |
| 5 | `noxious_gas` | simple | no | `NoxiousGasParticle$Provider` | 8 | 5 |
| 6 | `noxious_gas_cloud` | simple | no | `NoxiousGasCloudParticle$Provider` | - | 5 |
| 7 | `geyser` | geyser | yes | `GeyserEruptionParticle$Provider` | - | 5 |
| 8 | `geyser_base` | geyser-base | yes | `GeyserBaseParticle$Provider` | 8 | 5 |
| 9 | `geyser_poof` | geyser-base | yes | `GeyserBaseParticle$Provider` | 8 | 5 |
| 10 | `geyser_plume` | geyser | yes | `GeyserPlumeParticle$Provider` | 8 | 5 |
| 11 | `cloud` | simple | no | `PlayerCloudParticle$Provider` | 8 | 2 |
| 12 | `copper_fire_flame` | simple | no | `FlameParticle$Provider` | 1 | 2 |
| 13 | `crit` | simple | no | `CritParticle$Provider` | 1 | 2 |
| 14 | `damage_indicator` | simple | yes | `CritParticle$DamageIndicatorProvider` | 1 | 2 |
| 15 | `dragon_breath` | power | no | `DragonBreathParticle$Provider` | 3 | 2 |
| 16 | `dripping_lava` | simple | no | `DripParticle$LavaHangProvider` | 1 | 3 |
| 17 | `falling_lava` | simple | no | `DripParticle$LavaFallProvider` | 1 | 3 |
| 18 | `landing_lava` | simple | no | `DripParticle$LavaLandProvider` | 1 | 3 |
| 19 | `dripping_water` | simple | no | `DripParticle$WaterHangProvider` | 1 | 3 |
| 20 | `falling_water` | simple | no | `DripParticle$WaterFallProvider` | 1 | 3 |
| 21 | `dust` | dust | no | `DustParticle$Provider` | 8 | 4 |
| 22 | `dust_color_transition` | dust-transition | no | `DustColorTransitionParticle$Provider` | 8 | 4 |
| 23 | `effect` | spell | no | `SpellParticle$InstantProvider` | 8 | 2 |
| 24 | `elder_guardian` | simple | yes | `ElderGuardianParticle$Provider` | - | 2 |
| 25 | `enchanted_hit` | simple | no | `CritParticle$MagicProvider` | 1 | 2 |
| 26 | `enchant` | simple | no | `FlyTowardsPositionParticle$EnchantProvider` | 26 | 2 |
| 27 | `end_rod` | simple | no | `EndRodParticle$Provider` | 8 | 2 |
| 28 | `entity_effect` | color | no | `SpellParticle$MobEffectProvider` | 8 | 2 |
| 29 | `explosion_emitter` | simple | yes | `HugeExplosionSeedParticle$Provider` | - | 2 |
| 30 | `explosion` | simple | yes | `HugeExplosionParticle$Provider` | 16 | 2 |
| 31 | `gust` | simple | yes | `GustParticle$Provider` | 12 | 5 |
| 32 | `small_gust` | simple | no | `GustParticle$SmallProvider` | 7 | 5 |
| 33 | `gust_emitter_large` | simple | yes | `GustSeedParticle$Provider` | - | 5 |
| 34 | `gust_emitter_small` | simple | yes | `GustSeedParticle$Provider` | - | 5 |
| 35 | `sonic_boom` | simple | yes | `SonicBoomParticle$Provider` | 16 | 5 |
| 36 | `falling_dust` | block | no | `FallingDustParticle$Provider` | 8 | 4 |
| 37 | `firework` | simple | no | `FireworkParticles$SparkProvider` | 8 | 2 |
| 38 | `fishing` | simple | no | `WakeParticle$Provider` | 4 | 3 |
| 39 | `flame` | simple | no | `FlameParticle$Provider` | 1 | 2 |
| 40 | `infested` | simple | no | `SpellParticle$Provider` | 1 | 2 |
| 41 | `cherry_leaves` | simple | no | `FallingLeavesParticle$CherryProvider` | 12 | 4 |
| 42 | `pale_oak_leaves` | simple | no | `FallingLeavesParticle$PaleOakProvider` | 12 | 4 |
| 43 | `red_poplar_leaves` | simple | no | `FallingLeavesParticle$PoplarProvider` | 4 | 4 |
| 44 | `orange_poplar_leaves` | simple | no | `FallingLeavesParticle$PoplarProvider` | 4 | 4 |
| 45 | `yellow_poplar_leaves` | simple | no | `FallingLeavesParticle$PoplarProvider` | 4 | 4 |
| 46 | `tinted_leaves` | color | no | `FallingLeavesParticle$TintedLeavesProvider` | 12 | 4 |
| 47 | `sculk_soul` | simple | no | `EmissiveRisingParticle$EmissiveProvider` | 11 | 5 |
| 48 | `sculk_charge` | sculk-charge | yes | `SculkChargeParticle$Provider` | 7 | 5 |
| 49 | `sculk_charge_pop` | simple | yes | `SculkChargePopParticle$Provider` | 4 | 5 |
| 50 | `soul_fire_flame` | simple | no | `FlameParticle$Provider` | 1 | 2 |
| 51 | `soul` | simple | no | `EmissiveRisingParticle$Provider` | 11 | 2 |
| 52 | `flash` | color | no | `FireworkParticles$FlashProvider` | 1 | 2 |
| 53 | `happy_villager` | simple | no | `SuspendedTownParticle$HappyVillagerProvider` | 1 | 2 |
| 54 | `composter` | simple | no | `SuspendedTownParticle$ComposterFillProvider` | 1 | 2 |
| 55 | `heart` | simple | no | `HeartParticle$Provider` | 1 | 2 |
| 56 | `instant_effect` | spell | no | `SpellParticle$InstantProvider` | 8 | 2 |
| 57 | `item` | item | no | `BreakingItemParticle$Provider` | - | 4 |
| 58 | `vibration` | vibration | yes | `VibrationSignalParticle$Provider` | 1 | 5 |
| 59 | `trail` | trail | no | `TrailParticle$Provider` | 1 | 5 |
| 60 | `pause_mob_growth` | simple | no | `SimpleVerticalParticle$PauseMobGrowthProvider` | 1 | 2 |
| 61 | `reset_mob_growth` | simple | no | `SimpleVerticalParticle$ResetMobGrowthProvider` | 1 | 2 |
| 62 | `item_slime` | simple | no | `BreakingItemParticle$SlimeProvider` | - | 4 |
| 63 | `item_cobweb` | simple | no | `BreakingItemParticle$CobwebProvider` | - | 4 |
| 64 | `item_snowball` | simple | no | `BreakingItemParticle$SnowballProvider` | - | 4 |
| 65 | `large_smoke` | simple | no | `LargeSmokeParticle$Provider` | 8 | 2 |
| 66 | `lava` | simple | no | `LavaParticle$Provider` | 1 | 2 |
| 67 | `mycelium` | simple | no | `SuspendedTownParticle$Provider` | 1 | 4 |
| 68 | `note` | simple | no | `NoteParticle$Provider` | 1 | 2 |
| 69 | `poof` | simple | yes | `ExplodeParticle$Provider` | 8 | 2 |
| 70 | `portal` | simple | no | `PortalParticle$Provider` | 8 | 2 |
| 71 | `rain` | simple | no | `WaterDropParticle$Provider` | 4 | 3 |
| 72 | `smoke` | simple | no | `SmokeParticle$Provider` | 8 | 2 |
| 73 | `white_smoke` | simple | no | `WhiteSmokeParticle$Provider` | 8 | 2 |
| 74 | `sneeze` | simple | no | `PlayerCloudParticle$SneezeProvider` | 8 | 2 |
| 75 | `spit` | simple | yes | `SpitParticle$Provider` | 8 | 2 |
| 76 | `squid_ink` | simple | yes | `SquidInkParticle$Provider` | 8 | 3 |
| 77 | `sweep_attack` | simple | yes | `AttackSweepParticle$Provider` | 8 | 2 |
| 78 | `totem_of_undying` | simple | no | `TotemParticle$Provider` | 8 | 2 |
| 79 | `underwater` | simple | no | `SuspendedParticle$UnderwaterProvider` | 1 | 3 |
| 80 | `splash` | simple | no | `SplashParticle$Provider` | 4 | 3 |
| 81 | `witch` | simple | no | `SpellParticle$WitchProvider` | 8 | 2 |
| 82 | `bubble_pop` | simple | no | `BubblePopParticle$Provider` | 5 | 3 |
| 83 | `current_down` | simple | no | `WaterCurrentDownParticle$Provider` | 1 | 3 |
| 84 | `bubble_column_up` | simple | no | `BubbleColumnUpParticle$Provider` | 1 | 3 |
| 85 | `nautilus` | simple | no | `FlyTowardsPositionParticle$NautilusProvider` | 1 | 2 |
| 86 | `dolphin` | simple | no | `SuspendedTownParticle$DolphinSpeedProvider` | 1 | 2 |
| 87 | `campfire_cosy_smoke` | simple | yes | `CampfireSmokeParticle$CosyProvider` | 12 | 2 |
| 88 | `campfire_signal_smoke` | simple | yes | `CampfireSmokeParticle$SignalProvider` | 12 | 2 |
| 89 | `dripping_honey` | simple | no | `DripParticle$HoneyHangProvider` | 1 | 3 |
| 90 | `falling_honey` | simple | no | `DripParticle$HoneyFallProvider` | 1 | 3 |
| 91 | `landing_honey` | simple | no | `DripParticle$HoneyLandProvider` | 1 | 3 |
| 92 | `falling_nectar` | simple | no | `DripParticle$NectarFallProvider` | 1 | 3 |
| 93 | `falling_spore_blossom` | simple | no | `DripParticle$SporeBlossomFallProvider` | 1 | 3 |
| 94 | `ash` | simple | no | `AshParticle$Provider` | 1 | 4 |
| 95 | `crimson_spore` | simple | no | `SuspendedParticle$CrimsonSporeProvider` | 1 | 4 |
| 96 | `warped_spore` | simple | no | `SuspendedParticle$WarpedSporeProvider` | 1 | 4 |
| 97 | `spore_blossom_air` | simple | no | `SuspendedParticle$SporeBlossomAirProvider` | 1 | 4 |
| 98 | `dripping_obsidian_tear` | simple | no | `DripParticle$ObsidianTearHangProvider` | 1 | 3 |
| 99 | `falling_obsidian_tear` | simple | no | `DripParticle$ObsidianTearFallProvider` | 1 | 3 |
| 100 | `landing_obsidian_tear` | simple | no | `DripParticle$ObsidianTearLandProvider` | 1 | 3 |
| 101 | `reverse_portal` | simple | no | `ReversePortalParticle$ReversePortalProvider` | 8 | 2 |
| 102 | `white_ash` | simple | no | `WhiteAshParticle$Provider` | 1 | 4 |
| 103 | `small_flame` | simple | no | `FlameParticle$SmallFlameProvider` | 1 | 2 |
| 104 | `snowflake` | simple | no | `SnowflakeParticle$Provider` | 8 | 4 |
| 105 | `dripping_dripstone_lava` | simple | no | `DripParticle$DripstoneLavaHangProvider` | 1 | 3 |
| 106 | `falling_dripstone_lava` | simple | no | `DripParticle$DripstoneLavaFallProvider` | 1 | 3 |
| 107 | `dripping_dripstone_water` | simple | no | `DripParticle$DripstoneWaterHangProvider` | 1 | 3 |
| 108 | `falling_dripstone_water` | simple | no | `DripParticle$DripstoneWaterFallProvider` | 1 | 3 |
| 109 | `glow_squid_ink` | simple | yes | `SquidInkParticle$GlowInkProvider` | 8 | 3 |
| 110 | `glow` | simple | yes | `GlowParticle$GlowSquidProvider` | 1 | 2 |
| 111 | `wax_on` | simple | yes | `GlowParticle$WaxOnProvider` | 1 | 2 |
| 112 | `wax_off` | simple | yes | `GlowParticle$WaxOffProvider` | 1 | 2 |
| 113 | `electric_spark` | simple | yes | `GlowParticle$ElectricSparkProvider` | 1 | 2 |
| 114 | `scrape` | simple | yes | `GlowParticle$ScrapeProvider` | 1 | 2 |
| 115 | `shriek` | shriek | no | `ShriekParticle$Provider` | 1 | 5 |
| 116 | `egg_crack` | simple | no | `SuspendedTownParticle$EggCrackProvider` | 1 | 2 |
| 117 | `dust_plume` | simple | no | `DustPlumeParticle$Provider` | 8 | 5 |
| 118 | `trial_spawner_detection` | simple | yes | `TrialSpawnerDetectionParticle$Provider` | 5 | 5 |
| 119 | `trial_spawner_detection_ominous` | simple | yes | `TrialSpawnerDetectionParticle$Provider` | 5 | 5 |
| 120 | `vault_connection` | simple | yes | `FlyTowardsPositionParticle$VaultConnectionProvider` | 1 | 5 |
| 121 | `dust_pillar` | block | no | `TerrainParticle$DustPillarProvider` | - | 4 |
| 122 | `ominous_spawning` | simple | yes | `FlyStraightTowardsParticle$OminousSpawnProvider` | 1 | 5 |
| 123 | `raid_omen` | simple | no | `SpellParticle$Provider` | 1 | 5 |
| 124 | `trial_omen` | simple | no | `SpellParticle$Provider` | 1 | 5 |
| 125 | `block_crumble` | block | no | `TerrainParticle$CrumblingProvider` | - | 4 |
| 126 | `firefly` | simple | no | `FireflyParticle$FireflyProvider` | 1 | 4 |
| 127 | `sulfur_cube_goo` | simple | no | `BreakingItemParticle$SulfurCubeProvider` | 1 | 4 |

Counts (validation, section 11): option kinds: simple 106, block 5 (`block`, `block_marker`, `falling_dust`, `dust_pillar`, `block_crumble`), color 3 (`entity_effect`, `tinted_leaves`, `flash`), spell 2 (`effect`, `instant_effect`), geyser 2, geyser-base 2, and one each of dust, dust-transition, power (`dragon_breath`), item, sculk-charge, shriek, vibration, trail: 128 in all. Override limiter true: 32 types. Parts (the Part column of the table, each type counted once, so the four numbers sum to 128): part 2 has 50 rows, part 3 has 27, part 4 has 26, part 5 has 25 (50 + 27 + 26 + 25 = 128; part 5's own index states 28 owned types because it also takes `pause_mob_growth`, `reset_mob_growth` and `sulfur_cube_goo`, which the Part column gives to parts 2 and 4). The 32 override-limiter types (V2), by id: 2 `block_marker`, 7 `geyser`, 8 `geyser_base`, 9 `geyser_poof`, 10 `geyser_plume`, 14 `damage_indicator`, 24 `elder_guardian`, 29 `explosion_emitter`, 30 `explosion`, 31 `gust`, 33 `gust_emitter_large`, 34 `gust_emitter_small`, 35 `sonic_boom`, 48 `sculk_charge`, 49 `sculk_charge_pop`, 58 `vibration`, 69 `poof`, 75 `spit`, 76 `squid_ink`, 77 `sweep_attack`, 87 `campfire_cosy_smoke`, 88 `campfire_signal_smoke`, 109 `glow_squid_ink`, 110 `glow`, 111 `wax_on`, 112 `wax_off`, 113 `electric_spark`, 114 `scrape`, 118 `trial_spawner_detection`, 119 `trial_spawner_detection_ominous`, 120 `vault_connection`, 122 `ominous_spawning`. Overlaps (a type treated in two siblings): `dolphin` (2 §3.2, 3 §6.2), `nautilus` (2 §3.9, 3 §6.3), `glow` (2 §3.23, 3 §8, 4 §13), the other `GlowParticle` types (2 §3.23, 4 §13), `egg_crack` (2 §3.2, 4 §10.1), `mycelium` (4 §10.1), `pause_mob_growth` and `reset_mob_growth` (2 §3.22, 5 §2.18), `sulfur_cube_goo` (4 §7.4, 5 §2.20), `elder_guardian` (this part §5.9, 2 §3.19), `sonic_boom` (5 §2.5 only), `raid_omen` and `trial_omen` (5 §2.19 as well as the `SpellParticle` provider in 2 §3.7).

Notes on the table:

- Types with a "plain" provider (no sprite set, 14): `block`, `block_marker`, `block_crumble`, `dust_pillar`, `item`, `item_slime`, `item_cobweb`, `item_snowball`, `explosion_emitter`, `gust_emitter_large`, `gust_emitter_small`, `geyser`, `noxious_gas_cloud`, `elder_guardian`. The other 114 types have a sprite set and a definition file.
- Providers shared between types: `FlameParticle$Provider` serves `flame`, `copper_fire_flame` and `soul_fire_flame`; `SpellParticle$InstantProvider` serves `effect` and `instant_effect`; `SpellParticle$Provider` serves `infested`, `raid_omen` and `trial_omen`; `FallingLeavesParticle$PoplarProvider` serves the three poplar leaves; `GeyserBaseParticle$Provider` serves `geyser_base` and `geyser_poof`; `TrialSpawnerDetectionParticle$Provider` serves both detection types; `GustSeedParticle$Provider` serves both gust emitters. How the shared provider tells the types apart (by options, by sprite set, by constructor flag) is in the owning part.
- A particle created by a provider that returns "no particle" is dropped silently (`ParticleEngine.createParticle` returns null); no registered type lacks a provider.

## 3. Particle options and their forms

`ParticleOptions` has one method, `getType()`, returning the `ParticleType`. A `ParticleType` has a JSON/NBT map codec and a stream codec. The dispatching codecs over all types are `ParticleTypes.CODEC` (the data form) and `ParticleTypes.STREAM_CODEC` (wire). Users read in the jar (classes whose bytecode references each field): `CODEC` is used by `ExplosionParticleInfo`, `ClientLevel`, `AmbientParticle` and `AttributeTypes` (the `visual/ambient_particles` environment attribute), `AreaEffectCloud` (NBT), and the enchantment effects `SpawnParticlesEffect` and `ExplodeEffect`; `STREAM_CODEC` is used by `ClientboundLevelParticlesPacket`, `ClientboundExplodePacket`, `ExplosionParticleInfo` and `EntityDataSerializers` (entity metadata). No data-component class references either field. The `/particle` command does not use `ParticleTypes.CODEC`: its argument type reads the type id and then parses the options compound with the type's own map codec through the tag parser and the registry ops (42-particles-7 §2). The stream codec writes the registry id as a VarInt and then the options of that type; the options layouts are below. The JSON form dispatches on the key `type` (read in data files of the jar: `data/minecraft/worldgen/biome/crimson_forest.json` has `"particle": {"type": "minecraft:crimson_spore"}` under `minecraft:visual/ambient_particles`, and `data/minecraft/enchantment/soul_speed.json` has `"particle": {"type": "minecraft:soul"}`), followed by the type's fields.

05a "Particle" lists the layouts per type; this section is the authority for what the fields mean and for the non-wire forms. They agree.

| Options class | Used by (ids) | Wire (after the VarInt type id) | JSON/NBT fields | Notes |
|---|---|---|---|---|
| `SimpleParticleType` | 106 types | nothing | none (unit codec) | The type object is itself the options. |
| `BlockParticleOption` | 1, 2, 36, 121, 125 | VarInt: id in the global block state registry (`Block.BLOCK_STATE_REGISTRY`, 04 §5.1 to §5.3) | `block_state`: a block state (name plus properties) or, as an alternative, a plain block name which becomes that block's default state | Decoding an id outside the registry is the stream codec's error. Getter: the `BlockState`. |
| `ItemParticleOption` | 57 | `ItemStackTemplate` (VarInt item id, VarInt count, DataComponentPatch; 05a ItemStackTemplate, 00 §12) | `item`: an `ItemStackTemplate` | The `Item`-only constructor makes a template of that item with defaults. |
| `ColorParticleOption` | 28, 46, 52 | Int: ARGB colour | `color`: ARGB colour codec (an int, or a list of four floats in the order r, g, b, a, each in [0, 1], converted by `colorFromFloat(a, r, g, b)`) | Getters give red, green, blue, alpha as byte / 255.0. `create(type, r, g, b)` uses alpha 1.0. Note the int is a whole ARGB word on the wire: `tinted_leaves` and `flash` colours therefore carry alpha. |
| `DustParticleOptions` | 21 | Int: colour (RGB24), Float: scale | `color`: RGB colour codec (an int, or a list of three floats), `scale`: float validated in [0.01, 4.0] | Constants: `REDSTONE` is colour 16711680 (`0xFF0000`) scale 1.0. `getColor` splits the low 24 bits to three floats (`vector3fFromRGB24`). |
| `DustColorTransitionOptions` | 22 | Int: from colour, Int: to colour, Float: scale | `from_color`, `to_color` (RGB codec), `scale` | Constant: `SCULK_TO_REDSTONE` from 3790560 (`SCULK_PARTICLE_COLOR`) to 16711680, scale 1.0 (note 1). |
| `SpellParticleOption` | 23, 56 | Int: colour, Float: power | `color` RGB codec optional, default -1; `power` float optional, default 1.0 | Getters: red, green, blue (byte / 255.0), power. `create(type, r, g, b, power)` packs with alpha 1.0. The colour on the wire is an int that is read as ARGB bytes by the getters; the alpha byte is not used by the getters. A colour of -1 reads as white (all bytes 255). |
| `PowerParticleOption` | 15 | Float: power | `power` float optional, default 1.0 | Used by `dragon_breath`. |
| `ScalableParticleOptionsBase` | base of 21 and 22 | Float scale (see the two) | `scale` | `MIN_SCALE` 0.01, `MAX_SCALE` 4.0. The constructor clamps the scale to this range (so a wire value outside it is clamped, a JSON value outside it is an error). |
| `ShriekParticleOption` | 115 | VarInt: delay (ticks) | `delay` int | `getDelay`. |
| `SculkChargeParticleOptions` | 48 | Float: roll | `roll` float | Record; `roll` is radians. |
| `VibrationParticleOption` | 58 | `PositionSource` (05a PositionSource: VarInt type 0 block / 1 entity, then Position or entity id plus Float y offset), VarInt: arrival in ticks | `destination`: a position source, entity sources rejected with the message "Entity position sources are not allowed"; `arrival_in_ticks` int | The JSON form forbids entity sources; the wire form does not. |
| `TrailParticleOption` | 59 | Vec3 as three Doubles (x, y, z, 8 bytes each), Int: colour (RGB24), VarInt: duration | `target` (Vec3 as list of three doubles), `color` RGB codec, `duration` positive int (>= 1) | Record (target, color, duration). The target uses the plain three-double `Vec3.STREAM_CODEC` (24 bytes), not `Vec3.LP_STREAM_CODEC` (the low-precision form, which exists and is not used by this option). |
| `GeyserParticleOptions` | 7, 10 | Int: water blocks | `water_blocks` positive int | Record (type, waterBlocks); one class serves two types, so the type is part of the value. |
| `GeyserBaseParticleOptions` | 8, 9 | Int: water blocks, Float: burst impulse base | `water_blocks` positive int, `burst_impulse_base` float | Record (type, waterBlocks, burstImpulseBase). |
| `ExplosionParticleInfo` | Explosion packet only | `ParticleOptions` (the full particle with its type id, `ParticleTypes.STREAM_CODEC`), Float: scaling, Float: speed | `particle`, `scaling` optional default 1.0, `speed` optional default 1.0 | Not a `ParticleOptions`. 05a Explosion lists it with a weight (`WeightedExplosionParticle`). Meaning: part 7 explosion emitter record. |
| `ParticleLimit` | `spore_blossom_air` only | none | none | Record of one int, `limit`. The only constant is `SPORE_BLOSSOM` = 1000. See 5.4. |

Notes:

1. `DustColorTransitionOptions.SCULK_PARTICLE_COLOR` is the decimal constant 3790560. Splitting it (arithmetic, not a read value): 57 * 65536 = 3735552, remainder 55008 = 214 * 256 + 224, so red 57, green 214, blue 224 (`0x39D6E0`). `REDSTONE_PARTICLE_COLOR` 16711680 is `0xFF0000`.
2. The ids in "Used by" are the section 2 ids.
3. Where a wire colour is "RGB24" the high byte is ignored on read by the particle (via `vector3fFromRGB24`); the wire is still a full Int, so a server writes the 24-bit colour in the low bytes and zero in the high byte. 05a calls the spell colour "Int color"; its alpha byte is unused.

## 4. `Particle` and `SingleQuadParticle`

### 4.1 `Particle` fields and constants

Fields: previous position `xo, yo, zo`; position `x, y, z`; velocity `xd, yd, zd` (blocks per tick, doubles); bounding box; `onGround`; `hasPhysics` (default true); `stoppedByCollision`; `removed`; `bbWidth` and `bbHeight`; `random`; `age`; `lifetime`; `gravity` (f32, default 0); `friction` (f32, default 0.98); `speedUpWhenYMotionIsBlocked` (default false).

Constants read: initial box is a zero-size box; `MAXIMUM_COLLISION_VELOCITY_SQUARED` = 100 squared = 10000.0 (`Mth.square(100.0)`).

**Construction (position only, `Particle(level, x, y, z)`):** 1. `hasPhysics` true, box size 0.6 by 1.8 at first, friction 0.98, speed-up false. 2. `setSize(0.2, 0.2)`, then `setPos(x, y, z)`; `xo, yo, zo` = the position. 3. Lifetime: one `nextFloat` r; `lifetime = (int)(4.0f / (r * 0.9f + 0.1f))` (f32 division, truncation toward zero); range 4 (r near 1) to 40 (r = 0). Velocity is zero.

**Construction with a velocity (`Particle(level, x, y, z, vx, vy, vz)`):** after the steps above (so the lifetime draw is first), five more draws shape the velocity. Let a, b, c be three `nextFloat` draws taken in this order for x, y, z, and d, e two more draws.
1. `xd = vx + (a * 2 - 1) * 0.4`, `yd = vy + (b * 2 - 1) * 0.4`, `zd = vz + (c * 2 - 1) * 0.4` (the offset product is f32).
2. `s = (d + e + 1) * 0.15` (f32; d is drawn before e).
3. `len = sqrt(xd^2 + yd^2 + zd^2)` (double).
4. `xd = xd / len * s * 0.4000000059604645`; `yd = yd / len * s * 0.4000000059604645 + 0.10000000149011612`; `zd = zd / len * s * 0.4000000059604645`.
Note: the supplied velocity is only a bias before normalisation; if all three sums are 0 the division is by 0 (no guard was read: Open question 10). A subclass that wants the exact velocity overwrites `xd, yd, zd` after construction. So the draw order of a provider-built particle is: lifetime (1), x, y, z (3), speed pair (2), then the subclass.

`setPower(p)`: `xd *= p`, `yd = (yd - 0.1) * p + 0.1`, `zd *= p` (the 0.1 is `0.10000000149011612`). `scale(f)`: `setSize(0.2 * f, 0.2 * f)`. `setSize(w, h)`: when changed, the box keeps its horizontal centre and its minimum y, with new width w and height h. `setPos(x, y, z)`: the box is centred on x and z with half width `bbWidth / 2` and extends from y to y + `bbHeight`. `setLocationFromBoundingbox`: x = box centre x, y = box minimum y, z = box centre z.

### 4.2 `Particle.tick` (base behaviour)

Each engine tick, for a live particle, in order:
1. `xo, yo, zo` = current position.
2. Compare the age **before** incrementing with the lifetime, then increment age. If the old age is >= lifetime the particle is removed and the tick ends (so a particle moves for `lifetime` ticks and is removed on the next tick).
3. `yd -= 0.04 * gravity` (0.04 as double, gravity widened).
4. `move(xd, yd, zd)` (4.4).
5. If `speedUpWhenYMotionIsBlocked` and `y == yo` exactly, `xd *= 1.1` and `zd *= 1.1`.
6. `xd, yd, zd` each multiplied by `friction`.
7. If `onGround`, `xd *= 0.699999988079071` and `zd *= 0.699999988079071`.
`isAlive` is `!removed`; `remove()` sets `removed`.

### 4.3 `SingleQuadParticle`

Adds `quadSize`, colour channels `rCol, gCol, bCol` (all start at 1.0), `alpha` (starts at 1.0), `roll`, `oRoll` (both 0), and the current sprite (a `TextureAtlasSprite`).

- **Construction.** Base `Particle` constructor (with or without velocity), then colours and alpha 1.0, then one `nextFloat` r: `quadSize = 0.1 * (r * 0.5 + 0.5) * 2` (f32), so 0.1 to 0.2. The sprite is the constructor argument.
- **Group:** `SINGLE_QUADS` (section 5). **Layer** (`getLayer`, abstract): one of six `SingleQuadParticle$Layer` values chosen by each class: `OPAQUE`, `TRANSLUCENT` (atlas `particles`), `OPAQUE_TERRAIN`, `TRANSLUCENT_TERRAIN` (atlas `blocks`), `OPAQUE_ITEMS`, `TRANSLUCENT_ITEMS` (atlas `items`). The helper `Layer.bySprite(sprite)` selects by the sprite's atlas (blocks, items, else particles) and by whether the sprite's transparency has any translucent pixel (`Transparency.hasTranslucent`, read: `Transparency` holds two flags, `hasTransparent` and `hasTranslucent`; `NativeImage.computeTransparency` scans every pixel of an RGBA image, sets `hasTransparent` for any pixel of alpha 0 and `hasTranslucent` for any pixel of alpha neither 0 nor 255, and a non-RGBA image is NONE; the sprite stores the result computed over its whole image. `bySprite` picks the TRANSLUCENT variant of the sprite's atlas exactly when `hasTranslucent` is set). Opaque layers use the opaque particle pipeline and translucent layers the translucent pipeline (and an order-independent-transparency set); shader details are out of scope.
- **Facing** (`getFacingCameraMode`, default `LOOKAT_XYZ`): `LOOKAT_XYZ` copies the camera rotation quaternion. `LOOKAT_Y` takes the camera quaternion and zeroes its x and z components, keeping y and w (no renormalisation was read), so the quad turns only about the vertical axis. Only `TrialSpawnerDetectionParticle` overrides it (to `LOOKAT_Y`).
- **Roll:** when `roll != 0`, the facing quaternion is rotated about its local Z axis by `lerp(partial, oRoll, roll)` radians (f32) before the quad is built.
- **Quad geometry (render).** With `partial` the partial tick in [0, 1): the position relative to the camera is `lerp(partial, old, current)` per axis, minus the camera position, computed in doubles and cast to float. The size is `getQuadSize(partial)` (default the field `quadSize`; many classes override it with age-dependent growth). The four vertices are the offsets (+1, -1), (+1, +1), (-1, +1), (-1, -1) in the quad's local plane, each rotated by the final quaternion, multiplied by the size, and added to the relative position; so **the side of the drawn square is twice `quadSize`**. UV per vertex, with the sprite's u0, u1, v0, v1: (u1, v1), (u1, v0), (u0, v0), (u0, v1) in the order above. Colour is `colorFromFloat(alpha, rCol, gCol, bCol)`. Light is `getLightCoords(partial)`.
- **Light** default (inherited from `Particle.getLightCoords`): take the block containing (x, y, z); if its chunk is not loaded, 15728640 (full sky, no block light); otherwise `LightCoordsUtil.getLightCoords(level, pos)`: an emissive-rendering block gives 15728880; else the packed brightness at the position (the default brightness getter, read: the SKY-layer brightness and the BLOCK-layer brightness at the position are fetched through `BlockAndLightGetter.getBrightness`, then packed with `LightCoordsUtil.pack(block, sky)`, the form of 1.1), with the block component raised to the block's `getLightEmission` when that is higher than the packed block level (read in `LightCoordsUtil.getLightCoords`: `withBlock(packed, emission)` keeps the bits of the packed value covered by the mask 16711680 (0xFF0000, the sky bits) and replaces the block bits by `emission << 4`). Order read: the emissive-rendering test first, then the brightness, then the emission raise. The light layers themselves are 32.
- **Sprite selection helpers:** `setSpriteFromAge(set)` does nothing when the particle is already removed, else `sprite = set.get(age, lifetime)`; `setSprite(sprite)` assigns directly.
- `scale(f)` multiplies `quadSize` by f and then applies `Particle.scale` (box 0.2 * f).
- `setColor(r, g, b)` assigns the three channels; `setAlpha(a)` the alpha.

### 4.4 Movement and collision (`Particle.move`)

Input: the intended delta (dx, dy, dz) (always the particle's own velocity).
1. If `stoppedByCollision` is set, nothing happens (the particle stays where it is; velocity keeps being integrated by `tick` but no motion is applied).
2. Remember the intended delta.
3. If `hasPhysics`, and the delta is not all zeros, and `dx^2 + dy^2 + dz^2 < 10000`: replace the delta by the result of `Entity.collideBoundingBox` (the shared block-collision resolver used by entities, run with a position collision context at y, the particle's box, the client level, and an empty list of extra entity shapes). Blocks are collided; entities are not.
4. If the resulting delta is not all zeros, move the box by it and recompute (x, y, z) from the box (`setLocationFromBoundingbox`).
5. If the intended dy had absolute value >= 1e-5 (`9.999999747378752E-6`) and the resolved dy has absolute value < that, set `stoppedByCollision` (permanent for this particle).
6. `onGround` = (intended dy differs from the resolved dy) and (intended dy < 0).
7. If intended dx differs from the resolved dx, `xd = 0`; if intended dz differs from resolved dz, `zd = 0`. Velocity y is not reset here.
**The resolver, read in this round** (`Entity.collideBoundingBox` with a `CollisionContext`, the form `Particle.move` calls; `collideWithShapes`, `Direction.axisStepOrder`, `Shapes.collide`, `VoxelShape.collide`, `BlockCollisions`, `AABB.expandTowards`). It is stated here because no other document specifies it (41 covers item-entity gravity, drag and restitution only; the 29 documents do not give it).
1. Query box = the particle box expanded towards the delta: for each axis a negative delta lowers the minimum by that amount, a positive one raises the maximum, zero changes nothing.
2. Collect colliders: the supplied extra entity shapes (empty for particles) plus the block collision shapes met by the query box (step 3). No world-border shape is added for this context form, and entities are not collided.
3. Block collision scan (`BlockCollisions`): the block cells scanned are those from floor(min - 1e-7) - 1 to floor(max + 1e-7) + 1 on each axis, so a one-cell margin. Corner cells (all three cell offsets on the margin; `Cursor3D` type 3) are skipped. Cells on the margin along exactly one axis (type 1) are only used when the block state has a large collision shape; cells on the margin along exactly two axes (type 2) are only used for a moving piston; inner cells always. A cell whose chunk is not available is skipped. The shape comes from the context: the position context asks the block state for its collision shape with that context (blocks whose shape depends on the context see no entity, `isDescending` false, `canStandOnFluid` false, and `isAbove` true when the context y exceeds the cell y plus the shape's maximum y minus 9.999999747378752E-6). A full-cube shape counts only if the query box intersects the cell; any other shape is moved to the cell and kept when it is non-empty and its intersection with the query box shape is non-empty.
4. If the collider list is empty the delta is returned unchanged.
5. Otherwise resolve one axis at a time. The order is Y first, then: X then Z when |dx| >= |dz|, else Z then X (`axisStepOrder` compares |x| with |z| with strict less-than choosing the Z-first order). Start with an accumulated offset (0, 0, 0). For each axis in that order, skip it when its delta is exactly 0; else take the particle box moved by the accumulated offset and clip the axis delta against every collider in turn (`Shapes.collide`): when the running |delta| drops below 1e-7 it returns 0 at once; otherwise each shape clips the running value (`VoxelShape.collide`, which returns the largest movement along the axis, in the delta's direction, that does not push the box into the shape, within the tolerance 1e-7 on the other two axes; the grid search inside it was not traced further, Open question 12). Store the clipped value as that axis of the accumulated offset.
6. The result is the accumulated offset (so an axis with zero delta stays 0).
Constants verified in `Particle`: threshold 1e-5 (9.999999747378752E-6), ground factor 0.699999988079071, collision cap 100.0 (squared 10000), speed-up 1.1, gravity multiplier 0.04. Worked case: a particle falling at dy = -0.3 whose bottom is 0.1 above a full block top, dx = dz = 0: Y is resolved first, the clipped dy is -0.1, `onGround` becomes true (4.4 step 6), dy differs so the velocity y is not zeroed here but `tick` multiplies it by friction.

## 5. Engine core: groups, limits, culling, order

### 5.1 `ParticleRenderType`

A record of a name and a two-letter shorthand. Four values: `SINGLE_QUADS` ("SQ"), `ITEM_PICKUP` ("IP"), `ELDER_GUARDIANS` ("EG"), `NO_RENDER` ("NR"). Each `Particle` returns exactly one from `getGroup()`: `SingleQuadParticle` returns `SINGLE_QUADS`; `NoRenderParticle` (and so `TrackingEmitter`, `GeyserEruptionParticle`, `GustSeedParticle`, `HugeExplosionSeedParticle`, `NoxiousGasCloudParticle` and `FireworkParticles$Starter`) `NO_RENDER`; `ItemPickupParticle` `ITEM_PICKUP`; `ElderGuardianParticle` `ELDER_GUARDIANS`. The shorthand is used by the particle counter string of F3: for each group present, "<shorthand> <count> " then "T<total>" (13 §5 for the F3 overlay).

### 5.2 `ParticleEngine` state

Per level: a map from render type to `ParticleGroup` (an identity map; created lazily, the first time a particle of that type is added); a FIFO queue of live `TrackingEmitter`s; a FIFO queue `particlesToAdd`; a counter map from `ParticleLimit` to int (`trackedParticleCounts`); the `ParticleResources` (providers by id); one `RandomSource`. `setLevel` replaces the level and calls `clearParticles` (clears groups, the add queue, the emitters and the counters) and clears the emitter queue.

Group classes by render type (`createParticleGroup`): `ITEM_PICKUP` makes `ItemPickupParticleGroup`; `ELDER_GUARDIANS` makes `ElderGuardianParticleGroup`; `NO_RENDER` makes `NoRenderParticleGroup`; anything else (`SINGLE_QUADS`) `QuadParticleGroup`.

### 5.3 Creating and adding

- `createParticle(options, x, y, z, vx, vy, vz)`: finds the provider by the registry id of `options.getType()`; if none, returns nothing; otherwise `provider.createParticle(options, level, x, y, z, vx, vy, vz, engineRandom)`. A non-null result is passed to `add`.
- `add(particle)`: if the particle has a `ParticleLimit` (`getParticleLimit`, default none) then, **at call time**, if the counter for that limit is below `limit` the particle is queued and the counter incremented, and otherwise the particle is dropped; a particle without a limit is queued. (Only `spore_blossom_air` returns a limit: 5.4.)
- `createTrackingEmitter(entity, options[, lifetime])`: a `TrackingEmitter` (5.7) with lifetime 3 unless given, appended to the emitter queue.

### 5.4 Limits

| Limit | Value | Where | Rule |
|---|---|---|---|
| Per group | 16384 particles | `ParticleGroup.add` | Reject when the group already has 16384. |
| Reservoir band | sizes 12288 to 16383 (the last 4096) | `ParticleGroup.add` | With size >= 12288, let q = (16384 - size) / 4096 (f32). Accept only when one `nextFloat` draw (engine random) is less than q squared; otherwise reject. Below 12288 always accept. |
| Per type (`ParticleLimit`) | `SPORE_BLOSSOM` = 1000 | `ParticleEngine.add` | At most 1000 live `spore_blossom_air` particles. The counter increments when a particle is queued, decrements when a limited particle dies (removed in `tickParticles`) or when its group refused it. |
| Distance, status | section 7.1 | `ClientLevel.doAddParticle` | Before creation. |

When a group refuses a particle (limit or reservoir), the limit counter is decremented again (`ParticleEngine.tick`), so no particle is lost twice and the count stays exact.

### 5.5 Tick order

One `ParticleEngine.tick`:
1. For every group (in the identity map's iteration order, which is unspecified; groups are independent): `tickParticles`: for each particle in insertion order, call `tick` (any exception is reported as a crash "Ticking Particle"); if it is no longer alive, decrement its limit counter (when it has a limit) and remove it from the queue.
2. If any tracking emitters exist: tick each in queue order, collect those no longer alive, remove them.
3. Drain `particlesToAdd` in FIFO order: for each, get or create the group of the particle's render type and call `group.add`; if it returns false, decrement the particle's limit counter.
Consequences: a particle created during step 1 or 2 of tick N (for example by an emitter) is inserted in step 3 of tick N and is first ticked in tick N + 1. A particle created outside the tick (a packet handler, a block `animateTick`) is inserted in step 3 of the next tick. A particle is drawn in the frame after insertion with `age` 0.

### 5.6 Culling and draw order (render)

Per frame `ParticleEngine.extract` walks the fixed list `RENDER_ORDER` = (`SINGLE_QUADS`, `ITEM_PICKUP`, `ELDER_GUARDIANS`) and, for each group that exists and is not empty, asks it for a render state (`NO_RENDER` is never in the list and never drawn). Culling is per particle in the quad group: a particle is submitted only if its **current position point** (x, y, z, not interpolated, not its box) is inside the view frustum (`Frustum.pointInFrustum`, read: the point minus the stored camera position (x, y, z each subtracted in double, then narrowed to float) is passed to the JOML `FrustumIntersection.testPoint`; the frustum is built by multiplying the projection matrix by the model-view matrix and loading the product into `FrustumIntersection`, whose six-plane extraction is library code and was not read; which projection and view matrices the level renderer supplies is not described in 12, whose §6 is the first-person hand and held item, and was not read here: Open question 16). There is no distance culling at draw time (distance is tested at creation, 7.1), no occlusion culling and no per-particle sorting: particles are bucketed by their layer (6 layers) in group insertion order, so within a layer older particles are drawn first. The draw order between layers, and the translucent blending method (an order-independent-transparency pipeline is set on the three translucent layers), live in the renderer and were not read (Open question 3).

### 5.7 `NoRenderParticle`, `NoRenderParticleGroup`, `TrackingEmitter`

`NoRenderParticle` extends `Particle` (both constructors forward to `Particle`'s) and returns `NO_RENDER`. `NoRenderParticleGroup` returns an empty render state. These particles exist to run `tick` and spawn other particles.

`TrackingEmitter(level, entity, options, lifetime = 3)`: starts at x = entity x, y = entity y + 0.5 * entity height (`getY(0.5)`), z = entity z, with the entity's current velocity passed as the particle velocity (so the base velocity draws happen), stores the entity, options and lifetime, and **calls `tick()` once in the constructor**. Its `tick` (it does not call the base tick; `age` is unused):
1. Repeat 16 times (each repetition is one attempt, a rejected attempt is skipped, not retried): draw three values `ex, ey, ez`, each `nextFloat * 2 - 1` (f32, widened), in that order. If `ex^2 + ey^2 + ez^2 > 1` skip the attempt. Otherwise spawn through `level.addParticle(options, px, py, pz, ex, ey + 0.2, ez)` (normal entry, 7.1) at px = entity x + width * ex / 4 (`getX(ex / 4)`), py = entity y + height * (0.5 + ey / 4) (`getY(0.5 + ey / 4)`), pz = entity z + width * ez / 4. The width and height are the entity's current bounding box dimensions.
2. `life += 1`; when `life >= lifetime` the emitter removes itself.
With the default lifetime 3 it emits at construction, at the first tick and at the second tick: three batches of up to 16 particles. The accepted share of attempts is the volume of the unit ball over the cube [-1, 1] cubed, about 52 percent (arithmetic on the rule, not a constant read).

### 5.8 `ItemPickupParticle` and its group

(Pickup rules, the packet and the server side are in 41; this is the particle.) `ItemPickupParticle(level, itemRenderState, targetEntity, velocity)`: a `Particle` at the item's render position with a lifetime constant `LIFE_TIME` = 3 ticks (its own counter `life`, started at 0), `target` the entity that picks up, `itemRenderState` an entity render state of the item whose outline colour is set to 0. It calls the `Particle` velocity constructor, so it makes the 6 base draws of 4.1 (lifetime, 3 velocity noise, 2 speed); the drawn lifetime is discarded, because `tick` never calls the base tick and the particle removes itself at `life == 3`. At construction it records the target position (`updatePosition`) and copies it to the old position (`saveOldPosition`). The target position is (target x, mean of target y and target eye y, target z). `tick`: `life += 1`; at `life == 3` it removes itself; then it saves the old target position and updates the target position. Group `ITEM_PICKUP`.

Render: for each live pickup particle, with `t = ((life + partial) / 3)^2` (f32), the item is drawn at the render position of the item state moved toward the target: for each axis, `lerp(t, itemRenderState.pos, lerp(partial, targetOld, target))`, minus the camera position. The item is drawn with the normal entity renderer at that offset.

### 5.9 `ElderGuardianParticle` and its group

`ElderGuardianParticle` (type 24, group `ELDER_GUARDIANS`): a `Particle` built with the position-only constructor `Particle(level, x, y, z)` (which makes exactly one draw, the base lifetime draw, 4.1) and velocity zero; that drawn lifetime is discarded, because the constructor then sets gravity 0 and overwrites `lifetime` with 30, a baked guardian particle model (the elder guardian model layer; geometry in 34) and the render type "entity translucent" of the elder guardian texture. No `tick` override: the base tick applies (age and removal at 30; no motion).

Render state per particle, `t = (age + partial) / lifetime` (f32):
1. Alpha `a = 0.05 + 0.5 * sin(t * pi)` (`Mth.sin(double)` is a table lookup, not `Math.sin`: it returns `SIN[(int)((long)(x * 10430.378350470453) & 65535)]` from a 65536-entry float table, 10430.378350470453 being 65536 / (2 pi); the table is filled, read in the static initialiser, with entry i = the float of the true sine of i / 10430.378350470453; the pi in the alpha formula is the float constant 3.1415927 and `t * pi` is widened to double before the lookup), colour white with alpha a (`colorFromFloat(a, 1, 1, 1)`).
2. Pose, applied in this order to an empty pose stack: rotate by the camera rotation quaternion; rotate about the X axis by `60 - 150 * t` degrees; scale by (0.42553192, -0.42553192, -0.42553192); translate by (0, -0.56, 3.5).
3. Submit the model with light 15728880, no overlay, that colour. The group draws it after all quads and pickups.
At t = 0.5: alpha 0.55 (byte 140 after `colorFromFloat`, 1.1). The only creator read is `ClientPacketListener`'s game-event handler: on game event GUARDIAN_ELDER_EFFECT (05a id 10) it calls `ClientLevel.addParticle` with the elder guardian type at the local player's x, y, z with zero velocity (the sound on that path was not detailed here); the visual appearance beyond the pose above was not read.

## 6. Particle definitions, sprite sets and loading

### 6.1 Definition file

`particles/<name>.json` in a resource pack's `assets/<namespace>/` (the lister is `FileToIdConverter.json("particles")`, so a file `assets/minecraft/particles/heart.json` has the id `minecraft:heart`). The schema read by `ParticleDescription.fromJson`: one JSON object; field `textures` (optional): an array of strings, each a sprite id (`minecraft:angry`, which names the file `textures/particle/angry.png` of the `particles` atlas, 14 §3.1 and §7.1). If `textures` is absent the list is empty. Any other field is ignored.

### 6.2 Loading (`ParticleResources.reload`)

1. Registration of providers happens at construction (`registerProviders`, a fixed list that is not in registry order; the order does not matter). A sprite registration creates a `MutableSpriteSet` bound to the type's registry key and puts the provider in a table keyed by registry id; a plain registration just stores the provider.
2. On every resource reload, all `particles/*.json` of all packs (for the same id the pack stacking of 08 §4 decides which pack is on top; the listing (`FileToIdConverter.listMatchingResources`, which calls `ResourceManager.listResources`, read in `FallbackResourceManager`) visits the pushed packs in push order, lowest first, and writes each found id into one map, so a later-pushed pack's file replaces an earlier one's; a pack filter removes the ids it hides from the earlier packs; the result is a sorted map; the order in which packs are pushed is the pack list of 08 §4, not re-read here, Open question 18) are listed and each is parsed on a worker thread. A file whose id has no sprite registration is skipped with a debug message "Redundant texture list for particle". A malformed file is a hard error naming the file.
3. The `particles` atlas is stitched (12 atlases, 14 §3.1). Then for each definition with a sprite list: every sprite id is looked up in the atlas; a missing id adds the atlas's "missing" sprite and is collected for one warning "Missing particle sprites: ..." (sorted, comma separated); after resolving, **an empty list becomes a list of the single missing sprite**. The type's `MutableSpriteSet` is rebound to that immutable list.
4. A sprite-registered type for which no definition was found keeps its initial sprite set, which was never bound (inferred: the first use would fail). The generated pack always provides all 114 (section 9), so this does not occur in the standard world type.

### 6.3 `SpriteSet`

Three operations (the interface): `get(age, lifetime)`, `get(random)`, `first()`.
- `get(age, lifetime)` = `sprites[ age * (n - 1) / lifetime ]` with **integer** multiplication and division, n the number of sprites. At age 0 it is index 0; at age = lifetime it is index n - 1; with n = 1 it is always 0. An age above `lifetime` is out of range for n > 1 and is not guarded (the particle is removed first in all classes read here).
- `get(random)` = `sprites[ random.nextInt(n) ]` (one draw, also with n = 1).
- `first()` = `sprites[0]`.
Each sprite is a sub-rectangle of the particle atlas and gives u0, u1, v0, v1 (the normalised corners); animated `.mcmeta` sprites are handled by the atlas (14 §3.3), not by the particle.

### 6.4 Providers

`ParticleProvider<T>.createParticle(options, level, x, y, z, vx, vy, vz, random)` returns a particle; the `random` is the engine's. A sprite provider is built from the `SpriteSet`; it picks a sprite (usually `get(random)`, one draw, before the constructor), builds the particle and may then call setters (colour, lifetime, scale). The order is therefore: provider's sprite draw, then the constructor chain's draws (4.1), then setter-driven values.

## 7. Entry paths

### 7.1 `ClientLevel.addParticle` and the tests before creation

Four methods (two families, `addParticle` and `addAlwaysVisibleParticle`, two overloads each) exist, all ending in `doAddParticle(options, force, alwaysVisible, x, y, z, vx, vy, vz)`:

| Entry | force | alwaysVisible |
|---|---|---|
| `addParticle(options, x, y, z, vx, vy, vz)` | the type's override limiter | false |
| `addParticle(options, overrideLimiter, alwaysShow, ...)` (packet) | type override OR the argument | the argument |
| `addAlwaysVisibleParticle(options, ...)` | false | true |
| `addAlwaysVisibleParticle(options, overrideLimiter, ...)` | type override OR the argument | true |

`doAddParticle`:
1. Compute the status `calculateParticleLevel(alwaysVisible)` first (it consumes level-random draws even when `force` is set): `status` = the player's Particles option (`ParticleStatus`: ALL id 0, DECREASED id 1, MINIMAL id 2; keys `options.particles.all`, `.decreased`, `.minimal`; 13 §7). If `alwaysVisible` and status is MINIMAL and `nextInt(10) == 0`, status becomes DECREASED. Then, if status is DECREASED and `nextInt(3) == 0`, status becomes MINIMAL (applied to the possibly upgraded value; one draw per test, the second test draws only when the status is DECREASED).
2. If `force`: create the particle at once (no distance test, no status test) and stop.
3. Else if the squared distance from the camera position to (x, y, z) is greater than **1024** (32 blocks), drop the particle.
4. Else if the status is MINIMAL, drop it.
5. Else create the particle (5.3).
So with option ALL every non-forced particle within 32 blocks is created. With DECREASED about one third are dropped (the MINIMAL draw) and the rest created. With MINIMAL none are created except that `alwaysVisible` emissions survive about 10 percent of the time and then are thinned by the DECREASED rule (about 1 in 10 times 2 in 3: 6.7 percent overall, arithmetic). An exception while creating is a crash report naming the particle id, options and position.

### 7.2 The Level Particles packet (05a 0x30)

`ClientPacketListener.handleParticleEvent` runs on the main thread and uses its own random:
- **count = 0**: spawn one particle at (x, y, z) with velocity (xMaxSpeed * xDist, yMaxSpeed * yDist, zMaxSpeed * zDist) (the "speed" mode: the distance fields are the direction components). No draws.
- **count > 0**: loop `count` times:
  - randomisation DEFAULT: per particle, six `nextGaussian` draws in this order: offsets gx, gy, gz, then velocities vx, vy, vz; position = (x + gx * xDist, y + gy * yDist, z + gz * zDist); velocity = (vx * xMaxSpeed, vy * yMaxSpeed, vz * zMaxSpeed).
  - ALTERNATIVE: three `nextDouble` draws for the offsets (position = x + d1 * xDist, etc.: uniform in [0, xDist), not centred); velocity = (xMaxSpeed, yMaxSpeed, zMaxSpeed) exactly, no draws.
  - ALTERNATIVE_WITH_SPEED: as ALTERNATIVE, then three more `nextDouble` draws multiplying the three velocity components in order.
  - Each spawn is `ClientLevel.addParticle(options, overrideLimiter, alwaysShow, ...)` (the packet entry of 7.1); if it throws, the failure is logged ("Could not spawn particle effect") and the loop ends at once (the first failure ends the handler for count > 0; with count = 0 there is only one spawn).
Wire fields and the randomisation numbering: 05a. Emitters that go through this packet (the server side) are part 7's records.

### 7.3 Client-side emission

Block `animateTick` and entity code on the client call the entry points of 7.1 directly: that is where the emitter records of parts 6 and 7 sit. The emitters that live in `ClientLevel` itself and in the engine are not repeated here; they are covered as follows: rain and rain-smoke particles (`tickWeatherEffects`) in 42-particles-3 section 9.1; the barrier and light block-marker particles (`getMarkerParticleTarget`, `block_marker` options) and the attribute-driven ambient particle (`AmbientParticle`) in 42-particles-4 (marker emission and ambient section); the fluid drip spawner (`trySpawnDripParticles`, `spawnParticle`, `spawnFluidParticle`, driven by the fluid's drip particle) in 42-particles-3 section 4.4 and 42-particles-6; the firework starter (`createFireworks`, created directly in the engine, bypassing the tests of 7.1) in 42-particles-2 firework section; the `poof` emissions in 42-particles-6 and 42-particles-7. Sources that call `Level.addParticle` on the **server** reach the client only by the packet of 7.2 (the server side `ServerLevel` sends the packet; the count and spread fields carry the emitter's spread and speed).

## 8. Shared base-class physics

Each of these classes fixes constants of the particle fields of 4. The sibling parts name the constructor arguments they pass.

### 8.1 `RisingParticle` (extends `SingleQuadParticle`)

Constructor `(level, x, y, z, vx, vy, vz, sprite)`: base constructor with velocity (so 6 velocity draws, 4.1); `friction = 0.96`; each velocity component becomes `component * 0.009999999776482582 + supplied component` (the supplied value is the provider's velocity, so the particle's random burst is damped to 1 percent); then position jitter: for each of x, y, z (that order) two `nextFloat` draws `a`, `b`: `pos += (a - b) * 0.05` (f32); then one `nextFloat` r: `lifetime = (int)(8.0 / (r * 0.8 + 0.2)) + 4` (double math, range 12 when r = 1 to 44 when r = 0). Note the position is changed without `setPos` (the box is not recentred until the particle first moves; `xo, yo, zo` keep the original position). Used by `FlameParticle` and `EmissiveRisingParticle` only; the smoke classes (`SmokeParticle`, `LargeSmokeParticle`, `WhiteSmokeParticle`) extend `BaseAshSmokeParticle` (8.5).

### 8.2 `SimpleAnimatedParticle` (extends `SingleQuadParticle`)

Constructor `(level, x, y, z, sprites, gravity)`: sprite = `sprites.first()`; `friction = 0.91`; `gravity` stored. Layer `TRANSLUCENT`. Light always 15728880 (full bright). `setColor(int)` splits an RGB24 into channels (byte / 255.0) and sets rCol, gCol, bCol (the alpha is not touched); `setFadeColor(int)` stores a target colour and sets `hasFade`.
`tick`: 1. base `tick` (4.2); 2. `setSpriteFromAge(sprites)`; 3. if `age > lifetime / 2` (integer division), `alpha = 1 - (age - lifetime / 2) / lifetime` (f32; the half is the integer half); and if `hasFade` also move each colour channel 20 percent of the way to the fade colour: `channel += (fade - channel) * 0.2`. (The colour step happens only inside the second half of the life.) Used by `EndRodParticle`, `TotemParticle`, `SquidInkParticle` and `FireworkParticles$SparkParticle`.

### 8.3 `SimpleVerticalParticle` (extends `SingleQuadParticle`)

Private constructor `(level, x, y, z, vx, vy, vz, sprite, up)`: base constructor with velocity, then `xd = vx`, `zd = vz`, `yd = vy` (exact, overwriting), `gravity = 0`, `yd += 0.03` when `up` else `-= 0.03`, `quadSize *= nextFloat * 0.6 + 0.5` (f32), `lifetime = 8`. Layer `OPAQUE`. Providers `PauseMobGrowthProvider` and `ResetMobGrowthProvider` (types 60, 61) choose `up` (part 5). Draw order: base lifetime, base velocity (5 draws), base quadSize (1), then this constructor's size draw (1).

### 8.4 `FallingParticle` (extends `SingleQuadParticle`; base of `FallingLeavesParticle`)

Constants: `ACCELERATION_SCALE` 0.0025, initial lifetime 300, curve endpoint 300.
Constructor `(level, x, y, z, sprite, gravityScale, windBig, swirl, flowAway, sizeScale, fallSpeed)` (argument names are descriptive; the order is read): base constructor without velocity (lifetime draw, quadSize draw); then, in this order: one `nextBoolean`: `rotSpeed` = -30 degrees in radians when true, +30 when false (f32 radians); a second `nextBoolean`: `spinAcceleration` = -5 degrees (true) or +5 (false) in radians; store `windBig`, `swirl`, `flowAway`; `lifetime = 300`; `gravity = gravityScale * 1.2 * 0.0025`; a third `nextBoolean`: `quadSize = sizeScale * (0.05 when true else 0.075)`, and `setSize(quadSize, quadSize)`; `friction = 1.0`; `yd = -fallSpeed`; one `nextFloat` f: `xaFlowScale = cos(radians(f * 60)) * windBig`, `zaFlowScale = sin(radians(f * 60)) * windBig`, `swirlPeriod = radians(1000 + f * 3000)`. Layer `OPAQUE`.
`tick` (replaces the base tick; `age` is not used; `lifetime` counts down from 300):
1. Old position = position. `lifetime -= 1`; if the old value was <= 0, remove and end.
2. `t = min((300 - lifetime) / 300, 1)` (f32; lifetime already decremented).
3. Wind (dx, dz) starts at 0. If `flowAway`: add `xaFlowScale * t^1.25` to dx and `zaFlowScale * t^1.25` to dz. If `swirl`: add `t * cos(t * swirlPeriod) * windBig` to dx and `t * sin(t * swirlPeriod) * windBig` to dz. (The `xd`, `zd` update below is applied in any case, with dx = dz = 0 when neither flag is set.)
4. `xd += dx * 0.0024999999441206455`, `zd += dz * 0.0024999999441206455`, `yd -= gravity`.
5. `rotSpeed += spinAcceleration / 20`; `oRoll = roll`; `roll += rotSpeed / 20`.
6. `move(xd, yd, zd)` (4.4). Then remove the particle if `onGround`, or if `lifetime < 299` and (`xd == 0` or `zd == 0`). If it was removed, end.
7. `xd, yd, zd` each multiplied by `friction` (1.0, so unchanged).
The leaf particles of part 4 supply the argument values.

### 8.5 `BaseAshSmokeParticle` (extends `SingleQuadParticle`; direct subclasses read: `AshParticle`, `DustPlumeParticle`, `GeyserBaseParticle`, `NoxiousGasParticle`, `SmokeParticle`, `WhiteAshParticle`, `WhiteSmokeParticle`; large smoke is indirect, `LargeSmokeParticle` extends `SmokeParticle`)

Constructor `(level, x, y, z, vxMul, vyMul, vzMul, ax, ay, az, scale, sprites, colourMul, lifetimeBase, gravity, hasPhysics)`: base constructor (sprite `first()`) **with zero velocity** (so the 5 + 1 velocity-normalisation draws of 4.1 apply with a zero bias); `friction = 0.96`; `gravity` stored; `speedUpWhenYMotionIsBlocked = true`; each velocity component is multiplied by its multiplier then the add-on is added (`xd = xd * vxMul + ax`, and likewise y and z); one `nextFloat` r: grey `r * colourMul` for all three channels; `quadSize *= 0.75 * scale`; one `nextFloat` r2: `lifetime = (int)(lifetimeBase / (r2 * 0.8 + 0.2) * scale)`, then `lifetime = max(lifetime, 1)`; the sprite is set from age (age 0); `hasPhysics` stored. Layer `OPAQUE`.
`getQuadSize(partial)`: `quadSize * clamp((age + partial) / lifetime * 32, 0, 1)`: the quad grows from zero to full size over the first 1/32 of its life. `tick`: base tick then `setSpriteFromAge`.

### 8.6 Related shared size rule

`HeartParticle` (read) uses the same growth rule as 8.5's `getQuadSize` (`quadSize * clamp((age + partial) / lifetime * 32, 0, 1)`); the owning part states it.

## 9. Files the extraction tool must write

Cross-reference GAP-3, 14 §3.1 and §7.1, 22.

1. **Particle definitions.** Copy every file of `assets/minecraft/particles/*.json` of the jar verbatim to the generated resource pack at `assets/minecraft/particles/`: **115 files** (counted from the archive: `unzip -Z1 | grep -v '/$'`). The set is: one file for each of the 114 sprite-registered particle types, named by the type name of section 2 (the 14 plain types have none), plus `ambient_entity_effect.json` (8 textures), which matches no registered type and is skipped by the loader (6.2, "Redundant texture list"). The tool does not need to understand the textures; it needs the file names to equal the 114 names, and to keep `ambient_entity_effect.json` (harmless) or drop it.
2. **Atlas definition** `assets/minecraft/atlases/particles.json` (14 §3.1, `particles` directory source, prefix empty) and the **particle PNG textures** `assets/minecraft/textures/particle/*.png` (and their `.mcmeta` where present) so every sprite id of the definitions resolves. (The standard pack: 14 §7.1; the Faithful pack's count of 297 particle PNGs is (recalled, not verified) and was not checked against the pack source. Validation number read from the vanilla jar: 301 files under `assets/minecraft/textures/particle/`, of which 300 are `.png` and 1 is `.mcmeta`.)
3. **Language file keys** for the particle status option (`options.particles`, `.all`, `.decreased`, `.minimal`) come from the generated `lang/en_us.json` (no particle-specific key beyond these was read).
4. The client's particle **provider table** (section 2) is code, not data: the implementation binds provider behaviours to the 128 registry names.
Because a pack below the generated one may replace definitions (08 §4), the engine must not assume the sprite counts of section 2; it reads `textures` and uses `SpriteSet` of 6.3.

## 10. Worked examples

**E1: base velocity, positive case.** A `Particle` is built with velocity (0, 0, 0). Draws, in order: lifetime r = 0.5; a = 0.75, b = 0.5, c = 0.25 for x, y, z; d = 0.5, e = 0.5.
- lifetime = (int)(4 / (0.5 * 0.9 + 0.1)) = (int)(4 / 0.55) = (int)7.27 = 7.
- xd = (0.75 * 2 - 1) * 0.4 = 0.2; yd = 0; zd = (0.25 * 2 - 1) * 0.4 = -0.2.
- s = (0.5 + 0.5 + 1) * 0.15 = 0.3. len = sqrt(0.04 + 0 + 0.04) = 0.28284.
- xd = 0.2 / 0.28284 * 0.3 * 0.4000000059604645 = 0.08485; yd = 0 + 0.10000000149011612 = 0.1; zd = -0.08485.

**E2: lifetime range.** r = 0 gives (int)(4 / 0.1) = 40; r near 1 gives (int)(4 / 1.0) = 4.

**E3: sprite by age.** Sprite set of 8 entries, lifetime 20: age 10 gives index 10 * 7 / 20 = 70 / 20 = 3; age 20 gives 140 / 20 = 7; age 0 gives 0. A set of 16 entries with lifetime 6: age 3 gives 3 * 15 / 6 = 7.

**E4: reservoir.** The quad group holds 14336 particles. q = (16384 - 14336) / 4096 = 0.5; q squared = 0.25. A new particle is accepted only if the engine's `nextFloat` is < 0.25 (a draw of 0.3 rejects). At exactly 16384 it is always rejected (with no draw); at 12287 it is always accepted.

**E5: limits.** 1000 live `spore_blossom_air` particles: the 1001st creation is dropped inside `ParticleEngine.add` and the counter stays 1000. When one dies in `tickParticles` the counter is 999.

**E6: distance and status.** Camera at (0, 64, 0), a non-forced emission at (30, 64, 12): squared distance 900 + 144 = 1044 > 1024, dropped (even with status ALL). At (30, 64, 8): 964, created. A forced type (for example `explosion`, override true) at distance 200 is created, subject to nothing. Status DECREASED: the draw `nextInt(3)` returns 0 (probability 1/3): the status becomes MINIMAL and the particle is dropped.

**E7: simple animated alpha and fade.** lifetime 20, age 15, `hasFade` with fade colour (1, 0, 0) and the current colour (0, 0, 1): `age > 10` so alpha = 1 - (15 - 10) / 20 = 0.75; the colour moves to (0.2, 0, 0.8) (r: 0 + (1 - 0) * 0.2, b: 1 + (0 - 1) * 0.2). At age 10 exactly nothing changes (the test is a strict greater-than).

**E8: pickup interpolation.** `life` = 1 and `partial` = 0.5: t = (1.5 / 3)^2 = 0.25. With the item at x = 10 and the interpolated target at x = 12 the drawn x is 10 + 0.25 * (12 - 10) = 10.5 (before subtracting the camera).

**E9: elder guardian.** age 10, partial 0.5, lifetime 30: t = 10.5 / 30 = 0.35; the sine argument is 0.35 pi = 1.09956; the table index is (long)(1.09956 * 10430.378350470453) = (long)11468.8 = 11468, and `SIN[11468]` is the table sine of 11468 / 65536 turns, about 0.89097 (the table is the true sine at the grid points, read; the index uses the float pi 3.1415927, so 0.35 times 3.1415927 times 10430.378 is about 11468.8, the same truncation to 11468); alpha = 0.05 + 0.5 * 0.89097 = 0.49549, so the byte is floor(0.49549 * 255) = 126 (1.1); the X rotation is 60 - 150 * 0.35 = 7.5 degrees.

**E10: tracking emitter.** Entity box 0.6 wide and 1.8 high at (0, 64, 0), lifetime 3. The first draws (ex, ey, ez) = (0.5, 0.0, -0.5) have squared length 0.5, accepted: position = (0 + 0.6 * 0.5 / 4, 64 + 1.8 * (0.5 + 0) , 0 + 0.6 * -0.5 / 4) = (0.075, 64.9, -0.075), velocity (0.5, 0.2, -0.5). A draw (0.9, 0.9, 0.9) has squared length 2.43 > 1 and is skipped. 16 attempts per tick, three ticks of emission.

**E11: packet speed mode.** count 0, x/y/z distance (0, 1, 0) and max speed (0, 0.2, 0): one particle at the given position with velocity (0, 0.2, 0). count 5, DEFAULT, distances (0.5, 0.5, 0.5), speeds (0.1, 0.1, 0.1): five particles, each offset by a gaussian times 0.5 per axis and a velocity of a gaussian times 0.1 per axis.

**E12: falling leaf shape.** Constructor with `sizeScale` 1: draws give `rotSpeed` = +-30 degrees = +-0.5236 rad; `quadSize` 0.05 or 0.075; gravity = `gravityScale` * 0.003. `lifetime` 150 gives t = 0.5; with `flowAway` and `windBig` 2 and f giving angle 0: `xaFlowScale` = 2, so dx = 2 * 0.5^1.25 = 0.8409 and xd gains 0.8409 * 0.0025 = 0.0021.

## 11. Validation

| # | Check | Expected |
|---|---|---|
| V1 | Particle types in `ParticleTypes` static initialiser | 128, ids 0 to 127, first `angry_villager` (0), last `sulfur_cube_goo` (127) |
| V2 | Registrations with the override-limiter flag set | 32 |
| V3 | Option kinds | simple 106, block 5, color 3, spell 2, geyser 2, geyser-base 2, dust 1, dust-transition 1, power 1, item 1, sculk-charge 1, shriek 1, vibration 1, trail 1 (total 128) |
| V4 | Provider registrations | 128: 114 sprite-based, 14 plain |
| V5 | Definition files in the jar (`assets/minecraft/particles`, files only) | 115: 114 matching types plus `ambient_entity_effect` |
| V6 | Wire sizes | `dust` options 8 bytes; `dust_color_transition` 12; `effect` and `instant_effect` 8; `entity_effect`, `tinted_leaves`, `flash` 4; `dragon_breath` 4; `sculk_charge` 4; `shriek` 1+ (VarInt); `trail` 28 + VarInt; `geyser`, `geyser_plume` 4; `geyser_base`, `geyser_poof` 8 |
| V7 | Limits | group 16384, reservoir from 12288, spore blossom 1000, distance 32 blocks (1024 squared) |
| V8 | Tracking emitter default | lifetime 3, 16 attempts per tick, 3 batches |
| V9 | Pickup particle | lifetime constant 3, interpolation factor ((life + partial) / 3) squared |
| V10 | Elder guardian | lifetime 30, alpha 0.05 + 0.5 sin(pi t), light 15728880 |
| V11 | Decoded-wire clamps (derived expectation from the verified clamp to [0.01, 4.0] in `ScalableParticleOptionsBase`, not separately observed) | `dust` scale 0.0 reads as 0.01; 9.0 reads as 4.0 |
| V12 | `SpriteSet.get(age, lifetime)` | integer arithmetic as 6.3 (E3) |
| V13 | Distance and status | E6 |
| V14 | The six verified sibling-facing constants | `Particle` friction 0.98, size 0.2 by 0.2, `0.04` gravity multiplier, ground factor 0.699999988079071, lifetime `4 / (r * 0.9 + 0.1)`, quad side twice `quadSize` |

## Open questions
1. Closed: the JSON type key is `type` (read in biome and enchantment data files, section 3). The number is kept so that sibling parts' cross-references stay valid.
2. Whether the JSON list form of the colour codecs is validated for range (values outside [0, 1]) was not read.
3. The renderer's draw order between the six layers, the blending and the order-independent-transparency pipeline for the translucent layers, and the shaders were not read; only per-layer insertion order inside a layer is established (5.6).
4. Closed: `Transparency.hasTranslucent` and its computation from the sprite pixels were read (4.3). Which of the block and item sprites in the atlases contain translucent pixels is texture data, not read. Number kept for cross-references.
5. Closed: `colorFromFloat` truncates, `floor(channel * 255.0f)` per channel (section 1.1). `ARGB.vector3fFromRGB24` was read only at its call sites. Number kept for cross-references.
6. Closed: `RandomSource.create()` is a legacy 48-bit generator with a unique seed, constants read (section 1.1). Number kept for cross-references.
7. The F3 particle counter string is described from `ParticleEngine.countParticles`; its place in the overlay is 13 §5 (not re-verified here).
8. Closed: `Mth.sin(double)` is a 65536-entry table lookup whose entries are the float of the true sine at the grid points (sections 5.9, E9). Number kept for cross-references.
9. The Part column follows the siblings' own partition as read in their indexes (section 2); the earlier inferred assignment was replaced. Types treated in two siblings are listed in the note under the counts; whether a type should have a single owner is an editorial choice, and no other column depends on it.
10. `Particle` velocity construction divides by the length of a random vector without a zero guard; whether a zero-length vector can occur (three draws all exactly 0.5) was not examined (probability negligible).
11. Closed: the default brightness getter was read (4.3). Number kept for cross-references.
12. The resolver of 4.4 was read down to `Shapes.collide`; the grid search inside `VoxelShape.collide` (`collideX`, index search with a 1e-7 tolerance) and the per-block collision shapes (block shape data) were not traced here; a document that owns entity collision should specify them, and until then the exact clipped distance against a non-cube shape is a blocking cross-reference. Searched: 41 and the 29 documents (none specifies the resolver).
13. `FireworkParticles` (starter, spark, flash, overlay) and the individual particle classes were read only to the extent needed for the class table of section 2 and for the shared bases; their behaviour belongs to the sibling parts.
14. How the particle definition of a sprite-registered type behaves when no pack supplies any definition at all (6.2 point 4) was inferred, not exercised.
15. The geometry of `GuardianParticleModel` and the elder guardian texture are model data (34), not read here.
16. `Frustum.pointInFrustum` and the matrix product were read (5.6); the JOML plane extraction inside `FrustumIntersection.testPoint` (library code) and the projection and view matrices the level renderer passes in were not read; 12 does not describe them (its §6 is the first-person hand and held item). Searched: the section headings of 12-client-rendering.md.
17. Closed: the users of `ParticleTypes.CODEC` and `STREAM_CODEC` were found by scanning every class that references `ParticleTypes` (section 3). Number kept for cross-references.
18. The listing rule (later-pushed pack wins) was read in `FallbackResourceManager.listResources` (6.2 point 2); that the pack list is pushed lowest priority first was not re-read in `MultiPackResourceManager`, and the stacking rule is 08 section 4 (not re-read). The strings `Redundant texture list for particle: {}` and `Missing particle sprites: {}` were confirmed in `ParticleResources`.
