*> The generator of the standard overworld (DIM-GEN-STANDARD), chosen by world type (T0440, T0445): the hidden
*> `debug` type gets the grid of worldgen-debug.cob; the standard type's pipeline (biome, density, aquifer,
*> surface, carver and ore stages of docs/protocol/10 and 11) takes its place as the stages are built, and
*> until the terrain data are loaded it is the void placeholder (WORLDGEN-VOID-CHUNK of worldgen.cob); with them it is the
*> resumable pipeline of gen-job.cob (GEN-STANDARD-INSTALL). The cobolcraft type keeps
*> worldgen.cob (FR-033). The world type is the CS-WORLD-TYPE of the settings the world was opened with.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-STANDARD-CHUNK.
*> USING dimension row (BINARY-LONG), chunk x, chunk z, chunk memory (CELLS.cpy), marker-y out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-READY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y.
     MOVE CW-SETTINGS TO CORE-SETTINGS
     IF CS-WORLD-TYPE = "debug"
         CALL "WORLDGEN-DEBUG-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
     ELSE
         CALL "GEN-DATA-READY" USING WS-READY
         IF WS-READY = 1
             CALL "GEN-STANDARD-INSTALL" USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y
         ELSE
             CALL "WORLDGEN-VOID-CHUNK" USING L-CHUNK L-MARKER-Y
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WORLDGEN-STANDARD-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-IS-DEBUG.
*> USING flag out (BINARY-LONG): 1 when the open world is of the hidden debug type (the CS-WORLD-TYPE of its
*> settings), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     MOVE CW-SETTINGS TO CORE-SETTINGS
     MOVE 0 TO L-FLAG
     IF CS-WORLD-TYPE = "debug"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM WORLD-IS-DEBUG.
