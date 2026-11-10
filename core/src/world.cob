*> Per-dimension chunk cache and block access (data-model §2, §3; CORESTATE.cpy CORE-CHUNKS,
*> CELLS.cpy). Dimensions are rows of DIMENSIONS.cpy. Chunk coordinates are block >> 4 (floor
*> division by 16); a chunk is generated on first access (WORLD-CHUNK-LOAD) and lit when it is first
*> asked for whole (WORLD-CHUNK; light.cob) by the dimension's generator (WORLDGEN-DIM-CHUNK).

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
     CALL "GEN-QUEUE-RESET"
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
*> USING dim, chunk x, chunk z, row out (BINARY-LONG): the cache row of that chunk, read from the
*> dimension's region file when it is there (PERSIST-CHUNK-LOAD), else generated; not lit. A new row is the one above the high-water mark CK-COUNT, else the
*> first unused row; a full cache (CORE-MAX-CHUNKS chunks loaded) is fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-BYTES               BINARY-LONG VALUE 304640.
 01 WS-MARKER-Y            BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-EDIT-X              PIC -(9)9.
 01 WS-EDIT-Z              PIC -(9)9.
 01 WS-LINE                PIC X(160).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-KEY-LENGTH          BINARY-LONG.
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
     ALLOCATE WS-BYTES CHARACTERS INITIALIZED RETURNING CK-ADDR(L-ROW)
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     MOVE DM-KEY-LENGTH(L-DIM) TO WS-KEY-LENGTH
     CALL "PERSIST-CHUNK-LOAD" USING L-ROW WS-FOUND
     IF WS-FOUND = 2
         MOVE L-CX TO WS-EDIT-X
         MOVE L-CZ TO WS-EDIT-Z
         MOVE SPACES TO WS-LINE
         STRING "chunk " FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Z) " in "
             DM-KEY(L-DIM)(1:WS-KEY-LENGTH) " holds content of another world type and was not loaded"
             DELIMITED BY SIZE INTO WS-LINE
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
         CALL "CORE-LOG" USING WS-LINE WS-LINE-LENGTH
     END-IF
     IF WS-FOUND = 0
         CALL "WORLDGEN-DIM-CHUNK" USING L-DIM L-CX L-CZ CE-CHUNK WS-MARKER-Y
         IF WS-MARKER-Y >= 0
             ADD 1 TO CK-SOURCES(L-ROW, WS-MARKER-Y / 16 + 1)
         END-IF
     END-IF
     IF DM-GENERATOR(L-DIM) NOT = DIM-GEN-STANDARD
         CALL "WORLD-FILL-BIOMES" USING L-ROW
     END-IF
     CALL "BR-COUNT-ROW" USING L-ROW
     GOBACK.
 END PROGRAM WORLD-CHUNK-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-FILL-BIOMES.
