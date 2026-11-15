*> The Nether's seam to the dimension plumbing (docs/protocol/37-nether-1 section 6.9, 37-nether-2 to 4): the real generator
*> (NETHER-GEN-CHUNK of nether-gen-chunk.cob, seeded by the level seed) when the open world's block table holds the blocks it places and its
*> biome table the Nether's, else the placeholder terrain (nether-gen-placeholder.cob). WORLDGEN-DIM-CHUNK and WORLDGEN-DIM-BIOMES call these.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DIM-READY.
*> USING flag out (BINARY-LONG): 1 when netherrack, lava, bedrock and the biome nether_wastes are in the open world's tables and the
*> switch ND-PLACEHOLDER (NETHERDIM.cpy) is 0, else 0.
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
     MOVE "minecraft:netherrack" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:lava" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:bedrock" TO WS-KEY
     CALL "FD-BLOCK-INDEX" USING WS-KEY WS-INDEX
     IF WS-INDEX > 0
         ADD 1 TO WS-HAVE
     END-IF
     MOVE "minecraft:nether_wastes" TO WS-NAME
     CALL "SURFACE-BIOME-ID" USING WS-NAME WS-ID
     IF WS-ID > 0
         ADD 1 TO WS-HAVE
     END-IF
     IF WS-HAVE = 4 AND ND-PLACEHOLDER = 0
         MOVE 1 TO L-FLAG
     END-IF
     GOBACK.
 END PROGRAM NETHER-DIM-READY.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DIM-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy), marker-y out: the terrain of a Nether chunk, from NETHER-GEN-CHUNK and then
*> the placed features of its biomes (NETHER-GEN-FEATURES, 37-nether-5) when the tables are ready (NETHER-DIM-READY), else the placeholder.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-READY               BINARY-LONG.
 01 WS-PLACED              BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     CALL "NETHER-DIM-READY" USING WS-READY
     IF WS-READY = 1
         CALL "NETHER-GEN-CHUNK" USING CW-SEED L-CX L-CZ L-CHUNK L-MARKER-Y
         CALL "NETHER-GEN-FEATURES" USING CW-SEED L-CX L-CZ L-CHUNK WS-PLACED
     ELSE
         CALL "WORLDGEN-NETHER-CHUNK" USING L-CX L-CZ L-CHUNK L-MARKER-Y
     END-IF
     GOBACK.
 END PROGRAM NETHER-DIM-CHUNK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NETHER-DIM-BIOMES.
*> USING chunk x, chunk z (BINARY-LONG), biomes out (16 BINARY-LONG, the 4 x 4 quart columns, index z * 4 + x + 1): the Nether biome source
*> (37-nether-3 section 5.1) when the tables are ready, else nether_wastes everywhere.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY NETHER.
 01 WS-READY               BINARY-LONG.
 01 WS-NAME                PIC X(40).
 01 WS-ID                  BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-BIOMES.
    05 L-BIOME             BINARY-LONG OCCURS 16 TIMES.
 PROCEDURE DIVISION USING L-CX L-CZ L-BIOMES.
     CALL "NETHER-DIM-READY" USING WS-READY
     IF WS-READY = 1
         CALL "NETHER-SETUP" USING CW-SEED
         CALL "NETHER-STATES"
         CALL "NETHER-BIOME-GRID" USING L-CX L-CZ
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 3
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 3
                 COMPUTE WS-I = WS-Z * 4 + WS-X + 1
                 COMPUTE WS-R = (WS-Z + 1) * 6 + WS-X + 2
                 MOVE NH-BIOME-ID(NH-RING(WS-R)) TO L-BIOME(WS-I)
             END-PERFORM
         END-PERFORM
     ELSE
         MOVE "minecraft:nether_wastes" TO WS-NAME
         CALL "SURFACE-BIOME-ID" USING WS-NAME WS-ID
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
             MOVE WS-ID TO L-BIOME(WS-I)
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM NETHER-DIM-BIOMES.
