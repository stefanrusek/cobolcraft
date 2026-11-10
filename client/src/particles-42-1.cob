*> Particles part 1 (docs/protocol/42-particles-1-shared-model-engine.md): section 1 conventions
*> (colour channel conversion, light packing, the legacy generator seed) and section 2 the registry
*> of the 128 particle types (PART-TYPE, PART-TYPE-ID).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-CHANNEL.
*> Section 1.1: USING channel (COMP-2, 0 to 1), byte out: as8BitChannel(c) = floor(c x 255)
*> (Mth.floor: toward negative infinity), kept within 0..255.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   COMP-2.
 LINKAGE SECTION.
 01 L-CHANNEL              COMP-2.
 01 L-BYTE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CHANNEL L-BYTE.
     COMPUTE WS-V = L-CHANNEL * 255
     COMPUTE L-BYTE = FUNCTION MAX(0, FUNCTION MIN(255, FUNCTION INTEGER(WS-V)))
     GOBACK.
 END PROGRAM PART-CHANNEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-COLOR-PACK.
*> Section 1.1 (ARGB.colorFromFloat): USING alpha, red, green, blue (COMP-2), packed ARGB out
*> (BINARY-DOUBLE, 0 to 4294967295), alpha first, each channel through PART-CHANNEL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-A                    COMP-2.
 01 L-R                    COMP-2.
 01 L-G                    COMP-2.
 01 L-B                    COMP-2.
 01 L-PACKED               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-A L-R L-G L-B L-PACKED.
     CALL "PART-CHANNEL" USING L-A WS-B
     COMPUTE L-PACKED = WS-B * 16777216
     CALL "PART-CHANNEL" USING L-R WS-B
     COMPUTE L-PACKED = L-PACKED + WS-B * 65536
     CALL "PART-CHANNEL" USING L-G WS-B
     COMPUTE L-PACKED = L-PACKED + WS-B * 256
     CALL "PART-CHANNEL" USING L-B WS-B
     ADD WS-B TO L-PACKED
     GOBACK.
 END PROGRAM PART-COLOR-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-LIGHT-PACK.
*> Section 1.1 (LightCoordsUtil.pack): USING block level, sky level (0 to 15), packed out:
*> (block << 4) | (sky << 20).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-BLOCK                BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-PACKED               BINARY-LONG.
 PROCEDURE DIVISION USING L-BLOCK L-SKY L-PACKED.
     COMPUTE L-PACKED = L-BLOCK * 16 + L-SKY * 1048576
     GOBACK.
 END PROGRAM PART-LIGHT-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-RANDOM-SEED.
*> Section 1.1 (LegacyRandomSource.setSeed): USING seed (BINARY-DOUBLE, non-negative), state out:
*> (seed xor 0x5DEECE66D) and 2^48 - 1; the generator steps with TINT-LEGACY-NEXT (multiplier
*> 25214903917, increment 11, 48-bit mask).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-MULT                BINARY-DOUBLE VALUE 25214903917.
 01 WS-TWO48               BINARY-DOUBLE VALUE 281474976710656.
 01 WS-BYTES               BINARY-LONG VALUE 8.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-STATE                BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-SEED L-STATE.
     COMPUTE L-STATE = FUNCTION MOD(L-SEED, WS-TWO48)
     CALL "CBL_XOR" USING WS-MULT L-STATE BY VALUE WS-BYTES
     COMPUTE L-STATE = FUNCTION MOD(L-STATE, WS-TWO48)
     GOBACK.
 END PROGRAM PART-RANDOM-SEED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-TYPE.
