*> Phantom (002-lane-mobsfull-h11; docs/protocol/20 section 12, 20.5, 44-5 section 10C item 2). The rows of the phantom are STDMOBS.cpy row 36; EN-VARIANT is its size,
*> EN-PH-* its flight state (core/copy/CORESTATE.cpy).
*>
*> Entry points:
*>   STDMOB-INSOMNIA USING effective difficulty (thousandths), float draw (nextFloat x 3 in thousandths), rest ticks, rest draw (nextInt(rest)), ok out: 1 when the
*>     effective difficulty exceeds the draw and the rest draw is at least 72000 (and below the rest, which is at least 1).
*>   STDMOB-PHANTOM-COUNTDOWN USING counter (io), roll (nextInt(60)), due out: the spawner's nextTick: minus 1; at 0 or below it is due and gains (60 + roll) x 20.
*>   STDMOB-REST-TICK: time_since_rest (PL-REST) of every player grows by 1 a tick unless it sleeps.
*>   STDMOB-PHANTOM-ROUND: one pass of PhantomSpawner over the players: the spawn_phantoms rule, a sky darkness of 5 or more, and per non-spectator player standing at
*>     sea level (63) or higher under open sky (sky light 15 at its feet): insomnia, then a cell 20 + nextInt(15) up, -10 + nextInt(21) east and south of its block that
*>     is air, and 1 + nextInt(difficulty + 1) phantoms there, finalized.
*>   STDMOB-PHANTOM-SPAWNER: the spawner's tick (countdown, then a round); called by STDMOB-SPAWN-TICK.
*>   STDMOB-PHANTOM-SELECT USING row: select the next circle point. STDMOB-PHANTOM-ANCHOR USING row, target block x, y, z, roll (nextInt(20)): the anchor above a target.
*>   STDMOB-PHANTOM-CIRCLE USING row, roll 1 (0 to 349), roll 2 (0 to 249), roll 3 (0 to 449), float roll (0 to 999), angle roll (0 to 999): the per-tick changes of the
*>     circle goal (a to d of 20 section 12; the block tests e and f are open).
*>   STDMOB-PHANTOM-MOVE USING row: the move control (steps 2 to 8; the horizontal-collision turn of step 1 is open).
*>   STDMOB-PHANTOM-TICK USING row, table row: one tick of a phantom: daylight burning, the target (scan every 60 ticks, highest player within 16, 64, 16), the attack
*>     strategy (CIRCLE timer 10, SWOOP with a timer of (8 + nextInt(4)) x 20 and an anchor above the target), the circle goal, the swoop hit, the move control and the move.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-INSOMNIA.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-EFF                  BINARY-LONG.
 01 L-DRAW3                BINARY-LONG.
 01 L-REST                 BINARY-LONG.
 01 L-DRAW                 BINARY-LONG.
 01 L-OK                   BINARY-LONG.
 PROCEDURE DIVISION USING L-EFF L-DRAW3 L-REST L-DRAW L-OK.
     MOVE 0 TO L-OK
     IF L-EFF > L-DRAW3 AND L-DRAW >= 72000 AND L-DRAW < FUNCTION MAX(1, L-REST)
         MOVE 1 TO L-OK
     END-IF
     GOBACK.
 END PROGRAM STDMOB-INSOMNIA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-COUNTDOWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-COUNTER              BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 01 L-DUE                  BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNTER L-ROLL L-DUE.
     MOVE 0 TO L-DUE
     SUBTRACT 1 FROM L-COUNTER
     IF L-COUNTER <= 0
         COMPUTE L-COUNTER = L-COUNTER + (60 + L-ROLL) * 20
         MOVE 1 TO L-DUE
     END-IF
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-COUNTDOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-REST-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY WSIM2.
 01 WS-P                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND W2-SLEEPING(WS-P) = 0
             ADD 1 TO PL-REST(WS-P)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-REST-TICK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-ROUND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY XORO.
 01 WS-RULE-NAME           PIC X(40) VALUE "spawn_phantoms".
 01 WS-RULE                BINARY-DOUBLE.
 01 WS-DARK                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-INHABITED           BINARY-DOUBLE VALUE 0.
 01 WS-MOON                BINARY-LONG VALUE 0.
 01 WS-EFF                 BINARY-LONG.
 01 WS-SALT                BINARY-LONG VALUE 41.
 01 WS-BOUND               BINARY-LONG.
 01 WS-D3                  BINARY-LONG.
 01 WS-REST                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-EAST                BINARY-LONG.
 01 WS-SOUTH               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:phantom".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-NEW                 BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-STATE-XORO.
    05 WS-XORO-PAD         PIC X(1).
 LINKAGE SECTION.
 COPY COREAPI.
 PROCEDURE DIVISION.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     CALL "BR-RULE-GET" USING WS-RULE-NAME WS-RULE
     CALL "STDMOB-DARKEN" USING CW-TIME WS-DARK
     IF WS-RULE = 0 OR WS-DARK < 5 OR BW-DIFFICULTY = 0 OR CS-HOSTILE-MOBS NOT = 1
         GOBACK
     END-IF
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
         IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-MODE(WS-P) NOT = 3
             COMPUTE WS-BX = FUNCTION INTEGER(PL-X(WS-P))
             COMPUTE WS-BY = FUNCTION INTEGER(PL-Y(WS-P))
             COMPUTE WS-BZ = FUNCTION INTEGER(PL-Z(WS-P))
             CALL "STDMOB-LIGHTS" USING PL-DIM(WS-P) WS-BX WS-BY WS-BZ WS-SKY WS-BLOCK
             IF WS-BY >= 63 AND WS-SKY = 15
                 CALL "STDMOB-DIFFICULTY" USING BW-DIFFICULTY CW-TIME WS-INHABITED WS-MOON WS-EFF
                 MOVE 3000 TO WS-BOUND
                 CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-D3
                 COMPUTE WS-REST = FUNCTION MAX(1, PL-REST(WS-P))
                 CALL "XP-RANDOM" USING WS-SALT WS-REST WS-DRAW
                 CALL "STDMOB-INSOMNIA" USING WS-EFF WS-D3 WS-REST WS-DRAW WS-OK
                 IF WS-OK = 1
                     MOVE 15 TO WS-BOUND
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-UP
                     MOVE 21 TO WS-BOUND
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-EAST
                     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-SOUTH
                     COMPUTE WS-UP = WS-BY + 20 + WS-UP
                     COMPUTE WS-EAST = WS-BX - 10 + WS-EAST
                     COMPUTE WS-SOUTH = WS-BZ - 10 + WS-SOUTH
                     CALL "WORLD-GET-BLOCK" USING PL-DIM(WS-P) WS-EAST WS-UP WS-SOUTH WS-STATE
                     IF WS-STATE = 0
                         COMPUTE WS-BOUND = BW-DIFFICULTY + 1
                         CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-COUNT
                         ADD 1 TO WS-COUNT
                         COMPUTE WS-X = WS-EAST + 0.5
                         MOVE WS-UP TO WS-Y
                         COMPUTE WS-Z = WS-SOUTH + 0.5
                         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                             CALL "MOB-SPAWN" USING PL-DIM(WS-P) WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-NEW
                             COMPUTE WS-SEED = CW-TICKS * 31 + EN-ID(WS-NEW)
                             CALL "XORO-SEED" USING WS-SEED XR-STATE
                             CALL "STDMOB-FINALIZE" USING XR-STATE WS-NEW
                         END-PERFORM
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-ROUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-SPAWNER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-COUNTER             BINARY-LONG VALUE 0.
 01 WS-SALT                BINARY-LONG VALUE 43.
 01 WS-BOUND               BINARY-LONG VALUE 60.
 01 WS-ROLL                BINARY-LONG.
 01 WS-DUE                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "XP-RANDOM" USING WS-SALT WS-BOUND WS-ROLL
     CALL "STDMOB-PHANTOM-COUNTDOWN" USING WS-COUNTER WS-ROLL WS-DUE
     IF WS-DUE = 1
         CALL "STDMOB-PHANTOM-ROUND"
     END-IF
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-SPAWNER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-SELECT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     IF EN-PH-SET(L-ROW) = 0
         COMPUTE EN-PH-AX(L-ROW) = FUNCTION INTEGER(EN-X(L-ROW))
         COMPUTE EN-PH-AY(L-ROW) = FUNCTION INTEGER(EN-Y(L-ROW))
         COMPUTE EN-PH-AZ(L-ROW) = FUNCTION INTEGER(EN-Z(L-ROW))
         MOVE 1 TO EN-PH-SET(L-ROW)
     END-IF
     COMPUTE EN-PH-ANGLE(L-ROW) = EN-PH-ANGLE(L-ROW) + EN-PH-CW(L-ROW) * 0.26179938
     COMPUTE EN-PH-TX(L-ROW) = EN-PH-AX(L-ROW) + EN-PH-DIST(L-ROW) * FUNCTION COS(EN-PH-ANGLE(L-ROW))
     COMPUTE EN-PH-TY(L-ROW) = EN-PH-AY(L-ROW) - 4 + EN-PH-HEIGHT(L-ROW)
     COMPUTE EN-PH-TZ(L-ROW) = EN-PH-AZ(L-ROW) + EN-PH-DIST(L-ROW) * FUNCTION SIN(EN-PH-ANGLE(L-ROW))
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-SELECT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-ANCHOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROLL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-X L-Y L-Z L-ROLL.
     IF EN-PH-SET(L-ROW) = 0
         GOBACK
     END-IF
     MOVE L-X TO EN-PH-AX(L-ROW)
     COMPUTE EN-PH-AY(L-ROW) = L-Y + 20 + L-ROLL
     MOVE L-Z TO EN-PH-AZ(L-ROW)
     IF EN-PH-AY(L-ROW) < 63
         MOVE 64 TO EN-PH-AY(L-ROW)
     END-IF
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-ANCHOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-CIRCLE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-R1                   BINARY-LONG.
 01 L-R2                   BINARY-LONG.
 01 L-R3                   BINARY-LONG.
 01 L-RF                   BINARY-LONG.
 01 L-RA                   BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-R1 L-R2 L-R3 L-RF L-RA.
     IF L-R1 = 0
         COMPUTE EN-PH-HEIGHT(L-ROW) = -4 + L-RF / 1000 * 9
     END-IF
     IF L-R2 = 0
         ADD 1 TO EN-PH-DIST(L-ROW)
         IF EN-PH-DIST(L-ROW) > 15
             MOVE 5 TO EN-PH-DIST(L-ROW)
             COMPUTE EN-PH-CW(L-ROW) = 0 - EN-PH-CW(L-ROW)
         END-IF
     END-IF
     IF L-R3 = 0
         COMPUTE EN-PH-ANGLE(L-ROW) = L-RA / 1000 * 2 * FUNCTION PI
         CALL "STDMOB-PHANTOM-SELECT" USING L-ROW
     END-IF
     COMPUTE WS-DX = EN-PH-TX(L-ROW) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-PH-TY(L-ROW) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-PH-TZ(L-ROW) - EN-Z(L-ROW)
     IF WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ < 4
         CALL "STDMOB-PHANTOM-SELECT" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-CIRCLE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-MOVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-D3                  FLOAT-LONG.
 01 WS-F                   FLOAT-LONG.
 01 WS-HEADING             FLOAT-LONG.
 01 WS-CUR                 FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-NEW                 FLOAT-LONG.
 01 WS-OLD                 FLOAT-LONG.
 01 WS-STEP                FLOAT-LONG.
 01 WS-GOAL                FLOAT-LONG.
 01 WS-PITCH               FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-RAD                 FLOAT-LONG VALUE 0.017453292519943295.
 01 WS-DEG                 FLOAT-LONG VALUE 57.29577951308232.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     COMPUTE WS-DX = EN-PH-TX(L-ROW) - EN-X(L-ROW)
     COMPUTE WS-DY = EN-PH-TY(L-ROW) - EN-Y(L-ROW)
     COMPUTE WS-DZ = EN-PH-TZ(L-ROW) - EN-Z(L-ROW)
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     IF WS-H > 0.00001
         COMPUTE WS-F = 1 - FUNCTION ABS(WS-DY * 0.7) / WS-H
         COMPUTE WS-DX = WS-DX * WS-F
         COMPUTE WS-DZ = WS-DZ * WS-F
         COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
         COMPUTE WS-D3 = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ + WS-DY * WS-DY)
