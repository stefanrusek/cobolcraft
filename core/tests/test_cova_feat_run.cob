*> Implementation test (coverage lane A; docs/protocol/35-worldgen-features-4 section 2.2; core/src/feat-run.cob FR-INT-SAMPLE): the trapezoid int provider with a plateau that is neither
*> the whole span nor zero-centred (min + nextInt(side + 1) + nextInt(slope + 1)) stays within its bounds and reaches both halves of the span over many seeds.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-FEAT-RUN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY FEATDATA.
 COPY XORO.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-P.
    05 WS-V                BINARY-LONG OCCURS 4 TIMES.
 01 WS-VALUE               BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE 5 TO WS-V(1)
     MOVE 0 TO WS-V(2)
     MOVE 10 TO WS-V(3)
     MOVE 4 TO WS-V(4)
     MOVE 0 TO WS-BAD WS-LOW WS-HIGH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 200
         MOVE WS-I TO WS-SEED
         CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
         CALL "FR-INT-SAMPLE" USING XR-STATE WS-P WS-VALUE
         IF WS-VALUE < 0 OR WS-VALUE > 10
             ADD 1 TO WS-BAD
         END-IF
         IF WS-VALUE <= 3
             ADD 1 TO WS-LOW
         END-IF
         IF WS-VALUE >= 7
             ADD 1 TO WS-HIGH
         END-IF
     END-PERFORM
     MOVE "test cova feat run a trapezoid 0 to 10 with plateau 4 never leaves 0 to 10" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-BAD TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     MOVE "test cova feat run the trapezoid reaches both ends of its span" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-LOW > 0 AND WS-HIGH > 0
         MOVE 1 TO WS-O
     END-IF
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-FEAT-RUN.
 COPY COVATEST.
