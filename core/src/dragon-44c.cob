*> The ender dragon entity (docs/protocol/21 section 6.4, 44 part 9 section 1; lane 002-lane-mobsb8, T9703): the spawn, the tick, the damage rules, the death sequence and the crystal hook.
*>
*>   DRAGON-SPAWN USING dim, x, y, z (FLOAT-LONG), row out (0 when it cannot be made)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:ender_dragon".
 01 WS-KIND                BINARY-LONG VALUE 17.
 01 WS-ZERO                FLOAT-LONG VALUE 0.
 01 WS-ZERO2               FLOAT-LONG VALUE 0.
 01 WS-ZERO3               FLOAT-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-ROW.
     CALL "THROWN-SPAWN" USING WS-KIND WS-KEY L-DIM L-X L-Y L-Z WS-ZERO WS-ZERO2 WS-ZERO3 WS-NONE L-ROW
     IF L-ROW > 0
         MOVE 200 TO EN-HEALTH(L-ROW)
         INITIALIZE DG-STATE
         MOVE EN-ID(L-ROW) TO DG-ENT
         MOVE 200 TO DG-HP
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 64
             MOVE L-Y TO DG-HIST-Y(WS-I)
             MOVE EN-YAW(L-ROW) TO DG-HIST-YAW(WS-I)
         END-PERFORM
         CALL "DRAGON-NODES-INIT" USING L-DIM
     END-IF
     GOBACK.
 END PROGRAM DRAGON-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-ROW.
*> USING row out: the tracker row of the dragon (0 none).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-E                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE 0 TO L-ROW
     IF DG-ENT > 0
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT OR L-ROW > 0
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = DG-ENT
                 MOVE WS-E TO L-ROW
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM DRAGON-ROW.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-HEALTH-SYNC.
*> USING row: the tracker row's health is the ceiling of the exact health; the viewers get the changed value (the health slot, 18 section 9.3).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-I = FUNCTION INTEGER(DG-HP)
     IF DG-HP > WS-I
         ADD 1 TO WS-I
     END-IF
     MOVE WS-I TO EN-HEALTH(L-ROW)
     CALL "STDMOB-HP-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM DRAGON-HEALTH-SYNC.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-HURT-PART.
*> USING row, part (1 to 8), amount (FLOAT-LONG), cause (RULES.cpy), attacker player row (0 none), applied out: EnderDragon.hurt(part, source, amount) of 21 section 6.4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 COPY RULES.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-SIT                 BINARY-LONG.
 01 WS-PHASE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 01 L-AMOUNT               FLOAT-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PART L-AMOUNT L-CAUSE L-ATTACKER L-OK.
     MOVE 0 TO L-OK
     IF DG-PHASE = 9
         GOBACK
     END-IF
     MOVE 0 TO WS-SIT
     IF DG-PHASE = 5 OR DG-PHASE = 6 OR DG-PHASE = 7 OR DG-PHASE = 10
         MOVE 1 TO WS-SIT
     END-IF
     IF WS-SIT = 1 AND L-CAUSE = CAUSE-ARROW
         GOBACK
     END-IF
     IF L-ATTACKER = 0 AND L-CAUSE NOT = CAUSE-EXPLOSION
         GOBACK
     END-IF
     MOVE L-AMOUNT TO WS-AMOUNT
     IF L-PART > 2
         COMPUTE WS-AMOUNT = WS-AMOUNT / 4 + FUNCTION MIN(WS-AMOUNT, 1)
     END-IF
     IF WS-AMOUNT < 0.01
         GOBACK
     END-IF
     MOVE 1 TO L-OK
     COMPUTE DG-HP = DG-HP - WS-AMOUNT
     MOVE DG-TICK TO DG-HURT-T
     IF WS-SIT = 1
         COMPUTE DG-SIT-DMG = DG-SIT-DMG + WS-AMOUNT
         IF DG-SIT-DMG > 50
             MOVE 0 TO DG-SIT-DMG
             MOVE 4 TO WS-PHASE
             CALL "DRAGON-SET-PHASE" USING L-ROW WS-PHASE
         END-IF
     END-IF
     IF DG-HP <= 0
         IF WS-SIT = 0
             MOVE 1 TO DG-HP
             MOVE 9 TO WS-PHASE
             CALL "DRAGON-SET-PHASE" USING L-ROW WS-PHASE
         ELSE
             MOVE 0 TO DG-HP
         END-IF
     END-IF
     CALL "DRAGON-HEALTH-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM DRAGON-HURT-PART.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-PART-NEAR.