*>       The heading of (dx, dz) in degrees, wrapped to -180 up to 180.
         EVALUATE TRUE
             WHEN WS-DX = 0 AND WS-DZ > 0
                 MOVE 90 TO WS-HEADING
             WHEN WS-DX = 0 AND WS-DZ < 0
                 MOVE -90 TO WS-HEADING
             WHEN WS-DX = 0
                 MOVE 0 TO WS-HEADING
             WHEN WS-DX > 0
                 COMPUTE WS-HEADING = FUNCTION ATAN(WS-DZ / WS-DX) * WS-DEG
             WHEN WS-DZ >= 0
                 COMPUTE WS-HEADING = FUNCTION ATAN(WS-DZ / WS-DX) * WS-DEG + 180
             WHEN OTHER
                 COMPUTE WS-HEADING = FUNCTION ATAN(WS-DZ / WS-DX) * WS-DEG - 180
         END-EVALUATE
         MOVE EN-YAW(L-ROW) TO WS-OLD
         COMPUTE WS-CUR = FUNCTION MOD(WS-OLD + 90 + 180, 360) - 180
         COMPUTE WS-DIFF = FUNCTION MOD(WS-HEADING - WS-CUR + 180, 360) - 180
         COMPUTE WS-STEP = FUNCTION MAX(-4, FUNCTION MIN(4, WS-DIFF))
         COMPUTE WS-NEW = WS-CUR + WS-STEP - 90
         MOVE WS-NEW TO EN-YAW(L-ROW)
         IF FUNCTION ABS(WS-NEW - WS-OLD) < 3
             COMPUTE WS-STEP = 0.005 * (1.8 / EN-PH-SPEED(L-ROW))
             MOVE 1.8 TO WS-GOAL
         ELSE
             MOVE 0.025 TO WS-STEP
             MOVE 0.2 TO WS-GOAL
         END-IF
         EVALUATE TRUE
             WHEN EN-PH-SPEED(L-ROW) + WS-STEP < WS-GOAL AND EN-PH-SPEED(L-ROW) < WS-GOAL
                 COMPUTE EN-PH-SPEED(L-ROW) = EN-PH-SPEED(L-ROW) + WS-STEP
             WHEN EN-PH-SPEED(L-ROW) - WS-STEP > WS-GOAL AND EN-PH-SPEED(L-ROW) > WS-GOAL
                 COMPUTE EN-PH-SPEED(L-ROW) = EN-PH-SPEED(L-ROW) - WS-STEP
             WHEN OTHER
                 MOVE WS-GOAL TO EN-PH-SPEED(L-ROW)
         END-EVALUATE
         COMPUTE WS-PITCH = FUNCTION ATAN(WS-DY / WS-H) * WS-DEG
         MOVE WS-PITCH TO EN-PITCH(L-ROW)
         COMPUTE WS-A = (WS-NEW + 90) * WS-RAD
         COMPUTE WS-VX = EN-PH-SPEED(L-ROW) * FUNCTION COS(WS-A) * FUNCTION ABS(WS-DX / WS-D3)
         COMPUTE WS-VZ = EN-PH-SPEED(L-ROW) * FUNCTION SIN(WS-A) * FUNCTION ABS(WS-DZ / WS-D3)
         COMPUTE WS-VY = EN-PH-SPEED(L-ROW) * FUNCTION SIN(WS-PITCH * WS-RAD) * FUNCTION ABS(WS-DY / WS-D3)
         COMPUTE EN-VX(L-ROW) = EN-VX(L-ROW) + (WS-VX - EN-VX(L-ROW)) * 0.2
         COMPUTE EN-VY(L-ROW) = EN-VY(L-ROW) + (WS-VY - EN-VY(L-ROW)) * 0.2
         COMPUTE EN-VZ(L-ROW) = EN-VZ(L-ROW) + (WS-VZ - EN-VZ(L-ROW)) * 0.2
     END-IF
     GOBACK.
 END PROGRAM STDMOB-PHANTOM-MOVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. STDMOB-PHANTOM-TICK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STDMOBS.
 01 WS-SALT                BINARY-LONG VALUE 47.
 01 WS-B20                 BINARY-LONG VALUE 20.
 01 WS-B4                  BINARY-LONG VALUE 4.
 01 WS-B350                BINARY-LONG VALUE 350.
 01 WS-B250                BINARY-LONG VALUE 250.
 01 WS-B450                BINARY-LONG VALUE 450.
 01 WS-B1000               BINARY-LONG VALUE 1000.
 01 WS-R1                  BINARY-LONG.
 01 WS-R2                  BINARY-LONG.
 01 WS-R3                  BINARY-LONG.
 01 WS-RF                  BINARY-LONG.
 01 WS-RA                  BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-TX                  BINARY-LONG.
 01 WS-TY                  BINARY-LONG.
 01 WS-TZ                  BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-GROUND              BINARY-LONG VALUE 0.
 01 WS-SCALE               FLOAT-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-M                    BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-M.
     CALL "STDMOB-BURN" USING L-ROW L-M
     IF EN-HEALTH(L-ROW) = 0
         GOBACK
     END-IF
