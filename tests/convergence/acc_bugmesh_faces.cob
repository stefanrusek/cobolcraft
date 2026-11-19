*> Convergence acceptance test of the operator report "lots of blocks aren't rendering: logs, leaf litter, oak leaves, crafting bench, path blocks;
*> holes in the grass floor through which the sky shows" (try14 play; bug lane bugmesh). One standard single-player world (the host's in-process core,
*> real generated chunks of CC_GENERATED_DIR, view distance BM_VIEW, default 3, seed BM_SEED, default random) is stepped until every section with
*> cells is meshed. Then the faces the section meshes hold are compared with the faces the cells call for, by a model that does not use the mesher's
*> tables: a cell that is a full cube (an opaque state, or leaves) has a full-size quad on the plane of each face whose neighbour (read through the
*> replica, across chunk borders too) is not opaque (air, a plant, leaves, glass, a fluid; a neighbour of the same block with ST-LIKE hides it; a neighbour that occludes by its shape, a carpet or a
*> slab, may cover the face and is left to the shape tables); any other cell
*> with a baked model that has an air neighbour has at least one quad inside its cube. A face the mesh lacks is a hole: the cell is hollow there.
*> The missing faces are counted by block name (MISSING lines); the case asserts none are missing.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGMESH-FACES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY COREAPI.
 COPY CELLS.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugmesh-faces".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 24.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "BugFaces".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-ENV                 PIC X(64).
 01 WS-VIEW                BINARY-LONG VALUE 3.
 01 WS-FRAMES              BINARY-LONG VALUE 3000.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CHUNKS              BINARY-LONG.
 01 WS-DIRTY-CONTENT       BINARY-LONG.
 01 WS-QUIET               BINARY-LONG VALUE 0.
 01 WS-BASE                BINARY-LONG.
 01 WS-Q                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-QUADS               BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SHOWN               BINARY-LONG VALUE 0.
 01 WS-D3                  PIC 9(7).
 01 WS-D3B                 PIC 9(7).
 01 WS-D3C                 PIC 9(7).
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FACES.
    05 WS-FACE             PIC 9 OCCURS 24576 TIMES.
 01 WS-EMPTY-COLS          BINARY-LONG.
 01 WS-PITS                BINARY-LONG.
 01 WS-COLS                BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-COL-AT              BINARY-LONG.
 01 WS-COL-TOPS.
    05 WS-COL-TOP          BINARY-LONG OCCURS 256 TIMES.
 01 WS-STALE               BINARY-LONG.
 01 WS-REMESHED            BINARY-LONG.
 01 WS-OLD-OP              BINARY-LONG.
 01 WS-OLD-TR              BINARY-LONG.
 01 WS-VERTS-SEEN          BINARY-LONG VALUE 0.
 01 WS-BAD-POS             BINARY-LONG VALUE 0.
 01 WS-BAD-UV              BINARY-LONG VALUE 0.
 01 WS-BAD-TERM            BINARY-LONG VALUE 0.
 01 WS-MINFRAMES           BINARY-LONG VALUE 0.
 01 WS-TPX                 BINARY-LONG.
 01 WS-SAY                 PIC X(64).
 01 WS-SAY-LENGTH          BINARY-LONG.
 01 WS-FULLQ               BINARY-LONG.
 01 WS-ANYS.
    05 WS-ANY              PIC 9 OCCURS 4096 TIMES.
 01 WS-KINDS.
    05 WS-KIND-OF          PIC 9 OCCURS 65536 TIMES.
 01 WS-KEYS.
    05 WS-KEY-NAME         PIC X(32) OCCURS 512 TIMES.
    05 WS-KEY-CHECKED      BINARY-LONG OCCURS 512 TIMES.
    05 WS-KEY-MISSING      BINARY-LONG OCCURS 512 TIMES.
 01 WS-KEY-COUNT           BINARY-LONG VALUE 0.
 01 WS-KEY-AT              BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-BNAME                PIC X(32).
 01 WS-NHIT                BINARY-LONG.
 01 WS-STRICT              BINARY-LONG.
 01 WS-FDIR                 BINARY-LONG.
 01 WS-NSTATE              BINARY-LONG.
 01 WS-NSKY                BINARY-LONG.
 01 WS-NBLOCK              BINARY-LONG.
 01 WS-NB-CELL             BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-WX                  BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-WZ                  BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-HAS-AIR             BINARY-LONG.
 01 WS-BM                  BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-AX                  BINARY-LONG.
 01 WS-C1                  BINARY-LONG.
 01 WS-C2                  BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-CELLS-CHECKED       BINARY-LONG VALUE 0.
 01 WS-ANY-MISSING         BINARY-LONG VALUE 0.
 01 WS-FACES-MISSING       BINARY-LONG VALUE 0.
 01 WS-FACES-CHECKED       BINARY-LONG VALUE 0.
 01 WS-ADDR                USAGE POINTER.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VROW.
    05 WS-VF               FLOAT-SHORT OCCURS 11 TIMES.
 01 B-VERT                 PIC X(6488064) BASED.
 01 B-CELLS                PIC X(196608) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_VIEW"
     IF WS-ENV NOT = SPACES
         COMPUTE WS-VIEW = FUNCTION NUMVAL(WS-ENV)
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     MOVE SP-SETTINGS TO CORE-SETTINGS
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_SEED"
     MOVE WS-ENV TO CS-SEED-TEXT
     MOVE WS-VIEW TO CS-VIEW-DISTANCE
     MOVE CORE-SETTINGS TO SP-SETTINGS
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     MOVE 0 TO WS-JOINED
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 20 OR WS-JOINED = 1
         CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
         IF WS-JOINED = 0
             CALL "C$SLEEP" USING 1
         END-IF
     END-PERFORM
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
*>   BM_TP (blocks, default none): the player flies there (/tp x 120 z) at once, the chunks of the first place are forgotten and their rows
*>   taken by the chunks of the new one while the meshes of both are made: the checks below hold at the new place the same.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "BM_TP"
     MOVE 0 TO WS-MINFRAMES
     IF WS-ENV NOT = SPACES
         COMPUTE WS-TPX = FUNCTION NUMVAL(WS-ENV)
         MOVE SPACES TO WS-SAY
         MOVE WS-TPX TO WS-D3
         STRING "/tp " WS-D3 " 120 " WS-D3 DELIMITED BY SIZE INTO WS-SAY
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-SAY)) TO WS-SAY-LENGTH
         CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         MOVE 600 TO WS-MINFRAMES
     END-IF
     MOVE 0 TO WS-QUIET
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES OR (WS-QUIET >= 10 AND WS-F > WS-MINFRAMES)
         CALL "CV-STEP" USING CONVH
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         MOVE 0 TO WS-DIRTY-CONTENT WS-CHUNKS
         PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
             IF WR-USED(WS-R) = 1
                 ADD 1 TO WS-CHUNKS
                 SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-R)
                 SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                     IF WR-DIRTY(WS-R, WS-S) = 1
                         COMPUTE WS-BASE = (WS-S - 1) * 4096
                         IF B-CELLS(WS-BASE * 2 + 1:8192) NOT = LOW-VALUES
                             ADD 1 TO WS-DIRTY-CONTENT
                         END-IF
                     END-IF
                 END-PERFORM
             END-IF
         END-PERFORM
         IF WS-DIRTY-CONTENT = 0 AND WS-CHUNKS >= (2 * WS-VIEW + 1) * (2 * WS-VIEW + 1) - 4 * WS-VIEW
             ADD 1 TO WS-QUIET
         ELSE
             MOVE 0 TO WS-QUIET
         END-IF
     END-PERFORM
     MOVE WS-CHUNKS TO WS-D3
     MOVE WS-DIRTY-CONTENT TO WS-D3B
     DISPLAY "frames " WS-F " chunks " WS-D3 " dirty-with-cells " WS-D3B

