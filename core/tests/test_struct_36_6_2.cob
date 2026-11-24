*> Acceptance test of the shared definitions of the three ocean generators (docs/protocol/36-structures-6-ocean.md section 2): 2.1 the Java LCG primitives (next(bits), nextInt of a power of two and of other bounds, nextLong, nextFloat
*> and the bit of next(1), against the model values of core/tests/fixtures/gen_oceanruin.py's LCG for seed 12345), getSeed(1, 2, 3) = -33674130277896, setLargeFeatureSeed(0, 1, 0) then next(32) = 1118589937 (the document's
*> checks), Mth.nextInt(lo, hi), the per-position stream and getRandomPalette (LCG(getSeed(pos)).nextInt(palettes)); 2.2 the rotation table for the pivots (0, 0) and (4, 15) and the box of a template piece (the per-axis min and
*> max of the transformed corners, moved by the position) for the ruin size 6 x 7 x 7 and the shipwreck size 9 x 21 x 28.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-6-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY STRUCTPIECE.
 01 WS-STATE               BINARY-DOUBLE UNSIGNED.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 12345.
 01 WS-SEED0               BINARY-DOUBLE UNSIGNED VALUE 0.
 01 WS-SEED7               BINARY-DOUBLE UNSIGNED VALUE 777.
 01 WS-R                   BINARY-DOUBLE.
 01 WS-U                   BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-D                   FLOAT-LONG.
 01 WS-BITS                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-OZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-MIRROR              BINARY-LONG VALUE 0.
 01 WS-ROT                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-NAME                PIC X(160).
 01 WS-DS                  PIC 9.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-BXX                 BINARY-LONG.
 01 WS-BZZ                 BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-PAL                 BINARY-LONG.
 01 WS-EIGHT               BINARY-LONG VALUE 8.
 01 WS-BOX.
    COPY STRUCTBOX REPLACING LEADING ==BX-== BY ==B-==.
 01 WS-PTS.
    05 FILLER              PIC X(16) VALUE "+003+005-002+007".
    05 FILLER              PIC X(16) VALUE "+000+000+005-004".
 01 WS-PT-TAB REDEFINES WS-PTS.
    05 WS-PT OCCURS 4 TIMES.
       10 WS-PT-V          PIC S999 SIGN LEADING SEPARATE.
 01 WS-BIG                 BINARY-LONG VALUE 100.
 01 WS-PALS.
    05 FILLER              PIC X(22) VALUE "+010+040-003+000000004".
    05 FILLER              PIC X(22) VALUE "-007+055+100+000000003".
    05 FILLER              PIC X(22) VALUE "+000+000+000+000000005".
    05 FILLER              PIC X(22) VALUE "+123-005+456+000000006".
    05 FILLER              PIC X(22) VALUE "+003+070-090+000000005".
 01 WS-PAL-TAB REDEFINES WS-PALS.
    05 WS-PL OCCURS 5 TIMES.
       10 WS-PL-X          PIC S999 SIGN LEADING SEPARATE.
       10 WS-PL-Y          PIC S999 SIGN LEADING SEPARATE.
       10 WS-PL-Z          PIC S999 SIGN LEADING SEPARATE.
       10 FILLER           PIC X(4).
       10 WS-PL-I          PIC 9(6).
 01 WS-NINETY              BINARY-LONG VALUE 90.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
