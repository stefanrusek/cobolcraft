*> Axolotl and the spawn predicates of the water mobs added by lane p49d (docs/protocol/21 sections 3.2 and 4.7 with doc 44 part 7 sections 8 and 9.1). The axolotl is SM-KIND 5
*> (core/copy/MOBROWS9.cpy); STDMOB-AQUATIC-STEP calls AXOLOTL-TICK for it. Tracker fields it reuses (a species keyed use, like EN-DARK of the glow squid): EN-IDLE = PLAY_DEAD_TICKS,
*> EN-WAKE = the hunting cooldown (HAS_HUNTING_COOLDOWN), EN-FOE / EN-FOE-ID = the attack target (tracker row and entity id), EN-PET-CD = the melee cooldown, EN-WOOL = the two
*> variants of the spawn group data (first variant + 8 x second), EN-VARIANT = 1 + the variant id (0 lucy, 1 wild, 2 gold, 3 cyan, 4 blue).
*> Entry points:
*>   AXOLOTL-PLAYDEAD-TEST USING draw A, draw B, damage, health before, max health, in water, source has an entity, already playing dead, ok out: the test of 44-7 section 8.3, steps 2 to 7.
*>   AXOLOTL-PLAY-DEAD USING row: PLAY_DEAD_TICKS = 200. AXOLOTL-PLAYING-DEAD USING row, flag out: 1 while the counter is above 0.
*>   AXOLOTL-HURT USING row, damage, cause: called by HEALTH-MOB-DAMAGE before the damage applies; draws A and B and starts play dead when the test passes.
*>   AXOLOTL-FINALIZE USING xoro state, row: finalizeSpawn without group data (8.1): two common variants (nextInt(4) each), then nextInt(2) picks one.
*>   AQUA-PACK USING xoro state, first member row, row, group size before this member: the group data of a spawned pack (the axolotl: the first member's two variants, a baby from group size 2).
*>   AXOLOTL-TICK USING row, table row, in water: one tick (the timers; in water also play dead, hunting, the fight and the swim).
*>   AQUA-SPAWN-RULE USING xoro state, dim, table row, x, y, z, reason, ok out: SM-SPAWN 12 axolotl, 13 guardian, 14 drowned (21 section 3.2).
*> Gaps: out of water the axolotl neither strolls (0.15) nor looks for water (TryFindLiquid); breeding, tempting and the baby flag metadata; line of sight and the other attackability tests of
*> the sensor; rain does not count as water (isInWaterOrRain: the rain-at-position test is not in the core).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-PLAYDEAD-TEST.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DA                   BINARY-LONG.
 01 L-DB                   BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-HEALTH               BINARY-LONG.
 01 L-MAX                  BINARY-LONG.
 01 L-WATER                BINARY-LONG.
 01 L-SOURCE               BINARY-LONG.
 01 L-DEAD                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DA L-DB L-DAMAGE L-HEALTH L-MAX L-WATER L-SOURCE L-DEAD L-OK.
     MOVE 0 TO L-OK
     IF L-DA = 0 AND (L-DB < L-DAMAGE OR L-HEALTH * 2 < L-MAX) AND L-DAMAGE < L-HEALTH AND L-WATER = 1 AND L-SOURCE = 1 AND L-DEAD = 0
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM AXOLOTL-PLAYDEAD-TEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-PLAY-DEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 200 TO EN-IDLE(L-ROW)
     GOBACK.
 END PROGRAM AXOLOTL-PLAY-DEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-PLAYING-DEAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-FLAG.
     MOVE 0 TO L-FLAG
     IF EN-IDLE(L-ROW) > 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM AXOLOTL-PLAYING-DEAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-SALT                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-DA                  BINARY-LONG.
 01 WS-DB                  BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-DEAD                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DAMAGE               BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DAMAGE L-CAUSE.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0 OR SM-KEY(WS-M) NOT = "axolotl"
         GOBACK
     END-IF
     MOVE 21 TO WS-SALT
     CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
     COMPUTE WS-DA = FUNCTION INTEGER(WS-R * 3)
     MOVE 22 TO WS-SALT
     CALL "AQUA-RAND" USING L-ROW WS-SALT WS-R
     COMPUTE WS-DB = FUNCTION INTEGER(WS-R * 3)
     CALL "FLUID-TOUCHES-WATER" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-WATER
     MOVE 0 TO WS-SOURCE
     IF L-CAUSE = CAUSE-PLAYER OR L-CAUSE = CAUSE-MOB OR L-CAUSE = CAUSE-ARROW OR L-CAUSE = CAUSE-EXPLOSION
         MOVE 1 TO WS-SOURCE
     END-IF
     CALL "AXOLOTL-PLAYING-DEAD" USING L-ROW WS-DEAD
     CALL "AXOLOTL-PLAYDEAD-TEST" USING WS-DA WS-DB L-DAMAGE EN-HEALTH(L-ROW) SM-HEALTH(WS-M) WS-WATER WS-SOURCE WS-DEAD WS-OK
     IF WS-OK = 1
         CALL "AXOLOTL-PLAY-DEAD" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM AXOLOTL-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-FINALIZE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-4                   BINARY-LONG VALUE 4.
 01 WS-2                   BINARY-LONG VALUE 2.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-PICK                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW.
     CALL "XORO-NEXT-INT" USING L-STATE WS-4 WS-A
     CALL "XORO-NEXT-INT" USING L-STATE WS-4 WS-B
     CALL "XORO-NEXT-INT" USING L-STATE WS-2 WS-PICK
     COMPUTE EN-WOOL(L-ROW) = WS-A + 8 * WS-B
     IF WS-PICK = 0
         COMPUTE EN-VARIANT(L-ROW) = 1 + WS-A
     ELSE
         COMPUTE EN-VARIANT(L-ROW) = 1 + WS-B
     END-IF
     GOBACK.
 END PROGRAM AXOLOTL-FINALIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-PACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-2                   BINARY-LONG VALUE 2.
 01 WS-PICK                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FIRST                BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FIRST L-ROW L-SIZE.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0 AND SM-KEY(WS-M) = "axolotl" AND L-SIZE > 0
         CALL "XORO-NEXT-INT" USING L-STATE WS-2 WS-PICK
         IF WS-PICK = 0
             COMPUTE EN-VARIANT(L-ROW) = 1 + FUNCTION MOD(EN-WOOL(L-FIRST), 8)
         ELSE
             COMPUTE EN-VARIANT(L-ROW) = 1 + FUNCTION INTEGER(EN-WOOL(L-FIRST) / 8)
         END-IF
         MOVE EN-WOOL(L-FIRST) TO EN-WOOL(L-ROW)
         IF L-SIZE >= 2
             MOVE -24000 TO EN-MOBAGE(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM AQUA-PACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-CHASE.
*> USING row, target x, y, z (FLOAT-LONG), speed (FLOAT-LONG, attribute x modifier): the swim of AQUA-SWIM toward a point: the move speed lerps by 0.125 toward the speed, the yaw turns
*> toward the point and the velocity gains speed x 0.01 along the heading and speed x dy / distance x 0.1 vertically.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-DIST                FLOAT-LONG.
 01 WS-RADIANS             FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-SPEED                FLOAT-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-SPEED.
     COMPUTE WS-DX = L-X - EN-X(L-ROW)
     COMPUTE WS-DY = L-Y - EN-Y(L-ROW)
     COMPUTE WS-DZ = L-Z - EN-Z(L-ROW)
     MOVE EN-YAW(L-ROW) TO WS-YAW
     COMPUTE EN-SWIM-SPEED(L-ROW) = EN-SWIM-SPEED(L-ROW) + (L-SPEED - EN-SWIM-SPEED(L-ROW)) * 0.125
     CALL "MOB-YAW-TOWARD" USING WS-DX WS-DZ WS-YAW
     COMPUTE WS-DIST = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ) + 0.000001
     COMPUTE WS-RADIANS = WS-YAW * FUNCTION PI / 180
     COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - FUNCTION SIN(WS-RADIANS) * EN-SWIM-SPEED(L-ROW) * 0.01
     COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + FUNCTION COS(WS-RADIANS) * EN-SWIM-SPEED(L-ROW) * 0.01
     COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + EN-SWIM-SPEED(L-ROW) * (WS-DY / WS-DIST) * 0.1
     MOVE WS-YAW TO EN-YAW(L-ROW)
     GOBACK.
 END PROGRAM AQUA-CHASE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-SCAN.
*> USING row, target out (tracker row, 0 none): the nearest attackable of AxolotlAttackablesSensor (44-7 section 9.1): a living mob of the dimension within 8 blocks (squared distance
*> up to 64) that is in water and is of a type in tag axolotl_always_hostiles (drowned, guardian, elder_guardian) or, with no hunting cooldown, in tag axolotl_hunt_targets
*> (tropical_fish, pufferfish, salmon, cod, squid, glow_squid, tadpole).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 01 WS-WET                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TARGET               BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-TARGET.
     MOVE 0 TO L-TARGET
     MOVE 65 TO WS-BEST
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF WS-N NOT = L-ROW AND EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-DIM(WS-N) = EN-DIM(L-ROW) AND EN-HEALTH(WS-N) > 0
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-N) WS-S
             COMPUTE WS-D2 = (EN-X(WS-N) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-N) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-N) - EN-Z(L-ROW)) ** 2
             IF WS-S > 0 AND WS-D2 <= 64 AND WS-D2 < WS-BEST
                 IF SM-KEY(WS-S) = "drowned" OR "guardian" OR "elder_guardian"
                         OR (EN-WAKE(L-ROW) = 0 AND (SM-KEY(WS-S) = "tropical_fish" OR "pufferfish" OR "salmon" OR "cod" OR "squid"
                         OR "glow_squid" OR "tadpole"))
                     CALL "FLUID-TOUCHES-WATER" USING EN-DIM(WS-N) EN-X(WS-N) EN-Y(WS-N) EN-Z(WS-N) WS-WET
                     IF WS-WET = 1
                         MOVE WS-N TO L-TARGET
                         MOVE WS-D2 TO WS-BEST
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM AXOLOTL-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-STOP.
*> USING row: the fight ends (StopAttackingIfTargetInvalid and onStopAttacking, 44-7 section 8.5): when the target died and its killer is a player whose position is within 20 blocks of the
*> axolotl on every axis, that player gets Regeneration for min(2400, 100 + the time left) ticks unless a finite effect of more than 2399 ticks runs, and loses Mining Fatigue. The target is
*> forgotten and the hunting cooldown is 2400 ticks (8.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-T                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-FATIGUE             BINARY-LONG VALUE 3.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 6.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-DURATION            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE EN-FOE(L-ROW) TO WS-T
     MOVE EN-KILLER(WS-T) TO WS-P
     IF EN-USED(WS-T) = 1 AND EN-ID(WS-T) = EN-FOE-ID(L-ROW) AND EN-HEALTH(WS-T) = 0 AND WS-P > 0
         IF PL-USED(WS-P) = 1 AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW)) <= 20
                 AND FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW)) <= 20 AND FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW)) <= 20
             CALL "EFFECT-LEVEL" USING WS-P WS-REGEN WS-LEVEL WS-TICKS
             IF WS-LEVEL = 0 OR (WS-TICKS >= 0 AND WS-TICKS <= 2399)
                 COMPUTE WS-DURATION = FUNCTION MIN(2400, 100 + WS-TICKS)
                 CALL "EFFECT-ADD" USING WS-P WS-REGEN WS-AMP WS-DURATION WS-FLAGS
             END-IF
             CALL "EFFECT-REMOVE" USING WS-P WS-FATIGUE
         END-IF
     END-IF
     MOVE 0 TO EN-FOE(L-ROW) EN-FOE-ID(L-ROW)
     MOVE 2400 TO EN-WAKE(L-ROW)
     GOBACK.
 END PROGRAM AXOLOTL-STOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AXOLOTL-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-T                   BINARY-LONG.
 01 WS-REGEN               BINARY-LONG VALUE 9.
 01 WS-AMP                 BINARY-LONG VALUE 0.
 01 WS-DURATION            BINARY-LONG VALUE 200.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG VALUE 0.6.
 01 WS-REACH               FLOAT-LONG.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-CAUSE               BINARY-LONG VALUE 7.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-WET                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-WET.
     IF EN-WAKE(L-ROW) > 0
         SUBTRACT 1 FROM EN-WAKE(L-ROW)
     END-IF
     IF EN-MOBAGE(L-ROW) < 0 AND EN-LOCKED(L-ROW) = 0
         ADD 1 TO EN-MOBAGE(L-ROW)
     END-IF
     IF L-WET = 0
         GOBACK
     END-IF
     IF EN-IDLE(L-ROW) > 0
         IF EN-IDLE(L-ROW) = 200
             CALL "MEF-ADD" USING EN-ID(L-ROW) WS-REGEN WS-AMP WS-DURATION WS-FLAGS
         END-IF
         SUBTRACT 1 FROM EN-IDLE(L-ROW)
         MOVE 0 TO EN-SWIM-SPEED(L-ROW)
         IF EN-IDLE(L-ROW) > 0
             GOBACK
         END-IF
     END-IF
     MOVE EN-FOE(L-ROW) TO WS-T
     IF WS-T > 0
         COMPUTE WS-D2 = (EN-X(WS-T) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-T) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-T) - EN-Z(L-ROW)) ** 2
         IF EN-USED(WS-T) = 0 OR EN-ID(WS-T) NOT = EN-FOE-ID(L-ROW) OR EN-HEALTH(WS-T) = 0 OR WS-D2 > 256
             CALL "AXOLOTL-STOP" USING L-ROW
             MOVE 0 TO WS-T
         END-IF
     END-IF
     IF WS-T = 0 AND EN-LOVE(L-ROW) = 0 AND FUNCTION MOD(CW-TIME + EN-ID(L-ROW), 20) = 0
         CALL "AXOLOTL-SCAN" USING L-ROW WS-T
         IF WS-T > 0
             MOVE WS-T TO EN-FOE(L-ROW)
             MOVE EN-ID(WS-T) TO EN-FOE-ID(L-ROW)
         END-IF
     END-IF
     IF WS-T = 0
         CALL "AQUA-SWIM" USING L-ROW L-M
         GOBACK
     END-IF
     MOVE EN-X(WS-T) TO WS-X
     COMPUTE WS-Y = EN-Y(WS-T) + 0.2
     MOVE EN-Z(WS-T) TO WS-Z
     CALL "AQUA-CHASE" USING L-ROW WS-X WS-Y WS-Z WS-SPEED
     IF EN-PET-CD(L-ROW) > 0
         SUBTRACT 1 FROM EN-PET-CD(L-ROW)
     END-IF
     COMPUTE WS-DX = EN-X(WS-T) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-Y(WS-T) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-Z(WS-T) - EN-Z(L-ROW)
     COMPUTE WS-REACH = SM-REACH-MILLI / 1000
     IF EN-PET-CD(L-ROW) = 0 AND FUNCTION ABS(WS-DX) <= WS-REACH AND FUNCTION ABS(WS-DZ) <= WS-REACH AND FUNCTION ABS(WS-DY) < 1
         MOVE 20 TO EN-PET-CD(L-ROW)
         CALL "HEALTH-MOB-DAMAGE" USING WS-T SM-ATTACK(L-M) WS-CAUSE WS-NONE
     END-IF
     GOBACK.
 END PROGRAM AXOLOTL-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AQUA-SPAWN-RULE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY CBLOCKS.
 COPY DIMENSIONS.
 COPY STDMOBS.
 COPY MOBSPAWN.
 01 WS-Y                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-SPAWNER             BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCKLIGHT          BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-DARKEN              BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-32                  BINARY-LONG VALUE 32.
 01 WS-8                   BINARY-LONG VALUE 8.
 01 WS-20                  BINARY-LONG VALUE 20.
 01 WS-RIVER              BINARY-LONG.
 01 WS-ODDS                BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-PEACEFUL            BINARY-LONG.
 01 WS-DARK                BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-BIOME               BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-REASON               BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-DIM L-ROW L-X L-Y L-Z L-REASON L-OK.
     MOVE 0 TO L-OK WS-SPAWNER WS-PEACEFUL
     IF L-REASON = 2 OR L-REASON = 3
         MOVE 1 TO WS-SPAWNER
     END-IF
     IF BW-DIFFICULTY = 0
         MOVE 1 TO WS-PEACEFUL
     END-IF
     COMPUTE WS-Y = L-Y - 1
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-Y L-Z WS-BELOW
     CALL "MS6-BLOCK-KIND" USING L-DIM L-X L-Y L-Z WS-KIND
     EVALUATE SM-SPAWN(L-ROW)
         WHEN 12
