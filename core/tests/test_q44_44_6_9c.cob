*> The cube-mob move control (docs/protocol/44-residual-mob-questions-6-nether.md section 9.3 and 21 section 5.3; lane 002-lane-p49l): a slime or magma cube on the ground does not
*> walk between its jumps; it counts jumpDelay down and jumps at 0 (jump velocity 0.42, plus 0.1 x size for a magma cube), then jumpDelay = nextInt(20) + 10 (x 4 for a magma cube),
*> divided by 3 (integer) when its attack goal makes the control aggressive (it has a target and can deal damage). A cube in the air keeps its course.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-9C.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BRWORLD.
 COPY STDMOBS.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-GM                  BINARY-LONG.
 01 WS-K24                 PIC X(24).
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-X0
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z0
     COMPUTE WS-BX = FUNCTION INTEGER(WS-X0) - 20
     COMPUTE WS-BY = FUNCTION INTEGER(WS-Y) - 1
     COMPUTE WS-BZ = FUNCTION INTEGER(WS-Z0) - 20
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-BX WS-BZ 40 WS-BY 1
     MOVE 1000 TO CW-TICKS
     CALL "T-CLEAR"
     MOVE "slime" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-S
     MOVE 2 TO EN-VARIANT(WS-S)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-S) WS-M
     MOVE 1 TO EN-ON-GROUND(WS-S)
     MOVE 0 TO EN-TARGET(WS-S)