*>   Every section: the faces its two meshes hold, then the cells that call for faces.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-R)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 MOVE ALL "0" TO WS-FACES WS-ANYS
                 PERFORM VARYING WS-LIST FROM 1 BY 1 UNTIL WS-LIST > 2
                     IF WS-LIST = 1
                         COMPUTE WS-QUADS = WR-OP-COUNT(WS-R, WS-S) / 6
                         SET WS-ADDR TO WR-OP-ADDR(WS-R, WS-S)
                     ELSE
                         COMPUTE WS-QUADS = WR-TR-COUNT(WS-R, WS-S) / 6
                         SET WS-ADDR TO WR-TR-ADDR(WS-R, WS-S)
                     END-IF
                     IF WS-QUADS > 0
                         SET ADDRESS OF B-VERT TO WS-ADDR
                     END-IF
                     PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q >= WS-QUADS
                         MOVE 1000 TO WS-MINX WS-MINY WS-MINZ
                         MOVE -1000 TO WS-MAXX WS-MAXY WS-MAXZ
                         PERFORM VARYING WS-V FROM 0 BY 1 UNTIL WS-V > 5
                             COMPUTE WS-OFF = (WS-Q * 6 + WS-V) * 44 + 1
                             MOVE B-VERT(WS-OFF:44) TO WS-VROW
