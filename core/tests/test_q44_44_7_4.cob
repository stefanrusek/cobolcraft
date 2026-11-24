*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 4, lane 002-lane-p49j-a): the fish flop (4.1, 13.1: every tick on the ground out of
*> water, velocity + ((nextFloat x 2 - 1) x 0.05, 0.4, ...) with the x draw first; the flag is cleared so the next flop needs a new landing), the dolphin hop (4.2: the
*> draws of x, z; in water or rain the moistness is 2400 again) and the dolphin's dry-out damage cadence (13.2: one hit every 10 ticks, so about 100 ticks of life).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-NAME                PIC X(240).
 01 WS-EXP                 BINARY-LONG.
 01 WS-OBS                 BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-COD                 BINARY-LONG.
 01 WS-DOLPHIN             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-R1                  FLOAT-LONG.
 01 WS-R2                  FLOAT-LONG.
 01 WS-SALT1               BINARY-LONG.
 01 WS-SALT2               BINARY-LONG.
 01 WS-VXB                 FLOAT-LONG.
 01 WS-VZB                 FLOAT-LONG.
 01 WS-VYB                 FLOAT-LONG.
 01 WS-EXPX                FLOAT-LONG.
 01 WS-EXPZ                FLOAT-LONG.
 01 WS-FLOPS               BINARY-LONG.
 01 WS-GOOD                BINARY-LONG.
 01 WS-DROPS               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-GAP                 BINARY-LONG.
 01 WS-HEALTH              BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-MARK                BINARY-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     CALL "AQ-TEST-TANK" USING WS-PLAYER WS-DIM WS-X0 WS-Y0 WS-Z0
     MOVE "N" TO TL-MODE
     MOVE "minecraft:cod" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COD WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:dolphin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DOLPHIN WS-ENTITY-ROW WS-STATUS
*>   4.1 and 13.1: a cod on the stone block outside the tank.
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 3
     COMPUTE WS-Z = WS-Z0 + 2.5
     CALL "MOB-SPAWN" USING WS-DIM WS-COD WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 11 TO WS-SALT1
     MOVE 12 TO WS-SALT2
     MOVE 0 TO WS-FLOPS WS-GOOD WS-MARK
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-FLOPS >= 6
         ADD 1 TO CW-TIME
         MOVE EN-VX(WS-ROW) TO WS-VXB
         MOVE EN-VZ(WS-ROW) TO WS-VZB
         MOVE EN-VY(WS-ROW) TO WS-VYB
         MOVE 0 TO WS-MARK
         IF EN-ON-GROUND(WS-ROW) = 1 AND EN-HEALTH(WS-ROW) > 0
             MOVE 1 TO WS-MARK
             CALL "AQUA-RAND" USING WS-ROW WS-SALT1 WS-R1
             CALL "AQUA-RAND" USING WS-ROW WS-SALT2 WS-R2
         END-IF
         CALL "MOB-STEP" USING WS-ROW
         IF WS-MARK = 1
             ADD 1 TO WS-FLOPS
             COMPUTE WS-EXPX = (WS-VXB + (WS-R1 * 2 - 1) * 0.05) * 0.91
             COMPUTE WS-EXPZ = (WS-VZB + (WS-R2 * 2 - 1) * 0.05) * 0.91
             COMPUTE WS-DIFF = FUNCTION ABS(EN-VX(WS-ROW) - WS-EXPX) + FUNCTION ABS(EN-VZ(WS-ROW) - WS-EXPZ)
             IF WS-DIFF < 0.0001
                 ADD 1 TO WS-GOOD
             END-IF
             IF EN-ON-GROUND(WS-ROW) = 0 AND EN-VY(WS-ROW) > 0.25
                 ADD 100 TO WS-GOOD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§4.1 13.1 the cod flopped six times on the ground within 200 ticks" TO WS-NAME
     MOVE 6 TO WS-EXP
     MOVE WS-FLOPS TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§4.1 13.1 every flop adds ((draw1 x 2 - 1) x 0.05, 0.4, (draw2 x 2 - 1) x 0.05): x draw first, then z (6 of 6)" TO WS-NAME
     MOVE 6 TO WS-EXP
     COMPUTE WS-OBS = FUNCTION MOD(WS-GOOD, 100)
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§4.1 and every flop clears onGround and throws the fish up (6 of 6)" TO WS-NAME
     MOVE 6 TO WS-EXP
     COMPUTE WS-OBS = (WS-GOOD - FUNCTION MOD(WS-GOOD, 100)) / 100
     PERFORM EXPECT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   4.2 the dolphin on dry ground hops on a tick it stands on the ground: draws of salts 8 and 9 (x, z). A wide stone floor beside the tank.
     COMPUTE WS-FX = WS-X0 + 14
     MOVE 15 TO WS-SIZE
     MOVE 1 TO WS-KIND
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-Z0 WS-SIZE WS-Y0 WS-KIND
     COMPUTE WS-X = WS-X0 + 21.5
     COMPUTE WS-Y = WS-Y0 + 1
     COMPUTE WS-Z = WS-Z0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 8 TO WS-SALT1
     MOVE 9 TO WS-SALT2
     MOVE 0 TO WS-FLOPS WS-GOOD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200 OR WS-FLOPS >= 6
         ADD 1 TO CW-TIME
         MOVE EN-VX(WS-ROW) TO WS-VXB
         MOVE EN-VZ(WS-ROW) TO WS-VZB
         MOVE 0 TO WS-MARK
         IF EN-ON-GROUND(WS-ROW) = 1
             MOVE 1 TO WS-MARK
             CALL "AQUA-RAND" USING WS-ROW WS-SALT1 WS-R1
             CALL "AQUA-RAND" USING WS-ROW WS-SALT2 WS-R2
         END-IF
         CALL "MOB-STEP" USING WS-ROW
         IF WS-MARK = 1
             ADD 1 TO WS-FLOPS
             COMPUTE WS-EXPX = (WS-VXB + (WS-R1 * 2 - 1) * 0.2) * 0.91
             COMPUTE WS-EXPZ = (WS-VZB + (WS-R2 * 2 - 1) * 0.2) * 0.91
             COMPUTE WS-DIFF = FUNCTION ABS(EN-VX(WS-ROW) - WS-EXPX) + FUNCTION ABS(EN-VZ(WS-ROW) - WS-EXPZ)
             IF WS-DIFF < 0.0001 AND EN-ON-GROUND(WS-ROW) = 0
                 ADD 1 TO WS-GOOD
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§4.2 the dry dolphin hopped six times; each adds ((draw1 x 2 - 1) x 0.2, 0.5, (draw2 x 2 - 1) x 0.2) and clears onGround" TO WS-NAME
     MOVE 6 TO WS-EXP
     MOVE WS-GOOD TO WS-OBS
     PERFORM EXPECT