*>           Axolotl: the block below is in axolotls_spawnable_on (clay; 44-7 section 8) and nothing else.
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
             COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
             IF CB-KEY(WS-BLOCK) = "minecraft:clay" OR CB-KEY(WS-BLOCK) = "clay"
                 MOVE 1 TO L-OK
             END-IF
         WHEN 13
*>           Guardian: (nextInt(20) is 0 or the sky is not visible from below the water) and not Peaceful and (a spawner or water at the position) and water below.
*>           The sky is visible when the column above the position holds no solid block.
             MOVE 1 TO WS-SEES
             COMPUTE WS-N = L-Y + 1
             PERFORM UNTIL WS-N >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) OR WS-SEES = 0
                 CALL "MS6-BLOCK-KIND" USING L-DIM L-X WS-N L-Z WS-BLOCK
                 IF WS-BLOCK = 1
                     MOVE 0 TO WS-SEES
                 END-IF
                 ADD 1 TO WS-N
             END-PERFORM
             CALL "XORO-NEXT-INT" USING L-STATE WS-20 WS-DRAW
             IF (WS-DRAW = 0 OR WS-SEES = 0) AND WS-PEACEFUL = 0 AND (WS-SPAWNER = 1 OR WS-KIND = 2) AND WS-BELOW = 2
                 MOVE 1 TO L-OK
             END-IF
         WHEN OTHER
