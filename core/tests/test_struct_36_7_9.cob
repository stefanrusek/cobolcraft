*> Acceptance test of the order of random draws of the woodland mansion (docs/protocol/36-structures-7-woodland-mansion.md section 9; T13504): the rotation is the first draw (one nextInt(4)),
*> the grid draws follow, and the placer draws nothing for the entrance, the outer walls, the roofs and the corridor floors (the only draws are the rooms' door and name draws, floor by floor).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-9.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-BEFORE              BINARY-DOUBLE UNSIGNED.
 01 WS-AFTER               BINARY-DOUBLE UNSIGNED.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-C1                  BINARY-LONG VALUE 1.
 01 WS-C2                  BINARY-LONG VALUE 2.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-THIRD               BINARY-LONG VALUE 2.
 01 WS-SOUTH               BINARY-LONG VALUE 2.
 01 WS-SX                  BINARY-LONG VALUE 8.
 01 WS-SY                  BINARY-LONG VALUE 5.
 01 WS-EX                  BINARY-LONG VALUE 8.
 01 WS-EY                  BINARY-LONG VALUE 4.
 01 WS-RY                  BINARY-LONG VALUE 16.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-DRAWS               BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-DUMMY               BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SPB-RESET"
*>   the first draw after the seeding is the rotation's nextInt(4)
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     MOVE SP-RNG TO WS-REF
     CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-BOUND WS-DUMMY
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     MOVE "acceptance US12 36-7§9 Order of random draws: the rotation is one nextInt(4) as the first draw" TO TL-CASE
     MOVE WS-REF TO TL-EXPECTED-N
     MOVE SP-RNG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "MNG-BUILD"
     MOVE "acceptance US12 36-7§9 Order of random draws: the grid build draws" TO TL-CASE
     MOVE WS-REF TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF SP-RNG NOT = WS-REF
         MOVE WS-REF TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   entrance, outer walls, roofs: no draw
     MOVE 0 TO MN-COUNT MN-LOST
     MOVE 0 TO MN-CX(1)
     MOVE 0 TO MN-CY(1)
     MOVE 0 TO MN-CZ(1)
     MOVE 0 TO MN-CROT(1)
     MOVE 0 TO MN-CWALL(1)
     MOVE WS-ROT TO MN-ROT
     MOVE 0 TO MN-OX MN-OY MN-OZ
     MOVE SP-RNG TO WS-BEFORE
     CALL "MNP-C-ENTRANCE" USING WS-C1
     MOVE 1 TO MN-CWALL(2)
     MOVE 0 TO MN-CX(2) MN-CY(2) MN-CZ(2) MN-CROT(2)
     CALL "MNP-OUTER" USING WS-C2 WS-BASE WS-SOUTH WS-SX WS-SY WS-EX WS-EY
     CALL "MNP-ROOF" USING WS-RY WS-BASE WS-THIRD
     MOVE "acceptance US12 36-7§9 Order of random draws: the entrance, the outer walls and the roof draw nothing" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE SP-RNG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   corridor floors: no draw, rooms: draws
     MOVE SP-RNG TO WS-BEFORE
     MOVE 0 TO WS-DRAWS
     PERFORM VARYING WS-FLOOR FROM 0 BY 1 UNTIL WS-FLOOR > 2
         CALL "MNP-FLOOR-CORR" USING WS-FLOOR
     END-PERFORM
     MOVE "acceptance US12 36-7§9 Order of random draws: corridor floors and carpets draw nothing" TO TL-CASE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     MOVE SP-RNG TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM VARYING WS-FLOOR FROM 0 BY 1 UNTIL WS-FLOOR > 2
         CALL "MNP-FLOOR-ROOMS" USING WS-FLOOR
     END-PERFORM
     MOVE "acceptance US12 36-7§9 Order of random draws: the rooms of the three floors draw" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF SP-RNG NOT = WS-BEFORE
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-9.