*>   13.2: moistness 2400 reached, 1 damage lands about every 10 ticks (the hurt window), a dolphin of 10 health lasts about 100 ticks.
     MOVE 2400 TO EN-DRY(WS-ROW)
     MOVE 0 TO EN-HURT(WS-ROW)
     MOVE 10 TO WS-HEALTH
     MOVE 0 TO WS-DROPS WS-LAST WS-FIRST
     MOVE 0 TO WS-GAP
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 130 OR EN-HEALTH(WS-ROW) = 0
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         IF EN-HEALTH(WS-ROW) < WS-HEALTH
             ADD 1 TO WS-DROPS
             IF WS-LAST > 0 AND WS-GAP = 0
                 COMPUTE WS-GAP = WS-I - WS-LAST
             END-IF
             IF WS-FIRST = 0
                 MOVE WS-I TO WS-FIRST
             END-IF
             MOVE WS-I TO WS-LAST
             MOVE EN-HEALTH(WS-ROW) TO WS-HEALTH
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-7§4.2 13.2 the first dry-out hit lands on the first tick at moistness 0" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE WS-FIRST TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§4.2 13.2 the next hit lands 10 ticks later (the call when the window reads 10)" TO WS-NAME
     MOVE 10 TO WS-EXP
     MOVE WS-GAP TO WS-OBS
     PERFORM EXPECT
     MOVE "acceptance US15 44-7§4.2 13.2 the dolphin of 10 health dies after 10 hits, about 100 ticks (between 91 and 100)" TO WS-NAME
     MOVE 1 TO WS-EXP
     MOVE 0 TO WS-OBS
     IF EN-HEALTH(WS-ROW) = 0 AND WS-I >= 91 AND WS-I <= 101
         MOVE 1 TO WS-OBS
     END-IF
     PERFORM EXPECT
     CALL "ENTITY-REMOVE" USING WS-ROW
*>   4.2: in water the moistness is back at 2400 (EN-DRY 0), also in rain.
     COMPUTE WS-X = WS-X0 + 5.0
     COMPUTE WS-Y = WS-Y0 + 3.0
     COMPUTE WS-Z = WS-Z0 + 5.0
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1500 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§4.2 a dolphin in water has full moistness again (dry ticks 0)" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE EN-DRY(WS-ROW) TO WS-OBS
     PERFORM EXPECT
     CALL "ENTITY-REMOVE" USING WS-ROW
     MOVE 1 TO CW-RAIN-LEVEL(WS-DIM)
     COMPUTE WS-X = WS-X0 + 21.5
     COMPUTE WS-Y = WS-Y0 + 1
     COMPUTE WS-Z = WS-Z0 + 7.5
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1500 TO EN-DRY(WS-ROW)
     ADD 1 TO CW-TIME
     CALL "MOB-STEP" USING WS-ROW
     MOVE "acceptance US15 44-7§4.2 a dolphin out in the rain (isInWaterOrRain) has full moistness again" TO WS-NAME
     MOVE 0 TO WS-EXP
     MOVE EN-DRY(WS-ROW) TO WS-OBS
     PERFORM EXPECT
     STOP RUN.
 EXPECT.
     MOVE WS-NAME TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED-N
     MOVE WS-OBS TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-Q44-44-7-4.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY AQUATEST.
