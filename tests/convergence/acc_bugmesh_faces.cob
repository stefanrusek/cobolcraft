*> Convergence acceptance test of the operator report "the grass floor has holes through which the sky shows" (try14 play; bug lane bugmesh): one
*> standard single-player world (the host's in-process core, real generated chunks of CC_GENERATED_DIR, view distance BM_VIEW, default 3) is stepped
*> until every section with cells is meshed; then every cell that is opaque with air above it has, in its section's opaque mesh, a full-size horizontal
*> quad at its top (a quad is 6 vertices; the cell's top face lies at the cell's y + 1 and covers x and z from the cell's corner to the next). A top
*> face the mesh lacks is a hole in the floor: the cell is hollow, and the sky shows through it.
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
 01 WS-EXPECTED            BINARY-LONG VALUE 0.
 01 WS-MISSING             BINARY-LONG VALUE 0.
 01 WS-SHOWN               BINARY-LONG VALUE 0.
 01 WS-D3                  PIC 9(7).
 01 WS-D3B                 PIC 9(7).
 01 WS-MINX                FLOAT-LONG.
 01 WS-MAXX                FLOAT-LONG.
 01 WS-MINY                FLOAT-LONG.
 01 WS-MAXY                FLOAT-LONG.
 01 WS-MINZ                FLOAT-LONG.
 01 WS-MAXZ                FLOAT-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-BITS.
    05 WS-BIT              PIC 9 OCCURS 4096 TIMES.
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
     MOVE 0 TO WS-QUIET
     PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES OR WS-QUIET >= 10
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

*>   The top faces of every section's opaque mesh against the cells that need one.
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > WR-COUNT
         IF WR-USED(WS-R) = 1
             SET ADDRESS OF CE-CHUNK TO WR-ADDR(WS-R)
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > CL-MAX-SECTIONS
                 MOVE ALL "0" TO WS-BITS
                 COMPUTE WS-QUADS = WR-OP-COUNT(WS-R, WS-S) / 6
                 IF WS-QUADS > 0
                     SET ADDRESS OF B-VERT TO WR-OP-ADDR(WS-R, WS-S)
                 END-IF
                 PERFORM VARYING WS-Q FROM 0 BY 1 UNTIL WS-Q >= WS-QUADS
                     MOVE 1000 TO WS-MINX WS-MINY WS-MINZ
                     MOVE -1000 TO WS-MAXX WS-MAXY WS-MAXZ
                     PERFORM VARYING WS-V FROM 0 BY 1 UNTIL WS-V > 5
                         COMPUTE WS-OFF = (WS-Q * 6 + WS-V) * 44 + 1
                         MOVE B-VERT(WS-OFF:44) TO WS-VROW
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
*>                   A full-size horizontal quad on an integer height: the top of the cell below that height.
                     IF WS-MAXY - WS-MINY < 0.001 AND WS-MAXX - WS-MINX > 0.99 AND WS-MAXZ - WS-MINZ > 0.99
                         COMPUTE WS-CX = FUNCTION INTEGER(WS-MINX + 0.5)
                         COMPUTE WS-CZ = FUNCTION INTEGER(WS-MINZ + 0.5)
                         COMPUTE WS-CY = FUNCTION INTEGER(WS-MAXY + 0.5) - 1
                         IF WS-CX >= 0 AND WS-CX <= 15 AND WS-CZ >= 0 AND WS-CZ <= 15 AND WS-CY >= 0 AND WS-CY <= 15
                             COMPUTE WS-CELL = WS-CY * 256 + WS-CZ * 16 + WS-CX + 1
                             MOVE 1 TO WS-BIT(WS-CELL)
                         END-IF
                     END-IF
                 END-PERFORM
                 PERFORM VARYING WS-LY FROM 0 BY 1 UNTIL WS-LY > 15
                  PERFORM VARYING WS-LZ FROM 0 BY 1 UNTIL WS-LZ > 15
                   PERFORM VARYING WS-LX FROM 0 BY 1 UNTIL WS-LX > 15
                     COMPUTE WS-CELL = (WS-S - 1) * 4096 + WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
                     MOVE CE-STATE(WS-CELL) TO WS-STATE
                     IF WS-STATE > 0 AND ST-OPAQUE(WS-STATE + 1) = 1 AND WS-CELL + 256 <= CL-MAX-SECTIONS * 4096
                         MOVE CE-STATE(WS-CELL + 256) TO WS-ABOVE
                         IF WS-ABOVE = 0
                             ADD 1 TO WS-EXPECTED
                             COMPUTE WS-CELL = WS-LY * 256 + WS-LZ * 16 + WS-LX + 1
                             IF WS-BIT(WS-CELL) = 0
                                 ADD 1 TO WS-MISSING
                                 IF WS-SHOWN < 30
                                     ADD 1 TO WS-SHOWN
                                     MOVE WS-STATE TO WS-D3
                                     MOVE WS-S TO WS-D3B
                                     DISPLAY "MISSING top face chunk " WR-CX(WS-R) "," WR-CZ(WS-R) " section " WS-D3B " cell " WS-LX "," WS-LY "," WS-LZ
                                         " state " WS-D3 " dirty " WR-DIRTY(WS-R, WS-S) " verts " WR-OP-COUNT(WS-R, WS-S)
                                 END-IF
                             END-IF
                         END-IF
                     END-IF
                   END-PERFORM
                  END-PERFORM
                 END-PERFORM
             END-PERFORM
         END-IF
     END-PERFORM
     MOVE WS-EXPECTED TO WS-D3
     MOVE WS-MISSING TO WS-D3B
     DISPLAY "top faces expected " WS-D3 " missing " WS-D3B

     MOVE "acceptance bugmesh: given a single-player world when the player has joined then there are top faces to look for (the case below is not vacuous)"
         TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "joined 1 faces more than 1000" TO TL-EXPECTED
     IF WS-JOINED = 1 AND WS-EXPECTED > 1000
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-JOINED TO WS-D3B
         MOVE WS-EXPECTED TO WS-D3
         STRING "joined " WS-D3B " faces " WS-D3 DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance bugmesh: given a meshed world when each opaque cell with air above is looked at then its section mesh holds the top face (no hole in the floor)"
         TO TL-CASE
     MOVE SPACES TO TL-EXPECTED TL-OBSERVED
     MOVE "missing top faces 0" TO TL-EXPECTED
     IF WS-MISSING = 0
         MOVE TL-EXPECTED TO TL-OBSERVED
     ELSE
         MOVE WS-MISSING TO WS-D3
         MOVE WS-EXPECTED TO WS-D3B
         STRING "missing top faces " WS-D3 " of " WS-D3B DELIMITED BY SIZE INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGMESH-FACES.
