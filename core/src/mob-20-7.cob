*> Spiders (002-lane-mobsfull-h11; docs/protocol/20 section 7, 18 section 5 LeapAtTargetGoal).
*>
*> Entry points:
*>   STDMOB-LEAP USING tracker row, table row, roll (0 to 4), leapt out: a spider or cave spider with a target, on the ground, 2 to 4 blocks away (squared distance
*>     above 4 and below 16) leaps when the roll is 0 (one evaluation in five): the horizontal offset to the target, when its squared length exceeds 1.0E-7,
*>     normalised x 0.4 + 0.2 x the current velocity (else the raw offset), and the vertical speed 0.4 (EN-VX, EN-VY, EN-VZ). leapt out 1 when it leapt.
*>   STDMOB-SPIDER-FX USING xoro state, tracker row, special multiplier (thousandths): finalizeSpawn of a spider: on Hard, with probability 0.1 x the multiplier,
*>     one effect with no expiry (-1): nextInt(5) 0 or 1 Speed, 2 Strength, 3 Regeneration, 4 Invisibility.
*>   STDMOB-FX-TICK USING tracker row, table row: the effects of a mob (EN-FX-*) count down by 1 a tick (-1 never ends); Regeneration heals 1 health, up to the
*>     maximum, when the world time is a multiple of 50 (regeneration level I acts every 50 ticks, 17 section 4.9).
*>   Open: the jockey skeleton (a rider cannot be seated), avoiding armadillos, the climbing flag (metadata 16), the immunity to Poison and cobwebs.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-LEAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-LEAPT                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-ROLL L-LEAPT.
     MOVE 0 TO L-LEAPT
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF (SM-KEY(L-M) NOT = "spider" AND SM-KEY(L-M) NOT = "cave_spider") OR WS-P = 0 OR L-ROLL NOT = 0
             OR EN-ON-GROUND(L-ROW) NOT = 1
         GOBACK
     END-IF
     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     IF WS-D2 <= 4 OR WS-D2 >= 16
         GOBACK
     END-IF
     COMPUTE WS-H2 = WS-DX * WS-DX + WS-DZ * WS-DZ
     MOVE WS-DX TO WS-VX
     MOVE WS-DZ TO WS-VZ
     IF WS-H2 > 0.0000001
         COMPUTE WS-H = FUNCTION SQRT(WS-H2)
         COMPUTE WS-VX = WS-DX / WS-H * 0.4 + EN-VX(L-ROW) * 0.2
         COMPUTE WS-VZ = WS-DZ / WS-H * 0.4 + EN-VZ(L-ROW) * 0.2
     END-IF
     MOVE WS-VX TO EN-VX(L-ROW)
     MOVE WS-VZ TO EN-VZ(L-ROW)
     MOVE 0.4 TO EN-VY(L-ROW)
     MOVE 1 TO L-LEAPT
     GOBACK.
 END PROGRAM STDMOB-LEAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-SPIDER-FX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 01 WS-D                   FLOAT-LONG.
 01 WS-P                   FLOAT-LONG.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-PICK                BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-ROW                  BINARY-LONG.
 01 L-SPECIAL              BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-ROW L-SPECIAL.
     IF BW-DIFFICULTY NOT = 3
         GOBACK
     END-IF
     CALL "XORO-NEXT-DOUBLE" USING L-STATE WS-D
     COMPUTE WS-P = 0.1 * L-SPECIAL / 1000
     IF WS-D < WS-P
         CALL "XORO-NEXT-INT" USING L-STATE WS-FIVE WS-PICK
         EVALUATE WS-PICK
             WHEN 0
             WHEN 1
                 MOVE -1 TO EN-FX-SPEED(L-ROW)
             WHEN 2
                 MOVE -1 TO EN-FX-STRENGTH(L-ROW)
             WHEN 3
                 MOVE -1 TO EN-FX-REGEN(L-ROW)
             WHEN OTHER
                 MOVE -1 TO EN-FX-INVIS(L-ROW)
         END-EVALUATE
     END-IF
     GOBACK.
 END PROGRAM STDMOB-SPIDER-FX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-FX-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     IF EN-FX-REGEN(L-ROW) NOT = 0 AND FUNCTION MOD(CW-TIME, 50) = 0 AND EN-HEALTH(L-ROW) < SM-HEALTH(L-M)
         ADD 1 TO EN-HEALTH(L-ROW)
     END-IF
     IF EN-FX-SPEED(L-ROW) > 0
         SUBTRACT 1 FROM EN-FX-SPEED(L-ROW)
     END-IF
     IF EN-FX-STRENGTH(L-ROW) > 0
         SUBTRACT 1 FROM EN-FX-STRENGTH(L-ROW)
     END-IF
     IF EN-FX-REGEN(L-ROW) > 0
         SUBTRACT 1 FROM EN-FX-REGEN(L-ROW)
     END-IF
     IF EN-FX-INVIS(L-ROW) > 0
         SUBTRACT 1 FROM EN-FX-INVIS(L-ROW)
     END-IF
     IF EN-FX-FIRE(L-ROW) > 0
         SUBTRACT 1 FROM EN-FX-FIRE(L-ROW)
     END-IF
     IF EN-FX-WATER(L-ROW) > 0
         SUBTRACT 1 FROM EN-FX-WATER(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STDMOB-FX-TICK.