*> USING row, player row (0 = none), part out: the part nearest to the attacker's eye (the body without one).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-PART                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-PLAYER L-PART.
     MOVE 3 TO L-PART
     IF L-PLAYER = 0
         GOBACK
     END-IF
     CALL "DRAGON-PARTS" USING L-ROW
     MOVE 1.0E+30 TO WS-BEST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         CALL "DRAGON-PART-SIZE" USING WS-I WS-W WS-H
         COMPUTE WS-D2 = (PL-X(L-PLAYER) - DG-PART-X(WS-I)) ** 2 + (PL-Y(L-PLAYER) + 1.62 - DG-PART-Y(WS-I) - WS-H / 2) ** 2 + (PL-Z(L-PLAYER) - DG-PART-Z(WS-I)) ** 2 - (WS-W / 2) ** 2
         IF WS-D2 < WS-BEST
             MOVE WS-D2 TO WS-BEST
             MOVE WS-I TO L-PART
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM DRAGON-PART-NEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-HURT.
*> USING row, amount (points), cause, attacker player row, handled out: called by HEALTH-MOB-DAMAGE; the dragon takes its own damage through DRAGON-HURT-PART (the part nearest to the attacker).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-PART                BINARY-LONG.
 01 WS-AMOUNT              FLOAT-LONG.
 01 WS-OK                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-AMOUNT               BINARY-LONG.
 01 L-CAUSE                BINARY-LONG.
 01 L-ATTACKER             BINARY-LONG.
 01 L-HANDLED              BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-AMOUNT L-CAUSE L-ATTACKER L-HANDLED.
     MOVE 0 TO L-HANDLED
     IF DG-ENT = 0 OR EN-ID(L-ROW) NOT = DG-ENT
         GOBACK
     END-IF
     MOVE 1 TO L-HANDLED
     CALL "DRAGON-PART-NEAR" USING L-ROW L-ATTACKER WS-PART
     MOVE L-AMOUNT TO WS-AMOUNT
     CALL "DRAGON-HURT-PART" USING L-ROW WS-PART WS-AMOUNT L-CAUSE L-ATTACKER WS-OK
     GOBACK.
 END PROGRAM DRAGON-HURT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-HEAL.
