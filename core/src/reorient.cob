*> StructurePiece.reorient of the default chest, shared by the structure pieces (36-1 6.5, SCP-REORIENT) and the monster room (35-6 9.1, ROOM-REORIENT).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. REORIENT-DIR.
*> USING x, y, z, direction out (0 north, 1 east, 2 south, 3 west): the facing of a chest at the position. A neighbour (north, east, south, west, in that order) that is a chest keeps the
*> default facing north, the first neighbour that renders solid (CB-OPAQUE) is the wall, a second one cancels it and ends the scan; a unique wall gives the opposite facing, else the default
*> facing north turns away from a solid block in front (opposite, clockwise, opposite). A neighbour reads through the level of the generation stage (FL-GET-STATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-D                   BINARY-LONG.
 01 WS-CAND                BINARY-LONG.
 01 WS-STOP                BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-ST                  BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-RENDER              BINARY-LONG.
 01 WS-DXS.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE -1.
 01 WS-DX-TABLE REDEFINES WS-DXS.
    05 WS-DX               BINARY-LONG OCCURS 4 TIMES.
 01 WS-DZS.
    05 FILLER              BINARY-LONG VALUE -1.
    05 FILLER              BINARY-LONG VALUE 0.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 0.
 01 WS-DZ-TABLE REDEFINES WS-DZS.
    05 WS-DZ               BINARY-LONG OCCURS 4 TIMES.
*> the turns of the default facing: opposite, clockwise, opposite
 01 WS-TURNS.
    05 FILLER              BINARY-LONG VALUE 2.
    05 FILLER              BINARY-LONG VALUE 1.
    05 FILLER              BINARY-LONG VALUE 2.
 01 WS-TURN-TABLE REDEFINES WS-TURNS.
    05 WS-TURN             BINARY-LONG OCCURS 3 TIMES.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIR.
     MOVE -1 TO WS-CAND
     MOVE 0 TO WS-STOP WS-DEFAULT
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3 OR WS-STOP = 1 OR WS-DEFAULT = 1
         COMPUTE WS-PX = L-X + WS-DX(WS-D + 1)
         COMPUTE WS-PZ = L-Z + WS-DZ(WS-D + 1)
         CALL "FL-GET-STATE" USING WS-PX L-Y WS-PZ WS-ST
         CALL "FL-BLOCK-OF" USING WS-ST WS-B
         MOVE 0 TO WS-RENDER
         IF WS-B > 0
             MOVE CB-OPAQUE(WS-B) TO WS-RENDER
         END-IF
         IF WS-B > 0 AND CB-KEY(WS-B) = "chest"
             MOVE 1 TO WS-DEFAULT
         ELSE
             IF WS-RENDER = 1 AND WS-CAND < 0
                 MOVE WS-D TO WS-CAND
             ELSE
                 IF WS-RENDER = 1
                     MOVE -1 TO WS-CAND
                     MOVE 1 TO WS-STOP
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO L-DIR
     IF WS-DEFAULT = 0
         IF WS-CAND >= 0
             COMPUTE L-DIR = FUNCTION MOD(WS-CAND + 2, 4)
         ELSE
             PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 3
                 COMPUTE WS-PX = L-X + WS-DX(L-DIR + 1)
                 COMPUTE WS-PZ = L-Z + WS-DZ(L-DIR + 1)
                 CALL "FL-GET-STATE" USING WS-PX L-Y WS-PZ WS-ST
                 CALL "FL-BLOCK-OF" USING WS-ST WS-B
                 MOVE 0 TO WS-RENDER
                 IF WS-B > 0
                     MOVE CB-OPAQUE(WS-B) TO WS-RENDER
                 END-IF
                 IF WS-RENDER = 1
                     COMPUTE L-DIR = FUNCTION MOD(L-DIR + WS-TURN(WS-D), 4)
                 END-IF
             END-PERFORM
         END-IF
     END-IF
     GOBACK.
 END PROGRAM REORIENT-DIR.
