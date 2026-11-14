*> Acceptance test of docs/protocol/42-particles-2-effects-fire-smoke-magic.md section 1 (provider and class
*> index): every row of the table (id, override flag, sprite count, sprite pick, layer, physics, class,
*> provider, section) and the validation counts V1, V2 (38 provider classes) and V4, V14.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-PARTICLES-42-2-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLP2IX.
 COPY TESTLIB.
 01 WS-TYPE                PIC X(24).
 01 WS-EXP                 PIC X(140).
 01 WS-OBS                 PIC X(140).
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-OVR                 BINARY-LONG.
 01 WS-TRANS               BINARY-LONG.
 01 WS-LIST.
    05 WS-LIST-NAME        PIC X(24) OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     MOVE "heart" TO WS-TYPE
     MOVE "055001200HeartParticle|HeartParticle$Provider|3.1" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "angry_villager" TO WS-TYPE
     MOVE "000001200HeartParticle|HeartParticle$AngryVillagerProvider|3.1" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "happy_villager" TO WS-TYPE
     MOVE "053001200SuspendedTownParticle|SuspendedTownParticle$HappyVillagerProvider|3.2" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "composter" TO WS-TYPE
     MOVE "054001200SuspendedTownParticle|SuspendedTownParticle$ComposterFillProvider|3.2" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "crit" TO WS-TYPE
     MOVE "013001200CritParticle|CritParticle$Provider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "enchanted_hit" TO WS-TYPE
     MOVE "025001200CritParticle|CritParticle$MagicProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "damage_indicator" TO WS-TYPE
     MOVE "014101200CritParticle|CritParticle$DamageIndicatorProvider|3.3" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "sweep_attack" TO WS-TYPE
     MOVE "077108102AttackSweepParticle|AttackSweepParticle$Provider|3.4" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "poof" TO WS-TYPE
     MOVE "069108101ExplodeParticle|ExplodeParticle$Provider|3.5" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "spit" TO WS-TYPE
     MOVE "075108101SpitParticle|SpitParticle$Provider|3.5" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "cloud" TO WS-TYPE
     MOVE "011008110PlayerCloudParticle|PlayerCloudParticle$Provider|3.6" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "sneeze" TO WS-TYPE
     MOVE "074008110PlayerCloudParticle|PlayerCloudParticle$SneezeProvider|3.6" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "effect" TO WS-TYPE
     MOVE "023008110SpellParticle|SpellParticle$InstantProvider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "instant_effect" TO WS-TYPE
     MOVE "056008110SpellParticle|SpellParticle$InstantProvider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "entity_effect" TO WS-TYPE
     MOVE "028008110SpellParticle|SpellParticle$MobEffectProvider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "witch" TO WS-TYPE
     MOVE "081008110SpellParticle|SpellParticle$WitchProvider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "infested" TO WS-TYPE
     MOVE "040001110SpellParticle|SpellParticle$Provider|3.7" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dragon_breath" TO WS-TYPE
     MOVE "015003100DragonBreathParticle|DragonBreathParticle$Provider|3.8" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "enchant" TO WS-TYPE
     MOVE "026026200FlyTowardsPositionParticle|FlyTowardsPositionParticle$EnchantProvider|3.9" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "nautilus" TO WS-TYPE
     MOVE "085001200FlyTowardsPositionParticle|FlyTowardsPositionParticle$NautilusProvider|3.9" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "end_rod" TO WS-TYPE
     MOVE "027008110EndRodParticle|EndRodParticle$Provider|3.10" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "totem_of_undying" TO WS-TYPE
     MOVE "078008111TotemParticle|TotemParticle$Provider|3.11" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "explosion" TO WS-TYPE
     MOVE "030116102HugeExplosionParticle|HugeExplosionParticle$Provider|3.12" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "explosion_emitter" TO WS-TYPE
     MOVE "029100320HugeExplosionSeedParticle|HugeExplosionSeedParticle$Provider|3.12" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "firework" TO WS-TYPE
     MOVE "037008111FireworkParticles$SparkParticle|FireworkParticles$SparkProvider|3.13" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "flash" TO WS-TYPE
     MOVE "052001212FireworkParticles$OverlayParticle|FireworkParticles$FlashProvider|3.13" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "flame" TO WS-TYPE
     MOVE "039001200FlameParticle|FlameParticle$Provider|3.14" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "small_flame" TO WS-TYPE
     MOVE "103001200FlameParticle|FlameParticle$SmallFlameProvider|3.14" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "soul_fire_flame" TO WS-TYPE
     MOVE "050001200FlameParticle|FlameParticle$Provider|3.14" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "copper_fire_flame" TO WS-TYPE
     MOVE "012001200FlameParticle|FlameParticle$Provider|3.14" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "soul" TO WS-TYPE
     MOVE "051011111EmissiveRisingParticle|EmissiveRisingParticle$Provider|3.15" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "smoke" TO WS-TYPE
     MOVE "072008101SmokeParticle|SmokeParticle$Provider|3.16" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "large_smoke" TO WS-TYPE
     MOVE "065008101LargeSmokeParticle|LargeSmokeParticle$Provider|3.16" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "white_smoke" TO WS-TYPE
     MOVE "073008101WhiteSmokeParticle|WhiteSmokeParticle$Provider|3.16" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "campfire_cosy_smoke" TO WS-TYPE
     MOVE "087112211CampfireSmokeParticle|CampfireSmokeParticle$CosyProvider|3.17" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "campfire_signal_smoke" TO WS-TYPE
     MOVE "088112211CampfireSmokeParticle|CampfireSmokeParticle$SignalProvider|3.17" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "note" TO WS-TYPE
     MOVE "068001201NoteParticle|NoteParticle$Provider|3.18" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "elder_guardian" TO WS-TYPE
     MOVE "024100422ElderGuardianParticle|ElderGuardianParticle$Provider|3.19" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "portal" TO WS-TYPE
     MOVE "070008200PortalParticle|PortalParticle$Provider|3.20" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "reverse_portal" TO WS-TYPE
     MOVE "101008200ReversePortalParticle|ReversePortalParticle$ReversePortalProvider|3.20" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "lava" TO WS-TYPE
     MOVE "066001201LavaParticle|LavaParticle$Provider|3.21" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "pause_mob_growth" TO WS-TYPE
     MOVE "060001201SimpleVerticalParticle|SimpleVerticalParticle$PauseMobGrowthProvider|3.22" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "reset_mob_growth" TO WS-TYPE
     MOVE "061001201SimpleVerticalParticle|SimpleVerticalParticle$ResetMobGrowthProvider|3.22" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "dolphin" TO WS-TYPE
     MOVE "086001200SuspendedTownParticle|SuspendedTownParticle$DolphinSpeedProvider|3.2" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "egg_crack" TO WS-TYPE
     MOVE "116001200SuspendedTownParticle|SuspendedTownParticle$EggCrackProvider|3.2" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "glow" TO WS-TYPE
     MOVE "110101100GlowParticle|GlowParticle$GlowSquidProvider|3.23" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "wax_on" TO WS-TYPE
     MOVE "111101100GlowParticle|GlowParticle$WaxOnProvider|3.23" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "wax_off" TO WS-TYPE
     MOVE "112101100GlowParticle|GlowParticle$WaxOffProvider|3.23" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "electric_spark" TO WS-TYPE
     MOVE "113101100GlowParticle|GlowParticle$ElectricSparkProvider|3.23" TO WS-EXP
     PERFORM CHK-ROW
     MOVE "scrape" TO WS-TYPE
     MOVE "114101100GlowParticle|GlowParticle$ScrapeProvider|3.23" TO WS-EXP
     PERFORM CHK-ROW