*>   2.1: next(bits), the bound draws and nextLong of the LCG seeded with 12345
     CALL "JRAND-SET-SEED" USING WS-STATE WS-SEED
     MOVE 32 TO WS-BITS
     CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-R
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: next(32) of LCG(12345) is the model's signed value" TO TL-CASE
     MOVE 1553932502 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 31 TO WS-BITS
     CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-R
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: next(31) is the next 31 top bits" TO TL-CASE
     MOVE 1102109080 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-V
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextInt(4) (a power of two: (bound * next(31)) >> 31) matches the model" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 20 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-V
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextInt(20) (the rejection loop on next(31) % bound) matches the model" TO TL-CASE
     MOVE 8 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-V
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextInt(3) matches the model" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 7 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-STATE WS-BOUND WS-V
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextInt(7) matches the model" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-NEXT-LONG" USING WS-STATE WS-U
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextLong is (next(32) << 32) + next(32) with the low word sign-extended" TO TL-CASE
     MOVE 6022414958441676900 TO TL-EXPECTED-N
     MOVE WS-U TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "JRAND-NEXT-FLOAT" USING WS-STATE WS-F
     COMPUTE WS-D = WS-F - 0.2355237603187561
     IF WS-D < 0
         COMPUTE WS-D = 0 - WS-D
     END-IF
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextFloat is next(24) * 5.9604645E-8 (0.23552376 for the model's draw)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-D < 0.000000001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-BITS
     CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-R
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: nextBoolean is next(1) != 0 (false for the model's draw)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   getSeed(1, 2, 3) and setLargeFeatureSeed(0, 1, 0), the checks of the document
     MOVE 1 TO WS-X
     MOVE 2 TO WS-Y
     MOVE 3 TO WS-Z
     CALL "XORO-GET-SEED" USING WS-X WS-Y WS-Z WS-R
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: getSeed(1, 2, 3) = -33674130277896" TO TL-CASE
     MOVE -33674130277896 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-STATE WS-SEED0 WS-CX WS-CZ
     MOVE 32 TO WS-BITS
     CALL "JRAND-NEXT" USING WS-STATE WS-BITS WS-R
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: setLargeFeatureSeed(0, 1, 0) then next(32) = 1118589937" TO TL-CASE
     MOVE 1118589937 TO TL-EXPECTED-N
     MOVE WS-R TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Mth.nextInt(r, lo, hi) over LCG(777): both ends inclusive
     CALL "JRAND-SET-SEED" USING SP-RNG WS-SEED7
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
         EVALUATE WS-I
             WHEN 1 MOVE 1 TO WS-LO MOVE 8 TO WS-HI MOVE 6 TO WS-K
             WHEN 2 MOVE 4 TO WS-LO MOVE 8 TO WS-HI MOVE 5 TO WS-K
             WHEN 3 MOVE 1 TO WS-LO MOVE 7 TO WS-HI MOVE 4 TO WS-K
             WHEN 4 MOVE 3 TO WS-LO MOVE 8 TO WS-HI MOVE 3 TO WS-K
             WHEN 5 MOVE 4 TO WS-LO MOVE 6 TO WS-HI MOVE 6 TO WS-K
             WHEN 6 MOVE 1 TO WS-LO MOVE 8 TO WS-HI MOVE 1 TO WS-K
             WHEN OTHER MOVE 1 TO WS-LO MOVE 7 TO WS-HI MOVE 7 TO WS-K
         END-EVALUATE
         CALL "STRUCT-RUIN-DRAW" USING WS-LO WS-HI WS-V
         IF WS-V NOT = WS-K
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§2.1 Random sources and draw primitives: Mth.nextInt(lo, hi) draws nextInt(hi - lo + 1) + lo (seven draws of the model)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.3: getRandomPalette is LCG(getSeed(pos)).nextInt(palettes)
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         MOVE WS-PL-X(WS-I) TO WS-X
         MOVE WS-PL-Y(WS-I) TO WS-Y
         MOVE WS-PL-Z(WS-I) TO WS-Z
         CALL "STRUCT-PALETTE-PICK" USING WS-EIGHT WS-X WS-Y WS-Z WS-PAL
         IF WS-PAL NOT = WS-PL-I(WS-I)
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-6§2.3 What a template piece does when it is placed: a template of 8 palettes uses the palette LCG(getSeed(templatePosition)).nextInt(8) (five positions of the model)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   2.2: the rotation table, pivots (0, 0) and (4, 15), and the box of a template piece
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         IF WS-K = 1
             MOVE 0 TO WS-PX WS-PZ
         ELSE
             MOVE 4 TO WS-PX
             MOVE 15 TO WS-PZ
         END-IF
         PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
             PERFORM VARYING WS-I FROM 1 BY 2 UNTIL WS-I > 3
                 MOVE WS-PT-V(WS-I) TO WS-WX
                 COMPUTE WS-J = WS-I + 1
                 MOVE WS-PT-V(WS-J) TO WS-WZ
                 MOVE 0 TO WS-Y
                 MOVE WS-WX TO WS-X
                 MOVE WS-WZ TO WS-Z
                 CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ
                 EVALUATE WS-ROT
                     WHEN 0
                         COMPUTE WS-MX = WS-WX
                         COMPUTE WS-MZ = WS-WZ
                     WHEN 1
                         COMPUTE WS-MX = WS-PX + WS-PZ - WS-WZ
                         COMPUTE WS-MZ = WS-PZ - WS-PX + WS-WX
                     WHEN 2
                         COMPUTE WS-MX = 2 * WS-PX - WS-WX
                         COMPUTE WS-MZ = 2 * WS-PZ - WS-WZ
                     WHEN OTHER
                         COMPUTE WS-MX = WS-PX - WS-PZ + WS-WZ
                         COMPUTE WS-MZ = WS-PX + WS-PZ - WS-WX
                 END-EVALUATE
                 IF WS-OX NOT = WS-MX OR WS-OZ NOT = WS-MZ OR WS-OY NOT = 0
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§2.2 Rotating a position, and the box of a template piece: the four rotations of two points at the pivots (0, 0) and (4, 15) follow the table" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   with the pivot (0, 0): CLOCKWISE_90 gives (-z, x), COUNTERCLOCKWISE_90 gives (z, -x), CLOCKWISE_180 gives (-x, -z)
     MOVE 0 TO WS-PX WS-PZ WS-Y
     MOVE 3 TO WS-X
     MOVE 5 TO WS-Z
     MOVE 1 TO WS-ROT
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-6§2.2 Rotating a position, and the box of a template piece: with the pivot (0, 0) CLOCKWISE_90 maps (3, 5) to (-5, 3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OX = -5 AND WS-OZ = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3 TO WS-ROT
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-6§2.2 Rotating a position, and the box of a template piece: with the pivot (0, 0) COUNTERCLOCKWISE_90 maps (3, 5) to (5, -3)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OX = 5 AND WS-OZ = -3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-ROT
     CALL "STRUCT-TX-POS" USING WS-X WS-Y WS-Z WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ
     MOVE "acceptance US12 36-6§2.2 Rotating a position, and the box of a template piece: with the pivot (0, 0) CLOCKWISE_180 maps (3, 5) to (-3, -5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OX = -3 AND WS-OZ = -5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   the box of a piece: the ruin size 6 x 7 x 7 (pivot 0, 0) and the shipwreck size 9 x 21 x 28 (pivot 4, 15) at the position (10, 50, -20), every rotation
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 2
         IF WS-K = 1
             MOVE 0 TO WS-PX WS-PZ
             MOVE 6 TO WS-SX
             MOVE 7 TO WS-SY WS-SZ
         ELSE
             MOVE 4 TO WS-PX
             MOVE 15 TO WS-PZ
             MOVE 9 TO WS-SX
             MOVE 21 TO WS-SY
             MOVE 28 TO WS-SZ
         END-IF
         PERFORM VARYING WS-ROT FROM 0 BY 1 UNTIL WS-ROT > 3
             MOVE 10 TO WS-OX
             MOVE 50 TO WS-OY
             MOVE -20 TO WS-OZ
             CALL "STRUCT-TX-BOX" USING WS-SX WS-SY WS-SZ WS-MIRROR WS-ROT WS-PX WS-PZ WS-OX WS-OY WS-OZ WS-BOX
             MOVE 0 TO WS-WX WS-WZ
             PERFORM CORNER
             MOVE WS-MX TO WS-AX
             MOVE WS-MZ TO WS-AZ
             COMPUTE WS-WX = WS-SX - 1
             COMPUTE WS-WZ = WS-SZ - 1
             PERFORM CORNER
             IF B-X0 NOT = FUNCTION MIN(WS-AX, WS-MX) + 10 OR B-X1 NOT = FUNCTION MAX(WS-AX, WS-MX) + 10
                OR B-Z0 NOT = FUNCTION MIN(WS-AZ, WS-MZ) - 20 OR B-Z1 NOT = FUNCTION MAX(WS-AZ, WS-MZ) - 20
                OR B-Y0 NOT = 50 OR B-Y1 NOT = 50 + WS-SY - 1
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-6§2.2 Rotating a position, and the box of a template piece: the box is the per-axis min and max of the two transformed corners moved by the position (both sizes, all rotations)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> (WS-MX, WS-MZ): the table of 2.2 for (WS-WX, WS-WZ), the rotation WS-ROT and the pivot (WS-PX, WS-PZ)
 CORNER.
     EVALUATE WS-ROT
         WHEN 0
             MOVE WS-WX TO WS-MX
             MOVE WS-WZ TO WS-MZ
         WHEN 1
             COMPUTE WS-MX = WS-PX + WS-PZ - WS-WZ
             COMPUTE WS-MZ = WS-PZ - WS-PX + WS-WX
         WHEN 2
             COMPUTE WS-MX = 2 * WS-PX - WS-WX
             COMPUTE WS-MZ = 2 * WS-PZ - WS-WZ
         WHEN OTHER
             COMPUTE WS-MX = WS-PX - WS-PZ + WS-WZ
             COMPUTE WS-MZ = WS-PX + WS-PZ - WS-WX
     END-EVALUATE.

 END PROGRAM TEST-STRUCT-36-6-2.
 COPY CORETEST.
