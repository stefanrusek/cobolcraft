*> Acceptance test of the woodland mansion piece layout (docs/protocol/36-structures-7-woodland-mansion.md section 6; core/src/struct-man-place.cob; T13502): world seed 0, chunk (2, 0), rotation NONE:
*> the entrance and the first outer-wall pieces of 11.1, then rules that hold for every layout (one entrance, every name is a template of the catalogue of 10, no piece lost, the vertical range 0 to 30,
*> the floors in the order of 6.2) and that the layout is a function of the start random alone.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-7-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 COPY STRUCTMAN.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-BOUND               BINARY-LONG VALUE 4.
 01 WS-ROT                 BINARY-LONG.
 01 WS-Z1                  BINARY-LONG VALUE 0.
 01 WS-Z2                  BINARY-LONG VALUE 0.
 01 WS-Z3                  BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-ENTRANCES           BINARY-LONG.
 01 WS-MAXY                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-COUNT1              BINARY-LONG.
 01 WS-RNG1                BINARY-DOUBLE UNSIGNED.
 01 WS-ED                  PIC -(9)9.
 01 WS-NAME                PIC X(24).
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     CALL "MNG-BUILD"
     CALL "MNP-LAYOUT" USING WS-ROT WS-Z1 WS-Z2 WS-Z3
     MOVE WS-ROT TO WS-I
     MOVE "acceptance US12 36-7§6 The piece layout: entry 1 is the entrance one tile west of the origin" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF ME-NAME(1) = "entrance" AND ME-X(1) = -9 AND ME-Y(1) = 0 AND ME-Z(1) = 0 AND ME-ROT(1) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6 The piece layout: entries 2 to 4 are wall_flat at z 16, 24, 32 (x 7)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF ME-NAME(2) = "wall_flat" AND ME-X(2) = 7 AND ME-Z(2) = 16 AND ME-NAME(3) = "wall_flat" AND ME-Z(3) = 24
         AND ME-NAME(4) = "wall_flat" AND ME-Z(4) = 32 AND ME-X(4) = 7
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6 The piece layout: the corner turns the cursor (wall_corner, then wall_flat turned 90)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF ME-NAME(5) = "wall_corner" AND ME-X(5) = 0 AND ME-Z(5) = 39 AND ME-NAME(6) = "wall_flat" AND ME-X(6) = 6 AND ME-Z(6) = 39
         AND ME-ROT(6) = 1 AND ME-X(7) = -2 AND ME-Z(7) = 39 AND ME-ROT(7) = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-BAD
     MOVE 0 TO WS-ENTRANCES
     MOVE 1000 TO WS-MINY
     MOVE -1000 TO WS-MAXY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > MN-COUNT
         MOVE ME-NAME(WS-I) TO WS-NAME
         IF WS-NAME = "entrance"
             ADD 1 TO WS-ENTRANCES
         END-IF
         EVALUATE TRUE
             WHEN WS-NAME(1:4) = "1x1_" OR WS-NAME(1:4) = "1x2_" OR WS-NAME(1:4) = "2x2_"
                 CONTINUE
             WHEN WS-NAME = "entrance" OR WS-NAME(1:5) = "wall_" OR WS-NAME(1:8) = "indoors_" OR WS-NAME(1:7) = "carpet_"
                 CONTINUE
             WHEN WS-NAME(1:4) = "roof" OR WS-NAME(1:10) = "small_wall" OR WS-NAME = "corridor_floor"
                 CONTINUE
             WHEN OTHER
                 ADD 1 TO WS-BAD
                 DISPLAY "PROBE unknown template name " WS-NAME
         END-EVALUATE
         IF ME-Y(WS-I) < WS-MINY
             MOVE ME-Y(WS-I) TO WS-MINY
         END-IF
         IF ME-Y(WS-I) > WS-MAXY
             MOVE ME-Y(WS-I) TO WS-MAXY
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-7§6 The piece layout: every name is a template of the catalogue" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6 The piece layout: one entrance only" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-ENTRANCES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6 The piece layout: no entry over the table is lost" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE MN-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6 The piece layout: the lowest piece is at y 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MINY TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-7§6 The piece layout: no piece starts above y 30 (the three floors and the roof)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MAXY <= 30 AND WS-MAXY >= 19
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the layout depends on the start random only: the same start again gives the same list
     MOVE MN-COUNT TO WS-COUNT1
     CALL "SPB-RESET"
     CALL "JRAND-LARGE-FEATURE-SEED" USING SP-RNG WS-USEED 2 0
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-BOUND WS-ROT
     CALL "MNG-BUILD"
     CALL "MNP-LAYOUT" USING WS-ROT WS-Z1 WS-Z2 WS-Z3
     MOVE "acceptance US12 36-7§6 The piece layout: the same start gives the same list" TO TL-CASE
     MOVE WS-COUNT1 TO TL-EXPECTED-N
     MOVE MN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-7-6.
