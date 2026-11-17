*> Coverage of the woodland mansion floor plan's edge cases (docs/protocol/36-structures-7-woodland-mansion.md sections 5.4, 5.5, 12; core/src/struct-mansion.cob): the door corner of a 2x2 room taken from each
*> of its four corners, the third floor with no door-bearing 1x2 room and with a stair room whose far half has no free side, and every violation MNG-CHECK counts (each from a valid hand-built plan altered by one fault).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVE-A-MANSION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 10.
 01 WS-GRID1               BINARY-LONG VALUE 1.
 01 WS-GRID2               BINARY-LONG VALUE 2.
 01 WS-GRID3               BINARY-LONG VALUE 3.
 01 WS-GRID4               BINARY-LONG VALUE 4.
 01 WS-VAL0                BINARY-LONG VALUE 0.
 01 WS-Z0                  BINARY-LONG VALUE 0.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-T0                  BINARY-LONG VALUE 10.
 01 WS-T1                  BINARY-LONG VALUE 10.
 01 WS-X4                  BINARY-LONG VALUE 4.
 01 WS-Y4                  BINARY-LONG VALUE 4.
 01 WS-X5                  BINARY-LONG VALUE 5.
 01 WS-Y5                  BINARY-LONG VALUE 5.
 01 WS-VAL1                BINARY-LONG VALUE 1.
 01 WS-VAL2                BINARY-LONG VALUE 2.
 01 WS-VAL3                BINARY-LONG VALUE 3.
 01 WS-VAL5                BINARY-LONG VALUE 5.
 01 WS-STAIRS-BIT          BINARY-LONG VALUE 4194304.
 01 WS-CORNER-X            BINARY-LONG OCCURS 4 TIMES.
 01 WS-CORNER-Y            BINARY-LONG OCCURS 4 TIMES.
 01 WS-CORR-X              BINARY-LONG OCCURS 4 TIMES.
 01 WS-CORR-Y              BINARY-LONG OCCURS 4 TIMES.
 01 WS-ED                  PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 4 TO WS-CORNER-X(1) MOVE 4 TO WS-CORNER-Y(1) MOVE 3 TO WS-CORR-X(1) MOVE 4 TO WS-CORR-Y(1)
     MOVE 5 TO WS-CORNER-X(2) MOVE 4 TO WS-CORNER-Y(2) MOVE 6 TO WS-CORR-X(2) MOVE 4 TO WS-CORR-Y(2)
     MOVE 4 TO WS-CORNER-X(3) MOVE 5 TO WS-CORNER-Y(3) MOVE 3 TO WS-CORR-X(3) MOVE 5 TO WS-CORR-Y(3)
     MOVE 5 TO WS-CORNER-X(4) MOVE 5 TO WS-CORNER-Y(4) MOVE 6 TO WS-CORR-X(4) MOVE 5 TO WS-CORR-Y(4)
