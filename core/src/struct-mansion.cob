*> The woodland mansion floor plan (docs/protocol/36-structures-7-woodland-mansion.md sections 4 and 5, MansionGrid): the grids of core/copy/STRUCTMAN.cpy, the corridor growth, the edge cleaning, the room
*> identification and the third floor, all drawing from SP-RNG (the start random, a java.util.Random, STRUCTPIECE.cpy). Grid numbers: 1 base, 2 third floor, 3 to 5 the room codes of floors 0 to 2.
*> Entry points: MNG-BUILD (the constructor, 5.1), MNG-GET and MNG-SET (cells, outside reads 5 and is not written), MNG-SETIF, MNG-FILL, MNG-HOUSE, MNG-EDGES-TO, MNG-DIR-STEP, MNG-DIR-2D,
*> MNG-CORRIDOR, MNG-CLEAN-EDGES, MNG-IDENTIFY, MNG-THIRD-FLOOR, MNG-BITS (the fields of a room code), MNG-ROOM-DIR (get1x2RoomDirection), MNG-HEX and MNG-CHECK (validation aids, 12 items 2 to 6).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-GET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X L-Y L-V.
     IF L-X < 0 OR L-X > 10 OR L-Y < 0 OR L-Y > 10
         MOVE 5 TO L-V
         GOBACK
     END-IF
     COMPUTE WS-I = L-Y * 11 + L-X + 1
     MOVE MN-CELL(L-G, WS-I) TO L-V
     GOBACK.
 END PROGRAM MNG-GET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-SET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X L-Y L-V.
     IF L-X < 0 OR L-X > 10 OR L-Y < 0 OR L-Y > 10
         GOBACK
     END-IF
     COMPUTE WS-I = L-Y * 11 + L-X + 1
     MOVE L-V TO MN-CELL(L-G, WS-I)
     GOBACK.
 END PROGRAM MNG-SET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-SETIF.
