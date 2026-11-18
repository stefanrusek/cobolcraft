*> Leftovers of the mob framework (docs/protocol/18 sections 2.6, 2.8, 3.1, 3.3 and 4.4; 002-lane-p49n). State: P49NSTATE.cpy (PN-LH-*, PN-JUMP, PN-NOJUMP).
*>
*>   MOB-HURT-BY-MOB USING victim row, attacker row: setLastHurtByMob of a mob attacker (the player attackers are EN-KILLER): the attacker's entity id is remembered, the timestamp is now.
*>   MOB-LAST-HURT-BY USING row, attacker row out: the live attacker of lastHurtByMob (0 when there is none).
*>   MOB-LHBM-TICK USING row: baseTick (2.8): the memory is cleared when the attacker is dead (or gone) and when 100 ticks have passed since its timestamp.
*>   MOB-IMMOBILE USING row, immobile out: isImmobile (2.6 step 5): a dead or dying mob, a sitting pet (EN-SIT) and a sleeping fox (flag 32).
*>   MOB-JUMP-REQUEST USING row: JumpControl.jump() (4.4): the jumping input for one tick.
*>   MOB-JUMP-TICK USING row: LivingEntity.aiStep steps 1, 5 and 6 (2.6): noJumpDelay falls by 1; an immobile mob loses its request; with a request in deep water (water 0.4 above the feet, the
*>     fluid jump threshold of a mob of eye height at least 0.4) the vertical velocity gets +0.04 (jumpInLiquid), else a mob on the ground with noJumpDelay 0 jumps (vertical velocity
*>     max(0.42 x the block jump factor (0.5 over honey), vy), noJumpDelay 10); without a request noJumpDelay is 0; the request is spent.
*>   STDMOB-WATER-HURT USING row: the water-sensitive mobs of 2.6 step 12 (snow golem, blaze; the enderman has its own in mob-20-8.cob) take 1.0 drowning damage in a tick when they stand in
*>     water or in rain with the sky open.
*>   MOB-PUSH-TICK USING row: pushEntities (3.3): every live standard mob whose box overlaps this one's box is pushed along the line of the centres (Entity.push: d = max(|dx|, |dz|), no push
*>     below 0.01, then 0.05 x min(1 / sqrt(d), 1) x the unit vector scaled by 1 / sqrt(d)), this one by the opposite vector. Players are not pushed (they have no velocity here).
*> Not here: the per-block jump factor other than honey, the eye height of a mob (0.85 of its height is used for the 0.4 threshold), lava jumps, the sleeping state of other mobs, pushing a player
*> or a vehicle's passengers, a sleeping mob not being pushed.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-HURT-BY-MOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-VICTIM               BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-VICTIM L-ATTACKER.
     CALL "PN-ROW-OPEN" USING L-VICTIM
     MOVE EN-ID(L-ATTACKER) TO PN-LH-ID(L-VICTIM)
     MOVE 0 TO PN-LH-AGE(L-VICTIM)
     GOBACK.
 END PROGRAM MOB-HURT-BY-MOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LAST-HURT-BY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-ATTACKER.
     MOVE 0 TO L-ATTACKER
     IF PN-ID(L-ROW) = EN-ID(L-ROW) AND PN-LH-ID(L-ROW) > 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-ATTACKER > 0
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PN-LH-ID(L-ROW) AND EN-HEALTH(WS-E) > 0
                 MOVE WS-E TO L-ATTACKER
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM MOB-LAST-HURT-BY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-LHBM-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 01 WS-ATTACKER            BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF PN-ID(L-ROW) = EN-ID(L-ROW) AND PN-LH-ID(L-ROW) > 0
         CALL "MOB-LAST-HURT-BY" USING L-ROW WS-ATTACKER
         ADD 1 TO PN-LH-AGE(L-ROW)
         IF WS-ATTACKER = 0 OR PN-LH-AGE(L-ROW) >= 100
             MOVE 0 TO PN-LH-ID(L-ROW) PN-LH-AGE(L-ROW)
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-LHBM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-IMMOBILE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-BIT                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-IMMOBILE             BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-IMMOBILE.
     MOVE 0 TO L-IMMOBILE
     IF EN-HEALTH(L-ROW) = 0
         MOVE 1 TO L-IMMOBILE
     END-IF
     IF EN-SIT(L-ROW) = 1
         MOVE 1 TO L-IMMOBILE
     END-IF
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M > 0
         IF SM-KEY(WS-M) = "fox"
             COMPUTE WS-BIT = FUNCTION MOD(EN-FOX-FLAGS(L-ROW) / 32, 2)
             IF WS-BIT = 1
                 MOVE 1 TO L-IMMOBILE
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM MOB-IMMOBILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-JUMP-REQUEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY P49NSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     MOVE 1 TO PN-JUMP(L-ROW)
     GOBACK.
 END PROGRAM MOB-JUMP-REQUEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-JUMP-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY P49NSTATE.
 01 WS-IMM                 BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-DEEP                BINARY-LONG.
 01 WS-DEEP-Y              FLOAT-LONG.
 01 WS-THRESHOLD           FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-POWER               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "PN-ROW-OPEN" USING L-ROW
     IF PN-NOJUMP(L-ROW) > 0
         SUBTRACT 1 FROM PN-NOJUMP(L-ROW)
     END-IF
     CALL "MOB-IMMOBILE" USING L-ROW WS-IMM
     IF WS-IMM = 1
         MOVE 0 TO PN-JUMP(L-ROW)
     END-IF
     IF PN-JUMP(L-ROW) = 1
         CALL "FLUID-TOUCHES-WATER" USING EN-DIM(L-ROW) EN-X(L-ROW) EN-Y(L-ROW) EN-Z(L-ROW) WS-WET
         MOVE 0 TO WS-DEEP
         IF WS-WET = 1
             MOVE 0 TO WS-THRESHOLD
             IF ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) * 0.85 >= 400
                 MOVE 0.4 TO WS-THRESHOLD
             END-IF
             COMPUTE WS-DEEP-Y = EN-Y(L-ROW) + WS-THRESHOLD
             CALL "FLUID-TOUCHES-WATER" USING EN-DIM(L-ROW) EN-X(L-ROW) WS-DEEP-Y EN-Z(L-ROW) WS-DEEP
             IF WS-DEEP = 0 AND EN-ON-GROUND(L-ROW) = 0
                 MOVE 1 TO WS-DEEP
             END-IF
         END-IF
         IF WS-DEEP = 1
             ADD 0.04 TO EN-VY(L-ROW)
         ELSE
             IF EN-ON-GROUND(L-ROW) = 1 AND PN-NOJUMP(L-ROW) = 0
                 MOVE 0.42 TO WS-POWER
                 COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
                 COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW) - 0.500001)
                 COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
                 CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
                 IF WS-STATE > 0
                     IF CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "minecraft:honey_block" OR "honey_block"
                         COMPUTE WS-POWER = WS-POWER * 0.5
                     END-IF
                 END-IF
                 IF WS-POWER > EN-VY(L-ROW)
                     MOVE WS-POWER TO EN-VY(L-ROW)
                 END-IF
                 MOVE 10 TO PN-NOJUMP(L-ROW)
             END-IF
         END-IF
     ELSE
         MOVE 0 TO PN-NOJUMP(L-ROW)
     END-IF
     MOVE 0 TO PN-JUMP(L-ROW)
     GOBACK.
 END PROGRAM MOB-JUMP-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-WATER-HURT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY RULES.
 COPY STDMOBS.
 01 WS-M                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-EYE                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WET                 BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLK                 BINARY-LONG.
 01 WS-RAIN                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-DROWN.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     CALL "STDMOB-INDEX" USING EN-TYPE(L-ROW) WS-M
     IF WS-M = 0
         GOBACK
     END-IF
     IF SM-KEY(WS-M) NOT = "snow_golem" AND SM-KEY(WS-M) NOT = "blaze"
         GOBACK
     END-IF
     MOVE 0 TO WS-WET
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(L-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(L-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(L-ROW))
     CALL "WORLD-GET-BLOCK" USING EN-DIM(L-ROW) WS-BX WS-BY WS-BZ WS-STATE
     IF WS-STATE > 0
         IF CB-KEY(CB-S-BLOCK(WS-STATE + 1) + 1) = "minecraft:water" OR "water"
             MOVE 1 TO WS-WET
         END-IF
     END-IF
     COMPUTE WS-EYE = WS-BY + 1
     CALL "STDMOB-LIGHTS" USING EN-DIM(L-ROW) WS-BX WS-EYE WS-BZ WS-SKY WS-BLK
     CALL "WEATHER-RAINING" USING EN-DIM(L-ROW) WS-RAIN
     IF WS-RAIN = 1 AND WS-SKY >= 15
         MOVE 1 TO WS-WET
     END-IF
     IF WS-WET = 1
         MOVE 0 TO EN-HURT(L-ROW)
         CALL "HEALTH-MOB-DAMAGE" USING L-ROW WS-AMOUNT WS-CAUSE WS-NONE
     END-IF
     GOBACK.
 END PROGRAM STDMOB-WATER-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MOB-PUSH-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WS-S                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-HALF-A              FLOAT-LONG.
 01 WS-HEIGHT-A            FLOAT-LONG.
 01 WS-HALF-B              FLOAT-LONG.
 01 WS-HEIGHT-B            FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-HALF-A = ET-WIDTH-MILLI(EN-TYPE(L-ROW) + 1) / 2000
     COMPUTE WS-HEIGHT-A = ET-HEIGHT-MILLI(EN-TYPE(L-ROW) + 1) / 1000
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF WS-E NOT = L-ROW AND EN-USED(WS-E) = 1 AND EN-PLAYER(WS-E) = 0 AND EN-HEALTH(WS-E) > 0 AND EN-DIM(WS-E) = EN-DIM(L-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-S
             IF WS-S > 0
                 COMPUTE WS-HALF-B = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                 COMPUTE WS-HEIGHT-B = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                 IF FUNCTION ABS(EN-X(WS-E) - EN-X(L-ROW)) < WS-HALF-A + WS-HALF-B
                         AND FUNCTION ABS(EN-Z(WS-E) - EN-Z(L-ROW)) < WS-HALF-A + WS-HALF-B
                         AND EN-Y(WS-E) < EN-Y(L-ROW) + WS-HEIGHT-A AND EN-Y(L-ROW) < EN-Y(WS-E) + WS-HEIGHT-B
                     COMPUTE WS-DX = EN-X(WS-E) - EN-X(L-ROW)
                     COMPUTE WS-DZ = EN-Z(WS-E) - EN-Z(L-ROW)
                     COMPUTE WS-D = FUNCTION MAX(FUNCTION ABS(WS-DX), FUNCTION ABS(WS-DZ))
                     IF WS-D >= 0.01
                         COMPUTE WS-D = FUNCTION SQRT(WS-D)
                         COMPUTE WS-DX = WS-DX / WS-D
                         COMPUTE WS-DZ = WS-DZ / WS-D
                         COMPUTE WS-F = FUNCTION MIN(1 / WS-D, 1)
                         COMPUTE WS-DX = WS-DX * WS-F * 0.05
                         COMPUTE WS-DZ = WS-DZ * WS-F * 0.05
                         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) - WS-DX
                         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) - WS-DZ
                         COMPUTE EN-VX(WS-E) = EN-VX(WS-E) + WS-DX
                         COMPUTE EN-VZ(WS-E) = EN-VZ(WS-E) + WS-DZ
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MOB-PUSH-TICK.
