*> Entity models part 9, sections 7 and 8 thrown items, the firework rocket and the fishing hook (docs/protocol/34-entity-models-9-non-living-entities.md); Mth.sin and Mth.cos of 34-9 section 2:
*>   EF9-THROWN key(X(24)) OUT(1 known, 2 the scale, 3 full bright): ThrownItemRenderer's arguments (1.1 table, Validation 2);
*>   EF9-THROWN-LIGHT IN(1 block light, 2 full bright) OUT(1 the block light used: 15 when full bright);
*>   EF9-THROWN-QUAD IN(1 scale s, 2 isShotAtAngle) OUT(12 numbers: the corners top left, top right, bottom right, bottom left as x, y, z in the camera's space: x right, y up, z toward
*>     the camera): the flat item model of the ground display transform (x -0.25 to 0.25, y -0.125 to 0.375) scaled by s; a firework shot at an angle then rotates X by 90, Y by 180 and
*>     Z by 180 degrees (the stack lists Z, Y, X: the X rotation acts first);
*>   EF9-MTH-COS IN x OUT cos: SIN[(long)(x x 10430.378350470453 + 16384.0) & 65535] (the sine is PENG-MTH-SIN);
*>   EF9-HOOK-QUAD OUT(16: for the four vertices x, y, u, v): 8.1 step 1 (scale 0.5 of the corners (px - 0.5, py - 0.5), uv (0, 1), (1, 1), (1, 0), (0, 0));
*>   EF9-HOOK-LINE IN(1 to 3 lineOriginOffset, 4 segment i 0 to 15) OUT(1 to 3 and 4 to 6 the position and normal of the first vertex (t0, t1), 7 to 12 of the second (t1, t0)): 8 step 2;
*>   EF9-HOOK-SWING IN(1 swing animation) OUT(1 f = sin(sqrt(swing) pi));
*>   EF9-HOOK-SIDE IN(1 the main hand holds a fishing rod, 2 the main arm is right) OUT(1 +1 for the right arm, else -1): getHoldingArm;
*>   EF9-HOOK-HAND IN(1 yBodyRotO, 2 yBodyRot, 3 partial tick, 4 side, 5 scale, 6 crouching, 7 to 9 eye position) OUT(1 to 3): getPlayerHandPos in the third person.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-THROWN.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(24).
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE 1 TO L-O(1)
     MOVE 1 TO L-O(2)
     MOVE 0 TO L-O(3)
     EVALUATE L-KEY
         WHEN "snowball"
         WHEN "egg"
         WHEN "ender_pearl"
         WHEN "splash_potion"
         WHEN "lingering_potion"
         WHEN "experience_bottle"
             CONTINUE
         WHEN "eye_of_ender"
             MOVE 1 TO L-O(3)
         WHEN "fireball"
             MOVE 3 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN "small_fireball"
             MOVE 0.75 TO L-O(2)
             MOVE 1 TO L-O(3)
         WHEN OTHER
             MOVE 0 TO L-O(1)
     END-EVALUATE
     GOBACK.
 END PROGRAM EF9-THROWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-THROWN-LIGHT.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(1) TO L-O(1)
     IF L-I(2) NOT = 0
         MOVE 15 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF9-THROWN-LIGHT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-THROWN-QUAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-K                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-T                   FLOAT-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE -0.25 TO WS-X
         IF WS-K = 2 OR WS-K = 3
             MOVE 0.25 TO WS-X
         END-IF
         MOVE 0.375 TO WS-Y
         IF WS-K >= 3
             MOVE -0.125 TO WS-Y
         END-IF
         COMPUTE WS-X = WS-X * L-I(1)
         COMPUTE WS-Y = WS-Y * L-I(1)
         MOVE 0 TO WS-Z
         IF L-I(2) NOT = 0
*>           rotate X by 90: y' = y cos - z sin, z' = y sin + z cos
             COMPUTE WS-T = 0 - WS-Z
             COMPUTE WS-Z = WS-Y
             MOVE WS-T TO WS-Y
*>           rotate Y by 180: x' = -x, z' = -z
             COMPUTE WS-X = 0 - WS-X
             COMPUTE WS-Z = 0 - WS-Z