*>                           Every vertex is a number in range: position 0 to 16 (the section's cells), texture coordinates and the brightness, alpha,
*>                           sky and tint terms 0 to 1 (a value that is not a number, or out of range, draws a black or a missing face).
                             ADD 1 TO WS-VERTS-SEEN
                             IF NOT (WS-VF(1) >= -0.01 AND WS-VF(1) <= 16.01 AND WS-VF(2) >= -0.01 AND WS-VF(2) <= 16.01
                                     AND WS-VF(3) >= -0.01 AND WS-VF(3) <= 16.01)
                                 ADD 1 TO WS-BAD-POS
                             END-IF
                             IF NOT (WS-VF(4) >= 0 AND WS-VF(4) <= 1 AND WS-VF(5) >= 0 AND WS-VF(5) <= 1)
                                 ADD 1 TO WS-BAD-UV
                             END-IF
                             IF NOT (WS-VF(6) >= 0 AND WS-VF(6) <= 1 AND WS-VF(7) >= 0 AND WS-VF(7) <= 1 AND WS-VF(8) >= 0 AND WS-VF(8) <= 1
                                     AND WS-VF(9) >= 0 AND WS-VF(9) <= 1 AND WS-VF(10) >= 0 AND WS-VF(10) <= 1 AND WS-VF(11) >= 0 AND WS-VF(11) <= 1)
                                 ADD 1 TO WS-BAD-TERM
                                 IF WS-BAD-TERM <= 5
                                     DISPLAY "BAD terms chunk " WR-CX(WS-R) "," WR-CZ(WS-R) " section " WS-S " b " WS-VF(6) " a " WS-VF(7) " s " WS-VF(8)
                                         " rgb " WS-VF(9) " " WS-VF(10) " " WS-VF(11)
                                 END-IF
                             END-IF
                             IF WS-VF(1) < WS-MINX
                                 MOVE WS-VF(1) TO WS-MINX
                             END-IF
                             IF WS-VF(1) > WS-MAXX
                                 MOVE WS-VF(1) TO WS-MAXX
                             END-IF
                             IF WS-VF(2) < WS-MINY
                                 MOVE WS-VF(2) TO WS-MINY
                             END-IF
                             IF WS-VF(2) > WS-MAXY
                                 MOVE WS-VF(2) TO WS-MAXY
                             END-IF
                             IF WS-VF(3) < WS-MINZ
                                 MOVE WS-VF(3) TO WS-MINZ
                             END-IF
                             IF WS-VF(3) > WS-MAXZ
                                 MOVE WS-VF(3) TO WS-MAXZ
                             END-IF
                         END-PERFORM
*>                       The cells the quad lies in, for the "any quad" mark: along an axis its extent spans floor(min + hair) to floor(max - hair); a
*>                       quad with no extent along an axis lies on a plane, and on an integer plane (a cell boundary) it belongs to the cells on both sides.
*>                       A full-size quad on an integer plane is a cube face (marked in WS-FACE below, not here: it belongs to one of the two cells).
                         MOVE 0 TO WS-FULLQ
                         IF (WS-MAXX - WS-MINX < 0.001 AND WS-MAXY - WS-MINY > 0.99 AND WS-MAXZ - WS-MINZ > 0.99)
                                 OR (WS-MAXY - WS-MINY < 0.001 AND WS-MAXX - WS-MINX > 0.99 AND WS-MAXZ - WS-MINZ > 0.99)
                                 OR (WS-MAXZ - WS-MINZ < 0.001 AND WS-MAXX - WS-MINX > 0.99 AND WS-MAXY - WS-MINY > 0.99)
                             COMPUTE WS-FX = WS-MINX - FUNCTION INTEGER(WS-MINX + 0.5)
                             IF WS-MAXX - WS-MINX < 0.001
                                 IF FUNCTION ABS(WS-FX) < 0.0005
                                     MOVE 1 TO WS-FULLQ
                                 END-IF
                             END-IF
                             COMPUTE WS-FX = WS-MINY - FUNCTION INTEGER(WS-MINY + 0.5)
                             IF WS-MAXY - WS-MINY < 0.001
                                 IF FUNCTION ABS(WS-FX) < 0.0005
                                     MOVE 1 TO WS-FULLQ
                                 END-IF
                             END-IF
                             COMPUTE WS-FX = WS-MINZ - FUNCTION INTEGER(WS-MINZ + 0.5)
                             IF WS-MAXZ - WS-MINZ < 0.001
                                 IF FUNCTION ABS(WS-FX) < 0.0005
                                     MOVE 1 TO WS-FULLQ
                                 END-IF
                             END-IF
                         END-IF
                         IF WS-FULLQ = 0
                             COMPUTE WS-PX = FUNCTION INTEGER(WS-MINX + 0.0005)
                             COMPUTE WS-AX = FUNCTION INTEGER(WS-MAXX - 0.0005)
                             COMPUTE WS-PY = FUNCTION INTEGER(WS-MINY + 0.0005)
                             COMPUTE WS-C1 = FUNCTION INTEGER(WS-MAXY - 0.0005)
                             COMPUTE WS-PZ = FUNCTION INTEGER(WS-MINZ + 0.0005)
                             COMPUTE WS-C2 = FUNCTION INTEGER(WS-MAXZ - 0.0005)
                             IF WS-PX > WS-AX
                                 COMPUTE WS-PX = WS-AX
                                 IF FUNCTION ABS(WS-MINX - FUNCTION INTEGER(WS-MINX + 0.5)) < 0.0005
                                     COMPUTE WS-PX = FUNCTION INTEGER(WS-MINX + 0.5) - 1
                                     COMPUTE WS-AX = WS-PX + 1
                                 END-IF
                             END-IF
                             IF WS-PY > WS-C1
                                 COMPUTE WS-PY = WS-C1
                                 IF FUNCTION ABS(WS-MINY - FUNCTION INTEGER(WS-MINY + 0.5)) < 0.0005
                                     COMPUTE WS-PY = FUNCTION INTEGER(WS-MINY + 0.5) - 1
                                     COMPUTE WS-C1 = WS-PY + 1
                                 END-IF
                             END-IF
                             IF WS-PZ > WS-C2
                                 COMPUTE WS-PZ = WS-C2
                                 IF FUNCTION ABS(WS-MINZ - FUNCTION INTEGER(WS-MINZ + 0.5)) < 0.0005
                                     COMPUTE WS-PZ = FUNCTION INTEGER(WS-MINZ + 0.5) - 1
                                     COMPUTE WS-C2 = WS-PZ + 1
                                 END-IF
                             END-IF
                             PERFORM VARYING WS-CX FROM WS-PX BY 1 UNTIL WS-CX > WS-AX
                              PERFORM VARYING WS-CY FROM WS-PY BY 1 UNTIL WS-CY > WS-C1
                               PERFORM VARYING WS-CZ FROM WS-PZ BY 1 UNTIL WS-CZ > WS-C2
                                 IF WS-CX >= 0 AND WS-CX <= 15 AND WS-CY >= 0 AND WS-CY <= 15 AND WS-CZ >= 0 AND WS-CZ <= 15
                                     COMPUTE WS-CELL = WS-CY * 256 + WS-CZ * 16 + WS-CX + 1
                                     MOVE 1 TO WS-ANY(WS-CELL)
                                 END-IF
                               END-PERFORM
                              END-PERFORM
                             END-PERFORM
                         END-IF
*>                       A full-size quad on an integer plane marks the face of the cells on both sides of the plane.
                         IF WS-MAXX - WS-MINX < 0.001 AND WS-MAXY - WS-MINY > 0.99 AND WS-MAXZ - WS-MINZ > 0.99
                             COMPUTE WS-C1 = FUNCTION INTEGER(WS-MINX + 0.5)
                             COMPUTE WS-CY = FUNCTION INTEGER(WS-MINY + 0.5)
                             COMPUTE WS-CZ = FUNCTION INTEGER(WS-MINZ + 0.5)
                             IF WS-C1 - 1 >= 0 AND WS-C1 - 1 <= 15 AND WS-CY <= 15 AND WS-CZ <= 15
                                 COMPUTE WS-CELL = (WS-CY * 16 + WS-CZ) * 16 + WS-C1 - 1 + 1
                                 COMPUTE WS-CELL = (WS-CELL - 1) * 6 + 6
                                 MOVE 1 TO WS-FACE(WS-CELL)
                             END-IF
                             IF WS-C1 >= 0 AND WS-C1 <= 15 AND WS-CY <= 15 AND WS-CZ <= 15
                                 COMPUTE WS-CELL = (WS-CY * 16 + WS-CZ) * 16 + WS-C1 + 1
                                 COMPUTE WS-CELL = (WS-CELL - 1) * 6 + 5
                                 MOVE 1 TO WS-FACE(WS-CELL)
                             END-IF
                         END-IF
                         IF WS-MAXY - WS-MINY < 0.001 AND WS-MAXX - WS-MINX > 0.99 AND WS-MAXZ - WS-MINZ > 0.99
                             COMPUTE WS-CX = FUNCTION INTEGER(WS-MINX + 0.5)
                             COMPUTE WS-C1 = FUNCTION INTEGER(WS-MINY + 0.5)
                             COMPUTE WS-CZ = FUNCTION INTEGER(WS-MINZ + 0.5)
                             IF WS-C1 - 1 >= 0 AND WS-C1 - 1 <= 15 AND WS-CX <= 15 AND WS-CZ <= 15
                                 COMPUTE WS-CELL = ((WS-C1 - 1) * 16 + WS-CZ) * 16 + WS-CX + 1
                                 COMPUTE WS-CELL = (WS-CELL - 1) * 6 + 2
                                 MOVE 1 TO WS-FACE(WS-CELL)
                             END-IF
                             IF WS-C1 >= 0 AND WS-C1 <= 15 AND WS-CX <= 15 AND WS-CZ <= 15
                                 COMPUTE WS-CELL = (WS-C1 * 16 + WS-CZ) * 16 + WS-CX + 1
                                 COMPUTE WS-CELL = (WS-CELL - 1) * 6 + 1
                                 MOVE 1 TO WS-FACE(WS-CELL)
                             END-IF
                         END-IF
                         IF WS-MAXZ - WS-MINZ < 0.001 AND WS-MAXX - WS-MINX > 0.99 AND WS-MAXY - WS-MINY > 0.99
                             COMPUTE WS-CX = FUNCTION INTEGER(WS-MINX + 0.5)
                             COMPUTE WS-CY = FUNCTION INTEGER(WS-MINY + 0.5)
                             COMPUTE WS-C1 = FUNCTION INTEGER(WS-MINZ + 0.5)
                             IF WS-C1 - 1 >= 0 AND WS-C1 - 1 <= 15 AND WS-CX <= 15 AND WS-CY <= 15
                                 COMPUTE WS-CELL = (WS-CY * 16 + WS-C1 - 1) * 16 + WS-CX + 1
                                 COMPUTE WS-CELL = (WS-CELL - 1) * 6 + 4
                                 MOVE 1 TO WS-FACE(WS-CELL)
                             END-IF
                             IF WS-C1 >= 0 AND WS-C1 <= 15 AND WS-CX <= 15 AND WS-CY <= 15
                                 COMPUTE WS-CELL = (WS-CY * 16 + WS-C1) * 16 + WS-CX + 1
                                 COMPUTE WS-CELL = (WS-CELL - 1) * 6 + 3
                                 MOVE 1 TO WS-FACE(WS-CELL)
                             END-IF
                         END-IF
                     END-PERFORM
                 END-PERFORM
                 PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 15
                  PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
                   PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                     COMPUTE WS-CELL = (WS-S - 1) * 4096 + WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE CE-STATE(WS-CELL) TO WS-STATE
                     IF WS-STATE > 0
                         PERFORM CHECK-CELL
                     END-IF
                   END-PERFORM
                  END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
*>   A mesh is what its section's cells and the cells around them give: meshing every section again changes none of the vertex counts (a section
*>   whose mesh is out of date, because nothing marked it dirty when its neighbours changed, would draw faces that are gone or lack ones that are due).
     MOVE 0 TO WS-STALE WS-REMESHED
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 IF WR-DIRTY(WS-R, WS-S) = 0
                     COMPUTE WS-OLD-OP = WR-OP-COUNT(WS-R, WS-S)
                     COMPUTE WS-OLD-TR = WR-TR-COUNT(WS-R, WS-S)
                     CALL "MESH-SECTION" USING CLIENT-STATE WS-R WS-S
                     ADD 1 TO WS-REMESHED
                     IF WS-OLD-OP NOT = WR-OP-COUNT(WS-R, WS-S) OR WS-OLD-TR NOT = WR-TR-COUNT(WS-R, WS-S)
                         ADD 1 TO WS-STALE
                         IF WS-STALE <= 10
                             DISPLAY "STALE chunk " WR-CX(WS-R) "," WR-CZ(WS-R) " section " WS-S " opaque " WS-OLD-OP " now " WR-OP-COUNT(WS-R, WS-S)
                                 " translucent " WS-OLD-TR " now " WR-TR-COUNT(WS-R, WS-S)
                         END-IF
                     END-IF
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     DISPLAY "vertices " WS-VERTS-SEEN " bad position " WS-BAD-POS " bad uv " WS-BAD-UV " bad terms " WS-BAD-TERM
     DISPLAY "sections meshed again " WS-REMESHED " out of date " WS-STALE
