*> The debug world generator (docs/design/debug-world.md; the hidden `debug` world type, T0445): a flat grid
*> in which every block state of the standard set appears once, in state-id order, with nothing else:
*> no noise, climate, density, aquifer, surface, carver, ore or feature stage runs here (T0447).
*>   state s (0 <= s < N, N = the standard set's state count, 35723): x = 2 * (s mod 192), y = 70,
*>   z = 2 * (s div 192); every other block of y = 70 is air.
*>   A floor of stone (state 1) at y = 69 in chunks -1 to 24 (x and z -16 to 399); everything else air.
*>   The biome is minecraft:plains in every cell (the row of the biome table CORE-BIOMES, else 0).
*> The overworld dimension type: min y -64, so a block (x, y, z) is the cell (y + 64) * 256 + z * 16 + x + 1.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDGEN-DEBUG-CHUNK.
*> USING chunk x, chunk z (BINARY-LONG), chunk memory (CELLS.cpy layout; block states and biomes are
*> written, light is left alone), marker-y out (BINARY-LONG, always -1: no marker pillar).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CELLS.
 01 WS-STATES              BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-PLAINS              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 01 L-CHUNK                PIC X.
 01 L-MARKER-Y             BINARY-LONG.
 PROCEDURE DIVISION USING L-CX L-CZ L-CHUNK L-MARKER-Y.
     SET ADDRESS OF CE-CHUNK TO ADDRESS OF L-CHUNK
     MOVE -1 TO L-MARKER-Y
     MOVE LOW-VALUES TO CE-STATES
     MOVE 0 TO WS-PLAINS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CBI-COUNT
         IF CBI-KEY(WS-I)(1:16) = "minecraft:plains" AND CBI-KEY-LENGTH(WS-I) = 16
             COMPUTE WS-PLAINS = WS-I - 1
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CE-BIOME-BYTES
         MOVE WS-PLAINS TO CE-BIOME(WS-I)
     END-PERFORM
     IF L-CX < -1 OR L-CX > 24 OR L-CZ < -1 OR L-CZ > 24
         GOBACK
     END-IF
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-CELL = (69 + 64) * 256 + WS-I
         MOVE 1 TO CE-STATE(WS-CELL)
     END-PERFORM
     IF L-CX < 0 OR L-CX > 23 OR L-CZ < 0 OR L-CZ > 23
         GOBACK
     END-IF
     MOVE 35723 TO WS-STATES
     IF CT-OPEN = 1 AND CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND CT-STATE-COUNT > 0
         MOVE CT-STATE-COUNT TO WS-STATES
     END-IF
     PERFORM VARYING WS-LZ FROM 0 BY 2 UNTIL WS-LZ > 14
         PERFORM VARYING WS-LX FROM 0 BY 2 UNTIL WS-LX > 14
             COMPUTE WS-X = (L-CX * 16 + WS-LX) / 2
             COMPUTE WS-Z = (L-CZ * 16 + WS-LZ) / 2
             COMPUTE WS-S = WS-Z * 192 + WS-X
             IF WS-S < WS-STATES
                 COMPUTE WS-CELL = (70 + 64) * 256 + WS-LZ * 16 + WS-LX + 1
                 MOVE WS-S TO CE-STATE(WS-CELL)
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDGEN-DEBUG-CHUNK.
