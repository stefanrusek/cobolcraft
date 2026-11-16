*> Goat ram (002-lane-mobsa2; docs/protocol/44-residual-mob-questions-4-land-animals.md section 9; 19 section 10).
*> - Preparation (PrepareRamNearestTarget): a target 4 to 7 blocks away (squared distance 16 to 49) and no ram cooldown start 20 ticks of standing still facing it (EN-RAM-STATE 1); a target that leaves
*>   that range cancels it and sets the minimum cooldown 600 (100 screaming; 54 section 7.1). After the 20 ticks the goat rams (state 2): the direction is the normalised horizontal vector to the target, the ram point is the target's place at that moment.
*> - The charge walks at 3.0 x the goat's speed (0.2): 0.6 a tick. A target within 0.75 blocks horizontally (the boxes of a goat 0.9 and a player 0.6 overlap) is hit; the ram then ends. It also ends within 0.25 of
*>   the ram point and after 200 ticks (the time-out). The cooldown after a ram is U(600, 6000), U(100, 300) for a screaming goat; it counts down by 1 a tick.
*> - Knockback of a hit: S = clamp(speed x 1.65, 0.2, 3.0) (no Speed or Slowness effect), x 0.5 when a shield blocked, x the force 2.5 (adult) or 1.0 (baby).
*> Open items: the horn-break block test and dropping the horn (the content of the drop is a random instrument: no instrument data), the knockback packet to the player, target selection by mobs
*>   (players only), the long jump.
*>
*> Entry points:
*>   M44-RAM-KNOCKBACK USING speed, baby, blocked, strength out
*>   M44-RAM-COOLDOWN USING screaming, draw (a non-negative integer), ticks out
*>   M44-RAM-TICK USING row, dx, dz (the target relative to the goat), cooldown draw, hx out, hz out, hit out

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-RAM-KNOCKBACK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-S                   FLOAT-LONG.
 01 WS-FORCE               FLOAT-LONG.
 LINKAGE SECTION.
 01 L-SPEED                FLOAT-LONG.
 01 L-BABY                 BINARY-LONG.
 01 L-BLOCKED              BINARY-LONG.
 01 L-STRENGTH             FLOAT-LONG.
 PROCEDURE DIVISION USING L-SPEED L-BABY L-BLOCKED L-STRENGTH.
     COMPUTE WS-S = L-SPEED * 1.65
     IF WS-S < 0.2
         MOVE 0.2 TO WS-S
     END-IF
     IF WS-S > 3.0
         MOVE 3.0 TO WS-S
     END-IF
     MOVE 2.5 TO WS-FORCE
     IF L-BABY = 1
         MOVE 1.0 TO WS-FORCE
     END-IF
     COMPUTE L-STRENGTH = WS-S * WS-FORCE
     IF L-BLOCKED = 1
         COMPUTE L-STRENGTH = L-STRENGTH * 0.5
     END-IF
     GOBACK.
 END PROGRAM M44-RAM-KNOCKBACK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-RAM-COOLDOWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 LINKAGE SECTION.
 01 L-SCREAMING            BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-TICKS                FLOAT-LONG.
 PROCEDURE DIVISION USING L-SCREAMING L-DRAW L-TICKS.
     IF L-SCREAMING = 1
         COMPUTE L-TICKS = 100 + FUNCTION MOD(L-DRAW, 201)
     ELSE
         COMPUTE L-TICKS = 600 + FUNCTION MOD(L-DRAW, 5401)
     END-IF
     GOBACK.
 END PROGRAM M44-RAM-COOLDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-RAM-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-SCREAM              BINARY-LONG.
 01 WS-TICKS               FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-END                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-DX                   FLOAT-LONG.
 01 L-DZ                   FLOAT-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-HIT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-DX L-DZ L-DRAW L-HX L-HZ L-HIT.
     MOVE 0 TO L-HX L-HZ L-HIT WS-END
     COMPUTE WS-D2 = L-DX * L-DX + L-DZ * L-DZ
     EVALUATE EN-RAM-STATE(L-ROW)
         WHEN 0
             IF EN-RAM-CD(L-ROW) > 0
                 SUBTRACT 1 FROM EN-RAM-CD(L-ROW)
             ELSE
                 IF WS-D2 >= 16 AND WS-D2 <= 49
                     MOVE 1 TO EN-RAM-STATE(L-ROW)
                     MOVE 0 TO EN-RAM-T(L-ROW)
                 END-IF
             END-IF
         WHEN 1
             IF WS-D2 < 16 OR WS-D2 > 49
                 MOVE 0 TO EN-RAM-STATE(L-ROW)
                 MOVE FUNCTION MOD(EN-WOOL(L-ROW), 2) TO WS-SCREAM
                 COMPUTE EN-RAM-CD(L-ROW) = 600 - 500 * WS-SCREAM
             ELSE
                 ADD 1 TO EN-RAM-T(L-ROW)
                 IF EN-RAM-T(L-ROW) >= 20
                     MOVE 2 TO EN-RAM-STATE(L-ROW)
                     MOVE 0 TO EN-RAM-T(L-ROW)
                     COMPUTE WS-H = FUNCTION SQRT(WS-D2)
                     COMPUTE EN-RAM-DX(L-ROW) = L-DX / WS-H
                     COMPUTE EN-RAM-DZ(L-ROW) = L-DZ / WS-H
                     COMPUTE EN-RAM-PX(L-ROW) = EN-X(L-ROW) + L-DX
                     COMPUTE EN-RAM-PZ(L-ROW) = EN-Z(L-ROW) + L-DZ
                 END-IF
             END-IF
         WHEN OTHER
             ADD 1 TO EN-RAM-T(L-ROW)
             COMPUTE WS-DX = EN-RAM-PX(L-ROW) - EN-X(L-ROW)
             COMPUTE WS-DZ = EN-RAM-PZ(L-ROW) - EN-Z(L-ROW)
             EVALUATE TRUE
                 WHEN WS-D2 < 0.5625
                     MOVE 1 TO L-HIT WS-END
                 WHEN WS-DX * WS-DX + WS-DZ * WS-DZ < 0.0625 OR EN-RAM-T(L-ROW) > 200
                     MOVE 1 TO WS-END
                 WHEN OTHER
                     COMPUTE L-HX = EN-RAM-DX(L-ROW) * 0.6
                     COMPUTE L-HZ = EN-RAM-DZ(L-ROW) * 0.6
             END-EVALUATE
             IF WS-END = 1
                 MOVE 0 TO EN-RAM-STATE(L-ROW) EN-RAM-T(L-ROW)
                 MOVE FUNCTION MOD(EN-WOOL(L-ROW), 2) TO WS-SCREAM
                 CALL "M44-RAM-COOLDOWN" USING WS-SCREAM L-DRAW WS-TICKS
                 MOVE WS-TICKS TO EN-RAM-CD(L-ROW)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM M44-RAM-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. M44-GOAT-TICK.
