*> Entity models part 9, section 14 experience orb (docs/protocol/34-entity-models-9-non-living-entities.md):
*>   EF9-ORB-ICON IN(1 the orb's value) OUT(1 getIcon, 0 to 10);
*>   EF9-ORB-UV IN(1 icon) OUT(1 u0, 2 u1, 3 v0, 4 v1) of the 64 x 64 sheet of 16-pixel icons (integer division by 4);
*>   EF9-ORB-COLOR IN(1 ageInTicks) OUT(1 r, 2 g, 3 b as integers of 0 to 255, 4 alpha 128): t = age / 2, r = int((sin t + 1) 0.5 255), b = int((sin (t + 4.1887903) + 1) 0.1 255)
*>     with the game's table sine (PENG-MTH-SIN, 34-9 section 2);
*>   EF9-ORB-LIGHT IN(1 block light) OUT(1 clamp(block + 7, 0, 15)).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ORB-ICON.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     EVALUATE TRUE
         WHEN L-I(1) >= 2477 MOVE 10 TO L-O(1)
         WHEN L-I(1) >= 1237 MOVE 9 TO L-O(1)
         WHEN L-I(1) >= 617 MOVE 8 TO L-O(1)
         WHEN L-I(1) >= 307 MOVE 7 TO L-O(1)
         WHEN L-I(1) >= 149 MOVE 6 TO L-O(1)
         WHEN L-I(1) >= 73 MOVE 5 TO L-O(1)
         WHEN L-I(1) >= 37 MOVE 4 TO L-O(1)
         WHEN L-I(1) >= 17 MOVE 3 TO L-O(1)
         WHEN L-I(1) >= 7 MOVE 2 TO L-O(1)
         WHEN L-I(1) >= 3 MOVE 1 TO L-O(1)
         WHEN OTHER MOVE 0 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-ORB-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ORB-UV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-ICON                BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-ICON
     COMPUTE WS-ROW = WS-ICON / 4
     COMPUTE WS-COL = WS-ICON - WS-ROW * 4
     COMPUTE L-O(1) = (WS-COL * 16) / 64
     COMPUTE L-O(2) = (WS-COL * 16 + 16) / 64
     COMPUTE L-O(3) = (WS-ROW * 16) / 64
     COMPUTE L-O(4) = (WS-ROW * 16 + 16) / 64
     GOBACK.
 END PROGRAM EF9-ORB-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ORB-COLOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-T                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-T = L-I(1) / 2
     CALL "PENG-MTH-SIN" USING WS-T WS-S
     COMPUTE L-O(1) = FUNCTION INTEGER-PART((WS-S + 1) * 0.5 * 255)
     MOVE 255 TO L-O(2)
     COMPUTE WS-A = WS-T + 4.1887903
     CALL "PENG-MTH-SIN" USING WS-A WS-S
     COMPUTE L-O(3) = FUNCTION INTEGER-PART((WS-S + 1) * 0.1 * 255)
     MOVE 128 TO L-O(4)
     GOBACK.
 END PROGRAM EF9-ORB-COLOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-ORB-LIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION MAX(0, FUNCTION MIN(15, L-I(1) + 7))
     GOBACK.
 END PROGRAM EF9-ORB-LIGHT.
