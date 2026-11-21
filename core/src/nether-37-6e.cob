*> The nether fossil (docs/protocol/37-nether-6 section 7, with 37-5 section 6 and 36-4 section 9; T1714): the generation point from the structure's start random (x then z, the height draw 32 to 125,
*> the downward scan over a column the caller classifies, no start at or under the sea level 32), the rotation and template draws, the fourteen templates and the dried ghast step.
*>
*> Entry points:
*>   NETHER-FOSSIL-POINT USING level seed (BINARY-DOUBLE, signed), chunk x, chunk z, column (PIC X(128), the base column's cell at y = 0 to 127: A air, S soul sand, T another block whose top
*>     face is sturdy, X any other), x out, y out (the solid block's y), z out, rotation out (0 to 3, NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90), template out (1 to 14), valid out
*>     (0 when there is no start; rotation and template are then not drawn)
*>   NETHER-FOSSIL-TEMPLATE USING template (1 to 14), size x, size y, size z, bone blocks out (all 0 for another number)
*>   NETHER-FOSSIL-GHAST USING world seed (signed), box min x, y, z, x span, z span, centre x, y, z (BoundingBox.getCenter), placed out (the 50 percent gate), x, y, z out, rotation out (0 to 3)

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FOSSIL-POINT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-BOUND               BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-A                   PIC X.
 01 WS-B                   PIC X.
 01 WS-DONE                BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-COLUMN               PIC X(128).
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 01 L-TEMPLATE             BINARY-LONG.
 01 L-VALID                BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-CX L-CZ L-COLUMN L-X L-Y L-Z L-ROT L-TEMPLATE L-VALID.
     MOVE 0 TO L-VALID L-ROT L-TEMPLATE
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-LARGE-FEATURE-SEED" USING WS-RNG WS-USEED L-CX L-CZ
     MOVE 16 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
     COMPUTE L-X = L-CX * 16 + WS-DRAW
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
     COMPUTE L-Z = L-CZ * 16 + WS-DRAW
     MOVE 94 TO WS-BOUND
     CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
     COMPUTE L-Y = 32 + WS-DRAW
     MOVE 0 TO WS-DONE
     PERFORM UNTIL L-Y <= 32 OR WS-DONE = 1
         COMPUTE WS-INDEX = L-Y + 1
         MOVE L-COLUMN(WS-INDEX:1) TO WS-A
         SUBTRACT 1 FROM L-Y
         COMPUTE WS-INDEX = L-Y + 1
         MOVE L-COLUMN(WS-INDEX:1) TO WS-B
         IF WS-A = "A" AND (WS-B = "S" OR WS-B = "T")
             MOVE 1 TO WS-DONE
         END-IF
     END-PERFORM
     IF L-Y > 32
         MOVE 1 TO L-VALID
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND L-ROT
         MOVE 14 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
         COMPUTE L-TEMPLATE = WS-DRAW + 1
     END-IF
     GOBACK.
 END PROGRAM NETHER-FOSSIL-POINT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FOSSIL-TEMPLATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TABLE.
    05 FILLER              PIC X(9) VALUE "4 4 5 10|".
    05 FILLER              PIC X(9) VALUE "5 1 5 10|".
    05 FILLER              PIC X(9) VALUE "3 4 2 06|".
    05 FILLER              PIC X(9) VALUE "3 4 1 06|".
    05 FILLER              PIC X(9) VALUE "2 5 1 05|".
    05 FILLER              PIC X(9) VALUE "7 5 5 21|".
    05 FILLER              PIC X(9) VALUE "4 6 5 18|".
    05 FILLER              PIC X(9) VALUE "3 5 1 06|".
    05 FILLER              PIC X(9) VALUE "3 5 5 15|".
    05 FILLER              PIC X(9) VALUE "3 7 1 08|".
    05 FILLER              PIC X(9) VALUE "5 5 7 24|".
    05 FILLER              PIC X(9) VALUE "4 4 3 11|".
    05 FILLER              PIC X(9) VALUE "4 5 6 17|".
    05 FILLER              PIC X(9) VALUE "7 7 6 26|".
 01 WS-TABLE-T REDEFINES WS-TABLE.
    05 WS-ENTRY            OCCURS 14 TIMES.
       10 WS-SX            PIC 9.
       10 FILLER           PIC X.
       10 WS-SY            PIC 9.
       10 FILLER           PIC X.
       10 WS-SZ            PIC 9.
       10 FILLER           PIC X.
       10 WS-BONES         PIC 99.
       10 FILLER           PIC X.
 LINKAGE SECTION.
 01 L-TEMPLATE             BINARY-LONG.
 01 L-SX                   BINARY-LONG.
 01 L-SY                   BINARY-LONG.
 01 L-SZ                   BINARY-LONG.
 01 L-BONES                BINARY-LONG.
 PROCEDURE DIVISION USING L-TEMPLATE L-SX L-SY L-SZ L-BONES.
     MOVE 0 TO L-SX L-SY L-SZ L-BONES
     IF L-TEMPLATE >= 1 AND L-TEMPLATE <= 14
         MOVE WS-SX(L-TEMPLATE) TO L-SX
         MOVE WS-SY(L-TEMPLATE) TO L-SY
         MOVE WS-SZ(L-TEMPLATE) TO L-SZ
         MOVE WS-BONES(L-TEMPLATE) TO L-BONES
     END-IF
     GOBACK.
 END PROGRAM NETHER-FOSSIL-TEMPLATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-FOSSIL-GHAST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-M64                 PIC 9(20) VALUE 18446744073709551616.
 01 WS-RNG                 BINARY-DOUBLE UNSIGNED.
 01 WS-USEED               BINARY-DOUBLE UNSIGNED.
 01 WS-LO                  BINARY-DOUBLE UNSIGNED.
 01 WS-POS-SEED            BINARY-DOUBLE.
 01 WS-POS-USEED           BINARY-DOUBLE UNSIGNED.
 01 WS-F                   FLOAT-LONG.
 01 WS-BITS                BINARY-DOUBLE.
 01 WS-DRAW                BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-BX                   BINARY-LONG.
 01 L-BY                   BINARY-LONG.
 01 L-BZ                   BINARY-LONG.
 01 L-XS                   BINARY-LONG.
 01 L-ZS                   BINARY-LONG.
 01 L-MX                   BINARY-LONG.
 01 L-MY                   BINARY-LONG.
 01 L-MZ                   BINARY-LONG.
 01 L-PLACED               BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-ROT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-BX L-BY L-BZ L-XS L-ZS L-MX L-MY L-MZ L-PLACED L-X L-Y L-Z L-ROT.
     MOVE 0 TO L-PLACED L-X L-Y L-Z L-ROT
*>   SingleThreadedRandomSource(seed).forkPositional(): the factory seed is the first nextLong; at(centre) is a legacy random seeded getSeed(centre) xor that seed
     COMPUTE WS-USEED = FUNCTION MOD(L-SEED + WS-M64, WS-M64)
     CALL "JRAND-SET-SEED" USING WS-RNG WS-USEED
     CALL "JRAND-NEXT-LONG" USING WS-RNG WS-LO
     CALL "XORO-GET-SEED" USING L-MX L-MY L-MZ WS-POS-SEED
     COMPUTE WS-POS-USEED = FUNCTION MOD(WS-POS-SEED + WS-M64, WS-M64)
     CALL "CBL_XOR" USING WS-LO WS-POS-USEED BY VALUE 8
     CALL "JRAND-SET-SEED" USING WS-RNG WS-POS-USEED
     CALL "JRAND-NEXT-FLOAT" USING WS-RNG WS-F
*>   nextFloat() < 0.5 is the 24-bit draw below 2^23 (compared as an integer: float comparison is fuzzy)
     COMPUTE WS-BITS = FUNCTION INTEGER(WS-F * 16777216 + 0.5)
     IF WS-BITS < 8388608
         MOVE 1 TO L-PLACED
         MOVE L-XS TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
         COMPUTE L-X = L-BX + WS-DRAW
         MOVE L-BY TO L-Y
         MOVE L-ZS TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND WS-DRAW
         COMPUTE L-Z = L-BZ + WS-DRAW
         MOVE 4 TO WS-BOUND
         CALL "JRAND-NEXT-INT-BOUND" USING WS-RNG WS-BOUND L-ROT
     END-IF
     GOBACK.
 END PROGRAM NETHER-FOSSIL-GHAST.
