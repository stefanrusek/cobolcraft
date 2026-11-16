*> The ice spike feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 16; registry id 47, spike): FD-SPIKE-NODE takes a row of FD-WA (WA-I(1) the state, WA-PR(1) can_place_on,
*> WA-PR(2) can_replace: FD-BAD when one is missing or not compiled); FR-SPIKE: the origin walks down through air while y > minY + 2 and must satisfy can_place_on (else false); then up nextInt(4),
*> H = nextInt(4) + 7, Wd = H / 4 + nextInt(2) and, for Wd > 1, nextInt(60) = 0 lifts it by 10 + nextInt(30); the body (layers 0 .. H - 1, radius ceil((1 - y / H) * Wd) with the float32 steps of the
*> document, cells of the square within the distance test or the axis, rim cells skipped by nextFloat() > 0.75 (k > 2^23 * 1.5 of the 24 bit draw), air or can_replace cells written, the mirrored cell below
*> for y /= 0 and rad > 1); then the pillar base columns (t = min(Wd - 1, 1); a corner column starts its countdown at nextInt(5); a column goes down while y > 50 through air, can_replace and the state,
*> skipping 1 to 5 blocks when the countdown ends). Writes use flag 3. The result is true once can_place_on holds.
*>
*> Entry points: FD-SPIKE-NODE USING doc, node, row out; FR-SPIKE USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-SPIKE-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-CAN-REPLACE         PIC X(40) VALUE "can_replace".
 LINKAGE SECTION.
 COPY JSONDOC.
 01 L-NODE                 BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING JSON-DOC L-NODE L-ROW.
     MOVE 0 TO L-ROW
     IF FD-WA-COUNT >= FD-MAX-WA
         MOVE 1 TO FD-BAD
         GOBACK
     END-IF
     ADD 1 TO FD-WA-COUNT
     MOVE FD-WA-COUNT TO WS-ROW
     INITIALIZE FD-WA(WS-ROW)
     MOVE WS-ROW TO L-ROW
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-STATE WS-E
     CALL "FD-J-STATE" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-CAN-PLACE-ON WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 1)
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE WS-CAN-REPLACE WS-E
     CALL "FD-PRED-NODE" USING JSON-DOC WS-E WA-PR(WS-ROW, 2)
     GOBACK.
 END PROGRAM FD-SPIKE-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-SPIKE.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-TEST                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-B4                  BINARY-LONG VALUE 4.
 01 WS-B2                  BINARY-LONG VALUE 2.
 01 WS-B5                  BINARY-LONG VALUE 5.
 01 WS-B60                 BINARY-LONG VALUE 60.
 01 WS-B30                 BINARY-LONG VALUE 30.
 01 WS-BITS24              BINARY-LONG VALUE 24.
 01 WS-DRAW                BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-WD                  BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-LAYER               BINARY-LONG.
 01 WS-RAD                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-AZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-KW                  BINARY-DOUBLE.
 01 WS-DL                  FLOAT-LONG.
 01 WS-F1                  FLOAT-SHORT.
 01 WS-F2                  FLOAT-SHORT.
 01 WS-F                   FLOAT-SHORT.
 01 WS-FF                  FLOAT-SHORT.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG.
 01 WS-NEG                 FLOAT-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-SKIP                BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE L-Y TO WS-PY
     COMPUTE WS-LOW = FL-MIN-Y + 2
     MOVE 1 TO WS-CLASS
     PERFORM UNTIL WS-CLASS NOT = 1 OR WS-PY <= WS-LOW
         CALL "FL-GET-STATE" USING L-X WS-PY L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS = 1
             SUBTRACT 1 FROM WS-PY
         END-IF
     END-PERFORM
     CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 1) L-X WS-PY L-Z WS-TEST
     IF WS-TEST = 0
         GOBACK
     END-IF
     MOVE 1 TO L-RESULT
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B4 WS-DRAW
     ADD WS-DRAW TO WS-PY
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B4 WS-H
     ADD 7 TO WS-H
     CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B2 WS-DRAW
     COMPUTE WS-WD = WS-H / 4 + WS-DRAW
     IF WS-WD > 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B60 WS-DRAW
         IF WS-DRAW = 0
             CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B30 WS-DRAW
             COMPUTE WS-PY = WS-PY + 10 + WS-DRAW
         END-IF
     END-IF
     PERFORM VARYING WS-LAYER FROM 0 BY 1 UNTIL WS-LAYER >= WS-H
