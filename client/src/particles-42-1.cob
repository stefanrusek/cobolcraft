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

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-OPT-DECODE.
*> Section 3: USING PB-BUFFER (positioned after the VarInt type id), registry id, PART-OPTIONS out.
*> Reads the wire layout of the options class of the type's option kind (PART-TYPE): block = VarInt
*> state id; item = ItemStackTemplate (item, count, DataComponentPatch, read with PB-GET-ITEM-STACK on a
*> count-first copy); color, dust, dust-transition, spell = Int colours as unsigned words; the dust
*> scale is clamped to 0.01 .. 4.0 (ScalableParticleOptionsBase); power, sculk-charge Floats; shriek
*> VarInt; vibration = PositionSource then VarInt arrival; trail = three Doubles, Int, VarInt;
*> geyser Int; geyser-base Int and Float. PO-ERROR 1 on a short or malformed read; the caller's
*> PO-BLOCK-STATE-COUNT (0 = unchecked) bounds the block state id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TM-==.
 01 WS-NAME                PIC X(32).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-KIND                PIC X(16).
 01 WS-STATES              BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-DOUBLE              FLOAT-LONG.
 01 WS-REMAIN              BINARY-LONG.
 01 WS-HEADER              BINARY-LONG.
 01 WS-REST                PIC X(20000).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-ID                   BINARY-LONG.
 COPY CLPART.
 PROCEDURE DIVISION USING PB-BUFFER L-ID PART-OPTIONS.
     MOVE PO-BLOCK-STATE-COUNT TO WS-STATES
     INITIALIZE PART-OPTIONS
     MOVE WS-STATES TO PO-BLOCK-STATE-COUNT
     MOVE 1.0 TO PO-SCALE PO-POWER
     CALL "PART-TYPE" USING L-ID WS-NAME WS-KIND WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
     MOVE WS-KIND TO PO-KIND
     IF WS-NAME = SPACES
         MOVE 1 TO PO-ERROR
         GOBACK
     END-IF
     EVALUATE WS-KIND
         WHEN "block"
             CALL "PB-GET-VARINT" USING PB-BUFFER PO-BLOCK-STATE
             IF PO-BLOCK-STATE < 0
                     OR (PO-BLOCK-STATE-COUNT > 0 AND PO-BLOCK-STATE >= PO-BLOCK-STATE-COUNT)
                 MOVE 1 TO PO-ERROR
             END-IF
         WHEN "item"
             PERFORM READ-ITEM
         WHEN "color"
             PERFORM READ-COLOR
             MOVE WS-DOUBLE TO PO-COLOR
         WHEN "dust"
             PERFORM READ-COLOR
             MOVE WS-DOUBLE TO PO-COLOR
             PERFORM READ-SCALE
         WHEN "dust-transition"
             PERFORM READ-COLOR
             MOVE WS-DOUBLE TO PO-COLOR
             PERFORM READ-COLOR
             MOVE WS-DOUBLE TO PO-TO-COLOR
             PERFORM READ-SCALE
         WHEN "spell"
             PERFORM READ-COLOR
             MOVE WS-DOUBLE TO PO-COLOR
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             MOVE WS-FLOAT TO PO-POWER
         WHEN "power"
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             MOVE WS-FLOAT TO PO-POWER
         WHEN "shriek"
             CALL "PB-GET-VARINT" USING PB-BUFFER PO-DELAY
         WHEN "sculk-charge"
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             MOVE WS-FLOAT TO PO-ROLL
         WHEN "vibration"
             CALL "PB-GET-VARINT" USING PB-BUFFER PO-SRC-TYPE
             EVALUATE PO-SRC-TYPE
                 WHEN 0
                     CALL "PB-GET-POSITION" USING PB-BUFFER PO-SRC-X PO-SRC-Y PO-SRC-Z
                 WHEN 1
                     CALL "PB-GET-VARINT" USING PB-BUFFER PO-SRC-ENTITY
                     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
                     MOVE WS-FLOAT TO PO-SRC-YOFFSET
                 WHEN OTHER
                     MOVE 1 TO PO-ERROR
             END-EVALUATE
             IF PO-ERROR = 0
                 CALL "PB-GET-VARINT" USING PB-BUFFER PO-ARRIVAL
             END-IF
         WHEN "trail"
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PO-TARGET-X
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PO-TARGET-Y
             CALL "PB-GET-DOUBLE" USING PB-BUFFER PO-TARGET-Z
             PERFORM READ-COLOR
             MOVE WS-DOUBLE TO PO-COLOR
             CALL "PB-GET-VARINT" USING PB-BUFFER PO-DURATION
         WHEN "geyser"
             CALL "PB-GET-INT" USING PB-BUFFER PO-WATER-BLOCKS
         WHEN "geyser-base"
             CALL "PB-GET-INT" USING PB-BUFFER PO-WATER-BLOCKS
             CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
             MOVE WS-FLOAT TO PO-BURST
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     IF PB-ERROR = 1
         MOVE 1 TO PO-ERROR
     END-IF
     GO TO DONE.

 READ-COLOR.
     CALL "PB-GET-INT" USING PB-BUFFER WS-INT
     MOVE WS-INT TO WS-DOUBLE
     IF WS-DOUBLE < 0
         ADD 4294967296 TO WS-DOUBLE
     END-IF.

 READ-SCALE.
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PO-SCALE
     IF PO-SCALE < 0.01
         MOVE 0.01 TO PO-SCALE
     END-IF
     IF PO-SCALE > 4.0
         MOVE 4.0 TO PO-SCALE
     END-IF.

*> ItemStackTemplate is item, count, patch; PB-GET-ITEM-STACK reads count, item, patch, so the
*> template is re-ordered into a scratch buffer: count and item first, then the patch bytes.
 READ-ITEM.
     CALL "PB-GET-VARINT" USING PB-BUFFER PO-ITEM-ID
     CALL "PB-GET-VARINT" USING PB-BUFFER PO-ITEM-COUNT
     COMPUTE WS-REMAIN = PB-LENGTH - PB-POS
     IF PB-ERROR = 1 OR PO-ITEM-COUNT < 1 OR PO-ITEM-ID < 0 OR WS-REMAIN > 20000
         MOVE 1 TO PO-ERROR
     ELSE
         MOVE 20100 TO WS-INT
         CALL "PB-INIT" USING TM-BUFFER WS-INT
         CALL "PB-PUT-VARINT" USING TM-BUFFER PO-ITEM-COUNT
         CALL "PB-PUT-VARINT" USING TM-BUFFER PO-ITEM-ID
         MOVE TM-LENGTH TO WS-HEADER
         CALL "PB-GET-BYTES" USING PB-BUFFER WS-REST WS-REMAIN
         IF PB-ERROR = 0
             CALL "PB-APPEND-BYTES" USING TM-BUFFER WS-REST WS-REMAIN
             CALL "PB-GET-ITEM-STACK" USING TM-BUFFER TM-ITEMSTACK-X
             IF TM-ERROR = 1
                 MOVE 1 TO PO-ERROR
             ELSE
                 MOVE TM-ISX-ADDED-COUNT TO PO-ITEM-ADDED
                 MOVE TM-ISX-REMOVED-COUNT TO PO-ITEM-REMOVED
*>               Give back the bytes the patch did not use.
                 COMPUTE PB-POS = PB-POS - WS-REMAIN + (TM-POS - WS-HEADER)
             END-IF
         END-IF
         CALL "PB-FREE" USING TM-BUFFER
     END-IF.

 DONE.
     GOBACK.
 END PROGRAM PART-OPT-DECODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-COLOR-GET.
*> Section 3 (ColorParticleOption getters): USING ARGB word (BINARY-DOUBLE), alpha, red, green, blue
*> (FLOAT-LONG), each a byte divided by 255.0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-REST                BINARY-DOUBLE.
 01 WS-BYTE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-A                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-COLOR L-A L-R L-G L-B.
     MOVE L-COLOR TO WS-REST
     COMPUTE WS-BYTE = FUNCTION MOD(WS-REST / 16777216, 256)
     COMPUTE L-A = WS-BYTE / 255.0
     COMPUTE WS-BYTE = FUNCTION MOD(FUNCTION INTEGER-PART(WS-REST / 65536), 256)
     COMPUTE L-R = WS-BYTE / 255.0
     COMPUTE WS-BYTE = FUNCTION MOD(FUNCTION INTEGER-PART(WS-REST / 256), 256)
     COMPUTE L-G = WS-BYTE / 255.0
     COMPUTE WS-BYTE = FUNCTION MOD(WS-REST, 256)
     COMPUTE L-B = WS-BYTE / 255.0
     GOBACK.
 END PROGRAM PART-COLOR-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-RGB24.
*> Section 3 (vector3fFromRGB24): USING colour word, red, green, blue (FLOAT-LONG): the low 24 bits
*> split into bytes divided by 255.0; the high byte is ignored.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-LOW                 BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-COLOR                BINARY-DOUBLE.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-COLOR L-R L-G L-B.
     COMPUTE WS-LOW = FUNCTION MOD(L-COLOR, 16777216)
     CALL "PART-COLOR-GET" USING WS-LOW WS-A L-R L-G L-B
     GOBACK.
 END PROGRAM PART-RGB24.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-COLOR-LIST.
*> Section 3 (colour codec, list form): USING r, g, b, a (FLOAT-LONG, each 0 to 1), ARGB word out
*> = colorFromFloat(a, r, g, b).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 01 L-PACKED               BINARY-DOUBLE.
 PROCEDURE DIVISION USING L-R L-G L-B L-A L-PACKED.
     CALL "PART-COLOR-PACK" USING L-A L-R L-G L-B L-PACKED
     GOBACK.
 END PROGRAM PART-COLOR-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-OPT-DEFAULTS.
*> Section 3: USING registry id, PART-OPTIONS out: the options with the optional JSON fields at their
*> defaults (spell colour -1 = 4294967295 and power 1.0; power 1.0; dust scale 1.0).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-KIND                PIC X(16).
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 COPY CLPART.
 PROCEDURE DIVISION USING L-ID PART-OPTIONS.
     INITIALIZE PART-OPTIONS
     MOVE 1.0 TO PO-SCALE PO-POWER
     CALL "PART-TYPE" USING L-ID WS-NAME WS-KIND WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
     MOVE WS-KIND TO PO-KIND
     IF WS-KIND = "spell"
         MOVE 4294967295 TO PO-COLOR
     END-IF
     GOBACK.
 END PROGRAM PART-OPT-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-OPT-JSON-CHECK.