*> USING row (BINARY-LONG) of a cached chunk: fills its biome cells (CELLS.cpy: one byte per 4 x 4 x 4 cell)
*> from the dimension's generator biomes (WORLDGEN-DIM-BIOMES), the same for every cell Y.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-COLUMNS.
    05 WS-COLUMN           BINARY-LONG OCCURS 16 TIMES.
 01 WS-SECTIONS            BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     CALL "WORLDGEN-DIM-BIOMES" USING CK-DIM(L-ROW) CK-X(L-ROW) CK-Z(L-ROW) WS-COLUMNS
     COMPUTE WS-SECTIONS = DM-HEIGHT(CK-DIM(L-ROW)) / 16
     PERFORM VARYING WS-S FROM 0 BY 1 UNTIL WS-S >= WS-SECTIONS
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 63
             COMPUTE WS-CELL = WS-S * 64 + WS-I + 1
             MOVE WS-COLUMN(FUNCTION MOD(WS-I, 16) + 1) TO CE-BIOME(WS-CELL)
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-FILL-BIOMES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-CHUNK-RELEASE.
*> USING row (BINARY-LONG) of a loaded chunk: the row leaves its hash chain, its memory is freed and
*> it is unused again (CHUNKS-UNLOAD; a later WORLD-CHUNK-LOAD may reuse it).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-PREV                BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     COMPUTE WS-HASH = FUNCTION MOD(73 * CK-X(WS-ROW) + 1031 * CK-Z(WS-ROW) + 7 * CK-DIM(WS-ROW),
         CORE-MAX-CHUNKS) + 1
     IF CK-BUCKET(WS-HASH) = WS-ROW
         MOVE CK-NEXT(WS-ROW) TO CK-BUCKET(WS-HASH)
     ELSE
         MOVE CK-BUCKET(WS-HASH) TO WS-PREV
         PERFORM UNTIL CK-NEXT(WS-PREV) = WS-ROW
             MOVE CK-NEXT(WS-PREV) TO WS-PREV
         END-PERFORM
         MOVE CK-NEXT(WS-ROW) TO CK-NEXT(WS-PREV)
     END-IF
     FREE CK-ADDR(WS-ROW)
     MOVE 0 TO CK-USED(WS-ROW) CK-NEXT(WS-ROW)
     GOBACK.
 END PROGRAM WORLD-CHUNK-RELEASE.

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
 COPY CELLS.
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
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     MOVE CE-STATE((L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16 + L-X - WS-CX * 16 + 1)
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
 COPY CBLOCKS.
 COPY CELLS.
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
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     COMPUTE WS-CELL = (L-Y - DM-MIN-Y(L-DIM)) * 256 + (L-Z - WS-CZ * 16) * 16
         + L-X - WS-CX * 16 + 1
     MOVE CE-STATE(WS-CELL) TO WS-OLD
     IF WS-OLD = L-STATE
         GOBACK
     END-IF
     MOVE L-STATE TO CE-STATE(WS-CELL)
     MOVE 1 TO CK-CHANGED(WS-ROW)
     COMPUTE WS-SECTION = (WS-CELL - 1) / 4096 + 1
     IF CB-S-LIGHT(WS-OLD + 1) > 0
         SUBTRACT 1 FROM CK-SOURCES(WS-ROW, WS-SECTION)
     END-IF
     IF CB-S-LIGHT(L-STATE + 1) > 0
         ADD 1 TO CK-SOURCES(WS-ROW, WS-SECTION)
     END-IF
     CALL "BR-ADJUST" USING WS-ROW WS-SECTION WS-OLD L-STATE
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
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-TOPS.
    05 L-TOP               BINARY-LONG OCCURS 256 TIMES.
 PROCEDURE DIVISION USING L-ROW L-TOPS.
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(L-ROW)
     COMPUTE WS-TOP = DM-HEIGHT(CK-DIM(L-ROW)) - 1
     PERFORM UNTIL WS-TOP < 0
         COMPUTE WS-BYTE = WS-TOP * 512 + 1
         IF CE-STATES(WS-BYTE:512) NOT = LOW-VALUES
             EXIT PERFORM
         END-IF
         SUBTRACT 1 FROM WS-TOP
     END-PERFORM
     PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
         MOVE WS-TOP TO WS-Y
         PERFORM UNTIL WS-Y < 0
             IF CE-STATE(WS-Y * 256 + WS-C) NOT = 0
                 EXIT PERFORM
             END-IF
             SUBTRACT 1 FROM WS-Y
         END-PERFORM
         MOVE WS-Y TO L-TOP(WS-C)
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-COLUMN-TOPS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-TIME-TICK.
*> No parameters; called once per tick after CW-TICKS is raised (US3-6). The time of day advances by
*> 1 and wraps from 23999 to 0 (RULE-DAY-LENGTH). Every CORE-TIME-TICKS ticks (once a
*> second, 09 §3.2 Set Time row) every player whose join has been sent gets Set Time.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY RULES.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-PLAYER              BINARY-LONG.
 PROCEDURE DIVISION.
     COMPUTE CW-TIME = FUNCTION MOD(CW-TIME + 1, RULE-DAY-LENGTH)
     IF FUNCTION MOD(CW-TICKS, CORE-TIME-TICKS) NOT = 0
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PLAY-TIME-BUILD" USING CW-TIME PB-BUFFER
     PERFORM VARYING WS-PLAYER FROM 1 BY 1 UNTIL WS-PLAYER > CORE-MAX-PLAYERS
         IF PL-USED(WS-PLAYER) = 1 AND PL-ENTITY-ROW(WS-PLAYER) > 0
             CALL "CORE-SEND" USING PL-CONN(WS-PLAYER) PB-BUFFER
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLD-TIME-TICK.
