*> Acceptance test (US15, FR-036; docs/protocol/44-residual-mob-questions-7-aquatic.md section 7 and 13.14, lane 002-lane-p49j-a): the dolphin jump goal runs in the dolphin's tick.
*> A dolphin in the middle of a wide one-block-deep pool under open air (water at the offsets 0, 1, 4, 5, 6, 7 ahead in every direction, two air blocks above each) starts a jump on
*> some tick (1 chance in 5) with an upward velocity of 0.7 added; the tank with a stone ceiling of test_mob_21_4_6 (no air above the water) never starts one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-7-7W.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-DOLPHIN             BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-MAXVY               FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "minecraft:dolphin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-DOLPHIN WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
     MOVE "minecraft:water" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-WATER
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 30
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y0 = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 60
     PERFORM VARYING WS-BX FROM WS-X0 BY 1 UNTIL WS-BX > WS-X0 + 24
         PERFORM VARYING WS-BZ FROM WS-Z0 BY 1 UNTIL WS-BZ > WS-Z0 + 24
             MOVE WS-Y0 TO WS-BY
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE
             COMPUTE WS-BY = WS-Y0 + 1
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-WATER
             PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > 4
                 COMPUTE WS-BY = WS-Y0 + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-X = WS-X0 + 12.5
     COMPUTE WS-Y = WS-Y0 + 1.1
     COMPUTE WS-Z = WS-Z0 + 12.5
     CALL "MOB-SPAWN" USING WS-DIM WS-DOLPHIN WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 0 TO WS-MAXVY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 150
         ADD 1 TO CW-TIME
         CALL "MOB-STEP" USING WS-ROW
         COMPUTE WS-MAXVY = FUNCTION MAX(WS-MAXVY, EN-VY(WS-ROW))
     END-PERFORM
     MOVE "acceptance US15 44-7§7 a dolphin at the surface of open water jumps: vy rises by 0.7 on some tick within 150" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAXVY > 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-7-7W.
 COPY CORETEST.
 COPY MOBSPTEST.