*>   The target stays while it is a living survival or adventure player of the dimension.
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0
         IF PL-USED(WS-P) NOT = 1 OR PL-ENTITY-ID(WS-P) NOT = EN-TARGET-ID(L-ROW) OR PL-STATE(WS-P) NOT = PS-ALIVE
                 OR PL-DIM(WS-P) NOT = EN-DIM(L-ROW) OR PL-MODE(WS-P) = 1 OR PL-MODE(WS-P) = 3
             MOVE 0 TO EN-TARGET(L-ROW) EN-TARGET-ID(L-ROW) EN-PH-PHASE(L-ROW)
         END-IF
     END-IF
     IF EN-TARGET(L-ROW) = 0
         IF EN-PH-SCAN(L-ROW) > 0
             SUBTRACT 1 FROM EN-PH-SCAN(L-ROW)
         ELSE
             MOVE 60 TO EN-PH-SCAN(L-ROW)
             MOVE 0 TO WS-BEST
             PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > CORE-MAX-PLAYERS
                 IF PL-USED(WS-P) = 1 AND PL-STATE(WS-P) = PS-ALIVE AND PL-DIM(WS-P) = EN-DIM(L-ROW)
                         AND (PL-MODE(WS-P) = 0 OR PL-MODE(WS-P) = 2)
                     COMPUTE WS-DX = FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW))
                     COMPUTE WS-DY = FUNCTION ABS(PL-Y(WS-P) - EN-Y(L-ROW))
                     COMPUTE WS-DZ = FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW))
                     IF WS-DX <= 16 AND WS-DY <= 64 AND WS-DZ <= 16 AND (WS-BEST = 0 OR PL-Y(WS-P) > PL-Y(WS-BEST))
                         MOVE WS-P TO WS-BEST
                     END-IF
                 END-IF
             END-PERFORM
             IF WS-BEST > 0
                 MOVE WS-BEST TO EN-TARGET(L-ROW)
                 MOVE PL-ENTITY-ID(WS-BEST) TO EN-TARGET-ID(L-ROW)
                 MOVE 0 TO EN-PH-PHASE(L-ROW)
                 MOVE 10 TO EN-PH-TIMER(L-ROW)
                 MOVE WS-BEST TO WS-P
                 PERFORM SET-ANCHOR
                 GOBACK
             END-IF
         END-IF
     END-IF
     IF EN-PH-DIST(L-ROW) = 0
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-RF
         COMPUTE EN-PH-DIST(L-ROW) = 5 + WS-RF / 100
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-RF
         COMPUTE EN-PH-HEIGHT(L-ROW) = -4 + WS-RF / 1000 * 9
         CALL "STDMOB-PHANTOM-SELECT" USING L-ROW
     END-IF
     MOVE EN-TARGET(L-ROW) TO WS-P
     IF WS-P > 0 AND EN-PH-PHASE(L-ROW) = 0
         SUBTRACT 1 FROM EN-PH-TIMER(L-ROW)
         IF EN-PH-TIMER(L-ROW) <= 0
             MOVE 1 TO EN-PH-PHASE(L-ROW)
             PERFORM SET-ANCHOR
             CALL "XP-RANDOM" USING WS-SALT WS-B4 WS-ROLL
             COMPUTE EN-PH-TIMER(L-ROW) = (8 + WS-ROLL) * 20
         END-IF
     END-IF
     IF WS-P > 0 AND EN-PH-PHASE(L-ROW) = 1