*>           Drowned: water below unless a spawner; not Peaceful; the monster light test unless the trial spawner; water at the position unless a spawner; then a spawner accepts,
*>           else nextInt(15) = 0 in rivers (more_frequent_drowned_spawns) or nextInt(40) = 0 and y below sea level - 5 elsewhere.
             CALL "LIGHT-RAW" USING L-DIM L-X L-Y L-Z WS-SKY WS-BLOCKLIGHT WS-RAW
             CALL "STDMOB-DARKEN" USING CW-TIME WS-DARKEN
             CALL "MS6-LOCAL-LIGHT" USING WS-SKY WS-BLOCKLIGHT WS-DARKEN WS-ZERO WS-LOCAL
             CALL "XORO-NEXT-INT" USING L-STATE WS-32 WS-DRAW
             CALL "XORO-NEXT-INT" USING L-STATE WS-8 WS-LEVEL
             CALL "MS6-DARK-ENOUGH" USING WS-SKY WS-BLOCKLIGHT WS-DRAW WS-ZERO WS-LOCAL WS-LEVEL WS-DARK
             MOVE 0 TO WS-BASE
             IF (WS-SPAWNER = 1 OR WS-BELOW = 2) AND WS-PEACEFUL = 0 AND (L-REASON = 3 OR WS-DARK = 1) AND (WS-SPAWNER = 1 OR WS-KIND = 2)
                 MOVE 1 TO WS-BASE
             END-IF
             CALL "MS6-BIOME-AT" USING L-DIM L-X L-Y L-Z WS-BIOME
             MOVE 0 TO WS-RIVER
             INSPECT SPB-NAME(WS-BIOME) TALLYING WS-RIVER FOR ALL "river"
             COMPUTE WS-ODDS = 40 - 25 * FUNCTION MIN(WS-RIVER, 1)
             IF WS-BASE = 1 AND WS-SPAWNER = 1
                 MOVE 1 TO L-OK
             END-IF
             IF WS-BASE = 1 AND WS-SPAWNER = 0
                 CALL "XORO-NEXT-INT" USING L-STATE WS-ODDS WS-DRAW
                 IF WS-DRAW = 0 AND (WS-RIVER > 0 OR L-Y < DM-SEA-LEVEL(L-DIM) - 5)
                     MOVE 1 TO L-OK
                 END-IF
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM AQUA-SPAWN-RULE.