*>       f = (1.0f - (float) y / (float) H) * (float) Wd, rounded to float32 after each operation; rad = ceil(f)
         COMPUTE WS-DL = WS-LAYER / WS-H
         MOVE WS-DL TO WS-F1
         COMPUTE WS-DL = 1.0 - WS-F1
         MOVE WS-DL TO WS-F2
         COMPUTE WS-DL = WS-F2 * WS-WD
         MOVE WS-DL TO WS-F
         COMPUTE WS-NEG = 0 - WS-F
         COMPUTE WS-FLOOR = FUNCTION INTEGER(WS-NEG)
         COMPUTE WS-RAD = 0 - WS-FLOOR
         COMPUTE WS-DL = WS-F * WS-F
         MOVE WS-DL TO WS-FF
         COMPUTE WS-AX = 0 - WS-RAD
         PERFORM VARYING WS-DX FROM WS-AX BY 1 UNTIL WS-DX > WS-RAD
             PERFORM VARYING WS-DZ FROM WS-AX BY 1 UNTIL WS-DZ > WS-RAD
                 PERFORM BODY-CELL
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-T = WS-WD - 1
     IF WS-T > 1
         MOVE 1 TO WS-T
     END-IF
     COMPUTE WS-AX = 0 - WS-T
     PERFORM VARYING WS-DX FROM WS-AX BY 1 UNTIL WS-DX > WS-T
         PERFORM VARYING WS-DZ FROM WS-AX BY 1 UNTIL WS-DZ > WS-T
             PERFORM BASE-COLUMN
         END-PERFORM
     END-PERFORM
     GOBACK.
 BODY-CELL.
     COMPUTE WS-AZ = FUNCTION ABS(WS-DX)
     COMPUTE WS-FX = WS-AZ - 0.25
     COMPUTE WS-AZ = FUNCTION ABS(WS-DZ)
     COMPUTE WS-FZ = WS-AZ - 0.25
     COMPUTE WS-SUM = WS-FX * WS-FX + WS-FZ * WS-FZ
     MOVE 1 TO WS-SKIP
     IF WS-DX = 0 AND WS-DZ = 0
         MOVE 0 TO WS-SKIP
     ELSE
         IF WS-SUM <= WS-FF
             MOVE 0 TO WS-SKIP
         END-IF
     END-IF
     IF WS-SKIP = 0
         IF FUNCTION ABS(WS-DX) = WS-RAD OR FUNCTION ABS(WS-DZ) = WS-RAD
             CALL "WGR-NEXT" USING L-STATE WS-BITS24 WS-KW
             IF WS-KW > 12582912
                 MOVE 1 TO WS-SKIP
             END-IF
         END-IF
     END-IF
     IF WS-SKIP = 0
         COMPUTE WS-X = L-X + WS-DX
         COMPUTE WS-Y = WS-PY + WS-LAYER
         COMPUTE WS-Z = L-Z + WS-DZ
         PERFORM WRITE-IF-FREE
         IF WS-LAYER NOT = 0 AND WS-RAD > 1
             COMPUTE WS-Y = WS-PY - WS-LAYER
             PERFORM WRITE-IF-FREE
         END-IF
     END-IF
     .
*> WRITE-IF-FREE: the state at (WS-X, WS-Y, WS-Z) when it is air or can_replace holds there
 WRITE-IF-FREE.
     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     MOVE 0 TO WS-OK
     IF WS-CLASS = 1
         MOVE 1 TO WS-OK
     ELSE
         CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 2) WS-X WS-Y WS-Z WS-TEST
         MOVE WS-TEST TO WS-OK
     END-IF
     IF WS-OK = 1
         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WA-I(WS-ROW, 1) WS-FLAGS WS-WRITTEN
     END-IF
     .
 BASE-COLUMN.
     MOVE 50 TO WS-N
     IF FUNCTION ABS(WS-DX) = 1 AND FUNCTION ABS(WS-DZ) = 1
         CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-N
     END-IF
     COMPUTE WS-X = L-X + WS-DX
     COMPUTE WS-Z = L-Z + WS-DZ
     COMPUTE WS-CY = WS-PY - 1
     MOVE 0 TO WS-STOP
     PERFORM UNTIL WS-CY <= 50 OR WS-STOP = 1
         MOVE WS-CY TO WS-Y
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         MOVE 0 TO WS-OK
         IF WS-CLASS = 1 OR WS-STATE = WA-I(WS-ROW, 1)
             MOVE 1 TO WS-OK
         ELSE
             CALL "FR-PRED-TEST" USING WA-PR(WS-ROW, 2) WS-X WS-Y WS-Z WS-TEST
             MOVE WS-TEST TO WS-OK
         END-IF
         IF WS-OK = 1
             CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WA-I(WS-ROW, 1) WS-FLAGS WS-WRITTEN
             SUBTRACT 1 FROM WS-CY
             SUBTRACT 1 FROM WS-N
             IF WS-N <= 0
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-DRAW
                 COMPUTE WS-CY = WS-CY - WS-DRAW - 1
                 CALL "WGR-NEXT-INT-BOUND" USING L-STATE WS-B5 WS-N
             END-IF
         ELSE
             MOVE 1 TO WS-STOP
         END-IF
     END-PERFORM
     .
 END PROGRAM FR-SPIKE.