*>       The sweep: toward the middle of the target; touching its box (the phantom's inflated by 0.2) hurts it.
         MOVE PL-X(WS-P) TO EN-PH-TX(L-ROW)
         COMPUTE EN-PH-TY(L-ROW) = PL-Y(WS-P) + 0.9
         MOVE PL-Z(WS-P) TO EN-PH-TZ(L-ROW)
         COMPUTE WS-DX = FUNCTION ABS(PL-X(WS-P) - EN-X(L-ROW))
         COMPUTE WS-DZ = FUNCTION ABS(PL-Z(WS-P) - EN-Z(L-ROW))
         IF WS-DX < 0.45 + 0.2 + 0.3 AND WS-DZ < 0.45 + 0.2 + 0.3
                 AND EN-Y(L-ROW) + 0.5 + 0.2 > PL-Y(WS-P) AND EN-Y(L-ROW) - 0.2 < PL-Y(WS-P) + 1.8
             CALL "STDMOB-ATTACK-DAMAGE" USING L-ROW L-M WS-DAMAGE
             CALL "HEALTH-MOB-HIT" USING WS-P WS-DAMAGE L-ROW
             MOVE 0 TO EN-PH-PHASE(L-ROW)
         END-IF
     ELSE
         CALL "XP-RANDOM" USING WS-SALT WS-B350 WS-R1
         CALL "XP-RANDOM" USING WS-SALT WS-B250 WS-R2
         CALL "XP-RANDOM" USING WS-SALT WS-B450 WS-R3
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-RF
         CALL "XP-RANDOM" USING WS-SALT WS-B1000 WS-RA
         CALL "STDMOB-PHANTOM-CIRCLE" USING L-ROW WS-R1 WS-R2 WS-R3 WS-RF WS-RA
     END-IF
     CALL "STDMOB-PHANTOM-MOVE" USING L-ROW
     COMPUTE WS-X = EN-X(L-ROW) + EN-VX(L-ROW)
     COMPUTE WS-Y = EN-Y(L-ROW) + EN-VY(L-ROW)
     COMPUTE WS-Z = EN-Z(L-ROW) + EN-VZ(L-ROW)
     MOVE EN-YAW(L-ROW) TO WS-YAW
     MOVE EN-PITCH(L-ROW) TO WS-PITCH
     CALL "ENTITY-MOVE" USING L-ROW WS-X WS-Y WS-Z WS-YAW WS-PITCH WS-GROUND
     GOBACK.
 SET-ANCHOR.
     COMPUTE WS-TX = FUNCTION INTEGER(PL-X(WS-P))
     COMPUTE WS-TY = FUNCTION INTEGER(PL-Y(WS-P))
     COMPUTE WS-TZ = FUNCTION INTEGER(PL-Z(WS-P))
     CALL "XP-RANDOM" USING WS-SALT WS-B20 WS-ROLL
     CALL "STDMOB-PHANTOM-ANCHOR" USING L-ROW WS-TX WS-TY WS-TZ WS-ROLL.
 END PROGRAM STDMOB-PHANTOM-TICK.
