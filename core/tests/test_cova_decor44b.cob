*> Implementation test (coverage lane A; docs/protocol/44 part 9 sections 5.1 to 5.4; core/src/decor-44b.cob): the step of every direction, an item frame and a painting placed on each side face
*> of a stone wall (the frame's direction and yaw, the painting's centre against the facing and along the counter-clockwise tangent), a glow frame, a painting on a vertical face refused, and
*> the hurt of a row that is no hanging entity.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVA-DECOR44B.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROJSTATE.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-PROW                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STONE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG VALUE 150.
 01 WS-BZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-GLOW                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG VALUE 2.
 01 WS-WIDTHS.
    05 WS-W                BINARY-LONG OCCURS 64 TIMES.
 01 WS-HEIGHTS.
    05 WS-H                BINARY-LONG OCCURS 64 TIMES.
 01 WS-I                   BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-EXP-XZ.
    05 WS-EXP-X            FLOAT-LONG OCCURS 4 TIMES.
    05 WS-EXP-Z            FLOAT-LONG OCCURS 4 TIMES.
 01 WS-EXP-YAW             PIC X(12) VALUE "180000090270".
 01 WS-HANDLED             BINARY-LONG.
 01 WS-EX                  BINARY-DOUBLE.
 01 WS-EZ                  BINARY-DOUBLE.
 01 WS-NONE-ROW            BINARY-LONG VALUE 0.
 01 WS-EXPLODE             BINARY-LONG VALUE 0.
 01 WS-FACE1               BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-ENTITY-ROW(WS-PLAYER) TO WS-PROW
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE
*>   The step of each direction.
     PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 5
         CALL "DECOR-STEP" USING WS-F WS-DX WS-DY WS-DZ
         MOVE WS-F TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44b the step of direction " WS-DIGIT " is a unit vector along its axis" DELIMITED BY SIZE INTO WS-CASE
         EVALUATE WS-F
             WHEN 0
                 MOVE -10 TO WS-E
             WHEN 1
                 MOVE 10 TO WS-E
             WHEN 2
                 MOVE -1 TO WS-E
             WHEN 3
                 MOVE 1 TO WS-E
             WHEN 4
                 MOVE -100 TO WS-E
             WHEN OTHER
                 MOVE 100 TO WS-E
         END-EVALUATE
         COMPUTE WS-O = WS-DX * 100 + WS-DY * 10 + WS-DZ
         CALL "CA-N" USING WS-CASE WS-E WS-O
     END-PERFORM
*>   Candidates: a 1 x 1 and a 2 x 2 painting.
     MOVE 1 TO WS-W(1)
     MOVE 1 TO WS-H(1)
     MOVE 2 TO WS-W(2)
     MOVE 2 TO WS-H(2)
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 40
     PERFORM VARYING WS-F FROM 2 BY 1 UNTIL WS-F > 5
         COMPUTE WS-BX = WS-X0 + 12 * WS-F
         MOVE WS-Z0 TO WS-BZ
*>       The wall: 7 wide, y 148 to 152, in the plane of the clicked cell.
         PERFORM VARYING WS-T FROM -3 BY 1 UNTIL WS-T > 3
             PERFORM VARYING WS-Y FROM 148 BY 1 UNTIL WS-Y > 152
                 IF WS-F < 4
                     COMPUTE WS-CX = WS-BX + WS-T
                     MOVE WS-BZ TO WS-CZ
                 ELSE
                     MOVE WS-BX TO WS-CX
                     COMPUTE WS-CZ = WS-BZ + WS-T
                 END-IF
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-CX WS-Y WS-CZ WS-STONE
             END-PERFORM
         END-PERFORM
         CALL "DECOR-STEP" USING WS-F WS-DX WS-DY WS-DZ
         CALL "PAINTING-PLACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-F WS-COUNT WS-WIDTHS WS-HEIGHTS WS-ROW
         MOVE WS-F TO WS-DIGIT
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44b a painting on face " WS-DIGIT " is placed as the 2 x 2 candidate" DELIMITED BY SIZE INTO WS-CASE
         MOVE 22 TO WS-E
         MOVE 0 TO WS-O
         IF WS-ROW > 0
             CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
             COMPUTE WS-O = PJ-I2(WS-SLOT) * 10 + PJ-I3(WS-SLOT)
         END-IF
         CALL "CA-N" USING WS-CASE WS-E WS-O