*> USING row: checkCrystals: a removed nearest crystal is forgotten, else every 10 ticks the dragon heals 1; with chance 1 in 10 it rescans for the nearest end crystal within 32 blocks of its box.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROJSTATE.
 COPY DRAGSTATE.
 01 WS-E                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-TEN                 BINARY-LONG VALUE 10.
 01 WS-D2                  FLOAT-LONG.
 01 WS-BEST                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF DG-CRYSTAL > 0
         MOVE 0 TO WS-FOUND
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = DG-CRYSTAL
                 MOVE 1 TO WS-FOUND
             END-IF
         END-PERFORM
         IF WS-FOUND = 0
             MOVE 0 TO DG-CRYSTAL
         ELSE
             IF FUNCTION MOD(DG-TICK, 10) = 0 AND DG-HP < 200
                 COMPUTE DG-HP = FUNCTION MIN(200, DG-HP + 1)
                 CALL "DRAGON-HEALTH-SYNC" USING L-ROW
             END-IF
         END-IF
     END-IF
     CALL "DRAGON-ROLL" USING WS-TEN WS-ROLL
     IF WS-ROLL = 0
         MOVE 1.0E+30 TO WS-BEST
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > PJ-MAX
             IF PJ-ENT(WS-I) > 0 AND PJ-KIND(WS-I) = 16
                 PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
                     IF EN-USED(WS-E) = 1 AND EN-ID(WS-E) = PJ-ENT(WS-I) AND EN-DIM(WS-E) = EN-DIM(L-ROW)
                         COMPUTE WS-D2 = (EN-X(WS-E) - EN-X(L-ROW)) ** 2 + (EN-Y(WS-E) - EN-Y(L-ROW)) ** 2 + (EN-Z(WS-E) - EN-Z(L-ROW)) ** 2
                         IF WS-D2 <= 1600 AND WS-D2 < WS-BEST
                             MOVE WS-D2 TO WS-BEST
                             MOVE PJ-ENT(WS-I) TO DG-CRYSTAL
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM DRAGON-HEAL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-CRYSTAL-DESTROYED.
*> USING crystal entity id, destroyer player row (0 none), crystal x, y, z (FLOAT-LONG): 44 part 9 section 1.1: the nearest player within 64 when no player did it; 10 damage to the head when it was the
*> remembered crystal; a circling dragon (HOLDING_PATTERN) strafes the player. Gap: the 64 block targeting does not need line of sight.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-RANGE               FLOAT-LONG VALUE 64.
 01 WS-HEAD                BINARY-LONG VALUE 1.
 01 WS-TEN                 FLOAT-LONG VALUE 10.
 01 WS-CAUSE               BINARY-LONG VALUE 9.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-OK                  BINARY-LONG.
 01 WS-PHASE               BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-ID                   BINARY-LONG.
 01 L-PLAYER               BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-ID L-PLAYER L-X L-Y L-Z.
     CALL "DRAGON-ROW" USING WS-ROW
     IF WS-ROW = 0
         GOBACK
     END-IF
     MOVE L-PLAYER TO WS-P
     IF WS-P = 0
         CALL "DRAGON-PLAYER-NEAR" USING WS-ROW L-X L-Y L-Z WS-RANGE WS-P
     END-IF
     IF DG-CRYSTAL = L-ID
         CALL "DRAGON-HURT-PART" USING WS-ROW WS-HEAD WS-TEN WS-CAUSE WS-NONE WS-OK
         MOVE 0 TO DG-CRYSTAL
     END-IF
     IF DG-PHASE = 0 AND WS-P > 0
         CALL "DRAGON-SET-PHASE" USING WS-ROW WS-PHASE
         CALL "DRAGON-STRAFE-SET" USING WS-ROW WS-P
     END-IF
     GOBACK.
 END PROGRAM DRAGON-CRYSTAL-DESTROYED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-CONTACT.
*> USING row: wing and head contact (21 section 6.4) when the dragon was not hurt in the last 10 ticks: living entities in a wing box (4 x 2 inflated by 4, 2, 4 and moved down 2) are pushed (4.0 away from the
*> body, 0.2 up) and, flying, hurt 5; those in the head or neck box inflated by 1 take 10 (mob attack). Gaps: a player is not pushed (no player knockback entry point), no last-hurt-by-mob stamp, teams.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY RULES.
 COPY DRAGSTATE.
 01 WS-TARGET              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-PART                BINARY-LONG.
 01 WS-W                   FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-HW                  FLOAT-LONG.
 01 WS-EX                  FLOAT-LONG.
 01 WS-EY                  FLOAT-LONG.
 01 WS-EZ                  FLOAT-LONG.
 01 WS-EH                  FLOAT-LONG.
 01 WS-EW                  FLOAT-LONG.
 01 WS-Y0                  FLOAT-LONG.
 01 WS-Y1                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-IN                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG VALUE CAUSE-MOB.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-NONE2               BINARY-LONG VALUE 0.
 01 WS-RESULT              BINARY-LONG.
 01 WS-MILLI               BINARY-LONG.
 01 WS-POINTS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF DG-TICK - DG-HURT-T < 10
         GOBACK
     END-IF
     CALL "DRAGON-PARTS" USING L-ROW
