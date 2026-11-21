*> The flat chunk generator of the `superflat` world type (docs/protocol/56-superflat-world.md sections 4.2 to 4.7; docs/design/world-types.md superflat;
*> flat-settings.cob for the settings). What a chunk holds:
*>   - the layers of the settings, bottom first from the dimension's min y (-64), every column alike (56 section 4.3); a layer that is not motion
*>     blocking (air, snow, flowers) is left out of the terrain fill and written afterwards where the cell is still air (56 section 4.4);
*>   - the one biome of the settings in every biome cell (56 section 4.2);
*>   - the structure starts of the structure sets the settings allow (structure_overrides, further filtered by the biome test) and their pieces, made by
*>     the structure code of the standard pipeline (STRUCT-STAGE-HOOK: its starts and its decoration steps 0 to 10), unless the world's generate_structures is 0;
*>   - no noise, climate, density, aquifer, surface rule, carver, ore vein, biome feature or lake, and no creatures (56 section 4.2 and 4.9).
*> The heightmaps of the finished chunk are the usual ones, built from the blocks (CHUNK-HEIGHTMAP); the world generation heightmaps of 56 section 4.3 are
*> the queries FLAT-BASE-HEIGHT (ordinals 0 and 2) answers.
*> Cell (x, y, z) is (y + 64) * 256 + z * 16 + x + 1 (CELLS.cpy), so layer i from the bottom (0-based) fills cells i * 256 + 1 to i * 256 + 256.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-FLAT-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy layout; block states and biomes are written, light is left alone), marker-y out
*> (BINARY-LONG, always -1: no marker pillar).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FLATSET.
 COPY STRUCTDATA.
 COPY GENOVER.
 COPY GENBE.
 COPY GENENT.
 01 WS-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==W-==.
 01 WS-LIMIT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-BIOME               PIC X(48).
 01 WS-SEED-S              BINARY-DOUBLE.
 01 WS-SEED-U              BINARY-DOUBLE UNSIGNED.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE -1 TO L-MARKER-Y
     MOVE LOW-VALUES TO CE-STATES
     CALL "FLAT-SETTINGS-PREPARE"
*>   the biome of every cell: the settings' biome, plains when the content has no such biome (56 section 2.1)
     MOVE FS-BIOME TO WS-BIOME
     MOVE 0 TO WS-ID WS-PLAINS WS-FOUND
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         MOVE CBI-KEY-LENGTH(WS-I) TO WS-LEN
         IF WS-LEN > 0 AND WS-LEN <= 48
             COMPUTE WS-NEXT = WS-LEN + 1
             IF CBI-KEY(WS-I)(1:WS-LEN) = WS-BIOME(1:WS-LEN) AND WS-BIOME(WS-NEXT:1) = SPACE
                 COMPUTE WS-ID = WS-I - 1
                 MOVE 1 TO WS-FOUND
             END-IF
             IF CBI-KEY(WS-I)(1:WS-LEN) = "minecraft:plains" AND WS-LEN = 16
                 COMPUTE WS-PLAINS = WS-I - 1
             END-IF
         END-IF
     END-PERFORM
     IF WS-FOUND = 0
         MOVE WS-PLAINS TO WS-ID
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         MOVE WS-ID TO CE-BIOME(WS-I)
     END-PERFORM
*>   the terrain fill (56 section 4.3): layer i at y = -64 + i, only the lowest 384 layers exist, a null (non motion blocking) layer is skipped
     MOVE FS-TOTAL TO WS-LIMIT
     IF WS-LIMIT > FS-MAX-STACK
         MOVE FS-MAX-STACK TO WS-LIMIT
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIMIT
         IF FS-KIND(WS-I) NOT = 0 AND FS-STATE(WS-I) NOT = 0
             COMPUTE WS-BASE = (WS-I - 1) * 256
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
                 MOVE FS-STATE(WS-I) TO CE-STATE(WS-BASE + WS-C)
             END-PERFORM
         END-IF
     END-PERFORM
*>   the structures the settings allow (56 section 4.7): the starts of this chunk and of the chunks around it are found by the structure code, whose biome and height
*>   queries answer from the flat settings; their pieces are written into this chunk at their own steps (0 to 10)
     IF FS-GEN-STRUCT = 1 AND SD-GATE-COUNT > 0 AND SD-SET-COUNT > 0
         MOVE CW-SEED TO WS-SEED-S
         IF WS-SEED-S < 0
             COMPUTE WS-SEED-U = WS-SEED-S + 18446744073709551616
         ELSE
             MOVE WS-SEED-S TO WS-SEED-U
         END-IF
         CALL "CARVER-SETUP" USING WS-SEED-U
         MOVE 1 TO W-ACTIVE
         MOVE 3 TO W-DIM
         MOVE L-CX TO W-CX
         MOVE L-CZ TO W-CZ
         SET W-ADDR TO ADDRESS OF L-CHUNK
         MOVE 0 TO W-AQ-READY W-OV-COUNT W-OV-LOST W-BE-COUNT W-BE-LOST W-ENT-COUNT W-ENT-LOST W-ENT-BOX-COUNT W-ENT-BOX-LOST
         PERFORM VARYING W-SUB FROM 0 BY 1 UNTIL W-SUB > 10
             CALL "STRUCT-STAGE-HOOK" USING WS-JOB
         END-PERFORM
         MOVE W-OV TO GO-DATA
         MOVE W-BE TO GB-DATA
         MOVE W-ENT TO GE-DATA
     END-IF
*>   the fill_layer features of the null layers (56 section 4.4): a layer the terrain fill skipped is written where the cell is still air
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIMIT
         IF FS-KIND(WS-I) = 0 AND FS-STATE(WS-I) NOT = 0
             COMPUTE WS-BASE = (WS-I - 1) * 256
             PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > 256
                 IF CE-STATE(WS-BASE + WS-C) = 0
                     MOVE FS-STATE(WS-I) TO CE-STATE(WS-BASE + WS-C)
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-FLAT-CHUNK.
