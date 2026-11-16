*> Test of the eye of ender locate over the ring chunk list (docs/protocol/36-structures-5-mineshaft-stronghold.md section 3.10, 36-1 section 11 step 3; core/src/struct-eye.cob STRUCT-NEAREST-RING):
*> the answer is the ring chunk whose centre (16 cx + 8, 32, 16 cz + 8) is nearest to the origin (the first of equal distances), and the locate position of that chunk (4.8). Over the fixture
*> ring set of three chunks (-13,-106) (121,52) (-92,69) (36-1 12.3, seed 0, no biome to snap to) the worked vectors give each chunk for an origin near it, and a brute force model written in the
*> test (its own squared distances, strict less-than) agrees for a grid of 49 origins. The function leaves the ring list as it found it, answers `not found` for a set that has no ring list and
*> for a set that is not a concentric_rings set, and the stronghold lookup by name finds the set whose key ends in the name.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-EYE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTDATA.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/struct".
 01 WS-CLIMATE-DIR         PIC X(1100) VALUE "core/tests/fixtures/density".
 01 WS-STATUS              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-SET                 BINARY-LONG VALUE 6.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-MINS.
    05 WS-MIN              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-MAXS.
    05 WS-MAX              BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-OFFSET              BINARY-DOUBLE.
 01 WS-BEST                BINARY-DOUBLE.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-DX                  BINARY-DOUBLE.
 01 WS-DY                  BINARY-DOUBLE.
 01 WS-DZ                  BINARY-DOUBLE.
 01 WS-BAD                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-EDIT-A              PIC -(9)9.
 01 WS-EDIT-B              PIC -(9)9.
 01 WS-EDIT-C              PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "STRUCT-LOAD" USING WS-DIR WS-STATUS
     CALL "WORLDGEN-FREE"
     CALL "NOISES-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     CALL "DENSITY-FUNCTIONS-LOAD" USING WS-CLIMATE-DIR WS-STATUS
     MOVE 0 TO WS-SEED
     MOVE 0 TO WS-USEED
     CALL "DENSITY-SETUP" USING WS-USEED
     CALL "CLIMATE-POINTS-RESET"
     CALL "STRUCT-POSSIBLE-BUILD"
     MOVE "minecraft:forest" TO WS-NAME
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         MOVE -10000 TO WS-MIN(WS-I)
         MOVE 10000 TO WS-MAX(WS-I)
     END-PERFORM
     MOVE 0 TO WS-OFFSET
     CALL "CLIMATE-POINT-ADD" USING WS-NAME WS-MINS WS-MAXS WS-OFFSET
     CALL "STRUCT-RINGS-BUILD" USING WS-SET WS-SEED
     MOVE "T" TO TL-MODE

*>   worked vectors
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
         EVALUATE WS-I
             WHEN 1
                 MOVE 0 TO WS-OX
                 MOVE 64 TO WS-OY
                 MOVE 0 TO WS-OZ
             WHEN 2
                 MOVE 2000 TO WS-OX
                 MOVE 70 TO WS-OY
                 MOVE 100 TO WS-OZ
             WHEN OTHER
                 MOVE -1500 TO WS-OX
                 MOVE 64 TO WS-OY
                 MOVE 1100 TO WS-OZ
         END-EVALUATE
         CALL "STRUCT-NEAREST-RING" USING WS-SET WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-EDIT-A
         STRING "acceptance US12 36-5§3.10 eye of ender: the nearest ring chunk of the worked origin " FUNCTION TRIM(WS-EDIT-A) DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO WS-TEXT
         MOVE 1 TO WS-PTR
         MOVE WS-FOUND TO WS-EDIT-C
         MOVE WS-CX TO WS-EDIT-A
         MOVE WS-CZ TO WS-EDIT-B
         STRING FUNCTION TRIM(WS-EDIT-C) " " FUNCTION TRIM(WS-EDIT-A) "," FUNCTION TRIM(WS-EDIT-B) DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
         MOVE WS-TEXT TO TL-OBSERVED
         EVALUATE WS-I
             WHEN 1
                 MOVE "1 -13,-106" TO TL-EXPECTED
             WHEN 2
                 MOVE "1 121,52" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "1 -92,69" TO TL-EXPECTED
         END-EVALUATE
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "N" TO TL-MODE

*>   the locate position of the nearest chunk: (16 cx + 0, 0, 16 cz + 0) for the stronghold style set
     MOVE 0 TO WS-OX
     MOVE 64 TO WS-OY
     MOVE 0 TO WS-OZ
     CALL "STRUCT-NEAREST-RING" USING WS-SET WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§3.10 eye of ender: the answer is the locate position of the chunk (4.8)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = (WS-X - WS-CX * 16 - SS-LOC-X(WS-SET)) * 100 + (WS-Y - SS-LOC-Y(WS-SET)) * 10 + (WS-Z - WS-CZ * 16 - SS-LOC-Z(WS-SET))
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the model over a grid of origins
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM -3 BY 1 UNTIL WS-I > 3
         PERFORM VARYING WS-J FROM -3 BY 1 UNTIL WS-J > 3
             COMPUTE WS-OX = WS-I * 700 + 13
             COMPUTE WS-OZ = WS-J * 600 - 7
             COMPUTE WS-OY = 40 + WS-I * 9
             CALL "STRUCT-NEAREST-RING" USING WS-SET WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
             MOVE 0 TO WS-BX WS-BZ
             MOVE 9223372036854775807 TO WS-BEST
             PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > SR-N(SS-RING-ROW(WS-SET))
                 COMPUTE WS-DX = SR-X(SS-RING-ROW(WS-SET), WS-N) * 16 + 8 - WS-OX
                 COMPUTE WS-DY = 32 - WS-OY
                 COMPUTE WS-DZ = SR-Z(SS-RING-ROW(WS-SET), WS-N) * 16 + 8 - WS-OZ
                 COMPUTE WS-D = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
                 IF WS-D < WS-BEST
                     MOVE WS-D TO WS-BEST
                     MOVE SR-X(SS-RING-ROW(WS-SET), WS-N) TO WS-BX
                     MOVE SR-Z(SS-RING-ROW(WS-SET), WS-N) TO WS-BZ
                 END-IF
             END-PERFORM
             IF WS-FOUND NOT = 1 OR WS-CX NOT = WS-BX OR WS-CZ NOT = WS-BZ
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-5§3.10 eye of ender: 49 origins agree with the brute force model" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a set that is not a concentric_rings set, and the by-name lookup
     MOVE 1 TO WS-I
     CALL "STRUCT-NEAREST-RING" USING WS-I WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§3.10 eye of ender: a random_spread set has no ring list: not found" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ring_set" TO WS-NAME
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§3.10 eye of ender: the lookup by the name ring_set finds the ring set" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "nothing_like_it" TO WS-NAME
     CALL "STRUCT-NEAREST-NAMED" USING WS-NAME WS-SEED WS-OX WS-OY WS-OZ WS-FOUND WS-CX WS-CZ WS-X WS-Y WS-Z
     MOVE "acceptance US12 36-5§3.10 eye of ender: an unknown name is not found" TO TL-CASE
     MOVE WS-FOUND TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-EYE.
