*> Implementation test (002-lane-mobsa3; 44 part 4 section 12): the ArmadilloBallUp tick: the peek timer, the unrolling threshold of the danger memory (30 ticks), unrolling back to scared above it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-13-PEEK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-N0                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SCUTE               BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-BRUSH               BINARY-LONG.
 01 WS-BRUSH-ROW           PIC X(270).
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:armadillo" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:zombie" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "minecraft:armadillo_scute" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SCUTE WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO PL-SPRINTING(WS-PLAYER)

     COMPUTE WS-X = WS-PX + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE 1000000 TO EN-SCUTE(WS-A)
     MOVE 1 TO EN-ON-GROUND(WS-A)
     MOVE 2 TO EN-ARMA(WS-A)
     MOVE 80 TO EN-DANGER(WS-A)
     MOVE 0 TO EN-ARMA-AROUND(WS-A)
     MOVE 0 TO EN-ARMA-PEEK(WS-A)
     CALL "ARMADILLO-TICK" USING WS-A WS-N
     MOVE "acceptance US15 44-4§12 Armadillo: danger around (remaining above 75) re-rolls the peek timer to 150 to 450" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ARMA-PEEK(WS-A) >= 149 AND EN-ARMA-PEEK(WS-A) <= 450
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-4§12 Armadillo: the flag danger around is stored" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-ARMA-AROUND(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A timer of 1 runs out, the peek plays (event 64) and the timer is drawn again.
     MOVE 1 TO EN-ARMA-PEEK(WS-A)
     MOVE 79 TO EN-DANGER(WS-A)
     CALL "ARMADILLO-TICK" USING WS-A WS-N
     MOVE "acceptance US15 44-4§12 Armadillo: a peek (timer 0, on the ground, danger around) re-rolls the timer" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-ARMA-PEEK(WS-A) >= 149
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Remaining below 30: unrolling; above 30 again: back to scared.
     MOVE 31 TO EN-DANGER(WS-A)
     CALL "ARMADILLO-TICK" USING WS-A WS-N
     MOVE "acceptance US15 44-4§12 Armadillo: remaining 30 stays scared" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ARMADILLO-TICK" USING WS-A WS-N
     MOVE "acceptance US15 44-4§12 Armadillo: remaining 29 starts unrolling (state 3)" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 80 TO EN-DANGER(WS-A)
     CALL "ARMADILLO-TICK" USING WS-A WS-N
     MOVE "acceptance US15 44-4§12 Armadillo: fresh danger while unrolling returns it to scared" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-ARMA(WS-A) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-19-13-PEEK.
 COPY CORETEST.
 COPY MOBSPTEST.
