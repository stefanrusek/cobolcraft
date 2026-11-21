*> Entity models part 9, section 13 falling blocks and primed TNT (docs/protocol/34-entity-models-9-non-living-entities.md); swell and isLit are in entmodel-34-9-3.cob:
*>   EF9-TNT-OPS IN(1 fuseRemainingInTicks f) OUT(ops: count, then code and three values per op; 1 translate, 2 scale, 3 rotate Y degrees): 13.2 submit (translate (0, 0.5, 0), scale 1 + swell(f)
*>     when f < 10, rotate Y by -90, translate (-0.5, -0.5, 0.5), rotate Y by 90), the block model's cube [0, 1] cubed then follows;
*>   EF9-TNT-FLASH IN(1 f) OUT(1 overlay 15 when lit else 0, 2 the overlay's alpha 63 when lit else 0): submitWhiteSolidBlock's overlay pack(u(1.0) = 15, 10) and pixel alpha int(0.25 x 255);
*>   EF9-FALLING-OPS OUT(ops: translate (-0.5, 0, -0.5)): 13.1 submit;
*>   EF9-FALLING-SHOWN IN(1 the entity's block state, 2 the state the level holds at BlockPos.containing(x, maxY, z)) OUT(1 shouldRender: 0 when they are the same state);
*>   EF9-FALLING-POS IN(1 x, 2 y, 3 z, 4 the box height) OUT(1 to 3 the block position containing (x, y + height, z)).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TNT-OPS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 01 WS-N                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(2)
     MOVE 0 TO L-O(3) L-O(5)
     MOVE 0.5 TO L-O(4)
     MOVE 1 TO WS-N
     IF L-I(1) < 10
         MOVE L-I(1) TO WS-IV(1)
         CALL "EF9-TNT-SWELL" USING WS-I WS-O
         ADD 1 TO WS-N
         COMPUTE WS-K = WS-N * 4 - 2
         MOVE 2 TO L-O(WS-K)
         COMPUTE L-O(WS-K + 1) = 1 + WS-OV(1)
         MOVE L-O(WS-K + 1) TO L-O(WS-K + 2) L-O(WS-K + 3)
     END-IF
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 3 TO L-O(WS-K)
     MOVE -90 TO L-O(WS-K + 1)
     MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 1 TO L-O(WS-K)
     MOVE -0.5 TO L-O(WS-K + 1) L-O(WS-K + 2)
     MOVE 0.5 TO L-O(WS-K + 3)
     ADD 1 TO WS-N
     COMPUTE WS-K = WS-N * 4 - 2
     MOVE 3 TO L-O(WS-K)
     MOVE 90 TO L-O(WS-K + 1)
     MOVE 0 TO L-O(WS-K + 2) L-O(WS-K + 3)
     MOVE WS-N TO L-O(1)
     GOBACK.
 END PROGRAM EF9-TNT-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-TNT-FLASH.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I.
    05 WS-IV               FLOAT-LONG OCCURS 32 TIMES.
 01 WS-O.
    05 WS-OV               FLOAT-LONG OCCURS 64 TIMES.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO WS-IV(1)
     CALL "EF9-TNT-LIT" USING WS-I WS-O
     MOVE 0 TO L-O(1) L-O(2)
     IF WS-OV(1) = 1
         MOVE 15 TO L-O(1)
         COMPUTE L-O(2) = FUNCTION INTEGER-PART(0.25 * 255)
     END-IF
     GOBACK.
 END PROGRAM EF9-TNT-FLASH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-FALLING-OPS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     MOVE 1 TO L-O(2)
     MOVE -0.5 TO L-O(3) L-O(5)
     MOVE 0 TO L-O(4)
     GOBACK.
 END PROGRAM EF9-FALLING-OPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-FALLING-SHOWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE 1 TO L-O(1)
     IF L-I(1) = L-I(2)
         MOVE 0 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF9-FALLING-SHOWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-FALLING-POS.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE L-O(1) = FUNCTION INTEGER(L-I(1))
     COMPUTE L-O(2) = FUNCTION INTEGER(L-I(2) + L-I(4))
     COMPUTE L-O(3) = FUNCTION INTEGER(L-I(3))
     GOBACK.
 END PROGRAM EF9-FALLING-POS.
