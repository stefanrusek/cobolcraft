*> Ice and snow of docs/protocol/33 section 4.4 (tickPrecipitation), run from the random ticks of a chunk (WORLDSIM-RANDOM, 2.4 step 1): one attempt per tick and
*> chunk with probability 1/48 for each of random_tick_speed draws, at a column picked by randomBlockPos. The level random of the artifact does not exist in this
*> core: the 1/48 draw is taken from the level's randValue (WSIM.cpy) after the position. The biome base temperatures are those of standin-content section 4.3
*> (lowland 0.6, upland 0.3, ash flats 1.4; any other biome 0.8); the block light at the cell is taken as 0 (no light source of this world reaches a column top;
*> the light engine of 32 will answer it); the sea level is 48 (standin-content section 5.1). Ice and snow are the blocks "minecraft:ice" and "minecraft:snow"
*> (one layer, the default state) of the open block tables; a world without them forms none. The cauldron fill of 4.4 has no cauldron block here (WW-CAULDRON stays a
*> helper).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-BIOME-TEMP.
*> USING biome id (BINARY-LONG), base temperature out (FLOAT-LONG): standin-content section 4.3.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-TEMPS               PIC X(12) VALUE "060030140080".
 01 WS-INDEX               BINARY-LONG.
 01 WS-HUNDREDTHS          PIC 999.
 LINKAGE SECTION.
 01 L-BIOME                BINARY-LONG.
 01 L-TEMPERATURE          FLOAT-LONG.
 PROCEDURE DIVISION USING L-BIOME L-TEMPERATURE.
     COMPUTE WS-INDEX = FUNCTION MIN(L-BIOME, 3) * 3 + 1
     MOVE WS-TEMPS(WS-INDEX:3) TO WS-HUNDREDTHS
     COMPUTE L-TEMPERATURE = WS-HUNDREDTHS / 100
     GOBACK.
 END PROGRAM WORLDSIM-BIOME-TEMP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-FIND-BLOCK.
*> USING key (PIC X(48)), default state out (BINARY-LONG; 0 when the tables have no such block): the block of the open tables with that key.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 01 WS-I                   BINARY-LONG.
 01 WS-BARE                PIC X(48).
 01 WS-FULL                PIC X(48).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-STATE.
     MOVE 0 TO L-STATE
