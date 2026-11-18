*> Acceptance test of docs/protocol/36-structures-5-mineshaft-stronghold.md sections 3.1 and 4.1 (placement recap and ring sizes, T1508 and T1528): the raw ring list of
*> distance 32, spread 3, count 128 at seed 0 (STRUCT-RINGS-RAW) has 128 chunks; the ring of each position (found from its distance to the origin: ring r lies at 128 + 192 r
*> chunks, jittered by at most 40) gives the sizes 3, 6, 10, 15, 21, 28, 36 and 9 (cumulative 3, 9, 19, 34, 55, 83, 119, 128); the radii of the positions 0 to 4 are those of 4.1
*> (107.2429, 132.0349, 114.6574, 350.3346, 301.9963 chunks, each within one chunk of the distance of the rounded chunk) and the raw chunks are (-13,-106), (121,52), (-92,69),
*> (-75,-342), (223,-203). The ring sizes are also derived by the recurrence S(r+1) = S(r) + 2 S(r) / (r + 2), capped by 128 - i, in this test (the document's rule).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-5-4-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-DISTANCE            BINARY-LONG VALUE 32.
 01 WS-SPREAD              BINARY-LONG VALUE 3.
 01 WS-NUM                 BINARY-LONG VALUE 128.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-RAW.
    05 WS-RAW-ROW OCCURS 256 TIMES.
       10 WS-RAW-X         BINARY-LONG.
       10 WS-RAW-Z         BINARY-LONG.
       10 WS-RAW-SEED      BINARY-DOUBLE UNSIGNED.
 01 WS-I                   BINARY-LONG.
 01 WS-RING                BINARY-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-DIST                BINARY-DOUBLE.
 01 WS-X2                  BINARY-DOUBLE.
 01 WS-Z2                  BINARY-DOUBLE.
 01 WS-SUM                 BINARY-DOUBLE.
 01 WS-COUNTS.
    05 WS-N                BINARY-LONG OCCURS 12 TIMES.
 01 WS-MODEL.
    05 WS-M                BINARY-LONG OCCURS 12 TIMES.
 01 WS-S                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-LEFT                BINARY-LONG.
 01 WS-ADD                 BINARY-LONG.
 01 WS-R1                  BINARY-LONG.
 01 WS-TEXT                PIC X(60).
 01 WS-PTR                 BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-EDZ                 PIC -(9)9.
 01 WS-BAD                 BINARY-LONG.
 01 WS-WANT-R.
    05 WS-WR               BINARY-LONG OCCURS 5 TIMES.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "STRUCT-RINGS-RAW" USING WS-DISTANCE WS-SPREAD WS-NUM WS-USEED WS-RAW
     INITIALIZE WS-COUNTS
*>   the ring of each position by its distance from the origin: round((d - 128) / 192)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 128
         COMPUTE WS-X2 = WS-RAW-X(WS-I) * WS-RAW-X(WS-I)
         COMPUTE WS-Z2 = WS-RAW-Z(WS-I) * WS-RAW-Z(WS-I)
         COMPUTE WS-D = FUNCTION SQRT(WS-X2 + WS-Z2)
         COMPUTE WS-DIST = WS-D * 1000
         COMPUTE WS-RING = (WS-DIST - 128000 + 96000) / 192000
         IF WS-RING < 0
             MOVE 0 TO WS-RING
             ADD 1 TO WS-BAD
         END-IF
         IF WS-RING > 7
             MOVE 7 TO WS-RING
             ADD 1 TO WS-BAD
         END-IF
         COMPUTE WS-R = 128000 + 192000 * WS-RING
         IF WS-DIST < WS-R - 41000 OR WS-DIST > WS-R + 41000
             ADD 1 TO WS-BAD
         END-IF
         ADD 1 TO WS-N(WS-RING + 1)
     END-PERFORM
     MOVE "acceptance US12 36-5§3.1 Placement recap: every position of the 128 lies within 40 chunks (41 after rounding) of the radius 128 + 192 r of its ring" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the recurrence of 3.1
     INITIALIZE WS-MODEL
     MOVE 3 TO WS-S
     MOVE 0 TO WS-RING WS-POS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= 128
         ADD 1 TO WS-M(WS-RING + 1)
         ADD 1 TO WS-POS
         IF WS-POS = WS-S
             ADD 1 TO WS-RING
             MOVE 0 TO WS-POS
             COMPUTE WS-R1 = WS-RING + 1
             COMPUTE WS-LEFT = 2 * WS-S
             DIVIDE WS-LEFT BY WS-R1 GIVING WS-ADD
             ADD WS-ADD TO WS-S
             COMPUTE WS-LEFT = 128 - WS-I
             IF WS-LEFT < WS-S
                 MOVE WS-LEFT TO WS-S
             END-IF
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-M(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 36-5§3.1 Placement recap: the ring sizes of the recurrence S(r+1) = S(r) + 2 S(r) / (r + 2), capped by 128 - i, are 3, 6, 10, 15, 21, 28, 36, 9" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "3 6 10 15 21 28 36 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the sizes of the generated list by the radius bands
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE WS-N(WS-I) TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-5§4.1 Ring sizes: the 128 raw chunks of seed 0 fall into rings of 3, 6, 10, 15, 21, 28, 36 and 9 positions in generation order" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "3 6 10 15 21 28 36 9" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the cumulative boundaries 3, 9, 19, 34, 55, 83, 119, 128: the ring index of position i by the band
     MOVE 0 TO WS-SUM
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         ADD WS-N(WS-I) TO WS-SUM
         MOVE WS-SUM TO WS-ED
         STRING FUNCTION TRIM(WS-ED) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-5§4.1 Ring sizes: the cumulative counts are 3, 9, 19, 34, 55, 83, 119, 128" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "3 9 19 34 55 83 119 128" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the first five positions of 4.1
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-RAW-X(WS-I) TO WS-ED
         MOVE WS-RAW-Z(WS-I) TO WS-EDZ
         STRING FUNCTION TRIM(WS-ED) "," FUNCTION TRIM(WS-EDZ) " " DELIMITED BY SIZE INTO WS-TEXT POINTER WS-PTR
     END-PERFORM
     MOVE "acceptance US12 36-5§4.1 Ring sizes: the raw ring chunks of positions 0 to 4 at seed 0 are (-13,-106), (121,52), (-92,69), (-75,-342), (223,-203)" TO TL-CASE
     MOVE WS-TEXT TO TL-OBSERVED
     MOVE "-13,-106 121,52 -92,69 -75,-342 223,-203" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   their radii: 107.2429, 132.0349, 114.6574, 350.3346, 301.9963 (the rounded chunk is within one chunk of the radius)
     MOVE 107243 TO WS-WR(1)
     MOVE 132035 TO WS-WR(2)
     MOVE 114657 TO WS-WR(3)
     MOVE 350335 TO WS-WR(4)
     MOVE 301996 TO WS-WR(5)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         COMPUTE WS-X2 = WS-RAW-X(WS-I) * WS-RAW-X(WS-I)
         COMPUTE WS-Z2 = WS-RAW-Z(WS-I) * WS-RAW-Z(WS-I)
         COMPUTE WS-D = FUNCTION SQRT(WS-X2 + WS-Z2)
         COMPUTE WS-DIST = WS-D * 1000
         IF WS-DIST < WS-WR(WS-I) - 1000 OR WS-DIST > WS-WR(WS-I) + 1000
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acceptance US12 36-5§4.1 Ring sizes: the radii of positions 0 to 4 are 107.2429, 132.0349, 114.6574, 350.3346 and 301.9963 chunks (position 3 opens ring 1 with base radius 320)" TO TL-CASE
     MOVE WS-BAD TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-5-4-1.