*>   V1: 41 listed types plus 9 siblings.
     CALL "P2-INDEX-COUNT" USING WS-N
     MOVE "V1: 41 listed types and 9 siblings make 50 rows" TO TL-CASE
     PERFORM TL-CASE-PREFIX
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   V2: 38 distinct provider classes over the 41 listed registrations (the siblings add 4 more: SpellParticle$Provider,
*>   FlyTowardsPositionParticle$NautilusProvider, SuspendedTownParticle$DolphinSpeedProvider, ..$EggCrackProvider, five GlowParticle ones).
     MOVE 0 TO WS-N WS-OVR WS-TRANS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         CALL "P2-INDEX-ROW" USING WS-I P2IX
         ADD P2-OVR TO WS-OVR
         IF P2-LAYER = 1
             ADD 1 TO WS-TRANS
         END-IF
     END-PERFORM
     MOVE "V4: override flags on 9 of the 41 listed plus 5 glow-family siblings" TO TL-CASE
     PERFORM TL-CASE-PREFIX
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-OVR TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "V14: translucent rows (13 listed types plus infested make 14)" TO TL-CASE
     PERFORM TL-CASE-PREFIX
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-TRANS TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     CALL "P2-PROVIDER-CLASSES" USING WS-N WS-M
     MOVE "V2: 38 distinct provider classes among the 41 listed registrations" TO TL-CASE
     PERFORM TL-CASE-PREFIX
     MOVE 38 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     MOVE "V2: FlameParticle$Provider serves three types and SpellParticle$InstantProvider two" TO TL-CASE
     PERFORM TL-CASE-PREFIX
     MOVE 302 TO TL-EXPECTED-N
     MOVE WS-M TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
*>   An unknown type gives found 0.
     MOVE "no_such_particle" TO WS-TYPE
     CALL "P2-INDEX" USING WS-TYPE P2IX
     MOVE "an unknown type is not found" TO TL-CASE
     PERFORM TL-CASE-PREFIX
     MOVE 0 TO TL-EXPECTED-N
     MOVE P2-FOUND TO TL-OBSERVED-N
     PERFORM ASSERT-NUMBER
     STOP RUN.

 CHK-ROW.
     CALL "P2-INDEX" USING WS-TYPE P2IX
     MOVE SPACES TO WS-OBS
     STRING P2-ID P2-OVR P2-SPR P2-PICK P2-LAYER P2-PHYS FUNCTION TRIM(P2-CLASS) "|"
         FUNCTION TRIM(P2-PROVIDER) "|" FUNCTION TRIM(P2-SECTION)
         DELIMITED BY SIZE INTO WS-OBS
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-2§1 Provider and class index: row " FUNCTION TRIM(WS-TYPE)
         DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 TL-CASE-PREFIX.
     MOVE SPACES TO WS-EXP
     MOVE FUNCTION TRIM(TL-CASE) TO WS-EXP
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 42-2§1 Provider and class index: " FUNCTION TRIM(WS-EXP)
         DELIMITED BY SIZE INTO TL-CASE.

 ASSERT-NUMBER.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-PARTICLES-42-2-1.
