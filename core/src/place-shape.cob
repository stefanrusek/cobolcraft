*> Placement of the blocks whose state follows their neighbours or the click (lane wallitems, CC-0009; docs/protocol/24 part 7 sections 6.3 and 6.4 (stairs), part 3 sections 7.7 (doors and trapdoors) and 7.7.1 (door
*> hinge), 30 part 7 section 3.3 and 3.4). Each program takes the placement context (PLACECTX.cpy) with PC-STATE the state the item places and leaves the state to place there.
*> Entry points:
*>   PS-STAIR-AT USING dimension row, x, y, z, facing out (direction 2 to 5), half out (0 not a stair, 1 bottom, 2 top)
*>   PS-STAIR      stairs: facing = the player's horizontal direction, half by the click, shape by the neighbours (getStairsShape)
*>   PS-DOOR       doors: facing = the player's horizontal direction, hinge by the neighbours and the click (getHinge)
*>   PS-TRAPDOOR   trapdoors: against the clicked side when the block is not replaced there, else facing the player

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-STAIR-AT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-SUFFIX              PIC X(24) VALUE "_stairs".
 01 WS-IS                  BINARY-LONG.
 01 WS-FACING              PIC X(24) VALUE "facing".
 01 WS-HALF                PIC X(24) VALUE "half".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FACING               BINARY-LONG.
 01 L-HALF                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FACING L-HALF.
     MOVE 0 TO L-FACING L-HALF
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "PS-NAME-OF" USING WS-STATE WS-NAME
     CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-IS
     IF WS-IS = 1
         CALL "PS-GET" USING WS-STATE WS-FACING WS-TEXT WS-FOUND
         CALL "PS-DIR-OF" USING WS-TEXT L-FACING
         CALL "PS-GET" USING WS-STATE WS-HALF WS-TEXT WS-FOUND
         MOVE 1 TO L-HALF
         IF FUNCTION TRIM(WS-TEXT) = "top"
             MOVE 2 TO L-HALF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PS-STAIR-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-STAIR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-F                   BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-CCW                 BINARY-LONG.
 01 WS-HALF                BINARY-LONG.
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-HALF-NAME           PIC X(24) VALUE "half".
 01 WS-SHAPE-NAME          PIC X(24) VALUE "shape".
 01 WS-TEXT                PIC X(32).
 01 WS-SHAPE               PIC X(32).
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A-FACING            BINARY-LONG.
 01 WS-A-HALF              BINARY-LONG.
 01 WS-A-OPP               BINARY-LONG.
 01 WS-C-FACING            BINARY-LONG.
 01 WS-C-HALF              BINARY-LONG.
 01 WS-AXIS-F              BINARY-LONG.
 01 WS-AXIS-A              BINARY-LONG.
 01 WS-TAKE                BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
     MOVE PC-HDIR TO WS-F
     CALL "PS-DIR-NAME" USING WS-F WS-TEXT
     CALL "PS-PUT" USING PC-STATE WS-FACING-NAME WS-TEXT
     MOVE 1 TO WS-HALF
     MOVE "bottom" TO WS-TEXT
     IF PC-FACE = 0 OR (PC-FACE > 1 AND PC-CY > 0.5)
         MOVE 2 TO WS-HALF
         MOVE "top" TO WS-TEXT
     END-IF
     CALL "PS-PUT" USING PC-STATE WS-HALF-NAME WS-TEXT
     CALL "PS-OPP" USING WS-F WS-OPP
     CALL "PS-CCW" USING WS-F WS-CCW
     COMPUTE WS-AXIS-F = WS-F / 2
     MOVE "straight" TO WS-SHAPE
     MOVE 0 TO WS-DONE
*>   The front: a stair of the same half across the axis, that the stair can take a corner against, makes an outer corner (left when it faces the counter-clockwise side).
     CALL "PS-DIR-STEP" USING WS-F WS-DX WS-DY WS-DZ
     COMPUTE WS-X = PC-X + WS-DX
     COMPUTE WS-Y = PC-Y + WS-DY
     COMPUTE WS-Z = PC-Z + WS-DZ
     CALL "PS-STAIR-AT" USING PC-DIM WS-X WS-Y WS-Z WS-A-FACING WS-A-HALF
     IF WS-A-HALF = WS-HALF
         COMPUTE WS-AXIS-A = WS-A-FACING / 2
         IF WS-AXIS-A NOT = WS-AXIS-F
             CALL "PS-OPP" USING WS-A-FACING WS-A-OPP
             CALL "PS-DIR-STEP" USING WS-A-OPP WS-DX WS-DY WS-DZ
             COMPUTE WS-X = PC-X + WS-DX
             COMPUTE WS-Y = PC-Y + WS-DY
             COMPUTE WS-Z = PC-Z + WS-DZ
             CALL "PS-STAIR-AT" USING PC-DIM WS-X WS-Y WS-Z WS-C-FACING WS-C-HALF
             MOVE 1 TO WS-TAKE
             IF WS-C-HALF = WS-HALF AND WS-C-FACING = WS-F
                 MOVE 0 TO WS-TAKE
             END-IF
             IF WS-TAKE = 1
                 MOVE "outer_right" TO WS-SHAPE
                 IF WS-A-FACING = WS-CCW
                     MOVE "outer_left" TO WS-SHAPE
                 END-IF
                 MOVE 1 TO WS-DONE
             END-IF
         END-IF
     END-IF