*> Section 2: USING registry id (0 to 127), name (PIC X(32), without minecraft:), options kind
*> (PIC X(16): simple, block, color, spell, geyser, geyser-base, dust, dust-transition, power, item,
*> sculk-charge, shriek, vibration, trail), override limiter (0/1), provider class (PIC X(56)),
*> sprite count (0 for a plain provider), part (2 to 5); a name of spaces for an id out of range.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 WS-T1                PIC X(3456) VALUE
     "angry_villager                  simple          0HeartParticle$AngryVillagerProvider                     012" &
     "block                           block           0TerrainParticle$Provider                                004" &
     "block_marker                    block           1BlockMarker$Provider                                    004" &
     "bubble                          simple          0BubbleParticle$Provider                                 013" &
     "sulfur_bubbles                  simple          0SulfurBubbleParticle$Provider                           015" &
     "noxious_gas                     simple          0NoxiousGasParticle$Provider                             085" &
     "noxious_gas_cloud               simple          0NoxiousGasCloudParticle$Provider                        005" &
     "geyser                          geyser          1GeyserEruptionParticle$Provider                         005" &
     "geyser_base                     geyser-base     1GeyserBaseParticle$Provider                             085" &
     "geyser_poof                     geyser-base     1GeyserBaseParticle$Provider                             085" &
     "geyser_plume                    geyser          1GeyserPlumeParticle$Provider                            085" &
     "cloud                           simple          0PlayerCloudParticle$Provider                            082" &
     "copper_fire_flame               simple          0FlameParticle$Provider                                  012" &
     "crit                            simple          0CritParticle$Provider                                   012" &
     "damage_indicator                simple          1CritParticle$DamageIndicatorProvider                    012" &
     "dragon_breath                   power           0DragonBreathParticle$Provider                           032" &
     "dripping_lava                   simple          0DripParticle$LavaHangProvider                           013" &
     "falling_lava                    simple          0DripParticle$LavaFallProvider                           013" &
     "landing_lava                    simple          0DripParticle$LavaLandProvider                           013" &
     "dripping_water                  simple          0DripParticle$WaterHangProvider                          013" &
     "falling_water                   simple          0DripParticle$WaterFallProvider                          013" &
     "dust                            dust            0DustParticle$Provider                                   084" &
     "dust_color_transition           dust-transition 0DustColorTransitionParticle$Provider                    084" &
     "effect                          spell           0SpellParticle$InstantProvider                           082" &
     "elder_guardian                  simple          1ElderGuardianParticle$Provider                          002" &
     "enchanted_hit                   simple          0CritParticle$MagicProvider                              012" &
     "enchant                         simple          0FlyTowardsPositionParticle$EnchantProvider              262" &
     "end_rod                         simple          0EndRodParticle$Provider                                 082" &
     "entity_effect                   color           0SpellParticle$MobEffectProvider                         082" &
     "explosion_emitter               simple          1HugeExplosionSeedParticle$Provider                      002" &
     "explosion                       simple          1HugeExplosionParticle$Provider                          162" &
     "gust                            simple          1GustParticle$Provider                                   125".
    05 WS-T2                PIC X(3456) VALUE
     "small_gust                      simple          0GustParticle$SmallProvider                              075" &
     "gust_emitter_large              simple          1GustSeedParticle$Provider                               005" &
     "gust_emitter_small              simple          1GustSeedParticle$Provider                               005" &
     "sonic_boom                      simple          1SonicBoomParticle$Provider                              165" &
     "falling_dust                    block           0FallingDustParticle$Provider                            084" &
     "firework                        simple          0FireworkParticles$SparkProvider                         082" &
     "fishing                         simple          0WakeParticle$Provider                                   043" &
     "flame                           simple          0FlameParticle$Provider                                  012" &
     "infested                        simple          0SpellParticle$Provider                                  012" &
     "cherry_leaves                   simple          0FallingLeavesParticle$CherryProvider                    124" &
     "pale_oak_leaves                 simple          0FallingLeavesParticle$PaleOakProvider                   124" &
     "red_poplar_leaves               simple          0FallingLeavesParticle$PoplarProvider                    044" &
     "orange_poplar_leaves            simple          0FallingLeavesParticle$PoplarProvider                    044" &
     "yellow_poplar_leaves            simple          0FallingLeavesParticle$PoplarProvider                    044" &
     "tinted_leaves                   color           0FallingLeavesParticle$TintedLeavesProvider              124" &
     "sculk_soul                      simple          0EmissiveRisingParticle$EmissiveProvider                 115" &
     "sculk_charge                    sculk-charge    1SculkChargeParticle$Provider                            075" &
     "sculk_charge_pop                simple          1SculkChargePopParticle$Provider                         045" &
     "soul_fire_flame                 simple          0FlameParticle$Provider                                  012" &
     "soul                            simple          0EmissiveRisingParticle$Provider                         112" &
     "flash                           color           0FireworkParticles$FlashProvider                         012" &
     "happy_villager                  simple          0SuspendedTownParticle$HappyVillagerProvider             012" &
     "composter                       simple          0SuspendedTownParticle$ComposterFillProvider             012" &
     "heart                           simple          0HeartParticle$Provider                                  012" &
     "instant_effect                  spell           0SpellParticle$InstantProvider                           082" &
     "item                            item            0BreakingItemParticle$Provider                           004" &
     "vibration                       vibration       1VibrationSignalParticle$Provider                        015" &
     "trail                           trail           0TrailParticle$Provider                                  015" &
     "pause_mob_growth                simple          0SimpleVerticalParticle$PauseMobGrowthProvider           012" &
     "reset_mob_growth                simple          0SimpleVerticalParticle$ResetMobGrowthProvider           012" &
     "item_slime                      simple          0BreakingItemParticle$SlimeProvider                      004" &
     "item_cobweb                     simple          0BreakingItemParticle$CobwebProvider                     004".
    05 WS-T3                PIC X(3456) VALUE
     "item_snowball                   simple          0BreakingItemParticle$SnowballProvider                   004" &
     "large_smoke                     simple          0LargeSmokeParticle$Provider                             082" &
     "lava                            simple          0LavaParticle$Provider                                   012" &
     "mycelium                        simple          0SuspendedTownParticle$Provider                          014" &
     "note                            simple          0NoteParticle$Provider                                   012" &
     "poof                            simple          1ExplodeParticle$Provider                                082" &
     "portal                          simple          0PortalParticle$Provider                                 082" &
     "rain                            simple          0WaterDropParticle$Provider                              043" &
     "smoke                           simple          0SmokeParticle$Provider                                  082" &
     "white_smoke                     simple          0WhiteSmokeParticle$Provider                             082" &
     "sneeze                          simple          0PlayerCloudParticle$SneezeProvider                      082" &
     "spit                            simple          1SpitParticle$Provider                                   082" &
     "squid_ink                       simple          1SquidInkParticle$Provider                               083" &
     "sweep_attack                    simple          1AttackSweepParticle$Provider                            082" &
     "totem_of_undying                simple          0TotemParticle$Provider                                  082" &
     "underwater                      simple          0SuspendedParticle$UnderwaterProvider                    013" &
     "splash                          simple          0SplashParticle$Provider                                 043" &
     "witch                           simple          0SpellParticle$WitchProvider                             082" &
     "bubble_pop                      simple          0BubblePopParticle$Provider                              053" &
     "current_down                    simple          0WaterCurrentDownParticle$Provider                       013" &
     "bubble_column_up                simple          0BubbleColumnUpParticle$Provider                         013" &
     "nautilus                        simple          0FlyTowardsPositionParticle$NautilusProvider             012" &
     "dolphin                         simple          0SuspendedTownParticle$DolphinSpeedProvider              012" &
     "campfire_cosy_smoke             simple          1CampfireSmokeParticle$CosyProvider                      122" &
     "campfire_signal_smoke           simple          1CampfireSmokeParticle$SignalProvider                    122" &
     "dripping_honey                  simple          0DripParticle$HoneyHangProvider                          013" &
     "falling_honey                   simple          0DripParticle$HoneyFallProvider                          013" &
     "landing_honey                   simple          0DripParticle$HoneyLandProvider                          013" &
     "falling_nectar                  simple          0DripParticle$NectarFallProvider                         013" &
     "falling_spore_blossom           simple          0DripParticle$SporeBlossomFallProvider                   013" &
     "ash                             simple          0AshParticle$Provider                                    014" &
     "crimson_spore                   simple          0SuspendedParticle$CrimsonSporeProvider                  014".
    05 WS-T4                PIC X(3456) VALUE
     "warped_spore                    simple          0SuspendedParticle$WarpedSporeProvider                   014" &
     "spore_blossom_air               simple          0SuspendedParticle$SporeBlossomAirProvider               014" &
     "dripping_obsidian_tear          simple          0DripParticle$ObsidianTearHangProvider                   013" &
     "falling_obsidian_tear           simple          0DripParticle$ObsidianTearFallProvider                   013" &
     "landing_obsidian_tear           simple          0DripParticle$ObsidianTearLandProvider                   013" &
     "reverse_portal                  simple          0ReversePortalParticle$ReversePortalProvider             082" &
     "white_ash                       simple          0WhiteAshParticle$Provider                               014" &
     "small_flame                     simple          0FlameParticle$SmallFlameProvider                        012" &
     "snowflake                       simple          0SnowflakeParticle$Provider                              084" &
     "dripping_dripstone_lava         simple          0DripParticle$DripstoneLavaHangProvider                  013" &
     "falling_dripstone_lava          simple          0DripParticle$DripstoneLavaFallProvider                  013" &
     "dripping_dripstone_water        simple          0DripParticle$DripstoneWaterHangProvider                 013" &
     "falling_dripstone_water         simple          0DripParticle$DripstoneWaterFallProvider                 013" &
     "glow_squid_ink                  simple          1SquidInkParticle$GlowInkProvider                        083" &
     "glow                            simple          1GlowParticle$GlowSquidProvider                          012" &
     "wax_on                          simple          1GlowParticle$WaxOnProvider                              012" &
     "wax_off                         simple          1GlowParticle$WaxOffProvider                             012" &
     "electric_spark                  simple          1GlowParticle$ElectricSparkProvider                      012" &
     "scrape                          simple          1GlowParticle$ScrapeProvider                             012" &
     "shriek                          shriek          0ShriekParticle$Provider                                 015" &
     "egg_crack                       simple          0SuspendedTownParticle$EggCrackProvider                  012" &
     "dust_plume                      simple          0DustPlumeParticle$Provider                              085" &
     "trial_spawner_detection         simple          1TrialSpawnerDetectionParticle$Provider                  055" &
     "trial_spawner_detection_ominous simple          1TrialSpawnerDetectionParticle$Provider                  055" &
     "vault_connection                simple          1FlyTowardsPositionParticle$VaultConnectionProvider      015" &
     "dust_pillar                     block           0TerrainParticle$DustPillarProvider                      004" &
     "ominous_spawning                simple          1FlyStraightTowardsParticle$OminousSpawnProvider         015" &
     "raid_omen                       simple          0SpellParticle$Provider                                  015" &
     "trial_omen                      simple          0SpellParticle$Provider                                  015" &
     "block_crumble                   block           0TerrainParticle$CrumblingProvider                       004" &
     "firefly                         simple          0FireflyParticle$FireflyProvider                         014" &
     "sulfur_cube_goo                 simple          0BreakingItemParticle$SulfurCubeProvider                 014".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-ROW OCCURS 128 TIMES.
       10 WS-NAME          PIC X(32).
       10 WS-OPTIONS       PIC X(16).
       10 WS-OVERRIDE      PIC 9.
       10 WS-PROVIDER      PIC X(56).
       10 WS-SPRITES       PIC 99.
       10 WS-PART          PIC 9.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-NAME                 PIC X(32).
 01 L-OPTIONS              PIC X(16).
 01 L-OVERRIDE             BINARY-LONG.
 01 L-PROVIDER             PIC X(56).
 01 L-SPRITES              BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-NAME L-OPTIONS L-OVERRIDE L-PROVIDER L-SPRITES L-PART.
     MOVE SPACES TO L-NAME L-OPTIONS L-PROVIDER
     MOVE 0 TO L-OVERRIDE L-SPRITES L-PART
     IF L-ID >= 0 AND L-ID <= 127
         MOVE WS-NAME(L-ID + 1) TO L-NAME
         MOVE WS-OPTIONS(L-ID + 1) TO L-OPTIONS
         MOVE WS-OVERRIDE(L-ID + 1) TO L-OVERRIDE
         MOVE WS-PROVIDER(L-ID + 1) TO L-PROVIDER
         MOVE WS-SPRITES(L-ID + 1) TO L-SPRITES
         MOVE WS-PART(L-ID + 1) TO L-PART
     END-IF
     GOBACK.
 END PROGRAM PART-TYPE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-TYPE-ID.
*> Section 2: USING name (PIC X(32), with or without the minecraft: namespace), registry id out
*> (-1 when unknown).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32).
 01 WS-REST                PIC X(22).
 01 WS-I                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-OPTIONS             PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-ROWNAME             PIC X(32).
 LINKAGE SECTION.
 01 L-NAME                 PIC X(32).
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ID.
     MOVE L-NAME TO WS-NAME
     IF WS-NAME(1:10) = "minecraft:"
         MOVE WS-NAME(11:22) TO WS-REST
         MOVE WS-REST TO WS-NAME
     END-IF
     MOVE -1 TO L-ID
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 127
         MOVE WS-I TO WS-ID
         CALL "PART-TYPE" USING WS-ID WS-ROWNAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES
             WS-PART
         IF WS-ROWNAME = WS-NAME
             MOVE WS-I TO L-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PART-TYPE-ID.
