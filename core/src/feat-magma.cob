*> The underwater magma feature (docs/protocol/35-worldgen-features-5-water-and-surface.md section 15; registry id 52, underwater_magma): FD-MAGMA-NODE takes a row of FD-WA (WA-I(1) floor_search_range,
*> WA-I(2) placement_radius_around_floor, WA-I(3) the block index of magma_block, WA-F(1) the probability), FR-MAGMA places it: the origin must be water; the floor scan goes down from the origin
*> while i < range and the block is water, the floor is the cursor when that block is not water (else false); the cube of the radius around the floor is walked x fastest, then y, then z: a draw
*> nextFloat() < probability keeps a cell, which takes magma (flag 2) when it is not water or air and the block below and the four side neighbours are opaque (CB-OPAQUE, the face test of
*> has_sturdy_face: the document's face-occlusion shapes of 24 section 5.2 are not read per block, a documented deviation). A written block is seen by later cells. The result is whether one was written.
*>
*> Entry points: FD-MAGMA-NODE USING doc, node, row out; FR-MAGMA USING state, feature, x, y, z, result out.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FD-MAGMA-NODE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY FDKEYS.
 01 WS-ROW                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-OK                  BINARY-LONG.
 01 WS-NAME                PIC X(48).
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
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-FLOOR-RANGE WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PLACE-RADIUS WS-E
     CALL "FD-J-INT" USING JSON-DOC WS-E WA-I(WS-ROW, 2) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     CALL "FD-J-MEMBER" USING JSON-DOC L-NODE FK-PLACE-PROB WS-E
     CALL "FD-J-DOUBLE" USING JSON-DOC WS-E WA-F(WS-ROW, 1) WS-OK
     IF WS-OK = 0
         MOVE 1 TO FD-BAD
     END-IF
     MOVE "minecraft:magma_block" TO WS-NAME
     CALL "FD-BLOCK-INDEX" USING WS-NAME WA-I(WS-ROW, 3)
     IF WA-I(WS-ROW, 3) = 0
         MOVE 1 TO FD-BAD
     END-IF
     GOBACK.
 END PROGRAM FD-MAGMA-NODE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. FR-MAGMA.
*> USING state, feature, x, y, z, result out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FEATDATA.
 COPY CBLOCKS.
 COPY FEATLEVEL.
 01 WS-ROW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-RANGE               BINARY-LONG.
 01 WS-RADIUS              BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                 BINARY-LONG.
 01 WS-YLO                 BINARY-LONG.
 01 WS-ZLO                 BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-FLOAT               FLOAT-LONG.
 01 WS-PROB                FLOAT-LONG.
 01 WS-MAGMA               BINARY-LONG.
 01 WS-WRITTEN             BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-SIDES.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
 01 WS-SIDE-TABLE REDEFINES WS-SIDES.
    05 WS-SD OCCURS 4 TIMES.
       10 WS-SDX           BINARY-LONG.
       10 WS-SDZ           BINARY-LONG.
 LINKAGE SECTION.
 COPY XORO REPLACING LEADING ==XR-== BY ==L-==.
 01 L-FT                   BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RESULT               BINARY-LONG.
 PROCEDURE DIVISION USING L-STATE L-FT L-X L-Y L-Z L-RESULT.
     GO TO MAIN-LINE.
*> CHECK-OPAQUE: WS-VALID 0 unless the block of WS-STATE is opaque (a full face)
 CHECK-OPAQUE.
     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
     IF WS-BLOCK = 0
         MOVE 0 TO WS-VALID
     ELSE
         IF CB-OPAQUE(WS-BLOCK) = 0
             MOVE 0 TO WS-VALID
         END-IF
     END-IF
     .
 MAIN-LINE.
     MOVE 0 TO L-RESULT
     MOVE FT-A(L-FT) TO WS-ROW
     MOVE WA-I(WS-ROW, 1) TO WS-RANGE
     MOVE WA-I(WS-ROW, 2) TO WS-RADIUS
     MOVE WA-F(WS-ROW, 1) TO WS-PROB
     MOVE CB-DEFAULT-STATE(WA-I(WS-ROW, 3)) TO WS-MAGMA
     CALL "FL-GET-STATE" USING L-X L-Y L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS NOT = 2
         GOBACK
     END-IF
     MOVE L-Y TO WS-CY
     MOVE 1 TO WS-I
     PERFORM UNTIL WS-I >= WS-RANGE
         CALL "FL-GET-STATE" USING L-X WS-CY L-Z WS-STATE
         CALL "FL-CLASS" USING WS-STATE WS-CLASS
         IF WS-CLASS NOT = 2
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-CY
         ADD 1 TO WS-I
     END-PERFORM
     CALL "FL-GET-STATE" USING L-X WS-CY L-Z WS-STATE
     CALL "FL-CLASS" USING WS-STATE WS-CLASS
     IF WS-CLASS = 2
         GOBACK
     END-IF
     MOVE WS-CY TO WS-FY
     COMPUTE WS-XLO = L-X - WS-RADIUS
     COMPUTE WS-YLO = WS-FY - WS-RADIUS
     COMPUTE WS-ZLO = L-Z - WS-RADIUS
     PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > L-Z + WS-RADIUS
         PERFORM VARYING WS-Y FROM WS-YLO BY 1 UNTIL WS-Y > WS-FY + WS-RADIUS
             PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > L-X + WS-RADIUS
                 CALL "WGR-NEXT-FLOAT" USING L-STATE WS-FLOAT
                 IF WS-FLOAT < WS-PROB
                     MOVE 1 TO WS-VALID
                     CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
                     CALL "FL-CLASS" USING WS-STATE WS-CLASS
                     IF WS-CLASS = 1 OR WS-CLASS = 2
                         MOVE 0 TO WS-VALID
                     END-IF
                     COMPUTE WS-QY = WS-Y - 1
                     CALL "FL-GET-STATE" USING WS-X WS-QY WS-Z WS-STATE
                     PERFORM CHECK-OPAQUE
                     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
                         COMPUTE WS-QX = WS-X + WS-SDX(WS-K)
                         COMPUTE WS-QZ = WS-Z + WS-SDZ(WS-K)
                         CALL "FL-GET-STATE" USING WS-QX WS-Y WS-QZ WS-STATE
                         PERFORM CHECK-OPAQUE
                     END-PERFORM
                     IF WS-VALID = 1
                         CALL "FL-SET-STATE" USING WS-X WS-Y WS-Z WS-MAGMA WS-FLAGS WS-WRITTEN
                         MOVE 1 TO L-RESULT
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CONTINUE.
 END PROGRAM FR-MAGMA.