*>       The centre: the target cell's centre moved 0.46875 against the facing and 0.5 along the tangent (counter-clockwise), 0.5 up.
         COMPUTE WS-CX = WS-BX + WS-DX
         COMPUTE WS-CZ = WS-BZ + WS-DZ
         EVALUATE WS-F
             WHEN 2
                 COMPUTE WS-EX ROUNDED = (WS-CX + 0.5 - 0.5) * 1000
                 COMPUTE WS-EZ ROUNDED = (WS-CZ + 0.5 + 0.46875) * 1000
             WHEN 3
                 COMPUTE WS-EX ROUNDED = (WS-CX + 0.5 + 0.5) * 1000
                 COMPUTE WS-EZ ROUNDED = (WS-CZ + 0.5 - 0.46875) * 1000
             WHEN 4
                 COMPUTE WS-EX ROUNDED = (WS-CX + 0.5 + 0.46875) * 1000
                 COMPUTE WS-EZ ROUNDED = (WS-CZ + 0.5 + 0.5) * 1000
             WHEN OTHER
                 COMPUTE WS-EX ROUNDED = (WS-CX + 0.5 - 0.46875) * 1000
                 COMPUTE WS-EZ ROUNDED = (WS-CZ + 0.5 - 0.5) * 1000
         END-EVALUATE
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44b the 2 x 2 painting of face " WS-DIGIT " is centred against the wall (x, mm)" DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-O ROUNDED = EN-X(WS-ROW) * 1000
         CALL "CA-N" USING WS-CASE WS-EX WS-O
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44b the 2 x 2 painting of face " WS-DIGIT " rests at the computed z (mm)" DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-O ROUNDED = EN-Z(WS-ROW) * 1000
         CALL "CA-N" USING WS-CASE WS-EZ WS-O
*>       An item frame at another cell of the wall: the direction and the yaw of the face.
         IF WS-F < 4
             COMPUTE WS-CX = WS-BX + 3
             MOVE WS-BZ TO WS-CZ
         ELSE
             MOVE WS-BX TO WS-CX
             COMPUTE WS-CZ = WS-BZ + 3
         END-IF
         MOVE 148 TO WS-Y
         COMPUTE WS-GLOW = FUNCTION MOD(WS-F, 2)
         CALL "ITEM-FRAME-PLACE" USING WS-PLAYER WS-CX WS-Y WS-CZ WS-F WS-GLOW WS-ROW
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44b an item frame on face " WS-DIGIT " keeps the face as its direction" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-F TO WS-E
         MOVE 0 TO WS-O
         IF WS-ROW > 0
             CALL "PJ-FIND" USING EN-ID(WS-ROW) WS-SLOT
             MOVE PJ-I1(WS-SLOT) TO WS-O
         END-IF
         CALL "CA-N" USING WS-CASE WS-E WS-O
         MOVE SPACES TO WS-CASE
         STRING "test cova decor44b an item frame on face " WS-DIGIT " faces the way of its yaw" DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-E = FUNCTION NUMVAL(WS-EXP-YAW((WS-F - 2) * 3 + 1:3))
         COMPUTE WS-O ROUNDED = EN-YAW(WS-ROW)
         CALL "CA-N" USING WS-CASE WS-E WS-O
*>       A glow frame (odd faces here) is hurt by a survival player and drops the glow item.
         IF WS-GLOW = 1
             CALL "ITEM-FRAME-HURT" USING WS-ROW WS-PLAYER WS-EXPLODE WS-HANDLED
             MOVE SPACES TO WS-CASE
             STRING "test cova decor44b a glow frame on face " WS-DIGIT " is hurt and handled" DELIMITED BY SIZE INTO WS-CASE
             MOVE 1 TO WS-E
             MOVE WS-HANDLED TO WS-O
             CALL "CA-N" USING WS-CASE WS-E WS-O
         END-IF
     END-PERFORM
*>   A painting on a vertical face is refused.
     CALL "PAINTING-PLACE" USING WS-DIM WS-BX WS-BY WS-BZ WS-FACE1 WS-COUNT WS-WIDTHS WS-HEIGHTS WS-ROW
     MOVE "test cova decor44b a painting on the top face is refused" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-ROW TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
*>   A row that is no hanging entity (the player's tracker row) is not handled by the hurts.
     CALL "ITEM-FRAME-HURT" USING WS-PROW WS-NONE-ROW WS-EXPLODE WS-HANDLED
     MOVE "test cova decor44b the frame hurt ignores a row that is no frame" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HANDLED TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     CALL "PAINTING-HURT" USING WS-PROW WS-NONE-ROW WS-HANDLED
     MOVE "test cova decor44b the painting hurt ignores a row that is no painting" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-HANDLED TO WS-O
     CALL "CA-N" USING WS-CASE WS-E WS-O
     STOP RUN.
 END PROGRAM TEST-COVA-DECOR44B.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY COVATEST.