*>   The back: the same test against the stair behind gives an inner corner.
     IF WS-DONE = 0
         CALL "PS-DIR-STEP" USING WS-OPP WS-DX WS-DY WS-DZ
         COMPUTE WS-X = PC-X + WS-DX
         COMPUTE WS-Y = PC-Y + WS-DY
         COMPUTE WS-Z = PC-Z + WS-DZ
         CALL "PS-STAIR-AT" USING PC-DIM WS-X WS-Y WS-Z WS-A-FACING WS-A-HALF
         IF WS-A-HALF = WS-HALF
             COMPUTE WS-AXIS-A = WS-A-FACING / 2
             IF WS-AXIS-A NOT = WS-AXIS-F
                 CALL "PS-DIR-STEP" USING WS-A-FACING WS-DX WS-DY WS-DZ
                 COMPUTE WS-X = PC-X + WS-DX
                 COMPUTE WS-Y = PC-Y + WS-DY
                 COMPUTE WS-Z = PC-Z + WS-DZ
                 CALL "PS-STAIR-AT" USING PC-DIM WS-X WS-Y WS-Z WS-C-FACING WS-C-HALF
                 MOVE 1 TO WS-TAKE
                 IF WS-C-HALF = WS-HALF AND WS-C-FACING = WS-F
                     MOVE 0 TO WS-TAKE
                 END-IF
                 IF WS-TAKE = 1
                     MOVE "inner_right" TO WS-SHAPE
                     IF WS-A-FACING = WS-CCW
                         MOVE "inner_left" TO WS-SHAPE
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-IF
     CALL "PS-PUT" USING PC-STATE WS-SHAPE-NAME WS-SHAPE
     GOBACK.
 END PROGRAM PS-STAIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-FULL-AT.
