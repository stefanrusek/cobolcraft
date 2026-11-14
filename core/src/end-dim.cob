*> The End's seam to the dimension plumbing (docs/protocol/38-end.md sections 2, 8 and 12): the real generator (END-GEN-CHUNK and the decoration driver END-GEN-FEATURES
*> of end-38.cob and end-38e.cob, seeded by the level seed) when the open world's block table holds the blocks it places and its biome table the End's, else the placeholder
*> island (nether-gen-placeholder.cob WORLDGEN-END-CHUNK). The switch ND-PLACEHOLDER (NETHERDIM.cpy) of the Nether keeps the placeholder for both. WORLDGEN-DIM-CHUNK and
*> WORLDGEN-DIM-BIOMES call these. The end crystals that the pillars ask for (CRYSTAL-LIST) are spawned as tracker rows of the entity type end_crystal in the dimension.
*> Not done (open items): the crystal's beam target and bottom flag (entity data 8 and 9), the cage of a guarded spike is in the blocks only.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-DIM-READY.
*> USING flag out (BINARY-LONG): 1 when end_stone, obsidian, bedrock and chorus_plant are in the open world's block table, the biomes the_end and end_highlands in its biome
*> table and ND-PLACEHOLDER (NETHERDIM.cpy) is 0, else 0.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY NETHERDIM.
 01 WS-KEY                 PIC X(48).
 01 WS-NAME                PIC X(40).
 01 WS-INDEX               BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-HAVE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-FLAG                 BINARY-LONG.
 PROCEDURE DIVISION USING L-FLAG.
     MOVE 0 TO L-FLAG
     MOVE 0 TO WS-HAVE
     MOVE "minecraft:end_stone" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:obsidian" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:bedrock" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:chorus_plant" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:the_end" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME WS-ID
     IF WS-ID > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:end_highlands" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME WS-ID
     IF WS-ID > 0
         ADD 1 TO WS-HAVE
     END-IF
     IF WS-HAVE = 6 AND ND-PLACEHOLDER = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM END-DIM-READY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-CRYSTAL-SPAWN.
*> USING dimension row, crystal list (ENDSPIKE.cpy CRYSTAL-LIST): one end_crystal tracker row per listed crystal, at (x + 0.5, y, z + 0.5) with the listed yaw (38 section
*> 8.2); nothing when the open set has no end_crystal entity type.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:end_crystal".
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CRYSTALS.
    05 L-EC-COUNT          BINARY-LONG.
    05 L-EC-ROW            OCCURS 10 TIMES.
       10 L-EC-X           BINARY-LONG.
       10 L-EC-Y           BINARY-LONG.
       10 L-EC-Z           BINARY-LONG.
       10 L-EC-YAW         FLOAT-LONG.
 PROCEDURE DIVISION USING L-DIM L-CRYSTALS.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-TEXT WS-STATUS
     IF WS-STATUS NOT = 0
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-EC-COUNT
         CALL "ENTITY-ALLOC" USING WS-ROW
         CALL "ENTITY-NEW-ID" USING EN-ID(WS-ROW)
         MOVE WS-TYPE TO EN-TYPE(WS-ROW)
         CALL "ENTITY-SET-UUID" USING WS-ROW
         MOVE L-DIM TO EN-DIM(WS-ROW)
         COMPUTE EN-X(WS-ROW) = L-EC-X(WS-I) + 0.5
         MOVE L-EC-Y(WS-I) TO EN-Y(WS-ROW)
         COMPUTE EN-Z(WS-ROW) = L-EC-Z(WS-I) + 0.5
         MOVE L-EC-YAW(WS-I) TO EN-YAW(WS-ROW)
         CALL "ENTITY-TRACK" USING WS-ROW
     END-PERFORM
     GOBACK.
 END PROGRAM END-CRYSTAL-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-DIM-CHUNK.
*> USING dimension row, chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy), marker-y out: the terrain of an End chunk with its decoration and crystals, from END-GEN-CHUNK
*> and END-GEN-FEATURES when the tables are ready (END-DIM-READY), else the placeholder island.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY ENDSPIKE.
 01 WS-READY               BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ L-CHUNK L-MARKER-Y.
     CALL "END-DIM-READY" USING WS-READY
     IF WS-READY = 1
         CALL "END-GEN-CHUNK" USING CW-SEED L-CX L-CZ L-CHUNK L-MARKER-Y
         CALL "END-GEN-FEATURES" USING CW-SEED L-CX L-CZ L-CHUNK CRYSTAL-LIST WS-PLACED
         CALL "END-CRYSTAL-SPAWN" USING L-DIM CRYSTAL-LIST
     ELSE
         CALL "WORLDGEN-END-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
     END-IF
     GOBACK.
 END PROGRAM END-DIM-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. END-DIM-BIOMES.
*> USING chunk x, chunk z (BINARY-LONG), biomes out (16 BINARY-LONG, the 4 x 4 quart columns, index z * 4 + x + 1): the End biome of the chunk (END-BIOME-OF, 38
*> section 3) in every column when the tables are ready, else the_end everywhere.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY END.
 01 WS-READY               BINARY-LONG.
 01 WS-NAME                PIC X(40) VALUE "minecraft:the_end".
 01 WS-ID                  BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BIOMES.
    05 L-BIOME             BINARY-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-CX L-CZ L-BIOMES.
     CALL "END-DIM-READY" USING WS-READY
     IF WS-READY = 1
         CALL "END-STATES"
         CALL "END-BIOME-OF" USING L-CX L-CZ WS-INDEX
         MOVE EN-BIOME-ID(WS-INDEX) TO WS-ID
     ELSE
         CALL "SURFACE-BIOME-ID" USING WS-NAME WS-ID
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         MOVE WS-ID TO L-BIOME(WS-I)
     END-PERFORM
     GOBACK.
 END PROGRAM END-DIM-BIOMES.