*>   The standard set's rows have no namespace ("ice"): both forms of the key are looked for.
     CALL "KEY-BARE" USING L-KEY WS-BARE
     CALL "KEY-NAMESPACED" USING L-KEY WS-FULL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         IF CB-KEY(WS-I) = WS-BARE OR CB-KEY(WS-I) = WS-FULL
             MOVE CB-DEFAULT-STATE(WS-I) TO L-STATE
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-FIND-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-COLUMN-TOP.
*> USING dimension row, x, z (BINARY-LONG; the column), top out (BINARY-LONG): one above the highest non-void block of the column (the dimension's lowest
*> y when it holds none). A column of a loaded chunk is read from the chunk, a section with no block at a time; any other through WORLD-GET-BLOCK from the top
*> (the precipitation draw of the random ticks does this for every chunk and tick, and the block-by-block walk down from the build limit cost most of a frame).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 COPY CELLS.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-LY                  BINARY-LONG.
 01 WS-BASE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-COLUMN              BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 B-CELLS                PIC X(CE-CHUNK-BYTES) BASED.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-TOP                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-TOP.
     MOVE DM-MIN-Y(L-DIM) TO WS-MIN-Y
     MOVE WS-MIN-Y TO L-TOP
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLD-FIND" USING L-DIM WS-CX WS-CZ WS-ROW
     IF WS-ROW = 0
         COMPUTE WS-Y = DM-MIN-Y(L-DIM) + DM-HEIGHT(L-DIM) - 1
         PERFORM VARYING WS-Y FROM WS-Y BY -1 UNTIL WS-Y < WS-MIN-Y OR L-TOP > WS-MIN-Y
             CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y L-Z WS-STATE
             IF WS-STATE NOT = 0
                 COMPUTE L-TOP = WS-Y + 1
             END-IF
         END-PERFORM
         GOBACK
     END-IF
     SET ADDRESS OF CE-CHUNK TO CK-ADDR(WS-ROW)
     SET ADDRESS OF B-CELLS TO ADDRESS OF CE-CHUNK
     COMPUTE WS-COLUMN = (L-Z - WS-CZ * 16) * 16 + (L-X - WS-CX * 16) + 1
     MOVE 0 TO WS-DONE
     PERFORM VARYING WS-S FROM DM-HEIGHT(L-DIM) BY -16 UNTIL WS-S < 16 OR WS-DONE = 1
         COMPUTE WS-BASE = (WS-S / 16 - 1) * 8192 + 1
         IF B-CELLS(WS-BASE:8192) NOT = LOW-VALUES
             PERFORM VARYING WS-LY FROM WS-S BY -1 UNTIL WS-LY < WS-S - 15 OR WS-DONE = 1
                 COMPUTE WS-BASE = (WS-LY - 1) * 256 + WS-COLUMN
                 MOVE CE-STATE(WS-BASE) TO WS-STATE
                 IF WS-STATE NOT = 0
                     COMPUTE L-TOP = WS-MIN-Y + WS-LY
                     MOVE 1 TO WS-DONE
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM WORLDSIM-COLUMN-TOP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDSIM-PRECIPITATION.
*> USING dimension row, x, z (BINARY-LONG; the column), raining (BINARY-LONG): tickPrecipitation (33 section 4.4). top is one above the highest non-void block
*> of the column, below = top - 1, the biome that of the column. 1 Freeze: shouldFreeze at `below` (WW-FREEZE: not warm enough at top, inside the height, block
*> light below 10, a water source there and not all four horizontal neighbours water) turns it to ice. 2 With rain, a cold enough precipitation column with air at
*> top and a solid block below (max_snow_accumulation_height 1: one layer only, never stacked) gets a snow layer (WW-SNOW).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 01 WS-Y                   BINARY-LONG.
 01 WS-TOP                 BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-MIN-Y               BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-AMOUNT              BINARY-LONG.
 01 WS-FALLING             BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-HOLDS               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-CELL-Z              BINARY-LONG.
 01 WS-BIOMES.
    05 WS-BIOME            BINARY-LONG OCCURS 16 TIMES.
 01 WS-BASE                FLOAT-LONG.
 01 WS-NOISE               FLOAT-LONG VALUE 0.
 01 WS-SEA                 BINARY-LONG VALUE 48.
 01 WS-TEMPERATURE         FLOAT-LONG.
 01 WS-HAS                 BINARY-LONG.
 01 WS-PRECIP              BINARY-LONG.
 01 WS-WARM                BINARY-LONG.
 01 WS-INSIDE              BINARY-LONG VALUE 1.
 01 WS-LIGHT               BINARY-LONG VALUE 0.
 01 WS-SOURCE              BINARY-LONG.
 01 WS-SURROUNDED          BINARY-LONG.
 01 WS-FREEZE              BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-DIRS                PIC X(4) VALUE "2534".
 01 WS-DIR                 BINARY-LONG.
 01 WS-DIGIT               PIC 9.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-WATERS              BINARY-LONG.
 01 WS-ICE                 BINARY-LONG.
 01 WS-SNOW                BINARY-LONG.
 01 WS-ICE-KEY             PIC X(48) VALUE "minecraft:ice".
 01 WS-SNOW-KEY            PIC X(48) VALUE "minecraft:snow".
 01 WS-HEIGHT              BINARY-LONG VALUE 1.
 01 WS-SNOWY               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-LAYER               BINARY-LONG VALUE 0.
 01 WS-LAYERS              BINARY-LONG VALUE 0.
 01 WS-SURVIVES            BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-NEW-LAYERS          BINARY-LONG.
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-RAINING              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Z L-RAINING.
     MOVE DM-MIN-Y(L-DIM) TO WS-MIN-Y
     CALL "WORLDSIM-COLUMN-TOP" USING L-DIM L-X L-Z WS-TOP
     COMPUTE WS-BELOW = WS-TOP - 1
     COMPUTE WS-CX = (L-X - FUNCTION MOD(L-X, 16)) / 16
     COMPUTE WS-CZ = (L-Z - FUNCTION MOD(L-Z, 16)) / 16
     CALL "WORLDGEN-BIOMES" USING WS-CX WS-CZ WS-BIOMES
     COMPUTE WS-CELL-Z = (L-Z - WS-CZ * 16) / 4
     COMPUTE WS-CELL = (L-X - WS-CX * 16) / 4
     COMPUTE WS-CELL = WS-CELL-Z * 4 + WS-CELL + 1
     CALL "WORLDSIM-BIOME-TEMP" USING WS-BIOME(WS-CELL) WS-BASE
     MOVE CBI-PRECIPITATION(WS-BIOME(WS-CELL) + 1) TO WS-HAS
     CALL "WW-TEMPERATURE" USING WS-BASE WS-TOP WS-SEA WS-NOISE WS-TEMPERATURE
     CALL "WW-PRECIPITATION" USING WS-HAS WS-TEMPERATURE WS-PRECIP WS-WARM