*>   Every column of every chunk holds at least one opaque cell (a column of only air from the bottom to the top would show the sky through the
*>   ground) and the surface of a column is never two or more cells below all four of its neighbours' with air between (a pit one cell wide).
     MOVE 0 TO WS-EMPTY-COLS WS-PITS WS-COLS
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-R)
             PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
                 PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                     MOVE 0 TO WS-TOP
                     PERFORM VARYING WS-LY FROM 383 BY -1 UNTIL WS-LY < 0 OR WS-TOP > 0
                         COMPUTE WS-CELL = WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
                         MOVE CE-STATE(WS-CELL) TO WS-STATE
                         IF WS-STATE > 0
                             IF ST-OPAQUE(WS-STATE + 1) = 1
                                 COMPUTE WS-TOP = WS-LY + 1
                             END-IF
                         END-IF
                     END-PERFORM
                     COMPUTE WS-COL-AT = WS-LZ * 16 + WS-LX + 1
                     MOVE WS-TOP TO WS-COL-TOP(WS-COL-AT)
                     ADD 1 TO WS-COLS
                     IF WS-TOP = 0
                         ADD 1 TO WS-EMPTY-COLS
                     END-IF
                 END-PERFORM
             END-PERFORM
             PERFORM VARYING WS-LZ FROM 1 BY 1 UNTIL WS-LZ > 14
                 PERFORM VARYING WS-LX FROM 1 BY 1 UNTIL WS-LX > 14
                     COMPUTE WS-COL-AT = WS-LZ * 16 + WS-LX + 1
                     MOVE WS-COL-TOP(WS-COL-AT - 1) TO WS-LOW
                     IF WS-COL-TOP(WS-COL-AT + 1) < WS-LOW
                         MOVE WS-COL-TOP(WS-COL-AT + 1) TO WS-LOW
                     END-IF
                     IF WS-COL-TOP(WS-COL-AT - 16) < WS-LOW
                         MOVE WS-COL-TOP(WS-COL-AT - 16) TO WS-LOW
                     END-IF
                     IF WS-COL-TOP(WS-COL-AT + 16) < WS-LOW
                         MOVE WS-COL-TOP(WS-COL-AT + 16) TO WS-LOW
                     END-IF
                     IF WS-COL-TOP(WS-COL-AT) + 2 <= WS-LOW
                         ADD 1 TO WS-PITS
                         IF WS-PITS <= 10
                             COMPUTE WS-WX = WR-CX(WS-R) * 16 + WS-LX
                             COMPUTE WS-WZ = WR-CZ(WS-R) * 16 + WS-LZ
                             COMPUTE WS-WY = WS-COL-TOP(WS-COL-AT) + PL-MIN-Y
                             DISPLAY "PIT at " WS-WX " " WS-WY " " WS-WZ " neighbours' lowest top " WS-LOW
                         END-IF
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     DISPLAY "columns " WS-COLS " columns of only air " WS-EMPTY-COLS " pits " WS-PITS
     DISPLAY "cells checked " WS-CELLS-CHECKED " faces checked " WS-FACES-CHECKED " faces missing " WS-FACES-MISSING " cells without any quad " WS-ANY-MISSING
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-KEY-COUNT
         IF WS-KEY-MISSING(WS-I) > 0
             DISPLAY "MISSING " WS-KEY-NAME(WS-I) " checked " WS-KEY-CHECKED(WS-I) " missing " WS-KEY-MISSING(WS-I)
         END-IF
     END-PERFORM

     MOVE "acceptance bugmesh: given a single-player world when the player has joined then there are cells to look at (the case below is not vacuous)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "joined 1 faces more than 10000" TO TL-EXPECTED
     IF WS-JOINED = 1 AND WS-FACES-CHECKED > 10000
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-JOINED TO WS-D3B
         MOVE WS-FACES-CHECKED TO WS-D3
         STRING "joined " WS-D3B " faces " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given a meshed world when every vertex is looked at then its position, texture coordinates, light and tint are numbers in range"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "bad vertices 0" TO TL-EXPECTED
     IF WS-BAD-POS + WS-BAD-UV + WS-BAD-TERM = 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-BAD-POS TO WS-D3
         MOVE WS-BAD-UV TO WS-D3B
         MOVE WS-BAD-TERM TO WS-D3C
         STRING "bad positions " WS-D3 " bad uv " WS-D3B " bad terms " WS-D3C DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given a meshed world when each full cube is looked at then its section mesh holds the face toward every neighbour that is not opaque"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "missing faces 0" TO TL-EXPECTED
     IF WS-FACES-MISSING = 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-FACES-MISSING TO WS-D3
         MOVE WS-FACES-CHECKED TO WS-D3B
         STRING "missing faces " WS-D3 " of " WS-D3B DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given a meshed world when each other block with a model and an air neighbour is looked at then its section mesh holds a quad in its cell"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "cells without a quad 0" TO TL-EXPECTED
     IF WS-ANY-MISSING = 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-ANY-MISSING TO WS-D3
         STRING "cells without a quad " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   One non-air cell (WS-STATE, at index WS-CELL of the chunk, section WS-S, cell WS-LX/WS-LY/WS-LZ).
 CHECK-CELL.
     MOVE WS-KIND-OF(WS-STATE + 1) TO WS-HAS-AIR
     IF WS-HAS-AIR = 0
         MOVE ST-BLOCK(WS-STATE + 1) TO WS-BLOCK-ID
         MOVE SPACES TO WS-BNAME
         IF WS-BLOCK-ID >= 0 AND WS-BLOCK-ID < 2048
             MOVE ST-BLOCK-NAME(WS-BLOCK-ID + 1) TO WS-BNAME
         END-IF
         MOVE 2 TO WS-HAS-AIR
         MOVE 0 TO WS-NHIT
         INSPECT WS-BNAME TALLYING WS-NHIT FOR ALL "air"
         IF WS-NHIT > 0 AND WS-BNAME(1:3) = "air"
             MOVE 1 TO WS-HAS-AIR
         END-IF
         IF WS-BNAME = "cave_air" OR "void_air"
             MOVE 1 TO WS-HAS-AIR
         END-IF
         MOVE WS-HAS-AIR TO WS-KIND-OF(WS-STATE + 1)
     END-IF
     IF WS-HAS-AIR = 1
         EXIT PARAGRAPH
     END-IF
     MOVE ST-BLOCK(WS-STATE + 1) TO WS-BLOCK-ID
     MOVE SPACES TO WS-BNAME
     IF WS-BLOCK-ID >= 0 AND WS-BLOCK-ID < 2048
         MOVE ST-BLOCK-NAME(WS-BLOCK-ID + 1) TO WS-BNAME
     END-IF
     CALL "MODEL-SLOT-OF" USING CLIENT-STATE WS-STATE WS-BM
     IF WS-BM = 0 OR ST-FLUID(WS-STATE + 1) > 0
         EXIT PARAGRAPH
     END-IF
     IF BM-QUAD-COUNT(WS-BM) = 0
         EXIT PARAGRAPH
     END-IF
     MOVE 0 TO WS-STRICT
     IF ST-OPAQUE(WS-STATE + 1) = 1
         MOVE 1 TO WS-STRICT
     END-IF
     MOVE 0 TO WS-NHIT
     INSPECT WS-BNAME TALLYING WS-NHIT FOR ALL "leaves"
     IF WS-NHIT > 0
         MOVE 1 TO WS-STRICT
     END-IF
