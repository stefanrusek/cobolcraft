*> Per-dimension chunk cache and block access (data-model §2, §3; CORESTATE.cpy CORE-CHUNKS,
*> CHUNKMEM.cpy). Dimensions are rows of DIMENSIONS.cpy. Chunk coordinates are block >> 4 (floor
*> division by 16); a chunk is generated on first access (WORLD-CHUNK-LOAD) and lit when it is first
*> asked for whole (WORLD-CHUNK; light.cob). Only the cobolcraft:main generator exists in US2.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-RESET.
*> No parameters: frees the memory of every cached chunk (called by CORE-WORLD-OPEN when a world was
*> already open; CORE-WORLD-OPEN then empties CORE-CHUNKS).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 PROCEDURE DIVISION.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CK-COUNT
         IF CK-USED(WS-ROW) = 1
             FREE CK-ADDR(WS-ROW)
             MOVE 0 TO CK-USED(WS-ROW)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-FIND.
*> USING dim, chunk x, chunk z, row out (BINARY-LONG): the cache row of that chunk, 0 when it is not
*> loaded. Bucket = (73 * chunk x + 1031 * chunk z + 7 * dim) mod 4096, + 1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HASH                BINARY-DOUBLE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-ROW.
     COMPUTE WS-HASH = FUNCTION MOD(73 * L-CX + 1031 * L-CZ + 7 * L-DIM, CORE-MAX-CHUNKS) + 1
     MOVE CK-BUCKET(WS-HASH) TO L-ROW
     PERFORM UNTIL L-ROW = 0
         IF CK-X(L-ROW) = L-CX AND CK-Z(L-ROW) = L-CZ AND CK-DIM(L-ROW) = L-DIM
             GOBACK
         END-IF
         MOVE CK-NEXT(L-ROW) TO L-ROW
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CHUNK-LOAD.
*> USING dim, chunk x, chunk z, row out (BINARY-LONG): the cache row of that chunk, generated (not
*> lit) when it was not loaded. A new row is the one above the high-water mark CK-COUNT, else the
*> first unused row; a full cache (CORE-MAX-CHUNKS chunks loaded) is fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CHUNKMEM.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-BYTES               BINARY-LONG VALUE 196608.
 01 WS-MARKER-Y            BINARY-LONG.
 01 WS-FATAL               PIC X(40) VALUE Z"chunk cache: 4096 chunks loaded".
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-ROW.
     CALL "WORLD-FIND" USING L-DIM L-CX L-CZ L-ROW
     IF L-ROW > 0
         GOBACK
     END-IF
     IF CK-COUNT < CORE-MAX-CHUNKS
         ADD 1 TO CK-COUNT
         MOVE CK-COUNT TO L-ROW
     ELSE
         MOVE 1 TO L-ROW
         PERFORM UNTIL L-ROW > CORE-MAX-CHUNKS OR CK-USED(L-ROW) = 0
             ADD 1 TO L-ROW
         END-PERFORM
         IF L-ROW > CORE-MAX-CHUNKS
             CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
         END-IF
     END-IF
     INITIALIZE CK-ENTRY(L-ROW)
     MOVE 1 TO CK-USED(L-ROW)
     MOVE L-DIM TO CK-DIM(L-ROW)
     MOVE L-CX TO CK-X(L-ROW)
     MOVE L-CZ TO CK-Z(L-ROW)
     COMPUTE WS-HASH = FUNCTION MOD(73 * L-CX + 1031 * L-CZ + 7 * L-DIM, CORE-MAX-CHUNKS) + 1
     MOVE CK-BUCKET(WS-HASH) TO CK-NEXT(L-ROW)
     MOVE L-ROW TO CK-BUCKET(WS-HASH)
     ALLOCATE WS-BYTES CHARACTERS RETURNING CK-ADDR(L-ROW)
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     CALL "WORLDGEN-CHUNK" USING L-CX L-CZ CM-CHUNK WS-MARKER-Y
     IF WS-MARKER-Y >= 0
         ADD 1 TO CK-SOURCES(L-ROW, WS-MARKER-Y / 16 + 1)
     END-IF
     GOBACK.
 END PROGRAM WORLD-CHUNK-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CHUNK.