*>   a 2x2 room whose only corridor neighbour touches one corner takes its door at that corner, whichever corner the two draws chose first
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         PERFORM CLEAR-GRIDS
         CALL "MNG-FILL" USING WS-GRID1 WS-X4 WS-Y4 WS-X5 WS-Y5 WS-VAL2
         CALL "MNG-SET" USING WS-GRID1 WS-CORR-X(WS-K) WS-CORR-Y(WS-K) WS-VAL1
         CALL "SPB-RESET"
         CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
         CALL "MNG-ROOM" USING WS-GRID1 WS-GRID3 WS-CORNER-X(1) WS-CORNER-Y(1) WS-ID
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
             CALL "MNG-GET" USING WS-GRID3 WS-CORNER-X(WS-I) WS-CORNER-Y(WS-I) WS-V
             IF WS-I = WS-K
                 COMPUTE WS-WANT = 262144 + 10 + 1048576 + 2097152
             ELSE
                 COMPUTE WS-WANT = 262144 + 10
             END-IF
             IF WS-V NOT = WS-WANT
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
         MOVE WS-K TO WS-ED
         MOVE SPACES TO TL-CASE
         STRING "acceptance US12 36-7§5.4 a 2x2 room with its corridor beside corner " FUNCTION TRIM(WS-ED) " has origin and door there only" DELIMITED BY SIZE INTO TL-CASE
         MOVE 0 TO TL-EXPECTED-N
         MOVE WS-BAD TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   the third floor of a plan with no 1x2 room carrying a door: an all-5 grid
     PERFORM CLEAR-GRIDS
     CALL "MNG-FILL" USING WS-GRID2 WS-Z0 WS-Z1 WS-T0 WS-T1 WS-VAL3
     CALL "MNG-THIRD-FLOOR"
     PERFORM COUNT-NOT-FIVE
     MOVE "acceptance US12 36-7§5.5 no door-bearing 1x2 room leaves the third floor all 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a lone 1x2 room with a door: its far half has no free side, so the third floor is all 5 again and the stairs flag is taken back
     PERFORM CLEAR-GRIDS
     CALL "MNG-SET" USING WS-GRID1 WS-X4 WS-Y4 WS-VAL2
     CALL "MNG-SET" USING WS-GRID1 WS-X5 WS-Y4 WS-VAL2
     COMPUTE WS-CODE = 131072 + 10 + 1048576 + 2097152
     CALL "MNG-SET" USING WS-GRID4 WS-X4 WS-Y4 WS-CODE
     COMPUTE WS-V = 131072 + 10
     CALL "MNG-SET" USING WS-GRID4 WS-X5 WS-Y4 WS-V
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     CALL "MNG-THIRD-FLOOR"
     PERFORM COUNT-NOT-FIVE
     MOVE "acceptance US12 36-7§5.5 a stair room whose far half has no free side leaves the third floor all 5" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MNG-GET" USING WS-GRID4 WS-X4 WS-Y4 WS-V
     MOVE "acceptance US12 36-7§5.5 the room code of that stair room is back to its plain code" TO TL-CASE
     MOVE WS-CODE TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   MNG-CHECK: a valid plan counts nothing, and each fault one (or two floors' worth)
     PERFORM VALID-PLAN
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 a hand-built valid plan has no violation" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 0 TO WS-X WS-Y
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL0
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 2 a clear cell in the top border rows is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 9 TO WS-X
     MOVE 4 TO WS-Y
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL0
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 2 a clear cell in the east border columns is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 7 TO WS-X
     MOVE 4 TO WS-Y
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL0
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 3 the entrance cell (7, 4) not 3 is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 6 TO WS-X
     MOVE 4 TO WS-Y
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL0
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 3 the first room cell (6, 4) not 2 is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 3 TO WS-X
     MOVE 3 TO WS-Y
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL2
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 4 a room cell with no room code on floors 0 and 1 is two violations" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 2 TO WS-X
     MOVE 2 TO WS-Y
     COMPUTE WS-CODE = 131072 + 11 + 1048576
     CALL "MNG-SET" USING WS-GRID3 WS-X WS-Y WS-CODE
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 5 a 1x2 room with one cell is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 2 TO WS-X
     MOVE 5 TO WS-Y
     COMPUTE WS-CODE = 65536 + 12 + 1048576 + 2097152
     CALL "MNG-SET" USING WS-GRID3 WS-X WS-Y WS-CODE
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 5 a door flag with no corridor beside the origin is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 2 TO WS-X
     MOVE 6 TO WS-Y
     COMPUTE WS-CODE = 131072 + 13
     CALL "MNG-SET" USING WS-GRID3 WS-X WS-Y WS-CODE
     MOVE 3 TO WS-X
     COMPUTE WS-CODE = 131072 + 13 + 1048576
     CALL "MNG-SET" USING WS-GRID3 WS-X WS-Y WS-CODE
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 5 the origin of a door-less room away from its minimum corner is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Y
     CALL "MNG-SET" USING WS-GRID4 WS-X WS-Y WS-STAIRS-BIT
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 6 a stairs flag with no stair cell on the third floor is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VALID-PLAN
     MOVE 8 TO WS-X
     MOVE 8 TO WS-Y
     CALL "MNG-SET" USING WS-GRID2 WS-X WS-Y WS-VAL3
     CALL "MNG-CHECK" USING WS-V
     MOVE "acceptance US12 36-7§12 item 6 one stair cell instead of two is a violation" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 CLEAR-GRIDS.
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 5
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
             MOVE 0 TO MN-CELL(WS-G, WS-I)
         END-PERFORM
     END-PERFORM.
 VALID-PLAN.
     PERFORM CLEAR-GRIDS
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             IF WS-Y < 2 OR WS-Y > 8 OR (WS-X > 8 AND WS-Y > 1 AND WS-Y < 8)
                 CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL5
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 7 TO WS-X
     MOVE 4 TO WS-Y
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL3
     MOVE 6 TO WS-X
     CALL "MNG-SET" USING WS-GRID1 WS-X WS-Y WS-VAL2
     COMPUTE WS-CODE = 65536 + 10 + 1048576
     CALL "MNG-SET" USING WS-GRID3 WS-X WS-Y WS-CODE
     CALL "MNG-SET" USING WS-GRID4 WS-X WS-Y WS-CODE.
 COUNT-NOT-FIVE.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING WS-GRID2 WS-X WS-Y WS-V
             IF WS-V NOT = 5
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM.
 END PROGRAM TEST-COVE-A-MANSION.