*>           rotate Z by 180: x' = -x, y' = -y
             COMPUTE WS-X = 0 - WS-X
             COMPUTE WS-Y = 0 - WS-Y
         END-IF
         COMPUTE WS-B = WS-K * 3 - 2
         MOVE WS-X TO L-O(WS-B)
         MOVE WS-Y TO L-O(WS-B + 1)
         MOVE WS-Z TO L-O(WS-B + 2)
     END-PERFORM
     GOBACK.
 END PROGRAM EF9-THROWN-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-MTH-COS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-DOUBLE.
 01 WS-F32                 FLOAT-SHORT.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-COS                  FLOAT-LONG.
 PROCEDURE DIVISION USING L-X L-COS.
     COMPUTE WS-INDEX = FUNCTION INTEGER-PART(L-X * 10430.378350470453 + 16384.0)
     COMPUTE WS-INDEX = FUNCTION MOD(WS-INDEX, 65536)
     COMPUTE WS-F32 = FUNCTION SIN(WS-INDEX / 10430.378350470453)
     MOVE WS-F32 TO L-COS
     GOBACK.
 END PROGRAM EF9-MTH-COS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-HOOK-QUAD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DATA.
    05 FILLER PIC X(4) VALUE "0001".
    05 FILLER PIC X(4) VALUE "1011".
    05 FILLER PIC X(4) VALUE "1110".
    05 FILLER PIC X(4) VALUE "0100".
 01 WS-TABLE REDEFINES WS-DATA.
    05 WS-V OCCURS 4 TIMES.
       10 WS-PX            PIC 9.
       10 WS-PY            PIC 9.
       10 WS-U             PIC 9.
       10 WS-W             PIC 9.
 01 WS-K                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         COMPUTE WS-B = WS-K * 4 - 3
         COMPUTE L-O(WS-B) = (WS-PX(WS-K) - 0.5) * 0.5
         COMPUTE L-O(WS-B + 1) = (WS-PY(WS-K) - 0.5) * 0.5
         MOVE WS-U(WS-K) TO L-O(WS-B + 2)
         MOVE WS-W(WS-K) TO L-O(WS-B + 3)
     END-PERFORM
     GOBACK.
 END PROGRAM EF9-HOOK-QUAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-HOOK-LINE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-SEG                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-T0                  FLOAT-LONG.
 01 WS-T1                  FLOAT-LONG.
 01 WS-TA                  FLOAT-LONG.
 01 WS-TB                  FLOAT-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-QX                  FLOAT-LONG.
 01 WS-QY                  FLOAT-LONG.
 01 WS-QZ                  FLOAT-LONG.
 01 WS-LEN                 FLOAT-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE L-I(4) TO WS-SEG
     COMPUTE WS-T0 = WS-SEG / 16
     COMPUTE WS-T1 = (WS-SEG + 1) / 16
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S > 1
         IF WS-S = 0
             MOVE WS-T0 TO WS-TA
             MOVE WS-T1 TO WS-TB
         ELSE
             MOVE WS-T1 TO WS-TA
             MOVE WS-T0 TO WS-TB
         END-IF
         COMPUTE WS-PX = L-I(1) * WS-TA
         COMPUTE WS-PY = L-I(2) * (WS-TA * WS-TA + WS-TA) * 0.5 + 0.25
         COMPUTE WS-PZ = L-I(3) * WS-TA
         COMPUTE WS-QX = L-I(1) * WS-TB
         COMPUTE WS-QY = L-I(2) * (WS-TB * WS-TB + WS-TB) * 0.5 + 0.25
         COMPUTE WS-QZ = L-I(3) * WS-TB
         COMPUTE WS-LEN = FUNCTION SQRT((WS-QX - WS-PX) * (WS-QX - WS-PX) + (WS-QY - WS-PY) * (WS-QY - WS-PY) + (WS-QZ - WS-PZ) * (WS-QZ - WS-PZ))
         COMPUTE WS-B = WS-S * 6
         MOVE WS-PX TO L-O(WS-B + 1)
         MOVE WS-PY TO L-O(WS-B + 2)
         MOVE WS-PZ TO L-O(WS-B + 3)
         COMPUTE L-O(WS-B + 4) = (WS-QX - WS-PX) / WS-LEN
         COMPUTE L-O(WS-B + 5) = (WS-QY - WS-PY) / WS-LEN
         COMPUTE L-O(WS-B + 6) = (WS-QZ - WS-PZ) / WS-LEN
     END-PERFORM
     GOBACK.
 END PROGRAM EF9-HOOK-LINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-HOOK-SWING.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-PI32                FLOAT-SHORT VALUE 3.1415927.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-X = FUNCTION SQRT(L-I(1)) * WS-PI32
     CALL "PENG-MTH-SIN" USING WS-X WS-S
     MOVE WS-S TO L-O(1)
     GOBACK.
 END PROGRAM EF9-HOOK-SWING.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-HOOK-SIDE.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     MOVE -1 TO L-O(1)
*>   the main arm when the main hand holds a rod, else the opposite arm: right when (rod and main right) or (no rod and main left)
     IF (L-I(1) NOT = 0 AND L-I(2) NOT = 0) OR (L-I(1) = 0 AND L-I(2) = 0)
         MOVE 1 TO L-O(1)
     END-IF
     GOBACK.
 END PROGRAM EF9-HOOK-SIDE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EF9-HOOK-HAND.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 01 WS-S                   FLOAT-LONG.
 01 WS-SIN                 FLOAT-LONG.
 01 WS-COS                 FLOAT-LONG.
 01 WS-SD                  FLOAT-LONG.
 01 WS-FW                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 LINKAGE SECTION.
 01 L-IN.
    05 L-I                 FLOAT-LONG OCCURS 32 TIMES.
 01 L-OUT.
    05 L-O                 FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION USING L-IN L-OUT.
     COMPUTE WS-A = (L-I(1) + (L-I(2) - L-I(1)) * L-I(3)) * 0.017453292
     CALL "PENG-MTH-SIN" USING WS-A WS-SIN
     CALL "EF9-MTH-COS" USING WS-A WS-COS
     COMPUTE WS-SD = L-I(4) * 0.35 * L-I(5)
     COMPUTE WS-FW = 0.8 * L-I(5)
     MOVE 0 TO WS-DY
     IF L-I(6) NOT = 0
         MOVE -0.1875 TO WS-DY
     END-IF
     COMPUTE L-O(1) = L-I(7) + (0 - WS-COS * WS-SD - WS-SIN * WS-FW)
     COMPUTE L-O(2) = L-I(8) + (WS-DY - 0.45 * L-I(5))
     COMPUTE L-O(3) = L-I(9) + (0 - WS-SIN * WS-SD + WS-COS * WS-FW)
     GOBACK.
 END PROGRAM EF9-HOOK-HAND.