*>   1 Freeze.
     CALL "FLUID-CELL" USING L-DIM L-X WS-BELOW L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
     MOVE 0 TO WS-SOURCE
     IF WS-F = 1 AND WS-KIND = 2
         MOVE 1 TO WS-SOURCE
     END-IF
     MOVE 0 TO WS-WATERS
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 4
         MOVE WS-DIRS(WS-D:1) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-DIR
         CALL "BU-DIRECTION" USING WS-DIR WS-DX WS-DY WS-DZ
         COMPUTE WS-NX = L-X + WS-DX
         COMPUTE WS-NZ = L-Z + WS-DZ
         CALL "FLUID-CELL" USING L-DIM WS-NX WS-BELOW WS-NZ WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-F = 1
             ADD 1 TO WS-WATERS
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SURROUNDED
     IF WS-WATERS = 4
         MOVE 1 TO WS-SURROUNDED
     END-IF
     CALL "WW-FREEZE" USING WS-WARM WS-INSIDE WS-LIGHT WS-SOURCE WS-SURROUNDED WS-FREEZE
     IF WS-FREEZE = 1
         CALL "WORLDSIM-FIND-BLOCK" USING WS-ICE-KEY WS-ICE
         IF WS-ICE > 0
             CALL "LEVEL-SET-BLOCK" USING L-DIM L-X WS-BELOW L-Z WS-ICE WS-FLAGS WS-BUDGET WS-RESULT
         END-IF
     END-IF
*>   2 Snow.
     IF L-RAINING = 1
         MOVE 0 TO WS-SNOWY
         IF WS-PRECIP = 2
             MOVE 1 TO WS-SNOWY
         END-IF
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-TOP L-Z WS-STATE
         MOVE 0 TO WS-AIR WS-SURVIVES
         IF WS-STATE = 0
             MOVE 1 TO WS-AIR
         END-IF
         CALL "FLUID-CELL" USING L-DIM L-X WS-BELOW L-Z WS-STATE WS-F WS-KIND WS-AMOUNT WS-FALLING WS-SOLID WS-HOLDS
         IF WS-SOLID = 1
             MOVE 1 TO WS-SURVIVES
         END-IF
         CALL "WW-SNOW" USING WS-HEIGHT L-RAINING WS-SNOWY WS-INSIDE WS-LIGHT WS-AIR WS-LAYER WS-LAYERS WS-SURVIVES WS-ACTION
             WS-NEW-LAYERS
         IF WS-ACTION = 1
             CALL "WORLDSIM-FIND-BLOCK" USING WS-SNOW-KEY WS-SNOW
             IF WS-SNOW > 0
                 CALL "LEVEL-SET-BLOCK" USING L-DIM L-X WS-TOP L-Z WS-SNOW WS-FLAGS WS-BUDGET WS-RESULT
             END-IF
         END-IF
     END-IF
     GOBACK.
 END PROGRAM WORLDSIM-PRECIPITATION.