*>   The block's tally row.
     MOVE 0 TO WS-KEY-AT
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-KEY-COUNT OR WS-KEY-AT > 0
         IF WS-KEY-NAME(WS-K) = WS-BNAME
             MOVE WS-K TO WS-KEY-AT
         END-IF
     END-PERFORM
     IF WS-KEY-AT = 0 AND WS-KEY-COUNT < 512
         ADD 1 TO WS-KEY-COUNT
         MOVE WS-KEY-COUNT TO WS-KEY-AT
         MOVE WS-BNAME TO WS-KEY-NAME(WS-KEY-AT)
     END-IF
     MOVE 0 TO WS-WANT
     MOVE 0 TO WS-HAS-AIR
     COMPUTE WS-WX = WR-CX(WS-R) * 16 + WS-LX
     COMPUTE WS-WY = PL-MIN-Y + (WS-S - 1) * 16 + WS-LY
     COMPUTE WS-WZ = WR-CZ(WS-R) * 16 + WS-LZ
     PERFORM VARYING WS-FDIR FROM 1 BY 1 UNTIL WS-FDIR > 6
         MOVE WS-WX TO WS-NX
         MOVE WS-WY TO WS-NY
         MOVE WS-WZ TO WS-NZ
         EVALUATE WS-FDIR
             WHEN 1 SUBTRACT 1 FROM WS-NY
             WHEN 2 ADD 1 TO WS-NY
             WHEN 3 SUBTRACT 1 FROM WS-NZ
             WHEN 4 ADD 1 TO WS-NZ
             WHEN 5 SUBTRACT 1 FROM WS-NX
             WHEN OTHER ADD 1 TO WS-NX
         END-EVALUATE
         IF WS-NY >= PL-MIN-Y AND WS-NY < PL-MIN-Y + PL-HEIGHT
             CALL "WORLD-CELL" USING CLIENT-STATE WS-NX WS-NY WS-NZ WS-NSTATE WS-NSKY WS-NBLOCK
             MOVE 0 TO WS-C1
             IF WS-NSTATE = 0
                 MOVE 1 TO WS-C1
                 MOVE 1 TO WS-HAS-AIR
             ELSE
                 IF ST-OPAQUE(WS-NSTATE + 1) = 0 AND ST-SHAPED(WS-NSTATE + 1) = 0
                     MOVE 1 TO WS-C1
                     IF ST-BLOCK(WS-NSTATE + 1) = ST-BLOCK(WS-STATE + 1) AND ST-LIKE(WS-STATE + 1) = 1
                         MOVE 0 TO WS-C1
                     END-IF
                 END-IF
             END-IF
             IF WS-C1 = 1 AND WS-STRICT = 1
                 ADD 1 TO WS-FACES-CHECKED
                 ADD 1 TO WS-KEY-CHECKED(WS-KEY-AT)
                 COMPUTE WS-NB-CELL = (WS-LY * 256 + WS-LZ * 16 + WS-LX) * 6 + WS-FDIR
                 IF WS-FACE(WS-NB-CELL) = 0
                     ADD 1 TO WS-FACES-MISSING
                     ADD 1 TO WS-KEY-MISSING(WS-KEY-AT)
                     IF WS-SHOWN < 40
                         ADD 1 TO WS-SHOWN
                         DISPLAY "face missing " WS-BNAME " state " WS-STATE " dir " WS-FDIR " at " WS-WX " " WS-WY " " WS-WZ
                             " neighbour state " WS-NSTATE " opaque " ST-OPAQUE(WS-NSTATE + 1) " shaped " ST-SHAPED(WS-NSTATE + 1)
                             " nb block " ST-BLOCK-NAME(ST-BLOCK(WS-NSTATE + 1) + 1) " nb sky " WS-NSKY
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     IF WS-STRICT = 0 AND WS-HAS-AIR = 1
         ADD 1 TO WS-CELLS-CHECKED
         ADD 1 TO WS-KEY-CHECKED(WS-KEY-AT)
         COMPUTE WS-NB-CELL = WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
*>       A cube face on a cell boundary (ice at the edge of the world) counts too.
         PERFORM VARYING WS-FDIR FROM 1 BY 1 UNTIL WS-FDIR > 6
             COMPUTE WS-NHIT = (WS-NB-CELL - 1) * 6 + WS-FDIR
             IF WS-FACE(WS-NHIT) = 1
                 MOVE 1 TO WS-ANY(WS-NB-CELL)
             END-IF
         END-PERFORM
         IF WS-ANY(WS-NB-CELL) = 0
             ADD 1 TO WS-ANY-MISSING
             ADD 1 TO WS-KEY-MISSING(WS-KEY-AT)
             IF WS-SHOWN < 40
                 ADD 1 TO WS-SHOWN
                 DISPLAY "cell without quad " WS-BNAME " state " WS-STATE " at " WS-WX " " WS-WY " " WS-WZ
             END-IF
         END-IF
     END-IF
     EXIT PARAGRAPH.
 END PROGRAM ACC-BUGMESH-FACES.