*> USING dim, chunk x, chunk z, row out (BINARY-LONG): the cache row of that chunk, generated and lit
*> on first access.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-ROW.
     CALL "WORLD-CHUNK-LOAD" USING L-DIM L-CX L-CZ L-ROW
     IF CK-LIT(L-ROW) = 0
         CALL "LIGHT-CHUNK" USING L-ROW
     END-IF
     GOBACK.
 END PROGRAM WORLD-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-GET-BLOCK.
*> USING dim, x, y, z, state out (BINARY-LONG; world block position): the block state there; 0 (void)
*> outside the dimension's height range. Loads (generates) the chunk without lighting it.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CHUNKMEM.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     MOVE 0 TO L-STATE
     IF L-Y < DM-MIN-Y(L-DIM) OR L-Y >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM)
         GOBACK
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-CHUNK-LOAD" USING L-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(WS-ROW)
     MOVE CM-STATE((L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1)
         TO L-STATE
     GOBACK.
 END PROGRAM WORLD-GET-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-SET-BLOCK.
*> USING dim, x, y, z, state (BINARY-LONG; world block position): sets the block state there. Outside
*> the dimension's height range, or when the cell already holds that state, nothing happens.
*> Otherwise the chunk is loaded and lit first, its changed flag is set, its per-section light source
*> counts follow, and the light of the affected chunks is recomputed (LIGHT-BLOCK-CHANGED).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY BLOCKS.
 COPY CHUNKMEM.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-SECTION             BINARY-LONG.
 01 WS-OLD                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-STATE.
     IF L-Y < DM-MIN-Y(L-DIM) OR L-Y >= DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM)
         GOBACK
     END-IF
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-CHUNK" USING L-DIM WS-CX WS-CZ WS-ROW
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = (L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16
         + L-X - WS-CX * 16 + 1
     MOVE CM-STATE(WS-CELL) TO WS-OLD
     IF WS-OLD = L-STATE
         GOBACK
     END-IF
     MOVE L-STATE TO CM-STATE(WS-CELL)
     MOVE 1 TO CK-CHANGED(WS-ROW)
     COMPUTE WS-SECTION = (WS-CELL - 1) / 4096 + 1
     IF SB-LIGHT(WS-OLD + 1) > 0
         SUBTRACT 1 FROM CK-SOURCES(WS-ROW, WS-SECTION)
     END-IF
     IF SB-LIGHT(L-STATE + 1) > 0
         ADD 1 TO CK-SOURCES(WS-ROW, WS-SECTION)
     END-IF
     CALL "LIGHT-BLOCK-CHANGED" USING WS-ROW
     GOBACK.
 END PROGRAM WORLD-SET-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-COLUMN-TOPS.
*> USING row (BINARY-LONG), tops out (table of 256 BINARY-LONG, entry z * 16 + x + 1): the cell Y of
*> each column's topmost non-void block, -1 for a column that is void throughout. Whole void layers
*> above the highest block are skipped with one comparison each.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CHUNKMEM.
 01 WS-TOP                 BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TOPS.
    05 L-TOP               BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION USING L-ROW L-TOPS.
     SET ADDRESS OF CM-CHUNK TO CK-ADDR(L-ROW)
     MOVE 255 TO WS-TOP
     PERFORM UNTIL WS-TOP < 0
         IF CM-STATES(WS-TOP * 256 + 1:256) NOT = LOW-VALUES
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-TOP
     END-PERFORM
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         MOVE WS-TOP TO WS-Y
         PERFORM UNTIL WS-Y < 0
             IF CM-STATE(WS-Y * 256 + WS-C) NOT = 0
                 EXIT PERFORM
             END-IF
             SUBTRACT 1 FROM WS-Y
         END-PERFORM
         MOVE WS-Y TO L-TOP(WS-C)
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-COLUMN-TOPS.
