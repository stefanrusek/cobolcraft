*> Illagers of document 20 section 13 (002-lane-p49b): the pillager's crossbow goal (13.2).
*> Entry points:
*>   STDMOB-CROSSBOW USING tracker row, table row of a crossbow mob (SM-RANGED 2), stop out: RangedCrossbowAttackGoal (speed 1.0, radius 8.0). seeTime (EN-SWELL) as the bow goal: it
*>     grows by 1 a tick with a line of sight and falls by 1 without (a change of sight resets it first). The mob must approach when (the squared distance is above 64 or seeTime is
*>     below 5) and attackDelay (EN-SHOOT-TIME in state 2) is 0; stop 1 when it need not approach (it stands). States (EN-DRAW): 0 UNCHARGED: when it need not approach it starts
*>     charging (state 1, EN-SHOOT-TIME the use ticks, 0); 1 CHARGING: the use ticks grow by 1 a tick and at 25 it is CHARGED (state 2, attackDelay 20 + nextInt(20)); 2 CHARGED:
*>     attackDelay falls by 1 and at 0 it is READY_TO_ATTACK (state 3); 3 READY: with a line of sight to the target it shoots one arrow (speed 1.6, each component varied by
*>     triangle(0, 0.0172275 x (14 - 4 x difficulty)), aimed as the bow goal aims) and is UNCHARGED. Without a target the goal resets.
*>   Not here: the charging metadata 17, the path update delay (1 to 2 seconds) and half speed while charged (movement is the generic chase), Quick Charge, the crossbow's
*>     charged projectile item, firework crossbow shots, the arrow's Piercing, the five-slot inventory and loot pickup, the captain's ominous bottle.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-CROSSBOW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-P                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-AX                  FLOAT-LONG.
 01 WS-AY                  FLOAT-LONG.
 01 WS-AZ                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-INACC               FLOAT-LONG.
 01 WS-SALT                BINARY-LONG VALUE 13.
 01 WS-BOUND               BINARY-LONG VALUE 1000.
 01 WS-B20                 BINARY-LONG VALUE 20.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-SEES                BINARY-LONG.
 01 WS-APPROACH            BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-OWNER               BINARY-LONG.
 01 WS-ARROW               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 01 L-STOP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M L-STOP.
     MOVE 0 TO L-STOP
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P = 0
         MOVE 0 TO EN-SWELL(L-ROW) EN-DRAW(L-ROW) EN-SHOOT-TIME(L-ROW)
         GOBACK
     END-IF
     COMPUTE WS-DX = PL-X(WS-P) - EN-X(L-ROW)
     COMPUTE WS-DY = PL-Y(WS-P) - EN-Y(L-ROW)
     COMPUTE WS-DZ = PL-Z(WS-P) - EN-Z(L-ROW)
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     MOVE EN-X(L-ROW) TO WS-AX
     COMPUTE WS-AY = EN-Y(L-ROW) + 1.74
     MOVE EN-Z(L-ROW) TO WS-AZ
     COMPUTE WS-TY = PL-Y(WS-P) + 1.62
     CALL "MOB-SEES" USING EN-DIM(L-ROW) WS-AX WS-AY WS-AZ PL-X(WS-P) WS-TY PL-Z(WS-P) WS-SEES
     IF (WS-SEES = 1 AND EN-SWELL(L-ROW) <= 0) OR (WS-SEES = 0 AND EN-SWELL(L-ROW) > 0)
         MOVE 0 TO EN-SWELL(L-ROW)
     END-IF
     IF WS-SEES = 1
         ADD 1 TO EN-SWELL(L-ROW)
     ELSE
         SUBTRACT 1 FROM EN-SWELL(L-ROW)
     END-IF
     MOVE 0 TO WS-APPROACH
     IF (WS-D2 > 64 OR EN-SWELL(L-ROW) < 5) AND NOT (EN-DRAW(L-ROW) = 2 AND EN-SHOOT-TIME(L-ROW) > 0)
         MOVE 1 TO WS-APPROACH
     END-IF
     IF WS-APPROACH = 0
         MOVE 1 TO L-STOP
     END-IF
     EVALUATE EN-DRAW(L-ROW)
         WHEN 0
             IF WS-APPROACH = 0
                 MOVE 1 TO EN-DRAW(L-ROW)
                 MOVE 0 TO EN-SHOOT-TIME(L-ROW)
             END-IF
         WHEN 1
             ADD 1 TO EN-SHOOT-TIME(L-ROW)
             IF EN-SHOOT-TIME(L-ROW) >= 25
                 CALL "XP-RANDOM" USING WS-SALT WS-B20 WS-R1
                 COMPUTE EN-SHOOT-TIME(L-ROW) = 20 + WS-R1
                 MOVE 2 TO EN-DRAW(L-ROW)
             END-IF
         WHEN 2
             SUBTRACT 1 FROM EN-SHOOT-TIME(L-ROW)
             IF EN-SHOOT-TIME(L-ROW) <= 0
                 MOVE 3 TO EN-DRAW(L-ROW)
             END-IF
         WHEN OTHER
             IF WS-SEES = 1
                 MOVE EN-DIM(L-ROW) TO WS-DIM
                 MOVE EN-ID(L-ROW) TO WS-OWNER
                 COMPUTE WS-AY = EN-Y(L-ROW) + 1.64
                 COMPUTE WS-DY = PL-Y(WS-P) + 0.6 - WS-AY
                 COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
                 COMPUTE WS-DY = WS-DY + WS-H * 0.2
                 COMPUTE WS-LEN = FUNCTION SQRT(WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ)
                 COMPUTE WS-INACC = 0.0172275 * (14 - 4 * BW-DIFFICULTY)
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
                 COMPUTE WS-VX = (WS-DX / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
                 COMPUTE WS-VY = (WS-DY / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R1
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-R2
                 COMPUTE WS-VZ = (WS-DZ / WS-LEN + (WS-R1 - WS-R2) / 1000 * WS-INACC) * 1.6
                 MOVE 2000 TO WS-BASE
                 CALL "ARROW-SPAWN" USING WS-DIM WS-AX WS-AY WS-AZ WS-VX WS-VY WS-VZ WS-BASE WS-OWNER WS-ARROW
                 MOVE 0 TO EN-DRAW(L-ROW) EN-SHOOT-TIME(L-ROW)
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM STDMOB-CROSSBOW.
