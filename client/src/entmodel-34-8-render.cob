*> Entity models part 8, renderer facts of the dolphin (docs/protocol/34-entity-models-8-aquatic-nautilus-boats.md 3.2, 3.3) that are not mesh rows.
*>   EF8-DOLPHIN-MOVING IN(delta movement x, z) OUT(1 when the horizontal squared length is above 1.0E-7: isMoving);
*>   EF8-DOLPHIN-CARRY IN(xRot degrees) OUT(x, y, z of the translate of DolphinCarryingItemLayer, p = |xRot| / 60).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-DOLPHIN-MOVING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-LEN = L-I(1) * L-I(1) + L-I(2) * L-I(2)
     MOVE 0 TO L-O(1)
     IF WS-LEN > 0.0000001
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF8-DOLPHIN-MOVING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF8-DOLPHIN-CARRY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-P                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-P = FUNCTION ABS(L-I(1)) / 60
     MOVE 0 TO L-O(1)
     IF L-I(1) < 0
         COMPUTE L-O(2) = 1 - 0.5 * WS-P
         COMPUTE L-O(3) = -1 + 0.5 * WS-P
     ELSE
         COMPUTE L-O(2) = 1 + 0.8 * WS-P
         COMPUTE L-O(3) = -1 + 0.2 * WS-P
     END-IF
     GOBACK.
 END PROGRAM EF8-DOLPHIN-CARRY.