*>   Players, then standard mobs; WS-TARGET 1 is a player (index WS-PLAYER), 2 a mob (row WS-E).
     PERFORM VARYING WS-TARGET FROM 1 BY 1 UNTIL WS-TARGET > 2
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > FUNCTION MAX(CORE-MAX-PLAYERS, EN-COUNT)
             MOVE 0 TO WS-IN
             IF WS-TARGET = 1 AND WS-E <= CORE-MAX-PLAYERS
                 IF PL-USED(WS-E) = 1 AND PL-ENTITY-ROW(WS-E) > 0 AND PL-STATE(WS-E) = PS-ALIVE AND PL-DIM(WS-E) = EN-DIM(L-ROW)
                         AND PL-MODE(WS-E) < 3
                     MOVE PL-X(WS-E) TO WS-EX
                     MOVE PL-Y(WS-E) TO WS-EY
                     MOVE PL-Z(WS-E) TO WS-EZ
                     MOVE 1.8 TO WS-EH
                     MOVE 0.3 TO WS-EW
                     MOVE 1 TO WS-IN
                 END-IF
             END-IF
             IF WS-TARGET = 2 AND WS-E <= EN-COUNT
                 IF EN-USED(WS-E) = 1 AND WS-E NOT = L-ROW AND EN-DIM(WS-E) = EN-DIM(L-ROW) AND EN-HEALTH(WS-E) > 0
                     CALL "STDMOB-INDEX" USING EN-TYPE(WS-E) WS-M
                     IF WS-M > 0
                         MOVE EN-X(WS-E) TO WS-EX
                         MOVE EN-Y(WS-E) TO WS-EY
                         MOVE EN-Z(WS-E) TO WS-EZ
                         COMPUTE WS-EH = ET-HEIGHT-MILLI(EN-TYPE(WS-E) + 1) / 1000
                         COMPUTE WS-EW = ET-WIDTH-MILLI(EN-TYPE(WS-E) + 1) / 2000
                         MOVE 1 TO WS-IN
                     END-IF
                 END-IF
             END-IF
             IF WS-IN = 1
                 PERFORM VARYING WS-PART FROM 1 BY 1 UNTIL WS-PART > 8
                     MOVE 0 TO WS-KIND
                     EVALUATE WS-PART
                         WHEN 1 WHEN 2
                             MOVE 1 TO WS-KIND
                         WHEN 7 WHEN 8
                             MOVE 2 TO WS-KIND
                     END-EVALUATE
                     IF WS-KIND > 0
                         CALL "DRAGON-PART-SIZE" USING WS-PART WS-W WS-H
                         COMPUTE WS-HW = WS-W / 2 + 1 + WS-EW
                         COMPUTE WS-Y0 = DG-PART-Y(WS-PART) - 1
                         COMPUTE WS-Y1 = DG-PART-Y(WS-PART) + WS-H + 1
                         IF WS-KIND = 2
                             COMPUTE WS-HW = WS-W / 2 + 4 + WS-EW
                             COMPUTE WS-Y0 = DG-PART-Y(WS-PART) - 4
                             COMPUTE WS-Y1 = DG-PART-Y(WS-PART) + WS-H
                         END-IF
                         IF FUNCTION ABS(WS-EX - DG-PART-X(WS-PART)) <= WS-HW AND FUNCTION ABS(WS-EZ - DG-PART-Z(WS-PART)) <= WS-HW
                                 AND WS-EY <= WS-Y1 AND WS-EY + WS-EH >= WS-Y0
                             IF WS-KIND = 1
                                 MOVE 10000 TO WS-MILLI
                                 MOVE 10 TO WS-POINTS
                             ELSE
                                 MOVE 5000 TO WS-MILLI
                                 MOVE 5 TO WS-POINTS
                                 COMPUTE WS-DX = WS-EX - DG-PART-X(3)
                                 COMPUTE WS-DZ = WS-EZ - DG-PART-Z(3)
                                 COMPUTE WS-D = FUNCTION MAX(WS-DX * WS-DX + WS-DZ * WS-DZ, 0.1)
                                 IF WS-TARGET = 2
                                     COMPUTE EN-VX(WS-E) = EN-VX(WS-E) + WS-DX / WS-D * 4.0
                                     COMPUTE EN-VZ(WS-E) = EN-VZ(WS-E) + WS-DZ / WS-D * 4.0
                                     COMPUTE EN-VY(WS-E) = EN-VY(WS-E) + 0.2
                                 END-IF
                             END-IF
                             IF WS-KIND = 1 OR (DG-PHASE NOT = 5 AND DG-PHASE NOT = 6 AND DG-PHASE NOT = 7 AND DG-PHASE NOT = 10)
                                 IF WS-TARGET = 1
                                     CALL "HEALTH-HURT" USING WS-E WS-MILLI WS-CAUSE WS-NONE WS-NONE2 WS-RESULT
                                 ELSE
                                     MOVE 0 TO EN-HURT(WS-E)
                                     CALL "HEALTH-MOB-DAMAGE" USING WS-E WS-POINTS WS-CAUSE WS-NONE
                                 END-IF
                             END-IF
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM DRAGON-CONTACT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-DEATH.
*> USING row: tickDeath (21 section 6.4.4): the dragon rises 0.1 a tick, the death event at tick 1, XP orbs (floor(B x 0.08) on every fifth tick above 150, floor(B x 0.2) at 200 with mob_drops on; B 500, or
*> 12000 for the first kill of the saved fight) and at tick 200 the fight is told and the dragon removed.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 COPY ENDFIGHT.
 01 WS-RULE-NAME           PIC X(40) VALUE "mob_drops".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-ACTION              BINARY-LONG VALUE 3.
 01 WS-B                   BINARY-LONG VALUE 500.
 01 WS-XP                  BINARY-LONG.
 01 WS-EVENT               BINARY-LONG VALUE 1028.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     ADD 1 TO DG-DEATH-T
     IF DG-FIGHT = 1
         CALL "END-FIGHT-IO" USING WS-ACTION END-FIGHT
         IF EF-PREVIOUS = 0
             MOVE 12000 TO WS-B
         END-IF
     END-IF
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     MOVE EN-DIM(L-ROW) TO WS-DIM
     MOVE EN-X(L-ROW) TO WS-X
     MOVE EN-Y(L-ROW) TO WS-Y
     MOVE EN-Z(L-ROW) TO WS-Z
     IF DG-DEATH-T = 1
         COMPUTE WS-CX = FUNCTION INTEGER(WS-X)
         COMPUTE WS-CY = FUNCTION INTEGER(WS-Y)
         COMPUTE WS-CZ = FUNCTION INTEGER(WS-Z)
         CALL "END-GLOBAL-EVENT" USING WS-EVENT WS-CX WS-CY WS-CZ
     END-IF
     IF DG-DEATH-T > 150 AND FUNCTION MOD(DG-DEATH-T, 5) = 0 AND WS-RULE NOT = 0
         COMPUTE WS-F = WS-B * 0.08
         COMPUTE WS-XP = FUNCTION INTEGER(WS-F)
         CALL "XP-AWARD" USING WS-DIM WS-X WS-Y WS-Z WS-XP
     END-IF
     COMPUTE EN-Y(L-ROW) = EN-Y(L-ROW) + 0.1
     IF DG-DEATH-T >= 200
         IF WS-RULE NOT = 0
             COMPUTE WS-F = WS-B * 0.2
             COMPUTE WS-XP = FUNCTION INTEGER(WS-F)
             CALL "XP-AWARD" USING WS-DIM WS-X WS-Y WS-Z WS-XP
         END-IF
         IF DG-FIGHT = 1
             CALL "FIGHT-KILLED" USING WS-DIM
         END-IF
         MOVE 0 TO DG-ENT
         CALL "PJ-DROP" USING L-ROW
     ELSE
         CALL "THROWN-SYNC" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM DRAGON-DEATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DRAGON-STEP.
*> USING row: one server tick of the dragon.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DRAGSTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF DG-ENT = 0 OR EN-ID(L-ROW) NOT = DG-ENT
         GOBACK
     END-IF
     ADD 1 TO DG-TICK
     IF DG-HP <= 0
         MOVE 0 TO EN-HEALTH(L-ROW)
         CALL "STDMOB-HP-SYNC" USING L-ROW
         CALL "DRAGON-DEATH" USING L-ROW
         GOBACK
     END-IF
     CALL "DRAGON-HEAL" USING L-ROW
     CALL "DRAGON-PHASE-TICK" USING L-ROW
     CALL "DRAGON-MOVE" USING L-ROW
     CALL "DRAGON-HIST-PUSH" USING L-ROW
     CALL "DRAGON-PARTS" USING L-ROW
     CALL "DRAGON-WALLS" USING L-ROW DG-WALL
     CALL "DRAGON-CONTACT" USING L-ROW
     CALL "THROWN-SYNC" USING L-ROW
     GOBACK.
 END PROGRAM DRAGON-STEP.
