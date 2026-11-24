*> Test of the nether fossil (core/src/nether-37-6e.cob; T1713; docs/protocol/37-nether-6 section 7 with 37-5 section 6 and 36-4 section 9): the generation point (x then z, then the height draw 32 to 125,
*> the downward scan for an air cell over soul sand or a sturdy top, no start at or under the sea level 32), the rotation and template draws (nextInt(4), then nextInt(14)), the fourteen templates and
*> the dried ghast step (a legacy positional random of the world seed at the box centre: a 50 percent gate, then x and z in the box, then a rotation). Expected values are from an independent
*> implementation of java.util.Random, setLargeFeatureSeed and Mth.getSeed (fossil_model.py, the doc's getSeed(1, 2, 3) = -33674130277896 checked).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-NETHER-37-6-7.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 01 WS-SEED                BINARY-DOUBLE SIGNED.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-COLUMN              PIC X(128).
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-ROT                 BINARY-LONG.
 01 WS-TPL                 BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-BONES               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-XS                  BINARY-LONG.
 01 WS-ZS                  BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 01 WS-V                   BINARY-DOUBLE SIGNED.
 01 WS-EXPECT              BINARY-DOUBLE SIGNED.
 01 WS-CASE                PIC X(200).
 01 WS-D1                  PIC 9.
 01 WS-D2                  PIC 99.
 01 WS-N                   PIC -(8)9.
 01 WS-N2                  PIC -(8)9.
 01 WS-N3                  PIC -(8)9.
 01 WS-N4                  PIC -(8)9.
 01 WS-POINTS.
*>   seed, chunk x, chunk z, column kind, then the model's x y z rotation template (valid 0 when all are 0)
    05 FILLER PIC X(60) VALUE "+000000012345 +0000 +0000 0 +00005 +059 +00008 3 10".
    05 FILLER PIC X(60) VALUE "+000000012345 +0003 -0002 0 +00048 +059 -00024 3 14".
    05 FILLER PIC X(60) VALUE "+000000012345 -0005 +0007 1 -00072 +044 +00115 3 08".
    05 FILLER PIC X(60) VALUE "+000000012345 +0010 +0010 1 +00171 +044 +00164 0 13".
    05 FILLER PIC X(60) VALUE "+000000012345 +0030 -0030 1 +00492 +044 -00479 0 09".
    05 FILLER PIC X(60) VALUE "+000000012345 +0001 +0001 2 +00000 +000 +00000 0 00".
    05 FILLER PIC X(60) VALUE "+000000012345 +0002 +0002 3 +00000 +000 +00000 0 00".
    05 FILLER PIC X(60) VALUE "+000000012345 -0001 -0001 0 +00000 +000 +00000 0 00".
    05 FILLER PIC X(60) VALUE "-000000000001 +0000 +0000 0 +00004 +059 +00007 2 07".
    05 FILLER PIC X(60) VALUE "-000000000001 +0003 -0002 0 +00050 +059 -00018 0 13".
    05 FILLER PIC X(60) VALUE "-000000000001 -0005 +0007 1 +00000 +000 +00000 0 00".
    05 FILLER PIC X(60) VALUE "-000000000001 +0010 +0010 1 +00170 +044 +00164 2 13".
    05 FILLER PIC X(60) VALUE "-000000000001 -0001 -0001 0 -00001 +059 -00013 2 07".
    05 FILLER PIC X(60) VALUE "-000000000001 +0030 -0030 1 +00000 +000 +00000 0 00".
    05 FILLER PIC X(60) VALUE "+000987654321 +0000 +0000 0 +00004 +059 +00014 0 13".
    05 FILLER PIC X(60) VALUE "+000987654321 +0003 -0002 0 +00052 +059 -00032 0 13".
    05 FILLER PIC X(60) VALUE "+000987654321 -0005 +0007 1 -00073 +044 +00119 1 13".
    05 FILLER PIC X(60) VALUE "+000987654321 +0010 +0010 1 +00161 +044 +00171 0 02".
    05 FILLER PIC X(60) VALUE "+000987654321 -0001 -0001 0 -00010 +059 -00008 2 10".
    05 FILLER PIC X(60) VALUE "+000987654321 +0030 -0030 1 +00483 +044 -00465 3 02".
 01 WS-POINTS-T REDEFINES WS-POINTS.
    05 WS-PT OCCURS 20 TIMES.
       10 PT-SEED          PIC S9(12) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 PT-CX            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 PT-CZ            PIC S9(4) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 PT-KIND          PIC 9.
       10 FILLER           PIC X.
       10 PT-X             PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 PT-Y             PIC S9(3) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 PT-Z             PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 PT-ROT           PIC 9.
       10 FILLER           PIC X.
       10 PT-TPL           PIC 99.
       10 FILLER           PIC X(9).
 01 WS-GHASTS.
*>   seed, box min x y z, x span, z span, centre x y z, then the model's placed flag and x y z rotation
    05 FILLER PIC X(100) VALUE "+000000012345 +00010 +040 +00020 5 5 +00012 +040 +00022 1 +00013 +040 +00022 0".
    05 FILLER PIC X(100) VALUE "+000000012345 -00033 +050 +00070 7 6 -00030 +050 +00073 0 +00000 +000 +00000 0".
    05 FILLER PIC X(100) VALUE "+000000012345 +00000 +036 +00000 3 5 +00001 +036 +00002 1 +00001 +036 +00003 3".
    05 FILLER PIC X(100) VALUE "+000000012345 +00100 +090 -00100 4 3 +00102 +090 -00099 1 +00103 +090 -00100 2".
    05 FILLER PIC X(100) VALUE "-000000000001 +00010 +040 +00020 5 5 +00012 +040 +00022 0 +00000 +000 +00000 0".
    05 FILLER PIC X(100) VALUE "-000000000001 +00000 +036 +00000 3 5 +00001 +036 +00002 1 +00001 +036 +00003 0".
    05 FILLER PIC X(100) VALUE "+000987654321 -00033 +050 +00070 7 6 -00030 +050 +00073 1 -00030 +050 +00075 1".
    05 FILLER PIC X(100) VALUE "+000987654321 +00010 +040 +00020 5 5 +00012 +040 +00022 0 +00000 +000 +00000 0".
 01 WS-GHASTS-T REDEFINES WS-GHASTS.
    05 WS-GH OCCURS 8 TIMES.
       10 GH-SEED          PIC S9(12) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-BX            PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-BY            PIC S9(3) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-BZ            PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-XS            PIC 9.
       10 FILLER           PIC X.
       10 GH-ZS            PIC 9.
       10 FILLER           PIC X.
       10 GH-MX            PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-MY            PIC S9(3) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-MZ            PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-PLACED        PIC 9.
       10 FILLER           PIC X.
       10 GH-X             PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-Y             PIC S9(3) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-Z             PIC S9(5) SIGN LEADING SEPARATE.
       10 FILLER           PIC X.
       10 GH-ROT           PIC 9.
       10 FILLER           PIC X(22).
 01 WS-TEMPLATES.
*>   size x y z, bone blocks (37-5 section 6 table)
    05 FILLER PIC X(9) VALUE "4 4 5 10|".
    05 FILLER PIC X(9) VALUE "5 1 5 10|".
    05 FILLER PIC X(9) VALUE "3 4 2 06|".
    05 FILLER PIC X(9) VALUE "3 4 1 06|".
    05 FILLER PIC X(9) VALUE "2 5 1 05|".
    05 FILLER PIC X(9) VALUE "7 5 5 21|".
    05 FILLER PIC X(9) VALUE "4 6 5 18|".
    05 FILLER PIC X(9) VALUE "3 5 1 06|".
    05 FILLER PIC X(9) VALUE "3 5 5 15|".
    05 FILLER PIC X(9) VALUE "3 7 1 08|".
    05 FILLER PIC X(9) VALUE "5 5 7 24|".
    05 FILLER PIC X(9) VALUE "4 4 3 11|".
    05 FILLER PIC X(9) VALUE "4 5 6 17|".
    05 FILLER PIC X(9) VALUE "7 7 6 26|".
 01 WS-TEMPLATES-T REDEFINES WS-TEMPLATES.
    05 WS-TP OCCURS 14 TIMES.
       10 TP-SX            PIC 9.
       10 FILLER           PIC X.
       10 TP-SY            PIC 9.
       10 FILLER           PIC X.
       10 TP-SZ            PIC 9.
       10 FILLER           PIC X.
       10 TP-BONES         PIC 99.
       10 FILLER           PIC X.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM POINT-CASES
     PERFORM TEMPLATE-CASES
     PERFORM GHAST-CASES
     GOBACK.

 CHECK-V.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§7 The nether fossil: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-V TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> columns: 0 soul sand at y 59 under air from 60, 1 a sturdy block at y 44 under air from 45, 2 air everywhere above y 32, 3 solid everywhere
 BUILD-COLUMN.
     MOVE ALL "X" TO WS-COLUMN
     EVALUATE WS-KIND
         WHEN 0
             MOVE ALL "A" TO WS-COLUMN(61:68)
             MOVE "S" TO WS-COLUMN(60:1)
         WHEN 1
             MOVE ALL "A" TO WS-COLUMN(46:83)
             MOVE "T" TO WS-COLUMN(45:1)
         WHEN 2
             MOVE ALL "A" TO WS-COLUMN(34:95)
     END-EVALUATE.

 POINT-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 20
         MOVE PT-SEED(WS-I) TO WS-SEED
         MOVE PT-CX(WS-I) TO WS-CX
         MOVE PT-CZ(WS-I) TO WS-CZ
         MOVE PT-KIND(WS-I) TO WS-KIND
         PERFORM BUILD-COLUMN
         CALL "NETHER-FOSSIL-POINT" USING WS-SEED WS-CX WS-CZ WS-COLUMN WS-X WS-Y WS-Z WS-ROT WS-TPL WS-VALID
         MOVE WS-CX TO WS-N
         MOVE WS-CZ TO WS-N2
         MOVE PT-KIND(WS-I) TO WS-D1
         MOVE SPACES TO WS-CASE
         STRING "chunk (" FUNCTION TRIM(WS-N) ", " FUNCTION TRIM(WS-N2) ") column " WS-D1 " seed " PT-SEED(WS-I) DELIMITED BY SIZE INTO WS-CASE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         IF PT-TPL(WS-I) = 0
             MOVE "none" TO TL-EXPECTED
         ELSE
             MOVE PT-X(WS-I) TO WS-N
             MOVE PT-Y(WS-I) TO WS-N2
             MOVE PT-Z(WS-I) TO WS-N3
             MOVE PT-ROT(WS-I) TO WS-D1
             MOVE PT-TPL(WS-I) TO WS-D2
             STRING FUNCTION TRIM(WS-N) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " rot " WS-D1 " tpl " WS-D2 DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         IF WS-VALID = 0
             MOVE "none" TO TL-OBSERVED
         ELSE
             MOVE WS-X TO WS-N
             MOVE WS-Y TO WS-N2
             MOVE WS-Z TO WS-N3
             MOVE WS-ROT TO WS-D1
             MOVE WS-TPL TO WS-D2
             STRING FUNCTION TRIM(WS-N) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " rot " WS-D1 " tpl " WS-D2 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         PERFORM CHECK-TEXT
     END-PERFORM.

 CHECK-TEXT.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US12 37-6§7 The nether fossil: " FUNCTION TRIM(WS-CASE) DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE.

 TEMPLATE-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 15
         MOVE WS-I TO WS-TPL
         CALL "NETHER-FOSSIL-TEMPLATE" USING WS-TPL WS-SX WS-SY WS-SZ WS-BONES
         MOVE WS-I TO WS-D2
         MOVE SPACES TO WS-CASE
         STRING "template fossil_" WS-D2 " size and bone blocks" DELIMITED BY SIZE INTO WS-CASE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         IF WS-I = 15
             MOVE "0 0 0 0" TO TL-EXPECTED
         ELSE
             STRING TP-SX(WS-I) " " TP-SY(WS-I) " " TP-SZ(WS-I) " " TP-BONES(WS-I) DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         MOVE WS-SX TO WS-N
         MOVE WS-SY TO WS-N2
         MOVE WS-SZ TO WS-N3
         MOVE WS-BONES TO WS-N4
         STRING FUNCTION TRIM(WS-N) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " " FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO TL-OBSERVED
         IF WS-I NOT = 15
             MOVE SPACES TO TL-EXPECTED
             MOVE TP-SX(WS-I) TO WS-N
             MOVE TP-SY(WS-I) TO WS-N2
             MOVE TP-SZ(WS-I) TO WS-N3
             MOVE TP-BONES(WS-I) TO WS-N4
             STRING FUNCTION TRIM(WS-N) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " " FUNCTION TRIM(WS-N4) DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         PERFORM CHECK-TEXT
     END-PERFORM.

 GHAST-CASES.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 8
         MOVE GH-SEED(WS-I) TO WS-SEED
         MOVE GH-BX(WS-I) TO WS-BX
         MOVE GH-BY(WS-I) TO WS-BY
         MOVE GH-BZ(WS-I) TO WS-BZ
         MOVE GH-XS(WS-I) TO WS-XS
         MOVE GH-ZS(WS-I) TO WS-ZS
         MOVE GH-MX(WS-I) TO WS-MX
         MOVE GH-MY(WS-I) TO WS-MY
         MOVE GH-MZ(WS-I) TO WS-MZ
         CALL "NETHER-FOSSIL-GHAST" USING WS-SEED WS-BX WS-BY WS-BZ WS-XS WS-ZS WS-MX WS-MY WS-MZ WS-PLACED WS-X WS-Y WS-Z WS-ROT
         MOVE WS-I TO WS-D2
         MOVE SPACES TO WS-CASE
         STRING "dried ghast case " WS-D2 " (gate, x and z in the box, rotation)" DELIMITED BY SIZE INTO WS-CASE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         IF GH-PLACED(WS-I) = 0
             MOVE "none" TO TL-EXPECTED
         ELSE
             MOVE GH-X(WS-I) TO WS-N
             MOVE GH-Y(WS-I) TO WS-N2
             MOVE GH-Z(WS-I) TO WS-N3
             MOVE GH-ROT(WS-I) TO WS-D1
             STRING FUNCTION TRIM(WS-N) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " rot " WS-D1 DELIMITED BY SIZE INTO TL-EXPECTED
         END-IF
         IF WS-PLACED = 0
             MOVE "none" TO TL-OBSERVED
         ELSE
             MOVE WS-X TO WS-N
             MOVE WS-Y TO WS-N2
             MOVE WS-Z TO WS-N3
             MOVE WS-ROT TO WS-D1
             STRING FUNCTION TRIM(WS-N) " " FUNCTION TRIM(WS-N2) " " FUNCTION TRIM(WS-N3) " rot " WS-D1 DELIMITED BY SIZE INTO TL-OBSERVED
         END-IF
         PERFORM CHECK-TEXT
     END-PERFORM.
 END PROGRAM TEST-NETHER-37-6-7.