*> USING row, hx out, hz out, walk out: the ram against the nearest survival player within 8 blocks (the ram goal's range is 7). walk 2: the goat stands still (preparing); walk 1: it charges
*> with the heading hx, hz. A hit hurts the player by the goat's attack damage, 2 (adult) or 1 (baby).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-BEST-D2             FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-HIT                 BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 3.
 01 WS-ARGS.
    05 WS-ARG              BINARY-DOUBLE OCCURS 16 TIMES.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-BROKE               BINARY-LONG.
 01 WS-SCREAM              BINARY-LONG.
 01 WS-TICKS               FLOAT-LONG.
 01 WS-SPEED               FLOAT-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-NOBLOCK             BINARY-LONG VALUE 0.
 01 WS-STRENGTH            FLOAT-LONG.
 COPY PROTO.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-HX                   FLOAT-LONG.
 01 L-HZ                   FLOAT-LONG.
 01 L-WALK                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-HX L-HZ L-WALK.
     MOVE 0 TO L-HX L-HZ L-WALK WS-BEST
     MOVE EN-RAM-STATE(L-ROW) TO WS-BEFORE
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW) AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
             COMPUTE WS-D2 = (PL-X(WS-P) - EN-X(L-ROW)) ** 2 + (PL-Z(WS-P) - EN-Z(L-ROW)) ** 2
             IF WS-D2 <= 64 AND (WS-BEST = 0 OR WS-D2 < WS-BEST-D2)
                 MOVE WS-P TO WS-BEST
                 MOVE WS-D2 TO WS-BEST-D2
             END-IF
         END-IF
     END-PERFORM