*>   On the ground the control counts the delay down and the cube stands still.
     MOVE 5 TO EN-HOP(WS-S)
     MOVE 0.1 TO WS-HX
     MOVE 0.1 TO WS-HZ
     CALL "CUBE-HOP" USING WS-S WS-M WS-HX WS-HZ
     MOVE "acceptance 44-6§9.3 jumpDelay counts down on the ground" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-HOP(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FLAG
     IF WS-HX = 0 AND WS-HZ = 0
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 and the forward input is zero between jumps" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance 44-6§9.3 no jump yet" TO TL-CASE
     MOVE WS-NO TO TL-EXPECTED-N
     MOVE EN-VY(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   In the air nothing changes: the cube keeps its course.
     MOVE 0 TO EN-ON-GROUND(WS-S)
     MOVE 0.1 TO WS-HX
     MOVE 0.1 TO WS-HZ
     CALL "CUBE-HOP" USING WS-S WS-M WS-HX WS-HZ
     MOVE "acceptance 44-6§9.3 in the air the delay stays" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE EN-HOP(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FLAG
     IF WS-HX = 0.1 AND WS-HZ = 0.1
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 and the course" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   At 0 the cube jumps (0.42) and takes a new delay of 10 to 29; the draws over 100 jumps cover that range and stay in it.
     MOVE 1 TO EN-ON-GROUND(WS-S)
     MOVE 1 TO EN-HOP(WS-S)
     CALL "CUBE-HOP" USING WS-S WS-M WS-HX WS-HZ
     COMPUTE WS-N ROUNDED = EN-VY(WS-S) * 1000
     MOVE "acceptance 44-6§9.3 the jump velocity is 0.42" TO TL-CASE
     MOVE 420 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE 1 TO EN-HOP(WS-S)
         MOVE 1 TO EN-ON-GROUND(WS-S)
         CALL "CUBE-HOP" USING WS-S WS-M WS-HX WS-HZ
         IF EN-HOP(WS-S) < WS-MIN
             MOVE EN-HOP(WS-S) TO WS-MIN
         END-IF
         IF EN-HOP(WS-S) > WS-MAX
             MOVE EN-HOP(WS-S) TO WS-MAX
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FLAG
     IF WS-MIN >= 10 AND WS-MAX <= 29 AND WS-MAX - WS-MIN >= 10
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 jumpDelay = nextInt(20) + 10 (10 to 29, spread over 100 draws)" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Aggressive: a target and a cube that can deal damage divide the delay by 3 (3 to 9); a size 1 slime cannot.
     MOVE WS-PLAYER TO EN-TARGET(WS-S)
     MOVE 1000 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE 1 TO EN-HOP(WS-S)
         MOVE 1 TO EN-ON-GROUND(WS-S)
         CALL "CUBE-HOP" USING WS-S WS-M WS-HX WS-HZ
         IF EN-HOP(WS-S) < WS-MIN
             MOVE EN-HOP(WS-S) TO WS-MIN
         END-IF
         IF EN-HOP(WS-S) > WS-MAX
             MOVE EN-HOP(WS-S) TO WS-MAX
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FLAG
     IF WS-MIN >= 3 AND WS-MAX <= 9 AND WS-MAX - WS-MIN >= 3
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 aggressive: the delay is divided by 3 (3 to 9)" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-VARIANT(WS-S)
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 50
         MOVE 1 TO EN-HOP(WS-S)
         MOVE 1 TO EN-ON-GROUND(WS-S)
         CALL "CUBE-HOP" USING WS-S WS-M WS-HX WS-HZ
         IF EN-HOP(WS-S) > WS-MAX
             MOVE EN-HOP(WS-S) TO WS-MAX
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FLAG
     IF WS-MAX >= 10
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 a size 1 slime cannot deal damage: not aggressive (10 and up)" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A magma cube: jump velocity 0.42 + 0.1 x size, delay x 4 (40 to 116), aggressive with a target /3 (13 to 38).
     MOVE "magma_cube" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X0 WS-Y WS-Z0 WS-G
     MOVE 2 TO EN-VARIANT(WS-G)
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-G) WS-GM
     MOVE 0 TO EN-TARGET(WS-G)
     MOVE 1000 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE 1 TO EN-HOP(WS-G)
         MOVE 1 TO EN-ON-GROUND(WS-G)
         CALL "CUBE-HOP" USING WS-G WS-GM WS-HX WS-HZ
         IF EN-HOP(WS-G) < WS-MIN
             MOVE EN-HOP(WS-G) TO WS-MIN
         END-IF
         IF EN-HOP(WS-G) > WS-MAX
             MOVE EN-HOP(WS-G) TO WS-MAX
         END-IF
     END-PERFORM
     COMPUTE WS-N ROUNDED = EN-VY(WS-G) * 1000
     MOVE "acceptance 44-6§9.3 a size 2 magma cube jumps at 0.42 + 0.2" TO TL-CASE
     MOVE 620 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-FLAG
     IF WS-MIN >= 40 AND WS-MAX <= 116 AND WS-MAX - WS-MIN >= 40
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 magma cube: jumpDelay x 4 (40 to 116)" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-PLAYER TO EN-TARGET(WS-G)
     MOVE 1000 TO WS-MIN
     MOVE 0 TO WS-MAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         MOVE 1 TO EN-HOP(WS-G)
         MOVE 1 TO EN-ON-GROUND(WS-G)
         CALL "CUBE-HOP" USING WS-G WS-GM WS-HX WS-HZ
         IF EN-HOP(WS-G) < WS-MIN
             MOVE EN-HOP(WS-G) TO WS-MIN
         END-IF
         IF EN-HOP(WS-G) > WS-MAX
             MOVE EN-HOP(WS-G) TO WS-MAX
         END-IF
     END-PERFORM
     MOVE 0 TO WS-FLAG
     IF WS-MIN >= 13 AND WS-MAX <= 38 AND WS-MAX - WS-MIN >= 13
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 magma cube aggressive: (x 4) / 3 (13 to 38)" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The real tick (STDMOB-STEP): a slime on the ground that chases a player stays where it is while its delay runs and leaves the ground when it reaches 0.
     CALL "T-CLEAR"
     COMPUTE WS-X = WS-X0 + 4
     MOVE "slime" TO WS-K24
     CALL "T-SPAWN" USING WS-DIM WS-K24 WS-X WS-Y WS-Z0 WS-S
     MOVE 2 TO EN-VARIANT(WS-S)
     MOVE 0 TO EN-ON-GROUND(WS-S)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 30 OR EN-ON-GROUND(WS-S) = 1
         CALL "STDMOB-STEP" USING WS-S
     END-PERFORM
     MOVE "acceptance 44-6§9.3 the slime has landed" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE EN-ON-GROUND(WS-S) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO EN-HOP(WS-S)
     MOVE EN-X(WS-S) TO WS-HX
     MOVE EN-Y(WS-S) TO WS-HZ
     CALL "STDMOB-STEP" USING WS-S
     MOVE 0 TO WS-FLAG
     IF EN-X(WS-S) = WS-HX AND EN-Y(WS-S) = WS-HZ
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 a slime waiting for its jump does not walk toward the player" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO EN-HOP(WS-S)
     CALL "STDMOB-STEP" USING WS-S
     MOVE 0 TO WS-FLAG
     IF EN-Y(WS-S) > WS-HZ
         MOVE 1 TO WS-FLAG
     END-IF
     MOVE "acceptance 44-6§9.3 at delay 0 it jumps" TO TL-CASE
     MOVE WS-ONE TO TL-EXPECTED-N
     MOVE WS-FLAG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-Q44-44-6-9C.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-CLEAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-I                   BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM T-CLEAR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. T-SPAWN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KEY                  PIC X(24).
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KEY L-X L-Y L-Z L-ROW.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE L-KEY DELIMITED BY SPACE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING L-DIM WS-TYPE L-X L-Y L-Z WS-YAW L-ROW
     GOBACK.
 END PROGRAM T-SPAWN.

 COPY CORETEST.
 COPY MOBSPTEST.