*> Section 3 (JSON/NBT form validation): USING PART-OPTIONS, message out (spaces when valid). Dust and
*> transition scale in 0.01 .. 4.0; trail duration at least 1; geyser water_blocks at least 1;
*> vibration entity sources rejected ("Entity position sources are not allowed").
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPART.
 01 L-MESSAGE              PIC X(64).
 PROCEDURE DIVISION USING PART-OPTIONS L-MESSAGE.
     MOVE SPACES TO L-MESSAGE
     EVALUATE PO-KIND
         WHEN "dust"
         WHEN "dust-transition"
             IF PO-SCALE < 0.01 OR PO-SCALE > 4.0
                 MOVE "scale out of range" TO L-MESSAGE
             END-IF
         WHEN "trail"
             IF PO-DURATION < 1
                 MOVE "duration must be positive" TO L-MESSAGE
             END-IF
         WHEN "geyser"
         WHEN "geyser-base"
             IF PO-WATER-BLOCKS < 1
                 MOVE "water_blocks must be positive" TO L-MESSAGE
             END-IF
         WHEN "vibration"
             IF PO-SRC-TYPE = 1
                 MOVE "Entity position sources are not allowed" TO L-MESSAGE
             END-IF
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM PART-OPT-JSON-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-OPT-CONSTANT.
*> Section 3: USING constant name (PIC X(24): REDSTONE or SCULK_TO_REDSTONE), PART-OPTIONS out.
*> REDSTONE: dust colour 16711680, scale 1.0. SCULK_TO_REDSTONE: dust transition from 3790560
*> (SCULK_PARTICLE_COLOR) to 16711680, scale 1.0. An unknown name leaves the kind blank.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(24).
 COPY CLPART.
 PROCEDURE DIVISION USING L-NAME PART-OPTIONS.
     INITIALIZE PART-OPTIONS
     MOVE 1.0 TO PO-SCALE PO-POWER
     EVALUATE L-NAME
         WHEN "REDSTONE"
             MOVE "dust" TO PO-KIND
             MOVE 16711680 TO PO-COLOR
         WHEN "SCULK_TO_REDSTONE"
             MOVE "dust-transition" TO PO-KIND
             MOVE 3790560 TO PO-COLOR
             MOVE 16711680 TO PO-TO-COLOR
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM PART-OPT-CONSTANT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-EXPLOSION-INFO.
*> Section 3 (ExplosionParticleInfo, Explosion packet): USING PB-BUFFER, particle type id out,
*> PART-OPTIONS out (the full particle: VarInt type id then its options), scaling, speed (FLOAT-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FLOAT               FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-TYPE                 BINARY-LONG.
 COPY CLPART.
 01 L-SCALING              FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING PB-BUFFER L-TYPE PART-OPTIONS L-SCALING L-SPEED.
     CALL "PB-GET-VARINT" USING PB-BUFFER L-TYPE
     CALL "PART-OPT-DECODE" USING PB-BUFFER L-TYPE PART-OPTIONS
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO L-SCALING
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO L-SPEED
     IF PB-ERROR = 1
         MOVE 1 TO PO-ERROR
     END-IF
     GOBACK.
 END PROGRAM PART-EXPLOSION-INFO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-EXPLOSION-DEFAULTS.
*> Section 3: USING scaling, speed (FLOAT-LONG) out: the optional JSON fields of ExplosionParticleInfo
*> default to 1.0.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-SCALING              FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SCALING L-SPEED.
     MOVE 1.0 TO L-SCALING L-SPEED
     GOBACK.
 END PROGRAM PART-EXPLOSION-DEFAULTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PART-LIMIT.
*> Section 3 (ParticleLimit) and 5.4: USING registry id, limit out: 1000 (SPORE_BLOSSOM) for
*> spore_blossom_air, 0 for every other type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NAME                PIC X(32).
 01 WS-OPTIONS             PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-LIMIT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-LIMIT.
     MOVE 0 TO L-LIMIT
     CALL "PART-TYPE" USING L-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
     IF WS-NAME = "spore_blossom_air"
         MOVE 1000 TO L-LIMIT
     END-IF
     GOBACK.
 END PROGRAM PART-LIMIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SET-POS.
*> Section 4.1 setPos: USING PCL, x, y, z: the box is centred on x and z with half width bbWidth / 2
*> and extends from y to y + bbHeight.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z.
     MOVE L-X TO PC-X
     MOVE L-Y TO PC-Y
     MOVE L-Z TO PC-Z
     COMPUTE PC-BB-MIN(1) = L-X - PC-BBW / 2
     COMPUTE PC-BB-MAX(1) = L-X + PC-BBW / 2
     COMPUTE PC-BB-MIN(2) = L-Y
     COMPUTE PC-BB-MAX(2) = L-Y + PC-BBH
     COMPUTE PC-BB-MIN(3) = L-Z - PC-BBW / 2
     COMPUTE PC-BB-MAX(3) = L-Z + PC-BBW / 2
     GOBACK.
 END PROGRAM PCL-SET-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SET-SIZE.
*> Section 4.1 setSize: USING PCL, width, height: when changed the box keeps its horizontal centre and
*> its minimum y, with the new width and height.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CX                  FLOAT-LONG.
 01 WS-CZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-W                    FLOAT-LONG.
 01 L-H                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-W L-H.
     IF L-W NOT = PC-BBW OR L-H NOT = PC-BBH
         MOVE L-W TO PC-BBW
         MOVE L-H TO PC-BBH
         COMPUTE WS-CX = (PC-BB-MIN(1) + PC-BB-MAX(1)) / 2
         COMPUTE WS-CZ = (PC-BB-MIN(3) + PC-BB-MAX(3)) / 2
         COMPUTE PC-BB-MIN(1) = WS-CX - L-W / 2
         COMPUTE PC-BB-MAX(1) = WS-CX + L-W / 2
         COMPUTE PC-BB-MAX(2) = PC-BB-MIN(2) + L-H
         COMPUTE PC-BB-MIN(3) = WS-CZ - L-W / 2
         COMPUTE PC-BB-MAX(3) = WS-CZ + L-W / 2
     END-IF
     GOBACK.
 END PROGRAM PCL-SET-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-LOC-FROM-BOX.
*> Section 4.1 setLocationFromBoundingbox: x, z = box centre, y = box minimum y.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL.
     COMPUTE PC-X = (PC-BB-MIN(1) + PC-BB-MAX(1)) / 2
     MOVE PC-BB-MIN(2) TO PC-Y
     COMPUTE PC-Z = (PC-BB-MIN(3) + PC-BB-MAX(3)) / 2
     GOBACK.
 END PROGRAM PCL-LOC-FROM-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-INIT.
*> Section 4.1 steps 1 and 2: USING PCL, x, y, z: hasPhysics, friction 0.98 (the f32 value), gravity 0,
*> age 0, box 0.2 by 0.2 at the position, old position = position. The lifetime is set by the caller.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F32                 FLOAT-SHORT.
 01 WS-W                   FLOAT-LONG VALUE 0.2.
 01 WS-H                   FLOAT-LONG VALUE 0.2.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z.
     INITIALIZE PCL
     MOVE 1 TO PC-HAS-PHYSICS
     MOVE 0.98 TO WS-F32
     MOVE WS-F32 TO PC-FRICTION
     MOVE 0.6 TO PC-BBW
     MOVE 1.8 TO PC-BBH
     CALL "PCL-SET-POS" USING PCL L-X L-Y L-Z
     CALL "PCL-SET-SIZE" USING PCL WS-W WS-H
     CALL "PCL-SET-POS" USING PCL L-X L-Y L-Z
     MOVE L-X TO PC-XO
     MOVE L-Y TO PC-YO
     MOVE L-Z TO PC-ZO
     GOBACK.
 END PROGRAM PCL-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-LIFETIME.
*> Section 4.1 step 3: USING r (one nextFloat), lifetime out = (int)(4.0f / (r * 0.9f + 0.1f)).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DEN                 FLOAT-SHORT.
 01 WS-Q                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-R                    FLOAT-LONG.
 01 L-LIFETIME             BINARY-LONG.
 PROCEDURE DIVISION USING L-R L-LIFETIME.
     COMPUTE WS-DEN = L-R * 0.9 + 0.1
     COMPUTE WS-Q = 4.0 / WS-DEN
     COMPUTE L-LIFETIME = FUNCTION INTEGER-PART(WS-Q)
     GOBACK.
 END PROGRAM PCL-LIFETIME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-NEW.
*> Section 4.1 Particle(level, x, y, z): USING PCL, x, y, z, the lifetime draw r. Velocity is zero.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-R.
     CALL "PCL-INIT" USING PCL L-X L-Y L-Z
     CALL "PCL-LIFETIME" USING L-R PC-LIFETIME
     GOBACK.
 END PROGRAM PCL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-NEW-VEL.
*> Section 4.1 Particle(level, x, y, z, vx, vy, vz): USING PCL, x, y, z, vx, vy, vz, six draws in order
*> (lifetime r, then a, b, c for x, y, z, then d, e). xd = vx + (a * 2 - 1) * 0.4 and likewise; s =
*> (d + e + 1) * 0.15; each component divided by the length, times s * 0.4000000059604645, y plus
*> 0.10000000149011612. A zero-length vector gives zero velocity plus the y constant (the document
*> read no guard, Open question 10).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     COMPUTE PC-XD = L-VX + (L-DRAW(2) * 2 - 1) * 0.4
     COMPUTE PC-YD = L-VY + (L-DRAW(3) * 2 - 1) * 0.4
     COMPUTE PC-ZD = L-VZ + (L-DRAW(4) * 2 - 1) * 0.4
     COMPUTE WS-S = (L-DRAW(5) + L-DRAW(6) + 1) * 0.15
     COMPUTE WS-LEN = FUNCTION SQRT(PC-XD * PC-XD + PC-YD * PC-YD + PC-ZD * PC-ZD)
     IF WS-LEN = 0
         MOVE 0 TO PC-XD PC-YD PC-ZD
     ELSE
         COMPUTE PC-XD = PC-XD / WS-LEN * WS-S * 0.4000000059604645
         COMPUTE PC-YD = PC-YD / WS-LEN * WS-S * 0.4000000059604645
         COMPUTE PC-ZD = PC-ZD / WS-LEN * WS-S * 0.4000000059604645
     END-IF
     ADD 0.10000000149011612 TO PC-YD
     GOBACK.
 END PROGRAM PCL-NEW-VEL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SET-POWER.
*> Section 4.1 setPower(p): xd *= p, yd = (yd - 0.1) * p + 0.1 (0.10000000149011612), zd *= p.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-POWER                FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-POWER.
     COMPUTE PC-XD = PC-XD * L-POWER
     COMPUTE PC-YD = (PC-YD - 0.10000000149011612) * L-POWER + 0.10000000149011612
     COMPUTE PC-ZD = PC-ZD * L-POWER
     GOBACK.
 END PROGRAM PCL-SET-POWER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SCALE.
*> Section 4.1 scale(f): setSize(0.2 * f, 0.2 * f).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SIZE                FLOAT-LONG.
 01 WS-SIZE-H              FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-F                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-F.
     COMPUTE WS-SIZE = 0.2 * L-F
     MOVE WS-SIZE TO WS-SIZE-H
     CALL "PCL-SET-SIZE" USING PCL WS-SIZE WS-SIZE-H
     GOBACK.
 END PROGRAM PCL-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-COLLIDE.
*> Section 4.4 the resolver: USING PCL, dx, dy, dz in and out (the resolved delta), PCL-COLLIDERS (the
*> block collision boxes met by the query box). An empty list returns the delta unchanged. Else one
*> axis at a time, Y first, then X then Z when |dx| >= |dz|, else Z then X; an axis with delta 0 is
*> skipped; the particle box moved by the accumulated offset is clipped against every collider in turn
*> (a running |delta| below 1e-7 gives 0 at once; the tolerance on the other two axes is 1e-7).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DELTA               FLOAT-LONG OCCURS 3 TIMES.
 01 WS-OFFSET              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-ORDER               BINARY-LONG OCCURS 3 TIMES.
 01 WS-K                   BINARY-LONG.
 01 WS-AXIS                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-O1                  BINARY-LONG.
 01 WS-O2                  BINARY-LONG.
 01 WS-RUN                 FLOAT-LONG.
 01 WS-LO                  FLOAT-LONG.
 01 WS-HI                  FLOAT-LONG.
 01 WS-EPS                 FLOAT-LONG VALUE 0.0000001.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-DX L-DY L-DZ PCL-COLLIDERS.
     IF PK-COUNT <= 0
         GOBACK
     END-IF
     MOVE L-DX TO WS-DELTA(1)
     MOVE L-DY TO WS-DELTA(2)
     MOVE L-DZ TO WS-DELTA(3)
     MOVE 0 TO WS-OFFSET(1) WS-OFFSET(2) WS-OFFSET(3)
     MOVE 2 TO WS-ORDER(1)
     IF FUNCTION ABS(L-DX) < FUNCTION ABS(L-DZ)
         MOVE 3 TO WS-ORDER(2)
         MOVE 1 TO WS-ORDER(3)
     ELSE
         MOVE 1 TO WS-ORDER(2)
         MOVE 3 TO WS-ORDER(3)
     END-IF
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
         MOVE WS-ORDER(WS-K) TO WS-AXIS
         IF WS-DELTA(WS-AXIS) NOT = 0
             PERFORM CLIP-AXIS
             MOVE WS-RUN TO WS-OFFSET(WS-AXIS)
         END-IF
     END-PERFORM
     MOVE WS-OFFSET(1) TO L-DX
     MOVE WS-OFFSET(2) TO L-DY
     MOVE WS-OFFSET(3) TO L-DZ
     GO TO DONE.

 CLIP-AXIS.
     MOVE WS-DELTA(WS-AXIS) TO WS-RUN
     COMPUTE WS-O1 = FUNCTION MOD(WS-AXIS, 3) + 1
     COMPUTE WS-O2 = FUNCTION MOD(WS-AXIS + 1, 3) + 1
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PK-COUNT
         IF FUNCTION ABS(WS-RUN) < WS-EPS
             MOVE 0 TO WS-RUN
         ELSE
             IF PC-BB-MAX(WS-O1) + WS-OFFSET(WS-O1) > PK-MIN(WS-I, WS-O1) + WS-EPS
                     AND PC-BB-MIN(WS-O1) + WS-OFFSET(WS-O1) < PK-MAX(WS-I, WS-O1) - WS-EPS
                     AND PC-BB-MAX(WS-O2) + WS-OFFSET(WS-O2) > PK-MIN(WS-I, WS-O2) + WS-EPS
                     AND PC-BB-MIN(WS-O2) + WS-OFFSET(WS-O2) < PK-MAX(WS-I, WS-O2) - WS-EPS
                 COMPUTE WS-LO = PC-BB-MIN(WS-AXIS) + WS-OFFSET(WS-AXIS)
                 COMPUTE WS-HI = PC-BB-MAX(WS-AXIS) + WS-OFFSET(WS-AXIS)
                 IF WS-RUN > 0 AND PK-MIN(WS-I, WS-AXIS) >= WS-HI - WS-EPS
                     IF PK-MIN(WS-I, WS-AXIS) - WS-HI < WS-RUN
                         COMPUTE WS-RUN = PK-MIN(WS-I, WS-AXIS) - WS-HI
                     END-IF
                 END-IF
                 IF WS-RUN < 0 AND PK-MAX(WS-I, WS-AXIS) <= WS-LO + WS-EPS
                     IF PK-MAX(WS-I, WS-AXIS) - WS-LO > WS-RUN
                         COMPUTE WS-RUN = PK-MAX(WS-I, WS-AXIS) - WS-LO
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF FUNCTION ABS(WS-RUN) < WS-EPS
         MOVE 0 TO WS-RUN
     END-IF.

 DONE.
     GOBACK.
 END PROGRAM PCL-COLLIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-MOVE.
*> Section 4.4 Particle.move: USING PCL, dx, dy, dz (the particle's own velocity), PCL-COLLIDERS.
*> 1 nothing when stoppedByCollision. 3 with hasPhysics, a non-zero delta and a squared length below
*> 10000 the delta is resolved (PCL-COLLIDE). 4 a non-zero result moves the box and recomputes x, y, z.
*> 5 an intended |dy| >= 1e-5 resolved to < 1e-5 sets stoppedByCollision. 6 onGround = intended dy
*> differs from the resolved dy and the intended dy < 0. 7 xd and zd become 0 where blocked.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-IX                  FLOAT-LONG.
 01 WS-IY                  FLOAT-LONG.
 01 WS-IZ                  FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 01 WS-LIMIT               FLOAT-LONG VALUE 0.00001.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-DX                   FLOAT-LONG.
 01 L-DY                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-DX L-DY L-DZ PCL-COLLIDERS.
     IF PC-STOPPED NOT = 0
         GOBACK
     END-IF
     MOVE L-DX TO WS-IX WS-RX
     MOVE L-DY TO WS-IY WS-RY
     MOVE L-DZ TO WS-IZ WS-RZ
     IF PC-HAS-PHYSICS NOT = 0 AND (WS-RX NOT = 0 OR WS-RY NOT = 0 OR WS-RZ NOT = 0)
             AND WS-RX * WS-RX + WS-RY * WS-RY + WS-RZ * WS-RZ < 10000
         CALL "PCL-COLLIDE" USING PCL WS-RX WS-RY WS-RZ PCL-COLLIDERS
     END-IF
     IF WS-RX NOT = 0 OR WS-RY NOT = 0 OR WS-RZ NOT = 0
         ADD WS-RX TO PC-BB-MIN(1) PC-BB-MAX(1)
         ADD WS-RY TO PC-BB-MIN(2) PC-BB-MAX(2)
         ADD WS-RZ TO PC-BB-MIN(3) PC-BB-MAX(3)
         CALL "PCL-LOC-FROM-BOX" USING PCL
     END-IF
     IF FUNCTION ABS(WS-IY) >= WS-LIMIT AND FUNCTION ABS(WS-RY) < WS-LIMIT
         MOVE 1 TO PC-STOPPED
     END-IF
     IF WS-IY NOT = WS-RY AND WS-IY < 0
         MOVE 1 TO PC-ON-GROUND
     ELSE
         MOVE 0 TO PC-ON-GROUND
     END-IF
     IF WS-IX NOT = WS-RX
         MOVE 0 TO PC-XD
     END-IF
     IF WS-IZ NOT = WS-RZ
         MOVE 0 TO PC-ZD
     END-IF
     GOBACK.
 END PROGRAM PCL-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-TICK.
*> Section 4.2 Particle.tick: USING PCL, PCL-COLLIDERS. 1 old position = position. 2 the old age is
*> compared with the lifetime, then incremented; an old age >= lifetime removes the particle and ends
*> the tick. 3 yd -= 0.04 * gravity. 4 move(xd, yd, zd). 5 with speedUp and y == yo, xd and zd *= 1.1.
*> 6 the three velocity components *= friction. 7 on the ground xd and zd *= 0.699999988079071.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 PROCEDURE DIVISION USING PCL PCL-COLLIDERS.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     IF PC-AGE >= PC-LIFETIME
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     ADD 1 TO PC-AGE
     COMPUTE PC-YD = PC-YD - 0.04 * PC-GRAVITY
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     IF PC-SPEED-UP NOT = 0 AND PC-Y = PC-YO
         COMPUTE PC-XD = PC-XD * 1.1
         COMPUTE PC-ZD = PC-ZD * 1.1
     END-IF
     COMPUTE PC-XD = PC-XD * PC-FRICTION
     COMPUTE PC-YD = PC-YD * PC-FRICTION
     COMPUTE PC-ZD = PC-ZD * PC-FRICTION
     IF PC-ON-GROUND NOT = 0
         COMPUTE PC-XD = PC-XD * 0.699999988079071
         COMPUTE PC-ZD = PC-ZD * 0.699999988079071
     END-IF
     GOBACK.
 END PROGRAM PCL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-QUAD-NEW.
*> Section 4.3 construction (after PCL-INIT and the lifetime): USING PCL, the quadSize draw r: colours
*> and alpha 1.0, roll 0, quadSize = 0.1 * (r * 0.5 + 0.5) * 2.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-R.
     MOVE 1.0 TO PC-RCOL PC-GCOL PC-BCOL PC-ALPHA
     MOVE 0 TO PC-ROLL PC-OROLL
     COMPUTE PC-QUAD-SIZE = 0.1 * (L-R * 0.5 + 0.5) * 2
     GOBACK.
 END PROGRAM PCL-QUAD-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-QUAD-SCALE.
*> Section 4.3 scale(f): quadSize *= f, then Particle.scale (box 0.2 * f).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-F                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-F.
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * L-F
     CALL "PCL-SCALE" USING PCL L-F
     GOBACK.
 END PROGRAM PCL-QUAD-SCALE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SET-COLOR.
*> Section 4.3 setColor: USING PCL, r, g, b.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-R                    FLOAT-LONG.
 01 L-G                    FLOAT-LONG.
 01 L-B                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-R L-G L-B.
     MOVE L-R TO PC-RCOL
     MOVE L-G TO PC-GCOL
     MOVE L-B TO PC-BCOL
     GOBACK.
 END PROGRAM PCL-SET-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SET-ALPHA.
*> Section 4.3 setAlpha: USING PCL, alpha.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-A.
     MOVE L-A TO PC-ALPHA
     GOBACK.
 END PROGRAM PCL-SET-ALPHA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SPRITE-INDEX.
*> Section 6.3 / E3 SpriteSet.get(age, lifetime): USING age, lifetime, sprite count n, index out =
*> age * (n - 1) / lifetime with integer multiplication and division.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-N                    BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-AGE L-LIFETIME L-N L-INDEX.
     MOVE 0 TO L-INDEX
     IF L-LIFETIME > 0
         COMPUTE L-INDEX = FUNCTION INTEGER-PART(L-AGE * (L-N - 1) / L-LIFETIME)
     END-IF
     GOBACK.
 END PROGRAM PCL-SPRITE-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-SPRITE-FROM-AGE.
*> Section 4.3 setSpriteFromAge: USING PCL, sprite count n: nothing when removed, else the sprite is
*> the age index of the set.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL L-N.
     IF PC-REMOVED = 0
         CALL "PCL-SPRITE-INDEX" USING PC-AGE PC-LIFETIME L-N PC-SPRITE
     END-IF
     GOBACK.
 END PROGRAM PCL-SPRITE-FROM-AGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-FACING.
*> Section 4.3 facing and roll: USING mode (0 LOOKAT_XYZ, 1 LOOKAT_Y), camera quaternion (x, y, z, w),
*> roll, old roll, partial, result quaternion. LOOKAT_Y zeroes x and z (no renormalisation); a roll
*> other than 0 rotates the quaternion about its local Z axis by lerp(partial, oRoll, roll).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-C                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-W                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-MODE                 BINARY-LONG.
 01 L-CAMERA.
    05 L-CQ                FLOAT-LONG OCCURS 4 TIMES.
 01 L-ROLL                 FLOAT-LONG.
 01 L-OROLL                FLOAT-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-OUT.
    05 L-OQ                FLOAT-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-MODE L-CAMERA L-ROLL L-OROLL L-PARTIAL L-OUT.
     MOVE L-CQ(1) TO WS-X
     MOVE L-CQ(2) TO WS-Y
     MOVE L-CQ(3) TO WS-Z
     MOVE L-CQ(4) TO WS-W
     IF L-MODE = 1
         MOVE 0 TO WS-X WS-Z
     END-IF
     IF L-ROLL NOT = 0
         COMPUTE WS-ANGLE = L-OROLL + L-PARTIAL * (L-ROLL - L-OROLL)
         COMPUTE WS-S = FUNCTION SIN(WS-ANGLE / 2)
         COMPUTE WS-C = FUNCTION COS(WS-ANGLE / 2)
         MOVE WS-X TO L-OQ(1)
         COMPUTE L-OQ(1) = WS-X * WS-C + WS-Y * WS-S
         COMPUTE L-OQ(2) = WS-Y * WS-C - WS-X * WS-S
         COMPUTE L-OQ(3) = WS-Z * WS-C + WS-W * WS-S
         COMPUTE L-OQ(4) = WS-W * WS-C - WS-Z * WS-S
     ELSE
         MOVE WS-X TO L-OQ(1)
         MOVE WS-Y TO L-OQ(2)
         MOVE WS-Z TO L-OQ(3)
         MOVE WS-W TO L-OQ(4)
     END-IF
     GOBACK.
 END PROGRAM PCL-FACING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-QUAD-VERTS.
*> Section 4.3 quad geometry: USING facing quaternion, relative position x y z, size, four vertices out
*> (x, y, z each). The local offsets (+1,-1), (+1,+1), (-1,+1), (-1,-1) are rotated by the quaternion,
*> multiplied by the size and added to the relative position; the side of the square is twice the size.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-LX                  FLOAT-LONG.
 01 WS-LY                  FLOAT-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-RX                  FLOAT-LONG.
 01 WS-RY                  FLOAT-LONG.
 01 WS-RZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Q.
    05 L-QV                FLOAT-LONG OCCURS 4 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 01 L-VERTS.
    05 L-VERT              OCCURS 4 TIMES.
       10 L-VC             FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION USING L-Q L-X L-Y L-Z L-SIZE L-VERTS.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         EVALUATE WS-K
             WHEN 1
                 MOVE 1 TO WS-LX
                 MOVE -1 TO WS-LY
             WHEN 2
                 MOVE 1 TO WS-LX
                 MOVE 1 TO WS-LY
             WHEN 3
                 MOVE -1 TO WS-LX
                 MOVE 1 TO WS-LY
             WHEN OTHER
                 MOVE -1 TO WS-LX
                 MOVE -1 TO WS-LY
         END-EVALUATE
*>       v' = v + w t + q.xyz x t with t = 2 (q.xyz x v) and v = (lx, ly, 0).
         COMPUTE WS-TX = 2 * (L-QV(2) * 0 - L-QV(3) * WS-LY)
         COMPUTE WS-TY = 2 * (L-QV(3) * WS-LX - L-QV(1) * 0)
         COMPUTE WS-TZ = 2 * (L-QV(1) * WS-LY - L-QV(2) * WS-LX)
         COMPUTE WS-RX = WS-LX + L-QV(4) * WS-TX + (L-QV(2) * WS-TZ - L-QV(3) * WS-TY)
         COMPUTE WS-RY = WS-LY + L-QV(4) * WS-TY + (L-QV(3) * WS-TX - L-QV(1) * WS-TZ)
         COMPUTE WS-RZ = L-QV(4) * WS-TZ + (L-QV(1) * WS-TY - L-QV(2) * WS-TX)
         COMPUTE L-VC(WS-K, 1) = WS-RX * L-SIZE + L-X
         COMPUTE L-VC(WS-K, 2) = WS-RY * L-SIZE + L-Y
         COMPUTE L-VC(WS-K, 3) = WS-RZ * L-SIZE + L-Z
     END-PERFORM
     GOBACK.
 END PROGRAM PCL-QUAD-VERTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-QUAD-UV.
*> Section 4.3: USING u0, u1, v0, v1, four UV pairs out in the vertex order (u1,v1), (u1,v0), (u0,v0),
*> (u0,v1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-U0                   FLOAT-LONG.
 01 L-U1                   FLOAT-LONG.
 01 L-V0                   FLOAT-LONG.
 01 L-V1                   FLOAT-LONG.
 01 L-UVS.
    05 L-UV                OCCURS 4 TIMES.
       10 L-UC             FLOAT-LONG OCCURS 2 TIMES.
 PROCEDURE DIVISION USING L-U0 L-U1 L-V0 L-V1 L-UVS.
     MOVE L-U1 TO L-UC(1, 1)
     MOVE L-V1 TO L-UC(1, 2)
     MOVE L-U1 TO L-UC(2, 1)
     MOVE L-V0 TO L-UC(2, 2)
     MOVE L-U0 TO L-UC(3, 1)
     MOVE L-V0 TO L-UC(3, 2)
     MOVE L-U0 TO L-UC(4, 1)
     MOVE L-V1 TO L-UC(4, 2)
     GOBACK.
 END PROGRAM PCL-QUAD-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-LAYER-BY-SPRITE.
*> Section 4.3 Layer.bySprite: USING atlas (0 particles, 1 blocks, 2 items), has-translucent (0/1),
*> layer out: 0 OPAQUE, 1 TRANSLUCENT, 2 OPAQUE_TERRAIN, 3 TRANSLUCENT_TERRAIN, 4 OPAQUE_ITEMS,
*> 5 TRANSLUCENT_ITEMS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATLAS                BINARY-LONG.
 01 L-TRANSLUCENT          BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-ATLAS L-TRANSLUCENT L-LAYER.
     COMPUTE L-LAYER = L-ATLAS * 2 + L-TRANSLUCENT
     GOBACK.
 END PROGRAM PCL-LAYER-BY-SPRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-TRANSPARENCY.
*> Section 4.3 NativeImage.computeTransparency: USING rgba flag (0/1), pixel count, alpha bytes (one
*> byte per pixel, any area), hasTransparent out (any alpha 0), hasTranslucent out (any alpha
*> neither 0 nor 255). A non-RGBA image has neither.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-ALPHA               BINARY-LONG.
 01 B-ALPHAS               PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-RGBA                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 01 L-ALPHAS               PIC X.
 01 L-TRANSPARENT          BINARY-LONG.
 01 L-TRANSLUCENT          BINARY-LONG.
 PROCEDURE DIVISION USING L-RGBA L-COUNT L-ALPHAS L-TRANSPARENT L-TRANSLUCENT.
     MOVE 0 TO L-TRANSPARENT L-TRANSLUCENT
     IF L-RGBA NOT = 0
         SET ADDRESS OF B-ALPHAS TO ADDRESS OF L-ALPHAS
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             COMPUTE WS-ALPHA = FUNCTION ORD(B-ALPHAS(WS-I:1)) - 1
             IF WS-ALPHA = 0
                 MOVE 1 TO L-TRANSPARENT
             ELSE
                 IF WS-ALPHA NOT = 255
                     MOVE 1 TO L-TRANSLUCENT
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PCL-TRANSPARENCY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PCL-LIGHT.
*> Section 4.3 default light: USING chunk-loaded (0/1), emissive-rendering (0/1), sky level, block
*> level (0 to 15), block light emission (0 to 15), packed light out. Not loaded 15728640; emissive
*> 15728880; else the packed brightness with the block bits raised to the emission when that is higher.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LOADED               BINARY-LONG.
 01 L-EMISSIVE             BINARY-LONG.
 01 L-SKY                  BINARY-LONG.
 01 L-BLOCK                BINARY-LONG.
 01 L-EMISSION             BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LOADED L-EMISSIVE L-SKY L-BLOCK L-EMISSION L-LIGHT.
     EVALUATE TRUE
         WHEN L-LOADED = 0
             MOVE 15728640 TO L-LIGHT
         WHEN L-EMISSIVE NOT = 0
             MOVE 15728880 TO L-LIGHT
         WHEN OTHER
             IF L-EMISSION > L-BLOCK
                 CALL "PART-LIGHT-PACK" USING L-EMISSION L-SKY L-LIGHT
             ELSE
                 CALL "PART-LIGHT-PACK" USING L-BLOCK L-SKY L-LIGHT
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PCL-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-GROUP-NAME.
*> Section 5.1 and 5.2: USING group (1 SINGLE_QUADS, 2 ITEM_PICKUP, 3 ELDER_GUARDIANS, 4 NO_RENDER),
*> shorthand (PIC X(2)), group class name (PIC X(32)); spaces for an unknown group.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-GROUP                BINARY-LONG.
 01 L-SHORT                PIC X(2).
 01 L-CLASS                PIC X(32).
 PROCEDURE DIVISION USING L-GROUP L-SHORT L-CLASS.
     MOVE SPACES TO L-SHORT L-CLASS
     EVALUATE L-GROUP
         WHEN 1
             MOVE "SQ" TO L-SHORT
             MOVE "QuadParticleGroup" TO L-CLASS
         WHEN 2
             MOVE "IP" TO L-SHORT
             MOVE "ItemPickupParticleGroup" TO L-CLASS
         WHEN 3
             MOVE "EG" TO L-SHORT
             MOVE "ElderGuardianParticleGroup" TO L-CLASS
         WHEN 4
             MOVE "NR" TO L-SHORT
             MOVE "NoRenderParticleGroup" TO L-CLASS
         WHEN OTHER
             CONTINUE
     END-EVALUATE
     GOBACK.
 END PROGRAM PENG-GROUP-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-INIT.
*> Section 5.2 setLevel / clearParticles: USING ENGINE: groups, add queue, emitters and counters empty.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLENG.
 PROCEDURE DIVISION USING ENGINE.
     INITIALIZE ENGINE
     GOBACK.
 END PROGRAM PENG-INIT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-ADD.
*> Section 5.3 add(particle): USING ENGINE, handle, group, limited (1 = has a ParticleLimit), accepted
*> out. A limited particle is queued only while the counter is below its limit (1000), at call time,
*> and the counter is incremented; otherwise it is dropped. An unlimited particle is queued. A full
*> queue (4096 entries, a bound of this implementation) drops the particle.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SPORE-NAME          PIC X(32) VALUE "spore_blossom_air".
 01 WS-SPORE-ID            BINARY-LONG.
 01 WS-LIMIT               BINARY-LONG.
 LINKAGE SECTION.
 COPY CLENG.
 01 L-HANDLE               BINARY-LONG.
 01 L-GROUP                BINARY-LONG.
 01 L-LIMITED              BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING ENGINE L-HANDLE L-GROUP L-LIMITED L-OK.
     MOVE 0 TO L-OK
     CALL "PART-TYPE-ID" USING WS-SPORE-NAME WS-SPORE-ID
     CALL "PART-LIMIT" USING WS-SPORE-ID WS-LIMIT
     IF EN-ADD-COUNT >= EN-QUEUE-MAX
         GOBACK
     END-IF
     IF L-LIMITED NOT = 0
         IF EN-LIMIT-COUNT >= WS-LIMIT
             GOBACK
         END-IF
         ADD 1 TO EN-LIMIT-COUNT
     END-IF
     ADD 1 TO EN-ADD-COUNT
     MOVE L-HANDLE TO EN-A-HANDLE(EN-ADD-COUNT)
     MOVE L-GROUP TO EN-A-GROUP(EN-ADD-COUNT)
     MOVE L-LIMITED TO EN-A-LIMITED(EN-ADD-COUNT)
     MOVE 1 TO L-OK
     GOBACK.
 END PROGRAM PENG-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-GROUP-ACCEPT.
*> Section 5.4 ParticleGroup.add: USING group size, one nextFloat draw, accepted out, drew out (1 when
*> the draw was consumed). Size 16384 or more rejects (no draw); below 12288 accepts (no draw); in
*> between q = (16384 - size) / 4096 (f32) and the particle is accepted when the draw is below q squared.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-SIZE                 BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-OK                   BINARY-LONG.
 01 L-DREW                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SIZE L-DRAW L-OK L-DREW.
     MOVE 0 TO L-OK L-DREW
     EVALUATE TRUE
         WHEN L-SIZE >= 16384
             CONTINUE
         WHEN L-SIZE < 12288
             MOVE 1 TO L-OK
         WHEN OTHER
             MOVE 1 TO L-DREW
             COMPUTE WS-Q = (16384 - L-SIZE) / 4096
             IF L-DRAW < WS-Q * WS-Q
                 MOVE 1 TO L-OK
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM PENG-GROUP-ACCEPT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-REAP.
*> Section 5.5 steps 1 to 3 after the caller ticked every particle and emitter (marking EN-G-DEAD and
*> EN-EM-DEAD with 1): step 1 dead particles leave their group (insertion order kept) and a limited
*> one decrements the counter; step 2 dead emitters leave the queue; step 3 the add queue drains in
*> FIFO order, creating the group lazily and applying PENG-GROUP-ACCEPT with the next of the 48 draws
*> (a draw past the table is 1.0); a refused limited particle decrements the counter. The tick of 5.5
*> therefore inserts particles created during the tick after the groups were ticked.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-DREW                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLENG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 48 TIMES.
 PROCEDURE DIVISION USING ENGINE L-DRAWS.
     MOVE 0 TO EN-DRAW-INDEX
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 4
         MOVE 0 TO WS-J
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-G-COUNT(WS-G)
             IF EN-G-DEAD(WS-G, WS-I) NOT = 0
                 IF EN-G-LIMITED(WS-G, WS-I) NOT = 0
                     SUBTRACT 1 FROM EN-LIMIT-COUNT
                 END-IF
             ELSE
                 ADD 1 TO WS-J
                 IF WS-J NOT = WS-I
                     MOVE EN-G-SLOT(WS-G, WS-I) TO EN-G-SLOT(WS-G, WS-J)
                 END-IF
             END-IF
         END-PERFORM
         MOVE WS-J TO EN-G-COUNT(WS-G)
     END-PERFORM
     MOVE 0 TO WS-J
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-EM-COUNT
         IF EN-EM-DEAD(WS-I) = 0
             ADD 1 TO WS-J
             IF WS-J NOT = WS-I
                 MOVE EN-EM(WS-I) TO EN-EM(WS-J)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-J TO EN-EM-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-ADD-COUNT
         MOVE EN-A-GROUP(WS-I) TO WS-G
         MOVE 1 TO EN-G-EXISTS(WS-G)
         IF EN-DRAW-INDEX < 48
             MOVE L-DRAW(EN-DRAW-INDEX + 1) TO WS-DRAW
         ELSE
             MOVE 1.0 TO WS-DRAW
         END-IF
         CALL "PENG-GROUP-ACCEPT" USING EN-G-COUNT(WS-G) WS-DRAW WS-OK WS-DREW
         ADD WS-DREW TO EN-DRAW-INDEX
         IF WS-OK NOT = 0
             ADD 1 TO EN-G-COUNT(WS-G)
             MOVE EN-A-HANDLE(WS-I) TO EN-G-HANDLE(WS-G, EN-G-COUNT(WS-G))
             MOVE EN-A-LIMITED(WS-I) TO EN-G-LIMITED(WS-G, EN-G-COUNT(WS-G))
             MOVE 0 TO EN-G-DEAD(WS-G, EN-G-COUNT(WS-G))
         ELSE
             IF EN-A-LIMITED(WS-I) NOT = 0
                 SUBTRACT 1 FROM EN-LIMIT-COUNT
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO EN-ADD-COUNT
     GOBACK.
 END PROGRAM PENG-REAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-COUNTER.
*> Section 5.1 the F3 particle counter string: USING ENGINE, text out: for each group that exists
*> "<shorthand> <count> " then "T<total>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG VALUE 0.
 01 WS-SHORT               PIC X(2).
 01 WS-CLASS               PIC X(32).
 01 WS-NUM                 PIC Z(8)9.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLENG.
 01 L-TEXT                 PIC X(64).
 PROCEDURE DIVISION USING ENGINE L-TEXT.
     MOVE SPACES TO L-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-TOTAL
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 4
         IF EN-G-EXISTS(WS-G) NOT = 0
             CALL "PENG-GROUP-NAME" USING WS-G WS-SHORT WS-CLASS
             MOVE EN-G-COUNT(WS-G) TO WS-NUM
             ADD EN-G-COUNT(WS-G) TO WS-TOTAL
             STRING WS-SHORT " " FUNCTION TRIM(WS-NUM) " " DELIMITED BY SIZE
                 INTO L-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE WS-TOTAL TO WS-NUM
     STRING "T" FUNCTION TRIM(WS-NUM) DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
     GOBACK.
 END PROGRAM PENG-COUNTER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-RENDER-ORDER.
*> Section 5.6 RENDER_ORDER: USING ENGINE, groups out (4 BINARY-LONG), count out: SINGLE_QUADS,
*> ITEM_PICKUP, ELDER_GUARDIANS, each only when the group exists and is not empty; NO_RENDER never.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-G                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLENG.
 01 L-ORDER.
    05 L-GROUP             BINARY-LONG OCCURS 4 TIMES.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING ENGINE L-ORDER L-N.
     MOVE 0 TO L-N
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 3
         IF EN-G-EXISTS(WS-G) NOT = 0 AND EN-G-COUNT(WS-G) > 0
             ADD 1 TO L-N
             MOVE WS-G TO L-GROUP(L-N)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PENG-RENDER-ORDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-POINT-IN-FRUSTUM.
*> Section 5.6 Frustum.pointInFrustum: USING six planes (a, b, c, d), the point minus the camera
*> position (x, y, z), inside out (1 when a * x + b * y + c * z + d >= 0 for every plane).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-PLANES.
    05 L-PLANE             OCCURS 6 TIMES.
       10 L-PC             FLOAT-LONG OCCURS 4 TIMES.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-INSIDE               BINARY-LONG.
 PROCEDURE DIVISION USING L-PLANES L-X L-Y L-Z L-INSIDE.
     MOVE 1 TO L-INSIDE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         IF L-PC(WS-I, 1) * L-X + L-PC(WS-I, 2) * L-Y + L-PC(WS-I, 3) * L-Z + L-PC(WS-I, 4) < 0
             MOVE 0 TO L-INSIDE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PENG-POINT-IN-FRUSTUM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-EMITTER-TICK.
*> Section 5.7 TrackingEmitter.tick: USING entity (x, y, z, width, height), emitter (x, y, z, life,
*> lifetime, removed), 48 raw nextFloat draws (three per attempt), spawns out (count, then per spawn
*> px, py, pz, vx, vy, vz). Sixteen attempts: e = draw * 2 - 1 per axis in x, y, z order; a length
*> squared above 1 skips the attempt; else the spawn is at x + width * ex / 4, y + height * (0.5 +
*> ey / 4), z + width * ez / 4 with velocity (ex, ey + 0.2, ez). Then life + 1, removed when life >=
*> lifetime.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ENT.
    05 L-EX                FLOAT-LONG.
    05 L-EY                FLOAT-LONG.
    05 L-EZ                FLOAT-LONG.
    05 L-EW                FLOAT-LONG.
    05 L-EH                FLOAT-LONG.
 01 L-EM.
    05 L-EM-X              FLOAT-LONG.
    05 L-EM-Y              FLOAT-LONG.
    05 L-EM-Z              FLOAT-LONG.
    05 L-EM-LIFE           BINARY-LONG.
    05 L-EM-LIFETIME       BINARY-LONG.
    05 L-EM-REMOVED        BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 48 TIMES.
 01 L-SPAWNS.
    05 L-SP-COUNT          BINARY-LONG.
    05 L-SPAWN             OCCURS 16 TIMES.
       10 L-SP             FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-ENT L-EM L-DRAWS L-SPAWNS.
     MOVE 0 TO L-SP-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-EX = L-DRAW(WS-I * 3 - 2) * 2 - 1
         COMPUTE WS-EY = L-DRAW(WS-I * 3 - 1) * 2 - 1
         COMPUTE WS-EZ = L-DRAW(WS-I * 3) * 2 - 1
         IF WS-EX * WS-EX + WS-EY * WS-EY + WS-EZ * WS-EZ <= 1
             ADD 1 TO L-SP-COUNT
             COMPUTE L-SP(L-SP-COUNT, 1) = L-EX + L-EW * WS-EX / 4
             COMPUTE L-SP(L-SP-COUNT, 2) = L-EY + L-EH * (0.5 + WS-EY / 4)
             COMPUTE L-SP(L-SP-COUNT, 3) = L-EZ + L-EW * WS-EZ / 4
             MOVE WS-EX TO L-SP(L-SP-COUNT, 4)
             COMPUTE L-SP(L-SP-COUNT, 5) = WS-EY + 0.2
             MOVE WS-EZ TO L-SP(L-SP-COUNT, 6)
         END-IF
     END-PERFORM
     ADD 1 TO L-EM-LIFE
     IF L-EM-LIFE >= L-EM-LIFETIME
         MOVE 1 TO L-EM-REMOVED
     END-IF
     GOBACK.
 END PROGRAM PENG-EMITTER-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-EMITTER-NEW.
*> Section 5.7 TrackingEmitter constructor: the emitter starts at the entity x, y + 0.5 * height, z with
*> lifetime 3 and life 0, then calls tick once (same parameters as PENG-EMITTER-TICK).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENT.
    05 L-EX                FLOAT-LONG.
    05 L-EY                FLOAT-LONG.
    05 L-EZ                FLOAT-LONG.
    05 L-EW                FLOAT-LONG.
    05 L-EH                FLOAT-LONG.
 01 L-EM.
    05 L-EM-X              FLOAT-LONG.
    05 L-EM-Y              FLOAT-LONG.
    05 L-EM-Z              FLOAT-LONG.
    05 L-EM-LIFE           BINARY-LONG.
    05 L-EM-LIFETIME       BINARY-LONG.
    05 L-EM-REMOVED        BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 48 TIMES.
 01 L-SPAWNS.
    05 L-SP-COUNT          BINARY-LONG.
    05 L-SPAWN             OCCURS 16 TIMES.
       10 L-SP             FLOAT-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING L-ENT L-EM L-DRAWS L-SPAWNS.
     MOVE L-EX TO L-EM-X
     COMPUTE L-EM-Y = L-EY + 0.5 * L-EH
     MOVE L-EZ TO L-EM-Z
     MOVE 0 TO L-EM-LIFE L-EM-REMOVED
     MOVE 3 TO L-EM-LIFETIME
     CALL "PENG-EMITTER-TICK" USING L-ENT L-EM L-DRAWS L-SPAWNS
     GOBACK.
 END PROGRAM PENG-EMITTER-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-PICKUP-T.
*> Section 5.8: USING life, partial, t out = ((life + partial) / 3) squared.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIFE                 BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-T                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-LIFE L-PARTIAL L-T.
     COMPUTE L-T = ((L-LIFE + L-PARTIAL) / 3) * ((L-LIFE + L-PARTIAL) / 3)
     GOBACK.
 END PROGRAM PENG-PICKUP-T.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-PICKUP-POS.
*> Section 5.8 render: USING t, item position (one axis), interpolated target position, drawn position
*> out = lerp(t, item, target).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-T                    FLOAT-LONG.
 01 L-ITEM                 FLOAT-LONG.
 01 L-TARGET               FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-T L-ITEM L-TARGET L-OUT.
     COMPUTE L-OUT = L-ITEM + L-T * (L-TARGET - L-ITEM)
     GOBACK.
 END PROGRAM PENG-PICKUP-POS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-PICKUP-TICK.
*> Section 5.8 tick: USING pickup (life, removed): life + 1; at life 3 the particle removes itself.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-PICK.
    05 L-LIFE              BINARY-LONG.
    05 L-REMOVED           BINARY-LONG.
 PROCEDURE DIVISION USING L-PICK.
     ADD 1 TO L-LIFE
     IF L-LIFE = 3
         MOVE 1 TO L-REMOVED
     END-IF
     GOBACK.
 END PROGRAM PENG-PICKUP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-PICKUP-TARGET.
*> Section 5.8: USING target y, target eye y, target position y out = their mean.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-EYE                  FLOAT-LONG.
 01 L-OUT                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-EYE L-OUT.
     COMPUTE L-OUT = (L-Y + L-EYE) / 2
     GOBACK.
 END PROGRAM PENG-PICKUP-TARGET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-MTH-SIN.
*> Section 5.9 Mth.sin(double): USING x, result out (f32 widened) = SIN[(int)((long)(x * 10430.378350470453)
*> & 65535)] with SIN[i] the float of the true sine of i / 10430.378350470453.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-DOUBLE.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-SIN                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-SIN.
     COMPUTE WS-INDEX = FUNCTION INTEGER-PART(L-X * 10430.378350470453)
     COMPUTE WS-INDEX = FUNCTION MOD(WS-INDEX, 65536)
     COMPUTE WS-F32 = FUNCTION SIN(WS-INDEX / 10430.378350470453)
     MOVE WS-F32 TO L-SIN
     GOBACK.
 END PROGRAM PENG-MTH-SIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-ELDER.
*> Section 5.9 render state: USING age, partial, lifetime, alpha out, alpha byte out, X rotation in
*> degrees out. t = (age + partial) / lifetime; alpha = 0.05 + 0.5 * Mth.sin(t * 3.1415927); byte =
*> colorFromFloat channel floor(alpha * 255); rotation 60 - 150 * t.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-ARG                 FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-PI32                FLOAT-SHORT VALUE 3.1415927.
 LINKAGE SECTION.
 01 L-AGE                  BINARY-LONG.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-LIFETIME             BINARY-LONG.
 01 L-ALPHA                FLOAT-LONG.
 01 L-BYTE                 BINARY-LONG.
 01 L-DEGREES              FLOAT-LONG.
 PROCEDURE DIVISION USING L-AGE L-PARTIAL L-LIFETIME L-ALPHA L-BYTE L-DEGREES.
     COMPUTE WS-T = (L-AGE + L-PARTIAL) / L-LIFETIME
     COMPUTE WS-ARG = WS-T * WS-PI32
     CALL "PENG-MTH-SIN" USING WS-ARG WS-SIN
     COMPUTE L-ALPHA = 0.05 + 0.5 * WS-SIN
     CALL "PART-CHANNEL" USING L-ALPHA L-BYTE
     COMPUTE L-DEGREES = 60 - 150 * WS-T
     GOBACK.
 END PROGRAM PENG-ELDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENG-ELDER-CONSTANTS.
*> Section 5.9: USING lifetime out (30), light out (15728880).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIFETIME             BINARY-LONG.
 01 L-LIGHT                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIFETIME L-LIGHT.
     MOVE 30 TO L-LIFETIME
     MOVE 15728880 TO L-LIGHT
     GOBACK.
 END PROGRAM PENG-ELDER-CONSTANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PDEF-ID.
*> Section 6.1: USING sprite id (PIC X(64)) in and out: a sprite id without a namespace gets minecraft:.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COLON               BINARY-LONG.
 01 WS-OUT                 PIC X(64).
 LINKAGE SECTION.
 01 L-ID                   PIC X(64).
 PROCEDURE DIVISION USING L-ID.
     MOVE 0 TO WS-COLON
     INSPECT L-ID TALLYING WS-COLON FOR ALL ":"
     IF WS-COLON = 0
         MOVE SPACES TO WS-OUT
         STRING "minecraft:" FUNCTION TRIM(L-ID) DELIMITED BY SIZE INTO WS-OUT
         MOVE WS-OUT TO L-ID
     END-IF
     GOBACK.
 END PROGRAM PDEF-ID.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PDEF-PARSE.
*> Section 6.1 ParticleDescription.fromJson: USING text area, length, PDEF out. The root must be one
*> JSON object; "textures" (optional) is an array of sprite id strings (namespace minecraft: added when
*> absent); absent means an empty list; any other field is ignored. A malformed text or a root that is
*> not an object is a hard error (PD-ERROR 1). At most 64 sprites are kept.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY JSONDOC.
 01 WS-KEY                 PIC X(8) VALUE "textures".
 01 WS-KEY-LENGTH          BINARY-LONG VALUE 8.
 01 WS-ROOT                BINARY-LONG VALUE 1.
 01 WS-NODE                BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X.
 01 L-LENGTH               BINARY-LONG.
 COPY CLPDEF.
 PROCEDURE DIVISION USING L-TEXT L-LENGTH PDEF.
     INITIALIZE PDEF
     CALL "JSON-PARSE" USING JSON-DOC L-TEXT L-LENGTH
     IF JD-ERROR = 1 OR JN-TYPE(1) NOT = JT-OBJECT
         MOVE 1 TO PD-ERROR
         GOBACK
     END-IF
     CALL "JSON-MEMBER" USING JSON-DOC WS-ROOT WS-KEY WS-KEY-LENGTH WS-NODE
     IF WS-NODE > 0
         IF JN-TYPE(WS-NODE) = JT-ARRAY
             MOVE JN-FIRST(WS-NODE) TO WS-ELEMENT
             PERFORM UNTIL WS-ELEMENT = 0
                 IF JN-TYPE(WS-ELEMENT) = JT-STRING AND PD-COUNT < PD-MAX
                     ADD 1 TO PD-COUNT
                     MOVE SPACES TO PD-TEXTURE(PD-COUNT)
                     CALL "JSON-STRING" USING JSON-DOC WS-ELEMENT PD-TEXTURE(PD-COUNT) WS-CAP
                         WS-LENGTH
                     CALL "PDEF-ID" USING PD-TEXTURE(PD-COUNT)
                 END-IF
                 MOVE JN-NEXT(WS-ELEMENT) TO WS-ELEMENT
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PDEF-PARSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PDEF-LIST.
*> Section 6.2 point 2: USING listing, map out. The listing visits the pushed packs in push order,
*> lowest first: a file entry writes its id into one map (a later pack's file replaces an earlier
*> one's), a filter entry removes the id; the map is sorted by id.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-AT                  BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPDEF.
 PROCEDURE DIVISION USING PDEF-LISTING PDEF-MAP.
     MOVE 0 TO PM-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PL-COUNT
         MOVE 0 TO WS-AT
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PM-COUNT
             IF PM-ID(WS-J) = PL-ID(WS-I)
                 MOVE WS-J TO WS-AT
             END-IF
         END-PERFORM
         IF PL-FILTER(WS-I) NOT = 0
             IF WS-AT > 0
                 PERFORM VARYING WS-J FROM WS-AT BY 1 UNTIL WS-J >= PM-COUNT
                     MOVE PM-ENTRY(WS-J + 1) TO PM-ENTRY(WS-J)
                 END-PERFORM
                 SUBTRACT 1 FROM PM-COUNT
             END-IF
         ELSE
             IF WS-AT > 0
                 MOVE PL-PACK(WS-I) TO PM-PACK(WS-AT)
             ELSE
                 PERFORM FIND-SLOT
                 PERFORM VARYING WS-J FROM PM-COUNT BY -1 UNTIL WS-J < WS-AT
                     MOVE PM-ENTRY(WS-J) TO PM-ENTRY(WS-J + 1)
                 END-PERFORM
                 ADD 1 TO PM-COUNT
                 MOVE PL-ID(WS-I) TO PM-ID(WS-AT)
                 MOVE PL-PACK(WS-I) TO PM-PACK(WS-AT)
             END-IF
         END-IF
     END-PERFORM
     GO TO DONE.

 FIND-SLOT.
     COMPUTE WS-AT = PM-COUNT + 1
     PERFORM VARYING WS-J FROM PM-COUNT BY -1 UNTIL WS-J < 1
         IF PM-ID(WS-J) > PL-ID(WS-I)
             MOVE WS-J TO WS-AT
         END-IF
     END-PERFORM.

 DONE.
     GOBACK.
 END PROGRAM PDEF-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PDEF-REGISTERED.
*> Section 6.2 points 1 and 2: USING particle id (PIC X(64), namespace optional), registered out: 1 when
*> the type has a sprite registration (one of the 114 sprite-based types), else 0 (a plain provider,
*> or no type such as ambient_entity_effect: the file is a redundant texture list and is skipped).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  PIC X(64).
 01 WS-NAME                PIC X(32).
 01 WS-TYPE                BINARY-LONG.
 01 WS-KIND                PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-ROW                 PIC X(32).
 LINKAGE SECTION.
 01 L-ID                   PIC X(64).
 01 L-REGISTERED           BINARY-LONG.
 PROCEDURE DIVISION USING L-ID L-REGISTERED.
     MOVE 0 TO L-REGISTERED
     MOVE L-ID TO WS-ID
     IF WS-ID(1:10) = "minecraft:"
         MOVE WS-ID(11:32) TO WS-NAME
     ELSE
         MOVE WS-ID(1:32) TO WS-NAME
     END-IF
     CALL "PART-TYPE-ID" USING WS-NAME WS-TYPE
     IF WS-TYPE >= 0
         CALL "PART-TYPE" USING WS-TYPE WS-ROW WS-KIND WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
         IF WS-SPRITES > 0
             MOVE 1 TO L-REGISTERED
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PDEF-REGISTERED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PDEF-RESOLVE.
*> Section 6.2 point 3: USING PDEF, PDEF-ATLAS, PSET out, warning out (PIC X(512)). Every sprite id is
*> looked up in the atlas (index 1 to PA-COUNT); an absent id adds the missing sprite (index 0) and is
*> collected for one warning "Missing particle sprites: " followed by the sorted ids separated by
*> ", "; after resolving, an empty list becomes the single missing sprite (no warning). The set is bound.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-MISSING-COUNT       BINARY-LONG.
 01 WS-MISSING             PIC X(64) OCCURS 64 TIMES.
 01 WS-TMP                 PIC X(64).
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPDEF.
 01 L-WARNING              PIC X(512).
 PROCEDURE DIVISION USING PDEF PDEF-ATLAS PSET L-WARNING.
     INITIALIZE PSET
     MOVE SPACES TO L-WARNING
     MOVE 0 TO WS-MISSING-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PD-COUNT
         ADD 1 TO PS-COUNT
         MOVE 0 TO PS-SPRITE(PS-COUNT)
         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > PA-COUNT
             IF PA-ID(WS-J) = PD-TEXTURE(WS-I)
                 MOVE WS-J TO PS-SPRITE(PS-COUNT)
             END-IF
         END-PERFORM
         IF PS-SPRITE(PS-COUNT) = 0
             ADD 1 TO WS-MISSING-COUNT
             MOVE PD-TEXTURE(WS-I) TO WS-MISSING(WS-MISSING-COUNT)
         END-IF
     END-PERFORM
     IF PS-COUNT = 0
         MOVE 1 TO PS-COUNT
         MOVE 0 TO PS-SPRITE(1)
     END-IF
     MOVE 1 TO PS-BOUND
     IF WS-MISSING-COUNT > 0
         PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > WS-MISSING-COUNT
             MOVE WS-MISSING(WS-I) TO WS-TMP
             COMPUTE WS-J = WS-I - 1
             PERFORM UNTIL WS-J < 1 OR WS-MISSING(WS-J) <= WS-TMP
                 MOVE WS-MISSING(WS-J) TO WS-MISSING(WS-J + 1)
                 SUBTRACT 1 FROM WS-J
             END-PERFORM
             MOVE WS-TMP TO WS-MISSING(WS-J + 1)
         END-PERFORM
         MOVE 1 TO WS-PTR
         STRING "Missing particle sprites: " DELIMITED BY SIZE INTO L-WARNING WITH POINTER WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-MISSING-COUNT
             IF WS-I > 1
                 STRING ", " DELIMITED BY SIZE INTO L-WARNING WITH POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-MISSING(WS-I)) DELIMITED BY SIZE INTO L-WARNING
                 WITH POINTER WS-PTR
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM PDEF-RESOLVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSET-UNBOUND.
*> Section 6.2 point 4: USING PSET out: a sprite-registered type with no definition keeps its initial
*> sprite set, never bound (no sprites).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPDEF.
 PROCEDURE DIVISION USING PSET.
     INITIALIZE PSET
     GOBACK.
 END PROGRAM PSET-UNBOUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSET-RANDOM.
*> Section 6.3 get(random): USING sprite count n, one nextFloat draw, index out = nextInt(n) in [0, n).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-DRAW                 FLOAT-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-N L-DRAW L-INDEX.
     COMPUTE L-INDEX = FUNCTION INTEGER-PART(L-DRAW * L-N)
     IF L-INDEX >= L-N
         COMPUTE L-INDEX = L-N - 1
     END-IF
     GOBACK.
 END PROGRAM PSET-RANDOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSET-FIRST.
*> Section 6.3 first(): USING PSET, sprite (atlas index) out = PS-SPRITE(1).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPDEF.
 01 L-SPRITE               BINARY-LONG.
 PROCEDURE DIVISION USING PSET L-SPRITE.
     MOVE PS-SPRITE(1) TO L-SPRITE
     GOBACK.
 END PROGRAM PSET-FIRST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENTRY-FLAGS.
*> Section 7.1 the four entry methods: USING entry (1 addParticle without flags, 2 addParticle with
*> overrideLimiter and alwaysShow, 3 addAlwaysVisibleParticle, 4 addAlwaysVisibleParticle with
*> overrideLimiter), the type's override limiter, the override argument, the alwaysShow argument; force
*> and alwaysVisible out. 1: force = type, visible 0. 2: force = type OR argument, visible = argument.
*> 3: force 0, visible 1. 4: force = type OR argument, visible 1.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ENTRY                BINARY-LONG.
 01 L-TYPE-OVERRIDE        BINARY-LONG.
 01 L-ARG-OVERRIDE         BINARY-LONG.
 01 L-ARG-ALWAYS           BINARY-LONG.
 01 L-FORCE                BINARY-LONG.
 01 L-VISIBLE              BINARY-LONG.
 PROCEDURE DIVISION USING L-ENTRY L-TYPE-OVERRIDE L-ARG-OVERRIDE L-ARG-ALWAYS L-FORCE L-VISIBLE.
     MOVE 0 TO L-FORCE L-VISIBLE
     EVALUATE L-ENTRY
         WHEN 1
             MOVE L-TYPE-OVERRIDE TO L-FORCE
         WHEN 2
             IF L-TYPE-OVERRIDE NOT = 0 OR L-ARG-OVERRIDE NOT = 0
                 MOVE 1 TO L-FORCE
             END-IF
             MOVE L-ARG-ALWAYS TO L-VISIBLE
         WHEN 3
             MOVE 1 TO L-VISIBLE
         WHEN OTHER
             IF L-TYPE-OVERRIDE NOT = 0 OR L-ARG-OVERRIDE NOT = 0
                 MOVE 1 TO L-FORCE
             END-IF
             MOVE 1 TO L-VISIBLE
     END-EVALUATE
     GOBACK.
 END PROGRAM PENTRY-FLAGS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENTRY-STATUS.
*> Section 7.1 step 1 calculateParticleLevel: USING alwaysVisible, the Particles option (0 ALL, 1
*> DECREASED, 2 MINIMAL), the result of nextInt(10) and of nextInt(3) the level random would give,
*> status out, draws used out. Always visible and MINIMAL: nextInt(10) = 0 makes it DECREASED (one
*> draw). Then DECREASED: nextInt(3) = 0 makes it MINIMAL (one draw, taken only for DECREASED).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-VISIBLE              BINARY-LONG.
 01 L-STATUS-IN            BINARY-LONG.
 01 L-D10                  BINARY-LONG.
 01 L-D3                   BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-USED                 BINARY-LONG.
 PROCEDURE DIVISION USING L-VISIBLE L-STATUS-IN L-D10 L-D3 L-STATUS L-USED.
     MOVE L-STATUS-IN TO L-STATUS
     MOVE 0 TO L-USED
     IF L-VISIBLE NOT = 0 AND L-STATUS = 2
         ADD 1 TO L-USED
         IF L-D10 = 0
             MOVE 1 TO L-STATUS
         END-IF
     END-IF
     IF L-STATUS = 1
         ADD 1 TO L-USED
         IF L-D3 = 0
             MOVE 2 TO L-STATUS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PENTRY-STATUS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENTRY-DECIDE.
*> Section 7.1 steps 2 to 5: USING force, status (after the draws), squared distance from the camera,
*> create out. Forced: created at once. Else a squared distance above 1024 drops it, then MINIMAL
*> drops it, else it is created.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-FORCE                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 01 L-DIST2                FLOAT-LONG.
 01 L-CREATE               BINARY-LONG.
 PROCEDURE DIVISION USING L-FORCE L-STATUS L-DIST2 L-CREATE.
     MOVE 0 TO L-CREATE
     EVALUATE TRUE
         WHEN L-FORCE NOT = 0
             MOVE 1 TO L-CREATE
         WHEN L-DIST2 > 1024
             CONTINUE
         WHEN L-STATUS = 2
             CONTINUE
         WHEN OTHER
             MOVE 1 TO L-CREATE
     END-EVALUATE
     GOBACK.
 END PROGRAM PENTRY-DECIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENTRY-PACKET.
*> Section 7.2 and 05a 0x30: USING PB-BUFFER (at the packet body), PART-PACKET out, PART-OPTIONS out.
*> Fields in wire order: particle (VarInt type id and options), override limiter, always show,
*> x, y, z (Double), x, y, z distance and x, y, z max speed (Float), count VarInt, randomisation
*> VarInt (out of range = 0). PP-ERROR 1 on a short or malformed read.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BOOL                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 COPY CLPKT.
 COPY CLPART.
 PROCEDURE DIVISION USING PB-BUFFER PART-PACKET PART-OPTIONS.
     INITIALIZE PART-PACKET
     CALL "PB-GET-VARINT" USING PB-BUFFER PP-TYPE
     CALL "PART-OPT-DECODE" USING PB-BUFFER PP-TYPE PART-OPTIONS
     CALL "PB-GET-BOOL" USING PB-BUFFER PP-OVERRIDE
     CALL "PB-GET-BOOL" USING PB-BUFFER PP-ALWAYS
     CALL "PB-GET-DOUBLE" USING PB-BUFFER PP-X
     CALL "PB-GET-DOUBLE" USING PB-BUFFER PP-Y
     CALL "PB-GET-DOUBLE" USING PB-BUFFER PP-Z
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PP-DX
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PP-DY
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PP-DZ
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PP-SX
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PP-SY
     CALL "PB-GET-FLOAT" USING PB-BUFFER WS-FLOAT
     MOVE WS-FLOAT TO PP-SZ
     CALL "PB-GET-VARINT" USING PB-BUFFER PP-COUNT
     CALL "PB-GET-VARINT" USING PB-BUFFER PP-RANDOM
     IF PP-RANDOM < 0 OR PP-RANDOM > 2
         MOVE 0 TO PP-RANDOM
     END-IF
     IF PB-ERROR = 1 OR PO-ERROR NOT = 0
         MOVE 1 TO PP-ERROR
     END-IF
     GOBACK.
 END PROGRAM PENTRY-PACKET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PENTRY-SPAWNS.
*> Section 7.2: USING PART-PACKET, draws (192: nextGaussian for DEFAULT, nextDouble for the other modes,
*> consumed in order), PART-SPAWNS out (count, then x, y, z, vx, vy, vz per particle; at most 32).
*> count 0: one particle at (x, y, z) with velocity (xSpeed * xDist, ySpeed * yDist, zSpeed * zDist),
*> no draws. count > 0, per particle: DEFAULT six gaussians (offsets gx, gy, gz then velocities vx,
*> vy, vz): position x + gx * xDist, velocity vx * xSpeed. ALTERNATIVE three nextDouble offsets (position
*> x + d * xDist) and the velocity exactly the max speeds. ALTERNATIVE_WITH_SPEED as ALTERNATIVE, then
*> three more nextDouble draws multiplying the velocity components in order.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPKT.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 192 TIMES.
 PROCEDURE DIVISION USING PART-PACKET L-DRAWS PART-SPAWNS.
     INITIALIZE PART-SPAWNS
     IF PP-COUNT <= 0
         MOVE 1 TO PS-N
         MOVE PP-X TO PS-V(1, 1)
         MOVE PP-Y TO PS-V(1, 2)
         MOVE PP-Z TO PS-V(1, 3)
         COMPUTE PS-V(1, 4) = PP-SX * PP-DX
         COMPUTE PS-V(1, 5) = PP-SY * PP-DY
         COMPUTE PS-V(1, 6) = PP-SZ * PP-DZ
         GOBACK
     END-IF
     MOVE FUNCTION MIN(PP-COUNT, PP-MAX-SPAWNS) TO WS-N
     MOVE 1 TO WS-NEXT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         ADD 1 TO PS-N
         COMPUTE PS-V(WS-I, 1) = PP-X + L-DRAW(WS-NEXT) * PP-DX
         COMPUTE PS-V(WS-I, 2) = PP-Y + L-DRAW(WS-NEXT + 1) * PP-DY
         COMPUTE PS-V(WS-I, 3) = PP-Z + L-DRAW(WS-NEXT + 2) * PP-DZ
         ADD 3 TO WS-NEXT
         EVALUATE PP-RANDOM
             WHEN 1
                 MOVE PP-SX TO PS-V(WS-I, 4)
                 MOVE PP-SY TO PS-V(WS-I, 5)
                 MOVE PP-SZ TO PS-V(WS-I, 6)
             WHEN 2
                 COMPUTE PS-V(WS-I, 4) = PP-SX * L-DRAW(WS-NEXT)
                 COMPUTE PS-V(WS-I, 5) = PP-SY * L-DRAW(WS-NEXT + 1)
                 COMPUTE PS-V(WS-I, 6) = PP-SZ * L-DRAW(WS-NEXT + 2)
                 ADD 3 TO WS-NEXT
             WHEN OTHER
                 COMPUTE PS-V(WS-I, 4) = L-DRAW(WS-NEXT) * PP-SX
                 COMPUTE PS-V(WS-I, 5) = L-DRAW(WS-NEXT + 1) * PP-SY
                 COMPUTE PS-V(WS-I, 6) = L-DRAW(WS-NEXT + 2) * PP-SZ
                 ADD 3 TO WS-NEXT
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM PENTRY-SPAWNS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PRISE-NEW.
*> Section 8.1 RisingParticle: USING PCL, x, y, z, vx, vy, vz, 14 draws in order: 1-6 the base
*> velocity constructor (4.1), 7 the quad size, 8-13 the position jitter (a, b per axis x, y, z), 14
*> the lifetime. friction 0.96; each velocity component = component * 0.009999999776482582 + the
*> supplied one; pos += (a - b) * 0.05 without recentring the box; lifetime = (int)(8.0 / (r * 0.8 +
*> 0.2)) + 4.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     MOVE 0.96 TO PC-FRICTION
     COMPUTE PC-XD = PC-XD * 0.009999999776482582 + L-VX
     COMPUTE PC-YD = PC-YD * 0.009999999776482582 + L-VY
     COMPUTE PC-ZD = PC-ZD * 0.009999999776482582 + L-VZ
     COMPUTE PC-X = PC-X + (L-DRAW(8) - L-DRAW(9)) * 0.05
     COMPUTE PC-Y = PC-Y + (L-DRAW(10) - L-DRAW(11)) * 0.05
     COMPUTE PC-Z = PC-Z + (L-DRAW(12) - L-DRAW(13)) * 0.05
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(8.0 / (L-DRAW(14) * 0.8 + 0.2)) + 4
     GOBACK.
 END PROGRAM PRISE-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSA-NEW.
*> Section 8.2 SimpleAnimatedParticle: USING PCL, PCLX, x, y, z, gravity, 2 draws (lifetime, quad size).
*> Sprite = first (index 0), friction 0.91, gravity stored, no fade colour.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-GRAVITY              FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-GRAVITY L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     INITIALIZE PCLX
     MOVE 0 TO PC-SPRITE
     MOVE 0.91 TO PC-FRICTION
     MOVE L-GRAVITY TO PC-GRAVITY
     GOBACK.
 END PROGRAM PSA-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSA-CONSTANTS.
*> Section 8.2: USING light out (15728880, always full bright), layer out (1 TRANSLUCENT).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-LIGHT                BINARY-LONG.
 01 L-LAYER                BINARY-LONG.
 PROCEDURE DIVISION USING L-LIGHT L-LAYER.
     MOVE 15728880 TO L-LIGHT
     MOVE 1 TO L-LAYER
     GOBACK.
 END PROGRAM PSA-CONSTANTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSA-SET-COLOR.
*> Section 8.2 setColor(int): USING PCL, RGB24: the three channels = byte / 255.0; alpha untouched.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-R                   FLOAT-LONG.
 01 WS-G                   FLOAT-LONG.
 01 WS-B                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-RGB                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING PCL L-RGB.
     CALL "PART-RGB24" USING L-RGB WS-R WS-G WS-B
     MOVE WS-R TO PC-RCOL
     MOVE WS-G TO PC-GCOL
     MOVE WS-B TO PC-BCOL
     GOBACK.
 END PROGRAM PSA-SET-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSA-SET-FADE.
*> Section 8.2 setFadeColor(int): USING PCLX, RGB24: stores the target colour and sets hasFade.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCLX.
 01 L-RGB                  BINARY-DOUBLE.
 PROCEDURE DIVISION USING PCLX L-RGB.
     CALL "PART-RGB24" USING L-RGB PX-FADE-R PX-FADE-G PX-FADE-B
     MOVE 1 TO PX-HAS-FADE
     GOBACK.
 END PROGRAM PSA-SET-FADE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PSA-TICK.
*> Section 8.2 tick: USING PCL, PCLX, PCL-COLLIDERS, sprite count. 1 base tick; 2 setSpriteFromAge; 3 when
*> age > lifetime / 2 (integer half): alpha = 1 - (age - half) / lifetime and, with a fade colour, each
*> channel += (fade - channel) * 0.2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HALF                BINARY-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCLX PCL-COLLIDERS L-N.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL L-N
     COMPUTE WS-HALF = FUNCTION INTEGER-PART(PC-LIFETIME / 2)
     IF PC-AGE > WS-HALF
         COMPUTE PC-ALPHA = 1 - (PC-AGE - WS-HALF) / PC-LIFETIME
         IF PX-HAS-FADE NOT = 0
             COMPUTE PC-RCOL = PC-RCOL + (PX-FADE-R - PC-RCOL) * 0.2
             COMPUTE PC-GCOL = PC-GCOL + (PX-FADE-G - PC-GCOL) * 0.2
             COMPUTE PC-BCOL = PC-BCOL + (PX-FADE-B - PC-BCOL) * 0.2
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PSA-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PVERT-NEW.
*> Section 8.3 SimpleVerticalParticle: USING PCL, x, y, z, vx, vy, vz, up (1/0), 8 draws: 1-6 base
*> velocity, 7 quad size, 8 the size multiplier. xd = vx, yd = vy (+ 0.03 up, - 0.03 down), zd = vz,
*> gravity 0, quadSize *= r * 0.6 + 0.5, lifetime 8. Layer OPAQUE (0).
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-VX                   FLOAT-LONG.
 01 L-VY                   FLOAT-LONG.
 01 L-VZ                   FLOAT-LONG.
 01 L-UP                   BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-UP L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z L-VX L-VY L-VZ L-DRAWS
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     MOVE L-VX TO PC-XD
     MOVE L-VY TO PC-YD
     MOVE L-VZ TO PC-ZD
     MOVE 0 TO PC-GRAVITY
     IF L-UP NOT = 0
         ADD 0.03 TO PC-YD
     ELSE
         SUBTRACT 0.03 FROM PC-YD
     END-IF
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * (L-DRAW(8) * 0.6 + 0.5)
     MOVE 8 TO PC-LIFETIME
     GOBACK.
 END PROGRAM PVERT-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFALL-NEW.
*> Section 8.4 FallingParticle: USING PCL, PCLX, x, y, z, args (gravityScale, windBig, swirl, flowAway,
*> sizeScale, fallSpeed), 6 draws: 1 lifetime, 2 quad size, 3 first boolean (1 = true), 4 second, 5 third,
*> 6 the nextFloat f. rotSpeed -30 degrees (true) or +30; spinAcceleration -5 (true) or +5; lifetime
*> 300; gravity = gravityScale * 1.2 * 0.0025; quadSize = sizeScale * (0.05 true else 0.075) and the
*> box likewise; friction 1.0; yd = -fallSpeed; xaFlowScale = cos(radians(f * 60)) * windBig,
*> zaFlowScale = sin(...) * windBig, swirlPeriod = radians(1000 + f * 3000).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-RAD                 FLOAT-LONG VALUE 0.017453292519943295.
 01 WS-SIZE-H              FLOAT-LONG.
 01 WS-ANGLE               FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ARGS.
    05 L-GRAVITY-SCALE     FLOAT-LONG.
    05 L-WIND-BIG          FLOAT-LONG.
    05 L-SWIRL             BINARY-LONG.
    05 L-FLOW-AWAY         BINARY-LONG.
    05 L-SIZE-SCALE        FLOAT-LONG.
    05 L-FALL-SPEED        FLOAT-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL PCLX L-X L-Y L-Z L-ARGS L-DRAWS.
     CALL "PCL-NEW" USING PCL L-X L-Y L-Z L-DRAW(1)
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(2)
     INITIALIZE PCLX
     IF L-DRAW(3) NOT = 0
         COMPUTE PX-ROT-SPEED = -30 * WS-RAD
     ELSE
         COMPUTE PX-ROT-SPEED = 30 * WS-RAD
     END-IF
     IF L-DRAW(4) NOT = 0
         COMPUTE PX-SPIN-ACC = -5 * WS-RAD
     ELSE
         COMPUTE PX-SPIN-ACC = 5 * WS-RAD
     END-IF
     MOVE L-WIND-BIG TO PX-WIND-BIG
     MOVE L-SWIRL TO PX-SWIRL
     MOVE L-FLOW-AWAY TO PX-FLOW-AWAY
     MOVE 300 TO PC-LIFETIME
     COMPUTE PC-GRAVITY = L-GRAVITY-SCALE * 1.2 * 0.0025
     IF L-DRAW(5) NOT = 0
         COMPUTE PC-QUAD-SIZE = L-SIZE-SCALE * 0.05
     ELSE
         COMPUTE PC-QUAD-SIZE = L-SIZE-SCALE * 0.075
     END-IF
     MOVE PC-QUAD-SIZE TO WS-SIZE-H
     CALL "PCL-SET-SIZE" USING PCL PC-QUAD-SIZE WS-SIZE-H
     MOVE 1.0 TO PC-FRICTION
     COMPUTE PC-YD = 0 - L-FALL-SPEED
     COMPUTE WS-ANGLE = L-DRAW(6) * 60 * WS-RAD
     COMPUTE PX-XA-FLOW = FUNCTION COS(WS-ANGLE) * L-WIND-BIG
     COMPUTE PX-ZA-FLOW = FUNCTION SIN(WS-ANGLE) * L-WIND-BIG
     COMPUTE PX-SWIRL-PERIOD = (1000 + L-DRAW(6) * 3000) * WS-RAD
     GOBACK.
 END PROGRAM PFALL-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFALL-TICK.
*> Section 8.4 tick (replaces the base tick, age unused): 1 old position = position, lifetime - 1, an old
*> value <= 0 removes and ends; 2 t = min((300 - lifetime) / 300, 1); 3 wind (dx, dz): flowAway adds
*> xaFlowScale * t^1.25 and zaFlowScale * t^1.25, swirl adds t * cos(t * swirlPeriod) * windBig and
*> t * sin(...) * windBig; 4 xd += dx * 0.0024999999441206455, zd likewise, yd -= gravity; 5 rotSpeed +=
*> spinAcceleration / 20, oRoll = roll, roll += rotSpeed / 20; 6 move, then remove when onGround or when
*> lifetime < 299 and xd = 0 or zd = 0; 7 velocity *= friction.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OLD                 BINARY-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-POW                 FLOAT-LONG.
 01 WS-ARG                 FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 PROCEDURE DIVISION USING PCL PCLX PCL-COLLIDERS.
     MOVE PC-X TO PC-XO
     MOVE PC-Y TO PC-YO
     MOVE PC-Z TO PC-ZO
     MOVE PC-LIFETIME TO WS-OLD
     SUBTRACT 1 FROM PC-LIFETIME
     IF WS-OLD <= 0
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE WS-T = FUNCTION MIN((300 - PC-LIFETIME) / 300, 1)
     MOVE 0 TO WS-DX WS-DZ
     IF PX-FLOW-AWAY NOT = 0
         COMPUTE WS-POW = WS-T ** 1.25
         COMPUTE WS-DX = WS-DX + PX-XA-FLOW * WS-POW
         COMPUTE WS-DZ = WS-DZ + PX-ZA-FLOW * WS-POW
     END-IF
     IF PX-SWIRL NOT = 0
         COMPUTE WS-ARG = WS-T * PX-SWIRL-PERIOD
         COMPUTE WS-DX = WS-DX + WS-T * FUNCTION COS(WS-ARG) * PX-WIND-BIG
         COMPUTE WS-DZ = WS-DZ + WS-T * FUNCTION SIN(WS-ARG) * PX-WIND-BIG
     END-IF
     COMPUTE PC-XD = PC-XD + WS-DX * 0.0024999999441206455
     COMPUTE PC-ZD = PC-ZD + WS-DZ * 0.0024999999441206455
     COMPUTE PC-YD = PC-YD - PC-GRAVITY
     COMPUTE PX-ROT-SPEED = PX-ROT-SPEED + PX-SPIN-ACC / 20
     MOVE PC-ROLL TO PC-OROLL
     COMPUTE PC-ROLL = PC-ROLL + PX-ROT-SPEED / 20
     CALL "PCL-MOVE" USING PCL PC-XD PC-YD PC-ZD PCL-COLLIDERS
     IF PC-ON-GROUND NOT = 0
             OR (PC-LIFETIME < 299 AND (PC-XD = 0 OR PC-ZD = 0))
         MOVE 1 TO PC-REMOVED
         GOBACK
     END-IF
     COMPUTE PC-XD = PC-XD * PC-FRICTION
     COMPUTE PC-YD = PC-YD * PC-FRICTION
     COMPUTE PC-ZD = PC-ZD * PC-FRICTION
     GOBACK.
 END PROGRAM PFALL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PASH-NEW.
*> Section 8.5 BaseAshSmokeParticle: USING PCL, x, y, z, args (vxMul, vyMul, vzMul, ax, ay, az, scale,
*> colourMul, lifetimeBase, gravity, hasPhysics), 9 draws: 1-6 base velocity constructor with zero
*> velocity, 7 quad size, 8 the grey draw, 9 the lifetime draw. friction 0.96, gravity stored, speed-up
*> on; velocity = velocity * multiplier + add-on; grey = r * colourMul on all channels; quadSize *=
*> 0.75 * scale; lifetime = max((int)(lifetimeBase / (r2 * 0.8 + 0.2) * scale), 1); sprite 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO-Y              FLOAT-LONG VALUE 0.
 01 WS-ZERO-Z              FLOAT-LONG VALUE 0.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ARGS.
    05 L-VXM               FLOAT-LONG.
    05 L-VYM               FLOAT-LONG.
    05 L-VZM               FLOAT-LONG.
    05 L-AX                FLOAT-LONG.
    05 L-AY                FLOAT-LONG.
    05 L-AZ                FLOAT-LONG.
    05 L-SCALE             FLOAT-LONG.
    05 L-COLOUR            FLOAT-LONG.
    05 L-LIFE              FLOAT-LONG.
    05 L-GRAVITY           FLOAT-LONG.
    05 L-PHYSICS           BINARY-LONG.
 01 L-DRAWS.
    05 L-DRAW              FLOAT-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING PCL L-X L-Y L-Z L-ARGS L-DRAWS.
     CALL "PCL-NEW-VEL" USING PCL L-X L-Y L-Z WS-ZERO WS-ZERO-Y WS-ZERO-Z L-DRAWS
*>   The base velocity constructor adds its 0.1 y constant; the zero-bias velocity of 4.1 is kept as drawn.
     CALL "PCL-QUAD-NEW" USING PCL L-DRAW(7)
     MOVE 0.96 TO PC-FRICTION
     MOVE L-GRAVITY TO PC-GRAVITY
     MOVE 1 TO PC-SPEED-UP
     COMPUTE PC-XD = PC-XD * L-VXM + L-AX
     COMPUTE PC-YD = PC-YD * L-VYM + L-AY
     COMPUTE PC-ZD = PC-ZD * L-VZM + L-AZ
     COMPUTE PC-RCOL = L-DRAW(8) * L-COLOUR
     MOVE PC-RCOL TO PC-GCOL PC-BCOL
     COMPUTE PC-QUAD-SIZE = PC-QUAD-SIZE * 0.75 * L-SCALE
     COMPUTE PC-LIFETIME = FUNCTION INTEGER-PART(L-LIFE / (L-DRAW(9) * 0.8 + 0.2) * L-SCALE)
     IF PC-LIFETIME < 1
         MOVE 1 TO PC-LIFETIME
     END-IF
     MOVE 0 TO PC-SPRITE
     MOVE L-PHYSICS TO PC-HAS-PHYSICS
     GOBACK.
 END PROGRAM PASH-NEW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PASH-QUAD-SIZE.
*> Section 8.5 getQuadSize(partial): USING PCL, partial, size out = quadSize * clamp((age + partial) /
*> lifetime * 32, 0, 1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLPCL.
 01 L-PARTIAL              FLOAT-LONG.
 01 L-SIZE                 FLOAT-LONG.
 PROCEDURE DIVISION USING PCL L-PARTIAL L-SIZE.
     COMPUTE WS-F = FUNCTION MAX(0, FUNCTION MIN(1, (PC-AGE + L-PARTIAL) / PC-LIFETIME * 32))
     COMPUTE L-SIZE = PC-QUAD-SIZE * WS-F
     GOBACK.
 END PROGRAM PASH-QUAD-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PASH-TICK.
*> Section 8.5 tick: USING PCL, PCLX, PCL-COLLIDERS, sprite count: base tick then setSpriteFromAge.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLPCL.
 COPY CLPCLX.
 01 L-N                    BINARY-LONG.
 PROCEDURE DIVISION USING PCL PCLX PCL-COLLIDERS L-N.
     CALL "PCL-TICK" USING PCL PCL-COLLIDERS
     CALL "PCL-SPRITE-FROM-AGE" USING PCL L-N
     GOBACK.
 END PROGRAM PASH-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFILES-COUNT.
*> Section 9 point 1: USING count out: the number of sprite-registered types, each needing
*> assets/minecraft/particles/<name>.json in the generated pack (114).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-OPTIONS             PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 127
         CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
         IF WS-SPRITES > 0
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PFILES-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFILES-PATH.
*> Section 9 point 1: USING n (1 to 114), path out (PIC X(96)): the definition file of the n-th
*> sprite-registered type in registry order; spaces past the last.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ID                  BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-OPTIONS             PIC X(16).
 01 WS-OVERRIDE            BINARY-LONG.
 01 WS-PROVIDER            PIC X(56).
 01 WS-SPRITES             BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 LINKAGE SECTION.
 01 L-N                    BINARY-LONG.
 01 L-PATH                 PIC X(96).
 PROCEDURE DIVISION USING L-N L-PATH.
     MOVE SPACES TO L-PATH
     MOVE 0 TO WS-SEEN
     PERFORM VARYING WS-ID FROM 0 BY 1 UNTIL WS-ID > 127
         CALL "PART-TYPE" USING WS-ID WS-NAME WS-OPTIONS WS-OVERRIDE WS-PROVIDER WS-SPRITES WS-PART
         IF WS-SPRITES > 0
             ADD 1 TO WS-SEEN
             IF WS-SEEN = L-N
                 STRING "assets/minecraft/particles/" FUNCTION TRIM(WS-NAME) ".json"
                     DELIMITED BY SIZE INTO L-PATH
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PFILES-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFILES-CHECK.
*> Section 9 point 1: USING listing (count, file paths), missing out (of the 114 required definition
*> files), redundant out (listed files under assets/minecraft/particles/ that match no sprite-registered
*> type, such as ambient_entity_effect.json: harmless, skipped by the loader).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PATH                PIC X(96).
 01 WS-FOUND               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 LINKAGE SECTION.
 01 L-LISTING.
    05 L-COUNT             BINARY-LONG.
    05 L-FILE              PIC X(96) OCCURS 128 TIMES.
 01 L-MISSING              BINARY-LONG.
 01 L-REDUNDANT            BINARY-LONG.
 PROCEDURE DIVISION USING L-LISTING L-MISSING L-REDUNDANT.
     MOVE 0 TO L-MISSING L-REDUNDANT
     CALL "PFILES-COUNT" USING WS-COUNT
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-COUNT
         CALL "PFILES-PATH" USING WS-N WS-PATH
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
             IF L-FILE(WS-I) = WS-PATH
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             ADD 1 TO L-MISSING
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-COUNT
         MOVE 0 TO WS-FOUND
         IF L-FILE(WS-I)(1:27) = "assets/minecraft/particles/"
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-COUNT
                 CALL "PFILES-PATH" USING WS-N WS-PATH
                 IF L-FILE(WS-I) = WS-PATH
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 ADD 1 TO L-REDUNDANT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PFILES-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFILES-ATLAS.
*> Section 9 point 2: USING atlas definition path out, particle texture directory out, validation
*> numbers out: PNG files (300) and mcmeta files (1) of the vanilla jar under that directory.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-ATLAS                PIC X(96).
 01 L-DIR                  PIC X(96).
 01 L-PNG                  BINARY-LONG.
 01 L-META                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ATLAS L-DIR L-PNG L-META.
     MOVE "assets/minecraft/atlases/particles.json" TO L-ATLAS
     MOVE "assets/minecraft/textures/particle/" TO L-DIR
     MOVE 300 TO L-PNG
     MOVE 1 TO L-META
     GOBACK.
 END PROGRAM PFILES-ATLAS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PFILES-LANG-KEY.
*> Section 9 point 3: USING Particles option (0 ALL, 1 DECREASED, 2 MINIMAL, 3 the option itself), key
*> out: options.particles[.all|.decreased|.minimal].
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-STATUS               BINARY-LONG.
 01 L-KEY                  PIC X(40).
 PROCEDURE DIVISION USING L-STATUS L-KEY.
     EVALUATE L-STATUS
         WHEN 0
             MOVE "options.particles.all" TO L-KEY
         WHEN 1
             MOVE "options.particles.decreased" TO L-KEY
         WHEN 2
             MOVE "options.particles.minimal" TO L-KEY
         WHEN OTHER
             MOVE "options.particles" TO L-KEY
     END-EVALUATE
     GOBACK.
 END PROGRAM PFILES-LANG-KEY.