*> USING dimension row, x, y, z, full out: 1 when the block at the cell has a collision shape that is a full block (an opaque solid block: CB-SOLID and CB-OPAQUE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-STATE               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FULL                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FULL.
     MOVE 0 TO L-FULL
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     IF WS-STATE > 0 AND WS-STATE < CB-STATE-COUNT
         IF CB-SOLID(CB-S-BLOCK(WS-STATE + 1) + 1) = 1 AND CB-OPAQUE(CB-S-BLOCK(WS-STATE + 1) + 1) = 1
             MOVE 1 TO L-FULL
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PS-FULL-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-DOOR-LOWER-AT.
*> USING dimension row, x, y, z, flag out: 1 when the block at the cell is a door whose half is lower.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATE               BINARY-LONG.
 01 WS-NAME                PIC X(48).
 01 WS-SUFFIX              PIC X(24) VALUE "_door".
 01 WS-IS                  BINARY-LONG.
 01 WS-HALF                PIC X(24) VALUE "half".
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-FLAG.
     MOVE 0 TO L-FLAG
     CALL "WORLD-GET-BLOCK" USING L-DIM L-X L-Y L-Z WS-STATE
     CALL "PS-NAME-OF" USING WS-STATE WS-NAME
     CALL "PS-ENDS" USING WS-NAME WS-SUFFIX WS-IS
     IF WS-IS = 1
         CALL "PS-GET" USING WS-STATE WS-HALF WS-TEXT WS-FOUND
         IF FUNCTION TRIM(WS-TEXT) = "lower"
             MOVE 1 TO L-FLAG
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PS-DOOR-LOWER-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-DOOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-CW                  BINARY-LONG.
 01 WS-CCW                 BINARY-LONG.
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-HINGE-NAME          PIC X(24) VALUE "hinge".
 01 WS-HALF-NAME           PIC X(24) VALUE "half".
 01 WS-LOWER               PIC X(32) VALUE "lower".
 01 WS-TEXT                PIC X(32).
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-YU                  BINARY-LONG.
 01 WS-FULL                BINARY-LONG.
 01 WS-SCORE               BINARY-LONG.
 01 WS-LEFT-DOOR           BINARY-LONG.
 01 WS-RIGHT-DOOR          BINARY-LONG.
 01 WS-RIGHT               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
     MOVE PC-HDIR TO WS-D
     CALL "PS-DIR-NAME" USING WS-D WS-TEXT
     CALL "PS-PUT" USING PC-STATE WS-FACING-NAME WS-TEXT
     CALL "PS-PUT" USING PC-STATE WS-HALF-NAME WS-LOWER
     CALL "PS-CW" USING WS-D WS-CW
     CALL "PS-CCW" USING WS-D WS-CCW
     MOVE 0 TO WS-SCORE
     COMPUTE WS-YU = PC-Y + 1
*>   The side counter-clockwise of the player counts -1 for each full block beside the lower and the upper half, the clockwise side +1.
     CALL "PS-DIR-STEP" USING WS-CCW WS-DX WS-DY WS-DZ
     COMPUTE WS-X = PC-X + WS-DX
     COMPUTE WS-Z = PC-Z + WS-DZ
     CALL "PS-FULL-AT" USING PC-DIM WS-X PC-Y WS-Z WS-FULL
     SUBTRACT WS-FULL FROM WS-SCORE
     CALL "PS-FULL-AT" USING PC-DIM WS-X WS-YU WS-Z WS-FULL
     SUBTRACT WS-FULL FROM WS-SCORE
     CALL "PS-DOOR-LOWER-AT" USING PC-DIM WS-X PC-Y WS-Z WS-LEFT-DOOR
     CALL "PS-DIR-STEP" USING WS-CW WS-DX WS-DY WS-DZ
     COMPUTE WS-X = PC-X + WS-DX
     COMPUTE WS-Z = PC-Z + WS-DZ
     CALL "PS-FULL-AT" USING PC-DIM WS-X PC-Y WS-Z WS-FULL
     ADD WS-FULL TO WS-SCORE
     CALL "PS-FULL-AT" USING PC-DIM WS-X WS-YU WS-Z WS-FULL
     ADD WS-FULL TO WS-SCORE
     CALL "PS-DOOR-LOWER-AT" USING PC-DIM WS-X PC-Y WS-Z WS-RIGHT-DOOR
     EVALUATE TRUE
         WHEN (WS-LEFT-DOOR = 1 AND WS-RIGHT-DOOR = 0) OR WS-SCORE > 0
             MOVE 1 TO WS-RIGHT
         WHEN (WS-RIGHT-DOOR = 1 AND WS-LEFT-DOOR = 0) OR WS-SCORE < 0
             MOVE 0 TO WS-RIGHT
*>       A tie: the click point inside the cell decides, by the direction of the player (sx, sz).
         WHEN OTHER
             CALL "PS-DIR-STEP" USING WS-D WS-DX WS-DY WS-DZ
             COMPUTE WS-HX = PC-BX + PC-CX - PC-X
             COMPUTE WS-HZ = PC-BZ + PC-CZ - PC-Z
             MOVE 0 TO WS-RIGHT
             IF (WS-DX < 0 AND WS-HZ < 0.5) OR (WS-DX > 0 AND WS-HZ > 0.5) OR (WS-DZ < 0 AND WS-HX > 0.5) OR (WS-DZ > 0 AND WS-HX < 0.5)
                 MOVE 1 TO WS-RIGHT
             END-IF
     END-EVALUATE
     MOVE "left" TO WS-TEXT
     IF WS-RIGHT = 1
         MOVE "right" TO WS-TEXT
     END-IF
     CALL "PS-PUT" USING PC-STATE WS-HINGE-NAME WS-TEXT
     GOBACK.
 END PROGRAM PS-DOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PS-TRAPDOOR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OPP                 BINARY-LONG.
 01 WS-FACING-NAME         PIC X(24) VALUE "facing".
 01 WS-HALF-NAME           PIC X(24) VALUE "half".
 01 WS-TEXT                PIC X(32).
 LINKAGE SECTION.
 COPY PLACECTX.
 PROCEDURE DIVISION USING PLACE-CONTEXT.
     MOVE 1 TO PC-FITS
     IF PC-REPLACE = 0 AND PC-FACE > 1
         CALL "PS-DIR-NAME" USING PC-FACE WS-TEXT
         CALL "PS-PUT" USING PC-STATE WS-FACING-NAME WS-TEXT
         MOVE "bottom" TO WS-TEXT
         IF PC-CY > 0.5
             MOVE "top" TO WS-TEXT
         END-IF
         CALL "PS-PUT" USING PC-STATE WS-HALF-NAME WS-TEXT
     ELSE
         CALL "PS-OPP" USING PC-HDIR WS-OPP
         CALL "PS-DIR-NAME" USING WS-OPP WS-TEXT
         CALL "PS-PUT" USING PC-STATE WS-FACING-NAME WS-TEXT
         MOVE "top" TO WS-TEXT
         IF PC-FACE = 1
             MOVE "bottom" TO WS-TEXT
         END-IF
         CALL "PS-PUT" USING PC-STATE WS-HALF-NAME WS-TEXT
     END-IF
     GOBACK.
 END PROGRAM PS-TRAPDOOR.