*>   With no player the target is far away (a target at 0 would count as a hit).
     MOVE 1000 TO WS-DX WS-DZ
     IF WS-BEST > 0
         COMPUTE WS-DX = PL-X(WS-BEST) - EN-X(L-ROW)
         COMPUTE WS-DZ = PL-Z(WS-BEST) - EN-Z(L-ROW)
     END-IF
     MOVE EN-ID(L-ROW) TO WS-ARG(1)
     MOVE CW-TIME TO WS-ARG(2)
     MOVE 68 TO WS-ARG(3)
     CALL "RNG-HASH" USING WS-COUNT WS-ARGS WS-R
     COMPUTE WS-DRAW = FUNCTION MOD(WS-R, 6001)
     IF WS-BEST = 0 AND EN-RAM-STATE(L-ROW) = 0
         IF EN-RAM-CD(L-ROW) > 0
             SUBTRACT 1 FROM EN-RAM-CD(L-ROW)
         END-IF
         GOBACK
     END-IF
     CALL "M44-RAM-TICK" USING L-ROW WS-DX WS-DZ WS-DRAW L-HX L-HZ WS-HIT
*>   Entity Event 58 lowers the head when the run-up starts, 59 raises it when the ram ends (54 sections 7.1 to 7.3).
     MOVE 0 TO WS-EVENT
     IF WS-BEFORE = 0 AND EN-RAM-STATE(L-ROW) = 1
         MOVE 58 TO WS-EVENT
     END-IF
     IF WS-BEFORE > 0 AND EN-RAM-STATE(L-ROW) = 0
         MOVE 59 TO WS-EVENT
     END-IF
     IF WS-EVENT > 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
         CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
         CALL "PB-FREE" USING PB-BUFFER
     END-IF
*>   The charge without a hit: a horn-breaking block ahead breaks a horn and ends the ram (54 section 7.2).
     IF EN-RAM-STATE(L-ROW) = 2 AND WS-HIT = 0 AND (L-HX NOT = 0 OR L-HZ NOT = 0)
         CALL "M44-GOAT-HORN-TEST" USING L-ROW L-HX L-HZ WS-BROKE
         IF WS-BROKE = 1
             MOVE 0 TO EN-RAM-STATE(L-ROW) EN-RAM-T(L-ROW) L-HX L-HZ
             MOVE FUNCTION MOD(EN-WOOL(L-ROW), 2) TO WS-SCREAM
             CALL "M44-RAM-COOLDOWN" USING WS-SCREAM WS-DRAW WS-TICKS
             MOVE WS-TICKS TO EN-RAM-CD(L-ROW)
             MOVE 59 TO WS-EVENT
             CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
             CALL "ENTITY-EVENT-BUILD" USING EN-ID(L-ROW) WS-EVENT PB-BUFFER
             CALL "HEALTH-VIEWERS-SEND" USING L-ROW PB-BUFFER
             CALL "PB-FREE" USING PB-BUFFER
         END-IF
     END-IF
     IF EN-RAM-STATE(L-ROW) = 1
         MOVE 2 TO L-WALK
     END-IF
     IF EN-RAM-STATE(L-ROW) = 2 AND (L-HX NOT = 0 OR L-HZ NOT = 0)
         MOVE 1 TO L-WALK
     END-IF
     IF WS-HIT = 1
         MOVE 2 TO WS-DAMAGE
         IF EN-VARIANT(L-ROW) = 1
             MOVE 1 TO WS-DAMAGE
         END-IF
         CALL "HEALTH-MOB-HIT" USING WS-BEST WS-DAMAGE L-ROW
*>       Knockback of the player along the charge (54 section 7.2): speed 0.2 x 1.65, force 2.5 (1.0 baby), no shield block.
         MOVE 0.2 TO WS-SPEED
         MOVE EN-VARIANT(L-ROW) TO WS-BABY
         CALL "M44-RAM-KNOCKBACK" USING WS-SPEED WS-BABY WS-NOBLOCK WS-STRENGTH
         CALL "M44-RAM-KNOCK" USING WS-BEST L-ROW WS-STRENGTH
     END-IF
     GOBACK.
 END PROGRAM M44-GOAT-TICK.
