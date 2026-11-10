*> Regression and timing test of CLIMATE-FIND over the full overworld list (core/src/climate.cob, core/src/climate-overworld.cob; the cost
*> work of the world generation lane): the 7594 points of OVB-BUILD, 600 lookups of targets that walk through the climate space
*> (small steps, the depth cycling over 0, 0.5, 1.0 and 1.1 quantised, so a lookup is near the previous one as along a chunk), each
*> equal in index, biome and fitness to a plain scan of every point in order (a tie keeps the earlier point), and the lookups are at
*> least 3 times faster than that plain scan. The two times (hundredths of a second) are printed as evidence.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CLIMATE-FIND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CLIMATE.
 01 WS-TARGET.
    05 WS-T                BINARY-DOUBLE OCCURS 6 TIMES.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BIOME               PIC X(40).
 01 WS-FITNESS             BINARY-DOUBLE.
 01 WS-REF-INDEX           BINARY-LONG.
 01 WS-REF-FITNESS         BINARY-DOUBLE.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-D                   BINARY-DOUBLE.
 01 WS-F                   BINARY-DOUBLE.
 01 WS-SEED                BINARY-DOUBLE VALUE 12345.
 01 WS-STEP                BINARY-DOUBLE.
 01 WS-BAD                 BINARY-LONG.
 01 WS-DEPTHS.
    05 WS-DEPTH            BINARY-DOUBLE OCCURS 4 TIMES.
 01 WS-CLOCK.
    05 FILLER              PIC X(8).
    05 WS-HH               PIC 99.
    05 WS-MM               PIC 99.
    05 WS-SS               PIC 99.
    05 WS-CC               PIC 99.
 01 WS-NOW                 BINARY-DOUBLE.
 01 WS-T0                  BINARY-DOUBLE.
 01 WS-REF-TIME            BINARY-DOUBLE.
 01 WS-FIND-TIME           BINARY-DOUBLE.
 01 WS-EDIT                PIC -(9)9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-DEPTH(1)
     MOVE 5000 TO WS-DEPTH(2)
     MOVE 10000 TO WS-DEPTH(3)
     MOVE 11000 TO WS-DEPTH(4)
     CALL "OVB-BUILD"
     MOVE 0 TO WS-BAD
*>   the walk: the same targets are generated for the reference pass and the lookup pass
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         MOVE 0 TO WS-T(WS-K)
     END-PERFORM
     MOVE 0 TO WS-REF-TIME WS-FIND-TIME
     MOVE 12345 TO WS-SEED
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 600
         PERFORM NEXT-TARGET
         PERFORM CLOCK-NOW
         MOVE WS-NOW TO WS-T0
         PERFORM REFERENCE-SCAN
         PERFORM CLOCK-NOW
         COMPUTE WS-REF-TIME = WS-REF-TIME + WS-NOW - WS-T0
         MOVE WS-NOW TO WS-T0
         CALL "CLIMATE-FIND" USING WS-TARGET WS-INDEX WS-BIOME WS-FITNESS
         PERFORM CLOCK-NOW
         COMPUTE WS-FIND-TIME = WS-FIND-TIME + WS-NOW - WS-T0
         IF WS-INDEX NOT = WS-REF-INDEX OR WS-FITNESS NOT = WS-REF-FITNESS OR WS-BIOME NOT = CL-BIOME(WS-REF-INDEX)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "test climate find every lookup equals the plain scan of the 7594 points" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE WS-REF-TIME TO WS-EDIT
     DISPLAY "climate find: plain scan hundredths " WS-EDIT
     MOVE WS-FIND-TIME TO WS-EDIT
     DISPLAY "climate find: CLIMATE-FIND hundredths " WS-EDIT
     MOVE "test climate find is at least 3 times faster than the plain scan" TO TL-CASE
     IF WS-FIND-TIME * 3 <= WS-REF-TIME
         MOVE 1 TO TL-OBSERVED-N
     ELSE
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     MOVE 1 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.

 NEXT-TARGET.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
         COMPUTE WS-SEED = FUNCTION MOD(WS-SEED * 1103515245 + 12345, 2147483648)
         COMPUTE WS-STEP = FUNCTION MOD(WS-SEED / 65536, 601) - 300
         COMPUTE WS-T(WS-K) = WS-T(WS-K) + WS-STEP
         IF WS-T(WS-K) > 10000
             MOVE 10000 TO WS-T(WS-K)
         END-IF
         IF WS-T(WS-K) < -10000
             MOVE -10000 TO WS-T(WS-K)
         END-IF
     END-PERFORM
     MOVE WS-DEPTH(FUNCTION MOD(WS-N / 40, 4) + 1) TO WS-T(5).

*> the six values: temperature, humidity, continentalness, erosion, depth (slot 5, set from the cycle), weirdness
 CLOCK-NOW.
     MOVE FUNCTION CURRENT-DATE TO WS-CLOCK
     COMPUTE WS-NOW = ((WS-HH * 60 + WS-MM) * 60 + WS-SS) * 100 + WS-CC.

 REFERENCE-SCAN.
     MOVE 0 TO WS-REF-INDEX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CL-COUNT
         COMPUTE WS-F = CL-OFFSET(WS-I) * CL-OFFSET(WS-I)
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
             EVALUATE TRUE
                 WHEN WS-T(WS-K) > CL-MAX(WS-I, WS-K)
                     COMPUTE WS-D = WS-T(WS-K) - CL-MAX(WS-I, WS-K)
                 WHEN WS-T(WS-K) < CL-MIN(WS-I, WS-K)
                     COMPUTE WS-D = CL-MIN(WS-I, WS-K) - WS-T(WS-K)
                 WHEN OTHER
                     MOVE 0 TO WS-D
             END-EVALUATE
             COMPUTE WS-F = WS-F + WS-D * WS-D
         END-PERFORM
         IF WS-REF-INDEX = 0 OR WS-F < WS-REF-FITNESS
             MOVE WS-I TO WS-REF-INDEX
             MOVE WS-F TO WS-REF-FITNESS
         END-IF
     END-PERFORM.
