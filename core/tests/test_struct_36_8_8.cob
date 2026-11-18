*> Acceptance test of the end city start (docs/protocol/36-structures-8-nether-and-end.md section 8.2 and the start rule 12.4; core/src/struct-endcity.cob; T13508): the start block (chunk * 16 + 7),
*> the rotation as the first draw, no city below y 60, the corner offsets of the lowest-y test for each rotation, and the house placed on the start position.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTEC.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-REF                 BINARY-DOUBLE UNSIGNED.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-DRAW                BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   chunk (3, -2): start block (55, -25); the corners for clockwise 90 are (55,-25), (55,-20), (50,-25), (50,-20)
     MOVE 1 TO WS-ROT
     CALL "ENDCITY-CORNER" USING WS-ROT WS-SX WS-SZ
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: clockwise 90 tests the corners with sizes (-5, 5)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SX NOT = -5 OR WS-SZ NOT = 5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-ROT
     CALL "ENDCITY-CORNER" USING WS-ROT WS-SX WS-SZ
     IF WS-SX NOT = 5 OR WS-SZ NOT = 5
         ADD 1 TO WS-BAD
     END-IF
     MOVE 2 TO WS-ROT
     CALL "ENDCITY-CORNER" USING WS-ROT WS-SX WS-SZ
     IF WS-SX NOT = -5 OR WS-SZ NOT = -5
         ADD 1 TO WS-BAD
     END-IF
     MOVE 3 TO WS-ROT
     CALL "ENDCITY-CORNER" USING WS-ROT WS-SX WS-SZ
     IF WS-SX NOT = 5 OR WS-SZ NOT = -5
         ADD 1 TO WS-BAD
     END-IF
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: the corner sizes of none, 180 and counterclockwise 90" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   a lowest y of 59 gives no city and no piece, 60 gives one
     MOVE 3 TO WS-CX
     MOVE -2 TO WS-CZ
     MOVE 59 TO WS-LOW
     CALL "ENDCITY-START" USING WS-SEED WS-CX WS-CZ WS-LOW WS-VALID
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: a lowest y of 59 gives no city" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-VALID + EC-COUNT
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 60 TO WS-LOW
     CALL "ENDCITY-START" USING WS-SEED WS-CX WS-CZ WS-LOW WS-VALID
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: a lowest y of 60 gives a city" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-VALID TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the house sits on (chunk * 16 + 7, lowest y, chunk * 16 + 7) with the rotation of the first draw
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-REF WS-SEED WS-CX WS-CZ
     CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-FOUR WS-DRAW
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: the first piece is base_floor at (55, 60, -25)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EP-NAME(1) NOT = "base_floor" OR EP-X(1) NOT = 55 OR EP-Y(1) NOT = 60 OR EP-Z(1) NOT = -25 OR EP-ROT(1) NOT = WS-DRAW
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the rotation is the draw for every chunk
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 30
         MOVE WS-K TO WS-CX
         COMPUTE WS-CZ = 0 - WS-K * 3
         MOVE 70 TO WS-LOW
         CALL "ENDCITY-START" USING WS-SEED WS-CX WS-CZ WS-LOW WS-VALID
         CALL "JRAND-LARGE-FEATURE-SEED" USING WS-REF WS-SEED WS-CX WS-CZ
         CALL "JRAND-NEXT-INT-BOUND" USING WS-REF WS-FOUR WS-DRAW
         IF EP-ROT(1) NOT = WS-DRAW OR EP-ROT(2) NOT = WS-DRAW OR EP-X(1) NOT = WS-CX * 16 + 7 OR EP-Z(1) NOT = WS-CZ * 16 + 7
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: rotation and position follow the chunk in 30 starts" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-8.