*> USING grid, x, y, a, b: set(x, y, b) only when the cell holds a (4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X L-Y L-A L-B.
     CALL "MNG-GET" USING L-G L-X L-Y WS-V
     IF WS-V = L-A
         CALL "MNG-SET" USING L-G L-X L-Y L-B
     END-IF
     GOBACK.
 END PROGRAM MNG-SETIF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-FILL.
*> USING grid, x0, y0, x1, y1, value: the inclusive rectangle, y in the outer loop (cells outside are ignored).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-V                    BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X0 L-Y0 L-X1 L-Y1 L-V.
     PERFORM VARYING WS-Y FROM L-Y0 BY 1 UNTIL WS-Y > L-Y1
         PERFORM VARYING WS-X FROM L-X0 BY 1 UNTIL WS-X > L-X1
             CALL "MNG-SET" USING L-G WS-X WS-Y L-V
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-FILL.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-HOUSE.
*> USING grid, x, y, flag out: isHouse, a cell of value 1 to 4 (4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X L-Y L-FLAG.
     CALL "MNG-GET" USING L-G L-X L-Y WS-V
     MOVE 0 TO L-FLAG
     IF WS-V >= 1 AND WS-V <= 4
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM MNG-HOUSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-EDGES-TO.
*> USING grid, x, y, value, flag out: 1 when one of the four orthogonal neighbours holds the value (4.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-V                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-VALUE                BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X L-Y L-VALUE L-FLAG.
     MOVE 0 TO L-FLAG
     COMPUTE WS-X = L-X - 1
     CALL "MNG-GET" USING L-G WS-X L-Y WS-V
     IF WS-V = L-VALUE
         MOVE 1 TO L-FLAG
     END-IF
     COMPUTE WS-X = L-X + 1
     CALL "MNG-GET" USING L-G WS-X L-Y WS-V
     IF WS-V = L-VALUE
         MOVE 1 TO L-FLAG
     END-IF
     COMPUTE WS-Y = L-Y + 1
     CALL "MNG-GET" USING L-G L-X WS-Y WS-V
     IF WS-V = L-VALUE
         MOVE 1 TO L-FLAG
     END-IF
     COMPUTE WS-Y = L-Y - 1
     CALL "MNG-GET" USING L-G L-X WS-Y WS-V
     IF WS-V = L-VALUE
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM MNG-EDGES-TO.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-DIR-STEP.
*> USING direction (0 north, 1 east, 2 south, 3 west), dx out, dz out (2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-DIR                  BINARY-LONG.
 01 L-DX                   BINARY-LONG.
 01 L-DZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-DX L-DZ.
     EVALUATE FUNCTION MOD(L-DIR, 4)
         WHEN 0
             MOVE 0 TO L-DX
             MOVE -1 TO L-DZ
         WHEN 1
             MOVE 1 TO L-DX
             MOVE 0 TO L-DZ
         WHEN 2
             MOVE 0 TO L-DX
             MOVE 1 TO L-DZ
         WHEN OTHER
             MOVE -1 TO L-DX
             MOVE 0 TO L-DZ
     END-EVALUATE
     GOBACK.
 END PROGRAM MNG-DIR-STEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-DIR-2D.
*> USING draw, direction out: Direction.from2DDataValue (0 south, 1 west, 2 north, 3 east; 2.1).
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-I                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-I L-DIR.
     COMPUTE L-DIR = FUNCTION MOD(L-I + 2, 4)
     GOBACK.
 END PROGRAM MNG-DIR-2D.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-CORRIDOR IS RECURSIVE.
*> USING grid, x, y, direction, depth: recursiveCorridor (5.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-ONE-BIT             BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LOCAL-STORAGE SECTION.
 01 LS-G                   BINARY-LONG.
 01 LS-X                   BINARY-LONG.
 01 LS-Y                   BINARY-LONG.
 01 LS-DIR                 BINARY-LONG.
 01 LS-DEPTH               BINARY-LONG.
 01 LS-DX                  BINARY-LONG.
 01 LS-DZ                  BINARY-LONG.
 01 LS-AX                  BINARY-LONG.
 01 LS-AY                  BINARY-LONG.
 01 LS-D                   BINARY-LONG.
 01 LS-DDX                 BINARY-LONG.
 01 LS-DDZ                 BINARY-LONG.
 01 LS-TRY                 BINARY-LONG.
 01 LS-DONE                BINARY-LONG.
 01 LS-DRAW                BINARY-LONG.
 01 LS-BIT                 BINARY-DOUBLE.
 01 LS-V1                  BINARY-LONG.
 01 LS-V2                  BINARY-LONG.
 01 LS-NX                  BINARY-LONG.
 01 LS-NY                  BINARY-LONG.
 01 LS-NDEPTH              BINARY-LONG.
 01 LS-C                   BINARY-LONG.
 01 LS-K                   BINARY-LONG.
 01 LS-CX                  BINARY-LONG.
 01 LS-CZ                  BINARY-LONG.
 01 LS-KX                  BINARY-LONG.
 01 LS-KZ                  BINARY-LONG.
 01 LS-SKIP                BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 01 L-DEPTH                BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-X L-Y L-DIR L-DEPTH.
     IF L-DEPTH <= 0
         GOBACK
     END-IF
     MOVE L-G TO LS-G
     MOVE L-X TO LS-X
     MOVE L-Y TO LS-Y
     MOVE L-DIR TO LS-DIR
     MOVE L-DEPTH TO LS-DEPTH
     CALL "MNG-SET" USING LS-G LS-X LS-Y WS-ONE
     CALL "MNG-DIR-STEP" USING LS-DIR LS-DX LS-DZ
     COMPUTE LS-AX = LS-X + LS-DX
     COMPUTE LS-AY = LS-Y + LS-DZ
     CALL "MNG-SETIF" USING LS-G LS-AX LS-AY WS-ZERO WS-ONE
     MOVE 0 TO LS-DONE
     PERFORM VARYING LS-TRY FROM 0 BY 1 UNTIL LS-TRY > 7 OR LS-DONE = 1
         CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-FOUR LS-DRAW
         CALL "MNG-DIR-2D" USING LS-DRAW LS-D
         MOVE 0 TO LS-SKIP
         IF LS-D = FUNCTION MOD(LS-DIR + 2, 4)
             MOVE 1 TO LS-SKIP
         END-IF
         IF LS-SKIP = 0 AND LS-D = 1
             CALL "JRAND-NEXT" USING SP-RNG WS-ONE-BIT LS-BIT
             IF LS-BIT NOT = 0
                 MOVE 1 TO LS-SKIP
             END-IF
         END-IF
         IF LS-SKIP = 0
             CALL "MNG-DIR-STEP" USING LS-D LS-DDX LS-DZ
             MOVE LS-DZ TO LS-DDZ
             COMPUTE LS-NX = LS-AX + LS-DDX
             COMPUTE LS-NY = LS-AY + LS-DDZ
             CALL "MNG-GET" USING LS-G LS-NX LS-NY LS-V1
             COMPUTE LS-CX = LS-AX + 2 * LS-DDX
             COMPUTE LS-CZ = LS-AY + 2 * LS-DDZ
             CALL "MNG-GET" USING LS-G LS-CX LS-CZ LS-V2
             IF LS-V1 = 0 AND LS-V2 = 0
                 COMPUTE LS-NDEPTH = LS-DEPTH - 1
                 CALL "MNG-CORRIDOR" USING LS-G LS-NX LS-NY LS-D LS-NDEPTH
                 MOVE 1 TO LS-DONE
             END-IF
         END-IF
     END-PERFORM
*>   step 4: the clear cells around become room cells
     CALL "MNG-DIR-STEP" USING LS-DIR LS-DX LS-DZ
     COMPUTE LS-C = FUNCTION MOD(LS-DIR + 1, 4)
     COMPUTE LS-K = FUNCTION MOD(LS-DIR + 3, 4)
     CALL "MNG-DIR-STEP" USING LS-C LS-CX LS-CZ
     CALL "MNG-DIR-STEP" USING LS-K LS-KX LS-KZ
     COMPUTE LS-NX = LS-X + LS-CX
     COMPUTE LS-NY = LS-Y + LS-CZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     COMPUTE LS-NX = LS-X + LS-KX
     COMPUTE LS-NY = LS-Y + LS-KZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     COMPUTE LS-NX = LS-X + LS-DX + LS-CX
     COMPUTE LS-NY = LS-Y + LS-DZ + LS-CZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     COMPUTE LS-NX = LS-X + LS-DX + LS-KX
     COMPUTE LS-NY = LS-Y + LS-DZ + LS-KZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     COMPUTE LS-NX = LS-X + 2 * LS-DX
     COMPUTE LS-NY = LS-Y + 2 * LS-DZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     COMPUTE LS-NX = LS-X + 2 * LS-CX
     COMPUTE LS-NY = LS-Y + 2 * LS-CZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     COMPUTE LS-NX = LS-X + 2 * LS-KX
     COMPUTE LS-NY = LS-Y + 2 * LS-KZ
     CALL "MNG-SETIF" USING LS-G LS-NX LS-NY WS-ZERO WS-TWO
     GOBACK.
 END PROGRAM MNG-CORRIDOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-CLEAN-EDGES.
*> USING grid, changed out (0 or 1): cleanEdges (5.3); no random draws.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-CHANGED              BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-CHANGED.
     MOVE 0 TO L-CHANGED
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING L-G WS-X WS-Y WS-V
             IF WS-V = 0
                 MOVE 0 TO WS-N
                 COMPUTE WS-NX = WS-X - 1
                 CALL "MNG-HOUSE" USING L-G WS-NX WS-Y WS-FLAG
                 ADD WS-FLAG TO WS-N
                 COMPUTE WS-NX = WS-X + 1
                 CALL "MNG-HOUSE" USING L-G WS-NX WS-Y WS-FLAG
                 ADD WS-FLAG TO WS-N
                 COMPUTE WS-NY = WS-Y - 1
                 CALL "MNG-HOUSE" USING L-G WS-X WS-NY WS-FLAG
                 ADD WS-FLAG TO WS-N
                 COMPUTE WS-NY = WS-Y + 1
                 CALL "MNG-HOUSE" USING L-G WS-X WS-NY WS-FLAG
                 ADD WS-FLAG TO WS-N
                 IF WS-N >= 3
                     CALL "MNG-SET" USING L-G WS-X WS-Y WS-TWO
                     MOVE 1 TO L-CHANGED
                 END-IF
                 IF WS-N = 2
                     MOVE 0 TO WS-M
                     COMPUTE WS-NX = WS-X - 1
                     COMPUTE WS-NY = WS-Y - 1
                     CALL "MNG-HOUSE" USING L-G WS-NX WS-NY WS-FLAG
                     ADD WS-FLAG TO WS-M
                     COMPUTE WS-NX = WS-X + 1
                     CALL "MNG-HOUSE" USING L-G WS-NX WS-NY WS-FLAG
                     ADD WS-FLAG TO WS-M
                     COMPUTE WS-NY = WS-Y + 1
                     CALL "MNG-HOUSE" USING L-G WS-NX WS-NY WS-FLAG
                     ADD WS-FLAG TO WS-M
                     COMPUTE WS-NX = WS-X - 1
                     CALL "MNG-HOUSE" USING L-G WS-NX WS-NY WS-FLAG
                     ADD WS-FLAG TO WS-M
                     IF WS-M <= 1
                         CALL "MNG-SET" USING L-G WS-X WS-Y WS-TWO
                         MOVE 1 TO L-CHANGED
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-CLEAN-EDGES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-BITS.
*> USING room code, id out, type out (1, 2 or 4), origin flag out, door flag out, stairs flag out, corridor flag out (4.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-Q                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CODE                 BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-ORIGIN               BINARY-LONG.
 01 L-DOOR                 BINARY-LONG.
 01 L-STAIRS               BINARY-LONG.
 01 L-CORR                 BINARY-LONG.
 PROCEDURE DIVISION USING L-CODE L-ID L-TYPE L-ORIGIN L-DOOR L-STAIRS L-CORR.
     COMPUTE L-ID = FUNCTION MOD(L-CODE, 65536)
     DIVIDE L-CODE BY 65536 GIVING WS-Q
     COMPUTE L-TYPE = FUNCTION MOD(WS-Q, 16)
     DIVIDE L-CODE BY 1048576 GIVING WS-Q
     COMPUTE L-ORIGIN = FUNCTION MOD(WS-Q, 2)
     DIVIDE L-CODE BY 2097152 GIVING WS-Q
     COMPUTE L-DOOR = FUNCTION MOD(WS-Q, 2)
     DIVIDE L-CODE BY 4194304 GIVING WS-Q
     COMPUTE L-STAIRS = FUNCTION MOD(WS-Q, 2)
     DIVIDE L-CODE BY 8388608 GIVING WS-Q
     COMPUTE L-CORR = FUNCTION MOD(WS-Q, 2)
     GOBACK.
 END PROGRAM MNG-BITS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-FR.
*> USING grid, rooms grid, x, y, flag out: 1 when the rooms cell is free (0) and the grid cell is a room cell (2), the test of the patterns of 5.4 step 2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-ROOMS                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-ROOMS L-X L-Y L-FLAG.
     CALL "MNG-GET" USING L-G L-X L-Y WS-A
     CALL "MNG-GET" USING L-ROOMS L-X L-Y WS-B
     MOVE 0 TO L-FLAG
     IF WS-A = 2 AND WS-B = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM MNG-FR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-ROOM.
*> USING grid, rooms grid, x, y, id: one room of identifyRooms (5.4 steps 2.1 to 2.5) starting at a free room cell: the first matching pattern, the origin corner and the door, the codes.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-X0                  BINARY-LONG.
 01 WS-X1                  BINARY-LONG.
 01 WS-Y0                  BINARY-LONG.
 01 WS-Y1                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-A2                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-DOOR                BINARY-LONG.
 01 WS-BIT                 BINARY-DOUBLE.
 01 WS-ONE-BIT             BINARY-LONG VALUE 1.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-FLAG                BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-F-E                 BINARY-LONG.
 01 WS-F-S                 BINARY-LONG.
 01 WS-F-SE                BINARY-LONG.
 01 WS-F-W                 BINARY-LONG.
 01 WS-F-SW                BINARY-LONG.
 01 WS-F-NW                BINARY-LONG.
 01 WS-F-N                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-ROOMS                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-ROOMS L-X L-Y L-ID.
     MOVE L-X TO WS-X0 WS-X1
     MOVE L-Y TO WS-Y0 WS-Y1
     MOVE 65536 TO WS-TYPE
     COMPUTE WS-NX = L-X + 1
     CALL "MNG-FR" USING L-G L-ROOMS WS-NX L-Y WS-F-E
     COMPUTE WS-NY = L-Y + 1
     CALL "MNG-FR" USING L-G L-ROOMS L-X WS-NY WS-F-S
     CALL "MNG-FR" USING L-G L-ROOMS WS-NX WS-NY WS-F-SE
     COMPUTE WS-NX = L-X - 1
     CALL "MNG-FR" USING L-G L-ROOMS WS-NX L-Y WS-F-W
     CALL "MNG-FR" USING L-G L-ROOMS WS-NX WS-NY WS-F-SW
     COMPUTE WS-NY = L-Y - 1
     CALL "MNG-FR" USING L-G L-ROOMS WS-NX WS-NY WS-F-NW
     CALL "MNG-FR" USING L-G L-ROOMS L-X WS-NY WS-F-N
     EVALUATE TRUE
         WHEN WS-F-E = 1 AND WS-F-S = 1 AND WS-F-SE = 1
             ADD 1 TO WS-X1
             ADD 1 TO WS-Y1
             MOVE 262144 TO WS-TYPE
         WHEN WS-F-W = 1 AND WS-F-S = 1 AND WS-F-SW = 1
             SUBTRACT 1 FROM WS-X0
             ADD 1 TO WS-Y1
             MOVE 262144 TO WS-TYPE
         WHEN WS-F-W = 1 AND WS-F-N = 1 AND WS-F-NW = 1
             SUBTRACT 1 FROM WS-X0
             SUBTRACT 1 FROM WS-Y0
             MOVE 262144 TO WS-TYPE
         WHEN WS-F-E = 1
             ADD 1 TO WS-X1
             MOVE 131072 TO WS-TYPE
         WHEN WS-F-S = 1
             ADD 1 TO WS-Y1
             MOVE 131072 TO WS-TYPE
         WHEN WS-F-W = 1
             SUBTRACT 1 FROM WS-X0
             MOVE 131072 TO WS-TYPE
         WHEN WS-F-N = 1
             SUBTRACT 1 FROM WS-Y0
             MOVE 131072 TO WS-TYPE
         WHEN OTHER
             CONTINUE
     END-EVALUATE
*>   the origin corner: two draws, then the corners in the order (a, b), (a', b'), (a', b), (a, b')
     CALL "JRAND-NEXT" USING SP-RNG WS-ONE-BIT WS-BIT
     MOVE WS-X1 TO WS-A
     IF WS-BIT NOT = 0
         MOVE WS-X0 TO WS-A
     END-IF
     CALL "JRAND-NEXT" USING SP-RNG WS-ONE-BIT WS-BIT
     MOVE WS-Y1 TO WS-B
     IF WS-BIT NOT = 0
         MOVE WS-Y0 TO WS-B
     END-IF
     MOVE 2097152 TO WS-DOOR
     MOVE WS-X0 TO WS-A2
     IF WS-A = WS-X0
         MOVE WS-X1 TO WS-A2
     END-IF
     MOVE WS-Y0 TO WS-B2
     IF WS-B = WS-Y0
         MOVE WS-Y1 TO WS-B2
     END-IF
     CALL "MNG-EDGES-TO" USING L-G WS-A WS-B WS-ONE WS-FLAG
     IF WS-FLAG = 0
         CALL "MNG-EDGES-TO" USING L-G WS-A2 WS-B2 WS-ONE WS-FLAG
         IF WS-FLAG = 1
             MOVE WS-A2 TO WS-A
             MOVE WS-B2 TO WS-B
         END-IF
     END-IF
     IF WS-FLAG = 0
         CALL "MNG-EDGES-TO" USING L-G WS-A2 WS-B WS-ONE WS-FLAG
         IF WS-FLAG = 1
             MOVE WS-A2 TO WS-A
         END-IF
     END-IF
     IF WS-FLAG = 0
         CALL "MNG-EDGES-TO" USING L-G WS-A WS-B2 WS-ONE WS-FLAG
         IF WS-FLAG = 1
             MOVE WS-B2 TO WS-B
         END-IF
     END-IF
     IF WS-FLAG = 0
         MOVE 0 TO WS-DOOR
         MOVE WS-X0 TO WS-A
         MOVE WS-Y0 TO WS-B
     END-IF
     PERFORM VARYING WS-Y FROM WS-Y0 BY 1 UNTIL WS-Y > WS-Y1
         PERFORM VARYING WS-X FROM WS-X0 BY 1 UNTIL WS-X > WS-X1
             COMPUTE WS-CODE = WS-TYPE + L-ID
             IF WS-X = WS-A AND WS-Y = WS-B
                 COMPUTE WS-CODE = WS-CODE + 1048576 + WS-DOOR
             END-IF
             CALL "MNG-SET" USING L-ROOMS WS-X WS-Y WS-CODE
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-ROOM.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-IDENTIFY.
*> USING grid, rooms grid: identifyRooms (5.4): the value-2 cells are shuffled and merged into rooms (MNG-ROOM), ids from 10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-LIST.
    05 WS-CELL             OCCURS 121 TIMES.
       10 WS-CX            BINARY-LONG.
       10 WS-CY            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-ORDERS.
    05 WS-ORDER            BINARY-LONG OCCURS 121 TIMES.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-G                    BINARY-LONG.
 01 L-ROOMS                BINARY-LONG.
 PROCEDURE DIVISION USING L-G L-ROOMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING L-G WS-X WS-Y WS-V
             IF WS-V = 2
                 ADD 1 TO WS-N
                 MOVE WS-X TO WS-CX(WS-N)
                 MOVE WS-Y TO WS-CY(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
*>   Util.shuffle (35-5 1.2) of the cell numbers
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE WS-I TO WS-ORDER(WS-I)
     END-PERFORM
     CALL "F355-SHUFFLE" USING WS-ORDERS WS-N SP-RNG
     MOVE 10 TO WS-ID
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE WS-ORDER(WS-I) TO WS-J
         MOVE WS-CX(WS-J) TO WS-X
         MOVE WS-CY(WS-J) TO WS-Y
         CALL "MNG-GET" USING L-ROOMS WS-X WS-Y WS-V
         IF WS-V = 0
             CALL "MNG-ROOM" USING L-G L-ROOMS WS-X WS-Y WS-ID
             ADD 1 TO WS-ID
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-IDENTIFY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-ROOM-DIR.
*> USING rooms grid, x, y, id, direction out: get1x2RoomDirection (5.5 step 4, 6.6): the first direction in the order north, east, south, west whose neighbour has the room id; 9 when none.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-D                   BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROOMS                BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-ID                   BINARY-LONG.
 01 L-DIR                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROOMS L-X L-Y L-ID L-DIR.
     MOVE 9 TO L-DIR
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3 OR L-DIR NOT = 9
         CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NY = L-Y + WS-DZ
         CALL "MNG-GET" USING L-ROOMS WS-NX WS-NY WS-V
         COMPUTE WS-ID = FUNCTION MOD(WS-V, 65536)
         IF WS-ID = L-ID
             MOVE WS-D TO L-DIR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-ROOM-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-THIRD-FLOOR.
*> setupThirdFloor (5.5): a door-bearing 1x2 room of floor 1 becomes the stair room and a depth-4 corridor grows from its far half; no candidate or no free side gives an all-5 grid.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTPIECE.
 01 WS-LIST.
    05 WS-CELL             OCCURS 121 TIMES.
       10 WS-CX            BINARY-LONG.
       10 WS-CY            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-DOOR                BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-CORR                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-VP                  BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-X2                  BINARY-LONG.
 01 WS-Y2                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-DIRS.
    05 WS-DIR              BINARY-LONG OCCURS 4 TIMES.
 01 WS-ND                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-THIRD               BINARY-LONG VALUE 2.
 01 WS-F1                  BINARY-LONG VALUE 4.
 01 WS-F2                  BINARY-LONG VALUE 5.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ELEVEN              BINARY-LONG VALUE 11.
 01 WS-ELEVEN2             BINARY-LONG VALUE 11.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-FLAG                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-CORR-FLAG           BINARY-LONG VALUE 8388608.
 PROCEDURE DIVISION.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING WS-F1 WS-X WS-Y WS-V
             CALL "MNG-BITS" USING WS-V WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
             IF WS-TYPE = 2 AND WS-DOOR = 1
                 ADD 1 TO WS-N
                 MOVE WS-X TO WS-CX(WS-N)
                 MOVE WS-Y TO WS-CY(WS-N)
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-N = 0
         CALL "MNG-FILL" USING WS-THIRD WS-ZERO WS-ZERO2 WS-ELEVEN WS-ELEVEN2 WS-FIVE
         GOBACK
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-N WS-DRAW
     COMPUTE WS-D = WS-DRAW + 1
     MOVE WS-CX(WS-D) TO WS-PX
     MOVE WS-CY(WS-D) TO WS-PY
     CALL "MNG-GET" USING WS-F1 WS-PX WS-PY WS-VP
     COMPUTE WS-V = WS-VP + 4194304
     CALL "MNG-SET" USING WS-F1 WS-PX WS-PY WS-V
     COMPUTE WS-ID = FUNCTION MOD(WS-VP, 65536)
     CALL "MNG-ROOM-DIR" USING WS-F1 WS-PX WS-PY WS-ID WS-D
     CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
     COMPUTE WS-X2 = WS-PX + WS-DX
     COMPUTE WS-Y2 = WS-PY + WS-DZ
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-HOUSE" USING WS-BASE WS-X WS-Y WS-FLAG
             EVALUATE TRUE
                 WHEN WS-FLAG = 0
                     CALL "MNG-SET" USING WS-THIRD WS-X WS-Y WS-FIVE
                 WHEN WS-X = WS-PX AND WS-Y = WS-PY
                     CALL "MNG-SET" USING WS-THIRD WS-X WS-Y WS-THREE
                 WHEN WS-X = WS-X2 AND WS-Y = WS-Y2
                     CALL "MNG-SET" USING WS-THIRD WS-X WS-Y WS-THREE
                     CALL "MNG-SET" USING WS-F2 WS-X WS-Y WS-CORR-FLAG
                 WHEN OTHER
                     CONTINUE
             END-EVALUATE
         END-PERFORM
     END-PERFORM
     MOVE 0 TO WS-ND
     PERFORM VARYING WS-D FROM 0 BY 1 UNTIL WS-D > 3
         CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
         COMPUTE WS-NX = WS-X2 + WS-DX
         COMPUTE WS-NY = WS-Y2 + WS-DZ
         CALL "MNG-GET" USING WS-THIRD WS-NX WS-NY WS-V
         IF WS-V = 0
             ADD 1 TO WS-ND
             MOVE WS-D TO WS-DIR(WS-ND)
         END-IF
     END-PERFORM
     IF WS-ND = 0
         CALL "MNG-FILL" USING WS-THIRD WS-ZERO WS-ZERO2 WS-ELEVEN WS-ELEVEN2 WS-FIVE
         CALL "MNG-SET" USING WS-F1 WS-PX WS-PY WS-VP
         GOBACK
     END-IF
     CALL "JRAND-NEXT-INT-BOUND" USING SP-RNG WS-ND WS-DRAW
     COMPUTE WS-D = WS-DRAW + 1
     MOVE WS-DIR(WS-D) TO WS-D
     CALL "MNG-DIR-STEP" USING WS-D WS-DX WS-DZ
     COMPUTE WS-NX = WS-X2 + WS-DX
     COMPUTE WS-NY = WS-Y2 + WS-DZ
     CALL "MNG-CORRIDOR" USING WS-THIRD WS-NX WS-NY WS-D WS-FOUR
     MOVE 1 TO WS-CHANGED
     PERFORM UNTIL WS-CHANGED = 0
         CALL "MNG-CLEAN-EDGES" USING WS-THIRD WS-CHANGED
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-THIRD-FLOOR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-BUILD.
*> The MansionGrid constructor (5.1) from the start random SP-RNG: the fixed shapes, the four corridor growths, the edge cleaning, the room identification of floors 0 and 1, the entrance carpets,
*> the third floor and its rooms.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY STRUCTMAN.
 01 WS-G                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-THIRD               BINARY-LONG VALUE 2.
 01 WS-R0                  BINARY-LONG VALUE 3.
 01 WS-R1                  BINARY-LONG VALUE 4.
 01 WS-R2                  BINARY-LONG VALUE 5.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-A1                  BINARY-LONG.
 01 WS-A2                  BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-G FROM 1 BY 1 UNTIL WS-G > 5
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 121
             MOVE 0 TO MN-CELL(WS-G, WS-I)
         END-PERFORM
     END-PERFORM
     MOVE 7 TO WS-A
     MOVE 4 TO WS-B
     MOVE 8 TO WS-C
     MOVE 5 TO WS-D
     MOVE 3 TO WS-V
     CALL "MNG-FILL" USING WS-BASE WS-A WS-B WS-C WS-D WS-V
     MOVE 6 TO WS-A
     MOVE 2 TO WS-V
     MOVE WS-A TO WS-A1
     CALL "MNG-FILL" USING WS-BASE WS-A WS-B WS-A1 WS-D WS-V
     MOVE 9 TO WS-A
     MOVE 2 TO WS-B
     MOVE 10 TO WS-C
     MOVE 7 TO WS-D
     MOVE 5 TO WS-V
     CALL "MNG-FILL" USING WS-BASE WS-A WS-B WS-C WS-D WS-V
     MOVE 8 TO WS-A
     MOVE 3 TO WS-D
     MOVE 1 TO WS-V
     MOVE WS-A TO WS-A1
     CALL "MNG-FILL" USING WS-BASE WS-A WS-B WS-A1 WS-D WS-V
     MOVE 6 TO WS-B
     MOVE 7 TO WS-D
     MOVE WS-A TO WS-A1
     CALL "MNG-FILL" USING WS-BASE WS-A WS-B WS-A1 WS-D WS-V
     MOVE 6 TO WS-A
     MOVE 3 TO WS-B
     CALL "MNG-SET" USING WS-BASE WS-A WS-B WS-V
     MOVE 6 TO WS-B
     CALL "MNG-SET" USING WS-BASE WS-A WS-B WS-V
     MOVE 0 TO WS-A
     MOVE 11 TO WS-C
     MOVE 1 TO WS-D
     MOVE 5 TO WS-V
     CALL "MNG-FILL" USING WS-BASE WS-A WS-A2 WS-C WS-D WS-V
     MOVE 9 TO WS-B
     MOVE 11 TO WS-D
     CALL "MNG-FILL" USING WS-BASE WS-A WS-B WS-C WS-D WS-V
*>   the four corridor growths, heading west
     MOVE 3 TO WS-DIR
     MOVE 6 TO WS-DEPTH
     MOVE 7 TO WS-A
     MOVE 2 TO WS-B
     CALL "MNG-CORRIDOR" USING WS-BASE WS-A WS-B WS-DIR WS-DEPTH
     MOVE 7 TO WS-B
     CALL "MNG-CORRIDOR" USING WS-BASE WS-A WS-B WS-DIR WS-DEPTH
     MOVE 3 TO WS-DEPTH
     MOVE 5 TO WS-A
     MOVE 3 TO WS-B
     CALL "MNG-CORRIDOR" USING WS-BASE WS-A WS-B WS-DIR WS-DEPTH
     MOVE 6 TO WS-B
     CALL "MNG-CORRIDOR" USING WS-BASE WS-A WS-B WS-DIR WS-DEPTH
     MOVE 1 TO WS-CHANGED
     PERFORM UNTIL WS-CHANGED = 0
         CALL "MNG-CLEAN-EDGES" USING WS-BASE WS-CHANGED
     END-PERFORM
     CALL "MNG-IDENTIFY" USING WS-BASE WS-R0
     CALL "MNG-IDENTIFY" USING WS-BASE WS-R1
     MOVE 8 TO WS-A
     MOVE 4 TO WS-B
     MOVE 5 TO WS-D
     MOVE 8388608 TO WS-V
     MOVE WS-A TO WS-A1
     CALL "MNG-FILL" USING WS-R0 WS-A WS-B WS-A1 WS-D WS-V
     CALL "MNG-FILL" USING WS-R1 WS-A WS-B WS-A1 WS-D WS-V
     CALL "MNG-THIRD-FLOOR"
     CALL "MNG-IDENTIFY" USING WS-THIRD WS-R2
     GOBACK.
 END PROGRAM MNG-BUILD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-HEX.
*> USING value, text out (PIC X(8)): the lower-case hex digits of a room code, "." for 0 (a test and diagnostic aid).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIGITS              PIC X(16) VALUE "0123456789abcdef".
 01 WS-Q                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-V                    BINARY-LONG.
 01 L-TEXT                 PIC X(8).
 PROCEDURE DIVISION USING L-V L-TEXT.
     MOVE SPACES TO L-TEXT
     IF L-V = 0
         MOVE "." TO L-TEXT
         GOBACK
     END-IF
     MOVE L-V TO WS-Q
     MOVE 8 TO WS-P
     PERFORM UNTIL WS-Q = 0
         COMPUTE WS-R = FUNCTION MOD(WS-Q, 16)
         DIVIDE WS-Q BY 16 GIVING WS-Q
         MOVE WS-DIGITS(WS-R + 1:1) TO L-TEXT(WS-P:1)
         SUBTRACT 1 FROM WS-P
     END-PERFORM
     GOBACK.
 END PROGRAM MNG-HEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MNG-CHECK.
*> USING violations out: the checks of 12 items 2 to 6 on the grids built: the border rows and columns, the entrance block, no fillable clear cell, the room partition of floors 0 and 1 (every room cell
*> coded, sizes, one origin per room, the door flag only next to a corridor, the origin of a door-less room at its minimum corner) and the third floor (a stairs flag exactly when the third grid
*> has its two stair cells, one corridor flag among them).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BAD                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-G                   BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ORIGIN              BINARY-LONG.
 01 WS-DOOR                BINARY-LONG.
 01 WS-STAIRS              BINARY-LONG.
 01 WS-CORR                BINARY-LONG.
 01 WS-CUR                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-ORIGINS             BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-MINX                BINARY-LONG.
 01 WS-MINY                BINARY-LONG.
 01 WS-OX                  BINARY-LONG.
 01 WS-OY                  BINARY-LONG.
 01 WS-ODOOR               BINARY-LONG.
 01 WS-STAIR-CELLS         BINARY-LONG.
 01 WS-STAIR-FLAGS         BINARY-LONG.
 01 WS-CORR-FLAGS          BINARY-LONG.
 01 WS-BASE                BINARY-LONG VALUE 1.
 01 WS-THIRD               BINARY-LONG VALUE 2.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-ROOMS               BINARY-LONG.
 LINKAGE SECTION.
 01 L-BAD                  BINARY-LONG.
 PROCEDURE DIVISION USING L-BAD.
     MOVE 0 TO WS-BAD
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING WS-BASE WS-X WS-Y WS-V
             IF (WS-Y < 2 OR WS-Y > 8) AND WS-V NOT = 5
                 ADD 1 TO WS-BAD
             END-IF
             IF WS-X > 8 AND WS-Y > 1 AND WS-Y < 8 AND WS-V NOT = 5
                 ADD 1 TO WS-BAD
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE 7 TO WS-X
     MOVE 4 TO WS-Y
     CALL "MNG-GET" USING WS-BASE WS-X WS-Y WS-V
     IF WS-V NOT = 3
         ADD 1 TO WS-BAD
     END-IF
     MOVE 6 TO WS-X
     CALL "MNG-GET" USING WS-BASE WS-X WS-Y WS-V
     IF WS-V NOT = 2
         ADD 1 TO WS-BAD
     END-IF
     CALL "MNG-CLEAN-EDGES" USING WS-BASE WS-CHANGED
     ADD WS-CHANGED TO WS-BAD
*>   the room partition of floors 0 and 1
     PERFORM VARYING WS-F FROM 3 BY 1 UNTIL WS-F > 4
         PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
                 CALL "MNG-GET" USING WS-BASE WS-X WS-Y WS-V
                 CALL "MNG-GET" USING WS-F WS-X WS-Y WS-CUR
                 IF WS-V = 2 AND (WS-CUR = 0 OR FUNCTION MOD(WS-CUR, 65536) < 10)
                     ADD 1 TO WS-BAD
                 END-IF
             END-PERFORM
         END-PERFORM
         PERFORM VARYING WS-ID FROM 10 BY 1 UNTIL WS-ID > 140
             MOVE 0 TO WS-COUNT WS-ORIGINS WS-TYPE WS-ODOOR
             MOVE 99 TO WS-MINX WS-MINY
             PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
                 PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
                     CALL "MNG-GET" USING WS-F WS-X WS-Y WS-V
                     IF WS-V NOT = 5 AND FUNCTION MOD(WS-V, 65536) = WS-ID AND WS-V NOT = 0
                         CALL "MNG-BITS" USING WS-V WS-G WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
                         ADD 1 TO WS-COUNT
                         IF WS-X < WS-MINX
                             MOVE WS-X TO WS-MINX
                         END-IF
                         IF WS-Y < WS-MINY
                             MOVE WS-Y TO WS-MINY
                         END-IF
                         IF WS-ORIGIN = 1
                             ADD 1 TO WS-ORIGINS
                             MOVE WS-X TO WS-OX
                             MOVE WS-Y TO WS-OY
                             MOVE WS-DOOR TO WS-ODOOR
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
             IF WS-COUNT > 0
                 EVALUATE WS-TYPE
                     WHEN 1
                         MOVE 1 TO WS-SIZE
                     WHEN 2
                         MOVE 2 TO WS-SIZE
                     WHEN OTHER
                         MOVE 4 TO WS-SIZE
                 END-EVALUATE
                 IF WS-COUNT NOT = WS-SIZE OR WS-ORIGINS NOT = 1
                     ADD 1 TO WS-BAD
                 END-IF
                 IF WS-ODOOR = 1
                     CALL "MNG-EDGES-TO" USING WS-BASE WS-OX WS-OY WS-ONE WS-CHANGED
                     IF WS-CHANGED = 0
                         ADD 1 TO WS-BAD
                     END-IF
                 ELSE
                     IF WS-OX NOT = WS-MINX OR WS-OY NOT = WS-MINY
                         ADD 1 TO WS-BAD
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
*>   the third floor
     MOVE 0 TO WS-STAIR-CELLS WS-STAIR-FLAGS WS-CORR-FLAGS
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 10
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 10
             CALL "MNG-GET" USING WS-THIRD WS-X WS-Y WS-V
             IF WS-V = 3
                 ADD 1 TO WS-STAIR-CELLS
             END-IF
             MOVE 4 TO WS-F
             CALL "MNG-GET" USING WS-F WS-X WS-Y WS-V
             CALL "MNG-BITS" USING WS-V WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
             ADD WS-STAIRS TO WS-STAIR-FLAGS
             MOVE 5 TO WS-F
             CALL "MNG-GET" USING WS-F WS-X WS-Y WS-V
             IF WS-V NOT = 5
                 CALL "MNG-BITS" USING WS-V WS-ID WS-TYPE WS-ORIGIN WS-DOOR WS-STAIRS WS-CORR
                 ADD WS-CORR TO WS-CORR-FLAGS
             END-IF
         END-PERFORM
     END-PERFORM
     IF WS-STAIR-CELLS = 0
         IF WS-STAIR-FLAGS NOT = 0 OR WS-CORR-FLAGS NOT = 0
             ADD 1 TO WS-BAD
         END-IF
     ELSE
         IF WS-STAIR-CELLS NOT = 2 OR WS-STAIR-FLAGS NOT = 1 OR WS-CORR-FLAGS NOT = 1
             ADD 1 TO WS-BAD
         END-IF
     END-IF
     MOVE WS-BAD TO L-BAD
     GOBACK.
 END PROGRAM MNG-CHECK.
