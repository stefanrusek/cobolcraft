*> The generator of the standard overworld (DIM-GEN-STANDARD), chosen by world type (T0440, T0445): the hidden
*> `debug` type gets the grid of worldgen-debug.cob; the standard type's pipeline (biome, density, aquifer,
*> surface, carver and ore stages of docs/protocol/10 and 11) takes its place as the stages are built, and
*> until the terrain data are loaded it is the void placeholder (WORLDGEN-VOID-CHUNK of worldgen.cob); with them it is the
*> resumable pipeline of gen-job.cob (GEN-STANDARD-INSTALL). The cobolcraft type keeps
*> worldgen.cob (FR-033). The world type is the CW-WORLD-TYPE the world decided at its open (WORLD-TYPE-DECIDE: the type of its level.dat), never the
*> CS-WORLD-TYPE the host asked for: the client asks for cobolcraft when it opens a saved world from the list, and a superflat world reopened that way
*> made the standard terrain of every chunk of its first batch inside the join.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-STANDARD-CHUNK.
*> USING dimension row (BINARY-LONG), chunk x, chunk z, chunk memory (CELLS.cpy), marker-y out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-READY               BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y.
     EVALUATE TRUE
         WHEN CW-WORLD-TYPE = "debug"
             CALL "WORLDGEN-DEBUG-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
         WHEN CW-WORLD-TYPE = "superflat"
             CALL "WORLDGEN-FLAT-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
         WHEN OTHER
             CALL "GEN-DATA-READY" USING WS-READY
             IF WS-READY = 1
                 CALL "GEN-STANDARD-INSTALL" USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y
             ELSE
                 CALL "WORLDGEN-VOID-CHUNK" USING L-CHUNK L-MARKER-Y
             END-IF
     END-EVALUATE
     GOBACK.
 END PROGRAM WORLDGEN-STANDARD-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-IS-DEBUG.
*> USING flag out (BINARY-LONG): 1 when the open world is of the hidden debug type (its CW-WORLD-TYPE), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     MOVE 0 TO L-FLAG
     IF CW-WORLD-TYPE = "debug"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM WORLD-IS-DEBUG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-GEN-OWN.
*> USING flag out (BINARY-LONG): 1 when the open world's overworld has a generator of its own that the generation queue and its workers do not serve
*> (the hidden debug type: its grid; the superflat type: the flat generator of worldgen-flat.cob), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     MOVE 0 TO L-FLAG
     IF CW-WORLD-TYPE = "debug" OR CW-WORLD-TYPE = "superflat"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM WORLD-GEN-OWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIM-SEA-LEVEL-OF.
*> USING dimension row (BINARY-LONG), sea level out (BINARY-LONG): the level's sea level (ServerLevel.getSeaLevel): the dimension's own (DM-SEA-LEVEL), but -63 in the overworld of a
*> superflat world (56 section 4.1 and 5.2: the flat generator's constant, whatever the layers). The one place the spawn info (PLAY-SPAWN-INFO-BUILD) and the water animals' spawn
*> rules (MS6-WATER-RULE) ask.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-SEA                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-SEA.
     MOVE DM-SEA-LEVEL(L-DIM) TO L-SEA
     IF CW-WORLD-TYPE = "superflat" AND L-DIM = DIM-STANDARD-OVERWORLD
         MOVE -63 TO L-SEA
     END-IF
     GOBACK.
 END PROGRAM DIM-SEA-LEVEL-OF.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-IS-FLAT.
*> USING flag out (BINARY-LONG): 1 when the open world is of the superflat type (56 section 5.1: the flat generator in the overworld), else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     MOVE 0 TO L-FLAG
     IF CW-WORLD-TYPE = "superflat"
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM WORLD-IS-FLAT.
